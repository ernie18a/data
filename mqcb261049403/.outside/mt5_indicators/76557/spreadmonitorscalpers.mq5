//+------------------------------------------------------------------+
//|                                       SpreadMonitorScalpers.mq5  |
//|                             Copyright 2026, Radoslaw Karol Lubas |
//|                                            https://www.mql5.com  |
//+------------------------------------------------------------------+
// Spread histogram in a sub-window + statistics panel for scalpers.
// Shows current/avg/max/min spread, round-trip spread cost per trade,
// a threshold line on the histogram, and alerts when spread exceeds it.
// Analytical tool only: it does not send orders and draws no price data.
#property copyright "Copyright 2026, Radoslaw Karol Lubas"
#property link      "https://www.mql5.com"
#property version   "1.32"
#property description "Spread histogram + statistics panel for scalpers: current/avg/max/min spread, cost per trade, threshold alerts."
#property indicator_separate_window
#property indicator_plots   1
#property indicator_buffers 1

//--- histogram plot
#property indicator_label1  "Spread"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

//--- Object name prefixes (Spread Monitor Scalpers)
#define SMS_PREFIX        "SMS_"
#define SMS_PANEL_PFX     SMS_PREFIX "panel_"
#define SMS_THRESHOLD_LINE SMS_PREFIX "threshold_line"

//--- Panel corner selector (maps to ENUM_BASE_CORNER)
enum ENUM_SMS_CORNER
  {
   SMS_CORNER_LEFT_UPPER=0,  // Left upper
   SMS_CORNER_RIGHT_UPPER=1, // Right upper
   SMS_CORNER_LEFT_LOWER=2,  // Left lower
   SMS_CORNER_RIGHT_LOWER=3  // Right lower
  };

//--- Inputs
input int             InpLookbackBars         = 100;                  // Bars for avg/max/min spread
input color           InpHistogramColor       = clrDodgerBlue;       // Histogram color
input color           InpThresholdColor       = clrRed;              // Threshold line color
input bool            InpShowPanel            = true;                // Show statistics panel
input ENUM_SMS_CORNER InpPanelCorner          = SMS_CORNER_LEFT_UPPER; // Panel corner
input int             InpFontSize             = 9;                   // Panel font size
input color           InpTextColor            = clrBlack;        // Panel text color
input double          InpSpreadThresholdPips  = 2.0;                 // Alert threshold (pips)
input double          InpMaxScalePips         = 0.0;                 // Histogram scale ceiling (pips, 0 = auto: 4x threshold)
input bool            InpPersistHistory       = true;                // Remember spread history per symbol+timeframe (file in MQL5\Files)
input bool            InpAlertEnabled         = true;                // Enable spread alert
input int             InpAlertCooldownSec     = 30;                  // Alert cooldown (seconds)
input bool            InpPushNotifications    = false;               // Push notifications
input bool            InpShowCostPerTrade     = true;                // Show round-trip cost per trade

//--- Indicator buffer (spread in pips per bar)
double SpreadBuffer[];

//--- One recorded (bar time, spread) point for the persistence file
struct SmsHistPoint
  {
   datetime t;
   double   v;
  };

//--- Globals
double   g_pip_size        = 0.0; // one pip in points (10 for 5/3-digit, 1 otherwise)
datetime g_last_alert      = 0;   // last spread-alert time (cooldown)
int      g_sub_window      = -1;  // sub-window index of this indicator
bool     g_seeded          = false; // guards the one-time empty-seed (see OnCalculate)
datetime g_bar_time[];              // mirrors time[] so OnDeinit can pair it with SpreadBuffer

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"SpreadMonitorScalpers");
   SetIndexBuffer(0,SpreadBuffer,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"Spread (pips)");
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpHistogramColor);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
//--- hide the raw buffer value MT5 appends to the sub-window label next to
//--- the indicator name (and in the Data Window): the spread is already
//--- shown by the statistics panel, the bare number there is redundant
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- bars with no recorded spread (before attach, or a later history reload)
//--- are left empty instead of a fake flat value, so the histogram never
//--- "resets" to a misleading plateau
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   IndicatorSetInteger(INDICATOR_DIGITS,1);
//--- fixed vertical scale so the threshold line and bar heights stay put;
//--- without this MT5 auto-fits the axis to visible data, so every bar's
//--- PIXEL height shifts on every tick even when its VALUE is unchanged
   double scale_max=(InpMaxScalePips>0.0)?InpMaxScalePips:InpSpreadThresholdPips*4.0;
   IndicatorSetDouble(INDICATOR_MINIMUM,0.0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,scale_max);
//--- pip size: 5- and 3-digit brokers quote a fractional pip
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   g_pip_size=(digits==3 || digits==5) ? 10.0 : 1.0;
   g_last_alert=0;
   g_sub_window=-1;
   g_seeded=false;
//--- old bar times belonged to the previous symbol/period (if any); a stale
//--- mirror here would misalign new bars against wrong indices
   ArrayResize(g_bar_time,0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SaveHistory();
   ObjectsDeleteAll(0,SMS_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<=0)
      return(0);
   double spread_pips=CurrentSpreadPips();
//--- mirror bar open times so OnDeinit can pair them with recorded spread
//--- values when saving; only copy genuinely new entries (cheap, O(1)
//--- amortized instead of re-copying the whole array every tick)
   int mirrored=ArraySize(g_bar_time);
   if(rates_total>mirrored)
     {
      ArrayResize(g_bar_time,rates_total);
      for(int bi=mirrored;bi<rates_total;bi++)
         g_bar_time[bi]=time[bi];
     }
//--- MT5 keeps no per-bar spread history; leave everything before attach
//--- empty (no bar drawn), then try to restore real values we recorded
//--- earlier for this exact symbol+timeframe from the persistence file
//--- (survives timeframe/symbol switches, which re-run OnInit). Do this
//--- only ONCE per attach so a later full recalc doesn't wipe bars we
//--- already recorded live since the restore.
   if(prev_calculated==0 && !g_seeded)
     {
      ArrayInitialize(SpreadBuffer,EMPTY_VALUE);
      LoadHistory();
      g_seeded=true;
     }
//--- the current (last) bar tracks live spread; older bars stay frozen.
//--- a spread of 0 means "no quotes right now" (bar-open rollover before
//--- the first tick, a gap, market closed) not a real 0-pip market, so
//--- never record it: it would drag Min down to 0.0 permanently (e.g. a
//--- misleading "Min: 0.0" on XAUUSD). Leave the bar as-is (EMPTY_VALUE
//--- until it sees a genuine quote) so stats reflect real trading spreads.
   if(spread_pips>0.0)
      SpreadBuffer[rates_total-1]=spread_pips;
//--- stats over the last InpLookbackBars bars, real recordings only
   int lookback=(int)MathMin((int)InpLookbackBars,rates_total);
   if(lookback<1)
      lookback=1;
   double s_avg=0.0,s_max=-DBL_MAX,s_min=DBL_MAX;
   int n_real=0;
   for(int i=rates_total-1;i>=rates_total-lookback;i--)
     {
      double v=SpreadBuffer[i];
      if(v==EMPTY_VALUE || v<=0.0)   // skip empties and legacy 0 recordings (no-quote artifacts)
         continue;
      n_real++;
      s_avg+=v;
      if(v>s_max) s_max=v;
      if(v<s_min) s_min=v;
     }
   s_avg=(n_real>0)?s_avg/n_real:0.0;
   if(s_max==-DBL_MAX) s_max=0.0;
   if(s_min==DBL_MAX)  s_min=0.0;
//--- threshold line on the histogram sub-window
   DrawThresholdLine();
//--- statistics panel
   if(InpShowPanel)
      UpdatePanel(spread_pips,s_avg,s_max,s_min);
   else
      ObjectsDeleteAll(0,SMS_PANEL_PFX);
//--- alert with cooldown
   CheckSpreadAlert(spread_pips);
   ChartRedraw();
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Current spread in pips                                           |
//+------------------------------------------------------------------+
double CurrentSpreadPips()
  {
   long spread_points=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   return((double)spread_points/g_pip_size);
  }

//+------------------------------------------------------------------+
//| Persistence file name: one file per symbol+timeframe, so switching |
//| instruments never mixes their spread history                     |
//+------------------------------------------------------------------+
string HistoryFileName()
  {
   return("SMS_hist_"+_Symbol+"_"+EnumToString(_Period)+".bin");
  }

//+------------------------------------------------------------------+
//| Save every real (non-empty) recorded point, keyed by bar time, so |
//| it survives a timeframe/symbol switch and back (best-effort: a    |
//| failed write never blocks shutdown)                               |
//+------------------------------------------------------------------+
void SaveHistory()
  {
   if(!InpPersistHistory)
      return;
   int total=MathMin(ArraySize(SpreadBuffer),ArraySize(g_bar_time));
   if(total<=0)
      return;
   SmsHistPoint pts[];
   ArrayResize(pts,total);
   int n=0;
   for(int i=0;i<total;i++)
     {
      if(SpreadBuffer[i]==EMPTY_VALUE)
         continue;
      pts[n].t=g_bar_time[i];
      pts[n].v=SpreadBuffer[i];
      n++;
     }
   if(n<=0)
      return;
   ArrayResize(pts,n);
   int h=FileOpen(HistoryFileName(),FILE_WRITE|FILE_BIN);
   if(h==INVALID_HANDLE)
      return;
   FileWriteArray(h,pts,0,n);
   FileClose(h);
  }

//+------------------------------------------------------------------+
//| Restore points from a previous session/timeframe for THIS exact   |
//| symbol+timeframe, matching by bar time (never by index - bar      |
//| counts differ across timeframes). Both arrays are chronologically |
//| ascending, so a single linear sweep pairs them.                   |
//+------------------------------------------------------------------+
void LoadHistory()
  {
   if(!InpPersistHistory)
      return;
   int h=FileOpen(HistoryFileName(),FILE_READ|FILE_BIN);
   if(h==INVALID_HANDLE)
      return; // no saved history yet - fine, bars stay empty
   int n=(int)(FileSize(h)/sizeof(SmsHistPoint));
   SmsHistPoint pts[];
   if(n>0)
     {
      ArrayResize(pts,n);
      FileReadArray(h,pts,0,n);
     }
   FileClose(h);
   if(n<=0)
      return;
   int total=ArraySize(g_bar_time);
   int pi=0;
   for(int i=0;i<total && pi<n;i++)
     {
      while(pi<n && pts[pi].t<g_bar_time[i])
         pi++;
      if(pi<n && pts[pi].t==g_bar_time[i])
        {
         SpreadBuffer[i]=pts[pi].v;
         pi++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Draw or move the threshold horizontal line in the sub-window     |
//+------------------------------------------------------------------+
void DrawThresholdLine()
  {
   if(g_sub_window<0)
      g_sub_window=ChartWindowFind(); // sub-window this indicator runs in
   if(g_sub_window<0)
      return; // not registered yet, retry on the next tick
   if(ObjectFind(0,SMS_THRESHOLD_LINE)<0)
     {
      ObjectCreate(0,SMS_THRESHOLD_LINE,OBJ_HLINE,g_sub_window,0,InpSpreadThresholdPips);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_COLOR,InpThresholdColor);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_BACK,false);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_HIDDEN,true);
     }
   else
     {
      ObjectSetDouble(0,SMS_THRESHOLD_LINE,OBJPROP_PRICE,InpSpreadThresholdPips);
      ObjectSetInteger(0,SMS_THRESHOLD_LINE,OBJPROP_COLOR,InpThresholdColor);
     }
  }

//+------------------------------------------------------------------+
//| Map input corner enum to ENUM_BASE_CORNER                       |
//+------------------------------------------------------------------+
ENUM_BASE_CORNER CornerBase()
  {
   switch(InpPanelCorner)
     {
      case SMS_CORNER_LEFT_UPPER:  return(CORNER_LEFT_UPPER);
      case SMS_CORNER_RIGHT_UPPER: return(CORNER_RIGHT_UPPER);
      case SMS_CORNER_LEFT_LOWER:  return(CORNER_LEFT_LOWER);
      case SMS_CORNER_RIGHT_LOWER: return(CORNER_RIGHT_LOWER);
     }
   return(CORNER_LEFT_UPPER);
  }

//+------------------------------------------------------------------+
//| Text anchor matching the chosen corner                           |
//+------------------------------------------------------------------+
ENUM_ANCHOR_POINT CornerAnchor()
  {
   switch(InpPanelCorner)
     {
      case SMS_CORNER_LEFT_UPPER:  return(ANCHOR_LEFT_UPPER);
      case SMS_CORNER_RIGHT_UPPER: return(ANCHOR_RIGHT_UPPER);
      case SMS_CORNER_LEFT_LOWER:  return(ANCHOR_LEFT_LOWER);
      case SMS_CORNER_RIGHT_LOWER: return(ANCHOR_RIGHT_LOWER);
     }
   return(ANCHOR_LEFT_UPPER);
  }

//+------------------------------------------------------------------+
//| Refresh the statistics panel                                     |
//+------------------------------------------------------------------+
void UpdatePanel(const double cur,const double avg,
                 const double mx,const double mn)
  {
   if(g_sub_window<0)
      return; // sub-window not registered yet; retry on the next tick
//--- spread is displayed in pips with one decimal (INDICATOR_DIGITS=1)
   int row=0;
   EnsurePanelLabel(row++,"Spread: "+DoubleToString(cur,1)+" pips",cur>InpSpreadThresholdPips?clrTomato:InpTextColor);
   EnsurePanelLabel(row++,"Avg ("+IntegerToString(InpLookbackBars)+"): "+DoubleToString(avg,1),InpTextColor);
   EnsurePanelLabel(row++,"Max: "+DoubleToString(mx,1),InpTextColor);
   EnsurePanelLabel(row++,"Min: "+DoubleToString(mn,1),InpTextColor);
//--- round-trip spread cost = the pips a trade must clear to break even
   if(InpShowCostPerTrade)
      EnsurePanelLabel(row++,"Cost/trade: "+DoubleToString(cur*2.0,1)+" pips",InpTextColor);
  }

//+------------------------------------------------------------------+
//| Create or update a single panel text label                       |
//+------------------------------------------------------------------+
void EnsurePanelLabel(const int row,const string text,const color clr)
  {
   string name=SMS_PANEL_PFX+IntegerToString(row);
   if(ObjectFind(0,name)<0)
     {
      //--- create the panel label inside our sub-window, not the price chart
      ObjectCreate(0,name,OBJ_LABEL,g_sub_window,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CornerBase());
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,CornerAnchor());
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,5);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_CORNER,CornerBase());
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,CornerAnchor());
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,16+row*(InpFontSize+6));
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

//+------------------------------------------------------------------+
//| Spread threshold alert with cooldown                             |
//+------------------------------------------------------------------+
void CheckSpreadAlert(const double spread_pips)
  {
   if(!InpAlertEnabled)
      return;
   if(spread_pips<=InpSpreadThresholdPips)
      return;
   datetime now=TimeCurrent();
   if(now-g_last_alert<InpAlertCooldownSec)
      return;
   g_last_alert=now;
   string msg=StringFormat("%s spread alert: %.1f pips - check before entry (threshold %.1f)",
                           _Symbol,spread_pips,InpSpreadThresholdPips);
   Alert(msg);
   Print(msg);
   if(InpPushNotifications)
      SendNotification(msg);
  }
//+------------------------------------------------------------------+

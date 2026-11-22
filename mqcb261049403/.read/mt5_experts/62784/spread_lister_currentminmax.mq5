//+------------------------------------------------------------------+
//| EA Spread Lister - current, min, max per day                     |
//| Purpose : Display current, min, max spread for all visible       |
//|           Market Watch symbols in a table.                       |
//| Notes   : - Tracks min/max from the time the EA is running.      |
//|           - Resets min/max at server-day change (midnight).      |
//|           - Can display spreads in Points or Pips.               |
//|                                                                  |
//| this is a GIFT brought to you by HeinBollo                       |
//| please honor by leaving 5 star review and provide feedback       |
//+------------------------------------------------------------------+
#property strict

//--------------------------- Inputs --------------------------------
// Timer interval in seconds for polling quotes.
// Smaller = more accurate min/max; larger = less resource usage.
input int    InputTimerSeconds = 1; //timer in seconds

// Show the table sorted by current spread descending
input bool   InputSortByCurrentSpread = false; // sorting by Spread?

// Number of decimals for printing spread values (for points or pips)
input int    InputPrintDecimals = 1; //# decimal points

// Optional: filter out symbols with zero quotes
input bool   InputHideInactiveSymbols = true; // only active in Market Watch

// NEW: Display options
// If true, the table shows spreads in Pips; if false, in Points.
input bool   InputShowAsPips = false; // shows Pips instead of Points

// Optional custom pip factor: number of Points per Pip.
// Example: for 5-digit FX pairs usually 10, for 3-digit JPY pairs also 10.
// Leave 0 to auto-detect from symbol digits.
input double InputCustomPipFactorInPoints = 0.0; //pip factor auto=0, 3&5-digit=10
// Monospace font settings
input string InputFontName = "Courier New";   // "Consolas" as fallback
input int    InputFontSize = 10;          // font size 10 by default
input color  InputFontColor = clrLightGreen;   // color

// Optional prefix title line
input string InputTitle = "Spread Table"; //headline of table
input ENUM_BASE_CORNER InputCorner = CORNER_LEFT_UPPER;
input int    InputMarginX    = 10;           // x-axis shift
input int    InputMarginY    = 20;           // y-axis shift
input int    InputLinePadPx  = 4;            // vertical padding per row

// Chart appearance
input bool   InputMakeChartBlack = true;    // black-out chart for increases readability

//--------------------------- Data ----------------------------------
struct SpreadInfo
  {
   string            symbol;
   double            point;
   int               digits;
   double            cur_spread;   // POINTS
   double            min_spread;   // POINTS
   double            max_spread;   // POINTS
   bool              active;
   double            pip_factor;   // points per pip
  };

SpreadInfo g_infos[];
datetime   g_day_start = 0;
int        g_active_count = 0;

// Rendering (one label per line)
string g_row_prefix = "SpreadRow__";
int    g_row_count  = 0;  // number of row objects currently on chart

//------------------------ Helpers ----------------------------------
datetime DayStart(datetime t) { MqlDateTime mt; TimeToStruct(t, mt); mt.hour=0; mt.min=0; mt.sec=0; return StructToTime(mt); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DetectPipFactor(int digits)
  {
   if(InputCustomPipFactorInPoints > 0.0)
      return InputCustomPipFactorInPoints;
   if(digits==5 || digits==3)
      return 10.0;      // typical FX quoting
   return 1.0;                                  // fallback: pip == point
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LoadVisibleSymbols()
  {
   ArrayResize(g_infos, 0);
   int total = SymbolsTotal(true);
   if(total<=0)
      return false;

   ArrayResize(g_infos, total);
   for(int i=0;i<total;++i)
     {
      string sym = SymbolName(i,true);
      SymbolSelect(sym,true);
      double point = SymbolInfoDouble(sym, SYMBOL_POINT);
      int    digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);

      g_infos[i].symbol     = sym;
      g_infos[i].point      = (point>0.0?point:0.00001);
      g_infos[i].digits     = digits;
      g_infos[i].cur_spread = 0.0;
      g_infos[i].min_spread = DBL_MAX;
      g_infos[i].max_spread = 0.0;
      g_infos[i].active     = false;
      g_infos[i].pip_factor = DetectPipFactor(digits);
     }
   return true;
  }

// Update spreads; prefer Bid/Ask, else fallback to broker-reported SYMBOL_SPREAD
void UpdateSpreadsAll()
  {
   g_active_count=0;
   int n=ArraySize(g_infos);
   for(int i=0;i<n;++i)
     {
      string sym=g_infos[i].symbol;
      double bid=0.0, ask=0.0;
      bool valid=(SymbolInfoDouble(sym,SYMBOL_BID,bid) &&
                  SymbolInfoDouble(sym,SYMBOL_ASK,ask) &&
                  bid>0.0 && ask>0.0 && ask>=bid);

      double spread_pts=0.0;
      if(valid)
        {
         spread_pts=(ask-bid)/g_infos[i].point;
         g_infos[i].active=true;
        }
      else
        {
         long spr=0;
         if(SymbolInfoInteger(sym,SYMBOL_SPREAD,spr) && spr>0)
           {
            spread_pts=(double)spr;   // already in points
            g_infos[i].active=true;
           }
         else
           {
            g_infos[i].active=false;
           }
        }

      if(g_infos[i].active)
        {
         g_infos[i].cur_spread=spread_pts;
         if(spread_pts<g_infos[i].min_spread)
            g_infos[i].min_spread=spread_pts;
         if(spread_pts>g_infos[i].max_spread)
            g_infos[i].max_spread=spread_pts;
         ++g_active_count;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MaybeResetAtMidnight()
  {
   datetime today=DayStart(TimeCurrent());
   if(g_day_start==0)
     {
      g_day_start=today;
      return;
     }
   if(today!=g_day_start)
     {
      for(int i=0;i<ArraySize(g_infos);++i)
        {
         g_infos[i].min_spread=DBL_MAX;
         g_infos[i].max_spread=0.0;
        }
      g_day_start=today;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ToDisplay(const SpreadInfo &info,double points)
  {
   if(!InputShowAsPips)
      return points;
   double f=(info.pip_factor>0.0?info.pip_factor:1.0);
   return points/f;
  }
string UnitLabel() { return (InputShowAsPips?"pips":"points"); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BuildTableString()
  {
   string fullTitle = InputTitle;
   StringAdd(fullTitle, " - copyright by HeinBollo");
   string header =
      (StringLen(fullTitle)?(fullTitle):"") + "\n"
      "Symbol           Current    MinDay    MaxDay    Active\n"
      "------------------------------------------------------";
   string dbg = StringFormat("\nSymbols: %d   Active: %d", ArraySize(g_infos), g_active_count);

   SpreadInfo temp[];
   int n=ArraySize(g_infos);
   ArrayResize(temp,n);
   for(int i=0;i<n;++i)
      temp[i]=g_infos[i];

   if(InputSortByCurrentSpread)
     {
      for(int a=0;a<n-1;++a)
         for(int b=a+1;b<n;++b)
           {
            double sa=(temp[a].active?ToDisplay(temp[a],temp[a].cur_spread):-1e100);
            double sb=(temp[b].active?ToDisplay(temp[b],temp[b].cur_spread):-1e100);
            if(sb>sa)
              {
               SpreadInfo t=temp[a];
               temp[a]=temp[b];
               temp[b]=t;
              }
           }
     }

   string body="";
   for(int i=0;i<n;++i)
     {
      if(InputHideInactiveSymbols && !temp[i].active)
         continue;
      string sym=temp[i].symbol;
      string sCur=(temp[i].active?DoubleToString(ToDisplay(temp[i],temp[i].cur_spread),InputPrintDecimals):"-");
      string sMin=(temp[i].min_spread<DBL_MAX/2?DoubleToString(ToDisplay(temp[i],temp[i].min_spread),InputPrintDecimals):"-");
      string sMax=(temp[i].max_spread>0.0?DoubleToString(ToDisplay(temp[i],temp[i].max_spread),InputPrintDecimals):"-");
      string sAct=(temp[i].active?"yes":"no");
      body += StringFormat("\n%-16s %8s %8s %8s %8s", sym, sCur, sMin, sMax, sAct);
     }

   string t=TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
   string footer=StringFormat("\n------------------------------------------------------\nServer Time: %s   (Spreads in %s)", t, UnitLabel());
   return header + dbg + body + footer;
  }

//---------------------- Rendering (one label per line) -------------
int LineHeight() { return MathMax(1, InputFontSize + InputLinePadPx); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EnsureRowObject(int idx)
  {
   string name = g_row_prefix + IntegerToString(idx);
   if(ObjectFind(0,name)!=-1)
      return;

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);           // draw on top
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InputCorner);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InputFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InputFontColor);
// Fallback font if Consolas not installed
   ObjectSetString(0, name, OBJPROP_FONT, InputFontName);
   string setFont = ObjectGetString(0, name, OBJPROP_FONT);
   if(setFont!=InputFontName)
      ObjectSetString(0, name, OBJPROP_FONT, "Courier New");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetRow(int idx, const string &text)
  {
   EnsureRowObject(idx);
   string name = g_row_prefix + IntegerToString(idx);
   ObjectSetInteger(0, name, OBJPROP_CORNER,    InputCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InputMarginX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InputMarginY + idx * LineHeight());
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,  InputFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,     InputFontColor);
   ObjectSetString(0, name, OBJPROP_FONT,      InputFontName);
   ObjectSetString(0, name, OBJPROP_TEXT,      text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearExtraRows(int needed)
  {
   for(int idx=needed; idx<g_row_count; ++idx)
     {
      string name = g_row_prefix + IntegerToString(idx);
      ObjectDelete(0, name);
     }
   g_row_count = needed;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RenderTableAsRows(const string &table)
  {
   string lines[];
   int cnt = StringSplit(table, '\n', lines);
   if(cnt<=0)
     {
      ClearExtraRows(0);
      return;
     }

   for(int i=0; i<cnt; ++i)
      SetRow(i, lines[i]);
   g_row_count = cnt;
   ClearExtraRows(cnt);
  }

//---------------------- Chart appearance ---------------------------
void MakeChartBlackIfRequested()
  {
   if(!InputMakeChartBlack)
      return;
   long chart_id=0;
   ChartSetInteger(chart_id, CHART_COLOR_BACKGROUND, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_FOREGROUND, clrWhite);
   ChartSetInteger(chart_id, CHART_COLOR_GRID, clrBlack);
   ChartSetInteger(chart_id, CHART_SHOW_GRID, false);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_UP, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_DOWN, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BULL, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BEAR, clrBlack);
   ChartSetInteger(chart_id, CHART_SHOW_OHLC, false);
   ChartSetInteger(chart_id, CHART_SHOW_BID_LINE, false);
   ChartSetInteger(chart_id, CHART_SHOW_ASK_LINE, false);
   ChartSetInteger(chart_id, CHART_SHOW_LAST_LINE, false);
   ChartSetInteger(chart_id, CHART_SHOW_TRADE_LEVELS, false);
   ChartSetInteger(chart_id, CHART_SHOW_TRADE_HISTORY, false);
   ChartSetInteger(chart_id, CHART_COLOR_VOLUME, clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_BID,    clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_ASK,    clrBlack);
   ChartSetInteger(chart_id, CHART_COLOR_LAST,   clrBlack);
  }

//--------------------------- Events --------------------------------
int OnInit()
  {
   g_day_start = DayStart(TimeCurrent());
   if(!LoadVisibleSymbols())
     {
      Print("No visible symbols in Market Watch.");
      return INIT_FAILED;
     }
   MakeChartBlackIfRequested();
   if(InputTimerSeconds<1)
     {
      Print("Timer must be >= 1 sec");
      return INIT_PARAMETERS_INCORRECT;
     }
   EventSetTimer(InputTimerSeconds);
   Print("EA_SpreadTableLabels initialized. Symbols: ", ArraySize(g_infos));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ClearExtraRows(0); // remove all row labels
  }

void OnTick() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MaybeResetAtMidnight();
   UpdateSpreadsAll();
   string table = BuildTableString();
   RenderTableAsRows(table);

   if(g_active_count==0)
      Print("SpreadTable: No active symbols; try InputHideInactiveSymbols=false or check market hours.");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // Reposition existing rows
      for(int i=0; i<g_row_count; ++i)
        {
         string name = g_row_prefix + IntegerToString(i);
         if(ObjectFind(0,name)!=-1)
           {
            ObjectSetInteger(0, name, OBJPROP_CORNER,    InputCorner);
            ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InputMarginX);
            ObjectSetInteger(0, name, OBJPROP_YDISTANCE, InputMarginY + i * LineHeight());
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                       FailedBreakoutDetector.mq5 |
//|                                            Copyright 2026, Serge |
//|              https://www.mql5.com/en/users/serzamichajlik/seller |
//+------------------------------------------------------------------+
//| Failed Breakout Detector                                         |
//|                                                                  |
//| A price action tool. It watches the trading range formed by the |
//| last N bars. When a bar closes outside that range it is a        |
//| breakout. If price closes back inside the range within K bars,   |
//| the breakout FAILED: the traders who bought the breakout (or     |
//| sold it) are trapped, and the market often goes the other way.   |
//|                                                                  |
//| On the chart:                                                    |
//|   small dot          - breakout bar (blue)                       |
//|   arrow above a bar  - failed breakout UP   (bearish)            |
//|   arrow below a bar  - failed breakout DOWN (bullish)            |
//|   label              - number of failed breakouts today          |
//|                                                                  |
//| Works on closed bars only, nothing repaints. Buffers 4 and 5     |
//| (signal, failed count today) can be read from an EA via iCustom. |
//|                                                                  |
//| This is a stand-alone piece of the Market State Reader indicator.|
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Serge"
#property link        "https://www.mql5.com/en/users/serzamichajlik/seller"
#property version     "1.00"
#property description "Marks breakouts of the recent trading range and the ones that fail (price closes back inside within a few bars). Failed breakouts trap traders and often start a move the other way. Closed bars only, no repaint."
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   4
//--- plot 0: breakout up (dot below the bar)
#property indicator_label1  "Breakout up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
//--- plot 1: breakout down (dot above the bar)
#property indicator_label2  "Breakout down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
//--- plot 2: failed breakout up (arrow above the bar, bearish)
#property indicator_label3  "Failed breakout up (bearish)"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrTomato
#property indicator_width3  2
//--- plot 3: failed breakout down (arrow below the bar, bullish)
#property indicator_label4  "Failed breakout down (bullish)"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrMediumSeaGreen
#property indicator_width4  2
//--- input parameters
input int              InpRangeBars     = 12;                // Bars that form the range
input int              InpConfirmBars   = 3;                 // Bars in which the breakout must hold or it has failed
input int              InpAtrPeriod     = 14;                // ATR period (used to filter the range height)
input double           InpMinRangeAtr   = 0.5;               // Minimum range height (x ATR)
input double           InpMaxRangeAtr   = 4.0;               // Maximum range height (x ATR)
input double           InpBufferAtr     = 0.1;               // Close must be this far beyond the range (x ATR)
input bool             InpShowBreakouts = true;              // Show the breakout dots
input bool             InpShowLabel     = true;              // Show the "failed breakouts today" label
input ENUM_BASE_CORNER InpCorner        = CORNER_LEFT_UPPER; // Label corner
input int              InpLabelX        = 10;                // Label X offset
input int              InpLabelY        = 25;                // Label Y offset
input int              InpFontSize      = 10;                // Label font size
input color            InpLabelColor    = clrGray;           // Label colour
input bool             InpAlert         = false;             // Pop-up alert on a failed breakout
input bool             InpPush          = false;             // Push notification on a failed breakout
input bool             InpSound         = false;             // Sound on a failed breakout
input string           InpSoundFile     = "alert.wav";       // Sound file
//--- indicator buffers
double BufBreakUp[];     // plot 0: breakout up, dot below the bar
double BufBreakDown[];   // plot 1: breakout down, dot above the bar
double BufFailUp[];      // plot 2: failed breakout up, arrow above the bar
double BufFailDown[];    // plot 3: failed breakout down, arrow below the bar
double BufSignal[];      // calc: +1 failed breakout down (bullish), -1 failed breakout up (bearish), 0 nothing
double BufFailedToday[]; // calc: number of failed breakouts on the bar's day (so far)
double BufAtr[];         // calc: Wilder ATR
//--- validated inputs
int    g_rangeBars;
int    g_confirmBars;
int    g_atrPeriod;
//--- breakout state (one breakout is tracked at a time)
int      g_boDir=0;          // +1 up, -1 down, 0 nothing pending
int      g_boBar=-1;         // index of the breakout bar
double   g_boHi=0;           // range high at the time of the breakout
double   g_boLo=0;           // range low
int      g_failedToday=0;    // failed breakouts on the current day
int      g_failedUp=0;       // ... of them up
int      g_failedDown=0;     // ... of them down
datetime g_day=0;            // day of the last processed bar
int      g_lastProcessed=-1; // index of the last closed bar that was read
//--- name of the counter label
const string LABEL_NAME="FBD_count_label";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- validate the inputs
   g_rangeBars  =MathMax(2,InpRangeBars);
   g_confirmBars=MathMax(1,InpConfirmBars);
   g_atrPeriod  =MathMax(1,InpAtrPeriod);
//--- indicator buffers
   SetIndexBuffer(0,BufBreakUp,INDICATOR_DATA);
   SetIndexBuffer(1,BufBreakDown,INDICATOR_DATA);
   SetIndexBuffer(2,BufFailUp,INDICATOR_DATA);
   SetIndexBuffer(3,BufFailDown,INDICATOR_DATA);
   SetIndexBuffer(4,BufSignal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufFailedToday,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufAtr,INDICATOR_CALCULATIONS);
//--- arrow codes (Wingdings): 159 = small dot, 234 = arrow down, 233 = arrow up
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,234);
   PlotIndexSetInteger(3,PLOT_ARROW,233);
   for(int i=0; i<4; i++)
     {
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,g_rangeBars+g_atrPeriod);
     }
   if(!InpShowBreakouts)
     {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
     }
//--- name and precision
   IndicatorSetString(INDICATOR_SHORTNAME,"Failed Breakout Detector ("+IntegerToString(g_rangeBars)+","+IntegerToString(g_confirmBars)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,LABEL_NAME);
  }
//+------------------------------------------------------------------+
//| Forget everything (full recalculation)                           |
//+------------------------------------------------------------------+
void ResetState()
  {
   g_boDir=0;
   g_boBar=-1;
   g_boHi=0;
   g_boLo=0;
   g_failedToday=0;
   g_failedUp=0;
   g_failedDown=0;
   g_day=0;
   g_lastProcessed=-1;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int min_bars=g_rangeBars+g_atrPeriod+2;
   if(rates_total<min_bars)
      return(0);
//--- all arrays are used in the natural order: index 0 = oldest bar
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- first bar to (re)calculate
   int start=(prev_calculated>1) ? prev_calculated-1 : 0;
   if(start==0)
      ResetState();
//--- clear the plot values of the bars that are (re)calculated
   for(int i=start; i<rates_total; i++)
     {
      BufBreakUp[i]=0;
      BufBreakDown[i]=0;
      BufFailUp[i]=0;
      BufFailDown[i]=0;
      BufSignal[i]=0;
      BufFailedToday[i]=(i>0) ? BufFailedToday[i-1] : 0;
     }
//--- ATR (Wilder): the whole history once, then incremental
   for(int i=start; i<rates_total; i++)
     {
      if(i==0)
        {
         BufAtr[i]=high[i]-low[i];
         continue;
        }
      double tr=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      BufAtr[i]=(i<g_atrPeriod) ? tr : BufAtr[i-1]+(tr-BufAtr[i-1])/g_atrPeriod;
     }
//--- read every closed bar that was not read yet (the last bar is still forming)
   int last_closed=rates_total-2;
   int from=(g_lastProcessed<0) ? g_rangeBars+g_atrPeriod : g_lastProcessed+1;
   for(int b=from; b<=last_closed; b++)
      ReadBar(b,time,high,low,close,b==last_closed && prev_calculated>0);
   g_lastProcessed=last_closed;
//--- the forming bar carries the current count
   BufFailedToday[rates_total-1]=g_failedToday;
//--- counter label
   if(InpShowLabel)
      DrawLabel();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Reads one closed bar: breakout? failed? held?                    |
//+------------------------------------------------------------------+
void ReadBar(const int b,const datetime &time[],const double &high[],const double &low[],const double &close[],const bool live)
  {
   double atr=MathMax(BufAtr[b],_Point);
//--- new day: reset the counters
   datetime day=time[b]-(time[b]%86400);
   if(day!=g_day)
     {
      g_day=day;
      g_failedToday=0;
      g_failedUp=0;
      g_failedDown=0;
     }
//--- 1. a breakout is pending: did it hold or fail?
   if(g_boDir!=0)
     {
      int  age=b-g_boBar;
      bool back_inside=(g_boDir>0) ? (close[b]<g_boHi) : (close[b]>g_boLo);
      if(back_inside && age<=g_confirmBars)
        {
         //--- FAILED: the close is back inside the range
         if(g_boDir>0)
           {
            BufFailUp[b]=high[b]+0.3*atr;
            BufSignal[b]=-1;
            g_failedUp++;
           }
         else
           {
            BufFailDown[b]=low[b]-0.3*atr;
            BufSignal[b]=+1;
            g_failedDown++;
           }
         g_failedToday++;
         if(live)
            Notify(g_boDir,close[b]);
         g_boDir=0;
        }
      else
         if(age>=g_confirmBars)
            g_boDir=0; // held: the breakout is confirmed, nothing to mark
     }
   BufFailedToday[b]=g_failedToday;
//--- 2. nothing pending: is this bar a breakout of the range formed by the previous bars?
   if(g_boDir==0)
     {
      int    i0=b-g_rangeBars;
      double range_hi=high[i0];
      double range_lo=low[i0];
      for(int i=i0+1; i<b; i++)
        {
         if(high[i]>range_hi)
            range_hi=high[i];
         if(low[i]<range_lo)
            range_lo=low[i];
        }
      double height=range_hi-range_lo;
      double buffer=InpBufferAtr*atr;
      if(height>=InpMinRangeAtr*atr && height<=InpMaxRangeAtr*atr)
        {
         if(close[b]>range_hi+buffer)
           {
            g_boDir=+1;
            g_boBar=b;
            g_boHi=range_hi;
            g_boLo=range_lo;
            BufBreakUp[b]=low[b]-0.15*atr;
           }
         else
            if(close[b]<range_lo-buffer)
              {
               g_boDir=-1;
               g_boBar=b;
               g_boHi=range_hi;
               g_boLo=range_lo;
               BufBreakDown[b]=high[b]+0.15*atr;
              }
        }
     }
  }
//+------------------------------------------------------------------+
//| Alert / push / sound on a failed breakout of the last closed bar |
//+------------------------------------------------------------------+
void Notify(const int dir,const double price)
  {
   string text=StringFormat("%s %s: failed breakout %s at %s (%d today)",
                            _Symbol,
                            StringSubstr(EnumToString(_Period),7),
                            dir>0 ? "UP" : "DOWN",
                            DoubleToString(price,_Digits),
                            g_failedToday);
   if(InpAlert)
      Alert(text);
   if(InpPush)
      SendNotification(text);
   if(InpSound)
      PlaySound(InpSoundFile);
  }
//+------------------------------------------------------------------+
//| Label with the number of failed breakouts today                  |
//+------------------------------------------------------------------+
void DrawLabel()
  {
   if(ObjectFind(0,LABEL_NAME)<0)
     {
      ObjectCreate(0,LABEL_NAME,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_CORNER,InpCorner);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_XDISTANCE,InpLabelX);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_YDISTANCE,InpLabelY);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_COLOR,InpLabelColor);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,LABEL_NAME,OBJPROP_HIDDEN,true);
      ObjectSetString(0,LABEL_NAME,OBJPROP_FONT,"Segoe UI");
     }
   ObjectSetString(0,LABEL_NAME,OBJPROP_TEXT,
                   StringFormat("Failed breakouts today: %d   (up %d / down %d)",g_failedToday,g_failedUp,g_failedDown));
  }
//+------------------------------------------------------------------+

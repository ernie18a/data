//+------------------------------------------------------------------+
//|                                       Session_Sweep_Reversal.mq5 |
//|                                   Copyright 2026, Adeolu Gbadebo |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Marks the prior trading session's high/low and flags "
#property description "liquidity sweeps: breaches of that range that close "
#property description "back inside it within a set number of bars."

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

//--- Plot 1: Session High
#property indicator_label1  "Session High"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_DOT
#property indicator_width1  1

//--- Plot 2: Session Low
#property indicator_label2  "Session Low"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- Plot 3: Bullish sweep (swept the low, closed back above it)
#property indicator_label3  "Bullish Sweep"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLime
#property indicator_width3  2

//--- Plot 4: Bearish sweep (swept the high, closed back below it)
#property indicator_label4  "Bearish Sweep"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  2

//--- Inputs
input int    InpSessionStartHour  = 7;    // Session start hour (broker time)
input int    InpSessionEndHour    = 16;   // Session end hour (broker time)
input double InpSweepBufferPips   = 2.0;  // Min. penetration beyond range, in points
input int    InpReversalBars      = 2;    // Bars allowed to close back inside range
input int    InpMaxSessionsToShow = 5;    // Number of most recent sessions to display

//--- Indicator buffers
double BufSessHigh[];
double BufSessLow[];
double BufBullSweep[];
double BufBearSweep[];

//--- Persistent state across calculation calls
double   g_runHigh      = 0.0;
double   g_runLow       = 0.0;
double   g_frozenHigh   = 0.0;
double   g_frozenLow    = 0.0;
bool     g_inSession     = false;
int      g_breachDir     = 0;    // 0 = none, 1 = above high, -1 = below low
int      g_breachBarIdx  = -1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufSessHigh,  INDICATOR_DATA);
   SetIndexBuffer(1, BufSessLow,   INDICATOR_DATA);
   SetIndexBuffer(2, BufBullSweep, INDICATOR_DATA);
   SetIndexBuffer(3, BufBearSweep, INDICATOR_DATA);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(2, PLOT_ARROW, 233);   // up arrow (Wingdings)
   PlotIndexSetInteger(3, PLOT_ARROW, 234);   // down arrow (Wingdings)

   IndicatorSetString(INDICATOR_SHORTNAME,
      StringFormat("Session Sweep Reversal (%d-%d)", InpSessionStartHour, InpSessionEndHour));
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   g_runHigh = g_runLow = g_frozenHigh = g_frozenLow = 0.0;
   g_inSession    = false;
   g_breachDir    = 0;
   g_breachBarIdx = -1;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Returns true if the given hour falls inside the session window    |
//+------------------------------------------------------------------+
bool IsSessionHour(const int hour)
  {
   if(InpSessionStartHour == InpSessionEndHour)
      return(true); // 24h session edge case

   if(InpSessionStartHour < InpSessionEndHour)
      return(hour >= InpSessionStartHour && hour < InpSessionEndHour);

   // session wraps past midnight
   return(hour >= InpSessionStartHour || hour < InpSessionEndHour);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   if(rates_total < 2)
      return(0);

   int limit = prev_calculated - 1;

   if(prev_calculated == 0)
     {
      limit = 0;
      ArrayInitialize(BufSessHigh,  EMPTY_VALUE);
      ArrayInitialize(BufSessLow,   EMPTY_VALUE);
      ArrayInitialize(BufBullSweep, EMPTY_VALUE);
      ArrayInitialize(BufBearSweep, EMPTY_VALUE);

      g_runHigh = g_runLow = g_frozenHigh = g_frozenLow = 0.0;
      g_inSession    = false;
      g_breachDir    = 0;
      g_breachBarIdx = -1;
     }

   if(limit < 0)
      limit = 0;

   double bufferPts = InpSweepBufferPips * _Point;

   //--- cutoff so we only display the most recent N sessions
   datetime cutoff = 0;
   if(InpMaxSessionsToShow > 0)
      cutoff = TimeCurrent() - (datetime)(InpMaxSessionsToShow) * 86400;

   for(int i = limit; i < rates_total; i++)
     {
      BufBullSweep[i] = EMPTY_VALUE;
      BufBearSweep[i] = EMPTY_VALUE;

      MqlDateTime dt;
      TimeToStruct(time[i], dt);
      bool activeNow = IsSessionHour(dt.hour);

      if(activeNow)
        {
         if(!g_inSession)
           {
            g_runHigh   = high[i];
            g_runLow    = low[i];
            g_inSession = true;
           }
         else
           {
            if(high[i] > g_runHigh) g_runHigh = high[i];
            if(low[i]  < g_runLow)  g_runLow  = low[i];
           }

         BufSessHigh[i] = (time[i] >= cutoff) ? g_runHigh : EMPTY_VALUE;
         BufSessLow[i]  = (time[i] >= cutoff) ? g_runLow  : EMPTY_VALUE;
        }
      else
        {
         if(g_inSession)
           {
            g_frozenHigh = g_runHigh;
            g_frozenLow  = g_runLow;
            g_inSession  = false;
            g_breachDir  = 0; // fresh range, clear any stale breach tracking
           }

         bool showLine = (g_frozenHigh > 0.0) && (time[i] >= cutoff);
         BufSessHigh[i] = showLine ? g_frozenHigh : EMPTY_VALUE;
         BufSessLow[i]  = showLine ? g_frozenLow  : EMPTY_VALUE;

         if(g_frozenHigh > 0.0)
           {
            if(g_breachDir == 0)
              {
               if(high[i] > g_frozenHigh + bufferPts)
                 {
                  g_breachDir    = 1;
                  g_breachBarIdx = i;
                 }
               else if(low[i] < g_frozenLow - bufferPts)
                 {
                  g_breachDir    = -1;
                  g_breachBarIdx = i;
                 }
              }
            else
              {
               int barsSince = i - g_breachBarIdx;

               if(g_breachDir == 1)
                 {
                  if(close[i] < g_frozenHigh)
                    {
                     if(time[i] >= cutoff)
                        BufBearSweep[i] = high[i] + 5 * _Point;
                     g_breachDir = 0;
                    }
                  else if(barsSince >= InpReversalBars)
                     g_breachDir = 0; // no reversal in time, cancel
                 }
               else // g_breachDir == -1
                 {
                  if(close[i] > g_frozenLow)
                    {
                     if(time[i] >= cutoff)
                        BufBullSweep[i] = low[i] - 5 * _Point;
                     g_breachDir = 0;
                    }
                  else if(barsSince >= InpReversalBars)
                     g_breachDir = 0; // no reversal in time, cancel
                 }
              }
           }
        }
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayInitialize(BufSessHigh,  EMPTY_VALUE);
   ArrayInitialize(BufSessLow,   EMPTY_VALUE);
   ArrayInitialize(BufBullSweep, EMPTY_VALUE);
   ArrayInitialize(BufBearSweep, EMPTY_VALUE);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                 SwingHighLow.mq5 |
//|                                                         sahil057 |
//|                           https://www.mql5.com/en/users/sahil057 |
//+------------------------------------------------------------------+
#property copyright "sahil057"
#property link      "https://www.mql5.com/en/users/sahil057"
#property version   "1.00"
#property description "Marks non-repainting swing highs and lows using configurable LeftBars / RightBars pivots."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- Swing High plot (red arrow above the bar)
#property indicator_label1  "Swing High"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_width1  1
//--- Swing Low plot (green arrow below the bar)
#property indicator_label2  "Swing Low"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLime
#property indicator_width2  1
//--- input parameters
input int  InpLeftBars  = 5;      // Left Bars
input int  InpRightBars = 5;      // Right Bars
input int  InpArrowHigh = 234;    // Swing High Arrow Code (Wingdings)
input int  InpArrowLow  = 233;    // Swing Low Arrow Code (Wingdings)
input bool InpPush      = true;   // Send Push Notification
input bool InpEmail     = false;  // Send Email Alert
//--- indicator buffers
double HighBuf[];
double LowBuf[];
//--- bar time of the last swing already alerted (dedupe)
datetime g_lastHighAlert = 0;
datetime g_lastLowAlert  = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- bind plot buffers
   SetIndexBuffer(0, HighBuf, INDICATOR_DATA);
   SetIndexBuffer(1, LowBuf,  INDICATOR_DATA);
//--- assign arrow symbols and the empty value that hides an arrow
   PlotIndexSetInteger(0, PLOT_ARROW, InpArrowHigh);
   PlotIndexSetInteger(1, PLOT_ARROW, InpArrowLow);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
//--- offset arrows away from the candle: high arrow up, low arrow down
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -12);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT,  12);
//--- short name shown on the chart
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("SwingHighLow(%d,%d)", InpLeftBars, InpRightBars));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//|                                                                  |
//| A pivot at bar i needs LeftBars bars on its left and RightBars   |
//| bars on its right, so it can be evaluated only once RightBars    |
//| bars have closed to the right of it.                             |
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
//--- not enough bars to hold a full left+right window yet
   if(rates_total < InpLeftBars + InpRightBars + 1)
      return(rates_total);
//--- work with plain (non-series) indexing: index 0 is the oldest bar
   ArraySetAsSeries(time,    false);
   ArraySetAsSeries(high,    false);
   ArraySetAsSeries(low,     false);
   ArraySetAsSeries(HighBuf, false);
   ArraySetAsSeries(LowBuf,  false);
//--- recompute only the newly available pivots
   int start = (prev_calculated > InpLeftBars) ? prev_calculated - 1 : InpLeftBars;
//--- last bar that already has RightBars closed bars to its right
   int last  = rates_total - 1 - InpRightBars;
//--- scan every confirmable bar for a pivot high / pivot low
   for(int i = start; i <= last; i++)
     {
      HighBuf[i] = 0.0;
      LowBuf[i]  = 0.0;
      if(IsPivotHigh(high, i))
        {
         HighBuf[i] = high[i];
         MaybeAlert(true, time[i], high[i]);
        }
      if(IsPivotLow(low, i))
        {
         LowBuf[i] = low[i];
         MaybeAlert(false, time[i], low[i]);
        }
     }
//--- clear the not-yet-confirmable tail so nothing repaints there
   for(int i = MathMax(last + 1, start); i < rates_total; i++)
     {
      HighBuf[i] = 0.0;
      LowBuf[i]  = 0.0;
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Return true if bar i is a swing high                             |
//+------------------------------------------------------------------+
bool IsPivotHigh(const double &high[], const int i)
  {
   double v = high[i];
//--- must be strictly the highest against the left window
   for(int k = 1; k <= InpLeftBars; k++)
      if(high[i - k] >= v)
         return(false);
//--- must be at least as high as the right window (equal-then-lower allowed)
   for(int k = 1; k <= InpRightBars; k++)
      if(high[i + k] > v)
         return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Return true if bar i is a swing low                              |
//+------------------------------------------------------------------+
bool IsPivotLow(const double &low[], const int i)
  {
   double v = low[i];
//--- must be strictly the lowest against the left window
   for(int k = 1; k <= InpLeftBars; k++)
      if(low[i - k] <= v)
         return(false);
//--- must be at least as low as the right window (equal-then-higher allowed)
   for(int k = 1; k <= InpRightBars; k++)
      if(low[i + k] < v)
         return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Fire alerts once per confirmed swing (deduplicated by bar time)  |
//+------------------------------------------------------------------+
void MaybeAlert(const bool isHigh, const datetime t, const double price)
  {
//--- skip swings already alerted on this or an earlier bar
   if(isHigh)
     {
      if(t <= g_lastHighAlert)
         return;
      g_lastHighAlert = t;
     }
   else
     {
      if(t <= g_lastLowAlert)
         return;
      g_lastLowAlert = t;
     }
//--- on initial load skip old history: alert only recently confirmed swings
   if(TimeCurrent() - t > PeriodSeconds() * (InpRightBars + 2))
      return;
//--- build and send the message
   string dir = isHigh ? "Swing HIGH" : "Swing LOW";
   string msg = StringFormat("%s  %s  @ %s  (%s)",
                             _Symbol, dir, DoubleToString(price, _Digits),
                             EnumToString((ENUM_TIMEFRAMES)_Period));
   if(InpPush)
      SendNotification(msg);
   if(InpEmail)
      SendMail(_Symbol + " " + dir, msg);
   Print(msg);
  }
//+------------------------------------------------------------------+

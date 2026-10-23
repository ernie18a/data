//+------------------------------------------------------------------+
//|                                           BarStatsIndicator.mq5  |
//|                        © 2026 John Hanson                        |
//|        https://www.mql5.com/en/users/your_username               |
//+------------------------------------------------------------------+
// Contact: Telegram: @JohnHansonDev
// Custom EA / Indicator development available
//
// Lightweight and EA-friendly indicator for MetaTrader 5
// Shows bar index, price difference in points, and percentage change per bar.
// Designed for EA integration and fast analysis.
//
// For custom indicators or EA development, feel free to contact me.
//+------------------------------------------------------------------+
#property copyright "© 2026 John Hanson"
#property link "https://www.mql5.com/en/users/john999888"
#property version "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
//--- Plot 1: Invisible buffer (Bar index)
#property indicator_label1 "Bar Index"
#property indicator_type1 DRAW_NONE

#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrRed
#property indicator_width1 1
//--- Plot 2: Price difference in points
#property indicator_label2 "Price Diff (Pts)"
//--- Plot 3: Percentage change per bar
#property indicator_label3 "Change (%)"

double InvisibleBuffer[];
double DiffBuffer[];
double PercentBuffer[];
//+------------------------------------------------------------------+
//| Initialization                      |
//+------------------------------------------------------------------+
int OnInit()
  {
// Bind buffers
   SetIndexBuffer(0, InvisibleBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DiffBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, PercentBuffer, INDICATOR_DATA);
// Set global precision for DataWindow
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Main calculation                                                 |
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
   static datetime lastbar = 0;
// Recalculate only on new bar
   datetime currentBarTime = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(prev_calculated == 0 || lastbar != currentBarTime)
     {
      CalcValues(rates_total, open, close);
      lastbar = currentBarTime;
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate indicator values                                       |
//+------------------------------------------------------------------+
void CalcValues(int total, const double &open[], const double &close[])
  {
// Loop through all bars
   ArraySetAsSeries(InvisibleBuffer, true);
   ArraySetAsSeries(DiffBuffer, true);
   ArraySetAsSeries(PercentBuffer, true);

   double temp_open[], temp_close[];
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);

   for(int i = 0; i < total; i++)
     {
      InvisibleBuffer[i] = i;

      double diff = close[i] - open[i];
      DiffBuffer[i] = diff / _Point;

      // Calculate percentage change
      if(open[i] != 0)  // Prevent division by zero
         PercentBuffer[i] = (diff / open[i]) * 100.0;
      else
         PercentBuffer[i] = 0;
     }
  }
//+------------------------------------------------------------------+

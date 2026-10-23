//+------------------------------------------------------------------+
//|                                                     STC_Cross.mq5|
//|                                    Copyright 2026,   Ahmad Arju  |
//|                          https://www.mql5.com/en/users/arju0612_/|
//+------------------------------------------------------------------+
#property copyright "Ahmad Arju"
#property link      "https://www.mql5.com/en/users/arju0612_/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

// --- Plot 1: Buy ---
#property indicator_label1  "Buy Signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_width1  3

// --- Plot 2: Sell ---
#property indicator_label2  "Sell Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrCrimson
#property indicator_width2  3

// --- Inputs ---
input group "--- Stochastic Settings ---"
input int            InpStochKPeriod    = 8;          // K Period
input int            InpStochDPeriod    = 3;          // D Period
input int            InpStochSlowing    = 3;          // Slowing
input ENUM_MA_METHOD InpStochMAType     = MODE_SMA;   // MA Method
input ENUM_STO_PRICE InpStochPriceField = STO_LOWHIGH;// Price Field

input group "--- Reversal Boundaries ---"
input double         InpOversoldLevel   = 20.0;       // Oversold Level
input double         InpOverboughtLevel = 80.0;       // Overbought Level

input group "--- Alert Settings ---"
input bool           InpEnableAlert     = true;       // Enable Popup Alert

double   BuyBuffer[];
double   SellBuffer[];
int      stochHandle;
int      last_signal = 0; // 0 = Neutral, 1 = BUY, -1 = SELL
datetime last_alert_time = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, BuyBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellBuffer, INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   stochHandle = iStochastic(_Symbol, _Period, InpStochKPeriod, InpStochDPeriod, InpStochSlowing, InpStochMAType, InpStochPriceField);
   if(stochHandle == INVALID_HANDLE) return(INIT_FAILED);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(stochHandle);
}

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
   if(rates_total < 10) return(0);

   double k_values[], d_values[];
   ArraySetAsSeries(k_values, false);
   ArraySetAsSeries(d_values, false);

   int start = (prev_calculated > 2) ? prev_calculated - 1 : 2;
   int count = rates_total - start;

   if(count <= 0) return(rates_total);

   if(CopyBuffer(stochHandle, 0, 0, rates_total, k_values) <= 0) return(0);
   if(CopyBuffer(stochHandle, 1, 0, rates_total, d_values) <= 0) return(0);

   // Restore last signal state
   if(prev_calculated <= 2) {
      last_signal = 0;
   } else {
      for(int j = prev_calculated - 1; j >= 0; j--) {
         if(j < rates_total && BuyBuffer[j] != 0.0) { last_signal = 1; break; }
         if(j < rates_total && SellBuffer[j] != 0.0) { last_signal = -1; break; }
      }
   }

   int limit = rates_total - 1; // Process closed bars only
   int last_closed_bar = rates_total - 2; // Index of the most recently closed bar

   for(int i = start; i < limit && !IsStopped(); i++)
   {
      BuyBuffer[i] = 0.0;
      SellBuffer[i] = 0.0;

      double k  = k_values[i];
      double d  = d_values[i];
      double k1 = k_values[i-1];
      double d1 = d_values[i-1];

      // BUY: Oversold bounce + Cross Up + Anti-Streak
      bool zone_buy  = (k1 <= InpOversoldLevel || d1 <= InpOversoldLevel);
      bool cross_up  = (k > d && k1 <= d1);
      
      if(zone_buy && cross_up && last_signal != 1)
      {
         BuyBuffer[i] = low[i] - (10 * _Point);
         last_signal = 1;
         
         // Trigger alert only on the latest closed bar
         if(InpEnableAlert && i == last_closed_bar && time[i] != last_alert_time)
         {
            Alert(_Symbol, " [", EnumToString(_Period), "] - BUY Signal Confirmed");
            last_alert_time = time[i];
         }
         continue;
      }

      // SELL: Overbought bounce + Cross Down + Anti-Streak
      bool zone_sell  = (k1 >= InpOverboughtLevel || d1 >= InpOverboughtLevel);
      bool cross_down = (k < d && k1 >= d1);
      
      if(zone_sell && cross_down && last_signal != -1)
      {
         SellBuffer[i] = high[i] + (10 * _Point);
         last_signal = -1;
         
         // Trigger alert only on the latest closed bar
         if(InpEnableAlert && i == last_closed_bar && time[i] != last_alert_time)
         {
            Alert(_Symbol, " [", EnumToString(_Period), "] - SELL Signal Confirmed");
            last_alert_time = time[i];
         }
         continue;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
//|                     HalfLine4Exit123.mq5                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   7

// Plot Definitions
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_label1  "TMA Main"

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrNavajoWhite
#property indicator_width2  1
#property indicator_label2  "Upper Band"

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrPowderBlue
#property indicator_width3  1
#property indicator_label3  "Lower Band"

#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrWhite
#property indicator_width4  5
#property indicator_label4  "Sell Arrow"

#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrWhite
#property indicator_width5  5
#property indicator_label5  "Buy Arrow"

#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrYellow
#property indicator_width6  5
#property indicator_label6  "Sell Signal C"

#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrAqua
#property indicator_width7  5
#property indicator_label7  "Buy Signal C"

// Input Parameters
input int    HalfLength      = 55;
input double BandsDeviations = 2.8;
input bool   alertsOn        = true;

// Buffers
double tmBuffer[], upBuffer[], dnBuffer[];
double upArrow[],  dnArrow[],  upArrowC[], dnArrowC[];
double priceBuffer[], atrBuffer[];

//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
{
   // Bind Buffers - Data yang dipaparkan di carta
   SetIndexBuffer(0, tmBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, upBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, dnBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, upArrow,  INDICATOR_DATA);
   SetIndexBuffer(4, dnArrow,  INDICATOR_DATA);
   SetIndexBuffer(5, upArrowC, INDICATOR_DATA);
   SetIndexBuffer(6, dnArrowC, INDICATOR_DATA);
   
   // Bind Buffers - Data untuk pengiraan sahaja (RALAT DIPERBAIKI DI SINI)
   SetIndexBuffer(7, priceBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, atrBuffer,   INDICATOR_CALCULATIONS);

   // Arrow Codes (Wingdings)
   PlotIndexSetInteger(3, PLOT_ARROW, 234); // Arrow Down
   PlotIndexSetInteger(4, PLOT_ARROW, 233); // Arrow Up
   PlotIndexSetInteger(5, PLOT_ARROW, 74);  // Dot/Small Arrow
   PlotIndexSetInteger(6, PLOT_ARROW, 74);

   // Set Empty Value supaya arrow tidak muncul di harga 0
   for(int i=0; i<7; i++) PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);

   IndicatorSetString(INDICATOR_SHORTNAME, "ArrowSmile (Fixed)");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Main calculation function                                        |
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
   if(rates_total < HalfLength * 2) return(0);

   int limit = (prev_calculated > 0) ? prev_calculated - 1 : 0;

   // 1. Kira Price Buffer (Weighted Price: (H+L+C+C)/4)
   for(int i = limit; i < rates_total; i++)
   {
      priceBuffer[i] = (high[i] + low[i] + 2 * close[i]) / 4.0;
   }

   // 2. Kira TMA dan Bands
   for(int i = limit; i < rates_total; i++)
   {
      double sum  = 0;
      double sumw = 0;
      
      // Pengiraan Fast TMA
      for(int j = MathMax(0, i - HalfLength); j <= MathMin(rates_total - 1, i + HalfLength); j++)
      {
         double weight = HalfLength + 1 - MathAbs(j - i);
         sum  += weight * priceBuffer[j];
         sumw += weight;
      }
      
      if(sumw > 0) tmBuffer[i] = sum / sumw;

      // Kira ATR ringkas untuk Bands
      double range = high[i] - low[i];
      double atr = range; // Simple placeholder for ATR
      
      upBuffer[i] = tmBuffer[i] + (BandsDeviations * range);
      dnBuffer[i] = tmBuffer[i] - (BandsDeviations * range);
   }

   // 3. Logik Arrow & Isyarat (Mula dari 1 bar selepas limit)
   for(int i = MathMax(1, limit); i < rates_total; i++)
   {
      // Reset arrows
      upArrow[i]  = 0.0;
      dnArrow[i]  = 0.0;
      upArrowC[i] = 0.0;
      dnArrowC[i] = 0.0;

      // Syarat Sell (Harga tembus band atas + candle reversal)
      if(high[i-1] > upBuffer[i-1] && close[i-1] > open[i-1] && close[i] < open[i])
      {
         upArrow[i] = high[i] + (10 * _Point);
         if(i == rates_total - 1 && alertsOn && prev_calculated < rates_total) 
            Alert("Sell Signal on ", _Symbol);
      }

      // Syarat Buy (Harga tembus band bawah + candle reversal)
      if(low[i-1] < dnBuffer[i-1] && close[i-1] < open[i-1] && close[i] > open[i])
      {
         dnArrow[i] = low[i] - (10 * _Point);
         if(i == rates_total - 1 && alertsOn && prev_calculated < rates_total) 
            Alert("Buy Signal on ", _Symbol);
      }
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                              Nadaraya_Watson.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "3.10"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Upper Envelope
#property indicator_label1  "NW Upper Band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Lower Envelope
#property indicator_label2  "NW Lower Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSeaGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input group "=== Kernel Regression Settings ==="
input int    InpBandwidth    = 8;     // Smoothing Bandwidth (h)
input double InpMultiplier   = 2.5;   // Envelope Distance Multiplier
input int    InpLookback     = 100;   // Calculation Window

double ExtUpperBuffer[];
double ExtLowerBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtLowerBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Nadaraya-Watson Envelope");
   
   Print("Institutional Nadaraya-Watson Initialized.");
   return(INIT_SUCCEEDED);
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
   if(rates_total < InpLookback) return(0);

   int limit = (prev_calculated == 0) ? InpLookback : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double kernel_sum = 0.0;
      double weight_sum = 0.0;
      
      // Nadaraya-Watson Kernel Regression Calculation (Causal logic)
      for(int j = 0; j < InpLookback; j++)
        {
         // Gaussian Kernel function: K(u) = exp(-u^2 / 2)
         // u = distance / bandwidth
         double distance = (double)j;
         double weight = MathExp(-(distance * distance) / (2.0 * InpBandwidth * InpBandwidth));
         
         kernel_sum += close[i - j] * weight;
         weight_sum += weight;
        }
      
      double regression_mean = close[i];
      if(weight_sum > 0) regression_mean = kernel_sum / weight_sum;
      
      // Calculate Average True Range (ATR) approximation for the localized window
      double atr_sum = 0.0;
      for(int k = 0; k < InpBandwidth; k++)
        {
         atr_sum += (high[i - k] - low[i - k]);
        }
      double current_atr = atr_sum / InpBandwidth;
      
      // Project the non-linear predictive envelopes
      ExtUpperBuffer[i] = regression_mean + (current_atr * InpMultiplier);
      ExtLowerBuffer[i] = regression_mean - (current_atr * InpMultiplier);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                     Fractal_Regime_Detector.mq5  |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.28"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

//--- FDI Plot
#property indicator_label1  "Fractal Dimension"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue, clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Critical Thresholds
#property indicator_level1  1.5
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

input group "=== Chaos Theory Settings ==="
input int InpPeriod = 30; // Fractal Lookback Window

double ExtFdiBuffer[];
double ExtColorBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtFdiBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 3);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst FDI (" + IntegerToString(InpPeriod) + ")");
   
   Print("Institutional Fractal Dimension Index Initialized.");
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
   if(rates_total < InpPeriod) return(0);

   int limit = (prev_calculated == 0) ? InpPeriod : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double highest_price = high[i];
      double lowest_price = low[i];
      
      // 1. Find local extremes to normalize the Y-axis
      for(int j = 0; j < InpPeriod; j++)
        {
         if(high[i - j] > highest_price) highest_price = high[i - j];
         if(low[i - j] < lowest_price) lowest_price = low[i - j];
        }
        
      double price_range = highest_price - lowest_price;
      if(price_range == 0) price_range = _Point; // Prevent Division by zero
      
      // 2. Calculate normalized path length (L)
      double length = 0.0;
      for(int j = 0; j < InpPeriod - 1; j++)
        {
         double y_diff = (close[i - j] - close[i - j - 1]) / price_range;
         double x_diff = 1.0 / (double)InpPeriod;
         
         length += MathSqrt((x_diff * x_diff) + (y_diff * y_diff));
        }
        
      // 3. Calculate Fractal Dimension Index: D = 1 + (log(L) + log(2)) / log(2 * N)
      double fdi = 1.0 + (MathLog(length) + MathLog(2.0)) / MathLog(2.0 * InpPeriod);
      
      ExtFdiBuffer[i] = fdi;
      
      // 4. Color Code Regime (Below 1.5 = Blue/Trend, Above 1.5 = Red/Chaos)
      if(fdi < 1.5)
         ExtColorBuffer[i] = 0;
      else
         ExtColorBuffer[i] = 1;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
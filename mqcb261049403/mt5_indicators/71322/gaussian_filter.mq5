//+------------------------------------------------------------------+
//|                                              Gaussian_Filter.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

//--- Gaussian Filter Plot
#property indicator_label1  "Gaussian Filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSeaGreen, clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== Gaussian Settings ==="
input int    InpPeriod = 9;       // Gaussian Window (Period)
input double InpOffset = 0.85;    // Curve Offset (Responsiveness)
input double InpSigma  = 6.0;     // Sigma (Smoothness)

double ExtAlmaBuffer[];
double ExtColorBuffer[];
double ExtWeights[];
double ExtWeightSum;

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtAlmaBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Gaussian Filter (" + IntegerToString(InpPeriod) + ")");
   
   // Pre-calculate Gaussian Weights to save CPU cycles during OnCalculate
   ArrayResize(ExtWeights, InpPeriod);
   double m = InpOffset * (InpPeriod - 1);
   double s = InpPeriod / InpSigma;
   ExtWeightSum = 0.0;
   
   for(int i = 0; i < InpPeriod; i++)
     {
      ExtWeights[i] = MathExp(-(MathPow(i - m, 2)) / (2 * MathPow(s, 2)));
      ExtWeightSum += ExtWeights[i];
     }
   
   Print("Institutional Gaussian Filter Initialized.");
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

   int limit = (prev_calculated == 0) ? InpPeriod - 1 : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double alma = 0.0;
      
      // Apply Gaussian weights to the price series
      for(int j = 0; j < InpPeriod; j++)
        {
         alma += close[i - (InpPeriod - 1 - j)] * ExtWeights[j];
        }
        
      if(ExtWeightSum > 0)
         ExtAlmaBuffer[i] = alma / ExtWeightSum;
      else
         ExtAlmaBuffer[i] = close[i];

      // Slope Direction for Color Coding (0 = Green, 1 = Red)
      if(i > 0)
        {
         if(ExtAlmaBuffer[i] > ExtAlmaBuffer[i-1])
            ExtColorBuffer[i] = 0;
         else if(ExtAlmaBuffer[i] < ExtAlmaBuffer[i-1])
            ExtColorBuffer[i] = 1;
         else
            ExtColorBuffer[i] = ExtColorBuffer[i-1];
        }
      else
        {
         ExtColorBuffer[i] = 0;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
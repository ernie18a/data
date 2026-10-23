//+------------------------------------------------------------------+
//|                                           Fourier_DFT_Cycle.mq5  |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- DFT Wave Plot
#property indicator_label1  "Dominant Fourier Wave"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== Digital Signal Processing ==="
input int InpWindowSize = 64;   // DFT Rolling Window (Power of 2 recommended)
input int InpMinPeriod  = 4;    // Minimum Cycle Period Filter
input int InpMaxPeriod  = 32;   // Maximum Cycle Period Filter

double ExtDftWaveBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtDftWaveBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Fourier Transform (" + IntegerToString(InpWindowSize) + ")");
   
   Print("Institutional DFT Engine Initialized.");
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
   // Safety check for window size
   if(rates_total < InpWindowSize) return(0);

   int limit = (prev_calculated == 0) ? InpWindowSize : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double dominant_amplitude = 0.0;
      int dominant_k = 1;
      double dominant_phase = 0.0;
      
      // Calculate detrended mean for the current window
      double window_sum = 0;
      for(int n = 0; n < InpWindowSize; n++)
        {
         window_sum += close[i - n];
        }
      double window_mean = window_sum / InpWindowSize;

      // DFT Execution: Find the dominant frequency
      // k represents the frequency index. Period = WindowSize / k
      int k_start = InpWindowSize / InpMaxPeriod;
      if(k_start < 1) k_start = 1;
      int k_end = InpWindowSize / InpMinPeriod;
      
      for(int k = k_start; k <= k_end; k++)
        {
         double re = 0.0;
         double im = 0.0;
         
         for(int n = 0; n < InpWindowSize; n++)
           {
            double detrended_price = close[i - n] - window_mean;
            double angle = (2.0 * M_PI * k * n) / InpWindowSize;
            
            re += detrended_price * MathCos(angle);
            im -= detrended_price * MathSin(angle); // Negative for standard DFT definition
           }
           
         double amplitude = MathSqrt((re * re) + (im * im));
         
         if(amplitude > dominant_amplitude)
           {
            dominant_amplitude = amplitude;
            dominant_k = k;
            
            // Phase angle calculation: atan2(Im, Re)
            if(re != 0.0 || im != 0.0)
               dominant_phase = MathArctan2(im, re);
            else
               dominant_phase = 0.0;
           }
        }

      // Reconstruct only the dominant wave for the current bar (n=0)
      // Synthesized value = Mean + Amplitude * Cos(Phase)
      double normalized_amplitude = dominant_amplitude / (InpWindowSize / 2.0);
      ExtDftWaveBuffer[i] = window_mean + (normalized_amplitude * MathCos(dominant_phase));
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
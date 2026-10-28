//+------------------------------------------------------------------+
//|                                             Shannon_Entropy.mq5  |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

//--- Entropy Plot
#property indicator_label1  "Shannon Entropy (Noise Level)"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSlateBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== Information Theory Settings ==="
input int InpWindowSize = 60; // Data Sample Window
input int InpBins       = 10; // Number of Probability Bins

double ExtEntropyBuffer[];
double ExtBypassBuffer[]; // Prevent MQL5 EA misclassification

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtEntropyBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtBypassBuffer, INDICATOR_CALCULATIONS);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 4);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Shannon Entropy (" + IntegerToString(InpWindowSize) + ")");
   
   Print("Institutional Shannon Entropy Engine Initialized.");
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
   if(rates_total < InpWindowSize + 1) return(0);

   int limit = (prev_calculated == 0) ? InpWindowSize : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      double log_returns[];
      ArrayResize(log_returns, InpWindowSize);
      
      double max_ret = -999999.0;
      double min_ret = 999999.0;
      
      // 1. Calculate Log-Returns for the rolling window
      for(int j = 0; j < InpWindowSize; j++)
        {
         int idx = i - j;
         if(close[idx-1] > 0 && close[idx] > 0)
            log_returns[j] = MathLog(close[idx] / close[idx-1]);
         else
            log_returns[j] = 0.0;
            
         if(log_returns[j] > max_ret) max_ret = log_returns[j];
         if(log_returns[j] < min_ret) min_ret = log_returns[j];
        }
        
      // 2. Create Probability Distribution (Binning)
      int bin_counts[];
      ArrayResize(bin_counts, InpBins);
      ArrayInitialize(bin_counts, 0);
      
      double range = max_ret - min_ret;
      if(range == 0) range = 0.000001; // Prevent division by zero
      double bin_size = range / InpBins;
      
      for(int j = 0; j < InpWindowSize; j++)
        {
         int bin_index = (int)MathFloor((log_returns[j] - min_ret) / bin_size);
         if(bin_index >= InpBins) bin_index = InpBins - 1; // Catch edge case
         if(bin_index < 0) bin_index = 0;
         
         bin_counts[bin_index]++;
        }
        
      // 3. Calculate Shannon Entropy: H = -Sum( p * log2(p) )
      double entropy = 0.0;
      for(int b = 0; b < InpBins; b++)
        {
         double probability = (double)bin_counts[b] / (double)InpWindowSize;
         if(probability > 0)
           {
            entropy -= probability * (MathLog(probability) / MathLog(2.0)); // log base 2
           }
        }
        
      ExtEntropyBuffer[i] = entropy;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
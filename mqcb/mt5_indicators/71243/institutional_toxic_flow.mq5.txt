//+------------------------------------------------------------------+
//|                                     Institutional_Toxic_Flow.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

//--- Normal Volume Plot
#property indicator_label1  "Normal Flow"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDimGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Toxic Flow Spike Plot
#property indicator_label2  "Toxic Flow Spike"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

//--- Inputs
input group "=== Toxic Flow Math ==="
input int    InpBaselinePeriod = 20;   // Moving Baseline Period
input double InpDeviationMult  = 2.5;  // Standard Deviation Trigger

//--- Buffers
double ExtNormalBuffer[];
double ExtToxicBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtNormalBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtToxicBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   IndicatorSetString(INDICATOR_SHORTNAME, "Toxic Flow Meter (" + IntegerToString(InpBaselinePeriod) + ")");
   
   Print("Institutional Toxic Flow Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < InpBaselinePeriod) return(0);

   int limit = (prev_calculated == 0) ? InpBaselinePeriod : prev_calculated - 1;

   for(int i = limit; i < rates_total; i++)
     {
      // Reset buffers
      ExtNormalBuffer[i] = 0;
      ExtToxicBuffer[i]  = 0;
      
      double current_ticks = (double)tick_volume[i];
      
      // Calculate SMA of Tick Volume
      double sum = 0;
      for(int j = 0; j < InpBaselinePeriod; j++)
        {
         sum += (double)tick_volume[i - j];
        }
      double sma_ticks = sum / InpBaselinePeriod;
      
      // Calculate Standard Deviation
      double variance = 0;
      for(int j = 0; j < InpBaselinePeriod; j++)
        {
         variance += MathPow((double)tick_volume[i - j] - sma_ticks, 2);
        }
      double std_dev = MathSqrt(variance / InpBaselinePeriod);
      
      // Institutional Trigger Threshold
      double toxic_threshold = sma_ticks + (std_dev * InpDeviationMult);
      
      // Plotting Logic
      if(current_ticks > toxic_threshold)
        {
         ExtNormalBuffer[i] = sma_ticks;          // Show gray up to baseline
         ExtToxicBuffer[i]  = current_ticks;      // Show red spike for the anomaly
        }
      else
        {
         ExtNormalBuffer[i] = current_ticks;      // Normal gray volume
         ExtToxicBuffer[i]  = 0;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
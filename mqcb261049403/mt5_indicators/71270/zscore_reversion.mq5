//+------------------------------------------------------------------+
//|                                             ZScore_Reversion.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Z-Score Line
#property indicator_label1  "Z-Score"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- Overbought Histogram (Positive Extremes)
#property indicator_label2  "Overbought Extreme"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Oversold Histogram (Negative Extremes)
#property indicator_label3  "Oversold Extreme"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- Levels
#property indicator_level1  2.0
#property indicator_level2  0.0
#property indicator_level3 -2.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

input group "=== Quantitative Settings ==="
input int    InpPeriod       = 20;    // Statistical Baseline Period
input double InpExtremeLevel = 2.0;   // Standard Deviation Trigger (Z-Score)

double ExtZScoreBuffer[];
double ExtOverboughtBuffer[];
double ExtOversoldBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtZScoreBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtOverboughtBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtOversoldBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Z-Score (" + IntegerToString(InpPeriod) + ")");
   
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
      // 1. Calculate Simple Moving Average (The Mean)
      double sum = 0;
      for(int j = 0; j < InpPeriod; j++) sum += close[i - j];
      double sma = sum / InpPeriod;
      
      // 2. Calculate Standard Deviation
      double variance_sum = 0;
      for(int j = 0; j < InpPeriod; j++)
        {
         variance_sum += MathPow(close[i - j] - sma, 2);
        }
      double std_dev = MathSqrt(variance_sum / InpPeriod);
      
      // 3. Calculate Z-Score: Z = (Close - Mean) / StdDev
      double z_score = 0;
      if(std_dev > 0.00001) // Prevent division by zero
        {
         z_score = (close[i] - sma) / std_dev;
        }
        
      ExtZScoreBuffer[i] = z_score;
      
      // 4. Mathematical Extremes Detection (Histogram logic)
      ExtOverboughtBuffer[i] = 0.0;
      ExtOversoldBuffer[i]   = 0.0;
      
      if(z_score >= InpExtremeLevel)
        {
         ExtOverboughtBuffer[i] = z_score;
        }
      else if(z_score <= -InpExtremeLevel)
        {
         ExtOversoldBuffer[i] = z_score;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                     StatArb_Spread_ZScore.mq5    |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1

//--- Z-Score Plot
#property indicator_label1  "Spread Z-Score"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver, clrSeaGreen, clrIndianRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Critical Arbitrage Thresholds
#property indicator_level1  2.0
#property indicator_level2  0.0
#property indicator_level3 -2.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

input group "=== StatArb Pair Settings ==="
input string InpSymbol2 = "NZDUSD"; // Cointegrated Asset (e.g., NZDUSD for AUDUSD)
input int    InpPeriod  = 100;      // Cointegration Rolling Window
input double InpExtreme = 2.0;      // Arbitrage Trigger (Z-Score)

double ExtZScoreBuffer[];
double ExtColorBuffer[];
double ExtSpreadArray[]; // Internal calculation array

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtZScoreBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtSpreadArray, INDICATOR_CALCULATIONS);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "StatArb Z-Score (" + _Symbol + " vs " + InpSymbol2 + ")");
   
   Print("Institutional StatArb Spread Engine Initialized.");
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
      // 1. Synchronize Secondary Asset Data by exact time
      double close2[];
      if(CopyClose(InpSymbol2, _Period, time[i], 1, close2) <= 0)
        {
         // If data is missing for the secondary symbol, hold previous value
         if(i > 0) ExtSpreadArray[i] = ExtSpreadArray[i-1];
         continue;
        }
      
      // 2. Calculate Logarithmic Spread
      // Log(A) - Log(B) normalizes the spread across different asset prices
      double price1 = close[i];
      double price2 = close2[0];
      
      if(price1 > 0 && price2 > 0)
         ExtSpreadArray[i] = MathLog(price1) - MathLog(price2);
      else
         ExtSpreadArray[i] = 0;

      // 3. Calculate Rolling Mean & Standard Deviation of the Spread
      double sum = 0;
      for(int j = 0; j < InpPeriod; j++) sum += ExtSpreadArray[i - j];
      double mean = sum / InpPeriod;
      
      double variance_sum = 0;
      for(int j = 0; j < InpPeriod; j++)
        {
         variance_sum += MathPow(ExtSpreadArray[i - j] - mean, 2);
        }
      double std_dev = MathSqrt(variance_sum / InpPeriod);
      
      // 4. Calculate Spread Z-Score
      double z_score = 0;
      if(std_dev > 0.0000001)
         z_score = (ExtSpreadArray[i] - mean) / std_dev;
         
      ExtZScoreBuffer[i] = z_score;
      
      // 5. Arbitrage Color Coding
      if(z_score >= InpExtreme)
         ExtColorBuffer[i] = 2; // Red: Spread too wide (Sell 1, Buy 2)
      else if(z_score <= -InpExtreme)
         ExtColorBuffer[i] = 1; // Green: Spread too narrow (Buy 1, Sell 2)
      else
         ExtColorBuffer[i] = 0; // Silver: Neutral
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
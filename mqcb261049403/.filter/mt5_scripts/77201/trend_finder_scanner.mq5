//+------------------------------------------------------------------+
//|                                          Trend_Finder_Scanner.mq5|
//|                                     Copyright Ella & Sergei (v1) |
//+------------------------------------------------------------------+
#property copyright "Ella & Sergei"
#property version   "1.00"
#property script_show_inputs

//--- Input parameters
input ENUM_TIMEFRAMES InpTimeframe    = PERIOD_H1;  // Timeframe for trend search
input int             InpBarsCount    = 50;         // Number of bars for evaluation
input double          InpMinRSquared  = 0.70;       // Min. R-Squared (0.70+ for smooth trend)
input double          InpMinADX       = 25.0;       // Min. ADX (Trend strength)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   int totalSymbols = SymbolsTotal(true); // All symbols in Market Watch
   int foundCount = 0;

   PrintFormat("=== STARTING MARKET SCAN (%d symbols) ===", totalSymbols);
   PrintFormat("Criteria: TF=%s, Bars=%d, R2 >= %.2f, ADX >= %.1f", 
               EnumToString(InpTimeframe), InpBarsCount, InpMinRSquared, InpMinADX);

   for(int i = 0; i < totalSymbols; i++)
   {
      string symbol = SymbolName(i, true);
      
      // Copy close prices
      double close[];
      ArraySetAsSeries(close, true);
      if(CopyClose(symbol, InpTimeframe, 0, InpBarsCount, close) < InpBarsCount) continue;

      // 1. Calculate linear regression and R-squared coefficient (smoothness)
      double r2 = 0.0;
      double slope = 0.0;
      CalculateLinearRegression(close, InpBarsCount, r2, slope);

      // Skip if trend is too noisy (low R-squared)
      if(r2 < InpMinRSquared) continue;

      // 2. Calculate ADX (trend strength)
      int adxHandle = iADX(symbol, InpTimeframe, 14);
      if(adxHandle == INVALID_HANDLE) continue;
      
      double adxVal[1];
      if(CopyBuffer(adxHandle, 0, 0, 1, adxVal) <= 0)
      {
         IndicatorRelease(adxHandle);
         continue;
      }
      IndicatorRelease(adxHandle);

      if(adxVal[0] < InpMinADX) continue;

      // Determine direction
      string direction = (slope > 0) ? "UP ⬆️" : "DOWN ⬇️";

      // Print result if all filters pass
      foundCount++;
      PrintFormat("TREND FOUND #%d | Symbol: %-10s | Direction: %-10s | Quality (R²): %.2f | ADX: %.1f", 
                  foundCount, symbol, direction, r2, adxVal[0]);
   }

   PrintFormat("=== SCAN COMPLETED. Found trending symbols: %d ===", foundCount);
}

//+------------------------------------------------------------------+
//| Calculate Linear Regression and R-Squared                        |
//+------------------------------------------------------------------+
void CalculateLinearRegression(const double &y[], int N, double &r2, double &slope)
{
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;

   for(int i = 0; i < N; i++)
   {
      double x = i;
      double val = y[N - 1 - i]; // Oldest to newest
      
      sumX += x;
      sumY += val;
      sumXY += x * val;
      sumX2 += x * x;
      sumY2 += val * val;
   }

   double denom = (N * sumX2 - sumX * sumX);
   if(denom == 0) return;

   slope = (N * sumXY - sumX * sumY) / denom;
   
   double numR = (N * sumXY - sumX * sumY);
   double denR = (N * sumX2 - sumX * sumX) * (N * sumY2 - sumY * sumY);
   
   if(denR > 0)
      r2 = (numR * numR) / denR;
   else
      r2 = 0;
}
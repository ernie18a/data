//+------------------------------------------------------------------+
//|                                             GARCH_Forecaster.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

//--- GARCH Histogram Plot
#property indicator_label1  "GARCH(1,1) Volatility"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input group "=== GARCH(1,1) Econometric Parameters ==="
input double InpOmega = 0.000001; // Omega (Long-term Variance Weight)
input double InpAlpha = 0.09;     // Alpha (Recent Shock / Innovation Weight)
input double InpBeta  = 0.90;     // Beta (Volatility Persistence Weight)
input int    InpHistory = 1000;   // Calculation Initialization Window

double ExtGarchBuffer[];
double ExtLogReturns[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtGarchBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtLogReturns, INDICATOR_CALCULATIONS);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 6);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst GARCH(1,1) Forecaster");
   
   // Safety check for strictly stationary variance: Alpha + Beta must be < 1.0
   if(InpAlpha + InpBeta >= 1.0)
     {
      Print("WARNING: Alpha + Beta must be less than 1.0 for GARCH stationarity.");
     }
   
   Print("Institutional GARCH(1,1) Engine Initialized.");
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
   if(rates_total < 5) return(0);

   int limit = prev_calculated;
   if(limit == 0)
     {
      limit = 1; 
      // Initialize the first GARCH value with a simple baseline variance
      ExtGarchBuffer[0] = InpOmega / (1.0 - InpAlpha - InpBeta); 
      if(ExtGarchBuffer[0] < 0) ExtGarchBuffer[0] = 0.0001;
      ExtLogReturns[0] = 0.0;
     }
   else
     {
      limit = prev_calculated - 1;
     }

   for(int i = limit; i < rates_total; i++)
     {
      // 1. Calculate Logarithmic Return (Shock)
      if(close[i-1] > 0 && close[i] > 0)
         ExtLogReturns[i] = MathLog(close[i] / close[i-1]);
      else
         ExtLogReturns[i] = 0.0;

      // 2. GARCH(1,1) Variance Equation: 
      // Sigma^2_t = Omega + Alpha * (Return_{t-1})^2 + Beta * Sigma^2_{t-1}
      double prev_shock_sq = ExtLogReturns[i-1] * ExtLogReturns[i-1];
      double prev_variance = ExtGarchBuffer[i-1];
      
      double current_variance = InpOmega + (InpAlpha * prev_shock_sq) + (InpBeta * prev_variance);
      
      // Store the annualized volatility proxy (Square root of variance)
      if(current_variance > 0)
         ExtGarchBuffer[i] = MathSqrt(current_variance);
      else
         ExtGarchBuffer[i] = ExtGarchBuffer[i-1];
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                    Ornstein_Uhlenbeck_Matrix.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "4.20"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Equilibrium Line
#property indicator_label1  "OU Equilibrium (Mu)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGoldenrod
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Upper Diffusion Bound
#property indicator_label2  "OU Upper Boundary"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_DASH
#property indicator_width2  1

//--- Lower Diffusion Bound
#property indicator_label3  "OU Lower Boundary"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_DASH
#property indicator_width3  1

input group "=== Ornstein-Uhlenbeck Calibration ==="
input int    InpPeriod    = 50;  // Estimation Lookback Window
input double InpDeviations = 2.0; // Diffusion Band Multiplier

double ExtMuBuffer[];
double ExtUpperBuffer[];
double ExtLowerBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtMuBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowerBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst OU Matrix (" + IntegerToString(InpPeriod) + ")");
   
   Print("Institutional Ornstein-Uhlenbeck Matrix Engine V1.02 Initialized.");
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
   // TRAVA ABSOLUTA CONTRA GRÁFICO FANTASMA (0 ou 1 barra do validador MQL5)
   if(rates_total < InpPeriod + 2 || rates_total <= 0) return(rates_total);

   // Determinamos o início do cálculo sem limpar o array inteiro via ArrayInitialize
   int limit = (prev_calculated == 0) ? InpPeriod + 1 : prev_calculated - 1;
   
   if(limit >= rates_total) limit = rates_total - 1;
   if(limit < InpPeriod + 1) limit = InpPeriod + 1;

   // Preenchemos apenas as posições iniciais necessárias para evitar buracos gráficos
   if(prev_calculated == 0)
     {
      for(int k = 0; k <= limit; k++)
        {
         ExtMuBuffer[k] = close[k];
         ExtUpperBuffer[k] = close[k];
         ExtLowerBuffer[k] = close[k];
        }
     }

   // Loop de cálculo econométrico principal
   for(int i = limit; i < rates_total; i++)
     {
      double sumX  = 0.0;
      double sumY  = 0.0;
      double sumX2 = 0.0;
      double sumY2 = 0.0;
      double sumXY = 0.0;
      
      // OLS Regression de X_t contra X_{t-1}
      for(int j = 0; j < InpPeriod; j++)
        {
         int idx_current = i - j;
         int idx_previous = i - j - 1;
         
         if(idx_previous < 0 || idx_current >= rates_total) continue;
         
         double y = close[idx_current];
         double x = close[idx_previous];
         
         sumX  += x;
         sumY  += y;
         sumX2 += x * x;
         sumY2 += y * y;
         sumXY += x * y;
        }
        
      double denom = (InpPeriod * sumX2) - (sumX * sumX);
      if(denom == 0) denom = 0.000001; 
      
      double a = ((InpPeriod * sumXY) - (sumX * sumY)) / denom;
      double b = (sumY - (a * sumX)) / InpPeriod;
      
      double theta = 1.0 - a;
      if(MathAbs(theta) < 0.000001) theta = 0.000001;
      
      double mu = b / theta;
      
      // Cálculo do desvio estocástico residual (Brownian Motion Diffusion Factor)
      double residual_sum = 0.0;
      for(int j = 0; j < InpPeriod; j++)
        {
         int idx_current = i - j;
         int idx_previous = i - j - 1;
         if(idx_previous < 0) continue;
         
         double fit = (a * close[idx_previous]) + b;
         residual_sum += MathPow(close[idx_current] - fit, 2);
        }
      double sigma = MathSqrt(residual_sum / InpPeriod);
      
      // Armazenamento seguro nos buffers alocados pelo terminal
      ExtMuBuffer[i] = mu;
      ExtUpperBuffer[i] = mu + (sigma * InpDeviations);
      ExtLowerBuffer[i] = mu - (sigma * InpDeviations);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
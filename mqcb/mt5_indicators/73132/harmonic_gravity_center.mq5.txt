//+------------------------------------------------------------------+
//|                                      Harmonic_Gravity_Center.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "10.01"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Gravity Center Line
#property indicator_label1  "Harmonic Gravity Center"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Upper Deviation Band
#property indicator_label2  "Harmonic Upper Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepPink
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- Lower Deviation Band
#property indicator_label3  "Harmonic Lower Band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSpringGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

input group "=== Harmonic Volume Settings ==="
input int    InpPeriod      = 24;   // Lookback Calculation Window
input double InpMultiplier  = 2.0;  // Volumetric Deviation Multiplier

double ExtGravityCenterBuffer[];
double ExtUpperBandBuffer[];
double ExtLowerBandBuffer[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtGravityCenterBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtUpperBandBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ExtLowerBandBuffer, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Harmonic Gravity Center");
   
   Print("Institutional Volumetric Harmonic Engine Initialized.");
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
   // BARREIRA DE SEGURANÇA CRÍTICA PARA O VALIDADOR WEB:
   // Se o servidor de testes da MQL5 não fornecer histórico (0%), abortamos sem quebrar o array.
   if(rates_total < InpPeriod || rates_total <= 0) return(0);

   int limit = (prev_calculated == 0) ? InpPeriod : prev_calculated - 1;
   
   // Garante que o limit nunca aponte para fora do tamanho atual do array
   if(limit >= rates_total) limit = rates_total - 1;
   if(limit < InpPeriod) limit = InpPeriod;

   for(int i = limit; i < rates_total; i++)
     {
      double harmonic_volume_sum = 0.0;
      double reciprocal_price_volume_sum = 0.0;
      
      // Cálculo da Média Harmônica Ponderada por Volume
      for(int j = 0; j < InpPeriod; j++)
        {
         int current_index = i - j;
         
         // Proteção adicional de limite interno
         if(current_index < 0) continue;
         
         double current_price = close[current_index];
         double current_weight = (double)tick_volume[current_index];
         
         if(current_weight <= 0) current_weight = 1.0;
         if(current_price <= 0)  current_price = _Point;
         
         harmonic_volume_sum += current_weight;
         reciprocal_price_volume_sum += (current_weight / current_price);
        }
      
      double harmonic_gravity_center = close[i];
      if(reciprocal_price_volume_sum > 0)
        {
         harmonic_gravity_center = harmonic_volume_sum / reciprocal_price_volume_sum;
        }
        
      ExtGravityCenterBuffer[i] = harmonic_gravity_center;
      
      // Cálculo do Desvio Volumétrico Harmônico
      double variance_sum = 0.0;
      for(int j = 0; j < InpPeriod; j++)
        {
         int current_index = i - j;
         if(current_index < 0) continue;
         
         variance_sum += MathPow(close[current_index] - harmonic_gravity_center, 2);
        }
      double std_dev = MathSqrt(variance_sum / InpPeriod);
      
      // Projeção das Bandas
      ExtUpperBandBuffer[i] = harmonic_gravity_center + (std_dev * InpMultiplier);
      ExtLowerBandBuffer[i] = harmonic_gravity_center - (std_dev * InpMultiplier);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
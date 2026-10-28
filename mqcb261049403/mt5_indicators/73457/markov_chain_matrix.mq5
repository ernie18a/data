//+------------------------------------------------------------------+
//|                                          Markov_Chain_Matrix.mq5 |
//|                             Copyright 2026, Amanda V | KayruYuta |
//+------------------------------------------------------------------+
#property copyright "Amanda V | KayruYuta"
#property link      "https://forge.mql5.io"
#property version   "8.03"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_minimum 0.0
#property indicator_maximum 100.0

//--- Bullish Probability Plot
#property indicator_label1  "Prob Bullish (%)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Bearish Probability Plot
#property indicator_label2  "Prob Bearish (%)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrIndianRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- Midline
#property indicator_level1  50.0
#property indicator_levelcolor clrDimGray
#property indicator_levelstyle STYLE_DOT

input group "=== Stochastic Matrix Settings ==="
input int InpWindow = 200; // Transition Matrix Rolling Window

double ExtProbBullish[];
double ExtProbBearish[];

//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtProbBullish, INDICATOR_DATA);
   SetIndexBuffer(1, ExtProbBearish, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "Inst Markov Matrix (" + IntegerToString(InpWindow) + ")");
   
   Print("Institutional Markov Chain Engine V1.03 Initialized.");
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
   // BYPASS DA ENGINE DA MQL5: Se não tem barras suficientes, retorna rates_total (Ok) em vez de 0 (Crash)
   if(rates_total <= InpWindow + 2) return(rates_total);

   // Preenche o buffer inteiro com 50% no primeiro tick para evitar "Garbage Memory"
   if(prev_calculated == 0)
     {
      ArrayInitialize(ExtProbBullish, 50.0);
      ArrayInitialize(ExtProbBearish, 50.0);
     }

   int limit = (prev_calculated == 0) ? InpWindow + 1 : prev_calculated - 1;
   
   // Travas de Índice Críticas
   if(limit >= rates_total) limit = rates_total - 1;
   if(limit <= InpWindow) limit = InpWindow + 1;

   for(int i = limit; i < rates_total; i++)
     {
      int current_state = (close[i-1] >= open[i-1]) ? 1 : -1;
      
      int count_bull_to_bull = 0;
      int count_bull_to_bear = 0;
      int count_bear_to_bull = 0;
      int count_bear_to_bear = 0;
      
      for(int j = 1; j <= InpWindow; j++)
        {
         int past_idx = i - j;
         
         if(past_idx - 1 < 0 || past_idx >= rates_total) continue;
         
         int state_t0 = (close[past_idx-1] >= open[past_idx-1]) ? 1 : -1;
         int state_t1 = (close[past_idx] >= open[past_idx]) ? 1 : -1;
         
         if(state_t0 == 1 && state_t1 == 1) count_bull_to_bull++;
         if(state_t0 == 1 && state_t1 == -1) count_bull_to_bear++;
         if(state_t0 == -1 && state_t1 == 1) count_bear_to_bull++;
         if(state_t0 == -1 && state_t1 == -1) count_bear_to_bear++;
        }
        
      double prob_bull = 50.0;
      double prob_bear = 50.0;
      
      if(current_state == 1)
        {
         double total_from_bull = count_bull_to_bull + count_bull_to_bear;
         if(total_from_bull > 0)
           {
            prob_bull = (count_bull_to_bull / total_from_bull) * 100.0;
            prob_bear = (count_bull_to_bear / total_from_bull) * 100.0;
           }
        }
      else
        {
         double total_from_bear = count_bear_to_bull + count_bear_to_bear;
         if(total_from_bear > 0)
           {
            prob_bull = (count_bear_to_bull / total_from_bear) * 100.0;
            prob_bear = (count_bear_to_bear / total_from_bear) * 100.0;
           }
        }
        
      ExtProbBullish[i] = prob_bull;
      ExtProbBearish[i] = prob_bear;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
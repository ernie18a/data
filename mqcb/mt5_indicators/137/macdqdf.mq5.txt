//+------------------------------------------------------------------+
//|Based on code                                            MACD.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "2010, Vlad"
#property link        "http://www.becemal.ru/mql"
#property description "Moving Average Convergence/Divergence. Used QDF"
//#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_color1  RoyalBlue
#property indicator_color2  Chocolate
#property indicator_width1  2
#property indicator_width2  1
#property indicator_label1  "MACD"
#property indicator_label2  "Signal"
#property indicator_applied_price PRICE_CLOSE
input int                FastMA=12;               // Fast QDF Period
input int                SlowMA=36;               // Slow QDF Period
input int                SignalMA=9;              // Signal QDF Period
double                   MacdBuffer[];
double                   SignalBuffer[];
double                   FastMultiplier[];
double                   SlowMultiplier[];
double                   SignalMultiplier[];
//+------------------------------------------------------------------+
//| CalcMultiplier                                                   |
//+------------------------------------------------------------------+
void CalcMultiplier(double &M[],int P)
  {
   int i;
   double SM;
   ArrayResize(M,P,256);
   ArrayInitialize(M,0.0);
   for(i=0;i<P;i++) M[i]=MathExp(-2.0*M_PI*i*i/P/P);
   SM=0.0;
   for(i = 0;i < P;i++)  SM += M[i];
   for(i = 0;i < P;i++)  M[i] = M[i]/SM;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,MacdBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,SignalMA-1);
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD("+string(FastMA)+","+string(SlowMA)+","+string(SignalMA)+")");
   CalcMultiplier(FastMultiplier,FastMA);
   CalcMultiplier(SlowMultiplier,SlowMA);
   CalcMultiplier(SignalMultiplier,SignalMA);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total < SignalMA) return(0);
   if(rates_total < SlowMA)   return(0);
   int limit=prev_calculated-1;
   if(limit<SlowMA) limit=SlowMA;
   int i=limit;
   while(i<rates_total)
     {
      double SF = 0.0;
      for(int j = 0;j < FastMA;j++)  SF += price[i-j]*FastMultiplier[j];
      double SS = 0.0;
      for(int j = 0;j < SlowMA;j++)  SS += price[i-j]*SlowMultiplier[j];
      MacdBuffer[i]=SF-SS;
      i++;
     }
   limit=prev_calculated-1;
   if(limit<SignalMA) limit=SignalMA;
   i=limit;
   while(i<rates_total)
     {
      double SS = 0.0;
      for(int j = 0;j < SignalMA;j++)  SS += MacdBuffer[i-j]*SignalMultiplier[j];
      SignalBuffer[i]=SS;
      i++;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

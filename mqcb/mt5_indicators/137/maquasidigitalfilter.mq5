//+------------------------------------------------------------------+
//| Based on code                                           DEMA.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "2010, Vlad"
#property link        "http://www.becemal.ru/mql"
#property description "Moving Average - Quasi-Digital Filter"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Gold
#property indicator_width1  1
#property indicator_label1  "QDF"
#property indicator_applied_price PRICE_CLOSE
input int               PeriodMA = 31;               // Period
input int               Shift = 0;                   // Indicator's Shift
double                  QDFBuffer[];
double                  Multiplier[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   int i;
//--- indicator buffers mapping
   SetIndexBuffer(0,QDFBuffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2*PeriodMA-2);
//--- sets indicator shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- name for indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"QDF("+string(PeriodMA)+")");
//--- name for index label
   PlotIndexSetString(0,PLOT_LABEL,"QDF("+string(PeriodMA)+")");
   ArrayResize(Multiplier,PeriodMA,256);
   ArrayInitialize(Multiplier,0.0);
   for(i=0;i<PeriodMA;i++) Multiplier[i]=MathExp(-2.0*M_PI*i*i/PeriodMA/PeriodMA);
   double SM=0.0;
   for(i = 0;i < PeriodMA;i++)  SM += Multiplier[i];
   for(i = 0;i < PeriodMA;i++)  Multiplier[i] = Multiplier[i]/SM;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if(rates_total<PeriodMA) return(0);
   int limit=prev_calculated-1;
   if(limit<PeriodMA) limit=PeriodMA;
   int i=limit;
   while(i<rates_total)
     {
      double S=0.0;
      for(int j=0;j<PeriodMA;j++) S+=price[i-j]*Multiplier[j];
      QDFBuffer[i]=S;
      i++;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

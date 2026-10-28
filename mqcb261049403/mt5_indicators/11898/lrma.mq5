//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                                            Copyright 2014, Vinin |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Vinin"
#property link      "http:\\vinin.ucoz.ru"
#property version   "1.00"
#property description "Линейная регрессия является статистическим инструментом, используемым для"
#property description "прогнозирования будущих цен исходя из прошлых данных. Используется метод "
#property description "наименьших квадратов для построения «наиболее подходящей» прямой линии "
#property description "через ряд точек ценовых значений. В качестве входных параметров используется "
#property description "количество расчетных баров (свечей). Данный индикатор хорошо использовать для автоматической торговли"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot LRMA
#property indicator_label1  "LRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      LRMAPeriod=14; // Period LRMA
//--- indicator buffers
double         LRMABuffer[];
//#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LRMABuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

   ArraySetAsSeries(LRMABuffer,true);
//---
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
//---
//   ArraySetAsSeries(LRMABuffer,true);
   ArraySetAsSeries(close,true);

   if(rates_total<=LRMAPeriod) return(0);
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      ArrayInitialize(LRMABuffer,0.0);
      limit=rates_total-LRMAPeriod-1;
     }

   for(int pos=limit;pos>=0;pos--)
     {
      LRMABuffer[pos]=LRMA(pos,LRMAPeriod,close);
      //      Print("Bar(",pos,")=", LRMABuffer[pos]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+\\
// Calculate LRMA
//+------------------------------------------------------------------+\\
double LRMA(const int pos,const int period,const double  &price[])
  {
   double Res=0;
   double tmpS=0,tmpW=0,wsum=0;;
   for(int i=0;i<period;i++)
     {
      tmpS+=price[pos+i];
      tmpW+=price[pos+i]*(period-i);
      wsum+=(period-i);
     }
   tmpS/=period;
   tmpW/=wsum;
   Res=3.0*tmpW-2.0*tmpS;

   return(Res);
  }
//+------------------------------------------------------------------+

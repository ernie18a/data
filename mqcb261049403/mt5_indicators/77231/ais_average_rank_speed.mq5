//+------------------------------------------------------------------+
//|                                       AIS Average rank speed.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1  DRAW_LINE
#property indicator_label1 "ARS"
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

input ushort iPeriod=24;//Indicator period
int period=3,h;
double buffer[],price[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buffer,INDICATOR_DATA);
   ArraySetAsSeries(buffer,true);

   period=MathMax(period,iPeriod);
   h=period/2;

   ArrayResize(price,period);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int32_t rates_total,
                const int32_t prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int32_t &spread[])
  {
//---
   if(rates_total>prev_calculated)
     {
      ArraySetAsSeries(open,true);
      int bars=prev_calculated>0?rates_total-prev_calculated-1:rates_total-period-1;

      for(int i=bars;i>-1;i--)
        {
         //берем цены для анализа
         for(int j=0;j<period;j++)
            price[j]=open[i+j];

         //сортируем цены и расчитываем среднюю винсоризованную скорость
         ArraySort(price);
         double sum=0;
         for(int j=0;j<h;j++)
            sum=sum+(price[period-j-1]-price[j])/(period-j);

         //нормируем скорость, чтобы была возможность сравнивать два индикатора с разными периодами
         sum=sum/h;

         buffer[i]=sum;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

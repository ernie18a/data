//+------------------------------------------------------------------+
//|                                           Since_Last_Fractal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Since last fractal indicator."
#property description "The indicator shows how many bars back was a fractal."
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Num after Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Num after Down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Since last fractal");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-5)
         BufferUP[i]=BufferDN[i]=0;
      else
        {
         bool UpFr=(high[i+2]>high[i+4] && high[i+2]>high[i+3] && high[i+2]>high[i+1] && high[i+2]>high[i] ? true : false);
         bool DnFr=(low[i+2]<low[i+4] && low[i+2]<low[i+3] && low[i+2]<low[i+1] && low[i+2]<low[i] ? true : false);

         if(UpFr)
           {
            BufferUP[i+2]=0;
            BufferUP[i+1]=BufferUP[i+2]+1;
            BufferUP[i]=BufferUP[i+1]+1;
           }
         else
           {
            BufferUP[i+2]=BufferUP[i+3]+1;
            BufferUP[i+1]=BufferUP[i+2]+1;
            BufferUP[i]=BufferUP[i+1]+1;
           }

         if(DnFr)
           {
            BufferDN[i+2]=0;
            BufferDN[i+1]=BufferDN[i+2]+1;
            BufferDN[i]=BufferDN[i+1]+1;
           }
         else
           {
            BufferDN[i+2]=BufferDN[i+3]+1;
            BufferDN[i+1]=BufferDN[i+2]+1;
            BufferDN[i]=BufferDN[i+1]+1;
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

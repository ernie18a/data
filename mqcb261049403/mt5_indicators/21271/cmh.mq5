//+------------------------------------------------------------------+
//|                                                          CMH.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Clear Method Histogram indicator"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot CMH
#property indicator_label1  "CMH"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrAqua,clrFuchsia
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffers
double         BufferCMH[];
double         BufferColors[];
double         BufferHH[];
double         BufferLL[];
double         BufferLH[];
double         BufferHL[];
double         BufferSwing[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCMH,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferHH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferHL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferSwing,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Clear Method Histogram");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCMH,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferHH,true);
   ArraySetAsSeries(BufferLL,true);
   ArraySetAsSeries(BufferLH,true);
   ArraySetAsSeries(BufferHL,true);
   ArraySetAsSeries(BufferSwing,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCMH,EMPTY_VALUE);
      ArrayInitialize(BufferHH,0);
      ArrayInitialize(BufferLL,0);
      ArrayInitialize(BufferLH,0);
      ArrayInitialize(BufferHL,0);
      ArrayInitialize(BufferSwing,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferSwing[i]=0;
         BufferHH[i]=high[i];
         BufferLH[i]=high[i];
         BufferHL[i]=low[i];
         BufferLL[i]=low[i];
        }
      else
        {
         BufferSwing[i]=BufferSwing[i+1];
         BufferHH[i]=fmax(high[i],BufferHH[i+1]);
         BufferLH[i]=fmin(high[i],BufferLH[i+1]);
         BufferHL[i]=fmax(low[i],BufferHL[i+1]);
         BufferLL[i]=fmin(low[i],BufferLL[i+1]);
        }

      if(BufferSwing[i]>0)
        {
         if(high[i]<BufferHL[i])
           {
            BufferSwing[i]=-1;
            BufferLL[i]=low[i];
            BufferLH[i]=high[i];
           }
        }
      else
        {
         if(BufferSwing[i]<0)
           {
            if(low[i]>BufferLH[i])
              {
               BufferSwing[i]=1;
               BufferHH[i]=high[i];
               BufferHL[i]=low[i];
              }
           }
         else
           {
            if(high[i]<BufferHL[i])
              {
               BufferSwing[i]=-1;
               BufferLL[i]=low[i];
               BufferLH[i]=high[i];
              }
            else
              {
               if(low[i]>BufferHL[i])
                 {
                  BufferSwing[i]=1;
                  BufferHH[i]=high[i];
                  BufferHL[i]=low[i];
                 }
              }
           }
        }

      if(BufferSwing[i]>0)
        {
         BufferCMH[i]=(high[i]-BufferHL[i])/Point();
         BufferColors[i]=0;
        }
      else if(BufferSwing[i]<0)
        {
         BufferCMH[i]=(BufferLH[i]-low[i])/Point();
         BufferColors[i]=1;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

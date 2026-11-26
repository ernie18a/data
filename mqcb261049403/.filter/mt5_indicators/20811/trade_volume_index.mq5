//+------------------------------------------------------------------+
//|                                           Trade_Volume_Index.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trade Volume Index indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot TVI
#property indicator_label1  "TVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRoyalBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpMinTickValue=10;   // Minimum tick value
//--- indicator buffers
double         BufferTVI[];
double         BufferDirection[];
double         BufferExtremePrice[];
//--- global variables
int            min_tick_value;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   min_tick_value=int(InpMinTickValue<1 ? 1 : InpMinTickValue);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTVI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDirection,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferExtremePrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trade Volume Index ("+(string)min_tick_value+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTVI,true);
   ArraySetAsSeries(BufferDirection,true);
   ArraySetAsSeries(BufferExtremePrice,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferTVI,EMPTY_VALUE);
      ArrayInitialize(BufferDirection,0);
      ArrayInitialize(BufferExtremePrice,0);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(i==rates_total-2)
        {
         BufferDirection[i]=0;
         BufferExtremePrice[i]=close[i];
         BufferTVI[i]=0;
        }
      else
        {
         double change=(close[i]-BufferExtremePrice[i+1])/Point();
         if(change>min_tick_value)
           {
            BufferDirection[i]=1;
            BufferExtremePrice[i]=close[i];
           }
         else
           {
            if(change<-min_tick_value)
              {
               BufferDirection[i]=-1;
               BufferExtremePrice[i]=close[i];
              }
            else
              {
               BufferDirection[i]=BufferDirection[i+1];
               BufferExtremePrice[i]=BufferExtremePrice[i+1];
              }
           }

         if(BufferDirection[i]>0)
            BufferTVI[i]=BufferTVI[i+1]+tick_volume[i];
         else
           {
            if(BufferDirection[i]<0)
               BufferTVI[i]=BufferTVI[i+1]-tick_volume[i];
            else
               BufferTVI[i]=BufferTVI[i+1];
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

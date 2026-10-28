//+------------------------------------------------------------------+
//|                                                          CMC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Clear Method Candles indicator"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   1
//--- plot CMC
#property indicator_label1  "CMC Open;CMC High;CMC Low;CMC Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDodgerBlue,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
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
   SetIndexBuffer(0,BufferOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   
   SetIndexBuffer(5,BufferHH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferLL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferHL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferSwing,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Clear Method Candles");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOpen,EMPTY_VALUE);
      ArrayInitialize(BufferHigh,EMPTY_VALUE);
      ArrayInitialize(BufferLow,EMPTY_VALUE);
      ArrayInitialize(BufferClose,EMPTY_VALUE);
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

      BufferOpen[i]=open[i];
      BufferHigh[i]=high[i];
      BufferLow[i]=low[i];
      BufferClose[i]=close[i];
      
      if(BufferSwing[i]>0)
        {
         //BufferCMH[i]=(high[i]-BufferHL[i])/Point();
         BufferColors[i]=0;
        }
      else if(BufferSwing[i]<0)
        {
         //BufferCMH[i]=(BufferLH[i]-low[i])/Point();
         BufferColors[i]=1;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

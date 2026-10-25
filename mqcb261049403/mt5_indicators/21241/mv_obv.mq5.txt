//+------------------------------------------------------------------+
//|                                                       MV_OBV.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MultiVote OBV Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot MVOBV
#property indicator_label1  "MVOBV"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         BufferMVOBV[];
double         BufferColors[];
double         BufferUP[];
double         BufferDN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMVOBV,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferDN,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiVote OBV");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMVOBV,true);
   ArraySetAsSeries(BufferColors,true);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferMVOBV,EMPTY_VALUE);
      ArrayInitialize(BufferUP,0);
      ArrayInitialize(BufferDN,0);
     }
   
//--- Расчёт индикатора
   double hv=0,lv=0,cv=0,tv=0,obv=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      hv=(high[i]>high[i+1] ? 1 : high[i]<high[i+1] ? -1 : 0);
      lv=(low[i]>low[i+1] ? 1 : low[i]<low[i+1] ? -1 : 0);
      cv=(close[i]>close[i+1] ? 1 : close[i]<close[i+1] ? -1 : 0);
      tv=hv+lv+cv;

      BufferMVOBV[i]=(BufferUP[i+1]+BufferDN[i+1])+tick_volume[i]*tv;
      if(BufferMVOBV[i]>0)
        {
         BufferUP[i]=BufferMVOBV[i];
         BufferDN[i]=0;
         BufferColors[i]=0;
        }
      else
        {
         if(BufferMVOBV[i]<0)
           {
            BufferDN[i]=BufferMVOBV[i];
            BufferUP[i]=0;
            BufferColors[i]=1;
           }
         else
            BufferColors[i]=2;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                              SAR_Oscillator2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "SAR Oscillator 2"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot OscSAR
#property indicator_label1  "SAR Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDeepSkyBlue,clrPowderBlue,clrMoccasin,clrOrange,clrGainsboro
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input double   InpStep  =  0.02; // SAR step
input double   InpMax   =  0.2;  // SAR maximum
//--- indicator buffers
double         BufferOscSAR[];
double         BufferColors[];
double         BufferSAR[];
//--- global variables
double         step;
double         max;
int            handle_sar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   step=(InpStep<0.0001 ? 0.0001 : InpStep);
   max=(InpMax<0.0001 ? 0.0001 : InpMax);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOscSAR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferSAR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SAR Oscillator 2 "+DoubleToString(step,2)+","+DoubleToString(max,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOscSAR,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferSAR,true);
//--- create SAR handle
   ResetLastError();
   handle_sar=iSAR(NULL,PERIOD_CURRENT,step,max);
   if(handle_sar==INVALID_HANDLE)
     {
      Print("The iSAR(",DoubleToString(step,2),","+DoubleToString(max,2),") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOscSAR,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferSAR,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_sar,0,0,count,BufferSAR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferOscSAR[i]=BufferSAR[i]-close[i];
      BufferColors[i]=
        (
         BufferOscSAR[i]<0 ? (BufferOscSAR[i]>BufferOscSAR[i+1] ? 1 : BufferOscSAR[i]<BufferOscSAR[i+1] ? 0 : 4) : 
         BufferOscSAR[i]>0 ? (BufferOscSAR[i]>BufferOscSAR[i+1] ? 3 : BufferOscSAR[i]<BufferOscSAR[i+1] ? 2 : 4) :
         4
        );
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

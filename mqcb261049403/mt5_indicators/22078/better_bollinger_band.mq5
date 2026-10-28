//+------------------------------------------------------------------+
//|                                        Better_Bollinger_Band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Better Bollinger Band indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
//--- plot Top
#property indicator_label1  "DETop"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Central
#property indicator_label2  "DECentral"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "DEBottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod      =  20;   // Period
input double   InpDeviation   =  2.0;  // Deviation
//--- indicator buffers
double         BufferTop[];
double         BufferCentral[];
double         BufferBottom[];
double         BufferMT[];
double         BufferUT[];
double         BufferMT2[];
double         BufferUT2[];
//--- global variables
double         deviation;
double         alpha;
int            period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   deviation=InpDeviation;
   alpha=2.0/(1.0+period);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCentral,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMT,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferUT,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMT2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferUT2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Better BB("+(string)period+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferCentral,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferMT,true);
   ArraySetAsSeries(BufferUT,true);
   ArraySetAsSeries(BufferMT2,true);
   ArraySetAsSeries(BufferUT2,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferCentral,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferMT,0);
      ArrayInitialize(BufferUT,0);
      ArrayInitialize(BufferMT2,0);
      ArrayInitialize(BufferUT2,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double median=(high[i]+low[i])/2.;
      BufferMT[i]=alpha*median+(1.0-alpha)*BufferMT[i+1];
      BufferUT[i]=alpha*BufferMT[i]+(1.0-alpha)*BufferUT[i+1];

      BufferCentral[i]=((2.0-alpha)*BufferMT[i]-BufferUT[i])/(1.0-alpha);

      BufferMT2[i]=alpha*fabs(median-BufferCentral[i])+(1.0-alpha)*BufferMT2[i+1];
      BufferUT2[i]=alpha*BufferMT2[i]+(1.0-alpha)*BufferUT2[i+1];

      double dt2=((2.0-alpha)*BufferMT2[i]-BufferUT2[i])/(1.0-alpha);

      BufferTop[i]=BufferCentral[i]+deviation*dt2;
      BufferBottom[i]=BufferCentral[i]-deviation*dt2;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                      Sylvain_Vervoort_rainbow_moving_average.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Sylvain Vervoort rainbow moving average"
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   1
//--- plot SVRMA
#property indicator_label1  "SVRMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpPeriod   =  2; // Period
//--- indicator buffers
double         BufferSVRMA[];
double         BufferLWMA1[];
double         BufferLWMA2[];
double         BufferLWMA3[];
double         BufferLWMA4[];
double         BufferLWMA5[];
double         BufferLWMA6[];
double         BufferLWMA7[];
double         BufferLWMA8[];
double         BufferLWMA9[];
double         BufferLWMA10[];
//--- global variables
int            period_ma;
int            period_max;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<1 ? 1 : InpPeriod);
   period_max=period_ma+period_ma*9;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSVRMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLWMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferLWMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferLWMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferLWMA4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferLWMA5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferLWMA6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferLWMA7,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferLWMA8,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferLWMA9,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferLWMA10,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Sylvain Vervoort rainbow MA ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSVRMA,true);
   ArraySetAsSeries(BufferLWMA1,true);
   ArraySetAsSeries(BufferLWMA2,true);
   ArraySetAsSeries(BufferLWMA3,true);
   ArraySetAsSeries(BufferLWMA4,true);
   ArraySetAsSeries(BufferLWMA5,true);
   ArraySetAsSeries(BufferLWMA6,true);
   ArraySetAsSeries(BufferLWMA7,true);
   ArraySetAsSeries(BufferLWMA8,true);
   ArraySetAsSeries(BufferLWMA9,true);
   ArraySetAsSeries(BufferLWMA10,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_SMA,PRICE_CLOSE);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferSVRMA,EMPTY_VALUE);
      ArrayInitialize(BufferLWMA1,0);
      ArrayInitialize(BufferLWMA2,0);
      ArrayInitialize(BufferLWMA3,0);
      ArrayInitialize(BufferLWMA4,0);
      ArrayInitialize(BufferLWMA5,0);
      ArrayInitialize(BufferLWMA6,0);
      ArrayInitialize(BufferLWMA7,0);
      ArrayInitialize(BufferLWMA8,0);
      ArrayInitialize(BufferLWMA9,0);
      ArrayInitialize(BufferLWMA10,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferLWMA1);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferLWMA2[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA1);
      BufferLWMA3[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA2);
      BufferLWMA4[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA3);
      BufferLWMA5[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA4);
      BufferLWMA6[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA5);
      BufferLWMA7[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA6);
      BufferLWMA8[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA7);
      BufferLWMA9[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA8);
      BufferLWMA10[i]=LinearWeightedMA(rates_total,period_ma,i,BufferLWMA9);
      double value=0;
      value+=5*BufferLWMA1[i];
      value+=4*BufferLWMA2[i];
      value+=3*BufferLWMA3[i];
      value+=2*BufferLWMA4[i];
      value+=BufferLWMA5[i];
      value+=BufferLWMA6[i];
      value+=BufferLWMA7[i];
      value+=BufferLWMA8[i];
      value+=BufferLWMA9[i];
      value+=BufferLWMA10[i];
      BufferSVRMA[i]=value/20.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
double LinearWeightedMA(const int rates_total,const int period,const int index,const double &price[])
  {
//---
   double result=0.0,count=0,total=0,k=0;
   int    wsum=0;
//--- check position
   if(period<1 || index>rates_total-period-1)
      return 0;
//--- calculate value
   for(int j=index+period-1; j>=index; j--)
     {
      count++;
      k+=count;
      total+=price[j]*count;
     }
   result=total/k;
//---
   return(result);
  }
//+------------------------------------------------------------------+

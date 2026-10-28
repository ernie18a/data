//+------------------------------------------------------------------+
//|                                                          HVR.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Historical Volatility Ratio indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot HVR
#property indicator_label1  "HVR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSienna
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpPeriod1        =  6;             // First deviation period
input uint                 InpPeriod2        =  100;           // Second deviation period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpThreshold      =  0.5;           // Threshold
//--- indicator buffers
double         BufferHVR[];
double         BufferMA[];
double         BufferST[];
//--- global variables
int            period_1;
int            period_2;
int            handle_ma;
int            period_max;
double         threshold;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_max=fmax(period_1,period_2);
   threshold=(InpThreshold<0.01 ? 0.01 : InpThreshold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHVR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferST,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Historical Volatility Ratio ("+(string)period_1+","+(string)period_2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,threshold);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHVR,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferST,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferHVR,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferST,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferST[i]=log(BufferMA[i]/BufferMA[i+1]);

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Dev2=StdDev(BufferST,period_2,i);
      BufferHVR[i]=(StdDev(BufferST,period_1,i)/(Dev2!=0 ? Dev2 : 1.0));
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| StdDev                                                           |
//+------------------------------------------------------------------+
double StdDev(double &array[],int period,int index)
  {
   double avg=0;
   for(int i=0; i<period; i++)
      avg+=array[index+i];
   avg=avg/period;
   double SD=0;
   for(int i=0; i<period; i++)
      SD+=(avg-array[index+i])*(avg-array[index+i]);
   SD=sqrt(SD/period);
   return SD;
  }
//+------------------------------------------------------------------+

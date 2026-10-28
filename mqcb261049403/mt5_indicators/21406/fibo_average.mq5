//+------------------------------------------------------------------+
//|                                                 Fibo_Average.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Fibo average indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Fibo
#property indicator_label1  "Fibo MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot FiMA
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  55;            // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // FiboMA applied price
input uint                 InpCountFibo      =  11;            // Fibo count
//--- indicator buffers
double         BufferFibo[];
double         BufferFiMA[];
double         BufferMA[];
//--- includes
#include <MovingAverages.mqh>
#include <Arrays\ArrayInt.mqh>
//--- global variables
int            period_ma;
int            weight_sum;
int            max_fibo_value;
int            handle_ma;
CArrayInt      array_fibo_numbers;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   int count_fibo=int(InpCountFibo<2 ? 2 : InpCountFibo);
   array_fibo_numbers.Sort();
   array_fibo_numbers.Clear();
   array_fibo_numbers.Insert(0,0);
   array_fibo_numbers.Insert(1,1);
   if(count_fibo>2)
     {
      for(int i=2; i<=count_fibo-1; i++)
        {
         int value=array_fibo_numbers.At(i-2)+array_fibo_numbers.At(i-1);
         array_fibo_numbers.Insert(value,i);
        }
     }
   max_fibo_value=array_fibo_numbers.At(array_fibo_numbers.Total()-1);
   int total=array_fibo_numbers.Total();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFibo,INDICATOR_DATA);
   SetIndexBuffer(1,BufferFiMA,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fibo averages (period: "+(string)period_ma+", levels: "+(string)array_fibo_numbers.Total()+" --> bars: "+(string)max_fibo_value+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,max_fibo_value);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,max_fibo_value+period_ma-1);
   PlotIndexSetString(0,PLOT_LABEL,"Fibo MA("+(string)array_fibo_numbers.Total()+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA("+(string)period_ma+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFibo,true);
   ArraySetAsSeries(BufferFiMA,true);
   ArraySetAsSeries(BufferMA,true);
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
   if(rates_total<fmax(max_fibo_value,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max_fibo_value-1;
      ArrayInitialize(BufferFibo,0);
      ArrayInitialize(BufferFiMA,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      int total=array_fibo_numbers.Total()-1;
      for(int j=1; j<=total; j++)
         sum+=BufferMA[i+array_fibo_numbers.At(j)];
      BufferFibo[i]=sum/total;
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferFibo,BufferFiMA)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferFibo,BufferFiMA)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferFibo,BufferFiMA,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma,BufferFibo,BufferFiMA)==0) return 0;                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

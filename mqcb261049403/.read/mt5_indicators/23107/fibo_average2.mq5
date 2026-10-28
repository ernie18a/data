//+------------------------------------------------------------------+
//|                                                Fibo_Average2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Average given by the Fibonacci Sequence"
#property description "And a MA based on that Line"
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
//--- enums
enum ENUM_MA_MODE
  {
   METHOD_SMA,          // Simple
   METHOD_EMA,          // Exponential
   METHOD_SMMA,         // Smoothed
   METHOD_LWMA,         // Linear-Weighted
   METHOD_WILDER_EMA,   // Wilder Exponential
   METHOD_SINE_WMA,     // Sine-Weighted
   METHOD_TRI_MA,       // Triangular
   METHOD_LSMA,         // Least Square
   METHOD_HMA,          // Hull MA by Alan Hull
   METHOD_ZL_EMA,       // Zero-Lag Exponential
   METHOD_ITREND_MA,    // Instantaneous Trendline by J.Ehlers
   METHOD_MOVING_MEDIAN,// Moving Median
   METHOD_GEO_MEAN,     // Geometric Mean
   METHOD_REMA,         // Regularized EMA by Chris Satchwell
   METHOD_ILRS,         // Integral of Linear Regression Slope
   METHOD_IE_2,         // Combination of LSMA and ILRS
   METHOD_TRI_MA_GEN,   // Triangular MA generalized by J.Ehlers
   METHOD_VWMA          // Volume-Weighted
  };
//--- input parameters
input uint                 InpPeriod         =  55;            // MA period
input ENUM_MA_MODE         InpMethod         =  METHOD_SMA;    // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // FiboMA applied price
input uint                 InpCountFibo      =  11;            // Fibo count
//--- indicator buffers
double         BufferFibo[];
double         BufferFiMA[];
double         BufferPrice[];
//--- includes
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
   SetIndexBuffer(2,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Fibo averages2 (period: "+(string)period_ma+", levels: "+(string)array_fibo_numbers.Total()+" --> bars: "+(string)max_fibo_value+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,max_fibo_value);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,max_fibo_value+period_ma-1);
   PlotIndexSetString(0,PLOT_LABEL,"Fibo MA("+(string)array_fibo_numbers.Total()+")");
   PlotIndexSetString(1,PLOT_LABEL,MethodToString(InpMethod)+"("+(string)period_ma+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFibo,true);
   ArraySetAsSeries(BufferFiMA,true);
   ArraySetAsSeries(BufferPrice,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(tick_volume,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(max_fibo_value,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-max_fibo_value-1;
      ArrayInitialize(BufferFibo,0);
      ArrayInitialize(BufferFiMA,0);
      ArrayInitialize(BufferPrice,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;

//--- Расчёт Fibo MA
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double sum=0;
      int total=array_fibo_numbers.Total()-1;
      for(int j=1; j<=total; j++)
         sum+=BufferPrice[i+array_fibo_numbers.At(j)];
      BufferFibo[i]=sum/total;
     }
//--- Расчёт MA
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      switch(InpMethod)
        {
         case METHOD_EMA            : BufferFiMA[i] = EMA(rates_total,BufferFibo[i],BufferFiMA[i+1],period_ma,i);       break;
         case METHOD_SMMA           : BufferFiMA[i] = SMMA(rates_total,BufferFibo,BufferFiMA[i+1],period_ma,i);         break;
         case METHOD_LWMA           : BufferFiMA[i] = LWMA(rates_total,BufferFibo,period_ma,i);                         break;
         case METHOD_WILDER_EMA     : BufferFiMA[i] = Wilder(rates_total,BufferFibo[i],BufferFiMA[i+1],period_ma,i);    break;
         case METHOD_SINE_WMA       : BufferFiMA[i] = SineWMA(rates_total,BufferFibo,period_ma,i);                      break;
         case METHOD_TRI_MA         : BufferFiMA[i] = TriMA(rates_total,BufferFibo,period_ma,i);                        break;
         case METHOD_LSMA           : BufferFiMA[i] = LSMA(rates_total,BufferFibo,period_ma,i);                         break;
         case METHOD_HMA            : BufferFiMA[i] = HMA(rates_total,BufferFibo,period_ma,i);                          break;
         case METHOD_ZL_EMA         : BufferFiMA[i] = ZeroLagEMA(rates_total,BufferFibo,BufferFiMA[i+1],period_ma,i);   break;
         case METHOD_ITREND_MA      : BufferFiMA[i] = ITrend(rates_total,BufferFibo,BufferFiMA,period_ma,i);            break;
         case METHOD_MOVING_MEDIAN  : BufferFiMA[i] = Median(rates_total,BufferFibo,period_ma,i);                       break;
         case METHOD_GEO_MEAN       : BufferFiMA[i] = GeoMean(rates_total,BufferFibo,period_ma,i);                      break;
         case METHOD_REMA           : BufferFiMA[i] = REMA(rates_total,BufferFibo[i],BufferFiMA,period_ma,0.5,i);       break;
         case METHOD_ILRS           : BufferFiMA[i] = ILRS(rates_total,BufferFibo,period_ma,i);                         break;
         case METHOD_IE_2           : BufferFiMA[i] = IE2(rates_total,BufferFibo,period_ma,i);                          break;
         case METHOD_TRI_MA_GEN     : BufferFiMA[i] = TriMA_gen(rates_total,BufferFibo,period_ma,i);                    break;
         case METHOD_VWMA           : BufferFiMA[i] = VWMA(rates_total,BufferFibo,tick_volume,period_ma,i);             break;
         default /*METHOD_SMA*/     : BufferFiMA[i] = SMA(rates_total,BufferFibo,period_ma,i);                          break;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double SMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return array_src[shift];
   double sum=0;
   for(int i=0; i<period; i++)
      sum+=array_src[shift+i];
   return(sum/period);
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
double EMA(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+2.0/(1+period)*(price-prev));
  }
//+------------------------------------------------------------------+
//| Wilder Exponential Moving Average                                |
//+------------------------------------------------------------------+
double Wilder(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+(price-prev)/period);
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
double LWMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=(period-i);
      sum+=array_src[shift+i]*(period-i);
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| Sine Weighted Moving Average                                     |
//+------------------------------------------------------------------+
double SineWMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=sin(M_PI*(i+1)/(period+1));
      sum+=array_src[shift+i]*sin(M_PI*(i+1)/(period+1));
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| Triangular Moving Average                                        |
//+------------------------------------------------------------------+
double TriMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sma;
   int len=(int)ceil((period+1)*0.5);
   double sum=0;
   for(int i=0; i<len; i++)
     {
      sma=SMA(rates_total,array_src,len,shift+i);
      sum+=sma;
     }
   double trima=sum/len;
   return(trima);
  }
//+------------------------------------------------------------------+
//| Least Square Moving Average                                      |
//+------------------------------------------------------------------+
double LSMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   for(int i=period; i>=1; i--)
      sum+=(i-(period+1)/3.0)*array_src[shift+period-i];
   double lsma=sum*6.0/(period*(period+1));
   return(lsma);
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
double SMMA(const int rates_total,const double &array_src[],const double prev,const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double smma=0;
   if(shift==rates_total-period-1)
      smma=SMA(rates_total,array_src,period,shift);
   else if(shift<rates_total-period-1)
     {
      double sum=0;
      for(int i = 0; i<period; i++)
         sum+=array_src[shift+i+1];
      smma=(sum-prev+array_src[shift])/period;
     }
   return smma;
  }
//+------------------------------------------------------------------+
//| Hull Moving Average by Alan Hull                                 |
//+------------------------------------------------------------------+
double HMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double tmp1[];
   double hma=0;
   int len=(int)sqrt(period);
   ArrayResize(tmp1,len);
   if(shift==rates_total-period-1)
      hma=array_src[shift];
   else if(shift<rates_total-period-1)
     {
      for(int i=0; i<len; i++)
         tmp1[i]=2.0*LWMA(rates_total,array_src,period/2,shift+i)-LWMA(rates_total,array_src,period,shift+i);
      hma=LWMA(rates_total,tmp1,len,0);
     }
   return hma;
  }
//+------------------------------------------------------------------+
//| Zero-Lag Exponential Moving Average                              |
//+------------------------------------------------------------------+
double ZeroLagEMA(const int rates_total,const double &array_src[],const double prev,const int period,const int shift)
  {
   double alfa=2.0/(1+period);
   int lag=int(0.5*(period-1));
   return(shift>=rates_total-lag ? array_src[shift] : alfa*(2.0*array_src[shift]-array_src[shift+lag])+(1-alfa)*prev);
  }
//+------------------------------------------------------------------+
//| Instantaneous Trendline by J.Ehlers                              |
//+------------------------------------------------------------------+
double ITrend(const int rates_total,const double &array_src[],const double &array[],const int period,const int shift)
  {
   double alfa=2.0/(period+1);
   return
     (
      shift<rates_total-7 ?
      (alfa-0.25*alfa*alfa)*array_src[shift]+0.5*alfa*alfa*array_src[shift+1]-(alfa-0.75*alfa*alfa)*array_src[shift+2]+2*(1-alfa)*array[shift+1]-(1-alfa)*(1-alfa)*array[shift+2]:
      (array_src[shift]+2*array_src[shift+1]+array_src[shift+2])/4.0
     );
  }
//+------------------------------------------------------------------+
//| Moving Median                                                    |
//+------------------------------------------------------------------+
double Median(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<2 || shift>rates_total-period-1)
      return 0;
   double array[];
   ArrayResize(array,period);
   for(int i=0; i<period; i++)
      array[i]=array_src[shift+i];
   ArraySort(array);
   int num=(int)round((period-1)/2);
   return(fmod(period,2)>0 ? array_src[num] : 0.5*(array_src[num]+array[num+1]));
  }
//+------------------------------------------------------------------+
//| Geometric Mean                                                   |
//+------------------------------------------------------------------+
double GeoMean(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   double gmean=0;
   if(shift<rates_total-period)
     {
      gmean=pow(array_src[shift],1.0/period);
      for(int i=1; i<period; i++)
         gmean*=pow(array_src[shift+i],1.0/period);
     }
   return(gmean);
  }
//+------------------------------------------------------------------+
//| Regularized EMA by Chris Satchwell                               |
//+------------------------------------------------------------------+
double REMA(const int rates_total,const double price,const double &array[],const int period,const double lambda,const int shift)
  {
   double alpha=2.0/(period+1);
   return(shift>=rates_total-3 ? price : (array[shift+1]*(1+2*lambda)+alpha*(price-array[shift+1])-lambda*array[shift+2])/(1+lambda));
  }
//+------------------------------------------------------------------+
//| Integral of Linear Regression Slope                              |
//+------------------------------------------------------------------+
double ILRS(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=period*(period-1)*0.5;
   double sum2=(period-1)*period*(2*period-1)/6.0;
   double sum1=0;
   double sumy=0;
   for(int i=0; i<period; i++)
     {
      sum1+=i*array_src[shift+i];
      sumy+=array_src[shift+i];
     }
   double num1=period*sum1-sum*sumy;
   double num2=sum*sum-period*sum2;
   double slope=(num2!=0 ? num1/num2 : 0);
   return(slope+SMA(rates_total,array_src,period,shift));
  }
//+------------------------------------------------------------------+
//| Combination of LSMA and ILRS                                     |
//+------------------------------------------------------------------+
double IE2(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   return(0.5*(ILRS(rates_total,array_src,period,shift)+LSMA(rates_total,array_src,period,shift)));
  }
//+------------------------------------------------------------------+
//| Triangular Moving Average generalized by J.Ehlers                |
//+------------------------------------------------------------------+
double TriMA_gen(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   int len1=(int)floor((period+1)*0.5);
   int len2=(int)ceil((period+1)*0.5);
   double sum=0;
   for(int i=0; i<len2; i++)
      sum+=SMA(rates_total,array_src,len1,shift+i);
   return(sum/len2);
  }
//+------------------------------------------------------------------+
//| Volume-Weighted Moving Average                                   |
//+------------------------------------------------------------------+
template<typename T>
double VWMA(const int rates_total,const double &array_src[],const T &volume[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=(double)volume[shift+i];
      sum+=array_src[shift+i]*volume[shift+i];
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_MODE method)
  {
   return StringSubstr(EnumToString(method),7);
  }
//+------------------------------------------------------------------+

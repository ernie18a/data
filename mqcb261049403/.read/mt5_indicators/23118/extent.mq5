//+------------------------------------------------------------------+
//|                                                       Extent.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Extent oscillator."
#property description "Shows the difference between a specified Moving Average and price"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Extent
#property indicator_label1  "Extent Osc"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrDarkSeaGreen,clrRed,clrBurlyWood,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
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
input uint                 InpPeriodMA       =  36;            // MA period
input ENUM_MA_MODE         InpMethodMA       =  METHOD_SMA;    // MA type
input ENUM_APPLIED_PRICE   InpAppliedPriceMA =  PRICE_CLOSE;   // MA applied price
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Price for comparison
//--- indicator buffers
double         BufferExtent[];
double         BufferColors[];
double         BufferMA[];
double         BufferPrice[];
//--- global variables
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   uint min=(InpAppliedPrice==InpAppliedPriceMA ? 2 : 1);
   period_ma=int(InpPeriodMA<min ? min : InpPeriodMA);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferExtent,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Extent (Price "+PriceToString(InpAppliedPrice)+" vs "+MethodToString(InpMethodMA)+"("+(string)period_ma+"))");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferExtent,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPriceMA);
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-2;
      ArrayInitialize(BufferExtent,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferPrice,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      switch(InpMethodMA)
        {
         case METHOD_EMA            : BufferMA[i] = EMA(rates_total,BufferPrice[i],BufferMA[i+1],period_ma,i);       break;
         case METHOD_SMMA           : BufferMA[i] = SMMA(rates_total,BufferPrice,BufferMA[i+1],period_ma,i);         break;
         case METHOD_LWMA           : BufferMA[i] = LWMA(rates_total,BufferPrice,period_ma,i);                       break;
         case METHOD_WILDER_EMA     : BufferMA[i] = Wilder(rates_total,BufferPrice[i],BufferMA[i+1],period_ma,i);    break;
         case METHOD_SINE_WMA       : BufferMA[i] = SineWMA(rates_total,BufferPrice,period_ma,i);                    break;
         case METHOD_TRI_MA         : BufferMA[i] = TriMA(rates_total,BufferPrice,period_ma,i);                      break;
         case METHOD_LSMA           : BufferMA[i] = LSMA(rates_total,BufferPrice,period_ma,i);                       break;
         case METHOD_HMA            : BufferMA[i] = HMA(rates_total,BufferPrice,period_ma,i);                        break;
         case METHOD_ZL_EMA         : BufferMA[i] = ZeroLagEMA(rates_total,BufferPrice,BufferMA[i+1],period_ma,i);   break;
         case METHOD_ITREND_MA      : BufferMA[i] = ITrend(rates_total,BufferPrice,BufferMA,period_ma,i);            break;
         case METHOD_MOVING_MEDIAN  : BufferMA[i] = Median(rates_total,BufferPrice,period_ma,i);                     break;
         case METHOD_GEO_MEAN       : BufferMA[i] = GeoMean(rates_total,BufferPrice,period_ma,i);                    break;
         case METHOD_REMA           : BufferMA[i] = REMA(rates_total,BufferPrice[i],BufferMA,period_ma,0.5,i);       break;
         case METHOD_ILRS           : BufferMA[i] = ILRS(rates_total,BufferPrice,period_ma,i);                       break;
         case METHOD_IE_2           : BufferMA[i] = IE2(rates_total,BufferPrice,period_ma,i);                        break;
         case METHOD_TRI_MA_GEN     : BufferMA[i] = TriMAgen(rates_total,BufferPrice,period_ma,i);                   break;
         case METHOD_VWMA           : BufferMA[i] = VWMA(rates_total,BufferPrice,tick_volume,period_ma,i);           break;
         default /*METHOD_SMA*/     : BufferMA[i] = SMA(rates_total,BufferPrice,period_ma,i);                        break;
        }
      BufferExtent[i]=AppliedPrice(InpAppliedPrice,i)-BufferMA[i];
      BufferColors[i]=
        (
         BufferExtent[i]>0 ? (BufferExtent[i]>BufferExtent[i+1] ? 0 : BufferExtent[i]<BufferExtent[i+1] ? 1 : 4) :
         BufferExtent[i]<0 ? (BufferExtent[i]<BufferExtent[i+1] ? 2 : BufferExtent[i]>BufferExtent[i+1] ? 3 : 4) : 4
        );
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
   if(period<1 || shift>rates_total-period-1)
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
double TriMAgen(const int rates_total,const double &array_src[],const int period,const int shift)
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
//| Возвращает заданную цену                                         |
//+------------------------------------------------------------------+
double AppliedPrice(const ENUM_APPLIED_PRICE price,const int index)
  {
   switch(price)
     {
      case PRICE_OPEN      :  return PriceOpen(index);
      case PRICE_HIGH      :  return PriceHigh(index);
      case PRICE_LOW       :  return PriceLow(index);
      case PRICE_CLOSE     :  return PriceClose(index);
      case PRICE_MEDIAN    :  return PriceMedian(index);
      case PRICE_TYPICAL   :  return PriceTypical(index);
      //---PRICE_WEIGHTED
      default              :  return PriceWeighted(index);
     }
  }
//+------------------------------------------------------------------+
//| Возвращает цену Open                                             |
//+------------------------------------------------------------------+
double PriceOpen(const int index)
  {
   double array[];
   return(CopyOpen(NULL,PERIOD_CURRENT,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает цену High                                             |
//+------------------------------------------------------------------+
double PriceHigh(const int index)
  {
   double array[];
   return(CopyHigh(NULL,PERIOD_CURRENT,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает цену Low                                              |
//+------------------------------------------------------------------+
double PriceLow(const int index)
  {
   double array[];
   return(CopyLow(NULL,PERIOD_CURRENT,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает цену Close                                            |
//+------------------------------------------------------------------+
double PriceClose(const int index)
  {
   double array[];
   return(CopyClose(NULL,PERIOD_CURRENT,index,1,array)==1 ? array[0] : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает медианную цену                                        |
//+------------------------------------------------------------------+
double PriceMedian(const int index)
  {
   double array[];
   double high=PriceHigh(index);
   double low=PriceLow(index);
   return(high>0 && low>0 ? (high+low)/2 : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает типичную цену                                         |
//+------------------------------------------------------------------+
double PriceTypical(const int index)
  {
   double array[];
   double high=PriceHigh(index);
   double low=PriceLow(index);
   double close=PriceClose(index);
   return(high>0 && low>0 && close>0 ? (high+low+close)/3 : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает взвешенную цену                                       |
//+------------------------------------------------------------------+
double PriceWeighted(const int index)
  {
   double array[];
   double high=PriceHigh(index);
   double low=PriceLow(index);
   double close=PriceClose(index);
   return(high>0 && low>0 && close>0 ? (high+low+close+close)/4 : 0);
  }  
//+------------------------------------------------------------------+
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_MODE method)
  {
   return StringSubstr(EnumToString(method),7);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование типа цены                                |
//+------------------------------------------------------------------+
string PriceToString(ENUM_APPLIED_PRICE price)
  {
   return StringSubstr(EnumToString(price),6);
  }
//+------------------------------------------------------------------+

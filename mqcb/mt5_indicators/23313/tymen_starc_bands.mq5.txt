//+------------------------------------------------------------------+
//|                                            Tymen_STARC_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Tymen STARC Bands indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   5
//--- plot Highest
#property indicator_label1  "Highest"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Middle
#property indicator_label3  "Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Bottom
#property indicator_label4  "Bottom"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Lowest
#property indicator_label5  "Lowest"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
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
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input uint                 InpPeriodATR      =  15;            // ATR period
input uint                 InpPeriodMA       =  6;             // MA period
input ENUM_MA_MODE         InpMethod         =  METHOD_EMA;    // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpKATR           =  1.0;           // ATR coefficient
input double               InpMKATR          =  0.7;           // ATR middle coefficient
input ENUM_INPUT_YES_NO    InpShowMiddle     =  INPUT_YES;     // Show middle lines
//--- indicator buffers
double         BufferTopExtr[];
double         BufferTop[];
double         BufferMiddle[];
double         BufferBottom[];
double         BufferBottomExtr[];
double         BufferATR[];
double         BufferPrice[];
//--- global variables
double         katr;
double         mkatr;
int            period_ma;
int            period_atr;
int            handle_ma;
int            handle_atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<2 ? 2 : InpPeriodMA);
   period_atr=int(InpPeriodATR<1 ? 1 : InpPeriodATR);
   katr=InpKATR;
   mkatr=InpMKATR;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTopExtr,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(3,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBottomExtr,INDICATOR_DATA);
   SetIndexBuffer(5,BufferATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Tymen STARC Bands ("+(string)period_atr+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowMiddle);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTopExtr,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferBottomExtr,true);
   ArraySetAsSeries(BufferATR,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr=iATR(NULL,PERIOD_CURRENT,period_atr);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR(",(string)period_atr,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferTopExtr,EMPTY_VALUE);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,0);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferBottomExtr,EMPTY_VALUE);
      ArrayInitialize(BufferATR,0);
      ArrayInitialize(BufferPrice,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      GetMA(rates_total,InpMethod,period_ma,i,BufferPrice,BufferMiddle,tick_volume);
      BufferTopExtr[i]=BufferMiddle[i]+BufferATR[i]*katr;
      BufferTop[i]=BufferMiddle[i]+BufferATR[i]*mkatr;
      BufferBottom[i]=BufferMiddle[i]-BufferATR[i]*mkatr;
      BufferBottomExtr[i]=BufferMiddle[i]-BufferATR[i]*katr;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| GetMA                                                            |
//+------------------------------------------------------------------+
void GetMA(const int rates_total,const ENUM_MA_MODE method,const int period,const int shift,const double &price[],double &ma[],const long &tick_volume[])
  {
   switch(method)
     {
      case METHOD_EMA            : ma[shift] = EMA(rates_total,price[shift],ma[shift+1],period,shift);      break;
      case METHOD_SMMA           : ma[shift] = SMMA(rates_total,price,ma[shift+1],period,shift);            break;
      case METHOD_LWMA           : ma[shift] = LWMA(rates_total,price,period,shift);                        break;
      case METHOD_WILDER_EMA     : ma[shift] = Wilder(rates_total,price[shift],ma[shift+1],period,shift);   break;
      case METHOD_SINE_WMA       : ma[shift] = SineWMA(rates_total,price,period,shift);                     break;
      case METHOD_TRI_MA         : ma[shift] = TriMA(rates_total,price,period,shift);                       break;
      case METHOD_LSMA           : ma[shift] = LSMA(rates_total,price,period,shift);                        break;
      case METHOD_HMA            : ma[shift] = HMA(rates_total,price,period,shift);                         break;
      case METHOD_ZL_EMA         : ma[shift] = ZeroLagEMA(rates_total,price,ma[shift+1],period,shift);      break;
      case METHOD_ITREND_MA      : ma[shift] = ITrend(rates_total,price,ma,period,shift);                   break;
      case METHOD_MOVING_MEDIAN  : ma[shift] = Median(rates_total,price,period,shift);                      break;
      case METHOD_GEO_MEAN       : ma[shift] = GeoMean(rates_total,price,period,shift);                     break;
      case METHOD_REMA           : ma[shift] = REMA(rates_total,price[shift],ma,period,0.5,shift);          break;
      case METHOD_ILRS           : ma[shift] = ILRS(rates_total,price,period,shift);                        break;
      case METHOD_IE_2           : ma[shift] = IE2(rates_total,price,period,shift);                         break;
      case METHOD_TRI_MA_GEN     : ma[shift] = TriMAgen(rates_total,price,period,shift);                    break;
      case METHOD_VWMA           : ma[shift] = VWMA(rates_total,price,tick_volume,period,shift);            break;
      default /*METHOD_SMA*/     : ma[shift] = SMA(rates_total,price,period,shift);                         break;
     }
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
   return sum/len;
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
   return sum*6.0/(period*(period+1));
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

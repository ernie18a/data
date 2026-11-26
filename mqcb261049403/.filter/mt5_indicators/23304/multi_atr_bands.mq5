//+------------------------------------------------------------------+
//|                                              Multi_ATR_Bands.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Three ATR Bands with multiple selection"
#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots   9
//--- plot Top1
#property indicator_label1  "Top Band 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle1
#property indicator_label2  "Middle Band 1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom1
#property indicator_label3  "Bottom Band 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Top2
#property indicator_label4  "Top Band 2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Middle2
#property indicator_label5  "Middle Band 2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Bottom2
#property indicator_label6  "Bottom Band 2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Top3
#property indicator_label7  "Top Band 3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Middle3
#property indicator_label8  "Middle Band 3"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot Bottom3
#property indicator_label9  "Bottom Band 3"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
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
input ENUM_INPUT_YES_NO    InpShowMiddle     =  INPUT_NO;      // Show middle lines
input ENUM_INPUT_YES_NO    InpShowBands1     =  INPUT_YES;     // Show first ATR Bands
input uint                 InpPeriodATR1     =  14;            // First ATR period
input uint                 InpPeriodMA1      =  14;            // First MA period
input ENUM_MA_MODE         InpMethod1        =  METHOD_EMA;    // First MA type
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;   // First applied price
input double               InpPercent1       =  2.0;           // First bands multiplier

input ENUM_INPUT_YES_NO    InpShowBands2     =  INPUT_YES;     // Show second ATR Bands
input uint                 InpPeriodATR2     =  18;            // Second ATR period
input uint                 InpPeriodMA2      =  50;            // Second MA period
input ENUM_MA_MODE         InpMethod2        =  METHOD_SMMA;   // Second MA type
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_CLOSE;   // Second applied price
input double               InpPercent2       =  2.0;           // Second bands multiplier

input ENUM_INPUT_YES_NO    InpShowBands3     =  INPUT_YES;     // Show third ATR Bands
input uint                 InpPeriodATR3     =  15;            // Third ATR period
input uint                 InpPeriodMA3      =  100;           // Third MA period
input ENUM_MA_MODE         InpMethod3        =  METHOD_HMA;    // Third MA type
input ENUM_APPLIED_PRICE   InpAppliedPrice3  =  PRICE_CLOSE;   // Third applied price
input double               InpPercent3       =  2.0;           // Third bands multiplier
//--- indicator buffers
double         BufferTop1[];
double         BufferMiddle1[];
double         BufferBottom1[];
double         BufferTop2[];
double         BufferMiddle2[];
double         BufferBottom2[];
double         BufferTop3[];
double         BufferMiddle3[];
double         BufferBottom3[];
//---
double         BufferATR1[];
double         BufferATR2[];
double         BufferATR3[];
double         BufferPrice1[];
double         BufferPrice2[];
double         BufferPrice3[];
//--- global variables
double         percent1;
double         percent2;
double         percent3;
int            period_ma1;
int            period_ma2;
int            period_ma3;
int            period_atr1;
int            period_atr2;
int            period_atr3;
int            period_max;
int            handle_ma1;
int            handle_ma2;
int            handle_ma3;
int            handle_atr1;
int            handle_atr2;
int            handle_atr3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   percent1=InpPercent1;
   percent2=InpPercent2;
   percent3=InpPercent3;
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   period_ma3=int(InpPeriodMA3<2 ? 2 : InpPeriodMA3);
   period_atr1=int(InpPeriodATR1<1 ? 1 : InpPeriodATR1);
   period_atr2=int(InpPeriodATR2<1 ? 1 : InpPeriodATR2);
   period_atr3=int(InpPeriodATR3<1 ? 1 : InpPeriodATR3);
   period_max=fmax(period_ma1,fmax(period_ma2,period_ma3));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferTop2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMiddle2,INDICATOR_DATA);
   SetIndexBuffer(5,BufferBottom2,INDICATOR_DATA);
   SetIndexBuffer(6,BufferTop3,INDICATOR_DATA);
   SetIndexBuffer(7,BufferMiddle3,INDICATOR_DATA);
   SetIndexBuffer(8,BufferBottom3,INDICATOR_DATA);
   SetIndexBuffer(9,BufferATR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferATR2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferATR3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferPrice1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferPrice2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferPrice3,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MTF ATR Bands");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,InpShowBands1);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,(InpShowBands1 ? InpShowMiddle : 0));
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowBands1);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpShowBands2);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,(InpShowBands2 ? InpShowMiddle : 0));
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,InpShowBands2);
   PlotIndexSetInteger(6,PLOT_DRAW_TYPE,InpShowBands3);
   PlotIndexSetInteger(7,PLOT_DRAW_TYPE,(InpShowBands3 ? InpShowMiddle : 0));
   PlotIndexSetInteger(8,PLOT_DRAW_TYPE,InpShowBands3);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop1,true);
   ArraySetAsSeries(BufferMiddle1,true);
   ArraySetAsSeries(BufferBottom1,true);
   ArraySetAsSeries(BufferTop2,true);
   ArraySetAsSeries(BufferMiddle2,true);
   ArraySetAsSeries(BufferBottom2,true);
   ArraySetAsSeries(BufferTop3,true);
   ArraySetAsSeries(BufferMiddle3,true);
   ArraySetAsSeries(BufferBottom3,true);
   ArraySetAsSeries(BufferATR1,true);
   ArraySetAsSeries(BufferATR2,true);
   ArraySetAsSeries(BufferATR3,true);
   ArraySetAsSeries(BufferPrice1,true);
   ArraySetAsSeries(BufferPrice2,true);
   ArraySetAsSeries(BufferPrice3,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice1);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice2);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma3=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice3);
   if(handle_ma3==INVALID_HANDLE)
     {
      Print(__LINE__,": The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr1=iATR(NULL,PERIOD_CURRENT,period_atr1);
   if(handle_atr1==INVALID_HANDLE)
     {
      Print(__LINE__,": The iATR(",(string)period_atr1,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr2=iATR(NULL,PERIOD_CURRENT,period_atr2);
   if(handle_atr2==INVALID_HANDLE)
     {
      Print(__LINE__,": The iATR(",(string)period_atr2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_atr3=iATR(NULL,PERIOD_CURRENT,period_atr3);
   if(handle_atr3==INVALID_HANDLE)
     {
      Print(__LINE__,": The iATR(",(string)period_atr3,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-1;
      ArrayInitialize(BufferTop1,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle1,0);
      ArrayInitialize(BufferBottom1,EMPTY_VALUE);
      ArrayInitialize(BufferTop2,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle2,0);
      ArrayInitialize(BufferBottom2,EMPTY_VALUE);
      ArrayInitialize(BufferTop3,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle3,0);
      ArrayInitialize(BufferBottom3,EMPTY_VALUE);
      ArrayInitialize(BufferATR1,0);
      ArrayInitialize(BufferATR2,0);
      ArrayInitialize(BufferATR3,0);
      ArrayInitialize(BufferPrice1,0);
      ArrayInitialize(BufferPrice2,0);
      ArrayInitialize(BufferPrice3,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferPrice1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferPrice2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma3,0,0,count,BufferPrice3);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr1,0,0,count,BufferATR1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr2,0,0,count,BufferATR2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_atr3,0,0,count,BufferATR3);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      GetMA(rates_total,InpMethod1,period_ma1,i,BufferPrice1,BufferMiddle1,tick_volume);
      BufferTop1[i]=BufferMiddle1[i]+(BufferATR1[i]*percent1);
      BufferBottom1[i]=BufferMiddle1[i]-(BufferATR1[i]*percent1);

      GetMA(rates_total,InpMethod2,period_ma2,i,BufferPrice2,BufferMiddle2,tick_volume);
      BufferTop2[i]=BufferMiddle2[i]+(BufferATR2[i]*percent2);
      BufferBottom2[i]=BufferMiddle2[i]-(BufferATR2[i]*percent2);
      
      GetMA(rates_total,InpMethod3,period_ma3,i,BufferPrice3,BufferMiddle3,tick_volume);
      BufferTop3[i]=BufferMiddle3[i]+(BufferATR3[i]*percent1);
      BufferBottom3[i]=BufferMiddle3[i]-(BufferATR3[i]*percent1);
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

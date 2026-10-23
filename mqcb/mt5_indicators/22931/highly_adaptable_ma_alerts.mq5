//+------------------------------------------------------------------+
//|                                   Highly_Adaptable_MA_Alerts.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Highly Adaptable Moving Average Alert indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   6
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_DOT
#property indicator_width3  1
//--- plot SigMean
#property indicator_label4  "Mean crossing"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot SigTop
#property indicator_label5  "Top crossing"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot SigBottom
#property indicator_label6  "Bottom crossing"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
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
enum ENUM_ALERT_REASON
  {
   REASON_ALERT_ALL,    // All
   REASON_ALERT_MEAN,   // Mean
   REASON_ALERT_TOP,    // Top
   REASON_ALERT_BOTTOM, // Bottom
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//--- input parameters
input uint                 InpPeriodMA       =  50;               // MA period
input ENUM_MA_MODE         InpMethod         =  METHOD_EMA;       // MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // MA applied price
input double               InpPercentBand    =  0.618;            // Bands percent
input ENUM_ALERT_REASON    InpReasonAlert    =  REASON_ALERT_ALL; // Show alerts for
input ENUM_INPUT_YES_NO    InpUseAlert       =  INPUT_YES;        // Use alert
input ENUM_INPUT_YES_NO    InpSendMail       =  INPUT_NO;         // Send mail
input ENUM_INPUT_YES_NO    InpSendPush       =  INPUT_YES;        // Send push
//--- indicator buffers
double         BufferMA[];
double         BufferTop[];
double         BufferBottom[];
double         BufferSigMean[];
double         BufferSigTop[];
double         BufferSigBottom[];
double         BufferPrice[];
//--- global variables
double         percent_band;
double         point;
int            period_ma;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   point=Point();
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   percent_band=InpPercentBand;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSigMean,INDICATOR_DATA);
   SetIndexBuffer(4,BufferSigTop,INDICATOR_DATA);
   SetIndexBuffer(5,BufferSigBottom,INDICATOR_DATA);
   SetIndexBuffer(6,BufferPrice,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,234);
   PlotIndexSetInteger(5,PLOT_ARROW,233);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Highly Adaptable "+MethodToString(InpMethod)+" ("+(string)period_ma+","+(string)percent_band+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferSigMean,true);
   ArraySetAsSeries(BufferSigTop,true);
   ArraySetAsSeries(BufferSigBottom,true);
   ArraySetAsSeries(BufferPrice,true);
//--- create handles
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(tick_volume,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-1;
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferSigMean,EMPTY_VALUE);
      ArrayInitialize(BufferSigTop,EMPTY_VALUE);
      ArrayInitialize(BufferSigBottom,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferPrice);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      switch(InpMethod)
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
      BufferTop[i]=BufferMA[i]*(1+(percent_band/100.0));
      BufferBottom[i]=BufferMA[i]*(1-(percent_band/100.0));
      //--- Mean
      if((InpReasonAlert==REASON_ALERT_ALL || InpReasonAlert==REASON_ALERT_MEAN) && ((close[i+1]<BufferMA[i+1] && close[i]>=BufferMA[i]) || (close[i+1]>BufferMA[i+1] && close[i]<=BufferMA[i])))
        {
         BufferSigMean[i]=BufferMA[i];
         if(i==0 && time[0]>last_time)
           {
            string message=Symbol()+","+TimeframeToString(Period())+": Price just crossed the Moving Average Center Line.";
            if(InpUseAlert) Alert(message);
            if(InpSendMail && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Moving Average Cross Signal",message);
            if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
            last_time=TimeCurrent();
           }
        }
      //--- Top
      if((InpReasonAlert==REASON_ALERT_ALL || InpReasonAlert==REASON_ALERT_TOP) && close[i+1]<BufferTop[i+1] && close[i]>=BufferTop[i])
        {
         BufferSigTop[i]=high[i]+(20*point);
         if(i==0 && time[0]>last_time)
           {
            string message=Symbol()+","+TimeframeToString(Period())+": Price just crossed the Moving Average Top Band.";
            if(InpUseAlert) Alert(message);
            if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Moving Average Cross Signal",message);
            if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
            last_time=TimeCurrent();
           }
        }
      //--- Bottom
      if((InpReasonAlert==REASON_ALERT_ALL || InpReasonAlert==REASON_ALERT_BOTTOM) && close[i+1]>BufferBottom[i+1] && close[i]<=BufferBottom[i])
        {
         BufferSigBottom[i]=low[i]-(20*point);
         if(i==0 && time[0]>last_time)
           {
            string message=Symbol()+","+TimeframeToString(Period())+": Price just crossed the Moving Average Bottom Band.";
            if(InpUseAlert) Alert(message);
            if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("Moving Average Cross Signal",message);
            if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
            last_time=TimeCurrent();
           }
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
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_MODE method)
  {
   return StringSubstr(EnumToString(method),7);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  { 
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+

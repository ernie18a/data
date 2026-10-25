//+------------------------------------------------------------------+
//|                                            3_in_1_Stochastic.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "3 in 1 MTF Stochastic with MA Smoothing options indicator"
#property indicator_separate_window
#property indicator_buffers 27
#property indicator_plots   10
//--- plot Cloud2
#property indicator_label1  "Cloud2"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDarkSeaGreen,clrBurlyWood
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Cloud3
#property indicator_label2  "Cloud3"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrYellowGreen,clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SK1
#property indicator_label3  "SK1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot SD1
#property indicator_label4  "SD1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot SK2
#property indicator_label5  "SK2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot SD2
#property indicator_label6  "SD2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot SK3
#property indicator_label7  "SK3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGreen
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot SD3
#property indicator_label8  "SD3"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot UP
#property indicator_label9  "Up signal"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrGreen
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot DN
#property indicator_label10  "Down signal"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrRed
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- enums
enum ENUM_DRAW_MODE
  {
   DRAW_MODE_STEPS,     // Steps
   DRAW_MODE_SLOPE      // Slope
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,    // Yes
   INPUT_NO    =  0     // No
  };
//---
enum ENUM_TYPE_SMOOTH_K
  {
   TYPE_SMOOTH_K_SMA    =  MODE_SMA,   // Simple
   TYPE_SMOOTH_K_EMA    =  MODE_EMA,   // Exponential
   TYPE_SMOOTH_K_FAST   =  2           // Fast
  };
//---
enum ENUM_TYPE_SMOOTH_D
  {
   TYPE_SMOOTH_D_SMA    =  MODE_SMA,   // Simple
   TYPE_SMOOTH_D_EMA    =  MODE_EMA    // Exponential
  };
//--- input parameters
input uint                 InpPeriodK1    =  5;                   // First Stochastic %K period
input uint                 InpPeriodD1    =  3;                   // First Stochastic %D period
input uint                 InpSlowing1    =  3;                   // First Stochastic slowing
input ENUM_TYPE_SMOOTH_K   InpTypeSmK1    =  TYPE_SMOOTH_K_SMA;   // First Stochastic %K smoothing type
input ENUM_TYPE_SMOOTH_D   InpTypeSmD1    =  TYPE_SMOOTH_D_SMA;   // First Stochastic %D smoothing type

input ENUM_TIMEFRAMES      InpTimeframe2  =  PERIOD_H4;           // Second Stochastic timeframe
input uint                 InpPeriodK2    =  5;                   // Second Stochastic %K period
input uint                 InpPeriodD2    =  3;                   // Second Stochastic %D period
input uint                 InpSlowing2    =  3;                   // Second Stochastic slowing
input ENUM_TYPE_SMOOTH_K   InpTypeSmK2    =  TYPE_SMOOTH_K_SMA;   // Second Stochastic %K smoothing type
input ENUM_TYPE_SMOOTH_D   InpTypeSmD2    =  TYPE_SMOOTH_D_SMA;   // Second Stochastic %D smoothing type

input ENUM_TIMEFRAMES      InpTimeframe3  =  PERIOD_D1;           // Third Stochastic timeframe
input uint                 InpPeriodK3    =  5;                   // Third Stochastic %K period
input uint                 InpPeriodD3    =  3;                   // Third Stochastic %D period
input uint                 InpSlowing3    =  3;                   // Third Stochastic slowing
input ENUM_TYPE_SMOOTH_K   InpTypeSmK3    =  TYPE_SMOOTH_K_SMA;   // Third Stochastic %K smoothing type
input ENUM_TYPE_SMOOTH_D   InpTypeSmD3    =  TYPE_SMOOTH_D_SMA;   // Third Stochastic %D smoothing type

input double               InpOverbought  =  80.0;                // Overbought
input double               InpOversold    =  20.0;                // Oversold

input ENUM_DRAW_MODE       InpDrawMode    =  DRAW_MODE_STEPS;     // Bigger timeframes drawing mode
input ENUM_INPUT_YES_NO    InpShowClouds  =  INPUT_YES;           // Show clouds
input ENUM_INPUT_YES_NO    InpShowAlert   =  INPUT_YES;           // Show alerts
input ENUM_INPUT_YES_NO    InpSendMail    =  INPUT_NO;            // Send mail
input ENUM_INPUT_YES_NO    InpSendPush    =  INPUT_YES;           // Send push
//--- indicator buffers
double         BufferCloud21[];
double         BufferCloud22[];
double         BufferCloud31[];
double         BufferCloud32[];
double         BufferSK1[];
double         BufferSD1[];
double         BufferSK2[];
double         BufferSD2[];
double         BufferSK3[];
double         BufferSD3[];
double         BufferUP[];
double         BufferDN[];
double         BufferSK2tmp[];
double         BufferSD2tmp[];
double         BufferSK3tmp[];
double         BufferSD3tmp[];
double         BufferMin1[];
double         BufferMax1[];
double         BufferFastK1[];
double         BufferMin2[];
double         BufferMax2[];
double         BufferFastK2[];
double         BufferMin3[];
double         BufferMax3[];
double         BufferFastK3[];
double         BufferClose2[];
double         BufferClose3[];
//--- global variables
ENUM_TIMEFRAMES   timeframe2;
ENUM_TIMEFRAMES   timeframe3;
double            overbought;
double            oversold;
int               periodK1;
int               periodK2;
int               periodK3;
int               periodD1;
int               periodD2;
int               periodD3;
int               slowing1;
int               slowing2;
int               slowing3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- timer
   EventSetTimer(90);
//--- set global variables
   periodK1=int(InpPeriodK1<1 ? 1 : InpPeriodK1);
   periodD1=int(InpPeriodD1<1 ? 1 : InpPeriodD1);
   slowing1=int(InpSlowing1<1 ? 1 : InpSlowing1);
   periodK2=int(InpPeriodK2<1 ? 1 : InpPeriodK2);
   periodD2=int(InpPeriodD2<1 ? 1 : InpPeriodD2);
   slowing2=int(InpSlowing2<1 ? 1 : InpSlowing2);
   periodK3=int(InpPeriodK3<1 ? 1 : InpPeriodK3);
   periodD3=int(InpPeriodD3<1 ? 1 : InpPeriodD3);
   slowing3=int(InpSlowing3<1 ? 1 : InpSlowing3);
   timeframe2=(InpTimeframe2>Period() ? InpTimeframe2 : Period());
   timeframe3=(InpTimeframe3>Period() ? InpTimeframe3 : Period());
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCloud21,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCloud22,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCloud31,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCloud32,INDICATOR_DATA);
   SetIndexBuffer(4,BufferSK1,INDICATOR_DATA);
   SetIndexBuffer(5,BufferSD1,INDICATOR_DATA);
   SetIndexBuffer(6,BufferSK2,INDICATOR_DATA);
   SetIndexBuffer(7,BufferSD2,INDICATOR_DATA);
   SetIndexBuffer(8,BufferSK3,INDICATOR_DATA);
   SetIndexBuffer(9,BufferSD3,INDICATOR_DATA);
   SetIndexBuffer(10,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(11,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(12,BufferSK2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferSD2tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferSK3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BufferSD3tmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferMin1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,BufferMin2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,BufferMin3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,BufferMax1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,BufferMax2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(21,BufferMax3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,BufferFastK1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,BufferFastK2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(24,BufferFastK3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(25,BufferClose2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(26,BufferClose3,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(8,PLOT_ARROW,233);
   PlotIndexSetInteger(9,PLOT_ARROW,234);
//--- setting indicator parameters
   string label=TimeframeToString(timeframe2)+","+TimeframeToString(timeframe3)+" in "+TimeframeToString(Period())+" Stochastic";
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetString(2,PLOT_LABEL,TimeframeToString(Period())+" Stochastic");
   PlotIndexSetString(3,PLOT_LABEL,TimeframeToString(Period())+" Signal");
   PlotIndexSetString(4,PLOT_LABEL,TimeframeToString(timeframe2)+" Stochastic");
   PlotIndexSetString(5,PLOT_LABEL,TimeframeToString(timeframe2)+" Signal");
   PlotIndexSetString(6,PLOT_LABEL,TimeframeToString(timeframe3)+" Stochastic");
   PlotIndexSetString(7,PLOT_LABEL,TimeframeToString(timeframe3)+" Signal");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCloud21,true);
   ArraySetAsSeries(BufferCloud22,true);
   ArraySetAsSeries(BufferCloud31,true);
   ArraySetAsSeries(BufferCloud32,true);
   ArraySetAsSeries(BufferSK1,true);
   ArraySetAsSeries(BufferSD1,true);
   ArraySetAsSeries(BufferSK2,true);
   ArraySetAsSeries(BufferSD2,true);
   ArraySetAsSeries(BufferSK3,true);
   ArraySetAsSeries(BufferSD3,true);
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferSK2tmp,true);
   ArraySetAsSeries(BufferSD2tmp,true);
   ArraySetAsSeries(BufferSK3tmp,true);
   ArraySetAsSeries(BufferSD3tmp,true);
   ArraySetAsSeries(BufferMax1,true);
   ArraySetAsSeries(BufferMax2,true);
   ArraySetAsSeries(BufferMax3,true);
   ArraySetAsSeries(BufferMin1,true);
   ArraySetAsSeries(BufferMin2,true);
   ArraySetAsSeries(BufferMin3,true);
   ArraySetAsSeries(BufferFastK1,true);
   ArraySetAsSeries(BufferFastK2,true);
   ArraySetAsSeries(BufferFastK3,true);
   ArraySetAsSeries(BufferClose2,true);
   ArraySetAsSeries(BufferClose3,true);
//--- get timeframe
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
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
   ArraySetAsSeries(time,true);
//--- Проверка количества доступных баров
   if(rates_total<4 || Time(NULL,timeframe2,1)==0 || Time(NULL,timeframe3,1)==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCloud21,EMPTY_VALUE);
      ArrayInitialize(BufferCloud22,EMPTY_VALUE);
      ArrayInitialize(BufferCloud31,EMPTY_VALUE);
      ArrayInitialize(BufferCloud32,EMPTY_VALUE);
      ArrayInitialize(BufferSK1,0);
      ArrayInitialize(BufferSD1,0);
      ArrayInitialize(BufferSK2,0);
      ArrayInitialize(BufferSD2,0);
      ArrayInitialize(BufferSK3,0);
      ArrayInitialize(BufferSD3,0);
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferSK2tmp,0);
      ArrayInitialize(BufferSD2tmp,0);
      ArrayInitialize(BufferSK3tmp,0);
      ArrayInitialize(BufferSD3tmp,0);
      ArrayInitialize(BufferMax1,0);
      ArrayInitialize(BufferMax2,0);
      ArrayInitialize(BufferMax3,0);
      ArrayInitialize(BufferMin1,0);
      ArrayInitialize(BufferMin2,0);
      ArrayInitialize(BufferMin3,0);
      ArrayInitialize(BufferFastK1,0);
      ArrayInitialize(BufferFastK2,0);
      ArrayInitialize(BufferFastK3,0);
      ArrayInitialize(BufferClose2,0);
      ArrayInitialize(BufferClose3,0);
     }
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double close2=Close(NULL,timeframe2,i);
      if(close2==0) continue;
      BufferClose2[i]=close2;
      double close3=Close(NULL,timeframe3,i);
      if(close3==0) continue;
      BufferClose3[i]=close3;
      
      DataPreparing(rates_total,i,periodK1,close,BufferMin1,BufferMax1,BufferFastK1);
      DataPreparing(rates_total,i,periodK2,BufferClose2,BufferMin2,BufferMax2,BufferFastK2);
      DataPreparing(rates_total,i,periodK3,BufferClose3,BufferMin3,BufferMax3,BufferFastK3);
      
      CalculateSK(rates_total,i,periodK1,slowing1,BufferMin1,BufferMax1,BufferFastK1,BufferSK1);
      CalculateSK(rates_total,i,periodK2,slowing2,BufferMin2,BufferMax2,BufferFastK2,BufferSK2tmp);
      CalculateSK(rates_total,i,periodK3,slowing3,BufferMin3,BufferMax3,BufferFastK3,BufferSK3tmp);
      if(InpTypeSmD1==TYPE_SMOOTH_D_SMA)
        {
         BufferSD1[i]=GetSMA(rates_total,BufferSK1,periodD1,i);
         BufferSD2tmp[i]=GetSMA(rates_total,BufferSK2tmp,periodD2,i);
         BufferSD3tmp[i]=GetSMA(rates_total,BufferSK3tmp,periodD3,i);
        }
      else
        {
         BufferSD1[i]=GetEMA(rates_total,BufferSK1[i],BufferSD1[i+1],periodD1,i);  
         BufferSD2tmp[i]=GetEMA(rates_total,BufferSK2tmp[i],BufferSD2tmp[i+1],periodD2,i);  
         BufferSD3tmp[i]=GetEMA(rates_total,BufferSK3tmp[i],BufferSD3tmp[i+1],periodD3,i);  
        }
      DataConversion(rates_total,NULL,timeframe2,i,BufferSK2tmp,BufferSK2,BufferCloud21,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe2,i,BufferSD2tmp,BufferSD2,BufferCloud22,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSK3tmp,BufferSK3,BufferCloud31,InpDrawMode);
      DataConversion(rates_total,NULL,timeframe3,i,BufferSD3tmp,BufferSD3,BufferCloud32,InpDrawMode);
     }
     
//--- Облако и сигналы
   string alerts="";
   static datetime last_time=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP[i]=BufferDN[i]=BufferCloud21[i]=BufferCloud22[i]=BufferCloud31[i]=BufferCloud32[i]=EMPTY_VALUE;
      if(InpShowClouds)
        {
         BufferCloud21[i]=BufferSK2[i];
         BufferCloud22[i]=BufferSD2[i];
         BufferCloud31[i]=BufferSK3[i];
         BufferCloud32[i]=BufferSD3[i];
        }
      if(BufferSK1[i]>BufferSD1[i] && BufferSK1[i+1]<=BufferSD1[i+1] && BufferSK2[i]>BufferSD2[i] && BufferSK3[i]>BufferSD3[i])
        {
         BufferUP[i]=BufferSK1[i];
         if(i==0) alerts="Up Signal";
        }
      if(BufferSK1[i]<BufferSD1[i] && BufferSK1[i+1]>=BufferSD1[i+1] && BufferSK2[i]<BufferSD2[i] && BufferSK3[i]<BufferSD3[i])
        {
         BufferDN[i]=BufferSK1[i];
         if(i==0) alerts="Down Signal";
        }
      if(i==0 && time[0]>last_time && alerts!="")
        {
         string message=Symbol()+", "+TimeframeToString(Period())+": 3 in 1 Stochastic "+alerts;
         if(InpShowAlert) Alert(message);
         if(InpSendMail  && TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)) SendMail("3 in 1 Stochastic Signal",message);
         if(InpSendPush && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(message);
         last_time=TimeCurrent();
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Time(NULL,timeframe2,1);
   Time(NULL,timeframe3,1);
  }
//+------------------------------------------------------------------+
//| Transfering data from the source timeframe to current timeframe  |
//+------------------------------------------------------------------+
void DataConversion(const int rates_total,
                    const string symbol_name,
                    const ENUM_TIMEFRAMES timeframe_src,
                    const int shift,
                    const double &buffer_src[],
                    double &buffer_dest[],
                    double &buffer_cloud[],
                    ENUM_DRAW_MODE mode=DRAW_MODE_STEPS
                   )
  {
   if(timeframe_src==Period())
     {
      buffer_dest[shift]=buffer_src[shift];
      return;
     }
   int bar_curr=BarToCurrent(symbol_name,timeframe_src,shift);
   if(bar_curr>rates_total-1)
      return;
   int bar_prev=BarToCurrent(symbol_name,timeframe_src,shift+1);
   int bar_next=(shift>0 ? BarToCurrent(symbol_name,timeframe_src,shift-1) : 0);
   if(bar_prev==WRONG_VALUE || bar_curr==WRONG_VALUE || bar_next==WRONG_VALUE)
      return;
   buffer_dest[bar_curr]=buffer_src[shift];
   if(mode==DRAW_MODE_STEPS)
      for(int j=bar_curr; j>=bar_next; j--)
        {
         buffer_dest[j]=buffer_dest[bar_curr];
         if(InpShowClouds)
            buffer_cloud[j]=buffer_dest[bar_curr];
        }
   else
     {
      if(bar_prev>rates_total-1) return;
      for(int j=bar_prev; j>=bar_curr; j--)
        {
         buffer_dest[j]=EquationDirect(bar_prev,buffer_dest[bar_prev],bar_curr,buffer_dest[bar_curr],j);
         if(InpShowClouds)
            buffer_cloud[j]=buffer_dest[j];
        }
      if(shift==0)
         for(int j=bar_curr; j>=0; j--)
           {
            buffer_dest[j]=buffer_dest[bar_curr];
            if(InpShowClouds)
               buffer_cloud[j]=buffer_dest[bar_curr];
           }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает бар заданного таймфрейма как бар текущего таймфрейма  |
//+------------------------------------------------------------------+
int BarToCurrent(const string symbol_name,const ENUM_TIMEFRAMES timeframe_src,const int shift,bool exact=false)
  {
   datetime time=Time(symbol_name,timeframe_src,shift);
   return(time!=0 ? BarShift(symbol_name,Period(),time,exact) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//| https://www.mql5.com/ru/forum/743/page11#comment_7010041         |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return res;
  }
//+------------------------------------------------------------------+
//| Возвращает Time                                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   ArraySetAsSeries(array,true);
   return(CopyTime(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает Close                                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyClose(symbol_name,timeframe,shift,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search)
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
//| Timeframe to string                                              |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
  {
   return StringSubstr(EnumToString(timeframe),7);
  }
//+------------------------------------------------------------------+
//| Подготовка данных                                                |
//+------------------------------------------------------------------+
void DataPreparing(const int rates_total,const int shift,const int period_k,const double &buffer_src[],double &buffer_min[],double &buffer_max[],double &buffer_fast_k[])
  {
   if(shift>rates_total-period_k-1)
      return;
   double max=0,min=0;
   for(int j=(shift+period_k-1); j>=shift; j--)
     {
      if(j==(shift+period_k-1))
         max=min=buffer_src[j];
      else
        {
         if(buffer_src[j]>max) max = buffer_src[j];
         if(buffer_src[j]<min) min = buffer_src[j];
        }
     }
   buffer_min[shift]=buffer_src[shift]-min;
   buffer_max[shift]=max-min;
   buffer_fast_k[shift]=(buffer_max[shift]>0 ? buffer_min[shift]/buffer_max[shift]*100.0 : 50.0);
  }
//+------------------------------------------------------------------+
//| Расчёт линии %K                                                  |
//+------------------------------------------------------------------+
void CalculateSK(const int rates_total,const int shift,const int period_k,const int slowing,double &buffer_min[],const double &buffer_max[],const double &buffer_fast[],double &buffer_sk[])
  {
   double sum_max=0,sum_min=0;
   if(InpTypeSmK1==TYPE_SMOOTH_K_FAST)
     {
      if(shift>rates_total-period_k-1)
         return;
      for(int j=(shift+period_k-1); j>=shift; j--)
         sum_max+=buffer_max[j];
      if(sum_max!=0)
        {
         for(int j=(shift+period_k-1); j>=shift; j--)
            sum_min+=buffer_min[j];
         buffer_sk[shift]=sum_min/sum_max*100.0;
        }
      else
         buffer_sk[shift]=50.0;
      }
   else
     {
      if(shift>rates_total-slowing-1)
         return;
      if(InpTypeSmK1==TYPE_SMOOTH_K_SMA)
         buffer_sk[shift]=GetSMA(rates_total,buffer_fast,slowing,shift);
      else
         buffer_sk[shift]=GetEMA(rates_total,buffer_fast[shift],buffer_sk[shift+1],slowing,shift);
     }
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const double &array_src[],const int period,const int shift)
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
double GetEMA(const int rates_total,const double price,const double prev,const int period,const int shift)
  {
   return(shift>=rates_total-2 || period<1 ? price : prev+2.0/(1+period)*(price-prev));
  }
//+------------------------------------------------------------------+

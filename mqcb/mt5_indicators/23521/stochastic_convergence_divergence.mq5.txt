//+------------------------------------------------------------------+
//|                            Stochastic_Convergence_Divergence.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Two Stochastics with MA Smoothing and Convergence Divergence line"
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   5
//--- plot SK1
#property indicator_label1  "Stoch %K1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SD1
#property indicator_label2  "Stoch %D1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SK2
#property indicator_label3  "Stoch %K2"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot SD2
#property indicator_label4  "Stoch %D2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Divergence
#property indicator_label5  "Divergence"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrPurple,clrHotPink,clrDarkGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- enums
enum ENUM_IND_MODE
  {
   IND_MODE_IND,        // Two stochastics
   IND_MODE_DIV         // Stoch1/Stoch2 divergence
  };
//---
enum ENUM_TYPE_SMOOTH_K
  {
   TYPE_SMOOTH_K_SMA    =  MODE_SMA,      // Simple
   TYPE_SMOOTH_K_EMA    =  MODE_EMA,      // Exponential
   TYPE_SMOOTH_K_FAST   =  2              // Fast
  };
//---
enum ENUM_TYPE_SMOOTH_D
  {
   TYPE_SMOOTH_D_SMA    =  MODE_SMA,      // Simple
   TYPE_SMOOTH_D_EMA    =  MODE_EMA       // Exponential
  };
//--- input parameters
input ENUM_IND_MODE        InpMode        =  IND_MODE_DIV;        // Calculation mode
input uint                 InpPeriodK1    =  5;                   // First stochastic %K period
input uint                 InpPeriodD1    =  3;                   // First stochastic %D period
input uint                 InpSlowing1    =  3;                   // First stochastic slowing
input ENUM_TYPE_SMOOTH_K   InpMethodK1    =  TYPE_SMOOTH_K_SMA;   // First stochastic %K-smoothing type
input ENUM_TYPE_SMOOTH_D   InpMethodD1    =  TYPE_SMOOTH_D_SMA;   // First stochastic %D-smoothing type
input uint                 InpPeriodK2    =  21;                  // Second stochastic %K period
input uint                 InpPeriodD2    =  14;                  // Second stochastic %D period
input uint                 InpSlowing2    =  2;                   // Second stochastic slowing
input ENUM_TYPE_SMOOTH_K   InpMethodK2    =  TYPE_SMOOTH_K_SMA;   // Second stochastic %K-smoothing type
input ENUM_TYPE_SMOOTH_D   InpMethodD2    =  TYPE_SMOOTH_D_SMA;   // Second stochastic %D-smoothing type
input double               InpOverbought  =  80.0;                // Overbought
input double               InpOversold    =  20.0;                // Oversold
//--- indicator buffers
double         BufferSK1[];
double         BufferSD1[];
double         BufferSK2[];
double         BufferSD2[];
double         BufferDivergence[];
double         BufferColors[];
double         BufferMin1[];
double         BufferMax1[];
double         BufferFastK1[];
double         BufferMin2[];
double         BufferMax2[];
double         BufferFastK2[];
//--- global variables
double         overbought;
double         oversold;
int            periodK1;
int            periodK2;
int            periodD1;
int            periodD2;
int            slowing1;
int            slowing2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   periodK1=int(InpPeriodK1<1 ? 1 : InpPeriodK1);
   periodD1=int(InpPeriodD1<1 ? 1 : InpPeriodD1);
   slowing1=int(InpSlowing1<1 ? 1 : InpSlowing1);
   periodK2=int(InpPeriodK2<1 ? 1 : InpPeriodK2);
   periodD2=int(InpPeriodD2<1 ? 1 : InpPeriodD2);
   slowing2=int(InpSlowing2<1 ? 1 : InpSlowing2);
   overbought=(InpOverbought>100 ? 100 : InpOverbought<0.1 ? 0.1 : InpOverbought);
   oversold=(InpOversold<0 ? 0 : InpOversold>=overbought ? overbought-0.1 : InpOversold);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSK1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSD1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSK2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSD2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferDivergence,INDICATOR_DATA);
   SetIndexBuffer(5,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,BufferMax1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferMax2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMin1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMin2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferFastK1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferFastK2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   string label=
     (
      InpMode==IND_MODE_IND ? "Stochastic("+(string)periodK1+","+(string)periodD1+","+(string)slowing1+")"+", Stochastic("+(string)periodK2+","+(string)periodD2+","+(string)slowing2+")" :
      "Convergence/Divergence between Stoch("+(string)periodK1+","+(string)periodD1+","+(string)slowing1+")"+", Stoch("+(string)periodK2+","+(string)periodD2+","+(string)slowing2+")"
     );
   IndicatorSetString(INDICATOR_SHORTNAME,label);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overbought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,oversold);
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Overbought");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Oversold");
//--- setting plot buffer parameters
   if(InpMode==IND_MODE_IND)
     {
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
      PlotIndexSetInteger(3,PLOT_SHOW_DATA,true);
      PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
     }
   else
     {
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_COLOR_LINE);
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
      PlotIndexSetInteger(4,PLOT_SHOW_DATA,true);
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSK1,true);
   ArraySetAsSeries(BufferSD1,true);
   ArraySetAsSeries(BufferSK2,true);
   ArraySetAsSeries(BufferSD2,true);
   ArraySetAsSeries(BufferDivergence,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMax1,true);
   ArraySetAsSeries(BufferMax2,true);
   ArraySetAsSeries(BufferMin1,true);
   ArraySetAsSeries(BufferMin2,true);
   ArraySetAsSeries(BufferFastK1,true);
   ArraySetAsSeries(BufferFastK2,true);
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
//--- Проверка количества доступных баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSK1,EMPTY_VALUE);
      ArrayInitialize(BufferSD1,EMPTY_VALUE);
      ArrayInitialize(BufferSK2,EMPTY_VALUE);
      ArrayInitialize(BufferSD2,EMPTY_VALUE);
      ArrayInitialize(BufferDivergence,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferMax1,0);
      ArrayInitialize(BufferMax2,0);
      ArrayInitialize(BufferMin1,0);
      ArrayInitialize(BufferMin2,0);
      ArrayInitialize(BufferFastK1,0);
      ArrayInitialize(BufferFastK2,0);
     }
     
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      DataPreparing(rates_total,i,periodK1,close,BufferMin1,BufferMax1,BufferFastK1);
      DataPreparing(rates_total,i,periodK2,close,BufferMin2,BufferMax2,BufferFastK2);
      
      CalculateSK(rates_total,i,InpMethodK1,periodK1,slowing1,BufferMin1,BufferMax1,BufferFastK1,BufferSK1);
      CalculateSK(rates_total,i,InpMethodK2,periodK2,slowing2,BufferMin2,BufferMax2,BufferFastK2,BufferSK2);
      if(InpMethodD1==TYPE_SMOOTH_D_SMA)
        {
         BufferSD1[i]=GetSMA(rates_total,BufferSK1,periodD1,i);
         BufferSD2[i]=GetSMA(rates_total,BufferSK2,periodD2,i);
        }
      else
        {
         BufferSD1[i]=GetEMA(rates_total,BufferSK1[i],BufferSD1[i+1],periodD1,i);  
         BufferSD2[i]=GetEMA(rates_total,BufferSK2[i],BufferSD2[i+1],periodD2,i);  
        }
      BufferDivergence[i]=BufferSK1[i]-BufferSK2[i]+50.0;
      BufferColors[i]=(BufferDivergence[i]>50 ? 0 : BufferDivergence[i]<50 ? 1 : 2);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
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
void CalculateSK(const int rates_total,const int shift,const ENUM_TYPE_SMOOTH_K type_smK,const int period_k,const int slowing,double &buffer_min[],const double &buffer_max[],const double &buffer_fast[],double &buffer_sk[])
  {
   double sum_max=0,sum_min=0;
   if(type_smK==TYPE_SMOOTH_K_FAST)
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
      if(type_smK==TYPE_SMOOTH_K_SMA)
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

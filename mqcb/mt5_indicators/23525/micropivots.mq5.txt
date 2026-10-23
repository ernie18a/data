//+------------------------------------------------------------------+
//|                                                  MicroPivots.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Micro Pivots"
#property description "Shows selected Fibonacci levels between two moving averages"
#property indicator_chart_window
#property indicator_buffers 17
#property indicator_plots   15
//--- plot MA1
#property indicator_label1  "MA 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot MA2
#property indicator_label2  "MA 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Level1
#property indicator_label3  "Level 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Level2
#property indicator_label4  "Level 2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Level3
#property indicator_label5  "Level 3"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Level4
#property indicator_label6  "Level 4"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrDarkGray
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Level5
#property indicator_label7  "Level 5"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkGray
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Level6
#property indicator_label8  "Level 6"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDarkGray
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot Level7
#property indicator_label9  "Level 7"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrDarkGray
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot Level8
#property indicator_label10 "Level 8"
#property indicator_type10  DRAW_LINE
#property indicator_color10 clrDarkGray
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
//--- plot Level9
#property indicator_label11 "Level 9"
#property indicator_type11  DRAW_LINE
#property indicator_color11 clrDarkGray
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
//--- plot Level10
#property indicator_label12 "Level 10"
#property indicator_type12  DRAW_LINE
#property indicator_color12 clrDarkGray
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
//--- plot Level11
#property indicator_label13 "Level 11"
#property indicator_type13  DRAW_LINE
#property indicator_color13 clrDarkGray
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1
//--- plot Level12
#property indicator_label14 "Level 12"
#property indicator_type14  DRAW_LINE
#property indicator_color14 clrDarkGray
#property indicator_style14 STYLE_SOLID
#property indicator_width14 1
//--- plot Level13
#property indicator_label15 "Level 13"
#property indicator_type15  DRAW_LINE
#property indicator_color15 clrDarkGray
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
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
input uint                 InpPeriodMA1      =  30;            // First MA period
input ENUM_MA_MODE         InpMethod1        =  METHOD_SMA;    // First MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;   // First MA applied price
input uint                 InpPeriodMA2      =  100;           // Second MA period
input ENUM_MA_MODE         InpMethod2        =  METHOD_SMA;    // Second MA method
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_CLOSE;   // Second MA applied price
input ENUM_INPUT_YES_NO    InpShowLevel1     =  INPUT_YES;     // Show Fibo-level 1
input double               InpValueLevel1    = -423.6;         // Fibo-level 1 value
input ENUM_INPUT_YES_NO    InpShowLevel2     =  INPUT_YES;     // Show Fibo-level 2
input double               InpValueLevel2    = -261.8;         // Fibo-level 2 value
input ENUM_INPUT_YES_NO    InpShowLevel3     =  INPUT_YES;     // Show Fibo-level 3
input double               InpValueLevel3    = -81.8;          // Fibo-level 3 value
input ENUM_INPUT_YES_NO    InpShowLevel4     =  INPUT_YES;     // Show Fibo-level 4
input double               InpValueLevel4    = -27.1;          // Fibo-level 4 value
input ENUM_INPUT_YES_NO    InpShowLevel5     =  INPUT_YES;     // Show Fibo-level 5
input double               InpValueLevel5    =  23.6;          // Fibo-level 5 value
input ENUM_INPUT_YES_NO    InpShowLevel6     =  INPUT_YES;     // Show Fibo-level 6
input double               InpValueLevel6    =  38.5;          // Fibo-level 6 value
input ENUM_INPUT_YES_NO    InpShowLevel7     =  INPUT_YES;     // Show Fibo-level 7
input double               InpValueLevel7    =  50.0;          // Fibo-level 7 value
input ENUM_INPUT_YES_NO    InpShowLevel8     =  INPUT_YES;     // Show Fibo-level 8
input double               InpValueLevel8    =  61.8;          // Fibo-level 8 value
input ENUM_INPUT_YES_NO    InpShowLevel9     =  INPUT_YES;     // Show Fibo-level 9
input double               InpValueLevel9    =  76.4;          // Fibo-level 9 value
input ENUM_INPUT_YES_NO    InpShowLevel10    =  INPUT_YES;     // Show Fibo-level 10
input double               InpValueLevel10   =  127.2;         // Fibo-level 10 value
input ENUM_INPUT_YES_NO    InpShowLevel11    =  INPUT_YES;     // Show Fibo-level 11
input double               InpValueLevel11   =  161.8;         // Fibo-level 11 value
input ENUM_INPUT_YES_NO    InpShowLevel12    =  INPUT_YES;     // Show Fibo-level 12
input double               InpValueLevel12   =  261.8;         // Fibo-level 12 value
input ENUM_INPUT_YES_NO    InpShowLevel13    =  INPUT_YES;     // Show Fibo-level 13
input double               InpValueLevel13   =  423.6;         // Fibo-level 13 value
//--- indicator buffers
double         BufferMA1[];
double         BufferMA2[];
double         BufferLevel1[];
double         BufferLevel2[];
double         BufferLevel3[];
double         BufferLevel4[];
double         BufferLevel5[];
double         BufferLevel6[];
double         BufferLevel7[];
double         BufferLevel8[];
double         BufferLevel9[];
double         BufferLevel10[];
double         BufferLevel11[];
double         BufferLevel12[];
double         BufferLevel13[];
double         BufferPrice1[];
double         BufferPrice2[];
//--- global variables
double         level1;
double         level2;
double         level3;
double         level4;
double         level5;
double         level6;
double         level7;
double         level8;
double         level9;
double         level10;
double         level11;
double         level12;
double         level13;
int            period_ma1;
int            period_ma2;
int            period_max;
int            handle_ma1;
int            handle_ma2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
   period_max=fmax(period_ma1,period_ma2);
   level1=InpValueLevel1;
   level2=InpValueLevel2;
   level3=InpValueLevel3;
   level4=InpValueLevel4;
   level5=InpValueLevel5;
   level6=InpValueLevel6;
   level7=InpValueLevel7;
   level8=InpValueLevel8;
   level9=InpValueLevel9;
   level10=InpValueLevel10;
   level11=InpValueLevel11;
   level12=InpValueLevel12;
   level13=InpValueLevel13;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA1,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA2,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLevel1,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLevel2,INDICATOR_DATA);
   SetIndexBuffer(4,BufferLevel3,INDICATOR_DATA);
   SetIndexBuffer(5,BufferLevel4,INDICATOR_DATA);
   SetIndexBuffer(6,BufferLevel5,INDICATOR_DATA);
   SetIndexBuffer(7,BufferLevel6,INDICATOR_DATA);
   SetIndexBuffer(8,BufferLevel7,INDICATOR_DATA);
   SetIndexBuffer(9,BufferLevel8,INDICATOR_DATA);
   SetIndexBuffer(10,BufferLevel9,INDICATOR_DATA);
   SetIndexBuffer(11,BufferLevel10,INDICATOR_DATA);
   SetIndexBuffer(12,BufferLevel11,INDICATOR_DATA);
   SetIndexBuffer(13,BufferLevel12,INDICATOR_DATA);
   SetIndexBuffer(14,BufferLevel13,INDICATOR_DATA);
   SetIndexBuffer(15,BufferPrice1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,BufferPrice2,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MicroPivots ("+(string)period_ma1+", "+(string)period_ma2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(10,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(11,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(12,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(13,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(14,PLOT_DRAW_BEGIN,period_max);
   
   PlotIndexSetString(0,PLOT_LABEL,"MP MA1 ("+(string)period_ma1+")");
   PlotIndexSetString(1,PLOT_LABEL,"MP MA2 ("+(string)period_ma2+")");
   PlotIndexSetString(2,PLOT_LABEL,"Fibo1 ("+DoubleToString(level1,1)+")");
   PlotIndexSetString(3,PLOT_LABEL,"Fibo2 ("+DoubleToString(level2,1)+")");
   PlotIndexSetString(4,PLOT_LABEL,"Fibo3 ("+DoubleToString(level3,1)+")");
   PlotIndexSetString(5,PLOT_LABEL,"Fibo4 ("+DoubleToString(level4,1)+")");
   PlotIndexSetString(6,PLOT_LABEL,"Fibo5 ("+DoubleToString(level5,1)+")");
   PlotIndexSetString(7,PLOT_LABEL,"Fibo6 ("+DoubleToString(level6,1)+")");
   PlotIndexSetString(8,PLOT_LABEL,"Fibo7 ("+DoubleToString(level7,1)+")");
   PlotIndexSetString(9,PLOT_LABEL,"Fibo8 ("+DoubleToString(level8,1)+")");
   PlotIndexSetString(10,PLOT_LABEL,"Fibo9 ("+DoubleToString(level9,1)+")");
   PlotIndexSetString(11,PLOT_LABEL,"Fibo10 ("+DoubleToString(level10,1)+")");
   PlotIndexSetString(12,PLOT_LABEL,"Fibo11 ("+DoubleToString(level11,1)+")");
   PlotIndexSetString(13,PLOT_LABEL,"Fibo12 ("+DoubleToString(level12,1)+")");
   PlotIndexSetString(14,PLOT_LABEL,"Fibo13 ("+DoubleToString(level13,1)+")");

   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,InpShowLevel1);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,InpShowLevel2);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,InpShowLevel3);
   PlotIndexSetInteger(5,PLOT_DRAW_TYPE,InpShowLevel4);
   PlotIndexSetInteger(6,PLOT_DRAW_TYPE,InpShowLevel5);
   PlotIndexSetInteger(7,PLOT_DRAW_TYPE,InpShowLevel6);
   PlotIndexSetInteger(8,PLOT_DRAW_TYPE,InpShowLevel7);
   PlotIndexSetInteger(9,PLOT_DRAW_TYPE,InpShowLevel8);
   PlotIndexSetInteger(10,PLOT_DRAW_TYPE,InpShowLevel9);
   PlotIndexSetInteger(11,PLOT_DRAW_TYPE,InpShowLevel10);
   PlotIndexSetInteger(12,PLOT_DRAW_TYPE,InpShowLevel11);
   PlotIndexSetInteger(13,PLOT_DRAW_TYPE,InpShowLevel12);
   PlotIndexSetInteger(14,PLOT_DRAW_TYPE,InpShowLevel13);
   
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferLevel1,true);
   ArraySetAsSeries(BufferLevel2,true);
   ArraySetAsSeries(BufferLevel3,true);
   ArraySetAsSeries(BufferLevel4,true);
   ArraySetAsSeries(BufferLevel5,true);
   ArraySetAsSeries(BufferLevel6,true);
   ArraySetAsSeries(BufferLevel7,true);
   ArraySetAsSeries(BufferLevel8,true);
   ArraySetAsSeries(BufferLevel9,true);
   ArraySetAsSeries(BufferLevel10,true);
   ArraySetAsSeries(BufferLevel11,true);
   ArraySetAsSeries(BufferLevel12,true);
   ArraySetAsSeries(BufferLevel13,true);
   ArraySetAsSeries(BufferPrice1,true);
   ArraySetAsSeries(BufferPrice2,true);
//--- create MA's handles
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferLevel1,0);
      ArrayInitialize(BufferLevel2,0);
      ArrayInitialize(BufferLevel3,0);
      ArrayInitialize(BufferLevel4,0);
      ArrayInitialize(BufferLevel5,0);
      ArrayInitialize(BufferLevel6,0);
      ArrayInitialize(BufferLevel7,0);
      ArrayInitialize(BufferLevel8,0);
      ArrayInitialize(BufferLevel9,0);
      ArrayInitialize(BufferLevel10,0);
      ArrayInitialize(BufferLevel11,0);
      ArrayInitialize(BufferLevel12,0);
      ArrayInitialize(BufferLevel13,0);
      ArrayInitialize(BufferPrice1,0);
      ArrayInitialize(BufferPrice2,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferPrice1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferPrice2);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
   //--- Расчёт MA 1
      switch(InpMethod1)
        {
         case METHOD_EMA            : BufferMA1[i] = EMA(rates_total,BufferPrice1[i],BufferMA1[i+1],period_ma1,i);      break;
         case METHOD_SMMA           : BufferMA1[i] = SMMA(rates_total,BufferPrice1,BufferMA1[i+1],period_ma1,i);        break;
         case METHOD_LWMA           : BufferMA1[i] = LWMA(rates_total,BufferPrice1,period_ma1,i);                       break;
         case METHOD_WILDER_EMA     : BufferMA1[i] = Wilder(rates_total,BufferPrice1[i],BufferMA1[i+1],period_ma1,i);   break;
         case METHOD_SINE_WMA       : BufferMA1[i] = SineWMA(rates_total,BufferPrice1,period_ma1,i);                    break;
         case METHOD_TRI_MA         : BufferMA1[i] = TriMA(rates_total,BufferPrice1,period_ma1,i);                      break;
         case METHOD_LSMA           : BufferMA1[i] = LSMA(rates_total,BufferPrice1,period_ma1,i);                       break;
         case METHOD_HMA            : BufferMA1[i] = HMA(rates_total,BufferPrice1,period_ma1,i);                        break;
         case METHOD_ZL_EMA         : BufferMA1[i] = ZeroLagEMA(rates_total,BufferPrice1,BufferMA1[i+1],period_ma1,i);  break;
         case METHOD_ITREND_MA      : BufferMA1[i] = ITrend(rates_total,BufferPrice1,BufferMA1,period_ma1,i);           break;
         case METHOD_MOVING_MEDIAN  : BufferMA1[i] = Median(rates_total,BufferPrice1,period_ma1,i);                     break;
         case METHOD_GEO_MEAN       : BufferMA1[i] = GeoMean(rates_total,BufferPrice1,period_ma1,i);                    break;
         case METHOD_REMA           : BufferMA1[i] = REMA(rates_total,BufferPrice1[i],BufferMA1,period_ma1,0.5,i);      break;
         case METHOD_ILRS           : BufferMA1[i] = ILRS(rates_total,BufferPrice1,period_ma1,i);                       break;
         case METHOD_IE_2           : BufferMA1[i] = IE2(rates_total,BufferPrice1,period_ma1,i);                        break;
         case METHOD_TRI_MA_GEN     : BufferMA1[i] = TriMA_gen(rates_total,BufferPrice1,period_ma1,i);                  break;
         case METHOD_VWMA           : BufferMA1[i] = VWMA(rates_total,BufferPrice1,tick_volume,period_ma1,i);           break;
         default /*METHOD_SMA*/     : BufferMA1[i] = SMA(rates_total,BufferPrice1,period_ma1,i);                        break;
        }
   //--- Расчёт MA 2
      switch(InpMethod2)
        {
         case METHOD_EMA            : BufferMA2[i] = EMA(rates_total,BufferPrice2[i],BufferMA2[i+1],period_ma2,i);      break;
         case METHOD_SMMA           : BufferMA2[i] = SMMA(rates_total,BufferPrice2,BufferMA2[i+1],period_ma2,i);        break;
         case METHOD_LWMA           : BufferMA2[i] = LWMA(rates_total,BufferPrice2,period_ma2,i);                       break;
         case METHOD_WILDER_EMA     : BufferMA2[i] = Wilder(rates_total,BufferPrice2[i],BufferMA2[i+1],period_ma2,i);   break;
         case METHOD_SINE_WMA       : BufferMA2[i] = SineWMA(rates_total,BufferPrice2,period_ma2,i);                    break;
         case METHOD_TRI_MA         : BufferMA2[i] = TriMA(rates_total,BufferPrice2,period_ma2,i);                      break;
         case METHOD_LSMA           : BufferMA2[i] = LSMA(rates_total,BufferPrice2,period_ma2,i);                       break;
         case METHOD_HMA            : BufferMA2[i] = HMA(rates_total,BufferPrice2,period_ma2,i);                        break;
         case METHOD_ZL_EMA         : BufferMA2[i] = ZeroLagEMA(rates_total,BufferPrice2,BufferMA2[i+1],period_ma2,i);  break;
         case METHOD_ITREND_MA      : BufferMA2[i] = ITrend(rates_total,BufferPrice2,BufferMA2,period_ma2,i);           break;
         case METHOD_MOVING_MEDIAN  : BufferMA2[i] = Median(rates_total,BufferPrice2,period_ma2,i);                     break;
         case METHOD_GEO_MEAN       : BufferMA2[i] = GeoMean(rates_total,BufferPrice2,period_ma2,i);                    break;
         case METHOD_REMA           : BufferMA2[i] = REMA(rates_total,BufferPrice2[i],BufferMA2,period_ma2,0.5,i);      break;
         case METHOD_ILRS           : BufferMA2[i] = ILRS(rates_total,BufferPrice2,period_ma2,i);                       break;
         case METHOD_IE_2           : BufferMA2[i] = IE2(rates_total,BufferPrice2,period_ma2,i);                        break;
         case METHOD_TRI_MA_GEN     : BufferMA2[i] = TriMA_gen(rates_total,BufferPrice2,period_ma2,i);                  break;
         case METHOD_VWMA           : BufferMA2[i] = VWMA(rates_total,BufferPrice2,tick_volume,period_ma2,i);           break;
         default /*METHOD_SMA*/     : BufferMA2[i] = SMA(rates_total,BufferPrice2,period_ma2,i);                        break;
        }
   //--- Расчёт уровней
      double abs=(BufferMA1[i]>BufferMA2[i] ? fabs(BufferMA1[i]-BufferMA2[i]) : -fabs(BufferMA1[i]-BufferMA2[i]));
      BufferLevel1[i]  = BufferMA2[i] + abs*(level1/100.0);
      BufferLevel2[i]  = BufferMA2[i] + abs*(level2/100.0);
      BufferLevel3[i]  = BufferMA2[i] + abs*(level3/100.0);
      BufferLevel4[i]  = BufferMA2[i] + abs*(level4/100.0);
      BufferLevel5[i]  = BufferMA2[i] + abs*(level5/100.0);
      BufferLevel6[i]  = BufferMA2[i] + abs*(level6/100.0);
      BufferLevel7[i]  = BufferMA2[i] + abs*(level7/100.0);
      BufferLevel8[i]  = BufferMA2[i] + abs*(level8/100.0);
      BufferLevel9[i]  = BufferMA2[i] + abs*(level9/100.0);
      BufferLevel10[i] = BufferMA2[i] + abs*(level10/100.0);
      BufferLevel11[i] = BufferMA2[i] + abs*(level11/100.0);
      BufferLevel12[i] = BufferMA2[i] + abs*(level12/100.0);
      BufferLevel13[i] = BufferMA2[i] + abs*(level13/100.0);
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

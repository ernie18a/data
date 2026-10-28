//+------------------------------------------------------------------+
//|                                        Slope_MA_Confirmation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slope Direction Line / Moving Average confirmation candles indicator"
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   3
//--- plot Candle
#property indicator_label1  "Candle"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrDarkSeaGreen,clrRed,clrTan,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Slope
#property indicator_label2  "Slope trend"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGreen,clrRed,clrDarkGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot MA
#property indicator_label3  "MA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriodMA          =  50;            // MA period
input ENUM_MA_METHOD       InpMethodMA          =  MODE_SMA;      // MA method
input ENUM_APPLIED_PRICE   InpAppliedPriceMA    =  PRICE_CLOSE;   // MA applied price
input uint                 InpPeriodSlope       =  50;            // SDL period
input ENUM_MA_METHOD       InpMethodSlope       =  MODE_SMA;      // SDL method
input ENUM_APPLIED_PRICE   InpAppliedPriceSlope =  PRICE_CLOSE;   // SDL applied price
//--- indicator buffers
double         BufferCandleO[];
double         BufferCandleH[];
double         BufferCandleL[];
double         BufferCandleC[];
double         BufferCandleColors[];
double         BufferSlope[];
double         BufferSlopeColors[];
double         BufferMA[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferVect[];
//--- global variables
int            period_slope;
int            period_slope2;
int            period_sqrt;
int            period_ma;
int            period_max;
int            weight_sum;
int            handle_ma;
int            handle_ma1;
int            handle_ma2;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriodMA<1 ? 1 : InpPeriodMA);
   period_slope=int(InpPeriodSlope<2 ? 2 : InpPeriodSlope);
   period_slope2=int(floor(period_slope/2));
   period_sqrt=int(floor(sqrt(period_slope)));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleH,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleL,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleC,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferSlope,INDICATOR_DATA);
   SetIndexBuffer(6,BufferSlopeColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(8,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferVect,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Slope/MA candles ("+(string)period_slope+","+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetString(1,PLOT_LABEL,MethodToString(InpMethodSlope)+" SDL");
   PlotIndexSetString(2,PLOT_LABEL,MethodToString(InpMethodMA));
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleO,true);
   ArraySetAsSeries(BufferCandleH,true);
   ArraySetAsSeries(BufferCandleL,true);
   ArraySetAsSeries(BufferCandleC,true);
   ArraySetAsSeries(BufferCandleColors,true);
   ArraySetAsSeries(BufferSlope,true);
   ArraySetAsSeries(BufferSlopeColors,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferVect,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethodMA,InpAppliedPriceMA);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_slope,0,InpMethodSlope,InpAppliedPriceSlope);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slope,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_slope2,0,InpMethodSlope,InpAppliedPriceSlope);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_slope2,") object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_slope,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCandleO,EMPTY_VALUE);
      ArrayInitialize(BufferCandleH,EMPTY_VALUE);
      ArrayInitialize(BufferCandleL,EMPTY_VALUE);
      ArrayInitialize(BufferCandleC,EMPTY_VALUE);
      ArrayInitialize(BufferCandleColors,4);
      ArrayInitialize(BufferSlope,EMPTY_VALUE);
      ArrayInitialize(BufferSlopeColors,2);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferVect,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferVect[i]=2.0*BufferMA2[i]-BufferMA1[i];
     
//--- Расчёт индикатора
   switch(InpMethodSlope)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope,weight_sum)==0) return 0;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_slope,period_sqrt,BufferVect,BufferSlope)==0) return 0;
     }
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCandleO[i]=BufferCandleH[i]=BufferCandleL[i]=BufferCandleC[i]=EMPTY_VALUE;
      if(BufferSlope[i]>BufferSlope[i+1])
        {
         BufferSlopeColors[i]=0;
         if(BufferMA[i]>BufferMA[i+1])
           {
            BufferCandleO[i]=open[i];
            BufferCandleH[i]=high[i];
            BufferCandleL[i]=low[i];
            BufferCandleC[i]=close[i];
            BufferCandleColors[i]=(open[i]<close[i] ? 0 : open[i]>close[i] ? 1 : 4);
           }
        }
      else if(BufferSlope[i]<BufferSlope[i+1])
        {
         BufferSlopeColors[i]=1;
         if(BufferMA[i]<BufferMA[i+1])
           {
            BufferCandleO[i]=open[i];
            BufferCandleH[i]=high[i];
            BufferCandleL[i]=low[i];
            BufferCandleC[i]=close[i];
            BufferCandleColors[i]=(open[i]>close[i] ? 2 : open[i]<close[i] ? 3 : 4);
           }
        }
      else
        {
         BufferSlopeColors[i]=3;
         BufferCandleO[i]=BufferCandleH[i]=BufferCandleL[i]=BufferCandleC[i]=EMPTY_VALUE;
         BufferCandleColors[i]=4;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование метода МА                                |
//+------------------------------------------------------------------+
string MethodToString(ENUM_MA_METHOD method)
  {
   return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+

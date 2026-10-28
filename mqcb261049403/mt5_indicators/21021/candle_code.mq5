//+------------------------------------------------------------------+
//|                                                  Candle_Code.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Candle Codes indicator"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   3
//--- plot One
#property indicator_label1  "One smoothing"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Two
#property indicator_label2  "Two smoothing"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Raw
#property indicator_label3  "Weights Data"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_WEIGHTS
  {
   WEIGHT_0    =  0,    // 0
   WEIGHT_1    =  1,    // 1
   WEIGHT_2    =  2,    // 2
   WEIGHT_4    =  4,    // 4
   WEIGHT_8    =  8,    // 8
   WEIGHT_16   =  16,   // 16
   WEIGHT_32   =  32,   // 32
   WEIGHT_64   =  64,   // 64
   WEIGHT_128  =  128,  // 128
   WEIGHT_256  =  256,  // 256
   WEIGHT_512  =  512   // 512
  };
//---
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input ENUM_WEIGHTS      InpWeightBodySize    =  WEIGHT_32;  // Body size weight
input ENUM_WEIGHTS      InpWeightUpperShadow =  WEIGHT_16;  // Upper shadow weight
input ENUM_WEIGHTS      InpWeightLowerShadow =  WEIGHT_16;  // Lower shadow weight
input ENUM_WEIGHTS      InpWeightDirection   =  WEIGHT_32;  // Candle direction weight
input ENUM_WEIGHTS      InpWeightGap         =  WEIGHT_8;   // Gap weight
input ENUM_INPUT_YES_NO InpShowData          =  INPUT_NO;   // Show data
input uint              InpPeriodMA1         =  21;         // First MA period
input ENUM_MA_METHOD    InpMethodMA1         =  MODE_SMA;   // First MA method
input uint              InpPeriodMA2         =  3;          // Second MA period
input ENUM_MA_METHOD    InpMethodMA2         =  MODE_SMA;   // Second MA method
//--- indicator buffers
double         BufferOne[];
double         BufferTwo[];
double         BufferRaw[];
double         BufferRawBody[];
double         BufferRawUpper[];
double         BufferRawLower[];
double         BufferRawGap[];
double         BufferOpen[];
double         BufferHigh[];
double         BufferLow[];
double         BufferClose[];
//--- global variables
int            period_ma1;
int            period_ma2;
int            handle_open;
int            handle_high;
int            handle_low;
int            handle_close;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma1=int(InpPeriodMA1<2 ? 2 : InpPeriodMA1);
   period_ma2=int(InpPeriodMA2<2 ? 2 : InpPeriodMA2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferOne,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTwo,INDICATOR_DATA);
   SetIndexBuffer(2,BufferRaw,INDICATOR_DATA);
   SetIndexBuffer(3,BufferRawBody,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferRawUpper,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRawLower,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferRawGap,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferLow,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferClose,INDICATOR_CALCULATIONS);
//--- setting plot buffer parameters
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,(InpShowData ? DRAW_LINE : DRAW_NONE));
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Candle Codes (weights: "+(string)InpWeightBodySize+","+(string)InpWeightUpperShadow+","+(string)InpWeightLowerShadow+","+(string)InpWeightDirection+","+(string)InpWeightGap+", periods: "+(string)period_ma1+","+(string)period_ma2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferOne,true);
   ArraySetAsSeries(BufferTwo,true);
   ArraySetAsSeries(BufferRaw,true);
   ArraySetAsSeries(BufferRawBody,true);
   ArraySetAsSeries(BufferRawUpper,true);
   ArraySetAsSeries(BufferRawLower,true);
   ArraySetAsSeries(BufferRawGap,true);
   ArraySetAsSeries(BufferOpen,true);
   ArraySetAsSeries(BufferHigh,true);
   ArraySetAsSeries(BufferLow,true);
   ArraySetAsSeries(BufferClose,true);
//--- create MA's handles
   ResetLastError();
   handle_open=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_OPEN);
   if(handle_open==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_OPEN object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_high=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_HIGH);
   if(handle_high==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_HIGH object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_low=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_LOW);
   if(handle_low==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_LOW object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_close=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_CLOSE);
   if(handle_close==INVALID_HANDLE)
     {
      Print("The iMA(1) by PRICE_CLOSE object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferOne,EMPTY_VALUE);
      ArrayInitialize(BufferTwo,EMPTY_VALUE);
      ArrayInitialize(BufferRaw,EMPTY_VALUE);
      ArrayInitialize(BufferRawBody,0);
      ArrayInitialize(BufferRawUpper,0);
      ArrayInitialize(BufferRawLower,0);
      ArrayInitialize(BufferRawGap,0);
      ArrayInitialize(BufferOpen,0);
      ArrayInitialize(BufferHigh,0);
      ArrayInitialize(BufferLow,0);
      ArrayInitialize(BufferClose,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_open,0,0,count,BufferOpen);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_high,0,0,count,BufferHigh);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_low,0,0,count,BufferLow);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_close,0,0,count,BufferClose);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRawBody[i]=fabs(BufferClose[i]-BufferOpen[i]);
      BufferRawUpper[i]=BufferHigh[i]-fmax(BufferClose[i],BufferOpen[i]);
      BufferRawLower[i]=fmin(BufferClose[i],BufferOpen[i])-BufferLow[i];
      BufferRawGap[i]=BufferOpen[i]-BufferClose[i+1];
     }
   double AvgShadow=(SMAOnArray(BufferRawLower,0,rates_total-2,0,0)+SMAOnArray(BufferRawUpper,0,rates_total-2,0,0))/2.0;
   double AvgBodySize=SMAOnArray(BufferRawBody,0,rates_total-2,0,0);
   double AvgGap=SMAOnArray(BufferRawGap,0,rates_total-2,0,0);
   
   double BodySize,UpperShadow,LowerShadow,Gap,Direction;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BodySize=
        (
         fabs(BufferClose[i]-BufferOpen[i])>=AvgBodySize*2.0 ? InpWeightBodySize : 
         InpWeightBodySize*fabs(BufferClose[i]-BufferOpen[i])/(2.0*AvgBodySize)
        );
      UpperShadow=
        (
         BufferHigh[i]-fmax(BufferClose[i],BufferOpen[i])>=AvgShadow*2.0 ? InpWeightUpperShadow : 
         InpWeightUpperShadow*(BufferHigh[i]-fmax(BufferClose[i],BufferOpen[i]))/(2.0*AvgShadow)
        );
      LowerShadow=
        (
         fmin(BufferClose[i],BufferOpen[i])-BufferLow[i]>=AvgShadow*2.0 ? InpWeightLowerShadow : 
         InpWeightLowerShadow*(fmin(BufferClose[i],BufferOpen[i])-BufferLow[i])/(2.0*AvgShadow)
        );
      Gap=InpWeightGap*(BufferOpen[i]-BufferClose[i+1])/AvgGap;
      Direction=
        (
         BufferClose[i]>BufferOpen[i] ? InpWeightDirection : 
         BufferClose[i]<BufferOpen[i] ? -1.0*InpWeightDirection : 0
        );
      BufferRaw[i]=Direction+BodySize+UpperShadow+LowerShadow+Gap;
     }
//--- Расчёт индикатора
   switch(InpMethodMA1)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma1,BufferRaw,BufferOne);                        break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma1,BufferRaw,BufferOne);                           break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma1,BufferRaw,BufferOne,weight_sum);          break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,0,period_ma1,BufferRaw,BufferOne);                             break;
     }
   switch(InpMethodMA2)
     {
      case MODE_EMA  :  ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferOne,BufferTwo);               break;
      case MODE_SMMA :  SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferOne,BufferTwo);                  break;
      case MODE_LWMA :  LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferOne,BufferTwo,weight_sum); break;
      //---MODE_SMA
      default        :  SimpleMAOnBuffer(rates_total,prev_calculated,period_ma1,period_ma2,BufferOne,BufferTwo);                    break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double SMAOnArray(double &array[],int total,int period,int ma_shift,int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
//---
   total=ArrayCopy(arr,array,0,shift+ma_shift,period);
   if(ArrayResize(buf,total)<0) return(0);
   double sum=0;
   int    i,pos=total-1;
   for(i=1;i<period;i++,pos--)
      sum+=arr[pos];
   while(pos>=0)
     {
      sum+=arr[pos];
      buf[pos]=sum/period;
      sum-=arr[pos+period-1];
      pos--;
     }
   return buf[0];
  }
//+------------------------------------------------------------------+

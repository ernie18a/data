//+------------------------------------------------------------------+
//|                                         Slope_Direction_Line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Slope Direction Line indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot SDL
#property indicator_label1  "SDL"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Trend
#property indicator_label2  "Trend direction"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriod         =  80;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferSDL[];
double         BufferColors[];
double         BufferTrend[];
double         BufferMAP[];
double         BufferMAP2[];
double         BufferRAW[];
//--- global variables
int            period_ma;
int            period2;
int            periodSqrt;
int            handle_maP;
int            handle_maP2;
int            weight_sum;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<2 ? 2 : InpPeriod);
   period2=(int)floor(period_ma/2.0);
   periodSqrt=(int)floor(sqrt(period_ma));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSDL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferTrend,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMAP2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferRAW,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"SDL ("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSDL,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferTrend,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMAP2,true);
   ArraySetAsSeries(BufferRAW,true);
//--- create MA's handles
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP2=iMA(NULL,PERIOD_CURRENT,period2,0,InpMethod,InpAppliedPrice);
   if(handle_maP2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period2,") object was not created: Error ",GetLastError());
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
   if(rates_total<fmax(period_ma,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSDL,EMPTY_VALUE);
      ArrayInitialize(BufferTrend,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMAP2,0);
      ArrayInitialize(BufferRAW,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP2,0,0,count,BufferMAP2);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferRAW[i]=2.0*BufferMAP2[i]-BufferMAP[i];
     }
   switch(InpMethod)
     {
      case MODE_EMA  :  if(ExponentialMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;               break;
      case MODE_SMMA :  if(SmoothedMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;                  break;
      case MODE_LWMA :  if(LinearWeightedMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL,weight_sum)==0) return 0; break;
      //---MODE_SMA
      default        :  if(SimpleMAOnBuffer(rates_total,prev_calculated,period_ma,periodSqrt,BufferRAW,BufferSDL)==0) return 0;                    break;
     }
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTrend[i]=(BufferSDL[i]>BufferSDL[i+1] ? 1 : BufferSDL[i]<BufferSDL[i+1] ? -1 : BufferTrend[i+1]);
      BufferColors[i]=2;
      if(BufferTrend[i]>0)
        {
         BufferColors[i]=0;
         if(BufferTrend[i+1]<0)
            BufferColors[i+1]=0;
        }
      else
        {
         BufferColors[i]=1;
         if(BufferTrend[i+1]>0)
            BufferColors[i+1]=1;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

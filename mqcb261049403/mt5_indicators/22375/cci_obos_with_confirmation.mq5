//+------------------------------------------------------------------+
//|                                   CCI_OBOS_With_Confirmation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "CCI OBOS With Confirmation indicator"
#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots   3
//--- plot Candle
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrSpringGreen,clrRed,clrOrange,clrDodgerBlue,clrDarkGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Up
#property indicator_label2  "Bullish signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Dn
#property indicator_label3  "Bearish signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodOBOS  =  9;          // OBOS period
input uint              InpPeriodCCI   =  14;         // CCI period
input ENUM_INPUT_YES_NO InpColorCandle =  INPUT_NO;   // Color candle
//--- indicator buffers
double         BufferUp[];
double         BufferDn[];
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
double         BufferCCI[];
double         BufferUpOBOS[];
double         BufferDnOBOS[];
double         BufferRAW[];
double         BufferAvgRAW[];
double         BufferPrice[];
double         BufferMA[];
double         BufferDev[];
//--- global variables
int            period_obos;
int            period_cci;
int            handle_ma;
int            handle_dev;
int            handle_cci;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_obos=int(InpPeriodOBOS<1 ? 1 : InpPeriodOBOS);
   period_cci=int(InpPeriodCCI<1 ? 1 : InpPeriodCCI);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferUp,INDICATOR_DATA);
   SetIndexBuffer(6,BufferDn,INDICATOR_DATA);
   SetIndexBuffer(7,BufferCCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferUpOBOS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferDnOBOS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,BufferAvgRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BufferDev,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI OBOS With Confirmation ("+(string)period_obos+","+(string)period_cci+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,InpColorCandle);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferUp,true);
   ArraySetAsSeries(BufferDn,true);
   ArraySetAsSeries(BufferCCI,true);
   ArraySetAsSeries(BufferUpOBOS,true);
   ArraySetAsSeries(BufferDnOBOS,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferAvgRAW,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferDev,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period_obos,0,MODE_EMA,PRICE_WEIGHTED);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_obos,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_obos,0,MODE_EMA,PRICE_WEIGHTED);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_obos,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_cci=iCCI(NULL,PERIOD_CURRENT,period_cci,PRICE_TYPICAL);
   if(handle_cci==INVALID_HANDLE)
     {
      Print("The iCCI(",(string)period_cci,") object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_obos,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferCandleOpen,EMPTY_VALUE);
      ArrayInitialize(BufferCandleHigh,EMPTY_VALUE);
      ArrayInitialize(BufferCandleLow,EMPTY_VALUE);
      ArrayInitialize(BufferCandleClose,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferUp,EMPTY_VALUE);
      ArrayInitialize(BufferDn,EMPTY_VALUE);
      ArrayInitialize(BufferCCI,0);
      ArrayInitialize(BufferUpOBOS,0);
      ArrayInitialize(BufferDnOBOS,0);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferAvgRAW,0);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferDev,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_cci,0,0,count,BufferCCI);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferPrice[i]=(high[i]+low[i]+close[i]+close[i])/4.0;
      BufferRAW[i]=(BufferDev[i]!=0 ?(BufferPrice[i]-BufferMA[i])*100.0/BufferDev[i]: 0);
     }
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_obos,BufferRAW,BufferAvgRAW)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_obos,BufferAvgRAW,BufferUpOBOS)==0)
      return 0;
   if(ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_obos,BufferUpOBOS,BufferDnOBOS)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDn[i]=BufferUp[i]=EMPTY_VALUE;
      double OBOS_H0=fmax(BufferUpOBOS[i],BufferDnOBOS[i]);
      double OBOS_H1=fmax(BufferUpOBOS[i+1],BufferDnOBOS[i+1]);
      double OBOS_L0=fmin(BufferUpOBOS[i],BufferDnOBOS[i]);
      double OBOS_L1=fmin(BufferUpOBOS[i+1],BufferDnOBOS[i+1]);

      if(BufferCCI[i+1]<OBOS_H1 && BufferCCI[i]>OBOS_H0)
        {
         BufferUp[i]=open[i];
        }
      else
        {
         if(BufferCCI[i+1]>OBOS_L1 && BufferCCI[i]<OBOS_L0)
           {
            BufferDn[i]=open[i];
           }
        }
      if(InpColorCandle)
        {
         BufferCandleOpen[i]=open[i];
         BufferCandleHigh[i]=high[i];
         BufferCandleLow[i]=low[i];
         BufferCandleClose[i]=close[i];
         
         // clrGreen,clrSpringGreen,clrRed,clrOrange,clrDodgerBlue,clrDarkGray
         
         if(BufferUpOBOS[i+1]<BufferUpOBOS[i] && BufferDnOBOS[i+1]<BufferDnOBOS[i])
           {
            BufferColors[i]=(open[i]<close[i] ? 0 : open[i]>close[i] ? 1 : 5);
           }
         else if(BufferUpOBOS[i+1]>BufferUpOBOS[i] && BufferDnOBOS[i+1]>BufferDnOBOS[i])
           {
            BufferColors[i]=(open[i]>close[i] ? 2 : open[i]<close[i] ? 3 : 5);
           }
         else
           {
            BufferColors[i]=4;
           }
        }
      
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

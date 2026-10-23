//+------------------------------------------------------------------+
//|                                                          RMO.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Rahul Mohindar Oscillator"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot RMO
#property indicator_label1  "RMO"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Sig1
#property indicator_label2  "Signal first"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Sig2
#property indicator_label3  "Signal second"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- enums
enum ENUM_PRICE
  {
   OPEN  =  PRICE_OPEN, // Open
   HIGH  =  PRICE_HIGH, // High
   LOW   =  PRICE_LOW,  // Low
   CLOSE =  PRICE_CLOSE // Close
  };
//--- input parameters
input uint        InpPeriod1  =  30;   // Period 1
input uint        InpPeriod2  =  30;   // Period 2 
input ENUM_PRICE  InpPrice    =  OPEN; // Applied price
//--- indicator buffers
double         BufferRMO[];
double         BufferSig1[];
double         BufferSig2[];
double         BufferMA[];
//--- global variables
int            period_1;
int            period_2;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriod1<2 ? 2 : InpPeriod1);
   period_2=int(InpPeriod2<1 ? 1 : InpPeriod2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRMO,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSig1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSig2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"RMO("+(string)period_1+","+(string)period_2+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRMO,true);
   ArraySetAsSeries(BufferSig1,true);
   ArraySetAsSeries(BufferSig2,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,AppliedPrice());
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(AppliedPrice())," object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   int period_max=fmax(10,fmax(period_1,period_2));
   if(rates_total<period_max) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-11;
      ArrayInitialize(BufferRMO,0);
      ArrayInitialize(BufferSig1,0);
      ArrayInitialize(BufferSig2,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x=BufferMA[i]-(10*BufferMA[i]+55*BufferMA[i+1]+165*BufferMA[i+2]+330*BufferMA[i+3]+462*BufferMA[i+4]+462*BufferMA[i+5]+330*BufferMA[i+6]+165*BufferMA[i+7]+55*BufferMA[i+8]+11*BufferMA[i+9]+BufferMA[i+10])/2046;
      int bl=Lowest(NULL,PERIOD_CURRENT,AppliedPrice(),10,i);
      int bh=Highest(NULL,PERIOD_CURRENT,AppliedPrice(),10,i);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE) return 0;
      double MinPr=BufferMA[bl];
      double MaxPr=BufferMA[bh];
      BufferRMO[i]=(MinPr!=MaxPr ? 100*x/(MaxPr-MinPr) : 0);
     }
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_1,BufferRMO,BufferSig1);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,period_2,BufferSig1,BufferSig2);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает цену расчёта                                          |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE AppliedPrice(void)
  {
   return (ENUM_APPLIED_PRICE)InpPrice;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии               |
//+------------------------------------------------------------------+
int Highest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMaximum(array)+start;
         return WRONG_VALUE;
      default:
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии                |
//+------------------------------------------------------------------+
int Lowest(string symbol_name,const ENUM_TIMEFRAMES timeframe,const ENUM_APPLIED_PRICE price_type,const int count,const int start)
  {
   if(symbol_name=="" || symbol_name==NULL) symbol_name=Symbol();
   double array[];
   ArraySetAsSeries(array,true);
   switch(price_type)
     {
      case PRICE_CLOSE :
         if(CopyClose(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_OPEN :
         if(CopyOpen(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_HIGH :
         if(CopyHigh(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      case PRICE_LOW :
         if(CopyLow(symbol_name,timeframe,start,count,array)==count)
            return ArrayMinimum(array)+start;
         return WRONG_VALUE;
      default:
         return WRONG_VALUE;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                           VC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Volatility Channel by Larry Williams"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot Top
#property indicator_label1  "Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Bottom
#property indicator_label2  "Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input uint     InpPeriod=14;   // Period
//--- indicator buffers
double         BufferTop[];
double         BufferBottom[];
double         BufferMA[];
double         BufferT[];
double         BufferB[];
//--- global variables
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferT,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferB,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility Channel "+"("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferT,true);
   ArraySetAsSeries(BufferB,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,PRICE_TYPICAL);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferTop,EMPTY_VALUE);
      ArrayInitialize(BufferBottom,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferT,0);
      ArrayInitialize(BufferB,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) 
      return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferT[i]=2.0*BufferMA[i]-high[i];
      BufferB[i]=2.0*BufferMA[i]-low[i];
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int bh=ArrayMaximum(BufferT,i,period);
      int bl=ArrayMinimum(BufferB,i,period);
      if(bh==WRONG_VALUE || bl==WRONG_VALUE)
         continue;
      double max=BufferT[bh];
      double min=BufferB[bl];

      BufferTop[i]=fmax(max,BufferT[i]);
      BufferBottom[i]=fmin(min,BufferB[i]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

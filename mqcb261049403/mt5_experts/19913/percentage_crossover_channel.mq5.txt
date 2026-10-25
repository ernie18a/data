//+------------------------------------------------------------------+
//|                                 Percentage_Crossover_Channel.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSeaGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input double               InpPercent  =  100.0;         // Percent
input ENUM_APPLIED_PRICE   InpPrice    =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferUpper[];
double         BufferMiddle[];
double         BufferLower[];
double         BufferSMA[];
//--- global variables
double         percent;
double         plus_value;
double         minus_value;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- settings variables
   percent=(InpPercent<=0 ? 0.001 : InpPercent)/100;
   plus_value=1+percent/100;
   minus_value=1-percent/100;
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpPrice);
   if(handle_ma==INVALID_HANDLE){
      Print("Error creating MA handle");
      return INIT_FAILED;
      }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(3,BufferSMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Percentage Crossover Channel");
//--- set arrays as timeseries
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferSMA,true);
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferSMA,EMPTY_VALUE);
      int copied=CopyBuffer(handle_ma,0,0,rates_total,BufferSMA);
      if(copied!=rates_total) return 0;
     }
//--- Цикл расчёта индикатора
   for(int i=limit; i>=0; i--){
      int total=(limit==0 ? 1 : limit);
      int copied=CopyBuffer(handle_ma,0,0,total,BufferSMA);
      if(copied!=total) return 0;
      double price=BufferSMA[i];
      if(limit>1 && i==limit)
         BufferMiddle[i]=price;
      else
         BufferMiddle[i]=(price*minus_value>BufferMiddle[i+1] ? price*minus_value : price*plus_value<BufferMiddle[i+1] ? price*plus_value : BufferMiddle[i+1]);
      BufferUpper[i]=BufferMiddle[i]*plus_value;
      BufferLower[i]=BufferMiddle[i]*minus_value;
      }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                              Daily_Open_Line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot DailyOpen
#property indicator_label1  "DailyOpen"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint     InpOpenHour=0;    // Hour of daily open
//--- indicator buffers
double         BufferDailyOpen[];
//--- global variables
int            open_hour;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDailyOpen,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//--- settings variables
   open_hour=int(InpOpenHour>23 ? 23 : InpOpenHour);
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
//--- Зададим направление индексации массивов как у таймсерий
   ArraySetAsSeries(BufferDailyOpen,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferDailyOpen,EMPTY_VALUE);
     }
//--- Цикл расчёта индикатора
   for(int i=limit; i>=0; i--)
     {
      int H_Curr=TimeHour(time[i]);
      int H_Prev=TimeHour(time[i+1]);
      if(H_Curr==WRONG_VALUE || H_Prev==WRONG_VALUE) return 0;
      if(H_Prev==23) H_Prev=-1;
      if(open_hour>H_Prev && open_hour<=H_Curr)
         BufferDailyOpen[i]=open[i];
      else
         BufferDailyOpen[i]=BufferDailyOpen[i+1];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает час указанного времени                                |
//+------------------------------------------------------------------+
int TimeHour(const datetime time)
  {
   MqlDateTime tm;
   if(TimeToStruct(time,tm))
      return tm.hour;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+

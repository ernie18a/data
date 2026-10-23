//+------------------------------------------------------------------+
//|                                                 simplezigzag.mq5 |
//|    Copyright 2014, Andrey Litvichenko, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Andrey Litvichenko, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot ZZline
#property indicator_label1  "ZZline"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrTeal
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+------------------------------------------------------------------+
//|  Structure declaration SDot | Объявление структуры SDot          |
//+------------------------------------------------------------------+
struct SDot
  {
   double            price;
   datetime          time;
  };
//+-------------------------------------------------------------------------------------+
//|Enumeration declaration ETrendStatus | Объявление перечисления ETrendStatus          |
//+-------------------------------------------------------------------------------------+
enum ETrendStatus
  {
   up,
   down
  };
//--- input parameters
//---входные параметры
input int      min_delta=100;    //minimum range in points/минимальнный диапазон в пунктах
//--- indicator buffers
//--- объявление массивов индикаторных буфферов
double         ZZHigh[];
double         ZZLow[];
//---declaration of variables
//---объявление переменных
double         delta;
SDot           last_dot;
ETrendStatus   state;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//--- инициализация индикаторных буфферов
   SetIndexBuffer(0,ZZHigh,INDICATOR_DATA);
   SetIndexBuffer(1,ZZLow,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- installation indicator's short name
//--- установка короткого имени индикатора
   IndicatorSetString(INDICATOR_SHORTNAME,"SimpleZigZag"+"("+string(min_delta)+")");
//--- setting accuracy indicator
//--- установка точности индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---initialize variables
//---инициализация переменных
   delta=min_delta*_Point;
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
//---declaration of variables
//---объявление переменных
   int         first;
   int         bar;

   if(prev_calculated>rates_total || prev_calculated<=0) // Checking the first start of the indicator calculation
     {                                                   // проверка на первый старт расчета индикатора
      for(int i=0;i<rates_total;i++)
        {
         ZZHigh[bar]=0;
         ZZLow[bar]=0;
        }
      first=1;
      if(close[first]>open[first]) // initialize variable state|инициализации переменной state
         state=up;
      else
         state=down;
      last_dot.price=close[first];                       // initialize variable last_dot|инициализации переменной last_dot
      last_dot.time=time[first];
     }
   else
     {
      first=prev_calculated-1;                           // starting number for the calculation of new bars|стартовый номер для расчета новых баров
     }
   
   for(bar=first;bar<rates_total;bar++)//main loop calculation of the indicator|основной цикл расчета индикатора
     {
      if(bar==rates_total-1 && prev_calculated<rates_total)
        {
         ZZHigh[bar]=0;
         ZZLow[bar]=0;
        }
      switch(state)
        {
         case up:
           {
            if(high[bar]>last_dot.price)//check the trend continuation|проверка продолжения тренда
              {
               if(time[bar]>last_dot.time)
                  ZZHigh[ArrayBsearch(time,last_dot.time)]=0;//removing unnecessary vertices|удаление ненужных вершин 
               last_dot.price=high[bar];
               last_dot.time=time[bar];
               ZZHigh[bar]=high[bar];
              }
            if(low[bar]<last_dot.price-delta && (time[bar]>last_dot.time || high[bar-1]-low[bar]>delta))//check the appearance of the new knee|проверка появления нового колена
              {
               last_dot.time=time[bar];
               last_dot.price=low[bar];
               state=down;
               ZZLow[bar]=low[bar];
               CheckInsideBar(bar,time,open,high,low,close);
              }
           }
         break;
         case down:
           {
            if(low[bar]<last_dot.price)//check the trend continuation|проверка продолжения тренда
              {
               if(time[bar]>last_dot.time)
                  ZZLow[ArrayBsearch(time,last_dot.time)]=0;//removing unnecessary vertices|удаление ненужных вершин 
               last_dot.price=low[bar];
               last_dot.time=time[bar];
               ZZLow[bar]=low[bar];
              }
            if(high[bar]>last_dot.price+delta && (time[bar]>last_dot.time || high[bar]-low[bar-1]>delta))//check the appearance of the new knee|проверка появления нового колена
              {
               last_dot.time=time[bar];
               last_dot.price=high[bar];
               state=up;
               ZZHigh[bar]=high[bar];
               CheckInsideBar(bar,time,open,high,low,close);
              }
           }
         break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckInsideBar(int bar,
                    const datetime &time[],
                    const double &open[],
                    const double &high[],
                    const double &low[],
                    const double &close[])
  {
   if(high[bar-1]>high[bar] && low[bar-1]<low[bar])
     {
      switch(state)
        {
         case up:
           {
            if(low[bar]<high[bar]-delta)
              {
               last_dot.time=time[bar];
               last_dot.price=low[bar];
               state=down;
               ZZLow[bar]=low[bar];
              }
           }
         break;
         case down:
           {
            if(high[bar]>low[bar]+delta)
              {
               last_dot.time=time[bar];
               last_dot.price=high[bar];
               state=up;
               ZZHigh[bar]=high[bar];
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+

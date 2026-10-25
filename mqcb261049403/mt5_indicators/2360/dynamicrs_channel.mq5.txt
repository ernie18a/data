//+------------------------------------------------------------------+
//|                                            DynamicRS_Channel.mq5 |
//|                                 Copyright © 2007, Nick A. Zhilin |
//|                                                  rebus58@mail.ru |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, Nick A. Zhilin"
//--- ссылка на сайт автора
#property link      "rebus58@mail.ru"
//--- номер версии индикатора
#property version   "1.00"
#property description "Канал, построенный без усреднения" 
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано 3 буфера
#property indicator_buffers 3
//--- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- в качестве индикатора использована линия
#property indicator_type1   DRAW_LINE
//--- отображение метки индикатора
#property indicator_label1  "DynamicRS Middle"
//--- в качестве цвета индикатора использован
#property indicator_color1 clrDodgerBlue
//--- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//--- в качестве индикатора использована линия
#property indicator_type2   DRAW_LINE
//--- отображение метки индикатора
#property indicator_label2  "DynamicRS Upper"
//--- в качестве цветов линии индикатора использован
#property indicator_color2 clrRed
//--- линия индикатора - сплошная
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width2  2
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//--- в качестве индикатора использована линия
#property indicator_type3   DRAW_LINE
//--- отображение метки индикатора
#property indicator_label3  "DynamicRS Lower"
//--- в качестве цветов линии индикатора использован
#property indicator_color3 clrMediumSeaGreen
//--- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width3  2
//+----------------------------------------------+ 
//| объявление констант                          |
//+----------------------------------------------+ 
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Filter=150; // Ширина
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double LowestBuffer[];
double HighestBuffer[];
double MiddleBuffer[];
//---
double dFilter;
//--- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=2;
   dFilter=Filter*_Point;
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,MiddleBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HighestBuffer,INDICATOR_DATA);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(MiddleBuffer,true);
//--- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string shortname;
   StringConcatenate(shortname,"DynamicRS_Channel(",Filter,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---   
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total)return(RESET);
//--- объявления локальных переменных 
   int limit,bar;
   double;
//--- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
//--- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(high[bar]<high[bar+1] &&  high[bar]<MiddleBuffer[bar+1]-dFilter) MiddleBuffer[bar]=high[bar];
      else if(low[bar]>low[bar+1]&& low[bar]>MiddleBuffer[bar+1]+dFilter) MiddleBuffer[bar]=low[bar];
      else MiddleBuffer[bar]=MiddleBuffer[bar+1];
      //---
      HighestBuffer[bar]=MiddleBuffer[bar]+dFilter;
      LowestBuffer[bar]=MiddleBuffer[bar]-dFilter;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

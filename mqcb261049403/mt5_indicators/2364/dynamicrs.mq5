//+------------------------------------------------------------------+
//|                                                    DynamicRS.mq5 |
//|                                 Copyright © 2007, Nick A. Zhilin |
//|                                                  rebus58@mail.ru |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, Nick A. Zhilin"
//--- ссылка на сайт автора
#property link      "rebus58@mail.ru"
//--- номер версии индикатора
#property version   "1.00"
#property description "Мувинг, построенный без усреднения" 
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- количество индикаторных буферов
#property indicator_buffers 1 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- в качестве индикатора использована линия
#property indicator_type1   DRAW_LINE
//--- отображение метки индикатора
#property indicator_label1  "DynamicRS"
//--- в качестве цвета индикатора использован
#property indicator_color1 clrDodgerBlue
//--- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| объявление констант                          |
//+----------------------------------------------+ 
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input uint Filter=15; // Ширина
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
//---
double dFilter;
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=2;
   dFilter=Filter*_Point;
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(IndBuffer,true);
//--- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string shortname;
   StringConcatenate(shortname,"DynamicRS(",Filter,")");
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
      if(high[bar]<high[bar+1] && high[bar]<IndBuffer[bar+1]-dFilter) IndBuffer[bar]=high[bar];
      else if(low[bar]>low[bar+1] && low[bar]>IndBuffer[bar+1]+dFilter) IndBuffer[bar]=low[bar];
      else IndBuffer[bar]=IndBuffer[bar+1];
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

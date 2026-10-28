//+------------------------------------------------------------------+
//|                                                        GARCH.mq5 |
//|                            Copyright © 2012, Andres Barale Sarti |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2012, Andres Barale Sarti"
//--- ссылка на сайт автора
#property link "https://forge.mql5.io"
#property description "Это индикатор фрактальной волатильности на базе модели GARCH Тима Боллерслева"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 1
//--- использовано два графических построения
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "GARCH"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double e_alpha= 0.010;
input double e_beta = 0.080;
input int  Shift=0;                             //сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые будут
//--- в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double GarchNumVar;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(2);
   GarchNumVar=0.000001;
//--- превращение динамического массива PVIBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"GARCH");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,6);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(RESET);
//--- объявление локальных переменных
   int limit,bar;
   double GarchNum,residual,residualSq;
   static double GarchNumVar_;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=int(rates_total-min_rates_total-begin); // расчетное количество всех баров
      GarchNumVar_=0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//--- индексация элементов в массиве как в таймсерии
   ArraySetAsSeries(price,true);
//---
   GarchNumVar=GarchNumVar_;
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      residual=price[bar]-price[bar+1];
      residualSq=MathPow(residual,2.0);
      GarchNumVar=e_alpha*residualSq+e_beta*GarchNumVar;
      GarchNum=MathSqrt(GarchNumVar);
      IndBuffer[bar]=GarchNum;
      //---
      if(bar) GarchNumVar_=GarchNumVar;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

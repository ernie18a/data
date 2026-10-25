//+------------------------------------------------------------------+
//|                                   Chande Momentum Oscillator.mq5 |
//|              MQL5 Code:     Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
/*
 *  << Осциллятор ценовых моментов >>
 *
 * Для работы  индикатора  следует  положить файл
 * SmoothAlgorithms.mqh
 * в папку (директорию): MetaTrader\\MQL5\Include
 *
 * Основные методы использования «Осциллятора ценовых моментов Чанде»:
 *
 * 1) Обычный метод интерпретации CMO - поиск «перекупленности»/«перепроданности». 
 * «Перекупленность» - при уровне +70 и выше, «перепроданность» при уровне +30 и ниже.
 * 2) Индикатор тренда. Покупка - при пересечении CMO длинного периода с CMO короткого
 * периода, продажа - наоборот, при пересечении CMO короткого периода с CMO длинного периода.
 */
//---- авторство индикатора
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован золотой цвет
#property indicator_color1  clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "CMO"
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  +50
#property indicator_level2    0
#property indicator_level3  -50
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int CMO_period= 9; // Период CMO
input int CMO_Shift = 0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//+------------------------------------------------------------------+
//| Описание класса CCMO                                             |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,CMO_Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,CMO_period);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"CMO(",CMO_period,")");
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<CMO_period+1+begin)
      return(0);
//---- объявления локальных переменных 
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0+begin; // стартовый номер для расчета всех баров
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,CMO_period+2+begin);
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчета новых баров
     }
//---- объявление переменной класса CCMO
   static CCMO CMO;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
      ExtLineBuffer[bar]=CMO.CMOSeries(begin,prev_calculated,rates_total,CMO_period,price[bar],bar,false)*200-100;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

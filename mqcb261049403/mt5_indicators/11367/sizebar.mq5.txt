//+------------------------------------------------------------------+
//|                                                      SizeBar.mq5 | 
//|                                            Copyright © 2011, zfs | 
//|                                                   vasbsm@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, zfs"
#property link "vasbsm@mail.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов
#property indicator_buffers 1 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_HISTOGRAM
//--- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width1  3
//--- отображение метки индикатора
#property indicator_label1  "SizeBar"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамического массива, который будет
//--- в дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| SizeBar indicator initialization function                        | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=2;
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"SizeBar");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| SizeBar iteration function                                       | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(rates_total<min_rates_total) return(0);
//--- объявление переменных с плавающей точкой  
   double max,x,y;
//--- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total-1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      x=((high[bar]-close[bar-1])/_Point)-spread[bar];
      y=((close[bar-1]-low[bar])/_Point)-spread[bar];
      if(x>y) max=x;
      else max=y;
      max=MathMax(max,0);
      IndBuffer[bar]=max;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

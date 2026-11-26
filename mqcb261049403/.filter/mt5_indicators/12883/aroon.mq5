//+------------------------------------------------------------------+
//|                                                        Aroon.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//--- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color1  clrLime
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "BullsAroon"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  clrRed
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "BearsAroon"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int AroonPeriod= 9;  // Период индикатора 
input int AroonShift = 0;  // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double BullsAroonBuffer[];
double BearsAroonBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- превращение динамического массива BullsAroonBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsAroonBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,AroonShift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на AroonPeriod
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,AroonPeriod);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"BearsAroon");
//--- превращение динамического массива BearsAroonBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsAroonBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на AroonShift
   PlotIndexSetInteger(1,PLOT_SHIFT,AroonShift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на AroonPeriod
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,AroonPeriod);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"BullsAroon");
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Aroon(",AroonPeriod,", ",AroonShift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---
  }
//+------------------------------------------------------------------+
//| Searching index of the highest bar                               |
//+------------------------------------------------------------------+
int iHighest(const double &array[], // массив для поиска индекса максимального элемента
             int count,             // число элементов массива (в направлении от текущего бара в сторону убывания индекса), 
             int startPos           // индекс (смещение относительно текущего бара) начального бара, с которого начинается поиск наибольшего значения
             )
  {
//---
   int index=startPos;
//--- проверка стартового индекса на корректность
   if(startPos<0)
     {
      Print("Неверное значение в функции iHighest, startPos = ",startPos);
      return(0);
     }
//--- проверка значения startPos на корректность
   if(startPos-count<0)
      count=startPos;
//---
   double max=array[startPos];
//--- поиск индекса
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//--- возврат индекса наибольшего бара
   return(index);
  }
//+------------------------------------------------------------------+
//| Searching index of the lowest bar                                |
//+------------------------------------------------------------------+
int iLowest(const double &array[], // массив для поиска индекса минимального элемента
            int count,             // число элементов массива (в направлении от текущего бара в сторону убывания индекса), 
            int startPos           // индекс (смещение относительно текущего бара) начального бара, с которого начинается поиск наименьшего значения
            )
  {
//---
   int index=startPos;
//--- проверка стартового индекса на корректность
   if(startPos<0)
     {
      Print("Неверное значение в функции iLowest, startPos = ",startPos);
      return(0);
     }
//--- проверка значения startPos на корректность
   if(startPos-count<0)
      count=startPos;
//---
   double min=array[startPos];
//--- поиск индекса
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//--- возврат индекса наименьшего бара
   return(index);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<AroonPeriod-1) return(0);
//--- объявления локальных переменных 
   int first,bar;
   double BULLS,BEARS;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=AroonPeriod-1;       // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- вычисление индикаторных значений
      BULLS = 100 - (bar - iHighest(high, AroonPeriod, bar) + 0.5) * 100 / AroonPeriod;
      BEARS = 100 - (bar - iLowest (low,  AroonPeriod, bar) + 0.5) * 100 / AroonPeriod;
      //--- инициализация ячеек индикаторных буферов полученными значениями 
      BullsAroonBuffer[bar] = BULLS;
      BearsAroonBuffer[bar] = BEARS;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

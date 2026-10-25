//+---------------------------------------------------------------------+
//|                                               ATR_MA_Oscillator.mq5 | 
//|                                               Copyright © zfs, 2009 | 
//|                                                                     | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © zfs, 2009"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ATR_MA_Oscillator"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XATR1,XATR2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_LWMA; // Метод усреднения
input int XLength=100;                    // Глубина сглаживания                    
input int XPhase=15;                      // Параметр сглаживания
                                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method SXMA_Method=MODE_LWMA; // Метод усреднения
input int SXLength=100;                    // Глубина сглаживания                    
input int SXPhase=15;                      // Параметр сглаживания
                                           // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
                                           // для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                         // Сдвиг индикатора по горизонтали в барах
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//---- объявление целочисленных переменных начала отсчёта данных
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| ATR_MA_Oscillator initialization function                        | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   min_rates_=XATR1.GetStartBars(XMA_Method,XLength,XPhase)+1;
   min_rates_total=min_rates_+XATR1.GetStartBars(SXMA_Method,SXLength,SXPhase);
//---- установка алертов на недопустимые значения внешних переменных
   XATR1.XMALengthCheck("XLength", XLength);
   XATR1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XATR1.XMALengthCheck("SXLength", SXLength);
   XATR1.XMAPhaseCheck("SXPhase", SXPhase, SXMA_Method);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR_MA_Oscillator");
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| ATR_MA_Oscillator iteration function                             | 
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double atr,xatr,xxatr;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      atr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
      atr/=_Point;
      xatr=XATR1.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,atr,bar,false);
      xxatr=XATR2.XMASeries(min_rates_,prev_calculated,rates_total,SXMA_Method,SXPhase,SXLength,xatr,bar,false);
      IndBuffer[bar]=xatr-xxatr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

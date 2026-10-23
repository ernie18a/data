//+---------------------------------------------------------------------+
//|                                              Chaikin_Volatility.mq5 |
//|                         Copyright © 2007, MetaQuotes Software Corp. |
//|                                          https://www.metaquotes.net |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл xrangeAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
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
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован Salmon цвет
#property indicator_color1 clrSalmon
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 1
#property indicator_width1  1
//--- отображение метки индикатора
#property indicator_label1  "Chaikin_Volatility"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- объявление переменных класса CXMA из файла xrangeAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//| объявление перечислений           |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле xrangeAlgorithms.mqh
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
   MODE_AMA    //AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_EMA; // Метод усреднения
input int XLength=10;                    // Глубина сглаживания                    
input int XPhase=15;                     // Параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ROCPeriod=10;                 // Глубина второго сглаживания 
input int Shift=0;                       // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет использован в качестве индикаторного буфера
double IndBuffer[];
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве кольцевых буферов
int Count[];
double xrange[];
//+------------------------------------------------------------------+
//| Пересчёт позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[]) // Возврат по ссылке номера текущего значения ценового ряда
  {
//---
   int numb,Max1,Max2;
   static int count=1;

   Max2=7;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+   
//| Chaikin_Volatility indicator initialization function             | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_1=XMA1.GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total=min_rates_1+int(ROCPeriod+1);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,ROCPeriod+1);
   ArrayResize(xrange,ROCPeriod+1);
   ArrayInitialize(Count,0);
   ArrayInitialize(xrange,0);
//--- инициализация массивов переменных
   ArrayInitialize(xrange,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Chaikin_Volatility");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Chaikin_Volatility iteration function                            | 
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
   double range,xrangeX,ratio;
//--- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      range=high[bar]-low[bar];
      xrange[Count[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,range,bar,false);
      //---
      xrangeX=xrange[Count[ROCPeriod]];
      if(xrangeX) ratio=(xrange[Count[0]]-xrangeX)/xrangeX*100;
      else ratio=1;
      IndBuffer[bar]=ratio;
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

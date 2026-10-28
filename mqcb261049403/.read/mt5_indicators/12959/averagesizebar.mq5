//+------------------------------------------------------------------+
//|                                               AverageSizeBar.mq5 | 
//|                        Copyright © 2007, Ким Игорь В. aka KimIV. | 
//|                                             http://www.kimiv.ru/ | 
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh следует положить |
//| в папку: каталог_данных_терминала\MetaTrader\MQL5\Include        |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Ким Игорь В. aka KimIV."
#property link "http://www.kimiv.ru/"
#property description "Средний размер свечи за определённый период"
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
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "AverageSizeBar"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input int XLength=10; // Глубина сглаживания                    
input int XPhase=15;  // Параметр сглаживания
                      // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
                      // для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;    // Сдвиг индикатора по горизонтали в барах
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double XATR[];
//---- объявление целочисленных переменных начала отсчёта данных
int StartBars;
//+------------------------------------------------------------------+   
//| XATR indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчёта данных
   StartBars=XMA.GetStartBars(XMA_Method,XLength,XPhase);
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("XLength",XLength);
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XATR,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"XATR");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"AverageSizeBar(",XLength,", ",XPhase,", ",Smooth,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XATR iteration function                                          | 
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
   if(rates_total<StartBars) return(0);
//---- объявление переменных с плавающей точкой  
   double dprice;
//---- объявление целых переменных и получение уже посчитанных баров
   int first,bar;
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dprice=high[bar]-low[bar];
      XATR[bar]=XMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,dprice,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

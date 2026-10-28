//+---------------------------------------------------------------------+
//|                                                        ATR_3XMA.mq5 |
//|                                              Copyright 2015, fxborg |
//|                                      http://fxborg-labo.hateblo.jp/ |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://fxborg-labo.hateblo.jp/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки быстрого ATR             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован зеленый цвет
#property indicator_color1  clrLime
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Fast ATR"
//+----------------------------------------------+
//| Параметры отрисовки умеренного ATR           |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color2  clrRed
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  " Medium ATR"
//+----------------------------------------------+
//| Параметры отрисовки медленного ATR           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Slow ATR"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4,XMA5,XMA6;
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
input uint FastATRPeriod=14;     // Период быстрого ATR
input uint MediumATRPeriod=25;   // Период умеренного ATR
input uint SlowATRPeriod=50;     // Период медленного ATR
input double SmoothRatio=5.0;    // Коэффициент уменьшения периода
input Smooth_Method MA_Method1=MODE_JJMA; // Метод усреднения первого сглаживания
input int Phase1=15; // Параметр первого сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_SMA_; // Метод усреднения второго сглаживания
input int Phase2=15; // Параметр второго сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer1[],IndBuffer2[],IndBuffer3[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
uint FastSmoothPeriod,MediumSmoothPeriod,SlowSmoothPeriod;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   int max1=int(MathMax(FastATRPeriod,MathMax(MediumATRPeriod,SlowATRPeriod)));
   min_rates_1=1+GetStartBars(MA_Method1,max1,Phase1);;
   double Ratio=MathMax(1,SmoothRatio);
   FastSmoothPeriod=int(MathCeil(FastATRPeriod/Ratio));
   MediumSmoothPeriod=int(MathCeil(MediumATRPeriod/Ratio));
   SlowSmoothPeriod=int(MathCeil(SlowATRPeriod/Ratio));
   int max2=int(MathMax(FastSmoothPeriod,MathMax(MediumSmoothPeriod,SlowSmoothPeriod)));
   min_rates_total=min_rates_1+GetStartBars(MA_Method2,max2,Phase2);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer3,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ATR_3XMA(",FastATRPeriod,", ",MediumATRPeriod,", ",SlowATRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,5);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double atr,xatr1,xatr2,xatr3;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      atr=calc_atr(bar,high,low,close);
      //----
      xatr1=XMA1.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,FastATRPeriod,atr,bar,false);
      xatr2=XMA2.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,MediumATRPeriod,atr,bar,false);
      xatr3=XMA3.XMASeries(1,prev_calculated,rates_total,MA_Method1,Phase1,SlowATRPeriod,atr,bar,false);
      //----
      IndBuffer1[bar]=XMA4.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method1,Phase1,FastSmoothPeriod,xatr1,bar,false);
      IndBuffer2[bar]=XMA5.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method1,Phase1,MediumSmoothPeriod,xatr2,bar,false);
      IndBuffer3[bar]=XMA6.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method1,Phase1,SlowSmoothPeriod,xatr3,bar,false);
     }
//----     
   return(rates_total);
  }
//+----------------------------------------------------+
//| calc lwma atr                                      |
//+----------------------------------------------------+
double calc_atr(int index,const double  &h[],const double  &l[],const double  &c[])
  {
//--- 
   return(MathMax(h[index],c[index-1])-MathMin(l[index],c[index-1]));
  }
//+------------------------------------------------------------------+

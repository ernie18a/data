//+------------------------------------------------------------------+
//|                                           ChangeOfVolatility.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов диаграммы индикатора использованы
#property indicator_color1 clrGray,clrPurple,clrRed,clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "Change of Volatility"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint MPeriod=1;                              // Период моментума
input uint Short=6;
input uint Long=100;
input uint MaxTrendLevel=80;                         // Уровень максимального тренда
input uint MiddLeTrendLevel=50;                      // Уровень умеренного тренда
input uint FlatLevel=30;                             // Уровень флета
//+-----------------------------------+
//---- индикаторныe буферы
double StdDevBuffer[],ColorBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание функции iPriceSeriesAlert                               |
//| Описание классов CMomentum и CStdDeviation                       |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| StdDev indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MPeriod+MathMax(Short,Long));
//---- превращение динамического массива StdDevBuffer в индикаторный буфер
   SetIndexBuffer(0,StdDevBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Change of Volatility( ",MPeriod,", ",Short,", ",Long," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,MaxTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddLeTrendLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,FlatLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Magenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Blue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Gray);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| StdDev iteration function                                        |
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление целочисленных переменных
   int first,bar;
//---- объявление переменных с плавающей точкой  
   double stdl,stds,smal,smas,momentum;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных класса CMomentum и CStdDeviation из файла SmoothAlgorithms.mqh
   static CMomentum Mom;
   static CStdDeviation STDL,STDS;
   static CMoving_Average SMAL,SMAS;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      momentum=Mom.MomentumSeries(0,prev_calculated,rates_total,MPeriod,close[bar],bar,false);
      momentum/=_Point;
      //---
      smal=SMAL.SMASeries(MPeriod,prev_calculated,rates_total,Long,momentum,bar,false);
      stdl=STDL.StdDevSeries(MPeriod,prev_calculated,rates_total,Long,2,momentum,smal,bar,false);
      smas=SMAS.SMASeries(MPeriod,prev_calculated,rates_total,Short,momentum,bar,false);
      stds=STDS.StdDevSeries(MPeriod,prev_calculated,rates_total,Short,2,momentum,smas,bar,false);
      //---
      if(stdl) StdDevBuffer[bar]=100*stds/stdl;
      else StdDevBuffer[bar]=0.0;
      //---
      ColorBuffer[bar]=0;
      if(StdDevBuffer[bar]>MaxTrendLevel) ColorBuffer[bar]=3;
      else if(StdDevBuffer[bar]>MiddLeTrendLevel) ColorBuffer[bar]=2;
      else if(StdDevBuffer[bar]>FlatLevel) ColorBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

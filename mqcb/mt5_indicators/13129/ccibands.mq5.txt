//+---------------------------------------------------------------------+
//|                                                        CCIBands.mq5 |
//|                                             Copyright © 2014, wellx | 
//|                                                 http://www.mql4.com | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, wellx"
#property link "http://www.mql4.com"
#property description "Commodity Channel Index High-Low Band"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color1 clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "UpCCI"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован BlueViolet цвет
#property indicator_color2 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "MediumCCI"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color3 clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "LowCCI"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +100.0
#property indicator_level2    0.0
#property indicator_level3 -100.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA H1XMA,H2XMA,C1XMA,C2XMA,L1XMA,L2XMA;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input uint CCIPeriod=14;                 // Период CCI индикатора
input double koeff=0.015;
input int XPhase=15;                     // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtABuffer[],ExtBBuffer[],ExtBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(GetStartBars(XMA_Method,CCIPeriod,XPhase)+CCIPeriod);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"CCIBands");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double ExtPrice_C,ExtPrice_H,ExtPrice_L,ExtMov_C,ExtMov_H,ExtMov_L,dSum_C,dSum_H,dSum_L;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtPrice_C=(high[bar]+low[bar]+close[bar])/3;
      ExtPrice_H=(high[bar]+low[bar]+high[bar])/3;
      ExtPrice_L=(high[bar]+low[bar]+low[bar])/3;
      //----
      ExtMov_C=C1XMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,CCIPeriod,ExtPrice_C,bar,false);
      ExtMov_H=H1XMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,CCIPeriod,ExtPrice_H,bar,false);
      ExtMov_L=L1XMA.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,CCIPeriod,ExtPrice_L,bar,false);
      //----
      dSum_C=koeff*C2XMA.XMASeries(CCIPeriod,prev_calculated,rates_total,MODE_SMA_,XPhase,CCIPeriod,MathAbs(ExtPrice_C-ExtMov_C),bar,false);
      dSum_H=koeff*H2XMA.XMASeries(CCIPeriod,prev_calculated,rates_total,MODE_SMA_,XPhase,CCIPeriod,MathAbs(ExtPrice_H-ExtMov_C),bar,false);
      dSum_L=koeff*L2XMA.XMASeries(CCIPeriod,prev_calculated,rates_total,MODE_SMA_,XPhase,CCIPeriod,MathAbs(ExtPrice_L-ExtMov_C),bar,false);
      //----      
      ExtABuffer[bar]=0.0;
      ExtBBuffer[bar]=0.0;
      ExtBuffer[bar]=0.0;
      //---- 
      if(dSum_C) ExtBuffer[bar]=(ExtPrice_C-ExtMov_C)/dSum_C;
      if(dSum_H) ExtABuffer[bar]=(ExtPrice_H-ExtMov_C)/dSum_H;
      if(dSum_L) ExtBBuffer[bar]=(ExtPrice_L-ExtMov_C)/dSum_L;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+

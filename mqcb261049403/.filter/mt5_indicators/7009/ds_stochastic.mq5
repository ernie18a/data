//+------------------------------------------------------------------+
//|                                                DS_Stochastic.mq5 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "https://www.metaquotes.net/"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrYellowGreen,clrDeepPink
//--- отображение метки индикатора
#property indicator_label1  "DS_Stochastic"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
//+----------------------------------------------+
//| объявление перечислений                      |
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
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint qPeriod=13;                       // Период поиска экстремумов
input Smooth_Method rMethod=MODE_EMA;        // Метод усреднения 1
input uint rPeriod=32;                       // Период усреднения 1
input int rPhase=15;                         // Параметр сглаживания 1
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input Smooth_Method fMethod=MODE_EMA;        // Метод усреднения 2
input uint fPeriod=5;                        // Период усреднения 2
input int fPhase=15;                         // Параметр сглаживания 2
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtABuffer[],ExtBBuffer[];
//--- объявление целочисленных переменных начала отсчёта данных
int  min_rates_1,min_rates_2,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_1=int(qPeriod);
   min_rates_2=min_rates_1+XMA1.GetStartBars(rMethod,rPeriod,rPhase);
   min_rates_total=min_rates_2+XMA1.GetStartBars(fMethod,fPeriod,fPhase);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"DS_Stochastic");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int limit,bar,maxbar1,maxbar2;
   double HH,LL,DIF1,DIF2,CH,RN,XDIF1,XDIF2;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---   
   maxbar1=rates_total-min_rates_1-1;
   maxbar2=rates_total-min_rates_2-1;
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=maxbar1; // стартовый номер для расчёта всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//--- первый цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,qPeriod)];
      LL=low[ArrayMinimum(low,bar,qPeriod)];
      CH=close[bar]-LL;
      RN=HH-LL;
      DIF1=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,rMethod,rPhase,rPeriod,CH,bar,true);
      DIF2=XMA2.XMASeries(maxbar1,prev_calculated,rates_total,rMethod,rPhase,rPeriod,RN,bar,true);
      if(DIF2) ExtABuffer[bar]=100*DIF1/DIF2;
      else ExtABuffer[bar]=100.0;
      XDIF1=XMA3.XMASeries(maxbar2,prev_calculated,rates_total,fMethod,fPhase,fPeriod,DIF1,bar,true);
      XDIF2=XMA4.XMASeries(maxbar2,prev_calculated,rates_total,fMethod,fPhase,fPeriod,DIF2,bar,true);
      if(XDIF2) ExtBBuffer[bar]=100*XDIF1/XDIF2;
      else ExtBBuffer[bar]=100.0;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+

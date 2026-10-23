//+------------------------------------------------------------------+
//|                                             i-SpectrAnalysis.mq5 |
//|                                           Copyright © 2006, klot |
//|                                                     klot@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, klot"
#property link      "klot@mail.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- количество индикаторных буферов
#property indicator_buffers 1 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован Red цвет
#property indicator_color1 clrRed
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "i_SpecktrAnalis"
//+-----------------------------------+
//| Описание библиотеки dt_FFT.mqh    |
//+-----------------------------------+
#include <dt_FFT.mqh> 
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint N = 7;   // Длина ряда
input uint SS = 20; // Коэффициент сглаживания
input int Shift=0;  // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет использован в качестве индикаторного буфера
double IndBuffer[];
//---
int M,tnn1,ss;
//---
double aa[];
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| i-SpectrAnalysis indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   tnn1=int(MathPow(2,N));
   M=ArrayResize(aa,tnn1+1);
   ss=int(MathMin(SS,M));
   min_rates_total=int(M);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"i-SpecktrAnalis");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| i-SpecktrAnalis iteration function                               | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчёта баров
                const double &price[])    // ценовой массив для расчёта индикатора
  {
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total+begin) return(0);
//---
   for(int bbb=rates_total-1; bbb>=prev_calculated && !IsStopped(); bbb--) IndBuffer[rates_total-1-bbb]=0.0;
//---
   int end=M-1;
   for(int iii=M-1; iii>=0 && !IsStopped(); iii--) aa[iii]=price[rates_total-1-iii];
   fastcosinetransform(aa,tnn1,false);
   for(int kkk=0; kkk<=end && !IsStopped(); kkk++) if(kkk>=ss) aa[kkk]=0.0;
   fastcosinetransform(aa,tnn1,true);
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++) IndBuffer[rates_total-1-rrr]=aa[rrr];
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//|                                        i-SpectrAnalysis_OsMA.mq5 | 
//|                                           Copyright © 2006, klot | 
//|                                                     klot@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, klot" 
#property link      "klot@mail.ru" 
//--- номер версии индикатора 
#property version   "1.00" 
//--- отрисовка индикатора в отдельном окне 
#property indicator_separate_window 
//--- количество индикаторных буферов 
#property indicator_buffers 2 
//--- использовано всего одно графическое построение 
#property indicator_plots   1 
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               | 
//+----------------------------------------------+ 
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrDodgerBlue,clrDarkGreen,clrGray,clrPurple,clrMagenta
//--- линия индикатора - непрерывная кривая 
#property indicator_style1  STYLE_SOLID 
//--- толщина линии индикатора равна 2 
#property indicator_width1  2 
//--- отображение метки индикатора 
#property indicator_label1  "i-SpectrAnalysis_OsMA" 
//+----------------------------------------------+ 
//| Параметры отображения горизонтальных уровней | 
//+----------------------------------------------+ 
#property indicator_level1 0.0 
#property indicator_levelcolor clrGray 
#property indicator_levelstyle STYLE_DASHDOTDOT 
//+----------------------------------------------+ 
//| Объявление констант                          | 
//+----------------------------------------------+ 
#define RESET 0     // константа для возврата терминалу команды на пересчет индикатора 
//+----------------------------------------------+ 
//| Описание библиотеки dt_FFT.mqh               | 
//+----------------------------------------------+ 
#include <dt_FFT.mqh> 
//+----------------------------------------------+ 
//| Входные параметры индикатора                 | 
//+----------------------------------------------+ 
input uint FastEMA=12;
input uint SlowEMA=26;                         
input uint MacdEMA=9;                                                
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;
input uint N = 7;                                 // number Length 
input uint SS = 20;                               // smoothing factor 
input int Shift=0;                                // The shift indicator in the horizontal bars
//+----------------------------------------------+ 
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//--- 
int M,tnn1,ss;
//--- 
double aa[];
//--- объявление целочисленных переменных начала отсчета данных 
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов 
int Ind_Handle;
//+------------------------------------------------------------------+   
//| i-SpectrAnalysis_OsMA indicator initialization function          | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных 
   tnn1=int(MathPow(2,N));
   M=ArrayResize(aa,tnn1+1);
   ArraySetAsSeries(aa,true);
   ss=int(MathMin(SS,M));
   min_rates_total=int(M);
//--- получение хендла индикатора iOsMA 
   Ind_Handle=iOsMA(Symbol(),PERIOD_CURRENT,FastEMA,SlowEMA,MacdEMA,MAPrice);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iOsMA");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер 
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- осуществление сдвига индикатора 1 по горизонтали 
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии 
   ArraySetAsSeries(IndBuffer,true);
   ArraySetAsSeries(ColorIndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке 
   IndicatorSetString(INDICATOR_SHORTNAME,"i-SpectrAnalysis_OsMA");
//--- определение точности отображения значений индикатора 
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| i-SpectrAnalysis_OsMA iteration function                         | 
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
//--- проверка количества баров на достаточность для расчета 
   if(rates_total<min_rates_total || BarsCalculated(Ind_Handle)<rates_total) return(RESET);
   int end=M-1;
//---- осуществление сдвига начала отсчёта отрисовки индикаторов
   int drawbegin=rates_total-end;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,drawbegin);
//----  
   for(int bar=rates_total-1; bar>=prev_calculated && !IsStopped(); bar--) IndBuffer[bar]=NULL;
//---- копируем вновь появившиеся данные в массив 
   if(CopyBuffer(Ind_Handle,0,0,M,aa)<=0) return(RESET); 
   fastcosinetransform(aa,tnn1,false);
   for(int kkk=0; kkk<=end && !IsStopped(); kkk++) if(kkk>=ss) aa[kkk]=NULL;
   fastcosinetransform(aa,tnn1,true);
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++) IndBuffer[rrr]=aa[rrr]/_Point;
//---- 
if(prev_calculated>rates_total || prev_calculated<=0) end--;
//---- Основной цикл раскраски индикатора
   for(int rrr=0; rrr<=end && !IsStopped(); rrr++)
     {
      int clr=2;
      double diff=IndBuffer[rrr]-IndBuffer[rrr+1]; 
      double OsMA=IndBuffer[rrr];

      if(OsMA>0)
        {
         if(diff>0.0) clr=0;
         if(diff<0.0) clr=1;
        }

      if(OsMA<0)
        {
         if(diff<0.0) clr=4;
         if(diff>0.0) clr=3;
        }
      ColorIndBuffer[rrr]=clr;
     }
//----         
   return(rates_total);
  }
//+------------------------------------------------------------------+ 

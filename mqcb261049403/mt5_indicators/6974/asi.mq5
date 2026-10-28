//+------------------------------------------------------------------+
//|                                                          ASI.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 1
#property indicator_buffers 1 
//--- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован Coral цвет
#property indicator_color1 clrCoral
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 1
#property indicator_width1  1
//--- отображение метки индикатора
#property indicator_label1  "ASI"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint T = 300;        // Предел отклонения
input uint ATRPeriod=1;    // ATR период
//+-----------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtBuffer[];
//--- объявление целочисленных переменных для хранения хендлов индикаторов
int Ind_Handle;
//---
double dT;
//--- объявление целочисленных переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=int(ATRPeriod+1);
//--- получение хендла индикатора iATR
   Ind_Handle=iATR(Symbol(),PERIOD_CURRENT,ATRPeriod);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iATR");
      return(INIT_FAILED);
     }
//--- инициализация сдвига
   dT=_Point*T;
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBuffer,true);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ASI");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(rates_total<min_rates_total || BarsCalculated(Ind_Handle)<rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar,bar1;
//--- объявление переменных с плавающей точкой  
   double ATR[],TR,ER,K,SH,R,res;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- расчёты необходимого количества копируемых данных и
//--- стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      bar1=limit+1;
      ExtBuffer[bar1]=high[bar1]-low[bar1];
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//---   
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- первый цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar1=bar+1;
      TR=ATR[bar];
      if(close[bar+1]>=low[bar] && close[bar+1]<=high[bar]) ER=0.0;
      else
        {
         if(close[bar1]> high[bar]) ER=MathAbs(high[bar]-close[bar1]);
         if(close[bar1] < low[bar]) ER=MathAbs(low[bar]-close[bar1]);
        }
      K=MathMax(MathAbs(high[bar]-close[bar1]),MathAbs(low[bar]-close[bar1]));
      SH= MathAbs(close[bar1]-open[bar1]);
      R = TR-0.5*ER+0.25*SH;
      if(R) res=50*(close[bar]-close[bar+1]+0.5*(close[bar]-open[bar])+0.25*(close[bar+1]-open[bar+1]))*(K/dT)/R;
      else res=0.0;
      ExtBuffer[bar]=ExtBuffer[bar+1]+res;
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
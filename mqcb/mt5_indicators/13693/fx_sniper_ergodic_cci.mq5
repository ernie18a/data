//+------------------------------------------------------------------+
//|                                            FX_Sniper_Ergodic_CCI |
//|                                      Copyright © 2004, Fx Sniper |
//|                                                                  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2004, Fx Sniper"
//---- авторство индикатора
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
#property description "Louw Coetzer aka FX Sniper"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора CCI           |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "CCI"
//+----------------------------------------------+
//| Параметры отрисовки индикатора ErgoCCI       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkOrchid цвет
#property indicator_color2  clrDarkOrchid
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "FX Sniper Ergo/CCI"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CMoving_Average              |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CEMA из файла SmoothAlgorithms.mqh
CMoving_Average EMA1,EMA2,EMA3,EMA4,EMA5,EMA6;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint pq=2;
input uint pr=14;
input uint ps=5;
input uint CCI_period=14;
input int  Shift=0;       // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double CCIBuffer[];
double ErgoCCIBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int CCI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(CCI_period+1+pr+pq+ps);
//---- получение хендла индикатора CCI
   CCI_Handle=iCCI(NULL,0,CCI_period,PRICE_TYPICAL);
   if(CCI_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора CCI");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,CCIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(CCIBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ErgoCCIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ErgoCCIBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"FX Sniper Ergo/CCI");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar,MaxBarA,MaxBarB,MaxBarC;
   double dc,absdc,e1dc,e1absdc,e2dc,e2absdc,e3dc,e3absdc;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=int(rates_total-CCI_period-1); // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//----
   to_copy=limit+1;
//----
   MaxBarA=int(rates_total-min_rates_total-CCI_period-1);
   MaxBarB=int(MaxBarA-pq);
   MaxBarC=int(MaxBarB-pr);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCIBuffer)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      dc=close[bar]-close[bar+1];
      absdc=MathAbs(dc);
      //----
      e1dc=EMA1.EMASeries(MaxBarA,prev_calculated,rates_total,pq,dc,bar,true);
      e1absdc=EMA2.EMASeries(MaxBarA,prev_calculated,rates_total,pq,absdc,bar,true);
      //----
      e2dc=EMA3.EMASeries(MaxBarB,prev_calculated,rates_total,pr,e1dc,bar,true);
      e2absdc=EMA4.EMASeries(MaxBarB,prev_calculated,rates_total,pr,e1absdc,bar,true);
      //----
      e3dc=EMA3.EMASeries(MaxBarC,prev_calculated,rates_total,ps,e2dc,bar,true);
      e3absdc=EMA4.EMASeries(MaxBarC,prev_calculated,rates_total,ps,e2absdc,bar,true);
      //----
      if(e3absdc) ErgoCCIBuffer[bar]=450*e3dc/e3absdc;
      else ErgoCCIBuffer[bar]=50;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

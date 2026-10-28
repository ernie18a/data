//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh                  |
//| следует положить в папку: каталог_данных_терминала\MQL5\Include  |
//+------------------------------------------------------------------+
#property copyright "2010,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color1  clrLimeGreen
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int LRMAPeriod=13; //Период LRMA
input int LRMAShift=0; //Сдвиг LRMA по горизонтали в барах
input int LRMAPriceShift=0; //Сдвиг LRMA по вертикали в пунктах
//+----------------------------------------------+

//--- Индикаторный буфер
double ExtLineBuffer[];

double dPriceShift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- имя для окон данных и лэйба для субъокон 
   string short_name="LRMA";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"("+string(LRMAPeriod)+")");
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,LRMAPeriod+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига мувинга по горизонтали на LRMAShift
   PlotIndexSetInteger(0,PLOT_SHIFT,LRMAShift);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*LRMAPriceShift;
//---- объявление переменной класса Moving_Average из файла MASeries_Cls.mqh
   CMoving_Average LRMA1;
//---- установка алертов на недопустимые значения внешних переменных
   LRMA1.MALengthCheck("LRMAPeriod",LRMAPeriod);
//----
  }
//+------------------------------------------------------------------+
// Описание классов усреднения и индикаторов                         |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
#include <IndicatorsAlgorithms.mqh> 
//+------------------------------------------------------------------+ 
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate
(
 const int rates_total,// количество истории в барах на текущем тике
 const int prev_calculated,// количество истории в барах на предыдущем тике
 const int begin,// номер начала достоверного отсчёта баров
 const double &price[]// ценовой массив для расчёта индикатора
 )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<begin+LRMAPeriod)
      return(0);

//---- объявления локальных переменных 
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=begin; // стартовый номер для расчёта всех баров
      for(bar=0; bar<=begin; bar++)
         ExtLineBuffer[bar]=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- объявление переменной класса Moving_Average из файла LRMASeries_Cls.mqh
   static CLRMA LRMA1;

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- Получение среднего значения. Один вызов функции LRMASeries.  
      ExtLineBuffer[bar]=LRMA1.LRMASeries(begin,prev_calculated,rates_total,LRMAPeriod,price[bar],bar,false)+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

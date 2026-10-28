//+------------------------------------------------------------------+
//|                                                  FivePattern.mq5 |
//|                                     Copyright 2014, A. Emelyanov |
//|                                        A.Emelyanov2010@yandex.ru |
//+------------------------------------------------------------------+
//| Indicator: М & W Wave Patterns by A. Merrill                     |
//| Первоисточник:                                                   |
//| М & W Wave Patterns by Arthur A. Merrill, Chappaqua,             |
//| N.Y.: Analysis Press, 1983                                       |
//+------------------------------------------------------------------+
//| Now   version 2.01 - stable, for trade.                          |
//| Prev. version 1.XX - for test.                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, A. Emelyanov"
#property link      "A.Emelyanov2010@yandex.ru"
#property version   "2.01"
//+------------------------------------------------------------------+
//| Подключаемые ресурсы (иконка)                                    |
//+------------------------------------------------------------------+
//#property icon "\\Images\\fp.ico"
//+------------------------------------------------------------------+
//| Описание индикатора (инструкция пользователя)                    |
//+------------------------------------------------------------------+
#property description "М and W Wave Patterns by A. Merrill.\n"
#property description "№  Name Indicator buffers:"
#property description "0  ExtPointE[]    - Point E;"
#property description "1  ExtDeltaDE[]   - Delta DE;"
#property description "2  ExtEvolution[] - Point Evolution;"
#property description "3  ExtMutation[]  - Point Mutation;"
#property description "4  ExtSumModel[]  = Count_Evolution/(Count_Evolution + Count_Mutation)."
//+------------------------------------------------------------------+
//| Основные свойства индикатора                                     |
//+------------------------------------------------------------------+
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_label1  "Point E"
#property indicator_type1   DRAW_NONE
#property indicator_label2  "Delta DE"
#property indicator_type2   DRAW_NONE
#property indicator_label3  "Evolution"
#property indicator_type3   DRAW_NONE
#property indicator_label4  "Mutation"
#property indicator_type4   DRAW_NONE
#property indicator_label5  "Sum Model"
#property indicator_type5   DRAW_NONE
//+------------------------------------------------------------------+
//| Подключаемые библиотеки                                          |
//+------------------------------------------------------------------+
#include <MyMath\Pattern\MyCPatternZigzag.mqh>
#include <MyArrays\MyCListPattern.mqh>
#include <MyObjects\MyCComment.mqh>
//+------------------------------------------------------------------+
//| input parameters                                                 |
//+------------------------------------------------------------------+
//--- Main
input  int             Depth      = 24;         // Zigzag: Ширина окна поиска(Depth)
input  int             Deviation  = 12;         // Zigzag: Изменение цены в пуктах(Deviation)
input  int             Backstep   = 9;          // Zigzag: Отсутп от начала данных(Backstep)
sinput int             HistSize   = 500;        // Zigzag: Размер истории для расчетов
//--- Arrow
sinput color           ColorArrow = clrBlue;    // Цвет паттерных точек
//--- Trend
sinput color           ColorTrend = clrGold;    // Цвет паттерной линии
sinput int             WidthTrend = 2;          // Толщина паттерной линии
sinput bool            BackTrend  = true;       // Задний план для паттерной линии
sinput ENUM_LINE_STYLE StyleTrend = STYLE_SOLID;// Стиль паттерной линии
//--- HLine
sinput color           ColorUpHLine   = clrBlue;// Цвет линии сопротивления        
sinput color           ColorDownHLine = clrRed; // Цвет линии поддержки        
sinput int             WidthHLine = 2;          // Толщина линий уровня
sinput bool            BackHLine  = true;       // Задний план для линий уровня
sinput ENUM_LINE_STYLE StyleHLine = STYLE_SOLID;// Стиль линий уровня
//+------------------------------------------------------------------+
//| Глобальные переменные                                            |
//+------------------------------------------------------------------+
int                    Line       = 1;          // Номер первой строки комментария
MyCPatternZigzag*      MyPatternZigzag;         // Класс: модели паттерной системы
MyCListPattern*        MyListPattern;           // Класс: хранилище графических объектов
MyCComment*            MyComment;               // Класс: комментария
//+------------------------------------------------------------------+
//|Буфера для индикатора(использовать в генераторе торговых сигналов)|
//+------------------------------------------------------------------+
double                 ExtPointE[];             // Буфер: для хранения точки E
double                 ExtDeltaDE[];            // Буфер: для хранения длины волны D-E(в пунктах!)
double                 ExtEvolution[];          // Буфер: для хранения эволюций
double                 ExtMutation[];           // Буфер: для хранения мутаций
double                 ExtSumModel[];           // Буфер: для хранения счетчика-модели
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Подготовка графика цен, график должен быть смещен от правого угла, иначе пользователь не увидит прогноза
   if(!ChartShiftGet(0))
     {
      ChartShiftSet(true, 0);
     }
   //---
   SetIndexBuffer(0,ExtPointE,    INDICATOR_DATA);
   SetIndexBuffer(1,ExtDeltaDE,   INDICATOR_DATA);
   SetIndexBuffer(2,ExtEvolution, INDICATOR_DATA);
   SetIndexBuffer(3,ExtMutation,  INDICATOR_DATA);
   SetIndexBuffer(4,ExtSumModel,  INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   //--- 
   MyPatternZigzag= new MyCPatternZigzag;
   MyComment      = new MyCComment;
   MyListPattern  = new MyCListPattern;
   //--- Main
   MyPatternZigzag.SetDepth(Depth);
   MyPatternZigzag.SetDeviation(Deviation);
   MyPatternZigzag.SetBackstep(Backstep);
   MyPatternZigzag.AddPointerCommet(MyComment);
   MyPatternZigzag.SetNumberLineComment(Line);         // номер строки коммента
   MyPatternZigzag.SetSizeBuffers(HistSize);
   //--- Arrow, HLine & Trend
   MyListPattern.SetColorArrow(ColorArrow);
   MyListPattern.SetColorTrend(ColorTrend);
   MyListPattern.SetStyleTrend(StyleTrend);
   MyListPattern.SetWidthTrend(WidthTrend);
   MyListPattern.SetBackTrend(BackTrend);
   MyListPattern.SetStyleHLine(StyleHLine);
   MyListPattern.SetColorUpHLine(ColorUpHLine);
   MyListPattern.SetColorDownHLine(ColorDownHLine);
   MyListPattern.SetWidthHLine(WidthHLine);
   MyListPattern.SetBackHLine(BackHLine);
   //---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete MyPatternZigzag;
   delete MyListPattern;
   delete MyComment;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   //--- нельзя расчитывать индикатор при "малой истории"
   if(rates_total > HistSize)
     {
      //--- есть ли что считать? и был ли расчет до этого...
      int nHowMush = rates_total-prev_calculated;
      //--- Цикл подсчета
      if(nHowMush > 0)
        {
         //--- Временные переменные
         double   new_high[],new_low[];
         datetime new_time[];
         //--- Определяем размер буферов
         ArrayResize(new_high,HistSize,0);
         ArrayResize(new_low,HistSize,0);
         
         ArrayResize(new_time,HistSize,0);
         //--- Узнаем от КУДА и СКОЛЬКО считать
         int nStart = 0;                              // Индекс начала расчетов(окончание)
         int nCopy  = 0;                              // Индекс с которого начинается копирование во временные буфера
         if(prev_calculated == 0)
           {//--- Начало расчетов
            nStart = HistSize - 1;
           }else
              {//--- Продолжение расчетов
               nStart = prev_calculated - 1;
              }
         //--- Подсчет
         for(;nStart<rates_total;nStart++)
           {
            //--- Место от куда начинать копировать
            nCopy = 1+nStart-HistSize;
            //--- Копирование данных
            ArrayCopy(new_low, low, 0,nCopy,HistSize);
            ArrayCopy(new_high,high,0,nCopy,HistSize);
            ArrayCopy(new_time,time,0,nCopy,HistSize);
            //--- Расчет
            MyPatternZigzag.GetNamePattern(new_high,new_low,new_time);
            //--- Запоминаем данные: Evolution, Mutation, SumModel
            double dwDE          = MathAbs(MyPatternZigzag.GetE()-MyPatternZigzag.GetD());
            dwDE                 = dwDE/_Point;
            ExtDeltaDE[nStart]   = dwDE;                               // Буфер для хранения длины волны D-E
            ExtPointE[nStart]    = MyPatternZigzag.GetE();             // Буфер для хранения точки E
            ExtEvolution[nStart] = MyPatternZigzag.GetPointEvolution();// Буфер для хранения эволюций
            ExtMutation[nStart]  = MyPatternZigzag.GetPointMutation(); // Буфер для хранения мутаций
            ExtSumModel[nStart]  = MyPatternZigzag.GetSumModel();      // Буфер для хранения счетчика-модели
           }
         //--- Вывод графики
         DrawPattern();
        }
     }else
        {
         return(0);
        }
   //--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Функция для отображения расчетов на графике                      |
//+------------------------------------------------------------------+
void DrawPattern(void)
  {
   //--- 1. выводим на экран коммент
   MyPatternZigzag.PrintComment();
   //--- 2. выводим на экран графику
   MyListPattern.Insert(MyPatternZigzag.GetA(), MyPatternZigzag.GetTimeA(), 
                        MyPatternZigzag.GetB(), MyPatternZigzag.GetTimeB(),
                        MyPatternZigzag.GetC(), MyPatternZigzag.GetTimeC(),
                        MyPatternZigzag.GetD(), MyPatternZigzag.GetTimeD(),
                        MyPatternZigzag.GetE(), MyPatternZigzag.GetTimeE(),
                        MyPatternZigzag.GetPointEvolution(),MyPatternZigzag.GetTimeEvolution(),
                        MyPatternZigzag.GetPointMutation(), MyPatternZigzag.GetTimeMutation());   
  }
//+------------------------------------------------------------------+
//| Функция определяет, включен ли режим отображения ценового графика|
//| с отступом от правого края.                                      |
//+------------------------------------------------------------------+
bool ChartShiftGet(long chart_ID=0)
  {
   //--- подготовим переменную для получения значения свойства
   long value;
   //--- сбросим значение ошибки
   ResetLastError();
   //--- получим значение свойства
   if(!ChartGetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
   //--- проверим value... :-)
   if(value <= 0) return(false);
   //--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Функция включает/выключает режим отображения ценового графика с  |
//| отступом от правого края.                                        |
//+------------------------------------------------------------------+
bool ChartShiftSet(bool value, long chart_ID=0)
  {
   //--- сбросим значение ошибки
   ResetLastError();
   //--- установим значение свойства
   if(!ChartSetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
   //--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
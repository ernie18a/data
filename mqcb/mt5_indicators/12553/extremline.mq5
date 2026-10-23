//+------------------------------------------------------------------+
//|                                                   ExtremLine.mq5 |
//|                                 Copyright © 2014 Serkov Alexandr | 
//|                                          serkov-alexandr@mail.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2014 Serkov Alexandr"
//--- ссылка на сайт автора
#property link "serkov-alexandr@mail.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color1  clrLime
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "Bulls ExtremLine"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  clrRed
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Bears ExtremLine"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint IndPeriod= 10; // период индикатора 
input int IndShift = 0;   // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double BullsIndBuffer[];
double BearsIndBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=int(IndPeriod);
   
//--- превращение динамического массива BullsIndBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsIndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на IndShift
   PlotIndexSetInteger(0,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//--- превращение динамического массива BearsIndBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsIndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на IndShift
   PlotIndexSetInteger(1,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ExtremLine(",IndPeriod,", ",IndShift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//--- объявления локальных переменных 
   int first,bar;
   bool dir;

//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(high[bar]>high[bar-IndPeriod]) dir=true;
      if(low[bar]<low[bar-IndPeriod]) dir=false;
      if(dir==true)
        {
         BullsIndBuffer[bar]=high[bar];
         BullsIndBuffer[bar-1]=high[bar-1];
         BearsIndBuffer[bar]=0.0;
        }
      else
        {
         BearsIndBuffer[bar]=low[bar];
         BearsIndBuffer[bar-1]=low[bar-1];
         BullsIndBuffer[bar]=0.0;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

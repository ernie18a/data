//+------------------------------------------------------------------+
//|                                                      Notches.mq5 |
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
//--- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//--- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован голубой цвет
#property indicator_color1  clrDeepSkyBlue
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "Bulls Notches 1"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Bears Notches 1"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color3  clrLime
//--- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//--- отображение бычей метки индикатора
#property indicator_label3  "Bulls Notches 1"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color4  clrRed
//--- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//--- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//--- отображение медвежьей метки индикатора
#property indicator_label4  "Bears Notches 1"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int IndShift=0;   // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double BullsIndBuffer1[];
double BearsIndBuffer1[];
double BullsIndBuffer2[];
double BearsIndBuffer2[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=2;
//--- превращение динамического массива BullsIndBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на IndShift
   PlotIndexSetInteger(0,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BearsIndBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на IndShift
   PlotIndexSetInteger(1,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BullsIndBuffer в индикаторный буфер
   SetIndexBuffer(2,BullsIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на IndShift
   PlotIndexSetInteger(2,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BearsIndBuffer в индикаторный буфер
   SetIndexBuffer(3,BearsIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на IndShift
   PlotIndexSetInteger(3,PLOT_SHIFT,IndShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Notches(",IndShift,")");
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
   int first,bar,x,y;
   static int x_,y_;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_total; // стартовый номер для расчёта всех баров
      x_=0;
      y_=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---
   x=x_;
   y=y_;
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      BearsIndBuffer1[bar]=0.0;
      BullsIndBuffer1[bar]=0.0;
      BearsIndBuffer2[bar]=0.0;
      BullsIndBuffer2[bar]=0.0;

      if(high[bar]>high[bar-1])
        {
         if(x==1)
           {
            BullsIndBuffer1[bar]=high[bar];
            BullsIndBuffer1[bar-1]=high[bar-1];
            x=2;
           }
         else
           {
            BullsIndBuffer2[bar]=high[bar];
            BullsIndBuffer2[bar-1]=high[bar-1];
            x=1;
           }
        }
      //---
      if(low[bar]<low[bar-1])
        {
         if(y==1)
           {
            BearsIndBuffer1[bar]=low[bar];
            BearsIndBuffer1[bar-1]=low[bar-1];
            y=2;
           }
         else
           {
            BearsIndBuffer2[bar]=low[bar];
            BearsIndBuffer2[bar-1]=low[bar-1];
            y=1;
           }
        }
      //---
      if(bar<rates_total-1)
        {
         x_=x;
         y_=y;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

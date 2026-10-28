//+------------------------------------------------------------------+
//|                                               RoundPrice-Ext.mq5 |
//|                                         Copyright © 2004, Tartan |
//|                http://forum.alpari-idc.ru/viewtopic.php?t=48186/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, Tartan"
#property link      "http://forum.alpari-idc.ru/viewtopic.php?t=48186/"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 7
#property indicator_buffers 7
//---- использовано всего семь графических построений
#property indicator_plots   7
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Gold цвет
#property indicator_color1 clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Line 1"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color2 clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Line 2"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color3 clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Line 3"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 4 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Aqua цвет
#property indicator_color4 clrAqua
//---- линия индикатора - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "Line 4"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 5 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color5 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "Line 5"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 6 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использованMagenta цвет
#property indicator_color6 clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width6  1
//---- отображение метки индикатора
#property indicator_label6  "Line 6"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 7 |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type7   DRAW_LINE
//---- в качестве цвета линии индикатора использован Purple цвет
#property indicator_color7 clrPurple
//---- линия индикатора - непрерывная кривая
#property indicator_style7  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width7  1
//---- отображение метки индикатора
#property indicator_label7  "Line 7"

//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input double t3_period=8.0;
input double b=0.7;
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double e0Buffer[];
double e1Buffer[];
double e2Buffer[];
double e3Buffer[];
double e4Buffer[];
double e5Buffer[];
double e6Buffer[];
double c1,c2,c3,c4,n,w1,w2,b2,b3;
double dpo,t3;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Инициализация индикатора                                        |
//+------------------------------------------------------------------+
void IndicatorInit
(
 uint   number,
 int    shift,
 uint   drawbegin,
 double empty_value,
 double &Arrow[]
 )
//---- 
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(number,Arrow,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(number,PLOT_SHIFT,shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(number,PLOT_DRAW_BEGIN,drawbegin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(number,PLOT_EMPTY_VALUE,empty_value);
  }
//+------------------------------------------------------------------+   
//| RoundPrice-Ext indicator initialization function                 | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
//----
   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   n=t3_period;
//----
   if(n<1) n=1;
   n=1+0.5*(n-1);
   w1=2/(n + 1);
   w2=1 - w1;

//---- Инициализация индикаторов
   IndicatorInit(0,Shift,min_rates_total,0,e0Buffer);
   IndicatorInit(1,Shift,min_rates_total,0,e1Buffer);
   IndicatorInit(2,Shift,min_rates_total,0,e2Buffer);
   IndicatorInit(3,Shift,min_rates_total,0,e3Buffer);
   IndicatorInit(4,Shift,min_rates_total,0,e4Buffer);
   IndicatorInit(5,Shift,min_rates_total,0,e5Buffer);
   IndicatorInit(6,Shift,min_rates_total,0,e6Buffer);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"RoundPrice-Ext");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| RoundPrice-Ext iteration function                                | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчёта баров
                const double &price[]     // ценовой массив для расчёта индикатора
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total+begin) return(0);

//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1+begin; // стартовый номер для расчёта всех баров
      //---- осуществление сдвига начала отсчёта отрисовки индикаторов
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,first);
      PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,first);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dpo=price[bar];
      e1Buffer[bar]=w1*dpo + w2*e1Buffer[bar-1];
      e2Buffer[bar]=w1*e1Buffer[bar] + w2*e2Buffer[bar-1];
      e3Buffer[bar]=w1*e2Buffer[bar] + w2*e3Buffer[bar-1];
      e4Buffer[bar]=w1*e3Buffer[bar] + w2*e4Buffer[bar-1];
      e5Buffer[bar]=w1*e4Buffer[bar] + w2*e5Buffer[bar-1];
      e6Buffer[bar]=w1*e5Buffer[bar] + w2*e6Buffer[bar-1];
      //----
      t3=c1*e6Buffer[bar]+c2*e5Buffer[bar]+c3*e4Buffer[bar]+c4*e3Buffer[bar];
      //----
      if(!t3) t3=dpo;
      //----
      e0Buffer[bar]=t3;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

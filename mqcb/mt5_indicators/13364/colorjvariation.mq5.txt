//+---------------------------------------------------------------------+
//|                                                 ColorJVariation.mq5 | 
//|                                            Copyright © 2010, LeMan. |
//|                                                    b-market@mail.ru |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, LeMan."
#property link      "b-market@mail.ru"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде трехцветной линии
#property indicator_type1 DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1 clrGray,clrLime,clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "JVariation"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_SOLID
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Period_=12;  // Период усреднения
input ENUM_MA_METHOD MA_Method_=MODE_SMA; // Метод усреднения  
input int JLength_=3;  // Глубина JMA сглаживания                   
input int JPhase_=100; // Параметр JMA сглаживания
                       // изменяющийся в пределах -100 ... +100,
                       // влияет на качество переходного процесса
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- индикаторный буфер
double LineBuffer[],ColorLineBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Описание класса Moving_Average                                   |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| Variation indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(3*Period_+30+1);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JVariation");
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorLineBuffer,INDICATOR_COLOR_INDEX);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JVariation( Period_ = ",Period_,", MA_Method_ = ",MA_Method_,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Variation iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//---- объявление целочисленных переменных
   int first1,first2=0,bar;
//---- объявление переменных с плавающей точкой  
   double ma1,ma2,ma3,jma3;
//---- объявление статических переменных
   static int start1,start2,start3,start4;
//---- инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first1=begin; // стартовый номер для расчета всех баров
      //---- инициализация переменных начала отсчета данных
      start1=begin;
      //----
      if(MA_Method_!=MODE_EMA)
        {
         start2 = start1 + Period_;
         start3 = start2 + Period_;
         start4 = start3 + Period_;
         first2 = start4 + 30 + 2;
        }
      else
        {
         start2 = start1 + 30;
         start3 = start2 + 30;
         start4 = start3 + 30;
         first2 = start4 + 30 + 2;
        }
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,first2);
     }
   else
     {
      first1=prev_calculated-1; // стартовый номер для расчета новых баров
      first2=first1;
     }
//---- объявление переменных класса Moving_Average из файла SmoothAlgorithms.mqh
   static CMoving_Average MA1,MA2,MA3;
//---- объявление переменных класса JJMA из файла SmoothAlgorithms.mqh
   static CJJMA JMA;
//---- основной цикл расчета индикатора
   for(bar=first1; bar<rates_total; bar++)
     {
      //---- три вызова функции MASeries
      ma1 = MA1.MASeries(start1, prev_calculated, rates_total, Period_, MA_Method_, price[bar], bar, false);
      ma2 = MA2.MASeries(start2, prev_calculated, rates_total, Period_, MA_Method_, price[bar]-ma1, bar, false);
      ma3 = MA3.MASeries(start3, prev_calculated, rates_total, Period_, MA_Method_, price[bar]-ma2-ma1, bar, false);
      //---- один вызов функции JJMASeries
      //---- параметры Phase и Length не меняются на каждом баре (Din = 0) 
      jma3=JMA.JJMASeries(start4,prev_calculated,rates_total,0,JPhase_,JLength_,ma3,bar,false);
      //----
      LineBuffer[bar]=jma3;
     }
//---- основной цикл раскраски линии индикатора
   for(bar=first2; bar<rates_total; bar++)
     {
      ColorLineBuffer[bar]=0;
      if(LineBuffer[bar]>LineBuffer[bar-1]) ColorLineBuffer[bar]=1;
      if(LineBuffer[bar]<LineBuffer[bar-1]) ColorLineBuffer[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

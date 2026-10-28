//+---------------------------------------------------------------------+
//|                                                           J2JMA.mq5 | 
//|                                  Copyright © 2010, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован розовый цвет
#property indicator_color1 clrMagenta 
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "J2JMA"
//+------------------------------------------------+ 
//| Объявление перечислений                        |
//+------------------------------------------------+ 
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+ 
//| Входные параметры индикатора                   |
//+------------------------------------------------+ 
input double Length1 = 5; // Глубина  первого сглаживания
input double Length2 = 5; // Глубина  второго сглаживания
input double Phase1= 100; // Параметр первого сглаживания
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input double Phase2=100;  // Параметр второго сглаживания
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_; // Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+------------------------------------------------+ 
//---- индикаторные буферы
double J2JMA[];
//----
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| Описание класса CJJMA                                            |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| J2JMA indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_=30;
   min_rates_total=min_rates_+31;
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,J2JMA,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"J2JMA( Length1 = ",Length1,", Length2 = ",Length2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMALengthCheck("Length1", (int)Length1);
   JMA.JJMALengthCheck("Length2", (int)Length2);
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMAPhaseCheck("Phase1", (int)Phase1);
   JMA.JJMAPhaseCheck("Phase2", (int)Phase2);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| J2JMA iteration function                                         | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price,j1jma,j2jma;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных класса CJJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA1,JMA2;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---- два вызова функции JJMASeries
      //---- параметры Phase и Length не меняются на каждом баре (Din = 0)
      //---- во втором вызове параметр begin увеличен на 30, т.к. это повторное JMA сглаживание
      j1jma=JMA1.JJMASeries(0,prev_calculated,rates_total,0,Phase1,Length1,price,bar,false);
      j2jma=JMA2.JJMASeries(min_rates_,prev_calculated,rates_total,0,Phase2,Length2,j1jma,bar,false);
      //----       
      J2JMA[bar]=j2jma+dPriceShift;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+

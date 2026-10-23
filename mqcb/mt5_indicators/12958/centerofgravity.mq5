//+---------------------------------------------------------------------+
//|                                                 CenterOfGravity.mq4 |
//|                         Copyright © 2007, MetaQuotes Software Corp. |
//|                                          https://www.metaquotes.net |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде трёхцветной линии
#property indicator_type1 DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1 clrGray,clrLime,clrRed
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора 1
#property indicator_label1  "Center of Gravity"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора 2
#property indicator_label2  "Signal Line"
//---- стиль линии - штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Period_=10; // Период усреднения индикатора
input uint SmoothPeriod=3; // Период сглаживания сигнальной линии
input ENUM_MA_METHOD MA_Method_=MODE_SMA; // Метод усреднения сигнальной линии
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Ценовая константа
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double Ext1Buffer[];
double Ext2Buffer[];
double ColorExt2Buffer[];
//---- объявление целочисленых переменных начала отсчёта данных
int min_rates_total;
//---
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   min_rates_total=int(Period_+1+SmoothPeriod+2);
//---- превращение динамического массива MAMABuffer в индикаторный буфер
   SetIndexBuffer(0,Ext1Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExt2Buffer,INDICATOR_COLOR_INDEX);
//---- превращение динамического массива FAMABuffer в индикаторный буфер
   SetIndexBuffer(2,Ext2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Center of Gravity(",Period_,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price_,sma,lwma;
//---- объявление целочисленных переменных
   int first1,first2,first3,bar;
   static int startbar;
//---- инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first1=0; // стартовый номер для расчёта всех баров первого цикла
      first2=int(Period_+1); // стартовый номер для расчёта всех баров сигнальной линии
      first3=int(Period_+SmoothPeriod+3); // стартовый номер для расчёта всех баров цикла раскраски
      startbar=int(Period_+1);
     }
   else // стартовый номер для расчёта новых баров
     {
      first1=prev_calculated-1;
      first2=first1;
      first3=first1;
     }
//---- объявление переменных класса Moving_Average
   static CMoving_Average MA,LWMA,SIGN;
//---- основной цикл расчёта средней линии канала
   for(bar=first1; bar<rates_total; bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены Series
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);
      //----
      sma=MA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,price_,bar,false);
      lwma=LWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,price_,bar,false);
      //----
      Ext1Buffer[bar]=sma*lwma/_Point;
      Ext2Buffer[bar]=SIGN.MASeries(startbar,prev_calculated,rates_total,SmoothPeriod,MA_Method_,Ext1Buffer[bar],bar,false);
     }
//---- основной цикл раскраски сигнальной линии
   for(bar=first3; bar<rates_total; bar++)
     {
      ColorExt2Buffer[bar]=0;
      if(Ext1Buffer[bar]<Ext2Buffer[bar])
         ColorExt2Buffer[bar]=2;
      else ColorExt2Buffer[bar]=1;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+

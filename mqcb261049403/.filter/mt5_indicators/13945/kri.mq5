//+---------------------------------------------------------------------+ 
//|                                                             KRI.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован золотой цвет
#property indicator_color1 clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "KRI"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum ENUM_PRICE_TYPE //тип константы
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int KRIPeriod=20; // Период усреднения
input ENUM_MA_METHOD MA_Method_=MODE_SMA; // Метод усреднения
input double Ratio=1.0;
input ENUM_PRICE_TYPE IPC=PRICE_CLOSE_; // Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double KRIBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int StartBar;
//+------------------------------------------------------------------+
//| Описание классов усреднения                                      |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------------------------+    
//| KRI indicator initialization function                            |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   StartBar=KRIPeriod+1;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,KRIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"KRI");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"KRI( KRIPeriod = ",KRIPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| KRI iteration function                                           | 
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
   if(rates_total<StartBar) return(0);
//---- объявление переменных с плавающей точкой  
   double price_,KRI,mov;
//---- объявление целочисленных переменных
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else // стартовый номер для расчета новых баров
     {
      first=prev_calculated-1;
     }
//---- объявление переменных классов Moving_Average и StdDeviation
   static CMoving_Average MA;
//---- основной цикл расчета средней линии канала
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены Series
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //----
      mov=MA.MASeries(0,prev_calculated,rates_total,KRIPeriod,MA_Method_,price_,bar,false);
      //----
      KRI=100 *(price_-mov)/mov;
      KRIBuffer[bar]=KRI;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+

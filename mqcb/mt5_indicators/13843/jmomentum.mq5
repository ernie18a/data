//+---------------------------------------------------------------------+
//|                                                       JMomentum.mq5 | 
//|                                Copyright © 2010,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh следует положить    |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.03"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован коричневый цвет
#property indicator_color1 clrMaroon
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "JMomentum"
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
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
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price  
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int MLength=8;  // Глубина  сглаживания
input int JLength=8;  // Глубина JMA сглаживания индикатора Momentum
input int JPhase=100; // Параметр JMA сглаживания
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double JMomentum[];
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание функции iPriceSeriesAlert                               |
//| Описание класса CMomentum                                        |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+   
//| JMomentum indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,JMomentum,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,0);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"JMomentum");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JMomentum( MLengthh = ",MLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- объявление переменной класса CMomentum из файла SmoothAlgorithms.mqh
   CMomentum Mom;
//---- объявление переменной класса CJJMA из файла SmoothAlgorithms.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   Mom.MALengthCheck("MLength", MLength);
   JMA.JJMALengthCheck("JLength", JLength);
   JMA.JJMAPhaseCheck("JPhase", JPhase);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| JMomentum iteration function                                     | 
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
   if(rates_total<MLength+31) return(0);
//---- объявление переменных с плавающей точкой  
   double price,momentum,jmomentum;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated==0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных классов CMomentum и CJJMA из файла SmoothAlgorithms.mqh
   static CMomentum Mom;
   static CJJMA JMA;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения приращения входной цены dprice_
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---- два вызова функции MomentumSeries
      momentum=Mom.MomentumSeries(0,prev_calculated,rates_total,MLength,price,bar,false);
      //---- один вызов функции JJMASeries
      //---- параметры Phase и Length не меняются на каждом баре (Din = 0)
      jmomentum=JMA.JJMASeries(MLength+1,prev_calculated,rates_total,0,JPhase,JLength,momentum,bar,false);
      //---- загрузка полученного значения в индикаторный буфер
      JMomentum[bar]=jmomentum;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//|                                                          EMA.mq5 | 
//|                    MQL5 code: Copyright © 2010, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
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
//---- в качестве цвета линии индикатора использован clrMediumSlateBlue цвет
#property indicator_color1 clrMediumSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1  "EMA"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //Тип константы
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
input double EmaLength=12.75;             // Глубина сглаживания
input Applied_price_ IPC=PRICE_CLOSE_;    // Ценовая константа
input int Shift=0;                        // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // Сдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//---- индикаторный буфер
double EMABuffer[];
double dPriceShift;
//---- объявление глобальных переменных
int min_rates_total;
//+------------------------------------------------------------------+
//| Описание класса CMoving_Average                                  |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| EMA indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,EMABuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"EMA");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"EMA( Length = ",EmaLength,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| EMA iteration function                                           | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление локальных переменных
   int first,bar;
   double series,ema;
//----
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-min_rates_total; // стартовый номер для расчета новых баров
//---- объявление переменных класса CMoving_Average из файла SmoothAlgorithms.mqh 
   static CMoving_Average EMA;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      series=PriceSeries(IPC,bar,open,low,high,close);
      ema=EMA.EMASeries(0,prev_calculated,rates_total,EmaLength,series,bar,false);
      EMABuffer[bar]=ema+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

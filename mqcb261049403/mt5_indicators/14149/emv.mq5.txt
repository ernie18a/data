//+---------------------------------------------------------------------+
//|                                                             EMV.mq5 |
//|                                  Copyright © 2011, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): terminal_data_folder\MQL5\Include             |
//+---------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
#property description "Ease of Movement Value"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован серо-голубой цвет
#property indicator_color1  clrMediumSlateBlue
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Ease of Movement Value"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_      // Тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE_,        // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method MA_SMethod=MODE_SMA;           // Метод усреднения
input int SmLength=14;                             // Глубина сглаживания                    
input int SmPhase=15;                              // Параметр сглаживания
input Applied_price_ IPC=PRICE_QUARTER_;           // Ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объем
input int Shift=0;                                 // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double EMVBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   StartBars=XMA1.GetStartBars(MA_SMethod,SmLength,SmPhase)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length", SmLength);
   XMA1.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);
//---- инициализация сдвига по вертикали
//---- превращение динамического массива EMVBuffer[] в индикаторный буфер
   SetIndexBuffer(0,EMVBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на StartBars
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Ease of Movement Value");
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<StartBars) return(0);
//---- объявления локальных переменных 
   int first,bar;
   double price0,price1,EMV;
   long Volume;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1;                                           // стартовый номер для расчета всех баров
     }
//----
   else first=prev_calculated-1;                         // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price0=PriceSeries(IPC,bar,  open,low,high,close);
      price1=PriceSeries(IPC,bar-1,open,low,high,close);
      //----
      if(VolumeType==VOLUME_TICK) Volume=long(tick_volume[bar]);
      else                        Volume=long(volume[bar]);
      //----
      if(Volume!=0) EMV=(price0-price1)*price0/(2*Volume);
      else          EMV=0;
      //----
      EMVBuffer[bar]=XMA1.XMASeries(1,prev_calculated,rates_total,MA_SMethod,SmPhase,SmLength,EMV,bar,false);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

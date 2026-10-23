//+------------------------------------------------------------------+
//|                                          ColorTSI-Oscillator.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                                                                  |
//|                                   Modified from TSI-Osc by Toshi |
//|                                  http://toshi52583.blogspot.com/ |
//+------------------------------------------------------------------+
//| Для работы  индикатора файл SmoothAlgorithms.mqh                 |
//| следует положить в папку: каталог_данных_терминала\\MQL5\Include |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора 1  |
//+-----------------------------------+
//---- стиль отрисовки индикатора
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы цвета DarkOrchid,DeepPink
#property indicator_color1 clrDarkOrchid,clrDeepPink
//---- отображение метки индикатора
#property indicator_label1  "TSI-Oscillator"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +50.0
#property indicator_level2   0.0
#property indicator_level3 -50.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Описание класса CMTM              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CMTM из файла SmoothAlgorithms.mqh
CXMA MTM1,MTM2,ABSMTM1,ABSMTM2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_      // тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price
  };
//---
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method First_Method=MODE_SMA;  // Метод усреднения 1
input int First_Length=12;                  // Глубина сглаживания 1
input int First_Phase=15;                   // Параметр сглаживания 1
input Smooth_Method Second_Method=MODE_SMA; // Метод усреднения 2
input int Second_Length=12;                 // Глубина сглаживания 2
input int Second_Phase=15;                  // Параметр сглаживания 2
input Applied_price_ IPC=PRICE_CLOSE;       // Ценовая константа
input int Shift=0;                          // Сдвиг индикатора по горизонтали в барах
input uint TriggerShift=1;                  // Сдвиг бара для триггера 
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_total1,min_rates_total2;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double TSIBuffer[],TriggerBuffer[];
//+------------------------------------------------------------------+   
//| TSI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total1=MTM1.GetStartBars(First_Method,First_Length,First_Phase)+1;
   min_rates_total2=min_rates_total1+MTM1.GetStartBars(First_Method,First_Length,First_Phase);
   min_rates_total=int(min_rates_total1+MTM1.GetStartBars(Second_Method,Second_Length,Second_Phase)+TriggerShift);
//---- установка алертов на недопустимые значения внешних переменных
   MTM1.XMALengthCheck("First_Length",First_Length);
   MTM1.XMAPhaseCheck("First_Phase",First_Phase, First_Method);
   MTM1.XMALengthCheck("Second_Length",Second_Length);
   MTM1.XMAPhaseCheck("Second_Phase",Second_Phase,Second_Method);
//---- превращение динамического массива TSIBuffer[] в индикаторный буфер
   SetIndexBuffer(0,TSIBuffer,INDICATOR_DATA);
//---- превращение динамического массива TriggerBuffer[] в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=MTM1.GetString_MA_Method(First_Method);
   string Smooth2=MTM1.GetString_MA_Method(Second_Method);
   StringConcatenate(shortname,"TSI-Oscillator(",Smooth1,", ",First_Length,", ",Smooth2,", ",Second_Length,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| TSI iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//---- объявление переменных с плавающей точкой  
   double dprice,absdprice,mtm1,absmtm1,mtm2,absmtm2;
//---- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dprice=price[bar]-price[bar-1];
      absdprice=MathAbs(dprice);
      //----
      mtm1=MTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,dprice,bar,false);
      absmtm1=ABSMTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,absdprice,bar,false);
      //----
      mtm2=MTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,mtm1,bar,false);
      absmtm2=ABSMTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,absmtm1,bar,false);
      //----
      if(bar>min_rates_total2) TSIBuffer[bar]=100.0*mtm2/absmtm2;
      else TSIBuffer[bar]=EMPTY_VALUE;
      //----
      if(bar>min_rates_total) TriggerBuffer[bar]=TSIBuffer[bar-TriggerShift];
      else                    TriggerBuffer[bar]=EMPTY_VALUE;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

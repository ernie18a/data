//+------------------------------------------------------------------+
//|                                              InverseReaction.mq5 |
//|                                      Copyright © 2013, Erdem Sen |
//|                          https://www.mql5.com/en/users/erdogenes |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Erdem Sen"
#property link "https://www.mql5.com/en/users/erdogenes" 
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использован
#property indicator_color1  clrLavender
//---- отображение бычей метки индикатора
#property indicator_label1  "InverseReaction Cloud"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде трёхцветной гистограммы
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трёхцветной гистограммы использованы
#property indicator_color2 clrMagenta,clrGray,clrMediumSpringGreen
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки индикатора
#property indicator_label2 "InverseReaction Histogram"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных классов CMomentum и CJJMA из файла SmoothAlgorithms.mqh
CMomentum Mom;
CXMA XMA;
//+-----------------------------------+
//|  объявление перечислений          |
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
//|  объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint     MomPeriod   = 1;                    // Momentum period
input Applied_price_   MOMPrice = PRICE_CLOSE;     // Momentum price
input uint     MaPeriod    = 3;                    // Moving average period
input int      MaPhase=15;                         // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input  Smooth_Method   MaType = MODE_EMA;          // Moving average type
input double   Coefficient = 1.618;                // Confidence coefficient
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[],IndBuffer[],ColorIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| InverseReaction indicator initialization function                | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MomPeriod+MaPeriod);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"InverseReaction");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| InverseReaction iteration function                               | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double price,mom,xmom;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(MOMPrice,bar,Open,Low,High,Close);
      mom=Mom.MomentumSeries(0,prev_calculated,rates_total,MomPeriod,price,bar,false)/_Point;
      xmom=Coefficient*XMA.XMASeries(MomPeriod,prev_calculated,rates_total,MaType,MaPhase,MaPeriod,MathAbs(mom),bar,false);
      
      UpIndBuffer[bar]=+xmom;
      DnIndBuffer[bar]=-xmom;
      IndBuffer[bar]=mom;   
      int clr=1;
      if(mom>+xmom) clr=2;
      if(mom<-xmom) clr=0;
      ColorIndBuffer[bar]=clr;
     }
//----     
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

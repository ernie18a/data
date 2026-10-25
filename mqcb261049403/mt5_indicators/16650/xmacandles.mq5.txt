//+------------------------------------------------------------------+
//|                                                   XMACandles.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "XMA Candles"
//--- номер версии индикатора
#property version   "1.01"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано 5 буферов
#property indicator_buffers 5
//--- использовано одно графическое построение
#property indicator_plots   1
//--- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrMediumOrchid,clrSlateBlue,clrGreen
//--- отображение метки индикатора
#property indicator_label1  "X2MA Open; High; Low; Close"
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA OpXMA,HiXMA,LoXMA,ClXMA;
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
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
//|  Входные параметры индикатора     |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_T3;     // Метод усреднения первого сглаживания 
input int Length1=12;                       // Глубина первого сглаживания                    
input int Phase1=15;                        // Параметр первого сглаживания, 
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0;                          // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=GetStartBars(MA_Method1, Length1, Phase1);
//--- установка алертов на недопустимые значения внешних переменных
   OpXMA.XMALengthCheck("Length1", Length1);
//--- установка алертов на недопустимые значения внешних переменных
   OpXMA.XMAPhaseCheck("Phase1", Phase1, MA_Method1);

//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//--- превращение динамического массива ExtColorBuffer[] в цветовой индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//--- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=OpXMA.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"XMA Candles(",Smooth1,", ",Length1,", ",Phase1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//--- объявление переменных с плавающей точкой  
   double ;
//--- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;

//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     { 
      ExtOpenBuffer[bar]=OpXMA.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      ExtHighBuffer[bar]=HiXMA.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar],bar,false);
      ExtLowBuffer[bar]=LoXMA.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,low[bar],bar,false);
      ExtCloseBuffer[bar]=ClXMA.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
     }

//---- Основной цикл исправления и окрашивания свечей
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      //----
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      //----
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

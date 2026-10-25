//+------------------------------------------------------------------+
//|                                                    BBflat_sw.mq5 | 
//|                                           Copyright © 2008, Raff | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, Raff"
#property link ""
#property description ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 3
#property indicator_buffers 3 
//--- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1 clrBlue
//--- линия индикатора - сплошная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "Signal Line"
//+--------------------------------------------+
//| Параметры отрисовки индикатора BB уровней  |
//+--------------------------------------------+
//--- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//--- ввыбор цветов уровней Боллинджера
#property indicator_color2  clrRed
#property indicator_color3  clrRed
//--- уровни Боллинджера - сплошные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//--- толщина уровней Боллинджера равна 1
#property indicator_width2  1
#property indicator_width3  1
//--- отображение меток уровней Боллинджера
#property indicator_label2  "+NSigma"
#property indicator_label3  "-NSigma"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1;
CStdDeviation STD;
//+-----------------------------------+
//| объявление перечислений           |
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
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input int XLength=100;                   // Глубина  сглаживания                    
input int XPhase=15;                     // Параметр усреднения
//--- XPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input int BandsPeriod=100;               // Период усреднения BB
input double BandsDeviation = 2.0;       // Девиация
input Applied_price_ IPC=PRICE_CLOSE;    // Ценовая константа
input int Shift=0;                       // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будут использован в качестве индикаторного буфера
double ExtLineBuffer[];
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer1[],ExtLineBuffer2[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_=XMA1.GetStartBars(XMA_Method,XLength,XPhase)+1;
   min_rates_total=min_rates_+BandsPeriod;
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMALengthCheck("BandsPeriod", BandsPeriod);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//--- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"BBflat_sw(",XLength,", ",BandsPeriod,", ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//--- объявление переменных с плавающей точкой  
   double price,xma,stdev;
//--- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,false);
      stdev=STD.StdDevSeries(min_rates_,prev_calculated,rates_total,BandsPeriod,BandsDeviation,price,xma,bar,false)/_Point;     
      ExtLineBuffer[bar]=(price-xma)/_Point;     
      ExtLineBuffer1[bar]=+stdev;
      ExtLineBuffer2[bar]=-stdev;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

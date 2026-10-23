//+---------------------------------------------------------------------+
//|                                        ColorXDeMarker_Histogram.mq5 | 
//|                                  Copyright © 2017, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrAqua,clrForestGreen,clrGray,clrOrange,clrYellow
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "ColorXDeMarker_Histogram"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      //Тип константы
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
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_COLOR_MODE //Тип константы
  {
   ENUM_LEVELS = 1,     //по уровням перекупленности/перепроданности
   ENUM_DIRECT           //по направлению движения гистограммы
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint XPeriod=12;                    //период DeMarker                   
input Smooth_Method XMA_Method=MODE_JJMA; //метод усреднения
input uint XLength=5;                     //глубина сглаживания                    
input int XPhase=15;                      //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_TYPICAL_;  //ценовая константа
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
input ENUM_COLOR_MODE Mode=ENUM_LEVELS;  //метод цветовой индикации
input int HighLevel=+20;
input int MiddleLevel=0;
input int LowLevel=-20;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtIndBuffer[],ColorExtIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(XPeriod)+1;
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtIndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname="ColorXDeMarker_Histogram("+string(XPeriod)+")";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBrown);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double ExtDeMarker,ExtDeMarker_prev,ExtDeMax,ExtDeMin,ExtAvgDeMax,ExtAvgDeMin,dNum;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1; // стартовый номер для расчёта всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(high[bar]>high[bar-1]) ExtDeMax=high[bar]-high[bar-1];
      else ExtDeMax=NULL;
      //----
      if(low[bar-1]>low[bar]) ExtDeMin=low[bar-1]-low[bar];
      else ExtDeMin=NULL;
      //----
      ExtAvgDeMax=XMA1.XMASeries(1,prev_calculated,rates_total,MODE_SMA_,0,XPeriod,ExtDeMax,bar,false);
      ExtAvgDeMin=XMA2.XMASeries(1,prev_calculated,rates_total,MODE_SMA_,0,XPeriod,ExtDeMin,bar,false);
      //----      
      dNum=ExtAvgDeMax+ExtAvgDeMin;
      if(dNum) ExtDeMarker=ExtAvgDeMax/dNum;
      else ExtDeMarker=NULL;      
      ExtIndBuffer[bar]=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,ExtDeMarker,bar,false);
      ExtIndBuffer[bar]*=100;
      ExtIndBuffer[bar]-=50;
     }
//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      ExtDeMarker=ExtIndBuffer[bar];
      
      if(Mode==ENUM_DIRECT)
        {
         ExtDeMarker_prev=ExtIndBuffer[bar-1];
         if(ExtDeMarker>MiddleLevel)
           {
            if(ExtDeMarker_prev<ExtDeMarker) clr=0;
            if(ExtDeMarker_prev>ExtDeMarker) clr=3;
           }
         else if(ExtDeMarker<MiddleLevel)
           {
            if(ExtDeMarker_prev<ExtDeMarker) clr=1;
            if(ExtDeMarker_prev>ExtDeMarker) clr=4;
           }
        }
      else 
       {
         if(ExtDeMarker>HighLevel) clr=0;
         else if(ExtDeMarker>MiddleLevel) clr=1;
         else if(ExtDeMarker<LowLevel) clr=4;
         else if(ExtDeMarker<MiddleLevel) clr=3;
       }
      ColorExtIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

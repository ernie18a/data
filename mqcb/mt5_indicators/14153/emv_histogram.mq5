//+---------------------------------------------------------------------+
//|                                                   EMV_Histogram.mq5 |
//|                                  Copyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2015, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
#property description "Ease of Movement Value"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrBlue,clrPurple
//---- отображение метки индикатора
#property indicator_label1  "EMV Signal"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов пятицветной гистограммы использованы
#property indicator_color2 clrDeepPink,clrOrange,clrGray,clrYellowGreen,clrTeal
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки индикатора
#property indicator_label2  "Ease of Movement Value"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+-----------------------------------+
//| Объявление перечислений           |
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method1=MODE_SMA; // Метод усреднения основной линии
input int XLength1=14; // Глубина сглаживания основной линии
input int XPhase1=15;  // Параметр сглаживания основной линии
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method XMA_Method2=MODE_JJMA; // Метод усреднения сигнальной линии
input int XLength2=5;  // Глубина сглаживания сигнальной линии                   
input int XPhase2=100; // Параметр сглаживания сигнальной линии
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_QUARTER_; // Ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // Объем
input int Shift=0; // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double UpBuffer[],DnBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=GetStartBars(XMA_Method1,XLength1,XPhase1)+1;
   min_rates_total=min_rates_1+GetStartBars(XMA_Method2,XLength2,XPhase2);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Ease of Movement Value");
//--- определение точности отображения значений индикатора
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
   if(rates_total<min_rates_total) return(0);
//---- объявления локальных переменных 
   int first,bar;
   double price0,price1,EMV,XEMV;
   long Volume;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
     }
//----
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price0=PriceSeries(PRICE_MEDIAN,bar,  open,low,high,close);
      price1=PriceSeries(PRICE_MEDIAN,bar-1,open,low,high,close);
      //----
      if(VolumeType==VOLUME_TICK) Volume=long(tick_volume[bar]);
      else                        Volume=long(volume[bar]);
      //----
      if(Volume!=0) EMV=(price0-price1)*price0/(2*Volume);
      else          EMV=0;
      //----
      XEMV=XMA1.XMASeries(1,prev_calculated,rates_total,XMA_Method1,XPhase1,XLength1,EMV,bar,false);
      IndBuffer[bar]=UpBuffer[bar]=XEMV;
      DnBuffer[bar]=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method2,XPhase2,XLength2,XEMV,bar,false);
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) first=min_rates_total;
//---- основной цикл раскраски индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      //----
      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }
      //----
      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }
      //----
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------+
//|                                                           XWAMI.mq5 | 
//|                                     2018, MetaQuotes Software Corp. | 
//|                                                   https://mql5.com/ | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/"
#property description "Momentum Indicator by Anthony W.Warren"
#property description "Этот индикатор Моментума был описан в статье «Оптимизация импульса» Энтони У. Уоррена в журнале S & C в апреле 1994 г."
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrBlueViolet,clrDarkOrange
//---- отображение метки линии индикатора
#property indicator_label1  "XWAMI"

//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
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
input uint iPeriod=1; //период моментума
input Smooth_Method XMethod1=MODE_T3; //метод усреднения 1 
input uint XLength1=4; //глубина усреднения 1                    
input int XPhase1=15; //параметр усреднения 1,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input Smooth_Method XMethod2=MODE_JJMA; //метод усреднения 2 
input uint XLength2=13; //глубина усреднения 2                   
input int XPhase2=15; //параметр усреднения 2,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input Smooth_Method XMethod3=MODE_JJMA; //метод усреднения 3
input uint XLength3=13; //глубина усреднения 3                   
input int XPhase3=15; //параметр усреднения 3,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input Smooth_Method XMethod4=MODE_JJMA; //метод усреднения сигнальной линии
input uint XLength4=4; //глубина усреднения сигнальной линии                   
input int XPhase4=15; //параметр усреднения сигнальной линии,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpIndBuffer[],DnIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_2,min_rates_3,min_rates_4;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(iPeriod);
   min_rates_2=min_rates_1+GetStartBars(XMethod1,XLength1,XPhase1);
   min_rates_3=min_rates_2+GetStartBars(XMethod2,XLength2,XPhase2);
   min_rates_4=min_rates_3+GetStartBars(XMethod3,XLength3,XPhase3);
   min_rates_total=min_rates_4+GetStartBars(XMethod4,XLength4,XPhase4);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- запрет на отображения значения индикатора в левом углу
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XWAMI(",XLength1,", ",XLength2,", ",XLength3,", ",XLength4,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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

//---- Объявление целых переменных и получение уже посчитанных баров
   int first;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double price=PriceSeries(IPC,bar,open,low,high,close);
      double price_prev=PriceSeries(IPC,bar-iPeriod,open,low,high,close);
      double diff=price-price_prev;
      //---- Четыре вызова функции XMASeries. 
      double xdiff=XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,XMethod1,XPhase1,XLength1,diff,bar,false);
      double xxdiff=XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,XMethod2,XPhase2,XLength2,xdiff,bar,false);
      double xxxdiff=XMA3.XMASeries(min_rates_3,prev_calculated,rates_total,XMethod3,XPhase3,XLength3,xxdiff,bar,false);
      double xxxxdiff=XMA4.XMASeries(min_rates_4,prev_calculated,rates_total,XMethod4,XPhase4,XLength4,xxxdiff,bar,false);
      UpIndBuffer[bar]=xxxdiff/_Point;
      DnIndBuffer[bar]=xxxxdiff/_Point;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

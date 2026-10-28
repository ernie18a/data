//+---------------------------------------------------------------------+
//|                                                          NRatio.mq5 | 
//|                                              Copyright © 2006, Rosh | 
//|                                     http://konkop.narod.ru/nrma.htm | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора файл SmoothAlgorithms.mqh следует положить   |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Rosh"
#property link "http://konkop.narod.ru/nrma.htm"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов
#property indicator_buffers 1 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован MediumOrchid цвет
#property indicator_color1 clrMediumOrchid
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "NRatio"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //close
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
//| объявление перечислений                      |
//+----------------------------------------------+
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
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input int XLength=3;                     // Глубина сглаживания                    
input int XPhase=15;                     // Параметр сглаживания
//---XPhase: для JJMA изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
//---XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE;    // Ценовая константа
input double Kf=1;
input double Fast=2;
input double Sharp=2;
input int    Shift=0;                    // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//--- объявление переменной значения вертикального сдвига средней
double dF;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=XMA1.GetStartBars(XMA_Method,XLength,XPhase)+1;
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//--- инициализация констант
   dF=2.0/(1.0+Fast);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"NRatio(",XLength,", ",Smooth1,")");
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
   double price,NRTR0,LPrice,HPrice,Oscil,xOscil;
   static double NRTR1;
//--- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar,Trend0;
   static int Trend1;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      bar=first-1;
      price=PriceSeries(IPC,bar,open,low,high,close);
      if(close[first]>open[first])
        {
         Trend1=+1;
         NRTR1=NormalizeDouble(price*(1.0-Kf*0.01),_Digits);
        }
      else
        {
         Trend1=-1;
         NRTR1=NormalizeDouble(price*(1.0+Kf*0.01),_Digits);
        }
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- вызов функции PriceSeries для получения входной цены price
      price=PriceSeries(IPC,bar,open,low,high,close);
      NRTR0=NRTR1;
      Trend0=Trend1;
      //---
      if(Trend1>=0)
        {
         if(price<NRTR1)
           {
            Trend0=-1;
            NRTR0=NormalizeDouble(price*(1.0+Kf*0.01),_Digits);
           }
         else
           {
            Trend0=+1;
            LPrice=NormalizeDouble(price*(1.0-Kf*0.01),_Digits);
            if(LPrice>NRTR1) NRTR0=LPrice;
            else NRTR0=NRTR1;
           }
        }
      //---
      if(Trend1<=0)
        {
         if(price>NRTR1)
           {
            Trend0=+1;
            NRTR0=NormalizeDouble(price*(1.0-Kf*0.01),_Digits);
           }
         else
           {
            Trend0=-1;
            HPrice=NormalizeDouble(price*(1.0+Kf*0.01),_Digits);
            if(HPrice<NRTR1) NRTR0=HPrice;
            else NRTR0=NRTR1;
           }
        }
      //---
      Oscil=(100.0*MathAbs(price-NRTR0)/price)/Kf;
      xOscil=XMA1.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,Oscil,bar,false);
      IndBuffer[bar]=100*MathPow(xOscil,Sharp);
      if(bar<rates_total-1)
        {
         Trend1=Trend0;
         NRTR1=NRTR0;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+

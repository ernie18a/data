//+---------------------------------------------------------------------+
//|                                             ColorXCCI_Histogram.mq5 | 
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
//---- в качестве цветов линии использованы
#property indicator_color1  clrMediumSpringGreen,clrDarkGreen,clrGray,clrMaroon,clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "ColorXCCI_Histogram"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
   ENUM_LEVELES = 1,     //по уровням перекупленности/перепроданности
   ENUM_DIRECT           //по направлению движения гистограммы
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint XPeriod=12;                    //период CCI                   
input Smooth_Method XMA_Method=MODE_JJMA; //метод усреднения
input uint XLength=5;                     //глубина сглаживания                    
input int XPhase=15;                      //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_TYPICAL_;  //ценовая константа
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
input ENUM_COLOR_MODE Mode=ENUM_LEVELES;  //метод цветовой индикации
input int HighLevel=+100;
input int MiddleLevel=0;
input int LowLevel=-100;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtIndBuffer[],ColorExtIndBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//---- объявление глобальных переменных
int Count[];
double ExtSP[],dMul;
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(2*XPeriod)+1;
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase);
   dMul=0.015/XPeriod;
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,XPeriod);
   ArrayResize(ExtSP,XPeriod);
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
   string shortname="ColorXCCI_Histogram("+string(XPeriod)+")";
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
   double price,dTmp,ExtCCI,ExtCCI_prev,ExtD,ExtM;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,NULL);
      ArrayInitialize(ExtSP,NULL);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      ExtSP[Count[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,MODE_SMA_,0,XPeriod,price,bar,false);
      //----
      dTmp=NULL;
      for(int kkk=0; kkk<int(XPeriod); kkk++) dTmp+=MathAbs(PriceSeries(IPC,MathMax(0,bar-kkk),open,low,high,close)-ExtSP[Count[kkk]]);
      ExtD=dTmp*dMul;
      ExtM=price-ExtSP[Count[0]];
      if(ExtD) ExtCCI=ExtM/ExtD;
      else ExtCCI=NULL;    
      ExtIndBuffer[bar]=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,ExtCCI,bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,XPeriod);
     }
//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=2;
      ExtCCI=ExtIndBuffer[bar];
      
      if(Mode==ENUM_DIRECT)
        {
         ExtCCI_prev=ExtIndBuffer[bar-1];
         if(ExtCCI>MiddleLevel)
           {
            if(ExtCCI_prev<ExtCCI) clr=0;
            if(ExtCCI_prev>ExtCCI) clr=3;
           }
         else if(ExtCCI<MiddleLevel)
           {
            if(ExtCCI_prev<ExtCCI) clr=1;
            if(ExtCCI_prev>ExtCCI) clr=4;
           }
        }
      else 
       {
         if(ExtCCI>HighLevel) clr=0;
         else if(ExtCCI>MiddleLevel) clr=1;
         else if(ExtCCI<LowLevel) clr=4;
         else if(ExtCCI<MiddleLevel) clr=3;
       }
      ColorExtIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

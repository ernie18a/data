//+------------------------------------------------------------------+
//|                                          MA_Rounding_Channel.mq5 | 
//|                   Copyright © 2011, BACKSPACE + Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, BACKSPACE + Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkViolet цвет
#property indicator_color1 clrDarkViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "MA Rounding"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета верхней линии индикатора использован голубой цвет
#property indicator_color2  clrDodgerBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение бычьей метки индикатора
#property indicator_label2  "Up MA Rounding"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета нижней линии индикатора использован красный цвет
#property indicator_color3  clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 1
#property indicator_width3 1 
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Down MA Rounding"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simplе Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//| Объявление перечислений                      |
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
input int XLength=12; // Глубина сглаживания
input int XPhase=15;  // Параметр сглаживания
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input uint MaRound=50; // Коэффициент округления
input int    ATRPeriod=12; // Период ATR для ширины канала
input double ATR_Factor=1.0; // Коэффициент девиации канала
input bool  ChanContinuity=false; // Непрерывность канала
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
double IndBuffer[];
//---- объявление переменной значения вертикального сдвига
double MaRo;
//---- объявление переменной для хранения хендла индикатора
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| XMA indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=XMA1.GetStartBars(XMA_Method,XLength,XPhase)+2;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
//---- инициализация сдвига по вертикали
   MaRo=_Point*MaRound;
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,167);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,167);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"MA Rounding(",XLength,", ",MaRound,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XMA iteration function                                           | 
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double price_,MovAve0,MovAle0,res0,res1,Range[],range0;
//---- объявление целочисленных переменных
   int to_copy,first,bar;
//---- объявление статических переменных  
   static double MovAle1,MovAve1,range1;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=2; // стартовый номер для расчета всех баров
      MovAve1=PriceSeries(IPC,first,open,low,high,close);
      MovAle1=0;
      range1=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- восстанавливаем значения переменных
   range0=range1;
//----
   to_copy=rates_total-first;
//---- копируем вновь появившиеся данные в массив Range[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //----
      MovAve0=XMA1.XMASeries(2,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price_,bar,false);
      //----
      res1=IndBuffer[bar-1];
      //----
      if(MovAve0>MovAve1+MaRo
         || MovAve0<MovAve1-MaRo
         || MovAve0>res1+MaRo
         || MovAve0<res1-MaRo
         || (MovAve0>res1 && MovAle1==+1)
         || (MovAve0<res1 && MovAle1==-1))
         IndBuffer[bar]=MovAve0;
      else IndBuffer[bar]=res1;
      //----
      MovAle0=0;
      res0=IndBuffer[bar];
      if(res0<res1) MovAle0 =-1;
      if(res0>res1) MovAle0 =+1;
      if(res0==res1) MovAle0=MovAle1;
      //---- обнулим содержимое индикаторных буферов
      UpBuffer[bar]=0.0;
      DnBuffer[bar]=0.0;
      //---- построим канал
      if(res0==res1)
        {
         if(res1!=IndBuffer[bar-2]) range0=Range[rates_total-bar-1]*ATR_Factor;
         else range0=range1;

         UpBuffer[bar]=res0+range0;
         DnBuffer[bar]=res0-range0;
        }
      else if(ChanContinuity)
        {
         UpBuffer[bar]=UpBuffer[bar-1];
         DnBuffer[bar]=DnBuffer[bar-1];
        }
      //--- пересчет позиций в кольцевых буферах  
      if(bar<rates_total-1)
        {
         MovAle1=MovAle0;
         MovAve1=MovAve0;
         range1=range0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

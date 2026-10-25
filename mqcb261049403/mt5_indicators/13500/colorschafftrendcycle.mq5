//+---------------------------------------------------------------------+
//|                                           ColorSchaffTrendCycle.mq5 |
//|                                     Copyright © 2011, EarnForex.com |
//|                                           http://www.earnforex.com/ |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex.com"
#property link      "http://www.earnforex.com"
#property description "Schaff Trend Cycle - Cyclical Stoch over Stoch over XMACD."
#property description "The code adapted Nikolay Kositsin."
//---- номер версии индикатора
#property version   "2.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrMagenta,clrMediumOrchid,clrDarkOrange,clrPeru,clrBlue,clrDodgerBlue,clrMediumSeaGreen,clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "Schaff Trend Cycle"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
//---- фиксирование верхней и нижней границ окна индикатора
#property indicator_minimum -110
#property indicator_maximum +110
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
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
//---
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
input Smooth_Method XMA_Method=MODE_EMA; // Метод усреднения гистограммы
input uint Fast_XMA = 23; // Период быстрой скользящей средней
input uint Slow_XMA = 50; // Период медленной скользящей средней
input int XPhase=100;  // Параметр усреднения скользящих средних
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ AppliedPrice=PRICE_CLOSE_; // Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input uint Cycle=10; // Период стохастического осциллятора
input int HighLevel=+60;
input int MiddleLevel=0;
input int LowLevel=-60;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double STC_Buffer[];
double ColorSTC_Buffer[];
//----
int Count[];
bool st1_pass,st2_pass;
double XMACD[],ST[],Factor;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+
//|  пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Rates_total,
                          int Bar)
  {
//----
   if(Bar>=Rates_total-1) return;
//----
   int numb;
   static int count=1;
   count--;
//----
   if(count<0) count=int(Cycle)-1;
//----
   for(int iii=0; iii<int(Cycle); iii++)
     {
      numb=iii+count;
      if(numb>int(Cycle)-1) numb-=int(Cycle);
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=int(MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),
                   XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase)));
   min_rates_2=min_rates_1+int(Cycle);
   min_rates_total=min_rates_2+int(Cycle)+1;
//---- распределение памяти под массивы переменных
   if(ArrayResize(ST,Cycle)<int(Cycle)) Print("Не удалось распределить память под массив ST");
   if(ArrayResize(XMACD,Cycle)<int(Cycle)) Print("Не удалось распределить память под массив XMACD");
   if(ArrayResize(Count,Cycle)<int(Cycle)) Print("Не удалось распределить память под массив Count");
//---- инициализация констант  
   Factor=0.5;
   st1_pass = false;
   st2_pass = false;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,STC_Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в цветовой буфер
   SetIndexBuffer(1,ColorSTC_Buffer,INDICATOR_COLOR_INDEX);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"Schaff Trend Cycle( ",
                     Smooth,", ",Fast_XMA,", ",Slow_XMA,", ",Cycle," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMediumSeaGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Schaff Trend Cycle                                               |
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
//---- 
   if(rates_total<=min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price_,fastxma,slowxma,LLV,HHV;
//---- объявление целочисленных переменных
   int first,bar,Bar0,Bar1;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Bar0=Count[0];
      Bar1=Count[1];
      price_=PriceSeries(AppliedPrice,bar,open,low,high,close);;
      //----
      fastxma = XMA1.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Fast_XMA, price_, bar, false);
      slowxma = XMA2.XMASeries(0, prev_calculated, rates_total, XMA_Method, XPhase, Slow_XMA, price_, bar, false);
      //----
      XMACD[Bar0]=fastxma-slowxma;
      //----
      if(bar<=min_rates_2)
        {
         Recount_ArrayZeroPos(Count,rates_total,bar);
         continue;
        }
      //----
      LLV=XMACD[ArrayMinimum(XMACD)];
      HHV=XMACD[ArrayMaximum(XMACD)];
      //---- расчет первого стохастика
      if(HHV-LLV!=0) ST[Bar0]=((XMACD[Bar0]-LLV)/(HHV-LLV))*100;
      else           ST[Bar0]=ST[Bar1];
      //----
      if(st1_pass) ST[Bar0]=Factor *(ST[Bar0]-ST[Bar1])+ST[Bar1];
      st1_pass=true;
      //----
      if(bar<=min_rates_2)
        {
         Recount_ArrayZeroPos(Count,rates_total,bar);
         continue;
        }
      //----
      LLV=ST[ArrayMinimum(ST)];
      HHV=ST[ArrayMaximum(ST)];
      //---- расчет второго стохастика
      if(HHV-LLV!=0) STC_Buffer[bar]=((ST[Bar0]-LLV)/(HHV-LLV))*200-100;
      else           STC_Buffer[bar]=STC_Buffer[bar-1];
      //---- сглаживание второго стохастика
      if(st2_pass) STC_Buffer[bar]=Factor *(STC_Buffer[bar]-STC_Buffer[bar-1])+STC_Buffer[bar-1];
      st2_pass=true;
      //---- пересчет позиции элементов в кольцевых буферах на смене бара
      Recount_ArrayZeroPos(Count,rates_total,bar);
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) first++;
//---- основной цикл раскраски индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      double Sts=STC_Buffer[bar];
      double dSts=Sts-STC_Buffer[bar-1];
      int clr=4;
      //----
      if(Sts>0)
        {
         if(Sts>HighLevel)
           {
            if(dSts>=0) clr=7;
            else clr=6;
           }
         else
           {
            if(dSts>=0) clr=5;
            else clr=4;
           }
        }
      //----  
      if(Sts<0)
        {
         if(Sts<LowLevel)
           {
            if(dSts<0) clr=0;
            else clr=1;
           }
         else
           {
            if(dSts<0) clr=2;
            else clr=3;
           }
        }
      //----  
      ColorSTC_Buffer[bar]=clr;
     }
//----
   return(rates_total);
  }
//+----------------------------------------------------

 //+--------------------------------------------------------------------+
//|                                          LinearRegSlope_V2_Sign.mq5 | 
//|                     Linear regression value  - time series forecast |
//|                          Linear regression value - tsf with Trigger |
//|                                                              mladen |
//|                                                                     |
//|                Modified from Linear regression value - tsf by Toshi |
//|                                     http://toshi52583.blogspot.com/ |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, mladen"
#property link      "mladenfx@gmail.com"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color1  clrCoral
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "LinearRegSlope_V1 Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычего индикатора использован синий цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "LinearRegSlope_V1 Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  объявление перечислений                     |
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
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input Smooth_Method SlMethod=MODE_SMA; //метод усреднения
input int SlLength=12; //глубина сглаживания                    
input int SlPhase=15; //параметр сглаживания,
                      //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE;//ценовая константа
/* , по которой производится расчёт индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int TriggerShift=1; // cдвиг бара для тригера
//+----------------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- Объявление глобальных переменных
int TriggerShift_,TrigShift,TrigShift_;
double SumX,Divisor;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
int Count1[],Count2[];
double Smooth[],RegSlope[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos1
(
 int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
 int Size // количество элементов в кольцевом буфере
 )
// Recount_ArrayZeroPos(count, SlLength)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
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
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos2
(
 int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
 int Size // количество элементов в кольцевом буфере
 )
// Recount_ArrayZeroPos(count, SlLength)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
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
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int ATR_Period=15;
   min_rates_total=GetStartBars(SlMethod,1,SlPhase)+SlLength+TriggerShift;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total))+1;
   
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("SlLength", SlLength);
   XMA1.XMAPhaseCheck("SlPhase", SlPhase, SlMethod);
   if(TriggerShift>SlLength-2)
     {
      Print("Значение входного параметра TriggerShift не может быть больше чем SlLength-2");
      TrigShift=1;
      TrigShift_=SlLength-2;
     }
   else
     {
      TrigShift=SlLength-1-TriggerShift;
      TrigShift_=TriggerShift;
     }

//---- Инициализация переменных   
   SumX=SlLength *(SlLength-1)*0.5;
   double SumXSqr=(SlLength-1.0)*SlLength *(2.0*SlLength-1.0)/6.0;
   Divisor=SumX*SumX-SlLength*SumXSqr;
   TriggerShift_=int(min_rates_total);

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count1,SlLength);
   ArrayResize(Smooth,SlLength);
   ArrayResize(Count2,TriggerShift+1);
   ArrayResize(RegSlope,TriggerShift+1);

//---- Инициализация массивов переменных
   ArrayInitialize(Count1,0);
   ArrayInitialize(Count2,0);
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(RegSlope,0.0);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(SlMethod);
   StringConcatenate(shortname,"Linear Reg Slope(",SlLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
 IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
   
//---- Объявление переменных с плавающей точкой  
   double price_,SumY,SumXY,Intercept,Slope,ATR[1],Trigger,trend;
   static double trend_;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,iii;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      trend_=0.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      Smooth[Count1[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,SlMethod,SlPhase,SlLength,price_,bar,false);

      SumY=0;
      SumXY=0;

      if(bar>=SlLength)
         for(iii=0; iii<SlLength; iii++)
           {
            SumY+=Smooth[Count1[iii]];
            SumXY+=iii*Smooth[Count1[iii]];
           }

      if(Divisor!=0) Slope=(SlLength*SumXY-SumX*SumY)/Divisor;
      else           Slope=EMPTY_VALUE;

      if(bar>=SlLength)
        {
         Intercept=(SumY-Slope*SumX)/SlLength;
         RegSlope[Count2[0]]=Intercept+Slope*TrigShift;
        }

      if(bar>TriggerShift_) Trigger=2.0*RegSlope[Count2[0]]-RegSlope[Count2[TriggerShift]];
      else                  Trigger=EMPTY_VALUE;
      
      //----   
      trend=RegSlope[Count2[0]]-Trigger;
      //----
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;
      //----
      if(trend_<=0 && trend>0)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0)  return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //----
      if(trend_>=0 && trend<0)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0)  return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //----
      if(bar<rates_total-1)
        {
         //---- пересчёт позиций элементов в кольцевом буфере Smooth[]
         Recount_ArrayZeroPos1(Count1,SlLength);
         //---- пересчёт позиций элементов в кольцевом буфере RegSlope[]
         Recount_ArrayZeroPos2(Count2,TriggerShift+1);
         //---- запоминаем значения переменных
         if(trend) trend_=trend;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

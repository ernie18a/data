//+---------------------------------------------------------------------+
//|                                          ColorLinearRegSlope_V2.mq5 | 
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
#property version   "1.11"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1 clrCoral,clrDodgerBlue
//---- отображение метки индикатора
#property indicator_label1  "Linear Reg Slope"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
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
//----
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
input Smooth_Method SlMethod=MODE_SMA; // Метод усреднения
input int SlLength=12; // Глубина сглаживания                    
input int SlPhase=15;  // Параметр сглаживания
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
// для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
/* по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0;        // Сдвиг индикатора по горизонтали в барах
input int TriggerShift=1; // Сдвиг бара для триггера
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double RegSlopeBuffer[],TriggerBuffer[];
//---- объявление глобальных переменных
int TriggerShift_,TrigShift,TrigShift_;
double SumX,Divisor;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве кольцевых буферов
int Count[];
double Smooth[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)    // количество элементов в кольцевом буфере
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+   
//| LinearRegSlope_V2 indicator initialization function              | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=XMA1.GetStartBars(SlMethod,1,SlPhase)+SlLength+TriggerShift;
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
//---- инициализация переменных   
   SumX=SlLength *(SlLength-1)*0.5;
   double SumXSqr=(SlLength-1.0)*SlLength *(2.0*SlLength-1.0)/6.0;
   Divisor=SumX*SumX-SlLength*SumXSqr;
   TriggerShift_=int(min_rates_total);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,SlLength);
   ArrayResize(Smooth,SlLength);
//---- инициализация массивов переменных
   ArrayInitialize(Count,0);
   ArrayInitialize(Smooth,0.0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,RegSlopeBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(SlMethod);
   StringConcatenate(shortname,"Linear Reg Slope(",SlLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| LinearRegSlope_V2 iteration function                             | 
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
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double price_,SumY,SumXY,Intercept,Slope;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar,iii;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      Smooth[Count[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,SlMethod,SlPhase,SlLength,price_,bar,false);
      //----
      SumY=0.0;
      SumXY=0.0;
      //----
      if(bar>=SlLength)
         for(iii=0; iii<SlLength; iii++)
           {
            SumY+=Smooth[Count[iii]];
            SumXY+=iii*Smooth[Count[iii]];
           }
      //----
      if(Divisor) Slope=(SlLength*SumXY-SumX*SumY)/Divisor;
      else        Slope=EMPTY_VALUE;
      //----
      if(bar>=SlLength)
        {
         Intercept=(SumY-Slope*SumX)/SlLength;
         RegSlopeBuffer[bar]=Intercept+Slope*TrigShift;
        }
      //----
      if(bar>TriggerShift_) TriggerBuffer[bar]=2.0*RegSlopeBuffer[bar]-RegSlopeBuffer[bar-TrigShift_];
      else                  TriggerBuffer[bar]=EMPTY_VALUE;
      //---- пересчет позиций элементов в кольцевом буфере Smooth[]
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,SlLength);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

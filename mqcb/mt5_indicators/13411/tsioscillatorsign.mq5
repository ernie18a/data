//+------------------------------------------------------------------+
//|                                           TSI-OscillatorSign.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//|                                                                  |
//|                                   Modified from TSI-Osc by Toshi |
//|                                  http://toshi52583.blogspot.com/ |
//+------------------------------------------------------------------+
//| Для работы  индикатора файл SmoothAlgorithms.mqh                 |
//| следует положить в папку: каталог_данных_терминала\\MQL5\Include |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 1 
#property indicator_width1  1
//--- отображение медвежьей метки индикатора
#property indicator_label1  "TSI-Oscillator Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение бычьей метки индикатора
#property indicator_label2 "TSI-Oscillator Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание класса CMTM                         |
//+----------------------------------------------+
#include<SmoothAlgorithms.mqh>
//+----------------------------------------------+
//---- объявление переменных класса CMTM из файла SmoothAlgorithms.mqh
CXMA MTM1,MTM2,ABSMTM1,ABSMTM2;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_      // тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price
  };
//---
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
   {
    MODE_SMA_,  // SMA
    MODE_EMA_,  // EMA
    MODE_SMMA_, // SMMA
    MODE_LWMA_, // LWMA
    MODE_JJMA,  // JJMA
    MODE_JurX,  // JurX
    MODE_ParMA, // ParMA
    MODE_T3,    // T3
    MODE_VIDYA, // VIDYA
    MODE_AMA,   // AMA
   }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method First_Method=MODE_SMA;  // Метод усреднения 1
input int First_Length=12;                  // Глубина сглаживания 1
input int First_Phase=15;                   // Параметр сглаживания 1
input Smooth_Method Second_Method=MODE_SMA; // Метод усреднения 2
input int Second_Length=12;                 // Глубина сглаживания 2
input int Second_Phase=15;                  // Параметр сглаживания 2
input Applied_price_ IPC=PRICE_CLOSE;       // Ценовая константа
input int Shift=0;                          // Сдвиг индикатора по горизонтали в барах
input uint TriggerShift=1;                  // Сдвиг бара для триггера 
//+----------------------------------------------+
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_total1,min_rates_total2;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- объявление глобальных переменных
int Count[];
double TSI[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
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
//| TSI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация глобальных переменных 
   int ATR_Period=15;
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,TriggerShift+1);
   ArrayResize(TSI,TriggerShift+1);
   ArrayInitialize(Count,0);
   ArrayInitialize(TSI,0.0);
//---- инициализация переменных начала отсчета данных
   min_rates_total1=MTM1.GetStartBars(First_Method,First_Length,First_Phase)+1;
   min_rates_total2=min_rates_total1+MTM1.GetStartBars(First_Method,First_Length,First_Phase);
   min_rates_total=int(min_rates_total1+MTM1.GetStartBars(Second_Method,Second_Length,Second_Phase)+TriggerShift);
   min_rates_total=int(MathMax(ATR_Period,min_rates_total))+1;
//---- установка алертов на недопустимые значения внешних переменных
   MTM1.XMALengthCheck("First_Length",First_Length);
   MTM1.XMAPhaseCheck("First_Phase",First_Phase, First_Method);
   MTM1.XMALengthCheck("Second_Length",Second_Length);
   MTM1.XMAPhaseCheck("Second_Phase",Second_Phase,Second_Method);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=MTM1.GetString_MA_Method(First_Method);
   string Smooth2=MTM1.GetString_MA_Method(Second_Method);
   StringConcatenate(shortname,"TSI-OscillatorSign(",Smooth1,", ",First_Length,", ",Smooth2,", ",Second_Length,")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| TSI iteration function                                           | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double dprice,absdprice,mtm1,absmtm1,mtm2,absmtm2,Trigger,ATR[1];
//---- объявление целочисленных переменных и получение уже подсчитанных баров
   int first,bar;
   static double Trigger1;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dprice=close[bar]-close[bar-1];
      absdprice=MathAbs(dprice);
      //----
      mtm1=MTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,dprice,bar,false);
      absmtm1=ABSMTM1.XMASeries(1,prev_calculated,rates_total,First_Method,First_Phase,First_Length,absdprice,bar,false);
      //----
      mtm2=MTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,mtm1,bar,false);
      absmtm2=ABSMTM2.XMASeries(min_rates_total1,prev_calculated,rates_total,Second_Method,Second_Phase,Second_Length,absmtm1,bar,false);
      //----
      if(bar>min_rates_total2) TSI[Count[0]]=100.0*mtm2/absmtm2;
      else TSI[Count[0]]=0;
      //----
      if(bar>min_rates_total) Trigger=TSI[Count[TriggerShift]];
      else                    Trigger=0;
      //---
      if(TSI[Count[1]]<=Trigger1 && TSI[Count[0]]>Trigger)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(TSI[Count[1]]>=Trigger1 && TSI[Count[0]]<Trigger)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //----
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos(Count,TriggerShift+1);
         Trigger1=Trigger;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

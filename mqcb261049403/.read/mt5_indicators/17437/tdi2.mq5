//+---------------------------------------------------------------------+
//|                                                           TDI-2.mq5 |
//|                                              Copyright © Rosh, 2009 |
//|                                         https://www.metaquotes.net/ |
//|                                                     Written by Rosh |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © Rosh, 2009"
#property link "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего два графических построения
#property indicator_plots   2
//+---------------------------------------+
//|  Параметры отрисовки индикатора TDI   |
//+---------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1 clrRed
//---- линия индикатора - штрих-пунктир
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Trend Direction Index"

//+---------------------------------------+
//|  Параметры отрисовки сигнальной линии |
//+---------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color2 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Direction"

//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
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
input Smooth_Method TdiMethod=MODE_SMA_;          //метод усреднения
input uint TdiPeriod=20;                          //глубина сглаживания                    
input int TdiPhase=15;                            //параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;            //ценовая константа
input int Shift=0;                                //сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double TDI[],Direct[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+   
//| TDI indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(TdiPeriod);
   min_rates_2=min_rates_1+XMA1.GetStartBars(TdiMethod, TdiPeriod, TdiPhase);
   min_rates_total=min_rates_1+min_rates_2+2*XMA1.GetStartBars(TdiMethod, TdiPeriod, TdiPhase);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("TdiPeriod", TdiPeriod);
   XMA1.XMAPhaseCheck("TdiPhase", TdiPhase, TdiMethod);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,TDI,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Direct,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(TdiMethod);
   StringConcatenate(shortname,"Trend Direction Index(",Smooth,", ",TdiPeriod,", ",TdiPhase,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| TDI iteration function                                           | 
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
   double Mom,MomAbs,MomSum,MomSumAbs,MomAbsSum,MomAbsSum2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=int(TdiPeriod); // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      Mom=PriceSeries(IPC,bar,open,low,high,close)-PriceSeries(IPC,bar-TdiPeriod,open,low,high,close);
      MomAbs=MathAbs(Mom);
      MomSum=TdiPeriod*XMA1.XMASeries(min_rates_1,prev_calculated,rates_total,TdiMethod,TdiPhase,TdiPeriod,Mom,bar,false);
      MomSumAbs=MathAbs(MomSum);
      MomAbsSum=TdiPeriod*XMA2.XMASeries(min_rates_2,prev_calculated,rates_total,TdiMethod,TdiPhase,TdiPeriod,MomAbs,bar,false);
      MomAbsSum2=2*TdiPeriod*XMA3.XMASeries(min_rates_2,prev_calculated,rates_total,TdiMethod,TdiPhase,2*TdiPeriod,MomAbs,bar,false);
      TDI[bar]=MomSumAbs-(MomAbsSum2-MomAbs);
      Direct[bar]=MomSum;     
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

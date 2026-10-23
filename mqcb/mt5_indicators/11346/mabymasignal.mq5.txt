//+---------------------------------------------------------------------+
//|                                                    MaByMaSignal.mq5 | 
//|                                            Copyright © 2010, excelf | 
//|                                     excelf@gmail.com, skype: excelf | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, excelf"
#property link "excelf@gmail.com, skype: excelf"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован Magenta цвет
#property indicator_color1  clrMagenta
//--- толщина индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "BykovTrend Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован Aqua цвет
#property indicator_color2  clrAqua
//--- толщина индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "BykovTrend Buy"

//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
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
input Smooth_Method MA_Method1=MODE_SMA; //метод усреднения первого сглаживания 
input int Length1=7; //глубина  первого сглаживания                    
input int Phase1=15; //параметр первого сглаживания,
                     //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; //метод усреднения второго сглаживания 
input int Length2=7; //глубина  второго сглаживания 
input int Phase2=15; //параметр второго сглаживания,
                     //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| MaByMa indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int ATR_Period=15;
   min_rates_1=XMA1.GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total=min_rates_1+XMA2.GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=int(MathMax(ATR_Period,min_rates_total));
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1",Length1);
   XMA2.XMALengthCheck("Length2",Length2);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1",Phase1,MA_Method1);
   XMA2.XMAPhaseCheck("Phase2",Phase2,MA_Method2);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"MaByMa(",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| MaByMa iteration function                                        | 
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

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double price,x1xma,x2xma,ATR[];
   int trend,maxbar1,maxbar2;
   static int prev_trend;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров
      prev_trend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- восстанавливаем значения переменных
   trend=prev_trend;
   maxbar1=rates_total-1;
   maxbar2=maxbar1-min_rates_1;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      price=PriceSeries(IPC,bar,open,low,high,close); 
      x1xma=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price,bar,true);
      x2xma=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,true);
      if(x1xma>x2xma) trend=+1;
      if(x1xma<x2xma) trend=-1;
      if(prev_trend<0 && trend>0) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(prev_trend>0 && trend<0) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      if(bar) prev_trend=trend;    
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

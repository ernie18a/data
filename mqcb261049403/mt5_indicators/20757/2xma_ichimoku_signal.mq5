//+---------------------------------------------------------------------+
//|                                            2XMA_Ichimoku_Signal.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+ 
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "2XMA_Ichimoku Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "2XMA_Ichimoku Buy"
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh>
//---- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum MODE_PRICE //Тип константы
  {
   OPEN = 0,     //По ценам открытия
   LOW,          //По минимумам
   HIGH,         //По максимумам
   CLOSE         //По ценам закрытия
  };
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
   MODE_AMA    //AMA
  }; */
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint Up_period1=6; //1 период, используемый для вычисления наивысшего значения цены
input uint Dn_period1=6; //1 период, используеммый для вычисления наинизшего значения цены
//----
input uint Up_period2=9; //2 период, используемый для вычисления наивысшего значения цены
input uint Dn_period2=9; //2 период, используеммый для вычисления наинизшего значения цены
//---- 
input MODE_PRICE Up_mode1=HIGH;  //1 таймсерия для поиска максимумов 
input MODE_PRICE Dn_mode1=LOW;   //1 таймсерия для поиска минимумов 
//---- 
input MODE_PRICE Up_mode2=HIGH;  //2 таймсерия для поиска максимумов 
input MODE_PRICE Dn_mode2=LOW;   //2 таймсерия для поиска минимумов  
//---- 
input Smooth_Method XMA1_Method=MODE_SMA_; //1 метод усреднения
input Smooth_Method XMA2_Method=MODE_SMA_; //2 метод усреднения
//----
input int XLength1=25; //1 глубина сглаживания 
input int XLength2=80; //2 глубина сглаживания
//----                  
input int XPhase=15; //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//+-----------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates;
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//+------------------------------------------------------------------+
//| Поиск максимумов                                                 |
//+------------------------------------------------------------------+
int FindMaximum
(
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 MODE_PRICE Mode,
 uint index,
 uint period
 )
// FindMaximum(open,high,low,close,Up_mode,bar,Up_period)
  {
//----
   int max=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: max=ArrayMaximum(Open,index,period); break;
      case LOW: max=ArrayMaximum(Low,index,period); break;
      case HIGH: max=ArrayMaximum(High,index,period); break;
      case CLOSE: max=ArrayMaximum(Close,index,period); break;
     }

//----
   return(max);
  }
//+------------------------------------------------------------------+
//| Поиск минимумов                                                  |
//+------------------------------------------------------------------+
int FindMinimum
(
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 MODE_PRICE Mode,
 uint index,
 uint period
 )
// FindMinimum(open,high,low,close,Dn_mode,bar,Dn_period)
  {
//----
   int min=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: min=ArrayMinimum(Open,index,period); break;
      case LOW: min=ArrayMinimum(Low,index,period); break;
      case HIGH: min=ArrayMinimum(High,index,period); break;
      case CLOSE: min=ArrayMinimum(Close,index,period); break;
     }

//----
   return(min);
  }
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=int(MathMax(Up_period1,Dn_period1));
   min_rates=min_rates_1+=GetStartBars(XMA1_Method,XLength1,XPhase);
   int min_rates_2=int(MathMax(Up_period2,Dn_period2));
   min_rates_2+=GetStartBars(XMA2_Method,XLength2,XPhase);
   min_rates=int(MathMax(min_rates,min_rates_2));
   min_rates_total=int(MathMax(min_rates_1,min_rates_2));
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname="2XMA_Ichimoku_Signal";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
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
//---- Проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double ish_Up,ish_Dn,xma1,xma2,xma_ichimoku,ATR[];
   static double xma_ichimoku_prev;
//---- Объявление целых переменных
   int limit,to_copy,trend,maxbar=rates_total-min_rates-1;
   static int trend_prev;

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=maxbar; // стартовый номер для расчёта всех баров
      trend_prev=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- Основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=NULL;
      SellBuffer[bar]=NULL;
      //---
      ish_Up=high[FindMaximum(open,high,low,close,Up_mode1,bar,Up_period1)];
      ish_Dn=low[FindMinimum(open,high,low,close,Dn_mode1,bar,Dn_period1)];
      xma1=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA1_Method,XPhase,XLength1,(ish_Up+ish_Dn)/2,bar,true);
      //----
      ish_Up=high[FindMaximum(open,high,low,close,Up_mode2,bar,Up_period2)];
      ish_Dn=low[FindMinimum(open,high,low,close,Dn_mode2,bar,Dn_period2)];
      xma2=XMA2.XMASeries(maxbar,prev_calculated,rates_total,XMA2_Method,XPhase,XLength2,(ish_Up+ish_Dn)/2,bar,true);
      //----
      trend=trend_prev;
      xma_ichimoku=xma1-xma2;
      if(xma_ichimoku>xma_ichimoku_prev) trend=+1;
      if(xma_ichimoku<xma_ichimoku_prev) trend=-1;
      
      if(trend_prev<0 && trend>0) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(trend_prev>0 && trend<0)SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //----
      if(bar)
        {
         trend_prev=trend;
         xma_ichimoku_prev=xma_ichimoku;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

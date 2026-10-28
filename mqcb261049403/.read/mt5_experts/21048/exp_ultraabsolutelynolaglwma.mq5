//+------------------------------------------------------------------+
//|                                 Exp_UltraAbsolutelyNoLagLwma.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.10"
//---- Включение индикатора в код эксперта как ресурса
//#resource "\\Indicators\\UltraAbsolutelyNoLagLwma.ex5"
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      // Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//|  Торговые алгоритмы                          | 
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;       //Способ определения размера лота
input int    StopLoss_=1000;      // стоплосс в пунктах
input int    TakeProfit_=2000;    // тейкпрофит в пунктах
input int    Deviation_=10;       // макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     // Разрешение для входа в лонг
input bool   SellPosOpen=true;    // Разрешение для входа в шорт
input bool   BuyPosClose=true;    // Разрешение для выхода из лонгов
input bool   SellPosClose=true;   // Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4;   // Таймфрейм индикатора UltraAbsolutelyNoLagLwma
//----
input uint FLength=7;                               // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;              // ценовая константа
//----
input Smooth_Method W_Method=MODE_JJMA;             // Метод усреднения
input int StartLength=3;                            // Стартовый период усреднения                    
input int WPhase=100;                               // Параметр усреднения
//----  
input uint PStep=5;                                 // Шаг изменения периода
input uint PStepsTotal=10;                          // Количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Метод сглаживания
input int SmoothLength=3;                           // Глубина сглаживания
input int SmoothPhase=100;                          // Параметр сглаживания
//----                           
input uint SignalBar=1;                             // Номер бара для получения сигнала входа
//+----------------------------------------------+

int TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора UltraAbsolutelyNoLagLwma
 //InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\UltraAbsolutelyNoLagLwma",
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"UltraAbsolutelyNoLagLwma",
   FLength,IPC,W_Method,StartLength,WPhase,PStep,PStepsTotal,SmoothMethod,SmoothLength,SmoothPhase,80,20,clrBlue,clrBlue,1,1);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraAbsolutelyNoLagLwma");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчета данных
   min_rates_total=int(FLength*2.0);
   min_rates_total+=GetStartBars(W_Method,StartLength+PStep*PStepsTotal,WPhase)+1;
   min_rates_total+=GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
   min_rates_total+=int(3+SignalBar);
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   GlobalVariableDel_(Symbol());
//----
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(InpInd_Handle)<min_rates_total) return;

//---- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(InpInd_Timeframe)-1,Symbol(),InpInd_Timeframe);

//---- Объявление локальных переменных
   double Value[2];
//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//+----------------------------------------------+
//| Определение сигналов для сделок              |
//+----------------------------------------------+
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,2,SignalBar,2,Value)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Value[1]>4)
        {
         if(BuyPosOpen) if(Value[0]<5 && Value[0]) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Value[1]<5 && Value[1])
        {
         if(SellPosOpen) if(Value[0]>4) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }

//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- Закрываем лонг
   BuyPositionClose(BUY_Close,Symbol(),Deviation_);

//---- Закрываем шорт   
   SellPositionClose(SELL_Close,Symbol(),Deviation_);

//---- Открываем лонг
   BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);

//---- Открываем шорт
   SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
//----
  }
//+------------------------------------------------------------------+

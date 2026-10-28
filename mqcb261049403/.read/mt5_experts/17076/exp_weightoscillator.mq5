//+------------------------------------------------------------------+
//|                                         Exp_WeightOscillator.mq5 |
//|                               Copyright © 2016, Хлыстов Владимир | 
//|                                                cmillion@narod.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Хлыстов Владимир"
#property link      "cmillion@narod.ru"
#property version   "1.00"
//---- Включение индикаторов в код эксперта как ресурсов
#resource "\\Indicators\\WeightOscillator.ex5"
#resource "\\Indicators\\WeightOscillator_HTF.ex5"
//+-----------------------------------------------+
//  Торговые алгоритмы                            | 
//+-----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+-----------------------------------------------+
//|  Перечисление для вариантов расчёта лота      |
//+-----------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+-----------------------------------------------+
//|  Перечисление для определения тренда          |
//+-----------------------------------------------+
enum TrendMode
  {
   DIRECT=0,         //по сигналам
   AGAINST           //против сигналов
  };
//+-----------------------------------------------+
//|  Описание класса CXMA                         |
//+-----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------------+
//|  объявление перечислений                      |
//+-----------------------------------------------+
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
//+-----------------------------------------------+
//| Входные параметры индикатора эксперта         |
//+-----------------------------------------------+
input double MM=0.1;              //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов
input bool   SellPosClose=true;    //Разрешение для выхода из шортов
//+-----------------------------------------------+
//| Входные параметры индикатора                  |
//+-----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H6; //таймфрейм индикатора
input TrendMode            Trend=DIRECT;          //торговля
//----
//---- Параметры RSI
input double RSIWeight=1.0;
input uint   RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- Параметры MFI
input double MFIWeight=1.0;
input uint   MFIPeriod=14;
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;
//---- Параметры WPR
input double WPRWeight=1.0;
input uint   WPRPeriod=14;
//---- Параметры DeMarker
input double DeMarkerWeight=1.0;
input uint   DeMarkerPeriod=14;
//---- Включение сглаживания волны
input Smooth_Method bMA_Method=MODE_JJMA;         // метод усреднения
input uint bLength=5;                             // глубина сглаживания                    
input int bPhase=100;                             // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint HighLevel=70;                          // уровень перезакупа
input uint LowLevel=30;                           // уровень перепроданности
//----
input uint                 SignalBar=1;           // номер бара для получения сигнала входа
//+-----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
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
//---- получение хендла индикатора WeightOscillator
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\WeightOscillator",RSIWeight,RSIPeriod,RSIPrice,MFIWeight,MFIPeriod,MFIVolumeType,
                         WPRWeight,WPRPeriod,DeMarkerWeight,DeMarkerPeriod,bMA_Method,bLength,bPhase,HighLevel,LowLevel);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора WeightOscillator");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора WeightOscillator_HTF для визуализации в тестере стратегий   
   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора WeightOscillator_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"::Indicators\\WeightOscillator_HTF",InpInd_Timeframe,
                             RSIWeight,RSIPeriod,RSIPrice,MFIWeight,MFIPeriod,MFIVolumeType,
                             WPRWeight,WPRPeriod,DeMarkerWeight,DeMarkerPeriod,bMA_Method,bLength,bPhase,HighLevel,LowLevel);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора WeightOscillator_HTF");
         return(INIT_FAILED);
        }
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(RSIPeriod,MathMax(MFIPeriod,MathMax(WPRPeriod,DeMarkerPeriod))))+1;
   min_rates_total+=GetStartBars(bMA_Method,bLength,bPhase);
   min_rates_total+=int(3+SignalBar);
//--- завершение инициализации
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

//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//+-----------------------------------------------+
//| Определение сигналов для сделок               |
//+-----------------------------------------------+
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;
      //---- Объявление локальных переменных
      double WeightOscillator[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,WeightOscillator)<=0) {Recount=true; return;}

      if(Trend==DIRECT)
        {
         //---- Получим сигналы для покупки
         if(WeightOscillator[1]>LowLevel)
           {
            if(WeightOscillator[0]<=LowLevel)
              {
               if(BuyPosOpen) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
              }

            UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(WeightOscillator[1]<HighLevel)
           {
            if(WeightOscillator[0]>=HighLevel)
              {
               if(SellPosOpen) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
              }
            DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }
        }

      if(Trend==AGAINST)
        {
         //---- Получим сигналы для покупки
         if(WeightOscillator[1]>LowLevel)
           {
            if(WeightOscillator[0]<=LowLevel)
              {
               if(SellPosOpen) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
              }
            DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(WeightOscillator[1]<HighLevel)
           {
            if(WeightOscillator[0]>=HighLevel)
              {
               if(BuyPosOpen) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
        }
     }

//+-----------------------------------------------+
//| Совершение сделок                             |
//+-----------------------------------------------+
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

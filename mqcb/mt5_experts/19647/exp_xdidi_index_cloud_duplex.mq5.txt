//+------------------------------------------------------------------+
//|                                 Exp_XDidi_Index_Cloud_Duplex.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.05"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//  Торговые алгоритмы                           | 
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//|  Перечисление для вариантов расчёта лота     |
//+----------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
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
//| Входные параметры эксперта для лонгов        |
//+----------------------------------------------+
input uint    L_Magic=777;          //L магик номер
input double  L_MM=0.1;             //L Доля финансовых ресурсов от депозита в сделке
input MarginMode L_MMMode=LOT;      //L способ определения размера лота
input uint    L_StopLoss_=1000;     //L стоплосс в пунктах
input uint    L_TakeProfit_=2000;   //L тейкпрофит в пунктах
input uint    L_Deviation_=10;      //L макс. отклонение цены в пунктах
input bool    L_PosOpen=true;       //L Разрешение для входа в лонг
input bool    L_PosClose=true;      //L Разрешение для выхода из лонгов
//+----------------------------------------------+
//| Входные параметры индикатора для лонгов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES L_InpInd_Timeframe=PERIOD_H4;     //L таймфрейм индикатора
input Smooth_Method L_Curta_Method=MODE_SMA_;           //L Curta метод усреднения
input uint L_Curta=3;                                   //L Curta глубина сглаживания                    
input int L_CPhase=15;                                  //L Curta параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
//--- 
input Smooth_Method L_Media_Method=MODE_SMA_;           //L Media метод усреднения
input uint L_Media=8;                                   //L Media глубина сглаживания                    
input int L_MPhase=15;                                  //L Media параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей

input Smooth_Method L_Longa_Method=MODE_SMA_;           //L Longa метод усреднения
input uint L_Longa=20;                                  //L Longa глубина сглаживания                    
input int L_LPhase=15;                                  //L Longa параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ L_IPC=PRICE_CLOSE_;                //L ценовая константа
input bool  L_Revers=false;                             //L переворот графика относительно оси времени
input uint L_SignalBar=1;                               //L номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для шортов        |
//+----------------------------------------------+
input uint    S_Magic=555;          //S магик номер
input double  S_MM=0.1;             //S Доля финансовых ресурсов от депозита в сделке
input MarginMode S_MMMode=LOT;      //S способ определения размера лота
input uint    S_StopLoss_=1000;     //S стоплосс в пунктах
input uint    S_TakeProfit_=2000;   //S тейкпрофит в пунктах
input uint    S_Deviation_=10;      //S макс. отклонение цены в пунктах
input bool    S_PosOpen=true;       //S Разрешение для входа в лонг
input bool    S_PosClose=true;      //S Разрешение для выхода из лонгов
//+----------------------------------------------+
//| Входные параметры индикатора для шортов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES S_InpInd_Timeframe=PERIOD_H4;     //S таймфрейм индикатора
input Smooth_Method S_Curta_Method=MODE_SMA_;           //S Curta метод усреднения
input uint S_Curta=3;                                   //S Curta глубина сглаживания                    
input int S_CPhase=15;                                  //S Curta параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
//--- 
input Smooth_Method S_Media_Method=MODE_SMA_;           //S Media метод усреднения
input uint S_Media=8;                                   //S Media глубина сглаживания                    
input int S_MPhase=15;                                  //S Media параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей

input Smooth_Method S_Longa_Method=MODE_SMA_;           //S Longa метод усреднения
input uint S_Longa=20;                                  //S Longa глубина сглаживания                    
input int S_LPhase=15;                                  //S Longa параметр сглаживания,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ S_IPC=PRICE_CLOSE_;                //S ценовая константа
input bool  S_Revers=false;                             //S переворот графика относительно оси времени
input uint S_SignalBar=1;                               //S номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
int L_TimeShiftSec,S_TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int L_InpInd_Handle,S_InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int L_min_rates_total,S_min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора XDidi_Index_Cloud L
   L_InpInd_Handle=iCustom(Symbol(),L_InpInd_Timeframe,"XDidi_Index_Cloud",
                           L_Curta_Method,L_Curta,L_CPhase,L_Media_Method,L_Media,L_MPhase,L_Longa_Method,L_Longa,L_LPhase,L_IPC,L_Revers);

   if(L_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XDidi_Index_Cloud L");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора XDidi_Index_Cloud S
   S_InpInd_Handle=iCustom(Symbol(),S_InpInd_Timeframe,"XDidi_Index_Cloud",
                           S_Curta_Method,S_Curta,S_CPhase,S_Media_Method,S_Media,S_MPhase,S_Longa_Method,S_Longa,S_LPhase,S_IPC,S_Revers);

   if(S_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XDidi_Index_Cloud S");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   L_TimeShiftSec=PeriodSeconds(L_InpInd_Timeframe);
   S_TimeShiftSec=PeriodSeconds(S_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   L_min_rates_total=int(MathMax(MathMax(GetStartBars(L_Curta_Method,L_Curta,L_CPhase),
                       GetStartBars(L_Media_Method,L_Media,L_MPhase)),
                       GetStartBars(L_Longa_Method,L_Longa,L_LPhase)));
   L_min_rates_total+=int(3+L_SignalBar);
//---- Инициализация переменных начала отсчёта данных
   S_min_rates_total=int(MathMax(MathMax(GetStartBars(S_Curta_Method,S_Curta,S_CPhase),
                       GetStartBars(S_Media_Method,S_Media,S_MPhase)),
                       GetStartBars(S_Longa_Method,S_Longa,S_LPhase)));
   S_min_rates_total+=int(3+S_SignalBar);
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
   if(BarsCalculated(L_InpInd_Handle)<L_min_rates_total) return;
   if(BarsCalculated(S_InpInd_Handle)<S_min_rates_total) return;

//---- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(L_InpInd_Timeframe)-1,Symbol(),L_InpInd_Timeframe);
   LoadHistory(TimeCurrent()-PeriodSeconds(L_InpInd_Timeframe)-1,Symbol(),L_InpInd_Timeframe);

//---- Объявление локальных переменных
   double Ind[2],Sign[2];
//---- Объявление статических переменных
   static bool L_Recount=true,S_Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar L_NB,S_NB;

//+----------------------------------------------+
//| Определение сигналов для длинных позиций     |
//+----------------------------------------------+
   if(!L_SignalBar || L_NB.IsNewBar(Symbol(),L_InpInd_Timeframe) || L_Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      BUY_Close=false;
      L_Recount=false;

      //---- копируем вновь появившиеся данные в массивы      
      if(CopyBuffer(L_InpInd_Handle,0,L_SignalBar,2,Ind)<=0) {L_Recount=true; return;}
      if(CopyBuffer(L_InpInd_Handle,1,L_SignalBar,2,Sign)<=0) {L_Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Ind[1]>Sign[1])
        {
         if(L_PosOpen && Ind[0]<=Sign[0]) BUY_Open=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),L_InpInd_Timeframe,SERIES_LASTBAR_DATE))+L_TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Ind[1]<Sign[1])
        {
         if(L_PosClose) BUY_Close=true;
        }
     }
//+----------------------------------------------+
//| Определение сигналов для коротких позиций    |
//+----------------------------------------------+
   if(!S_SignalBar || S_NB.IsNewBar(Symbol(),S_InpInd_Timeframe) || S_Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      SELL_Open=false;
      SELL_Close=false;
      S_Recount=false;

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(S_InpInd_Handle,0,S_SignalBar,2,Ind)<=0) {S_Recount=true; return;}
      if(CopyBuffer(S_InpInd_Handle,1,S_SignalBar,2,Sign)<=0) {S_Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Ind[1]<Sign[1])
        {
         if(S_PosOpen && Ind[0]>=Sign[0]) SELL_Open=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),S_InpInd_Timeframe,SERIES_LASTBAR_DATE))+S_TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Ind[1]>Sign[1])
        {
         if(L_PosClose) SELL_Close=true;
        }
     }

//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- Закрываем лонг
   BuyPositionClose_M(BUY_Close,Symbol(),L_Deviation_,L_Magic);

//---- Закрываем шорт   
   SellPositionClose_M(SELL_Close,Symbol(),S_Deviation_,S_Magic);

//---- Открываем лонг
   BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,L_MM,L_MMMode,L_Deviation_,L_StopLoss_,L_TakeProfit_,L_Magic);

//---- Открываем шорт
   SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,S_MM,S_MMMode,S_Deviation_,S_StopLoss_,S_TakeProfit_,S_Magic);
//----
  }
//+------------------------------------------------------------------+

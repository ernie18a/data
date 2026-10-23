//+------------------------------------------------------------------+
//|                                Exp_ColorMaRsi-Trigger_Duplex.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
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
input uint L_nPeriodRsi=3;
input ENUM_APPLIED_PRICE L_nRSIPrice=PRICE_WEIGHTED;
input uint L_nPeriodRsiLong=13;
input ENUM_APPLIED_PRICE L_nRSIPriceLong=PRICE_MEDIAN;
input uint L_nPeriodMa=5;
input  ENUM_MA_METHOD L_nMAType=MODE_EMA;
input ENUM_APPLIED_PRICE L_nMAPrice=PRICE_CLOSE;
input uint L_nPeriodMaLong=10;
input  ENUM_MA_METHOD L_nMATypeLong=MODE_EMA;
input ENUM_APPLIED_PRICE L_nMAPriceLong=PRICE_CLOSE;
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
input uint S_nPeriodRsi=3;
input ENUM_APPLIED_PRICE S_nRSIPrice=PRICE_WEIGHTED;
input uint S_nPeriodRsiLong=13;
input ENUM_APPLIED_PRICE S_nRSIPriceLong=PRICE_MEDIAN;
input uint S_nPeriodMa=5;
input  ENUM_MA_METHOD S_nMAType=MODE_EMA;
input ENUM_APPLIED_PRICE S_nMAPrice=PRICE_CLOSE;
input uint S_nPeriodMaLong=10;
input  ENUM_MA_METHOD S_nMATypeLong=MODE_EMA;
input ENUM_APPLIED_PRICE S_nMAPriceLong=PRICE_CLOSE;
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
//---- получение хендла индикатора ColorMaRsi-Trigger L
   L_InpInd_Handle=iCustom(Symbol(),L_InpInd_Timeframe,"ColorMaRsi-Trigger",L_nPeriodRsi,L_nRSIPrice,L_nPeriodRsiLong,L_nRSIPriceLong,
                  L_nPeriodMa,L_nMAType,L_nMAPrice,L_nPeriodMaLong,L_nMATypeLong,L_nMAPriceLong,0);

   if(L_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorMaRsi-Trigger L");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора ColorMaRsi-Trigger S
   S_InpInd_Handle=iCustom(Symbol(),S_InpInd_Timeframe,"ColorMaRsi-Trigger",S_nPeriodRsi,S_nRSIPrice,S_nPeriodRsiLong,S_nRSIPriceLong,
                  S_nPeriodMa,S_nMAType,S_nMAPrice,S_nPeriodMaLong,S_nMATypeLong,S_nMAPriceLong,0);

   if(S_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorMaRsi-Trigger S");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   L_TimeShiftSec=PeriodSeconds(L_InpInd_Timeframe);
   S_TimeShiftSec=PeriodSeconds(S_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   L_min_rates_total=int(MathMax(MathMax(MathMax(L_nPeriodRsi,L_nPeriodRsiLong),L_nPeriodMa),L_nPeriodMaLong))+1;
   L_min_rates_total+=int(3+L_SignalBar);
//---- Инициализация переменных начала отсчёта данных
   S_min_rates_total=int(MathMax(MathMax(MathMax(S_nPeriodRsi,S_nPeriodRsiLong),S_nPeriodMa),S_nPeriodMaLong))+1;
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
   LoadHistory(TimeCurrent()-PeriodSeconds(S_InpInd_Timeframe)-1,Symbol(),S_InpInd_Timeframe);

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
      //---- Объявление локальных переменных
      double UpValue[2],DnValue[2];     
      
      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(L_InpInd_Handle,0,L_SignalBar,2,DnValue)<=0) {L_Recount=true; return;}
      if(CopyBuffer(L_InpInd_Handle,1,L_SignalBar,2,UpValue)<=0) {L_Recount=true; return;}

      //---- Получим сигналы для покупки
      if(UpValue[1]>DnValue[1])
        {
         if(L_PosOpen) if(UpValue[0]<=DnValue[0]) BUY_Open=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),L_InpInd_Timeframe,SERIES_LASTBAR_DATE))+L_TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(DnValue[1]>UpValue[1])
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
      //---- Объявление локальных переменных
      double UpValue[2],DnValue[2];  
      
     //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(S_InpInd_Handle,0,S_SignalBar,2,DnValue)<=0) {S_Recount=true; return;}
      if(CopyBuffer(S_InpInd_Handle,1,S_SignalBar,2,UpValue)<=0) {S_Recount=true; return;}  

      //---- Получим сигналы для продажи
      if(UpValue[1]<DnValue[1])
        {
         if(S_PosOpen) if(UpValue[0]>=DnValue[0]) SELL_Open=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),S_InpInd_Timeframe,SERIES_LASTBAR_DATE))+S_TimeShiftSec;
        }

      //---- Получим сигналы для покупки
      if(DnValue[1]<UpValue[1])
        {
         if(S_PosClose) SELL_Close=true;
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

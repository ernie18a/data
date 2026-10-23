//+------------------------------------------------------------------+
//|                                                     Exp_3STO.mq5 |
//|                          Copyright © 2011, Rafael Maia de Amorim |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Rafael Maia de Amorim"
#property link      "https://www.metaquotes.net"
#property version   "1.00"
//+-------------------------------------------------+
//  Торговые алгоритмы                              | 
//+-------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+-------------------------------------------------+
//|  Перечисление для вариантов расчёта лота        |
//+-------------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose1=true;     //Разрешение для выхода из лонгов по старшему таймфрейму 1
input bool   SellPosClose1=true;    //Разрешение для выхода из шортов по старшему таймфрейму 1
input bool   BuyPosClose2=true;     //Разрешение для выхода из лонгов по среднему таймфрейму 2
input bool   SellPosClose2=true;    //Разрешение для выхода из шортов по среднему таймфрейму 2
input bool   BuyPosClose3=true;     //Разрешение для выхода из лонгов по меньшему таймфрейму 3
input bool   SellPosClose3=true;    //Разрешение для выхода из шортов по меньшему таймфрейму 3
//+----------------------------------------------+
//| Входные параметры индикатора 3Parabolic      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M30;  //1 Период графика для тренда
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_M15;  //2 Период графика для тренда
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_M5;  //3 Период графика для сигнала
input uint KPeriod=5;
input uint DPeriod=3;
input uint Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
input uint SignalBar=1;    //номер бара для получения сигнала входа
//+----------------------------------------------+

int TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int InpInd_Handle_1,InpInd_Handle_2,InpInd_Handle_3;
//---- объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора iStochastic 1
   InpInd_Handle_1=iStochastic(NULL,TimeFrame1,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(InpInd_Handle_1==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic 1");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора iStochastic 2
   InpInd_Handle_2=iStochastic(NULL,TimeFrame2,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(InpInd_Handle_2==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic 2");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора iStochastic
   InpInd_Handle_3=iStochastic(NULL,TimeFrame3,KPeriod,DPeriod,Slowing,MA_Method,Price_field);
   if(InpInd_Handle_3==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic 3");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(TimeFrame3);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=int(KPeriod+DPeriod+Slowing);
   min_rates_total+=int(2+SignalBar);
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
   if(BarsCalculated(InpInd_Handle_1)<min_rates_total
      || BarsCalculated(InpInd_Handle_2)<min_rates_total
      || BarsCalculated(InpInd_Handle_3)<min_rates_total) return;

//---- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(TimeFrame1)-1,Symbol(),TimeFrame1);
   LoadHistory(TimeCurrent()-PeriodSeconds(TimeFrame2)-1,Symbol(),TimeFrame2);
   LoadHistory(TimeCurrent()-PeriodSeconds(TimeFrame3)-1,Symbol(),TimeFrame3);

//---- Объявление локальных переменных
   static int Trend1,Trend2,Trend3;
//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB1,NB2,NB3;

//---- Определяем тренд для старшего таймфрейма 1
   if(!SignalBar || NB1.IsNewBar(Symbol(),TimeFrame1) || Recount) // проверка на появление нового бара
     {
      Recount=false;
      Trend1=0;
      double Stoch[1],Signal[1];
      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle_1,MAIN_LINE,SignalBar,1,Stoch)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle_1,SIGNAL_LINE,SignalBar,1,Signal)<=0) {Recount=true; return;}
      if(Stoch[0]>Signal[0])
        {
         if(BuyPosOpen) Trend1=+1;
        }
      if(Stoch[0]<Signal[0])
        {
         if(SellPosOpen) Trend1=-1;
        }
     }

//---- Определяем тренд для среднего таймфрейма 2
   if(!SignalBar || NB2.IsNewBar(Symbol(),TimeFrame2) || Recount) // проверка на появление нового бара
     {
      Recount=false;
      Trend2=0;
      double Stoch[1],Signal[1];
      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle_2,MAIN_LINE,SignalBar,1,Stoch)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle_2,SIGNAL_LINE,SignalBar,1,Signal)<=0) {Recount=true; return;}
      if(Stoch[0]>Signal[0])
        {
         if(BuyPosOpen) Trend2=+1;
        }
      if(Stoch[0]<Signal[0])
        {
         if(SellPosOpen) Trend2=-1;
        }
     }
//+----------------------------------------------+
//| Определение сигналов для сделок              |
//+----------------------------------------------+
   if(!SignalBar || NB3.IsNewBar(Symbol(),TimeFrame3) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      Recount=false;
      double Stoch[2],Signal[2];
      Trend3=0;

      //---- копируем вновь появившиеся данные в массивы      
      if(CopyBuffer(InpInd_Handle_3,MAIN_LINE,SignalBar,2,Stoch)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle_3,SIGNAL_LINE,SignalBar,2,Signal)<=0) {Recount=true; return;}

      if(Stoch[1]>Signal[1])
        {
         Trend3=+1;
         //---- Получим сигналы для покупки
         if(BuyPosOpen && Stoch[0]<=Signal[0] && Trend1>0 && Trend2>0)
           {
            BUY_Open=true;
            UpSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrame3,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }
        }

      if(Stoch[1]<Signal[1])
        {
         Trend3=-1;
         //---- Получим сигналы для продажи
         if(SellPosOpen && Stoch[0]>=Signal[0] && Trend1<0 && Trend2<0)
           {
            SELL_Open=true;
            DnSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrame3,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }
        }
     }

   BUY_Close=false;
   SELL_Close=false;
   if(Trend1>0 && SellPosClose1) SELL_Close=true;
   if(Trend1<0  &&  BuyPosClose1) BUY_Close=true;
   if(Trend2>0 && SellPosClose2) SELL_Close=true;
   if(Trend2<0  &&  BuyPosClose2) BUY_Close=true;
   if(Trend3>0 && SellPosClose3) SELL_Close=true;
   if(Trend3<0  &&  BuyPosClose3) BUY_Close=true;
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

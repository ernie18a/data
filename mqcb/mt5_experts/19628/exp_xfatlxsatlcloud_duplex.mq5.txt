//+------------------------------------------------------------------+
//|                                   Exp_XFatlXSatlCloud_Duplex.mq5 |
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
input ENUM_TIMEFRAMES L_InpInd_Timeframe=PERIOD_H4;   //L таймфрейм индикатора
input Smooth_Method L_XMA_Method1=MODE_JJMA;          //L метод усреднения Fatl
input uint L_XLength1=3;                              //L глубина усреднения Fatl
input int L_XPhase1=15;                               //L параметр сглаживания Fatl,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                     
input Smooth_Method L_XMA_Method2=MODE_JJMA;          //L метод усреднения Satl
input uint L_XLength2=5;                              //L глубина усреднения Satl
input int L_XPhase2=15;                               //L параметр сглаживания Satl,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ L_IPC=PRICE_CLOSE_;              //L ценовая константа
input uint L_SignalBar=1;                             //L номер бара для получения сигнала входа
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
input ENUM_TIMEFRAMES S_InpInd_Timeframe=PERIOD_H4;   //S таймфрейм индикатора
input Smooth_Method S_XMA_Method1=MODE_JJMA;          //S метод усреднения Fatl
input uint S_XLength1=3;                              //S глубина усреднения Fatl
input int S_XPhase1=15;                               //S параметр сглаживания Fatl,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                     
input Smooth_Method S_XMA_Method2=MODE_JJMA;          //S метод усреднения Satl
input uint S_XLength2=5;                              //S глубина усреднения Satl
input int S_XPhase2=15;                               //S параметр сглаживания Satl,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ S_IPC=PRICE_CLOSE_;              //S ценовая константа
input uint S_SignalBar=1;                             //S номер бара для получения сигнала входа
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
//---- получение хендла индикатора XFatlXSatlCloud L
   L_InpInd_Handle=iCustom(Symbol(),L_InpInd_Timeframe,"XFatlXSatlCloud",L_XMA_Method1,L_XLength1,L_XPhase1,L_XMA_Method2,L_XLength2,L_XPhase2,L_IPC);
   if(L_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XFatlXSatlCloud L");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора XFatlXSatlCloud S
   S_InpInd_Handle=iCustom(Symbol(),S_InpInd_Timeframe,"XFatlXSatlCloud",S_XMA_Method1,S_XLength1,S_XPhase1,S_XMA_Method2,S_XLength2,S_XPhase2,S_IPC);
   if(S_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XFatlXSatlCloud S");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   L_TimeShiftSec=PeriodSeconds(L_InpInd_Timeframe);
   S_TimeShiftSec=PeriodSeconds(S_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   int min_rates_1=39;
   int min_rates_2=min_rates_1+GetStartBars(L_XMA_Method1,L_XLength1,L_XPhase1);
   int min_rates_3=65;
   int min_rates_4=min_rates_3+GetStartBars(L_XMA_Method2,L_XLength2,L_XPhase2);
   L_min_rates_total=MathMax(min_rates_2,min_rates_4);
   L_min_rates_total+=int(3+L_SignalBar);
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=39;
   min_rates_2=min_rates_1+GetStartBars(S_XMA_Method1,S_XLength1,S_XPhase1);
   min_rates_3=65;
   min_rates_4=min_rates_3+GetStartBars(S_XMA_Method2,S_XLength2,S_XPhase2);
   S_min_rates_total=MathMax(min_rates_2,min_rates_4);
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

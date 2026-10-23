//+------------------------------------------------------------------+
//|                                               Exp_BlauTVI_Tm.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.10"
//---- Включение индикатора в код эксперта как ресурса
#resource "\\Indicators\\BlauTVI.ex5"
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  Торговые алгоритмы                          | 
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;       //Способ определения размера лота
input int    StopLoss_=1000;       //стоплосс в пунктах
input int    TakeProfit_=2000;     //тейкпрофит в пунктах
input int    Deviation_=10;        //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;      //Разрешение для входа в лонг
input bool   SellPosOpen=true;     //Разрешение для входа в шорт
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов
input bool   SellPosClose=true;    //Разрешение для выхода из шортов
input bool   TimeTrade=true;       // Разрешение для торговли по интервалам времени
input HOURS  StartH=ENUM_HOUR_0;   // Старт торговли (Часы)
input MINUTS StartM=ENUM_MINUT_0;  // Старт торговли (Минуты)
input HOURS  EndH=ENUM_HOUR_23;    // Окончание торговли (Часы)
input MINUTS EndM=ENUM_MINUT_59;   // Окончание торговли (Минуты)
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4;  // таймфрейм индикатора

input Smooth_Method XMA_Method=MODE_EMA_;          // метод усреднения
input uint XLength1=12;                            // глубина первого усреднения
input uint XLength2=12;                            // глубина второго усреднения
input uint XLength3=5;                             // глубина третьего усреднения
input int XPhase=15;                               // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём

input uint SignalBar=1;//номер бара для получения сигнала входа
//+----------------------------------------------+
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
//---- получение хендла индикатора BlauTVI
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\BlauTVI",XMA_Method,XLength1,XLength2,XLength3,XPhase,VolumeType);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора BlauTVI");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total+=GetStartBars(XMA_Method,XLength1,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,XLength2,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,XLength3,XPhase);  
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
   double Value[3];
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
      if(CopyBuffer(InpInd_Handle,0,SignalBar,3,Value)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Value[1]<Value[2])
        {
         if(BuyPosOpen&&Value[0]>Value[1]) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Value[1]>Value[2])
        {
         if(SellPosOpen&&Value[0]<Value[1]) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }
//+----------------------------------------------+
//| Определение сигналов для торговли в периоде  |
//+----------------------------------------------+ 
//---- Объявление переменной для разрешения торговли
   bool Trade=false;
   if(TimeTrade)
     {
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);

      if(StartH<EndH)
        {
         if(tm.hour==StartH && tm.min>=StartM) Trade=true;
         if(tm.hour>StartH && tm.hour<EndH) Trade=true;
         if(tm.hour>StartH && tm.hour==EndH && tm.min<EndM) Trade=true;
        }

      if(StartH==EndH)
        {
         if(tm.hour==StartH && tm.min>=StartM && tm.min<EndM) Trade=true;
        }

      if(StartH>EndH)
        {
         if(tm.hour>=StartH && tm.min>=StartM) Trade=true;
         if(tm.hour<EndH) Trade=true;
         if(tm.hour==EndH && tm.min<EndM) Trade=true;
        }
     }
//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- закрываем позиции вне торгового интервала
   if(TimeTrade && !Trade && PositionsTotal())
     {
      bool Signal=true;
      BuyPositionClose(Signal,Symbol(),Deviation_);
      Signal=true;
      SellPositionClose(Signal,Symbol(),Deviation_);
     }

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

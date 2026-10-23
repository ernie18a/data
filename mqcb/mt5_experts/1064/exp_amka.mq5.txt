//+------------------------------------------------------------------+
//|                                                     Exp_AMkA.mq5 |
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.10"
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
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;              //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов
input bool   SellPosClose=true;    //Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора AMkA            |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; //таймфрейм индикатора
input int ama_period=9; // период AMA
input int fast_ma_period=2; // период быстрой скользящей
input int slow_ma_period=30; // период медленной скользящей
input double G=2.0; // степень, в которую возводится сглаживающая константа
input double dK = 1.0;  //коэффициент для фильтра
input uint SignalBar=1; //номер бара для получения сигнала входа
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
//---- получение хендла индикатора AMkA
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"AMkA",ama_period,fast_ma_period,slow_ma_period,G,0,dK);
   if(InpInd_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора AMkA");

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=int(3+2*ama_period+2+SignalBar);
//----
   return(0);
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
   double DnValue[1],UpValue[1];
//---- Объявление статических переменных
   int LastTrend;
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
      LastTrend=0;
      Recount=false;

      //---- Поиск последнего направления торговли
      int Bars_=Bars(Symbol(),InpInd_Timeframe);
      if(Bars_<min_rates_total) {Recount=true; return;}
      Bars_-=min_rates_total+3;

      for(int bar=int(SignalBar+1); bar<Bars_; bar++)
        {
         if(CopyBuffer(InpInd_Handle,1,bar,1,DnValue)<=0) {Recount=true; return;}
         if(DnValue[0])
           {
            LastTrend=-1;
            if(BuyPosClose) BUY_Close=true;
            break;
           }
         if(CopyBuffer(InpInd_Handle,2,bar,1,UpValue)<=0) {Recount=true; return;}
         if(UpValue[0])
           {
            LastTrend=+1;
            if(SellPosClose) SELL_Close=true;
            break;
           }
        }

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,2,SignalBar,1,UpValue)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,1,SignalBar,1,DnValue)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(UpValue[0])
        {
         if(BuyPosOpen && LastTrend<0) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         if(BuyPosClose) BUY_Close=false;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(DnValue[0])
        {
         if(SellPosOpen && LastTrend>0) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         if(SellPosClose) SELL_Close=false;
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

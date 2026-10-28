//+------------------------------------------------------------------+
//|         Exp_SpearmanRankCorrelation_Histogram_TimeWeekPeriod.mq5 |
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
//|  Перечисление для алгоритмов входа и выхода  |
//+----------------------------------------------+
enum TradeMode
  {
   ENUM_TRADE_MODE_1=0,     //Входы и выходы при пробое нуля
   ENUM_TRADE_MODE_2,       //Входы в зонах ПК и ПП, выходы уже при пробое нуля
   ENUM_TRADE_MODE_3        //Входы и выходы в зонах ПК и ПП
  };
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;                             //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;                     //способ определения размера лота
input int    StopLoss_=1000;                     //стоплосс в пунктах
input int    TakeProfit_=2000;                   //тейкпрофит в пунктах
input int    Deviation_=10;                      //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;                    //Разрешение для входа в лонг
input bool   SellPosOpen=true;                   //Разрешение для входа в шорт
input bool   BuyPosClose=true;                   //Разрешение для выхода из лонгов
input bool   SellPosClose=true;                  //Разрешение для выхода из шортов
input TradeMode Trade_Mode=ENUM_TRADE_MODE_1;    //Алгоритм входа и выхода
//----
input bool   TimeTrade=true;      //Разрешение на торговлю по интервалам
//----
input DAYS_OF_WEEK StartD=ENUM_DAY_OF_WEEK_2;  //Старт торговли (День недели)
input HOURS  StartH=ENUM_HOUR_8;  //Старт торговли (Час)
input MINUTS StartM=ENUM_MINUT_0; //Старт торговли (Минута)
input SECONDS StartS=ENUM_SECOND_0; //Старт торговли (Секунда)
//----
input DAYS_OF_WEEK EndD=ENUM_DAY_OF_WEEK_5;  //Конец торговли (День недели)
input HOURS  EndH=ENUM_HOUR_20;   //Конец торговли (Час)
input MINUTS EndM=ENUM_MINUT_59;  //Конец торговли (Минута)
input SECONDS EndS=ENUM_SECOND_40; //Конец торговли (Секунда)
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; //таймфрейм индикатора
//----
input int  rangeN=14;
input int  CalculatedBars=0;
input int  Maxrange=30;
input bool Direction=true;
input double inHighLevel=+0.5;
input double inLowLevel=-0.5;
//----
input uint SignalBar=1;                           // номер бара для получения сигнала входа
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
//---- получение хендла индикатора SpearmanRankCorrelation_Histogram
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"SpearmanRankCorrelation_Histogram",rangeN,CalculatedBars,Maxrange,Direction,inHighLevel,inLowLevel);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора SpearmanRankCorrelation_Histogram");
      return(INIT_FAILED);
     }
//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(rangeN);
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
      //---- Объявление локальных переменных
      double Col[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,1,SignalBar,2,Col)<=0) {Recount=true; return;}

      switch(Trade_Mode)
        {
         case ENUM_TRADE_MODE_1:
           {
            //---- Получим сигналы для покупки
            if(Col[1]>2)
              {
               if(BuyPosOpen && Col[0]<3) BUY_Open=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
               if(SellPosClose) SELL_Close=true;
              }

            //---- Получим сигналы для продажи
            if(Col[1]<2)
              {
               if(SellPosOpen && Col[0]>1) SELL_Open=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
               if(BuyPosClose) BUY_Close=true;
              }

            break;
           }

         case ENUM_TRADE_MODE_2:
           {
            //---- Получим сигналы для покупки
            if(Col[1]==4)
              {
               if(BuyPosOpen && Col[0]<4) BUY_Open=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
            if(SellPosClose) if(Col[1]>2) SELL_Close=true;

            //---- Получим сигналы для продажи
            if(Col[1]==0)
              {
               if(SellPosOpen && Col[0]>0) SELL_Open=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
            if(BuyPosClose) if(Col[1]<2) BUY_Close=true;

            break;
           }

         case ENUM_TRADE_MODE_3:
           {
            //---- Получим сигналы для покупки
            if(Col[1]==4)
              {
               if(BuyPosOpen && Col[0]<4) BUY_Open=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
               if(SellPosClose) SELL_Close=true;
              }

            //---- Получим сигналы для продажи
            if(Col[1]==0)
              {
               if(SellPosOpen && Col[0]>0) SELL_Open=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
               if(BuyPosClose) BUY_Close=true;
              }

            break;
           }
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
      if(tm.day_of_week>StartD && tm.day_of_week<EndD) Trade=true;
      if(tm.day_of_week<StartD ||  tm.day_of_week>EndD)Trade=false;

      if(tm.day_of_week==StartD)
        {
         if(tm.hour>StartH) Trade=true;
         if(tm.hour<StartH) Trade=false;
         if(tm.hour==StartH)
           {
            if(tm.min>StartM) Trade=true;
            if(tm.min<StartM) Trade=false;
            if(tm.min==StartM)
              {
               if(tm.sec>=StartS) Trade=true;
               if(tm.sec<StartS) Trade=false;
              }
           }
        }
      //----
      if(tm.day_of_week==EndD)
        {
         if(tm.hour>EndH) Trade=false;
         if(tm.hour<EndH) Trade=true;
         if(tm.hour==EndH)
           {
            if(tm.min>EndM) Trade=false;
            if(tm.min<EndM) Trade=true;
            if(tm.min==EndM)
              {
               if(tm.sec>=EndS) Trade=false;
               if(tm.sec<EndS) Trade=true;
              }
           }
        }
     }
//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- закрываем позиции вне торгового интервала
   if(TimeTrade && !Trade && PositionsTotal())
     {
      //---- закрываем все открытые позиции по текущему символу
      int total=PositionsTotal();
      for(int pos=total-1; pos>=0; pos--)
        {
         string symbol=PositionGetSymbol(pos);
         if(!PositionSelect(symbol)) continue;
         if(symbol!=Symbol()) continue;
         bool Signal=true;
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) BuyPositionClose(Signal,symbol,Deviation_);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) SellPositionClose(Signal,symbol,Deviation_);
        }
     }
   if(Trade || !TimeTrade)
     {
      //---- Закрываем лонг
      BuyPositionClose(BUY_Close,Symbol(),Deviation_);

      //---- Закрываем шорт   
      SellPositionClose(SELL_Close,Symbol(),Deviation_);

      //---- Открываем лонг
      BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);

      //---- Открываем шорт
      SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
     }
//----
  }
//+------------------------------------------------------------------+

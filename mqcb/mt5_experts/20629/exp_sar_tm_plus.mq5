//+------------------------------------------------------------------+
//|                                              Exp_Sar_Tm_Plus.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+------------------------------------------+
//  Торговые алгоритмы                       | 
//+------------------------------------------+
#include <TradeAlgorithms.mqh>
//+------------------------------------------+
//|  Перечисление для вариантов расчёта лота |
//+------------------------------------------+
/*
enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; 
*/
//+------------------------------------------+
//| Входные параметры индикатора эксперта    |
//+------------------------------------------+
input double MM=0.1;              //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;    //Разрешение для выхода из лонгов
input bool   SellPosClose=true;   //Разрешение для выхода из шортов
input bool   TimeTrade=true;      //Разрешение для выхода из позиций по времени
input uint   nTime=240;           //Время удержания открытой позиции в минутах
//+------------------------------------------+
//| Входные параметры индикатора JJRSX       |
//+------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; //таймфрейм индикатора
//----
input double SarStep=0.02;                       // Шаг iSAR
input double SarMaximum=0.2;                     // Максимум iSAR
//----
input uint SignalBar=1;//номер бара для получения сигнала входа
//+------------------------------------------+
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
//---- получение хендла индикатора Sar
   InpInd_Handle=iSAR(Symbol(),InpInd_Timeframe,SarStep,SarMaximum);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Sar");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
   min_rates_total+=30;
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
   double iSar[2],iClose[2];
//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//+------------------------------------------+
//| Определение сигналов для сделок          |
//+------------------------------------------+
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,iSar)<=0) {Recount=true; return;}
      if(CopyClose(Symbol(),InpInd_Timeframe,SignalBar,2,iClose)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(iClose[1]>iSar[1])
        {
         if(BuyPosOpen && iClose[0]<iSar[0]) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(iClose[1]<iSar[1])
        {
         if(SellPosOpen && iClose[0]>iSar[0]) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }

//+------------------------------------------+
//| Совершение сделок                        |
//+------------------------------------------+
//---- закрываем позиции вне торгового интервала
   if(TimeTrade && PositionsTotal())
     {
      //---- закрываем все открытые позиции по текущему символу по истечении времени
      int total=PositionsTotal();
      for(int pos=total-1; pos>=0; pos--)
        {
         string symbol=PositionGetSymbol(pos);
         if(symbol!=Symbol()) continue;
         if(!PositionSelect(symbol)) continue;

         if(TimeCurrent()-PositionGetInteger(POSITION_TIME)>60*nTime)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               bool Signal=true;
               BuyPositionClose(Signal,symbol,Deviation_);
              }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               bool Signal=true;
               SellPositionClose(Signal,symbol,Deviation_);
              }
           }
        }
     }
//---- Закрываем лонг
   BuyPositionClose(BUY_Close,Symbol(),Deviation_);

//---- Закрываем шорт   
   SellPositionClose(SELL_Close,Symbol(),Deviation_);
   Print(LOT);
//---- Открываем лонг
   BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);

//---- Открываем шорт
   SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
//----
  }
//+------------------------------------------------------------------+

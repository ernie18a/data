//+------------------------------------------------------------------+
//|                                             Exp_ThreeCandles.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+------------------------------------------------+
//| Торговые алгоритмы                             |
//+------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+------------------------------------------------+
//| Перечисление для вариантов расчёта лота        |
//+------------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+------------------------------------------------+
//|  объявление перечислений                       |
//+------------------------------------------------+
enum ENUM_APPLIED_VOLUME_      //Тип константы
  {
   VOLUME_TICK_=0,     //VOLUME_TICK
   VOLUME_REAL_,       //VOLUME_REAL
   VOLUME_NONE         //Без объёмов
  };
//+------------------------------------------------+
//| Входные параметры индикатора эксперта          |
//+------------------------------------------------+
input double MM=0.1;              // Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      // Способ определения размера лота
input int    StopLoss_=1000;      // Stop Loss в пунктах
input int    TakeProfit_=2000;    // Take Profit в пунктах
input int    Deviation_=10;       // Макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     // Разрешение для входа в лонг
input bool   SellPosOpen=true;    // Разрешение для входа в шорт
input bool   BuyPosClose=true;    // Разрешение для выхода из лонгов
input bool   SellPosClose=true;   // Разрешение для выхода из шортов
//+------------------------------------------------+
//| Входные параметры индикатора ThreeCandles  |
//+------------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4;    //Таймфрейм индикатора
input uint maxBar1=300;                              //Max Bar #1 size for disable Volume filter, pips
input ENUM_APPLIED_VOLUME_ VolumeType=VOLUME_TICK_;  //объём 
uint NumberofBar=1;                            //Номер бара для подачи сигнала
bool SoundON=false;                            //Разрешение алерта
uint NumberofAlerts=0;                         //Количество алертов
bool EMailON=false;                            //Разрешение почтовой отправки сигнала
bool PushON=false;                             //Разрешение отправки сигнала на мобильный
input uint SignalBar=1;                              //Номер бара для получения сигнала входа
//+------------------------------------------------+
int TimeShiftSec;
//--- объявление целочисленных переменных для хендлов индикаторов
int InpInd_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- получение хендла индикатора ThreeCandles
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"ThreeCandles",maxBar1,VolumeType,NumberofBar,SoundON,NumberofAlerts,EMailON,PushON);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ThreeCandles");
      return(INIT_FAILED);
     }
//--- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);
//--- инициализация переменных начала отсчёта данных
   min_rates_total=4;
   min_rates_total+=int(1+SignalBar);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   GlobalVariableDel_(Symbol());
//---
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
//---- Определение сигналов для сделок
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;
      //---- Объявление локальных переменных
      double Col[1];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,4,SignalBar,1,Col)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Col[0]>2)
        {
         if(BuyPosOpen) BUY_Open=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Col[0]<2)
        {
         if(SellPosOpen) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Поиск последнего направления торговли для получения сигналов для закрывания позиций
      //if(!MQL5InfoInteger(MQL5_TESTING) && !MQL5InfoInteger(MQL5_OPTIMIZATION)) //если режим торговли в тестере "Произвольная задержка" 
      if(((BuyPosOpen && BuyPosClose) || (SellPosOpen && SellPosClose)) && (!BUY_Close && !SELL_Close))
        {
         int Bars_=Bars(Symbol(),InpInd_Timeframe);

         if(BuyPosClose || SellPosClose)
            for(int bar=int(SignalBar+1); bar<Bars_; bar++)
              {
               if(CopyBuffer(InpInd_Handle,4,bar,1,Col)<=0) {Recount=true; return;}
               if(SellPosClose)
                 {

                  if(Col[0]>2)
                    {
                     SELL_Close=true;
                     break;
                    }
                 }

               if(BuyPosClose)
                 {
                  if(Col[0]<2)
                    {
                     BUY_Close=true;
                     break;
                    }
                 }
              }
        }
     }
//---- Совершение сделок
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

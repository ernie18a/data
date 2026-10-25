//+------------------------------------------------------------------+
//|                                                   Exp_RSIOMA.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//---- Включение индикаторов в код эксперта как ресурсов
#resource "\\Indicators\\RSIOMA.ex5"
#resource "\\Indicators\\RSIOMA_HTF.ex5"
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
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum AlgMode
  {
   breakdown,  //пробой уровней
   HistTwist,  //изменение направления гистограммы
   SIGNALtwist,//изменение направления сигнальной линии
   HistDisposition //пробой гистограммой сигнальной линии
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*
enum Smooth_Method
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
  };
*/
//+----------------------------------------------+
//| Входные параметры эксперта                   |
//+----------------------------------------------+
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;       //способ определения размера лота
input int     StopLoss_=1000;      //стоплосс в пунктах
input int     TakeProfit_=2000;    //тейкпрофит в пунктах
input int     Deviation_=10;       //макс. отклонение цены в пунктах
input bool    BuyPosOpen=true;     //Разрешение для входа в лонг
input bool    SellPosOpen=true;    //Разрешение для входа в шорт
input bool    BuyPosClose=true;    //Разрешение для выхода из лонгов
input bool    SellPosClose=true;   //Разрешение для выхода из шортов
input AlgMode Mode=HistDisposition;//алгоритм для входа в рынок
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; // таймфрейм индикатора
input Smooth_Method RSIOMA_Method=MODE_EMA_;  // Метод усреднения RSIOMA
input uint RSIOMA=14;                         // Глубина усреднения RSIOMA
input int RSIOMAPhase=15;                     // Параметр усреднения RSIOMA
input Smooth_Method MARSIOMA_Method=MODE_EMA_;// Метод усреднения MARSIOMA
input uint MARSIOMA=21;                       // Глубина усреднения RSIOMA
input int MARSIOMAPhase=15;                   // Параметр усреднения RSIOMA
input uint MomPeriod=1;                       // Период Моментума
input Applied_price_ IPC=PRICE_CLOSE_;        // Ценовая константа
input int HighLevel=+20;                      // Верхний уровень срабатывания
int MiddleLevel=0;                            // Середина диапазона
input int LowLevel=-20;                       // Нижний уровень срабатывания
input uint SignalBar=1;                       // номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
int TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//  Торговые алгоритмы                                               | 
//+------------------------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(HighLevel<LowLevel && Mode==breakdown)
     {
      Print("Неверное значение параметров Верхнего и Нижнего уровней срабатывания!");
      Print("Верхний уровень срабатывания должен быть не меньше Нижнего уровня срабатывания!");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора RSIOMA
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\RSIOMA",
                         RSIOMA_Method,RSIOMA,RSIOMAPhase,MARSIOMA_Method,MARSIOMA,MARSIOMAPhase,MomPeriod,IPC,HighLevel,MiddleLevel,LowLevel,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора RSIOMA");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора RSIOMA_HTF для визуализации в тестере стратегий   
   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора RSIOMA_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"::Indicators\\RSIOMA_HTF",InpInd_Timeframe,
                             RSIOMA_Method,RSIOMA,RSIOMAPhase,MARSIOMA_Method,MARSIOMA,MARSIOMAPhase,MomPeriod,IPC,HighLevel,MiddleLevel,LowLevel,0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора RSIOMA_HTF");
         return(INIT_FAILED);
        }
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(RSIOMA_Method,RSIOMA,RSIOMAPhase);
   min_rates_total+=int(MomPeriod);
   min_rates_total+=int(RSIOMA+1);
   min_rates_total+=GetStartBars(MARSIOMA_Method,MARSIOMA,RSIOMAPhase);
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

      switch(Mode)
        {
         case breakdown:
           {
            double Value[2];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,0,SignalBar,2,Value)<=0) {Recount=true; return;}

            //---- Получим сигналы для покупки
            if(Value[1]>HighLevel)
              {
               if(BuyPosOpen && Value[0]<=HighLevel) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }

            //---- Получим сигналы для продажи
            if(Value[1]<LowLevel)
              {
               if(SellPosOpen && Value[0]>=LowLevel) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;

         case HistTwist:
           {
            double Value[3];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,0,SignalBar,3,Value)<=0) {Recount=true; return;}

            //---- Получим сигналы для покупки
            if(Value[1]<Value[2])
              {
               if(BuyPosOpen && Value[0]>Value[1]) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }

            //---- Получим сигналы для продажи
            if(Value[1]>Value[2])
              {
               if(SellPosOpen && Value[0]<Value[1]) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;

         case SIGNALtwist:
           {
            double Value[3];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,1,SignalBar,3,Value)<=0) {Recount=true; return;}

            //---- Получим сигналы для покупки
            if(Value[1]<Value[2])
              {
               if(BuyPosOpen && Value[0]>Value[1]) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }

            //---- Получим сигналы для продажи
            if(Value[1]>Value[2])
              {
               if(SellPosOpen && Value[0]<Value[1]) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;

         case HistDisposition:
           {
            double MACD[2],Signal[2];
            //---- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,0,SignalBar,2,MACD)<=0) {Recount=true; return;}
            if(CopyBuffer(InpInd_Handle,1,SignalBar,2,Signal)<=0) {Recount=true; return;}

            //---- Получим сигналы для покупки
            if(MACD[1]>Signal[1])
              {
               if(BuyPosOpen  &&  MACD[0]<=Signal[0]) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }

            //---- Получим сигналы для продажи
            if(MACD[1]<Signal[1])
              {
               if(SellPosOpen && MACD[0]>=Signal[0]) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;
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

//+------------------------------------------------------------------+
//|                                        Exp_BlauErgodicMDI_Tm.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//---- Включение индикатора в код эксперта как ресурса
#resource "\\Indicators\\BlauErgodicMDI.ex5"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum AlgMode
  {
   breakdown,  // Пробой нуля гистограммой
   twist,      // Изменение направления гистограммы
   cloudtwist  // Изменение цвета сигнального облака
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      // Тип константы
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
//|  Торговые алгоритмы                          | 
//+----------------------------------------------+
#include <TradeAlgorithms.mqh>
//+----------------------------------------------+
//| Входные параметры эксперта                   |
//+----------------------------------------------+
input double MM=0.1;               // Доля финансовых ресурсов от депозита в сделке, отрицательные значения - размер лота
input MarginMode MMMode=LOT;       // Способ определения размера лота
input int     StopLoss_=1000;      // Stop Loss в пунктах
input int     TakeProfit_=2000;    // Take Profit в пунктах
input int     Deviation_=10;       // Макс. отклонение цены в пунктах
input bool    BuyPosOpen=true;     // Разрешение для входа в лонг
input bool    SellPosOpen=true;    // Разрешение для входа в шорт
input bool    BuyPosClose=true;    // Разрешение для выхода из лонгов
input bool    SellPosClose=true;   // Разрешение для выхода из шортов
input AlgMode Mode=twist;          // Алгоритм для входа в рынок
input bool   TimeTrade=true;       // Разрешение для торговли по интервалам времени
input HOURS  StartH=ENUM_HOUR_0;   // Старт торговли (Часы)
input MINUTS StartM=ENUM_MINUT_0;  // Старт торговли (Минуты)
input HOURS  EndH=ENUM_HOUR_23;    // Окончание торговли (Часы)
input MINUTS EndM=ENUM_MINUT_59;   // Окончание торговли (Минуты)
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; // Таймфрейм индикатора

input Smooth_Method XMA_Method=MODE_EMA_;         // Метод усреднения
input uint XLength=20;                            // Глубина усреднения цены 
input uint XLength1=5;                            // Глубина первого усреднения
input uint XLength2=3;                            // Глубина второго усреднения
input uint XLength3=8;                            // Глубина усреднения сигнальной линии
input int XPhase=15;                              // Параметр сглаживания
//--- XPhase: для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- XPhase: для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;            // Ценовая константа
input uint SignalBar=1;                           // Номер бара для получения сигнала входа
//+----------------------------------------------+
//--- объявление целочисленных переменных для хранения периода графика в секундах 
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
//--- получение хендла индикатора BlauErgodicMDI
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\BlauErgodicMDI",XMA_Method,XLength,XLength1,XLength2,XLength3,XPhase,IPC);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора BlauErgodicMDI");
      return(INIT_FAILED);
     }
//--- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
   CXMA XMA;
//--- инициализация переменных начала отсчета данных
   min_rates_total+=GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,XLength1,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,XLength2,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,XLength3,XPhase);
   min_rates_total=int(min_rates_total+3+SignalBar);
//--- завершение инициализации
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(InpInd_Handle)<min_rates_total) return;
//--- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(InpInd_Timeframe)-1,Symbol(),InpInd_Timeframe);
//--- объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//--- определение сигналов для сделок
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //--- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;

      switch(Mode)
        {
         case breakdown: //пробой нуля гистограммой
           {
            double Hist[2];
            //--- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,2,SignalBar,2,Hist)<=0) {Recount=true; return;}
            //--- получим сигналы для покупки
            if(Hist[1]>0)
              {
               if(BuyPosOpen  &&  Hist[0]<=0) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
            //--- получим сигналы для продажи
            if(Hist[1]<0)
              {
               if(SellPosOpen && Hist[0]>=0) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;

         case twist://изменение направления
           {
            double Hist[3];
            //--- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,2,SignalBar,3,Hist)<=0) {Recount=true; return;}
            //--- получим сигналы для покупки
            if(Hist[1]<Hist[2])
              {
               if(BuyPosOpen && Hist[0]>Hist[1]) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
            //--- получим сигналы для продажи
            if(Hist[1]>Hist[2])
              {
               if(SellPosOpen && Hist[0]<Hist[1]) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;

         case cloudtwist: //изменение цвета сигнального облака
           {
            double Up[2],Dn[2];
            //--- копируем вновь появившиеся данные в массивы
            if(CopyBuffer(InpInd_Handle,0,SignalBar,2,Up)<=0) {Recount=true; return;}
            if(CopyBuffer(InpInd_Handle,1,SignalBar,2,Dn)<=0) {Recount=true; return;}
            //--- получим сигналы для покупки
            if(Up[1]>Dn[1])
              {
               if(BuyPosOpen   &&   Up[0]<=Dn[0]) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
            //--- получим сигналы для продажи
            if(Up[1]<Dn[1])
              {
               if(SellPosOpen && Up[0]>=Dn[0]) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
               DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
         break;
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
//--- закрываем лонг
   BuyPositionClose(BUY_Close,Symbol(),Deviation_);
//--- закрываем шорт   
   SellPositionClose(SELL_Close,Symbol(),Deviation_);
//--- открываем лонг
   BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,0,Deviation_,StopLoss_,TakeProfit_);
//--- открываем шорт
   SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,0,Deviation_,StopLoss_,TakeProfit_);
//---
  }
//+------------------------------------------------------------------+

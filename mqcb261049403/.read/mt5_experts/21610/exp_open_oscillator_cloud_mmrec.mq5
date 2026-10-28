//+------------------------------------------------------------------+
//|                              Exp_Open_Oscillator_Cloud_MMRec.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
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
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input uint    BuyMagic=777;       //Buy магик номер
input uint    SellMagic=888;      //Sell магик номер
input uint    BuyLossMMTriger=2;  //количество убыточных сделок в Buy направлении для уменьшения MM
input uint    SellLossMMTriger=2; //количество убыточных сделок в Sell направлении для уменьшения MM
input double  SmallMM_=0.01;      //Доля финансовых ресурсов от депозита в сделке при убытках
input double  MM=0.1;             //Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;    //Разрешение для выхода из лонгов
input bool   SellPosClose=true;   //Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H1; //таймфрейм индикатора Open_Oscillator_Cloud
input uint     InpPeriod=20;                      // Period
input Smooth_Method XMethod=MODE_SMA_;            // метод усреднения сглаживания 
input uint XLength=10;                            // глубина сглаживания                    
input int XPhase=15;                              // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint SignalBar=1;                           //номер бара для получения сигнала входа
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
//---- получение хендла индикатора Open_Oscillator_Cloud
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"Open_Oscillator_Cloud",InpPeriod,XMethod,XLength,XPhase,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Open_Oscillator_Cloud");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=int(InpPeriod);
   min_rates_total+=GetStartBars(XMethod,XLength,XPhase);
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
      double DnValue[2],UpValue[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,UpValue)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,1,SignalBar,2,DnValue)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(UpValue[1]>DnValue[1])
        {
         if(BuyPosOpen) if(UpValue[0]<=DnValue[0]) BUY_Open=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(UpValue[1]<DnValue[1])
        {
         if(SellPosOpen) if(UpValue[0]>=DnValue[0]) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }
//---- Совершение сделок
//---- Закрываем лонг
   BuyPositionClose_M(BUY_Close,Symbol(),Deviation_,BuyMagic);

//---- Закрываем шорт   
   SellPositionClose_M(SELL_Close,Symbol(),Deviation_,SellMagic);

   double mm;
//---- Открываем лонг
   if(BUY_Open)
     {
      mm=BuyTradeMMRecounter(BuyMagic,BuyLossMMTriger,SmallMM_,MM);
      BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,BuyMagic);
     }

//---- Открываем шорт
   if(SELL_Open)
     {
      mm=SellTradeMMRecounter(SellMagic,SellLossMMTriger,SmallMM_,MM);
      SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,SellMagic);
     }
//----
  }
//+------------------------------------------------------------------+

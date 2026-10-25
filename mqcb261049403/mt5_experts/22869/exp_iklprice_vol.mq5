//+------------------------------------------------------------------+
//|                                            Exp_i-KlPrice_Vol.mq5 |
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
input uint Magic1=555;            //Магик-номер для ордеров по обычному сигналу
input uint Magic2=777;            //Магик-номер для ордеров по сильному сигналу
input double MM1=0.1;             //Доля финансовых ресурсов от депозита в сделке (обычный сигнал)
input double MM2=0.2;             //Доля финансовых ресурсов от депозита в сделке (сильный сигнал)
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
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H8;   // таймфрейм индикатора i-KlPrice_Vol
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   //объём 
input Smooth_Method MA_Method1=MODE_SMA_;           //метод усреднения мувинга
input uint Length1=100;                             //глубина сглаживания мувинга                  
input int Phase1=15;                                //параметр усреднения мувинга,
//--- для JJMA изменяющийся в пределах -100..+100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей.
input Smooth_Method MA_Method2=MODE_JJMA;           //метод усреднения размера свеч
input uint Length2=20;                              //глубина усреднения  размера свеч 
input int Phase2=100;                               //параметр сглаживания  размера свеч,
//--- для JJMA изменяющийся в пределах -100..+100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей.
input uint Smooth=20;                               //период сглаживания индикатора
input Applied_price_ IPC=PRICE_CLOSE_;              //ценовая константа
input int                 HighLevel2=+150;          //уровень перекупленности 2
input int                 HighLevel1=+20;           //уровень перекупленности 1
input int                 LowLevel1=-20;            //уровень перепроданности 1
input int                 LowLevel2=-150;           //уровень перепроданности 2
input int Shift=0;                                  //сдвиг индикатора по горизонтали в барах
input uint SignalBar=1;                             // номер бара для получения сигнала входа
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
//---- получение хендла индикатора i-KlPrice_Vol
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"i-KlPrice_Vol",VolumeType,MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,Smooth,IPC,
                         HighLevel2,HighLevel1,LowLevel1,LowLevel2,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора i-KlPrice_Vol");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total+=GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total+=30;
   min_rates_total=int(3+min_rates_total+SignalBar);
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

//---- Объявление локальных переменных
   double Col[2];
//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open1=false,BUY_Open2=false,BUY_Close=false;
   static bool SELL_Open1=false,SELL_Open2=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;
//---- Определение сигналов для сделок
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open1=false;
      BUY_Open2=false;
      SELL_Open1=false;
      SELL_Open2=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,3,SignalBar,2,Col)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки 1
      if(Col[1]==4)
        {
         if(BuyPosOpen && Col[0]<4) BUY_Open1=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
      //---- Получим сигналы для покупки 2
      if(Col[1]==3)
        {
         if(BuyPosOpen && Col[0]<3) BUY_Open2=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи 1
      if(Col[1]==0)
        {
         if(SellPosOpen && Col[0]>0) SELL_Open1=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи 2
      if(Col[1]==1)
        {
         if(SellPosOpen && Col[0]>1) SELL_Open2=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }
//---- Совершение сделок
//---- Закрываем лонги
   if(BUY_Close)
     {
      bool sign1=true,sign2=true;
      BuyPositionClose_M(sign1,Symbol(),Deviation_,Magic1);
      BuyPositionClose_M(sign2,Symbol(),Deviation_,Magic2);
      if(!sign1 && !sign2) BUY_Close=false;
     }

//---- Закрываем шорты   
   if(SELL_Close)
     {
      bool sign1=true,sign2=true;
      SellPositionClose_M(sign1,Symbol(),Deviation_,Magic1);
      SellPositionClose_M(sign2,Symbol(),Deviation_,Magic2);
      if(!sign1 && !sign2) SELL_Close=false;
     }
//---- Открываем лонги
   BuyPositionOpen_M1(BUY_Open1,Symbol(),UpSignalTime,MM1,MMMode,Deviation_,StopLoss_,TakeProfit_,Magic1);
   BuyPositionOpen_M1(BUY_Open2,Symbol(),UpSignalTime,MM2,MMMode,Deviation_,StopLoss_,TakeProfit_,Magic2);

//---- Открываем шорты
   SellPositionOpen_M1(SELL_Open1,Symbol(),UpSignalTime,MM1,MMMode,Deviation_,StopLoss_,TakeProfit_,Magic1);
   SellPositionOpen_M1(SELL_Open2,Symbol(),UpSignalTime,MM2,MMMode,Deviation_,StopLoss_,TakeProfit_,Magic2);
//----
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                           Exp_UltraMFI_MMRec.mq5 |
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
input uint    BuyMagic=777;       //Buy магик номер
input uint    SellMagic=888;      //Sell магик номер
input uint    BuyTotalMMTriger=5; //количество последних сделок в Buy направлении для счёта стоплоссов
input uint    BuyLossMMTriger=3;  //количество убыточных сделок в Buy направлении для уменьшения MM
input uint    SellTotalMMTriger=5;//количество последних сделок в Sell направлении для счёта стоплоссов
input uint    SellLossMMTriger=3; //количество убыточных сделок в Sell направлении для уменьшения MM
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
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H1; //таймфрейм индикатора UltraMFI
input uint MFI_Period=13; //период индикатора MFI
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём индикатора MFI 
//----
input Smooth_Method W_Method=MODE_JJMA; //метод усреднения
input uint StartLength=3; //стартовый период усреднения                    
input int WPhase=100; //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//----  
input uint nStep=5; //шаг изменения периода
input uint StepsTotal=10; //количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA; //метод сглаживания
input uint SmoothLength=3; //глубина сглаживания                    
input int SmoothPhase=100; //параметр сглаживания,
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
//---- получение хендла индикатора UltraMFI
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"UltraMFI",MFI_Period,VolumeType,W_Method,StartLength,WPhase,
                           nStep,StepsTotal,SmoothMethod,SmoothLength,SmoothPhase,0,0,clrNONE,clrNONE,0,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraMFI");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=int(MFI_Period);
   min_rates_total+=GetStartBars(W_Method,StartLength+nStep*StepsTotal,WPhase)+1;
   min_rates_total+=GetStartBars(SmoothMethod,SmoothLength,SmoothPhase);
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
      double Up[2],Dn[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,Up)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,1,SignalBar,2,Dn)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Up[1]>Dn[1])
        {
         if(BuyPosOpen && Up[0]<Dn[0]) BUY_Open=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Up[1]<Dn[1])
        {
         if(SellPosOpen && Up[0]>Dn[0]) SELL_Open=true;
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
      mm=BuyTradeMMRecounterS(BuyMagic,BuyTotalMMTriger,BuyLossMMTriger,SmallMM_,MM);
      BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,BuyMagic);
     }

//---- Открываем шорт
   if(SELL_Open)
     {
      mm=SellTradeMMRecounterS(SellMagic,SellTotalMMTriger,SellLossMMTriger,SmallMM_,MM);
      SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,SellMagic);
     }
//----
  }
//+------------------------------------------------------------------+

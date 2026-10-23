//+------------------------------------------------------------------+
//|                                 Exp_MA_Rounding_Candle_MMRec.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.10"
//+---------------------------------------------------+
//  Торговые алгоритмы                                | 
//+---------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+---------------------------------------------------+
//|  Перечисление для вариантов расчёта лота          |
//+---------------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+---------------------------------------------------+
//| Описание класса CXMA                              |
//+---------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+---------------------------------------------------+
//| Объявление перечислений                           |
//+---------------------------------------------------+
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
//+---------------------------------------------------+
//| Входные параметры индикатора эксперта             |
//+---------------------------------------------------+
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
//+---------------------------------------------------+
//| Входные параметры индикатора MA_Rounding_Candle   |
//+---------------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H1; // таймфрейм индикатора MA_Rounding_Candle
input Smooth_Method XMA_Method=MODE_SMA_;         // Метод усреднения
input int XLength=12;                             // Глубина сглаживания
input int XPhase=15;                              // Параметр сглаживания
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input uint MaRound=50;                            // Коэффициент округления
input uint Gap=10;                                // размер неучитываемого гэпа в пунктах
input uint SignalBar=1;                           // номер бара для получения сигнала входа
//+---------------------------------------------------+
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
//---- получение хендла индикатора MA_Rounding_Candle
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"MA_Rounding_Candle",XMA_Method,XLength,XPhase,MaRound,Gap);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print("Не удалось получить хендл индикатора MA_Rounding_Candle");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(XMA_Method,XLength,XPhase)+2;
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

//---- Объявление локальных переменных
   double Col[2];
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

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,4,SignalBar,2,Col)<=0) {Recount=true; return;}
      
      //---- Получим сигналы для покупки
      if(Col[1]==2)
        {
         if(BuyPosOpen && Col[0]!=2) BUY_Open=true;
         if(SellPosClose)SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Col[1]==0)
        {
         if(SellPosOpen && Col[0]!=0) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }
//---- Совершение сделок
//---- Закрываем лонг по магик-номеру
   BuyPositionClose_M(BUY_Close,Symbol(),Deviation_,BuyMagic);

//---- Закрываем шорт  по магик-номеру  
   SellPositionClose_M(SELL_Close,Symbol(),Deviation_,SellMagic);

   double mm;if(BUY_Open)
//---- Открываем лонг по магик-номеру
   if(BUY_Open)
     {
      mm=BuyTradeMMRecounterS(BuyMagic,BuyTotalMMTriger,BuyLossMMTriger,SmallMM_,MM); // определяем объём лонга в зависимости от результатов предыдущих сделок
      BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,BuyMagic); // 
     }

//---- Открываем шорт
   if(SELL_Open)
     {
      mm=SellTradeMMRecounterS(SellMagic,SellTotalMMTriger,SellLossMMTriger,SmallMM_,MM); // определяем объём шорта в зависимости от результатов предыдущих сделок
      SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,SellMagic);
     }
//----
  }
//+------------------------------------------------------------------+

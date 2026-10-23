//+------------------------------------------------------------------+
//|                                         Exp_XPeriodCandle_X2.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+-------------------------------------------------+
//|  Описание класса CXMA                           |
//+-------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-------------------------------------------------+
//  Торговые алгоритмы                              | 
//+-------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+-------------------------------------------------+
//|  Перечисление для вариантов расчёта лота        |
//+-------------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+-------------------------------------------------+
//|  объявление перечислений                        |
//+-------------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA    // AMA
  }; */
//+-------------------------------------------------+
//| Входные параметры индикатора эксперта           |
//+-------------------------------------------------+
sinput string Trade="Управление торговлей";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ ==============+  
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input uint    StopLoss_=1000;      //стоплосс в пунктах
input uint    TakeProfit_=2000;    //тейкпрофит в пунктах
sinput string MustTrade="Разрешения торговли";    //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ ==============+  
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
//+-------------------------------------------------+
//| Входные параметры индикатора фильтра            |
//+-------------------------------------------------+
sinput string Filter="ПАРАМЕТРЫ МЕДЛЕННОГО ТРЕНДА";            //+============== ПАРАМЕТРЫ ТРЕНДА ==============+  
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H6;                     //1 Период графика для тренда
input uint Cperiod=5;                                          // Период расчёта свечей
input Smooth_Method MA_SMethod=MODE_JJMA;                      // Метод усреднения
input int MA_Length=3;                                         // глубина сглаживания                    
input int MA_Phase=100;                                        // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint SignalBar=1;                                        // номер бара для получения сигнала входа
input bool   BuyPosClose=true;                                 // Разрешение для выхода из лонгов по тренду
input bool   SellPosClose=true;                                // Разрешение для выхода из шортов по тренду
//+-------------------------------------------------+
//| Входные параметры индикатора входа              |
//+-------------------------------------------------+
sinput string Input="ПАРАМЕТРЫ ВХОДА";                         //+=============== ПАРАМЕТРЫ ВХОДА ===============+  
input ENUM_TIMEFRAMES TimeFrame_=PERIOD_M30;                   //2 Период графика для входа 
input uint Cperiod_=5;                                         // Период расчёта свечей
input Smooth_Method MA_SMethod_=MODE_JJMA;                     // Метод усреднения
input int MA_Length_=3;                                        // глубина сглаживания                    
input int MA_Phase_=100;                                       // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint SignalBar_=1;                                       // номер бара для получения сигнала входа
input bool   BuyPosClose_=false;                               // Разрешение для выхода из лонгов по сигналу
input bool   SellPosClose_=false;                              // Разрешение для выхода из шортов по сигналу
//+-------------------------------------------------+
int TimeShiftSec,TimeShiftSec_;
//---- Объявление целых переменных для хендлов индикаторов
int InpInd_Handle,InpInd_Handle_;
//---- объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_total_;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора XPeriodCandle
   InpInd_Handle=iCustom(Symbol(),TimeFrame,"XPeriodCandle",Cperiod,MA_SMethod,MA_Length,MA_Phase);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XPeriodCandle");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора XPeriodCandled _
   InpInd_Handle_=iCustom(Symbol(),TimeFrame_,"XPeriodCandle",Cperiod_,MA_SMethod_,MA_Length_,MA_Phase_);
   if(InpInd_Handle_==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XPeriodCandle _");
      return(INIT_FAILED);
     }

   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора XPeriodCandle_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"XPeriodCandle_HTF",TimeFrame,Cperiod,MA_SMethod,MA_Length,MA_Phase);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора XPeriodCandle_HTF");
         return(INIT_FAILED);
        }
      //---- получение хендла индикатора XPeriodCandle_HTF
      Ind_Handle=iCustom(Symbol(),Period(),"XPeriodCandle_HTF",TimeFrame_,Cperiod_,MA_SMethod_,MA_Length_,MA_Phase_);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора XPeriodCandle_HTF _");
         return(INIT_FAILED);
        }

     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(TimeFrame);
   TimeShiftSec_=PeriodSeconds(TimeFrame_);

//---- инициализация переменных начала отсчёта данных
   int min_rates_1=GetStartBars(MA_SMethod,MA_Length,MA_Phase);
   min_rates_total=min_rates_1+int(Cperiod_)+1;
   min_rates_total+=int(2+SignalBar);
//---- инициализация переменных начала отсчёта данных   
   min_rates_1=GetStartBars(MA_SMethod_,MA_Length_,MA_Phase_);
   min_rates_total=min_rates_1+int(Cperiod_)+1;
   min_rates_total_+=int(3+SignalBar_);
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
//---- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(TimeFrame)-1,Symbol(),TimeFrame);
   LoadHistory(TimeCurrent()-PeriodSeconds(TimeFrame_)-1,Symbol(),TimeFrame_);
//---- проверка количества баров на достаточность для расчёта
   int barscal=BarsCalculated(InpInd_Handle);
   int barscal_=BarsCalculated(InpInd_Handle_);
   if(barscal<min_rates_total || barscal_<min_rates_total_) return;

//---- Объявление статических переменных
   static bool Recount=true,Recount_=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static bool ReBUY_Open=false,ReSELL_Open=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB,NB_;
   static int Trend=0;  //направление тренда для фильтра сделок

//---- определяем текущий тренд на последнем закрытом баре
   if(NB.IsNewBar(Symbol(),TimeFrame) || Recount) // проверка на появление нового бара
     {
      Recount=false;
      Trend=0;
      //---- Объявление локальных переменных
      double Value[1];
      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(InpInd_Handle,4,SignalBar,1,Value)<=0) {Recount=true; return;}
      //---- определяем тренд
      if(Value[0]==2) Trend=-1;
      if(Value[0]==0) Trend=+1;
     }

//---- определяем сигнал для сделки на последнем закрытом баре
   if(NB_.IsNewBar(Symbol(),TimeFrame_) || Recount_) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      ReBUY_Open=false;
      ReSELL_Open=false;
      Recount_=false;
      UpSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrame_,SERIES_LASTBAR_DATE))+TimeShiftSec_;
      DnSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrame_,SERIES_LASTBAR_DATE))+TimeShiftSec_;

      //---- Объявление локальных переменных
      double Value[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle_,4,SignalBar,2,Value)<=0) {Recount_=true; return;}

      //---- определяем сигналы для сделок
      if(BuyPosClose_ && Value[1]==2) BUY_Close=true;
      if(SellPosClose_ && Value[1]==0) SELL_Close=true;
      if(Trend<0)
        {
         if(BuyPosClose) BUY_Close=true;
         if(SellPosOpen && Value[0]<2 && Value[1]==2) SELL_Open=true;
        }
      if(Trend>0)
        {
         if(SellPosClose) SELL_Close=true;
         if(BuyPosOpen && Value[0]>0 && Value[1]==0) BUY_Open=true;
        }
     }
//+-------------------------------------------------+
//| Совершение сделок                               |
//+-------------------------------------------------+
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

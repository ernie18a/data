//+------------------------------------------------------------------+
//|                                               Exp_X2MA_JJRSX.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
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
//|  Описание класса CXMA                           |
//+-------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-------------------------------------------------+
//|  объявление перечислений                        |
//+-------------------------------------------------+
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
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
//+-------------------------------------------------+
//|  объявление перечислений                        |
//+-------------------------------------------------+
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
//+-------------------------------------------------+
//| Входные параметры индикатора эксперта           |
//+-------------------------------------------------+
input string Trade="Управление торговлей";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ ==============+  
input double MM=0.1;               //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input uint    StopLoss_=1000;      //стоплосс в пунктах
input uint    TakeProfit_=2000;    //тейкпрофит в пунктах
input string MustTrade="Разрешения торговли";    //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ ==============+  
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
//+-------------------------------------------------+
//| Входные параметры индикатора фильтра            |
//+-------------------------------------------------+
input string Filter="ПАРАМЕТРЫ МЕДЛЕННОГО ТРЕНДА";    //+============== ПАРАМЕТРЫ ТРЕНДА ==============+  
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  //1 Период графика для тренда
input Smooth_Method MA_Method1=MODE_SMA_; //метод усреднения первого сглаживания 
input uint Length1=12; //глубина  первого сглаживания                    
input int Phase1=15; //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; //метод усреднения второго сглаживания 
input uint Length2=5; //глубина  второго сглаживания 
input int Phase2=15;  //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input uint SignalBar=1; //номер бара для получения сигнала входа
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов по тренду
input bool   SellPosClose=true;    //Разрешение для выхода из шортов по тренду
//+-------------------------------------------------+
//| Входные параметры индикатора входа              |
//+-------------------------------------------------+
input string Input="ПАРАМЕТРЫ ВХОДА";       //+=============== ПАРАМЕТРЫ ВХОДА ===============+  
input ENUM_TIMEFRAMES TimeFrame_=PERIOD_M30;  //2 Период графика для входа 
input uint JurXPeriod=8; //период JurX
input uint JMAPeriod=3;  //период JMA
input int JMAPhase=100;   //параметр усреднения JMA,
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input Applied_price_ IPC_=PRICE_CLOSE_; //ценовая константа
input uint SignalBar_=1;//номер бара для получения сигнала входа
input bool   BuyPosClose_=false;     //Разрешение для выхода из лонгов по сигналу
input bool   SellPosClose_=false;    //Разрешение для выхода из шортов по сигналу
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
//---- получение хендла индикатора ColorX2MA
   InpInd_Handle=iCustom(Symbol(),TimeFrame,"ColorX2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorX2MA");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора ColorJJRSX _
   InpInd_Handle_=iCustom(Symbol(),TimeFrame_,"ColorJJRSX",JurXPeriod,JMAPeriod,JMAPhase,IPC_,0,DRAW_COLOR_HISTOGRAM,100,0,-100);
   if(InpInd_Handle_==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorJJRSX _");
      return(INIT_FAILED);
     }

   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора ColorX2MA_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"ColorX2MA_HTF",TimeFrame,0,0,MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора ColorX2MA_HTF");
         return(INIT_FAILED);
        }
      //---- получение хендла индикатора ColorJJRSX_HTF
      Ind_Handle=iCustom(Symbol(),Period(),"ColorJJRSX_HTF",TimeFrame_,0,0,JurXPeriod,JMAPeriod,JMAPhase,IPC_,0,DRAW_COLOR_HISTOGRAM,100,0,-100);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора ColorJJRSX_HTF _");
         return(INIT_FAILED);
        }

     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(TimeFrame);
   TimeShiftSec_=PeriodSeconds(TimeFrame_);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total+=GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total+=int(2+SignalBar);
   min_rates_total_=2+30;
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
      double Signal[1];
      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(InpInd_Handle,1,SignalBar,1,Signal)<=0) {Recount=true; return;}
      //---- определяем тренд
      if(Signal[0]==2) Trend=-1;
      if(Signal[0]==1) Trend=+1;
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
      //Print("IsNewBar_");

      //---- Объявление локальных переменных
      double Signal[2];
      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(InpInd_Handle_,2,SignalBar_,2,Signal)<=0) {Recount_=true; return;}
      //---- определяем сигналы для сделок
      if(BuyPosClose_ && Signal[1]<2) BUY_Close=true;
      if(SellPosClose_ && Signal[1]>2) SELL_Close=true;
      if(Trend<0)
        {
         if(BuyPosClose) BUY_Close=true;
         if(SellPosOpen && Signal[1]<2 && Signal[0]>1) SELL_Open=true;
        }
      if(Trend>0)
        {
         if(SellPosClose) SELL_Close=true;
         if(BuyPosOpen && Signal[1]>2 && Signal[0]<3) BUY_Open=true;
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

//+------------------------------------------------------------------+
//|                                              Exp_XROC2_VG_X2.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
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
//|  объявление перечислений                        |
//+-------------------------------------------------+
enum ENUM_TYPE
  {
   MOM=1,  //MOM
   ROC,    //ROC
   ROCP,   //ROCP
   ROCR,   //ROC
   ROCR100 //ROCR100
  };
//+-------------------------------------------------+
//|  Описание класса CXMA                           |
//+-------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-------------------------------------------------+
//|  объявление перечислений                        |
//+-------------------------------------------------+
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
   MODE_AMA    //AMA
  }; */
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
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H6;  //1 Период графика для тренда

input uint ROCPeriod1=8;
input Smooth_Method MA_Method1=MODE_JJMA;          //метод усреднения первого индикатора 
input uint Length1=5;                              //глубина  первого сглаживания                    
input int Phase1=15;                               //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ROCPeriod2=14;
input Smooth_Method MA_Method2=MODE_JJMA;          //метод усреднения второго индикатора 
input uint Length2 = 5;                            //глубина  второго сглаживания 
input int Phase2=15;                               //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input ENUM_TYPE ROCType=MOM;

input uint SignalBar=1; //номер бара для получения сигнала входа
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов по тренду
input bool   SellPosClose=true;    //Разрешение для выхода из шортов по тренду
//+-------------------------------------------------+
//| Входные параметры индикатора входа              |
//+-------------------------------------------------+
input string Input="ПАРАМЕТРЫ ВХОДА";       //+=============== ПАРАМЕТРЫ ВХОДА ===============+  
input ENUM_TIMEFRAMES TimeFrame_=PERIOD_M30;  //2 Период графика для входа 

input uint ROCPeriod1_=8;
input Smooth_Method MA_Method1_=MODE_JJMA;          //метод усреднения первого индикатора 
input uint Length1_=5;                              //глубина  первого сглаживания                    
input int Phase1_=15;                               //параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint ROCPeriod2_=14;
input Smooth_Method MA_Method2_=MODE_JJMA;          //метод усреднения второго индикатора 
input uint Length2_ = 5;                            //глубина  второго сглаживания 
input int Phase2_=15;                               //параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input ENUM_TYPE ROCType_=MOM;

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
//---- получение хендла индикатора XROC2_VG
   InpInd_Handle=iCustom(Symbol(),TimeFrame,"XROC2_VG",ROCPeriod1,MA_Method1,Length1,Phase1,ROCPeriod2,MA_Method2,Length2,Phase2,ROCType,0,0.0,0.0,0.0,0.0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XROC2_VG");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора XROC2_VG _
   InpInd_Handle_=iCustom(Symbol(),TimeFrame_,"XROC2_VG",ROCPeriod1_,MA_Method1_,Length1_,Phase1_,ROCPeriod2_,MA_Method2_,Length2_,Phase2_,ROCType_,0,0.0,0.0,0.0,0.0);
   if(InpInd_Handle_==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XROC2 _");
      return(INIT_FAILED);
     }

   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора XROC2_VG_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"XROC2_VG_HTF",TimeFrame,ROCPeriod1,MA_Method1,Length1,Phase1,ROCPeriod2,MA_Method2,Length2,Phase2,ROCType,0,0.0,0.0,0.0,0.0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора XROC2_VG_HTF");
         return(INIT_FAILED);
        }
      //---- получение хендла индикатора XROC2_VG_HTF
      Ind_Handle=iCustom(Symbol(),Period(),"XROC2_HTF",TimeFrame_,ROCPeriod1_,MA_Method1_,Length1_,Phase1_,ROCPeriod2_,MA_Method2_,Length2_,Phase2_,ROCType_,0,0.0,0.0,0.0,0.0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора XROC2_VG_HTF _");
         return(INIT_FAILED);
        }

     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(TimeFrame);
   TimeShiftSec_=PeriodSeconds(TimeFrame_);

//---- инициализация переменных начала отсчёта данных
   int min_rates_1=GetStartBars(MA_Method1,Length1,Phase1);
   int min_rates_2=GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=int(MathMax(min_rates_1+ROCPeriod1,min_rates_2+ROCPeriod2));
   min_rates_total+=int(2+SignalBar);
//---- инициализация переменных начала отсчёта данных   
   int min_rates_1_=GetStartBars(MA_Method1_,Length1_,Phase1_);
   int min_rates_2_=GetStartBars(MA_Method2_,Length2_,Phase2_);
   min_rates_total=int(MathMax(min_rates_1_+ROCPeriod1_,min_rates_2_+ROCPeriod2_));
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
      double Up[1],Dn[1];
      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,MAIN_LINE,SignalBar,1,Up)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,SIGNAL_LINE,SignalBar,1,Dn)<=0) {Recount=true; return;}
      //---- определяем тренд
      if(Up[0]<Dn[0]) Trend=-1;
      if(Up[0]>Dn[0]) Trend=+1;
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
      double Up[2],Dn[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle_,MAIN_LINE,SignalBar,2,Up)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle_,SIGNAL_LINE,SignalBar,2,Dn)<=0) {Recount=true; return;}

      //---- определяем сигналы для сделок
      if(BuyPosClose_ && Up[1]<Dn[1]) BUY_Close=true;
      if(SellPosClose_ && Up[1]>Dn[1]) SELL_Close=true;
      if(Trend<0)
        {
         if(BuyPosClose) BUY_Close=true;
         if(SellPosOpen && Up[0]>=Dn[0] && Up[1]<Dn[1]) SELL_Open=true;
        }
      if(Trend>0)
        {
         if(SellPosClose) SELL_Close=true;
         if(BuyPosOpen && Up[0]<=Dn[0] && Up[1]>Dn[1]) BUY_Open=true;
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

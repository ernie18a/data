//+------------------------------------------------------------------+
//|                                            Exp_Zonal_Trading.mq5 |
//|                                 Copyright © 2016, Relaysim Comp. |  
//|                                               relaysim@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Relaysim Comp."
#property link      "relaysim@gmail.com"
#property version   "1.00"
#property description  "Советник использует в своей работе индикаторы AO и AC, предложенные Биллом Уильямсом."
#property description  "Советник покупает при зеленых AO и AC, продает при красных AO и AC. Выход из рынка осуществляется при изменении цвета хотя бы одного из индикаторов."
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
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов
input bool   SellPosClose=true;    //Разрешение для выхода из шортов
//+-------------------------------------------------+
//| Входные параметры индикатора фильтра            |
//+-------------------------------------------------+
input string Filter="ПАРАМЕТРЫ Awesome Oscillator";      //+============== ПАРАМЕТРЫ Awesome Oscillator ==============+  
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  //1 Период графика для тренда
input uint SignalBar=1; //номер бара для получения сигнала входа
//+-------------------------------------------------+
//| Входные параметры индикатора входа              |
//+-------------------------------------------------+
input string Filter_="ПАРАМЕТРЫ Accelerator Oscillator"; //+=============== ПАРАМЕТРЫ Accelerator Oscillator ===============+  
input ENUM_TIMEFRAMES TimeFrame_=PERIOD_H4;  //2 Период графика для входа 
input uint SignalBar_=1;//номер бара для получения сигнала входа
//+-------------------------------------------------+
int TimeShiftSec,TimeShiftSec_;
//---- Объявление целых переменных для хендлов индикаторов
int InpInd_Handle,InpInd_Handle_;
//---- объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_total_;
ENUM_TIMEFRAMES TimeFrameX;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора AO
   InpInd_Handle=iAO(Symbol(),TimeFrame);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AO");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора AC _
   InpInd_Handle_=iAC(Symbol(),TimeFrame_);
   if(InpInd_Handle_==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AC _");
      return(INIT_FAILED);
     }

   if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора AO_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"AO_HTF",TimeFrame,true);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AO_HTF");
         return(INIT_FAILED);
        }
      //---- получение хендла индикатора AC_HTF
      Ind_Handle=iCustom(Symbol(),Period(),"AC_HTF",TimeFrame_,true);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AC_HTF _");
         return(INIT_FAILED);
        }

     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(TimeFrame);
   TimeShiftSec_=PeriodSeconds(TimeFrame_);
   TimeFrameX=MathMin(TimeFrame,TimeFrame_);

//---- инициализация переменных начала отсчёта данных
   min_rates_total=33;
   min_rates_total+=int(2+SignalBar);
   min_rates_total_=37;
   min_rates_total_+=int(2+SignalBar_);
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
   static CIsNewBar NB,NB_,NBx;
   static int Trend=0,Trend_=0;  //направления тренда для фильтра сделок

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
      if(Signal[0]==1) Trend=-1;
      if(Signal[0]==0) Trend=+1;
     }

//---- определяем текущий тренд на последнем закрытом баре
   if(NB_.IsNewBar(Symbol(),TimeFrame_) || Recount) // проверка на появление нового бара
     {
      Recount=false;
      Trend_=0;
      //---- Объявление локальных переменных
      double Signal[1];
      //---- копируем вновь появившиеся данные в массив
      if(CopyBuffer(InpInd_Handle_,1,SignalBar_,1,Signal)<=0) {Recount=true; return;}
      //---- определяем тренд
      if(Signal[0]==1) Trend_=-1;
      if(Signal[0]==0) Trend_=+1;
     }

//---- определяем сигнал для сделки на последнем закрытом баре
   if(NBx.IsNewBar(Symbol(),TimeFrameX) || Recount_) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount_=false;
      UpSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrameX,SERIES_LASTBAR_DATE))+MathMin(TimeShiftSec,TimeShiftSec_);
      DnSignalTime=datetime(SeriesInfoInteger(Symbol(),TimeFrameX,SERIES_LASTBAR_DATE))+MathMin(TimeShiftSec,TimeShiftSec_);

      //---- определяем сигналы для выходов
      if(Trend<0 ||  Trend_<0) if(BuyPosClose) BUY_Close=true;
      if(Trend>0|| Trend_>0) if(SellPosClose) SELL_Close=true;

      //---- определяем сигналы для сделок
      if(Trend>0  &&  Trend_>0 && BuyPosOpen) BUY_Open=true;
      if(Trend<0 && Trend_<0 && SellPosOpen) SELL_Open=true;

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

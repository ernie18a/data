//+------------------------------------------------------------------+
//|                     Exp_ColorPEMA_Digit_Tm_Plus_MMRec_Duplex.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры эксперта для лонгов        |
//+----------------------------------------------+
input uint    L_Magic=777;          //L магик номер
input uint    L_TotalMMTriger=5;    //L количество последних сделок в Buy направлении для счёта стоплоссов
input uint    L_LossMMTriger=3;     //L количество убыточных сделок в Buy направлении для уменьшения MM
input double  L_SmallMM=0.01;       //L Доля финансовых ресурсов от депозита в сделке при убытках
input double  L_MM=0.1;             //L Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode L_MMMode=LOT;      //L способ определения размера лота
input uint    L_StopLoss_=1000;     //L стоплосс в пунктах
input uint    L_TakeProfit_=2000;   //L тейкпрофит в пунктах
input uint    L_Deviation_=10;      //L макс. отклонение цены в пунктах
input bool    L_PosOpen=true;       //L Разрешение для входа в лонг
input bool    L_PosClose=true;      //L Разрешение для выхода из лонгов
input bool    L_TimeTrade=true;     //L Разрешение для выхода из позиций по времени
input uint    L_nTime=1920;         //L Время удержания открытой позиции в минутах
//+----------------------------------------------+
//| Входные параметры индикатора для лонгов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES L_InpInd_Timeframe=PERIOD_H4;     //L таймфрейм индикатора
input double          L_EmaLength=50.01;                //L глубина сглаживания                   
input Applied_price_  L_IPC=PRICE_CLOSE_;               //L ценовая константа
input uint            L_Digit=2;                        //L количество разрядов округления
input uint            L_SignalBar=1;                    //L номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для шортов        | 
//+----------------------------------------------+
input uint    S_Magic=555;          //S магик номер
input uint    S_TotalMMTriger=5;    //S количество последних сделок в Sell направлении для счёта стоплоссов
input uint    S_LossMMTriger=3;     //S количество убыточных сделок в Sell направлении для уменьшения MM
input double  S_SmallMM=0.01;       //S Доля финансовых ресурсов от депозита в сделке при убытках
input double  S_MM=0.1;             //S Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode S_MMMode=LOT;      //S способ определения размера лота
input uint    S_StopLoss_=1000;     //S стоплосс в пунктах
input uint    S_TakeProfit_=2000;   //S тейкпрофит в пунктах
input uint    S_Deviation_=10;      //S макс. отклонение цены в пунктах
input bool    S_PosOpen=true;       //S Разрешение для входа в шорт
input bool    S_PosClose=true;      //S Разрешение для выхода из шортов
input bool    S_TimeTrade=true;     //S Разрешение для выхода из позиций по времени
input uint    S_nTime=1920;         //S Время удержания открытой позиции в минутах
//+----------------------------------------------+
//| Входные параметры индикатора для шортов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES S_InpInd_Timeframe=PERIOD_H4;     //S таймфрейм индикатора
input double          S_EmaLength=50.01;                //S глубина сглаживания                   
input Applied_price_  S_IPC=PRICE_CLOSE_;               //S ценовая константа
input uint            S_Digit=2;                        //S количество разрядов округления
input uint            S_SignalBar=1;                    //S номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
int L_TimeShiftSec,S_TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int L_InpInd_Handle,S_InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int L_min_rates_total,S_min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора ColorPEMA_Digit L
   L_InpInd_Handle=iCustom(Symbol(),L_InpInd_Timeframe,"ColorPEMA_Digit",L_EmaLength,L_IPC,0,0,L_Digit,"",false);

   if(L_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorPEMA_Digit L");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора ColorPEMA_Digit S
   S_InpInd_Handle=iCustom(Symbol(),S_InpInd_Timeframe,"ColorPEMA_Digit",S_EmaLength,S_IPC,0,0,S_Digit,"",false);

   if(S_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorPEMA_Digit S");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   L_TimeShiftSec=PeriodSeconds(L_InpInd_Timeframe);
   S_TimeShiftSec=PeriodSeconds(S_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   L_min_rates_total=9+1;
   L_min_rates_total+=int(3+L_SignalBar);
//---- Инициализация переменных начала отсчёта данных
   S_min_rates_total=9+1;
   S_min_rates_total+=int(3+S_SignalBar);
//----
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
   if(BarsCalculated(L_InpInd_Handle)<L_min_rates_total) return;
   if(BarsCalculated(S_InpInd_Handle)<S_min_rates_total) return;

//---- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(L_InpInd_Timeframe)-1,Symbol(),L_InpInd_Timeframe);
   LoadHistory(TimeCurrent()-PeriodSeconds(S_InpInd_Timeframe)-1,Symbol(),S_InpInd_Timeframe);

//---- Объявление статических переменных
   static bool L_Recount=true,S_Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar L_NB,S_NB;

//+----------------------------------------------+
//| Определение сигналов для длинных позиций     |
//+----------------------------------------------+
   if(!L_SignalBar || L_NB.IsNewBar(Symbol(),L_InpInd_Timeframe) || L_Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      BUY_Close=false;
      L_Recount=false;
      //---- Объявление локальных переменных
      double Col[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(L_InpInd_Handle,1,L_SignalBar,2,Col)<=0) {L_Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Col[1]==2)
        {
         if(L_PosOpen) if(Col[0]<2) BUY_Open=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),L_InpInd_Timeframe,SERIES_LASTBAR_DATE))+L_TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Col[1]==0)
        {
         if(L_PosClose) BUY_Close=true;
        }
     }
//+----------------------------------------------+
//| Определение сигналов для коротких позиций    |
//+----------------------------------------------+
   if(!S_SignalBar || S_NB.IsNewBar(Symbol(),S_InpInd_Timeframe) || S_Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      SELL_Open=false;
      SELL_Close=false;
      S_Recount=false;
      //---- Объявление локальных переменных
      double Col[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(S_InpInd_Handle,1,S_SignalBar,2,Col)<=0) {S_Recount=true; return;}

      //---- Получим сигналы для продажи
      if(Col[1]==0)
        {
         if(S_PosOpen) if(Col[0]>0) SELL_Open=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),S_InpInd_Timeframe,SERIES_LASTBAR_DATE))+S_TimeShiftSec;
        }

      //---- Получим сигналы для покупки
      if(Col[1]==2)
        {
         if(S_PosClose) SELL_Close=true;
        }
     }
//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- закрываем длинные позиции вне торгового интервала
   if(L_TimeTrade && PositionsTotal())
     {
      //---- закрываем все открытые позиции по текущему символу по истечении времени
      int total=PositionsTotal();
      for(int pos=total-1; pos>=0; pos--)
        {
         string symbol=PositionGetSymbol(pos);
         if(symbol!=Symbol()) continue;
         if(!PositionSelect(symbol)) continue;
         if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_BUY) continue;
         if(PositionGetInteger(POSITION_MAGIC)!=L_Magic) continue;
         if(TimeCurrent()-PositionGetInteger(POSITION_TIME)<=60*L_nTime) continue;
         bool Signal=true;
         BuyPositionClose_M(Signal,symbol,L_Deviation_,L_Magic);
        }
     }
//---- закрываем короткие позиции вне торгового интервала
   if(S_TimeTrade && PositionsTotal())
     {
      //---- закрываем все открытые позиции по текущему символу по истечении времени
      int total=PositionsTotal();
      for(int pos=total-1; pos>=0; pos--)
        {
         string symbol=PositionGetSymbol(pos);
         if(symbol!=Symbol()) continue;
         if(!PositionSelect(symbol)) continue;
         if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL) continue;
         if(PositionGetInteger(POSITION_MAGIC)!=S_Magic) continue;
         if(TimeCurrent()-PositionGetInteger(POSITION_TIME)<=60*S_nTime) continue;
         bool Signal=true;
         SellPositionClose_M(Signal,symbol,S_Deviation_,S_Magic);
        }
     }

//---- Закрываем лонг
   BuyPositionClose_M(BUY_Close,Symbol(),L_Deviation_,L_Magic);

//---- Закрываем шорт   
   SellPositionClose_M(SELL_Close,Symbol(),S_Deviation_,S_Magic);

   double mm;
//---- Открываем лонг по магик-номеру
   if(BUY_Open)
     {
      mm=BuyTradeMMRecounterS(L_Magic,L_TotalMMTriger,L_LossMMTriger,L_SmallMM,L_MM); // определяем объём лонга в зависимости от результатов предыдущих сделок
      BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,mm,L_MMMode,L_Deviation_,L_StopLoss_,L_TakeProfit_,L_Magic);
     }

//---- Открываем шорт по магик-номеру
   if(SELL_Open)
     {
      mm=SellTradeMMRecounterS(S_Magic,S_TotalMMTriger,S_LossMMTriger,S_SmallMM,S_MM); // определяем объём щорта в зависимости от результатов предыдущих сделок
      SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,mm,S_MMMode,S_Deviation_,S_StopLoss_,S_TakeProfit_,S_Magic);
     }
//----
  }
//+------------------------------------------------------------------+

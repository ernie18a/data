//+------------------------------------------------------------------+
//|                    Exp_BrainTrend2_AbsolutelyNoLagLwma_MMRec.mq5 |
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
   PRICE_DEMARK_         //Dema
  };
//+----------------------------------------------+
//| Входные параметры эксперта для A             |
//+----------------------------------------------+
sinput string A_Trade="Управление торговлей для BrainTrend2_V2";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ  для BrainTrend2_V2 ==============+  
input uint    A_BuyMagic=777;       //A Buy магик номер
input uint    A_SellMagic=888;      //A Sell магик номер
input uint    A_BuyLossMMTriger=2;  //A количество убыточных сделок в Buy направлении для уменьшения MM
input uint    A_SellLossMMTriger=2; //A количество убыточных сделок в Sell направлении для уменьшения MM
input double  A_SmallMM=0.01;       //A Доля финансовых ресурсов от депозита в сделке при убытках
input double  A_MM=0.1;             //A Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode A_MMMode=LOT;      //A способ определения размера лота
input uint    A_StopLoss_=2000;     //A стоплосс в пунктах
input uint    A_TakeProfit_=5000;   //A тейкпрофит в пунктах
input uint    A_Deviation_=10;      //A макс. отклонение цены в пунктах
sinput string A_MustTrade="Разрешения торговли для BrainTrend2_V2"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ  для BrainTrend2_V2 ==============+  
input bool    A_BuyPosOpen=true;    //A Разрешение для входа в лонг
input bool    A_SellPosOpen=true;   //A Разрешение для входа в шорт
input bool    A_SellPosClose=true;  //A Разрешение для выхода из лонгов
input bool    A_BuyPosClose=true;   //A Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для A           |
//+----------------------------------------------+
sinput string A_Input="Параметры входа для BrainTrend2_V2";         //+=============== ПАРАМЕТРЫ ВХОДА  для BrainTrend2_V2 ===============+  
input ENUM_TIMEFRAMES A_InpInd_Timeframe=PERIOD_H6; //A таймфрейм индикатора
input uint A_ATR_Period=7;
input uint A_SignalBar=1;                           //A номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для B             |
//+----------------------------------------------+
sinput string B_Trade="Управление торговлей для AbsolutelyNoLagLwma";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ для AbsolutelyNoLagLwma ==============+  
input uint    B_BuyMagic=555;       //B Buy магик номер
input uint    B_SellMagic=444;      //B Sell магик номер
input uint    B_BuyLossMMTriger=2;  //B количество убыточных сделок в Buy направлении для уменьшения MM
input uint    B_SellLossMMTriger=2; //B количество убыточных сделок в Sell направлении для уменьшения MM
input double  B_SmallMM=0.01;       //B Доля финансовых ресурсов от депозита в сделке при убытках
input double  B_MM=0.1;             //B Доля финансовых ресурсов от депозита в сделке
input MarginMode B_MMMode=LOT;      //B способ определения размера лота
input uint    B_StopLoss_=2000;     //B стоплосс в пунктах
input uint    B_TakeProfit_=5000;   //B тейкпрофит в пунктах
input uint    B_Deviation_=10;      //B макс. отклонение цены в пунктах
sinput string B_MustTrade="Разрешения торговли для AbsolutelyNoLagLwma"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ для AbsolutelyNoLagLwma ==============+  
input bool    B_BuyPosOpen=true;    //B Разрешение для входа в лонг
input bool    B_SellPosOpen=true;   //B Разрешение для входа в шорт
input bool    B_SellPosClose=true;  //B Разрешение для выхода из лонгов
input bool    B_BuyPosClose=true;   //B Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для B           |
//+----------------------------------------------+
sinput string B_Input="Параметры входа для AbsolutelyNoLagLwma";         //+=============== ПАРАМЕТРЫ ВХОДА для AbsolutelyNoLagLwma ===============+  
input ENUM_TIMEFRAMES B_InpInd_Timeframe=PERIOD_H6; //B таймфрейм индикатора
input uint B_Length=7;                              //B глубина сглаживания                   
input Applied_price_ B_IPC=PRICE_CLOSE_;            //B ценовая константа
input uint B_SignalBar=1;                           //B номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
int A_TimeShiftSec,B_TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int A_InpInd_Handle,B_InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int A_min_rates_total,B_min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора BrainTrend2_V2 A
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      A_InpInd_Handle=iCustom(Symbol(),A_InpInd_Timeframe,"BrainTrend2_V2",A_ATR_Period,0,false,0,false,false);
      if(A_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора BrainTrend2_V2 A");
         return(INIT_FAILED);
        }
     }
//---- получение хендла индикатора AbsolutelyNoLagLwma B
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      B_InpInd_Handle=iCustom(Symbol(),B_InpInd_Timeframe,"AbsolutelyNoLagLwma",B_Length,B_IPC,0,0);
      if(B_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma B");
         return(INIT_FAILED);
        }
     }

//---- инициализация переменной для хранения периода графика в секундах  
   A_TimeShiftSec=PeriodSeconds(A_InpInd_Timeframe);
   B_TimeShiftSec=PeriodSeconds(B_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   A_min_rates_total=int(A_ATR_Period)+2;
   A_min_rates_total+=int(3+A_SignalBar);
   B_min_rates_total=int(B_Length*2.0);
   B_min_rates_total+=int(3+B_SignalBar);
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
//+-------------------------------------------------------+
//| Блок управления для BrainTrend2_V2                    |
//+-------------------------------------------------------+
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      //---- проверка количества баров на достаточность для расчёта
      if(BarsCalculated(A_InpInd_Handle)<A_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(A_InpInd_Timeframe)-1,Symbol(),A_InpInd_Timeframe);
      //---- Объявление статических переменных  для BrainTrend2_V2
      static bool A_Recount=true;
      static bool A_BUY_Open=false,A_BUY_Close=false;
      static bool A_SELL_Open=false,A_SELL_Close=false;
      static datetime A_UpSignalTime,A_DnSignalTime;
      static CIsNewBar A_NB;

      //+----------------------------------------------+
      //| Определение сигналов для BrainTrend2_V2      |
      //+----------------------------------------------+
      if(!A_SignalBar || A_NB.IsNewBar(Symbol(),A_InpInd_Timeframe) || A_Recount) // проверка на появление нового бара
        {
         //---- обнулим торговые сигналы
         A_BUY_Open=false;
         A_BUY_Close=false;
         A_SELL_Open=false;
         A_SELL_Close=false;
         A_Recount=false;
         //---- Объявление локальных переменных
         double Value[2];

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(A_InpInd_Handle,4,A_SignalBar,2,Value)<=0) {A_Recount=true; return;}

         //---- Получим сигналы для покупки
         if(Value[1]<2)
           {
            if(A_BuyPosOpen && Value[0]>1) A_BUY_Open=true;
            A_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
            A_SELL_Close=true;
           }

         //---- Получим сигналы для продажи
         if(Value[1]>2)
           {
            if(A_SellPosOpen && Value[0]<3) A_SELL_Open=true;
            A_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
            A_BUY_Close=true;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для BrainTrend2_V2         |
      //+----------------------------------------------+
      //---- Закрываем лонг
      BuyPositionClose_M(A_BUY_Close,Symbol(),A_Deviation_,A_BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(A_SELL_Close,Symbol(),A_Deviation_,A_SellMagic);

      double MM;
      //---- Открываем лонг
      if(A_BuyMagic)
        {
         MM=BuyTradeMMRecounter(A_BuyMagic,A_BuyLossMMTriger,A_SmallMM,A_MM);
         BuyPositionOpen_M1(A_BUY_Open,Symbol(),A_UpSignalTime,MM,A_MMMode,A_Deviation_,A_StopLoss_,A_TakeProfit_,A_BuyMagic);
        }

      //---- Открываем шорт
      if(A_SellMagic)
        {
         MM=SellTradeMMRecounter(A_SellMagic,A_SellLossMMTriger,A_SmallMM,A_MM);
         SellPositionOpen_M1(A_SELL_Open,Symbol(),A_DnSignalTime,MM,A_MMMode,A_Deviation_,A_StopLoss_,A_TakeProfit_,A_SellMagic);
        }
     }
//+-------------------------------------------------------+
//| Блок управления для AbsolutelyNoLagLwma               |
//+-------------------------------------------------------+
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      if(BarsCalculated(B_InpInd_Handle)<B_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(B_InpInd_Timeframe)-1,Symbol(),B_InpInd_Timeframe);
      //---- Объявление статических переменных  для BrainTrend2_V2
      static bool B_Recount=true;
      static bool B_BUY_Open=false,B_BUY_Close=false;
      static bool B_SELL_Open=false,B_SELL_Close=false;
      static datetime B_UpSignalTime,B_DnSignalTime;
      static CIsNewBar B_NB;
      //+----------------------------------------------+
      //| Определение сигналов для AbsolutelyNoLagLwma |
      //+----------------------------------------------+
      if(!B_SignalBar || B_NB.IsNewBar(Symbol(),B_InpInd_Timeframe) || B_Recount) // проверка на появление нового бара
        {
         //---- обнулим торговые сигналы
         B_BUY_Open=false;
         B_BUY_Close=false;
         B_SELL_Open=false;
         B_SELL_Close=false;
         B_Recount=false;
         //---- Объявление локальных переменных
         double Value[2];

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(B_InpInd_Handle,1,B_SignalBar,2,Value)<=0) {B_Recount=true; return;}

         //---- Получим сигналы для покупки
         if(Value[1]==2)
           {
            if(B_BuyPosOpen && Value[0]!=2) B_BUY_Open=true;
            if(B_SellPosClose) B_SELL_Close=true;
            B_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),B_InpInd_Timeframe,SERIES_LASTBAR_DATE))+B_TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Value[1]==0)
           {
            if(B_SellPosOpen && Value[0]!=0) B_SELL_Open=true;
            if(B_BuyPosClose) B_BUY_Close=true;
            B_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),B_InpInd_Timeframe,SERIES_LASTBAR_DATE))+B_TimeShiftSec;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для AbsolutelyNoLagLwma    |
      //+----------------------------------------------+
      //---- Закрываем лонг
      BuyPositionClose_M(B_BUY_Close,Symbol(),B_Deviation_,B_BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(B_SELL_Close,Symbol(),B_Deviation_,B_SellMagic);

      double MM;
      //---- Открываем лонг
      if(B_BUY_Open)
        {
         MM=BuyTradeMMRecounter(B_BuyMagic,B_BuyLossMMTriger,B_SmallMM,B_MM);
         BuyPositionOpen_M1(B_BUY_Open,Symbol(),B_UpSignalTime,MM,B_MMMode,B_Deviation_,B_StopLoss_,B_TakeProfit_,B_BuyMagic);
        }

      //---- Открываем шорт
      if(B_SELL_Open)
        {
         MM=SellTradeMMRecounter(B_SellMagic,B_SellLossMMTriger,B_SmallMM,B_MM);
         SellPositionOpen_M1(B_SELL_Open,Symbol(),B_DnSignalTime,MM,B_MMMode,B_Deviation_,B_StopLoss_,B_TakeProfit_,B_SellMagic);
        }
      //----
     }
//----
  }
//+------------------------------------------------------------------+

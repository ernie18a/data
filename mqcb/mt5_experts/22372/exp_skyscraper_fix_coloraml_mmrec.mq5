//+------------------------------------------------------------------+
//|                            Exp_Skyscraper_Fix_ColorAML_MMRec.mq5 |
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
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Method
  {
   MODE_HighLow,  //High/Low
   MODE_Close     //Close
  };
//+----------------------------------------------+
//| Входные параметры эксперта для A             |
//+----------------------------------------------+
sinput string A_Trade="Управление торговлей для Skyscraper_Fix";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ  для Skyscraper_Fix ==============+  
input uint    A_BuyMagic=777;       //A Buy магик номер
input uint    A_SellMagic=888;      //A Sell магик номер
input uint    A_BuyLossMMTriger=2;  //A количество убыточных сделок в Buy направлении для уменьшения MM
input uint    A_SellLossMMTriger=2; //A количество убыточных сделок в Sell направлении для уменьшения MM
input double  A_SmallMM=0.01;       //A Доля финансовых ресурсов от депозита в сделке при убытках
input double  A_MM=0.1;             //A Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode A_MMMode=LOT;      //A способ определения размера лота
input uint    A_StopLoss_=1000;     //A стоплосс в пунктах
input uint    A_TakeProfit_=2000;   //A тейкпрофит в пунктах
input uint    A_Deviation_=10;      //A макс. отклонение цены в пунктах
sinput string A_MustTrade="Разрешения торговли для Skyscraper_Fix"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ  для Skyscraper_Fix ==============+  
input bool    A_BuyPosOpen=true;    //A Разрешение для входа в лонг
input bool    A_SellPosOpen=true;   //A Разрешение для входа в шорт
input bool    A_SellPosClose=true;  //A Разрешение для выхода из лонгов
input bool    A_BuyPosClose=true;   //A Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для A           |
//+----------------------------------------------+
sinput string A_Input="Параметры входа для Skyscraper_Fix";         //+=============== ПАРАМЕТРЫ ВХОДА  для Skyscraper_Fix ===============+  
input ENUM_TIMEFRAMES A_InpInd_Timeframe=PERIOD_H4; //A таймфрейм индикатора
input uint    A_Length=10;                          //A Период ATR
input double  A_Kv=0.9;                             //A Фактор чувствительности индикатора
input double  A_Percentage=0;                       //A Приближение средней линии к линиям экстремумов
input Method  A_HighLow=MODE_HighLow;               //A Расчёт индикатора по High/Low или Close
input uint A_SignalBar=1;                           //A номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для B             |
//+----------------------------------------------+
sinput string B_Trade="Управление торговлей для ColorAML";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ для ColorAML ==============+  
input uint    B_BuyMagic=555;       //B Buy магик номер
input uint    B_SellMagic=444;      //B Sell магик номер
input uint    B_BuyLossMMTriger=2;  //B количество убыточных сделок в Buy направлении для уменьшения MM
input uint    B_SellLossMMTriger=2; //B количество убыточных сделок в Sell направлении для уменьшения MM
input double  B_SmallMM=0.01;       //B Доля финансовых ресурсов от депозита в сделке при убытках
input double  B_MM=0.1;             //B Доля финансовых ресурсов от депозита в сделке
input MarginMode B_MMMode=LOT;      //B способ определения размера лота
input uint    B_StopLoss_=1000;     //B стоплосс в пунктах
input uint    B_TakeProfit_=2000;   //B тейкпрофит в пунктах
input uint    B_Deviation_=10;      //B макс. отклонение цены в пунктах
sinput string B_MustTrade="Разрешения торговли для ColorAML"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ для ColorAML ==============+  
input bool    B_BuyPosOpen=true;    //B Разрешение для входа в лонг
input bool    B_SellPosOpen=true;   //B Разрешение для входа в шорт
input bool    B_SellPosClose=true;  //B Разрешение для выхода из лонгов
input bool    B_BuyPosClose=true;   //B Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для B           |
//+----------------------------------------------+
sinput string B_Input="Параметры входа для ColorAML";         //+=============== ПАРАМЕТРЫ ВХОДА для ColorAML ===============+  
input ENUM_TIMEFRAMES B_InpInd_Timeframe=PERIOD_H4; //B таймфрейм индикатора
input int B_Fractal=6;                              //B число фракталов
input int B_Lag=7;                                  //B задержка
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
//---- получение хендла индикатора Skyscraper_Fix A
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      A_InpInd_Handle=iCustom(Symbol(),A_InpInd_Timeframe,"Skyscraper_Fix",A_Length,A_Kv,A_Percentage,A_HighLow);
      if(A_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора Skyscraper_Fix A");
         return(INIT_FAILED);
        }
     }
//---- получение хендла индикатора ColorAML B
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      B_InpInd_Handle=iCustom(Symbol(),B_InpInd_Timeframe,"ColorAML",B_Fractal,B_Lag,0);
      if(B_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора ColorAML B");
         return(INIT_FAILED);
        }
     }

//---- инициализация переменной для хранения периода графика в секундах  
   A_TimeShiftSec=PeriodSeconds(A_InpInd_Timeframe);
   B_TimeShiftSec=PeriodSeconds(B_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   int ATR_Period=15;
   A_min_rates_total=ATR_Period+int(A_Length+1);
   A_min_rates_total+=int(3+A_SignalBar);
   B_min_rates_total=int(B_Fractal+B_Lag);
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
//| Блок управления для Skyscraper_Fix                      |
//+-------------------------------------------------------+
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      //---- проверка количества баров на достаточность для расчёта
      if(BarsCalculated(A_InpInd_Handle)<A_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(A_InpInd_Timeframe)-1,Symbol(),A_InpInd_Timeframe);
      //---- Объявление статических переменных  для Skyscraper_Fix
      static bool A_Recount=true;
      static bool A_BUY_Open=false,A_BUY_Close=false;
      static bool A_SELL_Open=false,A_SELL_Close=false;
      static datetime A_UpSignalTime,A_DnSignalTime;
      static CIsNewBar A_NB;

      //+----------------------------------------------+
      //| Определение сигналов для Skyscraper_Fix        |
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
         if(CopyBuffer(A_InpInd_Handle,5,A_SignalBar,2,Value)<=0) {A_Recount=true; return;}

         //---- Получим сигналы для покупки
         if(Value[1]==0)
           {
            if(A_BuyPosOpen && Value[0]!=0) A_BUY_Open=true;
            A_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
            A_SELL_Close=true;
           }

         //---- Получим сигналы для продажи
         if(Value[1]==1)
           {
            if(A_SellPosOpen && Value[0]!=1) A_SELL_Open=true;
            A_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
            A_BUY_Close=true;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для Skyscraper_Fix           |
      //+----------------------------------------------+
      //---- Закрываем лонг
      BuyPositionClose_M(A_BUY_Close,Symbol(),A_Deviation_,A_BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(A_SELL_Close,Symbol(),A_Deviation_,A_SellMagic);

      //---- Открываем лонг
      double MM;
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
//| Блок управления для ColorAML                          |
//+-------------------------------------------------------+
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      if(BarsCalculated(B_InpInd_Handle)<B_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(B_InpInd_Timeframe)-1,Symbol(),B_InpInd_Timeframe);
      //---- Объявление статических переменных  для Skyscraper_Fix
      static bool B_Recount=true;
      static bool B_BUY_Open=false,B_BUY_Close=false;
      static bool B_SELL_Open=false,B_SELL_Close=false;
      static datetime B_UpSignalTime,B_DnSignalTime;
      static CIsNewBar B_NB;
      //+----------------------------------------------+
      //| Определение сигналов для ColorAML            |
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
      //| Совершение сделок для ColorAML               |
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
     }
//----
  }
//+------------------------------------------------------------------+

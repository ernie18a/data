//+------------------------------------------------------------------+
//|                      Exp_AbsolutelyNoLagLwma_Digit_NN3_MMRec.mq5 |
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
sinput string A_Trade="Управление торговлей для AbsolutelyNoLagLwma_Digit 1";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ  для AbsolutelyNoLagLwma_Digit 1 ==============+  
input uint    A_BuyMagic=777;       //A Buy магик номер
input uint    A_SellMagic=888;      //A Sell магик номер
input uint    A_BuyLossMMTriger=2;  //A количество убыточных сделок в Buy направлении для уменьшения MM
input uint    A_SellLossMMTriger=2; //A количество убыточных сделок в Sell направлении для уменьшения MM
input double  A_SmallMM=0.01;       //A Доля финансовых ресурсов от депозита в сделке при убытках
input double  A_MM=0.1;             //A Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode A_MMMode=LOT;      //A способ определения размера лота
input uint    A_StopLoss_=3000;     //A стоплосс в пунктах
input uint    A_TakeProfit_=10000;   //A тейкпрофит в пунктах
input uint    A_Deviation_=10;      //A макс. отклонение цены в пунктах
sinput string A_MustTrade="Разрешения торговли для AbsolutelyNoLagLwma_Digit 1"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ  AbsolutelyNoLagLwma_Digit 1 ==============+  
input bool    A_BuyPosOpen=true;    //A Разрешение для входа в лонг
input bool    A_SellPosOpen=true;   //A Разрешение для входа в шорт
input bool    A_SellPosClose=true;  //A Разрешение для выхода из лонгов
input bool    A_BuyPosClose=true;   //A Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для A           |
//+----------------------------------------------+
sinput string A_Input="Параметры входа для AbsolutelyNoLagLwma_Digit 1";         //+=============== ПАРАМЕТРЫ ВХОДА для AbsolutelyNoLagLwma_Digit 1 ===============+  
input ENUM_TIMEFRAMES A_InpInd_Timeframe=PERIOD_H12;//A таймфрейм индикатора
input int A_Length=5;                               //A глубина JMA сглаживания                   
input Applied_price_ A_IPC=PRICE_CLOSE_;            //A ценовая константа
input uint A_Digit=2;                               //A количество разрядов округления
input uint A_SignalBar=1;                           //A номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для B             |
//+----------------------------------------------+
sinput string B_Trade="Управление торговлей для AbsolutelyNoLagLwma_Digit 2";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ  для AbsolutelyNoLagLwma_Digit 2 ==============+  
input uint    B_BuyMagic=555;       //B Buy магик номер
input uint    B_SellMagic=444;      //B Sell магик номер
input uint    B_BuyLossMMTriger=2;  //B количество убыточных сделок в Buy направлении для уменьшения MM
input uint    B_SellLossMMTriger=2; //B количество убыточных сделок в Sell направлении для уменьшения MM
input double  B_SmallMM=0.01;       //B Доля финансовых ресурсов от депозита в сделке при убытках
input double  B_MM=0.1;             //B Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode B_MMMode=LOT;      //B способ определения размера лота
input uint    B_StopLoss_=2000;     //B стоплосс в пунктах
input uint    B_TakeProfit_=6000;   //B тейкпрофит в пунктах
input uint    B_Deviation_=10;      //B макс. отклонение цены в пунктах
sinput string B_MustTrade="Разрешения торговли для AbsolutelyNoLagLwma_Digit 2"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ  AbsolutelyNoLagLwma_Digit 2 ==============+  
input bool    B_BuyPosOpen=true;    //B Разрешение для входа в лонг
input bool    B_SellPosOpen=true;   //B Разрешение для входа в шорт
input bool    B_SellPosClose=true;  //B Разрешение для выхода из лонгов
input bool    B_BuyPosClose=true;   //B Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для B           |
//+----------------------------------------------+
sinput string B_Input="Параметры входа для AbsolutelyNoLagLwma_Digit 2";         //+=============== ПАРАМЕТРЫ ВХОДА для AbsolutelyNoLagLwma_Digit 2 ===============+  
input ENUM_TIMEFRAMES B_InpInd_Timeframe=PERIOD_H4; //B таймфрейм индикатора
input int B_Length=5;                               //B глубина JMA сглаживания                   
input Applied_price_ B_IPC=PRICE_CLOSE_;            //B ценовая константа
input uint B_Digit=2;                               //B количество разрядов округления
input uint B_SignalBar=1;                           //B номер бара для получения сигнала входа

//+----------------------------------------------+
//| Входные параметры эксперта для C             |
//+----------------------------------------------+
sinput string C_Trade="Управление торговлей для AbsolutelyNoLagLwma_Digit 3";    //+============== УПРАВЛЕНИЕ ТОРГОВЛЕЙ  для AbsolutelyNoLagLwma_Digit 3 ==============+  
input uint    C_BuyMagic=222;       //C Buy магик номер
input uint    C_SellMagic=111;      //C Sell магик номер
input uint    C_BuyLossMMTriger=3;  //C количество убыточных сделок в Buy направлении для уменьшения MM
input uint    C_SellLossMMTriger=3; //C количество убыточных сделок в Sell направлении для уменьшения MM
input double  C_SmallMM=0.01;       //C Доля финансовых ресурсов от депозита в сделке при убытках
input double  C_MM=0.1;             //C Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode C_MMMode=LOT;      //C способ определения размера лота
input uint    C_StopLoss_=1000;     //C стоплосс в пунктах
input uint    C_TakeProfit_=3000;   //C тейкпрофит в пунктах
input uint    C_Deviation_=10;      //C макс. отклонение цены в пунктах
sinput string C_MustTrade="Разрешения торговли для AbsolutelyNoLagLwma_Digit 3"; //+============== РАЗРЕШЕНИЯ ТОРГОВЛИ  AbsolutelyNoLagLwma_Digit 3 ==============+  
input bool    C_BuyPosOpen=true;    //C Разрешение для входа в лонг
input bool    C_SellPosOpen=true;   //C Разрешение для входа в шорт
input bool    C_SellPosClose=true;  //C Разрешение для выхода из лонгов
input bool    C_BuyPosClose=true;   //C Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора для C           |
//+----------------------------------------------+
sinput string C_Input="Параметры входа для AbsolutelyNoLagLwma_Digit 3";         //+=============== ПАРАМЕТРЫ ВХОДА для AbsolutelyNoLagLwma_Digit 3 ===============+  
input ENUM_TIMEFRAMES C_InpInd_Timeframe=PERIOD_H2; //C таймфрейм индикатора
input int C_Length=5;                               //C глубина JMA сглаживания                   
input Applied_price_ C_IPC=PRICE_CLOSE_;            //C ценовая константа
input uint C_Digit=1;                               //C количество разрядов округления
input uint C_SignalBar=1;                           //C номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
int A_TimeShiftSec,B_TimeShiftSec,C_TimeShiftSec;
//---- Объявление целых переменных для хендлов индикаторов
int A_InpInd_Handle,B_InpInd_Handle,C_InpInd_Handle;
//---- объявление целых переменных начала отсчета данных
int A_min_rates_total,B_min_rates_total,C_min_rates_total;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- получение хендла индикатора AbsolutelyNoLagLwma_Digit A
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      A_InpInd_Handle=iCustom(Symbol(),A_InpInd_Timeframe,"AbsolutelyNoLagLwma_Digit","AbsolutelyNoLagLwma_Digit_A",A_Length,A_IPC,0,0,A_Digit,false,clrNONE,clrNONE,clrNONE);
      if(A_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma_Digit A");
         return(INIT_FAILED);
        }
     }
//---- инициализация переменной для хранения периода графика в секундах  
   A_TimeShiftSec=PeriodSeconds(A_InpInd_Timeframe);
//---- Инициализация переменных начала отсчёта данных  
   A_min_rates_total=int(A_Length*2.0)+1;
   A_min_rates_total+=int(3+A_SignalBar);


//---- получение хендла индикатора AbsolutelyNoLagLwma_Digit B
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      B_InpInd_Handle=iCustom(Symbol(),B_InpInd_Timeframe,"AbsolutelyNoLagLwma_Digit","AbsolutelyNoLagLwma_Digit_B",B_Length,B_IPC,0,0,B_Digit,false,clrNONE,clrNONE,clrNONE);
      if(B_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma_Digit B");
         return(INIT_FAILED);
        }
     }
//---- инициализация переменной для хранения периода графика в секундах  
   B_TimeShiftSec=PeriodSeconds(B_InpInd_Timeframe);
//---- Инициализация переменных начала отсчёта данных  
   B_min_rates_total=int(B_Length*2.0)+1;
   B_min_rates_total+=int(3+B_SignalBar);

//---- получение хендла индикатора AbsolutelyNoLagLwma_Digit C
   if(C_BuyPosOpen || C_SellPosOpen)
     {
      C_InpInd_Handle=iCustom(Symbol(),C_InpInd_Timeframe,"AbsolutelyNoLagLwma_Digit","AbsolutelyNoLagLwma_Digit_C",C_Length,C_IPC,0,0,C_Digit,false,clrNONE,clrNONE,clrNONE);
      if(C_InpInd_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma_Digit C");
         return(INIT_FAILED);
        }
     }
//---- инициализация переменной для хранения периода графика в секундах  
   C_TimeShiftSec=PeriodSeconds(C_InpInd_Timeframe);
//---- Инициализация переменных начала отсчёта данных  
   C_min_rates_total=int(C_Length*2.0)+1;;
   C_min_rates_total+=int(3+C_SignalBar);

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
//| Блок управления для AbsolutelyNoLagLwma_индикатора A  |
//+-------------------------------------------------------+
   if(A_BuyPosOpen || A_SellPosOpen)
     {
      if(BarsCalculated(A_InpInd_Handle)<A_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(A_InpInd_Timeframe)-1,Symbol(),A_InpInd_Timeframe);
      
      //---- Объявление статических переменных  для SilverTrend
      static bool A_Recount=true;
      static bool A_BUY_Open=false,A_BUY_Close=false;
      static bool A_SELL_Open=false,A_SELL_Close=false;
      static datetime A_UpSignalTime,A_DnSignalTime;
      static CIsNewBar A_NB;
      //+----------------------------------------------+
      //| Определение сигналов для индикатора A        |
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
         if(CopyBuffer(A_InpInd_Handle,1,A_SignalBar,2,Value)<=0) {A_Recount=true; return;}

         //---- Получим сигналы для покупки
         if(Value[1]==2)
           {
            if(A_BuyPosOpen && Value[0]<2) A_BUY_Open=true;
            if(A_SellPosClose) A_SELL_Close=true;
            A_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Value[1]==0)
           {
            if(A_SellPosOpen && Value[0]>0) A_SELL_Open=true;
            if(A_BuyPosClose) A_BUY_Close=true;
            A_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),A_InpInd_Timeframe,SERIES_LASTBAR_DATE))+A_TimeShiftSec;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для индикатора A           |
      //+----------------------------------------------+
      //---- Закрываем лонг
      BuyPositionClose_M(A_BUY_Close,Symbol(),A_Deviation_,A_BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(A_SELL_Close,Symbol(),A_Deviation_,A_SellMagic);

      double MM;
      //---- Открываем лонг
      if(A_BUY_Open)
        {
         MM=BuyTradeMMRecounter(A_BuyMagic,A_BuyLossMMTriger,A_SmallMM,A_MM);
         BuyPositionOpen_M1(A_BUY_Open,Symbol(),A_UpSignalTime,MM,A_MMMode,A_Deviation_,A_StopLoss_,A_TakeProfit_,A_BuyMagic);
        }

      //---- Открываем шорт
      if(A_SELL_Open)
        {
         MM=SellTradeMMRecounter(A_SellMagic,A_SellLossMMTriger,A_SmallMM,A_MM);
         SellPositionOpen_M1(A_SELL_Open,Symbol(),A_DnSignalTime,MM,A_MMMode,A_Deviation_,A_StopLoss_,A_TakeProfit_,A_SellMagic);
        }
      //----
     }

//+-------------------------------------------------------+
//| Блок управления для индикатора B                      |
//+-------------------------------------------------------+
   if(B_BuyPosOpen || B_SellPosOpen)
     {
      if(BarsCalculated(B_InpInd_Handle)<B_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(B_InpInd_Timeframe)-1,Symbol(),B_InpInd_Timeframe);
      
      //---- Объявление статических переменных  для SilverTrend
      static bool B_Recount=true;
      static bool B_BUY_Open=false,B_BUY_Close=false;
      static bool B_SELL_Open=false,B_SELL_Close=false;
      static datetime B_UpSignalTime,B_DnSignalTime;
      static CIsNewBar B_NB;
      //+----------------------------------------------+
      //| Определение сигналов для индикатора B        |
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
            if(B_BuyPosOpen && Value[0]<2) B_BUY_Open=true;
            if(B_SellPosClose) B_SELL_Close=true;
            B_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),B_InpInd_Timeframe,SERIES_LASTBAR_DATE))+B_TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Value[1]==0)
           {
            if(B_SellPosOpen && Value[0]>0) B_SELL_Open=true;
            if(B_BuyPosClose) B_BUY_Close=true;
            B_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),B_InpInd_Timeframe,SERIES_LASTBAR_DATE))+B_TimeShiftSec;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для для индикатора B       |
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
//+-------------------------------------------------------+
//| Блок управления для для индикатора C                  |
//+-------------------------------------------------------+
   if(C_BuyPosOpen || C_SellPosOpen)
     {
      if(BarsCalculated(C_InpInd_Handle)<C_min_rates_total) return;
      LoadHistory(TimeCurrent()-PeriodSeconds(C_InpInd_Timeframe)-1,Symbol(),C_InpInd_Timeframe);
      
      //---- Объявление статических переменных  для SilverTrend
      static bool C_Recount=true;
      static bool C_BUY_Open=false,C_BUY_Close=false;
      static bool C_SELL_Open=false,C_SELL_Close=false;
      static datetime C_UpSignalTime,C_DnSignalTime;
      static CIsNewBar C_NB;
      //+----------------------------------------------+
      //| Определение сигналов для для индикатора C    |
      //+----------------------------------------------+
      if(!C_SignalBar || C_NB.IsNewBar(Symbol(),C_InpInd_Timeframe) || C_Recount) // проверка на появление нового бара
        {
         //---- обнулим торговые сигналы
         C_BUY_Open=false;
         C_BUY_Close=false;
         C_SELL_Open=false;
         C_SELL_Close=false;
         C_Recount=false;
         //---- Объявление локальных переменных
         double Value[2];

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(C_InpInd_Handle,1,C_SignalBar,2,Value)<=0) {C_Recount=true; return;}

         //---- Получим сигналы для покупки
         if(Value[1]==2)
           {
            if(C_BuyPosOpen && Value[0]<2) C_BUY_Open=true;
            if(C_SellPosClose) C_SELL_Close=true;
            C_UpSignalTime=datetime(SeriesInfoInteger(Symbol(),C_InpInd_Timeframe,SERIES_LASTBAR_DATE))+C_TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Value[1]==0)
           {
            if(C_SellPosOpen && Value[0]>0) C_SELL_Open=true;
            if(C_BuyPosClose) C_BUY_Close=true;
            C_DnSignalTime=datetime(SeriesInfoInteger(Symbol(),C_InpInd_Timeframe,SERIES_LASTBAR_DATE))+C_TimeShiftSec;
           }
        }
      //+----------------------------------------------+
      //| Совершение сделок для индикатора C           |
      //+----------------------------------------------+
      //---- Закрываем лонг
      BuyPositionClose_M(C_BUY_Close,Symbol(),C_Deviation_,C_BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(C_SELL_Close,Symbol(),C_Deviation_,C_SellMagic);

      double MM;
      //---- Открываем лонг
      if(C_BUY_Open)
        {
         MM=BuyTradeMMRecounter(C_BuyMagic,C_BuyLossMMTriger,C_SmallMM,C_MM);
         BuyPositionOpen_M1(C_BUY_Open,Symbol(),C_UpSignalTime,MM,C_MMMode,C_Deviation_,C_StopLoss_,C_TakeProfit_,C_BuyMagic);
        }

      //---- Открываем шорт
      if(C_SELL_Open)
        {
         MM=SellTradeMMRecounter(C_SellMagic,C_SellLossMMTriger,C_SmallMM,C_MM);
         SellPositionOpen_M1(C_SELL_Open,Symbol(),C_DnSignalTime,MM,C_MMMode,C_Deviation_,C_StopLoss_,C_TakeProfit_,C_SellMagic);
        }
      //----
     }
  }
//+------------------------------------------------------------------+

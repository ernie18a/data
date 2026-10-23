//+------------------------------------------------------------------+
//|                                         Exp_UltraFatl_Duplex.mq5 |
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
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      // Тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры эксперта для лонгов        |
//+----------------------------------------------+
input uint    L_Magic=777;          //L магик номер
input double  L_MM=0.1;             //L Доля финансовых ресурсов от депозита в сделке
input MarginMode L_MMMode=LOT;      //L способ определения размера лота
input uint    L_StopLoss_=1000;     //L стоплосс в пунктах
input uint    L_TakeProfit_=2000;   //L тейкпрофит в пунктах
input uint    L_Deviation_=10;      //L макс. отклонение цены в пунктах
input bool    L_PosOpen=true;       //L Разрешение для входа в лонг
input bool    L_PosClose=true;      //L Разрешение для выхода из лонгов
//+----------------------------------------------+
//| Входные параметры индикатора для лонгов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES L_InpInd_Timeframe=PERIOD_H12;    //L таймфрейм индикатора
//----
input ENUM_APPLIED_PRICE L_Applied_price=PRICE_CLOSE;   //L использованная цена
//----
input Smooth_Method L_W_Method=MODE_JJMA;               //L Метод усреднения
input uint L_StartLength=3;                             //L Стартовый период усреднения                    
input int  L_WPhase=100;                                //L Параметр усреднения
//----  
input uint L_Step=5;                                    //L Шаг изменения периода
input uint L_StepsTotal=10;                             //L Количество изменений периода
//----
input Smooth_Method L_SmoothMethod=MODE_JJMA;           //L Метод сглаживания
input int  L_SmoothLength=3;                            //L Глубина сглаживания
input int  L_SmoothPhase=100;                           //L Параметр сглаживания
input Applied_price_ L_IPC=PRICE_CLOSE_;                //L ценовая константа
//----                                                
input uint L_SignalBar=1;                               //L номер бара для получения сигнала входа
//+----------------------------------------------+
//| Входные параметры эксперта для шортов        | 
//+----------------------------------------------+
input uint    S_Magic=555;          //S магик номер
input double  S_MM=0.1;             //S Доля финансовых ресурсов от депозита в сделке
input MarginMode S_MMMode=LOT;      //S способ определения размера лота
input uint    S_StopLoss_=1000;     //S стоплосс в пунктах
input uint    S_TakeProfit_=2000;   //S тейкпрофит в пунктах
input uint    S_Deviation_=10;      //S макс. отклонение цены в пунктах
input bool    S_PosOpen=true;       //S Разрешение для входа в лонг
input bool    S_PosClose=true;      //S Разрешение для выхода из лонгов
//+----------------------------------------------+
//| Входные параметры индикатора для шортов      |
//+----------------------------------------------+
input ENUM_TIMEFRAMES S_InpInd_Timeframe=PERIOD_H12;    //S таймфрейм индикатора
//----
input ENUM_APPLIED_PRICE S_Applied_price=PRICE_CLOSE;   //S использованная цена
//----
input Smooth_Method S_W_Method=MODE_JJMA;               //S Метод усреднения
input uint S_StartLength=3;                             //S Стартовый период усреднения                    
input int  S_WPhase=100;                                //S Параметр усреднения
//----  
input uint S_Step=5;                                    //S Шаг изменения периода
input uint S_StepsTotal=10;                             //S Количество изменений периода
//----
input Smooth_Method S_SmoothMethod=MODE_JJMA;           //S Метод сглаживания
input int  S_SmoothLength=3;                            //S Глубина сглаживания
input int  S_SmoothPhase=100;                           //S Параметр сглаживания
input Applied_price_ S_IPC=PRICE_CLOSE_;                //S ценовая константа
//----                                                
input uint S_SignalBar=1;                               //S номер бара для получения сигнала входа
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
//---- получение хендла индикатора UltraFatl L
   L_InpInd_Handle=iCustom(Symbol(),L_InpInd_Timeframe,"UltraFatl",L_Applied_price,L_W_Method,L_StartLength,L_WPhase,
                            L_Step,L_StepsTotal,L_SmoothMethod,L_SmoothLength,L_SmoothPhase,L_IPC,0,0,clrNONE,clrNONE,1,1);

   if(L_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraFatl L");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора UltraFatl S
   S_InpInd_Handle=iCustom(Symbol(),S_InpInd_Timeframe,"UltraFatl",S_Applied_price,S_W_Method,S_StartLength,S_WPhase,
                            S_Step,S_StepsTotal,S_SmoothMethod,S_SmoothLength,S_SmoothPhase,S_IPC,0,0,clrNONE,clrNONE,1,1);

   if(S_InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraFatl S");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   L_TimeShiftSec=PeriodSeconds(L_InpInd_Timeframe);
   S_TimeShiftSec=PeriodSeconds(S_InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   L_min_rates_total=40+GetStartBars(L_W_Method,L_StartLength+L_Step*L_StepsTotal,L_WPhase)+1;
   L_min_rates_total+=GetStartBars(L_SmoothMethod,L_SmoothLength,L_SmoothPhase);
   L_min_rates_total+=int(3+L_SignalBar);
//---- Инициализация переменных начала отсчёта данных
   S_min_rates_total=40+GetStartBars(S_W_Method,S_StartLength+S_Step*S_StepsTotal,S_WPhase)+1;
   S_min_rates_total+=GetStartBars(S_SmoothMethod,S_SmoothLength,S_SmoothPhase);
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
      double UpValue[2],DnValue[2];     
      
      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(L_InpInd_Handle,1,L_SignalBar,2,DnValue)<=0) {L_Recount=true; return;}
      if(CopyBuffer(L_InpInd_Handle,0,L_SignalBar,2,UpValue)<=0) {L_Recount=true; return;}

      //---- Получим сигналы для покупки
      if(UpValue[1]>DnValue[1])
        {
         if(L_PosOpen) if(UpValue[0]<=DnValue[0]) BUY_Open=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),L_InpInd_Timeframe,SERIES_LASTBAR_DATE))+L_TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(DnValue[1]>UpValue[1])
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
      double UpValue[2],DnValue[2];  
      
     //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(S_InpInd_Handle,1,S_SignalBar,2,DnValue)<=0) {S_Recount=true; return;}
      if(CopyBuffer(S_InpInd_Handle,0,S_SignalBar,2,UpValue)<=0) {S_Recount=true; return;}  

      //---- Получим сигналы для продажи
      if(UpValue[1]<DnValue[1])
        {
         if(S_PosOpen) if(UpValue[0]>=DnValue[0]) SELL_Open=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),S_InpInd_Timeframe,SERIES_LASTBAR_DATE))+S_TimeShiftSec;
        }

      //---- Получим сигналы для покупки
      if(DnValue[1]<UpValue[1])
        {
         if(S_PosClose) SELL_Close=true;
        }
     }

//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- Закрываем лонг
   BuyPositionClose_M(BUY_Close,Symbol(),L_Deviation_,L_Magic);

//---- Закрываем шорт   
   SellPositionClose_M(SELL_Close,Symbol(),S_Deviation_,S_Magic);

//---- Открываем лонг
   BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,L_MM,L_MMMode,L_Deviation_,L_StopLoss_,L_TakeProfit_,L_Magic);

//---- Открываем шорт
   SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,S_MM,S_MMMode,S_Deviation_,S_StopLoss_,S_TakeProfit_,S_Magic);
//----
  }
//+------------------------------------------------------------------+

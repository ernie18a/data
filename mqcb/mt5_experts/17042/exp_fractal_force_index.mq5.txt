//+------------------------------------------------------------------+
//|                                      Exp_Fractal_Force_Index.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
#property description  "Самый простой советник по фрактальному Force Index."
#property description  "Продаем при пересечении нулевого уровня индикатора сверху вниз, покупаем при пересечении этого уровня снизу вверх."
#property description  "Сигнал на совершение сделки формируется в момент закрытия бара если произошло пересечение нулевого уровня." 
//---- Включение индикаторов в код эксперта как ресурсов
#resource "\\Indicators\\Fractal_Force_Index.ex5"
#resource "\\Indicators\\Fractal_Force_Index_HTF.ex5"
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
//|  Перечисление для определения тренда         |
//+----------------------------------------------+
enum TrendMode
  {
   DIRECT=0,         //по сигналам
   AGAINST           //против сигналов
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
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
//+----------------------------------------------+
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input double MM=0.1;              //Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;     //Разрешение для выхода из лонгов
input bool   SellPosClose=true;    //Разрешение для выхода из шортов
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; //таймфрейм индикатора
input TrendMode            Trend=DIRECT;          //торговля
//----
input uint e_period=30;                           //глубина  усреднения                    
input uint normal_speed=30;
input ENUM_MA_METHOD MA_Method=MODE_SMA;          //метод усреднения
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       //ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // объём 
input int                 HighLevel=0;            // уровень перезакупа
input int                 LowLevel=0;             // уровень перепроданности
//----
input uint                 SignalBar=1;           // номер бара для получения сигнала входа
//+----------------------------------------------+
//---- Объявление целых переменных для хранения периода графика в секундах 
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
//---- получение хендла индикатора Fractal_Force_Index
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"::Indicators\\Fractal_Force_Index",e_period,normal_speed,MA_Method,IPC,VolumeType,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Fractal_Force_Index");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора Fractal_Force_Index_HTF для визуализации в тестере стратегий   
 if(MQLInfoInteger(MQL_VISUAL_MODE))
     {
      //---- получение хендла индикатора Fractal_Force_Index_HTF
      int Ind_Handle=iCustom(Symbol(),Period(),"::Indicators\\Fractal_Force_Index_HTF",InpInd_Timeframe,e_period,normal_speed,MA_Method,IPC,VolumeType,0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора Fractal_Force_Index_HTF");
         return(INIT_FAILED);
        }
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(e_period,normal_speed));
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

//---- Объявление статических переменных
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;

//+----------------------------------------------+
//| Определение сигналов для сделок              |
//+----------------------------------------------+
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //---- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      Recount=false;
      //---- Объявление локальных переменных
      double Fractal_Force_Index[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,Fractal_Force_Index)<=0) {Recount=true; return;}

      if(Trend==DIRECT)
        {
         //---- Получим сигналы для покупки
         if(Fractal_Force_Index[1]>HighLevel)
           {
            if(Fractal_Force_Index[0]<=HighLevel)
              {
               if(BuyPosOpen) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
              }

            UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Fractal_Force_Index[1]<LowLevel)
           {
            if(Fractal_Force_Index[0]>=LowLevel)
              {
               if(SellPosOpen) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
              }
            DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }
        }

      if(Trend==AGAINST)
        {
         //---- Получим сигналы для покупки
         if(Fractal_Force_Index[1]>HighLevel)
           {
            if(Fractal_Force_Index[0]<=HighLevel)
              {
               if(SellPosOpen) SELL_Open=true;
               if(BuyPosClose) BUY_Close=true;
              }
            DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
           }

         //---- Получим сигналы для продажи
         if(Fractal_Force_Index[1]<LowLevel)
           {
            if(Fractal_Force_Index[0]>=LowLevel)
              {
               if(BuyPosOpen) BUY_Open=true;
               if(SellPosClose) SELL_Close=true;
               UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
              }
           }
        }
     }

//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
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

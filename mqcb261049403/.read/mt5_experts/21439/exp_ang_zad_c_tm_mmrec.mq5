//+------------------------------------------------------------------+
//|                                       Exp_Ang_Zad_C_Tm_MMRec.mq5 |
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
//| Входные параметры индикатора эксперта        |
//+----------------------------------------------+
input uint    BuyMagic=777;       //Buy магик номер
input uint    SellMagic=888;      //Sell магик номер
input uint    BuyLossMMTriger=2;  //количество убыточных сделок в Buy направлении для уменьшения MM
input uint    SellLossMMTriger=2; //количество убыточных сделок в Sell направлении для уменьшения MM
input double  Small_MM=0.01;      //Доля финансовых ресурсов от депозита в сделке при убытках
input double  MM=0.1;             //Доля финансовых ресурсов от депозита в сделке при нормальной торговле
input MarginMode MMMode=LOT;      //способ определения размера лота
input int    StopLoss_=1000;      //стоплосс в пунктах
input int    TakeProfit_=2000;    //тейкпрофит в пунктах
input int    Deviation_=10;       //макс. отклонение цены в пунктах
input bool   BuyPosOpen=true;     //Разрешение для входа в лонг
input bool   SellPosOpen=true;    //Разрешение для входа в шорт
input bool   BuyPosClose=true;    //Разрешение для выхода из лонгов
input bool   SellPosClose=true;   //Разрешение для выхода из шортов
input bool   TimeTrade=true;      //Разрешение для торговли по интервалам времени
input HOURS  StartH=ENUM_HOUR_0;  //Старт торговли (Часы)
input MINUTS StartM=ENUM_MINUT_0; //Старт торговли (Минуты)
input HOURS  EndH=ENUM_HOUR_23;   //Окончание торговли (Часы)
input MINUTS EndM=ENUM_MINUT_59;  //Окончание торговли (Минуты) 
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H12;//таймфрейм индикатора
input double ki=4.000001;                         //Коэффициент усреднения индикатора 
input Applied_price_ IPC=PRICE_CLOSE_;            //ценовая константа
input uint SignalBar=1;//номер бара для получения сигнала входа
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
//---- получение хендла индикатора Ang_Zad_C
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"Ang_Zad_C",ki,IPC,0,0);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Ang_Zad_C");
      return(INIT_FAILED);
     }

//---- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2+1;
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
      double Up[2],Dn[2];

      //---- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,Up)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,1,SignalBar,2,Dn)<=0) {Recount=true; return;}

      //---- Получим сигналы для покупки
      if(Up[1]>Dn[1])
        {
         if(BuyPosOpen && Up[0]<=Dn[0]) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получим сигналы для продажи
      if(Up[1]<Dn[1])
        {
         if(SellPosOpen && Up[0]>=Dn[0]) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
     }
//+----------------------------------------------+
//| Определение сигналов для торговли в периоде  |
//+----------------------------------------------+ 
//---- Объявление переменной для разрешения торговли
   bool Trade=false;
   if(TimeTrade)
     {
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);

      if(StartH<EndH)
        {
         if(tm.hour==StartH && tm.min>=StartM) Trade=true;
         if(tm.hour>StartH && tm.hour<EndH) Trade=true;
         if(tm.hour>StartH && tm.hour==EndH && tm.min<EndM) Trade=true;
        }

      if(StartH==EndH)
        {
         if(tm.hour==StartH && tm.min>=StartM && tm.min<EndM) Trade=true;
        }

      if(StartH>EndH)
        {
         if(tm.hour>=StartH && tm.min>=StartM) Trade=true;
         if(tm.hour<EndH) Trade=true;
         if(tm.hour==EndH && tm.min<EndM) Trade=true;
        }
     }
//+----------------------------------------------+
//| Совершение сделок                            |
//+----------------------------------------------+
//---- закрываем позиции вне торгового интервала
   if(TimeTrade && !Trade && PositionsTotal())
     {
      //---- закрываем все открытые позиции по текущему символу
      int total=PositionsTotal();
      for(int pos=total-1; pos>=0; pos--)
        {
         string symbol=PositionGetSymbol(pos);
         if(!PositionSelect(symbol)) continue;
         if(symbol!=Symbol()) continue;
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            if(PositionGetInteger(POSITION_MAGIC)==BuyMagic)
              {
               bool Signal=true;
               BuyPositionClose(Signal,symbol,Deviation_);
              }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            if(PositionGetInteger(POSITION_MAGIC)==SellMagic)
              {
               bool Signal=true;
               SellPositionClose(Signal,symbol,Deviation_);
              }
        }
     }
//---- Закрываем лонг
      BuyPositionClose_M(BUY_Close,Symbol(),Deviation_,BuyMagic);

      //---- Закрываем шорт   
      SellPositionClose_M(SELL_Close,Symbol(),Deviation_,SellMagic);

//---- Открываем лонг
   double mm;
   if(BUY_Open)
     {
      mm=BuyTradeMMRecounter(BuyMagic,BuyLossMMTriger,Small_MM,MM);
      if((TimeTrade && Trade) || !TimeTrade) BuyPositionOpen_M1(BUY_Open,Symbol(),UpSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,BuyMagic);
     }

//---- Открываем шорт
   if(SELL_Open)
     {
      mm=SellTradeMMRecounter(SellMagic,SellLossMMTriger,Small_MM,MM);
      if((TimeTrade && Trade) || !TimeTrade) SellPositionOpen_M1(SELL_Open,Symbol(),DnSignalTime,mm,MMMode,Deviation_,StopLoss_,TakeProfit_,SellMagic);
     }
//----
  }
//+------------------------------------------------------------------+

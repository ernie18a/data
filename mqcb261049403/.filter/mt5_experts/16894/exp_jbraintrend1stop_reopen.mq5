//+------------------------------------------------------------------+
//|                                  Exp_JBrainTrend1Stop_ReOpen.mq5 |
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+------------------------------------------------+
//| Торговые алгоритмы                             |
//+------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+------------------------------------------------+
//| Перечисление для вариантов расчёта лота        |
//+------------------------------------------------+
/*enum MarginMode  - перечисление объявлено в файле TradeAlgorithms.mqh
  {
   FREEMARGIN=0,     //MM от свободных средств на счёте
   BALANCE,          //MM от баланса средств на счёте
   LOSSFREEMARGIN,   //MM по убыткам от свободных средств на счёте
   LOSSBALANCE,      //MM по убыткам от баланса средств на счёте
   LOT               //Лот без изменения
  }; */
//+------------------------------------------------+
//| Входные параметры индикатора эксперта          |
//+------------------------------------------------+
input double MM=0.1;              // Доля финансовых ресурсов от депозита в сделке
input MarginMode MMMode=LOT;      // Способ определения размера лота
input int    StopLoss_=1000;      // Stop Loss в пунктах
input int    TakeProfit_=2000;    // Take Profit в пунктах
input int    Deviation_=10;       // Макс. отклонение цены в пунктах
input uint   PriceStep=300;       // шаг ценовой сетки в пунктах для доливки
input uint   PosTotal=10;         // количество доливочных сделок
input bool   BuyPosOpen=true;     // Разрешение для входа в лонг
input bool   SellPosOpen=true;    // Разрешение для входа в шорт
input bool   BuyPosClose=true;    // Разрешение для выхода из лонгов
input bool   SellPosClose=true;   // Разрешение для выхода из шортов
//+------------------------------------------------+
//| Входные параметры индикатора JBrainTrend1Stop  |
//+------------------------------------------------+
input ENUM_TIMEFRAMES InpInd_Timeframe=PERIOD_H4; // Таймфрейм индикатора
input int ATR_Period=7;                           // Период ATR 
input int STO_Period=9;                           // Период стохастика
input ENUM_MA_METHOD MA_Method=MODE_SMA;          // Метод усреднения
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH;       // Метод расчёта цен 
input int Stop_dPeriod=3;                         // Приращение периода для стопа
input int Length_=7;                              // Глубина JMA сглаживания                   
input int Phase_=100;                             // Параметр JMA сглаживания
input uint SignalBar=1;                           // Номер бара для получения сигнала входа
//+------------------------------------------------+
int TimeShiftSec;
//--- объявление целочисленных переменных для хендлов индикаторов
int InpInd_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Торговые алгоритмы                                               |
//+------------------------------------------------------------------+
#include <TradeAlgorithms.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- получение хендла индикатора JBrainTrend1Stop
   InpInd_Handle=iCustom(Symbol(),InpInd_Timeframe,"JBrainTrend1Stop",ATR_Period,STO_Period,MA_Method,STO_Price,Stop_dPeriod,Length_,Phase_);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора JBrainTrend1Stop");
      return(INIT_FAILED);
     }
//--- инициализация переменной для хранения периода графика в секундах  
   TimeShiftSec=PeriodSeconds(InpInd_Timeframe);
//--- инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(MathMax(MathMax(ATR_Period,STO_Period),ATR_Period+Stop_dPeriod),30)+2);
   min_rates_total+=int(3+SignalBar);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   GlobalVariableDel_(Symbol());
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(InpInd_Handle)<min_rates_total) return;
//--- подгрузка истории для нормальной работы функций IsNewBar() и SeriesInfoInteger()  
   LoadHistory(TimeCurrent()-PeriodSeconds(InpInd_Timeframe)-1,Symbol(),InpInd_Timeframe);
//--- объявление статических переменных
   int LastTrend;
   static bool Recount=true;
   static bool BUY_Open=false,BUY_Close=false;
   static bool SELL_Open=false,SELL_Close=false;
   static bool ReBUY_Open=false,ReSELL_Open=false;
   static datetime UpSignalTime,DnSignalTime;
   static CIsNewBar NB;
   static string RePosComment="";
//--- определение сигналов для сделок
   if(!SignalBar || NB.IsNewBar(Symbol(),InpInd_Timeframe) || Recount) // проверка на появление нового бара
     {
      //--- обнулим торговые сигналы
      BUY_Open=false;
      SELL_Open=false;
      BUY_Close=false;
      SELL_Close=false;
      ReBUY_Open=false;
      ReSELL_Open=false;
      LastTrend=0;
      Recount=false;
      //--- поиск последнего направления торговли
      int Bars_=Bars(Symbol(),InpInd_Timeframe);
      if(Bars_<min_rates_total) {Recount=true; return;}
      Bars_-=min_rates_total+3;
      //--- объявление локальных переменных
      double DnTrend[2],UpTrend[2];
      //--- копируем вновь появившиеся данные в массивы
      if(CopyBuffer(InpInd_Handle,1,SignalBar,2,UpTrend)<=0) {Recount=true; return;}
      if(CopyBuffer(InpInd_Handle,0,SignalBar,2,DnTrend)<=0) {Recount=true; return;}
      //--- получим сигналы для покупки
      if(UpTrend[1])
        {
         if(BuyPosOpen && DnTrend[0]) BUY_Open=true;
         if(SellPosClose) SELL_Close=true;
         UpSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }
      //--- получим сигналы для продажи
      if(DnTrend[1])
        {
         if(SellPosOpen && UpTrend[0]) SELL_Open=true;
         if(BuyPosClose) BUY_Close=true;
         DnSignalTime=datetime(SeriesInfoInteger(Symbol(),InpInd_Timeframe,SERIES_LASTBAR_DATE))+TimeShiftSec;
        }

      //---- Получение сигналов для доливок
      if(PositionSelect(Symbol())) //Проверка на на наличие открытой позиции
        {
         //---- Получим число доливок в позиции
         string PosComment=PositionGetString(POSITION_COMMENT); //комментарий к позиции
         int OrderTotal;
         double OpenPrice,LastLot;
         if(PosComment=="")
           {
            OrderTotal=0; //число доливок в позиции
            OpenPrice=PositionGetDouble(POSITION_PRICE_OPEN); //Цена открытия последней доливки
            LastLot=PositionGetDouble(POSITION_VOLUME); //Размер лота последней доливки
           }
         else
           {
            OrderTotal=GetTotalFromStringComment(PosComment); //число доливок в позиции
            OpenPrice=GetPriceFromStringComment(PosComment); //Цена открытия последней доливки
            LastLot=GetLotFromStringComment(PosComment); //Размер лота последней доливки
           }

         if(OrderTotal<int(PosTotal)) //проверка числа доливок на лимит числа доливок
           {
            ENUM_POSITION_TYPE PosType=ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));

            if(PosType==POSITION_TYPE_SELL)
              {
               double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
               double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
               if(!Bid || !point) {Recount=true; return;} //нет данных для дальнейшего расчёта
               int len=int((OpenPrice-Bid)/point); //расстояние в пунктах между текущей ценой и ценой открытия
               if(len>int(PriceStep)) //проверка на минимальное расстояние между доливками
                 {
                  ReSELL_Open=true;
                  //---- Информация о новой доливке для комментария к позиции
                  int NewOrderTotal=OrderTotal+1;
                  if(NewOrderTotal<10) RePosComment="  "+string(NewOrderTotal);
                  else if(NewOrderTotal<100) RePosComment=" "+string(NewOrderTotal);
                  else if(NewOrderTotal<1000) RePosComment=string(NewOrderTotal);
                  RePosComment=RePosComment+"/"+DoubleToString(Bid,_Digits);
                 }
              }

            if(PosType==POSITION_TYPE_BUY)
              {
               double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
               double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
               if(!Ask || !point) {Recount=true; return;}  //нет данных для дальнейшего расчёта
               int len=int((Ask-OpenPrice)/point); //расстояние в пунктах между текущей ценой и ценой открытия
               if(len>int(PriceStep)) //проверка на минимальное расстояние между доливками
                 {
                  ReBUY_Open=true;
                  //---- Информация о новой доливке для комментария к позиции
                  int NewOrderTotal=OrderTotal+1;
                  if(NewOrderTotal<10) RePosComment="  "+string(NewOrderTotal);
                  else if(NewOrderTotal<100) RePosComment=" "+string(NewOrderTotal);
                  else if(NewOrderTotal<1000) RePosComment=string(NewOrderTotal);
                  RePosComment=RePosComment+"/"+DoubleToString(Ask,_Digits);
                 }
              }
           }
        }
     }
//--- совершение сделок 
//---- Закрываем лонг
   BuyPositionClose(BUY_Close,Symbol(),Deviation_);

//---- Закрываем шорт   
   SellPositionClose(SELL_Close,Symbol(),Deviation_);

//---- Доливаем лонг
   ReBuyPositionOpen_X(ReBUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_,RePosComment);

//---- Доливаем шорт
   ReSellPositionOpen_X(ReSELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_,RePosComment);

//---- Открываем лонг
   BuyPositionOpen(BUY_Open,Symbol(),UpSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);

//---- Открываем шорт
   SellPositionOpen(SELL_Open,Symbol(),DnSignalTime,MM,MMMode,Deviation_,StopLoss_,TakeProfit_);
//----
  }
//+------------------------------------------------------------------+
//|  Получение числа доливок из комента к открытой позиции           |
//+------------------------------------------------------------------+
int GetTotalFromStringComment(string comment)
  {
//----
   return(int(StringToInteger(StringSubstr(comment,0,3))));
//----
  }
//+------------------------------------------------------------------+
//|  Получение последней цены открытия из комента к открытой позиции |
//+------------------------------------------------------------------+
double GetPriceFromStringComment(string comment)
  {
//----
   return(StringToDouble(StringSubstr(comment,4,7)));
//----
  }
//+------------------------------------------------------------------+
//|  Получение последнего объёма из комента к открытой позиции       |
//+------------------------------------------------------------------+
double GetLotFromStringComment(string comment)
  {
//----
   return(StringToDouble(StringSubstr(comment,12,-1)));
//----
  }
//+------------------------------------------------------------------+
//|  Получение торгового результата последней закрытой позиции       |
//+------------------------------------------------------------------+
double GetLastClosePosRezalt(const string PosSymbol)
  {
//---- Запросим всю торговую историю по счёту
   if(!HistorySelect(0,TimeCurrent())) return(0.0);

//---- Определим размер списка сделок
   uint deals=HistoryDealsTotal();

//--- теперь обработаем каждую сделку 
   for(int pos=int(deals)-1; pos>=0; pos--)
     {
      //---- найдём тикет последней закрытой сделки
      ulong deal_ticket=HistoryDealGetTicket(pos);
      //---- определим символ сделки
      string symbol=HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
      if(symbol!=PosSymbol) continue;
      //---- определим профит последней закрытой сделки
      double last_profit=HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
      double last_volume=HistoryDealGetDouble(deal_ticket,DEAL_VOLUME);
      if(last_profit>=0) return(last_volume);
      else return(-last_volume);
     }
//----
   return(0.0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                              TradeAlgorithms.mqh |
//|                               Copyright © 2012, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "2011,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.10"
//+------------------------------------------------------------------+
//|  Алгоритм определения момента появления нового бара              |
//+------------------------------------------------------------------+  
class CIsNewBar
  {
   //----
public:
   //---- функция определения момента появления нового бара
   bool IsNewBar(string symbol,ENUM_TIMEFRAMES timeframe)
     {
      //---- получим время появления текущего бара
      datetime TNew=datetime(SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE));

      if(TNew!=m_TOld && TNew) // проверка на появление нового бара
        {
         m_TOld=TNew;
         return(true); // появился новый бар!
        }
      //----
      return(false); // новых баров пока нет!
     };

   //---- конструктор класса    
                     CIsNewBar(){m_TOld=-1;};

protected: datetime m_TOld;
   //---- 
  };
//+==================================================================+
//| Алгоритмы для торговых операций                                  |
//+==================================================================+

//+------------------------------------------------------------------+
//| Открываем длинную позицию                                        |
//+------------------------------------------------------------------+
bool BuyPositionOpen
(
 bool &BUY_Signal,           // флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 const datetime &TimeLevel,  // время, после которого будет осуществлена следущая сделка после текущей
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit              // тейкпрофит в пунктах
 )
//BuyPositionOpen(BUY_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!BUY_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
   if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на на наличие открытой позиции
   if(PositionSelect(symbol)) return(true);

//----
   double volume=BuyLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Неверный объём для структуры торгового запроса");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(!digit || !point || !Ask) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price-dStopLoss,digit);
     }
   else request.sl=0.0;

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price+dTakeprofit,digit);
     }
   else request.tp=0.0;

//----
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Открываем Buy позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Открываем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      TradeTimeLevelSet(symbol,PosType,TimeLevel);
      BUY_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Buy позиция по ",symbol," открыта ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем короткую позицию                                       |
//+------------------------------------------------------------------+
bool SellPositionOpen
(
 bool &SELL_Signal,          // флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 const datetime &TimeLevel,  // время, после которого будет осуществлена следущая сделка после текущей
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit              // тейкпрофит в пунктах
 )
//SellPositionOpen(SELL_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!SELL_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
   if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на на наличие открытой позиции
   if(PositionSelect(symbol)) return(true);

//----
   double volume=BuyLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Неверный объём для структуры торгового запроса");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!digit || !point || !Bid) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss!=0)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price+dStopLoss,digit);
     }
   else request.sl=0.0;

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit!=0)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price-dTakeprofit,digit);
     }
   else request.tp=0.0;
//----
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Открываем Sell позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Открываем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      TradeTimeLevelSet(symbol,PosType,TimeLevel);
      SELL_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Sell позиция по ",symbol," открыта ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем длинную позицию                                        |
//+------------------------------------------------------------------+
bool BuyPositionOpen
(
 bool &BUY_Signal,           // флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 const datetime &TimeLevel,  // время, после которого будет осуществлена следущая сделка после текущей
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 double dStopLoss,           // стоплосс в единицах ценового графика
 double dTakeprofit          // тейкпрофит в единицах ценового графика
 )
//BuyPositionOpen(BUY_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!BUY_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
   if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на на наличие открытой позиции
   if(PositionSelect(symbol)) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(!digit || !point || !Ask) return(false);

//---- коррекция расстояний до стоплосса и тейкпрофита в единицах ценового графика
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType)) return(false);
   int StopLoss=int((Ask-dStopLoss)/point);
//----
   double volume=BuyLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Неверный объём для структуры торгового запроса");
      return(false);
     }

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl=dStopLoss;
   request.tp=dTakeprofit;
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Открываем Buy позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Открываем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      TradeTimeLevelSet(symbol,PosType,TimeLevel);
      BUY_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Buy позиция по ",symbol," открыта ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем короткую позицию                                       |
//+------------------------------------------------------------------+
bool SellPositionOpen
(
 bool &SELL_Signal,          // флаг разрешения на сделку
 const string symbol,        // торговая пара сделки
 const datetime &TimeLevel,  // время, после которого будет осуществлена следущая сделка после текущей
 double Money_Management,    // MM
 int Margin_Mode,            // способ расчёта величины лота
 uint deviation,             // слиппаж
 double dStopLoss,           // стоплосс в единицах ценового графика
 double dTakeprofit          // тейкпрофит в единицах ценового графика
 )
//SellPositionOpen(SELL_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!SELL_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Проверка на истечение временного лимита для предыдущей сделки и полноты объёма
   if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Проверка на на наличие открытой позиции
   if(PositionSelect(symbol)) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!digit || !point || !Bid) return(true);

//---- коррекция расстояний до стоплосса и тейкпрофита в единицах ценового графика
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType)) return(false);
   int StopLoss=int((dStopLoss-Bid)/point);
//----
   double volume=SellLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Неверный объём для структуры торгового запроса");
      return(false);
     }

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): OrderCheck(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Открываем Sell позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Открываем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): OrderSend(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      TradeTimeLevelSet(symbol,PosType,TimeLevel);
      SELL_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Sell позиция по ",symbol," открыта ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): OrderSend(): Невозможно совершить сделку!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Закрываем длинную позицию                                        |
//+------------------------------------------------------------------+
bool BuyPositionClose
(
 bool &Signal,         // флаг разрешения на сделку
 const string symbol,  // торговая пара сделки
 uint deviation        // слиппаж
 )
  {
//----
   if(!Signal) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

//---- Проверка на наличие открытой BUY позиции
   if(PositionSelect(symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_BUY) return(false);
     }
   else return(false);

//---- получение данных для расчёта 
   double volume=PositionGetDouble(POSITION_VOLUME);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double Bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!volume || !MaxLot || !Bid) return(false);

//---- проверка лота на максимальное допустимое значение       
   if(volume>MaxLot) volume=MaxLot;

//---- Инициализация структуры торгового запроса MqlTradeRequest для закрывания BUY позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl = 0.0;
   request.tp = 0.0;
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }
//----     
   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Закрываем Buy позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Отправка приказа на закрывание позиции на торговый сервер
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно закрыть позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Buy позиция по ",symbol," закрыта ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно закрыть позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Закрываем короткую позицию                                       |
//+------------------------------------------------------------------+
bool SellPositionClose
(
 bool &Signal,         // флаг разрешения на сделку
 const string symbol,  // торговая пара сделки
 uint deviation        // слиппаж
 )
  {
//----
   if(!Signal) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

//---- Проверка на наличие открытой BUY позиции
   if(PositionSelect(symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL)return(false);
     }
   else return(false);

//---- получение данных для расчёта 
   double volume=PositionGetDouble(POSITION_VOLUME);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double Ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(!volume || !MaxLot || !Ask) return(false);

//---- проверка лота на максимальное допустимое значение       
   if(volume>MaxLot) volume=MaxLot;

//---- Инициализация структуры торгового запроса MqlTradeRequest для закрывания SELL позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl = 0.0;
   request.tp = 0.0;
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }
//----    
   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Закрываем Sell позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Отправка приказа на закрывание позиции на торговый сервер
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно закрыть позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      Signal=false;
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно закрыть позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Sell позиция по ",symbol," закрыта ============ >>>");
      //Print(comment);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Модифицируем длинную позицию                                     |
//+------------------------------------------------------------------+
bool BuyPositionModify
(
 bool &Modify_Signal,        // флаг разрешения модификации
 const string symbol,        // торговая пара сделки
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit              // тейкпрофит в пунктах
 )
//BuyPositionModify(Modify_Signal,symbol,deviation,StopLoss,Takeprofit);
  {
//----
   if(!Modify_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;

//---- Проверка на на наличие открытой позиции
   if(!PositionSelect(symbol)) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;

//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(!digit || !point || !Ask) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price-dStopLoss,digit);
      if(request.sl<PositionGetDouble(POSITION_SL)) request.sl=PositionGetDouble(POSITION_SL);
     }
   else request.sl=PositionGetDouble(POSITION_SL);

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price+dTakeprofit,digit);
      if(request.tp<PositionGetDouble(POSITION_TP)) request.tp=PositionGetDouble(POSITION_TP);
     }
   else request.tp=PositionGetDouble(POSITION_TP);

//----   
   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL)) return(true);
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Модифицируем Buy позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Модифицируем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно модифицировать позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      Modify_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Buy позиция по ",symbol," модифицирована ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно модифицировать позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Модифицируем короткую позицию                                    |
//+------------------------------------------------------------------+
bool SellPositionModify
(
 bool &Modify_Signal,        // флаг разрешения модификации
 const string symbol,        // торговая пара сделки
 uint deviation,             // слиппаж
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit              // тейкпрофит в пунктах
 )
//SellPositionModify(Modify_Signal,symbol,deviation,StopLoss,Takeprofit);
  {
//----
   if(!Modify_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;

//---- Проверка на на наличие открытой позиции
   if(!PositionSelect(symbol)) return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;

//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double Bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!digit || !point || !Bid) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;

//---- Определение расстояния до стоплосса в единицах ценового графика
   if(StopLoss!=0)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price+dStopLoss,digit);
      double laststop=PositionGetDouble(POSITION_SL);
      if(request.sl>laststop && laststop) request.sl=PositionGetDouble(POSITION_SL);
     }
   else request.sl=PositionGetDouble(POSITION_SL);

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit!=0)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price-dTakeprofit,digit);
      double lasttake=PositionGetDouble(POSITION_TP);
      if(request.tp>lasttake && lasttake) request.tp=PositionGetDouble(POSITION_TP);
     }
   else request.tp=PositionGetDouble(POSITION_TP);

//----   
   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL)) return(true);
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Неверные данные для структуры торгового запроса!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Модифицируем Sell позицию по ",symbol," ============ >>>");
   Print(comment);

//---- Модифицируем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Невозможно модифицировать позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      Modify_Signal=false;
      comment="";
      //StringConcatenate(comment,"<<< ============ ",__FUNCTION__,"(): Sell позиция по ",symbol," модифицирована ============ >>>");
      //Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): Невозможно модифицировать позицию!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| GetTimeLevelName() function                                      |
//+------------------------------------------------------------------+
string GetTimeLevelName(string symbol,ENUM_POSITION_TYPE trade_operation)
  {
//----
   string G_Name_;
//----  
   if(MQL5InfoInteger(MQL5_TESTING)
      || MQL5InfoInteger(MQL5_OPTIMIZATION)
      || MQL5InfoInteger(MQL5_DEBUGGING))
      StringConcatenate(G_Name_,"TimeLevel_",AccountInfoInteger(ACCOUNT_LOGIN),"_",symbol,"_",trade_operation,"_Test_");
   else StringConcatenate(G_Name_,"TimeLevel_",AccountInfoInteger(ACCOUNT_LOGIN),"_",symbol,"_",trade_operation);
//----
   return(G_Name_);
  }
//+------------------------------------------------------------------+
//| TradeTimeLevelCheck() function                                   |
//+------------------------------------------------------------------+
bool TradeTimeLevelCheck
(
 string symbol,
 ENUM_POSITION_TYPE trade_operation,
 datetime TradeTimeLevel
 )
  {
//----
   if(TradeTimeLevel>0)
     {
      //---- Получение имени глобальной 
      //переменной для запоминания лимита времени
      string G_Name_=GetTimeLevelName(symbol,trade_operation);

      //---- Проверка на истечение временного лимита для предыдущей сделки 
      if(TimeCurrent()<GlobalVariableGet(G_Name_)) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| TradeTimeLevelSet() function                                     |
//+------------------------------------------------------------------+
void TradeTimeLevelSet
(
 string symbol,
 ENUM_POSITION_TYPE trade_operation,
 datetime TradeTimeLevel
 )
  {
//---- Получение имени глобальной 
//переменной для запоминания лимита времени
   string G_Name_=GetTimeLevelName(symbol,trade_operation);
   GlobalVariableSet(GetTimeLevelName(symbol,trade_operation),TradeTimeLevel);
//----
  }
//+------------------------------------------------------------------+
//| TradeTimeLevelSet() function                                     |
//+------------------------------------------------------------------+
datetime TradeTimeLevelGet
(
 string symbol,
 ENUM_POSITION_TYPE trade_operation
 )
  {
//----
   return(datetime(GlobalVariableGet(GetTimeLevelName(symbol,trade_operation))));
  }
//+------------------------------------------------------------------+
//| TimeLevelGlobalVariableDel() function                            |
//+------------------------------------------------------------------+
void TimeLevelGlobalVariableDel
(
 string symbol,
 ENUM_POSITION_TYPE trade_operation
 )
  {
//----
   if(MQL5InfoInteger(MQL5_TESTING)
      || MQL5InfoInteger(MQL5_OPTIMIZATION)
      || MQL5InfoInteger(MQL5_DEBUGGING))
      GlobalVariableDel(GetTimeLevelName(symbol,trade_operation));
//----
  }
//+------------------------------------------------------------------+
//| GlobalVariableDel_() function                                    |
//+------------------------------------------------------------------+
void GlobalVariableDel_(string symbol)
  {
//----
   TimeLevelGlobalVariableDel(symbol,POSITION_TYPE_BUY);
   TimeLevelGlobalVariableDel(symbol,POSITION_TYPE_SELL);
//----
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания лонга                         |  
//+------------------------------------------------------------------+
/*                                                                   |
 Внешняя  переменная Margin_Mode определяет способ расчёта  величины | 
 лота                                                                |
 0 - MM по свободным средствам на счёте                              |
 1 - MM по балансу средств на счёте                                  |
 2 - MM по убыткам от свободных средств на счёте                     |
 3 - MM по убыткам от баланса средств на счёте                       |
 по умолчанию - MM по свободным средствам на счёте                   |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 если Money_Management меньше нуля,  то торговая  функция в качестве | 
 величины  лота  использует  округлённую  до ближайшего стандартного |
 значения абсолютную величину Money_Management.                      |
*///                                                                 |
//+------------------------------------------------------------------+
double BuyLotCount_
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
// (string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   double margin,Lot;

//---1+ РАСЧЁТ ВЕЛИЧИНЫ ЛОТА ДЛЯ ОТКРЫВАНИЯ ПОЗИЦИИ
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Расчёт лота от свободных средств на счёте
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         if(!margin) return(-1);  
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
         break;

         //---- Расчёт лота от баланса средств на счёте
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         if(!margin) return(-1); 
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin); 
         break;

         //---- Расчёт лота по убыткам от свободных средств на счёте             
      case  2:
        {
         if(STOPLOSS<=0)
           {
            Print(__FUNCTION__,": Неверный стоплосс!!!");
            STOPLOSS=0;
           }
         if(!StopCorrect(symbol,STOPLOSS)) return(-1);
         double TICKSIZE=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);         
         double TICKLOSS=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;     
         if(!TICKSIZE || !TICKLOSS || !margin) return(-1);        
         //----         
         Lot=margin*TICKSIZE/(TICKLOSS*STOPLOSS);
         break;
        }

      //---- Расчёт лота по убыткам от баланса средств на счёте
      case  3:
        {
         if(STOPLOSS<=0)
           {
            Print(__FUNCTION__,": Неверный стоплосс!!!");
            STOPLOSS=0;
           }
         //---- 
         if(!StopCorrect(symbol,STOPLOSS))return(-1);
         double TICKSIZE=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);         
         double TICKLOSS=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;        
         if(!TICKSIZE || !TICKLOSS || !margin) return(-1);        
         //----         
         Lot=margin*TICKSIZE/(TICKLOSS*STOPLOSS);
         break;
        }

      //---- Расчёт лота от свободных средств на счёте по умолчанию
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         if(!margin) return(-1); 
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
        }
     }
//---1+    

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_BUY)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания шорта                         |  
//+------------------------------------------------------------------+
/*                                                                   |
 Внешняя  переменная Margin_Mode определяет способ расчёта  величины | 
 лота                                                                |
 0 - MM по свободным средствам на счёте                              |
 1 - MM по балансу средств на счёте                                  |
 2 - MM по убыткам от свободных средств на счёте                     |
 3 - MM по убыткам от баланса средств на счёте                       |
 по умолчанию - MM по свободным средствам на счёте                   |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 если Money_Management меньше нуля,  то торговая  функция в качестве | 
 величины  лота  использует  округлённую  до ближайшего стандартного |
 значения абсолютную величину Money_Management.                      |
*///                                                                 |
//+------------------------------------------------------------------+
double SellLotCount_
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
// (string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   double margin,Lot;

//---1+ РАСЧЁТ ВЕЛИЧИНЫ ЛОТА ДЛЯ ОТКРЫВАНИЯ ПОЗИЦИИ
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Расчёт лота от свободных средств на счёте
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         if(!margin) return(-1); 
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //---- Расчёт лота от баланса средств на счёте
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         if(!margin) return(-1); 
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //---- Расчёт лота по убыткам от свободных средств на счёте             
      case  2:
        {
         if(STOPLOSS<=0)
           {
            Print(__FUNCTION__,": Неверный стоплосс!!!");
            STOPLOSS=0;
           }
         //---- 
         if(!StopCorrect(symbol,STOPLOSS))return(-1);
         double TICKSIZE=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);         
         double TICKLOSS=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
         int SPREAD=int(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;     
         if(!TICKSIZE || !TICKLOSS || !margin || !SPREAD) return(-1);        
         //----         
         Lot=margin*TICKSIZE/(TICKLOSS*(STOPLOSS+SPREAD));
         break;
        }

      //---- Расчёт лота по убыткам от баланса средств на счёте
      case  3:
        {
         if(STOPLOSS<=0)
           {
            Print(__FUNCTION__,": Неверный стоплосс!!!");
            STOPLOSS=0;
           }
         //----
         if(!StopCorrect(symbol,STOPLOSS))return(-1);
         double TICKSIZE=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);         
         double TICKLOSS=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
         int SPREAD=int(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;   
         if(!TICKSIZE || !TICKLOSS || !margin || !SPREAD) return(-1);        
         //----         
         Lot=margin*TICKSIZE/(TICKLOSS*(STOPLOSS+SPREAD));
         break;
        }

      //---- Расчёт лота от свободных средств на счёте по умолчанию
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         if(!margin) return(-1); 
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
        }
     }
//---1+ 

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_SELL)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания лонга                         |   
//+------------------------------------------------------------------+
/*                                                                   |
 Внешняя  переменная Margin_Mode определяет способ расчёта  величины | 
 лота                                                                |
 0 - MM по свободным средствам на счёте                              |
 1 - MM по балансу средств на счёте                                  |
 2 - MM по убыткам от свободных средств на счёте                     |
 3 - MM по убыткам от баланса средств на счёте                       |
 4 - минимальный лот между 0 и 2                                     |
 5 - минимальный лот между 1 и 3                                     |
 по умолчанию - MM по свободным средствам на счёте                   |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 если Money_Management меньше нуля,  то торговая  функция в качестве | 
 величины  лота  использует  округлённую  до ближайшего стандартного |
 значения абсолютную величину Money_Management.                      |
*///                                                                 |
//+------------------------------------------------------------------+                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
double BuyLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 int Slippage_
 )
// BuyLotCount(string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   if(Money_Management<0) return(BuyLotCount_(symbol,Money_Management,0,0,0));
//----
   double LotA,LotB;
   int MarModeA,MarModeB;
//----
   switch(Margin_Mode)
     {
      case 4:
         MarModeA = 0;
         MarModeB = 2;
         break;
         //----
      case 5:
         MarModeA = 1;
         MarModeB = 3;
         break;
         //----                                                                 
      default: return(BuyLotCount_(symbol,Money_Management,Margin_Mode,STOPLOSS,Slippage_));
     }

   LotA=BuyLotCount_(symbol,Money_Management,MarModeA,STOPLOSS,Slippage_);
   if(LotA==-1) return(-1);
//----          
   LotB=BuyLotCount_(symbol,Money_Management,MarModeB,STOPLOSS,Slippage_);
   if(LotB==-1) return(-1);
//----              
   if(LotA<LotB)
      return(LotA);
   else return(LotB);
//----
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания шорта                         |  
//+------------------------------------------------------------------+   
/*                                                                   |
 Внешняя  переменная Margin_Mode определяет способ расчёта  величины | 
 лота                                                                |
 0 - MM по свободным средствам на счёте                              |
 1 - MM по балансу средств на счёте                                  |
 2 - MM по убыткам от свободных средств на счёте                     |
 3 - MM по убыткам от баланса средств на счёте                       |
 4 - минимальный лот между 0 и 2                                     |
 5 - минимальный лот между 1 и 3                                     |
 по умолчанию - MM по свободным средствам на счёте                   |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 если Money_Management меньше нуля,  то торговая  функция в качестве | 
 величины  лота  использует  округлённую  до ближайшего стандартного |
 значения абсолютную величину Money_Management.                      |
*///                                                                 |
//+------------------------------------------------------------------+                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
double SellLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 int Slippage_
 )
// (string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   if(Money_Management<0) return(SellLotCount_(symbol,Money_Management,0,0,0));
//----
   double LotA,LotB;
   int MarModeA,MarModeB;
//----
   switch(Margin_Mode)
     {
      case 4:
         MarModeA = 0;
         MarModeB = 2;
         break;
         //----
      case 5:
         MarModeA = 1;
         MarModeB = 3;
         break;
         //----                                                                 
      default: return(SellLotCount_(symbol,Money_Management,Margin_Mode,STOPLOSS,Slippage_));
     }

   LotA=SellLotCount_(symbol,Money_Management,MarModeA,STOPLOSS,Slippage_);
   if(LotA==-1) return(-1);
//----          
   LotB=SellLotCount_(symbol,Money_Management,MarModeB,STOPLOSS,Slippage_);
   if(LotB==-1) return(-1);
//----              
   if(LotA<LotB)
      return(LotA);
   else return(LotB);
//----
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool StopCorrect(string symbol,int &Stop)
  {
//----
   int Extrem_Stop=int(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
   if(!Extrem_Stop) return(false);
   if(Stop<Extrem_Stop) Stop=Extrem_Stop;
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool dStopCorrect
(
 string symbol,
 double &dStopLoss,
 double &dTakeprofit,
 ENUM_POSITION_TYPE trade_operation
 )
// dStopCorrect(symbol,dStopLoss,dTakeprofit,trade_operation)
  {
//----
   if(!dStopLoss && !dTakeprofit) return(true);

   if(dStopLoss<0)
     {
      Print(__FUNCTION__,"(): Отрицательное значение стоплосса!");
      return(false);
     }

   if(dTakeprofit<0)
     {
      Print(__FUNCTION__,"(): Отрицательное значение тейкпрофита!");
      return(false);
     }

   int Stop,digit;
   double point,dStop,ExtrStop,ExtrTake;

//---- получаем минимальное расстояние до отложенного ордера 
   Stop=0;
   if(!StopCorrect(symbol,Stop))return(false);

//----
   digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(!digit || !point) return(true);
   dStop=Stop*point;

//---- коррекция размера отложенного ордера для лонга
   if(trade_operation==POSITION_TYPE_BUY)
     {
      double Ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
      if(!Ask) return(false);

      ExtrStop=NormalizeDouble(Ask-dStop,digit);
      ExtrTake=NormalizeDouble(Ask+dStop,digit);

      if(dStopLoss>ExtrStop) dStopLoss=ExtrStop;
      if(dTakeprofit<ExtrTake) dTakeprofit=ExtrTake;
     }

//---- коррекция размера отложенного ордера для шорта
   if(trade_operation==POSITION_TYPE_SELL)
     {
      double Bid=SymbolInfoDouble(symbol,SYMBOL_BID);
      if(!Bid) return(false);

      ExtrStop=NormalizeDouble(Bid+dStop,digit);
      ExtrTake=NormalizeDouble(Bid-dStop,digit);

      if(dStopLoss<ExtrStop) dStopLoss=ExtrStop;
      if(dTakeprofit>ExtrTake) dTakeprofit=ExtrTake;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| коррекция размера лота до ближайшего допустимого значения        |
//+------------------------------------------------------------------+
bool LotCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//LotCorrect(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- получение данных для расчёта  
   double Step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!Step || !MaxLot || !MinLot) return(false);

//---- нормирование величины лота до ближайшего стандартного значения 
   Lot=Step*MathFloor(Lot/Step);

//---- проверка лота на минимальное допустимое значение
   if(Lot<MinLot) Lot=MinLot;
//---- проверка лота на максимальное допустимое значение       
   if(Lot>MaxLot) Lot=MaxLot;

//---- проверка средств на достаточность
   if(!LotFreeMarginCorrect(symbol,Lot,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| ограничение размера лота возможностями депозита                  |
//+------------------------------------------------------------------+
bool LotFreeMarginCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- проверка средств на достаточность
   double freemargin=AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freemargin<=0) return(false);

//---- получение данных для расчёта  
   double Step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!Step || !MaxLot || !MinLot) return(false);

   double ExtremLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- нормирование величины лота до ближайшего стандартного значения 
   ExtremLot=Step*MathFloor(ExtremLot/Step);

   if(ExtremLot<MinLot) return(false); // недостаточно денег даже на минимальный лот!
   if(Lot>ExtremLot) Lot=ExtremLot; // урезаем размер лота до того, что есть на депозите!
   if(Lot>MaxLot) Lot=MaxLot; // урезаем размер лота до масимально допустимого
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| расчёт размер лота для открывания позиции с маржой lot_margin    |
//+------------------------------------------------------------------+
double GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   if(direction==POSITION_TYPE_BUY)  price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(direction==POSITION_TYPE_SELL) price=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!price) return(NULL);
   
   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin) return(0);
   double lot=lot_margin/n_margin;

//---- получение торговых констант
   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MaxLot || !MinLot) return(0);
   
//---- нормирование величины лота до ближайшего стандартного значения 
   lot=LOTSTEP*MathFloor(lot/LOTSTEP);

//---- проверка лота на минимальное допустимое значение
   if(lot<MinLot) lot=0;
//---- проверка лота на максимальное допустимое значение       
   if(lot>MaxLot) lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| возврат стрингового результата торговой операции по его коду     |
//+------------------------------------------------------------------+
string ResultRetcodeDescription_(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: str="Реквота"; break;
      case TRADE_RETCODE_REJECT: str="Запрос отвергнут"; break;
      case TRADE_RETCODE_CANCEL: str="Запрос отменен трейдером"; break;
      case TRADE_RETCODE_PLACED: str="Ордер размещен"; break;
      case TRADE_RETCODE_DONE: str="Заявка выполнена"; break;
      case TRADE_RETCODE_DONE_PARTIAL: str="Заявка выполнена частично"; break;
      case TRADE_RETCODE_ERROR: str="Ошибка обработки запроса"; break;
      case TRADE_RETCODE_TIMEOUT: str="Запрос отменен по истечению времени";break;
      case TRADE_RETCODE_INVALID: str="Неправильный запрос"; break;
      case TRADE_RETCODE_INVALID_VOLUME: str="Неправильный объем в запросе"; break;
      case TRADE_RETCODE_INVALID_PRICE: str="Неправильная цена в запросе"; break;
      case TRADE_RETCODE_INVALID_STOPS: str="Неправильные стопы в запросе"; break;
      case TRADE_RETCODE_TRADE_DISABLED: str="Торговля запрещена"; break;
      case TRADE_RETCODE_MARKET_CLOSED: str="Рынок закрыт"; break;
      case TRADE_RETCODE_NO_MONEY: str="Нет достаточных денежных средств для выполнения запроса"; break;
      case TRADE_RETCODE_PRICE_CHANGED: str="Цены изменились"; break;
      case TRADE_RETCODE_PRICE_OFF: str="Отсутствуют котировки для обработки запроса"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="Неверная дата истечения ордера в запросе"; break;
      case TRADE_RETCODE_ORDER_CHANGED: str="Состояние ордера изменилось"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Слишком частые запросы"; break;
      case TRADE_RETCODE_NO_CHANGES: str="В запросе нет изменений"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Автотрейдинг запрещен сервером"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Автотрейдинг запрещен клиентским терминалом"; break;
      case TRADE_RETCODE_LOCKED: str="Запрос заблокирован для обработки"; break;
      case TRADE_RETCODE_FROZEN: str="Ордер или позиция заморожены"; break;
      case TRADE_RETCODE_INVALID_FILL: str="Указан неподдерживаемый тип исполнения ордера по остатку "; break;
      case TRADE_RETCODE_CONNECTION: str="Нет соединения с торговым сервером"; break;
      case TRADE_RETCODE_ONLY_REAL: str="Операция разрешена только для реальных счетов"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="Достигнут лимит на количество отложенных ордеров"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="Достигнут лимит на объем ордеров и позиций для данного символа"; break;
      default: str="Неизвестный результат";
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| возврат стрингового результата торговой операции по его коду     |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: str="Requote"; break;
      case TRADE_RETCODE_REJECT: str="Request rejected"; break;
      case TRADE_RETCODE_CANCEL: str="Request canceled by      case TRADEr"; break;
      case TRADE_RETCODE_PLACED: str="Order placed"; break;
      case TRADE_RETCODE_DONE: str="Request completed"; break;
      case TRADE_RETCODE_DONE_PARTIAL: str="Only part of the request was completed"; break;
      case TRADE_RETCODE_ERROR: str="Request processing error"; break;
      case TRADE_RETCODE_TIMEOUT: str="Request canceled by timeout"; break;
      case TRADE_RETCODE_INVALID: str="Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume in the request"; break;
      case TRADE_RETCODE_INVALID_PRICE: str="Invalid price in the request"; break;
      case TRADE_RETCODE_INVALID_STOPS: str="Invalid stops in the request"; break;
      case TRADE_RETCODE_TRADE_DISABLED: str="Trade is disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED: str="Market is closed"; break;
      case TRADE_RETCODE_NO_MONEY: str="There is not enough money to complete the request"; break;
      case TRADE_RETCODE_PRICE_CHANGED: str="Prices changed"; break;
      case TRADE_RETCODE_PRICE_OFF: str="There are no quotes to process the request"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
      case TRADE_RETCODE_ORDER_CHANGED: str="Order state changed"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too frequent requests"; break;
      case TRADE_RETCODE_NO_CHANGES: str="No changes in request"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
      case TRADE_RETCODE_LOCKED: str="Request locked for processing"; break;
      case TRADE_RETCODE_FROZEN: str="Order or position frozen"; break;
      case TRADE_RETCODE_INVALID_FILL: str="Invalid order filling type"; break;
      case TRADE_RETCODE_CONNECTION: str="No connection with the      case TRADE server"; break;
      case TRADE_RETCODE_ONLY_REAL: str="Operation is allowed only for live accounts"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="The number of pending orders has reached the limit"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="The volume of orders and positions for the symbol has reached the limit"; break;
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+

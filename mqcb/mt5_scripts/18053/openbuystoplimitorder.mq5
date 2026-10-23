//+------------------------------------------------------------------+
//|                                        OpenBuyStopLimitOrder.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии скрипта
#property version   "1.00" 
//---- показывать входные параметры
#property script_show_inputs
//+----------------------------------------------+
//| ВХОДНЫЕ ПАРАМЕТРЫ СКРИПТА                    |
//+----------------------------------------------+
input double  MM=0.1;       // Money Management
input int  DEVIATION=10;    // Отклонение цены
input uint  LEVEL=300;      // Расстояние до ордера в пунктах
input uint  STOPLEVEL=150;  // Расстояние Stop Limit в пунктах
input uint  STOPLOSS=100;   // Стоплосс в пунктах от текущей цены
input uint  TAKEPROFIT=800; // Тейкпрофит  в пунктах от текущей цены
input uint RTOTAL=4;        // Число повторов при неудачных сделках
input uint SLEEPTIME=1;     // Время паузы между повторами в секундах
//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//----
   for(uint count=0; count<=RTOTAL && !IsStopped(); count++)
     {
      uint result=BuyStopLimitOrderOpen(Symbol(),MM,DEVIATION,LEVEL,STOPLEVEL,STOPLOSS,TAKEPROFIT);
      if(ResultRetcodeCheck(result)) break;
      else Sleep(SLEEPTIME*1000);
     }
//----
  }
//+------------------------------------------------------------------+
//| Открываем buy ордер.                                             |
//+------------------------------------------------------------------+
uint BuyStopLimitOrderOpen
(
 const string symbol,
 double Money_Management,
 uint deviation,
 uint level,
 uint StopLimitLevel,
 uint StopLoss,
 uint Takeprofit
 )
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   double volume=BuyLotCount(symbol,Money_Management);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Неверный объём для структуры торгового запроса");
      return(TRADE_RETCODE_INVALID_VOLUME);
     }
//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeCheckResult check;
   MqlTradeResult result;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double price=SymbolInfoDouble(symbol, SYMBOL_ASK);
   if(!digit || !point || !price) return(TRADE_RETCODE_ERROR);
   price+=level*point;
   double stoplimitprice=price-StopLimitLevel*point;

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY ордера
   request.type   = ORDER_TYPE_BUY_STOP_LIMIT;  
   request.price  = price;
   request.stoplimit = stoplimitprice;
   request.action = TRADE_ACTION_PENDING;
   request.symbol = symbol;
   request.volume = volume;
//----
   if(StopLoss)
     {
      //---- Определение расстояния до стоплосса в единицах ценового графика
      if(!StopCorrect(symbol,StopLoss)) return(TRADE_RETCODE_ERROR);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(stoplimitprice-dStopLoss,digit);
     }
   else request.sl=0.0;

   if(Takeprofit)
     {
      //---- Определение расстояния до тейкпрофита единицах ценового графика
      if(!StopCorrect(symbol,Takeprofit)) return(TRADE_RETCODE_ERROR);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(stoplimitprice+dTakeprofit,digit);
     }
   else request.tp=0.0;
//----
   request.deviation=deviation;
   request.type_filling=ORDER_FILLING_FOK;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(TRADE_RETCODE_INVALID);
     }

   string word="";
   StringConcatenate(word,__FUNCTION__,"(): <<< Выставляем Buy Stop Limit ордер по ",symbol,"! >>>");
   Print(word);

   word=__FUNCTION__+"(): OrderSend(): ";

//---- Открываем BUY ордер и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(word,"<<< Не удалось выставить Buy Stop Limit ордер по ",symbol,"!!! >>>");
      Print(word,ResultRetcodeDescription(result.retcode));
      PlaySound("timeout.wav");
      return(result.retcode);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      Print(word,"<<< Buy Stop Limit ордер по ",symbol," выставлен! >>>");
      PlaySound("ok.wav");
     }
   else
     {
      Print(word,"<<< Не удалось выставить Buy Stop Limit ордер по ",symbol,"!!! >>>");
      PlaySound("timeout.wav");
      return(TRADE_RETCODE_ERROR);
     }
//----
   return(TRADE_RETCODE_DONE);
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания лонга                         |  
//+------------------------------------------------------------------+
double BuyLotCount
(
 string symbol,
 double Money_Management
 )
// (string symbol, double Money_Management)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   double margin,Lot;

//---- Расчёт лота от баланса средств на счёте
   margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
   if(!margin) return(-1);

   Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_BUY)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool StopCorrect(string symbol,int &Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop) Stop=int(Extrem_Stop);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| LotCorrect() function                                            |
//+------------------------------------------------------------------+
bool LotCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//LotCorrect(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {

   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MaxLot || !MinLot) return(0);

//---- нормирование величины лота до ближайшего стандартного значения 
   Lot=LOTSTEP*MathFloor(Lot/LOTSTEP);

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
//| LotFreeMarginCorrect() function                                  |
//+------------------------------------------------------------------+
bool LotFreeMarginCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----  
//---- проверка средств на достаточность
   double freemargin=AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freemargin<=0) return(false);
   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MinLot) return(0);
   double maxLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- нормирование величины лота до ближайшего стандартного значения 
   maxLot=LOTSTEP*MathFloor(maxLot/LOTSTEP);
   if(maxLot<MinLot) return(false);
   if(Lot>maxLot) Lot=maxLot;
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| расчёт размер лота для открывания ордера с маржой lot_margin     |
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
string ResultRetcodeDescription(int retcode)
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
      case TRADE_RETCODE_INVALID_FILL: str="Указан неподдерживаемый тип исполнения ордера по остатку"; break;
      case TRADE_RETCODE_CONNECTION: str="Нет соединения с торговым сервером"; break;
      case TRADE_RETCODE_ONLY_REAL: str="Операция разрешена только для реальных счетов"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="Достигнут лимит на количество отложенных ордеров"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="Достигнут лимит на объем ордеров и позиций для данного символа"; break;
      case TRADE_RETCODE_INVALID_ORDER: str="Неверный или запрещённый тип ордера"; break;
      case TRADE_RETCODE_POSITION_CLOSED: str="Позиция с указанным POSITION_IDENTIFIER уже закрыта"; break;
      case TRADE_RETCODE_INVALID_CLOSE_VOLUME: str="Закрываемый объем превышает текущий объем позиции"; break;
      case TRADE_RETCODE_CLOSE_ORDER_EXIST: str="Для указанной позиции уже есть ордер на закрытие"; break;
      case TRADE_RETCODE_LIMIT_POSITIONS: str="Количество открытых позиций, которое можно одновременно иметь на счете, может быть ограничено настройками сервера"; break;
      //case : str=""; break;
      //case : str=""; break;
      //case : str=""; break;
      //case : str=""; break;
      default: str="Неизвестный результат";
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| возврат результата торговой операции для повтора сделки          |
//+------------------------------------------------------------------+
bool ResultRetcodeCheck(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: /*Реквота*/ return(false); break;
      case TRADE_RETCODE_REJECT: /*Запрос отвергнут*/ return(false); break;
      case TRADE_RETCODE_CANCEL: /*Запрос отменен трейдером*/ return(true); break;
      case TRADE_RETCODE_PLACED: /*Ордер размещен*/ return(true); break;
      case TRADE_RETCODE_DONE: /*Заявка выполнена*/ return(true); break;
      case TRADE_RETCODE_DONE_PARTIAL: /*Заявка выполнена частично*/ return(true); break;
      case TRADE_RETCODE_ERROR: /*Ошибка обработки запроса*/ return(false); break;
      case TRADE_RETCODE_TIMEOUT: /*Запрос отменен по истечению времени*/ return(false); break;
      case TRADE_RETCODE_INVALID: /*Неправильный запрос*/ return(true); break;
      case TRADE_RETCODE_INVALID_VOLUME: /*Неправильный объем в запросе*/ return(true); break;
      case TRADE_RETCODE_INVALID_PRICE: /*Неправильная цена в запросе*/ return(true); break;
      case TRADE_RETCODE_INVALID_STOPS: /*Неправильные стопы в запросе*/ return(true); break;
      case TRADE_RETCODE_TRADE_DISABLED: /*Торговля запрещена*/ return(true); break;
      case TRADE_RETCODE_MARKET_CLOSED: /*Рынок закрыт*/ return(true); break;
      case TRADE_RETCODE_NO_MONEY: /*Нет достаточных денежных средств для выполнения запроса*/ return(true); break;
      case TRADE_RETCODE_PRICE_CHANGED: /*Цены изменились*/ return(false); break;
      case TRADE_RETCODE_PRICE_OFF: /*Отсутствуют котировки для обработки запроса*/ return(false); break;
      case TRADE_RETCODE_INVALID_EXPIRATION: /*Неверная дата истечения ордера в запросе*/ return(true); break;
      case TRADE_RETCODE_ORDER_CHANGED: /*Состояние ордера изменилось*/ return(true); break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: /*Слишком частые запросы*/ return(false); break;
      case TRADE_RETCODE_NO_CHANGES: /*В запросе нет изменений*/ return(false); break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: /*Автотрейдинг запрещен сервером*/ return(true); break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: /*Автотрейдинг запрещен клиентским терминалом*/ return(true); break;
      case TRADE_RETCODE_LOCKED: /*Запрос заблокирован для обработки*/ return(true); break;
      case TRADE_RETCODE_FROZEN: /*Ордер или позиция заморожены*/ return(false); break;
      case TRADE_RETCODE_INVALID_FILL: /*Указан неподдерживаемый тип исполнения ордера по остатку */ return(true); break;
      case TRADE_RETCODE_CONNECTION: /*Нет соединения с торговым сервером*/ break;
      case TRADE_RETCODE_ONLY_REAL: /*Операция разрешена только для реальных счетов*/ return(true); break;
      case TRADE_RETCODE_LIMIT_ORDERS: /*Достигнут лимит на количество отложенных ордеров*/ return(true); break;
      case TRADE_RETCODE_LIMIT_VOLUME: /*Достигнут лимит на объем ордеров и позиций для данного символа*/ return(true); break;
      case TRADE_RETCODE_POSITION_CLOSED: /*Позиция с указанным POSITION_IDENTIFIER уже закрыта*/ return(true); break;
      case TRADE_RETCODE_INVALID_CLOSE_VOLUME: /*Закрываемый объем превышает текущий объем позиции*/ return(true); break;
      case TRADE_RETCODE_CLOSE_ORDER_EXIST: /*Для указанной позиции уже есть ордер на закрытие*/ return(true); break;
      case TRADE_RETCODE_LIMIT_POSITIONS: /*Количество открытых позиций, которое можно одновременно иметь на счете, может быть ограничено настройками сервера*/ return(true); break;
      default: /*Неизвестный результат*/ return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+

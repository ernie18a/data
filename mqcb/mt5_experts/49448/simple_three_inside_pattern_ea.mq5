//+------------------------------------------------------------------+
//|                               Simple_Three_Inside_Pattern_EA.mq5 |
//|                                       Copyright 2024, MrBrooklin |
//|                         https://www.mql5.com/ru/users/mrbrooklin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MrBrooklin"
#property link      "https://www.mql5.com/ru/users/mrbrooklin"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ushort Stop_Loss    = 500;  // Стоп-лосс
input ushort Take_Profit  = 500;  // Тейк-профит
input double Lot          = 0.1;  // Лот
input ulong  Magic_Number = 3119; // Магический номер
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
MqlTick             mql_tick;
MqlRates            mql_rates[];
MqlTradeRequest     request;
MqlTradeResult      result;
MqlTradeCheckResult check_result;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(60); // запустим генерацию событий от таймера с указанной периодичностью (60 секунд)
   ArraySetAsSeries(mql_rates, true); // зададим направление индексации элементов в массиве
   return(INIT_SUCCEEDED); // дошли сюда, значит инициализация советника прошла удачно
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reazon)
  {
   EventKillTimer(); // остановим генерацию событий от таймера для данного советника
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Trade_Three_Inside_Pattern(); // торгуем при появлении паттерна "Три изнутри"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade_Three_Inside_Pattern()
  {
   if(PositionsTotal() == 0 && // если общее количество позиций равно нулю
      !PositionSelect(_Symbol)) // и если по текущему символу нет открытых позиций
     {
      int copy_rates = CopyRates(_Symbol, PERIOD_H1, 0, 4, mql_rates); // копируем исторические данные в массив mql_rates
      if(copy_rates > 0) // если исторические данные в массив mql_rates скопированы
        {
         // если сформировался бычий паттерн "Три изнутри"
         if(mql_rates[3].open  >  mql_rates[3].close &&
            mql_rates[2].open  <  mql_rates[2].close &&
            mql_rates[2].open  >  mql_rates[3].low   &&
            mql_rates[2].close <  mql_rates[3].high  &&
            mql_rates[1].open  <  mql_rates[1].close &&
            mql_rates[1].open  >  mql_rates[2].open  &&
            mql_rates[1].open  <  mql_rates[2].close &&
            mql_rates[1].close >  mql_rates[3].high)
            Open_Pos(ORDER_TYPE_BUY); // открываем длинную позицию

         // если сформировался медвежий паттерн "Три изнутри"
         if(mql_rates[3].open  <  mql_rates[3].close &&
            mql_rates[2].open  >  mql_rates[2].close &&
            mql_rates[2].open  <  mql_rates[3].high  &&
            mql_rates[2].close >  mql_rates[3].low   &&
            mql_rates[1].open  >  mql_rates[1].close &&
            mql_rates[1].open  <  mql_rates[2].open  &&
            mql_rates[1].open  >  mql_rates[2].close &&
            mql_rates[1].close <  mql_rates[3].low)
            Open_Pos(ORDER_TYPE_SELL); // открываем короткую позицию
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Pos(ENUM_ORDER_TYPE type)
  {
   if(Check_Margin()) // если свободных средств в валюте депозита достаточно для открытия позиции
     {
      int k = type == ORDER_TYPE_BUY ? 1 : -1;
      double price = type == ORDER_TYPE_BUY ? SymbolInfoDouble(Symbol(), SYMBOL_ASK) :
                     SymbolInfoDouble(Symbol(), SYMBOL_BID);
      ZeroMemory(request);      // обнулим переменную request
      ZeroMemory(result);       // обнулим переменную result
      ZeroMemory(check_result); // обнулим переменную check_result
      //--- установим параметры запроса для совершения торговой операции
      request.action    = TRADE_ACTION_DEAL;                // тип торговой операции
      request.symbol    = _Symbol;                          // символ
      request.volume    = GetLot();                         // объем в лотах
      request.type      = type;                             // тип ордера
      request.price     = price;                            // цена для открытия
      request.sl        = price - Stop_Loss * _Point * k;   // стоп-лосс
      request.tp        = price + Take_Profit * _Point * k; // тейк-профит
      request.deviation = 5;                                // допустимое отклонение от цены
      request.magic     = Magic_Number;                     // MagicNumber ордера
      //---проверка ордера на достаточность средств для совершения торговой операции
      bool check_order = OrderCheck(request,check_result);
      if(check_result.retcode != TRADE_RETCODE_DONE)        // если заявка не выполнена
         Print(check_result.retcode, ":_", check_result.comment); // выведем код ошибки
      //--- отправка запроса на совершение торговой операции
      if(!OrderSend(request,result)) // если отправить запрос не удалось,
         PrintFormat("OrderSend error %d",GetLastError());  // выведем код ошибки
      //--- информация об операции
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
      //--- проверка прошла успешно
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLot()
  {
   double lot = Lot; // объявим и иницализируем переменную lot
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN); // получим min значение лота
   double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX); // получим max значение лота
   if(lot < min_volume) // если заданный лот меньше минимального значения
      lot = min_volume; // переменной lot присвоим min значение лота
   if(lot > max_volume) // если заданный лот больше максимального значения
      lot = max_volume; // переменной lot присвоим max значение лота
   return(lot); // вернём значение лота
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_Margin()
  {
//--- получим цену открытия
   SymbolInfoTick(_Symbol, mql_tick);
   double price = mql_tick.ask;
//--- значения необходимой и свободной маржи
   double margin, free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, GetLot(), price, margin))
     {
      // что-то пошло не так, сообщим и вернем false
      Print("Error in ", __FUNCTION__, " code=", GetLastError());
      return(false);
     }
//--- если не хватает средств на проведение операции
   if(margin > free_margin)
     {
      // сообщим об ошибке и вернем false
      Print("Not enough money! ", "Error code=", GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+

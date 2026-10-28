//+------------------------------------------------------------------+
//|                                   Simple_Pending_Orders_Time.mq5 |
//|                                       Copyright 2024, MrBrooklin |
//|                         https://www.mql5.com/ru/users/mrbrooklin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MrBrooklin"
#property link      "https://www.mql5.com/ru/users/mrbrooklin"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input ushort Trading_Start=15;   //Время начала торговли
input ushort End_Of_Trade=16;    //Время завершения торговли
input ushort Indent=100;         //Отступ отложенных ордеров от текущей цены
input ushort Stop_Loss=200;      //Стоп-лосс
//input ushort Take_Profit=1000;   //Тейк-профит
input double Lots=0.1;           //Лот
input ushort Magic_Number=9462;  //Магический номер (любое число от "1" до "65535")
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
MqlTradeRequest request;          // объявим структуру торгового запроса
MqlTradeResult result;            // объявим структуру результата торгового запроса
MqlTradeCheckResult check_result; // объявим структуру проверки результата торгового запроса
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- запустим генерацию событий от таймера с указанной периодичностью
   EventSetTimer(60);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- остановим генерацию событий от таймера
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(Check_Trading() &&        // если нет препятствий для торговли
      Can_Trade() &&            // если наступило время торговать
      !OrdersTotal() &&         // если нет установленных отложенных ордеров
      !PositionSelect(_Symbol)) // если по текущему символу нет открытых позиций
     {
      Set_Pending_Orders(ORDER_TYPE_BUY_STOP); // установим отложенный ордер BUY STOP
      Set_Pending_Orders(ORDER_TYPE_SELL_STOP); // установим отложенный ордер SELL STOP
     }
   if(!Can_Trade()) // если наступило время завершить торговлю
     {
      Close_All_Positions(); // закрываем все открытые позиции
      Delete_Pending_Orders(); // удаляем все отложенные ордера
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_Trading()
  {
//---
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Print("Ошибка разрешения автоматической торговли на терминале! ",GetLastError());
      return(false);
     }
//---
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Print("Ошибка разрешения автоматической торговли на сервере! ",GetLastError());
      return(false);
     }
//---
   if(!SymbolIsSynchronized(_Symbol))
     {
      Print("Ошибка синхронизированности данных по указанному символу! ",GetLastError());
      return(false);
     }
//--- проверка достаточности средств для торговли
   if(!CheckMoneyForTrade(_Symbol,Lots,ORDER_TYPE_SELL))
     {
      Print("Ошибка проверки достаточности средств для торговли! ",GetLastError());
      return(false);
     }
//--- проверки корректности объёма сделки
   string descript;
   if(!CheckVolumeValue(Lots,descript))
     {
      Print("Ошибка проверки корректности объёма сделки! ",GetLastError());
      return(false);
     }
//--- проверка прошла успешно
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- получим цену открытия
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- значения необходимой и свободной маржи
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- вызовем функцию проверки
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- что-то пошло не так, сообщим и вернем false
      Print("Ошибка в ",__FUNCTION__," Код ошибки = ",GetLastError());
      return(false);
     }
//--- если не хватает средств на проведение операции
   if(margin>free_margin)
     {
      //--- сообщим об ошибке и вернем false
      Print("Не хватает денег на ",EnumToString(type)," ",lots," ",symb," Код ошибки = ",GetLastError());
      return(false);
     }
//--- проверка прошла успешно
   return(true);
  }
//+------------------------------------------------------------------+
//|  Проверяет объем ордера на корректность                          |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {
//--- минимально допустимый объем для торговых операций
   double min_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- максимально допустимый объем для торговых операций
   double max_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- получим минимальную градацию объема
   double volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
//--- проверим на кратность минимальной градации
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Объем не является кратным минимальной градации SYMBOL_VOLUME_STEP=%.2f, \n"
                               "ближайший корректный объем %.2f", volume_step,ratio*volume_step);
      return(false);
     }
   description="Корректное значение объема";
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Can_Trade() // создадим функцию для разрешения торговли в указанном диапазоне времени
  {
   MqlDateTime time_current; // объявим структуру, в которой будем хранить текущее время
   TimeCurrent(time_current); // обновим данные о текущем времени
     {
      // если во входных параметрах задано время начала торговли больше, чем время окончания торговли
      if(Trading_Start-End_Of_Trade>0 &&
         (time_current.hour>=Trading_Start || // если текущее время больше или равно времени начала торговли
          time_current.hour<End_Of_Trade)) // или если текущее время меньше времени окончания торговли
         return true; // возвращаем значение "истина"
      else // в противном случае
         // если во входных параметрах задано время окончания торговли больше, чем время начала торговли
         if(End_Of_Trade-Trading_Start>0 &&
            (time_current.hour>=Trading_Start && // если текущее время больше или равно времени начала торговли
             time_current.hour<End_Of_Trade)) // и если текущее время меньше времени окончания торговли
            return true; // возвращаем значение "истина"
     }
   return false; // если дошли сюда, то тогда возвращаем значение "ложь"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Set_Pending_Orders(ENUM_ORDER_TYPE type) // создадим функцию для установки отложенных ордеров
  {
//--- объявим и инициализируем переменные для хранения цен ask и bid
   double price_ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double price_bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(price_ask>0 && price_bid>0) // если цены ask и bid больше нуля
     {
      int k=type==ORDER_TYPE_BUY_STOP ? 1 : -1;
      double price=type==ORDER_TYPE_BUY_STOP ?
                   price_ask+Indent*_Point :
                   price_bid-Indent*_Point;
      ZeroMemory(request);      // обнулим значение запроса
      ZeroMemory(result);       // обнулим значение результата
      ZeroMemory(check_result); // обнулим значение проверки результата торгового запроса
      // параметры запроса на открытие позиции
      request.action   =TRADE_ACTION_PENDING;                  // тип торговой операции
      request.symbol   =_Symbol;                               // символ
      request.volume   =Lots;                                  // объем в лотах
      request.type     =type;                                  // тип ордера
      request.price    =price;                                 // цена для открытия
      request.sl       =price-Stop_Loss*_Point*k;              // стоп-лосс
      //request.tp       =price+Take_Profit*_Point*k;            // тейк-профит
      request.deviation=5;                                     // допустимое отклонение от цены
      request.magic    =Magic_Number;                          // MagicNumber ордера
      // проверим ордер
      bool check_order=OrderCheck(request,check_result);
      PrintFormat("retcode=%u",check_result.retcode); // выведем информацию на печать
      // отправим запрос
      if(!OrderSend(request,result)) // если отправить запрос не удалось
         PrintFormat("OrderSend error %d",GetLastError()); // выведем код ошибки
      // выведем информацию об операции
      PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Close_All_Positions() // функция для закрытия открытой позиции встречной позицией
  {
//--- объявим и инициализируем переменную для хранения количества открытых позиций
   int total=PositionsTotal();
//--- переберём все открытые позиции
   for(int i=total-1; i>=0; i--)
     {
      // получим необходимые параметры
      ulong  position_ticket=PositionGetTicket(i);                         // тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL);           // символ
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                     // MagicNumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);                    // объем позиции
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // тип позиции
      // выведем информацию о позиции
      PrintFormat("#%I64u %s  %s  %.2f  %s [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  magic);
      // если MagicNumber совпадает
      if(magic==Magic_Number)
        {
         ZeroMemory(request); // обнулим значение запроса
         ZeroMemory(result);  // обнулим значение результата
         // установим параметры для выполнения операции
         request.action   =TRADE_ACTION_DEAL;        // тип торговой операции
         request.position =position_ticket;          // тикет позиции
         request.symbol   =position_symbol;          // символ
         request.volume   =volume;                   // объем позиции
         request.deviation=5;                        // допустимое отклонение от цены
         request.magic    =Magic_Number;             // MagicNumber позиции
         // установим цену и типа ордера в зависимости от типа позиции
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         // выведем информацию о закрытии
         PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         // отправим запрос
         if(!OrderSend(request,result))  // если отправить запрос не удалось
            PrintFormat("OrderSend error %d",GetLastError());  // выведем код ошибки
         // выведем информацию об операции
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Delete_Pending_Orders() // создадим функцию для удаления отложенного ордера
  {
//--- объявим и инициализируем переменную для хранения количества установленных отложенных ордеров
   int total=OrdersTotal();
//--- переберём все установленные отложенные ордера
   for(int i=total-1; i>=0; i--)
     {
      ulong order_ticket=OrderGetTicket(i);     // объявим и инициализируем переменную для тикета
      ulong magic=OrderGetInteger(ORDER_MAGIC); // объявим и инициализируем переменную для MagicNumber
      if(magic==Magic_Number) // если MagicNumber совпадает
        {
         ZeroMemory(request); // обнулим значение запроса
         ZeroMemory(result);  // обнулим значение результата
         // установим параметры операции
         request.action=TRADE_ACTION_REMOVE;    // тип торговой операции
         request.order = order_ticket;          // тикет ордера
         // проверим ордер
         bool check_order=OrderCheck(request,check_result);
         PrintFormat("retcode=%u",check_result.retcode); // выведем инфориацию на печать
         // отправим запрос
         if(!OrderSend(request,result))                        // если отправить запрос не удалось
            PrintFormat("OrderSend error %d",GetLastError());  // выведем код ошибки
         // выведем информация об операции
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                  Simple_Grid.mq5 |
//|                         https://www.mql5.com/ru/users/mrbrooklin |
//+------------------------------------------------------------------+
//--- включим файл для упрощенного доступа к торговому классу CTrade
#include <Trade\Trade.mqh> CTrade trade;
//--- зададим входные параметры советника
input ushort Grid_Step    = 100;    // Шаг сетки отложенных ордеров
input ushort Distance     = 100;    // Дистанция от текущей цены до первого ордера сетки
input ushort Numb_Orders  = 5;      // Количество ордеров в одном направлении
input bool   Type_Limit   = false;  // Установить сетку лимитных ордеров
input ushort Take_Profit  = 100;    // Взять прибыль
input double Fixed_Lot    = 0.01;   // Фиксированный лот
input ulong  Magic_Number = 123456; // Магический номер
//+------------------------------------------------------------------+
int OnInit() {EventSetTimer(60);  trade.SetExpertMagicNumber(Magic_Number); return(INIT_SUCCEEDED);}
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {EventKillTimer();}
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!Check_Trading()) // запустим проверку всех условий, разрешающих торговлю
     {
      Print("Возникла ошибка при проверке условий разрешающих торговлю! ", GetLastError());
      return;
     }
   if(OrdersTotal() > 0 && TimeDelOrders())
      DeletePendingOrders();
   if(OrdersTotal() == 0 && !TimeDelOrders())
     {
      for(int i = 1; i <= Numb_Orders; i++)
         if(!Type_Limit) // если во входных параметрах заданы стоповые отложенные ордера
           {
            double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + Distance * _Point + Grid_Step * i * _Point, _Digits);
            double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - Distance * _Point - Grid_Step * i * _Point, _Digits);
            trade.BuyStop(Fixed_Lot, ask, NULL, 0, ask + Take_Profit * _Point); // установим ордер buy stop
            trade.SellStop(Fixed_Lot, bid, NULL, 0, bid - Take_Profit * _Point); // установим ордер sell stop
           }
         else // в противном случае, если заданы лимитные отложенные ордера
           {
            double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - Distance * _Point - Grid_Step * i * _Point, _Digits);
            double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) + Distance * _Point + Grid_Step * i * _Point, _Digits);
            trade.BuyLimit(Fixed_Lot, ask, NULL, 0, ask + Take_Profit * _Point); // установим ордер buy limit
            trade.SellLimit(Fixed_Lot, bid, NULL, 0, bid - Take_Profit * _Point); // установим ордер sell limit
           }
     }
  }
//+------------------------------------------------------------------+
void DeletePendingOrders()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--) // переберём все установленные отложенные ордера
     {
      ulong  order_ticket = OrderGetTicket(i);     // получим тикет ордера
      ulong  magic = OrderGetInteger(ORDER_MAGIC); // получим Magic Number ордера
      if(magic == Magic_Number)                    // если Magic Number совпадает
        {trade.OrderDelete(order_ticket);}         // удалим ордер с указанным тикетом
     }
  }
//+------------------------------------------------------------------+
bool TimeDelOrders()
  {
   string time_set_orders = "04:00:00"; // зададим время, когда можно устанавливать отложенные ордера
   string time_del_orders = "23:30:00"; // зададим время, когда нужно удалить отложенные ордера
   datetime trade_set = StringToTime(time_set_orders); // преобразуем строку в тип datetime
   datetime trade_del = StringToTime(time_del_orders); // преобразуем строку в тип datetime
   if(TimeCurrent() > trade_del || TimeCurrent() < trade_set) // если текущее время в заданном диапазоне
      return(true); // наступило время удалить отложенные ордера
   return(false);   // время удалять отложенные ордера ещё не наступило
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_Trading()
  {
   ResetLastError();
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
   if(!CheckMoneyForTrade(_Symbol, Fixed_Lot, ORDER_TYPE_SELL))
     {
      Print("Ошибка проверки достаточности средств для торговли! ", GetLastError());
      return(false);
     }
//--- проверки корректности объёма сделки
   string descript;
   if(!CheckVolumeValue(Fixed_Lot, descript))
     {
      Print("Ошибка проверки корректности объёма сделки! ", GetLastError());
      return(false);
     }
//--- проверка прошла успешно
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, ENUM_ORDER_TYPE type)
  {
//--- получим цену открытия
   MqlTick mqltick;
   SymbolInfoTick(symb, mqltick);
   double price = (type == ORDER_TYPE_SELL ? mqltick.bid : mqltick.ask);
//--- значения необходимой и свободной маржи
   double margin, free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- вызовем функцию проверки
   if(!OrderCalcMargin(type, symb, lots, price, margin))
     {
      //--- что-то пошло не так, сообщим и вернем false
      Print("Ошибка в ",__FUNCTION__," Код ошибки = ",GetLastError());
      return(false);
     }
//--- если не хватает средств на проведение операции
   if(margin > free_margin)
     {
      //--- сообщим об ошибке и вернем false
      Print("Не хватает денег на ", EnumToString(type), " ", lots, " ", symb, " Код ошибки = ", GetLastError());
      return(false);
     }
//--- проверка прошла успешно
   return(true);
  }
//+------------------------------------------------------------------+
//|  Проверяет объем ордера на корректность                          |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume, string &description)
  {
//--- минимально допустимый объем для торговых операций
   double min_volume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
     {
      description = StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN = %.2f", min_volume);
      return(false);
     }
//--- максимально допустимый объем для торговых операций
   double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(volume > max_volume)
     {
      description = StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX = %.2f", max_volume);
      return(false);
     }
//--- получим минимальную градацию объема
   double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- проверим на кратность минимальной градации
   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001)
     {
      description=StringFormat("Объем не является кратным минимальной градации SYMBOL_VOLUME_STEP = %.2f, \n"
                               "ближайший корректный объем %.2f", volume_step, ratio*volume_step);
      return(false);
     }
   description = "Корректное значение объема";
   return(true);
  }
//+------------------------------------------------------------------+

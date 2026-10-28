//+------------------------------------------------------------------+
//|                                              Simple_Price_EA.mq5 |
//|                                       Copyright 2024, MrBrooklin |
//|                         https://www.mql5.com/ru/users/mrbrooklin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MrBrooklin"
#property link      "https://www.mql5.com/ru/users/mrbrooklin"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Trade classes                                                    |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh> // включим файл Trade.mqh
CTrade trade; // объявим переменную для упрощенного доступа к торговым функциям
//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
input ushort Check_Bars=60; //Количество баров для анализа поведения цены
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
static double move_up, move_down; // объявим статические переменные move_up и move_down
double Lots=0.1; // объявим и инициализируем переменную для объёма позиции
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(60); // запустим генерацию событий от таймера с указанной периодичностью
   return(INIT_SUCCEEDED); // если дошли сюда, то инициализация прошла успешно
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer(); // остановим генерацию событий от таймера
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(Check_Trading()) // если пройдена проверка всех условий, разрешающих торговлю
     {
      int symb_spread=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD); // объявим и инициализируем переменную для спреда
      double symb_point=SymbolInfoDouble(_Symbol,SYMBOL_POINT); // объявим и инициализируем переменную для пункта
      if(Signal_Up()) // если есть сигнал для открытия длинной позиции
        {
         double price_buy=SymbolInfoDouble(_Symbol,SYMBOL_BID); // объявим и инициализируем переменную для цены Bid
         if(!PositionSelect(_Symbol) &&  // если по текущему символу нет открытых позиций
            price_buy>0 && // если получили цену Bid и она больше нуля
            price_buy==move_up) // если цена Bid достигла значения цены move_up
            trade.Buy(Lots,_Symbol,price_buy,0,price_buy+(50+symb_spread)*symb_point); // откроем длинную позицию
        }
      if(Signal_Down())
        {
         double price_sell=SymbolInfoDouble(_Symbol,SYMBOL_ASK); // объявим и инициализируем переменную для цены Ask
         if(!PositionSelect(_Symbol) &&  // если по текущему символу нет открытых позиций
            price_sell>0 && // если получили цену Sell и она больше нуля
            price_sell==move_down) // если цена Ask достигла значения цены move_down
            trade.Sell(Lots,_Symbol,price_sell,0,price_sell-(50+symb_spread)*symb_point); // откроем короткую позицию
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Check_Trading()
  {
//---
   ResetLastError(); // сбросим переменную _LastError в ноль
   if(trade.ResultRetcodeExternal()==TRADE_RETCODE_MARKET_CLOSED)
     {
      Print("Ошибка: код возврата РЫНОК ЗАКРЫТ! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Print("Ошибка разрешения автоматической торговли на терминале! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
//---
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Print("Ошибка разрешения автоматической торговли на сервере! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
//---
   if(!SymbolIsSynchronized(_Symbol))
     {
      Print("Ошибка синхронизированности данных по указанному символу! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
//--- проверка достаточности средств для торговли
   if(!CheckMoneyForTrade(_Symbol,Lots,ORDER_TYPE_SELL))
     {
      Print("Ошибка проверки достаточности средств для торговли! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
//--- проверки корректности объёма сделки
   string descript;
   if(!CheckVolumeValue(Lots,descript))
     {
      Print("Ошибка проверки корректности объёма сделки! ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
   return(true); // если дошли сюда, то возвратим значение "истина"
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
      return(false); // возвратим значение "ложь"
     }
//--- если не хватает средств на проведение операции
   if(margin>free_margin)
     {
      //--- сообщим об ошибке и вернем false
      Print("Не хватает денег на ",EnumToString(type)," ",lots," ",symb," Код ошибки = ",GetLastError());
      return(false); // возвратим значение "ложь"
     }
   return(true); // если дошли сюда, то возвратим значение "истина"
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
      return(false); // возвратим значение "ложь"
     }
//--- максимально допустимый объем для торговых операций
   double max_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false); // возвратим значение "ложь"
     }
//--- получим минимальную градацию объема
   double volume_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
//--- проверим на кратность минимальной градации
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Объем не является кратным минимальной градации SYMBOL_VOLUME_STEP=%.2f, \n"
                               "ближайший корректный объем %.2f", volume_step,ratio*volume_step);
      return(false); // возвратим значение "ложь"
     }
   description="Корректное значение объема";
   return(true); // если дошли сюда, то возвратим значение "истина"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Signal_Up() // создадим функцию для открытия длинной позиции
  {
   int candles=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0); // получим номер первого видимого бара на графике
   double price_low[]; // создадим массив price_low
   ArraySetAsSeries(price_low,true); // зададим направление индексации в массиве price_low
   CopyLow(_Symbol,PERIOD_M1,0,Check_Bars,price_low); // скопируем минимальные значения цены в массив
   int candle_low = ArrayMinimum(price_low,0,candles); // найдём самую минимальную цену
   MqlRates rates_low[]; // создадим массив rates_low
   ArraySetAsSeries(rates_low,true); // зададим направление индексации в массиве rates_low
   int Data = CopyRates(_Symbol,PERIOD_M1,0,Check_Bars,rates_low); // скопируем необходимые данные в массив
   ObjectDelete(0,"SupprtLine"); // удалим объект с именем SupprtLine с текущего графика
   ObjectCreate(0,"SupprtLine",OBJ_HLINE,0,
                rates_low[candle_low].time,rates_low[candle_low].low, // определим начальную точку линии
                rates_low[0].time,rates_low[0].low); // определим конечную точку линии
   ObjectSetInteger(0,"SupprtLine",OBJPROP_COLOR,clrForestGreen); // зададим цвет линии
   ObjectSetInteger(0,"SupprtLine",OBJPROP_STYLE,STYLE_SOLID); // зададим стиль линии
   ObjectSetInteger(0,"SupprtLine",OBJPROP_WIDTH,3); // зададим толщину линии
   ObjectSetInteger(0,"SupprtLine",OBJPROP_RAY_RIGHT,true); // зададим направление луча рисующего линию
   move_up=rates_low[candle_low].low; // присвоим переменной move_up текущее значение цены low
   return(true);  // если дошли сюда, то возвратим значение "истина"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Signal_Down() // создадим функцию для открытия короткой позиции
  {
   int candles=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0); // получим номер первого видимого бара на графике
   double price_high[]; // создадим массив price_high
   ArraySetAsSeries(price_high,true); // зададим направление индексации в массиве price_high
   CopyHigh(_Symbol,PERIOD_M1,0,Check_Bars,price_high); // скопируем максимальные значения цены в массив
   int candle_high = ArrayMaximum(price_high,0,candles); // найдём самую максимальную цену
   MqlRates rates_high[]; // создадим массив rates_high
   ArraySetAsSeries(rates_high,true); // зададим направление индексации в массиве rates_high
   int Data = CopyRates(_Symbol,PERIOD_M1,0,Check_Bars,rates_high); // скопируем необходимые данные в массив
   ObjectDelete(0,"ResistanceLine"); // удалим объект с именем ResistanceLine с текущего графика
   ObjectCreate(0,"ResistanceLine",OBJ_HLINE,0,
                rates_high[candle_high].time,rates_high[candle_high].high, // определим начальную точку линии
                rates_high[0].time,rates_high[0].high); // определим конечную точку линии
   ObjectSetInteger(0,"ResistanceLine",OBJPROP_COLOR,clrDarkOrange); // зададим цвет линии
   ObjectSetInteger(0,"ResistanceLine",OBJPROP_STYLE,STYLE_SOLID); // зададим стиль линии
   ObjectSetInteger(0,"ResistanceLine",OBJPROP_WIDTH,3); // зададим толщину линии
   ObjectSetInteger(0,"ResistanceLine",OBJPROP_RAY_RIGHT,true); // зададим направление луча рисующего линию
   move_down=rates_high[candle_high].high; // присвоим переменной move_down текущее значение цены high
   return(true); // если дошли сюда, то возвратим значение "истина"
  }
//+------------------------------------------------------------------+

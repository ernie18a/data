//+------------------------------------------------------------------+
//|                                                    TestStops.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"

#include "..\libraries\stdlib.mq4"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  { 
   int    ticket;                                         // номер тикета 
   int    digits   =MarketInfo(Symbol(),MODE_DIGITS);     // сохраним количество знаков
   double volume   =MarketInfo(Symbol(),MODE_MINLOT);     // сохраним минимальный лот
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);  // сохраним минимальный отступ
//---- покажем настройки
   Print("Минимальный лот: ",volume," минимальный отступ: ",stoplevel);
//---- попробуем открыть позицию по рынку с максимально близко 
//---- установленными StopLoss и TakeProfit, покупаем по аску
//---- показываем, что открываться можно с отступом в stoplevel пунктов
   ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,2,
                    NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                    NormalizeDouble(Bid+stoplevel*Point,digits));  // TP
   if(ticket<1) 
     {
      Print("Шаг 1: ошибка ",ErrorDescription(GetLastError())); 
      return(-1); 
     }
//---- выделим только что открытый ордер и обновим рыночное окружение
   if(OrderSelect(ticket,SELECT_BY_TICKET)==false)
     {
      Print("Шаг 2: ошибка ",ErrorDescription(GetLastError())); 
      return(-2);
     }
   RefreshRates();  // обновим рыночное окружение
//---- попробуем модифицировать StopLoss, не трогая TakeProfit
//---- отодвинем стоп-лосс на 2 пипса (может и не получиться, если рынок дернется)
//---- показываем, что TakeProfit не проверяется, если он не изменился
   if(OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()-2*Point,OrderTakeProfit(),0)==false)
     {
      Print("Шаг 3: ошибка ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- удалим стопы, ничего не показываем, просто подготовка к следующему шагу
   if(OrderModify(ticket,OrderOpenPrice(),0,0,0)==false)
     {
      Print("Шаг 4: ошибка ",ErrorDescription(GetLastError())); 
      return(-4);
     }
   RefreshRates();  // обновим рыночное окружение
//---- попробуем снова выставить стопы вплотную к рынку
//---- показываем, что StopLoss и TakeProfit нормально ставятся
   if(OrderModify(ticket,OrderOpenPrice(),
                  NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                  NormalizeDouble(Bid+stoplevel*Point,digits),   // TP
                  0)==false)
     {
      Print("Шаг 5: ошибка ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- тест закончен
   Print("Тест успешно завершен!");
   return(0);
  }
//+------------------------------------------------------------------+
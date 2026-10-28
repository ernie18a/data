//+------------------------------------------------------------------+
//|                                    TypePendingOrderTriggered.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property description "What type of a pending order triggered?"
#property version   "1.001"
//---
bool bln_find_order=false;                // true -> you should look for a order
ulong ul_find_order=0;                    // order ticket
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(bln_find_order) // true -> you should look for a order
     {
      static long counter=0;
      Print("Attempt number ",counter);
      ResetLastError();
      if(HistoryOrderSelect(ul_find_order))
        {
         long type_order=HistoryOrderGetInteger(ul_find_order,ORDER_TYPE);
         if(type_order==ORDER_TYPE_BUY_LIMIT || type_order==ORDER_TYPE_BUY_STOP ||
            type_order==ORDER_TYPE_SELL_LIMIT ||type_order==ORDER_TYPE_SELL_STOP)
           {
            Print("The pending order ",ul_find_order," is found! Type of order is ",
                  EnumToString((ENUM_ORDER_TYPE)HistoryOrderGetInteger(ul_find_order,ORDER_TYPE)));
            bln_find_order=false;         // true -> you should look for a order
            counter=0;
            return;
           }
         else
           {
            Print("The order ",ul_find_order," is not pending");
            bln_find_order=false;         // true -> you should look for a order
            return;
           }
        }
      else
        {
         Print("Order ",ul_find_order," is not find, error#",GetLastError());
        }
      counter++;
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//+------------------------------------------------------------------+
//| TRADE_TRANSACTION_DEAL_*                                         |
//| The following fields in MqlTradeTransaction structure            |
//| are filled for trade transactions related to deals handling      |
//| (TRADE_TRANSACTION_DEAL_ADD, TRADE_TRANSACTION_DEAL_UPDATE       |
//| and TRADE_TRANSACTION_DEAL_DELETE):                              |
//|  •deal - deal ticket;                                            |
//|  •order - order ticket, based on which a deal has been performed;|
//|  •symbol - deal symbol name;                                     |
//|  •type - trade transaction type;                                 |
//|  •deal_type - deal type;                                         |
//|  •price - deal price;                                            |
//|  •price_sl - Stop Loss price (filled, if specified in the order, |
//|  •based on which a deal has been performed);                     |
//|  •price_tp - Take Profit price (filled, if specified             |
//|   in the order, based on which a deal has been performed);       |
//|  •volume - deal volume in lots.                                  |
//|  •position - the ticket of the position that was opened,         |
//|   modified or closed as a result of deal execution.              |
//|  •position_by - the ticket of the opposite position.             |
//|   It is only filled for the out by deals                         |
//|   (closing a position by an opposite one).                       |
//+------------------------------------------------------------------+
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      bln_find_order=true;                // true -> you should look for a order
      ul_find_order=trans.order;
     }
  }
//+------------------------------------------------------------------+

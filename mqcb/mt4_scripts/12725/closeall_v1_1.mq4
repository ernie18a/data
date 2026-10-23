//+------------------------------------------------------------------+
//|                                                      KillAll.mq4 |
//|                                 Copyright © 2015, FlashTrade JFL |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, FlashTrade JFL"
#property version   "1.10"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   for(int x=OrdersTotal()-1;x>=0;x--)
     {
      if(!OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrRed)){ Alert(ErrorDescription(GetLastError())); }
         else Alert("All Closed");
        }
     }
  }
//+------------------------------------------------------------------+

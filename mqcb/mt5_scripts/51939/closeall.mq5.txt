//+------------------------------------------------------------------+
//|                                                     CloseAll.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+--- includes -----------------------------------------------------!
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| start script function                                            |
//+------------------------------------------------------------------+
void OnStart(){
   CTrade trade;
   for(int i=0;i<PositionsTotal();i++){
      ulong tikt = PositionGetTicket(i);
      if(!trade.PositionClose(tikt,ULONG_MAX)){
         Print("CloseAll error :",trade.ResultRetcode());
         return;
         }
         else i--;
      }
   }
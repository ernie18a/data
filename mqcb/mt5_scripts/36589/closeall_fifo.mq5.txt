//+------------------------------------------------------------------+
//|                                                CloseAll_FIFO.mq5 |
//|                                    Copyright 2021, David J. Díez |
//|                         https://www.mql5.com/es/users/davidjdiez |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, David J. Díez Munilla"
#property link      "https://www.mql5.com/en/users/davidjdiez"
#property version   "1.00"
//+--- Libraries ----------------------------------------------------!
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart(){
   CTrade trade;
   for(int i=0;i<PositionsTotal();i++){
      ulong iTicket=PositionGetTicket(i);
      if(!trade.PositionClose(iTicket,ULONG_MAX)){
         Print("PositionClose error ",trade.ResultRetcode());
         return;
         }
      else{i--;}
      }
   }
//+--------------------------------------------------------- End. ---+
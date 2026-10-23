//+------------------------------------------------------------------+
//|                                             closeall_pending.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property description "closes all pending orders regardless of any other properties such as "
#property description "order symbol,order type, or order profit/loss"
#include <order_exit.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
  {
//---   
   while(closeAllPending()){}
  }
//+------------------------------------------------------------------+
bool closeAllPending()
  {
   int not_closed=0;
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,true,-1,NULL,ALL_PENDING))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+

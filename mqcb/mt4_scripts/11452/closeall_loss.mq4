//+------------------------------------------------------------------+
//|                                                closeall_loss.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property show_inputs

#property description "closes all orders upon going beyond the loss threshold,"
#property description "the loss value should be expressed in absolute value"
#property description "if the absolute value of loss is greater than the absolute value of order profit,"
#property description "the order would be deleted"

#include <order_exit.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input double order_loss=10.0; //order loss (absolute value)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   while(closeAllLoss()){}
  }
//+------------------------------------------------------------------+
bool closeAllLoss()
  {
   int not_closed=0;
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,true,-1,NULL,ALL_MARKET,order_loss,-1))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               closeall_magic.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property show_inputs
#property description "closes all orders by magic number"
#property description "if magic number matches the order magic number, the order will be deleted/closed"

#include <order_exit.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input int order_magic=0; //order aagic number
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   while(closeAllMagic()){}
  }
//+------------------------------------------------------------------+
bool closeAllMagic()
  {
   int not_closed=0;
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,true,order_magic))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+

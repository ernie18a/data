//+------------------------------------------------------------------+
//|                                             closeall_comment.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict

#property description "closes all orders by comment"
#property description "if comment matches the order comment, the order will be deleted/closed"

#include <order_exit.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input string order_comment=NULL; // order comment
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---   
   while(closeAllComment()){}
  }
//+------------------------------------------------------------------+
bool closeAllComment()
  {
   int not_closed=0;
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,true,-1,NULL,ALL,-1,-1,order_comment))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+

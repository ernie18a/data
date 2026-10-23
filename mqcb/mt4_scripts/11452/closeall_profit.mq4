//+------------------------------------------------------------------+
//|                                              closeall_profit.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property show_inputs
#property description "closes all orders upon going beyond the profit threshold,"
#property description "if the absolute value of profit is less than the absolute value of order profit,"
#property description "the order would be deleted"


#include <order_exit.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input double order_profit=10.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---   
   while(closeAllProfit()){}
  }
//+------------------------------------------------------------------+
bool closeAllProfit()
  {
   int not_closed=0;
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,true,-1,NULL,ALL_MARKET,-1,order_profit))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+

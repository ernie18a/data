//+------------------------------------------------------------------+
//|                                            onTrade Event handler |
//|                                  Copyright 2024, Yashar Seyyedin |
//|                    https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property strict
#include <Arrays/ArrayInt.mqh>
CArrayInt *tickets;

//+------------------------------------------------------------------+
//| Initiate tickets array with all orders at EA initiation          |
//+------------------------------------------------------------------+
int OnInit()
  {
   tickets=new CArrayInt();
   for(int i=0; i<OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS)==true)
         if(OrderType()<2)
            tickets.Add(OrderTicket());
         
   tickets.Sort();
   EventSetMillisecondTimer(100);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Release memory and timer                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete tickets;
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//| Check if there are any new or removed(closed) orders             |
//+------------------------------------------------------------------+
void OnTimer()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS)==false)
         continue;
      if(OrderType()>1) 
         continue;
      if(tickets.Search(OrderTicket())<0)
        {
         tickets.Add(OrderTicket());
         tickets.Sort();
         onTradeEntry(OrderTicket());
        }
     }
   for(int i=tickets.Total()-1; i>=0; i--)
     {
      if(OrderSelect(tickets.At(i), SELECT_BY_TICKET)==false)
         continue;
      if(OrderCloseTime()!=0)
        {
         tickets.Delete(i);
         tickets.Sort();
         onTradeExit(OrderTicket());
         if(OrderType()==OP_BUY && OrderClosePrice()<=OrderStopLoss() && OrderStopLoss()!=0)
            onStopLoss(OrderTicket());
         if(OrderType()==OP_SELL && OrderClosePrice()>=OrderStopLoss() && OrderStopLoss()!=0)
            onStopLoss(OrderTicket());
         if(OrderType()==OP_BUY && OrderClosePrice()>=OrderTakeProfit() && OrderTakeProfit()!=0)
            onTakeProfit(OrderTicket());
         if(OrderType()==OP_SELL && OrderClosePrice()<=OrderTakeProfit() && OrderTakeProfit()!=0)
            onTakeProfit(OrderTicket());
        }
     }
  }

//+------------------------------------------------------------------+
//| Event handler when stop loss is hit                              |
//+------------------------------------------------------------------+
void onStopLoss(ulong ticket)
  {
   Print("SL Hit! ");
   Print("==> Ticket: ", OrderTicket());
   Print("==> Symbol: ", OrderSymbol());
  }

//+------------------------------------------------------------------+
//| Event handler when take profit is hit                            |
//+------------------------------------------------------------------+
void onTakeProfit(ulong ticket)
  {
   Print("TP Hit! ");
   Print("==> Ticket: ", OrderTicket());
   Print("==> Symbol: ", OrderSymbol());
  }

//+------------------------------------------------------------------+
//| Event handler when a new order is opened                         |
//+------------------------------------------------------------------+
void onTradeEntry(ulong ticket)
  {
   Print("Order opened!");
   Print("==> Ticket: ", OrderTicket());
   Print("==> Symbol: ", OrderSymbol());
   Print("==> OrderType: ", OrderTypeString());
  }

//+------------------------------------------------------------------+
//| Event handler when an order is closed(removed)                   |
//+------------------------------------------------------------------+
void onTradeExit(ulong ticket)
  {
   Print("Order closed!");
   Print("==> Ticket: ", OrderTicket());
   Print("==> Symbol: ", OrderSymbol());
   Print("==> OrderType: ", OrderTypeString());
  }

//+------------------------------------------------------------------+
//| String value of OrderType                                        |
//+------------------------------------------------------------------+
string OrderTypeString()
  {
   switch(OrderType())
     {
      case OP_BUY:
         return "BUY";
      case OP_SELL:
         return "SELL";
     }
   return "";
  }
//+------------------------------------------------------------------+

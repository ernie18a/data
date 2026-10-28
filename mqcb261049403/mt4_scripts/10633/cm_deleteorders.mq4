//+------------------------------------------------------------------+
//|                                         Close pending orders.mq4 |
//|                               Copyright © 2012, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Vladimir Hlystov"
#property link      "http://cmillion.narod.ru"
extern bool comment = true;  //display information on screen
//+------------------------------------------------------------------+
int start()
  {
   int n,Ticket;
   string txt=StringConcatenate("The script removes all pending orders, the start ",TimeToStr(TimeCurrent(),TIME_SECONDS));
   if (comment) Comment(txt);
   for (int j = OrdersTotal(); j >=0 ; j--)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderType()>1)
         {
            Ticket = OrderTicket();
            while(true)
            {
               if (OrderDelete(Ticket))
               { 
                  txt = StringConcatenate(txt,"\nOrderDelete ",Ticket);
                  break;
               }
               else
               {
                  n++;
                  if (n>10) break;
                  Sleep(1000);
                  RefreshRates();
                  txt = StringConcatenate(txt,"\nOrderDelete error ",GetLastError()," Ticket ",Ticket);
               }
            }
         }
      }
      if (comment) Comment(txt);
   }
   if (comment) Comment(txt,"\nThe script has finished its work ",TimeToStr(TimeCurrent(),TIME_SECONDS));
   return(0);
  }
//+------------------------------------------------------------------+
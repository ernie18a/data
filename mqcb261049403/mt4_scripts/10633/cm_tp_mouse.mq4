//+------------------------------------------------------------------+
//|                                                     TP Mause.mq4 |
//|                                Copyright © 2012 Vladimir Hlystov |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012"
#property link      "http://cmillion.narod.ru"
extern bool    comment           = true;  //display information on screen
//+------------------------------------------------------------------+
int start()
  {
   int Ticket;
   double value = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("script exhibiting TP ",DoubleToStr(value,Digits)," start ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      
      Ticket = OrderTicket();
      if(OrderType()==OP_BUY)     
      if(value>Ask) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(),value ,OrderExpiration(),White))
            txt = StringConcatenate(txt,"\nSet TP ",DoubleToStr(value,Digits)," BUY order ",Ticket);
         else txt = StringConcatenate(txt,"\nError ",GetLastError()," TP BUY order ",Ticket);
      }
      
      if(OrderType()==OP_SELL)
      if(value<Bid) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(), value,OrderExpiration(),White))   
            txt = StringConcatenate(txt,"\nSet TP ",DoubleToStr(value,Digits)," SELL order ",Ticket);
         else txt = StringConcatenate(txt,"\nError ",GetLastError()," TP SELL order ",Ticket);
      }
         
      if((OrderType()==OP_BUYSTOP) || (OrderType()==OP_BUYLIMIT))     
      if(value>OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(), value,OrderExpiration(),White)) 
            txt = StringConcatenate(txt,"\nSet TP ",DoubleToStr(value,Digits)," placing BUY  order ",Ticket);
         else txt = StringConcatenate(txt,"\nError ",GetLastError()," TP placing BUY order ",Ticket);
      }
       
      if((OrderType()==OP_SELLSTOP) || (OrderType()==OP_SELLLIMIT))
      if(value<OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),OrderStopLoss(), value,OrderExpiration(),White))                
            txt = StringConcatenate(txt,"\nSet TP ",DoubleToStr(value,Digits)," placing SELL order ",Ticket);
         else txt = StringConcatenate(txt,"\nError ",GetLastError()," TP placing SELL order ",Ticket);
      }
      if (comment) Comment(txt);
   }   
   if (comment) Comment(txt,"\nThe script has finished its work ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                    EaTemplate.mq4|
//|                                          Jacek Dzambuіat-Colojew |
//|                                                jacekdc@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Jacek Dzambuіat-Colojew"
#property link      "jacekdc@gmail.com"
#property version   "2.00"

input double Lot = 1;
input bool AutoLots = False;
input int TakeProfit = 1000;
input int StopLoss = 500;
input int TrailingStart = 200;
input int TrailingStop = 150;
input int Ba = 100;
input int Slippage = 3;
input int MaxOrders = 1;
input int Magic = 666;
input int Pips = 10;
input int Mins = 30;
input int PERIOD = 15;
input int Candles = 8;
input int shift = 1;
input int MaxSpread = 20;

int Ticket, LastOrder = 2;
double lows, highs, low, high, range;

int start() {
   int m = 0;

   for ( int n = 0; n < OrdersTotal(); n++ ) {

      if ( OrderSelect ( n, SELECT_BY_POS ) ) {  

         if ( OrderSymbol() == Symbol() ) {    
         
            if ( OrderMagicNumber() == Magic ) {

               Ticket = OrderTicket();  
               if ( OrderSelect ( Ticket, SELECT_BY_TICKET ) == True ) { close(); }
               m++;
               
            }
            
         }

      }

   }
  
   if ( m == 0 ) { LastOrder = 2; }
   if ( m < MaxOrders ) { open(); }
  
return ( 0 );
}

int Scan ( int time, int period, int shifte ) {
   for ( int n = shifte; n < time; n++ ) {    
  
      lows = iLow(NULL, period, n);
      highs = iHigh(NULL, period, n);
  
      if ( n == shifte ) {
      
         low = lows;
         high = highs;    
        
      } else {
      
         if ( low >= lows ) { low = lows; }
         if ( high <= highs ) { high = highs; }
      
      }  
   }
  
   range = high - low;
  
return ( 0 );
}

int open() {  

   double Lots;

   Scan ( Candles, PERIOD, shift );
   double BackHigh = high;
   double BackLow = low;
   double BackRange = range;
  
   if ( AutoLots == False ) { Lots = Lot; }
   else { Lots = MathRound ( AccountBalance() / 100 ) / 100; }
  
   RefreshRates();
   
   if ( ( Ask - Bid ) / Point < MaxSpread ) { 
   
      if ( 1 == 0 && LastOrder != 1 ) {
         Ticket = OrderSend ( Symbol(), OP_BUY, Lots, Ask, Slippage, Ask - ( StopLoss * Point ), Ask + ( TakeProfit * Point ), NULL, Magic, 0, Green);
         LastOrder = 1;
      }
   
      if ( 1 == 0 && LastOrder != 1 ) {
         Ticket = OrderSend ( Symbol(), OP_BUYSTOP, Lots, Ask + ( Pips * Point ), Slippage, Ask + ( Pips * Point ) - ( StopLoss * Point ), Ask - ( Pips * Point ) + ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Green);
         LastOrder = 1;
      }
   
      if ( 1 == 0 && LastOrder != 0 ) {
         Ticket = OrderSend ( Symbol(), OP_SELL, Lots, Bid, Slippage, Bid + ( StopLoss * Point ), Bid - ( TakeProfit * Point ), NULL, Magic, 0, Red);
         LastOrder = 0;
      }
   
      if ( 1 == 0 && LastOrder != 0 ) {
         Ticket = OrderSend ( Symbol(), OP_SELLSTOP, Lots, Bid - ( Pips * Point ) , Slippage, Bid - ( Pips * Point ) + ( StopLoss * Point ), Bid + ( Pips * Point ) - ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Red);
         LastOrder = 0;
      }
   
   }

return ( 0 );
}

int close() {

   if ( OrderType() == OP_BUY ) {
    
         RefreshRates();
         if ( Bid >= OrderOpenPrice() + TrailingStart * Point && OrderStopLoss() < Bid - ( TrailingStop * Point ) ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), Bid - ( TrailingStop * Point ), OrderTakeProfit() , 0 );
         }
         
         if ( Bid >= OrderOpenPrice() + Ba * Point && Bid < OrderOpenPrice() + ( Ba + 5 ) * Point ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + ( 10 * Point ), OrderTakeProfit() , 0 );                
         } 
        
         if ( 1 == 0 ) {
            Ticket = OrderClose ( Ticket, OrderLots(), OrderClosePrice(), Slippage, Green );
         }           
      }
  
   if ( OrderType() == OP_SELL ) {
    
         RefreshRates();
         if ( Ask <= OrderOpenPrice() - TrailingStart * Point && OrderStopLoss() > Ask + ( TrailingStop * Point ) ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), Ask + ( TrailingStop * Point ), OrderTakeProfit(), 0 );
         }  
          
         if ( Ask <= OrderOpenPrice() - Ba * Point &&  Ask > OrderOpenPrice() - ( Ba + 5 ) * Point  ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - ( 10 * Point ) , OrderTakeProfit(), 0 );
         }           

         if ( 1 == 0 ) {
            Ticket = OrderClose ( Ticket, OrderLots(), OrderClosePrice(), Slippage, Red );
         }        
      }    

return ( 0 );
}
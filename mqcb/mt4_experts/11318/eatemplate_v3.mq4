//+------------------------------------------------------------------+
//|                                                    EaTemplate.mq4|
//|                                          Jacek Dzambuіat-Colojew |
//|                                                jacekdc@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Jacek Dzambuіat-Colojew"
#property link      "jacekdc@gmail.com"
#property version   "1.00"

input double Lot = 0.1;
input bool AutoLots = False; // if its True it will automatically calculate Lot based on Accont Balance. Go down to open() function to see how does it work.
input int TakeProfit = 1000;
input int StopLoss = 500;
input int TrailingStart = 200; // 200 mean tralingstop will start to work above 200 pips
input int TrailingStop = 150; // 150 mean it will move 150 pips above current order price
input int Ba = 100; // BA at 100 mean, that order stop loss will be moved at open price + spread to make order safe.
input int Slippage = 3;
input int MaxOrders = 1; // How many orders script can open on current symbol
input int Magic = 666; // Magic number
input int Pips = 10; // How far ( in pips ) from actual price sellstop / buystop order will be placed.
input int Mins = 30; // Lifetime of buystop / sellstop order ( in minutes ) after it is deleted if not reached open price. 
input int PERIOD = 15; // 15 mean it will work on M15, for exampe PERIOD = 240 mean it will work on H4
input int Candles = 8; // Number of candles scanned in Scan() function, which shows the highes and the lowest order price in the past.
input int shift = 1; // Shift = 1 mean it will start to scan from previous candle.
input int MaxSpread = 20; // If spread is above 20, orders will not be opened

int Ticket, LastOrder = 2; // LastOrder = 2 mean script can make sell and buy orders. 0 mean it can only buy. 1 mean it can only sell.
double lows, highs, low, high, range; // To learn how does LastOrder works look down in open() script.
// low, high and range are used in Scan Loop which calculate the highest and the lowest Order Price in the past. Range show how many pips are beetwen high and low value

int start() { // Executed when there is new tick.

   int m = 0; // m is a number of opened orders on current symbol.

   for ( int n = 0; n < OrdersTotal(); n++ ) {  // That loop search if there is opened order on current symbol.

      if ( OrderSelect ( n, SELECT_BY_POS ) ) {  

         if ( OrderSymbol() == Symbol() ) {  
         
            if ( OrderMagicNumber() == Magic ) {  
   
               Ticket = OrderTicket();  
               if ( OrderSelect ( Ticket, SELECT_BY_TICKET ) == True ) { close(); } // If it found opened order, script jump to close() function which close orders and make trailing stops.
               m++;
               
            }

         }

      }

   }
  
   if ( m == 0 ) { LastOrder = 2; } // If there are no orders script LastOrder = 2 which allow script to sell and buy
   if ( m < MaxOrders ) { open(); } // If MaxOrders are not reached it allow script to open one more order in order() function.
  
return ( 0 );
}
// time is a number of candles which are scanned
// period is a time of 1 candle. For ex. if period = 15 it will work on M15 candles.
// shifte = 1 mean it will start to scan from previous candle.
int Scan ( int time, int period, int shifte ) { // That loop calculate the highest and the lowest order price with range, which show how many pips are beetwen high and low value
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

   Scan ( Candles, PERIOD, shift ); // Here is example how to find the lowest, the highest value and range in the past.
   double BackHigh = high;
   double BackLow = low;
   double BackRange = range;
  
   if ( AutoLots == False ) { Lots = Lot; }
   else { Lots = MathRound ( AccountBalance() / 100 ) / 100; } // First 100 say, that every 100$ will will increase lot by 1 point.
                                                               // Second 100 say, that 1 point is equal to 0.01 lot
   // Here you can place indicators and all stuff              // For ex. if you want to play 0.5 Lot with 1000$ account you can write MathRound ( AccountBalance() / 20 ) / 100;
   // Which will calculate when script should buy or sell.
  
   RefreshRates();  // RefreshRate() update Bid and Ask value.
  
   if ( ( Ask - Bid ) / Point < MaxSpread ) { // Checking, if spread is less than MaxSpread from inputs. If its Bigger, orders wont open
  
      // Replace 1 == 0 to your conditions to buy order.
      if ( 1 == 0 && LastOrder != 1 ) { // LastOrder!= 1 prevent script from making a lot of same buy orders
         Ticket = OrderSend ( Symbol(), OP_BUY, Lots, Ask, Slippage, Ask - ( StopLoss * Point ), Ask + ( TakeProfit * Point ), NULL, 0, 0, Green);
         LastOrder = 1; // It prevent script from making a lot of same buy orders
      }
   
      // Replace 1 == 0 to your conditions to buystop order.
      if ( 1 == 0 && LastOrder != 1 ) {  // LastOrder!= 1 prevent script from making a lot of same buystop orders
         Ticket = OrderSend ( Symbol(), OP_BUYSTOP, Lots, Ask + ( Pips * Point ), Slippage, Ask + ( Pips * Point ) - ( StopLoss * Point ), Ask - ( Pips * Point ) + ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Green);
         LastOrder = 1; // It prevent script from making a lot of same buy orders
      }
  
      // Replace 1 == 0 to your conditions to sell order.
      if ( 1 == 0 && LastOrder != 0 ) { // LastOrder!= 0 prevent script from making a lot of same sell orders
         Ticket = OrderSend ( Symbol(), OP_SELL, Lots, Bid, Slippage, Bid + ( StopLoss * Point ), Bid - ( TakeProfit * Point ), NULL, 0, 0, Red);
         LastOrder = 0; // It prevent script from making a lot of same sell orders
      }
   
      // Replace 1 == 0 to your conditions to sellstop order.
      if ( 1 == 0 && LastOrder != 0 ) {  // LastOrder!= 0 prevent script from making a lot of same sellstop orders
         Ticket = OrderSend ( Symbol(), OP_SELLSTOP, Lots, Bid - ( Pips * Point ) , Slippage, Bid - ( Pips * Point ) + ( StopLoss * Point ), Bid + ( Pips * Point ) - ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Red);
         LastOrder = 0; // It prevent script from making a lot of same sell orders
      }
      
   }

return ( 0 );
}

int close() { // Close is executed when script find opened order on current symbol

   // Here you can place indicators, candle scan and other stuff to set condicions for closing the order.

   if ( OrderType() == OP_BUY ) {
    
         RefreshRates(); // RefreshRate() update Bid and Ask value.
         // Calculate Trailing Stop.
         if ( Bid >= OrderOpenPrice() + TrailingStart * Point && OrderStopLoss() < Bid - ( TrailingStop * Point ) ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), Bid - ( TrailingStop * Point ), OrderTakeProfit() , 0 );
         }    
         // Calculate BA.          
         if ( Bid >= OrderOpenPrice() + Ba * Point && Bid < OrderOpenPrice() + ( Ba + 5 ) * Point ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + ( 10 * Point ), OrderTakeProfit() , 0 );                
         } 
         
         // Replace 1 == 0 to conditions to close Buy order.
         if ( 1 == 0 ) {
            Ticket = OrderClose ( Ticket, OrderLots(), OrderClosePrice(), Slippage, Green );
         }    
          
      }
  
   if ( OrderType() == OP_SELL ) {
    
         RefreshRates(); // RefreshRate() update Bid and Ask value.
         // Calculate Trailing Stop.
         if ( Ask <= OrderOpenPrice() - TrailingStart * Point && OrderStopLoss() > Ask + ( TrailingStop * Point ) ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), Ask + ( TrailingStop * Point ), OrderTakeProfit(), 0 );
         }  
         // Calculate BA.
         if ( Ask <= OrderOpenPrice() - Ba * Point &&  Ask > OrderOpenPrice() - ( Ba + 5 ) * Point  ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - ( 10 * Point ) , OrderTakeProfit(), 0 );
         } 
         
         // Replace 1 == 0 to conditions to close Sell order.
         if ( 1 == 0 ) {
            Ticket = OrderClose ( Ticket, OrderLots(), OrderClosePrice(), Slippage, Red );
         }    
          
      }    
      
  
  
return ( 0 );
}
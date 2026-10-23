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
input int adxint = 14;
input int adxsignal = 5;
input int MaxSpread = 20;

//ADX indicator values used in my script;

// My ea is just example made only to help you understand my script, not to win. REMEMBER THAT!!!
// I dont mind using my template to code working scripts based on my work. Feel free to use it but do not sell it!

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
   
   // Here are some indicators used as values to open trades
   // Remember, that you can also use iCutom values to use custom indicators, but my template is not tutorial how to use that :)
   // I used adx indicator, last number represents shift from actual candle. For example 0 means actual candle value. 1 means value from last candle etc.
   
   double adx = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_MAIN, 0);
   double adxplus = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_PLUSDI, 0);
   double adxminus = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_MINUSDI, 0);
   double adxpluslast = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_PLUSDI, 2);
   double adxminuslast = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_MINUSDI, 2);
   
   
   // I have deleted buy and sell trader to show, how buystop/sellstop works. After that, buy and sell stops will be even easier that buystops / sellstops to understand.
   
      if ( ( Ask - Bid ) / Point < MaxSpread ) {  
   
      if ( adx > adxsignal && adxplus > adxminus && adxpluslast < adxminuslast && LastOrder != 1 ) {
         Ticket = OrderSend ( Symbol(), OP_BUYSTOP, Lots, Ask + ( Pips * Point ), Slippage, Ask + ( Pips * Point ) - ( StopLoss * Point ), Ask - ( Pips * Point ) + ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Green);
         LastOrder = 1;
      }
   
      if ( adx > adxsignal && adxplus < adxminus && adxpluslast > adxminuslast && LastOrder != 0 ) {
         Ticket = OrderSend ( Symbol(), OP_SELLSTOP, Lots, Bid - ( Pips * Point ) , Slippage, Bid - ( Pips * Point ) + ( StopLoss * Point ), Bid + ( Pips * Point ) - ( TakeProfit * Point ), NULL, Magic, TimeCurrent() + ( 60 * Mins ), Red);
         LastOrder = 0;
      }

   }

return ( 0 );
}

int close() {
   double adxplus = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_PLUSDI, 0);
   double adxminus = iADX(NULL, PERIOD, adxint, PRICE_CLOSE, MODE_MINUSDI, 0);

   if ( OrderType() == OP_BUY ) {
    
         RefreshRates();
         if ( Bid >= OrderOpenPrice() + TrailingStart * Point && OrderStopLoss() < Bid - ( TrailingStop * Point ) ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), Bid - ( TrailingStop * Point ), OrderTakeProfit() , 0 );
         }
         
         if ( Bid >= OrderOpenPrice() + Ba * Point && Bid < OrderOpenPrice() + ( Ba + 5 ) * Point ) {
            Ticket = OrderModify ( OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + ( 10 * Point ), OrderTakeProfit() , 0 );                
         } 
        
         // I also use adx to close orders ( just to show you, that there is so much ways to close opened order ).
         if ( adxplus < adxminus ) {
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
            
         // I also use adx to close orders ( just to show you, that there is so much ways to close opened order ).
         if ( adxplus > adxminus ) {
            Ticket = OrderClose ( Ticket, OrderLots(), OrderClosePrice(), Slippage, Red );
         }        
      }    

return ( 0 );
}
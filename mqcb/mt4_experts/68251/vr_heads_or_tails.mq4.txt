//+------------------------------------------------------------------+
//|                                            VR Heads or Tails.mq4 |
//|                                      Copyright 2026, Trading-Go. |
//+------------------------------------------------------------------+
#property copyright "@ Voldemar"                                       // Copyright information shown in terminal
#property link      "https://www.mql5.com/en/channels/tradingo-go-en"  // 
#property version   "26.010"                                           // Version number of the Expert Advisor
#property strict                                                       // Enables strict code compilation mode
// --- Input parameters (configurable by user) ---
input double  iStartLots    = 0.01;   // Initial trade volume (lot size)
input int     iTakeProfit   = 450;    // Take Profit distance in points
input int     iStopLoss     = 390;    // Stop Loss distance in points
input int     iMagicNumber  = 227;    // Unique identifier for this EA's trades
input int     iSlippage     = 30;     // Maximum allowed slippage in points

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// ---
   MathSrand(GetTickCount());                         // Seed the random number generator with current system time
// ---
   return(INIT_SUCCEEDED);                            // Return success code to terminal
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// --- Count open positions managed by this EA ---
   int total = OrdersTotal(), b = 0, s = 0;     // total = number of all orders, b = buy count, s = sell count

// Loop through all existing orders
   for(int i = 0; i < total; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) // Select order by position index from open trades
         if(OrderSymbol() == _Symbol)              // Check if order is for current symbol
            if(OrderMagicNumber() == iMagicNumber) // Check if order belongs to this EA (by magic number)
              {
               if(OrderType() == OP_BUY)           // If it's a buy order
                  b++;                             // Increment buy counter

               if(OrderType() == OP_SELL)          // If it's a sell order
                  s++;                             // Increment sell counter
              }

   int ticket = -1;  // Variable to store order ticket number

   if(CheckVolumeValue(iStartLots)) // Checking the trading volume
      // If no open positions exist for this EA (b+s=0)
      if((b + s) == 0)
         // Randomly decide trade direction (like flipping a coin)
         if(MathRand() % 2 == 0)                     // If random number is even -> BUY
           {
            // Send BUY order with specified parameters
            ticket = OrderSend(Symbol(),OP_BUY,iStartLots,Ask,iSlippage,
                               Ask - iStopLoss * _Point,       // Stop Loss price (current Ask minus SL distance)
                               Ask + iTakeProfit * _Point,     // Take Profit price (current Ask plus TP distance)
                               "VR Heads or Tails",            // Order comment
                               iMagicNumber,0,clrBlue);        // Magic number, expiration, blue arrow color

            // Check if order was successfully placed
            if(ticket<0)
               Print("OrderSend failed with an error #",GetLastError());  // Print error if failed
            else
               Print("The OrderSend function has been completed successfully");  // Success message
           }
         else  // If random number is odd -> SELL
           {
            // Send SELL order with specified parameters
            ticket = OrderSend(Symbol(),OP_SELL,iStartLots,Bid,iSlippage,
                               Bid + iStopLoss * _Point,       // Stop Loss price (current Bid plus SL distance)
                               Bid - iTakeProfit * _Point,     // Take Profit price (current Bid minus TP distance)
                               "VR Heads or Tails",            // Order comment
                               iMagicNumber,0,clrRed);         // Magic number, expiration, red arrow color

            // Check if order was successfully placed
            if(ticket<0)
               Print("OrderSend failed with an error #",GetLastError());  // Print error if failed
            else
               Print("The OrderSend function has been completed successfully");  // Success message
           }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  // Called when EA is removed from chart
  {
// No cleanup operations needed in this EA
  }
//+------------------------------------------------------------------+
//|  Checks order volume for correctness                            |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume)
  {
//--- minimum allowed volume for trading operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
      return(false);

//--- maximum allowed volume for trading operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
      return(false);

//--- get minimum volume increment step
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
      return(false);
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               VR Locker Lite.mq4 |
//|                                      Copyright 2025, Trading-Go. |
//+------------------------------------------------------------------+
#property copyright "@ Voldemar"                                      // Copyright information
#property link      "https://www.mql5.com/en/channels/tradingo-go-en" //
#property version   "26.010"                                          // Expert Advisor version
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double  iStartLots   = 0.01; // Initial trading volume (lot size)
input double  iMultiplier  = 2.0;  // Multiplier for increasing position volume
input double  iProfitPlus  = 30;   // Profit target in points to add to average price
input int     iStep        = 200;  // Distance in points for adding to losing positions
input int     iMagicNumber = 227;  // Unique identifier for EA's positions
input int     iSlippage    = 30;   // Maximum allowed slippage in points
double lt = 0;                     // Variable for calculated lot size
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");
   lt = iStartLots;


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int total = ::OrdersTotal(), b = 0, s = 0;                       // Get total positions, initialize buy/sell counters
   double   BuyPricSumm = 0,   SelPricSumm = 0, BuyLotsSumm = 0, SelLotsSumm = 0; // Variables for price and volume sums

   double   BuyLowPrice = 0,   SelHigtPrice = 0;                       // Track lowest buy and highest sell prices
   double   BuyLowLots  = 0,   SelHigtLots  = 0;                       // Track volumes at those prices

   if(Bid <= 0 || Ask <= 0)                                            // Check for invalid prices
      return;                                                          // Exit if prices are invalid

// Loop through all positions to analyze current portfolio
   for(int i = 0; i < total; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                     // Select position by index
         if(OrderSymbol() == _Symbol)                                  // Check if position is for current symbol
            if(OrderMagicNumber() == iMagicNumber)                     // Check if position belongs to this EA
               if(OrderType() == OP_BUY)                               // Check if position is BUY
                 {
                  b++;                                                 // Increment buy position counter
                  BuyPricSumm += OrderOpenPrice() * OrderLots();       // Add weighted open price (price * volume)
                  BuyLotsSumm += OrderLots();                          // Add buy volume to total

                  if(OrderOpenPrice() < BuyLowPrice || BuyLowPrice == 0) // Find lowest buy price
                    {
                     BuyLowPrice = OrderOpenPrice();                   // Update lowest buy price
                     BuyLowLots = OrderLots();                         // Store volume at lowest price
                    }
                 }
               else
                  if(OrderType() == OP_SELL)                           // Check if position is SELL
                    {
                     s++;                                              // Increment sell position counter
                     SelPricSumm += OrderOpenPrice() * OrderLots();    // Add weighted open price for sells
                     SelLotsSumm += OrderLots();                       // Add sell volume to total

                     if(OrderOpenPrice() > SelHigtPrice || SelHigtPrice == 0) // Find highest sell price
                       {
                        SelHigtPrice = OrderOpenPrice();               // Update highest sell price
                        SelHigtLots = OrderLots();                     // Store volume at highest price
                       }
                    }
// ===
//
// ===
   int ticket = -1;  // Variable to store order ticket number
// BUY position management logic
   if(b == 0)                                                          // If no buy positions exist
      if(CheckVolumeValue(lt))                                         // Checking the trading volume
        {
         // Send BUY order with specified parameters
         ticket = OrderSend(Symbol(),OP_BUY,lt,Ask,iSlippage,
                            0,                                            // Stop Loss price
                            0,                                            // Take Profit price
                            "VR Locker Lite",                             // Order comment
                            iMagicNumber,0,clrBlue);                      // Magic number, expiration, blue arrow color

         // Check if order was successfully placed
         if(ticket<0)
            Print("OrderSend failed with an error #",GetLastError());     // Print error if failed
         else
            Print("The OrderSend function has been completed successfully");  // Success message
         return;                                                          // Exit after opening position
        }



   if(b > 0)                                                              // If buy positions exist
      if((BuyLowPrice - Ask) >= iStep * _Point)                           // Check if price dropped by step amount
         if(CheckVolumeValue(BuyLowLots * iMultiplier))                   // Checking the trading volume
           {
            // Send BUY order with specified parameters
            ticket = OrderSend(Symbol(),OP_BUY,BuyLowLots * iMultiplier,Ask,iSlippage,
                               0,                                         // Stop Loss price
                               0,                                         // Take Profit price
                               "VR Locker Lite",                          // Order comment
                               iMagicNumber,0,clrBlue);                   // Magic number, expiration, blue arrow color

            // Check if order was successfully placed
            if(ticket<0)
               Print("OrderSend failed with an error #",GetLastError());  // Print error if failed
            else
               Print("The OrderSend function has been completed successfully");  // Success message
            return;                                                       // Exit after opening position
           }



// SELL position management logic
   if(s == 0)                                                             // If no sell positions exist
      if(CheckVolumeValue(lt))                                            // Checking the trading volume
        {
         // Send SELL order with specified parameters
         ticket = OrderSend(Symbol(),OP_SELL,lt,Bid,iSlippage,
                            0,                                            // Stop Loss price
                            0,                                            // Take Profit price
                            "VR Locker Lite",                             // Order comment
                            iMagicNumber,0,clrRed);                       // Magic number, expiration, red arrow color

         // Check if order was successfully placed
         if(ticket<0)
            Print("OrderSend failed with an error #",GetLastError());     // Print error if failed
         else
            Print("The OrderSend function has been completed successfully"); // Success message
         return;                                                          // Exit after opening position
        }

   if(s > 0)                                                              // If sell positions exist
      if((Bid - SelHigtPrice) >= iStep * _Point)                          // Check if price rose by step amount
         if(CheckVolumeValue(SelHigtLots * iMultiplier))                  // Checking the trading volume
           {
            // Send SELL order with specified parameters
            ticket = OrderSend(Symbol(),OP_SELL,SelHigtLots * iMultiplier,Bid,iSlippage,
                               0,                                         // Stop Loss price
                               0,                                         // Take Profit price
                               "VR Locker Lite",                          // Order comment
                               iMagicNumber,0,clrRed);                    // Magic number, expiration, red arrow color

            // Check if order was successfully placed
            if(ticket<0)
               Print("OrderSend failed with an error #",GetLastError());     // Print error if failed
            else
               Print("The OrderSend function has been completed successfully"); // Success message
            return;                                                          // Exit after opening position
           }


// ===
// Calculate average prices for take profit levels
// ===
   double BuyAwerage = 0;                                              // Variable for buy positions average
   double SelAwerage = 0;                                              // Variable for sell positions average

   if(b >= 2)                                                          // Calculate only if 2+ buy positions
      BuyAwerage = NormalizeDouble(BuyPricSumm / BuyLotsSumm + iProfitPlus * _Point, _Digits); // Weighted average + profit
   if(s >= 2)                                                          // Calculate only if 2+ sell positions
      SelAwerage = NormalizeDouble(SelPricSumm / SelLotsSumm - iProfitPlus * _Point, _Digits); // Weighted average - profit
// ===
// Modify positions to set take profit levels
// ===
   for(int i = 0; i < total; i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))                     // Select position by index
         if(OrderSymbol() == _Symbol)                                  // Check if position is for current symbol
            if(OrderMagicNumber() == iMagicNumber)                     // Check if position belongs to this EA
              {
               if(BuyAwerage > 0)                                      // If buy average is calculated
                  if(OrderType() == OP_BUY)                            // Check if position is BUY
                     if(NormalizeDouble(OrderTakeProfit(), _Digits) != BuyAwerage) // Check if TP needs update
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),BuyAwerage,NULL,clrBlue)) // Modify TP level
                           Print("OrderModify failed with an error #",GetLastError()); // Print error if failed


               if(SelAwerage > 0)                                      // If sell average is calculated
                  if(OrderType() == OP_SELL)                           // Check if position is SELL
                     if(NormalizeDouble(OrderTakeProfit(), _Digits) != SelAwerage) // Check if TP needs update
                        if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),SelAwerage,NULL,clrBlue)) // Modify TP level
                           Print("OrderModify failed with an error #",GetLastError()); // Print error if failed
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
//| Check Volume Value function                                      |
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
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               VR Locker Lite.mq5 |
//|                                      Copyright 2025, Trading-Go. |
//+------------------------------------------------------------------+
#property copyright "@ Voldemar"                                      // Copyright information
#property link      "https://www.mql5.com/en/channels/tradingo-go-en" //
#property version   "26.010"                                          // Expert Advisor version

#include <Trade\Trade.mqh>        CTrade        trade; // Include Trade class for executing orders
#include <Trade\PositionInfo.mqh> CPositionInfo posit; // Include PositionInfo class for position management

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
// --- Set MagicNumber in CTrade class
   trade.SetExpertMagicNumber(iMagicNumber);
// --- Set Slippage in CTrade class
   trade.SetDeviationInPoints(iSlippage);
// --- Set filling mode according to symbol specifications
   trade.SetTypeFillingBySymbol(_Symbol);
// --- Set account type to hedging (allows multiple positions per symbol)
   trade.SetMarginMode();
// ---
   double stepvol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);     // Get minimum lot size increment for current symbol
   if(stepvol > 0.0)                                                   // Check if step is valid
      lt = stepvol * (MathFloor(iStartLots / stepvol) - 1);            // Calculate lot size: round down and subtract one step
//---
   double minvol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);       // Get minimum allowed lot size for symbol
   if(lt < minvol)                                                     // Check if calculated lot is below minimum
      lt = 0.0;                                                        // Reset to zero if too small
      
   return(INIT_SUCCEEDED);                                             // Return success code
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int total = ::PositionsTotal(), b = 0, s = 0;                       // Get total positions, initialize buy/sell counters
   double   BuyPricSumm = 0,   SelPricSumm = 0, BuyLotsSumm = 0, SelLotsSumm = 0; // Variables for price and volume sums
   
   double   BuyLowPrice = 0,   SelHigtPrice = 0;                       // Track lowest buy and highest sell prices
   double   BuyLowLots  = 0,   SelHigtLots  = 0;                       // Track volumes at those prices

   double   Bid = ::SymbolInfoDouble(_Symbol, SYMBOL_BID);             // Get current Bid price
   double   Ask = ::SymbolInfoDouble(_Symbol, SYMBOL_ASK);             // Get current Ask price

   if(Bid <= 0 || Ask <= 0)                                            // Check for invalid prices
      return;                                                          // Exit if prices are invalid

   // Loop through all positions to analyze current portfolio
   for(int i = 0; i < total; i++)
      if(posit.SelectByIndex(i))                                       // Select position by index
         if(posit.Symbol() == _Symbol)                                 // Check if position is for current symbol
            if(posit.Magic() == iMagicNumber)                          // Check if position belongs to this EA
               if(posit.PositionType() == POSITION_TYPE_BUY)           // Check if position is BUY
                 {
                  b++;                                                  // Increment buy position counter
                  BuyPricSumm += posit.PriceOpen() * posit.Volume();   // Add weighted open price (price * volume)
                  BuyLotsSumm += posit.Volume();                       // Add buy volume to total

                  if(posit.PriceOpen() < BuyLowPrice || BuyLowPrice == 0) // Find lowest buy price
                    {
                     BuyLowPrice = posit.PriceOpen();                  // Update lowest buy price
                     BuyLowLots = posit.Volume();                      // Store volume at lowest price
                    }
                 }
               else
                  if(posit.PositionType() == POSITION_TYPE_SELL)       // Check if position is SELL
                    {
                     s++;                                              // Increment sell position counter
                     SelPricSumm += posit.PriceOpen() * posit.Volume(); // Add weighted open price for sells
                     SelLotsSumm += posit.Volume();                    // Add sell volume to total

                     if(posit.PriceOpen() > SelHigtPrice || SelHigtPrice == 0) // Find highest sell price
                       {
                        SelHigtPrice = posit.PriceOpen();              // Update highest sell price
                        SelHigtLots = posit.Volume();                  // Store volume at highest price
                       }
                    }

   // BUY position management logic
   if(b == 0)                                                          // If no buy positions exist
      if(trade.Buy(lt))                                                // Open initial buy position
         return;                                                       // Exit after opening position

   if(b > 0)                                                           // If buy positions exist
      if((BuyLowPrice - Ask) >= iStep * _Point)                        // Check if price dropped by step amount
         if(trade.Buy(BuyLowLots * iMultiplier))                       // Add to losing position with multiplier
            return;                                                    // Exit after adding position

   // SELL position management logic
   if(s == 0)                                                          // If no sell positions exist
      if(trade.Sell(lt))                                               // Open initial sell position
         return;                                                       // Exit after opening position

   if(s > 0)                                                           // If sell positions exist
      if((Bid - SelHigtPrice) >= iStep * _Point)                       // Check if price rose by step amount
         if(trade.Sell(SelHigtLots * iMultiplier))                     // Add to losing position with multiplier
            return;                                                    // Exit after adding position
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
   for(int i = 0; i < total; i++)                                      // Loop through all positions again
      if(posit.SelectByIndex(i))                                       // Select position by index
         if(posit.Symbol() == _Symbol)                                 // Check symbol
            if(posit.Magic() == iMagicNumber)                          // Check magic number
              {
               if(BuyAwerage > 0)                                      // If buy average is calculated
                  if(posit.PositionType() == POSITION_TYPE_BUY)        // Check if position is BUY
                     if(NormalizeDouble(posit.TakeProfit(), _Digits) != BuyAwerage) // Check if TP needs update
                        trade.PositionModify(posit.Ticket(), 0, BuyAwerage); // Modify TP level

               if(SelAwerage > 0)                                      // If sell average is calculated
                  if(posit.PositionType() == POSITION_TYPE_SELL)       // Check if position is SELL
                     if(NormalizeDouble(posit.TakeProfit(), _Digits) != SelAwerage) // Check if TP needs update
                        trade.PositionModify(posit.Ticket(), 0, SelAwerage); // Modify TP level
              }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  // Function called when EA is removed
  {
  }
//+------------------------------------------------------------------+
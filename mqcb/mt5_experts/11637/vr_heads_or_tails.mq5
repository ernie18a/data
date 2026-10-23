//+------------------------------------------------------------------+
//|                                            VR Heads or Tails.mq5 | // File header and program version
//|                                      Copyright 2026, Trading-Go. | // Information about copyright owner
//+------------------------------------------------------------------+
//| 🔥 Friends!                                                      | // Greeting users
//| I have created a channel in the MQL5 market.                     | // Description of author's channels
//| 1 - Strategy reviews                                             | // Strategy reviews
//| 2 - Source codes                                                 | // Source codes
//| 3 - Trading strategies and robots for them                       | // Trading strategies and robots
//| 4 - A lot of content for successful trading                      | // Lot of useful content for successful trading
//| MQL Channel En   https://www.mql5.com/en/channels/tradingo-go-en |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Trading-Go."                      // Setting copyright property
#property link      "https://www.mql5.com/en/channels/tradingo-go-en"  // Setting developer resource link
#property version   "26.010"                                           // Program version

#include <Trade\Trade.mqh>                                             // Including Trade.mqh library
CTrade        trade;                                                   // Object of class CTrade to manage trades

#include <Trade\PositionInfo.mqh>                                      // Including PositionInfo.mqh library
CPositionInfo posit;                                                   // Object of class CPositionInfo to process positions

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double  iLots         = 0.01;                                    // Input parameter for lot size (trade volume)
input int     iTakeProfit   = 450;                                     // Input parameter for profit fixing level (Take Profit)
input int     iStopLoss     = 390;                                     // Input parameter for loss limitation level (Stop Loss)
input int     iMagicNumber  = 227;                                     // Input parameter for unique deal number (Magic Number)
input int     iSlippage     = 30;                                      // Input parameter for maximum price slippage

string sy = "";                                                        // Variable to store instrument symbol
double pt = 0;                                                         // Variable for point calculation step
int    dt = 0;                                                         // Variable for decimal places count
double lt = 0;
//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()                                                           // Initialization function
  {

   sy = _Symbol;                                                       // Getting current trading instrument
   pt = _Point;                                                        // Getting minimum unit change size
   dt = _Digits;                                                       // Getting number of decimal digits in price

   trade.SetExpertMagicNumber(iMagicNumber);                           // Setting unique deal number for trade operations

   trade.SetDeviationInPoints(iSlippage);                              // Setting maximum price deviation points

   trade.SetTypeFillingBySymbol(sy);                                   // Setting order execution type according to instrument settings

   trade.SetMarginMode();                                              // Setting margin mode

   double stepvol = SymbolInfoDouble(sy, SYMBOL_VOLUME_STEP);          // Get the lot size change step for the selected symbol
   if(stepvol > 0.0)                                                   // If the lot size step is positive, apply calculation of adjusted lot size
      lt = stepvol * (MathFloor(iLots / stepvol) - 1);                 // Round down the lot size to the nearest step value and decrease by one step
//---
   double minvol = SymbolInfoDouble(sy, SYMBOL_VOLUME_MIN);            // Get minimum allowed lot size for the specified symbol
   if(lt < minvol)                                                     // If the adjusted lot size is less than the minimum possible value, reset it to zero
      lt = 0.0;

   ::MathSrand(GetTickCount());                                        // Generating initial number for random generator

   return(INIT_SUCCEEDED);                                             // Returning successful initialization status
  }
//+------------------------------------------------------------------+
//| Tick event handler                                               |
//+------------------------------------------------------------------+
void OnTick()                                                          // Function handling tick events
  {

   int total = ::PositionsTotal(), b = 0, s = 0;                       // Total open positions and purchase/sale counters

   double Bid = ::SymbolInfoDouble(sy, SYMBOL_BID);                    // Current bid price (selling price)
   double Ask = ::SymbolInfoDouble(sy, SYMBOL_ASK);                    // Current ask price (buying price)

   double new_sl = 0, new_tp = 0, old_sl = 0, old_tp = 0;              // New and old stop loss and take profit levels

   if(Bid <= 0 || Ask <= 0)                                            // If prices are incorrect
      return;                                                          // Exit function

   for(int i = 0; i < total; i++)                                      // Loop through open positions
      if(posit.SelectByIndex(i))                                       // Select position by index
         if(posit.Symbol() == sy)                                      // Check instrument of position
            if(posit.Magic() == iMagicNumber)                          // Check unique number of position
              {

               old_sl = ::NormalizeDouble(posit.StopLoss(),   dt);     // Converting old stop loss to required decimal places
               old_tp = ::NormalizeDouble(posit.TakeProfit(), dt);     // Converting old take profit to required decimal places

               if(posit.PositionType() == POSITION_TYPE_BUY)           // If position is BUY (purchase)
                 {
                  new_sl = ::NormalizeDouble(Ask - iStopLoss   * pt, dt); // New stop loss below current ask price
                  new_tp = ::NormalizeDouble(Ask + iTakeProfit * pt, dt); // New take profit above current ask price
                  b++;                                                 // Increment purchases counter
                 }

               if(posit.PositionType() == POSITION_TYPE_SELL)          // If position is SELL (sale)
                 {
                  new_sl = ::NormalizeDouble(Bid + iStopLoss   * pt, dt); // New stop loss above current bid price
                  new_tp = ::NormalizeDouble(Bid - iTakeProfit * pt, dt); // New take profit below current bid price
                  s++;                                                 // Increment sales counter
                 }

               if(old_sl == 0 || old_tp == 0)                          // If new levels differ from old ones
                  trade.PositionModify(posit.Ticket(), new_sl, new_tp);// Modify position with new SL and TP levels
              }



   if((b + s) == 0)                                                    // If there are no active positions
      if(::MathRand() % 2 == 0)                                        // Randomly choosing direction of opening position
        {
         if(trade.CheckVolume(sy, lt, Ask, ORDER_TYPE_BUY))        // Verification of the sufficiency of funds to perform the required trading operation
            if(trade.Buy(lt))                                      // Opening long position (BUY)
               return;                                                 // End function execution
        }
      else
         if(trade.CheckVolume(sy, lt, Bid, ORDER_TYPE_SELL))       // Verification of the sufficiency of funds to perform the required trading operation
            if(trade.Sell(lt))                                     // Opening short position (SELL)
               return;                                                 // End function execution
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)                                        // Deinitialization function
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

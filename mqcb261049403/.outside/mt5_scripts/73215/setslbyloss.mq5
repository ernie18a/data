//+------------------------------------------------------------------+
//|                                                  SetSLByLoss.mq5 |
//|                   Script to set Stop Loss on all open positions. |
//+------------------------------------------------------------------+
#property copyright   "Public domain - MQL5 community"
#property version     "1.00"
#property description "Script that sets a Stop Loss on every open position based"
#property description "on a target loss amount expressed in the account's currency"
#property description "(e.g. $50 per position). Works for any deposit currency"
#property description "(USD, AUD, EUR, NZD, etc.) and any forex symbol."
#property script_show_inputs

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- Inputs
input group "=== Configuration ==="
input double InpTargetLossAmount = 50.0; // Maximum loss (amount in account currency) for each position

//+------------------------------------------------------------------+
//| Calculates the SL price for a target loss in account currency    |
//| Returns true on success and sets slPrice; false on failure       |
//+------------------------------------------------------------------+
bool CalculateSLForTargetLoss(const string symbol,
                              const ENUM_POSITION_TYPE posType,
                              const double openPrice,
                              const double volume,
                              const double targetLoss,
                              double &slPrice)
  {
   slPrice = 0.0;

   if(volume <= 0.0 || targetLoss <= 0.0 || openPrice <= 0.0)
      return false;

   const double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      return false;

// Step 1 — get tick value already in ACCOUNT currency
   const double tickValueLoss = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickValueLoss <= 0.0)
     {
      PrintFormat("  ERROR tick value loss is zero or unavailable for %s",
                  symbol);
      return false;
     }

// Step 2 — calculate loss per tick (in account currency) for this volume
   const double lossPerTick = tickValueLoss * volume;

// Step 3 — how many ticks (and points) are needed for the target loss
   const double ticksForTarget  = targetLoss / lossPerTick;
   const double priceDistance   = ticksForTarget * tickSize;

// Step 4 — apply distance to openPrice
   if(posType == POSITION_TYPE_BUY)
      slPrice = openPrice - priceDistance;
   else
      slPrice = openPrice + priceDistance;

// Step 5 — normalize SL to symbol's tick size and digits
   const int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   slPrice = NormalizeDouble(MathRound(slPrice / tickSize) * tickSize, digits);

   return true;
  }

//+------------------------------------------------------------------+
//| Validates whether the SL price respects stops/freeze levels      |
//+------------------------------------------------------------------+
bool IsSLDistanceValid(const string symbol,
                       const ENUM_POSITION_TYPE posType,
                       const double slPrice,
                       string &reason)
  {
   const long stopsLevel  = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const long freezeLevel = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   const long minLevel    = MathMax(stopsLevel, freezeLevel);
   const double point     = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const double minDist   = minLevel * point;

   if(posType == POSITION_TYPE_BUY)
     {
      const double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      if(slPrice >= bid)
        {
         reason = StringFormat("BUY SL (%.5f) is >= current Bid (%.5f); "
                               "price moved too far against the position",
                               slPrice, bid);
         return false;
        }
      if((bid - slPrice) < minDist)
        {
         reason = StringFormat("BUY SL too close to Bid (dist=%.1f pts, "
                               "min required=%d pts)",
                               (bid - slPrice) / point, (int)minLevel);
         return false;
        }
     }
   else // SELL
     {
      const double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      if(slPrice <= ask)
        {
         reason = StringFormat("SELL SL (%.5f) is <= current Ask (%.5f); "
                               "price moved too far against the position",
                               slPrice, ask);
         return false;
        }
      if((slPrice - ask) < minDist)
        {
         reason = StringFormat("SELL SL too close to Ask (dist=%.1f pts, "
                               "min required=%d pts)",
                               (slPrice - ask) / point, (int)minLevel);
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| OnStart                                                          |
//+------------------------------------------------------------------+
void OnStart()
  {
   CTrade        trade;
   CPositionInfo position;
   trade.SetAsyncMode(false); // synchronous: we want reliable feedback

   const int totalPositions = PositionsTotal();
   const string accCurrency  = AccountInfoString(ACCOUNT_CURRENCY);

   PrintFormat("=== SetSLByLoss starting ===");
   PrintFormat("Account currency: %s | Target loss per position: %.2f %s | "
               "Open positions: %d",
               accCurrency, InpTargetLossAmount, accCurrency, totalPositions);

   int processed = 0, modified = 0, alreadyOk = 0, skipped = 0, failed = 0;

   for(int i = totalPositions - 1; i >= 0; i--)
     {
      if(!position.SelectByIndex(i))
         continue;
      processed++;

      const ulong  ticket    = position.Ticket();
      const string sym       = position.Symbol();
      const ENUM_POSITION_TYPE posType = position.PositionType();
      const double openPrice = position.PriceOpen();
      const double volume    = position.Volume();
      const double currentSL = position.StopLoss();
      const double currentTP = position.TakeProfit();

      // Step 1 — calculate target SL price
      double newSL = 0.0;
      if(!CalculateSLForTargetLoss(sym, posType, openPrice, volume, InpTargetLossAmount, newSL))
        {
         PrintFormat("[#%I64u %s %s vol=%.2f] Failed to calculate SL",
                     ticket, sym,
                     (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                     volume);
         failed++;
         continue;
        }

      // Step 2 — check whether SL is already in place (within 1 tick)
      const double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
      const double tol = (tickSize > 0) ? tickSize : SymbolInfoDouble(sym, SYMBOL_POINT);
      if(currentSL > 0.0 && MathAbs(currentSL - newSL) <= tol)
        {
         alreadyOk++;
         continue;
        }

      // Step 3 — validate SL distance against broker constraints
      string reason = "";
      if(!IsSLDistanceValid(sym, posType, newSL, reason))
        {
         PrintFormat("[#%I64u %s %s vol=%.2f] SKIPPED: %s",
                     ticket, sym,
                     (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                     volume, reason);
         skipped++;
         continue;
        }

      // Step 4 — submit modification
      if(trade.PositionModify(ticket, newSL, currentTP))
        {
         PrintFormat("[#%I64u %s %s vol=%.2f] SL set to %.5f "
                     "(target loss ~%.2f %s)",
                     ticket, sym,
                     (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                     volume, newSL, InpTargetLossAmount, accCurrency);
         modified++;
        }
      else
        {
         PrintFormat("[#%I64u %s %s vol=%.2f] Modify FAILED: retcode=%d (%s)",
                     ticket, sym,
                     (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                     volume, trade.ResultRetcode(),
                     trade.ResultRetcodeDescription());
         failed++;
        }
     }

   PrintFormat("=== SetSLByLoss done ===");
   PrintFormat("Processed: %d | Modified: %d | Already correct: %d | "
               "Skipped: %d | Failed: %d",
               processed, modified, alreadyOk, skipped, failed);
  }

//+------------------------------------------------------------------+

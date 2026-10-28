#property copyright "MQL5"
#property link      "MQL5.COM"
#property version   "2.00"
#property description "Optimized script to set Stop Loss and Take Profit based on Risk:Reward ratio"
#property script_show_inputs

#include <Trade\Trade.mqh>

// Input parameters
input double RiskRewardRatio = 2.0;  // Risk:Reward Ratio (e.g., 2.0 for 1:2)
input double StopLossPips = 20;      // Stop Loss in pips
input bool   ModifyAllPositions = true; // Modify all positions or only current symbol

//+------------------------------------------------------------------+
//| Calculate pip value based on symbol digits                        |
//+------------------------------------------------------------------+
double GetPipValue(string symbol)
{
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   // For 3-digit and 5-digit quotes
   if(digits == 3 || digits == 5)
      return point * 10;
   
   return point;
}

//+------------------------------------------------------------------+
//| Normalize price according to symbol digits                        |
//+------------------------------------------------------------------+
double NormalizePrice(string symbol, double price)
{
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return NormalizeDouble(price, digits);
}

//+------------------------------------------------------------------+
//| Check if SL/TP levels are valid                                  |
//+------------------------------------------------------------------+
bool CheckStopLevels(string symbol, double open_price, double sl, double tp, ENUM_POSITION_TYPE type)
{
   double stops_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(symbol, SYMBOL_POINT);
   double freeze_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL) * SymbolInfoDouble(symbol, SYMBOL_POINT);
   
   if(stops_level > 0)
   {
      if(type == POSITION_TYPE_BUY)
      {
         if((open_price - sl) < stops_level || (tp - open_price) < stops_level)
         {
            Print("Error: SL or TP too close to current price. Minimum distance: ", stops_level);
            return false;
         }
      }
      else
      {
         if((sl - open_price) < stops_level || (open_price - tp) < stops_level)
         {
            Print("Error: SL or TP too close to current price. Minimum distance: ", stops_level);
            return false;
         }
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   string current_symbol = Symbol();
   int positions_modified = 0;
   int positions_failed = 0;
   
   CTrade trade;
   trade.SetExpertMagicNumber(0); // Set magic number if needed
   trade.SetDeviationInPoints(10); // Set slippage
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Loop through all positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
      {
         Print("Failed to get position ticket at index ", i);
         continue;
      }
      
      if(!PositionSelectByTicket(ticket))
      {
         Print("Failed to select position #", ticket);
         continue;
      }
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      
      // Skip if not current symbol and ModifyAllPositions is false
      if(!ModifyAllPositions && symbol != current_symbol)
         continue;
      
      // Get position details
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      double current_sl = PositionGetDouble(POSITION_SL);
      double current_tp = PositionGetDouble(POSITION_TP);
      
      // Calculate pip value for this symbol
      double pip_value = GetPipValue(symbol);
      
      // Calculate SL and TP distances in price
      double sl_distance = StopLossPips * pip_value;
      double tp_distance = sl_distance * RiskRewardRatio;
      
      // Calculate new SL and TP
      double new_sl = 0;
      double new_tp = 0;
      
      if(type == POSITION_TYPE_BUY)
      {
         new_sl = NormalizePrice(symbol, open_price - sl_distance);
         new_tp = NormalizePrice(symbol, open_price + tp_distance);
      }
      else if(type == POSITION_TYPE_SELL)
      {
         new_sl = NormalizePrice(symbol, open_price + sl_distance);
         new_tp = NormalizePrice(symbol, open_price - tp_distance);
      }
      
      // Check if SL/TP already set to same values
      if(MathAbs(current_sl - new_sl) < pip_value * 0.1 && MathAbs(current_tp - new_tp) < pip_value * 0.1)
      {
         Print("Position #", ticket, " already has correct SL/TP");
         continue;
      }
      
      // Validate stop levels
      if(!CheckStopLevels(symbol, open_price, new_sl, new_tp, type))
      {
         positions_failed++;
         continue;
      }
      
      // Modify position
      if(trade.PositionModify(ticket, new_sl, new_tp))
      {
         positions_modified++;
         Print("✓ Position #", ticket, " (", symbol, "): SL=", new_sl, ", TP=", new_tp);
      }
      else
      {
         positions_failed++;
         Print("✗ Failed to modify position #", ticket, ". Error: ", GetLastError());
      }
   }
   
   // Summary
   Print("========================================");
   Print("Summary: ", positions_modified, " positions modified, ", positions_failed, " failed");
   Print("========================================");
   
   if(positions_modified > 0)
      MessageBox("Successfully modified " + IntegerToString(positions_modified) + " position(s)", 
                 "SL/TP Script", MB_OK | MB_ICONINFORMATION);
   else if(positions_failed > 0)
      MessageBox("Failed to modify positions. Check the Experts log.", 
                 "SL/TP Script", MB_OK | MB_ICONWARNING);
}
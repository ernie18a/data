//+------------------------------------------------------------------+
//|                                  RiskBasedLotSizeCalculator.mq5 |
//|                                        Copyright 2026, Ali Akbar |
//|                            https://www.mql5.com/en/users/alifx9 |
//+------------------------------------------------------------------+
#property copyright "Ali Akbar"
#property link      "https://www.mql5.com/en/users/alifx9"
#property version   "1.00"
#property description "Calculates the correct lot size for a trade based on account risk percentage and stop loss distance in pips."
#property script_show_inputs

input double InpRiskPercent  = 1.0;   // Risk per trade, % of balance
input double InpStopLossPips = 20.0;  // Stop loss distance, pips

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//--- basic input validation
   if(InpRiskPercent <= 0.0 || InpStopLossPips <= 0.0)
     {
      Alert("Risk percent and stop loss pips must be greater than zero.");
      return;
     }

//--- get account and symbol information
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (InpRiskPercent / 100.0);

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

//--- convert 1 pip to a price distance (handles 3/5-digit brokers)
   double pipSize = (digits == 3 || digits == 5) ? point * 10.0 : point;

   if(tickSize <= 0.0)
     {
      Alert("Unable to read tick size for ", _Symbol);
      return;
     }

//--- monetary value of one pip for one standard lot
   double valuePerPip = (tickValue / tickSize) * pipSize;

   if(valuePerPip <= 0.0)
     {
      Alert("Unable to calculate pip value for ", _Symbol);
      return;
     }

//--- raw lot size before broker constraints
   double rawLot = riskAmount / (InpStopLossPips * valuePerPip);

//--- align lot size to the broker's min/max/step rules
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double lot = MathFloor(rawLot / lotStep) * lotStep;
   lot = MathMax(minLot, MathMin(maxLot, lot));

//--- display and log the result
   string msg = StringFormat(
      "Symbol: %s\nBalance: %.2f\nRisk: %.2f%% (%.2f)\nStop Loss: %.1f pips\nSuggested Lot Size: %.2f",
      _Symbol, balance, InpRiskPercent, riskAmount, InpStopLossPips, lot);

   Comment(msg);
   Print(msg);
}
//+------------------------------------------------------------------+

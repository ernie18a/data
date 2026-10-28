//+------------------------------------------------------------------+
//|                                       PositionSizeCalculator.mq5 |
//|                 Risk-based position size calculator (lot sizing) |
//|                                                        Dror Munk |
//+------------------------------------------------------------------+
#property copyright   "Dror Munk"
#property version     "1.00"
#property description "Calculates the correct lot size for a planned trade from your"
#property description "risk (percent of equity or fixed money) and stop-loss distance."
#property description ""
#property description "Respects the symbol's contract specification: tick size/value,"
#property description "volume min/max/step. Also estimates the required margin and"
#property description "warns if the resulting position would not be affordable."
#property script_show_inputs

//--- risk input mode
enum ENUM_RISK_MODE
  {
   RISK_PERCENT_EQUITY = 0,   // Percent of account equity
   RISK_FIXED_MONEY    = 1    // Fixed money amount (account currency)
  };

//--- stop-loss input mode
enum ENUM_SL_MODE
  {
   SL_POINTS = 0,             // Stop-loss distance in points
   SL_PRICE  = 1              // Stop-loss price level
  };

//--- inputs
input ENUM_RISK_MODE InpRiskMode  = RISK_PERCENT_EQUITY;  // Risk defined as
input double         InpRiskValue = 1.0;                  // Risk value (% or money)
input ENUM_SL_MODE   InpSLMode    = SL_POINTS;            // Stop-loss defined as
input double         InpSLValue   = 300;                  // Stop-loss (points or price)
input bool           InpIsBuy     = true;                 // Planned direction: buy (false = sell)

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   string sym    = _Symbol;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

//--- risk money
   double risk_money = (InpRiskMode == RISK_PERCENT_EQUITY)
                       ? equity * InpRiskValue / 100.0
                       : InpRiskValue;
   if(risk_money <= 0)
     {
      Alert("PositionSizeCalculator: risk value must be positive.");
      return;
     }

//--- stop distance in points
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   double ask   = SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid   = SymbolInfoDouble(sym, SYMBOL_BID);
   double entry = InpIsBuy ? ask : bid;

   double sl_points = 0;
   if(InpSLMode == SL_POINTS)
      sl_points = InpSLValue;
   else
     {
      if(InpSLValue <= 0)
        {
         Alert("PositionSizeCalculator: stop-loss price must be positive.");
         return;
        }
      sl_points = MathAbs(entry - InpSLValue) / point;
     }
   if(sl_points <= 0)
     {
      Alert("PositionSizeCalculator: stop-loss distance is zero - nothing to calculate.");
      return;
     }

//--- money lost per 1.00 lot if the stop is hit
   double tick_size  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   if(tick_size <= 0 || tick_value <= 0)
     {
      Alert("PositionSizeCalculator: symbol tick size/value not available.");
      return;
     }
   double loss_per_lot = sl_points * point / tick_size * tick_value;
   if(loss_per_lot <= 0)
     {
      Alert("PositionSizeCalculator: could not compute loss per lot.");
      return;
     }

//--- raw lots, then normalize to contract specification
   double lots_raw = risk_money / loss_per_lot;

   double vol_min  = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double vol_max  = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double vol_step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(vol_step <= 0)
      vol_step = vol_min > 0 ? vol_min : 0.01;

   double lots = MathFloor(lots_raw / vol_step) * vol_step;   // round DOWN - never risk more
   lots = NormalizeDouble(lots, 8);

   string warn = "";
   if(lots < vol_min)
     {
      warn = StringFormat("Calculated size %.2f is below the minimum %.2f - "
                          "even the minimum lot exceeds your risk budget.",
                          lots, vol_min);
      lots = 0;
     }
   if(lots > vol_max)
     {
      warn = StringFormat("Capped at the symbol maximum of %.2f lots.", vol_max);
      lots = vol_max;
     }

//--- actual risk with the normalized volume
   double risk_actual = lots * loss_per_lot;

//--- margin estimate
   double margin_req = 0;
   ENUM_ORDER_TYPE ot = InpIsBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(lots > 0 && !OrderCalcMargin(ot, sym, lots, entry, margin_req))
      margin_req = -1;   // not available

   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

//--- report
   string rep;
   rep  = "=== Position Size Calculator ===\n";
   rep += StringFormat("Symbol: %s   direction: %s\n", sym, (InpIsBuy ? "BUY" : "SELL"));
   rep += StringFormat("Equity: %.2f %s   free margin: %.2f\n",
                       equity, AccountInfoString(ACCOUNT_CURRENCY), free_margin);
   rep += StringFormat("Risk: %s = %.2f %s\n",
                       (InpRiskMode == RISK_PERCENT_EQUITY ?
                        StringFormat("%.2f%% of equity", InpRiskValue) : "fixed amount"),
                       risk_money, AccountInfoString(ACCOUNT_CURRENCY));
   rep += StringFormat("Stop distance: %.0f points (loss per 1.00 lot: %.2f)\n",
                       sl_points, loss_per_lot);
   rep += StringFormat(">>> LOT SIZE: %.2f <<<\n", lots);
   rep += StringFormat("Actual risk at this size: %.2f (%.2f%% of equity)\n",
                       risk_actual, (equity > 0 ? 100.0 * risk_actual / equity : 0));
   if(margin_req >= 0 && lots > 0)
     {
      rep += StringFormat("Required margin: %.2f%s\n", margin_req,
                          (margin_req > free_margin ? "  *** EXCEEDS FREE MARGIN ***" : ""));
     }
   if(warn != "")
      rep += "WARNING: " + warn + "\n";

   Print(rep);
   Comment(rep);
   Alert(StringFormat("%s %s: lot size = %.2f (risk %.2f)",
                      sym, (InpIsBuy ? "BUY" : "SELL"), lots, risk_actual));
  }
//+------------------------------------------------------------------+

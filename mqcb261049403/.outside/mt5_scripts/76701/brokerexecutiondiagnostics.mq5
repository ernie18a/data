//+------------------------------------------------------------------+
//| BrokerExecutionDiagnostics.mq5                                   |
//| Read-only MT5 symbol and execution diagnostics                   |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs
#property version   "1.00"
#property description "Reports broker symbol, volume, price and execution constraints."

input string InpSymbol          = "";    // Empty uses the chart symbol
input double InpTestVolume      = 1.00;  // Volume used for margin/profit estimates
input int    InpTestMovePoints  = 100;   // Price move used for profit estimate

string BoolText(const bool value)
{
   return value ? "YES" : "NO";
}

string TradeModeText(const long mode)
{
   switch((ENUM_SYMBOL_TRADE_MODE)mode)
   {
      case SYMBOL_TRADE_MODE_DISABLED:  return "Disabled";
      case SYMBOL_TRADE_MODE_LONGONLY:  return "Long only";
      case SYMBOL_TRADE_MODE_SHORTONLY: return "Short only";
      case SYMBOL_TRADE_MODE_CLOSEONLY: return "Close only";
      case SYMBOL_TRADE_MODE_FULL:      return "Full";
   }
   return "Unknown";
}

string ExecutionModeText(const long mode)
{
   switch((ENUM_SYMBOL_TRADE_EXECUTION)mode)
   {
      case SYMBOL_TRADE_EXECUTION_REQUEST:  return "Request";
      case SYMBOL_TRADE_EXECUTION_INSTANT:  return "Instant";
      case SYMBOL_TRADE_EXECUTION_MARKET:   return "Market";
      case SYMBOL_TRADE_EXECUTION_EXCHANGE: return "Exchange";
   }
   return "Unknown";
}

string FillingModesText(const long flags)
{
   string result = "";
   if((flags & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
      result += "FOK ";
   if((flags & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
      result += "IOC ";
   if((flags & SYMBOL_FILLING_BOC) == SYMBOL_FILLING_BOC)
      result += "BOC ";
   if(result == "")
      result = "Broker/execution dependent";
   return result;
}

string OrderModesText(const long flags)
{
   string result = "";
   if((flags & SYMBOL_ORDER_MARKET) == SYMBOL_ORDER_MARKET) result += "Market ";
   if((flags & SYMBOL_ORDER_LIMIT) == SYMBOL_ORDER_LIMIT) result += "Limit ";
   if((flags & SYMBOL_ORDER_STOP) == SYMBOL_ORDER_STOP) result += "Stop ";
   if((flags & SYMBOL_ORDER_STOP_LIMIT) == SYMBOL_ORDER_STOP_LIMIT) result += "StopLimit ";
   if((flags & SYMBOL_ORDER_SL) == SYMBOL_ORDER_SL) result += "SL ";
   if((flags & SYMBOL_ORDER_TP) == SYMBOL_ORDER_TP) result += "TP ";
   if((flags & SYMBOL_ORDER_CLOSEBY) == SYMBOL_ORDER_CLOSEBY) result += "CloseBy ";
   return result == "" ? "None reported" : result;
}

int VolumeDigits(const double step)
{
   for(int digits = 0; digits <= 8; ++digits)
      if(MathAbs(step - NormalizeDouble(step, digits)) < 1e-12)
         return digits;
   return 8;
}

double NormalizeVolumeDown(const string symbol, const double requested)
{
   const double minimum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   const double maximum = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   const double step    = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0 || maximum <= 0.0)
      return 0.0;

   double volume = MathMin(requested, maximum);
   volume = MathFloor((volume + 1e-12) / step) * step;
   if(volume < minimum)
      volume = minimum;
   return NormalizeDouble(volume, VolumeDigits(step));
}

void AddLine(string &report, const string label, const string value)
{
   report += StringFormat("%-28s %s\n", label + ":", value);
}

void OnStart()
{
   const string symbol = (StringLen(InpSymbol) == 0 ? _Symbol : InpSymbol);
   if(!SymbolSelect(symbol, true))
   {
      PrintFormat("BrokerExecutionDiagnostics: cannot select symbol '%s'. Error %d",
                  symbol, GetLastError());
      return;
   }

   MqlTick tick;
   ResetLastError();
   if(!SymbolInfoTick(symbol, tick))
   {
      PrintFormat("BrokerExecutionDiagnostics: no current tick for '%s'. Error %d",
                  symbol, GetLastError());
      return;
   }

   const int    digits       = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   const double point        = SymbolInfoDouble(symbol, SYMBOL_POINT);
   const double tick_size    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tick_value   = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   const double tick_profit  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   const double tick_loss    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   const double contract     = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   const double vol_min      = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   const double vol_max      = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   const double vol_step     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   const double vol_limit    = SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT);
   const long   stops_level  = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   const long   freeze_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   const long   trade_mode   = SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE);
   const long   exec_mode    = SymbolInfoInteger(symbol, SYMBOL_TRADE_EXEMODE);
   const long   fill_flags   = SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   const long   order_flags  = SymbolInfoInteger(symbol, SYMBOL_ORDER_MODE);
   const double spread_pts   = (point > 0.0 ? (tick.ask - tick.bid) / point : 0.0);
   const double test_volume  = NormalizeVolumeDown(symbol, InpTestVolume);

   string report = "\n=== MT5 BROKER EXECUTION DIAGNOSTICS ===\n";
   AddLine(report, "Symbol", symbol);
   AddLine(report, "Description", SymbolInfoString(symbol, SYMBOL_DESCRIPTION));
   AddLine(report, "Base / Profit / Margin",
           SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE) + " / " +
           SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT) + " / " +
           SymbolInfoString(symbol, SYMBOL_CURRENCY_MARGIN));
   AddLine(report, "Bid / Ask",
           DoubleToString(tick.bid, digits) + " / " + DoubleToString(tick.ask, digits));
   AddLine(report, "Spread", DoubleToString(spread_pts, 1) + " points");
   AddLine(report, "Digits / Point", IntegerToString(digits) + " / " + DoubleToString(point, digits));
   AddLine(report, "Tick size", DoubleToString(tick_size, digits));
   AddLine(report, "Tick value", DoubleToString(tick_value, 8));
   AddLine(report, "Tick value profit/loss",
           DoubleToString(tick_profit, 8) + " / " + DoubleToString(tick_loss, 8));
   AddLine(report, "Contract size", DoubleToString(contract, 2));
   AddLine(report, "Volume min / max / step",
           DoubleToString(vol_min, VolumeDigits(vol_step)) + " / " +
           DoubleToString(vol_max, VolumeDigits(vol_step)) + " / " +
           DoubleToString(vol_step, VolumeDigits(vol_step)));
   AddLine(report, "Directional volume limit", DoubleToString(vol_limit, 2));
   AddLine(report, "Stops / freeze level",
           IntegerToString((int)stops_level) + " / " + IntegerToString((int)freeze_level) + " points");
   AddLine(report, "Trade mode", TradeModeText(trade_mode));
   AddLine(report, "Execution mode", ExecutionModeText(exec_mode));
   AddLine(report, "Filling modes", FillingModesText(fill_flags));
   AddLine(report, "Allowed order features", OrderModesText(order_flags));
   AddLine(report, "Terminal connected", BoolText((bool)TerminalInfoInteger(TERMINAL_CONNECTED)));
   AddLine(report, "Terminal trading allowed", BoolText((bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)));
   AddLine(report, "Account trading allowed", BoolText((bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)));
   AddLine(report, "EA trading allowed", BoolText((bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT)));

   double margin = 0.0;
   ResetLastError();
   if(test_volume > 0.0 && OrderCalcMargin(ORDER_TYPE_BUY, symbol, test_volume, tick.ask, margin))
      AddLine(report, "Estimated BUY margin",
              DoubleToString(margin, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) +
              " at " + DoubleToString(test_volume, VolumeDigits(vol_step)) + " lots");
   else
      AddLine(report, "Estimated BUY margin", "Unavailable, error " + IntegerToString(GetLastError()));

   double estimated_profit = 0.0;
   const int test_move_points = (InpTestMovePoints > 0 ? InpTestMovePoints : 1);
   const double target_price = tick.ask + test_move_points * point;
   ResetLastError();
   if(test_volume > 0.0 &&
      OrderCalcProfit(ORDER_TYPE_BUY, symbol, test_volume, tick.ask, target_price, estimated_profit))
      AddLine(report, "Profit for test move",
              DoubleToString(estimated_profit, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) +
              " for " + IntegerToString(test_move_points) + " points");
   else
      AddLine(report, "Profit for test move", "Unavailable, error " + IntegerToString(GetLastError()));

   report += "========================================\n";
   Print(report);
   Comment(report);
}

//+------------------------------------------------------------------+
//|                                BrokerExecutionDiagnosticsMT5.mq5 |
//| Read-only report of broker symbol and execution constraints.     |
//+------------------------------------------------------------------+
#property copyright "Usamah"
#property link      "https://www.mql5.com/en/users/usamah41"
#property version   "1.10"
#property description "Read-only MT5 script that reports broker symbol and execution constraints."
#property script_show_inputs

input double InpRequestedVolume = 0.01; // Volume to normalize against broker rules
input double InpEntryPrice      = 0.0;  // Optional entry price for distance/P&L checks
input double InpStopLossPrice   = 0.0;  // Optional Stop Loss price for distance/P&L checks
input bool   InpShowOnChart     = true; // Also display the report as a chart comment

//+------------------------------------------------------------------+
//| Normalize volume without exceeding the requested exposure.       |
//+------------------------------------------------------------------+
double NormalizeVolume(const double requested,
                       const double minimum,
                       const double maximum,
                       const double step)
  {
   if(step<=0.0)
      return requested;

   double bounded=MathMax(minimum,MathMin(maximum,requested));
   double steps=MathFloor((bounded-minimum)/step+1.0e-8);
   double normalized=minimum+steps*step;
   return MathMax(minimum,MathMin(maximum,normalized));
  }

//+------------------------------------------------------------------+
//| Convert a Boolean result into a compact report label.             |
//+------------------------------------------------------------------+
string YesNo(const bool value)
  {
   return value ? "YES" : "NO";
  }

//+------------------------------------------------------------------+
//| Collect symbol properties and print a read-only diagnostic.       |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Read the symbol specification exposed by the connected broker.
   const string symbol=_Symbol;
   const int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   const double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double tick_size=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   const double tick_value=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   const double volume_min=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   const double volume_max=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   const double volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   const long stops_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const long freeze_level=SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   const long spread_points=SymbolInfoInteger(symbol,SYMBOL_SPREAD);
   const long trade_mode=SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE);
   const long execution_mode=SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
   const bool selected=(bool)SymbolInfoInteger(symbol,SYMBOL_SELECT);

//--- Derive normalized user values and price-distance equivalents.
   const double normalized_volume=NormalizeVolume(InpRequestedVolume,
                                                   volume_min,
                                                   volume_max,
                                                   volume_step);
   const double minimum_stop_distance=stops_level*point;
   const double freeze_distance=freeze_level*point;

//--- Build the base report.
   string report="BROKER EXECUTION DIAGNOSTICS MT5\n";
   report+="Symbol: "+symbol+" | Selected: "+YesNo(selected)+"\n";
   report+=StringFormat("Digits: %d | Point: %.*f | Tick size: %.*f\n",
                        digits,digits,point,digits,tick_size);
   report+=StringFormat("Tick value: %.8f | Spread: %d points\n",
                        tick_value,(int)spread_points);
   report+=StringFormat("Volume min/max/step: %.8f / %.8f / %.8f\n",
                        volume_min,volume_max,volume_step);
   report+=StringFormat("Requested volume: %.8f | Normalized: %.8f\n",
                        InpRequestedVolume,normalized_volume);
   report+=StringFormat("Stops level: %d points (%.*f)\n",
                        (int)stops_level,digits,minimum_stop_distance);
   report+=StringFormat("Freeze level: %d points (%.*f)\n",
                        (int)freeze_level,digits,freeze_distance);
   report+=StringFormat("Trade mode enum: %d | Execution mode enum: %d\n",
                        (int)trade_mode,(int)execution_mode);

//--- Add optional entry-to-Stop-Loss and account-currency estimates.
   if(InpEntryPrice>0.0 && InpStopLossPrice>0.0)
     {
      const double distance=MathAbs(InpEntryPrice-InpStopLossPrice);
      const bool stop_distance_ok=(distance+point*0.1>=minimum_stop_distance);
      report+=StringFormat("Entry-to-SL distance: %.*f | Meets stops level: %s\n",
                           digits,distance,YesNo(stop_distance_ok));

      double buy_loss=0.0;
      double sell_loss=0.0;
      const bool buy_calc=OrderCalcProfit(ORDER_TYPE_BUY,symbol,normalized_volume,
                                          InpEntryPrice,InpStopLossPrice,buy_loss);
      const bool sell_calc=OrderCalcProfit(ORDER_TYPE_SELL,symbol,normalized_volume,
                                           InpEntryPrice,InpStopLossPrice,sell_loss);
      report+=StringFormat("Estimated BUY P/L to SL: %s | %.2f account currency\n",
                           YesNo(buy_calc),buy_loss);
      report+=StringFormat("Estimated SELL P/L to SL: %s | %.2f account currency\n",
                           YesNo(sell_calc),sell_loss);
     }
   else
      report+="Optional entry/SL estimate: disabled (set both prices above zero).\n";

//--- The script is read-only: output is limited to log and chart text.
   Print("\n",report);
   if(InpShowOnChart)
      Comment(report);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                      Manual_Trade_Pad_Tester.mq5 |
//|   Risk-based manual trading pad for the MetaTrader 5 Tester      |
//+------------------------------------------------------------------+
//| Description:                                                     |
//|   A lightweight manual trading panel designed for the visual      |
//|   Strategy Tester and chart-based manual backtesting in MetaTrader |
//|   5. The EA can open market BUY/SELL positions, calculate volume   |
//|   from a fixed lot or account-risk percentage, attach an optional  |
//|   risk/reward based take-profit, move positions to break-even,     |
//|   partially close positions, and close positions by direction.    |
//|                                                                  |
//| Position scope:                                                   |
//|   Only positions belonging to the current symbol (_Symbol) and    |
//|   the configured magic number (InpMagic) are managed.             |
//|                                                                  |
//| Keyboard shortcuts:                                               |
//|   B = BUY                                                         |
//|   S = SELL                                                        |
//|   E = Move managed positions to break-even                        |
//|   C = Close all managed positions                                 |
//|                                                                  |
//| Implementation notes:                                             |
//|   The panel uses native OBJ_* chart objects and the standard       |
//|   CTrade class from the MQL5 Standard Library. No external        |
//|   libraries are required.                                         |
//+------------------------------------------------------------------+
#property copyright "Amirhossein Heydarijokani"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Manual trading pad for visual Strategy Tester backtesting."
#property description "Risk-% or fixed lot sizing, automatic R:R take profit,"
#property description "break-even, partial close, side-specific close and hotkeys."

#include <Trade/Trade.mqh>

//--- Position sizing mode used for calculating the initial order volume
enum ENUM_SIZE_MODE
  {
   SIZE_FIXED_LOT    = 0,   // Use the entered volume directly.
   SIZE_RISK_PERCENT = 1    // Calculate volume from a percentage of balance.
  };

//--- User-configurable inputs
//    Trading inputs control order identification, volume calculation,
//    stop-loss/take-profit behavior and trade execution tolerance.
input group "Trading"
input ulong          InpMagic       = 5170001;          // Unique magic number used to identify managed positions.
input ENUM_SIZE_MODE InpSizeMode    = SIZE_RISK_PERCENT;// Initial volume-sizing mode.
input double         InpFixedLot    = 0.10;             // Default fixed volume in lots.
input double         InpRiskPercent = 1.0;              // Default percentage of balance to risk per trade.
input int            InpSLPoints    = 300;              // Default stop-loss distance in points.
input double         InpRR          = 2.0;              // Default reward:risk ratio; 0 disables TP.
input int            InpBEOffset    = 10;               // Break-even SL offset in points.
input int            InpDeviation   = 20;               // Maximum allowed price deviation in points.

input group "Panel"
input int            InpPanelX      = 15;               // Horizontal panel position in pixels.
input int            InpPanelY      = 25;               // Vertical panel position in pixels.

//--- Chart-object names
//    All panel objects use the "MTP_" prefix so they can be identified
//    and removed safely during deinitialization.
const string P_BG      = "MTP_BG";
const string P_TITLE   = "MTP_TITLE";
const string P_BAL     = "MTP_BAL";
const string P_EQ      = "MTP_EQ";
const string P_FLT     = "MTP_FLT";
const string P_POS     = "MTP_POS";
const string P_STATUS  = "MTP_STATUS";
const string P_LSIZE   = "MTP_LSIZE";
const string P_ESIZE   = "MTP_ESIZE";
const string P_BMODE   = "MTP_BMODE";
const string P_LSL     = "MTP_LSL";
const string P_ESL     = "MTP_ESL";
const string P_LRR     = "MTP_LRR";
const string P_ERR     = "MTP_ERR";
const string P_BUY     = "MTP_BUY";
const string P_SELL    = "MTP_SELL";
const string P_BE      = "MTP_BE";
const string P_PART    = "MTP_PART";
const string P_CBUY    = "MTP_CBUY";
const string P_CSELL   = "MTP_CSELL";
const string P_CALL    = "MTP_CALL";

//--- Global trading object and current volume-sizing mode
CTrade         g_trade;  // Standard MQL5 trade wrapper used for order/position operations.
ENUM_SIZE_MODE g_mode;   // Current mode shown and used by the panel.

//+------------------------------------------------------------------+
//| User-interface helper functions                                  |
//+------------------------------------------------------------------+
// The following functions provide a small wrapper around standard   |
//| MetaTrader 5 chart objects. Keeping object creation in one place  |
//| makes the panel easier to maintain and keeps visual properties    |
//| consistent across all controls.                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Apply common chart-object properties                              |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Name of the chart object.                                |
//|   x    - Horizontal distance from the selected chart corner.      |
//|   y    - Vertical distance from the selected chart corner.        |
//|   w    - Object width in pixels; ignored when <= 0.               |
//|   h    - Object height in pixels; ignored when <= 0.              |
//|   z    - Object Z-order used to control mouse interaction order.  |
//|                                                                  |
//| Notes:                                                            |
//|   All panel objects are anchored to the upper-left chart corner.  |
//|   Objects are made non-selectable and hidden from the object list |
//|   because they are implementation details of the trading panel.  |
//+------------------------------------------------------------------+
void UiCommon(const string name, const int x, const int y, const int w, const int h, const int z)
  {
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   if(w > 0) ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   if(h > 0) ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, z);
  }

//+------------------------------------------------------------------+
//| Create a rectangular panel/background object                     |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Unique chart-object name.                                |
//|   x/y  - Position in pixels from the upper-left chart corner.    |
//|   w/h  - Width and height in pixels.                              |
//|   bg   - Background color.                                       |
//+------------------------------------------------------------------+
void UiRect(const string name, const int x, const int y, const int w, const int h, const color bg)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   UiCommon(name, x, y, w, h, 0);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, C'60,60,70');
  }

//+------------------------------------------------------------------+
//| Create a text label                                               |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Unique chart-object name.                                |
//|   x/y  - Position in pixels.                                      |
//|   txt  - Initial label text.                                      |
//|   clr  - Text color.                                              |
//|   fs   - Font size.                                               |
//+------------------------------------------------------------------+
void UiLabel(const string name, const int x, const int y, const string txt,
             const color clr = clrWhiteSmoke, const int fs = 9)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   UiCommon(name, x, y, 0, 0, 1);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Create a push button                                              |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Unique chart-object name.                                |
//|   x/y  - Position in pixels.                                      |
//|   w/h  - Button dimensions in pixels.                             |
//|   txt  - Caption displayed on the button.                        |
//|   bg   - Button background color.                                 |
//|   fg   - Button text color.                                       |
//|   fs   - Font size.                                               |
//+------------------------------------------------------------------+
void UiButton(const string name, const int x, const int y, const int w, const int h,
              const string txt, const color bg, const color fg = clrWhite, const int fs = 9)
  {
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   UiCommon(name, x, y, w, h, 2);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI Semibold");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'30,30,36');
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
  }

//+------------------------------------------------------------------+
//| Create an editable input field                                    |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Unique chart-object name.                                |
//|   x/y  - Position in pixels.                                      |
//|   w/h  - Field dimensions in pixels.                              |
//|   txt  - Initial text displayed in the field.                    |
//|                                                                  |
//| The field is intentionally editable so the trader can change lot |
//| size/risk, stop-loss distance and reward:risk before execution.   |
//+------------------------------------------------------------------+
void UiEdit(const string name, const int x, const int y, const int w, const int h, const string txt)
  {
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   UiCommon(name, x, y, w, h, 2);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_READONLY, false);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'45,45,55');
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'90,90,105');
  }

//+------------------------------------------------------------------+
//| Update the text of an existing chart object                       |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Chart-object name.                                       |
//|   txt  - New text.                                                |
//|   clr  - Optional new text color. clrNONE preserves the color.   |
//+------------------------------------------------------------------+
void SetText(const string name, const string txt, const color clr = clrNONE)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   if(clr != clrNONE)
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Read a numeric value from an edit control                         |
//|                                                                  |
//| The function accepts both comma and dot as decimal separators and |
//| converts the resulting string with StringToDouble().              |
//|                                                                  |
//| Returns:                                                          |
//|   Numeric value contained in the edit field.                     |
//+------------------------------------------------------------------+
double ReadEdit(const string name)
  {
   string s = ObjectGetString(0, name, OBJPROP_TEXT);
   StringReplace(s, ",", ".");
   return StringToDouble(s);
  }

//+------------------------------------------------------------------+
//| Display an operation status message                               |
//|                                                                  |
//| Parameters:                                                       |
//|   msg - Message shown at the bottom of the panel.                |
//|   ok  - true displays a success/normal status; false displays an  |
//|         error status.                                             |
//+------------------------------------------------------------------+
void SetStatus(const string msg, const bool ok = true)
  {
   SetText(P_STATUS, msg, ok ? clrLimeGreen : clrTomato);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Panel construction and mode presentation                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Build the complete manual trading panel                           |
//|                                                                  |
//| Creates all labels, edit fields and buttons used by the EA.       |
//| The panel is deliberately implemented with native MT5 chart      |
//| objects, so it works without third-party GUI libraries.           |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   const int x = InpPanelX, y = InpPanelY, w = 250;

   UiRect(P_BG, x, y, w, 378, C'24,24,30');
   UiLabel(P_TITLE, x + 10, y + 8, "MANUAL TRADE PAD", clrGold, 11);

   UiLabel(P_BAL, x + 10, y + 36, "", clrSilver);
   UiLabel(P_EQ,  x + 10, y + 54, "", clrSilver);
   UiLabel(P_FLT, x + 10, y + 72, "", clrSilver);
   UiLabel(P_POS, x + 10, y + 90, "", clrSilver);

   UiLabel(P_LSIZE, x + 10, y + 124, "", clrWhiteSmoke);
   UiEdit(P_ESIZE, x + 85, y + 119, 70, 24, "");
   UiButton(P_BMODE, x + 165, y + 119, 75, 24, "", C'70,70,90', clrWhite, 8);

   UiLabel(P_LSL, x + 10, y + 154, "SL (points)", clrWhiteSmoke);
   UiEdit(P_ESL, x + 85, y + 149, 70, 24, IntegerToString(InpSLPoints));

   UiLabel(P_LRR, x + 10, y + 184, "Reward : Risk", clrWhiteSmoke);
   UiEdit(P_ERR, x + 85, y + 179, 70, 24, DoubleToString(InpRR, 1));

   UiButton(P_BUY,  x + 10,  y + 215, 112, 36, "BUY  [B]",  C'0,130,70',  clrWhite, 11);
   UiButton(P_SELL, x + 128, y + 215, 112, 36, "SELL  [S]", C'190,40,50', clrWhite, 11);

   UiButton(P_BE,   x + 10,  y + 259, 112, 28, "Break-even [E]", C'60,90,140');
   UiButton(P_PART, x + 128, y + 259, 112, 28, "Close 50%",      C'60,90,140');

   UiButton(P_CBUY,  x + 10,  y + 293, 112, 28, "Close BUYs",  C'90,90,100');
   UiButton(P_CSELL, x + 128, y + 293, 112, 28, "Close SELLs", C'90,90,100');

   UiButton(P_CALL, x + 10, y + 327, 230, 28, "CLOSE ALL  [C]", C'120,30,30', clrWhite, 10);

   UiLabel(P_STATUS, x + 10, y + 360, "Ready", clrLimeGreen, 8);

   ApplyModeToUi(true);
  }

//+------------------------------------------------------------------+
//| Synchronize the sizing mode with the user interface               |
//|                                                                  |
//| Parameters:                                                       |
//|   resetValue - If true, replace the current size/risk field with  |
//|                the corresponding input default.                   |
//|                                                                  |
//| SIZE_FIXED_LOT     -> the field represents lots.                  |
//| SIZE_RISK_PERCENT  -> the field represents account-risk percent.  |
//+------------------------------------------------------------------+
void ApplyModeToUi(const bool resetValue)
  {
   if(g_mode == SIZE_FIXED_LOT)
     {
      SetText(P_LSIZE, "Lot size");
      SetText(P_BMODE, "Mode: LOT");
      if(resetValue) SetText(P_ESIZE, DoubleToString(InpFixedLot, 2));
     }
   else
     {
      SetText(P_LSIZE, "Risk %");
      SetText(P_BMODE, "Mode: RISK");
      if(resetValue) SetText(P_ESIZE, DoubleToString(InpRiskPercent, 2));
     }
  }

//+------------------------------------------------------------------+
//| Position filtering and volume-calculation helpers                 |
//+------------------------------------------------------------------+
// All position-management operations are restricted to the current  |
//| symbol and the configured magic number. This prevents the panel   |
//| from accidentally modifying positions belonging to another EA or |
//| another symbol.                                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check whether a position belongs to this trading panel            |
//|                                                                  |
//| Parameters:                                                       |
//|   index - Position index returned by PositionsTotal().            |
//|                                                                  |
//| Returns:                                                          |
//|   true  if the position ticket is valid, belongs to _Symbol and   |
//|         uses InpMagic.                                            |
//|   false otherwise.                                                |
//|                                                                  |
//| PositionGetTicket(index) also selects the position, allowing the  |
//| subsequent PositionGet* calls to read its properties.             |
//+------------------------------------------------------------------+
bool SelectMine(const int index)
  {
   ulong ticket = PositionGetTicket(index);
   if(ticket == 0) return false;
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) return false;
   if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Determine the number of decimal places required for volume        |
//|                                                                  |
//| Returns:                                                          |
//|   Number of decimal digits required to represent the broker's     |
//|   SYMBOL_VOLUME_STEP accurately, up to eight decimal places.      |
//+------------------------------------------------------------------+
int LotDigits()
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int d = 0;
   while(d < 8 && MathAbs(step * MathPow(10, d) - MathRound(step * MathPow(10, d))) > 1e-8)
      d++;
   return d;
  }

//+------------------------------------------------------------------+
//| Normalize a trading volume to broker constraints                  |
//|                                                                  |
//| The requested volume is rounded down to the nearest volume step   |
//| and then constrained between SYMBOL_VOLUME_MIN and               |
//| SYMBOL_VOLUME_MAX.                                                |
//|                                                                  |
//| Parameters:                                                       |
//|   lot - Requested volume in lots.                                 |
//|                                                                  |
//| Returns:                                                          |
//|   Broker-compatible volume, or the broker minimum when the volume  |
//|   step cannot be obtained.                                        |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0) return vmin;
   lot = MathFloor(lot / step + 1e-9) * step;
   lot = MathMax(vmin, MathMin(vmax, lot));
   return NormalizeDouble(lot, LotDigits());
  }

//+------------------------------------------------------------------+
//| Calculate the initial order volume                                |
//|                                                                  |
//| Parameters:                                                       |
//|   slPoints - Stop-loss distance in points.                        |
//|                                                                  |
//| Returns:                                                          |
//|   Normalized lot size. Zero means the input or symbol's tick      |
//|   information is invalid and the trade should not be sent.        |
//|                                                                  |
//| Fixed-lot mode returns the user-entered volume. In risk-percent   |
//| mode the function converts the selected percentage of balance into |
//| a monetary risk amount and divides it by the estimated loss of    |
//| one lot at the specified SL distance.                              |
//+------------------------------------------------------------------+
double CalcLot(const int slPoints)
  {
   double input_val = ReadEdit(P_ESIZE);
   if(input_val <= 0) return 0.0;

   if(g_mode == SIZE_FIXED_LOT)
      return NormalizeLot(input_val);

   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * input_val / 100.0;
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickValue <= 0 || tickSize <= 0) return 0.0;

   // Convert the SL distance from points into an estimated monetary
   // loss for one lot using the symbol's tick size/value information.
   double lossPerLot = slPoints * _Point / tickSize * tickValue;
   if(lossPerLot <= 0) return 0.0;
   return NormalizeLot(riskMoney / lossPerLot);
  }

//+------------------------------------------------------------------+
//| Trading and position-management actions                           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open a market BUY or SELL position                                |
//|                                                                  |
//| Parameters:                                                       |
//|   isBuy - true opens a BUY; false opens a SELL.                   |
//|                                                                  |
//| Processing:                                                       |
//|   1. Read and validate SL and R:R values.                         |
//|   2. Respect the broker's minimum stop distance.                  |
//|   3. Calculate volume according to the selected sizing mode.      |
//|   4. Calculate SL and optional TP from the current market price.  |
//|   5. Check available free margin.                                 |
//|   6. Submit the market order through CTrade.                      |
//|                                                                  |
//| The order is tagged with the fixed comment "MTP" and uses the     |
//| configured magic number.                                          |
//+------------------------------------------------------------------+
void OpenTrade(const bool isBuy)
  {
   int minStop = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int slPts   = (int)ReadEdit(P_ESL);
   double rr   = ReadEdit(P_ERR);

   if(slPts <= 0)
     {
      SetStatus("Invalid SL distance", false);
      return;
     }
   // Never request an SL closer than the broker's minimum stop distance.
   // One additional point is used to avoid equality/rounding edge cases.
   slPts = MathMax(slPts, minStop + 1);

   double lot = CalcLot(slPts);
   if(lot <= 0)
     {
      SetStatus("Invalid lot / risk value", false);
      return;
     }

   double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = isBuy ? ask : bid;

   double sl = isBuy ? price - slPts * _Point : price + slPts * _Point;
   double tp = 0.0;
   if(rr > 0)
      tp = isBuy ? price + slPts * rr * _Point : price - slPts * rr * _Point;

   sl = NormalizeDouble(sl, _Digits);
   tp = (tp > 0) ? NormalizeDouble(tp, _Digits) : 0.0;

   double margin = 0.0;
   if(OrderCalcMargin(isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, lot, price, margin))
     {
      if(margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
        {
         SetStatus("Not enough free margin", false);
         return;
        }
     }

   bool ok = isBuy ? g_trade.Buy(lot, _Symbol, 0.0, sl, tp, "MTP")
                   : g_trade.Sell(lot, _Symbol, 0.0, sl, tp, "MTP");

   if(ok)
      SetStatus(StringFormat("%s %.2f lots | SL %d pts", isBuy ? "BUY" : "SELL", lot, slPts));
   else
      SetStatus(StringFormat("Order failed: %d", g_trade.ResultRetcode()), false);
  }

//+------------------------------------------------------------------+
//| Close selected positions                                          |
//|                                                                  |
//| Parameters:                                                       |
//|   direction - 1 closes BUY positions only;                       |
//|              -1 closes SELL positions only;                      |
//|               0 closes both directions.                           |
//|                                                                  |
//| Only positions passing SelectMine() are affected.                 |
//| Returns no value; the result is reported through the panel status |
//| message.                                                          |
//+------------------------------------------------------------------+
void ClosePositions(const int direction)
  {
   int closed = 0;

   // Iterate backwards because successful position closes can change
   // the collection while it is being traversed.
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(direction == 1  && type != POSITION_TYPE_BUY)  continue;
      if(direction == -1 && type != POSITION_TYPE_SELL) continue;
      if(g_trade.PositionClose(PositionGetInteger(POSITION_TICKET)))
         closed++;
     }
   SetStatus(StringFormat("Closed %d position(s)", closed));
  }

//+------------------------------------------------------------------+
//| Close approximately 50 percent of each eligible position          |
//|                                                                  |
//| The requested partial volume is half of the current position      |
//| volume, normalized to the broker's volume step. The operation is  |
//| skipped when the remaining volume or closing volume would violate |
//| the broker's minimum volume constraint.                           |
//+------------------------------------------------------------------+
void ClosePartial()
  {
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   int done = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      double vol  = PositionGetDouble(POSITION_VOLUME);
      double part = NormalizeLot(vol / 2.0);
      if(part < vmin || vol - part < vmin) continue;
      if(g_trade.PositionClosePartial(PositionGetInteger(POSITION_TICKET), part))
         done++;
     }
   SetStatus(done > 0 ? StringFormat("Partial close on %d position(s)", done)
                      : "Nothing to partially close", done > 0);
  }

//+------------------------------------------------------------------+
//| Move eligible positions to break-even plus an optional offset     |
//|                                                                  |
//| BUY positions are moved to open price + InpBEOffset points.       |
//| SELL positions are moved to open price - InpBEOffset points.      |
//|                                                                  |
//| The broker's minimum stop distance is checked before modification, |
//| and an existing SL is never moved backwards. Existing TP values   |
//| are preserved.                                                    |
//+------------------------------------------------------------------+
void MoveToBreakEven()
  {
   double stopLvl = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int moved = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;

      long   type = PositionGetInteger(POSITION_TYPE);
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl   = PositionGetDouble(POSITION_SL);
      double tp   = PositionGetDouble(POSITION_TP);
      double newSL;

      if(type == POSITION_TYPE_BUY)
        {
         newSL = open + InpBEOffset * _Point;
         if(bid - newSL <= stopLvl) continue;
         if(sl != 0.0 && sl >= newSL) continue;
        }
      else
        {
         newSL = open - InpBEOffset * _Point;
         if(newSL - ask <= stopLvl) continue;
         if(sl != 0.0 && sl <= newSL) continue;
        }

      if(g_trade.PositionModify(PositionGetInteger(POSITION_TICKET), NormalizeDouble(newSL, _Digits), tp))
         moved++;
     }
   SetStatus(moved > 0 ? StringFormat("Break-even set on %d position(s)", moved)
                       : "No position can move to break-even", moved > 0);
  }

//+------------------------------------------------------------------+
//| Information display                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Refresh account and position information shown on the panel       |
//|                                                                  |
//| Displays balance, equity, floating P/L and the number of open      |
//| positions managed by this panel. Floating P/L includes both       |
//| POSITION_PROFIT and POSITION_SWAP.                                |
//+------------------------------------------------------------------+
void UpdateInfo()
  {
   double floating = 0.0;
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      floating += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      count++;
     }

   SetText(P_BAL, StringFormat("Balance : %.2f", AccountInfoDouble(ACCOUNT_BALANCE)));
   SetText(P_EQ,  StringFormat("Equity  : %.2f", AccountInfoDouble(ACCOUNT_EQUITY)));
   SetText(P_FLT, StringFormat("Floating: %+.2f", floating),
           floating > 0 ? clrLimeGreen : (floating < 0 ? clrTomato : clrSilver));
   SetText(P_POS, StringFormat("Open positions: %d", count));
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Event dispatch and button polling                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Process a panel object interaction                                 |
//|                                                                  |
//| Parameters:                                                       |
//|   name - Name of the chart object that generated the interaction.  |
//|                                                                  |
//| The function validates that the object belongs to this panel,     |
//| consumes button state to prevent duplicate execution, and routes  |
//| the action to the corresponding trading function.                 |
//+------------------------------------------------------------------+
void HandleObject(const string name)
  {
   if(StringFind(name, "MTP_") != 0) return;

   // buttons: act only if still pressed, then release (prevents double execution)
   if(ObjectGetInteger(0, name, OBJPROP_TYPE) == OBJ_BUTTON)
     {
      if(!ObjectGetInteger(0, name, OBJPROP_STATE)) return;
      ObjectSetInteger(0, name, OBJPROP_STATE, false);
     }
   else
      return;

   if(name == P_BUY)        OpenTrade(true);
   else if(name == P_SELL)  OpenTrade(false);
   else if(name == P_BE)    MoveToBreakEven();
   else if(name == P_PART)  ClosePartial();
   else if(name == P_CBUY)  ClosePositions(1);
   else if(name == P_CSELL) ClosePositions(-1);
   else if(name == P_CALL)  ClosePositions(0);
   else if(name == P_BMODE)
     {
      g_mode = (g_mode == SIZE_FIXED_LOT) ? SIZE_RISK_PERCENT : SIZE_FIXED_LOT;
      ApplyModeToUi(true);
     }
   UpdateInfo();
  }

//+------------------------------------------------------------------+
//| Poll button states as a fallback event mechanism                   |
//|                                                                  |
//| The normal interaction path is CHARTEVENT_OBJECT_CLICK. The       |
//| polling pass provides a safety net for situations in which a chart |
//| click event is not delivered while the tester is running.         |
//+------------------------------------------------------------------+
void PollButtons()
  {
   string btns[] = {P_BUY, P_SELL, P_BE, P_PART, P_CBUY, P_CSELL, P_CALL, P_BMODE};
   for(int i = 0; i < ArraySize(btns); i++)
      if(ObjectGetInteger(0, btns[i], OBJPROP_STATE))
         HandleObject(btns[i]);
  }

//+------------------------------------------------------------------+
//| Expert Advisor event handlers                                     |
//+------------------------------------------------------------------+
// The EA uses the standard MQL5 event model:                       |
//|   OnInit()       -> initialize trading and build the panel.        |
//|   OnDeinit()     -> remove all panel objects.                     |
//|   OnTick()       -> poll controls and refresh account information. |
//|   OnChartEvent() -> react immediately to mouse/keyboard input.    |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization                                             |
//|                                                                  |
//| Configures the CTrade object, initializes the selected sizing      |
//| mode, creates the panel and performs the first information refresh. |
//|                                                                  |
//| Returns:                                                          |
//|   INIT_SUCCEEDED when initialization completes successfully.      |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_mode = InpSizeMode;
   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpDeviation);
   g_trade.SetTypeFillingBySymbol(_Symbol);

   BuildPanel();
   UpdateInfo();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//|                                                                  |
//| Parameters:                                                       |
//|   reason - Standard MQL5 deinitialization reason supplied by the   |
//|            terminal/tester. The reason is not otherwise required   |
//|            by this implementation.                                |
//|                                                                  |
//| All objects with the MTP_ prefix are removed from the chart.      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "MTP_");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Tick event                                                        |
//|                                                                  |
//| Runs on every incoming tick. Button polling is performed as a      |
//| fallback, while UpdateInfo() keeps the account/position display   |
//| synchronized with the tester.                                     |
//+------------------------------------------------------------------+
void OnTick()
  {
   PollButtons();   // fallback in case a click event was missed
   UpdateInfo();
  }

//+------------------------------------------------------------------+
//| Chart-event handler                                               |
//|                                                                  |
//| Parameters:                                                       |
//|   id     - Event identifier defined by MQL5.                      |
//|   lparam - Event-specific long parameter (used for key codes).    |
//|   dparam - Event-specific double parameter.                       |
//|   sparam - Event-specific string parameter (object name here).    |
//|                                                                  |
//| Supported events:                                                 |
//|   CHARTEVENT_OBJECT_CLICK - panel button clicks.                  |
//|   CHARTEVENT_KEYDOWN       - keyboard shortcuts: B, S, E and C.   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      HandleObject(sparam);
      return;
     }

   if(id == CHARTEVENT_KEYDOWN)
     {
      switch((int)lparam)
        {
         case 'B': OpenTrade(true);  UpdateInfo(); break;
         case 'S': OpenTrade(false); UpdateInfo(); break;
         case 'E': MoveToBreakEven(); UpdateInfo(); break;
         case 'C': ClosePositions(0); UpdateInfo(); break;
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                      Manual_Trade_Pad_Tester_MT4.mq4 |
//|   Risk-based manual trading pad for the MetaTrader 4 Tester      |
//+------------------------------------------------------------------+
//| Description:                                                     |
//|   A lightweight manual trading panel designed for the visual      |
//|   Strategy Tester and chart-based manual backtesting in MetaTrader |
//|   4. The EA can open market BUY/SELL orders, calculate volume     |
//|   from a fixed lot or account-risk percentage, attach an optional  |
//|   risk/reward based take-profit, move positions to break-even,     |
//|   partially close positions, and close positions by direction.    |
//|                                                                  |
//| Position scope:                                                   |
//|   Only positions belonging to the current symbol (Symbol()) and    |
//|   the configured magic number (InpMagic) are managed.             |
//|                                                                  |
//| Keyboard shortcuts:                                               |
//|   B = BUY                                                         |
//|   S = SELL                                                        |
//|   E = Move managed positions to break-even                        |
//|   C = Close all managed positions                                 |
//|                                                                  |
//| Implementation notes:                                             |
//|   The panel uses native MQL4 OBJ_* chart objects and built-in     |
//|   trade functions: OrderSend, OrderClose and OrderModify.         |
//|   No external libraries are required.                             |
//+------------------------------------------------------------------+
#property copyright "Amirhossein Heydarijokani"
#property link      "https://www.mql5.com"
#property version   "1.000"
#property description "MT4 manual trading pad for visual Strategy Tester backtesting."
#property description "Risk-% or fixed lot sizing, automatic R:R take profit,"
#property description "break-even, partial close, side-specific close and hotkeys."
#property strict
//+------------------------------------------------------------------+
//| BEGINNER'S GUIDE TO THIS SOURCE FILE                             |
//|                                                                  |
//| This file is an Expert Advisor (EA), not a custom indicator.     |
//| An EA can receive terminal events and send/manage trade orders.  |
//|                                                                  |
//| HOW TO READ MQL4 CODE                                            |
//|   input    = a setting shown in the EA Properties dialog.        |
//|   const    = a value that this program does not change.          |
//|   bool     = true/false; int = whole number; double = decimal;   |
//|   string   = text; color = a chart color.                        |
//|   if       = run code only when a condition is true.             |
//|   for      = repeat a block, commonly for each open order.       |
//|   return   = leave a function, optionally returning a value.     |
//|   void     = a function that does not return a value.            |
//|   //       = comment for humans; it is ignored by the compiler.  |
//|                                                                  |
//| MAIN PROGRAM FLOW                                                |
//|   OnInit()       creates the panel when the EA starts.           |
//|   OnTick()       refreshes information and checks button states. |
//|   OnChartEvent() handles clicks and keyboard shortcuts.          |
//|   OnDeinit()     removes the panel objects when the EA stops.    |
//|                                                                  |
//| TRADING SAFETY                                                   |
//|   Only market BUY/SELL orders on the chart symbol with the       |
//|   configured magic number are managed. A magic number is an      |
//|   identifier, not a password or a security boundary.             |
//|   Risk-percent sizing is an estimate based on broker tick data;  |
//|   gaps, slippage, commission and execution conditions can make   |
//|   actual loss differ from the estimate. Test on demo first.      |
//+------------------------------------------------------------------+



//--- Position sizing mode used for calculating the initial order volume
enum ENUM_SIZE_MODE
  {
   SIZE_FIXED_LOT    = 0,   // Use the entered volume directly.
   SIZE_RISK_PERCENT = 1    // Calculate volume from a percentage of balance.
  };

//--- User-configurable inputs
//    Trading inputs control order identification, volume calculation,
//    stop-loss/take-profit behavior and trade execution tolerance.
// Trading inputs
// InpMagic: order identifier. Use a different value if you want this
// panel to manage a separate set of trades from another EA/panel.
// InpSizeMode: initial sizing mode; the panel's Mode button can switch it.
// InpFixedLot / InpRiskPercent: default values loaded into the edit field.
// InpSLPoints: stop-loss distance measured in points, not pips.
// InpRR: TP distance = SL distance * this ratio; zero disables TP.
// InpBEOffset: extra points beyond the entry price when moving to BE.
// InpDeviation: maximum permitted slippage, expressed in points.
input int            InpMagic       = 5170001;          // Unique magic number used to identify managed positions.
input ENUM_SIZE_MODE InpSizeMode    = SIZE_RISK_PERCENT;// Initial volume-sizing mode.
input double         InpFixedLot    = 0.10;             // Default fixed volume in lots.
input double         InpRiskPercent = 1.0;              // Default percentage of balance to risk per trade.
input int            InpSLPoints    = 300;              // Default stop-loss distance in points.
input double         InpRR          = 2.0;              // Default reward:risk ratio; 0 disables TP.
input int            InpBEOffset    = 10;               // Break-even SL offset in points.
input int            InpDeviation   = 20;               // Maximum allowed price deviation in points.

// Panel inputs (pixel offsets from the chart's upper-left corner).
input int            InpPanelX      = 15;               // Horizontal panel position in pixels.
input int            InpPanelY      = 25;               // Vertical panel position in pixels.

//--- Chart-object names
//    P_ is a short prefix for source-code constants; the actual object
//    names start with MTP_. OnDeinit() removes objects with that prefix.
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

//--- Current volume-sizing mode selected in the panel.
//    This is a runtime variable because the user can switch modes
//    while the EA is running. It starts with the InpSizeMode input.
ENUM_SIZE_MODE g_sizingMode;

//+------------------------------------------------------------------+
//| User-interface helper functions                                  |
//+------------------------------------------------------------------+
//| The following helpers wrap standard MetaTrader 4 chart objects.  |
//| Centralizing creation keeps controls consistent and makes layout  |
//| changes easier.                                                   |
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
   // ObjectSetInteger changes a property of an object already created on chart 0.
   // Chart 0 means the chart to which this EA is attached.
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
//| The function accepts comma or dot as the decimal separator and    |
//| converts the resulting text to a double with StringToDouble().   |
//|                                                                  |
//| Returns:                                                          |
//|   Numeric value contained in the edit field.                     |
//+------------------------------------------------------------------+
double ReadEdit(const string name)
  {
   // Edit fields store text, so convert it to a number before using it in calculations.
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
//| The panel uses native MT4 chart objects, so no third-party GUI    |
//| library is needed. Object names are stored in P_* constants.      |
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
//| Synchronize the volume-sizing mode with the user interface       |
//|                                                                  |
//| Parameters:                                                       |
//|   resetValue - If true, reload the default lot/risk input value.  |
//|                If false, preserve what the user typed.            |
//|                                                                  |
//| SIZE_FIXED_LOT     -> the field represents lots.                  |
//| SIZE_RISK_PERCENT  -> the field represents account-risk percent.  |
//+------------------------------------------------------------------+
void ApplyModeToUi(const bool resetValue)
  {
   if(g_sizingMode == SIZE_FIXED_LOT)
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
//| Order filtering and volume-calculation helpers                    |
//+------------------------------------------------------------------+
// All management operations are restricted to the current symbol and|
//| configured magic number. This helps avoid changing another EA's  |
//| trades or trades on another symbol.                                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check whether a position belongs to this trading panel            |
//|                                                                  |
//| Parameters:                                                       |
//|   index - Zero-based position in the active-order list.           |
//|                                                                  |
//| Returns true only when OrderSelect succeeds and the selected     |
//| order is a market BUY/SELL for this symbol and this magic number.|
//| OrderSelect(index, SELECT_BY_POS, MODE_TRADES) selects an active  |
//| order by its list index. Order* functions then read its details.  |
//| Closing orders changes the list, so closing loops run backwards. |
//+------------------------------------------------------------------+
bool SelectMine(const int index)
  {
   // Each check rejects an order that should not be touched by this panel.
   if(!OrderSelect(index, SELECT_BY_POS, MODE_TRADES)) return false;
   if(OrderSymbol() != Symbol()) return false;
   if(OrderMagicNumber() != InpMagic) return false;
   if(OrderType() != OP_BUY && OrderType() != OP_SELL) return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Determine the decimal precision required for order volume         |
//|                                                                  |
//| MODE_LOTSTEP is the broker's allowed volume increment (for example|
//| 0.01). This function finds how many decimal places represent that |
//| increment accurately, up to eight places.                         |
//+------------------------------------------------------------------+
int LotDigits()
  {
   double step = MarketInfo(Symbol(), MODE_LOTSTEP);
   int d = 0;
   while(d < 8 && MathAbs(step * MathPow(10, d) - MathRound(step * MathPow(10, d))) > 1e-8)
      d++;
   return d;
  }

//+------------------------------------------------------------------+
//| Normalize a trading volume to broker constraints                  |
//|                                                                  |
//| The requested volume is rounded down to the nearest volume step   |
//| and then constrained between MODE_MINLOT and MODE_MAXLOT.                                                                |
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
   // Brokers define allowed volume steps (for example 0.01 lots).
   // Floor prevents rounding the requested volume upward beyond the intended risk.
   double step = MarketInfo(Symbol(), MODE_LOTSTEP);
   double vmin = MarketInfo(Symbol(), MODE_MINLOT);
   double vmax = MarketInfo(Symbol(), MODE_MAXLOT);
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
   // The visible field means either lots or risk percent, depending on g_sizingMode.
   double enteredSizeValue = ReadEdit(P_ESIZE); // Lots in fixed mode; percent in risk mode.
   if(enteredSizeValue <= 0) return 0.0;

   if(g_sizingMode == SIZE_FIXED_LOT)
      return NormalizeLot(enteredSizeValue);

   double riskMoney = AccountBalance() * enteredSizeValue / 100.0;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize  = MarketInfo(Symbol(), MODE_TICKSIZE);
   if(tickValue <= 0 || tickSize <= 0) return 0.0;

   // Convert the SL distance from points into an estimated monetary
   // loss for one lot using the symbol's tick size/value information.
   double lossPerLot = slPoints / tickSize * tickValue;
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
//|   6. Submit the market order through MQL4 OrderSend().             |
//|                                                                  |
//| The order receives comment "MTP" and the configured magic number.|
//| OrderSend() returns a ticket on success, or -1 on failure.       |
//| GetLastError() retrieves the terminal error code.                |
//+------------------------------------------------------------------+
void OpenTrade(const bool isBuy)
  {
   // Refresh Bid/Ask immediately before calculating the entry and protective levels.
   RefreshRates();
   int minStop = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   int slPts   = (int)ReadEdit(P_ESL);
   double rr   = ReadEdit(P_ERR);
   if(slPts <= 0) { SetStatus("Invalid SL distance", false); return; }
   slPts = MathMax(slPts, minStop + 1);
   double lot = CalcLot(slPts);
   if(lot <= 0) { SetStatus("Invalid lot / risk value", false); return; }

   double price = isBuy ? Ask : Bid;
   double sl = isBuy ? price - slPts * Point : price + slPts * Point;
   double tp = 0.0;
   if(rr > 0) tp = isBuy ? price + slPts * rr * Point : price - slPts * rr * Point;
   sl = NormalizeDouble(sl, Digits);
   if(tp > 0) tp = NormalizeDouble(tp, Digits);

   double margin = AccountFreeMarginCheck(Symbol(), isBuy ? OP_BUY : OP_SELL, lot);
   if(margin <= 0)
     { SetStatus("Not enough free margin", false); return; }

   // OrderSend arguments: symbol, type, lots, requested price, slippage, SL, TP,
   // comment, magic number, expiration (0 for market orders), chart arrow color.
   int ticket = OrderSend(Symbol(), isBuy ? OP_BUY : OP_SELL, lot, price,
                          InpDeviation, sl, tp, "MTP", InpMagic, 0,
                          isBuy ? clrDodgerBlue : clrTomato);
   if(ticket > 0)
      SetStatus(StringFormat("%s %.2f lots | SL %d pts", isBuy ? "BUY" : "SELL", lot, slPts));
   else
      SetStatus(StringFormat("Order failed: %d", GetLastError()), false);
  }

//+------------------------------------------------------------------+
//| Close selected positions                                          |
//|                                                                  |
//| Parameters:                                                       |
//|   direction - 1 closes BUY positions only;                       |
//|              -1 closes SELL positions only;                      |
//|               0 closes both directions.                           |
//|                                                                  |
//| Only orders passing SelectMine() are affected. The result is      |
//| reported through the panel status message.                       |
//| message.                                                          |
//+------------------------------------------------------------------+
void ClosePositions(const int direction)
  {
   // Iterate from the last order toward the first because closing changes the list.
   int closed = 0;
   RefreshRates();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      int type = OrderType();
      if(direction == 1 && type != OP_BUY) continue;
      if(direction == -1 && type != OP_SELL) continue;
      double price = (type == OP_BUY) ? Bid : Ask;
      if(OrderClose(OrderTicket(), OrderLots(), price, InpDeviation, clrSilver)) closed++;
     }
   SetStatus(StringFormat("Closed %d order(s)", closed));
  }

//+------------------------------------------------------------------+
//| Close approximately 50 percent of each eligible position          |
//|                                                                  |
//| The requested close volume is half of the current order volume,   |
//| rounded to a broker-valid volume step. The operation is skipped  |
//| if either the closed part or remaining part is below minimum lot. |
//+------------------------------------------------------------------+
void ClosePartial()
  {
   // A partial close is still an OrderClose() call, but with less than OrderLots().
   double vmin = MarketInfo(Symbol(), MODE_MINLOT);
   int done = 0;
   RefreshRates();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      double vol = OrderLots();
      double part = NormalizeLot(vol / 2.0);
      if(part < vmin || vol - part < vmin) continue;
      double price = (OrderType() == OP_BUY) ? Bid : Ask;
      if(OrderClose(OrderTicket(), part, price, InpDeviation, clrSilver)) done++;
     }
   SetStatus(done > 0 ? StringFormat("Partial close on %d order(s)", done)
                      : "Nothing to partially close", done > 0);
  }

//+------------------------------------------------------------------+
//| Move eligible positions to break-even plus an optional offset     |
//|                                                                  |
//| BUY positions are moved to open price + InpBEOffset points.       |
//| SELL positions are moved to open price - InpBEOffset points.      |
//|                                                                  |
//| The broker minimum stop distance is checked before modification.  |
//| An existing SL is never moved backwards, and the TP is preserved. |                                                    |
//+------------------------------------------------------------------+
void MoveToBreakEven()
  {
   // OrderModify() changes SL while retaining the original TP.
   RefreshRates();
   double stopLvl = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   int moved = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      int type = OrderType();
      double open = OrderOpenPrice(), sl = OrderStopLoss(), tp = OrderTakeProfit(), newSL;
      if(type == OP_BUY)
        {
         newSL = open + InpBEOffset * Point;
         if(Bid - newSL <= stopLvl) continue;
         if(sl != 0.0 && sl >= newSL) continue;
        }
      else
        {
         newSL = open - InpBEOffset * Point;
         if(newSL - Ask <= stopLvl) continue;
         if(sl != 0.0 && sl <= newSL) continue;
        }
      if(OrderModify(OrderTicket(), open, NormalizeDouble(newSL, Digits), tp, 0, clrNONE)) moved++;
     }
   SetStatus(moved > 0 ? StringFormat("Break-even set on %d order(s)", moved)
                       : "No order can move to break-even", moved > 0);
  }

//+------------------------------------------------------------------+
//| Information display                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Refresh account and position information shown on the panel       |
//|                                                                  |
//| Displays balance, equity, floating P/L and the number of open      |
//| positions managed by this panel. Floating P/L includes both       |
//| OrderProfit, OrderSwap and OrderCommission.                                |
//+------------------------------------------------------------------+
void UpdateInfo()
  {
   // These totals intentionally include only orders accepted by SelectMine().
   double floating = 0.0;
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!SelectMine(i)) continue;
      floating += OrderProfit() + OrderSwap() + OrderCommission();
      count++;
     }
   SetText(P_BAL, StringFormat("Balance : %.2f", AccountBalance()));
   SetText(P_EQ,  StringFormat("Equity  : %.2f", AccountEquity()));
   SetText(P_FLT, StringFormat("Floating: %+.2f", floating),
           floating > 0 ? clrLimeGreen : (floating < 0 ? clrTomato : clrSilver));
   SetText(P_POS, StringFormat("Open orders: %d", count));
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
//| checks that it is a button, resets its pressed state to reduce   |
//| duplicate execution, and routes the action to a trading function.                 |
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
      g_sizingMode = (g_sizingMode == SIZE_FIXED_LOT) ? SIZE_RISK_PERCENT : SIZE_FIXED_LOT;
      ApplyModeToUi(true);
     }
   UpdateInfo();
  }

//+------------------------------------------------------------------+
//| Poll button states as a fallback event mechanism                   |
//|                                                                  |
//| The normal interaction path is CHARTEVENT_OBJECT_CLICK. Polling   |
//| is a fallback in case a click event is missed by the tester.      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check one button's pressed state                                  |
//|                                                                  |
//| Parameters:                                                       |
//|   button_name - Name of the button chart object to check.         |
//|                                                                  |
//| OBJPROP_STATE is true while a button is pressed. HandleObject()  |
//| resets it and runs the action, so this helper does not duplicate |
//| the button-action logic.                                          |
//+------------------------------------------------------------------+
void PollOneButton(const string button_name)
  {
   if(ObjectGetInteger(0, button_name, OBJPROP_STATE))
      HandleObject(button_name);
  }

//+------------------------------------------------------------------+
//| Check all action buttons                                          |
//|                                                                  |
//| Called on each tick as a fallback for chart click events. The     |
//| buttons are listed explicitly for compatibility with older MT4    |
//| compilers that may reject constant strings in array initializers. |
//+------------------------------------------------------------------+
void PollButtons()
  {
   // Avoid arrays/initializers entirely: older MT4 compilers can reject
   // const-string identifiers in array initializer expressions.
   PollOneButton(P_BUY);
   PollOneButton(P_SELL);
   PollOneButton(P_BE);
   PollOneButton(P_PART);
   PollOneButton(P_CBUY);
   PollOneButton(P_CSELL);
   PollOneButton(P_CALL);
   PollOneButton(P_BMODE);
  }

//+------------------------------------------------------------------+
//| Expert Advisor event handlers                                     |
//+------------------------------------------------------------------+
//| The EA uses the standard MQL4 event model:                        |
//|   OnInit()       -> initialize state and build the panel.         |
//|   OnDeinit()     -> remove this EA's panel objects.               |
//|   OnTick()       -> poll buttons and refresh account information. |
//|   OnChartEvent() -> react to chart clicks and keyboard input.     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization                                             |
//|                                                                  |
//| Initializes the selected sizing mode, creates the panel and       |
//| performs the first information refresh. MQL4 trade functions are  |
//| built in; this EA does not use a CTrade object.                   |
//|                                                                  |
//| Returns:                                                          |
//|   INIT_SUCCEEDED when initialization completes successfully.      |
//+------------------------------------------------------------------+
int OnInit()
  {
   // OnInit is called once when the EA is attached or initialized by the tester.
   g_sizingMode = InpSizeMode;

   BuildPanel();
   UpdateInfo();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                           |
//|                                                                  |
//| Parameters:                                                       |
//|   reason - Standard MQL4 deinitialization reason supplied by the   |
//|            terminal/tester. The reason is not otherwise required   |
//|            by this implementation.                                |
//|                                                                  |
//| All objects with the MTP_ prefix are removed from the chart.      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Delete only objects whose names begin with our unique MTP_ prefix.
   ObjectsDeleteAll(0, "MTP_");
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Tick event                                                        |
//|                                                                  |
//| Runs when a new price tick arrives. PollButtons() is a fallback   |
//| for button clicks; UpdateInfo() refreshes account and order data. |
//| During quiet markets, no new tick means no OnTick() call.         |
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
//|   id     - Event type, such as a button click or key press.       |
//|   lparam - Long value; for key presses it contains the key code.  |
//|   dparam - Double value supplied by the event (unused here).     |
//|   sparam - String value; for object clicks it contains the name.  |
//|                                                                  |
//| Supported events:                                                 |
//|   CHARTEVENT_OBJECT_CLICK - panel button clicks.                  |
//|   CHARTEVENT_KEYDOWN       - keyboard shortcuts: B, S, E and C.   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   // The terminal calls this when a chart object or keyboard event occurs.
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

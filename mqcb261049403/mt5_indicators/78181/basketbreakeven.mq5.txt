//+------------------------------------------------------------------+
//|                                              BasketBreakEven.mq5 |
//|   Break-even and target price of all open positions on a symbol   |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// With several positions on one symbol (grid, averaging, hedging,
// scaling in) it is hard to see where the whole basket breaks even.
// This indicator draws:
//   - Buy break-even  : price where all buys together are at zero
//   - Sell break-even : price where all sells together are at zero
//   - Net break-even  : price where buys + sells together are at zero
//   - Target          : price where the basket makes the profit you set
// Swap can be included. Without swap the break-even levels are exact.
// The swap part and the target use the current tick value, so on symbols
// whose profit currency is not the account currency they are close
// approximations. The spread is not included (the buy level is a Bid
// price, the sell level an Ask price). Commission is not included.
// If buys and sells have the same volume the basket is fully hedged and
// its P/L does not change with price, so there is no net level.
// Planned positions: before you enter, type the planned entries in the
// input, e.g. "B 0.10 1.0850; B 0.10 1.0820; S 0.05 1.0900", and the
// levels show where the whole basket would break even. They are added
// to the open positions (they are not traded).
// Read-only: the indicator never trades.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Draws the break-even price of all buys, all sells and the whole basket of"
#property description "open positions on the chart symbol, plus an optional target-profit line."
#property description "Planned entries can be added to see the break-even before you trade."
#property description "Useful for grid, averaging and hedging. Read-only: it never trades."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input long            InpMagic       = -1;            // Only this magic number (-1 = all)
input bool            InpIncludeSwap = true;          // Include swap
input double          InpTarget      = 0.0;           // Target profit line, account currency (0 = off)
input string          InpPlanned     = "";            // Planned positions, e.g. B 0.10 1.0850; S 0.05 1.0900
input bool            InpShowBuy     = true;          // Buy break-even line
input bool            InpShowSell    = true;          // Sell break-even line
input bool            InpShowNet     = true;          // Net break-even line (when buys and sells are open)
input color           InpBuyColor    = clrDodgerBlue; // Buy colour
input color           InpSellColor   = clrOrangeRed;  // Sell colour
input color           InpNetColor    = clrGoldenrod;  // Net colour
input color           InpTargetColor = clrSeaGreen;   // Target colour
input ENUM_LINE_STYLE InpStyle       = STYLE_DASH;    // Line style
input int             InpWidth       = 1;             // Line width
input bool            InpShowInfo    = true;          // Info text (lower left corner)
input color           InpInfoColor   = clrGray;       // Info colour
input int             InpFontSize    = 9;             // Font size

#define PFX "BasketBE_"

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "Basket Break-Even");
   //--- the timer catches position changes between ticks; the tester calls OnCalculate on every tick
   if(!MQLInfoInteger(MQL_TESTER))
      EventSetTimer(1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   Update();
   return rates_total;
  }

//+------------------------------------------------------------------+
//| Timer: update when positions change without a tick               |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Update();
  }

//+------------------------------------------------------------------+
//| Collect the positions and draw the levels                        |
//+------------------------------------------------------------------+
void Update()
  {
   double buyVol = 0.0, sellVol = 0.0;   // lots
   double buySum = 0.0, sellSum = 0.0;   // sum of lots * open price
   double buySwap = 0.0, sellSwap = 0.0, floating = 0.0;
   int    buys = 0, sells = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if(InpMagic >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagic)
         continue;
      double lots  = PositionGetDouble(POSITION_VOLUME);
      double price = PositionGetDouble(POSITION_PRICE_OPEN);
      double swap  = PositionGetDouble(POSITION_SWAP);
      floating += PositionGetDouble(POSITION_PROFIT) + swap;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
         buyVol  += lots;
         buySum  += lots * price;
         buySwap += swap;
         buys++;
        }
      else
        {
         sellVol  += lots;
         sellSum  += lots * price;
         sellSwap += swap;
         sells++;
        }
     }
   int planned = AddPlanned(buyVol, buySum, buys, sellVol, sellSum, sells);

   // money for a move of 1.0 in price with 1 lot
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double k         = (tickSize > 0) ? tickValue / tickSize : 0.0;
   double swB       = InpIncludeSwap ? buySwap : 0.0;
   double swS       = InpIncludeSwap ? sellSwap : 0.0;

   // buys:  P/L(P) = k * buyVol  * (P - avgBuy)  + swB = 0
   if(InpShowBuy && buys > 0 && k > 0)
      DrawLevel("buy", buySum / buyVol - swB / (k * buyVol), InpBuyColor, StringFormat("Buy BE %s lot", DoubleToString(buyVol, 2)));
   else
      RemoveLevel("buy");

   // sells: P/L(P) = k * sellVol * (avgSell - P) + swS = 0
   if(InpShowSell && sells > 0 && k > 0)
      DrawLevel("sell", sellSum / sellVol + swS / (k * sellVol), InpSellColor, StringFormat("Sell BE %s lot", DoubleToString(sellVol, 2)));
   else
      RemoveLevel("sell");

   // basket: P/L(P) = k * ((buyVol - sellVol) * P - (buySum - sellSum)) + swB + swS
   double netVol  = buyVol - sellVol;
   bool   sloped  = (buys + sells > 0) && MathAbs(netVol) > 1e-8 && k > 0;
   double netBE   = sloped ? ((buySum - sellSum) - (swB + swS) / k) / netVol : 0.0;

   if(InpShowNet && sloped && buys > 0 && sells > 0)
      DrawLevel("net", netBE, InpNetColor, StringFormat("Net BE %s lot %s", DoubleToString(MathAbs(netVol), 2), netVol > 0 ? "long" : "short"));
   else
      RemoveLevel("net");

   double target = 0.0;
   if(InpTarget > 0 && sloped)
     {
      target = ((buySum - sellSum) + (InpTarget - swB - swS) / k) / netVol;
      DrawLevel("target", target, InpTargetColor, StringFormat("Target +%s", DoubleToString(InpTarget, 2)));
     }
   else
      RemoveLevel("target");

   if(InpShowInfo)
     {
      //--- chart labels hold at most 63 characters, so one fact per line
      string cur = AccountInfoString(ACCOUNT_CURRENCY);
      string lines[4] = {" ", " ", " ", " "};
      if(buys + sells == 0)
         lines[0] = "Basket " + _Symbol + ": no open positions";
      else
        {
         lines[0] = StringFormat("Basket %s: %d buy %s lot, %d sell %s lot",
                                 _Symbol, buys, DoubleToString(buyVol, 2), sells, DoubleToString(sellVol, 2));
         if(planned > 0)
            lines[1] = StringFormat("Planned entries included: %d", planned);
         lines[2] = StringFormat("Floating P/L: %s %s", DoubleToString(floating, 2), cur);
         if(k <= 0)
            lines[3] = "Waiting for the symbol's tick value";
         else
            if(!sloped)
               lines[3] = "Fully hedged: P/L does not change with price";
            else
              {
               lines[3] = "Break-even " + DoubleToString(netBE, _Digits);
               if(InpTarget > 0)
                  lines[3] += " | target " + DoubleToString(target, _Digits);
              }
        }
      for(int row = 0; row < 4; row++)
         InfoLine(row, lines[row]);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Add the planned entries ("B 0.10 1.0850; S 0.05 1.0900") to the  |
//| basket sums; returns how many were added                         |
//+------------------------------------------------------------------+
int AddPlanned(double &buyVol, double &buySum, int &buys, double &sellVol, double &sellSum, int &sells)
  {
   if(InpPlanned == "")
      return 0;
   string items[];
   int    n     = StringSplit(InpPlanned, ';', items);
   int    added = 0;
   for(int i = 0; i < n; i++)
     {
      string item = items[i];
      StringReplace(item, "@", " ");
      StringTrimLeft(item);
      StringTrimRight(item);
      while(StringReplace(item, "  ", " ") > 0)
        {
        }
      string parts[];
      if(StringSplit(item, ' ', parts) != 3)
         continue;
      string side  = parts[0];
      StringToUpper(side);
      double lots  = StringToDouble(parts[1]);
      double price = StringToDouble(parts[2]);
      if(lots <= 0 || price <= 0)
         continue;
      if(side == "B" || side == "BUY")
        {
         buyVol += lots;
         buySum += lots * price;
         buys++;
         added++;
        }
      else
         if(side == "S" || side == "SELL")
           {
            sellVol += lots;
            sellSum += lots * price;
            sells++;
            added++;
           }
     }
   return added;
  }

//+------------------------------------------------------------------+
//| Draw or move one horizontal level with its label                 |
//+------------------------------------------------------------------+
void DrawLevel(const string id, const double price, const color clr, const string text)
  {
   if(price <= 0)
     {
      RemoveLevel(id);
      return;
     }
   string line  = PFX + id;
   string label = PFX + id + "_txt";
   string full  = text + "  " + DoubleToString(price, _Digits);

   if(ObjectFind(0, line) < 0)
     {
      ObjectCreate(0, line, OBJ_HLINE, 0, 0, price);
      ObjectSetInteger(0, line, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, line, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, line, OBJPROP_BACK, false);
     }
   ObjectSetDouble(0, line, OBJPROP_PRICE, price);
   ObjectSetInteger(0, line, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, line, OBJPROP_STYLE, InpStyle);
   ObjectSetInteger(0, line, OBJPROP_WIDTH, InpWidth);
   ObjectSetString(0, line, OBJPROP_TOOLTIP, full);

   datetime t = iTime(_Symbol, _Period, 0);
   if(ObjectFind(0, label) < 0)
     {
      ObjectCreate(0, label, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, label, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0, label, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, label, OBJPROP_HIDDEN, true);
      ObjectSetString(0, label, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, label, OBJPROP_FONTSIZE, InpFontSize);
     }
   ObjectMove(0, label, 0, t, price);
   ObjectSetString(0, label, OBJPROP_TEXT, full);
   ObjectSetInteger(0, label, OBJPROP_COLOR, clr);
  }

//+------------------------------------------------------------------+
//| Delete one level and its label                                   |
//+------------------------------------------------------------------+
void RemoveLevel(const string id)
  {
   ObjectDelete(0, PFX + id);
   ObjectDelete(0, PFX + id + "_txt");
  }

//+------------------------------------------------------------------+
//| One line of the info text (lower left corner)                    |
//+------------------------------------------------------------------+
void InfoLine(const int row, const string text)
  {
   string name = PFX + "info" + IntegerToString(row);
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
     }
   int lineHeight = (int)MathRound(InpFontSize * 2.0 * TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10 + (3 - row) * lineHeight);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, InpInfoColor);
  }
//+------------------------------------------------------------------+

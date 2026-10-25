//+------------------------------------------------------------------+
//|                         PendingPanel.mq5                         |
//|                   Copyright 2026, QuantDev_CN                    |
//|           One-Click Pending Order Panel with OCO (MT5)           |
//+------------------------------------------------------------------+
//  A chart panel that places Buy/Sell Limit and Buy/Sell Stop pending
//  orders with one click, with optional OCO (one-cancels-other),
//  bulk delete, live order list and automatic broker-limit handling.
//
//  Features
//   - One-click Buy Limit / Sell Limit / Buy Stop / Sell Stop
//   - Adjustable volume and distance directly from the panel
//   - Optional SL/TP attached to every pending order
//   - OCO: when one order of a pair triggers, the other is cancelled
//   - Bulk delete of all pending orders placed by this EA
//   - Automatic detection of broker STOPS_LEVEL and filling mode
//   - Live list of pending orders with type, volume and price
//
//  The panel is an execution tool only. It does NOT generate trading
//  signals and does NOT guarantee any trading result.
//+------------------------------------------------------------------+
#property copyright "QuantDev_CN"
#property version   "1.00"
#property description "One-click pending order panel for MT5."
#property description "Buy/Sell Limit and Buy/Sell Stop with adjustable volume and"
#property description "distance, optional SL/TP, OCO (one-cancels-other), bulk delete,"
#property description "live order list and automatic broker-limit handling."
#property description "Execution tool only - it does not generate signals."

#include <Trade/Trade.mqh>

//--- trade inputs
input group "=== Trade Settings ==="
input double InpLots          = 0.10;      // Initial volume
input int    InpDistPoints    = 300;       // Distance from market (points)
input int    InpSLPoints      = 0;         // Stop loss (points, 0 = none)
input int    InpTPPoints      = 0;         // Take profit (points, 0 = none)
input ulong  InpMagic         = 20260101;  // Magic number
input int    InpSlippage      = 20;        // Deviation (points)

input group "=== Panel Appearance ==="
input int    InpPanelX        = 20;        // Panel X offset
input int    InpPanelY        = 120;       // Panel Y offset (below the one-click trading box)
input int    InpBtnW          = 124;       // Button width
input int    InpBtnH          = 26;        // Button height
input color  InpBuyColor      = clrSeaGreen;   // Buy buttons colour
input color  InpSellColor     = clrIndianRed;  // Sell buttons colour
input color  InpFuncColor     = clrDimGray;    // Function buttons colour
input color  InpTextColor     = clrWhite;      // Button text colour
input color  InpInfoColor     = clrGainsboro;  // Info text colour

input group "=== Behaviour ==="
input bool   InpOCO           = true;      // Enable OCO (one cancels other)
input bool   InpShowList      = true;      // Show pending order list
input int    InpMaxListRows   = 8;         // Max rows in the list
input string InpComment       = "PendingPanel"; // Order comment

//--- constants
#define PP_PREFIX   "PP_"
#define PP_TITLE    PP_PREFIX "title"
#define PP_INFO     PP_PREFIX "info"
#define PP_LIST     PP_PREFIX "list_"
#define PP_STATUS   PP_PREFIX "status"
#define MAX_OCO     16

//--- globals
CTrade   trade;
double   g_lots     = 0.10;
int      g_dist     = 300;
bool     g_ocoOn    = true;
ulong    g_ocoA[MAX_OCO];
ulong    g_ocoB[MAX_OCO];
int      g_ocoCount = 0;
uint     g_lastRefresh = 0;

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
double VolumeStep()
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      step = 0.01;
   return step;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VolumeDigits()
  {
   double step = VolumeStep();
   int d = (int)MathCeil(-MathLog10(step));
   if(d < 0)
      d = 0;
   if(d > 8)
      d = 8;
   return d;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
  {
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = VolumeStep();
   lots = MathRound(lots / step) * step;
   if(minL > 0.0 && lots < minL)
      lots = minL;
   if(maxL > 0.0 && lots > maxL)
      lots = maxL;
   return NormalizeDouble(lots, VolumeDigits());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RoundToTick(double price)
  {
   double tick = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tick <= 0.0)
      tick = _Point;
   return NormalizeDouble(MathRound(price / tick) * tick, _Digits);
  }

//--- minimum allowed distance from the market for a pending order
int MinDistPoints()
  {
   long   stops  = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) -
                    SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
   double minPts = MathMax((double)stops, spread) + 5.0;
   if(minPts < 10.0)
      minPts = 10.0;
   return (int)MathCeil(minPts);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOurPending(ulong ticket)
  {
   if(!OrderSelect(ticket))
      return false;
   if(OrderGetString(ORDER_SYMBOL) != _Symbol)
      return false;
   if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic)
      return false;
   long state = OrderGetInteger(ORDER_STATE);
   return (state == ORDER_STATE_PLACED || state == ORDER_STATE_PARTIAL);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOurPending()
  {
   int n = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      ulong tk = OrderGetTicket(i);
      if(tk == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic)
         continue;
      n++;
     }
   return n;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderTypeName(int type)
  {
   switch(type)
     {
      case ORDER_TYPE_BUY_LIMIT:
         return "BUY LIMIT";
      case ORDER_TYPE_SELL_LIMIT:
         return "SELL LIMIT";
      case ORDER_TYPE_BUY_STOP:
         return "BUY STOP";
      case ORDER_TYPE_SELL_STOP:
         return "SELL STOP";
      case ORDER_TYPE_BUY:
         return "BUY";
      case ORDER_TYPE_SELL:
         return "SELL";
     }
   return "UNKNOWN";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PriceToStr(double price)
  {
   return DoubleToString(price, _Digits);
  }

//+------------------------------------------------------------------+
//| Panel objects                                                    |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const int x, const int y,
                 const string text, const color clr, const int size = 9)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, "Microsoft YaHei");
// MT5 ignores an empty OBJPROP_TEXT and keeps the default "Label" caption,
// so an empty caption is replaced by a single space.
   ObjectSetString(0, name, OBJPROP_TEXT, (StringLen(text) == 0 ? " " : text));
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton(const string name, const int x, const int y,
                  const string text, const color bg, const color fg)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, InpBtnW);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, InpBtnH);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Microsoft YaHei");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetButtonText(const string name, const string text)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   int x = InpPanelX;
   int y = InpPanelY;
   int gap = 6;
   int colW = InpBtnW + gap;
   int rowH = InpBtnH + gap;

   CreateLabel(PP_TITLE, x, y, "PENDING ORDER PANEL", InpTextColor, 10);
   y += 22;

   CreateLabel(PP_INFO, x, y, "", InpInfoColor, 9);
   y += 20;

// row: volume and distance adjust
   CreateButton(PP_PREFIX "lot_minus", x,           y, "Lots -", InpFuncColor, InpTextColor);
   CreateButton(PP_PREFIX "lot_plus",  x + colW,    y, "Lots +", InpFuncColor, InpTextColor);
   CreateButton(PP_PREFIX "dist_minus",x + colW * 2,y, "Dist -", InpFuncColor, InpTextColor);
   CreateButton(PP_PREFIX "dist_plus", x + colW * 3,y, "Dist +", InpFuncColor, InpTextColor);
   y += rowH;

// row: limit orders
   CreateButton(PP_PREFIX "buy_limit",  x,        y, "BUY LIMIT",  InpBuyColor,  InpTextColor);
   CreateButton(PP_PREFIX "sell_limit", x + colW, y, "SELL LIMIT", InpSellColor, InpTextColor);
   y += rowH;

// row: stop orders
   CreateButton(PP_PREFIX "buy_stop",  x,        y, "BUY STOP",  InpBuyColor,  InpTextColor);
   CreateButton(PP_PREFIX "sell_stop", x + colW, y, "SELL STOP", InpSellColor, InpTextColor);
   y += rowH;

// row: utility
   CreateButton(PP_PREFIX "del_all", x,           y, "DELETE ALL", InpFuncColor, InpTextColor);
   CreateButton(PP_PREFIX "oco",     x + colW,    y, "OCO: --",   InpFuncColor, InpTextColor);
   y += rowH + 4;

   CreateLabel(PP_STATUS, x, y, "", InpInfoColor, 9);
   y += 20;

   if(InpShowList)
     {
      for(int i = 0; i < InpMaxListRows; i++)
         CreateLabel(PP_LIST + IntegerToString(i), x, y + i * 16, "", InpInfoColor, 9);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemovePanel()
  {
   ObjectsDeleteAll(0, PP_PREFIX);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Panel refresh                                                    |
//+------------------------------------------------------------------+
void UpdateInfo()
  {
   string s = StringFormat("Lots: %s   Dist: %d pts   Min: %d pts",
                           DoubleToString(g_lots, VolumeDigits()),
                           g_dist, MinDistPoints());
   if(InpSLPoints > 0 || InpTPPoints > 0)
      s += StringFormat("   SL: %d  TP: %d", InpSLPoints, InpTPPoints);
   ObjectSetString(0, PP_INFO, OBJPROP_TEXT, s);

   string oco = StringFormat("OCO: %s", (g_ocoOn ? "ON" : "OFF"));
   SetButtonText(PP_PREFIX "oco", oco);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateStatus()
  {
   int n = CountOurPending();
   string s = StringFormat("Pending orders: %d", n);
   ObjectSetString(0, PP_STATUS, OBJPROP_TEXT, s);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateList()
  {
   if(!InpShowList)
      return;

   string  names[MAX_OCO * 4];
   string  texts[MAX_OCO * 4];
   int     idx = 0;
   int     shown = 0;

   int total = OrdersTotal();
   for(int i = 0; i < total && shown < InpMaxListRows; i++)
     {
      ulong tk = OrderGetTicket(i);
      if(tk == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic)
         continue;

      long   type   = OrderGetInteger(ORDER_TYPE);
      double volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
      double price  = OrderGetDouble(ORDER_PRICE_OPEN);
      double sl     = OrderGetDouble(ORDER_SL);
      double tp     = OrderGetDouble(ORDER_TP);

      string line = StringFormat("%-10s %s @ %s",
                                 OrderTypeName((int)type),
                                 DoubleToString(volume, VolumeDigits()),
                                 PriceToStr(price));
      if(sl > 0.0 || tp > 0.0)
         line += StringFormat("  (SL %s / TP %s)",
                              (sl > 0.0 ? PriceToStr(sl) : "-"),
                              (tp > 0.0 ? PriceToStr(tp) : "-"));

      names[idx] = PP_LIST + IntegerToString(shown);
      texts[idx] = line;
      idx++;
      shown++;
     }

   for(int i = 0; i < InpMaxListRows; i++)
     {
      names[idx] = PP_LIST + IntegerToString(i);
      texts[idx] = " ";
      idx++;
     }
   for(int i = 0; i < idx; i++)
      ObjectSetString(0, names[i], OBJPROP_TEXT, texts[i]);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshAll()
  {
   UpdateInfo();
   UpdateStatus();
   UpdateList();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| OCO handling                                                     |
//+------------------------------------------------------------------+
void OCOAdd(ulong ticket)
  {
   if(!g_ocoOn)
      return;
   if(g_ocoCount >= MAX_OCO)
     {
      Print("[PP] OCO list full, ticket ", ticket, " not tracked");
      return;
     }

// try to pair with an opposite pending order of ours
   long newType = (long)OrderGetInteger(ORDER_TYPE);
   if(!OrderSelect(ticket))
      return;

   for(int i = 0; i < g_ocoCount; i++)
     {
      if(g_ocoA[i] == ticket || g_ocoB[i] == ticket)
         return; // already tracked
     }

   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      ulong other = OrderGetTicket(i);
      if(other == 0 || other == ticket)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic)
         continue;

      long otherType = OrderGetInteger(ORDER_TYPE);
      bool opposite = ((newType == ORDER_TYPE_BUY_LIMIT || newType == ORDER_TYPE_BUY_STOP) &&
                       (otherType == ORDER_TYPE_SELL_LIMIT || otherType == ORDER_TYPE_SELL_STOP)) ||
                      ((newType == ORDER_TYPE_SELL_LIMIT || newType == ORDER_TYPE_SELL_STOP) &&
                       (otherType == ORDER_TYPE_BUY_LIMIT || otherType == ORDER_TYPE_BUY_STOP));
      if(!opposite)
         continue;

      // skip if the candidate is already paired
      bool paired = false;
      for(int k = 0; k < g_ocoCount; k++)
         if(g_ocoA[k] == other || g_ocoB[k] == other)
            paired = true;
      if(paired)
         continue;

      g_ocoA[g_ocoCount] = ticket;
      g_ocoB[g_ocoCount] = other;
      g_ocoCount++;
      Print("[PP] OCO pair registered: #", ticket, " <-> #", other);
      return;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OCORemoveAt(const int i)
  {
   if(i < 0 || i >= g_ocoCount)
      return;
   for(int k = i; k < g_ocoCount - 1; k++)
     {
      g_ocoA[k] = g_ocoA[k + 1];
      g_ocoB[k] = g_ocoB[k + 1];
     }
   g_ocoCount--;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckOCO()
  {
   if(!g_ocoOn || g_ocoCount <= 0)
      return;

   for(int i = g_ocoCount - 1; i >= 0; i--)
     {
      bool a = IsOurPending(g_ocoA[i]);
      bool b = IsOurPending(g_ocoB[i]);

      if(a && !b)
        {
         if(trade.OrderDelete(g_ocoA[i]))
            Print("[PP] OCO: #", g_ocoB[i], " gone, deleted #", g_ocoA[i]);
         else
            Print("[PP] OCO: delete #", g_ocoA[i], " failed: ", trade.ResultRetcodeDescription());
         OCORemoveAt(i);
        }
      else
         if(!a && b)
           {
            if(trade.OrderDelete(g_ocoB[i]))
               Print("[PP] OCO: #", g_ocoA[i], " gone, deleted #", g_ocoB[i]);
            else
               Print("[PP] OCO: delete #", g_ocoB[i], " failed: ", trade.ResultRetcodeDescription());
            OCORemoveAt(i);
           }
         else
            if(!a && !b)
              {
               OCORemoveAt(i);
              }
     }
  }

//+------------------------------------------------------------------+
//| Trading                                                          |
//+------------------------------------------------------------------+
void PlacePending(const ENUM_ORDER_TYPE type)
  {
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      Print("[PP] Trading is not allowed for this EA");
      return;
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print("[PP] AutoTrading is disabled in the terminal");
      return;
     }

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0)
     {
      Print("[PP] No market prices yet");
      return;
     }

   int    dist = g_dist;
   int    minD = MinDistPoints();
   if(dist < minD)
     {
      Print("[PP] Distance ", dist, " pts is below the broker minimum (", minD,
            " pts). Distance adjusted automatically.");
      dist = minD;
      g_dist = dist;
     }

   double offset = dist * _Point;
   double lots   = NormalizeLots(g_lots);
   double price  = 0.0;
   double sl     = 0.0;
   double tp     = 0.0;

   switch(type)
     {
      case ORDER_TYPE_BUY_LIMIT:
         price = RoundToTick(ask - offset);
         if(InpSLPoints > 0)
            sl = RoundToTick(price - InpSLPoints * _Point);
         if(InpTPPoints > 0)
            tp = RoundToTick(price + InpTPPoints * _Point);
         break;

      case ORDER_TYPE_SELL_LIMIT:
         price = RoundToTick(bid + offset);
         if(InpSLPoints > 0)
            sl = RoundToTick(price + InpSLPoints * _Point);
         if(InpTPPoints > 0)
            tp = RoundToTick(price - InpTPPoints * _Point);
         break;

      case ORDER_TYPE_BUY_STOP:
         price = RoundToTick(ask + offset);
         if(InpSLPoints > 0)
            sl = RoundToTick(price - InpSLPoints * _Point);
         if(InpTPPoints > 0)
            tp = RoundToTick(price + InpTPPoints * _Point);
         break;

      case ORDER_TYPE_SELL_STOP:
         price = RoundToTick(bid - offset);
         if(InpSLPoints > 0)
            sl = RoundToTick(price + InpSLPoints * _Point);
         if(InpTPPoints > 0)
            tp = RoundToTick(price - InpTPPoints * _Point);
         break;

      default:
         Print("[PP] Unsupported order type");
         return;
     }

   if(price <= 0.0)
     {
      Print("[PP] Calculated price is invalid");
      return;
     }

   bool ok = false;
   switch(type)
     {
      case ORDER_TYPE_BUY_LIMIT:
         ok = trade.BuyLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, InpComment);
         break;
      case ORDER_TYPE_SELL_LIMIT:
         ok = trade.SellLimit(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, InpComment);
         break;
      case ORDER_TYPE_BUY_STOP:
         ok = trade.BuyStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, InpComment);
         break;
      case ORDER_TYPE_SELL_STOP:
         ok = trade.SellStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, InpComment);
         break;
     }

   if(ok)
     {
      PrintFormat("[PP] %s placed: %s lots @ %s (SL %s / TP %s)",
                  OrderTypeName((int)type),
                  DoubleToString(lots, VolumeDigits()),
                  PriceToStr(price),
                  (sl > 0.0 ? PriceToStr(sl) : "-"),
                  (tp > 0.0 ? PriceToStr(tp) : "-"));
      ulong ticket = trade.ResultOrder();
      if(ticket > 0)
         OCOAdd(ticket);
     }
   else
     {
      PrintFormat("[PP] %s failed: %d %s (price %s)",
                  OrderTypeName((int)type),
                  trade.ResultRetcode(),
                  trade.ResultRetcodeDescription(),
                  PriceToStr(price));
     }

   RefreshAll();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllPending()
  {
   int deleted = 0;
   int failed  = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong tk = OrderGetTicket(i);
      if(tk == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      if((ulong)OrderGetInteger(ORDER_MAGIC) != InpMagic)
         continue;

      if(trade.OrderDelete(tk))
         deleted++;
      else
        {
         failed++;
         PrintFormat("[PP] Delete #%I64u failed: %s", tk, trade.ResultRetcodeDescription());
        }
     }

   if(deleted > 0 || failed > 0)
      PrintFormat("[PP] Delete all: %d deleted, %d failed", deleted, failed);

   g_ocoCount = 0;
   RefreshAll();
  }

//+------------------------------------------------------------------+
//| Panel events                                                     |
//+------------------------------------------------------------------+
void OnButtonClick(const string name)
  {
   if(name == PP_PREFIX "buy_limit")
      PlacePending(ORDER_TYPE_BUY_LIMIT);
   else
      if(name == PP_PREFIX "sell_limit")
         PlacePending(ORDER_TYPE_SELL_LIMIT);
      else
         if(name == PP_PREFIX "buy_stop")
            PlacePending(ORDER_TYPE_BUY_STOP);
         else
            if(name == PP_PREFIX "sell_stop")
               PlacePending(ORDER_TYPE_SELL_STOP);
            else
               if(name == PP_PREFIX "del_all")
                  DeleteAllPending();
               else
                  if(name == PP_PREFIX "oco")
                    {
                     g_ocoOn = !g_ocoOn;
                     if(!g_ocoOn)
                        g_ocoCount = 0;
                     Print("[PP] OCO ", (g_ocoOn ? "enabled" : "disabled"));
                     RefreshAll();
                    }
                  else
                     if(name == PP_PREFIX "lot_minus")
                       {
                        g_lots = NormalizeLots(g_lots - VolumeStep());
                        RefreshAll();
                       }
                     else
                        if(name == PP_PREFIX "lot_plus")
                          {
                           g_lots = NormalizeLots(g_lots + VolumeStep());
                           RefreshAll();
                          }
                        else
                           if(name == PP_PREFIX "dist_minus")
                             {
                              g_dist = (int)MathMax(MinDistPoints(), g_dist - 50);
                              RefreshAll();
                             }
                           else
                              if(name == PP_PREFIX "dist_plus")
                                {
                                 g_dist += 50;
                                 RefreshAll();
                                }
  }

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!SymbolSelect(_Symbol, true))
     {
      Print("[PP] Symbol is not available: ", _Symbol);
      return INIT_FAILED;
     }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetAsyncMode(false);

   g_lots  = NormalizeLots(InpLots);
   g_dist  = InpDistPoints;
   g_ocoOn = InpOCO;

   int minD = MinDistPoints();
   if(g_dist < minD)
     {
      PrintFormat("[PP] InpDistPoints (%d) is below the broker minimum (%d). Adjusted.",
                  g_dist, minD);
      g_dist = minD;
     }

   BuildPanel();
   RefreshAll();

   PrintFormat("[PP] Started on %s %s | lots=%s dist=%d pts | OCO=%s | 1 lot = %s",
               _Symbol,
               EnumToString((ENUM_TIMEFRAMES)Period()),
               DoubleToString(g_lots, VolumeDigits()),
               g_dist,
               (g_ocoOn ? "ON" : "OFF"),
               DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE), 0));
   Print("[PP] Execution tool only - it does not generate signals and does not guarantee any result.");

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   RemovePanel();
   Print("[PP] Stopped, reason=", reason);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckOCO();

// refresh the panel at most twice per second
   uint now = GetTickCount();
   if(now - g_lastRefresh > 500)
     {
      g_lastRefresh = now;
      UpdateStatus();
      UpdateList();
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam, PP_PREFIX) == 0)
        {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
         OnButtonClick(sparam);
         ChartRedraw();
        }
     }
  }
//+------------------------------------------------------------------+

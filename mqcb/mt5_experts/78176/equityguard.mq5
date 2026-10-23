//+------------------------------------------------------------------+
//|                                                  EquityGuard.mq5 |
//|              Daily loss / max drawdown / daily target guard       |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Attach to ONE chart of the account. The EA does not open trades.
// It watches account equity and, when a limit is hit, closes positions,
// deletes pending orders and keeps the account flat:
//   - daily loss limit / daily profit target -> until the next trading day
//   - maximum drawdown                       -> until "Reset saved state"
// State (day-start base, initial balance, peak, lock) is kept in terminal
// global variables, so a restart of the terminal does not reset the day.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Equity Guard stops trading when a daily loss limit, a maximum drawdown"
#property description "or a daily profit target is reached: it closes positions, deletes pending"
#property description "orders and keeps the account flat until the next trading day."
#property description "Prop-firm style rules, on-chart panel, state survives terminal restarts."

#include <Trade\Trade.mqh>

#define LOCK_NONE   0
#define LOCK_DAILY  1
#define LOCK_TARGET 2
#define LOCK_MAXDD  3
#define PANEL_ROWS  9

enum ENUM_DAY_BASE
  {
   DAY_BASE_BALANCE = 0, // Balance at day start
   DAY_BASE_EQUITY  = 1, // Equity at day start
   DAY_BASE_HIGHER  = 2  // Higher of balance and equity
  };

enum ENUM_DD_MODE
  {
   DD_FROM_INITIAL = 0, // From initial balance (static)
   DD_FROM_PEAK    = 1  // From highest equity (trailing)
  };

input group "Limits (0 = off)"
input double           InpDailyLossPct    = 4.0;             // Max daily loss, % of day-start base
input double           InpDailyLossMoney  = 0.0;             // Max daily loss, account currency
input double           InpMaxDrawdownPct  = 8.0;             // Max overall drawdown, %
input ENUM_DD_MODE     InpDDMode          = DD_FROM_INITIAL; // Drawdown measured
input double           InpInitialBalance  = 0.0;             // Initial balance (0 = balance at first start)
input double           InpDailyTargetPct  = 0.0;             // Daily profit target, % (locks the profit)

input group "Trading day"
input ENUM_DAY_BASE    InpDayBase         = DAY_BASE_HIGHER; // Daily loss measured from
input int              InpResetHour       = 0;               // New day starts at server hour (0-23)

input group "Action when a limit is hit"
input bool             InpClosePositions  = true;            // Close open positions
input bool             InpDeletePending   = true;            // Delete pending orders
input bool             InpKeepFlat        = true;            // Keep closing new trades until reset
input long             InpMagicFilter     = -1;              // Only this magic number (-1 = all)
input bool             InpOnlyChartSymbol = false;           // Only the chart symbol
input bool             InpAlerts          = true;            // Pop-up alert
input bool             InpPush            = false;           // Push notification

input group "Panel"
input bool             InpShowPanel       = true;            // Show panel
input ENUM_BASE_CORNER InpCorner          = CORNER_RIGHT_UPPER; // Panel corner
input int              InpX               = 10;              // Horizontal offset, px
input int              InpY               = 30;              // Vertical offset, px
input int              InpFontSize        = 9;               // Font size
input color            InpTextColor       = clrWhiteSmoke;   // Text colour
input color            InpBackColor       = C'32,36,48';     // Background colour

input group "State"
input bool             InpResetState      = false;           // Reset saved state on start

CTrade   g_trade;
string   g_gv          = "";        // prefix of terminal global variables
string   g_obj         = "EqGuard_"; // prefix of chart objects
bool     g_ready       = false;
bool     g_running     = false;
long     g_dayKey      = -1;
double   g_dayStart    = 0.0;
double   g_initial     = 0.0;
double   g_peak        = 0.0;
int      g_lock        = LOCK_NONE;
long     g_lockDay     = -1;
uint     g_lastFlatten = 0;
int      g_dpi         = 96;
int      g_px          = 0;         // panel position, measured from the chosen corner
int      g_py          = 0;
bool     g_left        = true;      // panel bound to a left corner
bool     g_top         = true;      // panel bound to an upper corner

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpResetHour < 0 || InpResetHour > 23 ||
      InpDailyLossPct < 0 || InpDailyLossMoney < 0 ||
      InpMaxDrawdownPct < 0 || InpMaxDrawdownPct >= 100 ||
      InpDailyTargetPct < 0 || InpInitialBalance < 0 || InpFontSize < 6)
     {
      Print("Equity Guard: check the inputs (negative value, drawdown >= 100%, reset hour outside 0-23 or font size < 6).");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_dpi = (int)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   if(g_dpi <= 0)
      g_dpi = 96;

   g_trade.SetDeviationInPoints(50);
   g_trade.SetAsyncMode(false);

   EventSetTimer(1);
   if(EnsureReady())
      Evaluate();
   UpdatePanel();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_ready)
      SaveState();
   ObjectsDeleteAll(0, g_obj);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| New tick                                                         |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(EnsureReady())
      Evaluate();
  }

//+------------------------------------------------------------------+
//| Timer: check the limits and redraw the panel                     |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(EnsureReady())
      Evaluate();
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Chart events: keep the panel in place after a resize             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Loads saved state once the account is known (login > 0).         |
//+------------------------------------------------------------------+
bool EnsureReady()
  {
   if(g_ready)
      return true;
   long login = AccountInfoInteger(ACCOUNT_LOGIN);
   if(login <= 0)
      return false;

   g_gv = StringFormat("EqGuard_%I64d_", login);
   if(InpResetState)
      GlobalVariablesDeleteAll(g_gv);
   LoadState();

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpInitialBalance > 0)
      g_initial = InpInitialBalance;
   else
      if(g_initial <= 0)
         g_initial = balance;
   g_peak = MathMax(g_peak, MathMax(g_initial, equity));

   g_running = false;
   NewDayCheck();
   g_running = true;
   SaveState();
   g_ready = true;
   return true;
  }

//+------------------------------------------------------------------+
//| Main check: new day, drawdown, daily loss, daily target.          |
//+------------------------------------------------------------------+
void Evaluate()
  {
   NewDayCheck();

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > g_peak)
     {
      g_peak = equity;
      GlobalVariableSet(g_gv + "Peak", g_peak);
     }

   if(g_lock != LOCK_MAXDD && InpMaxDrawdownPct > 0 && equity <= DrawdownFloor())
      Lock(LOCK_MAXDD);
   else
      if(g_lock == LOCK_NONE)
        {
         double dayPL = equity - g_dayStart;
         double limit = DailyLossLimit();
         if(limit > 0 && dayPL <= -limit)
            Lock(LOCK_DAILY);
         else
            if(InpDailyTargetPct > 0 && g_dayStart > 0 && dayPL >= g_dayStart * InpDailyTargetPct / 100.0)
               Lock(LOCK_TARGET);
        }

   FlattenIfNeeded(false);
  }

//+------------------------------------------------------------------+
//| Start a new trading day and release the daily locks              |
//+------------------------------------------------------------------+
void NewDayCheck()
  {
   long key = DayKey(TimeTradeServer());
   if(key == g_dayKey)
      return;

   g_dayKey = key;
   // At a live day boundary use current values; on a start during the
   // day rebuild the day-start balance from today's closed deals.
   g_dayStart = g_running ? LiveBase() : MidDayBase();

   if((g_lock == LOCK_DAILY || g_lock == LOCK_TARGET) && g_lockDay != g_dayKey)
     {
      g_lock = LOCK_NONE;
      Print("Equity Guard: new trading day - daily lock released.");
     }
   SaveState();
  }

//+------------------------------------------------------------------+
//| Stop trading: save the lock, notify, close the trades            |
//+------------------------------------------------------------------+
void Lock(const int reason)
  {
   g_lock    = reason;
   g_lockDay = g_dayKey;
   SaveState();

   string until = (reason == LOCK_MAXDD) ? "until the state is reset" : "until the next trading day";
   Notify(StringFormat("%s hit, equity %s %s. Trading stopped %s.",
                       LockText(reason),
                       DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2),
                       AccountInfoString(ACCOUNT_CURRENCY),
                       until));
   FlattenIfNeeded(true);
  }

//+------------------------------------------------------------------+
//| Closes / deletes matching trades while a lock is active.         |
//+------------------------------------------------------------------+
void FlattenIfNeeded(const bool force)
  {
   if(g_lock == LOCK_NONE)
      return;
   if(!force && !InpKeepFlat && g_lock != LOCK_MAXDD)
      return;
   if(CountExposure() == 0)
      return;

   uint now = GetTickCount();
   if(!force && now - g_lastFlatten < 2000)
      return;
   g_lastFlatten = now;

   if(InpClosePositions)
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0)
            continue;
         string symbol = PositionGetString(POSITION_SYMBOL);
         if(!Matches(symbol, PositionGetInteger(POSITION_MAGIC)))
            continue;
         g_trade.SetTypeFillingBySymbol(symbol);
         if(!g_trade.PositionClose(ticket))
            PrintFormat("Equity Guard: closing position #%I64u failed, retcode %u (%s)",
                        ticket, g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
        }

   if(InpDeletePending)
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0)
            continue;
         if(!Matches(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC)))
            continue;
         if(!g_trade.OrderDelete(ticket))
            PrintFormat("Equity Guard: deleting order #%I64u failed, retcode %u (%s)",
                        ticket, g_trade.ResultRetcode(), g_trade.ResultRetcodeDescription());
        }
  }

//+------------------------------------------------------------------+
//| Number of positions and orders the guard would close             |
//+------------------------------------------------------------------+
int CountExposure()
  {
   int count = 0;
   if(InpClosePositions)
      for(int i = PositionsTotal() - 1; i >= 0; i--)
         if(PositionGetTicket(i) > 0 &&
            Matches(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
            count++;
   if(InpDeletePending)
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderGetTicket(i) > 0 &&
            Matches(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC)))
            count++;
   return count;
  }

//+------------------------------------------------------------------+
//| True if the trade passes the magic number / symbol filters       |
//+------------------------------------------------------------------+
bool Matches(const string symbol, const long magic)
  {
   if(InpOnlyChartSymbol && symbol != _Symbol)
      return false;
   if(InpMagicFilter >= 0 && magic != InpMagicFilter)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Daily loss limit in account currency (0 = off)                   |
//+------------------------------------------------------------------+
double DailyLossLimit()
  {
   double limit = 0.0;
   if(InpDailyLossPct > 0 && g_dayStart > 0)
      limit = g_dayStart * InpDailyLossPct / 100.0;
   if(InpDailyLossMoney > 0 && (limit == 0.0 || InpDailyLossMoney < limit))
      limit = InpDailyLossMoney;
   return limit;
  }

//+------------------------------------------------------------------+
//| Equity level that triggers the maximum drawdown lock             |
//+------------------------------------------------------------------+
double DrawdownFloor()
  {
   double base = (InpDDMode == DD_FROM_PEAK) ? g_peak : g_initial;
   return base * (1.0 - InpMaxDrawdownPct / 100.0);
  }

//+------------------------------------------------------------------+
//| Day-start base from the live balance / equity                    |
//+------------------------------------------------------------------+
double LiveBase()
  {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpDayBase == DAY_BASE_BALANCE)
      return balance;
   if(InpDayBase == DAY_BASE_EQUITY)
      return equity;
   return MathMax(balance, equity);
  }

//+------------------------------------------------------------------+
//| Day-start base when the EA starts during the day                 |
//+------------------------------------------------------------------+
double MidDayBase()
  {
   double balance      = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity       = AccountInfoDouble(ACCOUNT_EQUITY);
   double closedToday  = ClosedProfitSince(DayStartTime(g_dayKey));
   double startBalance = balance - closedToday;

   double base = startBalance;
   if(InpDayBase == DAY_BASE_EQUITY)
      base = equity;
   else
      if(InpDayBase == DAY_BASE_HIGHER)
         base = MathMax(startBalance, equity);

   PrintFormat("Equity Guard: day-start base set to %s (closed P/L today %s).",
               DoubleToString(base, 2), DoubleToString(closedToday, 2));
   return base;
  }

//+------------------------------------------------------------------+
//| Result of the trades closed since the given time                 |
//+------------------------------------------------------------------+
double ClosedProfitSince(const datetime from)
  {
   double sum = 0.0;
   if(!HistorySelect(from, TimeTradeServer() + 86400))
      return sum;
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      sum += HistoryDealGetDouble(ticket, DEAL_PROFIT)
             + HistoryDealGetDouble(ticket, DEAL_SWAP)
             + HistoryDealGetDouble(ticket, DEAL_COMMISSION)
             + HistoryDealGetDouble(ticket, DEAL_FEE);
     }
   return sum;
  }

//+------------------------------------------------------------------+
//| Number of the trading day that contains the given time           |
//+------------------------------------------------------------------+
long DayKey(const datetime t)
  {
   return ((long)t - (long)InpResetHour * 3600) / 86400;
  }

//+------------------------------------------------------------------+
//| Start time of the given trading day                              |
//+------------------------------------------------------------------+
datetime DayStartTime(const long key)
  {
   return (datetime)(key * 86400 + (long)InpResetHour * 3600);
  }

//+------------------------------------------------------------------+
//| Readable name of a lock reason                                   |
//+------------------------------------------------------------------+
string LockText(const int reason)
  {
   switch(reason)
     {
      case LOCK_DAILY:
         return "Daily loss limit";
      case LOCK_TARGET:
         return "Daily profit target";
      case LOCK_MAXDD:
         return "Maximum drawdown";
     }
   return "None";
  }

//+------------------------------------------------------------------+
//| Message to the journal, a pop-up and a push notification         |
//+------------------------------------------------------------------+
void Notify(const string text)
  {
   string msg = StringFormat("Equity Guard [%I64d]: %s", AccountInfoInteger(ACCOUNT_LOGIN), text);
   Print(msg);
   if(InpAlerts)
      Alert(msg);
   if(InpPush && !SendNotification(msg))
      Print("Equity Guard: push notification not sent - check the MetaQuotes ID in the terminal settings.");
  }

//+------------------------------------------------------------------+
//| State in terminal global variables                               |
//+------------------------------------------------------------------+
void SaveState()
  {
   GlobalVariableSet(g_gv + "DayKey",   (double)g_dayKey);
   GlobalVariableSet(g_gv + "DayStart", g_dayStart);
   GlobalVariableSet(g_gv + "Initial",  g_initial);
   GlobalVariableSet(g_gv + "Peak",     g_peak);
   GlobalVariableSet(g_gv + "Lock",     (double)g_lock);
   GlobalVariableSet(g_gv + "LockDay",  (double)g_lockDay);
  }

//+------------------------------------------------------------------+
//| Read the saved state from terminal global variables              |
//+------------------------------------------------------------------+
void LoadState()
  {
   g_dayKey   = (long)GvGet("DayKey", -1);
   g_dayStart = GvGet("DayStart", 0);
   g_initial  = GvGet("Initial", 0);
   g_peak     = GvGet("Peak", 0);
   g_lock     = (int)GvGet("Lock", LOCK_NONE);
   g_lockDay  = (long)GvGet("LockDay", -1);
  }

//+------------------------------------------------------------------+
//| Value of a global variable, or the fallback                      |
//+------------------------------------------------------------------+
double GvGet(const string name, const double fallback)
  {
   double value = 0.0;
   if(GlobalVariableGet(g_gv + name, value))
      return value;
   return fallback;
  }

//+------------------------------------------------------------------+
//| Panel                                                            |
//+------------------------------------------------------------------+
int Scale(const int px)
  {
   return (int)MathRound(px * g_dpi / 96.0);
  }

//+------------------------------------------------------------------+
//| Height of one panel row in pixels                                |
//+------------------------------------------------------------------+
int LineHeight()
  {
   return Scale(InpFontSize * 2);
  }

//+------------------------------------------------------------------+
//| Draw the panel                                                   |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   int width  = Scale(InpFontSize * 34);
   int height = Scale(16) + PANEL_ROWS * LineHeight();
   //--- the objects stay bound to the chosen corner and are anchored at their
   //--- upper-left point, so on the right / lower side the panel size is added
   g_left = (InpCorner == CORNER_LEFT_UPPER || InpCorner == CORNER_LEFT_LOWER);
   g_top  = (InpCorner == CORNER_LEFT_UPPER || InpCorner == CORNER_RIGHT_UPPER);
   g_px   = g_left ? InpX : InpX + width;
   g_py   = g_top  ? InpY : InpY + height;

   PanelBackground(width, height);
   PanelLabel(0, "EQUITY GUARD", InpTextColor);

   if(!g_ready)
     {
      PanelLabel(1, "Waiting for the account...", clrGold);
      for(int row = 2; row < PANEL_ROWS; row++)
         PanelLabel(row, " ", InpTextColor);
      ChartRedraw();
      return;
     }

   string cur    = AccountInfoString(ACCOUNT_CURRENCY);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dayPL  = equity - g_dayStart;
   double dayPct = (g_dayStart > 0) ? dayPL / g_dayStart * 100.0 : 0.0;
   double limit  = DailyLossLimit();
   double floor  = DrawdownFloor();

   string status = (g_lock == LOCK_NONE) ? "ACTIVE" : "LOCKED - " + LockText(g_lock);
   color  sColor = (g_lock == LOCK_NONE) ? clrLimeGreen : clrTomato;

   PanelLabel(1, "Status : " + status, sColor);
   PanelLabel(2, StringFormat("Equity : %s %s", DoubleToString(equity, 2), cur), InpTextColor);
   PanelLabel(3, StringFormat("Today  : %s (%+.2f%%)", DoubleToString(dayPL, 2), dayPct),
              dayPL < 0 ? clrTomato : InpTextColor);

   if(limit > 0)
      PanelLabel(4, StringFormat("Daily  : limit %s, left %s",
                                 DoubleToString(limit, 2), DoubleToString(MathMax(0.0, limit + dayPL), 2)), InpTextColor);
   else
      PanelLabel(4, "Daily  : off", InpTextColor);

   if(InpMaxDrawdownPct > 0)
      PanelLabel(5, StringFormat("Max DD : floor %s, left %s",
                                 DoubleToString(floor, 2), DoubleToString(MathMax(0.0, equity - floor), 2)), InpTextColor);
   else
      PanelLabel(5, "Max DD : off", InpTextColor);

   if(InpDailyTargetPct > 0)
      PanelLabel(6, StringFormat("Target : %s", DoubleToString(g_dayStart * InpDailyTargetPct / 100.0, 2)), InpTextColor);
   else
      PanelLabel(6, "Target : off", InpTextColor);

   PanelLabel(7, "Reset  : " + TimeToString(DayStartTime(g_dayKey + 1), TIME_DATE | TIME_MINUTES) + " server", InpTextColor);

   bool tradeAllowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && MQLInfoInteger(MQL_TRADE_ALLOWED);
   if(!tradeAllowed)
      PanelLabel(8, "! Turn on Algo Trading to let it close", clrOrange);
   else
      PanelLabel(8, " ", InpTextColor);

   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Background rectangle of the panel                                |
//+------------------------------------------------------------------+
void PanelBackground(const int width, const int height)
  {
   string name = g_obj + "bg";
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
     }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, g_px);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, g_py);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, InpBackColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray);
  }

//+------------------------------------------------------------------+
//| One text row of the panel                                        |
//+------------------------------------------------------------------+
void PanelLabel(const int row, const string text, const color clr)
  {
   string name = g_obj + "row" + IntegerToString(row);
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, InpCorner);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
     }
   int shiftY = Scale(8) + row * LineHeight();
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, g_left ? g_px + Scale(10) : g_px - Scale(10));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, g_top ? g_py + shiftY : g_py - shiftY);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+

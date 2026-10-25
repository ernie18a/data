//+------------------------------------------------------------------+
//|                                          PropFirmEquityGuard.mq5 |
//|  Enforces prop firm style risk rules on the whole account:       |
//|  daily loss limit, maximum overall loss and profit target.       |
//|  When a limit is reached it closes positions, deletes pending    |
//|  orders and keeps closing new trades until the lock expires.     |
//+------------------------------------------------------------------+
#property copyright   "Shanawaz M."
#property version     "1.00"
#property description "Prop Firm Equity Guard: closes all trades and blocks new ones when the daily loss limit, maximum loss or profit target is reached. Works with manual trading and any other EA. Never opens trades on a live chart."

#include <Trade\Trade.mqh>

//--- what the daily loss is measured from
enum ENUM_DAILY_BASE
  {
   DAILY_BASE_BALANCE,  // Balance at day start
   DAILY_BASE_EQUITY,   // Equity at day start
   DAILY_BASE_HIGHER    // Higher of balance and equity at day start
  };

//--- input parameters
input double          InpDailyLossPct    = 5.0;               // Daily loss limit, %
input ENUM_DAILY_BASE InpDailyBase       = DAILY_BASE_HIGHER; // Daily loss measured from
input double          InpMaxLossPct      = 10.0;              // Maximum overall loss, % of initial balance (0 = off)
input double          InpInitialBalance  = 0.0;               // Initial balance (0 = balance when first attached)
input double          InpProfitTargetPct = 0.0;               // Close all at profit target, % of initial balance (0 = off)
input int             InpResetHour       = 0;                 // Daily reset hour, server time
input double          InpWarnLevel       = 80.0;              // Warn when this % of a limit is used
input long            InpMagic           = -1;                // Manage only this magic number (-1 = all trades)
input bool            InpAllSymbols      = true;              // Manage all symbols (false = chart symbol only)
input bool            InpPushAlerts      = true;              // Send MT5 push notifications
input bool            InpTesterDemo      = true;              // Strategy Tester only: open sample trades to show the guard working

//--- lock states
enum ENUM_LOCK
  {
   LOCK_NONE,
   LOCK_DAILY,          // until the next daily reset
   LOCK_MAX_LOSS,       // permanent until the EA is reset
   LOCK_TARGET          // permanent until the EA is reset
  };

CTrade    g_trade;
string    g_gv;                 // global variable prefix for persistence
datetime  g_day_key    = 0;
double    g_day_start  = 0;
double    g_init_bal   = 0;
ENUM_LOCK g_lock       = LOCK_NONE;
bool      g_warn_daily = false;
bool      g_warn_max   = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDailyLossPct <= 0 || InpDailyLossPct >= 100 || InpMaxLossPct < 0 || InpMaxLossPct >= 100 ||
      InpResetHour < 0 || InpResetHour > 23 || InpWarnLevel <= 0 || InpWarnLevel > 100)
     {
      Print("Prop Firm Guard: check the input values");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_trade.SetDeviationInPoints(50);
   g_gv = "PFG_" + (string)AccountInfoInteger(ACCOUNT_LOGIN) + "_";
   LoadState();
   EventSetTimer(1);
   Check();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   SaveState();
   ObjectsDeleteAll(0, "PFG_");
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   Check();
   if(MQLInfoInteger(MQL_TESTER) && InpTesterDemo)
      TesterDemoTrade();
  }

//+------------------------------------------------------------------+
//| Timer: keeps checking even when the chart symbol has no ticks    |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Check();
   if(MQLInfoInteger(MQL_TESTER) && InpTesterDemo)
      TesterDemoTrade();
  }

//+------------------------------------------------------------------+
//| Start of the current trading day according to the reset hour     |
//+------------------------------------------------------------------+
datetime DayKey(const datetime t)
  {
   long shifted = (long)t - InpResetHour * 3600;
   return((datetime)((shifted / 86400) * 86400 + InpResetHour * 3600));
  }

//+------------------------------------------------------------------+
//| Value the daily loss is measured from                            |
//+------------------------------------------------------------------+
double DailyBaseValue()
  {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpDailyBase == DAILY_BASE_BALANCE)
      return(bal);
   if(InpDailyBase == DAILY_BASE_EQUITY)
      return(eq);
   return(MathMax(bal, eq));
  }

//+------------------------------------------------------------------+
//| Load persisted state so a restart does not reset the limits      |
//+------------------------------------------------------------------+
void LoadState()
  {
   g_init_bal = InpInitialBalance;
   if(g_init_bal <= 0)
     {
      if(GlobalVariableCheck(g_gv + "init"))
         g_init_bal = GlobalVariableGet(g_gv + "init");
      else
         g_init_bal = AccountInfoDouble(ACCOUNT_BALANCE);
     }
   if(GlobalVariableCheck(g_gv + "daykey"))
     {
      g_day_key   = (datetime)GlobalVariableGet(g_gv + "daykey");
      g_day_start = GlobalVariableGet(g_gv + "daystart");
      g_lock      = (ENUM_LOCK)(int)GlobalVariableGet(g_gv + "lock");
     }
  }

//+------------------------------------------------------------------+
//| Save state to terminal global variables                          |
//+------------------------------------------------------------------+
void SaveState()
  {
   GlobalVariableSet(g_gv + "init", g_init_bal);
   GlobalVariableSet(g_gv + "daykey", (double)g_day_key);
   GlobalVariableSet(g_gv + "daystart", g_day_start);
   GlobalVariableSet(g_gv + "lock", (double)g_lock);
  }

//+------------------------------------------------------------------+
//| Log, print and optionally push a message                         |
//+------------------------------------------------------------------+
void Notify(const string msg)
  {
   Print("Prop Firm Guard: ", msg);
   if(InpPushAlerts && !MQLInfoInteger(MQL_TESTER) && TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
      SendNotification("Prop Firm Guard " + (string)AccountInfoInteger(ACCOUNT_LOGIN) + ": " + msg);
  }

//+------------------------------------------------------------------+
//| Main rule check                                                  |
//+------------------------------------------------------------------+
void Check()
  {
   datetime key = DayKey(TimeCurrent());
   if(key != g_day_key)
     {
      //--- new trading day: new daily base, daily lock expires
      g_day_key    = key;
      g_day_start  = DailyBaseValue();
      g_warn_daily = false;
      if(g_lock == LOCK_DAILY)
        {
         g_lock = LOCK_NONE;
         Notify("new day, daily lock released");
        }
      SaveState();
     }

   double eq          = AccountInfoDouble(ACCOUNT_EQUITY);
   double daily_limit = g_day_start * InpDailyLossPct / 100.0;
   double daily_loss  = MathMax(0.0, g_day_start - eq);
   double daily_used  = daily_limit > 0 ? daily_loss / daily_limit * 100.0 : 0;

   double max_limit = g_init_bal * InpMaxLossPct / 100.0;
   double max_loss  = MathMax(0.0, g_init_bal - eq);
   double max_used  = max_limit > 0 ? max_loss / max_limit * 100.0 : 0;

   double target = g_init_bal * (1.0 + InpProfitTargetPct / 100.0);

//--- limits, most severe first
   if(g_lock != LOCK_MAX_LOSS && InpMaxLossPct > 0 && max_used >= 100.0)
     {
      g_lock = LOCK_MAX_LOSS;
      Notify(StringFormat("MAXIMUM LOSS reached (equity %.2f). All trades closed, trading blocked.", eq));
      SaveState();
     }
   else
      if(g_lock == LOCK_NONE && InpProfitTargetPct > 0 && eq >= target && OpenCount() > 0)
        {
         g_lock = LOCK_TARGET;
         Notify(StringFormat("PROFIT TARGET reached (equity %.2f). All trades closed.", eq));
         SaveState();
        }
      else
         if(g_lock == LOCK_NONE && daily_used >= 100.0)
           {
            g_lock = LOCK_DAILY;
            Notify(StringFormat("DAILY LOSS LIMIT reached (equity %.2f, loss %.2f). Trades closed until the next reset.", eq, daily_loss));
            SaveState();
           }

//--- early warnings, once per day / once per lock
   if(!g_warn_daily && g_lock == LOCK_NONE && daily_used >= InpWarnLevel)
     {
      g_warn_daily = true;
      Notify(StringFormat("warning: %.0f%% of the daily loss limit used", daily_used));
     }
   if(!g_warn_max && InpMaxLossPct > 0 && max_used >= InpWarnLevel && g_lock != LOCK_MAX_LOSS)
     {
      g_warn_max = true;
      Notify(StringFormat("warning: %.0f%% of the maximum loss limit used", max_used));
     }

//--- while locked, close everything, including trades opened after the lock
   if(g_lock != LOCK_NONE)
      CloseAll();

   ShowStatus(eq, daily_loss, daily_limit, daily_used, max_loss, max_limit, max_used);
  }

//+------------------------------------------------------------------+
//| Does a position or order belong to the managed set?              |
//+------------------------------------------------------------------+
bool IsManaged(const string symbol, const long magic)
  {
   if(InpMagic >= 0 && magic != InpMagic)
      return(false);
   if(!InpAllSymbols && symbol != _Symbol)
      return(false);
   return(true);
  }

//+------------------------------------------------------------------+
//| Number of managed open positions                                 |
//+------------------------------------------------------------------+
int OpenCount()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) > 0 && IsManaged(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
         n++;
   return(n);
  }

//+------------------------------------------------------------------+
//| Close managed positions and delete managed pending orders        |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !IsManaged(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
         continue;
      if(!g_trade.PositionClose(ticket))
         PrintFormat("Prop Firm Guard: close #%I64u failed, retcode %u (will retry)", ticket, g_trade.ResultRetcode());
     }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0 || !IsManaged(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC)))
         continue;
      if(!g_trade.OrderDelete(ticket))
         PrintFormat("Prop Firm Guard: delete order #%I64u failed, retcode %u (will retry)", ticket, g_trade.ResultRetcode());
     }
  }

//+------------------------------------------------------------------+
//| Status text in the chart corner                                  |
//+------------------------------------------------------------------+
void ShowStatus(const double eq, const double dl, const double dlim, const double dused,
                const double ml, const double mlim, const double mused)
  {
   string ccy  = AccountInfoString(ACCOUNT_CURRENCY);
   string lock = "OK - trading allowed";
   if(g_lock == LOCK_DAILY)
      lock = "LOCKED until next daily reset";
   if(g_lock == LOCK_MAX_LOSS)
      lock = "LOCKED - maximum loss reached";
   if(g_lock == LOCK_TARGET)
      lock = "LOCKED - profit target reached";

   string rows[7];
   color  clrs[7];
   ArrayInitialize(clrs, clrBlack);
   rows[0] = "PROP FIRM EQUITY GUARD";
   rows[1] = "Status     : " + lock;
   clrs[1] = (g_lock == LOCK_NONE) ? clrSeaGreen : clrRed;
   rows[2] = StringFormat("Equity     : %.2f %s", eq, ccy);
   rows[3] = StringFormat("Daily loss : %.2f / %.2f  (%.0f%%)", dl, dlim, dused);
   clrs[3] = (dused >= InpWarnLevel) ? clrRed : clrBlack;
   rows[4] = InpMaxLossPct > 0 ? StringFormat("Max loss   : %.2f / %.2f  (%.0f%%)", ml, mlim, mused) : "Max loss   : off";
   clrs[4] = (InpMaxLossPct > 0 && mused >= InpWarnLevel) ? clrRed : clrBlack;
   rows[5] = InpProfitTargetPct > 0 ? StringFormat("Target     : %.2f %s", g_init_bal * (1.0 + InpProfitTargetPct / 100.0), ccy) : "Target     : off";
   rows[6] = StringFormat("Day start  : %.2f  (reset %02d:00)", g_day_start, InpResetHour);

   int row_h = 18;
   string bg = "PFG_bg";
   if(ObjectFind(0, bg) < 0)
     {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, 25);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, 290);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, 7 * row_h + 12);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, clrWhiteSmoke);
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, clrGray);
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
     }
   for(int i = 0; i < 7; i++)
     {
      string name = "PFG_row" + (string)i;
      if(ObjectFind(0, name) < 0)
        {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 18);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 31 + i * row_h);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
         ObjectSetString(0, name, OBJPROP_FONT, i == 0 ? "Arial Bold" : "Consolas");
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        }
      ObjectSetString(0, name, OBJPROP_TEXT, rows[i]);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrs[i]);
     }
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Strategy Tester demonstration: one large buy at the start of     |
//| every day, so the daily limit can be seen triggering.            |
//+------------------------------------------------------------------+
void TesterDemoTrade()
  {
   static datetime last_day = 0;
   static datetime next_try = 0;
   if(g_lock != LOCK_NONE || g_day_key == last_day || PositionsTotal() > 0 || TimeCurrent() < next_try)
      return;
   if(!MarketOpen())
      return;

   double lots = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double step       = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//--- size the demo trade so a 200-point move equals the whole daily limit
   if(tick_value > 0 && tick_size > 0 && step > 0)
     {
      double per_lot = 200 * _Point / tick_size * tick_value;
      lots = MathFloor(g_day_start * InpDailyLossPct / 100.0 / per_lot / step) * step;
      //--- never use more than half of the free margin
      double margin_1lot = 0;
      MqlTick tick;
      if(SymbolInfoTick(_Symbol, tick) && OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, tick.ask, margin_1lot) && margin_1lot > 0)
         lots = MathMin(lots, MathFloor(AccountInfoDouble(ACCOUNT_MARGIN_FREE) * 0.5 / margin_1lot / step) * step);
      lots = MathMax(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), MathMin(lots, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)));
     }
//--- skip (and retry on a later tick) if even this volume does not fit the free margin
   double margin = 0;
   MqlTick now;
   if(!SymbolInfoTick(_Symbol, now) || now.ask <= 0 ||
      !OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lots, now.ask, margin) || margin >= AccountInfoDouble(ACCOUNT_MARGIN_FREE))
      return;
   g_trade.SetExpertMagicNumber(InpMagic >= 0 ? InpMagic : 0);
//--- count the day as done only when the order is filled (market can be closed at the day's first tick)
   if(g_trade.Buy(lots, _Symbol, 0, 0, 0, "PFG tester demo") && g_trade.ResultRetcode() == TRADE_RETCODE_DONE)
      last_day = g_day_key;
   else
      next_try = TimeCurrent() + 3600;          // after a rejection wait an hour before trying again
  }

//+------------------------------------------------------------------+
//| True when the symbol has a fresh quote inside a trading session  |
//+------------------------------------------------------------------+
bool MarketOpen()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.ask <= 0 || TimeCurrent() - tick.time > 60)
      return(false);
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
      return(false);
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime now_sec = (datetime)(dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime from, to;
   for(uint i = 0; SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)dt.day_of_week, i, from, to); i++)
      if(now_sec >= from && now_sec < to)
         return(true);
   return(false);
  }
//+------------------------------------------------------------------+

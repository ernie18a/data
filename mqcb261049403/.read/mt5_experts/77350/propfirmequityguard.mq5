//+------------------------------------------------------------------+
//|                                          PropFirmEquityGuard.mq5 |
//|        Prop-Firm Equity Guard - daily & max drawdown protection   |
//|                                                                  |
//|  Attach this utility EA to ONE chart. It monitors the whole      |
//|  account and protects prop-firm style limits (FTMO and similar): |
//|                                                                  |
//|   1. DAILY loss limit  - measured from the day-start snapshot    |
//|   2. MAX overall loss  - measured from the initial account size  |
//|                                                                  |
//|  When a limit (minus your safety buffer) is hit, the guard:      |
//|   - closes ALL open positions and deletes ALL pending orders     |
//|   - sets the global variable "DDGUARD_HALT" to 1.0 so that any   |
//|     other EA on the account can stop trading too. In your own    |
//|     EAs simply check:                                            |
//|        if(GlobalVariableGet("DDGUARD_HALT") > 0.0) return;       |
//|                                                                  |
//|  Trading stays blocked until the next trading day (daily breach) |
//|  or permanently (max breach), matching prop-firm logic.          |
//|                                                                  |
//|  v1.10 - the breach state and the day-start snapshot are now     |
//|  PERSISTED to Terminal\Common\Files (one file per account), so   |
//|  a terminal restart, a VPS reboot, a recompile or a manual       |
//|  re-attach can no longer clear a halt or re-anchor the daily     |
//|  limit to the reduced equity. Thanks to Valerii Sakara for       |
//|  reporting the state-loss bug in v1.00.                          |
//|                                                                  |
//|  v1.12 - file renamed to PropFirmEquityGuard.mq5. No on-chart    |
//|  elements; protection logic identical to v1.10.                  |
//+------------------------------------------------------------------+
#property copyright "Cristian Ciunae"
#property version   "1.12"
#property strict

#include <Trade/Trade.mqh>

//--- inputs
input double InpInitialBalance   = 100000.0; // Initial account size (challenge size)
input double InpDailyLossPct     = 5.0;      // Prop-firm daily loss limit, %
input double InpMaxLossPct       = 10.0;     // Prop-firm max overall loss limit, %
input double InpBufferPct        = 1.0;      // Safety buffer, % (halt this much BEFORE the real limit)
input int    InpDayStartHour     = 0;        // Trading-day rollover hour (server time, FTMO: midnight CE(S)T)
input bool   InpUseEquityForDay  = true;     // Day-start snapshot: true = max(balance, equity), false = balance
input bool   InpCloseOnBreach    = true;     // Close all positions/orders on breach
input string InpHaltFlagName     = "DDGUARD_HALT"; // Global variable name other EAs should check
input bool   InpResetState       = false;    // Set to true ONCE to clear a stored halt (new challenge)

//--- state
CTrade   trade;
double   g_dayStartLevel  = 0.0;   // snapshot at the start of the trading day
datetime g_currentDay     = 0;     // day being tracked (rounded to rollover)
bool     g_dailyBreached  = false;
bool     g_maxBreached    = false;
string   g_stateFile      = "";    // Common\Files, one file per account

//+------------------------------------------------------------------+
//| Returns the current trading-day anchor (server time)             |
//+------------------------------------------------------------------+
datetime TradingDayAnchor()
  {
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   dt.hour = InpDayStartHour;
   dt.min  = 0;
   dt.sec  = 0;
   datetime anchor = StructToTime(dt);
   if(anchor > now)               // before today's rollover -> still previous trading day
      anchor -= 86400;
   return anchor;
  }
//+------------------------------------------------------------------+
//| Persisted state: max breach, daily breach, day anchor, day level |
//+------------------------------------------------------------------+
void SaveState()
  {
   int h = FileOpen(g_stateFile, FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON, ';');
   if(h == INVALID_HANDLE)
     {
      PrintFormat("[EquityGuard] WARNING: cannot write the state file '%s' (error %d) - "
                  "a restart could clear the halt.", g_stateFile, GetLastError());
      return;
     }
   FileWrite(h, (int)g_maxBreached, (int)g_dailyBreached,
             (long)g_currentDay, DoubleToString(g_dayStartLevel, 2));
   FileClose(h);
  }

//--- returns true if a stored state was found
bool LoadState(bool &maxBreached, bool &dailyBreached, datetime &day, double &level)
  {
   maxBreached = dailyBreached = false;
   day = 0;
   level = 0.0;
   if(!FileIsExist(g_stateFile, FILE_COMMON))
      return false;
   int h = FileOpen(g_stateFile, FILE_READ | FILE_CSV | FILE_ANSI | FILE_COMMON, ';');
   if(h == INVALID_HANDLE)
      return false;
   maxBreached   = (StringToInteger(FileReadString(h)) != 0);
   dailyBreached = (StringToInteger(FileReadString(h)) != 0);
   day           = (datetime)StringToInteger(FileReadString(h));
   level         = StringToDouble(FileReadString(h));
   FileClose(h);
   return true;
  }
//+------------------------------------------------------------------+
//| Take the day-start snapshot                                      |
//+------------------------------------------------------------------+
void SnapshotDayStart()
  {
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayStartLevel = InpUseEquityForDay ? MathMax(bal, eq) : bal;
   g_dailyBreached = false;                       // daily block resets each new day
   SaveState();
   PrintFormat("[EquityGuard] New trading day. Day-start level: %.2f", g_dayStartLevel);
  }
//+------------------------------------------------------------------+
//| Halt flag helper (global variable + flush to disk)               |
//+------------------------------------------------------------------+
void SetHaltFlag(const double value)
  {
   GlobalVariableSet(InpHaltFlagName, value);
   GlobalVariablesFlush();
  }
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpInitialBalance <= 0)
     {
      Print("[EquityGuard] InpInitialBalance must be > 0");
      return(INIT_PARAMETERS_INCORRECT);
     }

   g_stateFile = StringFormat("DDGuard_%I64d.csv", AccountInfoInteger(ACCOUNT_LOGIN));

   if(InpResetState)
     {
      FileDelete(g_stateFile, FILE_COMMON);
      SetHaltFlag(0.0);
      Print("[EquityGuard] State reset by input. Set InpResetState back to false, "
            "otherwise the stored halt is cleared on every restart.");
     }

   //--- restore what is known about this account
   bool     sMax = false, sDaily = false;
   datetime sDay = 0;
   double   sLevel = 0.0;
   bool     found = LoadState(sMax, sDaily, sDay, sLevel);

   g_currentDay  = TradingDayAnchor();
   g_maxBreached = found ? sMax : false;

   if(found && sDay == g_currentDay && sLevel > 0.0)
     {
      //--- same trading day: keep the original snapshot and the daily state
      g_dayStartLevel = sLevel;
      g_dailyBreached = sDaily;
      PrintFormat("[EquityGuard] State restored. Day-start level: %.2f | daily breach: %s | max breach: %s",
                  g_dayStartLevel, g_dailyBreached ? "YES" : "no", g_maxBreached ? "YES" : "no");
     }
   else
      SnapshotDayStart();                 // new trading day (or first run)

   if(g_maxBreached)
     {
      SetHaltFlag(1.0);
      Print("[EquityGuard] *** MAX drawdown was already breached on this account - trading stays halted. *** "
            "Use InpResetState = true to start a new challenge.");
     }
   else
      SetHaltFlag(g_dailyBreached ? 1.0 : 0.0);

   SaveState();
   PrintFormat("[EquityGuard] Active. Daily limit %.1f%% | Max limit %.1f%% | Buffer %.1f%% | State file: Common\\Files\\%s",
               InpDailyLossPct, InpMaxLossPct, InpBufferPct, g_stateFile);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- never clear an active breach: it is restored from the state file
   if(!g_maxBreached && !g_dailyBreached)
      SetHaltFlag(0.0);
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- day rollover
   datetime anchor = TradingDayAnchor();
   if(anchor != g_currentDay)
     {
      g_currentDay = anchor;
      SnapshotDayStart();
      if(!g_maxBreached)
         SetHaltFlag(0.0);                         // re-allow trading on a new day
     }

   if(g_maxBreached)
      return;                                      // permanent stop, nothing more to do

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   //--- 1) MAX overall drawdown (from initial account size)
   double maxStopLevel = InpInitialBalance * (1.0 - (InpMaxLossPct - InpBufferPct) / 100.0);
   if(equity <= maxStopLevel)
     {
      g_maxBreached = true;
      SaveState();                                 // persist BEFORE closing anything
      Halt(StringFormat("MAX drawdown protection hit. Equity %.2f <= %.2f", equity, maxStopLevel));
      return;
     }

   //--- 2) DAILY drawdown (from day-start snapshot)
   if(!g_dailyBreached)
     {
      double dailyStopLevel = g_dayStartLevel * (1.0 - (InpDailyLossPct - InpBufferPct) / 100.0);
      if(equity <= dailyStopLevel)
        {
         g_dailyBreached = true;
         SaveState();
         Halt(StringFormat("DAILY drawdown protection hit. Equity %.2f <= %.2f", equity, dailyStopLevel));
        }
     }
  }
//+------------------------------------------------------------------+
//| Stop trading account-wide                                        |
//+------------------------------------------------------------------+
void Halt(const string reason)
  {
   Print("[EquityGuard] *** TRADING HALTED *** ", reason);
   SetHaltFlag(1.0);

   if(!InpCloseOnBreach)
      return;

   //--- close all open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(!trade.PositionClose(ticket))
            PrintFormat("[EquityGuard] Failed to close position #%I64u (retcode %d)",
                        ticket, trade.ResultRetcode());
        }
     }
   //--- delete all pending orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
        {
         if(!trade.OrderDelete(ticket))
            PrintFormat("[EquityGuard] Failed to delete order #%I64u (retcode %d)",
                        ticket, trade.ResultRetcode());
        }
     }
  }
//+------------------------------------------------------------------+

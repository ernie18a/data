//+------------------------------------------------------------------+
//|                                             ExampleDailyLock.mq5 |
//|  Example EA under test for the article "Live testing of Expert   |
//|  Advisors on a demo account".                                    |
//|                                                                  |
//|  A daily loss lock with the behaviours that only exist live:     |
//|  - state kept in terminal global variables across restarts       |
//|  - waits until the account is connected before loading state     |
//|  - one copy per account (owner id and heartbeat)                 |
//|  - day start rebuilt from today's deals when no state is saved   |
//|  - an Unlock button on the chart                                 |
//+------------------------------------------------------------------+
#property copyright "Article example"
#property version   "1.00"
#property description "Example for the article: a daily loss lock that keeps its state across restarts."

#include <Trade\Trade.mqh>

input double InpDailyLossMoney = 50.0; // Daily loss limit, account currency
input int    InpResetHour      = 0;    // Daily reset hour, server time (0-23)
input long   InpMagic          = -1;   // Positions to control: magic number (-1 = all)

#define BUTTON "EDL_unlock"

CTrade   g_trade;
bool     g_tester    = false;
bool     g_ready     = false;   // state loaded; nothing is saved before this
long     g_login     = 0;       // account the state belongs to
datetime g_connected = 0;       // local time the account was first seen connected
datetime g_lastBeat  = 0;

datetime g_dayKey    = 0;       // start of the current trading day
double   g_dayBal    = 0.0;     // balance at the day start
bool     g_locked    = false;
datetime g_lockUntil = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDailyLossMoney <= 0.0 || InpResetHour < 0 || InpResetHour > 23)
      return(INIT_PARAMETERS_INCORRECT);
   g_tester = (bool)MQLInfoInteger(MQL_TESTER);
   if(IsAccountReady() && Start() < 0)
      return(INIT_FAILED);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_ready)
     {
      SaveState();
      if(!g_tester)
         GlobalVariableSetOnCondition(Gv("owner"), 0.0, InstanceId()); // free the account
     }
   ObjectDelete(0, BUTTON);
   Comment("");
  }

void OnTick()  { Process(); }
void OnTimer() { Process(); }

//+------------------------------------------------------------------+
//| The Unlock button                                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON && g_ready && g_locked)
     {
      // a manual unlock starts a fresh daily budget from the equity now,
      // otherwise the loss that caused the lock would lock it again at once
      g_locked = false;
      g_lockUntil = 0;
      g_dayBal = AccountInfoDouble(ACCOUNT_EQUITY);
      SaveState();
      ObjectDelete(0, BUTTON);
      PrintFormat("Unlocked manually from the chart; new day start %.2f", g_dayBal);
      Process();
     }
  }

//+------------------------------------------------------------------+
//| Main pass                                                        |
//+------------------------------------------------------------------+
void Process()
  {
   if(!g_ready)
     {
      const int started = TryStart();
      if(started < 0)
        {
         ExpertRemove();
         return;
        }
      if(started == 0)
        {
         Comment("ExampleDailyLock: waiting for the account to connect");
         return;
        }
     }
   if(!g_tester && !KeepOwnership())
     {
      Print("Another copy took over this account; this copy stops");
      g_ready = false;
      ExpertRemove();
      return;
     }
   const datetime now = TimeTradeServer();
   const datetime key = DayKey(now);
   if(key != g_dayKey)
     {
      g_dayKey = key;
      g_dayBal = AccountInfoDouble(ACCOUNT_BALANCE);
      if(g_locked && now >= g_lockUntil)
         g_locked = false;
      SaveState();
     }
   const double loss = g_dayBal - AccountInfoDouble(ACCOUNT_EQUITY);
   if(!g_locked && loss >= InpDailyLossMoney)
     {
      g_locked = true;
      g_lockUntil = g_dayKey + 86400;
      SaveState();
      PrintFormat("LOCKED: daily loss %.2f reached the limit %.2f", loss, InpDailyLossMoney);
     }
   if(g_locked)
      CloseAll();
   ShowStatus(loss);
  }

//+------------------------------------------------------------------+
//| Start-up: the account must be connected before state is loaded   |
//+------------------------------------------------------------------+
bool IsAccountReady()
  {
   return(TerminalInfoInteger(TERMINAL_CONNECTED) != 0 && AccountInfoInteger(ACCOUNT_LOGIN) > 0 &&
          AccountInfoDouble(ACCOUNT_BALANCE) > 0.0);
  }

int TryStart()
  {
   if(!IsAccountReady())
     {
      g_connected = 0;
      return(0);
     }
   if(g_connected == 0)
      g_connected = TimeLocal();
   if(TimeLocal() - g_connected < 3)
      return(0); // let the trade history synchronise
   return(Start());
  }

// 1 = started, -1 = must not run
int Start()
  {
   g_login = AccountInfoInteger(ACCOUNT_LOGIN);
#ifdef DEMO_ONLY
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) != ACCOUNT_TRADE_MODE_DEMO)
     {
      Print("Test build: runs on demo accounts only");
      return(-1);
     }
#endif
   if(!g_tester && !ClaimOwnership())
     {
      Alert("ExampleDailyLock already runs on another chart for this account");
      return(-1);
     }
   LoadState();
   g_ready = true;
   SaveState();
   PrintFormat("Started | login %I64d | day start %s, balance %.2f | locked %s",
               g_login, TimeToString(g_dayKey), g_dayBal, g_locked ? "yes" : "no");
   return(1);
  }

//+------------------------------------------------------------------+
//| State in terminal global variables, keyed by the account login   |
//+------------------------------------------------------------------+
string Gv(const string key) { return("EDL." + IntegerToString(g_login) + "." + key); }

void SaveState()
  {
   if(!g_ready)
      return;
   GlobalVariableSet(Gv("dayKey"), (double)(long)g_dayKey);
   GlobalVariableSet(Gv("dayBal"), g_dayBal);
   GlobalVariableSet(Gv("locked"), g_locked ? 1.0 : 0.0);
   GlobalVariableSet(Gv("lockUntil"), (double)(long)g_lockUntil);
   if(!g_tester)
      GlobalVariablesFlush();
  }

void LoadState()
  {
   const datetime now = TimeTradeServer();
   const datetime key = DayKey(now);
   g_locked = GlobalVariableCheck(Gv("locked")) && GlobalVariableGet(Gv("locked")) > 0.5;
   g_lockUntil = GlobalVariableCheck(Gv("lockUntil")) ? (datetime)(long)GlobalVariableGet(Gv("lockUntil")) : 0;
   if(g_locked && now >= g_lockUntil)
      g_locked = false;
   if(GlobalVariableCheck(Gv("dayKey")) && (datetime)(long)GlobalVariableGet(Gv("dayKey")) == key)
     {
      g_dayKey = key;
      g_dayBal = GlobalVariableGet(Gv("dayBal"));
      return;
     }
   // no state for today: rebuild the day start from today's closed deals
   g_dayKey = key;
   g_dayBal = AccountInfoDouble(ACCOUNT_BALANCE) - ClosedProfitSince(key);
   PrintFormat("Day start rebuilt from today's deals: %.2f", g_dayBal);
  }

double ClosedProfitSince(const datetime from)
  {
   if(!HistorySelect(from, TimeTradeServer() + 60))
      return(0.0);
   double sum = 0.0;
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      const ulong ticket = HistoryDealGetTicket(i);
      const long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue; // deposits, withdrawals, credit: not trading results
      sum += HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_SWAP) +
             HistoryDealGetDouble(ticket, DEAL_COMMISSION) + HistoryDealGetDouble(ticket, DEAL_FEE);
     }
   return(sum);
  }

datetime DayKey(const datetime now)
  {
   MqlDateTime d;
   TimeToStruct(now, d);
   datetime key = now - (d.hour * 3600 + d.min * 60 + d.sec) + InpResetHour * 3600;
   if(now < key)
      key -= 86400;
   return(key);
  }

//+------------------------------------------------------------------+
//| One copy per account: owner id plus a heartbeat every second     |
//+------------------------------------------------------------------+
double InstanceId()
  {
   const long id = ChartID() % 1000000000000; // exact in a double
   return((double)(id > 0 ? id : 1));
  }

bool ClaimOwnership()
  {
   const string owner = Gv("owner");
   if(!GlobalVariableCheck(owner))
      GlobalVariableSet(owner, 0.0);
   const double current = GlobalVariableGet(owner);
   const double beat = GlobalVariableCheck(Gv("beat")) ? GlobalVariableGet(Gv("beat")) : 0.0;
   if(current != 0.0 && current != InstanceId() && TimeLocal() - (datetime)(long)beat <= 10)
      return(false); // the other copy is alive
   if(current != InstanceId() && !GlobalVariableSetOnCondition(owner, InstanceId(), current))
      return(false); // another copy claimed it a moment ago
   GlobalVariableSet(Gv("beat"), (double)(long)TimeLocal());
   return(true);
  }

bool KeepOwnership()
  {
   if(TimeLocal() == g_lastBeat)
      return(true);
   g_lastBeat = TimeLocal();
   if(GlobalVariableGet(Gv("owner")) != InstanceId())
      return(false);
   GlobalVariableSet(Gv("beat"), (double)(long)g_lastBeat);
   return(true);
  }

//+------------------------------------------------------------------+
//| Closing and display                                              |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      const ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || (InpMagic >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagic))
         continue;
      g_trade.SetTypeFillingBySymbol(PositionGetString(POSITION_SYMBOL));
      if(g_trade.PositionClose(ticket))
         PrintFormat("Closed #%I64u while locked", ticket);
     }
  }

void ShowStatus(const double loss)
  {
   if(g_tester)
      return;
   Comment(StringFormat("ExampleDailyLock | day start %.2f | daily loss %.2f of %.2f | %s",
                        g_dayBal, MathMax(0.0, loss), InpDailyLossMoney, g_locked ? "LOCKED" : "trading allowed"));
   if(g_locked && ObjectFind(0, BUTTON) < 0)
     {
      ObjectCreate(0, BUTTON, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, BUTTON, OBJPROP_XDISTANCE, 12);
      ObjectSetInteger(0, BUTTON, OBJPROP_YDISTANCE, 40);
      ObjectSetInteger(0, BUTTON, OBJPROP_XSIZE, 120);
      ObjectSetInteger(0, BUTTON, OBJPROP_YSIZE, 26);
      ObjectSetInteger(0, BUTTON, OBJPROP_BGCOLOR, clrFireBrick);
      ObjectSetInteger(0, BUTTON, OBJPROP_COLOR, clrWhite);
      ObjectSetString(0, BUTTON, OBJPROP_TEXT, "Unlock");
      ObjectSetInteger(0, BUTTON, OBJPROP_ZORDER, 10);
     }
   else
      if(!g_locked)
         ObjectDelete(0, BUTTON);
   ChartRedraw();
  }
//+------------------------------------------------------------------+

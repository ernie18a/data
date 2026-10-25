//+------------------------------------------------------------------+
//|                                               PropGuard_Lite.mq5 |
//|              Daily-loss / max-loss guard for prop-firm accounts  |
//+------------------------------------------------------------------+
#property copyright   "Manit Chin"
#property link        "https://www.mql5.com/en/users/manuay.17"
#property version     "1.03"
#property description "Risk tool. Watches account equity. When the daily loss limit or the max loss limit is reached it closes positions, deletes pending orders and keeps closing new ones until the next trading day (daily) or until you reset it (max loss)."
#property description "On a live or demo chart it never opens trades. Strategy Tester only: InpTesterDemo opens demo trades so you can watch it act."
#property description "Run ONE copy only: if you migrate it to an MQL5 VPS, turn Algo Trading off in your local terminal."

#include <Trade\Trade.mqh>

/*
   WHAT MUST ALWAYS BE TRUE (checked in code / self-test)
   1. Outside the Strategy Tester the guard never opens a position. The only
      Buy/Sell calls are in TesterDemo(), which returns at once unless
      MQLInfoInteger(MQL_TESTER) is true AND InpTesterDemo is true.
   2. The day-start reference is rebuilt from deal history on every check
      (balance now - today's trading P/L). A restart, recompile or VPS sync
      does not reset the day.
   3. While halted, every in-scope position / pending order is closed /
      deleted on every check (oldest first, FIFO-safe).
   4. Halts survive restarts and crashes: stored in terminal global
      variables and flushed to disk immediately. A max-loss halt stays until
      the user clears it on purpose.
   5. Invalid inputs -> the EA refuses to start. No silent defaults.
      InpInitialCapital = 0 means "auto": the first deposit found in the
      account history. Until it is found, NO limit is checked and the panel
      says so (CAPITAL UNKNOWN); an existing halt is still enforced.
   6. If deal history cannot be read, no reference is invented: the daily
      check is skipped for that round, counted, and shown on the panel.
      The max-loss check does not depend on history.
   7. When unsure, the guard picks the SAFER (higher) reference.

   EQUITY USED FOR LIMITS = ACCOUNT_EQUITY - ACCOUNT_CREDIT (credit is not
   your money and must not delay the guard).

   TRADING P/L = every deal except balance / credit / bonus deals
   (deposits, withdrawals, credit). Charges, corrections, interest, tax and
   commissions count as trading P/L.

   KNOWN LIMITS
   - Day reset time zone is a fixed offset (InpServerMinusResetTZ). If the
     server and the firm's zone switch DST on different dates, adjust the
     input on those weeks (an active daily halt is NOT cleared by that).
   - "Higher of balance/equity" needs the EA running and connected at the
     reset moment. Otherwise the balance reference is used, the panel says
     "estimated" and an alert is sent once per day.
   - The guard cannot switch off other EAs. It closes what they open while
     the halt is active.
*/

//--- enums
enum ENUM_PG_DAILY_BASE
  {
   PG_BASE_CAPITAL = 0,   // % of initial capital (FTMO style)
   PG_BASE_DAYREF  = 1    // % of day-start reference
  };
enum ENUM_PG_DAYREF
  {
   PG_REF_BALANCE = 0,    // balance at day start
   PG_REF_HIGHER  = 1     // higher of balance/equity at day start
  };
enum ENUM_PG_SCOPE
  {
   PG_SCOPE_ALL   = 0,    // all positions and orders on the account
   PG_SCOPE_MAGIC = 1     // only the magic number below
  };

//--- inputs
input group "Account"
input double             InpInitialCapital     = 0;               // InpInitialCapital: initial account size (e.g. 100000), 0 = auto (first deposit)
input group "Daily loss"
input bool               InpUseDaily           = true;            // InpUseDaily: enable daily loss limit
input double             InpDailyLossPct       = 5.0;             // InpDailyLossPct: daily loss limit, %
input ENUM_PG_DAILY_BASE InpDailyBase          = PG_BASE_CAPITAL; // InpDailyBase: daily % is taken from
input ENUM_PG_DAYREF     InpDayRef             = PG_REF_BALANCE;  // InpDayRef: day-start reference
input int                InpResetHour          = 0;               // InpResetHour: day reset hour in the firm's time zone (0-23)
input int                InpServerMinusResetTZ = 0;               // InpServerMinusResetTZ: server time minus firm time zone, hours
input group "Max loss"
input bool               InpUseMaxLoss         = true;            // InpUseMaxLoss: enable max (overall) loss limit
input double             InpMaxLossPct         = 10.0;            // InpMaxLossPct: max loss, % of initial capital
input bool               InpClearMaxLossHalt   = false;           // InpClearMaxLossHalt: true = clear saved max-loss halt (then set back to false)
input group "Action"
input double             InpBufferPct          = 0.5;             // InpBufferPct: act this % of capital BEFORE the limit
input ENUM_PG_SCOPE      InpScope              = PG_SCOPE_ALL;    // InpScope: what to close
input long               InpMagic              = 0;               // InpMagic: magic number when InpScope = magic (0 = manual trades)
input bool               InpDeletePending      = true;            // InpDeletePending: delete pending orders when halted
input int                InpDeviationPoints    = 200;             // InpDeviationPoints: max slippage when closing, points
input bool               InpPush               = false;           // InpPush: push notification to MT5 mobile app
input bool               InpShowPanel          = true;            // InpShowPanel: show status in chart corner
input bool               InpRunSelfTest        = false;           // InpRunSelfTest: run self-test at start (writes PropGuard_selftest.txt)
input group "Strategy Tester only"
input bool               InpTesterDemo         = true;            // InpTesterDemo: TESTER ONLY - open demo trades to show the guard working

//--- globals
CTrade   g_trade;
string   g_pfx            = "";
datetime g_dayStart       = 0;
double   g_dayRef         = -1.0;   // -1 = unknown
bool     g_refEstimated   = false;
bool     g_estAlerted     = false;
bool     g_haltDay        = false;
bool     g_haltTotal      = false;
bool     g_mismatchLogged = false;
int      g_refFailStreak  = 0;
bool     g_refFailAlerted = false;
ulong    g_lastEnforceMs  = 0;
datetime g_lastFailLog    = 0;
datetime g_backoffUntil   = 0;      // market closed / trading disabled -> wait before next request
datetime g_failSince      = 0;      // first failure of the current failing streak
bool     g_failAlerted    = false;
//--- counters (shown on panel, written to log)
int      g_cntClosed      = 0;
int      g_cntCloseFail   = 0;
int      g_cntDeleted     = 0;
int      g_cntDeleteFail  = 0;
int      g_cntRefFail     = 0;
//--- capital (InpInitialCapital, or auto = first deposit)
double   g_capital        = -1.0;   // -1 = unknown
bool     g_capAuto        = false;
int      g_capFailStreak  = 0;
bool     g_capAlerted     = false;
bool     g_capDoubtAlerted= false;
uint     g_capLastTryMs   = 0;
//--- tester demo trades
datetime g_demoLast       = 0;
bool     g_demoBuy        = true;
int      g_cntDemoOpen    = 0;
int      g_cntDemoSkip    = 0;
#define  PG_DEMO_MAGIC    20261022
bool     g_inited         = false;   // true after OnInit finished (no trading from OnInit)

//+------------------------------------------------------------------+
//| Pure helpers (covered by the self-test)                          |
//+------------------------------------------------------------------+
// Start of the trading day, expressed in server time.
datetime PG_DayStart(const datetime server_time,const int server_minus_tz_h,const int reset_hour)
  {
   long shift = (long)server_minus_tz_h*3600 + (long)reset_hour*3600;
   long local = (long)server_time - shift;
   long day   = local - (local % 86400);
   return (datetime)(day + shift);
  }

// Equity level that must not be reached today. -1 = invalid input.
double PG_DailyFloor(const double ref,const double capital,const double pct,const int base)
  {
   if(ref<=0.0 || capital<=0.0 || pct<=0.0 || pct>=100.0)
      return -1.0;
   if(base==PG_BASE_CAPITAL)
      return ref - capital*pct/100.0;
   return ref*(1.0-pct/100.0);
  }

// Equity level that must never be reached. -1 = invalid input.
double PG_TotalFloor(const double capital,const double pct)
  {
   if(capital<=0.0 || pct<=0.0 || pct>=100.0)
      return -1.0;
   return capital*(1.0-pct/100.0);
  }

// true = act now. An invalid floor (<=0) never triggers.
bool PG_Breached(const double equity,const double floor_level,const double buffer)
  {
   if(floor_level<=0.0)
      return false;
   return (equity <= floor_level + buffer);
  }

// Day reference.
//  bal_ref      : balance now - today's trading P/L (deposits counted as if at day start)
//  bal_snap     : balance snapshot at reset, -1 = none
//  eq_snap      : equity snapshot at reset, -1 = none
//  cash_today   : deposits(+)/withdrawals(-) since reset
//  estimated    : true when "higher" mode had no equity snapshot
// Rule 7: when unsure, pick the higher (safer) value.
double PG_ChooseRef(const double bal_ref,const double bal_snap,const double eq_snap,const double cash_today,
                    const int mode,bool &estimated)
  {
   estimated=false;
   double ref=bal_ref;
   // history may lag after a restart -> the reset snapshot (adjusted for cash moves) is a floor for the ref
   if(bal_snap>=0.0)
      ref=MathMax(ref,bal_snap+cash_today);
   if(mode==PG_REF_BALANCE)
      return ref;
   if(eq_snap<0.0)
     {
      estimated=true;
      return ref;
     }
   return MathMax(ref,eq_snap+cash_today);
  }

bool PG_IsCashType(const long deal_type)
  {
   return (deal_type==DEAL_TYPE_BALANCE || deal_type==DEAL_TYPE_CREDIT || deal_type==DEAL_TYPE_BONUS);
  }

// Retcodes where retrying every second is pointless (market closed / trading off)
bool PG_IsBackoffRetcode(const uint rc)
  {
   return (rc==TRADE_RETCODE_MARKET_CLOSED || rc==TRADE_RETCODE_TRADE_DISABLED ||
           rc==TRADE_RETCODE_CLIENT_DISABLES_AT || rc==TRADE_RETCODE_SERVER_DISABLES_AT);
  }

// Small stable hash so the same login on two servers does not share state
string PG_Hash(const string s)
  {
   uint h=5381;
   int n=StringLen(s);
   for(int i=0;i<n;i++)
      h=((h<<5)+h)+(uint)StringGetCharacter(s,i);
   return IntegerToString((long)h);
  }

// Round a volume DOWN to the symbol's step, cap at max. -1 = below the minimum.
double PG_NormLot(const double raw,const double vmin,const double vmax,const double step)
  {
   if(raw<=0.0 || vmin<=0.0 || step<=0.0 || vmax<vmin)
      return -1.0;
   double v=MathFloor(raw/step+1e-9)*step;
   if(v>vmax)
      v=MathFloor(vmax/step+1e-9)*step;
   int digits=0;
   while(digits<8 && MathAbs(step*MathPow(10,digits)-MathRound(step*MathPow(10,digits)))>1e-7)
      digits++;
   v=NormalizeDouble(v,digits);
   if(v<vmin-1e-12)
      return -1.0;
   return v;
  }

//+------------------------------------------------------------------+
//| Logging                                                          |
//+------------------------------------------------------------------+
void Log(const string ev,const string detail)
  {
   Print("PropGuard: ",ev," | ",detail);
   int h = FileOpen("PropGuard_log.csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_ANSI,',');
   if(h==INVALID_HANDLE)
     {
      Print("PropGuard: cannot open log file, error ",GetLastError());
      return;
     }
   if(FileSize(h)==0)
      FileWrite(h,"server_time","event","detail","equity","balance","credit");
   FileSeek(h,0,SEEK_END);
   FileWrite(h,TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS),ev,detail,
             DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2),
             DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2),
             DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT),2));
   FileFlush(h);
   FileClose(h);
  }

void Notify(const string msg)
  {
   Alert("PropGuard: ",msg);
   if(InpPush && !MQLInfoInteger(MQL_TESTER))
     {
      if(!SendNotification("PropGuard: "+StringSubstr(msg,0,240)))
         Log("PUSH_FAIL","error "+IntegerToString(GetLastError()));
     }
  }

//+------------------------------------------------------------------+
//| Terminal global variables (per login + server)                   |
//+------------------------------------------------------------------+
string GvHaltDayUntil() { return g_pfx+"HD_UNTIL"; }
string GvHaltTotal()    { return g_pfx+"HT"; }
string GvLock()         { return g_pfx+"LOCK"; }     // value = chart id of the owner
string GvLockBeat()     { return g_pfx+"LOCK_T"; }   // value = owner's last heartbeat (TimeLocal)
string GvEqSnap(const datetime d)  { return g_pfx+"EQ_"+IntegerToString((long)d); }
string GvBalSnap(const datetime d) { return g_pfx+"BAL_"+IntegerToString((long)d); }

void GvSetFlush(const string name,const double v)
  {
   if(GlobalVariableSet(name,v)==0)
      Log("GV_FAIL",name+" error "+IntegerToString(GetLastError()));
   GlobalVariablesFlush();   // survive a crash / power loss
  }

//+------------------------------------------------------------------+
//| Today's trading P/L and cash moves from deal history.            |
//| Account-wide (all magics, all symbols). false = not readable.    |
//+------------------------------------------------------------------+
bool TodayDeals(const datetime from,double &pnl,double &cash)
  {
   pnl=0.0;
   cash=0.0;
   if(!HistorySelect(from,TimeTradeServer()+86400))
      return false;
   int n=HistoryDealsTotal();
   for(int i=0;i<n;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0)
         return false;
      if((datetime)HistoryDealGetInteger(t,DEAL_TIME)<from)
         continue;
      double v = HistoryDealGetDouble(t,DEAL_PROFIT)
               + HistoryDealGetDouble(t,DEAL_COMMISSION)
               + HistoryDealGetDouble(t,DEAL_SWAP)
               + HistoryDealGetDouble(t,DEAL_FEE);
      long type=HistoryDealGetInteger(t,DEAL_TYPE);
      if(PG_IsCashType(type))
        {
         if(type==DEAL_TYPE_BALANCE)    // credit/bonus do not change balance
            cash+=v;
        }
      else
         pnl+=v;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Day roll + restore day halt                                      |
//+------------------------------------------------------------------+
void UpdateDay()
  {
   datetime now = TimeTradeServer();
   datetime ds  = PG_DayStart(now,InpServerMinusResetTZ,InpResetHour);
   if(ds!=g_dayStart)
     {
      bool rolled_while_running = (g_dayStart!=0);
      g_dayStart       = ds;
      g_dayRef         = -1.0;    // never carry yesterday's reference into today
      g_refEstimated   = false;
      g_estAlerted     = false;
      g_mismatchLogged = false;
      if(rolled_while_running)
        {
         if(TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            if(!GlobalVariableCheck(GvEqSnap(ds)))
               GvSetFlush(GvEqSnap(ds),AccountInfoDouble(ACCOUNT_EQUITY)-AccountInfoDouble(ACCOUNT_CREDIT));
            if(!GlobalVariableCheck(GvBalSnap(ds)))
               GvSetFlush(GvBalSnap(ds),AccountInfoDouble(ACCOUNT_BALANCE));
           }
         else
            Log("SNAPSHOT_SKIPPED","terminal not connected at day reset");
         Log("NEW_DAY",TimeToString(ds,TIME_DATE|TIME_MINUTES)+" (server time)");
         // remove snapshots older than 7 days
         GlobalVariablesDeleteAll(g_pfx+"EQ_",now-7*86400);
         GlobalVariablesDeleteAll(g_pfx+"BAL_",now-7*86400);
        }
      // keep the max-loss halt "touched" so the terminal never expires it
      if(g_haltTotal)
         GvSetFlush(GvHaltTotal(),1.0);
      if(g_capAuto && g_capital>0.0)
         GvSetFlush(GvCapital(),g_capital);       // keep the auto capital alive too
     }
   // daily halt lasts until a stored end time -> changing time inputs cannot clear it
   bool was = g_haltDay;
   g_haltDay = GlobalVariableCheck(GvHaltDayUntil()) && now < (datetime)(long)GlobalVariableGet(GvHaltDayUntil());
   if(g_haltDay && !was)
      Log("HALT_DAY_ACTIVE","daily halt active until "+TimeToString((datetime)(long)GlobalVariableGet(GvHaltDayUntil()),TIME_DATE|TIME_MINUTES));
  }

//+------------------------------------------------------------------+
//| Rebuild the day reference                                        |
//+------------------------------------------------------------------+
void RecalcRef()
  {
   double pnl=0.0, cash=0.0;
   if(!TodayDeals(g_dayStart,pnl,cash))
     {
      g_cntRefFail++;
      g_refFailStreak++;
      if(g_refFailStreak>=5 && !g_refFailAlerted)
        {
         g_refFailAlerted=true;
         Notify("cannot read deal history - daily limit is NOT being checked");
         Log("REF_FAIL","history not readable 5 times in a row");
        }
      return;   // keep today's last known value (or unknown); never invent one
     }
   g_refFailStreak=0;
   g_refFailAlerted=false;
   double bal_ref  = AccountInfoDouble(ACCOUNT_BALANCE) - pnl;
   double bal_snap = GlobalVariableCheck(GvBalSnap(g_dayStart)) ? GlobalVariableGet(GvBalSnap(g_dayStart)) : -1.0;
   double eq_snap  = GlobalVariableCheck(GvEqSnap(g_dayStart))  ? GlobalVariableGet(GvEqSnap(g_dayStart))  : -1.0;

   if(bal_snap>=0.0 && !g_mismatchLogged && MathAbs((bal_snap+cash)-bal_ref)>0.01)
     {
      g_mismatchLogged=true;
      Log("REF_MISMATCH","history ref "+DoubleToString(bal_ref,2)+" vs reset snapshot+cash "+DoubleToString(bal_snap+cash,2)
          +" - using the higher one");
     }

   g_dayRef = PG_ChooseRef(bal_ref,bal_snap,eq_snap,cash,InpDayRef,g_refEstimated);

   if(g_refEstimated && !g_estAlerted)
     {
      g_estAlerted=true;
      Notify("'higher of balance/equity' reference is ESTIMATED today (EA was not running at reset) - the firm's limit may be tighter than shown");
     }
  }

//+------------------------------------------------------------------+
bool InScope(const long magic)
  {
   return (InpScope==PG_SCOPE_ALL || magic==InpMagic);
  }

//+------------------------------------------------------------------+
//| Close everything in scope, oldest first (FIFO accounts).         |
//| Truth comes from the account: anything not closed is retried.    |
//+------------------------------------------------------------------+
void EnforceFlat()
  {
   datetime now = TimeTradeServer();
   if(!MQLInfoInteger(MQL_TESTER))
     {
      ulong now_ms=GetTickCount64();
      if(now_ms-g_lastEnforceMs<900)
         return;                                 // about 1 round per second
      g_lastEnforceMs=now_ms;
     }
   if(now<g_backoffUntil)
      return;                                    // market closed / trading disabled: wait
   bool log_fail = (now-g_lastFailLog>=60);
   bool any_fail = false;

   //--- collect in-scope positions, sort oldest first
   ulong    tks[];
   long     tms[];
   int      cnt=0;
   int      total=PositionsTotal();
   ArrayResize(tks,total);
   ArrayResize(tms,total);
   for(int i=0;i<total;i++)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0)
         continue;
      if(!InScope(PositionGetInteger(POSITION_MAGIC)))
         continue;
      tks[cnt]=tk;
      tms[cnt]=PositionGetInteger(POSITION_TIME_MSC);
      cnt++;
     }
   for(int a=1;a<cnt;a++)                         // insertion sort, small arrays
     {
      ulong kt=tks[a]; long km=tms[a]; int b=a-1;
      while(b>=0 && tms[b]>km) { tks[b+1]=tks[b]; tms[b+1]=tms[b]; b--; }
      tks[b+1]=kt; tms[b+1]=km;
     }

   for(int k=0;k<cnt;k++)
     {
      if(!PositionSelectByTicket(tks[k]))
         continue;                                // already gone
      string sym=PositionGetString(POSITION_SYMBOL);
      if(!g_trade.SetTypeFillingBySymbol(sym) && log_fail)
         Log("FILLING_WARN",sym+": could not read filling mode, using default");
      bool ok = g_trade.PositionClose(tks[k],(ulong)InpDeviationPoints);
      uint rc = g_trade.ResultRetcode();
      if(rc==TRADE_RETCODE_REQUOTE || rc==TRADE_RETCODE_PRICE_CHANGED)
        {
         ok = g_trade.PositionClose(tks[k],(ulong)InpDeviationPoints);   // one immediate retry
         rc = g_trade.ResultRetcode();
        }
      if(ok && (rc==TRADE_RETCODE_DONE || rc==TRADE_RETCODE_DONE_PARTIAL || rc==TRADE_RETCODE_PLACED))
        {
         g_cntClosed++;
         Log("CLOSED","#"+IntegerToString((long)tks[k])+" "+sym+" rc="+IntegerToString(rc));
        }
      else
        {
         g_cntCloseFail++;
         any_fail=true;
         if(PG_IsBackoffRetcode(rc))
            g_backoffUntil=now+60;
         if(log_fail)
            Log("CLOSE_FAIL","#"+IntegerToString((long)tks[k])+" "+sym+" rc="+IntegerToString(rc)+" "+g_trade.ResultRetcodeDescription());
        }
     }

   if(InpDeletePending)
     {
      for(int i=OrdersTotal()-1;i>=0;i--)
        {
         ulong ot=OrderGetTicket(i);
         if(ot==0)
            continue;
         if(!InScope(OrderGetInteger(ORDER_MAGIC)))
            continue;
         bool ok = g_trade.OrderDelete(ot);
         uint rc = g_trade.ResultRetcode();
         if(ok && (rc==TRADE_RETCODE_DONE || rc==TRADE_RETCODE_PLACED))
           {
            g_cntDeleted++;
            Log("DELETED","order #"+IntegerToString((long)ot));
           }
         else
           {
            g_cntDeleteFail++;
            any_fail=true;
            if(PG_IsBackoffRetcode(rc))
               g_backoffUntil=now+60;
            if(log_fail)
               Log("DELETE_FAIL","order #"+IntegerToString((long)ot)+" rc="+IntegerToString(rc)+" "+g_trade.ResultRetcodeDescription());
           }
        }
     }

   if(any_fail)
     {
      if(log_fail)
         g_lastFailLog=now;
      if(g_failSince==0)
         g_failSince=now;
      if(!g_failAlerted && now-g_failSince>=30)
        {
         g_failAlerted=true;
         Notify("closing has been FAILING for 30+ seconds - check Algo Trading / market hours / the log");
        }
     }
   else
     {
      g_failSince=0;
      g_failAlerted=false;
     }
  }

//+------------------------------------------------------------------+
//| Initial capital: the input, or auto = first deposit in history.  |
//| false = still unknown (history not readable / no deposit found). |
//+------------------------------------------------------------------+
string GvCapital() { return g_pfx+"CAP"; }

// Auto capital must be plausible: balance now within 0.5x - 2x of it.
// Otherwise (withdrawals, tiny first deposit, later top-ups) it is NOT used.
bool CapitalPlausible(const double cap,const string src)
  {
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   if(bal>0.0 && bal>=cap*0.5 && bal<=cap*2.0)
      return true;
   if(!g_capDoubtAlerted)
     {
      g_capDoubtAlerted=true;
      string m="auto capital "+DoubleToString(cap,2)+" ("+src+") does not fit balance "+DoubleToString(bal,2)
               +" - limits are NOT checked. Set InpInitialCapital.";
      Log("CAPITAL_DOUBTFUL",m);
      Notify(m);
     }
   return false;
  }

bool ResolveCapital()
  {
   if(g_capital>0.0)
      return true;
   if(InpInitialCapital>0.0)
     {
      g_capital=InpInitialCapital;
      g_capAuto=false;
      return true;
     }
   g_capAuto=true;
   // a value found earlier on this account survives a restart even before history loads
   if(GlobalVariableCheck(g_pfx+"CAP") && GlobalVariableGet(g_pfx+"CAP")>0.0)
     {
      double v=GlobalVariableGet(g_pfx+"CAP");
      if(CapitalPlausible(v,"saved"))
        {
         g_capital=v;
         Log("CAPITAL_AUTO","restored "+DoubleToString(g_capital,2));
         return true;
        }
      return false;
     }
   if(!HistorySelect(0,TimeTradeServer()+86400))
      return false;
   int      n=HistoryDealsTotal();
   datetime best_t=0;
   long     best_id=0;
   double   best_v=0.0;
   for(int i=0;i<n;i++)
     {
      ulong t=HistoryDealGetTicket(i);
      if(t==0)
         return false;
      if(HistoryDealGetInteger(t,DEAL_TYPE)!=DEAL_TYPE_BALANCE)
         continue;
      double v=HistoryDealGetDouble(t,DEAL_PROFIT);
      if(v<=0.0)
         continue;                                // withdrawals / negative corrections are not the start
      datetime dt=(datetime)HistoryDealGetInteger(t,DEAL_TIME);
      if(best_v<=0.0 || dt<best_t || (dt==best_t && (long)t<best_id))
        {
         best_t=dt;
         best_id=(long)t;
         best_v=v;
        }
     }
   if(best_v<=0.0)
      return false;
   if(!CapitalPlausible(best_v,"first deposit"))
      return false;
   g_capital=best_v;
   GvSetFlush(GvCapital(),g_capital);
   Log("CAPITAL_AUTO","first deposit "+DoubleToString(g_capital,2)+" at "+TimeToString(best_t,TIME_DATE|TIME_MINUTES)
       +" - set InpInitialCapital yourself if this is not your account size");
   return true;
  }

//+------------------------------------------------------------------+
//| STRATEGY TESTER ONLY: demo trades so the guard has work to do.   |
//| Every 4 hours: close the previous demo trade, open the opposite. |
//| Size: about 10% of capital lost on a 1% price move, limited to   |
//| 30% of free margin. Never runs outside the tester.               |
//+------------------------------------------------------------------+
void TesterDemo()
  {
   if(!MQLInfoInteger(MQL_TESTER) || !InpTesterDemo || !g_inited)
      return;
   if(g_haltTotal || g_haltDay || g_capital<=0.0)
      return;                                     // the guard is busy closing - do not feed it
   datetime now=TimeCurrent();
   if(g_demoLast!=0 && now-g_demoLast<4*3600)
      return;
   g_demoLast=now;
   long magic=(InpScope==PG_SCOPE_MAGIC ? InpMagic : PG_DEMO_MAGIC);

   //--- close the previous demo trade on this symbol
   bool close_failed=false;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong tk=PositionGetTicket(i);
      if(tk==0)
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=magic)
         continue;
      if(!g_trade.PositionClose(tk,(ulong)InpDeviationPoints) || g_trade.ResultRetcode()!=TRADE_RETCODE_DONE)
        {
         close_failed=true;
         Log("DEMO_CLOSE_FAIL","#"+IntegerToString((long)tk)+" rc="+IntegerToString(g_trade.ResultRetcode()));
        }
     }
   if(close_failed)
     { g_cntDemoSkip++; return; }                 // never stack or net against an open demo trade

   if(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL)
     { g_cntDemoSkip++; return; }
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(ask<=0.0 || bid<=0.0)
     { g_cntDemoSkip++; return; }
   ENUM_ORDER_TYPE type=(g_demoBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   double price=(g_demoBuy ? ask : bid);

   //--- lot: 1% price move ~ 10% of capital
   double p1=0.0;
   if(!OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,1.0,price,price*1.01,p1) || p1<=0.0)
     { g_cntDemoSkip++; return; }
   double raw=0.10*g_capital/p1;
   double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double m1=0.0;
   if(!OrderCalcMargin(type,_Symbol,1.0,price,m1) || free<=0.0)
     { g_cntDemoSkip++; return; }
   if(m1>0.0)
      raw=MathMin(raw,0.30*free/m1);
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double vlim=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
   if(vlim>0.0 && vlim<vmax)
      vmax=vlim;
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double lot=PG_NormLot(raw,vmin,vmax,step);
   if(lot<=0.0)
      lot=PG_NormLot(vmin,vmin,vmax,step);        // small account: try the minimum lot
   if(lot<=0.0)
     { g_cntDemoSkip++; return; }
   double need=0.0;
   if(!OrderCalcMargin(type,_Symbol,lot,price,need) || need>0.30*free)
     { g_cntDemoSkip++; return; }

   if(!g_trade.SetTypeFillingBySymbol(_Symbol))
      Log("FILLING_WARN",_Symbol+": could not read filling mode, using default");
   g_trade.SetExpertMagicNumber(magic);
   bool ok=(g_demoBuy ? g_trade.Buy(lot,_Symbol,0.0,0.0,0.0,"PropGuard tester demo")
                      : g_trade.Sell(lot,_Symbol,0.0,0.0,0.0,"PropGuard tester demo"));
   if(ok && g_trade.ResultRetcode()==TRADE_RETCODE_DONE)
     {
      g_cntDemoOpen++;
      g_demoBuy=!g_demoBuy;
     }
   else
     {
      g_cntDemoSkip++;
      Log("DEMO_OPEN_FAIL","rc="+IntegerToString(g_trade.ResultRetcode())+" "+g_trade.ResultRetcodeDescription());
     }
  }

//+------------------------------------------------------------------+
//| Main check                                                       |
//+------------------------------------------------------------------+
void Check(const bool from_tick)
  {
   if(!MQLInfoInteger(MQL_TESTER))
     {
      GlobalVariableSet(GvLock(),(double)ChartID());   // heartbeat for the one-instance lock
      GlobalVariableSet(GvLockBeat(),(double)(long)TimeLocal());
     }

   UpdateDay();
   RecalcRef();

   bool cap_try = (g_capital<=0.0);
   if(cap_try && g_capFailStreak>5 && !MQLInfoInteger(MQL_TESTER))
     {
      uint now_ms=GetTickCount();
      if(now_ms-g_capLastTryMs<60000)
         cap_try=false;                             // unknown capital: full history scan at most once a minute
      else
         g_capLastTryMs=now_ms;
     }
   if(cap_try)
     {
      if(ResolveCapital())
        {
         g_capFailStreak=0;
         g_capAlerted=false;
        }
      else
        {
         g_capFailStreak++;
         if(g_capFailStreak>=10 && !g_capAlerted)
           {
            g_capAlerted=true;
            Notify("initial capital UNKNOWN - limits are NOT checked. Set InpInitialCapital.");
            Log("CAPITAL_UNKNOWN","capital still unknown after 10 tries");
           }
        }
     }

   double eq     = AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_CREDIT);
   double buffer = (g_capital>0.0 ? g_capital*InpBufferPct/100.0 : 0.0);

   if(InpUseMaxLoss && !g_haltTotal && g_capital>0.0)
     {
      double tf=PG_TotalFloor(g_capital,InpMaxLossPct);
      if(PG_Breached(eq,tf,buffer))
        {
         g_haltTotal=true;
         GvSetFlush(GvHaltTotal(),1.0);
         string m="MAX LOSS reached: equity "+DoubleToString(eq,2)+" <= "+DoubleToString(tf,2)+" + buffer "+DoubleToString(buffer,2)
                  +". Closing all and blocking until reset.";
         Log("HALT_TOTAL",m);
         Notify(m);
        }
     }

   if(InpUseDaily && !g_haltDay && g_dayRef>0.0 && g_capital>0.0)
     {
      double df=PG_DailyFloor(g_dayRef,g_capital,InpDailyLossPct,InpDailyBase);
      if(PG_Breached(eq,df,buffer))
        {
         g_haltDay=true;
         datetime until = g_dayStart+86400;
         GvSetFlush(GvHaltDayUntil(),(double)(long)until);
         string m="DAILY LOSS reached: equity "+DoubleToString(eq,2)+" <= "+DoubleToString(df,2)+" + buffer "+DoubleToString(buffer,2)
                  +". Closing all until "+TimeToString(until,TIME_DATE|TIME_MINUTES)+" (server time).";
         Log("HALT_DAY",m);
         Notify(m);
        }
     }

   if(g_haltTotal || g_haltDay)
      EnforceFlat();
   else if(from_tick)
      TesterDemo();                                 // ticks only (market open); returns at once outside the Strategy Tester

   if(InpShowPanel)
      ShowPanel(eq,buffer);
  }

//+------------------------------------------------------------------+
void ShowPanel(const double eq,const double buffer)
  {
   string s="PropGuard Lite\n";
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
      s+="Algo Trading is OFF in this terminal - this copy cannot close positions\n(normal if the guard runs on an MQL5 VPS instead: keep only ONE copy active)\n";
   if(InpScope==PG_SCOPE_MAGIC)
      s+="Scope: only magic "+IntegerToString(InpMagic)+" is closed - other trades are NOT touched\n";
   if(MQLInfoInteger(MQL_TESTER) && InpTesterDemo)
      s+="TESTER DEMO: opened "+IntegerToString(g_cntDemoOpen)+" demo trades (tester only)\n";
   if(g_capital>0.0)
      s+="Capital: "+DoubleToString(g_capital,2)+(g_capAuto?" (auto: first deposit)":"")+"\n";
   else
      s+="CAPITAL UNKNOWN - no deposit found yet - limits NOT checked (set InpInitialCapital)\n";
   s+="Status: "+(g_haltTotal?"HALTED (max loss)":(g_haltDay?"HALTED (daily, until next day)":"watching"))+"\n";
   s+="Equity (excl. credit): "+DoubleToString(eq,2)+"\n";
   if(InpUseDaily && g_capital>0.0)
     {
      if(g_dayRef>0.0)
        {
         double df=PG_DailyFloor(g_dayRef,g_capital,InpDailyLossPct,InpDailyBase);
         s+="Day ref: "+DoubleToString(g_dayRef,2)+(g_refEstimated?" (ESTIMATED)":"")+"\n";
         s+="Daily floor: "+DoubleToString(df,2)+"  acts at "+DoubleToString(df+buffer,2)
           +"  room "+DoubleToString(eq-(df+buffer),2)+"\n";
        }
      else
         s+="Daily: REF UNKNOWN (history not readable) - daily limit not checked\n";
     }
   if(InpUseMaxLoss && g_capital>0.0)
     {
      double tf=PG_TotalFloor(g_capital,InpMaxLossPct);
      s+="Max-loss floor: "+DoubleToString(tf,2)+"  acts at "+DoubleToString(tf+buffer,2)
        +"  room "+DoubleToString(eq-(tf+buffer),2)+"\n";
     }
   s+="Day starts (server): "+TimeToString(g_dayStart,TIME_DATE|TIME_MINUTES)+"\n";
   s+="Closed "+IntegerToString(g_cntClosed)+" / fail "+IntegerToString(g_cntCloseFail)
     +"  Deleted "+IntegerToString(g_cntDeleted)+" / fail "+IntegerToString(g_cntDeleteFail)
     +"  History fail "+IntegerToString(g_cntRefFail);
   Comment(s);
  }

//+------------------------------------------------------------------+
//| Input validation: refuse to start rather than guess              |
//+------------------------------------------------------------------+
bool ValidateInputs(string &why)
  {
   if(InpInitialCapital<0.0)
     { why="InpInitialCapital cannot be negative (0 = auto: first deposit)"; return false; }
   if(!InpUseDaily && !InpUseMaxLoss)
     { why="both limits are disabled - nothing to guard"; return false; }
   if(InpUseDaily && (InpDailyLossPct<=0.0 || InpDailyLossPct>=100.0))
     { why="InpDailyLossPct must be between 0 and 100"; return false; }
   if(InpUseMaxLoss && (InpMaxLossPct<=0.0 || InpMaxLossPct>=100.0))
     { why="InpMaxLossPct must be between 0 and 100"; return false; }
   if(InpResetHour<0 || InpResetHour>23)
     { why="InpResetHour must be 0-23"; return false; }
   if(InpServerMinusResetTZ<-12 || InpServerMinusResetTZ>14)
     { why="InpServerMinusResetTZ must be between -12 and 14"; return false; }
   if(InpBufferPct<0.0)
     { why="InpBufferPct cannot be negative"; return false; }
   if(InpUseDaily && InpBufferPct>=InpDailyLossPct)
     { why="InpBufferPct must be smaller than InpDailyLossPct"; return false; }
   if(InpUseMaxLoss && InpBufferPct>=InpMaxLossPct)
     { why="InpBufferPct must be smaller than InpMaxLossPct"; return false; }
   if(InpDeviationPoints<0)
     { why="InpDeviationPoints cannot be negative"; return false; }
   if(InpScope==PG_SCOPE_MAGIC && InpMagic<0)
     { why="InpMagic cannot be negative"; return false; }
   return true;
  }

//+------------------------------------------------------------------+
//| Self-test: known answers, including cases that must NOT trigger  |
//+------------------------------------------------------------------+
int g_stPass=0, g_stFail=0, g_stH=INVALID_HANDLE;

void ST(const string name,const bool cond)
  {
   if(cond) g_stPass++; else g_stFail++;
   string r=(cond?"PASS":"FAIL")+"  "+name;
   if(g_stH!=INVALID_HANDLE) FileWrite(g_stH,r);
   if(!cond) Print("PropGuard self-test ",r);
  }
bool Near(const double a,const double b) { return MathAbs(a-b)<1e-6; }

bool RunSelfTest()
  {
   g_stPass=0; g_stFail=0;
   g_stH=FileOpen("PropGuard_selftest.txt",FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(g_stH==INVALID_HANDLE)
      Print("PropGuard: cannot write self-test file, error ",GetLastError());

   // day start
   ST("day start: midnight reset, same zone",          PG_DayStart(D'2026.10.22 00:30',0,0)==D'2026.10.22 00:00');
   ST("day start: exactly at reset",                   PG_DayStart(D'2026.10.22 00:00',0,0)==D'2026.10.22 00:00');
   ST("day start: 1 second before reset",              PG_DayStart(D'2026.10.21 23:59:59',0,0)==D'2026.10.21 00:00');
   ST("day start: server +2h ahead of firm zone",      PG_DayStart(D'2026.10.22 01:30',2,0)==D'2026.10.21 02:00');
   ST("day start: server -3h behind firm zone",        PG_DayStart(D'2026.10.22 22:00',-3,0)==D'2026.10.22 21:00');
   ST("day start: 17:00 reset, 16:59 = previous day",  PG_DayStart(D'2026.10.22 16:59',0,17)==D'2026.10.21 17:00');
   ST("day start: 17:00 reset, 17:00 = new day",       PG_DayStart(D'2026.10.22 17:00',0,17)==D'2026.10.22 17:00');

   // daily floor
   ST("daily floor: capital base, flat day",           Near(PG_DailyFloor(100000,100000,5,PG_BASE_CAPITAL),95000));
   ST("daily floor: capital base, after profit",       Near(PG_DailyFloor(102000,100000,5,PG_BASE_CAPITAL),97000));
   ST("daily floor: day-ref base",                     Near(PG_DailyFloor(102000,100000,5,PG_BASE_DAYREF),96900));
   ST("daily floor: invalid ref -> -1",                Near(PG_DailyFloor(0,100000,5,PG_BASE_CAPITAL),-1));
   ST("daily floor: invalid pct 0 -> -1",              Near(PG_DailyFloor(100000,100000,0,PG_BASE_CAPITAL),-1));
   ST("daily floor: invalid pct 100 -> -1",            Near(PG_DailyFloor(100000,100000,100,PG_BASE_CAPITAL),-1));

   // total floor
   ST("total floor: 10%",                              Near(PG_TotalFloor(100000,10),90000));
   ST("total floor: invalid capital -> -1",            Near(PG_TotalFloor(0,10),-1));

   // breach
   ST("breach: inside buffer triggers",                PG_Breached(95400,95000,500)==true);
   ST("breach: exactly at floor+buffer triggers",      PG_Breached(95500,95000,500)==true);
   ST("breach: above floor+buffer must NOT trigger",   PG_Breached(95500.01,95000,500)==false);
   ST("breach: invalid floor must NOT trigger",        PG_Breached(1,-1,0)==false);

   // reference choice
   bool est=false;
   ST("ref: balance mode, no snapshots",               Near(PG_ChooseRef(100000,-1,-1,0,PG_REF_BALANCE,est),100000) && !est);
   ST("ref: balance mode ignores equity snapshot",     Near(PG_ChooseRef(100000,100000,100500,0,PG_REF_BALANCE,est),100000) && !est);
   ST("ref: history lag -> snapshot wins (safer)",     Near(PG_ChooseRef(97000,100000,-1,0,PG_REF_BALANCE,est),100000) && !est);
   ST("ref: higher mode uses higher equity",           Near(PG_ChooseRef(100000,100000,100500,0,PG_REF_HIGHER,est),100500) && !est);
   ST("ref: higher mode uses higher balance",          Near(PG_ChooseRef(100000,100000,99000,0,PG_REF_HIGHER,est),100000) && !est);
   ST("ref: higher mode w/o snapshot = estimated",     Near(PG_ChooseRef(100000,-1,-1,0,PG_REF_HIGHER,est),100000) && est);
   // withdrawal of 6000 today: bal_ref already lower; snapshots must be lowered too (no false halt)
   ST("ref: withdrawal lowers equity snapshot",        Near(PG_ChooseRef(94000,100000,100500,-6000,PG_REF_HIGHER,est),94500) && !est);
   ST("ref: deposit raises equity snapshot",           Near(PG_ChooseRef(105000,100000,100500,5000,PG_REF_HIGHER,est),105500) && !est);

   // deal types
   ST("cash type: balance excluded from P/L",          PG_IsCashType(DEAL_TYPE_BALANCE));
   ST("cash type: credit excluded from P/L",           PG_IsCashType(DEAL_TYPE_CREDIT));
   ST("cash type: buy deal is P/L",                    !PG_IsCashType(DEAL_TYPE_BUY));
   ST("cash type: commission is P/L",                  !PG_IsCashType(DEAL_TYPE_COMMISSION));

   // backoff retcodes
   ST("backoff: market closed",                        PG_IsBackoffRetcode(TRADE_RETCODE_MARKET_CLOSED));
   ST("backoff: requote must NOT back off",            !PG_IsBackoffRetcode(TRADE_RETCODE_REQUOTE));

   // hash: stable and different for different servers
   ST("hash: stable",                                  PG_Hash("FTMO-Demo")==PG_Hash("FTMO-Demo"));
   ST("hash: differs by server",                       PG_Hash("FTMO-Demo")!=PG_Hash("FTMO-Server"));

   // lot normalisation (tester demo only)
   ST("lot: round down to step",                       Near(PG_NormLot(0.237,0.01,100,0.01),0.23));
   ST("lot: step 0.1",                                 Near(PG_NormLot(1.27,0.1,50,0.1),1.2));
   ST("lot: capped at max",                            Near(PG_NormLot(500,0.01,100,0.01),100));
   ST("lot: below minimum -> -1 (skip)",               Near(PG_NormLot(0.004,0.01,100,0.01),-1));
   ST("lot: zero -> -1",                               Near(PG_NormLot(0,0.01,100,0.01),-1));
   ST("lot: step 0.25 keeps 2 decimals",               Near(PG_NormLot(0.8,0.25,100,0.25),0.75));
   ST("lot: exact step boundary kept",                 Near(PG_NormLot(0.3,0.01,100,0.01),0.3));

   string sum="TOTAL: "+IntegerToString(g_stPass)+" PASS, "+IntegerToString(g_stFail)+" FAIL";
   if(g_stH!=INVALID_HANDLE)
     {
      FileWrite(g_stH,sum);
      FileClose(g_stH);
      g_stH=INVALID_HANDLE;
     }
   Print("PropGuard self-test ",sum);
   return (g_stFail==0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_inited=false;  g_demoLast=0;  g_demoBuy=true;
   g_capAlerted=false;  g_capDoubtAlerted=false;  g_capFailStreak=0;  g_capLastTryMs=0;
   string why="";
   if(!ValidateInputs(why))
     {
      Print("PropGuard: not started - ",why);
      Alert("PropGuard: not started - ",why);
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpRunSelfTest && !RunSelfTest())
     {
      Alert("PropGuard: self-test FAILED - see PropGuard_selftest.txt");
      return INIT_FAILED;
     }

   g_pfx = "PG_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+PG_Hash(AccountInfoString(ACCOUNT_SERVER))+"_";

   if(MQLInfoInteger(MQL_TESTER))
      GlobalVariablesDeleteAll(g_pfx);              // every test pass starts clean
   else
     {
      // one instance per account: refuse only if another chart sent a heartbeat in the last 10 s
      // (uses a stored time value; GlobalVariableTime is not used because Check/Get update it)
      if(GlobalVariableCheck(GvLock()) && GlobalVariableCheck(GvLockBeat()))
        {
         long     owner = (long)GlobalVariableGet(GvLock());
         datetime beat  = (datetime)(long)GlobalVariableGet(GvLockBeat());
         if(owner!=ChartID() && TimeLocal()-beat<10)
           {
            Alert("PropGuard: already running on another chart for this account - not started");
            return INIT_FAILED;
           }
        }
      GlobalVariableSet(GvLock(),(double)ChartID());
      GlobalVariableSet(GvLockBeat(),(double)(long)TimeLocal());
     }

   if(InpClearMaxLossHalt)
     {
      if(GlobalVariableCheck(GvHaltTotal()))
        {
         GlobalVariableDel(GvHaltTotal());
         GlobalVariablesFlush();
         Log("HALT_TOTAL_CLEARED","cleared by user input");
        }
      Alert("PropGuard: max-loss halt cleared. Set InpClearMaxLossHalt back to false and attach again.");
      return INIT_PARAMETERS_INCORRECT;            // force the user to switch it off
     }
   g_haltTotal = GlobalVariableCheck(GvHaltTotal());
   if(g_haltTotal)
     {
      GvSetFlush(GvHaltTotal(),1.0);               // touch it so it never expires
      Log("HALT_TOTAL_ACTIVE","max-loss halt is still active");
     }

   g_trade.SetDeviationInPoints((ulong)InpDeviationPoints);
   g_trade.SetAsyncMode(false);

   g_capital=-1.0;
   if(ResolveCapital() && !g_capAuto)
     {
      double bal=AccountInfoDouble(ACCOUNT_BALANCE);
      if(bal>0.0 && (bal<g_capital*0.5 || bal>g_capital*2.0))
         Log("CAPITAL_WARN","balance "+DoubleToString(bal,2)+" is far from InpInitialCapital "+DoubleToString(g_capital,2)+" - check the input");
     }
   if(AccountInfoDouble(ACCOUNT_CREDIT)>0.0)
      Log("CREDIT_INFO","account has credit "+DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT),2)+" - it is excluded from equity for the limits");

   if(!EventSetTimer(1))
     {
      Print("PropGuard: cannot start timer, error ",GetLastError());
      return INIT_FAILED;
     }
   Log("START","capital "+(g_capital>0.0?DoubleToString(g_capital,2):"unknown")+(g_capAuto?" (auto)":"")
       +" daily "+(InpUseDaily?DoubleToString(InpDailyLossPct,2)+"%":"off")
       +" max "+(InpUseMaxLoss?DoubleToString(InpMaxLossPct,2)+"%":"off")
       +" buffer "+DoubleToString(InpBufferPct,2)+"%");
   Check(false);
   g_inited=true;
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(!MQLInfoInteger(MQL_TESTER) && GlobalVariableCheck(GvLock()) && (long)GlobalVariableGet(GvLock())==ChartID())
     {
      GlobalVariableDel(GvLock());
      GlobalVariableDel(GvLockBeat());
     }
   GlobalVariablesFlush();
   Comment("");
  }

void OnTimer() { Check(false); }
void OnTick()  { Check(true); }
//+------------------------------------------------------------------+

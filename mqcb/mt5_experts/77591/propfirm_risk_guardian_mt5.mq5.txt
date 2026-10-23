//+------------------------------------------------------------------+
//| PropFirm_Risk_Guardian_MT5.mq5                                   |
//| Account-wide prop-firm risk protection for MetaTrader 5          |
//+------------------------------------------------------------------+
#property copyright "Rahul Sharma"
#property version   "3.00"
#property strict
#property description "Account-wide prop-firm risk guardian with daily/overall drawdown and single-position loss protection."

#include <Trade/Trade.mqh>

//--- Account-level protection
input double InpDailyLossPct           = 5.0;       // Daily loss limit, %
input double InpMaxLossPct             = 10.0;      // Maximum overall loss, %
input double InpBufferPct              = 1.0;       // Account safety buffer, percentage points
input int    InpDayStartHour           = 0;         // Trading-day rollover hour (broker server time)
input bool   InpUseEquityForDay        = true;      // Day-start = max(balance,equity) if true
input bool   InpCloseOnBreach          = true;      // Close all positions/delete pending orders on account breach

//--- Single-position protection
input double InpSingleTradeLossPct     = 1.0;       // Max floating loss per position, % of reference balance; 0=disabled
input double InpSingleTradeLossMoney   = 0.0;       // Optional fixed currency cap per position; 0=disabled
input bool   InpHaltOnSingleTradeLoss  = true;      // Halt account when one position hits its loss limit
input bool   InpCloseOnSingleTradeLoss = true;      // Close the offending position

//--- Coordination with other EAs
input string InpHaltFlagName           = "DDGUARD_HALT"; // Terminal global variable: 1=halt, 0=run

//--- State
CTrade   trade;
double   g_referenceBalance = 0.0;
double   g_dayStartLevel    = 0.0;
datetime g_currentDay      = 0;
bool     g_dailyBreached   = false;
bool     g_maxBreached     = false;

//--- Forward declarations
string   StatePrefix();
string   GV(const string suffix);
datetime TradingDayAnchor();
void     SaveState();
bool     LoadState();
void     SnapshotDayStart();
void     SetHalt(const bool halted);
void     MonitorRisk();
void     CheckSingleTradeLoss();
void     TriggerAccountBreach(const string reason);
void     TriggerSingleTradeBreach(const ulong ticket,const string symbol,const double loss);
void     CloseAllPositions();
void     DeleteAllPendingOrders();

//+------------------------------------------------------------------+
string StatePrefix()
  {
   return("PFRG_STATE_" + (string)AccountInfoInteger(ACCOUNT_LOGIN) + "_");
  }

//+------------------------------------------------------------------+
string GV(const string suffix)
  {
   return(StatePrefix()+suffix);
  }

//+------------------------------------------------------------------+
datetime TradingDayAnchor()
  {
   datetime now=TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now,dt);
   dt.hour=InpDayStartHour;
   dt.min=0;
   dt.sec=0;
   datetime anchor=StructToTime(dt);
   if(anchor>now)
      anchor-=86400;
   return(anchor);
  }

//+------------------------------------------------------------------+
void SaveState()
  {
   GlobalVariableSet(GV("DAY_ANCHOR"),       (double)g_currentDay);
   GlobalVariableSet(GV("REFERENCE_BALANCE"),g_referenceBalance);
   GlobalVariableSet(GV("DAY_START"),        g_dayStartLevel);
   GlobalVariableSet(GV("DAILY_BREACHED"),   g_dailyBreached ? 1.0 : 0.0);
   GlobalVariableSet(GV("MAX_BREACHED"),     g_maxBreached ? 1.0 : 0.0);
  }

//+------------------------------------------------------------------+
bool LoadState()
  {
   if(!GlobalVariableCheck(GV("DAY_ANCHOR")) ||
      !GlobalVariableCheck(GV("DAY_START"))  ||
      !GlobalVariableCheck(GV("DAILY_BREACHED")) ||
      !GlobalVariableCheck(GV("MAX_BREACHED")))
      return(false);

   g_currentDay    =(datetime)GlobalVariableGet(GV("DAY_ANCHOR"));
   g_dayStartLevel =GlobalVariableGet(GV("DAY_START"));
   g_dailyBreached =(GlobalVariableGet(GV("DAILY_BREACHED"))>0.5);
   g_maxBreached   =(GlobalVariableGet(GV("MAX_BREACHED"))>0.5);

   if(GlobalVariableCheck(GV("REFERENCE_BALANCE")))
      g_referenceBalance=GlobalVariableGet(GV("REFERENCE_BALANCE"));
   else
     {
      g_referenceBalance=AccountInfoDouble(ACCOUNT_BALANCE);
      if(g_referenceBalance>0.0)
         GlobalVariableSet(GV("REFERENCE_BALANCE"),g_referenceBalance);
     }

   return(g_referenceBalance>0.0 && g_dayStartLevel>0.0);
  }

//+------------------------------------------------------------------+
void SnapshotDayStart()
  {
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double equity =AccountInfoDouble(ACCOUNT_EQUITY);

   g_dayStartLevel=InpUseEquityForDay ? MathMax(balance,equity) : balance;
   g_dailyBreached=false;
   SaveState();

   PrintFormat("[PropFirm Risk Guardian] New trading day. Day-start level: %.2f",g_dayStartLevel);
  }

//+------------------------------------------------------------------+
void SetHalt(const bool halted)
  {
   if(InpHaltFlagName=="")
      return;
   GlobalVariableSet(InpHaltFlagName,halted ? 1.0 : 0.0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Validate settings
   if(InpDailyLossPct<=0.0 || InpMaxLossPct<=0.0)
      return(INIT_PARAMETERS_INCORRECT);

   if(InpBufferPct<0.0 || InpBufferPct>=InpDailyLossPct || InpBufferPct>=InpMaxLossPct)
      return(INIT_PARAMETERS_INCORRECT);

   if(InpDayStartHour<0 || InpDayStartHour>23)
      return(INIT_PARAMETERS_INCORRECT);

   if(InpSingleTradeLossPct<0.0 || InpSingleTradeLossMoney<0.0)
      return(INIT_PARAMETERS_INCORRECT);

   if(InpSingleTradeLossPct==0.0 && InpSingleTradeLossMoney==0.0)
      Print("[PropFirm Risk Guardian] Single-position protection is disabled.");

   g_currentDay=TradingDayAnchor();

   //--- Reference balance is captured once and persisted.
   //--- MT5 cannot infer a prop firm's original nominal account size if the broker
   //--- does not expose it; this is therefore the balance at first initialization.
   bool loaded=LoadState();
   if(!loaded)
     {
      g_referenceBalance=AccountInfoDouble(ACCOUNT_BALANCE);
      if(g_referenceBalance<=0.0)
         return(INIT_FAILED);

      g_currentDay=TradingDayAnchor();
      SnapshotDayStart();
     }

   //--- If a previous state belongs to an older trading day, create today's snapshot.
   if(g_currentDay!=TradingDayAnchor() || g_dayStartLevel<=0.0)
     {
      g_currentDay=TradingDayAnchor();
      if(!g_maxBreached)
         SnapshotDayStart();
      else
         SaveState();
     }

   //--- Preserve a breached state across restarts.
   if(g_maxBreached || g_dailyBreached)
      SetHalt(true);
   else
      SetHalt(false);

   //--- Timer provides protection even when the chart receives no new tick.
   EventSetTimer(1);

   PrintFormat("[PropFirm Risk Guardian] Active | Reference %.2f | Daily %.2f%% | Overall %.2f%% | Buffer %.2f%% | Single %.2f%% / %.2f",
               g_referenceBalance,InpDailyLossPct,InpMaxLossPct,InpBufferPct,
               InpSingleTradeLossPct,InpSingleTradeLossMoney);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   SaveState();
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   MonitorRisk();
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   MonitorRisk();
  }

//+------------------------------------------------------------------+
void MonitorRisk()
  {
   datetime anchor=TradingDayAnchor();

   //--- New trading day: reset only the daily protection.
   if(anchor!=g_currentDay)
     {
      g_currentDay=anchor;

      if(!g_maxBreached)
        {
         SnapshotDayStart();
         SetHalt(false);
        }
      else
         SaveState();
     }

   //--- Overall breach remains permanent until the persistent state is reset.
   if(g_maxBreached)
      return;

   double equity=AccountInfoDouble(ACCOUNT_EQUITY);

   //--- Overall drawdown: safety buffer is applied here.
   double effectiveMaxLoss=MathMax(0.0,InpMaxLossPct-InpBufferPct);
   double maxStopLevel=g_referenceBalance*(1.0-effectiveMaxLoss/100.0);

   if(equity<=maxStopLevel)
     {
      g_maxBreached=true;
      SaveState();
      TriggerAccountBreach(StringFormat("OVERALL drawdown protection hit. Equity %.2f <= %.2f",equity,maxStopLevel));
      return;
     }

   //--- Daily drawdown: safety buffer is applied here.
   if(!g_dailyBreached)
     {
      double effectiveDailyLoss=MathMax(0.0,InpDailyLossPct-InpBufferPct);
      double dailyStopLevel=g_dayStartLevel*(1.0-effectiveDailyLoss/100.0);

      if(equity<=dailyStopLevel)
        {
         g_dailyBreached=true;
         SaveState();
         TriggerAccountBreach(StringFormat("DAILY drawdown protection hit. Equity %.2f <= %.2f",equity,dailyStopLevel));
         return;
        }
     }

   //--- Individual-position protection.
   CheckSingleTradeLoss();
  }

//+------------------------------------------------------------------+
void CheckSingleTradeLoss()
  {
   if(InpSingleTradeLossPct<=0.0 && InpSingleTradeLossMoney<=0.0)
      return;

   double pctLimit=0.0;
   if(InpSingleTradeLossPct>0.0)
      pctLimit=g_referenceBalance*InpSingleTradeLossPct/100.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;

      double profit=PositionGetDouble(POSITION_PROFIT);
      double swap  =PositionGetDouble(POSITION_SWAP);
      double loss  =-(profit+swap);
      if(loss<=0.0)
         continue;

      bool pctHit  =(pctLimit>0.0 && loss>=pctLimit);
      bool moneyHit=(InpSingleTradeLossMoney>0.0 && loss>=InpSingleTradeLossMoney);
      if(!pctHit && !moneyHit)
         continue;

      string symbol=PositionGetString(POSITION_SYMBOL);
      TriggerSingleTradeBreach(ticket,symbol,loss);

      //--- Avoid acting on the same position again in this pass.
      if(InpHaltOnSingleTradeLoss)
         return;
     }
  }

//+------------------------------------------------------------------+
void TriggerSingleTradeBreach(const ulong ticket,const string symbol,const double loss)
  {
   PrintFormat("[PropFirm Risk Guardian] SINGLE-POSITION LOSS LIMIT hit. Ticket #%I64u %s loss %.2f",
               ticket,symbol,loss);

   if(InpCloseOnSingleTradeLoss)
     {
      if(!trade.PositionClose(ticket))
         PrintFormat("[PropFirm Risk Guardian] Failed to close position #%I64u (retcode %u)",
                     ticket,trade.ResultRetcode());
     }

   if(InpHaltOnSingleTradeLoss)
     {
      // A single-trade breach halts trading for the current trading day.
      // It does NOT consume the separate daily-loss buffer calculation.
      g_dailyBreached=true;
      SaveState();
      SetHalt(true);

      // Prevent queued/pending entries while the account is halted.
      DeleteAllPendingOrders();
     }
  }

//+------------------------------------------------------------------+
void TriggerAccountBreach(const string reason)
  {
   Print("[PropFirm Risk Guardian] *** TRADING HALTED *** ",reason);
   SetHalt(true);

   if(!InpCloseOnBreach)
      return;

   CloseAllPositions();
   DeleteAllPendingOrders();
  }

//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;

      if(!trade.PositionClose(ticket))
         PrintFormat("[PropFirm Risk Guardian] Failed to close position #%I64u (retcode %u)",
                     ticket,trade.ResultRetcode());
     }
  }

//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      ulong ticket=OrderGetTicket(i);
      if(ticket==0)
         continue;

      if(!trade.OrderDelete(ticket))
         PrintFormat("[PropFirm Risk Guardian] Failed to delete order #%I64u (retcode %u)",
                     ticket,trade.ResultRetcode());
     }
  }
//+------------------------------------------------------------------+

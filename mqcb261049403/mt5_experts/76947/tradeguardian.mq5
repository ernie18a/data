//+------------------------------------------------------------------+
//|                                              TradeGuardian.mq5   |
//|                                          Copyright 2026, Petr K. |
//|                        https://www.mql5.com/en/users/petrkostal  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Petr Kostal"
#property link      "https://www.mql5.com/en/users/petrkostal"
#property version   "1.00"
#property description "A safety net that runs beside your other EAs or manual trades."
#property description "1) Gives a hard stop loss to any position on this chart's symbol that has none."
#property description "2) Warns - or closes - when the daily or the total drawdown limit is hit."
#property description ""
#property description "The drawdown limits are measured from the equity peak and re-arm after"
#property description "a cooldown, so one bad stretch cannot switch the account off forever."
#property description "Closing is OFF by default: out of the box it only warns."

#include <Trade\Trade.mqh>
CTrade trade;

//--- inputs
input group "=== Scope ==="
input bool   InpCurrentSymbolOnly  = false;  // Guard this chart's symbol only
input long   InpMagicFilter        = -1;     // Magic number to guard (-1 = all)

input group "=== Missing stop loss ==="
input bool   InpEnforceStopLoss    = true;   // Attach a stop loss where there is none (chart symbol only)
input int    InpATR_Period         = 14;     // ATR period for the fallback stop
input double InpATR_Mult           = 3.0;    // Fallback stop = ATR * multiplier
input int    InpMinStopPoints      = 100;    // Never place the stop closer than N points

input group "=== Daily loss limit ==="
input double InpMaxDailyLossPct    = 0.0;    // Daily loss limit in % of the day's opening balance (0 = off)

input group "=== Total drawdown limit ==="
input double InpMaxTotalDDPct      = 0.0;    // Drawdown limit in % from the equity peak (0 = off)
input int    InpCooldownHours      = 168;    // Rebase the peak and re-arm after N hours (0 = never)

input group "=== What to do when a limit is hit ==="
input bool   InpCloseOnBreach      = false;  // Close the guarded positions (off = only warn)
input bool   InpAlertOnBreach      = true;   // Raise a terminal alert
input bool   InpPanel              = true;   // Show the status panel

//--- state
int      g_atrHandle    = INVALID_HANDLE;
double   g_equityPeak   = 0.0;
double   g_dayStartBal  = 0.0;
datetime g_dayStamp     = 0;
bool     g_dailyHit     = false;
bool     g_totalHit     = false;
datetime g_totalHitTime = 0;
string   g_lastMsg      = "";

//+------------------------------------------------------------------+
int OnInit()
{
   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, InpATR_Period);
   if(g_atrHandle == INVALID_HANDLE)
   {
      Print("TradeGuardian: cannot create the ATR handle");
      return INIT_FAILED;
   }

   trade.SetDeviationInPoints(30);
   g_equityPeak  = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayStartBal = AccountInfoDouble(ACCOUNT_BALANCE);
   g_dayStamp    = 0;

   EventSetTimer(1);
   Print("TradeGuardian started.");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()  { Guard(); }
void OnTimer() { Guard(); }

//+------------------------------------------------------------------+
bool InScope()
{
   string sym = PositionGetString(POSITION_SYMBOL);
   if(InpCurrentSymbolOnly && sym != _Symbol) return false;
   if(InpMagicFilter >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagicFilter)
      return false;
   return true;
}

//+------------------------------------------------------------------+
void Guard()
{
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   // --- new trading day ---
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(today != g_dayStamp)
   {
      g_dayStamp    = today;
      g_dayStartBal = balance;
      g_dailyHit    = false;
   }

   if(equity > g_equityPeak) g_equityPeak = equity;

   if(InpEnforceStopLoss) EnforceStops();

   // --- daily loss, measured from the balance the day opened with ---
   // Measuring it from an intraday equity peak instead would turn the normal
   // give-back of an open position into a breach several times a week.
   if(InpMaxDailyLossPct > 0 && !g_dailyHit && g_dayStartBal > 0)
   {
      double lossPct = (g_dayStartBal - equity) / g_dayStartBal * 100.0;
      if(lossPct >= InpMaxDailyLossPct)
      {
         g_dailyHit = true;
         Breach(StringFormat("Daily loss %.2f%% >= %.2f%%", lossPct, InpMaxDailyLossPct));
      }
   }

   // --- total drawdown from the equity peak ---
   if(InpMaxTotalDDPct > 0 && g_equityPeak > 0)
   {
      double ddPct = (g_equityPeak - equity) / g_equityPeak * 100.0;

      if(!g_totalHit && ddPct >= InpMaxTotalDDPct)
      {
         g_totalHit     = true;
         g_totalHitTime = TimeCurrent();
         Breach(StringFormat("Total drawdown %.2f%% >= %.2f%%", ddPct, InpMaxTotalDDPct));
      }
      else if(g_totalHit)
      {
         // Recovered on its own.
         if(ddPct <= InpMaxTotalDDPct * 0.5)
         {
            g_totalHit = false;
            g_lastMsg  = "Recovered - guard re-armed";
            Print("TradeGuardian: ", g_lastMsg);
         }
         // Or the cooldown expired. Measuring from a peak that never moves makes
         // the limit a one-way door, so after the cooldown the current equity
         // becomes the new reference and the account starts again from there.
         else if(InpCooldownHours > 0 && g_totalHitTime > 0 &&
                 (TimeCurrent() - g_totalHitTime) >= (long)InpCooldownHours * 3600)
         {
            g_equityPeak   = equity;
            g_totalHit     = false;
            g_totalHitTime = 0;
            g_lastMsg      = StringFormat("Cooldown over - peak rebased to %.2f", equity);
            Print("TradeGuardian: ", g_lastMsg);
         }
      }
   }

   if(InpPanel) Panel(equity, balance);
}

//+------------------------------------------------------------------+
//| Give a stop loss to every guarded position that has none.        |
//+------------------------------------------------------------------+
void EnforceStops()
{
   double atr[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atr) < 1) return;
   if(atr[0] <= 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!InScope()) continue;
      if(PositionGetDouble(POSITION_SL) > 0) continue;   // already protected

      string sym = PositionGetString(POSITION_SYMBOL);
      // The ATR handle belongs to this chart's symbol, so it may only size a stop
      // for that symbol. Run one instance per symbol you want stops enforced on;
      // the drawdown limits below are account-wide and need only one instance.
      if(sym != _Symbol) continue;

      bool   isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double openP = PositionGetDouble(POSITION_PRICE_OPEN);
      double point = SymbolInfoDouble(sym, SYMBOL_POINT);
      int    digits= (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
      long   stopLvl = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);

      double bid = SymbolInfoDouble(sym, SYMBOL_BID);
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
      double cur = isBuy ? bid : ask;
      if(cur <= 0) continue;

      double dist = atr[0] * InpATR_Mult;
      double minDist = MathMax((stopLvl + 10) * point, InpMinStopPoints * point);
      if(dist < minDist) dist = minDist;

      double sl = isBuy ? openP - dist : openP + dist;

      // Price may already be past that level - keep the stop a safe distance away.
      if(isBuy  && (cur - sl) < minDist) sl = cur - minDist;
      if(!isBuy && (sl - cur) < minDist) sl = cur + minDist;
      sl = NormalizeDouble(sl, digits);

      if(trade.PositionModify(ticket, sl, PositionGetDouble(POSITION_TP)))
         PrintFormat("TradeGuardian: #%I64u %s had no stop loss - set to %.*f",
                     ticket, sym, digits, sl);
      else
         PrintFormat("TradeGuardian: #%I64u could not set a stop loss (retcode %d)",
                     ticket, trade.ResultRetcode());
   }
}

//+------------------------------------------------------------------+
void Breach(const string reason)
{
   g_lastMsg = reason;
   Print("TradeGuardian: ", reason);
   if(InpAlertOnBreach) Alert("TradeGuardian: ", reason);
   if(!InpCloseOnBreach) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(!InScope()) continue;
      if(trade.PositionClose(ticket))
         PrintFormat("TradeGuardian: closed #%I64u", ticket);
   }
}

//+------------------------------------------------------------------+
void Panel(const double equity, const double balance)
{
   double ddPct  = (g_equityPeak > 0) ? (g_equityPeak - equity) / g_equityPeak * 100.0 : 0.0;
   double dayPct = (g_dayStartBal > 0) ? (g_dayStartBal - equity) / g_dayStartBal * 100.0 : 0.0;

   int guarded = 0, unprotected = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;
      if(!InScope()) continue;
      guarded++;
      if(PositionGetDouble(POSITION_SL) <= 0) unprotected++;
   }

   string txt = "Trade Guardian\n";
   txt += StringFormat("equity %.2f   balance %.2f\n", equity, balance);
   txt += StringFormat("peak %.2f   drawdown %.2f%%\n", g_equityPeak, ddPct);
   txt += StringFormat("today %+.2f%%\n", -dayPct);
   txt += StringFormat("guarded positions: %d  (without a stop: %d)\n", guarded, unprotected);
   txt += StringFormat("daily limit: %s   total limit: %s\n",
                       g_dailyHit ? "BREACHED" : "ok",
                       g_totalHit ? "BREACHED" : "ok");
   if(g_lastMsg != "") txt += "last: " + g_lastMsg + "\n";
   if(!InpCloseOnBreach) txt += "mode: warn only\n";

   Comment(txt);
}
//+------------------------------------------------------------------+

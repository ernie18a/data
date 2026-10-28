//+------------------------------------------------------------------+
//|                                              PropFirmGuardEA.mq5 |
//|                                      Copyright 2026, German Soto |
//|                                                https://shushi.cl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, German Soto"
#property link      "https://shushi.cl"
#property version   "1.00"
#property description "Prop-firm account guard: watches equity against a daily loss"
#property description "limit and a total drawdown limit, both with a safety buffer."
#property description "On breach it flattens the whole account and blocks trading"
#property description "until the next daily reset. It opens no trades of its own,"
#property description "so it can run next to any strategy, expert or manual trading."

#include "PropFirmGuard.mqh"

//--- input parameters
input double InpDailyLossPct = 5.0;   // Daily loss limit (% of day-start equity)
input double InpTotalDdPct   = 10.0;  // Total drawdown limit (% from equity peak)
input double InpBufferPct    = 0.5;   // Safety buffer subtracted from both limits (%)
input int    InpResetHour    = 0;     // Daily reset hour (server time, 0-23)

//--- the guard itself
CPropFirmGuard ExtGuard;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- arm the guard, it validates the parameters on its own
   if(!ExtGuard.Init(InpDailyLossPct,InpTotalDdPct,InpBufferPct,InpResetHour))
      return(INIT_PARAMETERS_INCORRECT);
   PrintFormat("[PropFirmGuard] expert initialized on %s, account #%I64d (%s)",
               _Symbol,
               AccountInfoInteger(ACCOUNT_LOGIN),
               AccountInfoString(ACCOUNT_COMPANY));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//--- the guard does all the work, this expert never trades
   ExtGuard.Update();
//--- report the current state on the chart
   string status="OK, trading allowed";
   if(ExtGuard.TotalBreached())
      status="TOTAL DD BREACHED, blocked for good";
   else
      if(ExtGuard.DailyBreached())
         status="DAILY LOSS BREACHED, blocked until reset";
   Comment(StringFormat("PropFirmGuard 1.00\n"
                        "Status: %s\n"
                        "Equity: %.2f   (day start %.2f, peak %.2f)\n"
                        "Daily loss: %.2f%% of %.2f%% allowed\n"
                        "Total DD:   %.2f%% of %.2f%% allowed\n"
                        "Reset hour: %02d:00 server",
                        status,
                        AccountInfoDouble(ACCOUNT_EQUITY),
                        ExtGuard.DayStartEquity(),
                        ExtGuard.PeakEquity(),
                        ExtGuard.DailyLossNowPct(),ExtGuard.EffectiveDailyPct(),
                        ExtGuard.TotalDdNowPct(),ExtGuard.EffectiveTotalPct(),
                        InpResetHour));
  }
//+------------------------------------------------------------------+

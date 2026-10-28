//+------------------------------------------------------------------+
//|                                        PropFirmGuardSelfTest.mq5 |
//|                                      Copyright 2026, German Soto |
//|                                                https://shushi.cl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, German Soto"
#property link      "https://shushi.cl"
#property version   "1.01"
#property description "Self-test harness for PropFirmGuard.mqh, not a strategy."
#property description "It deliberately bleeds money in the strategy tester, opening"
#property description "and closing a market position every N bars and paying the"
#property description "spread each time, to force a daily loss breach and show that"
#property description "the guard flattens and blocks trading until the next reset."

#include "PropFirmGuard.mqh"

//--- guard parameters, defaults tuned to breach fast in the tester
input double InpDailyLossPct = 1.0;   // Daily loss limit (% of day-start equity)
input double InpTotalDdPct   = 50.0;  // Total drawdown limit (% from equity peak)
input double InpBufferPct    = 0.1;   // Safety buffer subtracted from both limits (%)
input int    InpResetHour    = 0;     // Daily reset hour (server time, 0-23)
//--- bleeder parameters
input double InpLots         = 0.01;  // Lot size of each throw-away round trip
input int    InpEveryNBars   = 1;     // Do one round trip every N bars

//--- the guard under test
CPropFirmGuard ExtGuard;
//--- trading object of the bleeder
CTrade         ExtTrade;
//--- new bar detection
datetime       ExtLastBar =0;
int            ExtBarCount=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- check the bleeder parameters
   if(InpLots<=0.0 || InpEveryNBars<1)
     {
      Print("[SelfTest] invalid bleeder parameters");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- arm the guard under test
   if(!ExtGuard.Init(InpDailyLossPct,InpTotalDdPct,InpBufferPct,InpResetHour))
      return(INIT_PARAMETERS_INCORRECT);
   ExtTrade.SetExpertMagicNumber(20260830);
   PrintFormat("[SelfTest] initialized, one round trip every %d bar(s) while Allowed()",
               InpEveryNBars);
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
//| Volume the symbol actually accepts for the next round trip       |
//|                                                                  |
//| Starts from the requested lots, rounds down to the volume step,  |
//| clamps the result to the symbol minimum, maximum and per-symbol  |
//| volume limit, and finally checks the free margin. Returns 0.0    |
//| when no valid and affordable volume exists, in which case the    |
//| harness sends no order at all instead of collecting rejections.  |
//+------------------------------------------------------------------+
double TradableLots(void)
  {
   double vol_min =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vol_max =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double vol_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double vol_lim =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT);
   if(vol_min<=0.0 || vol_max<=0.0)
      return(0.0);
//--- round the request down to the volume step and clamp it to the range
   double lots=MathMax(InpLots,vol_min);
   if(vol_step>0.0)
      lots=MathFloor(lots/vol_step+1e-8)*vol_step;
   lots=MathMax(lots,vol_min);
   lots=MathMin(lots,vol_max);
   if(vol_lim>0.0)
      lots=MathMin(lots,vol_lim);
//--- never send a volume the account cannot afford
   double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double margin=0.0;
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lots,price,margin))
      return(0.0);
   if(margin>AccountInfoDouble(ACCOUNT_MARGIN_FREE))
      return(0.0);
   return(NormalizeDouble(lots,8));
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//--- the guard runs first, exactly as a real expert would use it
   ExtGuard.Update();
//--- mirror the guard state on the chart so the breach is visible
   string status="OK, trading allowed";
   if(ExtGuard.TotalBreached())
      status="TOTAL DD BREACHED, blocked for good";
   else
      if(ExtGuard.DailyBreached())
         status="DAILY LOSS BREACHED, blocked until reset";
   Comment(StringFormat("PropFirmGuard SelfTest\n"
                        "Status: %s\n"
                        "Equity: %.2f   (day start %.2f)\n"
                        "Daily loss: %.2f%% of %.2f%% allowed",
                        status,
                        AccountInfoDouble(ACCOUNT_EQUITY),
                        ExtGuard.DayStartEquity(),
                        ExtGuard.DailyLossNowPct(),ExtGuard.EffectiveDailyPct()));
//--- one action per new bar only
   datetime bar_time=iTime(_Symbol,PERIOD_CURRENT,0);
   if(bar_time==ExtLastBar)
      return;
   ExtLastBar=bar_time;
   ExtBarCount++;
   if(ExtBarCount%InpEveryNBars!=0)
      return;
//--- the whole point of the harness: respect the guard
   if(!ExtGuard.Allowed())
      return;
//--- deterministic loss: market in, market out, spread paid
   double lots=TradableLots();
   if(lots<=0.0)
      return;
   if(!ExtTrade.Buy(lots,_Symbol))
     {
      PrintFormat("[SelfTest] buy rejected (retcode %u '%s')",
                  ExtTrade.ResultRetcode(),ExtTrade.ResultRetcodeDescription());
      return;
     }
   if(!ExtTrade.PositionClose(_Symbol))
     {
      PrintFormat("[SelfTest] close rejected (retcode %u '%s'), the guard will mop it up on breach",
                  ExtTrade.ResultRetcode(),ExtTrade.ResultRetcodeDescription());
      return;
     }
   PrintFormat("[SelfTest] round trip done at %s, equity %.2f (daily loss %.2f%% of %.2f%%)",
               TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),
               AccountInfoDouble(ACCOUNT_EQUITY),
               ExtGuard.DailyLossNowPct(),ExtGuard.EffectiveDailyPct());
  }
//+------------------------------------------------------------------+

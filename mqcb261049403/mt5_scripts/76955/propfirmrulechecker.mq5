//+------------------------------------------------------------------+
//|                                    PropFirmRuleChecker.mq5       |
//|                                                                    |
//| Evaluates account or Strategy Tester trade history against        |
//| common prop-firm challenge rules:                                 |
//|   - Profit target                                                 |
//|   - Max daily loss                                                |
//|   - Max overall drawdown                                          |
//|   - Consistency rule (no single day dominating total profit)      |
//|   - Minimum trading days                                          |
//|                                                                    |
//| Usage:                                                             |
//|   1. Run in the Strategy Tester (after a backtest) or on a live/   |
//|      demo account chart.                                          |
//|   2. Set the inputs to match the rules of the prop firm you are    |
//|      evaluating and the date range you want to check.              |
//|   3. Read the report printed in the Experts/Journal tab.           |
//|                                                                    |
//| This tool only reads closed-trade history — it does not place,     |
//| modify, or close any trades.                                       |
//+------------------------------------------------------------------+
#property copyright "Article demo script"
#property version   "1.00"
#property script_show_inputs
#property strict

input double   InpStartBalance        = 10000.0;                       // Starting balance (account size)
input double   InpProfitTargetPercent = 8.0;                           // Profit target (%)
input double   InpMaxDailyLossPercent = 5.0;                           // Max daily loss allowed (%)
input double   InpMaxTotalDDPercent   = 10.0;                          // Max overall drawdown allowed (%)
input double   InpMaxSingleDayPercent = 30.0;                          // Consistency rule: max % of total profit from one day
input int      InpMinTradingDays      = 5;                             // Minimum trading days required
input datetime InpFromDate            = D'2024.01.01 00:00';           // Period start
input datetime InpToDate              = D'2024.12.31 23:59';           // Period end

struct DayStat
  {
   string dateKey;
   double profit;
  };

DayStat dayStats[];

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpStartBalance <= 0.0)
     {
      Print("InpStartBalance must be greater than 0.");
      return;
     }

   if(InpFromDate >= InpToDate)
     {
      Print("InpFromDate must be earlier than InpToDate.");
      return;
     }

   if(!HistorySelect(InpFromDate, InpToDate))
     {
      Print("HistorySelect failed, error ", GetLastError());
      return;
     }

   int    deals        = HistoryDealsTotal();
   double balance       = InpStartBalance;
   double peakBalance   = InpStartBalance;
   double maxDrawdown   = 0.0;
   double totalProfit   = 0.0;
   int    dealsCounted  = 0;

   ArrayResize(dayStats, 0);

   for(int i = 0; i < deals; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;

      long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL)
         continue;

      dealsCounted++;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                     + HistoryDealGetDouble(ticket, DEAL_SWAP)
                     + HistoryDealGetDouble(ticket, DEAL_COMMISSION);

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      MqlDateTime mdt;
      TimeToStruct(dealTime, mdt);
      string dayKey = StringFormat("%04d.%02d.%02d", mdt.year, mdt.mon, mdt.day);

      // running balance / drawdown
      balance     += profit;
      totalProfit += profit;
      if(balance > peakBalance)
         peakBalance = balance;

      double dd = (peakBalance - balance) / peakBalance * 100.0;
      if(dd > maxDrawdown)
         maxDrawdown = dd;

      // aggregate profit per calendar day
      int idx = -1;
      for(int j = 0; j < ArraySize(dayStats); j++)
        {
         if(dayStats[j].dateKey == dayKey)
           {
            idx = j;
            break;
           }
        }
      if(idx == -1)
        {
         idx = ArraySize(dayStats);
         ArrayResize(dayStats, idx + 1);
         dayStats[idx].dateKey = dayKey;
         dayStats[idx].profit  = 0.0;
        }
      dayStats[idx].profit += profit;
     }

   if(dealsCounted == 0)
     {
      PrintFormat("No closed trades found between %s and %s. Nothing to evaluate.",
                  TimeToString(InpFromDate, TIME_DATE), TimeToString(InpToDate, TIME_DATE));
      return;
     }

   // ---- Max daily loss check ----
   bool   dailyLossBreached  = false;
   string worstDay           = "-";
   double worstDayLossPercent = 0.0;

   for(int j = 0; j < ArraySize(dayStats); j++)
     {
      double lossPercent = (dayStats[j].profit < 0)
                          ? MathAbs(dayStats[j].profit) / InpStartBalance * 100.0
                          : 0.0;
      if(lossPercent > worstDayLossPercent)
        {
         worstDayLossPercent = lossPercent;
         worstDay = dayStats[j].dateKey;
        }
      if(lossPercent > InpMaxDailyLossPercent)
         dailyLossBreached = true;
     }

   // ---- Consistency rule check ----
   bool   consistencyBreached    = false;
   string bestDay                = "-";
   double bestDayPercentOfTotal  = 0.0;

   for(int j = 0; j < ArraySize(dayStats); j++)
     {
      if(dayStats[j].profit > 0 && totalProfit > 0)
        {
         double pctOfTotal = dayStats[j].profit / totalProfit * 100.0;
         if(pctOfTotal > bestDayPercentOfTotal)
           {
            bestDayPercentOfTotal = pctOfTotal;
            bestDay = dayStats[j].dateKey;
           }
         if(pctOfTotal > InpMaxSingleDayPercent)
            consistencyBreached = true;
        }
     }

   double totalProfitPercent = totalProfit / InpStartBalance * 100.0;
   int    tradingDays        = ArraySize(dayStats);

   bool ddBreached     = maxDrawdown > InpMaxTotalDDPercent;
   bool targetReached  = totalProfitPercent >= InpProfitTargetPercent;
   bool minDaysReached = tradingDays >= InpMinTradingDays;

   Print("========== PROP FIRM RULE CHECK REPORT ==========");
   PrintFormat("Period                : %s - %s",
               TimeToString(InpFromDate, TIME_DATE), TimeToString(InpToDate, TIME_DATE));
   PrintFormat("Deals evaluated       : %d", dealsCounted);
   PrintFormat("Trading days          : %d (min required: %d) -> %s",
               tradingDays, InpMinTradingDays, minDaysReached ? "PASS" : "FAIL");
   PrintFormat("Total profit          : %.2f (%.2f%%), target %.2f%% -> %s",
               totalProfit, totalProfitPercent, InpProfitTargetPercent, targetReached ? "PASS" : "FAIL");
   PrintFormat("Max drawdown          : %.2f%% (limit %.2f%%) -> %s",
               maxDrawdown, InpMaxTotalDDPercent, ddBreached ? "FAIL" : "PASS");
   PrintFormat("Worst single day loss : %s  %.2f%% (limit %.2f%%) -> %s",
               worstDay, worstDayLossPercent, InpMaxDailyLossPercent, dailyLossBreached ? "FAIL" : "PASS");
   PrintFormat("Best single day share : %s  %.2f%% of total profit (limit %.2f%%) -> %s",
               bestDay, bestDayPercentOfTotal, InpMaxSingleDayPercent, consistencyBreached ? "FAIL" : "PASS");

   bool overallPass = !ddBreached && !dailyLossBreached && !consistencyBreached && targetReached && minDaysReached;

   Print("---------------------------------------------------");
   Print("OVERALL RESULT: ", overallPass ? "WOULD PASS CHALLENGE" : "WOULD FAIL CHALLENGE");
   Print("====================================================");
  }
//+------------------------------------------------------------------+

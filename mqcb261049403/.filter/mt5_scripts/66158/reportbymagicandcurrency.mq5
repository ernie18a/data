//+------------------------------------------------------------------+
//|                                   ReportbyMagicAndCurrency.mq5   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, DamosResultados"
#property link      "https://www.damosresultados.com"
#property version   "3.03"
#property script_show_inputs

input group "=== Optional Date Range ==="
input datetime DateFrom = 0;  // Start date (default = ALL HISTORY)
input datetime DateTo = 0;    // End date (default = ALL HISTORY)

input group "=== Balance Allocation ==="
input double BalanceAllocation = 0; // Custom balance allocation per magic/symbol (0 = use whole account balance)

//+------------------------------------------------------------------+
//| Structure to hold statistics                                     |
//+------------------------------------------------------------------+
struct StatData
{
   string   symbol;
   long     magic;
   double   totalPL;
   double   totalVolume;
   int      totalTrades;
   int      winTrades;
   int      lossTrades;
   double   grossProfit;
   double   grossLoss;
   double   netPosition;
   double   exposure;
   double   peakDDDollar;
   double   peakDDPercent;

   // Portfolio-level MAE metrics (adverse excursion of the entire open basket)
   double   avgMAE;
   double   maxMAE;
   double   mae95Percentile;
   double   mae99Percentile;
   double   worstSingleTrade;
   int      maxConsecLosses;
   double   maxHoldingHours;
   double   avgHoldingHours;
   double   twrGainPercent;
};

//+------------------------------------------------------------------+
//| Structure to hold open position tracking                         |
//+------------------------------------------------------------------+
struct OpenPosition
{
   ulong    ticket;
   datetime openTime;
   double   openPrice;
   double   volume;
   int      type; // 0=buy, 1=sell
};

//+------------------------------------------------------------------+
//| Structure to hold balance history point                          |
//+------------------------------------------------------------------+
struct BalancePoint
{
   datetime time;
   double   balance;
};

//+------------------------------------------------------------------+
//| Structure to hold trade holding time data                        |
//+------------------------------------------------------------------+
struct TradeHoldingTime
{
   ulong    ticket;
   datetime openTime;
   datetime closeTime;
   double   holdingHours;
};

//+------------------------------------------------------------------+
//| Function to get the first trade date from history                |
//+------------------------------------------------------------------+
datetime GetFirstTradeDate()
{
   if(!HistorySelect(0, TimeCurrent()))
      return 0;

   int totalDeals = HistoryDealsTotal();

   for(int i = 0; i < totalDeals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);

      if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
         return (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
   }

   return 0;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   datetime actualDateFrom = DateFrom;
   datetime actualDateTo   = DateTo;

   if(actualDateFrom == 0)
   {
      actualDateFrom = GetFirstTradeDate();
      if(actualDateFrom == 0)
         actualDateFrom = 0;
   }

   if(actualDateTo == 0)
      actualDateTo = TimeCurrent();

   long   accountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
   string fromDateStr   = (actualDateFrom == 0) ? "BeginningOfTime" : TimeToString(actualDateFrom, TIME_DATE);
   string toDateStr     = TimeToString(actualDateTo, TIME_DATE);

   StringReplace(fromDateStr, ".", "-");
   StringReplace(toDateStr,   ".", "-");

   string CSVFileName = StringFormat("TradingStats%dFROM%sTO%s",
                                     accountNumber, fromDateStr, toDateStr);

   string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
   string fullPath = terminalDataPath + "\\MQL5\\Files\\" + CSVFileName + ".csv";
   Alert("Generating report, it might take longer according to the amount of records and will be saved to: " + fullPath);

   Print("Starting Trading Statistics Export...");
   Print("Date Range: FROM ", TimeToString(actualDateFrom), " TO ", TimeToString(actualDateTo));
   if(BalanceAllocation > 0)
      Print("Balance Allocation: $", DoubleToString(BalanceAllocation, 2), " (custom allocation mode)");

   if(!HistorySelect(actualDateFrom, actualDateTo))
   {
      Print("Failed to retrieve history!");
      Alert("Failed to retrieve history!");
      return;
   }

   int totalDeals = HistoryDealsTotal();
   Print("Total deals in history: ", totalDeals);

   if(totalDeals == 0)
   {
      Print("No deals found in account history.");
      Alert("No deals found in account history.");
      return;
   }

   StatData stats[];

   for(int i = 0; i < totalDeals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      if(actualDateFrom != 0 && dealTime < actualDateFrom) continue;
      if(actualDateTo   != 0 && dealTime > actualDateTo)   continue;

      long   magic      = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      string symbol     = HistoryDealGetString(ticket, DEAL_SYMBOL);
      double profit     = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      double volume     = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double swap       = HistoryDealGetDouble(ticket, DEAL_SWAP);
      double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      long   entry      = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      long   type       = HistoryDealGetInteger(ticket, DEAL_TYPE);

      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;

      double totalPL = profit + swap + commission;

      int idx = FindStatIndex(stats, symbol, magic);
      if(idx == -1)
      {
         idx = ArraySize(stats);
         ArrayResize(stats, idx + 1);
         stats[idx].symbol          = symbol;
         stats[idx].magic           = magic;
         stats[idx].totalPL         = 0;
         stats[idx].totalVolume     = 0;
         stats[idx].totalTrades     = 0;
         stats[idx].winTrades       = 0;
         stats[idx].lossTrades      = 0;
         stats[idx].grossProfit     = 0;
         stats[idx].grossLoss       = 0;
         stats[idx].netPosition     = 0;
         stats[idx].exposure        = 0;
         stats[idx].peakDDDollar    = 0;
         stats[idx].peakDDPercent   = 0;
         stats[idx].avgMAE          = 0;
         stats[idx].maxMAE          = 0;
         stats[idx].mae95Percentile = 0;
         stats[idx].mae99Percentile = 0;
         stats[idx].worstSingleTrade= 0;
         stats[idx].maxConsecLosses = 0;
         stats[idx].maxHoldingHours = 0;
         stats[idx].avgHoldingHours = 0;
         stats[idx].twrGainPercent  = 0;
      }

      stats[idx].totalPL     += totalPL;
      stats[idx].totalVolume += volume;

      if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT || entry == DEAL_ENTRY_OUT_BY)
      {
         stats[idx].totalTrades++;
         if(totalPL > 0)
         {
            stats[idx].winTrades++;
            stats[idx].grossProfit += totalPL;
         }
         else if(totalPL < 0)
         {
            stats[idx].lossTrades++;
            stats[idx].grossLoss += totalPL;
         }
      }

      if(entry == DEAL_ENTRY_IN)
      {
         if(type == DEAL_TYPE_BUY)  stats[idx].netPosition += volume;
         else                       stats[idx].netPosition -= volume;
      }
      else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
      {
         if(type == DEAL_TYPE_SELL) stats[idx].netPosition += volume;
         else                       stats[idx].netPosition -= volume;
      }
   }

   BalancePoint balanceHistory[];
   BuildBalanceHistory(balanceHistory);

   CalculateDrawdowns(stats, balanceHistory, actualDateFrom, actualDateTo);
   CalculateOpenPositions(stats);
   ExportToCSV(stats, CSVFileName, actualDateFrom, actualDateTo);

   Print("Export completed successfully!");
   Alert("Report saved to: " + fullPath);
}

//+------------------------------------------------------------------+
//| Find stat index for symbol/magic combination                     |
//+------------------------------------------------------------------+
int FindStatIndex(StatData &stats[], string symbol, long magic)
{
   for(int i = 0; i < ArraySize(stats); i++)
   {
      if(stats[i].symbol == symbol && stats[i].magic == magic)
         return i;
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Build account balance history from deals - ALWAYS FROM BEGINNING |
//+------------------------------------------------------------------+
void BuildBalanceHistory(BalancePoint &balanceHistory[])
{
   if(!HistorySelect(0, TimeCurrent()))
      return;

   int    totalDeals     = HistoryDealsTotal();
   double runningBalance = 0;

   for(int i = 0; i < totalDeals; i++)
   {
      ulong    ticket     = HistoryDealGetTicket(i);
      if(ticket == 0) continue;

      long     dealType   = HistoryDealGetInteger(ticket, DEAL_TYPE);
      double   profit     = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      double   swap       = HistoryDealGetDouble(ticket, DEAL_SWAP);
      double   commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      datetime dealTime   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      if(dealType == DEAL_TYPE_BALANCE)
         runningBalance += profit;
      else if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
         runningBalance += profit + swap + commission;

      int idx = ArraySize(balanceHistory);
      ArrayResize(balanceHistory, idx + 1);
      balanceHistory[idx].time    = dealTime;
      balanceHistory[idx].balance = runningBalance;
   }
}

//+------------------------------------------------------------------+
//| Get account balance at specific time from history                |
//+------------------------------------------------------------------+
double GetBalanceAtTime(BalancePoint &balanceHistory[], datetime targetTime)
{
   if(ArraySize(balanceHistory) == 0)
      return 0;

   double balance = 0;
   for(int i = 0; i < ArraySize(balanceHistory); i++)
   {
      if(balanceHistory[i].time <= targetTime)
         balance = balanceHistory[i].balance;
      else
         break;
   }
   return balance;
}

//+------------------------------------------------------------------+
//| Resolve effective balance: allocation override or account balance |
//+------------------------------------------------------------------+
double GetEffectiveBalance(BalancePoint &balanceHistory[], datetime targetTime)
{
   if(BalanceAllocation > 0)
      return BalanceAllocation;
   return GetBalanceAtTime(balanceHistory, targetTime);
}

//+------------------------------------------------------------------+
//| Calculate portfolio floating P&L at a given price                |
//| FIX: Uses deal prices (always available) instead of CopyRates.   |
//| FIX: Correct P&L formula: (priceDiff / tickSize) * tickValue     |
//| This correctly nets longs vs shorts for hedged/grid strategies.  |
//+------------------------------------------------------------------+
double CalculatePortfolioFloatingPL(OpenPosition &positions[], string symbol, double currentPrice)
{
   if(ArraySize(positions) == 0)
      return 0;

   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

   if(tickSize <= 0 || tickValue <= 0)
      return 0;

   double total = 0;
   for(int i = 0; i < ArraySize(positions); i++)
   {
      double priceDiff;
      if(positions[i].type == 0) // Buy
         priceDiff = currentPrice - positions[i].openPrice;
      else                        // Sell
         priceDiff = positions[i].openPrice - currentPrice;

      // Correct formula: (priceDiff / tickSize) * tickValue * lots
      total += (priceDiff / tickSize) * tickValue * positions[i].volume;
   }
   return total;
}

//+------------------------------------------------------------------+
//| Calculate percentile from sorted array                           |
//+------------------------------------------------------------------+
double CalculatePercentile(double &sortedValues[], int percentile)
{
   int count = ArraySize(sortedValues);
   if(count == 0) return 0;
   if(count == 1) return sortedValues[0];

   double rank       = (percentile / 100.0) * (count - 1);
   int    lowerIndex = (int)MathFloor(rank);
   int    upperIndex = (int)MathCeil(rank);

   if(lowerIndex == upperIndex)
      return sortedValues[lowerIndex];

   double weight = rank - lowerIndex;
   return sortedValues[lowerIndex] * (1.0 - weight) + sortedValues[upperIndex] * weight;
}

//+------------------------------------------------------------------+
//| Calculate MAE statistics from portfolio adverse-excursion samples |
//| FIX: Now uses portfolio-level samples instead of per-trade MAE.  |
//+------------------------------------------------------------------+
void CalculateMAEStatisticsFromSamples(StatData &stat, double &maeSamples[])
{
   int count = ArraySize(maeSamples);

   if(count == 0)
   {
      stat.avgMAE          = 0;
      stat.maxMAE          = 0;
      stat.mae95Percentile = 0;
      stat.mae99Percentile = 0;
      return;
   }

   double totalMAE = 0;
   double maxMAE   = 0;

   for(int i = 0; i < count; i++)
   {
      totalMAE += maeSamples[i];
      if(maeSamples[i] > maxMAE)
         maxMAE = maeSamples[i];
   }

   // Sort for percentile calculation
   ArraySort(maeSamples);

   stat.avgMAE          = totalMAE / count;
   stat.maxMAE          = maxMAE;
   stat.mae95Percentile = CalculatePercentile(maeSamples, 95);
   stat.mae99Percentile = CalculatePercentile(maeSamples, 99);
}

//+------------------------------------------------------------------+
//| Calculate holding time statistics from trade data                |
//+------------------------------------------------------------------+
void CalculateHoldingTimeStatistics(StatData &stat, TradeHoldingTime &holdingTimes[])
{
   int count = ArraySize(holdingTimes);
   if(count == 0)
   {
      stat.maxHoldingHours = 0;
      stat.avgHoldingHours = 0;
      return;
   }

   double totalHours = 0;
   double maxHours   = 0;

   for(int i = 0; i < count; i++)
   {
      totalHours += holdingTimes[i].holdingHours;
      if(holdingTimes[i].holdingHours > maxHours)
         maxHours = holdingTimes[i].holdingHours;
   }

   stat.maxHoldingHours = maxHours;
   stat.avgHoldingHours = totalHours / count;
}

//+------------------------------------------------------------------+
//| Calculate drawdowns, MAE, and TWR from historical deals          |
//|                                                                  |
//| KEY FIXES vs v3.02:                                              |
//|  1. Portfolio floating P&L uses DEAL_PRICE (no CopyRates).       |
//|     This is always available and never returns 0 silently.       |
//|  2. Portfolio P&L correctly nets long+short (hedging offset).    |
//|  3. MAE is now portfolio-level adverse excursion, not per-trade. |
//|     Sampled at every deal event (IN and OUT) and also at each    |
//|     IN-direction deal to capture running basket exposure.        |
//|  4. DD is calculated from the same portfolio floating P&L,       |
//|     so hedged positions reduce reported drawdown correctly.      |
//+------------------------------------------------------------------+
void CalculateDrawdowns(StatData &stats[], BalancePoint &balanceHistory[], datetime from, datetime to)
{
   if(!HistorySelect(from, to))
      return;

   int totalDeals = HistoryDealsTotal();

   for(int s = 0; s < ArraySize(stats); s++)
   {
      Print("Calculating metrics for ", stats[s].symbol, " Magic: ", stats[s].magic);

      OpenPosition     openPositions[];
      TradeHoldingTime holdingTimes[];

      // Portfolio-level MAE: collect adverse excursion samples at every deal event.
      // Samples are the absolute value of negative portfolio floating P&L.
      double maeSamples[];

      double   realizedPL     = 0;
      double   peakEquity     = 0;
      double   maxDD          = 0;
      double   maxDDPercent   = 0;
      int      consecLosses   = 0;
      int      maxConsecLoss  = 0;
      double   worstTrade     = 0;

      double   startBalance   = GetEffectiveBalance(balanceHistory, from);
      if(startBalance == 0) startBalance = 1;

      for(int i = 0; i < totalDeals; i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket == 0) continue;

         long   magic  = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         long   type   = HistoryDealGetInteger(ticket, DEAL_TYPE);

         if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL) continue;
         if(symbol != stats[s].symbol || magic != stats[s].magic) continue;

         datetime dealTime   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         long     entry      = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         double   volume     = HistoryDealGetDouble(ticket, DEAL_VOLUME);
         double   price      = HistoryDealGetDouble(ticket, DEAL_PRICE);
         double   profit     = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         double   swap       = HistoryDealGetDouble(ticket, DEAL_SWAP);
         double   commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);

         // ---- Handle position entry ----
         if(entry == DEAL_ENTRY_IN)
         {
            int idx = ArraySize(openPositions);
            ArrayResize(openPositions, idx + 1);
            openPositions[idx].ticket    = ticket;
            openPositions[idx].openTime  = dealTime;
            openPositions[idx].openPrice = price;
            openPositions[idx].volume    = volume;
            openPositions[idx].type      = (type == DEAL_TYPE_BUY) ? 0 : 1;
         }
         // ---- Handle position exit ----
         else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
         {
            double tradePL = profit + swap + commission;
            realizedPL += tradePL;

            if(tradePL < worstTrade) worstTrade = tradePL;

            if(tradePL < 0) { consecLosses++; if(consecLosses > maxConsecLoss) maxConsecLoss = consecLosses; }
            else              consecLosses = 0;

            // Match closed volume (FIFO) and record holding times
            double remainingVolume = volume;
            for(int p = 0; p < ArraySize(openPositions) && remainingVolume > 0; p++)
            {
               int htIdx = ArraySize(holdingTimes);
               ArrayResize(holdingTimes, htIdx + 1);
               holdingTimes[htIdx].ticket       = openPositions[p].ticket;
               holdingTimes[htIdx].openTime     = openPositions[p].openTime;
               holdingTimes[htIdx].closeTime    = dealTime;
               holdingTimes[htIdx].holdingHours = (dealTime - openPositions[p].openTime) / 3600.0;

               if(openPositions[p].volume <= remainingVolume + 1e-8)
               {
                  remainingVolume -= openPositions[p].volume;
                  for(int k = p; k < ArraySize(openPositions) - 1; k++)
                     openPositions[k] = openPositions[k + 1];
                  ArrayResize(openPositions, ArraySize(openPositions) - 1);
                  p--;
               }
               else
               {
                  openPositions[p].volume -= remainingVolume;
                  remainingVolume = 0;
               }
            }
         }

         // ---- Sample portfolio state at this deal price ----
         // FIX: Use the deal execution price as the current market reference.
         // For hedged positions this nets long and short floating P&L automatically.
         double portfolioFloatPL = CalculatePortfolioFloatingPL(openPositions, stats[s].symbol, price);

         // ---- MAE sampling ----
         // Record any adverse excursion (negative portfolio floating P&L)
         if(portfolioFloatPL < 0 && ArraySize(openPositions) > 0)
         {
            int sIdx = ArraySize(maeSamples);
            ArrayResize(maeSamples, sIdx + 1);
            maeSamples[sIdx] = MathAbs(portfolioFloatPL);
         }

         // ---- Equity and DD tracking ----
         double currentEquity = realizedPL + portfolioFloatPL;

         if(currentEquity > peakEquity)
            peakEquity = currentEquity;

         double currentDD = peakEquity - currentEquity;
         if(currentDD > maxDD)
         {
            maxDD = currentDD;

            double effectiveBalance = GetEffectiveBalance(balanceHistory, dealTime);
            if(effectiveBalance > 0)
            {
               double ddPct = MathMin((currentDD / effectiveBalance) * 100.0, 100.0);
               if(ddPct > maxDDPercent)
                  maxDDPercent = ddPct;
            }
         }
      } // end deal loop

      // ---- Finalise per-symbol/magic statistics ----
      CalculateMAEStatisticsFromSamples(stats[s], maeSamples);
      CalculateHoldingTimeStatistics(stats[s], holdingTimes);

      double endBalance = startBalance + stats[s].totalPL;
      stats[s].twrGainPercent  = ((endBalance - startBalance) / startBalance) * 100.0;
      stats[s].peakDDDollar    = maxDD;
      stats[s].peakDDPercent   = maxDDPercent;
      stats[s].worstSingleTrade= worstTrade;
      stats[s].maxConsecLosses = maxConsecLoss;

      Print("  Peak DD: $",  DoubleToString(maxDD, 2), " (", DoubleToString(maxDDPercent, 2), "%)");
      Print("  MAE samples: ", ArraySize(maeSamples),
            "  Avg=",  DoubleToString(stats[s].avgMAE, 2),
            "  Max=",  DoubleToString(stats[s].maxMAE, 2),
            "  95%=",  DoubleToString(stats[s].mae95Percentile, 2),
            "  99%=",  DoubleToString(stats[s].mae99Percentile, 2));
      Print("  Holding: Max=", DoubleToString(stats[s].maxHoldingHours, 2),
            " hrs, Avg=",      DoubleToString(stats[s].avgHoldingHours, 2), " hrs");
      Print("  TWR Gain: ",    DoubleToString(stats[s].twrGainPercent, 2), "%");
   }
}

//+------------------------------------------------------------------+
//| Calculate current open positions for exposure                    |
//+------------------------------------------------------------------+
void CalculateOpenPositions(StatData &stats[])
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong  ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      long   magic  = PositionGetInteger(POSITION_MAGIC);
      double volume = PositionGetDouble(POSITION_VOLUME);
      long   type   = PositionGetInteger(POSITION_TYPE);

      int idx = FindStatIndex(stats, symbol, magic);
      if(idx != -1)
      {
         if(type == POSITION_TYPE_BUY) stats[idx].exposure += volume;
         else                          stats[idx].exposure -= volume;
      }
   }
}

//+------------------------------------------------------------------+
//| Export all statistics to single CSV file                         |
//+------------------------------------------------------------------+
void ExportToCSV(StatData &stats[], string filename, datetime from, datetime to)
{
   string fullFilename = filename + ".csv";
   int handle = FileOpen(fullFilename, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');

   if(handle == INVALID_HANDLE)
   {
      Print("Failed to create CSV file: ", fullFilename);
      Alert("Failed to create CSV file: ", fullFilename);
      return;
   }

   string dateRangeStr;
   if(from == 0)
      dateRangeStr = "FROM Beginning of Time TO " + TimeToString(to, TIME_DATE);
   else
      dateRangeStr = "FROM " + TimeToString(from, TIME_DATE) + " TO " + TimeToString(to, TIME_DATE);

   // ---- Global totals ----
   double globalTotalPL         = 0;
   int    globalTotalTrades     = 0;
   int    globalWinTrades       = 0;
   double globalGrossProfit     = 0;
   double globalGrossLoss       = 0;
   double globalNetPosition     = 0;
   double globalExposure        = 0;
   double globalTotalVolume     = 0;
   double globalPeakDDDollar    = 0;
   double globalPeakDDPercent   = 0;
   double globalAvgMAE          = 0;
   double globalMaxMAE          = 0;
   double globalMAE95           = 0;
   double globalMAE99           = 0;
   double globalWorstTrade      = 0;
   int    globalMaxConsecLosses = 0;
   double globalMaxHolding      = 0;
   double globalAvgHolding      = 0;
   double globalTWRGain         = 0;

   for(int i = 0; i < ArraySize(stats); i++)
   {
      globalTotalPL       += stats[i].totalPL;
      globalTotalTrades   += stats[i].totalTrades;
      globalWinTrades     += stats[i].winTrades;
      globalGrossProfit   += stats[i].grossProfit;
      globalGrossLoss     += stats[i].grossLoss;
      globalNetPosition   += stats[i].netPosition;
      globalExposure      += stats[i].exposure;
      globalTotalVolume   += stats[i].totalVolume;
      globalTWRGain       += stats[i].twrGainPercent;

      if(stats[i].peakDDDollar  > globalPeakDDDollar)   globalPeakDDDollar  = stats[i].peakDDDollar;
      if(stats[i].peakDDPercent > globalPeakDDPercent)   globalPeakDDPercent = stats[i].peakDDPercent;
      if(stats[i].maxMAE        > globalMaxMAE)           globalMaxMAE        = stats[i].maxMAE;
      if(stats[i].mae95Percentile > globalMAE95)          globalMAE95         = stats[i].mae95Percentile;
      if(stats[i].mae99Percentile > globalMAE99)          globalMAE99         = stats[i].mae99Percentile;
      if(stats[i].worstSingleTrade < globalWorstTrade)    globalWorstTrade    = stats[i].worstSingleTrade;
      if(stats[i].maxConsecLosses > globalMaxConsecLosses) globalMaxConsecLosses = stats[i].maxConsecLosses;
      if(stats[i].maxHoldingHours > globalMaxHolding)     globalMaxHolding    = stats[i].maxHoldingHours;

      globalAvgMAE     += stats[i].avgMAE     * stats[i].totalTrades;
      globalAvgHolding += stats[i].avgHoldingHours * stats[i].totalTrades;
   }

   if(globalTotalTrades > 0)
   {
      globalAvgMAE     = globalAvgMAE     / globalTotalTrades;
      globalAvgHolding = globalAvgHolding / globalTotalTrades;
   }

   double globalWinRate      = globalTotalTrades > 0 ? (globalWinTrades * 100.0 / globalTotalTrades) : 0;
   double globalProfitFactor = globalGrossLoss  != 0 ? -globalGrossProfit / globalGrossLoss : 0;

   // ---- Write global summary ----
   FileWrite(handle, "");
   FileWrite(handle, "=== GLOBAL ACCOUNT METRICS - " + dateRangeStr + " ===");
   FileWrite(handle, "Currency Pair", "Magic Number", "Total P&L", "Total Trades",
             "Win Rate %", "Gain%(TWR)", "Gross Profit", "Gross Loss", "Profit Factor",
             "PeakDD$", "PeakDD%", "Net Position", "Current Exposure", "Total Volume",
             "Avg MAE (portfolio)", "Max MAE (portfolio)", "MAE 95%", "MAE 99%",
             "Worst Trade", "Max Consec Losses", "Max Holding (hrs)", "Avg Holding (hrs)");

   FileWrite(handle,
             "ALL", "ALL",
             DoubleToString(globalTotalPL, 2),
             IntegerToString(globalTotalTrades),
             DoubleToString(globalWinRate, 2),
             DoubleToString(globalTWRGain, 2),
             DoubleToString(globalGrossProfit, 2),
             DoubleToString(globalGrossLoss, 2),
             DoubleToString(globalProfitFactor, 2),
             DoubleToString(globalPeakDDDollar, 2),
             DoubleToString(globalPeakDDPercent, 2),
             DoubleToString(globalNetPosition, 2),
             DoubleToString(globalExposure, 2),
             DoubleToString(globalTotalVolume, 2),
             DoubleToString(globalAvgMAE, 2),
             DoubleToString(globalMaxMAE, 2),
             DoubleToString(globalMAE95, 2),
             DoubleToString(globalMAE99, 2),
             DoubleToString(globalWorstTrade, 2),
             IntegerToString(globalMaxConsecLosses),
             DoubleToString(globalMaxHolding, 2),
             DoubleToString(globalAvgHolding, 2));

   // ---- Detailed section ----
   string detailSectionTitle;
   if(BalanceAllocation > 0)
      detailSectionTitle = "=== STATISTICS BY CURRENCY PAIR AND MAGIC NUMBER WITH A $"
                           + DoubleToString(BalanceAllocation, 2) + " ALLOCATION ===";
   else
      detailSectionTitle = "=== STATISTICS BY CURRENCY PAIR AND MAGIC NUMBER ===";

   FileWrite(handle, "");
   FileWrite(handle, detailSectionTitle);
   FileWrite(handle, "Currency Pair", "Magic Number", "Total P&L", "Total Trades",
             "Win Rate %", "Gain%(TWR)", "Gross Profit", "Gross Loss", "Profit Factor",
             "PeakDD$", "PeakDD%", "Net Position", "Current Exposure", "Total Volume",
             "Avg MAE (portfolio)", "Max MAE (portfolio)", "MAE 95%", "MAE 99%",
             "Worst Trade", "Max Consec Losses", "Max Holding (hrs)", "Avg Holding (hrs)");

   string symbols[];

   for(int i = 0; i < ArraySize(stats); i++)
   {
      if(FindSymbolIndex(symbols, stats[i].symbol) == -1)
      {
         int idx = ArraySize(symbols);
         ArrayResize(symbols, idx + 1);
         symbols[idx] = stats[i].symbol;
      }
   }

   for(int s = 0; s < ArraySize(symbols); s++)
   {
      string symbol = symbols[s];

      for(int i = 0; i < ArraySize(stats); i++)
      {
         if(stats[i].symbol != symbol) continue;

         double winRate      = stats[i].totalTrades > 0 ? (stats[i].winTrades * 100.0 / stats[i].totalTrades) : 0;
         double profitFactor = stats[i].grossLoss   != 0 ? -stats[i].grossProfit / stats[i].grossLoss : 0;
         string magicLabel   = stats[i].magic == 0 ? "0 (Manual)" : IntegerToString(stats[i].magic);

         FileWrite(handle,
                   stats[i].symbol,
                   magicLabel,
                   DoubleToString(stats[i].totalPL, 2),
                   IntegerToString(stats[i].totalTrades),
                   DoubleToString(winRate, 2),
                   DoubleToString(stats[i].twrGainPercent, 2),
                   DoubleToString(stats[i].grossProfit, 2),
                   DoubleToString(stats[i].grossLoss, 2),
                   DoubleToString(profitFactor, 2),
                   DoubleToString(stats[i].peakDDDollar, 2),
                   DoubleToString(stats[i].peakDDPercent, 2),
                   DoubleToString(stats[i].netPosition, 2),
                   DoubleToString(stats[i].exposure, 2),
                   DoubleToString(stats[i].totalVolume, 2),
                   DoubleToString(stats[i].avgMAE, 2),
                   DoubleToString(stats[i].maxMAE, 2),
                   DoubleToString(stats[i].mae95Percentile, 2),
                   DoubleToString(stats[i].mae99Percentile, 2),
                   DoubleToString(stats[i].worstSingleTrade, 2),
                   IntegerToString(stats[i].maxConsecLosses),
                   DoubleToString(stats[i].maxHoldingHours, 2),
                   DoubleToString(stats[i].avgHoldingHours, 2));
      }
   }

   FileClose(handle);
   Print("All statistics exported successfully!");
}

//+------------------------------------------------------------------+
//| Find symbol index in array                                       |
//+------------------------------------------------------------------+
int FindSymbolIndex(string &symbols[], string symbol)
{
   for(int i = 0; i < ArraySize(symbols); i++)
   {
      if(symbols[i] == symbol)
         return i;
   }
   return -1;
}
//+------------------------------------------------------------------+

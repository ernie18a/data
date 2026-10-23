//+------------------------------------------------------------------+
//|                                                   ProfitConc.mq5 |
//|                Profit Concentration & Consistency Analyzer (MT5) |
//|          Reads a per-closing-deal result file and measures where |
//|          the profit comes from: top-trade share, Gini, a remove- |
//|         the-best-winners stress test, and the largest single day |
//|            versus a prop-firm consistency limit, combined into a |
//|        heuristic score.                                          |
//+------------------------------------------------------------------+
#property copyright "Cristian David Castillo Arrieta"
#property version   "1.10"
#property script_show_inputs
#property description "Reads a per-closing-deal result file and analyzes how concentrated the profit is."

//--- Input parameters
input string InpFileName         = "Trades.csv"; // CSV file: Date,Profit (one row per closing deal)
input double InpConsistencyLimit = 20.0;         // Prop-firm largest-day limit (% of total profit)
input int    InpTopN             = 5;            // Top-N trades used for the concentration figures
input double InpRemovePct        = 5.0;          // Stress test: remove this % of best winners (0 = none)
input double InpWeightConc       = 0.40;         // Weight: concentration dimension
input double InpWeightConsist    = 0.35;         // Weight: day-consistency dimension
input double InpWeightSurv       = 0.25;         // Weight: outlier-dependence dimension
input double InpConcFactor       = 1.4;          // Concentration score: points lost per 1% of top-N net share above 25
input double InpConsistFactor    = 2.5;          // Consistency score: points lost per 1% of best day above the limit

//--- Aggregated report: every figure the analyzer prints lives here
struct SReport
  {
   int    nTrades;                               // total trades loaded from the file
   int    nWinners;                              // trades with a positive result
   int    nLosers;                               // trades with a negative result
   int    nFlat;                                 // trades with exactly zero result
   double netProfit;                             // gross profit minus gross loss
   double grossProfit;                           // sum of the winning trades
   double grossLoss;                             // sum of the losing trades, stored as a positive number
   double profitFactor;                          // gross profit / gross loss; -1.0 means undefined (no losing trades)
   double winRate;                               // winners as a percentage of all trades
   double gini;                                  // Gini coefficient of the winning trades (0 = even, 1 = concentrated)
   double topNShare;                             // top-N trades as % of net profit
   double topNShareGross;                        // top-N trades as % of gross profit
   double bestDayShare;                          // largest profitable day as % of net profit
   string bestDay;                               // date of that largest profitable day
   double survivalRatio;                         // net after removing the best K winners / net before (0..1)
   double netAfterRemove;                        // net profit left after the stress test
   double pfAfterRemove;                         // profit factor after the stress test; -1.0 means no losing trades left
   int    removedCount;                          // number of winning trades removed by the stress test
   double concScore;                             // concentration dimension of the score, 0..100
   double consistScore;                          // day-consistency dimension of the score, 0..100
   double survScore;                             // outlier-dependence dimension of the score, 0..100
   double composite;                             // weighted composite score, 0..100
   string grade;                                 // letter grade from A+ to F
  };

//--- Per-day aggregation: one calendar day and its summed result
struct SDay
  {
   string d;                                     // the date, as text
   double pnl;                                   // the day's total profit or loss
  };

//--- Globals
double g_profit[];                               // result of each loaded trade
string g_date[];                                 // date of each loaded trade
int    g_n = 0;                                  // number of trades currently loaded

//+------------------------------------------------------------------+
//| Read a Date,Profit file (one row per closing deal)               |
//| Read as text and split each row on the comma, which tolerates    |
//| blank lines and stray spaces better than field-by-field reading. |
//+------------------------------------------------------------------+
bool LoadTrades(string filename, double &profit[], string &dates[])
  {
   int handle = FileOpen(filename, FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Could not open %s. Error: %d", filename, GetLastError());
      return false;
     }

   int  count = 0;
   bool firstLine = true;
   while(!FileIsEnding(handle))
     {
      //--- Read one whole line and trim the surrounding whitespace
      string row = FileReadString(handle);
      StringTrimLeft(row);
      StringTrimRight(row);

      if(firstLine)                   // the first line is the header
        {
         firstLine = false;
         continue;
        }
      if(row == "")                   // skip blank lines
         continue;

      //--- Split "Date,Profit" into its two fields
      string parts[];
      if(StringSplit(row, ',', parts) < 2)
         continue;                    // not enough columns: skip the row
      StringTrimLeft(parts[0]);
      StringTrimRight(parts[0]);

      if(StringToTime(parts[0]) <= 0) // skip rows whose date does not parse
         continue;
      double value = StringToDouble(parts[1]);

      //--- Store the parsed trade
      count++;
      ArrayResize(profit, count, 512);
      ArrayResize(dates, count, 512);
      profit[count - 1] = value;
      dates[count - 1]  = parts[0];
     }

   FileClose(handle);
   return (count > 0);
  }

//+------------------------------------------------------------------+
//| Gini coefficient of the winning trades (gain concentration)      |
//+------------------------------------------------------------------+
double GiniWinners(const double &profit[], int n)
  {
   //--- Collect the winning trades into w[]
   double w[];
   int m = 0;
   for(int i = 0; i < n; i++)
      if(profit[i] > 0.0)
        {
         m++;
         ArrayResize(w, m);
         w[m - 1] = profit[i];
        }
   if(m < 2)
      return 0.0;                         // need at least two winners to measure inequality

   ArraySort(w);                          // ascending order, required by the formula

   //--- Sum of the winners and the rank-weighted sum
   double sumw = 0.0;
   for(int i = 0; i < m; i++)
      sumw += w[i];
   if(sumw <= 0.0)
      return 0.0;

   double weighted = 0.0;
   for(int i = 0; i < m; i++)
      weighted += (double)(i + 1) * w[i]; // rank (1..m) times value

   //--- Standard Gini formula for sorted positive values
   return (2.0 * weighted) / (m * sumw) - (double)(m + 1) / m;
  }

//+------------------------------------------------------------------+
//| Share of net profit produced by the N largest trades (percent)   |
//+------------------------------------------------------------------+
double TopNShareOfNet(const double &profit[], int n, int N, double net)
  {
   if(net <= 0.0 || n <= 0)
      return 0.0; // the share needs a positive net profit
   //--- Work on a sorted copy so the original order is preserved
   double a[];
   ArrayResize(a, n);
   ArrayCopy(a, profit);
   ArraySort(a);  // ascending: the largest trades sit at the end

   //--- Add up the N largest results, reading from the end
   double s = 0.0;
   int    cnt = 0;
   for(int i = n - 1; i >= 0 && cnt < N; i--)
     {
      s += a[i];
      cnt++;
     }
   return s / net * 100.0;
  }

//+------------------------------------------------------------------+
//| Share of gross profit produced by the N largest winners (pct)    |
//| Bounded 0..100%, unlike the net version which can exceed 100%.   |
//+------------------------------------------------------------------+
double TopNShareOfGross(const double &profit[], int n, int N, double grossProfit)
  {
   if(grossProfit <= 0.0 || n <= 0)
      return 0.0;
   double a[];
   ArrayResize(a, n);
   ArrayCopy(a, profit);
   ArraySort(a); // ascending, largest at the end

   //--- Sum only the positive trades among the N largest
   double s = 0.0;
   int    cnt = 0;
   for(int i = n - 1; i >= 0 && cnt < N; i--)
     {
      if(a[i] > 0.0)
         s += a[i];
      cnt++;
     }
   return s / grossProfit * 100.0;
  }

//+------------------------------------------------------------------+
//| Net profit and profit factor after removing the K best winners   |
//| Only the K largest strictly-positive trades are removed; all     |
//| losers stay, so this is a one-sided outlier-dependence test.     |
//+------------------------------------------------------------------+
double NetAfterRemoveTopWinners(const double &profit[], int n, int K, double &pfAfter)
  {
   double a[];
   ArrayResize(a, n);
   ArrayCopy(a, profit);
   ArraySort(a);                          // ascending; largest values are at the end

   //--- Walk from the largest down, dropping the first K winners
   int    removed = 0;
   double gp = 0.0, gl = 0.0;
   for(int i = n - 1; i >= 0; i--)
     {
      if(a[i] > 0.0 && removed < K)       // drop this winner and move on
        {
         removed++;
         continue;
        }
      if(a[i] > 0.0)                      // keep the remaining winners
         gp += a[i];
      else if(a[i] < 0.0)                 // and all of the losers
         gl += -a[i];
     }
   pfAfter = (gl > 0.0) ? gp / gl : -1.0; // -1 means no losing trades remain
   return gp - gl;
  }

//+------------------------------------------------------------------+
//| Aggregate trades by calendar day                                 |
//| Simple O(n*d) aggregation; fine for the typical few-hundred to   |
//| few-thousand trades. For very large sets, sort by date first.    |
//+------------------------------------------------------------------+
int BuildDays(const double &profit[], const string &dates[], int n, SDay &days[])
  {
   int nd = 0;
   ArrayResize(days, 0);
   for(int i = 0; i < n; i++)
     {
      //--- Find the day this trade belongs to, if it already exists
      int idx = -1;
      for(int k = 0; k < nd; k++)
         if(days[k].d == dates[i])
           {
            idx = k;
            break;
           }
      if(idx < 0)                 // first trade of a new day: add it
        {
         nd++;
         ArrayResize(days, nd);
         days[nd - 1].d   = dates[i];
         days[nd - 1].pnl = 0.0;
         idx = nd - 1;
        }
      days[idx].pnl += profit[i]; // accumulate the day's result
     }
   return nd;
  }

//+------------------------------------------------------------------+
//| Print the concentration profile (cumulative share of winners)    |
//+------------------------------------------------------------------+
void PrintConcentrationProfile(const double &profit[], int n, double grossProfit)
  {
   //--- Collect and sort the winning trades
   double w[];
   int m = 0;
   for(int i = 0; i < n; i++)
      if(profit[i] > 0.0)
        {
         m++;
         ArrayResize(w, m);
         w[m - 1] = profit[i];
        }
   if(m < 1 || grossProfit <= 0.0)
     {
      Print("No winning trades to profile.");
      return;
     }
   ArraySort(w); // ascending; reverse-read for the largest first

   //--- For each tier, sum the largest "take" winners and show their share
   double tiers[] = {1.0, 5.0, 10.0, 25.0, 50.0, 100.0};
   Print("Concentration profile (share of gross profit from the largest winners):");
   for(int t = 0; t < ArraySize(tiers); t++)
     {
      int take = (int)MathCeil(m * tiers[t] / 100.0);
      if(take < 1)
         take = 1;
      if(take > m)
         take = m;
      double s = 0.0;
      for(int i = m - 1; i >= m - take; i--)
         s += w[i];
      PrintFormat("  Top %5.0f%% of winners  ->  %5.1f%% of gross profit", tiers[t], s / grossProfit * 100.0);
     }
  }

//+------------------------------------------------------------------+
//| Generate a synthetic per-trade file so the script runs by itself |
//+------------------------------------------------------------------+
bool EnsureSampleFile(string filename)
  {
   int handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Could not create sample %s. Error: %d", filename, GetLastError());
      return false;
     }

   FileWriteString(handle, "Date,Profit\n");
   MathSrand(20260601);                                          // fixed seed: the demo is reproducible

   int      trades    = 200;
   datetime t         = StringToTime("2026.01.05");
   int      todayLeft = 1 + (int)(MathRand() % 3);
   int      bigIdx[]  = {12, 44, 76, 108, 140, 175};             // a few larger winners, spread out

   for(int i = 0; i < trades; i++)
     {
      //--- Decide whether this trade is one of the engineered big winners
      double profit;
      bool   isBig = false;
      for(int b = 0; b < ArraySize(bigIdx); b++)
         if(bigIdx[b] == i)
           {
            isBig = true;
            break;
           }

      if(isBig)
         profit = 340.0 + (i % 3) * 15.0;                        // larger winner
      else if((double)MathRand() / 32767.0 < 0.58)
         profit = 25.0 + (double)MathRand() / 32767.0 * 70.0;    // ordinary winner
      else
         profit = -(30.0 + (double)MathRand() / 32767.0 * 50.0); // loser

      //--- Write the row and advance the calendar by 1-3 trades per day
      MqlDateTime dt;
      TimeToStruct(t, dt);
      string ds = StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day);
      FileWriteString(handle, StringFormat("%s,%.2f\n", ds, profit));

      todayLeft--;
      if(todayLeft <= 0)
        {
         t += 86400;
         todayLeft = 1 + (int)(MathRand() % 3);
        }
     }

   FileClose(handle);
   PrintFormat("Sample file %s created with %d trades.", filename, trades);
   return true;
  }

//+------------------------------------------------------------------+
//| Build the full report from the loaded trades                     |
//+------------------------------------------------------------------+
void BuildReport(const double &profit[], const string &dates[], int n, SReport &r)
  {
   //--- Tally winners, losers, flats and the gross figures
   r.nTrades     = n;
   r.nWinners    = 0;
   r.nLosers     = 0;
   r.nFlat       = 0;
   r.grossProfit = 0.0;
   r.grossLoss   = 0.0;
   for(int i = 0; i < n; i++)
     {
      if(profit[i] > 0.0)
        {
         r.nWinners++;
         r.grossProfit += profit[i];
        }
      else if(profit[i] < 0.0)
        {
         r.nLosers++;
         r.grossLoss += -profit[i];
        }
      else
         r.nFlat++;
     }

   //--- Core ratios
   r.netProfit    = r.grossProfit - r.grossLoss;
   r.profitFactor = (r.grossLoss > 0.0) ? r.grossProfit / r.grossLoss : -1.0; // -1 = undefined
   r.winRate      = (n > 0) ? 100.0 * r.nWinners / n : 0.0;

   //--- Concentration measures
   r.gini           = GiniWinners(profit, n);
   r.topNShare      = TopNShareOfNet(profit, n, InpTopN, r.netProfit);
   r.topNShareGross = TopNShareOfGross(profit, n, InpTopN, r.grossProfit);

   //--- Day aggregation and the largest profitable day
   SDay days[];
   int nd = BuildDays(profit, dates, n, days);
   double bestDay = 0.0;
   r.bestDay = "-";
   for(int k = 0; k < nd; k++)
      if(days[k].pnl > bestDay)
        {
         bestDay   = days[k].pnl;
         r.bestDay = days[k].d;
        }
   r.bestDayShare = (r.netProfit > 0.0) ? bestDay / r.netProfit * 100.0 : 0.0;

   //--- Outlier-dependence stress test: remove the best InpRemovePct% of winners
   r.removedCount = (InpRemovePct <= 0.0) ? 0 : (int)MathMax(1.0, MathCeil(r.nWinners * InpRemovePct / 100.0));
   if(r.removedCount > 0)
     {
      r.netAfterRemove = NetAfterRemoveTopWinners(profit, n, r.removedCount, r.pfAfterRemove);
      r.survivalRatio  = (r.netProfit > 0.0) ? r.netAfterRemove / r.netProfit : 0.0;
     }
   else                                                                       // removing nothing leaves the figures unchanged
     {
      r.netAfterRemove = r.netProfit;
      r.pfAfterRemove  = r.profitFactor;
      r.survivalRatio  = 1.0;
     }

   //--- Dimension scores (higher means broader, more repeatable profit). Factors are inputs.
   r.concScore    = MathMax(0.0, 100.0 - MathMax(0.0, r.topNShare - 25.0) * InpConcFactor);
   r.consistScore = MathMax(0.0, 100.0 - MathMax(0.0, r.bestDayShare - InpConsistencyLimit) * InpConsistFactor);
   r.survScore    = MathMax(0.0, MathMin(100.0, r.survivalRatio * 100.0));

   //--- Normalize the weights so the result does not depend on their sum
   double wc = MathMax(0.0, InpWeightConc);
   double wk = MathMax(0.0, InpWeightConsist);
   double ws = MathMax(0.0, InpWeightSurv);
   double wsum = wc + wk + ws;
   if(wsum <= 0.0)
     {
      wc = 0.40; wk = 0.35; ws = 0.25; wsum = 1.0;
      Print("Warning: weights were non-positive; reverting to the 0.40 / 0.35 / 0.25 default.");
     }
   wc /= wsum; wk /= wsum; ws /= wsum;

   //--- Composite score and its letter grade
   r.composite = r.concScore * wc + r.consistScore * wk + r.survScore * ws;

   if(r.composite >= 90)      r.grade = "A+";
   else if(r.composite >= 80) r.grade = "A";
   else if(r.composite >= 70) r.grade = "B";
   else if(r.composite >= 60) r.grade = "C";
   else if(r.composite >= 50) r.grade = "D";
   else                       r.grade = "F";
  }

//+------------------------------------------------------------------+
//| Print a profit factor, handling the undefined (no-loss) case     |
//+------------------------------------------------------------------+
void PrintProfitFactor(string label, double pf)
  {
   if(pf < 0.0)
      PrintFormat("%sn/a (no losing trades)", label);
   else
      PrintFormat("%s%.2f", label, pf);
  }

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("========================================");
   Print("  PROFIT CONCENTRATION ANALYZER v1.1");
   Print("  Where does the profit actually come from?");
   Print("========================================");

   //--- Load the trades, or build and load a sample set if none is found
   if(!LoadTrades(InpFileName, g_profit, g_date))
     {
      Print(">> File not found or empty. Generating a sample set...");
      if(!EnsureSampleFile(InpFileName))
        {
         Alert("Could not create the sample file.");
         return;
        }
      if(!LoadTrades(InpFileName, g_profit, g_date))
        {
         Alert("Could not load the sample file.");
         return;
        }
     }

   g_n = ArraySize(g_profit);
   if(g_n < 20)           // too few trades for the shares to be meaningful
     {
      Alert("At least 20 trades are required (results are more reliable with 100+).");
      return;
     }

   SReport r;
   BuildReport(g_profit, g_date, g_n, r);

   Print("\nNote: this works at the closing-deal level. A position closed in several");
   Print("deals (partial exits) contributes several rows; it is not full-position PnL.");

   if(r.netProfit <= 0.0) // the shares need a profitable set to make sense
     {
      Print("\nNet profit is not positive; the concentration shares need a profitable set.");
      PrintFormat("Net: %.2f | Trades: %d", r.netProfit, r.nTrades);
      return;
     }

   //--- Concentration profile
   Print("");
   PrintConcentrationProfile(g_profit, g_n, r.grossProfit);

   //--- Outlier-dependence stress test
   PrintFormat("\n=== OUTLIER-DEPENDENCE STRESS TEST (remove best %.0f%% of winners = %d trades) ===",
               InpRemovePct, r.removedCount);
   PrintFormat("  Net profit before: %.2f", r.netProfit);
   PrintProfitFactor("  Profit factor before: ", r.profitFactor);
   PrintFormat("  Net profit after:  %.2f", r.netAfterRemove);
   PrintProfitFactor("  Profit factor after:  ", r.pfAfterRemove);
   PrintFormat("  Remaining profit:  %.1f%% of the original net", r.survivalRatio * 100.0);
   Print("  (One-sided: only the best winners are removed, so the profit factor is meant to fall.)");

   //--- Metrics
   Print("\n=== METRICS ===");
   PrintFormat("  Trades:            %d  (%d winners, %d losers, %d flat)", r.nTrades, r.nWinners, r.nLosers, r.nFlat);
   PrintFormat("  Win rate:          %.1f%%", r.winRate);
   PrintFormat("  Net profit:        %.2f", r.netProfit);
   PrintProfitFactor("  Profit factor:     ", r.profitFactor);
   PrintFormat("  Gini (winners):    %.3f", r.gini);
   PrintFormat("  Top-%d trades:      %.1f%% of net profit  /  %.1f%% of gross profit",
               InpTopN, r.topNShare, r.topNShareGross);
   PrintFormat("  Best day (%s): %.1f%% of net profit", r.bestDay, r.bestDayShare);
   PrintFormat("  Consistency limit: %.1f%%  ->  %s", InpConsistencyLimit,
               (r.bestDayShare <= InpConsistencyLimit ? "PASS" : "FAIL"));

   //--- Score
   Print("\n========================================");
   Print("  CONCENTRATION & CONSISTENCY SCORE (heuristic)");
   Print("========================================");
   PrintFormat("  Concentration score: %.1f / 100", r.concScore);
   PrintFormat("  Consistency score:   %.1f / 100", r.consistScore);
   PrintFormat("  Survival score:      %.1f / 100", r.survScore);
   Print("----------------------------------------");
   PrintFormat("  COMPOSITE:           %.1f / 100", r.composite);
   PrintFormat("  GRADE:               %s", r.grade);
   Print(" (Heuristic for ranking and quick comparison, not a statistically validated measure.)");
   Print("========================================");

   //--- Recommendations: each one is driven by a specific weakness
   Print("\n--- RECOMMENDATIONS ---");
   if(r.topNShare >= 40.0)
      PrintFormat(">> The top %d trades produce %.0f%% of the net profit. Confirm the edge does not rest on a few exceptional trades.",
                  InpTopN, r.topNShare);
   if(r.bestDayShare > InpConsistencyLimit)
      PrintFormat(">> One day is %.0f%% of total profit, above the %.0f%% limit. This would fail a consistency rule.",
                  r.bestDayShare, InpConsistencyLimit);
   if(r.survivalRatio < 0.45)
      Print("!! Removing the best few winners erases more than half the profit. Treat the result as outlier-dependent.");
   if(r.gini >= 0.6)
      Print(">> Gains are highly unequal across trades. A handful of winners carries the system.");
   if(r.composite >= 80.0)
      Print("++ Profit is well distributed across trades and days. The edge looks broad-based.");

   Print("\nAnalysis complete.");
  }
//+------------------------------------------------------------------+
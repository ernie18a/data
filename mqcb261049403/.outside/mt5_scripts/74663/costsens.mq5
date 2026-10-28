//+------------------------------------------------------------------+
//|                                                     CostSens.mq5 |
//|                Execution Cost Sensitivity Analyzer (MetaTrader 5)|
//|        Reads a per-closing-deal result file and measures how much|
//|        execution cost the edge can absorb: the breakeven cost per|
//|        deal, the cushion over an assumed cost, the profit factor |
//|        at that cost, and how many winners it erases, combined    |
//|        into a heuristic robustness-to-cost score.                |
//+------------------------------------------------------------------+
#property copyright "Cristian David Castillo Arrieta"
#property version   "1.00"
#property script_show_inputs
#property description "Reads a per-closing-deal result file and measures how robust the edge is to execution costs."

//--- Input parameters
input string InpFileName      = "Trades.csv"; // CSV file: Date,Profit,Volume (one row per closing deal)
input double InpCostPerLot    = 12.0;         // Assumed round-turn cost per 1.0 lot (spread + commission + slippage)
input double InpCostFixed     = 0.0;          // Assumed fixed cost per deal (e.g. minimum commission), account currency
input double InpCushionTarget = 3.0;          // Cushion (x assumed cost) that scores full marks on the cushion dimension
input double InpThinMult      = 1.0;          // A winner is "thin" if its result <= InpThinMult x its assumed cost
input double InpErosionTol    = 0.20;         // Win-erosion tolerance: this fraction of winners erased scores zero
input double InpWeightCushion = 0.45;         // Weight: cost-cushion dimension
input double InpWeightPF       = 0.30;        // Weight: profit-factor-resilience dimension
input double InpWeightErosion  = 0.25;        // Weight: win-erosion dimension

//--- Aggregated report: every figure the analyzer prints lives here
struct SReport
  {
   int    nTrades;                            // total closing deals loaded from the file
   int    nWinners;                           // deals with a positive result, before cost
   int    nLosers;                            // deals with a negative result, before cost
   int    nFlat;                              // deals with exactly zero result
   double grossProfit;                        // sum of the winning deals, before cost
   double grossLoss;                          // sum of the losing deals, before cost, as a positive number
   double netProfit;                          // gross profit minus gross loss, before cost
   double profitFactor;                       // gross profit / gross loss; -1.0 means undefined (no losing deals)
   double winRate;                            // winners as a percentage of all deals
   double sumVol;                             // total traded volume across all deals (lots)
   double avgEdge;                            // net profit per deal (net / nTrades)
   double assumedCost;                        // total assumed cost across all deals (the C1 baseline)
   double avgCost;                            // assumed cost per deal (assumedCost / nTrades)
   double breakeven;                          // breakeven cost per deal that zeroes the net (equals avgEdge)
   double cushion;                            // breakeven multiplier: the net reaches zero at cushion x the assumed cost
   double netAtCost;                          // net profit left at the assumed cost level
   double pfAtCost;                           // profit factor at the assumed cost; -1.0 means no losing deals left
   double retention;                          // netAtCost / netProfit (0..1)
   int    erased;                             // winners that turn into non-winners at the assumed cost
   double erosionRate;                        // erased / nWinners (0..1)
   double thinShare;                          // share of gross profit from winners within InpThinMult x their cost
   double cushionScore;                       // cost-cushion dimension of the score, 0..100
   double pfScore;                            // profit-factor-resilience dimension of the score, 0..100
   double erosionScore;                       // win-erosion dimension of the score, 0..100
   double composite;                          // weighted composite score, 0..100
   string grade;                              // letter grade from A+ to F
  };

//--- Globals
double g_profit[];                            // result of each loaded closing deal
double g_vol[];                               // volume (lots) of each loaded closing deal
string g_date[];                              // date of each loaded closing deal
int    g_n = 0;                               // number of deals currently loaded

//+------------------------------------------------------------------+
//| Read a Date,Profit,Volume file (one row per closing deal)        |
//| Read as text and split each row on the comma, which tolerates    |
//| blank lines and stray spaces better than field-by-field reading. |
//| The Volume column is optional: if it is missing or unparseable,  |
//| the volume defaults to 1.0, so a plain Date,Profit file also     |
//| works (the cost is then applied per deal rather than per lot).   |
//+------------------------------------------------------------------+
bool LoadTrades(string filename, double &profit[], double &vol[], string &dates[])
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
      //--- In FILE_TXT mode, FileReadString returns one line; trim its whitespace
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

      //--- Split "Date,Profit,Volume" into its fields
      string parts[];
      if(StringSplit(row, ',', parts) < 2)
         continue;                    // need at least a date and a result
      StringTrimLeft(parts[0]);
      StringTrimRight(parts[0]);

      if(StringToTime(parts[0]) <= 0) // skip rows whose date does not parse
         continue;
      double value = StringToDouble(parts[1]);

      //--- The volume is optional; default to 1.0 when absent or non-positive
      double v = 1.0;
      if(ArraySize(parts) >= 3)
        {
         double parsed = StringToDouble(parts[2]);
         if(parsed > 0.0)
            v = parsed;
        }

      //--- Store the parsed deal
      count++;
      ArrayResize(profit, count, 512);
      ArrayResize(vol,    count, 512);
      ArrayResize(dates,  count, 512);
      profit[count - 1] = value;
      vol[count - 1]    = v;
      dates[count - 1]  = parts[0];
     }

   FileClose(handle);
   return (count > 0);
  }

//+------------------------------------------------------------------+
//| Net profit and profit factor at a cost multiplier                |
//| Each deal pays mult x (InpCostFixed + InpCostPerLot x volume).   |
//| Returns the net after cost; writes the profit factor to pfOut    |
//| (-1.0 when no losing deals remain after the cost is applied).    |
//+------------------------------------------------------------------+
double NetAtMultiplier(const double &profit[], const double &vol[], int n, double mult, double &pfOut)
  {
   double gp = 0.0, gl = 0.0;
   for(int i = 0; i < n; i++)
     {
      //--- The cost charged to this deal at the requested multiplier
      double cost = mult * (InpCostFixed + InpCostPerLot * vol[i]);
      double net  = profit[i] - cost;
      if(net > 0.0)
         gp += net;                     // a deal that is still a winner after cost
      else if(net < 0.0)
         gl += -net;                    // a deal that is a loser after cost
     }
   pfOut = (gl > 0.0) ? gp / gl : -1.0; // -1 means no losing deals remain
   return gp - gl;
  }

//+------------------------------------------------------------------+
//| Count the winners erased at a given cost multiplier              |
//| A winner is erased when its result no longer covers its cost.    |
//+------------------------------------------------------------------+
int CountErased(const double &profit[], const double &vol[], int n, double mult)
  {
   int erased = 0;
   for(int i = 0; i < n; i++)
     {
      if(profit[i] <= 0.0)        // only deals that were winners can be erased
         continue;
      double cost = mult * (InpCostFixed + InpCostPerLot * vol[i]);
      if(profit[i] - cost <= 0.0) // the cost wipes out the gain
         erased++;
     }
   return erased;
  }

//+------------------------------------------------------------------+
//| Share of gross profit held by "thin" winners                     |
//| A thin winner sits within InpThinMult x its assumed cost, so a   |
//| small rise in cost can erase it; this share is the gross profit  |
//| that lives close to the cost line.                               |
//+------------------------------------------------------------------+
double ThinWinnerShare(const double &profit[], const double &vol[], int n, double grossProfit)
  {
   if(grossProfit <= 0.0)
      return 0.0;
   double thin = 0.0;
   for(int i = 0; i < n; i++)
     {
      if(profit[i] <= 0.0)
         continue;
      double cost = InpCostFixed + InpCostPerLot * vol[i];
      if(profit[i] <= InpThinMult * cost)
         thin += profit[i];
     }
   return thin / grossProfit * 100.0;
  }

//+------------------------------------------------------------------+
//| Print the cost-sensitivity curve as a small ASCII chart          |
//| Each row is a multiple of the assumed cost; the bar is scaled to |
//| the net profit at zero cost, so the decay is easy to read.       |
//+------------------------------------------------------------------+
void PrintCostCurve(const double &profit[], const double &vol[], int n, double netZero)
  {
   double mults[] = {0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0};
   Print("Cost-sensitivity curve (net profit as the assumed cost is scaled up):");
   Print("  xCost   Cost/deal       Net   ProfitFactor");
   for(int k = 0; k < ArraySize(mults); k++)
     {
      double pf;
      double net     = NetAtMultiplier(profit, vol, n, mults[k], pf);
      double perDeal = mults[k] * (InpCostFixed + InpCostPerLot * (n > 0 ? AvgVolume(vol, n) : 0.0));
      int    bars    = (netZero > 0.0) ? (int)MathRound(40.0 * MathMax(net, 0.0) / netZero) : 0;
      string bar = "";
      for(int b = 0; b < bars; b++)
         bar += "#";
      string pfText = (pf < 0.0) ? "n/a" : StringFormat("%.2f", pf);
      PrintFormat("  %4.1f   %8.2f   %8.2f   %s  |%s", mults[k], perDeal, net, pfText, bar);
     }
  }

//+------------------------------------------------------------------+
//| Average volume across the loaded deals (lots)                    |
//+------------------------------------------------------------------+
double AvgVolume(const double &vol[], int n)
  {
   if(n <= 0)
      return 0.0;
   double s = 0.0;
   for(int i = 0; i < n; i++)
      s += vol[i];
   return s / n;
  }

//+------------------------------------------------------------------+
//| Generate a synthetic per-deal file so the script runs by itself  |
//| The seed is fixed, so the demo is reproducible. The set is shaped|
//| to land on a believable middle grade rather than a perfect pass. |
//+------------------------------------------------------------------+
bool EnsureSampleFile(string filename)
  {
   int handle = FileOpen(filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Could not create sample %s. Error: %d", filename, GetLastError());
      return false;
     }

   FileWriteString(handle, "Date,Profit,Volume\n");
   MathSrand(20260601);                                               // fixed seed: the demo is reproducible

   int      trades    = 200;
   datetime t         = StringToTime("2026.01.05");
   int      todayLeft = 1 + (int)(MathRand() % 3);                    // 1-3 deals on the first day
   int      bigIdx[]  = {17, 53, 96, 134, 178};                       // a few large winners, spread out
   int      thinIdx[] = {8, 27, 49, 70, 88, 110, 129, 150, 171, 190}; // small winners costs can erase

   for(int i = 0; i < trades; i++)
     {
      //--- Volume first, so the call order stays stable across branches
      double vol = 0.10 + (MathRand() % 6) * 0.10;                    // 0.10..0.60 lots

      //--- Decide what kind of deal this is
      bool isBig = false, isThin = false;
      for(int b = 0; b < ArraySize(bigIdx); b++)
         if(bigIdx[b] == i)
           {
            isBig = true;
            break;
           }
      if(!isBig)
         for(int b = 0; b < ArraySize(thinIdx); b++)
            if(thinIdx[b] == i)
              {
               isThin = true;
               break;
              }

      double profit;
      if(isBig)
         profit = 110.0 + (i % 4) * 25.0;                             // engineered large winner
      else if(isThin)
         profit = 1.0 + (MathRand() % 5);                             // small winner the cost can erase
      else
        {
         double u = (double)MathRand() / 32767.0;
         if(u < 0.58)
            profit = 15.0 + (double)MathRand() / 32767.0 * 66.0;      // ordinary winner
         else
            profit = -(20.0 + (double)MathRand() / 32767.0 * 52.0);   // loser
        }

      //--- Write the row and advance the calendar by 1-3 deals per day
      MqlDateTime dt;
      TimeToStruct(t, dt);
      string ds = StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day);
      FileWriteString(handle, StringFormat("%s,%.2f,%.2f\n", ds, profit, vol));

      todayLeft--;
      if(todayLeft <= 0)
        {
         t += 86400;
         todayLeft = 1 + (int)(MathRand() % 3);
        }
     }

   FileClose(handle);
   PrintFormat("Sample file %s created with %d deals.", filename, trades);
   return true;
  }

//+------------------------------------------------------------------+
//| Build the full report from the loaded deals                      |
//+------------------------------------------------------------------+
void BuildReport(const double &profit[], const double &vol[], int n, SReport &r)
  {
   //--- Tally winners, losers, flats and the gross figures (before cost)
   r.nTrades     = n;
   r.nWinners    = 0;
   r.nLosers     = 0;
   r.nFlat       = 0;
   r.grossProfit = 0.0;
   r.grossLoss   = 0.0;
   r.sumVol      = 0.0;
   for(int i = 0; i < n; i++)
     {
      r.sumVol += vol[i];
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

   //--- Core figures, all before cost
   r.netProfit    = r.grossProfit - r.grossLoss;
   r.profitFactor = (r.grossLoss > 0.0) ? r.grossProfit / r.grossLoss : -1.0; // -1 = undefined
   r.winRate      = (n > 0) ? 100.0 * r.nWinners / n : 0.0;

   //--- The assumed cost baseline and the per-deal edge
   r.assumedCost = 0.0;
   for(int i = 0; i < n; i++)
      r.assumedCost += InpCostFixed + InpCostPerLot * vol[i];
   r.avgCost   = (n > 0) ? r.assumedCost / n : 0.0;
   r.avgEdge   = (n > 0) ? r.netProfit / n : 0.0;
   r.breakeven = r.avgEdge;                                                   // per-deal cost that zeroes the net

   //--- The cushion: net profit reaches zero at cushion x the assumed cost
   r.cushion = (r.assumedCost > 0.0) ? r.netProfit / r.assumedCost : 0.0;

   //--- The net and the profit factor at the assumed cost (multiplier 1.0)
   r.netAtCost  = NetAtMultiplier(profit, vol, n, 1.0, r.pfAtCost);
   r.retention  = (r.netProfit > 0.0) ? r.netAtCost / r.netProfit : 0.0;

   //--- Win erosion and the thin-winner share at the assumed cost
   r.erased      = CountErased(profit, vol, n, 1.0);
   r.erosionRate = (r.nWinners > 0) ? (double)r.erased / r.nWinners : 0.0;
   r.thinShare   = ThinWinnerShare(profit, vol, n, r.grossProfit);

   //--- Dimension scores (higher means more robust to cost). Factors are inputs.
   double ct = MathMax(1.0001, InpCushionTarget);                             // guard the denominator
   r.cushionScore = MathMax(0.0, MathMin(100.0, 100.0 * (r.cushion - 1.0) / (ct - 1.0)));

   if(r.profitFactor < 0.0)                                                   // no losers at all: fully resilient
      r.pfScore = 100.0;
   else if(r.profitFactor <= 1.0)                                             // not profitable even before cost
      r.pfScore = 0.0;
   else if(r.pfAtCost < 0.0)                                                  // no losers left after cost
      r.pfScore = 100.0;
   else
      r.pfScore = MathMax(0.0, MathMin(100.0, 100.0 * (r.pfAtCost - 1.0) / (r.profitFactor - 1.0)));

   double et = MathMax(0.0001, InpErosionTol);                                // guard the denominator
   r.erosionScore = MathMax(0.0, MathMin(100.0, 100.0 * (1.0 - r.erosionRate / et)));

   //--- Normalize the weights so the result does not depend on their sum
   double wc = MathMax(0.0, InpWeightCushion);
   double wp = MathMax(0.0, InpWeightPF);
   double we = MathMax(0.0, InpWeightErosion);
   double wsum = wc + wp + we;
   if(wsum <= 0.0)
     {
      wc = 0.45; wp = 0.30; we = 0.25; wsum = 1.0;
      Print("Warning: weights were non-positive; reverting to the 0.45 / 0.30 / 0.25 default.");
     }
   wc /= wsum; wp /= wsum; we /= wsum;

   //--- Composite score and its letter grade
   r.composite = r.cushionScore * wc + r.pfScore * wp + r.erosionScore * we;

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
      PrintFormat("%sn/a (no losing deals)", label);
   else
      PrintFormat("%s%.2f", label, pf);
  }

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("========================================");
   Print("  EXECUTION COST SENSITIVITY ANALYZER v1.0");
   Print("  How much execution cost can the edge absorb?");
   Print("========================================");

   //--- Load the deals, or build and load a sample set if none is found
   if(!LoadTrades(InpFileName, g_profit, g_vol, g_date))
     {
      Print(">> File not found or empty. Generating a sample set...");
      if(!EnsureSampleFile(InpFileName))
        {
         Alert("Could not create the sample file.");
         return;
        }
      if(!LoadTrades(InpFileName, g_profit, g_vol, g_date))
        {
         Alert("Could not load the sample file.");
         return;
        }
     }

   g_n = ArraySize(g_profit);
   if(g_n < 20)           // too few deals for the figures to be meaningful
     {
      Alert("At least 20 deals are required (results are more reliable with 100+).");
      return;
     }

   SReport r;
   BuildReport(g_profit, g_vol, g_n, r);

   Print("\nNote: this works at the closing-deal level. A position closed in several");
   Print("deals (partial exits) is several rows, and each exit deal pays its own cost.");

   if(r.netProfit <= 0.0) // the analysis needs a profitable set to make sense
     {
      Print("\nNet profit is not positive before cost; the cost analysis needs a profitable set.");
      PrintFormat("Net: %.2f | Deals: %d", r.netProfit, r.nTrades);
      return;
     }

   //--- Headline figures
   Print("\n=== STRATEGY (before added cost) ===");
   PrintFormat("  Deals:           %d  (%d winners, %d losers, %d flat)", r.nTrades, r.nWinners, r.nLosers, r.nFlat);
   PrintFormat("  Win rate:        %.1f%%", r.winRate);
   PrintFormat("  Net profit:      %.2f", r.netProfit);
   PrintProfitFactor("  Profit factor:   ", r.profitFactor);
   PrintFormat("  Total volume:    %.2f lots  (avg %.2f per deal)", r.sumVol, AvgVolume(g_vol, g_n));
   PrintFormat("  Edge per deal:   %.2f", r.avgEdge);

   //--- The assumed cost and the cost curve
   PrintFormat("\n=== ASSUMED COST: %.2f per lot + %.2f fixed (%.2f per deal on average) ===",
               InpCostPerLot, InpCostFixed, r.avgCost);
   Print("");
   PrintCostCurve(g_profit, g_vol, g_n, r.netProfit);

   //--- The cost sensitivity results
   Print("\n=== COST SENSITIVITY ===");
   PrintFormat("  Breakeven cost per deal: %.2f  (the edge per deal)", r.breakeven);
   PrintFormat("  Cushion:                 %.2fx the assumed cost", r.cushion);
   PrintFormat("  Net at the assumed cost: %.2f  (%.0f%% of the original net)", r.netAtCost, r.retention * 100.0);
   PrintProfitFactor("  Profit factor at cost:   ", r.pfAtCost);
   PrintFormat("  Winners erased at cost:  %d of %d  (%.1f%%)", r.erased, r.nWinners, r.erosionRate * 100.0);
   PrintFormat("  Thin-winner gross share: %.1f%%", r.thinShare);
   Print("  (One-sided: only cost rises, so the net and the profit factor are meant to fall.)");

   //--- Score
   Print("\n========================================");
   Print("  COST-ROBUSTNESS SCORE (heuristic)");
   Print("========================================");
   PrintFormat("  Cushion score:    %.1f / 100", r.cushionScore);
   PrintFormat("  PF-resilience:    %.1f / 100", r.pfScore);
   PrintFormat("  Win-erosion:      %.1f / 100", r.erosionScore);
   Print("----------------------------------------");
   PrintFormat("  COMPOSITE:        %.1f / 100", r.composite);
   PrintFormat("  GRADE:            %s", r.grade);
   Print(" (Heuristic for ranking and quick comparison, not a statistically validated measure.)");
   Print("========================================");

   //--- Recommendations: each one is driven by a specific weakness
   Print("\n--- RECOMMENDATIONS ---");
   if(r.cushion < 2.0)
      PrintFormat("!! The edge disappears below 2x the assumed cost (cushion %.2fx). Treat live results with great caution.", r.cushion);
   else if(r.cushion < 3.0)
      PrintFormat(">> The cushion is only %.2fx the assumed cost. A modest rise in spread or slippage materially cuts the result; build in margin before trading live.", r.cushion);
   if(r.profitFactor > 0.0 && r.pfAtCost > 0.0 && r.pfAtCost < 1.4)
      PrintFormat(">> At the assumed cost the profit factor falls to %.2f. The edge is thin once realistic costs are paid.", r.pfAtCost);
   if(r.retention < 0.70)
      PrintFormat(">> Realistic costs erase %.0f%% of the net profit (%.2f -> %.2f).", (1.0 - r.retention) * 100.0, r.netProfit, r.netAtCost);
   if(r.erosionRate >= 0.10)
      PrintFormat(">> %.0f%% of winning deals turn into losers at the assumed cost. The result leans on marginal winners.", r.erosionRate * 100.0);
   if(r.cushion >= 3.0 && r.pfAtCost >= 1.5)
      Print("++ The edge absorbs several times the assumed cost and keeps a healthy profit factor. It looks robust to execution costs.");

   Print("\nAnalysis complete.");
  }
//+------------------------------------------------------------------+

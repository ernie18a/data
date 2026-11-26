//+------------------------------------------------------------------+
//|                                                  DrawdownDNA.mq5 |
//|                           Drawdown DNA Analyzer for MetaTrader 5 |
//|           Reads a daily equity curve and dissects its drawdowns: |
//|           underwater curve, episodes, recovery time and a score. |
//+------------------------------------------------------------------+
#property copyright "Cristian David Castillo Arrieta"
#property version   "1.00"
#property script_show_inputs
#property description "Reads a daily equity curve from CSV and analyzes the structure of its drawdowns."

//--- Input parameters
input string InpFileName     = "EquityCurve.csv"; // CSV file: Date,DailyPnL
input double InpStartCapital = 10000.0;           // Starting capital
input double InpMinDepthPct  = 1.0;               // Ignore drawdowns shallower than this (%)
input double InpWeightDepth  = 0.40;              // Weight: depth dimension
input double InpWeightRecov  = 0.30;              // Weight: recovery dimension
input double InpWeightUlcer  = 0.30;              // Weight: stability dimension

//--- One drawdown episode: peak -> trough -> recovery
struct SEpisode
  {
   int    peakIdx;        // last day at the previous high-water mark
   int    troughIdx;      // day of the deepest point
   int    recoveryIdx;    // day the equity reached the old peak again (-1 if never)
   double depthPct;       // deepest decline of the episode, in percent
   double depthMoney;     // deepest decline of the episode, in account currency
   int    ddDuration;     // peak -> trough, in days
   int    recDuration;    // trough -> recovery, in days
   int    underwaterLen;  // peak -> recovery, in days
   bool   recovered;      // true if the old peak was reached again
  };

//--- Aggregated report
struct SDrawdownReport
  {
   int    nDays;
   int    nEpisodes;
   double maxDepthPct;
   double maxDepthMoney;
   double avgDepthPct;
   int    longestUnderwater;
   int    avgRecovery;
   double timeUnderwaterPct;
   double ulcerIndex;
   double painIndex;
   double recoveryFactor;
   double netProfit;
   double depthScore;
   double recovScore;
   double ulcerScore;
   double resilience;
   string grade;
  };

//--- Global series
double g_pnl[];
double g_equity[];
double g_peak[];
double g_ddPct[];
double g_ddMoney[];
int    g_n = 0;

//+------------------------------------------------------------------+
//| Read a Date,DailyPnL file into the pnl array                     |
//+------------------------------------------------------------------+
bool LoadEquitySeries(string filename, double &pnl[])
  {
   int handle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Could not open %s. Error: %d", filename, GetLastError());
      return false;
     }

   //--- Skip the header line
   if(!FileIsEnding(handle))
     {
      while(!FileIsLineEnding(handle) && !FileIsEnding(handle))
         FileReadString(handle);
     }

   int count = 0;
   while(!FileIsEnding(handle))
     {
      string dateStr = FileReadString(handle);
      if(dateStr == "")
         break;
      double value = FileReadNumber(handle);

      count++;
      ArrayResize(pnl, count, 256);
      pnl[count - 1] = value;
     }

   FileClose(handle);
   return (count > 0);
  }

//+------------------------------------------------------------------+
//| Build the equity, high-water mark and underwater series          |
//+------------------------------------------------------------------+
void BuildSeries(const double &pnl[], int n, double capital,
                 double &equity[], double &peak[], double &ddPct[], double &ddMoney[])
  {
   ArrayResize(equity, n);
   ArrayResize(peak, n);
   ArrayResize(ddPct, n);
   ArrayResize(ddMoney, n);

   double run = capital;
   double hwm = capital;            // high-water mark
   for(int i = 0; i < n; i++)
     {
      run += pnl[i];
      equity[i] = run;
      if(run > hwm)
         hwm = run;
      peak[i]    = hwm;
      ddMoney[i] = hwm - run;
      ddPct[i]   = (hwm > 0.0) ? (ddMoney[i] / hwm * 100.0) : 0.0;
     }
  }

//+------------------------------------------------------------------+
//| Split the underwater curve into discrete drawdown episodes       |
//+------------------------------------------------------------------+
int DetectEpisodes(const double &equity[], const double &peak[], const double &ddPct[],
                   const double &ddMoney[], int n, double minDepth, SEpisode &eps[])
  {
   int    nEp = 0;
   double tol = 1e-8;
   ArrayResize(eps, 0);

   int i = 0;
   while(i < n)
     {
      if(ddPct[i] > tol)
        {
         //--- An episode begins. The peak day is the one before the first decline.
         int    startPeak = (i > 0) ? i - 1 : 0;
         double curPeak   = peak[i];
         int    troughIdx = i;
         double maxDd     = ddPct[i];

         int j = i;
         while(j < n && equity[j] < curPeak - tol)
           {
            if(ddPct[j] > maxDd)
              {
               maxDd     = ddPct[j];
               troughIdx = j;
              }
            j++;
           }

         SEpisode e;
         e.peakIdx    = startPeak;
         e.troughIdx  = troughIdx;
         e.depthPct   = maxDd;
         e.depthMoney = ddMoney[troughIdx];
         e.ddDuration = troughIdx - startPeak;

         if(j < n)
           {
            e.recovered     = true;
            e.recoveryIdx   = j;
            e.recDuration   = j - troughIdx;
            e.underwaterLen = j - startPeak;
           }
         else
           {
            e.recovered     = false;
            e.recoveryIdx   = -1;
            e.recDuration   = (n - 1) - troughIdx;
            e.underwaterLen = (n - 1) - startPeak;
           }

         if(e.depthPct >= minDepth)
           {
            nEp++;
            ArrayResize(eps, nEp);
            eps[nEp - 1] = e;
           }

         i = (j < n) ? j : n;
        }
      else
         i++;
     }
   return nEp;
  }

//+------------------------------------------------------------------+
//| Ulcer Index: root mean square of the underwater depths           |
//+------------------------------------------------------------------+
double UlcerIndex(const double &ddPct[], int n)
  {
   if(n <= 0)
      return 0.0;
   double sum = 0.0;
   for(int i = 0; i < n; i++)
      sum += ddPct[i] * ddPct[i];
   return MathSqrt(sum / n);
  }

//+------------------------------------------------------------------+
//| Pain Index: average underwater depth                             |
//+------------------------------------------------------------------+
double PainIndex(const double &ddPct[], int n)
  {
   if(n <= 0)
      return 0.0;
   double sum = 0.0;
   for(int i = 0; i < n; i++)
      sum += ddPct[i];
   return sum / n;
  }

//+------------------------------------------------------------------+
//| Aggregate the episodes and metrics into a single report          |
//+------------------------------------------------------------------+
void BuildReport(const SEpisode &eps[], int nEp, const double &ddPct[], int n,
                 const double &equity[], double capital, SDrawdownReport &r)
  {
   r.nDays            = n;
   r.nEpisodes        = nEp;
   r.maxDepthPct      = 0.0;
   r.maxDepthMoney    = 0.0;
   r.longestUnderwater = 0;

   double sumDepth = 0.0;
   int    sumRec = 0, recCount = 0;

   for(int k = 0; k < nEp; k++)
     {
      if(eps[k].depthPct > r.maxDepthPct)
         r.maxDepthPct = eps[k].depthPct;
      if(eps[k].depthMoney > r.maxDepthMoney)
         r.maxDepthMoney = eps[k].depthMoney;
      sumDepth += eps[k].depthPct;
      if(eps[k].underwaterLen > r.longestUnderwater)
         r.longestUnderwater = eps[k].underwaterLen;
      if(eps[k].recovered)
        {
         sumRec += eps[k].recDuration;
         recCount++;
        }
     }

   r.avgDepthPct = (nEp > 0)      ? sumDepth / nEp : 0.0;
   r.avgRecovery = (recCount > 0) ? (int)MathRound((double)sumRec / recCount) : 0;

   int underwaterDays = 0;
   for(int i = 0; i < n; i++)
      if(ddPct[i] > 1e-8)
         underwaterDays++;
   r.timeUnderwaterPct = (n > 0) ? 100.0 * underwaterDays / n : 0.0;

   r.ulcerIndex     = UlcerIndex(ddPct, n);
   r.painIndex      = PainIndex(ddPct, n);
   r.netProfit      = equity[n - 1] - capital;
   r.recoveryFactor = (r.maxDepthMoney > 0.0) ? r.netProfit / r.maxDepthMoney : 0.0;

   //--- Dimension scores (higher means more resilient)
   r.depthScore = MathMax(0.0, 100.0 - r.maxDepthPct * 2.0);
   r.recovScore = MathMax(0.0, 100.0 - r.timeUnderwaterPct);
   r.ulcerScore = MathMax(0.0, 100.0 - r.ulcerIndex * 5.0);

   r.resilience = r.depthScore * InpWeightDepth +
                  r.recovScore * InpWeightRecov +
                  r.ulcerScore * InpWeightUlcer;

   if(r.resilience >= 90)      r.grade = "A+";
   else if(r.resilience >= 80) r.grade = "A";
   else if(r.resilience >= 70) r.grade = "B";
   else if(r.resilience >= 60) r.grade = "C";
   else if(r.resilience >= 50) r.grade = "D";
   else                        r.grade = "F";
  }

//+------------------------------------------------------------------+
//| Draw a text underwater curve in the Experts tab                  |
//+------------------------------------------------------------------+
void PrintUnderwaterChart(const double &ddPct[], int n, double maxDepth)
  {
   int cols = 50;
   int rows = 8;

   double bucket[];
   ArrayResize(bucket, cols);
   ArrayInitialize(bucket, 0.0);

   for(int c = 0; c < cols; c++)
     {
      int a = (int)MathFloor((double)c * n / cols);
      int b = (int)MathFloor((double)(c + 1) * n / cols);
      if(b <= a)
         b = a + 1;
      double mx = 0.0;
      for(int i = a; i < b && i < n; i++)
         if(ddPct[i] > mx)
            mx = ddPct[i];
      bucket[c] = mx;
     }

   double scale = (maxDepth > 0.0) ? maxDepth : 1.0;
   Print("Underwater curve (deeper is lower, each column is a time bucket):");
   for(int rr = 1; rr <= rows; rr++)
     {
      double level = scale * rr / rows;
      string line  = StringFormat("%5.1f%%|", level);
      for(int c = 0; c < cols; c++)
         line += (bucket[c] >= level - 1e-9) ? "#" : ".";
      Print(line);
     }
  }

//+------------------------------------------------------------------+
//| Generate a synthetic curve so the script runs without setup      |
//+------------------------------------------------------------------+
bool EnsureSampleFile(string filename)
  {
   int handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Could not create sample %s. Error: %d", filename, GetLastError());
      return false;
     }

   FileWriteString(handle, "Date,DailyPnL\n");
   MathSrand(20260601);

   int      days = 220;
   datetime t    = StringToTime("2026.01.01");

   for(int i = 0; i < days; i++)
     {
      double noise = ((double)MathRand() / 32767.0 - 0.5) * 150.0;
      double pnl   = 60.0 + noise;

      //--- Two engineered stress windows so the demo has real episodes
      if(i >= 45 && i < 63)   pnl -= 150.0;   // sharp drawdown
      if(i >= 120 && i < 150) pnl -= 78.0;    // long, shallow drawdown
      if(i >= 150 && i < 170) pnl += 35.0;    // recovery push

      MqlDateTime dt;
      TimeToStruct(t, dt);
      string ds = StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day);
      FileWriteString(handle, StringFormat("%s,%.2f\n", ds, pnl));
      t += 86400;
     }

   FileClose(handle);
   PrintFormat("Sample file %s created with %d rows.", filename, days);
   return true;
  }

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("========================================");
   Print("  DRAWDOWN DNA ANALYZER v1.0");
   Print("  Underwater, Recovery and Resilience Tool");
   Print("========================================");

   if(!LoadEquitySeries(InpFileName, g_pnl))
     {
      Print(">> File not found or empty. Generating a sample curve...");
      if(!EnsureSampleFile(InpFileName))
        {
         Alert("Could not create the sample file.");
         return;
        }
      if(!LoadEquitySeries(InpFileName, g_pnl))
        {
         Alert("Could not load the sample file.");
         return;
        }
     }

   g_n = ArraySize(g_pnl);
   if(g_n < 20)
     {
      Alert("At least 20 daily records are required.");
      return;
     }

   BuildSeries(g_pnl, g_n, InpStartCapital, g_equity, g_peak, g_ddPct, g_ddMoney);

   SEpisode eps[];
   int nEp = DetectEpisodes(g_equity, g_peak, g_ddPct, g_ddMoney, g_n, InpMinDepthPct, eps);

   SDrawdownReport rep;
   BuildReport(eps, nEp, g_ddPct, g_n, g_equity, InpStartCapital, rep);

   //--- Underwater curve
   Print("");
   PrintUnderwaterChart(g_ddPct, g_n, rep.maxDepthPct);

   //--- Episode table
   PrintFormat("\n=== DRAWDOWN EPISODES (depth >= %.1f%%) ===", InpMinDepthPct);
   Print(" #   Depth      DDdays   Recdays   Underwater   Status");
   for(int k = 0; k < nEp; k++)
     {
      PrintFormat(" %-3d %6.2f%%    %-6d   %-7s   %-10d   %s",
                  k + 1, eps[k].depthPct, eps[k].ddDuration,
                  (eps[k].recovered ? IntegerToString(eps[k].recDuration) : "-"),
                  eps[k].underwaterLen,
                  (eps[k].recovered ? "recovered" : "ongoing"));
     }

   //--- Risk metrics
   Print("\n=== RISK METRICS ===");
   PrintFormat(" Max drawdown:        %.2f%%  ($%.2f)", rep.maxDepthPct, rep.maxDepthMoney);
   PrintFormat(" Average drawdown:    %.2f%%", rep.avgDepthPct);
   PrintFormat(" Drawdown episodes:   %d", rep.nEpisodes);
   PrintFormat(" Longest underwater:  %d days", rep.longestUnderwater);
   PrintFormat(" Avg recovery time:   %d days", rep.avgRecovery);
   PrintFormat(" Time underwater:     %.1f%%", rep.timeUnderwaterPct);
   PrintFormat(" Ulcer Index:         %.2f", rep.ulcerIndex);
   PrintFormat(" Pain Index:          %.2f", rep.painIndex);
   PrintFormat(" Recovery Factor:     %.2f", rep.recoveryFactor);

   //--- Resilience score
   Print("\n========================================");
   Print("  DRAWDOWN RESILIENCE SCORE");
   Print("========================================");
   PrintFormat(" Depth score:       %.1f / 100", rep.depthScore);
   PrintFormat(" Recovery score:    %.1f / 100", rep.recovScore);
   PrintFormat(" Stability score:   %.1f / 100", rep.ulcerScore);
   Print("----------------------------------------");
   PrintFormat(" RESILIENCE:        %.1f / 100", rep.resilience);
   PrintFormat(" GRADE:             %s", rep.grade);
   Print("========================================");

   //--- Recommendations
   Print("\n--- RECOMMENDATIONS ---");
   if(rep.maxDepthPct >= 25.0)
      Print("!! Deep maximum drawdown. Reduce position size or review the entry logic.");
   if(rep.timeUnderwaterPct >= 50.0)
      Print(">> The account spends most of its life below a previous peak. Review chronic underperformance.");
   if(rep.ulcerIndex >= 10.0)
      Print(">> High Ulcer Index. The depth and persistence of the losses would be hard to hold through.");
   if(rep.longestUnderwater >= 60)
      Print(">> Very long underwater period. Recovery is slow relative to the size of the loss.");
   if(rep.resilience >= 80.0)
      Print("++ Resilient equity curve. Drawdowns are shallow and recover quickly.");

   Print("\nAnalysis complete.");
  }
//+------------------------------------------------------------------+

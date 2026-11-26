//+------------------------------------------------------------------+
//|                                                    EdgeDrift.mq5 |
//|                  Copyright 2026, Cristian David Castillo Arrieta |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Cristian David Castillo Arrieta"
#property link      "https://www.mql5.com"
#property version   "1.21"
#property description "Edge Drift Detector: tests live deals against a backtest report."
#property script_show_inputs

#define DEMO_BASE_FILE "DemoBase.csv"
#define DEMO_LIVE_FILE "DemoLive.csv"

//--- where the baseline comes from
enum ENUM_BASE_SOURCE
  {
   BASE_TESTER_REPORT,                                          // Tester report (HTML)
   BASE_CSV_FILE,                                               // CSV file
   BASE_ACCOUNT_HISTORY                                         // Account history
  };
//--- where the live sample comes from
enum ENUM_LIVE_SOURCE
  {
   LIVE_ACCOUNT_HISTORY,                                        // Account history
   LIVE_CSV_FILE                                                // CSV file
  };

//--- data sources
input ENUM_BASE_SOURCE InpBaseSource    = BASE_TESTER_REPORT;   // Baseline source
input string           InpBaseFile      = "";                   // Baseline file (empty: auto)
input ENUM_LIVE_SOURCE InpLiveSource    = LIVE_ACCOUNT_HISTORY; // Live source
input string           InpLiveFile      = "EdgeLive.csv";       // Live CSV file
input long             InpMagic         = 0;                    // Magic number (0 = all)
input string           InpSymbol        = "";                   // Symbol (empty = all)
input datetime         InpLiveFrom      = 0;                    // Live start date (0 = all)
input bool             InpPerLot        = true;                 // Per-lot outcomes
//--- detector settings
input int              InpHorizon       = 250;                  // Monitoring horizon, deals
input int              InpShortWindow   = 20;                   // Short window, deals
input int              InpLongWindow    = 100;                  // Long window, deals
input double           InpAlpha         = 0.05;                 // False-alarm rate, horizon
input double           InpWatchFraction = 0.70;                 // Threshold share for WATCH
input int              InpBootstrap     = 2000;                 // Bootstrap resamples
input int              InpMaxDelay      = 2000;                 // Delay simulation cap
input ulong            InpSeed          = 12345;                // Bootstrap seed (repeatable)
input int              InpMinBaseline   = 100;                  // Minimum baseline deals
input int              InpMinLive       = 20;                   // Minimum live deals
input double           InpMaxMixGap     = 0.20;                 // Symbol mix gap that warns
//--- heuristic score
input double           InpHealthyTail   = 0.20;                 // Tail for full marks
input double           InpWeightCusum   = 40.0;                 // Weight: CUSUM evidence
input double           InpWeightLong    = 25.0;                 // Weight: long window
input double           InpWeightShort   = 15.0;                 // Weight: short window
input double           InpWeightWinRate = 20.0;                 // Weight: win rate
input double           InpGradeAPlus    = 95.0;                 // Minimum score for A+
input double           InpGradeA        = 85.0;                 // Minimum score for A
input double           InpGradeB        = 70.0;                 // Minimum score for B
input double           InpGradeC        = 55.0;                 // Minimum score for C
input double           InpGradeD        = 40.0;                 // Minimum score for D

//+------------------------------------------------------------------+
//| Data structures                                                  |
//+------------------------------------------------------------------+
//--- one closing deal reduced to what the detector needs
struct DealOutcome
  {
   datetime          time;                   // close time of the deal
   double            value;                  // net result (per lot if enabled)
   string            symbol;                 // symbol of the deal
  };
//--- summary statistics of one sample
struct EdgeProfile
  {
   int               count;                  // number of closing deals
   double            mean;                   // average outcome, the edge
   double            stdev;                  // sample standard deviation
   int               wins;                   // deals with a positive outcome
   double            winRate;                // wins divided by count
   double            avgWin;                 // average positive outcome
   double            avgLoss;                // average size of a non-win
  };
//--- result of the CUSUM edge-loss detector
struct CusumResult
  {
   double            reference;              // reference k = half the edge
   double            threshold;              // alarm threshold h (bootstrap)
   int               horizon;                // deals h is calibrated for
   double            peak;                   // highest CUSUM on the live path
   int               peakIndex;              // zero-based index of the peak
   double            peakTail;               // tail probability of the peak
   int               alarmIndex;             // first index at h, -1 if none
   int               startIndex;             // deals before the drift start
   int               medianDelay;            // median deals to flag lost edge
  };
//--- result of one bootstrap window test
struct WindowResult
  {
   int               size;                   // deals in the window
   double            mean;                   // mean of the last deals
   double            tail;                   // tail probability of that mean
  };
//--- decomposition of the change in expectancy
struct EdgeShift
  {
   double            total;                  // live mean minus baseline mean
   double            hitRate;                // part due to the win rate
   double            winSize;                // part due to the average win
   double            lossSize;               // part due to the average loss
  };
//--- heuristic score and decision
struct DriftScore
  {
   double            cusumScore;             // CUSUM dimension, 0-100
   double            longScore;              // long-window dimension, 0-100
   double            shortScore;             // short-window dimension, 0-100
   double            winRateScore;           // win-rate dimension, 0-100
   double            total;                  // weighted composite, 0-100
   string            grade;                  // letter grade from A+ to F
   string            verdict;                // CONTINUE/WATCH/REDUCE/SUSPEND
  };
//--- symbol composition of the baseline and the live sample
struct MixResult
  {
   int               baseSymbols;            // distinct symbols in the baseline
   int               liveSymbols;            // distinct symbols in the live sample
   int               shared;                 // symbols present in both samples
   double            gap;                    // mix difference, 0 = same mix, 1 = no overlap
   double            unmatched;              // live share on symbols absent from the baseline
   bool              warning;                // true when gap exceeds InpMaxMixGap
  };
//--- one closing deal read from the account history
struct ClosedDeal
  {
   datetime          time;                   // close time of the deal
   string            symbol;                 // symbol of the deal
   double            volume;                 // closed volume in lots
   double            net;                    // net result incl. entry cost
  };

//--- global state
ulong g_rngState = (ulong)88172645463325252; // xorshift64* generator state

//+------------------------------------------------------------------+
//| Seed the xorshift64* generator (zero is not a valid state)       |
//+------------------------------------------------------------------+
void RngSeed(const ulong seed)
  {
   g_rngState = (seed == 0) ? (ulong)88172645463325252 : seed;
  }
//+------------------------------------------------------------------+
//| Next 64-bit value of the xorshift64* generator                   |
//+------------------------------------------------------------------+
ulong RngNext()
  {
   ulong x = g_rngState;
   x ^= (x >> 12);
   x ^= (x << 25);
   x ^= (x >> 27);
   g_rngState = x;
   return(x * (ulong)2685821657736338717); // unsigned overflow wraps modulo 2^64
  }
//+------------------------------------------------------------------+
//| Uniform number in [0, 1) built from the top 53 bits              |
//+------------------------------------------------------------------+
double RngUniform()
  {
   return((double)(RngNext() >> 11) * (1.0 / 9007199254740992.0));
  }
//+------------------------------------------------------------------+
//| Uniform index in [0, n)                                          |
//+------------------------------------------------------------------+
int RngIndex(const int n)
  {
   int k = (int)(RngUniform() * n);
   return((k >= n) ? n - 1 : k);
  }
//+------------------------------------------------------------------+
//| Parse one CSV row: CloseTime,Symbol,Volume,NetProfit             |
//+------------------------------------------------------------------+
bool ParseRow(const string line, const bool perLot, DealOutcome &row)
  {
   string parts[];
   if(StringSplit(line, ',', parts) < 4)
      return(false);
   for(int i = 0; i < 4; i++)
     {
      StringTrimLeft(parts[i]);
      StringTrimRight(parts[i]);
     }
//--- validate every field before accepting the row
   datetime t = StringToTime(parts[0]);
   double volume = StringToDouble(parts[2]);
   if(t <= 0 || volume <= 0.0 || parts[3] == "")
      return(false);
   double net = StringToDouble(parts[3]);
   if(!MathIsValidNumber(net))
      return(false);
   row.time = t;
   row.value = perLot ? net / volume : net; // per lot makes different lot sizes comparable
   row.symbol = parts[1];
   return(true);
  }
//+------------------------------------------------------------------+
//| Load all closing deals of one CSV file, returns -1 on failure    |
//+------------------------------------------------------------------+
int LoadOutcomes(const string fileName, const bool common, const bool perLot,
                 DealOutcome &rows[])
  {
   ArrayResize(rows, 0);
   int flags = FILE_READ | FILE_TXT | FILE_ANSI | FILE_SHARE_READ;
   if(common)
      flags |= FILE_COMMON;
   int handle = FileOpen(fileName, flags);
   if(handle == INVALID_HANDLE)
      return(-1);
   bool header = true;
   int skipped = 0;
   while(!FileIsEnding(handle))
     {
      string line = FileReadString(handle); // in FILE_TXT mode, one call returns one line
      StringTrimLeft(line);
      StringTrimRight(line);
      if(line == "")
         continue;
      //--- the first non-empty line is the header
      if(header)
        {
         header = false;
         continue;
        }
      DealOutcome row;
      if(!ParseRow(line, perLot, row))
        {
         skipped++;
         continue;
        }
      int n = ArraySize(rows);
      ArrayResize(rows, n + 1, 1024);
      rows[n] = row;
     }
   FileClose(handle);
   if(skipped > 0)
      PrintFormat("%s: %d malformed rows skipped", fileName, skipped);
   return(ArraySize(rows));
  }
//+------------------------------------------------------------------+
//| Stable insertion sort by close time                              |
//+------------------------------------------------------------------+
void SortByTime(DealOutcome &rows[])
  {
   int n = ArraySize(rows);
   for(int i = 1; i < n; i++)
     {
      DealOutcome key = rows[i];
      int j = i - 1;
      while(j >= 0 && rows[j].time > key.time)
        {
         rows[j + 1] = rows[j];
         j--;
        }
      rows[j + 1] = key;
     }
  }
//+------------------------------------------------------------------+
//| Mean, deviation, win rate and payoff of one sample               |
//+------------------------------------------------------------------+
bool BuildProfile(const double &x[], EdgeProfile &p)
  {
   int n = ArraySize(x);
   p.count = n;
   if(n < 2)
      return(false);
   double sum = 0.0;
   for(int i = 0; i < n; i++)
      sum += x[i];
   p.mean = sum / n;
   double ss = 0.0;
   for(int i = 0; i < n; i++)
      ss += (x[i] - p.mean) * (x[i] - p.mean);
   p.stdev = MathSqrt(ss / (n - 1));
//--- split winners from the rest; a breakeven deal counts as a non-win
   double sumWin = 0.0;
   double sumLoss = 0.0;
   p.wins = 0;
   for(int i = 0; i < n; i++)
     {
      if(x[i] > 0.0)
        {
         p.wins++;
         sumWin += x[i];
        }
      else
         sumLoss -= x[i];
     }
   p.winRate = (double)p.wins / n;
   p.avgWin = (p.wins > 0) ? sumWin / p.wins : 0.0;
   p.avgLoss = (n - p.wins > 0) ? sumLoss / (n - p.wins) : 0.0;
   return(true);
  }
//+------------------------------------------------------------------+
//| One CUSUM step: accumulate evidence that the edge is gone        |
//+------------------------------------------------------------------+
double CusumStep(const double s, const double value, const double reference,
                 const double stdev)
  {
   double next = s + (reference - value) / stdev;
   return((next < 0.0) ? 0.0 : next); // the statistic never drops below zero
  }
//+------------------------------------------------------------------+
//| Bootstrap threshold h: the (1 - alpha) quantile of path maxima   |
//+------------------------------------------------------------------+
double CalibrateThreshold(const double &base[], const EdgeProfile &p,
                          const double reference, const int horizon,
                          const int resamples, const double alpha, double &maxima[])
  {
   int n = ArraySize(base);
   ArrayResize(maxima, resamples);
//--- replay the baseline many times and record the highest CUSUM of each path
   for(int b = 0; b < resamples; b++)
     {
      double s = 0.0;
      double mx = 0.0;
      for(int t = 0; t < horizon; t++)
        {
         s = CusumStep(s, base[RngIndex(n)], reference, p.stdev);
         if(s > mx)
            mx = s;
        }
      maxima[b] = mx;
     }
//--- only a share alpha of healthy paths ever reaches h within the horizon
   double sorted[];
   ArrayCopy(sorted, maxima);
   ArraySort(sorted);
   int k = (int)MathCeil((1.0 - alpha) * resamples - 1e-9) - 1;
   k = (int)MathMax(0, MathMin(resamples - 1, k));
   return(sorted[k]);
  }
//+------------------------------------------------------------------+
//| Run the CUSUM on the live deals: peak, alarm and drift start     |
//+------------------------------------------------------------------+
void RunCusum(const double &live[], const double &maxima[], const EdgeProfile &p,
              CusumResult &c)
  {
   int m = ArraySize(live);
   double path[];
   ArrayResize(path, m);
   double s = 0.0;
   c.peak = 0.0;
   c.peakIndex = 0;
   c.alarmIndex = -1;
   for(int i = 0; i < m; i++)
     {
      s = CusumStep(s, live[i], c.reference, p.stdev);
      path[i] = s;
      if(s > c.peak)
        {
         c.peak = s;
         c.peakIndex = i;
        }
      if(c.alarmIndex < 0 && s >= c.threshold)
         c.alarmIndex = i;
     }
//--- share of healthy paths that reach the observed peak (+1 keeps it above zero)
   int b = ArraySize(maxima);
   int hits = 0;
   for(int i = 0; i < b; i++)
      if(maxima[i] >= c.peak)
         hits++;
   c.peakTail = (hits + 1.0) / (b + 1.0);
//--- the drift starts right after the last zero before the alarm (or the peak)
   int anchor = (c.alarmIndex >= 0) ? c.alarmIndex : c.peakIndex;
   c.startIndex = 0;
   for(int i = anchor; i >= 0; i--)
     {
      if(path[i] <= 0.0)
        {
         c.startIndex = i + 1;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Bootstrap tail probability of the mean of the last deals         |
//+------------------------------------------------------------------+
void WindowTest(const double &base[], const double &live[], const int window,
                const int resamples, WindowResult &w)
  {
   int n = ArraySize(base);
   int m = ArraySize(live);
   w.size = (window < m) ? window : m;
   double sum = 0.0;
   for(int i = m - w.size; i < m; i++)
      sum += live[i];
   w.mean = sum / w.size;
//--- how often does a healthy window of the same size look this weak?
   int hits = 0;
   for(int b = 0; b < resamples; b++)
     {
      double s = 0.0;
      for(int t = 0; t < w.size; t++)
         s += base[RngIndex(n)];
      if(s / w.size <= w.mean)
         hits++;
     }
   w.tail = (hits + 1.0) / (resamples + 1.0);
  }
//+------------------------------------------------------------------+
//| Bootstrap tail probability of the live win count                 |
//+------------------------------------------------------------------+
double WinRateTail(const double &base[], const EdgeProfile &live, const int resamples)
  {
   int n = ArraySize(base);
   int hits = 0;
   for(int b = 0; b < resamples; b++)
     {
      int wins = 0;
      for(int t = 0; t < live.count; t++)
         if(base[RngIndex(n)] > 0.0)
            wins++;
      if(wins <= live.wins)
         hits++;
     }
   return((hits + 1.0) / (resamples + 1.0));
  }
//+------------------------------------------------------------------+
//| Median number of deals the detector needs if the edge vanishes   |
//+------------------------------------------------------------------+
int MedianDetectionDelay(const double &base[], const EdgeProfile &p,
                         const CusumResult &c, const int resamples, const int maxDelay)
  {
   int n = ArraySize(base);
   int delays[];
   ArrayResize(delays, resamples);
   for(int b = 0; b < resamples; b++)
     {
      double s = 0.0;
      delays[b] = maxDelay + 1; // marks a path that never reached h
      for(int t = 0; t < maxDelay; t++)
        {
         //--- a baseline deal with its edge removed: same shape, zero mean
         s = CusumStep(s, base[RngIndex(n)] - p.mean, c.reference, p.stdev);
         if(s >= c.threshold)
           {
            delays[b] = t + 1;
            break;
           }
        }
     }
   ArraySort(delays);
   return(delays[resamples / 2]);
  }
//+------------------------------------------------------------------+
//| Split the change in expectancy into win rate, win and loss size  |
//+------------------------------------------------------------------+
void DecomposeShift(const EdgeProfile &b, const EdgeProfile &l, EdgeShift &e)
  {
//--- expectancy = p * W - (1 - p) * L, so the three parts sum exactly to the total
   e.total = l.mean - b.mean;
   e.hitRate = (l.winRate - b.winRate) * (b.avgWin + b.avgLoss);
   e.winSize = l.winRate * (l.avgWin - b.avgWin);
   e.lossSize = -(1.0 - l.winRate) * (l.avgLoss - b.avgLoss);
  }
//+------------------------------------------------------------------+
//| Map a tail probability to 0-100 (full marks at InpHealthyTail)   |
//+------------------------------------------------------------------+
double TailScore(const double tail)
  {
   return(100.0 * MathMin(1.0, tail / InpHealthyTail));
  }
//+------------------------------------------------------------------+
//| Letter grade from the composite score                            |
//+------------------------------------------------------------------+
string GradeFromScore(const double score)
  {
   if(score >= InpGradeAPlus)
      return("A+");
   if(score >= InpGradeA)
      return("A");
   if(score >= InpGradeB)
      return("B");
   if(score >= InpGradeC)
      return("C");
   if(score >= InpGradeD)
      return("D");
   return("F");
  }
//+------------------------------------------------------------------+
//| Heuristic composite score and the rule-based verdict             |
//+------------------------------------------------------------------+
void ScoreDrift(const CusumResult &c, const WindowResult &sw, const WindowResult &lw,
                const double winTail, DriftScore &d)
  {
   d.cusumScore = TailScore(c.peakTail);
   d.longScore = TailScore(lw.tail);
   d.shortScore = TailScore(sw.tail);
   d.winRateScore = TailScore(winTail);
//--- normalized weights, so the result does not depend on their sum
   double wSum = InpWeightCusum + InpWeightLong + InpWeightShort + InpWeightWinRate;
   if(wSum <= 0.0)
      wSum = 1.0;
   d.total = (d.cusumScore * InpWeightCusum + d.longScore * InpWeightLong +
              d.shortScore * InpWeightShort + d.winRateScore * InpWeightWinRate) / wSum;
   d.grade = GradeFromScore(d.total);
//--- the verdict uses explicit rules, not the heuristic score
   bool alarm = (c.alarmIndex >= 0);
   if(alarm && lw.tail < InpAlpha)
      d.verdict = "SUSPEND";
   else
      if(alarm || lw.tail < InpAlpha)
         d.verdict = "REDUCE";
      else
         if(sw.tail < InpAlpha || c.peak >= InpWatchFraction * c.threshold)
            d.verdict = "WATCH";
         else
            d.verdict = "CONTINUE";
  }
//+------------------------------------------------------------------+
//| Close time of a deal as text                                     |
//+------------------------------------------------------------------+
string DealDate(const DealOutcome &rows[], const int index)
  {
   return(TimeToString(rows[index].time, TIME_DATE));
  }
//+------------------------------------------------------------------+
//| One-line reading of the two-horizon check                        |
//+------------------------------------------------------------------+
string HorizonReading(const WindowResult &sw, const WindowResult &lw)
  {
   bool shortWeak = (sw.tail < InpAlpha);
   bool longWeak = (lw.tail < InpAlpha);
   if(shortWeak && longWeak)
      return("Both windows weak. Consistent with a lasting loss of edge");
   if(shortWeak)
      return("Short window weak, long window normal. Possible regime dip");
   if(longWeak)
      return("Long window weak, short window normal. Recent deals hide a longer decline");
   return("Both windows normal");
  }
//+------------------------------------------------------------------+
//| Print the written recommendations                                |
//+------------------------------------------------------------------+
void PrintRecommendations(const DealOutcome &liveRows[], const CusumResult &c,
                          const WindowResult &sw, const WindowResult &lw,
                          const EdgeShift &e, const MixResult &mix)
  {
   Print("Recommendations:");
   int printed = 0;
   if(mix.warning)
     {
      Print("- Treat this verdict as provisional. Analyze one symbol at a time with the " +
            "Symbol input");
      printed++;
     }
   if(c.alarmIndex >= 0)
     {
      PrintFormat("- CUSUM crossed h at deal #%d. Stop adding risk and re-validate " +
                  "on data since %s", c.alarmIndex + 1, DealDate(liveRows, c.startIndex));
      printed++;
     }
   if(lw.tail < InpAlpha && sw.tail >= InpAlpha)
     {
      PrintFormat("- Do not read the last %d deals as a recovery. The last %d deals " +
                  "still sit in the lower tail of the baseline", sw.size, lw.size);
      printed++;
     }
//--- name the component that lost the most expectancy
   double worst = MathMin(e.hitRate, MathMin(e.winSize, e.lossSize));
   if(e.total < 0.0 && worst < 0.0)
     {
      if(worst == e.hitRate)
         Print("- The win rate explains most of the lost expectancy. Check whether " +
               "the entry conditions still match the market");
      else
         Print("- Trade sizes explain most of the lost expectancy. Review exits, " +
               "spreads and slippage");
      printed++;
     }
   if(c.medianDelay > c.horizon)
     {
      PrintFormat("- A complete loss of edge takes about %d deals to confirm. Extend " +
                  "the horizon or accept slower detection", c.medianDelay);
      printed++;
     }
   if(printed == 0)
      Print("- Live results are consistent with the baseline. Keep monitoring");
  }
//+------------------------------------------------------------------+
//| Demonstration outcome per lot: exponential wins, bounded losses  |
//+------------------------------------------------------------------+
double DemoOutcome(const double pWin, const double winMean, const double lossLo,
                   const double lossHi)
  {
   double u = RngUniform();
   double v = RngUniform();
   if(u < pWin)
      return(-winMean * MathLog(1.0 - v));    // winner with a long right tail
   return(-(lossLo + (lossHi - lossLo) * v)); // loser bounded by the stop
  }
//+------------------------------------------------------------------+
//| Next demonstration close time, skipping weekends                 |
//+------------------------------------------------------------------+
datetime DemoNextTime(datetime t)
  {
   t += (int)((6.0 + 42.0 * RngUniform()) * 3600.0);
   MqlDateTime st;
   TimeToStruct(t, st);
   while(st.day_of_week == 0 || st.day_of_week == 6)
     {
      t += 86400;
      TimeToStruct(t, st);
     }
   return(t);
  }
//+------------------------------------------------------------------+
//| One demonstration CSV row                                        |
//+------------------------------------------------------------------+
string DemoRow(const datetime t, const double volume, const double perLot)
  {
   return(TimeToString(t, TIME_DATE | TIME_SECONDS) + ",EURUSD," +
          DoubleToString(volume, 2) + "," + DoubleToString(perLot * volume, 2) + "\r\n");
  }
//+------------------------------------------------------------------+
//| Write demonstration files: the live edge breaks after deal 100   |
//+------------------------------------------------------------------+
bool WriteDemoFiles(const bool common)
  {
//--- fixed seed: the demonstration is identical on every terminal
   RngSeed(20260926);
   int flags = FILE_WRITE | FILE_TXT | FILE_ANSI;
   if(common)
      flags |= FILE_COMMON;
   int hb = FileOpen(DEMO_BASE_FILE, flags);
   if(hb == INVALID_HANDLE)
      return(false);
   int hl = FileOpen(DEMO_LIVE_FILE, flags);
   if(hl == INVALID_HANDLE)
     {
      FileClose(hb);
      return(false);
     }
   FileWriteString(hb, "CloseTime,Symbol,Volume,NetProfit\r\n");
   FileWriteString(hl, "CloseTime,Symbol,Volume,NetProfit\r\n");
//--- baseline: 500 deals at a fixed 0.10 lot, as a tester run would produce
   datetime t = D'2023.01.02 09:00';
   for(int i = 0; i < 500; i++)
     {
      t = DemoNextTime(t);
      double x = DemoOutcome(0.60, 10.0, 5.0, 11.0);
      FileWriteString(hb, DemoRow(t, 0.10, x));
     }
//--- live: 240 deals with risk-based lots; the win rate falls after deal 100
   t = D'2025.09.01 09:00';
   for(int i = 0; i < 240; i++)
     {
      t = DemoNextTime(t);
      double x = (i < 100) ? DemoOutcome(0.60, 10.0, 5.0, 11.0) :
                 DemoOutcome(0.40, 9.0, 5.0, 11.0);
      double volume = 0.20 + 0.01 * (int)(21.0 * RngUniform()); // 0.20-0.40 lot
      FileWriteString(hl, DemoRow(t, volume, x));
     }
   FileClose(hb);
   FileClose(hl);
   return(true);
  }
//+------------------------------------------------------------------+
//| Index of a position ID in the cache, -1 if it is not there       |
//+------------------------------------------------------------------+
int FindPosition(const long &ids[], const long id)
  {
//--- search from the end: exits usually follow their entries closely
   for(int i = ArraySize(ids) - 1; i >= 0; i--)
      if(ids[i] == id)
         return(i);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Collect closing deals in [from, to); to = 0 means no limit       |
//+------------------------------------------------------------------+
int CollectClosingDeals(const long magic, const string symbol, const datetime from,
                        const datetime to, ClosedDeal &deals[])
  {
   ArrayResize(deals, 0);
   if(!HistorySelect(0, TimeCurrent()))
      return(-1);
   int total = HistoryDealsTotal();
//--- pass 1: magic, entry cost and entry volume of every position
   long   posIds[];
   long   posMagic[];
   double posCost[];
   double posVolume[];
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0 || HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_IN)
         continue;
      long id = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      int k = FindPosition(posIds, id);
      if(k < 0)
        {
         k = ArraySize(posIds);
         ArrayResize(posIds, k + 1, 256);
         ArrayResize(posMagic, k + 1, 256);
         ArrayResize(posCost, k + 1, 256);
         ArrayResize(posVolume, k + 1, 256);
         posIds[k] = id;
         posMagic[k] = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         posCost[k] = 0.0;
         posVolume[k] = 0.0;
        }
      //--- commission and fee are often charged on the entry deal
      posCost[k] += HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                    HistoryDealGetDouble(ticket, DEAL_FEE);
      posVolume[k] += HistoryDealGetDouble(ticket, DEAL_VOLUME);
     }
//--- pass 2: one element per closing deal
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;
      //--- trades only: balance, credit, bonus and correction rows are excluded
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      //--- closing deals only; a partial exit is its own row, a reversal is skipped
      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY)
         continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      string sym = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(t < from || (to > 0 && t >= to) || (symbol != "" && sym != symbol))
         continue;
      //--- filter by the magic of the position, so SL, TP and manual exits stay in
      int k = FindPosition(posIds, HistoryDealGetInteger(ticket, DEAL_POSITION_ID));
      if(magic != 0 && (k < 0 || posMagic[k] != magic))
         continue;
      double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double net = HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                   HistoryDealGetDouble(ticket, DEAL_SWAP) +
                   HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                   HistoryDealGetDouble(ticket, DEAL_FEE);
      //--- add this exit's share of the entry cost, in proportion to its volume
      if(k >= 0 && posVolume[k] > 0.0)
         net += posCost[k] * volume / posVolume[k];
      int n = ArraySize(deals);
      ArrayResize(deals, n + 1, 1024);
      deals[n].time = t;
      deals[n].symbol = sym;
      deals[n].volume = volume;
      deals[n].net = net;
     }
   return(ArraySize(deals));
  }
//+------------------------------------------------------------------+
//| Sort the rows by time and copy their outcomes into a plain array |
//+------------------------------------------------------------------+
int SortAndCopy(DealOutcome &rows[], double &values[])
  {
   SortByTime(rows);
   int n = ArraySize(rows);
   ArrayResize(values, n);
   for(int i = 0; i < n; i++)
      values[i] = rows[i].value;
   return(n);
  }
//+------------------------------------------------------------------+
//| Full path of the common Files folder shared by all terminals     |
//+------------------------------------------------------------------+
string CommonFolder()
  {
   return(TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files");
  }
//+------------------------------------------------------------------+
//| Full path of the Files folder of this terminal                   |
//+------------------------------------------------------------------+
string LocalFolder()
  {
   return(TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files");
  }
//+------------------------------------------------------------------+
//| Look for a file in the common folder first, then the local one   |
//+------------------------------------------------------------------+
bool LocateFile(const string fileName, bool &common)
  {
   common = true;
   if(FileIsExist(fileName, FILE_COMMON))
      return(true);
   common = false;
   return(FileIsExist(fileName));
  }
//+------------------------------------------------------------------+
//| Newest ReportTester*.html in the common and the local folder     |
//+------------------------------------------------------------------+
bool FindNewestReport(string &fileName, bool &common)
  {
   bool found = false;
   long newest = 0;
   for(int pass = 0; pass < 2; pass++)
     {
      bool inCommon = (pass == 0);
      string name;
      long handle = FileFindFirst("ReportTester*.html", name, inCommon ? FILE_COMMON : 0);
      if(handle == INVALID_HANDLE)
         continue;
      do
        {
         long modified = FileGetInteger(name, FILE_MODIFY_DATE, inCommon);
         if(!found || modified > newest)
           {
            found = true;
            newest = modified;
            fileName = name;
            common = inCommon;
           }
        }
      while(FileFindNext(handle, name));
      FileFindClose(handle);
     }
   return(found);
  }
//+------------------------------------------------------------------+
//| Text of every <td> cell of one HTML table row                    |
//+------------------------------------------------------------------+
int ExtractCells(const string line, string &cells[])
  {
   ArrayResize(cells, 0);
   int pos = 0;
   while(true)
     {
      int open = StringFind(line, "<td", pos);
      if(open < 0)
         break;
      int start = StringFind(line, ">", open);
      int close = (start < 0) ? -1 : StringFind(line, "</td>", start);
      if(close < 0)
         break;
      string text = StringSubstr(line, start + 1, close - start - 1);
      StringTrimLeft(text);
      StringTrimRight(text);
      int n = ArraySize(cells);
      ArrayResize(cells, n + 1, 16);
      cells[n] = text;
      pos = close + 5;
     }
   return(ArraySize(cells));
  }
//+------------------------------------------------------------------+
//| Number from a report cell, for example "-3 068.92" -> -3068.92   |
//+------------------------------------------------------------------+
double ReportNumber(string text)
  {
//--- the report groups thousands with spaces
   StringReplace(text, " ", "");
   StringReplace(text, ShortToString(0x00A0), "");
   StringReplace(text, ShortToString(0x202F), "");
   return(StringToDouble(text));
  }
//+------------------------------------------------------------------+
//| Index of a symbol in a list, -1 if it is not there               |
//+------------------------------------------------------------------+
int FindSymbol(const string &list[], const string symbol)
  {
   for(int i = ArraySize(list) - 1; i >= 0; i--)
      if(list[i] == symbol)
         return(i);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Closing deals from the Deals table of a Strategy Tester report   |
//+------------------------------------------------------------------+
int LoadReport(const string fileName, const bool common, DealOutcome &rows[])
  {
   ArrayResize(rows, 0);
//--- the terminal saves HTML reports as UTF-16 text
   int flags = FILE_READ | FILE_TXT | FILE_UNICODE | FILE_SHARE_READ;
   if(common)
      flags |= FILE_COMMON;
   int handle = FileOpen(fileName, flags);
   if(handle == INVALID_HANDLE)
      return(-1);
   string symbols[];
   double entryRates[];
   while(!FileIsEnding(handle))
     {
      //--- a deal row has 13 cells: Time, Deal, Symbol, Type, Direction, Volume,
      //--- Price, Order, Commission, Swap, Profit, Balance, Comment
      string cells[];
      if(ExtractCells(FileReadString(handle), cells) != 13)
         continue;
      datetime t = StringToTime(cells[0]);
      if(t <= 0 || StringLen(cells[0]) < 19 || cells[2] == "")
         continue;                      // header or balance row
      if(InpSymbol != "" && cells[2] != InpSymbol)
         continue;
      double volume = ReportNumber(cells[5]);
      double commission = ReportNumber(cells[8]);
      double profit = ReportNumber(cells[10]);
      if(volume <= 0.0)
         continue;
      //--- entry or exit; a translated report falls back to "an exit has a profit"
      string direction = cells[4];
      bool isIn = (direction == "in");
      bool isOut = (direction == "out" || direction == "out by");
      if(!isIn && !isOut && direction != "in/out")
        {
         isOut = (profit != 0.0);
         isIn = !isOut;
        }
      int k = FindSymbol(symbols, cells[2]);
      //--- an entry only records its commission per lot for the exits that follow
      if(isIn)
        {
         if(k < 0)
           {
            k = ArraySize(symbols);
            ArrayResize(symbols, k + 1, 16);
            ArrayResize(entryRates, k + 1, 16);
            symbols[k] = cells[2];
           }
         entryRates[k] = commission / volume;
         continue;
        }
      //--- closing deals only; a reversal (in/out) is skipped, as in the history reader
      if(!isOut)
         continue;
      double net = profit + ReportNumber(cells[9]) + commission;
      if(k >= 0)
         net += entryRates[k] * volume; // entry commission share
      int n = ArraySize(rows);
      ArrayResize(rows, n + 1, 1024);
      rows[n].time = t;
      rows[n].symbol = cells[2];
      rows[n].value = InpPerLot ? net / volume : net;
     }
   FileClose(handle);
   return(ArraySize(rows));
  }
//+------------------------------------------------------------------+
//| Load the closing deals in [from, to) from the account history    |
//+------------------------------------------------------------------+
int LoadHistorySample(const datetime from, const datetime to, DealOutcome &rows[],
                      double &values[])
  {
   ClosedDeal deals[];
   int n = CollectClosingDeals(InpMagic, InpSymbol, from, to, deals);
   if(n < 0)
     {
      PrintFormat("Cannot read the account history (error %d)", GetLastError());
      return(-1);
     }
   ArrayResize(rows, 0);
   for(int i = 0; i < n; i++)
     {
      if(deals[i].volume <= 0.0)
         continue;
      int k = ArraySize(rows);
      ArrayResize(rows, k + 1, 1024);
      rows[k].time = deals[i].time;
      rows[k].symbol = deals[i].symbol;
      rows[k].value = InpPerLot ? deals[i].net / deals[i].volume : deals[i].net;
     }
   return(SortAndCopy(rows, values));
  }
//+------------------------------------------------------------------+
//| Load the baseline: 1 = loaded, 0 = file not found, -1 = error    |
//+------------------------------------------------------------------+
int LoadBaseline(DealOutcome &rows[], double &values[])
  {
//--- this account, before the live sample starts
   if(InpBaseSource == BASE_ACCOUNT_HISTORY)
     {
      if(InpLiveFrom <= 0)
        {
         Print("Set Live sample starts: the deals before that date form the baseline");
         return(-1);
        }
      PrintFormat("Baseline: this account, magic %I64d, deals before %s", InpMagic,
                  TimeToString(InpLiveFrom, TIME_DATE));
      return((LoadHistorySample(0, InpLiveFrom, rows, values) >= 0) ? 1 : -1);
     }
//--- a file: the named one, or the newest tester report
   string name = InpBaseFile;
   bool common = true;
   bool found = false;
   if(InpBaseSource == BASE_TESTER_REPORT && name == "")
      found = FindNewestReport(name, common);
   else
     {
      if(name == "")
         name = "EdgeBase.csv";
      found = LocateFile(name, common);
     }
   if(!found)
      return(0);
   PrintFormat("Baseline: %s in %s", name, common ? CommonFolder() : LocalFolder());
   int n = (InpBaseSource == BASE_TESTER_REPORT) ? LoadReport(name, common, rows) :
           LoadOutcomes(name, common, InpPerLot, rows);
   if(n < 0)
     {
      PrintFormat("Cannot open %s (error %d)", name, GetLastError());
      return(-1);
     }
   SortAndCopy(rows, values);
   return(1);
  }
//+------------------------------------------------------------------+
//| Load the live sample from this account or from a CSV file        |
//+------------------------------------------------------------------+
bool LoadLive(DealOutcome &rows[], double &values[])
  {
   if(InpLiveSource == LIVE_ACCOUNT_HISTORY)
     {
      PrintFormat("Live: this account, magic %I64d, deals from %s", InpMagic,
                  (InpLiveFrom > 0) ? TimeToString(InpLiveFrom, TIME_DATE) : "the first one");
      return(LoadHistorySample(InpLiveFrom, 0, rows, values) >= 0);
     }
   bool common = true;
   if(!LocateFile(InpLiveFile, common))
     {
      PrintFormat("%s was not found in %s or in %s", InpLiveFile, CommonFolder(),
                  LocalFolder());
      Print("Run DriftExport.mq5 on the live terminal, or set Live source to this account");
      return(false);
     }
   PrintFormat("Live: %s in %s", InpLiveFile, common ? CommonFolder() : LocalFolder());
   if(LoadOutcomes(InpLiveFile, common, InpPerLot, rows) < 0)
     {
      PrintFormat("Cannot open %s (error %d)", InpLiveFile, GetLastError());
      return(false);
     }
   SortAndCopy(rows, values);
   return(true);
  }
//+------------------------------------------------------------------+
//| Explain how to create the baseline from a tester report          |
//+------------------------------------------------------------------+
void PrintReportHelp()
  {
   PrintFormat("No Strategy Tester report (ReportTester*.html) found in %s", CommonFolder());
   Print("To analyze your Expert Advisor:");
   Print("1. Backtest the Expert Advisor in the Strategy Tester");
   Print("2. Right-click the Backtest results, choose Report and save it as HTML");
   PrintFormat("3. Save the report in %s", CommonFolder());
   Print("4. Run EdgeDrift on the live account with the Expert Advisor's magic number");
   Print("Until then, EdgeDrift analyzes its demonstration data");
  }
//+------------------------------------------------------------------+
//| Write and load the demonstration pair                            |
//+------------------------------------------------------------------+
bool LoadDemo(DealOutcome &baseRows[], double &base[], DealOutcome &liveRows[],
              double &live[])
  {
//--- demonstration files have their own names and never mix with real data
   if(!WriteDemoFiles(true))
     {
      Print("Cannot write the demonstration files");
      return(false);
     }
   PrintFormat("Source: %s (baseline) and %s (live)", DEMO_BASE_FILE, DEMO_LIVE_FILE);
   if(LoadOutcomes(DEMO_BASE_FILE, true, InpPerLot, baseRows) < 0 ||
      LoadOutcomes(DEMO_LIVE_FILE, true, InpPerLot, liveRows) < 0)
      return(false);
   SortAndCopy(baseRows, base);
   SortAndCopy(liveRows, live);
   return(true);
  }
//+------------------------------------------------------------------+
//| Load the baseline and the live sample from the chosen sources    |
//+------------------------------------------------------------------+
bool LoadSamples(DealOutcome &baseRows[], double &base[], DealOutcome &liveRows[],
                 double &live[])
  {
   int status = LoadBaseline(baseRows, base);
   if(status < 0)
      return(false);
   if(status == 0)
     {
      //--- no tester report yet: show the steps, then the demonstration
      if(InpBaseSource == BASE_TESTER_REPORT)
        {
         PrintReportHelp();
         return(LoadDemo(baseRows, base, liveRows, live));
        }
      PrintFormat("%s was not found in %s or in %s",
                  (InpBaseFile == "") ? "EdgeBase.csv" : InpBaseFile, CommonFolder(),
                  LocalFolder());
      Print("Set Baseline source to Strategy Tester report to read a backtest directly");
      return(false);
     }
   return(LoadLive(liveRows, live));
  }
//+------------------------------------------------------------------+
//| Number of deals per symbol in one sample                         |
//+------------------------------------------------------------------+
void CountBySymbol(const DealOutcome &rows[], string &names[], int &counts[])
  {
   ArrayResize(names, 0);
   ArrayResize(counts, 0);
   for(int i = 0; i < ArraySize(rows); i++)
     {
      int k = FindSymbol(names, rows[i].symbol);
      if(k < 0)
        {
         k = ArraySize(names);
         ArrayResize(names, k + 1, 16);
         ArrayResize(counts, k + 1, 16);
         names[k] = rows[i].symbol;
         counts[k] = 0;
        }
      counts[k]++;
     }
  }
//+------------------------------------------------------------------+
//| Compare the symbol mix of both samples and print the result      |
//+------------------------------------------------------------------+
void CheckSymbolMix(const DealOutcome &baseRows[], const DealOutcome &liveRows[],
                    MixResult &mix)
  {
   string baseNames[], liveNames[];
   int baseCounts[], liveCounts[];
   CountBySymbol(baseRows, baseNames, baseCounts);
   CountBySymbol(liveRows, liveNames, liveCounts);
   double n = (double)ArraySize(baseRows);
   double m = (double)ArraySize(liveRows);
   mix.baseSymbols = ArraySize(baseNames);
   mix.liveSymbols = ArraySize(liveNames);
   mix.shared = 0;
   mix.gap = 0.0;
   mix.unmatched = 0.0;
//--- share of each symbol in both samples, over the union of symbols
   string names[];
   double baseShare[], liveShare[];
   for(int i = 0; i < mix.baseSymbols; i++)
     {
      int k = FindSymbol(liveNames, baseNames[i]);
      int size = ArraySize(names);
      ArrayResize(names, size + 1, 16);
      ArrayResize(baseShare, size + 1, 16);
      ArrayResize(liveShare, size + 1, 16);
      names[size] = baseNames[i];
      baseShare[size] = baseCounts[i] / n;
      liveShare[size] = (k >= 0) ? liveCounts[k] / m : 0.0;
      if(k >= 0)
         mix.shared++;
     }
   for(int i = 0; i < mix.liveSymbols; i++)
     {
      if(FindSymbol(baseNames, liveNames[i]) >= 0)
         continue;
      int size = ArraySize(names);
      ArrayResize(names, size + 1, 16);
      ArrayResize(baseShare, size + 1, 16);
      ArrayResize(liveShare, size + 1, 16);
      names[size] = liveNames[i];
      baseShare[size] = 0.0;
      liveShare[size] = liveCounts[i] / m;
      mix.unmatched += liveShare[size];
     }
//--- half the sum of absolute share differences (total variation distance)
   for(int i = 0; i < ArraySize(names); i++)
      mix.gap += MathAbs(baseShare[i] - liveShare[i]);
   mix.gap *= 0.5;
   mix.warning = (mix.gap > InpMaxMixGap);
   Print("--- Symbol mix check ---");
   PrintFormat("Symbols: %d in the baseline, %d live, %d shared", mix.baseSymbols,
               mix.liveSymbols, mix.shared);
   PrintFormat("Mix difference: %.1f%% (0%% = same mix, 100%% = no overlap)",
               mix.gap * 100.0);
   if(!mix.warning)
      return;
   Print("WARNING: the symbol mix differs, so per-lot results are not comparable");
//--- the three symbols whose shares differ the most
   for(int shown = 0; shown < 3; shown++)
     {
      int best = -1;
      double bestDiff = 0.01;
      for(int i = 0; i < ArraySize(names); i++)
         if(MathAbs(baseShare[i] - liveShare[i]) > bestDiff)
           {
            bestDiff = MathAbs(baseShare[i] - liveShare[i]);
            best = i;
           }
      if(best < 0)
         break;
      PrintFormat("%s: %.1f%% of baseline deals, %.1f%% of live deals", names[best],
                  baseShare[best] * 100.0, liveShare[best] * 100.0);
      baseShare[best] = liveShare[best]; // exclude it from the next search
     }
   if(mix.unmatched > 0.0)
      PrintFormat("Live deals on symbols missing from the baseline: %.1f%%",
                  mix.unmatched * 100.0);
   Print("Set Symbol to analyze one instrument, or use a report of the same instruments");
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Print("=== Edge Drift Detector 1.21 ===");
//--- sanity checks on the inputs
   if(InpAlpha <= 0.0 || InpAlpha >= 1.0 || InpBootstrap < 100 || InpShortWindow < 1 ||
      InpLongWindow < 1 || InpHealthyTail <= 0.0 || InpMaxDelay < 1)
     {
      Print("Invalid inputs: check alpha, windows, resamples and the healthy tail");
      return;
     }
//--- load both samples from CSV files or from the account history
   DealOutcome baseRows[], liveRows[];
   double base[], live[];
   if(!LoadSamples(baseRows, base, liveRows, live))
      return;
   int n = ArraySize(base);
   int m = ArraySize(live);
   if(n < InpMinBaseline || m < InpMinLive)
     {
      PrintFormat("Too few deals: baseline %d (minimum %d), live %d (minimum %d)",
                  n, InpMinBaseline, m, InpMinLive);
      //--- tell the reader which setting moves the counts in the right direction
      if(InpBaseSource == BASE_ACCOUNT_HISTORY)
         Print("Move the start of the live sample to balance the two samples, or build " +
               "the baseline from a backtest");
      else
         Print("Run a longer backtest for the baseline, or wait for more live deals");
      return;
     }
   EdgeProfile pb, pl;
   BuildProfile(base, pb);
   BuildProfile(live, pl);
   if(pb.mean <= 0.0 || pb.stdev <= 0.0)
     {
      Print("The baseline shows no positive edge, so there is nothing to monitor");
      return;
     }
   PrintFormat("Unit: net result %s, one row per closing deal",
               InpPerLot ? "per 1.00 lot" : "in account currency");
   PrintFormat("Baseline: %d closing deals, %s to %s", n, DealDate(baseRows, 0),
               DealDate(baseRows, n - 1));
   PrintFormat("Live: %d closing deals, %s to %s", m, DealDate(liveRows, 0),
               DealDate(liveRows, m - 1));
   Print("--- Baseline versus live ---");
   PrintFormat("Mean per deal: %.2f -> %.2f", pb.mean, pl.mean);
   PrintFormat("Std deviation: %.2f -> %.2f", pb.stdev, pl.stdev);
   PrintFormat("Win rate: %.1f%% -> %.1f%%", pb.winRate * 100.0, pl.winRate * 100.0);
   PrintFormat("Average win: %.2f -> %.2f", pb.avgWin, pl.avgWin);
   PrintFormat("Average loss: %.2f -> %.2f", pb.avgLoss, pl.avgLoss);
   PrintFormat("Edge-to-noise ratio of the baseline: %.3f", pb.mean / pb.stdev);
   MixResult mix;
   CheckSymbolMix(baseRows, liveRows, mix);
//--- CUSUM detector; every bootstrap step below draws from one seeded generator
   CusumResult c;
   c.reference = 0.5 * pb.mean;
   c.horizon = (InpHorizon > m) ? InpHorizon : m;
   RngSeed(InpSeed);
   double maxima[];
   c.threshold = CalibrateThreshold(base, pb, c.reference, c.horizon, InpBootstrap,
                                    InpAlpha, maxima);
   RunCusum(live, maxima, pb, c);
//--- two-horizon check and win-rate test
   WindowResult sw, lw;
   WindowTest(base, live, InpShortWindow, InpBootstrap, sw);
   WindowTest(base, live, InpLongWindow, InpBootstrap, lw);
   double winTail = WinRateTail(base, pl, InpBootstrap);
   c.medianDelay = MedianDetectionDelay(base, pb, c, InpBootstrap, InpMaxDelay);
   EdgeShift e;
   DecomposeShift(pb, pl, e);
   DriftScore d;
   ScoreDrift(c, sw, lw, winTail, d);
//--- report
   Print("--- CUSUM edge-loss detector ---");
   PrintFormat("Reference k = %.2f (half the baseline edge), horizon %d deals, %d resamples",
               c.reference, c.horizon, InpBootstrap);
   PrintFormat("Threshold h = %.2f (%.0f%% of baseline paths stay below it)", c.threshold,
               (1.0 - InpAlpha) * 100.0);
   PrintFormat("Peak %.2f at deal #%d (%s), tail probability %.2f%%", c.peak,
               c.peakIndex + 1, DealDate(liveRows, c.peakIndex), c.peakTail * 100.0);
   if(c.alarmIndex >= 0)
      PrintFormat("ALARM at deal #%d (%s)", c.alarmIndex + 1,
                  DealDate(liveRows, c.alarmIndex));
   else
      Print("No alarm within the live sample");
   if(c.startIndex > 0)
      PrintFormat("Drift most likely began after deal #%d (%s)", c.startIndex,
                  DealDate(liveRows, c.startIndex - 1));
   PrintFormat("Median delay to flag a complete loss of edge: %d deals", c.medianDelay);
   Print("--- Two-horizon check ---");
   PrintFormat("Short window (last %d): mean %.2f, tail probability %.2f%%", sw.size,
               sw.mean, sw.tail * 100.0);
   PrintFormat("Long window (last %d): mean %.2f, tail probability %.2f%%", lw.size,
               lw.mean, lw.tail * 100.0);
   PrintFormat("Reading: %s", HorizonReading(sw, lw));
   Print("--- Where did the edge go? ---");
   PrintFormat("Change in expectancy: %+.2f per deal", e.total);
   PrintFormat("Win-rate effect: %+.2f", e.hitRate);
   PrintFormat("Win-size effect: %+.2f", e.winSize);
   PrintFormat("Loss-size effect: %+.2f", e.lossSize);
   PrintFormat("Win-rate tail probability: %.2f%%", winTail * 100.0);
   Print("--- Edge Health Score (heuristic, for ranking and quick comparison) ---");
   PrintFormat("CUSUM %.1f | Long %.1f | Short %.1f | Win rate %.1f", d.cusumScore,
               d.longScore, d.shortScore, d.winRateScore);
   PrintFormat("Edge Health Score: %.1f / 100 -> Grade %s", d.total, d.grade);
   PrintFormat("Verdict: %s%s", d.verdict,
               mix.warning ? " (provisional: the symbol mix differs)" : "");
   PrintRecommendations(liveRows, c, sw, lw, e, mix);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                DiagnosticLog.mqh |
//|                      BGC Grid Trading EA — CSV-Based Diagnostics |
//|                      Buffers data in memory, flushes to CSV at   |
//|                      OnDeinit/OnTester for Python analysis       |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __DIAGNOSTIC_LOG_MQH__
#define __DIAGNOSTIC_LOG_MQH__

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| Event types for the unified event log                            |
//+------------------------------------------------------------------+
enum ENUM_DIAG_EVENT
{
   DIAG_CYCLE_START       = 0,
   DIAG_CYCLE_PROFIT_END  = 1,   // ended by profit target
   DIAG_CYCLE_KILL_END    = 2,   // ended by kill switch
   DIAG_CYCLE_AGE_END     = 3,   // ended by variance age limit
   DIAG_CYCLE_AGE_BLOCKED = 4,   // age limit wanted to restart but loss too big
   DIAG_DRIFT_PAUSE       = 5,   // drift gate paused
   DIAG_DRIFT_RESUME      = 6,   // drift gate resumed
   DIAG_VOL_PAUSE         = 7,   // ATR volatility paused
   DIAG_VOL_RESUME        = 8,   // ATR volatility resumed
   DIAG_WARNING_CLOSE     = 9,   // warning-level worst loser closed
   DIAG_ORPHAN_CLOSED     = 10,  // orphan position closed in sweep
   DIAG_CLOSE_RETRY       = 11,  // CloseAll failed, positions remain
   DIAG_NO_MONEY          = 12,  // order rejected for margin
   DIAG_CPD_FIRE          = 13,  // CPD CUSUM change point detected
   DIAG_MODE_SWITCH       = 14,  // grid mode changed (BGT/TGT/MGT)
   DIAG_REGIME_RESTART    = 15,  // mid-cycle regime change forced restart
   DIAG_CYCLE_REGIME_END  = 16,  // cycle ended by regime change
   DIAG_PRICE_LEVEL_BLOCK = 17,  // price-level filter blocked cycle start
   DIAG_PRICE_LEVEL_CLEAR = 18,  // price-level filter cleared
   DIAG_WEEKEND_CLOSE     = 19,  // Friday close — flat over weekend
   DIAG_WEEKEND_RESUME    = 20   // Monday resume — new cycle allowed
};

//+------------------------------------------------------------------+
//| Per-bar snapshot (30 fields, one row per bar)                     |
//+------------------------------------------------------------------+
struct BarSnapshot
{
   datetime time;
   double   bid;
   double   equity;
   double   balance;
   double   floatingPL;
   double   sessionHigh;
   double   sessionLow;
   int      dtLevels;
   int      utLevels;
   double   ltFormula;
   double   ltPathAware;
   double   ltError;
   double   cycleDDPct;
   double   snapshotRPRPct;
   int      openBuys;
   int      openSells;
   int      armedBuys;
   int      armedSells;
   int      gridState;
   int      gridMode;
   int      trendDirection;
   double   sigmaMu;
   double   atr;
   double   drift;
   double   gridSpacing;
   double   baseLot;
   int      cycleNumber;
   double   ruinProbT53;
   double   cusumSHigh;
   double   cusumSLow;
};

//+------------------------------------------------------------------+
//| Cycle summary (28 fields, one row per completed cycle)           |
//+------------------------------------------------------------------+
struct DiagCycleSummary
{
   int              cycleNum;
   datetime         startTime;
   datetime         endTime;
   double           durationHours;
   double           startEquity;
   double           endEquity;
   double           profit;
   double           profitPct;
   double           gridSpacing;
   double           baseLot;
   ENUM_GRID_MODE   gridMode;
   double           sigmaMuAtStart;
   double           atrAtStart;
   double           driftAtStart;
   int              trendDirection;
   double           maxCycleDDPct;
   double           maxRPRPct;
   double           peakPRuin;
   double           peakPathLt;
   double           theoreticalLt;
   double           sessionRange;
   int              tpHits;
   int              warningCloses;
   int              driftPauses;
   int              cpdFires;
   int              positionsAtEnd;
   ENUM_DIAG_EVENT  exitReason;
   double           cumulativeProfit;
};

//+------------------------------------------------------------------+
//| Event record (7 fields, one row per event — unbounded)           |
//+------------------------------------------------------------------+
struct DiagEventRecord
{
   datetime         time;
   int              cycleNum;
   string           eventType;
   double           value1;
   double           value2;
   double           value3;
   string           detail;
};

//+------------------------------------------------------------------+
//| CDiagnosticLog — CSV-based unbounded diagnostic collection       |
//+------------------------------------------------------------------+
class CDiagnosticLog
{
private:
   //--- Data arrays (unbounded, dynamically grown)
   BarSnapshot       m_snapshots[];
   int               m_snapCount;
   DiagCycleSummary  m_cycles[];
   int               m_cycleCount;
   DiagEventRecord   m_events[];
   int               m_eventCount;

   //--- Running counters for current cycle
   int              m_curTpHits;
   int              m_curWarningCloses;
   int              m_curDriftPauses;
   int              m_curCPDFires;
   double           m_curPeakRPR;
   double           m_curSessionRange;
   double           m_curTheoreticalLt;
   ENUM_GRID_MODE   m_curGridMode;
   double           m_curGridSpacing;
   double           m_curEffectiveBaseLot;
   double           m_curPeakPRuin;
   double           m_curPathAwareLtPeak;
   double           m_curSigmaMuAtStart;
   double           m_curAtrAtStart;
   double           m_curDriftAtStart;
   int              m_curTrendDirection;
   datetime         m_curStartTime;
   double           m_curStartEquity;
   double           m_curPeakCycleDDPct;

   //--- Global counters
   int              m_totalTpHits;
   int              m_totalKillSwitchFires;
   int              m_totalProfitRestarts;
   int              m_totalAgeRestarts;
   int              m_totalAgeBlocked;
   int              m_totalWarningCloses;
   int              m_totalOrphansSwept;
   int              m_totalDriftPauses;
   int              m_totalCloseRetries;
   double           m_maxRPRever;
   double           m_peakEquity;
   double           m_troughEquity;

   //--- File prefix and flush guard
   string           m_filePrefix;
   bool             m_flushed;

   //--- Cumulative profit tracker for cycle summaries
   double           m_runningCumulativeProfit;

   void AddEvent(ENUM_DIAG_EVENT type, int cycleNum, double v1, double v2, double v3, string detail)
   {
      int newSize = m_eventCount + 1;
      ArrayResize(m_events, newSize, 1000);

      m_events[m_eventCount].time      = TimeCurrent();
      m_events[m_eventCount].cycleNum  = cycleNum;
      m_events[m_eventCount].eventType = EventName(type);
      m_events[m_eventCount].value1    = v1;
      m_events[m_eventCount].value2    = v2;
      m_events[m_eventCount].value3    = v3;
      m_events[m_eventCount].detail    = detail;
      m_eventCount++;
   }

public:
   CDiagnosticLog()
   {
      m_snapCount  = 0;
      m_eventCount = 0;
      m_cycleCount = 0;
      m_flushed    = false;
      m_filePrefix = "BGCGrid";
      m_runningCumulativeProfit = 0;
      ResetCycleCounters();
      ResetGlobalCounters();
   }

   //--- Initialise with file prefix, pre-allocate arrays
   void Init(string filePrefix)
   {
      m_filePrefix = filePrefix;
      m_flushed    = false;

      ArrayResize(m_snapshots, 0, 10000);
      ArrayResize(m_cycles, 0, 100);
      ArrayResize(m_events, 0, 1000);

      m_snapCount  = 0;
      m_cycleCount = 0;
      m_eventCount = 0;
   }

   //--- Record a per-bar snapshot
   void RecordBarSnapshot(const BarSnapshot &snap)
   {
      int newSize = m_snapCount + 1;
      ArrayResize(m_snapshots, newSize, 10000);
      m_snapshots[m_snapCount] = snap;
      m_snapCount++;
   }

   //=== Event recording methods ===

   void OnCycleStart(int cycleNum, double anchor, double equity,
                      ENUM_GRID_MODE mode = GRID_MODE_BGT,
                      double gridSpacing = 0, double effectiveBaseLot = 0,
                      double sigmaMu = 999, double atr = 0, double drift = 0)
   {
      ResetCycleCounters();
      m_curGridMode          = mode;
      m_curGridSpacing       = gridSpacing;
      m_curEffectiveBaseLot  = effectiveBaseLot;
      m_curSigmaMuAtStart    = sigmaMu;
      m_curAtrAtStart        = atr;
      m_curDriftAtStart      = drift;
      m_curStartTime         = TimeCurrent();
      m_curStartEquity       = equity;

      string modeStr = ModeToString(mode);
      string detail = StringFormat("Cycle started [%s] spacing=%.2f lot=%.2f sigma/mu=%.2f ATR=%.5f drift=%.5f",
                                    modeStr, gridSpacing, effectiveBaseLot, sigmaMu, atr, drift);
      AddEvent(DIAG_CYCLE_START, cycleNum, anchor, equity, 0, detail);
   }

   void OnCycleEndProfit(int cycleNum, double pnl, int positionsAtEnd, double equity)
   {
      m_totalProfitRestarts++;
      FinishCycle(cycleNum, pnl, positionsAtEnd, DIAG_CYCLE_PROFIT_END, equity);
      AddEvent(DIAG_CYCLE_PROFIT_END, cycleNum, pnl, equity, (double)positionsAtEnd, "Profit target");
   }

   void OnCycleEndKill(int cycleNum, double rpr, double pnl, double equity)
   {
      m_totalKillSwitchFires++;
      FinishCycle(cycleNum, pnl, 0, DIAG_CYCLE_KILL_END, equity);
      AddEvent(DIAG_CYCLE_KILL_END, cycleNum, rpr, pnl, equity,
               StringFormat("RPR=%.1f%%", rpr * 100));
   }

   void OnCycleEndAge(int cycleNum, int hours, double pnl, double equity)
   {
      m_totalAgeRestarts++;
      FinishCycle(cycleNum, pnl, 0, DIAG_CYCLE_AGE_END, equity);
      AddEvent(DIAG_CYCLE_AGE_END, cycleNum, (double)hours, pnl, equity,
               StringFormat("Aged %d hrs", hours));
   }

   void OnCycleEndRegime(int cycleNum, double pnl, double equity)
   {
      FinishCycle(cycleNum, pnl, 0, DIAG_CYCLE_REGIME_END, equity);
      AddEvent(DIAG_CYCLE_REGIME_END, cycleNum, pnl, equity, 0, "Regime change");
   }

   void OnCycleAgeBlocked(int cycleNum, int hours, double loss, double maxLoss)
   {
      m_totalAgeBlocked++;
      if(m_totalAgeBlocked % 100 == 1)
         AddEvent(DIAG_CYCLE_AGE_BLOCKED, cycleNum, (double)hours, loss, maxLoss,
                  StringFormat("Loss $%.2f > max $%.2f (x%d)", loss, maxLoss, m_totalAgeBlocked));
   }

   void OnTpHit(int cycleNum, double profit)
   {
      m_curTpHits++;
      m_totalTpHits++;
   }

   void OnWarningClose(int cycleNum, double rpr, double savedLoss)
   {
      m_curWarningCloses++;
      m_totalWarningCloses++;
      AddEvent(DIAG_WARNING_CLOSE, cycleNum, rpr, savedLoss, 0,
               StringFormat("RPR=%.1f%%", rpr * 100));
   }

   void OnDriftPause(int cycleNum, double sigmaMu, double atr, double drift)
   {
      m_curDriftPauses++;
      m_totalDriftPauses++;
      AddEvent(DIAG_DRIFT_PAUSE, cycleNum, sigmaMu, atr, drift, "Drift detected");
   }

   void OnDriftResume(int cycleNum, double sigmaMu)
   {
      AddEvent(DIAG_DRIFT_RESUME, cycleNum, sigmaMu, 0, 0, "Drift cleared");
   }

   void OnOrphanClosed(int count)
   {
      m_totalOrphansSwept += count;
   }

   void OnCloseRetry(int cycleNum, int remaining)
   {
      m_totalCloseRetries++;
      AddEvent(DIAG_CLOSE_RETRY, cycleNum, (double)remaining, 0, 0,
               StringFormat("%d positions remain", remaining));
   }

   void OnCPDFire(int cycleNum, double sHigh, double sLow)
   {
      m_curCPDFires++;
      AddEvent(DIAG_CPD_FIRE, cycleNum, sHigh, sLow, 0, "CUSUM change point");
   }

   void OnNoMoney(int cycleNum, int count)
   {
      AddEvent(DIAG_NO_MONEY, cycleNum, (double)count, 0, 0,
               StringFormat("%d ghost arm(s) — ticket=0 margin reject", count));
   }

   void OnPriceLevelBlock(int cycleNum, double distFromHigh, double distFromLow, double minDist)
   {
      AddEvent(DIAG_PRICE_LEVEL_BLOCK, cycleNum, distFromHigh, distFromLow, minDist,
               StringFormat("DistHigh=%.2f DistLow=%.2f MinDist=%.2f", distFromHigh, distFromLow, minDist));
   }

   void OnPriceLevelClear(int cycleNum)
   {
      AddEvent(DIAG_PRICE_LEVEL_CLEAR, cycleNum, 0, 0, 0, "Price retraced from extreme");
   }

   void OnWeekendClose(int cycleNum, double pnl, double equity)
   {
      FinishCycle(cycleNum, pnl, 0, DIAG_WEEKEND_CLOSE, equity);
      AddEvent(DIAG_WEEKEND_CLOSE, cycleNum, pnl, equity, 0, "Friday close — flat over weekend");
   }

   void OnWeekendResume(int cycleNum, double equity)
   {
      AddEvent(DIAG_WEEKEND_RESUME, cycleNum, equity, 0, 0, "Monday resume");
   }

   void OnModeSwitch(int cycleNum, ENUM_GRID_MODE newMode, double sigmaMu)
   {
      AddEvent(DIAG_MODE_SWITCH, cycleNum, (double)newMode, sigmaMu, 0,
               StringFormat("Switched to %s", ModeToString(newMode)));
   }

   void OnRegimeRestart(int cycleNum, ENUM_GRID_MODE oldMode, ENUM_GRID_MODE newMode)
   {
      AddEvent(DIAG_REGIME_RESTART, cycleNum, (double)oldMode, (double)newMode, 0,
               StringFormat("Regime change %s->%s", ModeToString(oldMode), ModeToString(newMode)));
   }

   //--- Track P(ruin) and path-aware Lt per tick (throttled)
   void OnCalibrationUpdate(double pRuin, double pathAwareLt)
   {
      if(pRuin > m_curPeakPRuin) m_curPeakPRuin = pRuin;
      if(pathAwareLt > m_curPathAwareLtPeak) m_curPathAwareLtPeak = pathAwareLt;
   }

   //--- Call every tick (or throttled) to track RPR and equity extremes
   void OnTickUpdate(double rpr, double equity)
   {
      if(rpr > m_curPeakRPR) m_curPeakRPR = rpr;
      if(rpr > m_maxRPRever) m_maxRPRever = rpr;
      if(equity > m_peakEquity) m_peakEquity = equity;
      if(equity < m_troughEquity) m_troughEquity = equity;

      //--- Track peak cycle DD for cycle summary
      double cycleDDPct = rpr * 100;
      if(cycleDDPct > m_curPeakCycleDDPct) m_curPeakCycleDDPct = cycleDDPct;
   }

   //--- Set session range info before cycle end for diagnostic output
   void SetCycleSessionInfo(double sessionRange, double theoreticalLt)
   {
      m_curSessionRange   = sessionRange;
      m_curTheoreticalLt  = theoreticalLt;
   }

   //--- Set trend direction for current cycle
   void SetTrendDirection(int trendDir)
   {
      m_curTrendDirection = trendDir;
   }

   //=== FLUSH TO CSV ===

   void Flush()
   {
      if(m_flushed) return;
      m_flushed = true;

      string dateStr = TimeToString(TimeCurrent(), TIME_DATE);
      StringReplace(dateStr, ".", "");

      WriteBarSnapshotsCSV(dateStr);
      WriteCycleSummaryCSV(dateStr);
      WriteEventLogCSV(dateStr);

      PrintFormat("[DiagnosticLog] CSV export complete: %d snapshots, %d cycles, %d events",
                  m_snapCount, m_cycleCount, m_eventCount);
   }

   //=== INTERNAL ===

private:
   void ResetCycleCounters()
   {
      m_curTpHits          = 0;
      m_curWarningCloses   = 0;
      m_curDriftPauses     = 0;
      m_curCPDFires        = 0;
      m_curPeakRPR         = 0;
      m_curSessionRange    = 0;
      m_curTheoreticalLt   = 0;
      m_curGridMode        = GRID_MODE_BGT;
      m_curGridSpacing     = 0;
      m_curEffectiveBaseLot= 0;
      m_curPeakPRuin       = 0;
      m_curPathAwareLtPeak = 0;
      m_curSigmaMuAtStart  = 0;
      m_curAtrAtStart      = 0;
      m_curDriftAtStart    = 0;
      m_curTrendDirection  = 0;
      m_curStartTime       = 0;
      m_curStartEquity     = 0;
      m_curPeakCycleDDPct  = 0;
   }

   void ResetGlobalCounters()
   {
      m_totalTpHits          = 0;
      m_totalKillSwitchFires = 0;
      m_totalProfitRestarts  = 0;
      m_totalAgeRestarts     = 0;
      m_totalAgeBlocked      = 0;
      m_totalWarningCloses   = 0;
      m_totalOrphansSwept    = 0;
      m_totalDriftPauses     = 0;
      m_totalCloseRetries    = 0;
      m_maxRPRever           = 0;
      m_peakEquity           = 0;
      m_troughEquity         = DBL_MAX;
   }

   void FinishCycle(int cycleNum, double pnl, int positionsAtEnd,
                     ENUM_DIAG_EVENT endReason, double endEquity)
   {
      int newSize = m_cycleCount + 1;
      ArrayResize(m_cycles, newSize, 100);

      double durationHours = 0;
      if(m_curStartTime > 0)
         durationHours = (double)(TimeCurrent() - m_curStartTime) / 3600.0;

      double profitPct = 0;
      if(m_curStartEquity > 0)
         profitPct = pnl / m_curStartEquity * 100.0;

      m_runningCumulativeProfit += pnl;

      m_cycles[m_cycleCount].cycleNum         = cycleNum;
      m_cycles[m_cycleCount].startTime        = m_curStartTime;
      m_cycles[m_cycleCount].endTime          = TimeCurrent();
      m_cycles[m_cycleCount].durationHours    = durationHours;
      m_cycles[m_cycleCount].startEquity      = m_curStartEquity;
      m_cycles[m_cycleCount].endEquity        = endEquity;
      m_cycles[m_cycleCount].profit           = pnl;
      m_cycles[m_cycleCount].profitPct        = profitPct;
      m_cycles[m_cycleCount].gridSpacing      = m_curGridSpacing;
      m_cycles[m_cycleCount].baseLot          = m_curEffectiveBaseLot;
      m_cycles[m_cycleCount].gridMode         = m_curGridMode;
      m_cycles[m_cycleCount].sigmaMuAtStart   = m_curSigmaMuAtStart;
      m_cycles[m_cycleCount].atrAtStart       = m_curAtrAtStart;
      m_cycles[m_cycleCount].driftAtStart     = m_curDriftAtStart;
      m_cycles[m_cycleCount].trendDirection   = m_curTrendDirection;
      m_cycles[m_cycleCount].maxCycleDDPct    = m_curPeakCycleDDPct;
      m_cycles[m_cycleCount].maxRPRPct        = m_curPeakRPR * 100;
      m_cycles[m_cycleCount].peakPRuin        = m_curPeakPRuin;
      m_cycles[m_cycleCount].peakPathLt       = m_curPathAwareLtPeak;
      m_cycles[m_cycleCount].theoreticalLt    = m_curTheoreticalLt;
      m_cycles[m_cycleCount].sessionRange     = m_curSessionRange;
      m_cycles[m_cycleCount].tpHits           = m_curTpHits;
      m_cycles[m_cycleCount].warningCloses    = m_curWarningCloses;
      m_cycles[m_cycleCount].driftPauses      = m_curDriftPauses;
      m_cycles[m_cycleCount].cpdFires         = m_curCPDFires;
      m_cycles[m_cycleCount].positionsAtEnd   = positionsAtEnd;
      m_cycles[m_cycleCount].exitReason       = endReason;
      m_cycles[m_cycleCount].cumulativeProfit = m_runningCumulativeProfit;
      m_cycleCount++;
   }

   //=== CSV WRITERS ===

   void WriteBarSnapshotsCSV(string dateStr)
   {
      if(m_snapCount == 0) return;

      string filename = StringFormat("%s_BarSnapshots_%s_%s.csv",
                                      m_filePrefix, _Symbol, dateStr);
      int handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
      if(handle == INVALID_HANDLE)
      {
         PrintFormat("[DiagnosticLog] Failed to open %s (error %d)", filename, GetLastError());
         return;
      }

      //--- Header
      FileWrite(handle,
         "Time", "Bid", "Equity", "Balance", "FloatingPL",
         "SessionHigh", "SessionLow", "DtLevels", "UtLevels",
         "Lt_Formula", "Lt_PathAware", "Lt_Error",
         "CycleDD_Pct", "SnapshotRPR_Pct",
         "OpenBuys", "OpenSells", "ArmedBuys", "ArmedSells",
         "GridState", "GridMode", "TrendDirection",
         "SigmaMu", "ATR", "Drift",
         "GridSpacing", "BaseLot", "CycleNumber",
         "RuinProb_T53", "CUSUM_SHigh", "CUSUM_SLow");

      for(int i = 0; i < m_snapCount; i++)
      {
         FileWrite(handle,
            TimeToString(m_snapshots[i].time, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
            DoubleToString(m_snapshots[i].bid, 5),
            DoubleToString(m_snapshots[i].equity, 2),
            DoubleToString(m_snapshots[i].balance, 2),
            DoubleToString(m_snapshots[i].floatingPL, 2),
            DoubleToString(m_snapshots[i].sessionHigh, 5),
            DoubleToString(m_snapshots[i].sessionLow, 5),
            IntegerToString(m_snapshots[i].dtLevels),
            IntegerToString(m_snapshots[i].utLevels),
            DoubleToString(m_snapshots[i].ltFormula, 2),
            DoubleToString(m_snapshots[i].ltPathAware, 2),
            DoubleToString(m_snapshots[i].ltError, 2),
            DoubleToString(m_snapshots[i].cycleDDPct, 4),
            DoubleToString(m_snapshots[i].snapshotRPRPct, 4),
            IntegerToString(m_snapshots[i].openBuys),
            IntegerToString(m_snapshots[i].openSells),
            IntegerToString(m_snapshots[i].armedBuys),
            IntegerToString(m_snapshots[i].armedSells),
            GridStateToString(m_snapshots[i].gridState),
            ModeToString((ENUM_GRID_MODE)m_snapshots[i].gridMode),
            IntegerToString(m_snapshots[i].trendDirection),
            DoubleToString(m_snapshots[i].sigmaMu, 4),
            DoubleToString(m_snapshots[i].atr, 6),
            DoubleToString(m_snapshots[i].drift, 6),
            DoubleToString(m_snapshots[i].gridSpacing, 5),
            DoubleToString(m_snapshots[i].baseLot, 4),
            IntegerToString(m_snapshots[i].cycleNumber),
            DoubleToString(m_snapshots[i].ruinProbT53, 6),
            DoubleToString(m_snapshots[i].cusumSHigh, 6),
            DoubleToString(m_snapshots[i].cusumSLow, 6));
      }

      FileClose(handle);
      PrintFormat("[DiagnosticLog] Saved %d bar snapshots to %s", m_snapCount, filename);
   }

   void WriteCycleSummaryCSV(string dateStr)
   {
      if(m_cycleCount == 0) return;

      string filename = StringFormat("%s_CycleSummary_%s_%s.csv",
                                      m_filePrefix, _Symbol, dateStr);
      int handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
      if(handle == INVALID_HANDLE)
      {
         PrintFormat("[DiagnosticLog] Failed to open %s (error %d)", filename, GetLastError());
         return;
      }

      //--- Header
      FileWrite(handle,
         "CycleNumber", "StartTime", "EndTime", "DurationHours",
         "StartEquity", "EndEquity", "Profit", "ProfitPct",
         "GridSpacing", "BaseLot", "GridMode",
         "SigmaMuAtStart", "ATRAtStart", "DriftAtStart", "TrendDirection",
         "MaxCycleDD_Pct", "MaxRPR_Pct", "PeakPRuin", "PeakPathLt",
         "TheoreticalLt", "SessionRange",
         "TpHits", "WarningCloses", "DriftPauses", "CPDFires",
         "PositionsAtEnd", "ExitReason", "CumulativeProfit");

      for(int i = 0; i < m_cycleCount; i++)
      {
         FileWrite(handle,
            IntegerToString(m_cycles[i].cycleNum),
            TimeToString(m_cycles[i].startTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
            TimeToString(m_cycles[i].endTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
            DoubleToString(m_cycles[i].durationHours, 2),
            DoubleToString(m_cycles[i].startEquity, 2),
            DoubleToString(m_cycles[i].endEquity, 2),
            DoubleToString(m_cycles[i].profit, 2),
            DoubleToString(m_cycles[i].profitPct, 4),
            DoubleToString(m_cycles[i].gridSpacing, 5),
            DoubleToString(m_cycles[i].baseLot, 4),
            ModeToString(m_cycles[i].gridMode),
            DoubleToString(m_cycles[i].sigmaMuAtStart, 4),
            DoubleToString(m_cycles[i].atrAtStart, 6),
            DoubleToString(m_cycles[i].driftAtStart, 6),
            IntegerToString(m_cycles[i].trendDirection),
            DoubleToString(m_cycles[i].maxCycleDDPct, 4),
            DoubleToString(m_cycles[i].maxRPRPct, 4),
            DoubleToString(m_cycles[i].peakPRuin, 6),
            DoubleToString(m_cycles[i].peakPathLt, 2),
            DoubleToString(m_cycles[i].theoreticalLt, 2),
            DoubleToString(m_cycles[i].sessionRange, 5),
            IntegerToString(m_cycles[i].tpHits),
            IntegerToString(m_cycles[i].warningCloses),
            IntegerToString(m_cycles[i].driftPauses),
            IntegerToString(m_cycles[i].cpdFires),
            IntegerToString(m_cycles[i].positionsAtEnd),
            ExitReasonToString(m_cycles[i].exitReason),
            DoubleToString(m_cycles[i].cumulativeProfit, 2));
      }

      FileClose(handle);
      PrintFormat("[DiagnosticLog] Saved %d cycle summaries to %s", m_cycleCount, filename);
   }

   void WriteEventLogCSV(string dateStr)
   {
      if(m_eventCount == 0) return;

      string filename = StringFormat("%s_EventLog_%s_%s.csv",
                                      m_filePrefix, _Symbol, dateStr);
      int handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
      if(handle == INVALID_HANDLE)
      {
         PrintFormat("[DiagnosticLog] Failed to open %s (error %d)", filename, GetLastError());
         return;
      }

      //--- Header
      FileWrite(handle, "Time", "CycleNumber", "EventType", "Value1", "Value2", "Value3", "Detail");

      for(int i = 0; i < m_eventCount; i++)
      {
         FileWrite(handle,
            TimeToString(m_events[i].time, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
            IntegerToString(m_events[i].cycleNum),
            m_events[i].eventType,
            DoubleToString(m_events[i].value1, 5),
            DoubleToString(m_events[i].value2, 5),
            DoubleToString(m_events[i].value3, 5),
            m_events[i].detail);
      }

      FileClose(handle);
      PrintFormat("[DiagnosticLog] Saved %d events to %s", m_eventCount, filename);
   }

   //=== HELPERS ===

   string GridStateToString(int state)
   {
      switch(state)
      {
         case GRID_STATE_IDLE:    return "IDLE";
         case GRID_STATE_ACTIVE:  return "ACTIVE";
         case GRID_STATE_PAUSED:  return "PAUSED";
         case GRID_STATE_CLOSING: return "CLOSING";
         default:                 return "UNKNOWN";
      }
   }

   string EventName(ENUM_DIAG_EVENT e)
   {
      switch(e)
      {
         case DIAG_CYCLE_START:       return "CYCLE_START";
         case DIAG_CYCLE_PROFIT_END:  return "PROFIT_END";
         case DIAG_CYCLE_KILL_END:    return "KILL_END";
         case DIAG_CYCLE_AGE_END:     return "AGE_END";
         case DIAG_CYCLE_AGE_BLOCKED: return "AGE_BLOCKED";
         case DIAG_DRIFT_PAUSE:       return "DRIFT_PAUSE";
         case DIAG_DRIFT_RESUME:      return "DRIFT_RESUME";
         case DIAG_VOL_PAUSE:         return "VOL_PAUSE";
         case DIAG_VOL_RESUME:        return "VOL_RESUME";
         case DIAG_WARNING_CLOSE:     return "WARN_CLOSE";
         case DIAG_ORPHAN_CLOSED:     return "ORPHAN_CLOSE";
         case DIAG_CLOSE_RETRY:       return "CLOSE_RETRY";
         case DIAG_NO_MONEY:          return "NO_MONEY";
         case DIAG_CPD_FIRE:          return "CPD_FIRE";
         case DIAG_MODE_SWITCH:       return "MODE_SWITCH";
         case DIAG_REGIME_RESTART:    return "REGIME_RESTART";
         case DIAG_CYCLE_REGIME_END:  return "REGIME_END";
         case DIAG_PRICE_LEVEL_BLOCK: return "PRICELEVEL_BLOCK";
         case DIAG_PRICE_LEVEL_CLEAR: return "PRICELEVEL_CLEAR";
         case DIAG_WEEKEND_CLOSE:     return "WEEKEND_CLOSE";
         case DIAG_WEEKEND_RESUME:    return "WEEKEND_RESUME";
         default:                     return "UNKNOWN";
      }
   }

   string ExitReasonToString(ENUM_DIAG_EVENT reason)
   {
      switch(reason)
      {
         case DIAG_CYCLE_PROFIT_END: return "PROFIT";
         case DIAG_CYCLE_KILL_END:   return "KILL";
         case DIAG_CYCLE_AGE_END:    return "AGE";
         case DIAG_CYCLE_REGIME_END: return "REGIME";
         case DIAG_WEEKEND_CLOSE:    return "WEEKEND";
         default:                    return "OTHER";
      }
   }

   string ModeToString(ENUM_GRID_MODE mode)
   {
      switch(mode)
      {
         case GRID_MODE_BGT: return "BGT";
         case GRID_MODE_TGT: return "TGT";
         case GRID_MODE_MGT: return "MGT";
         default:            return "???";
      }
   }
};

#endif // __DIAGNOSTIC_LOG_MQH__
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                      GridEA.mq5  |
//|                      BGC Grid Trading Expert Advisor             |
//|                      Based on Taranto & Khan (2020-2021)         |
//|                      Bi-Directional Grid Constrained Trading     |
//+------------------------------------------------------------------+
#property copyright "BGC Grid EA"
#property version   "3.00"
#property strict

//--- Module includes
#include "Defines.mqh"
#include "StateManager.mqh"
#include "LotEngine.mqh"
#include "GridCore.mqh"
#include "LtMonitor.mqh"
#include "ProfitMonitor.mqh"
#include "VolatilityGate.mqh"
#include "CPDEngine.mqh"
#include "DiagnosticLog.mqh"

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+

//--- Grid Structure
input group "=== Grid Structure ==="
input double InpGridSpacing         = 500;      // Grid Spacing (points) — XAUUSD 2-digit: 500pts = $5.00
input int    InpGridLevels          = 8;        // Grid Levels (per side)
input double InpBaseLot             = 0.01;     // Base Lot Size

//--- Lot Mode
input group "=== Lot Sizing ==="
input bool   InpUseMildMultiplier   = true;     // Use Mild Multiplier (false=Dynamic)
input double InpLotMultiplier       = 1.0;      // Lot Multiplier per Level (1.0=flat, research-correct)

//--- Exit Conditions
input group "=== Exit Conditions ==="
input double InpRuinThreshold       = 0.25;     // Kill Switch: RPR Threshold (cut bad cycles early)
input double InpWarningThreshold    = 0.15;     // Warning: Start closing worst losers at this RPR
input double InpProfitTargetDollars = 50.0;     // Profit Target ($)
input bool   InpUseProfitPercent    = true;     // Use % Instead of $
input double InpProfitTargetPercent = 3.0;      // Profit Target (%) — research: 2-5% per cycle

//--- Variance Age Monitor
input group "=== Cycle Age Limit ==="
input int    InpMaxCycleHours       = 72;       // Max Cycle Duration (hours) — force restart

//--- Volatility & Drift Gate
input group "=== Volatility & Drift Gate ==="
input int    InpATRPeriod           = 14;       // ATR Period
input int    InpMAPeriod            = 20;       // MA Period for Drift Detection
input double InpMinVolatilityRatio  = 0.5;      // Min ATR/GridSpacing Ratio
input double InpMaxVolatilityRatio  = 5.0;      // Max ATR/GridSpacing Ratio
input double InpMinSigmaMuRatio    = 5.0;       // Min σt/μt Ratio (>5 = ranging, <5 = trending danger)
input int    InpDriftCooldownBars   = 3;        // Drift Cooldown (bars clear before resume)

//--- Risk
input group "=== Risk Management ==="
input double InpMaxSpreadPoints     = 50;       // Max Spread (points)
input double InpMaxLotSize          = 0.5;      // Max Lot Size (hard cap)
input double InpMinFreeMargin       = 800.0;    // Min Free Margin to Place Orders (0=disabled)
input int    InpMagicNumber         = 202603;   // Magic Number

//--- ATR-dynamic grid spacing
input group "=== Dynamic Grid Spacing ==="
input bool   InpUseATRSpacing        = true;    // Use ATR-Dynamic Spacing
input int    InpATRSpacingPeriod      = 20;       // ATR Period for Spacing (daily bars)
input ENUM_TIMEFRAMES InpATRSpacingTF = PERIOD_D1; // ATR Timeframe for Spacing
input double InpATRSpacingMultiplier  = 0.12;     // ATR Multiplier (0.10-0.15 of ADR)
input double InpMinGridSpacingPts     = 200;      // Min Grid Spacing (points, safety floor)
input double InpMaxGridSpacingPts     = 2000;     // Max Grid Spacing (points, safety ceiling)

//--- Dynamic base lot sizing per cycle
input group "=== Dynamic Lot Sizing ==="
input bool   InpUseDynamicBaseLot = true;   // Dynamic Base Lot (compound with equity)
input double InpLotFraction       = 0.000003; // Lot Fraction (0.000003 = 0.03 lot per $10,000)

//--- Change point detection (CUSUM)
input group "=== Change Point Detection ==="
input bool   InpUseCPD        = true;  // Enable CPD (CUSUM)
input int    InpCPDWindow     = 50;     // Baseline Estimation Window (bars)
input double InpCPDDelta      = 2.0;    // Min Detectable Shift (x baseline sigma)
input double InpCPDThreshold  = 15.0;   // CUSUM Threshold h

//--- Mode switching (TGT/MGT)
input group "=== Mode Switching ==="
input bool   InpEnableTGT           = true;  // Enable TGT Mode (trending grid)
input bool   InpEnableMGT           = true;  // Enable MGT Mode (mean-reversion grid)
input double InpTGTSigmaMuThreshold = 5.0;    // sigma_t/mu_t Threshold for TGT activation
input ENUM_TIMEFRAMES InpRegimeTF        = PERIOD_H4; // Regime Detection Timeframe (drift/CPD)
input bool   InpBuyBiasAboveAnchor = false;  // Buy Bias Above Anchor (BGT: skip sells above anchor)
input bool   InpDisableBGT         = false;  // Disable BGT Mode (only TGT/MGT, wait when ambiguous)
input double InpMGTKillThreshold   = 0.10;   // MGT Kill Switch Threshold (0=use general threshold)

//--- Price-Level Filter (avoid anchoring at extremes)
input group "=== Price-Level Filter ==="
input bool   InpUsePriceLevelFilter    = true;   // Enable Price-Level Filter
input int    InpPriceLevelLookbackBars = 30;      // Lookback Period (regime-TF bars, 30 H4 bars ≈ 5 days)
input double InpMinATRDistFromExtreme  = 0.5;     // Min ATR Distance From Nearest Extreme (0.5 = half ATR)

//--- Weekend Close
input group "=== Weekend Close ==="
input bool   InpEnableWeekendClose = true;   // Enable Weekend Close (flat over weekend)
input int    InpFridayCloseHour   = 22;      // Friday Close Hour (server time, 0-23)
input int    InpMondayResumeHour  = 1;       // Monday Resume Hour (server time, 0-23)

//--- Diagnostics
input group "=== Diagnostics ==="
input bool   InpEnableDiagnostics = false;   // Enable CSV Diagnostic Logging

//+------------------------------------------------------------------+
//| Global module instances                                          |
//+------------------------------------------------------------------+
GridSession     g_session;
CStateManager   g_stateManager;
CLotEngine      g_lotEngine;
CGridCore       g_gridCore;
CLtMonitor      g_ltMonitor;
CProfitMonitor  g_profitMonitor;
CVolatilityGate g_volatilityGate;
CCPDEngine      g_cpdEngine;
CDiagnosticLog  g_diag;

//--- Performance: throttle intervals to reduce per-tick overhead
#define REARM_INTERVAL       5     // RearmGrid every N ticks
#define PROFIT_INTERVAL      10    // Profit check every N ticks
#define STATE_SAVE_INTERVAL  500   // Persist state every N ticks
#define WARNING_INTERVAL     20    // Warning-level loss reduction every N ticks
#define DIAG_INTERVAL        50    // Diagnostic equity/RPR tracking

//--- Derived values
double         g_gridSpacingPrice;    // Grid spacing in price units (not points)
datetime       g_lastBarTime;         // For new bar detection
datetime       g_lastRegimeBarTime;   // Track regime TF bar changes for CPD feeding
bool           g_volatilityOK;        // Cached volatility gate result
bool           g_isNewBar;            // Set true on bar change, consumed by RearmGrid
int            g_tickCounter;         // Tick counter for throttling
double         g_lastRPR;             // Cached RPR for lot recomputation decisions
bool           g_wasPaused;           // Track pause→resume transitions for logging

//--- ATR-dynamic spacing handle
int            g_spacingATRHandle;    // Separate ATR handle for spacing (daily TF)

//--- Dynamic lot sizing
double         g_effectiveBaseLot;    // Actual base lot used this cycle

//--- CPD regime-change block
bool           g_cpdBlockActive;      // True when CPD fires — gates next cycle start

//--- TGT/MGT mode-switching state
bool           g_lastCycleWasTGTKill; // Set true when TGT cycle ends via kill switch

//--- Price-level filter state
bool           g_priceLevelBlocked;   // True when price is too close to recent extreme

//--- Cycle-blocked guard: prevents cycle-ending logic on cycles that never placed orders
bool           g_cycleBlocked;        // True when StartNewCycle() was blocked by CPD or price-level filter

//--- Weekend close state
bool           g_weekendClosed;       // True from Friday close until Monday resume

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate inputs
   if(InpGridSpacing <= 0)
   {
      Alert("[BGC Grid] Invalid input: GridSpacing must be greater than 0.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpGridLevels <= 0 || InpGridLevels > MAX_GRID_LEVELS)
   {
      Alert(StringFormat("[BGC Grid] Invalid input: GridLevels must be between 1 and %d.",
                         MAX_GRID_LEVELS));
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpBaseLot <= 0)
   {
      Alert("[BGC Grid] Invalid input: BaseLot must be greater than 0.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpRuinThreshold <= 0 || InpRuinThreshold > 1.0)
   {
      Alert("[BGC Grid] Invalid input: RuinThreshold must be in the range (0.0, 1.0].");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpWarningThreshold >= InpRuinThreshold)
   {
      Alert("[BGC Grid] Invalid input: WarningThreshold must be lower than RuinThreshold.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpLotMultiplier < 1.0)
   {
      Alert("[BGC Grid] Invalid input: LotMultiplier must be at least 1.0.");
      return INIT_PARAMETERS_INCORRECT;
   }

   //--- Check hedging account
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) !=
      ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Alert("[BGC Grid] Initialization failed: this EA requires a hedging account. "
            "The current margin mode does not support hedging.");
      return INIT_FAILED;
   }

   //--- Convert grid spacing from points to price
   g_gridSpacingPrice = InpGridSpacing * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   //--- Validate grid spacing exceeds broker minimum stop distance
   long stopsLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(InpGridSpacing < stopsLevelPts)
   {
      Alert(StringFormat("[BGC Grid] Invalid input: GridSpacing (%.0f pts) is below the broker's "
                         "minimum stop distance (%d pts).",
                         InpGridSpacing, (int)stopsLevelPts));
      return INIT_PARAMETERS_INCORRECT;
   }

   //--- Initialise modules
   g_stateManager.Init(InpMagicNumber, _Symbol);
   g_effectiveBaseLot = InpBaseLot;
   g_lotEngine.Init(_Symbol, InpBaseLot, InpLotMultiplier, InpMaxLotSize, InpUseMildMultiplier);
   g_gridCore.Init(_Symbol, InpMagicNumber, DEFAULT_SLIPPAGE, &g_lotEngine, g_gridSpacingPrice,
                   InpBuyBiasAboveAnchor, InpMinFreeMargin);
   g_ltMonitor.Init(_Symbol);
   g_profitMonitor.Init(InpMagicNumber, _Symbol);

   if(!g_volatilityGate.Init(_Symbol, InpRegimeTF, InpATRPeriod, InpMAPeriod,
                             InpDriftCooldownBars))
   {
      Alert("[BGC Grid] Initialization warning: ATR/MA indicators could not be initialized.");
   }

   //--- Create dedicated ATR handle for dynamic spacing
   g_spacingATRHandle = INVALID_HANDLE;
   if(InpUseATRSpacing)
   {
      g_spacingATRHandle = iATR(_Symbol, InpATRSpacingTF, InpATRSpacingPeriod);
      if(g_spacingATRHandle == INVALID_HANDLE)
      {
         Alert("[BGC Grid] Initialization warning: ATR spacing handle could not be created. "
               "Falling back to fixed spacing.");
      }
   }

   //--- Initialise CPD engine
   g_cpdEngine.Init(InpUseCPD, InpCPDWindow, InpCPDDelta, InpCPDThreshold);

   //--- Initialise diagnostic CSV logger
   if(InpEnableDiagnostics)
      g_diag.Init("BGCGrid");

   //--- Initialise tracking variables
   g_lastBarTime   = 0;
   g_lastRegimeBarTime = 0;
   g_volatilityOK  = true;
   g_wasPaused    = false;
   g_isNewBar     = false;
   g_tickCounter  = 0;
   g_lastRPR      = 0;
   g_cpdBlockActive      = false;
   g_lastCycleWasTGTKill = false;
   g_priceLevelBlocked   = false;
   g_cycleBlocked        = false;
   g_weekendClosed       = false;

   //--- Weekend check on init: if starting during weekend window, don't open positions
   if(InpEnableWeekendClose)
   {
      MqlDateTime initDt;
      TimeCurrent(initDt);
      bool isFridayAfterClose = (initDt.day_of_week == 5 && initDt.hour >= InpFridayCloseHour);
      bool isSatOrSun         = (initDt.day_of_week == 6 || initDt.day_of_week == 0);
      bool isMondayBeforeResume = (initDt.day_of_week == 1 && initDt.hour < InpMondayResumeHour);
      if(isFridayAfterClose || isSatOrSun || isMondayBeforeResume)
      {
         g_weekendClosed = true;
         g_session.state = GRID_STATE_PAUSED;
         PrintFormat("[BGC Grid] Started during weekend window (day=%d, hour=%d). "
                     "Waiting until Monday %02d:00 before opening a new cycle.",
                     initDt.day_of_week, initDt.hour, InpMondayResumeHour);
         return INIT_SUCCEEDED;
      }
   }

   //--- Check for saved state (resume after restart)
   if(g_stateManager.HasSavedState())
   {
      if(g_stateManager.LoadState(g_session, g_gridSpacingPrice, InpUseATRSpacing))
      {
         g_gridCore.RecoverPositions(g_session);

         PrintFormat("[BGC Grid] Loaded saved state. Anchor=%.5f, Cycle #%d, "
                     "CumulativeProfit=$%.2f",
                     g_session.anchorPrice, g_session.cycleCount,
                     g_session.cumulativeProfit);
      }
      else
      {
         StartNewCycle();
      }
   }
   else
   {
      StartNewCycle();
   }

   PrintFormat("[BGC Grid] Initialized: Spacing=%.2f (%g pts, %s), Levels=%d, BaseLot=%.2f (%s), "
               "LotMode=%s, RuinThreshold=%.0f%%, WarningThreshold=%.0f%%, MaxCycleHrs=%d, "
               "TGT=%s, MGT=%s, CPD=%s",
               g_gridSpacingPrice, InpGridSpacing,
               InpUseATRSpacing ? "ATR-Dynamic" : "Fixed",
               InpGridLevels, g_effectiveBaseLot,
               InpUseDynamicBaseLot ? "Dynamic" : "Fixed",
               InpUseMildMultiplier ? "MildMultiplier" : "Dynamic",
               InpRuinThreshold * 100, InpWarningThreshold * 100,
               InpMaxCycleHours,
               InpEnableTGT ? "ON" : "OFF",
               InpEnableMGT ? "ON" : "OFF",
               InpUseCPD ? "ON" : "OFF");

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_session.state == GRID_STATE_ACTIVE || g_session.state == GRID_STATE_PAUSED)
   {
      g_stateManager.SaveState(g_session);
      PrintFormat("[BGC Grid] State saved on deinit. Reason=%d", reason);
   }

   //--- Flush diagnostic CSV on shutdown unless OnTester already handled it
   if(InpEnableDiagnostics && !MQLInfoInteger(MQL_TESTER))
      g_diag.Flush();

   g_volatilityGate.Deinit();

   //--- Release ATR spacing handle
   if(g_spacingATRHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_spacingATRHandle);
      g_spacingATRHandle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Strategy Tester end-of-run callback                              |
//+------------------------------------------------------------------+
double OnTester()
{
   //--- Flush diagnostic CSV at end of backtest
   if(InpEnableDiagnostics)
      g_diag.Flush();

   //--- Return cumulative profit as custom criterion
   return g_session.cumulativeProfit;
}

//+------------------------------------------------------------------+
//| Expert tick function — main loop                                 |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Skip if halted after ruin
   if(g_session.state == GRID_STATE_IDLE)
      return;

   //--- Skip if in the middle of closing
   if(g_session.state == GRID_STATE_CLOSING)
      return;

   //=== WEEKEND CLOSE / MONDAY RESUME ===
   if(InpEnableWeekendClose)
   {
      MqlDateTime dt;
      TimeCurrent(dt);

      //--- Friday close: close all positions, cancel orders, set weekend flag
      if(!g_weekendClosed && dt.day_of_week == 5 && dt.hour >= InpFridayCloseHour)
      {
         double cycleProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);

         PrintFormat("[BGC Grid] Weekend close at Friday %02d:00. Closing all positions. "
                     "Cycle P/L=$%.2f",
                     dt.hour, cycleProfit);

         g_session.state = GRID_STATE_CLOSING;
         int wkndOrphans = 0;
         g_gridCore.CloseAllPositions(g_session, wkndOrphans);
         if(InpEnableDiagnostics && wkndOrphans > 0) g_diag.OnOrphanClosed(wkndOrphans);

         double finalProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
         CaptureCycleSessionInfo();
         if(InpEnableDiagnostics)
            g_diag.OnWeekendClose(g_session.cycleCount, finalProfit,
                                   AccountInfoDouble(ACCOUNT_EQUITY));

         g_session.cumulativeProfit += finalProfit;
         g_session.cycleCount++;
         g_stateManager.ClearState();

         g_weekendClosed = true;
         g_session.state = GRID_STATE_PAUSED;
         return;
      }

      //--- Weekend: stay flat (Saturday or Sunday, or Friday after close)
      if(g_weekendClosed)
      {
         //--- Monday resume: clear flag and start fresh cycle
         if(dt.day_of_week == 1 && dt.hour >= InpMondayResumeHour)
         {
            g_weekendClosed = false;
            if(InpEnableDiagnostics)
               g_diag.OnWeekendResume(g_session.cycleCount, AccountInfoDouble(ACCOUNT_EQUITY));
            PrintFormat("[BGC Grid] Monday resume at %02d:00. Starting a new cycle.",
                        dt.hour);
            StartNewCycle();
            return;
         }

         //--- Still weekend — do nothing
         return;
      }
   }

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(bid <= 0)
      return;

   g_tickCounter++;

   //=== KILL SWITCH: Equity-based cycle drawdown (checked every tick) ===
   //    The research Lt formula assumes each level fills once. With re-arming,
   //    the snapshot RPR understates cumulative damage. Use actual equity change
   //    as the true kill switch — it captures realized losses, floating losses,
   //    swaps, commissions, and all re-arming damage.
   double cycleDrawdown = 0;
   if(g_session.cycleStartEquity > 0)
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      cycleDrawdown = (g_session.cycleStartEquity - currentEquity) / g_session.cycleStartEquity;
   }

   //--- Also compute snapshot RPR for diagnostics and warning closer
   double rpr = 0, lt = 0, weightedLoss = 0;
   g_ltMonitor.OnTick(g_session, bid, 999.0, rpr, lt, weightedLoss);  // never fire on snapshot RPR
   g_lastRPR = rpr;

   //--- Count open positions for this EA (used to guard cycle-ending logic).
   //    Cycle-ending must ALWAYS fire when real positions are open, even if
   //    g_cycleBlocked is stale. Only skip when truly blocked with 0 positions.
   int openPositionCount = g_profitMonitor.GetPositionCount();
   bool cycleIsEmpty = (g_cycleBlocked && openPositionCount == 0);

   double effectiveKillThreshold = InpRuinThreshold;
   if(g_session.gridMode == GRID_MODE_MGT && InpMGTKillThreshold > 0)
      effectiveKillThreshold = InpMGTKillThreshold;

   if(!cycleIsEmpty && cycleDrawdown >= effectiveKillThreshold)
   {
      //--- Track if TGT cycle ended via kill switch → trigger MGT next cycle
      if(g_session.gridMode == GRID_MODE_TGT)
         g_lastCycleWasTGTKill = true;

      //--- Kill switch fired — equity drawdown exceeds threshold
      g_session.state = GRID_STATE_CLOSING;
      int killOrphans = 0;
      g_gridCore.CloseAllPositions(g_session, killOrphans);
      if(InpEnableDiagnostics && killOrphans > 0) g_diag.OnOrphanClosed(killOrphans);

      double finalLoss = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
      CaptureCycleSessionInfo();
      if(InpEnableDiagnostics)
         g_diag.OnCycleEndKill(g_session.cycleCount, cycleDrawdown, finalLoss,
                                AccountInfoDouble(ACCOUNT_EQUITY));

      g_session.cumulativeProfit += finalLoss;
      g_session.cycleCount++;
      g_stateManager.ClearState();

      PrintFormat("[BGC Grid] Kill switch triggered. CycleDD=%.1f%% (threshold %.1f%%), "
                  "SnapshotRPR=%.1f%%, Loss=$%.2f. Starting a new cycle.",
                  cycleDrawdown * 100, effectiveKillThreshold * 100, rpr * 100, finalLoss);

      StartNewCycle();
      return;
   }

   //--- Diagnostic: track cycle drawdown, equity, and calibration metrics (throttled)
   if(InpEnableDiagnostics && g_tickCounter % DIAG_INTERVAL == 0)
   {
      g_diag.OnTickUpdate(cycleDrawdown, AccountInfoDouble(ACCOUNT_EQUITY));

      //--- Calibration diagnostics: P(ruin) and path-aware Lt
      double currentEquityDiag = AccountInfoDouble(ACCOUNT_EQUITY);
      double totalEquity = AccountInfoDouble(ACCOUNT_BALANCE);
      double pRuin = g_ltMonitor.ComputeRuinProbability(
                        currentEquityDiag, totalEquity,
                        g_effectiveBaseLot, g_gridSpacingPrice, 0);
      double pathLt = g_ltMonitor.ComputePathAwareLt(g_session, bid);
      g_diag.OnCalibrationUpdate(pRuin, pathLt);

      //--- Check for ghost arms (ticket=0 margin rejects) since last check
      int ghostArms = g_gridCore.ConsumeGhostArmCount();
      if(ghostArms > 0)
         g_diag.OnNoMoney(g_session.cycleCount, ghostArms);
   }

   //=== Warning-level loss reduction (currently disabled) ===
   //    In trending conditions, repeated warning closes can create an adverse
   //    close-rearm-fill loop: each close realizes a loss, the position is
   //    re-armed immediately, and the closer may fire again. In backtests this
   //    increased equity damage instead of reducing it. Re-enable only after
   //    the regime filters are fully validated for sustained trends.
   // if(g_tickCounter % WARNING_INTERVAL == 0 && cycleDrawdown >= InpWarningThreshold)
   // {
   //    if(g_gridCore.CloseWorstLoser(g_session))
   //    {
   //       g_diag.OnWarningClose(g_session.cycleCount, cycleDrawdown, 0);
   //       PrintFormat("[BGC Grid] Warning threshold reached: CycleDD=%.1f%%. Closed the highest-loss position.",
   //                   cycleDrawdown * 100);
   //    }
   // }

   //=== KILL SWITCH 2: Profit Monitor (throttled) ===
   if(!cycleIsEmpty && g_tickCounter % PROFIT_INTERVAL == 0)
   {
      double cycleProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);

      if(g_profitMonitor.CheckProfitTarget(cycleProfit, g_session.cycleStartEquity,
                                            InpUseProfitPercent, InpProfitTargetDollars,
                                            InpProfitTargetPercent))
      {
         g_profitMonitor.NotifyProfitTarget(cycleProfit, g_session.cycleCount,
                                             g_session.cycleStartTime);

         g_session.state = GRID_STATE_CLOSING;
         int profitOrphans = 0;
         int closedCount = g_gridCore.CloseAllPositions(g_session, profitOrphans);
         if(InpEnableDiagnostics && profitOrphans > 0) g_diag.OnOrphanClosed(profitOrphans);

         int remaining = g_profitMonitor.GetPositionCount();
         if(remaining > 0)
         {
            PrintFormat("[BGC Grid] CloseAllPositions incomplete: %d positions remain open. "
                        "Retrying on the next tick.", remaining);
            if(InpEnableDiagnostics)
               g_diag.OnCloseRetry(g_session.cycleCount, remaining);
            g_session.state = GRID_STATE_ACTIVE;
            return;
         }

         double finalProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
         CaptureCycleSessionInfo();
         if(InpEnableDiagnostics)
            g_diag.OnCycleEndProfit(g_session.cycleCount, finalProfit, 0, AccountInfoDouble(ACCOUNT_EQUITY));

         g_session.cumulativeProfit += finalProfit;
         g_session.cycleCount++;
         g_stateManager.ClearState();

         StartNewCycle();

         PrintFormat("[BGC Grid] Restarted as cycle #%d. Closed %d positions. "
                     "Cycle profit: $%.2f, Cumulative: $%.2f",
                     g_session.cycleCount, closedCount,
                     finalProfit, g_session.cumulativeProfit);
         return;
      }
   }

   //=== VARIANCE AGE MONITOR + VOLATILITY GATE (check on new bar only) ===
   g_isNewBar = false;
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBarTime != g_lastBarTime)
   {
      g_lastBarTime  = currentBarTime;
      g_isNewBar     = true;

      //--- Capture per-bar diagnostic snapshot
      if(InpEnableDiagnostics)
      {
         BarSnapshot snap = BuildBarSnapshot();
         g_diag.RecordBarSnapshot(snap);
      }

      //--- Check cycle age — research: restart resets variance accumulation.
      //    Holding an aged cycle longer only deepens the loss.
      //    Skip if cycle is blocked with no positions — no variance to reset.
      if(!cycleIsEmpty && InpMaxCycleHours > 0)
      {
         long cycleAgeSec = (long)(TimeCurrent() - g_session.cycleStartTime);
         long maxAgeSec   = (long)InpMaxCycleHours * 3600;

         if(cycleAgeSec >= maxAgeSec)
         {
            double cycleProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
            int    hours       = (int)(cycleAgeSec / 3600);

            PrintFormat("[BGC Grid] Cycle age limit reached: %d hours (max %d). "
                        "P/L=$%.2f. Restarting to reset accumulated variance.",
                        hours, InpMaxCycleHours, cycleProfit);

            g_session.state = GRID_STATE_CLOSING;
            int ageOrphans = 0;
            g_gridCore.CloseAllPositions(g_session, ageOrphans);
            if(InpEnableDiagnostics && ageOrphans > 0) g_diag.OnOrphanClosed(ageOrphans);

            double finalProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
            CaptureCycleSessionInfo();
            if(InpEnableDiagnostics)
               g_diag.OnCycleEndAge(g_session.cycleCount, hours, finalProfit,
                                     AccountInfoDouble(ACCOUNT_EQUITY));

            g_session.cumulativeProfit += finalProfit;
            g_session.cycleCount++;
            g_stateManager.ClearState();

            StartNewCycle();
            return;
         }
      }

      //--- Volatility + drift gate (combined check)
      //    When ATR-dynamic spacing is active, skip the ATR magnitude check:
      //    spacing is derived from the same ATR so the ratio is just 1/multiplier.
      bool wasOK = g_volatilityOK;
      g_volatilityOK = g_volatilityGate.IsVolatilityFavorable(
                           g_gridSpacingPrice, InpMinVolatilityRatio, InpMaxVolatilityRatio,
                           InpMinSigmaMuRatio, InpUseATRSpacing);

      //--- Feed CPD only on regime-timeframe bar changes
      //    Drift observations come from regime TF ATR/MA; feeding every M1 bar
      //    would repeat the same value many times/day, causing excessive fires.
      //    CPD fires set g_cpdBlockActive which gates the NEXT cycle start.
      //    Block clears when σ/μ recovers (g_volatilityOK, which includes cooldown).
      if(g_cpdEngine.IsEnabled())
      {
         datetime currentRegimeBarTime = iTime(_Symbol, InpRegimeTF, 0);
         if(currentRegimeBarTime != g_lastRegimeBarTime)
         {
            g_lastRegimeBarTime = currentRegimeBarTime;
            double driftObs = g_volatilityGate.GetLastDrift();
            bool cpdFired = g_cpdEngine.OnNewBar(driftObs);
            if(cpdFired)
            {
               g_cpdBlockActive = true;
               if(InpEnableDiagnostics)
                  g_diag.OnCPDFire(g_session.cycleCount,
                                    g_cpdEngine.GetSHigh(), g_cpdEngine.GetSLow());

               PrintFormat("[BGC Grid] CPD change point detected. "
                           "SHigh=%.2f SLow=%.2f. The next cycle will use TGT%s.",
                           g_cpdEngine.GetSHigh(), g_cpdEngine.GetSLow(),
                           InpEnableTGT ? "" : " (TGT is disabled, so cycle start will remain blocked)");
            }
         }

         //--- Clear CPD block when σ/μ recovers through the cooldown period
         if(g_cpdBlockActive && g_volatilityOK)
         {
            g_cpdBlockActive = false;
            PrintFormat("[BGC Grid] CPD block cleared after cooldown: σ/μ=%.2f above %.2f",
                        g_volatilityGate.GetSigmaMuRatio(), InpMinSigmaMuRatio);

            //--- If cycle was delayed by CPD block, start it now
            if(g_session.state == GRID_STATE_PAUSED && !InpEnableTGT)
            {
               PrintFormat("[BGC Grid] Starting delayed cycle after the CPD block cleared");
               StartNewCycle();
            }
         }
      }

      //--- Price-level filter recovery: re-check on each new bar
      //    If price has retraced sufficiently from the extreme, clear the block.
      if(g_priceLevelBlocked && g_session.state == GRID_STATE_PAUSED)
      {
         double recDistHigh = 0, recDistLow = 0, recMinDist = 0;
         if(!IsPriceAtExtreme(recDistHigh, recDistLow, recMinDist))
         {
            g_priceLevelBlocked = false;
            if(InpEnableDiagnostics)
               g_diag.OnPriceLevelClear(g_session.cycleCount);
            PrintFormat("[BGC Grid] Price-level filter cleared. "
                        "DistHigh=%.2f, DistLow=%.2f, MinDist=%.2f",
                        recDistHigh, recDistLow, recMinDist);
            StartNewCycle();
            if(g_session.state != GRID_STATE_PAUSED)
               return;  // cycle started successfully
         }
      }

      //--- BGT-disabled recovery: re-check on each new bar
      //    If BGT is disabled and the cycle is blocked waiting for TGT/MGT conditions,
      //    try StartNewCycle() again because DetermineGridMode() may now return TGT/MGT.
      if(InpDisableBGT && g_cycleBlocked && g_session.state == GRID_STATE_PAUSED
         && !g_priceLevelBlocked && !g_cpdBlockActive)
      {
         StartNewCycle();
         if(g_session.state != GRID_STATE_PAUSED)
            return;  // cycle started successfully
      }

      //--- Mid-cycle regime-change detection (TGT only)
      //    MGT is exempt because it is a temporary post-TGT recovery mode meant to run
      //    to completion (profit target, kill switch, or age limit). DetermineGridMode()
      //    would return BGT (since σ/μ has recovered and the TGT trigger was consumed),
      //    killing MGT on its very first bar.
      if(InpEnableTGT &&
         g_session.gridMode == GRID_MODE_TGT &&
         g_session.state == GRID_STATE_ACTIVE)
      {
         ENUM_GRID_MODE currentMode = g_session.gridMode;
         ENUM_GRID_MODE detectedMode = DetermineGridMode();

         //--- Regime has changed — force cycle restart with new mode
         if(detectedMode != currentMode)
         {
            double cycleProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);

            PrintFormat("[BGC Grid] Regime change detected: %s -> %s. P/L=$%.2f. Restarting cycle.",
                        currentMode == GRID_MODE_TGT ? "TGT" : "MGT",
                        detectedMode == GRID_MODE_BGT ? "BGT" :
                        (detectedMode == GRID_MODE_TGT ? "TGT" : "MGT"),
                        cycleProfit);

            //--- Track TGT→non-TGT as a TGT kill for MGT trigger
            if(currentMode == GRID_MODE_TGT)
               g_lastCycleWasTGTKill = true;

            if(InpEnableDiagnostics)
               g_diag.OnRegimeRestart(g_session.cycleCount, currentMode, detectedMode);

            g_session.state = GRID_STATE_CLOSING;
            int regimeOrphans = 0;
            g_gridCore.CloseAllPositions(g_session, regimeOrphans);
            if(InpEnableDiagnostics && regimeOrphans > 0) g_diag.OnOrphanClosed(regimeOrphans);

            double finalProfit = g_profitMonitor.GetCycleProfit(g_session.cycleStartEquity);
            CaptureCycleSessionInfo();
            if(InpEnableDiagnostics)
               g_diag.OnCycleEndRegime(g_session.cycleCount, finalProfit,
                                        AccountInfoDouble(ACCOUNT_EQUITY));

            g_session.cumulativeProfit += finalProfit;
            g_session.cycleCount++;
            g_stateManager.ClearState();

            StartNewCycle();
            return;
         }
      }

      //--- Drift gate pause/resume: applies only to BGT mode.
      //    TGT/MGT are designed to operate DURING trends, so the drift gate
      //    (which detects trends) must not pause them. The drift gate exists
      //    to protect BGT from its primary trend failure mode, not to block TGT/MGT.
      bool driftGateApplies = (g_session.gridMode == GRID_MODE_BGT);

      if(driftGateApplies && !g_volatilityOK && g_session.state == GRID_STATE_ACTIVE)
      {
         g_session.state = GRID_STATE_PAUSED;
         g_wasPaused = true;
         if(InpEnableDiagnostics)
            g_diag.OnDriftPause(g_session.cycleCount,
                                 g_volatilityGate.GetSigmaMuRatio(),
                                 g_volatilityGate.GetLastATR(),
                                 g_volatilityGate.GetLastDrift());
      }
      else if(g_session.state == GRID_STATE_PAUSED &&
              (g_volatilityOK || !driftGateApplies))
      {
         g_session.state = GRID_STATE_ACTIVE;
         if(g_wasPaused)
         {
            if(InpEnableDiagnostics)
               g_diag.OnDriftResume(g_session.cycleCount, g_volatilityGate.GetSigmaMuRatio());
            g_wasPaused = false;
         }
      }
   }

   //=== GRID SYNC + RE-ARMING ===
   //    Sync always runs (even PAUSED) so filled flags get cleared when TPs fire.
   //    RearmGrid handles both sync and re-arming in one pass so TP detection
   //    can see the state transition. Re-arming only places orders when ACTIVE.
   if(g_tickCounter % REARM_INTERVAL == 0)
   {
      bool recomputeLots = g_isNewBar;
      bool allowRearm = (g_session.state == GRID_STATE_ACTIVE);
      int tpHits = g_gridCore.SyncAndRearm(g_session, g_lastRPR, InpMaxSpreadPoints,
                                            recomputeLots, allowRearm);
      if(InpEnableDiagnostics)
         for(int t = 0; t < tpHits; t++)
            g_diag.OnTpHit(g_session.cycleCount, 0);
   }

   //=== PERIODIC STATE SAVE ===
   if(g_tickCounter % STATE_SAVE_INTERVAL == 0)
   {
      g_stateManager.SaveState(g_session);
   }
}

//+------------------------------------------------------------------+
//| Capture session diagnostics before cycle ends                    |
//+------------------------------------------------------------------+
void CaptureCycleSessionInfo()
{
   if(!InpEnableDiagnostics)
      return;
   double range = g_session.sessionHigh - g_session.sessionLow;
   double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double lt    = g_ltMonitor.ComputeLt(g_session, bid);
   g_diag.SetCycleSessionInfo(range, lt);
}

//+------------------------------------------------------------------+
//| Build a per-bar diagnostic snapshot (30 fields)                  |
//+------------------------------------------------------------------+
BarSnapshot BuildBarSnapshot()
{
   BarSnapshot snap;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   snap.time       = TimeCurrent();
   snap.bid        = bid;
   snap.equity     = equity;
   snap.balance    = balance;
   snap.floatingPL = equity - balance;

   snap.sessionHigh = g_session.sessionHigh;
   snap.sessionLow  = g_session.sessionLow;

   //--- Dt/Ut levels
   double dtPrice = g_session.sessionHigh - bid;
   double utPrice = bid - g_session.sessionLow;
   if(dtPrice < 0) dtPrice = 0;
   if(utPrice < 0) utPrice = 0;
   snap.dtLevels = (g_gridSpacingPrice > 0) ? (int)MathFloor(dtPrice / g_gridSpacingPrice) : 0;
   snap.utLevels = (g_gridSpacingPrice > 0) ? (int)MathFloor(utPrice / g_gridSpacingPrice) : 0;

   //--- Lt formula vs path-aware
   snap.ltFormula   = g_ltMonitor.ComputeLt(g_session, bid);
   snap.ltPathAware = g_ltMonitor.ComputePathAwareLt(g_session, bid);
   snap.ltError     = snap.ltFormula - snap.ltPathAware;

   //--- Cycle drawdown
   double cycleDDPct = 0;
   double snapshotRPRPct = 0;
   if(g_session.cycleStartEquity > 0)
   {
      cycleDDPct = (g_session.cycleStartEquity - equity) / g_session.cycleStartEquity * 100.0;
   }
   double weightedLoss = g_ltMonitor.ComputeWeightedLoss(g_session, bid);
   if(g_session.cycleStartEquity > 0)
      snapshotRPRPct = weightedLoss / g_session.cycleStartEquity * 100.0;
   snap.cycleDDPct      = cycleDDPct;
   snap.snapshotRPRPct  = snapshotRPRPct;

   //--- Count open/armed positions
   int total = 2 * g_session.totalLevels;
   int openBuys = 0, openSells = 0, armedBuys = 0, armedSells = 0;
   for(int i = 0; i < total; i++)
   {
      if(g_session.levels[i].buyOpen)   openBuys++;
      if(g_session.levels[i].sellOpen)  openSells++;
      if(g_session.levels[i].buyArmed)  armedBuys++;
      if(g_session.levels[i].sellArmed) armedSells++;
   }
   snap.openBuys  = openBuys;
   snap.openSells = openSells;
   snap.armedBuys = armedBuys;
   snap.armedSells= armedSells;

   //--- Grid state/mode
   snap.gridState      = (int)g_session.state;
   snap.gridMode       = (int)g_session.gridMode;
   snap.trendDirection = g_session.trendDirection;

   //--- Volatility data
   snap.sigmaMu = g_volatilityGate.GetSigmaMuRatio();
   snap.atr     = g_volatilityGate.GetLastATR();
   snap.drift   = g_volatilityGate.GetLastDrift();

   //--- Grid parameters
   snap.gridSpacing = g_gridSpacingPrice;
   snap.baseLot     = g_effectiveBaseLot;
   snap.cycleNumber = g_session.cycleCount;

   //--- Gambler's Ruin P(ruin)
   snap.ruinProbT53 = g_ltMonitor.ComputeRuinProbability(
                        equity, balance,
                        g_effectiveBaseLot, g_gridSpacingPrice, 0);

   //--- CUSUM
   snap.cusumSHigh = g_cpdEngine.GetSHigh();
   snap.cusumSLow  = g_cpdEngine.GetSLow();

   return snap;
}

//+------------------------------------------------------------------+
//| Compute ATR-dynamic grid spacing                                |
//|   Returns spacing in price units, clamped to [min, max]          |
//|   Falls back to fixed spacing if ATR unavailable                 |
//+------------------------------------------------------------------+
double ComputeATRSpacing()
{
   if(!InpUseATRSpacing || g_spacingATRHandle == INVALID_HANDLE)
      return InpGridSpacing * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);

   if(CopyBuffer(g_spacingATRHandle, 0, 1, 1, atrBuffer) <= 0)
   {
      PrintFormat("[BGC Grid] ATR spacing buffer copy failed; using fixed spacing");
      return InpGridSpacing * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }

   double atrValue = atrBuffer[0];
   double spacingPrice = atrValue * InpATRSpacingMultiplier;

   //--- Clamp to [min, max] in price units
   double pointSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double minSpacingPrice = InpMinGridSpacingPts * pointSize;
   double maxSpacingPrice = InpMaxGridSpacingPts * pointSize;

   spacingPrice = MathMax(spacingPrice, minSpacingPrice);
   spacingPrice = MathMin(spacingPrice, maxSpacingPrice);

   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   spacingPrice = NormalizeDouble(spacingPrice, digits);

   PrintFormat("[BGC Grid] ATR-based spacing: ATR=%.5f, Multiplier=%.2f, "
               "Result=%.5f (clamped to [%.5f, %.5f])",
               atrValue, InpATRSpacingMultiplier, spacingPrice,
               minSpacingPrice, maxSpacingPrice);

   return spacingPrice;
}

//+------------------------------------------------------------------+
//| Compute dynamic base lot from equity                             |
//+------------------------------------------------------------------+
double ComputeDynamicBaseLot(double cycleEquity)
{
   if(!InpUseDynamicBaseLot)
      return InpBaseLot;

   double lot = cycleEquity * InpLotFraction;

   //--- Normalise to broker constraints
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step    = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double cap     = MathMin(maxLot, InpMaxLotSize);

   lot = MathMax(lot, minLot);
   lot = MathMin(lot, cap);
   if(step > 0)
      lot = MathFloor(lot / step) * step;
   lot = NormalizeDouble(lot, 2);
   if(lot < minLot)
      lot = minLot;

   return lot;
}

//+------------------------------------------------------------------+
//| Determine grid mode from the current regime                      |
//+------------------------------------------------------------------+
ENUM_GRID_MODE DetermineGridMode()
{
   //--- MGT trigger: previous TGT cycle ended via kill switch -> post-trend recovery
   if(InpEnableMGT && g_lastCycleWasTGTKill)
   {
      g_lastCycleWasTGTKill = false;  // consume the trigger
      return GRID_MODE_MGT;
   }

   //--- CPD trigger: CUSUM detected a regime change -> force TGT
   //    CPD is an explicit regime-change signal; σ/μ is the continuous regime metric.
   //    If CPD fired and TGT is enabled, go straight to TGT regardless of σ/μ.
   if(g_cpdBlockActive && InpEnableTGT)
   {
      PrintFormat("[BGC Grid] Mode selection: TGT (CPD regime change detected)");
      return GRID_MODE_TGT;
   }

   //--- Check sigma/mu ratio for trending conditions
   //    Force a fresh computation because the cached value may be stale
   //    (constructor default 999 or a value from an earlier bar before restart).
   if(InpEnableTGT)
   {
      double sigmaMu = g_volatilityGate.ComputeSigmaMuRatio();  // fresh, not cached
      PrintFormat("[BGC Grid] Mode selection inputs: sigmaMu=%.2f (threshold=%.2f), ATR=%.5f, drift=%.5f",
                  sigmaMu, InpTGTSigmaMuThreshold,
                  g_volatilityGate.GetLastATR(), g_volatilityGate.GetLastDrift());
      if(sigmaMu < InpTGTSigmaMuThreshold)
      {
         PrintFormat("[BGC Grid] Mode selection: TGT (sigmaMu %.2f < threshold %.2f)",
                     sigmaMu, InpTGTSigmaMuThreshold);
         return GRID_MODE_TGT;  // Trending → TGT
      }
   }

   //--- CPD block active but TGT disabled -> do not start BGT into a confirmed trend
   if(g_cpdBlockActive)
   {
      PrintFormat("[BGC Grid] Mode selection: BGT (CPD block is active and TGT is disabled)");
   }

   PrintFormat("[BGC Grid] Mode selection: BGT (default ranging mode)");
   return GRID_MODE_BGT;  // Default: ranging → BGT
}

//+------------------------------------------------------------------+
//| Price-Level Filter: check if price is too close to recent extreme|
//|   Returns true if price is within MinATRDistance of the NEAREST  |
//|   N-bar high or low on the regime timeframe.                     |
//|   Only the nearest extreme matters — if price is near the high,  |
//|   it's far from the low (has room to retrace). The danger is     |
//|   anchoring at a level where price has no room on one side:      |
//|   e.g., at a 5-day high with all grid levels exposed to a       |
//|   correction, or at a 5-day low with all levels exposed to a    |
//|   bounce.                                                        |
//|   outDistHigh/outDistLow are populated for diagnostic logging.   |
//+------------------------------------------------------------------+
bool IsPriceAtExtreme(double &outDistHigh, double &outDistLow, double &outMinDist)
{
   outDistHigh = 0;
   outDistLow  = 0;
   outMinDist  = 0;

   if(!InpUsePriceLevelFilter)
      return false;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   //--- Get regime-TF ATR (same source as drift detection)
   double atr = g_volatilityGate.GetATRValue();
   if(atr <= 0)
      return false;  // no ATR data → don't block

   outMinDist = InpMinATRDistFromExtreme * atr;

   //--- Get N-bar high and low on the regime TF
   int highBar = iHighest(_Symbol, InpRegimeTF, MODE_HIGH, InpPriceLevelLookbackBars, 1);
   int lowBar  = iLowest(_Symbol, InpRegimeTF, MODE_LOW, InpPriceLevelLookbackBars, 1);

   if(highBar < 0 || lowBar < 0)
      return false;  // data not available → don't block

   double recentHigh = iHigh(_Symbol, InpRegimeTF, highBar);
   double recentLow  = iLow(_Symbol, InpRegimeTF, lowBar);

   outDistHigh = recentHigh - bid;
   outDistLow  = bid - recentLow;

   //--- Clamp negative distances (bid beyond the range — price discovery)
   if(outDistHigh < 0) outDistHigh = 0;  // bid above recent high → at extreme
   if(outDistLow < 0)  outDistLow = 0;   // bid below recent low → at extreme

   //--- Block if the NEAREST extreme is too close.
   //    min(distHigh, distLow) < threshold means price is near one edge of its range.
   double nearestDist = MathMin(outDistHigh, outDistLow);
   return (nearestDist < outMinDist);
}

//+------------------------------------------------------------------+
//| Start a new grid cycle from current price                        |
//+------------------------------------------------------------------+
void StartNewCycle()
{
   //--- CPD block: if CUSUM detected regime change and TGT is disabled,
   //    delay cycle start — don't deploy BGT into a confirmed trend.
   //    The block clears when σ/μ recovers through cooldown (checked in OnTick).
   if(g_cpdBlockActive && !InpEnableTGT)
   {
      g_cycleBlocked = true;
      g_session.state = GRID_STATE_PAUSED;
      PrintFormat("[BGC Grid] Cycle start delayed: CPD block is active while TGT is disabled. "
                  "Waiting for σ/μ recovery.");
      return;
   }

   //--- Price-level filter: don't anchor at a recent extreme.
   //    Price at an N-bar high/low has no established mean-reversion anchor —
   //    the BGC constraining function is weakest at price discovery levels.
   //    Block clears on new bar when price retraces (checked in OnTick).
   double plDistHigh = 0, plDistLow = 0, plMinDist = 0;
   if(IsPriceAtExtreme(plDistHigh, plDistLow, plMinDist))
   {
      //--- Only log the block event on the transition (not every retry)
      if(!g_priceLevelBlocked)
      {
         if(InpEnableDiagnostics)
            g_diag.OnPriceLevelBlock(g_session.cycleCount, plDistHigh, plDistLow, plMinDist);
         PrintFormat("[BGC Grid] Cycle start delayed: price is too close to the %d-bar extreme on %s. "
                     "DistHigh=%.2f, DistLow=%.2f, MinDist=%.2f (%.1f×ATR). "
                     "Waiting for retracement.",
                     InpPriceLevelLookbackBars, EnumToString(InpRegimeTF),
                     plDistHigh, plDistLow, plMinDist, InpMinATRDistFromExtreme);
      }
      g_priceLevelBlocked = true;
      g_cycleBlocked = true;
      g_session.state = GRID_STATE_PAUSED;
      return;
   }
   g_priceLevelBlocked = false;
   g_cycleBlocked = false;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   //--- Preserve cumulative stats
   double cumProfit = g_session.cumulativeProfit;
   int    cycleNum  = g_session.cycleCount;

   //--- Compute ATR-dynamic spacing for this cycle
   g_gridSpacingPrice = ComputeATRSpacing();
   g_gridCore.SetGridSpacing(g_gridSpacingPrice);

   //--- Init session with fresh anchor
   g_session.Init(bid, g_gridSpacingPrice, InpGridLevels);
   g_session.cumulativeProfit = cumProfit;
   g_session.cycleCount       = cycleNum;

   //--- Compute dynamic base lot for this cycle
   g_effectiveBaseLot = ComputeDynamicBaseLot(g_session.cycleStartEquity);
   g_lotEngine.Init(_Symbol, g_effectiveBaseLot, InpLotMultiplier, InpMaxLotSize, InpUseMildMultiplier);

   if(InpUseDynamicBaseLot)
   {
      PrintFormat("[BGC Grid] Dynamic base lot: Equity=$%.2f, Fraction=%.4f, BaseLot=%.2f",
                  g_session.cycleStartEquity, InpLotFraction, g_effectiveBaseLot);
   }

   //--- Determine grid mode for this cycle
   ENUM_GRID_MODE mode = DetermineGridMode();

   //--- BGT disabled: if DetermineGridMode() returned BGT but BGT is disabled,
   //    block the cycle and wait for TGT/MGT conditions to appear.
   if(InpDisableBGT && mode == GRID_MODE_BGT)
   {
      g_cycleBlocked = true;
      g_session.state = GRID_STATE_PAUSED;
      PrintFormat("[BGC Grid] Cycle start delayed: BGT is disabled and current conditions do not qualify for TGT/MGT.");
      return;
   }

   g_session.gridMode = mode;

   if(mode == GRID_MODE_TGT || mode == GRID_MODE_MGT)
   {
      //--- Determine trend direction from signed drift
      double signedDrift = g_volatilityGate.GetSignedDrift();
      g_session.trendDirection = (signedDrift >= 0) ? 1 : -1;

      if(InpEnableDiagnostics)
         g_diag.OnModeSwitch(cycleNum, mode, g_volatilityGate.GetSigmaMuRatio());

      PrintFormat("[BGC Grid] Mode=%s, TrendDir=%d, SigmaMu=%.2f",
                  mode == GRID_MODE_TGT ? "TGT" : "MGT",
                  g_session.trendDirection,
                  g_volatilityGate.GetSigmaMuRatio());
   }

   //--- Log cycle start with extended info (including σ/μ decision data)
   //    SetTrendDirection AFTER OnCycleStart — OnCycleStart calls ResetCycleCounters
   //    which would overwrite the value if set before.
   if(InpEnableDiagnostics)
   {
      g_diag.OnCycleStart(cycleNum, bid, g_session.cycleStartEquity,
                           mode, g_gridSpacingPrice, g_effectiveBaseLot,
                           g_volatilityGate.GetSigmaMuRatio(),
                           g_volatilityGate.GetLastATR(),
                           g_volatilityGate.GetLastDrift());
      g_diag.SetTrendDirection(g_session.trendDirection);
   }

   //--- Log cycle-start P(ruin) calibration diagnostics
   {
      double totalEquity = AccountInfoDouble(ACCOUNT_BALANCE);
      double pRuin = g_ltMonitor.ComputeRuinProbability(
                        g_session.cycleStartEquity, totalEquity,
                        g_effectiveBaseLot, g_gridSpacingPrice, 0);
      double expectedSteps = g_ltMonitor.ComputeExpectedSteps(
                        g_session.cycleStartEquity, totalEquity,
                        g_effectiveBaseLot, g_gridSpacingPrice);

      PrintFormat("[BGC Grid] Cycle-start diagnostics: P(ruin)=%.2f%%, E[steps]=%.0f, "
                  "v=%.2f (lot=%.2f x ptVal=%.4f x spacing=%.5f)",
                  pRuin * 100, expectedSteps,
                  g_effectiveBaseLot * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE)
                     / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) * g_gridSpacingPrice,
                  g_effectiveBaseLot,
                  SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE)
                     / SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE),
                  g_gridSpacingPrice);
   }

   //--- Place the initial grid
   g_gridCore.InitGrid(g_session);

   //--- Save initial state
   g_stateManager.SaveState(g_session);
}
//+------------------------------------------------------------------+

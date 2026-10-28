# [SW Lab] Edge Analyzer

- url: https://www.tradingview.com/script/4fipXPeI-SW-Lab-Edge-Analyzer/
- type: indicator
- pine_id: PUB;48cafcd4111b4a72a2249fa779cab269
- version: 1.0

## Description

## What It Does

Most indicators tell you to buy or sell without evidence. The Edge Analyzer changes that by building a real-time statistical profile for every trading setup it detects -- showing you exactly how that setup has performed historically on this specific asset, timeframe, and market regime. When a setup triggers, you see hard numbers: win rate, profit factor, best and worst outcomes, and a Kelly-derived position size -- not opinions.

## How It Works

- Monitors four setup types simultaneously: RSI Oversold/Overbought, MA Crossover, Breakout (with volume confirmation), and Mean Reversion (Z-score based)
- Each time a setup triggers, the indicator records the bar, price, direction, and current market regime, then measures the forward return after a configurable evaluation window (default: 10 bars)
- Classifies the market into three regimes (Trending, Ranging, Volatile) using ATR ratio analysis and trend slope, allowing you to see whether a setup that works in one regime also works in another
- Computes both all-time and regime-filtered statistics, with automatic fallback to all-regime stats when the current regime has fewer than 5 samples
- Calculates Quarter-Kelly position sizing from the real win rate and reward-to-risk ratio, capped at 25% for safety

## Key Features

- **Four parallel setup detectors** running simultaneously with independent statistics
- **Stat card overlay** showing occurrences, win rate, average return, best/worst, profit factor, and Kelly sizing
- **Regime-conditional analysis** breaking performance into Trending, Ranging, and Volatile environments
- **Confidence rating**: HIGH (15+ regime samples), MEDIUM (5-14), or LOW (fewer than 5)
- **Best setup highlight**: when multiple setups fire on the same bar, the highest win rate setup is prioritized
- Signal arrows plotted directly on the chart for visual reference

## Signal Interpretation

| Stat Card Field | Meaning |
|----------------|---------|
| Win Rate (All) | Historical win percentage across all regimes |
| Win Rate (Regime) | Win percentage filtered to the current market regime only |
| Profit Factor | Total wins divided by total losses -- above 1.0 means net positive |
| Quarter Kelly | Suggested position size as a percentage of account, based on Kelly Criterion at 25% safety factor |
| Confidence | HIGH / MEDIUM / LOW based on regime-specific sample count |
| NO EDGE | Negative Kelly value -- setup has negative expected value |

## Settings Guide

| Parameter | Default | Description |
|-----------|---------|-------------|
| RSI Length | 14 | RSI calculation period |
| RSI OB/OS | 70 / 30 | Overbought and oversold thresholds |
| MA Fast / Slow | 20 / 50 | Moving average crossover periods |
| Breakout Length | 20 | N-bar high/low lookback |
| Volume Confirm Mult | 1.2 | Volume must exceed SMA(20) times this value |
| Z-Score Length | 20 | Mean reversion lookback period |
| Z-Score Threshold | 2.0 | Standard deviations from mean to trigger |
| Eval Bars | 10 | Forward bars to measure each signal outcome |
| Min Signals | 10 | Minimum signals before displaying statistics |
| ATR Fast / Slow | 14 / 50 | ATR periods for regime classification |
| Trend Length | 50 | SMA period for trend slope calculation |

## Alerts

- RSI setup triggered
- MA crossover setup triggered
- Breakout setup triggered
- Mean reversion setup triggered
- Any setup triggered (composite)

## Best Used For

- Validating whether a setup actually has an edge on your chosen asset and timeframe before risking capital
- Identifying which market regime favors which setup type
- Data-driven position sizing instead of arbitrary fixed-percentage risk
- Screening multiple assets to find where specific setups consistently perform
- Building conviction (or losing it) with real forward-return statistics

## Academic Foundation

Position sizing is based on the Kelly Criterion (Kelly, 1956), which maximizes the long-term geometric growth rate of a portfolio. The indicator uses Quarter Kelly (25% of full Kelly) to reduce variance, a widely adopted practice in professional trading.

## Disclaimer

This indicator is an analytical tool, not financial advice. Past statistical performance does not guarantee future results. Always apply your own risk management.

## Source Code

````pine
// This Pine Script(TM) v6 indicator is subject to the Terms of Use:
// https://www.tradingview.com/pine-script-docs/
//@version=6
indicator("[SW Lab] Edge Analyzer", overlay=true, max_labels_count=500, max_bars_back=5000)

// ============================================================================
// SECTION A: Brand Colors
// ============================================================================
var color SW_BULL       = color.new(#00e5ff, 0)
var color SW_BULL_BG    = color.new(#00e5ff, 85)
var color SW_BEAR       = color.new(#ff6d00, 0)
var color SW_BEAR_BG    = color.new(#ff6d00, 85)
var color SW_NEUTRAL    = color.new(#9e9e9e, 0)
var color SW_NEUTRAL_BG = color.new(#9e9e9e, 90)
var color SW_STRONG     = color.new(#00c853, 0)
var color SW_WEAK       = color.new(#ffd600, 0)
var color SW_DANGER     = color.new(#ff1744, 0)
var color SW_TEXT        = color.new(#e0e0e0, 0)
var color SW_TEXT_DIM    = color.new(#757575, 0)

// ============================================================================
// SECTION B: Input Groups
// ============================================================================
var string GRP_MAIN    = "Main Settings"
var string GRP_REGIME  = "Regime Detection"
var string GRP_STATS   = "Statistics"
var string GRP_VISUAL  = "Visual Settings"
var string GRP_ALERTS  = "Alerts"
var string GRP_RSI     = "RSI Setup"
var string GRP_MA      = "MA Crossover Setup"
var string GRP_BRK     = "Breakout Setup"
var string GRP_MR      = "Mean Reversion Setup"

// ============================================================================
// INPUTS
// ============================================================================
// --- Setup Toggles ---
bool enRSI    = input.bool(true,  "Enable RSI Setup",       group=GRP_MAIN, tooltip="Track RSI oversold/overbought setups")
bool enMA     = input.bool(true,  "Enable MA Cross Setup",  group=GRP_MAIN, tooltip="Track moving average crossover setups")
bool enBrk    = input.bool(true,  "Enable Breakout Setup",  group=GRP_MAIN, tooltip="Track high/low breakout setups")
bool enMR     = input.bool(true,  "Enable Mean Rev Setup",  group=GRP_MAIN, tooltip="Track Z-score mean reversion setups")

// --- RSI Parameters ---
int   rsiLen  = input.int(14, "RSI Length",      minval=2,  group=GRP_RSI, tooltip="RSI calculation period")
int   rsiOB   = input.int(70, "RSI OB Level",    minval=50, maxval=95, group=GRP_RSI, tooltip="Overbought threshold")
int   rsiOS   = input.int(30, "RSI OS Level",    minval=5,  maxval=50, group=GRP_RSI, tooltip="Oversold threshold")

// --- MA Parameters ---
int   maFast  = input.int(20, "MA Fast Length",   minval=2,  group=GRP_MA, tooltip="Fast moving average period")
int   maSlow  = input.int(50, "MA Slow Length",   minval=5,  group=GRP_MA, tooltip="Slow moving average period")

// --- Breakout Parameters ---
int   brkLen  = input.int(20, "Breakout Length",  minval=5,  group=GRP_BRK, tooltip="N-bar high/low lookback for breakout")
float brkVol  = input.float(1.2, "Volume Confirm Mult", minval=1.0, step=0.1, group=GRP_BRK, tooltip="Volume must exceed SMA(20)*this to confirm breakout")

// --- Mean Reversion Parameters ---
int   mrLen   = input.int(20, "Z-Score Length",   minval=5,  group=GRP_MR, tooltip="Lookback for Z-score calculation")
float mrThresh = input.float(2.0, "Z-Score Threshold", minval=1.0, step=0.1, group=GRP_MR, tooltip="Standard deviations from mean to trigger")

// --- Regime Detection ---
int   atrFast   = input.int(14, "ATR Fast",       minval=2,  group=GRP_REGIME, tooltip="Fast ATR period for regime detection")
int   atrSlow   = input.int(50, "ATR Slow",       minval=10, group=GRP_REGIME, tooltip="Slow ATR period for regime detection")
int   trendLen  = input.int(50, "Trend Length",    minval=10, group=GRP_REGIME, tooltip="Trend slope calculation period")

// --- Statistics ---
int   evalBars  = input.int(10, "Eval Bars",      minval=1,  maxval=100, group=GRP_STATS, tooltip="Forward evaluation period in bars")
int   minSigs   = input.int(10, "Min Signals",    minval=3,  group=GRP_STATS, tooltip="Minimum signals required to show stats")

// --- Visual ---
string cardPos  = input.string("Top Right", "Card Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group=GRP_VISUAL, tooltip="Where to display the stat card")
bool showArrows = input.bool(true, "Show Signal Arrows", group=GRP_VISUAL, tooltip="Plot signal arrows on chart")
bool showCard   = input.bool(true, "Show Stat Card",     group=GRP_VISUAL, tooltip="Display stat card overlay")

// ============================================================================
// SECTION C: Regime Detection
// ============================================================================
regimeDetect(int _atrFast, int _atrSlow, int _trendLen) =>
    float atrF = ta.atr(_atrFast)
    float atrS = ta.atr(_atrSlow)
    float atrRatio = nz(atrF / atrS, 1.0)
    float smaNew = ta.sma(close, _trendLen)
    float smaOld = ta.sma(close, _trendLen)[_trendLen]
    float trendSlope = nz((smaNew - smaOld) / atrS, 0.0)
    int regime = atrRatio > 1.4 ? 3 : math.abs(trendSlope) > 0.5 ? 1 : 2
    float conf = atrRatio > 1.4 ? math.min(atrRatio / 2.0, 1.0) : math.abs(trendSlope) > 0.5 ? math.min(math.abs(trendSlope), 1.0) : 1.0 - math.max(atrRatio / 1.4, math.abs(trendSlope) / 0.5)
    [regime, conf]

regimeLabel(int r) =>
    r == 1 ? "TRENDING" : r == 2 ? "RANGING" : "VOLATILE"

regimeColor(int r) =>
    r == 1 ? SW_BULL : r == 2 ? SW_NEUTRAL : SW_BEAR

// ============================================================================
// SECTION D: Stats Engine Types
// ============================================================================
type SignalRecord
    int   barIdx
    float entryPrice
    int   direction
    int   regimeAtEntry
    float forwardReturn
    bool  evaluated
    int   setupType       // 1=RSI, 2=MA, 3=Breakout, 4=MeanRev

type SignalStats
    int   totalSignals
    int   wins
    int   losses
    float totalWinPct
    float totalLossPct
    float winRate
    float avgWin
    float avgLoss
    float profitFactor
    int   pending
    float bestReturn
    float worstReturn

// ============================================================================
// Stats Engine Functions
// ============================================================================
updateSignals(array<SignalRecord> signals, int _evalBars) =>
    bool statsChanged = false
    if signals.size() > 0
        for i = 0 to signals.size() - 1
            SignalRecord rec = signals.get(i)
            if not rec.evaluated and (bar_index - rec.barIdx >= _evalBars)
                int barsBack = bar_index - rec.barIdx
                float exitPrice = close[barsBack - _evalBars]
                rec.forwardReturn := nz((exitPrice - rec.entryPrice) / rec.entryPrice * rec.direction * 100, 0.0)
                rec.evaluated := true
                signals.set(i, rec)
                statsChanged := true
    statsChanged

computeStats(array<SignalRecord> signals, int regimeFilter, int setupFilter) =>
    int total = 0
    int w = 0
    int l = 0
    float winSum = 0.0
    float lossSum = 0.0
    int pend = 0
    float best = na
    float worst = na
    if signals.size() > 0
        for i = 0 to signals.size() - 1
            SignalRecord rec = signals.get(i)
            if setupFilter != 0 and rec.setupType != setupFilter
                continue
            if regimeFilter != 0 and rec.regimeAtEntry != regimeFilter
                continue
            if not rec.evaluated
                pend += 1
                continue
            total += 1
            if na(best) or rec.forwardReturn > best
                best := rec.forwardReturn
            if na(worst) or rec.forwardReturn < worst
                worst := rec.forwardReturn
            if rec.forwardReturn > 0
                w += 1
                winSum += rec.forwardReturn
            else
                l += 1
                lossSum += math.abs(rec.forwardReturn)
    float wr = total > 0 ? float(w) / float(total) * 100.0 : 0.0
    float aw = w > 0 ? winSum / float(w) : 0.0
    float al = l > 0 ? lossSum / float(l) : 0.0
    float pf = lossSum > 0 ? winSum / lossSum : (winSum > 0 ? 999.0 : 0.0)
    SignalStats.new(total, w, l, winSum, lossSum, wr, aw, al, pf, pend, nz(best, 0.0), nz(worst, 0.0))

// Kelly Criterion
kellyPct(float _winRate, float _avgWin, float _avgLoss) =>
    float wr = _winRate / 100.0
    float ratio = _avgLoss > 0.0 ? _avgWin / _avgLoss : 10.0
    float kelly = (wr * ratio - (1.0 - wr)) / ratio
    math.max(kelly, 0.0)

// ============================================================================
// SETUP DETECTORS
// ============================================================================
detectRSI(int _len, int _ob, int _os) =>
    float r = ta.rsi(close, _len)
    bool longTrig = ta.crossover(r, float(_os))
    bool shortTrig = ta.crossunder(r, float(_ob))
    bool triggered = longTrig or shortTrig
    int dir = longTrig ? 1 : -1
    string name = longTrig ? "RSI Oversold (" + str.tostring(r, "#.0") + ")" : shortTrig ? "RSI Overbought (" + str.tostring(r, "#.0") + ")" : ""
    [triggered, name, dir]

detectMA(int _fast, int _slow) =>
    float maF = ta.sma(close, _fast)
    float maS = ta.sma(close, _slow)
    bool longTrig = ta.crossover(maF, maS)
    bool shortTrig = ta.crossunder(maF, maS)
    bool triggered = longTrig or shortTrig
    int dir = longTrig ? 1 : -1
    string name = longTrig ? "MA Golden Cross (" + str.tostring(_fast) + "/" + str.tostring(_slow) + ")" : shortTrig ? "MA Death Cross (" + str.tostring(_fast) + "/" + str.tostring(_slow) + ")" : ""
    [triggered, name, dir]

detectBreakout(int _len, float _volMult) =>
    float hh = ta.highest(high, _len)[1]
    float ll = ta.lowest(low, _len)[1]
    float volSma = ta.sma(volume, 20)
    bool volConfirm = volume > volSma * _volMult
    bool longTrig = close > hh and volConfirm
    bool shortTrig = close < ll and volConfirm
    bool triggered = longTrig or shortTrig
    int dir = longTrig ? 1 : -1
    string name = longTrig ? "Breakout High (" + str.tostring(hh, "#.##") + ")" : shortTrig ? "Breakout Low (" + str.tostring(ll, "#.##") + ")" : ""
    [triggered, name, dir]

detectMeanRev(int _len, float _thresh) =>
    float mean = ta.sma(close, _len)
    float sd = ta.stdev(close, _len)
    float z = sd > 0 ? (close - mean) / sd : 0.0
    bool longTrig = z < -_thresh
    bool shortTrig = z > _thresh
    bool triggered = longTrig or shortTrig
    int dir = longTrig ? 1 : -1
    string name = longTrig ? "Mean Rev Long (Z=" + str.tostring(z, "#.00") + ")" : shortTrig ? "Mean Rev Short (Z=" + str.tostring(z, "#.00") + ")" : ""
    [triggered, name, dir]

// ============================================================================
// MAIN LOGIC
// ============================================================================
// Regime detection
[curRegime, curConf] = regimeDetect(atrFast, atrSlow, trendLen)
int warmupBars = math.max(atrSlow, trendLen * 2)
bool warmedUp = bar_index >= warmupBars

// Persistent signal array (shared across all setup types)
var array<SignalRecord> allSignals = array.new<SignalRecord>()

// Cumulative counters for signals dropped from array (overflow beyond 500)
// Overall overflow
var int   cumTotal   = 0
var int   cumWins    = 0
var int   cumLosses  = 0
var float cumWinPct  = 0.0
var float cumLossPct = 0.0
// Per-regime overflow
var int   cumTrendTotal = 0, var int cumTrendW = 0, var int cumTrendL = 0
var float cumTrendWP = 0.0, var float cumTrendLP = 0.0
var int   cumRangeTotal = 0, var int cumRangeW = 0, var int cumRangeL = 0
var float cumRangeWP = 0.0, var float cumRangeLP = 0.0
var int   cumVolTotal = 0, var int cumVolW = 0, var int cumVolL = 0
var float cumVolWP = 0.0, var float cumVolLP = 0.0
// Per-setup overflow (1=RSI, 2=MA, 3=Breakout, 4=MeanRev)
var int   cumS1Total = 0, var int cumS1W = 0, var int cumS1L = 0
var float cumS1WP = 0.0, var float cumS1LP = 0.0
var int   cumS2Total = 0, var int cumS2W = 0, var int cumS2L = 0
var float cumS2WP = 0.0, var float cumS2LP = 0.0
var int   cumS3Total = 0, var int cumS3W = 0, var int cumS3L = 0
var float cumS3WP = 0.0, var float cumS3LP = 0.0
var int   cumS4Total = 0, var int cumS4W = 0, var int cumS4L = 0
var float cumS4WP = 0.0, var float cumS4LP = 0.0

// Persistent state for last triggered setup (for stat card display)
var string lastSetupName  = ""
var int    lastSetupType  = 0
var int    lastSetupDir   = 0
var int    lastSetupBar   = 0

// Detect all setups
[rsiTrig, rsiName, rsiDir]  = detectRSI(rsiLen, rsiOB, rsiOS)
[maTrig, maName, maDir]     = detectMA(maFast, maSlow)
[brkTrig, brkName, brkDir]  = detectBreakout(brkLen, brkVol)
[mrTrig, mrName, mrDir]     = detectMeanRev(mrLen, mrThresh)

// Apply enable toggles
bool rsiActive = enRSI and rsiTrig and warmedUp
bool maActive  = enMA  and maTrig  and warmedUp
bool brkActive = enBrk and brkTrig and warmedUp
bool mrActive  = enMR  and mrTrig  and warmedUp

// Record signals and pick best setup for display
// We track all triggered setups, but display the best one
var float bestWR = 0.0

// Helper: record a signal into the array
recordSignal(array<SignalRecord> signals, int dir, int regime, int sType) =>
    SignalRecord rec = SignalRecord.new(bar_index, close, dir, regime, na, false, sType)
    signals.push(rec)

// Process each active setup
if rsiActive
    recordSignal(allSignals, rsiDir, curRegime, 1)
if maActive
    recordSignal(allSignals, maDir, curRegime, 2)
if brkActive
    recordSignal(allSignals, brkDir, curRegime, 3)
if mrActive
    recordSignal(allSignals, mrDir, curRegime, 4)

// Cap array at 500 — accumulate overflow stats
while allSignals.size() > 500
    SignalRecord oldest = allSignals.shift()
    if oldest.evaluated
        cumTotal += 1
        if oldest.forwardReturn > 0
            cumWins += 1
            cumWinPct += oldest.forwardReturn
        else
            cumLosses += 1
            cumLossPct += math.abs(oldest.forwardReturn)
        // Per-regime overflow
        if oldest.regimeAtEntry == 1
            cumTrendTotal += 1
            if oldest.forwardReturn > 0
                cumTrendW += 1
                cumTrendWP += oldest.forwardReturn
            else
                cumTrendL += 1
                cumTrendLP += math.abs(oldest.forwardReturn)
        else if oldest.regimeAtEntry == 2
            cumRangeTotal += 1
            if oldest.forwardReturn > 0
                cumRangeW += 1
                cumRangeWP += oldest.forwardReturn
            else
                cumRangeL += 1
                cumRangeLP += math.abs(oldest.forwardReturn)
        else if oldest.regimeAtEntry == 3
            cumVolTotal += 1
            if oldest.forwardReturn > 0
                cumVolW += 1
                cumVolWP += oldest.forwardReturn
            else
                cumVolL += 1
                cumVolLP += math.abs(oldest.forwardReturn)
        // Per-setup overflow
        if oldest.setupType == 1
            cumS1Total += 1
            if oldest.forwardReturn > 0
                cumS1W += 1
                cumS1WP += oldest.forwardReturn
            else
                cumS1L += 1
                cumS1LP += math.abs(oldest.forwardReturn)
        else if oldest.setupType == 2
            cumS2Total += 1
            if oldest.forwardReturn > 0
                cumS2W += 1
                cumS2WP += oldest.forwardReturn
            else
                cumS2L += 1
                cumS2LP += math.abs(oldest.forwardReturn)
        else if oldest.setupType == 3
            cumS3Total += 1
            if oldest.forwardReturn > 0
                cumS3W += 1
                cumS3WP += oldest.forwardReturn
            else
                cumS3L += 1
                cumS3LP += math.abs(oldest.forwardReturn)
        else if oldest.setupType == 4
            cumS4Total += 1
            if oldest.forwardReturn > 0
                cumS4W += 1
                cumS4WP += oldest.forwardReturn
            else
                cumS4L += 1
                cumS4LP += math.abs(oldest.forwardReturn)

// Evaluate pending signals
updateSignals(allSignals, evalBars)

// Determine which setup to display (highest WR in current regime among those that just triggered)
if rsiActive or maActive or brkActive or mrActive
    float bestSetupWR = -1.0
    int   bestType = 0
    string bestName = ""
    int   bestDir = 0
    if rsiActive
        SignalStats s = computeStats(allSignals, curRegime, 1)
        if s.totalSignals >= 1 and s.winRate > bestSetupWR
            bestSetupWR := s.winRate
            bestType := 1
            bestName := rsiName
            bestDir  := rsiDir
        else if s.totalSignals < 1
            bestType := 1
            bestName := rsiName
            bestDir  := rsiDir
    if maActive
        SignalStats s = computeStats(allSignals, curRegime, 2)
        if s.totalSignals >= 1 and s.winRate > bestSetupWR
            bestSetupWR := s.winRate
            bestType := 2
            bestName := maName
            bestDir  := maDir
        else if bestType == 0
            bestType := 2
            bestName := maName
            bestDir  := maDir
    if brkActive
        SignalStats s = computeStats(allSignals, curRegime, 3)
        if s.totalSignals >= 1 and s.winRate > bestSetupWR
            bestSetupWR := s.winRate
            bestType := 3
            bestName := brkName
            bestDir  := brkDir
        else if bestType == 0
            bestType := 3
            bestName := brkName
            bestDir  := brkDir
    if mrActive
        SignalStats s = computeStats(allSignals, curRegime, 4)
        if s.totalSignals >= 1 and s.winRate > bestSetupWR
            bestSetupWR := s.winRate
            bestType := 4
            bestName := mrName
            bestDir  := mrDir
        else if bestType == 0
            bestType := 4
            bestName := mrName
            bestDir  := mrDir
    lastSetupName := bestName
    lastSetupType := bestType
    lastSetupDir  := bestDir
    lastSetupBar  := bar_index

// ============================================================================
// SIGNAL ARROWS
// ============================================================================
bool anySetup = rsiActive or maActive or brkActive or mrActive
plotshape(showArrows and rsiActive and lastSetupType == 1 and rsiDir == 1 ? low : na, "RSI Long",  shape.triangleup,   location.belowbar, SW_BULL, size=size.small)
plotshape(showArrows and rsiActive and lastSetupType == 1 and rsiDir == -1 ? high : na, "RSI Short", shape.triangledown, location.abovebar, SW_BEAR, size=size.small)
plotshape(showArrows and maActive and lastSetupType == 2 and maDir == 1 ? low : na,  "MA Long",   shape.triangleup,   location.belowbar, SW_BULL, size=size.small)
plotshape(showArrows and maActive and lastSetupType == 2 and maDir == -1 ? high : na, "MA Short",  shape.triangledown, location.abovebar, SW_BEAR, size=size.small)
plotshape(showArrows and brkActive and lastSetupType == 3 and brkDir == 1 ? low : na, "Brk Long",  shape.triangleup,   location.belowbar, SW_BULL, size=size.small)
plotshape(showArrows and brkActive and lastSetupType == 3 and brkDir == -1 ? high : na,"Brk Short", shape.triangledown, location.abovebar, SW_BEAR, size=size.small)
plotshape(showArrows and mrActive and lastSetupType == 4 and mrDir == 1 ? low : na,  "MR Long",   shape.triangleup,   location.belowbar, SW_BULL, size=size.small)
plotshape(showArrows and mrActive and lastSetupType == 4 and mrDir == -1 ? high : na, "MR Short",  shape.triangledown, location.abovebar, SW_BEAR, size=size.small)

// Also plot all triggered setups (not just best) as small dots
// Split into separate long/short plotshapes because location must be input type
plotshape(showArrows and rsiActive and lastSetupType != 1 and rsiDir == 1 ? low : na,  "RSI dot up",   shape.circle, location.belowbar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and rsiActive and lastSetupType != 1 and rsiDir == -1 ? high : na, "RSI dot dn",   shape.circle, location.abovebar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and maActive and lastSetupType != 2 and maDir == 1 ? low : na,    "MA dot up",    shape.circle, location.belowbar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and maActive and lastSetupType != 2 and maDir == -1 ? high : na,  "MA dot dn",    shape.circle, location.abovebar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and brkActive and lastSetupType != 3 and brkDir == 1 ? low : na,  "Brk dot up",   shape.circle, location.belowbar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and brkActive and lastSetupType != 3 and brkDir == -1 ? high : na, "Brk dot dn",  shape.circle, location.abovebar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and mrActive and lastSetupType != 4 and mrDir == 1 ? low : na,    "MR dot up",    shape.circle, location.belowbar, SW_NEUTRAL, size=size.tiny)
plotshape(showArrows and mrActive and lastSetupType != 4 and mrDir == -1 ? high : na,  "MR dot dn",    shape.circle, location.abovebar, SW_NEUTRAL, size=size.tiny)

// ============================================================================
// STAT CARD TABLE
// ============================================================================
tablePos(string pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

if barstate.islastconfirmedhistory and showCard
    // Compute stats for the last triggered setup
    bool hasSetup = lastSetupType > 0 and (bar_index - lastSetupBar <= evalBars * 3)

    SignalStats arrAllSt = computeStats(allSignals, 0, lastSetupType)
    SignalStats regSt = computeStats(allSignals, curRegime, lastSetupType)

    // Add per-setup overflow to allSt (regSt cannot include overflow without per-regime-per-setup tracking)
    int   oT = lastSetupType == 1 ? cumS1Total : lastSetupType == 2 ? cumS2Total : lastSetupType == 3 ? cumS3Total : lastSetupType == 4 ? cumS4Total : 0
    int   oW = lastSetupType == 1 ? cumS1W : lastSetupType == 2 ? cumS2W : lastSetupType == 3 ? cumS3W : lastSetupType == 4 ? cumS4W : 0
    int   oL = lastSetupType == 1 ? cumS1L : lastSetupType == 2 ? cumS2L : lastSetupType == 3 ? cumS3L : lastSetupType == 4 ? cumS4L : 0
    float oWP = lastSetupType == 1 ? cumS1WP : lastSetupType == 2 ? cumS2WP : lastSetupType == 3 ? cumS3WP : lastSetupType == 4 ? cumS4WP : 0.0
    float oLP = lastSetupType == 1 ? cumS1LP : lastSetupType == 2 ? cumS2LP : lastSetupType == 3 ? cumS3LP : lastSetupType == 4 ? cumS4LP : 0.0
    int   cTotal  = arrAllSt.totalSignals + oT
    int   cWins   = arrAllSt.wins + oW
    int   cLosses = arrAllSt.losses + oL
    float cWinPct = arrAllSt.totalWinPct + oWP
    float cLossPct = arrAllSt.totalLossPct + oLP
    float cWR     = cTotal > 0 ? float(cWins) / float(cTotal) * 100.0 : 0.0
    float cAW     = cWins > 0 ? cWinPct / float(cWins) : 0.0
    float cAL     = cLosses > 0 ? cLossPct / float(cLosses) : 0.0
    float cPF     = cLossPct > 0 ? cWinPct / cLossPct : (cWinPct > 0 ? 999.0 : 0.0)
    float cBest   = arrAllSt.bestReturn
    float cWorst  = arrAllSt.worstReturn
    SignalStats allSt = SignalStats.new(cTotal, cWins, cLosses, cWinPct, cLossPct, cWR, cAW, cAL, cPF, arrAllSt.pending, cBest, cWorst)

    // Calculate Kelly
    float kellyAll  = kellyPct(allSt.winRate, allSt.avgWin, allSt.avgLoss)
    float kellyReg  = kellyPct(regSt.winRate, regSt.avgWin, regSt.avgLoss)
    float qKelly    = regSt.totalSignals >= 5 ? kellyReg * 0.25 : kellyAll * 0.25
    float qKellyPct = math.min(qKelly * 100.0, 25.0)

    // Confidence assessment
    string confLabel = regSt.totalSignals >= 15 ? "HIGH" : regSt.totalSignals >= 5 ? "MEDIUM" : "LOW"
    color  confColor = regSt.totalSignals >= 15 ? SW_STRONG : regSt.totalSignals >= 5 ? SW_WEAK : SW_DANGER

    // Setup name for display
    string setupDisp = hasSetup ? lastSetupName : "No active setup"
    string regDisp   = regimeLabel(curRegime)

    // Build table
    int rows = hasSetup ? 18 : 6
    var table statCard = table.new(tablePos(cardPos), 2, rows, bgcolor=color.new(#0d1117, 10), border_width=1, border_color=color.new(#30363d, 0))

    // Header
    table.cell(statCard, 0, 0, "EDGE ANALYSIS", text_color=SW_BULL, text_size=size.small, text_halign=text.align_left)
    table.cell(statCard, 1, 0, "[SW Lab]", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_right)

    if not hasSetup
        table.cell(statCard, 0, 1, "No active setup detected", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 1, "", text_color=SW_TEXT_DIM, text_size=size.small)
        table.cell(statCard, 0, 2, "Regime: " + regDisp, text_color=regimeColor(curRegime), text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 2, str.tostring(curConf * 100, "#.0") + "%", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_right)
        table.cell(statCard, 0, 3, "Signals tracked:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 3, str.tostring(allSignals.size()), text_color=SW_TEXT, text_size=size.small, text_halign=text.align_right)
        if not warmedUp
            table.cell(statCard, 0, 4, "Warming up...", text_color=SW_WEAK, text_size=size.small, text_halign=text.align_left)
            table.cell(statCard, 1, 4, str.tostring(bar_index) + "/" + str.tostring(warmupBars) + " bars", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_right)
        else
            table.cell(statCard, 0, 4, "Waiting for setup trigger", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
            table.cell(statCard, 1, 4, "", text_color=SW_TEXT_DIM, text_size=size.small)
        table.cell(statCard, 0, 5, "Not financial advice", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statCard, 1, 5, "", text_color=SW_TEXT_DIM, text_size=size.tiny)
    else
        // Row 1: Setup name
        table.cell(statCard, 0, 1, "Setup:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 1, setupDisp, text_color=lastSetupDir == 1 ? SW_BULL : SW_BEAR, text_size=size.small, text_halign=text.align_right)

        // Row 2: Asset + TF
        table.cell(statCard, 0, 2, syminfo.ticker + " | " + timeframe.period, text_color=SW_TEXT, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 2, "", text_color=SW_TEXT, text_size=size.small)

        // Row 3: Separator - All time header
        table.cell(statCard, 0, 3, "--- All Time ---", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statCard, 1, 3, "", text_color=SW_TEXT_DIM, text_size=size.tiny)

        // Row 4: Occurrences
        bool lowSampleAll = allSt.totalSignals < minSigs
        string occTxt = str.tostring(allSt.totalSignals) + (lowSampleAll ? " (Low sample)" : "")
        table.cell(statCard, 0, 4, "Occurrences:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 4, occTxt, text_color=lowSampleAll ? SW_WEAK : SW_TEXT, text_size=size.small, text_halign=text.align_right)

        // Row 5: Win Rate
        string wrTxt = allSt.totalSignals > 0 ? str.tostring(allSt.winRate, "#.1") + "% (" + str.tostring(allSt.wins) + "/" + str.tostring(allSt.totalSignals) + ")" : "N/A"
        color wrCol  = allSt.winRate >= 55 ? SW_STRONG : allSt.winRate >= 45 ? SW_WEAK : SW_DANGER
        table.cell(statCard, 0, 5, "Win Rate:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 5, wrTxt, text_color=allSt.totalSignals > 0 ? wrCol : SW_TEXT_DIM, text_size=size.small, text_halign=text.align_right)

        // Row 6: Avg Return
        float avgRetAll = allSt.totalSignals > 0 ? (allSt.totalWinPct - allSt.totalLossPct) / float(allSt.totalSignals) : 0.0
        table.cell(statCard, 0, 6, "Avg Return:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 6, (avgRetAll >= 0 ? "+" : "") + str.tostring(avgRetAll, "#.2") + "%", text_color=avgRetAll >= 0 ? SW_STRONG : SW_DANGER, text_size=size.small, text_halign=text.align_right)

        // Row 7: Best / Worst
        table.cell(statCard, 0, 7, "Best:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        string bestStr = (allSt.bestReturn >= 0 ? "+" : "") + str.tostring(allSt.bestReturn, "#.1") + "%"
        table.cell(statCard, 1, 7, bestStr + " | " + str.tostring(allSt.worstReturn, "#.1") + "%", text_color=SW_TEXT, text_size=size.small, text_halign=text.align_right)

        // Row 8: Profit Factor
        string pfTxt = allSt.profitFactor >= 999 ? "INF" : str.tostring(allSt.profitFactor, "#.2")
        table.cell(statCard, 0, 8, "Profit Factor:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 8, pfTxt, text_color=allSt.profitFactor >= 1.5 ? SW_STRONG : allSt.profitFactor >= 1.0 ? SW_WEAK : SW_DANGER, text_size=size.small, text_halign=text.align_right)

        // Row 9: Pending
        if allSt.pending > 0
            table.cell(statCard, 0, 9, "Pending:", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_left)
            table.cell(statCard, 1, 9, str.tostring(allSt.pending) + " signals", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_right)
        else
            table.cell(statCard, 0, 9, "", text_color=SW_TEXT_DIM, text_size=size.tiny)
            table.cell(statCard, 1, 9, "", text_color=SW_TEXT_DIM, text_size=size.tiny)

        // Row 10: Regime header
        bool regFallback = regSt.totalSignals < 5
        string regHeader = "--- " + regDisp + " Regime ---"
        table.cell(statCard, 0, 10, regHeader, text_color=regimeColor(curRegime), text_size=size.tiny, text_halign=text.align_left)
        table.cell(statCard, 1, 10, str.tostring(curConf * 100, "#.0") + "% conf", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_right)

        // Row 11: Regime occurrences
        if regFallback
            table.cell(statCard, 0, 11, "Occurrences:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
            table.cell(statCard, 1, 11, str.tostring(regSt.totalSignals) + " (<5, using all)", text_color=SW_WEAK, text_size=size.small, text_halign=text.align_right)
        else
            table.cell(statCard, 0, 11, "Occurrences:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
            table.cell(statCard, 1, 11, str.tostring(regSt.totalSignals), text_color=SW_TEXT, text_size=size.small, text_halign=text.align_right)

        // Row 12: Regime Win Rate
        SignalStats dispSt = regFallback ? allSt : regSt
        string regWRTxt = dispSt.totalSignals > 0 ? str.tostring(dispSt.winRate, "#.1") + "% (" + str.tostring(dispSt.wins) + "/" + str.tostring(dispSt.totalSignals) + ")" : "N/A"
        color regWRCol = dispSt.winRate >= 55 ? SW_STRONG : dispSt.winRate >= 45 ? SW_WEAK : SW_DANGER
        table.cell(statCard, 0, 12, "Win Rate:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 12, regWRTxt + (regFallback ? "" : (dispSt.winRate > allSt.winRate ? " ^" : "")), text_color=dispSt.totalSignals > 0 ? regWRCol : SW_TEXT_DIM, text_size=size.small, text_halign=text.align_right)

        // Row 13: Regime Avg Return
        float avgRetReg = dispSt.totalSignals > 0 ? (dispSt.totalWinPct - dispSt.totalLossPct) / float(dispSt.totalSignals) : 0.0
        table.cell(statCard, 0, 13, "Avg Return:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 13, (avgRetReg >= 0 ? "+" : "") + str.tostring(avgRetReg, "#.2") + "%", text_color=avgRetReg >= 0 ? SW_STRONG : SW_DANGER, text_size=size.small, text_halign=text.align_right)

        // Row 14: separator
        table.cell(statCard, 0, 14, "--- Position Sizing ---", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statCard, 1, 14, "", text_color=SW_TEXT_DIM, text_size=size.tiny)

        // Row 15: Quarter Kelly
        bool kellyCapped = qKellyPct >= 25.0
        string kellyTxt = qKelly <= 0 ? "NO EDGE" : str.tostring(qKellyPct, "#.1") + "%" + (kellyCapped ? " (capped)" : "")
        color kellyCol  = qKelly <= 0 ? SW_DANGER : kellyCapped ? SW_WEAK : SW_STRONG
        table.cell(statCard, 0, 15, "Quarter-Kelly:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        table.cell(statCard, 1, 15, kellyTxt, text_color=kellyCol, text_size=size.small, text_halign=text.align_right)

        // Row 16: Confidence
        table.cell(statCard, 0, 16, "Confidence:", text_color=SW_TEXT_DIM, text_size=size.small, text_halign=text.align_left)
        string confDetail = confLabel + " (n=" + str.tostring(regSt.totalSignals) + ")"
        table.cell(statCard, 1, 16, confDetail, text_color=confColor, text_size=size.small, text_halign=text.align_right)

        // Row 17: Disclaimer
        table.cell(statCard, 0, 17, "Not financial advice. Past != future.", text_color=SW_TEXT_DIM, text_size=size.tiny, text_halign=text.align_left)
        table.cell(statCard, 1, 17, "", text_color=SW_TEXT_DIM, text_size=size.tiny)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(rsiActive,  "RSI Setup Triggered",      "SW Lab Edge Analyzer: RSI setup detected")
alertcondition(maActive,   "MA Cross Setup Triggered",  "SW Lab Edge Analyzer: MA crossover detected")
alertcondition(brkActive,  "Breakout Setup Triggered",  "SW Lab Edge Analyzer: Breakout detected")
alertcondition(mrActive,   "Mean Rev Setup Triggered",  "SW Lab Edge Analyzer: Mean reversion detected")
alertcondition(anySetup,   "Any Setup Triggered",       "SW Lab Edge Analyzer: Setup detected")

// ============================================================================
// BACKGROUND HINT
// ============================================================================
bgcolor(anySetup ? (lastSetupDir == 1 ? SW_BULL_BG : SW_BEAR_BG) : na, title="Setup Background")
````

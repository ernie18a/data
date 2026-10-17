# [SW Lab] Signal Decay Monitor

- url: https://www.tradingview.com/script/VOGomEvw-SW-Lab-Signal-Decay-Monitor/
- type: indicator
- pine_id: PUB;5deec5bff5aa4c2f82c86d66b07579dd
- version: 1.0

## Description

## What It Does

Every trading signal has a shelf life. A strategy that delivered strong returns for six months can quietly stop working as markets adapt -- and most traders only notice after weeks of losses. The Signal Decay Monitor uses a statistical Z-test to continuously compare a strategy's recent performance against its historical baseline, flagging degradation before your P&L does.

## How It Works

- Select any of 6 built-in strategies (SMA Crossover, RSI Reversal, MACD Signal, Bollinger Bounce, Breakout, Mean Reversion) and the indicator tracks every signal and its forward return
- Computes a rolling win rate over a configurable recent window (default: last 30 evaluated signals) and compares it to the full historical win rate
- Performs a Z-test to determine whether the difference between recent and historical performance is statistically significant or just normal variance
- Plots confidence bands (1-sigma and 2-sigma) around the historical baseline so you can visually distinguish meaningful decay from noise
- Tracks which market regime recent signals occurred in, helping you determine if the strategy failed or if the regime simply shifted

## Key Features

- **Rolling win rate oscillator** (cyan line) showing recent signal performance in real time
- **Historical baseline** (gray line) for long-term average win rate reference
- **1-sigma and 2-sigma confidence bands** showing expected statistical variation
- **Z-score histogram** providing a visual representation of the decay score
- **Background color changes** with health status for instant visual assessment
- **Regime analysis** in the info panel identifying whether losses concentrate in a specific regime
- **Info panel** with complete breakdown: health status, Z-score, recent vs. historical win rate, signal counts, and regime notes

## Signal Interpretation

| Health Status | Z-Score Range | Meaning | Recommended Action |
|--------------|---------------|---------|-------------------|
| HEALTHY | Z > -0.5 | Edge intact | Trade normally |
| IMPROVING | Z > +0.5 | Signal getting stronger | Consider increasing size |
| WEAKENING | -0.5 to -1.5 | Early warning | Monitor closely, tighten stops |
| DEGRADING | -1.5 to -2.5 | Significant decay detected | Reduce position size |
| DEAD | Z < -2.5 | Edge is gone | Stop trading this signal |
| NEVER PROFITABLE | N/A | Strategy never had an edge | Do not trade on this asset |

## Settings Guide

| Parameter | Default | Description |
|-----------|---------|-------------|
| Strategy | SMA Crossover | Which strategy's signal health to monitor |
| Fast Length | 20 | Primary period for the selected strategy |
| Slow Length | 50 | Secondary period for the selected strategy |
| Recent Window | 30 | Number of recent evaluated signals to compare against baseline |
| Historical Window | 200 | Full history lookback for baseline performance |
| Evaluation Bars | 10 | Forward bars to measure each signal outcome |
| Decay Threshold | -1.5 | Z-score below which health is flagged as decaying |
| ATR Fast / Slow | 14 / 50 | ATR periods for regime detection |
| Trend Length | 50 | SMA period for trend slope calculation |

## Alerts

- Decay detected (Z-score crosses below the configured threshold)
- Signal declared DEAD (Z-score falls below -2.5)
- Signal IMPROVING (Z-score rises above +0.5)

## Best Used For

- Monitoring live strategies for performance degradation before losses accumulate
- Deciding when to retire a signal that has lost its edge
- Distinguishing between a strategy that stopped working and a strategy in a temporarily unfavorable regime
- Validating whether a recently discovered setup maintains its edge over time
- Companion tool to the Backtest Truth Table -- use the Truth Table to find edges, the Decay Monitor to track when they expire

## Academic Foundation

The decay detection is based on a standard two-proportion Z-test, comparing the recent win rate proportion against the historical baseline proportion. This is a well-established statistical hypothesis test used to determine whether observed differences are significant or attributable to sampling noise.

## Disclaimer

This indicator is an analytical tool, not financial advice. Past statistical performance does not guarantee future results. Always apply your own risk management.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SW Lab

//@version=6
indicator("[SW Lab] Signal Decay Monitor", overlay=false, max_labels_count=500, max_bars_back=5000)

// ============================================================================
// SECTION A: Brand Colors
// ============================================================================

//@variable SW Lab brand cyan (bullish)
var color SW_BULL       = color.new(#00e5ff, 0)
//@variable SW Lab brand cyan transparent (bullish background)
var color SW_BULL_BG    = color.new(#00e5ff, 85)
//@variable SW Lab brand orange (bearish)
var color SW_BEAR       = color.new(#ff6d00, 0)
//@variable SW Lab brand orange transparent (bearish background)
var color SW_BEAR_BG    = color.new(#ff6d00, 85)
//@variable SW Lab gray (neutral)
var color SW_NEUTRAL    = color.new(#9e9e9e, 0)
//@variable SW Lab gray transparent (neutral background)
var color SW_NEUTRAL_BG = color.new(#9e9e9e, 90)
//@variable SW Lab green (strong positive signal)
var color SW_STRONG     = color.new(#00c853, 0)
//@variable SW Lab yellow (caution)
var color SW_WEAK       = color.new(#ffd600, 0)
//@variable SW Lab red (danger/stop)
var color SW_DANGER     = color.new(#ff1744, 0)
//@variable Light text for dark theme
var color SW_TEXT        = color.new(#e0e0e0, 0)
//@variable Dimmed text
var color SW_TEXT_DIM    = color.new(#757575, 0)

// ============================================================================
// SECTION B: Input Groups
// ============================================================================

var string GRP_MAIN    = "Main Settings"
var string GRP_REGIME  = "Regime Detection"
var string GRP_STATS   = "Statistics"
var string GRP_VISUAL  = "Visual Settings"
var string GRP_ALERTS  = "Alerts"

// ============================================================================
// INPUTS
// ============================================================================

string i_strategy = input.string("SMA Crossover", "Strategy",
     options=["SMA Crossover", "RSI Reversal", "MACD Signal", "Bollinger Bounce", "Breakout", "Mean Reversion"],
     group=GRP_MAIN, tooltip="Select which strategy's signal health to monitor")

int i_fastLen    = input.int(20, "Fast Length", minval=2, maxval=200,
     group=GRP_MAIN, tooltip="Fast period for the selected strategy")
int i_slowLen    = input.int(50, "Slow Length", minval=5, maxval=500,
     group=GRP_MAIN, tooltip="Slow period for the selected strategy")
int i_evalBars   = input.int(10, "Evaluation Bars", minval=1, maxval=100,
     group=GRP_STATS, tooltip="How many bars forward to measure each signal's outcome")
int i_recentWin  = input.int(30, "Recent Window", minval=5, maxval=100,
     group=GRP_STATS, tooltip="Number of recent evaluated signals to compare against historical average")
int i_histWin    = input.int(200, "Historical Window", minval=50, maxval=500,
     group=GRP_STATS, tooltip="Full history lookback for baseline performance")
float i_decayZ   = input.float(-1.5, "Decay Threshold (Z-score)", minval=-5.0, maxval=0.0, step=0.1,
     group=GRP_STATS, tooltip="Z-score below which signal health is flagged as weakening. More negative = more tolerant.")

int i_atrFast    = input.int(14, "ATR Fast", minval=2, maxval=100,
     group=GRP_REGIME, tooltip="Fast ATR period for regime detection")
int i_atrSlow    = input.int(50, "ATR Slow", minval=10, maxval=200,
     group=GRP_REGIME, tooltip="Slow ATR period for regime detection")
int i_trendLen   = input.int(50, "Trend Length", minval=10, maxval=200,
     group=GRP_REGIME, tooltip="Lookback period for trend slope calculation")

bool i_showTable = input.bool(true, "Show Info Panel",
     group=GRP_VISUAL, tooltip="Display the signal health dashboard panel")
bool i_showBands = input.bool(true, "Show Confidence Bands",
     group=GRP_VISUAL, tooltip="Plot 1-sigma and 2-sigma bands around historical win rate")
string i_tablePos = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=GRP_VISUAL, tooltip="Where to display the info panel on chart")

// ============================================================================
// SECTION C: Regime Detection
// ============================================================================

regimeDetect(int atrFast, int atrSlow, int trendLen) =>
    float atrF = ta.atr(atrFast)
    float atrS = ta.atr(atrSlow)
    float atrRatio = nz(atrF / atrS, 1.0)
    float smaNew = ta.sma(close, trendLen)
    float smaOld = ta.sma(close, trendLen)[trendLen]
    float trendSlope = nz((smaNew - smaOld) / atrS, 0.0)
    int regime = atrRatio > 1.4 ? 3 : math.abs(trendSlope) > 0.5 ? 1 : 2
    float conf = atrRatio > 1.4 ? math.min(atrRatio / 2.0, 1.0) : math.abs(trendSlope) > 0.5 ? math.min(math.abs(trendSlope), 1.0) : 1.0 - math.max(atrRatio / 1.4, math.abs(trendSlope) / 0.5)
    [regime, conf]

regimeLabel(int r) =>
    r == 1 ? "TRENDING" : r == 2 ? "RANGING" : "VOLATILE"

regimeColor(int r) =>
    r == 1 ? SW_BULL : r == 2 ? SW_NEUTRAL : SW_BEAR

// ============================================================================
// SECTION D: Stats Engine (Types)
// ============================================================================

type SignalRecord
    int barIdx
    float entryPrice
    int direction       // 1 = long, -1 = short
    int regimeAtEntry   // 1/2/3
    float forwardReturn // na until evaluated
    bool evaluated

type SignalStats
    int totalSignals
    int wins
    int losses
    float totalWinPct
    float totalLossPct
    float winRate
    float avgWin
    float avgLoss
    float profitFactor
    int pending

// ============================================================================
// SECTION D: Stats Engine (Functions)
// ============================================================================

updateSignals(array<SignalRecord> signals, int evalBars) =>
    bool statsChanged = false
    if signals.size() > 0
        for i = 0 to signals.size() - 1
            SignalRecord rec = signals.get(i)
            if not rec.evaluated and (bar_index - rec.barIdx >= evalBars)
                int barsAgo = bar_index - rec.barIdx
                float exitPrice = close[barsAgo - evalBars]
                rec.forwardReturn := nz((exitPrice - rec.entryPrice) / rec.entryPrice * float(rec.direction) * 100.0, 0.0)
                rec.evaluated := true
                signals.set(i, rec)
                statsChanged := true
    statsChanged

computeStats(array<SignalRecord> signals, int regimeFilter) =>
    int total = 0
    int w = 0
    int l = 0
    float winSum = 0.0
    float lossSum = 0.0
    int pend = 0
    if signals.size() > 0
        for i = 0 to signals.size() - 1
            SignalRecord rec = signals.get(i)
            if regimeFilter != 0 and rec.regimeAtEntry != regimeFilter
                continue
            if not rec.evaluated
                pend += 1
                continue
            total += 1
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
    SignalStats.new(total, w, l, winSum, lossSum, wr, aw, al, pf, pend)

computeRecentStats(array<SignalRecord> signals, int recentCount, int regimeFilter) =>
    int total = 0
    int w = 0
    int l = 0
    float winSum = 0.0
    float lossSum = 0.0
    int pend = 0
    int evaluated = 0
    if signals.size() > 0
        for i = signals.size() - 1 to 0
            SignalRecord rec = signals.get(i)
            if regimeFilter != 0 and rec.regimeAtEntry != regimeFilter
                continue
            if not rec.evaluated
                pend += 1
                continue
            evaluated += 1
            if evaluated > recentCount
                break
            total += 1
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
    SignalStats.new(total, w, l, winSum, lossSum, wr, aw, al, pf, pend)

// ============================================================================
// STRATEGY SIGNAL GENERATORS (same as C5)
// ============================================================================

stratSMACross(int fast, int slow) =>
    float ma1 = ta.sma(close, fast)
    float ma2 = ta.sma(close, slow)
    [ta.crossover(ma1, ma2), ta.crossunder(ma1, ma2)]

stratRSIReversal(int len) =>
    float r = ta.rsi(close, len)
    [ta.crossover(r, 30.0), ta.crossunder(r, 70.0)]

stratMACDSignal(int fast, int slow, int sig) =>
    [macdLine, sigLine, histLine] = ta.macd(close, fast, slow, sig)
    [ta.crossover(macdLine, sigLine), ta.crossunder(macdLine, sigLine)]

stratBollingerBounce(int len, float mult) =>
    [mid, upper, lower] = ta.bb(close, len, mult)
    float r = ta.rsi(close, 14)
    [close <= lower and r < 35, close >= upper and r > 65]

stratBreakout(int len) =>
    float hh = ta.highest(high, len)
    float ll = ta.lowest(low, len)
    bool vol = volume > ta.sma(volume, 20) * 1.5
    [close > hh[1] and vol, close < ll[1] and vol]

stratMeanReversion(int len) =>
    float mean = ta.sma(close, len)
    float sd = ta.stdev(close, len)
    float z = sd > 0 ? (close - mean) / sd : 0.0
    [z < -2.0, z > 2.0]

// ============================================================================
// STRATEGY ROUTER
// ============================================================================

getStrategySignals(string strat, int fast, int slow) =>
    bool longSig = false
    bool shortSig = false
    if strat == "SMA Crossover"
        [l, s] = stratSMACross(fast, slow)
        longSig := l
        shortSig := s
    else if strat == "RSI Reversal"
        [l, s] = stratRSIReversal(fast)
        longSig := l
        shortSig := s
    else if strat == "MACD Signal"
        int sigLen = math.max(math.round(fast * 0.75), 2)
        [l, s] = stratMACDSignal(fast > 12 ? 12 : fast, slow > 26 ? 26 : slow, sigLen)
        longSig := l
        shortSig := s
    else if strat == "Bollinger Bounce"
        [l, s] = stratBollingerBounce(fast, 2.0)
        longSig := l
        shortSig := s
    else if strat == "Breakout"
        [l, s] = stratBreakout(fast)
        longSig := l
        shortSig := s
    else if strat == "Mean Reversion"
        [l, s] = stratMeanReversion(fast)
        longSig := l
        shortSig := s
    [longSig, shortSig]

getStrategyDesc(string strat, int fast, int slow) =>
    string desc = ""
    if strat == "SMA Crossover"
        desc := "SMA(" + str.tostring(fast) + "/" + str.tostring(slow) + ") Crossover"
    else if strat == "RSI Reversal"
        desc := "RSI(" + str.tostring(fast) + ") Reversal 30/70"
    else if strat == "MACD Signal"
        desc := "MACD Signal Line Cross"
    else if strat == "Bollinger Bounce"
        desc := "BB(" + str.tostring(fast) + ", 2.0) Bounce"
    else if strat == "Breakout"
        desc := "Breakout(" + str.tostring(fast) + ") + Volume"
    else if strat == "Mean Reversion"
        desc := "Mean Reversion Z(" + str.tostring(fast) + ") > 2sd"
    desc

// ============================================================================
// MAIN LOGIC
// ============================================================================

// Warmup check
int warmupBars = math.max(i_atrSlow, i_trendLen * 2)
bool isWarmedUp = bar_index >= warmupBars

// Regime detection
[currentRegime, regimeConf] = regimeDetect(i_atrFast, i_atrSlow, i_trendLen)

// Strategy signals
[longSig, shortSig] = getStrategySignals(i_strategy, i_fastLen, i_slowLen)
longSig  := isWarmedUp ? longSig : false
shortSig := isWarmedUp ? shortSig : false

// Persistent signal storage
var array<SignalRecord> signals = array.new<SignalRecord>()

// Cumulative counters for signals dropped from array (overflow beyond 500)
var int   cumTotal   = 0
var int   cumWins    = 0
var int   cumLosses  = 0
var float cumWinPct  = 0.0
var float cumLossPct = 0.0

// Per-regime cumulative overflow counters
var int   cumTrendTotal = 0, var int cumTrendW = 0, var int cumTrendL = 0
var float cumTrendWP = 0.0, var float cumTrendLP = 0.0
var int   cumRangeTotal = 0, var int cumRangeW = 0, var int cumRangeL = 0
var float cumRangeWP = 0.0, var float cumRangeLP = 0.0
var int   cumVolTotal = 0, var int cumVolW = 0, var int cumVolL = 0
var float cumVolWP = 0.0, var float cumVolLP = 0.0

// Record new signals
if longSig
    signals.push(SignalRecord.new(bar_index, close, 1, currentRegime, na, false))

if shortSig
    signals.push(SignalRecord.new(bar_index, close, -1, currentRegime, na, false))

// Cap array at 500 — accumulate overflow stats
while signals.size() > 500
    SignalRecord oldest = signals.shift()
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

// Evaluate pending signals
updateSignals(signals, i_evalBars)

// Compute stats (array-only, then add cumulative overflow for histStats)
SignalStats arrHist = computeStats(signals, 0)

int   hTotalC  = arrHist.totalSignals + cumTotal
int   hWinsC   = arrHist.wins + cumWins
int   hLossesC = arrHist.losses + cumLosses
float hWinPctC = arrHist.totalWinPct + cumWinPct
float hLossPctC = arrHist.totalLossPct + cumLossPct
float hWRC     = hTotalC > 0 ? float(hWinsC) / float(hTotalC) * 100.0 : 0.0
float hAWC     = hWinsC > 0 ? hWinPctC / float(hWinsC) : 0.0
float hALC     = hLossesC > 0 ? hLossPctC / float(hLossesC) : 0.0
float hPFC     = hLossPctC > 0 ? hWinPctC / hLossPctC : (hWinPctC > 0 ? 999.0 : 0.0)
SignalStats histStats = SignalStats.new(hTotalC, hWinsC, hLossesC, hWinPctC, hLossPctC, hWRC, hAWC, hALC, hPFC, arrHist.pending)

// Recent stats don't need overflow (they only look at most recent signals still in array)
SignalStats recentStats = computeRecentStats(signals, i_recentWin, 0)

// ============================================================================
// Z-TEST HEALTH ASSESSMENT
// ============================================================================

// Convert win rates to proportions (0-1 range)
float histWR   = histStats.totalSignals > 0 ? histStats.winRate / 100.0 : 0.0
float recentWR = recentStats.totalSignals > 0 ? recentStats.winRate / 100.0 : 0.0

// Standard error of the proportion
float se = (histWR > 0 and histWR < 1 and recentStats.totalSignals > 0) ? math.sqrt(histWR * (1.0 - histWR) / float(recentStats.totalSignals)) : 0.0

// Z-score: how different is recent performance from historical?
float zScore = se > 0 ? (recentWR - histWR) / se : 0.0

// Health classification
// 1 = HEALTHY, 2 = WEAKENING, 3 = DEGRADING, 4 = DEAD, 5 = IMPROVING, 6 = NEVER_PROFITABLE, 0 = INACTIVE
var int health = 0
var string healthLabel = ""
var color healthColor = SW_NEUTRAL
var string recommendation = ""

// Determine health status
bool hasRecentData = recentStats.totalSignals >= 5
bool hasHistData = histStats.totalSignals >= 10
bool neverProfitable = hasHistData and histStats.winRate < 50.0
bool isImproving = zScore > 0.5

if not hasHistData
    health := 0
    healthLabel := "INACTIVE"
    healthColor := SW_TEXT_DIM
    recommendation := "Insufficient data"
else if not hasRecentData
    health := 0
    healthLabel := "INACTIVE"
    healthColor := SW_TEXT_DIM
    recommendation := "No recent signals in evaluation window"
else if neverProfitable and recentStats.winRate < 50.0
    health := 6
    healthLabel := "NEVER PROFITABLE"
    healthColor := SW_DANGER
    recommendation := "Strategy never had an edge here"
else if isImproving
    health := 5
    healthLabel := "IMPROVING"
    healthColor := SW_STRONG
    recommendation := "Signal strengthening — consider increasing size"
else if zScore > -0.5
    health := 1
    healthLabel := "HEALTHY"
    healthColor := SW_STRONG
    recommendation := "Edge intact — trade normally"
else if zScore > -1.5
    health := 2
    healthLabel := "WEAKENING"
    healthColor := SW_WEAK
    recommendation := "Monitor closely — consider reducing size"
else if zScore > -2.5
    health := 3
    healthLabel := "DEGRADING"
    healthColor := SW_BEAR
    recommendation := "Significant decay — reduce position size"
else
    health := 4
    healthLabel := "DEAD"
    healthColor := SW_DANGER
    recommendation := "Edge lost — stop trading this signal"

// Trend direction (based on change in recent WR vs slightly older window)
// Simple heuristic: compare recent zScore movement
var float prevZScore = 0.0
string trendArrow = zScore > prevZScore + 0.2 ? "Improving" : zScore < prevZScore - 0.2 ? "Declining" : "Stable"
prevZScore := zScore

// ============================================================================
// REGIME BREAKDOWN FOR RECENT SIGNALS
// ============================================================================

// Count regime distribution in recent signals
countRecentRegimes(array<SignalRecord> sigs, int recentN) =>
    int trendN = 0
    int rangeN = 0
    int volatN = 0
    int counted = 0
    if sigs.size() > 0
        for i = sigs.size() - 1 to 0
            SignalRecord rec = sigs.get(i)
            if not rec.evaluated
                continue
            counted += 1
            if counted > recentN
                break
            if rec.regimeAtEntry == 1
                trendN += 1
            else if rec.regimeAtEntry == 2
                rangeN += 1
            else
                volatN += 1
    [trendN, rangeN, volatN]

[recentTrend, recentRange, recentVolat] = countRecentRegimes(signals, i_recentWin)
int recentTotal = recentTrend + recentRange + recentVolat

// Find dominant regime in recent signals
string dominantRegime = recentTrend >= recentRange and recentTrend >= recentVolat ? "TRENDING" : recentRange >= recentVolat ? "RANGING" : "VOLATILE"
float dominantPct = recentTotal > 0 ? float(math.max(recentTrend, math.max(recentRange, recentVolat))) / float(recentTotal) * 100.0 : 0.0

// ============================================================================
// OSCILLATOR PLOTS
// ============================================================================

// Plot rolling recent win rate
float plotRecentWR = hasRecentData ? recentStats.winRate : na
float plotHistWR   = hasHistData ? histStats.winRate : na

plot(plotRecentWR, "Recent Win Rate", color=SW_BULL, linewidth=2)
plot(plotHistWR, "Historical Win Rate", color=SW_TEXT_DIM, linewidth=1, style=plot.style_stepline)

// Confidence bands (1-sigma and 2-sigma around historical win rate)
float sigma1Upper = hasHistData ? (histWR + se) * 100.0 : na
float sigma1Lower = hasHistData ? (histWR - se) * 100.0 : na
float sigma2Upper = hasHistData ? (histWR + 2.0 * se) * 100.0 : na
float sigma2Lower = hasHistData ? (histWR - 2.0 * se) * 100.0 : na

p1u = plot(i_showBands ? sigma1Upper : na, "1-Sigma Upper", color=color.new(#00e5ff, 80), linewidth=1)
p1l = plot(i_showBands ? sigma1Lower : na, "1-Sigma Lower", color=color.new(#00e5ff, 80), linewidth=1)
p2u = plot(i_showBands ? sigma2Upper : na, "2-Sigma Upper", color=color.new(#ff6d00, 85), linewidth=1)
p2l = plot(i_showBands ? sigma2Lower : na, "2-Sigma Lower", color=color.new(#ff6d00, 85), linewidth=1)

fill(p1u, p1l, color=color.new(#00e5ff, 92), title="1-Sigma Band")
fill(p2u, p2l, color=color.new(#ff6d00, 95), title="2-Sigma Band")

// 50% reference line
hline(50, "Random (50%)", color=SW_NEUTRAL, linestyle=hline.style_dotted)

// Background color by health status
color bgColor = health == 1 ? color.new(#00c853, 95) :
     health == 2 ? color.new(#ffd600, 95) :
     health == 3 ? color.new(#ff6d00, 95) :
     health == 4 ? color.new(#ff1744, 95) :
     health == 5 ? color.new(#00c853, 92) :
     health == 6 ? color.new(#ff1744, 97) :
     na
bgcolor(bgColor)

// ============================================================================
// Z-SCORE SECONDARY PLOT
// ============================================================================

// Plot Z-score as histogram at bottom (scaled to fit WR range)
// Map z-score to 0-100 range: z=0 maps to 50, z=-3 maps to 20, z=3 maps to 80
float zPlot = hasRecentData and hasHistData ? math.max(math.min(50.0 + zScore * 10.0, 100.0), 0.0) : na
plot(zPlot, "Z-Score (scaled)", color=zScore > 0 ? SW_STRONG : zScore > -1.5 ? SW_WEAK : SW_DANGER, style=plot.style_columns, linewidth=1)

// ============================================================================
// INFO PANEL
// ============================================================================

getTablePosition(string pos) =>
    pos == "Top Right" ? position.top_right : pos == "Top Left" ? position.top_left : pos == "Bottom Right" ? position.bottom_right : position.bottom_left

if barstate.islastconfirmedhistory and i_showTable
    string tblPos = getTablePosition(i_tablePos)
    var table infoPanel = table.new(tblPos, 3, 14, bgcolor=color.new(#121212, 10), border_color=color.new(#333333, 0), border_width=1)

    // Row 0: Title
    table.cell(infoPanel, 0, 0, "[SW Lab] SIGNAL HEALTH MONITOR", text_color=SW_BULL, text_size=size.small, bgcolor=color.new(#0d0d0d, 0))
    table.merge_cells(infoPanel, 0, 0, 2, 0)

    // Row 1: Strategy
    string stratDesc = getStrategyDesc(i_strategy, i_fastLen, i_slowLen)
    table.cell(infoPanel, 0, 1, "Strategy: " + stratDesc, text_color=SW_TEXT, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
    table.merge_cells(infoPanel, 0, 1, 2, 1)

    if not hasHistData
        // Not enough data at all
        table.cell(infoPanel, 0, 2, "Insufficient historical data", text_color=SW_WEAK, text_size=size.small, bgcolor=color.new(#1a1a1a, 0))
        table.merge_cells(infoPanel, 0, 2, 2, 2)
        table.cell(infoPanel, 0, 3, "Need at least 10 evaluated signals to begin monitoring", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
        table.merge_cells(infoPanel, 0, 3, 2, 3)
    else
        // Row 2: Historical section header
        table.cell(infoPanel, 0, 2, "Historical (all time):", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a237e, 20))
        table.merge_cells(infoPanel, 0, 2, 2, 2)

        // Row 3: Historical stats
        table.cell(infoPanel, 0, 3, "Win Rate:", text_color=SW_TEXT_DIM, text_size=size.tiny)
        table.cell(infoPanel, 1, 3, str.tostring(histStats.winRate, "#.#") + "% (n=" + str.tostring(histStats.totalSignals) + ")", text_color=SW_TEXT, text_size=size.tiny)
        table.cell(infoPanel, 2, 3, "", text_color=SW_TEXT, text_size=size.tiny)

        // Row 4: Historical PF
        table.cell(infoPanel, 0, 4, "Profit Factor:", text_color=SW_TEXT_DIM, text_size=size.tiny)
        float dispPF = math.min(histStats.profitFactor, 99.0)
        table.cell(infoPanel, 1, 4, str.tostring(dispPF, "#.##"), text_color=dispPF >= 1.2 ? SW_STRONG : dispPF >= 1.0 ? SW_WEAK : SW_DANGER, text_size=size.tiny)
        table.cell(infoPanel, 2, 4, "", text_color=SW_TEXT, text_size=size.tiny)

        // Row 5: Recent section header
        table.cell(infoPanel, 0, 5, "Recent (last " + str.tostring(i_recentWin) + " signals):", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a237e, 20))
        table.merge_cells(infoPanel, 0, 5, 2, 5)

        if not hasRecentData
            table.cell(infoPanel, 0, 6, "Insufficient recent data (" + str.tostring(recentStats.totalSignals) + "/" + str.tostring(i_recentWin) + ")", text_color=SW_WEAK, text_size=size.tiny)
            table.merge_cells(infoPanel, 0, 6, 2, 6)
        else
            // Row 6: Recent WR
            string recentWRStr = str.tostring(recentStats.winRate, "#.#") + "% (n=" + str.tostring(recentStats.totalSignals) + ")"
            color recentWRColor = recentStats.winRate >= histStats.winRate ? SW_STRONG : recentStats.winRate >= histStats.winRate * 0.85 ? SW_WEAK : SW_DANGER
            table.cell(infoPanel, 0, 6, "Win Rate:", text_color=SW_TEXT_DIM, text_size=size.tiny)
            table.cell(infoPanel, 1, 6, recentWRStr, text_color=recentWRColor, text_size=size.tiny)
            table.cell(infoPanel, 2, 6, "", text_color=SW_TEXT, text_size=size.tiny)

            // Row 7: Recent PF
            float recentPF = math.min(recentStats.profitFactor, 99.0)
            table.cell(infoPanel, 0, 7, "Profit Factor:", text_color=SW_TEXT_DIM, text_size=size.tiny)
            table.cell(infoPanel, 1, 7, str.tostring(recentPF, "#.##"), text_color=recentPF >= 1.2 ? SW_STRONG : recentPF >= 1.0 ? SW_WEAK : SW_DANGER, text_size=size.tiny)
            table.cell(infoPanel, 2, 7, "", text_color=SW_TEXT, text_size=size.tiny)

        // Row 8: Decay analysis header
        table.cell(infoPanel, 0, 8, "Decay Analysis:", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a237e, 20))
        table.merge_cells(infoPanel, 0, 8, 2, 8)

        // Row 9: Z-score
        table.cell(infoPanel, 0, 9, "Decay Z-Score:", text_color=SW_TEXT_DIM, text_size=size.tiny)
        color zColor = zScore > -0.5 ? SW_STRONG : zScore > -1.5 ? SW_WEAK : zScore > -2.5 ? SW_BEAR : SW_DANGER
        table.cell(infoPanel, 1, 9, str.tostring(zScore, "#.##"), text_color=zColor, text_size=size.tiny)
        table.cell(infoPanel, 2, 9, trendArrow, text_color=SW_TEXT_DIM, text_size=size.tiny)

        // Row 10: Health status
        table.cell(infoPanel, 0, 10, "Status:", text_color=SW_TEXT_DIM, text_size=size.tiny)
        table.cell(infoPanel, 1, 10, healthLabel, text_color=healthColor, text_size=size.tiny)
        table.cell(infoPanel, 2, 10, "", text_color=SW_TEXT, text_size=size.tiny)

        // Row 11: Recommendation
        table.cell(infoPanel, 0, 11, "Action:", text_color=SW_TEXT_DIM, text_size=size.tiny)
        table.cell(infoPanel, 1, 11, recommendation, text_color=healthColor, text_size=size.tiny)
        table.cell(infoPanel, 2, 11, "", text_color=SW_TEXT, text_size=size.tiny)

        // Row 12: Regime note
        if recentTotal > 0 and dominantPct > 50
            string regimeNote = str.tostring(dominantPct, "#") + "% of recent signals in " + dominantRegime
            table.cell(infoPanel, 0, 12, "Regime note:", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
            table.cell(infoPanel, 1, 12, regimeNote, text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
            table.cell(infoPanel, 2, 12, "", text_color=SW_TEXT, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
        else
            table.cell(infoPanel, 0, 12, "", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
            table.cell(infoPanel, 1, 12, "", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))
            table.cell(infoPanel, 2, 12, "", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#1a1a1a, 0))

        // Row 13: Disclaimer
        table.cell(infoPanel, 0, 13, "NOT financial advice. Past != future.", text_color=SW_TEXT_DIM, text_size=size.tiny, bgcolor=color.new(#0d0d0d, 0))
        table.merge_cells(infoPanel, 0, 13, 2, 13)

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

// Track previous health for transition detection (var comparison with [1] doesn't work)
var int prevHealth = 0

bool decayAlert = hasRecentData and hasHistData and zScore < i_decayZ and zScore[1] >= i_decayZ
bool deadAlert = hasRecentData and hasHistData and health == 4 and health != prevHealth
bool improvingAlert = hasRecentData and hasHistData and health == 5

prevHealth := health

alertcondition(decayAlert, "[QE] Signal Decay — Weakening Detected", "SW Lab Signal Decay Monitor: Signal health declining")
alertcondition(deadAlert, "[QE] Signal Decay — Signal DEAD", "SW Lab Signal Decay Monitor: Signal has lost its edge completely")
alertcondition(improvingAlert, "[QE] Signal Decay — Improving", "SW Lab Signal Decay Monitor: Signal health improving")
alertcondition(longSig, "[QE] Signal Decay — Long Signal Fired", "SW Lab Signal Decay Monitor: Long signal detected")
alertcondition(shortSig, "[QE] Signal Decay — Short Signal Fired", "SW Lab Signal Decay Monitor: Short signal detected")
````

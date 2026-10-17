# Hunters Reversal v2.3

- url: https://www.tradingview.com/script/0IBrCAVS-Hunters-Reversal-v2-3/
- type: indicator
- pine_id: PUB;d9cf1ad92935459da7fdcc6d11936e40
- version: 1.0

## Description

Three independent reversal signals, each detecting a different type of turning point. When multiple signals cluster together within a short window, the probability of reversal increases significantly.

Part of the Hunters Framework ... WHERE / WHEN / WHY

[b]SIGNAL 1: LIQUIDITY SWEEP
[/b]
Detects when price wicks beyond a confirmed pivot high or low, triggers the stops sitting there, then closes back inside. This is the "stop hunt" pattern.

Unlike simple wick detection, this version requires:
- The level being swept must be a confirmed pivot (not just a rolling extreme)
- The sweep candle must penetrate the level by a minimum amount (filters noise) but not too far (filters breakouts)
- Post-sweep confirmation: price must stay below/above the sweep extreme for N bars before the signal fires
- Signal is plotted retroactively at the actual sweep bar once confirmed

This eliminates the majority of false sweeps that plague simpler implementations.

[b]SIGNAL 2: RSI DIVERGENCE
[/b]
Classic divergence between price and RSI at confirmed pivot points.
- Bearish: price makes a higher high but RSI makes a lower high
- Bullish: price makes a lower low but RSI makes a higher low

Requires a minimum distance between the two pivots being compared (default 15 bars) to filter out noise from pivots that are too close together.

[b]SIGNAL 3: PIVOT + EXTENSION
[/b]
Fires when price forms a confirmed pivot at an extreme distance from the EMA. This catches overextended moves that are likely to snap back.

Requirements:
- The pivot must be the highest high (or lowest low) within a lookback window
- The distance from the EMA must exceed a configurable ATR multiple (default 3x ATR)

These are the rubber-band snapback setups ... price stretched too far from the mean.

[b]TIER CLASSIFICATION (BIG SIGNALS)
[/b]
When two or more of the three signals fire within a short window (default 8 bars), a large "BIG" triangle appears. These cluster signals represent the highest confidence reversals because multiple independent conditions are confirming the same turning point.

For example: a liquidity sweep at an overextended pivot WITH RSI divergence ... that is three separate reasons saying "this move is done."

[b]INVALIDATION
[/b]
Every signal comes with a built-in invalidation check. If price moves too far beyond the signal level within a configurable window (default 8 bars, 0.6 ATR), an X marker appears showing the signal was invalidated. This keeps you honest ... no holding a losing position hoping the reversal still plays out.

[b]COOLDOWN[/b]

A per-direction cooldown (default 20 bars) prevents signal spam. After a bear signal fires, no new bear signals for 20 bars. Bull signals are tracked independently.

[b]SETTINGS OVERVIEW
[/b]
Pivot Detection:
- Left/Right bars for pivot confirmation (default 15/5)
- Minimum prominence filter (pivot must stand out from surrounding price by at least 1 ATR)

Liquidity Sweep:
- Pivot lookback for sweep targets (default 100 bars)
- Min/max penetration in ATR (0.1 to 1.0 ... filters both noise and breakouts)
- Confirmation bars (default 3 ... price must hold for 3 bars after sweep)

RSI Divergence:
- Standard RSI settings (default 14)
- Lookback and minimum distance between pivot pairs

Extension:
- EMA length (default 50)
- Minimum ATR distance from EMA (default 3x)
- Pivot must be extreme within N bars (default 30)

[b]HOW IT FITS THE FRAMEWORK
[/b]
Hunters Reversal answers WHEN ... specifically, when is a move likely exhausted and ready to reverse?

Used alongside:
- Liquidity Hunter ... shows WHERE the key levels are (the targets being swept)
- Trend Hunter ... shows the broader trend context (is this a counter-trend reversal or a pullback entry?)
- RSI+StochRSI ... provides additional momentum confirmation

The strongest setups: a Hunters Reversal BIG signal at a Liquidity Hunter zone with Trend Hunter showing momentum divergence on the higher timeframe.

[b]ALERTS[/b]

8 alertconditions covering all signal types:
- Bear/Bull Liquidity Sweep
- Bear/Bull RSI Divergence
- Bear/Bull Pivot Extension
- Bear/Bull BIG (cluster signal ... highest priority)
EOF

grep -c "..." /home/claude/tv_publish_hunters_reversal.txt && echo "EM DASHES" || echo "Clean"

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
//  HUNTERS REVERSAL v2.3 — SWEEP SELECTIVE
//  
//  v2.3 cuts sweep noise:
//    - Sweep must breach a CONFIRMED PIVOT high/low (not just rolling extreme)
//    - Sweep requires post-bar confirmation (3 bars of no new extreme)
//    - Sweep plotted retroactively at the actual sweep bar
// ═══════════════════════════════════════════════════════════════

indicator("Hunters Reversal v2.3", "HuntersRev", overlay=true, max_labels_count=500, max_lines_count=200)

// ── INPUTS ─────────────────────────────────────────────────────
grpPivot = "1. Pivot Detection"
pivotLeft  = input.int(15, "Pivot Left Bars", minval=2, group=grpPivot)
pivotRight = input.int(5, "Pivot Right Bars (confirmation delay)", minval=1, group=grpPivot)
pivotProminenceATR = input.float(1.0, "Min Pivot Prominence (ATR)", step=0.1, group=grpPivot)
pivotProminenceBars = input.int(20, "Prominence Lookback Bars", group=grpPivot)

grpSweep = "2. Liquidity Sweep"
useSweep      = input.bool(true, "Enable Liquidity Sweep Detection", group=grpSweep)
sweepPivotLookback = input.int(100, "Sweep Pivot Lookback", group=grpSweep, tooltip="How far back to find the prior pivot being swept. Sweeps only fire against confirmed prior pivots, not arbitrary rolling extremes.")
sweepMinPenetration = input.float(0.1, "Min Penetration (ATR)", step=0.05, group=grpSweep)
sweepMaxPenetration = input.float(1.0, "Max Penetration (ATR)", step=0.1, group=grpSweep)
sweepConfirmBars = input.int(3, "Confirm Bars (no new extreme)", minval=1, group=grpSweep, tooltip="After sweep candle, require N bars where price doesn't exceed the sweep extreme. Sweep plotted retroactively at the sweep bar.")

grpDiv = "3. RSI Divergence"
useDiv      = input.bool(true, "Enable RSI Divergence", group=grpDiv)
rsiLen      = input.int(14, "RSI Length", group=grpDiv)
divLookback = input.int(80, "Max Bars Back for Prior Pivot", group=grpDiv)
divMinDistance = input.int(15, "Min Bars Between Pivots", group=grpDiv)

grpExt = "4. Pivot + Extension"
useExt        = input.bool(true, "Enable Pivot + Extension", group=grpExt)
extEMALen     = input.int(50, "EMA Length", group=grpExt)
extMinATR     = input.float(3.0, "Min Distance from EMA (ATR)", step=0.1, group=grpExt)
extStrongPivotBars = input.int(30, "Extension: Pivot Must Be Extreme in N Bars", group=grpExt)

grpCooldown = "5. Signal Cooldown"
cooldownBars = input.int(20, "Cooldown Bars (per direction)", minval=0, group=grpCooldown)

grpTier = "6. Tier Classification"
clusterWindow = input.int(8, "Cluster Window (bars)", minval=1, maxval=20, group=grpTier)
bigTierMin = input.int(2, "Big Triangle: Min Criteria", minval=1, maxval=3, group=grpTier)

grpInval = "7. Invalidation"
useInval     = input.bool(true, "Show Invalidation Marks (X)", group=grpInval)
invalBars    = input.int(8, "Invalidation Window", group=grpInval)
invalATR     = input.float(0.6, "Invalidation Distance (ATR)", step=0.1, group=grpInval)

grpVisual = "8. Visual"
showSweep    = input.bool(true, "Show Sweep Signals", group=grpVisual)
showDiv      = input.bool(true, "Show Divergence Signals", group=grpVisual)
showExt      = input.bool(true, "Show Extension Signals", group=grpVisual)
showBig      = input.bool(true, "Show Big (cluster) Signals", group=grpVisual)
showEMA      = input.bool(true, "Show EMA Reference", group=grpVisual)

// ── INDICATORS ─────────────────────────────────────────────────
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(14)
ema_val = ta.ema(close, extEMALen)

// ── PIVOT DETECTION ────────────────────────────────────────────
pivotHighRaw = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLowRaw  = ta.pivotlow(low, pivotLeft, pivotRight)

recentAvg = ta.sma(close, pivotProminenceBars)
recentAvgAtPivot = recentAvg[pivotRight]
atrAtPivot = atrVal[pivotRight]

pivotHighProminent = not na(pivotHighRaw) and (pivotHighRaw - recentAvgAtPivot) > atrAtPivot * pivotProminenceATR
pivotLowProminent  = not na(pivotLowRaw) and (recentAvgAtPivot - pivotLowRaw) > atrAtPivot * pivotProminenceATR

pivotHigh = pivotHighProminent ? pivotHighRaw : na
pivotLow  = pivotLowProminent ? pivotLowRaw : na

// Track pivot history
var float lastPivotHigh = na
var int   lastPivotHighBar = na
var float lastPivotHighRSI = na
var float prevPivotHigh = na
var int   prevPivotHighBar = na
var float prevPivotHighRSI = na

var float lastPivotLow = na
var int   lastPivotLowBar = na
var float lastPivotLowRSI = na
var float prevPivotLow = na
var int   prevPivotLowBar = na
var float prevPivotLowRSI = na

if not na(pivotHigh)
    prevPivotHigh := lastPivotHigh
    prevPivotHighBar := lastPivotHighBar
    prevPivotHighRSI := lastPivotHighRSI
    lastPivotHigh := pivotHigh
    lastPivotHighBar := bar_index - pivotRight
    lastPivotHighRSI := rsiVal[pivotRight]

if not na(pivotLow)
    prevPivotLow := lastPivotLow
    prevPivotLowBar := lastPivotLowBar
    prevPivotLowRSI := lastPivotLowRSI
    lastPivotLow := pivotLow
    lastPivotLowBar := bar_index - pivotRight
    lastPivotLowRSI := rsiVal[pivotRight]

// ── SIGNAL 1: LIQUIDITY SWEEP (now pivot-based + confirmed) ────
// Track recent confirmed pivots to use as sweep targets
var array<float> recentPivotHighs = array.new<float>()
var array<int>   recentPivotHighBars = array.new<int>()
var array<float> recentPivotLows = array.new<float>()
var array<int>   recentPivotLowBars = array.new<int>()

if not na(pivotHigh)
    array.push(recentPivotHighs, pivotHigh)
    array.push(recentPivotHighBars, bar_index - pivotRight)
    // Trim old pivots beyond lookback
    while array.size(recentPivotHighBars) > 0 and (bar_index - array.get(recentPivotHighBars, 0)) > sweepPivotLookback
        array.shift(recentPivotHighs)
        array.shift(recentPivotHighBars)

if not na(pivotLow)
    array.push(recentPivotLows, pivotLow)
    array.push(recentPivotLowBars, bar_index - pivotRight)
    while array.size(recentPivotLowBars) > 0 and (bar_index - array.get(recentPivotLowBars, 0)) > sweepPivotLookback
        array.shift(recentPivotLows)
        array.shift(recentPivotLowBars)

// Find highest prior pivot high (the level being swept)
priorPivotHigh = array.size(recentPivotHighs) > 0 ? array.max(recentPivotHighs) : na
priorPivotLow  = array.size(recentPivotLows) > 0 ? array.min(recentPivotLows) : na

// Raw sweep candidate (on the bar itself)
penetrationHigh = not na(priorPivotHigh) ? high - priorPivotHigh : 0.0
penetrationLow  = not na(priorPivotLow) ? priorPivotLow - low : 0.0

bearSweepCandidate1 = useSweep and not na(priorPivotHigh) and high > priorPivotHigh and close < priorPivotHigh
bearSweepCandidate2 = penetrationHigh >= atrVal * sweepMinPenetration and penetrationHigh <= atrVal * sweepMaxPenetration
bearSweepCandidate = bearSweepCandidate1 and bearSweepCandidate2

bullSweepCandidate1 = useSweep and not na(priorPivotLow) and low < priorPivotLow and close > priorPivotLow
bullSweepCandidate2 = penetrationLow >= atrVal * sweepMinPenetration and penetrationLow <= atrVal * sweepMaxPenetration
bullSweepCandidate = bullSweepCandidate1 and bullSweepCandidate2

// Track candidate sweeps and confirm them after N bars
var float pendingBearSweepHigh = na
var int   pendingBearSweepBar = na
var float pendingBullSweepLow = na
var int   pendingBullSweepBar = na

if bearSweepCandidate
    pendingBearSweepHigh := high
    pendingBearSweepBar := bar_index

if bullSweepCandidate
    pendingBullSweepLow := low
    pendingBullSweepBar := bar_index

// Confirmation: after sweepConfirmBars, did price stay below/above?
bearSweep = false
bullSweep = false

if not na(pendingBearSweepBar) and (bar_index - pendingBearSweepBar) == sweepConfirmBars
    // Check if any bar between candidate and now exceeded the sweep high
    maxSinceCandidate = ta.highest(high, sweepConfirmBars + 1)
    if maxSinceCandidate <= pendingBearSweepHigh
        bearSweep := true
    pendingBearSweepHigh := na
    pendingBearSweepBar := na

if not na(pendingBullSweepBar) and (bar_index - pendingBullSweepBar) == sweepConfirmBars
    minSinceCandidate = ta.lowest(low, sweepConfirmBars + 1)
    if minSinceCandidate >= pendingBullSweepLow
        bullSweep := true
    pendingBullSweepLow := na
    pendingBullSweepBar := na

// ── SIGNAL 2: RSI DIVERGENCE ───────────────────────────────────
bearDivRaw = false
if useDiv and not na(pivotHigh) and not na(prevPivotHigh) and not na(prevPivotHighRSI)
    barsApart = bar_index - pivotRight - prevPivotHighBar
    if barsApart >= divMinDistance and barsApart <= divLookback
        if pivotHigh > prevPivotHigh and rsiVal[pivotRight] < prevPivotHighRSI
            bearDivRaw := true

bullDivRaw = false
if useDiv and not na(pivotLow) and not na(prevPivotLow) and not na(prevPivotLowRSI)
    barsApart = bar_index - pivotRight - prevPivotLowBar
    if barsApart >= divMinDistance and barsApart <= divLookback
        if pivotLow < prevPivotLow and rsiVal[pivotRight] > prevPivotLowRSI
            bullDivRaw := true

// ── SIGNAL 3: PIVOT + EXTENSION ────────────────────────────────
bearExtRaw = false
bullExtRaw = false

if useExt and not na(pivotHigh)
    pivotBarHigh = high[pivotRight]
    pivotBarEMA = ema_val[pivotRight]
    pivotBarATR = atrVal[pivotRight]
    pivotIsStrong = pivotBarHigh >= ta.highest(high, extStrongPivotBars)[pivotRight]
    if pivotIsStrong and (pivotBarHigh - pivotBarEMA) > pivotBarATR * extMinATR
        bearExtRaw := true

if useExt and not na(pivotLow)
    pivotBarLow = low[pivotRight]
    pivotBarEMA = ema_val[pivotRight]
    pivotBarATR = atrVal[pivotRight]
    pivotIsStrong = pivotBarLow <= ta.lowest(low, extStrongPivotBars)[pivotRight]
    if pivotIsStrong and (pivotBarEMA - pivotBarLow) > pivotBarATR * extMinATR
        bullExtRaw := true

// ── COOLDOWN ───────────────────────────────────────────────────
var int lastBearSignalBar = na
var int lastBullSignalBar = na

bearCooldownOk = na(lastBearSignalBar) or (bar_index - lastBearSignalBar) >= cooldownBars
bullCooldownOk = na(lastBullSignalBar) or (bar_index - lastBullSignalBar) >= cooldownBars

bearSweepFinal = bearSweep and bearCooldownOk
bullSweepFinal = bullSweep and bullCooldownOk
bearDivFinal   = bearDivRaw   and bearCooldownOk
bullDivFinal   = bullDivRaw   and bullCooldownOk
bearExtFinal   = bearExtRaw   and bearCooldownOk
bullExtFinal   = bullExtRaw   and bullCooldownOk

if bearSweepFinal or bearDivFinal or bearExtFinal
    lastBearSignalBar := bar_index
if bullSweepFinal or bullDivFinal or bullExtFinal
    lastBullSignalBar := bar_index

// ── TIER CLASSIFICATION ────────────────────────────────────────
bearSweepRecent = ta.barssince(bearSweepFinal) <= clusterWindow
bearDivRecent   = ta.barssince(bearDivFinal) <= clusterWindow
bearExtRecent   = ta.barssince(bearExtFinal) <= clusterWindow
bearCriteriaCount = (bearSweepRecent ? 1 : 0) + (bearDivRecent ? 1 : 0) + (bearExtRecent ? 1 : 0)

bullSweepRecent = ta.barssince(bullSweepFinal) <= clusterWindow
bullDivRecent   = ta.barssince(bullDivFinal) <= clusterWindow
bullExtRecent   = ta.barssince(bullExtFinal) <= clusterWindow
bullCriteriaCount = (bullSweepRecent ? 1 : 0) + (bullDivRecent ? 1 : 0) + (bullExtRecent ? 1 : 0)

hasAnyBearSignal = bearSweepFinal or bearDivFinal or bearExtFinal
hasAnyBullSignal = bullSweepFinal or bullDivFinal or bullExtFinal

bearBig = hasAnyBearSignal and bearCriteriaCount >= bigTierMin
bullBig = hasAnyBullSignal and bullCriteriaCount >= bigTierMin

// ── INVALIDATION ───────────────────────────────────────────────
var float lastBearLevel = na
var int   lastBearBar = na
var float lastBullLevel = na
var int   lastBullBar = na

if hasAnyBearSignal
    lastBearLevel := high
    lastBearBar := bar_index
if hasAnyBullSignal
    lastBullLevel := low
    lastBullBar := bar_index

bearInvalidated = useInval and not na(lastBearLevel) and bar_index <= lastBearBar + invalBars and high > lastBearLevel + atrVal * invalATR
bullInvalidated = useInval and not na(lastBullLevel) and bar_index <= lastBullBar + invalBars and low < lastBullLevel - atrVal * invalATR

if bearInvalidated
    lastBearLevel := na
if bullInvalidated
    lastBullLevel := na

// ── PLOTTING ───────────────────────────────────────────────────
// Sweep plotted retroactively at the sweep bar (offset = -sweepConfirmBars)
plotshape(showSweep and bearSweepFinal, "Bear Sweep", shape.triangledown, location.abovebar, color.new(color.fuchsia, 0), size=size.small, offset=-sweepConfirmBars)
plotshape(showSweep and bullSweepFinal, "Bull Sweep", shape.triangleup,   location.belowbar, color.new(color.aqua, 0),    size=size.small, offset=-sweepConfirmBars)

plotshape(showDiv and bearDivFinal, "Bear Divergence", shape.triangledown, location.abovebar, color.new(color.red, 0),   size=size.small, offset=-pivotRight)
plotshape(showDiv and bullDivFinal, "Bull Divergence", shape.triangleup,   location.belowbar, color.new(color.green, 0), size=size.small, offset=-pivotRight)

plotshape(showExt and bearExtFinal, "Bear Extension", shape.triangledown, location.abovebar, color.new(color.orange, 0), size=size.small, offset=-pivotRight)
plotshape(showExt and bullExtFinal, "Bull Extension", shape.triangleup,   location.belowbar, color.new(color.lime, 0),   size=size.small, offset=-pivotRight)

plotshape(showBig and bearBig, "Bear BIG", shape.triangledown, location.abovebar, color.new(color.red, 0),   size=size.large)
plotshape(showBig and bullBig, "Bull BIG", shape.triangleup,   location.belowbar, color.new(color.green, 0), size=size.large)

plotshape(useInval and bearInvalidated, "Bear Invalid", shape.xcross, location.abovebar, color.new(color.maroon, 30), size=size.tiny)
plotshape(useInval and bullInvalidated, "Bull Invalid", shape.xcross, location.belowbar, color.new(color.maroon, 30), size=size.tiny)

plot(showEMA ? ema_val : na, "EMA Reference", color=color.new(color.gray, 60), linewidth=1)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(bearSweepFinal, "Bear Liquidity Sweep", "HuntersRev v2.3: Bear Sweep on {{ticker}}")
alertcondition(bullSweepFinal, "Bull Liquidity Sweep", "HuntersRev v2.3: Bull Sweep on {{ticker}}")
alertcondition(bearDivFinal,   "Bear Divergence",      "HuntersRev v2.3: Bear Divergence on {{ticker}}")
alertcondition(bullDivFinal,   "Bull Divergence",      "HuntersRev v2.3: Bull Divergence on {{ticker}}")
alertcondition(bearExtFinal,   "Bear Extension",       "HuntersRev v2.3: Bear Extension on {{ticker}}")
alertcondition(bullExtFinal,   "Bull Extension",       "HuntersRev v2.3: Bull Extension on {{ticker}}")
alertcondition(bearBig,        "Bear BIG (cluster)",   "HuntersRev v2.3: BEAR CLUSTER on {{ticker}}")
alertcondition(bullBig,        "Bull BIG (cluster)",   "HuntersRev v2.3: BULL CLUSTER on {{ticker}}")
````

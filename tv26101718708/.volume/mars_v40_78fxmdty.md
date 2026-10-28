# MARS V4.0

- url: https://www.tradingview.com/script/78fXmDTy-MARS-V4-0/
- type: indicator
- pine_id: PUB;cb3293f60512493792a82d581aa44fe1
- version: 1.0

## Description

MARS 4.0 is a trend-structure and portfolio management framework designed to identify, classify, and manage equity trends through their full lifecycle.

Rather than functioning as a traditional buy/sell indicator, MARS 4.0 acts as a market regime engine that evaluates:

structural trend quality,
trend maturity,
price extension,
trend efficiency,
portfolio suitability,
and capital deployment opportunity.

The system is built around the principle that:

“A good stock is not always a good entry.”

MARS 4.0 distinguishes between:

early-stage developing trends,
mature structural leaders,
deteriorating trends,
repair/recovery phases,
and excessively extended momentum conditions.

This allows the framework to support:

portfolio construction,
risk management,
capital rotation,
watchlist prioritisation,
and discretionary decision-making.
Core Components
Trend Structure Engine

The script evaluates:

fast trend alignment,
slow structural trend alignment,
moving average relationships,
persistence of trend behaviour,
and pullback integrity.

This creates a dynamic classification of market state.

Trend Maturity Analysis

MARS 4.0 measures how developed a trend has become.

Early trends may offer:

better asymmetry,
lower extension risk,
and stronger future upside potential.

Mature trends may still be strong holdings but require:

reduced aggression,
tighter risk control,
and careful position sizing.
Extension & Risk Framework

The system measures extension using ATR-based distance from equilibrium.

This helps identify:

chase-risk conditions,
exhaustion phases,
elevated volatility risk,
and poor reward-to-risk entries.

Rather than blindly rewarding strength, MARS evaluates whether:

the move is still investable,
or already overcrowded and statistically stretched.
Portfolio Classification System

The framework classifies securities into operational portfolio states such as:

Core Hold
Hold / Wait
Watchlist / Repair
Reduce Aggression
Avoid / No Action

This converts technical structure into practical portfolio guidance.

MARS 4.0 Scanner Engine

MARS 4.0 introduces hidden quantitative outputs that allow the framework to operate as a ranking and scanning engine.

MARS4 Alpha Score

A composite quality score combining:

regime strength,
maturity,
efficiency,
opportunity quality,
and extension risk.

Higher scores indicate stronger deployable trend quality.

MARS4 Scan State

A simplified operational state model:

State	Meaning
0	Neutral
1	Watchlist / Repair
2	Fresh Money OK
3	Early Trend
4	Core Hold
5	Reduce / Avoid

This enables:

portfolio triage,
systematic scanning,
and capital allocation workflows.
Intended Use

MARS 4.0 is designed for:

swing traders,
trend-following investors,
discretionary portfolio managers,
and long-term equity trend analysis.

The framework is particularly effective for:

weekly timeframe analysis,
portfolio rotation,
and identifying institutional-quality trend behaviour.
Design Philosophy

MARS 4.0 prioritises:

clarity over complexity,
structure over prediction,
and risk-adjusted opportunity rather than pure momentum.

The system intentionally avoids excessive indicator stacking and instead focuses on refining:

trend behaviour,
market structure,
extension dynamics,
and portfolio context.

The objective is not to predict markets, but to:

systematically identify where risk/reward conditions are most favourable across the trend lifecycle.

## Source Code

````pine
//@version=6
indicator("MARS V3.0", shorttitle="MARS3.0", overlay=true)

//──────────────────────────────────────────────────────────────────────────────
// Moving averages
//──────────────────────────────────────────────────────────────────────────────
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

// Inputs
show_ma1   = input.bool(true,         "MA #1")
ma1_type   = input.string("EMA",      "MA1 Type",  options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma1_source = input.source(close,      "MA1 Source")
ma1_length = input.int(20,            "MA1 Length", minval=1)
ma1_color  = input.color(color.new(#18a73c, 0), "MA1 Line Colour")

show_ma2   = input.bool(true,         "MA #2")
ma2_type   = input.string("EMA",      "MA2 Type",  options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma2_source = input.source(close,      "MA2 Source")
ma2_length = input.int(35,            "MA2 Length", minval=1)
ma2_color  = input.color(color.new(#e90505, 0), "MA2 Line Colour")

show_ma3   = input.bool(true,         "MA #3")
ma3_type   = input.string("EMA",      "MA3 Type",  options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma3_source = input.source(close,      "MA3 Source")
ma3_length = input.int(145,           "MA3 Length", minval=1)
ma3_color  = input.color(color.new(#18a73c, 0), "MA3 Line Colour")

show_ma4   = input.bool(true,         "MA #4")
ma4_type   = input.string("EMA",      "MA4 Type",  options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"])
ma4_source = input.source(close,      "MA4 Source")
ma4_length = input.int(235,           "MA4 Length", minval=1)
ma4_color  = input.color(color.new(#e90505, 0), "MA4 Line Colour")

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

plot(ma1, "MA #1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display = show_ma4 ? display.all : display.none)

//──────────────────────────────────────────────────────────────────────────────
// Cloud / Fill settings
//──────────────────────────────────────────────────────────────────────────────
grp = "Cloud / Fill"
showFastCloud  = input.bool(true,  "Show Fast Cloud (MA1–MA2)", group=grp)
showSlowCloud  = input.bool(true,  "Show Slow Cloud (MA3–MA4)", group=grp)
showOverlap    = input.bool(true,  "Fill Between Clouds (Overlap Only)", group=grp)

fastOpacity    = input.int(75, "Fast Cloud Opacity (0–100)", minval=0, maxval=100, group=grp)
slowOpacity    = input.int(85, "Slow Cloud Opacity (0–100)", minval=0, maxval=100, group=grp)
overlapOpacity = input.int(20, "Extra Opacity on Overlap",   minval=0, maxval=90,  group=grp)

colBull = color.lime
colBear = color.red
colNeut = color.orange

//──────────────────────────────────────────────────────────────────────────────
// Signal sensitivity
//──────────────────────────────────────────────────────────────────────────────
sigGrp = "Signal Sensitivity"
slopeLenFast = input.int(2, "Fast: rising/falling lookback", minval=1, group=sigGrp)
slopeLenSlow = input.int(3, "Slow: rising/falling lookback", minval=1, group=sigGrp)

isRising(src, lb)  => ta.rising(src, lb)
isFalling(src, lb) => ta.falling(src, lb)

//──────────────────────────────────────────────────────────────────────────────
// FAST ribbon
//──────────────────────────────────────────────────────────────────────────────
fast_ok   = show_ma1 and show_ma2 and not na(ma1) and not na(ma2)
fastBull  = fast_ok and ma1 > ma2 and isRising(ma1, slopeLenFast) and isRising(ma2, slopeLenFast) and close > ma1 and close > ma2
fastBear  = fast_ok and ma1 < ma2 and isFalling(ma1, slopeLenFast) and isFalling(ma2, slopeLenFast) and close < ma1 and close < ma2
fastColor = fastBull ? colBull : fastBear ? colBear : colNeut

//──────────────────────────────────────────────────────────────────────────────
// SLOW ribbon
//──────────────────────────────────────────────────────────────────────────────
slow_ok   = show_ma3 and show_ma4 and not na(ma3) and not na(ma4)
slowBull  = slow_ok and ma3 > ma4 and isRising(ma3, slopeLenSlow) and isRising(ma4, slopeLenSlow) and (close > ma3 or close > ma4)
slowBear  = slow_ok and ma3 < ma4 and isFalling(ma3, slopeLenSlow) and isFalling(ma4, slopeLenSlow) and (close < ma3 or close < ma4)
slowColor = slowBull ? colBull : slowBear ? colBear : colNeut

//──────────────────────────────────────────────────────────────────────────────
// Cloud bounds & fills
//──────────────────────────────────────────────────────────────────────────────
fastTop = fast_ok ? math.max(ma1, ma2) : na
fastBot = fast_ok ? math.min(ma1, ma2) : na
slowTop = slow_ok ? math.max(ma3, ma4) : na
slowBot = slow_ok ? math.min(ma3, ma4) : na

fastAboveSlow = fast_ok and slow_ok and fastBot > slowTop

pFastTop = plot(fastTop, display=display.none, title="Fast Cloud Top")
pFastBot = plot(fastBot, display=display.none, title="Fast Cloud Bottom")
pSlowTop = plot(slowTop, display=display.none, title="Slow Cloud Top")
pSlowBot = plot(slowBot, display=display.none, title="Slow Cloud Bottom")

fill(pFastTop, pFastBot, color = showFastCloud ? color.new(fastColor, fastOpacity) : na, title="Fast Cloud")
fill(pSlowTop, pSlowBot, color = showSlowCloud ? color.new(slowColor, slowOpacity) : na, title="Slow Cloud")

overlapTop    = math.min(fastTop, slowTop)
overlapBottom = math.max(fastBot, slowBot)
hasOverlap    = overlapTop > overlapBottom

pOvTop = plot(overlapTop,    display=display.none, title="Overlap Top")
pOvBot = plot(overlapBottom, display=display.none, title="Overlap Bottom")

agreeBull = fastBull and slowBull
agreeBear = fastBear and slowBear
ovrBase   = agreeBull ? colBull : agreeBear ? colBear : colNeut
overlapColor = color.new(ovrBase, math.max(0, math.min(100, slowOpacity - overlapOpacity)))

fill(pOvTop, pOvBot, color = (showOverlap and hasOverlap) ? overlapColor : na, title="Overlap Fill (Fast ∩ Slow)")

//──────────────────────────────────────────────────────────────────────────────
// Wick rejection filter
//──────────────────────────────────────────────────────────────────────────────
wickGrp = "Wick Rejection Filter"
useWickFilter      = input.bool(true, "Use upper-wick rejection filter", group=wickGrp)
maxUpperWickPct    = input.float(0.35, "Max upper wick % of range", minval=0.0, maxval=0.95, step=0.05, group=wickGrp)
minRangeForWick    = input.float(0.0001, "Min range (avoid div0)", minval=0.0, step=0.0001, group=wickGrp)

barRange   = math.max(high - low, minRangeForWick)
upperWick  = high - math.max(open, close)
upperWickPct = upperWick / barRange
wickOK = (not useWickFilter) or (upperWickPct <= maxUpperWickPct)

//──────────────────────────────────────────────────────────────────────────────
// Continuation Setup (CS)
//──────────────────────────────────────────────────────────────────────────────
contGrp          = "Continuation Setup"
showContinuation = input.bool(true,  "Show Continuation markers", group=contGrp)
demandLookback   = input.int(8,      "Demand vs Supply lookback", minval=2, group=contGrp)
requireDemand    = input.bool(true,  "Require demand > supply",   group=contGrp)
contPullbackLen  = input.int(5,      "Pullback window (bars)",    minval=2, group=contGrp)

csLLbars            = input.int(2,     "CS: # lower-low events required", minval=1, maxval=20, group=contGrp)
csUseEqLow          = input.bool(true, "CS: allow equal lows in LL events", group=contGrp)
csRequireFastTouch  = input.bool(false,"CS: require pullback touched fast ribbon", group=contGrp)
csRequireCloseBreak = input.bool(false,"CS: require CLOSE > anchor high (stricter)", group=contGrp)
csUpBarRequired     = input.bool(true, "CS: require up-bar on breakout", group=contGrp)

csPLLeft  = input.int(2, "CS: anchor pivot LOW left bars",  minval=1, maxval=10, group=contGrp)
csPLRight = input.int(2, "CS: anchor pivot LOW right bars", minval=1, maxval=10, group=contGrp)
csHLLeft  = input.int(2, "CS: cooldown HL pivot left bars",  minval=1, maxval=10, group=contGrp)
csHLRight = input.int(2, "CS: cooldown HL pivot right bars", minval=1, maxval=10, group=contGrp)
csDebug = input.bool(false, "CS: debug plots", group=contGrp)

// Refinement: allow CS to appear in healthy rotational leaders without adding new indicators.
csAllowRotational      = input.bool(true, "CS: allow rotational continuation", group=contGrp)
csRotBreakLen          = input.int(6, "CS: rotational breakout lookback", minval=2, maxval=20, group=contGrp)
csRotCooldownBars      = input.int(6, "CS: rotational cooldown bars", minval=1, maxval=30, group=contGrp)

isDemand = close > open
isSupply = close < open

demandCount    = ta.sma(isDemand ? 1.0 : 0.0, demandLookback) * demandLookback
supplyCount    = ta.sma(isSupply ? 1.0 : 0.0, demandLookback) * demandLookback
demandDominant = demandCount > supplyCount

aboveSlow   = slow_ok and close > ma3 and close > ma4
trendUpCont = fastBull and aboveSlow

touchedFast = fast_ok and ta.lowest(low[1], contPullbackLen) <= fastTop[1]

plCD = ta.pivotlow(low, csHLLeft, csHLRight)
var float lastCooldownPivotLow = na
var bool  needHL = false

newHL = false
if not na(plCD)
    if not na(lastCooldownPivotLow) and plCD > lastCooldownPivotLow
        newHL := true
    lastCooldownPivotLow := plCD

if needHL and newHL
    needHL := false

plAnchor = ta.pivotlow(low, csPLLeft, csPLRight)

var int segmentLen = na
if not na(plAnchor)
    segmentLen := csPLRight

if not na(segmentLen)
    segmentLen += 1

anchorHigh = not na(segmentLen) ? ta.highest(high[1], segmentLen) : na

llCountSeg = 0
if not na(segmentLen)
    maxI = math.min(segmentLen - 1, 200)
    for i = 1 to maxI
        llEvent = csUseEqLow ? (low[i] <= low[i + 1]) : (low[i] < low[i + 1])
        if llEvent
            llCountSeg += 1

csArmed = llCountSeg >= csLLbars
breaksAnchor = not na(anchorHigh) and (csRequireCloseBreak ? close > anchorHigh : high > anchorHigh)
csUpBar = close > open
passesUpBar = (not csUpBarRequired) or csUpBar

hhAfterLL = (not needHL) and csArmed and breaksAnchor and passesUpBar and wickOK

if hhAfterLL
    needHL := true

// Standard CS: pullback structure followed by breakout.
standardContinuationSignal = (
    showContinuation
    and trendUpCont
    and hhAfterLL
    and (not csRequireFastTouch or touchedFast)
    and (not requireDemand or demandDominant)
)

// Rotational CS: for strong leaders where structure remains intact,
// but the pullback is shallower / cleaner than the original LL-anchor logic.
csRotationalTrend =
     csAllowRotational
     and fast_ok
     and slow_ok
     and ma1 > ma2
     and close > fastBot
     and close > slowTop
     and not fastBear

csRotationalPullback =
     fast_ok
     and ta.lowest(low[1], contPullbackLen) <= fastTop[1]

csRotationalBreak =
     high > ta.highest(high[1], csRotBreakLen)

var int lastCSRotBar = na
csRotCooldownOK = na(lastCSRotBar) or (bar_index - lastCSRotBar > csRotCooldownBars)

rotationalContinuationSignal = (
     showContinuation
     and csRotationalTrend
     and csRotationalPullback
     and csRotationalBreak
     and passesUpBar
     and wickOK
     and (not requireDemand or demandDominant)
     and csRotCooldownOK
)

if rotationalContinuationSignal
    lastCSRotBar := bar_index

continuationSignal = standardContinuationSignal or rotationalContinuationSignal

plot(csDebug ? anchorHigh : na, "CS AnchorHigh", color=color.new(color.blue, 0), linewidth=1)
plotchar(csDebug and csArmed,      "CS Armed",  "A", location=location.top)
plotchar(csDebug and needHL,       "CS NeedHL", "H", location=location.top)
plotchar(csDebug and breaksAnchor, "CS Breaks", "B", location=location.top)
plotchar(csDebug and rotationalContinuationSignal, "CS Rotational", "R", location=location.top)

// Shared trend-turn tracker used later by TS/TS+ and by RA suppression.
var int lastTrendTurnBar = na

//──────────────────────────────────────────────────────────────────────────────
// Re-Acceleration (RA) - original engine restored, with Compression + RVOL grading
//──────────────────────────────────────────────────────────────────────────────
raGrp = "Re-Acceleration (RA)"
showRA         = input.bool(true, "Show RA markers", group=raGrp)
raLookback     = input.int(8, "RA: pullback window (bars)", minval=3, maxval=30, group=raGrp)
raLLRequired   = input.int(2, "RA: LL events required", minval=1, maxval=10, group=raGrp)
raBreakLen     = input.int(3, "RA: breakout lookback (bars)", minval=2, maxval=10, group=raGrp)
raNeedResetBar = input.bool(true, "RA: require reset (down bar or MA1 touch) before next", group=raGrp)
raHHLen        = input.int(20, "RA: higher-high lookback (bars)", minval=5, maxval=200, group=raGrp)
raMinPause     = input.int(3, "RA: min bars since last HH", minval=1, maxval=10, group=raGrp)

// Signal spacing / suppression controls.
raCooldownBars        = input.int(8, "RA: minimum bars between RA signals", minval=1, maxval=100, group=raGrp)
raPlusCooldownBars    = input.int(14, "RA+/RA++: minimum bars between strong RA signals", minval=1, maxval=150, group=raGrp)
raSuppressAfterTurn   = input.int(6, "RA: suppress bars after TS/TS+", minval=0, maxval=50, group=raGrp)
raRequireResetForPlus = input.bool(true, "RA+/RA++: require compression reset since last strong RA", group=raGrp)

// Trend Lock controls.
// Purpose: reduce repeated RA labels during smooth mature institutional trends.
useTrendLock          = input.bool(true, "Trend Lock: suppress RA until meaningful reset", group=raGrp)
trendLockAfterRAPlus  = input.bool(true, "Trend Lock: activate after RA+/RA++", group=raGrp)
trendLockAfterTurn    = input.bool(true, "Trend Lock: activate after TS/TS+", group=raGrp)
trendLockMaturityBars = input.int(20, "Trend Lock: only enforce after bars from turn", minval=0, maxval=200, group=raGrp)
deepResetLookback     = input.int(12, "Trend Lock: reset lookback bars", minval=2, maxval=100, group=raGrp)
deepResetPct          = input.float(6.0, "Trend Lock: reset pullback %", minval=1.0, maxval=30.0, step=0.5, group=raGrp)
deepResetATRMult      = input.float(2.0, "Trend Lock: reset pullback ATR multiple", minval=0.5, maxval=10.0, step=0.25, group=raGrp)
unlockOnFastBear      = input.bool(true, "Trend Lock: unlock if fast ribbon breaks", group=raGrp)
unlockOnSlowBreak     = input.bool(true, "Trend Lock: unlock if price breaks slow cloud", group=raGrp)

// These are now grading tools only — they do NOT block the base RA signal.
rvolLen        = input.int(20, "RA grade: RVOL average length", minval=5, maxval=100, group=raGrp)
rvolStrongMin  = input.float(1.30, "RA grade: strong RVOL threshold", minval=0.1, maxval=10.0, step=0.05, group=raGrp)

compressionLookback   = input.int(6, "RA grade: compression lookback bars", minval=2, maxval=30, group=raGrp)
tightBarsRequired     = input.int(2, "RA grade: tight bars required", minval=1, maxval=10, group=raGrp)
rangeAvgLen           = input.int(20, "RA grade: average range length", minval=5, maxval=100, group=raGrp)
tightRangeMultiplier  = input.float(0.80, "RA grade: tight range multiplier", minval=0.10, maxval=2.00, step=0.05, group=raGrp)

showRAFilterLabels = input.bool(false, "RA: show compression/RVOL debug labels", group=raGrp)

raColorStandard = color.new(color.aqua, 0)
raColorTran     = color.new(color.orange, 0)
raColorPlus     = color.new(color.blue, 0)
raColorElite    = color.new(color.purple, 0)

// Original pullback structure: count lower-low / equal-low events.
raLL = 0
for i = 1 to raLookback
    llEvent = csUseEqLow ? (low[i] <= low[i+1]) : (low[i] < low[i+1])
    if llEvent
        raLL += 1

raPullbackOk = raLL >= raLLRequired

// Original higher-high breakout trigger.
raIsHH  = high > ta.highest(high[1], raHHLen)
raUpBar = close > open

// Pause filter: require at least N bars since the previous HH.
barsSincePriorHH = ta.barssince(raIsHH[1])
raPauseOK = na(barsSincePriorHH) ? true : (barsSincePriorHH >= raMinPause)

// Original trend context.
raTrend = fast_ok and (not fastBear) and close > fastTop
raAboveSlow = fastAboveSlow

// Reset gate: require either a down bar or a touch of MA1 before another RA.
var bool raCanFire = true
raReset = (close < open) or (fast_ok and low <= ma1)
if raNeedResetBar and raReset
    raCanFire := true

// Base RA signal setup — compression and RVOL are NOT hard filters here.
raSetup = (
    showRA
    and raCanFire
    and raTrend
    and raPullbackOk
    and raIsHH
    and raUpBar
    and raPauseOK
    and wickOK
)

// Signal spacing, post-turn suppression, and trend-lock suppression.
var int lastRASignalBar = na
var int lastRAPlusSignalBar = na
var bool compressionResetSinceStrongRA = true
var bool trendLocked = false
var int trendLockBar = na

// Trend Lock reset logic.
// A reset can be price-based, ATR-based, fast-ribbon breakdown, or slow-cloud breakdown.
highestCloseReset = ta.highest(close, deepResetLookback)
resetPullbackPct = highestCloseReset > 0 ? ((highestCloseReset - low) / highestCloseReset) * 100.0 : 0.0
resetATR = ta.atr(14)
resetPullbackATR = resetATR > 0 ? (highestCloseReset - low) / resetATR : 0.0
priceReset = resetPullbackPct >= deepResetPct or resetPullbackATR >= deepResetATRMult
fastRibbonReset = unlockOnFastBear and fast_ok and (close < ma2 or fastBear)
slowCloudReset = unlockOnSlowBreak and slow_ok and close < slowTop
trendLockReset = priceReset or fastRibbonReset or slowCloudReset

if trendLocked and trendLockReset
    trendLocked := false

barsFromTurnForLock = not na(lastTrendTurnBar) ? bar_index - lastTrendTurnBar : na
matureEnoughForLock = na(barsFromTurnForLock) or barsFromTurnForLock >= trendLockMaturityBars
trendLockSuppressRA = useTrendLock and trendLocked and matureEnoughForLock

recentTurnForRASuppression = not na(lastTrendTurnBar) and (bar_index - lastTrendTurnBar <= raSuppressAfterTurn)
raCooldownOK = na(lastRASignalBar) or (bar_index - lastRASignalBar > raCooldownBars)

raSignal = raSetup and raCooldownOK and not recentTurnForRASuppression and not trendLockSuppressRA

if raSignal
    lastRASignalBar := bar_index

if raSignal and raNeedResetBar
    raCanFire := false

//──────────────────────────────────────────────────────────────────────────────
// RA quality grading — informational only
//──────────────────────────────────────────────────────────────────────────────

// Relative Volume grade.
avgVol = ta.sma(volume, rvolLen)
rvol = avgVol > 0 ? volume / avgVol : na
raStrongVolume = not na(rvol) and rvol >= rvolStrongMin

// Compression grade.
rangePct = (high - low) / close
avgRangePct = ta.sma(rangePct, rangeAvgLen)

tightBarCount = 0
for i = 1 to compressionLookback
    priorRangePct = (high[i] - low[i]) / close[i]
    priorAvgRangePct = ta.sma(rangePct, rangeAvgLen)[i]
    priorTight = not na(priorAvgRangePct) and priorRangePct < priorAvgRangePct * tightRangeMultiplier
    if priorTight
        tightBarCount += 1

raCompression = tightBarCount >= tightBarsRequired

// After a strong RA, require the market to cool/compress before allowing another RA+/RA++.
if not raCompression
    compressionResetSinceStrongRA := true

// Label hierarchy:
// RA   = standard re-acceleration
// RA+  = compression OR strong RVOL present
// RA++ = compression AND strong RVOL present
// Extra spacing is applied only to RA+/RA++ so strong labels do not cluster.
raStrongCandidate = raSignal and (raCompression or raStrongVolume)
raEliteCandidate  = raSignal and raCompression and raStrongVolume
raPlusCooldownOK  = na(lastRAPlusSignalBar) or (bar_index - lastRAPlusSignalBar > raPlusCooldownBars)
raPlusResetOK     = (not raRequireResetForPlus) or compressionResetSinceStrongRA or raEliteCandidate

raPlusSignal  = raStrongCandidate and raPlusCooldownOK and raPlusResetOK
raEliteSignal = raEliteCandidate and raPlusCooldownOK and raPlusResetOK

if raPlusSignal
    lastRAPlusSignalBar := bar_index
    compressionResetSinceStrongRA := false
    if useTrendLock and trendLockAfterRAPlus
        trendLocked := true
        trendLockBar := bar_index

// RA plotting is handled later in the final signal-priority section.
// This prevents multiple labels from appearing on the same candle.

if showRAFilterLabels and raSignal
    debugText = "RVOL: " + str.tostring(rvol, "#.##") + " | Tight: " + str.tostring(tightBarCount) + "/" + str.tostring(tightBarsRequired)
    label.new(bar_index, low, debugText, style=label.style_label_up, textcolor=color.white, color=color.new(color.black, 20), size=size.tiny)

alertcondition(raSignal, title="Re-Acceleration", message="Re-Acceleration setup detected")
alertcondition(raPlusSignal, title="Strong Re-Acceleration RA+", message="RA+ detected: base RA with compression or strong relative volume")
alertcondition(raEliteSignal, title="Elite Re-Acceleration RA++", message="RA++ detected: base RA with compression and strong relative volume")

//──────────────────────────────────────────────────────────────────────────────
// Turnaround Setup (TS)
//──────────────────────────────────────────────────────────────────────────────
turnGrp        = "Turnaround Setup"
showTurnaround = input.bool(true,  "Show Turnaround markers", group=turnGrp)
bearLookback   = input.int(80,     "Bars since last slow downtrend (max)", minval=1, group=turnGrp)

barsSinceSlowBear = ta.barssince(slowBear)
recentBear        = not na(barsSinceSlowBear) and barsSinceSlowBear <= bearLookback
inTurnPhase = recentBear and slow_ok and not fastAboveSlow

phTS        = ta.pivothigh(high, 2, 2)
var float priorTurnHigh = na
if not na(phTS) and inTurnPhase
    priorTurnHigh := phTS

fastRisingIntoSlowTS = fast_ok and slow_ok and ma1 > ma1[1] and ma2 > ma2[1] and fastTop >= slowBot
strongDemandTS = close > open and close >= high - (high - low) * 0.25 and close > fastTop
turnCandidate = showTurnaround and inTurnPhase and fastRisingIntoSlowTS and strongDemandTS and wickOK and not na(priorTurnHigh) and close > priorTurnHigh

var bool hadTurnaroundSinceBear = false
if slowBear
    hadTurnaroundSinceBear := false

turnaroundSignal = turnCandidate and not hadTurnaroundSinceBear
if turnaroundSignal
    hadTurnaroundSinceBear := true

//──────────────────────────────────────────────────────────────────────────────
// Momentum Ignition Turnaround (TS+)
// - Designed to capture earlier high-beta trend ignition moves
// - Does NOT replace TS; it adds an earlier optional transition marker
//──────────────────────────────────────────────────────────────────────────────
tsPlusGrp = "Turnaround Setup Plus (TS+)"
showTSPlus              = input.bool(true, "Show TS+ momentum ignition markers", group=tsPlusGrp)
tsPlusRecentBearBars    = input.int(120, "TS+: bars since slow bear / base", minval=5, maxval=300, group=tsPlusGrp)
tsPlusBreakLen          = input.int(20, "TS+: breakout lookback", minval=5, maxval=100, group=tsPlusGrp)
tsPlusRangeLen          = input.int(20, "TS+: average range length", minval=5, maxval=100, group=tsPlusGrp)
tsPlusRangeMult         = input.float(1.25, "TS+: expansion range multiplier", minval=0.50, maxval=5.00, step=0.05, group=tsPlusGrp)
tsPlusClosePct          = input.float(0.75, "TS+: close position in candle", minval=0.50, maxval=0.95, step=0.05, group=tsPlusGrp)
tsPlusRequireCrossMA1   = input.bool(true, "TS+: require close crosses above MA1", group=tsPlusGrp)
tsPlusRequireFastSlope  = input.bool(true, "TS+: require fast MA slope improving", group=tsPlusGrp)
tsPlusRequireSlowBase   = input.bool(false, "TS+: require price near/above slow ribbon", group=tsPlusGrp)
tsPlusCooldownBars      = input.int(12, "TS+: cooldown bars after signal", minval=1, maxval=100, group=tsPlusGrp)

// Recent bearish or base-building environment.
barsSinceSlowBearPlus = ta.barssince(slowBear)
tsPlusRecentBear = not na(barsSinceSlowBearPlus) and barsSinceSlowBearPlus <= tsPlusRecentBearBars

// Expansion candle: strong demand, range expansion, close near high.
tsPlusBarRange = math.max(high - low, minRangeForWick)
tsPlusAvgRange = ta.sma(high - low, tsPlusRangeLen)
tsPlusRangeExpansion = not na(tsPlusAvgRange) and tsPlusBarRange > tsPlusAvgRange * tsPlusRangeMult
tsPlusCloseStrong = close >= low + tsPlusBarRange * tsPlusClosePct
tsPlusDemand = close > open and tsPlusCloseStrong

// Early reclaim / ignition logic.
tsPlusCrossMA1 = fast_ok and close > ma1 and close[1] <= ma1[1]
tsPlusAboveFast = fast_ok and close > fastTop
tsPlusFastSlopeImproving = fast_ok and ma1 > ma1[1] and ma2 >= ma2[1]

// Optional slow-ribbon proximity filter. Useful if TS+ becomes too early/noisy.
tsPlusNearSlow = slow_ok and close >= slowBot

// Breakout through recent structure, but using prior bars only.
tsPlusBreakout = high > ta.highest(high[1], tsPlusBreakLen)

// Cooldown to prevent repeated TS+ labels during the same ignition burst.
var int lastTSPlusBar = na
tsPlusCooldownOK = na(lastTSPlusBar) or (bar_index - lastTSPlusBar > tsPlusCooldownBars)

tsPlusSignal = (
    showTSPlus
    and not hadTurnaroundSinceBear
    and tsPlusCooldownOK
    and tsPlusRecentBear
    and tsPlusBreakout
    and tsPlusDemand
    and tsPlusRangeExpansion
    and wickOK
    and (not tsPlusRequireCrossMA1 or tsPlusCrossMA1 or tsPlusAboveFast)
    and (not tsPlusRequireFastSlope or tsPlusFastSlopeImproving)
    and (not tsPlusRequireSlowBase or tsPlusNearSlow)
    and not turnaroundSignal
)

if tsPlusSignal
    lastTSPlusBar := bar_index
    hadTurnaroundSinceBear := true

if useTrendLock and trendLockAfterTurn and (turnaroundSignal or tsPlusSignal)
    trendLocked := true
    trendLockBar := bar_index

//──────────────────────────────────────────────────────────────────────────────
// Dynamic Trend Stage / Trend Quality State
// - Replaces simple time-based Early/Mid/Late classification
// - Classifies the trend by behaviour: Expansion, Persistent, Mature, Exhaustion
// - This does NOT filter signals; it provides context for conviction and risk sizing
//──────────────────────────────────────────────────────────────────────────────
stageGrp = "Trend Stage"
showTrendMaturityTable = input.bool(true, "Show trend stage table", group=stageGrp)

// Time context remains useful, but no longer solely determines trend stage.
earlyTrendBars = input.int(20, "Reference: early bars after TS/TS+", minval=1, maxval=100, group=stageGrp)
midTrendBars   = input.int(60, "Reference: mid bars after TS/TS+", minval=2, maxval=300, group=stageGrp)
midTrendBarsAdj = math.max(midTrendBars, earlyTrendBars + 1)

// Trend quality settings.
stageLookback       = input.int(20, "Trend efficiency lookback", minval=5, maxval=100, group=stageGrp)
stageSlopeLen       = input.int(5, "EMA slope / acceleration length", minval=2, maxval=30, group=stageGrp)
stageAtrLen         = input.int(14, "ATR length for extension", minval=5, maxval=100, group=stageGrp)
extendedAtrLevel    = input.float(2.0, "Extended if close is ATRs above MA1", minval=0.5, maxval=8.0, step=0.25, group=stageGrp)
exhaustionAtrLevel  = input.float(3.5, "Exhaustion risk if ATRs above MA1", minval=1.0, maxval=10.0, step=0.25, group=stageGrp)
lowEfficiencyLevel  = input.float(0.30, "Low trend efficiency threshold", minval=0.05, maxval=1.00, step=0.05, group=stageGrp)
highEfficiencyLevel = input.float(0.55, "High trend efficiency threshold", minval=0.05, maxval=1.00, step=0.05, group=stageGrp)

// Maturity score settings.
maturityBarsFull      = input.int(80, "Maturity score: bars for full duration score", minval=20, maxval=300, group=stageGrp)
maturityAtrFull       = input.float(4.0, "Maturity score: ATR extension for full score", minval=1.0, maxval=10.0, step=0.25, group=stageGrp)
matureScoreThreshold  = input.float(0.70, "Mature trend score threshold", minval=0.10, maxval=1.00, step=0.05, group=stageGrp)
exhaustScoreThreshold = input.float(0.90, "Exhaustion score threshold", minval=0.10, maxval=1.00, step=0.05, group=stageGrp)

// State persistence / hysteresis. Keeps the table from changing state too quickly.
useStagePersistence   = input.bool(true, "Use stage persistence", group=stageGrp)
stageHoldBars         = input.int(3, "Minimum bars before changing stage", minval=0, maxval=20, group=stageGrp)

if turnaroundSignal or tsPlusSignal
    lastTrendTurnBar := bar_index

barsSinceTurn = not na(lastTrendTurnBar) ? bar_index - lastTrendTurnBar : na

// Directional efficiency: high = smooth trend, low = choppy / inefficient.
trendPath = 0.0
for i = 0 to stageLookback - 1
    trendPath += math.abs(close[i] - close[i + 1])
trendDistance = math.abs(close - close[stageLookback])
trendEfficiency = trendPath > 0 ? trendDistance / trendPath : 0.0

// Extension from the fast ribbon in ATR terms.
stageAtr = ta.atr(stageAtrLen)
fastExtensionATR = stageAtr > 0 and fast_ok ? (close - ma1) / stageAtr : 0.0

// Fast-ribbon slope and acceleration.
fastSlope = fast_ok ? ma1 - ma1[stageSlopeLen] : 0.0
fastSlopePrev = fast_ok ? ma1[stageSlopeLen] - ma1[stageSlopeLen * 2] : 0.0
fastAccel = fastSlope - fastSlopePrev

// Ribbon expansion / compression.
fastRibbonWidth = fast_ok ? math.abs(ma1 - ma2) : 0.0
fastRibbonWidthAvg = ta.sma(fastRibbonWidth, stageLookback)
ribbonExpanding = fastRibbonWidthAvg > 0 and fastRibbonWidth > fastRibbonWidthAvg
ribbonContracting = fastRibbonWidthAvg > 0 and fastRibbonWidth < fastRibbonWidthAvg

// Behavioural trend-state components.
strongAlignment = fastBull and slowBull and close > fastTop
freshTurn = not na(barsSinceTurn) and barsSinceTurn <= earlyTrendBars

// Maturity score blends duration, extension and efficiency.
// This prevents very old trends from being labelled "developing" indefinitely.
durationScore = not na(barsSinceTurn) ? math.min(barsSinceTurn / maturityBarsFull, 1.0) : 0.0
extensionScore = math.min(math.max(fastExtensionATR, 0.0) / maturityAtrFull, 1.0)
efficiencyScore = math.min(trendEfficiency / math.max(highEfficiencyLevel, 0.01), 1.0)
trendMaturityScore = durationScore * 0.40 + extensionScore * 0.40 + efficiencyScore * 0.20

maturityScoreMature = trendMaturityScore >= matureScoreThreshold
maturityScoreExhaust = trendMaturityScore >= exhaustScoreThreshold

persistentTrend = strongAlignment and trendEfficiency >= highEfficiencyLevel and fastExtensionATR < extendedAtrLevel and not maturityScoreMature
extendedTrend = strongAlignment and (fastExtensionATR >= extendedAtrLevel or maturityScoreMature)
exhaustionRisk = (fastExtensionATR >= exhaustionAtrLevel) or (maturityScoreExhaust and fastExtensionATR >= extendedAtrLevel) or (trendEfficiency <= lowEfficiencyLevel and extendedTrend) or (fastSlope > 0 and fastAccel < 0 and extendedTrend and fastExtensionATR >= extendedAtrLevel)

// Structural trend layer.
// This separates a long-term institutional trend from a short-term developing trend.
structuralTrendBars = input.int(120, "Structural Trend: minimum bars", minval=20, maxval=500, group=stageGrp)
structuralTrend = strongAlignment and not na(barsSinceTurn) and barsSinceTurn >= structuralTrendBars and close > slowTop and trendMaturityScore >= 0.50

// Tactical trend layer.
// This captures the shorter-term condition within the larger structure.
tacticalExpansion = freshTurn and fastAccel > 0 and ribbonExpanding
tacticalPersistent = strongAlignment and trendEfficiency >= highEfficiencyLevel and fastExtensionATR < extendedAtrLevel
tacticalExtended = strongAlignment and fastExtensionATR >= extendedAtrLevel

// Dynamic trend stage candidate.
trendStageCandidate =
     na(barsSinceTurn) ? "No active turn" :
     exhaustionRisk ? "Exhaustion Risk" :
     tacticalExpansion ? "Expansion" :
     extendedTrend ? "Mature Trend" :
     structuralTrend ? "Structural Trend" :
     persistentTrend or tacticalPersistent ? "Persistent Trend" :
     strongAlignment ? "Developing Trend" :
     "Transition"

// Stage persistence / hysteresis.
// The state must remain different for a few bars before the table changes.
var string persistedTrendStage = na
var int stageCandidateStartBar = na

if na(persistedTrendStage)
    persistedTrendStage := trendStageCandidate
    stageCandidateStartBar := bar_index
else if trendStageCandidate != persistedTrendStage
    if na(stageCandidateStartBar) or trendStageCandidate != trendStageCandidate[1]
        stageCandidateStartBar := bar_index
    if not useStagePersistence or (bar_index - stageCandidateStartBar >= stageHoldBars)
        persistedTrendStage := trendStageCandidate
        stageCandidateStartBar := bar_index
else
    stageCandidateStartBar := bar_index

trendStageText = persistedTrendStage

trendStageColour =
     na(barsSinceTurn) ? color.new(color.gray, 65) :
     trendStageText == "Expansion" ? color.new(color.lime, 60) :
     trendStageText == "Persistent Trend" ? color.new(color.blue, 65) :
     trendStageText == "Developing Trend" ? color.new(color.teal, 65) :
     trendStageText == "Mature Trend" ? color.new(color.orange, 65) :
     trendStageText == "Exhaustion Risk" ? color.new(color.red, 65) :
     color.new(color.gray, 65)

//──────────────────────────────────────────────────────────────────────────────
// Opportunity State
// - Separates trend condition from entry quality
// - This is intended to answer: "Is this a good place to buy, add, hold, or avoid chasing?"
//──────────────────────────────────────────────────────────────────────────────
oppGrp = "Opportunity State"
showOpportunityInTable = input.bool(true, "Show opportunity state in table", group=oppGrp)
optimalPullbackAtrMax  = input.float(1.25, "Optimal pullback: max ATR extension", minval=-5.0, maxval=5.0, step=0.25, group=oppGrp)
chaseRiskAtrLevel      = input.float(2.50, "Chase risk: ATR extension", minval=0.5, maxval=10.0, step=0.25, group=oppGrp)
compressionEffMax      = input.float(0.35, "Compression setup: max efficiency", minval=0.05, maxval=1.00, step=0.05, group=oppGrp)
nearFastRibbonATR      = input.float(0.75, "Near fast ribbon threshold ATR", minval=0.1, maxval=5.0, step=0.25, group=oppGrp)

nearFastRibbon = math.abs(fastExtensionATR) <= nearFastRibbonATR
belowOrAtFast = fast_ok and close <= fastTop and close >= fastBot
pullbackIntoFast = fast_ok and low <= fastTop and close >= fastBot
// Compression setup should occur before a new expansion, not after price is already stretched.
compressionSetup = strongAlignment and trendEfficiency <= compressionEffMax and nearFastRibbon and fastExtensionATR < optimalPullbackAtrMax
// Use raw signal candidates here because final priority labels are defined later.
reAccelerationNow = raEliteSignal or raPlusSignal or raSignal
continuationNow = continuationSignal
turnNow = tsPlusSignal or turnaroundSignal
extendedChaseRisk = strongAlignment and fastExtensionATR >= chaseRiskAtrLevel
optimalPullback = strongAlignment and pullbackIntoFast and fastExtensionATR <= optimalPullbackAtrMax and not exhaustionRisk
avoidOrReduce = exhaustionRisk or (trendStageText == "Mature Trend" and extendedChaseRisk)

// Portfolio-oriented opportunity layer.
// This separates "trend is intact" from "this is a good fresh entry".
coreTrendHold = (trendStageText == "Structural Trend" or trendStageText == "Persistent Trend") and not extendedChaseRisk and not exhaustionRisk
addOnPullback = coreTrendHold and optimalPullback

opportunityText =
     avoidOrReduce ? "Avoid / Reduce" :
     turnNow ? "Early Entry" :
     reAccelerationNow and not extendedChaseRisk ? "Re-Acceleration" :
     addOnPullback ? "Add on Pullback" :
     continuationNow and optimalPullback ? "Optimal Pullback" :
     compressionSetup ? "Compression Setup" :
     optimalPullback ? "Optimal Pullback" :
     extendedChaseRisk ? "Chase Risk" :
     coreTrendHold ? "Core Trend Hold" :
     strongAlignment ? "Hold / Wait" :
     trendStageText == "Transition" ? "Watchlist" :
     not strongAlignment and fast_ok and slow_ok ? "Neutral" :
     "No Edge"

opportunityColour =
     opportunityText == "Early Entry" ? color.new(color.navy, 55) :
     opportunityText == "Re-Acceleration" ? color.new(color.blue, 55) :
     opportunityText == "Optimal Pullback" ? color.new(color.lime, 55) :
     opportunityText == "Add on Pullback" ? color.new(color.lime, 45) :
     opportunityText == "Compression Setup" ? color.new(color.teal, 55) :
     opportunityText == "Core Trend Hold" ? color.new(color.blue, 65) :
     opportunityText == "Hold / Wait" ? color.new(color.gray, 60) :
     opportunityText == "Watchlist" ? color.new(color.orange, 65) :
     opportunityText == "Neutral" ? color.new(color.gray, 65) :
     opportunityText == "Chase Risk" ? color.new(color.orange, 50) :
     opportunityText == "Avoid / Reduce" ? color.new(color.red, 55) :
     color.new(color.gray, 70)

//──────────────────────────────────────────────────────────────────────────────
// Risk State
// - Separate from opportunity: a stock can remain a core hold while no longer being a good fresh entry
// - Used for position sizing / trimming discipline rather than signal generation
//──────────────────────────────────────────────────────────────────────────────
riskGrp = "Risk State"
showRiskInTable = input.bool(true, "Show risk state in table", group=riskGrp)
highRiskAtrLevel = input.float(3.00, "High risk: ATR extension", minval=1.0, maxval=10.0, step=0.25, group=riskGrp)
elevatedRiskAtrLevel = input.float(2.00, "Elevated risk: ATR extension", minval=0.5, maxval=8.0, step=0.25, group=riskGrp)
lowRiskAtrLevel = input.float(1.00, "Low risk: max ATR extension", minval=0.1, maxval=5.0, step=0.25, group=riskGrp)

riskHigh = exhaustionRisk or fastExtensionATR >= highRiskAtrLevel or opportunityText == "Avoid / Reduce"
riskElevated = not riskHigh and (extendedChaseRisk or fastExtensionATR >= elevatedRiskAtrLevel or trendStageText == "Mature Trend")
riskLow = not riskHigh and not riskElevated and strongAlignment and fastExtensionATR <= lowRiskAtrLevel and trendEfficiency >= lowEfficiencyLevel

riskText =
     riskHigh ? "High Risk / Trim Discipline" :
     riskElevated ? "Elevated Risk / Size Carefully" :
     riskLow ? "Lower Risk / Manageable Entry" :
     strongAlignment ? "Normal Trend Risk" :
     "Unclear / No Position Edge"

riskColour =
     riskHigh ? color.new(color.red, 55) :
     riskElevated ? color.new(color.orange, 55) :
     riskLow ? color.new(color.lime, 60) :
     strongAlignment ? color.new(color.gray, 60) :
     color.new(color.gray, 70)

//──────────────────────────────────────────────────────────────────────────────
// Ideal Combination Alert
// - Designed to identify the preferred MARS entry environment:
//   Green cloud alignment + controlled extension + strong efficiency + moderate MAT
//   + acceptable opportunity/risk state.
// - This does NOT replace RA/RA+/RA++/CS. It is a higher-level confluence alert.
//──────────────────────────────────────────────────────────────────────────────
idealGrp = "Ideal Combination Alert"
showIdealMarker          = input.bool(true, "Show Ideal Combination marker", group=idealGrp)
idealRequireFreshSignal  = input.bool(false, "Require fresh RA/CS signal", group=idealGrp)
idealMinMat              = input.float(0.30, "Ideal MAT: minimum", minval=0.00, maxval=1.00, step=0.05, group=idealGrp)
idealMaxMat              = input.float(0.75, "Ideal MAT: maximum", minval=0.00, maxval=1.00, step=0.05, group=idealGrp)
idealMinEff              = input.float(0.55, "Ideal EFF: minimum", minval=0.00, maxval=1.00, step=0.05, group=idealGrp)
idealMaxExtATR           = input.float(1.25, "Ideal Ext: max ATR above MA1", minval=-5.00, maxval=10.00, step=0.25, group=idealGrp)
idealAllowNormalRisk     = input.bool(true, "Allow Normal Trend Risk", group=idealGrp)
idealAllowCoreHold       = input.bool(false, "Allow Core Trend Hold opportunity", group=idealGrp)

// Trend alignment: preferred MARS environment is green/green with fast cloud above slow cloud.
idealCloudAlignment = fastBull and slowBull and fastAboveSlow and close > fastTop

// MAT: avoid very early/noisy turns and avoid late mature extension.
idealMat = trendMaturityScore >= idealMinMat and trendMaturityScore <= idealMaxMat

// EFF: require clean directional movement rather than choppy price action.
idealEff = trendEfficiency >= idealMinEff

// EXT/ATR: avoid chasing when price is too far above the fast ribbon.
idealExtension = fastExtensionATR <= idealMaxExtATR

// Opportunity: preferred entries are compression, pullback or re-acceleration states.
idealOpportunity = (
     opportunityText == "Compression Setup"
     or opportunityText == "Optimal Pullback"
     or opportunityText == "Add on Pullback"
     or opportunityText == "Re-Acceleration"
     or (idealAllowCoreHold and opportunityText == "Core Trend Hold")
)

// Risk: prefer lower risk, optionally allow normal trend risk.
idealRisk = riskLow or (idealAllowNormalRisk and riskText == "Normal Trend Risk")

// Optional fresh signal requirement. If enabled, the ideal alert only fires on RA/RA+/RA++/CS bars.
idealFreshSignalRaw = raEliteSignal or raPlusSignal or raSignal or continuationSignal

idealCombinationState = (
     idealCloudAlignment
     and idealMat
     and idealEff
     and idealExtension
     and idealOpportunity
     and idealRisk
     and not exhaustionRisk
     and not extendedChaseRisk
)

idealCombinationSignal = idealCombinationState and (not idealRequireFreshSignal or idealFreshSignalRaw)

// Alert trigger: if fresh-signal mode is off, trigger only when the ideal state first appears.
// If fresh-signal mode is on, trigger on the qualifying signal candle.
idealCombinationAlert = idealRequireFreshSignal ? idealCombinationSignal : (idealCombinationSignal and not idealCombinationSignal[1])

//──────────────────────────────────────────────────────────────────────────────
// Portfolio Action Framework V3.2
// - Converts MARS from a signal-only framework into a portfolio management tool.
// - Separates momentum event from portfolio action.
// - Splits extension-based profit protection from true deterioration-based TRIM.
// - Adds persistence and cooldown so portfolio warnings are less noisy.
// - Adds NO EDGE / NEUTRAL so REVIEW is reserved for material decision points.
// - Adds adaptive extension thresholds so strong efficient trends are given more room.
// - Uses raw signal variables here because final mutually-exclusive labels are declared later.
//──────────────────────────────────────────────────────────────────────────────
portGrp = "Portfolio Action Framework"

showPortfolioTableRow = input.bool(true, "Show portfolio action in table", group=portGrp)
showPortfolioMarkers  = input.bool(true, "Show portfolio action markers", group=portGrp)

// Build/Add settings.
buildMinMat      = input.float(0.30, "Build: minimum MAT", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
buildMaxMat      = input.float(0.70, "Build: maximum MAT", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
buildMinEff      = input.float(0.45, "Build: minimum EFF", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
buildMaxExtATR   = input.float(1.50, "Build: maximum ATR extension", minval=-5.00, maxval=10.00, step=0.25, group=portGrp)

// Adaptive extension settings.
// Stronger and cleaner trends are allowed more ATR extension before warnings escalate.
useAdaptiveExtension = input.bool(true, "Use adaptive extension thresholds", group=portGrp)
adaptiveHighEff      = input.float(0.45, "Adaptive: high efficiency threshold", minval=0.05, maxval=1.00, step=0.05, group=portGrp)
adaptiveMidEff       = input.float(0.30, "Adaptive: mid efficiency threshold", minval=0.05, maxval=1.00, step=0.05, group=portGrp)
adaptiveHighExtATR   = input.float(3.00, "Adaptive: extension allowed in high EFF trends", minval=1.00, maxval=8.00, step=0.25, group=portGrp)
adaptiveMidExtATR    = input.float(2.20, "Adaptive: extension allowed in mid EFF trends", minval=1.00, maxval=8.00, step=0.25, group=portGrp)
adaptiveLowExtATR    = input.float(1.60, "Adaptive: extension allowed in low EFF trends", minval=0.50, maxval=8.00, step=0.25, group=portGrp)

adaptiveExtensionLimit =
     not useAdaptiveExtension ? extendedAtrLevel :
     trendEfficiency > adaptiveHighEff ? adaptiveHighExtATR :
     trendEfficiency > adaptiveMidEff ? adaptiveMidExtATR :
     adaptiveLowExtATR

// Extension / profit protection settings.
extendedMatLevel    = input.float(0.70, "Extended: MAT above", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
extendedExtATRLevel = input.float(1.75, "Extended: ATR extension above", minval=0.00, maxval=10.00, step=0.25, group=portGrp)
extendedPersistBars = input.int(6, "Extended: regime persistence bars", minval=1, maxval=30, group=portGrp)

// Small parcel / caution settings.
smallMatLevel    = input.float(0.70, "Small only: MAT above", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
smallExtATRLevel = input.float(1.75, "Small only: ATR extension above", minval=0.00, maxval=10.00, step=0.25, group=portGrp)

// True trim settings. These are deliberately stricter than extension settings.
trimMatLevel     = input.float(0.82, "Trim: MAT above", minval=0.00, maxval=1.00, step=0.05, group=portGrp)
trimExtATRLevel  = input.float(2.75, "Trim: ATR extension above", minval=0.00, maxval=10.00, step=0.25, group=portGrp)

// Governance settings.
reviewConfirmBars = input.int(2, "Review: confirmation bars", minval=1, maxval=10, group=portGrp)
trimConfirmBars   = input.int(2, "Trim: confirmation bars", minval=1, maxval=10, group=portGrp)
portfolioCooldown = input.int(8, "Portfolio marker cooldown bars", minval=1, maxval=50, group=portGrp)

portfolioFreshMomentum = raEliteSignal or raPlusSignal or raSignal or continuationSignal

// Strong trends should be given room to breathe. This suppresses premature warnings
// when the trend is still structurally healthy and price remains above the fast ribbon.
trendStillHealthy = strongAlignment and close > fastTop and not fastBear and trendEfficiency >= lowEfficiencyLevel

// BUILD / ADD
// Best risk-adjusted deployment zone.
portfolioBuild = (
     idealCombinationSignal
     or (
         strongAlignment
         and portfolioFreshMomentum
         and trendMaturityScore >= buildMinMat
         and trendMaturityScore <= buildMaxMat
         and trendEfficiency >= buildMinEff
         and fastExtensionATR <= buildMaxExtATR
         and not riskHigh
         and not extendedChaseRisk
         and opportunityText != "Avoid / Reduce"
         and opportunityText != "Chase Risk"
     )
)

// Trend health / deterioration definitions must sit before EXTENDED/TRIM logic because
// they are used by multiple portfolio action blocks.
// The key distinction is now:
// - trend strength = trend is powerful / extended / mature
// - trend health   = trend remains orderly and structurally intact
// We do not want to punish strength unless health is also deteriorating.
trendStructurallyIntact =
     close > fastBot
     and not fastBear
     and (not slow_ok or close > slowBot)

// Trend orderly is intentionally broader than before.
// A strong institutional trend can be rotational or wickier without being structurally broken.
trendOrderly =
     trendEfficiency >= lowEfficiencyLevel

// Trend very clean is reserved for higher-quality fresh entries and aggressive adds.
// Use the existing efficiency threshold so this block does not depend on an undeclared input.
trendVeryClean =
     trendEfficiency >= highEfficiencyLevel
     and upperWickPct <= maxUpperWickPct

strongButHealthy =
     strongAlignment
     and trendStructurallyIntact
     and trendOrderly

// Rotational continuation allows CS / hold behaviour to persist in leaders that are still intact
// but no longer perfectly clean. This prevents good trends from becoming too quiet too early.
rotationalContinuationHealthy =
     strongAlignment
     and not fastBear
     // Use fastBot rather than fastTop so rotational leaders are not incorrectly suppressed.
     // CS/RA should remain trend-participation signals; portfolio actions should sit above them, not kill them.
     and close > fastBot
     and (not slow_ok or close > slowTop)
     and trendEfficiency >= lowEfficiencyLevel

structuralDeterioration =
     fastBear
     or close < fastBot
     or (slow_ok and close < slowTop)
     or (trendEfficiency <= lowEfficiencyLevel and close < fastTop)

// Exhaustion confirmation requires extension plus evidence of rejection or instability.
// This avoids treating a powerful, healthy trend as a sell signal simply because it is strong.
lateStageExtensionConfirmed =
     trendMaturityScore >= extendedMatLevel
     and fastExtensionATR >= adaptiveExtensionLimit

rejectionEvidence =
     upperWickPct > maxUpperWickPct
     or close < open
     or close < fastTop

exhaustionReversal =
     lateStageExtensionConfirmed
     and trendStageText == "Exhaustion Risk"
     and rejectionEvidence

// EXTENDED / REDUCE AGGRESSION
// This is not bearish. It means the trend is strong but less attractive for fresh money.
// EXT now requires late-stage behaviour, not merely early acceleration.
lateStageExtension =
     fastExtensionATR >= adaptiveExtensionLimit
     and trendMaturityScore >= extendedMatLevel

portfolioExtendedRaw = (
     strongButHealthy
     and not portfolioBuild
     and not structuralDeterioration
     and (
         lateStageExtension
         or extendedChaseRisk
         or riskHigh
         or opportunityText == "Avoid / Reduce"
         or (trendMaturityScore >= extendedMatLevel and fastExtensionATR >= extendedExtATRLevel)
     )
)

// EXTENDED HOLD is for mature leaders that remain structurally intact.
// This prevents high-quality trends from being downgraded to REVIEW too quickly.
portfolioExtendedHold = (
     strongButHealthy
     and not portfolioBuild
     and not portfolioExtendedRaw
     and trendMaturityScore >= extendedMatLevel
     and (
         opportunityText == "Core Trend Hold"
         or opportunityText == "Hold / Wait"
         or riskText == "Normal Trend Risk"
         or riskLow
     )
)

// Make EXT behave like a regime, not a one-bar event.
extendedRecently = nz(ta.barssince(portfolioExtendedRaw), 10000) <= extendedPersistBars
portfolioExtended = portfolioExtendedRaw or (extendedRecently and strongButHealthy and trendMaturityScore > 0.65 and not portfolioBuild)

// SMALL PARCEL ONLY
// Momentum exists, but risk/reward is no longer ideal.
portfolioSmall = (
     strongAlignment
     and portfolioFreshMomentum
     and not portfolioBuild
     and not portfolioExtended
     and not riskHigh
     and (
         riskElevated
         or opportunityText == "Chase Risk"
         or trendMaturityScore > smallMatLevel
         or fastExtensionATR > smallExtATRLevel
     )
)

// TRUE TRIM / AVOID NEW MONEY
// Requires extension plus genuine structural deterioration or confirmed exhaustion.
// Avoid / Reduce by itself is no longer enough while the trend remains healthy.
// Strong extended trends should remain EXTENDED or EXTENDED HOLD until structure actually degrades.
trimRaw = (
     (
         opportunityText == "Avoid / Reduce"
         and structuralDeterioration
     )
     or (
         lateStageExtensionConfirmed
         and structuralDeterioration
     )
     or exhaustionReversal
     or (riskHigh and structuralDeterioration)
)

// WATCHLIST / DAMAGED BUT REPAIRABLE
// This captures charts where trend quality is damaged, but not enough to be a formal REVIEW/TRIM.
portfolioWatchlist = (
     not portfolioBuild
     and not portfolioExtended
     and not portfolioExtendedHold
     and not trimRaw
     and not strongButHealthy
     and not rotationalContinuationHealthy
     and not fastBear
     and (
         trendStageText == "Transition"
         or opportunityText == "Watchlist"
         or opportunityText == "Hold / Wait"
     )
)

// REVIEW
// A review should be a genuine decision point, not normal trend breathing.
// We now require deterioration to persist, so temporary compression/pullbacks do not create excessive REVIEW labels.
trendHealthyForReview = strongAlignment and close > fastBot and not fastBear
barsSinceHealthyReview = ta.barssince(trendHealthyForReview)
reviewDeteriorationPersisted = not na(barsSinceHealthyReview) and barsSinceHealthyReview >= reviewConfirmBars

reviewRaw = (
     (
         trendStageText == "Exhaustion Risk"
         or (fastBear and close < fastTop)
         or (slow_ok and close < slowTop and close < ma3)
         or (not strongAlignment and trendStageText == "Transition" and close < fastBot and trendEfficiency <= lowEfficiencyLevel)
     )
     and reviewDeteriorationPersisted
)

// Persistence filters.
trimConfirmed = trimRaw and nz(ta.barssince(not trimRaw), 10000) >= trimConfirmBars - 1
reviewConfirmed = reviewRaw and nz(ta.barssince(not reviewRaw), 10000) >= reviewConfirmBars - 1

portfolioTrim = trimConfirmed
portfolioReview = reviewConfirmed and not portfolioTrim and not portfolioExtendedHold

// CORE HOLD
// Trend remains intact, but there is no attractive fresh entry edge.
portfolioHold = (
     (strongAlignment or rotationalContinuationHealthy)
     and not portfolioBuild
     and not portfolioSmall
     and not portfolioExtended
     and not portfolioExtendedHold
     and not portfolioTrim
     and not portfolioReview
     and (
         opportunityText == "Core Trend Hold"
         or opportunityText == "Hold / Wait"
         or riskText == "Normal Trend Risk"
         or riskLow
     )
)

// NO EDGE / NEUTRAL
// This prevents neutral or unclear charts from being over-classified as REVIEW.
portfolioNeutral = (
     not strongAlignment
     and not portfolioReview
     and not portfolioTrim
     and (
         opportunityText == "Neutral"
         or opportunityText == "No Edge"
         or (trendStageText == "Transition" and trendEfficiency < lowEfficiencyLevel)
         or na(barsSinceTurn)
     )
)

portfolioActionText =
     portfolioReview ? "REVIEW" :
     portfolioTrim ? "TRIM / AVOID NEW MONEY" :
     portfolioBuild ? "BUILD / ADD" :
     portfolioSmall ? "SMALL PARCEL ONLY" :
     portfolioExtended ? "EXTENDED / REDUCE AGGRESSION" :
     portfolioExtendedHold ? "EXTENDED HOLD" :
     portfolioHold ? "CORE HOLD" :
     portfolioWatchlist ? "WATCHLIST / REPAIR" :
     portfolioNeutral ? "NO EDGE / NEUTRAL" :
     "NO ACTION"

portfolioActionColour =
     portfolioActionText == "BUILD / ADD" ? color.new(color.green, 45) :
     portfolioActionText == "CORE HOLD" ? color.new(color.blue, 60) :
     portfolioActionText == "EXTENDED HOLD" ? color.new(color.blue, 70) :
     portfolioActionText == "SMALL PARCEL ONLY" ? color.new(color.orange, 45) :
     portfolioActionText == "EXTENDED / REDUCE AGGRESSION" ? color.new(color.orange, 65) :
     portfolioActionText == "TRIM / AVOID NEW MONEY" ? color.new(color.red, 45) :
     portfolioActionText == "REVIEW" ? color.new(color.gray, 45) :
     portfolioActionText == "WATCHLIST / REPAIR" ? color.new(color.gray, 60) :
     portfolioActionText == "NO EDGE / NEUTRAL" ? color.new(color.gray, 75) :
     color.new(color.gray, 75)

// Cooldown-governed state change alerts and markers.
var int lastPortfolioMarkerBar = na
portfolioCooldownOK = na(lastPortfolioMarkerBar) or (bar_index - lastPortfolioMarkerBar > portfolioCooldown)

portfolioBuildAlert    = portfolioBuild and not portfolioBuild[1] and portfolioCooldownOK
portfolioHoldAlert     = portfolioHold and not portfolioHold[1] and portfolioCooldownOK
portfolioSmallAlert    = portfolioSmall and not portfolioSmall[1] and portfolioCooldownOK
portfolioExtendedAlert = portfolioExtended and not portfolioExtended[1] and portfolioCooldownOK
portfolioTrimAlert     = portfolioTrim and not portfolioTrim[1] and portfolioCooldownOK
portfolioReviewAlert   = portfolioReview and not portfolioReview[1] and portfolioCooldownOK
portfolioNeutralAlert  = portfolioNeutral and not portfolioNeutral[1] and portfolioCooldownOK
portfolioExtendedHoldAlert = portfolioExtendedHold and not portfolioExtendedHold[1] and portfolioCooldownOK
portfolioWatchlistAlert = portfolioWatchlist and not portfolioWatchlist[1] and portfolioCooldownOK

if portfolioBuildAlert or portfolioHoldAlert or portfolioSmallAlert or portfolioExtendedAlert or portfolioExtendedHoldAlert or portfolioTrimAlert or portfolioReviewAlert or portfolioNeutralAlert or portfolioWatchlistAlert
    lastPortfolioMarkerBar := bar_index

var table maturityTable = table.new(position.top_right, 1, 4)
if barstate.islast and showTrendMaturityTable
    stageText = trendStageText + " | Bars: " + (na(barsSinceTurn) ? "n/a" : str.tostring(barsSinceTurn)) + " | Mat: " + str.tostring(trendMaturityScore, "#.##") + " | Eff: " + str.tostring(trendEfficiency, "#.##") + " | Ext: " + str.tostring(fastExtensionATR, "#.##") + " ATR"
    table.cell(maturityTable, 0, 0, stageText, text_color=color.white, bgcolor=trendStageColour)
    if showOpportunityInTable
        table.cell(maturityTable, 0, 1, "Opportunity: " + opportunityText, text_color=color.white, bgcolor=opportunityColour)
    if showRiskInTable
        table.cell(maturityTable, 0, 2, "Risk: " + riskText, text_color=color.white, bgcolor=riskColour)
    if showPortfolioTableRow
        table.cell(maturityTable, 0, 3, "Portfolio: " + portfolioActionText, text_color=color.white, bgcolor=portfolioActionColour)

//──────────────────────────────────────────────────────────────────────────────
// Final mutually-exclusive signals, plotting, alerts
//──────────────────────────────────────────────────────────────────────────────
// Strict priority hierarchy:
// 1. TS+
// 2. TS
// 3. RA++
// 4. RA+
// 5. RA
// 6. CS
// This prevents multiple labels appearing on the same candle.

// Portfolio risk override:
// Entry-style labels remain visible during SMALL and EXTENDED states because those
// states still provide useful trend-continuation information.
// Only true defensive states suppress entry labels.
// This prevents genuinely contradictory combinations such as CS + TRIM or RA + REVIEW,
// while still allowing CS/RA to appear in strong-but-extended trends.
portfolioEntryBlocked = portfolioTrim or portfolioReview

finalTSPlus = tsPlusSignal and not portfolioEntryBlocked

finalTurnaround = (
    turnaroundSignal
    and not finalTSPlus
    and not portfolioTrim
    and not portfolioReview
)

// RA/CS are participation signals, not portfolio-allocation instructions.
// Do not suppress them merely because the trend is mature or extended.
// Portfolio table/EXT/TRIM logic handles sizing discipline separately.
raEntryQualityOK =
     not structuralDeterioration
     and not riskHigh
     and not portfolioEntryBlocked

finalRAElite = (
    raEliteSignal
    and raEntryQualityOK
    and not portfolioEntryBlocked
    and not finalTSPlus
    and not finalTurnaround
)

finalRAPlus = (
    raPlusSignal
    and raEntryQualityOK
    and not portfolioEntryBlocked
    and not finalTSPlus
    and not finalTurnaround
    and not finalRAElite
)

finalRAStandard = (
    raSignal
    and raEntryQualityOK
    and not portfolioEntryBlocked
    and not finalTSPlus
    and not finalTurnaround
    and not finalRAElite
    and not finalRAPlus
)

finalContinuation = (
    continuationSignal
    and not portfolioEntryBlocked
    and not finalTSPlus
    and not finalTurnaround
    and not finalRAElite
    and not finalRAPlus
    and not finalRAStandard
)

plotshape(finalTSPlus, title="Momentum Ignition Turnaround TS+", text="TS+",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.navy, 0), textcolor=color.white, size=size.tiny)

plotshape(finalTurnaround, title="Turnaround Setup", text="TS",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.teal, 0), textcolor=color.white, size=size.tiny)

plotshape(finalRAElite and raAboveSlow, title="RA++ Elite Re-Acceleration", text="RA++",
          style=shape.labelup, location=location.belowbar,
          color=raColorElite, textcolor=color.white, size=size.tiny)

plotshape(finalRAPlus and raAboveSlow, title="RA+ Strong Re-Acceleration", text="RA+",
          style=shape.labelup, location=location.belowbar,
          color=raColorPlus, textcolor=color.white, size=size.tiny)

plotshape(finalRAStandard and raAboveSlow, title="RA Standard Re-Acceleration", text="RA",
          style=shape.labelup, location=location.belowbar,
          color=raColorStandard, textcolor=color.black, size=size.tiny)

plotshape(finalRAElite and not raAboveSlow, title="RA++ Transitional Re-Acceleration", text="RA++",
          style=shape.labelup, location=location.belowbar,
          color=raColorTran, textcolor=color.black, size=size.tiny)

plotshape(finalRAPlus and not raAboveSlow, title="RA+ Transitional Re-Acceleration", text="RA+",
          style=shape.labelup, location=location.belowbar,
          color=raColorTran, textcolor=color.black, size=size.tiny)

plotshape(finalRAStandard and not raAboveSlow, title="RA Transitional Re-Acceleration", text="RA",
          style=shape.labelup, location=location.belowbar,
          color=raColorTran, textcolor=color.black, size=size.tiny)

plotshape(finalContinuation, title="Continuation Setup", text="CS",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)

plotshape(showIdealMarker and idealCombinationAlert, title="MARS Ideal Combination", text="IDEAL",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)

plotshape(showPortfolioMarkers and portfolioBuildAlert, title="MARS Portfolio Build", text="BUILD",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)

plotshape(showPortfolioMarkers and portfolioSmallAlert, title="MARS Small Parcel Only", text="SMALL",
          style=shape.labelup, location=location.belowbar,
          color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)

plotshape(showPortfolioMarkers and portfolioExtendedAlert, title="MARS Extended / Reduce Aggression", text="EXT",
          style=shape.labeldown, location=location.abovebar,
          color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny)

plotshape(showPortfolioMarkers and portfolioTrimAlert, title="MARS Trim Discipline", text="TRIM",
          style=shape.labeldown, location=location.abovebar,
          color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

plotshape(showPortfolioMarkers and portfolioReviewAlert, title="MARS Review Position", text="REVIEW",
          style=shape.labeldown, location=location.abovebar,
          color=color.new(color.gray, 0), textcolor=color.white, size=size.tiny)

barcolor(finalTSPlus       ? color.new(color.navy, 70) :
         finalTurnaround   ? color.new(color.teal, 70) :
         finalContinuation ? color.new(color.lime, 70) : na)

alertcondition(finalContinuation, title="Continuation Setup", message="Continuation setup detected")
alertcondition(finalTurnaround,   title="Turnaround Setup",   message="Turnaround setup detected")
alertcondition(finalTSPlus,       title="Momentum Ignition Turnaround TS+", message="TS+ momentum ignition setup detected")
alertcondition(finalRAStandard,   title="Re-Acceleration", message="Re-Acceleration setup detected")
alertcondition(finalRAPlus,       title="Strong Re-Acceleration RA+", message="RA+ detected: base RA with compression or strong relative volume")
alertcondition(finalRAElite,      title="Elite Re-Acceleration RA++", message="RA++ detected: base RA with compression and strong relative volume")
alertcondition(idealCombinationAlert, title="MARS Ideal Combination", message="MARS Ideal Combination detected: green cloud alignment, moderate MAT, high EFF, controlled ATR extension, favourable opportunity and acceptable risk state.")
alertcondition(portfolioBuildAlert,  title="MARS Portfolio Build / Add", message="MARS Portfolio Action: BUILD / ADD. Trend alignment, acceptable maturity, sufficient efficiency and controlled extension.")
alertcondition(portfolioHoldAlert,   title="MARS Portfolio Core Hold", message="MARS Portfolio Action: CORE HOLD. Trend remains intact but fresh entry edge is not ideal.")
alertcondition(portfolioSmallAlert,  title="MARS Portfolio Small Parcel Only", message="MARS Portfolio Action: SMALL PARCEL ONLY. Momentum is present but maturity, extension or risk is elevated.")
alertcondition(portfolioExtendedAlert, title="MARS Portfolio Extended / Reduce Aggression", message="MARS Portfolio Action: EXTENDED / REDUCE AGGRESSION. Trend remains intact but fresh capital deployment should be reduced.")
alertcondition(portfolioTrimAlert,   title="MARS Portfolio Trim / Avoid New Money", message="MARS Portfolio Action: TRIM / AVOID NEW MONEY. Extension plus deterioration or poor opportunity has been confirmed.")
alertcondition(portfolioReviewAlert, title="MARS Portfolio Review Position", message="MARS Portfolio Action: REVIEW. Trend structure has weakened or exhaustion risk is present.")
alertcondition(portfolioNeutralAlert, title="MARS Portfolio No Edge / Neutral", message="MARS Portfolio Action: NO EDGE / NEUTRAL. No actionable portfolio edge is present.")
alertcondition(portfolioExtendedHoldAlert, title="MARS Portfolio Extended Hold", message="MARS Portfolio Action: EXTENDED HOLD. Mature leader remains structurally healthy; hold but avoid aggressive new buying.")
alertcondition(portfolioWatchlistAlert, title="MARS Portfolio Watchlist / Repair", message="MARS Portfolio Action: WATCHLIST / REPAIR. Trend is damaged but not yet a formal review or trim state.")

// ============================================================================
// MARS 4.0 - WATCHLIST / SCANNER OUTPUTS
// TradingView has a hard 64-plot limit. The main script already uses many
// plot/plotshape/plotchar/bgcolor-style outputs, so MARS4.0 keeps scanner
// outputs deliberately lean.
//
// Use ONE compact watchlist score plus ONE compact scan state instead of
// exposing every sub-score as a separate hidden plot.
// ============================================================================

// --- Regime score
// 0 = No active turn / neutral
// 1 = Review / deteriorating
// 2 = Transition / watchlist / repair
// 3 = Developing / hold-wait trend
// 4 = Structural / core trend
mars40RegimeScore =
     reviewRaw ? 1 :
     trendStillHealthy and trendMaturityScore >= 0.70 and trendEfficiency >= 0.20 ? 4 :
     trendStillHealthy and trendMaturityScore >= 0.45 and trendEfficiency >= 0.15 ? 3 :
     trendStillHealthy ? 2 : 0

// --- Extension score
mars40ExtensionScore = math.min(math.max(fastExtensionATR, -2.0), 5.0)

// --- Maturity / efficiency scores
mars40MaturityScore   = math.min(math.max(trendMaturityScore, 0.0), 1.0)
mars40EfficiencyScore = math.min(math.max(trendEfficiency, 0.0), 1.0)

// --- Opportunity score
// 5 = core trend hold
// 4 = developing / hold-wait
// 3 = transition / watchlist
// 2 = neutral / review
// 1 = avoid / reduce / chase risk
mars40OpportunityScore =
     reviewRaw ? 2 :
     mars40RegimeScore >= 4 and mars40ExtensionScore < 1.75 ? 5 :
     mars40RegimeScore >= 3 and mars40ExtensionScore < 2.25 ? 4 :
     mars40RegimeScore >= 2 ? 3 :
     mars40ExtensionScore >= 2.50 ? 1 : 2

// --- Risk score
// Lower is better.
// 1 = lower risk / manageable entry
// 2 = normal trend risk
// 3 = elevated risk / size carefully
// 4 = high risk / trim discipline
mars40RiskScore =
     reviewRaw ? 3 :
     mars40ExtensionScore >= 2.50 ? 4 :
     mars40ExtensionScore >= 1.25 ? 3 :
     mars40RegimeScore >= 2 and trendEfficiency >= 0.20 ? 1 : 2

// --- Portfolio score
// 5 = core hold / best quality
// 4 = extended but still valid
// 3 = watchlist / repair
// 2 = review / neutral
// 1 = reduce / avoid
mars40PortfolioScore =
     reviewRaw ? 2 :
     mars40RegimeScore >= 4 and mars40RiskScore <= 2 ? 5 :
     mars40RegimeScore >= 4 ? 4 :
     mars40RegimeScore >= 2 ? 3 : 2

// --- Composite alpha score
mars40AlphaRaw =
     mars40RegimeScore * 22.0 +
     mars40OpportunityScore * 16.0 +
     mars40PortfolioScore * 10.0 +
     mars40EfficiencyScore * 18.0 +
     mars40MaturityScore * 10.0 -
     mars40RiskScore * 8.0 -
     math.max(mars40ExtensionScore, 0.0) * 4.0

mars40AlphaScore = math.round(math.min(math.max(mars40AlphaRaw, 0.0), 100.0))

// --- Compact scan state
// 0 = Neutral
// 1 = Watchlist / repair
// 2 = Fresh money OK
// 3 = Early trend
// 4 = Core hold
// 5 = Reduce / avoid
mars40FreshMoneyOK =
     mars40RegimeScore >= 2 and
     mars40RiskScore <= 2 and
     mars40ExtensionScore < 1.25 and
     trendEfficiency >= 0.15

mars40EarlyTrendScan =
     mars40RegimeScore >= 2 and
     mars40RegimeScore <= 3 and
     mars40RiskScore <= 2 and
     mars40ExtensionScore < 1.50 and
     trendEfficiency >= 0.15

mars40CoreHoldScan =
     mars40RegimeScore >= 4 and
     mars40PortfolioScore >= 5 and
     mars40RiskScore <= 2

mars40WatchlistRepairScan =
     mars40RegimeScore == 2 or reviewRaw

mars40ReduceAvoidScan =
     mars40RiskScore >= 4

mars40ScanState =
     mars40ReduceAvoidScan ? 5 :
     mars40CoreHoldScan ? 4 :
     mars40EarlyTrendScan ? 3 :
     mars40FreshMoneyOK ? 2 :
     mars40WatchlistRepairScan ? 1 : 0

// --- ONLY TWO hidden plots to stay under TradingView's 64-plot limit
plot(mars40AlphaScore, title="MARS4 Alpha Score", display=display.none)
plot(mars40ScanState, title="MARS4 Scan State", display=display.none)

// --- Optional alert hooks. Alertconditions do not create watchlist columns.
alertcondition(mars40ScanState == 5, title="MARS4 Reduce / Avoid", message="MARS4 Reduce / Avoid scan triggered")
alertcondition(mars40ScanState == 4, title="MARS4 Core Hold", message="MARS4 Core Hold scan triggered")
alertcondition(mars40ScanState == 3, title="MARS4 Early Trend", message="MARS4 Early Trend scan triggered")
alertcondition(mars40ScanState == 2, title="MARS4 Fresh Money OK", message="MARS4 Fresh Money OK scan triggered")
alertcondition(mars40ScanState == 1, title="MARS4 Watchlist / Repair", message="MARS4 Watchlist / Repair scan triggered")
````

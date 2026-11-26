# Squeeze Vector [Gabremoku]

- url: https://www.tradingview.com/script/mo6LMtGv-Squeeze-Vector-Gabremoku/
- type: indicator
- pine_id: PUB;6f482eb84af644588973498d0eae1c2f
- version: 1.0

## Description

[b]Squeeze Vector [Gabremoku][/b] is a squeeze-based volatility breakout tool that combines Bollinger/Keltner compression detection, directional pressure flow, and a first-expansion state machine to help traders identify high-probability post-squeeze breakout setups.

The core idea is simple: compression precedes expansion. When Bollinger Bands shrink inside Keltner Channels, the market is coiling — and when that squeeze releases, the first directional signal can carry strong momentum. This script gives that process a structured visual and logical framework.

Core Concept — Squeeze → Release → Direction
A BB/KC squeeze occurs when Bollinger Bands, which reflect price volatility through standard deviation, contract inside Keltner Channels, which reflect typical range through ATR. This gap between the two envelopes is used as a proxy for volatility compression.

When BB width becomes smaller than KC width, the script identifies a Squeeze state. When it releases, the script enters an Armed state and opens a short post-squeeze window during which it looks for the first valid directional expansion.

Importantly, the squeeze release alone does not confirm direction. That is why the script adds multiple expansion confirmation filters before triggering a signal.

What it shows
Squeeze Vector Oscillator — a single line that rises as BB/KC compression increases. When it crosses above 50, the squeeze is active. The oscillator turns purple during squeeze states for fast visual identification.

Pressure Flow Histogram — a volume-weighted directional pressure value that reads where price closed within the candle range and weights it by volume relative to its moving average. Positive values indicate bullish pressure, negative values indicate bearish pressure.

Bollinger Overlay on Price — during squeeze states, the script renders Bollinger Bands directly on the main chart with gradient fills, making it easy to see where price is relative to the compressed structure.

LONG / SHORT signals — primary directional signals are placed on the main chart after a post-squeeze expansion bar meets all required conditions. Optional lighter repeat markers can be shown for follow-through confirmation.

Dashboard with live checklist — the on-chart dashboard shows the current state, regime, pressure, vector value, and a 6-point checklist for both long and short setups, with filled/empty circles to show how many conditions are currently met.

Signal Logic
The signal engine works as a state machine with three phases:

Squeeze — BB/KC compression is active. No signal is generated. The dashboard shows SQUEEZE.

Armed — the squeeze just released. The script opens a short expansion window and waits for directional confirmation. The dashboard shows ARMED.

Expansion signal — within the expansion window, if a valid directional bar forms with sufficient pressure, body size, and break condition, a LONG or SHORT label is placed on the main chart.

Signal direction is confirmed by checking:

Basis side: price above or below the BB basis

Pressure: smoothed directional pressure above threshold

Strong pressure: optional stronger filter

Body quality: minimum body-to-candle-range ratio

Break condition: higher high or lower low

Regime: optional EMA 200 trend filter

When both long and short conditions are simultaneously valid, the stronger pressure side wins. If pressure is equal, raw pressure bias decides.

States and Dashboard
The dashboard tracks the full machine at a glance:

Row	Content
SQZ	Squeeze ON / OFF
SEQ	ARMED or READY
REG	Trend regime (BULL / BEAR / OFF)
BIAS	Current directional pressure bias
P	Pressure Flow value
V	Vector Oscillator value
Checklist	6-point LONG and SHORT condition matrix
The checklist can be set to appear only during Squeeze or Armed states to reduce visual noise when no setup is forming.

Features
✅ Bollinger/Keltner squeeze detection via ratio oscillator

✅ Volume-weighted directional pressure flow

✅ Post-squeeze first expansion state machine

✅ Armed → signal transition logic

✅ 6-point entry checklist for both long and short

✅ EMA 200 regime filter

✅ Bollinger overlay with gradient fill during squeeze

✅ LONG / SHORT signal labels on main chart

✅ Optional follow-through repeat markers

✅ Repeat window filter to suppress signal clustering

✅ Strategy mode: Long, Short, or Both

✅ Fully configurable dashboard with size and offset settings

✅ Alert conditions for BUY, SELL, and squeeze activation

How to use
A practical workflow:

Watch for the Vector Oscillator to cross above 50 and turn purple — that is the squeeze state.

When it releases below 50, the dashboard switches to ARMED.

In the expansion window, check the checklist: more filled circles on one side indicate stronger directional alignment.

A LONG or SHORT label confirms a valid first expansion signal.

Use the Pressure Flow histogram to gauge how strong and consistent the directional push is.

The squeeze release alone is not a signal. Direction is only confirmed when the expansion bar quality, pressure, and structure checks all align.

Notes
Like all squeeze-based tools, Squeeze Vector is most effective when used alongside price structure context. Squeezes release into strong moves, but not every release produces a sustained trend — volume, higher timeframe context, and support/resistance levels can all affect follow-through quality.

[i]Author: Gabremoku
Pine Script v6[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator(title="Squeeze Vector [Gabremoku]", overlay=false, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  Squeeze Vector [Gabremoku]
//  Compression -> First Expansion Direction
// ═══════════════════════════════════════════════════════════════

// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "Strategy Mode & Signals"
strategySide         = input.string("Both", "Strategy Side", options=["Long", "Short", "Both"], group=grp0)
showSignals          = input.bool(true, "Show Signals on Main Chart", group=grp0)
showRepeatSignals    = input.bool(false, "Show Tiny Follow-Through Signals", group=grp0)
repeatWindowBars     = input.int(3, "Repeat Signal Window (bars)", minval=1, maxval=10, group=grp0)
expansionWindowBars  = input.int(5, "Post-Squeeze Expansion Window", minval=1, maxval=10, group=grp0)

grp1 = "Trend Filter"
useRegime            = input.bool(true, "Use EMA 200 Trend Filter", group=grp1)
lengthRegime         = input.int(200, "Regime EMA Length", minval=50, group=grp1)

grp2 = "Squeeze Vector Core"
vectorMaType         = input.string("EMA", "Basis Type", options=["SMA", "EMA", "WMA"], group=grp2)
lengthBB             = input.int(20, "BB Length", minval=1, group=grp2)
multBB               = input.float(2.0, "BB Multiplier", minval=0.1, step=0.1, group=grp2)
lengthATR            = input.int(14, "Keltner ATR Length", minval=1, group=grp2)
multKeltner          = input.float(1.4, "Keltner Multiplier", minval=0.1, step=0.1, group=grp2)

grp3 = "Expansion Logic"
lengthVolumeMA       = input.int(20, "Volume MA Length", minval=1, group=grp3)
lengthPressure       = input.int(5, "Pressure Smoothing", minval=1, group=grp3)
minPressure          = input.float(8.0, "Min Pressure Bias", minval=0.0, step=1.0, group=grp3)
strongPressure       = input.float(20.0, "Strong Pressure", minval=0.0, step=1.0, group=grp3)
minBodyPercent       = input.float(0.35, "Min Body % Of Candle Range", minval=0.05, maxval=1.0, step=0.05, group=grp3)
needUpperLowerBreak  = input.bool(false, "Require Break Above/Below BB", group=grp3)

grp4 = "Bollinger Overlay"
bbSrc                = input.source(close, "Overlay Source", group=grp4)
bbMaType             = input.string("SMA", "Overlay Basis Type", options=["SMA", "EMA", "RMA", "WMA", "VWMA"], group=grp4)
bbLengthOverlay      = input.int(20, "Overlay BB Length", minval=1, group=grp4)
bbMultOverlay        = input.float(2.0, "Overlay BB Multiplier", minval=0.1, step=0.1, group=grp4)
basisWidth           = input.int(2, "Basis Width", minval=1, maxval=5, group=grp4)
bandsWidth           = input.int(1, "Bands Width", minval=1, maxval=5, group=grp4)
neutralZonePct       = input.float(0.10, "Basis Neutral Zone %", minval=0.0, maxval=1.0, step=0.01, group=grp4)
fillAggressiveBB     = input.float(1.60, "BB Fill Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp4)
maxOpacityNear       = input.int(92, "Fill Opacity Near Basis", minval=0, maxval=100, group=grp4)
minOpacityFar        = input.int(20, "Fill Opacity Far From Basis", minval=0, maxval=100, group=grp4)

grp5 = "Dashboard"
showDashboard        = input.bool(true, "Show Dashboard", group=grp5)
dashboardSize        = input.string("Small", "Dashboard Size", options=["Normal", "Small", "Tiny"], group=grp5)
dashboardBarsOffset  = input.int(8, "Dashboard Horizontal Offset", minval=0, maxval=40, group=grp5)
showChecklistOnlySqz = input.bool(true, "Show Checklist Only In Squeeze / Armed", group=grp5)

grp6 = "Colors & Style"
bullColor            = input.color(color.rgb(33, 150, 243), "Bullish Color", group=grp6)
bearColor            = input.color(color.rgb(241, 255, 48), "Bearish Color", group=grp6)
squeezeColor         = input.color(color.rgb(156, 39, 176), "Squeeze Color", group=grp6)
neutralColor         = input.color(color.gray, "Neutral Color", group=grp6)
fillAggressive       = input.float(1.20, "Oscillator Gradient Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp6)

// ── FUNCTIONS ──────────────────────────────────────────────────
maBasic(_src, _len, _type) =>
    float _out = na
    if _type == "SMA"
        _out := ta.sma(_src, _len)
    else if _type == "EMA"
        _out := ta.ema(_src, _len)
    else
        _out := ta.wma(_src, _len)
    _out

maExtended(_src, _len, _type) =>
    float _out = na
    if _type == "SMA"
        _out := ta.sma(_src, _len)
    else if _type == "EMA"
        _out := ta.ema(_src, _len)
    else if _type == "RMA"
        _out := ta.rma(_src, _len)
    else if _type == "WMA"
        _out := ta.wma(_src, _len)
    else
        _out := ta.vwma(_src, _len)
    _out

clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

labelSizeFromDashboard(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : size.normal

dashLinePrefix(_ok) =>
    _ok ? "● " : "○ "

dashLine(_label, _ok) =>
    dashLinePrefix(_ok) + _label

// ── REGIME ─────────────────────────────────────────────────────
regimeMA = ta.ema(close, lengthRegime)
bullRegime = useRegime ? close > regimeMA : true
bearRegime = useRegime ? close < regimeMA : true

// ── SQUEEZE VECTOR CORE ────────────────────────────────────────
vectorBasis = maBasic(close, lengthBB, vectorMaType)
vectorDev   = multBB * ta.stdev(close, lengthBB)
vectorUpper = vectorBasis + vectorDev
vectorLower = vectorBasis - vectorDev
vectorBbWidth = vectorUpper - vectorLower

maKeltner       = maBasic(close, lengthATR, vectorMaType)
trueRangeSmooth = maBasic(ta.tr, lengthATR, vectorMaType)
rangeKeltner    = trueRangeSmooth * multKeltner
upperKeltner    = maKeltner + rangeKeltner
lowerKeltner    = maKeltner - rangeKeltner
kcWidth         = upperKeltner - lowerKeltner

vectorRatio = vectorBbWidth > 0.0 ? (kcWidth / vectorBbWidth) : 1.0
vectorOsc   = math.min(vectorRatio * 50.0, 100.0)
isSqueezeVector = vectorOsc >= 50.0
squeezeReleased = not isSqueezeVector and isSqueezeVector[1]

// ── PRESSURE ───────────────────────────────────────────────────
volumeMA = maBasic(volume, lengthVolumeMA, vectorMaType)
volumeRatio = volumeMA > 0.0 ? volume / volumeMA : 1.0

candleRange = high - low
bodySize    = math.abs(close - open)
bodyPct     = candleRange > 0.0 ? bodySize / candleRange : 0.0

rawDirection = candleRange > 0.0 ? ((close - low) - (high - close)) / candleRange : 0.0
weightedPressure = rawDirection * volumeRatio
smoothPressure   = ta.wma(weightedPressure, lengthPressure)
displayedPressure = math.min(math.max(smoothPressure * 50.0, -100.0), 100.0)

closePosInRange = candleRange > 0.0 ? (close - low) / candleRange : 0.5
bullCloseStrength = closePosInRange >= 0.60
bearCloseStrength = closePosInRange <= 0.40

bullExpansionBar = close > open and bodyPct >= minBodyPercent and bullCloseStrength and high > high[1]
bearExpansionBar = close < open and bodyPct >= minBodyPercent and bearCloseStrength and low < low[1]

bullBreakCondition = needUpperLowerBreak ? (close > vectorUpper or high > vectorUpper) : (close > vectorBasis and high > high[1])
bearBreakCondition = needUpperLowerBreak ? (close < vectorLower or low < vectorLower) : (close < vectorBasis and low < low[1])

bullPressureOk = displayedPressure > minPressure
bearPressureOk = displayedPressure < -minPressure

bullPressureStrong = displayedPressure > strongPressure
bearPressureStrong = displayedPressure < -strongPressure

// ── POST-SQUEEZE FIRST EXPANSION STATE ─────────────────────────
var bool awaitingExpansion = false
var int  squeezeReleaseBar = na
var int  lastSignalDirection = 0

if squeezeReleased
    awaitingExpansion := true
    squeezeReleaseBar := bar_index
    lastSignalDirection := 0

barsAfterRelease = awaitingExpansion and not na(squeezeReleaseBar) ? (bar_index - squeezeReleaseBar) : na
expansionWindowActive = awaitingExpansion and not na(barsAfterRelease) and barsAfterRelease >= 0 and barsAfterRelease <= expansionWindowBars

if awaitingExpansion and not expansionWindowActive
    awaitingExpansion := false

// ── FIRST DIRECTIONAL DECISION ─────────────────────────────────
rawLongEntry  = false
rawShortEntry = false

longAllowed  = strategySide == "Long" or strategySide == "Both"
shortAllowed = strategySide == "Short" or strategySide == "Both"

longCandidate =
     expansionWindowActive and
     longAllowed and
     bullExpansionBar and
     bullBreakCondition and
     bullPressureOk and
     bullRegime

shortCandidate =
     expansionWindowActive and
     shortAllowed and
     bearExpansionBar and
     bearBreakCondition and
     bearPressureOk and
     bearRegime

if longCandidate and not shortCandidate and lastSignalDirection == 0
    rawLongEntry := true
    awaitingExpansion := false
    lastSignalDirection := 1
else if shortCandidate and not longCandidate and lastSignalDirection == 0
    rawShortEntry := true
    awaitingExpansion := false
    lastSignalDirection := -1
else if longCandidate and shortCandidate and lastSignalDirection == 0
    if bullPressureStrong and not bearPressureStrong
        rawLongEntry := true
        awaitingExpansion := false
        lastSignalDirection := 1
    else if bearPressureStrong and not bullPressureStrong
        rawShortEntry := true
        awaitingExpansion := false
        lastSignalDirection := -1
    else
        if displayedPressure >= 0
            rawLongEntry := true
            awaitingExpansion := false
            lastSignalDirection := 1
        else
            rawShortEntry := true
            awaitingExpansion := false
            lastSignalDirection := -1

// ── TINY FOLLOW-THROUGH MARKERS ────────────────────────────────
followLong =
     showRepeatSignals and
     lastSignalDirection == 1 and
     not rawLongEntry and
     not na(squeezeReleaseBar) and
     (bar_index - squeezeReleaseBar > 0) and
     (bar_index - squeezeReleaseBar <= expansionWindowBars + 2) and
     close > vectorBasis and
     displayedPressure > strongPressure and
     high > high[1]

followShort =
     showRepeatSignals and
     lastSignalDirection == -1 and
     not rawShortEntry and
     not na(squeezeReleaseBar) and
     (bar_index - squeezeReleaseBar > 0) and
     (bar_index - squeezeReleaseBar <= expansionWindowBars + 2) and
     close < vectorBasis and
     displayedPressure < -strongPressure and
     low < low[1]

// ── REPEAT WINDOW FILTER ───────────────────────────────────────
var int lastLongSignalBar  = na
var int lastShortSignalBar = na

primaryLongEntry  = false
repeatLongEntry   = false
primaryShortEntry = false
repeatShortEntry  = false

if rawLongEntry or followLong
    bool isRepeatLong = not na(lastLongSignalBar) and (bar_index - lastLongSignalBar) <= repeatWindowBars
    if isRepeatLong
        repeatLongEntry := true
    else
        primaryLongEntry := true
    lastLongSignalBar := bar_index

if rawShortEntry or followShort
    bool isRepeatShort = not na(lastShortSignalBar) and (bar_index - lastShortSignalBar) <= repeatWindowBars
    if isRepeatShort
        repeatShortEntry := true
    else
        primaryShortEntry := true
    lastShortSignalBar := bar_index

// ── OSCILLATOR COLORS ──────────────────────────────────────────
oscColor = isSqueezeVector ? squeezeColor : neutralColor
pressureNorm = clamp(math.pow(math.abs(displayedPressure) / 100.0, fillAggressive), 0.0, 1.0)

histColor = displayedPressure >= 0.0
  ? color.from_gradient(pressureNorm, 0.0, 1.0, color.new(bullColor, 80), color.new(bullColor, 10))
  : color.from_gradient(pressureNorm, 0.0, 1.0, color.new(bearColor, 80), color.new(bearColor, 10))

// ── BOLLINGER OVERLAY VISUALS ──────────────────────────────────
bbBasis = maExtended(bbSrc, bbLengthOverlay, bbMaType)
bbDev   = ta.stdev(bbSrc, bbLengthOverlay) * bbMultOverlay
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

halfBand = bbDev
bbPos = halfBand > 0.0 ? (bbSrc - bbBasis) / halfBand : 0.0
bbPosClamped = clamp(bbPos, -2.0, 2.0)

neutralHi = neutralZonePct
neutralLo = -neutralZonePct

basisColorRaw = bbPosClamped >= 0.0
     ? color.from_gradient(bbPosClamped, neutralHi, 1.0, neutralColor, bullColor)
     : color.from_gradient(bbPosClamped, -1.0, neutralLo, bearColor, neutralColor)

basisColor = isSqueezeVector ? squeezeColor : math.abs(bbPosClamped) <= neutralZonePct ? neutralColor : basisColorRaw

distRaw  = math.abs(bbPosClamped)
distNorm = clamp(math.pow(clamp(distRaw, 0.0, 1.5) / 1.5, fillAggressiveBB), 0.0, 1.0)

bullNear = color.new(bullColor, maxOpacityNear)
bullFar  = color.new(bullColor, minOpacityFar)
bearNear = color.new(bearColor, maxOpacityNear)
bearFar  = color.new(bearColor, minOpacityFar)

bullFillTop    = color.from_gradient(distNorm, 0.0, 1.0, bullNear, bullFar)
bearFillBottom = color.from_gradient(distNorm, 0.0, 1.0, bearNear, bearFar)
sqzOutlineColor = color.new(squeezeColor, 5)

// ── DASHBOARD DATA ─────────────────────────────────────────────
dashStateText = isSqueezeVector ? "SQUEEZE" : awaitingExpansion ? "ARMED" : lastSignalDirection == 1 ? "LONG" : lastSignalDirection == -1 ? "SHORT" : "IDLE"
dashBiasText = displayedPressure >= 0 ? "LONG BIAS" : "SHORT BIAS"
showChecklistBlock = showChecklistOnlySqz ? (isSqueezeVector or awaitingExpansion) : true

l1 = close > vectorBasis
l2 = displayedPressure > minPressure
l3 = displayedPressure > strongPressure
l4 = close > open
l5 = high > high[1]
l6 = bullRegime

s1 = close < vectorBasis
s2 = displayedPressure < -minPressure
s3 = displayedPressure < -strongPressure
s4 = close < open
s5 = low < low[1]
s6 = bearRegime

longChecklistText =
     dashLine("L1 Basis", l1) + "\n" +
     dashLine("L2 Press", l2) + "\n" +
     dashLine("L3 Force", l3) + "\n" +
     dashLine("L4 Body", l4) + "\n" +
     dashLine("L5 Break", l5) + "\n" +
     dashLine("L6 Regime", l6)

shortChecklistText =
     dashLine("S1 Basis", s1) + "\n" +
     dashLine("S2 Press", s2) + "\n" +
     dashLine("S3 Force", s3) + "\n" +
     dashLine("S4 Body", s4) + "\n" +
     dashLine("S5 Break", s5) + "\n" +
     dashLine("S6 Regime", s6)

// ── PLOTS ──────────────────────────────────────────────────────
plot(displayedPressure, title="Pressure Flow", color=histColor, style=plot.style_histogram, linewidth=2)
plot(vectorOsc, title="Squeeze Vector Oscillator", color=oscColor, linewidth=2)
hline(50, "Squeeze Threshold", color=color.new(neutralColor, 50), linestyle=hline.style_dashed)
hline(0, "Neutral Axis", color=color.new(neutralColor, 70))

upperSqzFillPlot = plot(isSqueezeVector ? bbUpper : na, title="Squeeze Upper Fill", color=color.new(color.black, 100), linewidth=1, style=plot.style_linebr, force_overlay=true)
basisSqzFillPlot = plot(isSqueezeVector ? bbBasis : na, title="Squeeze Basis Fill", color=color.new(color.black, 100), linewidth=1, style=plot.style_linebr, force_overlay=true)
lowerSqzFillPlot = plot(isSqueezeVector ? bbLower : na, title="Squeeze Lower Fill", color=color.new(color.black, 100), linewidth=1, style=plot.style_linebr, force_overlay=true)

fill(upperSqzFillPlot, basisSqzFillPlot, color=isSqueezeVector ? bullFillTop : na, fillgaps=false, title="Bull Gradient Fill")
fill(basisSqzFillPlot, lowerSqzFillPlot, color=isSqueezeVector ? bearFillBottom : na, fillgaps=false, title="Bear Gradient Fill")

plot(isSqueezeVector ? bbUpper : na, title="Squeeze Upper Outline", color=sqzOutlineColor, linewidth=bandsWidth, style=plot.style_linebr, force_overlay=true)
plot(isSqueezeVector ? bbBasis : na, title="Squeeze Basis Line", color=basisColor, linewidth=basisWidth, style=plot.style_linebr, force_overlay=true)
plot(isSqueezeVector ? bbLower : na, title="Squeeze Lower Outline", color=sqzOutlineColor, linewidth=bandsWidth, style=plot.style_linebr, force_overlay=true)

plotshape(showSignals and primaryLongEntry, title="LONG", text="LONG", style=shape.triangleup, location=location.belowbar, color=bullColor, textcolor=color.white, size=size.small, force_overlay=true)
plotshape(showSignals and repeatLongEntry, title="LONG Repeat", text="", style=shape.triangleup, location=location.belowbar, color=color.new(bullColor, 60), size=size.tiny, force_overlay=true)

plotshape(showSignals and primaryShortEntry, title="SHORT", text="SHORT", style=shape.triangledown, location=location.abovebar, color=bearColor, textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showSignals and repeatShortEntry, title="SHORT Repeat", text="", style=shape.triangledown, location=location.abovebar, color=color.new(bearColor, 60), size=size.tiny, force_overlay=true)

// ── GABREMOKU DASHBOARD OVERLAY MONOLABEL ──────────────────────
var label dashMainLbl = na

dashLabelSize = labelSizeFromDashboard(dashboardSize)

dashLookback = 120
rangeHi = ta.highest(high, dashLookback)
rangeLo = ta.lowest(low, dashLookback)
rangeSpan = math.max(rangeHi - rangeLo, syminfo.mintick * 100)

dashX = bar_index + (dashboardSize == "Tiny" ? 8 : dashboardSize == "Small" ? 10 : 12) + dashboardBarsOffset
dashY = rangeHi - rangeSpan * (dashboardSize == "Tiny" ? 0.10 : dashboardSize == "Small" ? 0.08 : 0.06)

dashMainText =
     "SQUEEZE VECTOR | " + dashStateText + "\n" +
     "--------------------\n" +
     "MODE  " + strategySide + "\n" +
     "SQZ   " + (isSqueezeVector ? "ON" : "OFF") + "\n" +
     "SEQ   " + (awaitingExpansion ? "ARMED" : "READY") + "\n" +
     "REG   " + (useRegime ? (bullRegime ? "BULL" : bearRegime ? "BEAR" : "MIXED") : "OFF") + "\n" +
     "BIAS  " + dashBiasText + "\n" +
     "P     " + str.tostring(displayedPressure, format.mintick) + "\n" +
     "V     " + str.tostring(vectorOsc, format.mintick) +
     (showChecklistBlock ? "\n--------------------\nLONG\n" + longChecklistText + "\n\nSHORT\n" + shortChecklistText : "")

if barstate.islast
    if not na(dashMainLbl)
        label.delete(dashMainLbl)

    if showDashboard
        dashMainLbl := label.new(
             x=dashX,
             y=dashY,
             text=dashMainText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(color.black, 18),
             textcolor=chart.fg_color,
             size=dashLabelSize,
             force_overlay=true
        )
````

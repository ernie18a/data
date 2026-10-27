# Parallax Regime Lattice [JOAT]

- url: https://www.tradingview.com/script/JAovpgvX-Parallax-Regime-Lattice-JOAT/
- type: indicator
- pine_id: PUB;e457f19f9c5b451c88295dfb298d1e6d
- version: 1.0

## Description

[b]Parallax Regime Lattice [JOAT][/b]

[b]Introduction[/b]

Parallax Regime Lattice is an open-source market-state overlay built to classify whether price is operating in directional expansion, transitional behavior, chop, or compression. It combines structure events, liquidity sweeps, absorption behavior, EMA alignment, ADX, and choppiness into one continuous regime and confluence model.

The problem Parallax solves is fragmented context. Structure, liquidity, and regime are often analyzed with separate scripts, which makes it difficult to see when they actually agree. Parallax consolidates those layers into one chart model so the user can evaluate bias, confluence, and nearby structural risk from a single panel.

[image]https://www.tradingview.com/x/CxwnV5Rp/[/image]

[b]Core Concepts[/b]

[b]1. Structure State[/b]

The script tracks confirmed swing highs and swing lows and classifies directional breaks as the current structural state. This forms the backbone of the regime engine.

[b]2. Liquidity Level Registry[/b]

Confirmed pivot highs and lows are registered as buy-side and sell-side liquidity references, extended forward, and marked when swept.

[b]3. Absorption Zones[/b]

High-volume, low-body candles are used to identify localized demand or supply absorption areas, which are preserved as forward boxes for as long as they remain relevant.

[b]4. Chop and Compression Filters[/b]

ADX, choppiness, and compression ratio work together to determine whether the market is expanding, compressing, or structurally noisy.

[b]5. Confluence Score[/b]

Trend direction, structure, liquidity behavior, slope, and expansion quality are combined into one confluence score that is graded directly in the dashboard.

[b]Features[/b]

[list]
[*][b]Structure classification:[/b] BOS and regime-state handling from confirmed swing breaks
[*][b]Liquidity sweep tracking:[/b] Buy-side and sell-side levels retained and marked when swept
[*][b]Absorption zones:[/b] High-volume low-body candles create forward supply or demand boxes
[*][b]Compression box:[/b] Compression is visualized directly on the chart when range conditions dominate
[*][b]Confluence heat:[/b] Optional background heat reflects directional agreement strength
[*][b]EMA ribbon:[/b] Fast, intermediate, and structural composites define directional geometry
[*][b]Institutional dashboard:[/b] Bias, regime, ADX/chop, structure, confluence, sweep status, nearest level, and compression are summarized in one panel
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the regime row[/b]
Expansion means structure and conditions favor directional trade selection. Compression and chop mean the market is less suitable for trend continuation logic.

[b]Step 2: Check confluence grade[/b]
The grade gives a compact summary of how strongly the active state is supported by the underlying engines.

[b]Step 3: Use liquidity and absorption together[/b]
A sweep into an active absorption zone is a materially different event than an isolated sweep with no supporting structure.

[b]Step 4: Use nearest level for risk framing[/b]
The nearest tracked structural level helps frame where the next meaningful invalidation or continuation event may occur.

[b]Indicator Limitations[/b]

[list]
[*]Swing-confirmed structure always arrives with intentional delay because pivots require confirmation
[*]Liquidity levels are contextual references, not guaranteed reversal points
[*]Compression and chop states can persist longer than expected in slow markets
[*]Parallax classifies regime and confluence; it is not a full execution model by itself
[/list]

[b]Originality Statement[/b]

Parallax Regime Lattice is original in the way it merges structure, liquidity, absorption, chop, compression, and confluence into one coherent regime overlay rather than presenting those layers as disconnected tools.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Structural, liquidity, and regime readings can fail in live markets. Always apply independent risk management and validation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Parallax Regime Lattice [JOAT]", shorttitle="PL [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=300)

//------------------------------------------------------------------------------
// Theme
//------------------------------------------------------------------------------
var string g_core = "Core Engine"
var string g_structure = "Structure"
var string g_regime = "Regime Filters"
var string g_visual = "Visual System"
var string g_dash = "Dashboard"

color bullCore = input.color(color.rgb(32, 201, 151), "Bull Core", group=g_visual, inline="theme")
color bearCore = input.color(color.rgb(255, 107, 107), "Bear Core", group=g_visual, inline="theme")
color neutralCore = input.color(color.rgb(122, 138, 153), "Neutral Core", group=g_visual, inline="theme")
color accentCore = input.color(color.rgb(96, 165, 250), "Accent", group=g_visual, inline="theme")
color cautionCore = input.color(color.rgb(245, 158, 11), "Caution", group=g_visual, inline="theme2")
color backgroundCore = input.color(color.rgb(11, 18, 28), "Dashboard Background", group=g_visual, inline="theme2")

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
src = input.source(close, "Primary Source", group=g_core)
fastLen = input.int(21, "Fast Trend Length", minval=2, group=g_core, inline="ema")
midLen = input.int(55, "Intermediate Length", minval=3, group=g_core, inline="ema")
slowLen = input.int(144, "Structural Length", minval=5, group=g_core, inline="ema")
atrLen = input.int(14, "ATR Length", minval=2, group=g_core, inline="atr")
atrBandMult = input.float(1.35, "ATR Band Multiplier", minval=0.1, step=0.05, group=g_core, inline="atr")

pivotLen = input.int(5, "Pivot Strength", minval=2, maxval=20, group=g_structure, inline="p")
poolToleranceAtr = input.float(0.18, "Pool Tolerance ATR", minval=0.05, step=0.01, group=g_structure, inline="p")
poolHistory = input.int(10, "Tracked Liquidity Levels", minval=2, maxval=30, group=g_structure)
zoneHistory = input.int(6, "Tracked Absorption Zones", minval=1, maxval=15, group=g_structure)
zoneExtension = input.int(35, "Zone Extension Bars", minval=10, maxval=120, group=g_structure)

adxLen = input.int(14, "ADX Length", minval=3, group=g_regime, inline="adx")
adxTrendFloor = input.float(19.0, "Trend Floor", minval=5.0, step=0.5, group=g_regime, inline="adx")
chopLen = input.int(14, "Chop Length", minval=5, group=g_regime, inline="chop")
chopCeiling = input.float(61.8, "Chop Ceiling", minval=30.0, maxval=80.0, step=0.1, group=g_regime, inline="chop")
compressionLookback = input.int(34, "Compression Lookback", minval=10, maxval=200, group=g_regime, inline="comp")
compressionThreshold = input.float(0.78, "Compression Threshold", minval=0.2, maxval=2.0, step=0.01, group=g_regime, inline="comp")

showRibbon = input.bool(true, "Trend Ribbon", group=g_visual, inline="vis1")
showLevels = input.bool(true, "Liquidity Levels", group=g_visual, inline="vis1")
showZones = input.bool(true, "Absorption Zones", group=g_visual, inline="vis1")
showHeat = input.bool(true, "Confluence Heat", group=g_visual, inline="vis2")
showBarColor = input.bool(false, "Bar Coloring", group=g_visual, inline="vis2")
showStructureLabels = input.bool(true, "Structure Labels", group=g_visual, inline="vis2")

showDashboard = input.bool(true, "Show Dashboard", group=g_dash, inline="d1")
dashboardScale = input.string("Medium", "Scale", options=["Compact", "Medium"], group=g_dash, inline="d1")
dashboardPosition = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g_dash)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_dash_pos(pos) =>
    switch pos
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_dash_size(scale) =>
    switch scale
        "Compact" => size.tiny
        => size.small

f_line_style(styleSelector) =>
    switch styleSelector
        "dotted" => line.style_dotted
        "solid" => line.style_solid
        => line.style_dashed

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_zscore(value, length) =>
    mean = ta.sma(value, length)
    dev = ta.stdev(value, length)
    dev != 0 ? (value - mean) / dev : 0.0

f_grade(score) =>
    score >= 80 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_label_size(scale) =>
    scale == "Compact" ? size.tiny : size.small

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
atr = ta.atr(atrLen)
fastEma = ta.ema(src, fastLen)
midEma = ta.ema(src, midLen)
slowEma = ta.ema(src, slowLen)
trendBasis = (fastEma + midEma + slowEma) / 3.0
upperBand = trendBasis + atr * atrBandMult
lowerBand = trendBasis - atr * atrBandMult

[diplus, diminus, adxValue] = ta.dmi(adxLen, adxLen)
trSum = math.sum(ta.tr(true), chopLen)
rangeDenominator = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
chopValue = rangeDenominator > 0 ? 100 * math.log10(trSum / rangeDenominator) / math.log10(chopLen) : 50.0

compressionRange = ta.highest(high, compressionLookback) - ta.lowest(low, compressionLookback)
compressionAtrUnit = atr * compressionLookback
compressionRatio = compressionAtrUnit > 0 ? compressionRange / compressionAtrUnit : 1.0
isCompressed = compressionRatio < compressionThreshold

fastSlope = fastEma - fastEma[1]
midSlope = midEma - midEma[1]
slowSlope = slowEma - slowEma[1]
slopeMix = (fastSlope + midSlope + slowSlope) / 3.0
slopeNorm = f_clamp(50 + f_zscore(slopeMix, 55) * 12.5, 0, 100)

trendBias = 0
trendBias += fastEma > midEma ? 1 : -1
trendBias += midEma > slowEma ? 1 : -1
trendBias += close > trendBasis ? 1 : -1
trendBias += diplus > diminus ? 1 : -1

directionState = trendBias >= 2 ? 1 : trendBias <= -2 ? -1 : 0
isTrendHealthy = adxValue >= adxTrendFloor and chopValue < chopCeiling

//------------------------------------------------------------------------------
// Structure state
//------------------------------------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float prevSwingHigh = na
var int lastSwingHighBar = na
var float lastSwingLow = na
var float prevSwingLow = na
var int lastSwingLowBar = na
var int structureState = 0
var string lastStructureEvent = "Neutral"
var float lastStructurePrice = na

if not na(ph)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph
    lastSwingHighBar := bar_index - pivotLen

if not na(pl)
    prevSwingLow := lastSwingLow
    lastSwingLow := pl
    lastSwingLowBar := bar_index - pivotLen

bullBos = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bearBos = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

if bullBos
    lastStructureEvent := structureState <= 0 ? "Bullish CHOCH" : "Bullish BOS"
    structureState := 1
    lastStructurePrice := lastSwingHigh
if bearBos
    lastStructureEvent := structureState >= 0 ? "Bearish CHOCH" : "Bearish BOS"
    structureState := -1
    lastStructurePrice := lastSwingLow

//------------------------------------------------------------------------------
// Liquidity levels and sweep tracking
//------------------------------------------------------------------------------
var line[] liquidityLines = array.new_line()
var label[] liquidityLabels = array.new_label()
var float[] liquidityPrices = array.new_float()
var int[] liquiditySides = array.new_int()
var bool[] liquiditySwept = array.new_bool()

f_add_liquidity_level(levelPrice, levelBar, side) =>
    if showLevels and not na(levelPrice)
        levelColor = side == 1 ? color.new(bearCore, 45) : color.new(bullCore, 45)
        ln = line.new(levelBar, levelPrice, bar_index + 1, levelPrice, color=levelColor, width=1, style=line.style_dashed)
        lb = label.new(levelBar, levelPrice, side == 1 ? "Buy-side" : "Sell-side", style=side == 1 ? label.style_label_down : label.style_label_up, textcolor=levelColor, color=color.new(backgroundCore, 15), size=size.tiny)
        array.push(liquidityLines, ln)
        array.push(liquidityLabels, lb)
        array.push(liquidityPrices, levelPrice)
        array.push(liquiditySides, side)
        array.push(liquiditySwept, false)
        if array.size(liquidityLines) > poolHistory
            line.delete(array.shift(liquidityLines))
            label.delete(array.shift(liquidityLabels))
            array.shift(liquidityPrices)
            array.shift(liquiditySides)
            array.shift(liquiditySwept)

if not na(ph)
    f_add_liquidity_level(ph, bar_index - pivotLen, 1)
if not na(pl)
    f_add_liquidity_level(pl, bar_index - pivotLen, -1)

var string lastSweepText = "None"
var float lastSweepPrice = na

if array.size(liquidityLines) > 0
    for i = 0 to array.size(liquidityLines) - 1
        ln = array.get(liquidityLines, i)
        lb = array.get(liquidityLabels, i)
        levelPrice = array.get(liquidityPrices, i)
        levelSide = array.get(liquiditySides, i)
        wasSwept = array.get(liquiditySwept, i)
        line.set_x2(ln, bar_index + 1)
        label.set_x(lb, bar_index + 1)

        sweepDown = barstate.isconfirmed and levelSide == -1 and low < levelPrice and close > levelPrice
        sweepUp = barstate.isconfirmed and levelSide == 1 and high > levelPrice and close < levelPrice
        if (sweepDown or sweepUp) and not wasSwept
            array.set(liquiditySwept, i, true)
            line.set_color(ln, color.new(cautionCore, 0))
            label.set_text(lb, sweepDown ? "Sell-side swept" : "Buy-side swept")
            label.set_textcolor(lb, cautionCore)
            lastSweepText := sweepDown ? "Sell-side Sweep" : "Buy-side Sweep"
            lastSweepPrice := levelPrice

//------------------------------------------------------------------------------
// Absorption zones
//------------------------------------------------------------------------------
var box[] absorptionBoxes = array.new_box()
var label[] absorptionNotes = array.new_label()
volumeBaseline = ta.sma(volume, 20)
spread = high - low
body = math.abs(close - open)
bodyRatio = spread > 0 ? body / spread : 0.0
absorptionBull = barstate.isconfirmed and volume > volumeBaseline * 1.8 and bodyRatio < 0.32 and close >= open and close <= high - spread * 0.35
absorptionBear = barstate.isconfirmed and volume > volumeBaseline * 1.8 and bodyRatio < 0.32 and close <= open and close >= low + spread * 0.35

f_add_zone(zoneTop, zoneBottom, textLabel, zoneColor) =>
    if showZones
        b = box.new(bar_index, zoneTop, bar_index + zoneExtension, zoneBottom, bgcolor=color.new(zoneColor, 86), border_color=color.new(zoneColor, 12), border_width=1)
        n = label.new(bar_index, zoneTop, textLabel, style=label.style_label_left, textcolor=zoneColor, color=color.new(backgroundCore, 10), size=size.tiny)
        array.push(absorptionBoxes, b)
        array.push(absorptionNotes, n)
        if array.size(absorptionBoxes) > zoneHistory
            box.delete(array.shift(absorptionBoxes))
            label.delete(array.shift(absorptionNotes))

if absorptionBull
    f_add_zone(high, low, "Demand Absorption", bullCore)
if absorptionBear
    f_add_zone(high, low, "Supply Absorption", bearCore)

if array.size(absorptionBoxes) > 0
    for i = 0 to array.size(absorptionBoxes) - 1
        b = array.get(absorptionBoxes, i)
        n = array.get(absorptionNotes, i)
        box.set_right(b, bar_index + zoneExtension)
        label.set_x(n, bar_index)

//------------------------------------------------------------------------------
// Compression box
//------------------------------------------------------------------------------
var box compressionBox = na
if isCompressed and showZones
    compressionTop = ta.highest(high, compressionLookback)
    compressionBottom = ta.lowest(low, compressionLookback)
    if na(compressionBox)
        compressionBox := box.new(bar_index - compressionLookback, compressionTop, bar_index + 3, compressionBottom, bgcolor=color.new(accentCore, 92), border_color=color.new(accentCore, 65), border_style=line.style_dotted)
    else
        box.set_left(compressionBox, bar_index - compressionLookback)
        box.set_right(compressionBox, bar_index + 3)
        box.set_top(compressionBox, compressionTop)
        box.set_bottom(compressionBox, compressionBottom)
else if not na(compressionBox)
    box.delete(compressionBox)
    compressionBox := na

//------------------------------------------------------------------------------
// Confluence and state scoring
//------------------------------------------------------------------------------
volumeZ = f_zscore(volume, 55)
atrZ = f_zscore(atr, 55)
biasScore = 0.0
biasScore += directionState == 1 ? 22 : directionState == -1 ? -22 : 0
biasScore += structureState == 1 ? 18 : structureState == -1 ? -18 : 0
biasScore += isTrendHealthy ? (directionState != 0 ? directionState * 15 : 0) : 0
biasScore += bullBos ? 15 : bearBos ? -15 : 0
biasScore += absorptionBull ? 10 : absorptionBear ? -10 : 0
biasScore += lastSweepText == "Sell-side Sweep" ? 9 : lastSweepText == "Buy-side Sweep" ? -9 : 0
biasScore += slopeNorm > 55 ? 8 : slopeNorm < 45 ? -8 : 0
biasScore := f_clamp(biasScore, -100, 100)

confluenceScore = math.abs(biasScore)
confluenceGrade = f_grade(confluenceScore)
regimeText = isCompressed ? "Compression" : chopValue >= chopCeiling ? "Chop" : isTrendHealthy ? "Expansion" : "Transitional"
regimeColor = regimeText == "Expansion" ? (directionState >= 0 ? bullCore : bearCore) : regimeText == "Compression" ? accentCore : cautionCore

heatAlpha = 96 - int(math.min(confluenceScore, 85) / 85 * 16)
heatColor = biasScore > 0 ? color.new(bullCore, heatAlpha) : biasScore < 0 ? color.new(bearCore, heatAlpha) : na
bgcolor(showHeat and barstate.isconfirmed and regimeText == "Expansion" ? heatColor : na, title="Confluence Heat")

//------------------------------------------------------------------------------
// Visual system
//------------------------------------------------------------------------------
fastPlot = plot(fastEma, "Fast Composite", color=color.new(bullCore, 20), linewidth=1)
midPlot = plot(midEma, "Intermediate Composite", color=color.new(accentCore, 20), linewidth=1)
slowPlot = plot(slowEma, "Structural Composite", color=color.new(bearCore, 25), linewidth=1)
fill(fastPlot, midPlot, color=showRibbon ? color.new(directionState >= 0 ? bullCore : bearCore, 86) : na, title="Fast-Mid Ribbon")
fill(midPlot, slowPlot, color=showRibbon ? color.new(directionState >= 0 ? bullCore : bearCore, 91) : na, title="Mid-Slow Ribbon")

plot(upperBand, "Upper Lattice", color=color.new(bearCore, 78), linewidth=1, style=plot.style_linebr)
plot(lowerBand, "Lower Lattice", color=color.new(bullCore, 78), linewidth=1, style=plot.style_linebr)
plot(trendBasis, "Trend Basis", color=color.new(neutralCore, 25), linewidth=2)

barColorFinal = directionState == 1 ? color.new(bullCore, 68) : directionState == -1 ? color.new(bearCore, 68) : na
barcolor(showBarColor ? barColorFinal : na)

if showStructureLabels and bullBos
    label.new(bar_index, low, lastStructureEvent, style=label.style_label_up, textcolor=bullCore, color=color.new(backgroundCore, 5), size=f_label_size(dashboardScale))
if showStructureLabels and bearBos
    label.new(bar_index, high, lastStructureEvent, style=label.style_label_down, textcolor=bearCore, color=color.new(backgroundCore, 5), size=f_label_size(dashboardScale))

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dashboard = table.new(f_dash_pos(dashboardPosition), 2, 9, bgcolor=color.new(backgroundCore, 8), border_color=color.new(neutralCore, 75), border_width=1)
if showDashboard and barstate.islast
    dashText = f_dash_size(dashboardScale)
    stateText = directionState == 1 ? "Bullish" : directionState == -1 ? "Bearish" : "Balanced"
    stateColor = directionState == 1 ? bullCore : directionState == -1 ? bearCore : neutralCore
    sweepText = na(lastSweepPrice) ? "None" : lastSweepText + " @ " + str.tostring(lastSweepPrice, format.mintick)
    nearestLevel = na(lastSwingHigh) and na(lastSwingLow) ? na : na(lastSwingHigh) ? lastSwingLow : na(lastSwingLow) ? lastSwingHigh : math.abs(close - lastSwingHigh) < math.abs(close - lastSwingLow) ? lastSwingHigh : lastSwingLow
    levelText = na(nearestLevel) ? "Unavailable" : str.tostring(nearestLevel, format.mintick)

    table.cell(dashboard, 0, 0, "Parallax Regime", text_color=color.white, text_size=dashText, bgcolor=color.new(accentCore, 75))
    table.cell(dashboard, 1, 0, "Lattice", text_color=color.white, text_size=dashText, bgcolor=color.new(accentCore, 75))

    table.cell(dashboard, 0, 1, "Bias", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 1, stateText, text_color=stateColor, text_size=dashText)

    table.cell(dashboard, 0, 2, "Regime", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 2, regimeText, text_color=regimeColor, text_size=dashText)

    table.cell(dashboard, 0, 3, "ADX / Chop", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 3, str.tostring(adxValue, "#.0") + " / " + str.tostring(chopValue, "#.0"), text_color=adxValue >= adxTrendFloor ? stateColor : cautionCore, text_size=dashText)

    table.cell(dashboard, 0, 4, "Structure", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 4, lastStructureEvent, text_color=structureState == 1 ? bullCore : structureState == -1 ? bearCore : neutralCore, text_size=dashText)

    table.cell(dashboard, 0, 5, "Confluence", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 5, str.tostring(confluenceScore, "#.0") + " | " + confluenceGrade, text_color=confluenceScore >= 65 ? stateColor : cautionCore, text_size=dashText)

    table.cell(dashboard, 0, 6, "Sweep", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 6, sweepText, text_color=lastSweepText == "Sell-side Sweep" ? bullCore : lastSweepText == "Buy-side Sweep" ? bearCore : neutralCore, text_size=dashText)

    table.cell(dashboard, 0, 7, "Nearest Level", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 7, levelText, text_color=accentCore, text_size=dashText)

    table.cell(dashboard, 0, 8, "Compression", text_color=neutralCore, text_size=dashText)
    table.cell(dashboard, 1, 8, str.tostring(compressionRatio, "#.00"), text_color=isCompressed ? cautionCore : stateColor, text_size=dashText)

//------------------------------------------------------------------------------
// Signal-state alerts
//------------------------------------------------------------------------------
bullTransition = barstate.isconfirmed and biasScore > 25 and biasScore[1] <= 25
bearTransition = barstate.isconfirmed and biasScore < -25 and biasScore[1] >= -25
regimeExpansion = barstate.isconfirmed and regimeText == "Expansion" and regimeText[1] != "Expansion"
regimeCompression = barstate.isconfirmed and regimeText == "Compression" and regimeText[1] != "Compression"

alertcondition(bullTransition, "Parallax Bullish State", "Parallax Regime Lattice [JOAT] has transitioned into bullish expansion.")
alertcondition(bearTransition, "Parallax Bearish State", "Parallax Regime Lattice [JOAT] has transitioned into bearish expansion.")
alertcondition(regimeExpansion, "Parallax Expansion", "Parallax Regime Lattice [JOAT] has entered an expansion regime.")
alertcondition(regimeCompression, "Parallax Compression", "Parallax Regime Lattice [JOAT] has entered a compression regime.")
````

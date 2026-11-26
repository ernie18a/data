# Swing Volume Structure [JOAT]

- url: https://www.tradingview.com/script/ULPPiAyj-Swing-Volume-Structure-JOAT/
- type: indicator
- pine_id: PUB;a70fc383c7fb47c4922a7ee15528178e
- version: 1.0

## Description

[b]Swing Volume Structure [JOAT][/b]

[b]Introduction[/b]

Swing Volume Structure is an open-source market structure indicator focused on confirmed pivots, volume-backed breakouts, sweeps, retests, and compression. It is designed to keep structure analysis clean by confirming pivots with right-side bars and confirming actionable states on bar close.

The script helps traders distinguish ordinary swing movement from structure breaks that occur with volume expansion or sweep behavior.

[image]https://www.tradingview.com/x/RudytgHy/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Pivot Structure[/b]
Pivot highs and lows are confirmed using configurable left and right bars. Once confirmed, pivots are classified into structural context such as higher high, higher low, lower high, or lower low.

[b]2. Volume Confirmation[/b]
Breakout states are scored using volume relative to a moving average. Expansion volume strengthens breakout quality, while quiet volume can mark compression.

[b]3. Sweep and Reclaim Behavior[/b]
The script detects when price probes beyond a prior swing and then reclaims or rejects the level. This helps separate liquidity sweeps from clean breakouts.

[b]4. Retest Logic[/b]
After a structural break, retest behavior can support continuation when price returns to the broken area and holds.

[b]5. Entry and Exit Rails[/b]
Confirmed breakout or sweep states can draw entry, stop, TP1, and TP2 references using ATR and structure.

[b]Features[/b]

[list]
[*][b]Confirmed HH/HL/LH/LL structure:[/b] Pivots are classified after confirmation.
[*][b]Volume-backed breakouts:[/b] Break quality is strengthened by relative volume expansion.
[*][b]Sweep reclaim/reject states:[/b] Identifies failed breaks beyond prior swing levels.
[*][b]Inside compression detection:[/b] Detects quiet, compressed conditions.
[*][b]Supply/demand zones:[/b] Optional zones around important swing areas.
[*][b]Entry/exit rails:[/b] Optional risk references for accepted states.
[*][b]Candle tinting:[/b] Bars can reflect current structure state.
[*][b]HUD:[/b] Shows state, bias, pivot class, volume, nearest support/resistance, score, and bar counts.
[*][b]Alerts:[/b] Long breakout, short breakout, bullish sweep, bearish sweep, inside compression, and volume expansion.
[/list]

[b]Input Parameters[/b]

[b]Structure:[/b] Pivot Left, Pivot Right, ATR Length, Zone ATR Thickness, Zone Extension Bars.

[b]Volume and Signals:[/b] Volume Average Length, Expansion Multiplier, Quiet Compression Threshold, Minimum Breakout Score, State Cooldown Bars.

[b]Risk and Visuals:[/b] Stop ATR Buffer, TP1 R, TP2 R, Rail Projection Bars, Tint Candles by State, Connect Confirmed Swings, Show Supply/Demand Zones, Pivot Labels, Active Support/Resistance, Structure HUD.

[b]How to Use This Indicator[/b]

[b]Step 1: Read structure bias[/b]
Use the HUD and swing context to identify whether structure is improving, deteriorating, or balanced.

[b]Step 2: Separate breakouts from sweeps[/b]
A breakout shows acceptance beyond structure. A sweep shows a probe and rejection or reclaim. These are different conditions.

[b]Step 3: Check volume[/b]
Volume expansion can increase the importance of a break. Quiet volume can identify compression or lower-conviction movement.

[b]Indicator Limitations[/b]

[list]
[*]Pivots confirm only after the configured right bars complete.
[*]Volume confirmation depends on the quality of the symbol's volume feed.
[*]Supply/demand zones are approximations around swing areas, not exact order book data.
[*]Breakout and sweep states can fail during high-volatility reversals.
[/list]

[b]Originality Statement[/b]

Swing Volume Structure is original in how it combines confirmed pivot classification, volume expansion scoring, sweep/reclaim logic, retests, compression states, optional zones, candle states, and ATR risk rails into a single structure tool.

[b]Disclaimer[/b]

This script is provided for educational and informational purposes only. It is not financial advice or a trade recommendation. Structure signals are based on historical candles and can fail. Use proper risk management.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Swing Volume Structure [JOAT]", shorttitle="SWV [JOAT]", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=140)

// Swing Volume Structure maps confirmed pivots, volume-backed breakouts,
// sweeps, retests, and structure zones. It is designed to stay non-repainting:
// pivots are confirmed by right bars, and entry states require bar close.

//--------------------------------------------------------------------------
// Institutional palette
//--------------------------------------------------------------------------
bullColor       = color.rgb(48, 214, 189)
bearColor       = color.rgb(236, 92, 140)
controlColor    = color.rgb(82, 185, 255)
volColor        = color.rgb(92, 126, 255)
strongBullColor = color.rgb(114, 255, 188)
strongBearColor = color.rgb(255, 96, 180)
neutralColor    = color.rgb(143, 152, 171)
darkPanel       = color.rgb(10, 14, 20)
darkCell        = color.rgb(24, 28, 36)
hudBg           = color.new(darkPanel, 12)
hudBorder       = color.new(color.rgb(56, 64, 82), 38)

//--------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------
groupStructure = "Structure"
pivotLeft = input.int(5, "Pivot left", minval=1, group=groupStructure)
pivotRight = input.int(5, "Pivot right", minval=1, group=groupStructure)
atrLen = input.int(14, "ATR length", minval=2, group=groupStructure)
zoneAtrMult = input.float(0.28, "Zone ATR thickness", minval=0.05, maxval=1.5, step=0.05, group=groupStructure)
zoneBars = input.int(42, "Zone extension bars", minval=20, maxval=500, group=groupStructure)

groupVolume = "Volume"
volLen = input.int(30, "Volume average length", minval=2, group=groupVolume)
volExpansionMult = input.float(1.35, "Expansion multiplier", minval=1.0, step=0.05, group=groupVolume)
quietVolMult = input.float(0.75, "Quiet compression threshold", minval=0.2, maxval=1.2, step=0.05, group=groupVolume)

groupSignals = "Signals"
minBreakScore = input.int(72, "Minimum breakout score", minval=30, maxval=95, group=groupSignals)
showStateLabels = input.bool(true, "Show state labels", group=groupSignals)
showEntryRails = input.bool(true, "Show entry/exit rails", group=groupSignals)
cooldownBars = input.int(16, "State cooldown bars", minval=0, maxval=80, group=groupSignals)

groupRisk = "Risk"
stopAtrBuffer = input.float(0.45, "Stop ATR buffer", minval=0.05, step=0.05, group=groupRisk)
tpOneR = input.float(1.0, "TP1 R multiple", minval=0.25, step=0.25, group=groupRisk)
tpTwoR = input.float(1.45, "TP2 R multiple", minval=0.5, step=0.25, group=groupRisk)
railBars = input.int(20, "Rail projection bars", minval=6, maxval=120, group=groupRisk)

groupVisual = "Visuals"
showCandleTint = input.bool(true, "Tint candles by state", group=groupVisual)
showSwingLines = input.bool(false, "Connect confirmed swings", group=groupVisual)
showZones = input.bool(false, "Show supply/demand zones", group=groupVisual)
showPivotLabels = input.bool(false, "Show compact pivot labels", group=groupVisual)
showControlLines = input.bool(false, "Show active support/resistance", group=groupVisual)
showCompressionLabels = input.bool(false, "Show compression labels", group=groupVisual)

groupHud = "Dashboard"
showHud = input.bool(true, "Show Structure HUD", group=groupHud)
hudSizeInput = input.string("Small", "HUD size", options=["Tiny", "Small", "Normal"], group=groupHud)

groupPerf = "Performance"
maxSwingLabels = input.int(32, "Maximum labels", minval=20, maxval=250, group=groupPerf)
maxSwingLines = input.int(40, "Maximum swing lines", minval=20, maxval=240, group=groupPerf)
maxZones = input.int(16, "Maximum zones", minval=10, maxval=100, group=groupPerf)
maxRails = input.int(40, "Maximum rails", minval=20, maxval=200, group=groupPerf)

//--------------------------------------------------------------------------
// Utility functions
//--------------------------------------------------------------------------
f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_size(string choice) =>
    choice == "Tiny" ? size.tiny : choice == "Normal" ? size.normal : size.small

f_high_class(float current, float previous) =>
    na(previous) ? "H" : current > previous ? "HH" : "LH"

f_low_class(float current, float previous) =>
    na(previous) ? "L" : current > previous ? "HL" : "LL"

f_trim_labels(array<label> store, int maxCount) =>
    while array.size(store) > maxCount
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_trim_lines(array<line> store, int maxCount) =>
    while array.size(store) > maxCount
        line oldLine = array.shift(store)
        line.delete(oldLine)

f_trim_boxes(array<box> store, int maxCount) =>
    while array.size(store) > maxCount
        box oldBox = array.shift(store)
        box.delete(oldBox)

f_new_rail(array<line> store, int startBar, float price, int endBar, color railColor, string railStyle, int railWidth) =>
    line rail = line.new(startBar, price, endBar, price, xloc=xloc.bar_index, extend=extend.none, color=railColor, style=railStyle, width=railWidth)
    array.push(store, rail)

f_strength_color(int direction, float score) =>
    blend = f_clamp((score - 35.0) / 65.0, 0.0, 1.0)
    direction == 1 ? color.from_gradient(blend, 0.0, 1.0, bullColor, strongBullColor) :
     direction == -1 ? color.from_gradient(blend, 0.0, 1.0, bearColor, strongBearColor) :
     color.from_gradient(blend, 0.0, 1.0, neutralColor, controlColor)

//--------------------------------------------------------------------------
// Pivot and swing state engine
//--------------------------------------------------------------------------
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
volRatio = volAvg > 0.0 ? volume / volAvg : 1.0
volumeExpansion = volRatio >= volExpansionMult
quietVolume = volRatio <= quietVolMult

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var float previousHighPivot = na
var float previousLowPivot = na
var float lastHighPivot = na
var float lastLowPivot = na
var int lastHighBar = na
var int lastLowBar = na
var float lastPivotPrice = na
var int lastPivotBar = na
var int lastPivotType = 0
var string lastHighClass = "H"
var string lastLowClass = "L"

var float activeSwingVolume = 0.0
var float priorSwingVolume = na
activeSwingVolume += nz(volume)

var array<label> structureLabels = array.new<label>()
var array<line> swingLines = array.new<line>()
var array<box> structureZones = array.new<box>()
var array<line> entryRails = array.new<line>()
var array<box> entryBoxes = array.new<box>()

newPivot = false
newPivotType = 0
float newPivotPrice = na
int newPivotBar = na

if not na(ph)
    pivotBar = bar_index - pivotRight
    pivotPrice = ph
    pivotClass = f_high_class(pivotPrice, previousHighPivot)
    previousHighPivot := pivotPrice
    lastHighPivot := pivotPrice
    lastHighBar := pivotBar
    lastHighClass := pivotClass
    newPivot := true
    newPivotType := 1
    newPivotPrice := pivotPrice
    newPivotBar := pivotBar
    priorSwingVolume := activeSwingVolume
    activeSwingVolume := 0.0
    if showSwingLines and not na(lastPivotPrice)
        line swingLine = line.new(lastPivotBar, lastPivotPrice, pivotBar, pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(volColor, 35), width=2)
        array.push(swingLines, swingLine)
    if showPivotLabels
        label highLabel = label.new(pivotBar, pivotPrice + atr * 0.08, pivotClass, xloc=xloc.bar_index, style=label.style_label_down, color=color.new(bearColor, 12), textcolor=color.white, size=size.tiny)
        array.push(structureLabels, highLabel)
    if showZones
        zoneTop = pivotPrice + atr * zoneAtrMult
        zoneBottom = pivotPrice - atr * zoneAtrMult
        box supply = box.new(pivotBar, zoneTop, bar_index + zoneBars, zoneBottom, xloc=xloc.bar_index, border_color=color.new(bearColor, 45), bgcolor=color.new(bearColor, 90))
        array.push(structureZones, supply)

if not na(pl)
    pivotBar = bar_index - pivotRight
    pivotPrice = pl
    pivotClass = f_low_class(pivotPrice, previousLowPivot)
    previousLowPivot := pivotPrice
    lastLowPivot := pivotPrice
    lastLowBar := pivotBar
    lastLowClass := pivotClass
    newPivot := true
    newPivotType := -1
    newPivotPrice := pivotPrice
    newPivotBar := pivotBar
    priorSwingVolume := activeSwingVolume
    activeSwingVolume := 0.0
    if showSwingLines and not na(lastPivotPrice)
        line swingLine = line.new(lastPivotBar, lastPivotPrice, pivotBar, pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=color.new(volColor, 35), width=2)
        array.push(swingLines, swingLine)
    if showPivotLabels
        label lowLabel = label.new(pivotBar, pivotPrice - atr * 0.08, pivotClass, xloc=xloc.bar_index, style=label.style_label_up, color=color.new(bullColor, 12), textcolor=color.white, size=size.tiny)
        array.push(structureLabels, lowLabel)
    if showZones
        zoneTop = pivotPrice + atr * zoneAtrMult
        zoneBottom = pivotPrice - atr * zoneAtrMult
        box demand = box.new(pivotBar, zoneTop, bar_index + zoneBars, zoneBottom, xloc=xloc.bar_index, border_color=color.new(bullColor, 45), bgcolor=color.new(bullColor, 90))
        array.push(structureZones, demand)

if newPivot
    lastPivotPrice := newPivotPrice
    lastPivotBar := newPivotBar
    lastPivotType := newPivotType

if array.size(structureZones) > 0
    for i = 0 to array.size(structureZones) - 1
        box activeZone = array.get(structureZones, i)
        box.set_right(activeZone, bar_index + zoneBars)

f_trim_labels(structureLabels, maxSwingLabels)
f_trim_lines(swingLines, maxSwingLines)
f_trim_boxes(structureZones, maxZones)

//--------------------------------------------------------------------------
// Breakout, sweep, retest, and compression states
//--------------------------------------------------------------------------
body = math.abs(close - open)
barRange = math.max(high - low, syminfo.mintick)
closePos = (close - low) / barRange
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

breakHigh = barstate.isconfirmed and not na(lastHighPivot) and close > lastHighPivot and close[1] <= lastHighPivot
breakLow = barstate.isconfirmed and not na(lastLowPivot) and close < lastLowPivot and close[1] >= lastLowPivot
sweepHigh = barstate.isconfirmed and not na(lastHighPivot) and high > lastHighPivot and close < lastHighPivot and upperWick > body * 1.2
sweepLow = barstate.isconfirmed and not na(lastLowPivot) and low < lastLowPivot and close > lastLowPivot and lowerWick > body * 1.2
retestHigh = barstate.isconfirmed and not na(lastHighPivot) and low <= lastHighPivot and close > lastHighPivot and close[1] > lastHighPivot
retestLow = barstate.isconfirmed and not na(lastLowPivot) and high >= lastLowPivot and close < lastLowPivot and close[1] < lastLowPivot
insideCompression = barstate.isconfirmed and high < high[1] and low > low[1] and quietVolume

rangeAvg = ta.sma(high - low, 20)
volatilityCompression = rangeAvg > 0.0 and barRange / rangeAvg < 0.72 and quietVolume
expansionCandleUp = close > open and closePos >= 0.72 and body / barRange >= 0.48
expansionCandleDn = close < open and closePos <= 0.28 and body / barRange >= 0.48

breakScoreBull = 25.0
breakScoreBull += breakHigh ? 24.0 : 0.0
breakScoreBull += retestHigh ? 18.0 : 0.0
breakScoreBull += volumeExpansion ? 18.0 : 0.0
breakScoreBull += expansionCandleUp ? 13.0 : 0.0
breakScoreBull += lastLowClass == "HL" ? 10.0 : 0.0
breakScoreBull += priorSwingVolume > nz(priorSwingVolume[1], priorSwingVolume) ? 5.0 : 0.0

breakScoreBear = 25.0
breakScoreBear += breakLow ? 24.0 : 0.0
breakScoreBear += retestLow ? 18.0 : 0.0
breakScoreBear += volumeExpansion ? 18.0 : 0.0
breakScoreBear += expansionCandleDn ? 13.0 : 0.0
breakScoreBear += lastHighClass == "LH" ? 10.0 : 0.0
breakScoreBear += priorSwingVolume > nz(priorSwingVolume[1], priorSwingVolume) ? 5.0 : 0.0

sweepScoreBull = 38.0 + (sweepLow ? 25.0 : 0.0) + (volumeExpansion ? 12.0 : 0.0) + (closePos > 0.62 ? 10.0 : 0.0)
sweepScoreBear = 38.0 + (sweepHigh ? 25.0 : 0.0) + (volumeExpansion ? 12.0 : 0.0) + (closePos < 0.38 ? 10.0 : 0.0)

var int lastStateBar = na
cooldownReady = na(lastStateBar) or bar_index - lastStateBar > cooldownBars

longBreakState = barstate.isconfirmed and cooldownReady and (breakHigh or retestHigh) and breakScoreBull >= minBreakScore
shortBreakState = barstate.isconfirmed and cooldownReady and (breakLow or retestLow) and breakScoreBear >= minBreakScore
longSweepState = barstate.isconfirmed and cooldownReady and sweepLow and sweepScoreBull >= minBreakScore
shortSweepState = barstate.isconfirmed and cooldownReady and sweepHigh and sweepScoreBear >= minBreakScore

if longBreakState or shortBreakState or longSweepState or shortSweepState
    lastStateBar := bar_index

activeDir = longBreakState or longSweepState ? 1 : shortBreakState or shortSweepState ? -1 : 0
activeScore = longBreakState ? breakScoreBull : shortBreakState ? breakScoreBear : longSweepState ? sweepScoreBull : shortSweepState ? sweepScoreBear : math.max(breakScoreBull, breakScoreBear)
stateText =
     longBreakState ? "BULL BREAK" :
     shortBreakState ? "BEAR BREAK" :
     longSweepState ? "BULL SWEEP" :
     shortSweepState ? "BEAR SWEEP" :
     insideCompression ? "INSIDE QUIET" :
     volatilityCompression ? "COMPRESS" :
     volumeExpansion ? "VOL EXPAND" :
     "BALANCED"

stateColor =
     activeDir == 1 ? f_strength_color(1, activeScore) :
     activeDir == -1 ? f_strength_color(-1, activeScore) :
     insideCompression or volatilityCompression ? controlColor :
     volumeExpansion ? volColor :
     neutralColor

//--------------------------------------------------------------------------
// Entry/exit rails and state labels
//--------------------------------------------------------------------------
longStop = math.min(nz(lastLowPivot, low), low) - atr * stopAtrBuffer
shortStop = math.max(nz(lastHighPivot, high), high) + atr * stopAtrBuffer
longRisk = math.max(close - longStop, syminfo.mintick)
shortRisk = math.max(shortStop - close, syminfo.mintick)
longTp1 = close + longRisk * tpOneR
longTp2 = close + longRisk * tpTwoR
shortTp1 = close - shortRisk * tpOneR
shortTp2 = close - shortRisk * tpTwoR

if activeDir != 0 and showEntryRails
    railEnd = bar_index + railBars
    railColor = activeDir == 1 ? bullColor : bearColor
    stopPrice = activeDir == 1 ? longStop : shortStop
    tpTwoPrice = activeDir == 1 ? longTp2 : shortTp2
    rewardTop = math.max(close, tpTwoPrice)
    rewardBottom = math.min(close, tpTwoPrice)
    riskTop = math.max(close, stopPrice)
    riskBottom = math.min(close, stopPrice)
    array.push(entryBoxes, box.new(bar_index, rewardTop, railEnd, rewardBottom, xloc=xloc.bar_index, border_color=color.new(strongBullColor, 18), bgcolor=color.new(strongBullColor, 88)))
    array.push(entryBoxes, box.new(bar_index, riskTop, railEnd, riskBottom, xloc=xloc.bar_index, border_color=color.new(strongBearColor, 18), bgcolor=color.new(strongBearColor, 88)))
    f_new_rail(entryRails, bar_index, close, railEnd, color.new(color.white, 2), line.style_solid, 2)
    f_new_rail(entryRails, bar_index, activeDir == 1 ? longStop : shortStop, railEnd, color.new(activeDir == 1 ? bearColor : bullColor, 5), line.style_solid, 2)
    f_new_rail(entryRails, bar_index, activeDir == 1 ? longTp1 : shortTp1, railEnd, color.new(railColor, 14), line.style_solid, 1)
    f_new_rail(entryRails, bar_index, activeDir == 1 ? longTp2 : shortTp2, railEnd, color.new(strongBullColor, 0), line.style_solid, 2)

if activeDir != 0 and showStateLabels
    railEnd = bar_index + railBars
    stopPrice = activeDir == 1 ? longStop : shortStop
    tpOnePrice = activeDir == 1 ? longTp1 : shortTp1
    tpTwoPrice = activeDir == 1 ? longTp2 : shortTp2
    labelText = (activeDir == 1 ? "BUY STRUCTURE" : "SELL STRUCTURE") + "\n" + stateText + "\nQ " + str.tostring(math.round(activeScore)) + "\nEntry " + str.tostring(close, format.mintick) + "\nStop " + str.tostring(stopPrice, format.mintick) + "\nTP1 " + str.tostring(tpOnePrice, format.mintick) + "\nTP2 " + str.tostring(tpTwoPrice, format.mintick)
    label stateLabel = label.new(railEnd, close, labelText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(stateColor, 8), textcolor=color.white, size=size.small)
    array.push(structureLabels, stateLabel)

if (insideCompression or volatilityCompression) and showStateLabels and showCompressionLabels and cooldownReady
    label quietLabel = label.new(bar_index, close, "COMPRESS", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(controlColor, 50), textcolor=color.white, size=size.tiny)
    array.push(structureLabels, quietLabel)

f_trim_labels(structureLabels, maxSwingLabels)
f_trim_lines(entryRails, maxRails)
f_trim_boxes(entryBoxes, int(maxRails / 2))

//--------------------------------------------------------------------------
// Visual rendering
//--------------------------------------------------------------------------
barcolor(showCandleTint ? color.new(stateColor, activeDir == 0 ? 38 : 0) : na)

resPlot = plot(showControlLines ? lastHighPivot : na, "Active resistance", color=color.new(bearColor, 35), linewidth=2, style=plot.style_linebr)
supPlot = plot(showControlLines ? lastLowPivot : na, "Active support", color=color.new(bullColor, 35), linewidth=2, style=plot.style_linebr)
fill(resPlot, supPlot, color=showControlLines ? color.new(volColor, 96) : na, title="Structure field")

plot(showControlLines and not na(lastHighPivot) ? lastHighPivot + atr * zoneAtrMult : na, "Resistance glow", color=color.new(bearColor, 85), linewidth=5, style=plot.style_linebr)
plot(showControlLines and not na(lastLowPivot) ? lastLowPivot - atr * zoneAtrMult : na, "Support glow", color=color.new(bullColor, 85), linewidth=5, style=plot.style_linebr)

//--------------------------------------------------------------------------
// HUD
//--------------------------------------------------------------------------
barsSinceHigh = na(lastHighBar) ? na : bar_index - lastHighBar
barsSinceLow = na(lastLowBar) ? na : bar_index - lastLowBar
nearestText = na(lastHighPivot) or na(lastLowPivot) ? "BUILDING" : math.abs(close - lastHighPivot) < math.abs(close - lastLowPivot) ? "RESISTANCE" : "SUPPORT"
structureBias = lastHighClass == "HH" and lastLowClass == "HL" ? "UP LADDER" : lastHighClass == "LH" and lastLowClass == "LL" ? "DOWN LADDER" : "MIXED"

var table structureHud = table.new(position.top_right, 2, 8, frame_color=hudBorder, border_color=hudBorder, bgcolor=hudBg)

if barstate.islast and showHud
    table.cell(structureHud, 0, 0, "SWING VOLUME", text_color=color.white, bgcolor=color.new(controlColor, 60), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 0, "JOAT", text_color=color.white, bgcolor=color.new(volColor, 70), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 1, "State", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 1, stateText, text_color=stateColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 2, "Bias", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 2, structureBias, text_color=structureBias == "UP LADDER" ? bullColor : structureBias == "DOWN LADDER" ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 3, "Pivot class", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 3, lastHighClass + " / " + lastLowClass, text_color=stateColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 4, "Volume", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 4, str.tostring(volRatio, format.mintick) + "x", text_color=volumeExpansion ? controlColor : quietVolume ? neutralColor : color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 5, "Nearest", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 5, nearestText, text_color=nearestText == "SUPPORT" ? bullColor : nearestText == "RESISTANCE" ? bearColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 6, "Score", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 6, str.tostring(math.round(activeScore)), text_color=activeScore >= minBreakScore ? stateColor : neutralColor, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 0, 7, "Bars H/L", text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))
    table.cell(structureHud, 1, 7, (na(barsSinceHigh) ? "na" : str.tostring(barsSinceHigh)) + " / " + (na(barsSinceLow) ? "na" : str.tostring(barsSinceLow)), text_color=color.white, bgcolor=color.new(darkCell, 0), text_size=f_size(hudSizeInput))

//--------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------
alertcondition(longBreakState, "SWV long breakout", "Swing Volume Structure [JOAT] confirmed a bullish breakout or retest.")
alertcondition(shortBreakState, "SWV short breakout", "Swing Volume Structure [JOAT] confirmed a bearish breakout or retest.")
alertcondition(longSweepState, "SWV bullish sweep", "Swing Volume Structure [JOAT] confirmed a bullish sweep reclaim.")
alertcondition(shortSweepState, "SWV bearish sweep", "Swing Volume Structure [JOAT] confirmed a bearish sweep reject.")
alertcondition(insideCompression, "SWV inside compression", "Swing Volume Structure [JOAT] detected quiet inside compression.")
alertcondition(volumeExpansion, "SWV volume expansion", "Swing Volume Structure [JOAT] detected volume expansion.")
````

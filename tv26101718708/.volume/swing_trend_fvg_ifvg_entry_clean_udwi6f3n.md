# Swing Trend FVG / IFVG Entry Clean

- url: https://www.tradingview.com/script/uDWI6F3N-Swing-Trend-FVG-IFVG-Entry-Clean/
- type: indicator
- pine_id: PUB;b5ff9f9be1f346a09247d566f338584e
- version: 1.0

## Description

Swing Trend FVG / IFVG Entry Clean
Swing Trend FVG / IFVG Entry Clean is a structure-based entry indicator designed to identify higher-quality setups using true swing points, trend context, and Fair Value Gaps (FVGs) / Inverse Fair Value Gaps (IFVGs).

The goal of this tool is not to generate more signals - it is built to generate better signals by requiring price to show:

a valid swing start
directional structure
displacement
a meaningful imbalance zone
and a qualified entry condition
This makes it best suited for traders who want cleaner continuation and reversal-style entries inside structured price action, rather than random signals in chop.

How the indicator works
The indicator follows a structured sequence:

Find a swing start
Check trend context
Wait for displacement
Require an FVG or IFVG
Only then allow an entry
Optionally wait for a retest
If there is no Fair Value Gap or Inverse Fair Value Gap, there is no signal.

Core logic
1) Swing-start detection
The indicator can detect swing starts using:

5-Candle Pivot
2-Candle Reversal
Both
A swing start is designed to identify the beginning of a meaningful move rather than a random candle in the middle of consolidation.

5-Candle Pivot
This is the stronger, more classic pivot model.

A bullish pivot is formed when the center candle makes the lowest low relative to the 2 candles on each side.
A bearish pivot is formed when the center candle makes the highest high relative to the 2 candles on each side.
This creates the V-shape or inverted V-shape structure that often marks a true swing.

2-Candle Reversal
This is the faster swing model.

A bullish 2-candle swing looks for a strong rejection wick followed by a stronger confirmation candle.
A bearish 2-candle swing does the opposite.
This can help catch earlier reversals before a full 5-candle pivot is confirmed.

Optional sweep filter
You can also require the swing to sweep a prior pivot, which can help remove weaker starts and focus on more meaningful liquidity grabs.

2) Trend filter
The indicator includes a trend filter that can be turned on or off.

Available modes:

Off
EMA Only
Structure Only
EMA + Structure
This allows the indicator to work either:

as a stricter trend-following tool
or as a more flexible structure-only tool
EMA trend logic
Bullish trend:

price above fast EMA
fast EMA above slow EMA
Bearish trend:

price below fast EMA
fast EMA below slow EMA
Structure trend logic
The indicator also uses hidden market structure logic without drawing trendlines on the chart.

Available structure strength modes:

2-Point
3-Point
Both
2-Point structure
Faster trend confirmation using the most recent pivots.

3-Point structure
Stronger trend confirmation using a more developed sequence of pivots.

Both
This is the strictest option and is designed for traders who want better filtering, not more setups.

3) Displacement requirement
After a valid swing start, price must show displacement.

This is measured using ATR-based expansion, so the indicator only accepts moves that have enough strength to suggest real momentum rather than drift.

If the move does not show enough displacement, the setup is ignored.

4) Fair Value Gap and Inverse Fair Value Gap logic
This indicator focuses only on:

FVG
IFVG
FVG
A standard Fair Value Gap is created when price leaves an imbalance between candles.

IFVG
An Inverse Fair Value Gap is formed when a previously respected FVG is invalidated and flips role:

a broken bearish FVG can become a bullish IFVG
a broken bullish FVG can become a bearish IFVG
This lets the indicator work with both fresh imbalances and flipped imbalance zones.

5) Minimum zone size filter
The indicator lets you define the minimum size of the FVG / IFVG in ticks.

This is important because:

larger gaps often reflect stronger momentum
smaller gaps are more likely to be noise
If the FVG or IFVG is too small, the setup is ignored.

This helps improve quality by avoiding weak zones.

6) Entry mode
You can choose between two entry models:

Gap Close
As soon as the candle closes and creates the FVG or IFVG, the signal can trigger immediately.

This is the more aggressive entry style and is useful when strong momentum often continues without a clean retest.

Retest
The indicator waits for price to return into the FVG / IFVG zone before signaling.

This is the more conservative entry style and can offer cleaner risk placement.

Optional refined-half retest
You can also require price to retest deeper into the zone, including the Consequent Encroachment (CE) midpoint region.

Visual features
The indicator can display:

Bullish and bearish zones
CE midpoint lines
Start markers
Entry signals
Zone labels (FVG / IFVG)
You can customize:

bull zone color
bear zone color
CE line colors
start marker style
start marker text
start marker size
bull / bear start marker colors
entry label size
zone extension length
This makes it easy to keep the chart clean while still showing the key structure.

Suggested settings
These are good starting settings if your goal is better signals, not more signals.

Conservative trend-following setup
Swing Detection Mode: 5-Candle Pivot
Require Sweep Of Prior Pivot: Off to start, then test On
Trend Filter: On
Trend Mode: EMA + Structure
Structure Strength: 3-Point
Min Displacement ATR x: 0.6
Use FVG: On
Use IFVG: On
Minimum FVG Size In Ticks: 8
Minimum IFVG Size In Ticks: 8
Entry Mode: Gap Close
Use CE Midpoint: On
Retest Must Reach Refined Half: Off
Use Volume Confirmation: On
Volume > Average x: 1.0 to 1.2
Stricter filtering
If you want even fewer but stronger setups:

Structure Strength: Both
Require Sweep Of Prior Pivot: On
Entry Mode: Retest
Faster detection
If you want earlier starts:

Swing Detection Mode: Both
Best use case
This indicator is best used for traders who want to identify:

structured swing starts
momentum-based imbalances
FVG / IFVG continuation or reversal-style entries
cleaner setups inside trend context
It is especially useful for traders who like combining:

swing structure
displacement
imbalance zones
retest logic
momentum filtering
Notes
3-Point structure is generally stronger than 2-point structure.
Both structure mode is the strictest and may reduce signal count significantly.
Gap Close mode is more aggressive.
Retest mode is more selective.
Small FVGs and IFVGs are filtered out using tick-size thresholds, which can help avoid weaker zones.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator("Swing Trend FVG / IFVG Entry Clean", overlay=true, max_boxes_count=300, max_labels_count=300, max_lines_count=300)
//====================================================
// INPUTS
//====================================================
grpSwing = "Swing Start"
swingMode = input.string("5-Candle Pivot", "Swing Detection Mode", options=["5-Candle Pivot", "2-Candle Reversal", "Both"], group=grpSwing)
requirePivotSweep = input.bool(false, "Require Sweep Of Prior Pivot", group=grpSwing)
useHammerFilter = input.bool(true, "Use Hammer / Rejection Filter", group=grpSwing)
useDojiFilter = input.bool(true, "Use Doji Filter", group=grpSwing)
wickBodyRatio = input.float(2.0, "Wick / Body Ratio", minval=0.5, step=0.25, group=grpSwing)
dojiMaxPct = input.float(0.10, "Doji Max Body %", minval=0.01, maxval=0.50, step=0.01, group=grpSwing)
grpTrend = "Trend Filter"
useTrendFilter = input.bool(true, "Use Trend Filter", group=grpTrend)
trendFilterMode = input.string("EMA + Structure", "Trend Mode", options=["Off", "EMA Only", "Structure Only", "EMA + Structure"], group=grpTrend)
structureMode = input.string("3-Point", "Structure Strength", options=["2-Point", "3-Point", "Both"], group=grpTrend)
fastLen = input.int(20, "Fast EMA", minval=1, group=grpTrend)
slowLen = input.int(50, "Slow EMA", minval=2, group=grpTrend)
grpImpulse = "Displacement"
minImpulseATR = input.float(0.60, "Min Displacement ATR x", minval=0.1, step=0.1, group=grpImpulse)
grpZones = "Zones"
useFVG = input.bool(true, "Use FVG", group=grpZones)
useIFVG = input.bool(true, "Use IFVG", group=grpZones)
minFVGTicks = input.int(8, "Minimum FVG Size In Ticks", minval=1, group=grpZones)
minIFVGTicks = input.int(8, "Minimum IFVG Size In Ticks", minval=1, group=grpZones)
extendBars = input.int(80, "Zone Extend Length", minval=5, maxval=300, group=grpZones)
useCE = input.bool(true, "Use CE Midpoint", group=grpZones)
requireRetestIntoHalf = input.bool(false, "Retest Must Reach Refined Half", group=grpZones)
grpEntry = "Entry"
entryMode = input.string("Gap Close", "Entry Mode", options=["Gap Close", "Retest"], group=grpEntry)
requireCloseOut = input.bool(true, "Require Close Back Out Of Zone In Retest Mode", group=grpEntry)
invalidateOnFullBreak = input.bool(true, "Invalidate On Full Break", group=grpEntry)
setupExpiry = input.int(40, "Setup Expiry Bars", minval=5, maxval=200, group=grpEntry)
grpVolume = "Volume"
useVolumeFilter = input.bool(false, "Use Volume Confirmation", group=grpVolume)
volLen = input.int(20, "Volume Average Length", minval=1, group=grpVolume)
volMult = input.float(1.2, "Volume > Average x", minval=0.1, step=0.1, group=grpVolume)
grpStyle = "Style"
bullZoneColor = input.color(color.new(color.blue, 80), "Bull Zone Color", group=grpStyle)
bearZoneColor = input.color(color.new(color.aqua, 80), "Bear Zone Color", group=grpStyle)
bullSignalColor = input.color(color.lime, "Bull Signal", group=grpStyle)
bearSignalColor = input.color(color.red, "Bear Signal", group=grpStyle)
ceBullColor = input.color(color.blue, "Bull CE Line", group=grpStyle)
ceBearColor = input.color(color.aqua, "Bear CE Line", group=grpStyle)
showStartMarker = input.bool(true, "Show Start Marker", group=grpStyle)
startMarkerStyle = input.string("Arrow", "Start Marker Style", options=["Arrow", "Triangle", "Circle", "Diamond", "Text", "None"], group=grpStyle)
startLabelText = input.string("Start", "Start Marker Text", group=grpStyle)
startBullMarkerColor = input.color(color.new(color.green, 0), "Bull Start Marker Color", group=grpStyle)
startBearMarkerColor = input.color(color.new(color.red, 0), "Bear Start Marker Color", group=grpStyle)
startMarkerSize = input.string("Small", "Start Marker Size", options=["Tiny", "Small", "Normal", "Large"], group=grpStyle)
showZoneLabel = input.bool(true, "Show Zone Label", group=grpStyle)
showCE = input.bool(true, "Show CE Midpoint", group=grpStyle)
entryLabelSize = input.string("Small", "Entry Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpStyle)
//====================================================
// SIZE MAPPING
//====================================================
startPlotSize = size.small
if startMarkerSize == "Tiny"
    startPlotSize := size.tiny
if startMarkerSize == "Small"
    startPlotSize := size.small
if startMarkerSize == "Normal"
    startPlotSize := size.normal
if startMarkerSize == "Large"
    startPlotSize := size.large
entryPlotSize = size.small
if entryLabelSize == "Tiny"
    entryPlotSize := size.tiny
if entryLabelSize == "Small"
    entryPlotSize := size.small
if entryLabelSize == "Normal"
    entryPlotSize := size.normal
if entryLabelSize == "Large"
    entryPlotSize := size.large
//====================================================
// CORE
//====================================================
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
atr = ta.atr(14)
volAvg = ta.sma(volume, volLen)
tickSize = syminfo.mintick
plot(emaFast, "Fast EMA", color=color.yellow)
plot(emaSlow, "Slow EMA", color=color.orange)
emaBull = emaFast > emaSlow and close > emaFast
emaBear = emaFast < emaSlow and close < emaFast
//====================================================
// CANDLE SHAPE
//====================================================
body = math.abs(close - open)
rng = high - low
safeRng = rng > 0 ? rng : tickSize
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closePos = (close - low) / safeRng
bullHammer = lowerWick >= body * wickBodyRatio and upperWick <= body * 0.75 and closePos >= 0.45
bearHammer = upperWick >= body * wickBodyRatio and lowerWick <= body * 0.75 and closePos <= 0.55
isDoji = body / safeRng <= dojiMaxPct
bullCandleFilter = (useHammerFilter and bullHammer) or (useDojiFilter and isDoji)
bearCandleFilter = (useHammerFilter and bearHammer) or (useDojiFilter and isDoji)
//====================================================
// SWING MODELS
//====================================================
// 5-candle pivot
bull5Pivot = false
bear5Pivot = false
if bar_index >= 4
    bull5Pivot := low[2] < low[4] and low[2] < low[3] and low[2] < low[1] and low[2] < low[0]
    bear5Pivot := high[2] > high[4] and high[2] > high[3] and high[2] > high[1] and high[2] > high[0]
bull5Bar = bar_index - 2
bear5Bar = bar_index - 2
bull5Low = low[2]
bear5High = high[2]
// 2-candle reversal
prevBody = math.abs(close[1] - open[1])
prevUpperWick = high[1] - math.max(open[1], close[1])
prevLowerWick = math.min(open[1], close[1]) - low[1]
bull2Pivot = false
bear2Pivot = false
if bar_index >= 1
    bull2Pivot := prevLowerWick >= prevBody * wickBodyRatio and close > open and lowerWick <= body * 0.5
    bear2Pivot := prevUpperWick >= prevBody * wickBodyRatio and close < open and upperWick <= body * 0.5
bull2Bar = bar_index - 1
bear2Bar = bar_index - 1
bull2Low = low[1]
bear2High = high[1]
// sweep logic
var float lastBullPivotLow = na
var float prevBullPivotLow = na
var float lastBearPivotHigh = na
var float prevBearPivotHigh = na
if bull5Pivot
    prevBullPivotLow := lastBullPivotLow
    lastBullPivotLow := bull5Low
if bear5Pivot
    prevBearPivotHigh := lastBearPivotHigh
    lastBearPivotHigh := bear5High
bull5SweepOk = not requirePivotSweep or (not na(prevBullPivotLow) and bull5Low < prevBullPivotLow)
bear5SweepOk = not requirePivotSweep or (not na(prevBearPivotHigh) and bear5High > prevBearPivotHigh)
bull2SweepOk = not requirePivotSweep or (bar_index >= 2 and low[1] < low[2])
bear2SweepOk = not requirePivotSweep or (bar_index >= 2 and high[1] > high[2])
bullStart5 = bull5Pivot and bullCandleFilter[2] and bull5SweepOk
bearStart5 = bear5Pivot and bearCandleFilter[2] and bear5SweepOk
bullStart2 = bull2Pivot and bull2SweepOk
bearStart2 = bear2Pivot and bear2SweepOk
bullStartOk = false
bearStartOk = false
if swingMode == "5-Candle Pivot"
    bullStartOk := bullStart5
    bearStartOk := bearStart5
if swingMode == "2-Candle Reversal"
    bullStartOk := bullStart2
    bearStartOk := bearStart2
if swingMode == "Both"
    bullStartOk := bullStart5 or bullStart2
    bearStartOk := bearStart5 or bearStart2
bullStartBar = bullStart5 ? bull5Bar : bull2Bar
bearStartBar = bearStart5 ? bear5Bar : bear2Bar
bullStartLow = bullStart5 ? bull5Low : bull2Low
bearStartHigh = bearStart5 ? bear5High : bear2High
//====================================================
// STRUCTURE TREND LOGIC
//====================================================
ph = ta.pivothigh(high, 2, 2)
pl = ta.pivotlow(low, 2, 2)
var float ph1 = na
var float ph2 = na
var float ph3 = na
var float pl1 = na
var float pl2 = na
var float pl3 = na
if not na(ph)
    ph3 := ph2
    ph2 := ph1
    ph1 := ph
if not na(pl)
    pl3 := pl2
    pl2 := pl1
    pl1 := pl
bullStruct2 = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 > ph2 and pl1 > pl2
bearStruct2 = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 < ph2 and pl1 < pl2
bullStruct3 = not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2) and not na(pl3) and ph1 > ph2 and ph2 > ph3 and pl1 > pl2 and pl2 > pl3
bearStruct3 = not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2) and not na(pl3) and ph1 < ph2 and ph2 < ph3 and pl1 < pl2 and pl2 < pl3
bullStruct = false
bearStruct = false
if structureMode == "2-Point"
    bullStruct := bullStruct2
    bearStruct := bearStruct2
if structureMode == "3-Point"
    bullStruct := bullStruct3
    bearStruct := bearStruct3
if structureMode == "Both"
    bullStruct := bullStruct2 and bullStruct3
    bearStruct := bearStruct2 and bearStruct3
bullTrendOk = true
bearTrendOk = true
if useTrendFilter and trendFilterMode == "EMA Only"
    bullTrendOk := emaBull
    bearTrendOk := emaBear
if useTrendFilter and trendFilterMode == "Structure Only"
    bullTrendOk := bullStruct
    bearTrendOk := bearStruct
if useTrendFilter and trendFilterMode == "EMA + Structure"
    bullTrendOk := emaBull and bullStruct
    bearTrendOk := emaBear and bearStruct
//====================================================
// DISPLACEMENT
//====================================================
bullImpulse = close > open and (close - open) >= atr * minImpulseATR and close > emaFast
bearImpulse = close < open and (open - close) >= atr * minImpulseATR and close < emaFast
//====================================================
// FVG STORAGE
//====================================================
var float[] fvgTop = array.new_float()
var float[] fvgBot = array.new_float()
var int[] fvgDir = array.new_int()
var bool[] fvgValid = array.new_bool()
f_addFVG(float top_, float bot_, int dir_) =>
    array.push(fvgTop, math.max(top_, bot_))
    array.push(fvgBot, math.min(top_, bot_))
    array.push(fvgDir, dir_)
    array.push(fvgValid, true)
//====================================================
// FVG CREATION
//====================================================
bullFVGTop = low
bullFVGBot = high[2]
bullFVGSizeTicks = (bullFVGTop - bullFVGBot) / tickSize
bullFVG = useFVG and bar_index >= 2 and low > high[2] and bullFVGSizeTicks >= minFVGTicks
bearFVGTop = low[2]
bearFVGBot = high
bearFVGSizeTicks = (bearFVGTop - bearFVGBot) / tickSize
bearFVG = useFVG and bar_index >= 2 and high < low[2] and bearFVGSizeTicks >= minFVGTicks
if bullFVG
    f_addFVG(bullFVGTop, bullFVGBot, 1)
if bearFVG
    f_addFVG(bearFVGTop, bearFVGBot, -1)
//====================================================
// IFVG FLIP DETECTION
//====================================================
var bool bullIFVGNow = false
var bool bearIFVGNow = false
var float bullIFVGTop = na
var float bullIFVGBot = na
var float bearIFVGTop = na
var float bearIFVGBot = na
bullIFVGNow := false
bearIFVGNow := false
fvgCount = array.size(fvgTop)
if useIFVG and fvgCount > 0
    for i = 0 to fvgCount - 1
        if array.get(fvgValid, i)
            zTop = array.get(fvgTop, i)
            zBot = array.get(fvgBot, i)
            zDir = array.get(fvgDir, i)
            zTicks = (zTop - zBot) / tickSize
            if zDir == -1 and close > zTop and zTicks >= minIFVGTicks
                bullIFVGNow := true
                bullIFVGTop := zTop
                bullIFVGBot := zBot
                array.set(fvgValid, i, false)
            if zDir == 1 and close < zBot and zTicks >= minIFVGTicks
                bearIFVGNow := true
                bearIFVGTop := zTop
                bearIFVGBot := zBot
                array.set(fvgValid, i, false)
//====================================================
// SETUP STATE
//====================================================
var bool bullActive = false
var int bullAnchorBar = na
var bool bullZoneReady = false
var float bullZoneTop = na
var float bullZoneBot = na
var int bullZoneKind = 0
var bool bullTouched = false
var bool bullDone = false
var box bullBox = na
var line bullCE = na
var bool bearActive = false
var int bearAnchorBar = na
var bool bearZoneReady = false
var float bearZoneTop = na
var float bearZoneBot = na
var int bearZoneKind = 0
var bool bearTouched = false
var bool bearDone = false
var box bearBox = na
var line bearCE = na
//====================================================
// START OF MOVE
//====================================================
if bullStartOk and bullTrendOk
    bullActive := true
    bullAnchorBar := bullStartBar
    bullZoneReady := false
    bullZoneTop := na
    bullZoneBot := na
    bullZoneKind := 0
    bullTouched := false
    bullDone := false
    if not na(bullBox)
        box.delete(bullBox)
        bullBox := na
    if not na(bullCE)
        line.delete(bullCE)
        bullCE := na
if bearStartOk and bearTrendOk
    bearActive := true
    bearAnchorBar := bearStartBar
    bearZoneReady := false
    bearZoneTop := na
    bearZoneBot := na
    bearZoneKind := 0
    bearTouched := false
    bearDone := false
    if not na(bearBox)
        box.delete(bearBox)
        bearBox := na
    if not na(bearCE)
        line.delete(bearCE)
        bearCE := na
//====================================================
// GAP / IFVG MUST FORM
//====================================================
bullSignal = false
bearSignal = false
if bullActive and not bullZoneReady and bar_index > bullAnchorBar
    if bullImpulse
        bullVolPassNow = not useVolumeFilter or volume > volAvg * volMult
        if bullFVG
            bullZoneTop := bullFVGTop
            bullZoneBot := bullFVGBot
            bullZoneKind := 1
            bullZoneReady := true
        if not bullZoneReady and bullIFVGNow
            bullZoneTop := bullIFVGTop
            bullZoneBot := bullIFVGBot
            bullZoneKind := 2
            bullZoneReady := true
        if bullZoneReady
            bullBox := box.new(bullAnchorBar, bullZoneTop, bar_index + extendBars, bullZoneBot, bgcolor=bullZoneColor, border_color=color.new(bullZoneColor, 0))
            if showCE
                ceBull = (bullZoneTop + bullZoneBot) / 2.0
                bullCE := line.new(bullAnchorBar, ceBull, bar_index + extendBars, ceBull, color=ceBullColor, style=line.style_dotted)
            if entryMode == "Gap Close" and bullVolPassNow
                bullSignal := true
                bullDone := true
                bullActive := false
if bearActive and not bearZoneReady and bar_index > bearAnchorBar
    if bearImpulse
        bearVolPassNow = not useVolumeFilter or volume > volAvg * volMult
        if bearFVG
            bearZoneTop := bearFVGTop
            bearZoneBot := bearFVGBot
            bearZoneKind := 1
            bearZoneReady := true
        if not bearZoneReady and bearIFVGNow
            bearZoneTop := bearIFVGTop
            bearZoneBot := bearIFVGBot
            bearZoneKind := 2
            bearZoneReady := true
        if bearZoneReady
            bearBox := box.new(bearAnchorBar, bearZoneTop, bar_index + extendBars, bearZoneBot, bgcolor=bearZoneColor, border_color=color.new(bearZoneColor, 0))
            if showCE
                ceBear = (bearZoneTop + bearZoneBot) / 2.0
                bearCE := line.new(bearAnchorBar, ceBear, bar_index + extendBars, ceBear, color=ceBearColor, style=line.style_dotted)
            if entryMode == "Gap Close" and bearVolPassNow
                bearSignal := true
                bearDone := true
                bearActive := false
//====================================================
// EXTEND DRAWINGS
//====================================================
if not na(bullBox)
    box.set_right(bullBox, bar_index + extendBars)
if not na(bullCE)
    line.set_x2(bullCE, bar_index + extendBars)
if not na(bearBox)
    box.set_right(bearBox, bar_index + extendBars)
if not na(bearCE)
    line.set_x2(bearCE, bar_index + extendBars)
//====================================================
// RETEST MODE
//====================================================
if entryMode == "Retest"
    if bullActive and bullZoneReady and not bullDone
        bullExpired = (bar_index - bullAnchorBar) > setupExpiry
        bullBroken = low < bullZoneBot and close < bullZoneBot
        if bullExpired or (invalidateOnFullBreak and bullBroken)
            bullActive := false
        else
            ceBull = (bullZoneTop + bullZoneBot) / 2.0
            touchWholeBull = low <= bullZoneTop and high >= bullZoneBot
            touchHalfBull = low <= ceBull and high >= bullZoneBot
            bullTouchPass = requireRetestIntoHalf ? touchHalfBull : touchWholeBull
            if bullTouchPass
                bullTouched := true
            bullVolPass = not useVolumeFilter or volume > volAvg * volMult
            bullCloseOut = not requireCloseOut or close > bullZoneTop
            bullConfirm = close > open and bullCloseOut and bullVolPass
            if bullTouched and bullConfirm
                bullSignal := true
                bullDone := true
                bullActive := false
    if bearActive and bearZoneReady and not bearDone
        bearExpired = (bar_index - bearAnchorBar) > setupExpiry
        bearBroken = high > bearZoneTop and close > bearZoneTop
        if bearExpired or (invalidateOnFullBreak and bearBroken)
            bearActive := false
        else
            ceBear = (bearZoneTop + bearZoneBot) / 2.0
            touchWholeBear = high >= bearZoneBot and low <= bearZoneTop
            touchHalfBear = high >= ceBear and low <= bearZoneTop
            bearTouchPass = requireRetestIntoHalf ? touchHalfBear : touchWholeBear
            if bearTouchPass
                bearTouched := true
            bearVolPass = not useVolumeFilter or volume > volAvg * volMult
            bearCloseOut = not requireCloseOut or close < bearZoneBot
            bearConfirm = close < open and bearCloseOut and bearVolPass
            if bearTouched and bearConfirm
                bearSignal := true
                bearDone := true
                bearActive := false
//====================================================
// START MARKERS
//====================================================
bullStartMarker = bullStartOk and bullTrendOk
bearStartMarker = bearStartOk and bearTrendOk
if showStartMarker and bullStartMarker and startMarkerStyle != "None"
    bullTxt = startMarkerStyle == "Text" ? startLabelText : startMarkerStyle == "Arrow" ? "↑" : startMarkerStyle == "Triangle" ? "▲" : startMarkerStyle == "Circle" ? "●" : "◆"
    label.new(
         bar_index,
         low,
         bullTxt,
         style=label.style_label_up,
         color=startBullMarkerColor,
         textcolor=color.white,
         size=startPlotSize)
if showStartMarker and bearStartMarker and startMarkerStyle != "None"
    bearTxt = startMarkerStyle == "Text" ? startLabelText : startMarkerStyle == "Arrow" ? "↓" : startMarkerStyle == "Triangle" ? "▼" : startMarkerStyle == "Circle" ? "●" : "◆"
    label.new(
         bar_index,
         high,
         bearTxt,
         style=label.style_label_down,
         color=startBearMarkerColor,
         textcolor=color.white,
         size=startPlotSize)
//====================================================
// ZONE LABELS
//====================================================
if showZoneLabel and bullZoneReady and bar_index == bullAnchorBar + 1
    zoneTxtBull = bullZoneKind == 1 ? "FVG" : "IFVG"
    label.new(bar_index, bullZoneBot, zoneTxtBull, style=label.style_label_up, color=color.new(bullZoneColor, 0), textcolor=color.white, size=size.small)
if showZoneLabel and bearZoneReady and bar_index == bearAnchorBar + 1
    zoneTxtBear = bearZoneKind == 1 ? "FVG" : "IFVG"
    label.new(bar_index, bearZoneTop, zoneTxtBear, style=label.style_label_down, color=color.new(bearZoneColor, 0), textcolor=color.white, size=size.small)
//====================================================
// ENTRY SIGNALS
//====================================================
if bullSignal
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=bullSignalColor,
         textcolor=color.white,
         size=entryPlotSize)
if bearSignal
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=bearSignalColor,
         textcolor=color.white,
         size=entryPlotSize)
alertcondition(bullSignal, "Bullish Entry", "Bullish swing -> FVG/IFVG entry")
alertcondition(bearSignal, "Bearish Entry", "Bearish swing -> FVG/IFVG entry")
````

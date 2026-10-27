# Fusion EMA Trend Trade Planner

- url: https://www.tradingview.com/script/wVDedoVm-Fusion-EMA-Trend-Trade-Planner/
- type: indicator
- pine_id: PUB;9c558a67c21848ebb09a5f9fd41e1c44
- version: 3.0

## Description

Fusion EMA Trend Trade Planner

Back to basics.

This tool was built for traders who want a cleaner way to read trend direction, avoid messy chop, and plan risk before entering a trade.

Instead of filling the chart with separate tools for trend, confirmation, filtering, and risk levels, this script combines those steps into one simple workflow.

The goal is not to predict the future.

The goal is to answer four basic questions:

• Is the market trending?
• Is the trend clean or messy?
• Does the broader context support the move?
• Where would entry, stop loss, and take profit levels sit?

━━━━━━━━━━━━━━━━━━━━
🔹 Core Idea
━━━━━━━━━━━━━━━━━━━━

Fusion EMA Trend Trade Planner is built around a simple trend-following process:

1. Find clean EMA structure.
2. Check the 21-period Basis Cloud.
3. Use optional filters if extra confirmation is wanted.
4. Plot a simple risk/reward trade plan.
5. Watch for trend deterioration.

━━━━━━━━━━━━━━━━━━━━
🔹 Fusion EMA Structure
━━━━━━━━━━━━━━━━━━━━

The main trend engine uses four exponential moving averages.

A bullish trend is shown when the EMAs are stacked cleanly:

Fast EMA > Medium EMA > Slow EMA > Anchor EMA

A bearish trend is shown when the EMAs are stacked the opposite way:

Fast EMA < Medium EMA < Slow EMA < Anchor EMA

This is different from a basic two-line crossover.

A single moving average can show direction, but a stacked EMA structure can show both direction and trend quality.

When the EMAs are separated and aligned, the trend structure is cleaner.

When the EMAs compress or cross, the market may be losing structure.

When the structure is mixed, candles can turn grey. This is a visual warning that the trend is no longer clean.

━━━━━━━━━━━━━━━━━━━━
🔹 Fusion Ribbon
━━━━━━━━━━━━━━━━━━━━

The ribbon shows the relationship between the four EMAs.

When the ribbon is clean and expanded, trend structure is stronger.

When the ribbon compresses or turns grey, the market may be entering chop, transition, or weak trend conditions.

This makes it easier for newer traders to visually separate:

• Clean trend
• Weak trend
• Choppy market

━━━━━━━━━━━━━━━━━━━━
🔹 21-Period Basis Cloud
━━━━━━━━━━━━━━━━━━━━

The Basis Cloud is built around a smoothed 21-period basis average.

The number 21 was chosen because it is a Fibonacci number commonly used by trend traders as an intermediate market rhythm.

The cloud also uses a shorter reference average to create a layered visual zone around the basis.

The Basis Cloud is not designed as a simple crossover signal.

Its job is to act as a directional context layer.

In simple terms:

• Green cloud = basis direction is rising
• Red cloud = basis direction is falling

The Fusion EMA Structure and Basis Cloud are calculated separately.

This means traders can compare two different views of the market:

• EMA trend structure
• 21-period basis direction

When both agree, the setup has cleaner directional context.

When they disagree, conditions may be weaker or less clear.

━━━━━━━━━━━━━━━━━━━━
🔹 Higher Timeframe Filter
━━━━━━━━━━━━━━━━━━━━

An optional higher timeframe Fusion EMA can be used for extra context.

This helps traders avoid taking setups that go directly against broader trend structure.

For example:

• Current chart is bullish
• Higher timeframe is also bullish
• Setup has better alignment

This does not guarantee success, but it helps keep trades in line with the bigger picture.

━━━━━━━━━━━━━━━━━━━━
🔹 Optional Quality Filter
━━━━━━━━━━━━━━━━━━━━

The script includes an optional Quality Filter for traders who prefer additional confirmation.

By default, the indicator focuses on Fusion EMA Structure, Basis Cloud direction, and Trade Planning.

For traders who want a more selective approach, the Quality Filter can be enabled to evaluate:

• EMA ribbon expansion
• Price position relative to the Basis Cloud
• Higher timeframe agreement
• ADX trend strength

The filter is not intended to predict win rates or assign confidence scores.

Its purpose is simply to reduce participation during weaker trend conditions.

Many traders may prefer to leave the filter disabled and use Fusion EMA Structure and Basis Cloud alignment alone.

━━━━━━━━━━━━━━━━━━━━
🔹 Trade Planner
━━━━━━━━━━━━━━━━━━━━

When a valid setup appears, the script can draw a full trade plan:

• Entry
• Stop Loss
• TP1
• TP2
• TP3

Stop loss can be calculated using:

• ATR-based stop
• Percentage-based stop

Take-profit levels are based on adjustable risk/reward values.

This helps traders see the risk before entering instead of chasing candles blindly.

The Trade Planner is a visual planning tool only. It does not place trades automatically.

━━━━━━━━━━━━━━━━━━━━
🔹 Grey Exit Marker
━━━━━━━━━━━━━━━━━━━━

If a trade is active and the EMA structure turns grey, the script can print a small X marker.

This means the original clean trend structure has weakened.

It does not mean price must reverse.

It simply means the condition that created the trade setup is no longer clean.

━━━━━━━━━━━━━━━━━━━━
🔹 Suggested Workflow
━━━━━━━━━━━━━━━━━━━━

For a bullish setup:

1. Wait for green candle structure.
2. Check that the ribbon is clean.
3. Check that price is above the Basis Cloud.
4. Use the optional Quality Filter if you want extra confirmation.
5. Use the Trade Planner to review entry, stop loss, and targets.
6. Watch for grey candles or exit markers.

For a bearish setup:

1. Wait for red candle structure.
2. Check that the ribbon is clean.
3. Check that price is below the Basis Cloud.
4. Use the optional Quality Filter if you want extra confirmation.
5. Use the Trade Planner to review entry, stop loss, and targets.
6. Watch for grey candles or exit markers.

━━━━━━━━━━━━━━━━━━━━
🔹 Originality
━━━━━━━━━━━━━━━━━━━━

This script was designed as a complete trend-following workflow, not as a random collection of indicators.

The goal of this script was not to merge unrelated indicators into a single chart.

Each component was selected to perform a specific role within the workflow:

• Fusion EMA Structure identifies trend alignment.
• Fusion Ribbon visualizes trend quality.
• 21-Period Basis Cloud provides directional context.
• Optional Quality Filter helps reduce participation during weaker conditions.
• Trade Planner converts trend conditions into predefined risk levels.
• Grey Exit Marker highlights trend deterioration.

Together, these components form a single trend-analysis and trade-planning process rather than functioning as separate standalone indicators.

The purpose is to move from trend reading to trade planning in one clean process.

━━━━━━━━━━━━━━━━━━━━
🔹 Important Notes
━━━━━━━━━━━━━━━━━━━━

This indicator does not:

• Predict future price movement
• Guarantee profitable trades
• Estimate win probability
• Replace risk management
• Call every top or bottom

It is designed to help traders identify cleaner trend conditions and plan trades more consistently.

Simple idea:

Find the trend.
Check the structure.
Plan the risk.
Do not chase messy candles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("Fusion EMA Trend Trade Planner [NICK789]", shorttitle="Fusion EMA Planner", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupFusion = "Fusion EMA Trend"

useFusion  = input.bool(true, "Enable Fusion Trend", group=groupFusion)
visualMode = input.string("Ribbon", "Visual Mode", options=["Fusion Line", "Ribbon"], group=groupFusion)

len1 = input.int(6,  "EMA 1", minval=1, group=groupFusion)
len2 = input.int(14, "EMA 2", minval=1, group=groupFusion)
len3 = input.int(21, "EMA 3", minval=1, group=groupFusion)
len4 = input.int(34, "EMA 4", minval=1, group=groupFusion)

emaCountMode = input.string("4 EMAs", "EMA Alignment Mode", options=["2 EMAs", "3 EMAs", "4 EMAs"], group=groupFusion)

fusionLineTransp = input.int(65, "Fusion Line Transparency", minval=0, maxval=95, group=groupFusion)
fusionLineWidth  = input.int(2, "Fusion Line Width", minval=1, maxval=5, group=groupFusion)

showBG    = input.bool(false, "Show Background Tint", group=groupFusion)
colorBars = input.bool(true, "Color Bars", group=groupFusion)

groupEntry = "Entry Logic"

entryMode = input.string("Trend Flip", "Entry Mode", options=["Trend Flip", "Flip Retest", "Trend Pullback", "Retest + Pullback"], group=groupEntry)
confirmOnClose = input.bool(true, "Confirm Signals On Bar Close", group=groupEntry)
retestReference = input.string("Basis Cloud", "Retest/Pullback Reference", options=["Fusion EMA", "Basis Line", "Basis Cloud", "Ribbon Edge"], group=groupEntry)
retestToleranceATR = input.float(0.10, "Retest Tolerance ATR", minval=0.0, step=0.01, group=groupEntry)
maxRetestBars = input.int(25, "Max Bars To Wait For Retest", minval=1, maxval=300, group=groupEntry)
allowSameDirectionReEntry = input.bool(false, "Allow Same Direction Re-Entries", group=groupEntry)

groupClean = "Clean Visual Style"

entryMarkerMode   = input.string("Tiny Triangle", "Entry Marker Style", options=["Off", "Tiny Triangle", "Small Triangle", "Text Labels"], group=groupClean)
entryMarkerTransp = input.int(35, "Entry Marker Transparency", minval=0, maxval=95, group=groupClean)

rrLabelMode = input.string("Name + Price", "RR Label Style", options=["Price Only", "Name + Price", "Off"], group=groupClean)
rrTextOffset = input.int(1, "RR Price Text Offset Bars", minval=0, maxval=20, group=groupClean)

groupHTF = "Higher Timeframe Overlay"

useHTF = input.bool(false, "Show HTF Fusion EMA", group=groupHTF)
htfTf  = input.timeframe("5", "Higher Timeframe", group=groupHTF)

groupBasis = "Fusion Basis Cloud"

showBasis      = input.bool(true, "Show Fib Basis Line", group=groupBasis)
showFibCloud   = input.bool(true, "Show Fib Cloud", group=groupBasis)
fibBasisLen    = input.int(21, "Basis Length", minval=1, group=groupBasis)
fibBasisSmooth = input.bool(true, "Double Smooth Basis", group=groupBasis)

fibCloudRefLen = input.int(10, "Cloud Reference Length", minval=1, group=groupBasis)
fibCloudTransp = input.int(62, "Cloud Transparency", minval=0, maxval=95, group=groupBasis)

colUp = input.color(#00ff66, "Bull", group=groupBasis, inline="c1")
colDn = input.color(#ff1744, "Bear", group=groupBasis, inline="c1")

groupFilter = "Entry Quality Filter"

useQualityFilter = input.bool(false, "Use Quality Filter", group=groupFilter)
useHTFFilter      = input.bool(true, "Require HTF Agreement", group=groupFilter)
useADXFilter      = input.bool(true, "Require ADX Strength", group=groupFilter)

adxLen       = input.int(14, "ADX Length", minval=1, group=groupFilter)
adxSmooth    = input.int(14, "ADX Smoothing", minval=1, group=groupFilter)
minADX       = input.float(18.0, "Minimum ADX", minval=1, step=0.5, group=groupFilter)
minRibbonATR = input.float(0.15, "Minimum Ribbon Expansion ATR", minval=0.01, step=0.01, group=groupFilter)

groupPlan = "Trade Plan RR Lines"

showTradePlan      = input.bool(true, "Show Trade Plan", group=groupPlan)
showHistoricalPlan = input.bool(false, "Show Historical RR Plans", group=groupPlan)
showExitX          = input.bool(true, "Show Grey Exit X", group=groupPlan)
exitMode           = input.string("Active Trend Lost", "Exit X Mode", options=["Active Trend Lost", "Full Ribbon Lost", "Opposite Trend"], group=groupPlan)

planExtendBars = input.int(40, "Line Extend Bars", minval=5, maxval=300, group=groupPlan)

stopMode = input.string("ATR", "Stop Mode", options=["ATR", "Percent"], group=groupPlan)
atrLen   = input.int(14, "ATR Length", minval=1, group=groupPlan)
slAtr    = input.float(1.5, "SL ATR Multiplier", minval=0.1, step=0.1, group=groupPlan)
slPct    = input.float(0.5, "SL Percent", minval=0.01, step=0.01, group=groupPlan)

rr1 = input.float(1.0, "TP1 RR", minval=0.1, step=0.1, group=groupPlan)
rr2 = input.float(2.0, "TP2 RR", minval=0.1, step=0.1, group=groupPlan)
rr3 = input.float(3.0, "TP3 RR", minval=0.1, step=0.1, group=groupPlan)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_fusion_bull(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? a > b : mode == "3 EMAs" ? a > b and b > c : a > b and b > c and c > d

f_fusion_bear(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? a < b : mode == "3 EMAs" ? a < b and b < c : a < b and b < c and c < d

f_fusion_avg(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? (a + b) / 2.0 : mode == "3 EMAs" ? (a + b + c) / 3.0 : (a + b + c + d) / 4.0

f_ribbon_expansion(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? math.abs(a - b) : mode == "3 EMAs" ? math.abs(a - c) : math.abs(a - d)

f_active_max(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? math.max(a, b) : mode == "3 EMAs" ? math.max(math.max(a, b), c) : math.max(math.max(a, b), math.max(c, d))

f_active_min(float a, float b, float c, float d, string mode) =>
    mode == "2 EMAs" ? math.min(a, b) : mode == "3 EMAs" ? math.min(math.min(a, b), c) : math.min(math.min(a, b), math.min(c, d))

f_price(float v) =>
    str.tostring(v, format.mintick)

f_rr_live_text(string name, float price, bool hit) =>
    string prefix = hit ? "✓ " : ""
    rrLabelMode == "Off" ? "" :
     rrLabelMode == "Price Only" ? prefix + f_price(price) :
     prefix + name + " " + f_price(price)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUSION EMA STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
ema3 = ta.ema(close, len3)
ema4 = ta.ema(close, len4)

bullTrend = f_fusion_bull(ema1, ema2, ema3, ema4, emaCountMode)
bearTrend = f_fusion_bear(ema1, ema2, ema3, ema4, emaCountMode)
greyTrend = not bullTrend and not bearTrend

bull4 = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bear4 = ema1 < ema2 and ema2 < ema3 and ema3 < ema4

fusionEMA = f_fusion_avg(ema1, ema2, ema3, ema4, emaCountMode)

confirmedBar = not confirmOnClose or barstate.isconfirmed

bullFlip = confirmedBar and bullTrend and not bullTrend[1]
bearFlip = confirmedBar and bearTrend and not bearTrend[1]

fusionColor = bullTrend ? colUp : bearTrend ? colDn : color.gray
ribbonColor = bullTrend ? color.new(colUp, 0) : bearTrend ? color.new(colDn, 0) : color.new(color.gray, 45)

showFusionLine = useFusion and visualMode == "Fusion Line"
showRibbon     = useFusion and visualMode == "Ribbon"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGHER TIMEFRAME STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ema1HTF, ema2HTF, ema3HTF, ema4HTF] = request.security(
     syminfo.tickerid,
     htfTf,
     [ta.ema(close, len1), ta.ema(close, len2), ta.ema(close, len3), ta.ema(close, len4)],
     barmerge.gaps_off,
     barmerge.lookahead_off
)

bullHTF = f_fusion_bull(ema1HTF, ema2HTF, ema3HTF, ema4HTF, emaCountMode)
bearHTF = f_fusion_bear(ema1HTF, ema2HTF, ema3HTF, ema4HTF, emaCountMode)
fusionEMAHTF = f_fusion_avg(ema1HTF, ema2HTF, ema3HTF, ema4HTF, emaCountMode)

bullHTFFlip = confirmedBar and bullHTF and not bullHTF[1]
bearHTFFlip = confirmedBar and bearHTF and not bearHTF[1]

htfColor = bullHTF ? color.new(colUp, 0) : bearHTF ? color.new(colDn, 0) : color.new(color.gray, 75)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIS CLOUD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fibBasis =
     fibBasisSmooth
     ? ta.ema(ta.ema(hlc3, fibBasisLen), fibBasisLen)
     : ta.ema(hlc3, fibBasisLen)

fibRef = ta.ema(hlc3, fibCloudRefLen)

fibBull = fibBasis > fibBasis[1]
fibCloudColor = fibBull ? colUp : colDn

fibCloudA = fibBasis + (fibRef - fibBasis) * 0.25
fibCloudB = fibBasis + (fibRef - fibBasis) * 0.50
fibCloudC = fibBasis + (fibRef - fibBasis) * 0.75

cloudUpper = math.max(fibBasis, fibRef)
cloudLower = math.min(fibBasis, fibRef)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// QUALITY FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
[_, _, adxValue] = ta.dmi(adxLen, adxSmooth)

ribbonExpansion = f_ribbon_expansion(ema1, ema2, ema3, ema4, emaCountMode)
minExpansion    = atr * minRibbonATR

longQuality =
     bullTrend and
     close > open and
     close > fibBasis and
     ribbonExpansion > minExpansion and
     (not useHTFFilter or bullHTF) and
     (not useADXFilter or adxValue >= minADX)

shortQuality =
     bearTrend and
     close < open and
     close < fibBasis and
     ribbonExpansion > minExpansion and
     (not useHTFFilter or bearHTF) and
     (not useADXFilter or adxValue >= minADX)

longPass  = not useQualityFilter or longQuality
shortPass = not useQualityFilter or shortQuality

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showFusionLine ? fusionEMA : na, "Fusion EMA Line", color=color.new(fusionColor, fusionLineTransp), linewidth=fusionLineWidth)

ema3Active = emaCountMode != "2 EMAs"
ema4Active = emaCountMode == "4 EMAs"

p1 = plot(showRibbon ? ema1 : na, "Ribbon EMA 1", color=color.new(ribbonColor, 0), linewidth=1)
p2 = plot(showRibbon ? ema2 : na, "Ribbon EMA 2", color=color.new(ribbonColor, 15), linewidth=1)
p3 = plot(showRibbon ? ema3 : na, "Ribbon EMA 3", color=color.new(ema3Active ? ribbonColor : color.gray, ema3Active ? 30 : 88), linewidth=1)
p4 = plot(showRibbon ? ema4 : na, "Ribbon EMA 4", color=color.new(ema4Active ? ribbonColor : color.gray, ema4Active ? 45 : 88), linewidth=1)

fill(p1, p2, color=showRibbon ? color.new(ribbonColor, 85) : na)
fill(p2, p3, color=showRibbon ? color.new(ema3Active ? ribbonColor : color.gray, ema3Active ? 88 : 95) : na)
fill(p3, p4, color=showRibbon ? color.new(ema4Active ? ribbonColor : color.gray, ema4Active ? 91 : 95) : na)

plot(useHTF ? fusionEMAHTF : na, "Higher TF Fusion EMA", color=htfColor, linewidth=2)

plot(showBasis ? fibBasis : na, "Basis Line", color=color.new(fibCloudColor, 0), linewidth=3)

pFibBasis = plot(showFibCloud ? fibBasis : na, "Cloud Base", color=color.new(chart.fg_color, 100), display=display.none)
pFibA     = plot(showFibCloud ? fibCloudA : na, "Cloud Layer A", color=color.new(chart.fg_color, 100), display=display.none)
pFibB     = plot(showFibCloud ? fibCloudB : na, "Cloud Layer B", color=color.new(chart.fg_color, 100), display=display.none)
pFibC     = plot(showFibCloud ? fibCloudC : na, "Cloud Layer C", color=color.new(chart.fg_color, 100), display=display.none)
pFibRef   = plot(showFibCloud ? fibRef : na, "Cloud Reference", color=color.new(chart.fg_color, 100), display=display.none)

fill(pFibBasis, pFibA, color=showFibCloud ? color.new(fibCloudColor, math.max(0, fibCloudTransp - 18)) : na)
fill(pFibA, pFibB, color=showFibCloud ? color.new(fibCloudColor, math.max(0, fibCloudTransp - 6)) : na)
fill(pFibB, pFibC, color=showFibCloud ? color.new(fibCloudColor, math.min(95, fibCloudTransp + 6)) : na)
fill(pFibC, pFibRef, color=showFibCloud ? color.new(fibCloudColor, math.min(95, fibCloudTransp + 18)) : na)

barColorFinal =
     useFusion and colorBars
     ? bullTrend ? color.new(colUp, 0) :
       bearTrend ? color.new(colDn, 0) :
       color.new(color.gray, 70)
     : na

barcolor(barColorFinal)

bgColor =
     useFusion and showBG
     ? bullTrend ? color.new(colUp, 90) :
       bearTrend ? color.new(colDn, 90) :
       na
     : na

bgcolor(bgColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RETEST / PULLBACK REFERENCES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ribbonUpper = f_active_max(ema1, ema2, ema3, ema4, emaCountMode)
ribbonLower = f_active_min(ema1, ema2, ema3, ema4, emaCountMode)

longRef =
     retestReference == "Fusion EMA"  ? fusionEMA :
     retestReference == "Basis Line"  ? fibBasis :
     retestReference == "Basis Cloud" ? cloudUpper :
     ribbonUpper

shortRef =
     retestReference == "Fusion EMA"  ? fusionEMA :
     retestReference == "Basis Line"  ? fibBasis :
     retestReference == "Basis Cloud" ? cloudLower :
     ribbonLower

retestTolerance = atr * retestToleranceATR

longTouch  = not na(longRef) and low <= longRef + retestTolerance
shortTouch = not na(shortRef) and high >= shortRef - retestTolerance

longReclaim  = longTouch and close > longRef and close > open
shortReclaim = shortTouch and close < shortRef and close < open

useRetestMode =
     entryMode == "Flip Retest" or
     entryMode == "Retest + Pullback"

usePullbackMode =
     entryMode == "Trend Pullback" or
     entryMode == "Retest + Pullback"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RETEST STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int pendingDir = 0
var int pendingBar = na
var bool pendingTouched = false

if not useRetestMode
    pendingDir := 0
    pendingBar := na
    pendingTouched := false

if useRetestMode and bullFlip
    pendingDir := 1
    pendingBar := bar_index
    pendingTouched := false

if useRetestMode and bearFlip
    pendingDir := -1
    pendingBar := bar_index
    pendingTouched := false

pendingActive = pendingDir != 0 and not na(pendingBar)
pendingExpired = pendingActive and bar_index - pendingBar > maxRetestBars

if pendingExpired
    pendingDir := 0
    pendingBar := na
    pendingTouched := false

pendingAfterFlip = pendingDir != 0 and not na(pendingBar) and bar_index > pendingBar

if pendingAfterFlip and pendingDir == 1
    pendingTouched := pendingTouched or longTouch

if pendingAfterFlip and pendingDir == -1
    pendingTouched := pendingTouched or shortTouch

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE PLAN OBJECTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var line tp3Line   = na

var label entryLab = na
var label slLab    = na
var label tp1Lab   = na
var label tp2Lab   = na
var label tp3Lab   = na

var int tradeDir = 0

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit  = false
var bool planClosed = false
var int planEntryBar = na

f_clear_plan() =>
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(entryLab)
    label.delete(slLab)
    label.delete(tp1Lab)
    label.delete(tp2Lab)
    label.delete(tp3Lab)

f_draw_plan(bool isLong, float entry, float stop) =>
    risk = math.max(math.abs(entry - stop), syminfo.mintick)

    take1 = isLong ? entry + risk * rr1 : entry - risk * rr1
    take2 = isLong ? entry + risk * rr2 : entry - risk * rr2
    take3 = isLong ? entry + risk * rr3 : entry - risk * rr3

    x1 = bar_index
    x2 = bar_index + planExtendBars
    labelX = x2 + rrTextOffset

    planColor = isLong ? colUp : colDn

    newEntryLine = line.new(x1, entry, x2, entry, color=color.new(planColor, 0), width=2)
    newSlLine    = line.new(x1, stop, x2, stop, color=color.new(color.gray, 0), width=2, style=line.style_dotted)
    newTp1Line   = line.new(x1, take1, x2, take1, color=color.new(planColor, 25), width=1, style=line.style_dotted)
    newTp2Line   = line.new(x1, take2, x2, take2, color=color.new(planColor, 25), width=1, style=line.style_dotted)
    newTp3Line   = line.new(x1, take3, x2, take3, color=color.new(planColor, 25), width=1, style=line.style_dotted)

    newEntryLab = rrLabelMode == "Off" ? na : label.new(labelX, entry, f_rr_live_text("ENTRY", entry, false), style=label.style_none, textcolor=color.new(planColor, 0), color=color.new(color.black, 100), size=size.small)
    newSlLab    = rrLabelMode == "Off" ? na : label.new(labelX, stop, f_rr_live_text("SL", stop, false), style=label.style_none, textcolor=color.new(color.gray, 0), color=color.new(color.black, 100), size=size.small)
    newTp1Lab   = rrLabelMode == "Off" ? na : label.new(labelX, take1, f_rr_live_text("TP1", take1, false), style=label.style_none, textcolor=color.new(planColor, 0), color=color.new(color.black, 100), size=size.small)
    newTp2Lab   = rrLabelMode == "Off" ? na : label.new(labelX, take2, f_rr_live_text("TP2", take2, false), style=label.style_none, textcolor=color.new(planColor, 0), color=color.new(color.black, 100), size=size.small)
    newTp3Lab   = rrLabelMode == "Off" ? na : label.new(labelX, take3, f_rr_live_text("TP3", take3, false), style=label.style_none, textcolor=color.new(planColor, 0), color=color.new(color.black, 100), size=size.small)

    [newEntryLine, newSlLine, newTp1Line, newTp2Line, newTp3Line, newEntryLab, newSlLab, newTp1Lab, newTp2Lab, newTp3Lab]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXIT X ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not showTradePlan or not useFusion
    tradeDir := 0
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false
    planClosed := false
    planEntryBar := na

longExitByMode =
     exitMode == "Active Trend Lost" ? bullTrend[1] and not bullTrend :
     exitMode == "Full Ribbon Lost"  ? bull4[1] and not bull4 :
     bearTrend and not bearTrend[1]

shortExitByMode =
     exitMode == "Active Trend Lost" ? bearTrend[1] and not bearTrend :
     exitMode == "Full Ribbon Lost"  ? bear4[1] and not bear4 :
     bullTrend and not bullTrend[1]

exitLong  = confirmedBar and showExitX and useFusion and showTradePlan and longExitByMode
exitShort = confirmedBar and showExitX and useFusion and showTradePlan and shortExitByMode
exitGrey  = exitLong or exitShort

plotshape(exitLong, title="Grey Exit Long X", style=shape.xcross, location=location.abovebar, color=color.new(colDn, 20), size=size.tiny)
plotshape(exitShort, title="Grey Exit Short X", style=shape.xcross, location=location.belowbar, color=color.new(colUp, 20), size=size.tiny)

if exitLong and tradeDir == 1
    tradeDir := 0
    planClosed := true

if exitShort and tradeDir == -1
    tradeDir := 0
    planClosed := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
canLongPlan  = showHistoricalPlan or allowSameDirectionReEntry or tradeDir != 1
canShortPlan = showHistoricalPlan or allowSameDirectionReEntry or tradeDir != -1

longFlipSignal =
     entryMode == "Trend Flip" and
     bullFlip and
     longPass and
     canLongPlan

shortFlipSignal =
     entryMode == "Trend Flip" and
     bearFlip and
     shortPass and
     canShortPlan

longRetestSignal =
     useRetestMode and
     pendingAfterFlip and
     pendingDir == 1 and
     pendingTouched and
     bullTrend and
     longReclaim and
     longPass and
     canLongPlan

shortRetestSignal =
     useRetestMode and
     pendingAfterFlip and
     pendingDir == -1 and
     pendingTouched and
     bearTrend and
     shortReclaim and
     shortPass and
     canShortPlan

longPullbackSignal =
     usePullbackMode and
     not bullFlip and
     bullTrend and
     longReclaim and
     longPass and
     canLongPlan and
     not longRetestSignal

shortPullbackSignal =
     usePullbackMode and
     not bearFlip and
     bearTrend and
     shortReclaim and
     shortPass and
     canShortPlan and
     not shortRetestSignal

longSignal =
     confirmedBar and
     useFusion and
     showTradePlan and
     (
         longFlipSignal or
         longRetestSignal or
         longPullbackSignal
     )

shortSignal =
     confirmedBar and
     useFusion and
     showTradePlan and
     (
         shortFlipSignal or
         shortRetestSignal or
         shortPullbackSignal
     )

slDistance = stopMode == "ATR" ? atr * slAtr : close * slPct / 100.0

if longSignal
    if not showHistoricalPlan
        f_clear_plan()

    [newEntryLine, newSlLine, newTp1Line, newTp2Line, newTp3Line, newEntryLab, newSlLab, newTp1Lab, newTp2Lab, newTp3Lab] = f_draw_plan(true, close, close - slDistance)

    entryLine := newEntryLine
    slLine    := newSlLine
    tp1Line   := newTp1Line
    tp2Line   := newTp2Line
    tp3Line   := newTp3Line
    entryLab  := newEntryLab
    slLab     := newSlLab
    tp1Lab    := newTp1Lab
    tp2Lab    := newTp2Lab
    tp3Lab    := newTp3Lab

    tradeDir := 1

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false
    planClosed := false
    planEntryBar := bar_index

    if pendingDir == 1
        pendingDir := 0
        pendingBar := na
        pendingTouched := false

if shortSignal
    if not showHistoricalPlan
        f_clear_plan()

    [newEntryLine, newSlLine, newTp1Line, newTp2Line, newTp3Line, newEntryLab, newSlLab, newTp1Lab, newTp2Lab, newTp3Lab] = f_draw_plan(false, close, close + slDistance)

    entryLine := newEntryLine
    slLine    := newSlLine
    tp1Line   := newTp1Line
    tp2Line   := newTp2Line
    tp3Line   := newTp3Line
    entryLab  := newEntryLab
    slLab     := newSlLab
    tp1Lab    := newTp1Lab
    tp2Lab    := newTp2Lab
    tp3Lab    := newTp3Lab

    tradeDir := -1

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false
    planClosed := false
    planEntryBar := bar_index

    if pendingDir == -1
        pendingDir := 0
        pendingBar := na
        pendingTouched := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIVE TP / SL HIT TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if tradeDir != 0 and not na(entryLine) and not planClosed and not na(planEntryBar) and bar_index > planEntryBar
    float entryPx = line.get_y1(entryLine)
    float slPx    = line.get_y1(slLine)
    float tp1Px   = line.get_y1(tp1Line)
    float tp2Px   = line.get_y1(tp2Line)
    float tp3Px   = line.get_y1(tp3Line)

    if tradeDir == 1
        bool stopNow = low <= slPx
        bool tp1Now  = high >= tp1Px
        bool tp2Now  = high >= tp2Px
        bool tp3Now  = high >= tp3Px

        if stopNow
            slHit := true
            planClosed := true
        else if tp3Now
            tp1Hit := true
            tp2Hit := true
            tp3Hit := true
            planClosed := true
        else if tp2Now
            tp1Hit := true
            tp2Hit := true
        else if tp1Now
            tp1Hit := true

    if tradeDir == -1
        bool stopNow = high >= slPx
        bool tp1Now  = low <= tp1Px
        bool tp2Now  = low <= tp2Px
        bool tp3Now  = low <= tp3Px

        if stopNow
            slHit := true
            planClosed := true
        else if tp3Now
            tp1Hit := true
            tp2Hit := true
            tp3Hit := true
            planClosed := true
        else if tp2Now
            tp1Hit := true
            tp2Hit := true
        else if tp1Now
            tp1Hit := true

    if not na(entryLab)
        label.set_text(entryLab, f_rr_live_text("ENTRY", entryPx, false))
    if not na(slLab)
        label.set_text(slLab, f_rr_live_text("SL", slPx, slHit))
    if not na(tp1Lab)
        label.set_text(tp1Lab, f_rr_live_text("TP1", tp1Px, tp1Hit))
    if not na(tp2Lab)
        label.set_text(tp2Lab, f_rr_live_text("TP2", tp2Px, tp2Hit))
    if not na(tp3Lab)
        label.set_text(tp3Lab, f_rr_live_text("TP3", tp3Px, tp3Hit))

if planClosed and (slHit or tp3Hit)
    tradeDir := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLEAN ENTRY MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(entryMarkerMode == "Tiny Triangle" and longSignal, title="Long Tiny Triangle", style=shape.triangleup, location=location.belowbar, color=color.new(colUp, entryMarkerTransp), size=size.tiny)
plotshape(entryMarkerMode == "Tiny Triangle" and shortSignal, title="Short Tiny Triangle", style=shape.triangledown, location=location.abovebar, color=color.new(colDn, entryMarkerTransp), size=size.tiny)

plotshape(entryMarkerMode == "Small Triangle" and longSignal, title="Long Small Triangle", style=shape.triangleup, location=location.belowbar, color=color.new(colUp, entryMarkerTransp), size=size.small)
plotshape(entryMarkerMode == "Small Triangle" and shortSignal, title="Short Small Triangle", style=shape.triangledown, location=location.abovebar, color=color.new(colDn, entryMarkerTransp), size=size.small)

plotshape(entryMarkerMode == "Text Labels" and longSignal, title="Long Text Label", text="LONG", style=shape.labelup, location=location.belowbar, color=color.new(colUp, 0), textcolor=color.white, size=size.tiny)
plotshape(entryMarkerMode == "Text Labels" and shortSignal, title="Short Text Label", text="SHORT", style=shape.labeldown, location=location.abovebar, color=color.new(colDn, 0), textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, "Long Trade Plan", "Valid long Fusion EMA trade plan printed")
alertcondition(shortSignal, "Short Trade Plan", "Valid short Fusion EMA trade plan printed")
alertcondition(exitGrey, "Grey Exit", "Fusion exit condition printed")

alertcondition(bullFlip, "Fusion Bull Flip", "Fusion EMA alignment flipped bullish")
alertcondition(bearFlip, "Fusion Bear Flip", "Fusion EMA alignment flipped bearish")

alertcondition(bullHTFFlip, "HTF Fusion Bull Flip", "Higher timeframe Fusion EMA alignment flipped bullish")
alertcondition(bearHTFFlip, "HTF Fusion Bear Flip", "Higher timeframe Fusion EMA alignment flipped bearish")
````

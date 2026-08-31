<!-- tradingview-pine-id: PUB;5109b9322bf44e8ab81d451f232f4a6a -->
<!-- tradingviewscripts-format: 1 -->
# EMA/SMA Classics V1.0 by SRT

Source: https://www.tradingview.com/script/Bp2DVHi7-EMA-SMA-Classics-V1-0-by-SRT/

## Description

EMA/SMA Classics V1.0 by SRT

The EMA/SMA Classics indicator was designed to answer one simple question:

"Which side of the market currently has the structural advantage?"

Instead of flooding the chart with buy and sell arrows, this indicator focuses on market structure, trend alignment, and high-quality price action, allowing traders to make their own execution decisions with greater confidence.

Whether you trade Forex, Indices, Commodities or Crypto, this indicator combines multiple market concepts into a clean workflow while remaining highly configurable through both EMA and SMA combinations.

What This Indicator Includes
• Flexible EMA / SMA Engine

Unlike traditional moving average indicators that are locked to one MA type, every moving average in this indicator can independently be configured as either:

EMA
SMA

Default settings:

MA 1 : 7
MA 2 : 40
MA 3 : 150
MA 4 : 200

You may use the default configuration or customise the periods to fit your own trading methodology.

• Dynamic Moving Average Stack Detection

The indicator continuously evaluates whether the visible moving averages are properly stacked.

Bullish Stack

Fast MA > Medium MA > Slow MA

Bearish Stack

Fast MA < Medium MA < Slow MA

When the moving averages lose their proper order, the market is treated as neutral instead of forcing a directional bias.

This helps reduce many false trend signals that occur during consolidations.

• ATR-Based MA Spacing Filter

One common problem with MA strategies is entering when all moving averages have already compressed together.

This indicator measures the spacing between moving averages using ATR.

When the moving averages become too compressed, trend quality deteriorates.

The spacing filter helps identify these lower-quality environments before momentum fully develops.

• Ladder Structure

One of the core concepts inside this indicator is the Ladder System.

Instead of only observing moving averages, the indicator also evaluates the market using multiple dynamic support and resistance structures.

Resistance

R9
R40
R70
R100
R150

Support

S9
S40
S70
S100
S150

These levels automatically update with market structure and are used to generate an additional Ladder Bias.

When both the moving averages and Ladder Bias agree, market structure is generally stronger than relying on moving averages alone.

• Flush Dot System

The indicator displays visual Flush Dots beneath or above candles whenever trend alignment exists.

Small Green Dot

Bullish MA alignment.

Small Red Dot

Bearish MA alignment.

Large Green Dot

Moving Average alignment + Bullish Ladder confirmation.

Large Red Dot

Moving Average alignment + Bearish Ladder confirmation.

The larger dots represent stronger structural agreement across multiple components.

• KeyBar Detection

The indicator automatically identifies two important price action patterns.

Engulfing Bars

Bullish Engulfing (EBull)

Bearish Engulfing (EBear)

These are filtered using ATR and minimum body size to avoid insignificant candles.

Long Tail Bars (LTB)

Bullish Long Tail Bars

Bearish Long Tail Bars

These identify strong rejection candles with defined tail proportions and body positioning.

An optional body-size filter is also available for traders wanting stricter candle selection.

Daily Pivot (DP)

Automatically plots the previous day's pivot.

Useful as:

Dynamic support
Dynamic resistance
Intraday reaction level
Weekly Pivot (WP)

Automatically plots the previous week's pivot.

Many swing traders use weekly pivots as major reaction zones throughout the trading week.

RSI Momentum Alerts

The indicator includes two independent RSI event types.

RSI Breakout

Signals when RSI breaks into extreme momentum territory.

Bullish breakout

Bearish breakout

RSI Retracement

Designed to identify momentum continuation after RSI exits an extreme condition while confirming with the RSI Moving Average.

These alerts can be useful for traders looking to participate after momentum has begun to recover instead of chasing extremes.

Information Panel

A compact table summarises the current market condition.

Displays:

Moving Average Bias
Ladder Bias
Long Tail Bar presence

This provides a quick snapshot without needing to inspect every component individually.

How To Use This Indicator

This indicator is not designed to generate automatic Buy or Sell signals.

Instead, it acts as a Market Context Indicator.

A typical workflow may look like this:

Step 1

Observe whether the moving averages are properly stacked.

A clean stack generally indicates directional order.

Step 2

Check whether the Ladder Bias agrees with the moving averages.

When both align, the market structure is generally stronger.

Step 3

Watch for KeyBars.

Examples include:

Bullish Engulfing
Bearish Engulfing
Bullish Long Tail Bar
Bearish Long Tail Bar

These often represent meaningful reactions within the prevailing structure.

Step 4

Use Daily Pivot and Weekly Pivot as areas where price may react.

These levels should be considered areas of interest rather than guaranteed reversal zones.

Step 5

Monitor RSI alerts for momentum shifts.

Momentum signals are generally more useful when they occur in the same direction as the prevailing market structure.

Suitable Timeframes

Although the indicator can be applied to multiple chart intervals, it generally performs best on:

M15
M30
H1
H4
Daily

The moving averages, Ladder System, and KeyBar detection adapt naturally across different timeframes.

Difference Between EMA/SMA Classics & H1 EMA/SMA + Higher Timeframe Analysis (Classic)

Although both indicators belong to the same ecosystem, they serve different purposes.

EMA/SMA Classics

Designed as a general-purpose structural trend indicator.

Features include:

Flexible EMA/SMA stacking
Ladder System
Flush Dots
Engulfing Bars
Long Tail Bars
Daily Pivot
Weekly Pivot
RSI Alerts

It can be used on virtually any timeframe and is ideal for traders who prefer to analyse the chart directly.

H1 EMA/SMA + Higher Timeframe Analysis (Classic)

The H1 version is a significantly more advanced market context engine.

In addition to everything above, it introduces:

Dedicated H1 Bias Engine
H4 Trend Analysis
Daily Trend Analysis
Higher Timeframe Bias Aggregation
H1TF Composite Bias
Overall Market Verdict Engine
Multi-layer Bias Table
Higher Timeframe Confirmation Workflow

Rather than focusing solely on the current chart, the H1 version continuously evaluates whether multiple timeframes are aligned before presenting an overall market verdict.

If the EMA/SMA Classics indicator answers:

"What is my current chart doing?"

Then the H1 version answers:

"What is the broader market structure telling me across multiple timeframes?"

The two indicators are complementary and can be used together depending on your preferred trading workflow.

Disclaimer

This indicator is designed to assist with market structure analysis and decision-making. It does not provide financial advice or guarantee profitable trades. Always combine indicator signals with sound risk management, personal analysis, and appropriate position sizing.

---

## Source Code

````pine
//@version=6
indicator("EMA/SMA Classics V1.0 by SRT", overlay=true, max_lines_count=500, max_labels_count=500)

// ======================
// === 1️⃣ INPUTS - MAs ===
maType1 = input.string("EMA", "MA 1 Type", options=["EMA","SMA"])
maType2 = input.string("EMA", "MA 2 Type", options=["EMA","SMA"])
maType3 = input.string("EMA", "MA 3 Type", options=["EMA","SMA"])
maType4 = input.string("EMA", "MA 4 Type", options=["EMA","SMA"])

showMA1 = input.bool(true, "Show MA 1")
showMA2 = input.bool(true, "Show MA 2")
showMA3 = input.bool(true, "Show MA 3")
showMA4 = input.bool(true, "Show MA 4")

maLength1 = input.int(7, "MA 1 Length", minval=1)
maLength2 = input.int(40, "MA 2 Length", minval=1)
maLength3 = input.int(150, "MA 3 Length", minval=1)
maLength4 = input.int(200, "MA 4 Length", minval=1)

// Helper: compute chosen MA type
getMA(maType, maLen) =>
    maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)

// Compute each MA
ma1_series = getMA(maType1, maLength1)
ma2_series = getMA(maType2, maLength2)
ma3_series = getMA(maType3, maLength3)
ma4_series = getMA(maType4, maLength4)

// Build array of visible MAs
var float[] maVisible = array.new_float()
array.clear(maVisible)
if showMA1
    array.push(maVisible, ma1_series)
if showMA2
    array.push(maVisible, ma2_series)
if showMA3
    array.push(maVisible, ma3_series)
if showMA4
    array.push(maVisible, ma4_series)

// ======================
// === 2️⃣ EMA STACK LOGIC ===
atrLenEMA = input.int(14, "EMA Spacing ATR Length", minval=1)
atrPercEMA = input.float(0.25, "EMA Spacing Threshold %", step=0.01, minval=0.0, maxval=10.0)

atrVal = ta.atr(atrLenEMA)

// Compute distances between EMAs
emaDist12 = math.abs(ma1_series - ma2_series)
emaDist23 = math.abs(ma2_series - ma3_series)
emaDist13 = math.abs(ma1_series - ma3_series)

// Are EMAs too close?
emaTooClose = emaDist12 < atrVal * atrPercEMA or emaDist23 < atrVal * atrPercEMA or emaDist13 < atrVal * atrPercEMA

// ======================
/// === DYNAMIC STACK CLEAN VERSION ===
visibleCount = array.size(maVisible)

// Initialize stack flags
bullishStack = false
bearishStack = false

if visibleCount >= 2
    // Start with true; will be reduced to false if any MA order breaks
    bullishStack := true
    bearishStack := true

    // Loop through visible MAs and check stacking order
    for i = 0 to visibleCount - 2
        v0 = array.get(maVisible, i)
        v1 = array.get(maVisible, i + 1)
        bullishStack := bullishStack and (v0 > v1)
        bearishStack := bearishStack and (v0 < v1)
else
    bullishStack := false
    bearishStack := false

// Final flags (compatibility)
BullishEmas = bullishStack
BearishEmas = bearishStack

// ======================
// === PLOTTING MAs ===
plot(ma1_series, title="MA 1", color=showMA1 ? color.new(color.green, 0) : na, linewidth=2)
plot(ma2_series, title="MA 2", color=showMA2 ? color.new(color.orange, 0) : na, linewidth=2)
plot(ma3_series, title="MA 3", color=showMA3 ? color.new(color.red, 0) : na, linewidth=2)
plot(ma4_series, title="MA 4", color=showMA4 ? color.new(color.white, 0) : na, linewidth=2)

// ======================
// === 3️⃣ SIGNALS — EBULL / EBEAR / LTB
showEBull = input.bool(true, "Show Engulfing Bullish")
showEBear = input.bool(true, "Show Engulfing Bearish")
showLTBBull = input.bool(true, "Show LTB Bullish")
showLTBBear = input.bool(true, "Show LTB Bearish")

atrLenGlobal = input.int(20, "ATR Length (Global)", minval=1)
atrPercGlobal = input.float(0.72, "ATR % Threshold (Global)", step=0.01, minval=0.0, maxval=10.0)

overrideLTB = input.bool(false, "Override ATR for LTB")
ltbAtrLen = input.int(20, "LTB ATR Length", minval=1)
ltbAtrPerc = input.float(0.72, "LTB ATR %", step=0.01, minval=0.0, maxval=10.0)

overrideEB = input.bool(false, "Override ATR for Engulfings")
ebAtrLen = input.int(20, "EB ATR Length", minval=1)
ebAtrPerc = input.float(0.72, "EB ATR %", step=0.01, minval=0.0, maxval=10.0)

atrLenLTB = overrideLTB ? ltbAtrLen : atrLenGlobal
atrPercLTB = overrideLTB ? ltbAtrPerc : atrPercGlobal
atrLenEB = overrideEB ? ebAtrLen : atrLenGlobal
atrPercEB = overrideEB ? ebAtrPerc : atrPercGlobal

atrLTB_prev = ta.atr(atrLenLTB)[1]
atrEB_prev = ta.atr(atrLenEB)[1]

// ======================
// === Engulfing (EB) ===
minBodyPct = 0.5

bodyLow2 = math.min(open[2], close[2])
bodyHigh2 = math.max(open[2], close[2])

bodyLow1 = math.min(open[1], close[1])
bodyHigh1 = math.max(open[1], close[1])

body1 = math.abs(close[1] - open[1])
engulfrange1 = high[1] - low[1]
bodyPct1 = engulfrange1 > 0 ? body1 / engulfrange1 : 0

ebBigEnough = (engulfrange1 > 0 and atrEB_prev > 0) ? (engulfrange1 >= atrEB_prev * atrPercEB) : false

isEBull = ebBigEnough and (close[1] > open[1]) and (bodyLow1 < bodyLow2) and (bodyHigh1 > bodyHigh2) and (bodyPct1 >= minBodyPct)
isEBear = ebBigEnough and (close[1] < open[1]) and (bodyHigh1 > bodyHigh2) and (bodyLow1 < bodyLow2) and (bodyPct1 >= minBodyPct)

// ======================
// === LTB (long tail body) ===
h1 = high[1]
l1 = low[1]
o1 = open[1]
c1 = close[1]
range1 = h1 - l1
uw1 = h1 - math.max(o1, c1)
lw1 = math.min(o1, c1) - l1

lwPct = range1 > 0 ? lw1 / range1 : 0
uwPct = range1 > 0 ? uw1 / range1 : 0

bodyTop = math.max(o1, c1)
bodyBot = math.min(o1, c1)

bodyAtTop = bodyBot >= l1 + (0.55 * range1)
bodyAtBottom = bodyTop <= h1 - (0.55 * range1)

useLtbBodyFilter = input.bool(true, "Enable LTB Body % Filter")
minLtbBodyPct = input.float(0.20, "LTB Minimum Body %", step=0.01, minval=0.0, maxval=1.0)

ltbBodySize = math.abs(c1 - o1)
ltbBodyPct = range1 > 0 ? ltbBodySize / range1 : 0
ltbBodyPass = (not useLtbBodyFilter) or (ltbBodyPct >= minLtbBodyPct)

ltbBigEnough = (range1 > 0 and atrLTB_prev > 0) ? (range1 >= atrLTB_prev * atrPercLTB) : false

// apply close-momentum requirement: bullish LTB must close bullish, bearish LTB must close bearish
isLTBBull = ltbBigEnough and ltbBodyPass and lwPct >= 0.55 and bodyAtTop and (c1 > o1)
isLTBBear = ltbBigEnough and ltbBodyPass and uwPct >= 0.55 and bodyAtBottom and (c1 < o1)

// If both true (ambiguous) resolve by candle close direction
if isLTBBull and isLTBBear
    if c1 > o1
        isLTBBear := false
    else
        isLTBBull := false

// ======================
// === LABELS & OFFSETS ===
candleRange = range1
atrBase = ta.atr(14)
dynamicOffset = (candleRange * 0.25) + (atrBase * 0.25)

offsetAbove = high[1] + dynamicOffset
offsetBelow = low[1] - dynamicOffset

// label array (type must be label)
var label[] labels = array.new<label>()

// === DYNAMIC MAX LABELS BASED ON TIMEFRAME ===
maxLabels = switch timeframe.period
    "1"   => 150
    "5"   => 100
    "15"  => 80
    "60"  => 60
    "240" => 50
    "D"   => 30
    => 40  // default fallback

// Cleanup function (v6-compliant multi-line)
cleanup() =>
    while array.size(labels) > maxLabels
        l = array.shift(labels)
        label.delete(l)

// === Place labels ===
if barstate.isconfirmed
    if showEBull and isEBull
        l = label.new(bar_index[1], offsetBelow, "EBull", style=label.style_label_center, color=color.rgb(5,85,7), textcolor=color.white)
        array.push(labels, l)
        cleanup()
    if showEBear and isEBear
        l = label.new(bar_index[1], offsetAbove, "EBear", style=label.style_label_center, color=color.rgb(97,7,7), textcolor=color.white)
        array.push(labels, l)
        cleanup()
    if showLTBBull and isLTBBull
        l = label.new(bar_index[1], offsetBelow, "LTB", style=label.style_label_center, color=color.green, textcolor=color.white)
        array.push(labels, l)
        cleanup()
    if showLTBBear and isLTBBear
        l = label.new(bar_index[1], offsetAbove, "LTB", style=label.style_label_center, color=color.red, textcolor=color.white)
        array.push(labels, l)
        cleanup()

// ======================
// === Helper: safe min/max of array of floats ===
// (safer than using array.min/array.max in case of engine differences)
f_array_min(_arr) =>
    var float mn = na
    for i = 0 to array.size(_arr) - 1
        v = array.get(_arr, i)
        mn := na(mn) ? v : math.min(mn, v)
    mn

f_array_max(_arr) =>
    var float mx = na
    for i = 0 to array.size(_arr) - 1
        v = array.get(_arr, i)
        mx := na(mx) ? v : math.max(mx, v)
    mx

minVisibleMA = array.size(maVisible) > 0 ? f_array_min(maVisible) : low
maxVisibleMA = array.size(maVisible) > 0 ? f_array_max(maVisible) : high

// ======================
// === LADDER SYSTEM + BIAS
showLadder = input.bool(true, "Show Ladder Labels")
xOffset = 4
R150 = ta.highest(high,150)
R100 = ta.highest(high,100)
R70  = ta.highest(high,70)
R40  = ta.highest(high,40)
R9   = ta.highest(high,9)
S9   = ta.lowest(low,9)
S40  = ta.lowest(low,40)
S70  = ta.lowest(low,70)
S100 = ta.lowest(low,100)
S150 = ta.lowest(low,150)

var label r150Lbl = na
var label r100Lbl = na
var label r70Lbl = na
var label r40Lbl = na
var label r9Lbl = na
var label s9Lbl = na
var label s40Lbl = na
var label s70Lbl = na
var label s100Lbl = na
var label s150Lbl = na

f_update(lbl, price, txt, col) =>
    if na(lbl)
        label.new(bar_index+xOffset, price, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
    else
        label.set_xy(lbl, bar_index+xOffset, price),
        label.set_text(lbl, txt),
        label.set_color(lbl, col),
        lbl

if barstate.isconfirmed and showLadder
    r150Lbl := f_update(r150Lbl,R150,"R150 "+str.tostring(R150,format.mintick),color.red)
    r100Lbl := f_update(r100Lbl,R100,"R100 "+str.tostring(R100,format.mintick),color.red)
    r70Lbl  := f_update(r70Lbl,R70,"R70 "+str.tostring(R70,format.mintick),color.red)
    r40Lbl  := f_update(r40Lbl,R40,"R40 "+str.tostring(R40,format.mintick),color.red)
    r9Lbl   := f_update(r9Lbl,R9,"R9 "+str.tostring(R9,format.mintick),color.red)
    s9Lbl   := f_update(s9Lbl,S9,"S9 "+str.tostring(S9,format.mintick),color.green)
    s40Lbl  := f_update(s40Lbl,S40,"S40 "+str.tostring(S40,format.mintick),color.green)
    s70Lbl  := f_update(s70Lbl,S70,"S70 "+str.tostring(S70,format.mintick),color.green)
    s100Lbl := f_update(s100Lbl,S100,"S100 "+str.tostring(S100,format.mintick),color.green)
    s150Lbl := f_update(s150Lbl,S150,"S150 "+str.tostring(S150,format.mintick),color.green)

bullPts = 0
bullPts += S150<S100?1:0
bullPts += S100<S70?1:0
bullPts += S70<S40?1:0
bullPts += S40<S9?1:0
bearPts = 0
bearPts += R150>R100?1:0
bearPts += R100>R70?1:0
bearPts += R70>R40?1:0
bearPts += R40>R9?1:0
netPts = bullPts-bearPts
LadderBias = netPts>=2?2:netPts==1?1:netPts==-1?-1:netPts<=-2?-2:0
LadderBiasText = LadderBias==2?"S.Bull":LadderBias==1?"Bull":LadderBias==-1?"Bear":LadderBias==-2?"S.Bear":"Neut"

// ======================
// === DAILY & WEEKLY PIVOTS
showDP  = input.bool(true,"Show Daily Pivot (DP)")
showWP  = input.bool(true,"Show Weekly Pivot (WP)")
dpColor = input.color(color.new(#7bb2f8,0),"DP Color")
wpColor = input.color(color.new(#b6fe50,0),"WP Color")

isNewDay  = dayofmonth!=dayofmonth[1]
isNewWeek = weekofyear!=weekofyear[1]

// --- Daily Pivot
var float prevDayHigh = na
var float prevDayLow  = na
var float prevDayClose= na
var float dp = na
if na(prevDayHigh)
    prevDayHigh := high
    prevDayLow  := low
    prevDayClose:= close
if isNewDay
    dp := (prevDayHigh + prevDayLow + prevDayClose) / 3
    prevDayHigh := high
    prevDayLow  := low
else
    prevDayHigh := math.max(prevDayHigh,high)
    prevDayLow  := math.min(prevDayLow,low)
prevDayClose := close

// --- Weekly Pivot
var float prevWeekHigh=na
var float prevWeekLow=na
var float prevWeekClose=na
var float wp = na
if na(prevWeekHigh)
    prevWeekHigh  := high
    prevWeekLow   := low
    prevWeekClose := close
if isNewWeek
    wp := (prevWeekHigh + prevWeekLow + prevWeekClose) / 3
    prevWeekHigh := high
    prevWeekLow  := low
else
    prevWeekHigh:=math.max(prevWeekHigh,high)
    prevWeekLow:=math.min(prevWeekLow,low)
prevWeekClose:=close

plot(showDP?dp:na,"Daily Pivot (DP)",dpColor,1)
plot(showWP?wp:na,"Weekly Pivot (WP)",wpColor,3)

// ======================
// === FLUSH MARKERS ===
dotOffset = (high - low) * 0.2

bullDotY = math.min(minVisibleMA, low) - dotOffset
bearDotY = math.max(maxVisibleMA, high) + dotOffset

// Apply EMA spacing filter
bullishStackFiltered = bullishStack and not emaTooClose
bearishStackFiltered = bearishStack and not emaTooClose

// --- Regular MA flush markers
plotshape(bullishStackFiltered ? bullDotY : na, 
          title="MA Bull Flush", location=location.absolute, style=shape.circle, size=size.tiny, color=color.green)
plotshape(bearishStackFiltered ? bearDotY : na, 
          title="MA Bear Flush", location=location.absolute, style=shape.circle, size=size.tiny, color=color.red)

// --- Mega flush dot (MAs + Ladder alignment)
bigBullDotY = low - dotOffset * 1.5
bigBearDotY = high + dotOffset * 1.5

plotshape(bullishStack and LadderBias > 0 ? bigBullDotY : na,
          title="Mega Bull Flush", location=location.absolute, style=shape.circle, size=size.small, color=color.lime)

plotshape(bearishStack and LadderBias < 0 ? bigBearDotY : na,
          title="Mega Bear Flush", location=location.absolute, style=shape.circle, size=size.small, color=color.red)

// ======================
// === BIAS TABLE ===
updateFreq = switch timeframe.period
    "D"   => 1
    "240" => 1
    "60"  => 1
    "15"  => 3
    "5"   => 3
    "1"   => 5
    => 5

var table biasTable = table.new(position.top_right, 6, 1, border_width=1)

// MA Bias
MAsBiasText = BullishEmas ? "Bullish" : BearishEmas ? "Bearish" : "Neutral"

// LTB
ltbPresent = (isLTBBull or isLTBBear) ? "Yes" : "No"

// Ladder
ladderText  = LadderBias == 2  ? "S.Bull" :
              LadderBias == 1  ? "Bull"  :
              LadderBias == -1 ? "Bear"  :
              LadderBias == -2 ? "S.Bear": "Neut"

maColor      = BullishEmas ? color.green : BearishEmas ? color.red : color.gray
ltbColor     = ltbPresent == "Yes" ? color.fuchsia : color.gray
ladderColor  = LadderBias > 0 ? color.green : LadderBias < 0 ? color.red : color.gray

if bar_index % updateFreq == 0
    table.cell(biasTable, 0, 0, "MAs",        text_color=color.white, bgcolor=color.black)
    table.cell(biasTable, 1, 0, MAsBiasText, text_color=maColor,   bgcolor=color.black)
    table.cell(biasTable, 2, 0, "Ladder",    text_color=color.white, bgcolor=color.black)
    table.cell(biasTable, 3, 0, ladderText,  text_color=ladderColor, bgcolor=color.black)
    table.cell(biasTable, 4, 0, "LTB",       text_color=color.white, bgcolor=color.black)
    table.cell(biasTable, 5, 0, ltbPresent,  text_color=ltbColor, bgcolor=color.black)

// ======================
//PREMIUM RSI + RSI MA ALERTS

// === Inputs ===
rsiLen = input.int(14, "RSI Length")
rsiMALen = input.int(14, "RSI MA Length")
rsiSource = input.source(close, "RSI Source")
upperBreak = input.float(71.5, "RSI Bull Break Level")
lowerBreak = input.float(28.5, "RSI Bear Break Level")
upperMA = input.float(67, "RSI MA Bearish Threshold")
lowerMA = input.float(33, "RSI MA Bullish Threshold")
lookBack = input.int(3, "RSI Retracement LookBack Bars", minval=1, maxval=10)
cooldownBars = input.int(3, "Cooldown Bars After Retracement", minval=1, maxval=10)

// === RSI Calculations ===
rsiValue = ta.rsi(rsiSource, rsiLen)
rsiMA = ta.sma(rsiValue, rsiMALen)

// === Cooldown tracking ===
var int lastBullRetraceBar = na
var int lastBearRetraceBar = na

// === ALERT 1 — RSI Breakouts ===
alert1Bull = barstate.isconfirmed and (rsiValue[1] < upperBreak) and (rsiValue >= upperBreak)
alert1Bear = barstate.isconfirmed and (rsiValue[1] > lowerBreak) and (rsiValue <= lowerBreak)

// === ALERT 2 — RSI Retracements ===
// Intermediate variables

bullRetraceTouch = ta.lowest(rsiValue, lookBack) < lowerBreak
bullRetraceCross = ta.crossover(rsiValue, rsiMA)
bullRetraceMACond = rsiMA <= lowerMA
bullRetraceNow = rsiValue >= lowerBreak

bearRetraceTouch = ta.highest(rsiValue, lookBack) > upperBreak
bearRetraceCross = ta.crossunder(rsiValue, rsiMA)
bearRetraceMACond = rsiMA >= upperMA
bearRetraceNow = rsiValue <= upperBreak

// Combine conditions with parentheses
bullRetraceCond = barstate.isconfirmed and (bullRetraceTouch and bullRetraceNow and bullRetraceMACond and bullRetraceCross)
bearRetraceCond = barstate.isconfirmed and (bearRetraceTouch and bearRetraceNow and bearRetraceMACond and bearRetraceCross)

// Apply cooldown
alert2Bull = bullRetraceCond and (na(lastBullRetraceBar) or (bar_index - lastBullRetraceBar > cooldownBars))
alert2Bear = bearRetraceCond and (na(lastBearRetraceBar) or (bar_index - lastBearRetraceBar > cooldownBars))

// Update cooldown trackers

if alert2Bull
    lastBullRetraceBar:= bar_index
if alert2Bear
    lastBearRetraceBar:= bar_index

// === ALERT SHAPES ===
rsiOffsetUp = 300 * syminfo.mintick
rsiOffsetDown = 300 * syminfo.mintick

plotshape(alert1Bull ? low - rsiOffsetDown : na, title="RSI Breakout Bull", location=location.absolute, style=shape.triangleup, size=size.tiny, color=color.new(#5d5bd3, 0))
plotshape(alert1Bear ? high + rsiOffsetUp : na, title="RSI Breakout Bear", location=location.absolute, style=shape.triangledown, size=size.tiny, color=color.new(#fc0404, 0))
plotshape(alert2Bull ? low - rsiOffsetDown : na, title="RSI Retracement Bull", location=location.absolute, style=shape.triangleup, size=size.small, color=color.new(#869bf9, 0))
plotshape(alert2Bear ? high + rsiOffsetUp : na, title="RSI Retracement Bear", location=location.absolute, style=shape.triangledown, size=size.small, color=color.new(#ff8e8e, 0))

// === ALERT CONDITIONS FOR TRADINGVIEW PANEL ===
alertcondition(alert1Bull, title="RSI Bull Breakout", message="RSI broke above upperBreak level")
alertcondition(alert1Bear, title="RSI Bear Breakout", message="RSI broke below lowerBreak level")
alertcondition(alert2Bull, title="RSI Bull Retracement", message="Bullish RSI retracement setup")
alertcondition(alert2Bear, title="RSI Bear Retracement", message="Bearish RSI retracement setup")

// ======================
// === ALERTS (previous-bar only) ===
alertcondition(barstate.isconfirmed and (isEBull or isEBear or isLTBBull or isLTBBear),
     title="Signal Bar Formed", message="A signal bar formed: EBull, EBear, or LTB.")

alertcondition(barstate.isconfirmed and bullishStack and (isEBull or isLTBBull),
     title="Bullish Combo", message="Bullish MA bias + EBull or Bullish LTB.")

alertcondition(barstate.isconfirmed and bearishStack and (isEBear or isLTBBear),
     title="Bearish Combo", message="Bearish MA bias + EBear or Bearish LTB.")
````

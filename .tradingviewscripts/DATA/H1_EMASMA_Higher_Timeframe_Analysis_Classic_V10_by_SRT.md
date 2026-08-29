<!-- tradingview-pine-id: PUB;fe516c9e806d45608e2eea8127432bef -->
<!-- tradingviewscripts-format: 1 -->
# H1 EMA/SMA + Higher Timeframe Analysis (Classic) V1.0 by SRT

Source: https://www.tradingview.com/script/Ap4gGI12-H1-EMA-SMA-Higher-Timeframe-Analysis-Classic-V1-0-by-SRT/

## Description

# H1 EMA/SMA + Higher Timeframe Analysis (Classic) V1.0 by SRT

## Overview

H1 EMA/SMA + Higher Timeframe Analysis (Classic) V1.0 by SRT is a complete market context indicator designed to help traders read trend, structure and execution quality from a single chart.

Instead of relying on one indicator alone, this script combines multiple layers of market information into one unified framework:

• H1 Moving Average Bias Engine
• Higher Timeframe (H4 & Daily) Trend Confirmation
• Ladder Market Structure Analysis
• Dynamic Daily & Weekly Pivot Levels
• VWAP Bias Filter
• Engulfing & Long Tail Bar (LTB) Detection
• RSI Breakout & Retracement Alerts
• Composite Bias Dashboard
• Smart Alert System

The objective is simple:

Reduce subjectivity by helping traders identify when multiple independent factors agree before looking for trade opportunities.

This indicator is designed for traders who prefer trading with trend and market structure rather than relying on a single crossover or oscillator.

---

## Main Features

### ① H1 Bias Engine

The H1 Bias Engine evaluates the alignment of up to four configurable EMA/SMA lines.

Unlike traditional MA crossover indicators, this engine considers:

• Moving average order
• Price position relative to the moving averages
• MA spacing quality
• Trend strength

Bias is classified into:

• Strong Bullish
• Bullish
• Neutral
• Bearish
• Strong Bearish

An ATR-based spacing filter automatically ignores signals when moving averages become compressed, helping reduce false trend readings during consolidation.

---

### ② Higher Timeframe Bias

The script automatically evaluates both:

• H4 Trend
• Daily Trend

using a dedicated EMA40 / EMA150 / SMA200 structure.

These two higher timeframes are combined into a Higher Timeframe (HTF) Bias.

This allows traders to quickly determine whether H1 signals are aligned with the broader market direction.

---

### ③ Ladder Market Structure

The Ladder System measures how support and resistance levels evolve over multiple lookback windows.

Support Levels

S9
S40
S70
S100
S150

Resistance Levels

R9
R40
R70
R100
R150

The relative positioning of these levels produces a Ladder Bias ranging from:

Strong Bullish

Bullish

Neutral

Bearish

Strong Bearish

This provides an additional market structure confirmation independent of moving averages.

---

### ④ Composite H1TF Bias

One of the core components of the indicator.

H1TF combines:

• H1 Moving Average Bias
• Ladder Bias

to generate a stronger consensus trend.

Rather than reacting to a single condition, H1TF requires agreement between trend and structure before producing stronger directional confidence.

---

### ⑤ Final Verdict Engine

The Final Verdict combines:

Higher Timeframe Bias

*

H1TF Composite Bias

Only when both higher timeframe trend and H1 composite trend strongly agree will the dashboard produce:

Strong Bullish

or

Strong Bearish

This helps traders focus on higher probability market conditions instead of reacting to every market fluctuation.

---

### ⑥ Key Bar Detection

The indicator automatically detects two important price action patterns.

Bullish / Bearish Engulfing Bars

Long Tail Bars (LTB)

Each signal includes:

ATR size validation

Minimum body filters

Tail quality checks

Momentum confirmation

These are designed to highlight significant candles instead of every basic engulfing or pin bar.

---

### ⑦ Daily & Weekly Pivot Levels

Built-in pivot calculations include:

Daily Pivot (DP)

Weekly Pivot (WP)

These levels provide additional context for potential support, resistance and reaction zones.

---

### ⑧ VWAP Bias

The indicator includes a built-in VWAP filter.

Price above VWAP

Bullish

Price below VWAP

Bearish

This offers another layer of institutional-style market context that complements the moving average analysis.

---

### ⑨ RSI Momentum Alerts

Four RSI-based alerts are included.

Bullish RSI Breakout

Bearish RSI Breakout

Bullish RSI Retracement

Bearish RSI Retracement

These alerts are designed to identify momentum expansion as well as potential continuation opportunities after retracements.

---

### ⑩ Smart Alert System

The alert engine supports multiple event types.

H1 Bias changes

Higher Timeframe Bias changes

H1TF Composite changes

Ladder Bias changes

Bullish Engulfing

Bearish Engulfing

Bullish Long Tail Bar

Bearish Long Tail Bar

Optional filters allow alerts to trigger only when aligned with:

H1TF

Higher Timeframe

Strong Bias only

This helps reduce unnecessary alert noise.

---

## Reading the Bias Dashboard

The dashboard summarizes the complete market picture.

Daily

Daily Trend

H4

H4 Trend

HTF

Combined Higher Timeframe Trend

H1

Current H1 Moving Average Bias

Ladder

Market Structure Bias

H1TF

Combined H1 Trend

VWAP

Current VWAP Position

Verdict

Final Consensus

The strongest trading environments generally occur when multiple components point in the same direction.

---

## Typical Workflow

A simple workflow may look like this:

1. Check the Final Verdict.

2. Confirm H1TF agrees with the Higher Timeframe.

3. Observe whether VWAP supports the direction.

4. Wait for a qualifying Engulfing Bar or Long Tail Bar.

5. Use Daily Pivot, Weekly Pivot and Ladder levels for trade management.

This approach encourages waiting for confluence rather than entering solely because one indicator changes direction.

---

## Notes

This indicator is intended as a market context and decision-support tool.

It does not predict future prices and should not be considered a standalone trading system.

Like any technical tool, it performs best when combined with sound risk management, proper trade planning and disciplined execution.

---

Thank you for using H1 EMA/SMA + Higher Timeframe Analysis (Classic) V1.0 by SRT

I hope this indicator helps simplify chart analysis and encourages traders to focus on market structure, trend alignment and disciplined decision making.

— SRT

---

## Source Code

````pine
//@version=6
indicator("H1 EMA/SMA + Higher Timeframe Analysis (Classic) V1.0 by SRT", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
// === 1️⃣ H1 MOVING AVERAGES SETTINGS ===
maType1   = input.string("EMA", "MA 1 Type", options=["EMA","SMA"])
maType2   = input.string("EMA", "MA 2 Type", options=["EMA","SMA"])
maType3   = input.string("EMA", "MA 3 Type", options=["EMA","SMA"])
maType4   = input.string("EMA", "MA 4 Type", options=["EMA","SMA"])

maLength1 = input.int(7,   "MA 1 Length", minval=1)
maLength2 = input.int(40,  "MA 2 Length", minval=1)
maLength3 = input.int(150, "MA 3 Length", minval=1)
maLength4 = input.int(200, "MA 4 Length", minval=1)

showMA1   = input.bool(true, "Show MA 1")
showMA2   = input.bool(true, "Show MA 2")
showMA3   = input.bool(true, "Show MA 3")
showMA4   = input.bool(true, "Show MA 4")
showVWAP  = input.bool(true, "Show H1 VWAP")

// Compute selected MA
getMA(maType, maLen) =>
    maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)

// Compute each MA
ma1 = getMA(maType1, maLength1)
ma2 = getMA(maType2, maLength2)
ma3 = getMA(maType3, maLength3)
ma4 = getMA(maType4, maLength4)

// Plot MAs
plot(showMA1 ? ma1 : na, "MA1", color=color.new(color.green, 0), linewidth=1)
plot(showMA2 ? ma2 : na, "MA2", color=color.new(color.orange, 0), linewidth=1)
plot(showMA3 ? ma3 : na, "MA3", color=color.new(color.red, 0), linewidth=1)
plot(showMA4 ? ma4 : na, "MA4", color=color.new(color.white, 0), linewidth=1)

// ============================================================
// === 2️⃣ VISIBLE MA ARRAY & SORTING ===
var float[] maVisible = array.new_float()
var int[]   maVisibleLen = array.new_int()

array.clear(maVisible)
array.clear(maVisibleLen)

if showMA1
    array.push(maVisible, ma1)
    array.push(maVisibleLen, maLength1)
if showMA2
    array.push(maVisible, ma2)
    array.push(maVisibleLen, maLength2)
if showMA3
    array.push(maVisible, ma3)
    array.push(maVisibleLen, maLength3)
if showMA4
    array.push(maVisible, ma4)
    array.push(maVisibleLen, maLength4)

/// Sort visible by ascending by length
for i = 0 to array.size(maVisible) - 2
    for j = i + 1 to array.size(maVisible) - 1
        if array.get(maVisibleLen, i) > array.get(maVisibleLen, j)
            tempMA  = array.get(maVisible, i)
            tempLen = array.get(maVisibleLen, i)
            array.set(maVisible, i, array.get(maVisible, j))
            array.set(maVisibleLen, i, array.get(maVisibleLen, j))
            array.set(maVisible, j, tempMA)
            array.set(maVisibleLen, j, tempLen)

// ============================================================
// === 3️⃣ EMA SPACING FILTER ===
atrLenEMA  = input.int(40, "EMA Spacing ATR Length", minval=1)
atrPercEMA = input.float(0.25, "EMA Spacing Threshold %", step=0.01)
atrVal = ta.atr(atrLenEMA)

var bool emaTooClose = false
emaTooClose := false   // reset every bar

sz = array.size(maVisible)
if sz >= 2
    for i = 0 to sz - 2
        for j = i + 1 to sz - 1
            emaTooClose := emaTooClose or (math.abs(array.get(maVisible, i) - array.get(maVisible, j)) < atrVal * atrPercEMA)

var bool emaTooClose_prev = false
emaTooClose_prev := emaTooClose[1]

// ============================================================
// === 4️⃣ H1 BIAS ENGINE ===
f_calcH1MABias(_maArr, _pa, _tooClose) =>
    sz = array.size(_maArr)
    if sz < 2
        0
    else
        // --- Assign MAs dynamically
        fastMA       = array.get(_maArr, 0)
        slowest      = array.get(_maArr, sz - 1)
        secondSlowest = sz >= 3 ? array.get(_maArr, sz - 2) : slowest
        thirdSlowest  = sz >= 4 ? array.get(_maArr, sz - 3) : secondSlowest

        MA1 = fastMA              // fastest
        MA2 = thirdSlowest        // 3rd slowest
        MA3 = secondSlowest       // 2nd slowest
        MA4 = slowest             // slowest

        // --- Block bias if MAs are converging
        if _tooClose
            0
        else
            // --- Strict bias conditions
            sBull = (MA3 > MA4) and (MA2 > MA3) and (MA1 > MA2) and (_pa > MA1)
            bull  = (MA3 > MA4) and (MA2 > MA3) and (_pa > MA2)
            sBear = (MA3 < MA4) and (MA2 < MA3) and (MA1 < MA2) and (_pa < MA1)
            bear  = (MA3 < MA4) and (MA2 < MA3) and (_pa < MA2)

            // --- Output bias
            bias = sBull ? 2 : bull ? 1 : sBear ? -2 : bear ? -1 : 0

// === 4. COMPUTE H1 BIAS
H1Bias = f_calcH1MABias(maVisible, close, emaTooClose)

H1BiasText = emaTooClose ? "Neut" : H1Bias == 2 ? "S.Bull" : H1Bias == 1 ? "Bull" : H1Bias == -1 ? "Bear" : H1Bias == -2 ? "S.Bear" : "Neut"

// ============================================================
// === 5️⃣ H1 LADDER SYSTEM ===
showLadder = input.bool(true, "Show Ladder Labels")
xOffset    = 4

// --- Resistance Levels (confirmed)
R150 = ta.highest(high, 150)
R100 = ta.highest(high, 100)
R70  = ta.highest(high, 70)
R40  = ta.highest(high, 40)
R9   = ta.highest(high, 9)

// --- Support Levels (confirmed)
S9   = ta.lowest(low, 9)
S40  = ta.lowest(low, 40)
S70  = ta.lowest(low, 70)
S100 = ta.lowest(low, 100)
S150 = ta.lowest(low, 150)

// --- Persistent labels
var label r150Lbl = na
var label r100Lbl = na
var label r70Lbl  = na
var label r40Lbl  = na
var label r9Lbl   = na

var label s9Lbl   = na
var label s40Lbl  = na
var label s70Lbl  = na
var label s100Lbl = na
var label s150Lbl = na

f_update(lbl, price, txt, col) =>
    if na(lbl)
        label.new(bar_index + xOffset, price, txt,
            xloc=xloc.bar_index, yloc=yloc.price,
            style=label.style_label_left,
            color=col, textcolor=color.white, size=size.small)
    else
        label.set_xy(lbl, bar_index + xOffset, price),
        label.set_text(lbl, txt),
        label.set_color(lbl, col),
        lbl

if barstate.isconfirmed and showLadder
    r150Lbl := f_update(r150Lbl, R150, "R150 " + str.tostring(R150, format.mintick), color.red)
    r100Lbl := f_update(r100Lbl, R100, "R100 " + str.tostring(R100, format.mintick), color.red)
    r70Lbl  := f_update(r70Lbl,  R70,  "R70 "  + str.tostring(R70,  format.mintick), color.red)
    r40Lbl  := f_update(r40Lbl,  R40,  "R40 "  + str.tostring(R40,  format.mintick), color.red)
    r9Lbl   := f_update(r9Lbl,   R9,   "R9 "   + str.tostring(R9,   format.mintick), color.red)

    s9Lbl   := f_update(s9Lbl,   S9,   "S9 "   + str.tostring(S9,   format.mintick), color.green)
    s40Lbl  := f_update(s40Lbl,  S40,  "S40 "  + str.tostring(S40,  format.mintick), color.green)
    s70Lbl  := f_update(s70Lbl,  S70,  "S70 "  + str.tostring(S70,  format.mintick), color.green)
    s100Lbl := f_update(s100Lbl, S100, "S100 " + str.tostring(S100, format.mintick), color.green)
    s150Lbl := f_update(s150Lbl, S150, "S150 " + str.tostring(S150, format.mintick), color.green)

// ============================================================
// ===(H1 Ladder Score System) ===
bullPts = 0
bullPts += S150 < S100 ? 1 : 0
bullPts += S100 < S70  ? 1 : 0
bullPts += S70  < S40  ? 1 : 0
bullPts += S40  < S9   ? 1 : 0

bearPts = 0
bearPts += R150 > R100 ? 1 : 0
bearPts += R100 > R70  ? 1 : 0
bearPts += R70  > R40  ? 1 : 0
bearPts += R40  > R9   ? 1 : 0

netPts = bullPts - bearPts

LadderBias =
     netPts >= 2  ?  2 :
     netPts == 1  ?  1 :
     netPts == -1 ? -1 :
     netPts <= -2 ? -2 : 0

LadderBiasText =
     LadderBias ==  2 ? "S.Bull" :
     LadderBias ==  1 ? "Bull" :
     LadderBias == -1 ? "Bear" :
     LadderBias == -2 ? "S.Bear" : "Neut"

// ==============================
// === 6️⃣H1TF (MA + Ladder + Flush Dot Markers)
H1TFScore = emaTooClose ? 0 : (H1Bias + LadderBias)

// Assign H1TF levels based on cumulative score
H1TF =
     H1TFScore >= 3  ?  2 :   // Strong Bull
     H1TFScore > 0  ?  1 :   // Bull
     H1TFScore <= -3 ? -2 :   // Strong Bear
     H1TFScore < 0  ? -1 : 0 // Bear or Neutral

// Label text for plotting
H1TFText =
     H1TF ==  2 ? "S.Bull" :
     H1TF ==  1 ? "Bull" :
     H1TF == -1 ? "Bear" :
     H1TF == -2 ? "S.Bear" : "Neut"

// ==============================
// FLUSH DOT MARKERS
dotOffset = (high - low) * 0.2
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

minVisibleMA = sz > 0 ? f_array_min(maVisible) : low
maxVisibleMA = sz > 0 ? f_array_max(maVisible) : high
bullDotY = math.min(minVisibleMA, low) - dotOffset
bearDotY = math.max(maxVisibleMA, high) + dotOffset

// -------- H1TF Flush Dots (Differentiated)
plotshape(H1TF == 2 ? bullDotY : na, title="H1TF Strong Bull Flush", location=location.absolute, style=shape.circle, size=size.small, color=color.lime)
plotshape(H1TF == 1 ? bullDotY : na, title="H1TF Bull Flush", location=location.absolute, style=shape.circle, size=size.tiny, color=color.rgb(2, 79, 5))
plotshape(H1TF == -2 ? bearDotY : na, title="H1TF Strong Bear Flush", location=location.absolute, style=shape.circle, size=size.small, color=color.red)
plotshape(H1TF == -1 ? bearDotY : na, title="H1TF Bear Flush", location=location.absolute, style=shape.circle, size=size.tiny, color=color.rgb(91, 3, 3))

// ===================================================================================
// ===7️⃣ KeyBars Concept EBull, EBear & LTB ===
showEBull = input.bool(true, "Show Engulfing Bullish")
showEBear = input.bool(true, "Show Engulfing Bearish")
showLTBBull = input.bool(true, "Show LTB Bullish")
showLTBBear = input.bool(true, "Show LTB Bearish")

atrLenGlobal = input.int(40, "ATR Length (Global)", minval=1)
atrPercGlobal = input.float(0.72, "ATR % Threshold (Global)", step=0.01, minval=0.0, maxval=10.0)

overrideLTB = input.bool(false, "Override ATR for LTB")
ltbAtrLen = input.int(40, "LTB ATR Length", minval=1)
ltbAtrPerc = input.float(0.72, "LTB ATR %", step=0.01, minval=0.0, maxval=10.0)

overrideEB = input.bool(false, "Override ATR for Engulfings")
ebAtrLen = input.int(40, "EB ATR Length", minval=1)
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
// === LABELS & OFFSETS (Stable Version) ===
// ======================

// Core range metrics
candleRange = range1
atrBase     = ta.atr(40)

// Stable dynamic offset (original behavior)
dynamicOffset = math.max(candleRange * 0.6, atrBase * 0.6)

// Final Y placements (NO stacking)
offsetAbove = high[1] + dynamicOffset
offsetBelow = low[1]  - dynamicOffset

// Label buffer
var label[] labels = array.new<label>()
maxLabels = 70

cleanup() =>
    while array.size(labels) > maxLabels
        old = array.shift(labels)
        label.delete(old)

// =============================
// === APPLY LABELS ON CONFIRM ===
// =============================
if barstate.isconfirmed

    // EBULL (below)
    if showEBull and isEBull
        l = label.new(
            bar_index[1], offsetBelow, "EBull",
            style     = label.style_label_up,
            color     = color.rgb(5,85,7),
            textcolor = color.white
        )
        array.push(labels, l)
        cleanup()

    // EBEAR (above)
    if showEBear and isEBear
        l = label.new(
            bar_index[1], offsetAbove, "EBear",
            style     = label.style_label_down,
            color     = color.rgb(97,7,7),
            textcolor = color.white
        )
        array.push(labels, l)
        cleanup()

    // LTB BULL (below)
    if showLTBBull and isLTBBull
        l = label.new(
            bar_index[1], offsetBelow, "LTB",
            style     = label.style_label_up,
            color     = color.green,
            textcolor = color.white
        )
        array.push(labels, l)
        cleanup()

    // LTB BEAR (above)
    if showLTBBear and isLTBBear
        l = label.new(
            bar_index[1], offsetAbove, "LTB",
            style     = label.style_label_down,
            color     = color.red,
            textcolor = color.white
        )
        array.push(labels, l)
        cleanup()
        
// =============================
// ===8️⃣ DAILY & WEEKLY PIVOTS ===
// ----- Inputs -----
showDP  = input.bool(true,  "Show Daily Pivot (DP)")
showWP  = input.bool(true,  "Show Weekly Pivot (WP)")
dpColor = input.color(color.new(#7bb2f8, 0), "DP Color")
wpColor = input.color(color.new(#b6fe50, 0), "WP Color")

// ----- Session Change Detection -----
isNewDay  = timeframe.change("1D")
isNewWeek = timeframe.change("1W")

// === DAILY PIVOT ENGINE ==============================================
// Storage variables (persist across bars)
var float prevDayHigh  = na
var float prevDayLow   = na
var float prevDayClose = na
var float dp           = na

// Initialize values on first script bar
if na(prevDayHigh)
    prevDayHigh  := high
    prevDayLow   := low
    prevDayClose := close

// Update / Reset logic
if isNewDay
    // Lock yesterday's pivot
    dp := (prevDayHigh + prevDayLow + prevDayClose) / 3

    // Reset with current bar
    prevDayHigh  := high
    prevDayLow   := low
else
    // Accumulate today's session
    prevDayHigh := math.max(prevDayHigh, high)
    prevDayLow  := math.min(prevDayLow, low)

// Always store last close
prevDayClose := close

// === WEEKLY PIVOT ENGINE =============================================
var float prevWeekHigh  = na
var float prevWeekLow   = na
var float prevWeekClose = na
var float wp            = na

// Initialize on first bar
if na(prevWeekHigh)
    prevWeekHigh  := high
    prevWeekLow   := low
    prevWeekClose := close

if isNewWeek
    // Lock last week's pivot
    wp := (prevWeekHigh + prevWeekLow + prevWeekClose) / 3

    // Reset with current bar
    prevWeekHigh := high
    prevWeekLow  := low
else
    // Accumulate this week's session
    prevWeekHigh := math.max(prevWeekHigh, high)
    prevWeekLow  := math.min(prevWeekLow, low)

// Always store last close
prevWeekClose := close

// === PLOTTING =========================================================
plot(showDP ? dp : na, "Daily Pivot (DP)",  dpColor, 1)
plot(showWP ? wp : na, "Weekly Pivot (WP)", wpColor, 3)

// ======================
// ===9️⃣ H1 VWAP ===
vwapH1 = ta.vwap(close)

// Determine VWAP bias
VWAPBias = close > vwapH1 ? 1 : close < vwapH1 ? -1 : 0
VWAPBiasText = VWAPBias == 1 ? "Bull" : VWAPBias == -1 ? "Bear" : "Neut"
VWAPColor = VWAPBias == 1 ? color.green : VWAPBias == -1 ? color.red : color.gray

// ============================================================================
// ===🔟 HIGHER TIMEFRAME (HTF) BIAS ENGINE — CLEAN PATCH

// HTF Settings
// ----------------------
htfH4 = "240"      // H4 timeframe
htfD  = "D"        // Daily timeframe

// ----------------------
// Fetch HTF Moving Averages
// ----------------------
f_getHTFMAs(tf) =>
    request.security(
        syminfo.tickerid,
        tf,
        [
            ta.ema(close, 40),
            ta.ema(close, 150),
            ta.sma(close, 200)
        ],
        barmerge.gaps_off,
        barmerge.lookahead_off
    )

// ----------------------
// Calculate Bias from MA Flush
// ----------------------
f_calcHTFBias(ma40, ma150, ma200, price) =>
    bull = price > ma40 and ma40 > ma150 and ma150 > ma200
    bear = price < ma40 and ma40 < ma150 and ma150 < ma200
    bull ? 1 : bear ? -1 : 0

// ----------------------
// Retrieve HTF MA Values
// ----------------------
[h4_ema40, h4_ema150, h4_sma200] = f_getHTFMAs(htfH4)
[d_ema40,  d_ema150,  d_sma200 ] = f_getHTFMAs(htfD)

// Use H1 close for confirmation
priceH1 = close

// ----------------------
// Individual HTF Bias
// ----------------------
H4Bias = f_calcHTFBias(h4_ema40, h4_ema150, h4_sma200, priceH1)
DBias  = f_calcHTFBias(d_ema40,  d_ema150,  d_sma200,  priceH1)

// ----------------------
// Individual HTF Text
// ----------------------
H4BiasText = H4Bias ==  1 ? "Bull" :
             H4Bias == -1 ? "Bear" : "Neut"

DBiasText  = DBias  ==  1 ? "Bull" :
             DBias  == -1 ? "Bear" : "Neut"

// ----------------------
// Individual HTF Colors
// ----------------------
H4Color = H4Bias ==  1 ? color.green :
          H4Bias == -1 ? color.red : color.gray

DColor  = DBias  ==  1 ? color.green :
          DBias  == -1 ? color.red : color.gray
// ----------------------
// Combined HTF Bias Engine
// ----------------------
HTFScore = DBias + H4Bias    // Range: -2 .. +2

// HTF value: strong / normal / neutral
HTF = HTFScore > 1 ? 2 : HTFScore == 1 ? 1 : HTFScore == -1 ? -1 : HTFScore < -1 ? -2 : 0

// HTF Output Text (simplified)
HTFText = HTF == 2 ? "S.Bull" : HTF == 1 ? "Bull" : HTF == -1 ? "Bear" : HTF == -2 ? "S.Bear" : "Neut"

// HTF Output Color (simplified strong/normal/neutral)
HTFColor = HTF > 0 ? color.green : HTF < 0 ? color.red : color.gray

//===1️⃣1️⃣  Final Verdict
VerdictScore = HTF + H1TF
VerdictText  = VerdictScore == 4  ? "S. Bullish" :
               VerdictScore == -4 ? "S. Bearish" : "Neut"

// Only strong verdicts affect bottom row
VerdictColorValue = VerdictScore == 4 ? color.green : VerdictScore == -4 ? color.red : color.gray

// Header row: only light up if verdict is strong
VerdictColorHeader = (VerdictScore == 4 or VerdictScore == -4) ? VerdictColorValue : color.gray

//===1️⃣2️⃣ Create / Update Bias Table
var table biasTable = table.new(position.top_right, 8, 2, frame_color=color.gray, frame_width=1, border_width=1)

// --- Helper functions
// Header row: light up for any Bull/Bear
f_biasColorHeader(bias) => (bias == 2 or bias == 1) ? color.lime : (bias == -2 or bias == -1) ? color.red : color.gray

// Bottom row: light up only for strong bias (S.Bull/S.Bear)
f_biasColorValue(bias)  => bias == 2 ? color.lime : bias == -2 ? color.maroon : color.gray

// --- Update table
if barstate.isconfirmed
    // Row 0: headers (only strong bias lights up)
    table.cell(biasTable,0,0,"D",bgcolor=f_biasColorHeader(DBias),text_color=color.white)
    table.cell(biasTable,1,0,"H4",bgcolor=f_biasColorHeader(H4Bias),text_color=color.white)
    table.cell(biasTable,2,0,"HTF",bgcolor=f_biasColorHeader(HTF),text_color=color.white)
    table.cell(biasTable,3,0,"H1",bgcolor=f_biasColorHeader(H1Bias),text_color=color.white)
    table.cell(biasTable,4,0,"Ladder",bgcolor=f_biasColorHeader(LadderBias),text_color=color.white)
    table.cell(biasTable,5,0,"H1TF",bgcolor=f_biasColorHeader(H1TF),text_color=color.white)
    table.cell(biasTable,6,0,"VWAP",bgcolor=f_biasColorHeader(VWAPBias),text_color=color.white)
    table.cell(biasTable,7,0,"Verdict", bgcolor=VerdictColorHeader, text_color=color.white)

    // Row 1: values (normal and strong bias)
    table.cell(biasTable,0,1,DBiasText,bgcolor=f_biasColorValue(DBias),text_color=color.white)
    table.cell(biasTable,1,1,H4BiasText,bgcolor=f_biasColorValue(H4Bias),text_color=color.white)
    table.cell(biasTable,2,1,HTFText,bgcolor=f_biasColorValue(HTF),text_color=color.white)
    table.cell(biasTable,3,1,H1BiasText,bgcolor=f_biasColorValue(H1Bias),text_color=color.white)
    table.cell(biasTable,4,1,LadderBiasText,bgcolor=f_biasColorValue(LadderBias),text_color=color.white)
    table.cell(biasTable,5,1,H1TFText,bgcolor=f_biasColorValue(H1TF),text_color=color.white)
    table.cell(biasTable,6,1,VWAPBiasText,bgcolor=f_biasColorValue(VWAPBias),text_color=color.white)
    table.cell(biasTable,7,1,VerdictText, bgcolor=VerdictColorValue, text_color=color.white)

// ======================
// === RSI + RSI MA ALERTS (Updated Logic) ===

// Inputs
rsiLen      = input.int(14, "RSI Length")
rsiMALen    = input.int(14, "RSI MA Length")
rsiSource   = input.source(close, "RSI Source")

// Extreme levels
upperBreak  = input.float(71.5, "RSI Bull Break Level")
lowerBreak  = input.float(28.5, "RSI Bear Break Level")
upperMA     = input.float(67, "RSI MA Bearish Threshold")
lowerMA     = input.float(33, "RSI MA Bullish Threshold")

// RSI Calculations
rsiValue    = ta.rsi(rsiSource, rsiLen)
rsiMA       = ta.sma(rsiValue, rsiMALen)

// 🔶 ALERT 1 — RSI Breakout (No MA Required)

// Bullish breakout above 71.5
alert1Bull = barstate.isconfirmed and (rsiValue[1] < upperBreak) and (rsiValue >= upperBreak)

// Bearish breakout below 28.5
alert1Bear = barstate.isconfirmed and (rsiValue[1] > lowerBreak) and (rsiValue <= lowerBreak)

// 🔶 ALERT 2 — RSI Retracement Confirmation
// Must return from deep extreme + MA condition + crossover

// Bullish retracement (from oversold up)
// 1. RSI was below 28.5
// 2. RSI crosses up above 28.5
// 3. RSI MA  33
// 4. Cross must occur
alert2Bull = barstate.isconfirmed and rsiValue[1] < lowerBreak and rsiValue >= lowerBreak and rsiMA >= lowerMA and ta.crossover(rsiValue, rsiMA)

// Bearish retracement (from overbought down)
// 1. RSI was above 71.5
// 2. RSI crosses down below 71.5
// 3. RSI MA ≥ 67
// 4. Cross must occur
alert2Bear = barstate.isconfirmed and rsiValue[1] > upperBreak and rsiValue <= upperBreak and rsiMA >= upperMA and ta.crossunder(rsiValue, rsiMA)

// RSI Label Offsets (as % of price)
rsiOffsetPctUp   = input.float(0.14, "RSI Offset Up %", step=0.01, minval=0.0, maxval=5.0)
rsiOffsetPctDown = input.float(0.14, "RSI Offset Down %", step=0.01, minval=0.0, maxval=5.0)

// Compute dynamic offsets
rsiOffsetUpValue   = close * rsiOffsetPctUp / 100
rsiOffsetDownValue = close * rsiOffsetPctDown / 100

// RSI ALERT SHAPES (Shifted dynamically)
// Alert 1: Breakouts (tiny triangles)
plotshape(alert1Bull ? low - rsiOffsetDownValue : na, title="RSI Breakout Bull", 
     location=location.absolute, style=shape.triangleup, size=size.tiny, color=color.new(#5d5bd3, 0))

plotshape(alert1Bear ? high + rsiOffsetUpValue : na, title="RSI Breakout Bear", 
     location=location.absolute, style=shape.triangledown, size=size.tiny, color=color.new(#fc0404, 0))

// Alert 2: Retracements (slightly bigger triangles)
plotshape(alert2Bull ? low - rsiOffsetDownValue*2 : na, title="RSI Retracement Bull", 
     location=location.absolute, style=shape.triangleup, size=size.small, color=color.new(#869bf9, 0))

plotshape(alert2Bear ? high + rsiOffsetUpValue*2 : na, title="RSI Retracement Bear", 
     location=location.absolute, style=shape.triangledown, size=size.small, color=color.new(#ff8e8e, 0))

// 🔶 Alert Conditions (for TradingView alerts panel)
alertcondition(alert1Bull, title="RSI Bull Breakout", message="RSI broke above 71.5")
alertcondition(alert1Bear, title="RSI Bear Breakout", message="RSI broke below 28.5")
alertcondition(alert2Bull, title="RSI Bull Retracement", message="Bullish RSI retracement setup")
alertcondition(alert2Bear, title="RSI Bear Retracement", message="Bearish RSI retracement setup")

// DAILY SESSION LABELS & LINES (Circular Buffer, Last 10 days)
showDayLines    = input.bool(true, "Show Daily Session Lines")
dayLabelSizeStr = input.string("normal", "Day Label Size", options = ["tiny", "small", "normal"])
dayLineColor    = input.color(color.new(color.gray, 70), "Day Line Color")
dayTextColor    = input.color(color.white, "Day Text Color")

// Label size resolver
labelSize =
     dayLabelSizeStr == "tiny"  ? size.tiny  :
     dayLabelSizeStr == "small" ? size.small :
     size.normal

maxDays = 10  // circular buffer size

// Circular index
var int dayIndex = -1

// Preallocate arrays
var label[] dayLabels = array.new<label>(maxDays)
var line[]  dayLines  = array.new<line>(maxDays)

// Day names (stable)
dayName =
     dayofweek == dayofweek.monday    ? "MON" :
     dayofweek == dayofweek.tuesday   ? "TUE" :
     dayofweek == dayofweek.wednesday ? "WED" :
     dayofweek == dayofweek.thursday  ? "THU" :
     dayofweek == dayofweek.friday    ? "FRI" :
     dayofweek == dayofweek.saturday  ? "SAT" : "SUN"

// Adaptive bottom Y anchor
bottomY = ta.lowest(low, 150) - ta.atr(40) * 0.4

// Execute only when day changes
// ======================
if showDayLines and isNewDay
    // Move circular index
    dayIndex := (dayIndex + 1) % maxDays

    // === LABEL HANDLING ===
    oldLabel = array.get(dayLabels, dayIndex)

    if na(oldLabel)
        // Create new label
        newLabel = label.new(
            x = bar_index,
            y = bottomY,
            text = dayName,
            xloc = xloc.bar_index,
            yloc = yloc.price,
            style = label.style_label_center,
            size = labelSize,
            textcolor = dayTextColor,
            color = color.new(color.white, 100)
        )
        array.set(dayLabels, dayIndex, newLabel)
    else
        // Recycle existing label
        label.set_xy(oldLabel, bar_index, bottomY)
        label.set_text(oldLabel, dayName)
        label.set_size(oldLabel, labelSize)
        label.set_textcolor(oldLabel, dayTextColor)

    // === LINE HANDLING ===
    oldLine = array.get(dayLines, dayIndex)

    if na(oldLine)
        // Create new day line
        newLine = line.new(
            x1 = bar_index, y1 = low,
            x2 = bar_index, y2 = high,
            xloc = xloc.bar_index,
            extend = extend.both,
            color = dayLineColor,
            width = 1
        )
        array.set(dayLines, dayIndex, newLine)
    else
        // Recycle existing line
        line.set_x1(oldLine, bar_index)
        line.set_x2(oldLine, bar_index)
        line.set_color(oldLine, dayLineColor)

// ==============================
// =====================================================================
// === PHASE 1 ALERTS — STATE-BASED, TOGGLE-FRIENDLY, NON-REPAINT
// =====================================================================

// ─────────────────────────────────────────────────────────────────────
// ALERT INPUTS
// ─────────────────────────────────────────────────────────────────────
alertEnable = input.bool(true, "Enable Alerts", group="Alerts")

alertBiasStates   = input.bool(true,  "H1 Bias Alerts",        group="Alerts • States")
alertHTFStates    = input.bool(true,  "HTF Bias Alerts",       group="Alerts • States")
alertH1TFStates   = input.bool(true,  "H1TF Composite Alerts", group="Alerts • States")
alertLadderStates = input.bool(false, "Ladder Bias Alerts",    group="Alerts • States")

alertStrongOnly        = input.bool(true, "Strong Bias Only",   group="Alerts • Filters")
alertLadderStrongOnly = input.bool(true, "Strong Ladder Only", group="Alerts • Filters")

alertKeyBars = input.bool(true, "KeyBar Alerts (EB / LTB)", group="Alerts • Execution")
filterKeyBarByH1TF = input.bool(true,  "KeyBars align with H1TF", group="Alerts • Execution")
filterKeyBarByHTF  = input.bool(false, "KeyBars align with HTF",  group="Alerts • Execution")

// ─────────────────────────────────────────────────────────────────────
// STATE MEMORY (ANTI-SPAM)
// ─────────────────────────────────────────────────────────────────────
H1Bias_prev  = H1Bias[1]
HTF_prev     = HTF[1]
H1TF_prev    = H1TF[1]
Ladder_prev  = LadderBias[1]

// ─────────────────────────────────────────────────────────────────────
// STATE FLIP DETECTION
// ─────────────────────────────────────────────────────────────────────
H1BiasFlip = (
    barstate.isconfirmed and
    alertEnable and
    alertBiasStates and
    (H1Bias != H1Bias_prev)
)

HTFFlip = (
    barstate.isconfirmed and
    alertEnable and
    alertHTFStates and
    (HTF != HTF_prev)
)

H1TFFlip = (
    barstate.isconfirmed and
    alertEnable and
    alertH1TFStates and
    (H1TF != H1TF_prev)
)

LadderFlip = (
    barstate.isconfirmed and
    alertEnable and
    alertLadderStates and
    (LadderBias != Ladder_prev)
)

// ─────────────────────────────────────────────────────────────────────
// ALIGNMENT FILTERS FOR KEYBARS
// ─────────────────────────────────────────────────────────────────────
keyBarBullOK = (
    (not filterKeyBarByH1TF or H1TF > 0) and
    (not filterKeyBarByHTF  or HTF  > 0)
)

keyBarBearOK = (
    (not filterKeyBarByH1TF or H1TF < 0) and
    (not filterKeyBarByHTF  or HTF  < 0)
)

// ─────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS — SINGLE-LINE, TOGGLE-FRIENDLY
// ─────────────────────────────────────────────────────────────────────
alertcondition(barstate.isconfirmed and alertEnable and alertBiasStates and (H1Bias != H1Bias[1]) and (not alertStrongOnly or math.abs(H1Bias) == 2), title="H1 Bias Flip", message="H1 Bias flipped")
alertcondition(barstate.isconfirmed and alertEnable and alertHTFStates and (HTF != HTF[1]), title="HTF Bias Flip", message="HTF Bias flipped")
alertcondition(barstate.isconfirmed and alertEnable and alertH1TFStates and (H1TF != H1TF[1]), title="H1TF Composite Flip", message="H1TF Composite flipped")
alertcondition(barstate.isconfirmed and alertEnable and alertLadderStates and (LadderBias != LadderBias[1]) and (not alertLadderStrongOnly or math.abs(LadderBias) == 2), title="Ladder Bias Flip", message="Ladder Bias flipped")
alertcondition(barstate.isconfirmed and alertEnable and alertKeyBars and isEBull and ((not filterKeyBarByH1TF or H1TF > 0) and (not filterKeyBarByHTF or HTF > 0)), title="Bullish Engulfing", message="Bullish Engulfing detected")
alertcondition(barstate.isconfirmed and alertEnable and alertKeyBars and isEBear and ((not filterKeyBarByH1TF or H1TF < 0) and (not filterKeyBarByHTF or HTF < 0)), title="Bearish Engulfing", message="Bearish Engulfing detected")
alertcondition(barstate.isconfirmed and alertEnable and alertKeyBars and isLTBBull and ((not filterKeyBarByH1TF or H1TF > 0) and (not filterKeyBarByHTF or HTF > 0)), title="LTB Bullish", message="Bullish Long-Tail Bar detected")
alertcondition(barstate.isconfirmed and alertEnable and alertKeyBars and isLTBBear and ((not filterKeyBarByH1TF or H1TF < 0) and (not filterKeyBarByHTF or HTF < 0)), title="LTB Bearish", message="Bearish Long-Tail Bar detected")
````

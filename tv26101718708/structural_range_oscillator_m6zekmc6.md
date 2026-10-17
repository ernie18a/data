# Structural Range Oscillator

- url: https://www.tradingview.com/script/m6Zekmc6/
- type: indicator
- pine_id: PUB;0465483cac3b4bf0b67cc774d212db38
- version: 1.0

## Description

█ OVERVIEW
Structural Range Oscillator is a structure-based oscillator that operates within the current market range, dynamically adapting to price extremes or relying on confirmed swing points (pivots).
The indicator measures the position of price within the current market structure, showing whether price is closer to the upper boundary, lower boundary, or equilibrium.
This allows you to analyze:
* structural context of price
* market phases (balance vs expansion)
* transitions between extremes

█ CONCEPTS
Structural Range
The indicator defines a working range using two modes:

Trailing Range (dynamic)
The range updates continuously, but asymmetrically:
* one side of the range (in the direction of price expansion) updates immediately with new highs/lows
* the opposite side updates only after a confirmed pivot forms
This means:
* the range expands quickly in the direction of the move
* but contracts or resets only after structural confirmation
Result:
* fast adaptation to trend
* but in strong trends it may generate more false signals (range keeps shifting with price)

Pivot Range (static)
The range is based entirely on confirmed pivots:
* pivot high/low is formed only after a defined number of candles on both sides (Pivot Length)
* both range boundaries update only after confirmation
This results in:
* delayed updates
* higher structural reliability
* reduced noise and fewer false signals
In practice:
* trailing mode = faster, reactive
* pivot mode = slower, but structurally cleaner

Oscillator Logic
The oscillator calculates price position within the range:
* 0 → price at range low
* 50 → midpoint (equilibrium)
* 100 → price at range high
This helps identify:
* stretched conditions
* relative positioning within structure

Midline (50) – Equilibrium
The 50 level acts as:
* directional bias divider (bullish / bearish)
* dynamic equilibrium level
* short-term directional filter

Persistent Mid Trend
The midpoint of the range (mid) has its own directional behavior:
* rising → structural uptrend
* falling → structural downtrend
This provides an additional layer of trend context independent of the oscillator.
Additionally, an optional feature allows:
* candle coloring based on mid trend direction
which makes trend filtering visually intuitive.

Overbought / Oversold (OB / OS)
OB / OS levels:
* exist within the 0–100 range
* are NOT the range boundaries themselves
They can be adjusted depending on your strategy:
* tighter levels → more signals
* wider levels → more selective signals
Interpretation depends on mode:
* trailing mode → more frequent signals in trends (some may be false due to shifting range)
* pivot mode → fewer but more structurally confirmed signals

█ FEATURES
The indicator offers flexible configuration:
* range mode (Trailing vs Pivot)
* oscillator smoothing (SMA, EMA, RMA, WMA)
* adjustable OB / OS levels (within 0–100 range)
* dynamic transparency of levels - for consistent solid lines, set equal values (e.g. 10)
* gradient fill (momentum visualization)
* range overlay on chart (high / low / mid)
* candle coloring based on mid trend
* channel gradient (range visualization)
* Fibonacci levels based on current range
* alerts

█ APPLICATIONS
Range Trading
In consolidation:
* range high → resistance
* range low → support
* mid → equilibrium
The oscillator acts as a map of market structure.

Trend Context
Combining:
* oscillator position (0–100)
* midline direction
helps determine:
* whether the market is trending
* or just reacting within a range

Breakout Context
If:
* price holds near extremes
* and the range expands (Trailing Mode)
→ it may indicate volatility expansion and continuation

Fibonacci Levels
Fibonacci levels are dynamically derived from the current range:
* anchored based on the latest directional move (0 at high or low)
* update automatically as range evolves
Applications:
* identifying retracement zones within the range
* potential reaction levels
* added confluence with range boundaries and mid
Especially useful when:
* price returns into the range after an impulse
* looking for structured pullback zones

Confluence & Confirmation
The indicator is most effective when combined with other tools:
* if range boundaries align with key support/resistance → higher probability of reaction
* combine with momentum indicators → oscillator signals can act as early signals, while momentum confirms direction
* use structure + momentum together instead of relying on signals alone

Context interpretation
* oscillator near 50 → market in balance
* oscillator near extremes → tension / possible reversal or continuation
* rising mid → bullish structure
* falling mid → bearish structure

█ NOTES
The indicator measures price position within structure, not traditional momentum.
This means:
* it provides contextual insight rather than standalone signals
* it is best used as a decision-support tool, not a trigger on its own

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Structural Range Oscillator", overlay=false)

// INPUTS 
// Pivot Length 
lenSwing = input.int(15, "Pivot Length", minval=1)

// Mode 
useTrailing = input.bool(true, "Use Trailing Range (Dynamic)", 
     group="Mode",
     tooltip="When enabled, the range continuously trails new price highs and lows (dynamic behavior).\nWhen disabled, the range is based on fixed swing pivots.")

// OSCILLATOR SECTION
// Smoothing 
smoothOsc = input.bool(true, "Smooth Oscillator Line", group="Oscillator Smoothing")
smoothLen = input.int(3, "Smoothing Length", minval=1, group="Oscillator Smoothing")
smoothType = input.string("SMA", "Smoothing Method", options=["SMA", "EMA", "RMA", "WMA"], group="Oscillator Smoothing")

// Oscillator Colors 
colBullMain = input.color(color.rgb(6, 162, 47), "Bullish Color (Line / Gradient)", group = "Oscillator Colors")
colBearMain = input.color(color.rgb(207, 23, 23), "Bearish Color (Line / Gradient)", group = "Oscillator Colors")

// Band Levels 
obLevel = input.int(93, "Overbought Level", minval=50, maxval=100, group="Band Levels")
osLevel = input.int(7, "Oversold Level", minval=0, maxval=50, group="Band Levels")

// Band Colors & Settings 
colOB = input.color(color.rgb(207, 23, 23), "Overbought Color", group = "Band Colors & Settings")
colOS = input.color(color.rgb(6, 162, 47), "Oversold Color", group = "Band Colors & Settings")
useDynamicLevels = input.bool(true, "Dynamic OB/OS Transparency", group = "Band Colors & Settings")
minTransp = input.int(90, "Minimum Transparency (weak signal)", minval=0, maxval=100, group="Band Colors & Settings")
maxTransp = input.int(10, "Maximum Transparency (strong signal)", minval=0, maxval=100, group="Band Colors & Settings")
levelLineWidth = input.int(3, "OB/OS Line Thickness", minval=1, maxval=6, group="Band Colors & Settings")
useGradient = input.bool(true, "Use Gradient Fill", group = "Band Colors & Settings")
peakTransp = input.int(65, "Gradient Peak Transparency", minval=0, maxval=100, group = "Band Colors & Settings")

// Channel Lines 
colorCandlesWithTrend = input.bool(false, "Color Candles According to Trend", group="Channel Lines")
showOverlayLines = input.bool(true, "Show Range Lines on Chart", group="Channel Lines")
highColor = input.color(color.rgb(207, 23, 23), "High Line Color", group="Channel Lines")
lowColor = input.color(color.rgb(6, 162, 47), "Low Line Color", group="Channel Lines")
showMidLine = input.bool(true, "Show Mid Line on Chart", group="Channel Lines")
midUpColor = input.color(color.rgb(6, 162, 47), "Mid Line Up Color", group="Channel Lines")
midDownColor = input.color(color.rgb(207, 23, 23), "Mid Line Down Color", group="Channel Lines")
useOverlayGradient = input.bool(true, "Use Gradient Fill Between Channel & Mid", group="Channel Lines")
overlayGradientTransp = input.int(85, "Overlay Gradient Transparency", minval=70, maxval=95, group="Channel Lines")

// Fibonacci Settings
showFibo = input.bool(true, "Show Fibonacci Levels", group="Fibonacci Levels")
fiboOffset = input.int(5, "Right Offset from Last Bar (bars)", minval=0, group="Fibonacci Levels")
fiboLineColor = input.color(color.new(#787B86, 10), "Fibonacci Line Color", group="Fibonacci Levels")
fiboLineWidth = input.int(1, "Fibonacci Line Width", minval=1, maxval=4, group="Fibonacci Levels")
showFiboLabels = input.bool(true, "Show Fibonacci Labels", group="Fibonacci Levels")

// PIVOTS 
ph = ta.pivothigh(high, lenSwing, lenSwing)
pl = ta.pivotlow(low, lenSwing, lenSwing)
var float lastPH = na
var float lastPL = na
var int lastPH_bar = na
var int lastPL_bar = na
var float trailingHigh = na
var float trailingLow = na
var bool lastTrailingUpdateWasHigh = true
var bool fibZeroOnHigh = true

// Update pivots
if not na(ph)
    lastPH := ph
    lastPH_bar := bar_index
    trailingHigh := ph
    lastTrailingUpdateWasHigh := true
if not na(pl)
    lastPL := pl
    lastPL_bar := bar_index
    trailingLow := pl
    lastTrailingUpdateWasHigh := false

trailingHigh := useTrailing ? math.max(nz(trailingHigh, high), high) : na
trailingLow := useTrailing ? math.min(nz(trailingLow, low), low) : na

// ZERO FIB LOGIC 
if useTrailing
    if high > nz(trailingHigh[1])
        lastTrailingUpdateWasHigh := true
        fibZeroOnHigh := true
    if low < nz(trailingLow[1])
        lastTrailingUpdateWasHigh := false
        fibZeroOnHigh := false
else
    fibZeroOnHigh := lastTrailingUpdateWasHigh

// RANGE
float rangeHigh = useTrailing ? (na(trailingHigh) ? close : trailingHigh) : (na(lastPH) ? close : lastPH)
float rangeLow = useTrailing ? (na(trailingLow) ? close : trailingLow) : (na(lastPL) ? close : lastPL)
rangeHigh := na(rangeHigh) ? close : rangeHigh
rangeLow := na(rangeLow) ? close : rangeLow
float rangeMid = (rangeHigh + rangeLow) / 2

// PERSISTENT TREND
var int midTrend = 0
if rangeMid > nz(rangeMid[1])
    midTrend := 1
else if rangeMid < nz(rangeMid[1])
    midTrend := -1
color midPlotColor = midTrend == 1 ? midUpColor : midDownColor

// OSCILLATOR
float osc_raw = na
if rangeHigh != rangeLow
    osc_raw := (close - rangeLow) / (rangeHigh - rangeLow) * 100
osc_raw := math.max(0, math.min(100, nz(osc_raw, 50)))
float osc = osc_raw
if smoothOsc and smoothLen >= 2
    osc := switch smoothType
        "SMA" => ta.sma(osc_raw, smoothLen)
        "EMA" => ta.ema(osc_raw, smoothLen)
        "RMA" => ta.rma(osc_raw, smoothLen)
        "WMA" => ta.wma(osc_raw, smoothLen)
        => osc_raw

// HELPER FUNCTIONS
remap(val, inMin, inMax, outMin, outMax) =>
    outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin)

getDynamicOBColor() =>
    if not useDynamicLevels
        colOB
    else
        rawDist = obLevel - osc
        clamped = math.max(0, math.min(rawDist, obLevel - 50))
        transp = math.round(remap(clamped, 0, obLevel - 50, maxTransp, minTransp))
        color.new(colOB, transp)

getDynamicOSColor() =>
    if not useDynamicLevels
        colOS
    else
        rawDist = osc - osLevel
        clamped = math.max(0, math.min(rawDist, 50 - osLevel))
        transp = math.round(remap(clamped, 0, 50 - osLevel, maxTransp, minTransp))
        color.new(colOS, transp)

trendBull = osc >= 50
oscLineColor = trendBull ? colBullMain : colBearMain

// PLOTTING
hline(50, "Mid", color = color.gray, linestyle = hline.style_dashed)

plot(useDynamicLevels ? obLevel : na, "Overbought Level", color = getDynamicOBColor(), linewidth = levelLineWidth)
plot(useDynamicLevels ? osLevel : na, "Oversold Level", color = getDynamicOSColor(), linewidth = levelLineWidth)

pOsc = plot(osc, color = na, display = display.none)
pMidOsc = plot(50, color = na, display = display.none)

bullPeak = color.new(colBullMain, peakTransp)
bullMid = color.new(colBullMain, 95)
bearPeak = color.new(colBearMain, peakTransp)
bearMid = color.new(colBearMain, 95)

fill(pOsc, pMidOsc,
     top_value = useGradient and osc > 50 ? osc : na,
     bottom_value = useGradient and osc > 50 ? 50 : na,
     top_color = useGradient and osc > 50 ? bullPeak : na,
     bottom_color = useGradient and osc > 50 ? bullMid : na)
fill(pMidOsc, pOsc,
     top_value = useGradient and osc < 50 ? 50 : na,
     bottom_value = useGradient and osc < 50 ? osc : na,
     top_color = useGradient and osc < 50 ? bearMid : na,
     bottom_color = useGradient and osc < 50 ? bearPeak : na)

plot(osc, "Structural Range Oscillator", color=oscLineColor, linewidth=2)

// OVERLAY LINES 
plot(showOverlayLines ? rangeHigh : na, title="Range High", color=highColor, linewidth=1, force_overlay=true)
plot(showOverlayLines ? rangeLow : na, title="Range Low", color=lowColor, linewidth=1, force_overlay=true)
plot(showMidLine ? rangeMid : na, title="Range Mid", color=midPlotColor, linewidth=1, force_overlay=true)

pHighOverlay = plot(rangeHigh, color = na, display = display.none, force_overlay = true)
pLowOverlay = plot(rangeLow, color = na, display = display.none, force_overlay = true)
pMidOverlayGradient = plot(rangeMid, color = na, display = display.none, force_overlay = true)

fill(pMidOverlayGradient, pHighOverlay,
     top_value = useOverlayGradient ? rangeHigh : na,
     bottom_value = useOverlayGradient ? rangeMid : na,
     top_color = useOverlayGradient ? color.new(highColor, overlayGradientTransp) : na,
     bottom_color = useOverlayGradient ? color.new(highColor, 100) : na)

fill(pLowOverlay, pMidOverlayGradient,
     top_value = useOverlayGradient ? rangeMid : na,
     bottom_value = useOverlayGradient ? rangeLow : na,
     top_color = useOverlayGradient ? color.new(lowColor, 100) : na,
     bottom_color = useOverlayGradient ? color.new(lowColor, overlayGradientTransp) : na)

barcolor(colorCandlesWithTrend ? midPlotColor : na, title="Candle Trend Color")

// FIBONACCI 
var array<line> fibLines = array.new<line>()
var array<label> fibLabels = array.new<label>()
if barstate.isfirst
    for i = 0 to 6
        line l = line.new(na, na, na, na, color = fiboLineColor, width = fiboLineWidth, style = line.style_dashed, force_overlay = true)
        label lb = label.new(na, na, "", style = label.style_label_left, color = color.new(color.white, 100), textcolor = fiboLineColor, size = size.small, force_overlay = true)
        array.push(fibLines, l)
        array.push(fibLabels, lb)
if showFibo and not na(rangeHigh) and not na(rangeLow) and rangeHigh != rangeLow
    float zeroLevel = fibZeroOnHigh ? rangeHigh : rangeLow
    float opposite = fibZeroOnHigh ? rangeLow : rangeHigh
    float diff = math.abs(zeroLevel - opposite)
  
    array<float> ratios = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
    for i = 0 to array.size(ratios) - 1
        float ratio = array.get(ratios, i)
        float level = fibZeroOnHigh ? zeroLevel - diff * ratio : zeroLevel + diff * ratio
     
        line currLine = array.get(fibLines, i)
        label currLabel = array.get(fibLabels, i)
        int rightX = bar_index + fiboOffset
     
        line.set_x1(currLine, rightX)
        line.set_y1(currLine, level)
        line.set_x2(currLine, rightX + 8)
        line.set_y2(currLine, level)
        line.set_extend(currLine, extend.right)
     
        if showFiboLabels
            float labelY = level + (diff * 0.02)
            label.set_xy(currLabel, rightX + 2, labelY)
            label.set_text(currLabel, str.tostring(ratio * 100, "#.#") + "%")
        else
            label.set_text(currLabel, "")
else
    for i = 0 to array.size(fibLines) - 1
        line.set_x1(array.get(fibLines, i), na)

// SIGNALS 
float triangleOffset = 6.0
longSignal = osc[1] <= osLevel and osc > osLevel
shortSignal = osc[1] >= obLevel and osc < obLevel
plotshape(longSignal ? osLevel - triangleOffset : na, title="Long Signal", location=location.absolute, color=colBullMain, style=shape.triangleup, size=size.small)
plotshape(shortSignal ? obLevel + triangleOffset : na, title="Short Signal", location=location.absolute, color=colBearMain, style=shape.triangledown, size=size.small)

// ALERTS
alertcondition(longSignal, title = "Long Signal", message = "Structural Range Oscillator: LONG signal")
alertcondition(shortSignal, title = "Short Signal", message = "Structural Range Oscillator: SHORT signal")
````

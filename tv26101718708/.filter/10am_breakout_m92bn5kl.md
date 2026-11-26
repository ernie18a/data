# 10am Breakout

- url: https://www.tradingview.com/script/m92bN5KL-10am-Breakout/
- type: indicator
- pine_id: PUB;1a96d04259b240de8f17d51dddd12843
- version: 2.0

## Description

10am Breakout

10am Breakout is a simple New York session anchor-range indicator designed to help traders frame the market after the 09:00–10:00 NY hour.

The indicator builds a range from the 09:00–09:59 New York candle window, then waits for price to break and close outside that completed range. Once price closes outside the range, the indicator marks the first valid breakout candle and shows the directional bias for the day.

How It Works

The indicator does three main things:

1. Builds the 09:00 NY anchor range
    It tracks the high and low made between 09:00 and 10:00 New York time.
2. Marks the first valid breakout close
    After the range is complete, the indicator waits for the first candle that breaks and closes outside the range.
    * A close above the range marks a Bullish Bias
    * A close below the range marks a Bearish Bias
3. Displays same-direction Fair Value Gaps
    Once a breakout close happens, the indicator begins scanning for Fair Value Gaps in the same direction as the breakout.
    * Bullish breakout = bullish FVGs only
    * Bearish breakout = bearish FVGs only
    * Fully filled FVGs are hidden
    * Unfilled FVGs stop extending at 16:00 New York time

Visual Guide

* Blue range lines = 09:00–10:00 NY anchor high and low
* Green dot below candle = first candle that closes above the range
* Red dot above candle = first candle that closes below the range
* Top-right bias label = current breakout bias
* Green FVG boxes = bullish FVGs after bullish breakout
* Red FVG boxes = bearish FVGs after bearish breakout

How To Use It

1. Add the indicator to your chart.
2. Use an intraday timeframe such as 1m, 3m, 5m, or 15m.
3. Wait for the 09:00–10:00 NY range to finish.
4. Watch for the first candle that closes outside the range.
5. Use the displayed bias and same-direction FVGs to help frame possible continuation setups.

This tool is designed to keep the chart clean by only showing relevant FVGs after the breakout direction is confirmed.

Notes

This indicator does not place trades automatically and does not guarantee profitable signals. It is a visual tool for identifying the 09:00 NY anchor range, the first breakout close, directional bias, and unfilled same-direction FVGs.

Always combine this with your own trade plan, risk management, and market context.

## Source Code

````pine
//@version=5
indicator("10am Breakout", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// === INPUTS ===
showAnchor     = input.bool(true, "Show 09:00 Anchor Range")
showBackground = input.bool(true, "Shade Anchor Hour")
showRangeFill  = input.bool(false, "Fill Between High/Low During Anchor Hour")
showLabels     = input.bool(false, "Show High/Low Labels")
showBreakDots  = input.bool(true, "Show Breakout Dots")
showBiasText   = input.bool(true, "Show Bias Text")

biasTextSizeInput = input.string("Small", "Bias Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

showFVGs       = input.bool(true, "Show FVGs After Outside Close")
extendFVGs     = input.bool(true, "Extend FVGs Until 16:00 or Filled")
deleteFilled   = input.bool(true, "Hide Fully Filled FVGs")
maxFVGs        = input.int(50, "Max Active FVGs", minval=1, maxval=500)

anchorSession  = input.session("0900-1000:1234567", "Anchor Hour Session")
tradeSession   = input.session("1000-1600:1234567", "Breakout Window")
cutoffSession  = input.session("1600-1601:1234567", "FVG Stop Extending Time")
timezoneInput  = input.string("America/New_York", "Timezone")

anchorColor    = input.color(color.blue, "Anchor Range Color")
bullDotColor   = input.color(color.lime, "Bullish Break Dot Color")
bearDotColor   = input.color(color.red, "Bearish Break Dot Color")

bullFVGColor   = input.color(color.new(color.lime, 80), "Bullish FVG Color")
bearFVGColor   = input.color(color.new(color.red, 80), "Bearish FVG Color")
fvgBorderColor = input.color(color.new(color.gray, 70), "FVG Border Color")

bgTransparency = input.int(90, "Background Transparency", minval=0, maxval=100)
lineWidth      = input.int(1, "Line Width", minval=1, maxval=5)

// === SIZE CONVERSION ===
biasTextSize = biasTextSizeInput == "Tiny" ? size.tiny : biasTextSizeInput == "Small" ? size.small : biasTextSizeInput == "Normal" ? size.normal : biasTextSizeInput == "Large" ? size.large : size.huge

// === SESSION FUNCTIONS ===
is_session(sess) =>
    not na(time(timeframe.period, sess, timezoneInput))

is_new_session(sess) =>
    t = time("D", sess, timezoneInput)
    (na(t[1]) and not na(t)) or (t[1] < t)

// === SESSION STATES ===
anchorSess   = is_session(anchorSession)
anchorNewbar = is_new_session(anchorSession)
tradeSess    = is_session(tradeSession)
cutoffSess   = is_session(cutoffSession)

// === ANCHOR RANGE VARIABLES ===
var float anchorHigh = na
var float anchorLow  = na
var int anchorStart  = na
var int anchorEnd    = na
var int anchorMid    = na
var bool rangeReady  = false

// Dot tracking:
// Allows one bullish dot and one bearish dot per day.
var bool bullDotDone = false
var bool bearDotDone = false

// Bias tracking:
//  1 = Bullish Bias
// -1 = Bearish Bias
//  0 = No bias yet
var int breakoutDir = 0

// Allows the bias to flip only once per day.
var bool biasFlipDone = false

// === FVG ARRAYS ===
var box[] fvgBoxes = array.new_box()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var int[] fvgDirs = array.new_int()
var bool[] fvgStopped = array.new_bool()

// === BIAS TABLE ===
var table biasTable = table.new(position.top_right, 1, 1)

// === ANCHOR SESSION LOGIC ===
if showAnchor
    if anchorSess
        if anchorNewbar
            anchorHigh := high
            anchorLow := low
            anchorStart := bar_index
            anchorEnd := na
            anchorMid := na
            rangeReady := false
            bullDotDone := false
            bearDotDone := false
            breakoutDir := 0
            biasFlipDone := false
        else
            anchorHigh := math.max(anchorHigh, high)
            anchorLow := math.min(anchorLow, low)
    else
        if not na(anchorStart) and na(anchorEnd)
            anchorEnd := bar_index
            anchorMid := math.round((anchorStart + anchorEnd) / 2)
            rangeReady := true

            line.new(x1=anchorStart, y1=anchorHigh, x2=anchorEnd, y2=anchorHigh, extend=extend.none, color=anchorColor, width=lineWidth)
            line.new(x1=anchorStart, y1=anchorLow, x2=anchorEnd, y2=anchorLow, extend=extend.none, color=anchorColor, width=lineWidth)

            if showLabels
                label.new(x=anchorMid, y=anchorHigh, text="09:00 High", style=label.style_label_down, textcolor=color.white, color=anchorColor, size=size.tiny)
                label.new(x=anchorMid, y=anchorLow, text="09:00 Low", style=label.style_label_up, textcolor=color.white, color=anchorColor, size=size.tiny)

// === BREAKOUT DOT LOGIC ===
// Allows one valid close above the range and one valid close below the range per day.
bullBreak = showBreakDots and rangeReady and tradeSess and not bullDotDone and high > anchorHigh and close > anchorHigh
bearBreak = showBreakDots and rangeReady and tradeSess and not bearDotDone and low < anchorLow and close < anchorLow

// === BIAS LOGIC ===
// First outside close sets bias.
// Opposite-side outside close can flip bias only once.
if bullBreak
    bullDotDone := true

    if breakoutDir == 0
        breakoutDir := 1
    else if breakoutDir == -1 and not biasFlipDone
        breakoutDir := 1
        biasFlipDone := true

if bearBreak
    bearDotDone := true

    if breakoutDir == 0
        breakoutDir := -1
    else if breakoutDir == 1 and not biasFlipDone
        breakoutDir := -1
        biasFlipDone := true

plotshape(bullBreak, title="Bullish Breakout Dot", style=shape.circle, location=location.belowbar, color=bullDotColor, size=size.tiny)
plotshape(bearBreak, title="Bearish Breakout Dot", style=shape.circle, location=location.abovebar, color=bearDotColor, size=size.tiny)

// === FVG DETECTION ===
// No FVGs before the first outside close.
// Current bias controls which FVG direction is shown.
// Bullish Bias = bullish FVGs only.
// Bearish Bias = bearish FVGs only.
fvgScanActive = showFVGs and rangeReady and tradeSess and breakoutDir != 0

bullFVG = fvgScanActive and breakoutDir == 1 and bar_index >= 2 and low > high[2]
bearFVG = fvgScanActive and breakoutDir == -1 and bar_index >= 2 and high < low[2]

// === CREATE FVG BOXES ===
if bullFVG
    top = low
    bottom = high[2]
    newBox = box.new(left=bar_index - 2, top=top, right=bar_index, bottom=bottom, bgcolor=bullFVGColor, border_color=fvgBorderColor)
    array.push(fvgBoxes, newBox)
    array.push(fvgTops, top)
    array.push(fvgBottoms, bottom)
    array.push(fvgDirs, 1)
    array.push(fvgStopped, false)

if bearFVG
    top = low[2]
    bottom = high
    newBox = box.new(left=bar_index - 2, top=top, right=bar_index, bottom=bottom, bgcolor=bearFVGColor, border_color=fvgBorderColor)
    array.push(fvgBoxes, newBox)
    array.push(fvgTops, top)
    array.push(fvgBottoms, bottom)
    array.push(fvgDirs, -1)
    array.push(fvgStopped, false)

// === UPDATE / REMOVE / STOP FVG BOXES ===
if array.size(fvgBoxes) > 0
    i = array.size(fvgBoxes) - 1
    while i >= 0
        b = array.get(fvgBoxes, i)
        top = array.get(fvgTops, i)
        bottom = array.get(fvgBottoms, i)
        dir = array.get(fvgDirs, i)
        stopped = array.get(fvgStopped, i)

        bullFilled = dir == 1 and low <= bottom
        bearFilled = dir == -1 and high >= top
        fullyFilled = bullFilled or bearFilled

        if deleteFilled and fullyFilled
            box.delete(b)
            array.remove(fvgBoxes, i)
            array.remove(fvgTops, i)
            array.remove(fvgBottoms, i)
            array.remove(fvgDirs, i)
            array.remove(fvgStopped, i)
        else
            if extendFVGs and not stopped
                box.set_right(b, bar_index)

            if cutoffSess and not stopped
                box.set_right(b, bar_index)
                array.set(fvgStopped, i, true)

        i -= 1

// === LIMIT NUMBER OF ACTIVE FVG BOXES ===
while array.size(fvgBoxes) > maxFVGs
    oldBox = array.shift(fvgBoxes)
    box.delete(oldBox)
    array.shift(fvgTops)
    array.shift(fvgBottoms)
    array.shift(fvgDirs)
    array.shift(fvgStopped)

// === BIAS TEXT TABLE ===
biasText = breakoutDir == 1 ? "Bullish Bias" : breakoutDir == -1 ? "Bearish Bias" : ""
biasBg   = breakoutDir == 1 ? color.new(color.lime, 85) : breakoutDir == -1 ? color.new(color.red, 85) : color.new(color.gray, 100)
biasTxt  = breakoutDir == 1 ? color.lime : breakoutDir == -1 ? color.red : color.new(color.white, 100)

if showBiasText
    table.cell(biasTable, 0, 0, biasText, text_color=biasTxt, bgcolor=biasBg, text_size=biasTextSize)
else
    table.cell(biasTable, 0, 0, "", text_color=color.new(color.white, 100), bgcolor=color.new(color.gray, 100), text_size=size.tiny)

// === VISUALS ===
anchorHighPlot = plot(anchorHigh, title="09:00 Anchor High", color=color.new(anchorColor, 100))
anchorLowPlot  = plot(anchorLow, title="09:00 Anchor Low", color=color.new(anchorColor, 100))

bgcolor(anchorSess and showBackground ? color.new(anchorColor, bgTransparency) : na)

fill(anchorHighPlot, anchorLowPlot, color=anchorSess and showRangeFill ? color.new(anchorColor, bgTransparency) : na)
````

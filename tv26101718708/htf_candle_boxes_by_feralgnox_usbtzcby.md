# HTF Candle Boxes by FeralGnox

- url: https://www.tradingview.com/script/USbtZCby-HTF-Candle-Boxes-by-FeralGnox/
- type: indicator
- pine_id: PUB;2e11880ce79947c2bd0907143a2a104e
- version: 1.0

## Description

HTF Candle Boxes by FeralGnox

HTF Candle Boxes is a visual higher-timeframe (HTF) analysis tool designed to bring higher timeframe structure directly onto lower timeframe charts. It reconstructs HTF candles in real time, allowing traders to see how higher timeframe price action develops while still operating on their preferred intraday or lower timeframe chart.

The indicator plots each HTF candle as a structured box, showing both the wick range and body behavior, making it easier to understand market structure, momentum shifts, and price efficiency across timeframes.

A key feature of the script is its live HTF midline, which updates in real time as the current higher timeframe candle develops. This provides a dynamic equilibrium reference point for intrabar decision-making.

Key Features
HTF candle reconstruction on any lower timeframe
Wick and body visualization for clearer structure
Optional candle box outlines for cleaner or more minimal charts
Historical HTF lookback control for performance and clarity
Bull/Bear coloring for immediate directional context
Live HTF midline (real-time evolving equilibrium level)
Fully customizable styling (colors, thickness, visibility controls)

## Source Code

````pine
//@version=6
indicator(title = "HTF Candle Boxes by FeralGnox", shorttitle = "HTF Candle Boxes", overlay = true, max_boxes_count = 500, max_lines_count = 250)

// ================= INPUTS =================
Interval = input.timeframe("D", "HTF Interval")

UseLookback = input.bool(true, "Use HTF Lookback (History)")
LookbackHTF = input.int(20, "HTF Candles Lookback", minval = 1)

OnlyLiveMidline = input.bool(false, "Only Show Live Midline")

ShowWickBox = input.bool(true, "Show Wick Box")
ShowBodyBox = input.bool(true, "Show Body")
ShowMidLine = input.bool(true, "Show Midline")

ShowBoxOutline = input.bool(true, "Show Candle Box Outline")
BoxOutlineColor = input.color(color.white, "Box Outline Color")

ColLong = input.color(color.new(color.green, 80), "Bull")
ColShort = input.color(color.new(color.red, 80), "Bear")

MidlineColor = input.color(color.yellow, "Midline Color")
MidlineWidth = input.int(2, "Midline Thickness", minval = 1, maxval = 10)

// ================= STATE =================
var float htfHigh = na
var float htfLow = na
var float htfOpen = na
var int htfStart = na

var box[] wickBoxes = array.new_box()
var box[] bodyBoxes = array.new_box()
var line[] midLines = array.new_line()

var line currentMidLine = na

// ================= HTF CHANGE =================
isNewHTF = ta.change(time(Interval)) != 0

prevClose = close[1]
prevIndex = bar_index - 1

// ================= INITIALISE =================
if na(htfOpen)
    htfOpen := open
    htfHigh := high
    htfLow := low
    htfStart := bar_index

// ================= CLOSE HTF =================
if isNewHTF

    isBull = prevClose > htfOpen
    col = isBull ? ColLong : ColShort

    borderW = ShowBoxOutline ? 1 : 0
    borderCol = ShowBoxOutline ? BoxOutlineColor : na

    // ================= HISTORICAL (LOOKBACK) =================
    if UseLookback

        if ShowWickBox
            b = box.new(
                left = htfStart,
                right = prevIndex,
                top = htfHigh,
                bottom = htfLow,
                bgcolor = col,
                border_width = borderW,
                border_color = borderCol
            )
            array.push(wickBoxes, b)

        if ShowBodyBox
            topBody = isBull ? prevClose : htfOpen
            botBody = isBull ? htfOpen : prevClose

            b2 = box.new(
                left = htfStart,
                right = prevIndex,
                top = topBody,
                bottom = botBody,
                bgcolor = col,
                border_width = borderW,
                border_color = borderCol
            )
            array.push(bodyBoxes, b2)

        if ShowMidLine and not OnlyLiveMidline
            mid = math.avg(htfHigh, htfLow)

            l = line.new(
                x1 = htfStart,
                y1 = mid,
                x2 = prevIndex,
                y2 = mid,
                color = MidlineColor,
                width = MidlineWidth
            )

            array.push(midLines, l)

        // CLEANUP
        if array.size(wickBoxes) > LookbackHTF
            box.delete(array.shift(wickBoxes))

        if array.size(bodyBoxes) > LookbackHTF
            box.delete(array.shift(bodyBoxes))

        if array.size(midLines) > LookbackHTF
            line.delete(array.shift(midLines))

    // RESET HTF
    htfOpen := open
    htfHigh := high
    htfLow := low
    htfStart := bar_index

// ================= UPDATE CURRENT HTF =================
else
    htfHigh := math.max(htfHigh, high)
    htfLow := math.min(htfLow, low)

// ================= LIVE MIDLINE =================
if ShowMidLine and not na(htfHigh) and not na(htfLow)

    midNow = math.avg(htfHigh, htfLow)

    if not na(currentMidLine)
        line.delete(currentMidLine)

    currentMidLine := line.new(
        x1 = htfStart,
        y1 = midNow,
        x2 = bar_index,
        y2 = midNow,
        color = MidlineColor,
        width = MidlineWidth
    )
````

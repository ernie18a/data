# Chart Daddy: Auto Fib: Daily  Retrace Level

- url: https://www.tradingview.com/script/PY3wu0yd-Chart-Daddy-Auto-Fib-Daily-Retrace-Level/
- type: indicator
- pine_id: PUB;ee1750b01eea4de5acd0785a794aeb2d
- version: 4.0

## Description

Automatically pulls the fib scale in either uptrend or downtrend to mark fib price targets for intra-day trading.

## Source Code

````pine
//@version=5
indicator("Auto Fib Retracement", overlay=true, max_lines_count=15, max_labels_count=15)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
showLabels = input.bool(true, "Show Level Labels")
lineWidth  = input.int(1,    "Line Width", minval=1, maxval=4)
lineStyle  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

col0    = input.color(color.new(color.gray,   40), "0% / 100% Level")
col236  = input.color(color.new(color.white, 50), "23.6% Level")
col382  = input.color(color.new(color.lime, 20), "38.2% Level")
col500  = input.color(color.new(color.red,  20), "50.0% Level")
col618  = input.color(color.new(color.lime,   20), "61.8% Level")
col786  = input.color(color.new(color.white,   50), "78.6% Level")
col1000 = input.color(color.new(color.gray,   40), "100% / 0% Level")

// ─────────────────────────────────────────────
// NY OPEN DETECTION  (9:30 AM ET)
// ─────────────────────────────────────────────
isNYOpen = not na(time("1", "0930-0931", "America/New_York"))

// ─────────────────────────────────────────────
// RUNNING SWING HIGH / LOW since NY open
// Accumulate bar-by-bar — no dynamic lookback needed
// ─────────────────────────────────────────────
var float swingHigh    = na
var float swingLow     = na
var int   swingHighBar = na   // bar_index where session high occurred
var int   swingLowBar  = na   // bar_index where session low occurred
var int   nyOpenBar    = na

if isNYOpen
    // Reset at each NY open
    swingHigh    := high
    swingLow     := low
    swingHighBar := bar_index
    swingLowBar  := bar_index
    nyOpenBar    := bar_index

else if not na(nyOpenBar)
    // Update running high/low
    if high > swingHigh
        swingHigh    := high
        swingHighBar := bar_index
    if low < swingLow
        swingLow    := low
        swingLowBar := bar_index

// ─────────────────────────────────────────────
// TREND DETECTION
// Compare session open (first bar at NY open) to current close.
// Below open → downtrend (standard fib: 1 at top, 0 at bottom)
// Above open → uptrend   (inverted fib:  0 at top, 1 at bottom)
// ─────────────────────────────────────────────
var float sessionOpen = na
if isNYOpen
    sessionOpen := open

isUptrend = na(sessionOpen) ? true : close >= sessionOpen

// ─────────────────────────────────────────────
// FIB LEVELS
// ─────────────────────────────────────────────
fibRatios     = array.from(0.0,     0.236,   0.382,   0.500,   0.618,   0.786,   1.0    )
fibColors     = array.from(col0,    col236,  col382,  col500,  col618,  col786,  col1000)
fibLabelsUp   = array.from("0.000", "0.236", "0.382", "0.500", "0.618", "0.786", "1.000")
fibLabelsDown = array.from("1.000", "0.786", "0.618", "0.500", "0.382", "0.236", "0.000")

// ─────────────────────────────────────────────
// DRAW
// ─────────────────────────────────────────────
var line[]  drawnLines  = array.new_line()
var label[] drawnLabels = array.new_label()

if array.size(drawnLines) > 0
    for l in drawnLines
        line.delete(l)
    array.clear(drawnLines)

if array.size(drawnLabels) > 0
    for lb in drawnLabels
        label.delete(lb)
    array.clear(drawnLabels)

ls = switch lineStyle
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

if not na(swingHigh) and not na(swingLow) and swingHigh != swingLow
    startBar = nyOpenBar
    endBar   = bar_index + 10

    for i = 0 to array.size(fibRatios) - 1
        ratio = array.get(fibRatios, i)
        price = swingHigh - ratio * (swingHigh - swingLow)
        col   = array.get(fibColors, i)
        lbl   = isUptrend ? array.get(fibLabelsUp, i) : array.get(fibLabelsDown, i)

        ln = line.new(
             x1    = startBar,
             y1    = price,
             x2    = endBar,
             y2    = price,
             color = col,
             width = lineWidth,
             style = ls)
        array.push(drawnLines, ln)

        if showLabels
            lb = label.new(
                 x         = endBar,
                 y         = price,
                 text      = lbl + "  " + str.tostring(math.round(price, 2)),
                 color     = color.new(color.black, 100),
                 textcolor = col,
                 style     = label.style_label_left,
                 size      = size.small)
            array.push(drawnLabels, lb)

// ─────────────────────────────────────────────
// TREND LABEL
// ─────────────────────────────────────────────
var label trendLbl = na
label.delete(trendLbl)

if not na(swingHigh)
    trendLbl := label.new(
         x         = bar_index,
         y         = high,
         text      = isUptrend ? "▲ Uptrend  (Inverted Fib)" : "▼ Downtrend  (Standard Fib)",
         color     = color.new(color.black, 100),
         textcolor = isUptrend ? color.lime : color.red,
         style     = label.style_label_lower_left,
         size      = size.normal)
````

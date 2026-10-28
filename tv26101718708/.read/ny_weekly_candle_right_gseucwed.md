# NY Weekly Candle Right 

- url: https://www.tradingview.com/script/GsEUCwed-NY-Weekly-Candle-Right/
- type: indicator
- pine_id: PUB;20e3d38a07da404795dba5fc40bab666
- version: 1.0

## Description

This indicator draws a custom weekly candle positioned to the right of the price action. It tracks the open, high, low, and close of the current week based on the New York timezone, rendering it as a color-coded box with wicks. Green indicates a bullish week (close ≥ open), red indicates bearish. Useful for keeping the higher timeframe context visible while trading on lower timeframes.

## Source Code

````pine
//@version=6
indicator("Weekly Candle Right", overlay=true, max_boxes_count=10, max_lines_count=10)

// Right offset (increased for more spacing)
offset = 30

// New York timezone
string tz = "America/New_York"

// Detect weekly change (new week starts on Monday)
int nyWeek = time("W", "0000-0000", tz)
bool newWeek = not na(nyWeek) and ta.change(nyWeek) != 0

// Build custom OHLC for the week
var float wO = na
var float wH = na
var float wL = na
var float wC = na

if newWeek or na(wO)
    wO := open
    wH := high
    wL := low
    wC := close
else
    wH := math.max(wH, high)
    wL := math.min(wL, low)
    wC := close

// Candle color
isBull = wC >= wO
candleColor = isBull ? color.green : color.red

// X coordinates
xLeft  = bar_index + offset
xRight = bar_index + offset + 4
xMid   = bar_index + offset + 2

// Persistent objects
var box  bodyBox = na
var line wickUp  = na
var line wickDn  = na

if barstate.islast
    // Delete old objects
    if not na(bodyBox)
        box.delete(bodyBox)
    if not na(wickUp)
        line.delete(wickUp)
    if not na(wickDn)
        line.delete(wickDn)

    // Body
    bodyBox := box.new(
        left = xLeft,
        top = math.max(wO, wC),
        right = xRight,
        bottom = math.min(wO, wC),
        bgcolor = candleColor,
        border_color = color.black
    )

    // Upper wick
    wickUp := line.new(
        x1 = xMid,
        y1 = wH,
        x2 = xMid,
        y2 = math.max(wO, wC),
        color = color.black,
        width = 2
    )

    // Lower wick
    wickDn := line.new(
        x1 = xMid,
        y1 = math.min(wO, wC),
        x2 = xMid,
        y2 = wL,
        color = color.black,
        width = 2
    )
````

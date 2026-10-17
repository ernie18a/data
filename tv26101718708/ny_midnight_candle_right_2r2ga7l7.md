# NY Midnight Candle Right

- url: https://www.tradingview.com/script/2R2ga7l7-NY-Midnight-Candle-Right/
- type: indicator
- pine_id: PUB;cd610e1dd73e4dfb94777e056cf18468
- version: 1.0

## Description

This script displays a synthetic daily candle projected to the right side of the chart. Unlike the platform’s standard daily candle, it is built from price action that starts at New York midnight and ends at the next New York midnight.

## Source Code

````pine
//@version=6
indicator("NY Midnight Candle Right", overlay=true, max_boxes_count=10, max_lines_count=10)

// Right offset
offset = 15

// New York timezone
string tz = "America/New_York"

// Detect NY day change
int nyDay = time("1D", "0000-0000", tz)
bool newNyDay = not na(nyDay) and ta.change(nyDay) != 0

// Build custom OHLC from NY midnight to next NY midnight
var float dO = na
var float dH = na
var float dL = na
var float dC = na

if newNyDay or na(dO)
    dO := open
    dH := high
    dL := low
    dC := close
else
    dH := math.max(dH, high)
    dL := math.min(dL, low)
    dC := close

// Candle color
isBull = dC >= dO
candleColor = isBull ? color.green : color.red

// X coordinates
xLeft  = bar_index + offset
xRight = bar_index + offset + 2
xMid   = bar_index + offset + 1

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
        top = math.max(dO, dC),
        right = xRight,
        bottom = math.min(dO, dC),
        bgcolor = candleColor,
        border_color = color.black
    )

    // Upper wick
    wickUp := line.new(
        x1 = xMid,
        y1 = dH,
        x2 = xMid,
        y2 = math.max(dO, dC),
        color = color.black,
        width = 2
    )

    // Lower wick
    wickDn := line.new(
        x1 = xMid,
        y1 = math.min(dO, dC),
        x2 = xMid,
        y2 = dL,
        color = color.black,
        width = 2
    )
````

# Latest Weekly 8 EMA Horizontal

- url: https://www.tradingview.com/script/3ogRubta-Latest-Weekly-8-EMA-Horizontal/
- type: indicator
- pine_id: PUB;c71807186bf049fb863515d9aa773222
- version: 1.0

## Description

Draws weekly 8 ema horizontal line on all timeframes

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © richmiao

//@version=6
indicator("Latest Weekly 8 EMA Horizontal", overlay=true)

// --- Inputs ---
emaLen = input.int(8, title="Weekly EMA Length")
lineColor = input.color(color.rgb(32, 36, 255, 12), title="Line Color")
lineWidth = input.int(1, title="Line Width", minval=1)

// --- Calculations ---
// Calculate EMA on the current daily chart, then secure it from weekly
weeklyEma = request.security(syminfo.tickerid, "W", ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)

// --- Plotting ---
// Only plot on the last bar to act as a horizontal reference line
var line wEmaLine = na

if barstate.islast
    line.delete(wEmaLine)
    wEmaLine := line.new(x1=bar_index - 500, y1=weeklyEma, 
                         x2=bar_index + 500, y2=weeklyEma, 
                         color=lineColor, width=lineWidth, 
                         style=line.style_solid)

// Optional: Plot the value in the Data Window
plot(weeklyEma, title="Weekly 8 EMA", color=color.new(color.white, 100))
````

# GOLD MINE

- url: https://www.tradingview.com/script/daXxnqB7-GOLD-MINE/
- type: indicator
- pine_id: PUB;ff38e632aadb466787b617811f8fde49
- version: 1.0

## Description

GOLD MINE- run & enjoy pure technical indicator to make profits for lifetime

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mastertrader05

//@version=6
indicator("EMA 13/50 Entry–Exit Arrows with Entry Range", overlay=true)

// EMA calculations (hidden)
ema13 = ta.ema(close, 13)
ema50 = ta.ema(close, 50)

// Cross conditions
bullCross = ta.crossover(ema13, ema50)
bearCross = ta.crossunder(ema13, ema50)

// State variables
var bool waitForEntry = false
var bool entryBar = false
var bool exitBar = false

// Line holders
var line entryHighLine = na
var line entryLowLine  = na

// Reset flags each bar
entryBar := false
exitBar := false

// Detect bullish cross → wait for next candle
if bullCross
    waitForEntry := true

// Entry on next candle
if waitForEntry
    entryBar := true
    waitForEntry := false

    // Delete old lines
    if not na(entryHighLine)
        line.delete(entryHighLine)
    if not na(entryLowLine)
        line.delete(entryLowLine)

    // Draw dotted HIGH & LOW lines
    entryHighLine := line.new(
         bar_index, high,
         bar_index + 1, high,
         extend=extend.right,
         style=line.style_dotted,
         color=color.new(color.green, 0),
         width=1
    )

    entryLowLine := line.new(
         bar_index, low,
         bar_index + 1, low,
         extend=extend.right,
         style=line.style_dotted,
         color=color.new(color.red, 0),
         width=1
    )

// Exit condition
if bearCross
    exitBar := true

// =======================
// Candle coloring
// =======================
barcolor(
     entryBar ? color.blue :
     exitBar  ? color.red  : na
)

// =======================
// Entry candle highlight
// =======================
bgcolor(entryBar ? color.new(color.blue, 90) : na)

// =======================
// Arrows & Text
// =======================

// Entry arrow with BUY text
plotshape(
     entryBar,
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.green,
     text="BUY",
     textcolor=color.green
)

// Exit arrow with SELL text
plotshape(
     exitBar,
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     color=color.red,
     text="SELL",
     textcolor=color.red
)
````

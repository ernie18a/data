# Open Price % Levels With Session Gap by SMT

- url: https://www.tradingview.com/script/wwaVFtHP-Open-Price-Levels-With-Session-Gap-by-SMT/
- type: indicator
- pine_id: PUB;c3033a7585ad4bcf82d8bb0c4a279c99
- version: 1.0

## Description

This indicator plots the session opening price and automatically calculates percentage-based levels above and below it.
Features


Session Opening Price Line


+0.5%, +1%, +2%, +2.5%, +3% Levels


-0.5%, -1%, -2%, -2.5%, -3% Levels


Customizable line colors and thickness


Session-based plotting with automatic daily reset


No line connection between trading sessions (clean session gaps)


Works on all markets and timeframes


Useful for identifying key percentage expansion and retracement zones relative to the session open, helping traders track intraday price movement and potential reaction levels.
Best suited for: Index, Forex, Gold, Crypto, and Intraday Trading.

## Source Code

````pine
//@version=6
indicator("Open Price % Levels With Session Gap", overlay=true, max_lines_count=500)

openColor = input.color(color.black, "Open Line Color")
openWidth = input.int(2, "Open Line Width", minval=1)

upColor = input.color(color.green, "Upper Levels Color")
downColor = input.color(color.red, "Lower Levels Color")
levelWidth = input.int(1, "Levels Width", minval=1)

newDay = ta.change(time("D")) != 0

var float sessionOpen = na

if newDay or barstate.isfirst
    sessionOpen := open

up05 = sessionOpen * 1.005
up10 = sessionOpen * 1.010
up20 = sessionOpen * 1.020
up25 = sessionOpen * 1.025
up30 = sessionOpen * 1.030

dn05 = sessionOpen * 0.995
dn10 = sessionOpen * 0.990
dn20 = sessionOpen * 0.980
dn25 = sessionOpen * 0.975
dn30 = sessionOpen * 0.970

var line openLine = na

var line lUp05 = na
var line lUp10 = na
var line lUp20 = na
var line lUp25 = na
var line lUp30 = na

var line lDn05 = na
var line lDn10 = na
var line lDn20 = na
var line lDn25 = na
var line lDn30 = na

if newDay or barstate.isfirst

    openLine := line.new(bar_index, sessionOpen, bar_index, sessionOpen,
         color=openColor, width=openWidth)

    lUp05 := line.new(bar_index, up05, bar_index, up05,
         color=upColor, width=levelWidth)

    lUp10 := line.new(bar_index, up10, bar_index, up10,
         color=upColor, width=levelWidth)

    lUp20 := line.new(bar_index, up20, bar_index, up20,
         color=upColor, width=levelWidth)

    lUp25 := line.new(bar_index, up25, bar_index, up25,
         color=upColor, width=levelWidth)

    lUp30 := line.new(bar_index, up30, bar_index, up30,
         color=upColor, width=levelWidth)

    lDn05 := line.new(bar_index, dn05, bar_index, dn05,
         color=downColor, width=levelWidth)

    lDn10 := line.new(bar_index, dn10, bar_index, dn10,
         color=downColor, width=levelWidth)

    lDn20 := line.new(bar_index, dn20, bar_index, dn20,
         color=downColor, width=levelWidth)

    lDn25 := line.new(bar_index, dn25, bar_index, dn25,
         color=downColor, width=levelWidth)

    lDn30 := line.new(bar_index, dn30, bar_index, dn30,
         color=downColor, width=levelWidth)

line.set_x2(openLine, bar_index)

line.set_x2(lUp05, bar_index)
line.set_x2(lUp10, bar_index)
line.set_x2(lUp20, bar_index)
line.set_x2(lUp25, bar_index)
line.set_x2(lUp30, bar_index)

line.set_x2(lDn05, bar_index)
line.set_x2(lDn10, bar_index)
line.set_x2(lDn20, bar_index)
line.set_x2(lDn25, bar_index)
line.set_x2(lDn30, bar_index)
````

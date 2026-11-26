# ORB Institutional Volume V5

- url: https://www.tradingview.com/script/3HczMWf4-ORB-Institutional-Volume-V5/
- type: indicator
- pine_id: PUB;6c36940a161e41bdb90a42e702fc4ab2
- version: 1.0

## Description

30m Opening Range Breakout with Institutional Volume confirmation.

## Source Code

````pine
//@version=5
indicator("ORB Institutional Volume V5", overlay=true)

// --- Settings ---
orbTime = input.string("0930-1000", "Opening Range (ex: 0930-1000)")
volLength = input.int(20, "Volume Average Period")
volMult = input.float(1.5, "Volume Power Multiplier", step=0.1)

// --- ORB Calculation ---
is_new_day = ta.change(time("D")) != 0
is_in_range = not na(time(timeframe.period, orbTime))
var float orbHigh = na
var float orbLow = na

if is_new_day
    orbHigh := na
    orbLow := na

if is_in_range
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

// Plot the Range Lines
plot(orbHigh, color=color.blue, style=plot.style_linebr, linewidth=2)
plot(orbLow, color=color.red, style=plot.style_linebr, linewidth=2)

// --- Volume Power Detection ---
avgVol = ta.sma(volume, volLength)
isVolPower = volume > (avgVol * volMult)

// --- Breakout Signals ---
isBreakUp = ta.crossover(close, orbHigh) and isVolPower
isBreakDown = ta.crossunder(close, orbLow) and isVolPower

// --- Visual Colors ---
barcolor(isVolPower ? color.purple : na)

// Use Arrows instead of "shape" to avoid the Line 39 error
plotchar(isBreakUp, char="↓", location=location.abovebar, color=color.green, size=size.small, text="VOL BUY")
plotchar(isBreakDown, char="↑", location=location.belowbar, color=color.red, size=size.small, text="VOL SELL")
````

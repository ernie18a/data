# Swing High/Low Lines (Break Stop)

- url: https://www.tradingview.com/script/tKJABtmE-Swing-High-Low-Lines-Break-Stop/
- type: indicator
- pine_id: PUB;cb2dc82cc11242f9b2633998760fba67
- version: 1.0

## Description

Swing High/Low Lines (with alerts) – Strategy Description

This indicator automatically identifies market structure using swing highs and swing lows, then plots horizontal levels that extend forward until price breaks them. It is designed to track liquidity levels, highlight potential breakout points, and provide clean, event-based alerts.

Core Functionality
Detects swing highs and swing lows using a configurable strength setting
Plots each swing as a horizontal line starting at the pivot point
Lines extend forward in real time until price interacts with them
Once a level is broken, the line stops extending and is removed from tracking
Swing Detection
Uses ta.pivothigh and ta.pivotlow
The strength input defines how many candles are required on each side of a pivot
Higher strength = fewer, more significant levels
Lower strength = more frequent, sensitive levels
Line Behavior
Each swing level is drawn as an independent horizontal line
Lines extend right automatically as long as they remain unbroken
When price breaks a level:
The line is cut off at the break point
It is removed from active tracking
Prevents clutter by only keeping valid, untested levels active
Break Logic

Configurable via “Break on Wick” option:

Enabled (default):
A level is considered broken when price wicks through it
Disabled:
A level is only broken when price closes beyond it

This allows adaptation for:

Aggressive (wick-based liquidity grabs)
Conservative (confirmed close-based breaks)
Alerts

The script includes two types of alerts:

1. Swing Creation Alerts

Triggered when a new level forms:

New Swing High
New Swing Low

Useful for:

Tracking fresh structure
Identifying new liquidity zones
2. Break Alerts

Triggered when price crosses any active level:

Swing High Broken
Swing Low Broken

Behavior:

Fires as soon as price breaches a level (based on wick/close setting)
Works across all active swing levels simultaneously

Useful for:

Breakout entries
Liquidity sweeps
Structure shifts
Internal Tracking System
Uses arrays to store:
Active swing lines
Corresponding price levels
Continuously checks each level for break conditions
Efficiently removes invalidated levels in real time
Visual Customization
Adjustable colors for highs and lows
Configurable line width
Selectable line style:
Solid
Dashed
Dotted
Use Case

This indicator is built for traders who rely on:

Market structure
Liquidity sweeps
Breakout confirmation
Clean chart visualization without outdated levels

It ensures that only relevant, unbroken swing levels remain on the chart while providing immediate alerts when those levels are created or taken out.

## Source Code

````pine
//@version=5
indicator("Swing High/Low Lines (Break Stop)", overlay=true)

// === Inputs ===
strength   = input.int(3, "Swing Strength", minval=1)
lineColorH = input.color(color.red, "Swing High Line Color")
lineColorL = input.color(color.green, "Swing Low Line Color")
lineWidth  = input.int(2, "Line Width", minval=1, maxval=5)
lineStyle  = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
useWick    = input.bool(true, "Break on Wick (instead of close)")

// === Convert Style ===
style = lineStyle == "Solid"  ? line.style_solid :  lineStyle == "Dashed" ? line.style_dashed :
                               line.style_dotted

// === Detect Swings ===
pivotHigh = ta.pivothigh(high, strength, strength)
pivotLow  = ta.pivotlow(low, strength, strength)

// === Alerts for Swing Creation ===
newSwingHigh = not na(pivotHigh)
newSwingLow  = not na(pivotLow)

alertcondition(newSwingHigh, "New Swing High", "New swing high created")
alertcondition(newSwingLow,  "New Swing Low",  "New swing low created")

// === Storage ===
var line[] highLines = array.new_line()
var float[] highPrices = array.new_float()

var line[] lowLines = array.new_line()
var float[] lowPrices = array.new_float()

// === Create Swing High Lines ===
if newSwingHigh
    idx = bar_index - strength
    l = line.new(idx, pivotHigh, bar_index, pivotHigh, extend=extend.right, width=lineWidth, color=lineColorH, style=style)
    array.push(highLines, l)
    array.push(highPrices, pivotHigh)

// === Create Swing Low Lines ===
if newSwingLow
    idx = bar_index - strength
    l = line.new(idx, pivotLow, bar_index, pivotLow, extend=extend.right, width=lineWidth, color=lineColorL, style=style)
    array.push(lowLines, l)
    array.push(lowPrices, pivotLow)

// === Alerts for Cross ===
var bool crossedHigh = false
var bool crossedLow  = false

crossedHigh := false
crossedLow  := false

if array.size(highPrices) > 0
    for i = 0 to array.size(highPrices) - 1
        price = array.get(highPrices, i)
        if useWick ? high > price : close > price
            crossedHigh := true

if array.size(lowPrices) > 0
    for i = 0 to array.size(lowPrices) - 1
        price = array.get(lowPrices, i)
        if useWick ? low < price : close < price
            crossedLow := true

alertcondition(crossedHigh, "Swing High Broken", "Price crossed above a swing high")
alertcondition(crossedLow,  "Swing Low Broken",  "Price crossed below a swing low")

// === Stop Lines When Broken ===

// Highs
if array.size(highLines) > 0
    i = array.size(highLines) - 1
    while i >= 0
        l = array.get(highLines, i)
        price = array.get(highPrices, i)
        broken = useWick ? high > price : close > price
        if broken
            line.set_extend(l, extend.none)
            line.set_x2(l, bar_index)
            array.remove(highLines, i)
            array.remove(highPrices, i)
        i -= 1

// Lows
if array.size(lowLines) > 0
    i = array.size(lowLines) - 1
    while i >= 0
        l = array.get(lowLines, i)
        price = array.get(lowPrices, i)
        broken = useWick ? low < price : close < price
        if broken
            line.set_extend(l, extend.none)
            line.set_x2(l, bar_index)
            array.remove(lowLines, i)
            array.remove(lowPrices, i)
        i -= 1
````

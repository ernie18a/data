# Current Day HOD & LOD TOMAS ANDARA

- url: https://www.tradingview.com/script/alPn1Afy-Current-Day-HOD-LOD-TOMAS-ANDARA/
- type: indicator
- pine_id: PUB;d07d62622633443e9d2a37539f7a6e64
- version: 1.0

## Description

Current Day HOD & LOD (Dynamic)

This indicator plots the Current Day High (HOD) and Current Day Low (LOD) in real time across all intraday timeframes.

Unlike static previous-day levels, this tool dynamically tracks the developing daily range and updates continuously as new highs and lows form during the current trading day.

Key Features
Displays Current Day High (HOD) and Current Day Low (LOD) only
Fully dynamic: levels update in real time as price evolves
Clean horizontal ray-style lines extending to the right
Minimal visual clutter for clean chart structure
Customizable colors for HOD and LOD
Labels positioned to the far right for clear identification
Works on all intraday timeframes (1m, 5m, 15m, 1H, 4H, etc.)
Usage

This indicator is designed for traders who focus on:

Intraday liquidity levels
Breaks of daily extremes
Liquidity sweeps (HOD/LOD grabs)
ICT / Smart Money Concepts style trading

It helps identify key decision points where price is likely to react, reverse, or accelerate once the daily high or low is taken.

Notes
Only current day levels are shown (no historical clutter)
Automatically resets at the start of each new trading day
Designed for simplicity and precision

## Source Code

````pine
//@version=5
indicator("Current Day HOD & LOD", overlay=true)

// ======================
// INPUTS
// ======================

hodColor = input.color(color.red, "HOD Color")
lodColor = input.color(color.lime, "LOD Color")

// ======================
// CURRENT DAY LEVELS
// ======================

currentDayHigh = request.security(syminfo.tickerid, "D", high)
currentDayLow  = request.security(syminfo.tickerid, "D", low)

// ======================
// VARIABLES
// ======================

var line hodLine = na
var line lodLine = na

var label hodText = na
var label lodText = na

// ======================
// NEW DAY
// ======================

newDay = ta.change(time("D"))

// ======================
// CREATE OBJECTS
// ======================

if newDay
    // Delete previous objects
    line.delete(hodLine)
    line.delete(lodLine)

    label.delete(hodText)
    label.delete(lodText)

    // HOD Line
    hodLine := line.new(
         x1 = bar_index,
         y1 = currentDayHigh,
         x2 = bar_index + 1,
         y2 = currentDayHigh,
         extend = extend.right,
         color = hodColor,
         width = 2)

    // LOD Line
    lodLine := line.new(
         x1 = bar_index,
         y1 = currentDayLow,
         x2 = bar_index + 1,
         y2 = currentDayLow,
         extend = extend.right,
         color = lodColor,
         width = 2)

    // HOD Text
    hodText := label.new(
         x = bar_index,
         y = currentDayHigh,
         text = "HOD",
         style = label.style_none,
         textcolor = hodColor,
         size = size.normal)

    // LOD Text
    lodText := label.new(
         x = bar_index,
         y = currentDayLow,
         text = "LOD",
         style = label.style_none,
         textcolor = lodColor,
         size = size.normal)

// ======================
// UPDATE
// ======================

// Update lines
line.set_y1(hodLine, currentDayHigh)
line.set_y2(hodLine, currentDayHigh)

line.set_y1(lodLine, currentDayLow)
line.set_y2(lodLine, currentDayLow)

// Move text to far right
label.set_x(hodText, bar_index + 20)
label.set_y(hodText, currentDayHigh)

label.set_x(lodText, bar_index + 20)
label.set_y(lodText, currentDayLow)
````

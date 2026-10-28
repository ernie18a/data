# Daily High Low Levels

- url: https://www.tradingview.com/script/HinmifOz-Daily-High-Low-Levels/
- type: indicator
- pine_id: PUB;508908b01fee494ca1e96cb298fcf340
- version: 1.0

## Description

[b]Daily High Low Levels[/b]
This indicator draws the previous day's high and low as horizontal lines on an intraday chart. Each line is anchored to the session it belongs to and does not extend beyond the next day's open. Optional labels mark each level at its left edge.

[b]How it works[/b]
Daily high, low, and session open time are fetched using request.security on the daily timeframe with lookahead_on, which is required to align daily values to their correct intraday bars. On each bar where a new trading day is detected, a line is drawn for the prior day's high and a line for the prior day's low. Both lines span from the start to the end of that prior session. Labels are placed at the left edge of each line. Older lines and labels are removed automatically once the lookback limit is reached.

[b]Settings[/b]
[list]
[*]Days to Look Back — number of previous sessions to display (default: 100, max: 240)
[*]Line Width — thickness of the high and low lines (default: 1)
[*]High Line Color — color applied to the previous day's high line and label
[*]Low Line Color — color applied to the previous day's low line and label
[*]Show High Label — toggle the PDH text label on or off
[*]Show Low Label — toggle the PDL text label on or off
[/list]

[b]Notes[/b]
This indicator is designed for intraday charts (1m to 4H). On daily or higher timeframes the previous day's high and low will overlap with the current bar and the lines will not be meaningful. Results depend on the exchange session data available for the symbol.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © lazyhacker

//@version=6
indicator("Daily High Low Levels", shorttitle="Daily H/L", overlay=true, max_lines_count=500)

// --- Inputs ---
lookbackDays  = input.int(100,  title="Days to Look Back", minval=1, maxval=240, group="General")
lineWidth     = input.int(1,    title="Line Width",        minval=1, maxval=5,   group="General")

colorHigh     = input.color(color.new(color.green, 30), title="High Line Color", group="Colors")
colorLow      = input.color(color.new(color.red,   30), title="Low Line Color",  group="Colors")

showHighLabel = input.bool(true, title="Show High Label", group="Colors")
showLowLabel  = input.bool(true, title="Show Low Label",  group="Colors")

// --- Fetch daily high, low, and session open time ---
[dHigh, dLow, dTime] = request.security(
     syminfo.tickerid, "D",
     [high, low, time],
     lookahead=barmerge.lookahead_on)

// --- Storage ---
var line[]  allLines  = array.new<line>()
var label[] allLabels = array.new<label>()

// --- Draw on each new day using the previous day's values ---
isNewDay = dTime != dTime[1]

if isNewDay
    t1 = dTime[1]
    t2 = dTime

    lH = line.new(
         x1    = t1,
         y1    = dHigh[1],
         x2    = t2,
         y2    = dHigh[1],
         xloc  = xloc.bar_time,
         color = colorHigh,
         width = lineWidth)

    lL = line.new(
         x1    = t1,
         y1    = dLow[1],
         x2    = t2,
         y2    = dLow[1],
         xloc  = xloc.bar_time,
         color = colorLow,
         width = lineWidth)

    allLines.push(lH)
    allLines.push(lL)

    lbH = label.new(
         x         = t1,
         y         = dHigh[1],
         text      = showHighLabel ? "PDH" : "",
         xloc      = xloc.bar_time,
         style     = label.style_label_right,
         color     = color.new(color.green, 80),
         textcolor = colorHigh,
         size      = size.small)

    lbL = label.new(
         x         = t1,
         y         = dLow[1],
         text      = showLowLabel ? "PDL" : "",
         xloc      = xloc.bar_time,
         style     = label.style_label_right,
         color     = color.new(color.red, 80),
         textcolor = colorLow,
         size      = size.small)

    allLabels.push(lbH)
    allLabels.push(lbL)

    // --- Remove oldest lines beyond lookback ---
    if allLines.size() > lookbackDays * 2
        line.delete(allLines.shift())
        line.delete(allLines.shift())

    // --- Remove oldest labels beyond lookback ---
    if allLabels.size() > lookbackDays * 2
        label.delete(allLabels.shift())
        label.delete(allLabels.shift())
````

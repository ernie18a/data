# Opening 5-Minute Range For stocks ONLY

- url: https://www.tradingview.com/script/shHwmsyS-Opening-5-Minute-Range-For-stocks-ONLY/
- type: indicator
- pine_id: PUB;faa5ad1bcdbb406fbeb267a76445433e
- version: 1.0

## Description

Marks the highs and lows with midpoint of the 5 min range

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jonahthandelacruz

//@version=6
plot(close)
//@version=5
indicator("Opening 5-Minute Range", overlay=true, max_lines_count=500)

var float orHigh = na
var float orLow = na
var float orMid = na

var line highLine = na
var line lowLine = na
var line midLine = na

// New day
newDay = ta.change(time("D")) != 0

if newDay
    orHigh := na
    orLow := na
    orMid := na

// First 5-minute candle of regular session
isOpeningRange = hour == 9 and minute == 30

if isOpeningRange
    orHigh := high
    orLow := low
    orMid := (orHigh + orLow) / 2

    line.delete(highLine)
    line.delete(lowLine)
    line.delete(midLine)

    highLine := line.new(
         bar_index, orHigh,
         bar_index + 1, orHigh,
         extend=extend.right,
         color=color.gray,
         width=2)

    lowLine := line.new(
         bar_index, orLow,
         bar_index + 1, orLow,
         extend=extend.right,
         color=color.gray,
         width=2)

    midLine := line.new(
         bar_index, orMid,
         bar_index + 1, orMid,
         extend=extend.right,
         color=color.white,
         width=2,
         style=line.style_dotted)

// Plot values so they remain visible
plot(orHigh, "Opening High", color=color.gray, linewidth=2)
plot(orLow, "Opening Low", color=color.gray, linewidth=2)
plot(orMid, "Opening Mid", color=color.white, linewidth=2, style=plot.style_circles)
````

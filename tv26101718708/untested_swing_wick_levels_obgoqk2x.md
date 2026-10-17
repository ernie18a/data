# Untested Swing Wick Levels

- url: https://www.tradingview.com/script/ObGoQK2X-Untested-Swing-Wick-Levels/
- type: indicator
- pine_id: PUB;1cda036b79c74329846c26cbb0ff3769
- version: 1.0

## Description

marks out swing highs and swing lows. makes a horizontal line on the wick where price has not yet touched it.

## Source Code

````pine
//@version=6
indicator("Untested Swing Wick Levels", overlay=true, max_lines_count=500)

leftBars = input.int(3, "Left Bars")
rightBars = input.int(3, "Right Bars")

var line[] levels = array.new_line()
var float[] prices = array.new_float()

swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow  = ta.pivotlow(low, leftBars, rightBars)

// Create level at swing high wick
if not na(swingHigh)
    level = swingHigh
    ln = line.new(
         bar_index - rightBars,
         level,
         bar_index,
         level,
         extend=extend.right,
         color=color.red,
         width=2)
    array.push(levels, ln)
    array.push(prices, level)

// Create level at swing low wick
if not na(swingLow)
    level = swingLow
    ln = line.new(
         bar_index - rightBars,
         level,
         bar_index,
         level,
         extend=extend.right,
         color=color.green,
         width=2)
    array.push(levels, ln)
    array.push(prices, level)

// Remove line when price touches it
for i = array.size(levels) - 1 to 0
    level = array.get(prices, i)

    if high >= level and low <= level
        line.delete(array.get(levels, i))
        array.remove(levels, i)
        array.remove(prices, i)
````

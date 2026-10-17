# Doji Signals

- url: https://www.tradingview.com/script/2JvzDWIi-Doji-Signals/
- type: indicator
- pine_id: PUB;5d12e4bf3fee4eb6bf3d8f2d1af74c4c
- version: 3.0

## Description

done. fixed minor bugs and made candle stick pattern easy to read and check on chart

## Source Code

````pine
//@version=6
indicator("Doji Signals", overlay=true, max_lines_count=500)

Precision = input.float(0.369, minval=0.0001, title="Doji Max Body Size")
entryMode = input.string("Both", "Entries", options=["Normal", "Aggressive", "Both"])
showBuy = input.bool(true, "Buy")
showSell = input.bool(true, "Sell")

const int MAX_PENDING = 50
const int LINE_WIDTH = 1
color dojiColor = #FFD700
color normalBearColor = #8B0000
color normalBullColor = #006400
color aggressiveBearColor = color.red
color aggressiveBullColor = color.green

showNormal = entryMode == "Normal" or entryMode == "Both"
showAggressive = entryMode == "Aggressive" or entryMode == "Both"
isDoji = math.abs(open - close) <= (high - low) * Precision
barcolor(isDoji ? dojiColor : na, title="Doji Candle")

var normalBearLows = array.new_float()
var normalBearHighs = array.new_float()
var normalBearLines = array.new_line()
var normalBullLows = array.new_float()
var normalBullHighs = array.new_float()
var normalBullLines = array.new_line()
var aggressiveBearLows = array.new_float()
var aggressiveBearHighs = array.new_float()
var aggressiveBearLines = array.new_line()
var aggressiveBullLows = array.new_float()
var aggressiveBullHighs = array.new_float()
var aggressiveBullLines = array.new_line()
var bool lastBarWasEntry = false

f_add(array<float> lows, array<float> highs, array<line> lines, bool markHigh, color lineColor) =>
    float y = markHigh ? high[1] : low[1]
    line ln = line.new(bar_index - 1, y, bar_index, y, extend=extend.right, color=lineColor, width=LINE_WIDTH)
    array.push(lows, low[1])
    array.push(highs, high[1])
    array.push(lines, ln)

f_trim(array<float> lows, array<float> highs, array<line> lines) =>
    while array.size(lows) > MAX_PENDING
        array.shift(lows)
        array.shift(highs)
        line ln = array.shift(lines)
        if not na(ln)
            line.delete(ln)

f_resolve(array<float> lows, array<float> highs, array<line> lines, bool breakAbove) =>
    bool fired = false
    int i = array.size(lows) - 1
    while i >= 0
        float c1Low = array.get(lows, i)
        float c1High = array.get(highs, i)
        bool trigger = barstate.isconfirmed and (breakAbove ? close > c1High : close < c1Low)
        bool invalid = barstate.isconfirmed and (breakAbove ? close < c1Low : close > c1High)
        if invalid or trigger
            line ln = array.get(lines, i)
            if not na(ln)
                if trigger
                    line.set_x2(ln, bar_index)
                    line.set_extend(ln, extend.none)
                else
                    line.delete(ln)
            array.remove(lows, i)
            array.remove(highs, i)
            array.remove(lines, i)
            fired := fired or trigger
        i -= 1
    fired

previousCandleWasEntry = lastBarWasEntry
c2InsideC1 = close <= high[1] and close >= low[1]
c2Yellow = isDoji
c1GreenYellow = isDoji[1] and close[1] > open[1]
c1RedYellow = isDoji[1] and close[1] < open[1]
c1GreenBase = close[1] > open[1] and not isDoji[1]
c1RedBase = close[1] < open[1] and not isDoji[1]
greenPattern = c1GreenYellow or (c1GreenBase and c2Yellow)
redPattern = c1RedYellow or (c1RedBase and c2Yellow)
sweepHigh = high > high[1] and c2InsideC1
sweepLow = low < low[1] and c2InsideC1
canArm = barstate.isconfirmed and not previousCandleWasEntry

if canArm and showSell and showNormal and greenPattern and sweepHigh
    f_add(normalBearLows, normalBearHighs, normalBearLines, false, normalBearColor)
if canArm and showBuy and showNormal and redPattern and sweepLow
    f_add(normalBullLows, normalBullHighs, normalBullLines, true, normalBullColor)
if canArm and showSell and showAggressive and redPattern and sweepHigh
    f_add(aggressiveBearLows, aggressiveBearHighs, aggressiveBearLines, false, aggressiveBearColor)
if canArm and showBuy and showAggressive and greenPattern and sweepLow
    f_add(aggressiveBullLows, aggressiveBullHighs, aggressiveBullLines, true, aggressiveBullColor)

f_trim(normalBearLows, normalBearHighs, normalBearLines)
f_trim(normalBullLows, normalBullHighs, normalBullLines)
f_trim(aggressiveBearLows, aggressiveBearHighs, aggressiveBearLines)
f_trim(aggressiveBullLows, aggressiveBullHighs, aggressiveBullLines)

normalBear = f_resolve(normalBearLows, normalBearHighs, normalBearLines, false)
normalBull = f_resolve(normalBullLows, normalBullHighs, normalBullLines, true)
aggressiveBear = f_resolve(aggressiveBearLows, aggressiveBearHighs, aggressiveBearLines, false)
aggressiveBull = f_resolve(aggressiveBullLows, aggressiveBullHighs, aggressiveBullLines, true)

plotshape(normalBear, "Normal Bear", shape.circle, location.abovebar, normalBearColor, size=size.small)
plotshape(normalBull, "Normal Bull", shape.circle, location.belowbar, normalBullColor, size=size.small)
plotshape(aggressiveBear, "Aggressive Bear", shape.triangledown, location.abovebar, aggressiveBearColor, size=size.small)
plotshape(aggressiveBull, "Aggressive Bull", shape.triangleup, location.belowbar, aggressiveBullColor, size=size.small)

lastBarWasEntry := normalBear or normalBull or aggressiveBear or aggressiveBull
````

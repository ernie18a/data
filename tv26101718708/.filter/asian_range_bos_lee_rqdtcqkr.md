# Asian Range + BOS (Lee)

- url: https://www.tradingview.com/script/rQDTcqKr-Asian-Range-BOS-Lee/
- type: indicator
- pine_id: PUB;63437d203cff46178ad65361b74ed006
- version: 1.0

## Description

Do you want to save time on withdrawing liquidity on Asian so that it shows you whether it has withdrawn or not? If so, try it.

## Source Code

````pine
//@version=5
indicator("Asian Range + BOS WORKING", overlay=true)

// === INPUTY ===
asian = input.session("1700-0200", "Asian Session")

lineColor = input.color(color.black, "Line Color")
breakColor = input.color(color.green, "Break Color")
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)

showBOS = input.bool(true, "Show BOS")
bosColor = input.color(color.yellow, "BOS Color")

// === SESSION ===
inAsian = not na(time(timeframe.period, asian))

// === VAR ===
var float aHigh = na
var float aLow = na
var int startBar = na

var line highLine = na
var line lowLine = na

var bool drawn = false
var bool highBroken = false
var bool lowBroken = false

var bool sweepHigh = false
var bool sweepLow = false
var bool bosDone = false

// === RESET ===
if ta.change(time("D"))
    aHigh := na
    aLow := na
    startBar := na
    drawn := false
    highBroken := false
    lowBroken := false
    sweepHigh := false
    sweepLow := false
    bosDone := false

    if not na(highLine)
        line.delete(highLine)
    if not na(lowLine)
        line.delete(lowLine)

// === SBĚR ASIAN ===
if inAsian
    startBar := na(startBar) ? bar_index : startBar
    aHigh := na(aHigh) ? high : math.max(aHigh, high)
    aLow := na(aLow) ? low : math.min(aLow, low)

// === VYKRESLI PO SESSION ===
if not inAsian and not drawn and not na(aHigh)
    highLine := line.new(startBar, aHigh, bar_index, aHigh, width=lineWidth, color=lineColor)
    lowLine  := line.new(startBar, aLow, bar_index, aLow, width=lineWidth, color=lineColor)
    drawn := true

// === SWEEP + BREAK ===
if drawn
    if high > aHigh
        sweepHigh := true
        if not highBroken
            line.set_color(highLine, breakColor)
            line.set_x2(highLine, bar_index)
            highBroken := true

    if low < aLow
        sweepLow := true
        if not lowBroken
            line.set_color(lowLine, breakColor)
            line.set_x2(lowLine, bar_index)
            lowBroken := true

// === JEDNODUCHÝ BOS (GARANTOVANĚ SE UKÁŽE) ===
prevHigh = ta.highest(high, 10)[1]
prevLow  = ta.lowest(low, 10)[1]

bullBOS = sweepLow and close > prevHigh
bearBOS = sweepHigh and close < prevLow

// === PLOT BOS ===
if showBOS and not bosDone
    if bullBOS
        label.new(bar_index, high, "BOS ↑", color=bosColor, style=label.style_label_up)
        bosDone := true

    if bearBOS
        label.new(bar_index, low, "BOS ↓", color=bosColor, style=label.style_label_down)
        bosDone := true
````

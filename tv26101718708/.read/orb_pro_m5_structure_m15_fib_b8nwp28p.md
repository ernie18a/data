# ORB PRO M5 + STRUCTURE M15 + FIB

- url: https://www.tradingview.com/script/b8NWP28p/
- type: indicator
- pine_id: PUB;7358f77d3d2c40fab92e0122f9d64ea3
- version: 1.0

## Description

systeme Opening rang breakout + signal , zone of fibo 61.8 78.6

## Source Code

````pine
//@version=6
indicator("ORB PRO M5 + STRUCTURE M15 + FIB", overlay=true, max_boxes_count=50, max_lines_count=50)

//--------------------------------------------------
// TIMEZONE
//--------------------------------------------------
tz = "Europe/Paris"
isM5 = timeframe.period == "5"

//--------------------------------------------------
// ORB SESSION
//--------------------------------------------------
session = time(timeframe.period, "0815-0830", tz)
inRange = not na(session)
newRange = inRange and not inRange[1]

//--------------------------------------------------
// RANGE
//--------------------------------------------------
var float rangeHigh = na
var float rangeLow = na
var box orbBox = na

var bool breakoutDone = false
var int direction = 0
var bool signalDone = false

//--------------------------------------------------
// RANGE BUILD
//--------------------------------------------------
if newRange
    rangeHigh := high
    rangeLow := low
    breakoutDone := false
    direction := 0
    signalDone := false

    if not na(orbBox)
        box.delete(orbBox)

    orbBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.blue, 85), border_color=color.blue)

if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

    box.set_right(orbBox, bar_index)
    box.set_top(orbBox, rangeHigh)
    box.set_bottom(orbBox, rangeLow)

//--------------------------------------------------
// BREAKOUT 3 CLOTHES
//--------------------------------------------------
longBreak = not inRange and close > rangeHigh and close[1] > rangeHigh and close[2] > rangeHigh
shortBreak = not inRange and close < rangeLow and close[1] < rangeLow and close[2] < rangeLow

if longBreak
    breakoutDone := true
    direction := 1

if shortBreak
    breakoutDone := true
    direction := -1

//--------------------------------------------------
// INDICATORS
//--------------------------------------------------
smma50 = ta.rma(close, 50)
smmaUp = smma50 > smma50[5]
smmaDown = smma50 < smma50[5]

tenkan = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
kijun  = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2

//--------------------------------------------------
// VALIDATIONS
//--------------------------------------------------
buyValid =
     isM5 and breakoutDone and direction == 1 and not signalDone and
     close > smma50 and smmaUp and
     tenkan > kijun and
     tenkan > smma50 and kijun > smma50

sellValid =
     isM5 and breakoutDone and direction == -1 and not signalDone and
     close < smma50 and smmaDown and
     tenkan < kijun and
     tenkan < smma50 and kijun < smma50

//--------------------------------------------------
// SIGNAL
//--------------------------------------------------
buySignal = buyValid
sellSignal = sellValid

if buySignal or sellSignal
    signalDone := true

//--------------------------------------------------
// VISUAL SIGNAL
//--------------------------------------------------
buyColor = color.rgb(57, 255, 20)
sellColor = color.rgb(255, 20, 147)

barcolor(buySignal ? buyColor : sellSignal ? sellColor : na)

plotshape(buySignal, style=shape.triangleup, location=location.belowbar, size=size.tiny, color=buyColor)
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, size=size.tiny, color=sellColor)

//--------------------------------------------------
// STRUCTURE M15 (PIVOT BASE)
//--------------------------------------------------
mHigh = request.security(syminfo.tickerid, "15", ta.pivothigh(high, 3, 3))
mLow  = request.security(syminfo.tickerid, "15", ta.pivotlow(low, 3, 3))

var float lastHigh = na
var float lastLow = na

if not na(mHigh)
    lastHigh := mHigh

if not na(mLow)
    lastLow := mLow

//--------------------------------------------------
// FIB LINES
//--------------------------------------------------
var line fib618 = na
var line fib702 = na
var line fib786 = na

f_clear() =>
    if not na(fib618)
        line.delete(fib618)
    if not na(fib702)
        line.delete(fib702)
    if not na(fib786)
        line.delete(fib786)

//--------------------------------------------------
// FIB CREATION AFTER SIGNAL
//--------------------------------------------------
if buySignal and not na(lastHigh) and not na(lastLow)
    f_clear()

    fib618 := line.new(bar_index, lastLow + (lastHigh-lastLow)*0.618, bar_index+50, lastLow + (lastHigh-lastLow)*0.618, color=color.black, width=2)
    fib702 := line.new(bar_index, lastLow + (lastHigh-lastLow)*0.702, bar_index+50, lastLow + (lastHigh-lastLow)*0.702, color=color.red, width=2)
    fib786 := line.new(bar_index, lastLow + (lastHigh-lastLow)*0.786, bar_index+50, lastLow + (lastHigh-lastLow)*0.786, color=color.black, width=2)

if sellSignal and not na(lastHigh) and not na(lastLow)
    f_clear()

    fib618 := line.new(bar_index, lastHigh - (lastHigh-lastLow)*0.618, bar_index+50, lastHigh - (lastHigh-lastLow)*0.618, color=color.black, width=2)
    fib702 := line.new(bar_index, lastHigh - (lastHigh-lastLow)*0.702, bar_index+50, lastHigh - (lastHigh-lastLow)*0.702, color=color.red, width=2)
    fib786 := line.new(bar_index, lastHigh - (lastHigh-lastLow)*0.786, bar_index+50, lastHigh - (lastHigh-lastLow)*0.786, color=color.black, width=2)
````

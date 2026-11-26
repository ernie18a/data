# ORB PRO + FIB M15 + CONFIRMATIONS

- url: https://www.tradingview.com/script/1FyDuu99/
- type: indicator
- pine_id: PUB;7f710782201a44829d3ce9943aa991da
- version: 1.0

## Description

orb +  retracement dans le open range breakout plus une validation de la smma50 en soutien du prix attendre la retracement aprés confirmation pour rentré en position

## Source Code

````pine
//@version=6
indicator("ORB PRO + FIB M15 + CONFIRMATIONS", overlay=true, max_boxes_count=50, max_lines_count=50)

//--------------------------------------------------
// TIMEZONE
//--------------------------------------------------
tz = "Europe/Paris"

//--------------------------------------------------
// ORB SESSIONS
//--------------------------------------------------
morningRange   = not na(time(timeframe.period, "0815-0830", tz))
afternoonRange = not na(time(timeframe.period, "1415-1430", tz))

inRange = morningRange or afternoonRange
newRange = inRange and not inRange[1]

//--------------------------------------------------
// RANGE VARIABLES
//--------------------------------------------------
var float rangeHigh = na
var float rangeLow  = na
var box orbBox = na

var bool breakoutOK = false
var int direction = 0
var bool signalDone = false

//--------------------------------------------------
// PIVOTS M15 (FIBO BASE)
//--------------------------------------------------
m15High = request.security(syminfo.tickerid, "15", ta.pivothigh(high, 3, 3))
m15Low  = request.security(syminfo.tickerid, "15", ta.pivotlow(low, 3, 3))

var float lastPivotHigh = na
var float lastPivotLow  = na

if not na(m15High)
    lastPivotHigh := m15High

if not na(m15Low)
    lastPivotLow := m15Low

//--------------------------------------------------
// FIB LINES
//--------------------------------------------------
var line fib50 = na
var line fib618 = na

f_clearFib() =>
    if not na(fib50)
        line.delete(fib50)
    if not na(fib618)
        line.delete(fib618)

//--------------------------------------------------
// NEW RANGE RESET
//--------------------------------------------------
if newRange
    rangeHigh := high
    rangeLow := low

    breakoutOK := false
    direction := 0
    signalDone := false

    f_clearFib()

    if not na(orbBox)
        box.delete(orbBox)

    orbBox := box.new(left=bar_index, right=bar_index, top=high, bottom=low,
         bgcolor=color.new(color.blue, 85), border_color=color.blue)

//--------------------------------------------------
// BUILD RANGE
//--------------------------------------------------
if inRange
    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

    if not na(orbBox)
        box.set_right(orbBox, bar_index)
        box.set_top(orbBox, rangeHigh)
        box.set_bottom(orbBox, rangeLow)

//--------------------------------------------------
// EXTEND BOX
//--------------------------------------------------
if not inRange and not breakoutOK and not na(orbBox)
    box.set_right(orbBox, bar_index)

//--------------------------------------------------
// BREAKOUT 3 CLOSES
//--------------------------------------------------
longBreakout =
     not inRange and not breakoutOK and
     close > rangeHigh and close[1] > rangeHigh and close[2] > rangeHigh

shortBreakout =
     not inRange and not breakoutOK and
     close < rangeLow and close[1] < rangeLow and close[2] < rangeLow

if longBreakout
    breakoutOK := true
    direction := 1
    box.set_right(orbBox, bar_index)

if shortBreakout
    breakoutOK := true
    direction := -1
    box.set_right(orbBox, bar_index)

//--------------------------------------------------
// INDICATORS
//--------------------------------------------------
smma50 = ta.rma(close, 50)
smmaBull = smma50 > smma50[5]
smmaBear = smma50 < smma50[5]

tenkan = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
kijun  = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2

bullMomentum = tenkan > kijun
bearMomentum = tenkan < kijun

atr = ta.atr(14)
volOk = (rangeHigh - rangeLow) > atr * 0.8

//--------------------------------------------------
// SIGNALS
//--------------------------------------------------
buySignal =
     breakoutOK and direction == 1 and not signalDone and
     close > smma50 and smmaBull and bullMomentum and volOk

sellSignal =
     breakoutOK and direction == -1 and not signalDone and
     close < smma50 and smmaBear and bearMomentum and volOk

if buySignal or sellSignal
    signalDone := true

//--------------------------------------------------
// VISUAL SIGNALS
//--------------------------------------------------
buyCol = color.rgb(57,255,20)
sellCol = color.rgb(255,20,147)

barcolor(buySignal ? buyCol : sellSignal ? sellCol : na)

plotshape(buySignal, style=shape.triangleup, location=location.belowbar, size=size.tiny, color=buyCol)
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, size=size.tiny, color=sellCol)

//--------------------------------------------------
// FIBONACCI M15 (OPTION A)
//--------------------------------------------------
fibReady = breakoutOK

if fibReady and not na(lastPivotHigh) and not na(lastPivotLow)
    float fib50_val = na
    float fib618_val = na

    if direction == 1
        fib50_val := lastPivotLow + (lastPivotHigh - lastPivotLow) * 0.5
        fib618_val := lastPivotLow + (lastPivotHigh - lastPivotLow) * 0.618
    else
        fib50_val := lastPivotHigh - (lastPivotHigh - lastPivotLow) * 0.5
        fib618_val := lastPivotHigh - (lastPivotHigh - lastPivotLow) * 0.618

    if na(fib50)
        fib50 := line.new(bar_index, fib50_val, bar_index + 50, fib50_val, color=color.yellow, width=2)
        fib618 := line.new(bar_index, fib618_val, bar_index + 50, fib618_val, color=color.aqua, width=2)
````

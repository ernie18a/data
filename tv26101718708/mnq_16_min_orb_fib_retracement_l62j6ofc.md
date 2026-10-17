# MNQ 16 min. ORB Fib Retracement

- url: https://www.tradingview.com/script/L62j6OFc-MNQ-16-min-ORB-Fib-Retracement/
- type: indicator
- pine_id: PUB;4f889e0b816e422bb464e3e843e49643
- version: 1.0

## Description

Check out my indicator and let me know how it works for you....

## Source Code

````pine
//@version=5
indicator("MNQ ORB Fib TRIM Indicator", overlay=true)

// =====================================================
// SETTINGS
// =====================================================
fib50Level  = 0.5
fib618Level = 0.618

marketOpenHour   = 6
marketOpenMinute = 30

cutoffHour   = 10
cutoffMinute = 0

// =====================================================
// STATE
// =====================================================
var float rangeHigh = na
var float rangeLow  = na
var float sessionOpen = na

var bool rangeLocked = false
var int barCount = 0

var bool bullishBias = false
var bool bearishBias = false

var bool longTrigger = false
var bool shortTrigger = false

var int signalsToday = 0

// =====================================================
// RESET
// =====================================================
newDay = ta.change(time("D"))

if newDay
    rangeHigh := na
    rangeLow := na
    sessionOpen := na

    rangeLocked := false
    barCount := 0

    bullishBias := false
    bearishBias := false

    longTrigger := false
    shortTrigger := false

    signalsToday := 0

// =====================================================
// SESSION START
// =====================================================
sessionStart =
     hour(time, "America/Los_Angeles") == marketOpenHour and
     minute(time, "America/Los_Angeles") == marketOpenMinute

if sessionStart
    sessionOpen := open

// =====================================================
// OPENING RANGE
// =====================================================
if sessionStart
    barCount := 1
    rangeHigh := high
    rangeLow := low
    rangeLocked := false

else if barCount > 0 and barCount < 8
    barCount += 1

    rangeHigh := math.max(rangeHigh, high)
    rangeLow := math.min(rangeLow, low)

if barCount == 8
    rangeLocked := true

rangeReady =
     rangeLocked and
     not na(rangeHigh) and
     not na(rangeLow)

// =====================================================
// LOCKED DAILY BIAS
// =====================================================
rangeMid = (rangeHigh + rangeLow) / 2

if rangeReady and not bullishBias and not bearishBias

    bullishBias := close >= rangeMid
    bearishBias := not bullishBias

// =====================================================
// FIB LEVELS
// =====================================================
rangeSize =
     math.max(
         rangeHigh - rangeLow,
         syminfo.mintick)

bullFib50 =
     rangeHigh - (rangeSize * fib50Level)

bullFib618 =
     rangeHigh - (rangeSize * fib618Level)

bearFib50 =
     rangeLow + (rangeSize * fib50Level)

bearFib618 =
     rangeLow + (rangeSize * fib618Level)

fib50 =
     bullishBias ? bullFib50 : bearFib50

fib618 =
     bullishBias ? bullFib618 : bearFib618

// =====================================================
// TIME FILTER
// =====================================================
validTradingTime =
     (hour(time, "America/Los_Angeles") < cutoffHour) or
     (
         hour(time, "America/Los_Angeles") == cutoffHour and
         minute(time, "America/Los_Angeles") <= cutoffMinute
     )

// =====================================================
// LONG SETUP
// =====================================================
if rangeReady and bullishBias and signalsToday < 1

    if close < fib618
        longTrigger := true

longSignal =
     longTrigger and
     close > fib50 and
     validTradingTime

if longSignal
    longTrigger := false
    signalsToday += 1

// =====================================================
// SHORT SETUP
// =====================================================
if rangeReady and bearishBias and signalsToday < 1

    if close > fib618
        shortTrigger := true

shortSignal =
     shortTrigger and
     close < fib50 and
     validTradingTime

if shortSignal
    shortTrigger := false
    signalsToday += 1

// =====================================================
// VISUALS
// =====================================================
plot(
     rangeLocked ? rangeHigh : na,
     color=color.green,
     linewidth=2,
     title="Range High")

plot(
     rangeLocked ? rangeLow : na,
     color=color.red,
     linewidth=2,
     title="Range Low")

plot(
     rangeLocked ? fib50 : na,
     color=color.yellow,
     linewidth=2,
     title="Fib 50")

plot(
     rangeLocked ? fib618 : na,
     color=color.orange,
     linewidth=2,
     title="Fib 618")

plot(
     sessionOpen,
     color=color.white,
     linewidth=2,
     title="Session Open")

// =====================================================
// BIAS BACKGROUND
// =====================================================
bgcolor(
     bullishBias ? color.new(color.green, 92) :
     bearishBias ? color.new(color.red, 92) :
     na)

// =====================================================
// SIGNAL LABELS
// =====================================================
plotshape(
     longSignal,
     title="BUY",
     location=location.belowbar,
     color=color.lime,
     style=shape.labelup,
     text="BUY")

plotshape(
     shortSignal,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

// =====================================================
// ALERTS
// =====================================================
alertcondition(
     longSignal,
     title="MNQ LONG",
     message="MNQ ORB Fib Long Signal")

alertcondition(
     shortSignal,
     title="MNQ SHORT",
     message="MNQ ORB Fib Short Signal")
````

# ORB Prop Firm Execution Model (Fully Anchored)

- url: https://www.tradingview.com/script/VRcfgfLp-ORB-Prop-Firm-Execution-Model-Fully-Anchored/
- type: indicator
- pine_id: PUB;5abee1f668414696b78f55ea98602b04
- version: 1.0

## Description

Plots 15 minute highs and lows plus opening 1 min VWAP.

## Source Code

````pine
//@version=5
indicator("ORB Prop Firm Execution Model (Fully Anchored)", overlay=true, max_lines_count=100)

//=====================
// SESSION ANCHOR
//=====================
sessionOpen  = timestamp("America/New_York", year, month, dayofmonth, 9, 30)
sessionClose = timestamp("America/New_York", year, month, dayofmonth, 16, 0)

newDay = ta.change(time("D"))
inSession = time >= sessionOpen and time <= sessionClose

orbMinutes = 15
orbEnd = sessionOpen + orbMinutes * 60 * 1000

inORB = time >= sessionOpen and time < orbEnd

//=====================
// ORB CALCULATION (ANCHOR BASED)
//=====================
var float orbHigh = na
var float orbLow  = na

if newDay
    orbHigh := na
    orbLow := na

if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

orbReady = time >= orbEnd and not na(orbHigh)

//=====================
// ANCHORED ORB LEVELS (TIME BASED, NO BAR_INDEX)
//=====================
var line hiLine = na
var line loLine = na
var line hiExt1 = na
var line loExt1 = na
var line hiExt2 = na
var line loExt2 = na

if newDay
    line.delete(hiLine)
    line.delete(loLine)
    line.delete(hiExt1)
    line.delete(loExt1)
    line.delete(hiExt2)
    line.delete(loExt2)

if orbReady
    orbRange = orbHigh - orbLow

    hiLine := line.new(sessionOpen, orbHigh, sessionClose, orbHigh, xloc=xloc.bar_time, color=color.green, width=2)
    loLine := line.new(sessionOpen, orbLow, sessionClose, orbLow, xloc=xloc.bar_time, color=color.red, width=2)

    hiExt1 := line.new(sessionOpen, orbHigh + orbRange * 0.5, sessionClose, orbHigh + orbRange * 0.5, xloc=xloc.bar_time, color=color.new(color.green, 60))
    loExt1 := line.new(sessionOpen, orbLow - orbRange * 0.5, sessionClose, orbLow - orbRange * 0.5, xloc=xloc.bar_time, color=color.new(color.red, 60))

    hiExt2 := line.new(sessionOpen, orbHigh + orbRange, sessionClose, orbHigh + orbRange, xloc=xloc.bar_time, color=color.green)
    loExt2 := line.new(sessionOpen, orbLow - orbRange, sessionClose, orbLow - orbRange, xloc=xloc.bar_time, color=color.red)

//=====================
// AVWAP (SESSION ANCHORED TO TIME)
//=====================
var float cumVol = 0.0
var float cumPV  = 0.0

if newDay
    cumVol := 0
    cumPV := 0

if inSession
    cumVol += volume
    cumPV += hlc3 * volume

avwap = cumPV / cumVol

plot(avwap, color=color.blue, linewidth=2)

//=====================
// REGIME FILTER (CHOP vs TREND)
//=====================
trend = ta.sma(close, 20)
isTrendUp = close > trend and trend > trend[1]
isTrendDown = close < trend and trend < trend[1]

//=====================
// LIQUIDITY SWEEP DETECTION (FAKE BREAKOUTS)
//=====================
sweepHigh = high > orbHigh and close < orbHigh
sweepLow  = low < orbLow and close > orbLow

//=====================
// VOLUME CONFIRMATION
//=====================
volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * 1.5

//=====================
// EXECUTION SIGNALS
//=====================
longBreak = ta.crossover(close, orbHigh)
shortBreak = ta.crossunder(close, orbLow)

// HIGH QUALITY ONLY (FILTERED EXECUTION)
longSignal = orbReady and longBreak and close > avwap and isTrendUp and volSpike and not sweepHigh
shortSignal = orbReady and shortBreak and close < avwap and isTrendDown and volSpike and not sweepLow

//=====================
// VISUAL SIGNALS (MARK ENTRY POINTS)
//=====================
plotshape(longSignal, title="LONG EXEC", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(shortSignal, title="SHORT EXEC", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

//=====================
// ALERTS
//=====================
alertcondition(longSignal, "LONG EXECUTION", "Prop firm LONG ORB setup")
alertcondition(shortSignal, "SHORT EXECUTION", "Prop firm SHORT ORB setup")
````

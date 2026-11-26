# ORB Hardened Pro + AVWAP (No Box Version)

- url: https://www.tradingview.com/script/fEoearHw-ORB-Hardened-Pro-AVWAP-No-Box-Version/
- type: indicator
- pine_id: PUB;9b2a037fe3e6429cb8cc786e403ab6d4
- version: 1.0

## Description

Plots 15 minute high and lows, anchors vwap to the opening.

## Source Code

````pine
//@version=5
indicator("ORB Hardened Pro + AVWAP (No Box Version)", overlay=true, max_lines_count=100)

//=====================
// INPUTS
//=====================
orbMinutes = input.int(15, "ORB Minutes")
showExt    = input.bool(true, "Show Extensions")
showVWAP   = input.bool(true, "Show AVWAP")

//=====================
// SESSION (NY TIME)
//=====================
sessionOpen  = timestamp("America/New_York", year, month, dayofmonth, 9, 30)
sessionClose = timestamp("America/New_York", year, month, dayofmonth, 16, 0)

newDay = ta.change(time("D"))
inSession = time >= sessionOpen and time <= sessionClose

orbEnd = sessionOpen + orbMinutes * 60 * 1000
inORB = time >= sessionOpen and time < orbEnd

//=====================
// ORB CALC
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
// ORB LINES (HARDENED REPLACEMENT FOR BOX)
//=====================
var line orbHighLine = na
var line orbLowLine  = na
var line orbTopExt   = na
var line orbBotExt   = na

if newDay
    line.delete(orbHighLine)
    line.delete(orbLowLine)
    line.delete(orbTopExt)
    line.delete(orbBotExt)

if orbReady
    line.delete(orbHighLine)
    line.delete(orbLowLine)
    line.delete(orbTopExt)
    line.delete(orbBotExt)

    orbHighLine := line.new(sessionOpen, orbHigh, sessionClose, orbHigh, xloc=xloc.bar_time, color=color.green, width=2)
    orbLowLine  := line.new(sessionOpen, orbLow,  sessionClose, orbLow,  xloc=xloc.bar_time, color=color.red, width=2)

    orbRange = orbHigh - orbLow

    if showExt
        orbTopExt := line.new(sessionOpen, orbHigh + orbRange * 0.5, sessionClose, orbHigh + orbRange * 0.5, xloc=xloc.bar_time, color=color.new(color.green, 60))
        orbBotExt := line.new(sessionOpen, orbLow - orbRange * 0.5, sessionClose, orbLow - orbRange * 0.5, xloc=xloc.bar_time, color=color.new(color.red, 60))

//=====================
// AVWAP (SESSION ANCHORED)
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

plot(showVWAP ? avwap : na, color=color.blue, linewidth=2)

//=====================
// SIGNAL FILTERS
//=====================
volAvg = ta.sma(volume, 20)
volSpike = volume > volAvg * 1.5

longBreak = ta.crossover(close, orbHigh)
shortBreak = ta.crossunder(close, orbLow)

longFake = high > orbHigh and close < orbHigh
shortFake = low < orbLow and close > orbLow

bull = close > avwap
bear = close < avwap

//=====================
// FINAL SIGNALS
//=====================
longSignal = orbReady and longBreak and bull and volSpike and not longFake
shortSignal = orbReady and shortBreak and bear and volSpike and not shortFake

plotshape(longSignal, title="LONG", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(shortSignal, title="SHORT", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

//=====================
// ALERTS
//=====================
alertcondition(longSignal, "LONG ORB", "ORB LONG confirmed")
alertcondition(shortSignal, "SHORT ORB", "ORB SHORT confirmed")
````

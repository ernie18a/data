# ORB Breakout Reset Alert (9:30-10:00 ET)

- url: https://www.tradingview.com/script/s7I2QN8o-ORB-Breakout-Reset-Alert-9-30-10-00-ET/
- type: indicator
- pine_id: PUB;a3f1e6125d6641f4b64cc5d3ee916d45
- version: 1.0

## Description

Opening Range Breakout indicator for intraday charts. Triggers alerts when price closes above the 9:30–10:00 AM Eastern opening range high with strong volume and price above VWAP before 11:30 AM.

## Source Code

````pine
//@version=5
indicator("ORB Breakout Reset Alert (9:30-10:00 ET)", overlay=true, max_labels_count=500)

//==============================
// USER INPUTS
//==============================
tz             = input.string("America/New_York", "Time Zone")
volMultiplier  = input.float(1.5, "Volume Multiplier", minval=0.1, step=0.1)
showBg         = input.bool(true, "Show Light Green Background")
showTriangle   = input.bool(true, "Show Triangle Above Signal Bar")
showORHighLine = input.bool(true, "Show Opening Range High Line")
showVWAP       = input.bool(true, "Show VWAP")

//==============================
// INTRADAY CHECK
//==============================
if not timeframe.isintraday
    runtime.error("This indicator is designed for intraday charts only.")

//==============================
// TIME LOGIC
//==============================
hourET   = hour(time, tz)
minuteET = minute(time, tz)

inOpeningRange = (hourET == 9 and minuteET >= 30 and minuteET < 60)
inSignalWindow = (hourET == 9 and minuteET >= 30) or (hourET == 10) or (hourET == 11 and minuteET < 30)
afterOpeningRange = (hourET > 9) or (hourET == 10)

//==============================
// NEW DAY RESET
//==============================
currDay  = dayofmonth(time, tz)
prevDay  = dayofmonth(time[1], tz)
isNewDay = currDay != prevDay

//==============================
// VARIABLES
//==============================
var float orHigh      = na
var float orVolSum    = 0.0
var int   orBarCount  = 0
var float orAvgVolume = na
var bool  breakoutArmed = true

if isNewDay
    orHigh         := na
    orVolSum       := 0.0
    orBarCount     := 0
    orAvgVolume    := na
    breakoutArmed  := true

//==============================
// BUILD OPENING RANGE
//==============================
if inOpeningRange
    orHigh     := na(orHigh) ? high : math.max(orHigh, high)
    orVolSum   += volume
    orBarCount += 1

if afterOpeningRange and na(orAvgVolume) and orBarCount > 0
    orAvgVolume := orVolSum / orBarCount

//==============================
// VWAP
//==============================
vwapValue = ta.vwap(hlc3)

//==============================
// RE-ARM LOGIC
//==============================
if not na(orHigh) and close < orHigh
    breakoutArmed := true

//==============================
// CONDITIONS
//==============================
breakoutCondition = not na(orHigh) and ta.crossover(close, orHigh)
volumeCondition   = not na(orAvgVolume) and volume >= (volMultiplier * orAvgVolume)
vwapCondition     = close > vwapValue
timeCondition     = inSignalWindow

signal = breakoutArmed and breakoutCondition and volumeCondition and vwapCondition and timeCondition

if signal
    breakoutArmed := false

//==============================
// VISUALS
//==============================
plot(showORHighLine and not na(orHigh) ? orHigh : na, title="Opening Range High", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(showVWAP ? vwapValue : na, title="VWAP", color=color.blue, linewidth=1)
bgcolor(showBg and signal ? color.new(color.lime, 85) : na, title="Signal Background")
plotshape(showTriangle and signal, title="ORB Breakout Signal", style=shape.triangleup, location=location.abovebar, size=size.small, color=color.lime, text="ORB")

//==============================
// ALERT
//==============================
alertcondition(signal, title="ORB Long Breakout", message="ORB breakout on {{ticker}} at {{close}}. Close broke above the 9:30-10:00 ET opening range high, volume exceeded threshold, and price is above VWAP.")

// Optional live alert
if signal and barstate.isconfirmed
    alert("ORB breakout on " + syminfo.ticker + " at price " + str.tostring(close), alert.freq_once_per_bar_close)
````

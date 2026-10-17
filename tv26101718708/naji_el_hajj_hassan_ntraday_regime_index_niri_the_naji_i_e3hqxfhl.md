# NAJI EL HAJJ HASSAN ntraday Regime Index (NIRI) The Naji I

- url: https://www.tradingview.com/script/E3hQxfhL-NAJI-EL-HAJJ-HASSAN-ntraday-Regime-Index-NIRI-The-Naji-I/
- type: indicator
- pine_id: PUB;82640f3ca74b4c62b3ff07fd3fd7ceea
- version: 1.0

## Description

Naji Intraday Regime Index (NIRI)
The Naji Intraday Regime Index (NIRI) is an adaptive market activity and volatility regime indicator designed to identify whether the current trading session is behaving in compression, balance, expansion, or momentum conditions relative to its historical intraday behavior.
Unlike traditional volatility indicators such as ATR, NIRI compares the current session’s cumulative intraday movement against the average movement of the same exact time window across a user-defined historical sample.
The indicator measures the market’s real intraday activity using cumulative absolute price movement:
∑
∣
c
l
o
s
e
−
c
l
o
s
e
[
1
]
∣
∑∣close−close[1]∣
This approach captures actual market participation and directional activity more effectively than simple net price change, allowing traders to detect:
ranging environments,
volatility compression,
session expansion,
abnormal momentum conditions,
and statistically quiet or active trading periods.
NIRI dynamically compares:
the current day’s movement from a selected starting time (market open or custom time),
to a selected ending time (current time or custom time),
against the same intraday window over a configurable number of previous trading sessions.
The output is expressed as a relative activity percentage:
C
u
r
r
e
n
t
 
M
o
v
e
m
e
n
t
H
i
s
t
o
r
i
c
a
l
 
A
v
e
r
a
g
e
×
100
Historical Average
Current Movement
​	
 ×100
Interpretation example:
Below 70% → Compression / low activity / ranging conditions
70%–100% → Normal session behavior
Above 100% → Expansion relative to historical norms
Above 130% → Strong momentum or abnormal volatility
The indicator is designed as a market regime filter rather than a directional signal generator. It helps traders adapt strategy selection based on current session conditions:
trend-following during expansion,
mean reversion during compression,
and risk reduction during abnormal volatility.
Key Features:
Adaptive intraday volatility comparison
Same-time historical session analysis
Automatic or manual session timing
User-defined lookback period
Relative movement normalization
Ranging and expansion regime detection
Instrument-independent behavior modeling
NIRI is especially effective for:
index futures,
forex,
crypto,
commodities,
and highly session-dependent markets where volatility behavior changes significantly throughout the trading day.
Created by Naji.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rain_mustfall

//@version=5
indicator("Intraday Relative Movement Comparator", overlay=false)

//====================================================
// USER INPUTS
//====================================================

// Comparison days
lookbackDays = input.int(30, "Comparison Days", minval=1)

// Start mode
useSessionOpen = input.bool(true, "Start From Market Open?")

manualStartHour = input.int(1, "Manual Start Hour", minval=0, maxval=23)
manualStartMinute = input.int(0, "Manual Start Minute", minval=0, maxval=59)

// End mode
useCurrentTime = input.bool(true, "End At Current Time?")

manualEndHour = input.int(9, "Manual End Hour", minval=0, maxval=23)
manualEndMinute = input.int(0, "Manual End Minute", minval=0, maxval=59)

// Session
sessionInput = input.session("0000-2359", "Market Session")

// Thresholds
rangeThreshold = input.float(70.0, "Ranging Threshold %", step=1)

//====================================================
// SESSION DETECTION
//====================================================

inSession = not na(time(timeframe.period, sessionInput))

newSession = inSession and not inSession[1]

// Store session start timestamp
var int sessionStart = na

if newSession
    sessionStart := time

//====================================================
// START / END TIME LOGIC
//====================================================

// Current bar date
y = year(time)
m = month(time)
d = dayofmonth(time)

// Manual start timestamp
manualStart = timestamp(y, m, d, manualStartHour, manualStartMinute)

// Manual end timestamp
manualEnd = timestamp(y, m, d, manualEndHour, manualEndMinute)

// Final start
startTime = useSessionOpen ? sessionStart : manualStart

// Final end
endTime = useCurrentTime ? time : manualEnd

// Is current bar inside measurement window?
insideWindow = time >= startTime and time <= endTime

//====================================================
// MOVEMENT CALCULATION
//====================================================

// Absolute movement per bar
barMove = math.abs(close - close[1])

// Accumulate today's movement
var float todayMove = 0.0

if newSession
    todayMove := 0.0

if insideWindow
    todayMove += barMove

//====================================================
// HISTORICAL COMPARISON
//====================================================

// We store completed daily movement values
var movementArray = array.new_float()

// At session close save today's movement
sessionEnded = not inSession and inSession[1]

if sessionEnded
    array.unshift(movementArray, todayMove)

    // Keep only lookback size
    if array.size(movementArray) > lookbackDays
        array.pop(movementArray)

// Average historical movement
float historicalAvg = na

if array.size(movementArray) > 0
    float sum = 0.0

    for i = 0 to array.size(movementArray) - 1
        sum += array.get(movementArray, i)

    historicalAvg := sum / array.size(movementArray)

//====================================================
// RELATIVE STRENGTH
//====================================================

relativePercent = historicalAvg > 0
     ? (todayMove / historicalAvg) * 100
     : na

//====================================================
// RANGE DETECTION
//====================================================

isRanging = relativePercent < rangeThreshold

//====================================================
// PLOTS
//====================================================

plot(todayMove, title="Today's Movement", linewidth=2)

plot(historicalAvg, title="Historical Average", linewidth=2)

plot(relativePercent, title="Relative %", linewidth=3)

// Threshold line
hline(rangeThreshold, "Range Threshold")

bgcolor(isRanging ? color.new(color.red, 85) : color.new(color.green, 85))

//====================================================
// LABEL
//====================================================

var label lbl = na

if barstate.islast
    label.delete(lbl)

    txt =
         "Today Move: " + str.tostring(todayMove, format.mintick) + "\n" +
         "Historical Avg: " + str.tostring(historicalAvg, format.mintick) + "\n" +
         "Relative: " + str.tostring(relativePercent, "#.##") + "%\n" +
         "State: " + (isRanging ? "RANGING" : "EXPANDING")

    lbl := label.new(
         bar_index,
         relativePercent,
         txt,
         style=label.style_label_left,
         textcolor=color.white,
         color=isRanging ? color.red : color.green
     )
````

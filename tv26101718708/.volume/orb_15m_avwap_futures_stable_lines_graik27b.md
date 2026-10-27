# ORB 15m + AVWAP (Futures) [Stable Lines]. 

- url: https://www.tradingview.com/script/GraiK27b-ORB-15m-AVWAP-Futures-Stable-Lines/
- type: indicator
- pine_id: PUB;b155de192ae24e09ba6850b8dcd011a6
- version: 1.0

## Description

Marks 15 min high - low with AVWAP on first candle. Plots the 15 min open.

## Source Code

````pine
//@version=5
indicator("ORB 15m + AVWAP (Futures) [Stable Lines]", overlay=true)

// ===== INPUTS =====
orbMinutes = input.int(15, "ORB Minutes")
showVWAP   = input.bool(true, "Show AVWAP")

// ===== SESSION =====
inSession = not na(time(timeframe.period, "0930-1600"))
newSession = inSession and not inSession[1]

// Track bars since open
var int barCount = 0
if newSession
    barCount := 0
else if inSession
    barCount += 1

barsInORB = math.round(orbMinutes / timeframe.multiplier)

// ===== ORB CALC =====
var float orbHigh = na
var float orbLow  = na

if newSession
    orbHigh := high
    orbLow  := low
else if inSession and barCount < barsInORB
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow, low)

// ===== DRAW LINES =====
var line highLine = na
var line lowLine  = na

// When ORB completes → draw new lines
if barCount == barsInORB
    // delete previous day's lines
    line.delete(highLine)
    line.delete(lowLine)

    // create new ones
    highLine := line.new(bar_index, orbHigh, bar_index + 1, orbHigh, extend=extend.right, color=color.green, width=2)
    lowLine  := line.new(bar_index, orbLow,  bar_index + 1, orbLow,  extend=extend.right, color=color.red, width=2)

// ===== AVWAP =====
var float cumVol = 0.0
var float cumPV  = 0.0

if newSession
    cumVol := volume
    cumPV  := hlc3 * volume
else if inSession
    cumVol += volume
    cumPV  += hlc3 * volume

avwap = cumPV / cumVol

plot(showVWAP and inSession ? avwap : na, "AVWAP", color=color.blue, linewidth=2)
````

# Pure PA & MS System

- url: https://www.tradingview.com/script/m5UKrZxf-Pure-PA-MS-System/
- type: indicator
- pine_id: PUB;9f0d6ae91b6a413c8604e82c11f16b73
- version: 1.0

## Description

This script reads real structure across multiple timeframes (HTF, MTF, and LTF) to identify true directional bias, alignment, and trade opportunities. It focuses on:

Structure-based bias (not indicators or lagging signals)
Real alignment across timeframes
Clear entry, continuation, and exit signals
Volume validation to confirm participation

Designed to cut through noise and avoid overcomplication, this system prioritizes clarity, efficiency, and realistic market behavior.

If you trade based on how price actually moves — not indicators — this is built for you.

## Source Code

````pine
//@version=5
indicator("Pure PA & MS System", overlay=true, max_labels_count=500)

// ==============================
// INPUTS
// ==============================
htf_tf   = input.timeframe("240", "Bias Timeframe (4H)")
mtf_tf   = input.timeframe("60", "Structure Timeframe (1H)")
pivotLen = input.int(2, "Pivot Strength (Exit Structure)", minval=1)

// ==============================
// STRUCTURE FUNCTION
// ==============================
f_structure(_high, _low) =>
    ph = ta.pivothigh(_high, 3, 3)
    pl = ta.pivotlow(_low, 3, 3)

    lastHigh = ta.valuewhen(not na(ph), ph, 0)
    lastLow  = ta.valuewhen(not na(pl), pl, 0)

    bull = not na(lastLow) and _low > lastLow
    bear = not na(lastHigh) and _high < lastHigh

    [bull, bear]

// ==============================
// HTF (4H)
// ==============================
htf_high = request.security(syminfo.tickerid, htf_tf, high)
htf_low  = request.security(syminfo.tickerid, htf_tf, low)
[htfBull, htfBear] = f_structure(htf_high, htf_low)

// ==============================
// MTF (1H)
// ==============================
mtf_high = request.security(syminfo.tickerid, mtf_tf, high)
mtf_low  = request.security(syminfo.tickerid, mtf_tf, low)
[mtfBull, mtfBear] = f_structure(mtf_high, mtf_low)

// ==============================
// LTF (FIXED — NOW STRUCTURE BASED)
// ==============================
[ltfBull, ltfBear] = f_structure(high, low)

// ==============================
alignment = (htfBull and mtfBull and ltfBull) or (htfBear and mtfBear and ltfBear)

// ==============================
pullback = (htfBull and (mtfBear or ltfBear)) or (htfBear and (mtfBull or ltfBull))
continuationPhase = (htfBull and mtfBull and ltfBull) or (htfBear and mtfBear and ltfBear)

// ==============================
higherHigh = high > high[1]
lowerLow   = low < low[1]

trendStrength =
     (higherHigh ? 1 : 0) +
     (high[1] > high[2] ? 1 : 0) +
     (high[2] > high[3] ? 1 : 0) +
     (high[3] > high[4] ? 1 : 0) +
     (high[4] > high[5] ? 1 : 0) +
     (lowerLow ? 1 : 0) +
     (low[1] < low[2] ? 1 : 0) +
     (low[2] < low[3] ? 1 : 0) +
     (low[3] < low[4] ? 1 : 0) +
     (low[4] < low[5] ? 1 : 0)

isConsolidating = trendStrength < 3

// ==============================
// VOLUME
// ==============================
volAvg = ta.sma(volume, 20)
volumePercent = volAvg > 0 ? volume / volAvg : 0

volColor =
     volumePercent < 0.6 ? color.gray :
     volumePercent < 1.0 ? color.green :
     color.rgb(0, 100, 0)

volDisplay = str.tostring(volumePercent * 100, "#.##") + "%"

// ==============================
// STATE
// ==============================
var bool inTrade = false
var bool isLong  = false

var int barsSinceEntry = 0
var int barsSinceCont  = 0
var bool continuationSeen = false

// ==============================
body = math.abs(close - open)
candleRange = high - low

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

bullRejection = candleRange > 0 and lowerWick / candleRange >= 0.20
bearRejection = candleRange > 0 and upperWick / candleRange >= 0.20

// ==============================
strongBull = candleRange > 0 and close > open and body / candleRange >= 0.5
strongBear = candleRange > 0 and close < open and body / candleRange >= 0.5

// ==============================
entryLong  = not inTrade and not isConsolidating and htfBull and alignment and bullRejection[1] and strongBull and volumePercent >= 0.6
entryShort = not inTrade and not isConsolidating and htfBear and alignment and bearRejection[1] and strongBear and volumePercent >= 0.6

if entryLong
    inTrade := true
    isLong := true
    barsSinceEntry := 0
    continuationSeen := false

if entryShort
    inTrade := true
    isLong := false
    barsSinceEntry := 0
    continuationSeen := false

// ==============================
impulseHigh = ta.highest(high, 5)
impulseLow  = ta.lowest(low, 5)
impulse = impulseHigh - impulseLow

pullbackValid = impulse > 0 and (isLong ? (impulseHigh - low) : (high - impulseLow)) / impulse <= 0.55
breakStruct = isLong ? close > high[1] : close < low[1]

continuation = inTrade and not isConsolidating and pullbackValid and breakStruct

if continuation
    continuationSeen := true
    barsSinceCont := 0
else if inTrade and continuationSeen
    barsSinceCont += 1

if inTrade
    barsSinceEntry += 1

// ==============================
atr = ta.atr(14)
moveInFavor = isLong ? (high - close[1]) : (close[1] - low)

noMove = not continuationSeen and barsSinceEntry >= 8 and moveInFavor < atr * 0.5
fail = continuationSeen and barsSinceCont >= 8

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

structureBreak = (isLong and not na(pl) and close < pl) or (not isLong and not na(ph) and close > ph)

exitTrade = inTrade and not isConsolidating and (noMove or fail or structureBreak)

if exitTrade
    inTrade := false
    continuationSeen := false
    barsSinceEntry := 0
    barsSinceCont := 0

// ==============================
// SIGNALS
// ==============================
plotshape(entryLong, location=location.belowbar, style=shape.labelup, text="BUY", color=color.green, textcolor=color.white)
plotshape(entryShort, location=location.abovebar, style=shape.labeldown, text="SELL", color=color.red, textcolor=color.white)

plotshape(continuation and isLong, location=location.belowbar, style=shape.circle, size=size.tiny, color=color.green)
plotshape(continuation and not isLong, location=location.abovebar, style=shape.circle, size=size.tiny, color=color.red)

plotshape(exitTrade and isLong, location=location.abovebar, style=shape.labeldown, text="BUY EXIT", color=color.green, textcolor=color.white)
plotshape(exitTrade and not isLong, location=location.belowbar, style=shape.labelup, text="SELL EXIT", color=color.red, textcolor=color.white)

// ==============================
// ALERT (ONLY ONE)
// ==============================
anySignal = entryLong or entryShort or continuation or exitTrade
alertcondition(anySignal and barstate.isconfirmed, "ANY SIGNAL", "ANY SIGNAL")

// ==============================
// DASHBOARD
// ==============================
var table dash = table.new(position.top_right, 1, 5)

table.cell(dash, 0, 0, "BIAS: " + (htfBull ? "BULL" : "BEAR"), bgcolor=htfBull ? color.green : color.red, text_color=color.white)
table.cell(dash, 0, 1, "ALIGN: " + (alignment ? "YES" : "NO"), bgcolor=alignment ? color.green : color.red, text_color=color.white)
table.cell(dash, 0, 2, "TRADE: " + (inTrade ? (isLong ? "BUY" : "SELL") : "NONE"), bgcolor=inTrade ? (isLong ? color.green : color.red) : color.gray, text_color=color.white)
table.cell(dash, 0, 3, "PHASE: " + (continuationPhase ? "CONTINUATION" : pullback ? "PULLBACK" : "NEUTRAL"),
     bgcolor=continuationPhase ? color.green : pullback ? color.orange : color.gray, text_color=color.white)
table.cell(dash, 0, 4, "VOL: " + volDisplay, bgcolor=volColor, text_color=color.white)
````

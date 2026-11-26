# ORB Arrow with Advanced Filters

- url: https://www.tradingview.com/script/brotbU0P-ORB-Arrow-with-Advanced-Filters/
- type: indicator
- pine_id: PUB;2fdab80b9a5c4bce836bda0e6a4eadde
- version: 1.0

## Description

Arrows showing buy and sell signals. Trail version.

## Source Code

````pine
//@version=5
indicator("ORB Arrow with Advanced Filters", overlay=true)

// ============================
// SESSION ANCHORING VARIABLES
// ============================
sessionOpen = timestamp("America/New_York", year, month, dayofmonth, 9, 30)
sessionClose = timestamp("America/New_York", year, month, dayofmonth, 16, 0)

orbMinutes = 15
orbEnd = sessionOpen + orbMinutes * 60 * 1000

inSession = time >= sessionOpen and time <= sessionClose
inORB = time >= sessionOpen and time < orbEnd

// ============================
// ORB CALCULATION (ANCHOR BASED)
// ============================
var float orbHigh = na
var float orbLow  = na

// ORB logic - Calculate high and low within ORB time range (first 15 minutes)
if inORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

// ============================
// VOLUME FILTERING
// ============================
volumeMA = ta.sma(volume, 20)  // 20-period volume moving average

// ============================
// ATR FILTERING
// ============================
atrValue = ta.atr(14)  // 14-period ATR
atrThreshold = 0.5  // Minimum ATR threshold for filtering

// ============================
// RSI FILTERING
// ============================
rsiValue = ta.rsi(close, 14)

// ============================
// PRICE ACTION CONFIRMATION (CLOSE ABOVE OR BELOW ORB)
// ============================
longSignal = ta.crossover(close, orbHigh) and volume > volumeMA and atrValue > atrThreshold and rsiValue < 70 and close > orbHigh
shortSignal = ta.crossunder(close, orbLow) and volume > volumeMA and atrValue > atrThreshold and rsiValue > 30 and close < orbLow

// ============================
// PLOTTING SIGNALS (ARROWS)
// ============================
plotshape(longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ============================
// ALERT CONDITIONS
// ============================
alertcondition(longSignal, "Long Signal", "Long entry based on ORB break above ORB High with filters.")
alertcondition(shortSignal, "Short Signal", "Short entry based on ORB break below ORB Low with filters.")
````

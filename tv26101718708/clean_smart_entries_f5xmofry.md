# Clean Smart Entries

- url: https://www.tradingview.com/script/f5xmoFrY-Clean-Smart-Entries/
- type: indicator
- pine_id: PUB;c13b75e9c33249a09e555a1259ec9508
- version: 1.0

## Description

This is a multi-session trading indicator designed to help traders clearly identify key market sessions and stay aware of high-impact events. It automatically highlights major trading sessions such as London, New York, and Asia, allowing you to quickly understand current market conditions at a glance.

The indicator also includes a real-time session label, so you always know which session is active without needing to check manually. In addition, a built-in news guide provides awareness of upcoming high-impact events, helping you avoid unexpected volatility and manage risk more effectively.

This tool is ideal for traders who focus on intraday strategies, session-based setups, and volatility-driven moves. It simplifies chart analysis by combining session tracking and fundamental awareness into one clean, easy-to-read display.

## Source Code

````pine
//@version=5
indicator("Clean Smart Entries", overlay=true)

// === SWINGS ===
length = 5
swingHigh = ta.pivothigh(high, length, length)
swingLow  = ta.pivotlow(low, length, length)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

// === LIQUIDITY SWEEP ===
liqSweepBuy  = low < lastLow and close > lastLow
liqSweepSell = high > lastHigh and close < lastHigh

// === STRUCTURE SHIFT (CHoCH) ===
bullShift = close > lastHigh
bearShift = close < lastLow

// === TREND ===
var int trend = 0
if bullShift
    trend := 1
if bearShift
    trend := -1

// === PULLBACK ENTRY (THIS FIXES RANDOM SIGNALS) ===
pullbackBuy  = trend == 1 and close < high[1]
pullbackSell = trend == -1 and close > low[1]

// === SESSIONS (adjust if needed) ===
london  = (hour >= 2 and hour <= 5)
newyork = (hour >= 7 and hour <= 10)

sessionOK = london or newyork

// === FINAL CONDITIONS ===
buy = liqSweepBuy and bullShift and pullbackBuy and sessionOK
sell = liqSweepSell and bearShift and pullbackSell and sessionOK

// === PLOT CLEAN SIGNALS ===
plotshape(buy, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sell, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// === SESSION LABEL ON CHART ===
sessionText = london ? "London" : newyork ? "New York" : "Off"

var label sessionLabel = na
if barstate.islast
    label.delete(sessionLabel)
    sessionLabel := label.new(bar_index, high, "sessionText")
````

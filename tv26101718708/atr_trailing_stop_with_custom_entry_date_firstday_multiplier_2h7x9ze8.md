# ATR Trailing Stop with Custom Entry Date & First-Day Multiplier

- url: https://www.tradingview.com/script/2h7X9ZE8-ATR-Trailing-Stop-with-Custom-Entry-Date-First-Day-Multiplier/
- type: indicator
- pine_id: PUB;4519a199ecdc4ff397a8578cb34a1b60
- version: 1.0

## Description

This indicator plots a dynamic ATR-based trailing stop starting from a user-defined entry date and price, making it ideal for tracking open positions rather than generating signals on every bar.
How it works:

You set your entry date (year, month, day) and optional entry price. If entry price is left at 0, the closing price of the entry day is used automatically.
On the first day, a custom ATR multiplier is applied to give you a wider initial stop — useful if you expect early volatility after entry.
From day two onwards, the stop trails upward using the standard high - (ATR × multiplier) logic, and never moves down.
If price closes below the trailing stop, plotting stops automatically — cleanly marking the point of invalidation without cluttering the chart with a flatlined stop.

Inputs:

Entry Year / Month / Day — define when your trade started
Entry Price — set to 0 to use the day's close
ATR Period — default 14
ATR Multiplier — applied from day two onwards
First Day Multiplier — wider cushion for the opening bar

Best used on daily charts for swing or position trades where you want a clean, rules-based trailing stop anchored to a specific entry.

## Source Code

````pine
//@version=6
indicator("Simplified ATR Trailing Stop", overlay=true)

// === Inputs ===
entryDateYear = input.int(2023, title="Entry Year", minval=1900, maxval=2100)
entryDateMonth = input.int(1, title="Entry Month", minval=1, maxval=12)
entryDateDay = input.int(1, title="Entry Day", minval=1, maxval=31)
entryPrice = input.float(0, title="Entry Price (Set to 0 for Close of the Day)", minval=0, maxval=5000)
atrLength = input.int(14, title="ATR Period", minval=1)
atrMultiplier = input.float(2.0, title="ATR Multiplier for Stop Loss", minval=0.1)
customValueForFirstDay = input.float(2.0, title="Custom Value for First Day Trailing Stop", minval=0.1, maxval=100)

// === ATR Calculation ===
atrValue = ta.atr(atrLength)

// === Entry Timestamp ===
entryDate = timestamp(entryDateYear, entryDateMonth, entryDateDay, 0, 0)

// === Entry Level ===
var float entryLevel = na
if na(entryLevel) and time >= entryDate
    entryLevel := entryPrice > 0 ? entryPrice : close

// === Start Condition ===
startCalculating = time >= entryDate

// === Trailing Stop Logic ===
initialStop = entryLevel - atrMultiplier * atrValue
var float trailingStop = na
var bool firstDayCalculated = false
var bool stopPlotting = false

if startCalculating and not stopPlotting
    if na(trailingStop[1])
        if not firstDayCalculated
            trailingStop := entryLevel - atrValue * customValueForFirstDay
            firstDayCalculated := true
        else
            trailingStop := initialStop
    else
        trailingStop := math.max(trailingStop[1], high - atrMultiplier * atrValue)

// === Stop plotting if low < yesterday's trailing stop ===
if not na(trailingStop[1]) and low < trailingStop[1]
    stopPlotting := true

// === Plotting ===
plot(startCalculating and not stopPlotting ? trailingStop : na, color=color.red, title="Trailing Stop", linewidth=2)
````

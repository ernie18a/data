# Simple Trend Volume Bot

- url: https://www.tradingview.com/script/3lPkzwSw-Simple-Trend-Volume-Bot/
- type: indicator
- pine_id: PUB;fcff5800436c47c48d2b36d32510350a
- version: 1.0

## Description

Works on volume and trend before it actual happens

## Source Code

````pine
//@version=6
indicator("Simple Trend Volume Bot", overlay=true)

// --- Settings ---
src = close
sensitivity = input.float(1.5, "Sensitivity (Lower = Faster)")
len = input.int(10, "Trend Period")

// --- Volume Logic ---
// Only signal if volume is above the 10-period average
volAvg = ta.sma(volume, 10)
volConfirm = volume > volAvg

// --- Trend Logic ---
atr = ta.atr(len)
var float trailingStop = 0.0

// Calculate the Trend Line (Trailing Stop)
if (src > nz(trailingStop[1], 0) and src[1] > nz(trailingStop[1], 0))
    trailingStop := math.max(nz(trailingStop[1]), src - (sensitivity * atr))
else if (src < nz(trailingStop[1], 0) and src[1] < nz(trailingStop[1], 0))
    trailingStop := math.min(nz(trailingStop[1]), src + (sensitivity * atr))
else
    trailingStop := src > nz(trailingStop[1], 0) ? src - (sensitivity * atr) : src + (sensitivity * atr)

// --- Signal Logic ---
buySignal  = ta.crossover(src, trailingStop) and volConfirm
sellSignal = ta.crossunder(src, trailingStop) and volConfirm

// --- Visuals ---
// Plot the Trend Line
plot(trailingStop, "Trend Line", color=src > trailingStop ? color.green : color.red, linewidth=2)

// Clear Buy/Sell Labels
plotshape(buySignal,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)

// Alerts
alertcondition(buySignal,  "Buy Signal Triggered",  "Trend and Volume turned Bullish")
alertcondition(sellSignal, "Sell Signal Triggered", "Trend and Volume turned Bearish")
````

# Muses afl script

- url: https://www.tradingview.com/script/a2Djxpmb-Muses-afl-script/
- type: indicator
- pine_id: PUB;98b3d2ce2cc54e8d806f53917364bd4b
- version: 1.0

## Description

Clear trends, entries, and exits
High-precision, consistent signals
Filters noise and reduces false signals
Highlights high-probability setups
Accurate long and short signals
Stable across all market conditions
Built for a stronger trading edge

## Source Code

````pine
//@version=6
indicator("L1 Filter Sig", "L1Filter", overlay=true)

// Constants
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645

// Inputs
src = input.source(close, "Source")
atrMult = input.float(1.5, "ATR Mult", minval=0, step=0.1)
mu = input.float(0.6, "μ", minval=0, maxval=1, step=0.1)
showSignals = input.bool(true, "Signals")

// L1 Proximal Filter
float threshold = ta.atr(200) * atrMult
var float z = na
var float v = 0.0

if bar_index == 0
    z := src
else
    float zPrev = z[1]
    float vPrev = v[1]
    float zPred = zPrev + vPrev
    float zTemp = zPred + mu * (src - zPred)
    float diff = zTemp - zPrev
    if math.abs(diff) > threshold
        v := math.sign(diff) * (math.abs(diff) - threshold)
    else
        v := 0.0
    z := zPrev + v

// Trend Logic
var int trend = 0
if z > z[1]
    trend := 1
else if z < z[1]
    trend := -1

upChange = trend == 1 and trend[1] == -1
downChange = trend == -1 and trend[1] == 1

// Signal Strength (we won't use this for simplified Buy/Sell)
absV = math.abs(v)
float signalLevel = na
if absV >= threshold * 4.0
    signalLevel := 4
else if absV >= threshold * 3.0
    signalLevel := 3
else if absV >= threshold * 2.0
    signalLevel := 2
else if absV >= threshold * 1.0
    signalLevel := 1

// UT Bot-like Buy and Sell Signals
buySignal = showSignals and upChange
sellSignal = showSignals and downChange

// Plot Filter (for trend visualization)
zColor = trend == 1 ? BULL_COLOR : BEAR_COLOR
plotZ = plot(z, "Filter", color=zColor, linewidth=3)
plotSrc = plot(src, "Src", color=color.new(zColor, 0))

// Fill between src and filter
fill(plotZ, plotSrc, color=color.new(zColor, 90))

// Plot UT Bot-like Signals (simple arrows)
plotshape(buySignal, title="Buy Signal", location=location.belowbar, color=BULL_COLOR, style=shape.arrowup, size=size.large, text="BUY")
plotshape(sellSignal, title="Sell Signal", location=location.abovebar, color=BEAR_COLOR, style=shape.arrowdown, size=size.large, text="SELL")

// Alerts (for UT Bot-like Buy/Sell signals)
alertcondition(buySignal, title="Buy Alert", message="L1 Filter BUY Signal!")
alertcondition(sellSignal, title="Sell Alert", message="L1 Filter SELL Signal!")
````

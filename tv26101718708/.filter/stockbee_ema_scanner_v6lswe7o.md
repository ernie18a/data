# Stockbee + EMA Scanner

- url: https://www.tradingview.com/script/V6lswE7O-Stockbee-EMA-Scanner/
- type: indicator
- pine_id: PUB;234e4b45007b47f2a9289709568e5ce3
- version: 1.0

## Description

This scanner gives setups — not trades

Step 1
Run TradingView screener → shortlist stocks
Step 2
Open charts with script applied
Step 3

Only take trades when:

👉 EMA alignment holds
👉 Signal appears (triangle)
👉 Entry = breakout or pullback

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © normanalwyn

//@version=5
indicator("Stockbee + EMA Scanner", overlay=true)

// EMAs
ema21 = ta.ema(close, 21)
ema48 = ta.ema(close, 48)
ema200 = ta.ema(close, 200)

// Conditions
trendAligned = close > ema21 and ema21 > ema48 and ema48 > ema200

momentumBurst = close > open * 1.03 and volume > ta.sma(volume, 50) * 1.5

episodicPivot = close > open * 1.05 and volume > ta.sma(volume, 50) * 2

// Signals
mbSignal = trendAligned and momentumBurst
epSignal = trendAligned and episodicPivot

// Plot signals
plotshape(mbSignal, title="Momentum Burst", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(epSignal, title="Episodic Pivot", location=location.belowbar, color=color.blue, style=shape.triangleup, size=size.small)

// EMA plots
plot(ema21, color=color.yellow)
plot(ema48, color=color.orange)
plot(ema200, color=color.red)

alertcondition(mbSignal, title="Momentum Burst Alert", message="Momentum Burst Detected")
alertcondition(epSignal, title="Episodic Pivot Alert", message="Episodic Pivot Detected")
````

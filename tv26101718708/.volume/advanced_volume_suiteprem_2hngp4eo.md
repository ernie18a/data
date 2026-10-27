# Advanced Volume Suite_Prem

- url: https://www.tradingview.com/script/2hnGp4Eo-Advanced-Volume-Suite-Prem/
- type: indicator
- pine_id: PUB;7c34ee8f36d8448591364f18034c6506
- version: 1.0

## Description

An Advanced Volume Suite typically refers to a robust trading indicator pack on platforms like TradingView. These suites provide institutional-level insights into market momentum, liquidity, and volume dynamics. They help traders visualize trading volume distribution and buying versus selling pressure to inform their strategies.

## Source Code

````pine
//@version=6
indicator("Advanced Volume Suite_Prem", overlay=false, max_labels_count=500)

// Inputs
len = input.int(20, "Smoothing Length")
pulseMult = input.float(1.5, "Market Pulse Multiplier")

// Buy/Sell Volume Approximation
buyVol = close > open ? volume : volume * 0.5
sellVol = close < open ? volume : volume * 0.5

// Volume Delta
delta = buyVol - sellVol

// CVD
var float cvd = 0.0
cvd += delta

// Smoothed Delta
deltaMA = ta.ema(delta, len)

// Market Pulse
avgDelta = ta.sma(math.abs(delta), len)
strongBuy = delta > avgDelta * pulseMult
strongSell = delta < -avgDelta * pulseMult

// Colors
deltaColor =
     strongBuy ? color.yellow :
     strongSell ? color.orange :
     delta > 0 ? color.lime :
     color.red

// Delta Histogram
plot(delta,
     title="Delta Flow",
     style=plot.style_columns,
     color=deltaColor,
     linewidth=2)

// Zero Line
hline(0, "Zero", color=color.gray)

// Smoothed Delta
plot(deltaMA,
     title="Delta EMA",
     color=color.white,
     linewidth=2)

// Buy/Sell Pressure
buyPressure = buyVol / math.max(volume, 1) * 100
sellPressure = sellVol / math.max(volume, 1) * 100

plot(buyPressure,
     title="Buy Pressure %",
     color=color.green)

plot(sellPressure,
     title="Sell Pressure %",
     color=color.red)

// Trade Zone Signals
buySignal =
     ta.crossover(delta, 0) and
     cvd > ta.sma(cvd, len)

sellSignal =
     ta.crossunder(delta, 0) and
     cvd < ta.sma(cvd, len)
````

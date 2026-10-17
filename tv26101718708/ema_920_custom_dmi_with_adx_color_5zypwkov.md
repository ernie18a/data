# EMA 9/20 + Custom DMI with ADX Color

- url: https://www.tradingview.com/script/5zypwKov-EMA-9-20-Custom-DMI-with-ADX-Color/
- type: indicator
- pine_id: PUB;024657634c124a50b92f15f368e4bacb
- version: 1.0

## Description

This is to make the ADX line change color dynamically depending on whether it’s rising (trend strength increasing) or falling (trend strength weakening).

## Source Code

````pine
//@version=5
indicator("EMA 9/20 + Custom DMI with ADX Color", overlay=true)

// EMA calculations
ema9  = ta.ema(close, 9)
ema20 = ta.ema(close, 20)

// Custom DMI calculations
length = input.int(14, "DMI Length")

upMove   = high - high[1]
downMove = low[1] - low

plusDM   = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM  = (downMove > upMove and downMove > 0) ? downMove : 0.0

tr        = ta.rma(ta.tr, length)
plusDI    = 100 * ta.rma(plusDM, length) / tr
minusDI   = 100 * ta.rma(minusDM, length) / tr
adx       = ta.rma(math.abs(plusDI - minusDI) / (plusDI + minusDI) * 100, length)

// Conditions
bullishEntry = ta.crossover(ema9, ema20) and plusDI > minusDI and adx > 25
bearishEntry = ta.crossunder(ema9, ema20) and minusDI > plusDI and adx > 25

// Plot EMAs
plot(ema9,  color=color.green, title="EMA 9")
plot(ema20, color=color.red,   title="EMA 20")

// Plot signals
plotshape(bullishEntry, title="Bullish Signal", style=shape.triangleup,
          location=location.belowbar, color=color.green, size=size.tiny, text="BUY")

plotshape(bearishEntry, title="Bearish Signal", style=shape.triangledown,
          location=location.abovebar, color=color.red, size=size.tiny, text="SELL")

// Alerts
alertcondition(bullishEntry, title="Bullish Entry Alert",
               message="EMA 9/20 crossover + Custom DMI bullish + ADX strong → CALL setup")

alertcondition(bearishEntry, title="Bearish Entry Alert",
               message="EMA 9/20 crossover + Custom DMI bearish + ADX strong → PUT setup")

// 🔎 ADX color logic
adxColor = adx > adx[1] ? color.green : color.red
plot(adx, title="ADX", color=adxColor)
````

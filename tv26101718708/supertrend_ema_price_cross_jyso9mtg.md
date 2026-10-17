# SuperTrend + EMA Price Cross

- url: https://www.tradingview.com/script/JySO9mtG-SuperTrend-EMA-Price-Cross/
- type: indicator
- pine_id: PUB;bf574d83c8924b3dbe5e9717b47bd59c
- version: 1.0

## Description

SuperTrend + EMA Price Cross. Adjust the supertrend and EMA as per your requirements

## Source Code

````pine
//@version=5
indicator("SuperTrend + EMA Price Cross", overlay=true)

// Inputs
factor    = input.float(3.0, "SuperTrend Factor", minval=0.1, step=0.1)
atrLength = input.int(10, "ATR Length", minval=1)
emaLength = input.int(200, "EMA Length", minval=1)

// Calculations
[supertrend, direction] = ta.supertrend(factor, atrLength)
emaValue = ta.ema(close, emaLength)

// Trend conditions
stBull = direction < 0
stBear = direction > 0

// Price crossing EMA
priceCrossUp   = ta.crossover(close, emaValue)
priceCrossDown = ta.crossunder(close, emaValue)

// Final signals
buySignal  = stBull and priceCrossUp
sellSignal = stBear and priceCrossDown

// Plots
plot(supertrend, "SuperTrend", color=stBull ? color.green : color.red, linewidth=2)
plot(emaValue, "EMA", color=color.orange, linewidth=2)

// Signal markers
plotshape(buySignal, title="BUY", location=location.belowbar, style=shape.labelup, text="BUY", color=color.green, textcolor=color.white, size=size.small)
plotshape(sellSignal, title="SELL", location=location.abovebar, style=shape.labeldown, text="SELL", color=color.red, textcolor=color.white, size=size.small)

// Alerts
alertcondition(buySignal, title="Buy Alert", message="BUY: Price crossed above EMA and SuperTrend is bullish on {{ticker}}")
alertcondition(sellSignal, title="Sell Alert", message="SELL: Price crossed below EMA and SuperTrend is bearish on {{ticker}}")
````

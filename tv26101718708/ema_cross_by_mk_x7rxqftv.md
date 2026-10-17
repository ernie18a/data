# EMA Cross by MK

- url: https://www.tradingview.com/script/X7RXqFTV-EMA-Cross-by-MK/
- type: indicator
- pine_id: PUB;ee02dfeb467041cfaf7c7cbba89e6e4d
- version: 1.0

## Description

EMA Crossover by Manojkumar tamil indicator with symbol

Buy/Sell signals on crossover
Visual markers (crosses)
Colored lines (green + yellow)

## Source Code

````pine
//@version=5
indicator("EMA Cross by MK", overlay=true)

// Inputs
shortLength = input.int(5, title="Short EMA")
longLength  = input.int(20, title="Long EMA")

// EMA Calculations
shortEMA = ta.ema(close, shortLength)
longEMA  = ta.ema(close, longLength)

// Plot EMAs
plot(shortEMA, color=color.green, linewidth=2, title="Short EMA")
plot(longEMA, color=color.yellow, linewidth=2, title="Long EMA")

// Cross Conditions
bullishCross = ta.crossover(shortEMA, longEMA)
bearishCross = ta.crossunder(shortEMA, longEMA)

// Plot Signals (like your crosses)
plotshape(bullishCross, title="Buy Signal", location=location.belowbar, 
     color=color.white, style=shape.cross, size=size.small)

plotshape(bearishCross, title="Sell Signal", location=location.abovebar, 
     color=color.white, style=shape.cross, size=size.small)

// Alerts
alertcondition(bullishCross, title="Buy Alert", message="EMA Bullish Crossover")
alertcondition(bearishCross, title="Sell Alert", message="EMA Bearish Crossover")
````

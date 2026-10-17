# MA Zone Fill

- url: https://www.tradingview.com/script/AUJNsM6o-MA-Zone-Fill/
- type: indicator
- pine_id: PUB;31c8c501d14a44e3beffa3ed0e1660b1
- version: 1.0

## Description

Custom Moving Average Zone Fill indicator for TradingView.
This script allows traders to visualize trend direction by coloring the area between two moving averages.

Features:

* Choose between EMA or SMA calculation
* Fully customizable fast and slow MA lengths
* Dynamic colored fill between the averages:

  * Green when the fast MA is above the slow MA
  * Red when the fast MA is below the slow MA
* Adjustable fill transparency
* Designed for clean trend visualization and momentum analysis

Useful for:

* Trend-following strategies
* EMA/SMA crossover systems
* Momentum confirmation
* Market structure visualization

Works on all timeframes and assets.

## Source Code

````pine
//@version=5
indicator("MA Zone Fill", overlay=true)

// Inputs
maType = input.string("EMA", "סוג ממוצע", options=["EMA", "SMA"])

fastLength = input.int(13, "אורך ממוצע מהיר", minval=1)
slowLength = input.int(48, "אורך ממוצע איטי", minval=1)

fillTransparency = input.int(80, "שקיפות הצביעה", minval=0, maxval=100)

// Function
ma(source, length) =>
    maType == "EMA" ? ta.ema(source, length) : ta.sma(source, length)

// Calculations
fastMA = ma(close, fastLength)
slowMA = ma(close, slowLength)

// Plots
p1 = plot(fastMA, color=color.green, linewidth=2, title="Fast MA")
p2 = plot(slowMA, color=color.red, linewidth=2, title="Slow MA")

// Fill
fillColor = fastMA > slowMA ? color.new(color.green, fillTransparency) : color.new(color.red, fillTransparency)
fill(p1, p2, color=fillColor)
````

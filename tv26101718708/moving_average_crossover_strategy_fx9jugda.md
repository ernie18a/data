# Moving Average Crossover Strategy

- url: https://www.tradingview.com/script/FX9JugDa-Moving-Average-Crossover-Strategy/
- type: strategy
- pine_id: PUB;567f1262dc55424c99f7a8bcdcc90e6e
- version: 1.0

## Description

moving average crossover startegy 10*30
 it indicates when to buy or sell

## Source Code

````pine
//@version=5
strategy("Moving Average Crossover Strategy", overlay=true)

// Define the lengths for the fast and slow moving averages
fastLength = input(10, title="Fast Moving Average Length")
slowLength = input(30, title="Slow Moving Average Length")

// Calculate the moving averages
fastMA = ta.sma(close, fastLength)
slowMA = ta.sma(close, slowLength)

// Determine the crossover conditions
bullishCrossover = ta.crossover(fastMA, slowMA)
bearishCrossover = ta.crossunder(fastMA, slowMA)

// Execute a long trade when a bullish crossover occurs
if bullishCrossover
    strategy.entry("Buy", strategy.long)

// Execute a short trade when a bearish crossover occurs
if bearishCrossover
    strategy.entry("Sell", strategy.short)

// Plot the moving averages on the chart
plot(fastMA, color=color.blue, title="Fast MA")
plot(slowMA, color=color.red, title="Slow MA")
````

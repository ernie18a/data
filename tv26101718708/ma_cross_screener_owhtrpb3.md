# MA Cross Screener

- url: https://www.tradingview.com/script/OwHtRpb3-MA-Cross-Screener/
- type: indicator
- pine_id: PUB;a5085ec807c44851940f96eb5316932a
- version: 1.0

## Description

Tests whether MA cross event took place
Such event can signal a new move of a ticker

## Source Code

````pine
//@version=5
indicator("MA Cross Screener", overlay=true)

// Inputs
fastLen = input.int(20, "Fast MA Length")
slowLen = input.int(50, "Slow MA Length")

// MAs
fastMA = ta.sma(close, fastLen)
slowMA = ta.sma(close, slowLen)

// Cross conditions
bullCross = ta.crossover(fastMA, slowMA)   // fast crosses ABOVE slow
bearCross = ta.crossunder(fastMA, slowMA)  // fast crosses BELOW slow

// Plots - these become your filter columns in Pine Screener
plot(bullCross ? 1 : 0, "Bull Cross", color=color.green)
plot(bearCross ? 1 : 0, "Bear Cross", color=color.red)
````

# Anshul Navy Indicator

- url: https://www.tradingview.com/script/5na7Ffpt-Anshul-Navy-Indicator/
- type: indicator
- pine_id: PUB;26e74cf1fde8483a8475c640533a1f37
- version: 1.0

## Description

Combination of EMAs 21,55 and 100
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)
ema100 = ta.ema(close, 100)

## Source Code

````pine
//@version=5
indicator("Navy Ramvat Indicator", overlay=false)

// Calculate EMAs
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)
ema100 = ta.ema(close, 100)

// Condition 1: Price > 21 EMA
c1 = close > ema21 ? 1 : -1

// Condition 2: Price > 55 EMA
c2 = close > ema55 ? 1 : -1

// Condition 3: Price > 100 EMA
c3 = close > ema100 ? 1 : -1

// Condition 4: 21 EMA > 55 EMA
c4 = ema21 > ema55 ? 1 : -1

// Condition 5: 55 EMA > 100 EMA
c5 = ema55 > ema100 ? 1 : -1

// Condition 6: 21 EMA > 100 EMA
c6 = ema21 > ema100 ? 1 : -1

// Calculate total sum
totalSum = c1 + c2 + c3 + c4 + c5 + c6

// Plot the result
plot(totalSum, title="Score", color=color.blue, linewidth=2, style=plot.style_histogram)

// Optional: Plot zero line for reference
plot(0, title="Zero Line", color=color.gray, linewidth=1)
````

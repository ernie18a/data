# SMA Crossover Strategy

- url: https://www.tradingview.com/script/fOV1xSV7-sma-crossover-strategy/
- type: strategy
- pine_id: PUB;a4d3b86acc1944e792b7cbd064511a27
- version: 1.0

## Description

Simple moving average crossover strategy. For testing purposes.

## Source Code

````pine
//@version=5
strategy('SMA Crossover Strategy', overlay=true)

length = 14
smaShort = ta.sma(close, length)
smaLong = ta.sma(close, length * 2)

if ta.crossover(smaShort, smaLong)
    strategy.entry('Buy', strategy.long)

if ta.crossunder(smaShort, smaLong)
    strategy.entry('Sell', strategy.short)

plot(smaShort, color=color.new(color.red, 0))
plot(smaLong, color=color.new(color.blue, 0))
````

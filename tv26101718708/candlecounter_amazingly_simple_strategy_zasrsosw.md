# CandleCounter - Amazingly simple strategy

- url: https://www.tradingview.com/script/ZAsrsosw-CandleCounter-Amazingly-simple-strategy/
- type: strategy
- pine_id: PUB;u417tRrGSoH91lycimT0RQZZf2e11bvY
- version: 1.0

## Description

This might sound like a crazy idea, but actually seems to work, on all time scales nonetheless!

## Source Code

````pine
//@version=3
strategy("CandleCounter by origo", overlay=true)

// determine candle direction
candle_dir = round((close-open)*2)/2

// sell if previous 2 candles were green and this is red
shortCondition = (candle_dir[2] >= 0 and candle_dir[1] >= 0 and candle_dir < 0)
// buy if previous 3 candles was red, and this candle was green
longCondition = (candle_dir[3] < 0 and candle_dir[2] < 0 and candle_dir[1] < 0 and candle_dir > 0)

if (longCondition)
    strategy.entry("buy", strategy.long)

if (shortCondition)
    strategy.entry("sell", strategy.short, when = strategy.openprofit > 100)
````

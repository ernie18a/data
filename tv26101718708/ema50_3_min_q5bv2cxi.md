# EMA50 3 min

- url: https://www.tradingview.com/script/Q5bv2Cxi-EMA50-3-min/
- type: strategy
- pine_id: PUB;MmxFOxf3Em9zmhBX8Bxb0mH4QUxlCMER
- version: 1.0

## Description

simple strategy with 3 min candles and 76% profitable orders
major pairs recommended

## Source Code

````pine
//@version=3
strategy("My Strategy", overlay=true)

em = ema(close, 50)
op = open
cl = close

if (em-op>0 and cl-em>0)
    //strategy.entry("entry short", strategy.short, comment="Buy")
    strategy.order("buy", strategy.short, 100)

if (em-op<0 and cl-em<0)
    //strategy.entry("entry long", strategy.long, comment="Sell")
    strategy.order("sell", strategy.long, 100)
````

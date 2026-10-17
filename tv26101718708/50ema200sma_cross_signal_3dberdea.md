# 50EMA/200SMA Cross Signal

- url: https://www.tradingview.com/script/3DBeRDea-50EMA-200SMA-Cross-Signal/
- type: strategy
- pine_id: PUB;lVhddPQ9NCAjTI4QaGRIwtWNVrHEM9Ih
- version: 1.0

## Description

Simple 50ema cross over/under 200sma to signal buy/sell, works better on Daily charts

## Source Code

````pine
//@version=2
strategy("MovingAvg2Line Cross", overlay=true)
fastLength = input(200)
slowLength = input(50)
price = close

mafast = sma(price, fastLength)
maslow = ema(price, slowLength)

if (crossover(maslow, mafast))
    strategy.entry("MA2CrossLE", strategy.long, comment="Buy")

if (crossunder(maslow, mafast))
    strategy.entry("MA2CrossSE", strategy.short, comment="Sell")

//plot(strategy.equity, title="equity", color=red, linewidth=3, style=line)
````

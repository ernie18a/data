# MACD Strategy

- url: https://www.tradingview.com/script/CGaLnLrr/
- type: strategy
- pine_id: PUB;ikjSbWxCWwoHQJkrFCQ4vWj6VtnboZWg
- version: 1.0

## Description

MACD 穿0策略

## Source Code

````pine
//@version=3
strategy("MACD Strategy", overlay=true)

fastLength = input(12)
slowlength = input(26)
MACDLength = input(9)

MACD = ema(close, fastLength) - ema(close, slowlength)
aMACD = ema(MACD, MACDLength)
delta = MACD - aMACD

if (crossover(delta, 0))
    strategy.entry("MacdLE", strategy.long, comment="buy")

if (crossunder(delta, 0))
    strategy.entry("MacdSE", strategy.short, comment="sell")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````

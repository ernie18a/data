# Simple MACD Strategy - Crossover

- url: https://www.tradingview.com/script/suTQGcYl-Simple-MACD-Strategy-Crossover/
- type: strategy
- pine_id: PUB;GB4qVGrLkqNw58zgev3GDRSdFRT0eW3V
- version: 1.0

## Description

Simple MACD  Crossover Strategy

No secret sauce here!

Script was requested by user

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
    strategy.entry("MacdLE", strategy.long, comment="MacdLE")

if (crossunder(delta, 0))
    strategy.entry("MacdSE", strategy.short, comment="MacdSE")

plot(strategy.equity, title="equity",transp=100 , linewidth=2, style=areabr)
````

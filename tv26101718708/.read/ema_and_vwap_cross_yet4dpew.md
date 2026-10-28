# EMA and VWAP CROSS

- url: https://www.tradingview.com/script/Yet4DpeW-EMA-and-VWAP-CROSS/
- type: strategy
- pine_id: PUB;RqAVdcwlfszD89xKL9NYN1QNTuGAG5zN
- version: 4.0

## Description

cut and reverse

## Source Code

````pine
strategy("EMA CROSS", overlay = true)

in1 = input(title="EMA", type=integer, defval=25)

ema1 = ema(close, in1)
ema2 = vwap(close)
plot(vwap(close))
plot(ema1, color=red)
long = ema1 > ema2 
short = ema1 < ema2 

strategy.entry("Long", strategy.long, 1, when=long)
strategy.entry("Short", strategy.short, 1, when=short)

strategy.close("Long", when = short)
strategy.close("Short", when = long)
````

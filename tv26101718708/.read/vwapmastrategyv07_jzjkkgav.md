# vwap-ma-strategy-v0.7

- url: https://www.tradingview.com/script/jZjKKGAV-vwap-ma-strategy-v0-7/
- type: strategy
- pine_id: PUB;qtzMbXPc9dh6QSls6zO73SiJUce5vj3w
- version: 2.0

## Description

This strategy was inspired by my Israeli fellow iAtiya.

I love it because it's my first pine v3 script that actually works.

Powerful with respect to it's simplicity.

## Source Code

````pine
//@version=6
strategy('vwap-ma-strategy-v1', overlay = true)
maSource = input(title = 'sma(source)', defval = close)
maInterval = input.int(title = 'sma(interval)', minval = 0, maxval = 999, step = 1, defval = 7)
ma = ta.sma(maSource, maInterval)
if ta.crossover(ma, ta.vwap)
    strategy.entry('buy', strategy.long)
if ta.crossunder(ma, ta.vwap)
    strategy.close('buy')
plot(strategy.position_size)
````

# Picking Tops And Bottoms

- url: https://www.tradingview.com/script/fV7aS07m-Picking-Tops-And-Bottoms/
- type: strategy
- pine_id: PUB;Xt7kzBVxkkDP8dpMlf7tPnMK46Wtwj4Q
- version: 1.0

## Description

Used to pick the BTC high.

## Source Code

````pine
//@version=3
strategy("Picking Tops And Bottoms", overlay = true)

ma730 = sma(close, 730)
ma350 = sma(close, 350)
ma111 = sma(close, 111)
ma700 = ma350 * 2


entry() => crossover(open, ma730)
exit() => crossunder(ma700, ma111)

strategy.entry(id = "long_ma", long = true, when = entry ())
strategy.close(id = "long_ma", when = exit())

plot(ma700, color = orange, transp=0)
plot(ma111, color = purple, transp=0)
plot(ma730, color = blue, transp=0)
````

# Seitwärtsdoppelpenetration

- url: https://www.tradingview.com/script/95yV2t8V-Seitw%C3%A4rtsdoppelpenetration/
- type: strategy
- pine_id: PUB;XeUZJL1VEcHKWVCvZjIuRYuMdz0HM0b8
- version: 1.0

## Description

Strategy with Keltner Channels and MACD

## Source Code

````pine
//@version=3

strategy("Seitwärtsdoppelpenetration", overlay=false)

//Keltner Channel
source = open

useTrueRange = input(true)
length = input(20, minval=1)
mult = input(4.0)

ma = sma(source, length)
range = useTrueRange ? tr : high - low
rangema = sma(range, length)
upper = ma + rangema * mult
lower = ma - rangema * mult

crossUpper = crossover(source, upper)
crossLower = crossunder(source, lower)

//Entry
buyEntry = cross(lower,source)
sellEntry = cross(upper,source)

if (cross(lower,source))
    strategy.entry("buyEntry", strategy.long, comment="buyEntry")

if (cross(source, upper))
    strategy.entry("sellEntry", strategy.short, comment="sellEntry")

buyExit = cross(source, upper)
sellExit = cross(lower,source)

strategy.close("buyEntry", buyExit)
strategy.close("sellEntry", sellExit)
````

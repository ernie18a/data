# MA PT.1

- url: https://www.tradingview.com/script/o0Jie3fD-MA-PT-1/
- type: strategy
- pine_id: PUB;9uD0yQisfCRj4ELEsFUagg6DWuEvFUVo
- version: 2.0

## Description

Need all 3 :$

## Source Code

````pine
//@version=2
strategy("MA PT.1", overlay=true)
piriod = 720

s8ema = ema(close, 8)
s13ema = ema(close, 13)
s21ema = ema(close, 21)
s50ema = sma(close,50)
s80ema = sma(close,80)
s100ema = ema(close, 100)
s200ema = ema(close, 200)
shortCond = crossunder(s8ema, s21ema)
longCond = crossover(s8ema, s21ema)
plotshape(series=shortCond, title="Short", style=shape.triangledown, location=location.abovebar, color=red, text="Sell Only", size=size.small)
plotshape(series=longCond, title="Long", style=shape.triangleup, location=location.belowbar, color=green, text="Buy Only", size=size.small)

plot(s8ema, title="Ema 8", color=red, linewidth = 2, transp=0)
plot(s21ema, title="Ema 21", color=aqua, linewidth = 2, transp=0)
plot(s13ema, title="Ema 13", color=green, linewidth = 2, transp=0)
plot(s50ema, title="Ema 50", color=black, linewidth = 2, transp=0)
plot(s80ema, title="Ema 80", color=black, linewidth = 2, transp=0)
plot(s100ema, title="Ema 100", color=black, linewidth = 2, transp=0)
plot(s200ema, title="Ema 200", color=black, linewidth = 2, transp=0)
````

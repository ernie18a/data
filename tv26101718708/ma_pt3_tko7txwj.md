# MA Pt.3

- url: https://www.tradingview.com/script/tKo7TxWj-MA-Pt-3/
- type: strategy
- pine_id: PUB;Xwh8JvKqDV2AeeKO1weJWkh3zw3fZoft
- version: 1.0

## Description

[b]Need all 3 :$

## Source Code

````pine
//@version=2
strategy("MA Pt.3", overlay=true)

piriod = 720
s8sma = sma(close, 8)
s21sma = sma(close, 21)
s50ema = ema(close, 50)
s80ema = ema(close, 80)
s200ema = ema(close, 200)
s50sma = sma(close, 50)
shortCond = crossunder(s8sma, s21sma)
longCond = crossover(s21sma, s200ema) 
plotshape(series=shortCond, title="Short", style=shape.triangledown, location=location.abovebar, color=red, text="8/21", size=size.small)
plotshape(series=longCond, title="Long", style=shape.triangleup, location=location.belowbar, color=green, text="LONG", size=size.small)
plot(s8sma, title="Sma 8", color = red, linewidth = 1, transp=0)
plot(s21sma, title="Sma 21", color = aqua, linewidth = 1, transp=0)
plot(s50ema, title="Sma 50", color = green, linewidth = 2, transp=0)
plot(s200ema, title="Ema 200", color = blue, linewidth = 2, transp=0)
plot(s80ema, title="Ema 80", color = white, linewidth = 2, transp=0)
````

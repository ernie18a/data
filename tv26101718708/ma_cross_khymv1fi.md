# MA Cross

- url: https://www.tradingview.com/script/khymv1fi-MA-Cross/
- type: strategy
- pine_id: PUB;wYb33KAEnYIlVWxJ5ArSYSTVWU1Kvfbp
- version: 1.0

## Description

Very simple Strategy just for learning purposes. Uses crossover of SMA3/50

## Source Code

````pine
//Version 1
//Einfacher Crossover
//SwissTrader, http://geo.ch
strategy(title="MA Cross", overlay=true)
short = sma(close, 3)
long = sma(close, 50)
plot(short, color = red)
plot(long, color = green)
plot(cross(short, long) ? short : na, style = cross, linewidth = 4)
longCond=crossover(short,long)
shortCond=crossover(long,short)
strategy.entry("LONG", strategy.long, when=longCond)
strategy.entry("SHORT", strategy.short, when=shortCond)
strategy.exit("EXLONG", from_entry="LONG", when=shortCond)
strategy.exit("EXSHORT", from_entry="SHORT", when=longCond)
````

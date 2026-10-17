# Basic 2EMA CrossOver LongOnly

- url: https://www.tradingview.com/script/KlrlzrDM-Basic-2EMA-CrossOver-LongOnly/
- type: strategy
- pine_id: PUB;XzsvYHud8psUGBRlKZgkzIw67i1DI5H5
- version: 1.0

## Description

Just 2 EMA Crossover 12,26 for study

## Source Code

````pine
//https://www.tradingview.com/study-script-reference/
//@version=2
strategy("My 12, 26Crossover", overlay=true)

X = 12
Y = 26
Fst=ema(close,X)
Slw=ema(close,Y)
// conditions
buyCond = crossover(Fst, Slw)
sellCond = crossover(Slw, Fst)

// entries and base exit
strategy.entry("long", strategy.long, when = buyCond)
//strategy.entry("short", strategy.short, when = sellCond)
strategy.close_all(when = sellCond) 
// not sure needed, but just incase..
strategy.exit("XL", from_entry = "long", when = sellCond)
//strategy.exit("XS", from_entry = "short", when = buyCond)
//plot(strategy.equity)

plotshape(buyCond, style=shape.triangleup, color=teal, size=size.small, location=location.belowbar)
plotshape(sellCond, style=shape.triangledown, color=orange, size=size.small, location=location.abovebar)

plot(Fst, style = line, color = blue, linewidth = 2 )
plot(Slw, style = line, color = red, linewidth = 2)
````

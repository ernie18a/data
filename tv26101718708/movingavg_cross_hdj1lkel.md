# MovingAvg Cross

- url: https://www.tradingview.com/script/HDJ1LKEl-MovingAvg-Cross/
- type: strategy
- pine_id: PUB;3176
- version: -1.0

## Description

MA crosses with love

## Source Code

````pine

//@version=2
strategy("MovingAvg Cross", overlay=true)
length = input(12)
confirmBars = input(9)
price = close

ma = sma(price, length)

bcond = price > ma
bcount = bcond ? nz(bcount[1]) + 1 : 0

if (bcount == confirmBars)
    strategy.entry("MACrossLE", strategy.short, comment="MACrossLE")

scond = price < ma
scount = scond ? nz(scount[1]) + 1 : 0

if (scount == confirmBars)
    strategy.entry("MACrossSE", strategy.long, comment="MACrossSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````

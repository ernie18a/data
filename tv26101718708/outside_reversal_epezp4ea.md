# Outside Reversal

- url: https://www.tradingview.com/script/epeZP4Ea-Outside-Reversal/
- type: strategy
- pine_id: PUB;Fh3mq8x51jejHRvEtClria853FhllV1P
- version: 1.0

## Description

The PivotBoss outside reversal strategy

## Source Code

````pine
//@version=4
strategy("Outside Reversal", overlay=true)

barMultiplier = input(1.25)
barsBack = input(50)

myCandleSize = high-low
averageCandle = rma(myCandleSize, barsBack)

longSignal = low < low[1] and close > high[1] and (myCandleSize >= averageCandle*barMultiplier)
shortSignal = high > high[1] and close < low[1] and (myCandleSize >= averageCandle*barMultiplier)

plotshape(longSignal, title="LONG", style=shape.triangleup)
plotshape(shortSignal, title="SHORT", style=shape.triangledown)

strategy.entry("LONG", strategy.long, when=longSignal)
strategy.entry("SHORT", strategy.short, when=shortSignal)
````

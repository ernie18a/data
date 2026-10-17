# $EURUSD 1 Minute Chart Strategy

- url: https://www.tradingview.com/script/F3leaL3N-EURUSD-1-Minute-Chart-Strategy/
- type: strategy
- pine_id: PUB;2371
- version: -1.0

## Description

You must be using the renko chart with traditional settings with the block size set at .0001. This can be done by going to settings. Style at the bottom should be changed from ATR to traditional. The set the block size as .0001.

## Source Code

````pine
//@version=2
strategy("MovingAvg Cross", overlay=true)
length = input(9)
confirmBars = input(1)
price = close

strategy.exit ("trail_points", loss= 1)

ma = ema(price, length)

bcond = price > ma
bcount = bcond ? nz(bcount[1]) + 1 : 0

if (bcount == confirmBars)
    strategy.entry("MACrossLE", strategy.long, comment="MACrossLE")

scond = price < ma
scount = scond ? nz(scount[1]) + 1 : 0

if (scount == confirmBars)
    strategy.entry("MACrossSE", strategy.short, comment="MACrossSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````

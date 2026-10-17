# 9/21 MovingAvg Cross Signal EGAV.35

- url: https://www.tradingview.com/script/Zhd5017n-9-21-MovingAvg-Cross-Signal-EGAV-35/
- type: strategy
- pine_id: PUB;ovDljkUkJGOOGxIzJ8oXk1IsYPdqyjtR
- version: 1.0

## Description

Simple buy/sell signal with 9 & 21 ema cross over/under, works better in Daily Charts

## Source Code

````pine
//@version=2
strategy("MovingAvg Cross", overlay=true)
length = input(9)
lenght = input(21)
confirmBars = input(5)
price = open

ma = ema(price, length)
bcond = price > ma
bcount = bcond ? nz(bcount[1]) + 1 : 0

if (bcount == confirmBars)
    strategy.entry("MACrossLE", strategy.long, comment="Buy")

scond = price < ma
scount = scond ? nz(scount[1]) + 1 : 0

if (scount == confirmBars)
    strategy.entry("MACrossSE", strategy.short, comment="Short")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````

# WMA89 Cross - Arvind

- url: https://www.tradingview.com/script/rxrlYEw2-WMA89-Cross-Arvind/
- type: strategy
- pine_id: PUB;GkAs89iQifdKJhWwqWsnIleBkfCm9G4v
- version: 1.0

## Description

WMA 89 cross indicator strategy

## Source Code

````pine
//@version=3
strategy("WMA89 Cross", overlay=true)
length = input(89)
confirmBars = input(1)
price = close

ma = wma(price, length)

bcond = price > ma

bcount = 0
bcount := bcond ? nz(bcount[1]) + 1 : 0

if (bcount == confirmBars)
    strategy.entry("MACrossLE", strategy.long, comment="MACrossLE")

scond = price < ma
scount = 0
scount := scond ? nz(scount[1]) + 1 : 0

if (scount == confirmBars)
    strategy.entry("MACrossSE", strategy.short, comment="MACrossSE")

//plot(strategy.equity, title="equity", color=red, linewidth=2, style=areabr)
````

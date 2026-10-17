# USO - Adam Smith - Moving Average Cross Strategy

- url: https://www.tradingview.com/script/CVMrsYjB-USO-Adam-Smith-Moving-Average-Cross-Strategy/
- type: strategy
- pine_id: PUB;PUNk2aPAtKTIoZvsPqs3UyoUwJCLdIW0
- version: 1.0

## Description

Simple Moving Average strategy for USO - United States Oil Fund . This strategy can be used on stocks and currencies but will need to tweak frequency on chart and backtest Max Draw Down to Net Profit ratios for maximum dollar gains.

## Source Code

````pine
//@version=2
strategy("Adam Smith - MovingAvg Cross", overlay=true)
length = input(4)
confirmBars = input(1)
price = close

ma = sma(price, length)

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

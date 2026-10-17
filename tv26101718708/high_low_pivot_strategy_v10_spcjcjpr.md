# High & Low Pivot Strategy v1.0

- url: https://www.tradingview.com/script/spCJCjPR-High-Low-Pivot-Strategy-v1-0/
- type: strategy
- pine_id: PUB;d4Ml4EesUCRdty2ZtwVR9Qfa9MqaCs4q
- version: 1.0

## Description

A system that determines what direction the market is trending by analysing previous high and low pivot points to set up an entry trade.

## Source Code

````pine
//@version=3
strategy("Strategy1.71", overlay=true, initial_capital=5000, currency=currency.GBP, pyramiding=10)

leftBars = input(21, "Pivot Left Window")
rightBars = input(8, "Pivot Right Window")

pHigh = pivothigh(leftBars, rightBars)
pLow = pivotlow(low, leftBars, rightBars)

xb = nz(pHigh - nz(pLow))

bPoint = nz(pHigh - pLow) / 100 * 20 + nz(pHigh, pLow)

bat = nz(pHigh - pLow) / (100 * 50)

cypher = nz(pHigh - pLow) / (100 * 38.2)

Short = nz(pLow < nz(pHigh))

if (Short)
    strategy.entry("long", strategy.short, qty=80000)
    strategy.exit("long", profit = 2500)

plot(pHigh, style=cross, linewidth=3, color = blue, offset=-rightBars, title="Previous High", trackprice = true, join=true)
plot(pLow, style=cross, linewidth=3, color = red, offset=-rightBars, title="Previous Low", trackprice = true, join=true)
````

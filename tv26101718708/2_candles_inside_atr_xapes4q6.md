# 2 Candles Inside ATR

- url: https://www.tradingview.com/script/XapES4Q6-2-Candles-Inside-ATR/
- type: strategy
- pine_id: PUB;ludhVYVE6ZgmdmQGj48j1SImvJARsWB8
- version: 1.0

## Description

2 agitated candles falling inside ATR range, awaiting possibly a big move.
Buy / Sell signals at combined high / low can be used as order with other as stop loss.
Counter trade, when this minimal stop loss is hit, is also as useful. However, wait till the SL candle closes, before opening position on the other side.
Works quite well on 15 mins chart, with settings of ATR duration 25 and multiplier 0.6. These settings are configurable, so feel free.

## Source Code

````pine
//@version=4
strategy("2 Candles Inside ATR", overlay=true)

durATR = input(25, title="ATR duration")
multiplier= input(0.6, title="ATR multiplier")
ATR = sma(rma(tr, durATR), 2)

combinedHigh = max(high, high[1])
combinedLow = min(low, low[1])

longCondition = multiplier * ATR > (combinedHigh - combinedLow) ? combinedHigh : na
shortCondition = multiplier * ATR > (combinedHigh - combinedLow) ? combinedLow : na

plotshape(longCondition, title="Buy Signal", text="Buy above High", textcolor=color.blue, style=shape.arrowup, size=size.small, location=location.belowbar, color=color.blue, transp=0)
plotshape(shortCondition, title="Sell Signal", text="Sell below Low", textcolor=color.red, style=shape.arrowdown, size=size.small, location=location.abovebar, color=color.red, transp=0)
````

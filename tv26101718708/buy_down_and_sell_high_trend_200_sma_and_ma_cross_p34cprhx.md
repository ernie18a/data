# buy down and sell high trend 200 sma and ma cross 

- url: https://www.tradingview.com/script/P34cPRhX-buy-down-and-sell-high-trend-200-sma-and-ma-cross/
- type: strategy
- pine_id: PUB;slfSgPB6Z9qjXjOTdYaGS1iTVX1mMHwW
- version: 1.0

## Description

this indicator showing you when have to buy down and sell high and also can see the market trend is being above or below
I'm sorry if there is an error

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © willi130503

//@version=4
strategy(title = "buy down and sell high trend 200 sma ma cross ")
conditionForBuy = open > high[1]
strategy.entry("long", true, 1, limit = low, when = conditionForBuy) // enter long using limit order at low price of current bar if conditionForBuy is true
strategy.cancel("long", when = not conditionForBuy) // cancel the entry order with name "long" if conditionForBuy is false

short = sma(close, 9)
long = sma(close, 21)
long200 = sma(close, 200) 
plot(short, color = color.red)
plot(long, color = color.green)
plot(long200, color = color.white)

plot(cross(short, long) ? short : na, style = plot.style_cross, linewidth = 4)
````

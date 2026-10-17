# Donchian Strat EXMO

- url: https://www.tradingview.com/script/3rlTqNFH-Donchian-Strat-EXMO/
- type: strategy
- pine_id: PUB;FTSfJAnJpHJQ7UuBoY9QShJOQNO7eaE1
- version: 1.0

## Description

This is simple test of Turtle Trading strategy by Richard Dennis. The script meant to place orders on Donchian Channel borders. It's best to test and use on mid-term charts like 1H and more. 

I've chosen Kraken XBT/USDT chart because this market opened in december 2019. The main problem of crypto trading strategy testing is the bullish market of 2017 year. That enormous growth gives unrealisting expectations to all trend-following strategies tested.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pskoroplas

//@version=4
strategy("Donchian Strat EXMO", overlay=true)

long_per = input(defval = 20, title = "Long Period")
h = highest(high, long_per)
l = lowest(low, long_per)


plot(l)
plot(h)

perc = close/100

if h[1] < h[2]
    strategy.order("BUY", true, stop = h)
    //strategy.exit("BUY", profit = 400)

if l[1] > l[2]
    strategy.order("SELL", false, stop = l)
    //strategy.exit("SELL", profit = 400)
````

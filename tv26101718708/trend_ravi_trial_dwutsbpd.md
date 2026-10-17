# Trend Ravi Trial

- url: https://www.tradingview.com/script/dWutsBPd-Trend-Ravi-Trial/
- type: strategy
- pine_id: PUB;62e31d0d95cc47058b042f04ee78d6ed
- version: 2.0

## Description

Trial for trend analysis
it was not difficult to convert to look like and work like Trend Trader Karan's Tool, who invested " Lakho Rupaya" and works on the basis of price action trading also.

Let me tell you guys, this is nothing but an ATR based system which people already traded as Half Trend, Super Trend and various names. Half Trend is no more a copyrighted indicator, which stopped marketing after being exposed, but people are still cheating with such indicators.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abhimanyoo

//@version=4
strategy("test")
if bar_index < 100
    strategy.entry("buy", strategy.long, 10, when=strategy.position_size <= 0)
    strategy.entry("sell", strategy.short, 10, when=strategy.position_size > 0)
plot(strategy.equity)
````

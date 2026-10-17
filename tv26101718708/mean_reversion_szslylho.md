# Mean reversion

- url: https://www.tradingview.com/script/SzsLYlho-Mean-reversion/
- type: strategy
- pine_id: PUB;5feaebcd986f4608b620260e8958d7ac
- version: 1.0

## Description

Simple mean reversion strategy.

Strategy aims to find three bullish or bearish candle pattern which ends with strong move. Position will be open until we get close above previous highs.

Strategy uses also simple moving average to filter short positions.

This strategy works well with QQQ and daily time frame but it seems to do fairly well intraday also.

User can modify moving average length and how strong is the move of the last candle.

This strategy is inspired a strategy by hackertrader. The original idea by QuantpT.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © stormis
// Based on strategy by hackertrader (original idea by QuantpT)

//@version=5
strategy(title="Mean reversion", shorttitle="MeanRev", precision=16 , overlay=true)

moveLimit = input(70)
maLength = input(200)

ma = ta.sma(close, maLength)

downBar = open > close
isThreeDown = downBar and downBar[1] and downBar[2]
isThreeUp = not downBar and not downBar[1] and not downBar[2]
isBigMoveDown = ((open - close) / (0.001 + high - low)) > moveLimit / 100.0
isBigMoveUp = ((close - open) / (0.001 + high - low)) > moveLimit / 100.0

isLongBuy = isThreeDown and isBigMoveDown
isLongExit = close > high[1]

isShortBuy = isThreeUp and isBigMoveUp
isShortExit = close < low[1]

strategy.entry("Entry Long", strategy.long, when=isLongBuy)
strategy.close("Entry Long", when=isLongExit)

strategy.entry("Entry Short", strategy.short, when=close < ma and isShortBuy)
strategy.close("Entry Short", when=isShortExit)

plot(ma, color=color.gray)
````

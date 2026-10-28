# SQV Cross

- url: https://www.tradingview.com/script/m26U0ZYM-SQV-Cross/
- type: strategy
- pine_id: PUB;6bce1a0982364e9eaba87daef561d5f6
- version: 2.0

## Description

This strategy is used to find tickers that do well when SPY and QQQ are up and VIX is down. This uses EMA's on the user defined resolution to define direction of each ticker. Trades are entered upon crossover. EMAs are user defined as well.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tbernache

//@version=4
strategy("SQV Cross", overlay=true, margin_long=100, margin_short=100)

slow = input(5, title="Fast EMA", minval=0, maxval=100)
fast = input(35, title="Slow EMA", minval=0, maxval=500)
//res = input("10", title="Resolution")
res = timeframe.period

spy  = security("SPY", res, close)
spy_fast = ema(spy, fast)
spy_slow = ema(spy, slow)
spy_up = spy_fast > spy_slow and spy_slow > spy_slow[1]

vix  = security("VIX", res, close)
vix_fast = ema(vix, fast)
vix_slow = ema(vix, slow)
vix_down = vix_slow > vix_fast and vix_slow[1] > vix_slow

qqq  = security("QQQ", res, close)
qqq_fast = ema(qqq, fast)
qqq_slow = ema(qqq, slow)
qqq_up = qqq_fast > qqq_slow and qqq_slow > qqq_slow[1]


xUp = spy_up and qqq_up and vix_down
plotchar(xUp, "Long",  "▲", location.bottom, color.lime, size = size.tiny)


if (xUp)
    strategy.entry("long", strategy.long)
    strategy.exit ("Exit Long","long",  trail_points = 10,trail_offset = 50, loss =70)
````

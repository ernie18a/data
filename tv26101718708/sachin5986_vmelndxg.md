# sachin5986

- url: https://www.tradingview.com/script/VmeLNdxg-sachin5986/
- type: strategy
- pine_id: PUB;307e82efa4ec4f4cbb8de8f7210b3b5b
- version: 2.0

## Description

using EMA 3 and 21 moving average and showing buy and sell signal to on chart with selected time frame

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mohitesachin78

//@version=4
strategy("sachin5986")
ema3 = ema(close,3)
ema21 = ema(close,21)
long = ema3>ema21
short = ema3<ema21
start = timestamp(2022,19,7,0)
end = timestamp(2022,12,12,0)
strategy.entry("buy",strategy.long,when = long)
strategy.close("buy",when = short)
plot(close)
````

# Donchian Moving Average System

- url: https://www.tradingview.com/script/zcwztQsU/
- type: strategy
- pine_id: PUB;lnGFyFyE9fPzWXyDSKDsXrXqBVeQk8wD
- version: 1.0

## Description

Donchian Moving Average System

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dongyun

//@version=4
strategy("唐齐安移动平均交易系统", overlay=true)

longperiod = input(20,'长线')
shortperiod = input(5,'短线')
bandfactor = input(1.0,'')

TrueHigh = 0.0
TrueLow = 0.0
TrueRange = 0.0

TrueHigh := close[1] > high ? close[1] : high
TrueLow := close[1] < low ? close[1] : low
TrueRange := TrueHigh - TrueLow
AvgTrueRange = sma(TrueRange,longperiod)

MAlong = sma(close,longperiod)
MAshort = sma(close,shortperiod)
band =  AvgTrueRange * bandfactor

if close > MAlong[1] + band[1] and close >  MAshort[1] + band[1]
	strategy.entry("Long", strategy.long, when=strategy.position_size < 1)
else
	if close < MAlong[1] - band[1] and close < MAshort[1] - band[1]
		strategy.entry("Short", strategy.short, when=strategy.position_size > -1)

if close < MAlong[1] - band[1] or close < MAshort[1] - band[1]
	strategy.close("Long", when=strategy.position_size > 0)
else
	if close > MAlong[1] + band[1] or close > MAshort[1] + band[1]
		strategy.close("Short", when=strategy.position_size < 0)
````

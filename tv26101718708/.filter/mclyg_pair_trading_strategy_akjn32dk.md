# MCL-YG Pair Trading Strategy

- url: https://www.tradingview.com/script/AkJn32dK-MCL-YG-Pair-Trading-Strategy/
- type: strategy
- pine_id: PUB;5d994d7ac52f4bcfa6ae6ece0b5d1a36
- version: 1.0

## Description

This strategy uses Bollinger Band breakouts to detect buy and sell signals on a correlated pair of assets.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shark792

//@version=5

// 1. Define strategy settings
strategy(title="MCL-YG Pair Trading Strategy", overlay=true,
     pyramiding=0, initial_capital=10000,
     commission_type=strategy.commission.cash_per_order,
     commission_value=4, slippage=2)

smaLength = input.int(title="SMA Length", defval=20)
stdLength = input.int(title="StdDev Length", defval=20)

ubOffset = input.float(title="Upper Band Offset", defval=1, step=0.5)
lbOffset = input.float(title="Lower Band Offset", defval=1, step=0.5)

usePosSize = input.bool(title="Use Position Sizing?", defval=true)
riskPerc   = input.float(title="Risk %", defval=0.5, step=0.25)


// 2. Calculate strategy values
smaValue = ta.sma(close, smaLength)
stdDev   = ta.stdev(close, stdLength)

upperBand = smaValue + (stdDev * ubOffset)
lowerBand = smaValue - (stdDev * lbOffset)

riskEquity  = (riskPerc / 100) * strategy.equity
atrCurrency = (ta.atr(20) * syminfo.pointvalue)
posSize     = usePosSize ? math.floor(riskEquity / atrCurrency) : 1


// 3. Output strategy data
plot(series=smaValue, title="SMA", color=color.teal)

plot(series=upperBand, title="UB", color=color.green,
     linewidth=2)
plot(series=lowerBand, title="LB", color=color.red,
     linewidth=2)


// 4. Determine long trading conditions
enterLong = ta.crossover(close, upperBand)
exitLong  = ta.crossunder(close, smaValue)


// 5. Code short trading conditions
enterShort = ta.crossunder(close, lowerBand)
exitShort  = ta.crossover(close, smaValue)


// 6. Submit entry orders
if enterLong
    strategy.entry(id="EL", direction=strategy.long, qty=posSize)

if enterShort
    strategy.entry(id="ES", direction=strategy.short, qty=posSize)


// 7. Submit exit orders
strategy.close(id="EL", when=exitLong)
strategy.close(id="ES", when=exitShort)
````

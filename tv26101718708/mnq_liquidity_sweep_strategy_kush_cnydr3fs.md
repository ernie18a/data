# MNQ Liquidity Sweep Strategy ( KUSH )

- url: https://www.tradingview.com/script/cnydr3fS-MNQ-Liquidity-Sweep-Strategy-KUSH/
- type: strategy
- pine_id: PUB;3f4e589c778542db8a7bde3649e957a1
- version: 1.0

## Description

The Liquidity Sweep Strategy is based on the idea that price often moves beyond recent highs or lows to capture stop-loss liquidity before reversing.



The strategy identifies areas where retail traders place stop losses (above equal highs or below equal lows). When price sweeps these levels and shows rejection or confirmation, it enters in the opposite direction of the sweep, targeting the return to the internal range or the next liquidity zone.



It focuses on:

Stop-hunt behavior

Market structure shifts

Risk-to-reward optimization

High-probability reversal setups

## Source Code

````pine
//@version=5
strategy("MNQ Liquidity Sweep Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

lookback = 20

highestHigh = ta.highest(high, lookback)
lowestLow = ta.lowest(low, lookback)

shortCondition = high > highestHigh[1] and close < low[1]
longCondition = low < lowestLow[1] and close > high[1]

strategy.entry("Long", strategy.long, when = longCondition)
strategy.entry("Short", strategy.short, when = shortCondition)
````

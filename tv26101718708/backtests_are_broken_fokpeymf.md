# Backtests Are Broken

- url: https://www.tradingview.com/script/fOKpEymF-Backtests-Are-Broken/
- type: strategy
- pine_id: PUB;691df58944f24a479086c91e6289b5ed
- version: 1.0

## Description

This script demonstrates a fatal flaw with Trading View backtests involving trailing stops.  Trading View assumes the most optimistic case for trailing stops, always giving you the best case high/low of a bar instead of the worst or average case. Within a bar, the price could reverse against your position after the open and trigger your trailing stop for a loss before the price goes in your favor, but Trading View backtests do not consider this and instead always give you the best case returns.  This allows a trivial strategy to appear as though it would perform miracles.

This strategy enters on a random bar and sets a trailing stop triggered one tick better than the current price with 0 trailing distance.  Trading View then generously gives this strategy the difference between the open price and best possible wick as a profit.  The only way this strategy can lose money in simulation is if the price goes straight down after entry and never retraces.  It works on all symbols on all timeframes due to this systematic problem with the Trading View backtester.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copyright ©2022 and_then_it_CRASHED

//@version=5
strategy("Backtest Broken", overlay=true, margin_long=1, margin_short=1)

if strategy.position_size == 0 and math.random(0,100) < 5
    strategy.entry('Long', strategy.long)
    strategy.exit('Close Long', 'Long', trail_price = close+syminfo.mintick, trail_offset = 0)
````

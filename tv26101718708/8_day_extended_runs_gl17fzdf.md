# 8 Day Extended Runs 

- url: https://www.tradingview.com/script/gl17fzdf-8-Day-Extended-Runs/
- type: strategy
- pine_id: PUB;6aac4f84e8bc40728df8f9867825e169
- version: 1.0

## Description

Inspired by Linda Bradford Raschke.

Strategy suited to the US T-note (ZN1!) with a t-test of 4.06.

The 5 day SMA is vital to Linda’s trend identification system. She’s done extensive testing and research using this indicator and has built models based on it. Linda used the 5 day SMA to determine that large outlier price moves happen in the direction of the trend in each market about 9-10 times per year. The powerful part about that number is that when the trend does persist, it can go on a long run, making this a trade with a high expected value.

Note: the current exit criteria  is sell 10 days after entry, users should experiment with different stop placements.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Marcuscor

//@version=4

// Inpsired by Linda Bradford Raschke: a strategy  for the T-note futures (ZN1!) that finds 8 day extended runs above/ below the 5sma and buys/ sells the first pullback below/ above the 5sma
// as of 01/10/2021 the t-test score is 4.06

strategy("8DayRun", overlay=true)


SMA = sma(close,5)

TrendUp = close > SMA

TrendDown = close < SMA

//logic to long

TriggerBuy = barssince(close < SMA) > 8

Buy = TriggerBuy[1] and TrendDown

strategy.entry("EL", strategy.long, when = Buy)
strategy.close(id = "EL", when = barssince(Buy) >10)

bgcolor(TriggerBuy ? color.red : na)
bgcolor(Buy ? color.blue : na)

// logic to short 

TriggerSell = barssince(close > SMA) > 8

Sell = TriggerSell[1] and TrendUp

strategy.entry("ES", strategy.short, when = Sell)
strategy.close(id = "ES", when = barssince(Sell) > 10)

bgcolor(TriggerSell ? color.white : na)
bgcolor(Sell ? color.fuchsia : na)
````

# Hi-Lo Channel Strategy

- url: https://www.tradingview.com/script/nGQYrGYv-Hi-Lo-Channel-Strategy/
- type: strategy
- pine_id: PUB;H2fmM4VKYOyf7j2FSFxal2vIPjpdkR5f
- version: 1.0

## Description

Haven't seen a strategy quite like it. Buy when Heikin Ashi candle closes above a moving average that is sourced on highs - Sell when Heikin Ashi candle closes above a moving average that is sourced on lows. Moving average length should be between 5 and 20 ideally.

NOTE: the Heikin Ashi close values are calculated when the box is checkmarked. You do not need to view the chart with Heikin Ashi candles enabled on the chart. The buy and sell points of the strategy do not change whether or not you are viewing Heikin Ashi candles on the chart as long as the Heikin Ashi setting is enabled.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shiner_trading
// shiner.crypto@gmail.com

//@version=4
strategy("Hi-Lo Channel Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, initial_capital=500, default_qty_value=100, currency="USD")

lenh = input(5, "High-Based MA")
lenl = input (5, "Low-Based MA")
ha = input(true, "Use Heikin Ashi OHCL values (on real chart)?")
ha_h = security(heikinashi(syminfo.tickerid), timeframe.period, high)
ha_l = security(heikinashi(syminfo.tickerid), timeframe.period, low)
ha_c = security(heikinashi(syminfo.tickerid), timeframe.period, close)
float mah = na
float mal = na
longCondition = false
shortCondition = false

/// HA is the check mark box in the configuration.
/// IF "Use Heikin Ashi OHCL values?" is true, then the strategy will use the Heikin Ashi close values
// and therefore give the same buy/sell signals regardless of what chart you are viewing.
/// That being said, if "Use Heikin Ashi OHCL values?" is FALSE, yet you are viewing Heikin Ashi candles on your chart,
// then logically you will also get the same buy/sell signals
if ha == true
    mah := sma(ha_h, lenh)
    mal := sma(ha_l, lenl)
    longCondition := ha_c > mah
    shortCondition := ha_c < mal
if ha == false
    mah := sma(high, lenh)
    mal := sma(low, lenl)
    longCondition := close > mah
    shortCondition := close < mal


plot(mah, color=color.green)
plot(mal, color=color.red)

if (longCondition)
    strategy.entry("Buy", 100)
if (shortCondition)
    strategy.close("Buy")
````

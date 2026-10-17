# New intraday high with weak bar

- url: https://www.tradingview.com/script/g5UQYLvI-New-intraday-high-with-weak-bar/
- type: strategy
- pine_id: PUB;7958b326b601478ea19c4f4f08a63b64
- version: 1.0

## Description

Strategy Logic:

The strategy checks if the current bar’s high is the highest high of the last 10 bar and if internal bar strength is less than 0.15.

Position is closed when close is greater than the previous bar’s high.

When a position is open, the script applies a light green background on the chart to signal that you are in a trade.

## Source Code

````pine
//@version=6
strategy("New intraday high", overlay = true, fill_orders_on_standard_ohlc = true, process_orders_on_close = true)
import TradingView/ta/9

if (strategy.position_size == 0 and high == ta.highest(10) and (close-low)/(high-low) < 0.15)
    strategy.entry("L", strategy.long)
if strategy.position_size > 0 and close > high[1]
    strategy.close("L")

bgcolor(strategy.position_size > 0? color.new(color.green, 85):na, force_overlay = true)
````

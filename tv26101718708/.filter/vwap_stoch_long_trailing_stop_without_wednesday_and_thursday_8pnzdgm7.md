# VWAP Stoch Long Trailing Stop without wednesday and thursday

- url: https://www.tradingview.com/script/8PNzDgM7-VWAP-Stoch-Long-Trailing-Stop-without-wednesday-and-thursday/
- type: strategy
- pine_id: PUB;43a5b429a1f74aec8b2e603e685186fe
- version: 1.0

## Description

Simple trading strategy based on VWAP and Stochastic indicators and a 3% trailing stop.

After backtesting, wednesdays and thursdays seemed to be bad entry days so they are blacklisted.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © relevantSnail17572

//@version=4
strategy("VWAP Stoch Long Trailing Stop without wednesday and thursday")

vwapClose = vwap(close)
stochClose = stoch(close, high, low, 10)

vwapLong = close < vwapClose
stochLong = stochClose < 5
goodDay = dayofweek==dayofweek.sunday or dayofweek==dayofweek.monday or dayofweek==dayofweek.tuesday or dayofweek==dayofweek.friday or dayofweek==dayofweek.saturday
startLong = vwapLong and stochLong and goodDay

size = strategy.equity / close

longStopPrice = 0.0

longStopPrice := if (strategy.position_size > 0)
    stopValue = close * (1 - 0.03)
    max(stopValue, longStopPrice[1])
else
    0

strategy.entry("Buy", strategy.long, size, when = startLong and strategy.position_size <= 0)
strategy.exit(id="Buy", stop=longStopPrice)

plot(strategy.equity/close)
````

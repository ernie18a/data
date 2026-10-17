# Trend Reversal Alerts Strategy [Advanced]

- url: https://www.tradingview.com/script/xV4PNGzu-Trend-Reversal-Alerts-Strategy-Advanced/
- type: strategy
- pine_id: PUB;YYN8wuOG0CiELiPMrGkMze6nFKyGeMYR
- version: 3.0

## Description

This is a hourly version of [url=https://www.tradingview.com/script/gTVi7dA8-Trend-Reversal-Alerts-Strategy-lite/]T-R.A.S [lite][/url]

It's better for houry timeframes : 2h, 3h, 4h, 6h, 12h, 1d, 4d ; otherwise use version [lite] for weekly

## Source Code

````pine
//@version=6
strategy(title = 'Trend Reversal Alerts Strategy Advanced by @nocachy', shorttitle = 'T-RAS[ADV]', overlay = false)
delta = input.float(title = 'Delta', minval = 0.01, maxval = 1, step = 0.01, defval = 1)
buyResistance = input.float(title = 'Buy Resistance', minval = 0, maxval = 10, step = 0.01, defval = 0)
sellResistance = input.float(title = 'Sell Resistance', minval = -10, maxval = 10, step = 0.01, defval = 0)
topSource = close > open ? close : open
bottomSource = close < open ? close : open
body = high - low
spirit = topSource - bottomSource
resistance = open > close ? -(body / spirit) : body / spirit
buy_signal = ta.crossover(close[1] * delta, bottomSource[2]) and ta.crossover(close * delta, topSource[1]) and resistance > buyResistance
sell_signal = ta.crossunder(close[1] * (2 - delta), topSource[2]) and ta.crossunder(close * (2 - delta), bottomSource[1]) and resistance < sellResistance
if buy_signal
    strategy.entry('buy', strategy.long)
if sell_signal
    strategy.close('buy')
plot(strategy.position_size)
````

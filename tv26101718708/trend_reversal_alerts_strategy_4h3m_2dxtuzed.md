# Trend Reversal Alerts Strategy [4H/3M]

- url: https://www.tradingview.com/script/2DxTUzED-Trend-Reversal-Alerts-Strategy-4H-3M/
- type: strategy
- pine_id: PUB;YYoXIgjwHL4SJn6Sk9DAudZrqt1DTz23
- version: 2.0

## Description

This is advanced version of [url=https://www.tradingview.com/script/xV4PNGzu-Trend-Reversal-Alerts-Strategy-Advanced/]T-R.A.S[/url] with better logic adapted for 4hour / 3month timeframes

## Source Code

````pine
//@version=6
strategy(title = 'Trend Reversal Alerts Strategy PRO by @nocachy', shorttitle = 'T-RAS-PRO', overlay = false)
delta = input.float(title = 'Delta', minval = 0.01, maxval = 1, step = 0.01, defval = 1)
buyResistance = input.float(title = 'Buy Resistance', minval = 0, maxval = 10, step = 0.01, defval = 0)
sellResistance = input.float(title = 'Sell Resistance', minval = -10, maxval = 10, step = 0.01, defval = 0)
topSource = close > open ? close : open
bottomSource = close < open ? close : open
body = high - low
spirit = topSource - bottomSource
resistance = open > close ? -(body / spirit) : body / spirit
buy_signal = close[1] * delta > close[2] and close * delta > close[1] and resistance > buyResistance
sell_signal = close[1] * (2 - delta) < close[2] and close * (2 - delta) < close[1] and resistance < sellResistance
if buy_signal
    strategy.entry('buy', strategy.long)
if sell_signal
    strategy.close('buy')
plot(strategy.position_size)
````

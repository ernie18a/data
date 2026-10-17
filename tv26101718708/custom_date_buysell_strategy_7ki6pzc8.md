# Custom Date Buy/Sell Strategy

- url: https://www.tradingview.com/script/7Ki6pZc8-Custom-Date-Buy-Sell-Strategy/
- type: strategy
- pine_id: PUB;29b06eb728c746fe9a673649ea3b7872
- version: 1.0

## Description

This strategy allows you to back test longing or shorting during a period of time between two dates.

Make sure you are in the daily time frame while viewing the performance and trade history to ensure you have the most historical data as possible from Trading View.

Finally, due to the way Trading View enters trades at the end of a candle, you must subtract one day from your starting and your end dates.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=4
strategy("Custom Date Buy/Sell", overlay=true, currency=currency.USD, default_qty_value=1.0,initial_capital=30000.00,default_qty_type=strategy.percent_of_equity)


direction = input(defval='Long', options=['Long','Short'], title='Direction')

frommonth = input(defval = 6, minval = 01, maxval = 12, title = "From Month")
fromday = input(defval = 14, minval = 01, maxval = 31, title = "From day")
fromyear = input(defval = 2019, minval = 1900, maxval = 2100, title = "From Year")

tomonth = input(defval = 7, minval = 01, maxval = 12, title = "To Month")
today = input(defval = 15, minval = 01, maxval = 31, title = "To day")
toyear = input(defval = 2021, minval = 1900, maxval = 2100, title = "To Year")

if time == timestamp(fromyear, frommonth, fromday, 00, 00)
    if direction == 'Long'
        strategy.entry("Long", strategy.long)
    else if direction == 'Short'
        strategy.entry("Short", strategy.short)

if time == timestamp(toyear, tomonth, today, 00, 00)
    strategy.close_all()
````

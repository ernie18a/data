# Volty Expan Close Strategy with Backtest Date Range

- url: https://www.tradingview.com/script/PRck7Phi-Volty-Expan-Close-Strategy-with-Backtest-Date-Range/
- type: strategy
- pine_id: PUB;MNSDyLkWpKnGz2MKF9LAdACH8LYQscme
- version: 1.0

## Description

[b]Input Information[/b]

Length	Numeric	5	Number of bars used to determine the average true range.
NumATRs	Numeric	.75	Factor used to calculate a percentage of the average true range, used to

Long and short entry based on a percentage of price movement beyond the average range. 
Profitable and simple strategy..

## Source Code

````pine
//@version=4
strategy("Volty Expan Close Strategy", overlay=true)
length = input(5)
numATRs = input(0.75)

from_day   = input(defval = 1,    title = "From Day",   minval = 1)
from_month = input(defval = 3,    title = "From Month", minval = 1)
from_year  = input(defval = 2018, title = "From Year",  minval = 1970)

to_day     = input(defval = 1,    title = "To Day",     minval = 1)
to_month   = input(defval = 1,    title = "To Month",   minval = 1)
to_year    = input(defval = 2100, title = "To Year",    minval = 1970)

time_cond = (time > timestamp(from_year, from_month, from_day, 00, 00)) and (time < timestamp(to_year, to_month, to_day, 23, 59))

atrs = sma(tr, length)*numATRs

if (time_cond and not na(close[length]))
    strategy.entry("VltClsLE", strategy.long, stop=close+atrs, comment = "VltClsLE")
    strategy.entry("VltClsSE", strategy.short, stop=close-atrs, comment = "VltClsSE")

//plot(strategy.equity, title="equity", color=color.red, linewidth=2, style=plot.style_areabr)
````

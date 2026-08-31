<!-- tradingview-pine-id: PUB;uRXyFtGUi1dNuqSltJvo3792Jn2lwM61 -->
<!-- tradingviewscripts-format: 1 -->
# Backward Number of Bars

Source: https://www.tradingview.com/script/hekXth56-Backward-Number-of-Bars/

## Description

This indicator was written in order to apply bar limit in strategies and it was published as open code so that everyone can use it. When backtesting with stock market api data, we determine how many bars should be, not from which date the data will be drawn. For example, we can draw 1000 bar data from stock exchange and perform the backtest on this data. You can plan your strategy by checking the number of bars you test with the window () == 1 parameter here while checking through Tradingview to check that the test we performed gives correct results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © melihtuna

//@version=4
study("Backward Number of Bars")

BacktestBarCount = input(50)
_MILLISECONDS_IN_MINUTE = 60000
_MILLISECONDS_IN_HOUR = 60 * _MILLISECONDS_IN_MINUTE
_MILLISECONDS_IN_DAY = 24 * _MILLISECONDS_IN_HOUR
_MILLISECONDS_IN_WEEK = 7 * _MILLISECONDS_IN_DAY
_MILLISECONDS_IN_MONTH = 30 * _MILLISECONDS_IN_DAY

x = (timeframe.isdaily) ? _MILLISECONDS_IN_DAY : (timeframe.isweekly) ? _MILLISECONDS_IN_WEEK : (timeframe.ismonthly) ? _MILLISECONDS_IN_MONTH : timeframe.multiplier * _MILLISECONDS_IN_MINUTE
backTestFromDate = BacktestBarCount * x

reqDate = timenow - backTestFromDate
reqYear = year(reqDate)
reqMonth = month(reqDate)
reqDay = dayofmonth(reqDate)
reqHour = hour(reqDate)
reqMinute = minute(reqDate)

start = timestamp(reqYear, reqMonth, reqDay, reqHour, reqMinute)
window() => time >= start ? 1 : 0

plot(window(), color=color.blue)
````

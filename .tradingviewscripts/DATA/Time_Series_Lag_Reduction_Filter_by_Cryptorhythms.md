<!-- tradingview-pine-id: PUB;w61WKHWOgwMtL5dYYa8FmrUYcMoKDPzL -->
<!-- tradingviewscripts-format: 1 -->
# Time Series Lag Reduction Filter by Cryptorhythms

Source: https://www.tradingview.com/script/juMBqtQk-Time-Series-Lag-Reduction-Filter-by-Cryptorhythms/

## Description

Time Series Lag Reduction Filter by Cryptorhythms

Description
A little filter to reduce lag on any time series data.   Here we use an EMA to demonstrate how it works, but you could use it in many different ways/appications.

This method can cause overshoot if you get too aggressive with the "lagReduce" setting.  In this case lower the lagReduce variable.

👍 We hope you enjoyed this indicator and find it useful! We post free crypto analysis, strategies and indicators regularly. This is our 76th script on Tradingview!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © theheirophant
//@version=4
study("Time Series Lag Reduction Filter by Cryptorhythms", overlay=true)

//SETTINGS
lagReduce = input(20.0, title="Lag Reduction", minval=1, maxval=100)
seriesSource = input(close, title="Source", type=input.source)
seriesLength = input(100, title="Example Series Length for EMA")
yes1=input(true, title="Plot Original EMA as well?")

//FILTER
exampleSeries=ema(seriesSource, seriesLength)
lagFilter = exp(lagReduce*log(exampleSeries / exampleSeries[1]))*exampleSeries

//PLOTS
plot(lagFilter, color=color.lime)
plot(yes1? exampleSeries : na, color=color.red)
````

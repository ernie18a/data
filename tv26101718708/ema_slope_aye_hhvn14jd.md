# EMA Slope AyE

- url: https://www.tradingview.com/script/hHVN14jd/
- type: strategy
- pine_id: PUB;b535974ba3a446e4bd4712e9551d757e
- version: 1.0

## Description

We create our own indicator to calculate the slope of a 20 period EMA over the last candle.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fajardoarelys

//@version=4
strategy("EMA Slope AyE", shorttitle = "SLOPE", overlay=false)
EMAPeriod = input(20, title = "EMA Period", type = input.integer)
SlopePeriod = input(1, title = "Slope Period", type = input.integer)

EMA = ema(close, EMAPeriod)
Slope = (EMA - EMA[SlopePeriod]) / SlopePeriod

plot(Slope, color = color.yellow, linewidth = 2)
zero = hline(0, "zero", color=#787B86)
````

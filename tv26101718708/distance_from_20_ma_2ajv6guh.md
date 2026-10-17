# % Distance from 20 MA

- url: https://www.tradingview.com/script/2ajV6guh-Distance-from-20-MA/
- type: indicator
- pine_id: PUB;e83fd71f176d4d0388dea98bd27b7edf
- version: 1.0

## Description

Percentage Distance from 20-Period Moving Average.
Historically, will provide additional context for market tops and market bottoms

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stillness12

//@version=6

indicator("% Distance from 20 MA", overlay=false)

// Inputs
length = 20
ma = ta.sma(close, length)

// % distance
distance_pct = (close - ma) / ma * 100

plot(distance_pct, title="% From 20 MA", color=color.blue, linewidth=2)
hline(0, "MA", color=color.gray)
````

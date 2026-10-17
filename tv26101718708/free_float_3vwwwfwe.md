# Free Float

- url: https://www.tradingview.com/script/3vWWwFWe-Free-Float/
- type: indicator
- pine_id: PUB;0c80f65434ea428fbf444efdb187366f
- version: 1.0

## Description

Displays the chart symbol's free float value in the indicator's status line and Data Window, without drawing a visible plot on the chart.

The script uses `syminfo.shares_outstanding_float`, which provides the number of floating shares outstanding for the current symbol when TradingView has such data available. Because this value is symbol-level data rather than bar-level price data, it should generally remain constant across the chart's bars and across timeframes (within the same reporting period).

[image]https://www.tradingview.com/x/UeOtMKZ9/[/image]

https://www.tradingview.com/x/itMQnHXR/

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// © jasellewis - Jasel Trading
//
// Free Float
//
// Displays the chart symbol's free float value in the indicator's status line and Data Window,
// without drawing a visible plot on the chart.
//
// This script uses `syminfo.shares_outstanding_float`, which provides the number of floating shares
// outstanding for the current symbol when TradingView has such data available. Because this value is
// symbol-level data rather than bar-level price data, it should generally remain constant across the
// chart's bars and across timeframes (within the same reporting period).

//@version=6
indicator(
    "Free Float",
    overlay = true,
    // `format.volume` causes large share counts to be abbreviated using TradingView's volume-style
    // formatting (e.g. 12.34K, 56.78M, or 9.10B)
    format = format.volume,
    // Limit the displayed value to two decimal places
    precision = 2)

float freeFloat = syminfo.shares_outstanding_float

plot(
    freeFloat,
    "Free Float",
    color.yellow,
    // The following allows the free float value to appear next to the indicator name (in the upper-
    // left of the chart) and in the Data Window, while avoiding a visible line plotted on the chart
    display = display.status_line + display.data_window)
````

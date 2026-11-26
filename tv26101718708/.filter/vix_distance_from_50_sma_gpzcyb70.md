# VIX Distance from 50 SMA

- url: https://www.tradingview.com/script/gpzCyB70-VIX-Distance-from-50-SMA/
- type: indicator
- pine_id: PUB;631c28cb88be4cc6bdde5c9375ba6c42
- version: 1.0

## Description

Histograms that shows how far the VIX is below or above the 50-day simple moving average

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Generaltrading

//@version=6
indicator("VIX Distance from 50 SMA", overlay=false)

vix = request.security("VIX", timeframe.period, close)
sma50 = ta.sma(vix, 50)
dist = vix - sma50

plot(dist, title="VIX Distance from SMA50", style=plot.style_histogram, color=dist >= 0 ? color.red : color.green, linewidth=2)
hline(0, "Zero", color=color.gray)
````

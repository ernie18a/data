# SMACD

- url: https://www.tradingview.com/script/haLM746X-SMACD/
- type: indicator
- pine_id: PUB;52a0cc4df37148bfad4035d30cf540e6
- version: 1.0

## Description

SMACD is a normalized MACD-style momentum indicator that compares fast and slow EMAs inside the recent price range. By scaling both EMAs between the highest high and lowest low over a chosen lookback period, the indicator aims to make MACD signals more comparable across different symbols and price levels.

It plots:
SMACD line: the normalized difference between the fast and slow EMAs
Signal line: an EMA smoothing of SMACD
Histogram: the distance between SMACD and the signal line

The histogram uses different colors to highlight whether momentum is strengthening or weakening above or below the zero line. Upper and lower guide bands are included to help spot stronger momentum extremes.

This indicator is useful for:
Momentum analysis
Trend confirmation
Early shift detection
Comparing momentum across different instruments

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LoFiCharts, twitter: @LoFiCharts_, bsky: @LoFiCharts. Hope you like the indicator.

//@version=5
indicator(title='SMACD', shorttitle='SMACD', timeframe='')

// Inputs
fast_length = input(title='Fast Length', defval=12)
slow_length = input(title='Slow Length', defval=26)
signal_length = input.int(title='Signal Smoothing', minval=1, maxval=50, defval=9)
LookBack = input(title='Periods', defval=45)
HH = ta.highest(high, LookBack)
LL = ta.lowest(low, LookBack)
src = input(title='Source', defval=close)

// Calculations
StEMA26 = (ta.ema(src, slow_length) - LL) / (HH - LL)
StEMA12 = (ta.ema(src, fast_length) - LL) / (HH - LL)

StMACD = (StEMA12 - StEMA26) * 100
SigLine = ta.ema(StMACD, signal_length)

hist = StMACD - SigLine

// Plot colors
col_grow_above = #26A69A
col_grow_below = #FFCDD2
col_fall_above = #B2DFDB
col_fall_below = #EF5350
col_macd = #0094ff
col_signal = #ff6a00

// Plotting
plot(hist, title='Histogram', style=plot.style_columns, color=hist >= 0 ? hist[1] < hist ? col_grow_above : col_fall_above : hist[1] < hist ? col_grow_below : col_fall_below, transp=0)
plot(StMACD, title='StMACD', color=color.new(col_macd, 0))
plot(SigLine, title='Signal', color=color.new(col_signal, 0))
h0 = hline(15, 'Upper Band', color=#606060)
h1 = hline(-15, 'Lower Band', color=#606060)
h3 = hline(0, 'Upper Band', color=#606060, linestyle=hline.style_solid)
````

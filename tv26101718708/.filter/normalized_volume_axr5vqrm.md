# Normalized Volume

- url: https://www.tradingview.com/script/aXr5VQrm-Normalized-Volume/
- type: indicator
- pine_id: PUB;3edfe43c2f4b4fbb90d506ad46f3a3ea
- version: 1.0

## Description

[b]Normalized Volume[/b]

[b]Overview[/b]

Normalized Volume expresses the current bar's volume as a percentage of a rolling average, making it straightforward to compare volume intensity across different instruments, timeframes, and market sessions without manually adjusting thresholds.

A raw volume reading of 500,000 contracts is meaningless in isolation. Normalized Volume answers the more useful question: [i]how does this bar's volume compare to what is normal for this instrument right now?[/i] A reading of 100 means the bar printed exactly average volume. A reading of 200 means it printed twice the average. This normalisation makes the same threshold usable across equities, futures, forex, and crypto.

[b]How it works[/b]

The indicator calculates a Running Moving Average (RMA) of volume over a configurable lookback period, then divides the current bar's volume by that average and multiplies by 100 to express the result as a percentage.

[pine]
NormVol = volume / ta.rma(volume, VolLen) * 100
[/pine]

Bars are colour-coded to communicate both volume intensity and price direction at a glance:

[list]
[*]Bright green — volume exceeds the High Volume threshold and the bar closed up (bullish absorption or breakout)
[*]Dark red — volume exceeds the High Volume threshold and the bar closed down (bearish absorption or breakdown)
[*]White — volume is below the High Volume threshold (normal or low activity)
[/list]

[b]Inputs[/b]

[list=1]
[*][b]Volume Period[/b] — lookback length for the RMA baseline. Shorter values (10–20) react quickly but are noisier; longer values (50–100) provide a more stable baseline. Default: 50.
[*][b]High Volume[/b] — the percentage threshold above which a bar is considered high volume. A value of 150 means the bar must carry at least 1.5× average volume to trigger the highlight. Adjust higher (200+) on instruments with frequent volume spikes, or lower (120) on instruments with steadier volume profiles. Default: 150.
[/list]

[b]Usage notes[/b]

[list]
[*]Use elevated normalised readings (above your High Volume threshold) to confirm breakouts, reversals, or supply and demand zone tests. A zone test accompanied by a high-volume bar is more significant than one on thin volume.
[*]The colour distinction between green and red high-volume bars helps quickly identify whether aggressive buyers or sellers were responsible for the spike.
[*]Because the baseline is a rolling RMA, the indicator adapts automatically to regime changes in liquidity — for example, pre-market thin volume will not distort intraday readings.
[*]This indicator does not repaint. The RMA and the volume of any historical bar are fixed once the bar closes.
[/list]

[b]Recommended pairings[/b]

Normalised Volume works well alongside price action tools that benefit from volume confirmation: supply and demand zones, order blocks, VWAP, and breakout strategies. High-volume bars on key structural levels are a useful filter for separating high-probability setups from low-conviction noise.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jabez4jc

//@version=6

indicator('Normalized Volume', overlay = false)
VolLen = input.int(50, title = 'Volume Period', minval = 1)
HiVol = input(150, title = 'High Volume')

NormVol = volume / ta.rma(volume, VolLen) * 100
NormVolUp = NormVol >= HiVol
NormVolDn = NormVol < HiVol
colors = NormVolUp and close > open ? #008000 : NormVolUp and close < open ? color.rgb(131, 15, 15) : NormVolDn ? #ffffff : na

plot(NormVol, linewidth = 1, style = plot.style_columns, color = colors)
````

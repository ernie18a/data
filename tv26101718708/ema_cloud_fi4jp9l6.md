# EMA Cloud

- url: https://www.tradingview.com/script/fI4jp9L6-EMA-Cloud/
- type: indicator
- pine_id: PUB;ec473f61d8f3434d9d7b3ab7420e9886
- version: 1.0

## Description

[b]EMA Cloud — Dynamic Trend Visualization[/b]

This indicator plots a color-coded cloud between two EMAs to give you an instant read on trend direction and momentum.
How it works:

The cloud fills green when the fast EMA is above the slow EMA (bullish bias)
The cloud fills red when the slow EMA crosses above (bearish bias)
The crossover itself signals a potential trend shift

Fully customizable:

Fast and slow EMA periods (default: 9 / 21)
Individual colors for each EMA line
Bull and bear cloud colors

Best used as a trend filter — combine it with a momentum indicator or volume to confirm entries. Works on any timeframe and asset class.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yemilgr

//@version=6
indicator("EMA Cloud", overlay=true)


// ── Inputs ──────────────────────────────────────────────
emaFastLen  = input.int(9,  title="Fast EMA",  minval=1)
emaSlowLen  = input.int(21, title="Slow EMA",   minval=1)

colorFast   = input.color(color.new(color.gray,  30), title="Fast EMA Color")
colorSlow   = input.color(color.new(color.gray, 30), title="Slow EMA Color")
colorBull   = input.color(color.new(color.green,  60), title="Bullish Cloud Color")
colorBear   = input.color(color.new(color.red,    60), title="Bearish Cloud Color")

// ── Cálculo ──────────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// ── Plot ─────────────────────────────────────────────────
pFast = plot(emaFast, title="Fast EMA", color=colorFast, linewidth=1)
pSlow = plot(emaSlow, title="Slow EMA",  color=colorSlow, linewidth=1)

// ── Nube ─────────────────────────────────────────────────
fill(pFast, pSlow,
     color = emaFast > emaSlow ? colorBull : colorBear,
     title = "EMA Cloud")
````

# Adaptive Price Expansion

- url: https://www.tradingview.com/script/u2eKljtJ-Adaptive-Price-Expansion/
- type: indicator
- pine_id: PUB;f21242ca048747769a7fb3ddd94cc304
- version: 1.0

## Description

APEX — Adaptive Price Expansion plots two fully configurable EMAs with a dynamic fill zone that shifts color based on their relationship. Green when the fast EMA is above the slow, red when below, and blue on a cross. Designed as a momentum and trend bias tool — the fill zone expands during strong directional moves and compresses during consolidation, giving a visual read on price expansion and contraction in real time.

Features:
Fully adjustable fast and slow EMA lengths (default 9/21)
Independent source inputs for each EMA
Color-coded fill zone: green (bullish), red (bearish), blue (crossing)
All colors customizable to match your chart setup

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © indykarveli
//@version=5
indicator("APEX — Adaptive Price Expansion", "APEX", overlay=true)

fastLen  = input.int(9,  "Fast EMA Length", minval=1)
slowLen  = input.int(21, "Slow EMA Length", minval=1)
fastSrc  = input.source(close, "Fast EMA Source")
slowSrc  = input.source(close, "Slow EMA Source")
colorFast    = input.color(#F23645,                     "Fast EMA Color")
colorSlow    = input.color(#089981,                     "Slow EMA Color")
colorAbove   = input.color(color.rgb(8, 153, 129, 67),  "Fill Color - Fast Above Slow")
colorBelow   = input.color(color.rgb(242, 54, 69, 67),  "Fill Color - Fast Below Slow")
colorNeutral = input.color(color.rgb(41, 98, 255, 67),  "Fill Color - Crossing")

fastEMA = ta.ema(fastSrc, fastLen)
slowEMA = ta.ema(slowSrc, slowLen)

fillColor = fastEMA > slowEMA ? colorAbove : fastEMA < slowEMA ? colorBelow : colorNeutral

pFast = plot(fastEMA, "Fast EMA", color=colorFast)
pSlow = plot(slowEMA, "Slow EMA", color=colorSlow)
fill(pFast, pSlow, color=fillColor, fillgaps=true)
````

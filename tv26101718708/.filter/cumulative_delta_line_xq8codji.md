# Cumulative Delta Line

- url: https://www.tradingview.com/script/xq8codji-Cumulative-Delta-Line/
- type: indicator
- pine_id: PUB;afc82552243c40a0bc32cda4c679cfb4
- version: 1.0

## Description

"Minimal Cumulative Delta Line"
This script calculates and plots only a single red line showing Cumulative Volume Delta (CVD) — the running total of buying vs selling pressure.
It includes:

A gray dotted center line at zero (to easily see if net inventory is positive or negative).
No candles, no background color, no extra histogram — very clean pane.

In short: A simple red line that tracks accumulated buy/sell pressure over time, resetting daily if enabled.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Scottt8
//@version=5
indicator("Cumulative Delta Line", shorttitle="CVD Line", overlay=false, format=format.volume)

// ── Inputs ─────────────────────────────────────
useBodyWeight     = input.bool(true,  "Use Body-Weighted Delta", group="Settings")
resetOnNewSession = input.bool(true,  "Reset at New Session", group="Settings")

// ── Delta Calculation ──────────────────────────
float buyVol  = na
float sellVol = na

if useBodyWeight
    rangeSize = high - low
    buyVol    := rangeSize > 0 ? volume * (close - low) / rangeSize : volume * 0.5
    sellVol   := volume - buyVol
else
    buyVol    := close >= open ? volume : 0.0
    sellVol   := close <  open ? volume : 0.0

delta = buyVol - sellVol

// ── Cumulative Delta ───────────────────────────
var float cumDelta = 0.0

if resetOnNewSession and ta.change(time("D"))
    cumDelta := 0.0

cumDelta += delta

// ── Plot ───────────────────────────────────────
plot(cumDelta, 
     title="Cumulative Delta", 
     style=plot.style_line, 
     color=color.red, 
     linewidth=2)

// Zero Line (Centre Line)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
//@version=6
plot(close)
````

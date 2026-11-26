# Delta Histogram

- url: https://www.tradingview.com/script/ltrgx3kE-Delta-Histogram/
- type: indicator
- pine_id: PUB;7569de738c8c42288589eaaf25f7f0f7
- version: 1.0

## Description

"Delta Histogram (Buy/Sell Volume Pressure)"

This script estimates buying vs selling pressure on each bar and displays it as a coloured histogram (green = buyers stronger, red = sellers stronger), with an optional smoothing line.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Scottt8
//@version=5
indicator("Delta Histogram", shorttitle="Δ Histogram", overlay=false, format=format.volume)

// ── Inputs ─────────────────────────────────────
showEma       = input.bool(true,  "Show EMA of Delta", group="Settings")
emaLength     = input.int(9,     "EMA Length", minval=1, group="Settings")
useBodyWeight = input.bool(true,  "Use Body-Weighted Delta (recommended)", group="Settings")

// ── Delta Calculation ──────────────────────────
buyVol  = 0.0
sellVol = 0.0

if useBodyWeight
    // Better approximation using candle body and range
    rangeSize = high - low
    buyVol    := rangeSize > 0 ? volume * (close - low) / rangeSize : volume * 0.5
    sellVol   := volume - buyVol
else
    // Simple method based on candle color
    buyVol    := close >= open ? volume : 0.0
    sellVol   := close <  open ? volume : 0.0

delta = buyVol - sellVol

// Optional EMA of delta
deltaEma = ta.ema(delta, emaLength)

// ── Colors ─────────────────────────────────────
deltaColor = delta >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)
emaColor   = color.new(color.orange, 0)

// ── Plots ──────────────────────────────────────
plot(delta,     title="Delta Histogram", style=plot.style_histogram, color=deltaColor, linewidth=3)
plot(showEma ? deltaEma : na, title="Delta EMA", style=plot.style_line, color=emaColor, linewidth=2)

// Zero line
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// Background tint (optional but helpful)
bgcolor(delta > 0 ? color.new(color.green, 92) : color.new(color.red, 92), title="Delta Background")
//@version=6
plot(close)
````

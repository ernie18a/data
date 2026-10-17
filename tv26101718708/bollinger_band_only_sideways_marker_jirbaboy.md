# Bollinger Band Only + Sideways Marker

- url: https://www.tradingview.com/script/JiRbaboy-Bollinger-Band-Only-Sideways-Marker/
- type: indicator
- pine_id: PUB;d973c773a30f4925997f8d1603c6d915
- version: 1.0

## Description

Bollinger Band Only + Sideways Marker

This indicator displays a standard Bollinger Band on the price chart and marks possible sideways/ranging market conditions.

Main features:

* Plots Bollinger Band upper, middle, and lower lines.
* Uses a Squeeze-style sideways detector based on Bollinger Band and Keltner Channel compression.
* When the sideways condition returns true, a yellow triangle is plotted below the candle.
* The sideways condition follows the SQZMOM-style squeeze logic: Bollinger Bands are inside Keltner Channels.

Inputs:

* BB Length: Bollinger Band length used for display.
* BB Standard Deviation: Bollinger Band multiplier used for display.
* SQZ BB Length: Bollinger Band length used for sideways detection.
* SQZ KC Length: Keltner Channel length used for sideways detection.
* SQZ KC MultFactor: Keltner Channel multiplier used for sideways detection.
* Use True Range: Whether to use True Range for Keltner Channel calculation.

How to use:
When yellow triangles appear below candles, the market may be in a sideways/ranging or compressed-volatility state. This can help traders avoid trend-following entries during low-momentum conditions or prepare for a potential breakout after compression.

Note:
This indicator does not provide buy or sell signals. It only marks possible sideways/squeeze conditions. Please combine it with price action, trend filters, support/resistance, and risk management.

## Source Code

````pine
// © richardgong1988 — Bollinger Band Only + Sideways Marker
//@version=6
indicator("Bollinger Band Only + Sideways Marker", overlay = true)

import richardgong1988/HanJinSignals26/6 as S

// ─── Inputs ────────────────────────────────────────────────────────
bbLen = input.int(
     60,
     "BB length",
     minval = 1,
     maxval = 500,
     group = "Bollinger Band"
)

bbMult = input.float(
     2.0,
     "BB standard deviation",
     minval = 0.5,
     maxval = 5.0,
     step = 0.1,
     group = "Bollinger Band"
)

// ─── Sideways Inputs ────────────────────────────────────────────────
sqzBbLen = input.int(60, "SQZ BB Length", minval = 1, group = "Sideways Detection")
sqzBbMult = input.float(2.0, "SQZ BB MultFactor", minval = 0.1, step = 0.1, group = "Sideways Detection")
sqzKcLen = input.int(60, "SQZ KC Length", minval = 1, group = "Sideways Detection")
sqzKcMult = input.float(1.5, "SQZ KC MultFactor", minval = 0.1, step = 0.1, group = "Sideways Detection")
useTrueRange = input.bool(true, "Use True Range", group = "Sideways Detection")

// ─── Bollinger Band ────────────────────────────────────────────────
basis = ta.sma(close, bbLen)
stdv = ta.stdev(close, bbLen)

upperBand = basis + bbMult * stdv
lowerBand = basis - bbMult * stdv

// ─── Sideways Detection ────────────────────────────────────────────
isSideways = S.isSideways(
     sqzBbLen,
     sqzKcLen,
     sqzKcMult,
     useTrueRange
)

// ─── Plots ─────────────────────────────────────────────────────────
plot(upperBand, "Upper Band", color.new(color.gray, 0))
plot(basis, "Middle Band", color.new(color.orange, 0), linewidth = 2)
plot(lowerBand, "Lower Band", color.new(color.gray, 0))

// ─── Sideways Marker ───────────────────────────────────────────────
plotshape(
     isSideways,
     title = "Sideways Triangle",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.yellow, 0),
     size = size.tiny
)
````

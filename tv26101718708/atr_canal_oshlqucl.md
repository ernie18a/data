# ATR Canal

- url: https://www.tradingview.com/script/oSHlqUCl-ATR-Canal/
- type: indicator
- pine_id: PUB;1dc1a695a8f3486cafa18284d95e3612
- version: 1.0

## Description

A clean and customizable ATR Channel indicator for TradingView by @teclaro

This tool plots a moving average basis line with upper and lower bands calculated using Average True Range (ATR). It is designed to help traders visualize volatility envelopes, dynamic support/resistance areas, and possible trend continuation or mean reversion zones.

Features:
- Customizable moving average type: SMA, EMA, RMA, or WMA
- Adjustable ATR length and ATR multiplier
- Editable source input
- Custom colors for the basis line, upper band, lower band, and channel fill
- Adjustable line widths and transparency settings
- Works directly on the price chart with overlay enabled

The ATR Channel can be used to identify expanding or contracting volatility, track price movement around a dynamic mean, and support discretionary analysis across different markets and timeframes.

This script does not repaint and does not generate buy or sell signals. It is intended as a visual volatility tool.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Teclaro

//@version=6
indicator("Canal ATR", overlay = true)

// =====================================================
// Inputs
// =====================================================

groupBase = "Base"
src = input.source(close, "Fuente", group = groupBase)
baseLen = input.int(20, "Media base", minval = 1, group = groupBase)
atrLen = input.int(14, "ATR length", minval = 1, group = groupBase)
atrMult = input.float(2.0, "Multiplicador ATR", minval = 0.1, step = 0.1, group = groupBase)
maType = input.string("EMA", "Tipo de media", options = ["SMA", "EMA", "RMA", "WMA"], group = groupBase)

groupVisual = "Visual"
basisColor = input.color(color.rgb(80, 120, 190), "Color media", group = groupVisual)
upperColor = input.color(color.rgb(80, 120, 190), "Color canal superior", group = groupVisual)
lowerColor = input.color(color.rgb(80, 120, 190), "Color canal inferior", group = groupVisual)
fillColor = input.color(color.rgb(80, 120, 190), "Color fondo canal", group = groupVisual)

basisWidth = input.int(2, "Ancho media", minval = 1, maxval = 5, group = groupVisual)
channelWidth = input.int(1, "Ancho canal", minval = 1, maxval = 5, group = groupVisual)

basisTransp = input.int(0, "Transparencia media", minval = 0, maxval = 100, group = groupVisual)
channelTransp = input.int(25, "Transparencia canal", minval = 0, maxval = 100, group = groupVisual)
fillTransp = input.int(90, "Transparencia fondo", minval = 0, maxval = 100, group = groupVisual)

// =====================================================
// Calculos
// =====================================================

basis = switch maType
    "SMA" => ta.sma(src, baseLen)
    "EMA" => ta.ema(src, baseLen)
    "RMA" => ta.rma(src, baseLen)
    "WMA" => ta.wma(src, baseLen)

atrValue = ta.atr(atrLen)

upperBand = basis + atrValue * atrMult
lowerBand = basis - atrValue * atrMult

// =====================================================
// Plots
// =====================================================

plot(basis, "Media base", color = color.new(basisColor, basisTransp), linewidth = basisWidth)

pUpper = plot(upperBand, "Canal ATR superior", color = color.new(upperColor, channelTransp), linewidth = channelWidth)
pLower = plot(lowerBand, "Canal ATR inferior", color = color.new(lowerColor, channelTransp), linewidth = channelWidth)

fill(pUpper, pLower, color = color.new(fillColor, fillTransp), title = "Fondo canal ATR")
````

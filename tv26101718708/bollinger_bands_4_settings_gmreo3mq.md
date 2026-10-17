# Bollinger Bands 4 Settings

- url: https://www.tradingview.com/script/gMreO3Mq-Bollinger-Bands-4-Settings/
- type: indicator
- pine_id: PUB;b3a02d6a26ac4a6f97c97ab8b25e0286
- version: 1.0

## Description

Indicator Description:  
The Bollinger Bands 4 Settings indicator provides four fully independent Bollinger Band systems on a single chart. It is designed for traders who want to analyze volatility, trend strength, and price extremes across multiple moving‑average lengths simultaneously. Each band set includes its own length, source, and multiplier, allowing complete customization and multi‑layered market analysis.

This tool helps identify overbought/oversold conditions, volatility expansions, squeezes, and dynamic support/resistance zones across short‑, medium‑, and long‑term market structures.

Key Features:

Four separate Bollinger Band configurations

Individual settings for length, source, and deviation multiplier

Clear color‑coded visualization for each band set

Automatic shading between upper and lower bands

Works on all markets and timeframes

Ideal for volatility analysis, trend confirmation, and multi‑TF confluence

How to Use:

Shorter‑length bands react faster and help identify quick volatility shifts

Longer‑length bands show broader market structure and major trend zones

Price touching or breaking upper/lower bands may indicate overextension

Band contraction suggests low volatility; expansion signals potential breakout

Combine multiple band sets to detect alignment or divergence in market sentiment

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rauser

//@version=5
indicator("Bollinger Bands 4 Settings", overlay=true)

// Nastavení pro jednotlivé Bollinger Bands
length1 = input(20, title="Length 1")
src1 = input(close, title="Source 1")
mult1 = input(2.0, title="Multiplier 1")

length2 = input(50, title="Length 2")
src2 = input(close, title="Source 2")
mult2 = input(2.0, title="Multiplier 2")

length3 = input(100, title="Length 3")
src3 = input(close, title="Source 3")
mult3 = input(2.0, title="Multiplier 3")

length4 = input(200, title="Length 4")
src4 = input(close, title="Source 4")
mult4 = input(2.0, title="Multiplier 4")

// Výpočet Bollinger Bands
basis1 = ta.sma(src1, length1)
dev1 = mult1 * ta.stdev(src1, length1)
upper1 = basis1 + dev1
lower1 = basis1 - dev1

basis2 = ta.sma(src2, length2)
dev2 = mult2 * ta.stdev(src2, length2)
upper2 = basis2 + dev2
lower2 = basis2 - dev2

basis3 = ta.sma(src3, length3)
dev3 = mult3 * ta.stdev(src3, length3)
upper3 = basis3 + dev3
lower3 = basis3 - dev3

basis4 = ta.sma(src4, length4)
dev4 = mult4 * ta.stdev(src4, length4)
upper4 = basis4 + dev4
lower4 = basis4 - dev4

// Zobrazení Bollinger Bands na grafu
plot(basis1, title="Basis 1", color=color.blue)
plot(upper1, title="Upper 1", color=color.blue, linewidth=1)
plot(lower1, title="Lower 1", color=color.blue, linewidth=1)

plot(basis2, title="Basis 2", color=color.red)
plot(upper2, title="Upper 2", color=color.red, linewidth=1)
plot(lower2, title="Lower 2", color=color.red, linewidth=1)

plot(basis3, title="Basis 3", color=color.green)
plot(upper3, title="Upper 3", color=color.green, linewidth=1)
plot(lower3, title="Lower 3", color=color.green, linewidth=1)

plot(basis4, title="Basis 4", color=color.orange)
plot(upper4, title="Upper 4", color=color.orange, linewidth=1)
plot(lower4, title="Lower 4", color=color.orange, linewidth=1)

// Vyplnění mezi pásmy
fill(plot(upper1), plot(lower1), color=color.new(color.blue, 90), title="Fill 1")
fill(plot(upper2), plot(lower2), color=color.new(color.red, 90), title="Fill 2")
fill(plot(upper3), plot(lower3), color=color.new(color.green, 90), title="Fill 3")
fill(plot(upper4), plot(lower4), color=color.new(color.orange, 90), title="Fill 4")
````

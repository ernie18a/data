# EQ - HPDR Bands

- url: https://www.tradingview.com/script/oqsi5zH8-EQ-HPDR-Bands/
- type: indicator
- pine_id: PUB;0ed7f0bd800b4d8391262cc6b1749433
- version: 1.0

## Description

HPDR Bands is a volatility-based multi-range envelope indicator designed to measure how far price deviates from its equilibrium (median) using dynamic statistical ranges.

The indicator combines concepts from:

[list]
[*]Standard deviation analysis
[*]Bollinger Bands
[*]Fibonacci ratios
[*]Mean reversion theory
[*]Volatility mapping
[/list]

The result is a layered probability structure around price that helps identify:

[list]
[*]Overextended market conditions
[*]Potential reversal zones
[*]Trend continuation strength
[*]Volatility compression/expansion
[*]Liquidity sweep regions
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © esparaquia38425

//@version=6
indicator("HPDR Bands", overlay=true, max_bars_back=5000)

// ─────────────────────────────
// Inputs
// ─────────────────────────────
priceSource = input.source(close, "Price Source")
samplingLength = input.int(7, "Sampling Length", minval=1)
maxArraySize = input.int(100000, "Max Array Size", minval=100)

projectForward = input.bool(false, "Project Bands Forward")

scaleOn = input.bool(true, "Scale On")
fillOn = input.bool(true, "Fill On")
textOn = input.bool(true, "Text On")

rangeOn = input.bool(true, "Range On")
linefillOn = input.bool(true, "Linefill On")

lineTransparency = input.int(40, "Line Transparency", minval=0, maxval=100)
fillTransparency = input.int(90, "Fill Transparency", minval=0, maxval=100)

range1 = input.float(38.2, "Range 1")
range2 = input.float(50.0, "Range 2")
range3 = input.float(61.8, "Range 3")
range4 = input.float(78.6, "Range 4")
range5 = input.float(88.3, "Range 5")
range6 = input.float(95.0, "Range 6")
range7 = input.float(97.5, "Range 7")
range8 = input.float(100.0, "Range 8")

// ─────────────────────────────
// Colors
// ─────────────────────────────
c1 = color.new(color.blue, lineTransparency)
c2 = color.new(color.aqua, lineTransparency)
c3 = color.new(color.green, lineTransparency)
c4 = color.new(color.lime, lineTransparency)
c5 = color.new(color.yellow, lineTransparency)
c6 = color.new(color.orange, lineTransparency)
c7 = color.new(color.rgb(245, 125, 35), lineTransparency)
c8 = color.new(color.red, lineTransparency)

fillC1 = color.new(color.blue, fillTransparency)
fillC2 = color.new(color.aqua, fillTransparency)
fillC3 = color.new(color.green, fillTransparency)
fillC4 = color.new(color.lime, fillTransparency)
fillC5 = color.new(color.yellow, fillTransparency)
fillC6 = color.new(color.orange, fillTransparency)
fillC7 = color.new(color.rgb(245, 125, 35), fillTransparency)
fillC8 = color.new(color.red, fillTransparency)

// ─────────────────────────────
// HPDR Logic
// ─────────────────────────────
basis = ta.sma(priceSource, samplingLength)
dev = ta.stdev(priceSource, samplingLength)

// Convert percentage bands into deviation multipliers
band(_pct) =>
    basis + dev * (_pct / 100.0)

lowerBand(_pct) =>
    basis - dev * (_pct / 100.0)

upper1 = band(range1)
upper2 = band(range2)
upper3 = band(range3)
upper4 = band(range4)
upper5 = band(range5)
upper6 = band(range6)
upper7 = band(range7)
upper8 = band(range8)

lower1 = lowerBand(range1)
lower2 = lowerBand(range2)
lower3 = lowerBand(range3)
lower4 = lowerBand(range4)
lower5 = lowerBand(range5)
lower6 = lowerBand(range6)
lower7 = lowerBand(range7)
lower8 = lowerBand(range8)

// ─────────────────────────────
// Plot Median
// ─────────────────────────────
plot(rangeOn ? basis : na, "Median", color=color.white, linewidth=2)

// ─────────────────────────────
// Upper Bands
// ─────────────────────────────
u1 = plot(rangeOn ? upper1 : na, "Upper Range 1", color=c1)
u2 = plot(rangeOn ? upper2 : na, "Upper Range 2", color=c2)
u3 = plot(rangeOn ? upper3 : na, "Upper Range 3", color=c3)
u4 = plot(rangeOn ? upper4 : na, "Upper Range 4", color=c4)
u5 = plot(rangeOn ? upper5 : na, "Upper Range 5", color=c5)
u6 = plot(rangeOn ? upper6 : na, "Upper Range 6", color=c6)
u7 = plot(rangeOn ? upper7 : na, "Upper Range 7", color=c7)
u8 = plot(rangeOn ? upper8 : na, "Upper Range 8", color=c8)

// ─────────────────────────────
// Lower Bands
// ─────────────────────────────
l1 = plot(rangeOn ? lower1 : na, "Lower Range 1", color=c1)
l2 = plot(rangeOn ? lower2 : na, "Lower Range 2", color=c2)
l3 = plot(rangeOn ? lower3 : na, "Lower Range 3", color=c3)
l4 = plot(rangeOn ? lower4 : na, "Lower Range 4", color=c4)
l5 = plot(rangeOn ? lower5 : na, "Lower Range 5", color=c5)
l6 = plot(rangeOn ? lower6 : na, "Lower Range 6", color=c6)
l7 = plot(rangeOn ? lower7 : na, "Lower Range 7", color=c7)
l8 = plot(rangeOn ? lower8 : na, "Lower Range 8", color=c8)

// ─────────────────────────────
// Fill Bands
// ─────────────────────────────
fill(u1, l1, color = linefillOn ? fillC1 : na)
fill(u2, l2, color = linefillOn ? fillC2 : na)
fill(u3, l3, color = linefillOn ? fillC3 : na)
fill(u4, l4, color = linefillOn ? fillC4 : na)
fill(u5, l5, color = linefillOn ? fillC5 : na)
fill(u6, l6, color = linefillOn ? fillC6 : na)
fill(u7, l7, color = linefillOn ? fillC7 : na)
fill(u8, l8, color = linefillOn ? fillC8 : na)
````

# Slow 63,3,43 Stochastic ShareScope Approximation

- url: https://www.tradingview.com/script/PjfzJR7e-Slow-63-3-43-Stochastic-ShareScope-Approximation/
- type: indicator
- pine_id: PUB;00bbbd6353af429cb11e8adc45907c0a
- version: 1.0

## Description

This indicator approximates to a Slow 63.3.43 Stochastic indicator in ShareScope.

[b]Important caveat:[/b] because the exact ShareScope calculation engine is not public, this script should be treated as an approximation for visual study, not a guaranteed replication of ShareScope's stochastic indicator.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Slow 63,3,43 Stochastic", shorttitle="Slow Stoch 63,3,43", overlay=false)

//=========================
// Inputs
//=========================
kPeriod = input.int(63, "%K Period", minval=1, group="Stochastic")
dSmooth = input.int(3, "%D Smoothing", minval=1, group="Stochastic")
smooth = input.int(43, "Smooth", minval=1, group="Stochastic")
kColor = input.color(color.new(color.red, 0), "%K Color", group="Stochastic")
dColor = input.color(color.new(color.maroon, 0), "%D Color", group="Stochastic")

obLevel = input.int(75, "Overbought Level", minval=50, maxval=100, group="Levels")
osLevel = input.int(25, "Oversold Level", minval=0, maxval=50, group="Levels")

// Shading Mode Selection
shadingMode = input.bool(true, "Full Zone Shading", group="Shading", tooltip="ON = Shade entire zones above/below levels\nOFF = Shade between stochastic lines and levels")

// Full Zone Shading Colors
obZoneColor = input.color(color.new(color.red, 85), "Overbought Zone Color", group="Shading")
osZoneColor = input.color(color.new(color.green, 85), "Oversold Zone Color", group="Shading")

// Line-to-Level Shading Colors
obLineColor = input.color(color.new(color.red, 70), "Overbought Line Shade", group="Shading")
osLineColor = input.color(color.new(color.green, 70), "Oversold Line Shade", group="Shading")

//=========================
// Calculate Stochastic
//=========================
rawK = ta.stoch(close, high, low, kPeriod)
kValue = ta.sma(rawK, dSmooth)
dValue = ta.sma(kValue, smooth)

//=========================
// Plot
//=========================
k = plot(kValue, title="%K", color=kColor, linewidth=2)
d = plot(dValue, title="%D", color=dColor, linewidth=2)

hline(obLevel, "Overbought", color=color.new(color.red, 50), linestyle=hline.style_solid)
hline(osLevel, "Oversold", color=color.new(color.green, 50), linestyle=hline.style_solid)
hline(50, "Midline", color=color.new(color.gray, 80), linestyle=hline.style_dotted)

//=========================
// Shading Logic
//=========================

// Full Zone Shading - always create, control visibility with color
obUpper = hline(100, display=display.none)
obLower = hline(obLevel, display=display.none)
fill(obLower, obUpper, color=shadingMode ? obZoneColor : na, title="Overbought Zone")

osUpper = hline(osLevel, display=display.none)
osLower = hline(0, display=display.none)
fill(osLower, osUpper, color=shadingMode ? osZoneColor : na, title="Oversold Zone")

// Line-to-Level Shading - always create, control visibility with color
maxKD = math.max(kValue, dValue)
minKD = math.min(kValue, dValue)

obFillTop = maxKD > obLevel ? maxKD : obLevel
obFillBottom = obLevel
obLinePlot = plot(obFillTop, display=display.none, title="OB Top")
obLinePlot2 = plot(obFillBottom, display=display.none, title="OB Bottom")
fill(obLinePlot2, obLinePlot, color=not shadingMode and maxKD > obLevel ? obLineColor : na, title="Overbought Line Fill")

osFillBottom = minKD < osLevel ? minKD : osLevel
osFillTop = osLevel
osLinePlot = plot(osFillBottom, display=display.none, title="OS Bottom")
osLinePlot2 = plot(osFillTop, display=display.none, title="OS Top")
fill(osLinePlot, osLinePlot2, color=not shadingMode and minKD < osLevel ? osLineColor : na, title="Oversold Line Fill")
````

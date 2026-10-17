# Volatility Band Cloud with Overextension Signals

- url: https://www.tradingview.com/script/GfJx9EDv-Volatility-Band-Cloud-with-Overextension-Signals/
- type: indicator
- pine_id: PUB;fca3b6277aeb4a4d8eda576b6f5586e9
- version: 1.0

## Description

Volatility Band Cloud with Overextension Signals is a Bollinger Band-style volatility envelope designed to make price overextension easier to visualize.

The script uses a 100-period simple moving average as the centerline and plots volatility bands based on standard deviation from that average. The outer bands are set at +/- 2.5 standard deviations, while the inner bands are set at +/- 1.0 standard deviations.

The area between the centerline, inner bands, and outer bands is shaded to create a visual volatility cloud. This helps traders quickly see whether price is trading near the middle of its range, pushing into an upper extension zone, or falling into a lower extension zone.

The indicator also includes optional overextension markers:
- Upper Band Tag: price crosses above the upper outer volatility band
- Lower Band Tag: price crosses below the lower outer volatility band

These markers are not intended to be automatic buy or sell signals. They are visual alerts showing when price has moved outside the selected volatility envelope. Traders can use them as potential exhaustion, mean-reversion, or risk-management reference points when combined with trend, volume, support/resistance, and broader market context.

What makes this script useful is the combination of:
- Adjustable volatility band length
- Adjustable inner and outer standard deviation levels
- Multi-zone cloud shading
- Optional overextension markers
- Cleaner visual interpretation of volatility expansion and contraction

This script is published open-source so users can inspect the calculations and adapt the settings to their own process.

## Source Code

````pine
//@version=6
indicator("Volatility Band Cloud with Overextension Signals", shorttitle="VB Cloud Signals", overlay=true)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------
length = input.int(100, "Basis Length", minval=1)
source = input.source(close, "Source")

innerDeviation = input.float(1.0, "Inner Band Deviation", minval=0.1, step=0.1)
outerDeviation = input.float(2.5, "Outer Band Deviation", minval=0.1, step=0.1)

showCenterLine = input.bool(true, "Show Center Line?")
showBandCloud = input.bool(true, "Show Volatility Cloud?")
showMarkers = input.bool(true, "Show Overextension Markers?")

//----------------------------------------------------
// CALCULATIONS
//----------------------------------------------------
basis = ta.sma(source, length)
deviation = ta.stdev(source, length)

upperOuterBand = basis + outerDeviation * deviation
upperInnerBand = basis + innerDeviation * deviation
lowerInnerBand = basis - innerDeviation * deviation
lowerOuterBand = basis - outerDeviation * deviation

//----------------------------------------------------
// OVEREXTENSION CONDITIONS
//----------------------------------------------------
upperBandTag = ta.crossover(source, upperOuterBand)
lowerBandTag = ta.crossunder(source, lowerOuterBand)

//----------------------------------------------------
// PLOTS
//----------------------------------------------------
upperOuterPlot = plot(upperOuterBand, title="Upper Outer Band", color=color.red, linewidth=2)
upperInnerPlot = plot(upperInnerBand, title="Upper Inner Band", color=color.rgb(255, 120, 120), linewidth=1)

centerPlot = plot(showCenterLine ? basis : na, title="Center Line", color=color.blue, linewidth=2)

lowerInnerPlot = plot(lowerInnerBand, title="Lower Inner Band", color=color.rgb(90, 190, 90), linewidth=1)
lowerOuterPlot = plot(lowerOuterBand, title="Lower Outer Band", color=color.lime, linewidth=2)

//----------------------------------------------------
// CLOUD SHADING
//----------------------------------------------------
fill(upperOuterPlot, upperInnerPlot, color=showBandCloud ? color.new(color.red, 88) : na, title="Upper Extension Zone")
fill(upperInnerPlot, centerPlot, color=showBandCloud ? color.new(color.red, 95) : na, title="Upper Neutral Zone")
fill(centerPlot, lowerInnerPlot, color=showBandCloud ? color.new(color.green, 95) : na, title="Lower Neutral Zone")
fill(lowerInnerPlot, lowerOuterPlot, color=showBandCloud ? color.new(color.green, 88) : na, title="Lower Extension Zone")

//----------------------------------------------------
// VISUAL MARKERS
//----------------------------------------------------
plotshape(showMarkers and upperBandTag, title="Upper Band Tag", text="Upper", style=shape.triangledown, location=location.abovebar, color=color.red, textcolor=color.red, size=size.small)

plotshape(showMarkers and lowerBandTag, title="Lower Band Tag", text="Lower", style=shape.triangleup, location=location.belowbar, color=color.green, textcolor=color.green, size=size.small)
````

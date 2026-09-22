<!-- tradingview-pine-id: PUB;6bfa357ed6684e2f904edd6db46a9f29 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Structure & Bands

Source: https://www.tradingview.com/script/YtrMDh8l-VWAP-Structure-Bands/

## Description

VWAP Structure & Bands is a visual tool that helps traders understand price location relative to the Volume Weighted Average Price (VWAP) during each trading session.

VWAP represents the average traded price weighted by volume, providing a reference point for understanding where price is trading relative to the session's volume-weighted mean.

Key Features

Session VWAP
The main VWAP line resets at the beginning of each trading day and tracks the volume-weighted average price throughout the session.

VWAP Bands
The upper and lower bands are calculated using the volume-weighted standard deviation around VWAP. They provide a dynamic view of how far price has moved from the session's volume-weighted mean.

VWAP Crosses
Optional markers highlight when price crosses above or below VWAP, helping identify changes in price location relative to the session's average.

How to Read It

Price above VWAP
Price is trading above the session's volume-weighted average.

Price below VWAP
Price is trading below the session's volume-weighted average.

Price near VWAP
The market is trading close to its volume-weighted mean, which can indicate a period of balance.

Upper or Lower Band
Price reaching the outer bands indicates a larger deviation from VWAP. This does not automatically mean that a reversal will occur.

Important Note

VWAP is a reference tool, not a standalone trading signal. Price can remain above or below VWAP for extended periods, particularly during strong directional markets.

Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial, investment, trading, or other professional advice.

Past market behavior does not guarantee future results. Trading financial markets involves substantial risk. Always conduct your own research and apply appropriate risk management before making trading decisions.

---

## Source Code

````pine
//@version=6
indicator("VWAP Structure & Bands", shorttitle="VWAP Bands", overlay=true)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
src = input.source(hlc3, "Source")
bandMult = input.float(1.0, "Band Multiplier", minval=0.1, step=0.1)

showBands = input.bool(true, "Show VWAP Bands")
showFill  = input.bool(true, "Fill Bands")
showCross = input.bool(true, "Show VWAP Crosses")

//------------------------------------------------------------------------------
// Session VWAP
//------------------------------------------------------------------------------
isNewSession = timeframe.change("D")

var float cumulativePV = na
var float cumulativeVolume = na
var float cumulativePriceSquaredVolume = na

if isNewSession or na(cumulativePV)
    cumulativePV := src * volume
    cumulativeVolume := volume
    cumulativePriceSquaredVolume := src * src * volume
else
    cumulativePV += src * volume
    cumulativeVolume += volume
    cumulativePriceSquaredVolume += src * src * volume

vwap = cumulativePV / cumulativeVolume

//------------------------------------------------------------------------------
// Volume-weighted standard deviation
//------------------------------------------------------------------------------
variance = cumulativePriceSquaredVolume / cumulativeVolume - vwap * vwap
variance := math.max(variance, 0)

stdev = math.sqrt(variance)

//------------------------------------------------------------------------------
// VWAP Bands
//------------------------------------------------------------------------------
upperBand = vwap + stdev * bandMult
lowerBand = vwap - stdev * bandMult

//------------------------------------------------------------------------------
// VWAP Direction
//------------------------------------------------------------------------------
vwapRising = vwap > vwap[1]
vwapFalling = vwap < vwap[1]

//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
vwapPlot = plot(
     vwap,
     title="VWAP",
     linewidth=2)

upperPlot = plot(
     showBands ? upperBand : na,
     title="Upper VWAP Band",
     linewidth=1)

lowerPlot = plot(
     showBands ? lowerBand : na,
     title="Lower VWAP Band",
     linewidth=1)

//------------------------------------------------------------------------------
// Band Fill
//------------------------------------------------------------------------------
fill(
     upperPlot,
     lowerPlot,
     title="VWAP Band",
     color=showFill ? color.new(color.blue, 90) : na)

//------------------------------------------------------------------------------
// VWAP Crosses
//------------------------------------------------------------------------------
bullCross = ta.crossover(close, vwap)
bearCross = ta.crossunder(close, vwap)

plotshape(
     showCross and bullCross,
     title="Bullish VWAP Cross",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     text="VWAP")

plotshape(
     showCross and bearCross,
     title="Bearish VWAP Cross",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     text="VWAP")
````

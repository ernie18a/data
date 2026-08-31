<!-- tradingview-pine-id: PUB;2300094f396049f3bbed9f9a43801b2b -->
<!-- tradingviewscripts-format: 1 -->
# RSI + Bollinger Bands

Source: https://www.tradingview.com/script/mU1bw3Sw-RSI-Bollinger-Bands/

## Description

RSI + Bollinger Bands — RSIBB

RSIBB combines the Relative Strength Index with Bollinger Bands by projecting RSI momentum directly into price space. Instead of displaying RSI in a separate oscillator pane, this indicator places the RSI Flow alongside price and the Bollinger Band structure, allowing momentum, volatility, and price action to be evaluated together on a single chart.

How It Works

The RSI Flow is centered around the Bollinger Band basis:

RSI 50 aligns with the Bollinger Band basis.
The upper RSI threshold, set to 70 by default, aligns with the primary Upper Band.
The lower RSI threshold, set to 30 by default, aligns with the primary Lower Band.
RSI values beyond the selected thresholds extend into the outer momentum and volatility zones.

The yellow RSI Flow line represents projected RSI momentum. The white RSI Flow-Base line applies EMA smoothing to the projected RSI Flow, making momentum shifts and potential crosses easier to identify.

Bollinger Band Settings

The Bollinger Band system includes adjustable:

Length
Source
Basis moving-average type
Standard-deviation multiplier
Extended-band multiplier
Extended-band visibility

Supported basis moving averages include:

SMA
EMA
SMMA/RMA
WMA
VWMA

The optional Extended Bands highlight areas where momentum and price have moved beyond the primary Bollinger Band range.

RSI Settings

The RSI system includes adjustable:

RSI length
RSI source
Upper RSI threshold
Lower RSI threshold
EMA smoothing length

The default thresholds are 70 and 30, but they can be changed to make the projection more or less sensitive.

Interpretation

When the RSI Flow moves above the basis, momentum is positioned on the bullish side of its range. When it moves below the basis, momentum is positioned on the bearish side.

Movement near or beyond the primary bands indicates that RSI has reached or exceeded its selected upper or lower threshold. The extended zones can help identify stronger momentum expansion, volatility extremes, and possible exhaustion areas.

Crosses between the RSI Flow and its smoothed Flow-Base may help visualize changes in momentum direction. These signals should be evaluated alongside market structure, trend, volatility, and other forms of confirmation.

RSIBB does not provide automatic trade entries or guarantee reversals at the bands. It is designed as a visual analysis tool that places RSI momentum and Bollinger Band behavior into one unified price-chart display.

This indicator is intended for informational and educational purposes only and does not constitute financial advice.

---

## Source Code

````pine
// © silence_has_a_color
//@version=6
indicator(shorttitle="rsibb", title="RSI + Bollinger Bands", overlay=true)

//------------------------------------------------------------------------------
// Bollinger Bands
//------------------------------------------------------------------------------

TT_bbLENGTH = "The time period used to calculate the moving average that creates the basis for the Upper and Lower Bands."
TT_MA_TYPE  = "Determines the type of Moving Average applied to the Bollinger Band basis."
TT_bbSOURCE = "Determines what price data from each bar is used in the Bollinger Band calculations."
TT_bbMULT   = "The number of Standard Deviations between the basis and the primary Upper and Lower Bands."

bblength = input.int(
     20,
     "Length",
     minval = 1,
     tooltip = TT_bbLENGTH)

bbmaType = input.string(
     "SMA",
     "Basis MA Type",
     options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"],
     tooltip = TT_MA_TYPE)

bbsrc = input.source(
     close,
     "Source",
     tooltip = TT_bbSOURCE)

bbmult = input.float(
     2.0,
     "StdDev",
     minval = 0.001,
     maxval = 50,
     tooltip = TT_bbMULT)

OBBmult = input.float(
     2.5,
     "Extended StdDev",
     minval = 1,
     maxval = 50,
     step = 0.1,
     tooltip = "The number of Standard Deviations between the basis and the Extended Upper and Lower Bands.")

showoutbands = input.bool(
     true,
     "Use Extended Bands",
     tooltip = "Displays extended momentum and volatility zones outside the primary Bollinger Bands.")

//------------------------------------------------------------------------------
// RSI
//------------------------------------------------------------------------------

rsiLengthInput = input.int(
     14,
     "RSI Length",
     minval = 1,
     maxval = 15000,
     tooltip = "Controls how many candles are used to calculate Relative Strength. Lower values respond faster, while higher values produce smoother momentum.")

rsiSourceInput = input.source(
     close,
     "RSI Source",
     tooltip = "Determines what price data from each bar is used to calculate RSI.")

rsiUpperThreshold = input.float(
     70.0,
     "Upper RSI Threshold",
     minval = 50.1,
     maxval = 100,
     step = 0.5,
     tooltip = "The RSI level mapped to the primary Upper Bollinger Band. The standard overbought level is 70.")

rsiLowerThreshold = input.float(
     30.0,
     "Lower RSI Threshold",
     minval = 0,
     maxval = 49.9,
     step = 0.5,
     tooltip = "The RSI level mapped to the primary Lower Bollinger Band. The standard oversold level is 30.")

rsiEMA = input.int(
     3,
     "EMA Length",
     minval = 1,
     maxval = 4999,
     tooltip = "Applies EMA smoothing to the projected RSI Flow line. Higher values produce a smoother and slower signal line.")

//------------------------------------------------------------------------------
// Moving Average Function
//------------------------------------------------------------------------------

ma(source, length, maType) =>
    switch maType
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)

//------------------------------------------------------------------------------
// Bollinger Band Data
//------------------------------------------------------------------------------

bbbasis = ma(bbsrc, bblength, bbmaType)

stdev = ta.stdev(bbsrc, bblength)

dev = bbmult * stdev
upper = bbbasis + dev
lower = bbbasis - dev

Odev = OBBmult * stdev
Oupper = bbbasis + Odev
Olower = bbbasis - Odev

//------------------------------------------------------------------------------
// Bollinger Band Plotting
//------------------------------------------------------------------------------

plot(
     bbbasis,
     "BB Basis",
     color = #2962FF)

p1 = plot(
     upper,
     "Upper",
     color = #F23645)

p2 = plot(
     lower,
     "Lower",
     color = #039B29)

Op1 = plot(
     showoutbands ? Oupper : na,
     "Outer Upper",
     color = color.rgb(250, 7, 7))

Op2 = plot(
     showoutbands ? Olower : na,
     "Outer Lower",
     color = color.rgb(7, 252, 15))

fill(
     p1,
     p2,
     title = "BB Range Background",
     color = color.rgb(33, 150, 243, 95))

fill(
     Op1,
     p1,
     title = "Outer Upper Background",
     color = showoutbands ? color.rgb(255, 0, 0, 91) : na)

fill(
     Op2,
     p2,
     title = "Outer Lower Background",
     color = showoutbands ? color.rgb(9, 255, 0, 95) : na)

//------------------------------------------------------------------------------
// RSI Data
//------------------------------------------------------------------------------

rsiChange = ta.change(rsiSourceInput)

rsiUp = ta.rma(
     math.max(rsiChange, 0),
     rsiLengthInput)

rsiDown = ta.rma(
     -math.min(rsiChange, 0),
     rsiLengthInput)

rsiValue = rsiDown == 0
     ? 100
     : rsiUp == 0
     ? 0
     : 100 - (100 / (1 + rsiUp / rsiDown))

// RSI is centered around 50.
//
// Above 50:
// The distance from 50 to the Upper RSI Threshold maps to the distance
// between the Bollinger basis and the primary Upper Band.
//
// Below 50:
// The distance from 50 to the Lower RSI Threshold maps to the distance
// between the Bollinger basis and the primary Lower Band.

normalizedRSI = rsiValue >= 50
     ? (rsiValue - 50) / (rsiUpperThreshold - 50)
     : (rsiValue - 50) / (50 - rsiLowerThreshold)

rsiPlotted = bbbasis + normalizedRSI * dev
rsiSmoothed = ta.ema(rsiPlotted, rsiEMA)

//------------------------------------------------------------------------------
// RSI Plotting
//------------------------------------------------------------------------------

plot(
     rsiPlotted,
     "RSI Flow",
     color = color.rgb(247, 224, 16),
     linewidth = 2)

plot(
     rsiSmoothed,
     "RSI Flow-Base",
     color = color.rgb(255, 255, 255),
     linewidth = 2)
````

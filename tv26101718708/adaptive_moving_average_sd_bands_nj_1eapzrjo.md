# Adaptive Moving Average SD Bands [NJ]

- url: https://www.tradingview.com/script/1EAPzrJo-Adaptive-Moving-Average-SD-Bands-NJ/
- type: indicator
- pine_id: PUB;bfa631fe094242f1a093202be9f83aca
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

Adaptive Moving Average SD Bands is a volatility-based, trend-following indicator that builds standard deviation bands around three different moving averages and combines them into a single outer envelope.

RMA, SWMA and LSMA are calculated from the same source. Each moving average receives its own standard deviation bands, and the highest upper band and lowest lower band are used as the final bands.

Since the three moving averages react to price at different speeds, the envelope adapts its width to the distance between them, requiring a stronger move before the active condition changes.
[image]https://www.tradingview.com/x/eDglLdfe/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

MA Source
Selects the price source used for the moving average calculations.

MA Length
Controls how many bars are used to calculate the RMA and LSMA.

SD Length
Controls how many bars are used to calculate the standard deviation.

[b]✧ HOW IT WORKS ✧[/b]

Moving Averages
Indicator calculates three moving averages from selected source:
Wilder's Moving Average (RMA) applies exponential smoothing over MA Length and reacts slowly to new prices.
Symmetrically Weighted Moving Average (SWMA) uses a fixed four-bar window with the highest weights on the two middle bars, so it closely follows recent price.
Least Squares Moving Average (LSMA) fits a linear regression line over MA Length with a fixed offset of 1.

Standard Deviation Bands
Standard deviation of closing price is calculated over SD Length and measures how widely price has recently been dispersed.
Each moving average receives its own pair of bands:
Upper Band = Moving Average + Standard Deviation
Lower Band = Moving Average − Standard Deviation

Outer Envelope
Highest of the three upper bands is used as final upper band. Lowest of the three lower bands is used as final lower band.
When the moving averages spread apart, the envelope widens. When they converge, the envelope narrows toward a single pair of bands.

Signal Logic
A bullish condition is activated when the high of a candle moves above the final upper band.
A bearish condition is activated when the low of a candle moves below the final lower band.
If both happen on the same candle, the bearish condition takes priority.
Active condition remains unchanged until the opposite condition occurs.

[b]✧ VISUALIZATION ✧[/b]

Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

During a bullish condition, lower band is displayed in green.
During a bearish condition, upper band is displayed in red.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

Adaptive Moving Average SD Bands can be used to identify:

Bullish and bearish trend conditions
Volatility-adjusted price breakouts
Dynamic trend support and resistance
Directional market bias
Trend confirmation
Additional confirmation for other technical analysis

Combining a slow, a fast and a regression-based moving average is designed to filter minor price moves that would cross bands built around a single moving average.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Adaptive Moving Average SD Bands [NJ]", "AMASB", overlay = true, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode   = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
maSrc = input.source(close, "MA source", group = g2)
maLen = input.int(25, "MA length", group = g2)
sdLen = input.int(34, "SD length", group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Get MAs
rma  = ta.rma(maSrc, maLen)
swma = ta.swma(maSrc)
lsma = ta.linreg(maSrc, maLen, 1)

// Get SD
sd = ta.stdev(close, sdLen)

// Get bands
bands(ma) =>
    upperBand = ma + sd
    lowerBand = ma - sd
    [upperBand, lowerBand]

[upperRma, lowerRma]   = bands(rma)
[upperSwma, lowerSwma] = bands(swma)
[upperLsma, lowerLsma] = bands(lsma)

// Find the bands that are farthest from the price
upperBand = math.max(upperRma, upperSwma, upperLsma)
lowerBand = math.min(lowerRma, lowerSwma, lowerLsma)

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if high > upperBand
    NJ := 1
if low < lowerBand
    NJ := -1

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Colors
longCol  = colorMode == "Colored" ? color.rgb(0, 136, 100) : colorMode == "Neutral" ? color.rgb(179, 179, 179) : na
shortCol = colorMode == "Colored" ? color.rgb(120, 0, 32) : colorMode == "Neutral" ? color.rgb(60, 60, 60) : na
sigCol = NJ == 1 ? longCol : NJ == -1 ? shortCol : na

// Color candles
plotcandle(
     open, high, low, close,
     "Colored candles", 
     dispCandles ? sigCol : na,
     dispCandles ? sigCol : na,
     bordercolor = dispCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale)

// Display bands
plot(NJ == -1 ? upperBand : na, "Upper band", shortCol, 2, plot.style_linebr)
plot(NJ == 1  ? lowerBand : na, "Lower band", longCol, 2, plot.style_linebr)
````

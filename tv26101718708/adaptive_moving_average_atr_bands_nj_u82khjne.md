# Adaptive Moving Average ATR Bands [NJ]

- url: https://www.tradingview.com/script/u82khjne-Adaptive-Moving-Average-ATR-Bands-NJ/
- type: indicator
- pine_id: PUB;800bdfa08f6442ed88e77273e2a2febd
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

Adaptive Moving Average ATR Bands is a volatility-based, trend-following indicator that builds ATR bands around three different moving averages and combines them into a single outer envelope.

SMA, RMA and LSMA are calculated from the same source and length. Each moving average receives its own ATR bands, and the highest upper band and lowest lower band are used as the final bands.

Since the three moving averages react to price at different speeds, the envelope adapts its width to the distance between them, requiring a stronger move before the active condition changes.
[image]https://www.tradingview.com/x/B5SJfJZ6/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

MA Source
Selects the price source used for the moving average calculations.

MA Length
Controls how many bars are used to calculate all three moving averages.

ATR Length
Controls how many bars are used to calculate the ATR.

ATR Multiplier
Controls how far the ATR bands are placed from each moving average.

[b]✧ HOW IT WORKS ✧[/b]

Moving Averages
Indicator calculates three moving averages from selected source over the same MA Length.
Simple Moving Average (SMA) gives equal weight to all values in the lookback period.
Wilder's Moving Average (RMA) applies exponential smoothing and reacts more slowly to new prices.
Least Squares Moving Average (LSMA) uses the endpoint of a linear regression line and closely follows recent price direction.

ATR Bands
ATR measures recent market volatility. Each moving average receives its own pair of bands.
Upper Band = Moving Average + ATR × ATR Multiplier
Lower Band = Moving Average − ATR × ATR Multiplier

Outer Envelope
Highest of the three upper bands is used as final upper band. Lowest of the three lower bands is used as final lower band.
When the moving averages spread apart, the envelope widens. When they converge, the envelope narrows toward a single ATR band.

Signal Logic
A bullish condition is activated when price closes above the final upper band.
A bearish condition is activated when price closes below the final lower band.
Active condition remains unchanged until the opposite condition occurs.

[b]✧ VISUALIZATION ✧[/b]

Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

During a bullish condition, lower band is displayed in green.
During a bearish condition, upper band is displayed in red.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

Adaptive Moving Average ATR Bands can be used to identify:

Bullish and bearish trend conditions
Volatility-adjusted price breakouts
Dynamic trend support and resistance
Directional market bias
Trend confirmation
Additional confirmation for other technical analysis

Combining three moving averages with different responsiveness is designed to filter minor price moves that would cross bands built around a single moving average.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Adaptive Moving Average ATR Bands [NJ]", "AMAAB", overlay = true, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode   = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
maSrc    = input.source(close, "MA source", group = g2)
maLen    = input.int(28, "MA length", group = g2)
atrLen   = input.int(6, "ATR length", group = g2)
atrMulti = input.float(0.75, "ATR multiplier", step = 0.05, group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Get MAs
sma  = ta.sma(maSrc, maLen)
rma  = ta.rma(maSrc, maLen)
lsma = ta.linreg(maSrc, maLen, 0)

// Get ATR
atr = ta.atr(atrLen)

// Get bands
bands(ma, multi) =>
    upperBand = ma + atr * multi
    lowerBand = ma - atr * multi
    [upperBand, lowerBand]

[upperSma, lowerSma]   = bands(sma, atrMulti)
[upperRma, lowerRma]   = bands(rma, atrMulti)
[upperLsma, lowerLsma] = bands(lsma, atrMulti)

// Find the bands that are farthest from the price
upperBand = math.max(upperSma, upperRma, upperLsma)
lowerBand = math.min(lowerSma, lowerRma, lowerLsma)

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if close > upperBand
    NJ := 1
if close < lowerBand
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

# DEMA Z-Score [NJ]

- url: https://www.tradingview.com/script/7L3strrf-DEMA-Z-Score-NJ/
- type: indicator
- pine_id: PUB;46355aeba2d04e7983c0fd0373485bf8
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

DEMA Z-Score measures how far a Double Exponential Moving Average of price is positioned from its own recent mean, expressed in standard deviations.

Selected price source is first smoothed with DEMA and then converted into a Z-Score. Separate long and short thresholds are used to identify bullish and bearish conditions.

DEMA reduces lag compared with a standard EMA, while Z-Score normalization keeps readings comparable across different price levels and volatility conditions.
https://www.tradingview.com/x/hEA5ItIg/

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

Source
Selects the price source used for the DEMA calculation.

Source Length
Controls how many bars are used to calculate the DEMA.

Z-Score Length
Controls how much DEMA history is used to calculate the mean and standard deviation.

Long Threshold
Controls the score required for the indicator to switch to a bullish condition.

Short Threshold
Controls the score required for the indicator to switch to a bearish condition.

[b]✧ HOW IT WORKS ✧[/b]

Double Exponential Moving Average
Indicator calculates an EMA of selected source and a second EMA of that result, both using Source Length.
DEMA = 2 × EMA − EMA of EMA
This reduces lag compared with a single EMA of the same length.

Z-Score
Mean of DEMA is calculated with a simple moving average over Z-Score Length, together with standard deviation over the same period.
Z-Score = (DEMA − Mean) / Standard Deviation
Positive values indicate that DEMA is above its recent mean, while negative values indicate that it is below.

Signal Logic
A bullish condition is activated when Z-Score rises above the Long Threshold.
A bearish condition is activated when Z-Score falls below the Short Threshold.
While Z-Score remains between both thresholds, previous condition stays active.

[b]✧ VISUALIZATION ✧[/b]

Oscillator changes color based on the active condition:
Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

Long and short thresholds are plotted as dashed lines in bullish and bearish colors.

Same signal colors can optionally be applied directly to the chart candles.

Plotted Z-Score is capped one unit beyond each threshold to keep the relevant signal area in focus. This does not affect the underlying calculation or signal logic.

[b]✧ USAGE ✧[/b]

DEMA Z-Score can be used to identify:

Bullish and bearish trend conditions
Changes in smoothed price positioning
Potential directional shifts
Trend confirmation
Momentum context
Additional confirmation for other technical analysis

Indicator is designed to provide directional market context based on where smoothed price is positioned relative to its recent statistical range.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("DEMA Z-Score [NJ]", "DZS", overlay = false, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode   = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
src      = input.source(low, "Source", group = g2)
srcLen   = input.int(26, "Source length", group = g2)
zsLen    = input.int(32, "Z-Score length", group = g2)
longThr  = input.float(0, "Long threshold", step = 0.1, group = g2)
shortThr = input.float(-0.2, "Short threshold", step = 0.1, group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Source (dema)
ema1   = ta.ema(src, srcLen)
ema2   = ta.ema(ema1, srcLen)
source = 2 * ema1 - ema2

// Mean
mean = ta.sma(source, zsLen)

// Standard deviation
stDev = ta.stdev(source, zsLen)

// Z-Score
zScore = (source - mean) / stDev

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if zScore > longThr
    NJ := 1
if zScore < shortThr
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
     display = display.all - display.status_line - display.price_scale,
     force_overlay = true)

// Display capped Z-Score
zsCapped = math.max(shortThr - 1, math.min(longThr + 1, zScore))
plot(zsCapped, "Z-Score", sigCol, 2)
hline(longThr, "Long threshold", longCol)
hline(shortThr, "Short threshold", shortCol)
````

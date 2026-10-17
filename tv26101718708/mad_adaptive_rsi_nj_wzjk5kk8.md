# MAD Adaptive RSI [NJ]

- url: https://www.tradingview.com/script/wzJK5kk8-MAD-Adaptive-RSI-NJ/
- type: indicator
- pine_id: PUB;702c01e26a1e44e5bfb30ab95938a91d
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

MAD Adaptive RSI combines Relative Strength Index with adaptive thresholds based on Median Absolute Deviation.

MAD measures recent price volatility and adjusts bullish and bearish RSI thresholds accordingly. Wider price dispersion moves thresholds farther apart, while lower dispersion brings them closer together.

This allows signal requirements to adapt to changing market conditions instead of relying on fixed RSI levels.
https://www.tradingview.com/x/j1vbUruM/

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

MAD Length
Controls how much price history is used for Median Absolute Deviation calculation.

MAD Smoothing
Controls smoothing applied to normalized MAD values.

MAD Multiplier
Controls how strongly MAD affects adaptive thresholds.

Threshold Base
Sets central level around which bullish and bearish thresholds are calculated.

[b]✧ HOW IT WORKS ✧[/b]

Median Absolute Deviation
Indicator calculates median price over selected MAD Length and measures absolute deviations of closing prices from that median.
Median of those deviations produces MAD, providing a measure of recent price volatility that is less affected by extreme values.

Normalization and Smoothing
MAD is converted into a percentage of current closing price, making its value more comparable across different price levels.
Normalized MAD is then smoothed and multiplied by MAD Multiplier.
Resulting adjustment is capped at 10 to prevent thresholds from expanding excessively.

Adaptive Thresholds
Smoothed MAD adjustment is added to and subtracted from Threshold Base.
Upper threshold increases as price volatility grows, while lower threshold decreases.

RSI
A 14-period RSI is used as momentum input.

Signal Logic
A bullish condition is activated when RSI crosses above upper adaptive threshold.
A bearish condition is activated when RSI crosses below lower adaptive threshold.
While RSI remains between both thresholds, previous condition stays active.

[b]✧ VISUALIZATION ✧[/b]

Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

Upper and lower adaptive thresholds are plotted as dashed lines and move dynamically as MAD changes.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

MAD Adaptive RSI can be used to identify:

Bullish and bearish momentum conditions
Momentum shifts confirmed by adaptive thresholds
Changes in price volatility
Potential directional transitions
Trend confirmation
Momentum context
Additional confirmation for other technical analysis

Adaptive thresholds require stronger RSI movement when price volatility is elevated and become more sensitive when volatility is lower.

Indicator is designed to provide directional momentum context while adjusting signal requirements to recent market conditions.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("MAD Adaptive RSI [NJ]", "MAR", overlay = false, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
displayColCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
madLen = input.int(29, "MAD length", group = g2)
madSmooth = input.int(15, "MAD smoothing", group = g2)
madMulti = input.float(1.6, "MAD multiplier", step = 0.05, group = g2)
thr = input.int(53, "Threshold base", group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// MAD
mad(src, len) =>

    // Save source values
    array<float> srcArray = array.new<float>()
    for i = 0 to len - 1
        array.push(srcArray, src[i])

    // Get median of source values
    med = array.median(srcArray)

    // Absolute deviations from median
    array<float> devArray = array.new<float>()
    for i = 0 to len - 1
        array.push(devArray, math.abs(array.get(srcArray, i) - med))

    // Get median of absolute deviations
    mad = array.median(devArray)

// MAD
mad = mad(close, madLen)

// Normalize, smooth and cap MAD
madPct = (mad / close) * 100
smoothMadPct = ta.sma(madPct, madSmooth)
capMadPct = math.min(smoothMadPct * madMulti, 10)

// RSI
rsi = ta.rsi(close, 14)

// Adaptive thresholds
longThr = thr + capMadPct
shortThr = thr - capMadPct

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if ta.crossover(rsi, longThr)
    NJ := 1
if ta.crossunder(rsi, shortThr)
    NJ := -1

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Colors
longCol  = colorMode == "Colored" ? color.rgb(0, 136, 100) : colorMode == "Neutral" ? color.rgb(179, 179, 179) : na
shortCol = colorMode == "Colored" ? color.rgb(120, 0, 32) : colorMode == "Neutral" ? color.rgb(60, 60, 60) : na
sigCol =  NJ == 1 ? longCol : NJ == -1 ? shortCol : na

// Color candles
plotcandle(
     open, high, low, close,
     "Colored candles", 
     displayColCandles ? sigCol : na,
     displayColCandles ? sigCol : na,
     bordercolor = displayColCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale,
     force_overlay = true)

// Display RSI
plot(rsi, "RSI", sigCol, 2)
plot(longThr, "Upper threshold", longCol, linestyle = plot.linestyle_dashed)
plot(shortThr, "Lower threshold", shortCol, linestyle = plot.linestyle_dashed)
````

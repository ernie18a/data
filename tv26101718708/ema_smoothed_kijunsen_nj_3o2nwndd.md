# EMA Smoothed Kijun-Sen [NJ]

- url: https://www.tradingview.com/script/3o2nWNDD-EMA-Smoothed-Kijun-Sen-NJ/
- type: indicator
- pine_id: PUB;de193e254bd649368a8485d6f63fa7bd
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

EMA Smoothed Kijun-Sen is a trend-following indicator that applies exponential smoothing to the Kijun-sen, the baseline of the Ichimoku Cloud.

Kijun-sen is the midpoint between the highest and lowest values over a selected period. Smoothing it with an EMA turns the stepped baseline into a continuous line that is less sensitive to single swing highs and lows.

Price position relative to the smoothed line determines the current bullish or bearish condition, which is displayed using colored candles, a colored baseline and a gradient glow.
[image]https://www.tradingview.com/x/f0MM9x0c/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

KS Source
Selects the price source used for the Kijun-sen calculation.

KS Length
Controls how many bars are used to find the highest and lowest values for the Kijun-sen.

Smoothing Length
Controls how many bars are used for the EMA applied to the Kijun-sen.

[b]✧ HOW IT WORKS ✧[/b]

Kijun-Sen
Indicator finds the highest and lowest values of selected source over KS Length.
Kijun-Sen = (Highest Value + Lowest Value) / 2
The result represents the equilibrium point of the recent price range.

Smoothing
Kijun-sen only changes when a new high or low enters or leaves the lookback period, which creates flat steps.
An exponential moving average over Smoothing Length converts these steps into a continuous baseline.

Signal Logic
A bullish condition is active when the entire candle is above the smoothed Kijun-sen.
A bearish condition is activated as soon as the low of a candle moves below the smoothed Kijun-sen, including candles that cross through the line.

[b]✧ VISUALIZATION ✧[/b]

Smoothed Kijun-sen changes color based on the active condition:
Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

A gradient glow fills the area between the smoothed Kijun-sen and a 10-period simple moving average of closing price. It is strongest at the baseline and fades toward price.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

EMA Smoothed Kijun-Sen can be used to identify:

Bullish and bearish trend conditions
Dynamic trend support and resistance
Price position relative to range equilibrium
Directional market bias
Trend confirmation
Additional confirmation for other technical analysis

Combining range-based equilibrium with exponential smoothing is designed to provide a stable trend baseline that still reflects changes in the recent price range.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("EMA Smoothed Kijun-Sen [NJ]", "SKS", overlay = true, behind_chart = false)

//  ███╗   ██╗     ██╗
//  ████╗  ██║     ██║
//  ██╔██╗ ██║     ██║
//  ██║╚██╗██║     ██║
//  ██║ ╚████║ ██╗ ██║
//  ██║  ╚███║ ╚████╔╝
//  ╚═╝   ╚══╝  ╚═══╝

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode   = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
ksSrc     = input.source(hl2, "KS source", group = g2)
ksLen     = input.int(38, "KS length", group = g2)
smoothLen = input.int(20, "Smoothing length", group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Get Kijun-Sen
kijunSen = (ta.highest(ksSrc, ksLen) + ta.lowest(ksSrc, ksLen)) / 2

// Smooth KS
smoothKs = ta.ema(kijunSen, smoothLen)

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if high > smoothKs
    NJ := 1
if low < smoothKs
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

// Display smooth KS
plot(smoothKs, "Smooth Kijun-sen", sigCol, 2)

// Glow
sma = ta.sma(close, 10)

upperCol = NJ == 1 ? color.new(color.black, 100) : color.new(shortCol, 40)
lowerCol = NJ == 1 ? color.new(longCol, 40) : color.new(color.black, 100)

upper = NJ == 1 ? sma : smoothKs
lower = NJ == 1 ? smoothKs : sma

upperPlot = plot(NJ == 1 ? sma : smoothKs, "Upper glow", color = na)
lowerPlot = plot(NJ == 1 ? smoothKs : sma, "Lower glow", color = na)

fill(upperPlot, lowerPlot, upper, lower, upperCol, lowerCol)
````

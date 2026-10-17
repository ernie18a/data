# KAMA Adaptive SD Bands [NJ]

- url: https://www.tradingview.com/script/RtIYhwm7-KAMA-Adaptive-SD-Bands-NJ/
- type: indicator
- pine_id: PUB;5b8ac911b0ae45139cc86825506a249e
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

KAMA Adaptive SD Bands is a volatility-based, trend-following indicator that combines Kaufman's Adaptive Moving Average with standard deviation bands.

KAMA adjusts its smoothing speed based on how efficiently price is moving. It follows price closely during steady directional moves and slows down when price moves back and forth without clear direction.

Price moving beyond the standard deviation bands determines the current bullish or bearish condition, which is displayed using colored candles, an active volatility band and a gradient glow.
[image]https://www.tradingview.com/x/lN0hcAYJ/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

KAMA Source
Selects the price source used for the KAMA calculation.

KAMA Length
Controls how many bars are used to measure efficiency for the KAMA.

SD Length
Controls how many bars are used to calculate the standard deviation.

SD Multiplier
Controls how far the bands are placed from the KAMA.

[b]✧ HOW IT WORKS ✧[/b]

Efficiency Ratio
Indicator measures how directly price has moved over KAMA Length.
Efficiency Ratio = Net Price Change / Sum of All Bar-to-Bar Price Changes
Values near 1 indicate that price is moving steadily in one direction. Values near 0 indicate that price is moving back and forth without much net progress.

Kaufman's Adaptive Moving Average
Efficiency Ratio is converted into a smoothing constant that ranges between the speed of a 2-period and a 30-period EMA.
KAMA = Previous KAMA + Smoothing Constant × (Source − Previous KAMA)
High efficiency moves KAMA quickly toward price. Low efficiency keeps it close to its previous value, filtering short-term noise.

Standard Deviation Bands
Standard deviation of closing price is calculated over SD Length and measures how widely price has recently been dispersed.
Upper Band = KAMA + Standard Deviation × SD Multiplier
Lower Band = KAMA − Standard Deviation × SD Multiplier

Signal Logic
A bullish condition is activated when the high of a candle moves above the upper band.
A bearish condition is activated when the low of a candle moves below the lower band.
If both happen on the same candle, the bearish condition takes priority.
Active condition remains unchanged until the opposite condition occurs.

[b]✧ VISUALIZATION ✧[/b]

Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

During a bullish condition, lower band is displayed in green.
During a bearish condition, upper band is displayed in red.

A gradient glow fills the area between KAMA and the active band. It is strongest at the band and fades toward KAMA.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

KAMA Adaptive SD Bands can be used to identify:

Bullish and bearish trend conditions
Volatility-adjusted price breakouts
Dynamic trend support and resistance
Directional market bias
Trend confirmation
Additional confirmation for other technical analysis

Adaptive smoothing is designed to keep the bands responsive during clear directional moves while reducing signal changes caused by choppy price movement.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("KAMA Adaptive SD Bands [NJ]", "KASB", overlay = true, behind_chart = false)

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
kamaSrc = input.source(hl2, "KAMA source", group = g2)
kamaLen = input.int(30, "KAMA length", group = g2)
sdLen   = input.int(38, "SD length", group = g2)
sdMulti = input.float(1.4, "SD multiplier", step = 0.05, group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Kaufman's Adaptive Moving Average
kama(src, len) =>

    num = math.abs(src - src[len])

    float den = 0
    for i = 0 to len - 1
        den += math.abs(src[i] - src[i+1])

    er = num / den

    sc = math.pow(er * (2/3 - 2/31) + 2/31, 2)

    float kama = na
    kama := na(kama[1]) ? src : kama[1] + sc * (src - kama[1])

kama = kama(kamaSrc, kamaLen)

// KAMA bands
sd = ta.stdev(close, sdLen)
upperBand = kama + sd * sdMulti
lowerBand = kama - sd * sdMulti

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

// Glow
upperCol = NJ == 1 ? color.new(color.black, 100) : color.new(shortCol, 40)
lowerCol = NJ == 1 ? color.new(longCol, 40) : color.new(color.black, 100)

upper = NJ == 1 ? kama : upperBand
lower = NJ == 1 ? lowerBand : kama

upperPlot = plot(NJ == 1 ? kama : upperBand, "Upper glow", color = na)
lowerPlot = plot(NJ == 1 ? lowerBand : kama, "Lower glow", color = na)

fill(upperPlot, lowerPlot, upper, lower, upperCol, lowerCol)
````

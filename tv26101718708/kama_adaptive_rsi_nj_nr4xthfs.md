# KAMA Adaptive RSI [NJ]

- url: https://www.tradingview.com/script/nR4xThfs-KAMA-Adaptive-RSI-NJ/
- type: indicator
- pine_id: PUB;9bbb1b09fa254cbea37eb6274a7e7860
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

KAMA Adaptive RSI is a momentum-based, trend-following oscillator that smooths the Relative Strength Index with Kaufman's Adaptive Moving Average.

KAMA adjusts its smoothing speed based on how efficiently RSI is moving. It follows RSI closely during steady directional moves and slows down when RSI moves back and forth without clear direction.

Smoothed RSI crossing the long and short thresholds is used to identify bullish and bearish conditions
[image]https://www.tradingview.com/x/PO8TX8Up/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

RSI Source
Selects the price source used for the RSI calculation.

RSI Length
Controls how many bars are used to calculate the RSI.

Smoothing Length
Controls how many bars are used to measure efficiency for the KAMA smoothing.

Long Threshold
Controls the first RSI level used for signal changes.

Short Threshold
Controls the second RSI level used for signal changes.

[b]✧ HOW IT WORKS ✧[/b]

Relative Strength Index
RSI compares recent gains and losses of selected source and expresses the result on a scale from 0 to 100.
Values above 50 indicate stronger upward movement, while values below 50 indicate stronger downward movement.

Efficiency Ratio
Indicator measures how directly RSI has moved over Smoothing Length.
Efficiency Ratio = Net RSI Change / Sum of All Bar-to-Bar RSI Changes
Values near 1 indicate that RSI is moving steadily in one direction. Values near 0 indicate that RSI is moving back and forth without much net progress.

Kaufman's Adaptive Moving Average
Efficiency Ratio is converted into a smoothing constant that ranges between the speed of a 2-period and a 30-period EMA.
Smoothed RSI = Previous Value + Smoothing Constant × (RSI − Previous Value)
High efficiency moves the smoothed line quickly toward RSI. Low efficiency keeps it close to its previous value, filtering short-term noise.

Signal Logic
A bullish condition is activated when smoothed RSI crosses above either threshold.
A bearish condition is activated when smoothed RSI crosses below either threshold.
Because both levels can trigger a change, the condition switches at the first threshold crossed in each direction.
Active condition remains unchanged until the opposite condition occurs.

[b]✧ VISUALIZATION ✧[/b]

Oscillator changes color based on the active condition:
Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

Long and short thresholds are plotted as dashed lines in bullish and bearish colors.

Same signal colors can optionally be applied directly to the chart candles.

[b]✧ USAGE ✧[/b]

KAMA Adaptive RSI can be used to identify:

Bullish and bearish momentum conditions
Shifts in directional strength
Potential trend changes
Trend confirmation
Market bias
Additional confirmation for other technical analysis

Adaptive smoothing is designed to keep the oscillator responsive during clear momentum moves while reducing signal changes caused by choppy RSI movement.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("KAMA Adaptive RSI [NJ]", "KAR", overlay = false, behind_chart = false)

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
src       = input.source(open, "RSI source", group = g2)
rsiLen    = input.int(12, "RSI length", group = g2)
smoothLen = input.int(13, "Smoothing length", group = g2)
longThr   = input.int(40, "Long threshold", group = g2)
shortThr  = input.int(50, "Short threshold", group = g2)

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

// Smoothed RSI
rsi = ta.rsi(src, rsiLen)
smoothRsi = kama(rsi, smoothLen)

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if ta.crossover(smoothRsi, longThr) or ta.crossover(smoothRsi, shortThr)
    NJ := 1
if ta.crossunder(smoothRsi, shortThr) or ta.crossunder(smoothRsi, longThr)
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

// Display RSI
plot(smoothRsi, "Smoothed RSI", sigCol, 2)
hline(longThr, "Long threshold", longCol)
hline(shortThr, "Short threshold", shortCol)
````

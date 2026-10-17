# HLC Oscillator [NJ]

- url: https://www.tradingview.com/script/FEWOAkNt-HLC-Oscillator-NJ/
- type: indicator
- pine_id: PUB;b84b1b96f18a4154b504da20171ae088
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

HLC Oscillator measures relative price strength by comparing current high, low, and close with their historical values over a selected lookback period.

The three comparison counts are averaged into a single score, which is then used to identify bullish and bearish conditions with separate thresholds.
[image]https://www.tradingview.com/x/5gibmf3g/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on the current signal.

Count Length
Controls how much price history is used for the high, low, and close comparisons.

Long Threshold
Controls the score required for the indicator to switch to a bullish condition.

Short Threshold
Controls the score required for the indicator to switch to a bearish condition.

[b]✧ HOW IT WORKS ✧[/b]

HLC Comparison
Indicator compares current high, low, and close with their corresponding historical values over the selected lookback period.
Each time a current value is above its historical value, comparison count increases.

Combined Score
High, low, and close comparison counts are combined and averaged into a single oscillator value.

Higher values indicate that the current HLC values are positioned above a larger portion of their recent history, while lower values indicate weaker relative price positioning.

Signal Logic
A bullish condition is activated when the oscillator rises above the Long Threshold.

A bearish condition is activated when the oscillator falls below the Short Threshold.

While the oscillator remains between two thresholds, previous condition stays active.

[b]✧ VISUALIZATION ✧[/b]

Oscillator changes color based on the active condition:
Green represents a bullish condition.
Red represents a bearish condition.

Neutral mode displays the same conditions using light and dark shades.

The same colors can optionally be applied directly to the chart candles.

Plotted oscillator is capped slightly beyond the threshold levels to keep the relevant signal area in focus. This does not affect the underlying calculation or signal logic.

[b]✧ USAGE ✧[/b]

HLC Oscillator can be used to identify:

Bullish and bearish price strength
Changes in relative price positioning
Potential directional shifts
Trend confirmation
Momentum context
Additional confirmation for other technical analysis

Indicator is designed to provide directional market context based on the relative position of current price values within their recent history.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("HLC Oscillator [NJ]", "HLCO", behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)

const string g2 = "✧ CALCULATION ✧"
countLen = input.int(68, "Count length", group = g2)
longThr = input.int(61, "Long threshold", group = g2)
shortThr = input.int(41, "Short threshold", group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Compare current price values to historical
int count = 0
for i = 0 to countLen - 1
    count += high/high[i] > 1 ? 1 : 0
    count += low/low[i] > 1 ? 1 : 0
    count += close/close[i] > 1 ? 1 : 0

// Average counted values
countAvg = count / 3

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int NJ = 0

if countAvg > longThr
    NJ := 1
if countAvg < shortThr
    NJ := -1

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Cap count
cappedCount = math.max(shortThr - 5, math.min(longThr + 5, countAvg))

// Colors
longCol  = colorMode == "Colored" ? color.rgb(0, 136, 100) : colorMode == "Neutral" ? color.rgb(179, 179, 179) : na
shortCol = colorMode == "Colored" ? color.rgb(120, 0, 32) : colorMode == "Neutral" ? color.rgb(60, 60, 60) : na
sigCol =  NJ == 1 ? longCol : NJ == -1 ? shortCol : na

// Color candles
plotcandle(
     open, high, low, close,
     "Colored candles", 
     dispCandles ? sigCol : na,
     dispCandles ? sigCol : na,
     bordercolor = dispCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale,
     force_overlay = true)

// Display oscillator
plot(cappedCount, "Count", sigCol, 2)
hline(longThr, "Long threshold", longCol)
hline(shortThr, "Short threshold", shortCol)
````

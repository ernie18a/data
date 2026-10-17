# Pivot Support & Resistance Zones [NJ]

- url: https://www.tradingview.com/script/7jYMEBTI-Pivot-Support-Resistance-Zones-NJ/
- type: indicator
- pine_id: PUB;02ae2ba2b849470ea8bb2da639599332
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

Pivot Support & Resistance Zones is a price action indicator that converts confirmed swing highs and swing lows into support and resistance zones.

Each pivot high creates a resistance zone (which can also act as support) and each pivot low creates a support zone (which can also act as resistance). Zone height is based on ATR, so zones scale with market volatility instead of using a fixed price distance.

Zones extend to the right, keeping previous swing levels visible as potential areas of future price reaction.
[image]https://www.tradingview.com/x/7edzky01/[/image]

[b]✧ SETTINGS ✧[/b]

Color Mode
Switches between colored and neutral visualization.

Color Candles
Shows or hides candle coloring based on candle direction.

Maximum Zones Shown
Controls how many support and resistance zones remain on the chart at the same time.

Swing Strength
Controls how many bars on each side are required to confirm a pivot high or pivot low.

[b]✧ HOW IT WORKS ✧[/b]

Pivot Detection
A pivot high forms when a candle's high is the highest value within Swing Strength bars on both sides.
A pivot low forms when a candle's low is the lowest value within Swing Strength bars on both sides.
Higher Swing Strength values detect fewer, more significant swings. Lower values detect more frequent, smaller swings.

Confirmation
A pivot can only be confirmed after Swing Strength bars have closed after it. Each zone therefore appears with a delay equal to Swing Strength, but is drawn starting from the original pivot candle.
Once drawn, a zone does not change position.

Zone Construction
Zone level is placed slightly inside the pivot candle, 10% of its range away from the extreme.
For resistance, this is just below the pivot high. For support, just above the pivot low.
Zone height is based on 14-period ATR measured at the pivot candle.
Upper Edge = Zone Level + ATR × 0.2
Lower Edge = Zone Level − ATR × 0.2

Zone Management
All zones extend to the right until they are removed.
When the number of zones exceeds Maximum Zones Shown, the oldest zone is deleted.
Zones remain on the chart even after price moves through them.

[b]✧ VISUALIZATION ✧[/b]

Green zones represent support formed at pivot lows.
Red zones represent resistance formed at pivot highs.

Neutral mode displays the same zones using light and dark shades.

Candles can optionally be colored by direction:
Green represents candles closing above their open.
Red represents candles closing below their open.

[b]✧ USAGE ✧[/b]

Pivot Support & Resistance Zones can be used to identify:

Key support and resistance areas
Previous swing highs and swing lows
Potential reaction and reversal zones
Breakout and retest areas
Market structure context
Additional confirmation for other technical analysis

Using zones instead of single lines accounts for the fact that price often reacts within an area around a previous swing rather than at one exact price.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Pivot Support & Resistance Zones [NJ]", "PSRZ", overlay = true, behind_chart = false)

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
colorMode   = input.string("Colored", "Color mode", options = ["Colored", "Neutral"], group = g1)
dispCandles = input.bool(true, "Color candles", group = g1)
maxBoxes    = input.int(10, "Maximum zones shown", minval = 1, group = g1)

const string g2 = "✧ CALCULATION ✧"
pivotLen = input.int(40, "Swing strength", 1, group = g2)

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Get pivots
pivotHigh = ta.pivothigh(pivotLen, pivotLen)
pivotLow  = ta.pivotlow(pivotLen, pivotLen)

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Colors
longCol  = colorMode == "Colored" ? color.rgb(0, 136, 100) : colorMode == "Neutral" ? color.rgb(179, 179, 179) : na
shortCol = colorMode == "Colored" ? color.rgb(120, 0, 32) : colorMode == "Neutral" ? color.rgb(60, 60, 60) : na
sigCol = close > open ? longCol : close < open ? shortCol : na

// Color candles
plotcandle(
     open, high, low, close,
     "Colored candles", 
     dispCandles ? sigCol : na,
     dispCandles ? sigCol : na,
     bordercolor = dispCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale)

// Display reversal zones
var array<box> boxes = array.new<box>()

atr       = ta.atr(14) * 0.2
zoneAtr   = atr[pivotLen]
highPrice = high[pivotLen] + (low[pivotLen] - high[pivotLen]) * 0.1
lowPrice  = low[pivotLen] + (high[pivotLen] - low[pivotLen]) * 0.1

if not na(pivotHigh)
    newBox = box.new(
        left = bar_index - pivotLen,
        top = highPrice + zoneAtr,
        right = bar_index,
        bottom = highPrice - zoneAtr,
        xloc = xloc.bar_index,
        extend = extend.right,
        border_color = shortCol,
        bgcolor = color.new(shortCol, 90)
        )

    array.push(boxes, newBox)

if not na(pivotLow)
    newBox = box.new(
        left = bar_index - pivotLen,
        top = lowPrice + zoneAtr,
        right = bar_index,
        bottom = lowPrice - zoneAtr,
        xloc = xloc.bar_index,
        extend = extend.right,
        border_color = longCol,
        bgcolor = color.new(longCol, 90)
        )

    array.push(boxes, newBox)

while array.size(boxes) > maxBoxes
    oldBox = array.shift(boxes)
    box.delete(oldBox)
````

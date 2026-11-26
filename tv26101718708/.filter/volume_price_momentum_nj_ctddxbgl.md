# Volume Price Momentum [NJ]

- url: https://www.tradingview.com/script/cTddxBGL-Volume-Price-Momentum-NJ/
- type: indicator
- pine_id: PUB;f531de4cb6ba484cbda125fa0bca561d
- version: 1.0

## Description

[b]✧ OVERVIEW ✧[/b]

Volume Price Momentum combines relative volume and price strength into a single momentum score.

The indicator compares current volume and closing price with their recent values, combines both measurements, and smooths the result to identify shifts between bullish and bearish conditions.

A range filter is used to prevent new buy signals while the market is detected as ranging.
https://www.tradingview.com/x/3m7dNmHy/

[b]✧ SETTINGS ✧[/b]

Show Buy/Sell Labels?
Shows or hides BUY and SELL labels when the signal changes direction.

Show Colored Candles?
Shows or hides candle coloring based on the current signal.

Show Range Status?
Shows or hides the range status table in the top-right corner of the chart.

Buy Threshold
Controls the score required for the indicator to switch to a buy signal.

Sell Threshold
Controls the score required for the indicator to switch to a sell signal.

Volume Length
Controls how much recent volume history is used to measure relative volume strength.

Price Length
Controls how much recent price history is used to measure relative price strength.

Smoothing Length
Controls how much the final score is smoothed.

[b]✧ HOW IT WORKS ✧[/b]

Volume Strength
Current volume is ranked against recent volume values using percentile ranking. Higher values indicate that current volume is relatively high compared with the selected lookback period.

Price Strength
The current closing price is ranked against recent closing prices in the same way. Higher values indicate that price is trading relatively high within the selected lookback period.

Combined Score
The volume and price rankings are averaged into a single score and then smoothed using a moving average.

Signal Logic
A buy signal is activated when the score reaches or exceeds the Buy Threshold, provided the market is not currently ranging.
A sell signal is activated when the score falls below the Sell Threshold.

Range Filter
The indicator uses Range Detector [NJ] to identify ranging market conditions: https://www.tradingview.com/script/pB6xqZvV-Range-Detector-NJ/
While a range is active, new buy signals are blocked. The range status table displays whether a range is currently detected.

[b]✧ VISUALIZATION ✧[/b]

The oscillator changes color based on the active signal:
Green represents a buy condition.
Red represents a sell condition.

The same colors can optionally be applied directly to the chart candles.

BUY and SELL labels are displayed only when the active signal changes direction.

The range status table shows:
✓ when a range is detected.
✕ when no range is detected.

[b]✧ USAGE ✧[/b]

Volume Price Momentum can be used to identify:

Bullish and bearish momentum shifts
Changes in relative volume and price strength
Potential trend transitions
Momentum confirmation
Ranging market conditions
Additional confirmation for other technical analysis

The indicator is designed to provide directional market context rather than predict exact tops or bottoms.

As with any technical indicator, it is best used alongside other forms of analysis rather than as a standalone entry or exit signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoNejc

//@version=6
indicator("Volume Price Momentum [NJ]", "VPM")

// ✧═════════════════✧
// ║      INPUTS      ║
// ✧═════════════════✧

const string g1 = "✧ DISPLAY ✧"
displayLabels     = input.bool(true, "Show buy/sell labels?", group = g1)
displayColCandles = input.bool(true, "Show colored candles?", group = g1)
displayRngStatus  = input.bool(true, "Show range status?", group = g1)

const string g2 = "✧ CALCULATION ✧"
buyThr    = input.int(50, "Buy threshold", group = g2)
sellThr   = input.int(45, "Sell threshold", group = g2)
volLen    = input.int(30, "Volume length", group = g2)
priceLen  = input.int(50, "Price length", group = g2)
smoothLen = input.int(14, "Smoothing length", group = g2)

// ✧═══════════════════════✧
// ║      RANGE FILTER      ║
// ✧═══════════════════════✧

import CryptoNejc/RangeDetector/1 as rd

inRange = rd.detect()

// ✧══════════════════════✧
// ║      CALCULATION      ║
// ✧══════════════════════✧

// Volume and price percentile ranks
volRank   = ta.percentrank(volume, volLen)
priceRank = ta.percentrank(close, priceLen)

// Average percentile score
avgScore = (volRank + priceRank) / 2

// Smooth the score
smoothScore = ta.sma(avgScore, smoothLen)

// Cap the score
cappedScore = math.max(35, math.min(60, smoothScore))

// Buy/sell signals
buySig  = cappedScore >= buyThr and not inRange
sellSig = cappedScore < sellThr

// ✧═══════════════════════✧
// ║      FINAL SIGNAL      ║
// ✧═══════════════════════✧

var int sig = 0

if buySig
    sig := 1
if sellSig
    sig := -1

// ✧════════════════✧
// ║      PLOTS      ║
// ✧════════════════✧

// Colors
long  = color.rgb(0, 136, 100)
short = color.rgb(120, 0, 32)

color sigCol = sig == 1 ? long : sig == -1 ? short : na

// Score oscillator
plot(cappedScore, "Score", sigCol, 3)

hline(buyThr, "Buy threshold", long)
hline(sellThr, "Sell threshold", short)

// Range status table
var table rangeTable = table.new(
     position.top_right, 1, 2,
     frame_color = color.new(color.white, 85),
     frame_width = 1)

if barstate.islast and displayRngStatus
    table.cell(
         rangeTable, 0, 0,
         "✧ RANGE ✧",
         text_color = color.new(color.white, 15),
         text_size = size.small,
         bgcolor = color.rgb(18, 18, 20))

    table.cell(
         rangeTable, 0, 1,
         inRange ? "✓" : "✕",
         text_color = inRange ? long : short,
         text_size = size.large,
         bgcolor = color.rgb(18, 18, 20))

// Colored candles
plotcandle(
     open, high, low, close,
     "Colored candles", 
     displayColCandles ? sigCol : na,
     displayColCandles ? sigCol : na,
     bordercolor = displayColCandles ? sigCol : na,
     display = display.all - display.status_line - display.price_scale,
     force_overlay = true)

// Buy/sell labels
plotshape(
     sig == 1 and sig[1] == -1 and displayLabels,
     title = "Buy",
     text = "BUY",
     style = shape.labelup,
     location = location.belowbar,
     color = long,
     textcolor = color.white,
     size = size.small,
     force_overlay = true)

plotshape(
     sig == -1 and sig[1] == 1 and displayLabels,
     title = "Sell",
     text = "SELL",
     style = shape.labeldown,
     location = location.abovebar,
     color = short,
     textcolor = color.white,
     size = size.small,
     force_overlay = true)
````

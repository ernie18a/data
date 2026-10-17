# RSI Divergence Scout

- url: https://www.tradingview.com/script/FD5MU5IH-RSI-Divergence-Scout/
- type: indicator
- pine_id: PUB;ce5b0f07df2a4658a78372e86941f961
- version: 1.0

## Description

RSI Divergence Scout is a pivot-based RSI divergence study designed to mark potential disagreement between price movement and RSI momentum directly on the price chart.

The purpose of this script is to make bullish and bearish RSI divergences easier to see without requiring a separate oscillator pane or a large visual dashboard.

What the script detects

The study looks for two common RSI divergence conditions:

Bullish RSI divergence

A bullish divergence is detected when:

– price forms a confirmed pivot low below the previous confirmed pivot low
– RSI forms a higher value compared with the RSI value at the previous pivot low
– the previous RSI value was below the lower RSI context threshold

This can suggest that downside momentum is weakening, even though price has made a lower low.

Bearish RSI divergence

A bearish divergence is detected when:

– price forms a confirmed pivot high above the previous confirmed pivot high
– RSI forms a lower value compared with the RSI value at the previous pivot high
– the previous RSI value was above the upper RSI context threshold

This can suggest that upside momentum is weakening, even though price has made a higher high.

How the calculation works

The script uses confirmed pivot highs and pivot lows.

For bearish divergence, it compares the current confirmed pivot high with the previous confirmed pivot high:

– current pivot high price is higher than the previous pivot high price
– current RSI value is lower than the previous RSI value
– the previous RSI value is above the upper RSI context threshold

For bullish divergence, it compares the current confirmed pivot low with the previous confirmed pivot low:

– current pivot low price is lower than the previous pivot low price
– current RSI value is higher than the previous RSI value
– the previous RSI value is below the lower RSI context threshold

When a divergence is detected, the script draws a dashed line between the two relevant price pivots and places a label on the current confirmed pivot. The label can also show the RSI value at that pivot.

Why pivot confirmation matters

The script waits for a pivot high or pivot low to be confirmed using the selected left/right pivot sensitivity.

This means a signal appears only after the pivot is confirmed, not at the exact live high or low. This delay is intentional. It helps reduce noise and avoids marking every small candle fluctuation as a swing point.

Inputs

RSI length

Controls the RSI calculation period.

Pivot left bars

Controls how many bars to the left are required for pivot confirmation.

Pivot right bars

Controls how many bars to the right are required for pivot confirmation.

Higher pivot values produce fewer signals and focus on larger swings. Lower values produce more signals and make the script more sensitive to smaller price movements.

Upper RSI context threshold

Used as a context filter for bearish divergence. The previous pivot high RSI must be above this threshold.

Lower RSI context threshold

Used as a context filter for bullish divergence. The previous pivot low RSI must be below this threshold.

Display settings

The script allows bullish and bearish divergence labels to be shown or hidden independently. Pivot-to-pivot lines and RSI values on labels can also be enabled or disabled.

Alerts

The script includes basic alert conditions for bullish and bearish RSI divergence.

Because the script uses confirmed pivots, alerts trigger only after the pivot confirmation process is complete.

How to use it

RSI divergence should be treated as an early warning signal, not as a complete trade trigger.

A divergence can show that momentum is changing, but it does not confirm that price must reverse. In strong trends, multiple divergences can appear before price actually changes direction.

This study is most useful when combined with additional market context, such as:

– trend structure
– support and resistance
– volume behavior
– higher-timeframe direction
– risk management rules

Limitations

The script does not predict future price direction.

It does not generate complete buy or sell signals.

Pivot-based signals appear only after the pivot is confirmed.

Divergence can fail during strong trends, low-liquidity conditions or news-driven price movement.

The study should be used as one part of a broader analysis process.

Educational content only. Not financial advice.

## Source Code

````pine
//@version=6
// =============================================================
//  RSI Divergence Scout
//  Pivot-based bullish / bearish RSI divergence on the price chart.
//  Educational study. Not financial advice.
// =============================================================

indicator("RSI Divergence Scout", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
groupCore = "Core settings"

rsiLen = input.int(14, "RSI length", minval=2, group=groupCore)

pivLeft = input.int(3, "Pivot left bars", minval=1, group=groupCore)
pivRight = input.int(3, "Pivot right bars", minval=1, group=groupCore)

upperRsiContext = input.float(
     60.0,
     "Upper RSI context threshold",
     minval=50.0,
     maxval=100.0,
     step=1.0,
     group=groupCore
)

lowerRsiContext = input.float(
     40.0,
     "Lower RSI context threshold",
     minval=0.0,
     maxval=50.0,
     step=1.0,
     group=groupCore
)

groupDisplay = "Display"

showBear = input.bool(true, "Show bearish divergence", group=groupDisplay)
showBull = input.bool(true, "Show bullish divergence", group=groupDisplay)
showLines = input.bool(true, "Draw pivot-to-pivot lines", group=groupDisplay)
showRsiValue = input.bool(true, "Show RSI value on labels", group=groupDisplay)

// ─────────────────────────────────────────────────────────────
// RSI calculation
// ─────────────────────────────────────────────────────────────
rsi = ta.rsi(close, rsiLen)

// ─────────────────────────────────────────────────────────────
// Pivot highs: bearish RSI divergence
// ─────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivLeft, pivRight)

var float lastHighPrice = na
var float lastHighRsi = na
var int lastHighBar = na

bearishDiv = false

if not na(ph)
    float currentHighPrice = high[pivRight]
    float currentHighRsi = rsi[pivRight]
    int currentHighBar = bar_index - pivRight

    bearishDiv := not na(lastHighPrice) and
         not na(lastHighRsi) and
         currentHighPrice > lastHighPrice and
         currentHighRsi < lastHighRsi and
         lastHighRsi >= upperRsiContext

    if bearishDiv and showBear
        if showLines
            line.new(
                 lastHighBar,
                 lastHighPrice,
                 currentHighBar,
                 currentHighPrice,
                 color=color.red,
                 width=2,
                 style=line.style_dashed
            )

        string bearText = "Bear Div"
        if showRsiValue
            bearText += "\nRSI " + str.tostring(currentHighRsi, "#")

        label.new(
             currentHighBar,
             currentHighPrice,
             bearText,
             style=label.style_label_down,
             color=color.new(color.red, 0),
             textcolor=color.white,
             size=size.small,
             yloc=yloc.abovebar
        )

    lastHighPrice := currentHighPrice
    lastHighRsi := currentHighRsi
    lastHighBar := currentHighBar

// ─────────────────────────────────────────────────────────────
// Pivot lows: bullish RSI divergence
// ─────────────────────────────────────────────────────────────
pl = ta.pivotlow(low, pivLeft, pivRight)

var float lastLowPrice = na
var float lastLowRsi = na
var int lastLowBar = na

bullishDiv = false

if not na(pl)
    float currentLowPrice = low[pivRight]
    float currentLowRsi = rsi[pivRight]
    int currentLowBar = bar_index - pivRight

    bullishDiv := not na(lastLowPrice) and
         not na(lastLowRsi) and
         currentLowPrice < lastLowPrice and
         currentLowRsi > lastLowRsi and
         lastLowRsi <= lowerRsiContext

    if bullishDiv and showBull
        if showLines
            line.new(
                 lastLowBar,
                 lastLowPrice,
                 currentLowBar,
                 currentLowPrice,
                 color=color.green,
                 width=2,
                 style=line.style_dashed
            )

        string bullText = "Bull Div"
        if showRsiValue
            bullText += "\nRSI " + str.tostring(currentLowRsi, "#")

        label.new(
             currentLowBar,
             currentLowPrice,
             bullText,
             style=label.style_label_up,
             color=color.new(color.green, 0),
             textcolor=color.white,
             size=size.small,
             yloc=yloc.belowbar
        )

    lastLowPrice := currentLowPrice
    lastLowRsi := currentLowRsi
    lastLowBar := currentLowBar

// ─────────────────────────────────────────────────────────────
// Basic alert conditions
// Alerts trigger when the pivot is confirmed, not on the original pivot bar.
// ─────────────────────────────────────────────────────────────
alertcondition(
     bearishDiv and showBear,
     title="Bearish RSI divergence",
     message="Bearish RSI divergence detected on {{ticker}} {{interval}}"
)

alertcondition(
     bullishDiv and showBull,
     title="Bullish RSI divergence",
     message="Bullish RSI divergence detected on {{ticker}} {{interval}}"
)
````

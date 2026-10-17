# Smart Market Structure Pro

- url: https://www.tradingview.com/script/SkYHLbNF-Smart-Market-Structure-Pro/
- type: indicator
- pine_id: PUB;d761141afb1d4fcaa4b990b385624740
- version: 1.0

## Description

Description:
This indicator automatically detects and marks significant swing highs and swing lows using pivot-based market structure analysis.

Features:

Identifies Swing Highs and Swing Lows.
Labels market structure as:
HH (Higher High)
HL (Higher Low)
LH (Lower High)
LL (Lower Low)
Draws structure lines connecting consecutive highs and lows.
Helps traders visualize trend direction and market structure.
Suitable for Forex, Gold, Indices, Stocks, and Cryptocurrencies.
Works on all timeframes, including 1-minute charts.

How to Use:

A sequence of HH and HL indicates an uptrend.
A sequence of LH and LL indicates a downtrend.
Use market structure breaks as potential trend reversal signals.
Combine with support/resistance, moving averages, or supply and demand zones for better trade confirmation.

Recommended Settings:

Aggressive: Left Bars = 3, Right Bars = 3
Balanced: Left Bars = 5, Right Bars = 5
Conservative: Left Bars = 8, Right Bars = 8

Disclaimer:
This indicator is for educational and analytical purposes only and should not be considered financial advice. Always use proper risk management when trading.

## Source Code

````pine
//@version=6
indicator("Smart Market Structure Pro", overlay=true, max_labels_count=500, max_lines_count=500)

// ===== INPUTS =====
leftBars  = input.int(5, "Left Bars", minval=1)
rightBars = input.int(5, "Right Bars", minval=1)

showLabels = input.bool(true, "Show HH HL LH LL")
showLines  = input.bool(true, "Show Structure Lines")

// ===== PIVOTS =====
pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

// ===== STORAGE =====
var float lastHigh = na
var float lastLow  = na

var int lastHighBar = na
var int lastLowBar  = na

// ===== HIGHS =====
if not na(pivotHigh)

    currentBar = bar_index - rightBars

    if showLabels
        if na(lastHigh)
            label.new(currentBar, pivotHigh,
                 "H",
                 style=label.style_label_down)

        else
            txt = pivotHigh > lastHigh ? "HH" : "LH"

            label.new(currentBar, pivotHigh,
                 txt,
                 style=label.style_label_down)

    if showLines and not na(lastHighBar)
        line.new(lastHighBar, lastHigh,
             currentBar, pivotHigh,
             width=2)

    lastHigh := pivotHigh
    lastHighBar := currentBar

// ===== LOWS =====
if not na(pivotLow)

    currentBar = bar_index - rightBars

    if showLabels
        if na(lastLow)
            label.new(currentBar, pivotLow,
                 "L",
                 style=label.style_label_up)

        else
            txt = pivotLow > lastLow ? "HL" : "LL"

            label.new(currentBar, pivotLow,
                 txt,
                 style=label.style_label_up)

    if showLines and not na(lastLowBar)
        line.new(lastLowBar, lastLow,
             currentBar, pivotLow,
             width=2)

    lastLow := pivotLow
    lastLowBar := currentBar

// ===== PLOT SHAPES =====
plotshape(not na(pivotHigh),
     location=location.abovebar,
     style=shape.triangledown,
     size=size.small,
     offset=-rightBars)

plotshape(not na(pivotLow),
     location=location.belowbar,
     style=shape.triangleup,
     size=size.small,
     offset=-rightBars)
````

# Range Trading with Fib Retest 50% Zone [JPT]

- url: https://www.tradingview.com/script/PpjeYaoV-Range-Trading-with-Fib-Retest-50-Zone-JPT/
- type: indicator
- pine_id: PUB;69f814483cd74c6fbad6506713b7bd5b
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Range Trading with Fib Retest 50% Zone [JPT][/b] is a smart Fibonacci-based trading indicator designed to identify high-probability retracement entries after strong market moves.
The indicator automatically detects the current trading range and draws dynamic Fibonacci retracement levels without requiring manual anchoring. The 50% Equilibrium Zone acts as the primary area of interest where price often retraces before continuing its trend.

🔷 [b]This tool is suitable for:[/b]

•Intraday Trading
•Swing Trading
•Forex
•Crypto
•Indices
•Commodities
•Features

✔ Automatic Range Detection
✔ Dynamic Fibonacci Levels

0%
23.6%
38.2%
50%
61.8%
100%

• Automatic 50% Equilibrium Zone

• Dynamic Support & Resistance Levels

• Trend Continuation Setup

• Pullback Entry Identification

• Clean Chart Display
 
• Non-Repainting Calculations
 
• Beginner Friendly

🔷 [b]How to Use[/b]

Bullish Trend
Wait for a strong impulsive move. Allow price to retrace.
Watch the 50% Fib Zone. Look for bullish confirmation.
Enter on confirmation. Target previous highs or higher Fibonacci extensions.

Bearish Trend
Wait for a strong bearish impulse. Price retraces upward.
Watch the 50% Fib Zone. Wait for bearish confirmation.
Enter short. Target previous lows.

🔷 [b]Best Timeframes[/b]
• 5 Minute

• 15 Minute

• 30 Minute

• 1 Hour

• 4 Hour

• Daily

🔷 [b]Works Best On[/b]
[list][*]Crypto
[*]Forex
[*]Gold
[*]NASDAQ
[*]US30
[*]S&P500
[*]Stocks[*][/list]
🔷 [b]Indicator Includes[/b]
Automatic Fibonacci Retracement
Dynamic Range Detection 50% Equilibrium Zone
38.2% & 61.8% Confirmation Levels Real-Time Updates
Clean Visual Layout

🔷 [b]Risk Disclaimer[/b]
This indicator is an analytical tool and should be used alongside proper risk management and your own trading plan. No indicator guarantees profitable trades. Always test on a demo account before using it with live funds.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
//@version=6
indicator("Range Trading with Fib Retest 50% Zone [JPT]", shorttitle="RT Fib 50 [JPT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// Inputs
leftBars  = input.int(5, "Pivot Left", minval=1)
rightBars = input.int(5, "Pivot Right", minval=1)
extendRight = input.bool(true, "Extend Lines Right")
showLabels = input.bool(true, "Show Labels")

// Pivot Detection
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float swingHigh = na
var float swingLow  = na
var int highBar = na
var int lowBar = na

if not na(ph)
    swingHigh := ph
    highBar := bar_index - rightBars

if not na(pl)
    swingLow := pl
    lowBar := bar_index - rightBars

// Direction
bull = lowBar < highBar

top = bull ? swingHigh : swingLow
bot = bull ? swingLow : swingHigh

fibRange = top - bot

fib0   = top
fib236 = top - fibRange * 0.236
fib382 = top - fibRange * 0.382
fib50  = top - fibRange * 0.500
fib618 = top - fibRange * 0.618
fib786 = top - fibRange * 0.786
fib100 = bot

plot(fib0,   color=color.red,    linewidth=2, title="0%")
plot(fib236, color=color.orange, linewidth=1, title="23.6%")
plot(fib382, color=color.yellow, linewidth=1, title="38.2%")
plot(fib50,  color=color.gray,   linewidth=1, title="50%")
plot(fib618, color=color.green,  linewidth=2, title="61.8%")
plot(fib786, color=color.aqua,   linewidth=1, title="78.6%")
plot(fib100, color=color.blue,   linewidth=2, title="100%")

// Draw swing line
var line swing = na
if not na(top) and not na(bot)
    line.delete(swing)
    swing := line.new(
         bull ? lowBar : highBar,
         bot,
         bull ? highBar : lowBar,
         top,
         color=color.white,
         width=2)

// Labels
if showLabels and barstate.islast
    label.new(bar_index, fib618, "61.8%", style=label.style_label_left, color=color.green, textcolor=color.white)
    label.new(bar_index, fib50, "50%", style=label.style_label_left, color=color.gray, textcolor=color.white)
    label.new(bar_index, fib382, "38.2%", style=label.style_label_left, color=color.yellow, textcolor=color.black)
````

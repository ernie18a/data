# NIFTY 100-500 Levels

- url: https://www.tradingview.com/script/V1bClmXz-NIFTY-100-500-Levels/
- type: indicator
- pine_id: PUB;13889a32e6d84366b6596f9365b25dd4
- version: 1.0

## Description

This indicator plots psychological price levels for NIFTY 50 and other indices/stocks using automatic horizontal support and resistance zones.

Features
🔵 Blue horizontal lines every 100 points
🔴 Red horizontal lines every 500 points
Automatic level plotting around current market price
Helps identify:
Psychological support & resistance
Intraday reaction zones
Breakout and reversal areas
Option strike importance levels
Example
23500 → Red major level
23600 → Blue minor level
23700 → Blue minor level
23800 → Blue minor level
23900 → Blue minor level
24000 → Red major level
Best Used For
NIFTY
BANKNIFTY
Index trading
Scalping
Intraday trading
Swing trading

Major 500-point levels are highlighted with thicker red lines for better visibility, while intermediate 100-point levels are shown in blue to maintain chart clarity.

## Source Code

````pine
//@version=5
indicator("NIFTY 100-500 Levels", overlay=true)

// ===== SETTINGS =====
rangePoints = input.int(3000, "Range Around Price")

// ===== CALCULATIONS =====
startLevel = math.floor((close - rangePoints) / 100) * 100
endLevel   = math.ceil((close + rangePoints) / 100) * 100

// ===== DRAW LINES =====
for level = startLevel to endLevel by 100

    // Every 500 level = RED
    is500 = math.floor(level % 500) == 0

    lineColor = is500 ? color.red : color.blue
    lineWidth = is500 ? 3 : 2

    line.new(
         x1 = bar_index - 1,
         y1 = level,
         x2 = bar_index,
         y2 = level,
         extend = extend.both,
         color = lineColor,
         width = lineWidth
     )
````

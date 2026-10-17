# Premarket Bars to Divide Asian and London Session

- url: https://www.tradingview.com/script/jeBkE46y-Premarket-Bars-to-Divide-Asian-and-London-Session/
- type: indicator
- pine_id: PUB;12c99e225fa44a58b3540b294175a3c5
- version: 1.0

## Description

Vertical Bars to Divide Asian and London Session so I don't have to draw them manually.

## Source Code

````pine
//@version=6
indicator("Premarket Bars", overlay=true)

// === SETTINGS ===
lineColor = color.new(color.white, 60)
lineWidth = 2

// === SESSION CHECKS ===
// These trigger ONCE when the bar enters the specified minute

sess1800 = not na(time(timeframe.period, "1800-1801"))
sess0200 = not na(time(timeframe.period, "0200-0201"))
sess0830 = not na(time(timeframe.period, "0830-0831"))

// Trigger only once per session occurrence
new1800 = sess1800 and not sess1800[1]
new0200 = sess0200 and not sess0200[1]
new0830 = sess0830 and not sess0830[1]

// === DRAW VERTICAL LINES ===
if new1800 or new0200 or new0830
    line.new(
         x1 = bar_index,
         y1 = low - ta.atr(14) * 10,
         x2 = bar_index,
         y2 = high + ta.atr(14) * 10,
         extend = extend.both,
         color = lineColor,
         width = lineWidth
     )
````

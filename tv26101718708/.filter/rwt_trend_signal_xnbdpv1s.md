# RWT Trend Signal

- url: https://www.tradingview.com/script/XnBDpV1s-RWT-Trend-Signal/
- type: indicator
- pine_id: PUB;e1fe8bb33e0945a4bf360c9810461aef
- version: 1.0

## Description

Color changes with the MA length you choose. Alerts can be set.

## Source Code

````pine
//@version=5
indicator("RWT Trend Signal (Smoothed Slope)", overlay=true)

length = input.int(20, "Length")
maType = input.string("EMA", "MA Type", options=["SMA", "EMA", "RMA", "WMA", "VWMA", "HMA"])
srcType = input.string("Close", "Source", options=["Close", "HL2", "HLC3", "OHLC4"])

src = srcType == "Close" ? close :
      srcType == "HL2" ? hl2 :
      srcType == "HLC3" ? hlc3 :
      ohlc4

hma(src, len) =>
    ta.wma(2 * ta.wma(src, math.round(len / 2)) - ta.wma(src, len), math.round(math.sqrt(len)))

ma = maType == "SMA" ? ta.sma(src, length) :
     maType == "EMA" ? ta.ema(src, length) :
     maType == "RMA" ? ta.rma(src, length) :
     maType == "WMA" ? ta.wma(src, length) :
     maType == "VWMA" ? ta.vwma(src, length) :
     hma(src, length)

// 🔥 Smoothed slope (THIS is the fix)
slope = ta.ema(ma - ma[1], 2)

bull = slope > 0
bear = slope < 0

maColor = bull ? color.lime : bear ? color.fuchsia : color.gray

plot(ma, color=maColor, linewidth=4)

// Alerts
bullFlip = bull and not bull[1]
bearFlip = bear and not bear[1]

alertcondition(bullFlip, title="Trend Turned Green", message="RWT Trend turned GREEN")
alertcondition(bearFlip, title="Trend Turned Pink", message="RWT Trend turned PINK")
````

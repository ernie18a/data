# MA-WK Moving Average  Engulfing Candle Signals

- url: https://www.tradingview.com/script/H66xpNPr-MA-WK-Moving-Average-Engulfing-Candle-Signals/
- type: indicator
- pine_id: PUB;e15c4ab5eb63415bb9d9cd30785cac57
- version: 1.0

## Description

MA-WK – Moving Average + Engulfing Candle Signals

This indicator is designed to help identify market direction using three key moving averages: MA 21, MA 55 and MA 100. These levels can be used to observe short-term, medium-term and longer-term trend behaviour directly on the chart.

The script also includes optional smoothing settings, allowing the user to choose between SMA, EMA, SMMA/RMA, WMA and VWMA methods for additional moving average smoothing.

A built-in candlestick pattern detection system highlights potential Bullish Engulfing and Bearish Engulfing signals. These patterns may help traders spot possible reversal areas or continuation setups when combined with the moving averages.

Main features:
- 21-period moving average
- 55-period moving average
- 100-period moving average
- Adjustable source and offset
- Optional smoothing method
- Bullish Engulfing candle signal
- Bearish Engulfing candle signal
- Works directly on the price chart

This indicator can be useful for traders who want a simple visual tool to follow trend direction, observe dynamic support and resistance areas, and identify possible candle-based momentum shifts.

Note:  
This script is for educational and analytical purposes only. It is not financial advice. Always combine it with your own analysis, risk management and market context.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © deimos41

//@version=6
indicator(title="Moving Average", shorttitle="MA-WK", overlay=true, timeframe="", timeframe_gaps=true)

len = input.int(21, minval=1, title="Length A")
len1 = input.int(55, minval=1, title="Length B")
len2 = input.int(100, minval=1, title="Length C")
src = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500)
out = ta.sma(src, len)
out1 = ta.sma(src, len1)
out2 = ta.sma(src, len2)

plot(out, color=color.green, title="MA 21", offset=offset)
plot(out1, color=color.blue, title="MA 55", offset=offset)
plot(out2, color=color.red, title="MA 100", offset=offset)
ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

typeMA = input.string(title = "Method", defval = "SMA", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="Smoothing")
smoothingLength = input.int(title = "Length", defval = 5, minval = 1, maxval = 100, group="Smoothing")

smoothingLine = ma(out, smoothingLength, typeMA)
smoothingLine1 = ma(out1, smoothingLength, typeMA)
plot(smoothingLine, title="Smoothing Line", color=#f37f20, offset=offset, display=display.none)
plot(smoothingLine1, title="Smoothing Line", color=#9948b0, offset=offset, display=display.none)

/// Engulfing Candle pattern detection

// Define candleColor 
candleColor = close > open ? 1 : -1

// Engulfing Candle pattern detection
bullishEngulfing = candleColor[1] == -1 and candleColor == 1 and close > high[1] and open < low[1]
bearishEngulfing = candleColor[1] == 1 and candleColor == -1 and open > high[1] and close < low[1]

plotshape(bullishEngulfing, title="Bullish Engulfing", location=location.belowbar, color=color.rgb(84, 175, 76), style=shape.labelup, text="Bullish Engulfing")
plotshape(bearishEngulfing, title="Bearish Engulfing", location=location.abovebar, color=color.red, style=shape.labeldown, text="Bearish Engulfing")
````

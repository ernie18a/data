# Roy MACD Histogram EMA 5

- url: https://www.tradingview.com/script/ZuXDobyC-Roy-MACD-Histogram-EMA-5/
- type: indicator
- pine_id: PUB;225647ac28f0474da69f9e9a81d8145e
- version: 1.0

## Description

Roy MACD Histogram EMA 5 is a modified MACD momentum indicator with an additional EMA 5 line applied directly to the MACD histogram.

The EMA 5 Histogram helps traders read momentum strength, weakness, and early momentum changes more clearly compared to the standard MACD.

When the histogram is above the EMA 5 Histogram, bullish momentum is considered stronger. When the histogram is below the EMA 5 Histogram, bearish momentum is considered stronger or bullish momentum may be weakening.

This indicator includes MACD Line, Signal Line, Histogram, EMA 5 Histogram, and simple momentum markers to highlight potential bullish or bearish momentum shifts.

Best used together with price action, support and resistance, trendline, market structure, EMA 50/100/200, and proper risk management.

This indicator is not a financial advice or a guaranteed signal system. Always backtest and use proper money management.

## Source Code

````pine
//@version=5
indicator("Roy MACD Histogram EMA 5", shorttitle="Roy MACD EMA5", overlay=false)

// === INPUT SETTING ===
fastLength   = input.int(12, "MACD Fast Length")
slowLength   = input.int(26, "MACD Slow Length")
signalLength = input.int(9, "Signal Length")
histEmaLen   = input.int(5, "EMA Histogram Length")

src = input.source(close, "Source")

// === MACD CALCULATION ===
fastMA = ta.ema(src, fastLength)
slowMA = ta.ema(src, slowLength)

macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, signalLength)
histogram  = macdLine - signalLine

// === EMA 5 ATAS HISTOGRAM ===
histEma = ta.ema(histogram, histEmaLen)

// === WARNA HISTOGRAM ===
histColor = histogram >= 0 ?
     histogram > histogram[1] ? color.lime : color.green :
     histogram < histogram[1] ? color.red : color.maroon

// === PLOT MACD ===
plot(histogram, title="MACD Histogram", style=plot.style_columns, color=histColor)
plot(histEma, title="EMA 5 Histogram", color=color.yellow, linewidth=2)

plot(macdLine, title="MACD Line", color=color.aqua, linewidth=1)
plot(signalLine, title="Signal Line", color=color.orange, linewidth=1)

// === ZERO LINE ===
hline(0, "Zero Line", color=color.gray)

// === SIGNAL MOMENTUM ===
bullMomentum = histogram > histEma and histogram > 0
bearMomentum = histogram < histEma and histogram < 0

plotshape(bullMomentum and not bullMomentum[1],
     title="Bull Momentum Start",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.tiny)

plotshape(bearMomentum and not bearMomentum[1],
     title="Bear Momentum Start",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny)

// === ALERT CONDITION ===
alertcondition(bullMomentum and not bullMomentum[1],
     title="Bull Momentum",
     message="MACD Histogram berada atas EMA 5 Histogram - Bullish Momentum")

alertcondition(bearMomentum and not bearMomentum[1],
     title="Bear Momentum",
     message="MACD Histogram berada bawah EMA 5 Histogram - Bearish Momentum")// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sdroy87
````

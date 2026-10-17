# SMA Trend Flow

- url: https://www.tradingview.com/script/Kgoqvxde/
- type: indicator
- pine_id: PUB;7e0870fdae66473ab2cdb7a0655bf2a5
- version: 5.0

## Description

A clean and intuitive trend-following indicator designed to simplify market analysis using multiple Simple Moving Averages (SMAs).

Instead of displaying only moving averages, this indicator visualizes trend direction, trend strength, and potential entry timing in a simple and easy-to-read format.

Features
Displays 5, 20, 60, 100, and 200 SMAs.
Background highlights when a Perfect Order is established:
Bullish: 5 > 20 > 60 > 100
Bearish: 5 < 20 < 60 < 100
Dynamic fill between the 5 SMA and 20 SMA.
The fill becomes stronger as more SMAs align in the same direction, making trend strength easy to recognize at a glance.
Buy and sell arrows when the 5 SMA crosses the 20 SMA.
Alert support for both bullish and bearish crossovers.
Why this indicator?

The goal is to reduce chart clutter while providing the essential information needed for trend-following and swing trading.

With a single glance, traders can quickly identify:

Overall market trend
Trend strength
Short-term momentum
Potential entry opportunities

This indicator is designed for traders who prefer clean charts and objective trend analysis.

## Source Code

````pine
//@version=6
indicator("SMA Trend Entry", overlay=true)

//======================================================
// SMA SETTINGS
//======================================================

sma5Length   = input.int(5, "SMA 5", minval=1)
sma20Length  = input.int(20, "SMA 20", minval=1)
sma60Length  = input.int(60, "SMA 60", minval=1)
sma100Length = input.int(100, "SMA 100", minval=1)
sma200Length = input.int(200, "SMA 200", minval=1)

//======================================================
// SMA CALCULATION
//======================================================

sma5   = ta.sma(close, sma5Length)
sma20  = ta.sma(close, sma20Length)
sma60  = ta.sma(close, sma60Length)
sma100 = ta.sma(close, sma100Length)
sma200 = ta.sma(close, sma200Length)

//======================================================
// PERFECT ORDER
//======================================================

bullPerfect =
     sma5 > sma20 and
     sma20 > sma60 and
     sma60 > sma100

bearPerfect =
     sma5 < sma20 and
     sma20 < sma60 and
     sma60 < sma100

//======================================================
// BACKGROUND
//======================================================

bgcolor(
     bullPerfect ? color.new(color.green, 90) :
     bearPerfect ? color.new(color.red, 90) :
     na
)

//======================================================
// SMA DISPLAY
//======================================================

plot(
     sma5,
     title="SMA 5",
     color=color.rgb(255, 0, 0),
     linewidth=1
)

plot(
     sma20,
     title="SMA 20",
     color=color.rgb(3, 36, 249),
     linewidth=1
)

plot(
     sma60,
     title="SMA 60",
     color=color.rgb(116, 5, 252),
     linewidth=1
)

plot(
     sma100,
     title="SMA 100",
     color=color.rgb(245, 111, 1),
     linewidth=1
)

plot(
     sma200,
     title="SMA 200",
     color=color.rgb(24, 197, 162),
     linewidth=1
)

//======================================================
// SMA DIRECTION
//======================================================

sma5Down  = sma5 < sma5[1]
sma20Down = sma20 < sma20[1]

//======================================================
// BUY SIGNAL
// 5 SMA crosses above 20 SMA
// and 5 > 20 > 60
//======================================================

buySignal =
     ta.crossover(sma5, sma20) and
     sma5 > sma20 and
     sma20 > sma60

//======================================================
// SELL SIGNAL
// 5 SMA crosses below 20 SMA
// and both SMA 5 and SMA 20 are pointing downward
//======================================================

sellSignal =
     ta.crossunder(sma5, sma20) and
     sma5Down and
     sma20Down

//======================================================
// SIGNAL DISPLAY
//======================================================

plotshape(
     buySignal,
     title="Buy Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=#1ea38d,
     size=size.small
)

plotshape(
     sellSignal,
     title="Sell Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.rgb(244, 123, 123),
     size=size.small
)

//======================================================
// ALERTS
//======================================================

entrySignal = buySignal or sellSignal

alertcondition(
     buySignal,
     title="Bullish SMA Entry",
     message="SMA 5 crossed above SMA 20 while SMA 5 > SMA 20 > SMA 60."
)

alertcondition(
     sellSignal,
     title="Bearish SMA Entry",
     message="SMA 5 crossed below SMA 20 while both SMA 5 and SMA 20 are pointing downward."
)

alertcondition(
     entrySignal,
     title="SMA Trend Entry",
     message="SMA Trend Entry signal detected."
)
````

# MACD Advance [Jos-ProTrader]

- url: https://www.tradingview.com/script/YCho6aXo-MACD-Advance-Jos-ProTrader/
- type: indicator
- pine_id: PUB;1a1aa0141fd149488b46687fe7c678b5
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]MACD Advance [JPT[/b]] is an educational technical analysis indicator built around the [b]Moving Average Convergence Divergence (MACD)[/b] It combines the traditional MACD components with additional visual signals to help traders study momentum, trend behavior, and potential changes in market conditions.

The indicator is designed to assist with chart analysis and should be used alongside your own trading strategy and risk management.

🔷 [b]FEATURES[/b]

- Classic MACD Line and Signal Line
- Color-coded MACD Histogram
- Momentum shift visualization
- Bullish and bearish crossover markers
- Optional trend filter support
- Customizable input parameters
- Clear and organized indicator layout
- Alert conditions for key signal events

🔷 [b]HOW IT WORKS[/b]

The indicator compares two moving averages to measure momentum and trend direction. It plots:

- [b]MACD Line[/b] to represent momentum.
- [b]Signal Line[/b] to identify potential crossover events.
- [b]Histogram[/b] to visualize the difference between the two lines and highlight changes in momentum.
- Additional visual markers may appear when predefined technical conditions are met.

These elements are intended to help traders observe changes in momentum and identify areas that may warrant further analysis.

🔷 [b]HOW TO USE[/b]

- Observe the relationship between the MACD Line and Signal Line.
- Monitor the histogram for strengthening or weakening momentum.
- Use crossover signals as part of your overall market analysis.
- Consider confirming signals with price action, trend analysis, support/resistance, or other technical tools before making trading decisions.

🔷 [b]NOTES[/b]

- This script is provided for educational and analytical purposes only.
- Indicator signals should not be interpreted as guaranteed buy or sell opportunities.
- Market conditions can change rapidly, and no technical indicator can predict future price movement with certainty.
- Always perform your own analysis and apply appropriate risk management before entering any trade.

If you find this script helpful, your feedback and suggestions are always welcome. Thank you for using [b]MACD Advance [JPT][/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator(
    "MACD Advance [JPT]",
    shorttitle = "MACD Advance [JPT]",
    overlay = false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupEMA = "EMA Trend Filter"
emaFastLen = input.int(50, "EMA Fast", minval=1, group=groupEMA)
emaSlowLen = input.int(200, "EMA Slow", minval=1, group=groupEMA)
showTrendBg = input.bool(true, "Background Trend", group=groupEMA)

groupMACD = "MACD Settings"
src = input.source(close, "Source", group=groupMACD)
fastLen = input.int(12, "Fast Length", minval=1, group=groupMACD)
slowLen = input.int(26, "Slow Length", minval=1, group=groupMACD)
signalLen = input.int(9, "Signal Length", minval=1, group=groupMACD)

groupSignal = "Signals"
showSignals = input.bool(true, "Show Buy/Sell", group=groupSignal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema50 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

bgcolor(showTrendBg ? bullTrend ? color.new(color.green,92) : color.new(color.red,92) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastMA = ta.ema(src, fastLen)
slowMA = ta.ema(src, slowLen)

macd = fastMA - slowMA
signal = ta.ema(macd, signalLen)
hist = macd - signal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTOGRAM COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
histColor =
     hist >= 0 ?
     hist > hist[1] ? color.lime : color.green :
     hist < hist[1] ? color.red : color.maroon

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hline(0, "Zero Line", color.gray)

plot(hist,
     title="Histogram",
     style=plot.style_columns,
     color=histColor)

plot(macd,
     title="MACD",
     color=color.blue,
     linewidth=2)

plot(signal,
     title="Signal",
     color=color.orange,
     linewidth=2)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS (Pure MACD Cross)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buySignal  = ta.crossover(macd, signal)
sellSignal = ta.crossunder(macd, signal)

plotshape(showSignals and buySignal,
     title="LONG",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     text="",
     size=size.tiny)

plotshape(showSignals and sellSignal,
     title="SHORT",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     text="",
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZERO LINE SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
zeroBull = ta.crossover(macd, 0)
zeroBear = ta.crossunder(macd, 0)

plotshape(
     zeroBull,
     title="Zero Bull",
     style=shape.circle,
     location=location.bottom,
     color=color.aqua,
     size=size.tiny)

plotshape(
     zeroBear,
     title="Zero Bear",
     style=shape.circle,
     location=location.top,
     color=color.fuchsia,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal,
     title="Buy Signal",
     message="MACD Advance [JPT] BUY")

alertcondition(sellSignal,
     title="Sell Signal",
     message="MACD Advance [JPT] SELL")

alertcondition(buySignal,
     title="Bullish Cross",
     message="Bullish MACD Cross")

alertcondition(sellSignal,
     title="Bearish Cross",
     message="Bearish MACD Cross")

alertcondition(zeroBull,
     title="Zero Line Bullish",
     message="MACD crossed above Zero")

alertcondition(zeroBear,
     title="Zero Line Bearish",
     message="MACD crossed below Zero")
````

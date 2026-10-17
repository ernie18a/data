# Dynamic Pivot Levels Pro

- url: https://www.tradingview.com/script/1CGDwJ1Z-Dynamic-Pivot-Levels-Pro/
- type: indicator
- pine_id: PUB;17821e3dced3486a94b18928226be1ef
- version: 4.0

## Description

[b]Overview[/b]
[b]Dynamic Pivot Levels Pro[/b] is a price-action-based support and resistance indicator that automatically plots key pivot zones and reaction levels to help traders identify potential reversal, breakout, and profit-taking areas.

Unlike traditional pivot indicators, this tool focuses on significant market swings and recent structure to provide cleaner and more relevant trading levels.

[b]Features[/b]
Automatic Pivot High & Pivot Low Detection
Dynamic Support & Resistance Levels
Breakout and Rejection Monitoring
Clean Chart Visualization
Non-Repainting Pivot Confirmation
Suitable for Scalping, Day Trading, and Swing Trading

[b]How It Works[/b]

[b]Pivot High[/b]
A Pivot High is confirmed when price forms a significant swing high and surrounding candles validate the structure.

[b]Pivot Low[/b]
A Pivot Low is confirmed when price forms a significant swing low and surrounding candles validate the structure.

[b]Support Levels[/b]
Recent Pivot Lows are projected as support zones where buyers may become active.
[b]Resistance Levels[/b]
Recent Pivot Highs are projected as resistance zones where sellers may become active.
[b]Trading Applications[/b]
[b]Reversal Trading[/b]
Look for bullish reactions near support pivots and bearish reactions near resistance pivots.

[b]Breakout Trading[/b]
When price closes above a resistance pivot or below a support pivot, it may indicate a continuation move.

[b]Take Profit Planning[/b]
Pivot levels can serve as natural targets for profit-taking and trade management.

[b]Best Markets[/b]
* Forex
* Cryptocurrency
* Stocks
* Indices
* Futures

[b]Recommended Timeframes[/b]
* 1M – 5M for scalping
* 15M – 1H for intraday trading
* 4H – Daily for swing trading

[b]Key Advantages[/b]
* No future-looking calculations
* Non-repainting pivot confirmation
* Adapts to changing market structure
* Easy-to-read support and resistance framework

[b]Disclaimer[/b]
This indicator is intended for educational and analytical purposes only. Always use proper risk management and confirm signals with your own trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Dynamic Pivot Levels Pro", overlay=true, max_lines_count=200, max_labels_count=200)

// Inputs
pivotLen = input.int(5, "Pivot Strength", minval=1, maxval=20)
showBreakouts = input.bool(true, "Show Breakouts")
resColor = input.color(color.red, "Resistance Color")
supColor = input.color(color.lime, "Support Color")

// Confirmed pivots
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

// Store latest levels
var float lastRes = na
var float lastSup = na

// Store line objects
var line resLine = na
var line supLine = na

// New Resistance
if not na(pivotHigh)
    lastRes := pivotHigh

    if not na(resLine)
        line.delete(resLine)

    resLine := line.new(
         bar_index - pivotLen,
         pivotHigh,
         bar_index + 500,
         pivotHigh,
         extend=extend.right,
         color=resColor,
         width=2)

    label.new(
         bar_index - pivotLen,
         pivotHigh,
         "R",
         style=label.style_label_down,
         color=resColor,
         textcolor=color.white)

// New Support
if not na(pivotLow)
    lastSup := pivotLow

    if not na(supLine)
        line.delete(supLine)

    supLine := line.new(
         bar_index - pivotLen,
         pivotLow,
         bar_index + 500,
         pivotLow,
         extend=extend.right,
         color=supColor,
         width=2)

    label.new(
         bar_index - pivotLen,
         pivotLow,
         "S",
         style=label.style_label_up,
         color=supColor,
         textcolor=color.white)

// Breakout Logic
bullBreakout = showBreakouts and not na(lastRes) and ta.crossover(close, lastRes)
bearBreakout = showBreakouts and not na(lastSup) and ta.crossunder(close, lastSup)

// Plot Breakout Signals
plotshape(
     bullBreakout,
     title="Bull Breakout",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.small,
     text="Breakout")

plotshape(
     bearBreakout,
     title="Bear Breakout",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.small,
     text="Breakdown")

// Alerts
alertcondition(
     bullBreakout,
     title="Bullish Breakout",
     message="Price broke above Dynamic Resistance")

alertcondition(
     bearBreakout,
     title="Bearish Breakout",
     message="Price broke below Dynamic Support")
````

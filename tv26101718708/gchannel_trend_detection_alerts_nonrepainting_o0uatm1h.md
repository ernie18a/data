# G-Channel Trend Detection +Alerts (Non-Repainting)

- url: https://www.tradingview.com/script/O0uatm1h-G-Channel-Trend-Detection-Alerts-Non-Repainting/
- type: indicator
- pine_id: PUB;051c054921214296ac09665d2e968208
- version: 1.0

## Description

Here we are demonstrating a different approach to trend detection / trend analysis. Using this method, we consider the asset bullish if it breaks through the upward bounds of the channel at any time, and consider it bearish once it breaks downwards.

We have also simplified coloring: If we're in an uptrend, we're only drawing from the upwards part of the channel to the midline. And if we're in a downtrend we're only drawing from the downward part of the channel to the midline.

[i]Full credit goes to AlexGrover's G-Channel, 2019 .. Thank you @alexgrover for being an inspiration to so many. You have left a permanent mark on this space. Your incredible efforts are prolific and very much appreciated. 

Updated to non-repainting with alerts, 2026 by @fastecurrency .. Thank you very much for your valuable contributions. Amazing work![/i]

## Source Code

````pine
//@version=6
// Original credit to AlexGrover, 2019: https://www.tradingview.com/script/fIvlS64B-G-Channels-Efficient-Calculation-Of-Upper-Lower-Extremities/
// Updated to non-repainting, 2026 by @fastecurrency .. Thank you very much for your valuable contributions.
indicator("➔ G-Channel Trend Detection +Alerts (Non-Repainting)", shorttitle="➔ G-Trend", overlay=true)

// Inputs
length      = input.int(100, minval=1, title="Length")
src         = input.source(close, title="Source")
showSignals = input.bool(true, title="Show Buy/Sell Labels")
confirmBar  = input.bool(true, title="Wait For Candle Close (Non-Repainting)")

// G-Channel Calculation
var float a = na
var float b = na

a := math.max(src, nz(a[1])) - nz(a[1] - b[1]) / length
b := math.min(src, nz(b[1])) + nz(a[1] - b[1]) / length

avgLine = (a + b) / 2

// Original Cross Logic
crossUp = b[1] < close[1] and b > close
crossDn = a[1] < close[1] and a > close

bullish = ta.barssince(crossDn) <= ta.barssince(crossUp)

// Trend Change Signals
buySignalRaw  = bullish and not bullish[1]
sellSignalRaw = not bullish and bullish[1]

// Candle-close confirmation
buySignal  = confirmBar ? (buySignalRaw and barstate.isconfirmed) : buySignalRaw
sellSignal = confirmBar ? (sellSignalRaw and barstate.isconfirmed) : sellSignalRaw

// Colors
trendColor = bullish ? color.lime : color.red

// Plots
p1 = plot(avgLine, title="Average", color=trendColor, linewidth=2)
p2 = plot(close, title="Close", color=color.new(trendColor, 100))

fill(p1, p2, color=color.new(trendColor, 85))

// Buy/Sell Labels
plotshape(
     showSignals and buySignal,
     title="Buy",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY",
     textcolor=color.white,
     size=size.small)

plotshape(
     showSignals and sellSignal,
     title="Sell",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

// Alert Conditions
alertcondition(
     buySignal,
     title="G-Trend Buy",
     message="G-Trend BUY signal on {{ticker}} | Price: {{close}} | TF: {{interval}}")

alertcondition(
     sellSignal,
     title="G-Trend Sell",
     message="G-Trend SELL Signal on {{ticker}} | Price: {{close}} | TF: {{interval}}")

alertcondition(
     buySignal or sellSignal,
     title="G-Trend Any Signal",
     message="G-Trend trend change on {{ticker}} | Price: {{close}} | TF: {{interval}}")

// Optional alert() calls for immediate use
if buySignal
    alert("BUY Signal - " + syminfo.ticker, alert.freq_once_per_bar_close)

if sellSignal
    alert("SELL Signal - " + syminfo.ticker, alert.freq_once_per_bar_close)
````

# 14 RSI + HTF Confirmation

- url: https://www.tradingview.com/script/d0HHfv8X-14-RSI-HTF-Confirmation/
- type: indicator
- pine_id: PUB;10ee9214fe56489c85d99da972b49462
- version: 1.0

## Description

Multi TF RSI. Fully adjustable for looking at lower TF RSI value with Higher TF rsi above or below a certain level.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sumbloke077

//@version=6
indicator("14 RSI + HTF Confirmation", shorttitle="RSI + HTF", overlay=false)

// Inputs
len = input.int(14, minval=1, title="RSI Length")
src = input.source(close, "Source")

// Higher Timeframe Settings
htf = input.timeframe("60", "Higher Timeframe RSI")
bullLevel = input.int(40, "Bull Threshold")
bearLevel = input.int(60, "Bear Threshold")

// Current RSI
rsi = ta.rsi(src, len)

// Plot RSI
plot(rsi, "RSI", color=color.purple, linewidth=2)

band1 = hline(70, "Upper Band", color=color.gray)
bandm = hline(50, "Middle Band", color=color.new(color.gray, 50))
band0 = hline(30, "Lower Band", color=color.gray)

fill(band1, band0, color=color.new(color.purple, 80))

// Higher Timeframe RSI
htfRsi = request.security(
     syminfo.tickerid,
     htf,
     ta.rsi(src, len))

// Green circle near bottom when HTF RSI > Bull Threshold
plot(
     htfRsi > bullLevel ? 5 : na,
     title="HTF RSI Above Bull Threshold",
     style=plot.style_circles,
     linewidth=2,
     color=color.lime)

// Red circle near top when HTF RSI < Bear Threshold
plot(
     htfRsi < bearLevel ? 95 : na,
     title="HTF RSI Below Bear Threshold",
     style=plot.style_circles,
     linewidth=2,
     color=color.red)
````

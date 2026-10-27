# Multi Time Score Indicator

- url: https://www.tradingview.com/script/huMhykPC/
- type: indicator
- pine_id: PUB;b66fa68e697543929eaacd467054ec73
- version: 1.0

## Description

Multi Time Score Signal Indicator is a multi-timeframe scoring indicator designed for USDJPY on the 5-minute chart.

The script evaluates price position across multiple timeframes, including 5-minute, 15-minute, 1-hour, 4-hour, daily, and weekly charts. For each timeframe, it calculates where the current price is located within the recent high-low range and converts that position into a score. These scores are then combined using configurable importance weights.

A buy signal is displayed when the weighted total score rises above the sensitivity threshold. A sell signal is displayed when the weighted total score falls below zero.

Default settings:
Symbol: USDJPY
Timeframe: 5 minutes
Sensitivity: 10
Index Period: 20
5M Importance: 1
15M Importance: 2
1H Importance: 4
4H Importance: 7
1D Importance: 9
1W Importance: 10

The indicator displays buy and sell arrows, optional background coloring, alert conditions, and score values in the data window. It is designed for chart analysis and signal monitoring only. It does not place trades or perform backtesting.

This script is intended for chart analysis, backtesting support, research, and educational purposes only.
It does not guarantee future performance and should not be considered financial advice.
Please test carefully before using it in any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasayanFX

//@version=6
indicator("Multi Time Score Indicator", overlay=true)

// Inputs
sensitivity = input.int(10, "Sensitivity", minval=10, maxval=30)
indexPeriod = input.int(20, "Index Period", minval=10, maxval=100)

importance5M = input.int(1, "5M Importance", minval=1, maxval=10)
importance15M = input.int(2, "15M Importance", minval=1, maxval=10)
importance1H = input.int(4, "1H Importance", minval=1, maxval=10)
importance4H = input.int(7, "4H Importance", minval=1, maxval=10)
importance1D = input.int(9, "1D Importance", minval=1, maxval=10)
importance1W = input.int(10, "1W Importance", minval=1, maxval=10)

showScoreLine = input.bool(true, "Show Score Line")
showBackground = input.bool(true, "Show Background")
showText = input.bool(false, "Show BUY/SELL Text")

// Colors
scoreColor = color.rgb(255, 190, 60)
buyColor = color.rgb(0, 255, 170)
sellColor = color.rgb(255, 90, 120)
neutralColor = color.rgb(160, 160, 170)

// Functions
scoreFromRange(tf) =>
    tfHigh = request.security(syminfo.tickerid, tf, ta.highest(high, indexPeriod)[1], barmerge.gaps_off, barmerge.lookahead_off)
    tfLow = request.security(syminfo.tickerid, tf, ta.lowest(low, indexPeriod)[1], barmerge.gaps_off, barmerge.lookahead_off)
    tfHigh != tfLow ? (((close[1] - tfLow) / (tfHigh - tfLow)) * 100.0) - 50.0 : 0.0

// Indicator Calculations
value5M = scoreFromRange("5")
value15M = scoreFromRange("15")
value1H = scoreFromRange("60")
value4H = scoreFromRange("240")
value1D = scoreFromRange("D")
value1W = scoreFromRange("W")

totalWeight = importance5M + importance15M + importance1H + importance4H + importance1D + importance1W

totalRank = (
     value5M * importance5M +
     value15M * importance15M +
     value1H * importance1H +
     value4H * importance4H +
     value1D * importance1D +
     value1W * importance1W) / totalWeight

// Signal Logic
buySignal = totalRank > sensitivity
sellSignal = totalRank < 0
neutralSignal = not buySignal and not sellSignal

// Plot Lines
plot(showScoreLine ? totalRank : na, "Total Score", color=scoreColor, linewidth=2, display=display.data_window)
plot(value5M, "5M Score", display=display.data_window)
plot(value15M, "15M Score", display=display.data_window)
plot(value1H, "1H Score", display=display.data_window)
plot(value4H, "4H Score", display=display.data_window)
plot(value1D, "1D Score", display=display.data_window)
plot(value1W, "1W Score", display=display.data_window)
plot(float(sensitivity), "Long Threshold", color=color.new(buyColor, 60), display=display.data_window)
plot(0.0, "Short Threshold", color=color.new(sellColor, 60), display=display.data_window)

// Background
bgColor = buySignal ? color.new(color.rgb(0, 120, 255), 92) : sellSignal ? color.new(color.rgb(255, 70, 90), 92) : color.new(neutralColor, 97)
bgcolor(showBackground ? bgColor : na)

// Signals
plotshape(buySignal and not showText, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small)
plotshape(sellSignal and not showText, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small)

plotshape(buySignal and showText, title="Buy Signal Text", style=shape.triangleup, location=location.belowbar, color=buyColor, size=size.small, text="BUY")
plotshape(sellSignal and showText, title="Sell Signal Text", style=shape.triangledown, location=location.abovebar, color=sellColor, size=size.small, text="SELL")

// Alerts
alertcondition(buySignal, title="Buy Alert", message="Multi Time Score Buy Signal")
alertcondition(sellSignal, title="Sell Alert", message="Multi Time Score Sell Signal")
````

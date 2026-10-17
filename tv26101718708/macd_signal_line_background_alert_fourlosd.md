# MACD Signal Line Background + Alert

- url: https://www.tradingview.com/script/FOUrloSd/
- type: indicator
- pine_id: PUB;cb601065da934ba5b1083c1a67b63499
- version: 1.0

## Description

█ OVERVIEW

This indicator colors the chart background based on whether the MACD signal line is above or below the zero line.

Green background: Signal line is above 0 (bullish)
Red background: Signal line is below 0 (bearish)

No need to watch the MACD panel — just glance at the chart background to know the current trend bias.

█ HOW IT WORKS

• Uses standard MACD settings (12, 26, 9)
• Background turns green when the signal line is above zero
• Background turns red when the signal line is below zero
• Background color transparency is set to 90% so it does not interfere with your candles

█ ALERTS

Two alert conditions are included:

• Signal Line Cross Above 0 Alert — triggers when the signal line crosses above zero (bullish shift)
• Signal Line Cross Below 0 Alert — triggers when the signal line crosses below zero (bearish shift)

█ NOTES

• This indicator tracks the MACD signal line (EMA of the MACD line), not the MACD line itself
• The signal line reacts more slowly than the MACD line, which can reduce false signals
• For MACD line-based background coloring, see my other script: MACD Zero Line Background + Alert
• You can customize the background colors in the Style settings

## Source Code

````pine
//@version=6
indicator("MACD Signal Line Background + Alert", overlay=true)

// Get MACD values
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// Color background based on signal line position relative to zero
bgcolor(signalLine > 0 ? color.new(color.green, 90) : color.new(color.red, 90))

// Zero line cross conditions
signalBullish = ta.crossover(signalLine, 0)
signalBearish = ta.crossunder(signalLine, 0)

// Alerts
alertcondition(signalBullish, title="Signal Line Cross Above 0 Alert", message="MACD signal line crossed above 0")
alertcondition(signalBearish, title="Signal Line Cross Below 0 Alert", message="MACD signal line crossed below 0")
````

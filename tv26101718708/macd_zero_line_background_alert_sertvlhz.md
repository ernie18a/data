# MACD Zero Line Background + Alert

- url: https://www.tradingview.com/script/SErTvLHz/
- type: indicator
- pine_id: PUB;63210b0cfc5648f781dfaf50511353f1
- version: 1.0

## Description

█ OVERVIEW

This indicator colors the chart background based on whether the MACD line is above or below the zero line.

Green background: MACD line is above 0 (bullish)
Red background: MACD line is below 0 (bearish)

No need to watch the MACD panel — just glance at the chart background to know the current trend bias.

█ HOW IT WORKS

• Uses standard MACD settings (12, 26, 9)
• Background turns green when the MACD line is above zero
• Background turns red when the MACD line is below zero
• Background color transparency is set to 90% so it does not interfere with your candles

█ ALERTS

Two alert conditions are included:

• MACD Line Cross Above 0 Alert — triggers when MACD line crosses above zero (bullish shift)
• MACD Line Cross Below 0 Alert — triggers when MACD line crosses below zero (bearish shift)

█ NOTES

• This indicator tracks the MACD line (fast EMA minus slow EMA), not the signal line
• For signal line-based background coloring, see my other script: MACD Signal Line Background + Alert
• You can customize the background colors in the Style settings

## Source Code

````pine
//@version=6
indicator("MACD Zero Line Background + Alert", overlay=true)

// Get MACD values
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// Color background based on MACD line position relative to zero
bgcolor(macdLine > 0 ? color.new(color.green, 90) : color.new(color.red, 90))

// Zero line cross conditions
macdBullish = ta.crossover(macdLine, 0)
macdBearish = ta.crossunder(macdLine, 0)

// Alerts
alertcondition(macdBullish, title="MACD Line Cross Above 0 Alert", message="MACD line crossed above 0")
alertcondition(macdBearish, title="MACD Line Cross Below 0 Alert", message="MACD line crossed below 0")
````

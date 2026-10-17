# MACD Zero Line Candles + Alert

- url: https://www.tradingview.com/script/oscKJ0Lq/
- type: indicator
- pine_id: PUB;b2686fd8016c4c50bf81aa4dd6a9d291
- version: 1.0

## Description

█ OVERVIEW

This indicator recolors your candles based on whether the MACD line is above or below the zero line.

Green candles: MACD line is above 0 (bullish)
Red candles: MACD line is below 0 (bearish)

No need to watch the MACD panel — the candle color tells you the trend bias at a glance.

█ HOW IT WORKS

• Uses standard MACD settings (12, 26, 9)
• Candles turn green when the MACD line is above zero
• Candles turn red when the MACD line is below zero

█ ALERTS

Two alert conditions are included:

• MACD Line Cross Above 0 Alert — triggers when the MACD line crosses above zero (bullish shift)
• MACD Line Cross Below 0 Alert — triggers when the MACD line crosses below zero (bearish shift)

█ NOTES

• This indicator tracks the MACD line (fast EMA minus slow EMA), not the signal line
• For signal line-based candle coloring, see my other script: MACD Signal Line Candles + Alert
• For zero line-based background coloring instead of candle coloring, see my other script: MACD Zero Line Background + Alert

## Source Code

````pine
//@version=6
indicator("MACD Zero Line Candles + Alert", overlay=true)

// Get MACD values
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// Recolor candles based on MACD line position relative to zero
barcolor(macdLine > 0 ? color.green : color.red)

// Zero line cross conditions
macdBullish = ta.crossover(macdLine, 0)
macdBearish = ta.crossunder(macdLine, 0)

// Alerts
alertcondition(macdBullish, title="MACD Line Cross Above 0 Alert", message="MACD line crossed above 0")
alertcondition(macdBearish, title="MACD Line Cross Below 0 Alert", message="MACD line crossed below 0")
````

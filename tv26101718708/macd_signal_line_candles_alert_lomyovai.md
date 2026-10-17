# MACD Signal Line Candles + Alert

- url: https://www.tradingview.com/script/lOMYovAi/
- type: indicator
- pine_id: PUB;a56a93c7ed624d1fb151a339dcd7ce00
- version: 1.0

## Description

█ OVERVIEW

This indicator recolors your candles based on whether the MACD signal line is above or below the zero line.

Green candles: Signal line is above 0 (bullish)
Red candles: Signal line is below 0 (bearish)

No need to watch the MACD panel — the candle color tells you the trend bias at a glance.

█ HOW IT WORKS

• Uses standard MACD settings (12, 26, 9)
• Candles turn green when the signal line is above zero
• Candles turn red when the signal line is below zero
• Wick color matches the candle body color

█ ALERTS

Two alert conditions are included:

• Signal Line Cross Above 0 Alert — triggers when the signal line crosses above zero (bullish shift)
• Signal Line Cross Below 0 Alert — triggers when the signal line crosses below zero (bearish shift)

█ NOTES

• If the colored candles are hidden behind the original candles, go to the indicator settings and set the display order to "Bring to Front"
• You can customize the candle, wick, and border colors in the Style settings
• This indicator tracks the MACD signal line, not the MACD line itself
• For signal line-based background coloring instead of candle coloring, see my other script: MACD Signal Line Background + Alert
• For zero line-based candle coloring, see my other script: MACD Zero Line Candles + Alert

## Source Code

````pine
//@version=6
indicator("MACD Signal Line Candles + Alert", overlay=true)

// Get MACD values
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// Recolor candles based on signal line position relative to zero
barcolor(signalLine > 0 ? color.green : color.red)

// Zero line cross conditions
signalBullish = ta.crossover(signalLine, 0)
signalBearish = ta.crossunder(signalLine, 0)

// Alerts
alertcondition(signalBullish, title="Signal Line Cross Above 0 Alert", message="MACD signal line crossed above 0")
alertcondition(signalBearish, title="Signal Line Cross Below 0 Alert", message="MACD signal line crossed below 0")
````

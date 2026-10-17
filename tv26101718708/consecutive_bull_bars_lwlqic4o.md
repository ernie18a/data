# Consecutive Bull Bars

- url: https://www.tradingview.com/script/lWLqIC4O-Consecutive-Bull-Bars/
- type: indicator
- pine_id: PUB;8d7b5703d432424dbfdbbf6f57c5af44
- version: 1.0

## Description

[b]Introduction[/b]
Consecutive Bull Bars is a simple price action indicator that counts the number of consecutive bullish candlesticks.

Rather than measuring trend using moving averages or oscillators, this indicator focuses directly on candle behavior, providing a straightforward view of buying persistence.

A growing count indicates that buyers continue to close each candle above its opening price without interruption.

[b]How It Works[/b]
The indicator checks each completed candle.

If the candle closes above its opening price, the counter increases by one.

If a bearish candle appears, the counter immediately resets to zero.

The histogram displays the current number of consecutive bullish candles.

[b]Key Features[/b]
[i]Buying Persistence[/i]
Measures how consistently buyers have controlled recent candles.

[i]Easy Interpretation[/i]
Higher values indicate stronger bullish persistence.

[i]Price Action Based[/i]
Uses only candlestick data without relying on moving averages or oscillators.

[i]Lightweight[/i]
Very efficient and suitable for every market and timeframe.

[b]Interpretation[/b]
[i]0[/i]
No active bullish sequence.

[i]1–2 Bars[/i]
Normal buying activity.
Short bullish movement without strong confirmation.

[i]3–4 Bars[/i]
Moderate bullish persistence.
Buying pressure is becoming more consistent.

[i]5 Bars or More[/i]
Strong bullish persistence.
Buyers have maintained control across several consecutive candles.

[b]Alert Conditions[/b]
The indicator includes two alerts.
[i]3 Consecutive Bull Bars[/i]
Signals the beginning of sustained buying pressure.

[i]5 Consecutive Bull Bars[/i]
Highlights extended bullish persistence.

[b]Example Applications[/b]
- Measuring buying pressure.
- Confirming breakout strength.
- Supporting trend analysis.
- Monitoring market persistence.
- Combining with support and resistance.

[b]Notes[/b]
Consecutive Bull Bars measures the consistency of bullish candles rather than the magnitude of price movement.

Several small bullish candles may produce the same reading as several large bullish candles.
For best results, combine this indicator with market structure, trend analysis, and volatility indicators.

Consecutive Bull Bars provides a simple visualization of buying persistence by counting uninterrupted bullish candlesticks, helping traders monitor short-term market strength.

## Source Code

````pine
//@version=6
indicator("Consecutive Bull Bars", shorttitle="Bull Bars", overlay=false)

//------------------------------------------------------------------------------
// Calculation
//------------------------------------------------------------------------------
var int bullCount = 0

bullCount := close > open ? nz(bullCount[1]) + 1 : 0

//------------------------------------------------------------------------------
// Colors
//------------------------------------------------------------------------------
barColor =
     bullCount >= 5 ? color.lime :
     bullCount >= 3 ? color.green :
     bullCount >= 1 ? color.new(color.green, 40) :
     color.gray

//------------------------------------------------------------------------------
// Plot
//------------------------------------------------------------------------------
plot(
     bullCount,
     title="Consecutive Bull Bars",
     style=plot.style_columns,
     linewidth=2,
     color=barColor)

hline(3, "Moderate Strength", color=color.new(color.green, 75))
hline(5, "Strong Strength", color=color.new(color.lime, 75))

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(
     bullCount == 3,
     title="3 Consecutive Bull Bars",
     message="Three consecutive bullish candles detected.")

alertcondition(
     bullCount == 5,
     title="5 Consecutive Bull Bars",
     message="Five consecutive bullish candles detected.")
````

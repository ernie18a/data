# Candle Type Colorizer

- url: https://www.tradingview.com/script/FV87B5d9-Candle-Type-Colorizer/
- type: indicator
- pine_id: PUB;db73d0b5df314ab9b7f0369ed1b3007a
- version: 1.0

## Description

Candle Type Colorizer

The Candle Type Colorizer is a simple yet powerful price action indicator that automatically classifies and colors candles based on their relationship with the previous candle’s range.

It helps traders quickly identify:

Expansion candles
Contraction candles
Neutral price action
Volatile range expansion

This makes market structure and short-term momentum easier to read directly from the chart without manually analyzing every bar.

Candle Definitions
🟢 Impulse Candle (Green)

A candle is classified as an Impulse Candle when:

Current High > Previous High
Current Low ≥ Previous Low

This represents bullish range expansion and directional strength.

🔴 Corrective Candle (Red)

A candle is classified as a Corrective Candle when:

Current Low < Previous Low
Current High ≤ Previous High

This represents bearish correction or downside pressure.

⚫ Inside / Neutral Candle (Black)

A candle is classified as an Inside Candle when:

Current High ≤ Previous High
Current Low ≥ Previous Low

This indicates contraction, consolidation, or temporary balance between buyers and sellers.

🔵 Volatile Candle (Blue)

A candle is classified as a Volatile Candle when:

Current High > Previous High
Current Low < Previous Low

This is an outside-range candle showing increased volatility and two-sided expansion.

Key Benefits
Instantly visualize market structure
Identify momentum vs contraction phases
Spot volatility expansion bars quickly
Useful for price action, breakout, and trend-following traders
Works on all markets and timeframes
Best Use Cases
Trend continuation analysis
Base structure analysis
Volatility contraction/expansion studies
Breakout trading
Multi-timeframe price action analysis
Notes
The indicator is purely price-action based.
No lagging indicators or moving averages are used.
Candle classification is based entirely on comparison with the previous candle’s high and low.

## Source Code

````pine
//@version=6
indicator("Candle Type Colorizer", overlay=true)

// === Previous Candle Values ===
prevHigh = high[1]
prevLow  = low[1]

// === Candle Type Conditions ===

// Impulse Candle
impulse =
     high > prevHigh and
     low >= prevLow

// Corrective Candle
corrective =
     low < prevLow and
     high <= prevHigh

// Inside / Neutral Candle
inside =
     high <= prevHigh and
     low >= prevLow

// Volatile Candle (Outside Bar)
volatile =
     high > prevHigh and
     low < prevLow

// === Assign Colors ===
candleColor =
     volatile ? color.blue :
     impulse ? color.green :
     corrective ? color.red :
     inside ? color.black :
     color.gray

// === Paint Candles ===
barcolor(candleColor)

// Optional Labels for Debugging
plotshape(impulse, title="Impulse", style=shape.circle, location=location.abovebar, color=color.green, size=size.tiny)
plotshape(corrective, title="Corrective", style=shape.circle, location=location.belowbar, color=color.red, size=size.tiny)
plotshape(inside, title="Inside", style=shape.circle, location=location.bottom, color=color.black, size=size.tiny)
plotshape(volatile, title="Volatile", style=shape.circle, location=location.top, color=color.blue, size=size.tiny)
````

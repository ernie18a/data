# Mr Balwants EMAs

- url: https://www.tradingview.com/script/4yBrdfvJ-Mr-Balwants-EMAs/
- type: indicator
- pine_id: PUB;3cf4f838f98f4e8aae3d72b054cd402c
- version: 1.0

## Description

EMA Trend Matrix

This indicator combines six widely used Exponential Moving Averages (EMAs): 9, 21, 34, 50, 100, and 200.

The purpose of this indicator is to help traders quickly assess market structure, momentum, and trend direction without adding multiple EMA indicators separately to their charts.

Included EMAs:
• EMA 9 – Short-term momentum
• EMA 21 – Intraday trend
• EMA 34 – Trend continuation reference
• EMA 50 – Medium-term trend filter
• EMA 100 – Major trend reference
• EMA 200 – Long-term market direction

This indicator can be used for:
• Trend identification
• Dynamic support and resistance
• Trend alignment analysis
• Pullback trading
• Market bias filtering

Bullish conditions are generally stronger when shorter-period EMAs are positioned above longer-period EMAs. Bearish conditions are generally stronger when shorter-period EMAs are positioned below longer-period EMAs.

This indicator is intended as a trend-analysis tool and should be used alongside proper risk management and price action analysis.

## Source Code

````pine
//@version=6
indicator("Mr Balwants EMAs", overlay=true)

// EMA Calculations
ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
ema34  = ta.ema(close, 34)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// Plot EMAs
plot(ema9,   title="EMA 9",   linewidth=2)
plot(ema21,  title="EMA 21",  linewidth=2)
plot(ema34,  title="EMA 34",  linewidth=2)
plot(ema50,  title="EMA 50",  linewidth=2)
plot(ema100, title="EMA 100", linewidth=2)
plot(ema200, title="EMA 200", linewidth=3)
````

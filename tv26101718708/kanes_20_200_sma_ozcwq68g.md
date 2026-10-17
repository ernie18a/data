# Kane's 20 & 200 SMA

- url: https://www.tradingview.com/script/OZcwq68g-Kane-s-20-200-SMA/
- type: indicator
- pine_id: PUB;76afaee659084ac9942eceac09dd8d85
- version: 1.0

## Description

Kane's 20 & 200 SMA

A clean and lightweight dual moving average indicator designed for trend direction, market structure, and long-term bias analysis.

Features:

20 SMA in Yellow
200 SMA in Violet
Smooth overlay directly on price
Minimal chart clutter
Lightweight and responsive on all timeframes

Common Uses:

Identify overall market trend
Determine bullish vs bearish bias
Spot trend continuation setups
Find pullbacks into dynamic support/resistance
Track trend alignment between short and long-term structure

General Interpretation:

20 SMA above 200 SMA = bullish conditions
20 SMA below 200 SMA = bearish conditions
Strong separation can indicate momentum
Compression between averages can indicate consolidation or transition

Works on:

Stocks
Futures
Forex
Crypto
Indices
Gold & Silver

Fully customizable lengths, colors, and line thicknesses in settings.

## Source Code

````pine
//@version=6
indicator("Kane's 20 & 200 SMA", overlay=true)

plot(
    ta.sma(close, 20),
    title="20 SMA",
    color=color.yellow,
    linewidth=2
)

plot(
    ta.sma(close, 200),
    title="200 SMA",
    color=#9400D3,
    linewidth=2
)
````

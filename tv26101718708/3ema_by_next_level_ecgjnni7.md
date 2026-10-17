# 3EMA by Next Level

- url: https://www.tradingview.com/script/ecGJnni7-3EMA-by-Next-Level/
- type: indicator
- pine_id: PUB;b5f7afade0844a62b8f674c8ee6d4840
- version: 2.0

## Description

This indicator plots the 3 Exponential Moving Averages - 50, 100, and 200 EMA directly on your price chart.

This will help you quickly identify trend direction, dynamic support and resistance levels, and potential entry or exit zones.

Color coding:

🟢 EMA 50 — Short-term trend
🟠 EMA 100 — Medium-term trend
🔴 EMA 200 — Long-term trend

How to use it:

Price above all 3 EMAs = bullish structure
Price below all 3 EMAs = bearish structure
Watch for EMA crossovers as early trend shift signals
The 200 EMA is the most important line — it separates bull and bear markets

All three lengths are fully adjustable in the settings. Works on any timeframe and any asset class.

By Next Level Academy

## Source Code

````pine
//@version=6
indicator(title="3EMA by Next Level", shorttitle="3EMA by Next Level", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
len50  = input.int(50,  title="EMA 50 Length")
len100 = input.int(100, title="EMA 100 Length")
len200 = input.int(200, title="EMA 200 Length")

src = input.source(close, title="Source")

// ─── Calculations ─────────────────────────────────────────────────────────────
ema50  = ta.ema(src, len50)
ema100 = ta.ema(src, len100)
ema200 = ta.ema(src, len200)

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(ema50,  title="EMA 50",  color=color.new(#00C853, 0), linewidth=1)
plot(ema100, title="EMA 100", color=color.new(#FF6D00, 0), linewidth=1)
plot(ema200, title="EMA 200", color=color.new(#E53935, 0), linewidth=1)
````

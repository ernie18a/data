# Multi EMA (5, 13, 26, 50, 100, 200)

- url: https://www.tradingview.com/script/PYzWBXai-Multi-EMA-5-13-26-50-100-200/
- type: indicator
- pine_id: PUB;d8a75ff7d48246e9aca8f4fd06af7f5a
- version: 1.0

## Description

This is a single indicator which plots EMA 5,13,26,50,100 and 200

## Source Code

````pine
//@version=6
indicator("Multi EMA (5, 13, 26, 50, 100, 200)", overlay=true)

// --- Inputs ---
src = input(close, title="Source")

// Define lengths and colors
ema5_len = input.int(5,   minval=1, title="EMA 5 Length")
ema13_len = input.int(13,  minval=1, title="EMA 13 Length")
ema26_len  = input.int(26,  minval=1, title="EMA 26 Length")
ema50_len  = input.int(50,  minval=1, title="EMA 50 Length")
ema100_len = input.int(100, minval=1, title="EMA 100 Length")
ema200_len = input.int(200, minval=1, title="EMA 200 Length")

// --- Calculations ---
ema5   = ta.ema(src, ema5_len)
ema13  = ta.ema(src, ema13_len)
ema26  = ta.ema(src, ema26_len)
ema50  = ta.ema(src, ema50_len)
ema100 = ta.ema(src, ema100_len)
ema200 = ta.ema(src, ema200_len)

// --- Plotting ---
plot(ema200,   title="EMA 200",   color=color.new(#08e0f4, 17), linewidth=2) // Yellow
plot(ema100,  title="EMA 100",  color=color.new(#ef09cd, 0), linewidth=2) // Orange
plot(ema50,  title="EMA 50",  color=color.new(#181818, 0), linewidth=2) // Pink
plot(ema26,  title="EMA 26",  color=color.new(#FF9800, 0), linewidth=2) // Red
plot(ema13, title="EMA 13", color=color.new(#2196F3, 0), linewidth=2) // Blue
plot(ema5, title="EMA 5", color=color.new(#4CAF50, 0), linewidth=2) // Green
````

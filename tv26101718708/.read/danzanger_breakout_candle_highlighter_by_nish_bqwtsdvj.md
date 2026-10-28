# DanZanger breakout candle highlighter by Nish

- url: https://www.tradingview.com/script/bQwTSdvJ-DanZanger-breakout-candle-highlighter-by-Nish/
- type: indicator
- pine_id: PUB;bc925bbe09a24beba0039a13f8030465
- version: 1.0

## Description

This indicator highlights candles where volume expands above normal levels, inspired by Dan Zanger’s breakout methodology.
It is designed for traders who want a simple, visual way to spot potential breakout activity based on unusual volume — without needing to manually check the volume panel.

[list]
[*]Calculates the 20‑period average volume (customizable)
[*]Compares current volume to a user‑defined multiplier
[*]Highlights candles yellow when volume exceeds the threshold
[*]Optionally filters signals to only show bullish (green) candles
[*]Plots a small triangle marker below qualifying candles for clarity
[/list]

## Source Code

````pine
//@version=6
indicator("DanZanger breakout candle highlighter by Nish", overlay=true)

// --- Inputs ---
volLength = input.int(20, title="Volume MA Length")
volMult = input.float(2.0, title="Volume Multiplier (e.g., 2.0 = Double)", step=0.1)
usePriceFilter = input.bool(true, title="Only highlight Green (Up) candles?")

// --- Calculations ---
volAvg = ta.sma(volume, volLength)
// Check if volume is at least X times the 20-period average
isHighVolume = volume >= (volAvg * volMult)
// Check if it's a bullish candle (Close > Open)
isBullish = close > open

// --- Logic ---
// Trigger if volume is high. If price filter is on, also require a green candle.
zangerSignal = isHighVolume and (usePriceFilter ? isBullish : true)

// --- Coloring ---
// Define colors: Yellow for the signal, otherwise 'na' (keeps original candle colors)
candleColor = zangerSignal ? color.new(#ffeb3b, 0) : na

// This command overrides the candle color on the chart
barcolor(candleColor)

// Optional: Add a small label or shape below the bar for extra clarity
plotshape(zangerSignal, style=shape.triangleup, location=location.belowbar, color=color.new(#ffeb3b, 0), size=size.small, title="Zanger Breakout")
````

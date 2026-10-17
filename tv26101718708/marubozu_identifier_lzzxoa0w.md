# Marubozu Identifier

- url: https://www.tradingview.com/script/LZZxoA0w-Marubozu-Identifier/
- type: indicator
- pine_id: PUB;d4b4d35c92054ce985793a7c38fc6f2e
- version: 1.0

## Description

Power Candles... Wickless. 

Use these to identify coming moves.

## Source Code

````pine
//@version=6
indicator("Marubozu Identifier", overlay=true)

// --- Inputs ---
grp_settings = "Marubozu Parameters"
// Default is set to 2% tolerance. Change to 0% if you only want mathematically perfect Marubozus.
wickThresholdPct = input.float(2.0, title="Max Allowed Wick Size (%)", step=0.5, group=grp_settings, tooltip="Maximum allowed size of the combined wicks relative to the total candle range. Set to 0 for strict no-wick candles.") / 100

// --- Calculations ---
// 1. Define the overall sizes
candleRange = high - low

// 2. Calculate the wicks
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
totalWickSize = upperWick + lowerWick

// --- Logic ---
// Ensure the candle actually has range, then check if the total wick size is within our threshold
isMarubozu = candleRange > 0 and (totalWickSize <= (candleRange * wickThresholdPct))

// Determine direction
isBullish = close > open
isBearish = close < open

// Final trigger conditions
bullishMarubozu = isMarubozu and isBullish
bearishMarubozu = isMarubozu and isBearish

// --- Visuals ---
// Print the labels above or below the detected candles
plotshape(bullishMarubozu, title="Bullish Marubozu", style=shape.labelup, location=location.belowbar, color=color.green, text="Bullish", textcolor=color.white, size=size.small)
plotshape(bearishMarubozu, title="Bearish Marubozu", style=shape.labeldown, location=location.abovebar, color=color.red, text="Bearish", textcolor=color.white, size=size.small)
````

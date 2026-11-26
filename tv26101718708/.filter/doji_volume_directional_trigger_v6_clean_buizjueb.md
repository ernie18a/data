# Doji Volume Directional Trigger (v6 Clean)

- url: https://www.tradingview.com/script/BuizJuEB-Doji-Volume-Directional-Trigger-v6-Clean/
- type: indicator
- pine_id: PUB;c234a16cf3fd4b62a3e701b58eba2b4c
- version: 1.0

## Description

Doji Volume Directional Trigger identifies high-probability momentum shifts by looking for a specific three-part confirmation on the close of a bar:

- The Candlestick: A clear Doji pattern (tight body relative to its full range).

- The Color Flip: A sudden direction change (e.g., a green Doji immediately following a red candle).

- The Volume Surge: Confirming institutional presence by requiring current volume to exceed the previous bar.

Perfect for catching explosive reversals and breakouts early on any timeframe. Includes built-in visual shapes and standard alert triggers.

## Source Code

````pine
//@version=6
indicator("Doji Volume Directional Trigger (v6 Clean)", overlay=true)

// --- Inputs ---
dojiThreshold = input.float(0.10, title="Doji Body Threshold (Max % of Total Range)", minval=0.01, maxval=0.50, step=0.01)

// --- Calculations ---
candleRange = high - low
bodySize = math.abs(close - open)

// 1. The Beacon: Is the current candle a Doji?
isDoji = candleRange > 0 and (bodySize / candleRange) <= dojiThreshold

// 2. Volume Surge: Current volume is higher than the last bar
volumeSurge = volume > volume[1]

// 3. Direction Identification
isCurrentGreen  = close > open
isCurrentRed    = close < open
isPreviousGreen = close[1] > open[1]
isPreviousRed   = close[1] < open[1]

// 4. Split Trigger Logic
// Long: Previous bar was Red (selling volume), Doji flips to Green (buying volume) and is higher
longTrigger  = isDoji and volumeSurge and isPreviousRed and isCurrentGreen

// Short: Previous bar was Green (buying volume), Doji flips to Red (selling volume) and is higher
shortTrigger = isDoji and volumeSurge and isPreviousGreen and isCurrentRed

// --- Visuals ---
// Plot Green Triangle below the bar for Longs
plotshape(series=longTrigger, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="VOL LONG")
bgcolor(longTrigger ? color.new(color.green, 90) : na)

// Plot Red Triangle above the bar for Shorts
plotshape(series=shortTrigger, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="VOL SHORT")
bgcolor(shortTrigger ? color.new(color.red, 90) : na)

// --- Alerts ---
alertcondition(longTrigger, title="Doji Long Alert", message="Doji Vol Long Trigger on {{ticker}} ({{interval}})")
alertcondition(shortTrigger, title="Doji Short Alert", message="Doji Vol Short Trigger on {{ticker}} ({{interval}})")
````

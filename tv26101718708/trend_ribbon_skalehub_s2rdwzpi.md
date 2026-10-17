# Trend Ribbon [SkaleHub]

- url: https://www.tradingview.com/script/S2rDwzPi-Trend-Ribbon-SkaleHub/
- type: indicator
- pine_id: PUB;ff6252b4233e44bc8864f6880520ab23
- version: 1.0

## Description

Overview
A highly visual, simplified moving average ribbon. It tracks the space between a fast and slow moving average to determine trend strength.

The Edge
The ribbon dynamically fades in color as the short-term trend loses momentum, giving traders a smooth, action-oriented look into shifts in market power.

Key Features:

Visual Directional Bias: Instantly identifies macro trend direction with clear color-coding.

Dynamic Momentum Fading: Ribbon transparency shifts automatically to warn you when a trend is losing steam.

Late-Entry Prevention: Visually systemizes the chart so you don't chase moves that are already exhausted.

[b]How to Use[/b]

Apply the indicator to your chart. 

Monitor the overall color of the ribbon to determine your directional bias (Green for longs, Red for shorts). 

Watch for the color to fade (e.g., from bright green to dark green); this is your visual warning that short-term momentum is stalling and to avoid late entries. 

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Trend Ribbon [SkaleHub]", overlay=true)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
fastLength = input.int(9, title="Fast EMA Length", group="Ribbon Settings")
slowLength = input.int(21, title="Slow EMA Length", group="Ribbon Settings")

colorBullStrong = input.color(color.new(#00ff00, 40), title="Strong Bullish", group="Visuals")
colorBullWeak   = input.color(color.new(#00ff00, 80), title="Fading Bullish", group="Visuals")
colorBearStrong = input.color(color.new(#ff0000, 40), title="Strong Bearish", group="Visuals")
colorBearWeak   = input.color(color.new(#ff0000, 80), title="Fading Bearish", group="Visuals")

// =========================================================================
// 2. RIBBON CALCULATIONS
// =========================================================================
// Calculate the Fast and Slow Exponential Moving Averages
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)

// Determine Macro Trend Direction
isBullish = fastEMA > slowEMA
isBearish = fastEMA < slowEMA

// Determine Short-Term Momentum (Is the fast EMA accelerating or decelerating?)
fastRising  = fastEMA > fastEMA[1]
fastFalling = fastEMA < fastEMA[1]

// =========================================================================
// 3. DYNAMIC FADING LOGIC
// =========================================================================
// Assign the fill color based on both trend direction and momentum
ribbonColor = if isBullish and fastRising
    colorBullStrong
else if isBullish and fastFalling
    colorBullWeak
else if isBearish and fastFalling
    colorBearStrong
else if isBearish and fastRising
    colorBearWeak
else
    color.new(color.gray, 80) // Neutral fallback

// =========================================================================
// 4. VISUAL PLOTTING
// =========================================================================
// Plot the invisible boundary lines to hold the fill
plotFast = plot(fastEMA, title="Fast EMA", color=color.new(color.gray, 100))
plotSlow = plot(slowEMA, title="Slow EMA", color=color.new(color.gray, 100))

// Fill the space between the two EMAs with the dynamic momentum color
fill(plotFast, plotSlow, color=ribbonColor, title="Ribbon Fill")
````

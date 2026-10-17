# Volatility Bands [SkaleHub]

- url: https://www.tradingview.com/script/79mlX2Yh-Volatility-Bands-SkaleHub/
- type: indicator
- pine_id: PUB;6e5e3869bd37418f994a108b5b1793ad
- version: 1.0

## Description

Overview
A clean, branded take on standard volatility bounds. It gently shades the extreme overbought or oversold edges of your chart.

The Edge
It serves as a visual guardrail, training beginners not to buy at the absolute top of a massive run and protecting capital during overextended market conditions.

Key Features:

Extreme Zone Highlighting: Visually shades the outer edges of price action (Red for overbought, Green for oversold) to easily identify stretched markets.

Capital Protection Guardrails: Prevents developing traders from chasing late breakouts by warning them when the market is heavily overextended.

Clean Visuals: Strips away the noise of complex standard deviation lines, leaving just the soft, actionable boundary zones.

How to Use

Apply the indicator to your chart.

Watch for the current price to enter the shaded upper (Red) or lower (Green) extremes.

Avoid entering new positions in the direction of the trend when price is deep in these shaded zones, as the move is mathematically overextended and likely to pull back.

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Volatility Bands [SkaleHub]", overlay=true)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
length = input.int(20, title="Band Length", minval=1, group="Band Settings")
mult = input.float(2.0, title="Volatility Multiplier", minval=0.1, maxval=10, group="Band Settings")

colorUpper = input.color(color.new(#ff0000, 85), title="Overbought Shading", group="Visuals")
colorLower = input.color(color.new(#00ff00, 85), title="Oversold Shading", group="Visuals")
lineColor  = input.color(color.new(color.gray, 60), title="Band Borders", group="Visuals")

// =========================================================================
// 2. MATH & LOGIC
// =========================================================================
// Calculate the Simple Moving Average and Standard Deviation
basis = ta.sma(close, length)
dev = mult * ta.stdev(close, length)

// Define the standard volatility boundaries
upperBand = basis + dev
lowerBand = basis - dev

// Define an "extreme" outer boundary purely to anchor the visual shading
upperExtreme = basis + (dev * 1.25)
lowerExtreme = basis - (dev * 1.25)

// =========================================================================
// 3. VISUAL PLOTTING & SHADING
// =========================================================================
// Plot the visible inner borders of the volatility bands
p_upper = plot(upperBand, color=lineColor, title="Upper Band")
p_lower = plot(lowerBand, color=lineColor, title="Lower Band")

// Plot invisible outer boundaries
p_upperExt = plot(upperExtreme, color=color.new(color.white, 100), title="Upper Extreme", display=display.none)
p_lowerExt = plot(lowerExtreme, color=color.new(color.white, 100), title="Lower Extreme", display=display.none)

// Shade the extreme overbought and oversold edges of the chart
fill(p_upper, p_upperExt, color=colorUpper, title="Overbought Zone")
fill(p_lower, p_lowerExt, color=colorLower, title="Oversold Zone")
````

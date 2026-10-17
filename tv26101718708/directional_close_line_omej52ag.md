# Directional Close Line

- url: https://www.tradingview.com/script/OmeJ52AG-Directional-Close-Line/
- type: indicator
- pine_id: PUB;0e18cebd65224f7d9d95b870fe7deb14
- version: 1.0

## Description

**Directional Close Line**

This indicator connects candle closes to visualize price movement in a clean and structured way.

Instead of reacting to every candle individually, it groups consecutive movements into a single directional run:

• When price closes higher than the previous candle, the line continues upward
• When price closes lower, a new downward line begins
• The line only changes direction when a true reversal in closing price occurs

Key Features:

* Connects close-to-close only (ignores wicks and noise)
* Displays one continuous line per directional move
* Clearly highlights momentum and trend structure
* Helps identify clean runs and reversals in price action

This tool is useful for traders who focus on:

* Momentum tracking
* Breakout structure
* Trend clarity without candle noise

Designed for simplicity, clarity, and real market structure.

## Source Code

````pine
//@version=5
indicator("Directional Close Line", overlay=true)

// Direction
up   = close > close[1]
down = close < close[1]

// Create line value
lineValue = close

// Plot with color based on direction
plot(lineValue,
     color = up ? color.green : down ? color.red : color.gray,
     linewidth = 2,
     style = plot.style_line)
````

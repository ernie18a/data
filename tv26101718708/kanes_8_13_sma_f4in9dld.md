# Kane's 8 & 13 SMA

- url: https://www.tradingview.com/script/F4in9dld-Kane-s-8-13-SMA/
- type: indicator
- pine_id: PUB;6ab067d01d1c4119affb9a0a61c92347
- version: 1.0

## Description

Kane's 8 & 13 SMA

A clean dual moving average indicator built for fast trend visualization and momentum trading.

Features:

8 SMA in Neon Green
13 SMA in Neon Pink
Ultra-thin lines for minimal chart clutter
Simple and lightweight for scalping, day trading, and momentum trading
Fully customizable colors, lengths, and thickness settings

Designed to help quickly identify:

Short-term trend direction
Momentum shifts
Pullbacks and continuation moves
Crossovers and compression between fast moving averages

Works on all markets and timeframes including stocks, futures, forex, crypto, gold, and indices.

## Source Code

````pine
//@version=6
indicator("Kane's 8 & 13 SMA", overlay=true)

// Inputs
sma8Length  = input.int(8, title="8 SMA Length")
sma13Length = input.int(13, title="13 SMA Length")

// Neon Colors
sma8Color   = input.color(color.rgb(57, 255, 20), title="8 SMA Color")     // Neon Green
sma13Color  = input.color(color.rgb(255, 20, 147), title="13 SMA Color")   // Neon Pink

// Thinnest Line
lineWidth = input.int(1, title="Line Thickness", minval=1, maxval=5)

// Calculations
sma8  = ta.sma(close, sma8Length)
sma13 = ta.sma(close, sma13Length)

// Plots
plot(sma8,  title="8 SMA",  color=sma8Color,  linewidth=lineWidth)
plot(sma13, title="13 SMA", color=sma13Color, linewidth=lineWidth)
````

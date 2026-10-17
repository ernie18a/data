# 8 EMA Slope Background

- url: https://www.tradingview.com/script/YILrQwJE-8-EMA-Slope-Background/
- type: indicator
- pine_id: PUB;0e443341ebd04ae3bd949519f754e539
- version: 1.0

## Description

Shows the color coded up or down slope of 8 EMA in the background

## Source Code

````pine
//@version=6
indicator("8 EMA Slope Background", shorttitle="EMA8 Slope BG", overlay=true)

// === Inputs ===
ema8Len   = input.int(8,  "EMA 8 Length",  minval=1)
ema21Len  = input.int(21, "EMA 21 Length", minval=1)
upColor   = input.color(color.new(color.green, 82), "Up Slope Background")
downColor = input.color(color.new(color.red,   82), "Down Slope Background")

// === Calculations ===
ema8  = ta.ema(close, ema8Len)
ema21 = ta.ema(close, ema21Len)

// Slope detection on the 8 EMA
slopeUp   = ema8 > ema8[1]
slopeDown = ema8 < ema8[1]

// === Background coloring ===
bgcolor(slopeUp ? upColor : slopeDown ? downColor : na, title="EMA Slope Background")

// === Plot EMAs ===
plot(ema8,  color=color.new(color.blue, 0), linewidth=2, title="EMA 8")
plot(ema21, color=color.new(color.orange, 0), linewidth=2, title="EMA 21")
````

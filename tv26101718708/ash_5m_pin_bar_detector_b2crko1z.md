# Ash @ 5M Pin Bar Detector

- url: https://www.tradingview.com/script/b2CrKo1z-Ash-5M-Pin-Bar-Detector/
- type: indicator
- pine_id: PUB;2c6eb8cb8fa0485aa7b8e32dcd06081a
- version: 1.0

## Description

A pin bar is basically:

Small body
Long wick (rejection)
Wick is at least ~2–3× the body
Appears at key levels (but we’ll just detect structure here)

## Source Code

````pine
//@version=5
indicator("5M Pin Bar Detector", overlay=true)

// === Inputs ===
bodyRatio = input.float(0.3, "Max Body % of Range", step=0.05)
wickRatio = input.float(2.0, "Min Wick to Body Ratio", step=0.1)
showLabels = input.bool(true, "Show Labels")

// === Candle Calculations ===
body = math.abs(close - open)
candleRange = high - low

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// Avoid division by zero
valid = candleRange > 0

// === Pin Bar Conditions ===

// Bullish Pin Bar
bullishPin = valid and 
     (body / candleRange < bodyRatio) and
     (lowerWick > body * wickRatio) and
     (upperWick < body)

// Bearish Pin Bar
bearishPin = valid and 
     (body / candleRange < bodyRatio) and
     (upperWick > body * wickRatio) and
     (lowerWick < body)

// === Plot Signals ===
plotshape(bullishPin, title="Bullish Pin", location=location.belowbar, 
     color=color.green, style=shape.triangleup, size=size.small)

plotshape(bearishPin, title="Bearish Pin", location=location.abovebar, 
     color=color.red, style=shape.triangledown, size=size.small)

// Labels
if showLabels
    if bullishPin
        label.new(bar_index, low, "Bull Pin", style=label.style_label_up, color=color.green)
    if bearishPin
        label.new(bar_index, high, "Bear Pin", style=label.style_label_down, color=color.red)
````

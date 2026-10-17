# Directional MA Momentum (Zero-Based)

- url: https://www.tradingview.com/script/Ld0V3m54-Directional-MA-Momentum-Zero-Based/
- type: indicator
- pine_id: PUB;c0982acf46184edeaaa22fcdf091f386
- version: 1.0

## Description

Directional MA Momentum (Zero-Based) - measures directional changes in momentum

## Source Code

````pine
//@version=6
indicator("Directional MA Momentum (Zero-Based)", overlay=false)

// Inputs
maLength     = input.int(20, "MA Length")
smoothLength = input.int(1, "Smoothing (1 = none)")
signalLength = input.int(9, "Signal Length")

// ----------------------------
// 1. Moving Average
// ----------------------------
ma = ta.ema(close, maLength)

// ----------------------------
// 2. Directional Distance from MA (%)
// ----------------------------
distance = 100 * (close - ma) / ma

// ----------------------------
// 3. Momentum of Distance
// ----------------------------
momentum = distance - distance[1]

// ----------------------------
// 4. Optional smoothing
// ----------------------------
mainLine = ta.ema(momentum, smoothLength)

// ----------------------------
// 5. Signal line
// ----------------------------
signalLine = ta.ema(mainLine, signalLength)

// ----------------------------
// 6. Plot
// ----------------------------
plot(mainLine, "MA Momentum", linewidth=2)
plot(signalLine, "Signal")

hline(0, "Zero Line")
````

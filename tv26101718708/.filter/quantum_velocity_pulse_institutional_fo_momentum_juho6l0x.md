# Quantum Velocity Pulse: Institutional F&O Momentum

- url: https://www.tradingview.com/script/JUho6l0x-Quantum-Velocity-Pulse-Institutional-F-O-Momentum/
- type: indicator
- pine_id: PUB;5d4493ec83974484bbcd363ccb837fcd
- version: 1.0

## Description

"A specialized intraday tool designed for F&O traders to detect high-conviction 'Call' and 'Put' entries by analyzing the convergence of Relative Volume, Price Velocity, and Volatility Compression."

## Source Code

````pine
//@version=5
indicator("Unique GVV F&O Pulse", overlay=true)

// --- Inputs ---
lookback = input.int(10, "Pulse Lookback", minval=1)
volSens  = input.float(1.2, "Volume Sensitivity", step=0.1)
atrLen   = input.int(14, "ATR Period")

// --- Calculations ---
// 1. Price Velocity (Prevent division by zero)
bodySize = high - low
velocity = (close - close[1]) / (bodySize > 0 ? bodySize : syminfo.mintick)

// 2. Volume Weighting
vMA = ta.sma(volume, 50)
vWeight = volume / (vMA > 0 ? vMA : 1)
pulse = velocity * vWeight

// 3. Momentum Acceleration (The "Secret Sauce")
// Manual math to ensure no "null" or "ta" errors
accel = pulse - nz(pulse[lookback])

// 4. Filters
atr = ta.atr(atrLen)
atrMA = ta.sma(atr, 50)
isChop = atr < atrMA
vMA20 = ta.sma(volume, 20)

// --- Signal Logic ---
longSig  = accel > 0 and not isChop and volume > (vMA20 * volSens)
shortSig = accel < 0 and not isChop and volume > (vMA20 * volSens)

// --- Visuals ---
// Bar Colors
bColor = isChop ? color.gray : (accel > 0 ? color.lime : color.red)
barcolor(bColor)

// Trend Baseline
plot(ta.ema(close, 20), "Pulse Baseline", color=isChop ? color.gray : color.orange, linewidth=2)

// Signal Plots (Using plotshape for maximum stability)
plotshape(longSig and not longSig[1], "CALL", shape.labelup, location.belowbar, color.green, text="CALL", textcolor=color.white, size=size.small)
plotshape(shortSig and not shortSig[1], "PUT", shape.labeldown, location.abovebar, color.red, text="PUT", textcolor=color.white, size=size.small)
````

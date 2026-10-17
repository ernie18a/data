# Custom ADX (DI + Smoothing + Signal)

- url: https://www.tradingview.com/script/Jp3ACit7-Custom-ADX-DI-Smoothing-Signal/
- type: indicator
- pine_id: PUB;dbe7cc5332b7481c98f372c3850d0933
- version: 1.0

## Description

Custom ADX (DI + Smoothing + Signal).

Smoothed ADX providing a signal line

## Source Code

````pine
//@version=5
indicator("Custom ADX (DI + Smoothing + Signal)", overlay=false)

// Inputs (match TradingView structure)
diLen     = input.int(14, "DI Length")
adxSmooth = input.int(14, "ADX Smoothing")
signalLen = input.int(9, "Signal Line")

// --- Directional Movement ---
upMove   = ta.change(high)
downMove = -ta.change(low)

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

// --- True Range ---
tr = ta.tr(true)

// --- DI Calculation (uses DI Length) ---
atr = ta.rma(tr, diLen)

plusDI  = 100 * ta.rma(plusDM, diLen) / atr
minusDI = 100 * ta.rma(minusDM, diLen) / atr

// --- DX (Directional Index) ---
dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)

// --- ADX (uses ADX Smoothing) ---
adx = ta.rma(dx, adxSmooth)

// --- Signal line ---
signal = ta.ema(adx, signalLen)

// --- Plots ---
plot(adx, title="ADX", color=color.blue, linewidth=2)
plot(signal, title="Signal Line", color=color.orange, linewidth=2)

// --- Regime shifts ---
bull = ta.crossover(adx, signal)
bear = ta.crossunder(adx, signal)

plotshape(bull, title="Strength Expanding", style=shape.triangleup,
     location=location.bottom, color=color.green, size=size.tiny)

plotshape(bear, title="Strength Weakening", style=shape.triangledown,
     location=location.top, color=color.red, size=size.tiny)

// --- Regime background ---
bgcolor(adx > signal ? color.new(color.green, 90) : color.new(color.red, 90))
````

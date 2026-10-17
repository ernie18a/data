# Fast ADX with Signal Line

- url: https://www.tradingview.com/script/ai2wiQWn-Fast-ADX-with-Signal-Line/
- type: indicator
- pine_id: PUB;ac818be7d3064b5aae873003718917d2
- version: 1.0

## Description

Fast ADX with Signal Line - indicates quick changes of adx

## Source Code

````pine
//@version=6
indicator("Fast ADX with Signal Line", overlay=false)

// Inputs
diLength      = input.int(7,  "DI Length", minval=1)
adxSmooth     = input.int(3,  "ADX Smoothing", minval=1)
signalLength  = input.int(5,  "Signal Length", minval=1)

// True Range
tr = ta.tr(true)

// Directional Movement
upMove   = high - high[1]
downMove = low[1] - low

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0.0

// Wilder smoothing
smTR      = ta.rma(tr, diLength)
smPlusDM  = ta.rma(plusDM, diLength)
smMinusDM = ta.rma(minusDM, diLength)

// DI values
plusDI  = smTR > 0 ? 100 * smPlusDM / smTR : 0
minusDI = smTR > 0 ? 100 * smMinusDM / smTR : 0

// DX
dx = (plusDI + minusDI) > 0
     ? 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
     : 0

// Fast ADX
fastADX = ta.ema(dx, adxSmooth)

// Signal Line
signal = ta.ema(fastADX, signalLength)

// Plots
plot(fastADX, "Fast ADX", linewidth=2)
plot(signal, "Signal", linewidth=2)

hline(20, "Weak Trend")
hline(25, "Trend Starting")
hline(40, "Strong Trend")
````

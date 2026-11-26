# Relative Volume Expansion (Smoothed)

- url: https://www.tradingview.com/script/yIHPB46i-Relative-Volume-Expansion-Smoothed/
- type: indicator
- pine_id: PUB;216c9aafa03b4cf6a17dae50ceb53409
- version: 1.0

## Description

Relative Volume Expansion (Smoothed) - view  long vs short relative volume

## Source Code

````pine
//@version=5
indicator("Relative Volume Expansion (Smoothed)", overlay=false)

// Inputs
fastLen    = input.int(5, "Fast Volume Length")
slowLen    = input.int(30, "Slow Volume Length")
smoothLen  = input.int(5, "Expansion Smoothing")
signalLen  = input.int(9, "Signal Line")

// --- FAST & SLOW VOLUME AVERAGES ---
fastVol = ta.ema(volume, fastLen)
slowVol = ta.ema(volume, slowLen)

// --- RELATIVE VOLUME EXPANSION ---
rvExp = fastVol / slowVol

// --- SMOOTHING ---
rvSmooth = ta.ema(rvExp, smoothLen)

// --- SIGNAL LINE ---
signal = ta.ema(rvSmooth, signalLen)

// --- PLOTS ---
plot(rvSmooth, title="RV Expansion", color=color.blue, linewidth=2)
plot(signal, title="Signal Line", color=color.orange, linewidth=2)

// Baseline
hline(1.0, "Baseline", color=color.gray)

// --- REGIME SHIFTS ---
expanding = ta.crossover(rvSmooth, signal)
contracting = ta.crossunder(rvSmooth, signal)

// --- MARKERS ---
plotshape(expanding, title="Participation Expanding",
     style=shape.triangleup,
     location=location.bottom,
     color=color.green,
     size=size.tiny)

plotshape(contracting, title="Participation Weakening",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny)

// --- BACKGROUND ---
bgcolor(rvSmooth > signal
     ? color.new(color.green, 90)
     : color.new(color.red, 90))
````

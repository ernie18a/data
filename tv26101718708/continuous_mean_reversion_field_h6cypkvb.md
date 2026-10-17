# Continuous Mean Reversion Field

- url: https://www.tradingview.com/script/H6CyPKvB-Continuous-Mean-Reversion-Field/
- type: indicator
- pine_id: PUB;053cdd9b1eee4973b5e912984aae707b
- version: 1.0

## Description

A continuous mean reversion field typically refers to the application of the Ornstein-Uhlenbeck process, a mathematical model describing a stochastic variable that drifts towards a long-term average value over time

## Source Code

````pine
//@version=6
indicator("Continuous Mean Reversion Field", overlay = false)

// === Inputs ===
length      = input.int(50, minval=5, title="Mean Length")
smoothLen   = input.int(10, minval=1, title="Field Smoothing")
src         = input.source(close, title="Source")
threshold   = input.float(2.0, title="Extreme Threshold")

// === Mean & Deviation ===
mean   = ta.sma(src, length)
stdev  = ta.stdev(src, length)

// Prevent divide-by-zero
safeDev = stdev == 0 ? 0.0001 : stdev

// === Continuous Reversion Field ===
rawField = (src - mean) / safeDev
field = ta.ema(rawField, smoothLen)

// === Visualization ===
hline(0, "Mean", color=color.gray)
hline(threshold, "Upper Extreme", color=color.red)
hline(-threshold, "Lower Extreme", color=color.lime)

// Dynamic coloring
fieldColor = field > threshold ? color.red :
             field < -threshold ? color.lime :
             field > 0 ? color.orange :
             color.aqua

plot(field,
     title="Mean Reversion Field",
     color=fieldColor,
     linewidth=3)

// === Background Heatmap ===
bgcolor(
    field > threshold ? color.new(color.red, 85) :
    field < -threshold ? color.new(color.green, 85) :
    na)

// === Signals === 
longSignal  = ta.crossover(field, -threshold)
shortSignal = ta.crossunder(field, threshold)

plotshape(longSignal,
     title="Long Signal",
     location=location.bottom,
     color=color.lime,
     style=shape.triangleup,
     size=size.small)

plotshape(shortSignal,
     title="Short Signal",
     location=location.top,
     color=color.red,
     style=shape.triangledown,
     size=size.small)
````

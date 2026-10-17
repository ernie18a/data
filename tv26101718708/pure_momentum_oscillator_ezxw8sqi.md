# Pure Momentum Oscillator

- url: https://www.tradingview.com/script/ezXw8sQI-Pure-Momentum-Oscillator/
- type: indicator
- pine_id: PUB;81c8ac0217d44c98a19e5a7d1f4bf429
- version: 1.0

## Description

Purely based on momentum which focus to capture momentum before it happens

## Source Code

````pine
//@version=5
indicator("Pure Momentum Oscillator", overlay=false, precision=2)

// --- Inputs ---
lookback = input.int(14, "Momentum Lookback Period", minval=1)
smoothLen = input.int(9, "Signal Line Smoothing", minval=1)
src = input.source(close, "Source")

// --- Calculations ---
// Pure Momentum: (Current Price / Price n periods ago) - 1
// We multiply by 100 to get a percentage-style ROC
mom = ((src - src[lookback]) / src[lookback]) * 100

// Signal Line: Smoothing the momentum to filter out market noise
signalLine = ta.ema(mom, smoothLen)

// Histogram: The difference between momentum and its signal
hist = mom - signalLine

// --- Plotting ---
// Zero line for reference
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

// Momentum and Signal Lines
plot(mom, "Momentum Line", color=color.blue, linewidth=2)
plot(signalLine, "Signal Line", color=color.orange, linewidth=1)

// Color-coded Histogram
// Bright Green/Red = Momentum is pulling away from signal
// Dark Green/Red = Momentum is returning toward signal (exhaustion)
histColor = hist > 0 ? (hist > hist[1] ? #26a69a : #b2dfdb) : (hist < hist[1] ? #ef5350 : #ffcdd2)
plot(hist, "Momentum Histogram", color=histColor, style=plot.style_columns)

// --- Alerts ---
alertcondition(ta.crossover(mom, signalLine), title="Bullish Momentum", message="Momentum crossed above signal")
alertcondition(ta.crossunder(mom, signalLine), title="Bearish Momentum", message="Momentum crossed below signal")
````

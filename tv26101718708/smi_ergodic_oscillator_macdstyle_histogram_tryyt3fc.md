# SMI Ergodic Oscillator (MACD-style Histogram)

- url: https://www.tradingview.com/script/tryyT3fc-SMI-Ergodic-Oscillator-MACD-style-Histogram/
- type: indicator
- pine_id: PUB;19c9aa9fa0d543d5b411e29404c65946
- version: 2.0

## Description

Claude code SMI Ergodic Oscillator with the MACD style histogram

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © stephenwood15000

//@version=6
indicator("SMI Ergodic Oscillator (MACD-style Histogram)", shorttitle="SMI Ergodic", overlay=false)

// ================= Inputs =================
lengthR = input.int(10,  title="Long Length (r)",  group="SMI Ergodic")
lengthS = input.int(20,  title="Short Length (s)", group="SMI Ergodic")
lengthSignal = input.int(9, title="Signal Length", group="SMI Ergodic")

// ================= Calculations =================
momentum = close - close[1]

// Double-smoothed momentum
emaMom1 = ta.ema(momentum, lengthR)
emaMom2 = ta.ema(emaMom1, lengthS)

// Double-smoothed absolute momentum
absMomentum = math.abs(momentum)
emaAbsMom1  = ta.ema(absMomentum, lengthR)
emaAbsMom2  = ta.ema(emaAbsMom1, lengthS)

// SMI Ergodic Oscillator
smiErgodic = emaAbsMom2 != 0 ? (emaMom2 / emaAbsMom2) * 100 : 0

// Signal line
signalLine = ta.ema(smiErgodic, lengthSignal)

// Histogram = Oscillator - Signal
hist = smiErgodic - signalLine

// ================= Plots =================
hline(0, "Zero Line", color=color.rgb(0, 0, 0, 100), linestyle=hline.style_dotted)

// MACD-style histogram coloring
histColor = hist >= 0 ? (hist > hist[1] ? color.rgb(4, 180, 136, 43) : color.rgb(1, 94, 66, 38)) : (hist < hist[1] ? color.rgb(136, 46, 46, 31) : color.rgb(182, 77, 77, 42))

plot(hist, title="SMI Ergodic Histogram", style=plot.style_columns, color=histColor)

// Oscillator and Signal lines (optional, can be removed if not needed)
plot(smiErgodic, title="SMI Ergodic Oscillator", color=color.rgb(240, 241, 241), linewidth=1)
plot(signalLine, title="SMI Ergodic Signal", color=color.rgb(255, 153, 0, 45), linewidth=1)
````

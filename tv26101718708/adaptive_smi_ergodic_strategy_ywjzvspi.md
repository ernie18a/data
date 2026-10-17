# Adaptive SMI Ergodic Strategy

- url: https://www.tradingview.com/script/YwjZvSpI-Adaptive-SMI-Ergodic-Strategy/
- type: strategy
- pine_id: PUB;cb8883ed1cb14cc298f08cec2e29aed4
- version: 2.0

## Description

The Adaptive SMI Ergodic Strategy aims to capture the momentum and direction of a financial asset by leveraging the Stochastic Momentum Index Indicator (SMI) in an ergodic form. The strategy uses two lengths for the SMI, a shorter and a longer one, and an Exponential Moving Average (EMA) to serve as the signal line. Additionally, the strategy incorporates customizable overbought and oversold thresholds to improve the probability of successful trade execution.

How It Works:
Long Entry: A long position is taken when the ergodic SMI crosses over the EMA signal line, and both the SMI and EMA are below the oversold threshold.

Short Entry: A short position is initiated when the ergodic SMI crosses under the EMA signal line, and both the SMI and EMA are above the overbought threshold.

The strategy plots the SMI in yellow and the EMA signal line in purple. Horizontal lines indicate the overbought and oversold thresholds, and a colored background helps in visually identifying these zones.

Parameters:
Long Length: The length of the long EMA in SMI calculation.
Short Length: The length of the short EMA in SMI calculation.
Signal Line Length: The length for the EMA serving as the signal line.
Oversold: Customizable threshold for the oversold condition.
Overbought: Customizable threshold for the overbought condition.

Historical Context: The SMI Indicator
The Stochastic Momentum Index (SMI) was developed by William Blau in the early 1990s as an enhancement to traditional stochastic oscillators. The SMI provides a range of values like a traditional stochastic, but it differs in that it calculates the distance of the current close relative to the median of the high/low range, as opposed to the close relative to the low. As a result, the SMI is less erratic and more responsive, offering a clearer picture of market trends.

In recent years, the SMI has been adapted into ergodic forms to facilitate smoother data analysis, reduce lag, and improve trading accuracy. The Adaptive SMI Ergodic Strategy leverages these modern enhancements to offer a more robust, customizable trading strategy that aligns with various market conditions.

## Source Code

````pine
// © DraftVenture

//@version=5
strategy(title="Adaptive SMI Ergodic Strategy", shorttitle="Adaptive SMI Strategy", overlay = false)

// Inputs
longlen = input.int(12, minval=1, title="Long Length")
shortlen = input.int(5, minval=1, title="Short Length")
siglen = input.int(5, minval=1, title="Signal Line Length")
overS = input.float(-0.4, title = "Oversold Threshold", step = 0.01)
overB = input.float(0.4, title = "Overbought Threshold", step = 0.01)

// Calculations
erg = ta.tsi(close, shortlen, longlen)
sig = ta.ema(erg, siglen)

// Plotting
emiPlot = plot(erg, color = color.blue, title = "SMI")
plot(sig, color = color.orange, title="Signal")
hline(0, title = "Zero", color = color.gray, linestyle = hline.style_dotted)
h0 = hline(overB, color = color.gray, title = "Overbought")
h1 = hline(overS, color = color.gray, title = "Oversold")
fill(h0, h1, color=color.rgb(25, 117, 192, 90), title = "Background")
midLinePlot = plot(0, color = na, editable = false, display = display.none)
fill(emiPlot, midLinePlot, 1, overB,   top_color = color.new(#51b855, 0),    bottom_color = color.new(#4cb04f, 100), title = "Overbought Gradient")
fill(emiPlot, midLinePlot, overS, -1,  top_color = color.new(#fc5151, 100), bottom_color = color.new(#f54f4f, 0),    title = "Oversold Gradient")

// Conditions
longEntry = ta.crossover(erg, overS) and erg > sig
shortEntry = ta.crossunder(erg, overB) and erg < sig

// Logic
if longEntry
    strategy.entry("Long", strategy.long)

if shortEntry
    strategy.entry("Short", strategy.short)

// ______ _________ 
// ___  //_/__  __ \
// __  ,<  __  /_/ /
// _  /| | _  ____/ 
// /_/ |_| /_/
````

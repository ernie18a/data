# SMI + Williams %R Combo

- url: https://www.tradingview.com/script/qrlzx2Ky-SMI-Williams-R-Combo/
- type: indicator
- pine_id: PUB;35f1381943a241cbaa4e9bf7d16caba2
- version: 1.0

## Description

Stochastic Momentum Index overlayed on Williams & Range

## Source Code

````pine
//@version=5
indicator("SMI + Williams %R Combo", shorttitle="SMI_%R", timeframe="", timeframe_gaps=true)

// SMI Inputs
lengthK   = input.int(10, "%K Length",    minval=1, maxval=15000)
lengthD   = input.int(3,  "%D Length",    minval=1, maxval=4999)
lengthEMA = input.int(3,  "EMA Length",   minval=1, maxval=4999)

// Williams %R Input
lengthWR  = input.int(14, "Williams %R Length", minval=1)

// SMI Calculation (-100 to +100, centered at 0)
emaEma(source, length) => ta.ema(ta.ema(source, length), length)
highestHigh = ta.highest(lengthK)
lowestLow = ta.lowest(lengthK)
highestLowestRange = highestHigh - lowestLow
relativeRange = close - (highestHigh + lowestLow) / 2
smi = 200 * (emaEma(relativeRange, lengthD) / emaEma(highestLowestRange, lengthD))
smiEMA = ta.ema(smi, lengthEMA)

// Williams %R Calculation (transformed from -100-0 to -100-+100, centered at 0)
_pr(length) =>
    max = ta.highest(length)
    min = ta.lowest(length)
    100 * (close - max) / (max - min)
percentR = _pr(lengthWR)
normalizedWR = (percentR * 2) + 100

// Plotting
smiPlot = plot(smi, "SMI", color=color.blue, linewidth=2)
smiEmaPlot = plot(smiEMA, "SMI EMA", color=color.orange, linewidth=2)
wrPlot = plot(normalizedWR, "Williams %R", color=color.purple, linewidth=2)

// Dynamic ribbon color based on SMI vs SMI EMA
ribbonColor = smi > smiEMA ? color.new(color.green, 80) : color.new(color.red, 80)
fill(smiPlot, smiEmaPlot, color=ribbonColor, title="SMI Ribbon")

// Define middle as a plot for fill reference, non-editable
middlePlot = plot(0, "Middle", display=display.none, editable=false)

// Unified Levels
hline(50, "Overbought", color=color.gray, linestyle=hline.style_dashed)
hline(0, "Middle", color=color.gray, linestyle=hline.style_dotted)
hline(-50, "Oversold", color=color.gray, linestyle=hline.style_dashed)

// Gradient Fills
fill(smiPlot, middlePlot, 120, 50, top_color=color.new(#4caf4f, 50), bottom_color=color.new(color.green, 100), title="SMI Overbought Gradient")
fill(smiPlot, middlePlot, -50, -120, top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 50), title="SMI Oversold Gradient")
fill(wrPlot, middlePlot, 120, 50, top_color=color.new(#4caf4f, 50), bottom_color=color.new(color.green, 100), title="Williams %R Overbought Gradient")
fill(wrPlot, middlePlot, -50, -120, top_color=color.new(color.red, 100), bottom_color=color.new(color.red, 50), title="Williams %R Oversold Gradient")
````

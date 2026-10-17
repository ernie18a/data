# Source Correlation

- url: https://www.tradingview.com/script/58J5YgvZ-Source-Correlation/
- type: indicator
- pine_id: PUB;057af28b8d39408e879022dde1792c90
- version: 3.0

## Description

In this small indicator I make it possible for the user to set two different input sources. Then, the indicator displays the correlation of these two input sources. It's a very small script, but I think it could be helpful to somebody to find uncorrelated indicators for his trading strategy. To use uncorrelated indicators is in general recommended.

[i]Enjoy this small, but powerful tool.[/i] 🧙‍♂️

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © simwai

//@version=5
indicator('Source Correlation', 'S_COR', precision=2, overlay=false, explicit_plot_zorder=true)

// -- Colors --
color languidLavender = color.rgb(232, 215, 255)

// -- Inputs --
src1 = input.source(close, 'Source 1')
src1Repaint = input.bool(false, 'Is Source 1 Repainting?')
src2 = input.source(close, 'Source 2?')
src2Repaint = input.bool(false, 'Is Source 2 Repainting?')
length = input.int(defval=3, minval=2, step=1, title='Length')
corr_level = input.float(defval=0.8, step=0.01, title='Level of significant correlation')

// -- Calcuation --
symbol1 = src1[src1Repaint ? 1 : 0]
symbol2 = src2[src2Repaint ? 1 : 0]

c = ta.correlation(symbol1, symbol2, length)

corrPlot = plot(c, title='Correlation', color=c > corr_level ? color.aqua : c < -corr_level ? color.purple : languidLavender, trackprice=true, style=plot.style_columns)
zeroPlot = plot(0, title='Zero Line', color=color.new(color.gray, 50))
plusCorrLevel = plot(corr_level, title='+Level', color=color.new(color.silver, 50))
minusCorrLevel = plot(-corr_level, title='-Level', color=color.new(color.silver, 50))
maxPlot = plot(1, title='Top Line', color=color.new(color.gray, 50))
minPlot = plot(-1, title='Bottom Line', color=color.new(color.gray, 50))
fill(maxPlot, plusCorrLevel, c > corr_level ? color.new(color.aqua, 50) : color.new(color.gray, 56))
fill(minPlot, minusCorrLevel, c < -corr_level ? color.new(color.purple, 50) : color.new(color.gray, 56))
````

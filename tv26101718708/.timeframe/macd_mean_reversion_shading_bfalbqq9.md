# MACD Mean Reversion Shading

- url: https://www.tradingview.com/script/BfALbqQ9-MACD-Mean-Reversion-Shading/
- type: indicator
- pine_id: PUB;cb1e8f9e9a284810a587b6358cd60e69
- version: 1.0

## Description

MACD Mean Reversion Shading

This indicator is a visual MACD tool designed to make MACD/signal-line momentum shifts easier to read at a glance.

Unlike a standard MACD display that only plots the MACD line, signal line, and histogram, this version emphasizes the relationship between the MACD and signal line by coloring the MACD line, plotting optional crossover dots, and shading the space between the MACD and signal line.

The purpose is to help traders quickly identify potential mean-reversion momentum turns after extended moves, especially when MACD begins crossing back toward the signal line.

How it works

The indicator calculates MACD using customizable EMA lengths. The default settings are:

Fast EMA: 8
Slow EMA: 21
Signal EMA: 5

These faster settings are designed to be more responsive than the traditional 12/26/9 MACD.

When the MACD line is above the signal line, the indicator colors the MACD line green and shades the area between the two lines green. When the MACD line is below the signal line, the MACD line turns red and the shaded area turns red.

Optional dots mark MACD/signal-line crossovers:

Green dot: MACD crosses above the signal line
Red dot: MACD crosses below the signal line

The histogram can be displayed using either two-color or four-color logic. The four-color mode distinguishes between rising/falling momentum above and below the zero line.

Multi-timeframe option

The script can calculate MACD using the current chart timeframe or an alternate user-selected timeframe. This allows traders to view higher- or lower-timeframe MACD behavior while staying on the current chart.

How to use it

This script is not intended to be a standalone buy/sell system. It is designed as a visual momentum and mean-reversion aid.

Potential uses include:

Spotting MACD/signal-line turns after extended directional moves
Identifying when bearish momentum is weakening
Identifying when bullish momentum is strengthening
Comparing MACD momentum across different chart timeframes
Using the shaded MACD/signal area as a quick visual trend/momentum filter

A green shaded region suggests MACD is above its signal line. A red shaded region suggests MACD is below its signal line. Traders should combine this with price structure, support/resistance, trend, volume, and broader market context.

Original contribution

The main contribution of this script is its visual treatment of MACD/signal-line interaction: dynamic line coloring, shaded MACD/signal spread, crossover dots, four-color histogram behavior, and optional multi-timeframe calculation in one configurable tool.

## Source Code

````pine
//@version=6
indicator("MACD Mean Reversion Shading", shorttitle="MACD MR Shade", overlay=false)

//----------------------------------------------------
// INPUTS
//----------------------------------------------------
useChartTimeframe = input.bool(true, "Use Current Chart Timeframe?")
alternateTimeframe = input.timeframe("60", "Alternate Timeframe")

showMacdSignalLines = input.bool(true, "Show MACD & Signal Lines?")
showCrossSignals = input.bool(true, "Show MACD Cross Dots?")
showHistogram = input.bool(true, "Show Histogram?")
dynamicMacdColor = input.bool(true, "Dynamic MACD Line Color?")
fourColorHistogram = input.bool(true, "4-Color Histogram?")
showMacdSignalFill = input.bool(true, "Shade Between MACD & Signal?")
fillTransparency = input.int(20, "Fill Transparency", minval=0, maxval=100)

fastLength = input.int(8, "Fast EMA Length", minval=1)
slowLength = input.int(21, "Slow EMA Length", minval=1)
signalLength = input.int(5, "Signal EMA Length", minval=1)

//----------------------------------------------------
// TIMEFRAME SELECTION
//----------------------------------------------------
selectedTimeframe = useChartTimeframe ? timeframe.period : alternateTimeframe

//----------------------------------------------------
// MACD CALCULATION
//----------------------------------------------------
calculateMacd() =>
    fastEMA = ta.ema(close, fastLength)
    slowEMA = ta.ema(close, slowLength)
    macdValue = fastEMA - slowEMA
    signalValue = ta.ema(macdValue, signalLength)
    histogramValue = macdValue - signalValue
    [macdValue, signalValue, histogramValue]

[macdLine, signalLine, histogramLine] = request.security(syminfo.tickerid, selectedTimeframe, calculateMacd(), barmerge.gaps_off, barmerge.lookahead_off)

//----------------------------------------------------
// COLORS
//----------------------------------------------------
macdBullish = macdLine >= signalLine

macdLineColor = dynamicMacdColor ? macdBullish ? color.lime : color.red : color.lime
signalLineColor = macdBullish ? color.rgb(190, 175, 40) : color.rgb(40, 180, 40)

histogramRisingAboveZero = histogramLine >= 0 and histogramLine > histogramLine[1]
histogramFallingAboveZero = histogramLine >= 0 and histogramLine <= histogramLine[1]
histogramFallingBelowZero = histogramLine < 0 and histogramLine < histogramLine[1]
histogramRisingBelowZero = histogramLine < 0 and histogramLine >= histogramLine[1]

histogramColor4 = histogramRisingAboveZero ? color.teal : histogramFallingAboveZero ? color.rgb(170, 200, 200) : histogramFallingBelowZero ? color.rgb(180, 70, 70) : color.rgb(200, 170, 180)
histogramColor2 = histogramLine >= 0 ? color.teal : color.rgb(180, 70, 70)
histogramColor = fourColorHistogram ? histogramColor4 : histogramColor2

fillColor = macdBullish ? color.new(color.lime, fillTransparency) : color.new(color.red, fillTransparency)

//----------------------------------------------------
// PLOTS
//----------------------------------------------------
hline(0, "Zero Line", color=color.gray)

histogramPlot = plot(showHistogram ? histogramLine : na, title="Histogram", style=plot.style_columns, color=histogramColor, linewidth=2)

macdPlot = plot(showMacdSignalLines ? macdLine : na, title="MACD Line", color=macdLineColor, linewidth=2)

signalPlot = plot(showMacdSignalLines ? signalLine : na, title="Signal Line", color=signalLineColor, linewidth=2)

fill(macdPlot, signalPlot, color=showMacdSignalFill and showMacdSignalLines ? fillColor : na, title="MACD Signal Fill")

//----------------------------------------------------
// CROSSOVER SIGNALS
//----------------------------------------------------
bullishCross = ta.crossover(macdLine, signalLine)
bearishCross = ta.crossunder(macdLine, signalLine)

plotshape(showCrossSignals and bullishCross ? macdLine : na, title="Bullish Cross", style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)

plotshape(showCrossSignals and bearishCross ? macdLine : na, title="Bearish Cross", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)
````

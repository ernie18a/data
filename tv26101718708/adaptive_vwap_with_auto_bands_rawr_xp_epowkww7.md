# Adaptive VWAP with Auto Bands RAWR XP

- url: https://www.tradingview.com/script/EpowkWW7-Adaptive-VWAP-with-Auto-Bands-RAWR-XP/
- type: indicator
- pine_id: PUB;74bfc5017d7449ada98a7883a90c72d3
- version: 1.0

## Description

This is an adaptive vwap with auto bolinger bands i tried to make it no repainting but the code may need some touch ups!!! So tread carefully when [s]scalping [/s]wif this indicator but for swing trading it's pretty decent...

## Source Code

````pine
//@version=6
indicator("Adaptive VWAP with Auto Bands", overlay=true)

// VWAP Calculation
vwapValue = ta.vwap

// Volatility Detection (ATR-Based)
atrValue = ta.atr(14)
volatility = atrValue / ta.sma(close, 50) 

// Dynamic Band Multipliers
lowVolMultiplier = 1.5
normalVolMultiplier = 2.0
highVolMultiplier = 3.0

// Define thresholds
lowVolThreshold = 0.002
highVolThreshold = 0.005

// Select multiplier
bandMultiplier = volatility < lowVolThreshold ? lowVolMultiplier : 
                 volatility > highVolThreshold ? highVolMultiplier : 
                 normalVolMultiplier

// Calculate VWAP Bands
upperBand = vwapValue + (bandMultiplier * atrValue)
lowerBand = vwapValue - (bandMultiplier * atrValue)

// Plotting - Fixed the style identifiers
vwapPlot = plot(vwapValue, title="VWAP", color=color.blue, linewidth=2)

// Note: plot() uses plot.style_line, plot.style_stepline, plot.style_circles, etc.
upperBandPlot = plot(upperBand, title="Upper VWAP Band", color=color.red, linewidth=1, style=plot.style_linebr)
lowerBandPlot = plot(lowerBand, title="Lower VWAP Band", color=color.green, linewidth=1, style=plot.style_linebr)

// Alerts
alertcondition(close > upperBand, title="Overbought Alert", message="Price stretched too far above VWAP")
alertcondition(close < lowerBand, title="Oversold Alert", message="Price stretched too far below VWAP")
````

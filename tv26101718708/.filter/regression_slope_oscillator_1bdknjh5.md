# Regression Slope Oscillator

- url: https://www.tradingview.com/script/1bdkNJh5-Regression-Slope-Oscillator/
- type: indicator
- pine_id: PUB;d278d6591641427eaf5de58b4d8e5a42
- version: 1.0

## Description

Description:
The Regression Slope Oscillator is a momentum indicator that measures the slope of a linear regression curve. It can help traders identify the current trend direction as well as the acceleration or deceleration of a trend early on.

How Does the Indicator Work?
The core of the indicator calculates the difference between the current and the previous value of a linear regression. This value reflects the slope:

Values above the zero line: Indicate an uptrend.

Values below the zero line: Indicate a downtrend.

Additionally, a signal line is calculated. Crossovers between the oscillator and the signal line provide indications of potential trend changes.

The Color Logic (Momentum Strength)
The oscillator line and its fill use a dynamic 4-color system to display the strength of the market momentum at a glance:

Dark Turquoise (Bull Strong): The oscillator is above zero and rising. The uptrend is gaining momentum.

Light Turquoise (Bull Weak): The oscillator is above zero but falling. The uptrend is flattening out.

Dark Pink (Bear Strong): The oscillator is below zero and falling further. The downtrend is accelerating.

Light Pink (Bear Weak): The oscillator is below zero but rising. The downtrend is losing strength (recovery).

Main Features & Settings
Customizable Signal Line: Flexibly choose between various moving averages for the signal line (SMA, EMA, HMA, or VWMA).

Customizable Lengths: The lengths for both the linear regression and the signal line can be freely adjusted in the settings.

Built-in Signals: White dots mark the exact moment the regression oscillator crosses the signal line (crossovers/crossunders).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steffi_Se

//@version=6
indicator("Regression Slope Oscillator", "Reg Slope", timeframe= "", timeframe_gaps = true)

// User Inputs
SignalMAType    = input.string("EMA", "Signal Line",["SMA", "EMA", "HMA", "VWMA"])
SignalMALength  = input.int(21, "Length")
Source          = input.source(close,"Source")
RegLength       = input.int(38, "Regression Length")

//Calculation
RegSlope = ta.linreg(Source, RegLength,0) - ta.linreg(Source, RegLength,1)

SignalLine  = switch SignalMAType
    "SMA"   => ta.sma(RegSlope, SignalMALength)
    "EMA"   => ta.ema(RegSlope, SignalMALength)
    "HMA"   => ta.hma(RegSlope, SignalMALength)
    "VWMA"  => ta.vwma(RegSlope, SignalMALength)

// color logic
isBullStrong = RegSlope > 0 and RegSlope > RegSlope [1]
isBullWeak   = RegSlope > 0 and RegSlope < RegSlope [1]
isBearStrong = RegSlope < 0 and RegSlope < RegSlope [1]
isBearWeak  =  RegSlope < 0 and RegSlope > RegSlope [1]

// define color
colorBullStrong = color.new(#548f8f,0)
colorBullWeak   = color.new(#79cdcd,0)
colorBearStrong = color.new(#b2247d,0)
colorBearWeak   = color.new(#ff34b3,0)

lineColor = isBullStrong ? colorBullStrong : isBullWeak ? colorBullWeak : isBearStrong ? colorBearStrong : isBearWeak ? colorBearWeak : na

// Plots 
oscillator = plot(RegSlope, "Oscillator",lineColor,2,plot.style_line)
zeroline = plot(0, "Zero Line", color=color.new(color.gray, 60))
plot(SignalLine, "Signal Line", color.new(#ffec8b,20),1)


// SignalLine Cross
bullishCross = ta.crossover(RegSlope,SignalLine) 
bearishCross = ta.crossunder(RegSlope,SignalLine)

plotshape(bullishCross ? SignalLine : na ,"Buy Signal",shape.circle,location = location.absolute, color=color.white, size=size.tiny)
plotshape(bearishCross ? SignalLine : na ,"Sell Signal",shape.circle,location=location.absolute, color=color.white,size = size.tiny)
fillColor = isBullStrong ?color.new(#548f8f,50)
          : isBullWeak   ?color.new(#79cdcd,50)
          : isBearStrong ?color.new(#b2247d,50)
          : isBearWeak   ?color.new(#ff34b3,50) : na 


fill(oscillator, zeroline, color=fillColor)
````

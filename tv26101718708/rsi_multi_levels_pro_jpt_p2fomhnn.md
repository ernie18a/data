# RSI Multi Levels Pro (JPT)

- url: https://www.tradingview.com/script/p2FOMhnN-RSI-Multi-Levels-Pro-JPT/
- type: indicator
- pine_id: PUB;abf3dcdfd9314302aff3e223633c40ae
- version: 1.0

## Description

🔹 [b]OVERVIEW[/b]

[b]RSI Multi Levels Pro (JPT)[/b] is an enhanced Relative Strength Index (RSI) indicator that expands the traditional 70/30 approach by introducing multiple configurable RSI levels to help traders observe momentum shifts and potential reversal areas.

Instead of relying on a single overbought or oversold threshold, the indicator displays several RSI zones, allowing users to monitor how momentum develops as price moves through different strength levels.

The indicator also highlights potential exhaustion areas using optional visual markers when RSI reaches user-defined extreme level

🔹 [b]HOW IT WORKS[/b]

The indicator calculates the standard RSI using a configurable period and plots it against multiple horizontal reference levels.

As RSI moves through these levels, traders can observe changes in market momentum and identify areas where price may begin slowing, reversing, or continuing its current move.

Optional markers are displayed when RSI reaches predefined upper or lower threshold values, helping users quickly identify extreme momentum conditions.

🔹 [b]MULTI-LEVEL RSI STRUCTURE[/b]

Unlike a traditional RSI with only two reference levels, RSI ML Pro provides multiple zones including:

// RSI Levels
lvl90 = input.int(90, "Level 90")
lvl80 = input.int(80, "Level 80")
lvl70 = input.int(70, "Level 70")
lvl60 = input.int(60, "Level 60")
lvl50 = input.int(50, "Level 50")
lvl40 = input.int(40, "Level 40")
lvl30 = input.int(30, "Level 30")
lvl20 = input.int(20, "Level 20")
lvl10 = input.int(10, "Level 10")

These levels can help distinguish between moderate momentum and more extreme market conditions.

 🔹 [b]VISUAL FEATURES[/b]

• Standard RSI Line
• Configurable Multi-Level Reference Lines
• Upper Momentum Markers
• Lower Momentum Markers
• Customizable Colors
• Adjustable RSI Length
• Clean and Lightweight Display
• Compatible with Dark and Light Chart Themes

🔹 [b]INDICATOR INPUTS[/b]

The indicator includes several customization options:
RSI Length 
Adjust the RSI calculation period.
Reference Levels 
Configure upper and lower RSI levels to match your trading style.
Signal Markers
Enable or disable momentum markers.

Colors
Customize the appearance of the RSI line, levels, and markers.

🔹 [b]HOW TO USE[/b]

A common workflow is:

Observe the overall RSI trend.
Monitor how RSI reacts around the configured reference levels.
Watch for momentum markers when RSI reaches extreme values.
Combine RSI observations with your own price action or market structure analysis before making trading decisions.

🔹 [b]SUITABLE MARKETS[/b]

RSI ML Pro can be used on:

• Forex

• Cryptocurrency

• Stocks

• Indices

• Commodities

• Gold

The indicator is designed to work across multiple timeframes depending on the user's trading approach.

🔹 [b]COMBINING WITH OTHER TOOLS[/b]

Many traders choose to combine RSI ML Pro with other forms of technical analysis such as:

• Trend Analysis

• Support and Resistance

• Moving Averages

• Market Structure

• Volume Analysis

• Supply and Demand Zones

Using multiple forms of analysis may provide additional market context.

🔹[b]NOTES[/b]

RSI measures momentum and should not be interpreted as a standalone buy or sell signal. Strong trends can remain in higher or lower RSI regions for extended periods.

This indicator is intended as a technical analysis tool and should be used alongside appropriate risk management and independent market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("RSI Multi Levels Pro (JPT)", shorttitle="RSI ML Pro", overlay=false)

// Inputs
rsiLength = input.int(14, "RSI Length", minval=2)
src = input.source(close, "Source")

// RSI Levels
lvl90 = input.int(90, "Level 90")
lvl80 = input.int(80, "Level 80")
lvl70 = input.int(70, "Level 70")
lvl60 = input.int(60, "Level 60")
lvl50 = input.int(50, "Level 50")
lvl40 = input.int(40, "Level 40")
lvl30 = input.int(30, "Level 30")
lvl20 = input.int(20, "Level 20")
lvl10 = input.int(10, "Level 10")

// RSI Calculation
rsi = ta.rsi(src, rsiLength)

// Plot RSI
plot(rsi, title="RSI", color=color.rgb(0, 0, 0), linewidth=2)

// Plot Levels
hline(lvl90, "90", color=color.red)
hline(lvl80, "80", color=color.orange)
hline(lvl70, "70", color=color.red)
hline(lvl60, "60", color=color.gray)
hline(lvl50, "50", color=color.white)
hline(lvl40, "40", color=color.gray)
hline(lvl30, "30", color=color.lime)
hline(lvl20, "20", color=color.green)
hline(lvl10, "10", color=color.teal)

// Background Zones
bgcolor(rsi >= lvl80 ? color.new(color.red, 88) : na)
bgcolor(rsi <= lvl20 ? color.new(color.green, 88) : na)

// Buy & Sell Signals
buySignal = ta.crossover(rsi, lvl30)
sellSignal = ta.crossunder(rsi, lvl70)

plotshape(buySignal,
     title="Buy",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.small)

plotshape(sellSignal,
     title="Sell",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.small)

// Alerts
alertcondition(buySignal, title="RSI Buy", message="RSI crossed above 30")
alertcondition(sellSignal, title="RSI Sell", message="RSI crossed below 70")
````

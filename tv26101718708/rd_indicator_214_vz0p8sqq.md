# R&D Indicator 2.14

- url: https://www.tradingview.com/script/Vz0p8Sqq-R-D-Indicator-2-14/
- type: indicator
- pine_id: PUB;4fe37565ba734cb6bb0d92e9e0b59b83
- version: 1.0

## Description

This is a dual-line momentum indicator that combines two complementary oscillator calculations to provide both trend direction and early impulse detection on a single panel.
How it works:
The white line is a smoothed Stochastic %D that tracks the broader momentum cycle. It moves slowly and deliberately, making it useful for identifying the prevailing trend direction and overbought/oversold conditions.
The yellow line is a Double Stochastic Oscillator (DSO) that is more reactive to price changes. When the yellow line reaches the extreme zones (above 80 or below 20) and turns back, it acts as an early warning signal for a potential continuation impulse in the direction of the trend.
Key features:

Overbought zone (above 80) shaded in red
Oversold zone (below 20) shaded in green
Dotted midline at 50 for reference
Full customization of line colors, thickness and style
All settings adjustable including period lengths, zone levels and background transparency

## Source Code

````pine
//@version=6
indicator("R&D Indicator 2.14", overlay=false, max_lines_count=500)

// DSO Settings (Yellow Line)
dsoLengthK = input.int(12, "DSO LengthK", group="Yellow Line - DSO")
dsoLengthD = input.int(10, "DSO LengthD", group="Yellow Line - DSO")
dsoLengthSlowing = input.int(2, "DSO LengthSlowing", group="Yellow Line - DSO")
yellowColor = input.color(color.yellow, "Color", group="Yellow Line - DSO")
yellowWidth = input.int(2, "Width", minval=1, maxval=5, group="Yellow Line - DSO")
yellowStyle = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group="Yellow Line - DSO")

// Stoch Settings (White Line)
stochK = input.int(12, "%K Length", group="White Line - Stoch")
stochD = input.int(3, "%D Smoothing", group="White Line - Stoch")
whiteColor = input.color(color.white, "Color", group="White Line - Stoch")
whiteWidth = input.int(2, "Width", minval=1, maxval=5, group="White Line - Stoch")
whiteStyle = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group="White Line - Stoch")

// Levels
overboughtLevel = input.int(80, "OverBought Level", group="Levels")
oversoldLevel = input.int(20, "OverSold Level", group="Levels")
obLineColor = input.color(color.red, "OverBought Line Color", group="Levels")
obLineWidth = input.int(1, "OverBought Line Width", minval=1, maxval=5, group="Levels")
obLineStyle = input.string("Solid", "OverBought Line Style", options=["Solid", "Dashed", "Dotted"], group="Levels")
midLineColor = input.color(color.white, "Mid Line Color", group="Levels")
midLineWidth = input.int(1, "Mid Line Width", minval=1, maxval=5, group="Levels")
midLineStyle = input.string("Dotted", "Mid Line Style", options=["Solid", "Dashed", "Dotted"], group="Levels")
osLineColor = input.color(color.green, "OverSold Line Color", group="Levels")
osLineWidth = input.int(1, "OverSold Line Width", minval=1, maxval=5, group="Levels")
osLineStyle = input.string("Solid", "OverSold Line Style", options=["Solid", "Dashed", "Dotted"], group="Levels")

// Background
showShading = input.bool(true, "Show Zone Shading", group="Background")
redBgColor = input.color(color.new(color.red, 60), "OverBought Zone Color", group="Background")
greenBgColor = input.color(color.new(color.green, 60), "OverSold Zone Color", group="Background")

// Style conversion
getLineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

getPlotStyle(s) =>
    s == "Dotted" ? plot.style_cross : plot.style_line

// DSO Calculation (Yellow Line)
xLowest = ta.lowest(close, dsoLengthK)
xHighest = ta.highest(close, dsoLengthK)
xFastK = ((close - xLowest) / (xHighest - xLowest)) * 100
xSlowingK = ta.sma(xFastK, dsoLengthSlowing)
xLLSl = ta.lowest(xSlowingK, dsoLengthK)
xHHSl = ta.highest(xSlowingK, dsoLengthK)
xDS = ((xSlowingK - xLLSl) / (xHHSl - xLLSl)) * 100
xDSlowingK = ta.sma(xDS, dsoLengthSlowing)

// Stoch Calculation (White Line)
percentK = ta.stoch(close, high, low, stochK)
percentD = ta.sma(percentK, stochD)

// Permanent zone fills
upperBand = plot(overboughtLevel, display=display.none, editable=false)
topBand = plot(100, display=display.none, editable=false)
lowerBand = plot(oversoldLevel, display=display.none, editable=false)
botBand = plot(0, display=display.none, editable=false)

fill(upperBand, topBand, color=showShading ? redBgColor : na, title="OverBought Fill")
fill(botBand, lowerBand, color=showShading ? greenBgColor : na, title="OverSold Fill")

// Draw level lines using line.new() - stops at current bar
var line obLine = na
var line midLine = na
var line osLine = na

if barstate.isfirst
    obLine := line.new(0, overboughtLevel, last_bar_index, overboughtLevel, extend=extend.none, color=obLineColor, width=obLineWidth, style=getLineStyle(obLineStyle))
    midLine := line.new(0, 50, last_bar_index, 50, extend=extend.none, color=midLineColor, width=midLineWidth, style=getLineStyle(midLineStyle))
    osLine := line.new(0, oversoldLevel, last_bar_index, oversoldLevel, extend=extend.none, color=osLineColor, width=osLineWidth, style=getLineStyle(osLineStyle))

if barstate.islast
    line.set_x2(obLine, bar_index)
    line.set_x2(midLine, bar_index)
    line.set_x2(osLine, bar_index)
    line.set_color(obLine, obLineColor)
    line.set_color(midLine, midLineColor)
    line.set_color(osLine, osLineColor)
    line.set_width(obLine, obLineWidth)
    line.set_width(midLine, midLineWidth)
    line.set_width(osLine, osLineWidth)
    line.set_style(obLine, getLineStyle(obLineStyle))
    line.set_style(midLine, getLineStyle(midLineStyle))
    line.set_style(osLine, getLineStyle(osLineStyle))

// Main plots
plot(xDSlowingK, "DSO - Yellow", color=yellowColor, linewidth=yellowWidth, style=getPlotStyle(yellowStyle))
plot(percentD, "Stoch - White", color=whiteColor, linewidth=whiteWidth, style=getPlotStyle(whiteStyle))
````

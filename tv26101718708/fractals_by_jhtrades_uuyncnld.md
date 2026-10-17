# Fractals (by JH-Trades)

- url: https://www.tradingview.com/script/UUYncnLd-Fractals-by-JH-Trades/
- type: indicator
- pine_id: PUB;4d9060d6a9a84a7894a1ae1f5ad986d1
- version: 1.0

## Description

This indicator give a nice way of looking for liquidity.

## Source Code

````pine
//@version=6
indicator("Fractals (by JH-Trades)", overlay=true, max_lines_count=500)

//--------------------------------------------------
// INPUTS
//--------------------------------------------------

leftBars  = input.int(2, "Fractal Left Bars", minval=1)
rightBars = input.int(2, "Fractal Right Bars", minval=1)

// Fractals
showHighFractals = input.bool(true, "Show High Fractals")
showLowFractals  = input.bool(true, "Show Low Fractals")

highColor = input.color(color.lime, "High Fractal Color")
lowColor  = input.color(color.red, "Low Fractal Color")

fractalStyle = input.string(
     "Triangle",
     "Fractal Style",
     options = ["Triangle", "Diamond", "Circle", "Cross", "Arrow"]
)

// Grootte instellen
fractalSize = input.string(
     "Tiny",
     "Fractal Size",
     options = ["Tiny", "Small", "Normal", "Large"]
)

// Lines
showLines      = input.bool(true, "Show Horizontal Lines")
lineColorHi    = input.color(color.lime, "High Line Color")
lineColorLo    = input.color(color.red, "Low Line Color")
lineWidth      = input.int(1, "Line Width", minval=1, maxval=5)

lineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"]
)

//--------------------------------------------------
// LINE STYLE
//--------------------------------------------------

lineStyle = switch lineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    => line.style_dotted

//--------------------------------------------------
// FRACTALS
//--------------------------------------------------

highFractal = ta.pivothigh(high, leftBars, rightBars)
lowFractal  = ta.pivotlow(low, leftBars, rightBars)

//--------------------------------------------------
// FRACTAL SHAPES
//--------------------------------------------------

highShape = switch fractalStyle
    "Triangle" => shape.triangledown
    "Diamond"  => shape.diamond
    "Circle"   => shape.circle
    "Cross"    => shape.cross
    => shape.arrowdown

lowShape = switch fractalStyle
    "Triangle" => shape.triangleup
    "Diamond"  => shape.diamond
    "Circle"   => shape.circle
    "Cross"    => shape.cross
    => shape.arrowup

//--------------------------------------------------
// PLOT FRACTALS BY SIZE
//--------------------------------------------------

// TINY
plotshape(
     showHighFractals and not na(highFractal) and fractalSize == "Tiny",
     style=highShape,
     location=location.abovebar,
     color=highColor,
     size=size.tiny,
     offset=-rightBars
)

plotshape(
     showLowFractals and not na(lowFractal) and fractalSize == "Tiny",
     style=lowShape,
     location=location.belowbar,
     color=lowColor,
     size=size.tiny,
     offset=-rightBars
)

// SMALL
plotshape(
     showHighFractals and not na(highFractal) and fractalSize == "Small",
     style=highShape,
     location=location.abovebar,
     color=highColor,
     size=size.small,
     offset=-rightBars
)

plotshape(
     showLowFractals and not na(lowFractal) and fractalSize == "Small",
     style=lowShape,
     location=location.belowbar,
     color=lowColor,
     size=size.small,
     offset=-rightBars
)

// NORMAL
plotshape(
     showHighFractals and not na(highFractal) and fractalSize == "Normal",
     style=highShape,
     location=location.abovebar,
     color=highColor,
     size=size.normal,
     offset=-rightBars
)

plotshape(
     showLowFractals and not na(lowFractal) and fractalSize == "Normal",
     style=lowShape,
     location=location.belowbar,
     color=lowColor,
     size=size.normal,
     offset=-rightBars
)

// LARGE
plotshape(
     showHighFractals and not na(highFractal) and fractalSize == "Large",
     style=highShape,
     location=location.abovebar,
     color=highColor,
     size=size.large,
     offset=-rightBars
)

plotshape(
     showLowFractals and not na(lowFractal) and fractalSize == "Large",
     style=lowShape,
     location=location.belowbar,
     color=lowColor,
     size=size.large,
     offset=-rightBars
)

//--------------------------------------------------
// ARRAYS
//--------------------------------------------------

var line[] highLines   = array.new_line()
var float[] highPrices = array.new_float()

var line[] lowLines    = array.new_line()
var float[] lowPrices  = array.new_float()

//--------------------------------------------------
// CREATE HIGH LINES
//--------------------------------------------------

if showLines and not na(highFractal)

    fractalBar = bar_index - rightBars

    newLine = line.new(
         x1=fractalBar,
         y1=highFractal,
         x2=bar_index,
         y2=highFractal,
         color=lineColorHi,
         width=lineWidth,
         style=lineStyle
     )

    array.push(highLines, newLine)
    array.push(highPrices, highFractal)

//--------------------------------------------------
// CREATE LOW LINES
//--------------------------------------------------

if showLines and not na(lowFractal)

    fractalBar = bar_index - rightBars

    newLine = line.new(
         x1=fractalBar,
         y1=lowFractal,
         x2=bar_index,
         y2=lowFractal,
         color=lineColorLo,
         width=lineWidth,
         style=lineStyle
     )

    array.push(lowLines, newLine)
    array.push(lowPrices, lowFractal)

//--------------------------------------------------
// UPDATE HIGH LINES
//--------------------------------------------------

if array.size(highLines) > 0

    for i = array.size(highLines) - 1 to 0

        currentLine  = array.get(highLines, i)
        currentPrice = array.get(highPrices, i)

        touched = high >= currentPrice

        if touched
            line.set_x2(currentLine, bar_index)

            array.remove(highLines, i)
            array.remove(highPrices, i)

        else
            line.set_x2(currentLine, bar_index)

//--------------------------------------------------
// UPDATE LOW LINES
//--------------------------------------------------

if array.size(lowLines) > 0

    for i = array.size(lowLines) - 1 to 0

        currentLine  = array.get(lowLines, i)
        currentPrice = array.get(lowPrices, i)

        touched = low <= currentPrice

        if touched
            line.set_x2(currentLine, bar_index)

            array.remove(lowLines, i)
            array.remove(lowPrices, i)

        else
            line.set_x2(currentLine, bar_index)
````

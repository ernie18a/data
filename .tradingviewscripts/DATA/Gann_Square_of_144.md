<!-- tradingview-pine-id: PUB;b692712a50b6481a9d35f86d8a921db0 -->
<!-- tradingviewscripts-format: 1 -->
# Gann Square of 144

Source: https://www.tradingview.com/script/7KmrAB2f-Gann-Square-of-144/

## Description

This indicator will create lines on the chart based on W.D. Gann's Square of 144. All the inputs will be detailed below

Why create this indicator?
I didn't find it on Tradingview (at least with open source). But the main reason is to study the strategy and be able to draw it fast. Manually drawing the square is not hard, but moving all together to the right spots and scale was time-consuming. 

It has a lot of inputs...
Yes, each square point divisible by 6 has information with some options, so the user can create any configuration he wants. Also, it has the advantage of having the square built in seconds and adjusting itself on each new calculation.

About the inputs

Starting Date
This input will be used when the "Set Upper/Lower Prices and Start Bar Automatically" checkbox is not selected. The indicator will calculate all the line locations on the chart using the selected start date. When selecting this input, change the Manual Max and Min Prices to the better calculation

Manual Max/Min Price
This input will be used when the "Set Upper/Lower Prices and Start Bar Automatically" checkbox is not selected. The indicator will calculate all the line's locations on the chart using these prices

Set Upper/Lower Prices and Start Bar Automatically
Selects if the starting date will be automatically selected by the system or based on the input data. When it's set, the indicator will use the most recent bar as the middle point of the square, using the higher price as the Upper Price and the lowest price as the Lower Price in the latest 72 bars (or more based on the Candles Per Division parameter)

Update at a new bar
When this option is market, the indicator will update all created lines to match the new bar position, together with all the possible new Upper/Lower prices. Let it unchecked to watch the progression of the price while the square remains fixed in the chart.

Top X-Axis
When checked, it will display the labels on the Top of the square

Bottom X-Axis
When checked, it will display the labels on the Bottom of the square

Left X-Axis
When checked, it will display the labels on the left of the square

Right X-Axis
When checked, it will display the labels on the right of the square

Show Prices on the Right Y-Axis
When checked, it will display the prices together with the labels on the right of the square

Show Vertical Divisions
Show the lines that will divide the square into 9 equal parts

Show Extra Lines
Show unique lines that will come from the Top and bottom middle of the square, connecting the center to the 36 and 108 levels

Show Grid
When selected, it will display a grid in the square

Line Patterns
A selector with some options of built-in lines configuration. When any option besides None is selected, it will override the lines inputs below

Numbers Color
Select the color of each number on the Axis

Vertical Lines Color
Select the color of the vertical lines

Grid Color
Select the grid line color 

Connections from corners to N
Each corner is represented by 2 characters, so they all fit in a single line
It will indicate where the line starts and where it ends

[*]┏ ↓ = Top Left to Bottom
[*]┏ → = Top Left to Right
[*]┗ ↑ = Bottom Left to Top
[*]┗ → = Bottom Left to Right
[*]┓ ← = Top Right to Left
[*]┓ ↓ = Top Right to Bottom
[*]┛ ← = Bottom Right to Left
[*]┛ ↑ = Bottom Right to Top

Besides selecting what line will be created, it's possible to select the color, the style, and the extension

How to use this indicator
When you dig into Gann's books for more information about the square of 144, you find that it was part of his setup with multiple indicators (technical and fundamental, and astrological). It is not a "one indicator" setup, so it's hard to say that you will find entries, exits, stop loss, and take profit in this. Still, it will help see trendiness, support, and resistance levels. 

Mixing this with other indicators is probably a good idea, but some may find this indicator the only one needed. 

Some aspects of the square
The end of the square is important, so where it starts is crucial. The end is important because it is where the price and time expire. The other parts of the square are defined based on their start and end, so placing them right is essential.

So, where to set the start of the square? 
The last major low is the most indicated. The minimum price will be the lowest, and the max price will be the last major Top. Note that the indicator uses 1 candle on each point.

After finding the start, the minimum, and the maximum prices for the square, it will draw all lines. Another essential part of the square is The Midpoint.

The midpoint is the most crucial part of the square and is the best way to see if you positioned the square correctly. When the price is inside the square, using the starting candle as the start, a second higher low or a lower high occurs in that spot. When using the Vertical lines in the indicator, it's the middle square inside Gann's square. 

The other divisions will be opposing each other most of the time. So if the price is rising in the 1/3 of the square, it's common to see the price fall in the 3/3 of the square.

More information about these aspects [here](https://sacredtraders.com/tbonds-and-gann-s-square-of-144-by-phyllis-kahn/)

Considerations
This indicator was meant for price targets and a time calculator for possible support/resistances in the chart. It was created by William Delbert Gann and was part of his setup for trading almost a century ago. The lines will form geometric figures, which Gann used with high accuracy to predict tops/bottoms and when they would occur.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThiagoSchmitz

//@version=5
indicator("Gann Square of 144", overlay=true, max_lines_count=500, max_labels_count=500)
// *****************************************************************************
// ********************************* Constants *********************************
// *****************************************************************************
string groupInlineXYLabels      = "X-Axis and Y-Axis Labels"
string groupInlineExtraLines    = "Extra Lines"
string groupInlineColors        = "colors"
string groupInlineSquare        = "squarecolors"
int squares                     = 144
int barIndex                    = bar_index
float barHigh                   = high
float barLow                    = low
string lineDashed               = line.style_dashed
string lineDotted               = line.style_dotted
string lineSolid                = line.style_solid
string lineNone                 = label.style_none
bool barstateIsNew              = barstate.isnew
bool barstateIsLast             = barstate.islast
color colorRed                  = color.red
color colorWhite                = color.white

// *****************************************************************************
// ********************************* Inputs ************************************
// *****************************************************************************
var int startDate          = input.time(timestamp("2022-11-01"), "Starting Date")
var float maxPrice         = input.float(69198.0, "Manual Max Price")
var float minPrice         = input.float(17595.0, "Manual Min Price")
var bool autoPricesAndBar  = input.bool(true,     "Set Upper/Lower Prices and Start Bar Automatically")
var bool updateNewBar      = input.bool(true,     "Update at new bar")
var int candlesPerDivision = input.int(1,         "Candles per division", minval=1)
var bool showTopXAxis      = input.bool(false,    "Top X-Axis", inline=groupInlineXYLabels, group=groupInlineXYLabels)
var bool showBottomXAxis   = input.bool(true,     "Bottom X-Axis", inline=groupInlineXYLabels, group=groupInlineXYLabels)
var bool showLeftYAxis     = input.bool(false,    "Left Y-Axis", inline=groupInlineXYLabels, group=groupInlineXYLabels)
var bool showRightYAxis    = input.bool(true,     "Right Y-Axis", inline=groupInlineXYLabels, group=groupInlineXYLabels)
var bool showPrices        = input.bool(true,     "Show Prices on the Right Y-Axis", inline=groupInlineXYLabels, group=groupInlineXYLabels)
var bool showDivisions     = input.bool(true,     "Show Vertical Divisions", inline=groupInlineExtraLines, group=groupInlineExtraLines)
var bool showExtraLines    = input.bool(true,     "Show Extra Lines", inline=groupInlineExtraLines, group=groupInlineExtraLines)
var bool showGrid          = input.bool(true,     "Show Grid", inline=groupInlineExtraLines, group=groupInlineExtraLines)
var bool showBackground    = input.bool(true,     "Show Background", inline=groupInlineExtraLines, group=groupInlineExtraLines)
var string patterns        = input.string("None", "Line Patterns", options=["None", "Arrow", "Star", "36, 72, and 108", "Arrow Cross", "Corners and Cross", "Master"], group="patterns")
var color labelColor       = input.color(color.green,                "Numbers Color",              inline=groupInlineColors, group=groupInlineColors)
var color divisionsColor   = input.color(color.blue,                 "Vertical Lines Color",       inline=groupInlineColors, group=groupInlineColors)
var color gridColor        = input.color(color.gray,                 "Grid Color",                 inline=groupInlineColors, group=groupInlineColors)
var color TLSColor         = input.color(color.new(color.green, 80), "Top Left Square Color",      inline=groupInlineSquare, group=groupInlineSquare)
var color TMSColor         = input.color(color.new(color.red, 80), "Top Middle Square Color",    inline=groupInlineSquare, group=groupInlineSquare)
var color TRSColor         = input.color(color.new(color.green, 80), "Top Right Square Color",     inline=groupInlineSquare, group=groupInlineSquare)
var color CLSColor         = input.color(color.new(color.green, 80),   "Center Left Square Color",   inline=groupInlineSquare, group=groupInlineSquare)
var color CMSColor         = input.color(color.new(color.red, 80),   "Center Middle Square Color", inline=groupInlineSquare, group=groupInlineSquare)
var color CRSColor         = input.color(color.new(color.green, 80),   "Center Right Square Color",  inline=groupInlineSquare, group=groupInlineSquare)
var color BLSColor         = input.color(color.new(color.green, 80), "Bottom Left Square Color",   inline=groupInlineSquare, group=groupInlineSquare)
var color BMSColor         = input.color(color.new(color.red, 80), "Bottom Middle Square Color", inline=groupInlineSquare, group=groupInlineSquare)
var color BRSColor         = input.color(color.new(color.green, 80), "Bottom Right Square Color",  inline=groupInlineSquare, group=groupInlineSquare)
var int dateBarIndex       = 0

if time == startDate
    dateBarIndex := barIndex
// *****************************************************************************
// ******************************** Variables **********************************
// *****************************************************************************
int startBarIndex    = autoPricesAndBar ? barIndex - math.floor(squares * candlesPerDivision / 2) : dateBarIndex
int endBarIndex      = startBarIndex + squares * candlesPerDivision
int middleBarIndex   = startBarIndex + squares * candlesPerDivision / 2
int onethirdPriceBar = (endBarIndex - startBarIndex) / 3
int barDiff          = squares - math.abs(endBarIndex - barIndex)
int barIndexDiff     = barDiff <= 0 ? 1 : barDiff
float atr            = ta.atr(5)
float highest        = ta.highest(math.floor(squares * candlesPerDivision / 2) + 1)
float lowest         = ta.lowest(math.floor(squares * candlesPerDivision/ 2) + 1)
float lowerPrice     = autoPricesAndBar ? lowest : minPrice
float upperPrice     = autoPricesAndBar ? highest : maxPrice
float middlePrice    = lowerPrice + (upperPrice - lowerPrice) / 2
float onethirdPrice  = (upperPrice - lowerPrice) / 3

// *****************************************************************************
// *************************** One-Time Variables ******************************
// *****************************************************************************
var box squareLines          = box.new(barIndex, barHigh, barIndex, barLow, color.new(colorWhite, 50), 2, bgcolor=na)
var bool buildSquareDone     = false
var bool buildInputsDone     = false
var bool[] dashedLineStyles  = array.new_bool()
var bool[] extendLines       = array.new_bool()
var bool[] showGroup         = array.new_bool()
var color[] lineColors       = array.new_color()
var label[] bottomXAxisArray = array.new_label()
var label[] leftYAxisArray   = array.new_label()
var label[] rightYAxisArray  = array.new_label()
var label[] topXAxisArray    = array.new_label()
var line[] BLRArray          = array.new_line()
var line[] BLTArray          = array.new_line()
var line[] BRLArray          = array.new_line()
var line[] BRTArray          = array.new_line()
var line[] TLBArray          = array.new_line()
var line[] TLRArray          = array.new_line()
var line[] TRBArray          = array.new_line()
var line[] TRLArray          = array.new_line()
var line[] divisionsArray    = array.new_line()
var line[] extraArray        = array.new_line()
var line[] gridArray         = array.new_line()
var box back1Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=TLSColor)
var box back2Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=TMSColor)
var box back3Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=TRSColor)
var box back4Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=CLSColor)
var box back5Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=CMSColor)
var box back6Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=CRSColor)
var box back7Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=BLSColor)
var box back8Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=BMSColor)
var box back9Square          = box.new(barIndex, barHigh, barIndex, barLow, na, 0, bgcolor=BRSColor)

// *****************************************************************************
// ******************************** Fucntions **********************************
// *****************************************************************************

// =============================================================================
// * This function will update the box that goes on the edge of the Gann's
// * square
// =============================================================================
updateBox() =>
    box.set_left(squareLines, startBarIndex)
    box.set_top(squareLines, upperPrice)
    box.set_right(squareLines, endBarIndex)
    box.set_bottom(squareLines, lowerPrice)

// =============================================================================
// * This function will update the background of the Gann's square
// =============================================================================
updateBackgrounds() =>
    s1 = startBarIndex
    s2 = startBarIndex + ((squares / 3) * candlesPerDivision)
    s3 = startBarIndex + ((squares / 3) * 2 * candlesPerDivision)
    s4 = endBarIndex
    t1 = upperPrice
    t2 = upperPrice - ((upperPrice - lowerPrice) / 3)
    t3 = upperPrice - ((upperPrice - lowerPrice) / 3) * 2
    t4 = lowerPrice

    box.set_left(back1Square, s1)
    box.set_right(back1Square, s2)
    box.set_top(back1Square, t1)
    box.set_bottom(back1Square, t2)
    
    box.set_left(back2Square, s2)
    box.set_right(back2Square, s3)
    box.set_top(back2Square, t1)
    box.set_bottom(back2Square, t2)

    box.set_left(back3Square, s3)
    box.set_right(back3Square, s4)
    box.set_top(back3Square, t1)
    box.set_bottom(back3Square, t2)

    box.set_left(back4Square, s1)
    box.set_right(back4Square, s2)
    box.set_top(back4Square, t2)
    box.set_bottom(back4Square, t3)

    box.set_left(back5Square, s2)
    box.set_right(back5Square, s3)
    box.set_top(back5Square, t2)
    box.set_bottom(back5Square, t3)

    box.set_left(back6Square, s3)
    box.set_right(back6Square, s4)
    box.set_top(back6Square, t2)
    box.set_bottom(back6Square, t3)

    box.set_left(back7Square, s1)
    box.set_right(back7Square, s2)
    box.set_top(back7Square, t3)
    box.set_bottom(back7Square, t4)

    box.set_left(back8Square, s2)
    box.set_right(back8Square, s3)
    box.set_top(back8Square, t3)
    box.set_bottom(back8Square, t4)

    box.set_left(back9Square, s3)
    box.set_right(back9Square, s4)
    box.set_top(back9Square, t3)
    box.set_bottom(back9Square, t4)

// =============================================================================
// * Build both X-Axis and y-Axis labels
// * It will use the topXAxisArray, bottomXAxisArray, rightYAxisArray, and
// * leftYAxisArray arrays to store each label, if they are enabled to be shown
// =============================================================================
buildAxis() =>
    for int j = 0 to squares by 6
        if showTopXAxis
            array.push(topXAxisArray, label.new(startBarIndex + j * candlesPerDivision, upperPrice + atr / 4, str.tostring(j), style=lineNone, textcolor=labelColor))
        if showBottomXAxis
            array.push(bottomXAxisArray, label.new(startBarIndex + j * candlesPerDivision, lowerPrice - atr / 2, str.tostring(j), style=lineNone, textcolor=labelColor))
        if showRightYAxis
            price = upperPrice - (upperPrice - lowerPrice) / squares * j
            t = str.tostring(j) + (showPrices ? " (" + str.tostring(math.round_to_mintick(price)) + ")" : "")
            array.push(rightYAxisArray, label.new(endBarIndex + 8 * candlesPerDivision, price, t, style=lineNone, textcolor=labelColor))
        if showLeftYAxis
            array.push(leftYAxisArray, label.new(startBarIndex - 3, upperPrice - (upperPrice - lowerPrice) / squares * j, str.tostring(j), style=lineNone, textcolor=labelColor))

// =============================================================================
// * Update both X-Axis and y-Axis labels
// =============================================================================
updateAxis() =>
    for int j = 0 to squares - 1 by 6
        if showTopXAxis
            label.set_x(array.get(topXAxisArray,    j / 6), startBarIndex + j * candlesPerDivision)
            label.set_y(array.get(topXAxisArray,    j / 6), upperPrice + atr / 4)
        if showBottomXAxis
            label.set_x(array.get(bottomXAxisArray, j / 6), startBarIndex + j * candlesPerDivision)
            label.set_y(array.get(bottomXAxisArray, j / 6), lowerPrice - atr / 2)
        if showRightYAxis
            label.set_x(array.get(rightYAxisArray,  j / 6), endBarIndex + 8 * candlesPerDivision)
            label.set_y(array.get(rightYAxisArray,  j / 6), upperPrice - (upperPrice - lowerPrice) / squares * j)
        if showLeftYAxis
            label.set_x(array.get(rightYAxisArray,  j / 6), startBarIndex - 3)
            label.set_y(array.get(rightYAxisArray,  j / 6), upperPrice - (upperPrice - lowerPrice) / squares * j)

// =============================================================================
// * Build the vertical divisions to divide the square in 9 smaller squares
// =============================================================================
buildDivisions() =>
    array.push(divisionsArray, line.new(startBarIndex, lowerPrice + onethirdPrice, endBarIndex, lowerPrice + onethirdPrice, color=divisionsColor, style=lineDashed))
    array.push(divisionsArray, line.new(startBarIndex, lowerPrice + onethirdPrice * 2, endBarIndex, lowerPrice + onethirdPrice * 2, color=divisionsColor, style=lineDashed))
    array.push(divisionsArray, line.new(startBarIndex + onethirdPriceBar, upperPrice, startBarIndex + onethirdPriceBar, lowerPrice, color=divisionsColor, style=lineDashed))
    array.push(divisionsArray, line.new(startBarIndex + onethirdPriceBar * 2, upperPrice, startBarIndex + onethirdPriceBar * 2, lowerPrice, color=divisionsColor, style=lineDashed))

// =============================================================================
// * Update the vertical divisions
// =============================================================================
updateDivisions() =>
    line.set_xy1(array.get(divisionsArray, 0), startBarIndex, lowerPrice + onethirdPrice)
    line.set_xy2(array.get(divisionsArray, 0), endBarIndex, lowerPrice + onethirdPrice)
    line.set_xy1(array.get(divisionsArray, 1), startBarIndex, lowerPrice + onethirdPrice * 2)
    line.set_xy2(array.get(divisionsArray, 1), endBarIndex, lowerPrice + onethirdPrice * 2)
    line.set_xy1(array.get(divisionsArray, 2), startBarIndex + onethirdPriceBar, upperPrice)
    line.set_xy2(array.get(divisionsArray, 2), startBarIndex + onethirdPriceBar, lowerPrice)
    line.set_xy1(array.get(divisionsArray, 3), startBarIndex + onethirdPriceBar * 2, upperPrice)
    line.set_xy2(array.get(divisionsArray, 3), startBarIndex + onethirdPriceBar * 2, lowerPrice)

// =============================================================================
// * Build the Gann's square. It will create lines based on the inputs and store
// * them in some arrays. It will use the showGroup array to check if the line
// * needs to be created or not. If showExtraLines is enabled, it will create 
// * specific lines to provide the original Gann's Square format
// =============================================================================    
buildSquare() =>
    for int i = 0 to (squares / 6) - 1
        int endIndex = startBarIndex + 6 * (i + 1) * candlesPerDivision
        float endPrice = upperPrice - ((upperPrice - lowerPrice) / squares) * 6 * (i + 1)
        string style = array.get(dashedLineStyles, i) ? lineDashed : lineSolid
        string extend = array.get(extendLines, i) ? extend.both : extend.none
        if array.get(showGroup, i * 8)
            // Top Left Bottom
            array.push(TLBArray, line.new(startBarIndex, upperPrice, endIndex, lowerPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 1)
            // Top Left Right
            array.push(TLRArray, line.new(startBarIndex, upperPrice, endBarIndex, endPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 2)
            // Bottom Left Top
            array.push(BLTArray, line.new(startBarIndex, lowerPrice, endIndex, upperPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 3)
            // Bottom Left Right
            array.push(BLRArray, line.new(startBarIndex, lowerPrice, endBarIndex, endPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 4)
            // Top Right Bottom
            array.push(TRBArray, line.new(endBarIndex, upperPrice, endIndex, lowerPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 5)
            // Top Right Left
            array.push(TRLArray, line.new(endBarIndex, upperPrice, startBarIndex, endPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 6)
            // Bottom Right Top
            array.push(BRTArray, line.new(endBarIndex, lowerPrice, endIndex, upperPrice, color=array.get(lineColors, i), style=style, extend=extend))
        if array.get(showGroup, i * 8 + 7)
            // Bottom Right Left
            array.push(BRLArray, line.new(endBarIndex, lowerPrice, startBarIndex, endPrice, color=array.get(lineColors, i), style=style, extend=extend))
    if showExtraLines
        array.push(extraArray, line.new(middleBarIndex, upperPrice, startBarIndex,  upperPrice - ((upperPrice - lowerPrice) / squares) * 36,    color=colorRed, style=lineDashed))
        array.push(extraArray, line.new(middleBarIndex, upperPrice, endBarIndex,    upperPrice - ((upperPrice - lowerPrice) / squares) * 36,    color=colorRed, style=lineDashed))
        array.push(extraArray, line.new(middleBarIndex, lowerPrice, startBarIndex,  upperPrice - ((upperPrice - lowerPrice) / squares) * 108,   color=colorRed, style=lineDashed))
        array.push(extraArray, line.new(middleBarIndex, lowerPrice, endBarIndex,    upperPrice - ((upperPrice - lowerPrice) / squares) * 108,   color=colorRed, style=lineDashed))
 
// =============================================================================
// * Update each line created for the Gann's square
// =============================================================================    
updateSquare() =>
    if  array.size(TLBArray) == (squares / 6) - 1 and
           array.size(TLRArray) == (squares / 6) - 1 and
           array.size(BLTArray) == (squares / 6) - 1
        
        for int i = 0 to (squares / 6) - 1
            int endIndex = startBarIndex + 6 * i * candlesPerDivision
            float endPrice = upperPrice - ((upperPrice - lowerPrice) / squares) * 6 * i
            if array.get(showGroup, i * 8)
                // Top Left Bottom
                line.set_xy1(array.get(TLBArray, i), startBarIndex, upperPrice)
                line.set_xy2(array.get(TLBArray, i), endIndex,      lowerPrice)
            if array.get(showGroup, i * 8 + 1)
                // Top Left Right
                line.set_xy1(array.get(TLRArray, i), startBarIndex, upperPrice)
                line.set_xy2(array.get(TLRArray, i), endBarIndex,   endPrice)
            if array.get(showGroup, i * 8 + 2)
                // Bottom Left Top
                line.set_xy1(array.get(BLTArray, i), startBarIndex, lowerPrice)
                line.set_xy2(array.get(BLTArray, i), endIndex,      upperPrice)
            if array.get(showGroup, i * 8 + 3)
                // Bottom Left Right
                line.set_xy1(array.get(BLRArray, i), startBarIndex, lowerPrice)
                line.set_xy2(array.get(BLRArray, i), endBarIndex,   endPrice)
            if array.get(showGroup, i * 8 + 4)
                // Top Right Bottom
                line.set_xy1(array.get(TRBArray, i), endBarIndex,   upperPrice)
                line.set_xy2(array.get(TRBArray, i), endIndex,      lowerPrice)
            if array.get(showGroup, i * 8 + 5)
                // Top Right Left
                line.set_xy1(array.get(TRLArray, i), endBarIndex,   upperPrice)
                line.set_xy2(array.get(TRLArray, i), startBarIndex, endPrice)
            if array.get(showGroup, i * 8 + 6)
                // Bottom Right Top
                line.set_xy1(array.get(BRTArray, i), endBarIndex,   lowerPrice)
                line.set_xy2(array.get(BRTArray, i), endIndex,      upperPrice)
            if array.get(showGroup, i * 8 + 7)
                // Bottom Right Left
                line.set_xy1(array.get(BRLArray, i), endBarIndex,   lowerPrice)
                line.set_xy2(array.get(BRLArray, i), startBarIndex, endPrice)

// =============================================================================
// * Create the grid lines for reference
// =============================================================================
buildGrid() =>
    for int i = 0 to 23
        index = startBarIndex + 6 * (i + 1) * candlesPerDivision
        price = upperPrice - ((upperPrice - lowerPrice) / squares) *  6 * (i + 1)
        array.push(gridArray, line.new(index, upperPrice, index, lowerPrice, color=gridColor, style=lineDotted))
        array.push(gridArray, line.new(startBarIndex, price, endBarIndex, price, color=gridColor, style=lineDotted))

// =============================================================================
// * Update the grid lines
// =============================================================================
updateGrid() =>
    for int i = 0 to 23
        index = startBarIndex + 6 * (i + 1) * candlesPerDivision
        price = upperPrice - ((upperPrice - lowerPrice) / squares) *  6 * (i + 1)
        line.set_xy1(array.get(gridArray, i * 2), index, upperPrice)
        line.set_xy2(array.get(gridArray, i * 2), index, lowerPrice)
        line.set_xy1(array.get(gridArray, i * 2 + 1), startBarIndex, price)
        line.set_xy2(array.get(gridArray, i * 2 + 1), endBarIndex, price)

// =============================================================================
// * Set lines pattern to override the parameters input of each division. When an
// * option besides None is selected, it will ignore the selections of each line
// =============================================================================
setPattern() =>
    if patterns != "None"
        for int i = 0 to array.size(showGroup) - 1
            array.set(showGroup, i, false)
    if patterns == "Arrow"
        array.set(showGroup, 88, true) // Top Left to Bottom 72
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
    else if patterns == "Star"
        array.set(showGroup, 88, true) // Top Left to Bottom 72 
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
        array.set(showGroup, 92, true) // Top Right to Bottom 72
        array.set(showGroup, 93, true) // Top Right to Left 72
        array.set(showGroup, 94, true) // Bottom Right to Top 72
        array.set(showGroup, 95, true) // Bottom Right to Left 72
    else if patterns == "36, 72, and 108"
        array.set(showGroup, 40, true) // Top Left to Bottom 36
        array.set(showGroup, 41, true) // Top Left to Right 36
        array.set(showGroup, 42, true) // Bottom Left to Top 36
        array.set(showGroup, 45, true) // Top Right to Left 36
        array.set(showGroup, 88, true) // Top Left to Bottom 72
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
        array.set(showGroup, 92, true) // Top Right to Bottom 72
        array.set(showGroup, 93, true) // Top Right to Left 72
        array.set(showGroup, 94, true) // Bottom Right to Top 72
        array.set(showGroup, 95, true) // Bottom Right to Left 72
        array.set(showGroup, 139, true) // Bottom Left to Right 108
        array.set(showGroup, 140, true) // Top Right to Bottom 108
        array.set(showGroup, 142, true) // Bottom Right to Top 108
        array.set(showGroup, 143, true) // Bottom Right to Left 108
        array.set(showGroup, 184, true) // Top Left to Corner 144
        array.set(showGroup, 186, true) // Top Right to Corner 144
    else if patterns == "Arrow Cross"
        array.set(showGroup, 88, true) // Top Left to Bottom 72
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
        array.set(showGroup, 184, true) // Top Left to Corner 144
        array.set(showGroup, 186, true) // Top Right to Corner 144
    else if patterns == "Corners and Cross"
        array.set(showGroup, 88, true) // Top Left to Bottom 72
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
        array.set(showGroup, 92, true) // Top Right to Bottom 72
        array.set(showGroup, 93, true) // Top Right to Left 72
        array.set(showGroup, 94, true) // Bottom Right to Top 72
        array.set(showGroup, 95, true) // Bottom Right to Left 72
        array.set(showGroup, 184, true) // Top Left to Corner 144
        array.set(showGroup, 186, true) // Top Right to Corner 144
    else if patterns == "Master"
        array.set(showGroup, 42, true) // Bottom Left to Top 36
        array.set(showGroup, 43, true) // Bottom Left to Right 36
        array.set(showGroup, 88, true) // Top Left to Bottom 72
        array.set(showGroup, 89, true) // Top Left to Right 72
        array.set(showGroup, 90, true) // Bottom Left to Top 72
        array.set(showGroup, 91, true) // Bottom Left to Right 72
        array.set(showGroup, 138, true) // Bottom Left to Top 108
        array.set(showGroup, 139, true) // Bottom Left to Right 108
        array.set(showGroup, 184, true) // Top Left to Corner 144
        array.set(showGroup, 186, true) // Top Right to Corner 144
        
// *****************************************************************************
// ************************** Run On Every Tick ********************************
// *****************************************************************************
if updateNewBar and buildSquareDone and barstateIsNew and autoPricesAndBar
    updateSquare()
    updateAxis()
    updateBox()
    if showDivisions
        updateDivisions()
    if showGrid
        updateGrid()
    // if showBackground
    //     updateBackgrounds()

// *****************************************************************************
// ****************************** Run Once *************************************
// *****************************************************************************
if buildInputsDone
    if time == startDate
        startBarIndex := barIndex
    if barstateIsLast and not buildSquareDone
        setPattern()
        updateBox()
        buildSquare()
        buildAxis() 
        if showDivisions
            buildDivisions()
        if showGrid
            buildGrid()
        if showBackground
            updateBackgrounds()
        buildSquareDone := true

// =============================================================================
// * Create all the lines inputs, together with the color of each one, line style and 
// * extend type. The default values are those originally found in W.D. Gann's book.
// * The order of each line matters for the comparison inside the functions
// =============================================================================
if not buildInputsDone
    buildInputsDone := true
    lineColors := array.concat(lineColors, array.from(
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 6"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 12"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 18"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 24"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 30"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 36"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 42"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 48"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 54"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 60"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 66"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 72"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 78"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 84"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 90"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 96"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 102"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 108"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 114"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 120"),
           input.color(color.red, "Line Color",   inline="line", group="Connections from corners to 126"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 132"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 138"),
           input.color(color.green, "Line Color", inline="line", group="Connections from corners to 144")))
           
    extendLines := array.concat(extendLines, array.from(
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 6"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 12"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 18"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 24"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 30"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 36"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 42"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 48"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 54"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 60"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 66"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 72"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 78"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 84"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 90"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 96"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 102"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 108"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 114"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 120"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 126"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 132"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 138"),
           input.bool(false, "Extend Line", inline="line", group="Connections from corners to 144")))
    
    dashedLineStyles := array.concat(dashedLineStyles, array.from(
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 6"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 12"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 18"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 24"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 30"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 36"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 42"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 48"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 54"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 60"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 66"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 72"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 78"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 84"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 90"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 96"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 102"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 108"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 114"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 120"),
           input.bool(true, "Dashed Line",  inline="line", group="Connections from corners to 126"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 132"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 138"),
           input.bool(false, "Dashed Line", inline="line", group="Connections from corners to 144")))
    
    showGroup := array.concat(showGroup, array.from(
           input.bool(false, "┏ ↓", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┏ →", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┗ ↑", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┗ →", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┓ ←", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┓ ↓", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┛ ←", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┛ ↑", inline="6",  group="Connections from corners to 6"),
           input.bool(false, "┏ ↓", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┏ →", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┗ ↑", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┗ →", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┓ ←", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┓ ↓", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┛ ←", inline="12", group="Connections from corners to 12"),
           input.bool(false, "┛ ↑", inline="12", group="Connections from corners to 12"),
           input.bool(true, "┏ ↓",  inline="18", group="Connections from corners to 18"),
           input.bool(true, "┏ →",  inline="18", group="Connections from corners to 18"),
           input.bool(true, "┗ ↑",  inline="18", group="Connections from corners to 18"),
           input.bool(false, "┗ →", inline="18", group="Connections from corners to 18"),
           input.bool(false, "┓ ←", inline="18", group="Connections from corners to 18"),
           input.bool(false, "┓ ↓", inline="18", group="Connections from corners to 18"),
           input.bool(false, "┛ ←", inline="18", group="Connections from corners to 18"),
           input.bool(false, "┛ ↑", inline="18", group="Connections from corners to 18"),
           input.bool(false, "┏ ↓", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┏ →", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┗ ↑", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┗ →", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┓ ←", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┓ ↓", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┛ ←", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┛ ↑", inline="24", group="Connections from corners to 24"),
           input.bool(false, "┏ ↓", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┏ →", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┗ ↑", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┗ →", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┓ ←", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┓ ↓", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┛ ←", inline="30", group="Connections from corners to 30"),
           input.bool(false, "┛ ↑", inline="30", group="Connections from corners to 30"),
           input.bool(true, "┏ ↓",  inline="36", group="Connections from corners to 36"),
           input.bool(true, "┏ →",  inline="36", group="Connections from corners to 36"),
           input.bool(true, "┗ ↑",  inline="36", group="Connections from corners to 36"),
           input.bool(false, "┗ →", inline="36", group="Connections from corners to 36"),
           input.bool(false, "┓ ←", inline="36", group="Connections from corners to 36"),
           input.bool(false, "┓ ↓", inline="36", group="Connections from corners to 36"),
           input.bool(false, "┛ ←", inline="36", group="Connections from corners to 36"),
           input.bool(false, "┛ ↑", inline="36", group="Connections from corners to 36"),
           input.bool(false, "┏ ↓", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┏ →", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┗ ↑", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┗ →", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┓ ←", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┓ ↓", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┛ ←", inline="42", group="Connections from corners to 42"),
           input.bool(false, "┛ ↑", inline="42", group="Connections from corners to 42"),
           input.bool(true, "┏ ↓",  inline="48", group="Connections from corners to 48"),
           input.bool(true, "┏ →",  inline="48", group="Connections from corners to 48"),
           input.bool(true, "┗ ↑",  inline="48", group="Connections from corners to 48"),
           input.bool(false, "┗ →", inline="48", group="Connections from corners to 48"),
           input.bool(false, "┓ ←", inline="48", group="Connections from corners to 48"),
           input.bool(false, "┓ ↓", inline="48", group="Connections from corners to 48"),
           input.bool(false, "┛ ←", inline="48", group="Connections from corners to 48"),
           input.bool(false, "┛ ↑", inline="48", group="Connections from corners to 48"),
           input.bool(false, "┏ ↓", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┏ →", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┗ ↑", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┗ →", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┓ ←", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┓ ↓", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┛ ←", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┛ ↑", inline="54", group="Connections from corners to 54"),
           input.bool(false, "┏ ↓", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┏ →", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┗ ↑", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┗ →", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┓ ←", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┓ ↓", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┛ ←", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┛ ↑", inline="60", group="Connections from corners to 60"),
           input.bool(false, "┏ ↓", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┏ →", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┗ ↑", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┗ →", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┓ ←", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┓ ↓", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┛ ←", inline="66", group="Connections from corners to 66"),
           input.bool(false, "┛ ↑", inline="66", group="Connections from corners to 66"),
           input.bool(true, "┏ ↓",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┏ →",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┗ ↑",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┗ →",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┓ ←",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┓ ↓",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┛ ←",  inline="72", group="Connections from corners to 72"),
           input.bool(true, "┛ ↑",  inline="72", group="Connections from corners to 72"),
           input.bool(false, "┏ ↓", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┏ →", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┗ ↑", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┗ →", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┓ ←", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┓ ↓", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┛ ←", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┛ ↑", inline="78", group="Connections from corners to 78"),
           input.bool(false, "┏ ↓", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┏ →", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┗ ↑", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┗ →", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┓ ←", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┓ ↓", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┛ ←", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┛ ↑", inline="84", group="Connections from corners to 84"),
           input.bool(false, "┏ ↓", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┏ →", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┗ ↑", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┗ →", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┓ ←", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┓ ↓", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┛ ←", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┛ ↑", inline="90", group="Connections from corners to 90"),
           input.bool(false, "┏ ↓", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┏ →", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┗ ↑", inline="96", group="Connections from corners to 96"),
           input.bool(true, "┗ →",  inline="96", group="Connections from corners to 96"),
           input.bool(false, "┓ ←", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┓ ↓", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┛ ←", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┛ ↑", inline="96", group="Connections from corners to 96"),
           input.bool(false, "┏ ↓", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┏ →", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┗ ↑", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┗ →", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┓ ←", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┓ ↓", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┛ ←", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┛ ↑", inline="102", group="Connections from corners to 102"),
           input.bool(false, "┏ ↓", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┏ →", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┗ ↑", inline="108", group="Connections from corners to 108"),
           input.bool(true, "┗ →",  inline="108", group="Connections from corners to 108"),
           input.bool(false, "┓ ←", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┓ ↓", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┛ ←", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┛ ↑", inline="108", group="Connections from corners to 108"),
           input.bool(false, "┏ ↓", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┏ →", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┗ ↑", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┗ →", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┓ ←", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┓ ↓", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┛ ←", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┛ ↑", inline="114", group="Connections from corners to 114"),
           input.bool(false, "┏ ↓", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┏ →", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┗ ↑", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┗ →", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┓ ←", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┓ ↓", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┛ ←", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┛ ↑", inline="120", group="Connections from corners to 120"),
           input.bool(false, "┏ ↓", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┏ →", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┗ ↑", inline="126", group="Connections from corners to 126"),
           input.bool(true, "┗ →",  inline="126", group="Connections from corners to 126"),
           input.bool(false, "┓ ←", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┓ ↓", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┛ ←", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┛ ↑", inline="126", group="Connections from corners to 126"),
           input.bool(false, "┏ ↓", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┏ →", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┗ ↑", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┗ →", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┓ ←", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┓ ↓", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┛ ←", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┛ ↑", inline="132", group="Connections from corners to 132"),
           input.bool(false, "┏ ↓", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┏ →", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┗ ↑", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┗ →", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┓ ←", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┓ ↓", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┛ ←", inline="138", group="Connections from corners to 138"),
           input.bool(false, "┛ ↑", inline="138", group="Connections from corners to 138"),
           input.bool(true, "┏ ↓",  inline="144", group="Connections from corners to 144"),
           input.bool(true, "┏ →",  inline="144", group="Connections from corners to 144"),
           input.bool(true, "┗ ↑",  inline="144", group="Connections from corners to 144"),
           input.bool(true, "┗ →",  inline="144", group="Connections from corners to 144"),
           input.bool(false, "┓ ←", inline="144", group="Connections from corners to 144"),
           input.bool(false, "┓ ↓", inline="144", group="Connections from corners to 144"),
           input.bool(false, "┛ ←", inline="144", group="Connections from corners to 144"),
           input.bool(false, "┛ ↑", inline="144", group="Connections from corners to 144")))
````

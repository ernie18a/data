<!-- tradingview-pine-id: PUB;e764b93365ee4ba6873926bee036bade -->
<!-- tradingviewscripts-format: 1 -->
# Auto Fibonacci and Gann Fan/Retracements Combo

Source: https://www.tradingview.com/script/YLn2bNaa-Auto-Fibonacci-and-Gann-Fan-Retracements-Combo/

## Description

Introduction

This is a combination of Fibonacci and Gann fan/retracements.
The script can automatically draw as many:

[*]Fibonacci Retracements
[*]Fibonacci Fan
[*]Gann Retracements
[*]Gann Fan

as the user requires on the chart. Each level set or fan consists of 7 lines based on the most important ratios of Fibonacci/Gann.

Basics

What are Fibonacci retracements?
Fibonacci retracement levels are horizontal lines that indicate where support and resistance are likely to occur. They stem from Fibonacci’s sequence. Each level is associated with a percentage which is how much of a prior move the price has retraced. The Fibonacci retracement levels are 23.6%, 38.2%, 61.8%, and 78.6%. While not officially a Fibonacci ratio, 50% is also used. The indicator is useful because it can be drawn between any two significant price points, such as a high and a low. The indicator will then create the levels between those two points.

What are Gann retracements?
A developer of technical analysis and trading was W.D. Gann. Gann theory expects a normal retracement of 50 percent. This means that under normal selling pressure, the stock price will decline half the amount of its most recent rise, and vice versa. It also suggests that retracements occur at the halfway point of a move, such as 25 percent (half of 50 percent), 12.5 percent (half of 25 percent), and so on.

What is Fibonacci fan?
Fibonacci fan is a set of sequential trend lines drawn from a trough or peak through a set of points dictated by Fibonacci retracements. The first step to create it is to draw a trend line covering the local lowest and highest prices of a security. To reach retracement levels, the trader divides the difference in price at the low and high end by ratios determined by the Fibonacci series. The lines formed by connecting the starting point for the base trend line and each retracement level create the Fibonacci fan.

What is Gann fan?
A Gann fan consists of a series of lines called Gann angles. These angles are superimposed over a price chart to show potential support and resistance levels. The resulting image is supposed to help technical analysts predict price changes. Gann believed the 45-degree angle to be most important, but the Gann fan also draws angles at degrees like 75, 63.75, 26.25 and 15. The Gann fan originates at a low or high point. The resulting lines show areas of potential future support and resistance. The 45-degree line is known as the 1:1 line because the price will rise or fall at a 45-degree angle when the price moves up/down one unit for each unit of time. All other lines in the Gann fan are drawn above and below the 1:1 line. The other angles are associated with 2:1, 3:1, 4:1, 8:1 and 1:8, 1:4, 1:3, and 1:2 time-to-price moves.

Challenges

The most of the time I dedicated to writing this script has been spent on handling these problems:

1. Finding Local Highest/Lowest Prices
In order to draw Fibonacci and Gann fan/retracements, it's necessary to find local highest and lowest price points (Extrema) on the chart. As this could be so challenging, most traders and coders draw the lines covering the low and high prices over a given period of time or a limited number of bars back instead. I already wrote an indicator using this approach ([Auto Fibonacci Combo](https://www.tradingview.com/script/IyzgHa86-Auto-Fibonacci-Combo/)).
In this new script I tried to find the exact highest and lowest prices based on this idea that: if a high point is formed lower than previous high which was after a lowest point, then that previous one was the local highest point, and vice versa if a low point is formed higher than previous low which was after a highest point, then that previous one was the local lowest point. So logically an extremum price on the chart won't be found until the next high/low point is formed.

2. Finding Proper Chart Scale for Gann Fan
Based on the theory, Gann angles are sensitive to the chart price scale and in order to have the right angles, the chart must be made with the proper scale. J.A. Hyerczyk in his book "Pattern, Price & Time - Using Gann Theory in Technical Analysis" suggests that the easiest way to determine the scale of a market is by taking the difference between top-to-top and bottom-to-bottom and dividing it by the time it took the market to move from top to top and bottom to bottom.
Thus on a properly constructed chart, the basic equation for calculating Gann angles is: Price * Time.

3. Drawing Fans and Relocating Fan Labels at Each New Bar in Pine (A Programming-Related Subject)
To do this, I used linear equations and line slopes. Of course it was so complicated and exhausting, but finally I overcame that thanks to my genius cousin.

Settings and Usage

By default, the script shows detected extremum points plus 1 Fibonacci fan, 1 Gann fan, 1 set of Fibonacci retracements and no Gann retracements on the chart. All of these could be changed in the indicator settings beside the color and transparency of each line.

Feel free to use this and send me your thoughts!

---

## Source Code

````pine
// © informanerd
//@version=4

study("Auto Fibonacci and Gann Fan/Retracements Combo", "Auto Fibo & Gann Fan/Rets.", true, max_lines_count = 500, max_labels_count = 500)

// inputs & definitions {

showExtrema = input(true, "Mark Extremum Points on the Chart                                                          ")

fiboGroup = "===============[ Fibonacci ]==============="
ffCount = input(1, "Show", minval = 0, inline = "FiboFan", group = fiboGroup)
ffStyle = input("Solid", "Fans", options = ["Dashed", "Dotted", "Solid"], inline = "FiboFan", group = fiboGroup)
showFFLabels = input(true, "Show Labels", inline = "FiboFan", group = fiboGroup)
frCount = input(1, "Show", minval = 0, inline = "FiboRet", group = fiboGroup)
frStyle = input("Dashed", "Retracements", options = ["Dashed", "Dotted", "Solid"], inline = "FiboRet", group = fiboGroup)
showFRLabels = input(true, "Show Labels", inline = "FiboRet", group = fiboGroup)
extendFR = input(true, "Extend the Most Recent Retracement Lines", group = fiboGroup)

gannGroup = "===============[ Gann ]==============="
gfCount = input(1, "Show", minval = 0, inline = "GannFan", group = gannGroup)
gfStyle = input("Solid", "Fans", options = ["Dashed", "Dotted", "Solid"], inline = "GannFan", group = gannGroup)
showGFLabels = input(true, "Show Labels", inline = "GannFan", group = gannGroup)
grCount = input(0, "Show", minval = 0, inline = "GannRet", group = gannGroup)
grStyle = input("Dotted", "Retracements", options = ["Dashed", "Dotted", "Solid"], inline = "GannRet", group = gannGroup)
showGRLabels = input(true, "Show Labels", inline = "GannRet", group = gannGroup)
extendGR = input(true, "Extend the Most Recent Retracement Lines", group = gannGroup)

colorsGroup = "===============[ Line Colors ]==============="
var fiboFanBearColors = array.from(
     input(color.new(color.red, 60), "FiboFan ↘   23.6:", inline = "FiboFan1", group = colorsGroup),
     input(color.new(color.red, 40), "38.2:", inline = "FiboFan1", group = colorsGroup),
     input(color.new(color.red, 0), "50.0:", inline = "FiboFan1", group = colorsGroup),
     input(color.new(color.red, 40), "61.8:", inline = "FiboFan1", group = colorsGroup),
     input(color.new(color.red, 60), "78.6:", inline = "FiboFan1", group = colorsGroup))
var fiboFanBullColors = array.from(
     input(color.new(color.green, 60), "FiboFan ↗   23.6:", inline = "FiboFan2", group = colorsGroup),
     input(color.new(color.green, 40), "38.2:", inline = "FiboFan2", group = colorsGroup),
     input(color.new(color.green, 0), "50.0:", inline = "FiboFan2", group = colorsGroup),
     input(color.new(color.green, 40), "61.8:", inline = "FiboFan2", group = colorsGroup),
     input(color.new(color.green, 60), "78.6:", inline = "FiboFan2", group = colorsGroup))
var fiboRetBearColors = array.from(
     input(color.new(color.red, 60), "FiboRet ↘   23.6:", inline = "FiboRet1", group = colorsGroup),
     input(color.new(color.red, 40), "38.2:", inline = "FiboRet1", group = colorsGroup),
     input(color.new(color.red, 0), "50.0:", inline = "FiboRet1", group = colorsGroup),
     input(color.new(color.red, 40), "61.8:", inline = "FiboRet1", group = colorsGroup),
     input(color.new(color.red, 60), "78.6:", inline = "FiboRet1", group = colorsGroup))
var fiboRetBullColors = array.from(
     input(color.new(color.green, 60), "FiboRet ↗   23.6:", inline = "FiboRet2", group = colorsGroup),
     input(color.new(color.green, 40), "38.2:", inline = "FiboRet2", group = colorsGroup),
     input(color.new(color.green, 0), "50.0:", inline = "FiboRet2", group = colorsGroup),
     input(color.new(color.green, 40), "61.8:", inline = "FiboRet2", group = colorsGroup),
     input(color.new(color.green, 60), "78.6:", inline = "FiboRet2", group = colorsGroup))
var gannFanBearColors = array.from(
     input(color.new(color.maroon, 60), "GannFan ↘     4/1:", inline = "GannFan1", group = colorsGroup),
     input(color.new(color.maroon, 40), "2/1:", inline = "GannFan1", group = colorsGroup),
     input(color.new(color.maroon, 0), "1/1:", inline = "GannFan1", group = colorsGroup),
     input(color.new(color.maroon, 40), "1/2:", inline = "GannFan1", group = colorsGroup),
     input(color.new(color.maroon, 60), "1/4:", inline = "GannFan1", group = colorsGroup))
var gannFanBullColors = array.from(
     input(color.new(color.teal, 60), "GannFan ↗     4/1:", inline = "GannFan2", group = colorsGroup),
     input(color.new(color.teal, 40), "2/1:", inline = "GannFan2", group = colorsGroup),
     input(color.new(color.teal, 0), "1/1:", inline = "GannFan2", group = colorsGroup),
     input(color.new(color.teal, 40), "1/2:", inline = "GannFan2", group = colorsGroup),
     input(color.new(color.teal, 60), "1/4:", inline = "GannFan2", group = colorsGroup))
var gannRetBearColors = array.from(
     input(color.new(color.maroon, 60), "GannRet ↘   12.5:", inline = "GannRet1", group = colorsGroup),
     input(color.new(color.maroon, 40), "25.0:", inline = "GannRet1", group = colorsGroup),
     input(color.new(color.maroon, 0), "50.0:", inline = "GannRet1", group = colorsGroup),
     input(color.new(color.maroon, 40), "75.0:", inline = "GannRet1", group = colorsGroup),
     input(color.new(color.maroon, 60), "87.5:", inline = "GannRet1", group = colorsGroup))
var gannRetBullColors = array.from(
     input(color.new(color.teal, 60), "GannRet ↗   12.5:", inline = "GannRet2", group = colorsGroup),
     input(color.new(color.teal, 40), "25.0:", inline = "GannRet2", group = colorsGroup),
     input(color.new(color.teal, 0), "50.0:", inline = "GannRet2", group = colorsGroup),
     input(color.new(color.teal, 40), "75.0:", inline = "GannRet2", group = colorsGroup),
     input(color.new(color.teal, 60), "87.5:", inline = "GannRet2", group = colorsGroup))

fiboRetLineStyle = frStyle == "Dashed" ? line.style_dashed : frStyle == "Dotted" ? line.style_dotted : line.style_solid
fiboFanLineStyle = ffStyle == "Dashed" ? line.style_dashed : ffStyle == "Dotted" ? line.style_dotted : line.style_solid
gannRetLineStyle = grStyle == "Dashed" ? line.style_dashed : grStyle == "Dotted" ? line.style_dotted : line.style_solid
gannFanLineStyle = gfStyle == "Dashed" ? line.style_dashed : gfStyle == "Dotted" ? line.style_dotted : line.style_solid

var float highPrice = na
var float highestPrice = na
var float lowPrice = na
var float lowestPrice = na
var highBar = 0
var highestBar = 0
var lowBar = 0
var lowestBar = 0
var waitingFor = ""

var chartScale = 1.
var scales = array.new_float()

fiboRatios = array.from(.236, .382, .5, .618, .786)
fiboRatioLabels = array.from("23.6", "38.2", "50", "61.8", "78.6")
gannFanRatios = array.from(15. / 90, 26.25 / 90, 45. / 90, 63.75 / 90, 75. / 90)
gannFanRatioLabels = array.from("4:1", "2:1", "1:1", "1:2", "1:4")
gannRetRatios = array.from(.125, .25, .5, .75, .875)
gannRetRatioLabels = array.from("12.5", "25", "50", "75", "87.5")

var fiboRet1 = array.new_line()
var fiboRet2 = array.new_line()
var fiboRet3 = array.new_line()
var fiboRet4 = array.new_line()
var fiboRet5 = array.new_line()
var fiboRet6 = array.new_line()
var fiboRet7 = array.new_line()
var gannRet1 = array.new_line()
var gannRet2 = array.new_line()
var gannRet3 = array.new_line()
var gannRet4 = array.new_line()
var gannRet5 = array.new_line()
var gannRet6 = array.new_line()
var gannRet7 = array.new_line()
var fiboFan1 = array.new_line()
var fiboFan2 = array.new_line()
var fiboFan3 = array.new_line()
var fiboFan4 = array.new_line()
var fiboFan5 = array.new_line()
var fiboFan6 = array.new_line()
var fiboFan7 = array.new_line()
var gannFan1 = array.new_line()
var gannFan2 = array.new_line()
var gannFan3 = array.new_line()
var gannFan4 = array.new_line()
var gannFan5 = array.new_line()
var gannFan6 = array.new_line()
var gannFan7 = array.new_line()

var fiboRetLabel1 = array.new_label()
var fiboRetLabel2 = array.new_label()
var fiboRetLabel3 = array.new_label()
var fiboRetLabel4 = array.new_label()
var fiboRetLabel5 = array.new_label()
var fiboFanLabel1 = array.new_label()
var fiboFanLabel2 = array.new_label()
var fiboFanLabel3 = array.new_label()
var fiboFanLabel4 = array.new_label()
var fiboFanLabel5 = array.new_label()
var gannRetLabel1 = array.new_label()
var gannRetLabel2 = array.new_label()
var gannRetLabel3 = array.new_label()
var gannRetLabel4 = array.new_label()
var gannRetLabel5 = array.new_label()
var gannFanLabel1 = array.new_label()
var gannFanLabel2 = array.new_label()
var gannFanLabel3 = array.new_label()
var gannFanLabel4 = array.new_label()
var gannFanLabel5 = array.new_label()

var fiboRetLabels = array.new_label(5, na)
var fiboFanLabels = array.new_label(5, na)
var gannRetLabels = array.new_label(5, na)
var gannFanLabels = array.new_label(5, na)

var fiboFanSlopes = array.new_float(5, na)
var gannFanSlopes = array.new_float(5, na)

//}
// find proper chart scale, highest and lowest pivots and draw line sets {

// functions
calcScale(bar1, price1, bar2, price2) =>
    if array.size(scales) == 100000
        array.shift(scales)
    array.push(scales, abs(price2 - price1) / (bar2 - bar1))
    array.median(scales)

isHigh() =>
    isHigh = false
    bar = bar_index
    price = high
    if close < open
        for i = 1 to 10
            if close[i] < open[i]
                break
            else
                bar := price < high[i] ? bar_index - i : bar
                price := max(price, high[i])
                if close[i] == open[i]
                    continue
                if close[i] > open[i]
                    isHigh := true
                    break
    [isHigh, bar, price]
isLow() =>
    isLow = false
    bar = bar_index
    price = low
    if close > open
        for i = 1 to 10
            if close[i] > open[i]
                break
            else
                bar := price > low[i] ? bar_index - i : bar
                price := min(price, low[i])
                if close[i] == open[i]
                    continue
                if close[i] < open[i]
                    isLow := true
                    break
    [isLow, bar, price]

showLabel(setType, labelArray, arrayIndex, x, y, text, colour) =>
    if (showFRLabels and setType == "fret") or (showGRLabels and setType == "gret") or (showFFLabels and setType == "ffan") or (showGFLabels and setType == "gfan")
        label.delete(array.get(labelArray, arrayIndex))
        array.set(labelArray, arrayIndex, label.new(x, y, text, color = na, textcolor = colour))

saveLastLabels(setType, labelArray) =>
    if setType == "fret"
        array.push(fiboRetLabel1, array.get(labelArray, 0))
        array.push(fiboRetLabel2, array.get(labelArray, 1))
        array.push(fiboRetLabel3, array.get(labelArray, 2))
        array.push(fiboRetLabel4, array.get(labelArray, 3))
        array.push(fiboRetLabel5, array.get(labelArray, 4))
    else if setType == "gret"
        array.push(gannRetLabel1, array.get(labelArray, 0))
        array.push(gannRetLabel2, array.get(labelArray, 1))
        array.push(gannRetLabel3, array.get(labelArray, 2))
        array.push(gannRetLabel4, array.get(labelArray, 3))
        array.push(gannRetLabel5, array.get(labelArray, 4))
    else if setType == "ffan"
        array.push(fiboFanLabel1, array.get(labelArray, 0))
        array.push(fiboFanLabel2, array.get(labelArray, 1))
        array.push(fiboFanLabel3, array.get(labelArray, 2))
        array.push(fiboFanLabel4, array.get(labelArray, 3))
        array.push(fiboFanLabel5, array.get(labelArray, 4))
    else if setType == "gfan"
        array.push(gannFanLabel1, array.get(labelArray, 0))
        array.push(gannFanLabel2, array.get(labelArray, 1))
        array.push(gannFanLabel3, array.get(labelArray, 2))
        array.push(gannFanLabel4, array.get(labelArray, 3))
        array.push(gannFanLabel5, array.get(labelArray, 4))
    for i = 0 to 4
        array.set(labelArray, i, na)

drawLineSet(setType, ratioArray, ratioLabelArray, labelArray, lineArray1, lineArray2, lineArray3, lineArray4, lineArray5, lineArray6, lineArray7, bar1, price1, bar2, price2, extend, bullColors, bearColors, style) =>
    colors = array.copy(price1 < price2 ? bullColors : bearColors)
    barRange = price1 < price2 ? bar1 - bar2 : bar2 - bar1
    priceRange = price1 - price2
    levelPrice = 0.
    array.push(lineArray1, line.new(bar1, price1, bar2, price1, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 2), style = style))
    levelPrice := price1 - (setType != "gfan" ? priceRange * (1 - array.get(ratioArray, 0)) : barRange * tan(array.get(ratioArray, 0) * math.pi / 2) * chartScale)
    array.push(lineArray2, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : levelPrice, bar2, levelPrice, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 0), style = style))
    showLabel(setType, labelArray, 0, bar2, levelPrice, array.get(ratioLabelArray, 0), array.get(colors, 0))
    if setType == "ffan"
        array.set(fiboFanSlopes, 0, (levelPrice - price1) / (bar2 - bar1))
    if setType == "gfan"
        array.set(gannFanSlopes, 0, (levelPrice - price1) / (bar2 - bar1))
    levelPrice := price1 - (setType != "gfan" ? priceRange * (1 - array.get(ratioArray, 1)) : barRange * tan(array.get(ratioArray, 1) * math.pi / 2) * chartScale)
    array.push(lineArray3, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : levelPrice, bar2, levelPrice, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 1), style = style))
    showLabel(setType, labelArray, 1, bar2, levelPrice, array.get(ratioLabelArray, 1), array.get(colors, 1))
    if setType == "ffan"
        array.set(fiboFanSlopes, 1, (levelPrice - price1) / (bar2 - bar1))
    if setType == "gfan"
        array.set(gannFanSlopes, 1, (levelPrice - price1) / (bar2 - bar1))
    levelPrice := price1 - (setType != "gfan" ? priceRange * (1 - array.get(ratioArray, 2)) : barRange * tan(array.get(ratioArray, 2) * math.pi / 2) * chartScale)
    array.push(lineArray4, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : levelPrice, bar2, levelPrice, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 2), style = style))
    showLabel(setType, labelArray, 2, bar2, levelPrice, array.get(ratioLabelArray, 2), array.get(colors, 2))
    if setType == "ffan"
        array.set(fiboFanSlopes, 2, (levelPrice - price1) / (bar2 - bar1))
    if setType == "gfan"
        array.set(gannFanSlopes, 2, (levelPrice - price1) / (bar2 - bar1))
    levelPrice := price1 - (setType != "gfan" ? priceRange * (1 - array.get(ratioArray, 3)) : barRange * tan(array.get(ratioArray, 3) * math.pi / 2) * chartScale)
    array.push(lineArray5, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : levelPrice, bar2, levelPrice, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 3), style = style))
    showLabel(setType, labelArray, 3, bar2, levelPrice, array.get(ratioLabelArray, 3), array.get(colors, 3))
    if setType == "ffan"
        array.set(fiboFanSlopes, 3, (levelPrice - price1) / (bar2 - bar1))
    if setType == "gfan"
        array.set(gannFanSlopes, 3, (levelPrice - price1) / (bar2 - bar1))
    levelPrice := price1 - (setType != "gfan" ? priceRange * (1 - array.get(ratioArray, 4)) : barRange * tan(array.get(ratioArray, 4) * math.pi / 2) * chartScale)
    array.push(lineArray6, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : levelPrice, bar2, levelPrice, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 4), style = style))
    showLabel(setType, labelArray, 4, bar2, levelPrice, array.get(ratioLabelArray, 4), array.get(colors, 4))
    if setType == "ffan"
        array.set(fiboFanSlopes, 4, (levelPrice - price1) / (bar2 - bar1))
    if setType == "gfan"
        array.set(gannFanSlopes, 4, (levelPrice - price1) / (bar2 - bar1))
    array.push(lineArray7, line.new(bar1, setType == "ffan" or setType == "gfan" ? price1 : price2, setType == "gfan" ? bar1 : bar2, price2, extend = extend or setType == "ffan" or setType == "gfan" ? extend.right : extend.none, color = array.get(colors, 2), style = style))

cutLastRets() =>
    index = array.size(fiboRet1) - 1
    if index > -1
        line.set_extend(array.get(fiboRet1, index), extend.none)
        line.set_extend(array.get(fiboRet2, index), extend.none)
        line.set_extend(array.get(fiboRet3, index), extend.none)
        line.set_extend(array.get(fiboRet4, index), extend.none)
        line.set_extend(array.get(fiboRet5, index), extend.none)
        line.set_extend(array.get(fiboRet6, index), extend.none)
        line.set_extend(array.get(fiboRet7, index), extend.none)
    index := array.size(gannRet1) - 1
    if index > -1
        line.set_extend(array.get(gannRet1, index), extend.none)
        line.set_extend(array.get(gannRet2, index), extend.none)
        line.set_extend(array.get(gannRet3, index), extend.none)
        line.set_extend(array.get(gannRet4, index), extend.none)
        line.set_extend(array.get(gannRet5, index), extend.none)
        line.set_extend(array.get(gannRet6, index), extend.none)
        line.set_extend(array.get(gannRet7, index), extend.none)

delUnneededLines() =>
    if array.size(fiboRet1) > frCount
        line.delete(array.shift(fiboRet1))
        line.delete(array.shift(fiboRet2))
        line.delete(array.shift(fiboRet3))
        line.delete(array.shift(fiboRet4))
        line.delete(array.shift(fiboRet5))
        line.delete(array.shift(fiboRet6))
        line.delete(array.shift(fiboRet7))
    if array.size(fiboRetLabel1) > frCount - 1 and frCount > 0
        label.delete(array.shift(fiboRetLabel1))
        label.delete(array.shift(fiboRetLabel2))
        label.delete(array.shift(fiboRetLabel3))
        label.delete(array.shift(fiboRetLabel4))
        label.delete(array.shift(fiboRetLabel5))
    if array.size(gannRet1) > grCount
        line.delete(array.shift(gannRet1))
        line.delete(array.shift(gannRet2))
        line.delete(array.shift(gannRet3))
        line.delete(array.shift(gannRet4))
        line.delete(array.shift(gannRet5))
        line.delete(array.shift(gannRet6))
        line.delete(array.shift(gannRet7))
    if array.size(gannRetLabel1) > grCount - 1 and grCount > 0
        label.delete(array.shift(gannRetLabel1))
        label.delete(array.shift(gannRetLabel2))
        label.delete(array.shift(gannRetLabel3))
        label.delete(array.shift(gannRetLabel4))
        label.delete(array.shift(gannRetLabel5))
    if array.size(fiboFan1) > ffCount
        line.delete(array.shift(fiboFan1))
        line.delete(array.shift(fiboFan2))
        line.delete(array.shift(fiboFan3))
        line.delete(array.shift(fiboFan4))
        line.delete(array.shift(fiboFan5))
        line.delete(array.shift(fiboFan6))
        line.delete(array.shift(fiboFan7))
    if array.size(fiboFanLabel1) > ffCount - 1 and ffCount > 0
        label.delete(array.shift(fiboFanLabel1))
        label.delete(array.shift(fiboFanLabel2))
        label.delete(array.shift(fiboFanLabel3))
        label.delete(array.shift(fiboFanLabel4))
        label.delete(array.shift(fiboFanLabel5))
    if array.size(gannFan1) > gfCount
        line.delete(array.shift(gannFan1))
        line.delete(array.shift(gannFan2))
        line.delete(array.shift(gannFan3))
        line.delete(array.shift(gannFan4))
        line.delete(array.shift(gannFan5))
        line.delete(array.shift(gannFan6))
        line.delete(array.shift(gannFan7))
    if array.size(gannFanLabel1) > gfCount - 1 and gfCount > 0
        label.delete(array.shift(gannFanLabel1))
        label.delete(array.shift(gannFanLabel2))
        label.delete(array.shift(gannFanLabel3))
        label.delete(array.shift(gannFanLabel4))
        label.delete(array.shift(gannFanLabel5))

// find highests and lowests and draw retracements and fans
[isH, hBar, hPrice] = isHigh()
if isH
    chartScale := calcScale(highBar, highPrice, hBar, hPrice)
    if waitingFor != "l" and hPrice < highPrice
        highestBar := highBar
        highestPrice := highPrice
        cutLastRets()
        if frCount > 0
            saveLastLabels("fret", fiboRetLabels)
            drawLineSet("fret", fiboRatios, fiboRatioLabels, fiboRetLabels, fiboRet1, fiboRet2, fiboRet3, fiboRet4, fiboRet5, fiboRet6, fiboRet7, lowestBar, lowestPrice, highestBar, highestPrice, extendFR, fiboRetBullColors, fiboRetBearColors, fiboRetLineStyle)
        if ffCount > 0
            saveLastLabels("ffan", fiboFanLabels)
            drawLineSet("ffan", fiboRatios, fiboRatioLabels, fiboFanLabels, fiboFan1, fiboFan2, fiboFan3, fiboFan4, fiboFan5, fiboFan6, fiboFan7, lowestBar, lowestPrice, highestBar, highestPrice, extendFR, fiboFanBullColors, fiboFanBearColors, fiboFanLineStyle)
        if grCount > 0
            saveLastLabels("gret", gannRetLabels)
            drawLineSet("gret", gannRetRatios, gannRetRatioLabels, gannRetLabels, gannRet1, gannRet2, gannRet3, gannRet4, gannRet5, gannRet6, gannRet7, lowestBar, lowestPrice, highestBar, highestPrice, extendGR, gannRetBullColors, gannRetBearColors, gannRetLineStyle)
        if gfCount > 0
            saveLastLabels("gfan", gannFanLabels)
            drawLineSet("gfan", gannFanRatios, gannFanRatioLabels, gannFanLabels, gannFan1, gannFan2, gannFan3, gannFan4, gannFan5, gannFan6, gannFan7, highestBar, highestPrice, bar_index, low, extendGR, gannFanBullColors, gannFanBearColors, gannFanLineStyle)
        delUnneededLines()
        waitingFor := "l"
        if showExtrema
            label.new(highestBar, highestPrice, "")
    highBar := hBar
    highPrice := hPrice
[isL, lBar, lPrice] = isLow()
if isL
    chartScale := calcScale(lowBar, lowPrice, lBar, lPrice)
    if waitingFor != "h" and lPrice > lowPrice
        lowestBar := lowBar
        lowestPrice := lowPrice
        cutLastRets()
        if frCount > 0
            saveLastLabels("fret", fiboRetLabels)
            drawLineSet("fret", fiboRatios, fiboRatioLabels, fiboRetLabels, fiboRet1, fiboRet2, fiboRet3, fiboRet4, fiboRet5, fiboRet6, fiboRet7, highestBar, highestPrice, lowestBar, lowestPrice, extendFR, fiboRetBullColors, fiboRetBearColors, fiboRetLineStyle)
        if ffCount > 0
            saveLastLabels("ffan", fiboFanLabels)
            drawLineSet("ffan", fiboRatios, fiboRatioLabels, fiboFanLabels, fiboFan1, fiboFan2, fiboFan3, fiboFan4, fiboFan5, fiboFan6, fiboFan7, highestBar, highestPrice, lowestBar, lowestPrice, extendFR, fiboFanBullColors, fiboFanBearColors, fiboFanLineStyle)
        if grCount > 0
            saveLastLabels("gret", gannRetLabels)
            drawLineSet("gret", gannRetRatios, gannRetRatioLabels, gannRetLabels, gannRet1, gannRet2, gannRet3, gannRet4, gannRet5, gannRet6, gannRet7, highestBar, highestPrice, lowestBar, lowestPrice, extendGR, gannRetBullColors, gannRetBearColors, gannRetLineStyle)
        if gfCount > 0
            saveLastLabels("gfan", gannFanLabels)
            drawLineSet("gfan", gannFanRatios, gannFanRatioLabels, gannFanLabels, gannFan1, gannFan2, gannFan3, gannFan4, gannFan5, gannFan6, gannFan7, lowestBar, lowestPrice, bar_index, high, extendGR, gannFanBullColors, gannFanBearColors, gannFanLineStyle)
        delUnneededLines()
        waitingFor := "h"
        if showExtrema
            label.new(lowestBar, lowestPrice, "", style = label.style_label_up)
    lowBar := lBar
    lowPrice := lPrice

// extend latest retracements
index = array.size(fiboRet1) - 1
if index > -1
    line.set_x2(array.get(fiboRet1, index), bar_index)
    line.set_x2(array.get(fiboRet2, index), bar_index)
    line.set_x2(array.get(fiboRet3, index), bar_index)
    line.set_x2(array.get(fiboRet4, index), bar_index)
    line.set_x2(array.get(fiboRet5, index), bar_index)
    line.set_x2(array.get(fiboRet6, index), bar_index)
    line.set_x2(array.get(fiboRet7, index), bar_index)
index := array.size(gannRet1) - 1
if index > -1
    line.set_x2(array.get(gannRet1, index), bar_index)
    line.set_x2(array.get(gannRet2, index), bar_index)
    line.set_x2(array.get(gannRet3, index), bar_index)
    line.set_x2(array.get(gannRet4, index), bar_index)
    line.set_x2(array.get(gannRet5, index), bar_index)
    line.set_x2(array.get(gannRet6, index), bar_index)
    line.set_x2(array.get(gannRet7, index), bar_index)

// relocate labels
for i = 0 to 4
    if showFRLabels
        label.set_x(array.get(fiboRetLabels, i), bar_index + 2)
    if showGRLabels
        label.set_x(array.get(gannRetLabels, i), bar_index + 2)
    if showFFLabels
        fiboFanLabel = array.get(fiboFanLabels, i)
        label.set_x(fiboFanLabel, bar_index + 2 * (1 + i))
        label.set_y(fiboFanLabel, (waitingFor == "l" ? lowestPrice : highestPrice) + array.get(fiboFanSlopes, i) * (bar_index + 2 * (1 + i) - (waitingFor == "l" ? lowestBar : highestBar)))
    if showGFLabels
        gannFanLabel = array.get(gannFanLabels, i)
        label.set_x(gannFanLabel, bar_index + 2 * (5 - i))
        label.set_y(gannFanLabel, (waitingFor == "h" ? lowestPrice : highestPrice) + array.get(gannFanSlopes, i) * (bar_index + 2 * (5 - i) - (waitingFor == "h" ? lowestBar : highestBar)))
        //label.set_y(gannFanLabel, label.get_y(gannFanLabel) + tan(array.get(gannFanRatios, i) * math.pi / 2) * chartScale * (waitingFor == "h" ? 1 : waitingFor == "l" ? -1 : 0))

//}
````

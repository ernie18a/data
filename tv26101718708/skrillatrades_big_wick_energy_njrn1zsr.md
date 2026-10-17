# SkrillaTrades Big Wick Energy

- url: https://www.tradingview.com/script/njRn1zsR-SkrillaTrades-Big-Wick-Energy/
- type: indicator
- pine_id: PUB;dcc13e478fe44ce6a29bcc6b393d56ea
- version: 1.0

## Description

SKRILLATRADES BIG WICK ENERGY

OVERVIEW

Big Wick Energy is a wick-based liquidity indicator designed to identify candles that produced unusually large rejection wicks. When a large wick forms, it often represents a liquidity grab, stop run, aggressive rejection, or unfinished auction.

The indicator automatically detects wick lengths that fall within user-defined ranges and plots a box around the wick area. These boxes create visual zones that traders can monitor for future price interaction.

Many times after a strong rejection, price will eventually retrace back into the wick. These retracements frequently act as:

• Support or resistance zones
• Liquidity rebalancing areas
• Mitigation zones
• Reaction zones for continuation trades
• Potential reversal locations

The larger the wick, the more significant the rejection was at that price level. Large wicks often indicate that substantial order flow occurred in that area, which is why price commonly revisits them later.

FEATURES

• Detects upper wicks, lower wicks, or both
• Optional bullish-only or bearish-only candle filtering
• Draws boxes around qualifying wick zones
• Optional centerline through each box
• Custom colors for each wick size range
• Adjustable transparency and border styles
• Extend boxes a fixed number of bars
• Extend boxes until price crosses through the zone
• Automatic cleanup to prevent TradingView object limit issues

HOW TO USE

Bullish Example:

1. A candle forms with a very large lower wick.
2. The indicator draws a box around that wick.
3. Price rallies away.
4. Later price retraces into the wick zone.
5. Traders can watch for bullish reactions inside the box.

Bearish Example:

1. A candle forms with a very large upper wick.
2. The indicator draws a box around that wick.
3. Price sells off.
4. Later price retraces back into the wick zone.
5. Traders can watch for bearish reactions inside the box.

CENTERLINE

Each box can display a centerline.

The centerline marks the 50% level of the wick and can be used as:

• Midpoint support/resistance
• Mitigation level
• Equilibrium level
• First reaction area inside the wick zone

DEFAULT SETTINGS

GENERAL

Wick Side:
• Both

Candle Filter:
• All Candles

Max Boxes To Keep:
• 250

Extend Left Bars:
• 0

Extend Right Bars:
• 200

Extend Until Price Crosses:
• Off

CENTERLINE

Show Centerline:
• On

Centerline Style:
• Dotted

Centerline Width:
• 1

RANGE SETTINGS

Range 1
• OFF
• 10–50 Points
• Blue

Range 2
• ON
• 50–100 Points
• Orange

Range 3
• ON
• 101–300 Points
• Red

Range 4
• OFF
• 301–400 Points
• Purple

Range 5
• OFF
• 401–500 Points
• Green

Range 6
• OFF
• 501–999 Points
• Yellow

DEFAULT PURPOSE

The default configuration focuses on identifying medium-to-large rejection wicks while filtering out smaller market noise. This allows traders to concentrate on the most meaningful liquidity events and monitor those zones for future retracements and reactions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Skrilla_ICT

//@version=6
indicator("SkrillaTrades Big Wick Energy", overlay=true, max_boxes_count=500, max_lines_count=500)

//----------------------------------------------------
// GENERAL SETTINGS
//----------------------------------------------------
gGeneral = "GENERAL SETTINGS"

wickSide = input.string("Both", "Wick Side", options=["Both", "Upper Only", "Lower Only"], group=gGeneral)
candleFilter = input.string("All Candles", "Candle Filter", options=["All Candles", "Bullish Candles Only", "Bearish Candles Only"], group=gGeneral)

maxBoxes = input.int(250, "Max Boxes To Keep", minval=10, maxval=500, group=gGeneral)
extendLeftBars = input.int(0, "Extend Boxes Left Bars", minval=0, group=gGeneral)
extendRightBars = input.int(200, "Extend Boxes Right Bars", minval=0, group=gGeneral)
extendUntilCross = input.bool(false, "Extend Until Price Crosses", group=gGeneral)

//----------------------------------------------------
// CENTERLINE SETTINGS
//----------------------------------------------------
gCenter = "CENTERLINE SETTINGS"

showCenterline = input.bool(true, "Show Centerline", group=gCenter)
centerlineColor = input.color(color.rgb(115, 34, 192), "Centerline Color", group=gCenter)
centerlineTrans = input.int(50, "Centerline Transparency", minval=0, maxval=100, group=gCenter)
centerlineStyle = input.string("Dashed", "Centerline Style", options=["Solid", "Dashed", "Dotted"], group=gCenter)
centerlineWidth = input.int(1, "Centerline Width", minval=1, maxval=5, group=gCenter)

//----------------------------------------------------
// RANGE 1
//----------------------------------------------------
g1 = "RANGE 1"
r1On = input.bool(false, "Enable Range 1", group=g1)
r1Min = input.float(10.0, "Min Points", group=g1)
r1Max = input.float(50.0, "Max Points", group=g1)
r1Color = input.color(color.blue, "Box Color", group=g1)
r1Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g1)
r1BorderOn = input.bool(true, "Show Border", group=g1)
r1Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g1)
r1Width = input.int(1, "Border Width", minval=1, maxval=5, group=g1)

//----------------------------------------------------
// RANGE 2
//----------------------------------------------------
g2 = "RANGE 2"
r2On = input.bool(true, "Enable Range 2", group=g2)
r2Min = input.float(50.0, "Min Points", group=g2)
r2Max = input.float(100.0, "Max Points", group=g2)
r2Color = input.color(color.orange, "Box Color", group=g2)
r2Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g2)
r2BorderOn = input.bool(true, "Show Border", group=g2)
r2Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g2)
r2Width = input.int(1, "Border Width", minval=1, maxval=5, group=g2)

//----------------------------------------------------
// RANGE 3
//----------------------------------------------------
g3 = "RANGE 3"
r3On = input.bool(true, "Enable Range 3", group=g3)
r3Min = input.float(101.0, "Min Points", group=g3)
r3Max = input.float(300.0, "Max Points", group=g3)
r3Color = input.color(color.red, "Box Color", group=g3)
r3Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g3)
r3BorderOn = input.bool(true, "Show Border", group=g3)
r3Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g3)
r3Width = input.int(1, "Border Width", minval=1, maxval=5, group=g3)

//----------------------------------------------------
// RANGE 4
//----------------------------------------------------
g4 = "RANGE 4"
r4On = input.bool(false, "Enable Range 4", group=g4)
r4Min = input.float(301.0, "Min Points", group=g4)
r4Max = input.float(400.0, "Max Points", group=g4)
r4Color = input.color(color.purple, "Box Color", group=g4)
r4Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g4)
r4BorderOn = input.bool(true, "Show Border", group=g4)
r4Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g4)
r4Width = input.int(1, "Border Width", minval=1, maxval=5, group=g4)

//----------------------------------------------------
// RANGE 5
//----------------------------------------------------
g5 = "RANGE 5"
r5On = input.bool(false, "Enable Range 5", group=g5)
r5Min = input.float(401.0, "Min Points", group=g5)
r5Max = input.float(500.0, "Max Points", group=g5)
r5Color = input.color(color.green, "Box Color", group=g5)
r5Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g5)
r5BorderOn = input.bool(true, "Show Border", group=g5)
r5Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g5)
r5Width = input.int(1, "Border Width", minval=1, maxval=5, group=g5)

//----------------------------------------------------
// RANGE 6
//----------------------------------------------------
g6 = "RANGE 6"
r6On = input.bool(false, "Enable Range 6", group=g6)
r6Min = input.float(501.0, "Min Points", group=g6)
r6Max = input.float(999.0, "Max Points", group=g6)
r6Color = input.color(color.yellow, "Box Color", group=g6)
r6Trans = input.int(85, "Fill Transparency", minval=0, maxval=100, group=g6)
r6BorderOn = input.bool(true, "Show Border", group=g6)
r6Border = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=g6)
r6Width = input.int(1, "Border Width", minval=1, maxval=5, group=g6)

//----------------------------------------------------
// FUNCTIONS
//----------------------------------------------------
f_style(styleText) =>
    styleText == "Dashed" ? line.style_dashed :
     styleText == "Dotted" ? line.style_dotted :
     line.style_solid

f_inRange(length, minVal, maxVal) =>
    length >= minVal and length <= maxVal

var box[] wickBoxes = array.new_box()
var line[] centerLines = array.new_line()
var float[] boxTops = array.new_float()
var float[] boxBottoms = array.new_float()
var int[] boxDirs = array.new_int()

f_deleteAt(idx) =>
    bx = array.get(wickBoxes, idx)
    cl = array.get(centerLines, idx)

    box.delete(bx)

    if not na(cl)
        line.delete(cl)

    array.remove(wickBoxes, idx)
    array.remove(centerLines, idx)
    array.remove(boxTops, idx)
    array.remove(boxBottoms, idx)
    array.remove(boxDirs, idx)

f_drawBox(topPrice, bottomPrice, boxColor, transparency, borderOn, borderStyle, borderWidth, dir) =>
    leftSide = bar_index - extendLeftBars
    rightSide = extendUntilCross ? bar_index : bar_index + extendRightBars
    midPrice = (topPrice + bottomPrice) / 2.0

    b = box.new(
         left=leftSide,
         right=rightSide,
         top=topPrice,
         bottom=bottomPrice,
         xloc=xloc.bar_index,
         bgcolor=color.new(boxColor, transparency),
         border_color=borderOn ? boxColor : color.new(boxColor, 100),
         border_style=f_style(borderStyle),
         border_width=borderOn ? borderWidth : 1
     )

    line cl = na

    if showCenterline
        cl := line.new(
             x1=leftSide,
             y1=midPrice,
             x2=rightSide,
             y2=midPrice,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=color.new(centerlineColor, centerlineTrans),
             style=f_style(centerlineStyle),
             width=centerlineWidth
         )

    array.push(wickBoxes, b)
    array.push(centerLines, cl)
    array.push(boxTops, topPrice)
    array.push(boxBottoms, bottomPrice)
    array.push(boxDirs, dir)

    if array.size(wickBoxes) > maxBoxes
        f_deleteAt(0)

f_checkAndDraw(wickLength, topPrice, bottomPrice, dir) =>
    if r1On and f_inRange(wickLength, r1Min, r1Max)
        f_drawBox(topPrice, bottomPrice, r1Color, r1Trans, r1BorderOn, r1Border, r1Width, dir)
    else if r2On and f_inRange(wickLength, r2Min, r2Max)
        f_drawBox(topPrice, bottomPrice, r2Color, r2Trans, r2BorderOn, r2Border, r2Width, dir)
    else if r3On and f_inRange(wickLength, r3Min, r3Max)
        f_drawBox(topPrice, bottomPrice, r3Color, r3Trans, r3BorderOn, r3Border, r3Width, dir)
    else if r4On and f_inRange(wickLength, r4Min, r4Max)
        f_drawBox(topPrice, bottomPrice, r4Color, r4Trans, r4BorderOn, r4Border, r4Width, dir)
    else if r5On and f_inRange(wickLength, r5Min, r5Max)
        f_drawBox(topPrice, bottomPrice, r5Color, r5Trans, r5BorderOn, r5Border, r5Width, dir)
    else if r6On and f_inRange(wickLength, r6Min, r6Max)
        f_drawBox(topPrice, bottomPrice, r6Color, r6Trans, r6BorderOn, r6Border, r6Width, dir)

//----------------------------------------------------
// EXTEND / DELETE EXISTING BOXES
//----------------------------------------------------
if extendUntilCross and array.size(wickBoxes) > 0
    i = array.size(wickBoxes) - 1

    while i >= 0
        bx = array.get(wickBoxes, i)
        cl = array.get(centerLines, i)
        topPrice = array.get(boxTops, i)
        bottomPrice = array.get(boxBottoms, i)
        dir = array.get(boxDirs, i)

        crossedUpper = dir == 1 and close > topPrice
        crossedLower = dir == -1 and close < bottomPrice

        if crossedUpper or crossedLower
            f_deleteAt(i)
        else
            box.set_right(bx, bar_index)

            if not na(cl)
                line.set_x2(cl, bar_index)

        i -= 1

//----------------------------------------------------
// WICK CALCULATION
//----------------------------------------------------
bodyHigh = math.max(open, close)
bodyLow = math.min(open, close)

upperWick = high - bodyHigh
lowerWick = bodyLow - low

showUpper = wickSide == "Both" or wickSide == "Upper Only"
showLower = wickSide == "Both" or wickSide == "Lower Only"

validCandle =
     candleFilter == "All Candles" or
     candleFilter == "Bullish Candles Only" and close > open or
     candleFilter == "Bearish Candles Only" and close < open

//----------------------------------------------------
// DRAW NEW WICK BOXES
//----------------------------------------------------
if validCandle
    if showUpper and upperWick > 0
        f_checkAndDraw(upperWick, high, bodyHigh, 1)

    if showLower and lowerWick > 0
        f_checkAndDraw(lowerWick, bodyLow, low, -1)
````

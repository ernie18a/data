# Points from open price marker

- url: https://www.tradingview.com/script/2NmtQ337-Points-from-open-price-marker/
- type: indicator
- pine_id: PUB;0209eb4176f94b62bbf2e584edebc446
- version: 2.0

## Description

**Points From Open Price Marker**

The Points From Open Price Marker is a customizable tool designed to help traders visualize how far price moves above and below a selected candle's opening price.

The indicator identifies a user-selected reference candle and marks:

• The exact opening price
• The highest price reached above the open
• The lowest price reached below the open
• The total point expansion in both directions from the opening price

Each marker displays the actual price level and the number of points gained or lost from the candle's open, allowing traders to quickly measure volatility, expansion, and range development.

Features include:

✅ Select any candle timeframe
✅ Select any reference candle start time
✅ Measure upward and downward price expansion from the open
✅ Display price values, point distance, or both
✅ Customizable marker colors and sizes
✅ Optional open price bubble for quick reference

This tool can be used for studying opening ranges, session behavior, volatility expansion, market structure, and price movement patterns. Traders can apply it to futures, stocks, forex, or crypto to analyze how far price typically travels from important opening levels.

The indicator does not predict direction or provide trade signals. It is designed as a visual measurement tool to help traders understand price movement relative to a key candle open.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © K8etrades

//@version=6
indicator("Points from open price marker", overlay=true, max_labels_count=500)


//=================================
// TIMEZONEs
//=================================
string tz = "America/New_York"


//=================================
// USER SETTINGS
//=================================

// Reference candle settings

refTimeframe = input.timeframe(
     "240",
     "Reference Candle Timeframe")


refHour = input.int(
     6,
     "Reference Candle Hour (NY)",
     minval=0,
     maxval=23)


refMinute = input.int(
     0,
     "Reference Candle Minute",
     minval=0,
     maxval=59)



// Display options

showMarkers = input.bool(
     true,
     "Show High/Low Bubbles")


showPrice = input.bool(
     true,
     "Show Price")


showPoints = input.bool(
     true,
     "Show Points From Open")


showOpen = input.bool(
     true,
     "Show Open Label")


// Move labels

labelOffset = input.int(
     0,
     "Bubble Horizontal Offset (Bars)",
     minval=-20,
     maxval=20)



// Label size

labelSizeInput = input.string(
     "Normal",
     "Label Size",
     options=["Small","Normal","Large"])



// Colors

highColor = input.color(
     color.green,
     "High Bubble Color")


lowColor = input.color(
     color.red,
     "Low Bubble Color")


openColor = input.color(
     color.yellow,
     "Open Color")



//=================================
// GET REFERENCE CANDLE DATA
//=================================

[oTF, hTF, lTF, tTF] = request.security(
     syminfo.tickerid,
     refTimeframe,
     [open, high, low, time],
     lookahead = barmerge.lookahead_on)



//=================================
// IDENTIFY REFERENCE CANDLE
//=================================

isReference =
     hour(tTF, tz) == refHour and
     minute(tTF, tz) == refMinute



//=================================
// LABEL SIZE
//=================================

labelSize =
     labelSizeInput == "Small" ?
     size.small :
     labelSizeInput == "Large" ?
     size.large :
     size.normal



//=================================
// LABEL TEXT BUILDER
//=================================

makeText(price, points, direction) =>

    string txt = ""

    if showPrice
        txt += direction + " " + str.tostring(price,"#.00")

    if showPoints

        if txt != ""
            txt += "\n"

        if direction == "▲"
            txt += "+" + str.tostring(points,"#.00") + " pts"
        else
            txt += "-" + str.tostring(points,"#.00") + " pts"

    txt



//=================================
// DRAW ON REFERENCE CANDLE
//=================================

if isReference and showMarkers

    upPoints = hTF - oTF

    downPoints = oTF - lTF



    label.new(
         bar_index + labelOffset,
         hTF,
         makeText(hTF, upPoints, "▲"),
         style = label.style_label_down,
         color = highColor,
         textcolor = color.white,
         size = labelSize)



    label.new(
         bar_index + labelOffset,
         lTF,
         makeText(lTF, downPoints, "▼"),
         style = label.style_label_up,
         color = lowColor,
         textcolor = color.white,
         size = labelSize)



//=================================
// OPEN LABEL
//=================================

//=================================
// OPEN LABEL OUTSIDE CANDLE
//=================================

openOffset = input.int(
     0,
     "Open Bubble Offset (Bars)",
     minval=-20,
     maxval=20)


if isReference and showOpen

    label.new(
         bar_index + openOffset,
         oTF,
         "   " + str.tostring(oTF,"#.00"),
         style = label.style_label_left,
         color = openColor,
         textcolor = color.black,
         size = labelSize)


//=================================
// OPEN LINE
//=================================

plot(
     isReference ? oTF : na,
     title="Reference Open",
     color=openColor,
     linewidth=2,
     style=plot.style_linebr)
````

# FVG + Points (BLKBX)

- url: https://www.tradingview.com/script/UNEsK1Hd-FVG-Points-BLKBX/
- type: indicator
- pine_id: PUB;1c62f14d787e4c7da617543d1a779be5
- version: 1.0

## Description

FVG + Points (BLKBX)

A clean and minimal Fair Value Gap indicator built for futures traders who want to quickly visualize imbalance size in actual market points.

This script automatically detects bullish and bearish FVGs, displays customizable imbalance zones, and shows the exact point size of each gap directly inside the box at the 50% equilibrium level.

Features:
• Bullish + bearish FVG detection
• Real point values displayed inside each gap
• Adjustable FVG extension length
• Custom fill colors, border colors, and opacity
• Optional 50% equilibrium (CE) line
• Dashed / dotted / solid midpoint styles
• Lightweight and clean visual design optimized for MNQ / NQ futures trading

Designed for traders using ICT / liquidity concepts who want a cleaner visual understanding of imbalance size and efficiency directly on chart.

## Source Code

````pine
//@version=5
indicator("FVG + Points (BLKBX)", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

//====================================================
// SETTINGS
//====================================================

fvgLength = input.int(8, title = "FVG Length", minval = 1, maxval = 100)
minFVG = input.float(1.0, title = "Minimum FVG Size", step = 0.25)

showLabels = input.bool(true, title = "Show Point Labels")

//====================================================
// FILL SETTINGS
//====================================================

bullColor = input.color(color.green, title = "Bullish Fill Color")
bearColor = input.color(color.red, title = "Bearish Fill Color")

boxOpacity = input.int(85, title = "Fill Opacity", minval = 0, maxval = 100)

//====================================================
// BORDER SETTINGS
//====================================================

showBorders = input.bool(true, title = "Show Borders")

bullBorderColor = input.color(color.green, title = "Bullish Border Color")
bearBorderColor = input.color(color.red, title = "Bearish Border Color")

borderOpacity = input.int(40, title = "Border Opacity", minval = 0, maxval = 100)

borderWidth = input.int(1, title = "Border Width", minval = 1, maxval = 5)

//====================================================
// TEXT SETTINGS
//====================================================

textOpacity = input.int(0, title = "Text Opacity", minval = 0, maxval = 100)

textSize = input.string("Small", title = "Text Size", options = ["Tiny", "Small", "Normal"])

labelSize = textSize == "Tiny" ? size.tiny :
     textSize == "Normal" ? size.normal :
     size.small

//====================================================
// MIDLINE SETTINGS
//====================================================

showMidline = input.bool(true, title = "Show 50% Midline")

midlineColor = input.color(color.gray, title = "Midline Color")

midlineOpacity = input.int(40, title = "Midline Opacity", minval = 0, maxval = 100)

midlineWidth = input.int(1, title = "Midline Width", minval = 1, maxval = 5)

midlineStyleInput = input.string("Dashed", title = "Midline Style", options = ["Solid", "Dashed", "Dotted"])

midlineStyle = midlineStyleInput == "Solid" ? line.style_solid :
     midlineStyleInput == "Dotted" ? line.style_dotted :
     line.style_dashed

//====================================================
// CONDITIONS
//====================================================

bullFVG = low > high[2]
bearFVG = high < low[2]

bullPoints = math.abs(low - high[2])
bearPoints = math.abs(low[2] - high)

//====================================================
// BORDER COLORS
//====================================================

bullBorder = color.new(bullBorderColor, showBorders ? borderOpacity : 100)
bearBorder = color.new(bearBorderColor, showBorders ? borderOpacity : 100)

//====================================================
// BULLISH FVG
//====================================================

if bullFVG and bullPoints >= minFVG

    bullTop = low
    bullBottom = high[2]
    bullMid = bullBottom + ((bullTop - bullBottom) * 0.5)

    // BOX
    box.new(
         left = bar_index - 2,
         top = bullTop,
         right = bar_index + fvgLength,
         bottom = bullBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(bullColor, boxOpacity),
         border_color = bullBorder,
         border_width = borderWidth
     )

    // MIDLINE
    if showMidline

        line.new(
             x1 = bar_index - 2,
             y1 = bullMid,
             x2 = bar_index + fvgLength,
             y2 = bullMid,
             xloc = xloc.bar_index,
             color = color.new(midlineColor, midlineOpacity),
             style = midlineStyle,
             width = midlineWidth
         )

    // LABEL
    if showLabels

        label.new(
             x = bar_index + fvgLength - 1,
             y = bullMid,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             text = str.tostring(bullPoints, "#.##"),
             style = label.style_none,
             textalign = text.align_right,
             textcolor = color.new(bullBorderColor, textOpacity),
             size = labelSize
         )

//====================================================
// BEARISH FVG
//====================================================

if bearFVG and bearPoints >= minFVG

    bearTop = low[2]
    bearBottom = high
    bearMid = bearBottom + ((bearTop - bearBottom) * 0.5)

    // BOX
    box.new(
         left = bar_index - 2,
         top = bearTop,
         right = bar_index + fvgLength,
         bottom = bearBottom,
         xloc = xloc.bar_index,
         bgcolor = color.new(bearColor, boxOpacity),
         border_color = bearBorder,
         border_width = borderWidth
     )

    // MIDLINE
    if showMidline

        line.new(
             x1 = bar_index - 2,
             y1 = bearMid,
             x2 = bar_index + fvgLength,
             y2 = bearMid,
             xloc = xloc.bar_index,
             color = color.new(midlineColor, midlineOpacity),
             style = midlineStyle,
             width = midlineWidth
         )

    // LABEL
    if showLabels

        label.new(
             x = bar_index + fvgLength - 1,
             y = bearMid,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             text = str.tostring(bearPoints, "#.##"),
             style = label.style_none,
             textalign = text.align_right,
             textcolor = color.new(bearBorderColor, textOpacity),
             size = labelSize
         )
````

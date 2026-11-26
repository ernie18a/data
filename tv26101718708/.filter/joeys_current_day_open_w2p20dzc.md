# Joey's Current Day Open

- url: https://www.tradingview.com/script/W2p20DZc-Joey-s-Current-Day-Open/
- type: indicator
- pine_id: PUB;11bbc3ce2379418fb53010d1ab82b2d2
- version: 1.0

## Description

The Current Days Open with the ability to change settings etc.

## Source Code

````pine
 //@version=6
indicator("Joey's Current Day Open", overlay = true)

// === INPUTS ===
showLine = input.bool(true, "Show CDO")
col = input.color(color.rgb(13, 13, 13), "Line Color")
width = input.int(2, "Line Width", minval=1, maxval=5)

// Label position input
labelPos = input.string("Right", "Label Position", options=["Left", "Center", "Right"])

// Label extension control
labelExtend = input.int(15, "Label Extension (Bars)", minval=1)

// ✅ ADDED: Label color option
labelColor = input.color(color.black, "Label Color")

// Get current day open
CDO = request.security(syminfo.tickerid, "1D", open)

// Persistent objects
var line openLine = na
var label openLabel = na

// Create once
if barstate.isfirst and showLine
    openLine := line.new(bar_index, CDO, bar_index, CDO, extend=extend.right, color=col, width=width)

    // ONLY CHANGE: textcolor uses input
    openLabel := label.new(bar_index, CDO, "CDO",
         style=label.style_label_left,
         textcolor=labelColor,
         color=#ffffff00)

// Calculate label position
offset =
     labelPos == "Right"  ? labelExtend :
     labelPos == "Center" ? 0 :
                           -labelExtend

// Update every bar
if showLine and not na(openLine)
    line.set_y1(openLine, CDO)
    line.set_y2(openLine, CDO)

    label.set_xy(openLabel, bar_index + offset, CDO)
````

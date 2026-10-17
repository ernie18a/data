# Joey's PDH and PDL

- url: https://www.tradingview.com/script/1RceVPF7-Joey-s-PDH-and-PDL/
- type: indicator
- pine_id: PUB;aa291f41d78d445f8e271bb7b94516ec
- version: 1.0

## Description

Previous days high and low with the ability to change the settings.

## Source Code

````pine
//@version=6
indicator("Joey's PDH and PDL", overlay = true)

// === INPUTS ===
showLine = input.bool(true, "Show PDH / PDL")
colPDH = input.color(color.black, "PDH Color")
colPDL = input.color(color.black, "PDL Color")
width = input.int(2, "Line Width", minval=1, maxval=5)

// Label position control
labelPos = input.string("Right", "Label Position", options=["Left", "Center", "Right"])

// ✅ ADDED: label color input
labelColor = input.color(color.black, "Label Text Color")

// === DATA ===
PDH = request.security(syminfo.tickerid, "D", high[1])
PDL = request.security(syminfo.tickerid, "D", low[1])

// === OBJECTS ===
var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na

// === CREATE ON FIRST BAR ===
if barstate.isfirst and showLine
    pdhLine := line.new(bar_index, PDH, bar_index, PDH, extend=extend.right, color=colPDH, width=width)
    pdlLine := line.new(bar_index, PDL, bar_index, PDL, extend=extend.right, color=colPDL, width=width)

    // CHANGED ONLY: textcolor now uses input
    pdhLabel := label.new(bar_index, PDH, "PDH",
         style=label.style_label_left,
         textcolor=labelColor,
         color=#ffffff00)

    pdlLabel := label.new(bar_index, PDL, "PDL",
         style=label.style_label_left,
         textcolor=labelColor,
         color=#ffffff00)

// === POSITION LOGIC ===
labelOffset =
     labelPos == "Right"  ? 15 :
     labelPos == "Center" ? 0  :
                           -15

// === UPDATE EVERY BAR ===
if showLine and not na(pdhLine)
    line.set_y1(pdhLine, PDH)
    line.set_y2(pdhLine, PDH)

    line.set_y1(pdlLine, PDL)
    line.set_y2(pdlLine, PDL)

    label.set_xy(pdhLabel, bar_index + labelOffset, PDH)
    label.set_xy(pdlLabel, bar_index + labelOffset, PDL)
````

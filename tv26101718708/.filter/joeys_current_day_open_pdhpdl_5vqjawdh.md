# Joey's Current Day Open + PDH/PDL

- url: https://www.tradingview.com/script/5VqJAWDH-Joey-s-Current-Day-Open-PDH-PDL/
- type: indicator
- pine_id: PUB;06a861f3ae6e41fbab62e6dfa0c5e95e
- version: 1.0

## Description

Joey's Current Day Open + PDH/PDL
This indicator plots the current days open along with the previous day's high and low.

## Source Code

````pine
//@version=6
indicator("Joey's Current Day Open + PDH/PDL", overlay = true)

// === INPUTS ===
showLine = input.bool(true, "Show Levels")

cdoColor = input.color(color.rgb(13, 13, 13), "CDO Color")
pdhColor = input.color(color.green, "PDH Color")
pdlColor = input.color(color.red, "PDL Color")

width = input.int(2, "Line Width", minval=1, maxval=5)

// Label position input
labelPos = input.string("Right", "Label Position", options=["Left", "Center", "Right"])

// Label extension control
labelExtend = input.int(135, "Label Extension (Bars)", minval=1)

// Label color
labelColor = input.color(color.black, "Label Color")

// === LEVELS ===
CDO = request.security(syminfo.tickerid, "1D", open)
PDH = request.security(syminfo.tickerid, "1D", high[1])
PDL = request.security(syminfo.tickerid, "1D", low[1])

// === PERSISTENT OBJECTS ===
var line  cdoLine = na
var line  pdhLine = na
var line  pdlLine = na

var label cdoLabel = na
var label pdhLabel = na
var label pdlLabel = na

// === CREATE ON FIRST BAR ===
if barstate.isfirst and showLine

    cdoLine := line.new(bar_index, CDO, bar_index, CDO, extend=extend.right, color=cdoColor, width=width)
    pdhLine := line.new(bar_index, PDH, bar_index, PDH, extend=extend.right, color=pdhColor, width=width)
    pdlLine := line.new(bar_index, PDL, bar_index, PDL, extend=extend.right, color=pdlColor, width=width)

    cdoLabel := label.new(bar_index, CDO, "CDO", style=label.style_label_left, textcolor=labelColor, color=color.new(color.white, 100))
    pdhLabel := label.new(bar_index, PDH, "PDH", style=label.style_label_left, textcolor=labelColor, color=color.new(color.white, 100))
    pdlLabel := label.new(bar_index, PDL, "PDL", style=label.style_label_left, textcolor=labelColor, color=color.new(color.white, 100))

// === SAFE OFFSET (FIXED) ===
offset = labelPos == "Right" ? labelExtend : labelPos == "Center" ? 0 : -labelExtend

// === UPDATE EVERY BAR ===
if showLine and not na(cdoLine)

    // === CDO ===
    line.set_y1(cdoLine, CDO)
    line.set_y2(cdoLine, CDO)
    line.set_color(cdoLine, cdoColor)
    line.set_width(cdoLine, width)
    label.set_xy(cdoLabel, bar_index + offset, CDO)

    // === PDH ===
    line.set_y1(pdhLine, PDH)
    line.set_y2(pdhLine, PDH)
    line.set_color(pdhLine, pdhColor)
    line.set_width(pdhLine, width)
    label.set_xy(pdhLabel, bar_index + offset, PDH)

    // === PDL ===
    line.set_y1(pdlLine, PDL)
    line.set_y2(pdlLine, PDL)
    line.set_color(pdlLine, pdlColor)
    line.set_width(pdlLine, width)
    label.set_xy(pdlLabel, bar_index + offset, PDL)
````

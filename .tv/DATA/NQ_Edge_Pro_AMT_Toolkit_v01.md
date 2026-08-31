<!-- tradingview-pine-id: PUB;406ce17da96b402db57fa1e61e6a126d -->
<!-- tradingviewscripts-format: 1 -->
# NQ Edge Pro - AMT Toolkit v0.1

Source: https://www.tradingview.com/script/TwcFmJrr-NQ-Edge-Pro-AMT-Toolkit-v0-1/

## Description

//@version=6
indicator("NQ Edge Pro - AMT Toolkit v0.1", overlay=true, max_lines_count=100, max_labels_count=100)

//=========================
// INPUTS
//=========================
showPDLevels = input.bool(true, "Show Previous Day Levels")
showLabels   = input.bool(true, "Show Labels")
extendLines  = input.bool(true, "Extend Lines")

vahColor = color.new(color.green, 0)
pocColor = color.new(color.yellow, 0)
valColor = color.new(color.red, 0)

//=========================
// PREVIOUS DAY DATA
//=========================
prevHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

prevLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

// Temporary approximation
dayRange = prevHigh - prevLow

prevPOC = prevLow + dayRange * 0.50
prevVAH = prevLow + dayRange * 0.70
prevVAL = prevLow + dayRange * 0.30

// Correct new-day detection
newDay = timeframe.change("D")

//=========================
// DRAW LINES
//=========================
var line vahLine = na
var line pocLine = na
var line valLine = na

if newDay and showPDLevels
    line.delete(vahLine)
    line.delete(pocLine)
    line.delete(valLine)

    vahLine := line.new(
         bar_index, prevVAH,
         bar_index + 1, prevVAH,
         extend=extendLines ? extend.right : extend.none,
         color=vahColor,
         width=2)

    pocLine := line.new(
         bar_index, prevPOC,
         bar_index + 1, prevPOC,
         extend=extendLines ? extend.right : extend.none,
         color=pocColor,
         width=2)

    valLine := line.new(
         bar_index, prevVAL,
         bar_index + 1, prevVAL,
         extend=extendLines ? extend.right : extend.none,
         color=valColor,
         width=2)

//=========================
// LABELS
//=========================
if newDay and showPDLevels and showLabels
    label.new(
         bar_index, prevVAH,
         "Prev VAH",
         style=label.style_label_left,
         color=vahColor,
         textcolor=color.white)

    label.new(
         bar_index, prevPOC,
         "Prev POC",
         style=label.style_label_left,
         color=pocColor,
         textcolor=color.black)

    label.new(
         bar_index, prevVAL,
         "Prev VAL",
         style=label.style_label_left,
         color=valColor,
         textcolor=color.white)

//=========================
// DASHBOARD
//=========================
var table dash = table.new(
     position.top_right,
     2,
     5,
     border_width=1)

location = close > prevVAH ? "Above Value" :
     close < prevVAL ? "Below Value" :
     "Inside Value"

if barstate.islast
    table.cell(
         dash, 0, 0,
         "AMT TOOLKIT",
         text_color=color.white,
         bgcolor=color.blue)

    table.cell(
         dash, 1, 0,
         location,
         text_color=color.white,
         bgcolor=color.blue)

    table.cell(dash, 0, 1, "Prev VAH")
    table.cell(dash, 1, 1, str.tostring(prevVAH, format.mintick))

    table.cell(dash, 0, 2, "Prev POC")
    table.cell(dash, 1, 2, str.tostring(prevPOC, format.mintick))

    table.cell(dash, 0, 3, "Prev VAL")
    table.cell(dash, 1, 3, str.tostring(prevVAL, format.mintick))

    table.cell(dash, 0, 4, "Location")
    table.cell(dash, 1, 4, location)

---

## Source Code

````pine
//@version=6
indicator("NQ Edge Pro - AMT Toolkit v0.1", overlay=true, max_lines_count=100, max_labels_count=100)

//=========================
// INPUTS
//=========================
showPDLevels = input.bool(true, "Show Previous Day Levels")
showLabels   = input.bool(true, "Show Labels")
extendLines  = input.bool(true, "Extend Lines")

vahColor = color.new(color.green, 0)
pocColor = color.new(color.yellow, 0)
valColor = color.new(color.red, 0)

//=========================
// PREVIOUS DAY DATA
//=========================
prevHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

prevLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

// Temporary approximation
dayRange = prevHigh - prevLow

prevPOC = prevLow + dayRange * 0.50
prevVAH = prevLow + dayRange * 0.70
prevVAL = prevLow + dayRange * 0.30

// Correct new-day detection
newDay = timeframe.change("D")

//=========================
// DRAW LINES
//=========================
var line vahLine = na
var line pocLine = na
var line valLine = na

if newDay and showPDLevels
    line.delete(vahLine)
    line.delete(pocLine)
    line.delete(valLine)

    vahLine := line.new(
         bar_index, prevVAH,
         bar_index + 1, prevVAH,
         extend=extendLines ? extend.right : extend.none,
         color=vahColor,
         width=2)

    pocLine := line.new(
         bar_index, prevPOC,
         bar_index + 1, prevPOC,
         extend=extendLines ? extend.right : extend.none,
         color=pocColor,
         width=2)

    valLine := line.new(
         bar_index, prevVAL,
         bar_index + 1, prevVAL,
         extend=extendLines ? extend.right : extend.none,
         color=valColor,
         width=2)

//=========================
// LABELS
//=========================
if newDay and showPDLevels and showLabels
    label.new(
         bar_index, prevVAH,
         "Prev VAH",
         style=label.style_label_left,
         color=vahColor,
         textcolor=color.white)

    label.new(
         bar_index, prevPOC,
         "Prev POC",
         style=label.style_label_left,
         color=pocColor,
         textcolor=color.black)

    label.new(
         bar_index, prevVAL,
         "Prev VAL",
         style=label.style_label_left,
         color=valColor,
         textcolor=color.white)

//=========================
// DASHBOARD
//=========================
var table dash = table.new(
     position.top_right,
     2,
     5,
     border_width=1)

location = close > prevVAH ? "Above Value" :
     close < prevVAL ? "Below Value" :
     "Inside Value"

if barstate.islast
    table.cell(
         dash, 0, 0,
         "AMT TOOLKIT",
         text_color=color.white,
         bgcolor=color.blue)

    table.cell(
         dash, 1, 0,
         location,
         text_color=color.white,
         bgcolor=color.blue)

    table.cell(dash, 0, 1, "Prev VAH")
    table.cell(dash, 1, 1, str.tostring(prevVAH, format.mintick))

    table.cell(dash, 0, 2, "Prev POC")
    table.cell(dash, 1, 2, str.tostring(prevPOC, format.mintick))

    table.cell(dash, 0, 3, "Prev VAL")
    table.cell(dash, 1, 3, str.tostring(prevVAL, format.mintick))

    table.cell(dash, 0, 4, "Location")
    table.cell(dash, 1, 4, location)
````

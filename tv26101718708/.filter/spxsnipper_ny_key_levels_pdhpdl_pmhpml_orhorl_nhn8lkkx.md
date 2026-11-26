# SpxSnipper - NY Key Levels: PDH/PDL + PMH/PML + ORH/ORL

- url: https://www.tradingview.com/script/nHN8lKKX-SpxSnipper-NY-Key-Levels-PDH-PDL-PMH-PML-ORH-ORL/
- type: indicator
- pine_id: PUB;a5414e31784848d7b9152f92aa4698d0
- version: 1.0

## Description

NY Session Key Levels is a clean intraday reference tool designed to plot important price levels during the New York regular trading session.

The indicator displays horizontal levels from the regular market open to the regular market close, based on:

• Previous Regular Session High
• Previous Regular Session Low
• Pre-Market High
• Pre-Market Low
• Opening Range High
• Opening Range Low

The Opening Range is calculated using the first 30 minutes of the regular New York session, while the Pre-Market range is calculated only from the period before the regular market open. After-hours data is not included in the pre-market calculation.

Each group of levels uses a separate color for easier visual distinction, and optional labels are displayed on the chart to identify each level.

This tool is intended to help traders visually organize key intraday reference areas. It does not generate buy or sell signals and should not be used as a standalone trading system.

Main features:
• Previous regular session high and low
• Pre-market high and low
• First 30-minute opening range high and low
• Lines plotted only during the regular NY session
• Customizable colors
• Optional labels
• Adjustable line width and style
• Timezone and session inputs

Best used on intraday charts for instruments where New York session levels are relevant.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - NY Key Levels: PDH/PDL + PMH/PML + ORH/ORL", overlay = true, max_lines_count = 50, max_labels_count = 50)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
tzInput     = input.string("America/New_York", "Timezone")

rthSession  = input.session("0930-1600:23456", "Regular NY Session")
pmSession   = input.session("0400-0930:23456", "Pre-Market Session")
orSession   = input.session("0930-1000:23456", "Opening Range Session")

showPD      = input.bool(true, "Show Previous Regular Session High/Low")
showPM      = input.bool(true, "Show Pre-Market High/Low")
showOR      = input.bool(true, "Show Opening Range High/Low")
showLabels  = input.bool(true, "Show Labels")

pdColor     = input.color(color.rgb(30, 144, 255), "Previous Day Color")
pmColor     = input.color(color.rgb(255, 165, 0), "Pre-Market Color")
orColor     = input.color(color.rgb(50, 205, 50), "Opening Range Color")

lineWidth   = input.int(2, "Line Width", minval = 1, maxval = 5)
lineStyleIn = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleIn == "Dashed" ? line.style_dashed :
     lineStyleIn == "Dotted" ? line.style_dotted :
     line.style_solid

// ─────────────────────────────────────────────
// NY timestamps
// ─────────────────────────────────────────────
nyYear  = year(time, tzInput)
nyMonth = month(time, tzInput)
nyDay   = dayofmonth(time, tzInput)

marketOpenTs  = timestamp(tzInput, nyYear, nyMonth, nyDay, 9, 30)
marketCloseTs = timestamp(tzInput, nyYear, nyMonth, nyDay, 16, 0)

newNyDay = na(time[1]) or nyDay != dayofmonth(time[1], tzInput) or nyMonth != month(time[1], tzInput) or nyYear != year(time[1], tzInput)

// ─────────────────────────────────────────────
// Session detection
// ─────────────────────────────────────────────
inRTH = not na(time(timeframe.period, rthSession, tzInput))
inPM  = not na(time(timeframe.period, pmSession, tzInput))
inOR  = not na(time(timeframe.period, orSession, tzInput))

rthStart = inRTH and not inRTH[1]
rthEnd   = not inRTH and inRTH[1]

// ─────────────────────────────────────────────
// Track Previous Regular Session High / Low
// Αυτό είναι το high/low της προηγούμενης κανονικής συνεδρίασης,
// όχι pre-market και όχι after-market.
// ─────────────────────────────────────────────
var float currentRthHigh = na
var float currentRthLow  = na
var float prevRthHigh    = na
var float prevRthLow     = na

if rthStart
    currentRthHigh := high
    currentRthLow  := low
else if inRTH
    currentRthHigh := na(currentRthHigh) ? high : math.max(currentRthHigh, high)
    currentRthLow  := na(currentRthLow)  ? low  : math.min(currentRthLow, low)

if rthEnd
    prevRthHigh := currentRthHigh
    prevRthLow  := currentRthLow

// ─────────────────────────────────────────────
// Track Pre-Market High / Low and Opening Range
// ─────────────────────────────────────────────
var float pmHigh = na
var float pmLow  = na
var float orHigh = na
var float orLow  = na

if newNyDay
    pmHigh := na
    pmLow  := na
    orHigh := na
    orLow  := na

if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)

if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

// ─────────────────────────────────────────────
// Drawing objects
// ─────────────────────────────────────────────
var line  pdhLine = na
var line  pdlLine = na
var line  pmhLine = na
var line  pmlLine = na
var line  orhLine = na
var line  orlLine = na

var label pdhLabel = na
var label pdlLabel = na
var label pmhLabel = na
var label pmlLabel = na
var label orhLabel = na
var label orlLabel = na

f_deleteLine(line ln) =>
    if not na(ln)
        line.delete(ln)

f_deleteLabel(label lb) =>
    if not na(lb)
        label.delete(lb)

// Create fresh objects for the current NY day
if newNyDay or na(pdhLine)
    f_deleteLine(pdhLine)
    f_deleteLine(pdlLine)
    f_deleteLine(pmhLine)
    f_deleteLine(pmlLine)
    f_deleteLine(orhLine)
    f_deleteLine(orlLine)

    f_deleteLabel(pdhLabel)
    f_deleteLabel(pdlLabel)
    f_deleteLabel(pmhLabel)
    f_deleteLabel(pmlLabel)
    f_deleteLabel(orhLabel)
    f_deleteLabel(orlLabel)

    pdhLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(pdColor, 100), width = lineWidth, style = lineStyle)
    pdlLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(pdColor, 100), width = lineWidth, style = lineStyle)

    pmhLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(pmColor, 100), width = lineWidth, style = lineStyle)
    pmlLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(pmColor, 100), width = lineWidth, style = lineStyle)

    orhLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(orColor, 100), width = lineWidth, style = lineStyle)
    orlLine := line.new(marketOpenTs, close, marketCloseTs, close, xloc = xloc.bar_time, color = color.new(orColor, 100), width = lineWidth, style = lineStyle)

    pdhLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = pdColor, size = size.small)
    pdlLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = pdColor, size = size.small)

    pmhLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = pmColor, size = size.small)
    pmlLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = pmColor, size = size.small)

    orhLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = orColor, size = size.small)
    orlLabel := label.new(marketCloseTs, close, "", xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = orColor, size = size.small)

// ─────────────────────────────────────────────
// Update helper
// ─────────────────────────────────────────────
f_updateLevel(line ln, label lb, float price, string txt, color col, bool visible) =>
    if visible and not na(price)
        line.set_xy1(ln, marketOpenTs, price)
        line.set_xy2(ln, marketCloseTs, price)
        line.set_color(ln, col)
        line.set_width(ln, lineWidth)
        line.set_style(ln, lineStyle)

        label.set_x(lb, marketCloseTs)
        label.set_y(lb, price)
        label.set_text(lb, showLabels ? txt : "")
        label.set_textcolor(lb, col)
        label.set_color(lb, color.new(color.black, 100))
    else
        line.set_color(ln, color.new(col, 100))
        label.set_text(lb, "")

// ─────────────────────────────────────────────
// Update levels
// ─────────────────────────────────────────────
f_updateLevel(pdhLine, pdhLabel, prevRthHigh, "PDH", pdColor, showPD)
f_updateLevel(pdlLine, pdlLabel, prevRthLow,  "PDL", pdColor, showPD)

f_updateLevel(pmhLine, pmhLabel, pmHigh, "PMH", pmColor, showPM)
f_updateLevel(pmlLine, pmlLabel, pmLow,  "PML", pmColor, showPM)

f_updateLevel(orhLine, orhLabel, orHigh, "ORH", orColor, showOR)
f_updateLevel(orlLine, orlLabel, orLow,  "ORL", orColor, showOR)
````

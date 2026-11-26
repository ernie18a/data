# Prav_Levels

- url: https://www.tradingview.com/script/2mG4h7MF-Prav-Levels/
- type: indicator
- pine_id: PUB;77c509c2ab3c4bd7b32d04ac57ea41ab
- version: 1.0

## Description

This Pine Script indicator plots persistent higher timeframe liquidity levels including Previous Day High/Low/Close (PDH, PDL, PDC), Previous Week High/Low (PWH, PWL), and Previous Month High/Low (PMH, PML). It creates the levels only once per new day, week, or month, preventing constant redraws and improving chart performance. The lines automatically extend only up to the current candle and remain visible across all lower timeframes. Labels are dynamically positioned on the right side with ATR-based spacing to avoid overlapping. If multiple levels are very close, the script intelligently merges labels such as “PDH/PWH” for cleaner visualization. The indicator also supports customizable line styles and widths for better chart appearance

## Source Code

````pine
//@version=5
indicator("Prav_Levels", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// INPUTS
//====================================================

lineWidth = input.int(1, "Line Width", minval=1, maxval=5)

lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

lineStyle = lineStyleInput == "Dashed" ? line.style_dashed : lineStyleInput == "Dotted" ? line.style_dotted : line.style_solid

//====================================================
// COLORS
//====================================================

redColor = color.red
blueColor = color.blue
yellowColor = color.yellow

//====================================================
// HIGHER TIMEFRAME LEVELS
//====================================================

// Daily
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
pdc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

// Weekly
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)

// Monthly
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

//====================================================
// PERIOD CHANGE
//====================================================

newDay = ta.change(time("D"))
newWeek = ta.change(time("W"))
newMonth = ta.change(time("M"))

//====================================================
// DYNAMIC OFFSET
//====================================================

offsetUp = ta.atr(14) * 0.08
offsetDown = ta.atr(14) * 0.08

//====================================================
// OVERLAP DETECTION
//====================================================

mergeThreshold = ta.atr(14) * 0.03

pdhText = math.abs(pdh - pwh) < mergeThreshold ? "PDH/PWH" :
          math.abs(pdh - pmh) < mergeThreshold ? "PDH/PMH" :
          "PDH"

pwhText = math.abs(pwh - pdh) < mergeThreshold ? "" :
          math.abs(pwh - pmh) < mergeThreshold ? "PWH/PMH" :
          "PWH"

pdlText = math.abs(pdl - pwl) < mergeThreshold ? "PDL/PWL" :
          math.abs(pdl - pml) < mergeThreshold ? "PDL/PML" :
          "PDL"

pwlText = math.abs(pwl - pdl) < mergeThreshold ? "" :
          math.abs(pwl - pml) < mergeThreshold ? "PWL/PML" :
          "PWL"

pmhText = math.abs(pmh - pdh) < mergeThreshold or math.abs(pmh - pwh) < mergeThreshold ? "" : "PMH"

pmlText = math.abs(pml - pdl) < mergeThreshold or math.abs(pml - pwl) < mergeThreshold ? "" : "PML"

//====================================================
// LINE VARIABLES
//====================================================

var line pdhLine = na
var line pdlLine = na
var line pdcLine = na

var line pwhLine = na
var line pwlLine = na

var line pmhLine = na
var line pmlLine = na

//====================================================
// LABEL VARIABLES
//====================================================

var label pdhLabel = na
var label pdlLabel = na
var label pdcLabel = na

var label pwhLabel = na
var label pwlLabel = na

var label pmhLabel = na
var label pmlLabel = na

//====================================================
// DAILY LEVELS
//====================================================

if newDay

    line.delete(pdhLine)
    line.delete(pdlLine)
    line.delete(pdcLine)

    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(pdcLabel)

    // PDH
    pdhLine := line.new(
         bar_index,
         pdh,
         bar_index,
         pdh,
         color=redColor,
         width=lineWidth,
         style=lineStyle
     )

    pdhLabel := label.new(
         bar_index + 1,
         pdh + offsetUp,
         pdhText,
         style=label.style_none,
         textcolor=redColor,
         size=size.small
     )

    // PDL
    pdlLine := line.new(
         bar_index,
         pdl,
         bar_index,
         pdl,
         color=blueColor,
         width=lineWidth,
         style=lineStyle
     )

    pdlLabel := label.new(
         bar_index + 1,
         pdl - offsetDown,
         pdlText,
         style=label.style_none,
         textcolor=blueColor,
         size=size.small
     )

    // PDC
    pdcLine := line.new(
         bar_index,
         pdc,
         bar_index,
         pdc,
         color=yellowColor,
         width=lineWidth,
         style=lineStyle
     )

    pdcLabel := label.new(
         bar_index + 1,
         pdc + offsetUp,
         "PDC",
         style=label.style_none,
         textcolor=yellowColor,
         size=size.small
     )

//====================================================
// WEEKLY LEVELS
//====================================================

if newWeek

    line.delete(pwhLine)
    line.delete(pwlLine)

    label.delete(pwhLabel)
    label.delete(pwlLabel)

    // PWH
    pwhLine := line.new(
         bar_index,
         pwh,
         bar_index,
         pwh,
         color=redColor,
         width=lineWidth,
         style=lineStyle
     )

    pwhLabel := label.new(
         bar_index + 1,
         pwh + offsetUp,
         pwhText,
         style=label.style_none,
         textcolor=redColor,
         size=size.small
     )

    // PWL
    pwlLine := line.new(
         bar_index,
         pwl,
         bar_index,
         pwl,
         color=redColor,
         width=lineWidth,
         style=lineStyle
     )

    pwlLabel := label.new(
         bar_index + 1,
         pwl - offsetDown,
         pwlText,
         style=label.style_none,
         textcolor=redColor,
         size=size.small
     )

//====================================================
// MONTHLY LEVELS
//====================================================

if newMonth

    line.delete(pmhLine)
    line.delete(pmlLine)

    label.delete(pmhLabel)
    label.delete(pmlLabel)

    // PMH
    pmhLine := line.new(
         bar_index,
         pmh,
         bar_index,
         pmh,
         color=redColor,
         width=lineWidth,
         style=lineStyle
     )

    pmhLabel := label.new(
         bar_index + 1,
         pmh + offsetUp,
         pmhText,
         style=label.style_none,
         textcolor=redColor,
         size=size.small
     )

    // PML
    pmlLine := line.new(
         bar_index,
         pml,
         bar_index,
         pml,
         color=redColor,
         width=lineWidth,
         style=lineStyle
     )

    pmlLabel := label.new(
         bar_index + 1,
         pml - offsetDown,
         pmlText,
         style=label.style_none,
         textcolor=redColor,
         size=size.small
     )

//====================================================
// UPDATE LINES TO CURRENT BAR
//====================================================

if not na(pdhLine)
    line.set_x2(pdhLine, bar_index)

if not na(pdlLine)
    line.set_x2(pdlLine, bar_index)

if not na(pdcLine)
    line.set_x2(pdcLine, bar_index)

if not na(pwhLine)
    line.set_x2(pwhLine, bar_index)

if not na(pwlLine)
    line.set_x2(pwlLine, bar_index)

if not na(pmhLine)
    line.set_x2(pmhLine, bar_index)

if not na(pmlLine)
    line.set_x2(pmlLine, bar_index)

//====================================================
// MOVE LABELS TO RIGHT SIDE
//====================================================

if not na(pdhLabel)
    label.set_x(pdhLabel, bar_index + 1)

if not na(pdlLabel)
    label.set_x(pdlLabel, bar_index + 1)

if not na(pdcLabel)
    label.set_x(pdcLabel, bar_index + 1)

if not na(pwhLabel)
    label.set_x(pwhLabel, bar_index + 1)

if not na(pwlLabel)
    label.set_x(pwlLabel, bar_index + 1)

if not na(pmhLabel)
    label.set_x(pmhLabel, bar_index + 1)

if not na(pmlLabel)
    label.set_x(pmlLabel, bar_index + 1)
````

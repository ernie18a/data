# Boombastic V1 10AM Levels V2

- url: https://www.tradingview.com/script/MNDQfLQD-Boombastic-V1-10AM-Levels-V2/
- type: indicator
- pine_id: PUB;1402cae6a57d449aa3d0f1107a1d9739
- version: 1.0

## Description

Boombastic V2 is an intraday reference tool built around the ICT-style 10:00 AM (ET) candle, combined with a full set of higher-timeframe and previous-period highs and lows. Every level is read from a fixed source timeframe (1-minute by default), so the lines stay locked to the exact candle they were drawn from no matter which chart timeframe you switch to.

Make sure you chart is on EST

What it plots

The 10 AM candle ("full candle")


Open and Close lines
Body midpoint — (open + close) / 2
Full-candle box (high → low) with a Consequent Encroachment / equilibrium line at (high + low) / 2
Optional body shading
A per-day label anchored to the box equilibrium
The current day's candle box can be highlighted with its own border and background color


You aren't limited to 10:00 — change the hour, minute, timezone, or source timeframe to mark any candle you track (the 9:30 open, a session candle, the midnight candle, etc.).

True Day Open
A dotted line at the midnight (00:00 ET) candle open — the ICT "true day open" — with its own retention setting and label.

Higher-timeframe highs & lows (4H / 1H / 30m / 15m)
The previous (last closed) candle's high and low for each timeframe, drawn as solid lines and labeled. Each timeframe toggles on or off independently and has its own color.

Previous Day / Week / Month (PDH/PDL, PWH/PWL, PMH/PML)
The prior day, week, and month highs and lows — classic draws on liquidity — each toggleable with its own color and labeled in the same clean style as the 10 AM candle labels.

Key behaviors


Locked to the source candle. Levels are pulled from the source timeframe, so they don't shift when you change chart timeframes.
Swept levels turn dotted. When price trades through a high or low, that line automatically switches from solid to dotted — an instant read on which liquidity has been taken and which is still resting. It resets when the period rolls over (new candle / day / week / month).
Labeled with leaders. Every level's label sits in a column to the right of price, connected back to its line by a dotted leader. The offset distance is adjustable.
History & projection. Keep a configurable number of past days, project levels into the future whitespace, and optionally carry previous days' zones forward as live reference.


Settings highlights


Target candle: hour, minute, timezone, source timeframe
Days to keep: separate controls for the Sessions (10 AM candles) and the True Day Open
Elements: toggle and color each component, plus current-day box highlight colors
Style: line width, label offset, extend distance, extend-previous behavior
HTF and D/W/M groups: per-item toggles, colors, and independent line widths


Notes

This is a charting and reference tool — not a signal generator or financial advice. 1-minute history is limited by your TradingView plan, so very old sessions only appear if that data loads on your chart.

## Source Code

````pine
//@version=6
// ============================================================================
//  10 AM Candle Levels — 1-min body
//  Marks the 1-minute 10:00 candle:
//    • solid line at the OPEN
//    • solid line at the CLOSE
//    • dotted line at the body MIDPOINT  =  (open + close) / 2
//    • gray shading of the BODY (open→close)
//    • optional shading of the FULL CANDLE (high→low, wick to wick)
//    • day label centered on the right edge of the box (weekday + date)
//  Plus the ICT TRUE DAY OPEN (midnight ET open) as a dotted purple line.
//  All values are pulled from the 1-minute candle, so the levels stay locked
//  to that candle no matter which chart timeframe you switch to.
// ============================================================================
indicator("Boombastic V1", shorttitle = "Boombastic V1",
     overlay = true, max_lines_count = 500, max_boxes_count = 500,
     max_labels_count = 500)

// ---------------------------------------------------------------------------
//  INPUTS
// ---------------------------------------------------------------------------
grpT   = "Target candle"
tz     = input.string("America/New_York", "Timezone", group = grpT,
     options = ["America/New_York", "America/Chicago", "America/Denver",
                "America/Los_Angeles", "Europe/London", "UTC"])
hr     = input.int(10, "Hour (24h)",  minval = 0, maxval = 23, group = grpT)
mn     = input.int(0,  "Minute",      minval = 0, maxval = 59, group = grpT)
srcTF  = input.timeframe("1", "Source timeframe", group = grpT,
     tooltip = "The candle the levels are read from. Stays fixed when you change the chart timeframe.")
daysKeep  = input.int(10, "Days to keep — Sessions 10 Candle (0 = all)", minval = 0, maxval = 250, group = grpT,
     tooltip = "How many past days of 10AM candle levels (boxes, lines, labels) to retain. Note: 1-minute history is limited by your TradingView plan, so older days only appear if that data loads.")
daysKeepTDO = input.int(5, "Days to keep — True Day Open (0 = all)", minval = 0, maxval = 250, group = grpT,
     tooltip = "How many past days of True Day Open lines/labels to retain, independent of the Sessions setting.")

grpE   = "Elements"
showRange = input.bool(true,  "Shade full candle (high→low)", group = grpE, inline = "r",
     tooltip = "Shades the whole 10AM candle from the top wick to the bottom wick. Border lines mark the high and low.")
rangeFill   = input.color(color.new(#2962FF, 90), "", group = grpE, inline = "r")
rangeBorder = input.color(color.new(#2962FF, 30), "", group = grpE, inline = "r")
curRangeBorder = input.color(color.new(color.green, 0), "Current day candle border", group = grpE,
     tooltip = "The most recent (current) day's full-candle box uses this border color. Older days revert to the border color set above.")
curRangeFill = input.color(color.new(color.green, 90), "Current day candle background", group = grpE,
     tooltip = "Background fill for the most recent (current) day's full-candle box. Older days revert to the fill color set above.")
showMidR  = input.bool(true,  "Full candle midpoint / CE (dotted)", group = grpE, inline = "mr",
     tooltip = "Equilibrium of the full candle range = (high + low) / 2.")
midRCol   = input.color(#2962FF, "",               group = grpE, inline = "mr")
showOpen  = input.bool(true,  "Open line",         group = grpE, inline = "o")
openCol   = input.color(#2962FF, "",               group = grpE, inline = "o")
showClose = input.bool(true,  "Close line",        group = grpE, inline = "c")
closeCol  = input.color(#FF6D00, "",               group = grpE, inline = "c")
showMid   = input.bool(true,  "Body midpoint (dotted)", group = grpE, inline = "m")
midCol    = input.color(#787B86, "",               group = grpE, inline = "m")
showFill  = input.bool(false, "Shade body (open→close)", group = grpE, inline = "f")
fillCol   = input.color(color.new(color.gray, 80), "", group = grpE, inline = "f")
showLabel = input.bool(true,  "Day label",         group = grpE, inline = "d")
labelCol  = input.color(#787B86, "",               group = grpE, inline = "d")
showDayOpen = input.bool(true, "True day open (midnight ET)", group = grpE, inline = "t",
     tooltip = "Dotted line at the open of the 00:00 candle in the Timezone above. Keep Timezone on New York for the canonical ICT true day open.")
dayOpenCol  = input.color(#9C27B0, "",             group = grpE, inline = "t")

grpS   = "Style"
lineWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = grpS)
extendRight = input.bool(true, "Extend levels to the right", group = grpS)
extendBars  = input.int(10, "Extend distance (bars, max 500)", minval = 0, maxval = 500, group = grpS,
     tooltip = "How far the zone projects into the future whitespace. 500 is the Pine maximum.")
extendPrev  = input.bool(true, "Extend previous days forward", group = grpS,
     tooltip = "Keep every past day's lines AND shaded boxes running forward as live reference zones. They project the full extend distance past price.")
labelOffset = input.int(20, "Label offset (bars to the right)", minval = 0, maxval = 500, group = grpS,
     tooltip = "Pushes the day and True Day Open labels this many bars to the right of the extended levels, with a dotted leader line connecting each label back to its level. 0 = label sits on the level end (no leader).")

grpH   = "HTF Highs & Lows"
show4H  = input.bool(true,  "4H high & low",  group = grpH, inline = "4h")
col4H   = input.color(#FF9800, "",            group = grpH, inline = "4h")
show1H  = input.bool(true,  "1H high & low",  group = grpH, inline = "1h")
col1H   = input.color(#FFD600, "",            group = grpH, inline = "1h")
show30  = input.bool(true,  "30m high & low", group = grpH, inline = "30")
col30   = input.color(#00BCD4, "",            group = grpH, inline = "30")
show15  = input.bool(true,  "15m high & low", group = grpH, inline = "15")
col15   = input.color(#E91E63, "",            group = grpH, inline = "15")
htfWidth = input.int(1, "HTF line width", minval = 1, maxval = 5, group = grpH,
     tooltip = "Solid horizontal lines at the previous (last closed) candle's high and low for each timeframe. Uncheck any timeframe to hide both its high and low.")

grpD   = "Previous Day / Week / Month"
showD  = input.bool(true,  "Previous day high & low",   group = grpD, inline = "pd")
colD   = input.color(#FFFFFF, "",                       group = grpD, inline = "pd")
showW  = input.bool(true,  "Previous week high & low",  group = grpD, inline = "pw")
colW   = input.color(#FF5252, "",                       group = grpD, inline = "pw")
showM  = input.bool(true,  "Previous month high & low", group = grpD, inline = "pm")
colM   = input.color(#7C4DFF, "",                       group = grpD, inline = "pm")
dwmWidth = input.int(2, "D/W/M line width", minval = 1, maxval = 5, group = grpD,
     tooltip = "Solid horizontal lines at the previous day / week / month high and low. Same behavior as the HTF lines: once taken, the line turns dotted and its label moves to the middle.")

// ---------------------------------------------------------------------------
//  FETCH FROM THE SOURCE TIMEFRAME
//  - target candle full OHLC at hr:mn
//  - true day open: the open of the 00:00 candle (ICT midnight)
//  Both run in the source-TF context and carry forward until the next event.
// ---------------------------------------------------------------------------
f_levels() =>
    isTarget   = hour(time, tz) == hr and minute(time, tz) == mn
    isMidnight = hour(time, tz) == 0  and minute(time, tz) == 0
    var float o     = na
    var float c     = na
    var float h     = na
    var float l     = na
    var int   t     = na
    var float dOpen = na
    var int   dTime = na
    if isTarget
        o := open
        c := close
        h := high
        l := low
        t := time
    if isMidnight
        dOpen := open
        dTime := time
    [o, c, h, l, t, dOpen, dTime]

[tOpen, tClose, tHigh, tLow, tTime, dOpen, dTime] = request.security(syminfo.tickerid, srcTF, f_levels())

// Previous (last closed) candle high & low for each higher timeframe.
// Using [1] with lookahead off = the most recent COMPLETED candle, no repaint.
[h4,  l4]  = request.security(syminfo.tickerid, "240", [high[1], low[1]], lookahead = barmerge.lookahead_off)
[h1,  l1]  = request.security(syminfo.tickerid, "60",  [high[1], low[1]], lookahead = barmerge.lookahead_off)
[h30, l30] = request.security(syminfo.tickerid, "30",  [high[1], low[1]], lookahead = barmerge.lookahead_off)
[h15, l15] = request.security(syminfo.tickerid, "15",  [high[1], low[1]], lookahead = barmerge.lookahead_off)

// Previous day / week / month high & low (last closed period, no repaint).
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_off)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_off)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_off)

// Draw / update a persistent level line + label for a previous-candle high/low.
// Each label sits in the offset column (labelX) with a dotted leader back to the
// level. Once price takes the level (sweeps through), the main line turns dotted.
// lblBg / lblTxt set the label + leader color and text color (lets D/W/M match the
// full-candle day labels). Resets on new period. Trailing `true` keeps return type.
f_hl(show, lvl, isHigh, txt, col, w, rx, lx, lblBg, lblTxt) =>
    var line  ln     = na
    var line  lead   = na
    var label lb     = na
    var bool  taken  = false
    var float curLvl = na
    if show and not na(lvl)
        if na(curLvl) or lvl != curLvl
            taken  := false
            curLvl := lvl
        if not taken and ((isHigh and high >= lvl) or (not isHigh and low <= lvl))
            taken := true
        if na(ln)
            ln   := line.new(bar_index, lvl, rx, lvl, color = col, width = w)
            lead := line.new(rx, lvl, lx, lvl, color = lblBg, width = 1, style = line.style_dotted)
            lb   := label.new(lx, lvl, txt, style = label.style_label_left, color = lblBg, textcolor = lblTxt, size = size.small)
        line.set_y1(ln, lvl)
        line.set_xy2(ln, rx, lvl)
        line.set_style(ln, taken ? line.style_dotted : line.style_solid)
        line.set_xy1(lead, rx, lvl)
        line.set_xy2(lead, lx, lvl)
        label.set_xy(lb, lx, lvl)
        label.set_text(lb, txt)
    else if not na(ln)
        line.delete(ln)
        line.delete(lead)
        label.delete(lb)
        ln   := na
        lead := na
        lb   := na
    true

// New events detected (their timestamp changed = a new day's candle)
newTarget  = not na(tTime) and (na(tTime[1]) or tTime != tTime[1])
newDayOpen = not na(dTime) and (na(dTime[1]) or dTime != dTime[1])

// How far drawings project to the right
rightX = extendRight ? bar_index + extendBars : bar_index
// Where labels sit: offset further right, with a leader line bridging the gap
labelX = rightX + labelOffset

// ---------------------------------------------------------------------------
//  HTF HIGHS & LOWS  (previous candle high/low per timeframe, solid lines)
// ---------------------------------------------------------------------------
f_hl(show4H, h4,  true,  "4H High",  col4H, htfWidth, rightX, labelX, col4H, color.black)
f_hl(show4H, l4,  false, "4H Low",   col4H, htfWidth, rightX, labelX, col4H, color.black)
f_hl(show1H, h1,  true,  "1H High",  col1H, htfWidth, rightX, labelX, col1H, color.black)
f_hl(show1H, l1,  false, "1H Low",   col1H, htfWidth, rightX, labelX, col1H, color.black)
f_hl(show30, h30, true,  "30m High", col30, htfWidth, rightX, labelX, col30, color.black)
f_hl(show30, l30, false, "30m Low",  col30, htfWidth, rightX, labelX, col30, color.black)
f_hl(show15, h15, true,  "15m High", col15, htfWidth, rightX, labelX, col15, color.black)
f_hl(show15, l15, false, "15m Low",  col15, htfWidth, rightX, labelX, col15, color.black)

// Previous day / week / month — labels styled like the full-candle day labels
f_hl(showD, pdh, true,  "PDH",        colD, dwmWidth, rightX, labelX, labelCol, color.white)
f_hl(showD, pdl, false, "PDL",        colD, dwmWidth, rightX, labelX, labelCol, color.white)
f_hl(showW, pwh, true,  "PWH",        colW, dwmWidth, rightX, labelX, labelCol, color.white)
f_hl(showW, pwl, false, "PWL",        colW, dwmWidth, rightX, labelX, labelCol, color.white)
f_hl(showM, pmh, true,  "PMH",        colM, dwmWidth, rightX, labelX, labelCol, color.white)
f_hl(showM, pml, false, "PML",        colM, dwmWidth, rightX, labelX, labelCol, color.white)

// ---------------------------------------------------------------------------
//  TRUE DAY OPEN (midnight ET)
// ---------------------------------------------------------------------------
var line  lnDayOpen  = na
var line  leadDayOpen = na
var label lblDayOpen = na
var array<line>  allDayOpen      = array.new<line>()
var array<line>  allDayOpenLead  = array.new<line>()
var array<label> allDayOpenLabel = array.new<label>()

if newDayOpen
    if not extendPrev
        if not na(lnDayOpen)
            line.set_x2(lnDayOpen, bar_index)
        if not na(leadDayOpen)
            line.set_x1(leadDayOpen, bar_index)
            line.set_x2(leadDayOpen, bar_index + labelOffset)
        if not na(lblDayOpen)
            label.set_x(lblDayOpen, bar_index + labelOffset)
    lnDayOpen := showDayOpen ? line.new(bar_index, dOpen, bar_index, dOpen,
                   color = dayOpenCol, width = 1, style = line.style_dotted) : na
    leadDayOpen := showDayOpen ? line.new(bar_index, dOpen, bar_index, dOpen,
                   color = dayOpenCol, width = 1, style = line.style_dotted) : na
    lblDayOpen := showDayOpen ? label.new(bar_index, dOpen,
                   "True Day Open " + str.format_time(dTime, "EEE", tz),
                   style = label.style_label_left, color = dayOpenCol,
                   textcolor = color.white, size = size.small) : na
    if not na(lnDayOpen)
        array.push(allDayOpen, lnDayOpen)
    if not na(leadDayOpen)
        array.push(allDayOpenLead, leadDayOpen)
    if not na(lblDayOpen)
        array.push(allDayOpenLabel, lblDayOpen)
    if daysKeepTDO > 0
        while array.size(allDayOpen) > daysKeepTDO
            line.delete(array.shift(allDayOpen))
        while array.size(allDayOpenLead) > daysKeepTDO
            line.delete(array.shift(allDayOpenLead))
        while array.size(allDayOpenLabel) > daysKeepTDO
            label.delete(array.shift(allDayOpenLabel))

// ---------------------------------------------------------------------------
//  10 AM LEVELS
// ---------------------------------------------------------------------------
var line  lnOpen  = na
var line  lnClose = na
var line  lnMid   = na
var line  lnMidR  = na
var box   bxBody  = na
var box   bxRange = na
var label lblDay  = na
var line  leadDay = na
var array<line>  allLines  = array.new<line>()
var array<box>   allBoxes  = array.new<box>()
var array<box>   allRange  = array.new<box>()
var array<label> allLabels = array.new<label>()
var array<line>  allLabelLead = array.new<line>()

if newTarget
    // Freeze the previous candle's drawings at this boundary unless extending.
    if not extendPrev
        if not na(bxBody)
            box.set_right(bxBody, bar_index)
        if not na(bxRange)
            box.set_right(bxRange, bar_index)
        if not na(lnOpen)
            line.set_x2(lnOpen, bar_index)
        if not na(lnClose)
            line.set_x2(lnClose, bar_index)
        if not na(lnMid)
            line.set_x2(lnMid, bar_index)
        if not na(lnMidR)
            line.set_x2(lnMidR, bar_index)
        if not na(leadDay)
            line.set_x1(leadDay, bar_index)
            line.set_x2(leadDay, bar_index + labelOffset)
        if not na(lblDay)
            label.set_x(lblDay, bar_index + labelOffset)

    mid     = (tOpen + tClose) / 2.0
    midR    = (tHigh + tLow) / 2.0
    bodyTop = math.max(tOpen, tClose)
    bodyBot = math.min(tOpen, tClose)

    lnOpen  := showOpen  ? line.new(bar_index, tOpen,  bar_index, tOpen,
                 color = openCol,  width = lineWidth) : na
    lnClose := showClose ? line.new(bar_index, tClose, bar_index, tClose,
                 color = closeCol, width = lineWidth) : na
    lnMid   := showMid   ? line.new(bar_index, mid,    bar_index, mid,
                 color = midCol,   width = 1, style = line.style_dotted) : na
    bxBody  := showFill  ? box.new(bar_index, bodyTop, bar_index, bodyBot,
                 border_width = 0, bgcolor = fillCol) : na
    // The box that was "current" now becomes historical — revert its colors.
    if not na(bxRange)
        box.set_border_color(bxRange, rangeBorder)
        box.set_bgcolor(bxRange, rangeFill)
    bxRange := showRange ? box.new(bar_index, tHigh, bar_index, tLow,
                 border_color = curRangeBorder, border_width = 1, bgcolor = curRangeFill) : na
    lnMidR  := showMidR  ? line.new(bar_index, midR,   bar_index, midR,
                 color = midRCol,  width = 1, style = line.style_dotted) : na
    // Day label: centered vertically on the box CE (full candle equilibrium),
    // anchored to the right edge and pointing left so the text sits in the whitespace.
    lblDay  := showLabel ? label.new(bar_index, midR,
                 str.format_time(tTime, "EEE MMM dd", tz),
                 style = label.style_label_left, color = labelCol,
                 textcolor = color.white, size = size.small) : na
    leadDay := showLabel ? line.new(bar_index, midR, bar_index, midR,
                 color = labelCol, width = 1, style = line.style_dotted) : na

    if not na(lnOpen)
        array.push(allLines, lnOpen)
    if not na(lnClose)
        array.push(allLines, lnClose)
    if not na(lnMid)
        array.push(allLines, lnMid)
    if not na(lnMidR)
        array.push(allLines, lnMidR)
    if not na(bxBody)
        array.push(allBoxes, bxBody)
    if not na(bxRange)
        array.push(allRange, bxRange)
    if not na(lblDay)
        array.push(allLabels, lblDay)
    if not na(leadDay)
        array.push(allLabelLead, leadDay)

    // Trim history to the requested number of days
    if daysKeep > 0
        perDay   = (showOpen ? 1 : 0) + (showClose ? 1 : 0) + (showMid ? 1 : 0) + (showMidR ? 1 : 0)
        maxLines = daysKeep * math.max(perDay, 1)
        while array.size(allLines) > maxLines
            line.delete(array.shift(allLines))
        while array.size(allBoxes) > daysKeep
            box.delete(array.shift(allBoxes))
        while array.size(allRange) > daysKeep
            box.delete(array.shift(allRange))
        while array.size(allLabels) > daysKeep
            label.delete(array.shift(allLabels))
        while array.size(allLabelLead) > daysKeep
            line.delete(array.shift(allLabelLead))

// ---------------------------------------------------------------------------
//  EXTEND DRAWINGS RIGHTWARD
// ---------------------------------------------------------------------------
// Drag every past day's drawings forward the FULL extend distance, so they
// all project past price into the future whitespace. Labels ride the right edge.
if extendPrev
    for ln in allLines
        line.set_x2(ln, rightX)
    for bx in allBoxes
        box.set_right(bx, rightX)
    for bx in allRange
        box.set_right(bx, rightX)
    for ln in allDayOpen
        line.set_x2(ln, rightX)
    for ln in allDayOpenLead
        line.set_x1(ln, rightX)
        line.set_x2(ln, labelX)
    for lb in allDayOpenLabel
        label.set_x(lb, labelX)
    for ln in allLabelLead
        line.set_x1(ln, rightX)
        line.set_x2(ln, labelX)
    for lb in allLabels
        label.set_x(lb, labelX)

// Current candle's drawings take priority and project into the future
if not na(lnOpen)
    line.set_x2(lnOpen, rightX)
if not na(lnClose)
    line.set_x2(lnClose, rightX)
if not na(lnMid)
    line.set_x2(lnMid, rightX)
if not na(lnMidR)
    line.set_x2(lnMidR, rightX)
if not na(bxBody)
    box.set_right(bxBody, rightX)
if not na(bxRange)
    box.set_right(bxRange, rightX)
if not na(lnDayOpen)
    line.set_x2(lnDayOpen, rightX)
if not na(leadDayOpen)
    line.set_x1(leadDayOpen, rightX)
    line.set_x2(leadDayOpen, labelX)
if not na(lblDayOpen)
    label.set_x(lblDayOpen, labelX)
if not na(leadDay)
    line.set_x1(leadDay, rightX)
    line.set_x2(leadDay, labelX)
if not na(lblDay)
    label.set_x(lblDay, labelX)
````

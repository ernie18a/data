<!-- tradingview-pine-id: PUB;d5608f5e3f634604954f4b4c0476c919 -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD Initial Balance + Extensions

Source: https://www.tradingview.com/script/EcopvGT3-XAUUSD-Initial-Balance-Extensions/

## Description

IB level from  1 hour of daily open gold will bounce from ib and mnidpoint

---

## Source Code

````pine
//@version=6
indicator("XAUUSD Initial Balance + Extensions", shorttitle="IB + Ext", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
//  INPUTS
// ============================================================
grpIB = "Initial Balance"
ibSession = input.session("0800-0900", "IB Session (1-Hour Window)", group=grpIB, tooltip="First hour of the day, in the timezone set below. Default 08:00-09:00 approximates the XAUUSD/broker daily candle open (17:00 New York) converted to UTC+10.")
ibTZ      = input.string("UTC+10", "Session Timezone (UTC offset)", group=grpIB, tooltip="Use a UTC offset like UTC+10, UTC-5, UTC+0530, etc. Set this to your own timezone and the IB Session field above to your local clock time.\n\nNote: most brokers roll the XAUUSD daily candle at 17:00 New York time, which is 22:00 UTC (winter, EST) or 21:00 UTC (summer, EDT) — i.e. 08:00 or 07:00 next day in UTC+10, shifting 1hr with US daylight saving. Check your broker's actual daily open and adjust the session/timezone above to match.")
histDays  = input.int(100, "Historical IB Days to Keep", minval=0, maxval=150, group=grpIB, tooltip="How many past days to keep on the chart, each with its full IB + extension ladder frozen in place. Actual number shown may be auto-reduced below this to respect TradingView's hard 500-object-per-type limit — more Extension Levels or Midlines means fewer days fit. Check the on-chart status label (top-right) to see what's actually being displayed.")

grpExt = "Extensions"
extLevels = input.int(4, "Number of Extension Levels (1-8)", minval=1, maxval=8, group=grpExt, tooltip="How many IB-range multiples to project above and below the IB, both for today and for historical days. More levels = fewer historical days fit under the 500-object cap.")
showMid   = input.bool(true, "Show Midline of Each Extension Band", group=grpExt)

grpStyle = "Style"
colIB      = input.color(color.new(color.yellow, 0),  "IB High / Low",              group=grpStyle)
colIBMid   = input.color(color.new(#ffffff, 30),       "IB Midline",                 group=grpStyle)
colExtNear = input.color(color.new(color.aqua, 0),     "Extension Color — Level 1",  group=grpStyle)
colExtFar  = input.color(color.new(color.red, 0),      "Extension Color — Outer Level", group=grpStyle)
colMid     = input.color(color.new(color.gray, 35),    "Extension Midlines",         group=grpStyle)
lineW      = input.int(1, "Line Width", minval=1, maxval=4, group=grpStyle)
midStyleIn = input.string("dashed", "Midline Style", options=["dashed", "dotted", "solid"], group=grpStyle)
shadeIB    = input.bool(true, "Shade IB Range Box (Today Only)", group=grpStyle)
showLbl    = input.bool(true, "Show Price Labels", group=grpStyle)
lblSize    = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large], group=grpStyle)
showInfo   = input.bool(true, "Show Status Panel (Top Right)", group=grpStyle)

midLS = midStyleIn == "dashed" ? line.style_dashed : midStyleIn == "dotted" ? line.style_dotted : line.style_solid

// ============================================================
//  BUDGET CHECK — TradingView hard-caps lines/labels at 500 each,
//  so we auto-shrink the effective history depth to whatever
//  actually fits given the chosen extension levels / midlines.
// ============================================================
linesPerDay     = 3 + extLevels * 2 + (showMid ? extLevels * 2 : 0)
labelsPerDay    = showLbl ? (2 + extLevels * 2) : 0
maxDaysByLines  = linesPerDay  > 0 ? int(480 / linesPerDay)  : histDays
maxDaysByLabels = labelsPerDay > 0 ? int(480 / labelsPerDay) : histDays
histDaysEff     = math.max(0, math.min(histDays, math.min(maxDaysByLines, maxDaysByLabels)))

// ============================================================
//  SESSION DETECTION
// ============================================================
tSess     = time(timeframe.period, ibSession, ibTZ)
inSess    = not na(tSess)
sessStart = inSess and not inSess[1]
sessEnd   = inSess[1] and not inSess

var float ibHigh  = na
var float ibLow   = na
var int   anchorX = na

// ============================================================
//  OBJECT STORAGE
//  - lnHigh/lnLow/lnMid/bxIB : live refs for the day currently forming
//  - allLines/allLabels      : flat FIFO queues of every line/label
//    created, oldest first, so trimming just pops from the front
//  - dayLineCounts/dayLabelCounts : how many lines/labels each
//    completed day contributed, so we know how many to pop per day
//  - dayStartLineIdx/dayStartLabelIdx : array size snapshot taken
//    right when today's objects started, used to work out today's
//    count without mutating a counter inside a function
// ============================================================
var line lnHigh = na
var line lnLow  = na
var line lnMid  = na
var box  bxIB   = na
var label lbHigh = na
var label lbLow  = na

var line[]  allLines        = array.new_line()
var label[] allLabels       = array.new_label()
var int[]   dayLineCounts   = array.new_int()
var int[]   dayLabelCounts  = array.new_int()
var int     dayStartLineIdx  = 0
var int     dayStartLabelIdx = 0

// ============================================================
//  NEW IB SESSION STARTS
//  1) freeze + archive yesterday's full ladder (still on chart)
//  2) trim history down to what the object budget allows
//  3) start today's fresh IB
// ============================================================
if sessStart
    if not na(lnHigh)
        // freeze every line yesterday created so it stops at today's open
        n  = array.size(allLines) - dayStartLineIdx
        sz = array.size(allLines)
        if n > 0
            for i = sz - n to sz - 1
                ln = array.get(allLines, i)
                line.set_extend(ln, extend.none)
                line.set_x2(ln, bar_index)
        m = array.size(allLabels) - dayStartLabelIdx
        array.push(dayLineCounts, n)
        array.push(dayLabelCounts, m)

    while array.size(dayLineCounts) > histDaysEff
        n2 = array.shift(dayLineCounts)
        if n2 > 0
            for i = 1 to n2
                line.delete(array.shift(allLines))
    while array.size(dayLabelCounts) > histDaysEff
        m2 = array.shift(dayLabelCounts)
        if m2 > 0
            for i = 1 to m2
                label.delete(array.shift(allLabels))

    if not na(bxIB)
        box.delete(bxIB)

    dayStartLineIdx  := array.size(allLines)
    dayStartLabelIdx := array.size(allLabels)

    ibHigh  := high
    ibLow   := low
    anchorX := bar_index

    lnHigh := line.new(anchorX, ibHigh, anchorX + 1, ibHigh, xloc.bar_index, extend.right, colIB, line.style_solid, lineW)
    lnLow  := line.new(anchorX, ibLow,  anchorX + 1, ibLow,  xloc.bar_index, extend.right, colIB, line.style_solid, lineW)
    lnMid  := line.new(anchorX, (ibHigh + ibLow) / 2, anchorX + 1, (ibHigh + ibLow) / 2, xloc.bar_index, extend.right, colIBMid, line.style_dashed, 1)
    array.push(allLines, lnHigh)
    array.push(allLines, lnLow)
    array.push(allLines, lnMid)

    if shadeIB
        bxIB := box.new(anchorX, ibHigh, bar_index, ibLow, border_color=color.new(colIB, 60), border_width=1, bgcolor=color.new(colIB, 90), xloc=xloc.bar_index)

    if showLbl
        lh = label.new(anchorX, ibHigh, "IB High  " + str.tostring(ibHigh, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_right, colIB, lblSize)
        ll = label.new(anchorX, ibLow,  "IB Low   " + str.tostring(ibLow,  format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_right, colIB, lblSize)
        array.push(allLabels, lh)
        array.push(allLabels, ll)
        lbHigh := lh
        lbLow  := ll

// ============================================================
//  WHILE INSIDE THE IB WINDOW -> keep expanding the range live
// ============================================================
if inSess
    ibHigh := math.max(ibHigh, high)
    ibLow  := math.min(ibLow, low)
    ibm    = (ibHigh + ibLow) / 2

    if not na(lnHigh)
        line.set_y1(lnHigh, ibHigh)
        line.set_y2(lnHigh, ibHigh)
    if not na(lnLow)
        line.set_y1(lnLow, ibLow)
        line.set_y2(lnLow, ibLow)
    if not na(lnMid)
        line.set_y1(lnMid, ibm)
        line.set_y2(lnMid, ibm)
    if shadeIB and not na(bxIB)
        box.set_top(bxIB, ibHigh)
        box.set_bottom(bxIB, ibLow)
    if showLbl
        if not na(lbHigh)
            label.set_y(lbHigh, ibHigh)
            label.set_text(lbHigh, "IB High  " + str.tostring(ibHigh, format.mintick))
        if not na(lbLow)
            label.set_y(lbLow, ibLow)
            label.set_text(lbLow, "IB Low   " + str.tostring(ibLow, format.mintick))

// ============================================================
//  IB WINDOW JUST CLOSED -> range is final, draw up to 8 extensions
// ============================================================
if sessEnd
    ibRange = ibHigh - ibLow

    for lvl = 1 to extLevels
        extT = ibHigh + ibRange * lvl
        extB = ibLow  - ibRange * lvl
        midT = ibHigh + ibRange * (lvl - 0.5)
        midB = ibLow  - ibRange * (lvl - 0.5)
        lvlColor = color.from_gradient(lvl, 1, extLevels, colExtNear, colExtFar)

        lnT = line.new(anchorX, extT, anchorX + 1, extT, xloc.bar_index, extend.right, lvlColor, line.style_solid, lineW)
        lnB = line.new(anchorX, extB, anchorX + 1, extB, xloc.bar_index, extend.right, lvlColor, line.style_solid, lineW)
        array.push(allLines, lnT)
        array.push(allLines, lnB)

        if showMid
            lnMT = line.new(anchorX, midT, anchorX + 1, midT, xloc.bar_index, extend.right, colMid, midLS, 1)
            lnMB = line.new(anchorX, midB, anchorX + 1, midB, xloc.bar_index, extend.right, colMid, midLS, 1)
            array.push(allLines, lnMT)
            array.push(allLines, lnMB)

        if showLbl
            lT = label.new(anchorX, extT, "IB +" + str.tostring(lvl) + "  " + str.tostring(extT, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_right, lvlColor, lblSize)
            lB = label.new(anchorX, extB, "IB -" + str.tostring(lvl) + "  " + str.tostring(extB, format.mintick), xloc.bar_index, yloc.price, color(na), label.style_label_right, lvlColor, lblSize)
            array.push(allLabels, lT)
            array.push(allLabels, lB)

// ============================================================
//  KEEP THE SHADED IB BOX'S RIGHT EDGE PINNED TO THE LIVE BAR
// ============================================================
if shadeIB and not na(bxIB)
    box.set_right(bxIB, bar_index)

// ============================================================
//  STATUS PANEL — shows what's actually being rendered, since
//  the object cap can silently reduce the requested history
// ============================================================
var table infoTbl = table.new(position.top_right, 1, 1)
if showInfo and barstate.islast
    daysShown = array.size(dayLineCounts)
    txt = "IB Extensions: " + str.tostring(extLevels) + " level" + (extLevels > 1 ? "s" : "") + "\nHistory shown: " + str.tostring(daysShown) + " / " + str.tostring(histDays) + " days requested"
    table.cell(infoTbl, 0, 0, txt, text_color=color.white, bgcolor=color.new(color.black, 15), text_size=size.small)
````

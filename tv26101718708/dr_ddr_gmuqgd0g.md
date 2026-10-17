# DR DDR

- url: https://www.tradingview.com/script/GMuqgD0g-DR-DDR/
- type: indicator
- pine_id: PUB;787ff4985fbd4cc6824fbb51f10574be
- version: 1.0

## Description

DDR is the daily defining range so that we can view not only seasions but also day structure.

## Source Code

````pine
//@version=6
indicator("DR DDR", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
var GRP_T = "⏱ Session Window (NY Time)"
sessStartHour = input.int(9,  "Start Hour",   minval = 0, maxval = 23, group = GRP_T, inline = "st")
sessStartMin  = input.int(30, "Start Minute", minval = 0, maxval = 59, group = GRP_T, inline = "st")
sessEndHour   = input.int(16, "End Hour",     minval = 0, maxval = 23, group = GRP_T, inline = "en")
sessEndMin    = input.int(0,  "End Minute",   minval = 0, maxval = 59, group = GRP_T, inline = "en")

var GRP_E = "⏱ Extend Lines Until (NY Time)"
extendHour = input.int(9,  "Extend Until Hour",   minval = 0, maxval = 23, group = GRP_E, inline = "ex")
extendMin  = input.int(25, "Extend Until Minute",  minval = 0, maxval = 59, group = GRP_E, inline = "ex")

var GRP_H = "📜 History"
maxRanges = input.int(20, "Number of Ranges to Keep on Chart", minval = 1, maxval = 100, group = GRP_H)

var GRP_S = "🎛 Display Toggles"
showBoxFill = input.bool(true, "Show Box Fill (no border)", group = GRP_S)
showHigh    = input.bool(true, "Show High Line",  group = GRP_S)
showMid     = input.bool(true, "Show Mid Line",   group = GRP_S)
showLow     = input.bool(true, "Show Low Line",   group = GRP_S)

var GRP_C = "🎨 Style"
boxBg        = input.color(color.new(#5b9cf6, 95), "Box Fill Color", group = GRP_C)
hiLoColor    = input.color(color.new(#5b9cf6, 0),  "High/Low Line Color", group = GRP_C)
hiLoWidth    = input.int(1, "High/Low Line Width", minval = 1, maxval = 4, group = GRP_C)
midColor     = input.color(color.new(#ffe500, 0),  "Mid Line Color",  group = GRP_C)
midWidth     = input.int(2, "Mid Line Width", minval = 1, maxval = 4, group = GRP_C)

// ─────────────────────────────────────────────
//  TIME UTILITY  (NY time, overnight-safe)
// ─────────────────────────────────────────────
tz = "America/New_York"

barM() =>
    hour(time, tz) * 60 + minute(time, tz)

prevBarM() =>
    hour(time[1], tz) * 60 + minute(time[1], tz)

inRange(startM, endM) =>
    bm = barM()
    startM > endM ? (bm >= startM or bm < endM) : (bm >= startM and bm < endM)

isFirst(startM, endM) =>
    inRange(startM, endM) and not (startM > endM
         ? (prevBarM() >= startM or  prevBarM() < endM)
         : (prevBarM() >= startM and prevBarM() < endM))

sessSM = sessStartHour * 60 + sessStartMin
sessEM = sessEndHour   * 60 + sessEndMin
extendM = extendHour * 60 + extendMin
isExtendCutoff = barM() >= extendM and prevBarM() < extendM

// ─────────────────────────────────────────────
//  CURRENT (LIVE / GROWING) RANGE STATE
// ─────────────────────────────────────────────
var box   curBox   = na
var line  curHi     = na
var line  curLo     = na
var line  curMid    = na
var float rngHi     = na
var float rngLo     = na
var bool  isLocked  = false

// ─────────────────────────────────────────────
//  HISTORY ARRAYS  (oldest at index 0, newest pushed to end)
// ─────────────────────────────────────────────
var array<box>  histBoxes = array.new<box>()
var array<line> histHi    = array.new<line>()
var array<line> histLo    = array.new<line>()
var array<line> histMid   = array.new<line>()

trimHistory() =>
    while array.size(histBoxes) > maxRanges
        b = array.shift(histBoxes)
        box.delete(b)
    while array.size(histHi) > maxRanges
        l = array.shift(histHi)
        line.delete(l)
    while array.size(histLo) > maxRanges
        l = array.shift(histLo)
        line.delete(l)
    while array.size(histMid) > maxRanges
        l = array.shift(histMid)
        line.delete(l)

// At the moment a new session starts: archive the previous (now-finished) range,
// then begin a brand-new live range.
if isFirst(sessSM, sessEM)
    // archive whatever was the previous live/locked range into history
    if not na(curBox)
        array.push(histBoxes, curBox)
    if not na(curHi)
        array.push(histHi, curHi)
    if not na(curLo)
        array.push(histLo, curLo)
    if not na(curMid)
        array.push(histMid, curMid)
    trimHistory()

    // start fresh
    rngHi    := high
    rngLo    := low
    isLocked := false

    if showBoxFill
        curBox := box.new(bar_index, rngHi, bar_index, rngLo,
                          bgcolor      = boxBg,
                          border_color = color.new(#000000, 100),
                          extend       = extend.none)
    else
        curBox := na

    if showHigh
        curHi := line.new(bar_index, rngHi, bar_index, rngHi, color = hiLoColor, width = hiLoWidth, extend = extend.none)
    else
        curHi := na
    if showLow
        curLo := line.new(bar_index, rngLo, bar_index, rngLo, color = hiLoColor, width = hiLoWidth, extend = extend.none)
    else
        curLo := na
    if showMid
        curMid := line.new(bar_index, math.avg(rngHi, rngLo), bar_index, math.avg(rngHi, rngLo), color = midColor, width = midWidth, extend = extend.none)
    else
        curMid := na

// while inside the session window → grow the range with price
if inRange(sessSM, sessEM) and not isLocked
    rngHi := math.max(rngHi, high)
    rngLo := math.min(rngLo, low)

    if not na(curBox)
        box.set_top(curBox, rngHi)
        box.set_bottom(curBox, rngLo)
        box.set_right(curBox, bar_index)

    if not na(curHi)
        line.set_xy1(curHi, line.get_x1(curHi), rngHi)
        line.set_xy2(curHi, bar_index, rngHi)
    if not na(curLo)
        line.set_xy1(curLo, line.get_x1(curLo), rngLo)
        line.set_xy2(curLo, bar_index, rngLo)
    if not na(curMid)
        midVal = math.avg(rngHi, rngLo)
        line.set_xy1(curMid, line.get_x1(curMid), midVal)
        line.set_xy2(curMid, bar_index, midVal)

// once the session window ends → lock high/low/mid, extend bar-by-bar (NOT infinitely) up to the cutoff
if not inRange(sessSM, sessEM)
    isLocked := true

if isLocked and not isFirst(sessSM, sessEM)
    if not na(curBox)
        box.set_right(curBox, bar_index)
    if not na(curHi)
        line.set_x2(curHi, bar_index)
    if not na(curLo)
        line.set_x2(curLo, bar_index)
    if not na(curMid)
        line.set_x2(curMid, bar_index)
````

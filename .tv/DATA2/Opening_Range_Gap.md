<!-- tradingview-pine-id: PUB;28b5d5a0ea3d40d3a0bcee8418867c89 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Opening Range Gap

Source: https://www.tradingview.com/script/V0xd04jB-Opening-Range-Gap-ORG-TH-Trader/

## Description

Opening Range Gap (ORG) Zones

This indicator maps the overnight gap between the prior session's settlement (16:14 NY close) and the regular session open (09:30 NY), then divides that range into Fibonacci-style levels so you can track how price interacts with the gap throughout the day.

How it works:

Anchors are captured via a minute-by-minute walk over 1-minute data on the chart's own symbol, so both the 16:14 settlement price and the 09:30 open are always caught precisely — regardless of your chart's timeframe or Extended Hours setting
The gap range is divided into customizable levels (0/Open, 12.5%, 25%, 37.5%, 50%/CE, 62.5%, 75%, 87.5%, 100%/Close), each individually toggleable with its own color
The midpoint (CE) is highlighted separately as it often acts as a key reference for gap-fill trades
A background box shades the full gap zone, and a label shows the gap size in both points and percentage
Tracks whether each ORG has been "filled" (price has traded back to the settlement price) — fill detection uses your chart's own bars, so toggling Extended Hours changes what counts as filled

Extension styles:

Cap at day end — zone freezes at the end of each session
Cap at time of day — zone freezes at a custom cutoff time
Extend all lines right — zones extend indefinitely
Extend unfilled ORGs — filled zones are removed from the chart, keeping only unfilled gaps visible (with an option to keep the most recent ORG visible even after it fills)

How to use it:

Use the gap size label to gauge overnight volatility relative to recent history
Watch how price reacts at each Fibonacci level within the gap, especially the 50% (CE) level, for potential support/resistance or gap-fill setups
Combine with the CME Overnight Range and Anchored VWAP for additional overnight-positioning context
Works on any intraday timeframe; disabled on Daily/Weekly/Monthly charts since the concept requires intraday anchors

---

## Source Code

````pine
//@version=6
indicator("Opening Range Gap", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// Opening Range Gap (ORG) zone map.
// Anchor: previous RTH settlement close (16:14 NY) -> current RTH open (09:30 NY).
// Both anchors are captured via a minute-walk over raw 1-minute data on the
// chart's own symbol (request.security_lower_tf), using a single overnight
// session string "1614-0930" that wraps past midnight. This always includes
// every traded minute (extended hours included) regardless of what the chart
// itself is displaying, so no dedicated RTH-only ticker is needed. See the
// ANCHOR DETECTION section below for the full mechanism.
// Fill detection reads the chart's own bars, so toggling the chart's Extended
// Hours display changes what counts as filled.

// ---------------------------- INPUTS ----------------------------------------
grpPeriods = "History"
maxPeriods = input.int(20, "Sessions to Keep", minval = 1, maxval = 100, group = grpPeriods,
     tooltip = "One ORG per session/day; sets how many past sessions stay on the chart.")

grpExt = "Extension"
extMode = input.string("Cap at day end", "Style",
     options = ["Cap at day end", "Cap at time of day", "Extend all lines right", "Extend unfilled ORGs"], group = grpExt)
cutoffHour   = input.int(16, "Cutoff Hour", minval = 0, maxval = 23, group = grpExt, inline = "co", tooltip = "Used only when Style = 'Cap at time of day'.")
cutoffMinute = input.int(15, "Min",         minval = 0, maxval = 59, group = grpExt, inline = "co")
alwaysShowCurrentORG = input.bool(true, "Show Current ORG After Fill", group = grpExt,
     tooltip = "Only applies when Style = 'Extend unfilled ORGs'. Keeps the most recent ORG visible even after it fills.")

grpLevels = "Levels"
showOpen  = input.bool(true, "0 (Open)",  group = grpLevels)
showClose = input.bool(true, "1 (Close)", group = grpLevels)
show125 = input.bool(true,  "", group = grpLevels, inline = "L1")
val125  = input.float(0.125, "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L1")
show25  = input.bool(true,  "", group = grpLevels, inline = "L2")
val25   = input.float(0.25,  "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L2")
show375 = input.bool(true,  "", group = grpLevels, inline = "L3")
val375  = input.float(0.375, "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L3")
show50  = input.bool(true,  "CE", group = grpLevels, inline = "L4")
val50   = input.float(0.5,   "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L4")
show625 = input.bool(true,  "", group = grpLevels, inline = "L5")
val625  = input.float(0.625, "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L5")
show75  = input.bool(true,  "", group = grpLevels, inline = "L6")
val75   = input.float(0.75,  "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L6")
show875 = input.bool(true,  "", group = grpLevels, inline = "L7")
val875  = input.float(0.875, "", minval = -5, maxval = 5, step = 0.001, group = grpLevels, inline = "L7")

grpBg = "Background"
showBg  = input.bool(true, "Show Background", group = grpBg)
bgColor = input.color(color.new(color.blue, 90), "Color", group = grpBg)

grpRangeLbl = "Range Label"
showRangeTable = input.bool(true, "Show Range Label", group = grpRangeLbl)

grpStyle = "Appearance"
curColorOpen   = input.color(color.new(color.blue, 0),    "Open",         group = grpStyle, inline = "open")
histColorOpen  = input.color(color.new(color.blue, 60),   "Historical",   group = grpStyle, inline = "open")
curColorClose  = input.color(color.new(color.gray, 0),    "Close",        group = grpStyle, inline = "close")
histColorClose = input.color(color.new(color.gray, 60),   "Historical",   group = grpStyle, inline = "close")
curColorCE     = input.color(color.new(color.orange, 0),  "CE (0.5)",     group = grpStyle, inline = "ce")
histColorCE    = input.color(color.new(color.orange, 60), "Historical",   group = grpStyle, inline = "ce")
curColorQ      = input.color(color.new(color.silver, 0),  "Other Levels", group = grpStyle, inline = "q")
histColorQ     = input.color(color.new(color.silver, 65), "Historical",   group = grpStyle, inline = "q")
lineWidthCur   = input.int(2, "Current Width",    minval = 1, maxval = 4, group = grpStyle)
lineWidthHist  = input.int(1, "Historical Width", minval = 1, maxval = 4, group = grpStyle)
ceWidthCur     = input.int(2, "CE Width",         minval = 1, maxval = 4, group = grpStyle)

extIsCapDayEnd = extMode == "Cap at day end"
extIsCapTime   = extMode == "Cap at time of day"
extIsAll       = extMode == "Extend all lines right"
extIsUnfLvl    = extMode == "Extend unfilled ORGs"
isCapMode      = extIsCapDayEnd or extIsCapTime

sessTZ = "America/New_York"   // used only for the "Cap at time of day" cutoff clock

// ---------------------------- PER-ORG DATA TYPE -----------------------------
type OrgData
    array<line>  lns
    array<float> pxs
    array<color> histCol
    float pxOpen
    float pxClose
    float rng
    bool  premium
    bool  filled  = false
    bool  deleted = false   // marks an ORG whose drawings were already deleted
    box   bgBox
    label rangeLbl

var array<OrgData> orgs = array.new<OrgData>()

// Every ORG that remains in `orgs` stays fully visible (lines, box, label)
// regardless of fill status. "Extend unfilled ORGs" mode is the only style
// that ever removes a filled ORG from this array (see the fill-tracking
// section below) — everything else keeps ORGs visible until they're evicted
// by the "Sessions to Keep" limit.

isDWM = timeframe.isdwm

// ---------------------------- ANCHOR DETECTION -------------------------------
// Minute-walk technique: define a single overnight session string that spans
// 16:14 (RTH close/settlement) through 09:30 (RTH open) — wrapping past
// midnight, active every weekday. Then pull raw 1-minute data on the chart's
// OWN symbol (syminfo.tickerid) via request.security_lower_tf, which always
// includes every traded minute (extended hours included) regardless of what
// the chart itself is displaying — no dedicated RTH-only ticker needed.
//
// Walking that 1-minute data minute-by-minute:
//   - the minute where the session STARTS (16:14) -> its CLOSE price is the
//     settlement/close anchor (the settlement print happens at the END of
//     that minute, i.e. ~16:15:00, not its open).
//   - the minute where the session ENDS (09:30) -> its OPEN price is the RTH
//     open anchor (the RTH open print happens at the START of that minute),
//     and this is also the moment a new ORG is triggered, since both anchors
//     are now known.
sess = "1614-0930:1234567"

f_isSession() =>
    timeframe.isintraday and not na(time(timeframe.period, sess, "America/New_York"))

[m1_sess, m1_open, m1_close] = request.security_lower_tf(syminfo.tickerid, "1", [f_isSession(), open, close])

var float closeAnchor = na   // captured at 16:14 close -> settlement/close
var bool  inSession    = false
float openAnchor = na        // captured at 09:30 open -> RTH open (valid only on the trigger bar)
newORG = false

if not isDWM
    idx = 0
    while idx < array.size(m1_sess)
        sessNow = array.get(m1_sess, idx)
        if inSession and not sessNow
            // Session just ended this minute (09:30) -> this minute's open is the RTH open.
            openAnchor := array.get(m1_open, idx)
            newORG     := true
            inSession  := false
        if not inSession and sessNow
            // Session just started this minute (16:14) -> this minute's CLOSE is the
            // settlement price (the close print lands at the end of this minute).
            closeAnchor := array.get(m1_close, idx)
            inSession   := true
        idx += 1

ltfOrgOpen  = openAnchor
ltfOrgClose = closeAnchor

var int sessionCount = 0
if newORG
    sessionCount += 1

// ---------------------------- FILL DETECTION ---------------------------------
// Uses the chart's own current bar, so switching the chart's Extended Hours
// display setting directly changes what counts as a "fill".
fillHi = high
fillLo = low

// ---------------------------- CUTOFF STATE -----------------------------------
nyHourNow      = hour(time, sessTZ)
nyMinuteNow    = minute(time, sessTZ)
nowMinOfDay    = nyHourNow * 60 + nyMinuteNow
cutoffMinOfDay = cutoffHour * 60 + cutoffMinute
var bool cutoffReached = false

barDurMs = timeframe.in_seconds(timeframe.period) * 1000

// ---------------------------- BUILD ENABLED LEVEL LIST -----------------------
f_buildLevels() =>
    ratios = array.new<float>()
    if showOpen
        array.push(ratios, 0.0)
    if show125
        array.push(ratios, val125)
    if show25
        array.push(ratios, val25)
    if show375
        array.push(ratios, val375)
    if show50
        array.push(ratios, val50)
    if show625
        array.push(ratios, val625)
    if show75
        array.push(ratios, val75)
    if show875
        array.push(ratios, val875)
    if showClose
        array.push(ratios, 1.0)
    ratios

// ---------------------------- NEW ORG CREATION (skipped on D/W/M) -----------
if newORG and not isDWM
    cutoffReached := false

    // Seal previous "current" ORG into historical styling — unless it's
    // already filled under "Extend unfilled ORGs" mode, in which case it was
    // only being kept alive by "Show Current ORG After Fill" and now gets
    // fully deleted since it's no longer the most recent ORG.
    if array.size(orgs) > 0
        prev = array.get(orgs, array.size(orgs) - 1)
        if extIsUnfLvl and prev.filled
            for i = 0 to array.size(prev.lns) - 1
                line.delete(array.get(prev.lns, i))
            if not na(prev.bgBox)
                box.delete(prev.bgBox)
            if not na(prev.rangeLbl)
                label.delete(prev.rangeLbl)
            prev.deleted := true
        else
            for i = 0 to array.size(prev.lns) - 1
                line.set_color(array.get(prev.lns, i), array.get(prev.histCol, i))
                line.set_width(array.get(prev.lns, i), lineWidthHist)

    if extIsUnfLvl and array.size(orgs) > 0
        cleanedNew = array.new<OrgData>()
        for i = 0 to array.size(orgs) - 1
            oKeep = array.get(orgs, i)
            if not oKeep.deleted
                array.push(cleanedNew, oKeep)
        orgs := cleanedNew

    // evict oldest once at capacity
    if array.size(orgs) >= maxPeriods
        oldest = array.shift(orgs)
        for i = 0 to array.size(oldest.lns) - 1
            line.delete(array.get(oldest.lns, i))
        if not na(oldest.bgBox)
            box.delete(oldest.bgBox)
        if not na(oldest.rangeLbl)
            label.delete(oldest.rangeLbl)

    orgOpenPx  = ltfOrgOpen
    orgClosePx = ltfOrgClose
    lo  = math.min(orgOpenPx, orgClosePx)
    hi  = math.max(orgOpenPx, orgClosePx)
    rng = hi - lo

    initExtend = extIsAll or extIsUnfLvl ? extend.right : extend.none
    t0 = time
    t1 = time + barDurMs   // non-zero starting width avoids a vertical-line render bug

    newObj = OrgData.new()
    newObj.lns     := array.new<line>()
    newObj.pxs     := array.new<float>()
    newObj.histCol := array.new<color>()
    newObj.pxOpen  := orgOpenPx
    newObj.pxClose := orgClosePx
    newObj.rng     := rng
    newObj.premium := orgOpenPx > orgClosePx

    ratios = f_buildLevels()
    for r in ratios
        px   = lo + rng * r
        cCol = curColorQ
        hCol = histColorQ
        w    = lineWidthCur
        if math.abs(r - 0.0) < 0.0001
            cCol := curColorOpen
            hCol := histColorOpen
        else if math.abs(r - 1.0) < 0.0001
            cCol := curColorClose
            hCol := histColorClose
        else if math.abs(r - 0.5) < 0.0001
            cCol := curColorCE
            hCol := histColorCE
            w := ceWidthCur
        ln = line.new(t0, px, t1, px, xloc = xloc.bar_time, extend = initExtend, color = cCol, width = w)
        array.push(newObj.lns, ln)
        array.push(newObj.pxs, px)
        array.push(newObj.histCol, hCol)

    if showBg
        newObj.bgBox := box.new(left = t0, top = hi, right = t1, bottom = lo, xloc = xloc.bar_time,
             extend = initExtend, bgcolor = bgColor, border_color = color(na))

    array.push(orgs, newObj)

else if array.size(orgs) > 0 and not isDWM
    // "Cap at day end" always extends, so it never triggers this freeze.
    // "Cap at time of day" freezes permanently once the cutoff time passes.
    if isCapMode and not cutoffReached
        withinCutoff = extIsCapDayEnd or nowMinOfDay <= cutoffMinOfDay
        if withinCutoff
            last = array.get(orgs, array.size(orgs) - 1)
            for i = 0 to array.size(last.lns) - 1
                line.set_x2(array.get(last.lns, i), time)
            if not na(last.bgBox)
                box.set_right(last.bgBox, time)
        else
            cutoffReached := true

// ---------------------------- WHOLE-ORG FILL TRACKING ------------------------
// "Filled" = price has round-tripped back to the original settlement price
// (the opposite end of the 0->1 range).
//   - "Extend unfilled ORGs" mode: a filled ORG is deleted outright, unless
//     it's the current/most-recent ORG and "Show Current ORG After Fill" is
//     on, in which case it's frozen at the fill bar and stays visible until
//     the next ORG forms.
//   - Every other mode: a filled ORG simply stays visible, frozen at its
//     fill bar, same as any other historical ORG. `o.filled` is still
//     tracked (useful if other logic wants it later) but no longer hides
//     anything.
var bool anyDeletedThisBar = false
anyDeletedThisBar := false
if array.size(orgs) > 0
    lastIdx = array.size(orgs) - 1
    for i = 0 to lastIdx
        o = array.get(orgs, i)
        isCurrent = i == lastIdx
        if not o.filled and o.pxClose <= fillHi and o.pxClose >= fillLo
            o.filled := true

            if extIsUnfLvl
                keepVisible = alwaysShowCurrentORG and isCurrent
                if keepVisible
                    for j = 0 to array.size(o.lns) - 1
                        ln = array.get(o.lns, j)
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, time)
                    if not na(o.bgBox)
                        box.set_extend(o.bgBox, extend.none)
                        box.set_right(o.bgBox, time)
                else
                    for j = 0 to array.size(o.lns) - 1
                        line.delete(array.get(o.lns, j))
                    if not na(o.bgBox)
                        box.delete(o.bgBox)
                    if not na(o.rangeLbl)
                        label.delete(o.rangeLbl)
                    o.deleted := true
                    anyDeletedThisBar := true

    if anyDeletedThisBar
        cleanedFill = array.new<OrgData>()
        for i = 0 to array.size(orgs) - 1
            oKeep2 = array.get(orgs, i)
            if not oKeep2.deleted
                array.push(cleanedFill, oKeep2)
        orgs := cleanedFill

// ---------------------------- PER-ORG RANGE LABEL -----------------------------
// One compact label per ORG, anchored to its own right edge — every ORG
// still on the chart gets one, controlled solely by "Show Range Label".
if showRangeTable and barstate.islast and array.size(orgs) > 0
    for i = 0 to array.size(orgs) - 1
        o = array.get(orgs, i)
        pct = o.rng / o.pxOpen * 100
        int x2max = na
        for j = 0 to array.size(o.lns) - 1
            x2 = line.get_x2(array.get(o.lns, j))
            x2max := na(x2max) ? x2 : math.max(x2max, x2)
        yTop = math.max(o.pxOpen, o.pxClose)
        txt = str.tostring(o.rng, "#.#") + "pts (" + str.tostring(pct, "#.#") + "%)"
        if na(o.rangeLbl)
            o.rangeLbl := label.new(x2max, yTop, txt, xloc = xloc.bar_time,
                 style = label.style_label_left, color = color.new(color.black, 70), textcolor = color.white, size = size.small)
        else
            label.set_xy(o.rangeLbl, x2max, yTop)
            label.set_text(o.rangeLbl, txt)
````

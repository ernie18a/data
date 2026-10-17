# Precision Progressive ORB

- url: https://www.tradingview.com/script/1aTAEHOb-Precision-Progressive-ORB/
- type: indicator
- pine_id: PUB;a884ed86afd14f25addcf3311929a5fd
- version: 1.0

## Description

# Precision Progressive ORB (PORB)

A different approach to the Opening Range Breakout: instead of waiting for the full ORB window to complete before drawing anything, PORB builds the range progressively using smaller sub-boxes that develop live during the auction. You can watch the opening range form in real time rather than staring at empty space until the ORB completes.

> 🖼️ **[Main Image — sub-boxes during build]**

https://www.tradingview.com/x/K8R8sAAs/

> *Above: a 45-minute ORB built progressively from nine 5-minute sub-boxes. Each sub-box shows where price was leaning during its window — red borders for holding low, green for holding high, white for neutral rotation. The dotted line is the live midpoint tracking the running aggregate. The status table on the right tracks state and classification in real time.*

---

## The problem this solves

A standard 15-minute ORB script draws nothing until 15 minutes have passed. On fast-moving small caps, the trade is often half over by the time the box appears. PORB shows you what's happening *inside* those 15 minutes by breaking them into smaller development windows — for example, three 5-minute sub-boxes that build the full ORB. You see the opening auction develop in stages instead of all at once.

---

## Quick setup

Default settings work out of the box for US stocks:

- **Timezone:** Exchange (auto-detects from the symbol)
- **Start time:** 9:30 (matches NYSE/NASDAQ market open via the Exchange timezone)
- **ORB duration:** 15 minutes
- **Sub-box duration:** 5 minutes (three sub-boxes per ORB)

**Important about timezone:** the Hour and Minute inputs are interpreted in the selected Timezone. With the default "Exchange" setting, 9:30 means 9:30 AM in the symbol's home exchange — Eastern Time for NASDAQ/NYSE, Central European Time for DAX, JST for Nikkei, etc. If you want to anchor to a non-native session (trading EUR/USD on the London FX open from a US chart, for example), pick a specific timezone from the dropdown — DST is handled automatically.

If you pick a sub-box duration that doesn't divide the ORB evenly (e.g., 15 / 7), PORB auto-snaps to the nearest valid divisor and shows a one-time notice.

---

## How it works

During the ORB window:

- Sub-boxes draw live, one at a time
- Two display modes: **Rolling** (only the current sub-box visible) or **Show All** (every sub-box stays visible through completion)
- Internally, PORB tracks the aggregate high/low across the entire ORB window — that's the real range being built

When the ORB completes:

- All sub-boxes sweep away (development is done)
- The final aggregate high/low locks in
- A bordered final box anchors the locked structure to its origin time
- High/low lines, midpoint, and optional buffer lines extend right for ongoing reference

> 🖼️ **[IMAGE 2 — locked state after ORB completion]**

https://www.tradingview.com/x/vmN1FzWb/

> *Above: the same auction after the ORB locks. Sub-boxes are gone — the chart transitions from "watching the auction form" to "trading the resulting structure." The locked box, ORB high/low lines, and midpoint extend right as structural reference for the rest of the session.*

---

## Two display modes

**Show All Sub-Boxes** (the hero image at the top) keeps every completed sub-box visible through the ORB window, so you can see the full development sequence as it builds.

**Rolling Sub-Box Only** shows just the current developing sub-box — only one box visible at any time, moving forward as each new window begins. Less visual weight, more focus on the active auction phase.

> 🖼️ **[IMAGE 3 — rolling mode, single sub-box visible]**

https://www.tradingview.com/x/7GWr5wIo/

> *Above: PORB in rolling mode. Only the currently developing sub-box is drawn — prior sub-boxes disappear as new ones begin. Cleaner look for traders who want minimal chart clutter while still watching the auction form live.*

---

## Visual language

Two clean channels, two distinct concepts:

**Sub-box border = position lean**

- Silver — close in the middle third of the developing range
- Green — close in the upper third (holding high)
- Red — close in the lower third (holding low)

**Sub-box fill = movement energy**

Progressive green/red shading reflects the relative strength of each sub-box move. Fills stay light — atmospheric tint, not solid overlay — so candles and other indicators remain clearly readable. The fill thresholds adapt to the symbol's volatility regime so a sleepy Large cap doesn't need the same magnitude as a volatile small cap to show energy.

**Final box** I'm using a cyan border with a faint neutral fill — a structural anchor for the locked range. The color can be changed based on your preferred canvas color.

**Live midpoint** (optional, on by default): a dotted line tracking the running aggregate midpoint during build. Provisional by design — it shifts as the range develops. Replaced by the locked dashed midpoint when the ORB completes.

---

## Classification table

A 4-column status table tracks live state:

| State | Development | ORB High | ORB Low |
|-------|-------------|----------|---------|

The Development column shifts meaning by phase:

- **During build:** range classification — `Forming`, `Inside`, `Expanding`, `Compressing`, or `Stable`. Compares the current sub-box's range to the prior sub-box's range, with a tolerance threshold to avoid flickering on small differences.
- **After lock:** position classification — `Above Range`, `Upper Range`, `Mid Range`, `Lower Range`, or `Below Range`. Tells you where price sits relative to the locked structure, including whether it's broken out above or below.

---

## Buffer lines (optional, off by default)

Toggleable dotted lines just outside the locked ORB high and low. Sized by ticks, ATR multiple, or percent — your choice. These give you a "you actually broke this, not just kissed it" reference for traders who want a visual cushion against wick-pokes and liquidity sweeps.

---

## What this is and isn't

PORB is a structural visualization tool. It does not generate buy/sell signals, fire alerts, or recommend trades. It shows you the opening auction's development in a way that pure-completion ORB scripts can't, and gives you a clean structural reference once the range locks. How you use that information is up to you.

Best suited for:

- Active intraday traders working opening-range setups
- Anyone watching fast-moving instruments where the first 5–15 minutes carry most of the move
- Traders who want to see auction structure form rather than waiting for the result

**Note on viewing:** sub-boxes draw live during the ORB build phase. If you load PORB onto a chart after the ORB has already completed for the day, you'll only see the final locked structure — sub-boxes are part of the live development view, not a historical replay. To see sub-boxes in action, watch the next ORB window form in real time, or set the start time to the upcoming session.

---

Released open source under MPL 2.0.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MohaveTrader

//@version=6
indicator("Precision Progressive ORB", "PORB", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =============================================================================
// INPUTS
// =============================================================================
g_time = "Timing"
i_orbStartHour      = input.int(9,  "ORB Start Hour",    minval=0, maxval=23, group=g_time, tooltip="Hour entered in the selected timezone (24h format). Default 9:30 with Exchange timezone = the symbol's home market open (e.g., 9:30 ET for NASDAQ/NYSE).")
i_orbStartMinute    = input.int(30, "ORB Start Minute",  minval=0, maxval=59, group=g_time)
i_orbDurationMin    = input.int(15, "Total ORB Duration (min)", minval=1, maxval=240, group=g_time)
i_subBoxDurationMin = input.int(5,  "Sub-Box Duration (min)",   minval=1, maxval=60,  group=g_time, tooltip="Must divide ORB duration evenly. If not, auto-snaps to nearest valid divisor.")
i_timezone          = input.string("Exchange", "Timezone", options=["Exchange","America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Phoenix","Europe/London","Europe/Berlin","Europe/Paris","Europe/Zurich","Asia/Tokyo","Asia/Hong_Kong","Asia/Singapore","Asia/Shanghai","Australia/Sydney","UTC"], group=g_time, tooltip="Leave on 'Exchange' to use the symbol's home exchange timezone (auto-handles DST). Pick a specific timezone only when anchoring the ORB to a different session than the symbol's home market — e.g., trading EUR/USD on the London FX open from a US chart.")

g_disp = "Display"
i_showRollingBox  = input.bool(true,  "Show Rolling Sub-Box Only",  group=g_disp)
i_showAllSubBoxes = input.bool(false, "Show All Sub-Boxes",         group=g_disp)
i_showFinalBox    = input.bool(true,  "Show Final ORB Box",         group=g_disp)
i_showFinalLines  = input.bool(true,  "Show Final ORB High/Low",    group=g_disp)
i_showMidpoint    = input.bool(true,  "Show Midpoint",              group=g_disp)
i_showLiveMid     = input.bool(true,  "Show Live Midpoint (during build)", group=g_disp, tooltip="Draws a provisional midpoint line during ORB development, tracking the running aggregate high/low. Disappears when ORB locks (replaced by the final midpoint).")
i_showBuffer      = input.bool(false, "Show Buffer Lines",          group=g_disp)

g_buf = "Buffer"
i_bufferMode  = input.string("ATR", "Buffer Mode", options=["Ticks", "ATR", "Percent"], group=g_buf)
i_bufferTicks = input.int(5,     "Buffer Ticks",   minval=1, maxval=100, group=g_buf)
i_bufferATR   = input.float(0.5, "Buffer ATR Mult", minval=0.05, maxval=2.0, step=0.05, group=g_buf)
i_bufferPct   = input.float(0.25, "Buffer Percent",       minval=0.01, maxval=5.0, step=0.05, group=g_buf)

g_tbl = "Status Table"
i_showTable = input.bool(true, "Show Classification Table", group=g_tbl)
i_tablePos  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left","Bottom Center"], group=g_tbl)
i_tableSize = input.string("Normal", "Table Size", options=["Tiny","Small","Normal","Large"], group=g_tbl)

g_col = "Colors"
i_colNeutral  = input.color(color.new(color.silver, 0),  "Border: Neutral",         group=g_col)
i_colHoldHigh = input.color(color.new(color.lime,   0),  "Border: Holding High",    group=g_col)
i_colHoldLow  = input.color(color.new(color.red,    0),  "Border: Holding Low",     group=g_col)
i_colFinal    = input.color(color.new(color.white,  0),  "Border: Final ORB",       group=g_col)
i_colMid      = input.color(color.new(color.yellow, 0),  "Midpoint Line",           group=g_col)
i_colBuffer   = input.color(color.new(color.gray,  30),  "Buffer Lines",            group=g_col)

// =============================================================================
// ATR REGIME (volatility proxy for fill-shading thresholds)
// =============================================================================
atrPctRaw    = ta.atr(14) / math.max(close, 1e-10) * 100
atrPctSmooth = ta.sma(atrPctRaw, 10)

autoIsSmallMicro = atrPctSmooth > 3.0
autoIsMid        = atrPctSmooth >= 1.0 and atrPctSmooth <= 3.0
autoIsLarge      = atrPctSmooth < 1.0

fillTh1 = autoIsLarge ? 0.15 : autoIsMid ? 0.25 : 0.40
fillTh2 = autoIsLarge ? 0.50 : autoIsMid ? 0.75 : 1.00
fillTh3 = autoIsLarge ? 1.00 : autoIsMid ? 1.50 : 2.00

// =============================================================================
// SUB-BOX DIVISOR VALIDATION
// =============================================================================
f_nearestValidDivisor(orbDur, subDur) =>
    int chosen = 1
    int target = math.min(subDur, orbDur)
    for d = target to 1 by 1
        if orbDur % d == 0
            chosen := d
            break
    chosen

validSubBoxDur    = f_nearestValidDivisor(i_orbDurationMin, i_subBoxDurationMin)
subBoxWasAdjusted = validSubBoxDur != i_subBoxDurationMin
numSubBoxes       = math.floor(i_orbDurationMin / validSubBoxDur)

// =============================================================================
// SESSION TIMING
// =============================================================================
tzString   = i_timezone == "Exchange" ? syminfo.timezone : i_timezone
sessHour   = hour(time, tzString)
sessMinute = minute(time, tzString)
nowMinutes = sessHour * 60 + sessMinute

orbStartMinutes = i_orbStartHour * 60 + i_orbStartMinute
orbEndMinutes   = orbStartMinutes + i_orbDurationMin

inORBWindow  = nowMinutes >= orbStartMinutes and nowMinutes < orbEndMinutes
orbStarting  = inORBWindow and not inORBWindow[1]
orbJustEnded = not inORBWindow and inORBWindow[1]

minutesIntoORB   = nowMinutes - orbStartMinutes
currentSubBoxIdx = inORBWindow ? math.floor(minutesIntoORB / validSubBoxDur) : -1
newSubBox        = inORBWindow and (currentSubBoxIdx != currentSubBoxIdx[1])

// =============================================================================
// STATE
// =============================================================================
var float aggHigh    = na
var float aggLow     = na
var int   aggHighBar = na
var int   aggLowBar  = na

var float subHigh      = na
var float subLow       = na
var int   subStartBar  = na
var float prevSubClose = na
var float prevSubRange = na
var float prevSubHigh  = na
var float prevSubLow   = na

var float finalHigh   = na
var float finalLow    = na
var float finalMid    = na
var bool  orbComplete = false

var int sessionStartBar = na

var array<box>   subBoxes   = array.new<box>()
var array<box>   finalBoxes = array.new<box>()
var array<line>  finalLines = array.new<line>()
var array<label> noteLabels = array.new<label>()
var box currentSubBox     = na
var box pendingDeleteBox  = na
var line liveMidLine      = na

var string classExpand   = "—"
var string classPosition = "—"

atr14 = ta.atr(14)

// =============================================================================
// SESSION RESET
// =============================================================================
if orbStarting
    aggHigh      := high
    aggLow       := low
    aggHighBar   := bar_index
    aggLowBar    := bar_index
    subHigh      := high
    subLow       := low
    subStartBar  := bar_index
    sessionStartBar := bar_index
    prevSubClose := na
    prevSubRange := na
    prevSubHigh  := na
    prevSubLow   := na
    finalHigh    := na
    finalLow     := na
    finalMid     := na
    orbComplete  := false
    classExpand   := "Forming"
    classPosition := "—"

    if array.size(subBoxes) > 0
        for i = 0 to array.size(subBoxes) - 1
            box.delete(array.get(subBoxes, i))
        array.clear(subBoxes)
    if array.size(finalBoxes) > 0
        for i = 0 to array.size(finalBoxes) - 1
            box.delete(array.get(finalBoxes, i))
        array.clear(finalBoxes)
    if array.size(finalLines) > 0
        for i = 0 to array.size(finalLines) - 1
            line.delete(array.get(finalLines, i))
        array.clear(finalLines)
    if array.size(noteLabels) > 0
        for i = 0 to array.size(noteLabels) - 1
            label.delete(array.get(noteLabels, i))
        array.clear(noteLabels)
    if not na(pendingDeleteBox)
        box.delete(pendingDeleteBox)
        pendingDeleteBox := na
    if not na(liveMidLine)
        line.delete(liveMidLine)
        liveMidLine := na
    currentSubBox := na

// =============================================================================
// LIVE TRACKING
// =============================================================================
if inORBWindow and not orbStarting
    if high > aggHigh
        aggHigh := high
        aggHighBar := bar_index
    if low < aggLow
        aggLow := low
        aggLowBar := bar_index

    if newSubBox
        prevSubClose := close[1]
        prevSubRange := subHigh - subLow
        prevSubHigh  := subHigh
        prevSubLow   := subLow

        if i_showRollingBox and not i_showAllSubBoxes and not na(currentSubBox)
            pendingDeleteBox := currentSubBox
            if array.size(subBoxes) > 0
                array.pop(subBoxes)

        subHigh := high
        subLow  := low
        subStartBar := bar_index
        currentSubBox := na
    else
        if high > subHigh
            subHigh := high
        if low < subLow
            subLow := low

// =============================================================================
// CLASSIFICATION
// =============================================================================
refHigh = orbComplete ? finalHigh : aggHigh
refLow  = orbComplete ? finalLow  : aggLow

if not na(refHigh) and not na(refLow) and (refHigh - refLow) > 0
    refRange = refHigh - refLow
    upperBand = refHigh - refRange / 3.0
    lowerBand = refLow  + refRange / 3.0
    if orbComplete
        classPosition := close > refHigh    ? "Above Range" :
                         close < refLow     ? "Below Range" :
                         close >= upperBand ? "Upper Range" :
                         close <= lowerBand ? "Lower Range" : "Mid Range"
    else
        classPosition := close >= upperBand ? "Holding High" : close <= lowerBand ? "Holding Low" : "Neutral"

if inORBWindow
    if not na(prevSubRange) and prevSubRange > 0
        curRange = subHigh - subLow
        isInside = subHigh <= prevSubHigh and subLow >= prevSubLow
        barsIntoSubBox = bar_index - subStartBar + 1
        rangeThreshold = prevSubRange * 0.10
        if barsIntoSubBox < 2
            classExpand := "Forming"
        else if isInside
            classExpand := "Inside"
        else if curRange > prevSubRange + rangeThreshold
            classExpand := "Expanding"
        else if curRange < prevSubRange - rangeThreshold
            classExpand := "Compressing"
        else
            classExpand := "Stable"

// =============================================================================
// COLORS
// =============================================================================
f_borderColor() =>
    color result = i_colNeutral
    if classPosition == "Holding High"
        result := i_colHoldHigh
    else if classPosition == "Holding Low"
        result := i_colHoldLow
    result

f_fillColor() =>
    color result = color.new(color.silver, 95)
    if not na(prevSubClose) and not na(atr14) and atr14 > 0
        delta = close - prevSubClose
        mag   = math.abs(delta) / atr14
        transp = mag < fillTh1 ? 94 : mag < fillTh2 ? 90 : mag < fillTh3 ? 85 : 80
        if delta > 0
            result := color.new(color.green, transp)
        else if delta < 0
            result := color.new(color.red, transp)
        else
            result := color.new(color.silver, 94)
    result

// =============================================================================
// DRAW SUB-BOX
// =============================================================================
if inORBWindow
    if na(currentSubBox)
        currentSubBox := box.new(left=subStartBar, top=subHigh, right=bar_index + 1, bottom=subLow, border_color=f_borderColor(), border_width=2, bgcolor=f_fillColor())
        array.push(subBoxes, currentSubBox)
        if not na(pendingDeleteBox)
            box.delete(pendingDeleteBox)
            pendingDeleteBox := na
    else
        box.set_top(currentSubBox, subHigh)
        box.set_bottom(currentSubBox, subLow)
        box.set_right(currentSubBox, bar_index + 1)
        box.set_border_color(currentSubBox, f_borderColor())
        box.set_bgcolor(currentSubBox, f_fillColor())

// =============================================================================
// DRAW LIVE MIDPOINT
// =============================================================================
if inORBWindow and i_showLiveMid and not na(aggHigh) and not na(aggLow)
    liveMid = (aggHigh + aggLow) / 2.0
    if na(liveMidLine)
        liveMidLine := line.new(x1=sessionStartBar, y1=liveMid, x2=bar_index + 1, y2=liveMid, color=i_colMid, width=2, style=line.style_dotted)
    else
        line.set_xy1(liveMidLine, sessionStartBar, liveMid)
        line.set_xy2(liveMidLine, bar_index + 1, liveMid)

// =============================================================================
// ORB LOCK
// =============================================================================
if orbJustEnded and not orbComplete
    finalHigh := aggHigh
    finalLow  := aggLow
    finalMid  := (finalHigh + finalLow) / 2.0
    orbComplete := true

    orbLockBar  = bar_index - 1
    orbLockEdge = orbLockBar + 1

    if array.size(subBoxes) > 0
        for i = 0 to array.size(subBoxes) - 1
            box.delete(array.get(subBoxes, i))
        array.clear(subBoxes)
    if not na(pendingDeleteBox)
        box.delete(pendingDeleteBox)
        pendingDeleteBox := na
    if not na(liveMidLine)
        line.delete(liveMidLine)
        liveMidLine := na
    currentSubBox := na

    if i_showFinalBox
        fb = box.new(left=sessionStartBar, top=finalHigh, right=orbLockEdge, bottom=finalLow, border_color=i_colFinal, border_width=2, bgcolor=color.new(color.white, 95))
        array.push(finalBoxes, fb)

    if i_showFinalLines
        lnH = line.new(x1=orbLockEdge, y1=finalHigh, x2=orbLockEdge + 50, y2=finalHigh, color=i_colFinal, width=2, extend=extend.right)
        lnL = line.new(x1=orbLockEdge, y1=finalLow,  x2=orbLockEdge + 50, y2=finalLow,  color=i_colFinal, width=2, extend=extend.right)
        array.push(finalLines, lnH)
        array.push(finalLines, lnL)

    if i_showMidpoint
        lnM = line.new(x1=orbLockEdge, y1=finalMid, x2=orbLockEdge + 50, y2=finalMid, color=i_colMid, width=1, style=line.style_dashed, extend=extend.right)
        array.push(finalLines, lnM)

    if i_showBuffer
        bufVal = i_bufferMode == "Ticks" ? syminfo.mintick * i_bufferTicks : i_bufferMode == "ATR" ? atr14 * i_bufferATR : finalHigh * (i_bufferPct / 100.0)
        lnBH = line.new(x1=orbLockEdge, y1=finalHigh + bufVal, x2=orbLockEdge + 50, y2=finalHigh + bufVal, color=i_colBuffer, width=1, style=line.style_dotted, extend=extend.right)
        lnBL = line.new(x1=orbLockEdge, y1=finalLow  - bufVal, x2=orbLockEdge + 50, y2=finalLow  - bufVal, color=i_colBuffer, width=1, style=line.style_dotted, extend=extend.right)
        array.push(finalLines, lnBH)
        array.push(finalLines, lnBL)

// =============================================================================
// DIVISOR ADJUSTMENT NOTICE
// =============================================================================
var bool adjustNoticed = false
if orbStarting
    adjustNoticed := false
if subBoxWasAdjusted and not adjustNoticed and inORBWindow
    lbl = label.new(x=bar_index, y=high, text="Sub-box auto-adjusted: " + str.tostring(i_subBoxDurationMin) + "m → " + str.tostring(validSubBoxDur) + "m (must divide " + str.tostring(i_orbDurationMin) + "m evenly)", color=color.new(color.orange, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
    array.push(noteLabels, lbl)
    adjustNoticed := true

// =============================================================================
// STATUS TABLE
// =============================================================================
f_tblPos(s) =>
    s == "Top Right"     ? position.top_right     : s == "Top Left"      ? position.top_left      : s == "Top Center"    ? position.top_center    : s == "Middle Right"  ? position.middle_right  : s == "Middle Left"   ? position.middle_left   : s == "Bottom Right"  ? position.bottom_right  : s == "Bottom Left"   ? position.bottom_left   : s == "Bottom Center" ? position.bottom_center : position.top_right

f_tblSize(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.normal

f_tableBorderColor() =>
    color result = i_colNeutral
    if orbComplete
        result := i_colFinal
    else if inORBWindow
        if classPosition == "Holding High"
            result := i_colHoldHigh
        else if classPosition == "Holding Low"
            result := i_colHoldLow
    result

var table statTbl = na
if i_showTable and barstate.islast
    if not na(statTbl)
        table.delete(statTbl)
    statTbl := table.new(f_tblPos(i_tablePos), 4, 2, bgcolor=color.new(color.gray, 60), border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=f_tableBorderColor())

    txtSize  = f_tblSize(i_tableSize)
    cellBg   = color.new(#0a0a0a, 0)
    headerBg = color.new(#1a1a1a, 0)

    stateTxt = orbComplete ? "Locked" : inORBWindow ? "Building (" + str.tostring(currentSubBoxIdx + 1) + "/" + str.tostring(numSubBoxes) + ")" : "Pre-ORB"
    stateCol = orbComplete ? color.white : inORBWindow ? color.yellow : color.gray

    devTxt = orbComplete ? classPosition : classExpand
    devCol = orbComplete ?
              (classPosition == "Above Range" ? color.lime    :
               classPosition == "Upper Range" ? color.green   :
               classPosition == "Lower Range" ? color.maroon  :
               classPosition == "Below Range" ? color.red     : color.silver) :
              (classExpand == "Expanding"   ? color.lime   :
               classExpand == "Compressing" ? color.orange :
               classExpand == "Inside"      ? color.aqua   :
               classExpand == "Forming"     ? color.gray   :
               classExpand == "Stable"      ? color.silver : color.silver)

    highTxt = na(finalHigh) ? (na(aggHigh) ? "—" : str.tostring(aggHigh, format.mintick)) : str.tostring(finalHigh, format.mintick)
    lowTxt  = na(finalLow)  ? (na(aggLow)  ? "—" : str.tostring(aggLow,  format.mintick)) : str.tostring(finalLow,  format.mintick)

    table.cell(statTbl, 0, 0, "State",       text_color=color.silver, text_size=txtSize, bgcolor=headerBg)
    table.cell(statTbl, 1, 0, "Development", text_color=color.silver, text_size=txtSize, bgcolor=headerBg)
    table.cell(statTbl, 2, 0, "ORB High",    text_color=color.silver, text_size=txtSize, bgcolor=headerBg)
    table.cell(statTbl, 3, 0, "ORB Low",     text_color=color.silver, text_size=txtSize, bgcolor=headerBg)

    table.cell(statTbl, 0, 1, stateTxt, text_color=stateCol,    text_size=txtSize, bgcolor=cellBg)
    table.cell(statTbl, 1, 1, devTxt,   text_color=devCol,      text_size=txtSize, bgcolor=cellBg)
    table.cell(statTbl, 2, 1, highTxt,  text_color=color.white, text_size=txtSize, bgcolor=cellBg)
    table.cell(statTbl, 3, 1, lowTxt,   text_color=color.white, text_size=txtSize, bgcolor=cellBg)

// =============================================================================
// CLEANUP
// =============================================================================
if array.size(subBoxes) > 50
    oldest = array.shift(subBoxes)
    if not na(oldest)
        box.delete(oldest)
if array.size(finalBoxes) > 3
    oldest = array.shift(finalBoxes)
    if not na(oldest)
        box.delete(oldest)
if array.size(finalLines) > 15
    oldest = array.shift(finalLines)
    if not na(oldest)
        line.delete(oldest)
if array.size(noteLabels) > 5
    oldest = array.shift(noteLabels)
    if not na(oldest)
        label.delete(oldest)
````

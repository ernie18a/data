# NY Time Open Levels + NWOG + NDOG + EHPDA

- url: https://www.tradingview.com/script/9jWAhkFP-NY-Time-Open-Levels-NWOG-NDOG-EHPDA/
- type: indicator
- pine_id: PUB;e740a74590fc475ab2da4121ffd5c6ca
- version: 1.0

## Description

# NY Time Open Levels + NWOG + NDOG + EHPDA + RTH ORG

**A multi-concept ICT/SMC toolkit combining session open levels, opening gaps, and killzones — all anchored to New York time.**

This indicator brings together several concepts commonly used in ICT (Inner Circle Trader) and Smart Money Concepts trading into a single, clean overlay. It automatically detects key New York session times and draws the levels, gaps, and zones traders use to frame daily and weekly price behavior.

## Features

**🕐 NY Session Open Levels**
Automatically marks the open price at key intraday times: 00:00, 02:00, 08:30, 09:30, 10:00, and 18:00 (New York time). Each level is plotted as a dotted line that extends through the session, resetting daily. Any combination of levels can be toggled on or off.

**📦 NWOG — New Week Opening Gap**
Plots the gap between Friday's ~16:59 close and the market's next opening (Sunday/Monday 18:00), shown as a shaded box with a midline. Keeps a configurable number of historical NWOGs on the chart.

**📦 NDOG — New Day Opening Gap**
Same concept as NWOG but for daily (non-Friday) opens — the gap between each day's ~16:59 close and that same day's 18:00 reopen.

**📐 EHPDA — Equilibrium Half Point Draw Around**
Plots the 50% midpoint between the facing edges of two consecutive NWOGs, a level often used as a magnet/reference zone between weekly opening gaps.

**📊 RTH ORG — Regular Trading Hours Opening Range Gap**
Tracks the gap between the prior session's 16:14 close and the next Regular Trading Hours open at 09:30. Draws two horizontal lines (upper and lower boundary of the gap), each correctly originating from its own source candle — the close-based level starts at the 4:14 PM candle, and the open-based level starts at the 9:30 AM candle. Lines are color-coded by the originating weekday, making it easy to visually track which session each gap belongs to. Handles weekends/holidays automatically, so a Friday close correctly pairs with the following Monday's open.

**🎯 ICT Killzones**
Highlights the high/low range of five major sessions as they develop in real time, then freezes once the session ends:
- Asian (20:00–00:00)
- London (02:00–05:00)
- New York AM (08:30–11:30)
- Lunch (11:30–13:30)
- New York PM (13:30–16:00)

Each killzone keeps a configurable number of past sessions visible for historical reference.

## Timezone Handling
All calculations default to America/New_York time, ensuring accuracy regardless of your chart's exchange timezone or daylight saving time changes. A manual UTC offset override is also available for custom setups.

## How to Use It
This tool is designed for traders who use time-based and gap-based concepts (ICT, SMC, or similar frameworks) to identify areas of interest, liquidity, and draws on liquidity throughout the trading day and week. Combine the opening gaps (NWOG/NDOG/RTH ORG) with killzone ranges to build a narrative around where price is likely to react.

## Notes
- All levels, boxes, and lines are limited to a configurable history count to keep the chart clean and within Pine's line/label/box limits.
- Works on any symbol with sufficient historical data covering the relevant session times (works best on futures, forex, and other markets with extended/overnight sessions).
- This is not a signal generator — it is a context and structure tool meant to be used alongside your own analysis and risk management.

*This script is provided for educational and informational purposes only and does not constitute financial advice.*

## Source Code

````pine
//@version=6
indicator("NY Time Open Levels + NWOG + NDOG + EHPDA", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=300)

// ---------------- Timezone ----------------
useCustomUTC = input.bool(false, "Use Manual UTC Offset (overrides NY time)", group="Timezone")
utcOffset    = input.float(-5, "UTC Offset (e.g. 5.5 = UTC+5:30, -4 = UTC-4)", step=0.5, group="Timezone")

utcOffsetToString(offset) =>
    sign   = offset < 0 ? "-" : "+"
    absOff = math.abs(offset)
    hh     = math.floor(absOff)
    mm     = math.round((absOff - hh) * 60)
    mmStr  = mm < 10 ? "0" + str.tostring(mm) : str.tostring(mm)
    "UTC" + sign + str.tostring(hh) + (mm > 0 ? ":" + mmStr : "")

tz = useCustomUTC ? utcOffsetToString(utcOffset) : "America/New_York"

// ---------------- Time Level Inputs ----------------
show0000 = input.bool(true, "00:00")
show0200 = input.bool(true, "02:00")
show0830 = input.bool(true, "08:30")
show0930 = input.bool(true, "09:30")
show1000 = input.bool(true, "10:00")
show1800 = input.bool(true, "18:00")

// ---------------- NWOG Inputs ----------------
showNWOG = input.bool(true, "Show NWOG (New Week Opening Gap)", group="NWOG")
maxNWOG  = input.int(4, "Number of NWOG boxes to keep", minval=1, maxval=20, group="NWOG")

// ---------------- NDOG Inputs ----------------
showNDOG = input.bool(true, "Show NDOG (New Day Opening Gap)", group="NDOG")
maxNDOG  = input.int(6, "Number of NDOG boxes to keep", minval=1, maxval=30, group="NDOG")

// ---------------- EHPDA Inputs ----------------
showEHPDA = input.bool(true, "Show EHPDA (50% between NWOGs)", group="EHPDA")

// ---------------- RTH ORG Inputs ----------------
showRTHORG = input.bool(true, "Show RTH ORG (prior 16:14 close vs 09:30 open)", group="RTH ORG")
maxRTHORG  = input.int(5, "Number of RTH ORG line-pairs to keep", minval=1, maxval=30, group="RTH ORG")

// ---------------- Killzones Inputs ----------------
showKZAsian  = input.bool(true, "Show Asian Killzone (20:00-00:00)", group="Killzones")
showKZLondon = input.bool(true, "Show London Killzone (02:00-05:00)", group="Killzones")
showKZNYAM   = input.bool(true, "Show New York AM Killzone (08:30-11:30)", group="Killzones")
showKZLunch  = input.bool(true, "Show ICT Lunch (11:30-13:30)", group="Killzones")
showKZNYPM   = input.bool(true, "Show New York PM Killzone (13:30-16:00)", group="Killzones")
maxKZ        = input.int(5, "Number of past killzone sessions to keep (each)", minval=1, maxval=20, group="Killzones")

// ---------------- Time (selected timezone) ----------------
h   = hour(time, tz)
m   = minute(time, tz)
d   = dayofmonth(time, tz)
dow = dayofweek(time, tz)

// ================= Intraday Open Levels =================
var line[]  lines  = array.new_line()
var label[] labels = array.new_label()

var int lastDay = na
newDay = na(lastDay) or d != lastDay
lastDay := d

clearAll() =>
    while array.size(lines) > 0
        line.delete(array.shift(lines))
    while array.size(labels) > 0
        label.delete(array.shift(labels))

if newDay
    clearAll()

if array.size(lines) > 0
    for i = 0 to array.size(lines) - 1
        line.set_x2(array.get(lines, i), bar_index)
        label.set_x(array.get(labels, i), bar_index)

drawLevel(show, th, tm, txt) =>
    if show and h == th and m == tm
        price = open
        l = line.new(bar_index, price, bar_index, price,
             color=color.gray,
             width=1,
             style=line.style_dotted)
        lb = label.new(bar_index, price, txt,
             style=label.style_label_left,
             textcolor=color.gray,
             color=color.new(color.gray, 100),
             size=size.small)
        array.push(lines, l)
        array.push(labels, lb)

drawLevel(show0000, 0, 0, "00:00")
drawLevel(show0200, 2, 0, "02:00")
drawLevel(show0830, 8, 30, "08:30")
drawLevel(show0930, 9, 30, "09:30")
drawLevel(show1000, 10, 0, "10:00")
drawLevel(show1800, 18, 0, "18:00")

// ================= Shared helpers =================
monthNames = array.from("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
dayNames   = array.from("Sun","Mon","Tue","Wed","Thu","Fri","Sat")
dateStrFor(barTime) =>
    array.get(dayNames, dayofweek(barTime, tz) - 1) + " " + str.tostring(dayofmonth(barTime, tz)) + " " + array.get(monthNames, month(barTime, tz) - 1)

// ================= Hour-anchored close/open detection =================
// This replaces day-of-week / calendar-midnight based detection.
// IMPORTANT: most futures/forex feeds have NO bars between 17:00 and 18:00
// (that's the actual maintenance-break closure), so hour goes 16 -> 18
// directly with nothing in between. So instead of waiting for a bar
// INSIDE hour 17, we continuously latch the close throughout hour 16
// (it naturally ends up holding the ~16:59 close), and the reopen is
// simply "first bar of hour 18", whatever hour came right before it.
var float lastHr16Close = na
var int   lastHr16Bar   = na
var int   lastHr16Dow   = na
var bool  haveHr16Close = false

if h == 16
    lastHr16Close   := close
    lastHr16Bar     := bar_index
    lastHr16Dow     := dow
    haveHr16Close   := true

is6pmOpen = h == 18 and h[1] != 18   // first bar of hour 18, regardless of preceding hour

// Separate latch for RTH ORG (consumed at 09:30, not at 18:00, so it must
// track independently from the NWOG/NDOG latch above). RTH ORG anchors on
// the 16:14 close specifically (not 16:59 like NWOG/NDOG).
var float rthCloseVal  = na
var int   rthCloseBar  = na
var int   rthCloseDow  = na
var bool  rthHaveClose = false

if h == 16 and m == 14 and dow != dayofweek.saturday and dow != dayofweek.sunday
    rthCloseVal   := close
    rthCloseBar   := bar_index
    rthCloseDow   := dow
    rthHaveClose  := true

is930Open = h == 9 and m == 30   // the 09:30 RTH open bar

// ================= NWOG (New Week Opening Gap) =================
// Friday's ~16:59 close paired with the NEXT 18:00 reopen (Sun or Mon, whichever comes first)
isNWOGbar = showNWOG and haveHr16Close and lastHr16Dow == dayofweek.friday and is6pmOpen
pendingFridayClose = lastHr16Close
pendingFridayBar   = lastHr16Bar

var box[]   nwogBoxes  = array.new_box()
var line[]  nwogLines  = array.new_line()
var label[] nwogLabels = array.new_label()

var line[]  ehpdaLines     = array.new_line()
var label[] ehpdaLabels    = array.new_label()
var float   prevNWOGtop    = na
var float   prevNWOGbottom = na

if isNWOGbar
    closeLevel  = pendingFridayClose
    openLevel   = open
    topLevel    = math.max(closeLevel, openLevel)
    bottomLevel = math.min(closeLevel, openLevel)
    midLevel    = (topLevel + bottomLevel) / 2

    b = box.new(pendingFridayBar, topLevel, bar_index, bottomLevel,
         border_color=color.new(color.orange, 30),
         bgcolor=color.new(color.orange, 90),
         border_width=1)
    ml = line.new(pendingFridayBar, midLevel, bar_index, midLevel,
         color=color.orange,
         width=1,
         style=line.style_dashed)
    lb = label.new(bar_index, midLevel, "NWOG " + dateStrFor(time),
         style=label.style_label_left,
         textcolor=color.orange,
         color=color.new(color.orange, 100),
         size=size.small)

    array.push(nwogBoxes, b)
    array.push(nwogLines, ml)
    array.push(nwogLabels, lb)

    while array.size(nwogBoxes) > maxNWOG
        box.delete(array.shift(nwogBoxes))
        line.delete(array.shift(nwogLines))
        label.delete(array.shift(nwogLabels))

    // ---- EHPDA: midpoint between facing edges of this NWOG and the previous one ----
    if showEHPDA and not na(prevNWOGtop)
        float facingUpperEdge = na
        float facingLowerEdge = na

        if midLevel > (prevNWOGtop + prevNWOGbottom) / 2
            facingUpperEdge := bottomLevel
            facingLowerEdge := prevNWOGtop
        else
            facingUpperEdge := prevNWOGbottom
            facingLowerEdge := topLevel

        ehpdaLevel = (facingUpperEdge + facingLowerEdge) / 2

        el = line.new(pendingFridayBar, ehpdaLevel, bar_index, ehpdaLevel,
             color=color.aqua,
             width=1,
             style=line.style_solid)
        elb = label.new(bar_index, ehpdaLevel, "EHPDA",
             style=label.style_label_left,
             textcolor=color.aqua,
             color=color.new(color.aqua, 100),
             size=size.small)
        array.push(ehpdaLines, el)
        array.push(ehpdaLabels, elb)

        while array.size(ehpdaLines) > maxNWOG - 1
            line.delete(array.shift(ehpdaLines))
            label.delete(array.shift(ehpdaLabels))

    prevNWOGtop    := topLevel
    prevNWOGbottom := bottomLevel

    haveHr16Close := false   // consumed - reset until hour 16 latches again

// ================= NDOG (New Day Opening Gap) =================
// Every non-Friday day's ~16:59 close paired with that SAME day's 18:00 reopen
isNDOGbar = showNDOG and haveHr16Close and lastHr16Dow != dayofweek.friday and is6pmOpen
pendingDailyClose = lastHr16Close
pendingDailyBar   = lastHr16Bar

var box[]   ndogBoxes  = array.new_box()
var line[]  ndogLines  = array.new_line()
var label[] ndogLabels = array.new_label()

if isNDOGbar
    closeLevelD  = pendingDailyClose
    openLevelD   = open
    topLevelD    = math.max(closeLevelD, openLevelD)
    bottomLevelD = math.min(closeLevelD, openLevelD)
    midLevelD    = (topLevelD + bottomLevelD) / 2

    bD = box.new(pendingDailyBar, topLevelD, bar_index, bottomLevelD,
         border_color=color.new(color.blue, 30),
         bgcolor=color.new(color.blue, 90),
         border_width=1)
    mlD = line.new(pendingDailyBar, midLevelD, bar_index, midLevelD,
         color=color.blue,
         width=1,
         style=line.style_dashed)
    lbD = label.new(bar_index, midLevelD, "NDOG " + dateStrFor(time),
         style=label.style_label_left,
         textcolor=color.blue,
         color=color.new(color.blue, 100),
         size=size.small)

    array.push(ndogBoxes, bD)
    array.push(ndogLines, mlD)
    array.push(ndogLabels, lbD)

    while array.size(ndogBoxes) > maxNDOG
        box.delete(array.shift(ndogBoxes))
        line.delete(array.shift(ndogLines))
        label.delete(array.shift(ndogLabels))

    haveHr16Close := false   // consumed - reset until hour 16 latches again

// ================= RTH ORG (Regular Trading Hours Opening Range Gap) =================
// Prior day's 16:14 close paired with the NEXT 09:30 RTH open (weekend/holiday
// gaps naturally carry Friday's close forward to Monday's 09:30). The gap is
// labeled with the day of the 09:30 OPEN (e.g. Thursday), not the prior close
// day (Wednesday), since both the upper and lower line belong to that
// opening day's gap.
// Each originating weekday gets its own color so days are easy to tell apart.
rthDayColor(dv) =>
    switch dv
        1 => color.yellow                    // Sun
        2 => color.lime                      // Mon
        3 => color.aqua                      // Tue
        4 => color.fuchsia                   // Wed
        5 => color.orange                    // Thu
        6 => color.red                       // Fri
        7 => color.silver                    // Sat
        => color.white

isRTHORGbar = showRTHORG and rthHaveClose and is930Open

var line[]  rthUpperLines  = array.new_line()
var label[] rthUpperLabels = array.new_label()
var line[]  rthLowerLines  = array.new_line()
var label[] rthLowerLabels = array.new_label()

if isRTHORGbar
    closeLevelR  = rthCloseVal
    openLevelR   = open
    topLevelR    = math.max(closeLevelR, openLevelR)
    bottomLevelR = math.min(closeLevelR, openLevelR)
    dayPrefix    = array.get(dayNames, dow - 1)
    dayCol       = rthDayColor(dow)

    closeIsUpper = closeLevelR >= openLevelR
    ulStartBar   = closeIsUpper ? rthCloseBar : bar_index
    llStartBar   = closeIsUpper ? bar_index : rthCloseBar

    ulLine = line.new(ulStartBar, topLevelR, bar_index, topLevelR,
         color=dayCol,
         width=1,
         style=line.style_dashed)
    ulLabel = label.new(bar_index, topLevelR, dayPrefix + " RTH ORG upper",
         style=label.style_label_left,
         textcolor=dayCol,
         color=color.new(dayCol, 100),
         size=size.small)

    llLine = line.new(llStartBar, bottomLevelR, bar_index, bottomLevelR,
         color=dayCol,
         width=1,
         style=line.style_dashed)
    llLabel = label.new(bar_index, bottomLevelR, dayPrefix + " RTH ORG lower",
         style=label.style_label_left,
         textcolor=dayCol,
         color=color.new(dayCol, 100),
         size=size.small)

    array.push(rthUpperLines, ulLine)
    array.push(rthUpperLabels, ulLabel)
    array.push(rthLowerLines, llLine)
    array.push(rthLowerLabels, llLabel)

    while array.size(rthUpperLines) > maxRTHORG
        line.delete(array.shift(rthUpperLines))
        label.delete(array.shift(rthUpperLabels))
    while array.size(rthLowerLines) > maxRTHORG
        line.delete(array.shift(rthLowerLines))
        label.delete(array.shift(rthLowerLabels))

    rthHaveClose := false   // consumed - reset until hour 16 latches again

// ================= Extend everything to run with price =================
if array.size(nwogBoxes) > 0
    for i = 0 to array.size(nwogBoxes) - 1
        box.set_right(array.get(nwogBoxes, i), bar_index)
        line.set_x2(array.get(nwogLines, i), bar_index)
        label.set_x(array.get(nwogLabels, i), bar_index)

if array.size(ehpdaLines) > 0
    for i = 0 to array.size(ehpdaLines) - 1
        line.set_x2(array.get(ehpdaLines, i), bar_index)
        label.set_x(array.get(ehpdaLabels, i), bar_index)

if array.size(ndogBoxes) > 0
    for i = 0 to array.size(ndogBoxes) - 1
        box.set_right(array.get(ndogBoxes, i), bar_index)
        line.set_x2(array.get(ndogLines, i), bar_index)
        label.set_x(array.get(ndogLabels, i), bar_index)

if array.size(rthUpperLines) > 0
    for i = 0 to array.size(rthUpperLines) - 1
        line.set_x2(array.get(rthUpperLines, i), bar_index)
        label.set_x(array.get(rthUpperLabels, i), bar_index)

if array.size(rthLowerLines) > 0
    for i = 0 to array.size(rthLowerLines) - 1
        line.set_x2(array.get(rthLowerLines, i), bar_index)
        label.set_x(array.get(rthLowerLabels, i), bar_index)

// ================= Killzones =================
// Each killzone draws just two horizontal lines - top (session high) and
// bottom (session low) - plus one label above, confined to the session's
// own bar range. No box, no vertical end-caps. The lines grow live while
// the session is running (right edge tracks the current bar), then
// FREEZE in place once the session ends - they do not keep extending
// forward with price. The function below is called once per killzone;
// each call site keeps its own independent `var` state, so one function
// safely tracks all 5 sessions.
inAsian  = h >= 20                                                              // 20:00 - 00:00
inLondon = h >= 2 and h < 5                                                     // 02:00 - 05:00
inNYAM   = (h > 8 or (h == 8 and m >= 30)) and (h < 11 or (h == 11 and m < 30)) // 08:30 - 11:30
inLunch  = (h > 11 or (h == 11 and m >= 30)) and (h < 13 or (h == 13 and m < 30)) // 11:30 - 13:30 (ICT NY Lunch)
inNYPM   = (h > 13 or (h == 13 and m >= 30)) and h < 16                         // 13:30 - 16:00

manageKillzone(sessionActive, kzColor, labelText, maxKeep) =>
    var bool  activePrev  = false
    var float sessHigh    = na
    var float sessLow     = na
    var int   sessStart   = na
    var line  topLine     = na
    var line  bottomLine  = na
    var label nameLabel   = na
    var line[]  topHist    = array.new_line()
    var line[]  bottomHist = array.new_line()
    var label[] labelHist  = array.new_label()

    if sessionActive and not activePrev
        sessHigh   := high
        sessLow    := low
        sessStart  := bar_index
        topLine    := line.new(bar_index, sessHigh, bar_index, sessHigh, color=kzColor, width=1, style=line.style_solid)
        bottomLine := line.new(bar_index, sessLow, bar_index, sessLow, color=kzColor, width=1, style=line.style_solid)
        nameLabel  := label.new(bar_index, sessHigh, labelText, style=label.style_label_down, textcolor=kzColor, color=color.new(kzColor, 100), size=size.small)
        array.push(topHist, topLine)
        array.push(bottomHist, bottomLine)
        array.push(labelHist, nameLabel)
        while array.size(topHist) > maxKeep
            line.delete(array.shift(topHist))
            line.delete(array.shift(bottomHist))
            label.delete(array.shift(labelHist))

    if sessionActive
        sessHigh := math.max(sessHigh, high)
        sessLow  := math.min(sessLow, low)
        midBar    = math.round((sessStart + bar_index) / 2)
        line.set_y1(topLine, sessHigh)
        line.set_y2(topLine, sessHigh)
        line.set_x2(topLine, bar_index)
        line.set_y1(bottomLine, sessLow)
        line.set_y2(bottomLine, sessLow)
        line.set_x2(bottomLine, bar_index)
        label.set_xy(nameLabel, midBar, sessHigh)

    // NOTE: intentionally no "extend to current bar" step here - once a
    // session ends, the top/bottom lines freeze in place and do not keep
    // stretching forward with price.

    activePrev := sessionActive

if showKZAsian
    manageKillzone(inAsian, color.teal, "Asian", maxKZ)
if showKZLondon
    manageKillzone(inLondon, color.aqua, "London", maxKZ)
if showKZNYAM
    manageKillzone(inNYAM, color.orange, "New York AM", maxKZ)
if showKZLunch
    manageKillzone(inLunch, color.gray, "Lunch", maxKZ)
if showKZNYPM
    manageKillzone(inNYPM, color.red, "New York PM", maxKZ)
````

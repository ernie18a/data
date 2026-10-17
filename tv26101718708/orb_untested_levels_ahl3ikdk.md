# ORB + Untested Levels 

- url: https://www.tradingview.com/script/ahL3Ikdk-ORB-Untested-Levels/
- type: indicator
- pine_id: PUB;98d0a0cb48d74f8d8d68d54d7550d8f7
- version: 3.0

## Description

This comprehensive session-trading indicator is designed to help intraday traders map out institutional liquidity, define structural risk, and avoid low-probability market environments. By anchoring key Opening Range Breakout (ORB) zones and tracking unmitigated session levels, this script provides an objective framework for managing risk during volatile market opens.

Core Features
1. NY Morning ORB & Volatility Gauge (8:00 - 8:15 AM NY)
Plots the precise 8:00 AM - 8:15 AM New York Opening Range along with its structural Midpoint.

Dynamic Range Tracker: Instantly calculates and displays the exact point size of the ORB, allowing you to gauge initial morning volatility before the equities open.

2. Pre-Market "No Trade Zone" (NTZ)
Visually shades a No Trade Zone region to protect you from the treacherous choppy price action that often occurs during the pre-market lull.

This zone explicitly signals you to hold off on trading until the true institutional session volume enters the market at the 9:30 AM NY Equities Open.

3. Fully Customizable Session ORBs
Adapt to any trading schedule. You can independently toggle and customize Opening Ranges for multiple global sessions:

New York Session

Asia Session

Combined NY + Asia Overview

4. Untested Session Levels (Liquidity Pools)
Tracks unmitigated or "untested" historical session high/low levels that often act as powerful magnets for price.

Includes a customizable lookback period so you can decide how many past sessions to analyze for unreached liquidity.

5. Multi-Day Historical ORB Lookback
Keeps a historical lookback of the Previous Day ORBs (5 days by default) to help you see how price reacts to past structural zones.

Levels are cleanly extended to the right of your chart, serving as excellent support, resistance, or profit-taking targets for current intraday setups.

## Source Code

````pine
//@version=6
indicator("ORB + Untested Levels [thechadyogi]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================================================================
// SECTION 1.5 — PREVIOUS DAY ORB (PDO) SETTINGS
// =====================================================================

showPDO          = input.bool(true,   "Show Previous Day ORB (PDO)",       group="PDO Settings")
pdoLookback      = input.int(5,       "PDO Lookback (Trading Days)",       minval=1, maxval=10, group="PDO Settings")
pdoShowBoxes     = input.bool(true,   "Show PDO Range Boxes",              group="PDO Settings")
pdoShowMidlines  = input.bool(true,   "Show PDO Midlines",                 group="PDO Settings")
pdoFillOpacity   = input.int(90,      "PDO Box Fill Opacity %",            minval=50, maxval=99, group="PDO Settings")
pdoBorderOpacity = input.int(70,      "PDO Box Border Opacity %",          minval=20, maxval=99, group="PDO Settings")
pdoMidOpacity    = input.int(50,      "PDO Midline Opacity %",             minval=10, maxval=90, group="PDO Settings")
pdoAgeFade       = input.int(5,       "Opacity Fade Per Day (+%)",         minval=0,  maxval=15, group="PDO Settings")

// =====================================================================
// SECTION 1 — ORB SETTINGS
// =====================================================================

tz = input.string("America/New_York", "Session Timezone", group="ORB Settings")

orbDisplay = input.string("NY Only", "Select ORB to Display", options=["NY Only", "Asia Only", "NY + Asia"], group="ORB Settings")
showNyOrb = (orbDisplay == "NY Only" or orbDisplay == "NY + Asia")
showAsiaOrb = (orbDisplay == "Asia Only" or orbDisplay == "NY + Asia")

rangeSess = input.session("0800-0815", "NY ORB Window (HHMM-HHMM)", group="ORB Settings")
extendH   = input.int(16, "NY ORB Extend To Hour", group="ORB Settings")
extendM   = input.int(0,  "NY ORB Extend To Minute", group="ORB Settings")

asiaRangeSess = input.session("1800-1815", "Asia ORB Window (HHMM-HHMM)", group="ORB Settings")
asiaExtendH   = input.int(3, "Asia ORB Extend To Hour", group="ORB Settings")
asiaExtendM   = input.int(0,  "Asia ORB Extend To Minute", group="ORB Settings")

orbBorderColor  = input.color(color.red,                "NY ORB Border Color",  group="ORB Settings")
orbFillColor    = input.color(color.new(color.red, 90), "NY ORB Fill Color",    group="ORB Settings")
orbMidlineColor = input.color(color.black,              "NY ORB Midline Color", group="ORB Settings")

asiaOrbBorderColor  = input.color(color.blue,                "Asia ORB Border Color",  group="ORB Settings")
asiaOrbFillColor    = input.color(color.new(color.blue, 90), "Asia ORB Fill Color",    group="ORB Settings")
asiaOrbMidlineColor = input.color(color.black,              "Asia ORB Midline Color", group="ORB Settings")

orbMidlineStyle = input.string("Dashed", "ORB Midline Style", options=["Solid","Dashed","Dotted"], group="ORB Settings")

showSignalCandleLabel = input.bool(true, "Show Signal Candle Label", group="ORB Settings")
showMidpointLabel     = input.bool(true, "Show Midpoint Touch Label", group="ORB Settings")

// =====================================================================
// HELPERS
// =====================================================================

midStyleFor(s) =>
    s == "Solid"  ? line.style_solid :
     s == "Dotted" ? line.style_dotted :
                     line.style_dashed

// =====================================================================
// SECTION 2 — NY 8AM ORB
// =====================================================================

inRange = not na(time(timeframe.period, rangeSess, tz))
newNyRange = inRange and not inRange[1]

var float hi            = na
var float lo            = na
var box   bx            = na
var line  mid           = na
var label orbRangeLabel = na
var int   leftTs        = na
var int   nyExtendTs    = na

if newNyRange
    hi         := na
    lo         := na
    leftTs     := na
    bx         := na
    mid        := na
    nyExtendTs := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), extendH, extendM)
    if nyExtendTs <= time
        nyExtendTs += 86400000

    if not na(orbRangeLabel)
        label.delete(orbRangeLabel)
        orbRangeLabel := na

if inRange and showNyOrb
    hi := na(hi) ? high : math.max(hi, high)
    lo := na(lo) ? low  : math.min(lo, low)

    if na(bx)
        leftTs := time

        bx := box.new(
            leftTs, hi, nyExtendTs, lo,
            xloc         = xloc.bar_time,
            bgcolor      = orbFillColor,
            border_color = orbBorderColor,
            border_width = 1)

        float midY = (hi + lo) / 2.0

        mid := line.new(
            leftTs, midY, nyExtendTs, midY,
            xloc  = xloc.bar_time,
            color = orbMidlineColor,
            style = midStyleFor(orbMidlineStyle),
            width = 1)

        orbRangeLabel := label.new(
            leftTs, lo, str.tostring(hi - lo, format.mintick),
            xloc      = xloc.bar_time,
            yloc      = yloc.price,
            style     = label.style_label_up,
            size      = size.normal,
            textcolor = orbBorderColor,
            color     = color.new(color.black, 100))
    else
        box.set_top(bx, hi)
        box.set_bottom(bx, lo)

if not na(bx) and showNyOrb
    box.set_right(bx, nyExtendTs)

if not na(mid) and not na(hi) and not na(lo) and not na(leftTs) and showNyOrb
    float midY2 = (hi + lo) / 2.0
    line.set_xy1(mid, leftTs, midY2)
    line.set_xy2(mid, nyExtendTs, midY2)

if not na(orbRangeLabel) and not na(hi) and not na(lo) and not na(leftTs) and showNyOrb
    label.set_xy(orbRangeLabel, leftTs, lo)
    label.set_text(orbRangeLabel, str.tostring(hi - lo, format.mintick))
    label.set_textcolor(orbRangeLabel, orbBorderColor)

// =====================================================================
// SECTION 2.1 — NY PREVIOUS DAY ORB (PDO)
// =====================================================================

var float[] nyPdoHi     = array.new<float>()
var float[] nyPdoLo     = array.new<float>()
var int[]   nyPdoLeftTs = array.new<int>()
var box[]   nyPdoBoxes  = array.new<box>()
var line[]  nyPdoMids   = array.new<line>()

// When a new NY ORB range starts, archive the previous day's completed ORB
if newNyRange and showPDO and showNyOrb
    float prevHi = hi[1]
    float prevLo = lo[1]
    int   prevLt = leftTs[1]
    if not na(prevHi) and not na(prevLo) and not na(prevLt) and prevHi > prevLo
        nyPdoHi.push(prevHi)
        nyPdoLo.push(prevLo)
        nyPdoLeftTs.push(prevLt)
        nyPdoBoxes.push(na)
        nyPdoMids.push(na)

        // Trim oldest if exceeding lookback
        while nyPdoHi.size() > pdoLookback
            box.delete(nyPdoBoxes.shift())
            line.delete(nyPdoMids.shift())
            nyPdoHi.shift()
            nyPdoLo.shift()
            nyPdoLeftTs.shift()

// Draw / update NY PDO levels
if showPDO and showNyOrb and nyPdoHi.size() > 0
    int sz = nyPdoHi.size()
    for i = 0 to sz - 1
        int age = sz - 1 - i  // 0 = most recent, higher = older
        int fillTr   = math.min(99, pdoFillOpacity   + age * pdoAgeFade)
        int borderTr = math.min(99, pdoBorderOpacity  + age * pdoAgeFade)
        int midTr    = math.min(99, pdoMidOpacity     + age * pdoAgeFade)

        float pH = nyPdoHi.get(i)
        float pL = nyPdoLo.get(i)
        int   pT = nyPdoLeftTs.get(i)
        float pM = (pH + pL) / 2.0

        // --- Box ---
        if pdoShowBoxes
            box existingBox = nyPdoBoxes.get(i)
            if na(existingBox)
                box newBox = box.new(
                     pT, pH, time, pL,
                     xloc         = xloc.bar_time,
                     bgcolor      = color.new(orbBorderColor, fillTr),
                     border_color = color.new(orbBorderColor, borderTr),
                     border_width = 1)
                nyPdoBoxes.set(i, newBox)
            else
                box.set_right(existingBox, time)
                box.set_bgcolor(existingBox, color.new(orbBorderColor, fillTr))
                box.set_border_color(existingBox, color.new(orbBorderColor, borderTr))
        else
            box oldBox = nyPdoBoxes.get(i)
            if not na(oldBox)
                box.delete(oldBox)
                nyPdoBoxes.set(i, na)

        // --- Midline ---
        if pdoShowMidlines
            line existingMid = nyPdoMids.get(i)
            if na(existingMid)
                line newMid = line.new(
                     pT, pM, time, pM,
                     xloc  = xloc.bar_time,
                     color = color.new(orbMidlineColor, midTr),
                     style = line.style_dashed,
                     width = 1)
                nyPdoMids.set(i, newMid)
            else
                line.set_x2(existingMid, time)
                line.set_color(existingMid, color.new(orbMidlineColor, midTr))
        else
            line oldMid = nyPdoMids.get(i)
            if not na(oldMid)
                line.delete(oldMid)
                nyPdoMids.set(i, na)

// =====================================================================
// SECTION 2.5 — ASIA 6PM ORB
// =====================================================================

inAsiaOrbRange = not na(time(timeframe.period, asiaRangeSess, tz))
newAsiaOrbRange = inAsiaOrbRange and not inAsiaOrbRange[1]

var float asiaHi            = na
var float asiaLo            = na
var box   asiaBx            = na
var line  asiaMid           = na
var label asiaOrbRangeLabel = na
var int   asiaLeftTs        = na
var int   asiaExtendTs      = na

if newAsiaOrbRange
    asiaHi       := na
    asiaLo       := na
    asiaLeftTs   := na
    asiaBx       := na
    asiaMid      := na
    asiaExtendTs := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), asiaExtendH, asiaExtendM)
    if asiaExtendTs <= time
        asiaExtendTs += 86400000

    if not na(asiaOrbRangeLabel)
        label.delete(asiaOrbRangeLabel)
        asiaOrbRangeLabel := na

if inAsiaOrbRange and showAsiaOrb
    asiaHi := na(asiaHi) ? high : math.max(asiaHi, high)
    asiaLo := na(asiaLo) ? low  : math.min(asiaLo, low)

    if na(asiaBx)
        asiaLeftTs := time

        asiaBx := box.new(
            asiaLeftTs, asiaHi, asiaExtendTs, asiaLo,
            xloc         = xloc.bar_time,
            bgcolor      = asiaOrbFillColor,
            border_color = asiaOrbBorderColor,
            border_width = 1)

        float asiaMidY = (asiaHi + asiaLo) / 2.0

        asiaMid := line.new(
            asiaLeftTs, asiaMidY, asiaExtendTs, asiaMidY,
            xloc  = xloc.bar_time,
            color = asiaOrbMidlineColor,
            style = midStyleFor(orbMidlineStyle),
            width = 1)

        asiaOrbRangeLabel := label.new(
            asiaLeftTs, asiaLo, str.tostring(asiaHi - asiaLo, format.mintick),
            xloc      = xloc.bar_time,
            yloc      = yloc.price,
            style     = label.style_label_up,
            size      = size.normal,
            textcolor = asiaOrbBorderColor,
            color     = color.new(color.black, 100))
    else
        box.set_top(asiaBx, asiaHi)
        box.set_bottom(asiaBx, asiaLo)

if not na(asiaBx) and showAsiaOrb
    box.set_right(asiaBx, asiaExtendTs)

if not na(asiaMid) and not na(asiaHi) and not na(asiaLo) and not na(asiaLeftTs) and showAsiaOrb
    float asiaMidY2 = (asiaHi + asiaLo) / 2.0
    line.set_xy1(asiaMid, asiaLeftTs, asiaMidY2)
    line.set_xy2(asiaMid, asiaExtendTs, asiaMidY2)

if not na(asiaOrbRangeLabel) and not na(asiaHi) and not na(asiaLo) and not na(asiaLeftTs) and showAsiaOrb
    label.set_xy(asiaOrbRangeLabel, asiaLeftTs, asiaLo)
    label.set_text(asiaOrbRangeLabel, str.tostring(asiaHi - asiaLo, format.mintick))
    label.set_textcolor(asiaOrbRangeLabel, asiaOrbBorderColor)

// =====================================================================
// SECTION 2.6 — ASIA PREVIOUS DAY ORB (PDO)
// =====================================================================

var float[] asiaPdoHi     = array.new<float>()
var float[] asiaPdoLo     = array.new<float>()
var int[]   asiaPdoLeftTs = array.new<int>()
var box[]   asiaPdoBoxes  = array.new<box>()
var line[]  asiaPdoMids   = array.new<line>()

// When a new Asia ORB range starts, archive the previous day's completed ORB
if newAsiaOrbRange and showPDO and showAsiaOrb
    float prevAsiaHi = asiaHi[1]
    float prevAsiaLo = asiaLo[1]
    int   prevAsiaLt = asiaLeftTs[1]
    if not na(prevAsiaHi) and not na(prevAsiaLo) and not na(prevAsiaLt) and prevAsiaHi > prevAsiaLo
        asiaPdoHi.push(prevAsiaHi)
        asiaPdoLo.push(prevAsiaLo)
        asiaPdoLeftTs.push(prevAsiaLt)
        asiaPdoBoxes.push(na)
        asiaPdoMids.push(na)

        // Trim oldest if exceeding lookback
        while asiaPdoHi.size() > pdoLookback
            box.delete(asiaPdoBoxes.shift())
            line.delete(asiaPdoMids.shift())
            asiaPdoHi.shift()
            asiaPdoLo.shift()
            asiaPdoLeftTs.shift()

// Draw / update Asia PDO levels
if showPDO and showAsiaOrb and asiaPdoHi.size() > 0
    int aSz = asiaPdoHi.size()
    for i = 0 to aSz - 1
        int aAge = aSz - 1 - i
        int aFillTr   = math.min(99, pdoFillOpacity   + aAge * pdoAgeFade)
        int aBorderTr = math.min(99, pdoBorderOpacity  + aAge * pdoAgeFade)
        int aMidTr    = math.min(99, pdoMidOpacity     + aAge * pdoAgeFade)

        float aPH = asiaPdoHi.get(i)
        float aPL = asiaPdoLo.get(i)
        int   aPT = asiaPdoLeftTs.get(i)
        float aPM = (aPH + aPL) / 2.0

        // --- Box ---
        if pdoShowBoxes
            box aExistingBox = asiaPdoBoxes.get(i)
            if na(aExistingBox)
                box aNewBox = box.new(
                     aPT, aPH, time, aPL,
                     xloc         = xloc.bar_time,
                     bgcolor      = color.new(asiaOrbBorderColor, aFillTr),
                     border_color = color.new(asiaOrbBorderColor, aBorderTr),
                     border_width = 1)
                asiaPdoBoxes.set(i, aNewBox)
            else
                box.set_right(aExistingBox, time)
                box.set_bgcolor(aExistingBox, color.new(asiaOrbBorderColor, aFillTr))
                box.set_border_color(aExistingBox, color.new(asiaOrbBorderColor, aBorderTr))
        else
            box aOldBox = asiaPdoBoxes.get(i)
            if not na(aOldBox)
                box.delete(aOldBox)
                asiaPdoBoxes.set(i, na)

        // --- Midline ---
        if pdoShowMidlines
            line aExistingMid = asiaPdoMids.get(i)
            if na(aExistingMid)
                line aNewMid = line.new(
                     aPT, aPM, time, aPM,
                     xloc  = xloc.bar_time,
                     color = color.new(asiaOrbMidlineColor, aMidTr),
                     style = line.style_dashed,
                     width = 1)
                asiaPdoMids.set(i, aNewMid)
            else
                line.set_x2(aExistingMid, time)
                line.set_color(aExistingMid, color.new(asiaOrbMidlineColor, aMidTr))
        else
            line aOldMid = asiaPdoMids.get(i)
            if not na(aOldMid)
                line.delete(aOldMid)
                asiaPdoMids.set(i, na)

// =====================================================================
// SECTION 2.8 — NO-TRADE ZONE SETTINGS
// =====================================================================

showNoTradeZone   = input.bool(true,                          "Show No-Trade Zone (8AM–9:30AM ET)", group="No-Trade Zone")
ntzFillColor      = input.color(color.new(color.orange, 80),  "Fill Color",                        group="No-Trade Zone")
ntzBorderColor    = input.color(color.new(color.orange, 30),  "Border Color",                      group="No-Trade Zone")
ntzLabelColor     = input.color(color.orange,                 "Label Color",                       group="No-Trade Zone")
ntzLabelBgTransp  = input.int(100, "Label Background Opacity %", minval=0, maxval=100,             group="No-Trade Zone")

// =====================================================================
// SECTION 3 — SESSION SETTINGS
// =====================================================================

showSessions = input.bool(true, "Show Sessions", group="Sessions")

showAsia   = input.bool(true, "Show Asia Box",     group="Sessions")
showLondon = input.bool(true, "Show London Box",   group="Sessions")
showNY     = input.bool(true, "Show New York Box", group="Sessions")

asiaSession   = input.session("1800-0300", "Asia session",     group="Sessions")
londonSession = input.session("0200-1100", "London session",   group="Sessions")
nySession     = input.session("0700-1600", "New York session", group="Sessions")

asiaColor   = input.color(color.new(color.red,    85), "Asia Fill",   group="Sessions")
londonColor = input.color(color.new(color.yellow, 85), "London Fill", group="Sessions")
nyColor     = input.color(color.new(color.blue,   85), "NY Fill",     group="Sessions")

sessionBorderOpacity = input.int(100, "Session Border Opacity %", minval=0, maxval=100, group="Sessions")
sessionBorderWidth   = input.int(0,   "Session Border Width",     minval=0, maxval=3,   group="Sessions")

borderTransp = 100 - sessionBorderOpacity

// =====================================================================
// SECTION 4 — LABEL SETTINGS
// =====================================================================

showLabels      = input.bool(true, "Show Labels",           group="Session Labels")
showAsiaLabel   = input.bool(true, "Show Asia Label",       group="Session Labels")
showLondonLabel = input.bool(true, "Show London Label",     group="Session Labels")
showNYLabel     = input.bool(true, "Show New York Label",   group="Session Labels")

labelTransparency = input.int(50, "Label Transparency %", minval=0, maxval=100, group="Session Labels")
labelTextTransp   = labelTransparency

// =====================================================================
// SECTION 5 — UNTESTED LEVELS SETTINGS
// =====================================================================

group_ut      = "Untested Session Levels"
show_untested = input.bool(true,  "Show Untested Session Levels", group=group_ut)
lookback_days = input.int(3,      "Untested Lookback Days",       minval=1, maxval=10, group=group_ut)
ut_line_width = input.int(1,      "Untested Line Thickness",      minval=1, maxval=5,  group=group_ut)
ut_line_style = input.string("Solid", "Untested Line Type", options=["Solid","Dashed","Dotted"], group=group_ut)

ut_asia_color   = input.color(color.black, "Untested Asia Color",   group=group_ut)
ut_london_color = input.color(color.black, "Untested London Color", group=group_ut)
ut_ny_color     = input.color(color.black, "Untested NY Color",     group=group_ut)

// =====================================================================
// SECTION 6 — DATA STRUCTURES
// =====================================================================

type Level
    float  price
    int    startTime
    string sessionName
    color  levelColor
    line   levelLine
    label  levelLabel
    bool   isTested
    int    testedTime

var Level[] allLevels = array.new<Level>()

add_level(price, startTime, sessionName, levelColor) =>
    if show_untested and not na(price) and not na(startTime)
        allLevels.push(Level.new(price, startTime, sessionName, levelColor, na, na, false, 0))

get_ut_line_style(style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

// =====================================================================
// SECTION 7 — SESSION DETECTION
// =====================================================================

inAsiaS  = not na(time(timeframe.period, asiaSession))
inLondon = not na(time(timeframe.period, londonSession))
inNY     = not na(time(timeframe.period, nySession))

newAsiaS  = inAsiaS  and not inAsiaS[1]
newLondon = inLondon and not inLondon[1]
newNY     = inNY     and not inNY[1]

// =====================================================================
// SECTION 8 — ASIA SESSION BOX
// =====================================================================

var float asiaHigh  = na
var float asiaLow   = na
var int   asiaStart = na
var box   asiaBox   = na
var label asiaLbl   = na

if newAsiaS
    asiaHigh  := high
    asiaLow   := low
    asiaStart := time
    asiaBox   := na
    asiaLbl   := na

    if showSessions and showAsia
        asiaBox := box.new(
            asiaStart, asiaHigh, time, asiaLow,
            xloc         = xloc.bar_time,
            bgcolor      = asiaColor,
            border_color = color.new(asiaColor, borderTransp),
            border_width = sessionBorderWidth)

        if showLabels and showAsiaLabel
            asiaLbl := label.new(
                asiaStart, asiaHigh, "Asia",
                xloc      = xloc.bar_time,
                style     = label.style_none,
                textcolor = color.new(asiaColor, labelTextTransp))

else if inAsiaS
    asiaHigh := math.max(asiaHigh, high)
    asiaLow  := math.min(asiaLow,  low)

    if showSessions and showAsia and not na(asiaBox)
        box.set_top(asiaBox,    asiaHigh)
        box.set_bottom(asiaBox, asiaLow)
        box.set_right(asiaBox,  time)

    if showLabels and showAsiaLabel and not na(asiaLbl)
        label.set_xy(asiaLbl, asiaStart, asiaHigh)
        label.set_textcolor(asiaLbl, color.new(asiaColor, labelTextTransp))

if not inAsiaS and inAsiaS[1]
    if showSessions and showAsia and not na(asiaBox)
        box.set_right(asiaBox, time[1])
    add_level(asiaHigh, asiaStart, "Asia High", ut_asia_color)
    add_level(asiaLow,  asiaStart, "Asia Low",  ut_asia_color)

// =====================================================================
// SECTION 9 — LONDON SESSION BOX
// =====================================================================

var float londonHigh  = na
var float londonLow   = na
var int   londonStart = na
var box   londonBox   = na
var label londonLabel = na

if newLondon
    londonHigh  := high
    londonLow   := low
    londonStart := time
    londonBox   := na
    londonLabel := na

    if showSessions and showLondon
        londonBox := box.new(
            londonStart, londonHigh, time, londonLow,
            xloc         = xloc.bar_time,
            bgcolor      = londonColor,
            border_color = color.new(londonColor, borderTransp),
            border_width = sessionBorderWidth)

        if showLabels and showLondonLabel
            londonLabel := label.new(
                londonStart, londonHigh, "London",
                xloc      = xloc.bar_time,
                style     = label.style_none,
                textcolor = color.new(londonColor, labelTextTransp))

else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow  := math.min(londonLow,  low)

    if showSessions and showLondon and not na(londonBox)
        box.set_top(londonBox,    londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox,  time)

    if showLabels and showLondonLabel and not na(londonLabel)
        label.set_xy(londonLabel, londonStart, londonHigh)
        label.set_textcolor(londonLabel, color.new(londonColor, labelTextTransp))

if not inLondon and inLondon[1]
    if showSessions and showLondon and not na(londonBox)
        box.set_right(londonBox, time[1])
    add_level(londonHigh, londonStart, "London High", ut_london_color)
    add_level(londonLow,  londonStart, "London Low",  ut_london_color)

// =====================================================================
// SECTION 10 — NEW YORK SESSION BOX
// =====================================================================

var float nyHigh  = na
var float nyLow   = na
var int   nyStart = na
var box   nyBox   = na
var label nyLabel = na

if newNY
    nyHigh  := high
    nyLow   := low
    nyStart := time
    nyBox   := na
    nyLabel := na

    if showSessions and showNY
        nyBox := box.new(
            nyStart, nyHigh, time, nyLow,
            xloc         = xloc.bar_time,
            bgcolor      = nyColor,
            border_color = color.new(nyColor, borderTransp),
            border_width = sessionBorderWidth)

        if showLabels and showNYLabel
            nyLabel := label.new(
                nyStart, nyHigh, "New York",
                xloc      = xloc.bar_time,
                style     = label.style_none,
                textcolor = color.new(nyColor, labelTextTransp))

else if inNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow,  low)

    if showSessions and showNY and not na(nyBox)
        box.set_top(nyBox,    nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox,  time)

    if showLabels and showNYLabel and not na(nyLabel)
        label.set_xy(nyLabel, nyStart, nyHigh)
        label.set_textcolor(nyLabel, color.new(nyColor, labelTextTransp))

if not inNY and inNY[1]
    if showSessions and showNY and not na(nyBox)
        box.set_right(nyBox, time[1])
    add_level(nyHigh, nyStart, "NY High", ut_ny_color)
    add_level(nyLow,  nyStart, "NY Low",  ut_ny_color)

// =====================================================================
// SECTION 11 — UNTESTED RENDERING LOOP
// =====================================================================

lookback_ts = time - (lookback_days * 24 * 60 * 60 * 1000)

if show_untested and allLevels.size() > 0
    for i = allLevels.size() - 1 to 0
        Level lvl = allLevels.get(i)

        if lvl.startTime < lookback_ts
            line.delete(lvl.levelLine)
            label.delete(lvl.levelLabel)
            allLevels.remove(i)
            continue

        if lvl.isTested
            if dayofmonth(time, tz) != dayofmonth(lvl.testedTime, tz) and time > lvl.testedTime
                line.delete(lvl.levelLine)
                label.delete(lvl.levelLabel)
                allLevels.remove(i)
            continue

        if not lvl.isTested
            if time > lvl.startTime and high >= lvl.price and low <= lvl.price
                lvl.isTested := true
                lvl.testedTime := time
                line.set_x2(lvl.levelLine, time)
                label.set_xy(lvl.levelLabel, time, lvl.price)
                continue

            if na(lvl.levelLine)
                lvl.levelLine  := line.new(lvl.startTime, lvl.price, time, lvl.price,
                                     xloc.bar_time,
                                     color = lvl.levelColor,
                                     width = ut_line_width,
                                     style = get_ut_line_style(ut_line_style))
                lvl.levelLabel := label.new(time, lvl.price, lvl.sessionName,
                                     xloc.bar_time, yloc.price,
                                     color     = color.new(lvl.levelColor, 100),
                                     textcolor = lvl.levelColor,
                                     style     = label.style_label_left,
                                     size      = size.small)
            else
                line.set_x2(lvl.levelLine, time)
                label.set_xy(lvl.levelLabel, time, lvl.price)

// =====================================================================
// SECTION 12 — NO-TRADE ZONE (8:00 AM – 9:30 AM ET)
// =====================================================================

ntzSess = "0800-0930"
inNtz   = not na(time(timeframe.period, ntzSess, tz))
newNtz  = inNtz and not inNtz[1]

var float ntzHi    = na
var float ntzLo    = na
var int   ntzLeft  = na
var box   ntzBox   = na
var label ntzLabel = na

if newNtz
    ntzHi    := na
    ntzLo    := na
    ntzLeft  := na
    ntzBox   := na
    ntzLabel := na

if inNtz and showNoTradeZone
    ntzHi := na(ntzHi) ? high : math.max(ntzHi, high)
    ntzLo := na(ntzLo) ? low  : math.min(ntzLo, low)

    if na(ntzLeft)
        ntzLeft := time
        int ntzEndTs = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 9, 30)

        ntzBox := box.new(
            ntzLeft, ntzHi, ntzEndTs, ntzLo,
            xloc         = xloc.bar_time,
            bgcolor      = ntzFillColor,
            border_color = ntzBorderColor,
            border_width = 1,
            text         = "No-Trade Zone",
            text_halign  = text.align_left,
            text_valign  = text.align_top,
            text_color   = ntzLabelColor,
            text_size    = size.small)
    else
        box.set_top(ntzBox, ntzHi)
        box.set_bottom(ntzBox, ntzLo)

// =====================================================================
// SECTION 13 — OPEN MARKERS (12:00 AM & 8:30 AM EST)
// =====================================================================

showTrueDayOpen = input.bool(true,  "Show True Day Open (12:00 AM EST)", group="Open Markers")
trueDayColor    = input.color(color.new(color.white, 30), "12:00 AM Open Color", group="Open Markers")

show830Open     = input.bool(true,  "Show 8:30 AM EST Open", group="Open Markers")
open830Color    = input.color(color.new(color.yellow, 30), "8:30 AM Open Color", group="Open Markers")

markerLineWidth = input.int(1, "Marker Line Width", minval=1, maxval=5, group="Open Markers")

var float trueDayOpenPrice = na
var line  trueDayOpenLine  = na
var label trueDayOpenLabel = na
var int   trueDayStartTs   = na

var float open830Price = na
var line  open830Line  = na
var label open830Label = na
var int   open830StartTs = na

var int lastTrueDay = na
var int last830Day  = na

int currentDay = dayofmonth(time, tz)

// True Day Open detection
if na(lastTrueDay) or currentDay != lastTrueDay
    lastTrueDay := currentDay
    trueDayOpenPrice := open
    trueDayStartTs   := time
    
    if showTrueDayOpen
        if not na(trueDayOpenLine)
            line.delete(trueDayOpenLine)
        if not na(trueDayOpenLabel)
            label.delete(trueDayOpenLabel)
            
        trueDayOpenLine := line.new(trueDayStartTs, trueDayOpenPrice, time, trueDayOpenPrice, xloc.bar_time, color=trueDayColor, style=line.style_dashed, width=markerLineWidth)
        trueDayOpenLabel := label.new(time, trueDayOpenPrice, "True Day Open", xloc.bar_time, yloc.price, color=color.new(color.white, 100), textcolor=trueDayColor, style=label.style_label_left, size=size.small)

if showTrueDayOpen and not na(trueDayOpenLine)
    line.set_x2(trueDayOpenLine, time)
    label.set_xy(trueDayOpenLabel, time, trueDayOpenPrice)

// 8:30 AM EST Open detection
if (hour(time, tz) == 8 and minute(time, tz) >= 30) or (hour(time, tz) > 8)
    if na(last830Day) or currentDay != last830Day
        last830Day := currentDay
        open830Price := open
        open830StartTs := time
        
        if show830Open
            if not na(open830Line)
                line.delete(open830Line)
            if not na(open830Label)
                label.delete(open830Label)
                
            open830Line := line.new(open830StartTs, open830Price, time, open830Price, xloc.bar_time, color=open830Color, style=line.style_dashed, width=markerLineWidth)
            open830Label := label.new(time, open830Price, "8:30 AM Open", xloc.bar_time, yloc.price, color=color.new(color.white, 100), textcolor=open830Color, style=label.style_label_left, size=size.small)

if show830Open and not na(open830Line)
    line.set_x2(open830Line, time)
    label.set_xy(open830Label, time, open830Price)

// =====================================================================
// SECTION 14 — AUTOMATED STRATEGY EXECUTION (LONG ONLY DRAFT 1)
// =====================================================================

enableKLLongs   = input.bool(true, "Enable KL Long Trades", group="Strategy Executions")
enableORBLongs  = input.bool(true, "Enable ORB Long Trades", group="Strategy Executions")
enableKLShorts  = input.bool(true, "Enable KL Short Trades", group="Strategy Executions")
enableORBShorts = input.bool(true, "Enable ORB Short Trades", group="Strategy Executions")

// --- Ticker Detection & Dynamic Risk Matrix ---
bool isNQ = str.contains(syminfo.root, "NQ") or str.contains(syminfo.root, "MNQ")
bool isES = str.contains(syminfo.root, "ES") or str.contains(syminfo.root, "MES")

float stopLossPoints   = 6.5
float takeProfitPoints = 13.0

// --- Time & Session Filters ---
bool inTradingSession = not na(time(timeframe.period, "0930-1600:23456", tz))

// --- Strategy State Variables ---
var bool tradeExecutedToday = false

if ta.change(time("D", tz)) != 0
    tradeExecutedToday := false

// --- Execution Logic ---
bool isSweepCandle = false
bool isSweepCandleShort = false
bool touchesORB = not na(hi) and not na(lo) and low <= hi and high >= lo

// 1. Check Historical Untested Levels
if allLevels.size() > 0
    for i = 0 to allLevels.size() - 1
        Level lvl = allLevels.get(i)
        bool activeOrJustTested = not lvl.isTested or (lvl.isTested and lvl.testedTime == time)
        if activeOrJustTested
            if str.contains(lvl.sessionName, "Low")
                if low <= lvl.price and math.min(open, close) > lvl.price and close[1] > lvl.price and not touchesORB
                    isSweepCandle := true
            if str.contains(lvl.sessionName, "High")
                if high >= lvl.price and math.max(open, close) < lvl.price and close[1] < lvl.price and not touchesORB
                    isSweepCandleShort := true

// 2. Check Dynamic Session Lows/Highs (Active sessions overlapping with current time)
if inLondon and not newLondon and not na(londonLow[1]) and not na(londonStart[1])
    if (time - londonStart[1]) >= 1800000
        if low <= londonLow[1] and math.min(open, close) > londonLow[1] and close[1] > londonLow[1] and not touchesORB
            isSweepCandle := true

if inLondon and not newLondon and not na(londonHigh[1]) and not na(londonStart[1])
    if (time - londonStart[1]) >= 1800000 // roughly 30m offset using session start
        if high >= londonHigh[1] and math.max(open, close) < londonHigh[1] and close[1] < londonHigh[1] and not touchesORB
            isSweepCandleShort := true

bool isConfirmation = isSweepCandle[1] and close > open and not touchesORB
bool isConfirmationShort = isSweepCandleShort[1] and close < open and not touchesORB

bool canTradeLong = enableKLLongs and inTradingSession and not tradeExecutedToday
bool canTradeShort = enableKLShorts and inTradingSession and not tradeExecutedToday

if canTradeLong
    if isConfirmation
        // strategy.entry("KL Long", strategy.long)
        label.new(bar_index, low, "B", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
        float longStop = close - stopLossPoints
        float longProfit = close + takeProfitPoints
        // strategy.exit("KL Long Exit", "KL Long", stop=longStop, limit=longProfit)
        tradeExecutedToday := true

if canTradeShort
    if isConfirmationShort
        // strategy.entry("KL Short", strategy.short)
        label.new(bar_index, high, "S", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
        float shortStop = close + stopLossPoints
        float shortProfit = close - takeProfitPoints
        // strategy.exit("KL Short Exit", "KL Short", stop=shortStop, limit=shortProfit)
        tradeExecutedToday := true

// --- ORB Long Logic ---
var int orbState = 0
var int orbShortState = 0
var bool orbTradeExecutedToday = false
var bool signalDrawnToday = false

if ta.change(time("D", tz)) != 0
    orbState := 0
    orbShortState := 0
    orbTradeExecutedToday := false
    signalDrawnToday := false

bool orbTimeWindow = (hour(time, tz) > 9 or (hour(time, tz) == 9 and minute(time, tz) >= 30)) and hour(time, tz) < 12
bool orbRangeTooBig = not na(hi) and not na(lo) and (hi - lo) >= 20.0

bool bullishSignalAlert = false
bool bearishSignalAlert = false
bool midpointTouchAlert = false
bool midpointTouchShortAlert = false

if showSignalCandleLabel and not signalDrawnToday and orbTimeWindow and not orbRangeTooBig and not na(hi) and not na(lo)
    if close > hi and close > open
        label.new(bar_index, low, "BO", style=label.style_label_up, color=color.new(color.yellow, 0), textcolor=color.black, size=size.small)
        signalDrawnToday := true
        bullishSignalAlert := true
    else if close < lo and close < open
        label.new(bar_index, high, "BO", style=label.style_label_down, color=color.new(color.yellow, 0), textcolor=color.black, size=size.small)
        signalDrawnToday := true
        bearishSignalAlert := true

if not orbTradeExecutedToday and orbTimeWindow and not orbRangeTooBig and not na(hi) and not na(lo)
    float midY = (hi + lo) / 2.0
    
    // ORB LONG LOGIC
    if enableORBLongs
        if orbState == 0
            if close > hi and close > open
                orbState := 1
        else if orbState == 1
            if low <= midY
                if close > midY and close < open // Must be a bearish candle
                    if showMidpointLabel
                        label.new(bar_index, low, "M", style=label.style_circle, color=color.new(color.purple, 30), textcolor=color.white, size=size.tiny)
                    midpointTouchAlert := true
                    orbState := 2 // Wait for bullish confirmation
                else
                    orbState := 0 // Invalidated
        else if orbState == 2
            if close > midY and close > open // Bullish confirmation candle
                label.new(bar_index, low, "B", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
                orbTradeExecutedToday := true
                orbState := 3
            else
                orbState := 0

    // ORB SHORT LOGIC
    if enableORBShorts
        if orbShortState == 0
            if close < lo and close < open
                orbShortState := 1
        else if orbShortState == 1
            if high >= midY
                if close < midY and close > open // Must be a bullish candle
                    if showMidpointLabel
                        label.new(bar_index, high, "M", style=label.style_circle, color=color.new(color.purple, 30), textcolor=color.white, size=size.tiny)
                    midpointTouchShortAlert := true
                    orbShortState := 2 // Wait for bearish confirmation
                else
                    orbShortState := 0 // Invalidated
        else if orbShortState == 2
            if close < midY and close < open // Bearish confirmation candle
                label.new(bar_index, high, "S", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)
                orbTradeExecutedToday := true
                orbShortState := 3
            else
                orbShortState := 0

alertcondition(bullishSignalAlert, title="Bullish ORB Signal (B)", message="Bullish ORB Signal (B) Printed")
alertcondition(bearishSignalAlert, title="Bearish ORB Signal (B)", message="Bearish ORB Signal (B) Printed")
alertcondition(midpointTouchAlert, title="ORB Midpoint Touched", message="ORB Midpoint Touched and Closed Above")
alertcondition(midpointTouchShortAlert, title="ORB Midpoint Touched Short", message="ORB Midpoint Touched and Closed Below")

// End of Day Closure (4 PM ET = 16:00 ET, closing at 15:55 ET to be safe)
// if hour(time, tz) == 15 and minute(time, tz) >= 55
//     strategy.close_all(comment="EOD Close")
````

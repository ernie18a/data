<!-- tradingview-pine-id: PUB;c34bb1c748b0474faa71cade396d0400 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Support Resistance Zones

Source: https://www.tradingview.com/script/Ew0LRhby-Advanced-Support-Resistance-Zones/

## Description

Advanced Support Resistance Zone
[https://www.tradingview.com/u/Michael_Fx_Trader/](https://www.tradingview.com/u/Michael_Fx_Trader/)

What This Indicator Is

Advanced Support Resistance Zones is an automatic support and resistance tool that finds the real swing highs and lows on any chart and turns them into live, self-updating price zones instead of plain single-price lines. Each zone is a shaded band with a clear label showing whether it is resistance or support, the exact price level, and how many times price has reacted to it. The single most significant zone on the chart is highlighted separately so the strongest level always stands out. A live dashboard in the corner of the chart summarizes the current structure at a glance, so a trader does not need to manually count zones or measure distances.

[image]https://www.tradingview.com/x/BsrMPQoI/[/image]

Why It Was Built

Manually drawing support and resistance is slow, inconsistent, and different from one trader to the next. Two traders looking at the same chart often mark completely different levels depending on mood and experience. This indicator removes that inconsistency by using a fixed, repeatable method every single time: it looks only at confirmed swing highs and lows, groups nearby ones together into a single zone instead of drawing dozens of overlapping lines, and keeps a running count of how many times each zone has actually mattered to price. The goal is a clean, objective map of the levels that price itself has already proven are important, updated automatically as new data comes in.

How It Works

The engine watches for confirmed swing highs and swing lows using a standard pivot detection method. Every time a new swing high forms, it is treated as a resistance candidate; every new swing low is treated as a support candidate. Instead of creating a brand new zone for every single pivot, the script first checks whether the new pivot is close enough in price to an existing zone of the same type. If it is close enough, the two are merged together using a running weighted average, so the zone's price slowly centers itself on the true average of every touch, and its touch counter goes up by one. If nothing close enough exists yet, a brand new zone is created. Each zone is drawn as a shaded rectangle so its thickness reflects normal market noise around that level rather than being an impossibly thin, unrealistic line.

Every zone also tracks whether price is currently sitting inside it. A touch is only counted the moment price freshly enters the zone after having been outside it, which stops a slow, grinding move through a zone from being counted as dozens of touches. When price fully closes beyond a zone in the opposite direction, the zone is understood to be broken, and because a broken resistance level frequently goes on to act as support afterwards (and the same in reverse for a broken support level), the zone flips its role, resets its touch count, and continues tracking from there rather than disappearing outright. To keep the chart readable, only a limited number of zones are kept active at once; if that limit is ever exceeded, the zone that currently sits farthest away from the live price is removed first, since it is the least relevant to what is happening right now.

[image]https://www.tradingview.com/x/MeGOA6Hm/[/image]

How To Read The Chart

Every zone is labeled directly on its own band. A red label reading RES followed by a price and a touch count is a resistance zone; a green label reading SUP followed by a price and a touch count is a support zone. The number before the small x is simply how many separate times price has reacted to that exact level since the zone was formed, so a zone showing a higher number has been tested and respected more often than one showing a low number. Exactly one zone at a time, the one with the highest touch count among everything currently active, is drawn in a distinct highlight color and marked with a star symbol next to its label, making the single most important level on the chart impossible to miss.

How To Use It For Analysis

Start by identifying where price currently sits relative to the nearest zones above and below it; this alone tells you whether the market has room to move or is already pressing against a meaningful level. When price approaches a zone with a high touch count, treat it with more respect than a fresh, barely-tested one, since it represents a level the market has already agreed on multiple times. Watch for a reaction at the zone, a stall, a wick rejection, or a reversal, as confirmation that the level is holding; a clean close through the zone instead signals that it has broken, at which point the same level flips role and becomes worth watching in the opposite direction going forward. The starred strongest zone deserves the closest attention of all, since it represents the single level the market has interacted with the most. Used this way, the indicator is not a standalone buy or sell signal generator, but a structural map that should be combined with your own entry timing, trend reading, and risk management.

What The Dashboard Shows

The dashboard sits in the corner of the chart and updates on every new bar. The first row shows how many zones are currently active on the chart. The row labeled At Price tells you immediately whether the current price is sitting inside a resistance zone, inside a support zone, or simply between zones with open space on both sides. The Nearest Above row shows the closest resistance zone sitting above the current price, along with how far away it is measured in multiples of average recent volatility, so the same reading means roughly the same thing on a calm day as on a wild one. The Nearest Below row shows the same information for the closest support zone underneath price. The Strongest Shelf row always reports whichever single zone currently has the highest touch count anywhere on the chart, together with its price, so you never have to hunt for it visually. The final row, Structure State, gives a one line plain English summary of the current situation, such as sitting inside resistance, sitting inside support, or ranging between zones.

[image]https://www.tradingview.com/x/Ia4oYVyT/[/image]

Settings Worth Knowing Before Use

The pivot detection sensitivity, the average volatility length used to size and measure zones, how thick each zone band is drawn, how close a new pivot needs to be to merge into an existing zone, how many zones are kept active at once, and every color used can all be adjusted from the indicator's settings panel to suit different instruments, timeframes, and personal preferences.

Disclaimer

This indicator is a technical analysis tool and does not constitute financial advice. Touch counts describe how many times price has historically reacted to a level, not a guarantee that it will do so again. All trading involves risk, and past reactions to a level do not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: Advanced Support Resistance Zones
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The pivot clustering zone detection engine, which converges each zone's center using a running weighted average rather than ever expanding boundaries, the touch count based strength tracking, the automatic role reversal logic that flips a broken resistance zone into a support zone and a broken support zone into a resistance zone, the strongest zone highlighting system, and the live information dashboard were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. Support and resistance analysis using swing pivots is a well known, generic technical analysis concept not owned by any individual author; only the specific detection, clustering, scoring, and dashboard logic built around it here is original to this script.
[https://www.tradingview.com/u/Michael_Fx_Trader/](https://www.tradingview.com/u/Michael_Fx_Trader/)

---

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : Advanced Support Resistance Zones
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader. The pivot-clustering zone-detection engine (converging
//   zone centers via a running weighted average rather than ever-expanding
//   boundaries), the touch-count based strength tracking, the automatic
//   role-reversal logic that flips a broken resistance zone into a support
//   zone (and vice versa), the strongest-zone highlighting system, and the
//   live "Auto S/R" style information dashboard were all independently
//   conceived and implemented for this publication. No proprietary source
//   code, private scripts, or copyrighted material belonging to any other
//   author has been copied, mashed-up, or reused in any part of this script.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. Support and resistance analysis via swing
//   pivots is a well-known, generic technical-analysis concept not owned by
//   any individual author; only the specific detection, clustering, scoring,
//   and dashboard logic built around it here is original to this script.
// =============================================================================

indicator("Advanced Support Resistance Zones", shorttitle = "Adv S/R Zones", overlay = true,
     max_boxes_count = 200, max_labels_count = 200, max_lines_count = 100)

// =============================================================================
// INPUTS
// =============================================================================

grpPivot = "Pivot / Zone Detection"
pivotLeft   = input.int(5, "Pivot Left Bars", minval = 1, maxval = 50, group = grpPivot)
pivotRight  = input.int(5, "Pivot Right Bars", minval = 1, maxval = 50, group = grpPivot,
     tooltip = "A swing high/low needs this many bars on each side to confirm, so a new zone appears with a small, expected lag.")
atrLen      = input.int(14, "ATR Length (for zone sizing)", minval = 1, group = grpPivot)
zoneHalfWidthAtr = input.float(0.35, "Zone Half-Width (x ATR)", minval = 0.01, step = 0.01, group = grpPivot,
     tooltip = "Controls how thick each drawn zone band is, in multiples of ATR, on each side of its center. Raise this if zones look too thin to see; lower it for tighter, more precise levels.")
mergeToleranceAtr = input.float(0.6, "Merge Tolerance (x ATR)", minval = 0.05, step = 0.05, group = grpPivot,
     tooltip = "A new pivot merges into an existing zone of the same type if its price is within this many ATRs of that zone's center; otherwise a new zone is created.")

grpZones = "Zone Management"
maxZones    = input.int(25, "Max Zones Stored", minval = 5, maxval = 100, group = grpZones,
     tooltip = "Oldest/weakest zones are removed once this limit is exceeded, purely for performance.")
zoneExtend  = input.int(10, "Zone Extend (bars ahead)", minval = 1, maxval = 50, group = grpZones)
minTouchesToShow = input.int(1, "Minimum Touches to Display a Zone", minval = 1, maxval = 20, group = grpZones)

grpDash = "Dashboard"
showTable   = input.bool(true, "Show Info Dashboard Table", group = grpDash)
tablePos    = input.string("Top Right", "Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDash)

grpColors = "Colors"
resColor        = input.color(color.new(color.red, 55),    "Resistance Zone Color", group = grpColors)
supColor        = input.color(color.new(color.green, 55),  "Support Zone Color",    group = grpColors)
strongestColor  = input.color(color.new(color.yellow, 35), "Strongest Zone Highlight Color", group = grpColors)
resBorder       = input.color(color.new(color.red, 0),     "Resistance Border Color", group = grpColors)
supBorder       = input.color(color.new(color.green, 0),   "Support Border Color",    group = grpColors)

// =============================================================================
// CORE CALCULATIONS
// =============================================================================

atrVal = ta.atr(atrLen)
zoneHalfWidth = atrVal * zoneHalfWidthAtr
mergeTolerance = atrVal * mergeToleranceAtr

ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

// =============================================================================
// ZONE STORAGE (parallel arrays)
// =============================================================================
// zType: 1 = resistance, -1 = support

var float[] zCenter     = array.new_float()
var float[] zTop        = array.new_float()
var float[] zBottom     = array.new_float()
var int[]   zType       = array.new_int()
var int[]   zTouches    = array.new_int()
var bool[]  zWasInside  = array.new_bool()
var int[]   zCreatedBar = array.new_int()
var box[]   zBox        = array.new_box()
var label[] zLabel      = array.new_label()

// =============================================================================
// HELPER: find index of nearest same-type zone within merge tolerance (-1 if none)
// =============================================================================

findMergeIndex(price, targetType) =>
    idx = -1
    minDist = 1e10
    if array.size(zCenter) > 0
        for i = 0 to array.size(zCenter) - 1
            if array.get(zType, i) == targetType
                dist = math.abs(price - array.get(zCenter, i))
                if dist <= mergeTolerance and dist < minDist
                    minDist := dist
                    idx := i
    idx

// =============================================================================
// CREATE OR MERGE A NEW PIVOT INTO A ZONE
// =============================================================================

processPivot(price, targetType, pivotBar) =>
    mIdx = findMergeIndex(price, targetType)
    if mIdx >= 0
        oldCenter = array.get(zCenter, mIdx)
        oldTouches = array.get(zTouches, mIdx)
        newTouches = oldTouches + 1
        newCenter = (oldCenter * oldTouches + price) / newTouches
        array.set(zCenter, mIdx, newCenter)
        array.set(zTop, mIdx, newCenter + zoneHalfWidth)
        array.set(zBottom, mIdx, newCenter - zoneHalfWidth)
        array.set(zTouches, mIdx, newTouches)
    else
        array.push(zCenter, price)
        array.push(zTop, price + zoneHalfWidth)
        array.push(zBottom, price - zoneHalfWidth)
        array.push(zType, targetType)
        array.push(zTouches, 1)
        array.push(zWasInside, false)
        array.push(zCreatedBar, pivotBar)
        array.push(zBox, box.new(left = pivotBar, top = price + zoneHalfWidth, right = bar_index + zoneExtend,
             bottom = price - zoneHalfWidth, border_color = targetType == 1 ? resBorder : supBorder,
             bgcolor = targetType == 1 ? resColor : supColor, extend = extend.none))
        array.push(zLabel, label.new(bar_index + zoneExtend, price, "",
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = targetType == 1 ? resBorder : supBorder, size = size.small))

var bool newResZone = false
var bool newSupZone = false
newResZone := false
newSupZone := false

if not na(ph)
    newResZone := findMergeIndex(ph, 1) < 0
    processPivot(ph, 1, bar_index - pivotRight)

if not na(pl)
    newSupZone := findMergeIndex(pl, -1) < 0
    processPivot(pl, -1, bar_index - pivotRight)

// =============================================================================
// ROLE REVERSAL - a broken zone flips type and resets its touch count
// =============================================================================

if array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        t = array.get(zType, i)
        top = array.get(zTop, i)
        bot = array.get(zBottom, i)
        if t == 1 and close > top
            array.set(zType, i, -1)
            array.set(zTouches, i, 1)
            array.set(zWasInside, i, false)
            box.set_border_color(array.get(zBox, i), supBorder)
            box.set_bgcolor(array.get(zBox, i), supColor)
        else if t == -1 and close < bot
            array.set(zType, i, 1)
            array.set(zTouches, i, 1)
            array.set(zWasInside, i, false)
            box.set_border_color(array.get(zBox, i), resBorder)
            box.set_bgcolor(array.get(zBox, i), resColor)

// =============================================================================
// TOUCH COUNTING - counts one touch per fresh approach into a zone
// =============================================================================

if array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        top = array.get(zTop, i)
        bot = array.get(zBottom, i)
        insideNow = (low <= top) and (high >= bot)
        wasInside = array.get(zWasInside, i)
        if insideNow and not wasInside
            array.set(zTouches, i, array.get(zTouches, i) + 1)
            array.set(zWasInside, i, true)
        else if not insideNow
            array.set(zWasInside, i, false)

// =============================================================================
// FIND STRONGEST ZONE (highest touch count)
// =============================================================================

strongestIdx = -1
strongestTouches = 0
if array.size(zTouches) > 0
    for i = 0 to array.size(zTouches) - 1
        tch = array.get(zTouches, i)
        if tch > strongestTouches
            strongestTouches := tch
            strongestIdx := i

// =============================================================================
// UPDATE VISUALS FOR EVERY ZONE (box extend + label text/position)
// =============================================================================

if array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        touches = array.get(zTouches, i)
        typ = array.get(zType, i)
        top = array.get(zTop, i)
        bot = array.get(zBottom, i)
        mid = (top + bot) / 2.0
        bx = array.get(zBox, i)
        lb = array.get(zLabel, i)
        isStrongest = (i == strongestIdx) and (strongestTouches >= 2)
        meetsMinTouches = touches >= minTouchesToShow

        box.set_right(bx, bar_index + zoneExtend)
        box.set_bgcolor(bx, not meetsMinTouches ? color.new(color.gray, 100) : (isStrongest ? strongestColor : (typ == 1 ? resColor : supColor)))
        box.set_border_color(bx, not meetsMinTouches ? color.new(color.gray, 100) : (typ == 1 ? resBorder : supBorder))
        box.set_border_width(bx, isStrongest ? 2 : 1)

        label.set_xy(lb, bar_index + zoneExtend, mid)
        labelText = not meetsMinTouches ? "" : (typ == 1 ? "RES " : "SUP ") + str.tostring(mid, format.mintick) + "  |  " + str.tostring(touches) + "x" + (isStrongest ? "  \u2605" : "")
        label.set_text(lb, labelText)
        label.set_textcolor(lb, typ == 1 ? resBorder : supBorder)

// =============================================================================
// CLEANUP - remove the zone farthest from the current price once the storage
// limit is exceeded (keeps zones relevant to current price action, instead of
// letting old, far-away zones crowd out fresh ones near the market)
// =============================================================================

if array.size(zTop) > maxZones
    farthestIdx = 0
    farthestDist = -1.0
    for i = 0 to array.size(zTop) - 1
        zc = array.get(zCenter, i)
        dist = math.abs(close - zc)
        if dist > farthestDist
            farthestDist := dist
            farthestIdx := i
    box.delete(array.get(zBox, farthestIdx))
    label.delete(array.get(zLabel, farthestIdx))
    array.remove(zCenter, farthestIdx)
    array.remove(zTop, farthestIdx)
    array.remove(zBottom, farthestIdx)
    array.remove(zType, farthestIdx)
    array.remove(zTouches, farthestIdx)
    array.remove(zWasInside, farthestIdx)
    array.remove(zCreatedBar, farthestIdx)
    array.remove(zBox, farthestIdx)
    array.remove(zLabel, farthestIdx)

// =============================================================================
// LIVE INFO DASHBOARD (updated on the last bar only, for performance)
// =============================================================================

tablePosition = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(position = tablePosition, columns = 2, rows = 6,
     bgcolor = color.new(color.black, 15), border_color = color.new(color.gray, 40), border_width = 1)

if showTable and barstate.islast
    activeZoneCount = array.size(zTop)

    // ---- "At Price" status ----
    atPriceText = "Between Zones"
    for i = 0 to array.size(zTop) - 1
        top = array.get(zTop, i)
        bot = array.get(zBottom, i)
        if close <= top and close >= bot
            typ = array.get(zType, i)
            atPriceText := (typ == 1 ? "Inside Res @" : "Inside Sup @") + str.tostring(close, format.mintick)

    // ---- Nearest Above / Below ----
    var float nearAboveP = na
    var float nearBelowP = na
    nearAboveP := na
    nearBelowP := na
    for i = 0 to array.size(zTop) - 1
        top = array.get(zTop, i)
        bot = array.get(zBottom, i)
        mid = (top + bot) / 2.0
        if bot > close
            if na(nearAboveP) or bot < nearAboveP
                nearAboveP := mid
        if top < close
            if na(nearBelowP) or top > nearBelowP
                nearBelowP := mid

    nearAboveText = na(nearAboveP) ? "None" : "R " + str.tostring(nearAboveP, format.mintick) + " (" + str.tostring((nearAboveP - close) / atrVal, "#.#") + " ATR)"
    nearBelowText = na(nearBelowP) ? "None" : "S " + str.tostring(nearBelowP, format.mintick) + " (" + str.tostring((close - nearBelowP) / atrVal, "#.#") + " ATR)"

    // ---- Strongest Shelf ----
    strongestText = strongestIdx >= 0 ? (array.get(zType, strongestIdx) == 1 ? "R " : "S ") + str.tostring(strongestTouches) + "x @" + str.tostring(array.get(zCenter, strongestIdx), format.mintick) : "None yet"

    // ---- Structure State ----
    structureText = atPriceText == "Between Zones" ? "Ranging Between Zones" : (str.contains(atPriceText, "Res") ? "Inside Resistance" : "Inside Support")

    table.cell(dash, 0, 0, "Advanced S/R", text_color = color.yellow, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(dash, 1, 0, str.tostring(activeZoneCount) + " active zones", text_color = color.white, text_size = size.small)

    table.cell(dash, 0, 1, "At Price", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 1, atPriceText, text_color = color.orange, text_size = size.small)

    table.cell(dash, 0, 2, "Nearest Above", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 2, nearAboveText, text_color = color.new(color.red, 0), text_size = size.small)

    table.cell(dash, 0, 3, "Nearest Below", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 3, nearBelowText, text_color = color.new(color.green, 0), text_size = size.small)

    table.cell(dash, 0, 4, "Strongest Shelf", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 4, strongestText, text_color = color.yellow, text_size = size.small)

    table.cell(dash, 0, 5, "Structure State", text_color = color.gray, text_size = size.small)
    table.cell(dash, 1, 5, structureText, text_color = color.aqua, text_size = size.small)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(newResZone, title = "New Resistance Zone", message = "Advanced Support Resistance Zones: a new resistance zone was formed.")
alertcondition(newSupZone, title = "New Support Zone", message = "Advanced Support Resistance Zones: a new support zone was formed.")
````

# Bastion Ledger [JOAT]

- url: https://www.tradingview.com/script/DWMDu8sv-Bastion-Ledger-JOAT/
- type: indicator
- pine_id: PUB;a2bc0d6d46cb405ba2d60966514a7cbc
- version: 1.0

## Description

[b]Bastion Ledger [JOAT][/b]

[b]Introduction[/b]

Bastion Ledger is an open-source liquidity and structure overlay designed to track active demand and supply zones through a full lifecycle model. The script builds zones from confirmed pivots and volume impulse events, then tracks how price interacts with those zones over time through active, swept, broken, retested, and archived states.

The problem Bastion Ledger solves is zone ambiguity. Many support and resistance tools simply draw a level and leave interpretation to the user. Bastion Ledger adds structure to that process by classifying how each zone was created and what has happened to it since. This makes the chart easier to read and gives the user a cleaner framework for identifying whether liquidity has held, been swept, failed, or transitioned into a retest state.

[image]https://www.tradingview.com/x/DqE34Q7y/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Pivot Structure[/b]

Zones created from pivots only appear after pivot confirmation. This introduces natural delay by design, but it prevents the script from creating forward-looking structure that disappears later.

[b]2. Volume-Impulse Zone Creation[/b]

The script can also create zones from candles that exhibit high relative volume and efficient directional body behavior. This allows the overlay to capture not only swing structure but also displacement-origin areas.

[b]3. Zone Lifecycle Model[/b]

Each zone progresses through a clear state model:

[list]
[*]ACTIVE
[*]SWEEPED
[*]BROKEN
[*]RETESTED
[*]ARCHIVED
[/list]

This is one of the defining features of the script. Instead of leaving historical rectangles behind with no context, the overlay tracks what has happened to each one.

[b]4. Midpoint and Structure Rails[/b]

Every zone can include a midpoint reference and supporting structure rails to make reaction areas easier to inspect. This helps distinguish edge reactions from deeper zone acceptance.

[b]5. Dashboard Context[/b]

The top-right dashboard summarizes active counts, nearest demand and supply distance, event state, and structure bias so the user can quickly orient themselves.

[b]Features[/b]

[list]
[*][b]Dual-source zone creation:[/b] Confirmed pivots and volume impulse zones
[*][b]Stateful zone lifecycle:[/b] Tracks sweeps, breaks, retests, and archival
[*][b]ATR-aware zone sizing:[/b] Zone height adapts to market conditions
[*][b]Object-efficient rendering:[/b] Uses persistent objects with setter updates
[*][b]Midpoint lines:[/b] Helps judge reaction depth inside each zone
[*][b]Structure bias readout:[/b] Gives a quick demand-versus-supply view
[*][b]Nearest-zone distance readout:[/b] Useful for contextual planning
[*][b]Top-right dashboard:[/b] Medium-size summary panel
[*][b]Confirmed-bar event logic:[/b] Creation and transitions are handled safely
[*][b]Alertconditions:[/b] Zone create, sweep, break, retest, and structure breaks
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Nearest Active Zone[/b]
Use the plotted boxes and dashboard distance readouts to locate the nearest demand and supply area.

[b]Step 2: Read the Zone State[/b]
An active zone is different from a swept or broken zone. The lifecycle state tells you whether the zone is still intact or has already lost integrity.

[b]Step 3: Watch Retests After Breaks[/b]
Retested zones can be especially useful because they represent a transition from defended liquidity to broken structure and then a recheck of that failure.

[b]Step 4: Combine with Regime Context[/b]
Bastion Ledger works best when combined with a separate trend or regime filter. Use it to map where reactions matter, not to replace directional context.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based zones confirm after the pivot completes, which is intentional non-repainting behavior
[*]Very fast markets can move through multiple zone states in a short number of bars
[*]Zone relevance declines over time, so older archived zones should not be treated like fresh liquidity
[*]This script tracks structural interaction, not order flow or real exchange-level liquidity
[/list]

[b]Originality Statement[/b]

Bastion Ledger is original in its combination of pivot structure, volume-impulse zone creation, and lifecycle classification. The script is not just a rectangle drawer. Its core value lies in tracking how a zone evolves after creation and presenting that evolution in a consistent institutional overlay.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Liquidity zones are interpretive tools based on historical price and volume behavior and do not guarantee future reactions.

- Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Bastion Ledger [JOAT]", shorttitle = "BSL [JOAT]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 200)

//------------------------------------------------------------------------------
// Bastion Ledger [JOAT]
//------------------------------------------------------------------------------
// Architecture summary:
// 1) Build liquidity zones from confirmed pivot structure + volume impulses.
// 2) Track each zone through lifecycle states:
//    ACTIVE -> SWEEPED -> BROKEN -> RETESTED -> ARCHIVED.
// 3) Keep zones non-repainting by:
//    - creating pivot zones only after pivot confirmation,
//    - using confirmed-bar checks for break/sweep/retest events.
// 4) Render an institutional-style overlay:
//    - translucent zones,
//    - midpoint lines,
//    - structure rails,
//    - medium top-right dashboard.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Constants and enum-like state definitions
//------------------------------------------------------------------------------
int Z_ACTIVE = 0
int Z_SWEEPED = 1
int Z_BROKEN = 2
int Z_RETESTED = 3
int Z_ARCHIVED = 4

int SRC_PIVOT = 1
int SRC_VOLUME = 2
int SRC_HYBRID = 3

//------------------------------------------------------------------------------
// Inputs: Core Detection
//------------------------------------------------------------------------------
groupCore = "Core Detection"
pivotLeft = input.int(5, "Pivot Left Bars", minval = 1, group = groupCore)
pivotRight = input.int(5, "Pivot Right Bars", minval = 1, group = groupCore)
useVolumeGate = input.bool(true, "Require Volume Boost On Pivot Zones", group = groupCore)
volumeGateMult = input.float(1.2, "Pivot Volume Boost Multiplier", minval = 0.1, step = 0.1, group = groupCore)
volSmaLength = input.int(30, "Volume SMA Length", minval = 1, group = groupCore)
volImpulseMult = input.float(1.8, "Impulse Zone Volume Multiplier", minval = 0.2, step = 0.1, group = groupCore)
impulseBodyMin = input.float(0.45, "Impulse Min Body/Range", minval = 0.05, maxval = 0.95, step = 0.05, group = groupCore)

//------------------------------------------------------------------------------
// Inputs: Geometry and Lifecycle
//------------------------------------------------------------------------------
groupLifecycle = "Zone Lifecycle"
atrLen = input.int(14, "ATR Length", minval = 1, group = groupLifecycle)
pivotAtrPad = input.float(0.20, "Pivot Zone ATR Padding", minval = 0.0, step = 0.01, group = groupLifecycle)
impulseAtrPad = input.float(0.15, "Impulse Zone ATR Padding", minval = 0.0, step = 0.01, group = groupLifecycle)
minZoneTicks = input.int(6, "Minimum Zone Height (Ticks)", minval = 1, group = groupLifecycle)
zoneLifeBars = input.int(450, "Zone Active Life (Bars)", minval = 50, group = groupLifecycle)
archiveGraceBars = input.int(160, "Archive Grace Bars", minval = 10, group = groupLifecycle)
maxZones = input.int(80, "Max Stored Zones", minval = 20, maxval = 200, group = groupLifecycle)
breakMode = input.string("Confirmed Close", "Break Trigger", options = ["Confirmed Close", "Confirmed Wick"], group = groupLifecycle)
retestWindowBars = input.int(55, "Retest Confirmation Window", minval = 3, group = groupLifecycle)
enableSweepTracking = input.bool(true, "Track Liquidity Sweeps", group = groupLifecycle)
overlapToleranceAtr = input.float(0.08, "Overlap Tolerance (ATR)", minval = 0.0, step = 0.01, group = groupLifecycle)
sameTypeOverlapFilter = input.float(0.20, "Same-Type Overlap Filter", minval = 0.0, step = 0.01, group = groupLifecycle)

//------------------------------------------------------------------------------
// Inputs: Structure Context
//------------------------------------------------------------------------------
groupStructure = "Structure Context"
showStructureRails = input.bool(true, "Show Last Confirmed Structure Rails", group = groupStructure)
enableStructureBias = input.bool(true, "Enable Structure Bias State", group = groupStructure)
structureRailWidth = input.int(1, "Structure Rail Width", minval = 1, maxval = 4, group = groupStructure)

//------------------------------------------------------------------------------
// Inputs: Visualization
//------------------------------------------------------------------------------
groupVisual = "Visual Theme"
bullBorder = input.color(color.rgb(30, 189, 138), "Bullish Border", group = groupVisual)
bullFill = input.color(color.new(color.rgb(30, 189, 138), 84), "Bullish Fill", group = groupVisual)
bearBorder = input.color(color.rgb(217, 88, 75), "Bearish Border", group = groupVisual)
bearFill = input.color(color.new(color.rgb(217, 88, 75), 84), "Bearish Fill", group = groupVisual)
neutralBorder = input.color(color.rgb(104, 122, 144), "Neutral Border", group = groupVisual)
neutralFill = input.color(color.new(color.rgb(104, 122, 144), 88), "Neutral Fill", group = groupVisual)
sweepBorder = input.color(color.rgb(232, 171, 74), "Sweep Border", group = groupVisual)
sweepFill = input.color(color.new(color.rgb(232, 171, 74), 86), "Sweep Fill", group = groupVisual)
retestBorder = input.color(color.rgb(84, 154, 255), "Retest Border", group = groupVisual)
retestFill = input.color(color.new(color.rgb(84, 154, 255), 84), "Retest Fill", group = groupVisual)
midlineTransp = input.int(65, "Midline Transparency", minval = 0, maxval = 100, group = groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group = groupVisual)
dashboardText = input.color(color.rgb(220, 228, 240), "Dashboard Text Color", group = groupVisual)
dashboardBg = input.color(color.new(color.rgb(17, 23, 34), 12), "Dashboard Background", group = groupVisual)
showZoneLabels = input.bool(true, "Show Zone Labels", group = groupVisual)
maxZoneLabels = input.int(10, "Max Zone Labels", minval = 2, maxval = 30, group = groupVisual)
labelOffsetBars = input.int(3, "Label Offset Bars", minval = 1, maxval = 20, group = groupVisual)

//------------------------------------------------------------------------------
// Utility calculations
//------------------------------------------------------------------------------
atr = ta.atr(atrLen)
volSma = ta.sma(volume, volSmaLength)
minZoneHeight = syminfo.mintick * minZoneTicks
breakOnClose = breakMode == "Confirmed Close"

//------------------------------------------------------------------------------
// Persistent zone storage arrays
//------------------------------------------------------------------------------
var array<float> zoneTop = array.new_float()
var array<float> zoneBottom = array.new_float()
var array<float> zoneMid = array.new_float()
var array<int> zoneStartBar = array.new_int()
var array<int> zoneType = array.new_int()             // +1 demand, -1 supply
var array<int> zoneSource = array.new_int()           // SRC_PIVOT / SRC_VOLUME / SRC_HYBRID
var array<int> zoneState = array.new_int()            // Z_ACTIVE..Z_ARCHIVED
var array<int> zoneBreakDir = array.new_int()         // +1 up break, -1 down break
var array<int> zoneBreakBar = array.new_int()
var array<int> zoneSweepBar = array.new_int()
var array<int> zoneRetestBar = array.new_int()
var array<float> zoneVolScore = array.new_float()
var array<box> zoneBox = array.new_box()
var array<line> zoneMidLine = array.new_line()

//------------------------------------------------------------------------------
// Structure memory
//------------------------------------------------------------------------------
var float lastConfirmedSwingHigh = na
var float lastConfirmedSwingLow = na
var int structureBias = 0               // +1 bullish, -1 bearish, 0 neutral
var int lastStructureBreakBar = na

//------------------------------------------------------------------------------
// Event flags (series bool for alertcondition)
//------------------------------------------------------------------------------
var bool evtZoneCreated = false
var bool evtZoneBroken = false
var bool evtZoneSwept = false
var bool evtZoneRetested = false
var bool evtStructureBullBreak = false
var bool evtStructureBearBreak = false

evtZoneCreated := false
evtZoneBroken := false
evtZoneSwept := false
evtZoneRetested := false
evtStructureBullBreak := false
evtStructureBearBreak := false

//------------------------------------------------------------------------------
// Color helpers
//------------------------------------------------------------------------------
f_border_color(int zType, int zState) =>
    color result = neutralBorder
    if zState == Z_SWEEPED
        result := sweepBorder
    else if zState == Z_RETESTED
        result := retestBorder
    else if zState == Z_ARCHIVED or zState == Z_BROKEN
        result := neutralBorder
    else
        result := zType == 1 ? bullBorder : bearBorder
    result

f_fill_color(int zType, int zState) =>
    color result = neutralFill
    if zState == Z_SWEEPED
        result := sweepFill
    else if zState == Z_RETESTED
        result := retestFill
    else if zState == Z_ARCHIVED
        result := color.new(neutralFill, 92)
    else if zState == Z_BROKEN
        result := color.new(neutralFill, 88)
    else
        result := zType == 1 ? bullFill : bearFill
    result

f_mid_color(int zType, int zState) =>
    color result = color.new(neutralBorder, midlineTransp)
    if zState == Z_SWEEPED
        result := color.new(sweepBorder, midlineTransp)
    else if zState == Z_RETESTED
        result := color.new(retestBorder, midlineTransp)
    else if zState == Z_BROKEN or zState == Z_ARCHIVED
        result := color.new(neutralBorder, midlineTransp)
    else
        result := color.new(zType == 1 ? bullBorder : bearBorder, midlineTransp)
    result

f_state_text(int zState) =>
    zState == Z_ACTIVE ? "ACTIVE" : zState == Z_SWEEPED ? "SWEEPED" : zState == Z_BROKEN ? "BROKEN" : zState == Z_RETESTED ? "RETESTED" : "ARCHIVED"

f_source_text(int zSource) =>
    zSource == SRC_PIVOT ? "PIVOT" : zSource == SRC_VOLUME ? "VOLUME" : "HYBRID"

//------------------------------------------------------------------------------
// Object lifecycle helpers
//------------------------------------------------------------------------------
f_delete_zone_objects(int idx) =>
    box bx = array.get(zoneBox, idx)
    line ml = array.get(zoneMidLine, idx)
    if not na(bx)
        box.delete(bx)
    if not na(ml)
        line.delete(ml)

f_remove_zone(int idx) =>
    f_delete_zone_objects(idx)
    array.remove(zoneTop, idx)
    array.remove(zoneBottom, idx)
    array.remove(zoneMid, idx)
    array.remove(zoneStartBar, idx)
    array.remove(zoneType, idx)
    array.remove(zoneSource, idx)
    array.remove(zoneState, idx)
    array.remove(zoneBreakDir, idx)
    array.remove(zoneBreakBar, idx)
    array.remove(zoneSweepBar, idx)
    array.remove(zoneRetestBar, idx)
    array.remove(zoneVolScore, idx)
    array.remove(zoneBox, idx)
    array.remove(zoneMidLine, idx)

f_trim_zones() =>
    while array.size(zoneTop) > maxZones
        int idxToRemove = na
        // Prefer to remove archived zones first.
        for i = 0 to array.size(zoneTop) - 1
            if array.get(zoneState, i) == Z_ARCHIVED
                idxToRemove := i
                break
        if na(idxToRemove)
            idxToRemove := 0
        f_remove_zone(idxToRemove)

//------------------------------------------------------------------------------
// Overlap control and zone creation
//------------------------------------------------------------------------------
f_zone_overlap(float topNew, float botNew, int typeNew) =>
    bool overlapped = false
    float tol = atr * overlapToleranceAtr
    if array.size(zoneTop) > 0
        for i = 0 to array.size(zoneTop) - 1
            int st = array.get(zoneState, i)
            int zt = array.get(zoneType, i)
            if st != Z_ARCHIVED and zt == typeNew
                float t = array.get(zoneTop, i)
                float b = array.get(zoneBottom, i)
                float overlapHeight = math.max(0.0, math.min(topNew, t) - math.max(botNew, b))
                float refHeight = math.max(topNew - botNew, t - b)
                bool intersects = overlapHeight > 0 and overlapHeight / math.max(refHeight, syminfo.mintick) >= sameTypeOverlapFilter
                intersects := intersects or math.max(botNew, b) <= math.min(topNew, t) + tol
                if intersects
                    overlapped := true
                    break
    overlapped

f_zone_state_text(int st) =>
    st == Z_ACTIVE ? "ACTIVE" : st == Z_SWEEPED ? "SWEEP" : st == Z_BROKEN ? "BROKEN" : st == Z_RETESTED ? "RETEST" : "ARCHIVE"

f_zone_source_text(int src) =>
    src == SRC_PIVOT ? "Pivot" : src == SRC_VOLUME ? "Volume" : "Hybrid"

f_zone_label_text(int idx) =>
    int zt = array.get(zoneType, idx)
    int st = array.get(zoneState, idx)
    int src = array.get(zoneSource, idx)
    float zTop = array.get(zoneTop, idx)
    float zBot = array.get(zoneBottom, idx)
    float zMid = array.get(zoneMid, idx)
    float volScore = array.get(zoneVolScore, idx)
    string sideText = zt == 1 ? "Demand" : "Supply"
    sideText + " " + f_zone_state_text(st) + "\nTop " + str.tostring(zTop, format.mintick) + "\nMid " + str.tostring(zMid, format.mintick) + "\nBot " + str.tostring(zBot, format.mintick) + "\nVol " + str.tostring(volScore, "#.##") + "x\n" + f_zone_source_text(src)

f_create_zone(float topRaw, float botRaw, int zType, int zSource, float volScore, int startIdx) =>
    bool created = false
    float topVal = math.max(topRaw, botRaw)
    float botVal = math.min(topRaw, botRaw)
    float padIfNeeded = minZoneHeight - (topVal - botVal)
    if padIfNeeded > 0
        topVal += padIfNeeded * 0.5
        botVal -= padIfNeeded * 0.5
    float midVal = (topVal + botVal) * 0.5

    if not f_zone_overlap(topVal, botVal, zType)
        color borderCol = f_border_color(zType, Z_ACTIVE)
        color fillCol = f_fill_color(zType, Z_ACTIVE)
        color midCol = f_mid_color(zType, Z_ACTIVE)

        box bx = box.new(startIdx, topVal, bar_index + 1, botVal, border_color = borderCol, border_width = 2, bgcolor = fillCol, xloc = xloc.bar_index)
        line ml = line.new(startIdx, midVal, bar_index + 1, midVal, xloc = xloc.bar_index, color = midCol, style = line.style_dashed, width = 1)

        array.push(zoneTop, topVal)
        array.push(zoneBottom, botVal)
        array.push(zoneMid, midVal)
        array.push(zoneStartBar, startIdx)
        array.push(zoneType, zType)
        array.push(zoneSource, zSource)
        array.push(zoneState, Z_ACTIVE)
        array.push(zoneBreakDir, 0)
        array.push(zoneBreakBar, na)
        array.push(zoneSweepBar, na)
        array.push(zoneRetestBar, na)
        array.push(zoneVolScore, volScore)
        array.push(zoneBox, bx)
        array.push(zoneMidLine, ml)
        f_trim_zones()
        created := true
    created

//------------------------------------------------------------------------------
// Confirmed pivot detection and structure memory update
//------------------------------------------------------------------------------
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

if barstate.isconfirmed
    if not na(pivotHigh)
        lastConfirmedSwingHigh := pivotHigh
        int pBarH = bar_index - pivotRight
        float bodyAnchorH = math.max(open[pivotRight], close[pivotRight])
        float padH = atr[pivotRight] * pivotAtrPad
        float topH = pivotHigh + padH * 0.18
        float botH = bodyAnchorH - padH * 0.10
        float volScoreH = volSma[pivotRight] > 0 ? volume[pivotRight] / volSma[pivotRight] : 1.0
        bool allowH = not useVolumeGate or volScoreH >= volumeGateMult
        if allowH
            bool createdH = f_create_zone(topH, botH, -1, SRC_PIVOT, volScoreH, pBarH)
            evtZoneCreated := evtZoneCreated or createdH

    if not na(pivotLow)
        lastConfirmedSwingLow := pivotLow
        int pBarL = bar_index - pivotRight
        float bodyAnchorL = math.min(open[pivotRight], close[pivotRight])
        float padL = atr[pivotRight] * pivotAtrPad
        float topL = bodyAnchorL + padL * 0.10
        float botL = pivotLow - padL * 0.18
        float volScoreL = volSma[pivotRight] > 0 ? volume[pivotRight] / volSma[pivotRight] : 1.0
        bool allowL = not useVolumeGate or volScoreL >= volumeGateMult
        if allowL
            bool createdL = f_create_zone(topL, botL, 1, SRC_PIVOT, volScoreL, pBarL)
            evtZoneCreated := evtZoneCreated or createdL

//------------------------------------------------------------------------------
// Impulse zone creation (volume + body efficiency)
//------------------------------------------------------------------------------
barRange = math.max(high - low, syminfo.mintick)
bodySize = math.abs(close - open)
bodyEfficiency = bodySize / barRange
impulseVol = volSma > 0 ? volume / volSma : 0.0
isImpulse = barstate.isconfirmed and impulseVol >= volImpulseMult and bodyEfficiency >= impulseBodyMin

if isImpulse
    float p = atr * impulseAtrPad
    bool bullishImpulse = close >= open
    int zTypeI = bullishImpulse ? 1 : -1
    float topI = bullishImpulse ? math.max(open, close) + p * 0.08 : high + p * 0.16
    float botI = bullishImpulse ? low - p * 0.16 : math.min(open, close) - p * 0.08
    bool createdI = f_create_zone(topI, botI, zTypeI, SRC_VOLUME, impulseVol, bar_index)
    evtZoneCreated := evtZoneCreated or createdI

//------------------------------------------------------------------------------
// Structure break context (non-repainting: confirmed bar condition)
//------------------------------------------------------------------------------
if enableStructureBias and barstate.isconfirmed
    bool bullStructureBreak = not na(lastConfirmedSwingHigh) and close > lastConfirmedSwingHigh and close[1] <= lastConfirmedSwingHigh
    bool bearStructureBreak = not na(lastConfirmedSwingLow) and close < lastConfirmedSwingLow and close[1] >= lastConfirmedSwingLow
    if bullStructureBreak
        structureBias := 1
        lastStructureBreakBar := bar_index
        evtStructureBullBreak := true
    if bearStructureBreak
        structureBias := -1
        lastStructureBreakBar := bar_index
        evtStructureBearBreak := true

//------------------------------------------------------------------------------
// Zone state machine and object updates
//------------------------------------------------------------------------------
if array.size(zoneTop) > 0
    for i = 0 to array.size(zoneTop) - 1
        int st = array.get(zoneState, i)
        int stBar = array.get(zoneStartBar, i)
        int zType = array.get(zoneType, i)
        float zTop = array.get(zoneTop, i)
        float zBot = array.get(zoneBottom, i)
        float zMid = array.get(zoneMid, i)
        box bx = array.get(zoneBox, i)
        line ml = array.get(zoneMidLine, i)
        bool isDemand = zType == 1

        // Extend active visualization while zone is within lifecycle horizon.
        if st != Z_ARCHIVED
            int rightEdge = math.min(bar_index + 1, stBar + zoneLifeBars)
            if not na(bx)
                box.set_right(bx, rightEdge)
            if not na(ml)
                line.set_x2(ml, rightEdge)

        // Automatic archiving once lifecycle expires.
        if st != Z_ARCHIVED and bar_index - stBar > zoneLifeBars
            array.set(zoneState, i, Z_ARCHIVED)
            st := Z_ARCHIVED

        // Event logic only for non-archived zones and confirmed bars.
        if st != Z_ARCHIVED and barstate.isconfirmed
            bool breakCond = breakOnClose ? (isDemand ? close < zBot : close > zTop) : (isDemand ? low < zBot : high > zTop)
            bool sweepCond = enableSweepTracking and st == Z_ACTIVE and (isDemand ? (low < zBot and close >= zBot) : (high > zTop and close <= zTop))

            // Sweep is tracked first for wick-penetration reclaim behavior.
            if sweepCond
                array.set(zoneState, i, Z_SWEEPED)
                array.set(zoneSweepBar, i, bar_index)
                evtZoneSwept := true
                st := Z_SWEEPED

            // Break logic can transition ACTIVE or SWEEPED zones to BROKEN.
            if (st == Z_ACTIVE or st == Z_SWEEPED) and breakCond
                array.set(zoneState, i, Z_BROKEN)
                int breakDir = isDemand ? -1 : 1
                array.set(zoneBreakDir, i, breakDir)
                array.set(zoneBreakBar, i, bar_index)
                evtZoneBroken := true
                st := Z_BROKEN

            // Retest confirmation only after break.
            if st == Z_BROKEN
                int bBar = array.get(zoneBreakBar, i)
                int bDir = array.get(zoneBreakDir, i)
                bool withinWindow = not na(bBar) and bar_index - bBar <= retestWindowBars
                bool retestCond = bDir == 1 ? (low <= zTop and close > zTop) : (high >= zBot and close < zBot)
                if withinWindow and retestCond
                    array.set(zoneState, i, Z_RETESTED)
                    array.set(zoneRetestBar, i, bar_index)
                    evtZoneRetested := true
                    st := Z_RETESTED

        // Apply state visuals via object setters (object-efficient, no redraw flood).
        if not na(bx)
            box.set_border_color(bx, f_border_color(zType, st))
            box.set_bgcolor(bx, f_fill_color(zType, st))
            box.set_border_width(bx, st == Z_RETESTED ? 3 : st == Z_BROKEN ? 1 : 2)
        if not na(ml)
            line.set_color(ml, f_mid_color(zType, st))
            line.set_style(ml, st == Z_BROKEN ? line.style_dotted : line.style_dashed)
            line.set_y1(ml, zMid)
            line.set_y2(ml, zMid)

//------------------------------------------------------------------------------
// Cleanup pass: remove long-expired archived zones (reverse loop safe removal)
//------------------------------------------------------------------------------
if array.size(zoneTop) > 0
    for i = array.size(zoneTop) - 1 to 0
        int st = array.get(zoneState, i)
        int sb = array.get(zoneStartBar, i)
        bool staleArchive = st == Z_ARCHIVED and bar_index - sb > zoneLifeBars + archiveGraceBars
        if staleArchive
            f_remove_zone(i)

//------------------------------------------------------------------------------
// Dashboard metrics
//------------------------------------------------------------------------------
int demandCount = 0
int supplyCount = 0
int sweptCount = 0
int brokenCount = 0
int retestedCount = 0

float nearestSupply = na
float nearestDemand = na

if array.size(zoneTop) > 0
    for i = 0 to array.size(zoneTop) - 1
        int st = array.get(zoneState, i)
        int zt = array.get(zoneType, i)
        float t = array.get(zoneTop, i)
        float b = array.get(zoneBottom, i)
        if st != Z_ARCHIVED
            if zt == 1
                demandCount += 1
                if b < close
                    float distD = close - b
                    nearestDemand := na(nearestDemand) ? distD : math.min(nearestDemand, distD)
            if zt == -1
                supplyCount += 1
                if t > close
                    float distS = t - close
                    nearestSupply := na(nearestSupply) ? distS : math.min(nearestSupply, distS)
        if st == Z_SWEEPED
            sweptCount += 1
        if st == Z_BROKEN
            brokenCount += 1
        if st == Z_RETESTED
            retestedCount += 1

string biasText = structureBias == 1 ? "BULLISH" : structureBias == -1 ? "BEARISH" : "NEUTRAL"
color biasColor = structureBias == 1 ? bullBorder : structureBias == -1 ? bearBorder : neutralBorder
string nearSupplyText = na(nearestSupply) ? "n/a" : str.tostring(nearestSupply / syminfo.mintick, "#") + "t"
string nearDemandText = na(nearestDemand) ? "n/a" : str.tostring(nearestDemand / syminfo.mintick, "#") + "t"
string impulseText = str.tostring(impulseVol, "#.##") + "x"

//------------------------------------------------------------------------------
// Bounded last-bar zone labels placed just outside the boxes
//------------------------------------------------------------------------------
var array<label> zoneLabels = array.new_label()
if barstate.islast
    if array.size(zoneLabels) > 0
        for i = array.size(zoneLabels) - 1 to 0
            label.delete(array.get(zoneLabels, i))
            array.remove(zoneLabels, i)

    if showZoneLabels and array.size(zoneTop) > 0
        int labelsPlaced = 0
        for i = array.size(zoneTop) - 1 to 0
            if labelsPlaced >= maxZoneLabels
                break
            int st = array.get(zoneState, i)
            if st != Z_ARCHIVED
                int zt = array.get(zoneType, i)
                float zTop = array.get(zoneTop, i)
                float zBot = array.get(zoneBottom, i)
                float yPad = atr * 0.10 * (labelsPlaced % 3)
                float yPos = zt == 1 ? zBot - yPad : zTop + yPad
                color labelBase = f_border_color(zt, st)
                color labelBg = color.from_gradient(labelsPlaced, 0, math.max(maxZoneLabels - 1, 1), color.new(labelBase, 8), color.new(labelBase, 28))
                label lb = label.new(bar_index + labelOffsetBars, yPos, f_zone_label_text(i), xloc = xloc.bar_index, style = zt == 1 ? label.style_label_up : label.style_label_down, color = labelBg, textcolor = color.white, size = size.tiny)
                array.push(zoneLabels, lb)
                labelsPlaced += 1

//------------------------------------------------------------------------------
// Optional structure rails for context (non-cluttered)
//------------------------------------------------------------------------------
plot(showStructureRails ? lastConfirmedSwingHigh : na, "Structure High Rail", color = color.new(bearBorder, 70), linewidth = structureRailWidth, style = plot.style_linebr)
plot(showStructureRails ? lastConfirmedSwingLow : na, "Structure Low Rail", color = color.new(bullBorder, 70), linewidth = structureRailWidth, style = plot.style_linebr)

//------------------------------------------------------------------------------
// Dashboard rendering (medium table, top-right)
//------------------------------------------------------------------------------
if showDashboard
    var table dash = table.new(position.top_right, 2, 10, border_width = 1, border_color = color.new(neutralBorder, 35), bgcolor = dashboardBg)
    headerBg = color.new(color.rgb(26, 37, 63), 2)
    accentBg = color.new(color.rgb(54, 88, 148), 20)
    rowBgA = color.new(color.rgb(17, 24, 38), 8)
    rowBgB = color.new(color.rgb(24, 33, 52), 14)
    if barstate.islast
        table.cell(dash, 0, 0, "Bastion Ledger", text_color = dashboardText, text_size = size.small, bgcolor = headerBg)
        table.cell(dash, 1, 0, "JOAT", text_color = dashboardText, text_size = size.small, bgcolor = headerBg)

        table.cell(dash, 0, 1, "Structure Bias", text_color = dashboardText, bgcolor = accentBg)
        table.cell(dash, 1, 1, biasText, text_color = color.white, bgcolor = color.new(biasColor, 60))

        table.cell(dash, 0, 2, "Demand Zones", text_color = dashboardText, bgcolor = rowBgA)
        table.cell(dash, 1, 2, str.tostring(demandCount), text_color = bullBorder, bgcolor = rowBgA)

        table.cell(dash, 0, 3, "Supply Zones", text_color = dashboardText, bgcolor = rowBgB)
        table.cell(dash, 1, 3, str.tostring(supplyCount), text_color = bearBorder, bgcolor = rowBgB)

        table.cell(dash, 0, 4, "Swept / Broken", text_color = dashboardText, bgcolor = rowBgA)
        table.cell(dash, 1, 4, str.tostring(sweptCount) + " / " + str.tostring(brokenCount), text_color = sweepBorder, bgcolor = rowBgA)

        table.cell(dash, 0, 5, "Retested", text_color = dashboardText, bgcolor = rowBgB)
        table.cell(dash, 1, 5, str.tostring(retestedCount), text_color = retestBorder, bgcolor = rowBgB)

        table.cell(dash, 0, 6, "Nearest Supply", text_color = dashboardText, bgcolor = rowBgA)
        table.cell(dash, 1, 6, nearSupplyText, text_color = bearBorder, bgcolor = rowBgA)

        table.cell(dash, 0, 7, "Nearest Demand", text_color = dashboardText, bgcolor = rowBgB)
        table.cell(dash, 1, 7, nearDemandText, text_color = bullBorder, bgcolor = rowBgB)

        table.cell(dash, 0, 8, "Impulse Vol", text_color = dashboardText, bgcolor = rowBgA)
        table.cell(dash, 1, 8, impulseText, text_color = color.rgb(198, 211, 232), bgcolor = rowBgA)

        table.cell(dash, 0, 9, "Events This Bar", text_color = dashboardText, bgcolor = rowBgB)
        string evtText = (evtZoneCreated ? "C" : "-") + " " + (evtZoneBroken ? "B" : "-") + " " + (evtZoneSwept ? "S" : "-") + " " + (evtZoneRetested ? "R" : "-")
        table.cell(dash, 1, 9, evtText, text_color = color.white, bgcolor = color.new(color.rgb(44, 55, 78), 35))

//------------------------------------------------------------------------------
// Alert conditions
//------------------------------------------------------------------------------
alertcondition(evtZoneCreated, "BSL Zone Created", "Bastion Ledger [JOAT]: New liquidity zone created.")
alertcondition(evtZoneBroken, "BSL Zone Broken", "Bastion Ledger [JOAT]: Liquidity zone broken.")
alertcondition(evtZoneSwept, "BSL Zone Swept", "Bastion Ledger [JOAT]: Liquidity sweep detected.")
alertcondition(evtZoneRetested, "BSL Retest Confirmed", "Bastion Ledger [JOAT]: Break retest confirmed.")
alertcondition(evtStructureBullBreak, "BSL Structure Bull Break", "Bastion Ledger [JOAT]: Bullish structure break confirmed.")
alertcondition(evtStructureBearBreak, "BSL Structure Bear Break", "Bastion Ledger [JOAT]: Bearish structure break confirmed.")
````

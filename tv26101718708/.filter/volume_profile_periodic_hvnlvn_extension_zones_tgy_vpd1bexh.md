# Volume Profile Periodic HVN/LVN Extension Zones [TGY]

- url: https://www.tradingview.com/script/Vpd1bExH-Volume-Profile-Periodic-HVN-LVN-Extension-Zones-TGY/
- type: indicator
- pine_id: PUB;d31515efd54f4346a4c7dfe083d994ab
- version: 1.0

## Description

Volume Profile Periodic + HVN/LVN Extension Zones [TrendGenY]

An advanced periodic Volume Profile framework designed to visualize evolving auction structure, granular high-volume concentration, low-volume inefficiencies, and extended liquidity zones.

This indicator expands upon traditional periodic volume profiles by detecting and extending High Volume Nodes (HVNs) and Low Volume Nodes (LVNs) into the future as actionable support, resistance, acceptance, and rejection zones.

Core Features

• Periodic Volume Profiles
Generate automatic profiles by:

Day
Week
Month
Quarter
Year

• Granular Volume Distribution
Enhanced row-based volume allocation creates more precise node detection and cleaner structural mapping.

• High Volume Node (HVN) Detection
Highlights localized areas of heavy participation and acceptance.

• Low Volume Node (LVN) Detection
Highlights low-participation inefficiency zones where price may move aggressively through.

• Extendable HVN/LVN Zones
Node zones can be projected forward as live structure areas using:

X candles
Until next profile period
Until full price cross-through

• Intelligent Full-Cross Logic
Extended zones remain active until price fully traverses the entire node region rather than simply touching it.

• Independent Node Visualization
Hide the volume profile entirely while maintaining active HVN/LVN extension zones.

• Point of Control (POC)

Current POC
Previous POC
Extend-until-cross functionality

• Value Area Tools

VAH / VAL
Extendable value area field
Adjustable transparency and extensions
Practical Use Cases

This indicator is particularly effective for identifying:

• Acceptance vs rejection zones
• Future support/resistance from historical participation
• Price inefficiencies and low-liquidity corridors
• Areas likely to produce reaction or acceleration
• Rotational vs directional environments
• Liquidity magnets and rebalance targets
• Volume-based market structure shifts

HVN vs LVN Interpretation

HVNs often behave as:

Acceptance zones
Rotational magnets
Consolidation areas
Reversion targets

LVNs often behave as:

Inefficiency gaps
Fast-travel regions
Rejection zones
Breakout continuation paths
Recommended Workflow

Many traders use:

HVNs for mean reversion / reaction trades
LVNs for continuation and displacement setups
POC shifts for directional bias
Value area transitions for auction state changes

The ability to extend these zones forward allows the profile to become an evolving structural framework rather than a static historical tool.

Key Settings

• Node Extension Mode

X Candles
Next Period
Until Full Cross

• HVN/LVN Threshold Sensitivity
Adjust how aggressive or selective node detection becomes.

• Local Node Sensitivity
Controls how localized peaks/troughs in participation are identified.

• Show/Hide Volume Profile
Allows a clean chart while preserving projected node zones.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=6
indicator("Volume Profile Periodic + HVN/LVN Extension Zones [TrendGenY]", shorttitle="VP Nodes", overlay=true, max_bars_back=5000, max_boxes_count=500, max_lines_count=500, max_labels_count=100)

//====================================================
// Inputs
//====================================================
grpPeriod = "Profile Period"
profilePeriod = input.string("Day", "Profile Period", options=["Day", "Week", "Month", "Quarter", "Year"], group=grpPeriod)
maxProfiles = input.int(6, "Show Last X Profiles", minval=1, maxval=50, group=grpPeriod)
maxBarsPerProfile = input.int(1500, "Max Bars Per Profile", minval=50, maxval=5000, group=grpPeriod)

grpBars = "Volume Profile Display"
showVolumeProfile = input.bool(true, "Show Volume Profile Bars", group=grpBars)
showProfileLabels = input.bool(true, "Show POC / VAH / VAL Labels", group=grpBars)
vp_num_bars = input.int(100, "Number of Volume Rows", minval=10, maxval=200, group=grpBars)
profileWidth = input.int(100, "Profile Width In Bars", minval=5, maxval=1500, group=grpBars)
profileSide = input.string("Left Facing", "Profile Direction", options=["Left Facing", "Right Facing"], group=grpBars)
vp_volume_type = input.string("Both", "Volume Type", options=["Both", "Bullish", "Bearish"], group=grpBars)
vp_bar_color = input.color(color.new(color.gray, 35), "Volume Bar Color", group=grpBars)
vp_bar_border = input.color(color.new(color.gray, 100), "Volume Bar Border", group=grpBars)

grpNodes = "HVN / LVN Zones"
showHVN = input.bool(true, "Detect HVN", group=grpNodes)
showLVN = input.bool(true, "Detect LVN", group=grpNodes)
extendHVN = input.bool(true, "Extend HVN Zones", group=grpNodes)
extendLVN = input.bool(true, "Extend LVN Zones", group=grpNodes)
nodeLookaround = input.int(2, "Local Node Sensitivity", minval=1, maxval=5, group=grpNodes)
hvnThresholdPct = input.float(65, "HVN Min % Of Max Volume", minval=1, maxval=100, group=grpNodes)
lvnThresholdPct = input.float(20, "LVN Max % Of Max Volume", minval=0, maxval=100, group=grpNodes)
maxNodesPerProfile = input.int(6, "Max Nodes Per Profile", minval=1, maxval=30, group=grpNodes)

nodeExtensionMode = input.string("Next Period", "Node Extension Mode", options=["X Candles", "Next Period", "Until Full Cross"], group=grpNodes)
nodeExtendBars = input.int(100, "X Candles To Extend", minval=1, maxval=5000, group=grpNodes)
deleteOnFullCross = input.bool(true, "Delete Zone After Full Cross", group=grpNodes)

hvnColor = input.color(color.new(color.aqua, 78), "HVN Zone Color", group=grpNodes)
lvnColor = input.color(color.new(color.fuchsia, 78), "LVN Zone Color", group=grpNodes)
hvnBorderColor = input.color(color.new(color.aqua, 15), "HVN Border Color", group=grpNodes)
lvnBorderColor = input.color(color.new(color.fuchsia, 15), "LVN Border Color", group=grpNodes)

grpPOC = "Point of Control"
vp_display_poc = input.bool(true, "Display POC", group=grpPOC)
extendPOCUntilCross = input.bool(true, "Extend POC Until Price Cross", group=grpPOC)
vp_poc_line_color = input.color(color.aqua, "POC Color", group=grpPOC)
vp_poc_line_thickness = input.int(2, "POC Line Thickness", minval=1, maxval=5, group=grpPOC)
vp_display_prev_poc = input.bool(true, "Display Previous POC", group=grpPOC)
vp_prev_poc_color = input.color(color.aqua, "Previous POC Color", group=grpPOC)

grpVA = "Value Area"
vp_display_va = input.bool(true, "Display Value Area", group=grpVA)
vp_va_percent = input.int(68, "Value Area Percentage", minval=5, maxval=95, group=grpVA)
vp_va_bar_color = input.color(color.new(color.yellow, 10), "Value Area Bar Color", group=grpVA)
vp_display_va_lines = input.bool(true, "Display VAH / VAL Lines", group=grpVA)
vp_va_lines_color = input.color(color.yellow, "VAH / VAL Line Color", group=grpVA)
vp_va_lines_thickness = input.int(1, "VAH / VAL Line Thickness", minval=1, maxval=5, group=grpVA)

grpVAExt = "Value Area Extension"
extendValueAreaField = input.bool(true, "Extend Value Area Field Into Next Period", group=grpVAExt)
vaExtensionColor = input.color(color.yellow, "Value Area Extension Color", group=grpVAExt)
vaExtensionTransparency = input.int(85, "Value Area Extension Transparency", minval=0, maxval=100, group=grpVAExt)
vaExtensionBorderTransparency = input.int(100, "Value Area Extension Border Transparency", minval=0, maxval=100, group=grpVAExt)

grpLabels = "Labels"
label_text_color = input.color(color.white, "Label Text Color", group=grpLabels)
label_bg_transparency = input.int(100, "Label Background Transparency", minval=0, maxval=100, group=grpLabels)

//====================================================
// Period Logic
//====================================================
periodTF =
     profilePeriod == "Day" ? "D" :
     profilePeriod == "Week" ? "W" :
     profilePeriod == "Month" ? "M" :
     profilePeriod == "Quarter" ? "3M" :
     "12M"

newPeriod = timeframe.change(periodTF)

//====================================================
// Arrays
//====================================================
var array<box> allBoxes = array.new_box()
var array<int> boxCounts = array.new_int()

var array<line> allLines = array.new_line()
var array<int> lineCounts = array.new_int()

var array<label> allLabels = array.new_label()
var array<int> labelCounts = array.new_int()

var array<line> extPocLines = array.new_line()
var array<float> extPocPrices = array.new_float()
var array<bool> extPocActive = array.new_bool()
var array<int> extPocStartBars = array.new_int()

var array<box> extVABoxes = array.new_box()
var array<bool> extVAActive = array.new_bool()

var array<box> extNodeBoxes = array.new_box()
var array<float> extNodeTops = array.new_float()
var array<float> extNodeBottoms = array.new_float()
var array<bool> extNodeActive = array.new_bool()
var array<int> extNodeStartBars = array.new_int()
var array<string> extNodeTypes = array.new_string()
var array<bool> extNodeTouchedTop = array.new_bool()
var array<bool> extNodeTouchedBottom = array.new_bool()

var int periodStartBar = na

var float activePOC = na
var float activeVAH = na
var float activeVAL = na
var float previousPOC = na

//====================================================
// Helpers
//====================================================
fmt(v) =>
    na(v) ? "na" : str.tostring(v, format.mintick)

profileIsLeftFacing = profileSide == "Left Facing"
transparentLabelColor = color.new(color.black, label_bg_transparency)

fullCrossZone(float top, float bottom, bool touchedTop, bool touchedBottom) =>
    bool currentFullPierce = high >= top and low <= bottom
    bool completedTwoSideCross = touchedTop and touchedBottom
    currentFullPierce or completedTwoSideCross

createNodeZone(float top, float bottom, color bgCol, color borderCol, string nodeType) =>
    int rightStart = nodeExtensionMode == "X Candles" ? bar_index + nodeExtendBars : bar_index + 1
    box z = box.new(left=bar_index, top=top, right=rightStart, bottom=bottom, xloc=xloc.bar_index, bgcolor=bgCol, border_color=borderCol)

    array.push(extNodeBoxes, z)
    array.push(extNodeTops, top)
    array.push(extNodeBottoms, bottom)
    array.push(extNodeActive, true)
    array.push(extNodeStartBars, bar_index)
    array.push(extNodeTypes, nodeType)
    array.push(extNodeTouchedTop, false)
    array.push(extNodeTouchedBottom, false)

updateExtendedNodeZones() =>
    if array.size(extNodeBoxes) > 0
        for i = 0 to array.size(extNodeBoxes) - 1
            box bx = array.get(extNodeBoxes, i)
            bool active = array.get(extNodeActive, i)

            if active
                float top = array.get(extNodeTops, i)
                float bottom = array.get(extNodeBottoms, i)
                int startBar = array.get(extNodeStartBars, i)

                bool touchedTop = array.get(extNodeTouchedTop, i)
                bool touchedBottom = array.get(extNodeTouchedBottom, i)

                if bar_index > startBar
                    if high >= top
                        touchedTop := true

                    if low <= bottom
                        touchedBottom := true

                    array.set(extNodeTouchedTop, i, touchedTop)
                    array.set(extNodeTouchedBottom, i, touchedBottom)

                if nodeExtensionMode == "Until Full Cross"
                    box.set_right(bx, bar_index + 1)

                    bool crossed = bar_index > startBar and fullCrossZone(top, bottom, touchedTop, touchedBottom)

                    if crossed
                        if deleteOnFullCross
                            box.delete(bx)
                        else
                            box.set_right(bx, bar_index)
                        array.set(extNodeActive, i, false)

                else if nodeExtensionMode == "X Candles"
                    int endBar = startBar + nodeExtendBars
                    box.set_right(bx, endBar)

                    if bar_index >= endBar
                        array.set(extNodeActive, i, false)

                else
                    box.set_right(bx, bar_index + 1)

closeNextPeriodNodeZones() =>
    if nodeExtensionMode == "Next Period" and array.size(extNodeBoxes) > 0
        for i = 0 to array.size(extNodeBoxes) - 1
            bool active = array.get(extNodeActive, i)

            if active
                box bx = array.get(extNodeBoxes, i)
                box.set_right(bx, bar_index)
                array.set(extNodeActive, i, false)

pruneProfiles() =>
    while array.size(boxCounts) > maxProfiles
        int n = array.shift(boxCounts)
        for i = 0 to n - 1
            if array.size(allBoxes) > 0
                box b = array.shift(allBoxes)
                box.delete(b)

    while array.size(lineCounts) > maxProfiles
        int n = array.shift(lineCounts)
        for i = 0 to n - 1
            if array.size(allLines) > 0
                line ln = array.shift(allLines)
                line.delete(ln)

    while array.size(labelCounts) > maxProfiles
        int n = array.shift(labelCounts)
        for i = 0 to n - 1
            if array.size(allLabels) > 0
                label lb = array.shift(allLabels)
                label.delete(lb)

    while array.size(extPocLines) > maxProfiles
        line oldExt = array.shift(extPocLines)
        line.delete(oldExt)
        array.shift(extPocPrices)
        array.shift(extPocActive)
        array.shift(extPocStartBars)

    while array.size(extVABoxes) > maxProfiles
        box oldVA = array.shift(extVABoxes)
        box.delete(oldVA)
        array.shift(extVAActive)

    int maxNodeZones = maxProfiles * maxNodesPerProfile
    while array.size(extNodeBoxes) > maxNodeZones
        box oldNode = array.shift(extNodeBoxes)
        box.delete(oldNode)
        array.shift(extNodeTops)
        array.shift(extNodeBottoms)
        array.shift(extNodeActive)
        array.shift(extNodeStartBars)
        array.shift(extNodeTypes)
        array.shift(extNodeTouchedTop)
        array.shift(extNodeTouchedBottom)

updateExtendedPOCs() =>
    if array.size(extPocLines) > 0
        for i = 0 to array.size(extPocLines) - 1
            line ln = array.get(extPocLines, i)
            float lvl = array.get(extPocPrices, i)
            bool active = array.get(extPocActive, i)
            int startBar = array.get(extPocStartBars, i)

            if active
                bool crossed = bar_index > startBar and high >= lvl and low <= lvl
                line.set_x2(ln, bar_index)

                if crossed
                    array.set(extPocActive, i, false)

updateExtendedVAFields() =>
    if array.size(extVABoxes) > 0
        for i = 0 to array.size(extVABoxes) - 1
            box bx = array.get(extVABoxes, i)
            bool active = array.get(extVAActive, i)

            if active
                box.set_right(bx, bar_index)

closeActiveVAFields() =>
    if array.size(extVABoxes) > 0
        for i = 0 to array.size(extVABoxes) - 1
            bool active = array.get(extVAActive, i)

            if active
                box bx = array.get(extVABoxes, i)
                box.set_right(bx, bar_index - 1)
                array.set(extVAActive, i, false)

calculate_va(array<float> vols, int max_idx, float max_vol, int rows) =>
    float sum_vol = array.sum(vols)
    float va_target = sum_vol * vp_va_percent / 100.0

    int va_up = max_idx
    int va_dn = max_idx
    float va_sum = max_vol

    while va_sum < va_target
        float v_up = va_up < rows - 1 ? array.get(vols, va_up + 1) : 0.0
        float v_dn = va_dn > 0 ? array.get(vols, va_dn - 1) : 0.0

        if v_up == 0 and v_dn == 0
            break

        if v_up >= v_dn
            va_sum += v_up
            va_up += 1
        else
            va_sum += v_dn
            va_dn -= 1

    [va_dn, va_up]

isLocalHVN(array<float> vols, int idx, int rows, float maxVol) =>
    float v = array.get(vols, idx)
    bool thresholdOK = v >= maxVol * hvnThresholdPct / 100.0
    bool localOK = true

    for k = 1 to nodeLookaround
        float leftV = idx - k >= 0 ? array.get(vols, idx - k) : -1.0
        float rightV = idx + k <= rows - 1 ? array.get(vols, idx + k) : -1.0
        localOK := localOK and v >= leftV and v >= rightV

    thresholdOK and localOK

isLocalLVN(array<float> vols, int idx, int rows, float maxVol) =>
    float v = array.get(vols, idx)
    bool thresholdOK = v <= maxVol * lvnThresholdPct / 100.0 and v > 0
    bool localOK = true

    for k = 1 to nodeLookaround
        float leftV = idx - k >= 0 ? array.get(vols, idx - k) : maxVol
        float rightV = idx + k <= rows - 1 ? array.get(vols, idx + k) : maxVol
        localOK := localOK and v <= leftV and v <= rightV

    thresholdOK and localOK

//====================================================
// Draw Completed Profile
//====================================================
drawProfile(int barsInPeriod, int xEnd) =>
    int barsToUse = math.min(barsInPeriod, maxBarsPerProfile)
    int rows = vp_num_bars

    float highestPrice = na
    float lowestPrice = na

    for i = 1 to barsToUse
        highestPrice := na(highestPrice) ? high[i] : math.max(highestPrice, high[i])
        lowestPrice := na(lowestPrice) ? low[i] : math.min(lowestPrice, low[i])

    float priceRange = highestPrice - lowestPrice
    float interval = priceRange / rows

    array<float> vols = array.new_float(rows, 0.0)

    if interval > 0
        for i = 1 to barsToUse
            bool isBullish = close[i] >= open[i]
            bool includeVol = vp_volume_type == "Both" ? true : vp_volume_type == "Bullish" ? isBullish : not isBullish
            float candleRange = high[i] - low[i]

            if includeVol
                for j = 0 to rows - 1
                    float binLow = lowestPrice + interval * j
                    float binHigh = lowestPrice + interval * (j + 1)

                    if candleRange > 0
                        float overlap = math.max(0.0, math.min(high[i], binHigh) - math.max(low[i], binLow))
                        float portion = overlap / candleRange

                        if portion > 0
                            array.set(vols, j, array.get(vols, j) + volume[i] * portion)
                    else
                        if close[i] >= binLow and close[i] <= binHigh
                            array.set(vols, j, array.get(vols, j) + volume[i])

    float maxVol = array.max(vols)
    int pocIdx = array.indexof(vols, maxVol)

    [vaDn, vaUp] = calculate_va(vols, pocIdx, maxVol, rows)

    float pocPrice = lowestPrice + interval * (pocIdx + 0.5)
    float vahPrice = lowestPrice + interval * (vaUp + 1)
    float valPrice = lowestPrice + interval * vaDn

    int localBoxCount = 0
    int localLineCount = 0
    int localLabelCount = 0
    int localNodeCount = 0

    if maxVol > 0 and interval > 0
        for j = 0 to rows - 1
            float rowVol = array.get(vols, j)

            if rowVol > 0
                int barWidth = math.max(1, math.round((rowVol / maxVol) * profileWidth))
                int x1 = profileIsLeftFacing ? xEnd - barWidth : xEnd
                int x2 = profileIsLeftFacing ? xEnd : xEnd + barWidth

                float y1 = lowestPrice + interval * j
                float y2 = lowestPrice + interval * (j + 1)

                bool inVA = j >= vaDn and j <= vaUp
                bool isPOC = j == pocIdx
                bool hvn = showHVN and isLocalHVN(vols, j, rows, maxVol)
                bool lvn = showLVN and isLocalLVN(vols, j, rows, maxVol)

                color barCol = isPOC ? vp_poc_line_color : hvn ? color.new(hvnColor, 35) : lvn ? color.new(lvnColor, 35) : inVA and vp_display_va ? vp_va_bar_color : vp_bar_color

                if showVolumeProfile
                    box bx = box.new(left=x1, top=y2, right=x2, bottom=y1, xloc=xloc.bar_index, bgcolor=barCol, border_color=vp_bar_border)
                    array.push(allBoxes, bx)
                    localBoxCount += 1

                if localNodeCount < maxNodesPerProfile
                    if hvn and extendHVN
                        createNodeZone(y2, y1, hvnColor, hvnBorderColor, "HVN")
                        localNodeCount += 1

                    if lvn and extendLVN and localNodeCount < maxNodesPerProfile
                        createNodeZone(y2, y1, lvnColor, lvnBorderColor, "LVN")
                        localNodeCount += 1

        int xLine1 = profileIsLeftFacing ? xEnd - profileWidth : xEnd
        int xLine2 = profileIsLeftFacing ? xEnd : xEnd + profileWidth

        if showVolumeProfile and vp_display_poc
            int pocX2 = extendPOCUntilCross ? bar_index : xLine2
            line pocLine = line.new(xLine1, pocPrice, pocX2, pocPrice, xloc=xloc.bar_index, color=vp_poc_line_color, width=vp_poc_line_thickness)
            array.push(allLines, pocLine)
            localLineCount += 1

            if extendPOCUntilCross
                array.push(extPocLines, pocLine)
                array.push(extPocPrices, pocPrice)
                array.push(extPocActive, true)
                array.push(extPocStartBars, bar_index)

        if showVolumeProfile and vp_display_prev_poc and not na(previousPOC)
            line prevPocLine = line.new(xLine1, previousPOC, xLine2, previousPOC, xloc=xloc.bar_index, color=vp_prev_poc_color, width=vp_poc_line_thickness, style=line.style_dashed)
            array.push(allLines, prevPocLine)
            localLineCount += 1

        if showVolumeProfile and vp_display_va and vp_display_va_lines
            line vahLine = line.new(xLine1, vahPrice, xLine2, vahPrice, xloc=xloc.bar_index, color=vp_va_lines_color, width=vp_va_lines_thickness)
            line valLine = line.new(xLine1, valPrice, xLine2, valPrice, xloc=xloc.bar_index, color=vp_va_lines_color, width=vp_va_lines_thickness)

            array.push(allLines, vahLine)
            array.push(allLines, valLine)
            localLineCount += 2

        if extendValueAreaField and vp_display_va
            box vaExt = box.new(left=bar_index, top=vahPrice, right=bar_index + 1, bottom=valPrice, xloc=xloc.bar_index, bgcolor=color.new(vaExtensionColor, vaExtensionTransparency), border_color=color.new(vaExtensionColor, vaExtensionBorderTransparency))
            array.push(extVABoxes, vaExt)
            array.push(extVAActive, true)

        if showVolumeProfile and showProfileLabels
            int labelX = profileIsLeftFacing ? xEnd + 1 : xEnd + profileWidth + 1

            if vp_display_poc
                label pocLabel = label.new(labelX, pocPrice, "POC: " + fmt(pocPrice), xloc=xloc.bar_index, style=label.style_label_left, color=transparentLabelColor, textcolor=label_text_color)
                array.push(allLabels, pocLabel)
                localLabelCount += 1

            if vp_display_prev_poc and not na(previousPOC)
                label prevPocLabel = label.new(labelX, previousPOC, "Prev POC: " + fmt(previousPOC), xloc=xloc.bar_index, style=label.style_label_left, color=transparentLabelColor, textcolor=label_text_color)
                array.push(allLabels, prevPocLabel)
                localLabelCount += 1

            if vp_display_va and vp_display_va_lines
                label vahLabel = label.new(labelX, vahPrice, "VAH: " + fmt(vahPrice), xloc=xloc.bar_index, style=label.style_label_left, color=transparentLabelColor, textcolor=label_text_color)
                label valLabel = label.new(labelX, valPrice, "VAL: " + fmt(valPrice), xloc=xloc.bar_index, style=label.style_label_left, color=transparentLabelColor, textcolor=label_text_color)

                array.push(allLabels, vahLabel)
                array.push(allLabels, valLabel)
                localLabelCount += 2

    array.push(boxCounts, localBoxCount)
    array.push(lineCounts, localLineCount)
    array.push(labelCounts, localLabelCount)

    [pocPrice, vahPrice, valPrice]

//====================================================
// Main Logic
//====================================================
if barstate.isfirst
    periodStartBar := bar_index

updateExtendedPOCs()
updateExtendedVAFields()
updateExtendedNodeZones()

if newPeriod and not na(periodStartBar)
    closeActiveVAFields()
    closeNextPeriodNodeZones()

    int barsInPeriod = bar_index - periodStartBar

    if barsInPeriod > 5
        previousPOC := activePOC

        [pocOut, vahOut, valOut] = drawProfile(barsInPeriod, bar_index - 1)

        activePOC := pocOut
        activeVAH := vahOut
        activeVAL := valOut

        pruneProfiles()

    periodStartBar := bar_index

//====================================================
// Alerts
//====================================================
priceCrossPOC = not na(activePOC) and ta.cross(close, activePOC)
priceCrossVAH = not na(activeVAH) and ta.cross(close, activeVAH)
priceCrossVAL = not na(activeVAL) and ta.cross(close, activeVAL)

pocShiftUp = not na(activePOC) and not na(previousPOC) and activePOC > previousPOC
pocShiftDown = not na(activePOC) and not na(previousPOC) and activePOC < previousPOC

enteredValueArea = not na(activeVAH) and not na(activeVAL) and close <= activeVAH and close >= activeVAL and (close[1] > activeVAH or close[1] < activeVAL)
exitedValueArea = not na(activeVAH) and not na(activeVAL) and (close > activeVAH or close < activeVAL) and close[1] <= activeVAH and close[1] >= activeVAL

alertcondition(priceCrossPOC, "Price Crossed POC", "Price crossed the latest Volume Profile POC.")
alertcondition(priceCrossVAH, "Price Crossed VAH", "Price crossed the latest Volume Profile VAH.")
alertcondition(priceCrossVAL, "Price Crossed VAL", "Price crossed the latest Volume Profile VAL.")
alertcondition(pocShiftUp, "POC Shifted Higher", "Volume Profile POC shifted higher.")
alertcondition(pocShiftDown, "POC Shifted Lower", "Volume Profile POC shifted lower.")
alertcondition(enteredValueArea, "Price Entered Value Area", "Price entered the latest Volume Profile value area.")
alertcondition(exitedValueArea, "Price Exited Value Area", "Price exited the latest Volume Profile value area.")
````

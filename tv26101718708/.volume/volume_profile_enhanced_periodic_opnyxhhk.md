# Volume Profile Enhanced Periodic

- url: https://www.tradingview.com/script/opnyxHhk-Volume-Profile-Enhanced-Periodic/
- type: indicator
- pine_id: PUB;8e84a1ba4db7492cb23ceeaf427f42d1
- version: 1.0

## Description

Volume Profile Enhanced Periodic

Volume Profile Enhanced Periodic is an advanced profile framework designed to analyze and visualize how volume is distributed across price levels over repeating time periods such as days, weeks, months, quarters, and years.

Unlike traditional fixed-range profiles that focus on a single visible section of the chart, this indicator automatically generates separate volume profiles for each selected historical period, allowing traders to study how price acceptance, value migration, and high participation areas evolve over time.

The objective is to identify where market participants historically concentrated activity and monitor how these areas shift as market structure develops.

By combining period-based volume profiles, Point of Control tracking, Value Area analysis, extending POC levels, and profile projection tools, the indicator is designed to provide additional context for support/resistance behavior, market acceptance, and evolving market structure.

Features

• Automatic Day / Week / Month / Quarter / Year profiles
• Historical profile generation across multiple periods
• Solid histogram profile display
• Profile direction toggle (Left or Right facing)
• Point of Control (POC) detection
• Previous POC tracking
• Value Area High (VAH) and Value Area Low (VAL) calculations
• Extend POC levels until price interaction
• Extend Value Area fields into future periods
• Adjustable Value Area extension brightness
• Custom profile width controls
• Historical profile management controls
• Lightweight performance optimization
• Naked labels without background flags
• Dynamic labels for:

• POC
• Previous POC
• VAH
• VAL

Alerts Included

• Price Crossed POC
• Price Crossed VAH
• Price Crossed VAL
• POC Shifted Higher
• POC Shifted Lower
• Price Entered Value Area
• Price Exited Value Area

Potential Use Cases

• Identify historical high participation zones
• Locate support and resistance areas
• Monitor value migration over time
• Track changing market acceptance
• Identify developing imbalance areas
• Observe POC movement between periods
• Use extended POC levels as potential reaction zones
• Add confluence to existing systems
• Study auction behavior and market structure

Interpretation

POC (Point of Control)
Represents the price level where the highest concentration of volume occurred during the selected period.

VAH (Value Area High)
Represents the upper boundary of the selected value area where the majority of trading activity occurred.

VAL (Value Area Low)
Represents the lower boundary of the selected value area.

Previous POC
Displays prior dominant participation levels for historical context.

Extended POC
Extends POC levels forward until price revisits or crosses through them, potentially highlighting important market interaction zones.

Extended Value Area Field
Projects the previous period's value area into future price action for additional context regarding acceptance and rejection zones.

About TrendGenY Indicators

[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=6
indicator("Volume Profile Enhanced Periodic", shorttitle="VP Periodic", overlay=true, max_bars_back=5000, max_boxes_count=500, max_lines_count=500, max_labels_count=100)

//====================================================
// Inputs
//====================================================
grpPeriod = "Profile Period"
profilePeriod = input.string("Day", "Profile Period", options=["Day", "Week", "Month", "Quarter", "Year"], group=grpPeriod)
maxProfiles = input.int(6, "Show Last X Profiles", minval=1, maxval=100, group=grpPeriod)
maxBarsPerProfile = input.int(1500, "Max Bars Per Profile", minval=50, maxval=5000, group=grpPeriod)

grpBars = "Volume Bars"
vp_num_bars = input.int(50, "Number of Volume Rows", minval=10, maxval=60, group=grpBars)
profileWidth = input.int(40, "Profile Width In Bars", minval=5, maxval=150, group=grpBars)
profileSide = input.string("Left Facing", "Profile Direction", options=["Left Facing", "Right Facing"], group=grpBars)
vp_volume_type = input.string("Both", "Volume Type", options=["Both", "Bullish", "Bearish"], group=grpBars)
vp_bar_color = input.color(color.new(color.gray, 35), "Volume Bar Color", group=grpBars)
vp_bar_border = input.color(color.new(color.gray, 100), "Volume Bar Border", group=grpBars)

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
show_labels = input.bool(true, "Show POC / VAH / VAL Labels", group=grpLabels)
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
// Persistent Objects
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

updateExtendedPOCs() =>
    if array.size(extPocLines) > 0
        for i = 0 to array.size(extPocLines) - 1
            line ln = array.get(extPocLines, i)
            float lvl = array.get(extPocPrices, i)
            bool active = array.get(extPocActive, i)
            int startBar = array.get(extPocStartBars, i)

            if active
                bool crossed = bar_index > startBar and high >= lvl and low <= lvl

                if crossed
                    line.set_x2(ln, bar_index)
                    array.set(extPocActive, i, false)
                else
                    line.set_x2(ln, bar_index)

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

            if includeVol
                for j = 0 to rows - 1
                    float binLow = lowestPrice + interval * j
                    float binHigh = lowestPrice + interval * (j + 1)
                    bool overlaps = low[i] <= binHigh and high[i] >= binLow

                    if overlaps
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

                color barCol = isPOC ? vp_poc_line_color : inVA and vp_display_va ? vp_va_bar_color : vp_bar_color

                box bx = box.new(left=x1, top=y2, right=x2, bottom=y1, xloc=xloc.bar_index, bgcolor=barCol, border_color=vp_bar_border)
                array.push(allBoxes, bx)
                localBoxCount += 1

        int xLine1 = profileIsLeftFacing ? xEnd - profileWidth : xEnd
        int xLine2 = profileIsLeftFacing ? xEnd : xEnd + profileWidth

        if vp_display_poc
            int pocX2 = extendPOCUntilCross ? bar_index : xLine2

            line pocLine = line.new(xLine1, pocPrice, pocX2, pocPrice, xloc=xloc.bar_index, color=vp_poc_line_color, width=vp_poc_line_thickness)
            array.push(allLines, pocLine)
            localLineCount += 1

            if extendPOCUntilCross
                array.push(extPocLines, pocLine)
                array.push(extPocPrices, pocPrice)
                array.push(extPocActive, true)
                array.push(extPocStartBars, bar_index)

        if vp_display_prev_poc and not na(previousPOC)
            line prevPocLine = line.new(xLine1, previousPOC, xLine2, previousPOC, xloc=xloc.bar_index, color=vp_prev_poc_color, width=vp_poc_line_thickness, style=line.style_dashed)
            array.push(allLines, prevPocLine)
            localLineCount += 1

        if vp_display_va and vp_display_va_lines
            line vahLine = line.new(xLine1, vahPrice, xLine2, vahPrice, xloc=xloc.bar_index, color=vp_va_lines_color, width=vp_va_lines_thickness)
            line valLine = line.new(xLine1, valPrice, xLine2, valPrice, xloc=xloc.bar_index, color=vp_va_lines_color, width=vp_va_lines_thickness)

            array.push(allLines, vahLine)
            array.push(allLines, valLine)
            localLineCount += 2

        if extendValueAreaField and vp_display_va
            box vaExt = box.new(left=bar_index, top=vahPrice, right=bar_index, bottom=valPrice, xloc=xloc.bar_index, bgcolor=color.new(vaExtensionColor, vaExtensionTransparency), border_color=color.new(vaExtensionColor, vaExtensionBorderTransparency))
            array.push(extVABoxes, vaExt)
            array.push(extVAActive, true)

        if show_labels
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

if newPeriod and not na(periodStartBar)
    closeActiveVAFields()

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

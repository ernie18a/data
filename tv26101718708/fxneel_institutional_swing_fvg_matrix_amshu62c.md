# FxNeel Institutional Swing & FVG Matrix

- url: https://www.tradingview.com/script/AmshU62C-FxNeel-Institutional-Swing-FVG-Matrix/
- type: indicator
- pine_id: PUB;09f93e56bb594b12b27fa02aa2ae89bb
- version: 1.0

## Description

Developed under the FxNeel, this open-source Pine Script v6 indicator is designed for professional traders utilizing advanced market structure frameworks and institutional volume tracking. The script focuses on identifying clear structural key points while maintaining chart cleanliness through intelligent filtering.

Key Features:
Four-Way Independent Swing Structure: It dynamically tracks Short-Term Highs (STH), Short-Term Lows (STL), Intermediate-Term Highs (ITH), and Intermediate-Term Lows (ITL).

Automatic Overlap Filter: To ensure chart clarity and prevent clutter, the indicator automatically removes minor STH/STL lines and labels once a major institutional pivot (ITH/ITL) is fully confirmed.

Dynamic Fair Value Gap (FVG) Engine: It tracks dynamic market imbalances (Bullish/Bearish FVGs) with real-time, state-based mitigation logic, modifying or removing zones as price action tests the gaps.

Granular UI Customization: Features a fully structured settings panel where visibility, line styles, text colors, and exact 4-way label alignments (Vertical and Horizontal) can be customized independently for each swing type.

## Source Code

````pine
//@version=6
indicator("FxNeel Institutional Swing & FVG Matrix", overlay=true, max_labels_count=500, max_boxes_count=300, max_lines_count=300)

// ==========================================
// 1. INPUTS & CUSTOMIZATION CONTROLS (Fully Grouped)
// ==========================================

// 1a. Short-Term High (STH) Independent Settings
var string G_STH_SET = "Short-Term High (STH) Settings"
showSTH      = input.bool(true, "Show Short-Term High (STH)", group=G_STH_SET)
sthLineOpt   = input.string("Dotted", "STH Line Style", options=["Solid", "Dashed", "Dotted"], group=G_STH_SET)
sthLineWidth = input.int(1, "STH Line Width", minval=1, maxval=4, group=G_STH_SET)
sthLineColor = input.color(color.new(color.gray, 50), "STH Line Color", group=G_STH_SET)
sthTextColor = input.color(color.gray, "STH Text Color", group=G_STH_SET)
sthLabelVAlign = input.string("Top", "STH Label Vertical Position", options=["Top", "Bottom"], group=G_STH_SET)
sthLabelHAlign = input.string("Right", "STH Label Horizontal Position", options=["Left", "Right"], group=G_STH_SET)

// 1b. Short-Term Low (STL) Independent Settings
var string G_STL_SET = "Short-Term Low (STL) Settings"
showSTL      = input.bool(true, "Show Short-Term Low (STL)", group=G_STL_SET)
stlLineOpt   = input.string("Dotted", "STL Line Style", options=["Solid", "Dashed", "Dotted"], group=G_STL_SET)
stlLineWidth = input.int(1, "STL Line Width", minval=1, maxval=4, group=G_STL_SET)
stlLineColor = input.color(color.new(color.gray, 50), "STL Line Color", group=G_STL_SET)
stlTextColor = input.color(color.gray, "STL Text Color", group=G_STL_SET)
stlLabelVAlign = input.string("Bottom", "STL Label Vertical Position", options=["Top", "Bottom"], group=G_STL_SET)
stlLabelHAlign = input.string("Right", "STL Label Horizontal Position", options=["Left", "Right"], group=G_STL_SET)

// 1c. Intermediate-Term High (ITH) Independent Settings
var string G_ITH_SET = "Intermediate-Term High (ITH) Settings"
showITH      = input.bool(true, "Show Intermediate-Term High (ITH)", group=G_ITH_SET)
ithLineOpt   = input.string("Dashed", "ITH Line Style", options=["Solid", "Dashed", "Dotted"], group=G_ITH_SET)
ithLineWidth = input.int(1, "ITH Line Width", minval=1, maxval=4, group=G_ITH_SET)
ithLineColor = input.color(color.new(color.red, 40), "ITH Line Color", group=G_ITH_SET)
ithTextColor = input.color(color.red, "ITH Text Color", group=G_ITH_SET)
ithLabelVAlign = input.string("Top", "ITH Label Vertical Position", options=["Top", "Bottom"], group=G_ITH_SET)
ithLabelHAlign = input.string("Right", "ITH Label Horizontal Position", options=["Left", "Right"], group=G_ITH_SET)

// 1d. Intermediate-Term Low (ITL) Independent Settings
var string G_ITL_SET = "Intermediate-Term Low (ITL) Settings"
showITL      = input.bool(true, "Show Intermediate-Term Low (ITL)", group=G_ITL_SET)
itlLineOpt   = input.string("Dashed", "ITL Line Style", options=["Solid", "Dashed", "Dotted"], group=G_ITL_SET)
itlLineWidth = input.int(1, "ITL Line Width", minval=1, maxval=4, group=G_ITL_SET)
itlLineColor = input.color(color.new(color.green, 40), "ITL Line Color", group=G_ITL_SET)
itlTextColor = input.color(color.green, "ITL Text Color", group=G_ITL_SET)
itlLabelVAlign = input.string("Bottom", "ITL Label Vertical Position", options=["Top", "Bottom"], group=G_ITL_SET)
itlLabelHAlign = input.string("Right", "ITL Label Horizontal Position", options=["Left", "Right"], group=G_ITL_SET)

var string G_FVG     = "Dynamic Fair Value Gap (FVG) Engine"
showFVG      = input.bool(true, "Plot Dynamic Fair Value Gaps", group=G_FVG)
fvgCountLimit = input.int(10, "Max Number of FVGs to Show on Chart", minval=1, maxval=100, group=G_FVG)
fvgColorBull = input.color(color.new(color.green, 93), "Bullish FVG Fill", group=G_FVG)
fvgColorBear = input.color(color.new(color.red, 93), "Bearish FVG Fill", group=G_FVG)

// Helper function to map user selections to native line styles
getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

actualSthLineStyle = getLineStyle(sthLineOpt)
actualStlLineStyle = getLineStyle(stlLineOpt)
actualIthLineStyle = getLineStyle(ithLineOpt)
actualItlLineStyle = getLineStyle(itlLineOpt)

// Text positioning style mapper function
getLabelStyle(vPos, hPos) =>
    if vPos == "Top"
        hPos == "Left" ? label.style_label_upper_left : label.style_label_upper_right
    else
        hPos == "Left" ? label.style_label_lower_left : label.style_label_lower_right

actualSthLabelStyle = getLabelStyle(sthLabelVAlign, sthLabelHAlign)
actualStlLabelStyle = getLabelStyle(stlLabelVAlign, stlLabelHAlign)
actualIthLabelStyle = getLabelStyle(ithLabelVAlign, ithLabelHAlign)
actualItlLabelStyle = getLabelStyle(itlLabelVAlign, itlLabelHAlign)

// ==========================================
// 2. CORE SWING STRUCTURE LOGIC (A/V Shapes & Overlap Filter)
// ==========================================
isSTH = ta.pivothigh(high, 2, 2)
isSTL = ta.pivotlow(low, 2, 2)

// Historical tracking arrays
var float[] sthPrices = array.new_float(0)
var int[]   sthBars   = array.new_int(0)
var label[] sthLabels = array.new_label(0)
var line[]  sthLines  = array.new_line(0)

var float[] stlPrices = array.new_float(0)
var int[]   stlBars   = array.new_int(0)
var label[] stlLabels = array.new_label(0)
var line[]  stlLines  = array.new_line(0)

// Track and Plot Short-Term Highs (STH)
if not na(isSTH)
    targetBar = bar_index - 2
    array.push(sthPrices, high[2])
    array.push(sthBars, targetBar)
    
    if showSTH
        endBar = bar_index + 5
        stLine = line.new(x1=targetBar, y1=high[2], x2=endBar, y2=high[2], color=sthLineColor, width=sthLineWidth, style=actualSthLineStyle)
        labelTextBar = sthLabelHAlign == "Left" ? targetBar : endBar
        stLabel = label.new(labelTextBar, high[2], "STH", color=color.new(color.white, 100), style=actualSthLabelStyle, textcolor=sthTextColor, size=size.small)
        
        array.push(sthLines, stLine)
        array.push(sthLabels, stLabel)

    if array.size(sthPrices) > 15
        array.shift(sthPrices)
        array.shift(sthBars)
        if showSTH
            array.shift(sthLines)
            array.shift(sthLabels)

// Track and Plot Short-Term Lows (STL)
if not na(isSTL)
    targetBar = bar_index - 2
    array.push(stlPrices, low[2])
    array.push(stlBars, targetBar)
    
    if showSTL
        endBar = bar_index + 5
        stLine = line.new(x1=targetBar, y1=low[2], x2=endBar, y2=low[2], color=stlLineColor, width=stlLineWidth, style=actualStlLineStyle)
        labelTextBar = stlLabelHAlign == "Left" ? targetBar : endBar
        stLabel = label.new(labelTextBar, low[2], "STL", color=color.new(color.white, 100), style=actualStlLabelStyle, textcolor=stlTextColor, size=size.small)
        
        array.push(stlLines, stLine)
        array.push(stlLabels, stLabel)

    if array.size(stlPrices) > 15
        array.shift(stlPrices)
        array.shift(stlBars)
        if showSTL
            array.shift(stlLines)
            array.shift(stlLabels)

// Validate and plot Intermediate-Term Highs (ITH) & Remove Overlapping STH
if not na(isSTH) and array.size(sthPrices) >= 3
    currSTH = array.get(sthPrices, array.size(sthPrices) - 2)
    prevSTH = array.get(sthPrices, array.size(sthPrices) - 3)
    nextSTH = array.get(sthPrices, array.size(sthPrices) - 1)
    targetBar = array.get(sthBars, array.size(sthBars) - 2)
    
    if currSTH > prevSTH and currSTH > nextSTH and showITH
        if (showSTH or showSTL) and array.size(sthLabels) >= 2
            idx = array.size(sthLabels) - 2
            label.delete(array.get(sthLabels, idx))
            line.delete(array.get(sthLines, idx))
            
        endBar = bar_index + 10
        line.new(x1=targetBar, y1=currSTH, x2=endBar, y2=currSTH, color=ithLineColor, width=ithLineWidth, style=actualIthLineStyle)
        labelTextBar = ithLabelHAlign == "Left" ? targetBar : endBar
        label.new(labelTextBar, currSTH, "ITH 🔴", color=color.new(color.white, 100), style=actualIthLabelStyle, textcolor=ithTextColor, size=size.normal)

// Validate and plot Intermediate-Term Lows (ITL) & Remove Overlapping STL
if not na(isSTL) and array.size(stlPrices) >= 3
    currSTL = array.get(stlPrices, array.size(stlPrices) - 2)
    prevSTL = array.get(stlPrices, array.size(stlPrices) - 3)
    nextSTL = array.get(stlPrices, array.size(stlPrices) - 1)
    targetBar = array.get(stlBars, array.size(stlBars) - 2)
    
    if currSTL < prevSTL and currSTL < nextSTL and showITL
        if (showSTH or showSTL) and array.size(stlLabels) >= 2
            idx = array.size(stlLabels) - 2
            label.delete(array.get(stlLabels, idx))
            line.delete(array.get(stlLines, idx))
            
        endBar = bar_index + 10
        line.new(x1=targetBar, y1=currSTL, x2=endBar, y2=currSTL, color=itlLineColor, width=itlLineWidth, style=actualItlLineStyle)
        labelTextBar = itlLabelHAlign == "Left" ? targetBar : endBar
        label.new(labelTextBar, currSTL, "ITL 🟢", color=color.new(color.white, 100), style=actualItlLabelStyle, textcolor=itlTextColor, size=size.normal)

// ==========================================
// 3. DYNAMIC FAIR VALUE GAP (FVG) ENGINE
// ==========================================
var box[] bullFvgBoxes = array.new_box(0)
var box[] bearFvgBoxes = array.new_box(0)

isBullFVG = low[0] > high[2] and close[1] > high[2]
isBearFVG = high[0] < low[2] and close[1] < low[2]

if showFVG
    if isBullFVG
        bx = box.new(left=bar_index - 2, top=low[0], right=bar_index, bottom=high[2], bgcolor=fvgColorBull, border_color=na)
        array.push(bullFvgBoxes, bx)
        if array.size(bullFvgBoxes) > fvgCountLimit
            box.delete(array.shift(bullFvgBoxes))
    
    if isBearFVG
        bx = box.new(left=bar_index - 2, top=low[2], right=bar_index, bottom=high[0], bgcolor=fvgColorBear, border_color=na)
        array.push(bearFvgBoxes, bx)
        if array.size(bearFvgBoxes) > fvgCountLimit
            box.delete(array.shift(bearFvgBoxes))

    // Dynamic mitigation for Bullish FVGs
    if array.size(bullFvgBoxes) > 0
        for i = array.size(bullFvgBoxes) - 1 to 0
            b = array.get(bullFvgBoxes, i)
            topPrice = box.get_top(b)
            btmPrice = box.get_bottom(b)
            
            if low[0] <= btmPrice
                box.delete(b)
                array.remove(bullFvgBoxes, i)
            else
                box.set_right(b, bar_index)
                if low[0] < topPrice and low[0] > btmPrice
                    box.set_top(b, low[0])

    // Dynamic mitigation for Bearish FVGs
    if array.size(bearFvgBoxes) > 0
        for i = array.size(bearFvgBoxes) - 1 to 0
            b = array.get(bearFvgBoxes, i)
            topPrice = box.get_top(b)
            btmPrice = box.get_bottom(b)
            
            if high[0] >= topPrice
                box.delete(b)
                array.remove(bearFvgBoxes, i)
            else
                box.set_right(b, bar_index)
                if high[0] > btmPrice and high[0] < topPrice
                    box.set_bottom(b, high[0])
````

<!-- tradingview-pine-id: PUB;457b17edf64f4e33a0bb4f4f08895fb1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NQ Psychological Levels

Source: https://www.tradingview.com/script/29H8UVHp-NQ-Psychological-Levels/

## Description

NQ Psychological Levels automatically plots the round-number price levels closest to the current market price.

The indicator organizes these levels into five tiers:

• 50-point levels
• 100-point levels
• 250-point levels
• 500-point levels
• 1000-point levels

Each tier can be customized independently, including its color, opacity, width, and line style.

Features:

• Automatically plots the nearest psychological levels
• Configurable number of displayed levels
• Independent styling for every level tier
• Optional price labels
• Left or right label placement
• Configurable candle offset from the current bar
• Above, center, or below text alignment
• Custom label size and color
• Optional alerts when price touches a major 250-point level, including 500 and 1000 levels

This indicator is primarily designed for NQ and related Nasdaq futures charts. It can help identify commonly observed round-number areas and keep charts organized without manually drawing and updating each level.

The indicator does not generate entries, exits, directional bias, or trading recommendations. It is intended only as a charting and market-observation tool.

---

## Source Code

````pine
//@version=6
indicator("NQ Psychological Levels", shorttitle = "NQ Psy Lvls", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── GENERAL ─────────────────────────
grpGen = "General"
i_maxLines   = input.int(50, "Max Lines to Plot (closest to price)", minval = 1, maxval = 200, group = grpGen)
i_showLabels = input.bool(true, "Show Price Labels", group = grpGen)
i_labelHPos  = input.string("Right", "Label Horizontal Position", options = ["Left", "Right"], group = grpGen)
i_labelLeftOffsetBars  = input.int(50, "Left Offset From Current Price (candles)", minval = 0, maxval = 500, group = grpGen)
i_labelRightOffsetBars = input.int(50, "Right Offset From Current Price (candles)", minval = 0, maxval = 500, group = grpGen)
i_labelVPos  = input.string("Above", "Label Vertical Position", options = ["Above", "Center", "Below"], group = grpGen)
i_labelSize  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpGen)


// ───────────────────────── GLOBAL COLOR FALLBACK ─────────────────────────
grpGlobal = "Global Color"
i_globalColor = input.color(color.gray, "Global Line Color (used by tiers with 'Use Custom Color' off)", group = grpGlobal)

i_useLineColorForLabel = input.bool(true, "Use Line Color for Label Text", group = grpGlobal)
i_labelColor = input.color(color.white, "Custom Label Color (used if above is off)", group = grpGlobal)
// ───────────────────────── STYLE: 50s ─────────────────────────
grp50 = "Style: 50s"
i_customColor50 = input.bool(true, "Use Custom Color", group = grp50)
i_color50   = input.color(#787B86, "Color", group = grp50)
i_opacity50 = input.int(40, "Opacity % (0=invisible, 100=opaque)", minval = 0, maxval = 100, group = grp50)
i_width50   = input.int(1, "Line Width", minval = 1, maxval = 10, group = grp50)
i_style50   = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp50)

// ───────────────────────── STYLE: 100s ─────────────────────────
grp100 = "Style: 100s"
i_customColor100 = input.bool(true, "Use Custom Color", group = grp100)
i_color100   = input.color(#000000, "Color", group = grp100)
i_opacity100 = input.int(50, "Opacity % (0=invisible, 100=opaque)", minval = 0, maxval = 100, group = grp100)
i_width100   = input.int(1, "Line Width", minval = 1, maxval = 10, group = grp100)
i_style100   = input.string("Dashed", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp100)

// ───────────────────────── STYLE: 250s ─────────────────────────
grp250 = "Style: 250s"
i_customColor250 = input.bool(true, "Use Custom Color", group = grp250)
i_color250   = input.color(#f23645, "Color", group = grp250)
i_opacity250 = input.int(65, "Opacity % (0=invisible, 100=opaque)", minval = 0, maxval = 100, group = grp250)
i_width250   = input.int(2, "Line Width", minval = 1, maxval = 10, group = grp250)
i_style250   = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp250)

// ───────────────────────── STYLE: 500s ─────────────────────────
grp500 = "Style: 500s"
i_customColor500 = input.bool(true, "Use Custom Color", group = grp500)
i_color500   = input.color(#801922, "Color", group = grp500)
i_opacity500 = input.int(80, "Opacity % (0=invisible, 100=opaque)", minval = 0, maxval = 100, group = grp500)
i_width500   = input.int(2, "Line Width", minval = 1, maxval = 10, group = grp500)
i_style500   = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp500)

// ───────────────────────── STYLE: 1000s ─────────────────────────
grp1000 = "Style: 1000s"
i_customColor1000 = input.bool(true, "Use Custom Color", group = grp1000)
i_color1000   = input.color(#673ab7, "Color", group = grp1000)
i_opacity1000 = input.int(90, "Opacity % (0=invisible, 100=opaque)", minval = 0, maxval = 100, group = grp1000)
i_width1000   = input.int(3, "Line Width", minval = 1, maxval = 10, group = grp1000)
i_style1000   = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp1000)

// ───────────────────────── ALERTS ─────────────────────────
grpAlert = "Alerts"
i_enableAlerts = input.bool(true, "Enable Touch Alerts", group = grpAlert)

// ───────────────────────── HELPERS ─────────────────────────
f_lineStyle(string s) =>
    result = switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid
    result

f_labelSize(string s) =>
    result = switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small
    result

// Classifies a level into its finest round-number tier and returns that tier's configured
// color (or the global fallback color when "Use Custom Color" is off) / opacity / width / style.
f_tierStyle(float lvl) =>
    color  baseColor  = na
    int    opacityPct = na
    int    lwidth     = na
    string lstyleStr  = na
    if lvl % 1000 == 0
        baseColor  := i_customColor1000 ? i_color1000 : i_globalColor
        opacityPct := i_opacity1000
        lwidth     := i_width1000
        lstyleStr  := i_style1000
    else if lvl % 500 == 0
        baseColor  := i_customColor500 ? i_color500 : i_globalColor
        opacityPct := i_opacity500
        lwidth     := i_width500
        lstyleStr  := i_style500
    else if lvl % 250 == 0
        baseColor  := i_customColor250 ? i_color250 : i_globalColor
        opacityPct := i_opacity250
        lwidth     := i_width250
        lstyleStr  := i_style250
    else if lvl % 100 == 0
        baseColor  := i_customColor100 ? i_color100 : i_globalColor
        opacityPct := i_opacity100
        lwidth     := i_width100
        lstyleStr  := i_style100
    else
        baseColor  := i_customColor50 ? i_color50 : i_globalColor
        opacityPct := i_opacity50
        lwidth     := i_width50
        lstyleStr  := i_style50
    [baseColor, opacityPct, lwidth, f_lineStyle(lstyleStr)]

// ───────────────────────── PERSISTENT STATE ─────────────────────────
var array<line>  g_lines  = array.new_line()
var array<label> g_labels = array.new_label()
var array<float> g_levels = array.new_float()   // levels currently plotted on the chart

var float prevTouchedLevel = na            // used only to edge-trigger touch alerts

// Detect major-level touches for alerts. When one candle crosses several major levels,
// use the level closest to its close.
float touchedMajorThisBar = na
firstMajorInBar = math.ceil(low / 250) * 250
lastMajorInBar = math.floor(high / 250) * 250
if firstMajorInBar <= lastMajorInBar
    nearestMajorToClose = math.round(close / 250) * 250
    touchedMajorThisBar := math.max(firstMajorInBar, math.min(nearestMajorToClose, lastMajorInBar))

if na(touchedMajorThisBar)
    prevTouchedLevel := na
else if touchedMajorThisBar != prevTouchedLevel
    prevTouchedLevel := touchedMajorThisBar
    if i_enableAlerts
        alert(str.tostring(touchedMajorThisBar, format.mintick) + " has been touched", alert.freq_once_per_bar)

// ───────────────────────── BUILD + DRAW (last bar only) ─────────────────────────
if barstate.islast
    // Clear previous drawings
    if array.size(g_lines) > 0
        for ln in g_lines
            line.delete(ln)
        array.clear(g_lines)
    if array.size(g_labels) > 0
        for lb in g_labels
            label.delete(lb)
        array.clear(g_labels)

    // Build candidate level list — stepping by 50 automatically covers every 100/250/500/1000
    // level too (they're all multiples of 50), so a single grid is all that's needed.
    array<float> candLevels = array.new_float()
    base = math.round(close / 50) * 50
    for k = -i_maxLines to i_maxLines
        lvl = base + k * 50
        array.push(candLevels, lvl)

    array.clear(g_levels)

    n = array.size(candLevels)
    if n > 0
        array<float> dist = array.new_float(n)
        for i = 0 to n - 1
            array.set(dist, i, math.abs(array.get(candLevels, i) - close))
        idx  = array.sort_indices(dist)
        take = math.min(i_maxLines, n)

        for i = 0 to take - 1
            ii  = array.get(idx, i)
            lvl = array.get(candLevels, ii)
            array.push(g_levels, lvl)

        for i = 0 to array.size(g_levels) - 1
            lvl = array.get(g_levels, i)

            [baseColor, opacityPct, lwidth, lstyle] = f_tierStyle(lvl)

            lineColor = color.new(baseColor, 100 - opacityPct)

            x1 = bar_index - 300
            x2 = bar_index

            newLine = line.new(x1 = x1, y1 = lvl, x2 = x2, y2 = lvl, extend = extend.both, color = lineColor, style = lstyle, width = lwidth)
            array.push(g_lines, newLine)

            if i_showLabels
                labelX = i_labelHPos == "Left" ? bar_index - i_labelLeftOffsetBars : bar_index + i_labelRightOffsetBars
                labelStyle = i_labelVPos == "Above" ? label.style_label_down : i_labelVPos == "Below" ? label.style_label_up : label.style_label_center
                labelTextColor = i_useLineColorForLabel ? lineColor : i_labelColor
                labelBgColor = i_labelVPos == "Center" ? chart.bg_color : color.new(chart.bg_color, 100)

                newLabel = label.new(x = labelX, y = lvl, text = str.tostring(lvl, format.mintick),
                     xloc = xloc.bar_index, yloc = yloc.price, color = labelBgColor,
                     style = labelStyle, textcolor = labelTextColor, size = f_labelSize(i_labelSize))
                array.push(g_labels, newLabel)
````

# Adaptive Support and Resistance Zones [BigBeluga]

- url: https://www.tradingview.com/script/E8byEL6g-Adaptive-Support-and-Resistance-Zones-BigBeluga/
- type: indicator
- pine_id: PUB;1f0b95de6d18400b8b3c181cbc73750d
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[b]Adaptive Support and Resistance Zones [BigBeluga][/b] is a high-performance technical analysis tool designed to identify, manage, and visualize key supply and demand areas. Unlike static pivot indicators that clutter the chart with every minor high and low, this script employs volatility-adjusted logic (ATR) to ensure only the most significant structural levels are maintained.

[image]https://www.tradingview.com/x/7ynkt9dt/[/image]

The indicator treats support and resistance not as thin lines, but as [b]dynamic zones[/b], accounting for market "noise" and providing a clearer picture of where institutional interest actually lies.

[b]🔵 CONCEPT[/b]
[list]
[*] Volatility-Aware Detection — Uses ATR-based filtering to qualify pivot points. A level is only created if the price rejection is strong enough relative to current market volatility.
[*] Smart Level Merging — Automatically consolidates levels that are too close to one another, preventing "line spaghetti" and identifying high-confluence zones.
[*] Dynamic Zone Rendering — Visualizes S/R as shaded boxes. The width of these zones adapts to market volatility, providing a realistic representation of supply and demand.
[*] Real-Time Breakout Tracking — Monitors price action in real-time to detect when a level is definitively breached, switching its status from "Active" to "Broken."
[*] Automatic Pruning — Cleans the chart by removing levels that have exceeded a maximum age, ensuring your focus remains on current market structure.
[/list]

[b]🔵 HOW IT WORKS (IN-DEPTH)[/b]

[b]1️⃣ Advanced Swing Detection[/b]
[list]
[*] The indicator scans for Pivot Highs and Lows based on a user-defined Pivot Length.
[*] [b]The Strength Filter:[/b] It applies a "Min ATR Strength" check. For a pivot to be valid, the distance between the pivot point and its immediate neighbors must exceed a mathematical threshold of volatility. This filters out "fake" pivots during low-volume consolidation.
[image]https://www.tradingview.com/x/bWLFJJMX/[/image]
[/list]

[b]2️⃣ Adaptive Level Management[/b]
[list]
[*] [b]Merge Logic:[/b] Before a new level is drawn, the script checks if an existing level already exists within the "Merge Threshold." If it does, the indicator skips the new level, effectively treating the existing zone as the dominant area of interest.
[image]https://www.tradingview.com/x/ojMRV2Re/[/image]
[*] [b]Active vs. Broken:[/b] Levels remain "Active" as solid lines/zones as long as price respects them. Once price closes beyond the level (controlled by Break Sensitivity), the level is moved to the "Broken" category.
[*] [b]Visual Transition:[/b] Broken levels can be kept on the chart as muted, dotted lines—a crucial feature for traders who look for "S/R Flip" opportunities (where old resistance becomes new support).
[image]https://www.tradingview.com/x/7wZXpS8y/[/image]
[/list]

[b]3️⃣ The S/R Dashboard[/b]
[list]
[*] A dedicated on-screen table provides a birds-eye view of the current structural state.
[*] [b]Nearest Resistance/Support:[/b] Displays the exact price of the closest active levels.
[*] [b]Last Break:[/b] Identifies the direction of the most recent volatility-confirmed breakout.
[*] [b]Active Counter:[/b] Keeps track of how many structural levels are currently being monitored by the system.
[image]https://www.tradingview.com/x/RzL5HRnN/[/image]
[/list]

[b]🔵 KEY FEATURES[/b]
[list]
[*] ATR-Based Zone Width: Zones expand and contract based on market volatility, ensuring your stop-loss or entry buffers are mathematically sound.
[*] Price Labels: Optional labels at the end of active lines provide the exact price for quick order entry.
[*] Customizable Break Sensitivity: Define how much "daylight" price needs to show above or below a level before a breakout is confirmed.
[*] Historical Record: Retain a specific number of recently broken levels to identify long-term historical confluence.
[*] Clean Visuals: High-contrast colors for Support (Cyan) and Resistance (Orange), with fully customizable transparency.
[/list]

[b]🔵 HOW TO USE[/b]
[list]
[*] [b]Trading the Rejection:[/b] Look for price to enter a shaded Support or Resistance Zone. Wait for a reversal candle within the zone for a high-probability entry back toward the mean.
[*] [b]Trading the Breakout:[/b] When the "< Break" label appears, it confirms that price has closed beyond the zone with enough momentum to overcome the "Break Sensitivity" threshold.
[*] [b]The S/R Flip:[/b] Monitor "Broken" (dotted) levels. If price returns to a dotted Resistance line and treats it as Support, it confirms a structural shift in the market.
[*] [b]Volatility Buffers:[/b] Use the vertical height of the Zone Boxes to determine your "No-Trade Zone" or to help place stop-losses outside of the immediate area of market noise.
[/list]

[b]🔵 CONCLUSION[/b]
[b]Adaptive Support and Resistance Zones [BigBeluga][/b] transforms raw price action into an organized, data-driven roadmap. By automating the detection and management of key levels—while accounting for the ever-changing nature of market volatility—it allows traders to focus on execution rather than manual charting.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga 

//@version=6
indicator("Adaptive S/R Zones [BigBeluga]", shorttitle="Adaptive S/R [BigBeluga]", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=200)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

var grpSwing = "Swing Detection"
pivotLen     = input.int(5,   "Pivot Length",      minval=2, maxval=50,   group=grpSwing, tooltip="The number of bars on each side of a high or low to confirm a pivot point.")
minStrength  = input.float(0.1, "Min ATR Strength", minval=0.0, maxval=5.0, step=0.05, group=grpSwing, tooltip="Minimum distance required between the pivot and its neighbors.")
maxAgeBars   = input.int(300, "Max Level Age (bars)", minval=20, maxval=2000, group=grpSwing, tooltip="Maximum bars a level exists before removal. Also used to calculate longevity scaling.")

var grpLevels = "Levels"
showSupport  = input.bool(true,  "Show Support Levels",    group=grpLevels)
showResist   = input.bool(true,  "Show Resistance Levels", group=grpLevels)
maxLevels    = input.int(5,      "Max Active Levels Each", minval=1, maxval=20, group=grpLevels)
mergeThresh  = input.float(0.5,  "Merge Threshold (ATR x)", minval=0.0, maxval=3.0, step=0.05, group=grpLevels)
showZones    = input.bool(true,  "Show Level Zones",       group=grpLevels)
zoneWidth    = input.float(0.25, "Zone Width (ATR x)",     minval=0.05, maxval=2.0, step=0.05, group=grpLevels)

var grpBreak = "Breakouts"
showBroken   = input.bool(true,  "Show Broken Levels",         group=grpBreak)
breakSens    = input.float(0.1,  "Break Sensitivity (ATR x)",  minval=0.0, maxval=2.0, step=0.05, group=grpBreak)
showBreakLbl = input.bool(true,  "Show Break Labels",          group=grpBreak)
maxBroken    = input.int(4,      "Max Broken Levels Shown",    minval=0, maxval=20, group=grpBreak)

var grpVis = "Visuals"
supColor     = input.color(color.new(#22bac5, 0),  "Support Color",         group=grpVis)
resColor     = input.color(color.new(#ff6f43, 0),  "Resistance Color",      group=grpVis)
brokenColor  = input.color(color.new(#94a3b8, 0),  "Broken Level Color",    group=grpVis)
lineWidth    = input.int(2, "Base Line Width",     minval=1, maxval=5,      group=grpVis, tooltip="Used when Longevity Scaling is OFF.")

//  NEW LONGEVITY INPUTS 
useDynamicWidth = input.bool(true, "Enable Longevity Width", group=grpVis, tooltip="When enabled, older levels become thicker over time.")
maxLineWidth    = input.int(7, "Max Longevity Width", minval=1, maxval=10, group=grpVis, tooltip="The maximum thickness an old level can reach.")

showDash     = input.bool(true, "Show Dashboard",   group=grpVis)
showPriceLbl = input.bool(true, "Show Price Labels on Active Levels", group=grpVis)

var grpDash = "Dashboard"
dashPos      = input.string("Bottom Right", "Dashboard Position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=grpDash)

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

type SRLevel
    float  price
    int    barStart
    int    levelType
    bool   active
    bool   broken
    int    breakBar
    bool   retested
    line   mainLine
    box    zoneBox
    label  breakLabel
    label  priceLabel

var array<SRLevel> activeLevels = array.new<SRLevel>()
var array<SRLevel> brokenLevels = array.new<SRLevel>()
var string         lastBreakDir = "—"
var int            lastBreakBar = na

atrVal  = ta.atr(14)
atrSafe = na(atrVal) or atrVal == 0 ? syminfo.mintick * 10 : atrVal

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

f_isTooClose(_price, _type) =>
    bool tooClose = false
    int  sz = array.size(activeLevels)
    if sz > 0
        for i = 0 to sz - 1
            lvl = array.get(activeLevels, i)
            if lvl.levelType == _type and lvl.active
                if math.abs(lvl.price - _price) < mergeThresh * atrSafe
                    tooClose := true
                    break
    tooClose

f_addLevel(_price, _type, _barIdx) =>
    if not f_isTooClose(_price, _type)
        int sz  = array.size(activeLevels)
        int cnt = 0
        if sz > 0
            for i = 0 to sz - 1
                lvl = array.get(activeLevels, i)
                if lvl.levelType == _type and lvl.active
                    cnt += 1

        if cnt < maxLevels
            _baseColor = _type == 1 ? resColor : supColor
            _zoneTop   = _price + zoneWidth * atrSafe * 0.5
            _zoneBot   = _price - zoneWidth * atrSafe * 0.5

            newLine = line.new(
                 x1     = _barIdx,
                 y1     = _price,
                 x2     = _barIdx + 1,
                 y2     = _price,
                 extend = extend.right,
                 color  = color.new(_baseColor, 0),
                 width  = lineWidth,
                 style  = line.style_solid
             )

            newBox = showZones ? box.new(
                 left         = _barIdx,
                 top          = _zoneTop,
                 right        = _barIdx + 1,
                 bottom       = _zoneBot,
                 border_color = color.new(_baseColor, 90),
                 bgcolor      = color.new(_baseColor, 88),
                 extend       = extend.right
             ) : na

            newPriceLbl = showPriceLbl ? label.new(
                 x         = bar_index + 20,
                 y         = _price,
                 text      = str.tostring(_price, format.mintick),
                 style     = label.style_label_center,
                 textcolor = _baseColor,
                 color     = color.new(chart.bg_color, 0),
                 size      = size.small
             ) : na

            array.push(activeLevels, SRLevel.new(
                 price      = _price,
                 barStart   = _barIdx,
                 levelType  = _type,
                 active     = true,
                 broken     = false,
                 breakBar   = na,
                 retested   = false,
                 mainLine   = newLine,
                 zoneBox    = newBox,
                 breakLabel = na,
                 priceLabel = newPriceLbl
             ))

f_pivotStrong(_price, _type) =>
    bool strong = true
    if minStrength > 0
        if _type == 1
            nearHigh = math.max(high[pivotLen - 1], high[pivotLen + 1])
            if (_price - nearHigh) < minStrength * atrSafe
                strong := false
        else
            nearLow = math.min(low[pivotLen - 1], low[pivotLen + 1])
            if (nearLow - _price) < minStrength * atrSafe
                strong := false
    strong

// Prune old levels
int pruneSize = array.size(activeLevels)
if pruneSize > 0
    for i = pruneSize - 1 to 0
        if i < array.size(activeLevels)
            lvl = array.get(activeLevels, i)
            if lvl.active and (bar_index - lvl.barStart) > maxAgeBars
                line.delete(lvl.mainLine)
                if not na(lvl.zoneBox)
                    box.delete(lvl.zoneBox)
                if not na(lvl.priceLabel)
                    label.delete(lvl.priceLabel)
                array.remove(activeLevels, i)

// Add new pivots
if not na(ph) and showResist
    if f_pivotStrong(ph, 1)
        f_addLevel(ph, 1, bar_index - pivotLen)

if not na(pl) and showSupport
    if f_pivotStrong(pl, -1)
        f_addLevel(pl, -1, bar_index - pivotLen)

// Breakout logic
int activeSize = array.size(activeLevels)
if activeSize > 0
    for i = activeSize - 1 to 0
        if i >= array.size(activeLevels)
            continue
        lvl = array.get(activeLevels, i)
        if not lvl.active
            continue

        breakBuffer = breakSens * atrSafe

        if lvl.levelType == 1 and close > lvl.price + breakBuffer
            lvl.active   := false
            lvl.broken   := true
            lvl.breakBar := bar_index
            lastBreakDir := "Bullish"
            lastBreakBar := bar_index

            if not na(lvl.priceLabel)
                label.delete(lvl.priceLabel)
                lvl.priceLabel := na

            line.set_color(lvl.mainLine,  color.new(brokenColor, 0))
            line.set_style(lvl.mainLine,  line.style_dotted)
            line.set_width(lvl.mainLine,  1)
            line.set_extend(lvl.mainLine, extend.none)
            line.set_x2(lvl.mainLine,     bar_index)

            if not na(lvl.zoneBox)
                box.set_bgcolor(lvl.zoneBox,       color.new(brokenColor, 93))
                box.set_border_color(lvl.zoneBox,  color.new(brokenColor, 100))
                box.set_extend(lvl.zoneBox,        extend.none)
                box.set_right(lvl.zoneBox,         bar_index)
                mid = math.avg(lvl.zoneBox.get_top(), lvl.zoneBox.get_bottom())
                lvl.zoneBox.set_top(mid + breakBuffer)
                lvl.zoneBox.set_bottom(mid - breakBuffer)
                
            if showBreakLbl
                lvl.breakLabel := label.new(
                     x         = bar_index,
                     y         = lvl.price,
                     text      = "< Break",
                     style     = label.style_label_left,
                     textcolor = supColor,
                     color     = color.new(#22c55e, 100),
                     size      = size.small
                 )

            if showBroken
                array.push(brokenLevels, lvl)
                if array.size(brokenLevels) > maxBroken and array.size(brokenLevels) > 0
                    old = array.shift(brokenLevels)
                    if not na(old.mainLine)
                        line.delete(old.mainLine)
                    if not na(old.zoneBox)
                        box.delete(old.zoneBox)
                    if not na(old.breakLabel)
                        label.delete(old.breakLabel)
            else
                line.delete(lvl.mainLine)
                
                if not na(lvl.zoneBox)
                    box.delete(lvl.zoneBox)

            array.remove(activeLevels, i)

        else if lvl.levelType == -1 and close < lvl.price - breakBuffer
            lvl.active   := false
            lvl.broken   := true
            lvl.breakBar := bar_index
            lastBreakDir := "Bearish"
            lastBreakBar := bar_index

            if not na(lvl.priceLabel)
                label.delete(lvl.priceLabel)
                lvl.priceLabel := na

            line.set_color(lvl.mainLine,  color.new(brokenColor, 0))
            line.set_style(lvl.mainLine,  line.style_dotted)
            line.set_width(lvl.mainLine,  1)
            line.set_extend(lvl.mainLine, extend.none)
            line.set_x2(lvl.mainLine,     bar_index)

            if not na(lvl.zoneBox)
                box.set_bgcolor(lvl.zoneBox,       color.new(brokenColor, 93))
                box.set_border_color(lvl.zoneBox,  color.new(brokenColor, 100))
                box.set_extend(lvl.zoneBox,        extend.none)
                box.set_right(lvl.zoneBox,         bar_index)
                mid = math.avg(lvl.zoneBox.get_top(), lvl.zoneBox.get_bottom())
                lvl.zoneBox.set_top(mid + breakBuffer)
                lvl.zoneBox.set_bottom(mid - breakBuffer)
                
            if showBreakLbl
                lvl.breakLabel := label.new(
                     x         = bar_index,
                     y         = lvl.price,
                     text      = "< Break",
                     style     = label.style_label_left,
                     textcolor = resColor,
                     color     = color.new(#ef4444, 100),
                     size      = size.small
                 )

            if showBroken
                array.push(brokenLevels, lvl)
                if array.size(brokenLevels) > maxBroken and array.size(brokenLevels) > 0
                    old = array.shift(brokenLevels)
                    if not na(old.mainLine)
                        line.delete(old.mainLine)
                    if not na(old.zoneBox)
                        box.delete(old.zoneBox)
                    if not na(old.breakLabel)
                        label.delete(old.breakLabel)
            else
                line.delete(lvl.mainLine)
                if not na(lvl.zoneBox)
                    box.delete(lvl.zoneBox)

            array.remove(activeLevels, i)

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Extend visuals on active levels
int extSize = array.size(activeLevels)
if extSize > 0
    for i = 0 to extSize - 1
        lvl = array.get(activeLevels, i)
        if lvl.active
            //  DYNAMIC LONGEVITY WIDTH CALCULATION 
            if useDynamicWidth
                age = bar_index - lvl.barStart
                // Scale width from 1 to maxLineWidth based on maxAgeBars
                calcWidth = math.min(maxLineWidth, 1 + math.floor((age / maxAgeBars) * (maxLineWidth - 1)))
                line.set_width(lvl.mainLine, int(calcWidth))
            else
                line.set_width(lvl.mainLine, lineWidth)

            line.set_x2(lvl.mainLine, bar_index + 1)
            if not na(lvl.zoneBox)
                box.set_right(lvl.zoneBox, bar_index + 1)
            if showPriceLbl and not na(lvl.priceLabel)
                label.set_x(lvl.priceLabel, bar_index + 10)

var float nearestSup = na
var float nearestRes = na

nearestSup := na
nearestRes := na

// Dashboard scanning
int dashScanSize = array.size(activeLevels)
if dashScanSize > 0
    for i = 0 to dashScanSize - 1
        lvl = array.get(activeLevels, i)
        if not lvl.active
            continue
        if lvl.levelType == -1 and lvl.price < close
            if na(nearestSup) or lvl.price > nearestSup
                nearestSup := lvl.price
        if lvl.levelType == 1 and lvl.price > close
            if na(nearestRes) or lvl.price < nearestRes
                nearestRes := lvl.price

// Draw Dashboard
var table dashTable = na

if showDash
    tablePos = switch dashPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

    if barstate.isfirst
        dashTable := table.new(
             position     = tablePos,
             columns      = 2,
             rows         = 5,
             bgcolor      = color.new(#0d1117, 5),
             border_color = color.new(#30363d, 40),
             border_width = 1,
             frame_color  = color.new(#30363d, 20),
             frame_width  = 1
         )

    if barstate.islast and not na(dashTable)
        table.cell(dashTable, 0, 0, "S/R Dashboard", text_color=color.new(#f0f6fc, 0), text_size=size.normal, bgcolor=color.new(#161b22, 0), text_halign=text.align_center)
        table.merge_cells(dashTable, 0, 0, 1, 0)

        table.cell(dashTable, 0, 1, "Resistance", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 1,
             na(nearestRes) ? "—" : str.tostring(nearestRes, format.mintick),
             text_color  = na(nearestRes) ? color.new(#484f58, 0) : resColor,
             text_size   = size.normal,
             bgcolor     = color.new(#0d1117, 10),
             text_halign = text.align_right
         )

        table.cell(dashTable, 0, 2, "Support", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 2,
             na(nearestSup) ? "—" : str.tostring(nearestSup, format.mintick),
             text_color  = na(nearestSup) ? color.new(#484f58, 0) : supColor,
             text_size   = size.normal,
             bgcolor     = color.new(#0d1117, 10),
             text_halign = text.align_right
         )

        table.cell(dashTable, 0, 3, "Last Break", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        breakDirColor = lastBreakDir == "Bullish" ? supColor : lastBreakDir == "Bearish" ? resColor : color.new(#484f58, 0)
        table.cell(dashTable, 1, 3, lastBreakDir, text_color=breakDirColor, text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        activeCnt = array.size(activeLevels)
        table.cell(dashTable, 0, 4, "Active Levels", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 4, str.tostring(activeCnt), text_color=color.new(#f0f6fc, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

// }
````

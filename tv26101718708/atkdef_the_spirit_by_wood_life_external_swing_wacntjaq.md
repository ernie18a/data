# ATK/DEF The Spirit by Wood Life External Swing 

- url: https://www.tradingview.com/script/WaCNtjaq/
- type: indicator
- pine_id: PUB;6e31bbbc4486486ab4e63267e7e03989
- version: 1.0

## Description

ATK/DEF The Spirit by Wood Life External Swing

Overview

ATK/DEF The Spirit by Wood Life External Swing is a market structure observation framework that combines External Swing tracking, SH/SL lifecycle progression, structural HIGH/LOW identification, and Fair Value Gap (FVG) Seed Growth.

The framework represents external market structure through a lifecycle-based model, connecting swing formation, repeated interaction, structural weakening, transition, and renewal with a seed-growth process applied to bullish and bearish FVG zones.

Wood Life defines the underlying concept: structures are observed as evolving processes rather than isolated price levels.                                                    
                                                                                                                                                                       Defining Conditions

External Swing

Identifies confirmed external swing highs and lows through configurable pivot lengths. Dashed reference lines and SH/SL labels represent the detected structural points. ATR-based deduplication filters nearby swing points according to the selected threshold.     
                                                                                     https://www.tradingview.com/x/7WP2R78R/ 
                   
 SH/SL Lifecycle

Tracks the evolving conditions of each recorded swing point.

SH: SH → Exhaustion → Weakening → Degradation → Departure → Reset.

SL: SL → Growth → Boost → Evolution → Return → Reset.

State transitions are determined by price interaction, closing-price relationships, touch counts, and ATR-based reset distance.

HIGH / LOW Tracking

Identifies the highest unbroken SH and lowest unbroken SL among the retained structural points. The structure table displays reference prices, lifecycle stages, and current broken or active status.               
                                                                                                           https://www.tradingview.com/x/OHoH4OGw/  

FVG Seed Growth

Detects bullish and bearish Fair Value Gaps and associates each zone with a lifecycle sequence:

Seed → Field → Sow → Bury → Sprout → Root → Break Soil → Grow → Branch → Bloom → Fruit → Fall.

Additional states represent Wither and Rot, while qualifying conditions can return the displayed lifecycle to its initial stage.     

 https://www.tradingview.com/x/oe9GQ0PF/           

 Structure Management

Configurable settings control swing sensitivity, reference-line length, deduplication, lifecycle thresholds, FVG dimensions, confirmation counts, retained points, and table presentation.

Output Results

External SH/SL reference lines and lifecycle labels.

Dynamic HIGH/LOW identification among unbroken recorded swing points.

A structural table containing prices, lifecycle stages, and status.

Bullish and bearish FVG zones with Seed Growth stage labels.

Configurable visual distinctions for structural states and FVG regions.

Next Task / Action Framework

WATCH — Observe the formation of external swing points and new FVG zones.

WAIT — Track developing structural conditions before a lifecycle transition is registered.

TRACK — Monitor SH/SL interactions, repeated touches, lifecycle progression, and FVG development.

CONFIRM — Observe when the model's defined price and threshold conditions establish a new state.

RECHECK — Reassess active structural references, lifecycle status, and FVG zone persistence as market conditions change.

Scope

Designed for market observation and structural analysis through external swing relationships, lifecycle classification, and FVG development.

## Source Code

````pine
/// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF The Spirit by Wood Life External Swing ", shorttitle="ATK/DEF Wood Element External Seed Growth", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
grpExt = "External Swing"
externalLen     = input.int(25, "External Swing Length", minval=1, group=grpExt)
externalLineLen = input.int(14, "Dashed Line Length (bars)", minval=2, group=grpExt)
externalColor   = input.color(color.new(color.blue, 0), "External Color", group=grpExt)
highColor       = input.color(color.new(color.yellow, 0), "HIGH Color", group=grpExt)
lowColor        = input.color(color.new(color.orange, 0), "LOW Color", group=grpExt)
labelSize       = input.string("small", "Text Size", options=["tiny", "small", "normal", "large"], group=grpExt)

grpDedup = "Same-Price Dedup"
dedupEnable = input.bool(true, "Enable Dedup", group=grpDedup)
dedupATR    = input.float(0.5, "Same-Price Threshold (ATR mult)", minval=0.0, step=0.1, group=grpDedup)
atrLen      = input.int(14, "ATR Length", minval=1, group=grpDedup)

grpHL = "HIGH / LOW Tracking"
trackHL     = input.bool(true, "Enable HIGH/LOW Tracking", group=grpHL)
maxTrack    = input.int(100, "Max Tracked Points", minval=5, maxval=300, group=grpHL)

grpLife = "SH/SL Lifecycle"
enableLife     = input.bool(true, "Enable Lifecycle State Machine", group=grpLife)
touchMulti     = input.int(2, "Touches Required for Weaken/Boost", minval=2, group=grpLife)
farResetATR    = input.float(1.0, "Reset Distance (ATR mult)", minval=0.1, step=0.1, group=grpLife)

cSH      = input.color(color.new(color.red, 0),    "SH Color",          group=grpLife)
cExhaust = input.color(color.new(color.orange, 0), "Exhaustion Color",  group=grpLife)
cWeaken  = input.color(color.new(color.yellow, 0), "Weakening Color",   group=grpLife)
cDegrade = input.color(color.new(color.purple, 0), "Degradation Color", group=grpLife)
cLeave   = input.color(color.new(color.gray, 0),   "Departure Color",   group=grpLife)
cResetH  = input.color(color.new(color.blue, 0),   "Reset-H Color",     group=grpLife)

cSL      = input.color(color.new(color.green, 0),  "SL Color",          group=grpLife)
cGrow    = input.color(color.new(color.lime, 0),   "Growth Color",      group=grpLife)
cBoost   = input.color(color.new(color.teal, 0),   "Boost Color",       group=grpLife)
cEvolve  = input.color(color.new(color.olive, 0),  "Evolution Color",   group=grpLife)
cReturn  = input.color(color.new(color.gray, 0),   "Return Color",      group=grpLife)
cResetL  = input.color(color.new(color.blue, 0),   "Reset-L Color",     group=grpLife)

grpFVG = "FVG Seed Growth"
showFVG        = input.bool(true, "Show FVG Seed Process", group=grpFVG)
fvgBullColor   = input.color(color.new(color.green, 80), "Bullish FVG Color", group=grpFVG)
fvgBearColor   = input.color(color.new(color.red, 80),   "Bearish FVG Color", group=grpFVG)
fvgBorder      = input.bool(true, "FVG Border", group=grpFVG)
fvgBoxWidth    = input.int(10, "FVG Box Width (bars)", minval=1, maxval=50, group=grpFVG)
fvgMinSizeATR  = input.float(0.0, "FVG Min Size (ATR mult)", minval=0.0, step=0.1, group=grpFVG)
fvgLabelSize   = input.string("tiny", "FVG Label Size", options=["tiny","small","normal","large"], group=grpFVG)
fvgAcceptBars  = input.int(3, "Burial Confirm Bars", minval=1, group=grpFVG)
fvgConflictBars= input.int(2, "Wither Confirm Bars", minval=1, group=grpFVG)
fvgFarATR      = input.float(1.0, "Far Distance (ATR mult)", minval=0.1, step=0.1, group=grpFVG)
fvgMaxKeep     = input.int(50, "Max FVG Kept", minval=1, maxval=500, group=grpFVG)

grpTable = "Structure Table"
showTable   = input.bool(true, "Show Structure Table", group=grpTable)
tableRows   = input.int(3, "Rows per Side (SH/SL)", minval=1, maxval=10, group=grpTable)
tablePos    = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpTable)
tableSize   = input.string("small", "Text Size", options=["tiny","small","normal","large"], group=grpTable)

// ═══════════════════════════ TYPES ═══════════════════════════
type SwingPoint
    float price
    label lbl
    line  ln
    bool  broken
    int   stage
    int   touches

// ═══════════════════════════ HELPERS ═══════════════════════════
f_size(string s) =>
    string result = s
    switch result
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        => size.large

t_size(string s) =>
    string result = s
    switch result
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        => size.large

t_pos(string s) =>
    switch s
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        => position.middle_right

// ═══════════════════════════ ATR ═══════════════════════════
atrVal     = ta.atr(atrLen)
fvgMinSize = atrVal * fvgMinSizeATR
fvgFarDist = atrVal * fvgFarATR
farReset   = atrVal * farResetATR

// ═══════════════════════════ STATE ═══════════════════════════
var float lastHigh = na
var float lastLow  = na

var array<SwingPoint> shPoints = array.new<SwingPoint>()
var array<SwingPoint> slPoints = array.new<SwingPoint>()

// ═══════════════════════════ LABEL / COLOR MAPPERS ═══════════════════════════
shText(int st) =>
    switch st
        0 => "SH"
        1 => "SH Exhaustion"
        2 => "SH Weakening"
        3 => "SH Degradation"
        4 => "SH Departure"
        => "SH Reset"

shShort(int st) =>
    switch st
        0 => "SH"
        1 => "Exhaustion"
        2 => "Weakening"
        3 => "Degradation"
        4 => "Departure"
        => "Reset"

shColor(int st) =>
    switch st
        0 => cSH
        1 => cExhaust
        2 => cWeaken
        3 => cDegrade
        4 => cLeave
        => cResetH

slText(int st) =>
    switch st
        0 => "SL"
        1 => "SL Growth"
        2 => "SL Boost"
        3 => "SL Evolution"
        4 => "SL Return"
        => "SL Reset"

slShort(int st) =>
    switch st
        0 => "SL"
        1 => "Growth"
        2 => "Boost"
        3 => "Evolution"
        4 => "Return"
        => "Reset"

slColor(int st) =>
    switch st
        0 => cSL
        1 => cGrow
        2 => cBoost
        3 => cEvolve
        4 => cReturn
        => cResetL

bullTxt(int st) =>
    switch st
        1  => "FVG ↑ Seed → Field"
        2  => "FVG ↑ Seed → Field"
        3  => "FVG ↑ Field → Sow"
        4  => "FVG ↑ Sow → Bury"
        5  => "FVG ↑ Bury → Sprout"
        6  => "FVG ↑ Sprout → Root"
        7  => "FVG ↑ Root → Break Soil"
        8  => "FVG ↑ Break Soil → Grow"
        9  => "FVG ↑ Grow → Branch"
        10 => "FVG ↑ Branch → Bloom"
        11 => "FVG ↑ Bloom → Fruit"
        12 => "FVG ↑ Fruit → Fall 🔁"
        13 => "FVG ↑ Wither"
        => "FVG ↑ Rot"

bearTxt(int st) =>
    switch st
        1  => "FVG ↓ Seed → Field"
        2  => "FVG ↓ Seed → Field"
        3  => "FVG ↓ Field → Sow"
        4  => "FVG ↓ Sow → Bury"
        5  => "FVG ↓ Bury → Sprout"
        6  => "FVG ↓ Sprout → Root"
        7  => "FVG ↓ Root → Break Soil"
        8  => "FVG ↓ Break Soil → Grow"
        9  => "FVG ↓ Grow → Branch"
        10 => "FVG ↓ Branch → Bloom"
        11 => "FVG ↓ Bloom → Fruit"
        12 => "FVG ↓ Fruit → Fall 🔁"
        13 => "FVG ↓ Wither"
        => "FVG ↓ Rot"

// ═══════════════════════════ EXTERNAL SWING ═══════════════════════════
externalHighPt = ta.pivothigh(high, externalLen, externalLen)
externalLowPt  = ta.pivotlow(low, externalLen, externalLen)

if not na(externalHighPt)
    bool isDup = dedupEnable and not na(lastHigh) and not na(atrVal) and math.abs(externalHighPt - lastHigh) < atrVal * dedupATR
    if not isDup
        int pBar = bar_index - externalLen
        line ln = line.new(pBar, externalHighPt, pBar + externalLineLen, externalHighPt, color=externalColor, style=line.style_dashed, width=2)
        label lbl = label.new(pBar + externalLineLen, externalHighPt, "SH", style=label.style_label_left, size=f_size(labelSize), color=color.new(cSH, 10), textcolor=color.white)
        SwingPoint sp = SwingPoint.new(externalHighPt, lbl, ln, false, 0, 0)
        array.push(shPoints, sp)
        lastHigh := externalHighPt

if not na(externalLowPt)
    bool isDup = dedupEnable and not na(lastLow) and not na(atrVal) and math.abs(externalLowPt - lastLow) < atrVal * dedupATR
    if not isDup
        int pBar = bar_index - externalLen
        line ln = line.new(pBar, externalLowPt, pBar + externalLineLen, externalLowPt, color=externalColor, style=line.style_dashed, width=2)
        label lbl = label.new(pBar + externalLineLen, externalLowPt, "SL", style=label.style_label_left, size=f_size(labelSize), color=color.new(cSL, 10), textcolor=color.white)
        SwingPoint sp = SwingPoint.new(externalLowPt, lbl, ln, false, 0, 0)
        array.push(slPoints, sp)
        lastLow := externalLowPt

// ═══════════════════════════ SH LIFECYCLE ═══════════════════════════
if enableLife and array.size(shPoints) > 0
    int i = 0
    while i < array.size(shPoints)
        SwingPoint sp = array.get(shPoints, i)
        float p = sp.price
        int st = sp.stage
        if not sp.broken and close > p
            sp.broken := true
        if st == 0
            if high >= p and close < p
                sp.stage := 1
                sp.touches := 1
        else if st == 1
            if high >= p and close < p
                sp.touches += 1
                if sp.touches >= touchMulti
                    sp.stage := 2
                    sp.touches := 0
            else if close >= p * 0.998 and close < p
                sp.stage := 3
                sp.touches := 0
        else if st == 2
            if close >= p * 0.998 and close < p
                sp.stage := 3
                sp.touches := 0
        else if st == 3
            if close > p
                sp.stage := 4
                sp.touches := 0
        else if st == 4
            if close > p + farReset
                sp.stage := 5
                sp.touches := 0
        else if st == 5
            if low <= p
                sp.stage := 0
                sp.touches := 0
        i += 1

// ═══════════════════════════ SL LIFECYCLE ═══════════════════════════
if enableLife and array.size(slPoints) > 0
    int i = 0
    while i < array.size(slPoints)
        SwingPoint sp = array.get(slPoints, i)
        float p = sp.price
        int st = sp.stage
        if not sp.broken and close < p
            sp.broken := true
        if st == 0
            if low <= p and close > p
                sp.stage := 1
                sp.touches := 1
        else if st == 1
            if low <= p and close > p
                sp.touches += 1
                if sp.touches >= touchMulti
                    sp.stage := 2
                    sp.touches := 0
            else if close <= p * 1.002 and close > p
                sp.stage := 3
                sp.touches := 0
        else if st == 2
            if close <= p * 1.002 and close > p
                sp.stage := 3
                sp.touches := 0
        else if st == 3
            if close < p
                sp.stage := 4
                sp.touches := 0
        else if st == 4
            if close < p - farReset
                sp.stage := 5
                sp.touches := 0
        else if st == 5
            if high >= p
                sp.stage := 0
                sp.touches := 0
        i += 1

// ═══════════════════════════ HIGH / LOW ═══════════════════════════
float highestSH = na
int   highestSHIdx = -1
float lowestSL = na
int   lowestSLIdx = -1

if trackHL
    if array.size(shPoints) > 0
        int n = array.size(shPoints)
        for i = 0 to n - 1
            SwingPoint sp = array.get(shPoints, i)
            if not sp.broken
                if na(highestSH) or sp.price > highestSH
                    highestSH := sp.price
                    highestSHIdx := i
    if array.size(slPoints) > 0
        int n = array.size(slPoints)
        for i = 0 to n - 1
            SwingPoint sp = array.get(slPoints, i)
            if not sp.broken
                if na(lowestSL) or sp.price < lowestSL
                    lowestSL := sp.price
                    lowestSLIdx := i

// ═══════════════════════════ LABEL REFRESH ═══════════════════════════
if barstate.islast
    if array.size(shPoints) > 0
        int n = array.size(shPoints)
        for i = 0 to n - 1
            SwingPoint sp = array.get(shPoints, i)
            string baseTxt = shText(sp.stage)
            color  baseCol = shColor(sp.stage)
            if trackHL and i == highestSHIdx
                label.set_text(sp.lbl, "HIGH\n" + baseTxt)
                label.set_color(sp.lbl, highColor)
                label.set_textcolor(sp.lbl, color.black)
            else
                label.set_text(sp.lbl, baseTxt)
                label.set_color(sp.lbl, color.new(baseCol, 10))
                label.set_textcolor(sp.lbl, color.white)
    if array.size(slPoints) > 0
        int n = array.size(slPoints)
        for i = 0 to n - 1
            SwingPoint sp = array.get(slPoints, i)
            string baseTxt = slText(sp.stage)
            color  baseCol = slColor(sp.stage)
            if trackHL and i == lowestSLIdx
                label.set_text(sp.lbl, "LOW\n" + baseTxt)
                label.set_color(sp.lbl, lowColor)
                label.set_textcolor(sp.lbl, color.black)
            else
                label.set_text(sp.lbl, baseTxt)
                label.set_color(sp.lbl, color.new(baseCol, 10))
                label.set_textcolor(sp.lbl, color.white)

// ═══════════════════════════ FIFO ═══════════════════════════
while array.size(shPoints) > maxTrack
    SwingPoint sp = array.shift(shPoints)
    label.delete(sp.lbl)
    line.delete(sp.ln)
while array.size(slPoints) > maxTrack
    SwingPoint sp = array.shift(slPoints)
    label.delete(sp.lbl)
    line.delete(sp.ln)

// ═══════════════════════════ STRUCTURE TABLE ═══════════════════════════
var table structTable = table.new(t_pos(tablePos), 4, 2 + tableRows * 2, border_width=1)

if showTable and barstate.islast
    color hdrBg = color.new(color.blue, 20)
    // 表头
    table.cell(structTable, 0, 0, "Structure", text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 1, 0, "Price",     text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 2, 0, "Stage",     text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))
    table.cell(structTable, 3, 0, "Status",    text_color=color.white, bgcolor=hdrBg, text_size=t_size(tableSize))

    // SH 区（HIGH 优先，然后最近 N-1 个）
    int shN = array.size(shPoints)
    int rowSH = 0
    if shN > 0
        // 先放 HIGH
        if trackHL and highestSHIdx >= 0
            SwingPoint spH = array.get(shPoints, highestSHIdx)
            float d = (spH.price - close) / close * 100
            string stat = spH.broken ? "Broken" : ("Active " + (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%")
            table.cell(structTable, 0, 1 + rowSH, "HIGH", text_color=color.black, bgcolor=highColor, text_size=t_size(tableSize))
            table.cell(structTable, 1, 1 + rowSH, str.tostring(spH.price, format.mintick), text_color=color.black, bgcolor=highColor, text_size=t_size(tableSize))
            table.cell(structTable, 2, 1 + rowSH, shShort(spH.stage), text_color=color.black, bgcolor=highColor, text_size=t_size(tableSize))
            table.cell(structTable, 3, 1 + rowSH, stat, text_color=color.black, bgcolor=highColor, text_size=t_size(tableSize))
            rowSH += 1

        // 再从最近往旧取，跳过 HIGH
        int k = shN - 1
        int added = 0
        while k >= 0 and added < tableRows - (rowSH > 0 ? 1 : 0)
            if k != highestSHIdx
                SwingPoint sp = array.get(shPoints, k)
                float d = (sp.price - close) / close * 100
                string stat = sp.broken ? "Broken" : ("Active " + (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%")
                color bg = sp.broken ? color.new(color.gray, 70) : color.new(shColor(sp.stage), 60)
                table.cell(structTable, 0, 1 + rowSH, "SH", text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 1, 1 + rowSH, str.tostring(sp.price, format.mintick), text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 2, 1 + rowSH, shShort(sp.stage), text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 3, 1 + rowSH, stat, text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                rowSH += 1
                added += 1
            k -= 1

    // SL 区
    int slN = array.size(slPoints)
    int rowSL = rowSH
    if slN > 0
        if trackHL and lowestSLIdx >= 0
            SwingPoint spL = array.get(slPoints, lowestSLIdx)
            float d = (close - spL.price) / close * 100
            string stat = spL.broken ? "Broken" : ("Active " + (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%")
            table.cell(structTable, 0, 1 + rowSL, "LOW", text_color=color.black, bgcolor=lowColor, text_size=t_size(tableSize))
            table.cell(structTable, 1, 1 + rowSL, str.tostring(spL.price, format.mintick), text_color=color.black, bgcolor=lowColor, text_size=t_size(tableSize))
            table.cell(structTable, 2, 1 + rowSL, slShort(spL.stage), text_color=color.black, bgcolor=lowColor, text_size=t_size(tableSize))
            table.cell(structTable, 3, 1 + rowSL, stat, text_color=color.black, bgcolor=lowColor, text_size=t_size(tableSize))
            rowSL += 1

        int k = slN - 1
        int added = 0
        while k >= 0 and added < tableRows - (rowSL > rowSH ? 1 : 0)
            if k != lowestSLIdx
                SwingPoint sp = array.get(slPoints, k)
                float d = (close - sp.price) / close * 100
                string stat = sp.broken ? "Broken" : ("Active " + (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%")
                color bg = sp.broken ? color.new(color.gray, 70) : color.new(slColor(sp.stage), 60)
                table.cell(structTable, 0, 1 + rowSL, "SL", text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 1, 1 + rowSL, str.tostring(sp.price, format.mintick), text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 2, 1 + rowSL, slShort(sp.stage), text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                table.cell(structTable, 3, 1 + rowSL, stat, text_color=color.white, bgcolor=bg, text_size=t_size(tableSize))
                rowSL += 1
                added += 1
            k -= 1

// ═══════════════════════════ FVG SEED GROWTH ═══════════════════════════
var array<box>   bullFvgBoxes  = array.new<box>()
var array<box>   bearFvgBoxes  = array.new<box>()
var array<label> bullFvgLabels = array.new<label>()
var array<label> bearFvgLabels = array.new<label>()

var array<int>   bullFvgStage  = array.new<int>()
var array<float> bullFvgTop    = array.new<float>()
var array<float> bullFvgBot    = array.new<float>()
var array<int>   bullFvgBar    = array.new<int>()
var array<int>   bullFvgCnt    = array.new<int>()

var array<int>   bearFvgStage  = array.new<int>()
var array<float> bearFvgTop    = array.new<float>()
var array<float> bearFvgBot    = array.new<float>()
var array<int>   bearFvgBar    = array.new<int>()
var array<int>   bearFvgCnt    = array.new<int>()

// Create Bullish FVG
if showFVG and low > high[2]
    float gapTop = low
    float gapBot = high[2]
    if gapTop - gapBot >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(color.green, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBullColor, xloc = xloc.bar_index)
        array.push(bullFvgBoxes, b)
        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, "FVG ↑ Seed → Field", style=label.style_none, textcolor=color.new(color.green, 0), size=f_size(fvgLabelSize), xloc=xloc.bar_index)
        array.push(bullFvgLabels, lbl)
        array.push(bullFvgStage, 1)
        array.push(bullFvgTop, gapTop)
        array.push(bullFvgBot, gapBot)
        array.push(bullFvgBar, bar_index)
        array.push(bullFvgCnt, 0)

// Create Bearish FVG
if showFVG and high < low[2]
    float gapTop = low[2]
    float gapBot = high
    if gapTop - gapBot >= fvgMinSize
        box b = box.new(bar_index, gapTop, bar_index + fvgBoxWidth, gapBot,
                        border_color = fvgBorder ? color.new(color.red, 50) : na,
                        border_width = fvgBorder ? 1 : 0,
                        bgcolor = fvgBearColor, xloc = xloc.bar_index)
        array.push(bearFvgBoxes, b)
        int midX = bar_index + math.round(fvgBoxWidth / 2)
        float midY = (gapTop + gapBot) / 2
        lbl = label.new(midX, midY, "FVG ↓ Seed → Field", style=label.style_none, textcolor=color.new(color.red, 0), size=f_size(fvgLabelSize), xloc=xloc.bar_index)
        array.push(bearFvgLabels, lbl)
        array.push(bearFvgStage, 1)
        array.push(bearFvgTop, gapTop)
        array.push(bearFvgBot, gapBot)
        array.push(bearFvgBar, bar_index)
        array.push(bearFvgCnt, 0)

// Bullish flow
if showFVG and array.size(bullFvgStage) > 0
    int i = 0
    while i < array.size(bullFvgStage)
        int stage = array.get(bullFvgStage, i)
        float gTop = array.get(bullFvgTop, i)
        float gBot = array.get(bullFvgBot, i)
        int gBar = array.get(bullFvgBar, i)
        int cnt = array.get(bullFvgCnt, i)
        label lb = array.get(bullFvgLabels, i)

        if bar_index > gBar
            if stage != 14 and close < gBot and stage > 1
                label.set_text(lb, bullTxt(14))
                array.set(bullFvgStage, i, 14)
            else if stage == 1
                if low <= gTop
                    label.set_text(lb, bullTxt(2))
                    array.set(bullFvgStage, i, 2)
            else if stage == 2
                label.set_text(lb, bullTxt(3))
                array.set(bullFvgStage, i, 3)
            else if stage == 3
                if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, bullTxt(4))
                        array.set(bullFvgStage, i, 4)
                        array.set(bullFvgCnt, i, 0)
            else if stage == 4
                if low <= gBot
                    cnt += 1
                    array.set(bullFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, bullTxt(13))
                        array.set(bullFvgStage, i, 13)
                        array.set(bullFvgCnt, i, 0)
                else if close > gBot
                    label.set_text(lb, bullTxt(5))
                    array.set(bullFvgStage, i, 5)
            else if stage == 5
                if close > gBot + fvgFarDist * 0.3
                    label.set_text(lb, bullTxt(6))
                    array.set(bullFvgStage, i, 6)
            else if stage == 6
                if close > gBot + fvgFarDist * 0.6
                    label.set_text(lb, bullTxt(7))
                    array.set(bullFvgStage, i, 7)
            else if stage == 7
                if close > gTop
                    label.set_text(lb, bullTxt(8))
                    array.set(bullFvgStage, i, 8)
            else if stage == 8
                if close > gTop + fvgFarDist * 0.5
                    label.set_text(lb, bullTxt(9))
                    array.set(bullFvgStage, i, 9)
            else if stage == 9
                if close > gTop + fvgFarDist * 1.0
                    label.set_text(lb, bullTxt(10))
                    array.set(bullFvgStage, i, 10)
            else if stage == 10
                if close > gTop + fvgFarDist * 1.5
                    label.set_text(lb, bullTxt(11))
                    array.set(bullFvgStage, i, 11)
            else if stage == 11
                if close > gTop + fvgFarDist * 2.0
                    label.set_text(lb, bullTxt(12))
                    array.set(bullFvgStage, i, 12)
            else if stage == 12
                if close > gTop + fvgFarDist * 3.0
                    label.set_text(lb, "FVG ↑ Seed → Field 🔁")
                    array.set(bullFvgStage, i, 1)
            else if stage == 13
                if low <= gTop
                    label.set_text(lb, "FVG ↑ Seed → Field 🔁")
                    array.set(bullFvgStage, i, 1)
            else if stage == 14
                label.set_text(lb, "FVG ↑ Rot")
        i += 1

// Bearish flow
if showFVG and array.size(bearFvgStage) > 0
    int i = 0
    while i < array.size(bearFvgStage)
        int stage = array.get(bearFvgStage, i)
        float gTop = array.get(bearFvgTop, i)
        float gBot = array.get(bearFvgBot, i)
        int gBar = array.get(bearFvgBar, i)
        int cnt = array.get(bearFvgCnt, i)
        label lb = array.get(bearFvgLabels, i)

        if bar_index > gBar
            if stage != 14 and close > gTop and stage > 1
                label.set_text(lb, bearTxt(14))
                array.set(bearFvgStage, i, 14)
            else if stage == 1
                if high >= gBot
                    label.set_text(lb, bearTxt(2))
                    array.set(bearFvgStage, i, 2)
            else if stage == 2
                label.set_text(lb, bearTxt(3))
                array.set(bearFvgStage, i, 3)
            else if stage == 3
                if close >= gBot and close <= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgAcceptBars
                        label.set_text(lb, bearTxt(4))
                        array.set(bearFvgStage, i, 4)
                        array.set(bearFvgCnt, i, 0)
            else if stage == 4
                if high >= gTop
                    cnt += 1
                    array.set(bearFvgCnt, i, cnt)
                    if cnt >= fvgConflictBars
                        label.set_text(lb, bearTxt(13))
                        array.set(bearFvgStage, i, 13)
                        array.set(bearFvgCnt, i, 0)
                else if close < gTop
                    label.set_text(lb, bearTxt(5))
                    array.set(bearFvgStage, i, 5)
            else if stage == 5
                if close < gTop - fvgFarDist * 0.3
                    label.set_text(lb, bearTxt(6))
                    array.set(bearFvgStage, i, 6)
            else if stage == 6
                if close < gTop - fvgFarDist * 0.6
                    label.set_text(lb, bearTxt(7))
                    array.set(bearFvgStage, i, 7)
            else if stage == 7
                if close < gBot
                    label.set_text(lb, bearTxt(8))
                    array.set(bearFvgStage, i, 8)
            else if stage == 8
                if close < gBot - fvgFarDist * 0.5
                    label.set_text(lb, bearTxt(9))
                    array.set(bearFvgStage, i, 9)
            else if stage == 9
                if close < gBot - fvgFarDist * 1.0
                    label.set_text(lb, bearTxt(10))
                    array.set(bearFvgStage, i, 10)
            else if stage == 10
                if close < gBot - fvgFarDist * 1.5
                    label.set_text(lb, bearTxt(11))
                    array.set(bearFvgStage, i, 11)
            else if stage == 11
                if close < gBot - fvgFarDist * 2.0
                    label.set_text(lb, bearTxt(12))
                    array.set(bearFvgStage, i, 12)
            else if stage == 12
                if close < gBot - fvgFarDist * 3.0
                    label.set_text(lb, "FVG ↓ Seed → Field 🔁")
                    array.set(bearFvgStage, i, 1)
            else if stage == 13
                if high >= gBot
                    label.set_text(lb, "FVG ↓ Seed → Field 🔁")
                    array.set(bearFvgStage, i, 1)
            else if stage == 14
                label.set_text(lb, "FVG ↓ Rot")
        i += 1

// FVG Fill + FIFO
if showFVG
    if array.size(bullFvgBoxes) > 0
        int i = 0
        while i < array.size(bullFvgBoxes)
            box b = array.get(bullFvgBoxes, i)
            if not na(b) and close < box.get_bottom(b)
                box.delete(b)
                array.remove(bullFvgBoxes, i)
                if i < array.size(bullFvgLabels)
                    label.delete(array.get(bullFvgLabels, i))
                    array.remove(bullFvgLabels, i)
                if i < array.size(bullFvgStage)
                    array.remove(bullFvgStage, i)
                    array.remove(bullFvgTop, i)
                    array.remove(bullFvgBot, i)
                    array.remove(bullFvgBar, i)
                    array.remove(bullFvgCnt, i)
            else
                i += 1

    if array.size(bearFvgBoxes) > 0
        int i = 0
        while i < array.size(bearFvgBoxes)
            box b = array.get(bearFvgBoxes, i)
            if not na(b) and close > box.get_top(b)
                box.delete(b)
                array.remove(bearFvgBoxes, i)
                if i < array.size(bearFvgLabels)
                    label.delete(array.get(bearFvgLabels, i))
                    array.remove(bearFvgLabels, i)
                if i < array.size(bearFvgStage)
                    array.remove(bearFvgStage, i)
                    array.remove(bearFvgTop, i)
                    array.remove(bearFvgBot, i)
                    array.remove(bearFvgBar, i)
                    array.remove(bearFvgCnt, i)
            else
                i += 1

    while array.size(bullFvgBoxes) > fvgMaxKeep
        box.delete(array.shift(bullFvgBoxes))
        if array.size(bullFvgLabels) > 0
            label.delete(array.shift(bullFvgLabels))
            array.shift(bullFvgStage)
            array.shift(bullFvgTop)
            array.shift(bullFvgBot)
            array.shift(bullFvgBar)
            array.shift(bullFvgCnt)
    while array.size(bearFvgBoxes) > fvgMaxKeep
        box.delete(array.shift(bearFvgBoxes))
        if array.size(bearFvgLabels) > 0
            label.delete(array.shift(bearFvgLabels))
            array.shift(bearFvgStage)
            array.shift(bearFvgTop)
            array.shift(bearFvgBot)
            array.shift(bearFvgBar)
            array.shift(bearFvgCnt)
````

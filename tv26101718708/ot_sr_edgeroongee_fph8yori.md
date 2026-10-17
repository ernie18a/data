# OT S/R Edge[roongee]

- url: https://www.tradingview.com/script/FPH8yORi/
- type: indicator
- pine_id: PUB;3a783c1a5aa84ec383f54aa60402b3a2
- version: 1.0

## Description

Here is the comprehensive guide for the OT S/R Edge [roongee] indicator, translated and organized for professional use.

1. Dashboard Overview (The Command Center)
The dashboard summarizes the market state in real-time, allowing you to assess the situation at a glance without cluttering your chart.

Resistance: Displays the nearest resistance price and its Touch Count (x). A high touch count (3x or more) suggests the level is significant or may soon break.

Support: Displays the nearest support price and its Touch Count (x).

Trend: Indicates the current "Momentum" based on the most recent breakout.

Bullish ↑: A resistance level was recently broken (Buying is favored).

Bearish ↓: A support level was recently broken (Selling is favored).

Active (x/5): Tracks the number of "Live Barriers" currently on the chart. This helps you identify if the market is in a clear "vacuum" or a congested area.

2. Decision Logic: The Break Score Framework
This indicator doesn't just watch price cross a line; it calculates the "Quality" of a breakout using a 3-layer filter:

The Gate (ADX Filter): If ADX is outside the 15–45 range, the system assumes there is either insufficient volatility to break or the move is already "overextended."

The Pressure (Touch Count): The more a level is tested, the higher the Break Score. Statistically, levels weaken after multiple hits.

The Momentum (ADX Rising & Last Break): If ADX is sloping upward and the direction aligns with the most recent trend, the probability of a successful break reaches High Probability (Score 4+).

3. Trading Strategies (Action Plan)
Strategy 1: Trend Following
Check Dashboard: If the Trend is Bullish ↑, look for Buy opportunities only.

Entry Point: Wait for a "Buy the Dip" scenario at an Active support level or a "flipped" level (Old Resistance turned New Support, shown as a gray dotted line).

Target: Take Profit (TP) at the next Resistance level shown on the Dashboard.

Strategy 2: Breakout Trading
The Signal: Look for a ↑ Break or ↓ Break label accompanied by a "High Probability Break" alert.

Entry Point: Enter a trade once the candle closes outside the designated Zone.

Key Indicator: If the Active count on the dashboard drops suddenly (e.g., from 4/5 to 1/5), it signals a major "clearing" of levels, often leading to a powerful price run.

Strategy 3: Range/Sideways Play
Check Dashboard: Use this when the Trend is Neutral and the Active count is high (4/5 or 5/5).

Entry Point: Sell at the Resistance ceiling and Buy at the Support floor.

Confirmation: Check the Touch Count. If it is low (1x or 2x), the level is more likely to "bounce" than "break."

4. Visual Guide (Color & Line Logic)
Solid Green/Red Lines: Active support/resistance. Increased line thickness represents longevity (the older the level, the more important it is).

Colored Zones: These represent "Areas of Interest." Markets rarely reverse at a precise decimal point; they reverse within a zone.

Gray Dotted Lines (Broken): Levels that have been breached. These often serve as Retest points.

Break Labels: Mark the exact point where momentum successfully overcame a barrier.

Pro Tip: Pay close attention to the Active count. When it drops to 1/5 or 2/5, the market is usually entering a "clean" state where a long-term trend can finally begin.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// Original: BigBeluga - Adaptive Support and Resistance Zones
// Modified: Added Break Score Framework + ADX integration

//@version=5
indicator("OT S/R Edge[roongee]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════
var grpSwing = "Swing Detection"
pivotLen     = input.int(5,   "Pivot Length",      minval=2, maxval=50,   group=grpSwing)
minStrength  = input.float(0.1, "Min ATR Strength", minval=0.0, maxval=5.0, step=0.05, group=grpSwing)
maxAgeBars   = input.int(300, "Max Level Age (bars)", minval=20, maxval=2000, group=grpSwing)

var grpLevels = "Levels"
showSupport  = input.bool(true,  "Show Support Levels",    group=grpLevels)
showResist   = input.bool(true,  "Show Resistance Levels", group=grpLevels)
maxLevels    = input.int(5, "Max Active Levels (Total)", minval=1, maxval=5, group=grpLevels, tooltip="จำนวน level สูงสุดรวมทั้ง Support + Resistance")
mergeThresh  = input.float(0.5,  "Merge Threshold (ATR x)", minval=0.0, maxval=3.0, step=0.05, group=grpLevels)
showZones    = input.bool(true,  "Show Level Zones",       group=grpLevels)
zoneWidth    = input.float(0.25, "Zone Width (ATR x)",     minval=0.05, maxval=2.0, step=0.05, group=grpLevels)

var grpBreak = "Breakouts"
showBroken   = input.bool(true,  "Show Broken Levels",         group=grpBreak)
breakSens    = input.float(0.1,  "Break Sensitivity (ATR x)",  minval=0.0, maxval=2.0, step=0.05, group=grpBreak)
showBreakLbl = input.bool(true,  "Show Break Labels",          group=grpBreak)
maxBroken    = input.int(4,      "Max Broken Levels Shown",    minval=0, maxval=20, group=grpBreak)

// ─── ADX (ค่าเดิมจาก OT Bot: 15-45) ───
var grpADX = "ADX Filter (Break Score)"
adxLen       = input.int(14, "ADX Smoothing", group=grpADX)
diLen        = input.int(14, "DI Length",     group=grpADX)
adxMin       = input.float(15.0, "ADX Min (Gate)", minval=0, maxval=100, step=1, group=grpADX, tooltip="ต่ำกว่านี้ Gate ปิด ไม่มีโอกาส break")
adxMax       = input.float(45.0, "ADX Max",        minval=0, maxval=100, step=1, group=grpADX)

// Break Score (ใช้สำหรับ alerts เท่านั้น ไม่แสดงใน dashboard)
proxATR      = 0.5  // ราคาห่าง level ไม่เกิน 0.5 ATR ถึงจะนับว่า 'ใกล้'

// ─── สีใหม่: Support = เขียว, Resistance = แดง ───
var grpVis = "Visuals"
supColor     = input.color(color.new(#22c55e, 0),  "Support Color (Green)",  group=grpVis)
resColor     = input.color(color.new(#ef4444, 0),  "Resistance Color (Red)", group=grpVis)
brokenColor  = input.color(color.new(#94a3b8, 0),  "Broken Level Color",     group=grpVis)
lineWidth    = input.int(2, "Base Line Width", minval=1, maxval=5, group=grpVis)
useDynamicWidth = input.bool(true, "Enable Longevity Width", group=grpVis)
maxLineWidth    = input.int(5, "Max Longevity Width", minval=1, maxval=10, group=grpVis)
showDash     = input.bool(true, "Show Dashboard", group=grpVis)
showPriceLbl = input.bool(true, "Show Price Labels on Active Levels", group=grpVis)

var grpDash = "Dashboard"
dashPos      = input.string("Bottom Right", "Dashboard Position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=grpDash)

// ════════════════════════════════════════════════════════════
// CALCULATIONS
// ════════════════════════════════════════════════════════════
type SRLevel
    float price
    int   barStart
    int   levelType
    bool  active
    bool  broken
    int   breakBar
    int   touchCount
    line  mainLine
    box   zoneBox
    label breakLabel
    label priceLabel

var array<SRLevel> activeLevels = array.new<SRLevel>()
var array<SRLevel> brokenLevels = array.new<SRLevel>()
var string         lastBreakDir = "—"
var int            lastBreakBar = na

atrVal  = ta.atr(14)
atrSafe = na(atrVal) or atrVal == 0 ? syminfo.mintick * 10 : atrVal

// ─── ADX Calculation ───
[plusDI, minusDI, adxValue] = ta.dmi(diLen, adxLen)
isTrendActive = adxValue >= adxMin and adxValue <= adxMax
adxRising     = adxValue > adxValue[3]

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
        // นับรวมทั้ง Support + Resistance (เปลี่ยนจาก per-side เป็น total)
        int totalActive = 0
        int sz = array.size(activeLevels)
        if sz > 0
            for i = 0 to sz - 1
                lvl = array.get(activeLevels, i)
                if lvl.active
                    totalActive += 1

        if totalActive < maxLevels
            _baseColor = _type == 1 ? resColor : supColor
            _zoneTop   = _price + zoneWidth * atrSafe * 0.5
            _zoneBot   = _price - zoneWidth * atrSafe * 0.5

            newLine = line.new(x1=_barIdx, y1=_price, x2=_barIdx + 1, y2=_price, extend=extend.right, color=color.new(_baseColor, 0), width=lineWidth, style=line.style_solid)
            newBox  = showZones ? box.new(left=_barIdx, top=_zoneTop, right=_barIdx + 1, bottom=_zoneBot, border_color=color.new(_baseColor, 90), bgcolor=color.new(_baseColor, 88), extend=extend.right) : na
            newLbl  = showPriceLbl ? label.new(x=bar_index + 20, y=_price, text=str.tostring(_price, format.mintick), style=label.style_label_center, textcolor=_baseColor, color=color.new(chart.bg_color, 0), size=size.small) : na

            array.push(activeLevels, SRLevel.new(price=_price, barStart=_barIdx, levelType=_type, active=true, broken=false, breakBar=na, touchCount=0, mainLine=newLine, zoneBox=newBox, breakLabel=na, priceLabel=newLbl))

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

// ─── Prune old levels ───
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

// ─── Add new pivots ───
if not na(ph) and showResist
    if f_pivotStrong(ph, 1)
        f_addLevel(ph, 1, bar_index - pivotLen)

if not na(pl) and showSupport
    if f_pivotStrong(pl, -1)
        f_addLevel(pl, -1, bar_index - pivotLen)

// ─── Touch Count Tracking + Breakout Logic ───
int activeSize = array.size(activeLevels)
if activeSize > 0
    for i = activeSize - 1 to 0
        if i >= array.size(activeLevels)
            continue
        lvl = array.get(activeLevels, i)
        if not lvl.active
            continue

        breakBuffer = breakSens * atrSafe
        zoneTop     = lvl.price + zoneWidth * atrSafe * 0.5
        zoneBot     = lvl.price - zoneWidth * atrSafe * 0.5

        // ── Touch Detection: ราคาเข้า zone จากด้านนอก ──
        if lvl.levelType == 1  // Resistance
            wasBelow = close[1] < zoneBot
            inZone   = high >= zoneBot and close <= zoneTop
            if wasBelow and inZone
                lvl.touchCount += 1
        else  // Support
            wasAbove = close[1] > zoneTop
            inZone   = low <= zoneTop and close >= zoneBot
            if wasAbove and inZone
                lvl.touchCount += 1

        // ── Resistance Break (Bullish) ──
        if lvl.levelType == 1 and close > lvl.price + breakBuffer
            lvl.active   := false
            lvl.broken   := true
            lvl.breakBar := bar_index
            lastBreakDir := "Bullish"
            lastBreakBar := bar_index

            if not na(lvl.priceLabel)
                label.delete(lvl.priceLabel)
                lvl.priceLabel := na

            line.set_color(lvl.mainLine, color.new(brokenColor, 0))
            line.set_style(lvl.mainLine, line.style_dotted)
            line.set_width(lvl.mainLine, 1)
            line.set_extend(lvl.mainLine, extend.none)
            line.set_x2(lvl.mainLine, bar_index)

            if not na(lvl.zoneBox)
                box.set_bgcolor(lvl.zoneBox, color.new(brokenColor, 93))
                box.set_border_color(lvl.zoneBox, color.new(brokenColor, 100))
                box.set_extend(lvl.zoneBox, extend.none)
                box.set_right(lvl.zoneBox, bar_index)
                mid = math.avg(lvl.zoneBox.get_top(), lvl.zoneBox.get_bottom())
                lvl.zoneBox.set_top(mid + breakBuffer)
                lvl.zoneBox.set_bottom(mid - breakBuffer)

            if showBreakLbl
                lvl.breakLabel := label.new(x=bar_index, y=lvl.price, text="↑ Break", style=label.style_label_left, textcolor=supColor, color=color.new(supColor, 85), size=size.small)

            if showBroken
                array.push(brokenLevels, lvl)
                if array.size(brokenLevels) > maxBroken
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

        // ── Support Break (Bearish) ──
        else if lvl.levelType == -1 and close < lvl.price - breakBuffer
            lvl.active   := false
            lvl.broken   := true
            lvl.breakBar := bar_index
            lastBreakDir := "Bearish"
            lastBreakBar := bar_index

            if not na(lvl.priceLabel)
                label.delete(lvl.priceLabel)
                lvl.priceLabel := na

            line.set_color(lvl.mainLine, color.new(brokenColor, 0))
            line.set_style(lvl.mainLine, line.style_dotted)
            line.set_width(lvl.mainLine, 1)
            line.set_extend(lvl.mainLine, extend.none)
            line.set_x2(lvl.mainLine, bar_index)

            if not na(lvl.zoneBox)
                box.set_bgcolor(lvl.zoneBox, color.new(brokenColor, 93))
                box.set_border_color(lvl.zoneBox, color.new(brokenColor, 100))
                box.set_extend(lvl.zoneBox, extend.none)
                box.set_right(lvl.zoneBox, bar_index)
                mid = math.avg(lvl.zoneBox.get_top(), lvl.zoneBox.get_bottom())
                lvl.zoneBox.set_top(mid + breakBuffer)
                lvl.zoneBox.set_bottom(mid - breakBuffer)

            if showBreakLbl
                lvl.breakLabel := label.new(x=bar_index, y=lvl.price, text="↓ Break", style=label.style_label_left, textcolor=resColor, color=color.new(resColor, 85), size=size.small)

            if showBroken
                array.push(brokenLevels, lvl)
                if array.size(brokenLevels) > maxBroken
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

// ════════════════════════════════════════════════════════════
// PLOT — Extend visuals + Find nearest levels
// ════════════════════════════════════════════════════════════
int extSize = array.size(activeLevels)
if extSize > 0
    for i = 0 to extSize - 1
        lvl = array.get(activeLevels, i)
        if lvl.active
            if useDynamicWidth
                age = bar_index - lvl.barStart
                calcWidth = math.min(maxLineWidth, 1 + math.floor((age / maxAgeBars) * (maxLineWidth - 1)))
                line.set_width(lvl.mainLine, int(calcWidth))
            else
                line.set_width(lvl.mainLine, lineWidth)

            line.set_x2(lvl.mainLine, bar_index + 1)
            if not na(lvl.zoneBox)
                box.set_right(lvl.zoneBox, bar_index + 1)
            if showPriceLbl and not na(lvl.priceLabel)
                label.set_x(lvl.priceLabel, bar_index + 10)

// ─── Find nearest level + touch count ───
var float nearestSup       = na
var float nearestRes       = na
var int   nearestSupTouch  = 0
var int   nearestResTouch  = 0

nearestSup      := na
nearestRes      := na
nearestSupTouch := 0
nearestResTouch := 0

int dashScanSize = array.size(activeLevels)
if dashScanSize > 0
    for i = 0 to dashScanSize - 1
        lvl = array.get(activeLevels, i)
        if not lvl.active
            continue
        if lvl.levelType == -1 and lvl.price < close
            if na(nearestSup) or lvl.price > nearestSup
                nearestSup      := lvl.price
                nearestSupTouch := lvl.touchCount
        if lvl.levelType == 1 and lvl.price > close
            if na(nearestRes) or lvl.price < nearestRes
                nearestRes      := lvl.price
                nearestResTouch := lvl.touchCount

// ════════════════════════════════════════════════════════════
// BREAK SCORE FRAMEWORK
// ════════════════════════════════════════════════════════════
// Layer 1: Gate (ADX)
gateOpen = isTrendActive

// Layer 2: Touch Count Score (สำหรับ resistance)
resTouchScore = nearestResTouch >= 3 ? 2 : nearestResTouch == 2 ? 1 : 0
supTouchScore = nearestSupTouch >= 3 ? 2 : nearestSupTouch == 2 ? 1 : 0

// Layer 3: Confirming factors
nearRes = not na(nearestRes) and (nearestRes - close) < proxATR * atrSafe
nearSup = not na(nearestSup) and (close - nearestSup) < proxATR * atrSafe

// ADX rising = +1
adxRisingScore = adxRising ? 1 : 0

// Direction alignment (bullish bias for resistance break, bearish for support break)
bullishBias = lastBreakDir == "Bullish" ? 1 : 0
bearishBias = lastBreakDir == "Bearish" ? 1 : 0

// Final score
resBreakScore = gateOpen and nearRes ? resTouchScore + adxRisingScore + bullishBias : 0
supBreakScore = gateOpen and nearSup ? supTouchScore + adxRisingScore + bearishBias : 0

// ────────────────────────────────────────
// Trend Status (Last Break เป็น trend)
// ────────────────────────────────────────
trendStatus = lastBreakDir == "Bullish" ? "Bullish ↑" : lastBreakDir == "Bearish" ? "Bearish ↓" : "Neutral"
trendColor  = lastBreakDir == "Bullish" ? supColor : lastBreakDir == "Bearish" ? resColor : color.new(#484f58, 0)

// ════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════
var table dashTable = na

if showDash
    tablePos = switch dashPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

    int rowCount = 5

    if barstate.isfirst
        dashTable := table.new(position=tablePos, columns=2, rows=rowCount, bgcolor=color.new(#0d1117, 5), border_color=color.new(#30363d, 40), border_width=1, frame_color=color.new(#30363d, 20), frame_width=1)

    if barstate.islast and not na(dashTable)
        // Header
        table.cell(dashTable, 0, 0, "S/R Dashboard", text_color=color.new(#f0f6fc, 0), text_size=size.normal, bgcolor=color.new(#161b22, 0), text_halign=text.align_center)
        table.merge_cells(dashTable, 0, 0, 1, 0)

        // Resistance (with touch count)
        resText = na(nearestRes) ? "—" : str.tostring(nearestRes, format.mintick) + " (" + str.tostring(nearestResTouch) + "x)"
        table.cell(dashTable, 0, 1, "Resistance", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 1, resText, text_color=na(nearestRes) ? color.new(#484f58, 0) : resColor, text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        // Support (with touch count)
        supText = na(nearestSup) ? "—" : str.tostring(nearestSup, format.mintick) + " (" + str.tostring(nearestSupTouch) + "x)"
        table.cell(dashTable, 0, 2, "Support", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 2, supText, text_color=na(nearestSup) ? color.new(#484f58, 0) : supColor, text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        // Trend
        table.cell(dashTable, 0, 3, "Trend", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 3, trendStatus, text_color=trendColor, text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

        // Active (รวมทั้ง Sup + Res, max 5)
        activeCnt = 0
        for i = 0 to array.size(activeLevels) - 1
            if array.get(activeLevels, i).active
                activeCnt += 1
        table.cell(dashTable, 0, 4, "Active", text_color=color.new(#8b949e, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_left)
        table.cell(dashTable, 1, 4, str.tostring(activeCnt) + "/5", text_color=color.new(#f0f6fc, 0), text_size=size.normal, bgcolor=color.new(#0d1117, 10), text_halign=text.align_right)

// ════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════
alertcondition(lastBreakDir == "Bullish" and lastBreakBar == bar_index, "Bullish Break", "Resistance broken — bullish trend")
alertcondition(lastBreakDir == "Bearish" and lastBreakBar == bar_index, "Bearish Break", "Support broken — bearish trend")
alertcondition(resBreakScore >= 4 and gateOpen, "High Probability Res Break", "Resistance break score HIGH")
alertcondition(supBreakScore >= 4 and gateOpen, "High Probability Sup Break", "Support break score HIGH")
````

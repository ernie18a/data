# ICT FVG Repricing Zones [EmpArchitect]

- url: https://www.tradingview.com/script/M6ep6Fvi-ICT-FVG-Repricing-Zones-EmpArchitect/
- type: indicator
- pine_id: PUB;ce4aa296d869424abd5fdfd01e176a79
- version: 1.0

## Description

█ OVERVIEW

ICT FVG Repricing Zones detects displacement-driven fair value gaps and tracks whether price later reprices those zones.

Not every FVG matters. Many gaps are noise from weak candles. This indicator only maps FVG zones created by real displacement — large, committed candles that leave inefficient price delivery behind.

Where price moved too fast, the market can leave a zone worth tracking.

No signals. No entries. No targets. No financial advice.

█ WHAT IT DETECTS

Bullish Displacement FVG:
A strong bullish displacement candle creates an imbalance. The gap between the prior candle's high and the following candle's low becomes the bullish FVG zone.

Bearish Displacement FVG:
A strong bearish displacement candle creates an imbalance. The gap between the prior candle's low and the following candle's high becomes the bearish FVG zone.

Only FVGs created by displacement candles that meet minimum body-size, body-ratio, and gap-size thresholds are drawn. Weak or wicky candles are filtered out.

█ CONSEQUENT ENCROACHMENT

Each FVG zone can include an optional CE / 50% midpoint line.

In ICT-style analysis, the 50% level of an FVG is often treated as a key repricing reference. The CE line makes this level visible without manual measurement.

█ GRADING

Every FVG zone is graded by displacement candle strength:

A — strong displacement
B — moderate displacement
C — minimum valid displacement

Grade is encoded through zone opacity. A-grade zones are most visible. C-grade zones are faded.

█ ZONE LIFECYCLE

Fresh — FVG zone just formed. Full color, CE line visible, extends right.
Repriced — price traded back into the zone. The zone fades to gray or is removed depending on settings.
Invalidated — price closed through the zone in the wrong direction. The zone is removed immediately.

Invalidation rules:
• Bullish zone: close below zone bottom = invalidated
• Bearish zone: close above zone top = invalidated

Default display is fresh-first. Repriced zones are hidden by default.

█ DETECTION FILTERS

• Min Displacement ATR filters weak candles
• Min Body Ratio filters wicky displacement candles
• Min FVG Size ATR rejects tiny insignificant gaps
• Max Zone Height ATR rejects oversized zones
• Duplicate Filter prevents stacked zones near the same price area
• Max Active Zones caps visual clutter per side
• Bar-close confirmation prevents intrabar flickering

█ DISTINCTION FROM OTHER TOOLS

FVG Repricing Zones show inefficient displacement imbalances and whether they get repriced.
Breaker Block Detector shows failed OB zones that flip into opposing breakers.
Liquidity Trap Zones show one-bar failed reversal patterns.

All three are zone tools, but they detect different structure events.

█ DASHBOARD

• Fresh — active bull and bear FVG count
• Near ↑ — nearest fresh FVG above price with grade and distance
• Near ↓ — nearest fresh FVG below price with grade and distance
• Repriced — count of repriced zones or Hidden
• Last — most recent FVG event

█ ALERTS

• Bullish FVG detected
• Bearish FVG detected
• FVG zone repriced

Structure context only. Not trade signals. Use alerts with Once Per Bar Close.

█ PAIRS WITH

Smart Liquidity Map [EmpArchitect] — liquidity context
HTF Context Overlay [EmpArchitect] — higher-timeframe reference levels
ICT Dealing Range [EmpArchitect] — premium / discount context
Breaker Block Detector [EmpArchitect] — failed OB zones
Liquidity Trap Zones [EmpArchitect] — failed reversal context

█ NOTES

• Works on all instruments and timeframes
• Best on 15M–4H charts
• Bar-close confirmed / non-repainting by design
• Pine Script v6
• Open-source
• Built by EmpArchitect
• Educational context tool only
• Not financial advice
• Not a signal service

## Source Code

````pine
//@version=6
indicator("ICT FVG Repricing Zones [EmpArchitect]", shorttitle="FVG Repricing [EA]", overlay=true, max_boxes_count=200, max_labels_count=200, max_lines_count=200)

// ═══════════════════════════════════════════════════════════════════
// ICT FVG REPRICING ZONES [EmpArchitect] v1.0
//
// Not every FVG matters. Only imbalance created by real displacement
// gets mapped. Tracks whether price later reprices the zone.
//
// No signals. No entries. No targets.
// Structure context for ICT, SMC, and price-action workflows.
// ═══════════════════════════════════════════════════════════════════

// ─────────────── INPUTS ───────────────

grp1 = "Detection"
atrLen        = input.int(14, "ATR Length", minval=5, maxval=50, group=grp1)
minDispATR    = input.float(1.25, "Min Displacement ATR", minval=0.5, maxval=4.0, step=0.05, group=grp1, tooltip="Minimum displacement candle body size vs ATR. Filters weak gaps.")
minBodyRatio  = input.float(0.60, "Min Body Ratio", minval=0.3, maxval=0.95, step=0.05, group=grp1, tooltip="Minimum body/range ratio of displacement candle. Filters wicky candles.")
minFVGatr     = input.float(0.15, "Min FVG Size ATR", minval=0.05, maxval=1.0, step=0.05, group=grp1, tooltip="Minimum gap size vs ATR. Rejects tiny gaps.")
maxZoneATR    = input.float(3.0, "Max Zone Height ATR", minval=0.5, maxval=10.0, step=0.25, group=grp1, tooltip="Reject oversized zones.")

grp2 = "Display"
showBull      = input.bool(true, "Show Bullish Zones", group=grp2)
showBear      = input.bool(true, "Show Bearish Zones", group=grp2)
maxZones      = input.int(5, "Max Active Zones Per Side", minval=3, maxval=20, group=grp2)
showRepriced  = input.bool(false, "Show Repriced Zones", group=grp2, tooltip="OFF: repriced zones removed. ON: repriced zones fade gray as archive.")
maxRepriced   = input.int(20, "Max Repriced Archive Zones", minval=5, maxval=100, group=grp2)
showLabels    = input.bool(true, "Show Labels", group=grp2)
showCE        = input.bool(true, "Show CE / 50% Line", group=grp2, tooltip="Shows Consequent Encroachment midpoint inside each FVG zone.")
showDash      = input.bool(true, "Show Dashboard", group=grp2)

grp3 = "Grading"
gradeA_ATR    = input.float(2.0, "A Grade (ATR)", minval=1.0, maxval=5.0, step=0.05, group=grp3)
gradeB_ATR    = input.float(1.5, "B Grade (ATR)", minval=0.5, maxval=3.0, step=0.05, group=grp3)

grp4 = "Style"
bullCol       = input.color(color.new(#00D9A3, 25), "Bullish Zone", group=grp4)
bearCol       = input.color(color.new(#F59E0B, 25), "Bearish Zone", group=grp4)
repricedCol   = input.color(color.new(#6B7280, 60), "Repriced Zone", group=grp4)

// ─────────────── ATR ───────────────

atr = ta.atr(atrLen)

// ─────────────── GRADE ───────────────

f_gradeRatio(float r) =>
    r >= gradeA_ATR ? "A" : r >= gradeB_ATR ? "B" : "C"

// ─────────────── ACTIVE (FRESH) ZONE ARRAYS ───────────────

var box[]    zBox     = array.new_box()
var label[]  zLbl     = array.new_label()
var line[]   zCE      = array.new_line()
var float[]  zTop     = array.new_float()
var float[]  zBot     = array.new_float()
var bool[]   zIsBull  = array.new_bool()
var string[] zGrade   = array.new_string()
var int[]    zBorn    = array.new_int()

// ─────────────── REPRICED ARCHIVE ───────────────

var box[]   rBox      = array.new_box()

// ─────────────── HELPERS ───────────────

f_delFresh(int i) =>
    box.delete(array.get(zBox, i))
    lb = array.get(zLbl, i)
    if not na(lb)
        label.delete(lb)
    ln = array.get(zCE, i)
    if not na(ln)
        line.delete(ln)
    array.remove(zBox, i)
    array.remove(zLbl, i)
    array.remove(zCE, i)
    array.remove(zTop, i)
    array.remove(zBot, i)
    array.remove(zIsBull, i)
    array.remove(zGrade, i)
    array.remove(zBorn, i)

f_archiveFresh(int i) =>
    bx = array.get(zBox, i)
    box.set_bgcolor(bx, repricedCol)
    box.set_border_color(bx, color.new(#6B7280, 40))
    box.set_extend(bx, extend.none)
    box.set_right(bx, bar_index)
    array.push(rBox, bx)
    lb = array.get(zLbl, i)
    if not na(lb)
        label.delete(lb)
    ln = array.get(zCE, i)
    if not na(ln)
        line.delete(ln)
    array.remove(zBox, i)
    array.remove(zLbl, i)
    array.remove(zCE, i)
    array.remove(zTop, i)
    array.remove(zBot, i)
    array.remove(zIsBull, i)
    array.remove(zGrade, i)
    array.remove(zBorn, i)

f_zoneColor(bool isBull, string grade) =>
    color baseCol = isBull ? bullCol : bearCol
    int transp = grade == "A" ? 45 : grade == "B" ? 65 : 80
    color.new(baseCol, transp)

f_borderColor(bool isBull) =>
    isBull ? color.new(#00D9A3, 5) : color.new(#F59E0B, 5)

// ─────────────── EVENTS ───────────────

var bool evtBullFVG = false
var bool evtBearFVG = false
var bool evtRepriced = false
var string lastEvent = "—"

evtBullFVG := false
evtBearFVG := false
evtRepriced := false

// ─────────────── FVG DETECTION ───────────────
// Bullish FVG: low (bar 0) > high[2] (bar 2) — gap between high[2] and low
// Bearish FVG: high (bar 0) < low[2] (bar 2) — gap between high and low[2]
// Displacement candle is bar[1] (the middle candle)

bool confirmed = barstate.isconfirmed

float dispBody = math.abs(close[1] - open[1])
float dispRange = high[1] - low[1]
float dispRatio = dispRange > 0 ? dispBody / dispRange : 0.0
float atrRef = atr[1]
float dispATRratio = not na(atrRef) and atrRef > 0 ? dispBody / atrRef : 0.0

bool validDisp = dispATRratio >= minDispATR and dispRatio >= minBodyRatio

// Bullish FVG
bool bullGap = low > high[2]
float bullTop = low
float bullBot = high[2]
float bullSize = bullTop - bullBot
bool bullSizeOK = not na(atrRef) and atrRef > 0 and bullSize >= minFVGatr * atrRef and bullSize <= maxZoneATR * atrRef
bool bullDisp = close[1] > open[1]
bool bullFVG = confirmed and bullGap and bullSizeOK and validDisp and bullDisp

// Bearish FVG
bool bearGap = high < low[2]
float bearTop = low[2]
float bearBot = high
float bearSize = bearTop - bearBot
bool bearSizeOK = not na(atrRef) and atrRef > 0 and bearSize >= minFVGatr * atrRef and bearSize <= maxZoneATR * atrRef
bool bearDisp = close[1] < open[1]
bool bearFVG = confirmed and bearGap and bearSizeOK and validDisp and bearDisp

// ─────────────── CREATE ZONES ───────────────

f_createZone(float zt, float zb, bool isBull, string grade) =>
    float newMid = (zt + zb) / 2
    bool rejected = false
    bool created = false

    // Duplicate filter: fresh zones only
    if array.size(zTop) > 0
        for j = array.size(zTop) - 1 to 0
            if j < array.size(zTop) and array.get(zIsBull, j) == isBull
                float existMid = (array.get(zTop, j) + array.get(zBot, j)) / 2
                if not na(atr) and math.abs(newMid - existMid) < atr * 0.50
                    string existGrade = array.get(zGrade, j)
                    bool newBetter = (grade == "A" and existGrade != "A") or (grade == "B" and existGrade == "C")
                    if newBetter
                        f_delFresh(j)
                    else
                        rejected := true
                    break

    if not rejected
        bool showThis = (isBull and showBull) or (not isBull and showBear)
        if showThis
            color fc = f_zoneColor(isBull, grade)
            color bc = f_borderColor(isBull)
            box bx = box.new(bar_index - 2, zt, bar_index, zb, bgcolor=fc, border_color=bc, border_width=1, extend=extend.right)

            label lb = na
            if showLabels
                string side = isBull ? "Bull" : "Bear"
                string txt = side + " FVG " + grade
                float labelY = isBull ? zt : zb
                lb := label.new(bar_index, labelY, txt, style=isBull ? label.style_label_down : label.style_label_up, color=color.new(isBull ? #00D9A3 : #F59E0B, 70), textcolor=color.white, size=size.tiny)

            line ceLine = na
            if showCE
                float ceMid = (zt + zb) / 2
                color ceCol = isBull ? color.new(#00D9A3, 40) : color.new(#F59E0B, 40)
                ceLine := line.new(bar_index - 2, ceMid, bar_index, ceMid, color=ceCol, style=line.style_dotted, width=1, extend=extend.right)

            array.push(zBox, bx)
            array.push(zLbl, lb)
            array.push(zCE, ceLine)
            array.push(zTop, zt)
            array.push(zBot, zb)
            array.push(zIsBull, isBull)
            array.push(zGrade, grade)
            array.push(zBorn, bar_index)
            created := true

    created

// Create bullish FVG zone
if bullFVG
    string grade = f_gradeRatio(dispATRratio)
    bool created = f_createZone(bullTop, bullBot, true, grade)
    if created
        evtBullFVG := true
        lastEvent := "Bull FVG"

// Create bearish FVG zone
if bearFVG
    string grade = f_gradeRatio(dispATRratio)
    bool created = f_createZone(bearTop, bearBot, false, grade)
    if created
        evtBearFVG := true
        lastEvent := "Bear FVG"

// ─────────────── PROCESS ACTIVE ZONES ───────────────
// Order: invalidation → repricing → extend

int[] actIdx  = array.new_int()
int[] actType = array.new_int()  // 1=archive, 2=remove, 3=delete

if confirmed and array.size(zTop) > 0
    for i = array.size(zTop) - 1 to 0
        if i >= array.size(zTop)
            continue
        float zt = array.get(zTop, i)
        float zb = array.get(zBot, i)
        bool  isBull = array.get(zIsBull, i)
        int   born = array.get(zBorn, i)
        label lb = array.get(zLbl, i)

        if bar_index <= born
            continue

        // 1. INVALIDATION
        bool invalidated = false
        if isBull and close < zb
            invalidated := true
        if not isBull and close > zt
            invalidated := true

        if invalidated
            array.push(actIdx, i)
            array.push(actType, 3)
            continue

        // 2. REPRICING (price enters zone without invalidating)
        bool inZone = low <= zt and high >= zb
        if inZone and bar_index > born
            evtRepriced := true
            lastEvent := isBull ? "Bull Repriced" : "Bear Repriced"
            array.push(actIdx, i)
            array.push(actType, showRepriced ? 1 : 2)
            continue

        // 3. EXTEND label
        if not na(lb)
            label.set_x(lb, bar_index)
            label.set_y(lb, isBull ? zt : zb)

// Execute actions (collected in descending order, process 0→end = highest index first)
if array.size(actIdx) > 0
    for j = 0 to array.size(actIdx) - 1
        int idx = array.get(actIdx, j)
        int typ = array.get(actType, j)
        if idx < array.size(zBox)
            if typ == 1
                f_archiveFresh(idx)
            else
                f_delFresh(idx)

// Archive cap
while array.size(rBox) > maxRepriced
    box.delete(array.shift(rBox))

// ─────────────── ZONE CAP ───────────────

int bullCount = 0
int bearCount = 0
int[] prune = array.new_int()

if array.size(zTop) > 0
    for i = array.size(zTop) - 1 to 0
        if array.get(zIsBull, i)
            bullCount += 1
            if bullCount > maxZones
                array.push(prune, i)
        else
            bearCount += 1
            if bearCount > maxZones
                array.push(prune, i)

if array.size(prune) > 0
    for j = 0 to array.size(prune) - 1
        int idx = array.get(prune, j)
        if idx < array.size(zBox)
            f_delFresh(idx)

// Final count
bullCount := 0
bearCount := 0
if array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        if array.get(zIsBull, i)
            bullCount += 1
        else
            bearCount += 1

// ─────────────── NEAREST ZONE ───────────────

float nearAbove = na
string nearAboveN = ""
float nearBelow = na
string nearBelowN = ""

if array.size(zTop) > 0
    for i = 0 to array.size(zTop) - 1
        float zt = array.get(zTop, i)
        float zb = array.get(zBot, i)
        bool isBull = array.get(zIsBull, i)
        string g = array.get(zGrade, i)
        float mid = (zt + zb) / 2
        string name = (isBull ? "Bull " : "Bear ") + g

        if mid > close and (na(nearAbove) or mid < nearAbove)
            nearAbove := mid
            nearAboveN := name
        if mid < close and (na(nearBelow) or mid > nearBelow)
            nearBelow := mid
            nearBelowN := name

// ─────────────── DASHBOARD ───────────────

var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 5)

    table.cell(dash, 0, 0, "FVG Repricing", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)

    string freshStr = "▲" + str.tostring(bullCount) + "  ▼" + str.tostring(bearCount)
    table.cell(dash, 0, 1, "Fresh", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, freshStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

    string aboveStr = not na(nearAbove) ? nearAboveN + " +" + str.tostring((nearAbove / close - 1) * 100, "#.##") + "%" : "—"
    table.cell(dash, 0, 2, "Near ↑", text_color=#F59E0B, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, aboveStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

    string belowStr = not na(nearBelow) ? nearBelowN + " -" + str.tostring((1 - nearBelow / close) * 100, "#.##") + "%" : "—"
    table.cell(dash, 0, 3, "Near ↓", text_color=#00D9A3, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, belowStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

    string rStr = showRepriced ? str.tostring(array.size(rBox)) : "Hidden"
    table.cell(dash, 0, 4, "Repriced", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, rStr, text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Last", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, lastEvent, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 5)

// ─────────────── ALERTS ───────────────

alertcondition(evtBullFVG, title="Bullish FVG Detected", message="Bullish displacement FVG zone detected")
alertcondition(evtBearFVG, title="Bearish FVG Detected", message="Bearish displacement FVG zone detected")
alertcondition(evtBullFVG or evtBearFVG, title="FVG Detected", message="Displacement FVG zone detected")
alertcondition(evtRepriced, title="FVG Repriced", message="FVG zone repriced")
````

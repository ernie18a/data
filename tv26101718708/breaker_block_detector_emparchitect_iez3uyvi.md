# Breaker Block Detector [EmpArchitect]

- url: https://www.tradingview.com/script/iEZ3uyVI-Breaker-Block-Detector-EmpArchitect/
- type: indicator
- pine_id: PUB;fad716dc51ac43bf82e7792ef86ac9c2
- version: 1.0

## Description

█ OVERVIEW

Breaker Block Detector [EmpArchitect] identifies order-block failure zones that flip into breaker blocks.

When an order block breaks, it does not simply disappear. The failed zone can become the next structural reference point. This indicator detects those failed OB zones, converts them into bullish or bearish breaker blocks, and grades the break quality from A to C.

No signals. No entries. No targets. No trade calls.
Just breaker-block structure context for ICT, SMC, and price-action workflows.

█ WHAT IT SHOWS

Bullish Breaker:
A bearish OB near a swing low is broken upward with displacement. The failed bearish OB flips into a bullish breaker zone.

Bearish Breaker:
A bullish OB near a swing high is broken downward with displacement. The failed bullish OB flips into a bearish breaker zone.

Fresh zones extend to the right until they are retested or invalidated.

█ HOW IT WORKS

1. Detects confirmed pivot highs and lows.
2. Searches near the pivot for the relevant OB candle.
3. Tracks the OB as a pending breaker candidate.
4. Converts it into a breaker block only after price breaks through it with enough displacement.
5. Grades the break candle:
   • A = strong displacement
   • B = moderate displacement
   • C = minimum valid displacement
6. Deletes or hides zones after retest depending on settings.

█ VISUAL SYSTEM

Bullish breakers = teal zones.
Bearish breakers = amber zones.
A/B/C labels show displacement quality.
Tested zones are hidden by default for a cleaner chart.

Recommended clean mode:
• Show Tested Zones: OFF
• Trigger Markers: OFF
• Zone Source: Body
• Break Confirmation: Close

█ DASHBOARD

The top-right dashboard summarizes:

• Fresh bullish breakers
• Fresh bearish breakers
• Nearest breaker above price
• Nearest breaker below price
• Tested-zone status
• Last detected breaker event

This keeps the chart readable without forcing you to inspect every zone manually.

█ ALERTS

Included factual alerts:

• Bullish Breaker Formed
• Bearish Breaker Formed
• Any Breaker Formed
• Breaker Retested

These are structure alerts only. They are not buy or sell signals.

█ NON-REPAINTING NOTE

Breaker zones are based on confirmed pivots and confirmed break conditions. Pivot-based detection confirms after the selected swing length, which is normal structural confirmation, not repainting.

█ PAIRS WITH

Smart Liquidity Map [EmpArchitect] — liquidity context
HTF Context Overlay [EmpArchitect] — higher-timeframe reference levels
ICT Dealing Range [EmpArchitect] — premium / discount context
Liquidity Trap Zones [EmpArchitect] — failed reversal context

█ NOTES

• Works on all instruments and timeframes
• Best viewed on 15M–4H charts
• Cleaner on 1H+ when using default settings
• Pine Script v6
• Built by EmpArchitect
• Educational context tool only
• Not financial advice
• Not a signal service

## Source Code

````pine
//@version=6
indicator("Breaker Block Detector [EmpArchitect]", shorttitle="Breakers [EA]", overlay=true, max_boxes_count=200, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════
// BREAKER BLOCK DETECTOR [EmpArchitect] v1.0
// ═══════════════════════════════════════════════════════════════════

// ─────────────── INPUTS ───────────────

grp1 = "Detection"
swingLen    = input.int(5, "Swing Length", minval=2, maxval=20, group=grp1)
obWindow    = input.int(5, "OB Search Window", minval=1, maxval=20, group=grp1, tooltip="Candles to search back from pivot for OB candle.")
pendExpiry  = input.int(150, "Pending OB Expiry (bars)", minval=50, maxval=500, group=grp1)
zoneSrc     = input.string("Body", "Zone Source", options=["Body", "Full Candle"], group=grp1)
breakConf   = input.string("Close", "Break Confirmation", options=["Close", "Wick"], group=grp1)
dirBreak    = input.bool(true, "Directional Break Candle", group=grp1)
minDispATR  = input.float(1.0, "Min Break Displacement ATR", minval=0.3, maxval=3.0, step=0.05, group=grp1)
atrLen      = input.int(14, "ATR Length", minval=5, maxval=50, group=grp1)
maxZoneATR  = input.float(2.0, "Max Zone Height ATR", minval=0.5, maxval=10.0, step=0.25, group=grp1, tooltip="Reject oversized zones.")

grp2 = "Display"
showBull    = input.bool(true, "Show Bullish Breakers", group=grp2)
showBear    = input.bool(true, "Show Bearish Breakers", group=grp2)
maxZones    = input.int(5, "Max Active Zones Per Side", minval=3, maxval=20, group=grp2)
showTested  = input.bool(false, "Show Tested Zones", group=grp2, tooltip="OFF: tested zones removed. ON: tested zones fade gray as visual archive.")
showMarkers = input.bool(false, "Show Trigger Markers", group=grp2)
showLabels  = input.bool(true, "Show Labels", group=grp2)
showDash    = input.bool(true, "Show Dashboard", group=grp2)

grp3 = "Grading"
gradeA_ATR  = input.float(1.75, "A Grade (ATR)", minval=1.0, maxval=5.0, step=0.05, group=grp3)
gradeB_ATR  = input.float(1.25, "B Grade (ATR)", minval=0.5, maxval=3.0, step=0.05, group=grp3)

grp4 = "Style"
bullCol     = input.color(color.new(#00D9A3, 25), "Bullish Breaker", group=grp4)
bearCol     = input.color(color.new(#F59E0B, 25), "Bearish Breaker", group=grp4)
testedCol   = input.color(color.new(#6B7280, 60), "Tested Zone", group=grp4)

// ─────────────── ATR + PIVOTS ───────────────

atr = ta.atr(atrLen)
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// ─────────────── OB SEARCH ───────────────

f_findBearOB(int pivotOffset) =>
    float obTop = na
    float obBot = na
    int obBar = na
    for i = pivotOffset to pivotOffset + obWindow - 1
        if i < bar_index and close[i] < open[i]
            obTop := zoneSrc == "Body" ? open[i] : high[i]
            obBot := zoneSrc == "Body" ? close[i] : low[i]
            obBar := bar_index - i
            break
    [obTop, obBot, obBar]

f_findBullOB(int pivotOffset) =>
    float obTop = na
    float obBot = na
    int obBar = na
    for i = pivotOffset to pivotOffset + obWindow - 1
        if i < bar_index and close[i] > open[i]
            obTop := zoneSrc == "Body" ? close[i] : high[i]
            obBot := zoneSrc == "Body" ? open[i] : low[i]
            obBar := bar_index - i
            break
    [obTop, obBot, obBar]

// ─────────────── BREAK SCAN (uses atr[i]) ───────────────

f_scanBreakBull(float obTop, int fromOffset) =>
    int breakBar = na
    float ratio = na
    for i = fromOffset to 0
        float c = close[i]
        float o = open[i]
        float bd = math.abs(c - o)
        float a = atr[i]
        bool broke = breakConf == "Close" ? c > obTop : high[i] > obTop
        bool dirOK = not dirBreak or (c > o)
        bool hasDisp = not na(a) and a > 0 and bd >= minDispATR * a
        if broke and dirOK and hasDisp
            breakBar := bar_index - i
            ratio := a > 0 ? bd / a : 0.0
            break
    [breakBar, ratio]

f_scanBreakBear(float obBot, int fromOffset) =>
    int breakBar = na
    float ratio = na
    for i = fromOffset to 0
        float c = close[i]
        float o = open[i]
        float bd = math.abs(c - o)
        float a = atr[i]
        bool broke = breakConf == "Close" ? c < obBot : low[i] < obBot
        bool dirOK = not dirBreak or (c < o)
        bool hasDisp = not na(a) and a > 0 and bd >= minDispATR * a
        if broke and dirOK and hasDisp
            breakBar := bar_index - i
            ratio := a > 0 ? bd / a : 0.0
            break
    [breakBar, ratio]

// ─────────────── POST-BREAK STATE SCAN ───────────────

f_postBreakState(float zTop, float zBot, bool isBull, int breakBarIdx) =>
    int state = 0
    int eventBar = na
    int offset = bar_index - breakBarIdx - 1
    if offset > 0
        for i = offset to 1
            int thisBar = bar_index - i
            float c = close[i]
            float h = high[i]
            float l = low[i]
            if isBull and c < zBot
                state := -1
                eventBar := thisBar
                break
            if not isBull and c > zTop
                state := -1
                eventBar := thisBar
                break
            if state == 0 and l <= zTop and h >= zBot
                state := 1
                eventBar := thisBar
                break
    [state, eventBar]

// ─────────────── GRADE ───────────────

f_gradeRatio(float r) =>
    r >= gradeA_ATR ? "A" : r >= gradeB_ATR ? "B" : "C"

// ─────────────── PENDING OB ARRAYS ───────────────

var float[] pendTop     = array.new_float()
var float[] pendBot     = array.new_float()
var int[]   pendBorn    = array.new_int()
var bool[]  pendIsBull  = array.new_bool()
var int[]   pendObBar   = array.new_int()

// ─────────────── ACTIVE (FRESH) BREAKER ARRAYS ───────────────

var box[]    brkBox     = array.new_box()
var label[]  brkLbl     = array.new_label()
var float[]  brkTop     = array.new_float()
var float[]  brkBot     = array.new_float()
var bool[]   brkIsBull  = array.new_bool()
var string[] brkGrade   = array.new_string()
var int[]    brkBorn    = array.new_int()

// ─────────────── TESTED ARCHIVE (visual only) ───────────────

var box[]   tstBox      = array.new_box()

// ─────────────── HELPERS ───────────────

f_delFresh(int i) =>
    box.delete(array.get(brkBox, i))
    lb = array.get(brkLbl, i)
    if not na(lb)
        label.delete(lb)
    array.remove(brkBox, i)
    array.remove(brkLbl, i)
    array.remove(brkTop, i)
    array.remove(brkBot, i)
    array.remove(brkIsBull, i)
    array.remove(brkGrade, i)
    array.remove(brkBorn, i)

f_archiveFresh(int i) =>
    // Move box to tested archive, delete label, remove from fresh arrays
    bx = array.get(brkBox, i)
    box.set_bgcolor(bx, testedCol)
    box.set_border_color(bx, color.new(#6B7280, 40))
    box.set_extend(bx, extend.none)
    box.set_right(bx, bar_index)
    array.push(tstBox, bx)
    lb = array.get(brkLbl, i)
    if not na(lb)
        label.delete(lb)
    // Remove from fresh WITHOUT deleting box
    array.remove(brkBox, i)
    array.remove(brkLbl, i)
    array.remove(brkTop, i)
    array.remove(brkBot, i)
    array.remove(brkIsBull, i)
    array.remove(brkGrade, i)
    array.remove(brkBorn, i)

f_brkColor(bool isBull, string grade) =>
    color baseCol = isBull ? bullCol : bearCol
    int transp = grade == "A" ? 20 : grade == "B" ? 45 : 70
    color.new(baseCol, transp)

f_borderColor(bool isBull) =>
    isBull ? color.new(#00D9A3, 5) : color.new(#F59E0B, 5)

// ─────────────── EVENTS ───────────────

var bool evtBullBrk = false
var bool evtBearBrk = false
var bool evtRetest = false
var string lastEvent = "—"

evtBullBrk := false
evtBearBrk := false
evtRetest := false

// ─────────────── CREATE BREAKER ───────────────
// Compares ONLY against fresh zones for duplicates.
// initState 0 = fresh (goes to active arrays)
// initState 1 = already tested (goes to tested archive if showTested)

f_createBreaker(float pT, float pB, bool pBull, int obSourceBar, int breakBarIdx, string grade, int initState, int eventBar) =>
    float newMid = (pT + pB) / 2
    bool rejected = false

    // Zone height filter
    float zoneHeight = math.abs(pT - pB)
    if not na(atr) and atr > 0 and zoneHeight > maxZoneATR * atr
        rejected := true

    // Duplicate filter: FRESH zones only
    if not rejected and array.size(brkTop) > 0
        for j = array.size(brkTop) - 1 to 0
            if j < array.size(brkTop) and array.get(brkIsBull, j) == pBull
                float existMid = (array.get(brkTop, j) + array.get(brkBot, j)) / 2
                if not na(atr) and math.abs(newMid - existMid) < atr * 0.50
                    string existGrade = array.get(brkGrade, j)
                    bool newBetter = (grade == "A" and existGrade != "A") or (grade == "B" and existGrade == "C")
                    if newBetter
                        f_delFresh(j)
                    else
                        rejected := true
                    break

    if not rejected
        bool showThis = (pBull and showBull) or (not pBull and showBear)
        if showThis
            if initState == 1
                // Historical: already tested → tested archive only
                if showTested
                    int boxRight = not na(eventBar) ? eventBar : bar_index
                    box tbx = box.new(obSourceBar, pT, boxRight, pB, bgcolor=testedCol, border_color=color.new(#6B7280, 40), border_width=1)
                    array.push(tstBox, tbx)
                // Do NOT add to fresh arrays regardless of showTested
            else
                // Fresh zone → active arrays
                color fc = f_brkColor(pBull, grade)
                color bc = f_borderColor(pBull)
                box bx = box.new(obSourceBar, pT, bar_index + 1, pB, bgcolor=fc, border_color=bc, border_width=1, extend=extend.right)

                label lb = na
                if showLabels
                    string side = pBull ? "Bull" : "Bear"
                    string txt = side + " BRK " + grade
                    float labelY = pBull ? pT : pB
                    lb := label.new(bar_index, labelY, txt, style=pBull ? label.style_label_down : label.style_label_up, color=color.new(pBull ? #00D9A3 : #F59E0B, 70), textcolor=color.white, size=size.tiny)

                if showMarkers
                    string mTxt = "◆ " + grade
                    int mOffset = bar_index - breakBarIdx
                    float mY = pBull ? low[mOffset] - nz(atr, 0) * 0.15 : high[mOffset] + nz(atr, 0) * 0.15
                    label.new(breakBarIdx, mY, mTxt, style=pBull ? label.style_label_up : label.style_label_down, color=color.new(color.black, 100), textcolor=pBull ? #00D9A3 : #F59E0B, size=size.tiny)

                array.push(brkBox, bx)
                array.push(brkLbl, lb)
                array.push(brkTop, pT)
                array.push(brkBot, pB)
                array.push(brkIsBull, pBull)
                array.push(brkGrade, grade)
                array.push(brkBorn, bar_index)

    rejected

// ─────────────── NEW PIVOT: SCAN + CREATE OR PEND ───────────────

if not na(pl)
    [obT, obB, obBr] = f_findBearOB(swingLen)
    if not na(obT) and not na(obB) and not na(obBr)
        [bBar, bRatio] = f_scanBreakBull(obT, swingLen - 1)
        if not na(bBar) and not na(bRatio) and bRatio >= minDispATR
            string grade = f_gradeRatio(bRatio)
            [postState, postBar] = f_postBreakState(obT, obB, true, bBar)
            if postState != -1
                if postState == 1 and not showTested
                    noop = 0
                else
                    bool rej = f_createBreaker(obT, obB, true, obBr, bBar, grade, postState, nz(postBar, bar_index))
                    if not rej and postState == 0
                        evtBullBrk := true
                        lastEvent := "Bull Formed"
        else
            array.push(pendTop, obT)
            array.push(pendBot, obB)
            array.push(pendBorn, bar_index)
            array.push(pendIsBull, true)
            array.push(pendObBar, obBr)

if not na(ph)
    [obT, obB, obBr] = f_findBullOB(swingLen)
    if not na(obT) and not na(obB) and not na(obBr)
        [bBar, bRatio] = f_scanBreakBear(obB, swingLen - 1)
        if not na(bBar) and not na(bRatio) and bRatio >= minDispATR
            string grade = f_gradeRatio(bRatio)
            [postState, postBar] = f_postBreakState(obT, obB, false, bBar)
            if postState != -1
                if postState == 1 and not showTested
                    noop = 0
                else
                    bool rej = f_createBreaker(obT, obB, false, obBr, bBar, grade, postState, nz(postBar, bar_index))
                    if not rej and postState == 0
                        evtBearBrk := true
                        lastEvent := "Bear Formed"
        else
            array.push(pendTop, obT)
            array.push(pendBot, obB)
            array.push(pendBorn, bar_index)
            array.push(pendIsBull, false)
            array.push(pendObBar, obBr)

// ─────────────── PROCESS PENDING OBs ───────────────

if array.size(pendTop) > 0
    for i = array.size(pendTop) - 1 to 0
        if i >= array.size(pendTop)
            continue
        float pT = array.get(pendTop, i)
        float pB = array.get(pendBot, i)
        int   pBorn = array.get(pendBorn, i)
        bool  pBull = array.get(pendIsBull, i)
        int   pOBbar = array.get(pendObBar, i)

        bool remove = false

        if bar_index - pBorn > pendExpiry
            remove := true

        if not remove
            if pBull and close < pB
                remove := true
            if not pBull and close > pT
                remove := true

        if not remove
            float bodySize = math.abs(close - open)
            float curATR = nz(atr, 0)
            float ratio = curATR > 0 ? bodySize / curATR : 0.0
            bool hasDisp = ratio >= minDispATR

            if pBull
                bool broke = breakConf == "Close" ? close > pT : high > pT
                bool dirOK = not dirBreak or (close > open)
                if broke and hasDisp and dirOK
                    string grade = f_gradeRatio(ratio)
                    bool rej = f_createBreaker(pT, pB, true, pOBbar, bar_index, grade, 0, bar_index)
                    if not rej
                        evtBullBrk := true
                        lastEvent := "Bull Formed"
                    remove := true
            else
                bool broke = breakConf == "Close" ? close < pB : low < pB
                bool dirOK = not dirBreak or (close < open)
                if broke and hasDisp and dirOK
                    string grade = f_gradeRatio(ratio)
                    bool rej = f_createBreaker(pT, pB, false, pOBbar, bar_index, grade, 0, bar_index)
                    if not rej
                        evtBearBrk := true
                        lastEvent := "Bear Formed"
                    remove := true

        if remove
            array.remove(pendTop, i)
            array.remove(pendBot, i)
            array.remove(pendBorn, i)
            array.remove(pendIsBull, i)
            array.remove(pendObBar, i)

// ─────────────── PROCESS ACTIVE (FRESH) BREAKERS ───────────────
// CRITICAL: collect ALL actions first, execute AFTER the loop.
// No inline array removal during iteration.

int[] toDelete  = array.new_int()  // invalidated → delete box + remove
int[] toArchive = array.new_int()  // retested + showTested → archive box + remove
int[] toRemove  = array.new_int()  // retested + !showTested → delete box + remove

if array.size(brkTop) > 0
    for i = array.size(brkTop) - 1 to 0
        if i >= array.size(brkTop)
            continue
        float bT = array.get(brkTop, i)
        float bB = array.get(brkBot, i)
        bool  isBull = array.get(brkIsBull, i)
        int   born = array.get(brkBorn, i)
        label lb = array.get(brkLbl, i)

        if bar_index <= born
            continue

        // 1. INVALIDATION CHECK (first — priority over retest)
        bool invalidated = false
        if isBull and close < bB
            invalidated := true
        if not isBull and close > bT
            invalidated := true

        if invalidated
            array.push(toDelete, i)
            continue

        // 2. RETEST CHECK (price enters zone without invalidating)
        bool inZone = low <= bT and high >= bB
        if inZone and bar_index > born
            evtRetest := true
            lastEvent := isBull ? "Bull Retest" : "Bear Retest"
            if showTested
                array.push(toArchive, i)
            else
                array.push(toRemove, i)
            continue

        // 3. EXTEND label (still fresh, not touched)
        if not na(lb)
            label.set_x(lb, bar_index)
            label.set_y(lb, isBull ? bT : bB)

// ─── Execute actions: highest index first (all arrays collected descending) ───

// Archive first (move to tested, keep box visible)
if array.size(toArchive) > 0
    for j = 0 to array.size(toArchive) - 1
        int idx = array.get(toArchive, j)
        if idx < array.size(brkBox)
            f_archiveFresh(idx)

// Remove retested (showTested=false, delete everything)
if array.size(toRemove) > 0
    for j = 0 to array.size(toRemove) - 1
        int idx = array.get(toRemove, j)
        if idx < array.size(brkBox)
            f_delFresh(idx)

// Delete invalidated
if array.size(toDelete) > 0
    for j = 0 to array.size(toDelete) - 1
        int idx = array.get(toDelete, j)
        if idx < array.size(brkBox)
            f_delFresh(idx)

// ─────────────── ZONE CAP (fresh only) ───────────────

int bullCount = 0
int bearCount = 0
int[] prune = array.new_int()

if array.size(brkTop) > 0
    for i = array.size(brkTop) - 1 to 0
        if array.get(brkIsBull, i)
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
        if idx < array.size(brkBox)
            f_delFresh(idx)

// Final fresh count
bullCount := 0
bearCount := 0
if array.size(brkTop) > 0
    for i = 0 to array.size(brkTop) - 1
        if array.get(brkIsBull, i)
            bullCount += 1
        else
            bearCount += 1

// ─────────────── NEAREST BREAKER (fresh only) ───────────────

float nearAbove = na
string nearAboveN = ""
float nearBelow = na
string nearBelowN = ""

if array.size(brkTop) > 0
    for i = 0 to array.size(brkTop) - 1
        float bT = array.get(brkTop, i)
        float bB = array.get(brkBot, i)
        bool isBull = array.get(brkIsBull, i)
        string g = array.get(brkGrade, i)
        float mid = (bT + bB) / 2
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

    table.cell(dash, 0, 0, "Breaker Blocks", text_color=color.white, text_size=size.small, text_halign=text.align_left)
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

    string tstStr = showTested ? str.tostring(array.size(tstBox)) : "Hidden"
    table.cell(dash, 0, 4, "Tested", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, tstStr, text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Last", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, lastEvent, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 1, 5)

// ─────────────── ALERTS ───────────────

alertcondition(evtBullBrk, title="Bullish Breaker Formed", message="Bullish breaker block formed")
alertcondition(evtBearBrk, title="Bearish Breaker Formed", message="Bearish breaker block formed")
alertcondition(evtBullBrk or evtBearBrk, title="Breaker Formed", message="Breaker block formed")
alertcondition(evtRetest, title="Breaker Retested", message="Breaker block zone retested")
````

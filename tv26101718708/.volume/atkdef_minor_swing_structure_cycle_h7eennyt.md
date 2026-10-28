# ATK/DEF Minor Swing Structure cycle

- url: https://www.tradingview.com/script/h7eennyT/
- type: indicator
- pine_id: PUB;4501d535d1934cad9547e55c64fb54b3
- version: 1.0

## Description

ATK/DEF — Minor Swing Structure Cycle is a medium-scale market structure observation framework built around Minor Swing High / Low.

Minor Swing is used to record structural changes at a larger scale than Micro Swing and to organize the progression of market structure from formation, movement, interaction, structural break, repair, and subsequent reorganization.

## Minor Swing Structure

Minor Swing High and Minor Swing Low are generated from a configurable Pivot Length.

Each Minor Swing maintains structural information including:

* Minor Swing High
* Minor Swing Low
* ATR reference
* Structural position
* Structural retracement
* Structural break
* Structural return
* Subsequent structure formation

Each Minor Swing retains its own structural record while its subsequent changes are continuously tracked.

## Minor Structure Cycle

The core of the Minor Swing framework is organized into seven structural stages:

### ① Initiation — Market Initiation

Records the earliest Minor Swing direction within the defined reference structure.

### ② Activation — Market Activation

Observes the movement speed of recent Minor Swings in the same direction and normalizes the movement using ATR.

### ③ Pull — Market Pull

Calculates the structural relationship between the current Minor Swing and the preceding opposite-direction Minor Swing.

### ④ Counteraction — Market Counteraction

Records whether the current Minor Swing has experienced a structural break.

### ⑤ Displacement — Market Displacement

Observes the position of the current Minor Swing relative to the midpoint of the reference structure range.

### ⑥ Repair — Market Repair

After a structural break occurs, tracks the relationship of price returning toward the original structure range.

### ⑦ Reorganization — Market Reorganization

Records subsequent same-direction Minor Swings formed after a structural break, providing a reference for observing how the structure reorganizes.

## Market Structure Table

The right-side table organizes Minor Swing High and Minor Swing Low into seven structural dimensions:

**Initiation → Activation → Pull → Counteraction → Displacement → Repair → Reorganization**

The table displays corresponding structural direction, ATR-normalized movement, structural pull, break state, positional displacement, repair relationship, and subsequent structure formation.

## Structure Cycle

**Initiation → Activation → Pull → Counteraction → Displacement → Repair → Reorganization**

These seven stages form the Minor Swing structural cycle.

The cycle is designed to record and observe the progression of Minor Swing structure from initial formation through structural changes and subsequent reorganization.

## Display

Configurable components include:

* Minor Swing Pivot Length
* High / Low Display
* High / Low Colors
* ATR Length
* Deduplication Mode
* ATR / Percent / Points Reference
* ATR Deviation
* Position
* Retracement
* Volume
* Lifecycle Reference Range
* Minor Structure Table

## Scope

For market observation and user-defined technical analysis only.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF Minor Swing Structure cycle", shorttitle="Minor Swing", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
minorLen  = input.int(3, "Minor Swing Pivot Length", minval=1)
highColor = input.color(color.new(color.orange, 0), "Minor Swing High Color")
lowColor  = input.color(color.new(color.purple, 0), "Minor Swing Low Color")
labelSize = input.string("tiny", "Text Size", options=["tiny", "small", "normal", "large"])

// Display switches
showHigh = input.bool(true, "Show High + Line")
showLow  = input.bool(true, "Show Low + Line")

// Line
lineWidth = input.int(1, "Line Width", minval=1, maxval=5)
extendLen = input.int(3, "Line Length (bars)", minval=1)

// Deduplication
zoneMode   = input.string("ATR", "Dedup Mode", options=["ATR", "Percent", "Points"])
zoneATR    = input.float(0.3, "Same-Zone ATR Multiplier", minval=0.0, step=0.1)
zonePct    = input.float(0.03, "Same-Zone Percent (%)", minval=0.0, step=0.01)
zonePoints = input.float(1.0, "Same-Zone Points", minval=0.0, step=0.5)
atrLen     = input.int(14, "ATR Length", minval=1)

// Label extensions
rangeLookback = input.int(10, "Position Lookback Swings", minval=2, maxval=50)
showATRDist   = input.bool(true, "Show ATR Deviation")
showRelPos    = input.bool(true, "Show Position")
showRetrace   = input.bool(true, "Show Retrace")
showVol       = input.bool(true, "Show Volume (K)")

// Lifecycle table
showLifeTable = input.bool(true, "Show Lifecycle Table", group="Lifecycle")
lifeRefLen    = input.int(50, "Deviation Reference Swings", minval=4, maxval=50, group="Lifecycle")

f_size(string s) =>
    string result = s
    switch result
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.large

// ═══════════════════════════ UDT ═══════════════════════════
type SwingRecord
    int    dir
    int    x
    float  y
    float  atrAtBar
    float  volAtBar
    label  lbl
    line   ln
    label  vLbl
    int    touches
    int    birthX
    int    lastTouchX
    bool   broken
    bool   returned
    int    breakX

// ═══════════════════════════ PIVOT DETECTION ═══════════════════════════
minorHighPt = ta.pivothigh(high, minorLen, minorLen)
minorLowPt  = ta.pivotlow(low, minorLen, minorLen)

atrVal = ta.atr(atrLen)
zone = zoneMode == "ATR" ? atrVal * zoneATR : zoneMode == "Percent" ? close * zonePct / 100 : zonePoints

// ═══════════════════════════ STATE ═══════════════════════════
var float prevMicroHY = na
var float prevMicroLY = na

// ═══════════════════════════ UDT FIFO ═══════════════════════════
MAX_SWINGS = 50

var array<SwingRecord> highRecords = array.new<SwingRecord>()
var array<SwingRecord> lowRecords  = array.new<SwingRecord>()

fifoHigh() =>
    while array.size(highRecords) > MAX_SWINGS
        SwingRecord old = array.shift(highRecords)
        if not na(old.lbl)
            label.delete(old.lbl)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.vLbl)
            label.delete(old.vLbl)

fifoLow() =>
    while array.size(lowRecords) > MAX_SWINGS
        SwingRecord old = array.shift(lowRecords)
        if not na(old.lbl)
            label.delete(old.lbl)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.vLbl)
            label.delete(old.vLbl)

// ═══════════════════════════ LABEL TEXT ═══════════════════════════
f_makeBaseText(string base, float py, float atrNow, int dir) =>
    string txt = base

    if showATRDist and (array.size(highRecords) > 0 or array.size(lowRecords) > 0)
        SwingRecord last = na
        if array.size(highRecords) > 0 and array.size(lowRecords) > 0
            SwingRecord h = array.get(highRecords, array.size(highRecords) - 1)
            SwingRecord l = array.get(lowRecords,  array.size(lowRecords)  - 1)
            last := h.x > l.x ? h : l
        else if array.size(highRecords) > 0
            last := array.get(highRecords, array.size(highRecords) - 1)
        else
            last := array.get(lowRecords, array.size(lowRecords) - 1)
        float diff = py - last.y
        float atrDist = atrNow > 0 ? diff / atrNow : 0.0
        txt := txt + "\nΔATR: " + str.tostring(atrDist, "#.##")

    if showRelPos and (array.size(highRecords) + array.size(lowRecords)) >= 2
        float hi = py
        float lo = py
        int nH = math.min(rangeLookback, array.size(highRecords))
        int nL = math.min(rangeLookback, array.size(lowRecords))
        if nH > 0
            for i = 0 to nH - 1
                SwingRecord r = array.get(highRecords, array.size(highRecords) - 1 - i)
                hi := math.max(hi, r.y)
                lo := math.min(lo, r.y)
        if nL > 0
            for i = 0 to nL - 1
                SwingRecord r = array.get(lowRecords, array.size(lowRecords) - 1 - i)
                hi := math.max(hi, r.y)
                lo := math.min(lo, r.y)
        float rng = hi - lo
        float relPos = rng > 0 ? (py - lo) / rng : 0.5
        txt := txt + "\nPos: " + str.tostring(relPos * 100, "#.#") + "%"

    if showRetrace and atrNow > 0
        if dir == 1
            if array.size(lowRecords) > 0
                SwingRecord ref = array.get(lowRecords, array.size(lowRecords) - 1)
                float retr = (py - ref.y) / atrNow
                txt := txt + "\nRetr: " + str.tostring(retr, "#.##") + " ATR"
        else
            if array.size(highRecords) > 0
                SwingRecord ref = array.get(highRecords, array.size(highRecords) - 1)
                float retr = (ref.y - py) / atrNow
                txt := txt + "\nRetr: " + str.tostring(retr, "#.##") + " ATR"

    txt

// ═══════════════════════════ MARKET LIFECYCLE: 7 STAGES ═══════════════════════════
// ① Market Initiation      : direction of earliest Minor in the sequence
// ② Market Activation      : speed of last two Minors |Δy| / Δx, in ATR
// ③ Market Pull            : last Minor's retrace vs previous opposite Minor
// ④ Market Counteraction   : times Minor was broken by opposite direction
// ⑤ Market Displacement    : current Minor's deviation from mid-range
// ⑥ Market Repair          : after broken, how much price came back into range
// ⑦ Market Reorganization  : after broken, how many times structure was rebuilt
f_market(int dir) =>
    string initTxt = "—"
    float  actVal  = 0.0
    float  pullVal = 0.0
    int    counterVal = 0
    float  dispVal = 0.0
    float  repairVal = 0.0
    int    reorgVal = 0

    // ── Reference range: last lifeRefLen swings ──
    float hi = na
    float lo = na
    int maxX = na
    int minX = na
    int nH = math.min(lifeRefLen, array.size(highRecords))
    int nL = math.min(lifeRefLen, array.size(lowRecords))
    if nH > 0
        for i = 0 to nH - 1
            SwingRecord r = array.get(highRecords, array.size(highRecords) - 1 - i)
            hi := na(hi) ? r.y : math.max(hi, r.y)
            lo := na(lo) ? r.y : math.min(lo, r.y)
            maxX := na(maxX) ? r.x : math.max(maxX, r.x)
            minX := na(minX) ? r.x : math.min(minX, r.x)
    if nL > 0
        for i = 0 to nL - 1
            SwingRecord r = array.get(lowRecords, array.size(lowRecords) - 1 - i)
            hi := na(hi) ? r.y : math.max(hi, r.y)
            lo := na(lo) ? r.y : math.min(lo, r.y)
            maxX := na(maxX) ? r.x : math.max(maxX, r.x)
            minX := na(minX) ? r.x : math.min(minX, r.x)

    float mid = not na(hi) and not na(lo) ? (hi + lo) / 2 : close
    float rng = not na(hi) and not na(lo) ? hi - lo : 0.0
    float rngSafe = rng > 0 ? rng : 0.0001

    // ── Current Minor ──
    SwingRecord cur = na
    if dir == 1 and array.size(highRecords) > 0
        cur := array.get(highRecords, array.size(highRecords) - 1)
    if dir == -1 and array.size(lowRecords) > 0
        cur := array.get(lowRecords, array.size(lowRecords) - 1)

    // ── Previous opposite Minor ──
    SwingRecord prevOpp = na
    if dir == 1 and array.size(lowRecords) > 0 and not na(cur)
        for i = array.size(lowRecords) - 1 to 0
            SwingRecord r = array.get(lowRecords, i)
            if r.x < cur.x
                prevOpp := r
                break
    if dir == -1 and array.size(highRecords) > 0 and not na(cur)
        for i = array.size(highRecords) - 1 to 0
            SwingRecord r = array.get(highRecords, i)
            if r.x < cur.x
                prevOpp := r
                break

    if not na(cur)
        // ① Market Initiation: direction of earliest Minor in the reference window
        // Find the oldest swing within the last lifeRefLen
        int total = array.size(highRecords) + array.size(lowRecords)
        if total > 0
            // The oldest in the combined reference set
            int nHref = math.min(lifeRefLen, array.size(highRecords))
            int nLref = math.min(lifeRefLen, array.size(lowRecords))
            int oldestX = na
            int oldestDir = 0
            if nHref > 0
                SwingRecord h0 = array.get(highRecords, array.size(highRecords) - nHref)
                oldestX := h0.x
                oldestDir := 1
            if nLref > 0
                SwingRecord l0 = array.get(lowRecords, array.size(lowRecords) - nLref)
                if na(oldestX) or l0.x < oldestX
                    oldestX := l0.x
                    oldestDir := -1
            initTxt := oldestDir == 1 ? "⬆️" : "⬇️"

        // ② Market Activation: speed of last two same-direction Minors
        array<SwingRecord> sameArr = dir == 1 ? highRecords : lowRecords
        if array.size(sameArr) >= 2
            SwingRecord a = array.get(sameArr, array.size(sameArr) - 2)
            SwingRecord b = array.get(sameArr, array.size(sameArr) - 1)
            int dx = b.x - a.x
            if dx > 0 and atrVal > 0
                actVal := math.abs(b.y - a.y) / dx / atrVal

        // ③ Market Pull: current vs previous opposite
        if not na(prevOpp)
            pullVal := dir == 1 ? (cur.y - prevOpp.y) / rngSafe * 100 : (prevOpp.y - cur.y) / rngSafe * 100

        // ④ Market Counteraction: times Minor was broken
        if cur.broken
            counterVal := 1
        else
            counterVal := 0

        // ⑤ Market Displacement: current vs mid-range
        dispVal := (cur.y - mid) / rngSafe * 100

        // ⑥ Market Repair: if broken + returned, how much came back
        if cur.broken and cur.returned
            float backDist = dir == 1 ? (cur.y - close) : (close - cur.y)
            repairVal := backDist / rngSafe * 100
        else
            repairVal := 0.0

        // ⑦ Market Reorganization: rebuilt count (approximate: how many same-direction swings formed after this one broke)
        if cur.broken
            int reorg = 0
            for i = 0 to array.size(sameArr) - 1
                SwingRecord r = array.get(sameArr, i)
                if r.x > cur.breakX and r.x != cur.x
                    reorg := reorg + 1
            reorgVal := reorg

    [initTxt, actVal, pullVal, counterVal, dispVal, repairVal, reorgVal]

// ═══════════════════════════ MINOR HIGH ═══════════════════════════
if not na(minorHighPt)
    px = bar_index - minorLen
    py = minorHighPt
    float v = volume[minorLen]
    notDup = na(prevMicroHY) or math.abs(py - prevMicroHY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Minor Swing High", py, atrVal, 1)

        line   lnNew = na
        label  lbNew = na
        label  vLbl  = na

        if showHigh
            lnNew := line.new(px, py, px + extendLen, py,
                              xloc = xloc.bar_index,
                              color = highColor, width = lineWidth)
            lbNew := label.new(px, py, baseTxt,
                               style = label.style_label_down,
                               size = f_size(labelSize),
                               color = color.new(highColor, 25),
                               textcolor = color.white,
                               xloc = xloc.bar_index)
            if showVol
                vLbl := label.new(px + extendLen / 2, py,
                                  "Vol: " + str.tostring(v / 1000, "#.#") + "K",
                                  style = label.style_label_down,
                                  size = f_size(labelSize),
                                  color = color.new(highColor, 100),
                                  textcolor = highColor,
                                  xloc = xloc.bar_index)

        SwingRecord rec = SwingRecord.new(1, px, py, atrVal, v, lbNew, lnNew, vLbl,
                                          0, px, px, false, false, 0)
        array.push(highRecords, rec)
        fifoHigh()
        prevMicroHY := py

// ═══════════════════════════ MINOR LOW ═══════════════════════════
if not na(minorLowPt)
    px = bar_index - minorLen
    py = minorLowPt
    float v = volume[minorLen]
    notDup = na(prevMicroLY) or math.abs(py - prevMicroLY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Minor Swing Low", py, atrVal, -1)

        line   lnNew = na
        label  lbNew = na
        label  vLbl  = na

        if showLow
            lnNew := line.new(px, py, px + extendLen, py,
                              xloc = xloc.bar_index,
                              color = lowColor, width = lineWidth)
            lbNew := label.new(px, py, baseTxt,
                               style = label.style_label_up,
                               size = f_size(labelSize),
                               color = color.new(lowColor, 25),
                               textcolor = color.white,
                               xloc = xloc.bar_index)
            if showVol
                vLbl := label.new(px + extendLen / 2, py,
                                  "Vol: " + str.tostring(v / 1000, "#.#") + "K",
                                  style = label.style_label_up,
                                  size = f_size(labelSize),
                                  color = color.new(lowColor, 100),
                                  textcolor = lowColor,
                                  xloc = xloc.bar_index)

        SwingRecord rec = SwingRecord.new(-1, px, py, atrVal, v, lbNew, lnNew, vLbl,
                                          0, px, px, false, false, 0)
        array.push(lowRecords, rec)
        fifoLow()
        prevMicroLY := py

// ═══════════════════════════ LIFECYCLE TRACKING (main scope) ═══════════════════════════
if array.size(highRecords) > 0
    for i = 0 to array.size(highRecords) - 1
        SwingRecord r = array.get(highRecords, i)
        if not r.broken
            bool hit = low <= r.y and high >= r.y
            if hit
                r.touches := r.touches + 1
                r.lastTouchX := bar_index
            if close > r.y
                r.broken := true
                r.breakX := bar_index
        else
            if not r.returned and close < r.y
                r.returned := true

if array.size(lowRecords) > 0
    for i = 0 to array.size(lowRecords) - 1
        SwingRecord r = array.get(lowRecords, i)
        if not r.broken
            bool hit = low <= r.y and high >= r.y
            if hit
                r.touches := r.touches + 1
                r.lastTouchX := bar_index
            if close < r.y
                r.broken := true
                r.breakX := bar_index
        else
            if not r.returned and close > r.y
                r.returned := true

// ═══════════════════════════ MARKET TABLE (top-right, 7 cols × 3 rows) ═══════════════════════════
if showLifeTable
    [hInit, hAct, hPull, hCnt, hDisp, hRep, hReorg] = f_market(1)
    [lInit, lAct, lPull, lCnt, lDisp, lRep, lReorg] = f_market(-1)

    var table mktTbl = table.new(position.top_right, 7, 3,
                                 bgcolor = color.rgb(25, 25, 30),
                                 border_color = color.rgb(70, 70, 80),
                                 border_width = 1,
                                 frame_width = 1)

    // Header row
    table.cell(mktTbl, 0, 0, "① Initiation",    text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 1, 0, "② Activation",    text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 2, 0, "③ Pull",          text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 3, 0, "④ Counteraction", text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 4, 0, "⑤ Displacement",  text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 5, 0, "⑥ Repair",        text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 6, 0, "⑦ Reorganization",text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))

    // H row
    color hBg = color.rgb(60, 30, 60)
    table.cell(mktTbl, 0, 1, "H " + hInit,                                             text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 1, 1, "H " + str.tostring(hAct, "#.##") + " ATR",               text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 2, 1, "H " + str.tostring(hPull, "#.#") + "%",                  text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 3, 1, "H " + str.tostring(hCnt),                                text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 4, 1, "H " + str.tostring(hDisp, "+#.#;-#.#") + "%",            text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 5, 1, "H " + str.tostring(hRep, "#.#") + "%",                   text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 6, 1, "H " + str.tostring(hReorg),                              text_color = highColor, text_size = size.tiny, bgcolor = hBg)

    // L row
    color lBg = color.rgb(30, 60, 30)
    table.cell(mktTbl, 0, 2, "L " + lInit,                                             text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 1, 2, "L " + str.tostring(lAct, "#.##") + " ATR",               text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 2, 2, "L " + str.tostring(lPull, "#.#") + "%",                  text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 3, 2, "L " + str.tostring(lCnt),                                text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 4, 2, "L " + str.tostring(lDisp, "+#.#;-#.#") + "%",            text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 5, 2, "L " + str.tostring(lRep, "#.#") + "%",                   text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 6, 2, "L " + str.tostring(lReorg),                              text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
````

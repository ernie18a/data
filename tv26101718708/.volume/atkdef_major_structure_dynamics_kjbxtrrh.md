# ATK/DEF Major Structure Dynamics

- url: https://www.tradingview.com/script/kJbXtrrH/
- type: indicator
- pine_id: PUB;4a4695bc8bf348b3be52e3068279f19a
- version: 1.0

## Description

ATK/DEF Major Structure Dynamics is a major-scale market structure observation framework built around Major Swing High / Low.

The framework focuses on the structural behavior of Major Swings across a defined reference window, with eight core dimensions describing the progression of the current Major structure.

## Major Swing Structure

Major Swing High and Major Swing Low are generated from a configurable Pivot Length.

Each Major Swing records its structural position and subsequent interaction, including:

* Major Swing High
* Major Swing Low
* ATR reference
* Position
* Retracement
* Volume
* Touch count
* Structural break
* Post-break extension
* Structural return

The framework maintains separate Major High and Major Low records and tracks their structural changes over time.

## Major Structure Dynamics

The primary focus of the framework is the following eight structural dimensions:

### ① Restart

Records the direction of the oldest Swing within the reference window.

This identifies which side started the current Major structure.

### ② Restoring

Measures the distance from the current Major Swing to the previous opposite Major Swing, normalized by ATR.

A higher value represents a larger structural movement.

### ③ Takeover

Measures the movement speed of the most recent same-direction Major Swings, normalized by ATR.

A higher value represents greater relative movement intensity.

### ④ Concentration

Measures the current Major Swing's position within the reference range.

**0%** represents the low of the reference range, while **100%** represents the high.

### ⑤ Overload

Records how many times the current Major Swing level has been touched.

The value represents the accumulated structural interactions with the Major level.

### ⑥ Pressure

After the Major Swing is broken, measures how far price extends beyond the Major level, normalized by ATR.

The value represents the post-break extension from the original Major structure.

### ⑦ Replenish

When the Major Swing is broken and price subsequently returns, measures how much of the reference range is recovered.

### ⑧ Withdrawal

After the Major Swing is broken, measures how far price remains outside the original Major Swing level.

## Major Market Table

The market table organizes Major Swing High and Major Swing Low into the eight structural dimensions:

**Restart → Restoring → Takeover → Concentration → Overload → Pressure → Replenish → Withdrawal**

Separate **H / L** values are displayed for the corresponding Major Swing structures.

The table provides directional reference, ATR-normalized structural movement, movement intensity, reference-range position, touch count, post-break extension, recovery, and remaining displacement outside the Major level.

## Display

Configurable components include:

* Major Swing Pivot Length
* High / Low Display
* High / Low Colors
* ATR Length
* Deduplication Mode
* ATR / Percent / Points Reference
* ATR Deviation
* Position
* Retracement
* Volume
* Reference Swing Range
* Major Market Table

## Scope

For market observation and user-defined technical analysis only.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF Major Structure Dynamics", shorttitle="Major Swing", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
majorLen  = input.int(25, "Major Swing Pivot Length", minval=1)
highColor = input.color(color.new(color.red, 0),  "Major Swing High Color")
lowColor  = input.color(color.new(color.teal, 0), "Major Swing Low Color")
labelSize = input.string("tiny", "Text Size", options=["tiny", "small", "normal", "large"])

showHigh = input.bool(true, "Show High + Line")
showLow  = input.bool(true, "Show Low + Line")

lineWidth = input.int(3, "Line Width", minval=1, maxval=5)
extendLen = input.int(3, "Line Length (bars)", minval=1)

zoneMode   = input.string("ATR", "Dedup Mode", options=["ATR", "Percent", "Points"])
zoneATR    = input.float(0.3, "Same-Zone ATR Multiplier", minval=0.0, step=0.1)
zonePct    = input.float(0.03, "Same-Zone Percent (%)", minval=0.0, step=0.01)
zonePoints = input.float(1.0, "Same-Zone Points", minval=0.0, step=0.5)
atrLen     = input.int(14, "ATR Length", minval=1)

rangeLookback = input.int(10, "Position Lookback Swings", minval=2, maxval=50)
showATRDist   = input.bool(true, "Show ATR Deviation")
showRelPos    = input.bool(true, "Show Position")
showRetrace   = input.bool(true, "Show Retrace")
showVol       = input.bool(true, "Show Volume (K)")

showMarketTable = input.bool(true, "Show Market Table", group="Market")
marketRefLen    = input.int(50, "Reference Swings", minval=4, maxval=50, group="Market")

f_size(string s) =>
    string result = s
    switch result
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        => size.large

// ═══════════════════════════ UDT DEFINITIONS ═══════════════════════════
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
    float  peakAfterBreak

// ═══════════════════════════ PIVOT DETECTION ═══════════════════════════
majorHighPt = ta.pivothigh(high, majorLen, majorLen)
majorLowPt  = ta.pivotlow(low, majorLen, majorLen)

atrVal = ta.atr(atrLen)
zone = zoneMode == "ATR" ? atrVal * zoneATR : zoneMode == "Percent" ? close * zonePct / 100 : zonePoints

// ═══════════════════════════ STATE VARIABLES ═══════════════════════════
var float prevMajorHY = na
var float prevMajorLY = na

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

// ═══════════════════════════ MARKET TABLE: 8 STAGES ═══════════════════════════
f_market(int dir) =>
    string initTxt = "—"
    float  restoreVal = 0.0
    float  takeoverVal = 0.0
    float  concVal = 0.0
    int    overloadVal = 0
    float  releaseVal = 0.0
    float  replenishVal = 0.0
    float  withdrawVal = 0.0

    float hi = na
    float lo = na
    int nH = math.min(marketRefLen, array.size(highRecords))
    int nL = math.min(marketRefLen, array.size(lowRecords))
    if nH > 0
        for i = 0 to nH - 1
            SwingRecord r = array.get(highRecords, array.size(highRecords) - 1 - i)
            hi := na(hi) ? r.y : math.max(hi, r.y)
            lo := na(lo) ? r.y : math.min(lo, r.y)
    if nL > 0
        for i = 0 to nL - 1
            SwingRecord r = array.get(lowRecords, array.size(lowRecords) - 1 - i)
            hi := na(hi) ? r.y : math.max(hi, r.y)
            lo := na(lo) ? r.y : math.min(lo, r.y)

    float rng = not na(hi) and not na(lo) ? hi - lo : 0.0
    float rngSafe = rng > 0 ? rng : 0.0001

    SwingRecord cur = na
    if dir == 1 and array.size(highRecords) > 0
        cur := array.get(highRecords, array.size(highRecords) - 1)
    if dir == -1 and array.size(lowRecords) > 0
        cur := array.get(lowRecords, array.size(lowRecords) - 1)

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
        // ① Restart
        int nHref = math.min(marketRefLen, array.size(highRecords))
        int nLref = math.min(marketRefLen, array.size(lowRecords))
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

        // ② Restoring Force
        if not na(prevOpp) and cur.atrAtBar > 0
            restoreVal := dir == 1 ? (cur.y - prevOpp.y) / cur.atrAtBar : (prevOpp.y - cur.y) / cur.atrAtBar

        // ③ Takeover Force
        array<SwingRecord> sameArr = dir == 1 ? highRecords : lowRecords
        if array.size(sameArr) >= 2 and atrVal > 0
            SwingRecord a = array.get(sameArr, array.size(sameArr) - 2)
            SwingRecord b = array.get(sameArr, array.size(sameArr) - 1)
            int dx = b.x - a.x
            if dx > 0
                takeoverVal := math.abs(b.y - a.y) / dx / atrVal

        // ④ Concentration Force
        concVal := (cur.y - lo) / rngSafe * 100

        // ⑤ Market Overload
        overloadVal := cur.touches

        // ⑥ Pressure Release (uses peakAfterBreak)
        if cur.broken and not na(cur.peakAfterBreak) and cur.atrAtBar > 0
            float reached = dir == 1 ? (cur.peakAfterBreak - cur.y) : (cur.y - cur.peakAfterBreak)
            releaseVal := reached / cur.atrAtBar

        // ⑦ Liquidity Replenishment
        if cur.broken and cur.returned
            float backDist = dir == 1 ? (cur.y - close) : (close - cur.y)
            replenishVal := backDist / rngSafe * 100

        // ⑧ Liquidity Withdrawal
        if cur.broken
            float outside = dir == 1 ? (close - cur.y) : (cur.y - close)
            withdrawVal := outside > 0 ? outside / rngSafe * 100 : 0.0

    [initTxt, restoreVal, takeoverVal, concVal, overloadVal, releaseVal, replenishVal, withdrawVal]

// ═══════════════════════════ MAJOR HIGH ═══════════════════════════
if not na(majorHighPt)
    px = bar_index - majorLen
    py = majorHighPt
    float v = volume[majorLen]
    notDup = na(prevMajorHY) or math.abs(py - prevMajorHY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Major Swing High", py, atrVal, 1)

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
                                          0, px, px, false, false, 0, na)
        array.push(highRecords, rec)
        fifoHigh()
        prevMajorHY := py

// ═══════════════════════════ MAJOR LOW ═══════════════════════════
if not na(majorLowPt)
    px = bar_index - majorLen
    py = majorLowPt
    float v = volume[majorLen]
    notDup = na(prevMajorLY) or math.abs(py - prevMajorLY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Major Swing Low", py, atrVal, -1)

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
                                          0, px, px, false, false, 0, na)
        array.push(lowRecords, rec)
        fifoLow()
        prevMajorLY := py

// ═══════════════════════════ LIFECYCLE TRACKING ═══════════════════════════
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
                r.peakAfterBreak := high
        else
            if na(r.peakAfterBreak) or high > r.peakAfterBreak
                r.peakAfterBreak := high
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
                r.peakAfterBreak := low
        else
            if na(r.peakAfterBreak) or low < r.peakAfterBreak
                r.peakAfterBreak := low
            if not r.returned and close > r.y
                r.returned := true

// ═══════════════════════════ MARKET TABLE ═══════════════════════════
if showMarketTable
    [hRst, hRf, hTf, hCf, hOv, hPr, hLr, hLw] = f_market(1)
    [lRst, lRf, lTf, lCf, lOv, lPr, lLr, lLw] = f_market(-1)

    var table mktTbl = table.new(position.top_right, 8, 3,
                                 bgcolor = color.rgb(25, 25, 30),
                                 border_color = color.rgb(70, 70, 80),
                                 border_width = 1,
                                 frame_width = 1)

    table.cell(mktTbl, 0, 0, "① Restart",        text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 1, 0, "② Restoring",      text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 2, 0, "③ Takeover",       text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 3, 0, "④ Concentration",  text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 4, 0, "⑤ Overload",       text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 5, 0, "⑥ Pressure",       text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 6, 0, "⑦ Replenish",      text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(mktTbl, 7, 0, "⑧ Withdrawal",     text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))

    color hBg = color.rgb(60, 30, 30)
    table.cell(mktTbl, 0, 1, "H " + hRst,                               text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 1, 1, "H " + str.tostring(hRf, "#.##") + " ATR", text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 2, 1, "H " + str.tostring(hTf, "#.##") + " ATR", text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 3, 1, "H " + str.tostring(hCf, "#.#") + "%",     text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 4, 1, "H " + str.tostring(hOv),                   text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 5, 1, "H " + str.tostring(hPr, "#.##") + " ATR", text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 6, 1, "H " + str.tostring(hLr, "#.#") + "%",     text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(mktTbl, 7, 1, "H " + str.tostring(hLw, "#.#") + "%",     text_color = highColor, text_size = size.tiny, bgcolor = hBg)

    color lBg = color.rgb(30, 60, 60)
    table.cell(mktTbl, 0, 2, "L " + lRst,                               text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 1, 2, "L " + str.tostring(lRf, "#.##") + " ATR", text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 2, 2, "L " + str.tostring(lTf, "#.##") + " ATR", text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 3, 2, "L " + str.tostring(lCf, "#.#") + "%",     text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 4, 2, "L " + str.tostring(lOv),                   text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 5, 2, "L " + str.tostring(lPr, "#.##") + " ATR", text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 6, 2, "L " + str.tostring(lLr, "#.#") + "%",     text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(mktTbl, 7, 2, "L " + str.tostring(lLw, "#.#") + "%",     text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
````

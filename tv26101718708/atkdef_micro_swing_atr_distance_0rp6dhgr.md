# ATK/DEF Micro Swing ATR Distance 

- url: https://www.tradingview.com/script/0rp6dhGR/
- type: indicator
- pine_id: PUB;813902c3c4584cfc8bbae8154fa67763
- version: 1.0

## Description

ATK/DEF Micro Swing  ATR Distance is a market structure analysis framework built around Micro Swing High / Low.

Micro Swing identifies smaller-scale swing structures and provides a way to observe market reactions when price structure changes.

## Micro Swing Structure

Micro Swing High and Micro Swing Low are generated from the configurable swing length.

The detected swing points provide localized structural references for observing:

* Micro Swing High
* Micro Swing Low
* Structure position
* Price reaction
* Retracement
* Structural interaction

The framework focuses on the behavior of smaller swing structures within the current chart environment.

## ATR / Position / Retracement

Each Micro Swing can be analyzed through three primary components:

**ATR + Position + Retracement**

### ATR

ATR provides the volatility reference used for measuring the relative distance of the Micro Swing structure.

### Position

Position measures the location of the current Micro Swing relative to the defined historical swing range.

### Retracement

Retracement measures the distance between the current Micro Swing and the corresponding opposite swing reference using ATR.

These components provide quantitative references for examining the current Micro Swing structure.

## Micro Swing Lifecycle Table

The right-side table organizes the current High and Low structures through four defined measurements:

| Component      | Description                      |
| -------------- | -------------------------------- |
| **Position**   | Structure Deviation              |
| **Formation**  | Vortex Flow Reaction             |
| **Endurance**  | Endurance Ratio                  |
| **Reflection** | True / False Pressure Reflection |

### Position — Structure Deviation

Measures the current Micro Swing position relative to the reference swing range.

### Formation — Vortex Flow Reaction

Measures the price reaction associated with the bar where the current Micro Swing was formed.

### Endurance — Endurance Ratio

Tracks the relationship between structural touches and the number of bars since the Micro Swing was formed.

### Reflection — True / False Pressure Reflection

Tracks the structural relationship after a Micro Swing level is broken and subsequently revisited.

The table presents these measurements separately for **Micro Swing High** and **Micro Swing Low**.

## Display

Configurable components include:

* Micro Swing Length
* High / Low Display
* High / Low Colors
* ATR Length
* Deduplication Mode
* ATR / Percent / Points Reference
* ATR Distance
* Relative Position
* Retracement
* Formation Volume
* Lifecycle Table
* Reference Swing Range
* Maximum Retained Swing Records

## Structure Flow

**Micro Swing → ATR / Position / Retracement → Structural Interaction → Lifecycle Observation**

The framework organizes Micro Swing structure and its related measurements into a visual market-analysis structure.

## Scope

**For market observation and user-defined technical analysis only.**

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ATK/DEF Micro Swing ATR Distance ", shorttitle="Micro Swing ATR", overlay=true, max_labels_count=500, max_lines_count=500)

// ═══════════════════════════ INPUTS ═══════════════════════════
swingLen  = input.int(1, "Micro Swing Pivot Length", minval=1)
highColor = input.color(color.new(color.fuchsia, 0), "Micro Swing High Color")
lowColor  = input.color(color.new(color.lime, 0), "Micro Swing Low Color")
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
microHighPt = ta.pivothigh(high, swingLen, swingLen)
microLowPt  = ta.pivotlow(low, swingLen, swingLen)

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

// ═══════════════════════════ LIFECYCLE: 4-STAGE CALC ═══════════════════════════
// ① Position : time deviation = current swing vs previous opposite swing bar gap / 50-swing time span
// ② Formation: vortex flow reaction (swing bar close-open / high-low)
// ③ Endurance: touches / alive bars
// ④ Reflection: True / Semi-True / False / Not Broken
f_lifecycle(int dir) =>
    float devPct   = 0.0
    float reactPct = 0.0
    int   touches  = 0
    int   lifeX    = 0
    float endurePct = 0.0
    string reflTxt = "Not Broken"
    color  reflCol = color.new(color.gray, 0)

    // ── Time span reference: last 50 swings (H+L combined) maxX - minX ──
    int maxX = na
    int minX = na
    int nH = math.min(lifeRefLen, array.size(highRecords))
    int nL = math.min(lifeRefLen, array.size(lowRecords))
    if nH > 0
        for i = 0 to nH - 1
            SwingRecord r = array.get(highRecords, array.size(highRecords) - 1 - i)
            maxX := na(maxX) ? r.x : math.max(maxX, r.x)
            minX := na(minX) ? r.x : math.min(minX, r.x)
    if nL > 0
        for i = 0 to nL - 1
            SwingRecord r = array.get(lowRecords, array.size(lowRecords) - 1 - i)
            maxX := na(maxX) ? r.x : math.max(maxX, r.x)
            minX := na(minX) ? r.x : math.min(minX, r.x)

    float spanX = not na(maxX) and not na(minX) ? maxX - minX : 0
    float spanSafe = spanX > 0 ? spanX : 1

    // ── Current swing ──
    SwingRecord cur = na
    if dir == 1 and array.size(highRecords) > 0
        cur := array.get(highRecords, array.size(highRecords) - 1)
    if dir == -1 and array.size(lowRecords) > 0
        cur := array.get(lowRecords, array.size(lowRecords) - 1)

    // ── Previous opposite swing ──
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
        // ① Position: time deviation
        if not na(prevOpp)
            devPct := (cur.x - prevOpp.x) / spanSafe * 100

        // ② Formation: vortex flow reaction
        int offset = bar_index - cur.x
        float bOpen  = open[offset]
        float bClose = close[offset]
        float bHigh  = high[offset]
        float bLow   = low[offset]
        float rangeBar = bHigh - bLow
        reactPct := rangeBar > 0 ? (bClose - bOpen) / rangeBar * 100 : 0.0

        // ③ Endurance
        touches := cur.touches
        lifeX := bar_index - cur.birthX
        endurePct := lifeX > 0 ? touches / lifeX * 100 : 0.0

        // ④ Reflection
        if not cur.broken
            reflTxt := "Not Broken"
            reflCol := color.new(color.gray, 0)
        else if cur.returned
            float backDist = dir == 1 ? (cur.y - close) : (close - cur.y)
            float atrUse = cur.atrAtBar > 0 ? cur.atrAtBar : 0.0001
            float backAtr = backDist / atrUse
            if backAtr > 0.5
                reflTxt := "False"
                reflCol := color.new(color.lime, 0)
            else
                reflTxt := "Semi-True"
                reflCol := color.new(color.orange, 0)
        else
            reflTxt := "True"
            reflCol := color.new(color.red, 0)

    [devPct, reactPct, touches, lifeX, endurePct, reflTxt, reflCol]

// ═══════════════════════════ MICRO HIGH ═══════════════════════════
if not na(microHighPt)
    px = bar_index - swingLen
    py = microHighPt
    float v = volume[swingLen]
    notDup = na(prevMicroHY) or math.abs(py - prevMicroHY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Micro Swing High", py, atrVal, 1)

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

// ═══════════════════════════ MICRO LOW ═══════════════════════════
if not na(microLowPt)
    px = bar_index - swingLen
    py = microLowPt
    float v = volume[swingLen]
    notDup = na(prevMicroLY) or math.abs(py - prevMicroLY) >= zone

    if notDup
        string baseTxt = f_makeBaseText("Micro Swing Low", py, atrVal, -1)

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

// ═══════════════════════════ LIFECYCLE TABLE (top-right) ═══════════════════════════
if showLifeTable
    [hDev, hReact, hTch, hLife, hEnd, hReflTxt, hReflCol] = f_lifecycle(1)
    [lDev, lReact, lTch, lLife, lEnd, lReflTxt, lReflCol] = f_lifecycle(-1)

    var table lifeTbl = table.new(position.top_right, 4, 3,
                                  bgcolor = color.rgb(25, 25, 30),
                                  border_color = color.rgb(70, 70, 80),
                                  border_width = 1,
                                  frame_width = 1)

    table.cell(lifeTbl, 0, 0, "① Position\nTime Deviation", text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(lifeTbl, 1, 0, "② Formation\nVortex Flow", text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(lifeTbl, 2, 0, "③ Endurance\nEndurance Ratio", text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))
    table.cell(lifeTbl, 3, 0, "④ Reflection\nTrue/False", text_color = color.white, text_size = size.tiny, bgcolor = color.rgb(50, 50, 60))

    color hBg = color.rgb(60, 30, 60)
    table.cell(lifeTbl, 0, 1, "H " + str.tostring(hDev, "#.#") + "%",
               text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(lifeTbl, 1, 1, "H " + str.tostring(hReact, "+#.#;-#.#") + "%",
               text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(lifeTbl, 2, 1, "H " + str.tostring(hTch) + "x / " + str.tostring(hLife) + " bars = " + str.tostring(hEnd, "#.#") + "%",
               text_color = highColor, text_size = size.tiny, bgcolor = hBg)
    table.cell(lifeTbl, 3, 1, "H " + hReflTxt,
               text_color = hReflCol, text_size = size.tiny, bgcolor = hBg)

    color lBg = color.rgb(30, 60, 30)
    table.cell(lifeTbl, 0, 2, "L " + str.tostring(lDev, "#.#") + "%",
               text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(lifeTbl, 1, 2, "L " + str.tostring(lReact, "+#.#;-#.#") + "%",
               text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(lifeTbl, 2, 2, "L " + str.tostring(lTch) + "x / " + str.tostring(lLife) + " bars = " + str.tostring(lEnd, "#.#") + "%",
               text_color = lowColor, text_size = size.tiny, bgcolor = lBg)
    table.cell(lifeTbl, 3, 2, "L " + lReflTxt,
               text_color = lReflCol, text_size = size.tiny, bgcolor = lBg)
````

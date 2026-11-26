# Session Volume Profile by AUMBaumgartner

- url: https://www.tradingview.com/script/niaUzHtv/
- type: indicator
- pine_id: PUB;c7b6b2924378491087054b3ab8875a47
- version: 1.0

## Description

# Session Volume Profile – VPOC | TPOC | VAH | VAL

This indicator calculates the volume profile of a complete trading session and displays the key statistical price levels directly on the chart — based on the Market Profile principles developed by J. Peter Steidlmayer.

The volume of each session is distributed evenly across the High-Low range of each bar and accumulated into price buckets. This produces the following levels:

**VPOC – Volume Point of Control**
The price with the highest traded volume of the session. This is the fairest price, as the most trading activity occurred here.

**TPOC – Time Point of Control**
The price touched by the most bars during the session. The time-based variant of the POC.

**VAH – Value Area High**
The upper boundary of the Value Area. Above this level, price is statistically overvalued.

**VAL – Value Area Low**
The lower boundary of the Value Area. Below this level, price is statistically undervalued.

**Value Area (VA)**
The price range in which 70% of session volume was traded. Within the Value Area, price is fairly valued. The Value Area is calculated according to Steidlmayer's original method: starting from the VPOC, the next two price levels above and below are compared. The side with the higher volume is added to the Value Area. In case of a tie, the upper side is preferred. This process repeats until 70% of total volume is captured.

The horizontal histogram displays the volume distribution across all price levels of the session. The VPOC bar is highlighted and the Value Area is shown in a distinct colour.

**How to use**
Buy when price is below VAL, sell when price is above VAH — as long as the market is in balance. If price remains outside the Value Area for 30 minutes or more, a new price level is likely developing.

**Settings**
Session start and end (HHMM), Value Area percentage, Tick Multiplier for bucket granularity, volume distribution over Range or Close, histogram left or right of the session, and all colours individually customisable.

Optimised for EUREX futures (DAX, Euro Stoxx), but works on all markets and timeframes.

Based on the Market Profile theory of J. Peter Steidlmayer.

## Source Code

````pine
//@version=5
indicator(title="Session Volume Profile", shorttitle="SVP", overlay=true, max_boxes_count=500, max_lines_count=300, max_labels_count=30)

// ─────────────────────────────────────────────────────────────
//  Inputs
// ─────────────────────────────────────────────────────────────
grpSession   = "Session"
sessStart    = input.int(2200, "Session Start (HHMM)", minval=0, maxval=2359, group=grpSession, tooltip="EUREX volle Session: 2200")
sessEnd      = input.int(2200, "Session End   (HHMM)", minval=0, maxval=2359, group=grpSession, tooltip="EUREX volle Session: 2200")

grpCalc      = "Calculation"
valueAreaPct = input.int(70, "Value Area %",    minval=1,  maxval=99, group=grpCalc)
tickMult     = input.int(2,  "Tick multiplier", minval=1,  maxval=20, group=grpCalc)
volMode      = input.string("Range", "Volume distribution", options=["Range","Close"], group=grpCalc, tooltip="Range = Steidlmayer (Volumen über High-Low verteilt)\nClose = nur Schlusskurs")

grpDisplay   = "Display"
histWidth    = input.int(8,    "Histogram max width (bars)", minval=1, maxval=50, group=grpDisplay)
showHist     = input.bool(true, "Show histogram",            group=grpDisplay)
showLines    = input.bool(true, "Show POC/VAH/VAL lines",    group=grpDisplay)
showLabels   = input.bool(true, "Show labels",               group=grpDisplay)
histSide     = input.string("Left", "Histogram side", options=["Left","Right"], group=grpDisplay)

grpColors    = "Colors"
pocColor     = input.color(color.new(color.red,    0),  "VPOC",       group=grpColors)
tpocColor    = input.color(color.new(color.orange, 0),  "TPOC",       group=grpColors)
vahColor     = input.color(color.new(color.blue,   0),  "VAH",        group=grpColors)
valColor     = input.color(color.new(color.blue,   0),  "VAL",        group=grpColors)
histColor    = input.color(color.new(color.orange, 50), "Histogram",  group=grpColors)
vaColor      = input.color(color.new(color.blue,   70), "Value Area", group=grpColors)

// ─────────────────────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────────────────────
MAX_LEVELS = 400

var float[] lvlPrice = array.new_float(MAX_LEVELS, 0.0)
var int[]   lvlVol   = array.new_int(MAX_LEVELS, 0)
var int[]   lvlCount = array.new_int(1, 0)
var float[] lvlStep  = array.new_float(1, 0.0)
var int[]   cumVol   = array.new_int(1, 0)
var int[]   tpoCount = array.new_int(MAX_LEVELS, 0)

var int  sessFirst = -1
var int  sessLast  = -1
var bool wasInSess = false

// ─────────────────────────────────────────────────────────────
//  Session-Erkennung
// ─────────────────────────────────────────────────────────────
barHHMM = hour(time, syminfo.timezone) * 100 + minute(time, syminfo.timezone)

bool isInSess = false
if sessStart == sessEnd
    isInSess := true
else if sessStart < sessEnd
    isInSess := barHHMM >= sessStart and barHHMM < sessEnd
else
    isInSess := barHHMM >= sessStart or barHHMM < sessEnd

isSessionBoundary = (sessStart == sessEnd) ? (barHHMM == sessStart and hour(time[1], syminfo.timezone) * 100 + minute(time[1], syminfo.timezone) != sessStart) : false
sessionOpens  = isSessionBoundary or (isInSess and not wasInSess)
sessionCloses = not isSessionBoundary and not isInSess and wasInSess

// ─────────────────────────────────────────────────────────────
//  Profile Helpers
// ─────────────────────────────────────────────────────────────
resetProfile() =>
    array.fill(lvlVol,   0)
    array.fill(lvlPrice, 0.0)
    array.fill(tpoCount, 0)
    array.set(lvlCount, 0, 0)
    array.set(lvlStep,  0, 0.0)
    array.set(cumVol,   0, 0)

getBucket(float price) =>
    int   cnt  = array.get(lvlCount, 0)
    float step = array.get(lvlStep,  0)
    int   idx  = 0
    if cnt == 0
        array.set(lvlPrice, 0, price)
        array.set(lvlVol,   0, 0)
        array.set(lvlStep,  0, syminfo.mintick * tickMult)
        array.set(lvlCount, 0, 1)
        idx := 0
    else
        float base = array.get(lvlPrice, 0)
        int   raw  = int(math.floor((price - base) / step))
        if raw < 0
            int needed = math.min(math.abs(raw), MAX_LEVELS - cnt)
            if needed > 0
                for k = 0 to cnt - 1
                    int src = (cnt - 1) - k
                    int dst = src + needed
                    if dst < MAX_LEVELS
                        array.set(lvlPrice,  dst, array.get(lvlPrice, src))
                        array.set(lvlVol,    dst, array.get(lvlVol,   src))
                        array.set(tpoCount,  dst, array.get(tpoCount, src))
                for k = 0 to needed - 1
                    array.set(lvlPrice,  k, array.get(lvlPrice, needed) - (needed - k) * step)
                    array.set(lvlVol,    k, 0)
                    array.set(tpoCount,  k, 0)
                array.set(lvlCount, 0, math.min(cnt + needed, MAX_LEVELS))
            raw := 0
        int cnt2 = array.get(lvlCount, 0)
        if raw >= cnt2
            int needed = math.min(raw - cnt2 + 1, MAX_LEVELS - cnt2)
            if needed > 0
                for k = 0 to needed - 1
                    int   pos  = cnt2 + k
                    float newP = array.get(lvlPrice, cnt2 - 1) + (k + 1) * step
                    if pos < MAX_LEVELS
                        array.set(lvlPrice,  pos, newP)
                        array.set(lvlVol,    pos, 0)
                        array.set(tpoCount,  pos, 0)
                array.set(lvlCount, 0, math.min(cnt2 + needed, MAX_LEVELS))
        int cnt3 = array.get(lvlCount, 0)
        idx := math.max(0, math.min(raw, cnt3 - 1))
    idx

addToOneBucket(float price, int vol) =>
    int idx = getBucket(price)
    int cnt = array.get(lvlCount, 0)
    if idx >= 0 and idx < cnt
        array.set(lvlVol,   idx, array.get(lvlVol,   idx) + vol)
        array.set(tpoCount, idx, array.get(tpoCount, idx) + 1)
        array.set(cumVol,   0,   array.get(cumVol,   0)   + vol)

addVolumeRange(float barHigh, float barLow, int vol) =>
    int idxLo = getBucket(barLow)
    int idxHi = getBucket(barHigh)
    int cnt   = array.get(lvlCount, 0)
    idxLo     := math.max(0, math.min(idxLo, cnt - 1))
    idxHi     := math.max(0, math.min(idxHi, cnt - 1))
    int nBuck  = idxHi - idxLo + 1
    int volPer = int(math.floor(float(vol) / float(nBuck)))
    int rest   = vol - volPer * nBuck
    for k = idxLo to idxHi
        int v = volPer + (k == idxHi ? rest : 0)
        array.set(lvlVol,   k, array.get(lvlVol,   k) + v)
        array.set(tpoCount, k, array.get(tpoCount, k) + 1)
    array.set(cumVol, 0, array.get(cumVol, 0) + vol)

calcLevels() =>
    float poc     = na
    float tpoc    = na
    float vah     = na
    float val     = na
    int   pocIdx  = 0
    int   tpocIdx = 0
    int   loIdx   = 0
    int   hiIdx   = 0
    int   cnt     = array.get(lvlCount, 0)
    int   tot     = array.get(cumVol,   0)
    float stp     = array.get(lvlStep,  0)
    if cnt > 0 and tot > 0
        int pocV  = 0
        int tpocV = 0
        for k = 0 to cnt - 1
            int v = array.get(lvlVol, k)
            if v > pocV
                pocV   := v
                pocIdx := k
            int t = array.get(tpoCount, k)
            if t > tpocV
                tpocV   := t
                tpocIdx := k
        poc  := array.get(lvlPrice, pocIdx)  + stp * 0.5
        tpoc := array.get(lvlPrice, tpocIdx) + stp * 0.5

        // Value Area nach Originalwerk: 2-Bucket Vergleich, höherer Umsatz gewinnt
        // Bei Gleichstand: oben bevorzugen (VAH-first)
        int target = int(math.ceil(tot * valueAreaPct / 100.0))
        int accVol = pocV
        int lo     = pocIdx
        int hi     = pocIdx
        while accVol < target
            if lo == 0 and hi == cnt - 1
                break
            else if lo == 0
                hi     += 1
                accVol += array.get(lvlVol, hi)
            else if hi == cnt - 1
                lo     -= 1
                accVol += array.get(lvlVol, lo)
            else
                int hiV1  = hi + 1 < cnt ? array.get(lvlVol, hi + 1) : 0
                int hiV2  = hi + 2 < cnt ? array.get(lvlVol, hi + 2) : 0
                int sumHi = hiV1 + hiV2
                int loV1  = lo - 1 >= 0  ? array.get(lvlVol, lo - 1) : 0
                int loV2  = lo - 2 >= 0  ? array.get(lvlVol, lo - 2) : 0
                int sumLo = loV1 + loV2
                if sumHi >= sumLo
                    hi     += 1
                    accVol += array.get(lvlVol, hi)
                else
                    lo     -= 1
                    accVol += array.get(lvlVol, lo)
        loIdx := lo
        hiIdx := hi
        val   := array.get(lvlPrice, lo) + stp * 0.5
        vah   := array.get(lvlPrice, hi) + stp * 0.5
    [poc, tpoc, vah, val, pocIdx, tpocIdx, loIdx, hiIdx]

// ─────────────────────────────────────────────────────────────
//  Draw – exakt einmal pro abgeschlossener Session
// ─────────────────────────────────────────────────────────────
drawSession(int xFrom, int xTo, int pocI, int tpocI, int loI, int hiI, float poc, float tpoc, float vah, float val) =>
    int   cnt  = array.get(lvlCount, 0)
    float stp  = array.get(lvlStep,  0)
    if cnt > 0 and not na(poc) and xFrom >= 0 and xTo >= xFrom
        int maxV = 1
        for k = 0 to cnt - 1
            int v = array.get(lvlVol, k)
            if v > maxV
                maxV := v
        if showHist
            for k = 0 to cnt - 1
                int   vol    = array.get(lvlVol,   k)
                float pLow   = array.get(lvlPrice, k)
                float pHigh  = pLow + stp
                int   barW   = math.max(int(math.round(float(vol) / float(maxV) * histWidth)), 1)
                bool  inVA   = k >= loI and k <= hiI
                bool  isPoc  = k == pocI
                bool  isTpoc = k == tpocI
                color fill   = isPoc ? color.new(pocColor, 20) : isTpoc ? color.new(tpocColor, 20) : inVA ? vaColor : histColor
                color brd    = isPoc ? pocColor : isTpoc ? tpocColor : inVA ? vahColor : color.new(histColor, 30)
                int   bLeft  = histSide == "Left" ? xFrom - barW : xTo
                int   bRight = histSide == "Left" ? xFrom        : xTo + barW
                box.new(left=bLeft, top=pHigh, right=bRight, bottom=pLow, bgcolor=fill, border_color=brd, border_width=isPoc ? 2 : 1, xloc=xloc.bar_index)
        if showLines
            line.new(x1=xFrom, y1=poc,  x2=xTo, y2=poc,  color=pocColor,  width=2, style=line.style_solid,  xloc=xloc.bar_index)
            line.new(x1=xFrom, y1=tpoc, x2=xTo, y2=tpoc, color=tpocColor, width=2, style=line.style_dashed, xloc=xloc.bar_index)
            line.new(x1=xFrom, y1=vah,  x2=xTo, y2=vah,  color=vahColor,  width=1, style=line.style_dotted, xloc=xloc.bar_index)
            line.new(x1=xFrom, y1=val,  x2=xTo, y2=val,  color=valColor,  width=1, style=line.style_dotted, xloc=xloc.bar_index)
        if showLabels
            int    lx = histSide == "Left" ? xFrom - histWidth - 2 : xTo + histWidth + 2
            string ls = histSide == "Left" ? label.style_label_right : label.style_label_left
            label.new(lx, poc,  "VPOC " + str.tostring(poc,  format.mintick), color=pocColor,  textcolor=color.white, style=ls, size=size.small, xloc=xloc.bar_index)
            label.new(lx, tpoc, "TPOC " + str.tostring(tpoc, format.mintick), color=tpocColor, textcolor=color.white, style=ls, size=size.small, xloc=xloc.bar_index)
            label.new(lx, vah,  "VAH "  + str.tostring(vah,  format.mintick), color=vahColor,  textcolor=color.white, style=ls, size=size.small, xloc=xloc.bar_index)
            label.new(lx, val,  "VAL "  + str.tostring(val,  format.mintick), color=valColor,  textcolor=color.white, style=ls, size=size.small, xloc=xloc.bar_index)

// ─────────────────────────────────────────────────────────────
//  Per-bar Logik
// ─────────────────────────────────────────────────────────────
if sessionOpens
    if sessFirst >= 0 and sessLast >= sessFirst and array.get(cumVol, 0) > 0
        [p, tp, h, l, pi, tpi, li, hi_] = calcLevels()
        if not na(p)
            drawSession(sessFirst, sessLast, pi, tpi, li, hi_, p, tp, h, l)
    resetProfile()
    sessFirst := bar_index
    sessLast  := bar_index

if isInSess
    if volMode == "Range"
        addVolumeRange(high, low, int(volume))
    else
        addToOneBucket(close, int(volume))
    sessLast := bar_index

if sessionCloses
    if sessFirst >= 0 and sessLast >= sessFirst and array.get(cumVol, 0) > 0
        [p, tp, h, l, pi, tpi, li, hi_] = calcLevels()
        if not na(p)
            drawSession(sessFirst, sessLast, pi, tpi, li, hi_, p, tp, h, l)

wasInSess := isInSess

if barstate.islast and isInSess
    if sessFirst >= 0 and sessLast >= sessFirst and array.get(cumVol, 0) > 0
        [p, tp, h, l, pi, tpi, li, hi_] = calcLevels()
        if not na(p)
            drawSession(sessFirst, sessLast, pi, tpi, li, hi_, p, tp, h, l)
````

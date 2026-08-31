<!-- tradingview-pine-id: PUB;f2a2bc92a2c74c8a98df5a40ab847a5f -->
<!-- tradingviewscripts-format: 1 -->
# HERMES Zarb Setup

Source: https://www.tradingview.com/script/MGQ7yKJe-HERMES-Zarb-Setup/

## Description

Pivot Points and FVG and IFVG .....Using volume profile to point out Value area high and low , point of control and previous day point of control and other pivot points

---

## Source Code

````pine
//@version=6
// ============================================================================
// HERMES Zarb Setup — Session Volume Profile + Prior-Day Levels + FVG/IFVG
// v2.3 — Aug 3 2026 (Session 52). ROW-MODEL FIX: POC/VAH/VAL now computed the
//        SAME way TradingView's Session Volume Profile does — session range split
//        into a fixed NUMBER OF ROWS (input "Number of rows", default 24), POC =
//        busiest row, value area expands row-by-row. Fixes the misplaced PD
//        POC/VAH/VAL lines (old code picked the single busiest 2-pt bucket = a
//        finer, different price than TV's coarser rows). Set "Number of rows" =
//        your native SVP Row Size to overlay tick-for-tick. Live slot: the
//        "HERMES Zarb Lab set up" script (id b8a53...), which drives the on-chart
//        "HERMES Zarb Setup" study (verified Aug 3 via live labels).
// v2.2 — Jul 31 2026. POC FIX: reads REAL 1-min volume-at-price via
//        request.security_lower_tf instead of smearing each bar's volume evenly
//        across its full H-L range -> POC/PDPOC now match Zarb's native profile
//        (closes the ~80-point gap). Precision input = "Volume precision (LTF)".
// v2 — Jul 29 2026 (Session 48). Rebuilt from Zach Anthony's (@iamzarb / PFM)
// method after studying his "Volume Profile settings" + "$100K payouts" videos.
//
// What Zarb explained on video:
//   • SESSION Volume Profile is the core ("95% of my read"). Sessions = "all",
//     so every session builds its own profile.
//   • Value Area = 68% ("the standard is 68 or 70, I use 68").
//   • Reads POC / VAH / VAL; keeps a PRIOR-SESSION profile (PD POC/VAH/VAL) as
//     the intraday magnets. Bias = long above PD POC / short below.
//   • Flips timeframe 1h (bias) -> 15m (structure) -> 1m (entry via IFVG),
//     inside ICT killzones, targeting the Draw On Liquidity.
//
// Draws: developing session volume profile (histogram + POC), prior-session
// POC/VAH/VAL + PDH/PDL as FLAT per-session line segments, and FVG -> IFVG
// zones that can disappear once filled. Every element is colour + tint tunable.
//
// v2 CHANGES vs v1:
//   [FIX] labels no longer duplicate (persistent var labels, updated not recreated)
//   [FIX] prior-session levels drawn as FLAT per-session line segments (no more
//         diagonal-connect / drifting across days)
//   [NEW] volume spread across each bar's high-low range -> POC lands ~native SVP
//   [NEW] Session Volume Profile master on/off + developing histogram
//   [NEW] Value Area default 0.68 (Zarb)
//   [NEW] FVG and IFVG can DISAPPEAR once filled
//   [NEW] colour + tint (transparency) sliders for every drawn element
// ============================================================================
indicator("HERMES Zarb Setup", shorttitle="HRM Zarb", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=100)

// ============================== INPUTS ======================================
// ---- Session Volume Profile ----
gV = "Session Volume Profile"
showSVP   = input.bool(true,  "Enable Session Volume Profile", group=gV,
     tooltip="Master switch. Builds the per-session profile that sets POC/VAH/VAL and the prior-session levels.")
showHisto = input.bool(true,  "Draw developing profile histogram", group=gV)
showDev   = input.bool(true,  "Developing POC (this session)", group=gV)
vaPct     = input.float(0.68, "Value Area fraction", minval=0.50, maxval=0.90, step=0.01, group=gV,
     tooltip="Zarb uses 0.68 (one standard deviation). TradingView default is 0.70.")
nRows     = input.int(24, "Number of rows (match your SVP Row Size)", minval=6, maxval=200, group=gV,
     tooltip="TradingView's Session Volume Profile default = 24 rows per session. Set this EQUAL to your native SVP 'Number Of Rows' so POC/VAH/VAL land in the same place. This is the setting that fixes the misplaced lines.")
binPts    = input.float(2.0,  "Profile bin size (points)", minval=0.25, step=0.25, group=gV,
     tooltip="MNQ tick = 0.25. 2.0 pts = 8 ticks per row. Smaller = finer & heavier.")
histoBars = input.int(60,  "Histogram max width (bars)", minval=10, maxval=200, group=gV)
histoRows = input.int(150, "Histogram max rows",        minval=20, maxval=300, group=gV)
ltfRes    = input.timeframe("1", "Volume precision (lower timeframe)", group=gV,
     tooltip="Reads REAL volume-at-price from this lower timeframe instead of guessing. 1 = 1-minute (matches Zarb's native SVP). Lower = more accurate POC but heavier.")

// ---- Prior-Session levels ----
gL = "Prior-Session Levels"
showPD   = input.bool(true, "Prior-session POC / VAH / VAL", group=gL)
showPDHL = input.bool(true, "Prior-session High / Low (PDH/PDL)", group=gL)
showMid  = input.bool(true, "Midnight Open (00:00 New York)", group=gL)
showLbls = input.bool(true, "Price labels on levels", group=gL)

// ---- Fair Value Gaps ----
gF = "Fair Value Gaps"
showFVG    = input.bool(true, "Show FVG", group=gF)
flipIFVG   = input.bool(true, "Flip FVG -> IFVG when mitigated", group=gF,
     tooltip="ON: a filled FVG inverts into an IFVG. OFF: a filled FVG simply disappears.")
removeIFVG = input.bool(true, "Remove IFVG once filled", group=gF,
     tooltip="When the inverted IFVG is itself filled, delete it from the chart.")
keepN      = input.int(10, "Max FVG boxes kept per side", minval=1, maxval=50, group=gF)
extendN    = input.int(15, "Extend boxes (bars)", minval=0, maxval=200, group=gF)

// ---- Colours & Tint ----  (colour = hue, tint = 0 solid .. 100 invisible)
gC = "Colours & Tint"
cBull = input.color(color.teal,   "Bullish FVG", group=gC, inline="b")
tBull = input.int(82, "tint", minval=0, maxval=100, group=gC, inline="b")
cBear = input.color(color.red,    "Bearish FVG", group=gC, inline="r")
tBear = input.int(82, "tint", minval=0, maxval=100, group=gC, inline="r")
cIFVG = input.color(color.orange, "IFVG",        group=gC, inline="i")
tIFVG = input.int(74, "tint", minval=0, maxval=100, group=gC, inline="i")
cPOCd = input.color(color.orange, "Developing POC", group=gC, inline="pd")
tPOCd = input.int(0,  "tint", minval=0, maxval=100, group=gC, inline="pd")
cPOC  = input.color(color.red,    "Prior POC",    group=gC, inline="pp")
tPOC  = input.int(0,  "tint", minval=0, maxval=100, group=gC, inline="pp")
cVA   = input.color(color.gray,   "Prior VAH/VAL", group=gC, inline="va")
tVA   = input.int(20, "tint", minval=0, maxval=100, group=gC, inline="va")
cHL   = input.color(color.blue,   "Prior High/Low", group=gC, inline="hl")
tHL   = input.int(20, "tint", minval=0, maxval=100, group=gC, inline="hl")
cMid  = input.color(color.white,  "Midnight Open", group=gC, inline="mo")
tMid  = input.int(0, "tint", minval=0, maxval=100, group=gC, inline="mo")
cHist = input.color(color.blue,   "Histogram",    group=gC, inline="h")
tHist = input.int(80, "tint", minval=0, maxval=100, group=gC, inline="h")

// resolved colours
colBull = color.new(cBull, tBull)
colBear = color.new(cBear, tBear)
colIFVG = color.new(cIFVG, tIFVG)
colPOCd = color.new(cPOCd, tPOCd)
colPOC  = color.new(cPOC,  tPOC)
colVA   = color.new(cVA,   tVA)
colHL   = color.new(cHL,   tHL)
colMid  = color.new(cMid,  tMid)
colHist = color.new(cHist, tHist)

// ============================ SESSION ROLL ==================================
// For CME futures (MNQ/MES) the daily bar rolls at the session open, so a
// change in time("D") == a new session. This is Zarb's "sessions on all".
isNewDay = ta.change(time("D")) != 0

// ==================== VOLUME PROFILE (per-session map) ======================
var map<int, float> vp = map.new<int, float>()
binOf(p)   => int(math.round(p / binPts))
priceOf(b) => b * binPts

// bin a volume _v across the price range [_lo,_hi] into map m.
// used to distribute each lower-timeframe intrabar's REAL volume at its price.
f_binVol(map<int, float> m, float _lo, float _hi, float _v) =>
    lb = binOf(_lo)
    hb = binOf(_hi)
    int nb = math.max(hb - lb + 1, 1)
    if nb > 400
        key = binOf((_lo + _hi) / 2)
        prevK = map.contains(m, key) ? map.get(m, key) : 0.0
        map.put(m, key, prevK + _v)
    else
        vPer = _v / nb
        for bb = lb to hb
            prevB = map.contains(m, bb) ? map.get(m, bb) : 0.0
            map.put(m, bb, prevB + vPer)
    0

var float dH = na
var float dL = na

var float pdPOC = na
var float pdVAH = na
var float pdVAL = na
var float pdH   = na
var float pdL   = na

// compute [POC, VAH, VAL] the SAME way TradingView's Session Volume Profile does:
// divide the session range into `rows` equal-height rows, sum volume per row,
// POC = center of the busiest row, then expand the value area row-by-row (adding
// the heavier neighbour) until it holds `vaFrac` of total volume. VAH/VAL are the
// OUTER EDGES of the value-area rows (TV's convention), not bin centers.
f_profile(map<int, float> m, int rows, float vaFrac) =>
    keys = map.keys(m)
    int n = array.size(keys)
    float pocPrice = na
    float vah = na
    float val = na
    if n > 0
        array.sort(keys, order.ascending)
        float pLo  = priceOf(array.get(keys, 0))
        float pHi  = priceOf(array.get(keys, n - 1))
        float span = pHi - pLo
        int   R    = span > 0 ? rows : 1
        float rowH = span > 0 ? span / R : syminfo.mintick
        // bucket the fine price->volume map into R equal rows
        rv = array.new_float(R, 0.0)
        float total = 0.0
        for i = 0 to n - 1
            k = array.get(keys, i)
            v = map.get(m, k)
            total += v
            int ri = span > 0 ? int(math.floor((priceOf(k) - pLo) / rowH)) : 0
            ri := math.min(math.max(ri, 0), R - 1)
            array.set(rv, ri, array.get(rv, ri) + v)
        // POC = busiest row
        int   pocRow = 0
        float pocVol = -1.0
        for r = 0 to R - 1
            if array.get(rv, r) > pocVol
                pocVol := array.get(rv, r)
                pocRow := r
        pocPrice := pLo + (pocRow + 0.5) * rowH
        // expand value area from the POC row outward, taking the heavier side
        float acc = pocVol
        int lo = pocRow
        int hi = pocRow
        float target = total * vaFrac
        while acc < target and (lo > 0 or hi < R - 1)
            float vLo = lo > 0     ? array.get(rv, lo - 1) : -1.0
            float vHi = hi < R - 1 ? array.get(rv, hi + 1) : -1.0
            if vHi >= vLo
                hi += 1
                acc += math.max(vHi, 0)
            else
                lo -= 1
                acc += math.max(vLo, 0)
        vah := pLo + (hi + 1) * rowH
        val := pLo + lo * rowH
    [pocPrice, vah, val]

// on a fresh session: snapshot the completed session, then reset
if isNewDay
    [p, a, b] = f_profile(vp, nRows, vaPct)
    if not na(p)
        pdPOC := p
        pdVAH := a
        pdVAL := b
    pdH := dH
    pdL := dL
    map.clear(vp)
    dH := na
    dL := na

// pull this bar's lower-timeframe intrabars for TRUE volume-at-price
[ltfH, ltfL, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfRes, [high, low, volume])

// accumulate this bar using REAL volume-at-price (Jul 31 fix).
// OLD: smeared each 5-min bar's volume evenly across its whole H-L range ->
//      the busiest-price (POC) landed ~80 pts off Zarb's native profile.
// NEW: read this bar's 1-min intrabars and bin each one's OWN volume across its
//      OWN small range = true volume-at-price -> POC matches native SVP.
// NOTE: always runs (independent of showSVP) because the prior-session LEVELS
// derive from this profile. showSVP only governs the profile VISUAL below.
if array.size(ltfV) > 0
    for i = 0 to array.size(ltfV) - 1
        iv = array.get(ltfV, i)
        if not na(iv) and iv > 0
            f_binVol(vp, array.get(ltfL, i), array.get(ltfH, i), iv)
else if not na(volume) and volume > 0
    f_binVol(vp, low, high, volume)

dH := na(dH) ? high : math.max(dH, high)
dL := na(dL) ? low  : math.min(dL, low)

// developing profile (this session)
float devPOC = na
if showSVP and showDev
    [p2, a2, b2] = f_profile(vp, nRows, vaPct)
    devPOC := p2

// ================== PRIOR-SESSION FLAT LEVEL SEGMENTS =======================
// each session gets its OWN flat horizontal segment -> no diagonal drift
var line lnPOC = na
var line lnVAH = na
var line lnVAL = na
var line lnPDH = na
var line lnPDL = na

f_startLine(float price, color col, int w) =>
    not na(price) ? line.new(bar_index, price, bar_index + 1, price, xloc=xloc.bar_index, color=col, width=w) : na

if isNewDay
    if showPD
        lnPOC := f_startLine(pdPOC, colPOC, 2)
        lnVAH := f_startLine(pdVAH, colVA, 1)
        lnVAL := f_startLine(pdVAL, colVA, 1)
    if showPDHL
        lnPDH := f_startLine(pdH, colHL, 1)
        lnPDL := f_startLine(pdL, colHL, 1)

// extend the CURRENT session's flat segments to the live bar
if not na(lnPOC)
    line.set_x2(lnPOC, bar_index)
if not na(lnVAH)
    line.set_x2(lnVAH, bar_index)
if not na(lnVAL)
    line.set_x2(lnVAL, bar_index)
if not na(lnPDH)
    line.set_x2(lnPDH, bar_index)
if not na(lnPDL)
    line.set_x2(lnPDL, bar_index)

// ---- Midnight Open (00:00 New York) : flat per-day segment ----
// ICT reference: price at NY midnight. New NY day => capture the open, start a
// fresh flat segment; extend it through the day.
isMidnight = ta.change(dayofmonth(time, "America/New_York")) != 0
var float midOpen = na
var line  lnMid   = na
if isMidnight
    midOpen := open
    if showMid
        lnMid := f_startLine(midOpen, colMid, 1)
if not na(lnMid)
    line.set_x2(lnMid, bar_index)

// developing POC (moving line for the live session)
plot(showSVP and showDev ? devPOC : na, "Dev POC", color=colPOCd, linewidth=2, style=plot.style_stepline)

// ============================== LABELS ======================================
// persistent labels: created once, then updated -> never duplicate
var label lb_poc = na
var label lb_vah = na
var label lb_val = na
var label lb_pdh = na
var label lb_pdl = na

f_lab(label lbl, float price, string txt, color col) =>
    label out = lbl
    if showLbls and barstate.islast and not na(price)
        string s = txt + " " + str.tostring(price, format.mintick)
        if na(out)
            out := label.new(bar_index + 3, price, s, xloc=xloc.bar_index,
                 style=label.style_label_left, color=col, textcolor=color.white, size=size.small)
        else
            label.set_xy(out, bar_index + 3, price)
            label.set_text(out, s)
            label.set_color(out, col)
    out

if showPD
    lb_poc := f_lab(lb_poc, pdPOC, "PD POC", colPOC)
    lb_vah := f_lab(lb_vah, pdVAH, "PD VAH", colVA)
    lb_val := f_lab(lb_val, pdVAL, "PD VAL", colVA)
if showPDHL
    lb_pdh := f_lab(lb_pdh, pdH, "PDH", colHL)
    lb_pdl := f_lab(lb_pdl, pdL, "PDL", colHL)
var label lb_mid = na
if showMid
    lb_mid := f_lab(lb_mid, midOpen, "Midnight", colMid)

// ============================= HISTOGRAM ====================================
// developing session profile drawn as horizontal bars, redrawn on last bar
var box[] histo = array.new<box>()
if showSVP and showHisto and barstate.islast
    if array.size(histo) > 0
        for i = 0 to array.size(histo) - 1
            box.delete(array.get(histo, i))
        array.clear(histo)
    hk = map.keys(vp)
    int hn = array.size(hk)
    if hn > 0
        float mx = 0.0
        for i = 0 to hn - 1
            v = map.get(vp, array.get(hk, i))
            if v > mx
                mx := v
        int drawn = 0
        for i = 0 to hn - 1
            if drawn >= histoRows
                break
            k = array.get(hk, i)
            v = map.get(vp, k)
            float frac = mx > 0 ? v / mx : 0.0
            int len = int(math.round(frac * histoBars))
            if len < 1
                len := 1
            float pr = priceOf(k)
            float hb = binPts / 2.0
            bx = box.new(bar_index - len, pr + hb, bar_index, pr - hb, border_color=na, bgcolor=colHist)
            array.push(histo, bx)
            drawn += 1

// ============================ FVG / IFVG ====================================
// Bullish FVG: low > high[2]  (support zone high[2]..low)
// Bearish FVG: high < low[2]  (resistance zone high..low[2])
var box[] bulls  = array.new<box>()   // active bullish FVG (support)
var box[] bears  = array.new<box>()   // active bearish FVG (resistance)
var box[] ifBull = array.new<box>()   // IFVG from a bullish gap (now resistance)
var box[] ifBear = array.new<box>()   // IFVG from a bearish gap (now support)

bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG
    if bullFVG
        bx = box.new(bar_index[2], low, bar_index + extendN, high[2], border_color=na, bgcolor=colBull)
        array.push(bulls, bx)
        if array.size(bulls) > keepN
            box.delete(array.shift(bulls))
    if bearFVG
        bx = box.new(bar_index[2], low[2], bar_index + extendN, high, border_color=na, bgcolor=colBear)
        array.push(bears, bx)
        if array.size(bears) > keepN
            box.delete(array.shift(bears))

    // bullish FVG mitigated: close below its bottom -> flip to IFVG or disappear
    if array.size(bulls) > 0
        for i = array.size(bulls) - 1 to 0
            bx = array.get(bulls, i)
            if close < box.get_bottom(bx)
                array.remove(bulls, i)
                if flipIFVG
                    box.set_bgcolor(bx, colIFVG)
                    box.set_right(bx, bar_index + extendN)
                    array.push(ifBull, bx)
                    if array.size(ifBull) > keepN
                        box.delete(array.shift(ifBull))
                else
                    box.delete(bx)

    // bearish FVG mitigated: close above its top -> flip to IFVG or disappear
    if array.size(bears) > 0
        for i = array.size(bears) - 1 to 0
            bx = array.get(bears, i)
            if close > box.get_top(bx)
                array.remove(bears, i)
                if flipIFVG
                    box.set_bgcolor(bx, colIFVG)
                    box.set_right(bx, bar_index + extendN)
                    array.push(ifBear, bx)
                    if array.size(ifBear) > keepN
                        box.delete(array.shift(ifBear))
                else
                    box.delete(bx)

    // IFVG (from bullish, now resistance) filled -> disappear when close back above top
    if removeIFVG and array.size(ifBull) > 0
        for i = array.size(ifBull) - 1 to 0
            bx = array.get(ifBull, i)
            if close > box.get_top(bx)
                box.delete(bx)
                array.remove(ifBull, i)
    // IFVG (from bearish, now support) filled -> disappear when close back below bottom
    if removeIFVG and array.size(ifBear) > 0
        for i = array.size(ifBear) - 1 to 0
            bx = array.get(ifBear, i)
            if close < box.get_bottom(bx)
                box.delete(bx)
                array.remove(ifBear, i)

// ============================== BIAS ========================================
// Zarb's long/short filter around Prior-Session POC
biasLong  = not na(pdPOC) and close > pdPOC
biasShort = not na(pdPOC) and close < pdPOC
plotshape(showSVP and isNewDay, title="new session", location=location.bottom,
     style=shape.triangleup, size=size.tiny, color=color.new(color.gray, 60))
````

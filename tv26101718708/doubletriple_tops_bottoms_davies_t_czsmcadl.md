# Double/Triple Tops & Bottoms [DAVIES T]

- url: https://www.tradingview.com/script/CzsmcADL-Double-Triple-Tops-Bottoms-DAVIES-T/
- type: indicator
- pine_id: PUB;b8ca098fb57345d289c045750f8542f5
- version: 1.0

## Description

Double/Triple Tops & Bottoms [DAVIES T]

OVERVIEW
This indicator automatically detects classic Double Top, Triple Top, Double Bottom and Triple Bottom reversal patterns, tracks them while they form, and confirms them only when price closes through the neckline. On confirmation it projects a measured-move take profit and a stop loss beyond the pattern extreme.

HOW IT WORKS
1. Swing detection - Confirmed pivot highs and lows are found using a user-defined pivot strength (bars each side).
2. Peak matching - Two or three consecutive pivot highs (tops) or pivot lows (bottoms) are compared. They qualify as a pattern when they sit within an ATR-based tolerance of each other, so the logic adapts to any symbol and timeframe.
3. Neckline - The neckline is taken from the swing(s) between the peaks: the lowest intervening low for tops, the highest intervening high for bottoms. The pattern must have a minimum depth (in ATR) from peaks to neckline.
4. Clean structure check - No bar between the peaks may trade beyond the pattern extreme, which filters out broken or overlapping structures.
5. Triple priority - Triples are checked first. If a third matching peak forms on a pending double, it is upgraded to a triple automatically.
6. Forming stage - Unconfirmed patterns are drawn with a dashed zig-zag, a dotted neckline and a "DT?", "TT?", "DB?" or "TB?" label.
7. Invalidation - A pending pattern is removed if price closes beyond its extreme, or if the neckline is not broken within the allowed number of bars.
8. Confirmation - A candle close through the neckline confirms the pattern. The drawing turns solid, is labelled with its full name, and optional TP/SL lines are projected forward.

TARGETS
- TP = neckline +/- (pattern height x multiplier). The default is a 1.0x measured move.
- SL = pattern extreme +/- an ATR buffer.

SETTINGS
Detection: Pivot Strength, Peak Match Tolerance (x ATR), Min Depth to Neckline (x ATR), Min/Max Bars Between Peaks, Max Bars to Neckline Break, ATR Length.
Patterns: Toggle Double Tops, Triple Tops, Double Bottoms and Triple Bottoms individually. Optionally show forming patterns, and set how many confirmed patterns stay on the chart.
Targets: Toggle TP/SL, TP multiplier, SL ATR buffer, projection length.
Style: Bearish/bullish colours, neckline, TP and SL colours, label size.

ALERTS
- Top Forming / Top Confirmed
- Bottom Forming / Bottom Confirmed
- Any Pattern Confirmed

TUNING TIPS
- Too many patterns: lower Peak Match Tolerance (e.g. 0.3) or raise Min Depth (e.g. 1.5).
- Too few patterns on lower timeframes: lower Pivot Strength (e.g. 3).
- Higher Pivot Strength gives fewer but more significant swing-based patterns.

NOTES
- Patterns are detected on confirmed pivots, so detection is delayed by the Pivot Strength setting. Confirmations do not repaint once the candle closes.
- All drawings are time-anchored, so the indicator works on any timeframe without bar-index limits.
- Works on any market: forex, indices, crypto, stocks and futures.

DISCLAIMER
This script is for educational and analytical purposes only and is not financial advice. Chart patterns can fail; always use your own risk management.

## Source Code

````pine
//@version=6
indicator("Double/Triple Tops & Bottoms [DAVIES T]", shorttitle="DT-TB [DAVIES T]", overlay=true, max_lines_count=500, max_labels_count=500, max_polylines_count=100, max_bars_back=1000)

// ================= INPUTS =================
grpD = "Detection"
pivLen   = input.int(5, "Pivot Strength (bars each side)", minval=2, maxval=30, group=grpD)
tolATR   = input.float(0.5, "Peak Match Tolerance (x ATR)", minval=0.05, step=0.05, group=grpD, tooltip="How close the tops (or bottoms) must be to each other, measured in ATR.")
depthATR = input.float(1.0, "Min Depth to Neckline (x ATR)", minval=0.1, step=0.1, group=grpD, tooltip="Minimum distance between the peaks and the neckline.")
minGap   = input.int(5, "Min Bars Between Peaks", minval=2, group=grpD)
maxGap   = input.int(80, "Max Bars Between Peaks", minval=10, maxval=300, group=grpD)
maxWait  = input.int(40, "Max Bars to Neckline Break", minval=5, group=grpD, tooltip="Bars after the last peak. A forming pattern is dropped if the neckline is not broken in time.")
atrLen   = input.int(14, "ATR Length", minval=1, group=grpD)

grpP = "Patterns"
showDT   = input.bool(true, "Double Tops", group=grpP, inline="t")
showTT   = input.bool(true, "Triple Tops", group=grpP, inline="t")
showDB   = input.bool(true, "Double Bottoms", group=grpP, inline="b")
showTB   = input.bool(true, "Triple Bottoms", group=grpP, inline="b")
showPend = input.bool(true, "Show Forming (Unconfirmed) Patterns", group=grpP)
maxShow  = input.int(10, "Max Confirmed Patterns Kept", minval=1, maxval=50, group=grpP)

grpT = "Targets"
showTgt  = input.bool(true, "Show TP / SL on Neckline Break", group=grpT)
tpMult   = input.float(1.0, "TP = Pattern Height x", minval=0.25, step=0.25, group=grpT)
slBuf    = input.float(0.25, "SL Buffer Beyond Extreme (x ATR)", minval=0.0, step=0.05, group=grpT)
projBars = input.int(20, "TP/SL Line Length (bars)", minval=5, group=grpT)

grpS = "Style"
bearCol = input.color(#ef5350, "Tops (Bearish)", group=grpS)
bullCol = input.color(#26a69a, "Bottoms (Bullish)", group=grpS)
neckCol = input.color(color.gray, "Neckline", group=grpS)
tpCol   = input.color(#42a5f5, "TP", group=grpS)
slCol   = input.color(#ff9800, "SL", group=grpS)
lblSize = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=grpS)

sz = switch lblSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small
tfMs = timeframe.in_seconds() * 1000

// ================= TYPES / METHODS =================
type Pat
    bool  isTop
    int   kind
    float neck
    float extreme
    float height
    int   tStart
    int   lastPivBar
    array<chart.point> pts
    polyline pl
    line  neckLn
    label lbl
    line  tpLn
    line  slLn
    label tpLb
    label slLb

method clear(Pat p) =>
    polyline.delete(p.pl)
    line.delete(p.neckLn)
    label.delete(p.lbl)
    line.delete(p.tpLn)
    line.delete(p.slLn)
    label.delete(p.tpLb)
    label.delete(p.slLb)
    p

patName(Pat p) =>
    p.isTop ? (p.kind == 3 ? "Triple Top" : "Double Top") : (p.kind == 3 ? "Triple Bottom" : "Double Bottom")

patShort(Pat p) =>
    p.isTop ? (p.kind == 3 ? "TT" : "DT") : (p.kind == 3 ? "TB" : "DB")

method drawPending(Pat p) =>
    color c = p.isTop ? bearCol : bullCol
    chart.point lp = p.pts.last()
    p.pl := polyline.new(p.pts, false, false, xloc.bar_time, color.new(c, 40), color(na), line.style_dashed, 1)
    p.neckLn := line.new(p.tStart, p.neck, time, p.neck, xloc.bar_time, extend.none, color.new(neckCol, 30), line.style_dotted, 1)
    p.lbl := label.new(lp.time, lp.price, patShort(p) + "?", xloc.bar_time, yloc.price, color(na), p.isTop ? label.style_label_down : label.style_label_up, color.new(c, 30), sz, tooltip="Forming - waiting for neckline break")
    p

method confirm(Pat p, float atrV) =>
    color c = p.isTop ? bearCol : bullCol
    chart.point lp = p.pts.last()
    p.clear()
    p.pl := polyline.new(p.pts, false, false, xloc.bar_time, c, color(na), line.style_solid, 2)
    p.neckLn := line.new(p.tStart, p.neck, time, p.neck, xloc.bar_time, extend.none, neckCol, line.style_dashed, 1)
    p.lbl := label.new(lp.time, lp.price, patName(p), xloc.bar_time, yloc.price, color(na), p.isTop ? label.style_label_down : label.style_label_up, c, sz)
    if showTgt
        float tp = p.isTop ? p.neck - p.height * tpMult : p.neck + p.height * tpMult
        float sl = p.isTop ? p.extreme + slBuf * atrV : p.extreme - slBuf * atrV
        int t2 = time + projBars * tfMs
        p.tpLn := line.new(time, tp, t2, tp, xloc.bar_time, extend.none, tpCol, line.style_dashed, 1)
        p.slLn := line.new(time, sl, t2, sl, xloc.bar_time, extend.none, slCol, line.style_dashed, 1)
        p.tpLb := label.new(t2, tp, "TP " + str.tostring(tp, format.mintick), xloc.bar_time, yloc.price, color(na), label.style_label_left, tpCol, sz)
        p.slLb := label.new(t2, sl, "SL " + str.tostring(sl, format.mintick), xloc.bar_time, yloc.price, color(na), label.style_label_left, slCol, sz)
    p

// lowest low (tops) / highest high (bottoms) pivot strictly between two bars
extremeBetween(array<float> P, array<int> T, array<int> B, int b1, int b2, bool wantMin) =>
    float r = na
    int rt = na
    int n = array.size(P)
    if n > 0
        for i = 0 to n - 1
            int bi = array.get(B, i)
            if bi > b1 and bi < b2
                float v = array.get(P, i)
                if na(r) or (wantMin ? v < r : v > r)
                    r := v
                    rt := array.get(T, i)
    [r, rt]

// no bar since fromBar may poke beyond the pattern extreme
rangeOK(int fromBar, bool isTop, float lim) =>
    bool ok = true
    int span = bar_index - fromBar - 1
    if span >= 0
        for k = 0 to span
            if isTop ? high[k] > lim : low[k] < lim
                ok := false
                break
    ok

pushPiv(array<float> P, array<int> T, array<int> B, float v, int t, int b) =>
    array.push(P, v)
    array.push(T, t)
    array.push(B, b)
    if array.size(P) > 12
        array.shift(P)
        array.shift(T)
        array.shift(B)
    true

addPt(array<chart.point> a, int t, float v) =>
    array.push(a, chart.point.from_time(t, v))
    a

detect(bool isTop, float p, int pb, int pt, array<float> P, array<int> T, array<int> B, array<float> oP, array<int> oT, array<int> oB, float atrV) =>
    Pat res = na
    int n = array.size(P)
    float tol = tolATR * atrV
    float minDepth = depthATR * atrV
    // ---- Triple: two previous peaks + this one ----
    if n >= 2 and (isTop ? showTT : showTB)
        float a = array.get(P, n - 2)
        float b = array.get(P, n - 1)
        int ab = array.get(B, n - 2)
        int bb = array.get(B, n - 1)
        int at = array.get(T, n - 2)
        int bt = array.get(T, n - 1)
        int g1 = bb - ab
        int g2 = pb - bb
        float hi = math.max(a, b, p)
        float lo = math.min(a, b, p)
        if g1 >= minGap and g1 <= maxGap and g2 >= minGap and g2 <= maxGap and hi - lo <= tol
            [n1, n1t] = extremeBetween(oP, oT, oB, ab, bb, isTop)
            [n2, n2t] = extremeBetween(oP, oT, oB, bb, pb, isTop)
            if not na(n1) and not na(n2)
                float neck = isTop ? math.min(n1, n2) : math.max(n1, n2)
                float ext = isTop ? hi : lo
                float depth = isTop ? lo - neck : neck - hi
                if depth >= minDepth and rangeOK(ab, isTop, ext)
                    array<chart.point> pts = array.new<chart.point>()
                    addPt(pts, at, a)
                    addPt(pts, n1t, n1)
                    addPt(pts, bt, b)
                    addPt(pts, n2t, n2)
                    addPt(pts, pt, p)
                    res := Pat.new(isTop=isTop, kind=3, neck=neck, extreme=ext, height=math.abs(ext - neck), tStart=at, lastPivBar=pb, pts=pts)
    // ---- Double: previous peak + this one ----
    if na(res) and n >= 1 and (isTop ? showDT : showDB)
        float c = array.get(P, n - 1)
        int cb = array.get(B, n - 1)
        int ct = array.get(T, n - 1)
        int g = pb - cb
        if g >= minGap and g <= maxGap and math.abs(p - c) <= tol
            [nk, nkt] = extremeBetween(oP, oT, oB, cb, pb, isTop)
            if not na(nk)
                float ext2 = isTop ? math.max(p, c) : math.min(p, c)
                float inner = isTop ? math.min(p, c) : math.max(p, c)
                float depth2 = isTop ? inner - nk : nk - inner
                if depth2 >= minDepth and rangeOK(cb, isTop, ext2)
                    array<chart.point> pts2 = array.new<chart.point>()
                    addPt(pts2, ct, c)
                    addPt(pts2, nkt, nk)
                    addPt(pts2, pt, p)
                    res := Pat.new(isTop=isTop, kind=2, neck=nk, extreme=ext2, height=math.abs(ext2 - nk), tStart=ct, lastPivBar=pb, pts=pts2)
    res

// ================= STATE =================
float atr = ta.atr(atrLen)
float ph  = ta.pivothigh(high, pivLen, pivLen)
float pl  = ta.pivotlow(low, pivLen, pivLen)

var array<float> hP = array.new<float>()
var array<int>   hT = array.new<int>()
var array<int>   hB = array.new<int>()
var array<float> lP = array.new<float>()
var array<int>   lT = array.new<int>()
var array<int>   lB = array.new<int>()

var Pat pendTop = na
var Pat pendBot = na
var array<Pat> done = array.new<Pat>()

// 0 = still forming, 1 = confirmed, -1 = invalidated / expired
step(Pat p, float atrV) =>
    int st = 0
    bool broke = p.isTop ? close < p.neck : close > p.neck
    bool inval = p.isTop ? close > p.extreme : close < p.extreme
    if inval or bar_index - p.lastPivBar > math.max(maxWait, pivLen + 1)
        p.clear()
        st := -1
    else if broke
        p.confirm(atrV)
        done.push(p)
        if done.size() > maxShow
            Pat old = done.shift()
            old.clear()
        st := 1
    else
        if not na(p.neckLn)
            line.set_x2(p.neckLn, time)
    st

bool detTop = false
bool detBot = false
bool cfTop  = false
bool cfBot  = false

// ================= DETECTION =================
if not na(ph)
    int pb = bar_index - pivLen
    int pt = time[pivLen]
    Pat np = detect(true, ph, pb, pt, hP, hT, hB, lP, lT, lB, atr)
    if not na(np)
        if not na(pendTop)
            pendTop.clear()
        pendTop := np
        if showPend
            pendTop.drawPending()
        detTop := true
    pushPiv(hP, hT, hB, ph, pt, pb)

if not na(pl)
    int pb = bar_index - pivLen
    int pt = time[pivLen]
    Pat np = detect(false, pl, pb, pt, lP, lT, lB, hP, hT, hB, atr)
    if not na(np)
        if not na(pendBot)
            pendBot.clear()
        pendBot := np
        if showPend
            pendBot.drawPending()
        detBot := true
    pushPiv(lP, lT, lB, pl, pt, pb)

// ================= CONFIRM / INVALIDATE =================
if not na(pendTop)
    int st = step(pendTop, atr)
    cfTop := st == 1
    if st != 0
        pendTop := na

if not na(pendBot)
    int st = step(pendBot, atr)
    cfBot := st == 1
    if st != 0
        pendBot := na

// ================= ALERTS =================
alertcondition(detTop, "Top Forming", "Double/Triple Top forming on {{ticker}} {{interval}}")
alertcondition(cfTop, "Top Confirmed", "Double/Triple Top neckline break on {{ticker}} {{interval}} @ {{close}}")
alertcondition(detBot, "Bottom Forming", "Double/Triple Bottom forming on {{ticker}} {{interval}}")
alertcondition(cfBot, "Bottom Confirmed", "Double/Triple Bottom neckline break on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cfTop or cfBot, "Any Pattern Confirmed", "Double/Triple pattern confirmed on {{ticker}} {{interval}} @ {{close}}")
````

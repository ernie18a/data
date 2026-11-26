# Session & Hour Swing-Anchored AVWAPs + Placebo + Developing

- url: https://www.tradingview.com/script/oKDXVqSb-Session-Hour-Swing-Anchored-AVWAPs-Placebo-Developing/
- type: indicator
- pine_id: PUB;55656b11e7a549e9a9ae679d4a75db72
- version: 1.0

## Description

A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.A sleepy fox wandered through a moonlit garden, chasing fireflies between rosemary bushes while an old radio played softly from a nearby window, turning the quiet night into a tiny, secret adventure!.

## Source Code

````pine
//@version=6
indicator("Session & Hour Swing-Anchored AVWAPs + Placebo + Developing", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

lenL     = input.int(3, "Pivot left bars", minval = 1)
lenR     = input.int(3, "Pivot right bars", minval = 1)
kAtr     = input.float(0.3, "Min separation between swing points (x ATR)", minval = 0, step = 0.05)
atrLen   = input.int(14, "ATR length", minval = 1)
showPts  = input.bool(true, "Show counted session swing points")
showPlc  = input.bool(true, "Show placebo lines")
showDev  = input.bool(true, "Show developing composites in the source session (Asia / London)")
showAll  = input.bool(true, "Show full history")
recentH  = input.int(24, "If not full history: show last N hours", minval = 1)

// Sessions in New York time: Asia 18:00-03:00, London 03:00-09:30, New York 09:30-16:00
TZ = "America/New_York"
f_sess(int t) =>
    int mm = hour(t, TZ) * 60 + minute(t, TZ)
    mm >= 1080 or mm < 180 ? 0 : mm < 570 ? 1 : mm < 960 ? 2 : -1

int   sess     = f_sess(time)
int   prevSess = nz(sess[1], -2)
bool  newSess  = sess != prevSess
bool  trading  = sess == 1 or sess == 2
bool  source   = sess == 0 or sess == 1
int   hid      = int(math.floor(time / 3600000))          // clock-hour id
bool  newHour  = hid != nz(hid[1], -1)
float atr      = ta.atr(atrLen)
float vol      = nz(volume)
bool  vis      = showAll or time >= last_bar_time - recentH * 3600000

// Placebo shift sizes in bars, from minutes (same as the backtest: session 15-60 min, hour 10-30 min)
float tfMin  = timeframe.in_seconds() / 60.0
int   sMinB  = math.max(1, int(math.round(15 / tfMin)))
int   sMaxB  = math.max(sMinB, int(math.round(60 / tfMin)))
int   hMinB  = math.max(1, int(math.round(10 / tfMin)))
int   hMaxB  = math.max(hMinB, int(math.round(30 / tfMin)))

// Pivots are confirmed lenR bars after they print (no lookahead)
float ph      = ta.pivothigh(high, lenL, lenR)
float pl      = ta.pivotlow(low, lenL, lenR)
int   pivSess = nz(sess[lenR], -2)
int   pivHid  = nz(hid[lenR], -1)

// ---------- Helpers ----------
// Volume-weighted sum of highs (useHigh) or lows from bar `idx` through the previous bar
f_sum(int idx, bool useHigh) =>
    float pv = 0.0
    float v  = 0.0
    int   n  = bar_index - idx
    if n >= 1
        for k = n to 1
            float vk = nz(volume[k])
            pv += (useHigh ? high[k] : low[k]) * vk
            v  += vk
    [pv, v]

// Add a swing point; if within tol of the last one, keep only the more extreme. 0 = ignored, 1 = added, 2 = replaced
f_add(array<int> xs, array<float> ys, float p, int px, float tol, bool isHigh) =>
    int n   = array.size(ys)
    int res = 0
    if n > 0 and math.abs(p - array.get(ys, n - 1)) < tol
        if isHigh ? p > array.get(ys, n - 1) : p < array.get(ys, n - 1)
            array.set(ys, n - 1, p)
            array.set(xs, n - 1, px)
            res := 2
    else
        array.push(ys, p)
        array.push(xs, px)
        res := 1
    res

// Start one AVWAP at every anchor bar in xs (or at the fallback bar fb if xs is empty)
f_anchor(array<int> xs, int fb, bool useHigh, array<float> pvs, array<float> vs) =>
    array.clear(pvs)
    array.clear(vs)
    int n = array.size(xs)
    if n > 0
        for i = 0 to n - 1
            [p, v] = f_sum(array.get(xs, i), useHigh)
            array.push(pvs, p)
            array.push(vs, v)
    else if not na(fb)
        [p, v] = f_sum(fb, useHigh)
        array.push(pvs, p)
        array.push(vs, v)
    n

// Placebo anchors: every real anchor moved mn..mx bars (deterministic pseudo-random size and direction),
// kept inside the same session/hour [a0, a1]
f_shift(array<int> xs, int fb, int a0, int a1, int mn, int mx) =>
    array<int> out = array.new<int>()
    array<int> src = array.copy(xs)
    if array.size(src) == 0 and not na(fb)
        array.push(src, fb)
    int n = array.size(src)
    if n > 0
        for i = 0 to n - 1
            int x  = array.get(src, i)
            int dd = mn + (x * 7919 + i * 104729) % (mx - mn + 1)
            int sg = (x + i) % 2 == 0 ? 1 : -1
            int p  = x + sg * dd
            if p < a0 or p > a1
                p := x - sg * dd
            p := math.min(math.max(p, a0), a1)
            array.push(out, p)
    out

// Developing composite: add a new AVWAP for a new swing (r = 1) or restart the last one if the swing was replaced (r = 2)
f_dev(array<float> pvs, array<float> vs, int r, int px, bool useHigh) =>
    if r > 0
        [p, v] = f_sum(px, useHigh)
        if r == 1 or array.size(pvs) == 0
            array.push(pvs, p)
            array.push(vs, v)
        else
            array.set(pvs, array.size(pvs) - 1, p)
            array.set(vs, array.size(vs) - 1, v)
    r

// Add the current bar to every active AVWAP
f_upd(array<float> pvs, array<float> vs, float src, float vb) =>
    int n = array.size(pvs)
    if n > 0
        for i = 0 to n - 1
            array.set(pvs, i, array.get(pvs, i) + src * vb)
            array.set(vs,  i, array.get(vs, i) + vb)
    n

// Equal-weight average of all anchored AVWAPs
f_mean(array<float> pvs, array<float> vs) =>
    float s = 0.0
    int   c = 0
    int   n = array.size(pvs)
    if n > 0
        for i = 0 to n - 1
            float vv = array.get(vs, i)
            if vv > 0
                s += array.get(pvs, i) / vv
                c += 1
    c > 0 ? s / c : na

// ---------- State ----------
// swing points collected during the running session / hour
var array<int>   sHx = array.new<int>()
var array<float> sHy = array.new<float>()
var array<int>   sLx = array.new<int>()
var array<float> sLy = array.new<float>()
var array<int>   hHx = array.new<int>()
var array<float> hHy = array.new<float>()
var array<int>   hLx = array.new<int>()
var array<float> hLy = array.new<float>()
// active AVWAP accumulators (real)
var array<float> sHpv = array.new<float>()
var array<float> sHv  = array.new<float>()
var array<float> sLpv = array.new<float>()
var array<float> sLv  = array.new<float>()
var array<float> hHpv = array.new<float>()
var array<float> hHv  = array.new<float>()
var array<float> hLpv = array.new<float>()
var array<float> hLv  = array.new<float>()
// active AVWAP accumulators (placebo)
var array<float> qsHpv = array.new<float>()
var array<float> qsHv  = array.new<float>()
var array<float> qsLpv = array.new<float>()
var array<float> qsLv  = array.new<float>()
var array<float> qhHpv = array.new<float>()
var array<float> qhHv  = array.new<float>()
var array<float> qhLpv = array.new<float>()
var array<float> qhLv  = array.new<float>()
// developing composites of the running source session (Asia / London)
var array<float> dHpv = array.new<float>()
var array<float> dHv  = array.new<float>()
var array<float> dLpv = array.new<float>()
var array<float> dLv  = array.new<float>()
// absolute extremes and start bars of the running session / hour
var float curHi    = na
var int   curHiIdx = na
var float curLo    = na
var int   curLoIdx = na
var int   curStart = na
var int   hrHiIdx  = na
var float hrHi     = na
var int   hrLoIdx  = na
var float hrLo     = na
var int   hrStart  = na
var int   sPar     = 0
var int   hPar     = 0
var line  hiLine   = na
var line  loLine   = na
var label sHPt     = na
var label sLPt     = na

// ---------- New hour: previous-hour swing-anchored AVWAPs (real + placebo) ----------
if newHour
    if not na(hrHiIdx)
        f_anchor(hHx, hrHiIdx, true, hHpv, hHv)
        f_anchor(hLx, hrLoIdx, false, hLpv, hLv)
        f_anchor(f_shift(hHx, hrHiIdx, hrStart, bar_index - 1, hMinB, hMaxB), na, true, qhHpv, qhHv)
        f_anchor(f_shift(hLx, hrLoIdx, hrStart, bar_index - 1, hMinB, hMaxB), na, false, qhLpv, qhLv)
        hPar := 1 - hPar
    array.clear(hHx)
    array.clear(hHy)
    array.clear(hLx)
    array.clear(hLy)
    hrHi    := high
    hrHiIdx := bar_index
    hrLo    := low
    hrLoIdx := bar_index
    hrStart := bar_index
else
    if na(hrHi) or high > hrHi
        hrHi    := high
        hrHiIdx := bar_index
    if na(hrLo) or low < hrLo
        hrLo    := low
        hrLoIdx := bar_index

// ---------- New session: previous-session swing-anchored AVWAPs (real + placebo) + dashed High/Low lines ----------
if newSess
    // the lines of the session that just ended stop at its last bar
    hiLine := na
    loLine := na
    array.clear(sHpv)
    array.clear(sHv)
    array.clear(sLpv)
    array.clear(sLv)
    array.clear(qsHpv)
    array.clear(qsHv)
    array.clear(qsLpv)
    array.clear(qsLv)
    // London uses Asia, New York uses London
    bool chain = (sess == 1 and prevSess == 0) or (sess == 2 and prevSess == 1)
    if chain and not na(curHiIdx) and not na(curLoIdx)
        f_anchor(sHx, curHiIdx, true, sHpv, sHv)
        f_anchor(sLx, curLoIdx, false, sLpv, sLv)
        f_anchor(f_shift(sHx, curHiIdx, curStart, bar_index - 1, sMinB, sMaxB), na, true, qsHpv, qsHv)
        f_anchor(f_shift(sLx, curLoIdx, curStart, bar_index - 1, sMinB, sMaxB), na, false, qsLpv, qsLv)
        sPar   := 1 - sPar
        if vis
            hiLine := line.new(bar_index, curHi, bar_index, curHi, color = color.green, style = line.style_dashed, width = 1)
            loLine := line.new(bar_index, curLo, bar_index, curLo, color = color.red, style = line.style_dashed, width = 1)
    // the new session's developing composites start empty
    array.clear(dHpv)
    array.clear(dHv)
    array.clear(dLpv)
    array.clear(dLv)
    array.clear(sHx)
    array.clear(sHy)
    array.clear(sLx)
    array.clear(sLy)
    sHPt     := na
    sLPt     := na
    curHi    := high
    curHiIdx := bar_index
    curLo    := low
    curLoIdx := bar_index
    curStart := bar_index
else
    if na(curHi) or high > curHi
        curHi    := high
        curHiIdx := bar_index
    if na(curLo) or low < curLo
        curLo    := low
        curLoIdx := bar_index

// ---------- Collect swing points (and grow the developing composites) ----------
float tol = kAtr * atr
if not na(ph)
    int px = bar_index - lenR
    if pivHid == hid
        f_add(hHx, hHy, ph, px, tol, true)
    if pivSess == sess and source
        int r = f_add(sHx, sHy, ph, px, tol, true)
        f_dev(dHpv, dHv, r, px, true)
        if showPts and vis and r > 0
            if r == 2
                label.delete(sHPt)
            sHPt := label.new(px, ph, "", yloc = yloc.abovebar, style = label.style_circle, color = color.green, size = size.tiny)

if not na(pl)
    int px = bar_index - lenR
    if pivHid == hid
        f_add(hLx, hLy, pl, px, tol, false)
    if pivSess == sess and source
        int r = f_add(sLx, sLy, pl, px, tol, false)
        f_dev(dLpv, dLv, r, px, false)
        if showPts and vis and r > 0
            if r == 2
                label.delete(sLPt)
            sLPt := label.new(px, pl, "", yloc = yloc.belowbar, style = label.style_circle, color = color.red, size = size.tiny)

// ---------- Add the current bar to every active AVWAP ----------
f_upd(sHpv, sHv, high, vol)
f_upd(sLpv, sLv, low, vol)
f_upd(hHpv, hHv, high, vol)
f_upd(hLpv, hLv, low, vol)
f_upd(qsHpv, qsHv, high, vol)
f_upd(qsLpv, qsLv, low, vol)
f_upd(qhHpv, qhHv, high, vol)
f_upd(qhLpv, qhLv, low, vol)
f_upd(dHpv, dHv, high, vol)
f_upd(dLpv, dLv, low, vol)

// ---------- Extend the dashed lines only while the session that uses them is running ----------
if trading
    if not na(hiLine)
        line.set_x2(hiLine, bar_index)
    if not na(loLine)
        line.set_x2(loLine, bar_index)

// ---------- Composite values ----------
bool showT    = trading and vis
float sessHi  = showT ? f_mean(sHpv, sHv) : na
float sessLo  = showT ? f_mean(sLpv, sLv) : na
float hourHi  = showT ? f_mean(hHpv, hHv) : na
float hourLo  = showT ? f_mean(hLpv, hLv) : na
float pSessHi = showT and showPlc ? f_mean(qsHpv, qsHv) : na
float pSessLo = showT and showPlc ? f_mean(qsLpv, qsLv) : na
float pHourHi = showT and showPlc ? f_mean(qhHpv, qhHv) : na
float pHourLo = showT and showPlc ? f_mean(qhLpv, qhLv) : na
float devHi   = showDev and source and vis ? f_mean(dHpv, dHv) : na
float devLo   = showDev and source and vis ? f_mean(dLpv, dLv) : na

// Two alternating plots per line so a re-anchor starts a fresh line instead of drawing a connector
plot(sPar == 0 ? sessHi : na, "Prev Session High AVWAP",   color.green,  2, plot.style_linebr)
plot(sPar == 1 ? sessHi : na, "Prev Session High AVWAP ",  color.green,  2, plot.style_linebr)
plot(sPar == 0 ? sessLo : na, "Prev Session Low AVWAP",    color.red,    2, plot.style_linebr)
plot(sPar == 1 ? sessLo : na, "Prev Session Low AVWAP ",   color.red,    2, plot.style_linebr)
plot(hPar == 0 ? hourHi : na, "Prev Hour High AVWAP",      color.orange, 1, plot.style_linebr)
plot(hPar == 1 ? hourHi : na, "Prev Hour High AVWAP ",     color.orange, 1, plot.style_linebr)
plot(hPar == 0 ? hourLo : na, "Prev Hour Low AVWAP",       color.white,  1, plot.style_linebr)
plot(hPar == 1 ? hourLo : na, "Prev Hour Low AVWAP ",      color.white,  1, plot.style_linebr)
// Placebo composites: same math, anchors shifted away from the real swings
plot(sPar == 0 ? pSessHi : na, "Placebo Session High",  color.gray,   2, plot.style_linebr)
plot(sPar == 1 ? pSessHi : na, "Placebo Session High ", color.gray,   2, plot.style_linebr)
plot(sPar == 0 ? pSessLo : na, "Placebo Session Low",   color.gray,   2, plot.style_linebr)
plot(sPar == 1 ? pSessLo : na, "Placebo Session Low ",  color.gray,   2, plot.style_linebr)
plot(hPar == 0 ? pHourHi : na, "Placebo Hour High",     color.silver, 1, plot.style_linebr)
plot(hPar == 1 ? pHourHi : na, "Placebo Hour High ",    color.silver, 1, plot.style_linebr)
plot(hPar == 0 ? pHourLo : na, "Placebo Hour Low",      color.silver, 1, plot.style_linebr)
plot(hPar == 1 ? pHourLo : na, "Placebo Hour Low ",     color.silver, 1, plot.style_linebr)
// Developing composites of the source session (become the next session's green / red lines)
plot(devHi, "Developing Session High AVWAP", color.new(color.green, 55), 1, plot.style_linebr)
plot(devLo, "Developing Session Low AVWAP",  color.new(color.red, 55),   1, plot.style_linebr)
````

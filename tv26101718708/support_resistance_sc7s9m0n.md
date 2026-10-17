# Support Resistance

- url: https://www.tradingview.com/script/SC7S9M0n-Support-Resistance/
- type: indicator
- pine_id: PUB;2fb46567539b43ba94deabae8f25ad1f
- version: 1.0

## Description

EV S/R + Trend PRO is a comprehensive support and resistance system combined with automatic trendline detection. It identifies pivot-based price levels, merges nearby ones into high-conviction zones, and tracks them dynamically as the market evolves.

What makes it different:

Role Reversal (S↔R) — when price closes through a resistance level, it automatically flips to support, and vice versa. The line turns dashed and is tagged with ↕ so you always know which levels have been retested and converted
Strength-based line width — levels touched 1-2 times show as thin lines (★), 3-4 touches as medium (★★), and 5+ touches as thick (★★★), giving you an instant visual read on level quality
Nearest level highlight — the level closest to current price is always highlighted in yellow so your attention goes to what matters right now
Dual trend mode — choose between diagonal trendlines (connecting swing highs/lows) or horizontal rays from the last swing high and low
Smart merging — nearby pivots within an ATR threshold are merged into a single level rather than cluttering the chart with overlapping lines
Auto-pruning — levels too far from price or too old are removed automatically to keep the chart clean
Settings:

Pivot length, max levels, merge threshold, lookback bars, max distance from price
Role reversal, strength-based width, nearest level highlight toggle
Trend mode: diagonal trendlines or horizontal rays
Require valid slope filter for diagonal mode
Full color customization for support, resistance, trend up/down, and nearest level
Alerts (4 conditions):

Resistance broken (role reversal triggered)
Support broken (role reversal triggered)
Price breaks above last swing high ray
Price breaks below last swing low ray

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © EV Quant Lab

//@version=6
indicator("EV S/R + Trend PRO", shorttitle="S/R", overlay=true, max_lines_count=500, max_labels_count=200)

// ─────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────
g1 = "Support & Resistance"
g2 = "Trend"
g3 = "Style"

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
pivotLen      = input.int(5,     "Pivot Length",                  minval=1,             group=g1)
maxLevels     = input.int(12,    "Max Levels",                    minval=1, maxval=100,  group=g1)
atrLen        = input.int(14,    "ATR Length",                    minval=1,             group=g1)
mergeAtr      = input.float(0.25,"Merge Threshold (ATR Mult)",    minval=0.0, step=0.05, group=g1)
extendRight   = input.bool(true, "Extend Levels Right",                                 group=g1)
showLabels    = input.bool(true, "Show Labels",                                         group=g1)
strengthWidth = input.bool(true, "Strength-Based Line Width",                           group=g1)
roleReversal  = input.bool(true, "Role Reversal (S↔R on Break)",                       group=g1)
highlightNear = input.bool(true, "Highlight Nearest Level",                             group=g1)
srLookback    = input.int(800,   "Lookback Bars",                 minval=50,            group=g1)
srMaxDistATR  = input.float(6.0, "Max Distance (ATR)",            minval=0.5, step=0.5, group=g1)

trendMode    = input.string("Trendlines (Diagonal)", "Trend Mode",
     options=["Trendlines (Diagonal)", "Rays (Horizontal)"], group=g2)
showTrend    = input.bool(true,  "Show Trend",          group=g2)
showPrev     = input.bool(false, "Show Previous",       group=g2)
requireSlope = input.bool(true,  "Require Valid Slope", group=g2)
alertTrBreak = input.bool(true,  "Trend Break Alerts",  group=g2)
alertSRBreak = input.bool(true,  "S/R Break Alerts",    group=g2)

colSupport  = input.color(color.new(color.teal,   0),  "Support Color",    group=g3)
colResist   = input.color(color.new(color.red,    0),  "Resistance Color", group=g3)
colNearest  = input.color(color.new(color.yellow, 0),  "Nearest Level",    group=g3)
colUp       = input.color(color.new(color.teal,   0),  "Up Trend Color",   group=g3)
colDown     = input.color(color.new(color.red,    0),  "Down Trend Color", group=g3)
lwSR        = input.int(1, "S/R Base Width",  minval=1, maxval=3, group=g3)
lwTr        = input.int(2, "Trend Width",     minval=1, maxval=4, group=g3)

// ─────────────────────────────────────────────
// CORE
// ─────────────────────────────────────────────
atr     = ta.atr(atrLen)
th      = atr * mergeAtr
maxDist = atr * srMaxDistATR

// ─────────────────────────────────────────────
// S/R ARRAYS
// ─────────────────────────────────────────────
var float[] srPrice    = array.new_float()
var int[]   srStrength = array.new_int()
var bool[]  srIsRes    = array.new_bool()
var bool[]  srFlipped  = array.new_bool()   // role-reversed?
var int[]   srTime     = array.new_int()
var int[]   srBar      = array.new_int()
var line[]  srLine     = array.new_line()
var label[] srLabel    = array.new_label()

f_col(isRes) => isRes ? colResist : colSupport

f_width(s) =>
    w = strengthWidth ? (s >= 5 ? lwSR + 2 : s >= 3 ? lwSR + 1 : lwSR) : lwSR
    math.min(w, 4)

f_stars(s) => s >= 5 ? "★★★" : s >= 3 ? "★★" : "★"

f_del_level(idx) =>
    ln = array.get(srLine, idx)
    if not na(ln)
        line.delete(ln)
    lb = array.get(srLabel, idx)
    if not na(lb)
        label.delete(lb)
    array.remove(srPrice,    idx)
    array.remove(srStrength, idx)
    array.remove(srIsRes,    idx)
    array.remove(srFlipped,  idx)
    array.remove(srTime,     idx)
    array.remove(srBar,      idx)
    array.remove(srLine,     idx)
    array.remove(srLabel,    idx)

f_update_label(idx, xTime, yPrice) =>
    if not showLabels
        lb = array.get(srLabel, idx)
        if not na(lb)
            label.delete(lb)
        array.set(srLabel, idx, na)
    else
        s       = array.get(srStrength, idx)
        isR     = array.get(srIsRes,    idx)
        flipped = array.get(srFlipped,  idx)
        tag     = isR ? "R" : "S"
        flip    = flipped ? " ↕" : ""
        txt     = tag + " " + f_stars(s) + flip + " (" + str.tostring(s) + ")"
        col     = color.new(f_col(isR), 75)
        lb = array.get(srLabel, idx)
        if na(lb)
            lb := label.new(x=xTime, y=yPrice, xloc=xloc.bar_time,
                text=txt, style=label.style_label_left,
                textcolor=color.white, color=col, size=size.tiny)
            array.set(srLabel, idx, lb)
        else
            label.set_x(lb, xTime)
            label.set_y(lb, yPrice)
            label.set_text(lb, txt)
            label.set_color(lb, col)

f_keep_best() =>
    while array.size(srPrice) > maxLevels
        minIdx = 0
        minVal = array.get(srStrength, 0)
        n = array.size(srStrength)
        if n > 1
            for i = 1 to n - 1
                v = array.get(srStrength, i)
                if v < minVal
                    minVal := v
                    minIdx := i
        f_del_level(minIdx)

f_prune() =>
    n = array.size(srPrice)
    if n > 0
        for i = n - 1 to 0
            p  = array.get(srPrice, i)
            b0 = array.get(srBar,   i)
            if (bar_index - b0) > srLookback or math.abs(close - p) > maxDist
                f_del_level(i)

f_add_or_merge(p, isRes, pivotTime, pivotBar) =>
    if math.abs(close - p) <= maxDist
        merged = false
        n = array.size(srPrice)
        if n > 0
            for i = 0 to n - 1
                ep = array.get(srPrice, i)
                if math.abs(p - ep) <= th
                    s  = array.get(srStrength, i)
                    np = (ep * s + p) / (s + 1)
                    array.set(srPrice,    i, np)
                    array.set(srStrength, i, s + 1)
                    array.set(srTime,     i, pivotTime)
                    array.set(srBar,      i, pivotBar)
                    ln = array.get(srLine, i)
                    if not na(ln)
                        line.set_y1(ln, np)
                        line.set_y2(ln, np)
                        line.set_width(ln, f_width(s + 1))
                    f_update_label(i, time, np)
                    merged := true
                    break
        if not merged
            ext = extendRight ? extend.right : extend.none
            ln = line.new(x1=pivotTime, y1=p, x2=time, y2=p,
                xloc=xloc.bar_time, extend=ext,
                color=f_col(isRes), width=f_width(1))
            array.push(srPrice,    p)
            array.push(srStrength, 1)
            array.push(srIsRes,    isRes)
            array.push(srFlipped,  false)
            array.push(srTime,     pivotTime)
            array.push(srBar,      pivotBar)
            array.push(srLine,     ln)
            array.push(srLabel,    na)
            f_update_label(array.size(srPrice) - 1, time, p)
        f_keep_best()

// ─────────────────────────────────────────────
// PIVOTS → ADD LEVELS
// ─────────────────────────────────────────────
ph        = ta.pivothigh(high, pivotLen, pivotLen)
pl        = ta.pivotlow(low,  pivotLen, pivotLen)
pivotTime = time[pivotLen]
pivotBar  = bar_index[pivotLen]

if not na(ph)
    f_add_or_merge(ph, true, pivotTime, pivotBar)
if not na(pl)
    f_add_or_merge(pl, false, pivotTime, pivotBar)

if not extendRight
    n = array.size(srLine)
    if n > 0
        for i = 0 to n - 1
            ln = array.get(srLine, i)
            if not na(ln)
                line.set_x2(ln, time)

f_prune()

// ─────────────────────────────────────────────
// ROLE REVERSAL — S↔R on candle close break
// ─────────────────────────────────────────────
var bool srBreakAbove = false
var bool srBreakBelow = false
srBreakAbove := false
srBreakBelow := false

n = array.size(srPrice)
if roleReversal and n > 0
    for i = 0 to n - 1
        p   = array.get(srPrice,  i)
        isR = array.get(srIsRes,  i)
        // Resistance broken above → flip to support
        if isR and close > p and close[1] <= p
            array.set(srIsRes,   i, false)
            array.set(srFlipped, i, true)
            ln = array.get(srLine, i)
            if not na(ln)
                line.set_color(ln, colSupport)
                line.set_style(ln, line.style_dashed)
            f_update_label(i, time, p)
            srBreakAbove := true
        // Support broken below → flip to resistance
        if not isR and close < p and close[1] >= p
            array.set(srIsRes,   i, true)
            array.set(srFlipped, i, true)
            ln = array.get(srLine, i)
            if not na(ln)
                line.set_color(ln, colResist)
                line.set_style(ln, line.style_dashed)
            f_update_label(i, time, p)
            srBreakBelow := true

// ─────────────────────────────────────────────
// HIGHLIGHT NEAREST LEVEL
// ─────────────────────────────────────────────
if highlightNear and barstate.islast
    n2 = array.size(srPrice)
    if n2 > 0
        nearIdx  = 0
        nearDist = math.abs(close - array.get(srPrice, 0))
        if n2 > 1
            for i = 1 to n2 - 1
                d = math.abs(close - array.get(srPrice, i))
                if d < nearDist
                    nearDist := d
                    nearIdx  := i
        for i = 0 to n2 - 1
            ln = array.get(srLine, i)
            if not na(ln)
                if i == nearIdx
                    line.set_color(ln, colNearest)
                    line.set_width(ln, math.min(lwSR + 2, 4))
                else
                    isR = array.get(srIsRes,    i)
                    s   = array.get(srStrength, i)
                    line.set_color(ln, f_col(isR))
                    line.set_width(ln, f_width(s))

// ─────────────────────────────────────────────
// TREND LINES
// ─────────────────────────────────────────────
var int   hiT2 = na
var float hiP2 = na
var int   hiT1 = na
var float hiP1 = na
var int   loT2 = na
var float loP2 = na
var int   loT1 = na
var float loP1 = na

if not na(ph)
    hiT1 := hiT2
    hiP1 := hiP2
    hiT2 := pivotTime
    hiP2 := ph
if not na(pl)
    loT1 := loT2
    loP1 := loP2
    loT2 := pivotTime
    loP2 := pl

var line upObj  = na
var line dnObj  = na
var line upPrev = na
var line dnPrev = na

f_set_line(_line, t1, p1, t2, p2, _col, _w, _ext) =>
    ext = _ext ? extend.right : extend.none
    if na(_line)
        line.new(x1=t1, y1=p1, x2=t2, y2=p2, xloc=xloc.bar_time, extend=ext, color=_col, width=_w)
    else
        line.set_x1(_line, t1)
        line.set_y1(_line, p1)
        line.set_x2(_line, t2)
        line.set_y2(_line, p2)
        line.set_color(_line, _col)
        line.set_width(_line, _w)
        line.set_extend(_line, ext)
        _line

if showTrend
    if trendMode == "Rays (Horizontal)"
        if not na(hiT2) and not na(hiP2)
            dnObj := f_set_line(dnObj, hiT2, hiP2, time, hiP2, colDown, lwTr, true)
        if not na(loT2) and not na(loP2)
            upObj := f_set_line(upObj, loT2, loP2, time, loP2, colUp, lwTr, true)
        if showPrev
            if not na(hiT1) and not na(hiP1)
                dnPrev := f_set_line(dnPrev, hiT1, hiP1, time, hiP1, color.new(colDown, 50), 1, true)
            if not na(loT1) and not na(loP1)
                upPrev := f_set_line(upPrev, loT1, loP1, time, loP1, color.new(colUp, 50), 1, true)
        else
            if not na(upPrev)
                line.delete(upPrev)
                upPrev := na
            if not na(dnPrev)
                line.delete(dnPrev)
                dnPrev := na
    else
        if not na(loT1) and not na(loT2)
            if not requireSlope or loP2 > loP1
                upObj := f_set_line(upObj, loT1, loP1, loT2, loP2, colUp, lwTr, true)
            else if not na(upObj)
                line.delete(upObj)
                upObj := na
        if not na(hiT1) and not na(hiT2)
            if not requireSlope or hiP2 < hiP1
                dnObj := f_set_line(dnObj, hiT1, hiP1, hiT2, hiP2, colDown, lwTr, true)
            else if not na(dnObj)
                line.delete(dnObj)
                dnObj := na
        if not showPrev
            if not na(upPrev)
                line.delete(upPrev)
                upPrev := na
            if not na(dnPrev)
                line.delete(dnPrev)
                dnPrev := na
else
    if not na(upObj)
        line.delete(upObj)
        upObj := na
    if not na(dnObj)
        line.delete(dnObj)
        dnObj := na
    if not na(upPrev)
        line.delete(upPrev)
        upPrev := na
    if not na(dnPrev)
        line.delete(dnPrev)
        dnPrev := na

// ─────────────────────────────────────────────
// ALERTS — pre-compute crossovers globally
// ─────────────────────────────────────────────
crossAboveHR = ta.crossover(close,  nz(hiP2, 1e10))
crossBelowLR = ta.crossunder(close, nz(loP2, -1e10))

alertcondition(alertSRBreak and srBreakAbove, title="S/R: Resistance Broken",  message="Price closed above resistance on {{ticker}} {{interval}}")
alertcondition(alertSRBreak and srBreakBelow, title="S/R: Support Broken",     message="Price closed below support on {{ticker}} {{interval}}")
alertcondition(alertTrBreak and trendMode == "Rays (Horizontal)" and not na(hiP2) and crossAboveHR, title="Trend: Break Above High Ray", message="Price broke above swing high on {{ticker}} {{interval}}")
alertcondition(alertTrBreak and trendMode == "Rays (Horizontal)" and not na(loP2) and crossBelowLR, title="Trend: Break Below Low Ray",  message="Price broke below swing low on {{ticker}} {{interval}}")
````

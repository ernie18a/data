# Option Premium Chart - Key Levels

- url: https://www.tradingview.com/script/YUVq3jJl-Option-Premium-Chart-Key-Levels/
- type: indicator
- pine_id: PUB;bf65e08868f346bab6df6904ca305a13
- version: 1.0

## Description

This indicator is made to draw lines on an options contract's premium chart to show key levels the premium may support or resist at. Similar to a normal stock chart, use these levels to analyze at what price to enter, what price to set a stop loss, and what price to target.

The settings have been optimized to detect areas that candle bodies and stems touch multiple times and on a chart with minimal bar history. Typical stocks may have more candle history, but an option contract's chart has less bars and needs to be adjusted to read it differently.

## Source Code

````pine
//@version=6
indicator("Option Premium Key Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// Auto-draws horizontal S/R on an option premium chart, matching a
// hand-drawn look: a spread-out set of white lines at the prices where
// candle wicks & bodies repeatedly meet.
//
// How it differs from a naive "top N pivots":
//   1. Candidate prices come from swing pivots (where price turns).
//   2. Each candidate's STRENGTH = how many bars actually interacted
//      with that price (wick touch, body, or crossed through it) over
//      the whole scan window -> robust even on short-history charts.
//   3. Lines are chosen GREEDILY with a minimum spacing, so you get a
//      distributed ladder of levels instead of 4 lines stacked in one
//      congestion zone.
//   4. Optionally always marks the range high & low.
//
// Tuning for short option charts: keep Pivot strength low (1-3).
// =====================================================================

// ---------- Detection ----------
grpDet   = "Detection"
pivLen   = input.int(3,    "Pivot strength (bars L/R)", minval=1, group=grpDet, tooltip="Bars on each side to confirm a swing. Use 1-3 for short option charts, 5+ for long history.")
mergePct = input.float(0.8,"Merge / touch tolerance (%)", minval=0.05, step=0.05, group=grpDet, tooltip="How close a price counts as 'the same level'. Also the band width used when counting touches.")
spacePct = input.float(3.0,"Min spacing (% of chart range)", minval=0.0, step=0.25, group=grpDet, tooltip="Spread between drawn lines as a fraction of the chart's high-low range, so gaps are even at both high and low premiums. Raise to thin out, lower to allow more.")
minTouch = input.int(2,    "Min re-tests to qualify", minval=1, group=grpDet, tooltip="A level must be approached this many separate times (a long consolidation counts once, three spikes count as three).")
lookback = input.int(1000, "Bars to scan", minval=20, group=grpDet)
incExt   = input.bool(true,"Always mark range high & low", group=grpDet)

// ---------- Drawing ----------
grpDraw  = "Drawing"
maxLines = input.int(12,   "Max levels", minval=1, maxval=100, group=grpDraw)
lineCol  = input.color(color.white, "Line color", group=grpDraw)
lineWid  = input.int(1,    "Line width", minval=1, maxval=5, group=grpDraw)
lineSty  = input.string("Solid","Line style", options=["Solid","Dashed","Dotted"], group=grpDraw)
extendL  = input.bool(true,"Extend across chart", group=grpDraw)
showLbl  = input.bool(false,"Show touch-count labels", group=grpDraw)

styleOf(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ---------- Collect candidate prices from pivots ----------
var float[] cand = array.new_float()

inWin = (last_bar_index - bar_index) <= lookback

ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low,  pivLen, pivLen)

addCand(float p) =>
    if not na(p) and inWin
        merged = false
        n = array.size(cand)
        if n > 0
            i = 0
            while i < n and not merged
                lp = array.get(cand, i)
                if math.abs(p - lp) <= lp * mergePct / 100.0
                    array.set(cand, i, (lp + p) / 2.0)   // nudge toward the cluster center
                    merged := true
                i += 1
        if not merged
            array.push(cand, p)

addCand(ph)
addCand(pl)

// ---------- Strength = number of separate re-tests of a price ----------
// Walk the window oldest->newest and count every transition from
// "not touching" to "touching". A long stay at a level counts once;
// price leaving and returning counts again. This rewards levels that
// were tested repeatedly over time instead of where price merely sat.
countTouch(float price, int scanN) =>
    tol = price * mergePct / 100.0
    c = 0
    prev = false
    for i = scanN to 0
        h = high[i]
        l = low[i]
        cur = (math.abs(h - price) <= tol) or (math.abs(l - price) <= tol) or (l <= price and h >= price)
        if cur and not prev
            c += 1
        prev := cur
    c

// ---------- Draw on the last bar ----------
var line[]  dl  = array.new_line()
var label[] dlb = array.new_label()

if barstate.islast
    // clear previous
    if array.size(dl) > 0
        for i = 0 to array.size(dl) - 1
            line.delete(array.get(dl, i))
        array.clear(dl)
    if array.size(dlb) > 0
        for i = 0 to array.size(dlb) - 1
            label.delete(array.get(dlb, i))
        array.clear(dlb)

    scanN = math.min(lookback, bar_index)

    // chart price range (used for even, range-based line spacing)
    hh = high
    ll = low
    for i = 0 to scanN
        hh := math.max(hh, high[i])
        ll := math.min(ll, low[i])
    spaceDist = (hh - ll) * spacePct / 100.0

    // add the absolute range high & low as candidates
    if incExt
        addCand(hh)
        addCand(ll)

    // score every candidate
    idxArr = array.new_int()
    strArr = array.new_int()
    n = array.size(cand)
    if n > 0
        for i = 0 to n - 1
            p = array.get(cand, i)
            s = countTouch(p, scanN)
            if s >= minTouch
                array.push(idxArr, i)
                array.push(strArr, s)

    // sort by strength, descending
    m = array.size(idxArr)
    if m > 1
        for a = 0 to m - 2
            for b = 0 to m - 2 - a
                if array.get(strArr, b) < array.get(strArr, b + 1)
                    s1 = array.get(strArr, b)
                    array.set(strArr, b, array.get(strArr, b + 1))
                    array.set(strArr, b + 1, s1)
                    i1 = array.get(idxArr, b)
                    array.set(idxArr, b, array.get(idxArr, b + 1))
                    array.set(idxArr, b + 1, i1)

    // greedy pick with minimum spacing
    drawnP = array.new_float()
    leftX  = math.max(bar_index - scanN, 0)
    if m > 0
        for k = 0 to m - 1
            if array.size(drawnP) >= maxLines
                break
            ci    = array.get(idxArr, k)
            price = array.get(cand, ci)
            ok    = true
            ds    = array.size(drawnP)
            if ds > 0
                for j = 0 to ds - 1
                    dp = array.get(drawnP, j)
                    if math.abs(price - dp) <= spaceDist
                        ok := false
                        break
            if ok
                ln = line.new(leftX, price, bar_index, price, xloc=xloc.bar_index, color=lineCol, width=lineWid, style=styleOf(lineSty), extend=extendL ? extend.both : extend.none)
                array.push(dl, ln)
                array.push(drawnP, price)
                if showLbl
                    lb = label.new(bar_index, price, "×" + str.tostring(array.get(strArr, k)), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.gray, 70), textcolor=lineCol, size=size.small)
                    array.push(dlb, lb)
````

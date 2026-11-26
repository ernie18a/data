# Auto S/R + MTF Bias

- url: https://www.tradingview.com/script/CYptEQIk-Auto-S-R-MTF-Bias/
- type: indicator
- pine_id: PUB;139c90a4752d485680d58d63303089a3
- version: 2.0

## Description

Auto S/R + MTF
perform a multi-timeframe analysis. Identify the dominant trend, key structure levels, any momentum shifts, and give me the highest-probability directional bias for a swing trade entry.
Scan the full price history and identify the 3 most significant resistance levels above and 3 support levels below the current price. Rank them by strength, explain why each matters, and tell me how to trade a reaction or breakout at each level.

## Source Code

````pine
//@version=5
// Auto S/R + MAs + TRAMA + SMA cross alerts + chart pattern detection
// Works on any ticker, any timeframe.
indicator("Auto S/R + MAs + Patterns", overlay=true, max_lines_count=100, max_labels_count=100)

// ==================== INPUTS ====================
g1 = "Detection"
pivotLen   = input.int(10,    "Pivot lookback (bars each side)", group=g1, minval=2, maxval=100)
clusterPct = input.float(1.5, "Cluster tolerance %",              group=g1, minval=0.1, maxval=10, step=0.1)
maxAgeBars = input.int(1500,  "Max pivot age (bars)",             group=g1, minval=50, maxval=20000)
maxDistPct = input.float(30,  "Max distance from spot %",         group=g1, minval=5,  maxval=100)
topN       = input.int(3,     "Top N S/R per side",               group=g1, minval=1,  maxval=10)

g2 = "Display"
showLabels  = input.bool(true, "Show S/R labels",     group=g2)
baseOffset  = input.int(30,    "Label offset (bars)", group=g2, minval=2)
stepBars    = input.int(25,    "Stagger step (bars)", group=g2, minval=2)
overlapPct  = input.float(1.0, "Label overlap %",     group=g2, minval=0.1, step=0.1)
lineExtLeft = input.int(300,   "Line history (bars)", group=g2, minval=20)
lineWidth   = input.int(2,     "S/R line width",      group=g2, minval=1, maxval=4)

g3 = "Moving Averages"
showSMA10  = input.bool(true, "Show SMA 10",   group=g3)
showSMA20  = input.bool(true, "Show SMA 20",   group=g3)
showSMA50  = input.bool(true, "Show SMA 50",   group=g3)
showSMA200 = input.bool(true, "Show SMA 200",  group=g3)
showTRAMA  = input.bool(true, "Show TRAMA",    group=g3)
sma10Len   = input.int(10,    "SMA 10 length",  group=g3, minval=1)
sma20Len   = input.int(20,    "SMA 20 length",  group=g3, minval=1)
sma50Len   = input.int(50,    "SMA 50 length",  group=g3, minval=1)
sma200Len  = input.int(200,   "SMA 200 length", group=g3, minval=1)
tramaLen   = input.int(99,    "TRAMA length",   group=g3, minval=5)

g4 = "Patterns"
showPatterns     = input.bool(true, "Detect chart patterns",   group=g4)
patternTol       = input.float(3.0, "Pattern price tolerance %", group=g4, minval=0.5, maxval=10, step=0.1)
flatTol          = input.float(1.0, "Flat/trend tolerance %",    group=g4, minval=0.1, maxval=5,  step=0.1)
maxPatternsShown = input.int(6,     "Max patterns shown at once", group=g4, minval=1, maxval=20)

// ==================== MOVING AVERAGES ====================
sma10  = ta.sma(close, sma10Len)
sma20  = ta.sma(close, sma20Len)
sma50  = ta.sma(close, sma50Len)
sma200 = ta.sma(close, sma200Len)

// ==================== TRAMA ====================
hh_ = math.max(math.sign(nz(ta.change(ta.highest(tramaLen)), 0)), 0)
ll_ = math.max(-math.sign(nz(ta.change(ta.lowest(tramaLen)), 0)), 0)
tc_ = math.pow(ta.sma(math.max(hh_, ll_), tramaLen), 2)
trama = 0.0
trama := nz(trama[1]) + tc_ * (close - nz(trama[1]))

// ==================== PLOTS ====================
plot(showSMA10  ? sma10  : na, "SMA 10",  color=color.new(color.yellow,  0), linewidth=1)
plot(showSMA20  ? sma20  : na, "SMA 20",  color=color.new(color.orange,  0), linewidth=1)
plot(showSMA50  ? sma50  : na, "SMA 50",  color=color.new(color.aqua,    0), linewidth=1)
plot(showSMA200 ? sma200 : na, "SMA 200", color=color.new(color.fuchsia, 0), linewidth=2)
plot(showTRAMA  ? trama  : na, "TRAMA",   color=color.new(color.white,   0), linewidth=2)

// ==================== SMA CROSSOVER ALERTS ====================
x10_20_up  = ta.crossover(sma10,  sma20)
x10_20_dn  = ta.crossunder(sma10, sma20)
x20_50_up  = ta.crossover(sma20,  sma50)
x20_50_dn  = ta.crossunder(sma20, sma50)
x50_200_up = ta.crossover(sma50,  sma200)
x50_200_dn = ta.crossunder(sma50, sma200)
x10_50_up  = ta.crossover(sma10,  sma50)
x10_50_dn  = ta.crossunder(sma10, sma50)

alertcondition(x10_20_up,  "SMA10 crosses ABOVE SMA20",  "{{ticker}} ({{interval}}): SMA10 crossed ABOVE SMA20 at {{close}}")
alertcondition(x10_20_dn,  "SMA10 crosses BELOW SMA20",  "{{ticker}} ({{interval}}): SMA10 crossed BELOW SMA20 at {{close}}")
alertcondition(x10_50_up,  "SMA10 crosses ABOVE SMA50",  "{{ticker}} ({{interval}}): SMA10 crossed ABOVE SMA50 at {{close}}")
alertcondition(x10_50_dn,  "SMA10 crosses BELOW SMA50",  "{{ticker}} ({{interval}}): SMA10 crossed BELOW SMA50 at {{close}}")
alertcondition(x20_50_up,  "SMA20 crosses ABOVE SMA50",  "{{ticker}} ({{interval}}): SMA20 crossed ABOVE SMA50 at {{close}}")
alertcondition(x20_50_dn,  "SMA20 crosses BELOW SMA50",  "{{ticker}} ({{interval}}): SMA20 crossed BELOW SMA50 at {{close}}")
alertcondition(x50_200_up, "GOLDEN CROSS (SMA50 > SMA200)", "{{ticker}} ({{interval}}): GOLDEN CROSS at {{close}}")
alertcondition(x50_200_dn, "DEATH CROSS (SMA50 < SMA200)",  "{{ticker}} ({{interval}}): DEATH CROSS at {{close}}")

plotshape(x50_200_up, "Golden Cross",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.yellow, 0), size=size.small)
plotshape(x50_200_dn, "Death Cross",   style=shape.triangledown, location=location.abovebar, color=color.new(color.red,    0), size=size.small)

// ==================== PIVOT DETECTION ====================
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

// S/R pivot arrays (separate high/low for clustering)
var ph_price = array.new_float()
var ph_bar   = array.new_int()
var ph_vol   = array.new_float()
var pl_price = array.new_float()
var pl_bar   = array.new_int()
var pl_vol   = array.new_float()

if not na(ph)
    array.push(ph_price, ph)
    array.push(ph_bar, bar_index - pivotLen)
    array.push(ph_vol, volume[pivotLen])
if not na(pl)
    array.push(pl_price, pl)
    array.push(pl_bar, bar_index - pivotLen)
    array.push(pl_vol, volume[pivotLen])

// Unified pivot sequence (for pattern detection — preserves time order)
var all_p = array.new_float()
var all_b = array.new_int()
var all_t = array.new_int() // 1 = high, -1 = low

if not na(ph)
    array.push(all_p, ph)
    array.push(all_b, bar_index - pivotLen)
    array.push(all_t, 1)
if not na(pl)
    array.push(all_p, pl)
    array.push(all_b, bar_index - pivotLen)
    array.push(all_t, -1)

// cap unified array size
while array.size(all_p) > 200
    array.shift(all_p)
    array.shift(all_b)
    array.shift(all_t)

// ==================== PATTERN DETECTION ====================
// Pattern flags (series bool — reset every bar for alertcondition)
p_dt   = false  // double top
p_db   = false  // double bottom
p_hs   = false  // head & shoulders
p_ihs  = false  // inverse head & shoulders
p_asct = false  // ascending triangle
p_desct= false  // descending triangle
p_symt = false  // symmetrical triangle
p_rw   = false  // rising wedge
p_fw   = false  // falling wedge

var pattern_lines  = array.new_line()
var pattern_labels = array.new_label()

f_clean_patterns() =>
    while array.size(pattern_lines) > maxPatternsShown * 4
        line.delete(array.shift(pattern_lines))
    while array.size(pattern_labels) > maxPatternsShown
        label.delete(array.shift(pattern_labels))

f_draw_seg(b1, p1, b2, p2, col) =>
    ln = line.new(b1, p1, b2, p2, color=col, width=2, style=line.style_dashed)
    array.push(pattern_lines, ln)

f_draw_label(b, p, txt, col, is_up) =>
    sty = is_up ? label.style_label_up : label.style_label_down
    lbl = label.new(b, p, txt, style=sty, color=col, textcolor=color.white, size=size.small)
    array.push(pattern_labels, lbl)

new_pivot = not na(ph) or not na(pl)
if new_pivot and showPatterns
    nap = array.size(all_p)
    tol = patternTol / 100.0
    ftol = flatTol / 100.0

    // ---------- DOUBLE TOP / BOTTOM (last 3 pivots: H-L-H or L-H-L) ----------
    if nap >= 3
        i1 = nap - 3
        i2 = nap - 2
        i3 = nap - 1
        t1 = array.get(all_t, i1)
        t2 = array.get(all_t, i2)
        t3 = array.get(all_t, i3)
        p1 = array.get(all_p, i1)
        p2 = array.get(all_p, i2)
        p3 = array.get(all_p, i3)
        b1 = array.get(all_b, i1)
        b2 = array.get(all_b, i2)
        b3 = array.get(all_b, i3)

        // Double Top: H - L - H, tops ≈ equal, middle low beneath both
        if t1 == 1 and t2 == -1 and t3 == 1 and math.abs(p3 - p1) / p1 <= tol and p2 < math.min(p1, p3)
            p_dt := true
            f_draw_seg(b1, p1, b2, p2, color.new(color.red, 0))
            f_draw_seg(b2, p2, b3, p3, color.new(color.red, 0))
            f_draw_seg(b1, p1, b3, p3, color.new(color.red, 60))
            f_draw_label(b3, p3, "Double Top", color.new(color.red, 0), false)

        // Double Bottom: L - H - L
        if t1 == -1 and t2 == 1 and t3 == -1 and math.abs(p3 - p1) / p1 <= tol and p2 > math.max(p1, p3)
            p_db := true
            f_draw_seg(b1, p1, b2, p2, color.new(color.green, 0))
            f_draw_seg(b2, p2, b3, p3, color.new(color.green, 0))
            f_draw_seg(b1, p1, b3, p3, color.new(color.green, 60))
            f_draw_label(b3, p3, "Double Bottom", color.new(color.green, 0), true)

    // ---------- HEAD & SHOULDERS (last 5 pivots: H-L-H-L-H or L-H-L-H-L) ----------
    if nap >= 5
        i1 = nap - 5
        i2 = nap - 4
        i3 = nap - 3
        i4 = nap - 2
        i5 = nap - 1
        t1 = array.get(all_t, i1)
        t2 = array.get(all_t, i2)
        t3 = array.get(all_t, i3)
        t4 = array.get(all_t, i4)
        t5 = array.get(all_t, i5)
        p1 = array.get(all_p, i1)
        p2 = array.get(all_p, i2)
        p3 = array.get(all_p, i3)
        p4 = array.get(all_p, i4)
        p5 = array.get(all_p, i5)
        b1 = array.get(all_b, i1)
        b2 = array.get(all_b, i2)
        b3 = array.get(all_b, i3)
        b4 = array.get(all_b, i4)
        b5 = array.get(all_b, i5)

        // H&S top: LS-n1-Head-n2-RS, head highest, shoulders ≈ equal, necklines ≈ equal
        if t1 == 1 and t2 == -1 and t3 == 1 and t4 == -1 and t5 == 1 and p3 > p1 and p3 > p5 and math.abs(p5 - p1) / p1 <= tol and math.abs(p4 - p2) / p2 <= tol * 1.5
            p_hs := true
            f_draw_seg(b1, p1, b2, p2, color.new(color.red, 0))
            f_draw_seg(b2, p2, b3, p3, color.new(color.red, 0))
            f_draw_seg(b3, p3, b4, p4, color.new(color.red, 0))
            f_draw_seg(b4, p4, b5, p5, color.new(color.red, 0))
            f_draw_seg(b2, p2, b4, p4, color.new(color.orange, 30))  // neckline
            f_draw_label(b3, p3, "H&S Top", color.new(color.red, 0), false)

        // Inverse H&S
        if t1 == -1 and t2 == 1 and t3 == -1 and t4 == 1 and t5 == -1 and p3 < p1 and p3 < p5 and math.abs(p5 - p1) / p1 <= tol and math.abs(p4 - p2) / p2 <= tol * 1.5
            p_ihs := true
            f_draw_seg(b1, p1, b2, p2, color.new(color.green, 0))
            f_draw_seg(b2, p2, b3, p3, color.new(color.green, 0))
            f_draw_seg(b3, p3, b4, p4, color.new(color.green, 0))
            f_draw_seg(b4, p4, b5, p5, color.new(color.green, 0))
            f_draw_seg(b2, p2, b4, p4, color.new(color.lime, 30))
            f_draw_label(b3, p3, "Inv H&S", color.new(color.green, 0), true)

    // ---------- TRIANGLES & WEDGES (last 4 pivots, alternating) ----------
    if nap >= 4
        j1 = nap - 4
        j2 = nap - 3
        j3 = nap - 2
        j4 = nap - 1
        s1 = array.get(all_t, j1)
        s2 = array.get(all_t, j2)
        s3 = array.get(all_t, j3)
        s4 = array.get(all_t, j4)
        q1 = array.get(all_p, j1)
        q2 = array.get(all_p, j2)
        q3 = array.get(all_p, j3)
        q4 = array.get(all_p, j4)
        c1 = array.get(all_b, j1)
        c2 = array.get(all_b, j2)
        c3 = array.get(all_b, j3)
        c4 = array.get(all_b, j4)

        // alternating (H-L-H-L or L-H-L-H)
        if s1 != s2 and s2 != s3 and s3 != s4
            // extract H1, H2, L1, L2 in time order
            h1 = s1 == 1 ? q1 : q2
            h2 = s3 == 1 ? q3 : q4
            l1 = s1 == -1 ? q1 : q2
            l2 = s3 == -1 ? q3 : q4
            hb1 = s1 == 1 ? c1 : c2
            hb2 = s3 == 1 ? c3 : c4
            lb1 = s1 == -1 ? c1 : c2
            lb2 = s3 == -1 ? c3 : c4

            hdiff = (h2 - h1) / h1
            ldiff = (l2 - l1) / l1

            // Ascending triangle: flat highs + rising lows
            if math.abs(hdiff) < ftol and ldiff > ftol
                p_asct := true
                f_draw_seg(hb1, h1, hb2, h2, color.new(color.green, 0))
                f_draw_seg(lb1, l1, lb2, l2, color.new(color.green, 0))
                f_draw_label(c4, math.max(h1, h2), "Asc Triangle", color.new(color.green, 0), false)

            // Descending triangle
            else if math.abs(ldiff) < ftol and hdiff < -ftol
                p_desct := true
                f_draw_seg(hb1, h1, hb2, h2, color.new(color.red, 0))
                f_draw_seg(lb1, l1, lb2, l2, color.new(color.red, 0))
                f_draw_label(c4, math.max(h1, h2), "Desc Triangle", color.new(color.red, 0), false)

            // Symmetrical triangle
            else if hdiff < -ftol and ldiff > ftol
                p_symt := true
                f_draw_seg(hb1, h1, hb2, h2, color.new(color.yellow, 0))
                f_draw_seg(lb1, l1, lb2, l2, color.new(color.yellow, 0))
                f_draw_label(c4, math.max(h1, h2), "Sym Triangle", color.new(color.yellow, 0), false)

            // Rising wedge: both up, lows rising faster than highs (bearish)
            else if hdiff > ftol and ldiff > ftol and ldiff > hdiff
                p_rw := true
                f_draw_seg(hb1, h1, hb2, h2, color.new(color.red, 0))
                f_draw_seg(lb1, l1, lb2, l2, color.new(color.red, 0))
                f_draw_label(c4, math.max(h1, h2), "Rising Wedge", color.new(color.red, 0), false)

            // Falling wedge: both down, highs falling faster than lows (bullish)
            else if hdiff < -ftol and ldiff < -ftol and math.abs(hdiff) > math.abs(ldiff)
                p_fw := true
                f_draw_seg(hb1, h1, hb2, h2, color.new(color.green, 0))
                f_draw_seg(lb1, l1, lb2, l2, color.new(color.green, 0))
                f_draw_label(c4, math.min(l1, l2), "Falling Wedge", color.new(color.green, 0), true)

    f_clean_patterns()

// Pattern alert conditions
alertcondition(p_dt,    "Double Top",             "{{ticker}} ({{interval}}): Double Top detected at {{close}}")
alertcondition(p_db,    "Double Bottom",          "{{ticker}} ({{interval}}): Double Bottom detected at {{close}}")
alertcondition(p_hs,    "Head & Shoulders",       "{{ticker}} ({{interval}}): H&S Top detected at {{close}}")
alertcondition(p_ihs,   "Inverse H&S",            "{{ticker}} ({{interval}}): Inverse H&S detected at {{close}}")
alertcondition(p_asct,  "Ascending Triangle",     "{{ticker}} ({{interval}}): Ascending Triangle at {{close}}")
alertcondition(p_desct, "Descending Triangle",    "{{ticker}} ({{interval}}): Descending Triangle at {{close}}")
alertcondition(p_symt,  "Symmetrical Triangle",   "{{ticker}} ({{interval}}): Symmetrical Triangle at {{close}}")
alertcondition(p_rw,    "Rising Wedge",           "{{ticker}} ({{interval}}): Rising Wedge (bearish) at {{close}}")
alertcondition(p_fw,    "Falling Wedge",          "{{ticker}} ({{interval}}): Falling Wedge (bullish) at {{close}}")

// ==================== S/R LEVEL DRAWING ====================
var line_ids  = array.new_line()
var label_ids = array.new_label()

if barstate.islast
    nl = array.size(line_ids)
    if nl > 0
        for i = 0 to nl - 1
            line.delete(array.get(line_ids, i))
    nlb = array.size(label_ids)
    if nlb > 0
        for i = 0 to nlb - 1
            label.delete(array.get(label_ids, i))
    array.clear(line_ids)
    array.clear(label_ids)

    spot = close

    // RESISTANCE
    rp = array.new_float()
    rb = array.new_int()
    rv = array.new_float()
    nph = array.size(ph_price)
    if nph > 0
        for i = 0 to nph - 1
            pr = array.get(ph_price, i)
            pb = array.get(ph_bar, i)
            pv = array.get(ph_vol, i)
            if pr > spot and (bar_index - pb) <= maxAgeBars and (math.abs(pr - spot) / spot * 100) <= maxDistPct
                array.push(rp, pr)
                array.push(rb, pb)
                array.push(rv, pv)

    n = array.size(rp)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - 2 - i
                if array.get(rp, j) > array.get(rp, j + 1)
                    tp1 = array.get(rp, j)
                    array.set(rp, j, array.get(rp, j + 1))
                    array.set(rp, j + 1, tp1)
                    tb1 = array.get(rb, j)
                    array.set(rb, j, array.get(rb, j + 1))
                    array.set(rb, j + 1, tb1)
                    tv1 = array.get(rv, j)
                    array.set(rv, j, array.get(rv, j + 1))
                    array.set(rv, j + 1, tv1)

    rc_price   = array.new_float()
    rc_touches = array.new_int()
    rc_last    = array.new_int()
    rc_vol     = array.new_float()
    if n > 0
        cur_sum    = array.get(rp, 0)
        cur_cnt    = 1
        cur_last_b = array.get(rb, 0)
        cur_maxv   = array.get(rv, 0)
        cur_ref    = array.get(rp, 0)
        if n > 1
            for i = 1 to n - 1
                p = array.get(rp, i)
                b = array.get(rb, i)
                v = array.get(rv, i)
                if (math.abs(p - cur_ref) / cur_ref * 100) <= clusterPct
                    cur_sum    := cur_sum + p
                    cur_cnt    := cur_cnt + 1
                    cur_last_b := math.max(cur_last_b, b)
                    cur_maxv   := math.max(cur_maxv, v)
                else
                    array.push(rc_price, cur_sum / cur_cnt)
                    array.push(rc_touches, cur_cnt)
                    array.push(rc_last, cur_last_b)
                    array.push(rc_vol, cur_maxv)
                    cur_sum    := p
                    cur_cnt    := 1
                    cur_last_b := b
                    cur_maxv   := v
                    cur_ref    := p
        array.push(rc_price, cur_sum / cur_cnt)
        array.push(rc_touches, cur_cnt)
        array.push(rc_last, cur_last_b)
        array.push(rc_vol, cur_maxv)

    rc_score = array.new_float()
    nrc = array.size(rc_price)
    if nrc > 0
        for i = 0 to nrc - 1
            t   = array.get(rc_touches, i)
            lb  = array.get(rc_last, i)
            v   = array.get(rc_vol, i)
            p   = array.get(rc_price, i)
            age = bar_index - lb
            rec = 1.0 / (1.0 + age / 100.0)
            vs  = math.log(v + 1) / 18.0
            px  = 1.0 / (1.0 + math.abs(p - spot) / spot / 0.05)
            array.push(rc_score, t * 1.5 + rec * 4.0 + vs + px * 1.5)
    if nrc > 1
        for i = 0 to nrc - 2
            for j = 0 to nrc - 2 - i
                if array.get(rc_score, j) < array.get(rc_score, j + 1)
                    ts = array.get(rc_score, j)
                    array.set(rc_score, j, array.get(rc_score, j + 1))
                    array.set(rc_score, j + 1, ts)
                    tp = array.get(rc_price, j)
                    array.set(rc_price, j, array.get(rc_price, j + 1))
                    array.set(rc_price, j + 1, tp)
                    tt = array.get(rc_touches, j)
                    array.set(rc_touches, j, array.get(rc_touches, j + 1))
                    array.set(rc_touches, j + 1, tt)
                    tl = array.get(rc_last, j)
                    array.set(rc_last, j, array.get(rc_last, j + 1))
                    array.set(rc_last, j + 1, tl)

    keep_r = math.min(topN, nrc)

    // SUPPORT
    sp = array.new_float()
    sb = array.new_int()
    sv = array.new_float()
    npl = array.size(pl_price)
    if npl > 0
        for i = 0 to npl - 1
            pr = array.get(pl_price, i)
            pb = array.get(pl_bar, i)
            pv = array.get(pl_vol, i)
            if pr < spot and (bar_index - pb) <= maxAgeBars and (math.abs(pr - spot) / spot * 100) <= maxDistPct
                array.push(sp, pr)
                array.push(sb, pb)
                array.push(sv, pv)

    n2 = array.size(sp)
    if n2 > 1
        for i = 0 to n2 - 2
            for j = 0 to n2 - 2 - i
                if array.get(sp, j) > array.get(sp, j + 1)
                    tp2 = array.get(sp, j)
                    array.set(sp, j, array.get(sp, j + 1))
                    array.set(sp, j + 1, tp2)
                    tb2 = array.get(sb, j)
                    array.set(sb, j, array.get(sb, j + 1))
                    array.set(sb, j + 1, tb2)
                    tv2 = array.get(sv, j)
                    array.set(sv, j, array.get(sv, j + 1))
                    array.set(sv, j + 1, tv2)

    sc_price   = array.new_float()
    sc_touches = array.new_int()
    sc_last    = array.new_int()
    sc_vol     = array.new_float()
    if n2 > 0
        cs_sum    = array.get(sp, 0)
        cs_cnt    = 1
        cs_last_b = array.get(sb, 0)
        cs_maxv   = array.get(sv, 0)
        cs_ref    = array.get(sp, 0)
        if n2 > 1
            for i = 1 to n2 - 1
                p = array.get(sp, i)
                b = array.get(sb, i)
                v = array.get(sv, i)
                if (math.abs(p - cs_ref) / cs_ref * 100) <= clusterPct
                    cs_sum    := cs_sum + p
                    cs_cnt    := cs_cnt + 1
                    cs_last_b := math.max(cs_last_b, b)
                    cs_maxv   := math.max(cs_maxv, v)
                else
                    array.push(sc_price, cs_sum / cs_cnt)
                    array.push(sc_touches, cs_cnt)
                    array.push(sc_last, cs_last_b)
                    array.push(sc_vol, cs_maxv)
                    cs_sum    := p
                    cs_cnt    := 1
                    cs_last_b := b
                    cs_maxv   := v
                    cs_ref    := p
        array.push(sc_price, cs_sum / cs_cnt)
        array.push(sc_touches, cs_cnt)
        array.push(sc_last, cs_last_b)
        array.push(sc_vol, cs_maxv)

    sc_score = array.new_float()
    nsc = array.size(sc_price)
    if nsc > 0
        for i = 0 to nsc - 1
            t   = array.get(sc_touches, i)
            lb  = array.get(sc_last, i)
            v   = array.get(sc_vol, i)
            p   = array.get(sc_price, i)
            age = bar_index - lb
            rec = 1.0 / (1.0 + age / 100.0)
            vs  = math.log(v + 1) / 18.0
            px  = 1.0 / (1.0 + math.abs(p - spot) / spot / 0.05)
            array.push(sc_score, t * 1.5 + rec * 4.0 + vs + px * 1.5)
    if nsc > 1
        for i = 0 to nsc - 2
            for j = 0 to nsc - 2 - i
                if array.get(sc_score, j) < array.get(sc_score, j + 1)
                    ts = array.get(sc_score, j)
                    array.set(sc_score, j, array.get(sc_score, j + 1))
                    array.set(sc_score, j + 1, ts)
                    tp = array.get(sc_price, j)
                    array.set(sc_price, j, array.get(sc_price, j + 1))
                    array.set(sc_price, j + 1, tp)
                    tt = array.get(sc_touches, j)
                    array.set(sc_touches, j, array.get(sc_touches, j + 1))
                    array.set(sc_touches, j + 1, tt)
                    tl = array.get(sc_last, j)
                    array.set(sc_last, j, array.get(sc_last, j + 1))
                    array.set(sc_last, j + 1, tl)

    keep_s = math.min(topN, nsc)

    all_p_ = array.new_float()
    all_n_ = array.new_string()
    all_c_ = array.new_color()

    if keep_r > 0
        for i = 0 to keep_r - 1
            array.push(all_p_, array.get(rc_price, i))
            array.push(all_n_, "R" + str.tostring(i + 1) + " (" + str.tostring(array.get(rc_touches, i)) + "x)")
            array.push(all_c_, color.new(color.red, 0))
    if keep_s > 0
        for i = 0 to keep_s - 1
            array.push(all_p_, array.get(sc_price, i))
            array.push(all_n_, "S" + str.tostring(i + 1) + " (" + str.tostring(array.get(sc_touches, i)) + "x)")
            array.push(all_c_, color.new(color.green, 0))

    na_all = array.size(all_p_)
    if na_all > 1
        for i = 0 to na_all - 2
            for j = 0 to na_all - 2 - i
                if array.get(all_p_, j) > array.get(all_p_, j + 1)
                    tp = array.get(all_p_, j)
                    array.set(all_p_, j, array.get(all_p_, j + 1))
                    array.set(all_p_, j + 1, tp)
                    tn = array.get(all_n_, j)
                    array.set(all_n_, j, array.get(all_n_, j + 1))
                    array.set(all_n_, j + 1, tn)
                    tc = array.get(all_c_, j)
                    array.set(all_c_, j, array.get(all_c_, j + 1))
                    array.set(all_c_, j + 1, tc)

    prev_price = -1.0
    prev_off   = 0
    if na_all > 0
        for i = 0 to na_all - 1
            p  = array.get(all_p_, i)
            nm = array.get(all_n_, i)
            c  = array.get(all_c_, i)
            off = 0
            if prev_price > 0
                gap = math.abs(p - prev_price) / p * 100.0
                if gap < overlapPct
                    off := prev_off + stepBars
            lid = line.new(bar_index - lineExtLeft, p, bar_index + baseOffset + off, p, extend=extend.right, color=c, style=line.style_solid, width=lineWidth)
            array.push(line_ids, lid)
            if showLabels
                txt = nm + "  " + str.tostring(p, "#.##")
                tid = label.new(bar_index + baseOffset + off, p, txt, style=label.style_label_left, color=c, textcolor=color.white, size=size.small)
                array.push(label_ids, tid)
            prev_price := p
            prev_off   := off
````

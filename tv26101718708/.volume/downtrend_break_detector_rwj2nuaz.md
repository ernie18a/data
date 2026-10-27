# Downtrend Break Detector

- url: https://www.tradingview.com/script/RwJ2nuAZ-Downtrend-Break-Detector/
- type: indicator
- pine_id: PUB;fff11fe0be4640bb8573a75d3db2804b
- version: 1.0

## Description

Automatically detects and draws descending trendlines from pivot highs, then fires a signal the moment price breaks above with volume confirmation.

Unlike simple moving average crossovers, this indicator identifies actual market structure — connecting two or more pivot highs forming a valid downtrend, then waiting for a decisive breakout candle backed by volume surge.

How it works:

Scans historical pivot highs to find the best-fit descending trendline

Validates the line with configurable touch count, pierce tolerance, and anchor drop requirements

Fires only when price closes above the line with a volume surge AND a higher-low structure is intact

Assigns a quality score to every signal based on touches, spacing, recency, and structure — filter out weak signals with the minimum score setting

Signal features:

▲ Arrow marks the exact entry bar

Info label shows score, SL%, and T1/T2/T3 targets

ATR-based or fixed % SL/TP levels — fully configurable from settings, adapts to any trading style

Trailing stop logic: moves to breakeven at T1, to T1 at T2

Built-in benchmark table tracks win rate and average R across all historical signals

Best used on: Daily timeframe, any liquid asset — stocks, crypto, forex, indices.

## Source Code

````pine
//@version=6
indicator("📐 Downtrend Break", overlay=true, max_labels_count=500, max_lines_count=500)

// ── TRENDLINE ─────────────────────────────────────────────────────────────────
pivotLen      = input.int(10,    "Pivot lookback",             group="Trendline", minval=3)
maxHistory    = input.int(300,   "Max history (bars)",         group="Trendline", minval=50)
minAnchorBars = input.int(40,    "Min anchor span (bars)",     group="Trendline", minval=10)
maxRightAge   = input.int(100,   "Max right anchor age",       group="Trendline", minval=10)
touchTol      = input.float(3.0, "Touch tolerance %",          group="Trendline", minval=0.5, step=0.5)
minTouches    = input.int(2,     "Min touches",                group="Trendline", minval=2, maxval=5)
maxTouches    = input.int(10,    "Max touches",                group="Trendline", minval=3)
maxViolations = input.int(3,     "Max violations",             group="Trendline", minval=0)
pierceTol     = input.float(3.0, "Pierce tolerance %",         group="Trendline", minval=0.5, step=0.5)
minDrop       = input.float(10.0,"Min anchor drop %",          group="Trendline", minval=3.0, step=1.0)
breakBuffer   = input.float(0.8, "Break buffer %",             group="Trendline", minval=0.1, step=0.1)
showAllLines  = input.bool(true,  "Show historical lines",     group="Trendline")

// ── VOLUME ────────────────────────────────────────────────────────────────────
volLen        = input.int(20,   "Volume MA length",    group="Volume", minval=5)
volMult       = input.float(1.1,"Volume surge ×",      group="Volume", minval=0.5, step=0.1)

// ── SIGNAL QUALITY ────────────────────────────────────────────────────────────
minScore      = input.int(30,    "Min quality score (0–100)", group="Signal Quality")
autoConfirm   = input.bool(true, "Auto confirm bars",         group="Signal Quality")
confirmBars   = input.int(2,     "Confirm bars (manual)",     group="Signal Quality", minval=1, maxval=5)

// ── BENCHMARK ─────────────────────────────────────────────────────────────────
useAtr        = input.bool(true,  "Use ATR levels (off = fixed %)",    group="Benchmark")
atrLen        = input.int(14,    "   ATR length",                      group="Benchmark", minval=5)
slAtrMult     = input.float(2.0, "   SL ×ATR",                         group="Benchmark", step=0.5, minval=0.5)
tp1AtrMult    = input.float(3.0, "   TP1 ×ATR",                        group="Benchmark", step=0.5, minval=0.5)
tp2AtrMult    = input.float(5.0, "   TP2 ×ATR",                        group="Benchmark", step=0.5, minval=0.5)
tp3AtrMult    = input.float(8.0, "   TP3 ×ATR",                        group="Benchmark", step=0.5, minval=0.5)
slPct         = input.float(5.0, "   SL % (if ATR off)",               group="Benchmark", step=0.5, minval=0.5)
tp1Pct        = input.float(5.0, "   TP1 % (if ATR off)",              group="Benchmark", step=0.5, minval=0.5)
tp2Pct        = input.float(10.0,"   TP2 % (if ATR off)",              group="Benchmark", step=0.5, minval=0.5)
tp3Pct        = input.float(20.0,"   TP3 % (if ATR off)",              group="Benchmark", step=0.5, minval=0.5)
showBenchmark = input.bool(true,  "Show benchmark table",               group="Benchmark")

// ── DISPLAY ───────────────────────────────────────────────────────────────────
showLabel     = input.bool(true, "Show signal info label", group="Display")

// ── PIVOT STORAGE ─────────────────────────────────────────────────────────────
var int[]   pivBars = array.new_int(0)
var float[] pivVals = array.new_float(0)

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)

var float lastPivotLow = na
var float prevPivotLow = na

if not na(pl)
    prevPivotLow := lastPivotLow
    lastPivotLow := pl

if not na(ph)
    array.unshift(pivBars, bar_index - pivotLen)
    array.unshift(pivVals, ph)
    while array.size(pivBars) > 0
        lastIdx = array.size(pivBars) - 1
        if (bar_index - array.get(pivBars, lastIdx)) > maxHistory
            array.pop(pivBars)
            array.pop(pivVals)
        else
            break

// ── SOFT RIGHT ANCHOR ─────────────────────────────────────────────────────────
softRightVal = ta.highest(high, pivotLen)
softRightBar = bar_index
for i = 0 to pivotLen - 1
    if high[i] == softRightVal
        softRightBar := bar_index - i
        break

// ── ATR ───────────────────────────────────────────────────────────────────────
atrVal = ta.atr(atrLen)

// ── TRENDLINE STATE ───────────────────────────────────────────────────────────
var float saved_slope        = na
var int   saved_left         = na
var float saved_lval         = na
var int   saved_right        = na
var bool  saved_valid        = false
var bool  line_fired         = false
var int   saved_touches      = 0
var float saved_drop         = 0.0
var int   saved_span         = 0
var float saved_touchSpacing = 0.0
var int   saved_lastTouchAge = 0

var line   activeLine    = na
var line[] historicLines = array.new<line>(0)

// ── PER-SIGNAL TRACKING ───────────────────────────────────────────────────────
var int[]   openEntBars  = array.new_int(0)
var float[] openEntries  = array.new_float(0)
var float[] openSL       = array.new_float(0)
var float[] openTP1      = array.new_float(0)
var float[] openTP2      = array.new_float(0)
var float[] openTP3      = array.new_float(0)
var float[] openTrailSL  = array.new_float(0)
var bool[]  hitTP1arr    = array.new_bool(0)
var bool[]  hitTP2arr    = array.new_bool(0)
var label[] openArrows   = array.new<label>(0)
var label[] openLabels   = array.new<label>(0)
var float[] sigTp1R      = array.new_float(0)
var float[] sigTp2R      = array.new_float(0)
var float[] sigTp3R      = array.new_float(0)

// ── BENCHMARK COUNTERS ────────────────────────────────────────────────────────
var int   bench_total  = 0
var int   bench_tp1    = 0
var int   bench_tp2    = 0
var int   bench_tp3    = 0
var int   bench_sl     = 0
var int   bench_open   = 0
var float bench_totalR = 0.0

// ── SCORING ───────────────────────────────────────────────────────────────────
scoreTouches(t) =>
    t >= 5 ? 35 : t == 4 ? 28 : t == 3 ? 18 : t == 2 ? 8 : 0

scoreSpacing(sp, span) =>
    span <= 0 ? 0 : sp / span <= 0.05 ? 25 : sp / span <= 0.10 ? 20 : sp / span <= 0.18 ? 14 : sp / span <= 0.28 ? 8 : 3

scoreRecency(age) =>
    age <= 5 ? 25 : age <= 15 ? 20 : age <= 30 ? 14 : age <= 60 ? 8 : 3

scoreHL(lo, plo) =>
    na(lo) or na(plo) ? 0 : lo > plo * 1.02 ? 15 : lo > plo ? 8 : 0

// ── LINE SEARCH ───────────────────────────────────────────────────────────────
searchBestLine(useRightBar, useRightVal) =>
    n = array.size(pivBars)
    best_span = 0
    r_left = int(na), r_right = int(na), r_slope = float(na), r_lval = float(na)
    r_touches = 0, r_drop = 0.0, r_spacing = 0.0, r_lastTchAge = 0

    if n >= 1
        for a = 0 to n - 1
            if a >= array.size(pivBars)
                break
            left_bar = array.get(pivBars, a)
            left_val = array.get(pivVals, a)

            if n >= 2
                for b = a + 1 to n - 1
                    if b >= array.size(pivBars)
                        break
                    right_bar = array.get(pivBars, b)
                    right_val = array.get(pivVals, b)
                    if left_bar >= right_bar
                        continue
                    span    = right_bar - left_bar
                    dropPct = (left_val - right_val) / left_val * 100
                    if left_val <= right_val or span < minAnchorBars or dropPct < minDrop
                        continue
                    ol  = bar_index - left_bar
                    or_ = bar_index - right_bar
                    if ol > 490 or ol <= 0 or or_ < 0
                        continue
                    sc = (right_val - left_val) / float(span)
                    viols = 0
                    for k = or_ + 1 to ol - 1
                        if k >= 0 and k <= 490
                            if high[k] > (left_val + sc * float((bar_index - k) - left_bar)) * (1.0 + pierceTol / 100.0)
                                viols += 1
                    pivT = 0, ltb = -1
                    tBars = array.new_int(0)
                    for p = 0 to n - 1
                        if p >= array.size(pivBars)
                            break
                        pb = array.get(pivBars, p)
                        pv = array.get(pivVals, p)
                        if pb <= left_bar or pb >= right_bar
                            continue
                        lp = left_val + sc * float(pb - left_bar)
                        if pv >= lp * (1.0 - touchTol / 100.0) and pv <= lp * (1.0 + pierceTol / 100.0)
                            pivT += 1
                            array.push(tBars, pb)
                            if ltb < 0
                                ltb := pb
                    sp2 = 0.0
                    nT  = array.size(tBars)
                    if nT >= 2
                        gs = array.new_float(0)
                        for g = 0 to nT - 2
                            array.push(gs, float(math.abs(array.get(tBars, g + 1) - array.get(tBars, g))))
                        mg = 0.0
                        for g = 0 to array.size(gs) - 1
                            mg += array.get(gs, g)
                        mg /= array.size(gs)
                        vg = 0.0
                        for g = 0 to array.size(gs) - 1
                            d = array.get(gs, g) - mg
                            vg += d * d
                        vg /= array.size(gs)
                        sp2 := math.sqrt(vg)
                    la = ltb >= 0 ? bar_index - ltb : 999
                    if viols <= maxViolations and pivT >= minTouches and pivT <= maxTouches and span > best_span
                        best_span := span
                        r_left := left_bar, r_right := right_bar, r_slope := sc, r_lval := left_val
                        r_touches := pivT, r_drop := dropPct, r_spacing := sp2, r_lastTchAge := la

            if left_bar < useRightBar and useRightVal < left_val
                span    = useRightBar - left_bar
                dropPct = (left_val - useRightVal) / left_val * 100
                if span >= minAnchorBars and dropPct >= minDrop
                    ol  = bar_index - left_bar
                    or_ = bar_index - useRightBar
                    if ol <= 490 and ol > 0 and or_ >= 0
                        sc = (useRightVal - left_val) / float(span)
                        viols = 0
                        for k = or_ + 1 to ol - 1
                            if k >= 0 and k <= 490
                                if high[k] > (left_val + sc * float((bar_index - k) - left_bar)) * (1.0 + pierceTol / 100.0)
                                    viols += 1
                        pivT = 0, ltb = -1
                        tBars = array.new_int(0)
                        for p = 0 to n - 1
                            if p >= array.size(pivBars)
                                break
                            pb = array.get(pivBars, p)
                            pv = array.get(pivVals, p)
                            if pb <= left_bar or pb >= useRightBar
                                continue
                            lp = left_val + sc * float(pb - left_bar)
                            if pv >= lp * (1.0 - touchTol / 100.0) and pv <= lp * (1.0 + pierceTol / 100.0)
                                pivT += 1
                                array.push(tBars, pb)
                                if ltb < 0
                                    ltb := pb
                        sp2 = 0.0
                        nT  = array.size(tBars)
                        if nT >= 2
                            gs = array.new_float(0)
                            for g = 0 to nT - 2
                                array.push(gs, float(math.abs(array.get(tBars, g + 1) - array.get(tBars, g))))
                            mg = 0.0
                            for g = 0 to array.size(gs) - 1
                                mg += array.get(gs, g)
                            mg /= array.size(gs)
                            vg = 0.0
                            for g = 0 to array.size(gs) - 1
                                d = array.get(gs, g) - mg
                                vg += d * d
                            vg /= array.size(gs)
                            sp2 := math.sqrt(vg)
                        la = ltb >= 0 ? bar_index - ltb : 999
                        if viols <= maxViolations and pivT >= minTouches and pivT <= maxTouches and span > best_span
                            best_span := span
                            r_left := left_bar, r_right := useRightBar, r_slope := sc, r_lval := left_val
                            r_touches := pivT, r_drop := dropPct, r_spacing := sp2, r_lastTchAge := la

    [best_span > 0, r_left, r_right, r_slope, r_lval, r_touches, r_drop, r_spacing, r_lastTchAge]

// ── TRIGGER SEARCH ────────────────────────────────────────────────────────────
var int lastSoftBar = na
softAnchorChanged = softRightBar != lastSoftBar
if softAnchorChanged
    lastSoftBar := softRightBar

if not na(ph) or softAnchorChanged
    [v, fl, fr, fsl, flv, ft, fd, fsp, fla] = searchBestLine(softRightBar, softRightVal)
    if v
        if fl != saved_left
            line_fired := false
        saved_left := fl, saved_right := fr, saved_slope := fsl, saved_lval := flv
        saved_valid := true, saved_touches := ft, saved_drop := fd
        saved_span := fr - fl, saved_touchSpacing := fsp, saved_lastTouchAge := fla
    else
        saved_valid := false
        line_fired  := false

// ── PROJECTIONS & BREAK CONDITIONS ───────────────────────────────────────────
tl_now    = saved_valid and not na(saved_slope) ? saved_lval + saved_slope * float(bar_index - saved_left)      : na
tl_future = saved_valid and not na(saved_slope) ? saved_lval + saved_slope * float(bar_index + 30 - saved_left) : na

volMA    = ta.sma(volume, volLen)
volSurge = volume / volMA >= volMult

anchorRecent = not na(saved_right) and (bar_index - saved_right) <= maxRightAge
recentLowOk  = not na(lastPivotLow) and close > lastPivotLow * 0.95

s1 = scoreTouches(saved_touches)
s2 = scoreSpacing(saved_touchSpacing, saved_span)
s3 = scoreRecency(saved_lastTouchAge)
s4 = scoreHL(lastPivotLow, prevPivotLow)
sigScore  = s1 + s2 + s3 + s4
scorePass = sigScore >= minScore

dynConfirm = autoConfirm ? (sigScore >= 65 ? 1 : 2) : confirmBars
barsAbove  = 0
if saved_valid and not na(saved_slope)
    for j = 0 to dynConfirm - 1
        laj = saved_lval + saved_slope * float((bar_index - j) - saved_left)
        if close[j] > laj * (1.0 + breakBuffer / 100.0) and close[j] > open[j]
            barsAbove += 1
        else
            break

breakAbove  = saved_valid and not line_fired and anchorRecent and recentLowOk and scorePass and not na(tl_now) and barsAbove >= dynConfirm and volSurge
breakSignal = breakAbove and not breakAbove[1]

// ── ACTIVE TRENDLINE DRAW ─────────────────────────────────────────────────────
if saved_valid and not na(tl_future) and not line_fired
    line.delete(activeLine)
    activeLine := line.new(x1=saved_left, y1=saved_lval, x2=bar_index + 30, y2=tl_future,
      color=color.new(color.white, 15), width=2, extend=extend.none)
else if line_fired
    line.delete(activeLine)
    activeLine := na

// ── SIGNAL FIRE ───────────────────────────────────────────────────────────────
if breakSignal
    line_fired  := true
    bench_total += 1
    bench_open  += 1

    entryAtr = atrVal
    riskAmt  = useAtr ? slAtrMult * entryAtr : close * (slPct / 100.0)

    slPrice  = close - riskAmt
    tp1Price = useAtr ? close + tp1AtrMult * entryAtr : close * (1.0 + tp1Pct / 100.0)
    tp2Price = useAtr ? close + tp2AtrMult * entryAtr : close * (1.0 + tp2Pct / 100.0)
    tp3Price = useAtr ? close + tp3AtrMult * entryAtr : close * (1.0 + tp3Pct / 100.0)

    tp1R = (tp1Price - close) / riskAmt
    tp2R = (tp2Price - close) / riskAmt
    tp3R = (tp3Price - close) / riskAmt

    slD  = math.round(riskAmt            / close * 1000) / 10
    t1D  = math.round((tp1Price - close) / close * 1000) / 10
    t2D  = math.round((tp2Price - close) / close * 1000) / 10
    t3D  = math.round((tp3Price - close) / close * 1000) / 10

    if showAllLines
        breakY = saved_lval + saved_slope * float(bar_index - saved_left)
        hl = line.new(x1=saved_left, y1=saved_lval, x2=bar_index, y2=breakY,
               color=color.new(color.aqua, 40), width=1, style=line.style_dashed)
        array.push(historicLines, hl)
        if array.size(historicLines) > 200
            line.delete(array.shift(historicLines))

    // ── ARROW (always shown, no background box) ────────────────────────────
    arw = label.new(bar_index, na,
      text      = "▲",
      color     = color.new(color.black, 100),
      textcolor = color.white,
      style     = label.style_none,
      size      = size.huge,
      yloc      = yloc.belowbar)
    array.push(openArrows, arw)

    // ── INFO LABEL (toggle-controlled) ────────────────────────────────────
    if showLabel
        lbl = label.new(bar_index, na,
          text      = "📐 Score " + str.tostring(sigScore) + "  |  SL -" + str.tostring(slD) + "%  T1 +" + str.tostring(t1D) + "%  T2 +" + str.tostring(t2D) + "%  T3 +" + str.tostring(t3D) + "%\n⏳",
          color     = color.new(color.black, 0),
          textcolor = color.white,
          style     = label.style_label_upper_left,
          size      = size.small,
          yloc      = yloc.belowbar)
        array.push(openLabels, lbl)
    else
        array.push(openLabels, label(na))

    array.push(openEntBars, bar_index)
    array.push(openEntries, close)
    array.push(openSL,      slPrice)
    array.push(openTP1,     tp1Price)
    array.push(openTP2,     tp2Price)
    array.push(openTP3,     tp3Price)
    array.push(openTrailSL, slPrice)
    array.push(hitTP1arr,   false)
    array.push(hitTP2arr,   false)
    array.push(sigTp1R,     tp1R)
    array.push(sigTp2R,     tp2R)
    array.push(sigTp3R,     tp3R)

// ── BENCHMARK RESOLUTION ──────────────────────────────────────────────────────
if array.size(openEntries) > 0
    i = 0
    while i < array.size(openEntries)
        entPrice = array.get(openEntries, i)
        entBar   = array.get(openEntBars, i)
        arw      = array.get(openArrows,  i)
        lbl      = array.get(openLabels,  i)
        h1       = array.get(hitTP1arr,   i)
        h2       = array.get(hitTP2arr,   i)
        slp      = array.get(openSL,      i)
        tp1p     = array.get(openTP1,     i)
        tp2p     = array.get(openTP2,     i)
        tp3p     = array.get(openTP3,     i)
        t1r      = array.get(sigTp1R,     i)
        t2r      = array.get(sigTp2R,     i)
        t3r      = array.get(sigTp3R,     i)

        if bar_index > entBar
            if not h1 and high >= tp1p
                array.set(hitTP1arr,   i, true)
                array.set(openTrailSL, i, entPrice)
                h1 := true
            if not h2 and high >= tp2p
                array.set(hitTP2arr,   i, true)
                array.set(openTrailSL, i, tp1p)
                h2 := true

            trailSL  = array.get(openTrailSL, i)
            resolved = false

            if high >= tp3p
                bench_tp3    += 1
                bench_open   -= 1
                bench_totalR += (t1r + t2r + t3r) / 3.0
                label.set_textcolor(arw, color.new(color.lime, 0))
                if not na(lbl)
                    label.set_text(lbl, str.replace(label.get_text(lbl), "⏳", "🏆 +" + str.tostring(math.round((tp3p - entPrice) / entPrice * 1000) / 10) + "%"))
                    label.set_color(lbl, color.new(color.green, 10))
                    label.set_textcolor(lbl, color.white)
                resolved := true

            else if low <= trailSL
                bench_open -= 1
                if h2
                    bench_tp2    += 1
                    bench_totalR += (t1r + t2r + t1r) / 3.0
                    label.set_textcolor(arw, color.new(color.lime, 30))
                    if not na(lbl)
                        label.set_text(lbl, str.replace(label.get_text(lbl), "⏳", "🥈 +" + str.tostring(math.round((tp2p - entPrice) / entPrice * 1000) / 10) + "% → SL@T1"))
                        label.set_color(lbl, color.new(color.green, 30))
                        label.set_textcolor(lbl, color.white)
                else if h1
                    bench_tp1    += 1
                    bench_totalR += t1r / 3.0
                    label.set_textcolor(arw, color.new(color.orange, 0))
                    if not na(lbl)
                        label.set_text(lbl, str.replace(label.get_text(lbl), "⏳", "🥉 +" + str.tostring(math.round((tp1p - entPrice) / entPrice * 1000) / 10) + "% → BE"))
                        label.set_color(lbl, color.new(color.orange, 20))
                        label.set_textcolor(lbl, color.white)
                else
                    bench_sl     += 1
                    bench_totalR -= 1.0
                    label.set_textcolor(arw, color.new(color.red, 0))
                    if not na(lbl)
                        label.set_text(lbl, str.replace(label.get_text(lbl), "⏳", "❌ -" + str.tostring(math.round((entPrice - slp) / entPrice * 1000) / 10) + "%"))
                        label.set_color(lbl, color.new(color.red, 10))
                        label.set_textcolor(lbl, color.white)
                resolved := true

            if resolved
                array.remove(openEntBars, i)
                array.remove(openEntries, i)
                array.remove(openSL,      i)
                array.remove(openTP1,     i)
                array.remove(openTP2,     i)
                array.remove(openTP3,     i)
                array.remove(openTrailSL, i)
                array.remove(hitTP1arr,   i)
                array.remove(hitTP2arr,   i)
                array.remove(openArrows,  i)
                array.remove(openLabels,  i)
                array.remove(sigTp1R,     i)
                array.remove(sigTp2R,     i)
                array.remove(sigTp3R,     i)
                continue
        i += 1

// ── BENCHMARK TABLE ───────────────────────────────────────────────────────────
var table benchTable = na

if showBenchmark and barstate.islast
    table.delete(benchTable)
    resolved = bench_tp1 + bench_tp2 + bench_tp3 + bench_sl
    winRate  = resolved > 0 ? ((bench_tp1 + bench_tp2 + bench_tp3) / resolved) * 100.0 : 0.0
    avgR     = resolved > 0 ? bench_totalR / resolved : 0.0

    winColor = winRate >= 60.0 ? color.new(color.lime, 15) : winRate >= 45.0 ? color.new(color.orange, 20) : color.new(color.red, 20)
    rColor   = avgR >= 0.0 ? color.new(color.lime, 15) : color.new(color.red, 20)
    modeLabel = useAtr
      ? "SL " + str.tostring(slAtrMult) + "× / T1 " + str.tostring(tp1AtrMult) + "× / T2 " + str.tostring(tp2AtrMult) + "× / T3 " + str.tostring(tp3AtrMult) + "× ATR"
      : "SL "  + str.tostring(slPct)    + "% / T1 " + str.tostring(tp1Pct)    + "% / T2 " + str.tostring(tp2Pct)    + "% / T3 " + str.tostring(tp3Pct) + "%"
    sampleWarn = resolved < 15 ? "⚠️ Low sample (" + str.tostring(resolved) + ")" : ""

    rows = resolved < 15 ? 10 : 9
    benchTable := table.new(position.bottom_right, 2, rows,
      bgcolor=color.new(color.black, 25), border_width=1, border_color=color.new(color.gray, 60),
      frame_width=1, frame_color=color.new(color.gray, 40))

    table.cell(benchTable, 0, 0, "📐 Benchmark",  text_color=color.white,              bgcolor=color.new(color.teal, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 0, modeLabel,        text_color=color.new(color.gray, 20), bgcolor=color.new(color.teal, 30), text_size=size.tiny,  text_halign=text.align_right)
    table.cell(benchTable, 0, 1, "Signals",        text_color=color.new(color.gray, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 1, str.tostring(bench_total) + "  (" + str.tostring(bench_open) + " open)", text_color=color.white, text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 2, "🏆 TP3",         text_color=color.new(#00c853, 0),     text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 2, str.tostring(bench_tp3), text_color=color.new(#00c853, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 3, "🥈 TP2 → SL@T1", text_color=color.new(color.lime, 10), text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 3, str.tostring(bench_tp2), text_color=color.new(color.lime, 10), text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 4, "🥉 TP1 → BE",    text_color=color.new(color.orange, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 4, str.tostring(bench_tp1), text_color=color.new(color.orange, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 5, "❌ Full SL",      text_color=color.new(color.red, 20),  text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 5, str.tostring(bench_sl), text_color=color.new(color.red, 20), text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 6, "Resolved",        text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 6, str.tostring(resolved), text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 7, "Win Rate",        text_color=color.white, bgcolor=winColor, text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 7, str.tostring(math.round(winRate * 10) / 10) + "%", text_color=color.white, bgcolor=winColor, text_size=size.small, text_halign=text.align_right)
    table.cell(benchTable, 0, 8, "Avg R/trade",     text_color=color.white, bgcolor=rColor, text_size=size.small, text_halign=text.align_left)
    table.cell(benchTable, 1, 8, str.tostring(math.round(avgR * 100) / 100) + "R", text_color=color.white, bgcolor=rColor, text_size=size.small, text_halign=text.align_right)

    if resolved < 15
        table.cell(benchTable, 0, 9, sampleWarn,       text_color=color.new(color.orange, 0), bgcolor=color.new(color.orange, 75), text_size=size.small, text_halign=text.align_left)
        table.cell(benchTable, 1, 9, "tune when ≥15",  text_color=color.new(color.orange, 10), bgcolor=color.new(color.orange, 75), text_size=size.small, text_halign=text.align_right)

// ── PLOTS & ALERTS ────────────────────────────────────────────────────────────
plotshape(not na(ph), title="Pivot High", style=shape.diamond, location=location.abovebar, color=color.new(color.red, 30), size=size.tiny, offset=-pivotLen)
alertcondition(breakSignal, title="📐 Downtrend Break", message="📐 Downtrend Break — {{ticker}} {{interval}}")
````

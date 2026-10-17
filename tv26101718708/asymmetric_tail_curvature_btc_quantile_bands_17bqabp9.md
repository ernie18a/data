# Asymmetric Tail Curvature  BTC Quantile Bands

- url: https://www.tradingview.com/script/17bQABP9-Asymmetric-Tail-Curvature-BTC-Quantile-Bands/
- type: indicator
- pine_id: PUB;333f7cdc1f164278ad42583efe344166
- version: 1.0

## Description

Based on the paper from Benjamin Cowen from "Into The Cryptoverse"

## Source Code

````pine
//@version=6
// =============================================================================
//  Asymmetric Tail Curvature — Bitcoin Quantile Bands
//  Implements the rearranged asymmetric quadratic quantile-regression model of
//  Cowen (2026), "Asymmetric Tail Curvature in Bitcoin Price Quantiles."
//
//  Model, per quantile tau, in log-log space:
//      Q_tau(log10 P) = c_tau + a_tau * x + b(tau) * x^2 ,   x = ln(t) - mu
//  where t  = days since the genesis anchor (Jan 1, 2009),
//        mu = 7.9914 (sample mean of ln t, the centering constant),
//        b(tau) is shared within tail groups:
//            b_LO  = -0.0241   tau in {1%, 10%, 25%}  (lower tail / structural)
//            b_MED = -0.1126   tau = 50%              (median)
//            b_HI  = -0.3259   tau in {75%, 95%, 99%} (upper tail / speculative)
//  Coefficients = Table 3 (full sample 2010-2026, n = 5,788).
//
//  Non-crossing is enforced exactly as in the paper (CFG 2010 rearrangement):
//  at every evaluation point the seven predictions are sorted ascending. The
//  raw quadratic crosses well before the 2035 grid end; sorting guarantees
//  monotone bands on any grid.
//
//  CAVEATS (from the paper, worth keeping in mind):
//   - Describes the conditional distribution of PRICE LEVEL given time. It is
//     NOT return-tail risk, NOT a loss model, and Q1% is NOT a price floor
//     (deepest realized daily close was -12.2% below Q1% in Sep-Oct 2010).
//   - Calibrated on BTCUSD daily close. Meaningless on other symbols.
//   - Long-horizon extrapolation has no literal interpretation (Section 17).
//   - Use a LOGARITHMIC price scale.
// =============================================================================
indicator("Asymmetric Tail Curvature — BTC Quantile Bands", "ATC Bands", overlay = true, max_polylines_count = 20, max_labels_count = 10)

// ----------------------------------------------------------- model constants
MU   = 7.9914
BLO  = -0.0241
BMED = -0.1126
BHI  = -0.3259
C01 = 2.837
A01 = 2.578
C10 = 2.933
A10 = 2.552
C25 = 3.004
A25 = 2.554
C50 = 3.214
A50 = 2.482
C75 = 3.562
A75 = 2.283
C95 = 3.897
A95 = 1.964
C99 = 4.028
A99 = 1.904
// historical intraday-wick dislocations below Q1% (factor = 1 + deviation)
F_FTX   = 0.9265   // -7.35%  Nov 2022 (FTX)
F_COVID = 0.826    // -17.4%  Mar 2020 (COVID)
F_2015  = 0.774    // -22.6%  Aug 2015
F_2010  = 0.654    // -34.6%  Aug 2010

MS_DAY  = 86400000
GENESIS = timestamp("UTC", 2009, 1, 1, 0, 0, 0)

// ------------------------------------------------------------------- inputs
showFills    = input.bool(true,  "Shade between bands",                       group = "Bands")
medWidth     = input.int(2, "Median line width", minval = 1, maxval = 4,      group = "Bands")
showDisloc   = input.bool(true,  "Show wick-dislocation reference levels",    group = "Reference levels")
projectF     = input.bool(true,  "Project bands into the future",             group = "Projection")
projEndYear  = input.int(2032,   "Projection end year", minval = 2027, maxval = 2045, group = "Projection")
showTable    = input.bool(true,  "Show info panel",                           group = "Display")
tablePosIn   = input.string("Top Right", "Panel position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = "Display")
warnNonBtc   = input.bool(true,  "Warn if symbol is not Bitcoin",             group = "Display")

posSel = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Bottom Right" ? position.bottom_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.top_right

// ------------------------------------------------------------------- helpers
// Returns the 7 quantile predictions in log10-price, sorted ascending
// (the rearrangement step). Order after sort = {1,10,25,50,75,95,99}%.
qbands(float t) =>
    float x  = math.log(t) - MU
    float x2 = x * x
    float l01 = C01 + A01 * x + BLO  * x2
    float l10 = C10 + A10 * x + BLO  * x2
    float l25 = C25 + A25 * x + BLO  * x2
    float l50 = C50 + A50 * x + BMED * x2
    float l75 = C75 + A75 * x + BHI  * x2
    float l95 = C95 + A95 * x + BHI  * x2
    float l99 = C99 + A99 * x + BHI  * x2
    out = array.from(l01, l10, l25, l50, l75, l95, l99)
    array.sort(out, order.ascending)
    out

fmtUsd(float v) =>
    na(v) ? "—" : v >= 1e6 ? "$" + str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? "$" + str.tostring(v / 1e3, "#.#") + "k" : "$" + str.tostring(v, "#.##")

// -------------------------------------------------------------- per-bar model
float daysNow = (time - GENESIS) / MS_DAY
arr = qbands(math.max(daysNow, 1))

float p01 = math.pow(10, array.get(arr, 0))
float p10 = math.pow(10, array.get(arr, 1))
float p25 = math.pow(10, array.get(arr, 2))
float p50 = math.pow(10, array.get(arr, 3))
float p75 = math.pow(10, array.get(arr, 4))
float p95 = math.pow(10, array.get(arr, 5))
float p99 = math.pow(10, array.get(arr, 6))

// ------------------------------------------------------------------- band plots
pl01 = plot(p01, "Q1%",          color = color.new(#1a6b3c, 0), linewidth = 1)
pl10 = plot(p10, "Q10%",         color = color.new(#2e8b57, 0), linewidth = 1)
pl25 = plot(p25, "Q25%",         color = color.new(#7cc47f, 0), linewidth = 1)
pl50 = plot(p50, "Q50% median",  color = color.new(#bdbdbd, 0), linewidth = medWidth)
pl75 = plot(p75, "Q75%",         color = color.new(#e8896b, 0), linewidth = 1)
pl95 = plot(p95, "Q95%",         color = color.new(#d9534f, 0), linewidth = 1)
pl99 = plot(p99, "Q99%",         color = color.new(#8b1a1a, 0), linewidth = 1)

fill(pl01, pl10, color = showFills ? color.new(#2e8b57, 88) : na, title = "1-10")
fill(pl10, pl25, color = showFills ? color.new(#3a9d63, 90) : na, title = "10-25")
fill(pl25, pl50, color = showFills ? color.new(#7cc47f, 92) : na, title = "25-50")
fill(pl50, pl75, color = showFills ? color.new(#e8896b, 92) : na, title = "50-75")
fill(pl75, pl95, color = showFills ? color.new(#d9534f, 90) : na, title = "75-95")
fill(pl95, pl99, color = showFills ? color.new(#8b1a1a, 88) : na, title = "95-99")

// -------------------------------------------------- wick-dislocation references
dFTX   = showDisloc ? p01 * F_FTX   : na
dCOVID = showDisloc ? p01 * F_COVID : na
d2015  = showDisloc ? p01 * F_2015  : na
d2010  = showDisloc ? p01 * F_2010  : na
plot(dFTX,   "Disloc -7.35% (FTX 2022)",   color = color.new(#caa53d, 35), linewidth = 1)
plot(dCOVID, "Disloc -17.4% (COVID 2020)", color = color.new(#caa53d, 45), linewidth = 1)
plot(d2015,  "Disloc -22.6% (Aug 2015)",   color = color.new(#caa53d, 55), linewidth = 1)
plD2010 = plot(d2010, "Disloc -34.6% (Aug 2010)", color = color.new(#caa53d, 35), linewidth = 1)
fill(pl01, plD2010, color = showDisloc ? color.new(#caa53d, 93) : na, title = "Historical dislocation zone")

// -------------------------------------------------------------- future projection
var polyline[] projLines = array.new<polyline>()

if barstate.islast
    if array.size(projLines) > 0
        for pl in projLines
            polyline.delete(pl)
        array.clear(projLines)
    if projectF
        pts0 = array.new<chart.point>()
        pts1 = array.new<chart.point>()
        pts2 = array.new<chart.point>()
        pts3 = array.new<chart.point>()
        pts4 = array.new<chart.point>()
        pts5 = array.new<chart.point>()
        pts6 = array.new<chart.point>()
        int endTs  = timestamp("UTC", projEndYear, 12, 31, 0, 0, 0)
        int stepMs = int(30.44 * MS_DAY)
        int ct = time
        while ct <= endTs
            float dd = (ct - GENESIS) / MS_DAY
            a = qbands(math.max(dd, 1))
            array.push(pts0, chart.point.from_time(ct, math.pow(10, array.get(a, 0))))
            array.push(pts1, chart.point.from_time(ct, math.pow(10, array.get(a, 1))))
            array.push(pts2, chart.point.from_time(ct, math.pow(10, array.get(a, 2))))
            array.push(pts3, chart.point.from_time(ct, math.pow(10, array.get(a, 3))))
            array.push(pts4, chart.point.from_time(ct, math.pow(10, array.get(a, 4))))
            array.push(pts5, chart.point.from_time(ct, math.pow(10, array.get(a, 5))))
            array.push(pts6, chart.point.from_time(ct, math.pow(10, array.get(a, 6))))
            ct := ct + stepMs
        if array.size(pts0) >= 2
            array.push(projLines, polyline.new(pts0, false, false, xloc.bar_time, color.new(#1a6b3c, 0), na, line.style_dashed, 1))
            array.push(projLines, polyline.new(pts1, false, false, xloc.bar_time, color.new(#2e8b57, 0), na, line.style_dashed, 1))
            array.push(projLines, polyline.new(pts2, false, false, xloc.bar_time, color.new(#7cc47f, 0), na, line.style_dashed, 1))
            array.push(projLines, polyline.new(pts3, false, false, xloc.bar_time, color.new(#bdbdbd, 0), na, line.style_dashed, medWidth))
            array.push(projLines, polyline.new(pts4, false, false, xloc.bar_time, color.new(#e8896b, 0), na, line.style_dashed, 1))
            array.push(projLines, polyline.new(pts5, false, false, xloc.bar_time, color.new(#d9534f, 0), na, line.style_dashed, 1))
            array.push(projLines, polyline.new(pts6, false, false, xloc.bar_time, color.new(#8b1a1a, 0), na, line.style_dashed, 1))

// ------------------------------------------------------------------- info panel
var table tbl = table.new(posSel, 2, 6, frame_color = color.gray, frame_width = 1)

if barstate.islast
    if showTable
        float lc = math.log10(close)
        taus = array.from(1.0, 10.0, 25.0, 50.0, 75.0, 95.0, 99.0)
        string pctStr = ""
        if lc <= array.get(arr, 0)
            pctStr := "< 1% (below structural floor)"
        else if lc >= array.get(arr, 6)
            pctStr := "> 99% (above speculative ceiling)"
        else
            int k = 0
            for i = 0 to 5
                if lc >= array.get(arr, i) and lc <= array.get(arr, i + 1)
                    k := i
                    break
            float lo  = array.get(arr, k)
            float hi  = array.get(arr, k + 1)
            float tlo = array.get(taus, k)
            float thi = array.get(taus, k + 1)
            float pct = tlo + (thi - tlo) * (lc - lo) / (hi - lo)
            pctStr := str.tostring(pct, "#.#") + " percentile"

        table.cell(tbl, 0, 0, "Model percentile",  text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 0, pctStr,              text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 0, 1, "Price",             text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 1, fmtUsd(close),       text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 0, 2, "Median (Q50)",      text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 2, fmtUsd(p50),         text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 0, 3, "Q1% – Q99%",        text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 3, fmtUsd(p01) + " – " + fmtUsd(p99), text_color = chart.fg_color, text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 0, 4, "Upper curvature bHI", text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 4, "-0.326",            text_color = color.new(#d9534f, 0), text_size = size.small, text_halign = text.align_right)
        table.cell(tbl, 0, 5, "Lower curvature bLO", text_color = chart.fg_color, text_size = size.small)
        table.cell(tbl, 1, 5, "-0.024",            text_color = color.new(#2e8b57, 0), text_size = size.small, text_halign = text.align_right)
    else
        for r = 0 to 5
            table.cell(tbl, 0, r, "")
            table.cell(tbl, 1, r, "")

// ------------------------------------------------------------------- warning
var label warnLbl = na
if barstate.islast
    bool isBtc = str.contains(str.upper(syminfo.ticker), "BTC") or str.contains(str.upper(syminfo.ticker), "XBT")
    if warnNonBtc and not isBtc
        if na(warnLbl)
            warnLbl := label.new(bar_index, high, "⚠ Model calibrated on BTCUSD daily close. Bands are not meaningful on this symbol.", color = color.new(color.orange, 15), textcolor = color.white, style = label.style_label_down, size = size.small)
        else
            label.set_xy(warnLbl, bar_index, high)
    else if not na(warnLbl)
        label.delete(warnLbl)
        warnLbl := na

// ------------------------------------------------------------------- alerts
alertcondition(ta.crossunder(close, p01), "Closed below Q1%",   "BTC closed below the Q1% structural-support quantile.")
alertcondition(ta.crossover(close, p95),  "Entered upper tail", "BTC crossed above the Q95% quantile (upper tail).")
alertcondition(ta.crossover(close, p99),  "Above Q99%",         "BTC closed above the Q99% speculative-ceiling quantile.")
````

# BTC Asymmetric Quantile Model (Cowen 2026)

- url: https://www.tradingview.com/script/vWN8hnCJ-BTC-Asymmetric-Quantile-Model-Cowen-2026/
- type: indicator
- pine_id: PUB;7a1a9e0a6246418d99a16c8c8df99b12
- version: 1.0

## Description

Classic Power law w/ Quantiles. Top Quantiles decayed.

## Source Code

````pine
//@version=6
// =============================================================================
// Bitcoin Asymmetric Quantile Model  (rearranged asymmetric quadratic)
// After: Cowen, B. (2026) "Asymmetric Tail Curvature in Bitcoin Price Quantiles"
//
//   Q_tau( log10(P) ) = c_tau + a_tau * x + b_tau * x^2
//   x  = ln(t) - mu                 (centered log-time)
//   t  = days since genesis anchor  (Jan 1, 2009)
//   mu = 7.9914                     (sample-mean centering, Sec 4.2)
//
//   Curvature is SHARED within tail groups (the paper's central asymmetry):
//     b_LO  = -0.0241  for tau in {0.01, 0.10, 0.25}
//     b_MED = -0.1126  for tau = 0.50
//     b_HI  = -0.3259  for tau in {0.75, 0.95, 0.99}
//
//   Non-crossing is enforced by REARRANGEMENT (Chernozhukov et al. 2010):
//   the 7 fitted values are sorted ascending at every evaluation point.
//   With these coefficients the raw bands would cross ~2028-2032, so the
//   sort is required for a coherent forward fan.
//
//   >>> Set the price axis to LOGARITHMIC scale to view the fan correctly. <<<
//   Coefficients are calibrated to the Jan 1 2009 anchor (Table 3, full sample).
// =============================================================================
indicator("BTC Asymmetric Quantile Model (Cowen 2026)", shorttitle="BTC AQM",
     overlay=true, max_polylines_count=20, max_labels_count=10)

// ----- Inputs -----------------------------------------------------------------
showFills   = input.bool(true,  "Shade between bands",                    group="Display")
showDisloc  = input.bool(false, "Show Q1% dislocation reference floors",  group="Display")
showProj    = input.bool(true,  "Project fan into the future",            group="Projection")
projEndYear = input.int(2030,   "Projection end year", minval=2026, maxval=2040, group="Projection")

// ----- Model constants (Table 3, full-sample rearranged asymmetric quadratic) -
MU = 7.9914
genesis = timestamp("UTC", 2009, 1, 1, 0, 0, 0)

// quantile order: Q1, Q10, Q25, Q50, Q75, Q95, Q99
var array<float> C = array.from(2.837, 2.933, 3.004, 3.214, 3.562, 3.897, 4.028)
var array<float> A = array.from(2.578, 2.552, 2.554, 2.482, 2.283, 1.964, 1.904)
var array<float> B = array.from(-0.0241, -0.0241, -0.0241, -0.1126, -0.3259, -0.3259, -0.3259)

// ----- Core: rearranged (sorted) quantile PRICES at a given timestamp ----------
f_prices(int ts) =>
    t  = math.max((ts - genesis) / 86400000.0, 1.0)   // days since genesis
    x  = math.log(t) - MU                             // natural log, centered
    x2 = x * x
    lp = array.new_float(7)
    for i = 0 to 6
        array.set(lp, i, array.get(C, i) + array.get(A, i) * x + array.get(B, i) * x2)
    array.sort(lp, order.ascending)                   // rearrangement -> non-crossing
    out = array.new_float(7)
    for i = 0 to 6
        array.set(out, i, math.pow(10, array.get(lp, i)))
    out

// ----- Per-bar evaluation ------------------------------------------------------
qp  = f_prices(time)
p01 = array.get(qp, 0)
p10 = array.get(qp, 1)
p25 = array.get(qp, 2)
p50 = array.get(qp, 3)
p75 = array.get(qp, 4)
p95 = array.get(qp, 5)
p99 = array.get(qp, 6)

// ----- Colors (dark green Q1% -> dark red Q99%, per Figure 1) ------------------
cQ01 = color.new(#1b7837, 0)
cQ10 = color.new(#5aae61, 0)
cQ25 = color.new(#a6dba0, 0)
cQ50 = color.new(#9e9e9e, 0)
cQ75 = color.new(#f4a582, 0)
cQ95 = color.new(#d6604d, 0)
cQ99 = color.new(#b2182b, 0)

// ----- Plot bands -------------------------------------------------------------
plQ01 = plot(p01, "Q1%",            color=cQ01, linewidth=1)
plQ10 = plot(p10, "Q10%",           color=cQ10, linewidth=1)
plQ25 = plot(p25, "Q25%",           color=cQ25, linewidth=1)
plQ50 = plot(p50, "Median (Q50%)",  color=cQ50, linewidth=2)
plQ75 = plot(p75, "Q75%",           color=cQ75, linewidth=1)
plQ95 = plot(p95, "Q95%",           color=cQ95, linewidth=1)
plQ99 = plot(p99, "Q99%",           color=cQ99, linewidth=1)

// ----- Fills ------------------------------------------------------------------
fill(plQ01, plQ10, color = showFills ? color.new(#5aae61, 88) : na, title="Q1-Q10")
fill(plQ10, plQ25, color = showFills ? color.new(#a6dba0, 88) : na, title="Q10-Q25")
fill(plQ25, plQ50, color = showFills ? color.new(#d9f0d3, 90) : na, title="Q25-Q50")
fill(plQ50, plQ75, color = showFills ? color.new(#fddbc7, 90) : na, title="Q50-Q75")
fill(plQ75, plQ95, color = showFills ? color.new(#f4a582, 88) : na, title="Q75-Q95")
fill(plQ95, plQ99, color = showFills ? color.new(#d6604d, 88) : na, title="Q95-Q99")

// ----- Q1% dislocation reference floors (Sec 12 / Figure 1) -------------------
// Historical undershoots of the realized intraday low vs contemporaneous Q1%:
//   -7.35% (FTX 2022), -17.4% (COVID 2020), -22.6% (2015), -34.6% (2010).
// These are descriptive stress references, NOT mechanical floors (Sec 12, 17).
plot(showDisloc ? p01 * (1 - 0.0735) : na, "Q1% -7.35% (FTX)",   color=color.new(color.orange, 25), style=plot.style_linebr)
plot(showDisloc ? p01 * (1 - 0.1740) : na, "Q1% -17.4% (COVID)", color=color.new(color.orange, 45), style=plot.style_linebr)
plot(showDisloc ? p01 * (1 - 0.2260) : na, "Q1% -22.6% (2015)",  color=color.new(color.orange, 60), style=plot.style_linebr)
plot(showDisloc ? p01 * (1 - 0.3460) : na, "Q1% -34.6% (2010)",  color=color.new(color.red, 55),    style=plot.style_linebr)

// ----- Forward projection (rearranged fan into the future) --------------------
var array<polyline> projLines = array.new<polyline>()

if barstate.islast and showProj
    if array.size(projLines) > 0
        for pl in projLines
            polyline.delete(pl)
        array.clear(projLines)

    endTime = timestamp("UTC", projEndYear, 12, 31, 0, 0, 0)
    stepMs  = 7 * 86400000                              // weekly steps

    pts0 = array.new<chart.point>(), pts1 = array.new<chart.point>()
    pts2 = array.new<chart.point>(), pts3 = array.new<chart.point>()
    pts4 = array.new<chart.point>(), pts5 = array.new<chart.point>()
    pts6 = array.new<chart.point>()

    ts = time
    while ts <= endTime
        fp = f_prices(ts)
        array.push(pts0, chart.point.from_time(ts, array.get(fp, 0)))
        array.push(pts1, chart.point.from_time(ts, array.get(fp, 1)))
        array.push(pts2, chart.point.from_time(ts, array.get(fp, 2)))
        array.push(pts3, chart.point.from_time(ts, array.get(fp, 3)))
        array.push(pts4, chart.point.from_time(ts, array.get(fp, 4)))
        array.push(pts5, chart.point.from_time(ts, array.get(fp, 5)))
        array.push(pts6, chart.point.from_time(ts, array.get(fp, 6)))
        ts += stepMs

    array.push(projLines, polyline.new(pts0, false, false, xloc.bar_time, cQ01, line_width=1))
    array.push(projLines, polyline.new(pts1, false, false, xloc.bar_time, cQ10, line_width=1))
    array.push(projLines, polyline.new(pts2, false, false, xloc.bar_time, cQ25, line_width=1))
    array.push(projLines, polyline.new(pts3, false, false, xloc.bar_time, cQ50, line_width=2))
    array.push(projLines, polyline.new(pts4, false, false, xloc.bar_time, cQ75, line_width=1))
    array.push(projLines, polyline.new(pts5, false, false, xloc.bar_time, cQ95, line_width=1))
    array.push(projLines, polyline.new(pts6, false, false, xloc.bar_time, cQ99, line_width=1))
````

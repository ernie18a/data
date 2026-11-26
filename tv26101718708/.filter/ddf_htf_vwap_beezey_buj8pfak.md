# DDF - HTF VWAP | Beezey

- url: https://www.tradingview.com/script/BuJ8pfak-DDF-HTF-VWAP-Beezey/
- type: indicator
- pine_id: PUB;140a090ff9e2459dad1057bda9dc5391
- version: 1.0

## Description

multiple vwaps with deviation bands many times making me type more

## Source Code

````pine

//@version=6
indicator("DDF - HTF VWAP | Beezey", overlay = true, max_bars_back = 500, max_labels_count = 200)

// ════════════════════════════════════════════════════════════════════════════
//  DDF - HTF VWAP  -  multi-anchored VWAP + 3 std-dev bands + prev-period lines
//  Port of the ATAS 8.0.13 indicator. Use on intraday / daily charts.
//
//  Anchors: Yearly, Quarterly, Monthly, Weekly, Daily, RTH Session, plus frozen
//  previous-period reference lines (Prev Yearly / Quarterly / Monthly).
//  Std dev: weighted Welford recurrence - matches the ATAS DLL within float error.
//  NOTE: TradingView only loads a few thousand-to-~20k bars, so a Yearly VWAP on an
//  intraday chart anchors at the start of loaded data, not Jan 1. View Yearly/Quarterly
//  on 1H/4H/1D for a faithful anchor; Monthly and below are fine intraday.
// ════════════════════════════════════════════════════════════════════════════

// ── INPUTS ───────────────────────────────────────────────────────────────────
gBands = "Deviation Bands"
mult1 = input.float(1.0, "Std Dev Mult 1", minval = 0.01, group = gBands)
mult2 = input.float(2.0, "Std Dev Mult 2", minval = 0.01, group = gBands)
mult3 = input.float(3.0, "Std Dev Mult 3", minval = 0.01, group = gBands)

gStyle = "Line Style & Width"
vwapWidth   = input.int(2, "VWAP line width", minval = 1, maxval = 10, group = gStyle)
bandWidth   = input.int(1, "Band line width", minval = 1, maxval = 10, group = gStyle)
vwapStyleIn = input.string("Solid", "VWAP line style", options = ["Solid", "Stepline", "Circles"], group = gStyle)
bandStyleIn = input.string("Solid", "Band line style", options = ["Solid", "Stepline", "Circles"], group = gStyle)
vwapStyle = switch vwapStyleIn
    "Stepline" => plot.style_stepline
    "Circles"  => plot.style_circles
    => plot.style_line
bandStyle = switch bandStyleIn
    "Stepline" => plot.style_stepline
    "Circles"  => plot.style_circles
    => plot.style_line

// NOTE on plot limits: TradingView caps a script at 64 "plot units". A plot() whose
// color is non-const (input/series) costs 2 units; a const color costs 1. With 9 VWAP
// lines (configurable color, 2 each) + 36 SD-band plots, configurable band colors would
// cost 90 + 6 alerts = 96 (over the 64 cap → RE10140). So band colors are fixed const
// faded-theme values below (band plot = 1 unit each). Total = 18 + 36 + 6 = 60.
// Line colors remain fully configurable; only per-band color picking is dropped.

gY = "Yearly VWAP"
showY  = input.bool(true,  "Enabled",    group = gY)
colY   = input.color(color.rgb(255, 215, 0), "Line",  group = gY)
showYB = input.bool(true,  "Show Bands", group = gY)
colYB  = color.new(color.rgb(255, 215, 0), 55)   // const band color (fixed) - see plot-limit note

gQ = "Quarterly VWAP"
showQ  = input.bool(true,  "Enabled",    group = gQ)
colQ   = input.color(color.rgb(255, 165, 0), "Line",  group = gQ)
showQB = input.bool(true,  "Show Bands", group = gQ)
colQB  = color.new(color.rgb(255, 165, 0), 55)   // const band color (fixed)

gM = "Monthly VWAP"
showM  = input.bool(true,  "Enabled",    group = gM)
colM   = input.color(color.rgb(0, 191, 255), "Line",  group = gM)
showMB = input.bool(true,  "Show Bands", group = gM)
colMB  = color.new(color.rgb(0, 191, 255), 55)   // const band color (fixed)

gW = "Weekly VWAP"
showW  = input.bool(false, "Enabled",    group = gW)
colW   = input.color(color.rgb(147, 112, 219), "Line",  group = gW)
showWB = input.bool(false, "Show Bands", group = gW)
colWB  = color.new(color.rgb(147, 112, 219), 55)   // const band color (fixed)

gD = "Daily VWAP"
showD  = input.bool(false, "Enabled",    group = gD)
colD   = input.color(color.rgb(50, 205, 50), "Line",  group = gD)
showDB = input.bool(false, "Show Bands", group = gD)
colDB  = color.new(color.rgb(50, 205, 50), 55)   // const band color (fixed)

gS = "Session VWAP (RTH)"
showS   = input.bool(false, "Enabled",    group = gS)
colS    = input.color(color.rgb(255, 255, 255), "Line",  group = gS)
showSB  = input.bool(true,  "Show Bands", group = gS)
colSB   = color.new(color.gray, 50)   // const band color (fixed)
sessRTH = input.session("0930-1600", "RTH Session", group = gS)
tzRTH   = input.string("America/New_York", "RTH Time Zone", group = gS)

gP = "Previous Periods (frozen reference)"
showPY = input.bool(true,  "Prev Yearly",    group = gP)
colPY  = input.color(color.rgb(184, 134, 11), "Prev Yearly Color",    group = gP)
showPQ = input.bool(true,  "Prev Quarterly", group = gP)
colPQ  = input.color(color.rgb(210, 105, 30), "Prev Quarterly Color", group = gP)
showPM = input.bool(false, "Prev Monthly",   group = gP)
colPM  = input.color(color.rgb(70, 130, 180), "Prev Monthly Color",   group = gP)

// ── ANCHOR CONDITIONS ──────────────────────────────────────────────────────────
// Year / Quarter / Month are detected from explicit calendar fields in the
// instrument's EXCHANGE time zone (closest analog to ATAS InstrumentInfo.TimeZone).
// This is more robust than timeframe.change("12M"/"3M") for true Jan-1 / quarter
// alignment. Week / Day use timeframe.change, which honors the data feed's session.
calTz  = syminfo.timezone
yNow   = year(time,  calTz)
yPrev  = year(time[1], calTz)
mNow   = month(time,  calTz)
mPrev  = month(time[1], calTz)
qNow   = math.ceil(mNow  / 3.0)
qPrev  = math.ceil(mPrev / 3.0)

anchorY = not barstate.isfirst and yNow != yPrev
anchorQ = not barstate.isfirst and (yNow != yPrev or qNow != qPrev)
anchorM = not barstate.isfirst and (yNow != yPrev or mNow != mPrev)
anchorW = timeframe.change("W")
anchorD = timeframe.change("D")

inRth  = not na(time(timeframe.period, sessRTH, tzRTH))
newRth = inRth and not inRth[1]

// ── CORE: reusable anchored VWAP + volume-weighted stdev ───────────────────────
// Each call site keeps its own persistent accumulators (Pine var-in-function scope).
// active=false  -> returns na (line breaks). Used to confine the RTH session VWAP.
//
// Variance uses the WEIGHTED WELFORD recurrence:
//     newMean = cPV / cVol
//     cM2    += vol * (tp - oldMean) * (tp - newMean)
//     var     = cM2 / cVol            (population, volume-weighted)
// This is mathematically identical to ATAS's  Σ(tp²·vol)/Σvol − vwap²  but avoids
// the catastrophic cancellation of subtracting two huge near-equal sums on a Yearly
// anchor, so the bands stay stable in float64 and match the ATAS DLL within precision.
// Zero-volume bars don't move the VWAP/SD but still emit the carried value so the line
// is continuous.
f_avwap(float tp, float vol, bool resetCond, bool active) =>
    var float cVol = 0.0
    var float cPV  = 0.0
    var float cM2  = 0.0
    if resetCond
        cVol := 0.0
        cPV  := 0.0
        cM2  := 0.0
    float vw = na
    float sd = na
    if active
        if vol > 0
            float oldMean = cVol > 0 ? cPV / cVol : tp
            cVol += vol
            cPV  += tp * vol
            float newMean = cPV / cVol
            cM2  += vol * (tp - oldMean) * (tp - newMean)
        vw := cVol > 0 ? cPV / cVol : tp
        sd := cVol > 0 ? math.sqrt(math.max(cM2 / cVol, 0.0)) : 0.0
    [vw, sd]

[vwY, sdY] = f_avwap(hlc3, volume, anchorY, true)
[vwQ, sdQ] = f_avwap(hlc3, volume, anchorQ, true)
[vwM, sdM] = f_avwap(hlc3, volume, anchorM, true)
[vwW, sdW] = f_avwap(hlc3, volume, anchorW, true)
[vwD, sdD] = f_avwap(hlc3, volume, anchorD, true)
[vwS, sdS] = f_avwap(hlc3, volume, newRth, inRth)

// ── PREVIOUS-PERIOD CAPTURE (frozen final VWAP, projected flat) ────────────────
f_prevVwap(bool resetCond, float vwSeries) =>
    var float pv = na
    if resetCond and not na(vwSeries[1])
        pv := vwSeries[1]
    pv

prevY = f_prevVwap(anchorY, vwY)
prevQ = f_prevVwap(anchorQ, vwQ)
prevM = f_prevVwap(anchorM, vwM)

// ── VISUALIZATION ──────────────────────────────────────────────────────────────
// Calendar VWAPs: insert a 1-bar gap at each reset (not anchorX) so periods don't join.
// hlc3 typical price; titles appear in the status line / Data Window (TV hover equivalent).

// Yearly
plot(showY  and not anchorY ? vwY : na,            "Yearly VWAP",    color = colY, linewidth = vwapWidth, style = vwapStyle)
plot(showY and showYB and not anchorY ? vwY + mult1 * sdY : na, "Yearly VWAP +1 SD", color = colYB, linewidth = bandWidth, style = bandStyle)
plot(showY and showYB and not anchorY ? vwY + mult2 * sdY : na, "Yearly VWAP +2 SD", color = colYB, linewidth = bandWidth, style = bandStyle)
plot(showY and showYB and not anchorY ? vwY + mult3 * sdY : na, "Yearly VWAP +3 SD", color = colYB, linewidth = bandWidth, style = bandStyle)
plot(showY and showYB and not anchorY ? vwY - mult1 * sdY : na, "Yearly VWAP -1 SD", color = colYB, linewidth = bandWidth, style = bandStyle)
plot(showY and showYB and not anchorY ? vwY - mult2 * sdY : na, "Yearly VWAP -2 SD", color = colYB, linewidth = bandWidth, style = bandStyle)
plot(showY and showYB and not anchorY ? vwY - mult3 * sdY : na, "Yearly VWAP -3 SD", color = colYB, linewidth = bandWidth, style = bandStyle)

// Quarterly
plot(showQ  and not anchorQ ? vwQ : na,            "Quarterly VWAP", color = colQ, linewidth = vwapWidth, style = vwapStyle)
plot(showQ and showQB and not anchorQ ? vwQ + mult1 * sdQ : na, "Quarterly VWAP +1 SD", color = colQB, linewidth = bandWidth, style = bandStyle)
plot(showQ and showQB and not anchorQ ? vwQ + mult2 * sdQ : na, "Quarterly VWAP +2 SD", color = colQB, linewidth = bandWidth, style = bandStyle)
plot(showQ and showQB and not anchorQ ? vwQ + mult3 * sdQ : na, "Quarterly VWAP +3 SD", color = colQB, linewidth = bandWidth, style = bandStyle)
plot(showQ and showQB and not anchorQ ? vwQ - mult1 * sdQ : na, "Quarterly VWAP -1 SD", color = colQB, linewidth = bandWidth, style = bandStyle)
plot(showQ and showQB and not anchorQ ? vwQ - mult2 * sdQ : na, "Quarterly VWAP -2 SD", color = colQB, linewidth = bandWidth, style = bandStyle)
plot(showQ and showQB and not anchorQ ? vwQ - mult3 * sdQ : na, "Quarterly VWAP -3 SD", color = colQB, linewidth = bandWidth, style = bandStyle)

// Monthly
plot(showM  and not anchorM ? vwM : na,            "Monthly VWAP",   color = colM, linewidth = vwapWidth, style = vwapStyle)
plot(showM and showMB and not anchorM ? vwM + mult1 * sdM : na, "Monthly VWAP +1 SD", color = colMB, linewidth = bandWidth, style = bandStyle)
plot(showM and showMB and not anchorM ? vwM + mult2 * sdM : na, "Monthly VWAP +2 SD", color = colMB, linewidth = bandWidth, style = bandStyle)
plot(showM and showMB and not anchorM ? vwM + mult3 * sdM : na, "Monthly VWAP +3 SD", color = colMB, linewidth = bandWidth, style = bandStyle)
plot(showM and showMB and not anchorM ? vwM - mult1 * sdM : na, "Monthly VWAP -1 SD", color = colMB, linewidth = bandWidth, style = bandStyle)
plot(showM and showMB and not anchorM ? vwM - mult2 * sdM : na, "Monthly VWAP -2 SD", color = colMB, linewidth = bandWidth, style = bandStyle)
plot(showM and showMB and not anchorM ? vwM - mult3 * sdM : na, "Monthly VWAP -3 SD", color = colMB, linewidth = bandWidth, style = bandStyle)

// Weekly
plot(showW  and not anchorW ? vwW : na,            "Weekly VWAP",    color = colW, linewidth = vwapWidth, style = vwapStyle)
plot(showW and showWB and not anchorW ? vwW + mult1 * sdW : na, "Weekly VWAP +1 SD", color = colWB, linewidth = bandWidth, style = bandStyle)
plot(showW and showWB and not anchorW ? vwW + mult2 * sdW : na, "Weekly VWAP +2 SD", color = colWB, linewidth = bandWidth, style = bandStyle)
plot(showW and showWB and not anchorW ? vwW + mult3 * sdW : na, "Weekly VWAP +3 SD", color = colWB, linewidth = bandWidth, style = bandStyle)
plot(showW and showWB and not anchorW ? vwW - mult1 * sdW : na, "Weekly VWAP -1 SD", color = colWB, linewidth = bandWidth, style = bandStyle)
plot(showW and showWB and not anchorW ? vwW - mult2 * sdW : na, "Weekly VWAP -2 SD", color = colWB, linewidth = bandWidth, style = bandStyle)
plot(showW and showWB and not anchorW ? vwW - mult3 * sdW : na, "Weekly VWAP -3 SD", color = colWB, linewidth = bandWidth, style = bandStyle)

// Daily
plot(showD  and not anchorD ? vwD : na,            "Daily VWAP",     color = colD, linewidth = vwapWidth, style = vwapStyle)
plot(showD and showDB and not anchorD ? vwD + mult1 * sdD : na, "Daily VWAP +1 SD", color = colDB, linewidth = bandWidth, style = bandStyle)
plot(showD and showDB and not anchorD ? vwD + mult2 * sdD : na, "Daily VWAP +2 SD", color = colDB, linewidth = bandWidth, style = bandStyle)
plot(showD and showDB and not anchorD ? vwD + mult3 * sdD : na, "Daily VWAP +3 SD", color = colDB, linewidth = bandWidth, style = bandStyle)
plot(showD and showDB and not anchorD ? vwD - mult1 * sdD : na, "Daily VWAP -1 SD", color = colDB, linewidth = bandWidth, style = bandStyle)
plot(showD and showDB and not anchorD ? vwD - mult2 * sdD : na, "Daily VWAP -2 SD", color = colDB, linewidth = bandWidth, style = bandStyle)
plot(showD and showDB and not anchorD ? vwD - mult3 * sdD : na, "Daily VWAP -3 SD", color = colDB, linewidth = bandWidth, style = bandStyle)

// Session (RTH) - vwS is already na outside the session, so it self-breaks overnight.
plot(showS ? vwS : na,                         "Session VWAP",    color = colS, linewidth = vwapWidth, style = vwapStyle)
plot(showS and showSB ? vwS + mult1 * sdS : na, "Session VWAP +1 SD", color = colSB, linewidth = bandWidth, style = bandStyle)
plot(showS and showSB ? vwS + mult2 * sdS : na, "Session VWAP +2 SD", color = colSB, linewidth = bandWidth, style = bandStyle)
plot(showS and showSB ? vwS + mult3 * sdS : na, "Session VWAP +3 SD", color = colSB, linewidth = bandWidth, style = bandStyle)
plot(showS and showSB ? vwS - mult1 * sdS : na, "Session VWAP -1 SD", color = colSB, linewidth = bandWidth, style = bandStyle)
plot(showS and showSB ? vwS - mult2 * sdS : na, "Session VWAP -2 SD", color = colSB, linewidth = bandWidth, style = bandStyle)
plot(showS and showSB ? vwS - mult3 * sdS : na, "Session VWAP -3 SD", color = colSB, linewidth = bandWidth, style = bandStyle)

// Previous-period frozen lines (line only, break at each reset for a clean step)
plot(showPY and not anchorY ? prevY : na, "Prev Yearly VWAP",    color = colPY, linewidth = vwapWidth, style = vwapStyle)
plot(showPQ and not anchorQ ? prevQ : na, "Prev Quarterly VWAP", color = colPQ, linewidth = vwapWidth, style = vwapStyle)
plot(showPM and not anchorM ? prevM : na, "Prev Monthly VWAP",   color = colPM, linewidth = vwapWidth, style = vwapStyle)

// ── LEVEL LABELS ───────────────────────────────────────────────────────────────
// Labels do NOT count toward the 64 plot-unit limit, so we can name every line/band.
// Drawn only on the last bar, projected `labOffset` bars to the right, and deleted +
// redrawn on each update so they never accumulate.
gLab        = "Level Labels"
showLab     = input.bool(true,  "Show VWAP / prev labels", group = gLab)
showBandLab = input.bool(true,  "Show band labels",        group = gLab)
labPrice    = input.bool(true,  "Show price in label",     group = gLab)
labOffset   = input.int(3,      "Label offset (bars)", minval = 0, maxval = 50, group = gLab)
labSizeIn   = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = gLab)
labSz = switch labSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

var array<label> _labs = array.new<label>()

f_lab(bool cond, float y, string txt, color col) =>
    if cond and not na(y)
        string s = labPrice ? txt + "  " + str.tostring(math.round_to_mintick(y)) : txt
        label lb = label.new(bar_index + labOffset, y, s, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 85), textcolor = col, size = labSz)
        array.push(_labs, lb)

if barstate.islast
    for lb in _labs
        label.delete(lb)
    array.clear(_labs)

    // VWAP lines
    f_lab(showLab and showY, vwY, "Yearly VWAP",    colY)
    f_lab(showLab and showQ, vwQ, "Quarterly VWAP", colQ)
    f_lab(showLab and showM, vwM, "Monthly VWAP",   colM)
    f_lab(showLab and showW, vwW, "Weekly VWAP",    colW)
    f_lab(showLab and showD, vwD, "Daily VWAP",     colD)
    f_lab(showLab and showS, vwS, "Session VWAP",   colS)

    // Bands (label text uses the anchor's line color for readability)
    f_lab(showBandLab and showY and showYB, vwY + mult1 * sdY, "Y +1 SD", colY)
    f_lab(showBandLab and showY and showYB, vwY + mult2 * sdY, "Y +2 SD", colY)
    f_lab(showBandLab and showY and showYB, vwY + mult3 * sdY, "Y +3 SD", colY)
    f_lab(showBandLab and showY and showYB, vwY - mult1 * sdY, "Y -1 SD", colY)
    f_lab(showBandLab and showY and showYB, vwY - mult2 * sdY, "Y -2 SD", colY)
    f_lab(showBandLab and showY and showYB, vwY - mult3 * sdY, "Y -3 SD", colY)

    f_lab(showBandLab and showQ and showQB, vwQ + mult1 * sdQ, "Q +1 SD", colQ)
    f_lab(showBandLab and showQ and showQB, vwQ + mult2 * sdQ, "Q +2 SD", colQ)
    f_lab(showBandLab and showQ and showQB, vwQ + mult3 * sdQ, "Q +3 SD", colQ)
    f_lab(showBandLab and showQ and showQB, vwQ - mult1 * sdQ, "Q -1 SD", colQ)
    f_lab(showBandLab and showQ and showQB, vwQ - mult2 * sdQ, "Q -2 SD", colQ)
    f_lab(showBandLab and showQ and showQB, vwQ - mult3 * sdQ, "Q -3 SD", colQ)

    f_lab(showBandLab and showM and showMB, vwM + mult1 * sdM, "M +1 SD", colM)
    f_lab(showBandLab and showM and showMB, vwM + mult2 * sdM, "M +2 SD", colM)
    f_lab(showBandLab and showM and showMB, vwM + mult3 * sdM, "M +3 SD", colM)
    f_lab(showBandLab and showM and showMB, vwM - mult1 * sdM, "M -1 SD", colM)
    f_lab(showBandLab and showM and showMB, vwM - mult2 * sdM, "M -2 SD", colM)
    f_lab(showBandLab and showM and showMB, vwM - mult3 * sdM, "M -3 SD", colM)

    f_lab(showBandLab and showW and showWB, vwW + mult1 * sdW, "W +1 SD", colW)
    f_lab(showBandLab and showW and showWB, vwW + mult2 * sdW, "W +2 SD", colW)
    f_lab(showBandLab and showW and showWB, vwW + mult3 * sdW, "W +3 SD", colW)
    f_lab(showBandLab and showW and showWB, vwW - mult1 * sdW, "W -1 SD", colW)
    f_lab(showBandLab and showW and showWB, vwW - mult2 * sdW, "W -2 SD", colW)
    f_lab(showBandLab and showW and showWB, vwW - mult3 * sdW, "W -3 SD", colW)

    f_lab(showBandLab and showD and showDB, vwD + mult1 * sdD, "D +1 SD", colD)
    f_lab(showBandLab and showD and showDB, vwD + mult2 * sdD, "D +2 SD", colD)
    f_lab(showBandLab and showD and showDB, vwD + mult3 * sdD, "D +3 SD", colD)
    f_lab(showBandLab and showD and showDB, vwD - mult1 * sdD, "D -1 SD", colD)
    f_lab(showBandLab and showD and showDB, vwD - mult2 * sdD, "D -2 SD", colD)
    f_lab(showBandLab and showD and showDB, vwD - mult3 * sdD, "D -3 SD", colD)

    f_lab(showBandLab and showS and showSB, vwS + mult1 * sdS, "S +1 SD", colS)
    f_lab(showBandLab and showS and showSB, vwS + mult2 * sdS, "S +2 SD", colS)
    f_lab(showBandLab and showS and showSB, vwS + mult3 * sdS, "S +3 SD", colS)
    f_lab(showBandLab and showS and showSB, vwS - mult1 * sdS, "S -1 SD", colS)
    f_lab(showBandLab and showS and showSB, vwS - mult2 * sdS, "S -2 SD", colS)
    f_lab(showBandLab and showS and showSB, vwS - mult3 * sdS, "S -3 SD", colS)

    // Previous-period frozen lines
    f_lab(showLab and showPY, prevY, "Prev Yearly",    colPY)
    f_lab(showLab and showPQ, prevQ, "Prev Quarterly", colPQ)
    f_lab(showLab and showPM, prevM, "Prev Monthly",   colPM)

// ── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(ta.cross(close, vwY) and barstate.isconfirmed, "Cross Yearly VWAP",    '{{ticker}} | DDF HTF VWAP | crossed YEARLY VWAP @ {{close}}')
alertcondition(ta.cross(close, vwQ) and barstate.isconfirmed, "Cross Quarterly VWAP", '{{ticker}} | DDF HTF VWAP | crossed QUARTERLY VWAP @ {{close}}')
alertcondition(ta.cross(close, vwM) and barstate.isconfirmed, "Cross Monthly VWAP",   '{{ticker}} | DDF HTF VWAP | crossed MONTHLY VWAP @ {{close}}')
alertcondition(ta.cross(close, vwS) and barstate.isconfirmed, "Cross Session VWAP",   '{{ticker}} | DDF HTF VWAP | crossed SESSION VWAP @ {{close}}')
alertcondition(high >= vwS + mult2 * sdS and barstate.isconfirmed, "Session +2 SD stretch", '{{ticker}} | DDF HTF VWAP | tagged SESSION +2 SD @ {{close}}')
alertcondition(low  <= vwS - mult2 * sdS and barstate.isconfirmed, "Session -2 SD stretch", '{{ticker}} | DDF HTF VWAP | tagged SESSION -2 SD @ {{close}}')
````

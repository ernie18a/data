# ZIZO BTC Power Law

- url: https://www.tradingview.com/script/RskxfIiG-ZIZO-BTC-Power-Law/
- type: indicator
- pine_id: PUB;f0298837fbed445bbd6247cff4814347
- version: 1.0

## Description

ZIZO BTC Power Law — Streamlined Edition
A fixed power law channel for Bitcoin. No refitting. No drift. No statistical bands. Every line on the chart is a number you can check for yourself.
The model
Bitcoin's long-run price has tracked a power law of time since the Genesis Block. This script draws that law and nothing else:
Price = A × (days since Genesis)^n

A = 3.21 × 10⁻¹⁷
n = 5.688
Genesis = 3 January 2009

These coefficients are fixed. They do not recalibrate as new candles print. That is deliberate. A model that constantly refits itself can never be wrong, and so can never be verified. This one holds still, which means you can test it against price and judge it honestly.
The bands
The centre line is fair value — the raw model output (1.000×). Every other band is a chosen multiple of fair value, not a standard deviation or a curve fit:

Cycle Top — 2.627× fair value
Fair Value 2 — 1.747×
PL Median (fair value) — 1.000×
Fair Value 1 — 0.667×
Floor — 0.420×

Zones between the bands are shaded low-to-high so the chart reads at a glance.
Also on the chart

200-day SMA, coloured green above / red below, as a tactical trend layer over the macro model.
Halving markers. H1–H4 are the four confirmed halvings, verified against their calendar dates. H5+ is projected from the last confirmed halving plus a configurable interval (default 1,461 days). No cycle dates are hardcoded beyond the four that have actually happened.
Forward projection lines at 1, 2, 3 and 5 years, with fair-value and cycle-top price labels. This is model extrapolation, not a forecast.
Info table — every band price, live deviation from fair value and from the 200 SMA, log-space channel position (0 = floor, 1 = top), day-count streaks above/below each key line, and forward targets.

How to read it
Channel position is the quick summary. Near 1.0, price sits at the historical top of the band and risk is high. Near 0.0, price sits at the floor and value is high. The 200 SMA tells you the current trend; the power law tells you where that trend sits inside the long cycle.
Alerts
Crossings of the Cycle Top, Floor, PL Median, Fair Value 1/2, and the 200 SMA — up and down.
Design principles
Fixed anchors over dynamic models. Chosen multipliers over fitted sigma bands. Self-extending halvings over hardcoded dates. Every number on screen is a deliberate value you can audit.
Notes
This is a research and analysis tool, not financial advice. Power law fair value is a long-horizon reference, not a price prediction. Past cycle structure does not guarantee future structure. Verify everything before you act on it.
License: MPL 2.0. Built by PseudoNakamoto21.
Hard money. Don't trust. Verify.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PseudoNakamoto21
// =========================================================================
//  ZIZO BTC Power Law  —  Streamlined Edition
//  PseudoNakamoto21  |  Pine Script v6
//
//  Fixed power law model: Price = A × (days since Genesis)^n
//  No presets, no band modes, no drift. Every band is a chosen multiplier.
//  Genesis: Jan 3 2009 (Unix day 14247)
//
//  Model      : A = 3.21e-17   n = 5.688
//  Bands (× fair value):
//      Cycle Top     2.6266
//      Fair Value 2  1.747
//      PL Median     1.000
//      Fair Value 1  0.6671
//      Floor         0.420
//
//  H1–H4 are confirmed historical halvings (hardcoded, verified against
//  calendar dates: 2012-11-28, 2016-07-09, 2020-05-11, 2024-04-20).
//  H5+ is PROJECTED: last confirmed halving + halvingIntervalDays input.
//
//  Hard money. Don't trust. Verify.
//  Color palette: PseudoNakamoto21 standard
// =========================================================================

//@version=6
indicator("ZIZO BTC Power Law", " BTC Power Law", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────

var string gModel = "① Model"
var string gBands = "② Bands"
var string gProj  = "③ Projection Lines"
var string gHalv  = "④ Halving Markers"
var string g200   = "⑤ 200-Day SMA"
var string gDisp  = "⑥ Display"

// ─────────────────────────────────────────────────────────────────────────
//  ① MODEL  (fixed — edit defaults only if recalibrating)
// ─────────────────────────────────────────────────────────────────────────

mantissa = input.float(3.21, "Mantissa (A × 10^exp)", group = gModel, step = 0.01,
     tooltip = "Scaling constant A. Default 3.21 (× 10^-17).")
expPow   = input.int  (-17,  "Exponent (10^x)",       group = gModel,
     tooltip = "Power of ten for A.")
slope    = input.float(5.688, "Slope (n)",            group = gModel, step = 0.001,
     tooltip = "Power law exponent. Default 5.688.")

genesisUnixDays = input.int(14247, "Genesis Block (Unix days)", group = gModel,
     tooltip = "Days from Unix epoch to Genesis Block (Jan 3 2009) = 14247.")

float A = mantissa * math.pow(10.0, float(expPow))

// ─────────────────────────────────────────────────────────────────────────
//  ② BANDS
// ─────────────────────────────────────────────────────────────────────────

showTop   = input.bool(true, "Show Cycle Top",    group = gBands)
showFV2   = input.bool(true, "Show Fair Value 2", group = gBands)
showMed   = input.bool(true, "Show PL Median",    group = gBands)
showFV1   = input.bool(true, "Show Fair Value 1", group = gBands)
showFloor = input.bool(true, "Show Floor",        group = gBands)
showFill  = input.bool(true, "Fill zones",        group = gBands)

topMult   = input.float(2.6266,  "Cycle Top × fair",    group = gBands, step = 0.001)
fv2Mult   = input.float(1.747,  "Fair Value 2 × fair", group = gBands, step = 0.001)
fv1Mult   = input.float(0.6671, "Fair Value 1 × fair", group = gBands, step = 0.001)
floorMult = input.float(0.420,  "Floor × fair",        group = gBands, step = 0.001)

// ─────────────────────────────────────────────────────────────────────────
//  ③ PROJECTION LINES
// ─────────────────────────────────────────────────────────────────────────

showProjections = input.bool(true,  "Show projection lines", group = gProj,
     tooltip = "Extends the median, FV1, FV2, floor and top forward as dashed lines. Model extrapolation — not a forecast.")
proj1yr = input.bool(true,  "1-year target label", group = gProj)
proj2yr = input.bool(true,  "2-year target label", group = gProj)
proj3yr = input.bool(false, "3-year target label", group = gProj)
proj5yr = input.bool(false, "5-year target label", group = gProj)

// ─────────────────────────────────────────────────────────────────────────
//  ④ HALVING MARKERS
// ─────────────────────────────────────────────────────────────────────────

showHalvings  = input.bool(true, "Show halving markers",     group = gHalv)
halvingExtend = input.bool(true, "Extend to top of channel", group = gHalv)
halvingIntervalDays = input.int(1461, "Next halving interval (days)", group = gHalv, minval = 1,
     tooltip = "Days added to the LAST CONFIRMED halving to project the next one. Default 1461 (~210,000 blocks @ 10min avg). Set to 1441 to match the BTC CYCLES companion script.")

// ─────────────────────────────────────────────────────────────────────────
//  ⑤ 200-DAY SMA
// ─────────────────────────────────────────────────────────────────────────

show200  = input.bool(true, "Show 200 SMA",   group = g200)
ma200Len = input.int (200,  "200 SMA length", group = g200, minval = 1)

// ─────────────────────────────────────────────────────────────────────────
//  ⑥ DISPLAY
// ─────────────────────────────────────────────────────────────────────────

lineWidth = input.int (1,    "Line width",      group = gDisp, minval = 1, maxval = 4)
showTable = input.bool(true, "Show info table", group = gDisp)

// ─────────────────────────────────────────────────────────────────────────
//  POWER LAW CORE
// ─────────────────────────────────────────────────────────────────────────

int   currentUnixDays  = int(time / 86400000)
float daysSinceGenesis = float(currentUnixDays - genesisUnixDays)
float fairValue        = daysSinceGenesis > 0 ? A * math.pow(daysSinceGenesis, slope) : na

// ─────────────────────────────────────────────────────────────────────────
//  BAND PRICES
// ─────────────────────────────────────────────────────────────────────────

float floorLine = na(fairValue) ? na : fairValue * floorMult
float fv1Line   = na(fairValue) ? na : fairValue * fv1Mult
float topLine   = na(fairValue) ? na : fairValue * topMult
float fv2Line   = na(fairValue) ? na : fairValue * fv2Mult

// ─────────────────────────────────────────────────────────────────────────
//  200 SMA
// ─────────────────────────────────────────────────────────────────────────

float ma200 = ta.sma(close, ma200Len)

// ─────────────────────────────────────────────────────────────────────────
//  DEVIATION METRICS
// ─────────────────────────────────────────────────────────────────────────

float devFromFair = not na(fairValue) and fairValue > 0 ? (close - fairValue) / fairValue * 100.0 : na
float devFrom200  = not na(ma200)     and ma200     > 0 ? (close - ma200)     / ma200     * 100.0 : na

float plPosition = not na(floorLine) and not na(topLine) and topLine > floorLine
     ? math.log(math.max(close, 0.001) / floorLine) / math.log(topLine / floorLine)
     : na

// Channel-position reference levels (used by the info table)
float denom  = math.log(topMult / floorMult)
float posFV1 = math.log(fv1Mult / floorMult) / denom
float posMed = math.log(1.0     / floorMult) / denom
float posFV2 = math.log(fv2Mult / floorMult) / denom

// ─────────────────────────────────────────────────────────────────────────
//  STREAK COUNTERS
// ─────────────────────────────────────────────────────────────────────────

var int daysAbove200  = 0
var int daysBelow200  = 0
var int daysAboveFair = 0
var int daysBelowFair = 0

if not na(ma200)
    if close >= ma200
        daysAbove200 += 1
        daysBelow200  := 0
    else
        daysBelow200 += 1
        daysAbove200  := 0

if not na(fairValue)
    if close >= fairValue
        daysAboveFair += 1
    else
        daysBelowFair += 1

// ─────────────────────────────────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────────────────────────────────

color colTop   = #e6392d
color colFV2   = #ff9933
color colFair  = #e6e64c
color colFV1   = #3ed9a6
color colFloor = #1e7cc2
color col200   = close >= ma200 ? color.new(#008000, 0) : color.new(#ff0000, 0)
color colHalv  = color.new(#ffffff, 60)

int fillAlpha = showFill ? 88 : 100

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS — BANDS
// ─────────────────────────────────────────────────────────────────────────

p_top   = plot(showTop   ? topLine   : na, "Cycle Top",    color = colTop,   linewidth = lineWidth,     style = plot.style_line)
p_fv2   = plot(showFV2   ? fv2Line   : na, "Fair Value 2", color = colFV2,   linewidth = lineWidth,     style = plot.style_line)
p_fair  = plot(showMed   ? fairValue : na, "PL Median",    color = colFair,  linewidth = lineWidth + 1, style = plot.style_line)
p_fv1   = plot(showFV1   ? fv1Line   : na, "Fair Value 1", color = colFV1,   linewidth = lineWidth,     style = plot.style_line)
p_floor = plot(showFloor ? floorLine : na, "Floor",        color = colFloor, linewidth = lineWidth,     style = plot.style_line)
p_200   = plot(show200   ? ma200     : na, "200 SMA",      color = col200,   linewidth = lineWidth,     style = plot.style_line)

fill(p_top,  p_fv2,   color = color.new(colTop,  fillAlpha), title = "Top → FV2")
fill(p_fv2,  p_fair,  color = color.new(colFV2,  fillAlpha), title = "FV2 → Median")
fill(p_fair, p_fv1,   color = color.new(colFair, fillAlpha), title = "Median → FV1")
fill(p_fv1,  p_floor, color = color.new(colFV1,  fillAlpha), title = "FV1 → Floor")

// ─────────────────────────────────────────────────────────────────────────
//  HALVING MARKERS
//  H1–H4 confirmed unix days, verified against calendar dates:
//    H1 2012-11-28 → 15672   H2 2016-07-09 → 16991
//    H3 2020-05-11 → 18393   H4 2024-04-20 → 19833
//  H5+ projected = last confirmed day + halvingIntervalDays.
// ─────────────────────────────────────────────────────────────────────────

var int[]    confirmedHalvingDays   = array.from(15672, 16991, 18393, 19833)
var string[] confirmedHalvingLabels = array.from("H1\n2012", "H2\n2016", "H3\n2020", "H4\n2024")

if showHalvings and barstate.islast
    int lastConfirmedDay = array.get(confirmedHalvingDays, array.size(confirmedHalvingDays) - 1)
    int nextHalvingDay   = lastConfirmedDay + halvingIntervalDays

    int[]    halvingDays   = array.copy(confirmedHalvingDays)
    string[] halvingLabels = array.copy(confirmedHalvingLabels)
    array.push(halvingDays, nextHalvingDay)
    array.push(halvingLabels, "H5~\n" + str.format_time(nextHalvingDay * 86400000, "yyyy", "UTC"))

    for i = 0 to array.size(halvingDays) - 1
        int   hDay  = array.get(halvingDays, i)
        int   hTime = hDay * 86400000
        float hFV   = A * math.pow(float(hDay - genesisUnixDays), slope)
        float hTop  = hFV * topMult

        line.new(
             x1    = hTime,
             y1    = hFV * floorMult,
             x2    = hTime,
             y2    = halvingExtend ? hTop * 1.05 : hTop,
             xloc  = xloc.bar_time,
             color = colHalv,
             style = line.style_dashed,
             width = 1)

        label.new(
             x         = hTime,
             y         = hFV * floorMult * 0.70,
             text      = array.get(halvingLabels, i),
             xloc      = xloc.bar_time,
             color     = color.new(#1a1a2e, 20),
             textcolor = colHalv,
             style     = label.style_none,
             size      = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  PROJECTION LINES
// ─────────────────────────────────────────────────────────────────────────

if showProjections and barstate.islast and not na(fairValue)
    int t0   = currentUnixDays
    int t1yr = t0 + 365
    int t2yr = t0 + 730
    int t3yr = t0 + 1095
    int t5yr = t0 + 1825
    int tEnd = proj5yr ? t5yr : proj3yr ? t3yr : proj2yr ? t2yr : t1yr

    float fvEnd = A * math.pow(float(tEnd  - genesisUnixDays), slope)
    float fv1p  = A * math.pow(float(t1yr  - genesisUnixDays), slope)
    float fv2p  = A * math.pow(float(t2yr  - genesisUnixDays), slope)
    float fv3p  = A * math.pow(float(t3yr  - genesisUnixDays), slope)
    float fv5p  = A * math.pow(float(t5yr  - genesisUnixDays), slope)

    int t0ms   = t0   * 86400000
    int tEndms = tEnd * 86400000
    int t1ms   = t1yr * 86400000
    int t2ms   = t2yr * 86400000
    int t3ms   = t3yr * 86400000
    int t5ms   = t5yr * 86400000

    float[] startPrices = array.from(fairValue, fv2Line,             fv1Line,             topLine,          floorLine)
    float[] endPrices   = array.from(fvEnd,     fvEnd * fv2Mult,     fvEnd * fv1Mult,     fvEnd * topMult,  fvEnd * floorMult)
    color[] projColors  = array.from(colFair,   colFV2,              colFV1,              colTop,           colFloor)

    for i = 0 to 4
        line.new(
             x1    = t0ms,
             y1    = array.get(startPrices, i),
             x2    = tEndms,
             y2    = array.get(endPrices,   i),
             xloc  = xloc.bar_time,
             color = color.new(array.get(projColors, i), 40),
             style = line.style_dashed,
             width = 1)

    if proj1yr
        label.new(t1ms, fv1p, "PL Fair\n$" + str.tostring(math.round(fv1p / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colFair, style = label.style_label_left, size = size.small)
        label.new(t1ms, fv1p * topMult, "Top\n$" + str.tostring(math.round(fv1p * topMult / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colTop, style = label.style_label_left, size = size.small)

    if proj2yr
        label.new(t2ms, fv2p, "PL Fair\n$" + str.tostring(math.round(fv2p / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colFair, style = label.style_label_left, size = size.small)
        label.new(t2ms, fv2p * topMult, "Top\n$" + str.tostring(math.round(fv2p * topMult / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colTop, style = label.style_label_left, size = size.small)

    if proj3yr
        label.new(t3ms, fv3p, "PL Fair\n$" + str.tostring(math.round(fv3p / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colFair, style = label.style_label_left, size = size.small)

    if proj5yr
        label.new(t5ms, fv5p, "PL Fair\n$" + str.tostring(math.round(fv5p / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colFair, style = label.style_label_left, size = size.small)
        label.new(t5ms, fv5p * topMult, "Top\n$" + str.tostring(math.round(fv5p * topMult / 1000)) + "k",
             xloc = xloc.bar_time, color = color.new(#1a1a2e, 10),
             textcolor = colTop, style = label.style_label_left, size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  INFO TABLE
// ─────────────────────────────────────────────────────────────────────────

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 18,
         border_width = 1,
         border_color = color.new(color.gray, 55),
         frame_width  = 1,
         frame_color  = color.new(color.gray, 35))

    color hBG  = color.new(#0d0d1a,  5)
    color cBG  = color.new(#16213e, 15)
    color sBG  = color.new(#0a1628, 25)
    color lCol = color.new(color.silver, 10)
    color dCol = color.new(color.gray,   35)

    table.cell(t, 0, 0, "BTC Power Law  ⬡  Streamlined", bgcolor = hBG, text_color = colFair, text_size = size.normal)
    table.cell(t, 1, 0, str.format("A {0}e{1} · n {2}", mantissa, expPow, slope), bgcolor = hBG, text_color = colFair, text_size = size.small)

    table.cell(t, 0, 1, "Cycle Top  (" + str.format("{0,number,0.000}", topMult) + "×)", bgcolor = cBG, text_color = colTop, text_size = size.normal)
    table.cell(t, 1, 1, not na(topLine) ? "$" + str.tostring(math.round(topLine)) : "n/a", bgcolor = cBG, text_color = colTop, text_size = size.normal)

    table.cell(t, 0, 2, "Fair Value 2  (" + str.format("{0,number,0.000}", fv2Mult) + "×)", bgcolor = cBG, text_color = colFV2, text_size = size.normal)
    table.cell(t, 1, 2, not na(fv2Line) ? "$" + str.tostring(math.round(fv2Line)) : "n/a", bgcolor = cBG, text_color = colFV2, text_size = size.normal)

    table.cell(t, 0, 3, "PL Median  (1.000×)", bgcolor = cBG, text_color = colFair, text_size = size.normal)
    table.cell(t, 1, 3, not na(fairValue) ? "$" + str.tostring(math.round(fairValue)) +
         (not na(devFromFair) ? "  (" + str.format("{0,number,+0.0}", devFromFair) + "%)" : "")
         : "n/a", bgcolor = cBG, text_color = colFair, text_size = size.normal)

    table.cell(t, 0, 4, "Fair Value 1  (" + str.format("{0,number,0.000}", fv1Mult) + "×)", bgcolor = cBG, text_color = colFV1, text_size = size.normal)
    table.cell(t, 1, 4, not na(fv1Line) ? "$" + str.tostring(math.round(fv1Line)) : "n/a", bgcolor = cBG, text_color = colFV1, text_size = size.normal)

    table.cell(t, 0, 5, "Floor  (" + str.format("{0,number,0.000}", floorMult) + "×)", bgcolor = cBG, text_color = colFloor, text_size = size.normal)
    table.cell(t, 1, 5, not na(floorLine) ? "$" + str.tostring(math.round(floorLine)) : "n/a", bgcolor = cBG, text_color = colFloor, text_size = size.normal)

    table.cell(t, 0, 6, "─────────────────", bgcolor = sBG, text_color = dCol, text_size = size.tiny)
    table.cell(t, 1, 6, "─────────────────", bgcolor = sBG, text_color = dCol, text_size = size.tiny)

    color posCol = not na(plPosition)
         ? (plPosition > posFV2 ? colTop : plPosition > posMed ? colFV2 : plPosition > posFV1 ? colFair : colFV1)
         : lCol
    table.cell(t, 0, 7, "Channel Position", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 7, not na(plPosition) ? str.format("{0,number,0.000}", plPosition) + " / 1.000" : "n/a",
         bgcolor = cBG, text_color = posCol, text_size = size.normal)

    table.cell(t, 0, 8, "200 SMA", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 8, not na(ma200) ? "$" + str.tostring(math.round(ma200)) +
         (not na(devFrom200) ? "  (" + str.format("{0,number,+0.0}", devFrom200) + "%)" : "")
         : "n/a", bgcolor = cBG, text_color = col200, text_size = size.normal)

    table.cell(t, 0, 9,  "Days above 200 SMA", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 9,  str.tostring(daysAbove200),  bgcolor = cBG, text_color = colFV2,  text_size = size.normal)
    table.cell(t, 0, 10, "Days below 200 SMA", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 10, str.tostring(daysBelow200),  bgcolor = cBG, text_color = colFloor, text_size = size.normal)
    table.cell(t, 0, 11, "Days above PL fair", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 11, str.tostring(daysAboveFair), bgcolor = cBG, text_color = colFair,  text_size = size.normal)
    table.cell(t, 0, 12, "Days below PL fair", bgcolor = cBG, text_color = lCol, text_size = size.normal)
    table.cell(t, 1, 12, str.tostring(daysBelowFair), bgcolor = cBG, text_color = colFV1,   text_size = size.normal)

    table.cell(t, 0, 13, "─────────────────", bgcolor = sBG, text_color = dCol, text_size = size.tiny)
    table.cell(t, 1, 13, "─────────────────", bgcolor = sBG, text_color = dCol, text_size = size.tiny)

    float f1 = A * math.pow(float(currentUnixDays + 365  - genesisUnixDays), slope)
    float f2 = A * math.pow(float(currentUnixDays + 730  - genesisUnixDays), slope)
    float f3 = A * math.pow(float(currentUnixDays + 1095 - genesisUnixDays), slope)
    float f5 = A * math.pow(float(currentUnixDays + 1825 - genesisUnixDays), slope)

    table.cell(t, 0, 14, "PL Fair  +1yr", bgcolor = cBG, text_color = dCol, text_size = size.small)
    table.cell(t, 1, 14, "$" + str.tostring(math.round(f1 / 1000)) + "k  |  Top $" + str.tostring(math.round(f1 * topMult / 1000)) + "k", bgcolor = cBG, text_color = colFair, text_size = size.small)
    table.cell(t, 0, 15, "PL Fair  +2yr", bgcolor = cBG, text_color = dCol, text_size = size.small)
    table.cell(t, 1, 15, "$" + str.tostring(math.round(f2 / 1000)) + "k  |  Top $" + str.tostring(math.round(f2 * topMult / 1000)) + "k", bgcolor = cBG, text_color = colFair, text_size = size.small)
    table.cell(t, 0, 16, "PL Fair  +3yr", bgcolor = cBG, text_color = dCol, text_size = size.small)
    table.cell(t, 1, 16, "$" + str.tostring(math.round(f3 / 1000)) + "k  |  Top $" + str.tostring(math.round(f3 * topMult / 1000)) + "k", bgcolor = cBG, text_color = colFair, text_size = size.small)
    table.cell(t, 0, 17, "PL Fair  +5yr", bgcolor = cBG, text_color = dCol, text_size = size.small)
    table.cell(t, 1, 17, "$" + str.tostring(math.round(f5 / 1000)) + "k  |  Top $" + str.tostring(math.round(f5 * topMult / 1000)) + "k", bgcolor = cBG, text_color = colFair, text_size = size.small)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────

alertcondition(ta.crossover (close, topLine),   "Crossed ABOVE Cycle Top",    "BTC crossed ABOVE cycle top band")
alertcondition(ta.crossunder(close, floorLine), "Crossed BELOW Floor",        "BTC crossed BELOW floor band")
alertcondition(ta.crossover (close, fairValue), "Crossed ABOVE PL Median",    "BTC crossed ABOVE PL median (fair value)")
alertcondition(ta.crossunder(close, fairValue), "Crossed BELOW PL Median",    "BTC crossed BELOW PL median (fair value)")
alertcondition(ta.crossover (close, fv2Line),   "Crossed ABOVE Fair Value 2", "BTC crossed ABOVE Fair Value 2")
alertcondition(ta.crossunder(close, fv1Line),   "Crossed BELOW Fair Value 1", "BTC crossed BELOW Fair Value 1")
alertcondition(ta.crossover (close, ma200),     "Crossed ABOVE 200 SMA",      "BTC crossed ABOVE 200-day SMA")
alertcondition(ta.crossunder(close, ma200),     "Crossed BELOW 200 SMA",      "BTC crossed BELOW 200-day SMA")
````

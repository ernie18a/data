# Burst Size Flow Divergence  Large vs Small CVD

- url: https://www.tradingview.com/script/IjtOndkB-Burst-Size-Flow-Divergence-Large-vs-Small-CVD/
- type: indicator
- pine_id: PUB;072cb2731ac6439b9698aa8fc96918f0
- version: 2.0

## Description

Overview

A single cumulative-delta line tells you net buying or selling, but hides who is doing the pushing. Burst-Size Flow Divergence splits the flow inside each bar by the size of each volume burst — small / medium / large sub-intervals — and runs a separate signed delta on each tier. The signal is the divergence between the large-burst delta and the small-burst delta: concentrated bursts leaning one way while trickle flow leans the other. It is a flow-structure read, not a signal to trade alone.

What this is — and is NOT (read this before using)

This measures activity-burst size, not per-trade size. Pine cannot see individual trades — it sees a bar's volume and, via lower-timeframe requests, the volume of each sub-interval within the bar. "Large" here means a sub-interval that printed a lot of volume relative to normal — not a large single trade, and not "institutional." Institutions deliberately slice big orders into many small child-orders, so burst size is a proxy, not proof of who is behind the flow. The classification is honest about this, and the built-in harness is there precisely to test whether the divergence carries any information rather than to assert that it does.

Why these components are ONE tool (mashup justification)

Each stage exists because the previous one is ambiguous on its own:


Intrabar bucketing. Each lower-timeframe sub-bar is classed small/medium/large by its volume against an adaptive average, so "large" means large for this symbol and session, not a fixed lot count. A fixed threshold would misclassify on every instrument and every volatility regime.
Per-tier directional imbalance. Each tier gets its own signed delta (up sub-bar → +volume, down → −volume), expressed as net ÷ gross in [−1, +1] — what fraction of that tier was net buying versus selling. Normalising this way lets the tiers' directions be compared apples-to-apples even though the large tier moves far less total volume than the small one.
The divergence. The large-minus-small spread is the object. Three separate delta lines would just be clutter to eyeball; the disagreement between the concentrated and the trickle flow is the actual read, so the tool computes it directly.
The calibration harness. "Concentrated bursts are informed" is a hypothesis, not a law — so when the spread is strong, the harness checks forward whether price actually followed the large tier more than the unconditional base rate, and reports Hit / Base / Edge on confirmed bars. That's what turns the divergence from a story into something you can verify on your instrument.


How it works

For each chart bar the finest available sub-bars are requested. Each is signed by close-versus-open (a tick-rule aggressor proxy) and bucketed by volume against the adaptive average. Per-tier signed volume becomes a net÷gross imbalance in [−1, +1], the large-minus-small spread is smoothed into the oscillator, and a strong gated spread is the divergence signal.

How to use it

Read the histogram (the large-minus-small spread): green means large bursts are accumulating while small flow lags or sells; red means large bursts are distributing. The bold line is the large-tier imbalance, the faint line the small tier. A gated turn in the spread suggests concentrated flow is leading, and is marked in the pane and — optionally — on the price chart. Always check the Coverage row (how much real sub-bar resolution the current bar received) and the Edge row (whether the divergence has actually led on this instrument). It is never a standalone trigger.

Plan-adaptive & data note

Sub-bar precision auto-selects the finest your plan serves (seconds on Premium+, else 1-minute). Lower-timeframe data exists only for recent bars, so older bars fall back to whole-bar flow and the coverage read shows it. The tool needs an instrument with real volume — a cash index reports none, so use the futures. The adaptive average and the calibration harness advance only on confirmed bars, so they never drift or inflate intrabar. Edge is in-sample, no costs — a study aid, not a backtest.

Originality

The parts are public: cumulative volume delta, the close-vs-open (tick-rule) aggressor proxy, and the general idea of size-partitioned / flow-toxicity order flow. What's assembled here is the specific construction — the adaptive intrabar size-tiering, the net÷gross per-tier imbalance that makes tiers of very different volume directly comparable, the large-minus-small divergence as the headline object, and the forward-calibration harness that scores it against the base rate. This is a clean-room implementation; no third-party Pine code is reused.

Concept credits


Cumulative Volume Delta — standard order-flow technique.
Close-vs-open (tick-rule) aggressor classification — after the classic trade-sign literature (Lee & Ready).
Size-partitioned / flow-toxicity order flow (VPIN) — Easley, López de Prado & O'Hara.


Disclaimer

Research and educational tool only. Not financial advice, no recommendation, no guarantee of results. Burst size is not trade size and does not identify institutions versus retail; the up/down sign is a close-vs-open proxy for the aggressor, not the true tape. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// BURST-SIZE FLOW DIVERGENCE — LARGE vs SMALL CVD                                             v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A single cumulative-delta line hides who is doing the pushing. This oscillator splits the flow
//   INSIDE each bar by the SIZE of each volume burst — small / medium / large sub-intervals — and
//   runs a separate signed cumulative delta on each tier. The signal is the DIVERGENCE between the
//   LARGE-burst delta and the SMALL-burst delta: concentrated bursts leaning one way while trickle
//   flow leans the other. It is a flow-structure read, not a signal to trade alone.
//
// IMPORTANT — WHAT THIS IS (AND IS NOT)
//   This measures ACTIVITY-BURST SIZE, not per-trade size. Pine cannot see individual trades; it
//   sees a bar's volume, and (via lower-timeframe requests) the volume of each SUB-INTERVAL within
//   the bar. "Large" here means a sub-interval that printed a lot of volume relative to normal —
//   NOT a large single trade, and NOT "institutional." Institutions deliberately slice big orders
//   into many small child-orders, so burst size is a proxy, not proof of who is behind the flow.
//   The bar-classification is honest and the harness tests whether the divergence actually leads.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool)
//   - INTRABAR BUCKETING: each lower-timeframe sub-bar is classed small/medium/large by its volume
//     versus an ADAPTIVE average (so "large" means large for THIS symbol/session, not a fixed lot).
//   - PER-TIER DIRECTIONAL IMBALANCE: each tier gets its own delta (up sub-bar → +vol, down → −vol),
//     expressed as net ÷ gross volume in [−1,+1] — what fraction of that tier was net buying vs
//     selling — so the tiers' DIRECTIONS compare apples-to-apples despite very different volumes.
//   - THE DIVERGENCE: the LARGE-minus-SMALL spread is the object — the tiers disagreeing is the
//     signal, not three lines to eyeball.
//   - CALIBRATION HARNESS: when the spread is strong, did price follow the large tier more than the
//     base rate? Reports Hit / Base / EDGE — because "concentrated bursts are informed" is a
//     hypothesis, not a law, and this tests it on your instrument.
//
// HOW IT WORKS
//   For each chart bar, the finest available sub-bars are requested. Each is signed (up/down) and
//   bucketed by volume against an adaptive average. Per-tier signed volume is expressed as a
//   net ÷ gross directional imbalance in [−1,+1], and the large-minus-small spread is smoothed into
//   the oscillator. A strong spread in a direction, gated, is the divergence signal.
//
// HOW TO USE
//   Read the histogram (large-minus-small spread): green = large bursts accumulating while small
//   flow lags/sells; red = large bursts distributing. The bold line is the large-tier imbalance, the
//   faint line the small tier. A gated turn in the spread suggests concentrated flow is leading, and
//   is marked in the pane and (optionally) on the price chart. Watch the EDGE row and the intrabar
//   COVERAGE (how much real sub-bar resolution each bar got). Never a standalone trigger.
//
//
// EDGE IS NOW BOUNDED, NOT ASSERTED  (v1.1)
//   The Edge figure is a POINT ESTIMATE, and on a modest sample a +4 pt reading
//   and pure noise look identical. Every Edge now carries a WILSON 95% LOWER
//   BOUND beside it:  Edge LB = wilsonLo(hit rate) - base rate.  The panel turns
//   green ONLY when that lower bound clears zero with an adequate sample - a
//   positive point estimate alone is no longer coloured as though it were
//   evidence. Expect the bound to sit below zero far more often than the point
//   estimate does; that is the honest picture of a modest sample, not a fault in
//   the measurement.
//   Edge figures remain IN-SAMPLE and without costs - a study aid, not a backtest.
// PLAN-ADAPTIVE / NON-REPAINT
//   Sub-bar precision auto-selects the finest your plan serves (seconds on Premium+, else 1-minute).
//   Lower-timeframe data exists only for recent bars; older bars fall back to whole-bar flow and the
//   coverage read shows it. The adaptive average and the calibration harness advance only on closed
//   (confirmed) bars, so they never drift or inflate intrabar. Edge is in-sample, no costs — a study
//   aid, not a backtest.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Spread · EXP_LargeImb · EXP_SmallImb · EXP_Signal (+1 large accum / −1 large distrib / 0) · EXP_Edge
//
// CONCEPT CREDIT
//   Built on standard techniques — cumulative volume delta, the close-vs-open (tick-rule) aggressor
//   proxy, and the size-partitioned / flow-toxicity order-flow literature. Full credits in the
//   published description. The size-tier partition, the net÷gross large-vs-small imbalance divergence
//   and the harness are this script's own. No third-party Pine code is reused. Not affiliated with,
//   nor endorsed by, any party.
//
// HONESTY / LIMITATIONS
//   Burst size is NOT trade size and does NOT identify institutions vs retail. The up/down sign is a
//   close-vs-open proxy for aggressor, not the true tape. Lower-timeframe data is recent-bars-only.
//   Markets change; the divergence's edge is exactly what the harness exists to check. Nothing here
//   predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NO recommendation, NO guarantee of
//   results. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Burst-Size Flow Divergence — Large vs Small CVD", "Burst Flow", overlay = false, calc_bars_count = 3000, max_labels_count = 100)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g0        = "01 · Intrabar precision"
ltfMode   = input.string("Auto (finest available)", "Sub-bar resolution", options = ["Auto (finest available)","Seconds","5 seconds","1 minute"], group = g0, tooltip = "Auto tries seconds (Premium+), falls back to 1-minute, and older bars fall back to whole-bar flow.")

g1        = "02 · Size buckets"
avgLen    = input.int(50, "Adaptive volume window", minval = 5, maxval = 500, group = g1, tooltip = "Rolling average sub-bar volume that defines the tiers.")
largeMult = input.float(3.0, "Large ≥ × average", minval = 1.1, maxval = 8.0, step = 0.1, group = g1, tooltip = "How many times the average sub-bar volume a burst must exceed to count as 'large'. Higher = only the concentrated tail.")
smallMult = input.float(0.5, "Small ≤ × average", minval = 0.05, maxval = 0.9, step = 0.05, group = g1)

g2        = "03 · Flow & smoothing"
cvdLen    = input.int(20, "Imbalance window (bars)", minval = 3, maxval = 200, group = g2, tooltip = "Bars over which each tier's net÷gross directional imbalance is measured.")
smoothLen = input.int(3, "Spread smoothing", minval = 1, maxval = 50, group = g2)

g3        = "04 · Signal"
gate      = input.float(0.6, "Divergence gate", minval = 0.1, maxval = 2.0, step = 0.05, group = g3, tooltip = "The large-minus-small imbalance spread (range −2..+2) must exceed this to flag a burst-flow divergence. 0.6 ≈ the tiers clearly disagreeing.")

g4        = "05 · Calibration harness"
horizon   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
kATR      = input.float(1.0, "Move threshold (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = g4)

g5        = "06 · Display & theme"
showLines = input.bool(true, "Show large / small tier lines", group = g5)
showHist  = input.bool(true, "Show spread histogram", group = g5)
showMarks = input.bool(true, "Mark gated divergences (pane)", group = g5)
showOvl   = input.bool(true, "Also mark signals on price (overlay)", group = g5, tooltip = "Draw the gated large-accumulating / large-distributing triangles on the price chart as well as in the pane.")
showDash  = input.bool(true, "Show dashboard", group = g5)
theme     = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g5)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0) : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0) : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0) : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0) : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0) : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0) : color.new(#2a323c, 0)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                      INTRABAR REQUEST → per-tier signed delta this bar
// ═════════════════════════════════════════════════════════════════════════════════════════
string ltfTF = ltfMode == "Seconds" ? "1S" : ltfMode == "5 seconds" ? "5S" : ltfMode == "1 minute" ? "1" : (timeframe.in_seconds() >= 3600 ? "1" : timeframe.in_seconds() >= 300 ? "5S" : "1S")
array<float> ivVol = request.security_lower_tf(syminfo.tickerid, ltfTF, volume)
array<float> ivCls = request.security_lower_tf(syminfo.tickerid, ltfTF, close)
array<float> ivOpn = request.security_lower_tf(syminfo.tickerid, ltfTF, open)

var float avgIV = na
float ivRef = nz(avgIV[1], na)
float thrL = na(ivRef) ? 1e18 : largeMult * ivRef
float thrS = na(ivRef) ? -1.0 : smallMult * ivRef

int n = math.min(array.size(ivVol), math.min(array.size(ivCls), array.size(ivOpn)))
float dL = 0.0
float dS = 0.0     // signed tier deltas (large / small — medium delta is unused in the spread)
float vL = 0.0
float vM = 0.0
float vS = 0.0     // unsigned tier volumes (for the size split)
float barVol = 0.0
if n > 0
    for i = 0 to n - 1
        float v = nz(array.get(ivVol, i), 0.0)
        float c = array.get(ivCls, i)
        float o = array.get(ivOpn, i)
        int sgn = (na(c) or na(o)) ? 0 : c > o ? 1 : c < o ? -1 : 0
        float sv = v * sgn
        barVol += v
        if v >= thrL
            dL += sv
            vL += v
        else if v <= thrS
            dS += sv
            vS += v
        else
            vM += v
    float meanIV = barVol / n
    if barstate.isconfirmed
        avgIV := na(avgIV) ? meanIV : avgIV + (meanIV - avgIV) * (2.0 / (avgLen + 1.0))
else
    // fallback: no sub-bar data → whole chart bar counts as one medium unit (no tiering, spread = 0)
    float v = nz(volume, 0.0)
    vM += v
    barVol := v

// ═════════════════════════════════════════════════════════════════════════════════════════
//                      PER-TIER DIRECTIONAL IMBALANCE → large-minus-small spread
// ═════════════════════════════════════════════════════════════════════════════════════════
// per-tier directional imbalance = net signed volume ÷ gross tier volume, in [-1, +1]
float sumDL = math.sum(dL, cvdLen)
float sumVL = math.sum(vL, cvdLen)
float sumDS = math.sum(dS, cvdLen)
float sumVS = math.sum(vS, cvdLen)
float imbL = sumVL > 1e-9 ? sumDL / sumVL : 0.0
float imbS = sumVS > 1e-9 ? sumDS / sumVS : 0.0
float spread = imbL - imbS
float spreadSm = ta.ema(spread, smoothLen)

// rolling size split (share of volume by tier)
float shL = sumVL
float shM = math.sum(vM, cvdLen)
float shS = sumVS
float shTot = math.max(shL + shM + shS, 1e-9)

int covg = n   // intrabars covered this bar (0 = fallback)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              SIGNAL + CALIBRATION HARNESS  (non-repaint)
//   The harness accumulates ONLY on barstate.isconfirmed so the live bar never double-counts.
// ═════════════════════════════════════════════════════════════════════════════════════════
bool burstBull = ta.crossover(spreadSm, gate)
bool burstBear = ta.crossunder(spreadSm, -gate)
int  sigDir = burstBull ? 1 : burstBear ? -1 : 0
float atr = ta.atr(14)
var int hN = 0
var int hHit = 0
var int bT = 0
var int bU = 0
var int bD = 0
bool warm = bar_index > cvdLen + horizon + 30
if barstate.isconfirmed and warm and not na(close[horizon]) and not na(atr[horizon])
    float thr = kATR * atr[horizon]
    float mv  = close - close[horizon]
    bT += 1
    bU += mv >=  thr ? 1 : 0
    bD += -mv >= thr ? 1 : 0
    int sd = sigDir[horizon]
    if sd != 0
        hN += 1
        hHit += (sd > 0 and mv >= thr) or (sd < 0 and -mv >= thr) ? 1 : 0
float hitP  = hN > 0 ? hHit * 100.0 / hN : na
float baseP = bT > 0 ? (bU + bD) * 100.0 / (2.0 * bT) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// WILSON 95% LOWER BOUND on the hit rate. The Edge above is a POINT ESTIMATE:
// on a small sample a +4 pt reading and pure noise are indistinguishable. The
// lower bound answers the question that actually matters - what is the WORST
// the hit rate plausibly is, given this many observations? Edge LB = the lower
// bound minus the base rate. Only a POSITIVE lower bound is evidence; a
// positive point estimate on its own is not.
f_wilsonLo(int hits, int n) =>
    float outv = na
    if n > 0
        float ph  = hits / float(n)
        float z   = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv
float edgeLo   = f_wilsonLo(hHit, hN)
float edgeLB   = (not na(edgeLo) and not na(baseP)) ? edgeLo - baseP : na
bool  edgeProven = not na(edgeLB) and edgeLB > 0 and hN >= 20


// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
color histCol = spreadSm >= 0 ? color.new(GRN, 35) : color.new(RED, 35)
plot(showHist ? spreadSm : na, "Large−Small spread", histCol, style = plot.style_columns)
hline(0, "Zero", color.new(chart.fg_color, 60))
hline(gate, "Gate +", color.new(GRN, 70), hline.style_dotted)
hline(-gate, "Gate −", color.new(RED, 70), hline.style_dotted)
plot(showLines ? imbL : na, "Large-tier imbalance", color.new(imbL >= 0 ? GRN : RED, 0), 2)
plot(showLines ? imbS : na, "Small-tier imbalance", color.new(mutCol, 20), 1)
plotshape(showMarks and burstBull, "Large accumulating", shape.triangleup,   location.bottom, color.new(GRN, 0), size = size.tiny)
plotshape(showMarks and burstBear, "Large distributing", shape.triangledown, location.top,    color.new(RED, 0), size = size.tiny)
// same gated divergences mirrored onto the price chart
plotshape(showOvl and burstBull, "Large accum (price)",   shape.triangleup,   location.belowbar, color.new(GRN, 0), size = size.tiny, force_overlay = true)
plotshape(showOvl and burstBear, "Large distrib (price)", shape.triangledown, location.abovebar, color.new(RED, 0), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 9, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_row(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? rowA : rowB
    table.cell(dash, 0, r, k, text_size = size.small, text_color = mutCol, text_halign = text.align_left,  bgcolor = bg)
    table.cell(dash, 1, r, v, text_size = size.small, text_color = vc,     text_halign = text.align_right, bgcolor = bg)
if showDash and barstate.islast
    string biasTxt = math.abs(spreadSm) < gate ? "balanced" : spreadSm > 0 ? "▲ large accumulating" : "▼ large distributing"
    color  biasCol = math.abs(spreadSm) < gate ? mutCol : spreadSm > 0 ? GRN : RED
    string edgeTxt = hN < 20 ? "warming…" : str.tostring(edge, "+0.0;-0.0") + " / LB " + str.tostring(edgeLB, "+0.0;-0.0") + " (n" + str.tostring(hN) + ")"
    color  edgeCol = na(edge) or hN < 20 ? mutCol : edgeProven ? GRN : edgeLB < -3 ? RED : mutCol
    string splitTxt = str.tostring(shL / shTot * 100.0, "0") + " / " + str.tostring(shM / shTot * 100.0, "0") + " / " + str.tostring(shS / shTot * 100.0, "0") + " %"
    string covTxt = covg == 0 ? "whole-bar (no sub-bars)" : str.tostring(covg) + " sub-bars"
    table.cell(dash, 0, 0, "BURST FLOW", text_size = size.small, text_color = txtCol, text_halign = text.align_left,  bgcolor = hdrCol)
    table.cell(dash, 1, 0, syminfo.ticker, text_size = size.small, text_color = txtCol, text_halign = text.align_right, bgcolor = hdrCol)
    f_row(1, "Bias (large tier)", biasTxt, biasCol)
    f_row(2, "Large imbalance", str.tostring(imbL, "+0.00;-0.00"), imbL >= 0 ? GRN : RED)
    f_row(3, "Small imbalance", str.tostring(imbS, "+0.00;-0.00"), imbS >= 0 ? GRN : RED)
    f_row(4, "Spread L−S", str.tostring(spreadSm, "+0.00;-0.00"), biasCol)
    f_row(5, "Size split L/M/S", splitTxt, txtCol)
    f_row(6, "Coverage", covTxt, covg == 0 ? mutCol : txtCol)
    f_row(7, "Divergence leads?", edgeTxt, edgeCol)
    f_row(8, "Read", math.abs(spreadSm) >= gate ? "follow the large tier" : "no clear divergence", math.abs(spreadSm) >= gate ? biasCol : mutCol)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(spreadSm,                            "EXP_Spread",   color.new(color.gray, 100), display = display.data_window)
plot(imbL,                                "EXP_LargeImb", color.new(color.gray, 100), display = display.data_window)
plot(imbS,                                "EXP_SmallImb", color.new(color.gray, 100), display = display.data_window)
plot(burstBull ? 1 : burstBear ? -1 : 0,  "EXP_Signal",   color.new(color.gray, 100), display = display.data_window)
plot(edge,                                "EXP_Edge",     color.new(color.gray, 100), display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(burstBull, "Large accumulating", "Burst Flow: large bursts turning to net buying vs small flow.")
alertcondition(burstBear, "Large distributing", "Burst Flow: large bursts turning to net selling vs small flow.")
````

# Accumulation Distribution Divergence

- url: https://www.tradingview.com/script/l1kgftJq-Accumulation-Distribution-Divergence/
- type: indicator
- pine_id: PUB;fa25179d860a4349837a50bec8cd88f5
- version: 3.0

## Description

Overview

Accumulation Distribution Divergence turns Chaikin's Accumulation/Distribution line into a bounded pane oscillator and runs a price/oscillator divergence engine on it, with a built-in forward-calibration harness that measures whether those divergences have actually preceded a move on your instrument. It is an analytical study of accumulation versus distribution — not a strategy, not a signal, not a recommendation.

What it measures — and why it is not another CVD/MFI tool

The A/D line measures a different physical quantity from the volume oscillators most traders already run. Cumulative Volume Delta signs an entire bar's volume by tick direction; the Money Flow Index weights volume by typical price. The A/D line instead weights each bar's volume by its Close-Location-Value — how close the bar finishes to its high versus its low — so a bar that opens weak but closes on its high still accumulates. Because the input quantity is different, an A/D-line divergence is an independent read of who is in control, not a restatement of a signed-tick or typical-price oscillator. That independence is the entire point of running it alongside your existing volume tools.

How the three components work together (why they are combined)

This is a deliberate three-part construction, not a random stack. Each part answers a question the previous one leaves open:


The oscillator answers "is volume accumulating or distributing right now?" — the raw A/D line drifts endlessly and can't be read on a fixed scale, so it is detrended (subtract its EMA), z-scored over a window to put it on a portable σ axis, and tanh-squashed to a soft ±100 pane where 0 is balance and the ±50 bands mark an accumulation/distribution edge.
The divergence engine answers "is that flow diverging from price?" — it compares confirmed price pivots to the oscillator at those pivots. Regular divergence (price makes a new extreme, flow does not) flags thinning conviction; hidden divergence flags trend continuation. Divergence alone, though, is famously prone to firing early and often.

The calibration harness answers the question every divergence tool leaves unanswered: "has this class of divergence actually paid on this symbol?" Every regular divergence is queued and resolved a fixed horizon later against the unconditional same-horizon base rate, and the dashboard reports Hit % / Edge / sample size with a Wilson-score-gated star. A divergence that never beats the base rate is adding no information — and now you can see that instead of assuming it.


Together: a distinct volume lens, a divergence read on it, and an honesty layer that tells you whether the read is worth anything on the instrument in front of you.

How to use it


Read the oscillator's side and slope — above 0 is net accumulation, below 0 is net distribution.

Treat a divergence mark as context (conviction thinning or trend confirming), never as a standalone entry. It marks a condition, not a trade.

Read the dashboard before you weight a divergence: if the Bull/Bear Edge is not clearly positive with an adequate sample and a star, that class is not carrying an edge on this instrument right now.

Combine with your own level/trend framework and risk rules. This tool describes behaviour; it does not decide anything for you.


Settings

Five grouped sections: Data source (High/Low series for the pivots — configurable so the engine runs on any market), A/D engine (detrend EMA and normalization window), Divergence (pivot strength, max bars between pivots, hidden on/off, connecting lines), Calibration (forward horizon, minimum sample for stars), and Dashboard & theme (position, auto/dark/light palette that reads the chart background so the table stays legible, and the bull/bear colours).

Universality & data note

High/Low are inputs, so the divergence engine works on any symbol or timeframe. The A/D line, however, needs real volume — on a no-volume symbol (like a cash index) the dashboard reads "no volume" and no signals fire. Use the futures contract. Defaults target liquid index-futures intraday; change the sources and lengths for any other asset.

Non-repainting

Pivots confirm a fixed number of bars after the fact and do not move once printed. The calibration harness logs and resolves only on confirmed bars, so its statistics never repaint. The live oscillator value updates each bar, like any oscillator.

Originality

The Accumulation/Distribution line and Close-Location-Value are Marc Chaikin's public concepts; the Wilson score interval is Edwin B. Wilson's; price/oscillator divergence is a standard public technique. What is original here is the specific construction: the detrend → z-score → tanh-squash oscillator that makes the A/D line readable on a fixed bounded scale, the combined regular+hidden divergence engine keyed to that oscillator, and — most importantly — the forward-calibration harness that scores each divergence class against its unconditional base rate with a Wilson-gated confidence read. This is a clean-room implementation; no third-party script code is reused.

Concept credits


Accumulation/Distribution line & Close-Location-Value — Marc Chaikin
Wilson score confidence interval — Edwin B. Wilson
Price/oscillator divergence — standard public technical-analysis technique


Disclaimer

Educational / informational only. Not financial advice, not a signal, not a recommendation. The oscillator describes past volume-and-location behaviour; the edge figures are in-sample, forward-measured at a fixed horizon over overlapping windows, with no costs, slippage or stops — read them as context, not a verified backtest. Past behaviour does not assure future behaviour. Markets carry risk. Do your own research and paper-trade before risking capital; you alone are responsible for your decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// ACCUMULATION / DISTRIBUTION DIVERGENCE                                                     v1.2
//  v1.2 (R1 · honest-stats standardization): robust-z via ml_robuststats/2 and the Wilson confidence math via
//    ml_calib/2 — both byte-identical to the prior local helpers, so the oscillator, the divergence marks and
//    every calibration number are UNCHANGED. Imports pinned to the exact published v2 versions.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   Chaikin's Accumulation/Distribution line — volume weighted by WHERE price closes inside each
//   bar's range — detrended into a bounded pane oscillator, with a regular + hidden price/
//   oscillator divergence engine and a forward-calibration harness that scores whether those
//   divergences have actually preceded a move on YOUR instrument. It is an analytical study of
//   accumulation vs distribution — not a strategy, not a signal, not a recommendation.
//
// WHY IT IS DIFFERENT  (and not a duplicate of a CVD / MFI tool)
//   The A/D line measures a DIFFERENT physical quantity from cumulative volume delta or the Money
//   Flow Index. CVD signs a whole bar's volume by tick direction; MFI weights by typical price.
//   The A/D line instead weights volume by the Close-Location-Value — how near the close finishes
//   to the high vs the low of the SAME bar — so a bar that closes on its high accumulates even if
//   it opened lower. An A/D-line divergence is therefore its own, independent read of who is in
//   control, not a restatement of a signed-tick or typical-price oscillator.
//
// HOW IT WORKS
//   • CLV  = ((close − low) − (high − close)) / (high − low)          (−1 at the low … +1 at the high)
//   • A/D  = cumulative( CLV × volume )                              (Chaikin's running line)
//   • OSC  = A/D − EMA(A/D)  → z-scored over a window → tanh-squashed to a soft ±100 pane scale.
//     0 = balance; the +50 / −50 bands mark an accumulation / distribution edge (~1.6σ stretch).
//   • DIVERGENCE compares CONFIRMED price pivots against the oscillator at those pivots:
//       regular bull = price lower-low, oscillator higher-low  (selling losing conviction)
//       regular bear = price higher-high, oscillator lower-high (buying losing conviction)
//       hidden variants flag trend-continuation. Regular divergences also draw a connecting line.
//   • CALIBRATION queues every regular divergence and resolves it a fixed horizon later against
//     the UNCONDITIONAL same-horizon base rate, reporting Hit % / Edge / sample and a Wilson-gated
//     star. A divergence that never beats the base rate on your symbol is adding no information.
//
// HOW TO USE
//   1. Read the oscillator's side and slope: above 0 = net accumulation, below 0 = net distribution.
//   2. Treat a divergence as CONTEXT (conviction thinning), never as a standalone trigger. It marks
//      a condition, not an entry.
//   3. Read the dashboard: if the Bull / Bear Edge is not clearly positive with an adequate sample
//      and a star, that divergence class is not carrying an edge on this instrument — weight it down.
//   4. Combine with your own level / trend framework and risk rules. This tool describes behaviour;
//      it does not decide anything for you.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   High / Low sources are inputs, so the divergence engine runs on any symbol or timeframe. The
//   A/D line needs REAL volume — use a futures contract (e.g. NSE:NIFTY1! for NIFTY, whose cash
//   index reports no volume). On a no-volume symbol the dashboard reads "no volume" and no signals
//   fire. Defaults target liquid index-futures intraday; change the sources / lengths for any asset.
//
// NON-REPAINT
//   Pivots confirm pivLen bars after the fact and do not move once printed. The calibration harness
//   logs AND resolves only on barstate.isconfirmed, so its statistics never repaint. The live
//   oscillator value updates each bar (a current estimate), like any oscillator.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_ADosc · EXP_ADline · EXP_Div   (Div: +1 bull divergence, −1 bear divergence, 0 none)
//
// CONCEPT CREDIT
//   • Accumulation/Distribution line & Close-Location-Value — Marc Chaikin.
//   • Wilson score confidence interval — Edwin B. Wilson.
//   • Price/oscillator divergence — standard public technical-analysis technique.
//   The detrend-and-squash construction, the divergence engine and the forward-calibration harness
//   are the author's original implementation.
//
// CHANGELOG
//   v1.1 (Wave A) — Added an optional ROBUST normalization. The detrended A/D line can now be
//     standardized with a MEDIAN / MAD z-score (median absolute deviation × 1.4826) instead of the
//     classic mean / stdev z. MAD ignores the fat outlier bars that A/D produces around news spikes,
//     so the ±50 accumulation / distribution bands keep a consistent meaning instead of being blown
//     out by a single burst. Selectable via "Normalization" in group 2; defaults to Robust (MAD).
//     Set it back to "Classic (mean/stdev)" for the exact v1.0 behaviour. No signal logic changed.
//
// DISCLAIMER
//   EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a signal, NOT a recommendation. The
//   oscillator describes past volume-and-location behaviour; the edge figures are in-sample,
//   forward-measured at a fixed horizon over overlapping windows, with no costs, slippage or stops —
//   read them as context, not a verified backtest. Past behaviour does not assure future behaviour.
//   Markets carry risk. Do your own research and paper-trade before risking capital; you alone are
//   responsible for your decisions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Accumulation Distribution Divergence", "AD Div", overlay = false, max_lines_count = 100, max_labels_count = 200)

// R1 · honest-stats standardization — robust-z and the Wilson confidence math are now routed through the
// published calibration libraries (one engine across the divergence family). Both are byte-identical to the
// prior local f_robZ / f_wilson, so the oscillator, the divergence marks and every calibration number are
// UNCHANGED — only where the math is computed moves into the libraries. Pinned to the exact published v2
// versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat


// ── INPUTS ────────────────────────────────────────────────────────────────────────────────────
gData    = "1 · Data source"
srcHigh  = input.source(high, "High source (bearish divergence)", group = gData, tooltip = "Price series for bearish-divergence pivots. Default = high.")
srcLow   = input.source(low,  "Low source (bullish divergence)",  group = gData, tooltip = "Price series for bullish-divergence pivots. Default = low.")

gEng     = "2 · A/D engine"
detLen   = input.int(34,  "Detrend EMA", minval = 2, maxval = 200, group = gEng, tooltip = "The A/D line is detrended by subtracting this EMA, turning a drifting cumulative line into a stationary oscillator.")
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gEng, tooltip = "Window for the z-score that puts the detrended line onto a portable, self-scaling σ axis.")
zMode    = input.string("Robust (MAD)", "Normalization", options = ["Robust (MAD)","Classic (mean/stdev)"], group = gEng, tooltip = "Robust (MAD) standardizes with median / median-absolute-deviation (×1.4826) — it ignores the fat outlier bars A/D throws off around news, so the bands stay stable. Classic reproduces the original mean/stdev z-score.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = gEng, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")

gDiv     = "3 · Divergence"
pivLen   = input.int(5,  "Pivot L/R", minval = 1, maxval = 50, group = gDiv, tooltip = "Bars of confirmation on each side of a pivot. Larger = fewer, sturdier pivots but a longer confirmation delay.")
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv, tooltip = "A divergence is only valid if the two pivots it connects are no more than this many bars apart.")
showHid  = input.bool(true, "Hidden divergences", group = gDiv, tooltip = "Also flag hidden (trend-continuation) divergences, not just regular (reversal-context) ones.")
drawLines= input.bool(true, "Draw divergence lines", group = gDiv, tooltip = "Draw the connecting line between the two oscillator pivots of a regular divergence.")

gCal     = "4 · Calibration (forward)"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score each regular divergence against the unconditional forward base rate. Read as context, not a backtest.")
calHor   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = gCal, tooltip = "How many bars ahead each divergence is resolved when measuring follow-through.")
calMinN  = input.int(15, "Min sample for stars", minval = 5, maxval = 500, group = gCal, tooltip = "Below this many samples a class stays 'warming' and shows no star — too few events to judge.")
wfTrainN = input.int(30, "In-sample signals before out-of-sample (walk-forward)", minval = 5, group = gCal, tooltip = "Wave E honesty: the first N resolved signals TRAIN (in-sample); every signal after is scored OUT-OF-SAMPLE. The OOS win-rate is the trustworthy one — an in-sample edge can flatter because the settings were chosen on that same data.")

gUI      = "5 · Dashboard & theme"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto reads the chart background luminance and picks a legible palette; force Dark / Light if you prefer.")
colUp    = input.color(#2ebd85, "Bull / Up",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Bear / Down", inline = "c", group = gUI)

// ── HELPERS ─────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
// robust z: median / MAD (median absolute deviation × 1.4826 ≈ σ for a normal). Both ta.median
// calls run UNCONDITIONALLY so this compiles clean; outlier bars barely move the median or the MAD.
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e  = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, simple float k) => 100.0 * f_tanh(x / k)      // soft-bound a σ value to (−100, +100)
f_star(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"

// ── ENGINE ──────────────────────────────────────────────────────────────────────────────────
hasVol = ta.cum(nz(volume)) > 0
clv    = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
ad     = ta.cum(clv * nz(volume))
adOsc  = ad - ta.ema(ad, detLen)
// compute BOTH normalizations unconditionally (Pine v6: ta.* must not sit inside a branch), then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_zscore(adOsc, _wS), _zcM = f_zscore(adOsc, normLen), _zcL = f_zscore(adOsc, _wL)
float _zrS = rstat.robZ(adOsc, _wS),  _zrM = rstat.robZ(adOsc, normLen),  _zrL = rstat.robZ(adOsc, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
float adZ = zWinMode == "Single window" ? _zM : _zMed
osc    = f_squash(adZ, 3)                                      // ≈ ±50 bands at ~1.6σ, asymptotes at ±100

// ── DIVERGENCE ENGINE ─────────────────────────────────────────────────────────────────────────
ph  = ta.pivothigh(srcHigh, pivLen, pivLen)
pl  = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen

oH  = osc[pivLen]
pHh = srcHigh[pivLen]
poH = ta.valuewhen(phC, osc[pivLen], 1)
ppH = ta.valuewhen(phC, srcHigh[pivLen], 1)
pxH = ta.valuewhen(phC, bar_index - pivLen, 1)
bearReg = phC and pHh > ppH and oH < poH and (curX - pxH <= divLook)
bearHid = showHid and phC and pHh < ppH and oH > poH and (curX - pxH <= divLook)

oL  = osc[pivLen]
pLl = srcLow[pivLen]
poL = ta.valuewhen(plC, osc[pivLen], 1)
ppL = ta.valuewhen(plC, srcLow[pivLen], 1)
pxL = ta.valuewhen(plC, bar_index - pivLen, 1)
bullReg = plC and pLl < ppL and oL > poL and (curX - pxL <= divLook)
bullHid = showHid and plC and pLl > ppL and oL < poL and (curX - pxL <= divLook)

bullDiv = bullReg or bullHid
bearDiv = bearReg or bearHid

if drawLines and bearReg
    line.new(int(pxH), poH, curX, oH, color = color.new(colDn, 30), width = 2)
if drawLines and bullReg
    line.new(int(pxL), poL, curX, oL, color = color.new(colUp, 30), width = 2)

// regular divergences are the events the harness scores (hidden are shown but not scored)
bullEval = bullReg and hasVol
bearEval = bearReg and hasVol
stTxt = not hasVol ? "no volume" : osc >= 0 ? "Accumulation" : "Distribution"
wCol  = osc >= 0 ? colUp : colDn

// ── CALIBRATION (forward, non-repainting) ───────────────────────────────────────────────────────
var int buyN  = 0
var int buyW  = 0
var int sellN = 0
var int sellW = 0
var int baseN = 0
var int baseW = 0
// Wave E — walk-forward out-of-sample split (trustworthy reliability, additive)
var int   wfResolved = 0
var float wfBuyOosW = 0.0, var float wfBuyOosN = 0.0
var float wfSellOosW = 0.0, var float wfSellOosN = 0.0
canEval = calOn and barstate.isconfirmed and not na(close[calHor])
if canEval
    if bullEval[calHor]
        buyN += 1
        bool _wB = close > close[calHor]
        buyW += _wB ? 1 : 0
        wfResolved += 1
        if wfResolved > wfTrainN
            wfBuyOosN += 1.0
            wfBuyOosW := wfBuyOosW + (_wB ? 1.0 : 0.0)
    if bearEval[calHor]
        sellN += 1
        bool _wS = close < close[calHor]
        sellW += _wS ? 1 : 0
        wfResolved += 1
        if wfResolved > wfTrainN
            wfSellOosN += 1.0
            wfSellOosW := wfSellOosW + (_wS ? 1.0 : 0.0)
    baseN += 1
    baseW += close > close[calHor] ? 1 : 0
buyHit   = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit  = sellN > 0 ? sellW / sellN * 100.0 : na
baseUp   = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn   = baseN > 0 ? 100.0 - baseUp : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na

// Wave E — out-of-sample (walk-forward) win rates: the trustworthy read
float wfBuyOosHit  = wfBuyOosN  > 0 ? wfBuyOosW  / wfBuyOosN  * 100.0 : na
float wfSellOosHit = wfSellOosN > 0 ? wfSellOosW / wfSellOosN * 100.0 : na
float wfBuyOosEdge  = (not na(wfBuyOosHit)  and not na(baseUp)) ? wfBuyOosHit  - baseUp : na
float wfSellOosEdge = (not na(wfSellOosHit) and not na(baseDn)) ? wfSellOosHit - baseDn : na
buyStar  = f_star(calib.wilsonLo(buyW, buyN, 1.96),   baseUp, buyN)
sellStar = f_star(calib.wilsonLo(sellW, sellN, 1.96), baseDn, sellN)

// ── PLOTS ─────────────────────────────────────────────────────────────────────────────────────
pObIn  = plot(50.0,  "Accum edge", color.new(colUp, 35), 1)
pObOut = plot(100.0, "Accum cap",  color.new(colUp, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(colUp, 18), color.new(colUp, 92), title = "Accumulation")
pOsIn  = plot(-50.0,  "Distrib edge", color.new(colDn, 35), 1)
pOsOut = plot(-100.0, "Distrib cap",  color.new(colDn, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(colDn, 92), color.new(colDn, 18), title = "Distribution")
hline(0, "Zero", color.new(color.gray, 60))

plot(osc, "A/D glow", color.new(wCol, 70), 8)
plot(osc, "A/D",      color.new(wCol, 0),  2)

plotshape(bullDiv ? oL : na, "Bull div", shape.circle, location.absolute, color.new(colUp, 0), offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? oH : na, "Bear div", shape.circle, location.absolute, color.new(colDn, 0), offset = -pivLen, size = size.tiny)
plotshape(bullReg, "Bull mark", shape.triangleup,   location.belowbar, color.new(colUp, 0), size = size.tiny, force_overlay = true)
plotshape(bearReg, "Bear mark", shape.triangledown, location.abovebar, color.new(colDn, 0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
var table st = table.new(f_pos(tblPos), 2, 8, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color bgc     = chart.bg_color
    float lumaV   = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
    bool  darkUI  = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
    color panelBg = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
    color rowAlt  = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
    color txtMain = darkUI ? color.white            : color.rgb(16,20,24)
    color txtSub  = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
    color frameC  = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
    color upC     = darkUI ? colUp : color.rgb(22,151,106)
    color dnC     = darkUI ? colDn : color.rgb(210,45,68)
    color flatC   = darkUI ? color.gray : color.rgb(122,130,139)
    color hdr     = color.new(colUp, 0)
    string divTxt = bullDiv ? "Bull div" : bearDiv ? "Bear div" : "—"
    color  divC   = bullDiv ? upC : bearDiv ? dnC : flatC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    table.cell(st, 0, 0, "A/D Divergence", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, str.upper(stTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "A/D osc", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 1, str.tostring(osc,"#"), text_color = osc>=0?upC:dnC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 2, "Divergence", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, divTxt, text_color = divC, bgcolor = panelBg, text_size = size.tiny)
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming" : "up " + str.tostring(baseUp,"0") + "  dn " + str.tostring(baseDn,"0")
        string buyTxt  = buyN  < calMinN ? "warm " + str.tostring(buyN)  : "H" + str.tostring(buyHit,"0")  + "  E" + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warm " + str.tostring(sellN) : "H" + str.tostring(sellHit,"0") + "  E" + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, 3, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 3, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 0, 4, "Bull " + buyStar, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 4, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 0, 5, "Bear " + sellStar, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 5, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 0, 6, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 6, "context only · not advice", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 0, 7, "OOS win (walk-fwd)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 7, (wfBuyOosN < 1 and wfSellOosN < 1) ? "warming" : "L " + (na(wfBuyOosHit) ? "-" : str.tostring(wfBuyOosHit, "0") + "%") + "  S " + (na(wfSellOosHit) ? "-" : str.tostring(wfSellOosHit, "0") + "%"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)

// ── EXPORTS / ALERTS ──────────────────────────────────────────────────────────────────────────
plot(osc, "EXP_ADosc", color.new(color.gray,100), display = display.data_window)
plot(ad,  "EXP_ADline", color.new(color.gray,100), display = display.data_window)
plot(bullDiv ? 1 : bearDiv ? -1 : 0, "EXP_Div", color.new(color.gray,100), display = display.data_window)
plot(wfBuyOosEdge,  "EXP_OOSLongEdge",  color.new(color.gray,100), display = display.data_window)
plot(wfSellOosEdge, "EXP_OOSShortEdge", color.new(color.gray,100), display = display.data_window)
alertcondition(bullReg, "Bull Divergence", "A/D: bullish divergence (context)")
alertcondition(bearReg, "Bear Divergence", "A/D: bearish divergence (context)")
alertcondition(ta.crossover(osc, 0),  "AD Above Zero", "A/D oscillator crossed above zero (net accumulation)")
alertcondition(ta.crossunder(osc, 0), "AD Below Zero", "A/D oscillator crossed below zero (net distribution)")
````

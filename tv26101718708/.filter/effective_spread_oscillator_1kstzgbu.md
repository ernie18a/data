# Effective Spread Oscillator

- url: https://www.tradingview.com/script/1kstzGBU-Effective-Spread-Oscillator/
- type: indicator
- pine_id: PUB;227380ba0b9c49bf96eea4a34c222da2
- version: 2.0

## Description

Overview

Effective Spread Oscillator is a liquidity gauge built from price alone. It estimates the effective bid-ask spread — the real round-trip cost of trading — from open/high/low/close bars, with no quote or order-book data, then percentile-ranks it into a 0–100 read. High = a wide effective spread: thin, illiquid, stressed conditions where slippage and gaps are large. Low = a tight spread: deep, liquid, orderly trade. It is an analytical study of market liquidity and trading friction — not a directional signal and not a strategy.

Why these parts are ONE tool (mashup justification)

Liquidity is normally invisible without Level-2 data. This reconstructs it from bars and then makes it usable, in a chain where each link fixes what the previous one can't do alone:


A low-frequency spread estimator recovers the effective spread from the geometry of OHLC prices — the cost the tape hides. Two are offered: Abdi-Ranaldo (close vs the high-low mid-range) and Corwin-Schultz (consecutive high-low ranges). Negative small-sample estimates — a known statistical artefact of these methods — are floored at zero.
Percentile ranking turns an instrument-specific cost into a universal 0–100 read, so "expensive liquidity" means the same thing on an index future, a stock, or FX. A raw spread number in basis points is not comparable across symbols; a percentile is.
A liquidity-state verdict (stressed / normal / liquid) plus a widening-vs-tightening read makes it legible at a glance, which a bare number isn't.
The calibration harness then tests the well-documented link on your instrument: does a spread spike actually precede a volatility expansion? It reports the conditional hit rate against the unconditional base rate, so you see the Edge rather than assume it.


Chained, they answer one question: is liquidity stressed right now, and has that stress preceded bigger moves here?

How it works

The estimator is computed on log prices and evaluated one bar back (so no future value is referenced), averaged over a window, optionally smoothed, and percentile-ranked over a lookback into the 0–100 oscillator. A spike arms when the spread crosses into the high band; the harness then checks whether the realised range over the next horizon exceeds k × ATR × √horizon more often than the base rate. (The √horizon term keeps the base rate informative near 50% instead of saturating on intraday charts.)

How to use it

The high band (above the upper guide) is stressed / illiquid: widen stops, expect slippage and gaps, and treat breakouts with care — this is where volatility expansions cluster. The low band is liquid / orderly: tighter behaviour, cleaner fills. Use it as a risk and position-sizing context that sits behind your directional tools, and read the Edge row to see whether spread spikes have actually preceded bigger ranges on this symbol. Spikes are marked in the pane and, optionally, on the price chart. The dashboard has a Compact layout (default) and a Pro layout (estimator in use, spread in bps, spike sample, base rate). Context — never a standalone trigger.

Universal across markets

The high / low / close inputs are configurable, so it runs on any instrument and timeframe. Defaults target intraday index futures. Crucially, it needs no volume, so it also works on volume-less feeds (cash indices, spot FX) where flow-based tools cannot.

Non-repainting

The estimator is evaluated one bar back, so it never references a future value, and the calibration harness logs and resolves only on confirmed bars, so its statistics never inflate intrabar. The live oscillator value updates each bar, like any oscillator.

Originality

The spread estimators are published academic work, credited below. What's original here is the construction around them: the percentile normalisation that makes the cost comparable across instruments, the liquidity-state and widening/tightening read, the price-overlay stress marker, and — most of all — the forward-calibration harness that tests the spread-spike → volatility-expansion link against a base rate on your own symbol rather than asserting it. Clean-room implementation; no third-party code reused.

Concept credits


Serial-covariance spread estimator — Richard Roll (1984)
High-low range spread — Shane Corwin & Paul Schultz (2012)
Close-high-low spread — Farshid Abdi & Angelo Ranaldo (2017)
The current state of the art generalising this family to the full OHLC information set is the EDGE estimator of David Ardia, Emanuele Guidotti & Tim Kroencke (Journal of Financial Economics, 2024). This script implements the Corwin-Schultz and Abdi-Ranaldo estimators.


Honest limits

These are estimates of the effective spread from bar geometry, not measured quotes — accurate in aggregate, noisy bar to bar, which is exactly why a window and smoothing are used. Estimates can be small and are floored at zero in tiny samples. The Edge figures are in-sample, with overlapping forward windows and no costs — descriptive context, not a verified backtest. Nothing here predicts direction.

Disclaimer

Research and educational tool only. Not financial advice and no guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// EFFECTIVE SPREAD OSCILLATOR                                                             v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Confidence interval on the calibration edge (no engine change):
//   The harness reported the spike→volatility-expansion Edge (conditional hit% − base%) as a bare
//   number. v1.1 adds a WILSON 95% interval on the conditional hit rate and a significance verdict:
//   the edge is ✓sig only when the interval's LOWER BOUND clears the base rate — so a small edge on a
//   thin sample is no longer mistaken for a real one. Shown in the panel and exported (EXP_EdgeLB).
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A liquidity gauge built from price alone. It estimates the EFFECTIVE BID-ASK SPREAD - the real
//   round-trip cost of trading - from open/high/low/close bars, with no quote or order-book data,
//   then percentile-ranks it into a 0-100 read. HIGH = a wide effective spread: thin, illiquid,
//   stressed conditions where slippage and gaps are large. LOW = a tight spread: deep, liquid,
//   orderly trade. It is an analytical study of market LIQUIDITY and trading friction - not a
//   directional signal and not a strategy.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not three studies)
//   Liquidity is usually invisible without Level-2 data; this reconstructs it from bars and makes
//   it actionable in a chain:
//     - A LOW-FREQUENCY SPREAD ESTIMATOR (chosen from a small family) recovers the effective spread
//       from the geometry of OHLC prices - the cost the tape hides.
//     - PERCENTILE RANKING turns an instrument-specific cost into a universal 0-100 read, so
//       "expensive liquidity" means the same thing on NIFTY, a stock, or FX.
//     - A LIQUIDITY-STATE verdict and a widening/tightening read summarise it at a glance.
//     - The CALIBRATION HARNESS then tests the well-documented link on YOUR instrument: does a
//       spread spike precede a VOLATILITY EXPANSION? It reports Edge vs the unconditional base rate.
//   A raw spread number is not comparable across symbols; a comparable number without the spike
//   test is just a gauge; the test without the state read is hard to use live. Chained, they answer
//   one question: is liquidity stressed right now, and has stress preceded bigger moves here?
//
// HOW IT WORKS
//   1. The effective spread is estimated by a low-frequency method:
//        - Abdi-Ranaldo: from close and the high-low mid-range (close + high + low).
//        - Corwin-Schultz: from consecutive high-low ranges.
//      Negative small-sample estimates (a known statistical artefact) are floored at zero.
//   2. The spread is smoothed and percentile-ranked over a lookback into the 0-100 oscillator.
//   3. A spike arms when the spread is in the high band; the harness checks whether realised range
//      over the next horizon exceeds k x ATR more often than the unconditional base rate.
//
// HOW TO USE
//   High band (above the upper guide) = stressed / illiquid: widen stops, expect slippage and
//   gaps, and treat breakouts with care; this is where volatility expansions cluster. Low band =
//   liquid / orderly: tighter behaviour, cleaner fills. Use it as a RISK and position-sizing
//   context that sits behind your directional tools, and read the Edge row to see whether spread
//   spikes have actually preceded bigger ranges on this symbol. Context, never a standalone trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   The high / low / close inputs are configurable, so it runs on any instrument and timeframe.
//   Defaults target intraday index futures (e.g. NSE NIFTY). It needs no volume, so it also works
//   on volume-less feeds (indices, spot FX) where flow tools cannot.
//
// NON-REPAINT
//   The estimator is evaluated one bar back, so no future value is referenced. The calibration
//   harness logs AND resolves only on barstate.isconfirmed, so its statistics never inflate
//   intrabar. The live oscillator value updates each bar (a current estimate), like any oscillator.
//
// EXPORTS  (Data Window - consume from other scripts via input.source())
//   EXP_SpreadPct (0-100) · EXP_SpreadBps · EXP_State (+1 stressed / -1 liquid / 0 normal) ·
//   EXP_Spike (1 on a spread spike) · EXP_Edge · EXP_EdgeLB (Wilson lower bound of the edge, pts;
//   > 0 = the spike→expansion edge is significant)
//
// CONCEPT CREDIT
//   The low-frequency effective-spread family this implements: serial-covariance spread - Richard
//   Roll (1984); high-low range spread - Shane Corwin & Paul Schultz (2012); close-high-low spread
//   - Farshid Abdi & Angelo Ranaldo (2017). The current state of the art generalising this family
//   to the full OHLC information set is the EDGE estimator of David Ardia, Emanuele Guidotti &
//   Tim Kroencke (Journal of Financial Economics, 2024). This script implements the Corwin-Schultz
//   and Abdi-Ranaldo estimators; the percentile read, state logic and calibration are its own work.
//   No third-party code is reused; not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   These are ESTIMATES of the effective spread from bar geometry, not measured quotes - accurate
//   in aggregate, noisy bar to bar, which is why a window and smoothing are used. Estimates can be
//   small and are floored at zero in tiny samples. The Edge figures are in-sample, with overlapping
//   forward windows and no costs - descriptive context, not a verified backtest. Nothing here
//   predicts direction.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Effective Spread Oscillator", "EffSpread", overlay = false, max_labels_count = 120)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── 01 · DATA & SOURCE ──────────────────────────────────────────────────────────────────
g0 = "01 · Data & source"
srcH = input.source(high,  "High source",  group = g0, tooltip = "OHLC inputs the spread is estimated from. Works on any symbol / market, with or without volume.")
srcL = input.source(low,   "Low source",   group = g0)
srcC = input.source(close, "Close source", group = g0)

// ── 02 · SPREAD ESTIMATE ────────────────────────────────────────────────────────────────
g1 = "02 · Spread estimate"
method = input.string("Abdi-Ranaldo (close-high-low)", "Estimator", options = ["Abdi-Ranaldo (close-high-low)","Corwin-Schultz (high-low)"], group = g1, tooltip = "Two low-frequency effective-spread estimators. Abdi-Ranaldo uses close + mid-range and is robust; Corwin-Schultz uses consecutive high-low ranges.")
win = input.int(20, "Averaging window (bars)", minval = 2, maxval = 200, group = g1, tooltip = "Bars the spread moment is averaged over. Higher = steadier estimate.")
sprSmooth = input.int(3, "Smoothing (EMA, 1 = off)", minval = 1, maxval = 50, group = g1)
pctLen = input.int(200, "Percentile lookback", minval = 30, maxval = 1000, group = g1, tooltip = "Window the spread is ranked against for the 0-100 read.")

// ── 03 · STATE ──────────────────────────────────────────────────────────────────────────
g2 = "03 · State"
hiThr = input.int(80, "Stressed above (%)", minval = 50, maxval = 100, group = g2)
loThr = input.int(20, "Liquid below (%)", minval = 0, maxval = 50, group = g2)
showSpike = input.bool(true, "Mark spread spikes", group = g2)

// ── 04 · CALIBRATION HARNESS ────────────────────────────────────────────────────────────
g4 = "04 · Calibration harness"
calibOn = input.bool(true, "Run calibration", group = g4, tooltip = "Logs each spread spike and checks whether realised range over the next horizon exceeds k x ATR more often than the unconditional base rate. Edge = conditional - base.")
calHor  = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
calMove = input.float(1.2, "Range threshold (x ATR x √horizon)", minval = 0.1, step = 0.1, group = g4, tooltip = "Forward range counts as an expansion if it exceeds this multiple of ATR x √horizon. The √horizon term keeps the base rate near 50% (informative) instead of saturating at 100% on intraday charts.")
calAtrLen = input.int(14, "ATR length", minval = 1, group = g4)

// ── 05 · VISUAL STYLE ───────────────────────────────────────────────────────────────────
g5 = "05 · Visual style"
visStyle = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = g5)
colLiq   = input.color(#2ebd85, "Liquid", inline = "cc", group = g5)
colStr   = input.color(#f6465d, "Stressed", inline = "cc", group = g5)
colMid   = input.color(#f7c948, "Midline", group = g5)

// ── 06 · DASHBOARD & THEME ──────────────────────────────────────────────────────────────
g6 = "06 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelMode = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g6, tooltip = "Compact (default) = the liquidity verdict, percentile, trend and Edge. Pro = adds the estimator in use, the spread in basis points, the spike sample and the unconditional base rate.")
panelPos  = input.string("Bottom Right", "Dashboard position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)
showOvl   = input.bool(true, "Mark spread spikes on price (overlay)", group = g6, tooltip = "Draw a marker on the price chart when a spread spike fires - a liquidity-stress warning next to price.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ENGINE · low-frequency effective spread
// ═════════════════════════════════════════════════════════════════════════════════════════
float h = math.log(srcH)
float l = math.log(srcL)
float c = math.log(srcC)
float eta = (h + l) / 2.0

// Abdi-Ranaldo (2017): S^2 = 4 * E[(c_t - eta_t)(c_t - eta_{t+1})], evaluated one bar back so
// no future value is referenced (non-repaint).
float arProd = (c[1] - eta[1]) * (c[1] - eta[0])
float arS2 = 4.0 * ta.sma(arProd, win)
float sprAR = math.sqrt(math.max(arS2, 0.0))

// Corwin-Schultz (2012): from one- and two-bar high-low ranges.
float hl2 = math.pow(math.log(srcH / srcL), 2.0)
float beta = hl2 + hl2[1]
float h2 = math.max(srcH, srcH[1])
float l2 = math.min(srcL, srcL[1])
float gamma = math.pow(math.log(h2 / l2), 2.0)
float kCS = 3.0 - 2.0 * math.sqrt(2.0)
float alpha = (math.sqrt(2.0 * beta) - math.sqrt(beta)) / kCS - math.sqrt(gamma / kCS)
float csRaw = 2.0 * (math.exp(alpha) - 1.0) / (1.0 + math.exp(alpha))
float sprCSbar = math.max(csRaw, 0.0)
float sprCS = ta.sma(sprCSbar, win)

float sprRaw = method == "Corwin-Schultz (high-low)" ? sprCS : sprAR
float sprS = ta.ema(sprRaw, sprSmooth)
float spr = sprSmooth > 1 ? sprS : sprRaw
float sprBps = spr * 10000.0
float osc = ta.percentrank(spr, pctLen)

bool spike = osc >= hiThr and osc[1] < hiThr
float oscTrend = ta.ema(osc, 3)
bool widening = oscTrend > oscTrend[2]

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(50.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(50, "Median liquidity", color = color.new(colMid, 0), linestyle = hline.style_solid)
hline(hiThr, "Stressed", color = color.new(colStr, 55), linestyle = hline.style_dotted)
hline(loThr, "Liquid", color = color.new(colLiq, 55), linestyle = hline.style_dotted)
hline(100, "Max", color = color.new(colStr, 75), linestyle = hline.style_dashed)
hline(0, "Min", color = color.new(colLiq, 75), linestyle = hline.style_dashed)

pStrEdge = plot(float(hiThr), "z str edge", color = na, display = display.none, editable = false)
pTop     = plot(100.0,        "z top",      color = na, display = display.none, editable = false)
pLiqEdge = plot(float(loThr), "z liq edge", color = na, display = display.none, editable = false)
pBot     = plot(0.0,          "z bot",      color = na, display = display.none, editable = false)
fill(pStrEdge, pTop, 100.0, float(hiThr), color.new(colStr, 32), color.new(colStr, 90), title = "Stressed zone")
fill(pLiqEdge, pBot, float(loThr), 0.0, color.new(colLiq, 90), color.new(colLiq, 32), title = "Liquid zone")

color oCol = na(osc) ? color.gray : osc >= 50 ? colStr : colLiq
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showLine = isArea or isLine
plot(showLine ? osc : na, "glow outer", color = color.new(oCol, 82), linewidth = 8, display = display.pane)
plot(showLine ? osc : na, "glow inner", color = color.new(oCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showLine ? osc : na, "Spread percentile", color = oCol, linewidth = 2, display = display.pane)
plot(isHist ? osc : na, "Histogram", color = color.new(oCol, 25), style = plot.style_columns, display = display.pane)
pBase = plot(isArea ? 50.0 : na, "area base", color = na, display = display.none, editable = false)
fill(pMain, pBase, color = isArea ? color.new(oCol, 80) : na, title = "Area")

plotshape(showSpike and spike ? osc : na, "Spread spike", shape.triangleup, location.absolute, color.new(colStr, 0), size = size.tiny)
// spread spikes mirrored onto the price chart (liquidity-stress warning next to price)
plotshape(showOvl and spike, "Spread spike (price)", shape.xcross, location.abovebar, color.new(colStr, 0), size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          CALIBRATION  (does a spread spike precede vol expansion?)
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrC = ta.atr(calAtrLen)
float fwdRange = ta.highest(high, calHor) - ta.lowest(low, calHor)
var int sigN = 0
var int hitN = 0
var int baseTot = 0
var int baseHit = 0
float fr  = fwdRange
float fa  = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fa) and fa > 0
    bool expanded = fr >= calMove * fa * math.sqrt(calHor)
    if spike[calHor]
        sigN += 1
        if expanded
            hitN += 1
    baseTot += 1
    if expanded
        baseHit += 1

float hitP  = sigN > 0 ? hitN * 100.0 / sigN : na
float baseP = baseTot > 0 ? baseHit * 100.0 / baseTot : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// Wilson 95% interval on the spike-conditional hit rate, and a significance test: the edge is real
// only when the interval's LOWER BOUND clears the base rate (a thin-sample edge is not "proven").
f_wilsonCI(float k, float n, float z) =>
    float lo = na
    float hi = na
    if n > 0
        float p = k / n
        float d = 1.0 + z * z / n
        float c = (p + z * z / (2.0 * n)) / d
        float m = (z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))) / d
        lo := math.max(0.0, c - m)
        hi := math.min(1.0, c + m)
    [lo, hi]
[hitLo, hitHi] = f_wilsonCI(hitN, sigN, 1.96)
float edgeLB = (not na(hitLo) and not na(baseP)) ? hitLo * 100.0 - baseP : na    // worst-case edge (pts)
bool  edgeSig = not na(edgeLB) and sigN >= 20 and edgeLB > 0                     // LB clears base = ✓sig

// ═════════════════════════════════════════════════════════════════════════════════════════
//                       DASHBOARD  (theme-adaptive zebra, bias headline)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cStr2   = darkUI ? colStr : color.rgb(198, 40, 40)
color cLiq2   = darkUI ? colLiq : color.rgb(14, 124, 90)

f_pos(string s) => s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right
bool isPro = panelMode == "Pro"
var table T = table.new(f_pos(panelPos), 2, 10, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color rbg) =>
    table.cell(T, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(T, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = rbg)

if showPanel and barstate.islast
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    // headline liquidity state (the one-look verdict)
    color hdr = color.new(osc >= hiThr ? colStr : osc <= loThr ? colLiq : color.gray, 0)
    string verdict = na(osc) ? "warming" : osc >= hiThr ? "STRESSED" : osc <= loThr ? "LIQUID" : "NORMAL"
    color hdrTxt = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white
    color pctCol = na(osc) ? txtMut : osc >= hiThr ? cStr2 : osc <= loThr ? cLiq2 : txtMain
    color edgeCol = (sigN < 20 or na(edge)) ? txtMut : edgeSig ? cStr2 : txtMain
    string edgeTxt = sigN < 20 or na(edge) ? "warming (" + str.tostring(sigN) + ")" : str.tostring(edge, "+0.0;-0.0") + " pts " + (edgeSig ? "✓sig" : "(ns)") + " (" + str.tostring(sigN) + ")"
    table.cell(T, 0, 0, "LIQUIDITY", text_color = hdrTxt, bgcolor = hdr, text_size = size.small)
    table.cell(T, 1, 0, verdict, text_color = hdrTxt, bgcolor = hdr, text_size = size.small)
    if isPro
        f_row(1, "Spread %ile", na(osc) ? "warming" : str.tostring(osc, "0") + "%", pctCol, rowAlt)
        f_row(2, "Effective spread", na(sprBps) ? "warming" : str.tostring(sprBps, "0.0") + " bps", txtMain, panelBg)
        f_row(3, "Estimator", method == "Corwin-Schultz (high-low)" ? "Corwin-Schultz" : "Abdi-Ranaldo", txtSub, rowAlt)
        f_row(4, "Trend", na(osc) ? "-" : widening ? "widening" : "tightening", widening ? cStr2 : cLiq2, panelBg)
        f_row(5, "Spikes (n)", str.tostring(sigN), txtMain, rowAlt)
        f_row(6, "Vol-exp Hit %", sigN < 20 ? "warming" : str.tostring(hitP, "0") + "%", sigN < 20 ? txtMut : txtMain, panelBg)
        f_row(7, "Base rate", na(baseP) ? "warming" : str.tostring(baseP, "0") + "%", txtSub, rowAlt)
        f_row(8, "Edge", edgeTxt, edgeCol, panelBg)
        f_row(9, "Hit 95% CI", sigN < 20 or na(hitLo) ? "warming" : str.tostring(hitP, "0") + "% [" + str.tostring(hitLo * 100.0, "0") + "–" + str.tostring(hitHi * 100.0, "0") + "]", edgeSig ? cStr2 : txtSub, rowAlt)
    else
        f_row(1, "Spread %ile", na(osc) ? "warming" : str.tostring(osc, "0") + "%", pctCol, rowAlt)
        f_row(2, "Trend", na(osc) ? "-" : widening ? "widening" : "tightening", widening ? cStr2 : cLiq2, panelBg)
        f_row(3, "Vol-exp Edge", edgeTxt, edgeCol, rowAlt)
        f_row(4, "Note", "risk context · not advice", txtMut, panelBg)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    EXPORTS  (Data Window - consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(osc,     "EXP_SpreadPct", color.new(color.gray, 100), display = display.data_window)
plot(sprBps,  "EXP_SpreadBps", color.new(color.gray, 100), display = display.data_window)
plot(na(osc) ? 0 : osc >= hiThr ? 1 : osc <= loThr ? -1 : 0, "EXP_State", color.new(color.gray, 100), display = display.data_window)
plot(spike ? 1 : 0, "EXP_Spike", color.new(color.gray, 100), display = display.data_window)
plot(edge,    "EXP_Edge",      color.new(color.gray, 100), display = display.data_window)
plot(edgeLB,  "EXP_EdgeLB",    color.new(color.gray, 100), display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(ta.crossover(osc, float(hiThr)),  "Liquidity stressed", "Effective Spread: liquidity entered the stressed band (spread widening).")
alertcondition(ta.crossunder(osc, float(loThr)), "Liquidity normalised", "Effective Spread: liquidity entered the liquid band (spread tightening).")
alertcondition(spike, "Spread spike", "Effective Spread: a spread spike fired - expect higher volatility / slippage.")
````

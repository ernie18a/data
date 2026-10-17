# Triple Barrier Exit with Meta Labeling

- url: https://www.tradingview.com/script/3gtS1q5i-Triple-Barrier-Exit-with-Meta-Labeling/
- type: indicator
- pine_id: PUB;52d32e31ee5f4d27b2fcef4bbb5e2b69
- version: 3.0

## Description

Overview

Most tools tell you when to enter. This one frames how a trade would be managed — and then keeps an honest record of how that framing actually resolved. It takes a primary entry signal (its own built-in breakout, or any external signal series you point it at), draws a volatility-scaled profit barrier, stop barrier and time barrier around it, watches which is touched first, and feeds every resolved outcome into a live track record. On top sits a meta-label gate: a small online model that learns, from those resolved outcomes, whether to take or skip the next signal.

It is a research and trade-framing study — not a strategy, not a signal service, and not a validated edge.

Why these parts are ONE tool (mashup rationale)

Each layer exists because the one before it leaves a question open:


The triple barrier. A raw entry signal has no definition of success. Profit / stop / time barriers, scaled by current volatility (ATR or an EWMA of returns), turn a signal into a labelled outcome: profit-hit, stop-hit, or timed-out. Widths are regime-asymmetric — the profit barrier widens in trend and tightens in chop — because a fixed frame misprices the same signal in different conditions.
The trend-scanning vertical. A fixed holding time is arbitrary. The time barrier is instead chosen from candidate horizons by the strongest |t-value| of a linear fit — the horizon over which price is actually trending most decisively.
The meta-label gate. Knowing outcomes isn't the same as acting on them. A small online logistic model, trained only on resolved outcomes, scores each new signal and says TAKE or SKIP. It stays disabled until enough trades have resolved, so it never acts on an untrained model.
The honesty layer. Overlapping trades are not independent samples — so wins are recency-decayed and reported with a Wilson 95% lower bound per regime, alongside a reliability table and a Brier score for the meta-gate itself. If the gate isn't calibrated, the panel says so.


Remove any layer and the tool either mislabels the trade, mistimes it, acts on an untested model, or reports a win-rate it hasn't earned.

How it works

A primary signal fires. If the meta-gate passes, the trade is framed: profit = entry ± (PT × regime multiplier × σ), stop = entry ∓ (SL × regime multiplier × σ), and a vertical barrier holdH bars ahead. The frame is drawn as a forward box that recolours green / red / grey on first touch. Same-bar ties resolve stop-first (the conservative assumption). MFE and MAE are tracked live on the open trade. On resolution, the outcome trains the meta-model and updates the per-regime statistics.

How to use it

Read the panel before you trust the frame.


Meta gate — whether the model would take or skip the current signal (stays "warming" until it has enough resolved samples).
Wilson 95% lower — the honest floor of the win-rate in the current regime. If it isn't above 50%, this framing has not demonstrated an edge here.
Meta Brier — below ~0.25 means the gate's probabilities are reasonably calibrated; above it, ignore the gate.


The most useful thing you can do with it: point it at your own entry signal via the external-source input, and see how your signal resolves under a disciplined exit frame. The suggested size is advisory arithmetic (risk ÷ stop distance), not a recommendation. Only one trade is managed at a time — this is a study of the framing, not a portfolio simulator. The dashboard has a Compact layout (default) and a Pro layout (adds the scanned horizon, Brier, reliability tiers, PT/SL/timeout counts, live MFE/MAE and suggested size).

Universal across markets

Entry source, σ source, barrier widths and horizons are all inputs, so it runs on any symbol and timeframe. It needs no volume. Defaults target intraday index futures.

Non-repainting

Entries are taken and outcomes resolved only on confirmed bars, and the meta-model is trained only on resolved outcomes — so no statistic reads its own future and nothing inflates intrabar. The live "next-trade frame" preview is a forward projection at the current bar only, by design.

Originality

The triple barrier, meta-labelling and trend-scanning are published research concepts, credited below. What's assembled here is the specific synthesis: the triple barrier used as a live exit/management frame rather than an offline training pipeline, regime-asymmetric barrier widths, an online meta-gate that trains itself on the chart in front of you, and an honesty panel that reports the Wilson lower bound, the reliability tiers and the gate's own Brier score. Clean-room implementation; no third-party code reused.

Concept credits


Triple-barrier labelling, meta-labelling, trend-scanning, and sample uniqueness / time-decay for non-IID overlapping outcomes — Marcos López de Prado (Advances in Financial Machine Learning). Here the triple barrier is used as an exit/management frame and a labelling substrate, not as a training pipeline.
Wilson score confidence interval — Edwin B. Wilson · Brier score — Glenn W. Brier
Average True Range — J. Welles Wilder · Efficiency Ratio — Perry Kaufman
Inverse-volatility position sizing — standard risk-management practice


Honest limits

Overlapping trades are not independent, which is exactly why wins are decayed and reported with a Wilson lower bound rather than a raw percentage — treat the win-rate as descriptive, not a probability of future results. The meta-model is a small online logistic fit on three features; it can be miscalibrated, which is why its Brier score is shown. All figures are in-sample, with no costs, slippage or spread. Nothing here predicts price.

Disclaimer

Research and educational tool only. Not financial advice, not a recommendation, and no guarantee of results. The position-size output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// TRIPLE-BARRIER EXIT WITH META-LABELING                                                     v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
//  v1.1 — Cost model (no engine change): every resolved trade already has a realised R (profit = +rr,
//         stop = −1R, timeout = marked-to-market). v1.1 accumulates a recency-decayed R-EXPECTANCY and
//         subtracts a round-trip cost input → Net R, shown in the panel and exported (EXP_ExpR /
//         EXP_NetR). The win-rate, Wilson floor and meta-gate are unchanged; Net R is a second,
//         cost-aware lens on the same resolved outcomes. No conditional ta.* — no correctness fix.
// ────────────────────────────────────────────────────────────────────────────────────────────
//   OVERVIEW
//   Most tools tell you when to ENTER. This one frames how a trade would be MANAGED and then keeps
//   an honest record of how that framing actually resolved. It takes a primary entry signal (its own
//   built-in breakout, or any external signal series you point it at), draws a volatility-scaled
//   PROFIT barrier, STOP barrier and TIME barrier around it, watches which one is touched first, and
//   feeds every resolved outcome back into a live track record. On top of that sits a META-LABEL
//   gate — a small online model that learns, from the resolved outcomes, whether to TAKE or SKIP the
//   next signal. It is a research and trade-framing study — NOT a strategy, NOT a signal service,
//   and NOT a validated edge.
//
//  WHY THESE PARTS ARE ONE TOOL  (mashup rationale)
//   Each layer exists because the one before it leaves a question open:
//     1. TRIPLE BARRIER. A raw entry signal has no definition of success. Profit / stop / time
//        barriers, scaled by current volatility (ATR or EWMA of returns), turn a signal into a
//        labelled OUTCOME: profit-hit, stop-hit, or timed-out. Widths are REGIME-ASYMMETRIC —
//        the profit barrier widens in trend and tightens in chop — because a fixed frame misprices
//        the same signal in different conditions.
//     2. TREND-SCANNING VERTICAL. A fixed holding time is arbitrary. The time barrier is instead
//        chosen from candidate horizons by the strongest |t-value| of a linear fit, so the trade is
//        given the horizon over which price is actually trending most decisively.
//     3. META-LABEL GATE. Knowing outcomes is not the same as acting on them. A small online
//        logistic model, trained ONLY on resolved outcomes, scores each new signal and says TAKE or
//        SKIP. It stays disabled until it has enough resolved samples to be worth listening to.
//     4. HONESTY LAYER. Overlapping trades are NOT independent samples, so wins are recency-decayed
//        and reported with a Wilson 95% lower bound per regime, alongside a RELIABILITY table and a
//        BRIER score for the meta-gate itself. If the gate is not calibrated, the panel shows it.
//   Remove any layer and the tool either mislabels the trade, mistimes it, acts on an untested
//   model, or reports a win-rate it has not earned.
//
//  HOW IT WORKS
//   A primary signal fires (built-in Donchian breakout, or your external series). If the meta-gate
//   passes, the trade is FRAMED: profit = entry ± (PT × regime multiplier × σ), stop = entry ∓
//   (SL × regime multiplier × σ), and a vertical barrier holdH bars ahead. The frame is drawn as a
//   forward box that recolours green / red / grey on first touch. Same-bar ties resolve STOP-FIRST
//   (the conservative assumption). MFE / MAE are tracked live on the open trade. On resolution the
//   outcome trains the meta-model and updates the per-regime statistics.
//
//  HOW TO USE
//   Read the panel before you trust the frame. "Meta gate" tells you whether the model would take or
//   skip the current signal (and stays "warming" until it has enough resolved samples). "Wilson 95%
//   lower" is the honest floor of the win-rate in the current regime — if it is not above 50%, this
//   framing has NOT demonstrated an edge here. "Meta Brier" below ~0.25 means the gate's probabilities
//   are reasonably calibrated; above it, ignore the gate. Point it at your own entry signal via the
//   external-source input to test how YOUR signal resolves under a disciplined exit frame. The
//   suggested size is advisory arithmetic (risk ÷ stop distance), not a recommendation.
//   Only ONE trade is managed at a time — this is a study of the framing, not a portfolio simulator.
//
// UNIVERSAL ACROSS MARKETS
//   Entry source, σ source, barrier widths and horizons are all inputs, so it runs on any symbol and
//   timeframe. It needs no volume. Defaults target intraday index futures.
//
// NON-REPAINT
//   Entries are taken and outcomes resolved only on CONFIRMED bars, and the meta-model is trained
//   only on RESOLVED outcomes — so no statistic reads its own future and nothing inflates intrabar.
//   The live "next-trade frame" preview is a forward projection at the current bar only, by design.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_inTrade · EXP_tradeDir · EXP_barrierPT · EXP_barrierSL · EXP_outcome · EXP_metaP ·
//   EXP_sizeSuggest · EXP_ExpR (recency-decayed R-expectancy) · EXP_NetR (ExpR − round-trip cost)
//
// CONCEPT CREDIT
//   • Triple-barrier labelling, meta-labelling, trend-scanning, and sample uniqueness / time-decay
//     for non-IID overlapping outcomes — Marcos López de Prado (Advances in Financial Machine
//     Learning). Here the triple barrier is used as an EXIT / MANAGEMENT frame and a labelling
//     substrate, not as a training pipeline.
//   • Wilson score confidence interval — Edwin B. Wilson.  • Brier score — Glenn W. Brier.
//   • Average True Range — J. Welles Wilder.  • Efficiency Ratio — Perry Kaufman.
//   • Inverse-volatility position sizing — standard risk-management practice.
//   The synthesis, the regime-asymmetric barrier widths, the online meta-gate and the honesty panel
//   are the author's own implementation. No third-party code is reused.
//
// HONESTY / LIMITATIONS
//   Overlapping trades are not independent, which is exactly why wins are decayed and reported with
//   a Wilson lower bound rather than a raw percentage — treat the win-rate as descriptive, not as a
//   probability of future results. The meta-model is a small online logistic fit on three features;
//   it can be miscalibrated, which is why its Brier score is shown. All figures are in-sample, with
//   no costs, slippage or spread. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Position-size output is arithmetic, not advice. Trading carries risk of loss. Test
//   out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Triple-Barrier Exit with Meta-Labeling", "TB Exit", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
gE = "01 · Entry source"
gB = "02 · Barriers"
gT = "03 · Trend-scan vertical"
gM = "04 · Meta-label gate"
gG = "05 · Gates"
gS = "06 · Sizing"
gR = "07 · Regime & honesty"
gV = "08 · Display & theme"

useExt  = input.bool(false, "Use external entry signal", group = gE, tooltip = "Take entries from another script instead of the built-in breakout. Point the source below at a signal series where a value above 0 = long and below 0 = short (for example a Data Window signal export from one of your other studies).")
extSig  = input.source(close, "External entry source", group = gE)
dcLen   = input.int(20, "Built-in breakout length", minval = 3, maxval = 500, group = gE, tooltip = "Donchian channel length for the built-in primary signal (used when the external source is off).")

bU      = input.float(1.5, "Profit-take ×σ", minval = 0.2, maxval = 10.0, step = 0.1, group = gB)
bD      = input.float(1.5, "Stop-loss ×σ",   minval = 0.2, maxval = 10.0, step = 0.1, group = gB)
volMode = input.string("ATR", "σ source", options = ["ATR", "EWMA returns"], group = gB, tooltip = "Volatility unit the barriers are scaled by.")
volLen  = input.int(14, "σ length", minval = 5, maxval = 200, group = gB)
regAsym = input.bool(true, "Regime-asymmetric widths", group = gB, tooltip = "Widen the profit barrier in trend regimes and tighten it in chop, because a fixed frame misprices the same signal in different conditions.")

useTS   = input.bool(true, "Trend-scanning vertical barrier", group = gT, tooltip = "Pick the holding horizon from the candidate with the strongest |t-value| of a linear fit — the horizon over which price is trending most decisively. Off = use the fixed hold below.")
hFix    = input.int(20, "Fixed vertical (when scan off)", minval = 2, maxval = 500, group = gT)
h1      = input.int(10, "Candidate h1", minval = 3, maxval = 200, group = gT)
h2      = input.int(20, "Candidate h2", minval = 3, maxval = 200, group = gT)
h3      = input.int(30, "Candidate h3", minval = 3, maxval = 200, group = gT)
h4      = input.int(45, "Candidate h4", minval = 3, maxval = 200, group = gT)
h5      = input.int(60, "Candidate h5", minval = 3, maxval = 200, group = gT)
hCap    = input.int(80, "Vertical cap (bars)", minval = 5, maxval = 500, group = gT)

useMeta = input.bool(true, "Meta-label take/skip gate", group = gM, tooltip = "An online logistic model trained ONLY on resolved outcomes. It scores each new signal and says TAKE or SKIP, and stays inactive until it has enough resolved samples.")
metaThr = input.float(0.50, "Take threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = gM)
lr      = input.float(0.03, "Learning rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gM)
l2      = input.float(0.001, "L2 regularisation", minval = 0.0, maxval = 0.1, step = 0.001, group = gM)
warmN   = input.int(25, "Warm-up resolved samples", minval = 5, maxval = 500, group = gM, tooltip = "The gate stays off until this many trades have resolved, so it never acts on an untrained model.")

useHL   = input.bool(false, "Half-life gate", group = gG, tooltip = "Skip setups whose mean-reversion half-life is too long to resolve within the vertical cap.")
hlLen   = input.int(50, "Half-life AR(1) length", minval = 10, maxval = 500, group = gG)

riskCur = input.float(100.0, "Risk per trade (price units)", minval = 0.0, group = gS, tooltip = "Suggested size = risk ÷ stop distance. This is arithmetic, not advice.")

erLen   = input.int(20, "Efficiency-ratio length", minval = 5, maxval = 200, group = gR)
adxLen  = input.int(14, "ADX length", minval = 5, maxval = 200, group = gR)
atrPctL = input.int(100, "ATR percentile lookback", minval = 20, maxval = 1000, group = gR)
decay   = input.float(0.99, "Recency decay", minval = 0.80, maxval = 1.0, step = 0.005, group = gR, tooltip = "Older resolved trades are down-weighted, so the track record reflects the recent market.")
minN    = input.float(3.0, "Min effective n to show", minval = 1.0, maxval = 100.0, group = gR)
costR   = input.float(0.30, "Round-trip cost (R) — for NetR", minval = 0.0, maxval = 3.0, step = 0.05, group = gR, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) in R — a fraction of the trade's 1R risk (Stop distance). Each resolved trade's realised R (profit = +reward:risk, stop = −1R, timeout = marked-to-market) is averaged with the same recency decay as the win-rate; NetR = ExpR − cost. NetR > 0 = this exit framing is profitable after costs. Default 0.30 suits 1m NIFTY futures.")

showTbl  = input.bool(true, "Show dashboard", group = gV)
tblMode  = input.string("Compact", "Dashboard detail", options = ["Compact", "Pro"], group = gV, tooltip = "Compact (default) = regime, state, meta gate and the honest win-rate floor. Pro = adds the vertical horizon, Brier score, reliability tiers, PT/SL/timeout counts, live MFE/MAE and suggested size.")
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gV)
showLegend = input.bool(true, "Show legend / key", group = gV, tooltip = "A key explaining every line, box and marker the script draws.")
showLevels = input.bool(true, "Price labels on barriers", group = gV, tooltip = "Print the actual price of each barrier at the right edge of its line, with the R-multiple.")
showOutcome= input.bool(true, "Outcome labels on resolve", group = gV, tooltip = "Label each finished trade with how it resolved and the R-multiple achieved.")
showVert   = input.bool(true, "Draw the time barrier", group = gV, tooltip = "Draw the vertical (time) barrier as a line, so all three barriers are visible.")
lineW      = input.int(3, "Barrier line width", minval = 1, maxval = 6, group = gV)
prevLen    = input.int(20, "Preview frame length (bars)", minval = 5, maxval = 100, group = gV, tooltip = "How far ahead the next-trade preview frame is projected when flat.")
colPT   = input.color(color.new(#26a69a, 0),  "Profit", group = gV)
colSL   = input.color(color.new(#ef5350, 0),  "Stop",   group = gV)
colBoxW = input.color(color.new(#26a69a, 78), "Win fill",  group = gV)
colBoxL = input.color(color.new(#ef5350, 78), "Loss fill", group = gV)
colBoxN = input.color(color.new(#b0bec5, 85), "Open fill", group = gV)
colMFE  = input.color(color.new(#26a69a, 25), "MFE",    group = gV)
colMAE  = input.color(color.new(#ef5350, 25), "MAE",    group = gV)
showPrev= input.bool(true, "Preview next-trade barriers when flat", group = gV, tooltip = "Live σ-scaled profit/stop frame for a hypothetical long here (shorts mirror). Drawn only at the current bar.")
showMark= input.bool(true, "Entry markers", group = gV)
showSkip= input.bool(false, "Meta-skip markers (diagnostic)", group = gV, tooltip = "Marks bars where the meta-gate vetoed an otherwise-valid signal. Off by default — at wide zoom these pile up.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
f_er(s, len) =>
    ch   = math.abs(s - s[len])
    vsum = math.sum(math.abs(ta.change(s)), len)
    vsum != 0 ? ch / vsum : 0.0

f_regId(er, adx, ap) =>
    if ap >= 0.80 and er < 0.40
        4
    else if er >= 0.55 and adx >= 25
        0
    else if er >= 0.40 and adx >= 20
        1
    else if er < 0.25 and adx < 18
        3
    else
        2

f_regLbl(id) => id == 0 ? "STRONG TREND" : id == 1 ? "TREND" : id == 2 ? "NEUTRAL" : id == 3 ? "CHOP" : "VOLATILE"
f_regCol(id) => id == 0 ? color.new(#26a69a, 0) : id == 1 ? color.new(#66bb6a, 0) : id == 2 ? color.new(#b0bec5, 0) : id == 3 ? color.new(#ffa726, 0) : color.new(#ef5350, 0)

f_wilsonLo(w, t, zc) =>
    if t <= 0
        na
    else
        p = w / t
        d = 1.0 + zc * zc / t
        c = (p + zc * zc / (2.0 * t)) / d
        m = (zc * math.sqrt(p * (1.0 - p) / t + zc * zc / (4.0 * t * t))) / d
        c - m

f_sig(x) => 1.0 / (1.0 + math.exp(-math.max(-30.0, math.min(30.0, x))))

f_pctTier(wA, tA, ix, mn) =>
    wv = array.get(wA, ix)
    tv = array.get(tA, ix)
    tv >= mn ? str.tostring(100.0 * wv / tv, "#0") + "%" : "—"

f_pred(wA, a, b, c) =>
    s = array.get(wA, 0) * 1.0 + array.get(wA, 1) * a + array.get(wA, 2) * b + array.get(wA, 3) * c
    f_sig(s)

f_tval(len) =>
    n = len
    sx = 0.0
    sy = 0.0
    sxx = 0.0
    syy = 0.0
    sxy = 0.0
    for i = 0 to n - 1
        y = close[i]
        sx := sx + i
        sy := sy + y
        sxx := sxx + i * i
        syy := syy + y * y
        sxy := sxy + i * y
    den = math.sqrt(math.max(1e-12, (n * sxx - sx * sx) * (n * syy - sy * sy)))
    cc = den > 0 ? (n * sxy - sx * sy) / den : 0.0
    cc := math.max(-0.999999, math.min(0.999999, cc))
    cc * math.sqrt(math.max(1.0, n - 2) / math.max(1e-9, 1.0 - cc * cc))

f_lum(color cc) => na(cc) ? 0.0 : 0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  VOLATILITY · REGIME
// ═════════════════════════════════════════════════════════════════════════════════════════
r = na(close[1]) ? 0.0 : math.log(close / close[1])
aL = 2.0 / (volLen + 1)
var float ewVar = na
ewVar := na(ewVar) ? r * r : aL * r * r + (1.0 - aL) * ewVar
sigRet = math.sqrt(math.max(ewVar, 0.0))
atrV   = ta.atr(volLen)
sigPx  = volMode == "ATR" ? atrV : close * sigRet

erV    = f_er(close, erLen)
[dip, dim, adxV] = ta.dmi(adxLen, adxLen)
atrPct = ta.percentrank(atrV, atrPctL) / 100.0
regId  = f_regId(erV, adxV, atrPct)
// asymmetric multipliers by regime
ptMul = regAsym ? (regId == 0 ? 1.4 : regId == 1 ? 1.2 : regId == 3 ? 0.8 : 1.0) : 1.0
slMul = regAsym ? (regId == 3 ? 0.85 : regId == 4 ? 1.15 : 1.0) : 1.0

// ── half-life gate ──
phi      = ta.correlation(close, close[1], hlLen)
halfLife = (not na(phi) and phi > 0 and phi < 1) ? -math.log(2.0) / math.log(phi) : na
hlOk     = not useHL or (not na(halfLife) and halfLife <= hCap)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                            TREND-SCAN VERTICAL HORIZON
// ═════════════════════════════════════════════════════════════════════════════════════════
t1 = f_tval(h1)
t2 = f_tval(h2)
t3 = f_tval(h3)
t4 = f_tval(h4)
t5 = f_tval(h5)
bestT = math.abs(t1)
bestH = h1
if math.abs(t2) > bestT
    bestT := math.abs(t2)
    bestH := h2
if math.abs(t3) > bestT
    bestT := math.abs(t3)
    bestH := h3
if math.abs(t4) > bestT
    bestT := math.abs(t4)
    bestH := h4
if math.abs(t5) > bestT
    bestT := math.abs(t5)
    bestH := h5
holdH = useTS ? math.min(hCap, bestH) : hFix

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              META-LABEL FEATURES & GATE
// ═════════════════════════════════════════════════════════════════════════════════════════
ema20 = ta.ema(close, 20)
fA = erV                                                   // 0..1  trend efficiency
fB = atrPct                                                // 0..1  volatility percentile
fC = math.max(-1.0, math.min(1.0, (close - ema20) / math.max(sigPx, 1e-9) / 3.0))  // -1..1 stretch
var float[] wts = array.new_float(4, 0.0)
pTakeNow = f_pred(wts, fA, fB, fC)
var int resolvedN = 0
metaReady = resolvedN >= warmN
metaPass = not useMeta or not metaReady or pTakeNow >= metaThr

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                     PRIMARY ENTRIES
// ═════════════════════════════════════════════════════════════════════════════════════════
upBrk    = ta.crossover(close,  ta.highest(close, dcLen)[1])
dnBrk    = ta.crossunder(close, ta.lowest(close,  dcLen)[1])
extLong  = useExt and extSig > 0 and (na(extSig[1]) or extSig[1] <= 0)
extShort = useExt and extSig < 0 and (na(extSig[1]) or extSig[1] >= 0)
rawLong  = useExt ? extLong  : upBrk
rawShort = useExt ? extShort : dnBrk

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                   TRADE MANAGEMENT
// ═════════════════════════════════════════════════════════════════════════════════════════
var bool  inTrade  = false
var float entryPx  = na
var int   tDir     = 0
var float ptLvl    = na
var float slLvl    = na
var int   vBar     = na
var float mfe      = na
var float mae      = na
var float ef_a     = na
var float ef_b     = na
var float ef_c     = na
var float ef_p     = na
var box   tBox     = na
var line  ptLine   = na
var line  slLine   = na
var line  entLine  = na
var line  vertLine = na
var line  mfeLine  = na
var line  maeLine  = na
var label labPT    = na
var label labSL    = na
var label labEnt   = na

canEnter = not inTrade and not na(sigPx) and sigPx > 0 and hlOk and metaPass
newLong  = rawLong  and canEnter
newShort = rawShort and canEnter
newEntry = (newLong or newShort) and barstate.isconfirmed

if newEntry
    inTrade  := true
    entryPx  := close
    tDir     := newLong ? 1 : -1
    ptLvl    := tDir == 1 ? close + bU * ptMul * sigPx : close - bU * ptMul * sigPx
    slLvl    := tDir == 1 ? close - bD * slMul * sigPx : close + bD * slMul * sigPx
    vBar     := bar_index + holdH
    mfe := 0.0
    mae := 0.0
    ef_a := fA
    ef_b := fB
    ef_c := fC
    ef_p := pTakeNow
    topB = math.max(ptLvl, slLvl)
    botB = math.min(ptLvl, slLvl)
    tBox   := box.new(bar_index, topB, vBar, botB, border_color = color.new(color.gray, 40), border_width = 1, bgcolor = colBoxN, xloc = xloc.bar_index)
    ptLine := line.new(bar_index, ptLvl, vBar, ptLvl, color = colPT, width = lineW, xloc = xloc.bar_index)
    slLine := line.new(bar_index, slLvl, vBar, slLvl, color = colSL, width = lineW, xloc = xloc.bar_index)
    entLine:= line.new(bar_index, entryPx, vBar, entryPx, color = color.new(color.gray, 25), width = 1, style = line.style_dotted, xloc = xloc.bar_index)
    vertLine := showVert ? line.new(vBar, botB, vBar, topB, color = color.new(#ffa726, 30), width = math.max(1, lineW - 1), style = line.style_dashed, xloc = xloc.bar_index) : na
    mfeLine := line.new(bar_index, entryPx, bar_index, entryPx, color = colMFE, width = math.max(1, lineW - 1), style = line.style_dotted, xloc = xloc.bar_index)
    maeLine := line.new(bar_index, entryPx, bar_index, entryPx, color = colMAE, width = math.max(1, lineW - 1), style = line.style_dotted, xloc = xloc.bar_index)
    // live price labels on each barrier (deleted and redrawn per trade — bounded)
    label.delete(labPT)
    label.delete(labSL)
    label.delete(labEnt)
    if showLevels
        float rr = bD * slMul != 0 ? (bU * ptMul) / (bD * slMul) : na
        labPT  := label.new(vBar, ptLvl, "PT  " + str.tostring(ptLvl, format.mintick) + "   +" + str.tostring(rr, "0.0") + "R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colPT, 12), textcolor = color.white, size = size.small)
        labSL  := label.new(vBar, slLvl, "SL  " + str.tostring(slLvl, format.mintick) + "   −1.0R", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colSL, 12), textcolor = color.white, size = size.small)
        labEnt := label.new(vBar, entryPx, (tDir == 1 ? "LONG  " : "SHORT  ") + str.tostring(entryPx, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 25), textcolor = color.white, size = size.small)

// live MFE / MAE on the open trade
if inTrade and not newEntry
    curFav = tDir == 1 ? high - entryPx : entryPx - low
    curAdv = tDir == 1 ? entryPx - low  : high - entryPx
    mfe := math.max(nz(mfe), curFav)
    mae := math.max(nz(mae), curAdv)
    if not na(mfeLine)
        line.set_xy2(mfeLine, bar_index, entryPx + tDir * mfe)
    if not na(maeLine)
        line.set_xy2(maeLine, bar_index, entryPx - tDir * mae)

// resolution — confirmed bars only; STOP-first on same-bar ties (conservative)
int  outcome  = 0
bool resolved = false
if inTrade and not newEntry and barstate.isconfirmed
    ptHit = tDir == 1 ? high >= ptLvl : low  <= ptLvl
    slHit = tDir == 1 ? low  <= slLvl : high >= slLvl
    vtHit = bar_index >= vBar
    if slHit
        outcome := -1
        resolved := true
    else if ptHit
        outcome := 1
        resolved := true
    else if vtHit
        outcome := 0
        resolved := true
    if resolved
        if not na(tBox)
            box.set_bgcolor(tBox, outcome == 1 ? colBoxW : outcome == -1 ? colBoxL : colBoxN)
            box.set_border_color(tBox, outcome == 1 ? color.new(colPT, 40) : outcome == -1 ? color.new(colSL, 40) : color.new(color.gray, 50))
            box.set_right(tBox, bar_index)
        if not na(ptLine)
            line.set_x2(ptLine, bar_index)
        if not na(slLine)
            line.set_x2(slLine, bar_index)
        if not na(entLine)
            line.set_x2(entLine, bar_index)
        if not na(vertLine)
            line.set_xy1(vertLine, bar_index, line.get_y1(vertLine))
            line.set_xy2(vertLine, bar_index, line.get_y2(vertLine))
        // move the live price labels to the exit bar so they don't float in empty space
        if not na(labPT)
            label.set_x(labPT, bar_index)
        if not na(labSL)
            label.set_x(labSL, bar_index)
        if not na(labEnt)
            label.set_x(labEnt, bar_index)
        // persistent outcome label: how it resolved, and the R actually achieved
        if showOutcome
            float sd = math.abs(entryPx - slLvl)
            float rMult = sd > 0 ? (tDir == 1 ? close - entryPx : entryPx - close) / sd : na
            string oTxt = outcome == 1 ? "PT ✓" : outcome == -1 ? "SL ✗" : "TIME"
            string rTxt = na(rMult) ? "" : "  " + (rMult >= 0 ? "+" : "") + str.tostring(rMult, "0.0") + "R"
            color  oCol = outcome == 1 ? colPT : outcome == -1 ? colSL : color.new(#ffa726, 0)
            label.new(bar_index, outcome == 1 ? ptLvl : outcome == -1 ? slLvl : close, oTxt + rTxt, xloc = xloc.bar_index, style = tDir == 1 and outcome == 1 ? label.style_label_down : label.style_label_up, color = color.new(oCol, 15), textcolor = color.white, size = size.small)
        inTrade := false

// ═════════════════════════════════════════════════════════════════════════════════════════
//              HONESTY LAYER — stats + meta training (only on resolved outcomes)
// ═════════════════════════════════════════════════════════════════════════════════════════
var float[] wWin = array.new_float(5, 0.0)
var float[] wTot = array.new_float(5, 0.0)
var int[]   regPT = array.new_int(5, 0)
var int[]   regSL = array.new_int(5, 0)
var int[]   regTO = array.new_int(5, 0)
var float[] relWin = array.new_float(3, 0.0)
var float[] relTot = array.new_float(3, 0.0)
var float   brierAcc = 0.0
var float   brierCnt = 0.0
var float   rWsum = 0.0     // recency-decayed Σ realised R (all resolved trades, incl. timeouts)
var float   rWcnt = 0.0     // recency-decayed count

if resolved
    // realised R of THIS trade: profit = +reward:risk, stop = −1R, timeout = marked-to-market
    float sdR   = math.abs(entryPx - slLvl)
    float rrR   = sdR > 0 ? math.abs(ptLvl - entryPx) / sdR : na
    float rReal = outcome == 1 ? nz(rrR) : outcome == -1 ? -1.0 : (sdR > 0 ? (tDir == 1 ? close - entryPx : entryPx - close) / sdR : 0.0)
    rWsum := rWsum * decay + rReal
    rWcnt := rWcnt * decay + 1.0
    // win-rate accounting (PT vs SL; timeouts counted separately, excluded from the rate)
    if outcome == 1
        array.set(regPT, regId, array.get(regPT, regId) + 1)
    else if outcome == -1
        array.set(regSL, regId, array.get(regSL, regId) + 1)
    else
        array.set(regTO, regId, array.get(regTO, regId) + 1)
    if outcome != 0
        win = outcome == 1 ? 1.0 : 0.0
        // recency-decayed, per-regime win accounting (overlapping trades are not IID)
        array.set(wWin, regId, array.get(wWin, regId) * decay + win)
        array.set(wTot, regId, array.get(wTot, regId) * decay + 1.0)
        // meta training on resolved decisive samples only
        phat = f_pred(wts, ef_a, ef_b, ef_c)
        gerr = phat - win
        if not na(ef_a) and not na(ef_b) and not na(ef_c)
            array.set(wts, 0, array.get(wts, 0) - lr * (gerr * 1.0 + l2 * array.get(wts, 0)))
            array.set(wts, 1, array.get(wts, 1) - lr * (gerr * ef_a + l2 * array.get(wts, 1)))
            array.set(wts, 2, array.get(wts, 2) - lr * (gerr * ef_b + l2 * array.get(wts, 2)))
            array.set(wts, 3, array.get(wts, 3) - lr * (gerr * ef_c + l2 * array.get(wts, 3)))
            resolvedN := resolvedN + 1
            // reliability bucket on the entry-time prediction + Brier score
            tier = ef_p >= 0.6 ? 2 : ef_p >= 0.4 ? 1 : 0
            array.set(relWin, tier, array.get(relWin, tier) * decay + win)
            array.set(relTot, tier, array.get(relTot, tier) * decay + 1.0)
            brierAcc := brierAcc * decay + (ef_p - win) * (ef_p - win)
            brierCnt := brierCnt * decay + 1.0

// inverse-volatility suggested size (arithmetic, advisory only)
stopDist = bD * slMul * sigPx
sizeSug  = stopDist > 0 ? riskCur / stopDist : na

// cost model: recency-decayed R-expectancy of the exit framing, net of the round-trip cost
float expR = rWcnt >= minN ? rWsum / rWcnt : na
float netR = na(expR) ? na : expR - costR

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          DASHBOARD (theme-adaptive · Compact / Pro)
// ═════════════════════════════════════════════════════════════════════════════════════════
bool darkUI  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)

bool isPro = tblMode == "Pro"
var table t = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
f_row(int rw, string k, string v, color col, color bg) =>
    table.cell(t, 0, rw, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, rw, v, text_color = col,    text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showTbl and barstate.islast
    table.set_bgcolor(t, panelBg)
    table.set_frame_color(t, frameC)
    table.set_border_color(t, frameC)
    zc = 1.96
    pt = array.get(regPT, regId)
    sl = array.get(regSL, regId)
    toC = array.get(regTO, regId)
    rw2 = array.get(wWin, regId)
    rt = array.get(wTot, regId)
    lo = rt >= minN ? f_wilsonLo(rw2, rt, zc) : na
    wrStr = rt >= minN ? str.tostring(100.0 * rw2 / rt, "#.0") + "% (n≈" + str.tostring(rt, "#.0") + ")" : "warming"
    loStr = na(lo) ? "warming" : str.tostring(100.0 * lo, "#.0") + "%"
    brier = brierCnt > 0 ? brierAcc / brierCnt : na
    relStr = f_pctTier(relWin, relTot, 0, minN) + "/" + f_pctTier(relWin, relTot, 1, minN) + "/" + f_pctTier(relWin, relTot, 2, minN)
    stStr = inTrade ? (tDir == 1 ? "LONG open" : "SHORT open") : "flat"
    btv   = inTrade and not na(vBar) ? math.max(0, vBar - bar_index) : na
    metaStr = not useMeta ? "off" : not metaReady ? "warming (" + str.tostring(resolvedN) + "/" + str.tostring(warmN) + ")" : str.tostring(100.0 * pTakeNow, "#0") + "% " + (metaPass ? "TAKE" : "SKIP")
    color hdrC = f_regCol(regId)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white
    table.cell(t, 0, 0, "TRIPLE-BARRIER", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 0, f_regLbl(regId), text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    if isPro
        f_row(1,  "State", stStr, inTrade ? (tDir == 1 ? colPT : colSL) : txtMut, rowAlt)
        f_row(2,  "Vertical (scan h*)", str.tostring(holdH) + (inTrade ? "  →" + str.tostring(btv) : ""), txtMain, panelBg)
        f_row(3,  "Meta gate", metaStr, not useMeta ? txtMut : not metaReady ? txtMut : metaPass ? colPT : colSL, rowAlt)
        f_row(4,  "Meta Brier", na(brier) ? "warming" : str.tostring(brier, "#.000"), na(brier) ? txtMut : (brier < 0.25 ? colPT : colSL), panelBg)
        f_row(5,  "Reliab. lo/mid/hi", relStr, txtMain, rowAlt)
        f_row(6,  "Win rate (regime)", wrStr, txtMain, panelBg)
        f_row(7,  "Wilson 95% lower", loStr, na(lo) ? txtMut : (lo > 0.5 ? colPT : colSL), rowAlt)
        f_row(8,  "PT / SL / timeout", str.tostring(pt) + " / " + str.tostring(sl) + " / " + str.tostring(toC), txtMain, panelBg)
        f_row(9,  "MFE / MAE", inTrade ? str.tostring(nz(mfe), format.mintick) + " / " + str.tostring(nz(mae), format.mintick) : "—", txtMain, rowAlt)
        f_row(10, "Suggested size", na(sizeSug) ? "—" : str.tostring(sizeSug, "#.##"), txtMain, panelBg)
        f_row(11, "Net R (after cost)", na(netR) ? "warming" : (na(expR) ? "—" : (expR >= 0 ? "+" : "") + str.tostring(expR, "0.00") + "R → net " + (netR >= 0 ? "+" : "") + str.tostring(netR, "0.00") + "R  (cost " + str.tostring(costR, "0.00") + ")"), na(netR) ? txtMut : netR > 0 ? colPT : colSL, rowAlt)
        f_row(12, "Note", "in-sample · not advice", txtMut, panelBg)
    else
        f_row(1, "State", stStr, inTrade ? (tDir == 1 ? colPT : colSL) : txtMut, rowAlt)
        f_row(2, "Meta gate", metaStr, not useMeta ? txtMut : not metaReady ? txtMut : metaPass ? colPT : colSL, panelBg)
        f_row(3, "Win rate (regime)", wrStr, txtMain, rowAlt)
        f_row(4, "Wilson 95% lower", loStr, na(lo) ? txtMut : (lo > 0.5 ? colPT : colSL), panelBg)
        f_row(5, "Net R (after cost)", na(netR) ? "warming" : (netR >= 0 ? "+" : "") + str.tostring(netR, "0.00") + "R", na(netR) ? txtMut : netR > 0 ? colPT : colSL, rowAlt)
        f_row(6, "Note", "in-sample · not advice", txtMut, panelBg)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                     NEXT-TRADE FRAME PREVIEW (live edge only, no smear)
// ═════════════════════════════════════════════════════════════════════════════════════════
var line lpt = na
var line lps = na
var line lent = na
var label lpl = na
var label lsl = na
pPTlvl = close + bU * ptMul * sigPx
pSLlvl = close - bD * slMul * sigPx
showFrame = showPrev and not inTrade and not na(sigPx) and sigPx > 0
if na(lpt)
    lpt  := line.new(bar_index, pPTlvl, bar_index + prevLen, pPTlvl, xloc = xloc.bar_index, style = line.style_dashed)
    lps  := line.new(bar_index, pSLlvl, bar_index + prevLen, pSLlvl, xloc = xloc.bar_index, style = line.style_dashed)
    lent := line.new(bar_index, close,  bar_index + prevLen, close,  xloc = xloc.bar_index, style = line.style_dotted)
    lpl  := label.new(bar_index + prevLen, pPTlvl, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small)
    lsl  := label.new(bar_index + prevLen, pSLlvl, "", xloc = xloc.bar_index, style = label.style_label_left, size = size.small)
if barstate.islast
    int xR = bar_index + prevLen
    line.set_xy1(lpt, bar_index, pPTlvl)
    line.set_xy2(lpt, xR, pPTlvl)
    line.set_color(lpt, showFrame ? color.new(colPT, 25) : color.new(colPT, 100))
    line.set_width(lpt, math.max(1, lineW - 1))
    line.set_xy1(lps, bar_index, pSLlvl)
    line.set_xy2(lps, xR, pSLlvl)
    line.set_color(lps, showFrame ? color.new(colSL, 25) : color.new(colSL, 100))
    line.set_width(lps, math.max(1, lineW - 1))
    line.set_xy1(lent, bar_index, close)
    line.set_xy2(lent, xR, close)
    line.set_color(lent, showFrame ? color.new(color.gray, 45) : color.new(color.gray, 100))
    bool lblOn = showFrame and showLevels
    label.set_xy(lpl, xR, pPTlvl)
    label.set_text(lpl, lblOn ? "next PT  " + str.tostring(pPTlvl, format.mintick) : "")
    label.set_color(lpl, lblOn ? color.new(colPT, 25) : color.new(color.gray, 100))
    label.set_textcolor(lpl, lblOn ? color.white : color.new(color.gray, 100))
    label.set_xy(lsl, xR, pSLlvl)
    label.set_text(lsl, lblOn ? "next SL  " + str.tostring(pSLlvl, format.mintick) : "")
    label.set_color(lsl, lblOn ? color.new(colSL, 25) : color.new(color.gray, 100))
    label.set_textcolor(lsl, lblOn ? color.white : color.new(color.gray, 100))

// entry markers (taken trades only) + optional diagnostic skip markers
plotshape(showMark and newLong,  "Long entry",  shape.triangleup,   location.belowbar, colPT, text = "LONG",  textcolor = color.white, size = size.small)
plotshape(showMark and newShort, "Short entry", shape.triangledown, location.abovebar, colSL, text = "SHORT", textcolor = color.white, size = size.small)
metaSkip = useMeta and metaReady and not metaPass
plotshape(showSkip and metaSkip and (rawLong or rawShort), "Meta skip", shape.xcross, location.abovebar, color.new(color.gray, 20), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                   LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(position.bottom_left, 2, 8, frame_width = 1, border_width = 1)
f_lg(int rw, string sw, color swc, string txt) =>
    color bg = rw % 2 == 0 ? panelBg : rowAlt
    table.cell(lg, 0, rw, sw, text_color = swc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lg, 1, rw, txt, text_color = txtSub, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    table.set_bgcolor(lg, panelBg)
    table.set_frame_color(lg, frameC)
    table.set_border_color(lg, frameC)
    table.cell(lg, 0, 0, "KEY", text_color = txtMain, bgcolor = frameC, text_size = size.tiny)
    table.cell(lg, 1, 0, "what you're looking at", text_color = txtMain, bgcolor = frameC, text_size = size.tiny, text_halign = text.align_left)
    f_lg(1, "▲▼", colPT, "Entry taken (meta-gate passed)")
    f_lg(2, "━━", colPT, "Profit barrier (PT) + price")
    f_lg(3, "━━", colSL, "Stop barrier (SL) + price")
    f_lg(4, "┋", color.new(#ffa726, 0), "Time barrier — trade expires here")
    f_lg(5, "▒", txtSub, "Trade box: grey open · green PT · red SL")
    f_lg(6, "┈", colMFE, "MFE / MAE — best & worst excursion")
    f_lg(7, "- -", txtSub, "Dashed = next-trade frame (flat)")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(inTrade ? 1 : 0,         "EXP_inTrade",     color.new(color.gray, 100), display = display.data_window)
plot(inTrade ? tDir : 0,      "EXP_tradeDir",    color.new(color.gray, 100), display = display.data_window)
plot(inTrade ? ptLvl : na,    "EXP_barrierPT",   color.new(color.gray, 100), display = display.data_window)
plot(inTrade ? slLvl : na,    "EXP_barrierSL",   color.new(color.gray, 100), display = display.data_window)
plot(resolved ? outcome : na, "EXP_outcome",     color.new(color.gray, 100), display = display.data_window)
plot(pTakeNow,                "EXP_metaP",       color.new(color.gray, 100), display = display.data_window)
plot(sizeSug,                 "EXP_sizeSuggest", color.new(color.gray, 100), display = display.data_window)
plot(expR,                    "EXP_ExpR",        color.new(color.gray, 100), display = display.data_window)
plot(netR,                    "EXP_NetR",        color.new(color.gray, 100), display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(newLong,  "Long framed",  "Triple-Barrier: long trade framed (context, not advice)")
alertcondition(newShort, "Short framed", "Triple-Barrier: short trade framed (context, not advice)")
alertcondition(resolved and outcome ==  1, "Profit barrier hit",  "Triple-Barrier: profit barrier touched first")
alertcondition(resolved and outcome == -1, "Stop barrier hit",    "Triple-Barrier: stop barrier touched first")
alertcondition(resolved and outcome ==  0, "Time barrier hit",    "Triple-Barrier: vertical (time) barrier reached")
````

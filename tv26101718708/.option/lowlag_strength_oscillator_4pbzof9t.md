# Low-Lag Strength Oscillator

- url: https://www.tradingview.com/script/4pBzoF9t-Low-Lag-Strength-Oscillator/
- type: indicator
- pine_id: PUB;d5e150650ce149d68bbb37942d7bda79
- version: 4.0

## Description

Low-Lag Strength Oscillator [LLSO]

What this script does

LLSO is a bounded 0–100 momentum oscillator in the relative-strength family. It measures the balance between up-strength and down-strength in price, but smooths each side with a low-lag two-pole low-pass filter instead of the rolling/exponential average a classic strength index uses. The result keeps the familiar overbought/oversold behaviour and the 50 balance line, but turns several bars earlier — better measurement of the same momentum, not a different concept bolted on.

Why these components are combined (mashup justification)

This is not several indicators shown side by side. There is exactly one plotted value — the smoothed strength oscillator. Everything else is a decision-support layer built on that single value, and each layer answers one specific question about the same oscillator:

The low-lag smoother is the core. A short EMA reduces lag but overshoots and adds noise; a long average is smooth but late. The two-pole low-pass filter removes lag in the pass band without the overshoot, so the up/down strength legs are both responsive and stable. This is what makes the oscillator usable for early reads.
Divergence compares price pivots to oscillator pivots. Because the oscillator is a strength reading, a higher price high against a lower oscillator high is fading strength — information that the line alone doesn't make explicit. Regular and hidden divergences are detected from confirmed pivots only.
Reversal dots mark the moment the line turns back from inside the overbought/oversold bands — a context cue about where in the range the turn happened, which a bare line forces you to eyeball.
The calibration harness is the reason the rest is trustworthy. It logs every signal the oscillator produces and, a fixed horizon later, checks whether price actually moved at least k×ATR in the signal's direction — then reports Hit %, the unconditional Base %, and the Edge (Hit − Base). It scores the oscillator's own output against reality.

These belong in one script because they all operate on, and report about, the same single oscillator. Splitting them into separate studies would mean re-deriving the oscillator three times and losing the shared pivot/threshold context that ties them together.

What makes it original

Two things. First, the strength index is rebuilt on a low-lag low-pass smoother rather than the conventional average, which changes its timing without changing its bounded, mean-reverting character. Second — and more importantly — most oscillators emit signals and never tell you whether those signals lead anywhere. LLSO carries a built-in honesty layer: the calibration harness shows the realized hit rate of its own signals against the base rate on your instrument and timeframe. If the Edge sits near zero, the script says so plainly. That measurement-first design, not the oscillator alone, is the contribution.

How to use it

Add to a chart. Defaults target intraday index futures (e.g. NSE NIFTY); for other instruments simply change the chart, or set the Price / High / Low source inputs (group 01) to retarget the engine — you can even feed it another indicator's plot.
Read the line: green above the 50 balance line = net up-strength, red below = net down-strength; the gradient fill and color saturation scale with conviction (distance from 50). The dashed bands mark overbought/oversold.
Use divergences as early warning of fading strength and reversal dots as in-band turn cues — points to investigate, not automatic trades.
Read the Edge row in the panel before trusting signals. A positive Edge means the signal preceded a forward move more often than chance on this symbol/timeframe; near zero means it didn't. The panel shows "warming" until enough samples accumulate.
The smoother period, OB/OS levels, divergence pivots, and the calibration horizon/threshold are all configurable.

Limitations

Statistics are in-sample, close-to-close, without costs — a study aid, not a backtest. They describe past behaviour on loaded history, not a forward guarantee.
Lower lag is better measurement, not an edge; an earlier turn is still wrong if the turn leads nowhere.
Divergence prints a few bars after the pivot it confirms — that lag is inherent to honest, non-repainting pivot detection.
This is an analytical oscillator. It issues no automated buy/sell instructions and is not a strategy.

Concept credit

The low-lag two-pole low-pass smoother and the strength-index reformulation are based on the published work of John F. Ehlers (Technical Analysis of Stocks & Commodities, 2024).
The Relative Strength Index that this oscillator generalizes is by J. Welles Wilder (New Concepts in Technical Trading Systems, 1978).

The implementation, the calibration harness, the divergence/reversal layers and the packaging are original.

Disclaimer

For research and educational purposes only. This script is not financial advice, not a recommendation, and not a guarantee of future results. Indicators describe price behaviour; they do not predict the future. Trading carries risk of loss. Test on out-of-sample data and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// LEAD-LAG INFORMATION FLOW                                                               v3.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// v3.0 — WHAT'S NEW
//   • SURROGATE significance — the gap this header used to flag is now closed. The observed net
//     transfer entropy is tested against a TIME-SHIFT SURROGATE null (the source series is shifted
//     to break the true lead-lag alignment while keeping each series' own structure); a z and a
//     pass/fail tell you whether the lead is beyond what chance alignment produces.
//   • RÉNYI-q transfer entropy — an effective-Rényi generalisation (Jizba et al.) with a tunable q:
//     q = 1 is the classic Shannon TE, q > 1 emphasises the common transitions, q < 1 the rare
//     (tail) ones. q = 1 reproduces v2 exactly.
//   • EMBEDDING > 1 — the target's history can use one OR two past states, so genuine 2-step
//     memory in the follower is conditioned out before crediting the leader.
//   • REGIME★ backbone — optionally consume EXP_Regime from the Market Regime Classifier to require
//     a trending follower, instead of (or beside) the internal Hurst read.
//   • HARNESS+ — the edge track-record adds a uniqueness-weighted EFFECTIVE sample size, an
//     IN-SAMPLE / OUT-OF-SAMPLE split (the OOS edge is the one to trust) and a deflated bar.
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A single line that answers one question correlation cannot: WHO MOVES FIRST. It measures the
//   net DIRECTIONAL information flow between a reference symbol and the chart using transfer
//   entropy - how much knowing the reference's last move reduces uncertainty about the chart's
//   NEXT move, beyond what the chart's own past already says, minus the same quantity in reverse.
//   Plotted around zero: positive = the reference leads the chart; negative = the chart leads the
//   reference. Alongside it sits a regime read (is the follower trending or chopping?) because a
//   lead is only worth acting on when the follower is in a state that lets it pay off. This is a
//   study of lead-lag STRUCTURE, not a buy/sell signal.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not three overlays)
//   Three components, one question - "is there exploitable lead-lag right now, and which way?":
//     - TRANSFER ENTROPY (net, in bits) answers DIRECTION of information: who leads. It is model-
//       free and captures nonlinear lead-lag a correlation or regression misses, and netting the
//       two directions cancels much of the small-sample bias that plagues raw entropy estimates.
//     - The HURST REGIME read answers WHETHER a lead is tradeable: information flow into a
//       persistent (trending) follower is far more actionable than into a mean-reverting chop.
//     - The CALIBRATION HARNESS answers WHETHER IT ACTUALLY WORKED here: it logs each lead-and-
//       follow setup and, a fixed horizon later, checks whether the chart moved with the leader.
//   Direction without a regime filter fires into noise; a regime read without direction is just a
//   Hurst line; either without calibration is an untested claim. Together they form one decision:
//   lead exists (entropy) + follower can run (regime) + it has paid before (Edge). Remove any one
//   and the question is answered less completely - which is why they ship as a single engine.
//
// HOW IT WORKS
//   1. Each series' bar-to-bar move is reduced to an up/down state.
//   2. Over a window, state-transition frequencies estimate the transfer entropy in each
//      direction (Schreiber); the plotted value is the NET (reference->chart minus chart->ref).
//   3. A Hurst exponent (structure-function estimate around 0.5) classifies the follower's regime.
//   4. A FOLLOW setup arms when net flow says the reference leads AND the reference has just moved;
//      the calibration harness then measures whether the chart followed by at least k x ATR.
//
// HOW TO USE
//   Read the line for direction (above zero / the upper threshold = reference leads; below =
//   chart leads) and the dashboard for regime and the Edge row. A lead into a trending follower
//   with a positive, matured Edge is the context this tool is built to surface; a lead into a
//   reverting follower, or with Edge near zero, is the engine telling you the lead-lag is not
//   exploitable on this pair and timeframe. Context, never a standalone trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   The chart is the follower; the Reference symbol is the candidate leader - both are inputs, so
//   the engine runs on any related pair in any market (cash vs futures, index vs lead constituent,
//   asset vs its dominant driver). Default reference NSE:NIFTY pairs the cash index against a
//   NIFTY-futures chart; change it for any other pair.
//
// NON-REPAINT
//   The reference series is requested with lookahead off and read on confirmed bars; the entropy,
//   regime and calibration all use closed-bar data. No higher-timeframe lookahead is used.
//
// CONCEPT CREDIT
//   Transfer entropy - Thomas Schreiber (2000). Information entropy - Claude E. Shannon (1948).
//   Rényi transfer entropy - Alfréd Rényi; effective-Rényi TE - Jizba, Kleinert & Shefaat (2012).
//   Surrogate-data significance - Theiler et al. (1992). Miller-Madow bias correction - Miller
//   (1955). Sample-uniqueness weighting & out-of-sample evaluation - Marcos López de Prado (2018).
//   Hurst exponent - Harold E. Hurst (1951); long-memory framing - Benoit Mandelbrot.
//   Original implementation; not affiliated with, nor endorsed by, any third party.
//
// HONESTY / LIMITATIONS
//   This is a COARSE, two-state, windowed estimator. v3.0 adds a genuine TIME-SHIFT SURROGATE test
//   (the streaming-feasible form of surrogate significance): the net TE is compared to a null built
//   by shifting the source out of alignment, so you can see whether the lead beats chance. It is a
//   shift surrogate, not a full IAAFT reshuffle, and the two-state coarse-graining remains - so
//   read the surrogate z as evidence, not proof. The Miller-Madow correction and direction-netting
//   still reduce small-sample bias. Edge figures are in-sample, close-to-close, with overlapping
//   forward windows and no costs - the OOS row is the one to trust. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability
//   for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Lead-Lag Information Flow", "Info Flow", overlay = false, max_labels_count = 120, dynamic_requests = true, max_bars_back = 900)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 01 · DATA & SOURCE ───────────────────────────────────────────────────────────────────
g0 = "01 · Data & source"
src    = input.source(close, "Chart (follower) source", group = g0, tooltip = "The series whose NEXT move we test. Works on any symbol / market.")
refSym = input.symbol("NSE:NIFTY", "Reference (candidate leader) symbol", group = g0, tooltip = "The series tested as the LEADER. Default NSE:NIFTY (cash) pairs with NIFTY futures; set it to any related instrument.")

// ── 02 · TRANSFER ENTROPY ────────────────────────────────────────────────────────────────
g1 = "02 · Transfer entropy"
teLen    = input.int(120, "Window (transitions)", minval = 40, maxval = 400, group = g1, tooltip = "How many state transitions are tallied for the probability estimate. Longer = steadier but slower.")
teKy     = input.int(1, "Target embedding (history states)", minval = 1, maxval = 2, group = g1, tooltip = "How many PAST states of the follower are conditioned out before crediting the leader. 1 = classic (v2). 2 = removes genuine 2-step follower memory (needs a longer window).")
teQ      = input.float(1.0, "Rényi q (1 = Shannon)", minval = 0.2, maxval = 3.0, step = 0.1, group = g1, tooltip = "Rényi order. 1 = classic Shannon TE (reproduces v2). q > 1 emphasises COMMON transitions; q < 1 emphasises RARE (tail) transitions.")
biasOn   = input.bool(true, "Finite-sample bias correction", group = g1, tooltip = "Miller-Madow correction (Shannon / q = 1 only): subtracts the small-sample bias raw TE estimates carry on short windows. Recommended on.")
teSmooth = input.int(3, "Smoothing (EMA, 1 = off)", minval = 1, maxval = 20, group = g1)
teThr    = input.float(0.02, "Lead threshold (bits)", minval = 0.0, step = 0.01, group = g1, tooltip = "Net flow beyond +/- this marks a decisive lead and tints the background.")

// ── 02b · SURROGATE SIGNIFICANCE ─────────────────────────────────────────────────────────
gSg = "02b · Surrogate significance"
useSurr  = input.bool(true, "Time-shift surrogate significance", group = gSg, tooltip = "Test the observed net TE against a null built by SHIFTING the source out of alignment (breaks the true lead-lag while keeping each series' own structure). Reports a z and a pass/fail.")
nSurr    = input.int(5, "Surrogate shifts", minval = 3, maxval = 10, group = gSg, tooltip = "How many shifted nulls to average. More = steadier null, heavier compute.")
surrBase = input.int(19, "Surrogate base shift (bars)", minval = 7, maxval = 40, group = gSg, tooltip = "The k-th surrogate shifts the source by base×k bars. Kept away from the true lag so the null is genuinely mis-aligned.")
surrZthr = input.float(1.64, "Surrogate significance z", minval = 1.0, maxval = 4.0, step = 0.05, group = gSg, tooltip = "The lead is flagged significant when the net TE is this many surrogate-σ above the shifted null (1.64 ≈ 95% one-sided).")
gateSurr = input.bool(true, "Require surrogate significance for signals", group = gSg, tooltip = "When on (default), follow signals only fire when the lead beats the surrogate null — so on a pair with no genuine lead-lag the tool stays quiet instead of marking noise.")

// ── 03 · SIGNAL & REGIME ─────────────────────────────────────────────────────────────────
g2 = "03 · Signal & regime"
refMomLen = input.int(3, "Reference momentum length", minval = 1, group = g2, tooltip = "Sign of the reference's move over this many bars sets the follow direction.")
hLen      = input.int(100, "Hurst window (regime)", minval = 40, maxval = 400, group = g2)
reqTrend  = input.bool(false, "Require trending regime (H > 0.5) for signal", group = g2)
sigGap    = input.int(10, "Min bars between follow signals", minval = 1, maxval = 200, group = g2, tooltip = "Cooldown after a follow mark before another can fire, so a sustained lead shows occasional marks instead of one on every bar.")
showSig   = input.bool(true, "Mark follow signals", group = g2)
useRegime = input.bool(false, "Consume external regime (EXP_Regime)", group = g2, tooltip = "Link the source below to the Market Regime Classifier's EXP_Regime (−2…+2) and require a trending follower (state ≥ 1) for signals, instead of the internal Hurst read.")
regSrc    = input.source(close, "Regime source (link to EXP_Regime)", group = g2)

// ── 04 · CALIBRATION HARNESS ─────────────────────────────────────────────────────────────
g4 = "04 · Calibration harness"
calibOn   = input.bool(true, "Run calibration", group = g4, tooltip = "Logs every follow setup and, a fixed horizon later, checks whether the chart followed >= k x ATR in the signal direction. Reports Hit %, unconditional Base %, and Edge = Hit - Base.")
calHor    = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
calMove   = input.float(0.6, "Move threshold (x ATR)", minval = 0.1, step = 0.1, group = g4)
calAtrLen = input.int(14, "ATR length", minval = 1, group = g4)
trainN    = input.int(30, "In-sample events (then OOS)", minval = 10, group = g4, tooltip = "HARNESS+: the first N resolved (CUSUM-gated) events train; every later event is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
nTests    = input.int(3, "Edge significance · N tests (deflation)", minval = 1, maxval = 10, group = g4, tooltip = "HARNESS+: raise the significance bar for the number of things tested (Bonferroni-style z).")

// ── 05 · VISUAL STYLE ────────────────────────────────────────────────────────────────────
g5 = "05 · Visual style"
dispMode = input.string("Normalized (oscillator)", "Display scale", options = ["Normalized (oscillator)","Net TE (bits)"], group = g5, tooltip = "Normalized: the net flow is scaled to its own recent σ so it swings on a consistent, banded oscillator scale (like RSI/MACD) — the SIGN still means direction (above 0 = reference leads). Net TE (bits): the raw value in bits (v2 look).")
visStyle = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = g5)
showTint = input.bool(true, "Background regime tint", group = g5)
colBull  = input.color(#2ebd85, "Ref leads / up", inline = "cc", group = g5)
colBear  = input.color(#f6465d, "Chart leads / down", inline = "cc", group = g5)
colMid   = input.color(#f7c948, "Midline", group = g5)

// ── 06 · DASHBOARD & THEME ───────────────────────────────────────────────────────────────
g6 = "06 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelPos  = input.string("Bottom Right", "Dashboard position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6, tooltip = "Auto reads the chart background luminance so the panel stays legible on any colour scheme.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    STATES & REFERENCE
// ═════════════════════════════════════════════════════════════════════════════════════════
float xClose = request.security(refSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool  refLive = not na(xClose)
float retY = src - src[1]
float retX = xClose - xClose[1]
int ySt = retY >= 0 ? 1 : 0
int xSt = (not na(retX) and retX >= 0) ? 1 : 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                         ENGINE · two-state transfer entropy (Schreiber)
// ═════════════════════════════════════════════════════════════════════════════════════════
// Generalised two-state TE:  target-embedding kY (1 or 2), Rényi order q (q=1 → Shannon + Miller-
// Madow), and a source time-SHIFT (0 = real; >0 = surrogate that breaks lead-lag alignment).
// Indexing (validated against a reference): yp = target-past index (0..nYp-1), yf = target future,
// xp = source past.  c3[yp*4+yf*2+xp] · c2s[yp*2+xp] · c2t[yf*nYp+yp] · c1t[yp].
f_te(simple int win, simple bool xToY, simple bool mm, simple int kY, simple float q, int shift) =>
    int nYp = kY == 2 ? 4 : 2
    array<float> c3  = array.new<float>(nYp * 4, 0.0)
    array<float> c2s = array.new<float>(nYp * 2, 0.0)
    array<float> c2t = array.new<float>(2 * nYp, 0.0)
    array<float> c1t = array.new<float>(nYp,     0.0)
    float cnt = 0.0
    for i = 0 to win - 1
        int yf = xToY ? ySt[i] : xSt[i]
        int yp = kY == 2 ? (xToY ? ySt[i + 1] * 2 + ySt[i + 2] : xSt[i + 1] * 2 + xSt[i + 2]) : (xToY ? ySt[i + 1] : xSt[i + 1])
        int xp = xToY ? xSt[i + 1 + shift] : ySt[i + 1 + shift]
        array.set(c3,  yp * 4 + yf * 2 + xp, array.get(c3,  yp * 4 + yf * 2 + xp) + 1.0)
        array.set(c2s, yp * 2 + xp,          array.get(c2s, yp * 2 + xp)          + 1.0)
        array.set(c2t, yf * nYp + yp,        array.get(c2t, yf * nYp + yp)        + 1.0)
        array.set(c1t, yp,                   array.get(c1t, yp)                   + 1.0)
        cnt += 1.0
    float Tn = cnt
    float te = na
    if Tn > 0.0
        if math.abs(q - 1.0) < 0.02
            float s = 0.0
            for a = 0 to nYp - 1
                for b = 0 to 1
                    for c = 0 to 1
                        float n3 = array.get(c3, a * 4 + b * 2 + c)
                        if n3 > 0.0
                            float p3  = n3 / Tn
                            float pys = array.get(c2s, a * 2 + c) / Tn
                            float pyy = array.get(c2t, b * nYp + a) / Tn
                            float py  = array.get(c1t, a) / Tn
                            if pys > 0.0 and pyy > 0.0 and py > 0.0
                                float ratio = (p3 / pys) / (pyy / py)
                                if ratio > 0.0
                                    s += p3 * (math.log(ratio) / math.log(2.0))
            if mm
                int k3 = 0
                for j = 0 to nYp * 4 - 1
                    if array.get(c3, j) > 0.0
                        k3 += 1
                int k2s = 0
                for j = 0 to nYp * 2 - 1
                    if array.get(c2s, j) > 0.0
                        k2s += 1
                int k2t = 0
                for j = 0 to 2 * nYp - 1
                    if array.get(c2t, j) > 0.0
                        k2t += 1
                int k1 = 0
                for j = 0 to nYp - 1
                    if array.get(c1t, j) > 0.0
                        k1 += 1
                s += (k2t + k2s - k1 - k3) / (2.0 * Tn * math.log(2.0))
            te := s
        else
            // effective Rényi TE = H_q(Yf|Yp) − H_q(Yf|Yp,Xp), escort-weighted (Jizba et al.)
            float Zp = 0.0
            for a = 0 to nYp - 1
                float pc = array.get(c1t, a) / Tn
                if pc > 0.0
                    Zp += math.pow(pc, q)
            float sHyp = 0.0
            for a = 0 to nYp - 1
                float pc = array.get(c1t, a) / Tn
                if pc > 0.0 and Zp > 0.0
                    float phi = math.pow(pc, q) / Zp
                    float inner = 0.0
                    for b = 0 to 1
                        float pj = array.get(c2t, b * nYp + a) / Tn
                        if pj > 0.0
                            inner += math.pow(pj / pc, q)
                    sHyp += phi * inner
            float Hyp = sHyp > 0.0 ? (1.0 / (1.0 - q)) * (math.log(sHyp) / math.log(2.0)) : na
            float Zpx = 0.0
            for a = 0 to nYp - 1
                for c = 0 to 1
                    float pc = array.get(c2s, a * 2 + c) / Tn
                    if pc > 0.0
                        Zpx += math.pow(pc, q)
            float sHypx = 0.0
            for a = 0 to nYp - 1
                for c = 0 to 1
                    float pc = array.get(c2s, a * 2 + c) / Tn
                    if pc > 0.0 and Zpx > 0.0
                        float phi = math.pow(pc, q) / Zpx
                        float inner = 0.0
                        for b = 0 to 1
                            float pj = array.get(c3, a * 4 + b * 2 + c) / Tn
                            if pj > 0.0
                                inner += math.pow(pj / pc, q)
                        sHypx += phi * inner
            float Hypx = sHypx > 0.0 ? (1.0 / (1.0 - q)) * (math.log(sHypx) / math.log(2.0)) : na
            te := (not na(Hyp) and not na(Hypx)) ? Hyp - Hypx : na
    te

float teXY_raw = bar_index >= teLen + teKy + 2 and refLive ? f_te(teLen, true,  biasOn, teKy, teQ, 0) : na
float teYX_raw = bar_index >= teLen + teKy + 2 and refLive ? f_te(teLen, false, biasOn, teKy, teQ, 0) : na
float netRaw = (not na(teXY_raw) and not na(teYX_raw)) ? teXY_raw - teYX_raw : na

// ── time-shift SURROGATE null: shift the source out of alignment, average the shifted nets ──────
var float surrZ = na
float sSum = 0.0
float sSq  = 0.0
int   sCnt = 0
if useSurr and refLive and not na(netRaw) and bar_index >= teLen + teKy + surrBase * nSurr + 3
    for k = 1 to nSurr
        float nsurr = f_te(teLen, true, biasOn, teKy, teQ, surrBase * k) - f_te(teLen, false, biasOn, teKy, teQ, surrBase * k)
        if not na(nsurr)
            sSum += nsurr
            sSq  += nsurr * nsurr
            sCnt += 1
float sMean = sCnt > 0 ? sSum / sCnt : na
float sStd  = sCnt > 1 ? math.sqrt(math.max(sSq / sCnt - sMean * sMean, 0.0)) : na
surrZ := (useSurr and not na(netRaw) and not na(sMean) and not na(sStd) and sStd > 0.0) ? (netRaw - sMean) / sStd : na
bool  surrSig = not na(surrZ) and math.abs(surrZ) >= surrZthr
float netEma = ta.ema(netRaw, teSmooth)
float netTE = teSmooth > 1 ? netEma : netRaw

// ===== Effective net TE (baseline-subtracted, standardized) + significance gate =====
teEffLen = input.int(120, "Effective-TE baseline window", minval = 30, group = "Z2 · Advanced calibration")
float teMu = ta.sma(netTE, teEffLen)
float teSd = ta.stdev(netTE, teEffLen)
float teEff = (not na(netTE) and not na(teMu)) ? netTE - teMu : na
float teZ   = (not na(teEff) and not na(teSd) and teSd > 0) ? teEff / teSd : na
float teSigVal = (not na(teZ) and math.abs(teZ) >= 2.0) ? netTE : 0.0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                         HURST regime (structure-function estimate)
// ═════════════════════════════════════════════════════════════════════════════════════════
float lY = math.log(src)
float hm1 = ta.sma(math.abs(lY - lY[1]), hLen)
float hm2 = ta.sma(math.abs(lY - lY[2]), hLen)
float hm4 = ta.sma(math.abs(lY - lY[4]), hLen)
float hm8 = ta.sma(math.abs(lY - lY[8]), hLen)
array<float> hxs = array.from(math.log(1.0), math.log(2.0), math.log(4.0), math.log(8.0))
array<float> hys = array.from(math.log(math.max(hm1,1e-10)), math.log(math.max(hm2,1e-10)), math.log(math.max(hm4,1e-10)), math.log(math.max(hm8,1e-10)))
float hsx = 0.0
float hsy = 0.0
float hsxx = 0.0
float hsxy = 0.0
for i = 0 to 3
    float xi = array.get(hxs, i)
    float yi = array.get(hys, i)
    hsx += xi
    hsy += yi
    hsxx += xi*xi
    hsxy += xi*yi
float hDen = 4.0*hsxx - hsx*hsx
float hurst = hDen != 0 ? (4.0*hsxy - hsx*hsy)/hDen : 0.5
hurst := math.max(0.0, math.min(1.0, hurst))
bool trending = hurst >= 0.5

float xMom = xClose - xClose[refMomLen]
bool refLeads = not na(netTE) and netTE >= teThr
// regime gate: external REGIME★ (if linked and valid) requires a trending follower; else internal Hurst
bool regValid = useRegime and not na(regSrc) and math.abs(regSrc) <= 2.5
int  regId    = regValid ? int(math.round(regSrc)) : na
bool regimeOK = useRegime ? (not na(regId) and regId >= 1) : (not reqTrend or trending)
bool surrOK   = not gateSurr or surrSig
// A follow setup is a discrete EVENT, not a per-bar level: it needs the ref-leads state to hold,
// the regime and (by default) the surrogate test to pass, a fresh reference move, AND a cooldown
// since the last mark — so the chart shows occasional, meaningful marks instead of one per bar.
bool leadState = refLeads and regimeOK and surrOK
var int lastFollowBar = na
bool cooled = na(lastFollowBar) or (bar_index - lastFollowBar) >= sigGap
bool longSig  = leadState and cooled and not na(xMom) and xMom > 0
bool shortSig = leadState and cooled and not na(xMom) and xMom < 0
if longSig or shortSig
    lastFollowBar := bar_index

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showGlow = isArea or isLine

// DISPLAY VALUE — normalized (net flow ÷ its own recent σ, sign = direction) or raw bits.
// Normalization keeps the lead direction (sign) but puts the swing on a consistent, banded scale.
bool  normOsc = dispMode != "Net TE (bits)"
float oscView = na(netTE) ? na : normOsc ? (teSd > 0.0 ? netTE / teSd : na) : netTE
float viewHi  = normOsc ? 1.5 : teThr            // "decisive lead" band
float viewEx  = normOsc ? 2.5 : teThr * 2.0      // "strong lead" band
float areaDen = normOsc ? 3.0 : math.max(teThr * 3.0, 0.01)

color lineCol = na(oscView) ? color.gray : oscView >= 0 ? colBull : colBear

// yellow midline (house signature) + symmetric decisive/strong bands
plot(0.0, "Mid glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(0, "No net flow", color = color.new(colMid, 0), linestyle = hline.style_solid)
plot(viewHi,  "Ref-leads band",  color = color.new(colBull, 55), linewidth = 1, display = display.pane, editable = false)
plot(-viewHi, "Chart-leads band", color = color.new(colBear, 55), linewidth = 1, display = display.pane, editable = false)
plot(viewEx,  "Strong-ref band",  color = color.new(colBull, 72), linewidth = 1, display = display.pane, editable = false)
plot(-viewEx, "Strong-chart band", color = color.new(colBear, 72), linewidth = 1, display = display.pane, editable = false)

// glow line (Line / Gradient styles) or histogram columns
plot(showGlow ? oscView : na, "glow outer", color = color.new(lineCol, 82), linewidth = 8, display = display.pane)
plot(showGlow ? oscView : na, "glow inner", color = color.new(lineCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showGlow ? oscView : na, "Net information flow", color = lineCol, linewidth = 2, display = display.pane)
plot(isHist ? oscView : na, "Histogram", color = color.new(lineCol, 20), style = plot.style_columns, display = display.pane)

// gradient area under the line, intensity scaling with the reading
pBase = plot(isArea ? 0.0 : na, "base", color = na, display = display.none, editable = false)
float areaInt = math.min(1.0, math.abs(nz(oscView)) / areaDen)
fill(pMain, pBase, color = isArea ? color.new(oscView >= 0 ? colBull : colBear, 92 - int(42 * areaInt)) : na)

// background regime tint - decisive lead at a glance (keyed to the displayed scale)
bgcolor(showTint and not na(oscView) and oscView >= viewHi ? color.new(colBull, 92) : showTint and not na(oscView) and oscView <= -viewHi ? color.new(colBear, 92) : na)

// follow signals (in-pane, on the displayed oscillator)
plotshape(showSig and longSig  ? oscView : na, "Follow long",  shape.triangleup,   location.absolute, color.new(colBull, 0), size = size.tiny)
plotshape(showSig and shortSig ? oscView : na, "Follow short", shape.triangledown, location.absolute, color.new(colBear, 0), size = size.tiny)

// FOLLOW signals on the PRICE chart — tiny directional triangles, proper colour:
// green up (below bar) = reference leads UP, chart expected to follow · red down (above bar) = leads DOWN
plotshape(showSig and longSig,  "Follow long (overlay)",  shape.triangleup,   location.belowbar, color = colBull, size = size.tiny, force_overlay = true)
plotshape(showSig and shortSig, "Follow short (overlay)", shape.triangledown, location.abovebar, color = colBear, size = size.tiny, force_overlay = true)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       CALIBRATION
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrC = ta.atr(calAtrLen)
var int sigN    = 0
var int hitN    = 0
var int baseTot = 0
var int baseUp  = 0
var int baseDn  = 0
float fwdMv  = close - close[calHor]
float fwdAtr = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fwdAtr) and fwdAtr > 0
    if longSig[calHor]
        sigN += 1
        if fwdMv >= calMove * fwdAtr
            hitN += 1
    if shortSig[calHor]
        sigN += 1
        if -fwdMv >= calMove * fwdAtr
            hitN += 1
    baseTot += 1
    if fwdMv >= calMove * fwdAtr
        baseUp += 1
    if -fwdMv >= calMove * fwdAtr
        baseDn += 1

float hitP  = sigN > 0 ? hitN * 100.0 / sigN : na
float baseP = baseTot > 0 ? (baseUp + baseDn) * 100.0 / (2.0 * baseTot) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// ===== FORWARD-STATISTICS UPGRADE  (Wilson interval + significance) =====
f_wilson(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r
float ciPct   = f_wilson(hitN, sigN, 1.96) * 100.0
bool  sigStar = sigN >= 20 and not na(hitP) and not na(baseP) and (hitP - ciPct) > baseP

// ===== CUSUM event-sampling + Wald-Wolfowitz runs-test + Wilson edge floor =====
cusumK = input.float(1.0, "CUSUM event threshold (x ATR)", minval = 0.1, step = 0.1, group = "Z2 · Advanced calibration")
var float csPos = 0.0
var float csNeg = 0.0
float csRet = close - close[1]
csPos := math.max(0.0, csPos + csRet)
csNeg := math.min(0.0, csNeg + csRet)
bool cusumEvt = not na(atrC) and atrC > 0 and (csPos >= cusumK * atrC or csNeg <= -cusumK * atrC)
if cusumEvt
    csPos := 0.0
    csNeg := 0.0
var array<int>   rtDir  = array.new<int>()
var array<int>   rtBar  = array.new<int>()
var array<float> rtEnt  = array.new<float>()
var array<float> rtAtr0 = array.new<float>()
var array<float> rtUniq = array.new<float>()          // HARNESS+ per-event uniqueness weight
var int rtPrev = 0
var int rtRuns = 0
var int rtW = 0
var int rtL = 0
var float hitsW = 0.0, var float totW = 0.0           // uniqueness-weighted (effective N)
var int isHits = 0, var int isTot = 0                 // in-sample
var int oosHits = 0, var int oosTot = 0               // out-of-sample
var int resolvedC = 0
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    if cusumEvt and (longSig)
        rtDir.push(1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC), rtUniq.push(1.0 / (1.0 + rtBar.size()))
    if cusumEvt and (shortSig)
        rtDir.push(-1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC), rtUniq.push(1.0 / (1.0 + rtBar.size()))
    if rtBar.size() > 0
        for i = rtBar.size() - 1 to 0
            if bar_index - rtBar.get(i) >= calHor
                float fwd = (close - rtEnt.get(i)) * rtDir.get(i)
                bool  win = fwd >= calMove * rtAtr0.get(i)
                int wlab = win ? 1 : -1
                float w  = rtUniq.get(i)
                totW += w
                hitsW := win ? hitsW + w : hitsW
                if resolvedC < trainN
                    isTot += 1
                    isHits := win ? isHits + 1 : isHits
                else
                    oosTot += 1
                    oosHits := win ? oosHits + 1 : oosHits
                resolvedC += 1
                rtRuns := rtPrev == 0 ? 1 : (wlab != rtPrev ? rtRuns + 1 : rtRuns)
                rtPrev := wlab
                rtW := wlab == 1 ? rtW + 1 : rtW
                rtL := wlab == -1 ? rtL + 1 : rtL
                rtDir.remove(i), rtBar.remove(i), rtEnt.remove(i), rtAtr0.remove(i), rtUniq.remove(i)
float rtNn = rtW + rtL
float rtMu = rtNn > 0 ? 2.0 * rtW * rtL / rtNn + 1.0 : na
float rtVr = rtNn > 1 ? 2.0 * rtW * rtL * (2.0 * rtW * rtL - rtNn) / (rtNn * rtNn * (rtNn - 1.0)) : na
float runsZ = (not na(rtMu) and not na(rtVr) and rtVr > 0) ? (rtRuns - rtMu) / math.sqrt(rtVr) : na
float edgeLB = (not na(hitP) and not na(baseP) and not na(ciPct)) ? (hitP - ciPct) - baseP : na
// HARNESS+ metrics — effective N, out-of-sample edge (vs unconditional base), deflated star
float zDefl     = nTests <= 1 ? 1.96 : nTests == 2 ? 2.24 : nTests == 3 ? 2.39 : nTests == 4 ? 2.50 : 2.58
float effN      = totW
float oosHitPct = oosTot > 0 ? oosHits / float(oosTot) * 100.0 : na
float oosEdge   = (not na(oosHitPct) and not na(baseP)) ? oosHitPct - baseP : na
float oosCi     = f_wilson(oosHits, oosTot, zDefl) * 100.0
bool  oosStar   = oosTot >= 10 and not na(oosHitPct) and not na(baseP) and (oosHitPct - oosCi) > baseP

// ── PLAIN-LANGUAGE VERDICT — does THIS pair actually show exploitable lead-lag? ─────────────────
// -2 no ref · -1 warming · 0 no significant lead-lag · 1 lead but no edge here · 2 lead + edge (IS) ·
// 3 exploitable (out-of-sample edge confirmed). Keeps the tool from looking "busy" when there's nothing.
int vCode = not refLive ? -2 : na(netTE) ? -1 : (useSurr and not na(surrZ) and not surrSig) ? 0 : (not na(oosEdge) and oosStar and oosEdge > 0.0) ? 3 : (not na(edge) and edge > 0.0) ? 2 : (not na(edge)) ? 1 : -1
string vTxt = vCode == -2 ? "no reference data" : vCode == -1 ? "warming up…" : vCode == 0 ? "no lead-lag (not significant)" : vCode == 1 ? "lead present · no edge here" : vCode == 2 ? "lead + edge · confirm OOS" : "exploitable lead-lag ✓"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              DASHBOARD  (theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right

var table T = table.new(f_pos(panelPos), 2, 15, frame_width = 1, border_width = 1)
if showPanel and barstate.islast
    color bgc    = chart.bg_color
    float luma   = na(bgc) ? 0.0 : color.r(bgc) * 0.299 + color.g(bgc) * 0.587 + color.b(bgc) * 0.114
    bool  darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgc) or luma < 140)
    color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
    color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
    color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
    color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
    color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
    color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
    color hdr     = color.new(colBull, 0)
    color cUp     = darkUI ? colBull : color.rgb(14, 124, 90)
    color cDn     = darkUI ? colBear : color.rgb(198, 40, 40)
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)

    string netTxt = not refLive ? "no reference" : na(netTE) ? "warming" : str.tostring(netTE, "0.000") + " bits"
    string lead   = na(netTE) ? "-" : netTE >= teThr ? "reference leads" : netTE <= -teThr ? "chart leads" : "balanced"
    color  leadCol = na(netTE) ? txtMut : netTE >= teThr ? cUp : netTE <= -teThr ? cDn : txtMain
    color  vCol    = vCode >= 2 ? cUp : vCode == 1 ? cDn : txtMut

    table.cell(T, 0, 0, "Info Flow", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(T, 1, 0, vTxt, text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(T, 0, 1, "Verdict / flow", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 1, (lead == "-" ? "-" : lead) + (na(netTE) ? "" : "  ·  " + netTxt), text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 2, "Regime", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 2, na(netTE) ? "-" : trending ? "trending" : "reverting", text_color = trending ? txtMain : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 3, "Hurst", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 3, na(hurst) ? "-" : str.tostring(hurst, "0.00"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 4, "Reference move", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 4, na(xMom) ? "-" : xMom > 0 ? "up" : xMom < 0 ? "down" : "flat", text_color = xMom > 0 ? cUp : xMom < 0 ? cDn : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 5, "Signals (n)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 5, str.tostring(sigN), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 6, "Hit %", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 6, sigN < 20 ? "warming" : str.tostring(hitP, "0") + "% +/-" + str.tostring(ciPct, "0"), text_color = sigN < 20 ? txtMut : txtMain, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 7, "Edge (Hit - Base)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 7, sigN < 20 or na(edge) ? "warming" : str.tostring(edge, "+0.0;-0.0") + " pts" + (sigStar ? " *" : ""), text_color = (sigN < 20 or na(edge)) ? txtMut : edge > 3 ? cUp : edge < -3 ? cDn : txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 8, "Runs-Z (streak)", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 8, na(runsZ) ? "warming" : str.tostring(runsZ, "0.0"), text_color = math.abs(nz(runsZ)) > 2.0 ? cDn : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 9, "Edge floor", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 9, na(edgeLB) ? "warming" : str.tostring(edgeLB, "+0.0;-0.0"), text_color = na(edgeLB) ? txtMut : edgeLB > 0 ? cUp : cDn, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 10, "Eff-TE / sig", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 10, na(teZ) ? "-" : str.tostring(teEff, "0.000") + (math.abs(teZ) >= 2.0 ? " *" : ""), text_color = na(teZ) ? txtMut : math.abs(teZ) >= 2.0 ? txtMain : txtMut, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 11, "Surrogate z", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 11, not useSurr ? "off" : na(surrZ) ? "warming" : str.tostring(surrZ, "0.0") + (surrSig ? " ✓ sig" : " ns"), text_color = na(surrZ) ? txtMut : surrSig ? cUp : txtMut, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 12, "Edge (OOS)", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 12, na(oosEdge) ? "warming" : (oosStar ? "★ " : "") + str.tostring(oosEdge, "+0.0;-0.0") + " pts", text_color = na(oosEdge) ? txtMut : oosEdge > 0 ? cUp : cDn, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 0, 13, "Eff-N (IS/OOS)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 1, 13, str.tostring(effN, "0.0") + "  (" + str.tostring(isTot) + "/" + str.tostring(oosTot) + ")", text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(T, 0, 14, "Regime (ext) / q·k", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(T, 1, 14, (useRegime ? (na(regId) ? "link EXP_Regime" : "state " + str.tostring(regId)) : "Hurst") + "  ·  q" + str.tostring(teQ, "0.0") + "/k" + str.tostring(teKy), text_color = txtMut, bgcolor = panelBg, text_size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "Lead-Lag Information Flow   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (netTE) : na, "EXP_NetTE", color = exC_, display = display.data_window)
plot(showEXP ? (netTE >= teThr ? 1 : netTE <= -teThr ? -1 : 0) : na, "EXP_Lead", color = exC_, display = display.data_window)
plot(showEXP ? (hurst) : na, "EXP_Hurst", color = exC_, display = display.data_window)
plot(showEXP ? (longSig ? 1 : shortSig ? -1 : 0) : na, "EXP_Signal", color = exC_, display = display.data_window)
plot(showEXP ? (edge) : na, "EXP_Edge", color = exC_, display = display.data_window)
plot(showEXP ? (refLive ? 1 : 0) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (teEff) : na, "EXP_TEeff", color = exC_, display = display.data_window)
plot(showEXP ? (teSigVal) : na, "EXP_TEsig", color = exC_, display = display.data_window)
plot(showEXP ? (surrZ) : na, "EXP_SurrZ", color = exC_, display = display.data_window)
plot(showEXP ? (surrSig ? 1 : 0) : na, "EXP_SurrSig", color = exC_, display = display.data_window)
plot(showEXP ? (runsZ) : na, "EXP_RunsZ", color = exC_, display = display.data_window)
plot(showEXP ? (edgeLB) : na, "EXP_EdgeLB", color = exC_, display = display.data_window)
plot(showEXP ? (oosEdge) : na, "EXP_EdgeOOS", color = exC_, display = display.data_window)
plot(showEXP ? (effN) : na, "EXP_EffN", color = exC_, display = display.data_window)
plot(showEXP ? (cusumEvt ? 1 : 0) : na, "EXP_CUSUM", color = exC_, display = display.data_window)
alertcondition(longSig,  "Follow long",      "Lead-Lag Information Flow: reference leads up - chart expected to follow.")
alertcondition(shortSig, "Follow short",     "Lead-Lag Information Flow: reference leads down - chart expected to follow.")
alertcondition(refLeads, "Reference leads",  "Lead-Lag Information Flow: net information flow from reference to chart.")
````

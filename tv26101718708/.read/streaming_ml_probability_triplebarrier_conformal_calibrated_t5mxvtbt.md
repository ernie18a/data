# Streaming ML Probability Triple-Barrier, Conformal & Calibrated

- url: https://www.tradingview.com/script/T5mxvtBt-Streaming-ML-Probability-Triple-Barrier-Conformal-Calibrated/
- type: indicator
- pine_id: PUB;d092e09530c345eeba3b4bbf2f215f9f
- version: 2.0

## Description

Streaming-ML Probability — Triple-Barrier, Conformal & Calibrated

What it is

A self-training probability model that estimates P(up-barrier resolves before down-barrier) and — crucially — reports its own calibration. The differentiator is not the classifier; it is the labelling and the honesty layer wrapped around it. The pane shows a probability, an honest uncertainty band, a plain-language verdict, and a reliability diagram that tells you whether to believe any of it.

Why these components belong in ONE script (not a stack of indicators)

They are the stages of one honest prediction pipeline, each fixing a failure mode of a naive "ML" overlay:

Triple-barrier labels define what is predicted as a real, path-dependent outcome (which barrier is hit first) instead of an arbitrary "next bar up?", and resolve forward in time so training only ever sees confirmed results — no look-ahead.
Z-scored, bounded features keep every input finite so no single bar can blow up the online weights.
Logistic SGD + Lorentzian k-NN, fused in log-odds with a Kish decorrelation shrink — a linear model for the trend and a fat-tail-tolerant neighbour vote for non-linear structure, combined without double-counting the shared features.
Regime engine (efficiency + ADX + Hawkes) gives each market state its own calibration and shrinks the probability toward 0.5 where a regime is barely seen — the model defers to a coin flip where it has not learned.
Adaptive Conformal Inference turns the point estimate into a coverage-controlled band that holds under drift, so the uncertainty is honest rather than a fake point estimate.
Conviction + hard vetoes (regime, MTF, participation/CVD, calibration quality) stop the model acting on a number it cannot back up.
The calibration harness — reliability table, Brier score, and forward edge versus an unconditional base rate — is the whole point: a probability is only useful if 70% means 70%.

Labels say what to learn, features feed it, the fused classifier predicts, regime + conformal say how much to trust it, the vetoes gate it, and calibration proves whether any of it held. Remove a stage and the honesty breaks — that is why they ship as one engine.

How it works (mechanics)

Each confirmed bar opens a triple-barrier sample (unless the OU half-life says reversion is too slow to resolve in the horizon). When a sample resolves, the model takes one online gradient step on its own features and outcome, the resolved sample enters the k-NN memory, and the nonconformity score updates the conformal band via Gibbs-Candès ACI. The live probability is the log-odds fusion of the logistic output and the Lorentzian k-NN vote, regime-shrunk during warm-up. A directional signal fires only when the probability band clears the signal margin, conviction clears its floor, and no hard veto trips. Every resolved directional call is then scored against an unconditional same-horizon base rate (Hit% vs Base%, Wilson-bounded, regime- and recency-weighted).

Non-repaint: training only on resolved triple-barrier outcomes, signals on bar close, MTF requested with lookahead_off, no dynamic-length ta(). The live probability updates each bar — a current estimate from fixed historical training.

How to use

Read the VERDICT line first — ACT, STAND ASIDE (no calibrated edge), or WAIT, based on the live signal and the model's own calibration.
Check the reliability diagram / Brier. Points off the diagonal, or Brier ≥ 0.25 (worse than a coin flip), mean the probability is not trustworthy yet — the engine will tell you to stand aside.
A signal fires only on confluence: probability past the band-margin, conviction past the floor, no hard veto.
The conformal band is the honest uncertainty — a wide band means low confidence.
Everything here is descriptive, probabilistic context — never an instruction.

Note on honesty: on pure intraday noise (e.g. NIFTY 1-minute) this model will often show NO EDGE / VETO with Brier ≈ worse than a coin flip — and it says so plainly rather than inventing a signal. That is the intended behaviour.

Use on any market

The Data Source inputs (Close / High / Low / Volume) drive the features, the triple-barrier labels and the calibration, so the model runs on any series (standard candles, Heikin-Ashi, etc.) and any market. All thresholds are ATR-relative. Defaults are set for NIFTY index-futures intraday; change the source or lengths for other assets. Assets with no volume simply contribute nothing through the volume feature.

Originality

Most "machine-learning" indicators emit an uncalibrated score that is never checked against what actually happened. The contribution here is the closed, honest loop: real path-dependent labels, a fused-but-decorrelated classifier, regime-conditional shrinkage, a drift-robust conformal band, conviction/veto gating, and a built-in reliability + Brier + edge harness that can — and often does — tell you the model has no edge right now. It is built to be disprovable, which is the opposite of most signal scripts.

Credits

Triple-barrier labelling & meta-labelling — Marcos López de Prado
Logistic regression / SGD — classical statistics
Lorentzian (non-Euclidean) distance for k-NN — relativistic-distance concept
Conformal prediction — Vovk, Gammerman & Shafer; Adaptive Conformal Inference — Gibbs & Candès
Brier score — Glenn W. Brier
Wilson score interval — Edwin B. Wilson
Efficiency Ratio — Perry Kaufman · ADX / DMI — J. Welles Wilder
Hawkes self-exciting process — Alan G. Hawkes
Ornstein-Uhlenbeck / AR(1) half-life — Ornstein & Uhlenbeck
Effective-sample decorrelation — Leslie Kish

The pipeline assembly, the regime-conditional calibration and the conviction/veto layer are the author's original implementation.

Limitations (honest)

A well-calibrated probability is not an edge after costs. The forward stats are in-sample, close-to-close at a fixed horizon, with no costs, slippage or stops — a study aid, not a backtest. The model is small (six features, online weights); it warms up slowly and will stand aside often. Past behaviour does not assure future behaviour.

Disclaimer

Educational / informational study for chart analysis only. NOT financial advice, NOT a strategy, NOT a recommendation. It places no orders and guarantees no outcome. Markets carry risk; do your own research and manage your own risk. Paper-trade before risking real money.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ══════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                   MPL-2.0
//  STREAMING-ML PROBABILITY — Triple-Barrier, Conformal-PID & Recalibrated    v2.0
//  shorttitle: ML Probability                                       Pine Script v6
// ──────────────────────────────────────────────────────────────────────────────
//  WHAT THIS IS
//    A self-training probability model that estimates P(up-barrier resolves before
//    down-barrier) and — crucially — REPORTS ITS OWN CALIBRATION. The differentiator
//    is not the classifier; it is the labelling and the honesty layer wrapped around
//    it. The pane shows a probability, an honest uncertainty band, a plain-language
//    verdict, and a reliability diagram that tells you whether to believe any of it.
//
//  WHY THESE COMPONENTS BELONG IN ONE SCRIPT  (mashup rationale)
//    These are not separate indicators stacked together — they are the stages of one
//    honest prediction pipeline, each fixing a failure mode of a naive ML overlay:
//      * TRIPLE-BARRIER LABELS define WHAT is predicted as a real, path-dependent
//        outcome (which barrier is hit first) instead of an arbitrary "next bar up?",
//        and resolve forward in time so training only ever sees CONFIRMED results.
//      * Z-SCORED FEATURES keep every input bounded so no single bar can blow up the
//        online weights.
//      * LOGISTIC SGD + LORENTZIAN k-NN are fused in LOG-ODDS with a Kish
//        decorrelation shrink — a linear model for the trend, a fat-tail-tolerant
//        neighbour vote for the non-linear structure, combined without double-counting
//        the shared features.
//      * REGIME (efficiency + ADX + Hawkes) gives each market state its OWN
//        calibration and shrinks the probability toward 0.5 where a regime is barely
//        seen — the model defers to a coin flip where it has not learned.
//      * ADAPTIVE CONFORMAL INFERENCE turns the point estimate into a coverage-
//        controlled band that holds under drift, so the uncertainty is honest.
//      * CONVICTION + HARD VETOES (regime, MTF, participation/CVD, calibration) stop
//        the model acting on a number it cannot back up.
//      * THE CALIBRATION HARNESS (reliability table, Brier score, forward edge vs an
//        unconditional base rate) is the whole point: a probability is only useful if
//        70% means 70%. A model that cannot show this is just a number generator.
//    Labels say what to learn, features feed it, the fused classifier predicts,
//    regime + conformal say how much to trust it, the vetoes gate it, and calibration
//    proves whether any of it held — remove a stage and the honesty breaks.
//
//  PIPELINE
//    1. LABELS — TRIPLE BARRIER: upper (+bATR·ATR), lower (−bATR·ATR), vertical
//       (maxHold bars). Label = +1 if up hit first, 0 if down first; timeouts not
//       trained. No look-ahead.
//    2. FEATURES — six z-scored, bounded inputs (return, momentum, efficiency, RSI,
//       MA-distance, volume).
//    3. CLASSIFIER — online logistic regression (SGD, L2) fused in log-odds with a
//       Lorentzian k-NN over a memory of resolved samples.
//    4. CONFORMAL — ACI (1−α) nonconformity quantile → a calibrated ± band.
//    5. CALIBRATION — reliability table, Brier score, regime/recency/Wilson edge.
//
//  USE ON ANY MARKET
//    The Data Source inputs (Close / High / Low / Volume) drive the features, the
//    triple-barrier labels and the calibration, so the model runs on any series and
//    any market. All thresholds are ATR-relative; defaults are set for NIFTY
//    index-futures intraday — change the source or lengths for other assets.
//
//  HOW TO USE
//    1. Read the VERDICT line first — it says ACT, STAND ASIDE (no calibrated edge),
//       or WAIT, based on the live signal AND the model's own calibration.
//    2. Check the reliability diagram / Brier: if points sit off the diagonal or
//       Brier ≥ 0.25 (worse than a coin flip), the probability is not trustworthy yet.
//    3. A signal fires only when probability clears the band-margin AND conviction
//       clears the floor AND no hard veto trips.
//    4. The conformal band is the honest uncertainty — a wide band means low confidence.
//    5. Everything here is descriptive, probabilistic context — never an instruction.
//
//  EXPORTS (Data Window): consume via input.source():
//    EXP_Pup (recalibrated) · EXP_Praw · EXP_AlphaEff · EXP_PLo · EXP_PHi ·
//    EXP_Signal · EXP_Brier · EXP_Edge · EXP_Regime · EXP_Alpha · EXP_Conv ·
//    EXP_Veto · EXP_MTF
//
//  NON-REPAINT
//    Training only on resolved (confirmed) triple-barrier outcomes; directional signal
//    on barstate.isconfirmed; MTF requested with lookahead_off; no dynamic-length ta().
//    The live probability updates each bar (a current estimate from fixed historical
//    training).
//
//  CREDITS (concepts this engine builds on)
//    • Triple-barrier labelling & meta-labelling — Marcos López de Prado.
//    • Logistic regression / stochastic gradient descent — classical statistics.
//    • Lorentzian (non-Euclidean) distance for k-NN — relativistic-distance concept.
//    • Conformal prediction — Vovk, Gammerman & Shafer; Adaptive Conformal Inference
//      — Gibbs & Candès.
//    • Brier score — Glenn W. Brier.
//    • Wilson score interval — Edwin B. Wilson.
//    • Efficiency Ratio — Perry Kaufman.   • ADX / DMI — J. Welles Wilder.
//    • Hawkes self-exciting process — Alan G. Hawkes.
//    • Ornstein-Uhlenbeck / AR(1) half-life — Ornstein & Uhlenbeck.
//    • Effective-sample decorrelation — Leslie Kish.
//    The pipeline assembly, the regime-conditional calibration and the conviction/veto
//    layer are the author's original work.
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a strategy, NOT a
//    recommendation. This is a small online model on a few hand-built features; a
//    well-calibrated probability is still not an edge after costs. Forward stats are
//    in-sample, close-to-close at a fixed horizon, no costs/slippage/stops. Past
//    behaviour does not assure future behaviour. Paper-trade before risking real
//    money; you alone are responsible for your decisions.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Streaming-ML Probability — Triple-Barrier, Conformal & Calibrated", "ML Probability",
     overlay          = false,
     max_labels_count = 300,
     max_lines_count  = 100,
     max_bars_back    = 1000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 1 — INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gS = "1 · Data Source (any market)"
g1 = "2 · Labels (Triple Barrier)"
g2 = "3 · Features"
g3 = "4 · Model & Fusion"
gR = "5 · Regime"
gV = "6 · Conviction · Veto · MTF"
g4 = "7 · Conformal (PID), Recalibration & Signal"
g5 = "8 · Display"
gT = "9 · Theme"
gE = "10 · Exports"

srcClose = input.source(close,  "Close source",  group = gS, tooltip = "Drives the features, the triple-barrier labels and the calibration. Swap to an alternate series (e.g. Heikin-Ashi) to run the model on any market or candle type. Defaults to the chart's Close.")
srcHigh  = input.source(high,   "High source",   group = gS, tooltip = "Used for upper-barrier touches and favourable/adverse excursion.")
srcLow   = input.source(low,    "Low source",    group = gS)
srcVol   = input.source(volume, "Volume source", group = gS, tooltip = "Used for the volume feature and the participation (CVD) veto. On assets with no volume the feature simply contributes nothing.")

bATR     = input.float(1.2, "Barrier Width (×ATR)", minval = 0.3, maxval = 5.0, step = 0.1, group = g1, tooltip = "Upper/lower profit-taking & stop barriers, in ATR. Symmetric.")
maxHold  = input.int(15, "Vertical Barrier (bars)", minval = 3, maxval = 80, group = g1, tooltip = "Timeout horizon. If neither barrier is hit by here, the sample is a timeout and is not used for training.")
atrLen   = input.int(14, "ATR Length", minval = 5, maxval = 50, group = g1)
useHLgate= input.bool(true, "Half-Life Sample Gate", group = g1, tooltip = "Skip opening a triple-barrier sample when the OU mean-reversion half-life is longer than the vertical barrier — reversion too slow to resolve inside the horizon would just time out and add noise to training.")
hlLen    = input.int(60, "Half-Life Window", minval = 10, maxval = 200, group = g1)

zLen     = input.int(100, "Z-Score Length", minval = 20, maxval = 400, group = g2, tooltip = "Rolling window used to standardize unbounded features.")
momLen   = input.int(10, "Momentum Length", minval = 2, maxval = 60, group = g2)
erLen    = input.int(20, "Efficiency Length", minval = 5, maxval = 60, group = g2)
rsiLen   = input.int(14, "RSI Length", minval = 2, maxval = 50, group = g2)
emaLen   = input.int(50, "MA-Distance Length", minval = 5, maxval = 200, group = g2)

lr       = input.float(0.03, "Logistic Learn Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = g3)
l2       = input.float(0.0005, "L2 Regularization", minval = 0.0, maxval = 0.05, step = 0.0005, group = g3)
useKnn   = input.bool(true, "Blend Lorentzian k-NN", group = g3)
kNN      = input.int(8, "k (neighbors)", minval = 1, maxval = 30, group = g3)
memSize  = input.int(150, "k-NN Memory", minval = 20, maxval = 400, group = g3, tooltip = "How many recent resolved samples the k-NN remembers.")
kishK    = input.float(0.6, "Fusion Decorrelation (Kish)", minval = 0.2, maxval = 1.0, step = 0.05, group = g3, tooltip = "Bayesian log-odds fusion of the logistic and k-NN votes. Because both read the same features they are correlated, so each log-odds contribution is shrunk by this Kish factor (1 = treat as independent, lower = more shared-information discount).")
warmN    = input.int(40, "Warm-Up Samples", minval = 10, maxval = 300, group = g3, tooltip = "Suppress signals until this many labels have resolved.")

// regime engine (efficiency ratio + ADX + Hawkes vol-cluster) — separate calibration per state
adxLenR  = input.int(14, "ADX / DMI Length", minval = 4, maxval = 50, group = gR)
adxTrd   = input.float(20.0, "ADX Trend Threshold", minval = 10, maxval = 40, group = gR)
erTrd    = input.float(0.35, "ER Trend Threshold", minval = 0.1, maxval = 0.9, step = 0.01, group = gR)
hawkK    = input.float(0.20, "Hawkes Decay k", minval = 0.02, maxval = 0.9, step = 0.01, group = gR)
hawkThr  = input.float(1.5, "Vol-Cluster z (Volatile)", minval = 0.5, maxval = 4.0, step = 0.1, group = gR)
regMaLn  = input.int(50, "Regime Trend MA", minval = 10, maxval = 200, group = gR)
normLen  = input.int(100, "Normalization Window", minval = 20, maxval = 500, group = gR)
useShrink= input.bool(true, "Regime Warm-Up Shrink", group = gR, tooltip = "Pull the probability toward 0.5 in a regime until that regime has resolved enough samples — the model defers to a coin flip where it has not yet learned. Stops it being confident in a regime it has barely seen.")

// conviction + hard vetoes — gate the probability signal so it only acts under confluence
minConv  = input.int(45, "Min Conviction to Act (0–100)", minval = 0, maxval = 100, group = gV, tooltip = "Conviction blends model confidence, regime fit, MTF agreement, calibration quality and participation. Below this the signal is vetoed.")
useVetoReg = input.bool(true, "Veto · Regime mismatch", group = gV, tooltip = "Block longs in a down-trend / shorts in an up-trend, and block all signals in the Volatile regime.")
useVetoMtf = input.bool(true, "Veto · MTF disagreement", group = gV)
useVetoConv= input.bool(true, "Veto · Low conviction", group = gV)
useVetoPart= input.bool(true, "Veto · Low participation (CVD)", group = gV, tooltip = "Block a signal when cumulative volume delta is pushing against the signal direction — price moving without participation.")
useMtf   = input.bool(true, "MTF Confluence", group = gV)
mtfTf1   = input.timeframe("15", "MTF · TF 1", group = gV, tooltip = "Keep MTF timeframes ≥ the chart timeframe. Bias on each = price vs its EMA.")
mtfTf2   = input.timeframe("60", "MTF · TF 2", group = gV)
mtfTf3   = input.timeframe("240", "MTF · TF 3", group = gV)
mtfMaLen = input.int(20, "MTF Bias MA", minval = 5, maxval = 100, group = gV)
minAlign = input.int(2, "MTF Min Agreement", minval = 1, maxval = 3, group = gV)
cvdLook  = input.int(5, "Participation Lookback", minval = 1, maxval = 30, group = gV)

alpha    = input.float(0.20, "Conformal target α (1−coverage)", minval = 0.02, maxval = 0.5, step = 0.01, group = g4, tooltip = "Target miss rate. 0.20 → ~80% interval. ACI adapts the working α online toward this target so realised coverage holds even under drift.")
aciGamma = input.float(0.02, "ACI Step (γ)", minval = 0.0, maxval = 0.2, step = 0.005, group = g4, tooltip = "Adaptive Conformal Inference learning rate (Gibbs-Candès). The working α rises after a miss and falls after a hit, keeping long-run coverage at the target. 0 = static conformal.")
conLen   = input.int(120, "Conformal Memory", minval = 20, maxval = 400, group = g4)
recencyHL= input.int(60, "Calibration Recency Half-Life", minval = 5, maxval = 500, group = g4, tooltip = "Recency-weighted edge tables decay older resolutions toward this half-life (in samples), so a regime that has drifted is reflected faster than the all-time rate.")
sigMarg  = input.float(0.10, "Signal Margin (from 0.5)", minval = 0.0, maxval = 0.4, step = 0.01, group = g4, tooltip = "Call UP when p−lo band > 0.5+margin; DOWN when p+hi band < 0.5−margin.")
horizon  = input.int(12, "Edge Eval Horizon", minval = 3, maxval = 60, group = g4)
moveATR  = input.float(1.0, "Edge Win Threshold (×ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = g4)
minGap   = input.int(4, "Min Bars Between Signals", minval = 1, maxval = 40, group = g4)
pidKp    = input.float(0.10, "Conformal PID · proportional gain", minval = 0.0, maxval = 1.0, step = 0.01, group = g4, tooltip = "Conformal PID Control (Angelopoulos-Candès-Tibshirani 2023) upgrades ACI: ACI is only the INTEGRAL term; this proportional gain reacts to the RECENT coverage error, tightening long-run coverage under drift. 0 = plain ACI.")
pidBeta  = input.float(0.05, "PID · recent-error smoothing", minval = 0.01, maxval = 0.5, step = 0.01, group = g4, tooltip = "EWMA rate for the recent miss-rate that the proportional term reacts to.")
useRecal = input.bool(true, "Isotonic probability recalibration", group = g4, tooltip = "Fit a monotone (pool-adjacent-violators) map from the reliability bins and pass the probability through it, so the reported P is recalibrated to the frequencies actually observed on THIS instrument — 'make 70% mean 70%'. Fitted on the raw model's bins (no feedback loop).")
recalMinB= input.int(15, "Min samples per bin to recalibrate", minval = 3, maxval = 200, group = g4, tooltip = "A reliability bucket must hold at least this many resolved samples before it is used in the recalibration map.")
edgeTests= input.int(4, "Edge significance · corrected for N tests", minval = 1, maxval = 10, group = g4, tooltip = "Raises the z bar for the directional-edge ★ by the number of classes tested (Bonferroni-style), so a lucky edge is not starred as real.")

viewMode = input.string("Clean", "Pane View", ["Clean", "Full"], group = g5, tooltip = "CLEAN (default): a smoothed probability line, the gates, signal markers, and a signal tint — only the decision elements. FULL: adds the raw per-bar probability and the conformal band for analysis.")
smoothLen= input.int(5, "Probability Smoothing", minval = 1, maxval = 30, group = g5, tooltip = "Clean view smooths the probability over this many bars so the line is readable. The raw probability (Full view) and the model itself are unchanged.")
showProb = input.bool(true, "Show Probability + Band", group = g5)
showSig  = input.bool(true, "Show Signal Markers", group = g5)
showVerdict = input.bool(true, "Plain-Language Verdict", group = g5, tooltip = "A one-line read at the top of the dashboard: whether to act, stand aside (no calibrated edge), or wait — based on the live signal and the model's own calibration.")
showRelDiag = input.bool(true, "Reliability Diagram", group = g5, tooltip = "A small predicted-vs-realized scatter drawn at the right edge. Points on the diagonal = well calibrated; below it = over-confident, above = under-confident.")
showDash = input.bool(true, "Show Dashboard", group = g5)
dashMode = input.string("Compact", "Dashboard Mode", ["Compact", "Pro"], group = g5)
dashPos  = input.string("Top Left", "Dashboard Position", ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5, tooltip = "Default Top Left keeps the panel clear of the reliability diagram and conviction badge, which are drawn in the empty space to the right of the last bar.")

themeMode = input.string("Auto", "Theme", ["Auto", "Dark", "Light"], group = gT)
upColI    = input.color(#21D7AC, "Up", group = gT)
dnColI    = input.color(#F2547B, "Down", group = gT)
neuColI   = input.color(#58A6FF, "Accent", group = gT)

showEXP  = input.bool(true, "Emit EXP_* exports", group = gE)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 2 — THEME, HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_bg     = chart.bg_color
_bgLum  = 0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg)
isLight = themeMode == "Light" or (themeMode == "Auto" and _bgLum > 140)

darken(color c, float f) => color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f, color.t(c))
cBull = isLight ? darken(upColI, 0.80) : upColI
cBear = isLight ? darken(dnColI, 0.80) : dnColI
cAcc  = isLight ? darken(neuColI, 0.80) : neuColI
cNeu  = isLight ? #57606A : #8B949E
cTxt  = isLight ? #0A0A0A : #E6EDF3
cDim  = isLight ? #9AA4B2 : #484F58
cPanel= isLight ? #F2F4F8 : #0D1117
cHead = isLight ? #E2E6ED : #161B22
cGrid = isLight ? #C4CAD4 : #21262D

f_dashPos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_sig(float z) => 1.0 / (1.0 + math.exp(-math.max(-30.0, math.min(30.0, z))))
f_logit(float p) =>
    float pp = math.max(1e-6, math.min(1.0 - 1e-6, p))
    math.log(pp / (1.0 - pp))
f_wilsonHalf(int wn, int n) =>
    float r = na
    if n > 0
        float zc = 1.96
        float pp = wn / float(n)
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r

// isotonic (pool-adjacent-violators) recalibration of a probability from the reliability bins:
// fit a monotone non-decreasing map predicted→realized and pass p through it. Returns p unchanged
// until at least two bins hold ≥ minb resolved samples. Verified in Python (monotone; lowers Brier).
f_isoRecal(float p, int[] bn, float[] bs, simple int nbin, simple int minb) =>
    array<float> gv = array.new<float>()
    array<float> gw = array.new<float>()
    array<float> gp = array.new<float>()
    for b = 0 to nbin - 1
        int n = bn.get(b)
        if n >= minb
            gv.push(bs.get(b) / n)
            gw.push(float(n))
            gp.push((b + 0.5) / nbin)
    float rp = p
    if gv.size() >= 2
        bool changed = true
        while changed and gv.size() >= 2
            changed := false
            for i = 0 to gv.size() - 2
                if gv.get(i) > gv.get(i + 1)
                    float w1 = gw.get(i)
                    float w2 = gw.get(i + 1)
                    gv.set(i, (gv.get(i) * w1 + gv.get(i + 1) * w2) / (w1 + w2))
                    gw.set(i, w1 + w2)
                    gv.remove(i + 1)
                    gw.remove(i + 1)
                    gp.remove(i + 1)
                    changed := true
                    break
        int M = gv.size()
        if p <= gp.get(0)
            rp := gv.get(0)
        else if p >= gp.get(M - 1)
            rp := gv.get(M - 1)
        else
            for i = 0 to M - 2
                if p >= gp.get(i) and p <= gp.get(i + 1)
                    float t = (p - gp.get(i)) / math.max(gp.get(i + 1) - gp.get(i), 1e-9)
                    rp := gv.get(i) + t * (gv.get(i + 1) - gv.get(i))
                    break
    rp

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 3 — FEATURES  (six bounded / z-scored inputs)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int NF = 6
float atr = ta.atr(atrLen)

f_er(float s, int len) =>
    float net  = math.abs(s - s[len])
    float path = 0.0
    for i = 0 to len - 1
        path += math.abs(s[i] - s[i + 1])
    path > 0 ? net / path : 0.0

float ema = ta.ema(srcClose, emaLen)

f_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))

// every feature is finite (nz) and bounded so no single sample can blow up the
// SGD, and a warm-up na can never poison a weight. The rolling z-scores use the
// incremental built-ins (ta.sma/ta.stdev, population) instead of a per-bar loop.
float d0  = srcClose - srcClose[1]
float sd0 = ta.stdev(d0, zLen)
float x0  = f_clamp(nz(sd0 > 0 ? (d0 - ta.sma(d0, zLen)) / sd0 : 0.0), -5.0, 5.0)        // 1-bar return
float d1  = srcClose - srcClose[momLen]
float sd1 = ta.stdev(d1, zLen)
float x1  = f_clamp(nz(sd1 > 0 ? (d1 - ta.sma(d1, zLen)) / sd1 : 0.0), -5.0, 5.0)         // momentum
float x2  = f_clamp(nz(f_er(srcClose, erLen) * 2.0 - 1.0), -1.0, 1.0)                      // efficiency, centered
float x3  = nz(ta.rsi(srcClose, rsiLen) / 100.0 - 0.5)                                     // rsi centered
float x4  = atr > 0 ? f_clamp((srcClose - ema) / atr, -4.0, 4.0) : 0.0                     // MA distance
float sd5 = ta.stdev(srcVol, zLen)
float x5  = f_clamp(nz(sd5 > 0 ? (srcVol - ta.sma(srcVol, zLen)) / sd5 : 0.0), -5.0, 5.0)  // volume z

// don't open training samples until every feature window is full (else early na
// or half-formed z-scores corrupt the model)
int  needBars  = math.max(zLen, math.max(emaLen, math.max(momLen, math.max(erLen, math.max(rsiLen, atrLen)))))
bool featReady = bar_index > needBars

f_feat() =>
    array<float> a = array.new<float>()
    a.push(x0)
    a.push(x1)
    a.push(x2)
    a.push(x3)
    a.push(x4)
    a.push(x5)
    a

// ── REGIME (efficiency + ADX + Hawkes vol-cluster) — separate calibration per state ──
int NREG = 4
[dpR, dmR, adxR] = ta.dmi(adxLenR, adxLenR)
float erReg   = f_er(srcClose, erLen)
float logRetR = math.abs(nz(ta.change(math.log(srcClose))))
var float hawk = 0.0
hawk := hawk * math.exp(-hawkK) + logRetR
float hMeanR = ta.sma(hawk, normLen)
float hSdR   = ta.stdev(hawk, normLen)
float hawkZ  = hSdR > 0 ? (hawk - hMeanR) / hSdR : 0.0
bool  volClu = hawkZ > hawkThr
float trendMaR = ta.ema(srcClose, regMaLn)
bool  trendingR = nz(adxR) > adxTrd and erReg > erTrd
bool  bullR = srcClose > trendMaR
int   regID = volClu and not trendingR ? 4 : trendingR ? (bullR ? 1 : 2) : 3
f_regName(int id)  => id == 1 ? "TREND ↑" : id == 2 ? "TREND ↓" : id == 3 ? "RANGE" : "VOLATILE"
f_regShort(int id) => id == 1 ? "TU" : id == 2 ? "TD" : id == 3 ? "RG" : id == 4 ? "VO" : "—"
f_regCol(int id) => id == 1 ? cBull : id == 2 ? cBear : id == 3 ? cNeu : cAcc

// ── MTF CONFLUENCE · PARTICIPATION · MEAN-REVERSION HALF-LIFE ──
f_mtfBias() => srcClose > ta.ema(srcClose, mtfMaLen) ? 1 : srcClose < ta.ema(srcClose, mtfMaLen) ? -1 : 0
int NTF = 3
int mtf1 = useMtf ? int(nz(request.security(syminfo.tickerid, mtfTf1, f_mtfBias(), lookahead = barmerge.lookahead_off))) : 0
int mtf2 = useMtf ? int(nz(request.security(syminfo.tickerid, mtfTf2, f_mtfBias(), lookahead = barmerge.lookahead_off))) : 0
int mtf3 = useMtf ? int(nz(request.security(syminfo.tickerid, mtfTf3, f_mtfBias(), lookahead = barmerge.lookahead_off))) : 0
int mtfBull = (mtf1 > 0 ? 1 : 0) + (mtf2 > 0 ? 1 : 0) + (mtf3 > 0 ? 1 : 0)
int mtfBear = (mtf1 < 0 ? 1 : 0) + (mtf2 < 0 ? 1 : 0) + (mtf3 < 0 ? 1 : 0)

// participation — chart-bar cumulative volume delta, slope sign over the lookback
float barDelta = (srcClose >= open ? 1.0 : -1.0) * nz(srcVol)
float cvd      = ta.cum(barDelta)
int   cvdSign  = int(math.sign(cvd - cvd[cvdLook]))

// OU mean-reversion half-life on (close − EMA) via AR(1) — ported from BB-ARC
float spreadH  = srcClose - ema
float spreadH1 = nz(spreadH[1], spreadH)
float mSH  = ta.sma(spreadH,  hlLen)
float mSH1 = ta.sma(spreadH1, hlLen)
float covH = ta.sma(spreadH * spreadH1, hlLen) - mSH * mSH1
float varH = ta.sma(spreadH1 * spreadH1, hlLen) - mSH1 * mSH1
float betaAR   = varH > 0 ? covH / varH : na
float halfLife = (not na(betaAR) and betaAR > 0.0 and betaAR < 1.0) ? -math.log(2.0) / math.log(betaAR) : na

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 4 — MODEL STATE  (logistic weights, k-NN memory, conformal, reliability)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] w = array.new<float>(NF + 1, 0.0)             // [bias, w0..w5]

var float[] memX = array.new<float>()                    // flattened NF per sample
var float[] memY = array.new<float>()

var float[] conf = array.new<float>()                    // nonconformity residuals

int NBIN = 10
var int[]   binN = array.new<int>(NBIN, 0)
var float[] binS = array.new<float>(NBIN, 0.0)           // sum of y per bucket

var float brierSum = 0.0
var int   brierN   = 0
var int   resolvedN = 0

// per-regime resolved-sample counts (warm-up shrink) + ACI working alpha
var int[] regResolved = array.new<int>(NREG + 1, 0)
var float aciAlpha = alpha
var float missEwma = alpha                               // recent coverage-error EWMA (Conformal PID proportional term)

// logistic prediction from a feature array
f_plogit(array<float> x) =>
    float z = w.get(0)
    for f = 0 to NF - 1
        z += w.get(f + 1) * x.get(f)
    f_sig(z)

// Lorentzian k-NN probability from memory
f_pknn(array<float> x) =>
    float r = na
    int m = memY.size()
    if m >= kNN
        array<float> dist = array.new<float>()
        for i = 0 to m - 1
            float d = 0.0
            for f = 0 to NF - 1
                d += math.log(1.0 + math.abs(x.get(f) - memX.get(i * NF + f)))
            dist.push(d)
        float acc = 0.0
        int cnt = 0
        array<bool> used = array.new<bool>(m, false)
        for n = 0 to kNN - 1
            float best = 1e18
            int bi = -1
            for i = 0 to m - 1
                if not used.get(i) and dist.get(i) < best
                    best := dist.get(i)
                    bi := i
            if bi >= 0
                used.set(bi, true)
                acc += memY.get(bi)
                cnt += 1
        r := cnt > 0 ? acc / cnt : na
    r

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5 — LIVE PREDICTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
array<float> xNow = f_feat()
float pLog = f_plogit(xNow)
float pKnn = useKnn ? f_pknn(xNow) : na

// Bayesian log-odds FUSION (Kish-decorrelated) — replaces the linear blend.
// Both votes read the same features, so each log-odds contribution is shrunk.
float fusedLogit = f_logit(pLog)
if useKnn and not na(pKnn)
    fusedLogit := kishK * (f_logit(pLog) + f_logit(pKnn))
float pRaw = f_sig(fusedLogit)

// regime warm-up SHRINK — defer toward 0.5 where the current regime has little data
float regShrink = 1.0
if useShrink
    regShrink := math.min(1.0, regResolved.get(regID) / float(warmN))
float pUp = 0.5 + (pRaw - 0.5) * regShrink

// conformal half-width = (1−α) quantile of recent |y − p|. CONFORMAL PID: the working α is the ACI
// integrator PLUS a proportional term on the recent coverage error (Angelopoulos-Candès-Tibshirani 2023).
float alphaEff = math.max(0.01, math.min(0.50, aciAlpha + pidKp * (alpha - missEwma)))
float cHW = conf.size() >= 10 ? array.percentile_linear_interpolation(conf, (1.0 - alphaEff) * 100.0) : na
float pLo = na(cHW) ? na : math.max(0.0, pUp - cHW)
float pHi = na(cHW) ? na : math.min(1.0, pUp + cHW)
// ISOTONIC (PAV) RECALIBRATION — pass the raw probability through the monotone calibration map so the
// reported P matches the frequencies actually observed here. Fitted on the raw bins → no feedback loop.
float pCal = useRecal ? f_isoRecal(pUp, binN, binS, NBIN, recalMinB) : pUp

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 6 — TRIPLE-BARRIER SAMPLES  (open, resolve, train)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type Sample
    float entry
    float atr0
    int   bidx
    float pOpen
    array<float> x
    int   reg
    float cHW0
    int   conc

var array<Sample> samples = array.new<Sample>()

// open a fresh sample every bar once features are valid (confirmed); skip when
// mean-reversion is too slow to resolve inside the vertical barrier (half-life gate)
bool hlOK = (not useHLgate) or na(halfLife) or halfLife <= maxHold
if barstate.isconfirmed and featReady and hlOK
    samples.push(Sample.new(srcClose, atr, bar_index, pUp, f_feat(), regID, cHW, samples.size()))

// resolve open samples against the triple barrier
if barstate.isconfirmed and samples.size() > 0
    for i = samples.size() - 1 to 0
        Sample s = samples.get(i)
        float up = s.entry + bATR * s.atr0
        float dn = s.entry - bATR * s.atr0
        int   age = bar_index - s.bidx
        int   y = -1                                   // -1 = unresolved
        if srcHigh >= up and srcLow <= dn
            // both touched same bar — resolve by close side (conservative)
            y := srcClose >= s.entry ? 1 : 0
        else if srcHigh >= up
            y := 1
        else if srcLow <= dn
            y := 0
        else if age >= maxHold
            y := 2                                      // timeout — skip training
        if y >= 0
            if y == 0 or y == 1
                float yv = float(y)
                // logistic SGD update on the sample's OWN features & open prediction is
                // recomputed for a fresh gradient
                float pTrain = f_plogit(s.x)
                float errg = pTrain - yv
                float uw = 1.0 / (1.0 + s.conc)          // sample-uniqueness weight — overlapping labels aren't independent (López de Prado)
                w.set(0, f_clamp(w.get(0) - lr * uw * errg, -12.0, 12.0))
                for f = 0 to NF - 1
                    w.set(f + 1, f_clamp(w.get(f + 1) - lr * uw * (errg * s.x.get(f) + l2 * w.get(f + 1)), -12.0, 12.0))
                // k-NN memory
                for f = 0 to NF - 1
                    memX.push(s.x.get(f))
                memY.push(yv)
                while memY.size() > memSize
                    memY.shift()
                    for f = 0 to NF - 1
                        memX.shift()
                // conformal residual (uses prediction recorded at open)
                conf.push(math.abs(yv - s.pOpen))
                while conf.size() > conLen
                    conf.shift()
                // reliability bin (by pOpen) + Brier
                int b = math.max(0, math.min(NBIN - 1, int(s.pOpen * NBIN)))
                binN.set(b, binN.get(b) + 1)
                binS.set(b, binS.get(b) + yv)
                brierSum += (s.pOpen - yv) * (s.pOpen - yv)
                brierN += 1
                resolvedN += 1
                if s.reg >= 1 and s.reg <= NREG
                    regResolved.set(s.reg, regResolved.get(s.reg) + 1)
                // ACI — adapt the working α toward the target coverage (Gibbs-Candès)
                float miss = (not na(s.cHW0) and math.abs(yv - s.pOpen) > s.cHW0) ? 1.0 : 0.0
                aciAlpha := math.max(0.01, math.min(0.50, aciAlpha + aciGamma * (alpha - miss)))
                missEwma := missEwma + pidBeta * (miss - missEwma)     // Conformal PID proportional feedback
            samples.remove(i)

float brier = brierN > 0 ? brierSum / brierN : na
bool  warm  = resolvedN >= warmN

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 7 — DIRECTIONAL SIGNAL + EDGE CALIBRATION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type Pend
    int   dir
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    bool  done
    int   reg

var array<Pend> pend = array.new<Pend>()
var int upN = 0
var int upW = 0
var int dnN = 0
var int dnW = 0
// per-regime directional edge (idx by regID): up = LONG-signal wins, dn = SHORT-signal wins
var int[] regUpN = array.new<int>(NREG + 1, 0)
var int[] regUpW = array.new<int>(NREG + 1, 0)
var int[] regDnN = array.new<int>(NREG + 1, 0)
var int[] regDnW = array.new<int>(NREG + 1, 0)
// recency-weighted directional edge (decayed)
var float upNd = 0.0
var float upWd = 0.0
var float dnNd = 0.0
var float dnWd = 0.0
float recDecay = math.pow(0.5, 1.0 / recencyHL)
var int baseN = 0
var int baseWup = 0
var int baseWdn = 0
var int lastSigBar = -100000

f_z(int wn, int n, float p0) =>
    float r = na
    if n > 0 and not na(p0) and p0 > 0.0 and p0 < 1.0
        float ph = wn / float(n)
        float se = math.sqrt(p0 * (1.0 - p0) / n)
        r := se > 0 ? (ph - p0) / se : na
    r
// directional base rate: LONG (dir>0) → unconditional up-move base · SHORT → down-move base
f_baseP(int dir) =>
    float r = na
    if baseN > 0
        r := dir > 0 ? baseWup / float(baseN) : baseWdn / float(baseN)
    r

// candidate direction — the probability band clears a gate
bool longOK  = warm and not na(pLo) and pLo > 0.5 + sigMarg and pCal >= 0.5
bool shortOK = warm and not na(pHi) and pHi < 0.5 - sigMarg and pCal <= 0.5
int  rawDir  = longOK ? 1 : shortOK ? -1 : 0
// direction to score: the candidate, else the side the probability leans
int  scoreDir = rawDir != 0 ? rawDir : (pUp >= 0.5 ? 1 : -1)

// ── CONVICTION (0–100) — model confidence · regime fit · MTF · calibration · participation ──
float sConf = math.min(1.0, math.abs(pUp - 0.5) / 0.5)
float sReg  = scoreDir > 0 ? (regID == 1 ? 1.0 : regID == 3 ? 0.5 : 0.2) : (regID == 2 ? 1.0 : regID == 3 ? 0.5 : 0.2)
float sMtf  = useMtf ? (scoreDir > 0 ? mtfBull : mtfBear) / float(NTF) : 0.5
float sCal  = na(brier) ? 0.0 : math.max(0.0, math.min(1.0, (0.25 - brier) / 0.15))
float sPart = cvdSign == scoreDir ? 1.0 : (cvdSign == 0 ? 0.6 : 0.4)
int   conv  = int(math.round((30.0 * sConf + 20.0 * sReg + 20.0 * sMtf + 20.0 * sCal + 10.0 * sPart)))
string tier = conv >= 75 ? "S" : conv >= 60 ? "A" : conv >= 45 ? "B" : "—"

// ── HARD VETOES — evaluated for the candidate direction ──
bool vReg  = useVetoReg  and (regID == 4 or (scoreDir > 0 and regID == 2) or (scoreDir < 0 and regID == 1))
bool vMtf  = useVetoMtf  and useMtf and ((scoreDir > 0 and mtfBull < minAlign) or (scoreDir < 0 and mtfBear < minAlign))
bool vConv = useVetoConv and conv < minConv
bool vPart = useVetoPart and cvdSign != 0 and cvdSign != scoreDir
bool vetoed = vReg or vMtf or vConv or vPart
string vetoTxt = not vetoed ? "none" : vReg ? "regime" : vMtf ? "MTF" : vConv ? "conviction" : "participation"

// ── FINAL actionable signal — the gated direction ──
int sigDir = 0
if barstate.isconfirmed and rawDir != 0 and not vetoed and (bar_index - lastSigBar) >= minGap
    sigDir := rawDir
    lastSigBar := bar_index
    if not na(atr) and atr > 0.0
        pend.push(Pend.new(sigDir, srcClose, atr, bar_index, 0.0, 0.0, false, regID))

if barstate.isconfirmed and pend.size() > 0
    for i = pend.size() - 1 to 0
        Pend p = pend.get(i)
        if not p.done
            float favor   = p.dir > 0 ? (srcHigh - p.entry) : (p.entry - srcLow)
            float adverse = p.dir > 0 ? (p.entry - srcLow)  : (srcHigh - p.entry)
            p.mfe := p.atr0 > 0.0 ? math.max(p.mfe, favor   / p.atr0) : p.mfe
            p.mae := p.atr0 > 0.0 ? math.max(p.mae, adverse / p.atr0) : p.mae
            if bar_index - p.bidx >= horizon
                p.done := true
                float fwd = p.dir > 0 ? (srcClose - p.entry) : (p.entry - srcClose)
                bool  win = fwd >= moveATR * p.atr0
                int   rg  = p.reg >= 1 and p.reg <= NREG ? p.reg : 3
                if p.dir > 0
                    upN += 1
                    upW += win ? 1 : 0
                    upNd := upNd * recDecay + 1.0
                    upWd := upWd * recDecay + (win ? 1.0 : 0.0)
                    regUpN.set(rg, regUpN.get(rg) + 1)
                    regUpW.set(rg, regUpW.get(rg) + (win ? 1 : 0))
                else
                    dnN += 1
                    dnW += win ? 1 : 0
                    dnNd := dnNd * recDecay + 1.0
                    dnWd := dnWd * recDecay + (win ? 1.0 : 0.0)
                    regDnN.set(rg, regDnN.get(rg) + 1)
                    regDnW.set(rg, regDnW.get(rg) + (win ? 1 : 0))
                pend.remove(i)

if barstate.isconfirmed and not na(atr) and atr > 0.0
    // unconditional close-to-close directional base at the same horizon
    var array<float> be = array.new<float>()
    var array<float> ba = array.new<float>()
    var array<int>   bb = array.new<int>()
    be.push(srcClose)
    ba.push(atr)
    bb.push(bar_index)
    if bb.size() > 0
        for i = bb.size() - 1 to 0
            if bar_index - bb.get(i) >= horizon
                if (srcClose - be.get(i)) >= moveATR * ba.get(i)
                    baseWup += 1
                if (be.get(i) - srcClose) >= moveATR * ba.get(i)
                    baseWdn += 1
                baseN += 1
                be.remove(i)
                ba.remove(i)
                bb.remove(i)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8 — PLOTS (probability pane)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool fullView = viewMode == "Full"
// model is only worth reading when it beats a coin flip (Brier < 0.25)
bool calibrated = not na(brier) and brier < 0.25
float pSmooth = ta.ema(pCal, smoothLen)                  // the plotted probability is the recalibrated one
color pc  = pUp     >= 0.5 ? cBull : cBear
color pcS = pSmooth >= 0.5 ? cBull : cBear

// CLEAN: smoothed probability only · FULL: raw probability + conformal band
plot(showProb and not fullView ? pSmooth : na, "P(up) smoothed", color = color.new(pcS, calibrated ? 0 : 55), linewidth = 2)
p_mid = plot(showProb and fullView ? pUp : na, "P(up)", color = color.new(pc, 0), linewidth = 2)
p_hi  = plot(showProb and fullView and not na(pHi) ? pHi : na, "Conf Hi", color = color.new(cNeu, 70), linewidth = 1)
p_lo  = plot(showProb and fullView and not na(pLo) ? pLo : na, "Conf Lo", color = color.new(cNeu, 70), linewidth = 1)
fill(p_hi, p_lo, color = showProb and fullView ? color.new(pc, 90) : na, title = "Conformal Band")

hline(0.5, "Coin Flip", color = color.new(neuColI, 50), linestyle = hline.style_dashed)
hline(0.5 + sigMarg, "Long Gate", color = color.new(upColI, 75), linestyle = hline.style_dotted)
hline(0.5 - sigMarg, "Short Gate", color = color.new(dnColI, 75), linestyle = hline.style_dotted)

plotshape(showSig and sigDir > 0 ? 0.04 : na, "Long", shape.triangleup, location.absolute, color = cBull, size = size.small)
plotshape(showSig and sigDir < 0 ? 0.96 : na, "Short", shape.triangledown, location.absolute, color = cBear, size = size.small)

// background: warm-up grey · signal tint on the firing bar · faint amber when the model is not beating a coin flip
color augBg = not warm ? color.new(cNeu, 92) : sigDir > 0 ? color.new(cBull, 80) : sigDir < 0 ? color.new(cBear, 80) : (warm and not calibrated ? color.new(#E8A13C, 94) : na)
bgcolor(augBg, title = "State Tint")

// ── RELIABILITY DIAGRAM — predicted (x) vs realized (y), drawn at the right edge ──
// points on the dotted diagonal = well calibrated · below = over-confident · above = under-confident
var line relDiag = na
var array<line>  relAx  = array.new<line>()
var array<label> relPts = array.new<label>()
if showRelDiag and barstate.islast
    if not na(relDiag)
        line.delete(relDiag)
    while relAx.size() > 0
        line.delete(relAx.shift())
    while relPts.size() > 0
        label.delete(relPts.shift())
    int x0 = bar_index + 5
    int W  = 16
    relDiag := line.new(x0, 0.0, x0 + W, 1.0, color = color.new(cNeu, 30), style = line.style_dotted, width = 1)
    relAx.push(line.new(x0, 0.0, x0, 1.0, color = color.new(cDim, 40), width = 1))
    relAx.push(line.new(x0, 0.0, x0 + W, 0.0, color = color.new(cDim, 40), width = 1))
    for b = 0 to NBIN - 1
        int n = binN.get(b)
        if n >= 3
            float pred = (b + 0.5) / NBIN
            float real = binS.get(b) / n
            color dc = math.abs(real - pred) < 0.12 ? cBull : cBear
            relPts.push(label.new(x0 + int(pred * W), real, "●", style = label.style_none, textcolor = dc, size = size.tiny))

// ── CONVICTION-TIER BADGE ──
var label badge = na
if showVerdict and barstate.islast
    if not na(badge)
        label.delete(badge)
    color tcol = tier == "S" ? cBull : tier == "A" ? cAcc : tier == "B" ? cNeu : cDim
    string bTxt = (sigDir != 0 ? (sigDir > 0 ? "▲ " : "▼ ") : vetoed ? "⊘ " : "· ") + "CONV " + str.tostring(conv) + " · " + tier
    badge := label.new(bar_index + 3, 0.94, bTxt, style = label.style_label_left, color = color.new(tcol, 82), textcolor = tcol, size = size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 9 — DASHBOARD  (reliability + metrics)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_dashPos(dashPos), 4, 15, frame_color = cGrid, frame_width = 1, border_color = cGrid, border_width = 1)
f_cell(int c, int r, string txt, color tc, color bg, string sz) =>
    table.cell(dash, c, r, txt, text_color = tc, bgcolor = bg, text_size = sz, text_halign = text.align_center)

if showDash and barstate.islast
    string sz = "small"
    table.clear(dash, 0, 0, 3, 14)
    // header becomes a plain-language VERDICT — act / stand aside / wait
    string vTxt = "ML PROBABILITY"
    color  vCol = cTxt
    if showVerdict
        if not warm
            vTxt := "WARMING UP · " + str.tostring(resolvedN) + "/" + str.tostring(warmN) + " samples"
            vCol := cDim
        else if sigDir > 0
            vTxt := "LONG · probability clears the long gate"
            vCol := cBull
        else if sigDir < 0
            vTxt := "SHORT · probability clears the short gate"
            vCol := cBear
        else if rawDir != 0 and vetoed
            vTxt := "VETO · " + vetoTxt + " — " + (rawDir > 0 ? "long" : "short") + " setup blocked"
            vCol := cDim
        else if not calibrated
            vTxt := "NO EDGE · stand aside (Brier " + str.tostring(brier, "0.00") + " ≥ 0.25)"
            vCol := cDim
        else
            vTxt := "NO SIGNAL · " + f_regName(regID) + " · P inside the gates"
            vCol := f_regCol(regID)
        if sigDir != 0
            int   sn = sigDir > 0 ? upN : dnN
            int   sw = sigDir > 0 ? upW : dnW
            float sb = f_baseP(sigDir)
            if sn >= 5 and not na(sb)
                float se = sw / float(sn) - sb
                vTxt := vTxt + "  (edge " + (se >= 0 ? "+" : "") + str.tostring(se * 100, "0") + "%)"
    f_cell(0, 0, vTxt, vCol, cHead, "normal")
    table.merge_cells(dash, 0, 0, 3, 0)

    f_cell(0, 1, "P " + str.tostring(pCal * 100, "0.0") + "%" + (useRecal ? "↺" : ""), pc, cPanel, sz)
    f_cell(1, 1, na(cHW) ? "±·" : "±" + str.tostring(cHW * 100, "0") + "%", cNeu, cPanel, sz)
    f_cell(2, 1, "Brier " + (na(brier) ? "·" : str.tostring(brier, "0.000")), na(brier) ? cDim : brier < 0.25 ? cBull : cBear, cPanel, sz)
    f_cell(3, 1, warm ? "READY" : "warm " + str.tostring(resolvedN) + "/" + str.tostring(warmN), warm ? cBull : cDim, cPanel, sz)

    // regime · ACI working α · warm-up shrink
    f_cell(0, 2, f_regName(regID), f_regCol(regID), cPanel, sz)
    f_cell(1, 2, "α " + str.tostring(aciAlpha, "0.00"), cNeu, cPanel, sz)
    f_cell(2, 2, "shrink " + str.tostring(regShrink * 100, "0") + "%", regShrink >= 0.99 ? cBull : cDim, cPanel, sz)
    f_cell(3, 2, "rN " + str.tostring(regResolved.get(regID)), cNeu, cPanel, sz)

    // conviction tier · MTF agreement · participation · active veto
    color tierCol = tier == "S" ? cBull : tier == "A" ? cAcc : tier == "B" ? cNeu : cDim
    f_cell(0, 3, "CONV " + str.tostring(conv) + " " + tier, tierCol, cPanel, sz)
    f_cell(1, 3, "MTF " + str.tostring(mtfBull) + "/" + str.tostring(mtfBear), useMtf ? cNeu : cDim, cPanel, sz)
    f_cell(2, 3, "flow " + (cvdSign > 0 ? "↑" : cvdSign < 0 ? "↓" : "·"), cvdSign > 0 ? cBull : cvdSign < 0 ? cBear : cDim, cPanel, sz)
    f_cell(3, 3, vetoed ? "VETO " + vetoTxt : "clear", vetoed ? cBear : cBull, cPanel, sz)

    if dashMode == "Pro"
        f_cell(0, 4, "BUCKET", cNeu, cHead, sz)
        f_cell(1, 4, "n",      cNeu, cHead, sz)
        f_cell(2, 4, "Pred",   cNeu, cHead, sz)
        f_cell(3, 4, "Real",   cNeu, cHead, sz)
        int row = 5
        for b = 0 to NBIN - 1
            int n = binN.get(b)
            if n >= 3 and row <= 11
                float pred = (b + 0.5) / NBIN
                float real = binS.get(b) / n
                color rc = math.abs(real - pred) < 0.12 ? cBull : cBear
                f_cell(0, row, str.tostring(int(b * 100 / NBIN)) + "–" + str.tostring(int((b + 1) * 100 / NBIN)), cTxt, cPanel, sz)
                f_cell(1, row, str.tostring(n), cTxt, cPanel, sz)
                f_cell(2, row, str.tostring(pred * 100, "0") + "%", cNeu, cPanel, sz)
                f_cell(3, row, str.tostring(real * 100, "0") + "%", rc, cPanel, sz)
                row += 1
        // overall directional edge vs DIRECTIONAL base, with recency + Wilson
        float upHit = upN > 0 ? upW / float(upN) : na
        float dnHit = dnN > 0 ? dnW / float(dnN) : na
        float upEdge = na(f_baseP(1))  or na(upHit) ? na : upHit - f_baseP(1)
        float dnEdge = na(f_baseP(-1)) or na(dnHit) ? na : dnHit - f_baseP(-1)
        // multiple-testing deflation: the significance bar rises with the number of edges scanned
        float zEdge = edgeTests <= 1 ? 1.96 : edgeTests == 2 ? 2.24 : edgeTests == 3 ? 2.39 : edgeTests == 4 ? 2.50 : 2.58
        bool  upStar = not na(f_z(upW, upN, f_baseP(1)))  and f_z(upW, upN, f_baseP(1))  > zEdge
        bool  dnStar = not na(f_z(dnW, dnN, f_baseP(-1))) and f_z(dnW, dnN, f_baseP(-1)) > zEdge
        float upCI = f_wilsonHalf(upW, upN)
        float dnCI = f_wilsonHalf(dnW, dnN)
        string es = "UP " + (na(upEdge) ? "·" : (upEdge >= 0 ? "+" : "") + str.tostring(upEdge * 100, "0") + "%" + (na(upCI) ? "" : "±" + str.tostring(upCI * 100, "0")) + (upStar ? "*" : "")) + "   DN " + (na(dnEdge) ? "·" : (dnEdge >= 0 ? "+" : "") + str.tostring(dnEdge * 100, "0") + "%" + (na(dnCI) ? "" : "±" + str.tostring(dnCI * 100, "0")) + (dnStar ? "*" : ""))
        f_cell(0, 12, es, cTxt, cHead, sz)
        table.merge_cells(dash, 0, 12, 3, 12)
        // recency-weighted + regime-conditional directional hit for the CURRENT regime
        float upRH = regUpN.get(regID) > 0 ? regUpW.get(regID) / float(regUpN.get(regID)) * 100.0 : na
        float dnRH = regDnN.get(regID) > 0 ? regDnW.get(regID) / float(regDnN.get(regID)) * 100.0 : na
        string rc2 = "in " + f_regShort(regID) + " · UP " + (na(upRH) ? "·" : str.tostring(upRH, "0") + "%(" + str.tostring(regUpN.get(regID)) + ")") + " · DN " + (na(dnRH) ? "·" : str.tostring(dnRH, "0") + "%(" + str.tostring(regDnN.get(regID)) + ")")
        f_cell(0, 13, rc2, f_regCol(regID), cHead, sz)
        table.merge_cells(dash, 0, 13, 3, 13)
        string recTxt = "recent UP " + (upNd >= 1.0 ? str.tostring(upWd / upNd * 100, "0") + "%" : "·") + " · DN " + (dnNd >= 1.0 ? str.tostring(dnWd / dnNd * 100, "0") + "%" : "·") + "  ·  base ↑" + (baseN > 0 ? str.tostring(baseWup * 100 / baseN) : "·") + "/↓" + (baseN > 0 ? str.tostring(baseWdn * 100 / baseN) : "·") + " · mem " + str.tostring(memY.size())
        f_cell(0, 14, recTxt, cDim, cHead, sz)
        table.merge_cells(dash, 0, 14, 3, 14)
    else
        f_cell(0, 4, "Brier " + (na(brier) ? "·" : str.tostring(brier, "0.000")), cTxt, cPanel, sz)
        table.merge_cells(dash, 0, 4, 1, 4)
        f_cell(2, 4, "n " + str.tostring(resolvedN), cNeu, cPanel, sz)
        table.merge_cells(dash, 2, 4, 3, 4)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 10 — ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(sigDir > 0, "Long Probability Signal",  "ML Probability: P(up) band above long gate on {{ticker}} ({{interval}})")
alertcondition(sigDir < 0, "Short Probability Signal", "ML Probability: P(up) band below short gate on {{ticker}} ({{interval}})")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 11 — EXPORTS (Data Window)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float upHitE = upN > 0 ? upW / float(upN) : na
float expEdge = (na(f_baseP(1)) or na(upHitE)) ? na : (upHitE - f_baseP(1)) * 100.0

plot(showEXP ? pCal : na,         "EXP_Pup",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? pUp : na,          "EXP_Praw",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? alphaEff : na,     "EXP_AlphaEff", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? pLo : na,          "EXP_PLo",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? pHi : na,          "EXP_PHi",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(sigDir) : na,"EXP_Signal", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? brier : na,        "EXP_Brier",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expEdge : na,      "EXP_Edge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(regID) : na, "EXP_Regime", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? aciAlpha : na,     "EXP_Alpha",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? float(conv) : na,  "EXP_Conv",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (vetoed ? 1.0 : 0.0) : na, "EXP_Veto", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP and useMtf ? float(mtfBull - mtfBear) : na, "EXP_MTF", color = color.new(color.gray, 100), display = display.data_window)
````

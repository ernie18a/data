# Adaptive Regression Channel Fit-Gated & Calibrated

- url: https://www.tradingview.com/script/o4bUlsSo-Adaptive-Regression-Channel-Fit-Gated-Calibrated/
- type: indicator
- pine_id: PUB;9be470d82f66416bbd2349db754fc2ab
- version: 2.0

## Description

Adaptive Regression Channel — Multi-Engine, Fit-Gated & Calibrated

What it is

A regression channel that lets you choose the estimator, measures its own goodness-of-fit, and refuses to be trusted when that fit is poor. Four centerline engines, seven volatility engines for the bands, a kurtosis fat-tail multiplier, an honest √-horizon uncertainty cone, a ride-vs-revert detector, and a past-only calibration tracker that asks whether tagging the band actually precedes reversion on this symbol — measured against an unconditional base rate, in R.

Why these components belong in ONE script (not a stack of indicators)

They are the parts of one estimator, each covering a failure mode of the others:

Centerline engine. OLS is the baseline but lags at the right edge and is fragile to spikes. LOESS fixes the endpoint lag (local-linear, tricube-weighted). Theil-Sen fixes spike fragility (median of pairwise slopes). Kalman removes the window entirely (recursive level + trend). You choose the trade-off.
Adaptive window (Kaufman efficiency ratio). A fixed window is wrong in both trends and chop; the length stretches when price is efficient and contracts when it is noisy, so the channel tracks the live swing.
Volatility engine. The bands are only meaningful if their width reflects the real residual distribution: EWMA (recency), Yang-Zhang (drift-robust OHLC range), GARCH(1,1) (clustering), MAD (spike-resistance), asymmetric semidev (skew), quantile (empirical containment) — plus a kurtosis fat-tail multiplier so the stated containment actually holds.
Fit-quality gate. A channel drawn on a bad fit is noise dressed as structure. The centerline only draws solid and only emits events when it explains at least r2Gate of variance; below that it greys to dashed.
Ride-vs-revert. A band touch is ambiguous. Consecutive closes beyond the band ("walking the band") mark continuation, not reversion — so the channel does not fade a trend that is running.
Calibration. The edges are a hypothesis. Each trusted band tag is resolved forward against an unconditional same-horizon base rate, in R, so you see whether the band adds anything over noise — not a naked win-rate.

The centerline says where the mean is, the volatility engine says how wide the normal range is, the fit gate says whether to believe any of it, ride-vs-revert says fade or follow, and calibration keeps it honest. Remove any layer and the channel loses a check it cannot recover.

How it works (mechanics)

The selected engine fits the centerline in (optionally log) price space, on a window that can be fixed, ER-adaptive, or pivot-anchored to the current segment. Residual dispersion drives the bands through the chosen volatility engine, widened by the fat-tail multiplier. The fit metric is the explained-variance fraction of the residuals; below the gate the channel is shown as untrusted and emits nothing. On a trusted channel, each band tag is queued on bar close and resolved horizon bars later — a win if price moved moveATR·ATR in the reversion direction — and tallied per class (UTAG / LTAG) against the unconditional base rate.

Non-repaint: fits on confirmed closes, pivots confirmed, calibration on bar close. The drawn channel updates live (a rolling regression always does — that is description, not a signal); the calibrated events are confirmed-bar only.

How to use

Read the dashboard: FIT% and TRUSTED / LOW-FIT come first. If the fit is low, treat the channel as description only.
On a trusted channel, a band tag is a reversion hypothesis — the calibration rows tell you whether that class has actually paid on this symbol (Hit% vs Base%, Edge with a 95% star, MFE/MAE in R).
WALK means the band is being ridden (trend) — do not fade it.
The cone is an uncertainty fan (√-horizon growth), not a target.
Everything here is descriptive, probabilistic context — never an instruction.

Use on any market

The Data Source inputs (Close / High / Low) drive the fit, the band tags and the calibration, so the channel runs on any series (standard candles, Heikin-Ashi, etc.) and any market. All thresholds are ATR-relative. Defaults are set for NIFTY index-futures intraday; change the source or lengths for other assets.

Originality

The contribution is the closed loop: a selectable estimator whose fit is measured and gated, bands whose width is chosen from seven rigorous volatility models and fat-tail-corrected, a ride-vs-revert guard, and a per-class forward calibration against an unconditional base rate. Most channels draw a line and a ±σ band and stop; this one tells you whether to believe the line and whether the band has historically meant anything here.

Credits

Least squares & local regression (LOESS) — Gauss / Legendre; W. S. Cleveland
Theil-Sen estimator — H. Theil & P. K. Sen
Recursive level+trend (Kalman) filter — R. E. Kálmán
Efficiency Ratio (adaptive window) — Perry Kaufman
EWMA / RiskMetrics variance — J.P. Morgan
Yang-Zhang OHLC volatility — Dennis Yang & Qiang Zhang
GARCH(1,1) — Engle & Bollerslev

The fit-quality gate, the band-walk ride-vs-revert logic and the forward-calibration framework are the author's original implementation.

Limitations (honest)

The calibration is in-sample, close-to-close at a fixed horizon, with no costs, slippage or stops — a study aid, not a backtest, and not a probability of future results. A rolling regression updates every bar; the drawn channel is descriptive, and only the confirmed-bar tag events are calibrated. Theil-Sen is O(n²) in pairs (capped for speed). Past behaviour does not assure future behaviour.

Disclaimer

Educational / informational study for chart analysis only. NOT financial advice, NOT a strategy, NOT a recommendation. It places no orders and guarantees no outcome. Markets carry risk; do your own research and manage your own risk. Paper-trade before risking real money.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ══════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                  MPL-2.0
//  ADAPTIVE REGRESSION CHANNEL — Multi-Engine, Fit-Gated & Calibrated       v2.0
//  shorttitle: Adaptive Channel                                     Pine Script v6
// ──────────────────────────────────────────────────────────────────────────────
//  WHAT THIS IS
//    A regression channel that lets you choose the estimator, measures its own
//    goodness-of-fit, and REFUSES to be trusted when that fit is poor. Four
//    centerline engines, seven volatility engines for the bands, an honest
//    uncertainty cone, and a past-only calibration tracker that asks whether
//    tagging the band actually precedes reversion on THIS symbol.
//
//  WHY THESE COMPONENTS BELONG IN ONE SCRIPT  (mashup rationale)
//    These are not separate indicators bolted together — they are the parts of one
//    estimator, each covering a failure mode of the others:
//      * CENTERLINE ENGINE — OLS is the baseline but lags at the right edge and is
//        fragile to spikes. LOESS fixes the endpoint lag (local-linear, tricube),
//        Theil-Sen fixes the spike fragility (median of pairwise slopes), Kalman
//        removes the window entirely (recursive level+trend). You pick the trade-off.
//      * ADAPTIVE WINDOW (Kaufman efficiency ratio) — a fixed window is wrong in
//        both trends and chop; the length stretches when price is efficient and
//        contracts when it is noisy, so the channel tracks the live swing.
//      * VOLATILITY ENGINE — the bands are only meaningful if their width reflects
//        the real residual distribution: EWMA for recency, Yang-Zhang for
//        drift-robust OHLC range, GARCH for clustering, MAD for spike-resistance,
//        asymmetric semidev for skew, quantile for empirical containment — plus a
//        kurtosis fat-tail multiplier so stated containment actually holds.
//      * FIT-QUALITY GATE — a channel drawn on a bad fit is noise dressed as
//        structure. The centerline only draws solid and only emits events when it
//        explains at least r2Gate of variance; below that it greys to dashed.
//      * RIDE-vs-REVERT — a band touch is ambiguous; consecutive closes beyond the
//        band ("walking the band") mark continuation, not reversion, so the channel
//        does not fade a trend that is running.
//      * CALIBRATION — the edges are a hypothesis. Each trusted band tag is resolved
//        forward against an unconditional same-horizon base rate, in R, so you see
//        whether the band adds anything over noise — not a naked win-rate.
//    Centerline says where the mean is, the volatility engine says how wide the
//    normal range is, the fit gate says whether to believe any of it, ride-vs-revert
//    says whether to fade or follow, and calibration keeps it honest.
//
//  ENGINES
//    • OLS        — classic least squares (baseline).
//    • LOESS      — local-linear, tricube-weighted at the endpoint (fixes edge lag).
//    • Theil-Sen  — median of pairwise slopes (robust to spikes / outliers).
//    • Kalman     — recursive local level + trend; no window, adapts bar to bar.
//    • Quantile   — median (L1) regression via IRLS; the most outlier-robust centre,
//                   and the same routine draws asymmetric quantile-regression bands.
//
//  FRONTIER BANDS  (v2.0)
//    • CONFORMAL-PID coverage — instead of a fixed ×σ, the band multiplier is set so
//      the channel actually contains its target fraction of closes on THIS symbol.
//      Adaptive Conformal Inference (the integral term) plus a proportional term on
//      the recent coverage error (Angelopoulos-Candès-Tibshirani 2023) keeps coverage
//      on target through volatility breaks.
//    • QUANTILE-REGRESSION bands — upper/lower are conditional-quantile lines fitted
//      straight to the data, so the channel is asymmetric where the move is skewed.
//    • ROUGH-VOL band width — a fractional power-law kernel (rough volatility) for the
//      residual σ, weighting recent bars the way rough vol demands.
//    • REGIME★ input — optionally read EXP_Regime from the Market Regime Classifier to
//      stop the channel fading a strong trend.
//
//  CALIBRATION
//    Each trusted-channel band tag is queued and resolved N bars later against
//    moveATR·ATR, in R. Dashboard, per class:
//      UTAG / LTAG :  n · Hit% · Base% · Edge(Hit−Base, *=95% z) · MFE/MAE(R).
//    Base% = unconditional same-horizon directional move. No naked win-rates.
//
//  USE ON ANY MARKET
//    The Data Source inputs (Close / High / Low) drive the fit, the band tags and
//    the calibration, so the channel runs on any series (standard candles,
//    Heikin-Ashi, etc.) and any market. All thresholds are ATR-relative; defaults
//    are set for NIFTY index-futures intraday — change the source or lengths for
//    other assets.
//
//  HOW TO USE
//    1. Read the dashboard: the FIT% and TRUSTED/LOW-FIT state come first — if the
//       fit is low, the channel is description only.
//    2. On a trusted channel, a band tag is a reversion hypothesis; the calibration
//       rows tell you whether that class has actually paid on this symbol.
//    3. WALK means the band is being ridden (trend) — do not fade it.
//    4. The cone is an uncertainty fan (√horizon growth), not a target.
//    5. Everything here is descriptive, probabilistic context — never an instruction.
//
//  EXPORTS (Data Window): consume via input.source():
//    EXP_Center · EXP_Slope · EXP_Upper · EXP_Lower · EXP_FitQ · EXP_Edge ·
//    EXP_Coverage · EXP_BandMult
//
//  NON-REPAINT
//    Fit on confirmed closes; pivots confirmed; calibration on barstate.isconfirmed.
//    The drawn channel updates live (a rolling regression always does) — that is
//    description, not a signal; the calibrated events are confirmed-bar only.
//
//  CREDITS (concepts this engine builds on)
//    • Least squares & local regression (LOESS) — Gauss / Legendre; W. S. Cleveland.
//    • Theil-Sen estimator — H. Theil & P. K. Sen.
//    • Quantile / median regression (IRLS) — Roger Koenker & Gilbert Bassett.
//    • Recursive level+trend filter — R. E. Kálmán.
//    • Efficiency Ratio (adaptive window) — Perry Kaufman.
//    • EWMA / RiskMetrics variance — J.P. Morgan.
//    • Yang-Zhang OHLC volatility — Dennis Yang & Qiang Zhang.
//    • GARCH(1,1) volatility clustering — Engle & Bollerslev.
//    • Rough volatility (fractional kernel) — Gatheral, Jaisson & Rosenbaum.
//    • Conformal prediction — Vovk; Adaptive CI — Gibbs & Candès; Conformal-PID —
//      Angelopoulos, Candès & Tibshirani (2023).
//    Implementation, the fit-quality gate, the conformal-band calibration and the
//    calibration framework are the author's original work.
//
//  DISCLAIMER
//    EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a strategy, NOT a
//    recommendation. A regression channel is a description of the past; the cone is
//    uncertainty, not a forecast you can trade blindly. Forward stats are in-sample,
//    close-to-close at a fixed horizon, with no costs, slippage or stops. Past
//    behaviour does not assure future behaviour. Paper-trade before risking real
//    money; you alone are responsible for your decisions.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Adaptive Regression Channel — Multi-Engine, Fit-Gated & Calibrated", "Adaptive Channel",
     overlay              = true,
     max_polylines_count  = 10,
     max_bars_back        = 1000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 1 — INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gS = "1 · Data Source (any market)"
g1 = "2 · Engine"
g2 = "3 · Bands & Cone"
g3 = "4 · Adaptive / Modes"
g4 = "5 · Calibration"
g5 = "6 · Display"
gT = "7 · Theme"
gE = "8 · Exports"

srcClose = input.source(close, "Close source", group = gS, tooltip = "Drives the regression fit, the residual bands and the cone. Swap to an alternate series (e.g. Heikin-Ashi) to run the channel on any market or candle type. Defaults to the chart's Close.")
srcHigh  = input.source(high,  "High source",  group = gS, tooltip = "Used for upper-band tags and the favourable/adverse excursion in calibration.")
srcLow   = input.source(low,   "Low source",   group = gS)

method   = input.string("LOESS", "Centerline Engine", ["OLS", "LOESS", "Theil-Sen", "Kalman", "Quantile (median)"], group = g1)
baseLen  = input.int(100, "Base Length", minval = 10, maxval = 400, group = g1, tooltip = "Regression window (windowed engines). Kalman ignores this.")
loessBw  = input.float(0.6, "LOESS Bandwidth (×length)", minval = 0.15, maxval = 1.0, step = 0.05, group = g1, tooltip = "Tricube weighting span as a fraction of the window. Smaller = more local, more reactive.")
tsMax    = input.int(50, "Theil-Sen Max Points", minval = 12, maxval = 80, group = g1, tooltip = "Theil-Sen is O(n²) in pairs; this caps the window it considers for speed.")
kalQ     = input.float(0.01, "Kalman Process Noise Q", minval = 0.0001, maxval = 1.0, step = 0.001, group = g1, tooltip = "Higher = the filter trusts new prices more (more reactive, noisier).")
kalR     = input.float(1.0,  "Kalman Measurement Noise R", minval = 0.01, maxval = 20.0, step = 0.05, group = g1)
qrMaxPts = input.int(120, "Quantile-reg Max Points", minval = 20, maxval = 200, group = g1, tooltip = "Window cap for the median / quantile-regression engine (IRLS is O(points×iterations)).")
qrIters  = input.int(25, "Quantile-reg IRLS Iterations", minval = 5, maxval = 60, group = g1, tooltip = "Iteratively-reweighted least squares passes. ~25 converges to the true conditional quantile; fewer is faster but the tails under-cover.")

bandK    = input.float(2.0, "Band Width (×σ)", minval = 0.5, maxval = 4.0, step = 0.1, group = g2, tooltip = "Channel half-width in residual standard deviations (or the chosen engine's unit).")
bandLen  = input.int(100, "Residual / Variance Length", minval = 20, maxval = 400, group = g2, tooltip = "Window for residual σ (bands) and for the explained-variance fit metric.")
volEng   = input.string("EWMA", "Band Volatility Engine", ["Rolling σ", "EWMA", "Yang-Zhang", "GARCH(1,1)", "Robust MAD", "Asymmetric semidev", "Quantile", "Rough (fractional)", "Quantile regression"], group = g2, tooltip = "How band width is measured on the residuals. Rolling σ = textbook. EWMA = recency-weighted (RiskMetrics). Yang-Zhang = OHLC range vol (drift-robust). GARCH(1,1) = volatility-clustering. MAD = spike-resistant. Asymmetric = separate up/down width (captures skew). Quantile = empirical containment. Rough (fractional) = rough-volatility power-law kernel on residuals. Quantile regression = asymmetric bands fitted directly as conditional-quantile lines (skew-aware; self-calibrating coverage).")
rghH     = input.float(0.10, "Rough-vol roughness H", minval = 0.02, maxval = 0.95, step = 0.01, group = g2, tooltip = "Rough-vol engine only. Fractional-kernel exponent (weight ∝ lag^(H−0.5)). Equity vol is typically very rough, H ~ 0.1; H = 0.5 reproduces a flat window σ.")
ewmaLam  = input.float(0.94, "EWMA λ", minval = 0.80, maxval = 0.995, step = 0.005, group = g2, tooltip = "EWMA engine only. 0.94 = RiskMetrics default.")
garchA   = input.float(0.10, "GARCH α (shock)", minval = 0.01, maxval = 0.50, step = 0.01, group = g2, tooltip = "GARCH engine only — weight on the latest squared residual.")
garchB   = input.float(0.85, "GARCH β (persistence)", minval = 0.50, maxval = 0.98, step = 0.01, group = g2, tooltip = "GARCH engine only — weight on prior variance. α+β<1 for a stable long-run variance.")
qCont    = input.float(95.0, "Quantile Containment %", minval = 50.0, maxval = 99.9, step = 0.5, group = g2, tooltip = "Quantile engine only — target fraction of residuals the band should contain.")
fatTail  = input.bool(true, "Fat-Tail Multiplier (kurtosis)", group = g2, tooltip = "Widen the bands when the residual distribution is fat-tailed, so the stated containment actually holds.")
fatGain  = input.float(0.5, "Fat-Tail Gain", minval = 0.0, maxval = 2.0, step = 0.1, group = g2)
walkBars = input.int(3, "Band-Walk Streak (Ride)", minval = 2, maxval = 15, group = g2, tooltip = "Consecutive closes beyond the band that count as 'walking the band' — trend continuation (ride), not reversion (fade).")
showCone = input.bool(true, "Show Forecast Cone", group = g2)
coneH    = input.int(20, "Cone Horizon (bars)", minval = 4, maxval = 60, group = g2)
coneGrow = input.float(1.0, "Cone Growth (×σ·√h)", minval = 0.2, maxval = 3.0, step = 0.1, group = g2)

gC = "3b · Conformal-PID band coverage"
useConf   = input.bool(true, "Conformal-PID band calibration", group = gC, tooltip = "Replace the fixed ×σ multiplier with a conformal one, so the band actually contains its target fraction of closes on THIS symbol. Ignored for the 'Quantile regression' engine (already quantile-targeted).")
confTarget= input.float(90.0, "Target coverage %", minval = 50.0, maxval = 99.0, step = 1.0, group = gC, tooltip = "Fraction of closes the band should contain (also sets the quantile-regression band levels).")
confKp    = input.float(0.10, "PID proportional gain", minval = 0.0, maxval = 1.0, step = 0.01, group = gC, tooltip = "Conformal-PID: reacts to the RECENT coverage error on top of the ACI integrator. 0 = plain Adaptive Conformal Inference.")
confBeta  = input.float(0.05, "PID recent-error smoothing", minval = 0.01, maxval = 0.5, step = 0.01, group = gC)
confGamma = input.float(0.02, "ACI integrator rate", minval = 0.001, maxval = 0.2, step = 0.001, group = gC)
confWin   = input.int(250, "Conformal score window", minval = 40, maxval = 1000, group = gC, tooltip = "How many recent standardised residuals the conformal quantile is taken over.")

gRg = "4b · Regime backbone (optional)"
useRegime = input.bool(false, "Consume external regime (EXP_Regime)", group = gRg, tooltip = "Read the −2…+2 regime state exported by the Market Regime Classifier and stop the channel fading a strong trend. Add that indicator to the chart, then point the source below at its EXP_Regime plot.")
regSrc    = input.source(close, "Regime source (link to EXP_Regime)", group = gRg)
regGate   = input.bool(true, "Suppress counter-trend fades in strong regimes", group = gRg, tooltip = "When on, a strong trend regime (|state| = 2) blocks the band tag that would fade it — no upper-band fade in a strong up-regime, no lower-band fade in a strong down-regime.")

adaptive = input.bool(true, "Adaptive Window (ER)", group = g3, tooltip = "Stretch the window in efficient trends, shrink it in chop.")
erLen    = input.int(20, "Adaptive ER Length", minval = 5, maxval = 60, group = g3)
anchorPv = input.bool(false, "Pivot-Anchored Segment", group = g3, tooltip = "Fit only the current segment: from the most recent confirmed pivot to now.")
pivotLen = input.int(8, "Anchor Pivot Length", minval = 3, maxval = 40, group = g3)
logMode  = input.bool(false, "Log-Space Fit", group = g3, tooltip = "Fit on ln(price). Bands become percentage-symmetric.")
r2Gate   = input.float(0.45, "Fit-Quality Gate (R²)", minval = 0.0, maxval = 0.95, step = 0.05, group = g3, tooltip = "Below this explained-variance fraction, the channel is shown greyed/dashed and emits no signals.")

horizon  = input.int(12,  "Eval Horizon (bars)", minval = 3, maxval = 60, group = g4)
moveATR  = input.float(1.0, "Win Threshold (×ATR)", minval = 0.2, maxval = 4.0, step = 0.1, group = g4)
atrLen   = input.int(14,  "ATR Length (R unit)", minval = 5, maxval = 50, group = g4)
minGap   = input.int(6, "Min Bars Between Tags", minval = 1, maxval = 60, group = g4)

showBands= input.bool(true, "Show Bands", group = g5)
showFill = input.bool(true, "Fill Channel", group = g5)
showTags = input.bool(true, "Show Band Tags", group = g5)
showDash = input.bool(true, "Show Dashboard", group = g5)
dashMode = input.string("Compact", "Dashboard Mode", ["Compact", "Pro"], group = g5)
dashPos  = input.string("Top Right", "Dashboard Position", ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)

themeMode = input.string("Auto", "Theme", ["Auto", "Dark", "Light"], group = gT)
upColI    = input.color(#21D7AC, "Up / Bull",  group = gT)
dnColI    = input.color(#F2547B, "Down / Bear", group = gT)
neuColI   = input.color(#58A6FF, "Centerline", group = gT)

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

f_tx(float p) => logMode ? math.log(p) : p          // forward transform
f_itx(float v) => logMode ? math.exp(v) : v         // inverse transform

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 3 — EFFECTIVE WINDOW (adaptive + pivot-anchored)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_er(float s, int len) =>
    float net  = math.abs(s - s[len])
    float path = 0.0
    for i = 0 to len - 1
        path += math.abs(s[i] - s[i + 1])
    path > 0 ? net / path : 0.0

float er = f_er(close, erLen)

float ph = ta.pivothigh(pivotLen, pivotLen)
float pl = ta.pivotlow(pivotLen, pivotLen)
var int lastPivotBar = na
if not na(ph) or not na(pl)
    lastPivotBar := bar_index - pivotLen

int effLen = baseLen
if adaptive
    effLen := int(math.round(baseLen * (0.5 + er)))            // 0.5×..1.5× by efficiency
if anchorPv and not na(lastPivotBar)
    int segBars = bar_index - lastPivotBar
    effLen := math.max(10, math.min(effLen, segBars))
effLen := math.max(10, math.min(effLen, 400))
effLen := math.max(2, math.min(effLen, bar_index))   // never exceed available history; never 0 (would make for-loops count down into srcClose[-1])

float atr = ta.atr(atrLen)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 4 — CENTERLINE ENGINES  (return [endValue, slopePerBar] in fit space)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// note: srcClose in fit space, t bars from oldest, is f_tx(srcClose[L-1-t]) — inlined below
//       (calling a history-indexing helper inside loops trips CW10003/CW10004)

// OLS
f_ols(int L) =>
    float n = L
    float Sx = 0.0
    float Sy = 0.0
    float Sxx = 0.0
    float Sxy = 0.0
    for t = 0 to L - 1
        float y = f_tx(srcClose[L - 1 - t])
        Sx += t
        Sy += y
        Sxx += t * t
        Sxy += t * y
    float den = n * Sxx - Sx * Sx
    float b = den != 0 ? (n * Sxy - Sx * Sy) / den : 0.0
    float a = (Sy - b * Sx) / n
    [a + b * (L - 1), b]

// LOESS local-linear at the newest point (tricube weights)
f_loess(int L) =>
    float x0 = L - 1
    float bw = math.max(2.0, loessBw * L)
    float Sw = 0.0
    float Swx = 0.0
    float Swy = 0.0
    float Swxx = 0.0
    float Swxy = 0.0
    for t = 0 to L - 1
        float d = math.abs(x0 - t) / bw
        float w = d < 1.0 ? math.pow(1.0 - d * d * d, 3.0) : 0.0
        if w > 0
            float y = f_tx(srcClose[L - 1 - t])
            Sw += w
            Swx += w * t
            Swy += w * y
            Swxx += w * t * t
            Swxy += w * t * y
    float den = Sw * Swxx - Swx * Swx
    float b = den != 0 ? (Sw * Swxy - Swx * Swy) / den : 0.0
    float a = Sw != 0 ? (Swy - b * Swx) / Sw : f_tx(srcClose)
    [a + b * x0, b]

// Theil-Sen (median pairwise slope), capped at tsMax points
f_theilsen(int Lin) =>
    int L = math.min(Lin, tsMax)
    array<float> slopes = array.new<float>()
    for i = 0 to L - 2
        for j = i + 1 to L - 1
            float yi = f_tx(srcClose[L - 1 - i])
            float yj = f_tx(srcClose[L - 1 - j])
            slopes.push((yj - yi) / (j - i))
    float b = slopes.size() > 0 ? slopes.median() : 0.0
    // robust intercept: median(y_t - b·t), evaluated at newest
    array<float> ints = array.new<float>()
    for t = 0 to L - 1
        ints.push(f_tx(srcClose[L - 1 - t]) - b * t)
    float a = ints.size() > 0 ? ints.median() : f_tx(srcClose)
    [a + b * (L - 1), b]

// Quantile / median regression at the endpoint via IRLS (Koenker-Bassett).
// tau = 0.5 is the L1 (median) centreline — the most outlier-robust fit; tau away
// from 0.5 gives the asymmetric conditional-quantile band lines. The check-function
// is minimised by iteratively-reweighted least squares with weight
//   w = (tau if resid>0 else 1-tau) / |resid|.  ~25 passes reach the true quantile.
f_quantreg(int Lin, float tau, int iters) =>
    int L = math.max(2, math.min(Lin, qrMaxPts))
    float a = 0.0
    for t = 0 to L - 1
        a += f_tx(srcClose[L - 1 - t])
    a := a / L
    float b = 0.0
    for it = 0 to iters - 1
        float Sw  = 0.0
        float Swx = 0.0
        float Swy = 0.0
        float Swxx = 0.0
        float Swxy = 0.0
        for t = 0 to L - 1
            float y  = f_tx(srcClose[L - 1 - t])
            float r  = y - (a + b * t)
            float wq = (r > 0.0 ? tau : 1.0 - tau) / math.max(math.abs(r), 1e-6)
            Sw   += wq
            Swx  += wq * t
            Swy  += wq * y
            Swxx += wq * t * t
            Swxy += wq * t * y
        float den = Sw * Swxx - Swx * Swx
        b := den != 0.0 ? (Sw * Swxy - Swx * Swy) / den : b
        a := Sw != 0.0 ? (Swy - b * Swx) / Sw : a
    [a + b * (L - 1), b]

// scalar endpoint of the quantile-regression line (bands need the level, not the slope)
f_qrEnd(int Lin, float tau, int iters) =>
    [e, b] = f_quantreg(Lin, tau, iters)
    e + b * 0.0

// Kalman local level + trend (recursive). Runs at GLOBAL scope every bar — a
// function may not modify global var state in Pine v6, and the filter must keep
// continuous state. Only consumed when method == "Kalman".
var float kLevel = na
var float kTrend = 0.0
var float kP00 = 1.0
var float kP01 = 0.0
var float kP10 = 0.0
var float kP11 = 1.0

float kz = f_tx(srcClose)
if na(kLevel)
    kLevel := kz
else
    float lp = kLevel + kTrend
    float tp = kTrend
    float p00 = kP00 + kP01 + kP10 + kP11 + kalQ
    float p01 = kP01 + kP11
    float p10 = kP10 + kP11
    float p11 = kP11 + kalQ
    float yres = kz - lp
    float s = p00 + kalR
    float k0 = p00 / s
    float k1 = p10 / s
    kLevel := lp + k0 * yres
    kTrend := tp + k1 * yres
    kP00 := (1.0 - k0) * p00
    kP01 := (1.0 - k0) * p01
    kP10 := p10 - k1 * p00
    kP11 := p11 - k1 * p01

// dispatch
float endV = na
float slope = na
if method == "OLS"
    [e, b] = f_ols(effLen)
    endV := e
    slope := b
else if method == "LOESS"
    [e, b] = f_loess(effLen)
    endV := e
    slope := b
else if method == "Theil-Sen"
    [e, b] = f_theilsen(effLen)
    endV := e
    slope := b
else if method == "Quantile (median)"
    [e, b] = f_quantreg(effLen, 0.5, qrIters)
    endV := e
    slope := b
else
    endV := kLevel
    slope := kTrend

float center = f_itx(endV)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 5 — BANDS (vol engine + fat-tail) + FIT QUALITY + RIDE-vs-REVERT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float resid    = srcClose - center
float sigResid = nz(ta.stdev(resid, bandLen), 0.0)          // honest residual σ — used for the FIT metric and the cone
float sigPrice = nz(ta.stdev(srcClose, bandLen), syminfo.mintick)
float fitQ     = sigPrice > 0 ? math.max(0.0, 1.0 - (sigResid * sigResid) / (sigPrice * sigPrice)) : 0.0
bool  trusted  = fitQ >= r2Gate

// residual dispersion stats over the window (deviations are around the centerline = 0)
int   nnB = math.max(2, math.min(bandLen, 250))
float ssB = 0.0
float upB = 0.0
float dnB = 0.0
float s4B = 0.0
// MAD/Quantile need the per-deviation arrays + a sort; build them ONLY when their
// engine is active so the default path does no allocation or median/percentile work.
bool needMad = volEng == "Robust MAD"
bool needQ   = volEng == "Quantile"
array<float> absArr = array.new<float>()
array<float> sgnArr = array.new<float>()
for i = 0 to nnB - 1
    float d = nz(resid[i], 0.0)
    ssB += d * d
    s4B += d * d * d * d
    if d > 0
        upB += d * d
    else
        dnB += d * d
    if needMad
        absArr.push(math.abs(d))
    if needQ
        sgnArr.push(d)
float rVar  = ssB / nnB
float rSd   = math.sqrt(rVar)
float rUp   = math.sqrt(upB / nnB) * 1.41421356                 // upside semidev
float rDn   = math.sqrt(dnB / nnB) * 1.41421356                 // downside semidev
float rMad  = needMad ? absArr.median() * 1.4826 : na           // robust σ (MAD → σ)
float rKurt = rSd > 0 ? (s4B / nnB) / math.pow(rSd, 4.0) : 3.0  // residual kurtosis

// quantile residual levels (empirical containment) — only when that engine is active
float qHiPct = 100.0 - (100.0 - qCont) / 2.0
float qLoPct = (100.0 - qCont) / 2.0
float qUpR   = needQ ? array.percentile_linear_interpolation(sgnArr, qHiPct) : na
float qLoR   = needQ ? array.percentile_linear_interpolation(sgnArr, qLoPct) : na

// EWMA variance of residuals (RiskMetrics, recency-weighted)
var float ewmaVar = na
ewmaVar := na(ewmaVar[1]) or ewmaVar[1] == 0.0 ? resid * resid : ewmaLam * nz(ewmaVar[1]) + (1.0 - ewmaLam) * resid * resid
float ewmaSig = math.sqrt(nz(ewmaVar))

// GARCH(1,1) variance of residuals (volatility clustering); ω from the long-run residual variance
float garchOmega = math.max(0.0, 1.0 - garchA - garchB) * rVar
var float garchVar = na
garchVar := na(garchVar[1]) ? rVar : math.max(0.0, garchOmega + garchA * nz(resid[1]) * nz(resid[1]) + garchB * nz(garchVar[1]))
float garchSig = math.sqrt(garchVar)

// Yang-Zhang OHLC volatility (drift-robust) → price units, per bar.
// Computed only when its engine is selected (two O(n) loops — the heaviest band path).
float yzSig = na
if volEng == "Yang-Zhang"
    float kYZ = 0.34 / (1.34 + (nnB + 1.0) / (nnB - 1.0))
    float soY = 0.0
    float scY = 0.0
    for i = 0 to nnB - 1
        soY += math.log(nz(open[i], close[i]) / nz(close[i + 1], open[i]))
        scY += math.log(nz(close[i], open[i]) / nz(open[i], close[i]))
    float oBarY = soY / nnB
    float cBarY = scY / nnB
    float voY = 0.0
    float vcY = 0.0
    float vrsY = 0.0
    for i = 0 to nnB - 1
        float oo = math.log(nz(open[i], close[i]) / nz(close[i + 1], open[i]))
        float cc = math.log(nz(close[i], open[i]) / nz(open[i], close[i]))
        float uu = math.log(nz(high[i], close[i]) / nz(open[i], high[i]))
        float dd = math.log(nz(low[i],  close[i]) / nz(open[i], low[i]))
        voY  += (oo - oBarY) * (oo - oBarY)
        vcY  += (cc - cBarY) * (cc - cBarY)
        vrsY += uu * (uu - cc) + dd * (dd - cc)
    float yzVar = voY / (nnB - 1) + kYZ * vcY / (nnB - 1) + (1.0 - kYZ) * vrsY / nnB
    yzSig := math.sqrt(math.max(0.0, yzVar)) * close

// rough-volatility residual σ: fractional power-law kernel w_i ∝ (i+1)^(H−0.5) on residual²
// (rough vol → more weight on the most recent bars). Computed only when its engine is active.
float rghSig = na
if volEng == "Rough (fractional)"
    float rSumR = 0.0
    float rWR   = 0.0
    for i = 0 to nnB - 1
        float wk = math.pow(i + 1.0, rghH - 0.5)
        rSumR += wk * nz(resid[i], 0.0) * nz(resid[i], 0.0)
        rWR   += wk
    rghSig := rWR > 0.0 ? math.sqrt(rSumR / rWR) : rSd

// dispatch → per-side σ (asymmetric engine splits up/down; the rest are symmetric)
float sigUp = rSd
float sigDn = rSd
if volEng == "EWMA"
    sigUp := ewmaSig
    sigDn := ewmaSig
else if volEng == "Yang-Zhang"
    sigUp := yzSig
    sigDn := yzSig
else if volEng == "GARCH(1,1)"
    sigUp := garchSig
    sigDn := garchSig
else if volEng == "Robust MAD"
    sigUp := rMad
    sigDn := rMad
else if volEng == "Asymmetric semidev"
    sigUp := rUp
    sigDn := rDn
else if volEng == "Rough (fractional)"
    sigUp := rghSig
    sigDn := rghSig
else if volEng == "Quantile"
    sigUp := math.max(qUpR, 0.0) / math.max(bandK, 0.01)
    sigDn := math.max(-qLoR, 0.0) / math.max(bandK, 0.01)

// fat-tail multiplier (1.0 at normal kurtosis = 3)
float tailF = fatTail ? math.max(1.0, math.min(2.5, 1.0 + fatGain * (rKurt / 3.0 - 1.0))) : 1.0
sigUp := sigUp * tailF
sigDn := sigDn * tailF

// ── CONFORMAL-PID band multiplier ─────────────────────────────────────────────
// Instead of a fixed bandK, set the multiplier from the (1−αEff) empirical quantile
// of recent standardised residuals, where αEff = ACI integrator + a proportional term
// on the recent coverage error. The band then contains ≈ target% of closes on THIS
// symbol, and re-tightens through vol breaks. Scores/updates use past bars only.
bool  qrBands     = volEng == "Quantile regression"
float sigEng      = math.max((sigUp + sigDn) * 0.5, syminfo.mintick)
float alphaTarget = 1.0 - confTarget / 100.0
var array<float> cScores = array.new<float>()
var float aciAlpha = na
var float missEwma = na
aciAlpha := na(aciAlpha) ? alphaTarget : aciAlpha
missEwma := na(missEwma) ? alphaTarget : missEwma
float alphaEff = math.min(0.5, math.max(0.005, aciAlpha + confKp * (alphaTarget - missEwma)))
float confQ    = cScores.size() >= 30 ? array.percentile_linear_interpolation(cScores, (1.0 - alphaEff) * 100.0) : bandK
float kEff     = (useConf and not qrBands) ? confQ : bandK

// ── BANDS ─────────────────────────────────────────────────────────────────────
float upper = na
float lower = na
if qrBands
    float tauHi = 1.0 - alphaTarget / 2.0
    float tauLo = alphaTarget / 2.0
    upper := f_itx(f_qrEnd(effLen, tauHi, qrIters))
    lower := f_itx(f_qrEnd(effLen, tauLo, qrIters))
else
    upper := center + kEff * sigUp
    lower := center - kEff * sigDn

// conformal state update — confirmed bars only, past-only (no look-ahead)
if barstate.isconfirmed and useConf and not qrBands
    float miss = math.abs(resid) <= kEff * sigEng ? 0.0 : 1.0
    aciAlpha := math.min(0.9, math.max(0.001, aciAlpha + confGamma * (alphaTarget - miss)))
    missEwma := missEwma + confBeta * (miss - missEwma)
    cScores.push(math.abs(resid) / sigEng)
    while cScores.size() > confWin
        cScores.shift()
float coverage = (useConf and not qrBands) ? (1.0 - missEwma) : na

// regime backbone (optional) — read the external −2…+2 state and block counter-trend fades.
// Guard: only trust the source if it is actually in the −2…+2 range (so a source left at
// the default price series can't accidentally read as a strong-trend regime).
bool regValid = useRegime and not na(regSrc) and math.abs(regSrc) <= 2.5
int  regId    = regValid ? int(math.round(regSrc)) : na
bool blockU   = regGate and not na(regId) and regId >= 2      // strong up-regime → don't fade the top
bool blockL   = regGate and not na(regId) and regId <= -2     // strong down-regime → don't fade the bottom

float slopePerBar = logMode ? center * slope : slope     // approx price slope for display

// RIDE-vs-REVERT — consecutive closes beyond the band = walking the band (trend), not reverting
var int walkUp = 0
var int walkDn = 0
walkUp := srcClose > upper ? walkUp + 1 : 0
walkDn := srcClose < lower ? walkDn + 1 : 0
bool walking = walkUp >= walkBars or walkDn >= walkBars
int  walkDir = walkUp >= walkBars ? 1 : walkDn >= walkBars ? -1 : 0

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 6 — CALIBRATION STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// classes: 1 UTAG (upper tag → expect down) · 2 LTAG (lower tag → expect up)
int NCLS = 2
f_clsName(int id) => id == 1 ? "UTAG" : id == 2 ? "LTAG" : "—"
f_clsLong(int id) => id == 1 ? "Upper-band reversion" : id == 2 ? "Lower-band reversion" : "—"

type Pend
    int   cls
    int   dir
    float entry
    float atr0
    int   bidx
    float mfe
    float mae
    bool  done

type Base
    float entry
    float atr0
    int   bidx

var array<Pend> pend = array.new<Pend>()
var array<Base> bq   = array.new<Base>()
var int[]   clsN   = array.new<int>(NCLS + 1, 0)
var int[]   clsW   = array.new<int>(NCLS + 1, 0)
var float[] clsMFE = array.new<float>(NCLS + 1, 0.0)
var float[] clsMAE = array.new<float>(NCLS + 1, 0.0)
var bool[]  clsSig = array.new<bool>(NCLS + 1, false)
var int baseN = 0
var int baseWup = 0
var int baseWdn = 0
var int lastTagBar = -100000

// per-class base rate: UTAG (expects DOWN) → down-move base · LTAG (expects UP) → up-move base
f_baseP(int cls) =>
    float r = na
    if baseN > 0
        r := cls == 1 ? baseWdn / float(baseN) : cls == 2 ? baseWup / float(baseN) : na
    r

f_z(int w, int n, float p0) =>
    float r = na
    if n > 0 and not na(p0) and p0 > 0.0 and p0 < 1.0
        float phh = w / float(n)
        float se = math.sqrt(p0 * (1.0 - p0) / n)
        r := se > 0 ? (phh - p0) / se : na
    r

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 7 — BAND-TAG EVENTS (confirmed bars; only when channel is trusted)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int evtCls = 0
int evtDir = 0
if barstate.isconfirmed and trusted and (bar_index - lastTagBar) >= minGap
    if srcHigh >= upper and srcClose < upper and not blockU
        evtCls := 1
        evtDir := -1
        lastTagBar := bar_index
    else if srcLow <= lower and srcClose > lower and not blockL
        evtCls := 2
        evtDir := 1
        lastTagBar := bar_index
    if evtCls != 0 and not na(atr) and atr > 0.0
        pend.push(Pend.new(evtCls, evtDir, srcClose, atr, bar_index, 0.0, 0.0, false))

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
                clsN.set(p.cls, clsN.get(p.cls) + 1)
                if win
                    clsW.set(p.cls, clsW.get(p.cls) + 1)
                clsMFE.set(p.cls, clsMFE.get(p.cls) + p.mfe)
                clsMAE.set(p.cls, clsMAE.get(p.cls) + p.mae)
                pend.remove(i)

if barstate.isconfirmed and not na(atr) and atr > 0.0
    bq.push(Base.new(srcClose, atr, bar_index))
if barstate.isconfirmed and bq.size() > 0
    for i = bq.size() - 1 to 0
        Base b = bq.get(i)
        if bar_index - b.bidx >= horizon
            // unconditional close-to-close directional move at the same horizon
            if (srcClose - b.entry) >= moveATR * b.atr0
                baseWup += 1
            if (b.entry - srcClose) >= moveATR * b.atr0
                baseWdn += 1
            baseN += 1
            bq.remove(i)

int sigCls = 0
if barstate.isconfirmed
    for id = 1 to NCLS
        if clsN.get(id) >= 5 and not clsSig.get(id)
            float bp = f_baseP(id)
            float z = f_z(clsW.get(id), clsN.get(id), bp)
            float hit = clsW.get(id) / float(clsN.get(id))
            if not na(z) and z > 1.96 and not na(bp) and hit > bp
                clsSig.set(id, true)
                sigCls := id

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 8 — PLOTS (rolling channel) + CONE (last bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color cCenter = not trusted ? cDim : slope >= 0 ? cBull : cBear
plot_center = plot(center, "Centerline", color = color.new(cCenter, 0), linewidth = 2, style = plot.style_line)
plot_up = plot(showBands ? upper : na, "Upper", color = color.new(trusted ? cNeu : cDim, 30), linewidth = 1)
plot_lo = plot(showBands ? lower : na, "Lower", color = color.new(trusted ? cNeu : cDim, 30), linewidth = 1)
fill(plot_up, plot_lo, color = showFill and trusted ? color.new(cCenter, 72) : na, title = "Channel Fill")

// band tags
plotshape(showTags and evtCls == 1 ? srcHigh : na, "Upper Tag", shape.triangledown, location.absolute, color = cBear, size = size.tiny)
plotshape(showTags and evtCls == 2 ? srcLow  : na, "Lower Tag", shape.triangleup,   location.absolute, color = cBull, size = size.tiny)

// forecast cone (drawn on last bar only)
var polyline coneU = na
var polyline coneL = na
if barstate.islast and showCone and trusted
    polyline.delete(coneU)
    polyline.delete(coneL)
    array<chart.point> ptsU = array.new<chart.point>()
    array<chart.point> ptsL = array.new<chart.point>()
    for h = 0 to coneH
        float c  = f_itx(endV + slope * h)
        float hw = bandK * sigResid + coneGrow * sigResid * math.sqrt(h)
        ptsU.push(chart.point.from_index(bar_index + h, c + hw))
        ptsL.push(chart.point.from_index(bar_index + h, c - hw))
    coneU := polyline.new(ptsU, line_color = color.new(cCenter, 45), line_width = 1, line_style = line.style_dashed)
    coneL := polyline.new(ptsL, line_color = color.new(cCenter, 45), line_width = 1, line_style = line.style_dashed)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 9 — DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_dashPos(dashPos), 7, NCLS + 5, frame_color = cGrid, frame_width = 1, border_color = cGrid, border_width = 1)
f_cell(int c, int r, string txt, color tc, color bg, string sz) =>
    table.cell(dash, c, r, txt, text_color = tc, bgcolor = bg, text_size = sz, text_halign = text.align_center)

if showDash and barstate.islast
    string sz = "small"
    table.clear(dash, 0, 0, 6, NCLS + 4)
    f_cell(0, 0, "REGRESSION CHANNEL · " + method, cTxt, cHead, "normal")
    table.merge_cells(dash, 0, 0, 6, 0)

    color fc = trusted ? cBull : cBear
    f_cell(0, 1, "Fit " + str.tostring(fitQ * 100, "0") + "%", fc, cPanel, sz)
    table.merge_cells(dash, 0, 1, 1, 1)
    f_cell(2, 1, trusted ? "TRUSTED" : "LOW FIT", fc, cPanel, sz)
    table.merge_cells(dash, 2, 1, 3, 1)
    f_cell(4, 1, "len " + str.tostring(effLen), cNeu, cPanel, sz)
    f_cell(5, 1, "slope " + str.tostring(slopePerBar / math.max(atr, syminfo.mintick), "0.00") + "a", slopePerBar >= 0 ? cBull : cBear, cPanel, sz)
    table.merge_cells(dash, 5, 1, 6, 1)

    if dashMode == "Pro"
        f_cell(0, 2, "CLASS", cNeu, cHead, sz)
        f_cell(1, 2, "n",     cNeu, cHead, sz)
        f_cell(2, 2, "Hit%",  cNeu, cHead, sz)
        f_cell(3, 2, "Base%", cNeu, cHead, sz)
        f_cell(4, 2, "Edge",  cNeu, cHead, sz)
        f_cell(5, 2, "MFE",   cNeu, cHead, sz)
        f_cell(6, 2, "MAE",   cNeu, cHead, sz)
        for id = 1 to NCLS
            int n = clsN.get(id)
            int r = 2 + id
            if n < 5
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cNeu, cPanel, sz)
                f_cell(2, r, "·", cDim, cPanel, sz)
                f_cell(3, r, "·", cDim, cPanel, sz)
                f_cell(4, r, "warm", cDim, cPanel, sz)
                f_cell(5, r, "·", cDim, cPanel, sz)
                f_cell(6, r, "·", cDim, cPanel, sz)
            else
                float hit  = clsW.get(id) / float(n)
                float bp   = f_baseP(id)
                float edge = na(bp) ? na : hit - bp
                float z    = f_z(clsW.get(id), n, bp)
                bool  star = not na(z) and z > 1.96
                color ec   = na(edge) ? cNeu : edge > 0 ? cBull : cBear
                f_cell(0, r, f_clsName(id), cTxt, cPanel, sz)
                f_cell(1, r, str.tostring(n), cTxt, cPanel, sz)
                f_cell(2, r, str.tostring(hit * 100, "0") + "%", cTxt, cPanel, sz)
                f_cell(3, r, na(bp) ? "·" : str.tostring(bp * 100, "0") + "%", cNeu, cPanel, sz)
                f_cell(4, r, (na(edge) ? "·" : (edge >= 0 ? "+" : "") + str.tostring(edge * 100, "0") + "%") + (star ? "*" : ""), ec, cPanel, sz)
                f_cell(5, r, str.tostring(clsMFE.get(id) / n, "0.0") + "R", cBull, cPanel, sz)
                f_cell(6, r, str.tostring(clsMAE.get(id) / n, "0.0") + "R", cBear, cPanel, sz)
        f_cell(0, NCLS + 3, "eng " + volEng + (not na(coverage) ? "  ·  cov " + str.tostring(coverage * 100, "0") + "%→" + str.tostring(confTarget, "0") : "") + (useConf and not qrBands ? "  ·  k×" + str.tostring(kEff, "0.00") : "") + (useRegime and not na(regId) ? "  ·  reg " + str.tostring(regId) + ((blockU or blockL) ? "⛔" : "") : "") + (walking ? "  ·  WALK " + (walkDir > 0 ? "U" + str.tostring(walkUp) : "D" + str.tostring(walkDn)) : "") + (tailF > 1.001 ? "  ·  tail ×" + str.tostring(tailF, "0.00") : "") + "  ·  base n=" + str.tostring(baseN), cDim, cHead, sz)
        table.merge_cells(dash, 0, NCLS + 3, 6, NCLS + 3)
    else
        f_cell(0, 2, (walking ? (walkDir > 0 ? "RIDE up · walk " + str.tostring(walkUp) : "RIDE dn · walk " + str.tostring(walkDn)) : baseN == 0 ? "calibrating…" : "U " + str.tostring(clsN.get(1)) + " · L " + str.tostring(clsN.get(2))), walking ? cAcc : cTxt, cPanel, sz)
        table.merge_cells(dash, 0, 2, 6, 2)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 10 — ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(evtCls == 1, "Upper Band Tag", "Adaptive Channel: upper-band tag on {{ticker}} ({{interval}})")
alertcondition(evtCls == 2, "Lower Band Tag", "Adaptive Channel: lower-band tag on {{ticker}} ({{interval}})")
alertcondition(sigCls != 0, "Significant Edge", "Adaptive Channel: a band-tag class reached significant edge on {{ticker}}")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SECTION 11 — EXPORTS (Data Window)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float expEdge = na
if evtCls != 0 and clsN.get(evtCls) >= 5 and not na(f_baseP(evtCls))
    expEdge := (clsW.get(evtCls) / float(clsN.get(evtCls)) - f_baseP(evtCls)) * 100.0

plot(showEXP ? center : na,      "EXP_Center", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? slopePerBar : na, "EXP_Slope",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? upper : na,       "EXP_Upper",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? lower : na,       "EXP_Lower",  color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? fitQ * 100 : na,  "EXP_FitQ",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expEdge : na,     "EXP_Edge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (na(coverage) ? na : coverage * 100) : na, "EXP_Coverage", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? kEff : na,        "EXP_BandMult", color = color.new(color.gray, 100), display = display.data_window)
````

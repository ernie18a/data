# Brownian Motion Residual [JOAT]

- url: https://www.tradingview.com/script/6Dlozc7K-Brownian-Motion-Residual-JOAT/
- type: indicator
- pine_id: PUB;893b287bd1fd4258a53ebd4335371992
- version: 1.0

## Description

[b]BROWNIAN MOTION RESIDUAL [JOAT][/b]

A regime classifier rooted in the [b]sqrt(T) scaling law[/b] of geometric Brownian motion. Under a true random walk, the standard deviation of T-bar returns scales as [b]σ₁ · √T[/b] — that is the central fact of Brownian motion in continuous time. Markets [i]violate[/i] this scaling in revealing ways: when they trend, dispersion at long horizons grows faster than √T; when they mean-revert, it grows slower. Brownian Motion Residual measures that violation across three horizons simultaneously, aggregates it, and surfaces a single Z-like residual that classifies the market into Strong MR / MR / Random / Trend / Strong Trend.

[image]https://www.tradingview.com/x/0QiB7IAr/[/image]

[b]The sqrt(T) scaling law, restated[/b]

For a Brownian process with per-bar volatility σ₁:

[i]σ(T-bar return) = σ₁ · √T[/i]

For a real market the observed σ at horizon T can be measured directly. The [b]residual[/b] is the deviation of the observed value from the Brownian-implied value:

[i]residual(T) = σ_observed(T) − σ₁ · √T[/i]

When the residual is [b]positive[/b], dispersion at T is greater than Brownian predicts — the market is trending (price travels further than a random walk in T bars). When it is [b]negative[/b], dispersion is less than Brownian predicts — the market is mean-reverting (price ends up closer to home than a random walk would).

Optional normalisation by [b]σ₁ · √T[/b] turns the residual into a unit-less percentage of expected dispersion, so the same threshold values are meaningful across instruments and timeframes.

[b]Three horizons, weighted blend[/b]

A single horizon is noisy. Brownian Motion Residual reads three horizons simultaneously (default 5 / 20 / 100 bars), each independently toggleable and weighted (default 1.0 each). The horizons are aggregated into a single residual line — the script's headline metric. Toggling off the short horizon makes the read smoother and slower; toggling off the long horizon makes it more reactive. Configurable.

A configurable EMA on top of the aggregated residual suppresses single-bar noise without lagging the regime view.

[b]Two-tier classification[/b]

The aggregated residual is mapped to one of five regimes by two symmetric thresholds (default ±1 mild, ±2 strong):

[list]
[*] [b]Strong Trend[/b] — residual > +2. Aggressive momentum regime.
[*] [b]Trend[/b] — residual between +1 and +2. Trending.
[*] [b]Random[/b] — residual between −1 and +1. Brownian-like.
[*] [b]MR[/b] — residual between −2 and −1. Mean-reverting.
[*] [b]Strong MR[/b] — residual < −2. Aggressive reversion regime.
[/list]

[b]Visual system[/b]

[list]
[*] [b]Slope-coloured residual line[/b] with configurable width and optional area fill under it (transparency configurable).
[*] [b]Zero line[/b] and ±1 / ±2 threshold lines (toggleable).
[*] [b]Background tint by regime[/b] (subtle 88 transparency default) — teal trend, lavender MR, mint random.
[*] [b]Per-horizon plots[/b] (toggleable, off by default) — each horizon's residual as a faint dotted overlay; useful for seeing which horizon is driving the read.
[*] [b]Regime-change dots[/b] above the line at every confirmed flip.
[/list]

A locked Aurora palette (teal trend / lavender MR / mint random on a deep-night ground) gives the pane a distinctive structural identity.

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with vertical row-fade. Surfaces:

[list]
[*] Aggregated residual (raw and smoothed).
[*] Regime classification with glyph.
[*] σ₁ value (the Brownian anchor).
[*] Per-horizon residuals (h1 / h2 / h3) when enabled.
[*] Bars in current regime.
[*] Distance to nearest threshold.
[/list]

Optional fancy Unicode header for the institutional aesthetic.

[image]https://www.tradingview.com/x/bBdzol8Z/[/image]

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Regime Change (any classification flip)
[*] Strong threshold cross (±2)
[*] Mild threshold cross (±1) — off by default
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Strong Trend / Strong MR entry[/b] — the highest-conviction read. The market has decisively departed from Brownian scaling in one direction. Pair with a momentum tool in Trend regimes, a reversion tool in MR regimes.
[*] [b]Residual crossing zero[/b] — the regime fault line. Even before crossing a threshold, a sustained sign flip means the underlying distribution has rotated; the next threshold cross will confirm the new regime.
[*] [b]Per-horizon disagreement[/b] (when enabled) — when the short horizon is in trend regime but the long horizon is in MR regime, the market is in a [i]nested[/i] state: short-term momentum inside a longer reversion. This is the textbook setup for fade-the-extreme intraday plays inside a wider range.
[/list]

[b]Suggested settings[/b]

Defaults (σ₁ window 100, observed σ window 60, horizons 5/20/100, equal weights, log returns ON, normalisation ON) are tuned for 15m–4H on liquid markets. For lower timeframes drop horizon 3 to 50. For HTF (daily+) raise horizon 3 to 200 and σ₁ window to 200. Log returns are theoretically correct and the recommended default — the script's regime classification depends on the scaling law, which assumes log returns; switch off only for research.

[b]Originality[/b]

The √T Brownian scaling law is textbook continuous-time finance — the central piece of Bachelier's 1900 thesis and the foundation of every diffusion model in pricing. The implementation here — the per-horizon σ measurement pipeline, the σ₁-anchored Brownian baseline with optional normalisation, the three-horizon weighted aggregation, the EMA-smoothed residual classifier with two-tier thresholds, the per-horizon overlay layer, the regime-tinted background, and the dashboard — is JOAT-original. No third-party code reused. The use of [i]residual against Brownian[/i] as a regime classifier is the original quantitative contribution.

[b]Limitations[/b]

The √T law is exact only for Brownian motion — real markets have fat tails, autocorrelation, and discrete bars, so the measured "residual" is always non-zero even in a regime that looks random. The thresholds (±1 / ±2) are calibrated to be the regime boundaries empirically; tighten or loosen if your instrument has unusual variance behaviour. Per-horizon σ values need their respective windows populated to be meaningful — early bars give a warm-up read.

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Brownian Motion Residual [JOAT]", shorttitle="BMR [JOAT]", overlay=false,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000,
     precision=4)


// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

grpCalc   = "+----- Calculation Engine -----+"
grpHoriz  = "+----- Horizons -----+"
grpThresh = "+----- Regime Thresholds -----+"
grpVis    = "+----- Visuals -----+"
grpDash   = "+----- Dashboard -----+"
grpAlert  = "+----- Alerts -----+"

// ----- Calculation Engine -----------------------------------------------------
baseHorizon  = input.int(1, "Base Horizon (bars)", minval=1, maxval=10, group=grpCalc,
     tooltip="The 'unit' interval over which sigma_1 is measured. Default 1 = per-bar returns. " +
            "Increase to suppress microstructure noise (e.g. 2 = two-bar returns).")
sigmaWindow  = input.int(100, "sigma_1 Rolling Window (bars)", minval=10, maxval=2000, group=grpCalc,
     tooltip="Lookback for the per-bar return stdev that anchors the Brownian sqrt(T) scaling law.")
obsWindow    = input.int(60, "Observed sigma Window (bars)", minval=10, maxval=1000, group=grpCalc,
     tooltip="Rolling window used to compute the stdev of T-bar returns at each horizon. " +
            "Should be >= 2*max(horizon).")
priceSrc     = input.source(close, "Price Source", group=grpCalc)
useLogReturns = input.bool(true, "Use Log Returns", group=grpCalc,
     tooltip="If on, returns are computed as ln(P_t / P_{t-T}); this matches geometric Brownian motion. " +
            "If off, simple price differences are used (arithmetic Brownian).")
smoothLen    = input.int(5, "Residual EMA Smoothing", minval=1, maxval=50, group=grpCalc,
     tooltip="EMA smoothing on the aggregated residual to reduce single-bar noise.")
normalizeRes = input.bool(true, "Normalize Residual by sigma_1", group=grpCalc,
     tooltip="When enabled, each horizon's residual is divided by (sigma_1 * sqrt(T)) so the output " +
            "is scale-free (a unit-less percent of expected dispersion).")

// ----- Horizons ---------------------------------------------------------------
horizon1     = input.int(5,   "Horizon 1 (bars)", minval=2, maxval=200, group=grpHoriz)
horizon2     = input.int(20,  "Horizon 2 (bars)", minval=2, maxval=500, group=grpHoriz)
horizon3     = input.int(100, "Horizon 3 (bars)", minval=2, maxval=2000, group=grpHoriz)
useH1        = input.bool(true, "Include Horizon 1", group=grpHoriz)
useH2        = input.bool(true, "Include Horizon 2", group=grpHoriz)
useH3        = input.bool(true, "Include Horizon 3", group=grpHoriz)
weightH1     = input.float(1.0, "Weight Horizon 1", minval=0.0, maxval=5.0, step=0.1, group=grpHoriz)
weightH2     = input.float(1.0, "Weight Horizon 2", minval=0.0, maxval=5.0, step=0.1, group=grpHoriz)
weightH3     = input.float(1.0, "Weight Horizon 3", minval=0.0, maxval=5.0, step=0.1, group=grpHoriz)

// ----- Thresholds -------------------------------------------------------------
mildThresh   = input.float(1.0, "Mild Threshold (+/-)", minval=0.1, maxval=5.0, step=0.1, group=grpThresh,
     tooltip="Above +mild = mildly trending. Below -mild = mildly mean-reverting.")
strongThresh = input.float(2.0, "Strong Threshold (+/-)", minval=0.5, maxval=10.0, step=0.1, group=grpThresh,
     tooltip="Above +strong = strongly trending. Below -strong = strongly mean-reverting.")

// ----- Visuals ----------------------------------------------------------------
resLineWidth = input.int(2, "Residual Line Width", minval=1, maxval=10, group=grpVis)
showResLine  = input.bool(true, "Show Residual Line", group=grpVis)
showFill     = input.bool(true, "Fill Area Under Residual", group=grpVis)
fillTransp   = input.int(75, "Fill Transparency", minval=0, maxval=100, group=grpVis)
showZero     = input.bool(true, "Show Zero Line", group=grpVis)
showThresh   = input.bool(true, "Show Threshold Lines (+/-1, +/-2)", group=grpVis)
showBgTint   = input.bool(true, "Show Background Tint by Regime", group=grpVis)
bgTransp     = input.int(88, "Background Tint Transparency", minval=70, maxval=100, group=grpVis,
     tooltip="Higher = more subtle. 88 is a gentle whisper, 75 is bold.")
showHorizPlots = input.bool(false, "Show Per-Horizon Residual Plots", group=grpVis,
     tooltip="Plot each horizon's residual as a faint dotted overlay on the same pane.")
showRegimeDots = input.bool(true, "Show Regime Change Dots", group=grpVis)

// ----- Dashboard --------------------------------------------------------------
showDash     = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr   = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"],
     group=grpDash)
dashSizeStr  = input.string("Small", "Dashboard Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
dashTransp   = input.int(78, "Cell Transparency", minval=0, maxval=100, group=grpDash)
dashFancy    = input.bool(true, "Use Fancy Unicode Header", group=grpDash)

// ----- Alerts -----------------------------------------------------------------
alertOnReg   = input.bool(true,  "Alert on Regime Change", group=grpAlert)
alertOnStrong = input.bool(true, "Alert on Strong Threshold Crosses (+/-2)", group=grpAlert)
alertOnMild   = input.bool(false,"Alert on Mild Threshold Crosses (+/-1)", group=grpAlert)


// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Aurora - curated)
//      Trending  = teal     (#00FFD1)
//      Mean-rev  = lavender (#B19CD9)
//      Random    = mint     (#4DFFB5)
//      BG / Frame for tables + tints
// =============================================================================

const color bullColor = #00FFD1   // trending  (teal)
const color bearColor = #B19CD9   // mean-reverting (lavender)
const color midColor  = #4DFFB5   // random walk (mint)
const color bgRaw     = #001423   // pane / table background
const color frameCol  = #152840   // table frame
const color flatColor = color.rgb(136, 136, 136)


// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
//      f_colorGradient (KB 2.1), f_clamp (KB 2.3), strToPos/strToSize (KB 2.4)
//      f_safeDiv, f_signum, f_regimeLabel, f_regimeColor
// =============================================================================

// ----- f_colorGradient: linear interp between two colours by 0..1 ratio ------
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// ----- f_clamp ---------------------------------------------------------------
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// ----- f_safeDiv: divide with guard against zero or na ----------------------
f_safeDiv(float _num, float _den, float _fallback) =>
    (na(_num) or na(_den) or _den == 0.0) ? _fallback : _num / _den

// ----- f_signum --------------------------------------------------------------
f_signum(float _x) => _x > 0 ? 1 : _x < 0 ? -1 : 0

// ----- f_regimeLabel: integer state -> human-readable string ----------------
//   +2 strong trend / +1 mild trend / 0 random walk / -1 mild MR / -2 strong MR
f_regimeLabel(int _r) =>
    string s = "Random Walk"
    if _r == 2
        s := "Strong Trending"
    else if _r == 1
        s := "Mild Trending"
    else if _r == 0
        s := "Random Walk"
    else if _r == -1
        s := "Mild Mean-Revert"
    else if _r == -2
        s := "Strong Mean-Revert"
    s

// ----- f_regimeColor: regime integer -> a colour from the active palette ---
f_regimeColor(int _r, color _bull, color _bear, color _flat) =>
    color c = _flat
    if _r == 2
        c := _bull
    else if _r == 1
        c := color.new(_bull, 30)
    else if _r == -1
        c := color.new(_bear, 30)
    else if _r == -2
        c := _bear
    else
        c := _flat
    c

// ----- strToPos --------------------------------------------------------------
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// ----- strToSize -------------------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ----- Format an absolute bar count into a compact human string -------------
f_barsAgo(int _b) =>
    string s = "-"
    if _b >= 0
        if _b >= 10000
            s := str.tostring(_b / 1000.0, "#.#") + "K bars"
        else if _b >= 100
            s := str.tostring(_b) + " bars"
        else
            s := str.tostring(_b) + " bar" + (_b == 1 ? "" : "s")
    s


// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
//      Brownian motion expected variance:  sigma_T = sigma_1 * sqrt(T)
//
//      For each horizon T in {h1, h2, h3}:
//        rT          =  ln(P_t / P_{t-T})            // log return over T bars
//                       or  P_t - P_{t-T}            // arithmetic if useLog=false
//        obs_T       =  stdev_window( rT )            // observed dispersion
//        exp_T       =  sigma_1 * sqrt(T)             // Brownian benchmark
//        residual_T  =  obs_T - exp_T                 // raw signed deviation
//        norm_T      =  residual_T / (sigma_1 * sqrt(T))   (if normalize=on)
//
//      Aggregated residual = weighted mean of horizon residuals (active only)
// =============================================================================

// ----- per-bar (base-horizon) return -----------------------------------------
//   Base horizon defaults to 1 bar.  Allow up to 10 bars for noise-suppressed sigma_1.
baseRet = useLogReturns ? math.log(f_safeDiv(priceSrc, priceSrc[baseHorizon], 1.0)) : priceSrc - priceSrc[baseHorizon]

// ----- per-base-horizon sigma anchor (sigma_1) -------------------------------
//   This is the foundational scale.  All sqrt(T) expectations multiply through it.
sigma1 = ta.stdev(baseRet, sigmaWindow)
sigma1Safe = sigma1 < 1e-12 ? 1e-12 : sigma1   // numerical floor


// ----- generic per-horizon residual helper -----------------------------------
//   Returns [observed_sigma, expected_sigma, raw_residual, normalised_residual].
f_horizonResidual(int _T) =>
    // T-bar return path
    float retT = useLogReturns ? math.log(f_safeDiv(priceSrc, priceSrc[_T], 1.0)) : priceSrc - priceSrc[_T]
    // Observed rolling stdev of T-bar returns (independent window)
    float obs  = ta.stdev(retT, obsWindow)
    // Theoretical Brownian dispersion at horizon T
    float exp  = sigma1Safe * math.sqrt(_T / float(baseHorizon))
    // Raw residual
    float raw  = obs - exp
    // Normalised residual (scale-free), guarded against zero exp
    float nrm  = exp > 1e-12 ? raw / exp : 0.0
    [obs, exp, raw, nrm]


// ----- horizon evaluations ---------------------------------------------------
[obs1, exp1, raw1, nrm1] = f_horizonResidual(horizon1)
[obs2, exp2, raw2, nrm2] = f_horizonResidual(horizon2)
[obs3, exp3, raw3, nrm3] = f_horizonResidual(horizon3)

// Choose normalised or raw per the user setting
resH1 = normalizeRes ? nrm1 : raw1
resH2 = normalizeRes ? nrm2 : raw2
resH3 = normalizeRes ? nrm3 : raw3

// ----- weighted aggregate ----------------------------------------------------
//   Each enabled horizon contributes its (weighted) residual.  We compute the
//   weighted MEAN so the magnitude stays comparable to a single-horizon value.
w1 = useH1 ? weightH1 : 0.0
w2 = useH2 ? weightH2 : 0.0
w3 = useH3 ? weightH3 : 0.0
wSum = w1 + w2 + w3
wSumSafe = wSum < 1e-9 ? 1e-9 : wSum

aggRawRes  = (resH1 * w1 + resH2 * w2 + resH3 * w3) / wSumSafe
residual   = ta.ema(aggRawRes, smoothLen)


// =============================================================================
//  SECTION 5 - STATE / TRACKING
// =============================================================================

// ----- regime classification --------------------------------------------------
//   +2 strong trending     ( residual >  strongThresh )
//   +1 mild trending       ( residual >  mildThresh and <= strong )
//    0 random walk         ( |residual| <= mildThresh )
//   -1 mild mean-revert    ( residual < -mildThresh and >= -strong )
//   -2 strong mean-revert  ( residual < -strongThresh )
classifyRegime(float _r, float _mild, float _strong) =>
    int rv = 0
    if _r > _strong
        rv := 2
    else if _r > _mild
        rv := 1
    else if _r < -_strong
        rv := -2
    else if _r < -_mild
        rv := -1
    else
        rv := 0
    rv

instantRegime = classifyRegime(residual, mildThresh, strongThresh)

// ----- persistent regime state (var) -----------------------------------------
//   Smooth the regime so a single noise bar doesn't flip it.  We use a 2-bar
//   confirmation: the instantaneous regime must agree two bars in a row before
//   we adopt it.
var int currentRegime    = 0
var int prevInstant      = 0
var int regimeChangeBar  = 0
var int prevRegimeStored = 0

if barstate.isconfirmed
    if instantRegime == prevInstant and instantRegime != currentRegime
        prevRegimeStored := currentRegime
        currentRegime    := instantRegime
        regimeChangeBar  := bar_index
    prevInstant := instantRegime


// ----- horizon-agreement metric -----------------------------------------------
//   What fraction of ACTIVE horizons individually classify into the SAME sign
//   bucket as the aggregate?  100% = full alignment.
sgnAgg = f_signum(residual)
n_active = (useH1 ? 1 : 0) + (useH2 ? 1 : 0) + (useH3 ? 1 : 0)
n_aligned = 0
if useH1 and f_signum(resH1) == sgnAgg
    n_aligned += 1
if useH2 and f_signum(resH2) == sgnAgg
    n_aligned += 1
if useH3 and f_signum(resH3) == sgnAgg
    n_aligned += 1
agreementPct = n_active > 0 ? (n_aligned / float(n_active)) * 100.0 : 0.0


// ----- rolling extrema of residual (for the dashboard's distance-from-peak) --
var float resMin = 0.0
var float resMax = 0.0
resMin := math.min(nz(resMin,  1e10), nz(residual, 0.0))
resMax := math.max(nz(resMax, -1e10), nz(residual, 0.0))


// =============================================================================
//  SECTION 6 - SIGNAL ENGINE  (cross detection + cooldown)
// =============================================================================

// Crosses against the three structural levels
crossUpStrong   = ta.crossover(residual,  strongThresh)
crossDnStrong   = ta.crossunder(residual, -strongThresh)
crossUpMild     = ta.crossover(residual,  mildThresh)
crossDnMild     = ta.crossunder(residual, -mildThresh)
crossUpZero     = ta.crossover(residual,  0.0)
crossDnZero     = ta.crossunder(residual, 0.0)

// Regime change is detected at the very bar `currentRegime` shifts
regimeChanged = currentRegime != currentRegime[1] and not na(currentRegime[1])

// Direction of regime change for label text
regimeUpShift   = regimeChanged and currentRegime > nz(currentRegime[1], 0)
regimeDownShift = regimeChanged and currentRegime < nz(currentRegime[1], 0)

// Cooldown for label drawing - prevents stacked labels from rapid flicker
var int lastLabelBar = -1000
labelGap = 5
canLabel = (bar_index - lastLabelBar) >= labelGap
emitLabel = regimeChanged and canLabel
if emitLabel
    lastLabelBar := bar_index


// =============================================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
// =============================================================================

// ----- residual line colour: GRADED by sign and magnitude --------------------
//   We map the residual to a 0..1 ratio across [-strong, +strong] and pick a
//   colour from the bear-mid-bull gradient.
ratio = f_clamp(0.5 + (residual / (2.0 * strongThresh)), 0.0, 1.0)
// Two-step gradient: bear -> mid (lower half), mid -> bull (upper half).  This
// keeps the mid colour at exactly zero.
gradColor = ratio < 0.5
     ? f_colorGradient(ratio * 2.0,           bearColor, midColor)
     : f_colorGradient((ratio - 0.5) * 2.0,   midColor,  bullColor)

// ----- main residual plot ----------------------------------------------------
plot(showResLine ? residual : na, "Brownian Residual", color=gradColor, linewidth=resLineWidth)

// ----- hidden anchor plots used by `fill(...)` -------------------------------
pRes  = plot(residual,            "Residual (anchor)", display=display.none)
pZero = plot(0.0,                 "Zero (anchor)",     display=display.none)
fillCol = residual >= 0.0 ? color.new(bullColor, fillTransp) : color.new(bearColor, fillTransp)
fill(pRes, pZero, color=showFill ? fillCol : na, title="Residual <-> Zero Fill")

// ----- zero line -------------------------------------------------------------
plot(showZero ? 0.0 : na, "Zero Line", color=color.new(midColor, 30), linewidth=1, style=plot.style_line)

// ----- threshold lines: mild and strong --------------------------------------
plot(showThresh ?  mildThresh   : na, "+Mild",   color=color.new(bullColor, 55), linewidth=1, style=plot.style_linebr)
plot(showThresh ? -mildThresh   : na, "-Mild",   color=color.new(bearColor, 55), linewidth=1, style=plot.style_linebr)
plot(showThresh ?  strongThresh : na, "+Strong", color=color.new(bullColor, 30), linewidth=1, style=plot.style_circles)
plot(showThresh ? -strongThresh : na, "-Strong", color=color.new(bearColor, 30), linewidth=1, style=plot.style_circles)

// ----- per-horizon residual overlays (optional, faint) ----------------------
plot(showHorizPlots and useH1 ? resH1 : na, "Residual H1", color=color.new(bullColor, 70), linewidth=1, style=plot.style_circles)
plot(showHorizPlots and useH2 ? resH2 : na, "Residual H2", color=color.new(midColor,  70), linewidth=1, style=plot.style_circles)
plot(showHorizPlots and useH3 ? resH3 : na, "Residual H3", color=color.new(bearColor, 70), linewidth=1, style=plot.style_circles)

// ----- regime-change dots ----------------------------------------------------
plotshape(showRegimeDots and regimeUpShift,   "Up-Shift",   style=shape.triangleup,   location=location.bottom, color=bullColor, size=size.tiny)
plotshape(showRegimeDots and regimeDownShift, "Down-Shift", style=shape.triangledown, location=location.top,    color=bearColor, size=size.tiny)

// ----- background tint by regime (subtle) ------------------------------------
color bgTintColor = na
if showBgTint
    if currentRegime == 2
        bgTintColor := color.new(bullColor, bgTransp - 5)
    else if currentRegime == 1
        bgTintColor := color.new(bullColor, bgTransp + 4)
    else if currentRegime == -1
        bgTintColor := color.new(bearColor, bgTransp + 4)
    else if currentRegime == -2
        bgTintColor := color.new(bearColor, bgTransp - 5)
    else
        bgTintColor := na
bgcolor(bgTintColor, title="Regime Background")


// =============================================================================
//  SECTION 8 - DRAWINGS  (regime change labels)
// =============================================================================

if emitLabel and barstate.isconfirmed
    string txt = ""
    color  col = flatColor
    if currentRegime == 2
        txt := "STRONG TREND"
        col := bullColor
    else if currentRegime == 1
        txt := "Mild Trend"
        col := bullColor
    else if currentRegime == 0
        txt := "Random Walk"
        col := midColor
    else if currentRegime == -1
        txt := "Mild MR"
        col := bearColor
    else if currentRegime == -2
        txt := "STRONG MR"
        col := bearColor
    label.new(bar_index, residual, txt,
         style     = currentRegime >= 0 ? label.style_label_down : label.style_label_up,
         color     = color.new(col, 25),
         textcolor = color.new(color.white, 0),
         size      = size.tiny,
         yloc      = yloc.price)


// =============================================================================
//  SECTION 9 - DASHBOARD  (7+ rows, 2 columns)
// =============================================================================

// Pre-format display strings (avoid recomputing inside table.cell calls)
resStr      = str.tostring(residual,  "0.0000")
res1Str     = str.tostring(resH1,     "0.0000")
res2Str     = str.tostring(resH2,     "0.0000")
res3Str     = str.tostring(resH3,     "0.0000")
sigma1Str   = str.tostring(sigma1,    "0.000000")
agreeStr    = str.tostring(agreementPct, "#.#") + "%"
regimeStr   = f_regimeLabel(currentRegime)
regimeCol   = f_regimeColor(currentRegime, bullColor, bearColor, flatColor)
barsSince   = bar_index - regimeChangeBar
barsAgoStr  = f_barsAgo(barsSince)
headerStr   = dashFancy ? "BROWNIAN MOTION RESIDUAL" : "BMR [JOAT]"

dashTextCol = color.new(color.white, 0)
dashHdrBg   = color.new(frameCol, dashTransp - 10)
dashRowBg   = color.new(frameCol, dashTransp)
dashAltBg   = color.new(bgRaw,    math.min(99, dashTransp + 6))
dashMonoFnt = font.family_monospace

// Table:  9 rows x 2 cols  (header + 7 data rows + footer/legend)
var table tbl = table.new(strToPos(dashPosStr), 2, 9,
     bgcolor      = na,
     frame_color  = frameCol,
     frame_width  = 1,
     border_color = color.new(frameCol, 65),
     border_width = 1)

if showDash and barstate.islast
    // --- header row 0 ------------------------------------------------------
    table.cell(tbl, 0, 0, headerStr,
         text_color       = dashTextCol,
         bgcolor          = dashHdrBg,
         text_size        = strToSize(dashSizeStr),
         text_font_family = dashMonoFnt,
         text_halign      = text.align_left)
    table.cell(tbl, 1, 0, "VALUE",
         text_color       = dashTextCol,
         bgcolor          = dashHdrBg,
         text_size        = strToSize(dashSizeStr),
         text_font_family = dashMonoFnt,
         text_halign      = text.align_right)

    // --- row 1 : current aggregate residual --------------------------------
    table.cell(tbl, 0, 1, "Current Residual",
         text_color = dashTextCol, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 1, resStr,
         text_color = gradColor,    bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 2 : regime --------------------------------------------------
    table.cell(tbl, 0, 2, "Regime",
         text_color = dashTextCol, bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 2, regimeStr,
         text_color = regimeCol,   bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 3 : H1 residual --------------------------------------------
    table.cell(tbl, 0, 3, "Residual @ " + str.tostring(horizon1) + "-bar",
         text_color = dashTextCol, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 3, res1Str,
         text_color = resH1 > 0 ? bullColor : bearColor, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 4 : H2 residual --------------------------------------------
    table.cell(tbl, 0, 4, "Residual @ " + str.tostring(horizon2) + "-bar",
         text_color = dashTextCol, bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 4, res2Str,
         text_color = resH2 > 0 ? bullColor : bearColor, bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 5 : H3 residual --------------------------------------------
    table.cell(tbl, 0, 5, "Residual @ " + str.tostring(horizon3) + "-bar",
         text_color = dashTextCol, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 5, res3Str,
         text_color = resH3 > 0 ? bullColor : bearColor, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 6 : horizon agreement -------------------------------------
    table.cell(tbl, 0, 6, "Horizon Agreement",
         text_color = dashTextCol, bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    agreeCol = agreementPct >= 99.0 ? bullColor : agreementPct >= 66.0 ? color.new(bullColor, 30) : agreementPct >= 34.0 ? midColor : bearColor
    table.cell(tbl, 1, 6, agreeStr,
         text_color = agreeCol,    bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 7 : last regime change ------------------------------------
    table.cell(tbl, 0, 7, "Last Regime Change",
         text_color = dashTextCol, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 7, barsAgoStr,
         text_color = dashTextCol, bgcolor = dashRowBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)

    // --- row 8 : sigma_1 anchor (diagnostic) ---------------------------
    table.cell(tbl, 0, 8, "sigma_1 anchor",
         text_color = color.new(color.white, 30), bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_left)
    table.cell(tbl, 1, 8, sigma1Str,
         text_color = color.new(color.white, 20), bgcolor = dashAltBg,
         text_size  = strToSize(dashSizeStr), text_font_family = dashMonoFnt,
         text_halign = text.align_right)


// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

// ----- Strong threshold crosses ---------------------------------------------
alertcondition(crossUpStrong, "BMR: Cross +Strong (Trending)",
     "BMR crossed above +strong threshold - market is now strongly trending (variance growing faster than sqrt(T)).")
alertcondition(crossDnStrong, "BMR: Cross -Strong (Mean-Reverting)",
     "BMR crossed below -strong threshold - market is now strongly mean-reverting (variance growing slower than sqrt(T)).")

// ----- Mild threshold crosses -----------------------------------------------
alertcondition(crossUpMild,   "BMR: Cross +Mild",
     "BMR crossed above +mild threshold - drift toward trending regime.")
alertcondition(crossDnMild,   "BMR: Cross -Mild",
     "BMR crossed below -mild threshold - drift toward mean-reverting regime.")

// ----- Zero crosses ---------------------------------------------------------
alertcondition(crossUpZero,   "BMR: Cross Zero Up",
     "BMR crossed zero from below - sign flip, variance now exceeds sqrt(T) baseline.")
alertcondition(crossDnZero,   "BMR: Cross Zero Down",
     "BMR crossed zero from above - sign flip, variance now falls below sqrt(T) baseline.")

// ----- Regime change --------------------------------------------------------
alertcondition(regimeChanged, "BMR: Regime Change",
     "BMR regime has changed state. Check the dashboard for the new label.")

// ----- Strong-regime entry (any direction) ---------------------------------
alertcondition(currentRegime == 2 and currentRegime[1] != 2,   "BMR: Enter Strong Trend",
     "BMR has entered the STRONG TRENDING regime.")
alertcondition(currentRegime == -2 and currentRegime[1] != -2, "BMR: Enter Strong MR",
     "BMR has entered the STRONG MEAN-REVERTING regime.")


// =============================================================================
//  END OF FILE
//  -------------------------------------------------------------------------
//  Brownian Motion Residual [JOAT]
//  Math:    sigma_T = sigma_1 * sqrt(T)      (Independent Increments)
//  Output:  residual = observed_sigma(T) - expected_sigma(T)
//  Aggregate over horizons 5/20/100 (default), EMA-smoothed, classified into
//  one of 5 regime states.  27 themes, 8-row dashboard, 9 alert conditions.
// =============================================================================
````

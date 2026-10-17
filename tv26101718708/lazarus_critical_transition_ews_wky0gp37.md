# LAZARUS - Critical Transition EWS

- url: https://www.tradingview.com/script/WKy0gP37-LAZARUS-Critical-Transition-EWS/
- type: indicator
- pine_id: PUB;6936ed530f6347c49a3b840958ab10f8
- version: 4.0

## Description

[b]LAZARUS ⚡ Critical Transition EWS[/b]
[i]An Early Warning System (EWS) for detecting critical regime transitions, bifurcations, and market crashes before they fully materialize. LAZARUS monitors statistical signatures of "critical slowing down" — rising autocorrelation, variance inflation, spectral reddening, and rising skew/kurtosis — to flag when a market is approaching a tipping point.[/i]
[b]What It Does[/b]
LAZARUS synthesizes five statistical moments into a composite z-scored Early Warning Signal (EWS). It detects when a market transitions from a stable equilibrium to a critical state where small perturbations can trigger large regime shifts. The indicator operates in three distinct states with hysteresis to prevent flickering:
[list]
[*][b]Normal[/b] (Cool Blue): Market operates within statistical equilibrium. No critical transition imminent.
[*][b]Warning[/b] (Warm Orange): Early signatures of critical slowing down detected. Volatility rising, autocorrelation increasing, distribution tails fattening. Elevated probability of regime change.
[*][b]Critical[/b] (Hot Red): Multiple statistical indicators simultaneously exceed critical thresholds. System is at or near bifurcation point. High probability of abrupt trend change, breakout, or crash.
[/list]
[b]The Five Statistical Pillars[/b]
[list]
[*][b]AR(1) Autocorrelation:[/b] First-order autocorrelation of the series. Increases as systems approach critical transitions (critical slowing down causes greater memory of previous states). Detects rising persistence in price action.
[*][b]Log-Variance:[/b] Rolling window variance of returns. Flickering and variance inflation are classic precursors to regime shifts. Captures sudden volatility clustering before visible price breakdowns.
[*][b]Absolute Skewness:[/b] Measures distributional asymmetry. Rising |skew| indicates one-sided risk building (positive or negative tail risk accumulation). Reflects underlying order flow imbalance.
[*][b]Spectral Reddening:[/b] Ratio of low-pass to high-pass variance. As critical transitions approach, low-frequency components dominate (spectral power shifts to "redder" regimes), indicating slower recovery from perturbations.
[*][b]Excess Kurtosis:[/b] "Tailedness" of the return distribution. Rising kurtosis indicates increasing probability of extreme events (leptokurtosis) beyond what normal distributions predict.
[/list]
[b]Key Features[/b]
[list]
[*][b]Dual-Window Architecture:[/b] Uses a short rolling window (W, default 50) to calculate current moments, and a long reference window (R, default 250) to establish baseline statistics. All components are z-scored against historical norms for genuine anomaly detection.
[*][b]Hysteresis State Machine:[/b] Implements exit thresholds (thWarn - hyst, thCrit - hyst) below entry thresholds to prevent rapid state flickering. Once Critical, the system maintains that state until EWS drops significantly below the entry threshold.
[*][b]Trend Bias Context:[/b] Displays directional bias (▲ uptrend / ▼ downtrend) based on price versus long-term EMA. Critical signals in the direction of the prevailing trend suggest acceleration; against the trend suggest reversal/collapse.
[*][b]Flexible Pre-Processing:[/b] Choose between log returns (standard), first differences (linear trends), or HP-filtered (business cycle extraction) depending on asset characteristics.
[*][b]Composite Histogram:[/b] Visual representation of EWS intensity with gradient coloring from cool (stable) to hot (critical).
[*][b]Transition Resolution Alerts:[/b] Unique "↯ Transition" signal fires when exiting Critical state, indicating the bifurcation has resolved (either completed its move or reversed).
[/list]
[b]Inputs & Parameters[/b]
[i]Core Detection[/i]
[list]
[*]Source: Input price series (default close).
[*]Rolling window (short): 20–500 (default 50). Window for calculating current AR(1), variance, skew, kurtosis. Shorter = more responsive but noisier.
[*]Reference window (long): 100–2000 (default 250). Baseline for z-score normalization. Must be significantly longer than rolling window.
[*]Pre-processing: Select data transformation — log returns (standard for finance), first difference (raw deltas), or HP-filtered (cycle extraction).
[/list]
[i]Component Weights[/i]
[list]
[*]AR(1) weight: Contribution of autocorrelation to composite EWS.
[*]Variance weight: Contribution of log-variance.
[*]|Skew| weight: Contribution of absolute skewness.
[*]Spectral-red weight: Contribution of spectral reddening (low/high freq ratio).
[*]Kurtosis weight: Contribution of excess kurtosis.
[/list]
[i]Signal Logic[/i]
[list]
[*]Warning threshold (z): Z-score level to trigger Warning state (default 1.5σ).
[*]Critical threshold (z): Z-score level to trigger Critical state (default 2.5σ).
[*]Hysteresis band: Buffer below thresholds required to exit a state (default 0.3σ). Prevents rapid Normal→Warning→Normal flickering around threshold boundaries.
[/list]
[i]Visualization[/i]
[list]
[*]Show sub-components: Toggle visibility of individual z-scored components (z AR(1), z logVar, etc.).
[*]Gradient background: Toggle dynamic background coloring that intensifies with EWS heat.
[*]Diagnostic table: Toggle floating information panel showing current state, EWS value, component breakdowns, and trend bias.
[*]Composite histogram: Toggle column histogram visualization behind the main line.
[*]Event labels: Toggle on-chart labels for Critical entry ("⚡ CRITICAL") and Transition exit ("↯ TRANSITION").
[/list]
[b]How to Read It[/b]
[list]
[*][b]EWS Composite Line:[/b] The main oscillator plotted as a thick colored line. Values are z-scores (standard deviations from long-term mean). Above 0 = elevated statistical anomalies; below 0 = subdued/stabile.
[*][b]Color Gradient:[/b] Transitions from Cool Blue (EWS ≈ 0) through Warm Orange (approaching Warning) to Hot Red (Critical). The gradient uses the ratio EWS/thCrit to determine heat intensity.
[*][b]State Transitions:[/b]
[list]
[*]Enter Warning: EWS crosses above thWarn (1.5) from below.
[*]Enter Critical: EWS crosses above thCrit (2.5) OR crosses from Warning above thCrit.
[*]Exit Critical: EWS drops below (thCrit - hyst) = 2.2.
[*]Exit Warning: EWS drops below (thWarn - hyst) = 1.2.
[/list]
[*][b]Trend Bias Indicator:[/b] Shown in diagnostic table as ▲ (uptrend) or ▼ (downtrend) based on price relative to long-term EMA. Contextualizes whether critical signals suggest trend acceleration or imminent reversal.
[*][b]Sub-Component Lines:[/b] Thin semi-transparent lines showing individual z-scores. Divergences between components (e.g., variance rising while AR(1) flat) indicate specific types of regime stress.
[/list]
[b]Signal Types & Alerts[/b]
[list]
[*][b]⚠ Warning (Alert):[/b] Early-warning threshold crossed. Regime instability rising. First indication that system dynamics are shifting. Consider reducing position size or tightening stops.
[*][b]⚡ Critical (Alert + Label):[/b] All EWS indicators elevated simultaneously. Phase transition imminent or underway. High conviction for significant move. Label appears below bar in red.
[*][b]↯ Transition (Alert + Label):[/b] Exiting Critical state. The bifurcation has resolved — either the move completed, the system settled into a new regime, or the crisis passed without materializing. Label appears above bar in ice blue.
[*][b]State Persistence Counter:[/b] Internal counter tracks consecutive bars in current state. Longer duration in Critical increases probability of sustained regime change vs. temporary spike.
[/list]
[b]Practical Usage Guidelines[/b]
[i]Regime Change Anticipation[/i]
[list]
[*]Enter Warning state: Reduce leverage, tighten stop-losses, prepare for volatility expansion. Do not yet assume direction (could be crash or explosive breakout).
[*]Enter Critical state: Consider directional positions in the direction of trend bias (▲ = long volatility/breakout continuation, ▼ = short/reversal). Or exit all positions if uncertainty is unacceptable.
[*]Exit Critical state (Transition signal): Reassess the new regime. If price moved significantly during Critical phase, this may mark the end of the move (take profit). If price did not move, it may indicate a "false alarm" or aborted transition.
[/list]
[i]Risk Management[/i]
[list]
[*]Use Critical signals as automatic trading halts for mean-reversion strategies (critical transitions destroy MR edge).
[*]Use Warning signals to reduce Kelly criterion / position sizing by 50% or more.
[*]Combine with trend-following systems: LAZARUS Critical + Trend Bias ▲ = high-conviction long continuation. LAZARUS Critical + Trend Bias ▼ = imminent collapse signal.
[/list]
[i]Asset-Specific Calibration[/i]
[list]
[*]High-volatility crypto: Lower thresholds (Warn 1.2, Crit 2.0) to catch earlier signals in naturally noisy data.
[*]Low-volatility forex/indices: Raise thresholds (Warn 1.8, Crit 3.0) to avoid false positives from normal market drift.
[*]First-difference mode: Use for non-stationary series with strong linear trends (certain commodities).
[*]HP-filtered mode: Use for removing business cycle effects in equity indices when looking for crashes specific to short-term dynamics.
[/list]
[b]Important Notes[/b]
[list]
[*][b]Critical Slowing Down Theory:[/b] This indicator is grounded in dynamical systems theory. As systems approach bifurcation points (tipping points), they exhibit slower recovery from perturbations, causing increased autocorrelation and variance, and shifting spectral power to lower frequencies. LAZARUS detects these pre-cursor patterns statistically.
[*][b]Z-Score Calculation:[/b] All components are normalized against the long reference window (R), not the short window. This means the indicator asks: "Are current statistical properties anomalous compared to the last 250 bars?" rather than "Are they high in absolute terms?"
[*][b]Hysteresis Necessity:[/b] Without the hysteresis band (default 0.3σ), markets hovering near 1.5σ would flicker between Normal and Warning every tick, creating alert spam. The state machine requires EWS to drop 0.3σ below the entry threshold to exit, ensuring stable state classification.
[*][b]Log Variance Guard:[/b] Variance calculations use max(variance, 1e-12) to prevent log(0) errors in flat markets. If 10+ consecutive bars have identical prices, variance floor prevents crash.
[*][b]AR(1) Interpretation:[/b] In efficient markets, AR(1) ≈ 0 (no serial correlation). As AR(1) rises toward 1.0, the market "remembers" its previous moves increasingly — a mathematical signature of approaching criticality (slowing down).
[*][b]Spectral Reddening Mechanics:[/b] The script separates the signal into low-pass (EMA-smoothed) and high-pass (residual) components. As critical transitions approach, the low-pass component captures increasingly more variance relative to high-pass, indicating the system is dominated by slow-moving forces rather than fast noise.
[*][b]No Repainting:[/b] Uses confirmed close prices and barstate-based calculations. The "bars in state" counter tracks historical persistence accurately.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NotLazyBear

//@version=5
indicator("LAZARUS ⚡ Bidirectional Critical Transition EWS v5",
     shorttitle    = "LAZARUS-BI-v5",
     overlay       = false,
     precision     = 3,
     max_bars_back = 2000)

// ══ INPUTS ═══════════════════════════════════════════════════════════════
gCore = "◆ Core Detection"
src    = input.source(close, "Source",                                       group=gCore)
W      = input.int(50,  "Rolling window (short)",  minval=20,  maxval=500,   group=gCore,
     tooltip="Window for rolling moments (AR1, variance, skew, kurtosis).")
R      = input.int(250, "Reference window (long)", minval=100, maxval=2000,  group=gCore,
     tooltip="Baseline window for z-normalizing the short-window statistics.")
dtMode = input.string("log returns", "Pre-processing",
     options=["log returns", "first difference", "HP-filtered"],             group=gCore)

gW = "◆ Component Weights"
w_ar  = input.float(1.0, "AR(1) weight",         minval=0, step=0.1, group=gW)
w_var = input.float(1.0, "Variance weight",      minval=0, step=0.1, group=gW)
w_sk  = input.float(0.7, "|Skew| weight",        minval=0, step=0.1, group=gW)
w_red = input.float(1.0, "Spectral-red weight",  minval=0, step=0.1, group=gW)
w_kur = input.float(0.8, "Kurtosis weight",      minval=0, step=0.1, group=gW)
w_vov = input.float(1.0, "Vol-of-Vol weight",    minval=0, step=0.1, group=gW,
     tooltip="Rolling std-dev of volatility. Detects turbulence clustering.")
w_dd  = input.float(0.8, "Drawdown intensity",   minval=0, step=0.1, group=gW,
     tooltip="Depth below recent rolling maximum. Detects stress accumulation.")
w_mom = input.float(0.9, "Momentum divergence",  minval=0, step=0.1, group=gW,
     tooltip="Rate-of-change of raw composite. Detects accelerating/decelerating regimes.")

gS = "◆ Signal Logic"
thWarn = input.float(1.5, "Warning threshold  (z)", step=0.1, group=gS)
thCrit = input.float(2.5, "Critical threshold (z)", step=0.1, group=gS)
hyst   = input.float(0.3, "Hysteresis band",        minval=0, step=0.05, group=gS)
conf   = input.int(1,    "Confirm bars",           minval=1, maxval=5,   group=gS,
     tooltip="Consecutive bars required in a zone before state upgrades to Warning/Critical.")

gV = "◆ Visualization"
showSub  = input.bool(true, "Show sub-components",  group=gV)
showBG   = input.bool(true, "Gradient background",  group=gV)
showTbl  = input.bool(true, "Diagnostic table",     group=gV)
showHist = input.bool(true, "Composite histogram",  group=gV)
showLbls = input.bool(true, "Event labels",         group=gV)
showAgree= input.bool(true, "Show agreement %",     group=gV)

// ══ PRE-PROCESSING ═══════════════════════════════════════════════════════
x = switch dtMode
    "log returns"      => math.log(math.max(src,  1e-12)) - math.log(math.max(nz(src[1]), 1e-12))
    "first difference" => src - nz(src[1])
    "HP-filtered"      => src - ta.sma(src, W)
    =>                    math.log(math.max(src, 1e-12)) - math.log(math.max(nz(src[1]), 1e-12))

mu   = ta.sma(x, W)
varW = ta.variance(x, W)
sdW  = math.sqrt(math.max(varW, 1e-12))

ar1 = ta.correlation(x, nz(x[1]), W)

// ══ MOMENTS (manual loop for exact rolling m3/m4) ════════════════════════
m3 = 0.0
m4 = 0.0
for i = 0 to W - 1
    d  = nz(x[i]) - mu
    d2 = d * d
    m3 := m3 + d * d2
    m4 := m4 + d2 * d2
m3 := m3 / W
m4 := m4 / W
skew = sdW > 0 ? m3 / math.pow(sdW, 3) : 0.0
kurtRaw = sdW > 0 ? m4 / math.pow(sdW, 4) - 3.0 : 0.0
kurt = kurtRaw > 5.0 ? 5.0 : kurtRaw < -5.0 ? -5.0 : kurtRaw   // v5: bounded excess kurtosis

// ══ SPECTRAL REDNESS (regularized, no nested math.max) ═══════════════════
kLP_raw = math.round(W / 10.0)
kLP = kLP_raw < 3 ? 3 : int(kLP_raw)
xLP = ta.ema(x, kLP)
xHP = x - xLP
vLP = ta.variance(xLP, W)
vHP = ta.variance(xHP, W)
redNum = vLP + 1e-6
redDen = vHP + 1e-6
red = math.log(redNum / redDen)
red := red > 3.0 ? 3.0 : red < -3.0 ? -3.0 : red               // v5: clipped to prevent blow-ups

// ══ NEW COMPONENTS v5 ══════════════════════════════════════════════════════
// Vol-of-Vol: rolling std-dev of realized volatility
volW = math.sqrt(math.max(varW, 1e-12))
vol_of_vol = ta.stdev(volW, W)

// Drawdown Intensity: depth below rolling 2W maximum
rollMax = ta.highest(src, W * 2)
drawdown = (src - rollMax) / (rollMax < 1e-12 ? 1e-12 : rollMax)
dd_intensity = -drawdown

// ══ Z-SCORE NORMALIZATION ══════════════════════════════════════════════════
fZ(float v, int r) =>
    m = ta.sma(v, r)
    s = ta.stdev(v, r)
    s > 0 ? (v - m) / s : 0.0

z_ar  = fZ(ar1,                                      R)
z_var = fZ(math.log(math.max(varW, 1e-12)),          R)
z_sk  = fZ(math.abs(skew),                           R)
z_kur = fZ(kurt,                                     R)
z_red = fZ(red,                                      R)
z_vov = fZ(vol_of_vol,                               R)
z_dd  = fZ(dd_intensity,                             R)

// Momentum Divergence: rate-of-change of raw composite before final normalization
ws2_part = w_ar*w_ar + w_var*w_var + w_sk*w_sk + w_red*w_red + w_kur*w_kur + w_vov*w_vov + w_dd*w_dd
wn_part  = math.sqrt(math.max(ws2_part, 1e-12))
raw_ews  = (w_ar*z_ar + w_var*z_var + w_sk*z_sk + w_red*z_red + w_kur*z_kur + w_vov*z_vov + w_dd*z_dd) / wn_part

mom_div = raw_ews - nz(raw_ews[1])
z_mom   = fZ(mom_div, R)

// ══ COMPOSITE EWS (v5: final composite itself is z-scored over R) ════════
ws2 = w_ar*w_ar + w_var*w_var + w_sk*w_sk + w_red*w_red + w_kur*w_kur + w_vov*w_vov + w_dd*w_dd + w_mom*w_mom
wn  = math.sqrt(math.max(ws2, 1e-12))
ews_raw = (w_ar*z_ar + w_var*z_var + w_sk*z_sk + w_red*z_red + w_kur*z_kur + w_vov*z_vov + w_dd*z_dd + w_mom*z_mom) / wn

// KEY v5 improvement: normalize the composite to ensure standard-normal behaviour
m_ews = ta.sma(ews_raw, R)
s_ews = ta.stdev(ews_raw, R)
ews   = s_ews > 0 ? (ews_raw - m_ews) / s_ews : 0.0

ewsS = ta.ema(ews, 3)

// ══ COMPONENT AGREEMENT SCORE ════════════════════════════════════════════
sign_ar  = math.sign(z_ar)
sign_var = math.sign(z_var)
sign_sk  = math.sign(z_sk)
sign_kur = math.sign(z_kur)
sign_red = math.sign(z_red)
sign_vov = math.sign(z_vov)
sign_dd  = math.sign(z_dd)
sign_mom = math.sign(z_mom)
sign_ews = math.sign(ewsS)

agreeCount = 0
agreeCount := sign_ews ==  0 ? 4 : 0
agreeCount := sign_ews !=  0 and sign_ar  == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_var == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_sk  == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_kur == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_red == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_vov == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_dd  == sign_ews ? agreeCount + 1 : agreeCount
agreeCount := sign_ews !=  0 and sign_mom == sign_ews ? agreeCount + 1 : agreeCount
agreement  = sign_ews == 0 ? 0.5 : agreeCount / 8.0

// ══ BIDIRECTIONAL STATE MACHINE (v5: consecutive-bar confirmation) ═══════
// States: 0=Normal, 1=WarningUp, 2=CriticalUp, -1=WarningDown, -2=CriticalDown
var int state  = 0
var int barsIn = 0

// Confirmation counters (consecutive bars in each zone)
var int cnt_crit_up = 0
var int cnt_crit_dn = 0
var int cnt_warn_up = 0
var int warn_dn_cnt = 0

exitWarn    = thWarn - hyst
exitCrit    = thCrit - hyst
exitWarnNeg = -thWarn + hyst
exitCritNeg = -thCrit + hyst

prev = state

// Update confirmation counters
if ewsS >= thCrit
    cnt_crit_up := cnt_crit_up + 1
else
    cnt_crit_up := 0

if ewsS <= -thCrit
    cnt_crit_dn := cnt_crit_dn + 1
else
    cnt_crit_dn := 0

if ewsS >= thWarn
    cnt_warn_up := cnt_warn_up + 1
else
    cnt_warn_up := 0

if ewsS <= -thWarn
    warn_dn_cnt := warn_dn_cnt + 1
else
    warn_dn_cnt := 0

// State transition logic with confirmation requirement
if prev == 2
    state := ewsS >= exitCrit ? 2 : (ewsS >= exitWarn ? 1 : 0)
else if prev == -2
    state := ewsS <= exitCritNeg ? -2 : (ewsS <= exitWarnNeg ? -1 : 0)
else if prev == 1
    state := (ewsS >= thCrit and cnt_crit_up >= conf) ? 2 : (ewsS >= exitWarn ? 1 : 0)
else if prev == -1
    state := (ewsS <= -thCrit and cnt_crit_dn >= conf) ? -2 : (ewsS <= exitWarnNeg ? -1 : 0)
else
    // prev == 0
    if ewsS >= thCrit and cnt_crit_up >= conf
        state := 2
    else if ewsS <= -thCrit and cnt_crit_dn >= conf
        state := -2
    else if ewsS >= thWarn and cnt_warn_up >= conf
        state := 1
    else if ewsS <= -thWarn and warn_dn_cnt >= conf
        state := -1
    else
        state := 0

barsIn := state == prev ? barsIn + 1 : 0

// Event triggers
enterWarnUp   = state == 1  and prev != 1
enterWarnDown = state == -1 and prev != -1
enterCritUp   = state == 2  and prev != 2
enterCritDown = state == -2 and prev != -2
exitCritUp    = prev == 2   and state != 2
exitCritDown  = prev == -2  and state != -2

// Trend context (market bias, independent of EWS direction)
trendBias = ta.ema(src, math.max(2, R / 2))
isUptrend = src > trendBias
biasStr   = isUptrend ? "▲" : "▼"

// Direction strings for EWS
dirStr    = state > 0 ? "▲" : state < 0 ? "▼" : "•"
dirStrInv = state > 0 ? "▼" : state < 0 ? "▲" : "•"

// ══ COLOR SCHEME ═════════════════════════════════════════════════════════
cHotUp    = color.rgb(255, 60,  70)
cWarmUp   = color.rgb(255, 176, 59)
cCool     = color.rgb(80,  140, 255)
cWarmDown = color.rgb(120, 200, 255)
cHotDown  = color.rgb(80,  220, 250)

heat = math.min(math.max(math.abs(ewsS) / thCrit, 0), 1.5)

stateCol = state == 2 ? cHotUp : state == 1 ? cWarmUp : state == -1 ? cWarmDown : state == -2 ? cHotDown : cCool

compCol = ewsS >= 0 ? color.from_gradient(heat, 0, 1.5, cCool, cHotUp) : color.from_gradient(heat, 0, 1.5, cCool, cHotDown)

bgAlpha = 92 - math.round(heat * 25)
bgCol   = state == 2 ? color.new(cHotUp, bgAlpha) : state == 1 ? color.new(cWarmUp, bgAlpha) : state == -1 ? color.new(cWarmDown, bgAlpha) : state == -2 ? color.new(cHotDown, bgAlpha) : na

// ══ PLOTS ════════════════════════════════════════════════════════════════
plot(showSub ? z_ar  : na, "z AR(1)",   color=color.new(color.teal,    55))
plot(showSub ? z_var : na, "z logVar",  color=color.new(color.yellow,  55))
plot(showSub ? z_sk  : na, "z |Skew|",  color=color.new(color.fuchsia, 55))
plot(showSub ? z_red : na, "z Red",     color=color.new(color.aqua,    55))
plot(showSub ? z_kur : na, "z Kurt",    color=color.new(color.orange,  55))
plot(showSub ? z_vov : na, "z VolVol",  color=color.new(color.lime,    55))
plot(showSub ? z_dd  : na, "z DD",      color=color.new(color.maroon,  55))
plot(showSub ? z_mom : na, "z MomDiv",  color=color.new(color.purple,  55))

plot(showHist ? ewsS : na, "EWS histogram", color=color.new(stateCol, 60),
     style=plot.style_columns)
plot(ewsS, "EWS Composite", color=compCol, linewidth=3)

hline(0,        "Zero",      color=color.new(color.gray, 70))
hline(thWarn,   "Warn +",    color=color.new(cWarmUp,  30), linestyle=hline.style_dashed)
hline(thCrit,   "Crit +",    color=color.new(cHotUp,   10), linestyle=hline.style_dashed)
hline(-thWarn,  "Warn -",    color=color.new(cWarmDown,30), linestyle=hline.style_dashed)
hline(-thCrit,  "Crit -",    color=color.new(cHotDown, 10), linestyle=hline.style_dashed)

bgcolor(showBG ? bgCol : na)

// Agreement plot
plot(showAgree ? agreement : na, "Agreement", color=color.new(color.gray, 70), style=plot.style_area)

// Labels
if showLbls and enterCritUp
    label.new(bar_index, ewsS, "⚡ CRITICAL " + dirStr,
         color=color.new(cHotUp, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small)
if showLbls and enterCritDown
    label.new(bar_index, ewsS, "⚡ CRITICAL " + dirStr,
         color=color.new(cHotDown, 0), textcolor=color.black,
         style=label.style_label_up, size=size.small)
if showLbls and exitCritUp
    label.new(bar_index, ewsS, "↯ TRANSITION " + dirStrInv,
         color=color.new(cWarmUp, 0), textcolor=color.black,
         style=label.style_label_down, size=size.small)
if showLbls and exitCritDown
    label.new(bar_index, ewsS, "↯ TRANSITION " + dirStrInv,
         color=color.new(cWarmDown, 0), textcolor=color.black,
         style=label.style_label_up, size=size.small)

// ══ DIAGNOSTIC TABLE ═════════════════════════════════════════════════════
f_row(table tbl, int r, string lbl, float v, color col, string fmt) =>
    table.cell(tbl, 0, r, lbl,
         text_color=color.new(color.white,20), text_size=size.small,
         bgcolor=color.new(color.black,60))
    table.cell(tbl, 1, r, str.tostring(v, fmt),
         text_color=col, text_size=size.small,
         bgcolor=color.new(color.black,60))

if showTbl and barstate.islast
    var table t = table.new(position.top_right, 2, 10,
         bgcolor=color.new(color.black, 75),
         border_color=color.new(color.gray, 60), border_width=1,
         frame_color=color.new(color.silver, 30), frame_width=1)

    stateStr = state == 2 ? "⚡ CRITICAL " + dirStr : state == 1 ? "⚠ WARNING " + dirStr : state == -1 ? "⚠ WARNING " + dirStr : state == -2 ? "⚡ CRITICAL " + dirStr : "• NORMAL"
    table.cell(t, 0, 0, "LAZARUS-BI-v5",
         text_color=color.white, text_size=size.normal, bgcolor=color.new(stateCol, 40))
    table.cell(t, 1, 0, stateStr,
         text_color=color.white, text_size=size.normal, bgcolor=color.new(stateCol,30))

    f_row(t, 1, "EWS",         ewsS,  compCol,       "#.###")
    f_row(t, 2, "z AR(1)",     z_ar,  color.teal,    "#.##")
    f_row(t, 3, "z log-Var",   z_var, color.yellow,  "#.##")
    f_row(t, 4, "z |Skew|",    z_sk,  color.fuchsia, "#.##")
    f_row(t, 5, "z Red",       z_red, color.aqua,    "#.##")
    f_row(t, 6, "z Kurt",      z_kur, color.orange,  "#.##")
    f_row(t, 7, "z VolVol",    z_vov, color.lime,    "#.##")
    f_row(t, 8, "Agreement",   agreement, color.gray, "#.##")

    table.cell(t, 0, 9, "Trend Bias",
         text_color=color.new(color.white,20), text_size=size.small,
         bgcolor=color.new(color.black,60))
    table.cell(t, 1, 9, biasStr + " " + (isUptrend ? "up" : "dn"),
         text_color = isUptrend ? color.lime : color.red, text_size=size.small,
         bgcolor=color.new(color.black,60))

// ══ ALERTS ═══════════════════════════════════════════════════════════════
alertcondition(enterWarnUp,   "LAZARUS ⚠ Warning Up",
     "LAZARUS: Early-warning UP signal activated. Positive regime instability rising.")
alertcondition(enterWarnDown, "LAZARUS ⚠ Warning Down",
     "LAZARUS: Early-warning DOWN signal activated. Negative regime instability rising.")
alertcondition(enterCritUp,   "LAZARUS ⚡ Critical Up",
     "LAZARUS: CRITICAL UP — all EWS indicators elevated, positive phase transition imminent.")
alertcondition(enterCritDown, "LAZARUS ⚡ Critical Down",
     "LAZARUS: CRITICAL DOWN — all EWS indicators depressed, negative phase transition imminent.")
alertcondition(exitCritUp,    "LAZARUS ↯ Transition Up",
     "LAZARUS: Positive regime transition has occurred. Reassess trend and regime classifier.")
alertcondition(exitCritDown,   "LAZARUS ↯ Transition Down",
     "LAZARUS: Negative regime transition has occurred. Reassess trend and regime classifier.")
````

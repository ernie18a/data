# AetherEdge - Gaussian Mixture Regimes

- url: https://www.tradingview.com/script/DS6facyY/
- type: indicator
- pine_id: PUB;b44588361f154880b734a7048d9ee8ef
- version: 1.0

## Description

🖊️ Overview

AE-GMM is a self-evolving regime detector that treats the market as a probability distribution rather than carving it up with rigid rules. It models the joint distribution of momentum × volatility as a mixture of K Gaussian components — one per regime — and keeps learning their means, variances, and weights through online Expectation-Maximization with forgetting. Every bar receives a soft probability vector (a posterior) over regimes, rendered as a flowing probability ribbon that lets the market's state blend and shift before your eyes.

🔶 Key Features

Gaussian mixture + online EM engine — the E-step (responsibilities) and M-step (sufficient statistics) run every bar, estimating the regime distribution incrementally.
Self-evolving forgetting mechanism — a forgetting factor λ weights recent data, so the model quietly reshapes itself as regimes emerge and dissolve.
Soft probability ribbon — the K regime probabilities, stacked into a flow in the lower pane; not hard boundaries, but "how much of each regime is present now."
Semantic regime coloring — each component is auto-colored by the character of its learned centroid (Risk-On / Range / Risk-Off / Stress), sidestepping the label-switching problem.
Projection onto price — force_overlay tints the main chart's background by the dominant regime, deepening with confidence.
Live statistics panel — dominant regime, confidence, per-regime probabilities, regime duration, the adaptation factor λ, and model fit (log-likelihood).
Diagonal-covariance robustness — no matrix inversion, numerically stable; learning on confirmed bars only, with no look-ahead.

🧠 Technical Architecture

The feature space is two-dimensional — a momentum axis (z-scored ATR-unit trend deviation) and a volatility axis (z-scored log realized-volatility). Each component is a diagonal-covariance Gaussian with mean μ_k, variance σ²_k, and weight π_k. Every bar, responsibilities (posteriors) are computed as γ_k(x) = π_k·N(x|μ_k,σ²_k) / Σ_j π_j·N(x|μ_j,σ²_j), normalized stably via log-sum-exp in the log domain.
Learning proceeds by incremental EM. On each confirmed bar, the sufficient statistics (responsibility mass N_k, Σγx, Σγx²) are updated with a forgetting factor λ, and π_k, μ_k, σ²_k are re-derived from them. Lower λ weights recent data and adapts quickly; higher λ acts as longer memory and stays steady. Components are initialized spread around a ring in feature space, starting from diverse regimes and migrating toward the data. Each regime's color is decided every bar from its learned centroid (high volatility → Stress; positive momentum → Risk-On; negative → Risk-Off; in between → Range).

🎯 Three design choices stand out. First, soft responsibilities let regime transitions be expressed as a blend of probabilities — the "in-between" is visible. Second, character-based coloring keeps colors meaningful regardless of index shuffling. Third, confining parameter updates to confirmed bars — with only the forming bar's posterior updating live — keeps historical output non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): K = 3, λ = 0.99, standardization length 200, vol length 20; Risk-On / Range / Stress separate cleanly. High-volatility names (SOL, XRP): lower λ toward 0.97 for faster adaptation, and set K = 4 to split Stress into upside vs downside stress, revealing the internal structure of rough action.
Per parameter: λ (adaptation) is the key knob — near 0.999 regimes are smooth and persistent; near 0.95 they switch nimbly. K (regimes) ranges from 2 (on/off) to 4 (finer states). Standardization length sets the feature baseline window — longer is steadier, shorter more locally adaptive. Stress Vol (z) sets how much of a volatility rise counts as "Stress."

💡 How to Use in Practice

The core read is dominant regime × confidence. When the ribbon is thick in a single color (high confidence) and stable, strategies aligned with that regime tend to work (trend-following in Risk-On, fading in Range). When ribbon colors blend, it signals a regime transition — a cue to cut size or stand aside. When the Stress (amber) probability rises, volatility is expanding — useful for staging breakouts or de-risking.
For multi-timeframe work, read the higher-timeframe regime for the backdrop and execute on a lower timeframe. With the price-chart background tint enabled, regime "epochs" sit directly over the candles, making context easy to combine with trend or volume tools.

⚠️ Important Notes

Regimes are hidden until the warmup period (default 200 bars) completes. Reloading the indicator, or changing settings, makes the model relearn across the entire history from scratch — learning state is not persisted. This is a diagonal-covariance approximation and does not explicitly model correlation between features. Regime probabilities are the model's probabilistic beliefs, not certain forecasts. Parameters update on confirmed bars, while the forming bar's probabilities move live.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Gaussian Mixture Regimes   ( AE-GMM )
// ----------------------------------------------------------------------------
//  A self-evolving probabilistic regime detector. Instead of slicing the market
//  with hard rules, it models the joint distribution of (momentum, volatility)
//  as a MIXTURE of K Gaussian components - one per market "regime" - and learns
//  their means, variances and weights ONLINE via incremental Expectation-
//  Maximization with exponential forgetting:
//      E-step:  responsibility  g_k(x) = pi_k N(x|mu_k,S_k) / sum_j pi_j N(...)
//      M-step:  decayed sufficient statistics  ->  pi_k, mu_k, S_k   adapt
//  Every bar receives a SOFT probability over regimes (a posterior), shown as a
//  stacked probability ribbon. The forgetting factor lets the model continuously
//  reshape itself as regimes appear and dissolve. Diagonal covariance keeps it
//  numerically robust; learning happens on confirmed bars only (no look-ahead).
// ============================================================================
indicator("AetherEdge - Gaussian Mixture Regimes", "AE-GMM", overlay = false, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Mixture model ---
var string gMM = "Mixture Model"
K        = input.int(3,    "Regimes (K)",        minval = 2, maxval = 4, group = gMM, tooltip = "Number of Gaussian components / market regimes.")
lambda   = input.float(0.99, "Adaptation (lambda)", minval = 0.90, maxval = 0.999, step = 0.001, group = gMM, tooltip = "Forgetting factor of the online EM. Lower = adapts faster to new regimes; higher = longer, steadier memory.")
varFloor = input.float(0.08, "Variance Floor",    minval = 0.01, maxval = 0.50, step = 0.01, group = gMM, tooltip = "Minimum component variance (prevents collapse onto single points).")

//  --- Features ---
var string gFE = "Features"
zLen   = input.int(200, "Standardization Length", minval = 20, group = gFE, tooltip = "Rolling window used to z-score the features.")
emaLen = input.int(50,  "Trend EMA Length", minval = 5, group = gFE)
atrLen = input.int(14,  "ATR Length",       minval = 2, group = gFE)
volLen = input.int(20,  "Volatility Length", minval = 2, group = gFE, tooltip = "Window for realized volatility (stdev of returns).")

//  --- Regime character ---
var string gCH = "Regime Character"
volStressZ = input.float(0.50, "Stress Vol (z)",     minval = 0.0, step = 0.05, group = gCH, tooltip = "A component whose mean volatility exceeds this (in z-units) is labeled a Stress regime.")
dirZ       = input.float(0.25, "Direction (z)",      minval = 0.0, step = 0.05, group = gCH, tooltip = "Mean-momentum magnitude separating Risk-On / Range / Risk-Off.")

//  --- Display ---
var string gDS = "Display"
warmup     = input.int(200, "Warmup Bars", minval = 50, group = gDS)
bullCol    = input.color(#26ffe6, "Risk-On",  group = gDS)
bearCol    = input.color(#ff2e88, "Risk-Off", group = gDS)
neutCol    = input.color(#8892b0, "Range",    group = gDS)
stressCol  = input.color(#ffae57, "Stress",   group = gDS)
ribT       = input.int(18, "Ribbon Transparency", minval = 0, maxval = 90, group = gDS)
showTint   = input.bool(true,  "Price Background Tint", group = gDS, tooltip = "Tints the MAIN price chart by the dominant regime (force_overlay).")
showBars   = input.bool(true,  "Color Bars by Regime",  group = gDS)
showDash   = input.bool(true,  "Dashboard", group = gDS)
dashPos    = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDS)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
EPS    = 1e-10
LOG2PI = math.log(2.0 * math.pi)

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

// Character of a regime from its learned mean (momentum, volatility), in z-units
f_char(float mr, float mv) => mv > volStressZ ? stressCol : mr > dirZ ? bullCol : mr < -dirZ ? bearCol : neutCol
f_glyph(float mr, float mv) => mv > volStressZ ? "✸" : mr > dirZ ? "▲" : mr < -dirZ ? "▼" : "◆"
f_lab(float mr, float mv) => mv > volStressZ ? "STRESS" : mr > dirZ ? "RISK-ON" : mr < -dirZ ? "RISK-OFF" : "RANGE"

// ----------------------------------------------------------------------------
//  FEATURES  ( x0 = momentum axis, x1 = volatility axis ; both z-scored )
// ----------------------------------------------------------------------------
ret      = math.log(close / close[1])
trendDev = (close - ta.ema(close, emaLen)) / (ta.atr(atrLen) + EPS)
x0 = f_clip((trendDev - ta.sma(trendDev, zLen)) / (ta.stdev(trendDev, zLen) + EPS), -4.0, 4.0)
rv  = ta.stdev(ret, volLen)
lrv = math.log(rv + EPS)
x1 = f_clip((lrv - ta.sma(lrv, zLen)) / (ta.stdev(lrv, zLen) + EPS), -4.0, 4.0)

ready  = bar_index > math.max(math.max(zLen, emaLen), math.max(atrLen, volLen)) + 2 and not na(x0) and not na(x1)
active = ready and bar_index > warmup

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  ( online EM sufficient statistics )
// ----------------------------------------------------------------------------
var matrix<float> M1 = matrix.new<float>(K, 2, 0.0)   // decayed sum of g*x   (per dim)
var matrix<float> M2 = matrix.new<float>(K, 2, 0.0)   // decayed sum of g*x^2 (per dim)
var array<float>  Nk = array.new<float>(K, 0.0)       // decayed responsibility mass
var array<float>  gamma = array.new<float>(K, 0.0)    // current responsibilities (posterior)
var array<color>  regCol = array.new<color>(4, color.new(#8892b0, 0))
var array<float>  muR = array.new<float>(4, 0.0)      // learned mean momentum per regime
var array<float>  muV = array.new<float>(4, 0.0)      // learned mean volatility per regime
var bool  built = false
var int   dom = na
var float conf = na
var float logLik = na
var int   regimeAge = 0
var int   domPrev = na

// --- Initialize components on a spread-out ring (deterministic, diverse seeds) ---
if not built
    float rInit = 1.5
    float n0 = 1.0
    for k = 0 to K - 1
        float ang = 2.0 * math.pi * k / K
        float mu0 = rInit * math.cos(ang)
        float mu1 = rInit * math.sin(ang)
        array.set(Nk, k, n0)
        matrix.set(M1, k, 0, n0 * mu0)
        matrix.set(M1, k, 1, n0 * mu1)
        matrix.set(M2, k, 0, n0 * (mu0 * mu0 + 1.0))   // -> initial variance = 1
        matrix.set(M2, k, 1, n0 * (mu1 * mu1 + 1.0))
    built := true

// ----------------------------------------------------------------------------
//  E-STEP  ( posterior over regimes for the current bar ; every bar )
// ----------------------------------------------------------------------------
if built and ready
    float sumN = array.sum(Nk)
    array<float> piA = array.new<float>(K, 0.0)
    array<float> m0A = array.new<float>(K, 0.0)
    array<float> m1A = array.new<float>(K, 0.0)
    array<float> v0A = array.new<float>(K, 0.0)
    array<float> v1A = array.new<float>(K, 0.0)
    for k = 0 to K - 1
        float nk = math.max(array.get(Nk, k), EPS)
        float mu0 = matrix.get(M1, k, 0) / nk
        float mu1 = matrix.get(M1, k, 1) / nk
        array.set(piA, k, nk / sumN)
        array.set(m0A, k, mu0)
        array.set(m1A, k, mu1)
        array.set(v0A, k, math.max(matrix.get(M2, k, 0) / nk - mu0 * mu0, varFloor))
        array.set(v1A, k, math.max(matrix.get(M2, k, 1) / nk - mu1 * mu1, varFloor))
        if k < 4
            array.set(muR, k, mu0)
            array.set(muV, k, mu1)
            array.set(regCol, k, f_char(mu0, mu1))
    // log-densities with log-sum-exp normalization
    array<float> lg = array.new<float>(K, 0.0)
    float mx = -1e18
    for k = 0 to K - 1
        float v0 = array.get(v0A, k)
        float v1 = array.get(v1A, k)
        float d0 = x0 - array.get(m0A, k)
        float d1 = x1 - array.get(m1A, k)
        float l = math.log(array.get(piA, k)) - 0.5 * (LOG2PI + math.log(v0) + d0 * d0 / v0) - 0.5 * (LOG2PI + math.log(v1) + d1 * d1 / v1)
        array.set(lg, k, l)
        mx := math.max(mx, l)
    float den = 0.0
    for k = 0 to K - 1
        den += math.exp(array.get(lg, k) - mx)
    logLik := mx + math.log(den)
    int best = 0
    float bestg = -1.0
    for k = 0 to K - 1
        float gk = math.exp(array.get(lg, k) - mx) / den
        array.set(gamma, k, gk)
        if gk > bestg
            bestg := gk
            best := k
    dom := best
    conf := bestg
    regimeAge := (na(domPrev) or dom != domPrev) ? 0 : regimeAge + 1
    domPrev := dom

// ----------------------------------------------------------------------------
//  M-STEP  ( update sufficient statistics with forgetting ; confirmed bars )
// ----------------------------------------------------------------------------
if built and ready and barstate.isconfirmed
    for k = 0 to K - 1
        float gk = array.get(gamma, k)
        array.set(Nk, k, lambda * array.get(Nk, k) + gk)
        matrix.set(M1, k, 0, lambda * matrix.get(M1, k, 0) + gk * x0)
        matrix.set(M1, k, 1, lambda * matrix.get(M1, k, 1) + gk * x1)
        matrix.set(M2, k, 0, lambda * matrix.get(M2, k, 0) + gk * x0 * x0)
        matrix.set(M2, k, 1, lambda * matrix.get(M2, k, 1) + gk * x1 * x1)

// ----------------------------------------------------------------------------
//  ON-PRICE VISUALS  ( dominant-regime tint + bar coloring, drawn on main chart )
// ----------------------------------------------------------------------------
color domColor = (ready and not na(dom)) ? array.get(regCol, dom) : na
int tintT = 92 - int(nz(conf) * 8.0)
bgcolor(showTint and active and not na(domColor) ? color.new(domColor, tintT) : na, force_overlay = true)
barcolor(showBars and active and not na(domColor) ? color.new(domColor, 30) : na)

// ----------------------------------------------------------------------------
//  REGIME PROBABILITY RIBBON  ( stacked posterior, this pane, [0..1] )
// ----------------------------------------------------------------------------
float L0 = na
float L1 = na
float L2 = na
float L3 = na
float L4 = na
if ready and built
    float a1 = array.get(gamma, 0)
    float a2 = K > 1 ? array.get(gamma, 1) : 0.0
    float a3 = K > 2 ? array.get(gamma, 2) : 0.0
    float a4 = K > 3 ? array.get(gamma, 3) : 0.0
    L0 := 0.0
    L1 := a1
    L2 := a1 + a2
    L3 := a1 + a2 + a3
    L4 := a1 + a2 + a3 + a4

color sepCol = color.new(#0b0e16, 55)
p0 = plot(L0, "b0", color = sepCol, linewidth = 1)
p1 = plot(L1, "b1", color = sepCol, linewidth = 1)
p2 = plot(L2, "b2", color = sepCol, linewidth = 1)
p3 = plot(L3, "b3", color = sepCol, linewidth = 1)
p4 = plot(L4, "b4", color = sepCol, linewidth = 1)
fill(p0, p1, color = color.new(array.get(regCol, 0), ribT))
fill(p1, p2, color = K > 1 ? color.new(array.get(regCol, 1), ribT) : na)
fill(p2, p3, color = K > 2 ? color.new(array.get(regCol, 2), ribT) : na)
fill(p3, p4, color = K > 3 ? color.new(array.get(regCol, 3), ribT) : na)

// ----------------------------------------------------------------------------
//  DASHBOARD
// ----------------------------------------------------------------------------
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(bullCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast and showDash
    color hdrBg = #0b0e16
    color rowBg = color.new(#11151f, 10)
    string stat = active ? "● ACTIVE" : "◌ LEARNING"
    color  statCol = active ? bullCol : neutCol
    string dRegime = (not na(dom)) ? f_glyph(array.get(muR, dom), array.get(muV, dom)) + " " + f_lab(array.get(muR, dom), array.get(muV, dom)) : "—"
    table.cell(dash, 0, 0, "AE · GMM",   text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, stat,         text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 1, "Regime",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 1, dRegime,      text_color = nz(conf) >= 0 ? domColor : neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Confidence", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(nz(conf) * 100, "#") + "%", text_color = color.from_gradient(nz(conf), 0.33, 1.0, neutCol, bullCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    for k = 0 to 3
        string lab = k < K ? "R" + str.tostring(k + 1) + " " + f_glyph(array.get(muR, k), array.get(muV, k)) : "R" + str.tostring(k + 1)
        string val = k < K ? str.tostring(array.get(gamma, k) * 100, "#") + "%" : "—"
        color  tc  = k < K ? f_char(array.get(muR, k), array.get(muV, k)) : neutCol
        table.cell(dash, 0, 3 + k, lab, text_color = neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 3 + k, val, text_color = tc,      bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 7, "Stability",   text_color = neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(regimeAge) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 8, "λ / Fit",     text_color = neutCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(lambda, "#.###") + " / " + str.tostring(nz(logLik), "#.#"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
regimeChange = active and not na(dom) and not na(dom[1]) and dom != dom[1]
alertcondition(regimeChange, "Regime change", "AE-GMM: market regime changed")
````

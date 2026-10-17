# AetherEdge - Gaussian Process Bands

- url: https://www.tradingview.com/script/HquVbrsO/
- type: indicator
- pine_id: PUB;15273fc2a2d64e63a3282ae324fb2b36
- version: 1.0

## Description

🖊️ Overview

AE-GAUSS models price as a Gaussian Process and draws the predictive mean plus its uncertainty (±1σ, ±2σ) as nested translucent bands — a "fog of probability" that narrows where the model is confident and widens where it isn't. When price punches outside the 2σ band and snaps back, it fires a mean-reversion BUY/SELL as a statistically extreme excursion. It implements Gaussian Process Regression (GPR), a genuine Bayesian machine-learning method, the numerically-stable way without a matrix inverse.

🔶 Key Features

Gaussian Process Regression (GPR): models price as a stochastic process
RBF kernel + Cholesky decomposition: numerically-stable exact GP prediction
Linear detrend: trend-following extrapolation
Uncertainty bands: nested ±1σ / ±2σ "fog"
Volatility-adaptive kernel: σf scaled by ATR so bands breathe
2 signal modes: 2σ excursion reversion, or predictive-mean cross
Fit-quality tracking: online monitoring of prediction error
HUD showing σ-position gauge and z-score
Per-event 2σ excursion and signal alerts

🧠 Technical Architecture

This implements Gaussian Process Regression (GPR). Training is the last N prices; a linear trend is removed by least squares first, the GP models the stationary residual, and the trend is added back to the forecast. The RBF kernel k(i,j) = σf²·exp(−(i−j)²/2ℓ²) builds the N×N covariance K (+ σn² noise on the diagonal). Cholesky K = LLᵀ solves the linear systems K·α = y and K·v = k* by forward/back substitution (avoiding a matrix inverse — numerically stable). At x* = N (current bar), predictive mean μ* = trend + kᵀα and variance σ² = σf² − kᵀv. σf is ATR-scaled so band width changes with volatility. z-score = (close − μ)/σ* measures the statistical position. Signals fire when price exits the ±2σ band and re-enters, or crosses the predictive mean. GP computation runs on confirmed bars only.

⚙️ Recommended Settings & Tuning Guide

Training Points (N) 16 is a starting point — cost is O(N³), keep modest; lower if your chart lags (min 6). Length Scale (ℓ) 5 is RBF smoothness in bars — larger is smoother and longer-memory, smaller is local and reactive. Signal Amplitude 1.0×ATR is kernel signal std σf, setting the band's vertical scale. Observation Noise 0.4×ATR is σn — higher gives a smoother mean, wider bands, more tolerance. Signal Mode "2σ reversion" is mean-reverting; "Mean cross" is more trend-following.

💡 How to Use in Practice

Apply to chart and fog-like uncertainty bands appear around the predictive mean. Narrow bands mean the model confidently predicts price; wide bands mean uncertainty. When price punches through the lower 2σ band it's a statistically rare oversold — buy on the re-entry. Vice versa above. The HUD's "price σ-position" gauge shows where price sits in the prediction (● position), and the z-score shows how many σ it deviates. Smaller "fit error" means the model fits well, raising signal reliability. Raising length scale gives smooth swing bands; lowering gives reactive ones. In trends the predictive mean follows the trend; in ranges band-edge reversions work.

⚠️ Important Notes

GPR is a genuine machine-learning method (Bayesian non-parametric regression). To stay inside Pine's compute budget, N is kept small and the kernel hyper-parameters (ℓ, σf, σn) are user-set (with ATR scaling), not marginal-likelihood-optimized. The GP math, however, is exact for the chosen N. This indicator is the most compute-heavy of the set, O(N³) per bar; lower N if your chart is slow. GP computation runs on confirmed bars only and does not repaint, but real-time bars show the last confirmed value. All signals are probabilistic decisions based on historical data and do not guarantee future profits.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Gaussian Process Bands
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Gaussian Process Bands  ·  AE-GAUSS                           │
// │                                                                            │
// │  Models price as a Gaussian Process and draws the predictive MEAN plus its │
// │  UNCERTAINTY (±1σ, ±2σ) as nested translucent bands — a "fog" of           │
// │  probability that narrows where the model is confident and widens where    │
// │  it isn't. When price punches outside the 2σ band and snaps back, that's a │
// │  statistically extreme excursion → a mean-reversion BUY/SELL.              │
// │                                                                            │
// │  HOW IT WORKS (genuine GPR)                                                │
// │  • Training set = last N prices; a linear trend is removed first so the     │
// │    GP models the stationary residual and the forecast follows the trend.   │
// │  • RBF kernel k(i,j) = σf²·exp(−(i−j)²/2ℓ²) builds the N×N covariance K     │
// │    (+ σn² noise on the diagonal).                                          │
// │  • Cholesky K = LLᵀ; solve K·α = y and K·v = k* by forward/back            │
// │    substitution. Predictive mean μ* = trend + k*ᵀα; variance               │
// │    σ*² = σf² − k*ᵀv. No matrix inverse — the proper numerically-stable way. │
// │  • σf is scaled by ATR so the band breathes with volatility.               │
// │                                                                            │
// │  HONEST SCOPE: GPR is a real machine-learning method (Bayesian non-        │
// │  parametric regression). To stay inside Pine's compute budget N is kept    │
// │  small and the kernel hyper-parameters are user-set (with ATR scaling),    │
// │  not marginal-likelihood-optimized. The GP math is exact for the chosen N. │
// │  Heavy: lower N if your chart is slow.                                     │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Gaussian Process Bands", "AE-GAUSS", overlay = true,
     max_bars_back = 200, max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS — Gaussian Process ░░
// ============================================================================
gG = "▓ GAUSSIAN PROCESS ▓"
gp_srcInp   = input.source(close, "Source", group = gG)
gp_nInp     = input.int(16, "Training Points (N)", minval = 6, maxval = 28, group = gG,
     tooltip = "Number of past points the GP fits. Cost is O(N³) per bar — keep modest. 16 is a good balance; lower if your chart lags.")
gp_ellInp   = input.float(5.0, "Length Scale (ℓ)", minval = 1.0, maxval = 30.0, step = 0.5, group = gG,
     tooltip = "RBF smoothness in bars. Larger = smoother, longer-memory mean. Smaller = more local, reactive.")
gp_sigFInp  = input.float(1.0, "Signal Amplitude (× ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = gG,
     tooltip = "Kernel signal std σf, in ATR units. Sets the vertical scale of the band.")
gp_sigNInp  = input.float(0.4, "Observation Noise (× ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = gG,
     tooltip = "Observation noise σn, in ATR units. Higher = smoother mean, wider bands, more tolerance.")

gS = "▓ SIGNAL ▓"
sig_modeInput = input.string("2σ reversion (punch-out & back)", "Signal Mode",
     options = ["2σ reversion (punch-out & back)", "Mean cross"], group = gS,
     tooltip = "2σ reversion: price exits the 2σ band then re-enters. Mean cross: price crosses the predictive mean.")

gVI = "▓ VISUALS ▓"
vi_themeInput = input.string("Aurora Mist", "Palette",
     options = ["Aurora Mist", "Quantum Violet", "Emerald Fog"], group = gVI)
vi_showMean   = input.bool(true, "Show Predictive Mean", group = gVI)
vi_show1s     = input.bool(true, "Show ±1σ Band", group = gVI)
vi_show2s     = input.bool(true, "Show ±2σ Band", group = gVI)
vi_marks      = input.bool(true, "BUY/SELL Markers", group = gVI)
vi_barColor   = input.bool(false, "Color Candles by σ-Position", group = gVI)

gH = "▓ HUD ▓"
hud_showInp   = input.bool(true, "Show HUD", group = gH)


// ============================================================================
//  ░░ PALETTE ░░
// ============================================================================
var color cMean = na
var color cBand = na
var color cBuy = na
var color cSell = na
var color cAcc = na
var color cTxt = #eef2f0
var color cTxtD = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [me, bd, b, s, a] = switch vi_themeInput
        "Quantum Violet" => [#c4b5fd, #818cf8, #34d399, #fb7185, #e879f9]
        "Emerald Fog"    => [#6ee7b7, #34d399, #10e0a0, #ff3860, #d4af37]
        => [#a5b4fc, #818cf8, #10e0a0, #ff3860, #d4af37]   // Aurora Mist
    [me, bd, b, s, a]
[pMe, pBd, pB, pS, pA] = setPalette()
cMean := pMe
cBand := pBd
cBuy := pB
cSell := pS
cAcc := pA


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Cholesky decomposition K = L·Lᵀ (L lower-triangular). Row-major n×n arrays.
cholesky(Km, n) =>
    L = array.new<float>(n * n, 0.0)
    for j = 0 to n - 1
        for i = j to n - 1
            s = array.get(Km, i * n + j)
            if j > 0
                for k = 0 to j - 1
                    s -= array.get(L, i * n + k) * array.get(L, j * n + k)
            if i == j
                array.set(L, i * n + j, math.sqrt(math.max(s, 1e-12)))
            else
                ljj = array.get(L, j * n + j)
                array.set(L, i * n + j, ljj != 0.0 ? s / ljj : 0.0)
    L

// Solve K·x = b given Cholesky factor L, via forward then back substitution.
solveChol(L, b, n) =>
    yv = array.new<float>(n, 0.0)
    for i = 0 to n - 1
        s = array.get(b, i)
        if i > 0
            for k = 0 to i - 1
                s -= array.get(L, i * n + k) * array.get(yv, k)
        lii = array.get(L, i * n + i)
        array.set(yv, i, lii != 0.0 ? s / lii : 0.0)
    xv = array.new<float>(n, 0.0)
    for ii = 0 to n - 1
        i = n - 1 - ii
        s = array.get(yv, i)
        if i < n - 1
            for k = i + 1 to n - 1
                s -= array.get(L, k * n + i) * array.get(xv, k)
        lii = array.get(L, i * n + i)
        array.set(xv, i, lii != 0.0 ? s / lii : 0.0)
    xv


// ============================================================================
//  ░░ COMMON ░░
// ============================================================================
atr = ta.atr(14)


// ============================================================================
//  ░░ GAUSSIAN PROCESS REGRESSION (confirmed bars only — heavy) ░░
//  Training x = 0..N-1 (oldest→newest), predict at x* = N (current bar).
//  Linear detrend, GP on residual, add trend back.
// ============================================================================
N = gp_nInp
var float muStarV = na
var float sigStarV = na

if barstate.isconfirmed and bar_index > N + 1
    // Linear detrend over training window.
    sx = 0.0
    sy = 0.0
    sxx = 0.0
    sxy = 0.0
    for i = 0 to N - 1
        yi = gp_srcInp[N - i]
        sx += i
        sy += yi
        sxx += i * i
        sxy += i * yi
    ddenom = N * sxx - sx * sx
    slope = ddenom != 0.0 ? (N * sxy - sx * sy) / ddenom : 0.0
    intercept = (sy - slope * sx) / N

    // Kernel hyper-parameters (ATR-scaled amplitude/noise).
    sigF = atr * gp_sigFInp
    sigF2 = sigF * sigF
    sigN = atr * gp_sigNInp
    sigN2 = sigN * sigN
    ell = gp_ellInp
    twoEll2 = 2.0 * ell * ell

    // Build covariance matrix K and detrended target yc.
    K = array.new<float>(N * N, 0.0)
    yc = array.new<float>(N, 0.0)
    for a = 0 to N - 1
        array.set(yc, a, gp_srcInp[N - a] - (intercept + slope * a))
        for b = 0 to N - 1
            d = a - b
            kv = sigF2 * math.exp(-(d * d) / twoEll2)
            if a == b
                kv += sigN2
            array.set(K, a * N + b, kv)

    // k* between training points and the prediction point x* = N.
    kstar = array.new<float>(N, 0.0)
    for i = 0 to N - 1
        d = N - i
        array.set(kstar, i, sigF2 * math.exp(-(d * d) / twoEll2))

    // Solve and predict.
    L = cholesky(K, N)
    alpha = solveChol(L, yc, N)
    vvec = solveChol(L, kstar, N)

    muResid = 0.0
    kv2 = 0.0
    for i = 0 to N - 1
        muResid += array.get(kstar, i) * array.get(alpha, i)
        kv2 += array.get(kstar, i) * array.get(vvec, i)
    trendStar = intercept + slope * N
    muStarV := trendStar + muResid
    sigStarV := math.sqrt(math.max(sigF2 - kv2, 0.0))


// ============================================================================
//  ░░ BANDS ░░
// ============================================================================
mu = muStarV
sig = sigStarV
up1 = mu + sig
up2 = mu + 2.0 * sig
dn1 = mu - sig
dn2 = mu - 2.0 * sig

zScore = not na(sig) and sig > 0 ? sdiv(close - mu, sig) : 0.0


// ============================================================================
//  ░░ PREDICTION ERROR TRACKING (model fit quality) ░░
// ============================================================================
var float predErrEWMA = na
if barstate.isconfirmed and not na(muStarV[1])
    err = math.abs(close - muStarV[1])
    predErrEWMA := na(predErrEWMA) ? err : predErrEWMA * 0.95 + err * 0.05


// ============================================================================
//  ░░ SIGNAL ░░
// ============================================================================
revBuyRaw = not na(dn2) and not na(dn2[1]) and close[1] < dn2[1] and close >= dn2
revSellRaw = not na(up2) and not na(up2[1]) and close[1] > up2[1] and close <= up2
crossBuyRaw = not na(mu) and ta.crossover(close, mu)
crossSellRaw = not na(mu) and ta.crossunder(close, mu)

buyRaw = sig_modeInput == "Mean cross" ? crossBuyRaw : revBuyRaw
sellRaw = sig_modeInput == "Mean cross" ? crossSellRaw : revSellRaw

var int lastSig = 0
fireBuy = buyRaw and lastSig != 1
fireSell = sellRaw and lastSig != -1
if barstate.isconfirmed
    if fireBuy
        lastSig := 1
    if fireSell
        lastSig := -1
    if math.abs(zScore) < 0.5
        lastSig := 0

predDir = not na(mu) and not na(mu[1]) ? (mu > mu[1] ? 1 : mu < mu[1] ? -1 : 0) : 0


// ============================================================================
//  ░░ VISUALS — nested uncertainty bands ░░
// ============================================================================
muCol = predDir > 0 ? cMean : predDir < 0 ? color.new(cMean, 0) : cMean
pMean = plot(vi_showMean ? mu : na, "GP Mean", color = color.new(cMean, 0), linewidth = 2)

pUp1 = plot(vi_show1s ? up1 : na, "+1σ", color = na, editable = false)
pDn1 = plot(vi_show1s ? dn1 : na, "−1σ", color = na, editable = false)
pUp2 = plot(vi_show2s ? up2 : na, "+2σ", color = na, editable = false)
pDn2 = plot(vi_show2s ? dn2 : na, "−2σ", color = na, editable = false)

// ±1σ inner band (denser fog).
fill(pUp1, pDn1, color = vi_show1s ? color.new(cBand, 80) : na, title = "±1σ")
// 1σ→2σ outer bands (thinner fog).
fill(pUp2, pUp1, color = (vi_show2s and vi_show1s) ? color.new(cBand, 90) : na, title = "+1σ→2σ")
fill(pDn1, pDn2, color = (vi_show2s and vi_show1s) ? color.new(cBand, 90) : na, title = "−1σ→2σ")

// BUY/SELL markers.
plotshape(vi_marks and fireBuy  and barstate.isconfirmed, title = "BUY",  style = shape.labelup,   location = location.belowbar, color = cBuy,  textcolor = #04140f, text = "GP▲", size = size.small)
plotshape(vi_marks and fireSell and barstate.isconfirmed, title = "SELL", style = shape.labeldown, location = location.abovebar, color = cSell, textcolor = #1a0509, text = "GP▼", size = size.small)

// Bar coloring by σ-position.
zCol = zScore > 1.5 ? cSell : zScore < -1.5 ? cBuy : na
barcolor(vi_barColor ? zCol : na, editable = false)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
bar10signed(z) =>
    // maps z in [-3,3] to a 10-cell bar centered at 5
    int pos = int(clamp(math.round((z + 3.0) / 6.0 * 10.0), 0.0, 10.0))
    string s = ""
    for i = 1 to 10
        s += i == pos ? "●" : "░"
    s

var table hud = na
if hud_showInp and na(hud)
    hud := table.new(position.top_right, 2, 11, bgcolor = cPanel,
         border_color = color.new(cAcc, 60), border_width = 1, frame_color = color.new(cAcc, 40), frame_width = 1)

if hud_showInp and barstate.islast
    sz = size.normal
    fitQual = not na(predErrEWMA) and atr > 0 ? predErrEWMA / atr : na

    table.cell(hud, 0, 0, "GAUSSIAN PROCESS", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "GPR · N=" + str.tostring(N), text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    pdCol = predDir > 0 ? cBuy : predDir < 0 ? cSell : cTxtD
    table.cell(hud, 0, 1, "predictive mean", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, na(mu) ? "—" : str.tostring(mu, format.mintick) + (predDir > 0 ? " ↗" : predDir < 0 ? " ↘" : " →"), text_color = pdCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "uncertainty σ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, na(sig) or atr == 0 ? "—" : str.tostring(sig / atr, "#.00") + " ATR", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    zCol2 = zScore > 1.5 ? cSell : zScore < -1.5 ? cBuy : cTxt
    table.cell(hud, 0, 3, "price σ-position", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10signed(zScore), text_color = zCol2, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "z-score", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(zScore, "#.00") + "σ", text_color = zCol2, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "▔ MODEL ▔", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 5, "", bgcolor = cPanelHd)

    fitCol = na(fitQual) ? cTxtD : fitQual < 0.5 ? cBuy : fitQual < 1.0 ? cTxt : cSell
    table.cell(hud, 0, 6, "fit error (EWMA)", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, na(fitQual) ? "—" : str.tostring(fitQual, "#.00") + " ATR", text_color = fitCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "length scale ℓ", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(gp_ellInp, "#.0") + " bars", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 8, "signal σf", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(gp_sigFInp, "#.0") + " ATR", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "noise σn", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(gp_sigNInp, "#.00") + " ATR", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    sigState = lastSig == 1 ? "▲ long bias" : lastSig == -1 ? "▼ short bias" : "· neutral"
    sigStCol = lastSig == 1 ? cBuy : lastSig == -1 ? cSell : cTxtD
    table.cell(hud, 0, 10, "signal state", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 10, sigState, text_color = sigStCol, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(fireBuy,  "GP BUY",  "AE-GAUSS: bullish signal (GP band)")
alertcondition(fireSell, "GP SELL", "AE-GAUSS: bearish signal (GP band)")
alertcondition(not na(zScore) and zScore > 2.0 and zScore[1] <= 2.0, "Above 2σ", "AE-GAUSS: price exceeded +2σ band")
alertcondition(not na(zScore) and zScore < -2.0 and zScore[1] >= -2.0, "Below 2σ", "AE-GAUSS: price fell below −2σ band")
````

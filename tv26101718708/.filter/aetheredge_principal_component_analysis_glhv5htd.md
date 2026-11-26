# AetherEdge - Principal Component Analysis

- url: https://www.tradingview.com/script/glhV5HTd/
- type: indicator
- pine_id: PUB;cd089d893dd24720b1b9f0c88bb36d71
- version: 1.0

## Description

🖊️ Overview

AE-PCA extracts the market's eigen-state from the correlation structure of a basket of assets. It builds a rolling correlation matrix online and extracts the leading principal components — PC1 (market factor), PC2 (rotation/dispersion) — via power iteration with deflation. From the eigenvalues it derives the Absorption Ratio (λ₁/N) — the share of basket variance explained by one factor — which reveals, at a glance, the "everything moves together" systemic fragility of the market. The eigenbasis continuously re-orients each bar to the current correlation structure.

🔶 Key Features

Online PCA engine — builds a rolling correlation matrix with forgetting and extracts the top two principal components by power iteration (heavy use of the matrix type).
Absorption Ratio (systemic stress) — λ₁/N quantifies market concentration = fragility; sharp rises capture the "correlation convergence" that precedes crashes.
Self-evolving eigenbasis — eigenvectors are warm-started and re-converged each bar, tracking shifts in correlation smoothly (subspace tracking) with sign continuity preserved.
Phase-space comet — projects the live return vector onto PC1/PC2 and traces the market's path through factor space as a comet trail on a floating canvas to the right of the chart.
Factor loadings — identifies the asset that loads most heavily on PC1 (the one leading the market).
Dispersion gauge — 1 − Absorption Ratio shows the degree of diversification.
Live statistics panel — absorption ratio, cumulative (PC1+PC2), eigenvalues λ₁/λ₂, dispersion, lead asset, and PC1/PC2 scores.
Macro-overlay design — the basket is independent of the chart symbol, so you can overlay market-wide stress on any chart you view. Confirmed-bar updates, no look-ahead.

🧠 Technical Architecture

From 6 asset returns, first and second moments (means, covariances) are updated online with forgetting factor λ, then divided by each asset's standard deviation to build the correlation matrix R (N×N). PC1 is found by power iteration v ← Rv/‖Rv‖, with eigenvalue λ₁ from the Rayleigh quotient. Then deflation R₂ = R − λ₁v₁v₁ᵀ is applied, and PC2 obtained by power iteration with Gram-Schmidt orthogonalization. Since the correlation matrix has trace N, the absorption ratio is λ₁/N and the cumulative is (λ₁+λ₂)/N.
Factor scores are computed by projecting the standardized current returns z_i=(r_i−μ_i)/σ_i onto the eigenvectors (PC1 score = Σz_i·v₁_i). Eigenvectors are warm-started from the previous bar for fast convergence and sign stability across bars (PC1 is oriented so Σv₁ > 0). A high absorption ratio means "correlation convergence = single-factor dominance = fragility"; a low one means "dispersion = diversification." All updates occur on confirmed bars.

🎯 Three design choices stand out. First, using the correlation (not covariance) matrix yields a scale-free absorption ratio that isn't dominated by a single high-volatility asset. Second, warm-starting the eigenvectors suppresses sign flips and flicker, giving smooth scores. Third, confining updates to confirmed bars keeps historical values non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — a basket of the 6 majors (BTC/ETH/SOL/BNB/XRP/ADA), 1D/4H: adaptation λ = 0.97, Calm threshold 0.40, Stress threshold 0.60; crypto-wide risk-on/off separates cleanly. For nimbler anomaly detection: lower λ toward 0.95 to react faster to correlation shifts, and raise the Stress threshold to 0.65 so only genuine convergence triggers, reducing noise.
Per parameter: Adaptation λ is the main knob — near 0.99 correlations are smooth and long-run; near 0.95 they respond quickly to shocks. Calm/Stress thresholds should be tuned to your basket's composition and its typical absorption ratio (closer to uncorrelated → lower λ₁/N; strongly correlated → higher). Comet length / canvas width tune the phase-space display. The basket can be freely swapped for the assets whose correlation you want to track.

💡 How to Use in Practice

The core read is the absorption-ratio regime. When the ratio is low and stable (CALM), the market is diversified and stock-picking tends to work. When it spikes into the Stress zone, correlations have converged into an "everything moves together" fragile state — a cue to reduce concentration as a leading sign of self-reinforcing declines or risk-off. When the phase-space comet stretches strongly in one direction, the market is factor-driven (trending); when it swirls near the center, it's ranging/rotating. The Lead Asset is the one currently driving the whole market.
For multi-timeframe work, read the higher-timeframe absorption ratio for the macro risk backdrop and execute single-name trades on the lower timeframe. Paired with trend and volatility tools, it serves as a top-level risk filter (e.g., avoid fading during stress spikes).

⚠️ Important Notes

This indicator fetches external data (request.security) for 6 symbols. Specifying invalid or illiquid symbols drops their contribution and degrades accuracy — compose the basket from liquid symbols. Nothing displays until warmup completes. Reloading the indicator rebuilds the correlation moments from scratch — learning state is not persisted. The absorption ratio is a proxy for systemic fragility (akin to Kritzman's absorption ratio), not a directional signal by itself. The sign of the PC2 score is arbitrary. The phase-space comet is drawn in the chart's right margin, so display requires right-side space. Power iteration is an approximation of the top two components, and updates occur on confirmed bars only.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Principal Component Analysis   ( AE-PCA )
// ----------------------------------------------------------------------------
//  A market eigen-state engine. It reads a basket of correlated assets, builds
//  a ROLLING correlation matrix online (exponential forgetting), and extracts
//  its leading principal components by power iteration with deflation:
//      R v = lambda v   ->   PC1 (market factor), PC2 (rotation/dispersion)
//  From the eigenvalues it derives the ABSORPTION RATIO (lambda1 / N) - the
//  share of basket variance explained by one factor. A high ratio means
//  everything moves together: a fragile, systemically-stressed market. It also
//  projects the live return vector onto PC1/PC2 to trace the market's path
//  through factor space (a phase-space comet trail). The eigenbasis is warm-
//  started each bar, so it continuously re-orients to the current correlation
//  structure. Updates occur on confirmed bars only (no look-ahead).
// ============================================================================
indicator("AetherEdge - Principal Component Analysis", "AE-PCA", overlay = false, max_lines_count = 50, max_labels_count = 50, max_boxes_count = 50, max_polylines_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Basket (6 assets) ---
var string gB = "Basket"
sym0 = input.symbol("BINANCE:BTCUSDT", "Asset 1", group = gB)
sym1 = input.symbol("BINANCE:ETHUSDT", "Asset 2", group = gB)
sym2 = input.symbol("BINANCE:SOLUSDT", "Asset 3", group = gB)
sym3 = input.symbol("BINANCE:BNBUSDT", "Asset 4", group = gB)
sym4 = input.symbol("BINANCE:XRPUSDT", "Asset 5", group = gB)
sym5 = input.symbol("BINANCE:ADAUSDT", "Asset 6", group = gB)
lambda = input.float(0.97, "Adaptation (lambda)", minval = 0.90, maxval = 0.999, step = 0.001, group = gB, tooltip = "Forgetting factor of the rolling correlation. Lower = adapts faster; higher = longer, steadier memory.")

//  --- Stress ---
var string gS = "Stress"
loTh = input.float(0.40, "Calm Below", minval = 0.1, maxval = 0.9, step = 0.05, group = gS, tooltip = "Absorption ratio below this = calm / diversified.")
hiTh = input.float(0.60, "Stressed Above", minval = 0.1, maxval = 0.95, step = 0.05, group = gS, tooltip = "Absorption ratio above this = systemically stressed.")

//  --- Display ---
var string gD = "Display"
warmup    = input.int(150, "Warmup Bars", minval = 30, group = gD)
calmCol   = input.color(#26ffe6, "Calm", group = gD)
stressCol = input.color(#ff2e88, "Stress", group = gD)
neutCol   = input.color(#8892b0, "Neutral", group = gD)
accent    = input.color(#aeffff, "Accent", group = gD)
showPhase = input.bool(true,  "Phase-Space Comet (on price)", group = gD)
phaseLen  = input.int(40, "Comet Length", minval = 5, maxval = 120, group = gD)
phaseW    = input.int(30, "Canvas Width (bars)", minval = 10, maxval = 80, group = gD)
rangeLen  = input.int(100, "Canvas Height Lookback", minval = 20, group = gD)
showTint  = input.bool(true,  "Price Stress Tint", group = gD)
showDash  = input.bool(true,  "Dashboard", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
N   = 6
EPS = 1e-12
ITER = 10

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

f_stress(float t) =>
    float tt = f_clip(t, 0.0, 1.0)
    tt < 0.5 ? color.from_gradient(tt, 0.0, 0.5, calmCol, #ffae57) : color.from_gradient(tt, 0.5, 1.0, #ffae57, stressCol)

f_short(string s) =>
    array<string> parts = str.split(s, ":")
    array.size(parts) > 0 ? array.last(parts) : s

// ----------------------------------------------------------------------------
//  BASKET RETURNS
// ----------------------------------------------------------------------------
c0 = request.security(sym0, timeframe.period, close, ignore_invalid_symbol = true)
c1 = request.security(sym1, timeframe.period, close, ignore_invalid_symbol = true)
c2 = request.security(sym2, timeframe.period, close, ignore_invalid_symbol = true)
c3 = request.security(sym3, timeframe.period, close, ignore_invalid_symbol = true)
c4 = request.security(sym4, timeframe.period, close, ignore_invalid_symbol = true)
c5 = request.security(sym5, timeframe.period, close, ignore_invalid_symbol = true)
r0 = na(c0) or na(c0[1]) or c0[1] == 0.0 ? 0.0 : math.log(c0 / c0[1])
r1 = na(c1) or na(c1[1]) or c1[1] == 0.0 ? 0.0 : math.log(c1 / c1[1])
r2 = na(c2) or na(c2[1]) or c2[1] == 0.0 ? 0.0 : math.log(c2 / c2[1])
r3 = na(c3) or na(c3[1]) or c3[1] == 0.0 ? 0.0 : math.log(c3 / c3[1])
r4 = na(c4) or na(c4[1]) or c4[1] == 0.0 ? 0.0 : math.log(c4 / c4[1])
r5 = na(c5) or na(c5[1]) or c5[1] == 0.0 ? 0.0 : math.log(c5 / c5[1])

ready = bar_index > warmup

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (rolling moments + warm-started eigenvectors)
// ----------------------------------------------------------------------------
var array<float>  mean = array.new<float>(N, 0.0)
var matrix<float> M2   = matrix.new<float>(N, N, 0.0)
var array<float>  v1   = array.new<float>(N, 0.0)
var array<float>  v2   = array.new<float>(N, 0.0)
var array<float>  pc1H = array.new<float>(0)
var array<float>  pc2H = array.new<float>(0)
var float AR1 = na
var float AR2 = na
var float lam1 = na
var float lam2 = na
var float pc1 = na
var float pc2 = na
var int   domIdx = 0
var bool  built = false

var array<string> symArr = array.from(sym0, sym1, sym2, sym3, sym4, sym5)

if not built
    for i = 0 to N - 1
        array.set(v1, i, 1.0 / math.sqrt(N))
        array.set(v2, i, (i % 2 == 0 ? 1.0 : -1.0) / math.sqrt(N))
    built := true

// ----------------------------------------------------------------------------
//  ENGINE  (update correlation, eigen-decompose, project ; confirmed bars)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    array<float> rv = array.from(r0, r1, r2, r3, r4, r5)
    // --- online moments with forgetting ---
    for a = 0 to N - 1
        array.set(mean, a, lambda * array.get(mean, a) + (1.0 - lambda) * array.get(rv, a))
    for a = 0 to N - 1
        for b = 0 to N - 1
            matrix.set(M2, a, b, lambda * matrix.get(M2, a, b) + (1.0 - lambda) * array.get(rv, a) * array.get(rv, b))
    // --- correlation matrix ---
    array<float> sig = array.new<float>(N, 0.0)
    for a = 0 to N - 1
        array.set(sig, a, math.sqrt(math.max(matrix.get(M2, a, a) - math.pow(array.get(mean, a), 2), EPS)))
    matrix<float> R = matrix.new<float>(N, N, 0.0)
    for a = 0 to N - 1
        for b = 0 to N - 1
            float cab = matrix.get(M2, a, b) - array.get(mean, a) * array.get(mean, b)
            matrix.set(R, a, b, f_clip(cab / (array.get(sig, a) * array.get(sig, b)), -1.0, 1.0))

    // --- PC1 via power iteration (warm-started from previous v1) ---
    array<float> vv = array.copy(v1)
    for it = 0 to ITER - 1
        array<float> w = array.new<float>(N, 0.0)
        for a = 0 to N - 1
            float s = 0.0
            for b = 0 to N - 1
                s += matrix.get(R, a, b) * array.get(vv, b)
            array.set(w, a, s)
        float nrm = 0.0
        for a = 0 to N - 1
            nrm += math.pow(array.get(w, a), 2)
        nrm := math.sqrt(nrm)
        if nrm > EPS
            for a = 0 to N - 1
                array.set(vv, a, array.get(w, a) / nrm)
    // orient PC1 so the basket factor is positive
    float vsum = array.sum(vv)
    if vsum < 0.0
        for a = 0 to N - 1
            array.set(vv, a, -array.get(vv, a))
    // Rayleigh quotient -> lambda1
    float l1 = 0.0
    for a = 0 to N - 1
        float s = 0.0
        for b = 0 to N - 1
            s += matrix.get(R, a, b) * array.get(vv, b)
        l1 += array.get(vv, a) * s
    for a = 0 to N - 1
        array.set(v1, a, array.get(vv, a))
    lam1 := l1

    // --- deflate and find PC2 (Gram-Schmidt against v1) ---
    matrix<float> R2 = matrix.new<float>(N, N, 0.0)
    for a = 0 to N - 1
        for b = 0 to N - 1
            matrix.set(R2, a, b, matrix.get(R, a, b) - l1 * array.get(v1, a) * array.get(v1, b))
    array<float> uu = array.copy(v2)
    for it = 0 to ITER - 1
        array<float> w = array.new<float>(N, 0.0)
        for a = 0 to N - 1
            float s = 0.0
            for b = 0 to N - 1
                s += matrix.get(R2, a, b) * array.get(uu, b)
            array.set(w, a, s)
        float dotv = 0.0
        for a = 0 to N - 1
            dotv += array.get(w, a) * array.get(v1, a)
        for a = 0 to N - 1
            array.set(w, a, array.get(w, a) - dotv * array.get(v1, a))
        float nrm = 0.0
        for a = 0 to N - 1
            nrm += math.pow(array.get(w, a), 2)
        nrm := math.sqrt(nrm)
        if nrm > EPS
            for a = 0 to N - 1
                array.set(uu, a, array.get(w, a) / nrm)
    float l2 = 0.0
    for a = 0 to N - 1
        float s = 0.0
        for b = 0 to N - 1
            s += matrix.get(R, a, b) * array.get(uu, b)
        l2 += array.get(uu, a) * s
    for a = 0 to N - 1
        array.set(v2, a, array.get(uu, a))
    lam2 := l2

    // --- shares (absorption) + factor scores ---
    AR1 := f_clip(l1 / N, 0.0, 1.0)
    AR2 := f_clip((l1 + l2) / N, 0.0, 1.0)
    float p1 = 0.0
    float p2 = 0.0
    for a = 0 to N - 1
        float z = (array.get(rv, a) - array.get(mean, a)) / array.get(sig, a)
        p1 += z * array.get(v1, a)
        p2 += z * array.get(v2, a)
    pc1 := p1
    pc2 := p2
    // dominant loading on the market factor
    float bestL = -1.0
    for a = 0 to N - 1
        if math.abs(array.get(v1, a)) > bestL
            bestL := math.abs(array.get(v1, a))
            domIdx := a
    // store phase-space history
    array.push(pc1H, p1)
    array.push(pc2H, p2)
    if array.size(pc1H) > phaseLen
        array.shift(pc1H)
        array.shift(pc2H)

// ----------------------------------------------------------------------------
//  DERIVED
// ----------------------------------------------------------------------------
active = ready and built and not na(AR1)
float stressT = (nz(AR1) - loTh) / (hiTh - loTh + EPS)
color arCol = f_stress(stressT)
string regime = nz(AR1) > hiTh ? "STRESSED" : nz(AR1) < loTh ? "CALM" : "NORMAL"

// ----------------------------------------------------------------------------
//  PANE : ABSORPTION RATIO TIME SERIES
// ----------------------------------------------------------------------------
plot_ar1 = plot(active ? AR1 : na, "Absorption (PC1)", color = arCol, linewidth = 2)
plot_zero = plot(active ? 0.0 : na, "", color = na, display = display.none)
fill(plot_ar1, plot_zero, color = color.new(arCol, 82))
plot(active ? AR2 : na, "Cumulative (PC1+PC2)", color = color.new(neutCol, 30), linewidth = 1)
hline(hiTh, "Stress", color = color.new(stressCol, 50), linestyle = hline.style_dashed)
hline(loTh, "Calm", color = color.new(calmCol, 50), linestyle = hline.style_dashed)

bgcolor(showTint and active ? color.new(arCol, 90 - int(f_clip(stressT, 0, 1) * 6.0)) : na, force_overlay = true)

// ----------------------------------------------------------------------------
//  PHASE-SPACE COMET  (floating canvas in the right margin, on price)
// ----------------------------------------------------------------------------
yHi = ta.highest(high, rangeLen)
yLo = ta.lowest(low, rangeLen)

var box   pbox = na
var line  pax = na
var line  pay = na
var label plab = na
var array<polyline> ppl = array.new<polyline>()

if barstate.islast
    box.delete(pbox)
    line.delete(pax)
    line.delete(pay)
    label.delete(plab)
    if array.size(ppl) > 0
        for pl in ppl
            polyline.delete(pl)
        array.clear(ppl)

    if active and showPhase and array.size(pc1H) >= 2
        int xL = bar_index + 4
        float xC = xL + phaseW / 2.0
        float yC = (yHi + yLo) / 2.0
        float yH = (yHi - yLo) / 2.0
        pbox := box.new(left = xL, top = yHi, right = xL + phaseW, bottom = yLo, border_color = color.new(neutCol, 70), border_width = 1, bgcolor = color.new(#0b0e16, 80), force_overlay = true)
        pax := line.new(xL, yC, xL + phaseW, yC, color = color.new(neutCol, 75), force_overlay = true)
        pay := line.new(int(math.round(xC)), yLo, int(math.round(xC)), yHi, color = color.new(neutCol, 75), force_overlay = true)
        array<chart.point> trail = array.new<chart.point>()
        for j = 0 to array.size(pc1H) - 1
            float px = xC + (f_clip(array.get(pc1H, j), -3.0, 3.0) / 3.0) * (phaseW / 2.0)
            float py = yC + (f_clip(array.get(pc2H, j), -3.0, 3.0) / 3.0) * yH
            array.push(trail, chart.point.from_index(int(math.round(px)), py))
        array.push(ppl, polyline.new(points = trail, closed = false, curved = true, xloc = xloc.bar_index, line_color = color.new(arCol, 30), line_width = 2, force_overlay = true))
        chart.point last = array.last(trail)
        plab := label.new(last.index, last.price, "●", xloc = xloc.bar_index, style = label.style_none, textcolor = arCol, size = size.large, force_overlay = true)

// ----------------------------------------------------------------------------
//  DASHBOARD  (on price)
// ----------------------------------------------------------------------------
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(calmCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1, force_overlay = true)

if barstate.islast and showDash and active
    color rowBg = color.new(#11151f, 10)
    color hdrBg = #0b0e16
    color regCol = regime == "STRESSED" ? stressCol : regime == "CALM" ? calmCol : neutCol
    table.cell(dash, 0, 0, "AE · PCA",   text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, regime,        text_color = regCol,  bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
    table.cell(dash, 0, 1, "Absorption",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(AR1 * 100, "#") + "%", text_color = arCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "PC1+PC2",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(AR2 * 100, "#") + "%", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Dispersion",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring((1.0 - AR1) * 100, "#") + "%", text_color = color.from_gradient(1.0 - AR1, 0.2, 0.6, stressCol, calmCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "λ1 / λ2",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(lam1, "#.##") + " / " + str.tostring(lam2, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Lead Asset",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 5, f_short(array.get(symArr, domIdx)), text_color = accent, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 6, "PC1 score",   text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 6, (pc1 >= 0 ? "+" : "") + str.tostring(pc1, "#.##"), text_color = pc1 >= 0 ? calmCol : stressCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 7, "PC2 score",   text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 7, (pc2 >= 0 ? "+" : "") + str.tostring(pc2, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 8, "Adapt λ",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(lambda, "#.###"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
enterStress = active and nz(AR1) > hiTh and not (nz(AR1[1]) > hiTh)
exitStress  = active and nz(AR1) < loTh and not (nz(AR1[1]) < loTh)
alertcondition(enterStress, "Entered stress", "AE-PCA: absorption ratio entered systemic-stress zone")
alertcondition(exitStress,  "Exited stress",  "AE-PCA: absorption ratio dropped into the calm zone")
````

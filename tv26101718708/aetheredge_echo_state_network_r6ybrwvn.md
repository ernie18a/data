# AetherEdge - Echo State Network

- url: https://www.tradingview.com/script/r6yBrWvn/
- type: indicator
- pine_id: PUB;0af1941aefe54b3281c84312763ccc0e
- version: 1.0

## Description

🖊️ Overview

AE-ESN doesn't train on price — it pours price into a fixed, random recurrent core (a reservoir) and reads the future out of its rich nonlinear dynamics. No backpropagation, no offline training. Only the readout layer self-evolves online, bar by bar, continuously adapting to the prevailing regime. The result is projected forward as a confidence cone whose width is shaped by the model's own error distribution.

🔶 Key Features

Reservoir-computing engine — a fixed, sparsely-wired recurrent layer (4–48 neurons) maps the price stream into a high-dimensional state space.
Self-evolving online learning — the linear readout is updated every bar via normalized LMS; as the market shifts, the model quietly rewrites itself.
Guaranteed Echo State Property — the spectral radius is measured by power iteration and auto-scaled to the target ρ, ensuring stable memory dynamics.
Forward forecast cone — a free-running projection of multiple bars ahead, rendered as a confidence cone that widens with horizon.
Fully deterministic, non-repainting design — neuron wiring is reproducibly generated from a seed; learning and statistics update on confirmed bars only.
No look-ahead learning — weights are trained on a strict one-bar lag: the previous forecast versus the now-realized outcome.
Live statistics panel — directional accuracy, an R²-like confidence score, reservoir energy, and the projected return in real time.
Neon-grade visuals — gradient confidence cone, a glowing forecast line, and a directional background tint.

🧠 Technical Architecture

At the core is a reservoir driven by three normalized features (a standardized return, an ATR-normalized trend deviation, and momentum). State evolves through leaky integration — x(t) = (1−a)·x(t−1) + a·tanh(W_res·x(t−1) + W_in·u(t)). Both W_res and W_in are generated once via a deterministic LCG and then held fixed; the only thing that learns is the readout vector W_out.
That readout evolves on every confirmed bar through normalized LMS: each bar, the error between the previous forecast and the realized return is projected back along the state vector to correct the weights. An exponential moving variance of that error drives the cone's width (σ), while confidence is computed as explanatory skill over a zero-forecast baseline (an R²-like measure). The forward projection clones the current state and runs the reservoir free, feeding its own predictions back as input across the horizon.

🎯 Three design choices are worth highlighting. First, the spectral radius is measured via power 
iteration before being normalized to ρ, so memory quality stays stable even as neuron count changes. Second, learning is confined to confirmed bars on a one-bar lag, eliminating future leakage. Third, because the wiring is seed-deterministic, identical settings reproduce an identical topology on any chart.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): 16 neurons, ρ = 0.90, Leak = 0.30, learning rate 0.15, horizon 12; it tracks trending instruments cleanly. High-volatility names (SOL, XRP): lower Leak to 0.20–0.25 to smooth noise, and widen Band σ toward 2.0 so the cone reflects the rougher price action.
Per parameter: Learning rate (μ) sets adaptation speed — use 0.2–0.3 for fast regime turns, 0.08–0.12 for stability in ranges. Spectral radius (ρ) sets memory length — higher retains longer context (0.95–1.05 reactive, 0.80–0.90 calmer). Neuron count sets expressiveness — 12–16 for lower timeframes, 24–32 for higher timeframes or complex structure. Horizon should match your trading style — 6–8 for scalps, 20–30 for swings.

💡 How to Use in Practice

The core read is cone direction × confidence. When the cone tilts up with both confidence and directional accuracy elevated, treat it as a tailwind for buying dips. A tag-and-reject at the cone's outer edge marks the boundary of the model's expected range — a mean-reversion cue. A rapidly expanding cone signals rising volatility; a contracting cone suggests a transition into consolidation. When the one-bar fit trail hugs actual price tightly, the model is reliable in that regime.
For multi-timeframe work, confirm the macro bias from the cone on the higher timeframe (1D), then execute aligned setups on a lower timeframe (1H–4H). Layering it over volume profile or market structure (S/R, order blocks) lets the cone add where and with what conviction, giving mutual confirmation.

⚠️ Important Notes

Signals are hidden until the warmup period (default 200 bars) completes. Reloading the indicator, or changing settings/seed, makes the network relearn across the entire history from scratch — learning state is not persisted between sessions. Reproducibility on a given chart is preserved, but expect confidence and accuracy to take time to settle after any change. The forecast cone is a probabilistic expected range, not a guarantee. Learning and statistics update on confirmed bars only, and the cone refreshes when a bar closes. Pushing neuron count high (40+) over very long history can approach Pine's ~40-second runtime limit.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Echo State Network   ( AE-ESN )
// ----------------------------------------------------------------------------
//  A self-evolving Reservoir-Computing forecast band.
//  A FIXED random recurrent "reservoir" projects price into a rich, nonlinear
//  dynamical state. Only a lightweight LINEAR readout is trained ONLINE
//  (normalized LMS), so the model keeps adapting bar-by-bar to the current
//  regime without any offline training, gradients through time, or backprop.
//  The readout is trained on a strict 1-bar lag (no look-ahead), and the
//  reservoir wiring is deterministic from a seed (reproducible, non-repainting
//  topology). Forecasts are projected forward as a confidence cone whose width
//  is driven by the live standard deviation of the model's own errors.
// ============================================================================
indicator("AetherEdge - Echo State Network", "AE-ESN", overlay = true, max_polylines_count = 100, max_lines_count = 50, max_labels_count = 100, max_boxes_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Reservoir core ---
var string gRES = "Reservoir Core"
N          = input.int(16,   "Reservoir Neurons",     minval = 4, maxval = 48, group = gRES, tooltip = "Hidden state size. More neurons = more capacity, but heavier. 40+ on very long history can approach the ~40s runtime limit.")
specRadius = input.float(0.90, "Spectral Radius (rho)", minval = 0.10, maxval = 1.25, step = 0.05, group = gRES, tooltip = "Reservoir memory/stability. rho < 1 guarantees the Echo State Property. Higher = longer memory, more reactive.")
leak       = input.float(0.30, "Leak Rate",            minval = 0.05, maxval = 1.00, step = 0.05, group = gRES, tooltip = "State update speed. Lower = smoother, slower-fading memory.")
sparsity   = input.float(0.50, "Connection Sparsity",  minval = 0.00, maxval = 0.95, step = 0.05, group = gRES, tooltip = "Fraction of zeroed reservoir connections (sparse internal wiring).")
inScale    = input.float(1.00, "Input Scaling",        minval = 0.10, maxval = 3.00, step = 0.10, group = gRES)
seed       = input.int(1337,  "Random Seed",           minval = 1, group = gRES, tooltip = "Deterministic reservoir wiring. Same seed = reproducible, non-repainting topology.")

//  --- Online learning ---
var string gLRN = "Online Learning"
mu      = input.float(0.15, "Learning Rate (mu)", minval = 0.01, maxval = 1.00, step = 0.01, group = gLRN, tooltip = "Readout adaptation speed (normalized LMS). Higher = faster but noisier adaptation.")
warmup  = input.int(200,  "Warmup Bars",          minval = 20, group = gLRN, tooltip = "Bars the network learns before signals are displayed.")
statWin = input.int(200,  "Adaptation Window",    minval = 20, group = gLRN, tooltip = "Window (EMA-equivalent) for error / accuracy / confidence statistics.")

//  --- Features ---
var string gFEA = "Features"
zLen   = input.int(50, "Return Z-Score Length", minval = 5, group = gFEA)
emaLen = input.int(50, "Trend EMA Length",      minval = 5, group = gFEA)
atrLen = input.int(14, "ATR Length",            minval = 2, group = gFEA)
rsiLen = input.int(14, "RSI Length",            minval = 2, group = gFEA)

//  --- Forecast projection ---
var string gPRJ = "Forecast Projection"
H        = input.int(12,   "Projection Horizon",     minval = 2, maxval = 60, group = gPRJ, tooltip = "Bars projected forward via a free-running reservoir.")
bandMult = input.float(1.5, "Band Width (sigma)",    minval = 0.25, maxval = 4.00, step = 0.25, group = gPRJ, tooltip = "Confidence cone width, in standard deviations of the model's forecast error.")
fbDecay  = input.float(0.80, "Feedback Decay",       minval = 0.00, maxval = 1.00, step = 0.05, group = gPRJ, tooltip = "Decay of trend/momentum features during the free-running projection.")
biasBps  = input.float(2.0, "Neutral Threshold (bps)", minval = 0.0, group = gPRJ, tooltip = "Forecasts smaller than this magnitude are treated as neutral.")

//  --- Style ---
var string gSTY = "Style"
bullCol    = input.color(#26ffe6, "Bullish", group = gSTY)
bearCol    = input.color(#ff2e88, "Bearish", group = gSTY)
neutCol    = input.color(#8892b0, "Neutral", group = gSTY)
showCone   = input.bool(true,  "Show Confidence Cone", group = gSTY)
showCenter = input.bool(true,  "Show Forecast Line",   group = gSTY)
showGlow   = input.bool(true,  "Neon Glow",            group = gSTY)
showTrail  = input.bool(true,  "1-Bar Fit Trail",      group = gSTY, tooltip = "Historical 1-bar-ahead forecast, shifted +1 to align with the bar it predicts (non-repainting after close).")
showTint   = input.bool(true,  "Background Bias Tint", group = gSTY)
showDash   = input.bool(true,  "Dashboard",            group = gSTY)
dashPos    = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gSTY)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
FEAT = 3          // number of input features fed to the reservoir
EPS  = 1e-10      // numerical guard

// Hyperbolic tangent (Pine has no math.tanh) with overflow clamping
f_tanh(float x) =>
    xc = math.max(math.min(x, 20.0), -20.0)
    e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

// One leaky-integrator reservoir step on an arbitrary state copy (projection)
f_step(matrix<float> Wr, matrix<float> Wi, matrix<float> xPrev, array<float> u, float a, int n, int nin) =>
    xNew = matrix.new<float>(n, 1, 0.0)
    for i = 0 to n - 1
        acc = 0.0
        for j = 0 to n - 1
            acc += matrix.get(Wr, i, j) * matrix.get(xPrev, j, 0)
        for j = 0 to nin - 1
            acc += matrix.get(Wi, i, j) * array.get(u, j)
        matrix.set(xNew, i, 0, (1.0 - a) * matrix.get(xPrev, i, 0) + a * f_tanh(acc))
    xNew

// Map dashboard position string to a table position constant
f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// ----------------------------------------------------------------------------
//  FEATURE ENGINEERING  (computed every bar so series stay consistent)
// ----------------------------------------------------------------------------
ret  = math.log(close / close[1])
retZ = f_clip((ret - ta.sma(ret, zLen)) / (ta.stdev(ret, zLen) + EPS), -4.0, 4.0)  // standardized return
dev  = f_clip((close - ta.ema(close, emaLen)) / (ta.atr(atrLen) + EPS), -4.0, 4.0)  // ATR-normalized trend deviation
mom  = (ta.rsi(close, rsiLen) - 50.0) / 50.0                                         // momentum in [-1, 1]

// Normalize features to ~[-1, 1] so the reservoir stays in the active tanh region
u1 = retZ / 4.0
u2 = dev  / 4.0
u3 = mom

ready = bar_index > math.max(math.max(zLen, emaLen), math.max(atrLen, rsiLen)) + 2 and not na(retZ) and not na(dev) and not na(mom)

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (the network lives here across bars)
// ----------------------------------------------------------------------------
var matrix<float> Wres    = matrix.new<float>(N, N, 0.0)       // reservoir weights
var matrix<float> Win     = matrix.new<float>(N, FEAT, 0.0)    // input weights
var matrix<float> xst     = matrix.new<float>(N, 1, 0.0)       // reservoir state
var array<float>  Wout    = array.new<float>(N + 1, 0.0)       // linear readout (+ bias)
var array<float>  augPrev = array.new<float>(N + 1, 0.0)       // augmented state used by the last forecast
var float predPrev = 0.0
var float predNext = 0.0
var bool  built    = false

// Running statistics (EMA-based, updated only on confirmed bars)
var float errVar = na
var float retVar = na
var float dirAcc = na
alpha = 2.0 / (statWin + 1.0)

// --- Build the reservoir ONCE: deterministic LCG wiring + power-iteration scaling ---
if not built
    int rng = seed
    // Reservoir matrix with sparsity
    for i = 0 to N - 1
        for j = 0 to N - 1
            rng := (rng * 1103515245 + 12345) % 2147483647
            float r1 = rng / 2147483647.0
            rng := (rng * 1103515245 + 12345) % 2147483647
            float r2 = (rng / 2147483647.0) * 2.0 - 1.0
            matrix.set(Wres, i, j, r1 < sparsity ? 0.0 : r2)
    // Dense input weights
    for i = 0 to N - 1
        for j = 0 to FEAT - 1
            rng := (rng * 1103515245 + 12345) % 2147483647
            float r3 = (rng / 2147483647.0) * 2.0 - 1.0
            matrix.set(Win, i, j, r3 * inScale)
    // Estimate the largest eigenvalue magnitude via power iteration
    pv = matrix.new<float>(N, 1, 1.0 / math.sqrt(N))
    float lam = 1.0
    for it = 0 to 29
        wv = matrix.mult(Wres, pv)
        nrm = 0.0
        for i = 0 to N - 1
            nrm += math.pow(matrix.get(wv, i, 0), 2)
        nrm := math.sqrt(nrm)
        lam := nrm
        if nrm > EPS
            for i = 0 to N - 1
                matrix.set(pv, i, 0, matrix.get(wv, i, 0) / nrm)
    // Rescale reservoir to the target spectral radius (enforces Echo State Property)
    float sc = lam > EPS ? specRadius / lam : 1.0
    for i = 0 to N - 1
        for j = 0 to N - 1
            matrix.set(Wres, i, j, matrix.get(Wres, i, j) * sc)
    array.set(augPrev, N, 1.0)  // bias term
    built := true

// ----------------------------------------------------------------------------
//  ESN STEP + ONLINE LEARNING  (advance exactly once per CLOSED bar)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    // 1) Learn from the now-realized outcome of the PREVIOUS forecast (1-bar lag, no look-ahead)
    float oldPred = predPrev
    float e = ret - oldPred
    float nrm2 = EPS
    for k = 0 to N
        nrm2 += math.pow(array.get(augPrev, k), 2)
    float g = mu * e / nrm2                       // normalized LMS gain
    for k = 0 to N
        array.set(Wout, k, array.get(Wout, k) + g * array.get(augPrev, k))

    // 2) Advance the reservoir with current features (native matrix multiply = fast)
    uM = matrix.new<float>(FEAT, 1, 0.0)
    matrix.set(uM, 0, 0, u1)
    matrix.set(uM, 1, 0, u2)
    matrix.set(uM, 2, 0, u3)
    preM = matrix.mult(Wres, xst)
    inM  = matrix.mult(Win, uM)
    for i = 0 to N - 1
        matrix.set(xst, i, 0, (1.0 - leak) * matrix.get(xst, i, 0) + leak * f_tanh(matrix.get(preM, i, 0) + matrix.get(inM, i, 0)))

    // 3) Read out a fresh forecast for the NEXT bar's log-return
    float p = array.get(Wout, N)
    for i = 0 to N - 1
        p += array.get(Wout, i) * matrix.get(xst, i, 0)
    predNext := p

    // 4) Cache the augmented state that produced this forecast for the next learning step
    for i = 0 to N - 1
        array.set(augPrev, i, matrix.get(xst, i, 0))
    array.set(augPrev, N, 1.0)
    predPrev := p

    // 5) Update adaptation statistics
    errVar := na(errVar) ? e * e : errVar * (1.0 - alpha) + alpha * e * e
    retVar := na(retVar) ? ret * ret : retVar * (1.0 - alpha) + alpha * ret * ret
    float hit = math.sign(oldPred) == math.sign(ret) ? 1.0 : 0.0
    dirAcc := na(dirAcc) ? hit : dirAcc * (1.0 - alpha) + alpha * hit

// ----------------------------------------------------------------------------
//  DERIVED METRICS
// ----------------------------------------------------------------------------
errStd  = math.sqrt(nz(errVar))
retStd  = math.sqrt(nz(retVar))
conf    = f_clip(1.0 - nz(errVar) / (nz(retVar) + EPS), 0.0, 1.0)   // R^2-like skill vs. zero-forecast
predPct = (math.exp(predNext) - 1.0) * 100.0
isBull  = predNext >  biasBps / 10000.0
isBear  = predNext < -biasBps / 10000.0
dirCol  = isBull ? bullCol : isBear ? bearCol : neutCol
active  = ready and bar_index > warmup and built

// ----------------------------------------------------------------------------
//  PASSIVE VISUALS  (background tint + historical 1-bar fit trail)
// ----------------------------------------------------------------------------
int tintTransp = 92 - int(math.round(conf * 6.0))
bgcolor(showTint and active ? color.new(dirCol, tintTransp) : na)

float predClose = active ? close * math.exp(predNext) : na
plot(showTrail ? predClose : na, "ESN 1-bar fit", color = color.new(dirCol, 55), linewidth = 1, offset = 1)

// ----------------------------------------------------------------------------
//  ACTIVE VISUALS  (forecast cone, glow, end label, dashboard)
// ----------------------------------------------------------------------------
var array<polyline> pls = array.new<polyline>()
var label endLab = na
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 9, bgcolor = color.new(#0b0e16, 20), frame_color = color.new(bullCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast
    // Clear previous drawings
    if array.size(pls) > 0
        for p in pls
            polyline.delete(p)
        array.clear(pls)
    label.delete(endLab)

    // --- Free-running forecast projection ---
    if active and (showCone or showCenter)
        xp = matrix.copy(xst)
        float f1 = u1
        float f2 = u2
        float f3 = u3
        array<float> cRet = array.new<float>(H + 1, 0.0)
        float cum = 0.0
        for h = 1 to H
            float pr = array.get(Wout, N)
            for i = 0 to N - 1
                pr += array.get(Wout, i) * matrix.get(xp, i, 0)
            cum += pr
            array.set(cRet, h, cum)
            // Feed the prediction back; decay slower-moving context features
            f1 := f_clip(pr / (retStd + EPS), -4.0, 4.0) / 4.0
            f2 := f2 * fbDecay
            f3 := f3 * fbDecay
            uA = array.from(f1, f2, f3)
            xp := f_step(Wres, Win, xp, uA, leak, N, FEAT)

        // Forecast centerline
        array<chart.point> ctr = array.new<chart.point>()
        for h = 0 to H
            array.push(ctr, chart.point.from_index(bar_index + h, close * math.exp(array.get(cRet, h))))

        if showGlow and showCenter
            array.push(pls, polyline.new(points = ctr, closed = false, curved = false, xloc = xloc.bar_index, line_color = color.new(dirCol, 70), line_width = 6))
        if showCenter
            array.push(pls, polyline.new(points = ctr, closed = false, curved = false, xloc = xloc.bar_index, line_color = dirCol, line_width = 2))

        // Confidence cone: 3 nested translucent polygons => soft gradient fill
        if showCone
            for layer = 1 to 3
                float frac = layer / 3.0
                array<chart.point> poly = array.new<chart.point>()
                for h = 0 to H
                    float w = bandMult * errStd * math.sqrt(h) * frac
                    array.push(poly, chart.point.from_index(bar_index + h, close * math.exp(array.get(cRet, h) + w)))
                for h = H to 0
                    float w = bandMult * errStd * math.sqrt(h) * frac
                    array.push(poly, chart.point.from_index(bar_index + h, close * math.exp(array.get(cRet, h) - w)))
                int tr = 90 + layer * 2  // fainter outward: 92, 94, 96
                array.push(pls, polyline.new(points = poly, closed = true, curved = false, xloc = xloc.bar_index, line_color = color.new(dirCol, 100), fill_color = color.new(dirCol, tr)))

        // End-of-horizon label
        float totPct = (math.exp(array.get(cRet, H)) - 1.0) * 100.0
        string arrow = isBull ? "▲" : isBear ? "▼" : "◆"
        string labTxt = arrow + " " + (totPct >= 0 ? "+" : "") + str.tostring(totPct, "#.##") + "%  ·  conf " + str.tostring(conf * 100, "#") + "%"
        endLab := label.new(x = bar_index + H, y = close * math.exp(array.get(cRet, H)), text = labTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dirCol, 15), textcolor = #0b0e16, size = size.small)

    // --- Dashboard ---
    if showDash
        float energy = 0.0
        if built
            for i = 0 to N - 1
                energy += math.pow(matrix.get(xst, i, 0), 2)
            energy := math.sqrt(energy) / math.sqrt(N)
        color hdrBg = #0b0e16
        color rowBg = color.new(#11151f, 10)
        string stat = active ? "● ACTIVE" : "◌ LEARNING"
        color  statCol = active ? bullCol : neutCol
        string bias = isBull ? "▲ BULLISH" : isBear ? "▼ BEARISH" : "◆ NEUTRAL"
        table.cell(dash, 0, 0, "AE · ESN",      text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, stat,            text_color = statCol, bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 1, "Bias",          text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 1, bias,            text_color = dirCol,  bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 2, "Next-bar",      text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 2, (predPct >= 0 ? "+" : "") + str.tostring(predPct, "#.###") + "%", text_color = dirCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Confidence",    text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 3, str.tostring(conf * 100, "#") + "%", text_color = color.from_gradient(conf, 0.0, 1.0, neutCol, bullCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 4, "Dir. Accuracy", text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 4, str.tostring(nz(dirAcc) * 100, "#") + "%", text_color = color.from_gradient(nz(dirAcc), 0.40, 0.70, bearCol, bullCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Reservoir",     text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 5, str.tostring(N) + "n · rho " + str.tostring(specRadius, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 6, "Energy",        text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 6, str.tostring(energy, "#.##"), text_color = color.from_gradient(energy, 0.0, 1.0, neutCol, bullCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Learn / Leak",  text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(mu, "#.##") + " / " + str.tostring(leak, "#.##"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 8, "Horizon",       text_color = neutCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 8, str.tostring(H) + " bars", text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
flipBull = active and isBull and not isBull[1]
flipBear = active and isBear and not isBear[1]
alertcondition(flipBull, "ESN turned Bullish", "AE-ESN: forecast flipped bullish")
alertcondition(flipBear, "ESN turned Bearish", "AE-ESN: forecast flipped bearish")
````

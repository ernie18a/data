# AetherEdge - Fractal Geometry + Diffusion Predictor

- url: https://www.tradingview.com/script/gVlgzy4u/
- type: indicator
- pine_id: PUB;65442c93288f4379b6bf166f35dcbb9e
- version: 1.0

## Description

🖊️ Overview

A geometric forecaster unlike any channel or trendline tool. Two ideas combine. First, fractal geometry — a Higuchi-style fractal-dimension estimate and a Hurst-like persistence exponent quantify the market's self-similarity (roughness vs. smoothness). A rough, mean-reverting tape and a smooth, trending one have distinct fractal signatures, and the engine reads which regime is live. Second, diffusion-style generation — echoing how a diffusion model denoises noise into data, the engine seeds many noise vectors and runs a guided reverse process to GENERATE multiple future price paths. Their drift and volatility structure are conditioned on the fractal signature, so trending regimes generate persistent paths and rough regimes generate mean-reverting ones. Visualization: a central forecast line (the mean of generated paths) plus a faint fan of prediction bands whose opacity encodes probability.

🔶 Key Features

Fractal dimension — Higuchi method quantifies market roughness (self-similarity) as D∈[1,2]
Hurst persistence exponent — distinguishes trend-persistence (H>0.5) from mean-reversion (H<0.5)
Diffusion-style path generation — generates multiple future paths by guided reverse diffusion from noise
Fractal guidance — the self-similarity signature steers path drift (classifier-style guidance)
Multi-scenario forecasting — samples many paths to build a per-step distribution
Geometric prediction fan — a central line plus nested probability bands fanning out with horizon
Probability via opacity — band opacity follows Gaussian mass (inner = higher probability = denser)
Intelligence panel — fractal dimension, Hurst exponent, persistence, and the forecast target price at a glance

🧠 Technical Architecture

Fractal geometry: the Higuchi estimator computes the curve length L(k) at each interval k and derives the dimension D from the least-squares slope of log L(k) vs log(1/k). Higher D means a rougher (noisier) series; lower means smoother (more trending). In parallel, a rescaled-range (R/S)-style Hurst exponent is estimated as H = log(R/S) / log(n). The two combine into a persistence score ∈ [-1,1] (+1 strongly trending, −1 strongly mean-reverting).
Diffusion generation: for each path, starting from the current price, each future step runs a reverse-diffusion process over Denoising Steps iterations. Each denoise step shrinks the noise amplitude along a cosine schedule (noisy early, clean late) while progressively strengthening a fractal-guided drift (guidance bites as the noise clears — classifier-style guidance). When persistence is negative (a mean-reverting regime), a pull-back force toward the starting price is added. Repeated across Generated Paths paths, the per-step mean and variance are accumulated via Welford's online algorithm.
Visualization: the per-step mean price forms the central line, and nested bands at multiples of the standard deviation (±k·σ) form the fan. Band opacity is proportional to Gaussian mass exp(−0.5k²), denser inside (higher probability). The fan naturally widens with horizon as variance grows.

⚙️ Recommended Settings & Tuning Guide

BTC (1H–4H): Fractal Window 40, kMax 5, Persistence Window 50, Generated Paths 24, Denoising Steps 8, Horizon 16. Standard settings fit well
ETH (1H–4H): As BTC, with Fan Width 1.0 for standard spread
SOL (15m–1H): High volatility favors Noise Scale 1.2 / Fan Width 1.2 to widen path dispersion, Fractal Guidance 0.5 to soften guidance
XRP (1H–4H): Spike-prone; Persistence Window 40 to weight recent self-similarity, Paths 30 to smooth the distribution
Fractal Window / kMax: a wider window and higher kMax refine the dimension estimate but add compute; 40/5 is practical
Generated Paths: more smooths the distribution but is heavier; 20–40 is a practical balance
Denoising Steps: more smooths paths; ~8 is sufficient
Fractal Guidance: higher lets the fractal signature steer drift more; lower is noise-driven
Render load: the fan draws Fan Bands × Horizon × 2 boxes, so maxing both can hit the 500-object render cap

💡 How to Use in Practice

Reacting to the central line: the mean of generated paths is the most probable future path — its slope and target price are the forecast's core
Reading the fan: a narrow fan = high forecast confidence (paths converge); wide = high uncertainty (paths diverge); the dense inner bands are the high-probability zone
Using the fractal regime: in high-persistence (trending) conditions, follow the central line's direction; in low (mean-reverting), expect the forecast to pull back
Reading fractal dimension: low D (toward 1.0) = smooth trending tape; high (toward 2.0) = rough range/noise — an aid to regime classification
Checking Hurst: H>0.5 trend-persistent, H<0.5 reversion-prone — corroborates the central forecast's direction
Fan width and risk: tighten stops when the fan is narrow, give room when wide
Multi-timeframe usage: confirm the fractal regime and forecast direction on the higher timeframe (4H), then time entries on the lower one (15m–1H)

⚠️ Important Notes

Initial computation period: until the fractal and Hurst windows fill (tens to a hundred-plus bars), the dimension and persistence estimates are unstable; treat forecasts as low-confidence until then
Stochastic generation: diffusion paths are generated from noise seeds, so changing the seed (settings) changes the distribution — forecasts are probabilistic scenario sets, not deterministic
Interpreting the fan: the fan shows where generated paths landed, not a guarantee that price stays within it — it is a probability-density visualization
On look-ahead: fractal dimension, Hurst, and drift are all computed from confirmed past data; the forecast projects from now into the future and can of course be wrong — always forward-test
Render load: box count is Fan Bands × Horizon; lower either if it feels heavy
Constraints: this is a lightweight implementation within Pine's compute budget; the Higuchi dimension, Hurst, and path generation are all approximations

🚨 Disclaimer

This indicator is an analytical and educational visualization tool. The fractal dimension, Hurst exponent, diffusion-style path generation, prediction fan, and central line are quantitative heuristics computed on-chart from price data — they are not financial advice, buy/sell signals, or any guarantee of future performance. Even a probabilistically generated forecast can be wrong. Always combine any tool with your own analysis and disciplined risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AetherEdge

//@version=6

// ════════════════════════════════════════════════════════════════════════════════════════════════
//   AetherEdge - Fractal Geometry + Diffusion Predictor
//   AI Drawing Power Series
//
//   A geometric forecaster unlike any channel or trendline tool. Two ideas combine:
//     • FRACTAL GEOMETRY — the market's self-similarity is measured via a fractal-dimension estimate
//       (Higuchi-style) and a Hurst-like persistence exponent. A rough, mean-reverting tape and a
//       smooth, trending one have distinct fractal signatures; the engine reads which regime is live.
//     • DIFFUSION-STYLE GENERATION — echoing how a diffusion model denoises noise into data, the
//       engine seeds many noise vectors and runs a guided reverse process to GENERATE multiple future
//       price paths. The drift and volatility structure of that process are conditioned on the fractal
//       signature, so trending regimes generate persistent paths and rough regimes generate
//       mean-reverting ones.
//
//   Visualization: a central forecast line (the mean of generated paths) plus a faint FAN of
//   prediction bands whose opacity encodes probability — a fundamentally geometric forecast.
// ════════════════════════════════════════════════════════════════════════════════════════════════

indicator("AetherEdge - Fractal Geometry + Diffusion Predictor", "AE-FG DP", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────

var string GRP_FRAC  = "◆  FRACTAL GEOMETRY"
var string GRP_DIFF  = "◆  DIFFUSION GENERATOR"
var string GRP_PRED  = "◆  PREDICTION FAN"
var string GRP_STYLE = "◆  AESTHETICS"
var string GRP_PANEL = "◆  INTELLIGENCE PANEL"

// — Fractal Geometry —
fracLen      = input.int(40,   "Fractal Window (bars)", minval = 10, maxval = 200, group = GRP_FRAC, tooltip = "Lookback over which the fractal dimension and Hurst-like exponent are estimated.")
kMax         = input.int(5,    "Higuchi kMax",   minval = 2, maxval = 12, group = GRP_FRAC, tooltip = "Maximum interval for the Higuchi fractal-dimension estimator. Higher = finer scaling fit.")
hurstLen     = input.int(50,   "Persistence Window", minval = 10, maxval = 300, group = GRP_FRAC, tooltip = "Window for the Hurst-like persistence exponent (trend-persistence vs. mean-reversion).")
selfSimSmooth= input.int(3,    "Self-Similarity Smoothing", minval = 1, maxval = 20, group = GRP_FRAC)

// — Diffusion Generator —
nPaths       = input.int(24,   "Generated Paths",  minval = 5, maxval = 80, group = GRP_DIFF, tooltip = "Number of future price paths the diffusion-style generator samples per bar.")
diffSteps    = input.int(8,    "Denoising Steps",  minval = 2, maxval = 30, group = GRP_DIFF, tooltip = "Reverse-diffusion steps used to refine each generated path (more = smoother paths).")
noiseScale   = input.float(1.0, "Noise Scale", minval = 0.2, maxval = 3.0, step = 0.1, group = GRP_DIFF, tooltip = "Overall magnitude of the diffusion noise (path dispersion).")
guideStr     = input.float(0.6, "Fractal Guidance", minval = 0.0, maxval = 1.5, step = 0.05, group = GRP_DIFF, tooltip = "How strongly the fractal signature steers the drift of generated paths (classifier-style guidance).")
seedInp      = input.int(47,   "Noise Seed",      minval = 1, maxval = 9999, group = GRP_DIFF)

// — Prediction Fan —
predLook     = input.int(16,   "Forecast Horizon (bars)", minval = 2, maxval = 60, group = GRP_PRED)
fanBands     = input.int(4,    "Fan Bands",      minval = 1, maxval = 8, group = GRP_PRED, tooltip = "Number of probability bands forming the fan (±0.5σ, ±1σ, ...).")
fanWidth     = input.float(1.0, "Fan Width Scale", minval = 0.2, maxval = 3.0, step = 0.1, group = GRP_PRED)

// — Aesthetics —
colUp        = input.color(#21d3a3, "Bullish Forecast", group = GRP_STYLE, inline = "c1")
colDn        = input.color(#ff5d73, "Bearish Forecast", group = GRP_STYLE, inline = "c1")
colMid       = input.color(#5ce1ff, "Central Line", group = GRP_STYLE)
fanTransp    = input.int(82,   "Fan Base Transparency", minval = 60, maxval = 96, group = GRP_STYLE)
showSamples  = input.bool(false,"Show Sample Paths", group = GRP_STYLE, tooltip = "Draw a few individual generated paths (thin lines) for intuition.")
sampleCount  = input.int(5,    "Sample Paths to Draw", minval = 1, maxval = 12, group = GRP_STYLE)
glowFx       = input.bool(true, "Glow / Halo Effect", group = GRP_STYLE)

// — Intelligence Panel —
showPanel    = input.bool(true, "Show Intelligence Panel", group = GRP_PANEL)
panelPos     = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = GRP_PANEL)
panelSize    = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_PANEL)

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  THEME / PALETTE
// ────────────────────────────────────────────────────────────────────────────────────────────────

var color THEME_BG   = color.new(#0a0d15, 8)
var color THEME_GRID = color.new(#222b40, 38)
var color THEME_TXT  = #d2dae8
var color THEME_DIM  = #6b7689
var color THEME_ACC  = #5ce1ff
var color THEME_GOLD = #f4c25b

// ────────────────────────────────────────────────────────────────────────────────────────────────
//  PRNG / NOISE
// ────────────────────────────────────────────────────────────────────────────────────────────────

f_rand(int s) =>
    float x = math.abs(s % 2147483647) + 1.0
    float h = x * 12.9898 + 78.233
    float v = math.sin(h) * 43758.5453
    v - math.floor(v)

// approx Gaussian via sum-of-uniforms (central limit), zero-mean
f_gauss(int s) =>
    (f_rand(s) + f_rand(s * 7919 + 1) + f_rand(s * 104729 + 2) - 1.5) * 1.1547

atr = ta.atr(14)

// ── Rolling close-price history ──
// Pine's [] history operator needs a simple/const offset, so a loop variable can't index it
// (e.g. close[idx] where idx is a loop counter is illegal). We therefore keep a rolling array of
// recent closes and read them with array.get(index), where the index CAN be a series int.
// Index 0 = most recent (current bar), increasing index = further back.
var array<float> pxHist = array.new_float()

if barstate.isconfirmed
    array.unshift(pxHist, close)   // most recent confirmed at front (index 0)
    int capPx = math.max(fracLen, hurstLen) + 10
    while array.size(pxHist) > capPx
        array.pop(pxHist)

// safe accessor: returns close n bars back (n=0 → current), clamped to available history
f_px(int n) =>
    int sz = array.size(pxHist)
    int i = math.max(0, math.min(sz - 1, n))
    sz == 0 ? close : array.get(pxHist, i)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  FRACTAL GEOMETRY
//  (1) Higuchi fractal dimension over the price series → roughness (D∈~[1,2]).
//  (2) Hurst-like persistence exponent via rescaled-range-style ratio → trend persistence.
//  Self-similarity signature drives the diffusion drift/volatility.
// ════════════════════════════════════════════════════════════════════════════════════════════════

// --- Higuchi fractal dimension ---
// For each interval k, compute curve length L(k); D ≈ -slope of log L(k) vs log(1/k).
// We accumulate Σ(log(1/k)·logL) etc. for a least-squares slope over k = 1..kMax.
f_higuchiDim() =>
    float sumX = 0.0
    float sumY = 0.0
    float sumXY = 0.0
    float sumXX = 0.0
    int cnt = 0
    for k = 1 to kMax
        // average normalized curve length at interval k
        float lenAccum = 0.0
        int mCount = 0
        for m = 0 to k - 1
            float lm = 0.0
            int steps = 0
            // walk indices m, m+k, m+2k, ... within the fractal window
            int idx = m
            while idx + k < fracLen
                float a = f_px(idx)
                float b = f_px(idx + k)
                lm += math.abs(b - a)
                steps += 1
                idx += k
            if steps > 0
                float norm = (fracLen - 1.0) / (steps * k)
                lenAccum += (lm * norm) / k
                mCount += 1
        if mCount > 0
            float Lk = lenAccum / mCount
            if Lk > 0
                float lx = math.log(1.0 / k)
                float ly = math.log(Lk)
                sumX += lx
                sumY += ly
                sumXY += lx * ly
                sumXX += lx * lx
                cnt += 1
    float slope = (cnt * sumXX - sumX * sumX) == 0 ? 1.5 : (cnt * sumXY - sumX * sumY) / (cnt * sumXX - sumX * sumX)
    // Higuchi D is the slope of logL vs log(1/k)
    math.max(1.0, math.min(2.0, slope))

// --- Hurst-like persistence exponent ---
// rescaled-range style: H>0.5 trending/persistent, H<0.5 mean-reverting/anti-persistent
f_hurst() =>
    float meanRet = 0.0
    for i = 0 to hurstLen - 1
        meanRet += (f_px(i) - f_px(i + 1))
    meanRet := meanRet / hurstLen
    float cum = 0.0
    float maxC = -1e18
    float minC = 1e18
    float sumSq = 0.0
    for i = 0 to hurstLen - 1
        float dev = (f_px(i) - f_px(i + 1)) - meanRet
        cum += dev
        maxC := math.max(maxC, cum)
        minC := math.min(minC, cum)
        sumSq += dev * dev
    float R = maxC - minC
    float S = math.sqrt(sumSq / hurstLen)
    float RS = S == 0 ? 1.0 : R / S
    float H = RS <= 0 ? 0.5 : math.log(RS) / math.log(hurstLen)
    math.max(0.0, math.min(1.0, H))

fracDimRaw = f_higuchiDim()
hurstRaw   = f_hurst()

fracDim = ta.sma(fracDimRaw, selfSimSmooth)
hurst   = ta.sma(hurstRaw, selfSimSmooth)

// self-similarity → regime read:
//   low D / high H = smooth, persistent (trending);  high D / low H = rough, anti-persistent (mean-revert)
// persistence ∈ [-1,1]: +1 strongly trending, -1 strongly mean-reverting
persistence = math.max(-1.0, math.min(1.0, (hurst - 0.5) * 2.0 - (fracDim - 1.5) * 1.0))

// recent normalized drift (per-bar) to seed the path direction
driftRaw = (close - close[predLook]) / (predLook * (atr == 0 ? 1.0 : atr))
realizedVol = ta.stdev(close - close[1], fracLen)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  DIFFUSION-STYLE PATH GENERATOR
//  For each path: start from pure noise increments, then run `diffSteps` reverse-denoising passes
//  that pull increments toward a fractal-guided drift (classifier-style guidance) while shrinking
//  noise each step (a cosine-like schedule). The endpoint distribution forms the forecast fan.
//
//  We only need the per-horizon distribution (mean, std at each future step), so we accumulate
//  the running price at each forward step across paths into mean/M2 (Welford) arrays.
// ════════════════════════════════════════════════════════════════════════════════════════════════

// arrays holding, per forecast step h = 0..predLook, the running mean & sumSq of generated prices
var array<float> stepMean = na
var array<float> stepM2   = na
// keep a few sample paths for optional drawing: store endpoint-per-step for first `sampleCount` paths
var array<float> samplePaths = na   // flattened [sampleCount * (predLook+1)]

if na(stepMean)
    stepMean := array.new_float(predLook + 1, 0.0)
    stepM2   := array.new_float(predLook + 1, 0.0)
    samplePaths := array.new_float((sampleCount) * (predLook + 1), 0.0)

bool inHorizon = bar_index > fracLen + hurstLen + predLook

var float liveDim = na
var float liveHurst = na
var float livePersist = 0.0

// regenerate paths only on the last bar (forecast is forward-looking from "now")
f_generate() =>
    int steps1 = predLook + 1
    // reset accumulators
    for i = 0 to steps1 - 1
        array.set(stepMean, i, 0.0)
        array.set(stepM2, i, 0.0)

    // fractal-guided per-bar drift and base volatility
    float guidedDrift = guideStr * persistence * (atr * 0.15) + driftRaw * atr * 0.10
    float baseVol = (na(realizedVol) ? atr : realizedVol) * noiseScale
    // roughness modulation: higher fractal dim → noisier increments
    float roughMul = 0.6 + (fracDim - 1.0)   // D∈[1,2] → mul∈[0.6,1.6]

    for p = 0 to nPaths - 1
        float price = close
        // initialize this path's "noise budget" — diffusion starts noisy, denoises over steps
        for h = 1 to predLook
            // reverse-diffusion: noise amplitude shrinks across denoising steps (cosine-like)
            float denoiseAccum = 0.0
            float driftAccum = 0.0
            for d = 0 to diffSteps - 1
                // cosine schedule: early steps noisier, later steps cleaner
                float frac = d / math.max(1, diffSteps - 1)
                float sched = math.cos(frac * 1.5708)   // 1 → 0 across steps
                int nseed = (seedInp + p * 100003 + h * 911 + d * 17) % 2147483647
                float z = f_gauss(nseed) * baseVol * roughMul * sched
                // classifier-style guidance pulls increments toward the fractal-guided drift
                float guided = guidedDrift * (1.0 - sched)   // guidance strengthens as noise clears
                denoiseAccum += z
                driftAccum += guided
            // averaged increment for this forward bar
            float inc = (denoiseAccum + driftAccum) / diffSteps
            // persistence shaping: trending regimes auto-correlate increments, mean-revert pulls back
            if persistence < 0
                // anti-persistent: pull back toward starting price
                inc += persistence * (price - close) * 0.05
            price := price + inc
            // accumulate into running mean / M2 (Welford online)
            float old = array.get(stepMean, h)
            float cntF = p + 1.0
            float delta = price - old
            float newMean = old + delta / cntF
            array.set(stepMean, h, newMean)
            array.set(stepM2, h, array.get(stepM2, h) + delta * (price - newMean))
            // store sample path endpoints for first few paths
            if p < sampleCount
                array.set(samplePaths, p * steps1 + h, price)
        if p < sampleCount
            array.set(samplePaths, p * steps1 + 0, close)
    // set step 0 mean = close
    array.set(stepMean, 0, close)
    array.set(stepM2, 0, 0.0)

if inHorizon
    liveDim := fracDim
    liveHurst := hurst
    livePersist := persistence

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION  — central forecast line + faint probability fan
// ════════════════════════════════════════════════════════════════════════════════════════════════

color dirCol = livePersist >= 0 ? (driftRaw >= 0 ? colUp : colDn) : (driftRaw >= 0 ? colUp : colDn)
color fanCol = driftRaw >= 0 ? colUp : colDn

// persistent line/box collections for the fan
var array<line> fanLines = array.new<line>()
var array<box>  fanBoxes = array.new<box>()
var line centerLine = na
var line centerGlow = na
var array<line> sampleLines = array.new<line>()

if inHorizon and barstate.islast
    f_generate()

    // --- clear previous drawings ---
    if array.size(fanBoxes) > 0
        for i = 0 to array.size(fanBoxes) - 1
            box.delete(array.get(fanBoxes, i))
        array.clear(fanBoxes)
    if array.size(sampleLines) > 0
        for i = 0 to array.size(sampleLines) - 1
            line.delete(array.get(sampleLines, i))
        array.clear(sampleLines)
    if not na(centerLine)
        line.delete(centerLine)
    if not na(centerGlow)
        line.delete(centerGlow)

    int x0 = bar_index
    float meanEnd = array.get(stepMean, predLook)
    float stdEnd = math.sqrt(array.get(stepM2, predLook) / math.max(1.0, nPaths))

    // --- prediction fan: nested bands around the per-step mean path ---
    // each band j spans (j-1)·step .. j·step of the std envelope; outer bands fainter.
    for j = fanBands to 1
        float kOuter = (j * 1.0) / fanBands * 2.0       // outer multiple of std (up to 2σ)
        float kInner = ((j - 1) * 1.0) / fanBands * 2.0
        // Gaussian-mass-based opacity: inner (smaller k) = denser
        float mass = math.exp(-0.5 * kInner * kInner)
        int trans = int(math.max(58, fanTransp - mass * 30))
        // draw the band as a sequence of small boxes stepping forward (fan shape: widens with horizon)
        for h = 1 to predLook
            float mh = array.get(stepMean, h)
            float sh = math.sqrt(array.get(stepM2, h) / math.max(1.0, nPaths)) * fanWidth
            float topO = mh + kOuter * sh
            float botO = mh + kInner * sh
            // upper band slice
            box bxU = box.new(x0 + h - 1, topO, x0 + h, botO, xloc = xloc.bar_index, border_width = 0, bgcolor = color.new(fanCol, trans))
            array.push(fanBoxes, bxU)
            // mirror lower band slice
            float topL = mh - kInner * sh
            float botL = mh - kOuter * sh
            box bxL = box.new(x0 + h - 1, topL, x0 + h, botL, xloc = xloc.bar_index, border_width = 0, bgcolor = color.new(fanCol, trans))
            array.push(fanBoxes, bxL)

    // --- central forecast line (mean path) ---
    if glowFx
        centerGlow := line.new(x0, close, x0 + predLook, meanEnd, xloc = xloc.bar_index, color = color.new(colMid, 60), width = 5)
    centerLine := line.new(x0, close, x0 + predLook, meanEnd, xloc = xloc.bar_index, color = color.new(colMid, 0), width = 2, style = line.style_arrow_right)

    // --- optional sample paths ---
    if showSamples
        int steps1 = predLook + 1
        for sp = 0 to math.min(sampleCount, nPaths) - 1
            // draw each sample path as a polyline of segments
            for h = 1 to predLook
                float y1 = array.get(samplePaths, sp * steps1 + (h - 1))
                float y2 = array.get(samplePaths, sp * steps1 + h)
                line sl = line.new(x0 + h - 1, y1, x0 + h, y2, xloc = xloc.bar_index, color = color.new(fanCol, 55), width = 1)
                array.push(sampleLines, sl)

// glow accent on strong-persistence bars
plot(glowFx and inHorizon and math.abs(livePersist) > 0.4 ? close : na, "Persistence Glow", color = color.new(fanCol, 60), linewidth = 3, style = plot.style_circles, force_overlay = true)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  INTELLIGENCE PANEL
// ════════════════════════════════════════════════════════════════════════════════════════════════

f_panelPos() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_panelSize() =>
    switch panelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_bar(float v01) =>
    int filled = int(math.round(math.max(0.0, math.min(1.0, v01)) * 12))
    string s = ""
    for i = 1 to 12
        s := s + (i <= filled ? "█" : "░")
    s

f_signedBar(float b) =>
    int half = 6
    int mag = int(math.round(math.min(1.0, math.abs(b)) * half))
    string s = ""
    for i = 1 to half
        s := s + (b < 0 and i > half - mag ? "█" : "░")
    s := s + "│"
    for i = 1 to half
        s := s + (b > 0 and i <= mag ? "█" : "░")
    s

var table panel = na
if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(), 3, 10, bgcolor = THEME_BG, frame_color = THEME_GRID, frame_width = 1, border_color = THEME_GRID, border_width = 1)

    float pd = na(liveDim) ? 1.5 : liveDim
    float ph = na(liveHurst) ? 0.5 : liveHurst
    string regime = livePersist > 0.25 ? "TRENDING" : livePersist < -0.25 ? "MEAN-REVERTING" : "NEUTRAL"
    color regCol = livePersist > 0.25 ? colUp : livePersist < -0.25 ? colDn : THEME_DIM

    float meanEndP = array.get(stepMean, predLook)
    float predMoveATR = atr == 0 ? 0.0 : (meanEndP - close) / atr

    table.cell(panel, 0, 0, "◆  AETHEREDGE", text_color = THEME_GOLD, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(#10131c, 0))
    table.cell(panel, 1, 0, "", bgcolor = color.new(#10131c, 0))
    table.cell(panel, 2, 0, "FRACTAL ⊕ DIFFUSION", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right, bgcolor = color.new(#10131c, 0))

    table.cell(panel, 0, 1, "  " + regime, text_color = #0a0d15, text_size = f_panelSize(), text_halign = text.align_left, bgcolor = color.new(regCol, 0))
    table.merge_cells(panel, 0, 1, 2, 1)

    table.cell(panel, 0, 2, "Fractal Dimension", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 2, f_bar((pd - 1.0)), text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 2, str.tostring(pd, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 3, "Hurst Exponent", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 3, f_bar(ph), text_color = ph >= 0.5 ? colUp : colDn, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 3, str.tostring(ph, "#.###"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 4, "Persistence", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 4, f_signedBar(livePersist), text_color = regCol, text_size = f_panelSize(), text_halign = text.align_center)
    table.cell(panel, 2, 4, str.tostring(livePersist, "+#.##;-#.##"), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 5, "FORECAST", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.merge_cells(panel, 0, 5, 2, 5)

    table.cell(panel, 0, 6, "Central Move", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 6, "", text_size = f_panelSize())
    table.cell(panel, 2, 6, str.tostring(predMoveATR, "+#.##;-#.##") + " ATR", text_color = predMoveATR >= 0 ? colUp : colDn, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 7, "Target Price", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 7, "", text_size = f_panelSize())
    table.cell(panel, 2, 7, str.tostring(meanEndP, format.mintick), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 8, "Paths / Steps", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 8, str.tostring(nPaths), text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 2, 8, str.tostring(diffSteps) + " denoise", text_color = THEME_ACC, text_size = f_panelSize(), text_halign = text.align_right)

    table.cell(panel, 0, 9, "Horizon", text_color = THEME_DIM, text_size = f_panelSize(), text_halign = text.align_left)
    table.cell(panel, 1, 9, "", text_size = f_panelSize())
    table.cell(panel, 2, 9, str.tostring(predLook) + " bars", text_color = THEME_TXT, text_size = f_panelSize(), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════════════════════════

alertcondition(not na(liveDim) and livePersist > 0.4, "Fractal ▸ Strong Trending Regime", "AetherEdge Fractal-Diffusion: strongly trending (persistent) regime detected.")
alertcondition(not na(liveDim) and livePersist < -0.4, "Fractal ▸ Strong Mean-Revert Regime", "AetherEdge Fractal-Diffusion: strongly mean-reverting regime detected.")
````

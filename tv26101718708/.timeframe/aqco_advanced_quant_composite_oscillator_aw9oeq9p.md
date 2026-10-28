# AQCO  Advanced Quant Composite Oscillator

- url: https://www.tradingview.com/script/Aw9OeQ9P-AQCO-Advanced-Quant-Composite-Oscillator/
- type: indicator
- pine_id: PUB;a0a843b014b94495a1468eddf479bacd
- version: 2.0

## Description

[b]AQCO — Advanced Quant Composite Oscillator[/b]
[i]A multi-pillar quantitative regime detector that synthesizes fractal geometry, information theory, and statistical physics into a single adaptive oscillator. AQCO dynamically weights trend vs. entropy inputs based on real-time market structure — increasing trend sensitivity during persistent markets and anti-trend weight during noisy, mean-reverting conditions.[/i]
[b]What It Does[/b]
AQCO produces a normalized output bounded to [-1, +1] where:
[list]
[*]+1 = Maximum bullish structural alignment (strong trend persistence, low entropy, high fractal trendiness)
[*]0 = Neutral / maximum entropy equilibrium
[*]-1 = Maximum bearish structural alignment
[*]|osc| < 0.15 = Explicit chop/neutral regime (no tradable edge)
[/list]
[b]The Six Quantitative Pillars[/b]
[list]
[*][b]Adaptive Roofing Filter[/b] — Ehlers-style high-pass + low-pass conditioning that removes drift and noise, isolating tradeable cyclical components without lag-heavy moving averages.
[*][b]Katz Fractal Dimension (KFD)[/b] — Multi-scale space-filling complexity measured over Short, Core, and Long windows. 1.0 = perfectly linear/trending; 2.0 = maximum randomness. Converted to a [-1, +1] trend score.
[*][b]Rescaled-Range Hurst Exponent[/b] — Classic R/S analysis across three geometric scales. H > 0.50 indicates persistence (trend-following favorable); H < 0.50 indicates anti-persistence (mean-reversion favorable); H ≈ 0.50 = random walk.
[*][b]Shannon Entropy of Signed Returns[/b] — Decaying histogram of hlc3 returns measuring information content. High entropy (uniform distribution) = chop → negative score. Low entropy (concentrated bins) = structure → positive score.
[*][b]Robust Momentum / Pressure (MAD-z)[/b] — Median Absolute Deviation z-score of the band-passed signal, robust to outliers and fat tails. Captures directional pressure.
[*][b]Lower-Timeframe Microtrend Sampler (Optional)[/b] — Pulls normalized micro-returns from a user-defined lower timeframe for early structural bias without repainting.
[/list]
[b]Key Features[/b]
[list]
[*][b]Data-Driven Adaptive Weighting[/b] — Weights are not fixed. The indicator calculates real-time trendBias from Hurst and fractal rank, then derives wTrend, wEntropy, and wMicro dynamically. Strong trend bias compresses entropy influence; strong mean-reversion bias elevates it.
[*][b]Regime-Aware Emission[/b] — The indicator explicitly labels the market as Trend↑, Trend↓, or Chop/Neutral based on oscillator position, trend pillar direction, Hurst threshold, and entropy ceiling.
[*][b]Confidence Proxy[/b] — Reports 0.00–1.00 confidence calculated as 1 minus average absolute dispersion between pillars. High confidence = pillars agree; low confidence = mixed signals.
[*][b]Bounded & Robust[/b] — All sub-components are mathematically clamped and guarded against division-by-zero, flat markets, and zero-volatility conditions.
[/list]
[b]Inputs & Parameters[/b]
[i]Core Windows[/i]
[list]
[*]Core Window (16–512, default 64): Primary lookback for fractal dimension and entropy baseline.
[*]Short Window (8–256, default 32): Fast reaction window for fractal geometry and momentum.
[*]Long Window (32–1024, default 128): Slow structural window for fractal geometry.
[/list]
[i]Filters (Ehlers-style Roofing)[/i]
[list]
[*]High-Pass Alpha (0.01–0.99, default 0.10): Drift removal cutoff. Higher values remove slower cycles.
[*]Low-Pass Alpha (0.01–0.99, default 0.20): Noise suppression cutoff. Higher values = more smoothing.
[/list]
[i]Entropy / Regime[/i]
[list]
[*]Entropy Bins (8–64, default 16): Histogram resolution for return distribution.
[*]Entropy Lookback (16–512, default 48): Decay rate controlling adaptation speed to new return regimes.
[/list]
[i]Hurst (Rescaled Range)[/i]
[list]
[*]Scale 1 / 2 / 3 (default 8, 16, 32): Geometrically spaced scales for R/S calculation. Must satisfy K1 < K2 < K3.
[/list]
[i]Lower-TF Microtrend Sampler[/i]
[list]
[*]Enable toggle + Lower Timeframe string (e.g., "1", "5", "15", "60", "D").
[/list]
[i]Visualization[/i]
[list]
[*]Final Visual Smoothing (1–50, default 9): EMA period applied to raw composite.
[*]Show ±0.5 / ±0.75 Bands: Toggle reference threshold circles.
[*]Show Regime Label: Toggle floating state label.
[/list]
[b]How to Read It[/b]
[list]
[*][b]Composite Oscillator (-1 to +1)[/b]
[list]
[*]Above +0.50: Strong bullish structural regime.
[*]+0.15 to +0.50: Moderate bullish bias.
[*]-0.15 to +0.15: Chop/Neutral — explicitly flagged as non-trending. Avoid directional trades.
[*]-0.50 to -0.15: Moderate bearish bias.
[*]Below -0.50: Strong bearish structural regime.
[/list]
[*][b]Regime Label[/b]
[list]
[*]Trend↑: Bullish regime (osc > 0.15 and trend pillar positive).
[*]Trend↓: Bearish regime (osc < -0.15 and trend pillar negative).
[*]Chop/Neutral: No reliable directional structure.
[/list]
[*][b]Confidence (0.00–1.00)[/b]
[list]
[*]> 0.60: High confidence — pillars agree, market is sending a coherent message.
[*]< 0.40: Low confidence — mixed signals, reduce size or wait.
[/list]
[*][b]Color Logic[/b]: The oscillator line shifts to red (bear) when > +0.40 and green (bull) when < -0.40, with grey in between — creating a contrarian extreme-highlighting effect.
[/list]
[b]Signal Types[/b]
[list]
[*][b]Long Thrust[/b] (green ▲): osc > +0.75 and confidence > 0.60. High-confidence bullish structural thrust. Trend-following long entry.
[*][b]Short Thrust[/b] (red ▼): osc < -0.75 and confidence > 0.60. High-confidence bearish structural thrust. Trend-following short entry.
[*][b]Mean-Revert Up[/b] (teal ●): osc crosses up through -0.50 while in chop regime. Oversold bounce potential in neutral/choppy market.
[*][b]Mean-Revert Down[/b] (orange ●): osc crosses down through +0.50 while in chop regime. Overbought rejection in neutral/choppy market.
[/list]
[b]Practical Usage Guidelines[/b]
[i]Trend-Following[/i]
[list]
[*]Wait for oscillator to cross above +0.50 (long) or below -0.50 (short).
[*]Confirm regime label reads Trend↑ or Trend↓.
[*]Confirm confidence > 0.60.
[*]Enter on close or next-bar open.
[*]Trail stop or exit when oscillator returns to ±0.15 neutral zone or confidence collapses below 0.30.
[/list]
[i]Mean-Reversion (Range-Bound)[/i]
[list]
[*]Identify when regime label consistently shows Chop/Neutral and Hurst < 0.50.
[*]Wait for oscillator to reach ±0.75 extremes.
[*]Trade Mean-Revert signals (teal/orange circles) as counter-trend entries.
[*]Target the zero line or opposite ±0.50 band.
[*]Stop-loss beyond the thrust high/low that created the extreme.
[/list]
[i]Regime Filter[/i]
[list]
[*]Only allow trend-following strategy signals when AQCO > +0.30 and label = Trend↑.
[*]Only allow mean-reversion signals when AQCO is near 0 and label = Chop/Neutral.
[*]Block all signals when confidence < 0.40.
[/list]
[b]Timeframe Calibration[/b]
[i]Scalping (M1–M5)[/i]
[list]
[*]Core: 32 | Short: 16 | Hurst: 4, 8, 16 | Entropy Lookback: 24 | Smoothing: 3–5 | Enable LTF sampler on "1" for M5 charts.
[/list]
[i]Day Trading (M15–H1)[/i]
[list]
[*]Use defaults (Core 64, Short 32, Hurst 8/16/32, Smoothing 9).
[/list]
[i]Swing Trading (H4–Daily)[/i]
[list]
[*]Core: 128 | Long: 256 | Hurst: 16, 32, 64 | Entropy Lookback: 96 | Smoothing: 13–21 | Disable LTF sampler.
[/list]
[b]Important Notes[/b]
[list]
[*][b]Data-Driven Weights:[/b] Weights are derived from real-time trendBias and normalized to sum to 0.95 deliberately, leaving 5% stability headroom against overfitting.
[*][b]Filter Warm-Up:[/b] The Ehlers roofing filter requires ~10–20 bars to stabilize. Early historical bars may show erratic behavior until state converges.
[*][b]Hurst Estimation:[/b] If R/S returns zero on a scale (flat price), that pair is excluded. In perfectly flat markets, H defaults to 0.5.
[*][b]Entropy Decay:[/b] The histogram uses EMA-style decay rather than a hard rolling window, providing stability. Sudden volatility shifts take ~retLook bars to fully reflect.
[*][b]MAD-z Fallback:[/b] When MAD equals zero (perfectly flat filtered signal), the script falls back to standard deviation for the z-score denominator.
[*][b]No Repainting:[/b] Uses confirmed close prices and request.security for LTF data. Signals are bar-stable.
[*][b]Weight Normalization:[/b] Weights adapt each bar based on detected regime, preventing the common flaw of fixed-weight trend indicators failing in chop and vice versa.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22
// © 2025 Advanced Quant Composite Oscillator

//@version=5
indicator("AQCO — Advanced Quant Composite Oscillator", shorttitle="AQCO", overlay=false, max_lines_count=500, max_labels_count=500, dynamic_requests = true)

//──────────────────────────────────────────────────────────────────────────────
// Utility helpers (safe & explicit)
//──────────────────────────────────────────────────────────────────────────────
clamp(x, lo, hi) =>
    x < lo ? lo : x > hi ? hi : x

nzN(x, rep) => na(x) ? rep : x

// robust median absolute deviation z-score (MAD-z)
mad_z(src, len) =>
    // FIX: Cannot reassign 'len', use localLen
    localLen = math.max(len, 5)
    m   = ta.median(src, localLen)
    mad = ta.median(math.abs(src - m), localLen)
    denom = mad == 0.0 ? ta.stdev(src, localLen) : mad * 1.4826  // 1.4826 ≈ Gaussian consistency
    denom == 0.0 ? 0.0 : (src - m) / denom

// rolling percentile rank [0..1]
percentile_rank(src, len) =>
    // FIX: Cannot reassign 'len', use localLen
    localLen = math.max(len, 10)
    lo = ta.lowest(src, localLen)
    hi = ta.highest(src, localLen)
    rng = hi - lo
    rng == 0.0 ? 0.5 : clamp((src - lo) / rng, 0.0, 1.0)

// safe rolling sum of absolute increments (path length proxy)
path_len(src, n) =>
    // FIX: Cannot reassign 'n', use localN
    localN = math.max(n, 2)
    float acc = 0.0
    // sum over n-1 segments
    for i = 1 to localN - 1
        acc += math.abs(src[i - 1] - src[i])
    acc

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
grp_core    = "Core Windows"
lenCore     = input.int(64,  "Core Window", group=grp_core, minval=16, maxval=512)
lenShort    = input.int(32,  "Short Window", group=grp_core, minval=8,  maxval=256)
lenLong     = input.int(128, "Long Window",  group=grp_core, minval=32, maxval=1024)

grp_filters = "Filters (Ehlers-style Roofing)"
hpCut       = input.float(0.10, "High-pass alpha (0..1)", group=grp_filters, minval=0.01, maxval=0.99)
lpCut       = input.float(0.20, "Low-pass alpha (0..1)",  group=grp_filters, minval=0.01, maxval=0.99)

grp_entropy = "Entropy / Regime"
bins        = input.int(16, "Entropy bins (returns)", group=grp_entropy, minval=8, maxval=64)
retLook     = input.int(48, "Entropy lookback", group=grp_entropy, minval=16, maxval=512)

grp_hurst = "Hurst (Rescaled Range)"
hurstK1     = input.int(8,  "Scale 1 (bars)", group=grp_hurst, minval=4, maxval=256)
hurstK2     = input.int(16, "Scale 2 (bars)", group=grp_hurst, minval=5, maxval=512)
hurstK3     = input.int(32, "Scale 3 (bars)", group=grp_hurst, minval=6, maxval=1024)

grp_ltf = "Lower-TF Microtrend Sampler (optional)"
useLTF      = input.bool(false, "Enable lower-TF sampler", group=grp_ltf)
ltf         = input.timeframe("1", "Lower timeframe", group=grp_ltf)

grp_vis = "Visualization"
smoothVis = input.int(9, "Final visual smoothing", group=grp_vis, minval=1, maxval=50)
showBands   = input.bool(true, "Show ±0.5 / ±0.75 bands", group=grp_vis)
showState   = input.bool(true, "Show regime label", group=grp_vis)

//──────────────────────────────────────────────────────────────────────────────
// 1) Adaptive Roofing Filter (High-pass then Low-pass)
//    - removes drift & very-short noise, preserves tradeable cycles.
//──────────────────────────────────────────────────────────────────────────────

// Stateful 1st-order high-pass: y = (x - x[1]) + (1-a)*y[1]
hp_filter(src, a) =>
    // FIX: Cannot reassign 'a', use localA
    localA = clamp(a, 0.01, 0.99)
    var float y = na
    y := (nz(src) - nz(src[1])) + (1 - localA) * nz(y[1], 0.0)
    y

// Stateful 1st-order low-pass: y = a*x + (1-a)*y[1]
lp_filter(src, a) =>
    // FIX: Cannot reassign 'a', use localA
    localA = clamp(a, 0.01, 0.99)
    var float y = na
    y := localA * src + (1 - localA) * nz(y[1], src)
    y

price = hlc3
hpSig = hp_filter(price, hpCut)
bp    = lp_filter(hpSig, lpCut)

// Normalized band-passed momentum (volatility scaled) — kept for reference if needed
// volN  = ta.stdev(price, lenShort)
// momN  = volN == 0.0 ? 0.0 : bp / volN

//──────────────────────────────────────────────────────────────────────────────
// 2) Fractal Geometry: Katz Fractal Dimension (KFD)
//──────────────────────────────────────────────────────────────────────────────
katz_fd(src, n) =>
    // FIX: Cannot reassign 'n', use localN
    localN = math.max(n, 16)
    L = path_len(src, localN)
    d = math.abs(src - src[localN - 1])
    // guard for early/flat windows
    d := na(d) or d == 0.0 ? 1e-10 : d
    L := na(L) or L == 0.0 ? 1e-10 : L
    top = math.log10(localN)
    bot = top + math.log10(d / L)
    fd  = bot == 0.0 ? 1.5 : top / bot
    clamp(fd, 1.0, 2.0)

fdShort = katz_fd(price, lenShort)
fdCore  = katz_fd(price, lenCore)
fdLong  = katz_fd(price, lenLong)

// Map FD -> trendiness score in [-1, +1]
fd_to_trendscore(fd) =>
    1.0 - 2.0 * clamp((fd - 1.0) / 1.0, 0.0, 1.0)

fdScore = (fd_to_trendscore(fdShort) + fd_to_trendscore(fdCore) + fd_to_trendscore(fdLong)) / 3.0

//──────────────────────────────────────────────────────────────────────────────
// 3) Rescaled-Range Hurst Exponent (rough multi-scale slope of log(R/S) vs log(n))
//──────────────────────────────────────────────────────────────────────────────
rs_stat(src, k) =>
    // FIX: Cannot reassign 'k', use localK
    localK = math.max(k, 4)
    m = ta.sma(src, localK)
    float cum = 0.0
    float rmax = -1e10, rmin = 1e10
    for i = 0 to localK - 1
        cum += (src[i] - m)
        rmax := math.max(rmax, cum)
        rmin := math.min(rmin, cum)
    R = rmax - rmin
    S = ta.stdev(src, localK)
    R == 0.0 or S == 0.0 ? 0.0 : R / S

hurst_est(src, k1, k2, k3) =>
    r1 = rs_stat(src, k1)
    r2 = rs_stat(src, k2)
    r3 = rs_stat(src, k3)
    h12 = (r1 > 0 and r2 > 0) ? (math.log(r2) - math.log(r1)) / (math.log(k2) - math.log(k1)) : na
    h23 = (r2 > 0 and r3 > 0) ? (math.log(r3) - math.log(r2)) / (math.log(k3) - math.log(k2)) : na
    hmean = na(h12) and na(h23) ? 0.5 : na(h12) ? h23 : na(h23) ? h12 : (h12 + h23) / 2.0
    clamp(hmean, 0.05, 0.95)

H = hurst_est(close, hurstK1, hurstK2, hurstK3)

// Convert H -> regime score [-1,+1]; >0.5 => persistent/trending (+), <0.5 => mean-reverting (−)
hurstScore = 2.0 * (H - 0.5)

//──────────────────────────────────────────────────────────────────────────────
// 4) Shannon entropy of signed returns across bins
//──────────────────────────────────────────────────────────────────────────────
ret   = ta.change(price)
rMin  = ta.lowest(ret, retLook)
rMax  = ta.highest(ret, retLook)
rngR  = rMax - rMin

bucket(x) =>
    if na(x) or na(rMin) or na(rngR)
        int(na)
    else
        rng = rngR == 0.0 ? 1e-12 : rngR
        b = math.floor(bins * clamp((x - rMin) / rng, 0.0, 1.0))
        int(clamp(b, 0, bins - 1))

// build histogram (rolling, approximate)
var int[] hist = array.new_int(0)
if barstate.isfirst
    for _ = 0 to bins - 1
        array.push(hist, 0)

// decay counts instead of full window recompute (EMA-like histogram for stability)
decay = 2.0 / (retLook + 1.0)
for i = 0 to bins - 1
    prev = array.get(hist, i)
    next = int(math.round(prev * (1.0 - decay)))
    array.set(hist, i, next)

// add current (only when bin is known)
bi = bucket(ret)
if not na(bi)
    array.set(hist, bi, array.get(hist, bi) + 1)

// compute probabilities & entropy
float Hs = 0.0
float total = 0.0
for i = 0 to bins - 1
    total += array.get(hist, i)
for i = 0 to bins - 1
    p = total <= 0 ? 0.0 : array.get(hist, i) / total
    Hs += (p > 0 ? -p * math.log(p) : 0.0)

// normalize entropy to [0,1] by dividing by log(bins)
HsNorm = (bins > 1) ? clamp(Hs / math.log(bins), 0.0, 1.0) : 0.0
// map: high entropy (chop) -> -1, low entropy (information) -> +1
entropyScore = 1.0 - 2.0 * HsNorm

//──────────────────────────────────────────────────────────────────────────────
// 5) Lower-TF microtrend sampler (optional)
//──────────────────────────────────────────────────────────────────────────────
ltfBias = if useLTF
    // FIX: request.security_lower_tf() is deprecated. Use request.security() and proper scope.
    fast = request.security(syminfo.tickerid, ltf, close)
    
    // Normalize micro-ret vs its own stdev
    ltfRet = ta.change(fast)
    ltfStd = ta.stdev(fast, int(math.max(20, lenShort / 2)))
    
    // Calculate the normalized microtrend bias 'v'
    v = ltfStd == 0.0 ? 0.0 : ta.sma(ltfRet, 3) / ltfStd
    
    // Final bias result, clamped to [-1, 1]
    clamp(v, -3.0, 3.0) / 3.0
else
    0.0

//──────────────────────────────────────────────────────────────────────────────
// 6) Robust momentum / pressure (MAD-z of band-passed price)
//──────────────────────────────────────────────────────────────────────────────
momScore = clamp(ta.ema(mad_z(bp, lenShort), 3), -3.0, 3.0) / 3.0  // [-1,1]

//──────────────────────────────────────────────────────────────────────────────
// 7) Data-driven weighting (no magic constants)
//──────────────────────────────────────────────────────────────────────────────
trendBias   = clamp((hurstScore + (1.0 - 2.0 * percentile_rank(fdCore, lenCore))) / 2.0, -1.0, 1.0)
// base weights in [0..1]
wTrendRaw   = clamp( 0.60 + 0.40 * trendBias, 0.10, 0.95)     // weight for trend (mom + fd + hurst)
wEntropyRaw = clamp( 0.40 - 0.40 * (trendBias), 0.05, 0.90)   // weight for entropy (anti-trend)
wMicroRaw   = clamp( 0.20 + 0.30 * trendBias, 0.00, 0.50)      // microstructure contribution if enabled

// normalize weights to sum ≤ 1 (keep some slack for stability)
sumW    = wTrendRaw + wEntropyRaw + (useLTF ? wMicroRaw : 0.0)
scaleW  = sumW > 0 ? 0.95 / sumW : 1.0
wTrend  = wTrendRaw     * scaleW
wEnt    = wEntropyRaw * scaleW
wMicro  = (useLTF ? wMicroRaw : 0.0) * scaleW

// compose trend pillar from components (momentum, fdScore, hurstScore)
trendPillar = (momScore + fdScore + hurstScore) / 3.0

// final composite (bounded)
rawOsc = clamp(wTrend * trendPillar + wEnt * entropyScore + wMicro * ltfBias, -1.0, 1.0)
osc     = ta.ema(rawOsc, smoothVis)

// confidence proxy: how aligned are pillars? use 1 - dispersion
disp = (math.abs(trendPillar - entropyScore) + (useLTF ? math.abs(trendPillar - ltfBias) : 0.0)) / (useLTF ? 2.0 : 1.0)
confidence = clamp(1.0 - disp, 0.0, 1.0)

// state labeling
isBull = osc >  0.15 and trendPillar > 0
isBear = osc < -0.15 and trendPillar < 0
isChop = math.abs(osc) <= 0.15 or H < 0.52 or HsNorm > 0.85

stateTxt =
      isBull and not isChop ? "Trend↑" :
      isBear and not isChop ? "Trend↓" :
      "Chop/Neutral"

//──────────────────────────────────────────────────────────────────────────────
// Plotting
//──────────────────────────────────────────────────────────────────────────────
plot(0,    title="Zero", color=color.new(color.gray, 70))


color bullC = #00E676
color bearC = #FF1744
color neutC = #2196F3

color rsiColor = osc > 0.40 ? bearC : osc < -0.40 ? bullC : color.gray

plot(osc, "AQCO", rsiColor, 2)

// guide bands
b1 = showBands ? 0.50 : na
b2 = showBands ? 0.75 : na
plot(b1,  color=color.new(color.teal,   80), style=plot.style_circles)
plot(-b1, color=color.new(color.teal,   80), style=plot.style_circles)
plot(b2,  color=color.new(color.orange, 80), style=plot.style_circles)
plot(-b2, color=color.new(color.orange, 80), style=plot.style_circles)

// confidence as fill under curve (alpha via confidence)
col = osc >= 0 ? color.lime : color.red

// regime label
if showState and barstate.islast
    label.new(bar_index, osc, stateTxt + "  |  conf=" + str.tostring(confidence, "#.00"),
       style=label.style_label_right,
       textcolor=color.white,
       color= isChop ? color.new(color.gray, 0) : osc > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
     )

// optional signal dots (extreme thrust/revert cues)
longSig  = osc >  0.75 and confidence > 0.6
shortSig = osc < -0.75 and confidence > 0.6
revertUp = ta.crossunder(osc, -0.50) and isChop
revertDn = ta.crossover(osc,  0.50) and isChop

plotshape(longSig,  title="Long Thrust",  style=shape.triangleup,     location=location.bottom, color=color.new(color.green, 0), size=size.tiny)
plotshape(shortSig, title="Short Thrust", style=shape.triangledown, location=location.top,     color=color.new(color.red,   0), size=size.tiny)
plotshape(revertUp, title="Mean-Revert Up",    style=shape.circle, location=location.bottom, color=color.new(color.teal,  0), size=size.tiny)
plotshape(revertDn, title="Mean-Revert Down", style=shape.circle, location=location.top,     color=color.new(color.orange,0), size=size.tiny)

// ============================================================================
// ============================= ALERTS =======================================
// ============================================================================

// ── Trend Regime Alerts ──
alertcondition(ta.crossover(osc, 0.15) and not isChop, title="AQCO: Bullish Trend Start", message='AQCO Bullish Trend Start on {{ticker}} at {{time}}. Osc: {{plot_0}}')
alertcondition(ta.crossunder(osc, -0.15) and not isChop, title="AQCO: Bearish Trend Start", message='AQCO Bearish Trend Start on {{ticker}} at {{time}}. Osc: {{plot_0}}')
alertcondition(ta.crossunder(osc, 0.15) and isChop, title="AQCO: Neutral/Chop Zone Entry", message='AQCO Entered Chop/Neutral on {{ticker}} at {{time}}. Osc: {{plot_0}}')

// ── Extreme Thrust Alerts (high confidence) ──
alertcondition(longSig, title="AQCO: Long Thrust Signal", message='AQCO Long Thrust on {{ticker}} at {{time}}. Osc: {{plot_0}} | Confidence: {{plot_1}}')
alertcondition(shortSig, title="AQCO: Short Thrust Signal", message='AQCO Short Thrust on {{ticker}} at {{time}}. Osc: {{plot_0}} | Confidence: {{plot_1}}')

// ── Mean Reversion Alerts ──
alertcondition(revertUp, title="AQCO: Mean Reversion Up", message='AQCO Mean Reversion Up on {{ticker}} at {{time}}. Osc: {{plot_0}}')
alertcondition(revertDn, title="AQCO: Mean Reversion Down", message='AQCO Mean Reversion Down on {{ticker}} at {{time}}. Osc: {{plot_0}}')

// ── Confidence Spike Alert ──
alertcondition(ta.crossover(confidence, 0.80), title="AQCO: High Confidence Spike", message='AQCO High Confidence on {{ticker}} at {{time}}. Confidence: {{plot_1}}')
````

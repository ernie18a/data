# Alpha-Stable Stability Index [LB]

- url: https://www.tradingview.com/script/SoXLFeyS/
- type: indicator
- pine_id: PUB;f0c43b2a680941c199c639fc21cf4212
- version: 1.0

## Description

[b]Concept[/b]
The Alpha-Stable Stability Index estimates the tail index alpha of an alpha-stable distribution using McCulloch's quantile method (1986). Alpha ranges from 0 (extremely heavy-tailed, infinite variance) to 2 (Gaussian, finite variance). The indicator quantifies how prone the market is to wild, outsized moves and visually separates the chart into three regimes : Gaussian (green), transitional (black/default background), and heavy-tailed (red).

[b]Mathematical Foundation[/b]
The estimation follows McCulloch (1986), "Simple Consistent Estimators of Stable Distribution Parameters". It relies on sample quantiles, which are robust and computationally light.

Given a window of [i]N[/i] log-returns sorted in ascending order, four quantiles are extracted :

[i]q05 = 5th percentile[/i]
[i]q25 = 25th percentile[/i]
[i]q75 = 75th percentile[/i]
[i]q95 = 95th percentile[/i]

The tail-to-body ratio [i]nu[/i] is computed as :

[i]nu = (q95 - q05) / (q75 - q25)[/i]

For a Gaussian distribution, [i]nu[/i] is approximately 2.0. For heavy-tailed stable distributions, [i]nu[/i] increases beyond 3.0. The indicator maps [i]nu[/i] to [i]alpha[/i] using a calibrated rational approximation of McCulloch's Table I :

[i]alpha = 2.0 - 0.70 * ln(nu - 1.9) - 0.04 * (ln(nu - 1.9))^2[/i]

The result is clamped to [0.3, 2.0] and optionally smoothed with an EMA. The indicator pane displays three distinct visual zones :

- [i]Green background[/i] : alpha >= Gaussian Threshold (default 1.9). The distribution is near-Gaussian (mesokurtic). Returns are well-behaved, standard risk management applies.
- [i]Black/default background[/i] : alpha between the two thresholds. Transitional regime — neither fully stable nor clearly heavy-tailed.
- [i]Red background[/i] : alpha <= Heavy Tail Threshold (default 1.5). The distribution is leptokurtic. Fat tails dominate, extreme events are structurally more frequent.

A brief glossary for interpretation :
[i]Leptokurtic[/i] — positive excess kurtosis ; the distribution has fatter tails and a sharper peak than the Gaussian. Alpha < 2.0 indicates leptokurtosis. Price action alternates between long quiet periods and sudden violent bursts.
[i]Platykurtic[/i] — negative excess kurtosis ; thinner tails and a flatter peak than the Gaussian. Rare in financial returns but can appear in heavily mean-reverting or range-bound markets. Alpha close to 2.0 with low overall volatility may suggest platykurtic behavior.
[i]Mesokurtic[/i] — kurtosis equal to that of the Gaussian (excess kurtosis = 0). Alpha = 2.0 corresponds to this regime. The green background signals this state.

[b]What Problem Does It Solve ?[/b]
Classic volatility measures (standard deviation, ATR, historical vol) assume finite second moments and treat all deviations as coming from the same distribution. When the true return distribution is alpha-stable with alpha < 2, the variance is infinite and standard deviation becomes meaningless. The alpha index directly measures tail heaviness without assuming normality, and the green/black/red background gives an immediate visual cue of the risk regime.
[image]https://www.tradingview.com/x/hRMsTQNS/[/image]
[b]How To Interpret[/b]
[i]Alpha in the green zone (>= 1.9)[/i] — mesokurtic / near-Gaussian. Returns are well-behaved, standard risk management applies.
[i]Alpha in the black zone (1.5 to 1.9)[/i] — transitional. The market is neither fully stable nor fully wild ; monitor for a move into the red zone.
[i]Alpha in the red zone (<= 1.5)[/i] — leptokurtic / heavy-tailed. The distribution has undefined or extremely high variance. Large price swings are likely. Consider reducing position size, widening stops, and hedging tail risk.
[i]Alpha declining[/i] — the market is transitioning toward instability ; rising tail risk ahead.

[b]Parameters[/b]
[b]Source[/b] — price data for return calculation (default close).
[b]Window Length[/b] — number of bars used to compute the empirical quantiles. Longer windows give more stable estimates but react more slowly.
[b]Smoothing[/b] — EMA period applied to the raw alpha estimate to reduce noise.
[b]Heavy Tail Threshold[/b] — background turns red when alpha falls below this level (default 1.5).
[b]Gaussian Threshold[/b] — background turns green when alpha exceeds this level (default 1.9).

[b]Reference[/b]
McCulloch J.H., "Simple Consistent Estimators of Stable Distribution Parameters", Communications in Statistics — Simulation and Computation, Vol. 15, No. 4, pp. 1109-1136, 1986.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// INDICATOR : Alpha-Stable Stability Index (McCulloch)
// Concept  : Estimates the tail index alpha of an alpha-stable
//            distribution using McCulloch's quantile method.
//            Alpha ranges from 0 (extremely heavy tails) to 2
//            (Gaussian). Low alpha warns of wild price swings.
//            McCulloch J.H. (1986), Communications in Statistics.
// Author   : Luis Barlier
// Style    : One line between 0 and 2, background highlights
//            for heavy-tail regimes.
// ═══════════════════════════════════════════════════════════════
indicator("Alpha-Stable Stability Index [LB]", overlay=false, precision=4)
bgcolor(color.new(#000000, 100))

// ── PARAMETERS ────────────────────────────────────────────
src          = input.source(close, "Source")
windowLen    = input.int(100, "Window Length", minval=20, maxval=500,
               tooltip="Number of bars for quantile estimation")
smoothLen    = input.int(3, "Smoothing", minval=1,
               tooltip="EMA length applied to the alpha estimate")
heavyTailThreshold = input.float(1.5, "Heavy Tail Threshold",
               minval=0.5, maxval=2.0, step=0.1,
               tooltip="Background highlights when alpha falls below this level")
gaussianThreshold = input.float(1.9, "Gaussian Threshold",
               minval=0.5, maxval=2.0, step=0.1,
               tooltip="Background highlights when alpha exceeds this level")

// ── RETURNS ──────────────────────────────────────────────
ret = math.log(src / src[1])

// ── QUANTILE FUNCTION ────────────────────────────────────
// Returns the value at quantile q (0..1) from a sorted array
getQuantile(sortedArr, q) =>
    N = array.size(sortedArr)
    if N == 0
        0.0
    else
        float pos = q * (N - 1)
        int idxLow = int(math.floor(pos))
        int idxHigh = int(math.ceil(pos))
        if idxLow < 0
            idxLow := 0
        if idxHigh >= N
            idxHigh := N - 1
        float frac = pos - idxLow
        float vLow = array.get(sortedArr, idxLow)
        float vHigh = array.get(sortedArr, idxHigh)
        vLow + frac * (vHigh - vLow)

// ── McCULLOCH ALPHA ESTIMATOR ────────────────────────────
// McCulloch (1986) : "Simple consistent estimators of stable
// distribution parameters". Uses quantiles to estimate alpha
// and beta (skewness) without assuming a parametric form.
//
// nu_alpha = (q95 - q05) / (q75 - q25)
// alpha is obtained by inverting a calibration table.
// We use the asymptotic approximation :
//   alpha ≈ 2.0 / (1.0 + 0.5 * log10(nu_alpha))
// for nu_alpha in the stable range.
mccullochAlpha(returns, N) =>
    // Sort returns to get order statistics
    sorted = array.copy(returns)
    array.sort(sorted)

    // Quantiles needed
    float q05 = getQuantile(sorted, 0.05)
    float q25 = getQuantile(sorted, 0.25)
    float q75 = getQuantile(sorted, 0.75)
    float q95 = getQuantile(sorted, 0.95)

    // Inter-quantile ranges
    float iqrInner = q75 - q25
    float iqrOuter = q95 - q05

    float alpha = 2.0  // default: Gaussian
    if iqrInner > 0.0 and iqrOuter > 0.0
        float nu = iqrOuter / iqrInner

        // McCulloch's Table 1 mapping of nu -> alpha
        // We use a piecewise rational approximation fitted to the table.
        // For nu in [2.0, 6.0] : alpha goes from 2.0 down to ~0.5
        if nu <= 2.05
            alpha := 2.0
        else if nu >= 6.0
            alpha := 0.5
        else
            // Rational approximation calibrated on McCulloch Table I (symmetric case)
            float logNu = math.log(nu - 1.9)
            alpha := 2.0 - 0.70 * logNu - 0.04 * logNu * logNu

        // Clamp to [0.3, 2.0]
        alpha := math.max(0.3, math.min(alpha, 2.0))
    alpha

// ── MAIN COMPUTATION ─────────────────────────────────────
float alpha = na

if bar_index >= windowLen + 1
    arr = array.new_float()
    for i = 0 to windowLen - 1
        array.push(arr, ret[windowLen - 1 - i])

    alpha := mccullochAlpha(arr, windowLen)

// Smoothing
float alphaSmooth = smoothLen > 1 ? ta.ema(alpha, smoothLen) : alpha

// ── OUTPUT ───────────────────────────────────────────────
// Alpha line
plot(alphaSmooth, "Alpha", color=color.new(#ff9800, 0), linewidth=2)

// Reference lines
hline(2.0, "Gaussian", color.new(#00ff00, 60), linestyle=hline.style_dashed)
hline(heavyTailThreshold, "Heavy Tail Threshold", color.new(#ff5252, 60), linestyle=hline.style_dashed)
hline(1.0, "Cauchy", color.new(color.gray, 50), linestyle=hline.style_dotted)

// ── REGIME BACKGROUND ────────────────────────────────────
color couleurFond = na
if not na(alphaSmooth)
    if alphaSmooth >= gaussianThreshold
        couleurFond := color.new(#00ff00, 85)  // near-Gaussian : stable
    else if alphaSmooth <= heavyTailThreshold
        couleurFond := color.new(#ff5252, 85)  // heavy tails : unstable
bgcolor(couleurFond, title="Tail Regime")
````

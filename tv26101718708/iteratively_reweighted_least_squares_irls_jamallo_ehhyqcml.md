# Iteratively Reweighted Least Squares (IRLS) [Jamallo]

- url: https://www.tradingview.com/script/EHhyqcML-Iteratively-Reweighted-Least-Squares-IRLS-Jamallo/
- type: indicator
- pine_id: PUB;30e02fca8be7479887435207d225a9b8
- version: 1.0

## Description

[b]Author's Note:[/b] [i]This script is published as a unique mathematical contribution to TradingView's open-source public library. It is intended to introduce a novel application of a robust statistical method for the community and developers to study, adapt, and build upon, rather than to serve as a standalone, out-of-the-box trading strategy.[/i]

[b]Introduction[/b]

Almost all moving averages and smoothing filters in technical analysis treat historical price data equally or apply a fixed mathematical decay (like an EMA). The problem? A massive, anomalous wick or a sudden volatility spike will inevitably drag the average away from the true underlying market consensus.

Enter [b]Iteratively Reweighted Least Squares (IRLS)[/b].

IRLS is a robust statistical method that calculates a "consensus" price by actively identifying and down-weighting outliers. Instead of letting a large wick distort the line, the algorithm assigns less weight to prices that deviate furthest from the current estimate. The result is a filter that cuts through noise, ignores price-distant spikes, and naturally locks onto the dominant, high-density price levels.

[b]How It Works[/b]

The indicator uses the Hardy weight function to determine how heavily each historical candle influences the current estimate. On every bar, the algorithm checks the distance of each sample from the current consensus and iteratively refines the line until it converges on a robust mean. Epsilon — the outlier rejection scale — is derived dynamically from the average High–Low range, keeping the filter dimensionless and consistent across all instruments and timeframes.

[b]Parameters[/b]
[list]
[*][b]Window Size (N)[/b]: The rolling lookback window of historical samples the kernel considers. Larger values produce a smoother, slower-responding line.
[*][b]Sparsity (s/N)[/b]: The core behavioral control. Dictates the fraction of the window allowed to "vote" on the estimate.
[list]


[*][b]Low Sparsity (e.g., 0.1)[/b]: Only the 10% of samples closest to the current estimate participate. Produces a snappy, selective line that locks tightly onto the most dominant price cluster.

[*][b]High Sparsity (e.g., 1.0)[/b]: All samples participate, resulting in a smoother, more conventional robust mean.

[/list]
[*][b]Gamma (ε scale)[/b]: Controls the strength of outlier rejection. Lower values enforce harsh, median-like rejection. Higher values soften the rejection toward a standard weighted mean.
[*][b]Iterations[/b]: The number of reweighting convergence passes per bar. 2–3 is sufficient for practical convergence.
[/list]

[b]Potential Applications[/b]

The Hardy IRLS filter provides a unique lens into market structure by shifting the focus from simple time-averaged prices to spatial price consensus. Because it rejects price-distant wicks and noise spikes by design, it can serve as a foundation for:
[list]
[*]Custom trailing stops
[*]Dynamic support and resistance trackers
[*]Baseline trend or regime filters
[/list]

Feel free to inspect the open-source code, experiment with extreme sparsity and gamma settings, and integrate the IRLS core into your own quantitative projects.


[b]References[/b]
[list]
[*]Li Shuang, "Sparse Representation of Hardy Function by Iteratively Reweighted Least Squares," 2020 International Symposium on Computer Engineering and Intelligent Communications (ISCEIC), IEEE, 2020. DOI: 10.1109/ISCEIC51027.2020.00020
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © Jamallo

//@version=5

// =============================================================================
// Hardy IRLS — Iteratively Reweighted Least Squares Robust Filter
// =============================================================================
//
// WHAT IT IS
// ----------
// This indicator implements an L1-robust price smoother based on Iteratively
// Reweighted Least Squares (IRLS). Unlike a simple moving average, IRLS assigns
// lower weight to candles that deviate furthest from the current consensus
// estimate, making it highly resistant to outliers — wick spikes, gaps, and
// manipulation that would otherwise yank a standard MA off-course.
//
// It uses the "Hardy" weight function:
//   w(j) = 1 / sqrt( dist(j)² + ε² )
// where ε (epsilon) is an adaptive scale derived from the average High–Low range,
// keeping the filter dimensionless across all instruments and timeframes.
//
// HOW IT WORKS
// ------------
// Each bar, a rolling window of N source samples is maintained. The algorithm
// then runs a configurable number of reweighting passes:
//
//   1. Assign inverse-distance weights from the current estimate.
//   2. Apply Sparsity: only the top s = s_ratio × N weights "vote."
//   3. Update the estimate as the sparse weighted mean.
//
// The Sparsity parameter is the key behavioral control:
//   • Low sparsity (0.1) → only the closest 10% of samples vote → tight,
//     snappy filter that locks onto the dominant price level very precisely.
//   • High sparsity (1.0) → all samples vote equally → behaves more like a
//     conventional robust mean over the whole window.
//
// OUTPUT
// ------
// A single line — the live IRLS consensus price — colored by whether the source
// price is currently above (bullish) or below (bearish) it.
//
// PARAMETERS GUIDE
// ----------------
//  Window (N)        → How far the kernel looks back. Larger = smoother.
//  Sparsity (s/N)    → Selectivity. Lower = snappier and more level-selective.
//  Gamma (ε scale)   → Outlier rejection sharpness. Lower = harder rejection
//                       (approaches a median). Higher = softer (approaches mean).
//  Iterations        → Convergence passes per bar. 2–3 is optimal.
//
// =============================================================================

indicator("Iteratively Reweighted Least Squares [Jamallo]", shorttitle="IRLS [Jamallo]", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
var string GRP_IRLS = "IRLS Parameters"
var string GRP_VIS  = "Appearance"

src     = input.source(close, "Source", group=GRP_IRLS,
          tooltip="Price series that feeds the IRLS kernel. Close is recommended.")

irls_N  = input.int(5, "Window Size (N)", group=GRP_IRLS,
          minval=5, maxval=200,
          tooltip="The number of historical bars the kernel considers. Larger values produce a smoother, slower-responding line.")

s_ratio = input.float(1.0, "Sparsity (s / N)", group=GRP_IRLS,
          minval=0.02, maxval=1.0, step=0.02,
          tooltip="Fraction of the window that participates in the weighted mean. " +
                  "0.1 → only the 10% of samples closest to the current estimate vote (very selective, snappy). " +
                  "1.0 → all samples vote (closer to a robust full-window mean).")

gamma   = input.float(1.0, "Gamma  (ε scale)", group=GRP_IRLS,
          minval=0.001, maxval=100.0, step=0.001,
          tooltip="Sets the epsilon scale for the weight function, expressed as a multiple of the average High–Low range. " +
                  "Low values produce strong outlier rejection (median-like behaviour). " +
                  "High values soften the rejection (ordinary weighted mean).")

iters   = input.int(1, "Iterations", group=GRP_IRLS,
          minval=1, maxval=10,
          tooltip="Number of reweighting passes per bar. 2–3 is sufficient for practical convergence. More iterations = marginally smoother at the cost of extra computation.")

bullCol  = input.color(color.teal,   "Bullish Color", group=GRP_VIS,
           tooltip="Line color when source price is above the IRLS estimate.")
bearCol  = input.color(color.maroon, "Bearish Color", group=GRP_VIS,
           tooltip="Line color when source price is below the IRLS estimate.")
lw       = input.int(1, "Line Width", group=GRP_VIS, minval=1, maxval=4)

// ─────────────────────────────────────────────────────────────────────────────
// IRLS CORE
// ─────────────────────────────────────────────────────────────────────────────

// Rolling window of source samples (newest first)
var float[] y = array.new_float(0)
array.unshift(y, src)
if array.size(y) > irls_N
    array.pop(y)
int win = array.size(y)

// Adaptive epsilon — scales γ by the average High–Low range so the filter
// behaves consistently regardless of instrument price level or timeframe.
float hl_avg = ta.sma(high - low, irls_N)
float eps    = math.max(gamma * nz(hl_avg, close * 0.01), 1e-10)

// Number of samples that contribute to each iteration's estimate
int s = math.max(1, math.round(s_ratio * irls_N))

// Persistent estimate — initialised on the first bar, updated every bar
var float est = na
if na(est)
    est := src

// Main IRLS loop
for _iter = 1 to iters

    // Step 1 — Hardy inverse-distance weights
    float[] w = array.new_float(irls_N, 0.0)
    for j = 0 to irls_N - 1
        float yj = j < win ? array.get(y, j) : src
        float d  = math.abs(yj - est)
        array.set(w, j, 1.0 / math.sqrt(d * d + eps * eps))

    // Step 2 — Sparsity gate: only top-s weights survive
    float[] ws = array.copy(w)
    array.sort(ws, order.descending)
    float gate = array.get(ws, s - 1)

    // Step 3 — Sparse weighted mean → new estimate
    float num = 0.0
    float den = 0.0
    for j = 0 to irls_N - 1
        float wj = array.get(w, j)
        if wj >= gate
            float yj = j < win ? array.get(y, j) : src
            num += wj * yj
            den += wj
    est := den > 1e-10 ? num / den : est

// ─────────────────────────────────────────────────────────────────────────────
// PLOT
// ─────────────────────────────────────────────────────────────────────────────
lineColor = src > est ? bullCol : bearCol
plot(est, "Hardy IRLS", color=lineColor, linewidth=lw)
````

# NW - Nadaraya-Watson Kernel Regression

- url: https://www.tradingview.com/script/3c96zaa8-NW-Nadaraya-Watson-Kernel-Regression/
- type: indicator
- pine_id: PUB;5d3f871966d244feb9dabfd17dba2cab
- version: 1.0

## Description

The Nadaraya-Watson (NW) Estimator is a nonparametric regression tool that produces a highly responsive, non-repainting smooth of price data using a Gaussian kernel. Instead of calculating a simple average over a fixed window, it weighs every historical observation in the lookback period by its temporal distance from the current bar. The result is a continuous curve that filters market noise while preserving underlying structural trends, avoiding the abrupt drop-offs seen in traditional moving averages.

HISTORICAL CONTEXT

Elizbar Nadaraya and Geoffrey Watson independently published this kernel regression estimator in 1964. In time-series analysis, the kernel acts as a temporal weighting function.

The NW estimator gained massive popularity on TradingView around 2022. However, most public versions utilize a centered or forward-looking kernel that repaints—meaning the indicator recalculates past values as new price data arrives. While visually perfect in hindsight, repainting indicators are invalid for live trading or backtesting.

This implementation is strictly backward-looking (endpoint mode). The estimate at the current bar relies exclusively on closed historical data. What you see historically is exactly what printed in real-time.

HOW IT WORKS

Stage 1: Gaussian kernel weights
For each historical bar "i" in the lookback window (where i = 0 is the current bar), the weight decays exponentially based on a Gaussian curve.
w_i = exp(−i² / 2h²)
where h is the bandwidth parameter.

Stage 2: Normalized weighted average
The final output is the sum of all weighted prices divided by the sum of all weights.
NW = Sum(w_i × source) / Sum(w_i)

Decay speed and effective window

Weights approach zero rapidly. Observations beyond a lag of 3h bars contribute less than 1.1% of the peak weight.

Setting the lookback window to at least 4h captures over 99.97% of the kernel mass.

INPUTS & PARAMETERS

Bandwidth (h): Dictates the width of the Gaussian bell curve. This is the primary smoothing control.

Lookback Window (Period): The total number of historical bars processed per calculation.

Bandwidth selection

Small h (h << Period): Tight tracking. Weights drop off immediately. Low bias, high variance. Tracks minor noise, prone to whipsaws.

Balanced h (h ≈ Period / 4): Optimal default. Balanced bias and variance. Smooths noise while maintaining trend fidelity.

Large h (h >> Period): Heavy smoothing. Weights remain high across the entire window. High bias, low variance. Flat response.

HOW TO USE

Trend identification

Because it filters out high-frequency noise better than a standard SMA, the NW estimator is highly effective at defining the core directional bias. A rising NW line indicates a structural uptrend, ignoring minor market fluctuations.

Dynamic support and resistance

When paired with standard deviation bands (like Bollinger Bands applied to the NW line instead of an SMA), it creates a highly responsive volatility envelope that doesn't suffer from the "stepping" effect of traditional moving averages.

Crossovers

Using two NW estimators with different bandwidths (e.g., h=8 and h=32) provides a smoother alternative to MACD or EMA crossovers, resulting in fewer false signals during choppy, sideways markets.

LIMITATIONS

Computationally heavy: Requires an O(N) loop iterating through historical data on every single new bar. Very large lookback windows can cause Pine Script execution timeouts.
Inherent Lag (Group Delay): Like all smoothing algorithms, it introduces lag. The group delay is approximately 1.25 × Bandwidth bars.
Cutoff truncation: If the lookback window is set too small relative to the bandwidth (Period < 3h), the Gaussian curve is abruptly cut off, degrading the accuracy of the estimator.

REFERENCES

Nadaraya, E.A. "On Estimating Regression." Theory of Probability and Its Applications, 1964.
Watson, G.S. "Smooth Regression Analysis." Sankhyā: The Indian Journal of Statistics, 1964.
Wand, M.P. & Jones, M.C. Kernel Smoothing. Chapman & Hall/CRC, 1995.

## Source Code

````pine
// Licensed under the Apache License, Version 2.0
// © mihakralj

//@version=6
indicator("NW - Nadaraya-Watson Kernel Regression", "NW", overlay=true)

// ── Functions ──────────────────────────────────────────────────────────
// @function Calculates the Nadaraya-Watson kernel regression estimator
//   (Nadaraya 1964, Watson 1964) with Gaussian kernel.
//   Non-repainting endpoint estimation (backward-looking only).
//   For each bar t, computes the weighted average:
//     nw(t) = Σ_{i=0}^{N-1} w_i × src[i] / Σ_{i=0}^{N-1} w_i
//   where w_i = K(i/h) and K(u) = exp(-u²/2) is the Gaussian kernel.
//   The bandwidth h controls the effective smoothing radius:
//     small h → tight kernel → tracks price closely (low bias, high variance)
//     large h → wide kernel → heavy smoothing (high bias, low variance)
//   The period limits the lookback window; weights beyond ~3h are negligible.
//   Mathematically equivalent to a normalized Gaussian-weighted FIR filter
//   where the kernel width is parameterized by h rather than period.
// @param source Series to smooth
// @param period Lookback window (must be > 0)
// @param bandwidth Gaussian kernel bandwidth h (must be > 0)
// @returns NW kernel regression estimate
nw(series float source, simple int period, simple float bandwidth) =>
    if period <= 0
        runtime.error("Period must be greater than 0")
    if bandwidth <= 0
        runtime.error("Bandwidth must be greater than 0")

    float src = nz(source)
    int bars = math.min(bar_index + 1, period)

    // Nadaraya-Watson: weighted average with Gaussian kernel
    float num = 0.0
    float den = 0.0
    float h2x2 = 2.0 * bandwidth * bandwidth

    for i = 0 to bars - 1
        float dist = float(i)
        float w = math.exp(-(dist * dist) / h2x2)
        float val = nz(source[i])
        num += w * val
        den += w

    float result = den > 0.0 ? num / den : src
    result

// ── Inputs ─────────────────────────────────────────────────────────────
int    i_period    = input.int(64, "Period", minval=1)
float  i_bandwidth = input.float(8.0, "Bandwidth (h)", minval=0.1, step=0.5)
float i_source    = input.source(close, "Source")

// ── Calculation ────────────────────────────────────────────────────────
float value = nw(i_source, i_period, i_bandwidth)

// ── Plot ───────────────────────────────────────────────────────────────
plot(value, "NW", color.yellow, 2)
````

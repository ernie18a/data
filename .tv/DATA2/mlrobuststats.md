<!-- tradingview-pine-id: PUB;6f65b2d6c6644abf858b1c23e2bf268c -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_robuststats

Source: https://www.tradingview.com/script/Vas4I7IB-ml-robuststats/

## Description

A small robust-statistics toolkit for building stable, outlier-resistant indicators.

Provides MAD-based robust z-scores (median/MAD, breakdown point 0.5), robust variance,
winsorization, percentile rank, multi-window boolean consensus, and inverse-variance
"precision" weighting (ridge-regularized, capped, normalized) for combining several
factors into one composite so quiet/reliable inputs get more weight and noisy ones fade.

Intended as a shared building block imported by other scripts, not as a standalone chart
indicator. MPL-2.0.

Library  "ml_robuststats"

robMedian(src, len)
  Parameters:
    src (float)
    len (simple int)

robMAD(src, len)
  Parameters:
    src (float)
    len (simple int)

robZ(src, len)
  Parameters:
    src (float)
    len (simple int)

robVar(src, len)
  Parameters:
    src (float)
    len (simple int)

winsor(x, cap)
  Parameters:
    x (float)
    cap (simple float)

pctRank(src, len)
  Parameters:
    src (float)
    len (simple int)

consensus(sShort, sMid, sLong, mode)
  Parameters:
    sShort (bool)
    sMid (bool)
    sLong (bool)
    mode (simple string)

precisionWeights(variances, wCap, ridgeFrac)
  Parameters:
    variances (array<float>)
    wCap (simple float)
    ridgeFrac (simple float)

dot(values, weights)
  Parameters:
    values (array<float>)
    weights (array<float>)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_robuststats — Robust statistics toolkit  (Wave A foundation library)
// MAD z-scores · winsorization · inverse-variance precision weights · consensus.
// Import once, reuse across the suite:  import Market_Logic_India/ml_robuststats/2 as rs
// v2 ADDS pctCap — winsorize a series to its own rolling percentile (e.g. cap volume at
// P95 so one freak spike can't blow out a scale). Additive; every v1 export is unchanged.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_robuststats", overlay = false)

// Rolling median.
export robMedian(series float src, simple int len) =>
    ta.median(src, len)

// Median Absolute Deviation (rolling).
export robMAD(series float src, simple int len) =>
    float med = ta.median(src, len)
    ta.median(math.abs(src - med), len)

// Robust z-score: (x - median) / (1.4826 * MAD). 1.4826 makes MAD ≈ σ under
// Gaussian data (breakdown point 0.5). Returns 0 when the window has ~no spread.
export robZ(series float src, simple int len) =>
    float med = ta.median(src, len)
    float mad = ta.median(math.abs(src - med), len)
    mad > 1e-10 ? (src - med) / (1.4826 * mad) : 0.0

// Robust variance estimate for a series (for use as a precision-weight input).
export robVar(series float src, simple int len) =>
    float med = ta.median(src, len)
    float mad = ta.median(math.abs(src - med), len)
    math.pow(1.4826 * mad, 2.0)

// Winsorize: clamp x to +/- cap (second-layer outlier control before compositing).
export winsor(series float x, simple float cap) =>
    math.max(-cap, math.min(cap, x))

// Percentile rank 0..100 (self-calibrating strength).
export pctRank(series float src, simple int len) =>
    ta.percentrank(src, len)

// Multi-window boolean consensus. mode: "Any" | "Majority" | "All".
export consensus(series bool sShort, series bool sMid, series bool sLong, simple string mode) =>
    int hits = (sShort ? 1 : 0) + (sMid ? 1 : 0) + (sLong ? 1 : 0)
    mode == "Any" ? hits >= 1 : mode == "All" ? hits >= 3 : hits >= 2

// Inverse-variance precision weights, ridge-regularized, capped, normalized to 1.
// variances: per-factor variances (e.g. robVar of each factor). Quiet/reliable
// factors get more weight; noisy ones fade. wCap prevents single-factor dominance.
export precisionWeights(array<float> variances, simple float wCap, simple float ridgeFrac) =>
    int n = array.size(variances)
    array<float> w = array.new<float>(n, 0.0)
    if n > 0
        float vsum = 0.0
        for i = 0 to n - 1
            vsum += math.max(0.0, nz(array.get(variances, i)))
        float eps = vsum > 0.0 ? ridgeFrac * vsum / n : 1e-10
        float isum = 0.0
        for i = 0 to n - 1
            float iv = 1.0 / (math.max(0.0, nz(array.get(variances, i))) + eps)
            array.set(w, i, iv)
            isum += iv
        for i = 0 to n - 1
            array.set(w, i, isum > 0.0 ? array.get(w, i) / isum : 1.0 / n)
        float csum = 0.0
        for i = 0 to n - 1
            float cw = math.min(array.get(w, i), wCap)
            array.set(w, i, cw)
            csum += cw
        for i = 0 to n - 1
            array.set(w, i, csum > 0.0 ? array.get(w, i) / csum : 1.0 / n)
    w

// Dot product of a values array with a weights array (safe on size mismatch/na).
export dot(array<float> values, array<float> weights) =>
    int n = math.min(array.size(values), array.size(weights))
    float s = 0.0
    if n > 0
        for i = 0 to n - 1
            s += nz(array.get(values, i)) * nz(array.get(weights, i))
    s

// Percentile CAP (winsorize to a rolling percentile): clamp src DOWN to its own P-th
// percentile over `len`, so one freak spike can't blow out a display/threshold scale.
// pct in 0..100 (e.g. 95 caps the top tail). Use for volume normalization / climax scales.
export pctCap(series float src, simple float pct, simple int len) =>
    float cap = ta.percentile_linear_interpolation(src, len, pct)
    not na(cap) ? math.min(src, cap) : src

// ── demo output (library preview only) ──
plot(robZ(close, 100), "robZ(close,100)", color = color.new(#5b9cf6, 0))
````

<!-- tradingview-pine-id: PUB;bef5c7c649344d99a40d74875bcc531d -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_dsp

Source: https://www.tradingview.com/script/dVg5yadr-ml-dsp-Ehlers-DSP-smoothing-toolkit/

## Description

ml_dsp is a small, dependency-free library of digital-signal-processing filters for Pine v6, built around John Ehlers' filter designs. It exists to solve one recurring problem: EMA and SMA reject noise only by adding lag, so a smoother oscillator or score line always turns late. The filters here reject the same bar-to-bar noise with far less phase delay, so smoothed lines keep their timing.

Everything is exported for reuse via import, and every function takes a series float source and a simple int length, so they slot in wherever you currently call ta.ema(src, len) or ta.sma(src, len).

What's inside
superSmoother(src, period) — Ehlers' 2-pole SuperSmoother low-pass. A direct replacement for ta.ema with substantially less lag for comparable smoothing. Good general-purpose smoother for price, oscillators, and score lines.
ultimateSmoother(src, period) — Ehlers' UltimateSmoother (all-pass minus high-pass). Near-zero lag in the passband — the best default when you want to de-jitter an oscillator or signal line without pushing its turns later. This is the smoother most oscillators should use in place of a display EMA.
highPass(src, period) — Ehlers' 2-pole high-pass filter. Removes the slow trend and leaves the cyclic component — a detrender / cycle extractor for building oscillators, or for isolating short-term deviation from a drifting series.
hann(src, length) — Hann-window FIR smoother. A cosine-tapered moving average with a clean frequency response and minimal ringing; a smooth alternative to SMA when you want gentle, artefact-free smoothing.
rms(src, length) — root-mean-square amplitude of a series over a window. The natural amplitude scale for normalization.
rmsNorm(src, length) — the source divided by its own RMS, giving an approximately unit-amplitude series. A robust alternative to min/max or fixed-range scaling when you need a portable amplitude across symbols and regimes.
How to use

Import the library, then call the filter you need:

//@version=6
indicator("Example — UltimateSmoother RSI", overlay = false)
import Market_Logic_India/ml_dsp/1 as dsp

length = input.int(14, "RSI length")
smooth = input.int(6,  "Smoothing")

raw    = ta.rsi(close, length)
smooth_rsi = dsp.ultimateSmoother(raw, smooth)   // lag-minimal vs ta.ema(raw, smooth)

plot(raw,        "RSI",              color = color.new(color.gray, 60))
plot(smooth_rsi, "UltimateSmoother", color = color.new(#2ecc9b, 0))

Swap ultimateSmoother for superSmoother or hann depending on how aggressive you want the smoothing, or use highPass to detrend and rmsNorm to put a series onto a portable amplitude scale.

Notes
Non-repainting: all filters use only closed historical bars (src, src[1], src[2], and their own feedback). No request.*, no future references. The last bar updates intrabar like any indicator, and settles on close.
Warm-up: the recursive filters (SuperSmoother, UltimateSmoother, High-Pass) seed on the first few bars and converge within a handful of bars; treat the very start of history as warm-up.
Types: pass a simple int length (a plain input or constant), not a series int.
Concept credits

The SuperSmoother, UltimateSmoother, and 2-pole High-Pass filter designs are the work of John F. Ehlers (see his books and articles on cycle analysis and DSP for trading). The Hann-window smoother and RMS normalization are standard signal-processing techniques. This library is an original Pine v6 implementation of those public techniques, packaged for reuse; it is not affiliated with, nor endorsed by, the originators.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). You are free to import and build on it.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_dsp — Ehlers DSP smoothing toolkit  (Wave A foundation library)
// SuperSmoother · UltimateSmoother · Hann · High-Pass · RMS normalization.
// Lag-minimal alternatives to EMA/SMA — less whipsaw for the same noise rejection.
// Filter formulas per John F. Ehlers.  Import:
//   import Market_Logic_India/ml_dsp/3 as dsp
// v2 (Batch-2) ADDED a streaming rolling-OLS regression block (beta/alpha/residual/
// residual-z) — the fit used by the order-flow absorption work and any "expected vs
// actual" relationship (delta→move, volume→range, VIX→move).
// v3 (Batch-4) ADDS a regression/KDE toolkit for profiles & fair-value: log-regression
// (correct for %-scaled NIFTY), polynomial regression (curved fair value), binomial
// (discrete-Gaussian) smoothing, and the Epanechnikov kernel + Silverman bandwidth for
// KDE-smoothed profiles/HVN. All additive — every earlier export is unchanged.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_dsp", overlay = true)

// SuperSmoother (2-pole low-pass). Drop-in for ta.ema with far less lag.
export superSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 - c1 + c2) / 2.0
    float ss = src
    if bar_index >= 4
        ss := a0 * (src + nz(src[1])) + c1 * nz(ss[1]) - c2 * nz(ss[2])
    ss

// UltimateSmoother — all-pass minus high-pass; near-zero lag in the passband.
// Best default replacement for EMA smoothing on oscillators/score lines.
export ultimateSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0) * src + (2.0 * a0 - c1) * nz(src[1]) + (c2 - a0) * nz(src[2]) + c1 * nz(us[1]) - c2 * nz(us[2])
    us

// Ehlers 2-pole High-Pass (detrender / cycle extractor).
export highPass(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float hp = 0.0
    if bar_index >= 4
        hp := a0 * (src - 2.0 * nz(src[1]) + nz(src[2])) + c1 * nz(hp[1]) - c2 * nz(hp[2])
    hp

// Hann-window FIR smoother (clean taper, minimal ringing).
export hann(series float src, simple int length) =>
    float filt = 0.0
    float coef = 0.0
    for c = 1 to length
        float p = math.cos(2.0 * math.pi * c / (length + 1))
        filt += (1.0 - p) * nz(src[c - 1])
        coef += 1.0 - p
    coef != 0.0 ? filt / coef : 0.0

// Root-Mean-Square over a window (amplitude scale for normalization).
export rms(series float src, simple int length) =>
    float s2 = math.sum(src * src, length)
    s2 > 0.0 ? math.sqrt(s2 / length) : 0.0

// RMS-normalized series (≈ unit amplitude) — a robust alternative to min/max scaling.
export rmsNorm(series float src, simple int length) =>
    float r = rms(src, length)
    r != 0.0 ? src / r : 0.0

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ STREAMING ROLLING-OLS REGRESSION  (fit y ≈ alpha + beta·x over `len` bars)
// Closed-form, no arrays: beta = cov(x,y)/var(x), alpha = ȳ − beta·x̄. The robust,
// no-matrix way to measure any "expected vs actual" relationship.
// ══════════════════════════════════════════════════════════════════════════════

// Rolling OLS SLOPE (beta) of y on x.
export olsBeta(series float y, series float x, simple int len) =>
    float mx  = ta.sma(x, len)
    float my  = ta.sma(y, len)
    float cov = ta.sma(x * y, len) - mx * my
    float vx  = ta.sma(x * x, len) - mx * mx
    vx > 1e-12 ? cov / vx : na

// Rolling OLS INTERCEPT (alpha) of y on x.
export olsAlpha(series float y, series float x, simple int len) =>
    float mx = ta.sma(x, len)
    float my = ta.sma(y, len)
    float b  = olsBeta(y, x, len)
    na(b) ? my : my - b * mx

// R² of the fit (how much of y this window's x explains).
export olsR2(series float y, series float x, simple int len) =>
    float mx  = ta.sma(x, len)
    float my  = ta.sma(y, len)
    float cov = ta.sma(x * y, len) - mx * my
    float vx  = ta.sma(x * x, len) - mx * mx
    float vy  = ta.sma(y * y, len) - my * my
    (vx > 1e-12 and vy > 1e-12) ? (cov * cov) / (vx * vy) : na

// CURRENT-bar residual: y − (alpha + beta·x). The part of y the flow/x did NOT explain.
export olsResid(series float y, series float x, simple int len) =>
    float b = olsBeta(y, x, len)
    float a = olsAlpha(y, x, len)
    (na(a) or na(b)) ? na : y - (a + b * x)

// Residual z-scored over the same window — how anomalous this bar's residual is.
// (Order-flow absorption: y = Δprice, x = signed flow → a high +z means flow arrived
//  but price under-moved = absorption.)
export olsResidZ(series float y, series float x, simple int len) =>
    float r  = olsResid(y, x, len)
    float mu = ta.sma(r, len)
    float sd = ta.stdev(r, len)
    sd > 1e-12 ? (r - mu) / sd : na

// ══════════════════════════════════════════════════════════════════════════════
// v3 ▸ REGRESSION & KDE TOOLKIT  (curved / log fair value · discrete-Gaussian smoothing ·
// kernel-density primitives for profiles & HVN extraction)
// ══════════════════════════════════════════════════════════════════════════════

// LOG-REGRESSION fair value: linear regression of log(price), exponentiated back. Correct
// for a %-scaled instrument (NIFTY over long windows grows geometrically) where a plain
// linear regression bends. Returns the fitted price at the current bar.
export logReg(series float src, simple int len) =>
    src > 0.0 ? math.exp(ta.linreg(math.log(src), len, 0)) : na

// POLYNOMIAL REGRESSION value at the current bar — least-squares fit of degree `degree`
// (1..4) over the last `len` bars (x = 0 at the current bar), via the normal equations.
// Degree 2–3 gives a curved fair-value line; the residual (src − polyReg) is a detrended,
// mean-reverting series. Heavier than linreg — keep `len` modest.
export polyReg(series float src, simple int len, simple int degree) =>
    float result = na
    int d = math.max(1, math.min(degree, 4))
    int m = d + 1
    if bar_index >= len - 1 and len > m
        matrix<float> A = matrix.new<float>(m, m, 0.0)
        matrix<float> B = matrix.new<float>(m, 1, 0.0)
        for i = 0 to len - 1
            float x = i                      // current bar x = 0; older bars positive
            float y = nz(src[i])
            for j = 0 to m - 1
                float xj = j == 0 ? 1.0 : math.pow(x, j)
                matrix.set(B, j, 0, matrix.get(B, j, 0) + xj * y)
                for k = 0 to m - 1
                    int e = j + k
                    float xe = e == 0 ? 1.0 : math.pow(x, e)
                    matrix.set(A, j, k, matrix.get(A, j, k) + xe)
        matrix<float> Ainv = matrix.pinv(A)
        matrix<float> C = matrix.mult(Ainv, B)
        result := matrix.get(C, 0, 0)        // fitted value at x = 0 = the current bar
    result

// BINOMIAL (discrete-Gaussian) smoother — FIR weights are the binomial coefficients
// C(length-1, k). A clean, ring-free Gaussian taper; nicer than SMA for profile/score lines.
export binomialSmooth(series float src, simple int length) =>
    float num  = 0.0
    float den  = 0.0
    float coef = 1.0
    int n = math.max(length - 1, 0)
    for k = 0 to n
        num += coef * nz(src[k])
        den += coef
        coef := coef * (n - k) / (k + 1)
    den != 0.0 ? num / den : src

// EPANECHNIKOV kernel K(u) = 0.75·(1−u²) for |u|≤1, else 0. The optimal-efficiency KDE
// kernel — use to smooth a profile histogram (u = binOffset / bandwidth).
export epanechnikov(series float u) =>
    math.abs(u) <= 1.0 ? 0.75 * (1.0 - u * u) : 0.0

// SILVERMAN's rule-of-thumb KDE bandwidth: h = 1.06·σ·n^(−1/5). Principled auto-bandwidth
// for density smoothing (pair with epanechnikov). `sd` = sample stdev, `n` = sample count.
export silvermanBW(series float sd, simple int n) =>
    n > 1 ? 1.06 * sd * math.pow(n, -0.2) : na

// ── demo output (library preview only) ──
plot(ultimateSmoother(close, 20), "UltimateSmoother(close,20)", color = color.new(#2ecc9b, 0))
````

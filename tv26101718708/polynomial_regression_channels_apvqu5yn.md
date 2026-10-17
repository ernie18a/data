# Polynomial Regression Channels 

- url: https://www.tradingview.com/script/ApVQU5Yn-Polynomial-Regression-Channels/
- type: indicator
- pine_id: PUB;3e6d28de99bb49f5a72241ac82ae181b
- version: 1.0

## Description

Polynomial Regression Channels 

Polynomial Regression Channel (PRC)

The Polynomial Regression Channel (PRC) is an advanced trend analysis tool designed to model price behavior using a curved regression instead of a simple linear fit. By capturing non-linear market dynamics, the indicator provides a more adaptive view of trend structure and price deviation.

Core Concept

At its foundation, the PRC fits a polynomial function to historical price data over a defined lookback period:

y=a0​+a1​x+a2​x^2+⋯+an​x^n

This allows the model to reflect acceleration, deceleration, and curvature in trends, which are often missed by linear regression tools.

How It Works
Regression Curve (PRC Midline)
The central line represents the polynomial regression fit of the selected price source.
Deviation Channels
Two sets of bands are constructed around the regression curve using standard deviation:
Inner Channel (±SD1): captures normal price fluctuation
Outer Channel (±SD2): highlights statistically extended moves
Dynamic Adaptation
The curve continuously adjusts as new data comes in, reflecting evolving market structure.
Inputs Explained
Model
Degree (Grad)
Controls the curvature of the regression.
Lower values (1–2): smoother, more stable
Higher values (3+): more responsive, but prone to overfitting
Period (Periode)
Number of bars used for regression.
Shorter = more reactive
Longer = more stable
Source
Price input (e.g., Close, HL2, etc.)
Exponential Weighting (WLS)
Applies Weighted Least Squares, giving more importance to recent data.
Alpha (WLS only)
Controls decay rate of weights.
Values close to 1.0 emphasize recent price action while still retaining historical structure.
Sigma / Channels
Sample Sigma Correction (Regression df)
Adjusts standard deviation using regression degrees of freedom for a more statistically accurate channel width.
SD Multiplier 1 (Inner Band)
Default ~1.62, often aligns with typical price dispersion.
SD Multiplier 2 (Outer Band)
Default ~2.0, commonly used to identify extreme deviations.
Display
Toggle visibility of:
Regression midline
Inner channel (±SD1)
Outer channel (±SD2)
Custom colors for clear visual separation.
How to Use
Trend Identification
The slope and curvature of the regression line indicate trend direction and momentum.
A flattening curve may signal weakening momentum.
Mean Reversion Context
Price near the outer channel suggests statistical extension.
Price within the inner channel reflects normal movement.
Volatility Awareness
Expanding channels indicate increasing volatility.
Contracting channels suggest consolidation.
Best Practices
Use Degree 2–3 for most market conditions. Higher degrees can introduce noise.
Combine with market structure and volume analysis for confirmation.
Avoid treating channel extremes as automatic reversal signals in strong trends.

## Source Code

````pine
//@version=6
indicator("Polynomial Regression Channels (PRC) – v6", overlay=true, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════════════════════════
// CHANGELOG
// ───────────────────────────────────────────────────────────────────────────────
// v6 MIGRATION (on top of all v5 Bug/Math/Quality fixes):
//
//   1. //@version=6
//   2. Typed function signatures:
//        f_solve_aug(int n, float[] aug) → float[]
//        f_build_points(float b0, float b1, float b2, float b3,
//                       int _len, float offset) → array<chart.point>
//      Pine v6 enforces strict typing — untyped params are deprecated.
//
//   3. const string group labels:
//      Group name variables are now declared as `const string` to signal
//      compile-time constants and avoid accidental series coercion.
//
//   4. Short-circuit bool evaluation (v6 native):
//      The `solver_ok` chain and all `if ok` guards now benefit from lazy
//      evaluation at no code cost — false terminates the chain immediately.
//      No bool can be `na` in v6; our code never relied on that, so clean.
//
//   5. Explicit int→float cast on sigma denom kept for clarity:
//      `float(len - n)` is still valid and preferred in strict-type context.
//
// ───────────────────────────────────────────────────────────────────────────────
// PREVIOUS FIXES (v5 → v5-Fixed):
//   BUG 1  – Line-Count-Overflow → polyline (5 objects vs. 595)
//   BUG 2  – Toggle-Off persistence → delete+rebuild on every islast tick
//   BUG 3  – Gauss-Jordan pivot hack → clean ok=false + chart label
//   MATH 1 – WLS Sigma formula → V2 reliability-weight estimator
//   MATH 2 – Variable shadowing in residual loop → consistent typing
//   QUAL 1 – Degree-conditional accumulation of S4–S6, T2–T3
//   QUAL 2 – Condition label when len < 3×(deg+1)
// ═══════════════════════════════════════════════════════════════════════════════


// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
const string grp_m = "Modell"
const string grp_s = "Sigma / Kanäle"
const string grp_v = "Darstellung"

int    deg = input.int   (3,     "Grad (Degree)",                    group=grp_m, minval=1,    maxval=3)
int    len = input.int   (100,   "Periode",                          group=grp_m, minval=10,   maxval=500)
float src = input.source(close, "Source", group=grp_m)

bool   useExpW = input.bool  (false, "Exponentielle Gewichtung (WLS)",      group=grp_m)
float  alpha   = input.float (0.97,  "Alpha (nur wenn WLS aktiv)",           group=grp_m,
                               minval=0.80, maxval=1.0, step=0.001)

bool   useSampleSigma = input.bool  (false, "Sample-Sigma-Korrektur (Regressions-df)", group=grp_s)
float  sd1            = input.float (1.62,  "SD Multiplikator 1",            group=grp_s, step=0.01, minval=0.1)
float  sd2            = input.float (2.00,  "SD Multiplikator 2",            group=grp_s, step=0.01, minval=0.1)

bool   showMid = input.bool (true,  "PRC Mitte anzeigen",                    group=grp_v)
bool   show1   = input.bool (true,  "Innerer Kanal ±SD1",                    group=grp_v)
bool   show2   = input.bool (true,  "Äußerer Kanal ±SD2",                    group=grp_v)

color  midCol = input.color(color.yellow,  "PRC Farbe",                      group=grp_v)
color  inCol  = input.color(color.lime,    "Inner Kanal Farbe",               group=grp_v)
color  outCol = input.color(color.fuchsia, "Outer Kanal Farbe",               group=grp_v)

int    midW = input.int(2, "PRC Stärke",   group=grp_v, minval=1, maxval=5)
int    inW  = input.int(1, "Inner Stärke", group=grp_v, minval=1, maxval=5)
int    outW = input.int(1, "Outer Stärke", group=grp_v, minval=1, maxval=5)


// ─────────────────────────────────────────────────────────────────────────────
// GAUSS-JORDAN SOLVER
// v6: fully typed signature  f_solve_aug(int n, float[] aug) → float[]
// Singular matrix → ok = false, returns array of na (no eps-hack).
// Short-circuit `if ok` guards benefit from v6 lazy bool evaluation.
// ─────────────────────────────────────────────────────────────────────────────
f_solve_aug(int n, float[] aug) =>
    float[] x   = array.new_float(n, na)
    bool    ok  = true
    float   eps = 1e-12

    for col = 0 to n - 1
        if ok
            int   pivRow = col
            float pivAbs = 0.0

            for r = col to n - 1
                float v = math.abs(array.get(aug, r * (n+1) + col))
                if v > pivAbs
                    pivAbs := v
                    pivRow := r

            if pivAbs < eps
                ok := false

            if ok
                if pivRow != col
                    for c = col to n
                        int   i1  = col    * (n+1) + c
                        int   i2  = pivRow * (n+1) + c
                        float tmp = array.get(aug, i1)
                        array.set(aug, i1, array.get(aug, i2))
                        array.set(aug, i2, tmp)

                float piv = array.get(aug, col * (n+1) + col)
                for c = col to n
                    int idx = col * (n+1) + c
                    array.set(aug, idx, array.get(aug, idx) / piv)

                for r = 0 to n - 1
                    if r != col
                        float factor = array.get(aug, r * (n+1) + col)
                        if math.abs(factor) > eps
                            for c = col to n
                                int idxR = r   * (n+1) + c
                                int idxP = col * (n+1) + c
                                array.set(aug, idxR,
                                          array.get(aug, idxR) - factor * array.get(aug, idxP))

    if ok
        for r = 0 to n - 1
            array.set(x, r, array.get(aug, r * (n+1) + n))
    x


// ─────────────────────────────────────────────────────────────────────────────
// CHART.POINT BUILDER
// v6: fully typed signature
//     f_build_points(float, float, float, float, int, float) → array<chart.point>
// ─────────────────────────────────────────────────────────────────────────────
f_build_points(float b0, float b1, float b2, float b3, int _len, float offset) =>
    array<chart.point> pts = array.new<chart.point>()
    for j = 0 to _len - 1
        float xj   = -1.0 + 2.0 * (j / (_len - 1.0))
        float xj2  = xj * xj
        float yhat = b0 + b1*xj + b2*xj2 + b3*xj2*xj
        int   bx   = bar_index - (_len - 1 - j)
        array.push(pts, chart.point.from_index(bx, yhat + offset))
    pts


// ─────────────────────────────────────────────────────────────────────────────
// POLYLINE STORAGE  (5 objects total — line-count limit irrelevant)
// ─────────────────────────────────────────────────────────────────────────────
var polyline midPoly = na
var polyline up1Poly = na
var polyline dn1Poly = na
var polyline up2Poly = na
var polyline dn2Poly = na


// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────
int n = deg + 1   // number of polynomial coefficients (params)

// ── Condition check: near-singular normal equations ───────────────────────────
if barstate.islast and len < 3 * n
    label.new(bar_index, high,
              "⚠ PRC: Periode (" + str.tostring(len) + ") zu kurz für Grad " +
              str.tostring(deg) + ".  Empfehlung: Periode ≥ " + str.tostring(3 * n),
              color=color.red, textcolor=color.white,
              style=label.style_label_left, xloc=xloc.bar_index)

if barstate.islast and bar_index >= len - 1

    // ── Normal-equation sums (degree-conditional accumulation) ───────────────
    float wsum   = 0.0
    float sum_w2 = 0.0
    float S0=0., S1=0., S2=0., S3=0., S4=0., S5=0., S6=0.
    float T0=0., T1=0., T2=0., T3=0.

    for j = 0 to len - 1
        float xj = -1.0 + 2.0 * (j / (len - 1.0))
        float yj = src[len - 1 - j]
        float wj = useExpW ? math.pow(alpha, len - 1 - j) : 1.0
        float x2 = xj * xj
        float x3 = x2 * xj

        wsum   += wj
        sum_w2 += wj * wj
        S0     += wj
        T0     += wj * yj

        if n >= 2
            S1 += wj * xj
            S2 += wj * x2
            T1 += wj * xj * yj

        if n >= 3
            S3 += wj * x3
            S4 += wj * x2 * x2
            T2 += wj * x2 * yj

        if n >= 4
            float x5 = x2 * x3
            float x6 = x3 * x3
            S5 += wj * x5
            S6 += wj * x6
            T3 += wj * x3 * yj

    // ── Augmented matrix ──────────────────────────────────────────────────────
    float[] aug = array.new_float(n * (n+1), 0.0)

    if n == 2
        array.set(aug, 0, S0), array.set(aug, 1, S1), array.set(aug, 2, T0)
        array.set(aug, 3, S1), array.set(aug, 4, S2), array.set(aug, 5, T1)

    else if n == 3
        array.set(aug,  0, S0), array.set(aug,  1, S1), array.set(aug,  2, S2), array.set(aug,  3, T0)
        array.set(aug,  4, S1), array.set(aug,  5, S2), array.set(aug,  6, S3), array.set(aug,  7, T1)
        array.set(aug,  8, S2), array.set(aug,  9, S3), array.set(aug, 10, S4), array.set(aug, 11, T2)

    else
        array.set(aug,  0, S0), array.set(aug,  1, S1), array.set(aug,  2, S2), array.set(aug,  3, S3), array.set(aug,  4, T0)
        array.set(aug,  5, S1), array.set(aug,  6, S2), array.set(aug,  7, S3), array.set(aug,  8, S4), array.set(aug,  9, T1)
        array.set(aug, 10, S2), array.set(aug, 11, S3), array.set(aug, 12, S4), array.set(aug, 13, S5), array.set(aug, 14, T2)
        array.set(aug, 15, S3), array.set(aug, 16, S4), array.set(aug, 17, S5), array.set(aug, 18, S6), array.set(aug, 19, T3)

    // ── Solve ─────────────────────────────────────────────────────────────────
    float[] coeff = f_solve_aug(n, aug)

    float b0 = array.get(coeff, 0)
    float b1 = n > 1 ? array.get(coeff, 1) : 0.0
    float b2 = n > 2 ? array.get(coeff, 2) : 0.0
    float b3 = n > 3 ? array.get(coeff, 3) : 0.0

    // v6 short-circuit: chain stops at first false — no redundant na() checks
    bool solver_ok = not na(b0)           and
                     (n < 2 or not na(b1)) and
                     (n < 3 or not na(b2)) and
                     (n < 4 or not na(b3))

    if not solver_ok
        label.new(bar_index, high,
                  "⚠ PRC: Singuläre Matrix – Grad reduzieren oder Periode erhöhen",
                  color=color.red, textcolor=color.white,
                  style=label.style_label_left, xloc=xloc.bar_index)

    // ── Sigma ─────────────────────────────────────────────────────────────────
    //  Population OLS : σ² = SSE / len
    //  Sample     OLS : σ² = SSE / (len – n_params)
    //  Population WLS : σ² = Σwᵢrᵢ² / Σwᵢ
    //  Sample     WLS : σ² = Σwᵢrᵢ² / (Σwᵢ – Σwᵢ²/Σwᵢ)   [V2 estimator]
    // ─────────────────────────────────────────────────────────────────────────
    float sigma = na

    if solver_ok
        float sse = 0.0
        for j = 0 to len - 1
            float xj  = -1.0 + 2.0 * (j / (len - 1.0))
            float yj  = src[len - 1 - j]
            float wj  = useExpW ? math.pow(alpha, len - 1 - j) : 1.0
            float yh  = b0 + b1*xj + b2*xj*xj + b3*xj*xj*xj
            float res = yj - yh
            sse += wj * res * res

        float denom = wsum

        if useSampleSigma
            denom := useExpW
                      ? math.max(1e-12, wsum - sum_w2 / wsum)   // V2 WLS
                      : math.max(1.0,   float(len - n))          // OLS df

        sigma := math.sqrt(sse / math.max(1e-12, denom))

    // ── Delete stale polylines ────────────────────────────────────────────────
    if not na(midPoly)
        polyline.delete(midPoly)
    if not na(up1Poly)
        polyline.delete(up1Poly)
    if not na(dn1Poly)
        polyline.delete(dn1Poly)
    if not na(up2Poly)
        polyline.delete(up2Poly)
    if not na(dn2Poly)
        polyline.delete(dn2Poly)

    midPoly := na
    up1Poly := na
    dn1Poly := na
    up2Poly := na
    dn2Poly := na

    // ── Draw ─────────────────────────────────────────────────────────────────
    if solver_ok and not na(sigma)

        if showMid
            midPoly := polyline.new(
                         f_build_points(b0, b1, b2, b3, len, 0.0),
                         curved=false, closed=false,
                         line_color=midCol, line_width=midW)

        if show1
            up1Poly := polyline.new(
                         f_build_points(b0, b1, b2, b3, len,  sd1 * sigma),
                         curved=false, closed=false,
                         line_color=inCol, line_width=inW)
            dn1Poly := polyline.new(
                         f_build_points(b0, b1, b2, b3, len, -sd1 * sigma),
                         curved=false, closed=false,
                         line_color=inCol, line_width=inW)

        if show2
            up2Poly := polyline.new(
                         f_build_points(b0, b1, b2, b3, len,  sd2 * sigma),
                         curved=false, closed=false,
                         line_color=outCol, line_width=outW)
            dn2Poly := polyline.new(
                         f_build_points(b0, b1, b2, b3, len, -sd2 * sigma),
                         curved=false, closed=false,
                         line_color=outCol, line_width=outW)
````

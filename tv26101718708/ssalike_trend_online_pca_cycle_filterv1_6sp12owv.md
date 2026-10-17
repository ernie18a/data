# SSA-like Trend (Online PCA + Cycle Filter)V1

- url: https://www.tradingview.com/script/6sP12OwV-SSA-like-Trend-Online-PCA-Cycle-Filter-V1/
- type: indicator
- pine_id: PUB;f4e41ba420d344498c6e65d672252ed9
- version: 1.0

## Description

# SSA-like Trend (Online PCA + Cycle Filter)

## Overview

This indicator is an **online approximation to Singular Spectrum Analysis (SSA)** using **Oja's Principal Component Analysis (PCA) learning rule**. It attempts to separate the dominant low-frequency structure (trend) from shorter-term fluctuations by continuously learning the strongest component in a lagged embedding of price.

Unlike classical SSA, which requires constructing a trajectory matrix and performing eigendecomposition, this implementation updates the dominant component incrementally on each bar and is therefore suitable for Pine Script's real-time execution model.

The indicator produces:

* A dominant trend estimate
* ±1 standard deviation envelope around the trend
* A detrended residual series
* An estimate of the strongest cycle length

---

# Theory

## 1. Delay Embedding

For each bar, a lagged vector is constructed:

[
X_t =
[x_t,;x_{t-1},;x_{t-2},;\ldots,;x_{t-L+1}]
]

where:

* (x_t) = normalized price
* (L) = embedding length

This is equivalent to the trajectory matrix concept used in SSA.

The embedding transforms a one-dimensional time series into a higher-dimensional state space.

---

## 2. Online Principal Component Analysis

The indicator learns the first principal component using Oja's learning rule.

The projection of the embedded vector onto the dominant component is:

[
y_t = w^T X_t
]

where:

* (w) = learned eigenvector
* (X_t) = embedded state vector

The weight update is:

[
w_{new}
=======

w + \eta y (X - yw)
]

where:

* (\eta) = learning rate
* (y) = projection score

Weights are normalized after each update:

[
w \leftarrow \frac{w}{|w|}
]

This converges toward the dominant eigenvector of the covariance matrix.

---

## 3. Trend Reconstruction

The current sample's trend estimate is reconstructed as:

[
Trend_Z = y \cdot w_0
]

where:

* (w_0) is the weight associated with the current bar

The result is transformed back into price space:

[
Trend
=====

Mean + Trend_Z \times StdDev
]

This yields a smoothed estimate of the dominant low-frequency component.

---

## 4. Residual (Detrended Signal)

The residual is:

[
Residual = Price - Trend
]

The residual contains:

* Cyclic activity
* Noise
* Short-term oscillations
* Mean-reverting behavior

Many traders use this series similarly to a detrended oscillator.

---

## 5. Envelope

A volatility envelope is built around the trend:

[
Upper = Trend + \sigma
]

[
Lower = Trend - \sigma
]

where:

[
\sigma = StdDev(Residual)
]

computed over the user-selected envelope length.

This creates adaptive trend bands.

---

## 6. Dominant Cycle Detection

The script estimates the strongest cycle by searching for the lag with maximum autocorrelation.

For each lag:

[
Corr(lag)
=========

Correlation(x_t,x_{t-lag})
]

The lag producing the highest correlation is selected:

[
Cycle = \arg\max Corr(lag)
]

This provides an estimate of the dominant repeating structure in the market.

---

# Inputs

### Embedding Length

**Default:** 20

Controls the dimension of the lagged state vector.

Smaller values:

* Faster adaptation
* More noise

Larger values:

* Smoother trend
* Slower response

Typical range:

| Market Style | Suggested L |
| ------------ | ----------- |
| Intraday     | 10–20       |
| Swing        | 20–40       |
| Position     | 30–50       |

---

### Learning Rate

**Default:** 0.001

Controls adaptation speed of the PCA component.

Smaller values:

* More stable
* Slower convergence

Larger values:

* Faster adaptation
* More instability

Recommended:

[
0.0001 \le \eta \le 0.005
]

---

### Envelope Length

**Default:** 50

Controls volatility estimation for trend bands.

Smaller:

* More reactive

Larger:

* More stable

---

# Outputs

## SSA Trend

Orange line.

Represents the dominant learned component.

Can be interpreted as:

* Adaptive trend
* Low-frequency structure
* Market baseline

---

## Upper Envelope

[
Trend + 1\sigma
]

Potential overextension zone.

---

## Lower Envelope

[
Trend - 1\sigma
]

Potential underextension zone.

---

## Detrended Signal

[
Price - Trend
]

Useful for:

* Mean reversion
* Oscillator analysis
* Cycle analysis

---

## Dominant Cycle Length

Displayed as a separate series.

Represents the lag with the highest autocorrelation.

Can be interpreted as the market's currently strongest repeating cycle.

---

# Relationship to Classical SSA

This indicator is **not a full SSA implementation**.

Classical SSA:

1. Builds trajectory matrix
2. Computes covariance matrix
3. Performs eigendecomposition
4. Reconstructs selected components via diagonal averaging

This indicator:

1. Builds lagged vectors
2. Learns dominant eigenvector online
3. Reconstructs dominant component approximately

Advantages:

* Real-time
* Computationally lightweight
* Pine compatible

Disadvantages:

* Only learns one dominant component
* No full eigenspectrum
* Approximate reconstruction

---

# Practical Interpretation

### Rising Trend

When the SSA Trend slopes upward:

* Dominant market structure is bullish.

### Falling Trend

When the SSA Trend slopes downward:

* Dominant market structure is bearish.

### Large Positive Residual

Price significantly above trend:

[
Price \gg Trend
]

Possible:

* Momentum burst
* Overextension

### Large Negative Residual

Price significantly below trend:

[
Price \ll Trend
]

Possible:

* Panic move
* Undershoot

### Cycle Compression

If estimated cycle length contracts:

* Faster market rhythm
* Higher activity

### Cycle Expansion

If estimated cycle length expands:

* Slower market rhythm
* Trend-dominated regime

---

# Best Use Cases

This indicator is most useful for:

* Trend extraction
* Regime detection
* Adaptive smoothing
* Cycle-aware analysis
* Mean reversion around trend

It is less suitable as a standalone entry signal and is generally strongest when combined with volatility, cycle, or momentum analysis.

## Source Code

````pine
//@version=6
indicator("SSA-like Trend (Online PCA + Cycle Filter)", overlay=false, max_bars_back=500)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
L      = input.int(20, "Embedding Length", minval=5, maxval=50)
lr     = input.float(0.001, "Learning Rate", minval=0.0001, step=0.0001)
envLen = input.int(50, "Envelope Length", minval=10)

//--------------------------------------------------
// Dominant cycle estimate
//--------------------------------------------------
f_domCycle(src, minLag, maxLag) =>
    float bestCorr = -10.0
    int bestLag = minLag

    for lag = minLag to maxLag
        c = ta.correlation(src, src[lag], lag)

        if not na(c) and c > bestCorr
            bestCorr := c
            bestLag := lag

    bestLag

cycle = f_domCycle(close, 5, 50)

//--------------------------------------------------
// Normalize input
//--------------------------------------------------
meanPrice = ta.sma(close, L)
stdPrice  = ta.stdev(close, L)

z = na(stdPrice) or stdPrice == 0.0 ? 0.0 : (close - meanPrice) / stdPrice

//--------------------------------------------------
// Buffers
//--------------------------------------------------
var float[] x = array.new_float()

array.unshift(x, z)

if array.size(x) > L
    array.pop(x)

//--------------------------------------------------
// PCA weights
//--------------------------------------------------
var float[] w = array.new_float(L, 0.0)

if barstate.isfirst
    for i = 0 to L - 1
        array.set(w, i, 1.0 / math.sqrt(L))

//--------------------------------------------------
// Wait until enough data
//--------------------------------------------------
ready = array.size(x) >= L and not na(meanPrice)

float y = na
float trend = na
float resid = na
float upper = na
float lower = na

if ready

    //----------------------------------------------
    // Projection
    //----------------------------------------------
    y := 0.0

    for i = 0 to L - 1
        y += array.get(w, i) * array.get(x, i)

    //----------------------------------------------
    // Oja update
    //----------------------------------------------
    norm2 = 0.0

    for i = 0 to L - 1

        wi = array.get(w, i)
        xi = array.get(x, i)

        wi := wi + lr * y * (xi - y * wi)

        array.set(w, i, wi)

        norm2 += wi * wi

    //----------------------------------------------
    // Normalize weights
    //----------------------------------------------
    norm = math.sqrt(norm2)

    if norm > 0
        for i = 0 to L - 1
            array.set(w, i, array.get(w, i) / norm)

    //----------------------------------------------
    // Reconstruct current sample
    //----------------------------------------------
    trendZ = y * array.get(w, 0)

    //----------------------------------------------
    // Convert back to price space
    //----------------------------------------------
    trend := meanPrice + trendZ * stdPrice

    //----------------------------------------------
    // Residual / envelope
    //----------------------------------------------
    resid := close - trend

    sigma = ta.stdev(resid, envLen)

    upper := trend + sigma
    lower := trend - sigma

//--------------------------------------------------
// Plots
//--------------------------------------------------
plot(close, "Price", color=color.gray)

plot(trend, "SSA Trend", color=color.orange, linewidth=2)

plot(upper, "Upper", color=color.new(color.orange, 70))
plot(lower, "Lower", color=color.new(color.orange, 70))

plot(resid, "Detrended", color=color.aqua)

hline(0, "Zero", color=color.gray)

//--------------------------------------------------
// Diagnostics
//--------------------------------------------------
plot(cycle, "Dominant Cycle", color=color.fuchsia)
````

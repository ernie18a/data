# Quant Mean Reversion Z-Score by Santiago Rebello

- url: https://www.tradingview.com/script/XAu3ddfK-Quant-Mean-Reversion-Z-Score-by-Santiago-Rebello/
- type: indicator
- pine_id: PUB;7b7753e6ca334d59bf88a10045932b18
- version: 1.0

## Description

### Overview
The Quant Mean Reversion Z-Score is an advanced statistical oscillator designed to track asset overextension. It bridges the gap between raw statistical variance and institutional execution filters by calculating a precise Z-Score and running it through advanced noise-filtering math blocks.

### Why This Script is Unique (Originality & Usefulness)
Instead of rehashing a basic open-source Z-Score or standard RSI (which suffer from market noise and fixed, non-adaptive boundaries), this indicator creates a multi-layered quant pipeline:

1. **Statistical Isolation:** It calculates a raw Z-Score to determine exactly how many standard deviations the current price is away from its historical mean ($Z = \frac{x - \mu}{\sigma}$).
2. **Algorithmic Noise-Reduction:** Rather than using a lagging standard moving average, users can toggle between a Triangular Moving Average (TMA) or an institutional-grade, low-lag Jurik Moving Average (JMA) algorithm to smooth out false-positive whipsaws without sacrificing structural execution speed.
3. **Intraday Market Optimization:** The default lookbacks and threshold bounds are custom-calibrated for high-liquidity index environments (such as the Intraday Nifty 50 5m/15m intervals), providing structural grounding for mean-reversion traders.

### How it Works & Component Interaction
* **The Raw Core:** Isolates pure mathematical variance.
* **The Smoothing Layer:** Filters out high-frequency market noise, preventing premature entries during strong trend expansions.
* **The Execution Bands:** Employs explicit $\pm1$ and customizable threshold standard deviation boundaries to visually map out institutional exhaust zones.

### How to Trade It
* **Bearish Exhaustion (Short Bias):** When the smoothed Z-score crosses above the upper Execution Threshold, the asset is statistically overextended. Look for a cross back below the threshold to signal a mean-reversion short.
* **Bullish Exhaustion (Long Bias):** When the smoothed Z-score drops below the lower Execution Threshold, the asset is statistically undervalued. Look for a hook back above the threshold to signal a mean-reversion long.
* **Equilibrium:** The center 0.0 line serves as the ultimate target for mean-reversion take-profits.

## Source Code

````pine
//@version=6
indicator("Quant Mean Reversion Z-Score by Santiago Rebello", overlay=false)

// ==========================================
// 1. INPUTS & SETTINGS
// ==========================================
// Inputs optimized for Intraday Nifty 50 (5m / 15m)
src         = input.source(close, title="Source Data")
length      = input.int(14, title="Base Lookback Period", minval=1)
threshold   = input.float(1.0, title="Execution Threshold (SD)")

// Institutional Quant Smoothing Inputs
smooth_line = input.bool(true, title="Smooth Oscillator Line?")
smooth_type = input.string("TMA", title="Smoothing Type", options=["TMA", "JMA"])
smooth_len  = input.int(12, title="Smoothing Length", minval=1)

// ==========================================
// 2. CORE CALCULATIONS
// ==========================================
// Calculations (Using ta. namespace)
sma_val   = ta.sma(src, length)
stdev_val = ta.stdev(src, length)

// FIX: Prevent division by zero runtime errors on early historical bars
z_score_raw = stdev_val == 0 or na(stdev_val) ? 0.0 : (src - sma_val) / stdev_val

// --- Smoothing Algorithms ---
// 1. Triangular Moving Average (TMA)
z_score_tma = ta.sma(ta.sma(z_score_raw, math.ceil((smooth_len + 1) / 2)), math.floor((smooth_len + 1) / 2))

// 2. Jurik Moving Average (JMA) Implementation
var float e0 = 0.0
var float e1 = 0.0
var float e2 = 0.0
var float jma = 0.0

phase = 0.0  
power = 2.0  
beta  = 0.45 * (smooth_len - 1) / (0.45 * (smooth_len - 1) + 2.0)
alpha = math.pow(beta, power)

// FIX: Removed invalid history indexing [1] inside nz() for cleaner v6 compliance
e0   := (1 - alpha) * z_score_raw + alpha * nz(e0)
e1   := (z_score_raw - e0) * (1 - beta) + beta * nz(e1)
e2   := (e0 + phase * e1 - nz(jma)) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2)
jma  := e2 + nz(jma)
z_score_jma = jma

// Final oscillator selection based on settings
z_score_smoothed = smooth_type == "TMA" ? z_score_tma : z_score_jma
z_score = smooth_line ? z_score_smoothed : z_score_raw

// ==========================================
// 3. COLORING & PLOTTING
// ==========================================
// Dynamic coloring based on mathematical extremes
color z_color = z_score >= threshold ? color.red : z_score <= -threshold ? color.green : color.gray

// Plotting the dynamic Z-Score oscillator
plot(z_score, title="Z-Score Line", color=z_color, linewidth=2)

// Statistical Bands using hline
plot(0.0, "Mean (Equilibrium)", color=color.new(color.white, 20), linewidth=2, style=plot.style_line)
hline(threshold, "Overextended Upper (+SD)", color=color.red, linestyle=hline.style_solid)
hline(-threshold, "Overextended Lower (-SD)", color=color.green, linestyle=hline.style_solid)
hline(1.0, "+1 SD", color=color.new(color.gray, 70))
hline(-1.0, "-1 SD", color=color.new(color.gray, 70))
````

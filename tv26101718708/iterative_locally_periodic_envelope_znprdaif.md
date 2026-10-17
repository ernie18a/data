# Iterative Locally Periodic Envelope

- url: https://www.tradingview.com/script/zNPRdAiF-Iterative-Locally-Periodic-Envelope/
- type: indicator
- pine_id: PUB;5b55ce2a05454408a2e741fa331daff1
- version: 1.0

## Description

The Iterative Locally Periodic Envelope is a phase-conditioned kernel estimator with temporal locality and endogenous dispersion modeling, implemented as a Nadaraya–Watson estimator under a locally periodic kernel.

The locally periodic kernel defines similarity through cyclical phase alignment modulated by temporal proximity. Observations contribute to the estimator based on both their position within a repeating cycle structure and their recency, emphasizing structural recurrence with sensitivity to local regime conditions.

The indicator computes a latent equilibrium using a kernel-weighted mean and a dispersion measure using kernel-weighted variance under the same weighting structure. The resulting envelope reflects cycle-consistent deviation with temporal locality, rather than a conventional volatility band. All values are computed exclusively on closed historical bars using a bounded lookback window to ensure non-repainting behavior.

This indicator belongs to a broader class of iterative kernel-based envelopes that includes Gaussian, Rational Quadratic, and Periodic variants. All share a common Nadaraya–Watson estimation framework, differentiated by their kernel.

[b]TRADING USES[/b]
The Iterative Locally Periodic Envelope is best interpreted as a cycle-aware structural estimator with adaptive temporal sensitivity, rather than a volatility-based band. The temporal locality component allows the estimator to adapt more readily to emerging regime shifts than the pure periodic variant.

[b]Equilibrium Tracking[/b]
The latent equilibrium represents the phase-conditioned central tendency of price under locally periodic similarity weighting. Oscillations around this level reflect movement within a repeating structural cycle, with more recent phase-aligned observations contributing more strongly than temporally distant ones.

[b]Cycle Regime Structure[/b]
The envelope emphasizes repeating structural behavior through phase recurrence weighting, modulated by temporal decay. Changes in symmetry, amplitude, or persistence of oscillation around the latent equilibrium may indicate transitions between cyclical regimes.

[b]Mean Reversion Within Cycles[/b]
When a stable periodic structure is present, deviations from the latent equilibrium may revert toward phase-consistent levels. Mean-reversion behavior is conditioned on both cycle structure and temporal proximity.

[b]Structural Extremes[/b]
Extreme deviations relative to the envelope correspond to phase-inconsistent states where cyclical structure becomes stretched or destabilized. Because the kernel incorporates temporal decay, these conditions are identified with greater sensitivity to recent price behavior.

[b]State Estimation[/b]
The system defines a latent equilibrium as the inferred central cyclical state under joint phase and temporal weighting, with dispersion derived from kernel-weighted variance under identical constraints. This produces a structurally consistent representation of the market state that is sensitive to both cyclical position and local regime conditions.

[b]LOCALLY PERIODIC ENVELOPE CONSTRUCTION[/b]
The envelope is constructed using kernel-weighted variance under the same locally periodic similarity measure used to estimate the latent equilibrium. The latent equilibrium defines the central state estimate and kernel-weighted variance defines dispersion under identical weighting, producing an endogenously determined envelope. The band width is fixed at ±1 kernel standard deviation with no multiplier, ensuring dispersion remains an intrinsic property of the locally periodic similarity structure rather than an externally imposed scaling parameter.

[b]THEORY[/b]
The locally periodic kernel defines similarity in terms of cyclical phase recurrence modulated by temporal proximity. Observations contribute to the estimator based on alignment within a repeating cycle structure, with influence attenuated by temporal distance from the estimation point.

The estimator is formulated as a Nadaraya–Watson kernel regression under a locally periodic kernel, where weights are defined as:

k(i) = exp( -2 · sin²(πi / p) / L² ) · exp( -i² / 2L² )

Where:
p = period (cycle length)
L = lookback window (shared bandwidth parameter; effective smoothing scales with L²)

In this MacKay consistent formulation, the lookback window acts as a unified bandwidth parameter governing periodic phase selectivity and the Radial Basis Function (RBF) temporal decay envelope. The two components are coupled through L, producing a kernel that simultaneously emphasizes phase-aligned and temporally proximate observations.

As L increases, both the periodic and RBF components broaden, producing stronger smoothing across phase and time. As L decreases, phase selectivity and temporal locality both increase, making the estimator more sensitive to recent cycle-consistent observations.

This induces a similarity structure in which influence concentrates at phase-aligned intervals within a temporally bounded neighborhood. The resulting estimator defines a latent equilibrium governed by phase alignment and temporal proximity that can be interpreted as a locally stationary periodic extension of kernel regression on a circular phase manifold.

The key distinction from the pure periodic kernel is that phase-aligned observations at distant lags are progressively suppressed by the RBF decay term, allowing the estimator to adapt to structural drift while preserving cycle-aware weighting. During stable cyclical regimes the two estimators converge; during structural transitions the locally periodic variant adapts faster by downweighting older phase information.

[b]CALIBRATION[/b]
As established in Gaussian Processes for Machine Learning (Rasmussen & Williams, 2006), the period should reflect the recurrence interval of the dominant cycle in the data, while the bandwidth parameter L controls how quickly similarity decays away from perfect phase alignment. For daily charts, common cycle anchors include the trading week (~5 bars), trading month (~21 bars), trading quarter (~63 bars), and trading year (~252 bars).

[b]Length (Lookback / Bandwidth)[/b]
Controls structural depth of the estimator and acts as the unified bandwidth parameter for the periodic and RBF components; as L governs phase selectivity and temporal decay simultaneously, its effect is stronger than in the pure periodic variant. The default of 100 reflects the locally periodic kernel's temporal decay component; at longer lengths the RBF term weakens and behavior converges toward the pure periodic estimator.

- 50–100: high responsiveness, strong temporal locality, short-cycle sensitivity
- 150–250: balanced regime stability with moderate temporal decay
- 300+: broad structural smoothing, weak temporal decay, behavior converges toward pure periodic envelopes

[b]Period (Cycle Length)[/b]
Defines the recurrence interval of the kernel and governs phase alignment and cyclical structure. Shorter periods increase phase resolution and cycle sensitivity, while longer periods emphasize broader structural recurrence. The period should reflect the dominant cycle present in the data, aligned with the anchor scales defined above.

[b]Start At Bar[/b]
Offsets the kernel window backward from the most recent bars and excludes newer observations from the estimator. This ensures all calculations are based strictly on closed historical data and preserves non-repainting behavior.

[b]MARKET USAGE[/b]
Stock, Forex, Crypto, Commodities, and Indices.

Performance is dependent on the presence of stable cyclical structure; in regimes lacking periodic coherence, the estimator converges toward a local smoother with reduced phase discrimination.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SensitiveSuit
//@version=6
indicator('Iterative Locally Periodic Envelope', overlay = true)

//INPUTS
length     = input.int(100, title = "Length")
period     = input.int(63,  title = "Period")
startAtBar = input.int(25,  title = "Start At Bar")
src        = input.source(close, title = "Source")
//LOGIC
// Locally Periodic Kernel — MacKay (1998) | NW estimator framework: Kernel Functions Library by jdehorty (jdehorty/KernelFunctions/2)
kernel_mean(_src, _lookback, _period, _startAtBar) =>
    sum_w  = 0.0
    sum_xw = 0.0
    for i = 0 to _lookback - 1
        idx = i + _startAtBar
        if not na(_src[idx])
            x = _src[idx]
            w = math.exp(
                -2.0 *
                math.pow(math.sin(math.pi * i / _period), 2) /
                math.pow(_lookback, 2)
            ) * math.exp(
                -math.pow(i, 2) /
                (2.0 * math.pow(_lookback, 2))
            )
            sum_xw += x * w
            sum_w  += w
    sum_w != 0 ? sum_xw / sum_w : na

mu = kernel_mean(src, length, period, startAtBar)
//Kernel-Weighted Variance
kernel_var(_src, _lookback, _period, _startAtBar, _mu) =>
    sum_w = 0.0
    sum_v = 0.0
    for i = 0 to _lookback - 1
        idx = i + _startAtBar
        if not na(_src[idx])
            x = _src[idx]
            w = math.exp(
                -2.0 *
                math.pow(math.sin(math.pi * i / _period), 2) /
                math.pow(_lookback, 2)
            ) * math.exp(
                -math.pow(i, 2) /
                (2.0 * math.pow(_lookback, 2))
            )
            sum_v += w * math.pow(x - _mu, 2)
            sum_w += w
    sum_w != 0 ? sum_v / sum_w : na

kvar = kernel_var(src, length, period, startAtBar, mu)
kstd = math.sqrt(kvar)
//Envelope Construction
upper = mu + kstd
lower = mu - kstd
//PLOT
u = plot(upper, color = color.blue, title = "Upper")
l = plot(lower, color = color.blue, title = "Lower")
plot(mu, color = color.green, title = "Basis", linewidth = 2)
fill(u, l, color = color.rgb(33, 150, 243, 90))
````

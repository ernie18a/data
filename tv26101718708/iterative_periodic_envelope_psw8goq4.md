# Iterative Periodic Envelope

- url: https://www.tradingview.com/script/pSW8GoQ4-Iterative-Periodic-Envelope/
- type: indicator
- pine_id: PUB;67fcb8221d524a639fcc37832369c21b
- version: 1.0

## Description

The Iterative Periodic Envelope is a phase-conditioned kernel estimator with endogenous dispersion modeling, implemented as a Nadaraya–Watson estimator under a canonical periodic kernel.

The periodic kernel defines similarity through cyclical phase alignment rather than temporal proximity or multi-scale distance decay. Observations contribute to the estimator based on their position within a repeating cycle structure, emphasizing structural recurrence over linear time dependence.

The indicator computes a latent equilibrium using a kernel-weighted mean and a dispersion measure using kernel-weighted variance under the same weighting structure. The resulting envelope reflects cycle-consistent deviation, rather than a conventional volatility band. All values are computed exclusively on closed historical bars using a bounded lookback window, ensuring non-repainting behavior.

This indicator belongs to a broader class of iterative kernel-based envelopes that includes Gaussian and Rational Quadratic variants. All share a common Nadaraya–Watson estimation framework, differentiated by their kernel.

[b]TRADING USES[/b]
The Iterative Periodic Envelope is best interpreted as a cycle-aware structural estimator rather than a volatility-based band.

[b]Equilibrium Tracking[/b]
The latent equilibrium represents the phase-conditioned central tendency of price under periodic similarity weighting. Oscillations around this level reflect movement within a repeating structural cycle rather than directional drift.

[b]Cycle Regime Structure[/b]
The envelope emphasizes repeating structural behavior through phase recurrence weighting. Changes in symmetry, amplitude, or persistence of oscillation around the latent equilibrium may indicate transitions between cyclical regimes.

[b]Mean Reversion Within Cycles[/b]
When a stable periodic structure is present, deviations from the latent equilibrium may revert toward phase-consistent levels. This supports mean-reversion behavior that is conditioned on cycle structure rather than purely statistical dispersion.

[b]Structural Extremes[/b]
Extreme deviations relative to the envelope correspond to phase-inconsistent states where cyclical structure becomes stretched or destabilized. These conditions often precede transitions such as cycle inversion, expansion, or compression.

[b]State Estimation[/b]
The system defines a latent equilibrium as the inferred central cyclical state, with dispersion derived from kernel-weighted variance under identical periodic similarity constraints. This produces a structurally consistent representation of market state.

[b]PERIODIC ENVELOPE CONSTRUCTION[/b]
The envelope is constructed using kernel-weighted variance under the same periodic similarity measure used to estimate the latent equilibrium. The latent equilibrium defines the central state estimate and kernel-weighted variance defines dispersion under identical weighting, producing an endogenously determined envelope. The band width is fixed at ±1 kernel standard deviation with no multiplier, ensuring dispersion remains an intrinsic property of the periodic similarity structure rather than an externally imposed scaling parameter.

[b]THEORY[/b]
The periodic kernel defines similarity in terms of cyclical phase recurrence rather than linear temporal distance. Observations contribute to the estimator based on alignment within a repeating cycle structure.

The estimator is formulated as a Nadaraya–Watson kernel regression under a canonical periodic kernel, where weights are defined as:

k(i) = exp( -2 · sin²(πi / p) / L² )

Where:
p = period (cycle length)
L = lookback window (bandwidth parameter; effective smoothing scales with L²)

In this MacKay consistent formulation, the lookback window acts as a bandwidth control parameter, governing phase selectivity and structural smoothing. As L increases, the kernel becomes broader, producing stronger smoothing and reduced phase sensitivity. As L decreases, phase selectivity increases and the estimator becomes more locally sensitive to cyclical alignment.

This induces a cyclical similarity structure in which influence concentrates at recurring phase intervals. The resulting estimator defines a latent equilibrium governed by phase alignment rather than temporal proximity. This formulation can be interpreted as a periodic extension of kernel regression on a circular phase manifold.

[b]CALIBRATION[/b]

[b]Length (Lookback / Bandwidth)[/b]
Controls structural depth of the estimator and acts as the primary kernel bandwidth parameter.
- 50–100: high responsiveness, short-cycle sensitivity
- 150–250: balanced regime stability
- 300+: strong structural smoothing, reduced sensitivity to phase noise

[b]Period (Cycle Length)[/b]
Defines the recurrence interval of the kernel and governs phase alignment and cyclical structure. Commonly aligns with dominant market rhythms such as intraday or macro-cycle structure.
- Lower values: faster cycle sensitivity
- Higher values: slower, broader structural cycles

[b]Start At Bar[/b]
Offsets the kernel window backward from the most recent bars and excludes newer observations from the estimator. This ensures all calculations are based strictly on closed historical data and preserves non-repainting behavior.

[b]MARKET USAGE[/b]
Stock, Forex, Crypto, Commodities, and Indices.

Performance is dependent on the presence of stable cyclical structure; in regimes lacking periodic coherence, the estimator converges toward a smoother, low-information state.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SensitiveSuit
//@version=6
indicator('Iterative Periodic Envelope', overlay = true)

//INPUTS
length         = input.int(200, title = "Length")
period         = input.int(63,  title = "Period")
startAtBar     = input.int(25,  title = "Start At Bar")
src            = input.source(close, title = "Source")
//LOGIC
//Periodic Kernel — MacKay (1998) | NW estimator framework: Kernel Functions Library by jdehorty at jdehorty/KernelFunctions/2
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
            )
            sum_xw += x * w
            sum_w  += w
    sum_w != 0 ? sum_xw / sum_w : na

mu = kernel_mean(src, length, period, startAtBar)
//Weighted Mean and Variance
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

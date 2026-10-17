# Bicoherence

- url: https://www.tradingview.com/script/tbVbBLFZ-Bicoherence/
- type: indicator
- pine_id: PUB;5e524d791fa14c0ca33c94faaf22f883
- version: 1.0

## Description

[b]Bicoherence[/b]

A higher-order spectral measure for detecting nonlinear phase coupling in price returns. Where the standard power spectrum tells you how much energy sits at each frequency, the bispectrum tells you whether the phases of three frequencies (f₁, f₂, and f₁+f₂) are systematically locked together — a textbook signature of nonlinear dynamics. Bicoherence is the bispectrum normalized to [0, 1]: zero means no coupling at that frequency triple, one means perfect phase locking.
Linear (Gaussian) processes sit near zero across the bifrequency plane. When markets transition into regimes where price is driven by genuine nonlinear dynamics — feedback loops, regime shifts, wave-coupling effects — bicoherence rises, often well before conventional indicators move.
How it works
For each bar, the most recent (K−1)·step + N samples of log returns are split into K Hann-windowed segments of length N=32, with configurable overlap (default 50%, the Welch standard). Each segment is transformed by discrete Fourier transform. Triple products X(f₁)·X(f₂)·X*(f₁+f₂) are accumulated across segments for every (f₁, f₂) in the principal non-redundant domain {1 ≤ f₂ ≤ f₁, f₁+f₂ ≤ N/2}, alongside the magnitude products needed for normalization.
Per the standard direct estimator:
b²(f₁, f₂) = |⟨triple⟩|² / (⟨|X(f₁)X(f₂)|²⟩ · ⟨|X(f₁+f₂)|²⟩)
The script reports the mean and peak of b² across that domain on every bar.

[b]How to read it[/b]

The thicker line is mean bicoherence — the average of b² over all 64 pairs in the principal domain. The thinner, dimmer line is peak bicoherence — the maximum across the same domain.
The dotted reference is 1/K, the theoretical mean of b² under a linear-Gaussian null hypothesis. Values that consistently sit above this line indicate genuine nonlinear coupling rather than estimation noise.
Line color shifts from cyan (low coupling) through deep purple (high coupling). A faint background tint marks bars where peak bicoherence exceeds 0.7 — the regime where at least one frequency triple is showing exceptional phase locking.

[b]Inputs[/b]

[list]
[*]Segments (K) — number of Hann-windowed sub-windows averaged per bar. More segments produce a smoother, less variance-prone estimate but require more history (history needed = (K−1)·step + N). Default 4.
[*]Segment overlap — overlap between consecutive segments. 50% is Welch's recommendation and the default.
[*]Source — input series for the log-return calculation. Default close.
[*]Compute over last N bars — Pine has a 40-second runtime budget per script. Bicoherence is heavy, so the calculation is restricted to recent history. Default 1500. Lower this if you hit time-outs.
[*]Visuals — toggles for peak line, baseline reference, glow, and regime tint, plus customizable colors for low/high coupling, peak, and neutral states.
[/list]

[b]Built-in alerts[/b]

[list]
[*]Significant nonlinearity — mean bicoherence crosses 1.5× the linear-Gaussian baseline
[*]Strong phase coupling — peak bicoherence crosses 0.5
[*]Extreme phase coupling — peak bicoherence crosses 0.7
[*]Returning to linearity — mean bicoherence drops back below the baseline
[/list]

[b]Notes[/b]

The FFT length is fixed at N=32 — enough for 16 frequency bins below Nyquist while keeping the DFT and triple-product accumulation tractable inside Pine's runtime budget.
Bicoherence assumes a well-mixed input series. Long stretches of zero returns from non-trading hours can produce spurious low-frequency coupling, so prefer active sessions when interpreting the result.
This is a diagnostic tool, not a signal generator. It tells you whether returns are exhibiting nonlinear structure.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//                          Bicoherence
//                          ───────────
//   Higher-order spectral analysis for detecting nonlinear phase coupling
//   in returns. The bispectrum B(f₁,f₂) is the third-order spectral
//   moment; bicoherence b²(f₁,f₂) is its normalized squared magnitude,
//   bounded in [0, 1]. Linear (Gaussian) processes have bicoherence near
//   zero; nonlinear processes show systematic departures at specific
//   frequency triples, signaling quadratic phase coupling.
//
//   Estimation: Welch-style segmentation with K Hann-windowed segments,
//   discrete Fourier transform, and ensemble averaging over the principal
//   non-redundant domain of the bifrequency plane. Reported as mean and
//   peak b² across the principal domain.
//
//   References:
//     Hinich, M.J. (1982). "Testing for gaussianity and linearity of a
//       stationary time series." Journal of Time Series Analysis 3:169-176.
//     Nikias, C.L. & Mendel, J.M. (1993). "Signal processing with
//       higher-order spectra." IEEE Signal Processing Magazine 10(3):10-37.
//
//   Author : TradeSymbiotic
//   License: MPL-2.0
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Bicoherence", shorttitle="BICOH", overlay=false, precision=3, max_bars_back=300)

// ── Constants (FFT length fixed for tractable Pine runtime) ──────────────────
const int N_FFT  = 32
const int N_HALF = 16

// ── Inputs ───────────────────────────────────────────────────────────────────
n_segments    = input.int(4, "Segments (K)", minval=2, maxval=8, group="Calculation",
    tooltip="Number of Hann-windowed segments averaged into the bispectrum estimate. More segments produce a smoother, less variance-prone estimate but require more history. K=4 is a reasonable balance.")

overlap_pct   = input.int(50, "Segment overlap (%)", options=[0, 25, 50, 75], group="Calculation",
    tooltip="Overlap between consecutive segments. 50% (Welch's recommendation) reduces variance with minimal added bias.")

src_input     = input.source(close, "Source", group="Calculation",
    tooltip="Bicoherence assumes a well-mixed input. Avoid charts with long stretches of zero returns from non-trading hours, which produce spurious low-frequency coupling.")

plot_lookback = input.int(1500, "Compute over last N bars", minval=200, maxval=3000, group="Performance",
    tooltip="Pine has a 40-second total execution-time budget per script. Bicoherence requires K DFTs and triple-product averaging on every bar; computing across the full chart history exceeds it. Older bars are blank.")

show_peak     = input.bool(true, "Show peak bicoherence",          group="Visuals")
show_baseline = input.bool(true, "Show 1/K baseline reference",    group="Visuals",
    tooltip="Theoretical mean of b² under the linear-Gaussian null hypothesis. Values that consistently sit above this baseline indicate genuine nonlinear coupling rather than estimation noise.")
show_glow     = input.bool(true, "Glow on mean bicoherence",       group="Visuals")
show_regime   = input.bool(true, "Background tint on strong coupling", group="Visuals")

low_color     = input.color(#00bcd4, "Low coupling",  group="Visuals")
high_color    = input.color(#7c4dff, "High coupling", group="Visuals")
peak_color    = input.color(#b388ff, "Peak line",     group="Visuals")
neutral_color = input.color(#787b86, "Neutral",       group="Visuals")

// ── Returns ──────────────────────────────────────────────────────────────────
ret = nz(math.log(src_input / src_input[1]))

// ── Precomputed Hann window and DFT twiddle factors (one-time setup) ─────────
var hann_w = array.new<float>(N_FFT, 0.0)
var cos_t  = array.new<float>(N_FFT * (N_HALF + 1), 0.0)
var sin_t  = array.new<float>(N_FFT * (N_HALF + 1), 0.0)

if barstate.isfirst
    for k = 0 to N_FFT - 1
        array.set(hann_w, k, 0.5 * (1.0 - math.cos(2.0 * math.pi * k / (N_FFT - 1))))
    for f = 0 to N_HALF
        for k = 0 to N_FFT - 1
            angle = -2.0 * math.pi * f * k / N_FFT
            array.set(cos_t, f * N_FFT + k, math.cos(angle))
            array.set(sin_t, f * N_FFT + k, math.sin(angle))

// ── Gating: lookback window + sufficient history ─────────────────────────────
seg_step    = math.round(N_FFT * (100.0 - overlap_pct) / 100.0)
hist_needed = (n_segments - 1) * seg_step + N_FFT

within_lookback = bar_index > last_bar_index - plot_lookback
ready           = within_lookback and bar_index >= hist_needed

// ── Per-bar bicoherence calculation ──────────────────────────────────────────
//
// For each segment s = 0..K-1, with window starting at offset s*step:
//   1. Apply Hann window to the N_FFT-sample segment
//   2. DFT to get X_s(f) for f = 0..N_HALF
//   3. Accumulate triple products X_s(f1)·X_s(f2)·X*_s(f1+f2) over the
//      principal domain {1 ≤ f2 ≤ f1, f1+f2 ≤ N_HALF}
//   4. Accumulate |X_s(f1)·X_s(f2)|² and |X_s(f1+f2)|² for normalization
//
// After segments: b²(f1,f2) = |Σ triple|² / (Σ|X1·X2|² · Σ|X3|²)
//                 (the K averaging factors cancel between num and denom)
//
float mean_b2 = na
float peak_b2 = na

if ready
    sum_re  = matrix.new<float>(N_HALF, N_HALF, 0.0)
    sum_im  = matrix.new<float>(N_HALF, N_HALF, 0.0)
    sum_d12 = matrix.new<float>(N_HALF, N_HALF, 0.0)
    sum_d3  = matrix.new<float>(N_HALF, N_HALF, 0.0)

    re_X = array.new<float>(N_HALF + 1, 0.0)
    im_X = array.new<float>(N_HALF + 1, 0.0)

    // ── Segment loop ─────────────────────────────────────────────────────────
    for s = 0 to n_segments - 1
        seg_off = s * seg_step

        // DFT of windowed segment
        for f = 0 to N_HALF
            re_sum = 0.0
            im_sum = 0.0
            for k = 0 to N_FFT - 1
                sample = ret[seg_off + N_FFT - 1 - k] * array.get(hann_w, k)
                re_sum := re_sum + sample * array.get(cos_t, f * N_FFT + k)
                im_sum := im_sum + sample * array.get(sin_t, f * N_FFT + k)
            array.set(re_X, f, re_sum)
            array.set(im_X, f, im_sum)

        // Accumulate triple products over principal domain
        for f1 = 1 to N_HALF - 1
            f2_max = math.min(f1, N_HALF - f1)
            for f2 = 1 to f2_max
                re1 = array.get(re_X, f1)
                im1 = array.get(im_X, f1)
                re2 = array.get(re_X, f2)
                im2 = array.get(im_X, f2)
                re3 = array.get(re_X, f1 + f2)
                im3 = array.get(im_X, f1 + f2)

                // X(f1) * X(f2)
                re12 = re1 * re2 - im1 * im2
                im12 = re1 * im2 + im1 * re2

                // (X(f1) * X(f2)) * conj(X(f1+f2))
                re_t = re12 * re3 + im12 * im3
                im_t = im12 * re3 - re12 * im3

                matrix.set(sum_re,  f1, f2, matrix.get(sum_re,  f1, f2) + re_t)
                matrix.set(sum_im,  f1, f2, matrix.get(sum_im,  f1, f2) + im_t)
                matrix.set(sum_d12, f1, f2, matrix.get(sum_d12, f1, f2) + re12*re12 + im12*im12)
                matrix.set(sum_d3,  f1, f2, matrix.get(sum_d3,  f1, f2) + re3 *re3  + im3 *im3 )

    // ── Aggregate b² across the principal domain ─────────────────────────────
    sum_b2  = 0.0
    max_b2  = 0.0
    n_pairs = 0

    for f1 = 1 to N_HALF - 1
        f2_max = math.min(f1, N_HALF - f1)
        for f2 = 1 to f2_max
            sr   = matrix.get(sum_re,  f1, f2)
            si   = matrix.get(sum_im,  f1, f2)
            sd12 = matrix.get(sum_d12, f1, f2)
            sd3  = matrix.get(sum_d3,  f1, f2)

            num   = sr * sr + si * si
            denom = sd12 * sd3
            b2    = denom > 1e-20 ? num / denom : 0.0
            // Numerical clamp into the theoretical range [0, 1]
            b2    := math.min(1.0, math.max(0.0, b2))

            sum_b2  := sum_b2 + b2
            max_b2  := math.max(max_b2, b2)
            n_pairs := n_pairs + 1

    mean_b2 := n_pairs > 0 ? sum_b2 / n_pairs : 0.0
    peak_b2 := max_b2

// ── Plotting ─────────────────────────────────────────────────────────────────
mean_color = na(mean_b2)
     ? neutral_color
     : color.from_gradient(mean_b2, 0.0, 0.5, low_color, high_color)

// Glow layers on mean line
glow_outer_a = show_glow ? 88 : 100
glow_inner_a = show_glow ? 75 : 100
plot(mean_b2, "Glow outer", color=color.new(mean_color, glow_outer_a), linewidth=8)
plot(mean_b2, "Glow inner", color=color.new(mean_color, glow_inner_a), linewidth=4)

// Main mean bicoherence line
plot(mean_b2, "Mean bicoherence", color=mean_color, linewidth=2)

// Peak bicoherence (secondary, dimmer)
peak_alpha = show_peak ? 50 : 100
plot(peak_b2, "Peak bicoherence", color=color.new(peak_color, peak_alpha), linewidth=1)

// 1/K baseline
baseline = 1.0 / n_segments
plot(show_baseline ? baseline : na, "1/K baseline",
     color=color.new(neutral_color, 50), linewidth=1, style=plot.style_circles)

// Regime tint when peak is strong
extreme_regime = peak_b2 > 0.7
bgcolor(show_regime and extreme_regime ? color.new(high_color, 92) : na,
        title="Strong coupling regime")

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(ta.crossover (mean_b2, baseline * 1.5), "Significant nonlinearity",
    "{{ticker}}: Mean bicoherence crossed 1.5× the linear-Gaussian baseline — recent returns show genuine nonlinear coupling.")
alertcondition(ta.crossover (peak_b2, 0.5), "Strong phase coupling",
    "{{ticker}}: Peak bicoherence crossed 0.5 — at least one frequency triple is showing strong phase locking.")
alertcondition(ta.crossover (peak_b2, 0.7), "Extreme phase coupling",
    "{{ticker}}: Peak bicoherence crossed 0.7 — exceptional nonlinear phase coupling at some frequency triple.")
alertcondition(ta.crossunder(mean_b2, baseline), "Returning to linearity",
    "{{ticker}}: Mean bicoherence dropped back below the linear-Gaussian baseline.")
````

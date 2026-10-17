# [GYTS-CE] Pattern Texture Codex (PTC)

- url: https://www.tradingview.com/script/1nvH5VBV-GYTS-CE-Pattern-Texture-Codex-PTC/
- type: indicator
- pine_id: PUB;a9927688b5a04cd9818494a8e454d394
- version: 2.0

## Description

[b]Pattern Texture Codex (Community Edition)[/b]
[i]🌸 Part of GoemonYae Trading System (GYTS) 🌸[/i]


[b]🌸 --------- INTRODUCTION --------- 🌸[/b]

[b]💮 What is the Pattern Texture Codex?[/b]

Standard technical analysis focuses on two dimensions: [b]Amplitude[/b] (how far price moves) and [b]Momentum[/b] (how fast price moves). The Pattern Texture Codex introduces a third: [b]Structure[/b] (how price moves).

This indicator implements [i]Permutation Entropy[/i] (PE), a complexity measure from dynamical systems theory that captures whether price evolves in structured patterns or chaotic noise. We call this "Market Texture":
[list]
[*][b]🫧 Smooth Texture (Low Entropy):[/b] Price evolves in ordered, predictable patterns. Trends are durable and causality is high. Momentum strategies favoured.
[*][b]🌵 Rough Texture (High Entropy):[/b] Price evolves chaotically. The market is noisy, trends are fragile. Mean reversion or defensive sizing recommended.
[/list]

[b]💮 Why Use This Indicator?[/b]

Most "entropy" indicators on TradingView fall into common traps:
[list]
[*]Shannon entropy of price histograms — measures value distribution but ignores [i]temporal sequence[/i]
[*]Approximate Entropy (ApEn) — measures amplitude similarity with O(N²) computational cost
[*]Volatility metrics labelled "entropy" — captures magnitude, not pattern structure
[*]Mathematical errors — normalised values that don't form valid probability distributions
[/list]The Pattern Texture Codex provides [i]true ordinal pattern analysis[/i] — it examines the [i]sequence[/i] of price movements, not just their distribution or magnitude. A smooth uptrend and choppy consolidation may have identical volatility, but their [i]texture[/i] is completely different.


[image]https://www.tradingview.com/x/hCIEJHPN/[/image][i]↑ Pattern Texture Codex with dynamic threshold bands. Rough Texture (high entropy) often indicates reversals, while Smooth Texture (low entropy) often precedes trend continuation.[/i]


[b]🌸 --------- HOW IT WORKS --------- 🌸[/b]

[b]💮 Core Concept: Ordinal Patterns[/b]

Instead of analysing raw price values, Permutation Entropy converts price into [i]ordinal patterns[/i] — the relative ordering of consecutive data points.

For example, with embedding dimension D=3 (three points per pattern):
[list]
[*]Pattern "012": first < second < third → ascending
[*]Pattern "210": first > second > third → descending
[*]Pattern "102": middle value smallest → valley shape
[/list]The indicator counts how often each pattern appears over a lookback window, then calculates the Shannon entropy of this distribution.

[image]https://www.tradingview.com/x/6CfvMRNl/[/image][i]↑ With D=3, three consecutive data points determine each pattern. Left: ascending pattern "012" (first point smallest, second middle, third greatest). Right: descending pattern "210" (first point greatest, second middle, third smallest).[/i]


[b]💮 Calculation Overview[/b]

The normalised Permutation Entropy is computed as:

H = −∑ p(π) · ln(p(π)) / ln(D!)

Where:
• p(π) is the probability of each ordinal pattern π
• D is the embedding dimension (number of points per pattern)
• D! is the total possible patterns (e.g., 4! = 24 for D=4)

The result ranges from 0 to 1:
• [i]H → 0[/i]: One pattern dominates — highly structured, predictable
• [i]H → 1[/i]: All patterns equally likely — pure randomness

[image]https://www.tradingview.com/x/C5NVNmu4/[/image][i]↑ Full calculation example at D=3 showing the lowest entropy point (green vertical line). With 3!=6 possible patterns, the monotonic rising pattern "012" dominates while three other patterns occur only once. The frequency column feeds into the entropy contribution formula, yielding H(3)=1.039. Normalising produces 0.4019 — matching the indicator output exactly.[/i]


[b]💮 Theoretical Background[/b]

Permutation Entropy has deep theoretical foundations. For piecewise monotone maps, it converges to the [i]Kolmogorov-Sinai entropy[/i] — the fundamental measure of chaos in dynamical systems.

Key scientific properties:
• [i]Scale invariance[/i] — analyses rank orderings, invariant to monotonic transformations
• [i]Noise robustness[/i] — ordinal encoding naturally filters high-frequency noise
• [i]Computational efficiency[/i] — O(1) amortised per bar with lookup acceleration
• [i]Micro-structure sensitivity[/i] — captures specific sequence patterns, not just distribution


[b]🌸 --------- KEY FEATURES --------- 🌸[/b]

[b]💮 Lookup Table Acceleration[/b]

Standard PE requires sorting each embedding vector — O(D log D) operations per bar. This implementation uses precomputed [i]transition tables[/i] from Unakafova & Keller (2013), reducing complexity to O(D) per bar.

The key insight: successive ordinal patterns in overlapping windows share (D−1) data points. Rather than recomputing from scratch, the algorithm derives the new pattern from the previous one using a single table lookup.
[list]
[*]Enabled by default for Delay=1 and Dimension ∈ {3, 4, 5}
[*]Falls back to standard calculation for D=2, D=6
[/list]
[b]💮 Flexible Threshold Modes[/b]

The indicator supports four independent threshold modes for both Smooth and Rough detection:
[list]
[*][i]Static[/i] — Fixed threshold values you define
[*][i]Dynamic[/i] — Adaptive bands based on entropy baseline ± standard deviation
[*][i]Percentile[/i] — Threshold at Nth percentile of recent entropy history
[*][i]Disabled[/i] — No threshold for that direction
[/list]You can mix modes: for example, Dynamic for Smooth detection while using Percentile for Rough detection.


[b]🌸 --------- CONFIGURATION --------- 🌸[/b]

[b]💮 General Settings[/b]

• [i]Source[/i] — Price series to analyse (default: close)
• [i]Smoothing Critical Period[/i] — Smoothing via 2-pole Ultimate Smoother (default: 0 = disabled). Reveals underlying texture by filtering entropy noise.


[b]💮 Entropy Calculation[/b]
[list]
[*][i]Dimension (D)[/i] — Points per ordinal pattern:
  • D=3: 6 patterns — fast, stable. Good for limited lookback.
  • D=4: 24 patterns — balanced, captures V-reversals. [b]Recommended.[/b]
  • D=5: 120 patterns — sensitive, captures W/M patterns. Noisier.
  • D=6: 720 patterns — maximum sensitivity. No lookup acceleration.
[*][i]Lookback[/i] — Estimation window size. Hard minimum: D × 5. Statistical recommendation: 5 × D! (e.g., 120 for D=4). Default: 100.
[*][i]Delay (τ)[/i] — Stride between points in each pattern (default: 1). Change only for oversampled data.
[*][i]Lookup Acceleration[/i] — Enables transition tables for D ∈ {3, 4, 5} with Delay=1.
[/list]
[b]💮 Threshold Management[/b]
[list]
[*][i]Rough/Smooth Mode[/i] — Static, Dynamic, Percentile, or Disabled for each threshold
[*][i]Static Values[/i] — Fixed threshold when Static mode selected
[*][i]Std Dev Multiplier[/i] — Band width for Dynamic mode (default: 2.0σ)
[*][i]Baseline/Deviation Length[/i] — Lookback for Dynamic mode calculations
[*][i]Percentile Settings[/i] — Lookback and percentile values for Percentile mode
[/list]
[b]💮 Visualisation & Alerts[/b]
[list]
[*][i]Palette[/i] — Colour scheme (default: GYTS Purple)
[*][i]Colouring Bars[/i] — Applies texture colours to chart candles
[*][i]Dark Mode[/i] — Optimises colour intensity for dark backgrounds
[*][i]Alerts[/i] — Triggers when entropy crosses above/below thresholds
[/list]

[b]🌸 --------- USAGE GUIDE --------- 🌸[/b]

[b]💮 Getting Started[/b]

Apply the indicator with default settings:
• Dimension: 4 (balanced complexity, captures V-shaped reversals)
• Lookback: 100 (responsive; statistical ideal: ≥120 for 5× coverage)
• Smooth Threshold: Dynamic mode with 2.0σ multiplier

Observe how entropy rises during choppy consolidation and falls during clean trends.


[b]💮 Interpretation[/b]

[i]Entropy Value (0 to 1):[/i]
[list]
[*]Below 0.6: Strong pattern dominance — highly ordered
[*]0.7–0.9: Normal complexity — typical market behaviour
[*]Above 0.95: Near-random — patterns uniformly distributed
[/list]
[i]Transitions:[/i]
Watch for regime changes. When entropy rises sharply after a prolonged smooth period, the trend may be losing coherence. When entropy falls from elevated levels, a new trend may be establishing.


[image]https://www.tradingview.com/x/3qsQN7OS/[/image][i]↑ Texture transitions during a trend-to-consolidation regime change. During the uptrend, similar patterns (D=3) recur frequently and entropy decreases. As the market transitions to consolidation, entropy rises — signalling the trend is losing structure.[/i]


[b]💮 Trading Applications[/b]
[list]
[*][i]Trend Filtering[/i] — Only take trend-following signals during Smooth texture.
[*][i]Mean Reversion Timing[/i] — Elevated entropy often precedes mean reversion.
[*][i]Position Sizing[/i] — Reduce exposure during Rough texture.
[*][i]Exit Management[/i] — Tighten stops when entropy rises during a position.
[/list]
[b]💮 Integration with GYTS Suite[/b]

The Pattern Texture Codex exports two signals:
[list]
[*][i]PE Continuous[/i] — Raw entropy value (0 to 1)
[*][i]PE Ternary[/i] — State signal (+1 = Rough, 0 = Neutral, −1 = Smooth)
[/list]These can be read by [url=https://www.tradingview.com/script/FhSSTxaX-GYTS-CE-Flux-Composer/]Flux Composer[/url] or used as filter conditions with [url=https://www.tradingview.com/script/2CR8Rt1O-GYTS-CE-Market-Regime-Detector/]Market Regime Detector[/url].


[b]🌸 --------- PARAMETER TUNING --------- 🌸[/b]

[b]💮 Lookback Selection[/b]

Shorter lookbacks react faster but may produce unstable estimates:
[list]
[*]50–100: Responsive. Good for intraday regime detection.
[*]100–200: Balanced. Recommended for swing trading.
[*]200–500: Stable. Better for position trading or noisy instruments.
[/list]The indicator enforces a hard minimum of D × 5 to prevent meaningless output.


[image]https://www.tradingview.com/x/Wyl3rBYm/[/image][i]↑ Three dimensions (D=3, D=4, D=5) with their academically recommended minimum lookback periods.[/i]


[b]💮 Threshold Tuning[/b]

[i]For Smooth Detection:[/i]
Dynamic mode with 2.0σ works well across most instruments. Lower multipliers (1.5σ) detect structure earlier but may false-trigger.

[i]For Rough Detection:[/i]
Percentile mode at 90th percentile identifies only extreme chaos. Static threshold of 0.95+ focuses on near-random conditions.

Consider disabling Rough detection entirely if your strategy only cares about identifying structured trends.


[image]https://www.tradingview.com/x/Z80EgsHc/[/image][i]↑ The three threshold modes on the same PTC calculation. Both upper and lower thresholds are independently configurable.[/i]


[b]🌸 --------- LIMITATIONS --------- 🌸[/b]
[list]
[*][i]Amplitude Blindness[/i] — PE treats all patterns equally regardless of magnitude. A 0.1% drift and a 10% crash produce identical entropy if their ordinal patterns match.
[*][i]Equal Values (Ties)[/i] — Handled via temporal tie-breaking (recent values rank higher), but heavily discretised data may produce edge-case behaviour.
[*][i]Sample Size Requirements[/i] — Very short lookbacks (below D × 5) produce unreliable estimates. Statistical reliability improves with larger samples.
[*][i]Not Predictive Alone[/i] — Low entropy indicates structure exists, not that the trend will continue. Combine with directional analysis for trading decisions.
[*][i]Lag During Transitions[/i] — The sliding window approach introduces inherent lag when market texture changes.
[/list]

[b]🌸 --------- CREDITS --------- 🌸[/b]

[b]💮 Academic Sources[/b]
[list]
[*]Bandt, C., & Pompe, B. (2002). Permutation entropy: A natural complexity measure for time series. [i]Physical Review Letters, 88[/i](17), 174102. [url=https://doi.org/10.1103/PhysRevLett.88.174102]DOI[/url]
[*]Unakafova, V., & Keller, K. (2013). Efficiently measuring complexity on the basis of real-world data. [i]Entropy, 15[/i](10), 4392-4415. [url=https://doi.org/10.3390/e15104392]DOI[/url]
[*]Ehlers, J. F. (2024). The Ultimate Smoother. [i]Technical Analysis of Stocks & Commodities[/i], 2024-04. [url=https://traders.com/Documentation/FEEDbk_docs/2024/04/TradersTips.html]TASC[/url]
[/list]
[b]💮 Libraries Used[/b]
[list]
[*][url=https://www.tradingview.com/script/Mm789eKn-GYTS-FiltersToolkit-Library/]FiltersToolkit[/url] — Ultimate Smoother and other curated filters
[*][url=https://www.tradingview.com/script/AAj3ZYbf-PatternTransitionTables/]PatternTransitionTables[/url] — Precomputed lookup tables for O(1) pattern transitions
[*][url=https://www.tradingview.com/script/BXVj1kBS-ColourUtilities/]ColourUtilities[/url] — Gradient palette generation and colour management
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GoemonYae, 2026-01 -- 2026-08
//
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
// ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░
// ░▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░
// ░▒▓                                                                                                   ▓▒░
// ░▒▓        ██████╗ ██╗   ██╗████████╗███████╗                                                         ▓▒░
// ░▒▓       ██╔════╝ ╚██╗ ██╔╝╚══██╔══╝██╔════╝        GoemonYae Trading System                         ▓▒░
// ░▒▓       ██║  ███╗ ╚████╔╝    ██║   ███████╗                                                         ▓▒░
// ░▒▓       ██║   ██║  ╚██╔╝     ██║   ╚════██║        Pattern Texture Codex (Community Edition)        ▓▒░
// ░▒▓       ╚██████╔╝   ██║      ██║   ███████║        Permutation Entropy Indicator                    ▓▒░
// ░▒▓        ╚═════╝    ╚═╝      ╚═╝   ╚══════╝        Version 1.0.1                                    ▓▒░
// ░▒▓                                                                                                   ▓▒░
// ░▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒░
// ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░
// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
//
//@version=6
//@description     GYTS "Pattern Texture Codex" [CE] — Permutation Entropy Indicator
//
// ═══════════════════════════════════════════════════════════════════════════════════════════════
// COMMUNITY EDITION (CE)
// ═══════════════════════════════════════════════════════════════════════════════════════════════
//
// This indicator implements Standard Permutation Entropy (Bandt & Pompe, 2002).
//
// CONTEXT & UNIQUENESS
// --------------------
// State of Jan. 2026: Most "Entropy" indicators on TradingView fall into these categories:
//   • Shannon/Tsallis entropy of price histograms (measures value distribution, ignores temporal sequence)
//   • Approximate Entropy (ApEn) — measures amplitude similarity, O(N²) complexity
//   • Goodness-of-fit metrics labelled as "entropy" (e.g., 1-R² trend quality)
//   • Volatility measures (ATR, True Range) branded with "entropy" terminology
//   • Mathematical errors (e.g., normalised values that don't sum to 1, invalid probability distributions)
//
// This script provides the first standalone, optimised Bandt-Pompe Permutation Entropy on TradingView:
//   • True ordinal pattern analysis (captures temporal micro-structure, not just distribution)
//   • O(D) lookup table acceleration (Unakafova & Keller, 2013)
//   • Clean, focused implementation with proper scientific documentation
//
// SCIENTIFIC PROPERTIES
// ---------------------
// • Scale Invariance: Because PE analyses rank orderings rather than absolute values, it is invariant to
//   any monotonic transformation of the data (Bandt & Pompe 2002, Abstract). A 0.1% move and a 10% move
//   produce the same pattern if their relative ordering is identical. This makes PE robust across different
//   price scales and instruments.
//
// • Noise Robustness: The original paper demonstrates that PE remains meaningful even in the presence of
//   observational and dynamical noise (Bandt & Pompe 2002, Sec V) -- a critical property for noisy financial
//   markets.
//
// • Micro-Structure Sensitivity: PE captures the specific *sequence* of price movements, not just their
//   distribution. It distinguishes a smooth trend from choppy oscillations even when volatility is identical.
//
// • Computational Efficiency: PE can be computed extremely fast, enabling real-time applications. This
//   implementation uses Lookup Tables for maximum performance (Unakafova & Keller 2013, Sec 3).
//
// • Theoretical Foundation: PE has deep connections to dynamical systems theory. For piecewise monotone maps,
//   it converges to the Kolmogorov-Sinai entropy (Bandt, Keller & Pompe; referenced in Bandt & Pompe 2002,
//   Sec IV) -- the fundamental measure of chaos in a system.
//
// TEXTURE INTERPRETATION
// ----------------------
// • Smooth Texture (Low Entropy): Highly structured. Trends are durable.
// • Rough Texture  (High Entropy): Pure noise. Trends are breaking.
//
// FEATURES:
// • Scale-invariant ordinal pattern analysis
// • Dual-threshold texture detection (Smooth/Rough with Neutral zone)
// • Static or Dynamic threshold modes
// • Lookup Table acceleration reducing operations by half (Unakafova & Keller, 2013)
//
// IMPLEMENTATION
// --------------
// Implements the efficient "Successive Ordinal Pattern" algorithm.
// • Lookup Table Mode: O(D) complexity (≤2D-2 operations per bar).
//   Uses precomputed transition tables (Unakafova & Keller 2013, Table 4).
// • Standard Mode: O(D²) complexity (calculation from scratch).
//   Used as fallback for delays > 1 or dimensions outside [3,5].
//
// REFERENCES
// ----------
// - Bandt & Pompe (2002): "Permutation entropy: A natural complexity measure for time series"
//   https://doi.org/10.1103/PhysRevLett.88.174102
// - Unakafova & Keller (2013): "Efficiently measuring complexity"
//   https://doi.org/10.3390/e15104392

indicator("[GYTS-CE] Pattern Texture Codex (PTC)", "[GYTS-CE] PTC", overlay=false, precision=4)

const string VERSION = "1.0.1"

//==================================================================//
//#region                      IMPORTS                              //
//==================================================================//

import GoemonYae/FiltersToolkit/2 as filt
import GoemonYae/PatternTransitionTables/1 as ptt
import GoemonYae/ColourUtilities/8 as cu
import GoemonYae/MathTransform/6 as mt

//#endregion


//==================================================================//
//#region                  INPUT PARAMETERS                         //
//==================================================================//

const string g_general    = '🎛️ ────── General Settings ─────── 🎛️'
const string g_calc       = '📐 ───── Entropy Calculation ───── 📐'
const string g_thresholds = '📏 ──── Threshold Management ───── 📏'
const string g_visual     = '🎨 ──────── Visualisation ──────── 🎨'
const string g_alerts     = '🔔 ─────────── Alerts ──────────── 🔔'

//──────────────────────────── general ─────────────────────────────//
const string tt_smooth_period_entropy = "Smoothing applied to the entropy values using 2-pole Ultimate Smoother to reveal the underlying texture."
  + "\n\nSet to 0 to disable smoothing."

i_source           = input.source(close, "Source", group=g_general)
i_smoothing_period = input.int(0, "Smoothing critical period", minval=0, maxval=1000, group=g_general, tooltip=tt_smooth_period_entropy)

//────────────────────────── calculation ───────────────────────────//
const string tt_dimension = "Embedding Dimension (D) — the number of points per ordinal pattern."
  + "\n\nControls the complexity of the pattern weave:"
  + "\n• D=2: Minimal (2!=2 patterns: up/down). Binary direction only — no lookup acceleration."
  + "\n• D=3: Simple (3!=6 patterns). Fast, stable."
  + "\n• D=4: Moderate (4!=24 patterns). Recommended default."
  + "\n• D=5: Complex (5!=120 patterns)."
  + "\n• D=6: Highly complex (6!=720 patterns). No lookup acceleration — may be slow on TradingView. Consider reducing lookback."
  + "\n\nNote: Lookup acceleration is only available for D ∈ [3,5] with Delay=1."
  + "\n\nAcademic literature often uses 'order d' where d=D-1."
const string tt_delay = "Embedding Delay (tau)."
  + "\n\nThe stride between data points in a pattern."
  + "\nDefault of 1 works well for most financial time series. Change only in exotic cases."
const string tt_lookback = "Pattern Window Size (N) — the number of ordinal patterns used for entropy estimation."
  + "\n\nNote: Each pattern requires D consecutive data points, but patterns overlap."
  + "\nTotal bars used = N + (D - 1). For D=4 with N=100, this uses 103 bars."
  + "\n\n⚠️ HARD MINIMUM: N ≥ Dimension × 5"
  + "\n• D=2: Min 10  │  D=3: Min 15  │  D=4: Min 20"
  + "\n• D=5: Min 25  │  D=6: Min 30"
  + "\n\nStatistical recommendation for papers: 5 × (Dimension!)"
  + "\n• D=3: 30  │  D=4: 120  │  D=5: 600  │  D=6: 3600"
  + "\n\nShorter windows (above hard minimum) work in practice but may reduce statistical reliability."
const string tt_lookup_accel = "Uses Lookup Tables for faster calculation (Unakafova & Keller, 2013)."
  + " Reduces per-bar operations from ≤4D-5 to ≤2D-2 (Table 4)."
  + "\n\nOnly active when Delay=1 and Dimension ∈ [3,5]. D=2 and D=6 use standard O(D²) calculation."

i_embedding_dim    = input.int(4, "Dimension", minval=2, maxval=6, group=g_calc, tooltip=tt_dimension)
i_entropy_lookback = input.int(100, "Pattern Window (N)", minval=10, maxval=10000, step=5, group=g_calc, tooltip=tt_lookback)
i_embedding_delay  = input.int(1, "Delay", minval=1, maxval=10, group=g_calc, tooltip=tt_delay)
i_use_lookup_accel = input.bool(true, "Lookup acceleration", group=g_calc, tooltip=tt_lookup_accel)

//────────────────────── threshold management ──────────────────────//
enum ThresholdType
    static     = 'Static'
    dynamic    = 'Dynamic'
    percentile = 'Percentile'
    disabled   = 'Disabled'

const string tt_rough_mode = "🌵 Rough Texture Threshold Mode:"
  + "\n\n• Static: Uses fixed threshold value."
  + "\n• Dynamic: Adaptive threshold based on baseline + deviation."
  + "\n• Percentile: Threshold at Nth percentile of recent history."
  + "\n• Disabled: No rough texture detection."

const string tt_smooth_mode = "🫧 Smooth Texture Threshold Mode:"
  + "\n\n• Static: Uses fixed threshold value."
  + "\n• Dynamic: Adaptive threshold based on baseline - deviation."
  + "\n• Percentile: Threshold at Nth percentile of recent history."
  + "\n• Disabled: No smooth texture detection."

const string tt_rough_thresh = "🌵 Rough Texture Threshold (Static)."
  + "\n\nEntropy values ABOVE this threshold indicate Rough texture."
  + "\n\nOnly used when 🌵 Rough Mode is Static."

const string tt_smooth_thresh = "🫧 Smooth Texture Threshold (Static)."
  + "\n\nEntropy values BELOW this threshold indicate Smooth texture."
  + "\n\nOnly used when 🫧 Smooth Mode is Static."

const string tt_dynamic_mult_rough = "Standard Deviation Multiplier for the 🌵 Rough (Upper) Dynamic Threshold."
  + "\n\nOnly used when 🌵 Rough Mode is Dynamic."

const string tt_dynamic_mult_smooth = "Standard Deviation Multiplier for the 🫧 Smooth (Lower) Dynamic Threshold."
  + "\n\nOnly used when 🫧 Smooth Mode is Dynamic."

const string tt_dynamic_base_len = "The period length for the baseline calculation (Super Smoother)."
  + "\n\nControls the responsiveness of the adaptive baseline used for dynamic thresholds."

const string tt_dynamic_dev_len = "The lookback length for the standard deviation calculation."
  + "\n\nControls the volatility measurement window for the dynamic bands."

const string tt_pct_lookback = "Lookback period for threshold percentile calculation."
  + "\n\nControls how much history is used to determine the Nth percentile "
  + "when threshold mode is set to 'Percentile'."

const string tt_pct_rough = "Percentile for 🌵 Rough threshold (e.g., 90 = top 10%)."
  + "\n\nEntropy values above this percentile indicate Rough texture."

const string tt_pct_smooth = "Percentile for 🫧 Smooth threshold (e.g., 10 = bottom 10%)."
  + "\n\nEntropy values below this percentile indicate Smooth texture."

i_rough_thresh_mode  = input.enum(ThresholdType.disabled, "🌵 Rough Threshold Mode", group=g_thresholds, tooltip=tt_rough_mode)
i_smooth_thresh_mode = input.enum(ThresholdType.dynamic, "🫧 Smooth Threshold Mode", group=g_thresholds, tooltip=tt_smooth_mode)

// Dynamic activation bools for UI
bool i_rough_is_static      = i_rough_thresh_mode == ThresholdType.static
bool i_smooth_is_static     = i_smooth_thresh_mode == ThresholdType.static
bool i_rough_is_dynamic     = i_rough_thresh_mode == ThresholdType.dynamic
bool i_smooth_is_dynamic    = i_smooth_thresh_mode == ThresholdType.dynamic
bool i_rough_is_percentile  = i_rough_thresh_mode == ThresholdType.percentile
bool i_smooth_is_percentile = i_smooth_thresh_mode == ThresholdType.percentile
bool i_any_dynamic          = i_rough_is_dynamic or i_smooth_is_dynamic
bool i_any_percentile       = i_rough_is_percentile or i_smooth_is_percentile

i_static_rough_thresh  = input.float(0.9, "🌵 Rough Value (Static)", minval=0.1, maxval=1.0, step=0.01, group=g_thresholds, tooltip=tt_rough_thresh, active=i_rough_is_static)
i_static_smooth_thresh = input.float(0.7, "🫧 Smooth Value (Static)", minval=0.0, maxval=0.9, step=0.01, group=g_thresholds, tooltip=tt_smooth_thresh, active=i_smooth_is_static)
i_dynamic_mult_rough   = input.float(2.0, "🌵 Std Dev Multiplier (Rough)", minval=0.5, maxval=5.0, step=0.1, group=g_thresholds, tooltip=tt_dynamic_mult_rough, active=i_rough_is_dynamic)
i_dynamic_mult_smooth  = input.float(2.0, "🫧 Std Dev Multiplier (Smooth)", minval=0.5, maxval=5.0, step=0.1, group=g_thresholds, tooltip=tt_dynamic_mult_smooth, active=i_smooth_is_dynamic)
i_dynamic_base_len     = input.int(1000, "Baseline Length (Dynamic)", minval=10, step=20, group=g_thresholds, tooltip=tt_dynamic_base_len, active=i_any_dynamic)
i_dynamic_dev_len      = input.int(1000, "Std Dev Length (Dynamic)", minval=10, step=20, group=g_thresholds, tooltip=tt_dynamic_dev_len, active=i_any_dynamic)
i_pct_lookback         = input.int(1000, "Percentile Lookback", minval=20, maxval=10000, step=20, group=g_thresholds, tooltip=tt_pct_lookback, active=i_any_percentile)
i_pct_rough            = input.float(90, "🌵 Rough Percentile", minval=50, maxval=100, step=1, group=g_thresholds, tooltip=tt_pct_rough, active=i_rough_is_percentile)
i_pct_smooth           = input.float(10, "🫧 Smooth Percentile", minval=0, maxval=50, step=1, group=g_thresholds, tooltip=tt_pct_smooth, active=i_smooth_is_percentile)


//───────────────────────── visualisation ──────────────────────────//
const string tt_palette = "Selects the colour palette used for the entropy line and texture fills."
const string tt_colour_bars = "If enabled, colours the chart bars/candles according to the detected texture (Rough or Smooth)."
const string tt_dark_mode = "Adjusts the colour intensity and brightness for optimal visibility on dark backgrounds."
const string tt_line_transp = "Transparency of the main entropy line (0 = opaque, 100 = invisible)."
const string tt_fill_transp = "Transparency of the texture zone fills (0 = opaque, 100 = invisible)."
const string tt_indicator_name = "Custom label to display on the chart for easy visual identification."
  + "\n\nUseful when running multiple instances of this indicator with different settings."
  + "\n\nSuggested labels:"
  + "\n• Parameter distinctions: \"D=3, N=100\" or \"D=5, N=500\""
  + "\n• Threshold settings: \"Smooth < 0.7\" or \"Dynamic ±2σ\""
  + "\n• Source variations: \"HLC3\" or \"OHLC4\""
  + "\n\nLeave empty to hide the label."
const string tt_repeat_name_bars = "Repeats the indicator name label every N bars on the chart."
  + "\n\nUseful when scrolling through historical data to maintain visual context."
  + "\n\nSet to 0 to display the label only on the most recent bar."

i_palette_name   = input.enum(cu.PaletteNames.gyts_purple, "Palette", group=g_visual, tooltip=tt_palette)
i_colour_bars    = input.bool(true, "Colouring bars", group=g_visual, tooltip=tt_colour_bars)
i_dark_mode      = input.bool(true, "Dark Mode", group=g_visual, tooltip=tt_dark_mode)
i_line_transp    = input.int(0, "Line Transparency", minval=0, maxval=100, group=g_visual, tooltip=tt_line_transp)
i_fill_transp    = input.int(25, "Fill Transparency", minval=0, maxval=100, group=g_visual, tooltip=tt_fill_transp)
i_indicator_name = input.string("", "Indicator Name", group=g_visual, tooltip=tt_indicator_name)
i_repeat_name_bars = input.int(300, "Repeat Name Every N Bars", minval=0, maxval=10000, step=20, group=g_visual, tooltip=tt_repeat_name_bars)

//───────────────────────────── alerts ─────────────────────────────//
const string tt_alert_rough = "Enable runtime alerts when texture transitions to ROUGH."
  + "\n\nTo use: Open the Alerts panel → Create Alert → set Condition to this indicator"
  + "→ select 'Any alert() function call' for webhook-compatible messages with values, "
  + "or select 'Texture → Rough' for the simpler alertcondition() variant."
const string tt_alert_smooth = "Enable runtime alerts when texture transitions to SMOOTH."
  + "\n\nTo use: Open the Alerts panel → Create Alert → set Condition to this indicator"
  + "→ select 'Any alert() function call' for webhook-compatible messages with values, "
  + "or select 'Texture → Smooth' for the simpler alertcondition() variant."

i_use_alerts_rough  = input.bool(true, "Alert: Texture → Rough", tooltip=tt_alert_rough, group=g_alerts)
i_use_alerts_smooth = input.bool(true, "Alert: Texture → Smooth", tooltip=tt_alert_smooth, group=g_alerts)


//==================================================================//
//#region                     UTILITIES                             //
//==================================================================//

// @function            Computes the ordinal pattern index (Unakafova & Keller, 2013)
//                      Maps a specific ordinal pattern to an integer in range [0, D!-1].
//                      Uses strictly temporal tie-breaking (Recent > Older).
// @param src           <float> Source price series
// @param dim           <int> Embedding dimension (D)
// @param delay         <int> Embedding delay
// @returns             <int> Pattern index
get_pattern_index(float src, int dim, int delay) =>
    int index = 0
    // Iterate l from 1 to dim-1
    for l = 1 to dim - 1
        float val_l = src[l * delay]
        int count = 0
        
        // Compare with all more recent values (r < l)
        for r = 0 to l - 1
            float val_r = src[r * delay]
            // Strict inequality handles tie-breaking
            if val_l > val_r
                count += 1
                
        // Add term to index: i_l * (dim! / (l+1)!)
        int factor = int(mt.factorial(dim) / mt.factorial(l + 1))
        index += count * factor
        
    index

//#endregion


//==================================================================//
//#region              PERMUTATION ENTROPY CORE                     //
//==================================================================//

// @type                        Encapsulates state for sliding window Standard Permutation Entropy calculation.
//                              Manages the frequency histogram of ordinal patterns efficiently.
// @field dim                   <int> Embedding dimension (D). Length of the ordinal pattern.
// @field delay                 <int> Embedding delay (tau). Stride between points in the pattern.
// @field lookback              <int> Estimation window size (N). Number of patterns to track.
// @field max_patterns          <int> Total possible unique patterns (D!).
// @field is_initialized        <bool> Initialization flag to ensure setup runs once.
// @field counts                <array<int>> Histogram of pattern frequencies in the current window.
// @field history               <array<int>> Circular buffer storing the sequence of pattern indices in the window.
// @field head                  <int> Pointer to the current insertion position in the history buffer.
// @field count_filled          <int> Number of valid patterns currently in the buffer (ramp-up tracking).
// @field use_o1                <bool> Flag to enable O(1) fast update algorithm using transition tables.
// @field current_pattern_idx   <int> The index of the most recent pattern, used for O(1) state transitions.
// @field prev_embedding_values <array<float>> Buffer of recent source values needed for O(1) comparisons.
// @field o1_initialized        <bool> Flag indicating if the O(1) buffer has been primed.
// @field transition_table      <array<int>> Precomputed lookup table for O(1) pattern transitions.
type PermutationEntropy
    int dim
    int delay
    int lookback
    int max_patterns
    bool is_initialized
    
    // State arrays
    array<int> counts
    array<int> history
    int head
    int count_filled

    // Lookup Acceleration
    bool use_lookup
    int current_pattern_idx
    array<float> prev_embedding_values
    bool lookup_initialized
    array<int> transition_table

// @function            Initialises the PermutationEntropy object, allocating arrays and precomputing tables.
//                      Must be called once before the first update.
// @param self          <PermutationEntropy> The object instance.
// @returns             <PermutationEntropy> The initialized object.
method init(PermutationEntropy self) =>
    if not self.is_initialized
        self.max_patterns := int(mt.factorial(self.dim))
        self.counts := array.new<int>(self.max_patterns, 0)
        self.history := array.new<int>(self.lookback, 0)
        self.head := 0
        self.count_filled := 0
        
        // Lookup init
        self.prev_embedding_values := array.new<float>(self.dim, na)
        self.current_pattern_idx := 0
        self.lookup_initialized := false
        
        // Library parameter mapping: library 'd' is order (points - 1).
        // Indicator 'dim' is number of points. So we request table for d = dim - 1.
        // Library supports d ∈ [2,4] (dim ∈ [3,5]).
        // Input allows dim ∈ [2,6]. When dim=2 or dim=6, we fall back to on-demand calculation.
        if self.use_lookup and self.delay == 1 and self.dim >= 3 and self.dim <= 5
            self.transition_table := ptt.get_table(self.dim - 1)

        self.is_initialized := true
    self

// @function            Updates the sliding window state with a new data point.
//                      Calculates the new pattern, updates frequencies, and removes the oldest pattern.
// @param self          <PermutationEntropy> The object instance.
// @param src           <float> The new source value (e.g., close price).
// @returns             <PermutationEntropy> The updated object.
method update(PermutationEntropy self, float src) =>
    // Determine if Lookup mode is applicable
    // Library supports d ∈ [2,4], indicator passes dim-1, so dim ∈ [3,5] supported.
    // Input constrains dim to [2,6], so effective Lookup range is dim ∈ [3,5].
    bool use_lookup_table = self.use_lookup and self.delay == 1 and self.dim >= 3 and self.dim <= 5

    // 1. Calculate current pattern index
    int current_idx = 0

    if use_lookup_table
        if not self.lookup_initialized
            // First pattern: must compute using standard method to initialize
            current_idx := get_pattern_index(src, self.dim, self.delay)
            self.current_pattern_idx := current_idx
            
            // Store embedding values for subsequent updates
            for i = 0 to self.dim - 1
                self.prev_embedding_values.set(i, src[i * self.delay])
            
            self.lookup_initialized := true
        else
            // Lookup Update: O(D) complexity (≤2D-2 operations)
            // Determine position 'l' of new value relative to previous embedding vector
            float new_val = src
            int position_l = 0
            
            for i = 0 to self.dim - 2
                if self.prev_embedding_values.get(i) > new_val
                    position_l += 1
            
            int lookup_index = self.current_pattern_idx * self.dim + position_l
            current_idx := self.transition_table.get(lookup_index)
            self.current_pattern_idx := current_idx
            
            // Update embedding buffer (Shift right, insert at 0)
            self.prev_embedding_values.unshift(new_val)
            self.prev_embedding_values.pop()
    else
        // Standard Update: O(D²) complexity (calculation from scratch)
        current_idx := get_pattern_index(src, self.dim, self.delay)
    
    // 2. Handle Exiting Value (if buffer full)
    if self.count_filled >= self.lookback
        int exiting_idx = self.history.get(self.head)
        self.counts.set(exiting_idx, self.counts.get(exiting_idx) - 1)
    
    // 3. Handle Entering Value
    self.history.set(self.head, current_idx)
    self.counts.set(current_idx, self.counts.get(current_idx) + 1)
    
    // Move head pointer
    self.head := (self.head + 1) % self.lookback
    self.count_filled := math.min(self.count_filled + 1, self.lookback)
    
    self

// @function            Computes the normalised Permutation Entropy for the current window.
//                      H_norm = -Sum(p * log(p)) / log(D!)
// @param self          <PermutationEntropy> The object instance.
// @returns             <float> Normalised entropy value [0, 1], or na if insufficient data.
method calculate(PermutationEntropy self) =>
    // Minimum samples for validity (heuristic)
    int required_bars = math.max((self.dim - 1) * self.delay + 1, self.dim * 5)
    
    if self.count_filled < required_bars
        float(na)
    else
        float entropy = 0.0
        float total = float(self.count_filled)
        
        if total > 0
            // Sum -p * log(p) over all patterns
            for i = 0 to self.max_patterns - 1
                int count_val = self.counts.get(i)
                if count_val > 0
                    float p = float(count_val) / total
                    entropy -= p * math.log(p)
            
            // Normalise by log(D!)
            float max_entropy = math.log(self.max_patterns)
            entropy / max_entropy

//#endregion


//==================================================================//
//#region               THRESHOLD CALCULATION                       //
//==================================================================//

// @function            Calculates the texture thresholds based on independent modes.
// @param entropy       <float> The (smoothed) entropy value to analyze.
// @param mode_rough    <ThresholdType> The mode for the rough (upper) threshold.
// @param mode_smooth   <ThresholdType> The mode for the smooth (lower) threshold.
// @param static_rough  <float> The fixed rough threshold for Static mode.
// @param static_smooth <float> The fixed smooth threshold for Static mode.
// @param pct_lookback  <int> Lookback for percentile calculation.
// @param pct_rough     <float> Percentile for rough threshold (e.g., 80).
// @param pct_smooth    <float> Percentile for smooth threshold (e.g., 20).
// @returns             <tuple> [baseline, rough_thresh, smooth_thresh]
calculate_thresholds(float entropy, ThresholdType mode_rough, ThresholdType mode_smooth, float static_rough, float static_smooth, int pct_lookback, float pct_rough, float pct_smooth) =>
    // 1. Calculate Dynamic Components if needed
    bool needs_dynamic = (mode_rough == ThresholdType.dynamic) or (mode_smooth == ThresholdType.dynamic)
    float baseline_dyn = na
    float stdev_val    = na

    if needs_dynamic
        baseline_dyn := filt.super_smoother_2pole(entropy, i_dynamic_base_len)
        stdev_val    := ta.stdev(entropy, i_dynamic_dev_len)

    // 2. Determine Rough Threshold
    float thresh_rough = na
    switch mode_rough
        ThresholdType.static     => thresh_rough := static_rough
        ThresholdType.dynamic    =>
            float raw = baseline_dyn + (stdev_val * i_dynamic_mult_rough)
            thresh_rough := math.min(raw, 1.0)
        ThresholdType.percentile =>
            thresh_rough := ta.percentile_linear_interpolation(entropy, pct_lookback, pct_rough)

    // 3. Determine Smooth Threshold
    float thresh_smooth = na
    switch mode_smooth
        ThresholdType.static     => thresh_smooth := static_smooth
        ThresholdType.dynamic    =>
            float raw = baseline_dyn - (stdev_val * i_dynamic_mult_smooth)
            thresh_smooth := math.max(raw, 0.0)
        ThresholdType.percentile =>
            thresh_smooth := ta.percentile_linear_interpolation(entropy, pct_lookback, pct_smooth)

    // 4. Determine Baseline for display
    // If dynamic used, use dynamic baseline. Else average of static thresholds (if both exist), else na.
    float baseline_out = needs_dynamic ? baseline_dyn : (not na(thresh_rough) and not na(thresh_smooth) ? (thresh_rough + thresh_smooth) / 2 : na)

    [baseline_out, thresh_rough, thresh_smooth]

//#endregion


//==================================================================//
//#region                     MAIN LOGIC                            //
//==================================================================//

//───────────────────── input validation ────────────────────────────//
// Hard minimum: lookback must be at least dim × 5 for valid entropy output
int min_lookback_required = i_embedding_dim * 5
if i_entropy_lookback < min_lookback_required
    runtime.error(str.format(
      "Invalid parameter combination: Lookback ({0}) must be ≥ {1} for Dimension {2}. " +
      "Either increase Lookback to {1}+ or reduce Dimension.",
      i_entropy_lookback, min_lookback_required, i_embedding_dim
    ))

//────────────────────── state initialisation ──────────────────────//
var pe = PermutationEntropy.new(
    dim                   = i_embedding_dim,
    delay                 = i_embedding_delay,
    lookback              = i_entropy_lookback,
    max_patterns          = 0,
    is_initialized        = false,
    counts                = array.new<int>(0),
    history               = array.new<int>(0),
    head                  = 0,
    count_filled          = 0,
    use_lookup            = i_use_lookup_accel,
    current_pattern_idx   = 0,
    prev_embedding_values = array.new<float>(0),
    lookup_initialized    = false,
    transition_table      = array.new<int>(0)
)

if barstate.isfirst
    pe.init()

//─────────────────────── update & calculate ───────────────────────//
// Check history requirement
int min_history = i_embedding_dim * i_embedding_delay

if bar_index >= min_history
    pe.update(i_source)

// Get Entropy
float entropy_raw = pe.calculate()

// Smoothing. Account for possible overshoot by clipping to [0, 1]
float entropy = i_smoothing_period == 0 ? entropy_raw : math.max(math.min(filt.ultimate_smoother_2pole(entropy_raw, i_smoothing_period), 1.), 0.)

//───────────────────── threshold calculation ──────────────────────//
[threshold_midpoint, rough_threshold, smooth_threshold] = calculate_thresholds(entropy, i_rough_thresh_mode, i_smooth_thresh_mode, i_static_rough_thresh, i_static_smooth_thresh, i_pct_lookback, i_pct_rough, i_pct_smooth)

// Helper bools for logic readability
bool use_rough  = i_rough_thresh_mode  != ThresholdType.disabled
bool use_smooth = i_smooth_thresh_mode != ThresholdType.disabled

//─────────────────────── texture detection ────────────────────────//
bool is_rough   = false
bool is_smooth  = false
bool is_neutral = false

if use_rough
    is_rough := entropy > rough_threshold

if use_smooth
    is_smooth := entropy < smooth_threshold

if use_rough and use_smooth
    is_neutral := not is_rough and not is_smooth
else if use_rough
    is_neutral := not is_rough
else if use_smooth
    is_neutral := not is_smooth
else
    is_neutral := true

//#endregion


//==================================================================//
//#region                      PLOTTING                             //
//==================================================================//

//──────────────────────────── colours ─────────────────────────────//
// Use Palette for dynamic colouring (initialise once, reuse forever)
var p = cu.Palette.new(transparency=0)
if barstate.isfirst
    p.apply_default_palette(i_palette_name)

// Threshold visibility flags
bool show_rough = i_rough_thresh_mode != ThresholdType.disabled
bool show_smooth = i_smooth_thresh_mode != ThresholdType.disabled

// Line colour: Use percentile rank like VolatilityToolkit for consistent colour spread
// This normalizes entropy to 0-100 based on recent history, ensuring full palette use
float entropy_pct_rank = ta.percentrank(entropy, 200)

// Invert so: HIGH entropy (rough) → low value → warm/red, LOW entropy (smooth) → high value → cool/blue
color c_line = cu.adjust_colour(
    p.get_gradient_colour(100.0 - entropy_pct_rank, 0.0, 100.0),
    transparency_amount = i_line_transp / 100.0,
    dark_mode = i_dark_mode
)

//────────────────────────── fill colours ──────────────────────────//
// Fills get stronger as entropy moves further into the extreme zone.

// Calculate recent range for intensity normalisation
float entropy_highest = ta.highest(entropy, 50)
float entropy_lowest  = ta.lowest(entropy, 50)

// Rough Zone Fill (High entropy - chaotic)
color c_fill_rough = na
if show_rough and is_rough and not na(rough_threshold)
    float dist_rough     = math.abs(entropy - rough_threshold)
    float max_dist_rough = math.max(0.01, nz(entropy_highest - rough_threshold, 0.01))
    float intensity_rough = math.min(1.0, dist_rough / max_dist_rough)
    // Transparency: 90% at threshold (faint) → user's fill_transp at extreme (strong)
    int fill_transp_rough = int(90 - intensity_rough * (90 - i_fill_transp))
    c_fill_rough := cu.adjust_colour(p.get_colour(1, fill_transp_rough), desaturation_amount=0.2, transparency_amount=0.1, dark_mode=i_dark_mode)  // Warm/alert colour

// Smooth Zone Fill (Low entropy - structured)
color c_fill_smooth = na
if show_smooth and is_smooth and not na(smooth_threshold)
    float dist_smooth     = math.abs(smooth_threshold - entropy)
    float max_dist_smooth = math.max(0.01, nz(smooth_threshold - entropy_lowest, 0.01))
    float intensity_smooth = math.min(1.0, dist_smooth / max_dist_smooth)
    // Transparency: 90% at threshold (faint) → user's fill_transp at extreme (strong)
    int fill_transp_smooth = int(90 - intensity_smooth * (90 - i_fill_transp))
    c_fill_smooth := cu.adjust_colour(p.get_colour(6, fill_transp_smooth), desaturation_amount=0.2, transparency_amount=0.1, dark_mode=i_dark_mode)  // Cool/calm colour


// Threshold line colours
color c_thresh_rough  = cu.adjust_colour(p.get_colour(1, 40), dark_mode=i_dark_mode)
color c_thresh_smooth = cu.adjust_colour(p.get_colour(6, 40), dark_mode=i_dark_mode)
color c_baseline      = cu.adjust_colour(p.get_colour(3, 60), dark_mode=i_dark_mode)

// Binary colors for fill of bars/candles
color c_bars = color.new(color.gray, 70)
if i_colour_bars
    if is_rough
        c_bars := cu.adjust_colour(p.get_colour(1, 20), dark_mode=i_dark_mode)
    else if is_smooth
        c_bars := cu.adjust_colour(p.get_colour(6, 20), dark_mode=i_dark_mode)


//───────────────────────────── plots ──────────────────────────────//
// Entropy line
p_val = plot(entropy, "Entropy", c_line, 2, display=display.all)

// Threshold lines
// Note: We always plot the line objects for fills to work, but use `na` values when hidden.
p_thresh_rough = plot(
    show_rough ? rough_threshold : na,
    "Rough Threshold",
    color=c_thresh_rough,
    linewidth=2,
    style=plot.style_line
)

p_thresh_smooth = plot(
    show_smooth ? smooth_threshold : na,
    "Smooth Threshold",
    color=c_thresh_smooth,
    linewidth=2,
    style=plot.style_line
)

// Dynamic baseline (only in dynamic mode)
show_midpoint = not na(threshold_midpoint)
plot(
    show_midpoint ? threshold_midpoint : na,
    "Dynamic Baseline",
    color=c_baseline,
    linewidth=1,
    style=plot.style_line
)


//───────────────────────────── fills ──────────────────────────────//
// Fill colours are pre-calculated with na when not applicable
fill(p_val, p_thresh_rough, c_fill_rough, "Rough Zone Fill")
fill(p_val, p_thresh_smooth, c_fill_smooth, "Smooth Zone Fill")

// Bar/candle colouring
barcolor(c_bars, title="Texture Bar Color")

//─────────────────────── indicator name labels ───────────────────────//
// Display custom indicator name label for visual identification
// Theme-aware colours for readability on both dark and light charts
color c_label_bg   = i_dark_mode ? color.rgb(30, 40, 50, 20) : color.rgb(240, 245, 250, 20)
color c_label_text = i_dark_mode ? color.rgb(220, 225, 230) : color.rgb(40, 45, 50)

if i_indicator_name != ""
    if barstate.islastconfirmedhistory
        label.new(
            bar_index + 10,
            entropy,
            i_indicator_name,
            style=label.style_label_left,
            color=c_label_bg,
            textcolor=c_label_text,
            size=size.normal
        )
    else if i_repeat_name_bars > 0 and bar_index % i_repeat_name_bars == 0 and bar_index != last_bar_index
        label.new(
            bar_index,
            entropy,
            i_indicator_name,
            style=label.style_label_left,
            color=c_label_bg,
            textcolor=c_label_text,
            size=size.small
        )

//#endregion


//==================================================================//
//#region                  EXPORTS & ALERTS                         //
//==================================================================//

//──────────────────────────── exports ─────────────────────────────//
// For GYTS Integration
plot(entropy, '🔗 STREAM PTC 🌵 Entropy (continuous)', display=display.none)
plot(is_rough ? 1.0 : (is_smooth ? -1.0 : 0.0), '🔗 STREAM PTC 🌵 Entropy (ternary)', display=display.none)  // 1.0 = Rough, -1.0 = Smooth, 0.0 = Neutral

//───────────────────────────── alerts ─────────────────────────────//
// Guard against early bars where history operators may return unexpected values
bool trigger_rough  = bar_index >= 2 and is_rough  and not is_rough[1]
bool trigger_smooth = bar_index >= 2 and is_smooth and not is_smooth[1]

// Dynamic Alert Messages for alert()
string mode_str_rough  = str.tostring(i_rough_thresh_mode)
string mode_str_smooth = str.tostring(i_smooth_thresh_mode)

string msg_rough  = str.format(
    "GYTS PTC [CE]: {0} ({1}) Texture → ROUGH (Entropy: {2,number,#.####}, Threshold: {3,number,#.####}, Mode: {4}). Trends are breaking.",
    syminfo.ticker, timeframe.period, entropy, rough_threshold, mode_str_rough
)
string msg_smooth = str.format(
    "GYTS PTC [CE]: {0} ({1}) Texture → SMOOTH (Entropy: {2,number,#.####}, Threshold: {3,number,#.####}, Mode: {4}). Trends are durable.",
    syminfo.ticker, timeframe.period, entropy, smooth_threshold, mode_str_smooth
)

// 1. alert() function calls (for "Any alert() function call" and Webhooks)
if i_use_alerts_rough and trigger_rough
    alert(msg_rough, alert.freq_once_per_bar_close)

if i_use_alerts_smooth and trigger_smooth
    alert(msg_smooth, alert.freq_once_per_bar_close)

// 2. alertcondition() calls (for distinct selection in Create Alert dialog)
alertcondition(trigger_rough, "Texture → Rough", "GYTS PTC [CE]: {{ticker}} ({{interval}}) Texture → ROUGH. Trends are breaking.")
alertcondition(trigger_smooth, "Texture → Smooth", "GYTS PTC [CE]: {{ticker}} ({{interval}}) Texture → SMOOTH. Trends are durable.")

//#endregion
````

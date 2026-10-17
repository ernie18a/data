# Quant Edge Ribbon PRO

- url: https://www.tradingview.com/script/mnu4kTvl-Quant-Edge-Ribbon-PRO/
- type: indicator
- pine_id: PUB;5cd274c96e144eaebc4b29b9e0d98d02
- version: 1.0

## Description

[b]🟦 Quant Edge Ribbon PRO[/b] is a multi-kernel divergence ribbon indicator built on the KernelLens Nadaraya–Watson regression library (a_jabbaroff/KernelLens/1). A primary kernel and eleven longer-bandwidth kernels form a dual-ribbon visualization driven by kernel regression mathematics, an integer trend score in [−11, +11], a theme-aware rendering pipeline, four user-configurable reference levels, and a PRO dashboard. All twelve kernels route through the unified library dispatcher, so the user may select any of the eight kernel families and any of the three filter modes from a single configuration panel.


[b]🟦 HOW IT WORKS[/b]

Quant Edge Ribbon PRO calls the KernelLens library's unified dispatcher (`kl.estimate`) twelve times per bar — once for the primary kernel and once for each of the eleven outer kernels:

```
primary = kl.estimate(type, src, ℓ,        α, period, phase, filter)
long00  = kl.estimate(type, src, ℓ +  1·s, α, period, phase, filter)
long01  = kl.estimate(type, src, ℓ +  2·s, α, period, phase, filter)
...
long10  = kl.estimate(type, src, ℓ + 11·s, α, period, phase, filter)
```

where ℓ is the Primary Bandwidth and s is the Bandwidth Step. All twelve kernels share the same kernel type, filter, shape α, period, and phase — only the bandwidth differs. This guarantees the ribbon behaves as a coherent spectrum of kernel scales rather than a mixture of unrelated signals.

The library handles all weighted-sum computation, loop-depth selection, NA-safe iteration, division-by-zero guards, and input validation internally. Quant Edge Ribbon PRO does not reimplement any kernel math — every bug fix or optimization in the library automatically propagates to this indicator.


[b]🟦 KERNEL LIBRARY INTEGRATION[/b]

Quant Edge Ribbon PRO imports the published KernelLens library and uses the following export:

| Library Export | Used For |
|---|---|
| `kl.estimate()` | Unified dispatcher — routes to the correct kernel based on the user's Kernel Type dropdown. Called twelve times per bar, once for the primary kernel and once for each of the eleven outer kernels. |

Every regression computation — kernel weight evaluation, NA-safe summation, bandwidth-aware loop termination — is delegated to the library. The indicator itself contains zero kernel math; it only orchestrates twelve library calls and aggregates their outputs into the trend score.


[b]🟦 THE TWELVE-KERNEL RIBBON ARCHITECTURE[/b]

**Primary kernel (the shortest, the anchor)** — A single kernel at bandwidth ℓ that serves two roles: (1) it is the reference baseline for the trend score calculation, and (2) it is plotted as a dedicated highlighted anchor line when the "Highlight Primary Kernel" toggle is ON.

**Eleven outer kernels (progressively wider)** — Kernels at bandwidths ℓ+1·s, ℓ+2·s, …, ℓ+11·s, where s is the Bandwidth Step (default: 1). Each outer kernel is plotted as a line on the main chart, all eleven sharing a single score-driven gradient color — so the entire outer ribbon shifts between the theme's bull and bear hues as the trend score moves between −11 and +11.

**Eleven inner ribbon plots (lagged primary snapshots)** — The primary kernel plotted at eleven time-lag offsets (0, 1, 2, …, 10 bars). The resulting visual is a gently flowing shadow that makes expansion and contraction of the outer ribbon easier to perceive. Opacity is user-controlled (default: 40 %).


[b]🟦 INTEGER TREND SCORE[/b]

The trend score is a signed integer in [−11, +11], computed on every bar by eleven pairwise comparisons between the primary kernel (at progressive lag offsets) and the eleven outer kernels:

```
score = 0
for i in 0..10:
    if primary[i] < long_i:
        score += 1
    else:
        score -= 1
```

**Semantic interpretation** — Each comparison pairs an older snapshot of the shortest kernel against a current snapshot of a progressively wider kernel. In an uptrend, past primary values are lower while current wider-kernel values have caught up above them — the inequality resolves positive on most pairs and the score climbs toward +11. The symmetric argument drives the score toward −11 in a downtrend.

**Score parity** — Because the score is a sum of eleven ±1 terms (score = 2k − 11, k ∈ [0, 11]), it is always odd. Reachable values: { −11, −9, −7, −5, −3, −1, 1, 3, 5, 7, 9, 11 }. The score is never exactly zero.


[b]🟦 STRENGTH CATEGORIZATION[/b]

The absolute score is bucketed into four bands, each with a matched label glyph used throughout the dashboard and the last-bar signal label:

| Score Range | Strength | Label |
|---|---|---|
| \|score\| = 1 | NEUTRAL | ▰▱▱▱ NEUTRAL |
| \|score\| ∈ {3, 5} | WEAK | ▰▰▱▱ WEAK BULL / WEAK BEAR |
| \|score\| = 7 | STRONG | ▰▰▰▱ STRONG BULL / STRONG BEAR |
| \|score\| ∈ {9, 11} | TRIPLE | ▰▰▰▰ TRIPLE BULL / TRIPLE BEAR |

The bull / bear suffix is driven by the sign of the score. The progress-bar glyphs (▰▱) give an instant at-a-glance read of confluence intensity without needing to parse the numeric value.


[b]🟦 NON-REPAINTING BEHAVIOR[/b]

Quant Edge Ribbon PRO inherits non-repainting behavior directly from the KernelLens library's `_phase` parameter. A single Phase input (default: 2) shifts every one of the twelve kernel centers into the past by that many bars.

- Phase = 0 — live estimate, flickers on the current bar (real-time only; history is immutable)
- Phase = 1 — 1-bar lag, non-repainting once the bar is confirmed
- Phase = 2 — recommended balance between freshness and stability (default)
- Phase = 3+ — extra margin against erratic ticks, higher lag

Historical repainting never occurs at any phase value. The library contains no `request.security` calls, no lookahead, and no array rotation that could leak future data. Every historical bar's plotted value is final once confirmed.


[b]🟦 VISUAL PIPELINE[/b]

**Outer Ribbon Gradient** — All eleven outer kernels are plotted with a single shared color driven by the trend score via `color.from_gradient(score, -11, 11, thBear, thBull)`. As the score walks across its range, the entire ribbon shifts continuously between the active theme's bearish and bullish hues — producing a smooth visual feedback loop between the math and the palette.

**Inner Ribbon Shadow Trail** — Eleven lag-shifted primary snapshots (primary[0] through primary[10]) drawn in the theme's accent hue with user-controlled opacity. On a trending chart the trail visually expands; on a reversing chart it contracts. Adjust opacity from 0 (invisible) to 100 (fully opaque) — default 40 balances presence and subtlety.

**Primary Kernel Anchor Line** — The primary kernel plotted as a dedicated bold line in the theme's accent color at 80 % opacity, distinct from the shadow trail. Provides a clear centerline amid the ribbon flow. Toggleable.

**Oscillator Subplot** — The smoothed trend score plotted in a dedicated subplot with a score-gradient vertical fill between the score line and the zero line. Opacity is user-controlled. An optional bold score line (up to 4 px wide) overlays the fill for sharp numeric reading.

**Last-Bar Trend Label** — A right-anchored label at the current bar in the oscillator pane. Format: `▲ TRIPLE BULL 11 / 11` (bull) or `▼ WEAK BEAR −3 / 11` (bear). The label is deleted and redrawn on every bar, so only one instance is ever present on the chart.


[b]🟦 OSCILLATOR STYLES[/b]

The oscillator subplot ships with two visual presets, selectable from the Oscillator Style dropdown:

| Style | Plot Style | Fill | Best For |
|---|---|---|---|
| Classic Gradient | `plot.style_line` (smooth curve) | Continuous vertical gradient from score to zero | Trend flow, slope momentum |
| Stepline | `plot.style_stepline` (staircase) | Stepped gradient mirroring the discrete score plateaus | Signal / threshold trading, discrete level crossings |

**Classic Gradient** produces a smooth curve traced through the smoothed score values, with the gradient fill flowing continuously between the score line and the zero line. This is the default and suits traders who read trend direction through slope and curvature.

**Stepline** renders each bar as a horizontal plateau joined to the next bar by a vertical edge. Because the raw score is always an odd integer in { −11, −9, …, 9, 11 }, the staircase visualization honors the score's true discrete nature — making it easier to identify exact threshold crossings (e.g. the moment the score enters the ±9 extreme zone). The fill inherits the same stepline style, so the entire oscillator pane stays geometrically consistent.

Both styles share the same opacity controls, score line toggle, and line width setting — only the geometry of the score line and its fill changes between them.


[b]🟦 THEME SYSTEM[/b]

Ten cohesive color palettes tuned to the Quant Edge Ribbon PRO optical brand. One selection drives every visual component — outer ribbon gradient, inner ribbon accent, oscillator fill, reference lines, signal label, dashboard accents — all sharing the same bull / bear / accent color axes:

| Theme | Bull | Bear |
|---|---|---|
| Prism | Forest green | Crimson red |
| Focus | Cyan steel | Deep orange |
| Solar | Warm amber | Indigo red |
| Frost | Sky blue | Soft lavender |
| Laser | Neon lime | Hot crimson |
| Aurora | Bright gold | Scarlet |
| Plasma | Electric aqua | Magenta |
| Bloom | Mint green | Hot pink |
| Eclipse | Deep navy | Dark crimson |
| Carbon | Near-black | Silver grey |

The oscillator's zero line uses Pine's `chart.fg_color` so it auto-adapts to the actual chart background (white on dark charts, black on light charts) — independent of the Dashboard's Display Mode setting.


[b]🟦 REFERENCE LEVELS[/b]

Four user-configurable horizontal reference lines mark the score's structural thresholds inside the oscillator subplot:

| Level | Style | Meaning |
|---|---|---|
| +11 / −11 | Dotted | Ceiling / floor — the mathematical maximum (every comparison aligned) |
| +9 / −9 | Dashed | Extreme zone — nine or more of the eleven comparisons agree on direction |

Each pair (±11 and ±9) has an independent opacity input (0–100 %). A master toggle (Show Reference Levels) collapses all four lines to fully transparent in a single branch — useful for minimalist layouts. An additional `showOsc` gate hides them automatically when the oscillator itself is disabled.


🟦 PRO DASHBOARD

A 2-column, 12-row theme-aware status panel that updates only on the last bar (zero historical overhead). Supports Dark and Light display modes, six docking positions, and four text sizes. Renders via `force_overlay = true` on the main price chart.

| Row | Label | Content |
|---|---|---|
| Header | Q-EDGE PRO | DARK / LIGHT |
| Theme | Theme | Active palette name |
| Kernel | Kernel | Selected kernel type |
| Divider | RIBBON | — |
| Primary ℓ | Primary ℓ | Primary bandwidth value |
| Span | Span | ℓ → ℓ + 11·s |
| Filter | Filter | No Filter / Smooth / Zero Lag |
| Divider | SCORE | — |
| Score | Score | ▲/▼ + integer score + " / 11" (bull/bear colored) |
| Bull / Bear | Bull / Bear | Bull comparison count / bear comparison count |
| Strength | Strength | ▰-bar + NEUTRAL / WEAK / STRONG / TRIPLE label |
| Primary | Primary | Primary kernel value in chart mintick format |

**Bull / Bear breakdown** — The eleven pairwise comparisons split into bulls (resolved +1) and bears (resolved −1). Always sums to 11, so this row gives a direct visual of how many kernel scales agree with the net direction.


[b]🟦 ALERT CONDITIONS[/b]

Six opt-in alert conditions, each gated by its own toggle:

| Alert | Fires When |
|---|---|
| Bullish Flip | Score crosses from ≤ 0 into positive territory |
| Bearish Flip | Score crosses from ≥ 0 into negative territory |
| Extreme Bullish | Score reaches +9 or higher (first entry into the zone) |
| Extreme Bearish | Score reaches −9 or lower (first entry into the zone) |
| Full Confluence Up | Score hits +11 — every outer kernel aligned bullishly |
| Full Confluence Down | Score hits −11 — every outer kernel aligned bearishly |

All alerts use `alertcondition()` for maximum compatibility with TradingView's alert system including webhooks. Messages are structured as `"Quant Edge Ribbon PRO: <event description>"` for easy parsing in downstream automation.


[b]🟦 RECOMMENDED PRESETS[/b]

| Style | Primary ℓ | Bandwidth Step s | Phase | Filter | Chart |
|---|---|---|---|---|---|
| Scalper | 8–16 | 1 | 1 | No Filter | 1m–5m |
| Day Trader | 16–32 | 1–2 | 2 | Smooth | 15m–1h |
| Swing | 25–50 | 1–2 | 2 | Smooth | 4h–1D |
| Position | 50–120 | 2–3 | 3 | Smooth | 1D–1W |

**Bandwidth Step tuning** — Step = 1 produces a tight ribbon where adjacent outer kernels sit visually close together. Steps of 2–4 spread the eleven outer kernels across a broader spectrum of scales, making expansion / contraction easier to read at a glance. Step 5–6 is reserved for very wide ribbons where each line represents a distinctly different time scale.


[b]🟦 COMPATIBILITY[/b]

- Pine Script v6
- All exchanges, all asset classes (crypto, forex, equities, commodities, indices)
- All timeframes (1 minute through Monthly)
- Both Dark and Light chart themes — visual elements auto-adapt via `chart.fg_color`
- No exchange-specific logic — fully deterministic


[b]🟦 TECHNICAL NOTES[/b]

- **Library dependency** — `import a_jabbaroff/KernelLens/1` — all kernel regression math is delegated to the published library
- **Plot budget** — 11 outer + 11 inner + 1 primary + 2 oscillator plots + 1 fill + 4 hlines = well under Pine's 64-plot limit
- **Table** — Single `var table` created once on `barstate.islast` with `force_overlay = true`; dashboard renders on the main chart pane, zero historical overhead
- **No persistent drawing objects** — no `box.new`, `line.new`, no `array.new`; the single trend label is deleted and recreated every bar so only one instance is ever present
- **Opacity convention** — every user-facing opacity input follows `0 = invisible, 100 = fully opaque`; conversion to Pine's native transparency is centralized in a single helper function (`f_opac`)
- **Non-repainting** — inherits from the library's `_phase` parameter; no `request.security`, no lookahead, no future-bar leakage at any phase value
- **Chart background adaptive** — the oscillator's zero line uses `chart.fg_color`, so it always renders with high contrast regardless of the user's chart color scheme


[b]🟦 DISCLAIMER[/b]

Quant Edge Ribbon PRO is a technical analysis indicator built on the KernelLens Nadaraya–Watson regression library. It is provided solely for educational and research purposes and does not constitute financial, investment, or trading advice.

Kernel regression is a local smoothing technique. It estimates the mean of a source series in the neighborhood of the current bar based on historical data, but it does not predict future prices, does not generate trading signals on its own, and does not guarantee the profitability of any strategy built on top of its output. The integer trend score is a geometric summary of kernel alignments — not a forecast — and should always be combined with broader context: higher-timeframe structure, volatility regime, liquidity, news, and risk management.

Past performance of any model does not guarantee future results. Markets contain systemic risks that cannot be eliminated by any amount of mathematical rigor. Responsibility for any trading decisions rests entirely with the user. Always apply sound capital management, conduct your own independent analysis, and never risk capital you are not prepared to lose.

The author assumes no liability for direct or indirect losses incurred through the use of Quant Edge Ribbon PRO or the underlying KernelLens library.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Quant Edge Ribbon PRO — Multi-Kernel Divergence Ribbon
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0
//  Version     : 1.0.0
//  PineScript  : v6
//  Library     : import a_jabbaroff/KernelLens/1
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Quant Edge Ribbon PRO is a multi-kernel divergence ribbon indicator built
//  on the KernelLens Nadaraya–Watson regression library (a_jabbaroff /
//  KernelLens / 1).  A primary kernel and eleven longer-bandwidth kernels
//  form a dual-ribbon visualization driven by kernel regression mathematics,
//  a theme-aware rendering pipeline, and a PRO dashboard.
//
//  The inner ribbon plots eleven time-lagged snapshots of the primary kernel
//  (offsets 0..10 bars), while the outer ribbon plots eleven kernels with
//  incrementing bandwidth (ℓ+1·s .. ℓ+11·s, where s is the step size).  An
//  integer trend score in [−11, +11] quantifies how many of the longer
//  kernels sit above the time-lagged primary at matching offsets — positive
//  values indicate bullish alignment, negative values bearish.  The score is
//  smoothed and rendered in a dedicated subplot with a choice of two
//  Oscillator Styles (Classic Gradient or Stepline) and a last-bar trend
//  label showing direction and magnitude.
//
//  Every kernel line routes through the unified KernelLens dispatcher, so the
//  user may select any of the eight kernel families (Rational Quadratic,
//  Gaussian, Periodic, Locally Periodic, Epanechnikov, Tricube, Triangular,
//  Cosine) and any of the three filter modes (No Filter / Smooth / Zero Lag).
//  Ten cohesive color palettes drive every visual component — kernel lines,
//  oscillator fill, signal label, dashboard accents — all sharing the same
//  bull / bear / accent color axes.
//
//  Four user-configurable reference lines (±11 ceiling, ±9 extreme) mark the
//  score's structural limits with independently controlled opacities.  The
//  PRO dashboard is theme-aware and supports Dark and Light display modes,
//  updating in real time on the last bar with zero historical overhead.  Six
//  alert conditions cover trend flips, extreme readings, and full-confluence
//  events — each gated by its own opt-in toggle.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Quant Edge Ribbon PRO", "Q-Edge PRO", overlay = false, max_bars_back = 5000, precision = 2)

import a_jabbaroff/KernelLens/1 as kl


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_SRC    = "Source 🔹"
const string GRP_THEME  = "Theme 🔹"
const string GRP_KRN    = "Kernel Engine 🔹"
const string GRP_RIB    = "Ribbon Geometry 🔹"
const string GRP_VIS    = "Visual Style 🔹"
const string GRP_OSC    = "Score Oscillator 🔹"
const string GRP_LVL    = "Reference Levels 🔹"
const string GRP_SIG    = "Signal Label 🔹"
const string GRP_DASH   = "Dashboard 🔹"
const string GRP_ALERT  = "Alerts 🔹"

// Kernel type dropdown options (must match KernelLens library constants exactly)
const string KRN_RQ    = "Rational Quadratic"
const string KRN_GAUSS = "Gaussian"
const string KRN_PER   = "Periodic"
const string KRN_LP    = "Locally Periodic"
const string KRN_EPA   = "Epanechnikov"
const string KRN_TRI   = "Tricube"
const string KRN_TRG   = "Triangular"
const string KRN_COS   = "Cosine"

// Filter mode options (must match KernelLens library constants exactly)
const string FLT_NONE  = "No Filter"
const string FLT_SM    = "Smooth"
const string FLT_ZL    = "Zero Lag"


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Source ──────────────────────────────────────────────────────────────────
src = input.source(close, "Source", group = GRP_SRC,
     tooltip = "Price series feeding every kernel in the ribbon. Typical choices: close, hl2, ohlc4.\n\nAll twelve kernels (1 primary + 11 outer) use the same source — this guarantees the ribbon behaves as a coherent spectrum rather than a mixture of unrelated signals.")


// ─── Theme ───────────────────────────────────────────────────────────────────
themeChoice = input.string("Focus", "Theme",
     options = ["Prism", "Focus", "Solar", "Frost", "Laser", "Aurora", "Plasma", "Bloom", "Eclipse", "Carbon"],
     group = GRP_THEME,
     tooltip = "Ten cohesive color palettes tuned to the Quant Edge Ribbon PRO optical brand. One selection drives every visual component: outer ribbon gradient, inner ribbon accent, oscillator fill, signal label, dashboard accents.\n\nPrism — Forest green + crimson red (classic)\nFocus — Cyan steel + deep orange (default)\nSolar — Warm amber + indigo red\nFrost — Sky blue + soft lavender\nLaser — Neon lime + hot crimson\nAurora — Bright gold + scarlet\nPlasma — Electric aqua + magenta\nBloom — Mint green + hot pink\nEclipse — Deep navy + dark crimson\nCarbon — Near-black + silver grey")


// ─── Kernel Engine ───────────────────────────────────────────────────────────
kType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_KRN,
     tooltip = "Kernel family used for every line in the ribbon (primary + 11 outer).  All twelve lines share the same kernel type — only the bandwidth differs.\n\nRational Quadratic — multi-scale mixer, α controls stretch (recommended default)\nGaussian / RBF — canonical smoother, infinitely differentiable\nPeriodic — resonates with repetition distance p\nLocally Periodic — periodic × gaussian (seasonal + trend)\nEpanechnikov — MSE-optimal, compact support\nTricube — LOWESS standard, near-Gaussian\nTriangular — simplest compact kernel\nCosine — raised-cosine, smooth boundary")

kAlpha = input.float(1.0, "Shape α (RQ only)", minval = 0.01, step = 0.25, group = GRP_KRN,
     tooltip = "Rational Quadratic shape parameter α.\nIgnored by other kernels.\n\nα → ∞ — collapses to pure Gaussian\nα → 0⁺ — stretches the curve over longer length scales\nα = 1 — balanced default (equal multi-scale weight)\nα = 2–5 — moderate long-range emphasis (smoother ribbon)\nα > 10 — heavy long-range smoothing")

kPeriod = input.int(20, "Period (P / LP)", minval = 1, group = GRP_KRN,
     tooltip = "Repetition distance p in bars.\nUsed only by Periodic and Locally Periodic kernels.\n\nTypical values:\n20 — intraday / daily cycle\n52 — weekly cycle\n60 — 1-hour cycle on 1m chart\n\nIgnored by the other six kernel families.")

kPhase = input.int(2, "Phase", minval = 0, group = GRP_KRN,
     tooltip = "Non-repainting offset — each kernel center is shifted by this many bars.\n\n0 = live estimate, flickers on the current bar\n1 = 1-bar lag, non-repainting once confirmed\n2 = recommended balance (default)\n3+ = extra margin against erratic ticks, higher lag\n\nHistorical plots are immutable at every phase value.")

kFilter = input.string(FLT_NONE, "Filter",
     options = [FLT_NONE, FLT_SM, FLT_ZL],
     group   = GRP_KRN,
     tooltip = "Filter layer applied on top of every raw kernel estimate in the ribbon.\n\nNo Filter — single-pass, most reactive (default)\nSmooth — double-pass, more stable, adds lag\nZero Lag — Ehlers de-lag trick (2·raw − smooth), tracks price tightly\n\nThe same filter mode applies to all twelve ribbon lines.")


// ─── Ribbon Geometry ─────────────────────────────────────────────────────────
ribBw = input.int(25, "Primary Bandwidth ℓ", minval = 2, step = 1, group = GRP_RIB,
     tooltip = "Kernel scale ℓ of the primary (shortest) kernel.\n\nSmaller = tighter fit, noisier, more reactive.\nLarger = smoother curve, more stable, slower.\n\nThe eleven outer ribbon lines use bandwidths ℓ+1·s, ℓ+2·s, …, ℓ+11·s where s is the Bandwidth Step.\n\nRecommended ranges by style:\nScalper — 8–16\nDay trader — 16–32\nSwing — 25–50\nPosition — 50–120")

ribStep = input.int(1, "Bandwidth Step s", minval = 1, maxval = 6, group = GRP_RIB,
     tooltip = "Bandwidth increment between adjacent outer ribbon lines.\n\n1 — tight ribbon, lines stay visually close (default)\n2 — moderate spread, clearer separation\n3–4 — wide ribbon, easier to read expansion / contraction at a glance\n5–6 — very wide, each line represents a distinct time scale\n\nLarger steps make the ribbon span a broader spectrum of kernel scales at the cost of smoothness in the visual sweep.")


// ─── Visual Style ────────────────────────────────────────────────────────────
showOuter = input.bool(true, "Show Outer Ribbon", group = GRP_VIS,
     tooltip = "Toggle the outer ribbon (eleven kernels with incrementing bandwidth).\n\nThe outer ribbon is the primary visual signal — its color is driven by the trend score via gradient mapping, so the entire ribbon shifts between the theme's bull and bear hues as score moves between −11 and +11.")

outerWidth = input.int(2, "Outer Line Width", minval = 1, maxval = 5, group = GRP_VIS,
     tooltip = "Thickness of each outer ribbon line in pixels.\n\n1 — thin, minimal\n2 — standard (default)\n3 — bold, prominent\n4–5 — extra prominence, may overcrowd the chart on low zoom\n\nAll eleven outer lines share the same width.")

showInner = input.bool(true, "Show Inner Ribbon", group = GRP_VIS,
     tooltip = "Toggle the inner ribbon (eleven time-lagged snapshots of the primary kernel).\n\nThe inner ribbon provides a faded reference trail — each line is the primary kernel shifted i bars into the past, for i = 0..10.  The resulting visual is a gently flowing shadow that makes expansion and contraction of the outer ribbon easier to perceive.")

innerOpacity = input.int(40, "Inner Ribbon Opacity", minval = 0, maxval = 100, group = GRP_VIS,
     tooltip = "Opacity of the inner ribbon lines (0–100).\n\n0 — invisible (fully transparent)\n5 — barely visible ghost trail\n40 — recommended balance (default)\n70 — solid and prominent\n100 — fully opaque\n\nHigher values make the inner ribbon more prominent — but may compete visually with the outer ribbon gradient.")

showPrimary = input.bool(true, "Highlight Primary Kernel", group = GRP_VIS,
     tooltip = "Draw a dedicated bold line for the primary kernel (ℓ = Primary Bandwidth), distinct from the inner ribbon trail.\n\nOn — primary kernel is plotted as a standalone bright line using the theme's accent color\nOff — primary kernel is visible only as the first line of the inner ribbon trail\n\nEnable for a clear anchor line amid the ribbon flow.")


// ─── Score Oscillator ────────────────────────────────────────────────────────
showOsc = input.bool(true, "Show Score Oscillator", group = GRP_OSC,
     tooltip = "Toggle the score oscillator rendered in the indicator's own subplot pane.\n\nThe oscillator plots the (smoothed) trend score in [−11, +11] with a gradient fill between the score line and zero — green above zero, red below zero, colored by the active theme.\n\nDisable to hide the oscillator entirely; the ribbon on the main chart continues to render unchanged.")

oscStyle = input.string("Classic Gradient", "Oscillator Style",
     options = ["Classic Gradient", "Stepline"],
     group = GRP_OSC,
     tooltip = "Two rendering presets for the oscillator's score line and gradient fill.\n\nClassic Gradient — smooth curve traced through the smoothed score values, with a continuously gradient-filled area down to zero.  Best for visualizing trend flow and slope momentum.\n\nStepline — discrete step visualization.  Each bar shows the score as a horizontal plateau, joined to the next bar by a vertical edge.  The resulting staircase visual honors the integer nature of the score (always an odd value in [−11, +11]) and sharpens reading of discrete threshold crossings.  Best for signal / threshold traders.")

oscSmooth = input.int(2, "Score Smoothing", minval = 1, maxval = 20, group = GRP_OSC,
     tooltip = "Simple-moving-average smoothing applied to the raw integer score before plotting.\n\n1 — no smoothing, raw integer steps\n2 — light smoothing (default)\n3–5 — moderate smoothing, fluid curves\n6–20 — heavy smoothing, may mask short-term flips\n\nRaw score remains unsmoothed for event detection (flip, extreme).  Smoothing only affects the visual oscillator curve.")

oscFillOpacity = input.int(100, "Oscillator Fill Opacity", minval = 5, maxval = 100, group = GRP_OSC,
     tooltip = "Opacity of the gradient fill between the score line and the zero line.\n\n5 — nearly invisible\n20 — subtle tint\n60 — balanced mid-tint\n100 — fully opaque fill (default)\n\nHigher values make the oscillator a more dominant visual element; lower values keep it subdued.")

showOscLine = input.bool(true, "Show Oscillator Line", group = GRP_OSC,
     tooltip = "Draw a bold line tracing the smoothed score on top of the gradient fill.\n\nOn — thick score-gradient line overlays the fill, giving a sharp visual anchor that emphasizes the current score level.\n\nOff — line is hidden; only the gradient fill conveys the oscillator shape.\n\nRecommended ON for crisp readability, OFF for a more ambient fill-only aesthetic.")

oscLineWidth = input.int(2, "Oscillator Line Width", minval = 1, maxval = 4, group = GRP_OSC,
     tooltip = "Thickness of the oscillator line in pixels.\n\n1 — thin, minimal\n2 — standard bold (default)\n3 — extra bold, high visibility\n4 — thickest, dominant visual\n\nIgnored when Show Oscillator Line is off.")


// ─── Reference Levels ───────────────────────────────────────────────────────
showRefLines = input.bool(true, "Show Reference Levels", group = GRP_LVL,
     tooltip = "Master toggle for the four horizontal reference lines in the oscillator subplot: ±11 (ceiling / floor) and ±9 (extreme zones).\n\nOn — all four lines render with their configured opacities (below).\nOff — every reference line collapses to fully transparent and disappears from the subplot.\n\nThese lines mark the score's structural limits: ±11 is the mathematical maximum (every one of the eleven kernel comparisons aligned), while ±9 marks the onset of \"near-full\" confluence.")

ceilOpacity = input.int(100, "±11 Ceiling Opacity", minval = 0, maxval = 100, group = GRP_LVL,
     tooltip = "Opacity of the +11 / −11 ceiling and floor lines (dotted style).\n\n0 — invisible\n30 — faint reference\n60 — balanced\n100 — fully opaque (default)\n\nThese lines mark the absolute score limits; fully opaque by default so the score can never visually leave the pane's boundaries unnoticed.")

extOpacity = input.int(100, "±9 Extreme Opacity", minval = 0, maxval = 100, group = GRP_LVL,
     tooltip = "Opacity of the +9 / −9 extreme zone lines (dashed style).\n\n0 — invisible\n30 — faint reference\n60 — balanced\n100 — fully opaque (default)\n\n±9 marks the \"strong confluence\" threshold where nine or more of the eleven kernel comparisons agree on direction.  Crossings through this level match the Extreme Bullish / Extreme Bearish alert events.")

refLineWidth = input.int(1, "Reference Line Width", minval = 1, maxval = 3, group = GRP_LVL,
     tooltip = "Thickness of all four reference lines in pixels.\n\n1 — thin, minimal reference (default)\n2 — standard\n3 — bold, prominent\n\nApplies to ±11 dotted and ±9 dashed lines uniformly.")


// ─── Signal Label ────────────────────────────────────────────────────────────
showLabel = input.bool(true, "Show Trend Label", group = GRP_SIG,
     tooltip = "Render a single right-anchored label at the current bar in the oscillator pane.\n\nThe label shows the active strength category and the integer score value — e.g. \"TRIPLE BULL ▲ 11/11\" or \"WEAK BEAR ▼ −4/11\" — colored by the same gradient mapping as the oscillator fill.\n\nThe label is deleted and redrawn on every bar, so only one instance is ever on the chart.")

labelOffset = input.int(2, "Label Right Offset (bars)", minval = 0, maxval = 10, group = GRP_SIG,
     tooltip = "Horizontal offset of the trend label, in bars, to the right of the current bar.\n\n0 — label sits directly on the current bar (may overlap the latest oscillator values)\n2 — recommended default, clear of the oscillator tip\n5+ — further into the future, extra breathing room")


// ─── Dashboard ───────────────────────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Compact 2-column live status panel. Updates only on the last bar — zero historical overhead.")

displayMode = input.string("Dark", "Display Mode",
     options = ["Dark", "Light"],
     group = GRP_DASH,
     tooltip = "Dark — black dashboard background, bright accents (default for dark charts).\nLight — white dashboard background, darker accents (use on light charts).")

dashPos = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_DASH,
     tooltip = "Where the dashboard panel docks on the chart.\n\nTop Right — default, clear of most indicators\nTop Left — good for right-anchored charts\nMiddle Right / Left — centered vertically\nBottom Right / Left — tucked below price action")

dashSize = input.string("Small", "Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DASH,
     tooltip = "Dashboard text size.\n\nTiny — minimal footprint, hard to read on 4K monitors\nSmall — default, clean and readable (recommended)\nNormal — larger cells, easier to read at a glance\nLarge — maximum readability, biggest footprint")


// ─── Alerts ──────────────────────────────────────────────────────────────────
alertBull = input.bool(true, "Bullish Flip (score crosses 0 ↑)", group = GRP_ALERT,
     tooltip = "Fire an alert when the trend score crosses from ≤ 0 into positive territory.\n\nThis is the finest-grained directional signal — captures every transition from bearish / neutral to bullish on the primary kernel relative to the ribbon.\n\nDisable to suppress bullish flip alerts only.")

alertBear = input.bool(true, "Bearish Flip (score crosses 0 ↓)", group = GRP_ALERT,
     tooltip = "Fire an alert when the trend score crosses from ≥ 0 into negative territory.\n\nThe bearish counterpart of Bullish Flip — captures every transition from bullish / neutral to bearish on the ribbon.\n\nDisable to suppress bearish flip alerts only.")

alertExtBull = input.bool(true, "Extreme Bullish (score ≥ +9)", group = GRP_ALERT,
     tooltip = "Fire an alert when the trend score reaches +9 or higher — nine or more of the eleven outer kernels sit above the lagged primary.\n\nThis is a strong confluence signal indicating broad alignment of kernel scales to the upside. Fires once per entry into the zone (not continuously).")

alertExtBear = input.bool(true, "Extreme Bearish (score ≤ −9)", group = GRP_ALERT,
     tooltip = "Fire an alert when the trend score reaches −9 or lower — nine or more of the eleven outer kernels sit below the lagged primary.\n\nThe bearish counterpart of Extreme Bullish. Fires once per entry into the zone (not continuously).")

alertFullConfBull = input.bool(false, "Full Confluence Up (score = +11)", group = GRP_ALERT,
     tooltip = "Fire an alert when every single outer kernel aligns bullishly with the lagged primary (score = +11 / 11).\n\nThis is the rarest and strongest bullish signal the indicator can produce. Disabled by default — enable for very high-conviction entry setups only.")

alertFullConfBear = input.bool(false, "Full Confluence Down (score = −11)", group = GRP_ALERT,
     tooltip = "Fire an alert when every single outer kernel aligns bearishly with the lagged primary (score = −11 / 11).\n\nThe bearish counterpart of Full Confluence Up. Disabled by default — enable for very high-conviction short entry setups only.")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (ten themes from Apex)
// ═══════════════════════════════════════════════════════════════════════════════
// Each theme defines three axis colors:
//   thBull   — bullish side  (positive score, bull gradient endpoint)
//   thBear   — bearish side  (negative score, bear gradient endpoint)
//   thAccent — neutral accent (inner ribbon trail, primary kernel line)

color thBull = switch themeChoice
    "Prism"   => #51B155
    "Focus"   => #00BCD4
    "Solar"   => #FF9800
    "Frost"   => #4FC3F7
    "Laser"   => #00E676
    "Aurora"  => #FFD600
    "Plasma"  => #00E5FF
    "Bloom"   => #69F0AE
    "Eclipse" => #0D47A1
    "Carbon"  => #1A1A1A
    =>           #00BCD4

color thBear = switch themeChoice
    "Prism"   => #F23645
    "Focus"   => #FF6D00
    "Solar"   => #E53935
    "Frost"   => #9575CD
    "Laser"   => #FF1744
    "Aurora"  => #EF5350
    "Plasma"  => #E040FB
    "Bloom"   => #FF4081
    "Eclipse" => #B71C1C
    "Carbon"  => #757575
    =>           #FF6D00

color thAccent = switch themeChoice
    "Prism"   => #80828D
    "Focus"   => #607D8B
    "Solar"   => #7986CB
    "Frost"   => #B0BEC5
    "Laser"   => #757575
    "Aurora"  => #9E9E9E
    "Plasma"  => #546E7A
    "Bloom"   => #455A64
    "Eclipse" => #546E7A
    "Carbon"  => #9E9E9E
    =>           #607D8B

// ─── Opacity helper ──────────────────────────────────────────────────────────
// Every opacity value in this script follows the intuitive convention:
//
//   0   = invisible (fully transparent)
//   100 = fully opaque
//
// Pine's native color.new() takes the inverse (transparency).  The helper
// below performs the conversion once at every call site, keeping the rest of
// the script readable in pure opacity semantics — both in code and in the
// user-facing inputs / tooltips.

f_opac(color _base, int _opacity) =>
    color.new(_base, 100 - _opacity)


// Dashboard theme colors (Dark vs Light)
color dashBg      = displayMode == "Dark" ? #0A0A0A : #FFFFFF
color dashBgAlt   = displayMode == "Dark" ? #141414 : #F5F5F5
color dashFg      = displayMode == "Dark" ? #E0E0E0 : #1A1A1A
color dashBorder  = displayMode == "Dark" ? #2A2A2A : #DCDCDC
color dashHeader  = f_opac(thBull, 100)   // fully opaque header accent
color dashSection = displayMode == "Dark" ? #1A1A1A : #EEEEEE


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 3   —   KERNEL RIBBON COMPUTATIONS
// ═══════════════════════════════════════════════════════════════════════════════
// All twelve kernels share the same kernel type, filter, α, period, and phase —
// only the bandwidth differs.  The primary kernel anchors the ribbon at ℓ, and
// the eleven outer kernels step outward at ℓ + k·s for k = 1..11.
//
// Library call signature:
//   kl.estimate(_kernelType, _src, _bandwidth, _shapeAlpha, _period, _phase, _filter)
//
// Bandwidth arguments are compile-time constants from the caller's perspective
// (ribBw + k·ribStep with k as a literal int), so the library's <simple int>
// type contract is honored at every call site.

// ─── Primary kernel (the shortest, the anchor) ───────────────────────────────
primary = kl.estimate(kType, src, ribBw,                kAlpha, kPeriod, kPhase, kFilter)

// ─── Eleven outer kernels (incrementing bandwidth) ───────────────────────────
long00  = kl.estimate(kType, src, ribBw +  1 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long01  = kl.estimate(kType, src, ribBw +  2 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long02  = kl.estimate(kType, src, ribBw +  3 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long03  = kl.estimate(kType, src, ribBw +  4 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long04  = kl.estimate(kType, src, ribBw +  5 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long05  = kl.estimate(kType, src, ribBw +  6 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long06  = kl.estimate(kType, src, ribBw +  7 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long07  = kl.estimate(kType, src, ribBw +  8 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long08  = kl.estimate(kType, src, ribBw +  9 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long09  = kl.estimate(kType, src, ribBw + 10 * ribStep, kAlpha, kPeriod, kPhase, kFilter)
long10  = kl.estimate(kType, src, ribBw + 11 * ribStep, kAlpha, kPeriod, kPhase, kFilter)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   SCORE ANALYTICS
// ═══════════════════════════════════════════════════════════════════════════════
// Score rule — eleven pairwise comparisons between the primary kernel (at
// progressive lag offsets) and each of the eleven outer kernels:
//   For each pair i ∈ [0..10]:
//     score += 1   if  primary[i] < longNN
//     score -= 1   otherwise
//
// Semantic interpretation — the comparison pairs an older snapshot of the
// shortest kernel against a current snapshot of a progressively wider kernel.
// When the price is trending up, past primary values were lower while current
// wider-kernel values have caught up above them — the inequality resolves
// positive on most pairs and the score climbs toward +11.  The symmetric
// argument drives the score toward −11 in a downtrend.
//
// Score range: integer, [−11, +11].

int score = 0
score += primary[0]  < long00 ? 1 : -1
score += primary[1]  < long01 ? 1 : -1
score += primary[2]  < long02 ? 1 : -1
score += primary[3]  < long03 ? 1 : -1
score += primary[4]  < long04 ? 1 : -1
score += primary[5]  < long05 ? 1 : -1
score += primary[6]  < long06 ? 1 : -1
score += primary[7]  < long07 ? 1 : -1
score += primary[8]  < long08 ? 1 : -1
score += primary[9]  < long09 ? 1 : -1
score += primary[10] < long10 ? 1 : -1

// ─── Smoothed score for oscillator rendering ─────────────────────────────────
float scoreSm = ta.sma(score, oscSmooth)

// ─── Direction (sign of raw score) ───────────────────────────────────────────
int dir = score > 0 ? 1 : score < 0 ? -1 : 0

// ─── Strength categorization ─────────────────────────────────────────────────
// Bucket absolute score into four bands — used for label text and dashboard.
// Note: the score is always odd (sum of eleven ±1 terms → 2k − 11 with k ∈
// [0, 11]), so the reachable values in each band are:
//   |score| = 1          →  NEUTRAL
//   |score| ∈ {3, 5}     →  WEAK
//   |score| = 7          →  STRONG
//   |score| ∈ {9, 11}    →  TRIPLE (near-full confluence)
int absScore = math.abs(score)
int strength = absScore >= 9 ? 3 : absScore >= 6 ? 2 : absScore >= 3 ? 1 : 0

string strLbl = strength == 3 ? (dir > 0 ? "TRIPLE BULL"  : "TRIPLE BEAR")
     :         strength == 2 ? (dir > 0 ? "STRONG BULL"  : "STRONG BEAR")
     :         strength == 1 ? (dir > 0 ? "WEAK BULL"    : "WEAK BEAR")
     :                          "NEUTRAL"

string strBar = strength == 3 ? "▰▰▰▰" : strength == 2 ? "▰▰▰▱" : strength == 1 ? "▰▰▱▱" : "▰▱▱▱"

// ─── Event detection (for alerts) ────────────────────────────────────────────
bool bullFlip     = score > 0  and score[1] <= 0
bool bearFlip     = score < 0  and score[1] >= 0
bool extBullEvent = score >=  9 and score[1] <  9
bool extBearEvent = score <= -9 and score[1] > -9
bool fullBullEvt  = score == 11 and score[1] < 11
bool fullBearEvt  = score == -11 and score[1] > -11


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   VISUAL LAYER
// ═══════════════════════════════════════════════════════════════════════════════
// Rendering pipeline — three parallel visual layers driven by the score:
//   • Outer ribbon — eleven longer kernels drawn with a score-driven gradient
//     color mapped through color.from_gradient across the active theme's bull
//     and bear hues.
//   • Inner ribbon — eleven lag-shifted primary snapshots drawn in the theme's
//     accent hue with user-controlled opacity.
//   • Oscillator — smoothed score plotted with gradient fill to zero line,
//     matching the outer ribbon's gradient coloring.
//
// Ribbon plots use force_overlay = true to render on the main price chart,
// while the oscillator stays in the indicator's own subplot pane.

// ─── Gradient score color (shared by outer ribbon, oscillator, label) ───────
color scoreColor = color.from_gradient(score, -11, 11, thBear, thBull)

// Opacity convention reminder — every value below is an OPACITY in [0, 100]:
//   0   = invisible
//   100 = fully opaque
// The f_opac() helper (defined in Section 2) converts to Pine's transparency.

// ─── Outer ribbon color (100 % opaque when shown, 0 % when hidden) ──────────
color outerCol = f_opac(scoreColor, showOuter ? 100 : 0)

// ─── Inner ribbon color (user-controlled opacity, 0 % when hidden) ──────────
color innerCol = f_opac(thAccent, showInner ? innerOpacity : 0)

// ─── Primary kernel anchor color (80 % opaque — bolder than inner ribbon) ──
color primCol = f_opac(thAccent, showPrimary ? 80 : 0)

// ─── Outer ribbon plots (force onto main chart) ──────────────────────────────
plot(long00, "Outer 01", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long01, "Outer 02", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long02, "Outer 03", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long03, "Outer 04", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long04, "Outer 05", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long05, "Outer 06", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long06, "Outer 07", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long07, "Outer 08", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long08, "Outer 09", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long09, "Outer 10", color = outerCol, linewidth = outerWidth, force_overlay = true)
plot(long10, "Outer 11", color = outerCol, linewidth = outerWidth, force_overlay = true)

// ─── Inner ribbon plots (lagged primary snapshots) ───────────────────────────
plot(primary[0],  "Inner 01", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[1],  "Inner 02", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[2],  "Inner 03", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[3],  "Inner 04", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[4],  "Inner 05", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[5],  "Inner 06", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[6],  "Inner 07", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[7],  "Inner 08", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[8],  "Inner 09", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[9],  "Inner 10", color = innerCol, linewidth = 1, force_overlay = true)
plot(primary[10], "Inner 11", color = innerCol, linewidth = 1, force_overlay = true)

// ─── Primary kernel anchor line (optional bold highlight) ───────────────────
plot(primary, "Primary Kernel", color = primCol, linewidth = 2, force_overlay = true)

// ─── Oscillator (subplot) — smoothed score with gradient fill ───────────────
// Two plots define the fill strip; both are hidden (color = na) and only their
// position in space matters for fill() — the fill itself carries all visual
// weight via a vertical gradient between scoreSm and 0.
//
// Fill-anchor opacities (both values are in the 0..100 opacity convention):
//   top of fill    = oscFillOpacity            — user-controlled, 5–100
//   bottom of fill = oscFillOpacity − 50, floored at 5 so the silhouette of
//                    the fill never collapses completely at low settings.
int oscTopOpac = oscFillOpacity
int oscBotOpac = math.max(5, oscTopOpac - 50)

// Score line serves two purposes:
//   1. Vertical anchor for the fill() gradient below (always present).
//   2. Optional bold visual trace on top of the fill when showOscLine is on.
// When showOscLine is off, color collapses to na so the fill uses this plot
// as an invisible anchor only — the gradient fill then renders the oscillator
// on its own for a more ambient fill-only look.
//
// The plot style is driven by the Oscillator Style dropdown:
//   Classic Gradient → plot.style_line     (smooth curve)
//   Stepline         → plot.style_stepline (discrete staircase — honors the
//                                           integer nature of the score)
// The zero line and the fill inherit the same style, so the entire oscillator
// visual stays geometrically consistent with the user's choice.
oscPlotStyle = oscStyle == "Stepline" ? plot.style_stepline : plot.style_line
color oscLineCol = showOscLine ? f_opac(scoreColor, 100) : na
p_score = plot(showOsc ? scoreSm : na, "Score", color = oscLineCol, linewidth = oscLineWidth, style = oscPlotStyle)
// Zero line uses chart.fg_color so it auto-adapts to the actual chart
// background (white line on dark charts, black line on light charts) —
// independent of the Dashboard's Display Mode setting.
p_zero  = plot(showOsc ? 0       : na, "Zero",             color = f_opac(chart.fg_color, 100), linewidth = 1, style = oscPlotStyle)

fill(p_score, p_zero, scoreSm, 0,
     f_opac(scoreColor, oscTopOpac),
     f_opac(scoreColor, oscBotOpac))

// ─── Score reference lines in subplot ────────────────────────────────────────
// Four horizontal reference lines mark the score's structural thresholds:
//   ±11 ceiling / floor  — dotted, opacity from ceilOpacity input
//   ±9  extreme zones    — dashed, opacity from extOpacity  input
//
// hline() requires an <input color> qualifier, so user-defined helpers like
// f_opac (which return <series color>) cannot be used here.  Each call uses
// color.new(X, 100 − opacity) inline to keep opacity semantics readable.
//
// Two gates collapse every line to fully transparent when either is off:
//   showOsc       — master oscillator toggle (hides the whole subplot visual)
//   showRefLines  — user toggle for the reference lines alone
int ceilTrans = (showOsc and showRefLines) ? 100 - ceilOpacity : 100
int extTrans  = (showOsc and showRefLines) ? 100 - extOpacity  : 100

hline( 11, "+11 Ceiling", color = color.new(thBull, ceilTrans), linestyle = hline.style_dotted, linewidth = refLineWidth)
hline(-11, "−11 Floor",   color = color.new(thBear, ceilTrans), linestyle = hline.style_dotted, linewidth = refLineWidth)
hline(  9, "+9 Extreme",  color = color.new(thBull, extTrans),  linestyle = hline.style_dashed, linewidth = refLineWidth)
hline( -9, "−9 Extreme",  color = color.new(thBear, extTrans),  linestyle = hline.style_dashed, linewidth = refLineWidth)

// ─── Trend label at current bar (subplot, right-anchored) ───────────────────
// Recreated on every bar; the [1]-offset delete wipes the previous instance so
// only one label is ever present on the chart.  The label lives in the
// oscillator subplot, so its visibility also requires showOsc to be on.
if showLabel and showOsc
    // Direction glyph prefixes the label — ▲ for bull, ▼ for bear, ━ for flat.
    string lblArrow = dir == 1 ? "▲" : dir == -1 ? "▼" : "━"
    string lblText  = lblArrow + "  " + strLbl + "   " + str.tostring(score) + " / 11"
    label.delete(label.new(
         bar_index + labelOffset, 0, lblText,
         color     = color(na),
         textcolor = scoreColor,
         style     = label.style_label_left,
         size      = size.normal)[1])


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   PRO DASHBOARD   (theme-aware, Dark / Light)
// ═══════════════════════════════════════════════════════════════════════════════

// Position resolver
posV = switch dashPos
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    =>                 position.top_right

// Size resolver
sizV = switch dashSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.small

// Helper — format price with chart mintick
f_fmt(float _v) =>
    na(_v) ? "—" : str.tostring(_v, format.mintick)

// Helper — direction glyph
f_arrow(int _t) =>
    _t ==  1 ? "▲" : _t == -1 ? "▼" : "━"

var table dash = na

// Bull / Bear counts across the 11 score comparisons — used in dashboard
int bullCount = math.round(float(score + 11) / 2.0)  // how many comparisons resolved positive
int bearCount = 11 - bullCount                       // how many resolved negative

if barstate.islast and showDash
    dash := table.new(posV, 2, 12,
         bgcolor       = dashBg,
         border_color  = dashBorder,
         border_width  = 1,
         frame_color   = dashBorder,
         frame_width   = 2,
         force_overlay = true)

    // ─── Row 0 — Header ───
    table.cell(dash, 0, 0, "Q-EDGE PRO",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 0, str.upper(displayMode),
         text_color = dashFg, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 1 — Theme (bg) ───
    table.cell(dash, 0, 1, "Theme",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 1, themeChoice,
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 2 — Kernel (bgAlt) ───
    table.cell(dash, 0, 2, "Kernel",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 2, kType,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 3 — Section divider: RIBBON ───
    table.cell(dash, 0, 3, "RIBBON",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 3, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 4 — Primary ℓ (bg) ───
    table.cell(dash, 0, 4, "Primary ℓ",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(ribBw),
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 5 — Span ℓ..ℓ+11·s (bgAlt) ───
    table.cell(dash, 0, 5, "Span",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(ribBw) + " → " + str.tostring(ribBw + 11 * ribStep),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 6 — Filter (bg) ───
    table.cell(dash, 0, 6, "Filter",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 6, kFilter,
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 7 — Section divider: SCORE ───
    table.cell(dash, 0, 7, "SCORE",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 7, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 8 — Raw score (bg) ───
    table.cell(dash, 0, 8, "Score",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 8, f_arrow(dir) + "  " + str.tostring(score) + " / 11",
         text_color = scoreColor, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 9 — Bull / Bear breakdown (bgAlt) ───
    table.cell(dash, 0, 9, "Bull / Bear",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(bullCount) + " / " + str.tostring(bearCount),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 10 — Strength (bg) ───
    table.cell(dash, 0, 10, "Strength",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 10, strBar + "  " + strLbl,
         text_color = scoreColor, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 11 — Primary price (bgAlt) ───
    table.cell(dash, 0, 11, "Primary",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 11, f_fmt(primary),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 7   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(alertBull and bullFlip,
     title   = "Quant Edge Ribbon PRO — Bullish Flip",
     message = "Quant Edge Ribbon PRO: trend score crossed above zero — bullish flip confirmed.")

alertcondition(alertBear and bearFlip,
     title   = "Quant Edge Ribbon PRO — Bearish Flip",
     message = "Quant Edge Ribbon PRO: trend score crossed below zero — bearish flip confirmed.")

alertcondition(alertExtBull and extBullEvent,
     title   = "Quant Edge Ribbon PRO — Extreme Bullish",
     message = "Quant Edge Ribbon PRO: score reached +9 or higher — strong bullish confluence.")

alertcondition(alertExtBear and extBearEvent,
     title   = "Quant Edge Ribbon PRO — Extreme Bearish",
     message = "Quant Edge Ribbon PRO: score reached −9 or lower — strong bearish confluence.")

alertcondition(alertFullConfBull and fullBullEvt,
     title   = "Quant Edge Ribbon PRO — Full Confluence Up",
     message = "Quant Edge Ribbon PRO: score reached +11 / 11 — full bullish confluence across the ribbon.")

alertcondition(alertFullConfBear and fullBearEvt,
     title   = "Quant Edge Ribbon PRO — Full Confluence Down",
     message = "Quant Edge Ribbon PRO: score reached −11 / 11 — full bearish confluence across the ribbon.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END CODE
// ═══════════════════════════════════════════════════════════════════════════════
````

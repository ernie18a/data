# Artemis Volatility Bands PRO

- url: https://www.tradingview.com/script/LgKH3YNn-Artemis-Volatility-Bands-PRO/
- type: indicator
- pine_id: PUB;62c278798c7f407d8f56bb1f3f2ce1c5
- version: 1.0

## Description

[b]🟦 Artemis Volatility Bands PRO[/b] is a price-overlay volatility indicator built on the KernelLens Nadaraya–Watson regression library (a_jabbaroff/KernelLens/1). A single kernel estimate — selectable from eight classical kernel families — anchors the Basis line. Around it, two outer bands fan outward by a fixed multiple of the residual standard deviation, creating an envelope whose width is model-consistent with the kernel. The interior is washed with a 6-layer neon halo that mirrors the statistical density of price residuals under normality. A signal engine detects basis-breaks with confirming slope direction, guarded by Confirmed (zero-repaint) or Realtime mode. Twelve cohesive color themes, a theme-aware Dark / Light dashboard, and four opt-in alert conditions complete the indicator.


[b]🟦 HOW IT WORKS[/b]

Artemis Volatility Bands PRO fuses two mathematical operations on every bar — a single kernel regression pass and a residual standard deviation calculation:

basis = kl.estimate(type, src, ℓ, α, period, phase, filter)
sigma = kl.confidenceBand(src, basis, window)
upper = basis + k · σ
lower = basis − k · σ

where ℓ is the Primary Bandwidth, k is the Band Multiplier, and window is the Residual σ Window. The kernel regression produces the Basis line, and the residual standard deviation (σ of price − basis) produces the per-σ band half-width.

This architecture collapses classical Bollinger band duality: in Bollinger bands, the moving average and volatility estimate live in different statistical universes. In Artemis, both emerge from a single kernel pass, so the envelope is internally consistent by construction. The Basis is always non-parametric, and the band width always measures deviation relative to the Basis, never to a disconnected moving average.

The library handles all weighted-sum computation, kernel weight evaluation, NA-safe iteration, division-by-zero guards, and input validation internally. Artemis Volatility Bands PRO does not reimplement any kernel math — every bug fix or optimization in the library automatically propagates to this indicator.


[b]🟦 KERNEL LIBRARY INTEGRATION[/b]

Artemis Volatility Bands PRO imports the published KernelLens library and uses the following exports:

| Library Export | Used For |
|---|---|
| `kl.estimate()` | Unified dispatcher — routes to the correct kernel based on the user's Kernel Type dropdown. Called once per bar to produce the Basis line. |
| `kl.confidenceBand()` | Rolling residual standard deviation — computes σ of (source − basis) over the specified window. |
| `kl.trendState()` | Ternary trend detector — returns +1 (rising), 0 (flat), or −1 (falling) based on a 1-bar finite difference of the Basis. |

Every regression computation — kernel weight evaluation, NA-safe summation, bandwidth-aware loop termination — is delegated to the library. The indicator itself contains zero kernel math; it only orchestrates three library calls and aggregates their outputs into the band envelope and signal logic.


[b]🟦 KERNEL REGRESSION & RESIDUAL VOLATILITY[/b]

**The Basis line** — A non-parametric kernel regression anchored to the user's choice of price source (default: close; also supports hl2, ohlc4, custom). Eight kernel families available:

| Kernel | Behavior | Best For |
|---|---|---|
| Rational Quadratic | Multi-scale mixer; α controls stretch | Default, balanced responsiveness |
| Gaussian / RBF | Canonical smoother, infinitely differentiable | Smooth trend, minimize noise |
| Periodic | Resonates with a known repetition distance p | Cyclic markets, seasonal patterns |
| Locally Periodic | Periodic × gaussian blend | Seasonal + trend drift |
| Epanechnikov | MSE-optimal, compact support | Minimal tail contamination |
| Tricube | LOWESS standard, near-Gaussian profile | Fast computation, robust |
| Triangular | Simplest compact kernel | Lightweight, real-time responsiveness |
| Cosine | Raised-cosine, smooth boundary transition | Smooth rolloff, professional appearance |

Three filter modes applied on top of the raw kernel estimate:

| Filter | Description | Use Case |
|---|---|---|
| No Filter | Single-pass Nadaraya–Watson | Rawest output, maximum responsiveness |
| Smooth | Double-pass: kernel applied to its own output | Cleaner, slightly more lag |
| Zero Lag | Ehlers de-lagging: 2·raw − smooth | Sharpens edges without increasing lag |

**Residual volatility** — Once the Basis is computed, the per-bar residual is (source − basis). The residual standard deviation is the rolling σ of this residual over a configurable window (default: 14 bars). This is the model-consistent volatility estimate — price deviations are measured relative to the kernel Basis, guaranteeing alignment between trend and volatility.

**Band levels** — upper = basis + k · σ and lower = basis − k · σ, where k is the Band Multiplier (default: 2.0, Bollinger-style). The multiplier is user-adjustable from 0.5 (tight) to 5.0 (wide).


[b]🟦 SIGNAL ENGINE[/b]

Artemis fires Long / Short signals when price breaks the Basis with a confirming slope direction:

Long  → close > basis AND basis rising
Short → close < basis AND basis falling

The signal state is persistent — once a direction flips, it remains latched until the opposite condition fires. This state machine (vii ∈ {−1, 0, +1}) ensures the Basis hue stays coherent across bars even when the raw trigger is a single-bar event.

Signal markers fire ONLY on the bar the state flips, not on every bar that satisfies the raw condition. This keeps the chart uncluttered and mirrors how discretionary traders consume trend-flip information.

**Signal Mode** — Two gating options:

| Mode | Behavior | Repaint |
|---|---|---|
| Confirmed | Signals fire ONLY after the bar closes via `barstate.isconfirmed` | Zero repaint, fully reliable for live trading |
| Realtime | Signals fire on the current (open) bar as soon as the condition is met | Fastest reaction; signal may vanish if price reverses before bar closes |

Historical repainting never occurs at any Signal Mode value. The library's `_phase` parameter shifts every kernel center into the past by that many bars, so historical bars' plotted values are final once confirmed.


[b]🟦 6-LAYER NEON HALO VISUALIZATION[/b]

The interior between the Basis and each outer band is filled with a 6-layer gradient: 5 interior step plots plus the outer band, creating a stepped transparency schedule that mirrors the statistical density of price residuals under normality.

**Transparency schedule:**

| Layer | Transparency | Meaning |
|---|---|---|
| Outer band ↔ 1st interior | 70 % | Densest layer |
| 1st ↔ 2nd | 78 % | |
| 2nd ↔ 3rd | 85 % | |
| 3rd ↔ 4th | 90 % | |
| 4th ↔ 5th | 95 % | |
| 5th ↔ Basis | 98 % | Nearly invisible fade to centerline |

Every transparency value is scaled by the Gradient Intensity input (0–100 %), so the user can dial the visual density from invisible (0) to heavy fills (100).

**Color assignment:**

- Upper band + gradient: Bearish theme hue (short signal color)
- Lower band + gradient: Bullish theme hue (long signal color)
- Basis line: Slope-adaptive color (thBull when rising, thBear when falling, previous color on flat bars)

**Signal markers** — Two-layer neon glow plotshapes:
- Halo: size.small, 40 % opaque theme hue (glow layer)
- Core: size.tiny, 100 % opaque theme hue (bright center)


[b]🟦 THEME SYSTEM[/b]

Twelve cohesive color palettes tuned to every trading aesthetic. One selection drives every visual component — Basis line, outer bands, gradient halos, long / short signal markers, dashboard accents — all sharing the same bull / bear / neutral color axes:

| Theme | Bull | Bear | Usage |
|---|---|---|---|
| Tropic | Cyan steel | Deep orange | Default, electric contrast |
| Amber | Warm amber | Indigo blue | Fire tones |
| Pastel | Sky blue | Soft lavender | Cool arctic glow |
| Cyber | Neon lime | Hot crimson | Cyber terminal aesthetic |
| Helios | Bright gold | Scarlet | Solar warmth |
| Electric | Electric aqua | Magenta | High-voltage neon |
| Candy | Neon green | Hot pink | Dark energy pop |
| Bloomberg | Terminal orange | Cyan | Wall Street finance heritage (PRO) |
| Solar | Solarized olive | Crimson | Developer palette, easy on eyes (PRO) |
| Royal | Imperial gold | Deep purple | Luxury signature (PRO) |
| Midnight | Deep navy | Dark crimson | Dark depth |
| Graphite | Near-black | Silver grey | Monochrome minimal |

**Dashboard display modes** — Dark (black background, bright accents) or Light (white background, darker accents), auto-adapting visual contrast regardless of chart background.


[b]🟦 DASHBOARD[/b]

A 2-column, 9-row theme-aware status panel that updates only on the last bar (zero historical overhead). Supports Dark and Light display modes, six docking positions, and four text sizes. Renders via `force_overlay = true` on the main price chart.

| Row | Label | Content |
|---|---|---|
| Header | ARTEMIS PRO | DARK / LIGHT |
| Theme | Theme | Active palette name |
| Divider | KERNEL | — |
| Type | Type | Selected kernel type |
| Bandwidth ℓ | Bandwidth ℓ | Primary bandwidth + Phase φ |
| Basis | Basis | Current Basis value in chart mintick format |
| Divider | VOLATILITY | — |
| Residual σ | Residual σ | Current residual standard deviation |
| Signal | Signal | ▲ LONG / ▼ SHORT / ━ FLAT (direction-colored) |


[b]🟦 ALERT CONDITIONS[/b]

Four opt-in alert conditions, each gated by its own toggle:

| Alert | Fires When |
|---|---|
| Long Signal | Price breaks above the Basis with a rising slope (confirmed state flip) |
| Short Signal | Price breaks below the Basis with a falling slope (confirmed state flip) |
| Upper Band Touch | Price touches or exceeds the upper outer band (raw crossover) |
| Lower Band Touch | Price touches or falls below the lower outer band (raw crossunder) |

Band touch alerts are useful as pre-signal early warnings in trending markets. Signal alerts are gated by the Signal Mode setting, so Confirmed mode ensures zero-repaint alerts suitable for live trading.

All alerts use `alertcondition()` for maximum compatibility with TradingView's alert system including webhooks. Messages are structured as `"Artemis Volatility Bands: <event description>"` for easy parsing in downstream automation.


[b]🟦 RECOMMENDED PRESETS[/b]

| Trading Style | Bandwidth ℓ | Filter | Residual σ Window | Phase |
|---|---|---|---|---|
| Scalper | 10–20 | No Filter | 8–10 | 1 |
| Day Trader | 20–40 | Smooth | 14 | 2 |
| Swing | 30–60 | Smooth | 20–40 | 2 |
| Position | 60–120 | Smooth | 40–60 | 3 |

**Bandwidth tuning** — Smaller ℓ produces a tighter fit to price and faster reaction; larger ℓ produces smoother curves and more stability. Experiment with ℓ in your preferred style's range, then adjust the Residual σ Window and Filter mode for visual smoothness.

**Phase tuning** — Phase = 0 is live (flickers on the current bar); Phase = 2 is the recommended balance; Phase = 3+ adds margin against noise at the cost of lag. Historical charts are immutable at any phase value.


[b]🟦 KERNEL-ONLY DESIGN PHILOSOPHY[/b]

Artemis Volatility Bands PRO contains zero classical technical analysis bolt-ons. No Bollinger Bands, no Keltner Channels, no linear regression, no ATR, no moving averages — only kernel regression and residual volatility. This kernel-only architecture guarantees that:

1. **Internal consistency** — The Basis and band width emerge from a single statistical model, not from mixing independent techniques.
2. **Unified parameterization** — All visual outputs (Basis, bands, gradient) are controlled by a single set of kernel-theoretic parameters.
3. **No analytical compromise** — Every choice in the indicator is mathematically motivated; no ad-hoc decorations.

The philosophy is defensive: traders who layer Artemis on top of their own edge strategies get a pure kernel-regression envelope that will not conflict with classical-TA signals already in use. Traders seeking a standalone kernel-based indicator get a complete, coherent system.


[b]🟦 COMPATIBILITY[/b]

- Pine Script v6
- All exchanges, all asset classes (crypto, forex, equities, commodities, indices)
- All timeframes (1 minute through Monthly)
- Both Dark and Light chart themes — visual elements auto-adapt to chart background
- No exchange-specific logic — fully deterministic

Indicator renders on the main overlay chart with `force_overlay = true`. No secondary panes, no subplot logic.


[b]🟦 TECHNICAL NOTES[/b]

- **Library dependency** — `import a_jabbaroff/KernelLens/1` — all kernel regression math is delegated to the published library
- **Plot budget** — 2 outer bands + 10 gradient interior plots + 1 Basis + 1 transparent anchor + 4 signal shapes + 12 fills + 4 alertconditions = 34 outputs, well under Pine's 64-output hard limit (50 % margin)
- **Table** — Single `var table` created once on `barstate.islast` with `force_overlay = true`; dashboard renders on the main chart pane, zero historical overhead
- **No persistent drawing objects** — no `box.new`, `line.new`, no `array.new`; all visuals are plots and fills
- **Opacity convention** — every user-facing opacity / transparency input follows `0 = invisible, 100 = fully opaque`; conversion to Pine's native transparency is centralized in a single helper function (`f_opac`)
- **Non-repainting** — inherits from the library's `_phase` parameter; no `request.security`, no lookahead, no future-bar leakage at any phase value
- **Residual consistency** — The residual σ is computed as `ta.stdev(source − basis, window)`, ensuring the band width always measures deviation relative to the kernel Basis


[b]🟦 DISCLAIMER[/b]

Artemis Volatility Bands PRO is a technical analysis indicator built on the KernelLens Nadaraya–Watson regression library. It is provided solely for educational and research purposes and does not constitute financial, investment, or trading advice.

Kernel regression is a local smoothing technique. It estimates the mean of a source series in the neighborhood of the current bar based on historical data, but it does not predict future prices, does not generate trading signals on its own, and does not guarantee the profitability of any strategy built on top of its output. The signal engine is a mechanical detector of basis breaks and slope direction — not a forecast — and should always be combined with broader context: higher-timeframe structure, volatility regime, liquidity, news, and risk management.

Past performance of any model does not guarantee future results. Markets contain systemic risks that cannot be eliminated by any amount of mathematical rigor. Responsibility for any trading decisions rests entirely with the user. Always apply sound capital management, conduct your own independent analysis, and never risk capital you are not prepared to lose.

The author assumes no liability for direct or indirect losses incurred through the use of Artemis Volatility Bands PRO or the underlying KernelLens library.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Artemis Volatility Bands PRO — Layered Gradient Volatility Envelope
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
//  Version     : 1.0.0
//  PineScript  : v6 (PRO)
//  Library     : import a_jabbaroff/KernelLens/1
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Artemis Volatility Bands PRO is a price-overlay volatility indicator that fuses
//  the statistical rigor of the KernelLens Nadaraya–Watson regression library
//  with a professional layered gradient visualization.  A single kernel estimate — selectable from eight
//  classical kernel families (Rational Quadratic, Gaussian, Periodic,
//  Locally Periodic, Epanechnikov, Tricube, Triangular, Cosine) — anchors
//  the Basis line.  Around it, two outer bands fan outward by a fixed
//  multiple of the residual standard deviation, and the interior is washed
//  with progressively transparent fills that taper from the outer edge
//  back toward the Basis — producing a neon halo whose density mirrors the
//  statistical density of price residuals under normality.
//
//  A signal engine prints long / short triggers when price breaks the
//  Basis with a confirming slope direction, guarded by Confirmed /
//  Realtime mode.  Twelve cohesive color themes, a theme-aware Dark /
//  Light dashboard, and four opt-in alert conditions round out the
//  indicator.
//
// ─── Core Engines ────────────────────────────────────────────────────────────
//
//   Kernel Engine     — kl.estimate() with 8 kernel families × 3 filter modes
//   Volatility Engine — kl.confidenceBand() residual σ (model-consistent)
//   Gradient Render   — 6-layer neon halo fill on each side
//   Theme Palette     — 12 cohesive color palettes with theme-aware rendering
//   Dashboard         — 9-row theme-aware panel (Dark / Light display modes)
//
// ─── Design Philosophy ───────────────────────────────────────────────────────
//
//  Classical Bollinger-style bands pair one moving-average basis with a
//  second, independent close-stdev measurement — the smoother and the
//  volatility estimate live in different statistical universes.  Artemis
//  collapses that duality: the Basis line is a non-parametric kernel
//  regression, and the band half-width is the rolling σ of the residuals
//  (price − kernel estimate).  Basis and volatility emerge from a single
//  estimator pass, so the envelope is internally consistent by construction —
//  kernel-only, no classical-TA bolt-ons.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Artemis Volatility Bands PRO", "AVB PRO", overlay = true, max_bars_back = 5000, max_labels_count = 500)

import a_jabbaroff/KernelLens/1 as kl


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_SRC    = "Source 🔹"
const string GRP_THEME  = "Theme 🔹"
const string GRP_KRN    = "Kernel Engine 🔹"
const string GRP_VOL    = "Volatility Engine 🔹"
const string GRP_SIG    = "Signal System 🔹"
const string GRP_VIS    = "Visual Style 🔹"
const string GRP_DASH   = "Dashboard 🔹"
const string GRP_ALERT  = "Alerts 🔹"

// Kernel type dropdown options — must match KernelLens library constants exactly
const string KRN_RQ    = "Rational Quadratic"
const string KRN_GAUSS = "Gaussian"
const string KRN_PER   = "Periodic"
const string KRN_LP    = "Locally Periodic"
const string KRN_EPA   = "Epanechnikov"
const string KRN_TRI   = "Tricube"
const string KRN_TRG   = "Triangular"
const string KRN_COS   = "Cosine"

// Filter mode options — must match KernelLens library constants exactly
const string FLT_NONE = "No Filter"
const string FLT_SM   = "Smooth"
const string FLT_ZL   = "Zero Lag"

// Signal evaluation mode — Confirmed waits for bar close, Realtime fires live
const string SIG_CONF = "Confirmed"
const string SIG_LIVE = "Realtime"


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Source ──────────────────────────────────────────────────────────────────
src = input.source(close, "Kernel Source", group = GRP_SRC,
     tooltip = "Price series fed to the kernel regression engine.  Typical choices: close, hl2, ohlc4.\n\nThis source anchors the Basis line and drives every downstream calculation: residual σ bands, signal state, and dashboard readouts.\n\nDefault: close")


// ─── Theme ───────────────────────────────────────────────────────────────────
themeChoice = input.string("Tropic", "Theme",
     options = ["Tropic", "Amber", "Pastel", "Cyber", "Helios", "Electric", "Candy", "Bloomberg", "Solar", "Royal", "Midnight", "Graphite"],
     group   = GRP_THEME,
     tooltip = "Applies a complete color palette across every visual component — Basis line, outer bands, gradient halos, long / short signal markers, and dashboard accents.\n\nTropic — Cyan steel + deep orange (electric contrast — default)\n\nAmber — Warm amber + indigo blue (fire tones)\n\nPastel — Sky blue + soft lavender (cool arctic glow)\n\nCyber — Neon lime + hot crimson (cyber terminal)\n\nHelios — Bright gold + scarlet (solar warmth)\n\nElectric — Electric aqua + magenta (high-voltage neon)\n\nCandy — Neon green + hot pink (dark energy pop)\n\nBloomberg — Terminal orange + cyan (Wall Street finance heritage — PRO)\n\nSolar — Solarized olive + crimson (developer palette, easy on the eyes — PRO)\n\nRoyal — Imperial gold + deep purple (luxury signature — PRO)\n\nMidnight — Deep navy + dark crimson (dark depth)\n\nGraphite — Near-black + silver grey (monochrome minimal)")


// ─── Signal System ───────────────────────────────────────────────────────────
showSignals = input.bool(true, "Show Long / Short Signals", group = GRP_SIG,
     tooltip = "Master toggle for the Long (▲) and Short (▼) signal markers.\n\nSignals fire when price breaks the Basis with a confirming slope direction:\n  Long  — close > basis AND basis rising\n  Short — close < basis AND basis falling\n\nThe signal state flips persistently, so the Basis line and (optionally) the bars paint the active direction until the opposite condition fires.\n\nDefault: ON")

signalMode = input.string(SIG_CONF, "Signal Mode",
     options = [SIG_CONF, SIG_LIVE],
     group   = GRP_SIG,
     tooltip = "Controls when Long / Short signals fire.\n\nConfirmed — signals fire ONLY after the bar closes.  The marker will never disappear once plotted.  Zero repaint, fully reliable.  Recommended for live trading.\n\nRealtime  — signals fire on the current (open) bar as soon as the condition is met.  Fastest reaction, but the signal may vanish if price reverses before the bar closes.\n\nDefault: Confirmed")


// ─── Kernel Engine ───────────────────────────────────────────────────────────
kType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_KRN,
     tooltip = "Kernel family used for the Nadaraya–Watson regression that builds the Basis line.\n\nRational Quadratic — multi-scale mixer, α controls stretch (recommended default)\nGaussian / RBF — canonical smoother, infinitely differentiable\nPeriodic — resonates with a known repetition distance p\nLocally Periodic — periodic × gaussian (seasonal + trend drift)\nEpanechnikov — MSE-optimal, compact support (no tail contamination)\nTricube — LOWESS standard, near-Gaussian compact profile\nTriangular — simplest compact kernel, cheapest to compute\nCosine — raised-cosine, smooth boundary transition\n\nDefault: Rational Quadratic")

kBw = input.int(20, "Bandwidth ℓ", minval = 2, step = 1, group = GRP_KRN,
     tooltip = "Kernel scale ℓ in bars — controls the smoothness / reactivity trade-off.\n\nSmaller ℓ — tighter fit to price, more reactive, noisier Basis\nLarger ℓ — smoother curve, more stable, slower response\n\nRecommended ranges by trading style:\nScalper    — 10–20 bars\nDay trader — 20–40 bars\nSwing      — 30–60 bars\nPosition   — 60–120 bars\n\nDefault: 20")

kAlpha = input.float(1.0, "Shape α (RQ only)", minval = 0.01, step = 0.25, group = GRP_KRN,
     tooltip = "Rational Quadratic shape parameter α.  Ignored by other kernels.\n\nα → ∞   — collapses to pure Gaussian\nα → 0⁺  — stretches the curve over longer length scales\nα = 1   — balanced default (equal multi-scale weight)\nα = 2–5 — moderate long-range emphasis\nα > 10  — heavy long-range smoothing\n\nDefault: 1.0")

kPeriod = input.int(20, "Period (P / LP)", minval = 1, group = GRP_KRN,
     tooltip = "Repetition distance p in bars.  Used only by Periodic and Locally Periodic kernels.\n\nTypical values:\n20 — intraday / daily cycle\n52 — weekly cycle\n60 — 1-hour cycle on 1m chart\n\nIgnored by the other six kernel families.\n\nDefault: 20")

kPhase = input.int(2, "Phase", minval = 0, group = GRP_KRN,
     tooltip = "Non-repainting offset — the kernel center is shifted by this many bars into the past.\n\n0 — live estimate, flickers on the current bar\n1 — 1-bar lag, non-repainting once confirmed\n2 — recommended balance (default)\n3+ — extra margin against erratic ticks, higher lag\n\nHistorical plots are immutable at every phase value.\n\nDefault: 2")

kFilter = input.string(FLT_SM, "Filter",
     options = [FLT_NONE, FLT_SM, FLT_ZL],
     group   = GRP_KRN,
     tooltip = "Filter layer applied on top of the raw kernel estimate.\n\nNo Filter — single-pass Nadaraya–Watson (rawest output)\nSmooth   — double-pass: kernel applied to its own output (cleaner, slightly more lag)\nZero Lag — Ehlers de-lagging: 2·raw − smooth (sharpens edges without increasing lag)\n\nDefault: Smooth")


// ─── Volatility Engine ───────────────────────────────────────────────────────
volWin = input.int(14, "Residual σ Window", minval = 5, maxval = 100, group = GRP_VOL,
     tooltip = "Lookback window for the rolling residual standard deviation — i.e. σ of (source − basis).\n\nShorter → more reactive bands, tighter in calm markets, wider in fast volatility\nLonger  → more stable bands, insensitive to short-term volatility bursts\n\n8–10  — reactive / scalping\n14    — balanced (default)\n20–40 — position / swing\n\nThe residual σ is the model-consistent volatility estimate — price deviations are measured relative to the kernel Basis, not a disconnected MA.\n\nDefault: 14")

volMult = input.float(2.0, "Band Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_VOL,
     tooltip = "Multiplier k applied to the residual σ to size the bands.\n\nupper = basis + k · σ\nlower = basis − k · σ\n\n1.0 — tight envelope, frequent touches, sensitive to micro-reversions\n2.0 — balanced Bollinger-style default\n3.0 — wide envelope, reserved for extreme excursions\n\nDefault: 2.0")


// ─── Visual Style ────────────────────────────────────────────────────────────
basisWidth = input.int(2, "Basis Width", minval = 1, maxval = 5, group = GRP_VIS,
     tooltip = "Thickness of the Basis regression line.\n\n1 — hairline, precision view\n2 — balanced (default)\n3–5 — thick, high-visibility\n\nDefault: 2")

bandWidth = input.int(1, "Outer Band Width", minval = 1, maxval = 4, group = GRP_VIS,
     tooltip = "Thickness of the upper / lower outer band outlines.\n\n1 — hairline (default, cleanest for gradient fills)\n2 — medium\n3–4 — thick\n\nDefault: 1")

gradIntensity = input.int(70, "Gradient Intensity", minval = 0, maxval = 100, group = GRP_VIS,
     tooltip = "Opacity scaler for the layered gradient halo between Basis and each outer band.\n\n0   — fills invisible, only outlines remain\n70  — balanced neon halo (default)\n100 — heavy fills, strong visual weight\n\nThe gradient tapers from the outer band (densest layer) back toward the Basis (lightest layer), mirroring the statistical density of price residuals under normality.  Intuitive scale: higher number = more visible.")


// ─── Dashboard ───────────────────────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Compact 2-column live status panel.  Updates only on the last bar — zero historical overhead.\n\nShows at a glance: Theme, Kernel, Bandwidth, Basis, Residual σ, and Signal state.")

displayMode = input.string("Dark", "Display Mode",
     options = ["Dark", "Light"],
     group = GRP_DASH,
     tooltip = "Dark — black dashboard background, bright accents (default for dark charts).\nLight — white dashboard background, darker accents (use on light charts).")

dashPos = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_DASH,
     tooltip = "Where the dashboard panel docks on the chart.\n\nTop Right — default, clear of most indicators\nTop Left  — good for right-anchored charts\nMiddle Right / Left — centered vertically\nBottom Right / Left — tucked below price action")

dashSize = input.string("Small", "Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DASH,
     tooltip = "Dashboard text size.\n\nTiny   — minimal footprint, hard to read on 4K monitors\nSmall  — default, clean and readable\nNormal — larger cells, easier at a glance\nLarge  — maximum readability, biggest footprint")


// ─── Alerts ──────────────────────────────────────────────────────────────────
alertLong = input.bool(true, "Long Signal", group = GRP_ALERT,
     tooltip = "Fires when a confirmed Long signal prints — close breaks above the Basis with a rising slope.")

alertShort = input.bool(true, "Short Signal", group = GRP_ALERT,
     tooltip = "Fires when a confirmed Short signal prints — close breaks below the Basis with a falling slope.")

alertTouchUp = input.bool(false, "Upper Band Touch", group = GRP_ALERT,
     tooltip = "Fires whenever price touches or exceeds the upper outer band.  Raw touch alert — useful as a pre-signal early warning.\n\nDefault: OFF (can be noisy in trending markets)")

alertTouchDn = input.bool(false, "Lower Band Touch", group = GRP_ALERT,
     tooltip = "Fires whenever price touches or falls below the lower outer band.  Raw touch alert — useful as a pre-signal early warning.\n\nDefault: OFF (can be noisy in trending markets)")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (12 cohesive color palettes)
// ═══════════════════════════════════════════════════════════════════════════════
// Each theme defines four axis colors:
//   thBull    — bullish side  (positive slope, lower band fill, long signal)
//   thBear    — bearish side  (negative slope, upper band fill, short signal)
//   thNeutral — desaturated mid tone (dashboard foreground accents)
//   thSignal  — pastel tint of thBull (dashboard header on dark themes)

color thBull = switch themeChoice
    "Tropic"    => #00bcd4
    "Amber"     => #ff9800
    "Pastel"    => #4fc3f7
    "Cyber"     => #00e676
    "Helios"    => #ffd600
    "Electric"  => #00e5ff
    "Candy"     => #69F0AE
    "Bloomberg" => #00b0ff
    "Solar"     => #859900
    "Royal"     => #ffd700
    "Midnight"  => #0d47a1
    "Graphite"  => #1a1a1a
    =>             #00bcd4

color thBear = switch themeChoice
    "Tropic"    => #ff6d00
    "Amber"     => #e53935
    "Pastel"    => #9575cd
    "Cyber"     => #ff1744
    "Helios"    => #ef5350
    "Electric"  => #e040fb
    "Candy"     => #FF4081
    "Bloomberg" => #ff8c00
    "Solar"     => #dc322f
    "Royal"     => #6a0dad
    "Midnight"  => #b71c1c
    "Graphite"  => #757575
    =>             #ff6d00

color thNeutral = switch themeChoice
    "Tropic"    => #607d8b
    "Amber"     => #7986cb
    "Pastel"    => #b0bec5
    "Cyber"     => #757575
    "Helios"    => #9e9e9e
    "Electric"  => #546e7a
    "Candy"     => #455A64
    "Bloomberg" => #5a5a5a
    "Solar"     => #586e75
    "Royal"     => #4a4458
    "Midnight"  => #546e7a
    "Graphite"  => #9e9e9e
    =>             #607d8b

color thSignal = switch themeChoice
    "Tropic"    => #80DEEA
    "Amber"     => #FFCC80
    "Pastel"    => #B3E5FC
    "Cyber"     => #B9F6CA
    "Helios"    => #FFF59D
    "Electric"  => #84FFFF
    "Candy"     => #CCFF90
    "Bloomberg" => #FFD180
    "Solar"     => #B5CB00
    "Royal"     => #FFE680
    "Midnight"  => #90CAF9
    "Graphite"  => #BDBDBD
    =>             #80DEEA


// ─── Opacity helper ──────────────────────────────────────────────────────────
// Every opacity value in this script follows the intuitive convention:
//   0   = invisible (fully transparent)
//   100 = fully opaque
// Pine's native color.new() takes the inverse (transparency).  This helper
// performs the conversion once per call site, keeping the rest of the script
// readable in pure opacity semantics.

f_opac(color _base, int _opacity) =>
    color.new(_base, 100 - _opacity)


// ─── Dashboard theme colors (Dark / Light resolver) ──────────────────────────

color dashBg      = displayMode == "Dark" ? #0A0A0A : #FFFFFF
color dashBgAlt   = displayMode == "Dark" ? #141414 : #F5F5F5
color dashFg      = displayMode == "Dark" ? #E0E0E0 : #1A1A1A
color dashBorder  = displayMode == "Dark" ? #2A2A2A : #DCDCDC
color dashHeader  = f_opac(thBull, 100)
color dashSection = displayMode == "Dark" ? #1A1A1A : #EEEEEE


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 3   —   KERNEL ENGINE & RESIDUAL VOLATILITY
// ═══════════════════════════════════════════════════════════════════════════════
// Single kernel pass anchors the Basis line.  The library's confidenceBand
// helper wraps ta.stdev(src − estimate, window) with input validation and
// returns the residual standard deviation used as the per-σ band half-width.
//
// Library call signature reference:
//   kl.estimate(_kernelType, _src, _bandwidth, _shapeAlpha, _period, _phase, _filter)
//   kl.confidenceBand(_src, _estimate, _window)  →  rolling σ of residual
//   kl.trendState(_estimate, _step)              →  +1 / 0 / −1 ternary state

// ─── Basis line (the regression anchor) ──────────────────────────────────────
float basis = kl.estimate(kType, src, kBw, kAlpha, kPeriod, kPhase, kFilter)

// ─── Residual standard deviation (per-σ band half-width) ─────────────────────
float sigma = kl.confidenceBand(src, basis, volWin)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   BAND LEVELS
// ═══════════════════════════════════════════════════════════════════════════════
// Outer bands sit at basis ± volMult · σ.  The five intermediate step levels
// used by the gradient render are computed as linear interpolations between
// the basis and each outer band (see SECTION 6 — Plots below).

float dev = volMult * sigma
float upper = basis + dev
float lower = basis - dev


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   SIGNAL ENGINE   (Basis-break with slope confirmation)
// ═══════════════════════════════════════════════════════════════════════════════
// Long  — close > basis AND basis rising
// Short — close < basis AND basis falling
//
// State tracking uses a persistent variable (vii) so the active direction
// remains latched until the opposite condition fires.  This keeps the
// slope-adaptive Basis hue coherent across bars even when the raw trigger
// is a single-bar event.

// Trend state of the Basis line (1-bar finite difference, ternary result)
int trendSt = kl.trendState(basis, 1)

// Signal Mode gate — Confirmed waits for bar close, Realtime fires live
bool confirmGate = signalMode == SIG_CONF ? barstate.isconfirmed : true

bool rawLong  = close > basis and trendSt ==  1
bool rawShort = close < basis and trendSt == -1

// Persistent direction state:  +1 long, −1 short, 0 undecided.
// The state latches until the opposite raw trigger fires, so the Basis
// hue stays coherent across bars.
var int vii = 0
int  viiPrev = vii
vii := rawLong  and not rawShort ? 1
     : rawShort                  ? -1
     : vii

// Signal markers fire ONLY on the bar the state flips — not on every bar
// that satisfies the raw condition.  This keeps the chart uncluttered and
// mirrors how discretionary traders consume trend-flip information.
bool longFlip  = vii ==  1 and viiPrev !=  1
bool shortFlip = vii == -1 and viiPrev != -1

bool longFire  = showSignals and longFlip  and confirmGate
bool shortFire = showSignals and shortFlip and confirmGate

// Outer-band touch events — raw (fires regardless of Signal Mode / visibility)
bool touchUp = ta.crossover (high, upper)
bool touchDn = ta.crossunder(low,  lower)

// Slope-adaptive line colors.  Flat bars retain the previous color so the
// Basis line never flashes neutral on a zero-slope tick.
var color slopeColor = thNeutral
slopeColor := vii ==  1 ? thBull :
              vii == -1 ? thBear :
                          slopeColor


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   PLOTS   (6-layer gradient + outer bands + basis + signals)
// ═══════════════════════════════════════════════════════════════════════════════
// Z-order (Pine renders in declaration order, later = on top):
//   1. Outer band outlines
//   2. Six-layer gradient plots + fills (upper side, then lower side)
//   3. Basis line (on top of the fills, below signal markers)
//   4. Long / Short signal shapes
//
// Plot-count budget: Pine Script v6 caps a script at 64 total outputs.
// A full 10-layer gradient on both sides together with dual-layer signal
// markers and alerts would exceed that cap, so we render the halo with
// 5 interior step layers + outer band = 6 visible levels per side.
// This delivers a professional layered aesthetic within the resource budget.
//
// The transparency of each fill widens monotonically from the outermost
// pair (densest layer) toward the innermost pair (nearly invisible),
// producing a neon halo that mirrors the statistical density of price
// residuals under normality.  gradIntensity scales every layer uniformly.

// ─── Outer band plot handles ─────────────────────────────────────────────────
// These double as anchors for the outermost gradient fills.
plot_upper = plot(upper, "Upper Band", color = f_opac(thBear, 80), linewidth = bandWidth)
plot_lower = plot(lower, "Lower Band", color = f_opac(thBull, 80), linewidth = bandWidth)

// ─── Step heights for the six-layer decomposition ────────────────────────────
// Distance from the basis to each outer band is divided into six equal
// fractions.  The band lives at fraction 6/6, the five interior step plots
// sit at 5/6 … 1/6, and the basis anchor closes the gradient at 0/6.
float upperStep = (upper - basis) / 6.0
float lowerStep = (basis - lower) / 6.0

// ─── Per-layer transparency schedule ─────────────────────────────────────────
// Pine's transparency convention: 0 opaque, 100 invisible.  f_fillT maps a
// "natural" transparency (at gradIntensity = 100) onto the user's chosen
// intensity.  The schedule below samples the AVB curve at five points —
// denser near the outer band, rapidly fading toward the basis.

f_fillT(int _naturalT) =>
    int delta = 100 - _naturalT
    int scaled = math.round(delta * gradIntensity / 100.0)
    100 - scaled

int t1    = f_fillT(70)    // outer band ↔ 1st interior step
int t2    = f_fillT(78)    // 1st ↔ 2nd
int t3    = f_fillT(85)    // 2nd ↔ 3rd
int t4    = f_fillT(90)    // 3rd ↔ 4th
int t5    = f_fillT(95)    // 4th ↔ 5th
int tCore = f_fillT(98)    // 5th ↔ basis

// ─── Upper gradient — five interior steps ────────────────────────────────────
uGrad2 = plot(upper - upperStep * 1, "UG2", color = color.new(thBear, t1), style = plot.style_line, linewidth = 1)
fill(plot_upper, uGrad2, color.new(thBear, t1))

uGrad3 = plot(upper - upperStep * 2, "UG3", color = color.new(thBear, t2), style = plot.style_line, linewidth = 1)
fill(uGrad2, uGrad3, color.new(thBear, t2))

uGrad4 = plot(upper - upperStep * 3, "UG4", color = color.new(thBear, t3), style = plot.style_line, linewidth = 1)
fill(uGrad3, uGrad4, color.new(thBear, t3))

uGrad5 = plot(upper - upperStep * 4, "UG5", color = color.new(thBear, t4), style = plot.style_line, linewidth = 1)
fill(uGrad4, uGrad5, color.new(thBear, t4))

uGrad6 = plot(upper - upperStep * 5, "UG6", color = color.new(thBear, t5), style = plot.style_line, linewidth = 1)
fill(uGrad5, uGrad6, color.new(thBear, t5))

// ─── Basis anchor (declared here so both sides can fill against it) ──────────
// Rendered transparent; the visible colored Basis is re-plotted below at
// higher z-order so it sits on top of every gradient fill.
pBasis = plot(basis, "Basis Anchor", color = na, display = display.none, editable = false)

// Final upper fill — from the fifth step back to the Basis (lightest layer).
fill(uGrad6, pBasis, color.new(thBear, tCore))

// ─── Lower gradient — five interior steps ────────────────────────────────────
lGrad2 = plot(lower + lowerStep * 1, "LG2", color = color.new(thBull, t1), style = plot.style_line, linewidth = 1)
fill(plot_lower, lGrad2, color.new(thBull, t1))

lGrad3 = plot(lower + lowerStep * 2, "LG3", color = color.new(thBull, t2), style = plot.style_line, linewidth = 1)
fill(lGrad2, lGrad3, color.new(thBull, t2))

lGrad4 = plot(lower + lowerStep * 3, "LG4", color = color.new(thBull, t3), style = plot.style_line, linewidth = 1)
fill(lGrad3, lGrad4, color.new(thBull, t3))

lGrad5 = plot(lower + lowerStep * 4, "LG5", color = color.new(thBull, t4), style = plot.style_line, linewidth = 1)
fill(lGrad4, lGrad5, color.new(thBull, t4))

lGrad6 = plot(lower + lowerStep * 5, "LG6", color = color.new(thBull, t5), style = plot.style_line, linewidth = 1)
fill(lGrad5, lGrad6, color.new(thBull, t5))

// Final lower fill — from the fifth step back to the Basis (lightest layer).
fill(lGrad6, pBasis, color.new(thBull, tCore))

// ─── Basis line — slope-adaptive color ───────────────────────────────────────
// Re-plotted after all fills so the visible line sits on top of every halo.
plot(basis, "Basis", color = slopeColor, linewidth = basisWidth)

// ─── Long / Short signal markers (two-layer neon glow) ───────────────────────
// Each signal prints two plotshapes at the same absolute price:
//   • Halo  — size.small, 40 % transparent theme hue (glow layer)
//   • Core  — size.tiny, fully opaque theme hue      (bright center)
// The halo renders first so the core sits cleanly on top.
float signalOffset = dev * 0.3
float longY  = longFire  ? lower - signalOffset : na
float shortY = shortFire ? upper + signalOffset : na

plotshape(shortY, "Short Halo",
     shape.triangledown, location.absolute,
     color = f_opac(thBear, 40), size = size.small)
plotshape(shortY, "Short Core",
     shape.triangledown, location.absolute,
     color = f_opac(thBear, 100), size = size.tiny)

plotshape(longY, "Long Halo",
     shape.triangleup, location.absolute,
     color = f_opac(thBull, 40), size = size.small)
plotshape(longY, "Long Core",
     shape.triangleup, location.absolute,
     color = f_opac(thBull, 100), size = size.tiny)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 7   —   DASHBOARD   (theme-aware, Dark / Light)
// ═══════════════════════════════════════════════════════════════════════════════
// 9-row compact status panel rendered only on the last bar so historical
// bars carry zero overhead.  Five logical blocks (Header → Config →
// Regression → Volatility → State) separated by section divider rows;
// alternate row backgrounds (dashBg / dashBgAlt) create a zebra stripe that
// improves scan-ability on narrow cells.

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

// ─── Helper — price formatter ────────────────────────────────────────────────
// Wraps str.tostring with a mintick format and an na-safe em-dash fallback
// so dashboard cells never print the string "NaN".
f_fmt(float _v) =>
    na(_v) ? "—" : str.tostring(_v, format.mintick)

// ─── Derived dashboard values ────────────────────────────────────────────────
string signalLbl = vii ==  1 ? "▲ LONG" : vii == -1 ? "▼ SHORT" : "━ FLAT"
color  signalCol = vii ==  1 ? thBull   : vii == -1 ? thBear    : dashFg

var table dash = na

if barstate.islast and showDash
    dash := table.new(posV, 2, 9,
         bgcolor       = dashBg,
         border_color  = dashBorder,
         border_width  = 1,
         frame_color   = dashBorder,
         frame_width   = 2,
         force_overlay = true)

    // ─── Row 0 — Header (brand + display mode) ───
    table.cell(dash, 0, 0, "ARTEMIS PRO",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 0, str.upper(displayMode),
         text_color = dashFg, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 1 — Theme ───
    table.cell(dash, 0, 1, "Theme",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 1, themeChoice,
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 2 — Section divider: KERNEL ───
    table.cell(dash, 0, 2, "KERNEL",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 2, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 3 — Type ───
    table.cell(dash, 0, 3, "Type",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 3, kType,
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 4 — Bandwidth + Phase ───
    table.cell(dash, 0, 4, "Bandwidth ℓ",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(kBw) + "  / φ " + str.tostring(kPhase),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 5 — Basis ───
    table.cell(dash, 0, 5, "Basis",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 5, f_fmt(basis),
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 6 — Section divider: VOLATILITY ───
    table.cell(dash, 0, 6, "VOLATILITY",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 6, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 7 — Residual σ ───
    table.cell(dash, 0, 7, "Residual σ",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 7, f_fmt(sigma),
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 8 — Signal ───
    table.cell(dash, 0, 8, "Signal",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 8, signalLbl,
         text_color = signalCol, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 8   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
// Every alert is opt-in via a matching input toggle.  The showSignals
// visibility gate suppresses signal alerts when the markers are hidden —
// hiding a feature also silences its alerts.

alertcondition(alertLong and longFire,
     title   = "Artemis — Long Signal",
     message = "Artemis Volatility Bands: Long signal — close broke above the Basis with a rising slope.")

alertcondition(alertShort and shortFire,
     title   = "Artemis — Short Signal",
     message = "Artemis Volatility Bands: Short signal — close broke below the Basis with a falling slope.")

alertcondition(alertTouchUp and touchUp,
     title   = "Artemis — Upper Band Touch",
     message = "Artemis Volatility Bands: price touched or exceeded the upper outer band — pre-signal early warning.")

alertcondition(alertTouchDn and touchDn,
     title   = "Artemis — Lower Band Touch",
     message = "Artemis Volatility Bands: price touched or fell below the lower outer band — pre-signal early warning.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````

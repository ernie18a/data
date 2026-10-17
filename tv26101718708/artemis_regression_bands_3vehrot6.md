# Artemis Regression Bands

- url: https://www.tradingview.com/script/3vEHrot6-Artemis-Regression-Bands/
- type: indicator
- pine_id: PUB;d5d78a9fa2cc4ba98353c25f61d95f7b
- version: 1.0

## Description

[b]🟦 Artemis Regression Bands[/b] is a kernel-driven volatility envelope indicator built on the KernelLens Nadaraya–Watson regression library (a_jabbaroff/KernelLens/1). A single kernel estimate — selectable from eight classical kernel families — anchors the Fair Value line. Around it, three residual-standard-deviation bands (±1σ, ±2σ, ±3σ) fan outward with either Linear or Exponential spacing, producing a statistically grounded envelope far cleaner than the classical close-stdev approach used by legacy Bollinger-style indicators. A four-gate Romb signal engine overlays buy / sell diamond markers when price pokes through the outermost enabled σ boundary and reverses back inside.


[b]🟦 HOW IT WORKS[/b]

Artemis calls the KernelLens library's unified dispatcher once per bar to build the Fair Value line, then queries three additional library exports to derive the band widths, slope direction, and residual σ:

```
fair = kl.estimate (type, src, ℓ, α, period, phase, filter)
sigma = kl.confidenceBand(src, fair, window)
slopeVal = kl.slope (fair, 1)
trendSt  = kl.trendState (fair, 1)

dev  = baseMult · sigma
upper1 = fair + 1·dev     lower1 = fair − 1·dev
upper2 = fair + 2·dev     lower2 = fair − 2·dev
upper3 = fair + k3·dev    lower3 = fair − k3·dev      (k3 = 3 Linear | 4 Exp)
```

The library handles all weighted-sum computation, loop-depth selection, NA-safe iteration, division-by-zero guards, and input validation internally. Artemis contains zero kernel math — every bug fix or optimization in the library automatically propagates to this indicator.


[b]🟦 KERNEL LIBRARY INTEGRATION[/b]

Artemis imports the published KernelLens library and uses the following exports:

| Library Export | Used For |
|---|---|
| `kl.estimate()` | Unified dispatcher — routes to the correct kernel based on the user's Kernel Type dropdown. Called once per bar to produce the Fair Value line. |
| `kl.confidenceBand()` | Rolling standard deviation of the (source − Fair Value) residual. Drives the band half-widths on every bar. |
| `kl.slope()` | Discrete first derivative of the Fair Value line. Feeds trend flip alerts. |
| `kl.trendState()` | Ternary classifier (+1 rising / −1 falling / 0 flat) of the Fair Value line. Drives the slope-adaptive color, the kernel trend confluence filter, and the dashboard Trend row. |

Every regression computation — kernel weight evaluation, NA-safe summation, bandwidth-aware loop termination, residual stdev, finite-difference slope — is delegated to the library. The indicator itself only orchestrates the four library calls and layers the visual pipeline on top.


[b]🟦 EIGHT KERNEL FAMILIES[/b]

A single Kernel Type dropdown selects any of the eight kernels shipped with the KernelLens library. Each is a different mathematical smoother with its own statistical character:

| Kernel | Formula | Best For |
|---|---|---|
| Rational Quadratic | (1 + d² / (2·α·ℓ²))^(−α) | Multi-scale mixer; α controls stretch. Recommended default. |
| Gaussian / RBF | exp(−d² / (2·ℓ²)) | Canonical smoother; infinitely differentiable. |
| Periodic | exp(−2·sin²(π·d/p) / ℓ²) | Resonates with a known repetition distance p. |
| Locally Periodic | Periodic × Gaussian | Seasonal patterns with slow trend drift. |
| Epanechnikov | (3/4)·(1 − u²), \|u\| ≤ 1 | MSE-optimal; compact support, no tail contamination. |
| Tricube | (70/81)·(1 − \|u\|³)³, \|u\| ≤ 1 | LOWESS standard; near-Gaussian compact profile. |
| Triangular | (1 − \|u\|), \|u\| ≤ 1 | Simplest compact kernel; cheapest to compute. |
| Cosine | (π/4)·cos(π·u/2), \|u\| ≤ 1 | Raised-cosine; smooth boundary transition. |

Because the dropdown feeds the library's `kl.estimate()` dispatcher directly, every kernel inherits the same three-mode filter layer (No Filter / Smooth / Zero Lag) and the same non-repainting guarantees — there is no special case per kernel in Artemis.


[b]🟦 FILTER LAYER[/b]

A second dropdown applies an optional post-processing layer on top of the raw Nadaraya–Watson estimate:

| Filter | Formula | Trade-off |
|---|---|---|
| No Filter | ŷ = ŷ_raw | Single-pass kernel. Rawest output, most reactive. |
| Smooth | ŷ = K(ŷ_raw) | Double-pass — kernel applied to its own output. Cleaner line, slightly more lag. |
| Zero Lag | ŷ = 2·ŷ_raw − K(ŷ_raw) | Ehlers de-lagging identity — sharpens edges without adding lag. |

The filter is resolved entirely inside `kl.estimate()`, so switching modes incurs no runtime cost beyond the extra kernel pass.


[b]🟦 RESIDUAL-σ BAND ENGINE[/b]

Artemis bands are statistically grounded on the residual standard deviation — not on raw close stdev as in classical Bollinger indicators. The residual is computed as:

```
residual = src − fair
sigma    = ta.stdev(residual, window)      // via kl.confidenceBand()
```

Because Fair Value is already an unbiased local estimate of the source, the residual is a zero-mean noise series and its stdev captures **only the portion of price variance that the kernel could not explain**. This produces three benefits over the classical approach:

1. **Tighter bands in trending regimes** — close-stdev widens during strong trends because the trend itself inflates the variance; residual-σ does not, because the kernel absorbs the trend.
2. **Faster reaction to volatility regime changes** — residual-σ tightens as soon as the kernel fits well, and widens the instant the market breaks out of the kernel's neighborhood.
3. **True statistical interpretation** — under the assumption of locally Gaussian residuals, ±1σ / ±2σ / ±3σ enclose approximately 68 % / 95 % / 99.7 % of near-term price variation. The traditional close-stdev envelope carries no such interpretation.

A dedicated Residual σ Window input controls the lookback; typical values range from 50 (reactive, scalping) to 300 (stable, position trading).


[b]🟦 BAND SPACING MODES[/b]

Two spacing presets shape the outward fan of the three σ bands:

| Mode | Multipliers | Character |
|---|---|---|
| Linear | 1·, 2·, 3· | Classical Bollinger-style uniform steps. Predictable, symmetric. |
| Exponential | 1·, 2·, 4· | Fibonacci-flavored — outer band (4σ) is reserved for genuine blow-off excursions. |

Base Multiplier scales all three bands uniformly (default 1.0). The formula is:

```
band_level = fair ± (baseMult · k · sigma)      k ∈ {1, 2, k3}
```

where k3 resolves to 3 in Linear mode and 4 in Exponential mode. Every band has an independent visibility toggle, so minimalist users can run ±1σ only, swing traders ±3σ only, or any combination.


[b]🟦 FOUR-GATE ROMB SIGNAL ENGINE[/b]

The Romb engine prints buy / sell diamond markers when price pokes through the outermost enabled σ band and reverses back inside. Four sequential gates protect against false entries:

| Gate | Logic | Purpose |
|---|---|---|
| 1 — Crossover | `ta.crossunder(high, triggerUp)` / `ta.crossover(low, triggerDn)` | Detects the reversal back through the outer band. |
| 2 — Warm-up | Residual σ computable for N consecutive bars | Blocks signals during the early kernel-settlement window. |
| 3 — Confluence | Fair Value slope aligns with the reversal direction | Optional PRO filter — Sell Romb requires falling kernel, Buy Romb requires rising kernel. |
| 4 — Cooldown | Minimum bar gap since the last same-side Romb | Prevents signal clustering on a single extended poke-and-reverse sequence. |

A Signal Mode toggle layers on top:
- **Confirmed** — signals fire only on `barstate.isconfirmed`; zero repaint on closed bars.
- **Realtime** — signals fire live on the current open bar; faster reaction, may vanish if price reverses before close.

Each confirmed signal is rendered as a two-layer neon diamond:
- **Halo** — `size.small`, 40 % transparent theme hue (glow layer).
- **Core** — `size.tiny`, fully opaque theme hue (bright center).

The halo renders first so the core sits cleanly on top, producing a sharp luminous marker that reads instantly even on dense price charts.


[b]🟦 ADAPTIVE OUTER-BAND TRIGGER[/b]

The Romb engine does not hard-code the ±3σ band as the signal trigger. Instead, it resolves the outermost currently-enabled band on every bar:

```
triggerUp = show3 ? upper3 : show2 ? upper2 : show1 ? upper1 : na
triggerDn = show3 ? lower3 : show2 ? lower2 : show1 ? lower1 : na
```

The result is an envelope that respects the user's visibility choices:

| Visible Bands | Romb Fires At |
|---|---|
| ±1σ + ±2σ + ±3σ | ±3σ (default) |
| ±1σ + ±2σ | ±2σ |
| ±1σ only | ±1σ |
| All off | no signals |

Diamond positioning follows the same trigger, so the glyph always floats ~0.3σ outside whatever envelope is actually drawn on the chart. The behavior matches user intent: the band I can see is the band that fires signals.


[b]🟦 NON-REPAINTING BEHAVIOR[/b]

Artemis inherits non-repainting behavior directly from the KernelLens library's `_phase` parameter. A single Phase input (default 2) shifts the kernel center into the past by that many bars:

- **Phase = 0** — live estimate, flickers on the current bar (real-time only; history is immutable).
- **Phase = 1** — 1-bar lag, non-repainting once the bar is confirmed.
- **Phase = 2** — recommended balance between freshness and stability (default).
- **Phase = 3+** — extra margin against erratic ticks, higher lag.

Historical repainting never occurs at any phase value. The library contains no `request.security` calls, no lookahead, and no array rotation that could leak future data. Every historical bar's plotted Fair Value, band, and Romb signal is final once confirmed.


[b]🟦 VISUAL PIPELINE[/b]

**σ Band Outlines** — Three upper bands (±1σ / ±2σ / ±3σ) in progressively lighter `thBear` hues, three lower bands in progressively lighter `thBull` hues. Hidden bands collapse to na via their individual visibility toggles; the outline widths share a single Band Line Width input.

**Tapered Gradient Fills** — Six fills drawn between the Fair Value line and each σ band. Opacity scales progressively from ±1σ (densest, most opaque) to ±3σ (lightest, most transparent), creating a halo that mirrors the statistical density of price residuals under normality. Master Fill Opacity input (0 = invisible, 100 = fully opaque) scales all three fills uniformly.

**Fair Value Line** — Slope-adaptive color resolver swaps between `thBull` (rising kernel) and `thBear` (falling kernel). Flat bars retain the previous color so the line never flashes neutral on a perfectly horizontal tick. Width is user-controlled (1–5 px).

**Romb Diamonds** — Two-layer neon glow at the adaptive trigger band; halo + core rendering described above.

**Bar Coloring** — Optional theme-aware candle coloring driven by the Fair Value slope. Off by default; when enabled it paints every bar with the active theme's bull / bear hue based on the current trend state.


[b]🟦 THEME SYSTEM[/b]

Twelve cohesive color palettes drive every visual component — Fair Value line, σ band outlines, gradient fills, Romb diamonds, bar coloring, and dashboard accents — all sharing the same four color axes (`thBull`, `thBear`, `thNeutral`, `thSignal`):

| Theme | Bull | Bear |
|---|---|---|
| Tropic | Cyan steel | Deep orange |
| Amber | Warm amber | Indigo blue |
| Pastel | Sky blue | Soft lavender |
| Cyber | Neon lime | Hot crimson |
| Helios | Bright gold | Scarlet |
| Electric | Electric aqua | Magenta |
| Candy | Neon green | Hot pink |
| Bloomberg | Terminal orange | Cyan |
| Solar | Solarized olive | Crimson |
| Royal | Imperial gold | Deep purple |
| Midnight | Deep navy | Dark crimson |
| Graphite | Near-black | Silver grey |

A separate Display Mode toggle (Dark / Light) controls the dashboard palette independently of the chart theme — so a Bloomberg chart theme with a Light dashboard is a valid configuration, as is Midnight chart + Dark dashboard.


[b]🟦 DASHBOARD[/b]

A 2-column, 12-row theme-aware status panel that updates only on the last bar (zero historical overhead). Supports Dark and Light display modes, six docking positions, and four text sizes. Renders via `force_overlay = true` on the main price chart.

| Row | Label | Content |
|---|---|---|
| Header | ARTEMIS [PRO] | DARK / LIGHT |
| Theme | Theme | Active palette name |
| Kernel | Kernel | Selected kernel type |
| Divider | REGRESSION | — |
| Bandwidth | Bandwidth ℓ | Bandwidth value / Phase offset φ |
| Filter | Filter | No Filter / Smooth / Zero Lag |
| Fair Value | Fair Value | Current Fair Value in chart mintick format |
| Divider | BANDS | — |
| Spacing | Spacing | Linear 1·/2·/3· or Exp 1·/2·/4· |
| Residual σ | Band σ | Rolling residual standard deviation |
| Trend | Trend | ▲ BULL / ▼ BEAR / ━ FLAT (bull/bear colored) |
| Last Romb | Last Romb | ▲ BUY (N ago) / ▼ SELL (N ago) — bull/bear colored |

**Zebra-stripe layout** — alternating `dashBg` / `dashBgAlt` row backgrounds improve scan-ability on narrow cells. Section dividers (REGRESSION, BANDS) use a third background tone (`dashSection`) with the theme's bull accent as the header color — preserving brand identity across both Display Modes.


[b]🟦 ALERT CONDITIONS[/b]

Six opt-in alert conditions, each gated by its own toggle:

| Alert | Fires When |
|---|---|
| Bullish Trend Flip | Fair Value slope crosses from ≤ 0 into positive territory |
| Bearish Trend Flip | Fair Value slope crosses from ≥ 0 into negative territory |
| Buy Romb | Confirmed Buy Romb fires — all four signal gates passing |
| Sell Romb | Confirmed Sell Romb fires — all four signal gates passing |
| Upper Band Touch | Price touches or exceeds the outermost enabled upper band |
| Lower Band Touch | Price touches or falls below the outermost enabled lower band |

All alerts use `alertcondition()` for maximum compatibility with TradingView's alert system including webhooks. Messages are structured as `"Artemis Regression Bands: <event description>"` for easy parsing in downstream automation. Touch alerts are off by default (can be noisy in trending markets); the four core alerts are on by default.


[b]🟦 RECOMMENDED PRESETS[/b]

| Style | Bandwidth ℓ | Filter | Phase | Spacing | σ Window | Chart |
|---|---|---|---|---|---|---|
| Scalper | 10–20 | No Filter | 1 | Linear | 50–80 | 1m–5m |
| Day Trader | 20–40 | Smooth | 2 | Linear | 80–120 | 15m–1h |
| Swing | 30–60 | Smooth | 2 | Linear or Exp | 100–200 | 4h–1D |
| Position | 60–120 | Smooth or Zero Lag | 3 | Exp | 200–300 | 1D–1W |

**Kernel type tuning**
- **Trending instruments** — Rational Quadratic (α = 1–3) or Gaussian. Smooth multi-scale response.
- **Mean-reverting instruments** — Epanechnikov or Tricube. Compact support keeps the band envelope tight.
- **Session-cyclic patterns** — Periodic (with p = session length in bars) or Locally Periodic. Resonates with known cycles.

**Romb filter tuning** — Keep Kernel Trend Confluence ON for high-conviction setups only. Switch OFF on range-bound instruments to capture both sides of the oscillation.


[b]🟦 COMPATIBILITY[/b]

- Pine Script v6
- All exchanges, all asset classes (crypto, forex, equities, commodities, indices)
- All timeframes (1 minute through Monthly)
- Both Dark and Light chart themes — the Display Mode toggle controls dashboard palette independently
- No exchange-specific logic — fully deterministic


[b]🟦 TECHNICAL NOTES[/b]

- **Library dependency** — `import a_jabbaroff/KernelLens/1` — all kernel regression, residual σ, slope, and trend-state math is delegated to the published library.
- **Plot budget** — 6 band plots + 1 Fair Value anchor + 1 Fair Value visible + 6 gradient fills + 4 Romb plotshapes + 1 barcolor = well under Pine's plot limits.
- **Table** — Single `var table` rebuilt on `barstate.islast` with `force_overlay = true`; zero historical overhead.
- **Signal state** — Two `var int` cooldown anchors (`lastSellBar`, `lastBuyBar`) seeded at −10000 so the very first bar always passes the gap test. A `var int stabCount` warm-up counter blocks signals during early kernel settlement.
- **No persistent drawing objects** — no `box.new`, `line.new`, no array rotations; every visual is either a plot or a single-bar plotshape.
- **Adaptive trigger resolver** — Romb crossover detection, touch alerts, and diamond positioning all read from the same `triggerUp` / `triggerDn` resolver, so band visibility toggles stay semantically coherent across every layer of the indicator.
- **Non-repainting** — inherits from the library's `_phase` parameter; no `request.security`, no lookahead, no future-bar leakage at any phase value.


[b]🟦 DISCLAIMER[/b]

Artemis Regression Bands is a technical analysis indicator built on the KernelLens Nadaraya–Watson regression library. It is provided solely for educational and research purposes and does not constitute financial, investment, or trading advice.

Kernel regression is a local smoothing technique. It estimates the mean of a source series in the neighborhood of the current bar based on historical data, but it does not predict future prices, does not generate trading signals on its own, and does not guarantee the profitability of any strategy built on top of its output. The residual-σ envelope describes past dispersion around the kernel estimate — not a forecast of future range — and should always be combined with broader context: higher-timeframe structure, volatility regime, liquidity, news, and risk management.

Past performance of any model does not guarantee future results. Markets contain systemic risks that cannot be eliminated by any amount of mathematical rigor. Responsibility for any trading decisions rests entirely with the user. Always apply sound capital management, conduct your own independent analysis, and never risk capital you are not prepared to lose.

The author assumes no liability for direct or indirect losses incurred through the use of Artemis Regression Bands or the underlying KernelLens library.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Artemis Regression Bands — Kernel-Driven Volatility Envelope
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
//  Version     : 1.0.0
//  PineScript  : v6
//  Library     : import a_jabbaroff/KernelLens/1
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Artemis Regression Bands is a price-overlay volatility indicator built on
//  top of the KernelLens Nadaraya–Watson regression library. A single kernel
//  estimate — selectable from eight classical kernel families (Rational
//  Quadratic, Gaussian, Periodic, Locally Periodic, Epanechnikov, Tricube,
//  Triangular, Cosine) — anchors the Fair Value line.  Around it, three
//  residual-standard-deviation bands (±1σ, ±2σ, ±3σ) fan outward, producing
//  a statistically grounded envelope far cleaner than the classical
//  close-stdev approach used by legacy Bollinger-style indicators.
//
//  A four-gate Romb signal engine prints buy / sell diamonds when price pokes
//  through the outermost enabled σ boundary and reverses back inside,
//  optionally confirmed against the kernel trend state for PRO confluence.
//  The trigger band adapts to whichever envelope the user leaves visible —
//  ±3σ by default, or ±2σ / ±1σ if outer bands are toggled off.  Twelve
//  cohesive color themes, a Dark / Light dashboard with section dividers and
//  zebra stripes, and six opt-in alert conditions round out the indicator.
//
// ─── Core Engines ────────────────────────────────────────────────────────────
//
//   Kernel Engine   — kl.estimate() with 8 kernel families × 3 filter modes
//   Band Engine     — kl.confidenceBand() residual σ × Linear / Exp spacing
//   Signal Engine   — 4-gate Romb (crossover + stability + confluence + gap)
//   Theme Palette   — 12 cohesive color palettes with theme-aware rendering
//   Dashboard       — 12-row theme-aware panel (Dark / Light display modes)
//
// ─── Design Philosophy ───────────────────────────────────────────────────────
//
//  Legacy regression-band tools fit one hand-tuned curve to every market —
//  ALMA, linear regression, or custom weighted HL structures. Artemis 
//  Regression Bands inverts that: the user picks a kernel family appropriate to the
//  instrument's volatility signature (periodic / trending / mean-reverting),
//  and the library delivers a Nadaraya–Watson estimate whose residuals drive
//  the band widths directly. No arbitrary multiplier of close stdev, no
//  Kalman patch-up on a pre-smoothed midline — just one clean kernel pass
//  plus one residual-stdev pass.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Artemis Regression Bands", "AR Bands", overlay = true, max_bars_back = 5000, max_labels_count = 500)

import a_jabbaroff/KernelLens/1 as kl


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_SRC    = "Source 🔹"
const string GRP_THEME  = "Theme 🔹"
const string GRP_KRN    = "Kernel Engine 🔹"
const string GRP_BAND   = "Bands 🔹"
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

// Band spacing modes — control how ±σ bands fan outward from the Fair Value
const string SPC_LIN  = "Linear"
const string SPC_EXP  = "Exponential"

// Signal evaluation mode — Confirmed waits for bar close, Realtime fires live
const string SIG_CONF = "Confirmed"
const string SIG_LIVE = "Realtime"


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Source ──────────────────────────────────────────────────────────────────
src = input.source(close, "Kernel Source", group = GRP_SRC,
     tooltip = "Price series fed to the kernel regression engine.  Typical choices: close, hl2, ohlc4.\n\nThis source anchors the Fair Value line and drives every downstream calculation: σ bands, slope direction, Romb signals, and dashboard trend state.\n\nDefault: close")


// ─── Theme ───────────────────────────────────────────────────────────────────
themeChoice = input.string("Tropic", "Theme",
     options = ["Tropic", "Amber", "Pastel", "Cyber", "Helios", "Electric", "Candy", "Bloomberg", "Solar", "Royal", "Midnight", "Graphite"],
     group   = GRP_THEME,
     tooltip = "Applies a complete color palette across every visual component — Fair Value line, σ bands, gradient fills, Romb diamonds, bar coloring, and dashboard accents.\n\nTropic — Cyan steel + deep orange (electric contrast — default)\n\nAmber — Warm amber + indigo blue (fire tones)\n\nPastel — Sky blue + soft lavender (cool arctic glow)\n\nCyber — Neon lime + hot crimson (cyber terminal)\n\nHelios — Bright gold + scarlet (solar warmth)\n\nElectric — Electric aqua + magenta (high-voltage neon)\n\nCandy — Neon green + hot pink (dark energy pop)\n\nBloomberg — Terminal orange + cyan (Wall Street finance heritage — PRO)\n\nSolar — Solarized olive + crimson (developer palette, easy on the eyes — PRO)\n\nRoyal — Imperial gold + deep purple (luxury signature — PRO)\n\nMidnight — Deep navy + dark crimson (dark depth)\n\nGraphite — Near-black + silver grey (monochrome minimal)")


// ─── Kernel Engine ───────────────────────────────────────────────────────────
kType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_KRN,
     tooltip = "Kernel family used for the Nadaraya–Watson regression.\n\nRational Quadratic — multi-scale mixer, α controls stretch (recommended default)\nGaussian / RBF — canonical smoother, infinitely differentiable\nPeriodic — resonates with a known repetition distance p\nLocally Periodic — periodic × gaussian (seasonal + trend drift)\nEpanechnikov — MSE-optimal, compact support (no tail contamination)\nTricube — LOWESS standard, near-Gaussian compact profile\nTriangular — simplest compact kernel, cheapest to compute\nCosine — raised-cosine, smooth boundary transition\n\nDefault: Rational Quadratic")

kBw = input.int(30, "Bandwidth ℓ", minval = 2, step = 1, group = GRP_KRN,
     tooltip = "Kernel scale ℓ in bars — controls the smoothness / reactivity trade-off.\n\nSmaller ℓ — tighter fit to price, more reactive, noisier Fair Value\nLarger ℓ — smoother curve, more stable, slower response\n\nRecommended ranges by trading style:\nScalper   — 10–20 bars\nDay trader — 20–40 bars\nSwing     — 30–60 bars\nPosition  — 60–120 bars\n\nDefault: 30")

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


// ─── Bands ───────────────────────────────────────────────────────────────────
baseMult = input.float(1.0, "Base Multiplier", minval = 0.1, step = 0.1, group = GRP_BAND,
     tooltip = "Multiplies the residual σ to size every band.\n\nIn Linear spacing  — bands sit at ±1·mult·σ / ±2·mult·σ / ±3·mult·σ\nIn Exponential    — bands sit at ±1·mult·σ / ±2·mult·σ / ±4·mult·σ\n\nLower values tighten all three bands, higher values widen them proportionally.\n\n0.5 — tight, sensitive to micro-reversions\n1.0 — balanced (default)\n1.5–2.0 — wide, only extreme excursions reach the outer band\n\nDefault: 1.0")

spaceMode = input.string(SPC_LIN, "Spacing Mode",
     options = [SPC_LIN, SPC_EXP],
     group   = GRP_BAND,
     tooltip = "Controls how the three σ bands fan outward from the Fair Value line.\n\nLinear      — bands at 1·, 2·, 3· of (baseMult × σ).  Classical Bollinger-style spacing, predictable, uniform steps.\n\nExponential — bands at 1·, 2·, 4· of (baseMult × σ).  Fibonacci-flavored spacing, emphasizes extreme zones — outer band reserved for genuine blow-off moves.\n\nDefault: Linear")

bandWin = input.int(100, "Residual σ Window", minval = 10, maxval = 500, group = GRP_BAND,
     tooltip = "Lookback window for the rolling residual standard deviation — i.e. σ of (source − fairValue).\n\nShorter → more reactive bands, tighter in calm markets, wider in fast volatility\nLonger  → more stable bands, insensitive to short-term volatility bursts\n\n50–80  — reactive / scalping\n100    — balanced (default)\n150–300 — position / swing\n\nDefault: 100")

show1 = input.bool(true,  "Show ±1σ Band", group = GRP_BAND,
     tooltip = "Inner band — first standard-deviation envelope.  The tightest zone; price spends most of its time here during normal regimes.")

show2 = input.bool(true,  "Show ±2σ Band", group = GRP_BAND,
     tooltip = "Middle band — second standard-deviation envelope.  Classic Bollinger boundary; statistically encloses ~95 % of residual variation under normality.")

show3 = input.bool(true,  "Show ±3σ Band", group = GRP_BAND,
     tooltip = "Outer band — third standard-deviation envelope.  The extreme boundary used by the Romb mean-reversion signal engine.  Touches here are rare and statistically significant.")

fillOpacity = input.int(15, "Fill Opacity", minval = 0, maxval = 100, group = GRP_BAND,
     tooltip = "Opacity of the gradient fill between the Fair Value line and each σ band.\n\n0   — invisible (bands render as outlines only)\n15  — subtle background wash (default)\n50+ — heavy fill, obscures price candles\n\nIntuitive scale: higher number = more visible.")


// ─── Signal System ───────────────────────────────────────────────────────────
showRomb = input.bool(true, "Show Romb Signals", group = GRP_SIG,
     tooltip = "Master toggle for the buy / sell diamond (Romb) markers.\n\nRombs fire when price pokes through the OUTERMOST enabled σ band and reverses back inside — a classic mean-reversion trigger, refined by a four-gate filter:\n  1. Crossover (price back inside the band)\n  2. Stability counter (band not flickering)\n  3. Kernel trend confluence (optional)\n  4. Cooldown gap\n\nAdaptive trigger — the engine follows whichever outer band the user has left visible:\n  • All three on  → Rombs fire at ±3σ\n  • ±1 + ±2 on   → Rombs fire at ±2σ\n  • Only ±1 on   → Rombs fire at ±1σ\n  • All off      → no signals\n\nDefault: ON")

useConfluence = input.bool(true, "Kernel Trend Confluence", group = GRP_SIG,
     tooltip = "Optional PRO filter — only allows Romb signals that align with the Fair Value slope direction.\n\nON  — Sell Romb fires only if kernel is falling; Buy Romb only if kernel is rising.  Cleanest setups, fewer signals.\nOFF — Pure mean-reversion mode.  Every outer-band poke-and-reverse triggers regardless of trend.\n\nDefault: ON")

stabThresh = input.int(3, "Warm-up Bars", minval = 0, maxval = 20, group = GRP_SIG,
     tooltip = "Minimum consecutive bars the residual σ must be computable before the signal engine is allowed to fire.\n\nAt session start (and after any stretch where the stdev window has insufficient samples) σ is na.  This gate blocks Romb signals until σ has produced valid values for the given number of bars in a row — so you never get a spurious diamond on the very first computable bar.\n\nThis is a warm-up filter, not a continuous volatility filter — once the threshold clears, the gate stays open for the rest of the chart unless σ goes na again.\n\n0  — no warm-up gate (signals can fire on the first computable bar)\n3  — balanced (default)\n5+ — conservative, waits a few extra bars for confidence\n\nDefault: 3")

signalGap = input.int(8, "Cooldown Gap (bars)", minval = 0, maxval = 100, group = GRP_SIG,
     tooltip = "Minimum bars that must elapse between two consecutive Rombs of the same direction.\n\nPrevents signal clustering on a single extended poke-and-reverse sequence.\n\n0    — no cooldown, every qualifying trigger fires\n4–10 — balanced (default range)\n20+  — strict, only well-separated entries\n\nDefault: 8")

signalMode = input.string(SIG_CONF, "Signal Mode",
     options = [SIG_CONF, SIG_LIVE],
     group   = GRP_SIG,
     tooltip = "Controls when Romb signals fire.\n\nConfirmed — signals fire ONLY after the bar closes.  The diamond will never disappear once plotted.  Zero repaint, fully reliable.  Recommended for live trading.\n\nRealtime  — signals fire on the current (open) bar as soon as the crossover condition is met.  Fastest reaction, but the signal may vanish if price reverses before the bar closes.\n\nDefault: Confirmed")


// ─── Visual Style ────────────────────────────────────────────────────────────
fairWidth = input.int(2, "Fair Value Width", minval = 1, maxval = 5, group = GRP_VIS,
     tooltip = "Thickness of the Fair Value regression line.\n\n1 — hairline, precision view\n2 — balanced (default)\n3–5 — thick, high-visibility\n\nDefault: 2")

bandWidth = input.int(1, "Band Line Width", minval = 1, maxval = 4, group = GRP_VIS,
     tooltip = "Thickness of the σ band outline.\n\n1 — hairline (default, cleanest for gradient fills)\n2 — medium\n3–4 — thick\n\nDefault: 1")

showBarColor = input.bool(false, "Bar Coloring", group = GRP_VIS,
     tooltip = "Optional theme-aware bar coloring driven by the Fair Value slope.\n\nOFF — standard TradingView bars (default)\nON  — bars painted with the active Theme's bull / bear hue based on slope direction\n\nDefault: OFF")


// ─── Dashboard ───────────────────────────────────────────────────────────────
showDash = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Compact 2-column live status panel.  Updates only on the last bar — zero historical overhead.\n\nShows at a glance: Theme, Kernel, Bandwidth, Filter, Fair Value, Spacing, σ, Trend, and the last Romb signal.")

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
alertBull = input.bool(true, "Bullish Trend Flip", group = GRP_ALERT,
     tooltip = "Fires when the Fair Value slope crosses from ≤ 0 into positive territory — the indicator flips bullish.")

alertBear = input.bool(true, "Bearish Trend Flip", group = GRP_ALERT,
     tooltip = "Fires when the Fair Value slope crosses from ≥ 0 into negative territory — the indicator flips bearish.")

alertBuy = input.bool(true, "Buy Romb", group = GRP_ALERT,
     tooltip = "Fires on a confirmed Buy Romb — price poked below the lower outer band and reversed back inside with all four signal gates passing.\n\nThe outer band is resolved adaptively from the visibility toggles (±3σ → ±2σ → ±1σ).\n\nSuppressed automatically when 'Show Romb Signals' is disabled.")

alertSell = input.bool(true, "Sell Romb", group = GRP_ALERT,
     tooltip = "Fires on a confirmed Sell Romb — price poked above the upper outer band and reversed back inside with all four signal gates passing.\n\nThe outer band is resolved adaptively from the visibility toggles (±3σ → ±2σ → ±1σ).\n\nSuppressed automatically when 'Show Romb Signals' is disabled.")

alertTouchUp = input.bool(false, "Upper Band Touch", group = GRP_ALERT,
     tooltip = "Fires whenever price touches or exceeds the upper outer band.\n\n'Outer' is resolved adaptively from the active band toggles:\n  • All three on  → ±3σ\n  • ±1 + ±2 on   → ±2σ\n  • Only ±1 on   → ±1σ\n\nRaw touch alert — fires before the Romb mean-reversion logic evaluates.  Useful as a pre-signal early warning.\n\nSuppressed automatically when every band visibility toggle is off.\n\nDefault: OFF (can be noisy in trending markets)")

alertTouchDn = input.bool(false, "Lower Band Touch", group = GRP_ALERT,
     tooltip = "Fires whenever price touches or falls below the lower outer band.\n\n'Outer' is resolved adaptively from the active band toggles:\n  • All three on  → −3σ\n  • ±1 + ±2 on   → −2σ\n  • Only ±1 on   → −1σ\n\nRaw touch alert — fires before the Romb mean-reversion logic evaluates.  Useful as a pre-signal early warning.\n\nSuppressed automatically when every band visibility toggle is off.\n\nDefault: OFF (can be noisy in trending markets)")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (12 cohesive color palettes)
// ═══════════════════════════════════════════════════════════════════════════════
// Each theme defines four axis colors:
//   thBull    — bullish side  (positive slope, lower band fill, buy Romb)
//   thBear    — bearish side  (negative slope, upper band fill, sell Romb)
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
// The dashboard palette is independent of the chart theme.  Dark mode is the
// default; Light mode flips the scaffold to white / near-white tones so the
// panel stays readable against bright charts.  Header and divider accents
// always pick up the active theme's bull hue so brand identity is preserved
// regardless of display mode.

color dashBg      = displayMode == "Dark" ? #0A0A0A : #FFFFFF
color dashBgAlt   = displayMode == "Dark" ? #141414 : #F5F5F5
color dashFg      = displayMode == "Dark" ? #E0E0E0 : #1A1A1A
color dashBorder  = displayMode == "Dark" ? #2A2A2A : #DCDCDC
color dashHeader  = f_opac(thBull, 100)
color dashSection = displayMode == "Dark" ? #1A1A1A : #EEEEEE


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 3   —   KERNEL ENGINE & BAND COMPUTATION
// ═══════════════════════════════════════════════════════════════════════════════
// Single kernel pass anchors the Fair Value line.  Residual σ feeds the band
// widths.  Band levels are resolved through a spacing-mode switch so the
// downstream plot code is agnostic to whether the bands are Linear or
// Exponentially spaced.
//
// Library call signature:
//   kl.estimate(_kernelType, _src, _bandwidth, _shapeAlpha, _period, _phase, _filter)
//   kl.confidenceBand(_src, _estimate, _window)  →  rolling σ of residual
//   kl.slope(_estimate, _step)                   →  discrete first derivative
//   kl.trendState(_estimate, _step)              →  +1 / 0 / −1 ternary state

// ─── Fair Value line (the regression anchor) ─────────────────────────────────
float fair = kl.estimate(kType, src, kBw, kAlpha, kPeriod, kPhase, kFilter)

// ─── Residual standard deviation (band half-width per σ) ─────────────────────
// ta.stdev(src − fair, window) — wrapped by the library with input validation.
float sigma = kl.confidenceBand(src, fair, bandWin)

// ─── Per-band multipliers resolved from the spacing mode ─────────────────────
// Linear      : k = 1, 2, 3   (classical Bollinger-style uniform steps)
// Exponential : k = 1, 2, 4   (Fibonacci-flavored, outer band reserved for
//                              genuine blow-off excursions)
float k1 = 1.0
float k2 = 2.0
float k3 = spaceMode == SPC_EXP ? 4.0 : 3.0

// ─── Band levels ─────────────────────────────────────────────────────────────
// Every band is fairValue ± (baseMult · k · σ).  Nesting the multiplier into
// baseMult keeps the formula honest to the user's spacing preference.
float dev = baseMult * sigma
float upper1 = fair + k1 * dev
float upper2 = fair + k2 * dev
float upper3 = fair + k3 * dev
float lower1 = fair - k1 * dev
float lower2 = fair - k2 * dev
float lower3 = fair - k3 * dev

// ─── Slope, trend state, and slope-color resolver ────────────────────────────
// Slope is read off Fair Value with a 1-bar finite difference; trend state
// discretises it into ±1 / 0.  The slope color swaps between the theme's
// bull / bear hues; ties retain the previous bar's color so the Fair Value
// line never flashes neutral on a perfectly flat bar.
float slopeVal = kl.slope     (fair, 1)
int   trendSt  = kl.trendState(fair, 1)

var color slopeColor = thNeutral
slopeColor := trendSt ==  1 ? thBull :
              trendSt == -1 ? thBear :
                              slopeColor


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   Romb SIGNAL ENGINE   (4-gate mean-reversion logic)
// ═══════════════════════════════════════════════════════════════════════════════
// The Romb engine fires diamond markers when price pokes through the
// outermost enabled σ band and reverses back inside.  A four-gate filter
// protects against false entries:
//
//   Gate 1 — Crossover       : price reverses back through the band
//   Gate 2 — Warm-up Gate    : residual σ has been computable for N bars
//   Gate 3 — Confluence      : kernel slope aligns with the reversal (optional)
//   Gate 4 — Cooldown        : minimum bar gap since the last same-side Romb
//
// A Signal Mode gate layers on top: Confirmed waits for bar close, Realtime
// fires live.  The Confirmed default prevents repaint on closed bars.

// ─── Outermost-enabled band resolver (adaptive signal trigger) ───────────────
// The Romb engine fires against whichever σ band the user has currently
// enabled at the outermost position.  If ±3σ is on, signals trigger there;
// if only ±1σ and ±2σ are on, signals trigger at ±2σ; if only ±1σ is on,
// signals trigger at ±1σ.  This keeps Romb diamonds visually anchored to
// the outer edge of whatever envelope is visible — matching user intent:
// "the band I can see is the band that fires signals".
// If all three bands are hidden the trigger collapses to na and no signals
// will ever fire — downstream logic is naturally silent.
float triggerUp = show3 ? upper3 : show2 ? upper2 : show1 ? upper1 : na
float triggerDn = show3 ? lower3 : show2 ? lower2 : show1 ? lower1 : na

// ─── Raw crossover detection (Gate 1) ────────────────────────────────────────
// Sell : high crossed ABOVE the outer band, now closing back inside.
// Buy  : low  crossed BELOW the outer band, now closing back inside.
bool rawSell = ta.crossunder(high, triggerUp)
bool rawBuy  = ta.crossover (low,  triggerDn)

// ─── Raw outer-band touch events (used by the early-warning alert pair) ──────
bool touchUp = ta.crossover (high, triggerUp)
bool touchDn = ta.crossunder(low,  triggerDn)

// ─── Warm-up gate (Gate 2) ───────────────────────────────────────────────────
// Counts consecutive bars on which the residual σ has been computable.  On
// early bars — and any time the stdev window has insufficient samples — σ is
// na; the counter resets to zero and the gate blocks signals until the
// kernel estimate and its residuals have settled.  This is a warm-up filter,
// not a continuous flicker detector: once stabThresh clears, the gate stays
// open for the remainder of the chart unless σ goes na again.
var int stabCount = 0
stabCount := na(sigma) ? 0 : stabCount + 1
bool stableOK = stabCount > stabThresh

// ─── Kernel trend confluence (Gate 3, optional) ──────────────────────────────
// Sell signal requires a falling kernel (trendSt == −1) when enabled.
// Buy  signal requires a rising  kernel (trendSt == +1) when enabled.
bool confSell = not useConfluence or trendSt == -1
bool confBuy  = not useConfluence or trendSt ==  1

// ─── Signal Mode gate (Confirmed / Realtime) ─────────────────────────────────
bool confirmGate = signalMode == SIG_CONF ? barstate.isconfirmed : true

// ─── Combine gates 1–3 + Signal Mode into a pre-cooldown signal ──────────────
bool sellReady = rawSell and stableOK and confSell and confirmGate
bool buyReady  = rawBuy  and stableOK and confBuy  and confirmGate

// ─── Cooldown (Gate 4) ───────────────────────────────────────────────────────
// Track the bar index of the last fired Romb per side; suppress new signals
// until the cooldown gap has elapsed.  Seeded at −10000 so the very first
// bar always passes the gap test.
var int lastSellBar = -10000
var int lastBuyBar  = -10000

bool sellFire = sellReady and (bar_index - lastSellBar) > signalGap
bool buyFire  = buyReady  and (bar_index - lastBuyBar)  > signalGap

// Refresh cooldown anchors whenever a signal fires
if sellFire
    lastSellBar := bar_index
if buyFire
    lastBuyBar  := bar_index


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
// Z-order (Pine renders in declaration order, later = on top):
//   1. σ band outlines (hidden when a band's toggle is off)
//   2. Gradient fills between Fair Value and each band
//   3. Fair Value line (on top of the fills, but below signals)
//   4. Romb diamonds (above everything)
//   5. Bar coloring (affects candles, not a z-order concern)

// ─── σ band plot handles ─────────────────────────────────────────────────────
// Each band renders as a thin line in the appropriate theme hue — thBear on
// the upper side, thBull on the lower side.  Hidden bands collapse to na via
// their individual show* toggle; the handle is still declared so downstream
// fill() calls always have a valid anchor.
plot_u1 = plot(show1 ? upper1 : na, "Upper ±1σ", color = f_opac(thBear, 80), linewidth = bandWidth)
plot_u2 = plot(show2 ? upper2 : na, "Upper ±2σ", color = f_opac(thBear, 70), linewidth = bandWidth)
plot_u3 = plot(show3 ? upper3 : na, "Upper ±3σ", color = f_opac(thBear, 60), linewidth = bandWidth)

plot_l1 = plot(show1 ? lower1 : na, "Lower ±1σ", color = f_opac(thBull, 80), linewidth = bandWidth)
plot_l2 = plot(show2 ? lower2 : na, "Lower ±2σ", color = f_opac(thBull, 70), linewidth = bandWidth)
plot_l3 = plot(show3 ? lower3 : na, "Lower ±3σ", color = f_opac(thBull, 60), linewidth = bandWidth)

// ─── Anchor plot for Fair Value (needed by the gradient fills) ───────────────
// Declared before the fills so both sides can bind against it.  The actual
// Fair Value colored line is re-plotted below at higher z-order.
pFair = plot(fair, "Fair Value Anchor", color = na, display = display.none, editable = false)

// ─── Gradient fills — Fair Value ↔ each σ band ───────────────────────────────
// The fill opacity widens progressively from ±1σ (densest, most opaque) to
// ±3σ (lightest, most transparent), creating a tapered halo that mirrors the
// statistical density of price residuals under normality.
//
// fillOpacity user input scales all three fills uniformly.  When it is 0 the
// fills are effectively invisible; at 100 the ±1σ fill sits at full opacity.
int fillT1 = 100 - fillOpacity
int fillT2 = 100 - math.round(fillOpacity * 0.70)
int fillT3 = 100 - math.round(fillOpacity * 0.40)

fill(pFair, plot_u1, color = show1 ? color.new(thBear, fillT1) : na, title = "Fill Upper 1σ")
fill(pFair, plot_u2, color = show2 ? color.new(thBear, fillT2) : na, title = "Fill Upper 2σ")
fill(pFair, plot_u3, color = show3 ? color.new(thBear, fillT3) : na, title = "Fill Upper 3σ")
fill(pFair, plot_l1, color = show1 ? color.new(thBull, fillT1) : na, title = "Fill Lower 1σ")
fill(pFair, plot_l2, color = show2 ? color.new(thBull, fillT2) : na, title = "Fill Lower 2σ")
fill(pFair, plot_l3, color = show3 ? color.new(thBull, fillT3) : na, title = "Fill Lower 3σ")

// ─── Fair Value line — slope-adaptive color ──────────────────────────────────
// Re-plotted after the fills so the visible line sits on top of the halos.
// Width and color come directly from user inputs + the slopeColor resolver.
plot(fair, "Fair Value", color = slopeColor, linewidth = fairWidth)

// ─── Romb diamonds (two-layer neon glow) ─────────────────────────────────────
// Each confirmed signal prints two plotshapes at the same absolute price:
//   • Halo  — size.small, 40 % transparent theme hue (glow layer)
//   • Core  — size.tiny, fully opaque theme hue      (bright center)
// The halo renders first so the core sits cleanly on top.  The diamond
// floats just outside the outermost-enabled band — triggerUp / triggerDn
// already resolves to that band (±3σ → ±2σ → ±1σ) so the glyph auto-follows
// whatever envelope the user has made visible, avoiding overlap with the
// band outline.
float diamondOffset = dev * 0.3    // ~0.3σ padding outside the active band
float sellY = showRomb and sellFire ? triggerUp + diamondOffset : na
float buyY  = showRomb and buyFire  ? triggerDn - diamondOffset : na

plotshape(sellY, "Sell Halo",
     shape.diamond, location.absolute,
     color = f_opac(thBear, 40), size = size.small)
plotshape(sellY, "Sell Core",
     shape.diamond, location.absolute,
     color = f_opac(thBear, 100), size = size.tiny)

plotshape(buyY, "Buy Halo",
     shape.diamond, location.absolute,
     color = f_opac(thBull, 40), size = size.small)
plotshape(buyY, "Buy Core",
     shape.diamond, location.absolute,
     color = f_opac(thBull, 100), size = size.tiny)

// ─── Bar coloring (optional) ─────────────────────────────────────────────────
// Slope-adaptive bar hue using the active theme.  When the toggle is off we
// pass na so TradingView's default candle coloring stays untouched.
barcolor(showBarColor ? slopeColor : na, title = "Artemis Bar Coloring")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   DASHBOARD   (theme-aware, Dark / Light)
// ═══════════════════════════════════════════════════════════════════════════════
// 12-row compact status panel rendered only on the last bar so historical
// bars carry zero overhead.  Four logical blocks (Header → Config →
// Regression → Bands → Signal) separated by section divider rows; alternate
// row backgrounds (dashBg / dashBgAlt) create a zebra stripe that improves
// scan-ability on narrow cells.

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
string trendLbl = trendSt ==  1 ? "▲ BULL" : trendSt == -1 ? "▼ BEAR" : "━ FLAT"
color  trendCol = trendSt ==  1 ? thBull   : trendSt == -1 ? thBear   : dashFg

string spaceLbl = spaceMode == SPC_EXP ? "Exp  1·/2·/4·" : "Linear 1·/2·/3·"

// Last Romb tracker — inspects cooldown anchors to report which signal fired
// most recently and how many bars ago it printed.
bool   noRomb      = lastSellBar == -10000 and lastBuyBar == -10000
int    barsSell    = bar_index - lastSellBar
int    barsBuy     = bar_index - lastBuyBar
bool   lastWasSell = lastSellBar > lastBuyBar

string lastRombLbl = noRomb ? "—"
     : lastWasSell ? "▼ SELL (" + str.tostring(barsSell) + " ago)"
     :               "▲ BUY ("  + str.tostring(barsBuy)  + " ago)"
color  lastRombCol = noRomb ? dashFg
     : lastWasSell ? thBear
     :               thBull

var table dash = na

if barstate.islast and showDash
    dash := table.new(posV, 2, 12,
         bgcolor       = dashBg,
         border_color  = dashBorder,
         border_width  = 1,
         frame_color   = dashBorder,
         frame_width   = 2,
         force_overlay = true)

    // ─── Row 0 — Header (brand + display mode) ───
    table.cell(dash, 0, 0, "ARB [PRO]",
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

    // ─── Row 2 — Kernel ───
    table.cell(dash, 0, 2, "Kernel",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 2, kType,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 3 — Section divider: REGRESSION ───
    table.cell(dash, 0, 3, "REGRESSION",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 3, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 4 — Bandwidth + Phase ───
    table.cell(dash, 0, 4, "Bandwidth ℓ",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(kBw) + "  / φ " + str.tostring(kPhase),
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 5 — Filter ───
    table.cell(dash, 0, 5, "Filter",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 5, kFilter,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 6 — Fair Value ───
    table.cell(dash, 0, 6, "Fair Value",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 6, f_fmt(fair),
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 7 — Section divider: BANDS ───
    table.cell(dash, 0, 7, "BANDS",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 7, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 8 — Spacing ───
    table.cell(dash, 0, 8, "Spacing",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 8, spaceLbl,
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 9 — Residual σ ───
    table.cell(dash, 0, 9, "Band σ",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 9, f_fmt(sigma),
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 10 — Trend ───
    table.cell(dash, 0, 10, "Trend",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 10, trendLbl,
         text_color = trendCol, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 11 — Last Romb ───
    table.cell(dash, 0, 11, "Last Romb",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 11, lastRombLbl,
         text_color = lastRombCol, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 7   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
// Every alert is opt-in via a matching input toggle.  Additional component
// visibility gates (showRomb) suppress alerts when their visual counterpart
// is disabled — hiding the Romb diamonds also silences their alerts.

// Trend flip events — slope crosses zero.  The literal is typed as 0.0 so
// ta.crossover / ta.crossunder resolve to their (series float, series float)
// overload without an implicit int → float promotion at the call site.
bool bullFlip = ta.crossover (slopeVal, 0.0)
bool bearFlip = ta.crossunder(slopeVal, 0.0)

alertcondition(alertBull and bullFlip,
     title   = "Artemis — Bullish Trend Flip",
     message = "Artemis Regression Bands: Fair Value slope crossed above zero — bullish flip confirmed.")

alertcondition(alertBear and bearFlip,
     title   = "Artemis — Bearish Trend Flip",
     message = "Artemis Regression Bands: Fair Value slope crossed below zero — bearish flip confirmed.")

alertcondition(alertBuy and showRomb and buyFire,
     title   = "Artemis — Buy Romb",
     message = "Artemis Regression Bands: Buy Romb — price poked below the lower outer band and reversed back inside with all four signal gates passing.")

alertcondition(alertSell and showRomb and sellFire,
     title   = "Artemis — Sell Romb",
     message = "Artemis Regression Bands: Sell Romb — price poked above the upper outer band and reversed back inside with all four signal gates passing.")

// Outer-band touches fire against the same adaptive trigger as the Romb
// engine (triggerUp / triggerDn) — gating on "any band enabled" so the
// alerts stay silent only when the entire envelope is hidden.
bool anyBandOn = show1 or show2 or show3

alertcondition(alertTouchUp and anyBandOn and touchUp,
     title   = "Artemis — Upper Band Touch",
     message = "Artemis Regression Bands: price touched or exceeded the upper outer band — pre-signal early warning.")

alertcondition(alertTouchDn and anyBandOn and touchDn,
     title   = "Artemis — Lower Band Touch",
     message = "Artemis Regression Bands: price touched or fell below the lower outer band — pre-signal early warning.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````

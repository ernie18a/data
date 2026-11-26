# Meridian Lens PRO

- url: https://www.tradingview.com/script/V4G2vZNK-Meridian-Lens-PRO/
- type: indicator
- pine_id: PUB;18b612a34d834022b7c00fcebe5b3c76
- version: 1.0

## Description

[b]🟦 Meridian Lens PRO[/b] is a multi-kernel trend indicator built on the KernelLens Nadaraya–Watson regression library (a_jabbaroff/KernelLens/1). Three independently configurable kernel lines — Fast, Medium, and Slow — cover the full reactivity spectrum from scalping to position trading, each accepting any of the eight kernel families and three filter modes exposed by the library. The visual layer applies volume-intensity-adaptive coloring, gradient-filled trailing bands, 3-layer neon glow signal arrows, and a theme-aware dashboard — all driven by a single theme selection from ten optical-brand palettes.


[b]🟦 HOW IT WORKS[/b]

Meridian Lens PRO calls the KernelLens library's unified dispatcher (`kl.estimate`) three times per bar — once for each kernel line:

```
Fast   = kl.estimate(type, src, bw=8,  α, period, phase, filter)
Medium = kl.estimate(type, src, bw=16, α, period, phase, filter)
Slow   = kl.estimate(type, src, bw=32, α, period, phase, filter)
```

Each line independently selects its kernel family (Rational Quadratic, Gaussian, Periodic, Locally Periodic, Epanechnikov, Tricube, Triangular, Cosine), its filter mode (No Filter / Smooth / Zero Lag), its bandwidth, shape α, period, phase, and line width. The library handles all weighted-sum computation, loop-depth selection, NA-safe iteration, and input validation internally.

The Medium line is the primary trend reference — it drives the trailing bands, the main signal arrows, the dashboard trend cell, and the direction variable that colors every visual component. The Fast line provides early-warning reactivity for short-term entry timing. The Slow line anchors the macro trend for crossover logic and confluence scoring.


[b]🟦 KERNEL LIBRARY INTEGRATION[/b]

Meridian Lens imports the published KernelLens library and uses the following exports:

| Library Export | Used For |
|---|---|
| `kl.estimate()` | Unified dispatcher — routes to the correct kernel based on user's dropdown selection |
| `kl.trendState()` | Returns +1 / −1 / 0 for each kernel's slope — drives dashboard arrows and signal triggers |
| `kl.crossSignal()` | Detects Fast × Slow crossovers — drives the Cross row in the dashboard and crossover alerts |

The indicator does not reimplement any kernel math — all regression computation is delegated to the library, ensuring that every bug fix or optimization in the library automatically propagates to this indicator.


[b]🟦 THREE KERNEL LINES[/b]

**Fast Kernel** — The most reactive line. Default bandwidth 8, No Filter. Designed for scalping and short-term entry timing. Flips direction frequently on noisy charts — its signal markers are OFF by default to avoid visual clutter.

**Medium Kernel** — The primary trend reference. Default bandwidth 16, Smooth filter. Drives the trailing bands, the main 3-layer glow signal arrows, the dashboard Trend cell, and the direction variable that colors every visual component. This is the indicator's core signal.

**Slow Kernel** — The macro trend anchor. Default bandwidth 32, Smooth filter. Provides structural support for crossover logic (Fast × Slow) and triple-line confluence scoring. Its signal markers are ON by default because Slow flips are rare and meaningful.

Each kernel group exposes: Show toggle, Kernel Type dropdown (8 families), Bandwidth, Shape α (RQ only), Period (Periodic / Locally Periodic only), Phase (non-repainting offset), Filter (None / Smooth / Zero Lag), and Line Width.


[b]🟦 NON-REPAINTING BEHAVIOR[/b]

Meridian Lens inherits non-repainting behavior directly from the KernelLens library's `_phase` parameter. Each kernel line has its own Phase input (default: 2), which shifts the kernel center into the past by that many bars.

- Phase = 0 — live estimate, flickers on the current bar (real-time only; history is immutable)
- Phase = 1 — 1-bar lag, non-repainting once the bar is confirmed
- Phase = 2 — recommended balance between freshness and stability (default)
- Phase = 3+ — extra stability for swing and position trading

Historical repainting never occurs at any phase value. The library contains no `request.security` calls, no lookahead, and no array rotation that could leak future data. Every historical bar's plotted value is final once confirmed.


[b]🟦 SIGNAL SYSTEM[/b]

The indicator produces three tiers of trend-flip signals, each visually distinct:

**Medium Signals (Primary)** — 3-layer neon glow arrows rendered when the Medium kernel's direction flips. The outer halo is large and 80% transparent, the middle layer is normal-sized and 50% transparent, and the core arrow is small and fully opaque — creating a luminous halo effect on dark charts. Controlled by the "Glow Effect" toggle.

**Slow Signals** — Minimal tiny arrows (40% transparent) that fire when the Slow kernel flips direction. ON by default — these mark rare, meaningful macro trend changes.

**Fast Signals** — Minimal tiny arrows (40% transparent) that fire when the Fast kernel flips direction. OFF by default — enable for early-warning entry timing on lower timeframes.


[b]🟦 VISUAL PIPELINE[/b]

**Volume-Intensity Adaptive Color** — The Medium line's transparency responds to the current volume reading. High volume = bright line (volume-confirmed trend), low volume = dim line (low-conviction drift). Uses a 33-bar HMA-smoothed normalized volume metric. Disable for a fixed 50% transparency.

**Trailing Bands** — Gradient-filled bands on the bullish/bearish side of the Medium line. Band width is driven by the rolling 100-bar average candle body size multiplied by a configurable distance factor (default: 2.0×). Bull bands fill below the Medium line during uptrends, bear bands fill above during downtrends.

**Theme System** — Ten cohesive palettes drive every visual component:

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


[b]🟦 PRO DASHBOARD[/b]

A 2-column, 11-row theme-aware status panel that updates only on the last bar (zero historical overhead). Supports Dark and Light display modes with configurable position and text size.

| Row | Label | Content |
|---|---|---|
| Header | MERIDIAN LENS | DARK / LIGHT |
| Theme | Theme | Active palette name |
| Kernel | Kernel | Medium kernel type |
| Divider | KERNELS | — |
| Fast | Fast | ▲/▼ + price value (bull/bear colored) |
| Medium | Medium | ▲/▼ + price value (bull/bear colored) |
| Slow | Slow | ▲/▼ + price value (bull/bear colored) |
| Divider | SIGNALS | — |
| Trend | Trend | ▲ BULL / ▼ BEAR |
| Cross | Cross | ↑ UP / ↓ DOWN / — |
| Strength | Strength | ▰▰▰ TRIPLE / ▰▰▱ STRONG / ▰▱▱ WEAK / ▱▱▱ NEUTRAL |

**Confluence Strength** — Counts how many of the three kernels (Fast, Medium, Slow) have their trend aligned with the Medium's direction. Score 3 = TRIPLE BULL/BEAR, 2 = STRONG, 1 = WEAK, 0 = NEUTRAL.


[b]🟦 ALERT CONDITIONS[/b]

Six opt-in alert conditions, each gated by its own toggle:

| Alert | Fires When |
|---|---|
| Bull Crossover | Fast line crosses above Slow line |
| Bear Crossover | Fast line crosses below Slow line |
| Trend Up | Medium kernel trend flips to rising |
| Trend Down | Medium kernel trend flips to falling |
| Triple Bullish | Fast > Medium > Slow AND Medium rising |
| Triple Bearish | Fast < Medium < Slow AND Medium falling |

All alerts use `alertcondition()` for maximum compatibility with TradingView's alert system including webhooks.


[b]🟦 RECOMMENDED PRESETS[/b]

| Style | Fast bw | Med bw | Slow bw | Phase | Med Filter | Chart |
|---|---|---|---|---|---|---|
| Scalper | 4–8 | 8–16 | 16–32 | 1 | No Filter | 1m–5m |
| Day Trader | 8–12 | 14–24 | 24–48 | 2 | Smooth | 15m–1h |
| Swing | 16–24 | 24–40 | 48–80 | 2 | Smooth | 4h–1D |
| Position | 24–48 | 40–80 | 80–200 | 3 | Smooth | 1D–1W |


[b]🟦 COMPATIBILITY[/b]

- Pine Script v6
- All exchanges, all asset classes (crypto, forex, equities, commodities)
- All timeframes (1 minute through Monthly)
- No exchange-specific logic — fully deterministic


[b]🟦 TECHNICAL NOTES[/b]

- **Library dependency** — `import a_jabbaroff/KernelLens/1` — all kernel regression math is delegated to the library
- **Plot budget** — 5 plots + 2 fills + 10 plotshapes = well under Pine's 64-plot limit
- **Table** — Single `var table` created once on `barstate.islast`, zero historical overhead
- **No persistent drawing objects** — no `box.new`, `label.new`, `line.new` — no garbage collection needed
- **Non-repainting** — inherits from the library's `_phase` parameter; no `request.security`, no lookahead
- **Volume-intensity** — uses HMA-smoothed normalized volume (33-bar window) for adaptive transparency


[b]🟦 DISCLAIMER[/b]

Meridian Lens PRO is a technical analysis overlay indicator built on the KernelLens Nadaraya–Watson regression library. It is provided solely for educational and research purposes and does not constitute financial, investment, or trading advice.

Kernel regression is a local smoothing technique. It estimates the mean of a source series in the neighborhood of the current bar based on historical data, but it does not predict future prices, does not generate trading signals on its own, and does not guarantee the profitability of any strategy built on top of its output.

Past performance of any model does not guarantee future results. Markets contain systemic risks that cannot be eliminated by any amount of mathematical rigor. Responsibility for any trading decisions rests entirely with the user. Always apply sound capital management, conduct your own independent analysis, and never risk capital you are not prepared to lose.

The author assumes no liability for direct or indirect losses incurred through the use of Meridian Lens or the underlying KernelLens library.

## Source Code

````pine
//@version=6

// ═══════════════════════════════════════════════════════════════════════════════
//
//  Meridian Lens — Multi Kernel Trend Indicator
//
//  Author      : a_jabbaroff
//  License     : Mozilla Public License 2.0
//  Version     : 1.0.0
//  PineScript  : v6
//  Library     : import a_jabbaroff/KernelLens/1
//
// ─── Abstract ────────────────────────────────────────────────────────────────
//
//  Meridian Lens is a multi kernel trend indicator built on the KernelLens
//  Nadaraya–Watson regression library.  Three independently configurable
//  kernel lines — Fast, Medium, and Slow — cover the full reactivity
//  spectrum from scalping to position trading.  Each line accepts any of the
//  eight kernel families (Rational Quadratic, Gaussian, Periodic, Locally
//  Periodic, Epanechnikov, Tricube, Triangular, Cosine) and any of the three
//  filter modes (Raw / Smooth / Zero Lag).
//
//  The visual layer applies a volume-intensity-adaptive rendering pipeline:
//  the Medium line is drawn as the primary trend reference with gradient-
//  filled trailing bands on the bullish and bearish sides, the Fast and
//  Slow lines are supporting references for crossover logic, and every
//  component is colored from the active theme palette (ten themes drawn
//  from the Apex design system).
//
//  The PRO dashboard is theme-aware and supports Dark and Light display
//  modes, updating in real time on the last bar with zero historical
//  overhead.  Six alert conditions cover crossover events, trend changes,
//  and triple-line confluence — each gated by its own opt-in toggle.
//
// ═══════════════════════════════════════════════════════════════════════════════

indicator("Meridian Lens", "MR Lens", overlay = true, max_bars_back = 5000)

import a_jabbaroff/KernelLens/1 as kl


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 0   —   CONSTANTS & GROUP NAMES
// ═══════════════════════════════════════════════════════════════════════════════

const string GRP_SRC    = "Source 🔹"
const string GRP_THEME  = "Theme 🔹"
const string GRP_FAST   = "Fast Kernel 🔹"
const string GRP_MED    = "Medium Kernel 🔹"
const string GRP_SLOW   = "Slow Kernel 🔹"
const string GRP_VIS    = "Volume Intensity 🔹"
const string GRP_BANDS  = "Trailing Bands 🔹"
const string GRP_SIG    = "Signal Labels 🔹"
const string GRP_DASH   = "Dashboard 🔹"
const string GRP_ALERT  = "Alerts 🔹"

// Kernel type dropdown options (must match Meridian Lens constants exactly)
const string KRN_RQ    = "Rational Quadratic"
const string KRN_GAUSS = "Gaussian"
const string KRN_PER   = "Periodic"
const string KRN_LP    = "Locally Periodic"
const string KRN_EPA   = "Epanechnikov"
const string KRN_TRI   = "Tricube"
const string KRN_TRG   = "Triangular"
const string KRN_COS   = "Cosine"

// Filter mode options (must match Meridian Lens constants exactly)
const string FLT_NONE  = "No Filter"
const string FLT_SM    = "Smooth"
const string FLT_ZL    = "Zero Lag"


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 1   —   INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Source ──────────────────────────────────────────────────────────────────
src = input.source(close, "Source", group = GRP_SRC,
     tooltip = "Price series feeding every kernel. Typical choices: close, hl2, ohlc4.")


// ─── Theme ───────────────────────────────────────────────────────────────────
themeChoice = input.string("Focus", "Theme",
     options = ["Prism", "Focus", "Solar", "Frost", "Laser", "Aurora", "Plasma", "Bloom", "Eclipse", "Carbon"],
     group = GRP_THEME,
     tooltip = "Ten cohesive color palettes tuned to the Meridian Lens optical brand. One selection drives every visual component: kernel lines, trailing bands, signal labels, dashboard accents.\n\nPrism — Forest green + crimson red (classic)\nFocus — Cyan steel + deep orange (default)\nSolar — Warm amber + indigo red\nFrost — Sky blue + soft lavender\nLaser — Neon lime + hot crimson\nAurora — Bright gold + scarlet\nPlasma — Electric aqua + magenta\nBloom — Mint green + hot pink\nEclipse — Deep navy + dark crimson\nCarbon — Near-black + silver grey")


// ─── Fast Kernel ─────────────────────────────────────────────────────────────
showFast = input.bool(true, "Show Fast Line", group = GRP_FAST,
     tooltip = "Toggle the Fast kernel line rendering on the chart.\nDisable to hide it completely — computation still runs for crossover detection.\n\nFast line is typically the most reactive of the three and is used for short-term entry timing.")

fastType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_FAST,
     tooltip = "Kernel family used for the Fast line.\n\nRational Quadratic — multi-scale mixer, α controls stretch\nGaussian / RBF — canonical smoother, infinitely differentiable\nPeriodic — resonates with repetition distance p\nLocally Periodic — periodic × gaussian (seasonal + trend)\nEpanechnikov — MSE-optimal, compact support\nTricube — LOWESS standard, near-Gaussian\nTriangular — simplest compact kernel\nCosine — raised-cosine, smooth boundary")

fastBw = input.int(8, "Bandwidth", minval = 2, step = 1, group = GRP_FAST,
     tooltip = "Kernel scale ℓ.\n\nSmaller = tighter fit, noisier, more reactive.\nLarger = smoother curve, more stable, slower.\n\nRecommended ranges by style:\nScalper — 4–10\nDay trader — 12–24\nSwing — 24–48\nPosition — 48–100")

fastAlpha = input.float(1.0, "Shape α (RQ only)", minval = 0.01, step = 0.25, group = GRP_FAST,
     tooltip = "Rational Quadratic shape parameter α.\nIgnored by other kernels.\n\nα → ∞ — collapses to pure Gaussian\nα → 0⁺ — stretches the curve over longer length scales\nα = 1 — balanced default (equal multi-scale weight)\nα = 2–5 — moderate long-range emphasis\nα > 10 — heavy long-range smoothing")

fastPeriod = input.int(20, "Period (P / LP)", minval = 1, group = GRP_FAST,
     tooltip = "Repetition distance p in bars.\nUsed only by Periodic and Locally Periodic kernels.\n\nTypical values:\n20 — intraday / daily cycle\n52 — weekly cycle\n60 — 1-hour cycle on 1m chart\n\nIgnored by the other six kernel families.")

fastPhase = input.int(2, "Phase", minval = 0, group = GRP_FAST,
     tooltip = "Non-repainting offset — kernel center shifted by this many bars.\n\n0 = live estimate, flickers on the current bar\n1 = 1-bar lag, non-repainting once confirmed\n2 = recommended balance (default)\n3+ = extra margin against erratic ticks, higher lag\n\nHistorical plots are immutable at every phase value.")

fastFilter = input.string(FLT_NONE, "Filter",
     options = [FLT_NONE, FLT_SM, FLT_ZL],
     group   = GRP_FAST,
     tooltip = "Filter layer applied on top of the raw kernel estimate.\n\nNo Filter — single-pass, most reactive\nSmooth — double-pass, more stable, adds lag\nZero Lag — Ehlers de-lag trick (2·raw − smooth), tracks price tightly")

fastWidth = input.int(1, "Line Width", minval = 1, maxval = 6, group = GRP_FAST,
     tooltip = "Thickness of the Fast kernel line in pixels.\n\n1 — thin, minimal (default — Fast is a support line)\n2 — standard\n3 — bold\n4+ — extra prominence\n\nFast line typically stays thin to avoid visual clutter against the Medium reference.")


// ─── Medium Kernel ───────────────────────────────────────────────────────────
showMedium = input.bool(true, "Show Medium Line", group = GRP_MED,
     tooltip = "Toggle the Medium kernel line rendering on the chart.\nDisable to hide the main trend line.\n\nThe Medium line drives the trailing bands, signal labels, and trend direction. Hiding it also hides the trailing bands that anchor to it.")

medType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_MED,
     tooltip = "Kernel family used for the Medium line.\n\nThe Medium line is the primary trend reference — it drives the trailing bands, the trend direction, and the dashboard trend cell.\n\nRecommended: Rational Quadratic (versatile) or Gaussian (clean).")

medBw = input.int(16, "Bandwidth", minval = 2, step = 1, group = GRP_MED,
     tooltip = "Kernel scale ℓ for the Medium line.\n\nShould be larger than Fast Bandwidth and smaller than Slow Bandwidth to preserve the Fast < Medium < Slow hierarchy for crossover logic.\n\nRecommended ranges:\nScalper — 10–20\nDay trader — 14–24\nSwing — 24–40\nPosition — 40–80")

medAlpha = input.float(1.0, "Shape α (RQ only)", minval = 0.01, step = 0.25, group = GRP_MED,
     tooltip = "Rational Quadratic shape parameter α for the Medium line.\nIgnored by other kernels.\n\nα = 1 — balanced default\nα = 2–5 — moderate long-range emphasis (good for swing trades)\nα > 10 — heavy long-range smoothing")

medPeriod = input.int(20, "Period (P / LP)", minval = 1, group = GRP_MED,
     tooltip = "Repetition distance p in bars for the Medium line's Periodic / Locally Periodic kernel.\nIgnored by other kernels.")

medPhase = input.int(2, "Phase", minval = 0, group = GRP_MED,
     tooltip = "Non-repainting offset — kernel center shifted by this many bars.\n\n0 = live estimate, flickers on the current bar\n1 = 1-bar lag, non-repainting once confirmed\n2 = recommended balance (default)\n3+ = extra stability, more lag\n\nHistorical plots are immutable at every phase value.")

medFilter = input.string(FLT_SM, "Filter",
     options = [FLT_NONE, FLT_SM, FLT_ZL],
     group   = GRP_MED,
     tooltip = "Filter layer for the Medium line.\n\nNo Filter — most reactive\nSmooth — recommended for the primary trend reference\nZero Lag — tracks price tightly, noisier")

medWidth = input.int(3, "Line Width", minval = 1, maxval = 6, group = GRP_MED,
     tooltip = "Thickness of the Medium kernel line in pixels.\n\n1 — thin\n2 — standard\n3 — bold (default — Medium is the primary trend reference)\n4+ — extra prominence\n\nThe Medium line drives the trailing bands and trend cell, so a thicker line helps it stand out as the primary visual anchor.")


// ─── Slow Kernel ─────────────────────────────────────────────────────────────
showSlow = input.bool(true, "Show Slow Line", group = GRP_SLOW,
     tooltip = "Toggle the Slow kernel line rendering on the chart.\nDisable to hide it completely — computation still runs for crossover detection.\n\nSlow line is typically the most stable of the three and is used as the macro trend reference.")

slowType = input.string(KRN_RQ, "Kernel Type",
     options = [KRN_RQ, KRN_GAUSS, KRN_PER, KRN_LP, KRN_EPA, KRN_TRI, KRN_TRG, KRN_COS],
     group   = GRP_SLOW,
     tooltip = "Kernel family used for the Slow line.\n\nThe Slow line provides the macro trend reference for crossover signals (Fast × Slow). Use a smooth, stable kernel — Rational Quadratic or Gaussian recommended.")

slowBw = input.int(32, "Bandwidth", minval = 2, step = 1, group = GRP_SLOW,
     tooltip = "Kernel scale ℓ for the Slow line.\n\nShould be the largest of the three bandwidths to produce a stable macro-trend reference.\n\nRecommended ranges:\nScalper — 20–40\nDay trader — 24–48\nSwing — 48–80\nPosition — 80–200")

slowAlpha = input.float(2.0, "Shape α (RQ only)", minval = 0.01, step = 0.25, group = GRP_SLOW,
     tooltip = "Rational Quadratic shape parameter α for the Slow line.\nIgnored by other kernels.\n\nHigher α (2–5) is recommended for the Slow line — it emphasizes long-range smoothing and produces a clean macro-trend curve.")

slowPeriod = input.int(20, "Period (P / LP)", minval = 1, group = GRP_SLOW,
     tooltip = "Repetition distance p in bars for the Slow line's Periodic / Locally Periodic kernel.\nIgnored by other kernels.")

slowPhase = input.int(2, "Phase", minval = 0, group = GRP_SLOW,
     tooltip = "Non-repainting offset — kernel center shifted by this many bars.\n\n0 = live estimate, flickers on the current bar\n1 = 1-bar lag, non-repainting once confirmed\n2 = recommended balance (default)\n3+ = extra stability for long-term analysis\n\nHistorical plots are immutable at every phase value.")

slowFilter = input.string(FLT_SM, "Filter",
     options = [FLT_NONE, FLT_SM, FLT_ZL],
     group   = GRP_SLOW,
     tooltip = "Filter layer for the Slow line.\n\nNo Filter — most reactive\nSmooth — recommended for the stable macro reference\nZero Lag — tracks price tightly")

slowWidth = input.int(2, "Line Width", minval = 1, maxval = 6, group = GRP_SLOW,
     tooltip = "Thickness of the Slow kernel line in pixels.\n\n1 — thin\n2 — standard (default — Slow is a macro reference)\n3 — bold\n4+ — extra prominence\n\nSlow line is typically kept moderate — thinner than Medium but thicker than Fast — to mark the macro trend without overpowering the primary reference.")


// ─── Volume Intensity ─────────────────────────────────────────────────────────
volIntensity = input.bool(true, "Adaptive Color", group = GRP_VIS,
     tooltip = "Adapt line transparency to the current volume reading.\n\nOn — bright line on high volume, dim line on low volume (dynamic)\nOff — fixed 50 % transparency at all times (static)\n\nWhen enabled, the line acts as a confidence meter: bright = volume-confirmed, dim = low-volume drift.")

volFilt = input.int(60, "Intensity Strength", minval = 1, maxval = 99, group = GRP_VIS,
     tooltip = "Volume-intensity sensitivity cap (1–99).\n\nLower — gentler response, line stays brighter more of the time\nHigher — sharper response, line dims faster on weak volume\n\nDefault 70 is a balanced starting point. Used only when Volume-Intensity Adaptive Color is enabled.")


// ─── Trailing Bands ──────────────────────────────────────────────────────────
bandsOn = input.bool(true, "Show Trailing Bands", group = GRP_BANDS,
     tooltip = "Draws gradient-filled bands on the bullish / bearish side of the Medium kernel line.\nBands widen or narrow with the rolling average candle body size.")

bandDistMult = input.float(2.0, "Band Distance Multiplier", minval = 0.5, step = 0.5, group = GRP_BANDS,
     tooltip = "Multiplier applied to the 100-bar average candle body size.\nLarger = wider bands.")


// ─── Signal Labels ───────────────────────────────────────────────────────────
showFastSig = input.bool(false, "Fast Line Signals", group = GRP_SIG,
     tooltip = "Plot a minimal ▲ / ▼ marker when the Fast kernel line flips direction.\n\nSmaller and fainter than the main Medium signal — intended as an early warning cue before the Medium line confirms a trend change.\n\nDefault: OFF. Fast flips frequently on noisy charts — enable only when you want early-entry timing.")

showMedSig = input.bool(true, "Medium Line Signals", group = GRP_SIG,
     tooltip = "Plot the primary ▲ / ▼ trend-flip arrows when the Medium kernel line changes direction.\n\nThis is the main signal of the indicator — rendered with a 3-layer neon glow halo for maximum visibility.\n\n▲ below the bar — Medium flipped to uptrend\n▼ above the bar — Medium flipped to downtrend")

showSlowSig = input.bool(true, "Slow Line Signals", group = GRP_SIG,
     tooltip = "Plot a minimal ▲ / ▼ marker when the Slow kernel line flips direction.\n\nSmaller and fainter than the main Medium signal — intended as a macro trend-change cue that complements the Medium's main signals.\n\nDefault: ON. Slow flips are rare and meaningful — worth keeping visible.")

showSigGlow = input.bool(true, "Glow Effect", group = GRP_SIG,
     tooltip = "Three-layer neon halo wrapped around each Medium signal arrow. The outer layer is very transparent, the middle layer is semi-transparent, and the inner core is fully opaque — creating a clean luminous glow on dark charts.\n\nApplies only to the Medium signal. Fast / Slow markers stay minimal.")


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
alertBullCross = input.bool(true, "Bull Crossover (Fast × Slow)", group = GRP_ALERT,
     tooltip = "Fire an alert when the Fast line crosses above the Slow line.\n\nThis is the classic MA crossover signal adapted to kernel regression — faster reaction than a traditional moving-average crossover because kernels track price more tightly.\n\nDisable to suppress bull crossover alerts only.")

alertBearCross = input.bool(true, "Bear Crossover (Fast × Slow)", group = GRP_ALERT,
     tooltip = "Fire an alert when the Fast line crosses below the Slow line.\n\nThe bearish counterpart of Bull Crossover — signals momentum shift to the downside.\n\nDisable to suppress bear crossover alerts only.")

alertTrendUp = input.bool(true, "Trend Up (Medium direction)", group = GRP_ALERT,
     tooltip = "Fire an alert when the Medium line's direction flips to up.\n\nThis is a finer-grained signal than crossover — it captures every time the primary trend line changes slope from falling to rising, even without a Fast × Slow crossover.\n\nUseful for early entries and trailing-stop logic.")

alertTrendDn = input.bool(true, "Trend Down (Medium direction)", group = GRP_ALERT,
     tooltip = "Fire an alert when the Medium line's direction flips to down.\n\nThe bearish counterpart of Trend Up — captures every slope reversal on the primary trend line.\n\nUseful for early exits and short-entry timing.")

alertConflBull = input.bool(true, "Triple Bullish Confluence", group = GRP_ALERT,
     tooltip = "Fire an alert when all three kernel lines align bullishly:\n\nFast > Medium > Slow\nAND Medium line is rising\n\nThis is the strongest bullish signal the indicator produces — three independent kernels confirming the same direction simultaneously. Use it for high-conviction entries.")

alertConflBear = input.bool(true, "Triple Bearish Confluence", group = GRP_ALERT,
     tooltip = "Fire an alert when all three kernel lines align bearishly:\n\nFast < Medium < Slow\nAND Medium line is falling\n\nThis is the strongest bearish signal the indicator produces — three independent kernels confirming the same direction simultaneously. Use it for high-conviction short entries or long exits.")


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 2   —   THEME RESOLVER   (ten themes from Apex)
// ═══════════════════════════════════════════════════════════════════════════════
// Each theme defines two axis colors:
//   thBull — bullish side  (up trend, bull crossover, bullish confluence)
//   thBear — bearish side  (down trend, bear crossover, bearish confluence)

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

// Neutral / accent color — used for Fast and Slow support lines
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

// Dashboard theme colors (Dark vs Light)
color dashBg      = displayMode == "Dark" ? #0A0A0A : #FFFFFF
color dashBgAlt   = displayMode == "Dark" ? #141414 : #F5F5F5
color dashFg      = displayMode == "Dark" ? #E0E0E0 : #1A1A1A
color dashBorder  = displayMode == "Dark" ? #2A2A2A : #DCDCDC
color dashHeader  = color.new(thBull, 0)
color dashSection = displayMode == "Dark" ? #1A1A1A : #EEEEEE


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 3   —   KERNEL COMPUTATIONS   (via Meridian Lens library)
// ═══════════════════════════════════════════════════════════════════════════════

fastLine = kl.estimate(fastType, src, fastBw, fastAlpha, fastPeriod, fastPhase, fastFilter)
medLine  = kl.estimate(medType,  src, medBw,  medAlpha,  medPeriod,  medPhase,  medFilter)
slowLine = kl.estimate(slowType, src, slowBw, slowAlpha, slowPeriod, slowPhase, slowFilter)

// Trend state per line (+1 up / −1 down / 0 flat)
fastTrend = kl.trendState(fastLine, 1)
medTrend  = kl.trendState(medLine,  1)
slowTrend = kl.trendState(slowLine, 1)

// Medium direction drives the primary visual layer
int dir = medLine > medLine[1] ? 1 : -1

// Crossover signals — Fast × Slow
int crossFS = kl.crossSignal(fastLine, slowLine)

// Triple-line confluence — all three aligned AND medium trending
bool confluenceBull = fastLine > medLine and medLine > slowLine and medTrend == 1
bool confluenceBear = fastLine < medLine and medLine < slowLine and medTrend == -1

// Trend change events (for alerts)
bool trendUpEvent = medTrend == 1  and medTrend[1] != 1
bool trendDnEvent = medTrend == -1 and medTrend[1] != -1

// Confluence change events (for alerts)
bool conflBullEvent = confluenceBull and not confluenceBull[1]
bool conflBearEvent = confluenceBear and not confluenceBear[1]


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 4   —   VISUAL LAYER   (LINE_STYLE technique)
// ═══════════════════════════════════════════════════════════════════════════════
// Adapted from AlgoAlpha's Smoothed Gaussian Trend Filter visual pipeline:
// volume-intensity transparency, gradient trailing bands, adaptive bull/bear
// coloring, and signal labels at trend-flip points.  The ranging / mid-trend
// gray logic has been removed — direction is read directly from the Medium
// line's slope via kl.trendState.

// ─── Volume intensity — adaptive transparency ────────────────────────────────
const int VOL_WIN = 33
float s_vol = ta.hma((volume - ta.lowest(volume, VOL_WIN)) / (ta.highest(volume, VOL_WIN) - ta.lowest(volume, VOL_WIN)), 4)
float vTrans = math.min(100 - s_vol * 100, volFilt)
float aTrans = volIntensity ? vTrans : 50.0

// ─── Rolling candle body distance for trailing bands ─────────────────────────
float dist = ta.sma(math.abs(close - open), 100)

// ─── Adaptive Medium color ───────────────────────────────────────────────────
color medColor = dir > 0 ? color.new(thBull, aTrans) : color.new(thBear, aTrans)

// ─── Fast and Slow support colors ────────────────────────────────────────────
color fastColor = color.new(thAccent, 40)
color slowColor = color.new(thAccent, 20)

// ─── Primary Medium plot ─────────────────────────────────────────────────────
plot_main = plot(showMedium ? medLine : na, "Medium",
     color = medColor, linewidth = medWidth)

// ─── Fast and Slow support plots ─────────────────────────────────────────────
plot(showFast ? fastLine : na, "Fast",
     color = fastColor, linewidth = fastWidth, style = plot.style_line)

plot(showSlow ? slowLine : na, "Slow",
     color = slowColor, linewidth = slowWidth, style = plot.style_line)

// ─── Trailing bands (gradient fill around Medium) ────────────────────────────
plot_bull = plot(bandsOn and dir > 0 and showMedium ? medLine - dist * bandDistMult : na,
     "Bull Band", style = plot.style_linebr, color = color.new(thBull, 90))

plot_bear = plot(bandsOn and dir < 0 and showMedium ? medLine + dist * bandDistMult : na,
     "Bear Band", style = plot.style_linebr, color = color.new(thBear, 90))

fill(plot_main, plot_bull, medLine, medLine - dist * bandDistMult,
     color.new(thBull, aTrans), color.new(thBull, 93))

fill(plot_main, plot_bear, medLine + dist * bandDistMult, medLine,
     color.new(thBear, 93), color.new(thBear, aTrans))

// ─── Signal labels at trend flips (3-layer neon glow arrows) ────────────────
// Adapted from the SIGNAL.pine 3-layer pattern:
//   • Outer halo  — size.huge, 80 % transparent  (widest, softest)
//   • Middle halo — size.large, 50 % transparent (mid-tier glow)
//   • Core arrow  — size.normal, 0 % transparent (bright center)
// The three plotshapes stack on the same bar, producing a luminous halo
// around the triangle.  Arrows use the active theme's bull / bear colors.

bool bullSig = showMedSig and dir > 0 and dir[1] < 0
bool bearSig = showMedSig and dir < 0 and dir[1] > 0

// ─── Fast / Slow minimal signals (early warning + macro shift) ───
// Fire on the first bar when the kernel's trendState flips to bull / bear.
// Rendered as tiny faded arrows — visually subordinate to the Medium glow.
bool fastBullSig = showFastSig and fastTrend ==  1 and fastTrend[1] !=  1
bool fastBearSig = showFastSig and fastTrend == -1 and fastTrend[1] != -1
bool slowBullSig = showSlowSig and slowTrend ==  1 and slowTrend[1] !=  1
bool slowBearSig = showSlowSig and slowTrend == -1 and slowTrend[1] != -1

// ─── Fixed 3-layer scale (Normal preset) ────────────────────────────────
//   Outer glow  — size.large, 80 % transparent
//   Middle glow — size.normal, 50 % transparent
//   Core arrow  — size.small, 0 % transparent

// ── Bullish ▲ — outer glow halo (below bar) ───────────────────────────────
plotshape(showSigGlow and bullSig, "Bull Glow Outer",
     style = shape.triangleup, location = location.belowbar,
     color = color.new(thBull, 80), size = size.large)

// ── Bullish ▲ — middle glow halo ──────────────────────────────────────────
plotshape(showSigGlow and bullSig, "Bull Glow Middle",
     style = shape.triangleup, location = location.belowbar,
     color = color.new(thBull, 50), size = size.normal)

// ── Bullish ▲ — core arrow ────────────────────────────────────────────────
plotshape(bullSig, "Bull Arrow",
     style = shape.triangleup, location = location.belowbar,
     color = color.new(thBull, 0), size = size.small)

// ── Bearish ▼ — outer glow halo (above bar) ───────────────────────────────
plotshape(showSigGlow and bearSig, "Bear Glow Outer",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(thBear, 80), size = size.large)

// ── Bearish ▼ — middle glow halo ──────────────────────────────────────────
plotshape(showSigGlow and bearSig, "Bear Glow Middle",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(thBear, 50), size = size.normal)

// ── Bearish ▼ — core arrow ────────────────────────────────────────────────
plotshape(bearSig, "Bear Arrow",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(thBear, 0), size = size.small)

// ─── Fast / Slow minimal signal arrows (no glow, tiny, faded) ────────────
// Visually subordinate to the Medium signals — early-warning / macro-shift cue.
plotshape(fastBullSig, "Fast Bull Mark",
     style = shape.triangleup,   location = location.belowbar,
     color = color.new(thBull, 40), size = size.tiny)
plotshape(fastBearSig, "Fast Bear Mark",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(thBear, 40), size = size.tiny)
plotshape(slowBullSig, "Slow Bull Mark",
     style = shape.triangleup,   location = location.belowbar,
     color = color.new(thBull, 40), size = size.tiny)
plotshape(slowBearSig, "Slow Bear Mark",
     style = shape.triangledown, location = location.abovebar,
     color = color.new(thBear, 40), size = size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 5   —   PRO DASHBOARD   (theme-aware, Dark / Light)
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

// Confluence strength (0..3) — number of kernels aligned with medium dir
int strength = (dir != 0 ? ((fastTrend == dir ? 1 : 0) + (medTrend == dir ? 1 : 0) + (slowTrend == dir ? 1 : 0)) : 0)
string strBar  = strength == 3 ? "▰▰▰" : strength == 2 ? "▰▰▱" : strength == 1 ? "▰▱▱" : "▱▱▱"
string strLbl  = strength == 3 ? (dir > 0 ? "TRIPLE BULL" : "TRIPLE BEAR") : strength == 2 ? "STRONG" : strength == 1 ? "WEAK" : "NEUTRAL"
color  strCol  = dir > 0 ? thBull : thBear

if barstate.islast and showDash
    dash := table.new(posV, 2, 11,
         bgcolor      = dashBg,
         border_color = dashBorder,
         border_width = 1,
         frame_color  = dashBorder,
         frame_width  = 2)

    // ─── Row 0 — Header ───
    table.cell(dash, 0, 0, "MERIDIAN LENS",
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
    table.cell(dash, 1, 2, medType,
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 3 — Section divider: KERNELS ───
    table.cell(dash, 0, 3, "KERNELS",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 3, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 4 — Fast (bg) ───
    color fastAccent = fastTrend == 1 ? thBull : fastTrend == -1 ? thBear : dashFg
    table.cell(dash, 0, 4, "Fast",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 4, f_arrow(fastTrend) + "  " + f_fmt(fastLine),
         text_color = fastAccent, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 5 — Medium (bgAlt) ───
    color medAccent = medTrend == 1 ? thBull : medTrend == -1 ? thBear : dashFg
    table.cell(dash, 0, 5, "Medium",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 5, f_arrow(medTrend) + "  " + f_fmt(medLine),
         text_color = medAccent, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 6 — Slow (bg) ───
    color slowAccent = slowTrend == 1 ? thBull : slowTrend == -1 ? thBear : dashFg
    table.cell(dash, 0, 6, "Slow",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 6, f_arrow(slowTrend) + "  " + f_fmt(slowLine),
         text_color = slowAccent, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 7 — Section divider: SIGNALS ───
    table.cell(dash, 0, 7, "SIGNALS",
         text_color = dashHeader, bgcolor = dashSection, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 7, "",
         bgcolor = dashSection, text_size = sizV)

    // ─── Row 8 — Trend (bgAlt) ───
    string trendText = dir > 0 ? "▲ BULL" : dir < 0 ? "▼ BEAR" : "━ FLAT"
    color  trendAcc  = dir > 0 ? thBull : dir < 0 ? thBear : dashFg
    table.cell(dash, 0, 8, "Trend",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 8, trendText,
         text_color = trendAcc, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 9 — Cross (bg) ───
    string crossText = crossFS == 1 ? "↑ UP" : crossFS == -1 ? "↓ DOWN" : "—"
    color  crossAcc  = crossFS == 1 ? thBull : crossFS == -1 ? thBear : dashFg
    table.cell(dash, 0, 9, "Cross",
         text_color = dashFg, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 9, crossText,
         text_color = crossAcc, bgcolor = dashBg, text_size = sizV,
         text_halign = text.align_right)

    // ─── Row 10 — Strength (bgAlt) ───
    table.cell(dash, 0, 10, "Strength",
         text_color = dashFg, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_left)
    table.cell(dash, 1, 10, strBar + "  " + strLbl,
         text_color = strCol, bgcolor = dashBgAlt, text_size = sizV,
         text_halign = text.align_right)


// ═══════════════════════════════════════════════════════════════════════════════
//   SECTION 6   —   ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(alertBullCross and crossFS == 1,
     title   = "Meridian Lens — Bull Crossover",
     message = "Meridian Lens: Fast crossed above Slow — bullish crossover confirmed.")

alertcondition(alertBearCross and crossFS == -1,
     title   = "Meridian Lens — Bear Crossover",
     message = "Meridian Lens: Fast crossed below Slow — bearish crossover confirmed.")

alertcondition(alertTrendUp and trendUpEvent,
     title   = "Meridian Lens — Trend Up",
     message = "Meridian Lens: Medium kernel trend flipped to Up.")

alertcondition(alertTrendDn and trendDnEvent,
     title   = "Meridian Lens — Trend Down",
     message = "Meridian Lens: Medium kernel trend flipped to Down.")

alertcondition(alertConflBull and conflBullEvent,
     title   = "Meridian Lens — Triple Bullish Confluence",
     message = "Meridian Lens: Fast > Medium > Slow AND Medium rising — triple bullish confluence.")

alertcondition(alertConflBear and conflBearEvent,
     title   = "Meridian Lens — Triple Bearish Confluence",
     message = "Meridian Lens: Fast < Medium < Slow AND Medium falling — triple bearish confluence.")


// ═══════════════════════════════════════════════════════════════════════════════
//   END CODE
// ═══════════════════════════════════════════════════════════════════════════════
````

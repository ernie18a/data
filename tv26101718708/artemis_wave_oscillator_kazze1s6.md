# Artemis Wave Oscillator

- url: https://www.tradingview.com/script/KaZZe1s6-Artemis-Wave-Oscillator/
- type: indicator
- pine_id: PUB;b204d9dd14dc4084a8f5c6f461079c20
- version: 1.0

## Description

[b]🟦 Artemis Wave Oscillator[/b] is a Pine v6 reimagination of the classical WaveTrend family, built on a Welford running-stdev channel and EMA-smoothed normalization. Unlike fixed-band WaveTrend variants that ship with hard-coded levels, the engine continuously rescales itself against its own dispersion — producing a momentum curve that stays perfectly bounded between visually consistent reversion bands on every asset and every timeframe, with no manual recalibration.

The indicator integrates six analytical layers — WaveTrend core, dynamic reversion bands, histogram momentum gauge, extremity reversion dots, regular + hidden divergence detection with a Smart AI Filter, and a theme-adaptive PRO dashboard — each operating independently and rendered on a single, clean oscillator panel.


[b]🟦 HOW THE CORE ENGINE WORKS[/b]

**WaveTrend Channel**

Each bar, the engine builds an EMA-smoothed midline from the selected price aggregate over the Channel Length window. In parallel, a Welford single-pass running standard deviation measures the channel width — a numerically stable O(N) algorithm that updates the running mean and squared deviation simultaneously, preserving precision on long histories where naive sum-of-squares accumulators drift.

The raw wave is then computed as:

wave_raw = (src − chanMid) / chanDev × 100

This produces a z-score-like signal scaled to the ±100 range. Dividing by the running standard deviation normalizes the output regardless of asset volatility — BTC, EURUSD, SPY, and a small-cap stock all swing through the same band structure without parameter changes.

**EMA Smoothing**

The raw wave is then passed through an EMA of length Average Length to produce the visible `wave` line. This is the dominant responsiveness control — larger values produce a calmer curve with fewer reversion-zone touches.

**Signal Line**

An SMA of the wave (Signal Length) builds the trigger line. Crossovers between the wave and signal line mark momentum regime changes — the same convention used by classical MACD and Stochastic.

**Histogram**

The wave − signal delta is rendered as a filled area. Two opacity tiers distinguish rising momentum (brighter) from fading momentum (dimmer), so the eye picks up acceleration vs. deceleration at a glance.

**Source Selector**

Nine price aggregates are available:

| Source | Formula | Use case |
|---|---|---|
| Open | open | Open-of-bar bias |
| High | high | Top-of-range tracking |
| Low | low | Bottom-of-range tracking |
| Close | close | Standard, fastest reaction |
| OC2 | (open + close) / 2 | Body midpoint |
| HL2 | (high + low) / 2 | Body-independent midpoint |
| HLC3 | (high + low + close) / 3 | Typical mean — default |
| OHLC4 | (open + high + low + close) / 4 | Smoothest |
| HLCC4 | (high + low + 2×close) / 4 | Close-weighted |


[b]🟦 REVERSION BANDS[/b]

The user picks a single Reversion Threshold (T) — the distance from zero (in normalized wave units) beyond which the wave is considered overbought (positive side) or oversold (negative side). Three proportional tiers render automatically:

| Tier | Level | Visual |
|---|---|---|
| Inner | ±T | Outer ring of the gradient fill |
| Middle | ±T × 1.25 | Boundary between outer ring and inner extreme |
| Outer | ±T × 1.5 | Hard outer boundary of the gradient fill |

Because the bands are derived from T, they always wrap the threshold no matter how the user tunes it. A trader scaling T from 80 (volatile assets) to 150 (trending assets) keeps the visual context intact without retuning the band levels.

The Reversion Threshold itself drives three downstream features:

- Extremity Dot triggers
- The "Extremities" bar-coloring mode
- The Dashboard Zone tag (OB / MID / OS)


[b]🟦 EXTREMITY DOTS[/b]

OB / OS reversion markers — small dual-layer dots that fire when the wave crosses the signal line beyond the Reversion Threshold:

- **OS dot** (bull theme color) → wave crossed UP past −T
- **OB dot** (bear theme color) → wave crossed DOWN past +T

These are the highest-conviction mean-reversion triggers in the script. The dots use a two-track rendering — a pixel-perfect glow + core visual via `plot.style_circles`, paired with an invisible `label.style_circle` carrying a rich tooltip. Hovering on a dot surfaces:

- Direction (Crossed UP / DOWN through Signal)
- Active zone (Below −T / Above +T)
- Current wave value
- Current signal value
- Trading interpretation (mean-reversion long / short opportunity)


[b]🟦 DIVERGENCE DETECTION[/b]

Pivots are calculated using `ta.pivothigh` and `ta.pivotlow` with an arm of `Channel Length / 2`. All divergence results appear `Channel Length / 2` bars late — this is standard Pine Script pivot behavior, not a bug.

**Four divergence types:**

| Type | Price | Wave | Signal |
|---|---|---|---|
| Regular Bull (D▲) | Lower Low | Higher Low | Potential reversal up |
| Regular Bear (D▼) | Higher High | Lower High | Potential reversal down |
| Hidden Bull (H▲) | Higher Low | Lower Low | Uptrend continuation |
| Hidden Bear (H▼) | Lower High | Higher High | Downtrend continuation |

Regular divergence uses solid lines (width 2). Hidden divergence uses dashed lines (width 1) — the thinner, dashed style makes the continuation signal visually quieter than the reversal signal, matching their respective conviction tiers. Labels use bracketed symbols (D▲ / D▼ / H▲ / H▼) and each carries a tooltip-rich hover with price + wave context.

**Smart Divergence Filter (AI)**

An optional pre-filter that rejects low-quality divergences before they render. Three independent gates:

1. **Min Wave Swing** — minimum oscillator swing between the two pivots (default: 5 units). Drops noise-level differences where the wave barely moved between pivots.
2. **Min Price Swing (%)** — minimum price swing between pivots as a percentage of the recent `Channel Length × 4` high-low range (default: 0.3%). Drops divergences where price barely moved relative to recent volatility.
3. **Zone Confirmation** — the wave at the current pivot must sit in the matching reversion half:
   - Bullish divergence → wave at LL pivot ≤ −T × 0.5 (oversold half)
   - Bearish divergence → wave at HH pivot ≥ +T × 0.5 (overbought half)

This encodes the classical "best divergences form at extremes" rule using the wave value itself as the gate — no MFI or volume input required.

When the master toggle is OFF (default), all detected divergences render. When ON, only divergences that clear all three gates survive. The filter applies identically to both chart rendering and alert conditions — no mismatch between visual and alert signals.


[b]🟦 HISTOGRAM[/b]

The wave − signal histogram is rendered as a filled area between the histogram value and the zero line. Two opacity tiers per side:

| State | Color | Opacity |
|---|---|---|
| Bull, rising | thBull | Rising Opacity (default 60) |
| Bull, fading | thBull | Fading Opacity (default 40) |
| Bear, rising | thBear | Rising Opacity (default 60) |
| Bear, fading | thBear | Fading Opacity (default 40) |

Rising bars are the most actionable visual cue — they mark momentum that is accelerating in the active direction. Fading bars indicate momentum stalling.


[b]🟦 BAR COLORING[/b]

Five mutually exclusive modes apply a wave-driven color to every price bar on the chart:

| Mode | Behavior |
|---|---|
| None | Leave bars untouched (default) |
| Midline Cross | Bull above zero, bear below zero |
| Extremities | Bull beyond +T, bear beyond −T, neutral elsewhere |
| Reversions | Bull on OS dot trigger, bear on OB dot trigger |
| Slope | Bull when wave > signal, bear when wave < signal |

Colors are pulled from the active theme — no per-mode color picker needed.


[b]🟦 DASHBOARD[/b]

A compact 2-column, 7-row data panel renders on the last bar when enabled. Every value derives from variables already computed upstream, so the dashboard adds zero overhead until the final bar.

| Row | Left | Right |
|---|---|---|
| Header | Artemis Wave | ▲ BULL / ▼ BEAR / ■ NEUTRAL |
| Wave | Wave | Current value + trend arrow (▲ ▼ ■) |
| Signal | Signal | Current SMA trigger value |
| Strength | Strength | 10-block monospace bar gauge |
| Zone | Zone | OB / MID / OS tag |
| Div | Div | Most recent divergence within last 50 bars (▲ REG / ▼ REG / ▲ HID / ▼ HID / —) |
| Slope | Slope | ▲ UP / ▼ DOWN / ■ FLAT |

The strength gauge normalizes `|wave − signal|` against 50 (typical mid-amplitude swing) and buckets the result into 10 monospace blocks (`█` filled, `░` empty), giving an at-a-glance read of crossover conviction.

**Theme-Adaptive Chrome**

The dashboard auto-inverts its layout based on the active theme:

- **Dark themes** (Tropic, Amber, Pastel, Cyber, Helios, Electric, Candy, Bloomberg, Solar, Royal): header and footer use a faint `thBull` tint, middle rows stay solid dark, text uses full-saturation `thBull`. Border uses `thBull` at 20% transparency for strong theme presence.
- **Light themes** (Midnight, Graphite): backgrounds flip to white, text stays `thBull` (which is itself dark on these themes), border uses `thBull` at 40% transparency.

This guarantees text legibility against every palette without per-theme manual tuning.

**Position & Size**

Six anchor slots (Top/Middle/Bottom × Left/Right) and four text sizes (Tiny / Small / Normal / Large).


[b]🟦 COLOR THEMES[/b]

Twelve cohesive palettes, each resolving to four axis colors:

| Theme | Character | Bull | Bear |
|---|---|---|---|
| Tropic | Cyan steel + deep orange | #00bcd4 | #ff6d00 |
| Amber | Warm amber + indigo blue | #ff9800 | #e53935 |
| Pastel | Sky blue + soft lavender | #4fc3f7 | #9575cd |
| Cyber | Neon lime + hot crimson | #00e676 | #ff1744 |
| Helios | Bright gold + scarlet | #ffd600 | #ef5350 |
| Electric | Electric aqua + magenta | #00e5ff | #e040fb |
| Candy | Neon green + hot pink | #69F0AE | #FF4081 |
| Bloomberg | Terminal orange + cyan | #ff8c00 | #00b0ff |
| Solar | Solarized olive + crimson | #859900 | #dc322f |
| Royal | Imperial gold + deep purple | #ffd700 | #6a0dad |
| Midnight | Deep navy + dark crimson | #0d47a1 | #b71c1c |
| Graphite | Near-black + silver grey | #1a1a1a | #757575 |

All four color roles (bull / bear / neutral / signal) change simultaneously when the theme changes. The whole script reads through these four variables — nothing below the resolver references a raw hex literal, so a single dropdown selection drives every plot, fill, dot, divergence line, dashboard cell and border.


[b]🟦 ALERT SYSTEM[/b]

Ten alert conditions, all using `alert.freq_once_per_bar_close`:

| Alert | Condition |
|---|---|
| OS Reversion | Wave crossed UP through signal while wave < −T |
| OB Reversion | Wave crossed DOWN through signal while wave > +T |
| Regular Divergence | D▲ or D▼ detected (respects Smart Filter) |
| Hidden Divergence | H▲ or H▼ detected (respects Smart Filter) |
| Bullish Trend | Wave crossed above the midline (zero) |
| Bearish Trend | Wave crossed below the midline (zero) |
| Bullish Swing | Wave × signal upward cross, regardless of zone |
| Bearish Swing | Wave × signal downward cross, regardless of zone |

Each alert fires through `alert()` so the message body carries live context — direction, current wave value, and the threshold that triggered. Divergence alerts respect the Smart Divergence Filter — if the filter is ON and a divergence is rejected visually, the alert will also not fire.


[b]🟦 SETTINGS REFERENCE[/b]

**WaveTrend Core**
- Source — 9 price aggregates. Default: HLC3
- Channel Length — EMA midline + Welford stdev lookback. Default: 10
- Average Length — EMA smoothing of the normalized wave. Default: 21
- Signal Length — SMA smoothing of the wave to build the trigger. Default: 4

**Reversion Bands**
- Reversion Threshold — 50–200, step 5. Default: 100
- Show Band Fills — Toggle. Default: ON
- Band Opacity — 0–100. Default: 30

**Histogram**
- Show Histogram — Toggle. Default: ON
- Rising Opacity — Default: 60
- Fading Opacity — Default: 40

**Extremity Dots**
- Show Extremity Dots — Toggle. Default: ON

**Divergence**
- Regular Divergence — Toggle. Default: ON
- Regular Opacity — Default: 80
- Hidden Divergence — Toggle. Default: ON
- Hidden Opacity — Default: 80
- Label Size — Tiny / Small / Normal / Large. Default: Tiny
- Smart Divergence Filter (AI) — Master toggle. Default: OFF
- Min Wave Swing — Default: 5.0
- Min Price Swing (%) — Default: 0.3%
- Require Zone Confirmation — Default: ON

**Bar Coloring**
- Bar Color Mode — None / Midline Cross / Extremities / Reversions / Slope. Default: None

**Dashboard**
- Show Dashboard — Toggle. Default: ON
- Panel Position — 6 anchor slots. Default: Middle Right
- Panel Text Size — Tiny / Small / Normal / Large. Default: Small

**Alerts**
- OS Reversion — Default: ON
- OB Reversion — Default: ON
- Regular Divergence — Default: ON
- Hidden Divergence — Default: OFF
- Bullish Trend — Default: ON
- Bearish Trend — Default: ON
- Bullish Swing — Default: OFF
- Bearish Swing — Default: OFF


[b]🟦 COMPATIBILITY[/b]

Works on all asset classes and all timeframes in TradingView Pine Script v6.

- Crypto: Spot, futures, perpetual contracts
- Forex: All pairs
- Equities: Stocks, ETFs, indices
- Commodities: Metals, energy, agriculture
- Timeframes: 1m through Monthly

The Welford running standard deviation normalizes the wave against its own dispersion, making the engine fully volatility-agnostic. The same default settings work on a 5-second BTC chart and a weekly index chart without retuning.


[b]🟦 TECHNICAL NOTES[/b]

- Pine Script v6
- `max_lines_count = 500`, `max_labels_count = 500` (divergence drawings + extremity dot hover labels)
- No repainting — all values calculated on bar close. Pivot-based divergence results appear `Channel Length / 2` bars late by design
- WaveTrend engine intentionally mirrors EliCobra's original Enhanced WaveTrend formulation — the value added by Artemis Wave is in the Pine v6 idioms, the dynamic band scaling, the divergence engine, the Smart Filter, the theme system, and the dashboard, not in altering the well-tested core curve
- UDT fields declared without defaults to comply with Pine v6's compile-time-literal requirement; objects constructed via `Bar.new(...)` and `WaveReading.new(...)`
- `var int x = int(na)` pattern used for safe persistent integer state (pivot bar indices)
- Reversion-band anchors rendered as hidden `plot()`s rather than `hline()`s — `hline()` only accepts compile-time constants, but the band levels are series values driven by the user-tunable Reversion Threshold
- Extremity Dots use a dual-track rendering: `plot.style_circles` for the pixel-perfect visual, plus a parallel invisible `label.style_circle` carrying the hover tooltip (since `plot()` does not support the `tooltip` argument)


[b]🟦 DISCLAIMER[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Past performance does not guarantee future results. Always conduct your own analysis and apply proper risk management.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// Artemis Wave Oscillator
// Author  : © a_jabbaroff
// Version : 1.0.0
// License : Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
// ❤️ Crafted with love for TradingView traders — every line here exists so
//     your next chart reads cleaner and your next trade lands sharper.
// ═══════════════════════════════════════════════════════════════════════════════
//
// DESCRIPTION
//   Artemis Wave is a Pine v6 reimagination of the classical WaveTrend family,
//   built on a running-stdev channel and EMA-smoothed normalisation. The
//   engine compresses any price aggregate into a bounded momentum curve that
//   swings between visually consistent reversion bands, plotting both the
//   primary wave and an SMA trigger line for high-confidence cross detection.
//
// COMPONENTS
//   Source Selector   — nine price aggregates (open / high / low / close /
//                       oc2 / hl2 / hlc3 / ohlc4 / hlcc4)
//   WaveTrend Core    — Welford running-stdev channel + EMA(avg) wave + SMA(sig) signal
//   Histogram         — wave − signal area renderer with rising / falling fade
//   Reversion Bands   — dynamic OB / OS strips scaled from the Reversion
//                       Threshold (±T / ±T × 1.25 / ±T × 1.5)
//   Extremity Dots    — OB / OS reversion markers when the wave crosses the
//                       signal beyond the user-defined reversion threshold
//   Divergence Engine — Regular + Hidden bull / bear divergences with a
//                       Smart AI filter (min wave swing + min price swing %
//                       + zone confirmation); solid lines for Regular,
//                       dashed for Hidden, tooltip-rich labels
//   Bar Painter       — five colouring modes (None / Midline / Extremities /
//                       Reversions / Slope) applied to the main chart
//   Dashboard         — compact theme-adaptive PRO panel (regime / zone /
//                       slope / strength gauge / last divergence)
//   Theme Palette     — twelve cohesive palettes drive plots, histogram,
//                       fills, midline and dashboard chrome
//
// CORE PHILOSOPHY
//   Standard WaveTrend implementations leak detail through hard-coded
//   normalisation constants and frozen colour schemes. Artemis Wave's running
//   standard-deviation channel keeps the wave perfectly scale-invariant on
//   every asset and timeframe, while the QUANT-grade theme engine drives
//   every visual layer from a single dropdown — no hidden colour pickers,
//   no palette drift between fills, dots and dashboard.
//
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Artemis Wave Oscillator", shorttitle = "Artemis Wave", overlay = false, precision = 2, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — USER-DEFINED TYPES
// Two small UDTs keep Section 3's method signatures tidy. Bar bundles the four
// price streams so the source resolver can pick any aggregate by name without
// four positional arguments; WaveReading carries the three core outputs back
// from the engine as a single object.
// ═══════════════════════════════════════════════════════════════════════════════

// Price-stream bundle — populated once per bar in Section 4 (Engine).
//   o — open   |   h — high   |   l — low   |   c — close
// UDT field defaults must be compile-time literals in Pine v6, so the fields
// are declared without defaults and the object is constructed via Bar.new(...).
type Bar
    float o
    float h
    float l
    float c

// WaveTrend reading — the three derived series returned by computeWave().
//   wave   — primary EMA-smoothed normalised oscillator
//   signal — SMA trigger line for cross detection
//   hist   — wave − signal histogram, drives the area renderer + slope colouring
type WaveReading
    float wave
    float signal
    float hist

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUT DECLARATIONS
// Every user-configurable setting lives here, organised by component group.
// Group constants are declared first so every input below can share them.
// ═══════════════════════════════════════════════════════════════════════════════

string GRP_THEME = "Visual 🔹"
string GRP_WAVE  = "WaveTrend Core 🔹"
string GRP_BAND  = "Reversion Bands 🔹"
string GRP_HIST  = "Histogram 🔹"
string GRP_DOTS  = "Extremity Dots 🔹"
string GRP_DIV   = "Divergence 🔹"
string GRP_BAR   = "Bar Coloring 🔹"
string GRP_DASH  = "Dashboard 🔹"
string GRP_ALRT  = "Alerts 🔹"

// ── Color Theme ──────────────────────────────────────────────────────────────
// Twelve cohesive palettes, one control. The theme dropdown is the single
// source of truth for every coloured component — wave line, signal line,
// histogram, reversion-band fills, midline reference, OB / OS dots, and the
// dashboard panel all resolve through the four switch blocks below.

themeChoice = input.string("Tropic", "Theme",
     options = ["Tropic", "Amber", "Pastel", "Cyber", "Helios", "Electric", "Candy", "Bloomberg", "Solar", "Royal", "Midnight", "Graphite"],
     group   = GRP_THEME,
     tooltip = "Applies a complete color palette across all Artemis Wave components.\nOne selection governs the Wave line, Signal line, Histogram, OB / OS bands, dots and dashboard.\n\nTropic — Cyan steel + deep orange (electric contrast — default)\n\nAmber — Warm amber + indigo blue (fire tones)\n\nPastel — Sky blue + soft lavender (cool arctic glow)\n\nCyber — Neon lime + hot crimson (cyber terminal)\n\nHelios — Bright gold + scarlet (solar warmth)\n\nElectric — Electric aqua + magenta (high-voltage neon)\n\nCandy — Neon green + hot pink (dark energy pop)\n\nBloomberg — Terminal orange + cyan (Wall Street finance heritage — PRO)\n\nSolar — Solarized olive + crimson (developer palette, easy on the eyes — PRO)\n\nRoyal — Imperial gold + deep purple (luxury signature — PRO)\n\nMidnight — Deep navy + dark crimson (dark depth)\n\nGraphite — Near-black + silver grey (monochrome minimal)")

// ── Theme color resolver ─────────────────────────────────────────────────────
// Each theme resolves to four axis colours. The whole script reads from these
// four variables — nothing below this block references a raw hex literal.
//   thBull    — bullish / positive side  (wave up, histogram up, OB band)
//   thBear    — bearish / negative side  (wave down, histogram down, OS band)
//   thNeutral — desaturated mid tone     (midline, neutral dashboard rows)
//   thSignal  — pastel tint of thBull    (signal line + neon glow halo)

color thBull = switch themeChoice
    "Tropic"    => #00bcd4
    "Amber"     => #ff9800
    "Pastel"    => #4fc3f7
    "Cyber"     => #00e676
    "Helios"    => #ffd600
    "Electric"  => #00e5ff
    "Candy"     => #69F0AE
    "Bloomberg" => #ff8c00
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
    "Bloomberg" => #00b0ff
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

// Signal-line colour is a pastel lift of each theme's bull hue. Readers see
// it as "same family, brighter variant" rather than a separate accent — the
// whole panel reads cohesively under every palette.
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

// ── WaveTrend Core ───────────────────────────────────────────────────────────
// Source aggregate selector + the three length knobs that govern the entire
// engine: channel, average and signal smoothing. Lengths are typed `simple`
// because ta.ema / ta.sma accept only simple-qualified arguments.

simple string srcCode = input.string("HLC3", "Source",
     options = ["Open", "High", "Low", "Close", "OC2", "HL2", "HLC3", "OHLC4", "HLCC4"],
     group   = GRP_WAVE,
     tooltip = "Price aggregate fed into the WaveTrend channel.\n\nClose — standard close-only feed, fastest reaction\nHL2 — (High + Low) / 2, body-independent midpoint\nHLC3 — (High + Low + Close) / 3, typical mean — default\nOHLC4 — (Open + High + Low + Close) / 4, smoothest\nHLCC4 — (High + Low + 2×Close) / 4, close-weighted\nOC2 — (Open + Close) / 2, body midpoint\n\nDefault: HLC3")

simple int chanLen = input.int(10, "Channel Length",
     minval = 7, maxval = 50, step = 1,
     group   = GRP_WAVE,
     tooltip = "Lookback for the EMA channel midline + Welford running-stdev band.\n\nShorter → tighter channel, faster wave reaction, more noise\nLonger → wider channel, slower wave, cleaner extremes\n\n7–12 → scalping / intraday\n10 → balanced — default\n14–25 → swing trading\n30–50 → position / weekly\n\nDefault: 10")

simple int avgLen = input.int(21, "Average Length",
     minval = 7, maxval = 50, step = 1,
     group   = GRP_WAVE,
     tooltip = "EMA smoothing applied to the normalised wave. This is the dominant responsiveness control — larger values produce a calmer curve with fewer reversion-zone touches.\n\n7–14 → fast, more whipsaws\n21 → balanced — default\n25–35 → swing trading\n40–50 → position / weekly\n\nDefault: 21")

simple int sigLen = input.int(4, "Signal Length",
     minval = 2, maxval = 7, step = 1,
     group   = GRP_WAVE,
     tooltip = "SMA smoothing applied to the wave to build the trigger line. Shorter than the Average Length so the two cross cleanly.\n\n2–3 → fast triggers, more crosses\n4 → balanced — default\n5–7 → fewer, more reliable crosses\n\nDefault: 4")

// ── Reversion Bands ──────────────────────────────────────────────────────────
// User-tunable reversion threshold. The threshold defines what "OB / OS"
// means for the extremity dots, the bar-colouring mode and the dashboard
// Zone tag; the two outer gradient tiers (at ±T × 1.25 and ±T × 1.5) are
// drawn purely for visual context.

revThreshold = input.int(100, "Reversion Threshold",
     minval = 50, maxval = 200, step = 5,
     group   = GRP_BAND,
     tooltip = "Distance from zero (in normalised units) beyond which the wave is considered overbought (positive side) or oversold (negative side).\n\n50–80 → loose, fires on shallow reversions (good for ranging assets)\n100 → moderate, balanced — default\n125 → strict, mainstream WaveTrend convention\n150–200 → very strict, only extreme readings register (good for trending assets)\n\nDrives:\n• Extremity Dot triggers\n• Bar-colour mode 'Extremities'\n• Dashboard Zone tag\n\nDefault: 100")

showBands = input.bool(true, "Show Band Fills",
     group   = GRP_BAND,
     tooltip = "Toggles the gradient strips at ±T / ±T × 1.25 / ±T × 1.5 (where T is the Reversion Threshold).\n\nThe strips highlight when the wave breaks into successive reversion tiers — classical mean-reversion zones — and scale automatically with the Threshold setting.\n\nColours are driven by the active Theme.")

bandOpacity = input.int(30, "Band Opacity",
     minval = 0, maxval = 100,
     group   = GRP_BAND,
     tooltip = "Opacity of the reversion-band gradient strips.\n\nKept intentionally low so the bands stay as a subtle ambient cue rather than dominating the panel — the wave line is the focal point, the bands are context.\n\n0 → fully transparent (invisible)\n20 → very subtle\n30 → balanced ambient cue — default\n50 → moderate, clearly visible\n100 → fully opaque (saturated, overpowers the wave)\n\nIntuitive scale: higher number = more visible.")

// ── Histogram ────────────────────────────────────────────────────────────────
// The wave − signal histogram is drawn as a filled area. Two opacity levels
// distinguish rising bars (brighter) from falling bars (dimmer) on each side.

showHist = input.bool(true, "Show Histogram",
     group   = GRP_HIST,
     tooltip = "Toggles the wave − signal histogram area renderer.\n\nAbove zero → bull theme colour\nBelow zero → bear theme colour\nRising bars are brighter than falling bars for momentum context.")

histOpRise = input.int(60, "Rising Opacity",
     minval = 0, maxval = 100,
     group   = GRP_HIST,
     tooltip = "Opacity for histogram bars when momentum is rising in the active\ndirection (e.g. bull bar that grew vs. its previous bar).\n\nHigher value = brighter. Default: 60")

histOpFade = input.int(40, "Fading Opacity",
     minval = 0, maxval = 100,
     group   = GRP_HIST,
     tooltip = "Opacity for histogram bars when momentum is fading (a bull bar\nthat shrank vs. its previous bar, or a bear bar moving back toward\nzero).\n\nHigher value = brighter. Default: 40")

// ── Extremity Dots ───────────────────────────────────────────────────────────
// OB / OS dots — small markers above/below the wave whenever a cross happens
// past the reversion threshold. They are the highest-conviction reversion
// triggers built into the script.

showDots = input.bool(true, "Show Extremity Dots",
     group   = GRP_DOTS,
     tooltip = "Plots a small dot whenever the wave crosses the signal line beyond\nthe Reversion Threshold.\n\n• OS dot (bull theme colour) → wave crossed UP past −threshold\n• OB dot (bear theme colour) → wave crossed DOWN past +threshold\n\nThese are the highest-conviction mean-reversion triggers in Artemis Wave.")

// ── Divergence ───────────────────────────────────────────────────────────────
// Regular and Hidden divergence detection on price-pivot vs. wave-pivot
// pairs. Regular divergences signal potential reversals (price + wave move
// in opposite directions); Hidden divergences signal trend continuation
// (price + wave move in the same direction with mismatched magnitudes).
// The Smart AI Filter is OFF by default — flip on for high-conviction only.

divRegOn = input.bool(true, "Regular Divergence",
     group   = GRP_DIV,
     tooltip = "Detects potential trend reversals.\n\nBull (D▲): price Lower Low + wave Higher Low → reversal up\nBear (D▼): price Higher High + wave Lower High → reversal down\n\nSolid lines connect the two pivots. Pivot arm = Channel Length / 2.\nResults appear a few bars late — expected Pine Script pivot behaviour.")

divRegAlpha = input.int(80, "Regular Opacity",
     minval = 0, maxval = 100,
     group   = GRP_DIV,
     tooltip = "Line and label opacity for Regular Divergences.\n\n0 → fully transparent (invisible)\n80 → bright — default\n100 → fully opaque\n\nIntuitive scale: higher number = more visible.")

divHidOn = input.bool(true, "Hidden Divergence",
     group   = GRP_DIV,
     tooltip = "Detects trend-continuation signals.\n\nBull (H▲): price Higher Low + wave Lower Low → uptrend continues\nBear (H▼): price Lower High + wave Higher High → downtrend continues\n\nDashed lines connect the two pivots. Use these to add to an existing position in the trend's direction, not as reversal triggers.")

divHidAlpha = input.int(80, "Hidden Opacity",
     minval = 0, maxval = 100,
     group   = GRP_DIV,
     tooltip = "Line and label opacity for Hidden Divergences.\n\nKept slightly dimmer than Regular Divergence by default so the two flavours read at distinct visual tiers.\n\n0 → fully transparent (invisible)\n80 → readable — default\n100 → fully opaque")

divLabelSize = input.string("Tiny", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DIV,
     tooltip = "Size of the D▲ D▼ H▲ H▼ divergence markers.\n\nTiny → minimal, default\nSmall → slightly larger\nNormal → standard\nLarge → maximum visibility")

sdfOn = input.bool(false, "Smart Divergence Filter (AI)",
     group   = GRP_DIV,
     tooltip = "AI-assisted filter that suppresses weak or low-quality divergences.\n\nOFF (default) → all detected divergences pass through\nON → only divergences that clear all three gates below survive\n\nThe three gates:\n1. Min Wave Swing — drops oscillator differences below this size\n2. Min Price Swing (%) — drops divergences where price barely moved\n3. Zone Confirmation — bull divergences must form in the OS half, bear divergences in the OB half (best context)\n\nTurn ON for fewer, higher-conviction signals only.")

sdfMinWave = input.float(5.0, "Min Wave Swing",
     minval = 1.0, maxval = 50.0, step = 0.5,
     group   = GRP_DIV,
     tooltip = "Minimum wave swing between the two pivots (in normalised wave units, same scale as the ±100 reversion threshold).\n\nSmall (1–3) → permissive, allows minor divergences through\nMedium (5) → balanced — default\nLarge (10–20) → only structurally significant divergences pass\n\nRequires Smart Filter ON.")

sdfMinPct = input.float(0.3, "Min Price Swing (%)",
     minval = 0.1, maxval = 5.0, step = 0.1,
     group   = GRP_DIV,
     tooltip = "Minimum price swing between the two pivots as a percentage of the\nrecent (chanLen × 4 bars) price range.\n\nFilters divergences caused by tiny price moves relative to volatility.\n\n0.3% → permissive — default\n1.0% → moderate\n2.0%+ → strict (price swing must be visibly significant)\n\nRequires Smart Filter ON.")

sdfZoneConf = input.bool(true, "Require Zone Confirmation",
     group   = GRP_DIV,
     tooltip = "Restricts divergences to the matching reversion half:\n\n• Bullish divergence — wave at the current pivot must be ≤ −½ × threshold (i.e. in moderate-to-deep oversold territory)\n• Bearish divergence — wave at the current pivot must be ≥ +½ × threshold (i.e. in moderate-to-deep overbought territory)\n\nEncodes the classic 'best divergences form at extremes' rule — uses the wave value itself as the gate (no MFI or volume input required).\n\nRequires Smart Filter ON. Default: ON.")

// ── Bar Coloring ─────────────────────────────────────────────────────────────
// Optional chart-wide colouring mode driven by the wave state.

barMode = input.string("None", "Bar Color Mode",
     options = ["None", "Midline Cross", "Extremities", "Reversions", "Slope"],
     group   = GRP_BAR,
     tooltip = "Applies a wave-driven colour to every price bar on the chart.\n\nNone → leave bars untouched (default)\nMidline Cross → bull above zero, bear below zero\nExtremities → bull beyond +threshold, bear beyond −threshold, neutral elsewhere\nReversions → bull on OS dot trigger, bear on OB dot trigger\nSlope → bull when wave > signal, bear when wave < signal\n\nDefault: None")

// ── Dashboard ────────────────────────────────────────────────────────────────
// Compact PRO data table drawn on the last bar. Mirrors QUANT's dashboard
// convention so the whole catalogue feels like one product family.

showDash = input.bool(true, "Show Dashboard",
     group   = GRP_DASH,
     tooltip = "Master toggle for the on-chart data panel.\n\nShows at a glance:\n• Regime — Bull / Bear / Neutral bias from the wave vs. zero\n• Wave — current normalised wave value + trend arrow\n• Signal — SMA trigger-line value\n• Strength — 10-block gauge of |wave − signal|\n• Zone — OB / MID / OS tag from the Reversion Threshold\n• Div — most recent divergence detected within the last 50 bars\n• Slope — ▲ wave above signal, ▼ wave below signal\n\nColours are driven by the active Theme. On Midnight / Graphite themes the panel automatically flips to a light background so the text stays readable against dark plots.")

dashPos = input.string("Middle Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_DASH,
     tooltip = "Anchor position inside the indicator pane where the dashboard docks.\n\nSix slots — three vertical bands × two sides. Pick whichever does\nnot overlap your other indicators or labels.\n\nDefault: Middle Right")

dashSize = input.string("Small", "Panel Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DASH,
     tooltip = "Text size inside the dashboard.\n\nTiny → smallest, compact layouts\nSmall → default, clean and readable\nNormal → larger, comfortable reading\nLarge → maximum visibility")

// ── Alerts ───────────────────────────────────────────────────────────────────
// Opt-in toggles for every core cross event. Each alert is gated by its
// switch — hiding a feature on the chart silences its alerts automatically.

simple bool alrtOSSig    = input.bool(true,  "OS Reversion",
     group   = GRP_ALRT,
     tooltip = "Fires when the wave crosses ABOVE the signal line while the wave\nsits below the negative Reversion Threshold.\n\nHigh-conviction bullish mean-reversion trigger.")

simple bool alrtOBSig    = input.bool(true,  "OB Reversion",
     group   = GRP_ALRT,
     tooltip = "Fires when the wave crosses BELOW the signal line while the wave\nsits above the positive Reversion Threshold.\n\nHigh-conviction bearish mean-reversion trigger.")

simple bool alrtDivReg   = input.bool(true,  "Regular Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Regular bullish or bearish divergence detection.\n\nBull (D▲): price Lower Low + wave Higher Low → reversal up\nBear (D▼): price Higher High + wave Lower High → reversal down\n\nRespects the Smart Filter when enabled.")

simple bool alrtDivHid   = input.bool(false, "Hidden Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Hidden bullish or bearish divergence detection.\n\nBull (H▲): price Higher Low + wave Lower Low → uptrend continues\nBear (H▼): price Lower High + wave Higher High → downtrend continues\n\nOFF by default — Hidden divergences fire more frequently than Regular. Respects the Smart Filter when enabled.")

simple bool alrtBullTrnd = input.bool(true,  "Bullish Trend",
     group   = GRP_ALRT,
     tooltip = "Fires when the wave crosses above zero (bullish regime flip).")

simple bool alrtBearTrnd = input.bool(true,  "Bearish Trend",
     group   = GRP_ALRT,
     tooltip = "Fires when the wave crosses below zero (bearish regime flip).")

simple bool alrtBullSwng = input.bool(false, "Bullish Swing",
     group   = GRP_ALRT,
     tooltip = "Fires on every wave × signal upward cross, regardless of zone.\nFrequent on short timeframes — best combined with the Reversion\nor Trend alerts above for confirmation.")

simple bool alrtBearSwng = input.bool(false, "Bearish Swing",
     group   = GRP_ALRT,
     tooltip = "Fires on every wave × signal downward cross, regardless of zone.\nFrequent on short timeframes — best combined with the Reversion\nor Trend alerts above for confirmation.")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — METHODS
// Three small methods drive the entire engine. Declared at top level so they
// participate in Pine v6's UFCS (`x.runStdev(len)`, `b.computeWave(...)`).
// ═══════════════════════════════════════════════════════════════════════════════

// Source resolver — turns the user-selected string code into the matching
// price aggregate. Centralised here so the engine never branches on the
// source name and the dashboard can read the same code without duplication.
method resolveSrc(Bar b, simple string code) =>
    switch code
        "Open"  =>           b.o
        "High"  =>           b.h
        "Low"   =>           b.l
        "Close" =>           b.c
        "OC2"   => math.avg(b.o, b.c)
        "HL2"   => math.avg(b.h, b.l)
        "HLC3"  => math.avg(b.h, b.l, b.c)
        "OHLC4" => math.avg(b.o, b.h, b.l, b.c)
        "HLCC4" => math.avg(b.h, b.l, b.c, b.c)
        =>        math.avg(b.h, b.l, b.c)

// Welford-style running standard deviation — single-pass O(len) algorithm
// that updates the running mean and squared deviation simultaneously. Stays
// numerically stable on long histories where a naive sum-of-squares approach
// loses precision.
//
//   meanRun  — current running mean across the lookback window
//   meanPrev — mean before this iteration's update (used by the var-update)
//   sqAcc    — accumulating sum of squared deviations from the running mean
method runStdev(float src, simple int len) =>
    float meanRun  = 0.0
    float meanPrev = 0.0
    float sqAcc    = 0.0
    for k = 0 to len - 1
        float val = nz(src[k])
        meanPrev := meanRun
        meanRun  := meanRun + (val - meanRun) / (1 + k)
        sqAcc    := sqAcc + (val - meanRun) * (val - meanPrev)
    math.sqrt(sqAcc / (len - 1))

// WaveTrend engine — the heart of Artemis Wave, four ordered steps:
//   1. Resolve the user-selected price aggregate.
//   2. Build an EMA channel midline and a running-stdev channel width.
//   3. Normalise the source against the channel and scale to ±100.
//   4. EMA-smooth the normalised series into the wave, SMA-smooth that
//      into a signal trigger line, and emit the wave-minus-signal histogram.
//
// The math intentionally mirrors EliCobra's original Enhanced WaveTrend
// formulation — Artemis Wave's value is in the Pine v6 idioms, the theme system
// and the rendering layer, not in altering the well-tested core curve.
method computeWave(Bar b, simple string code, simple int chan, simple int avg, simple int sig) =>
    float x       = b.resolveSrc(code)
    float chanMid = ta.ema(x, chan)
    float chanDev = x.runStdev(chan)
    float waveVal = ta.ema((x - chanMid) / chanDev * 100.0, avg)
    float sigVal  = ta.sma(waveVal, sig)
    WaveReading.new(waveVal, sigVal, waveVal - sigVal)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — ENGINE
// Drive the bar bundle into the WaveTrend engine and unpack the reading into
// short-named aliases so the plot + alert blocks below stay readable.
// ═══════════════════════════════════════════════════════════════════════════════

Bar         barBundle = Bar.new(open, high, low, close)
WaveReading wt        = barBundle.computeWave(srcCode, chanLen, avgLen, sigLen)

float wave   = wt.wave    // primary EMA-smoothed normalised oscillator
float signal = wt.signal  // SMA trigger line
float hist   = wt.hist    // wave − signal

// Numeric reversion threshold promoted to float for the multiplication
// downstream in the Smart Filter zone gates (cLL_w <= -revT * 0.5, etc.).
float revT = revThreshold

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — SIGNAL DETECTION
// All cross-state booleans live here, computed once and reused by the plots,
// the dashboard, the bar painter and the alert block. Calculating each event
// in a single place guarantees the visual layer and the alert layer can
// never disagree.
// ═══════════════════════════════════════════════════════════════════════════════

bool xWaveUp   = ta.crossover (wave, signal)  // wave crossed up through signal
bool xWaveDn   = ta.crossunder(wave, signal)  // wave crossed down through signal
bool xZeroUp   = ta.crossover (wave, 0)       // wave crossed up through zero
bool xZeroDn   = ta.crossunder(wave, 0)       // wave crossed down through zero

bool osSignal  = xWaveUp and wave < -revT     // bullish reversion from OS extreme
bool obSignal  = xWaveDn and wave >  revT     // bearish reversion from OB extreme

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — DIVERGENCE DETECTION
// Pivot-based detection for the four classical divergence flavours:
//   Regular Bull / Bear → reversal signals (price + wave move opposite ways)
//   Hidden  Bull / Bear → continuation signals (price + wave same way, mismatched)
//
// Pivots are sampled on raw price (high / low) and the wave value at the
// pivot bar is captured in lock-step so the comparison is always taken at
// the same instant. The Smart AI Filter applies three independent gates —
// min wave swing, min price swing %, zone confirmation. The master toggle
// is OFF by default for permissive detection; flip ON for high-conviction
// signals only.
// ═══════════════════════════════════════════════════════════════════════════════

// Pivot arm — derived from chanLen so longer-period setups produce wider,
// more selective pivots. Floor of 2 protects against degenerate single-bar
// pivots on aggressive chanLen settings.
int   pivSpan = math.max(chanLen / 2, 2)
float phRaw   = ta.pivothigh(high, pivSpan, pivSpan)
float plRaw   = ta.pivotlow (low,  pivSpan, pivSpan)

// Previous pivot anchors — bar index, price and wave value held in `var`
// state across bars. Each pair of consecutive pivots (one previous + one
// current) constitutes a potential divergence sample.
//   pHH_* — previous price HIGH pivot     |   pLL_* — previous price LOW pivot
//   *_px  — price value at the pivot      |   *_wv  — wave value at the pivot
//   *_bx  — bar index at the pivot (used as the line.new x1 anchor)
var float pHH_px = na
var float pHH_wv = na
var int   pHH_bx = int(na)
var float pLL_px = na
var float pLL_wv = na
var int   pLL_bx = int(na)

// Current-bar pivot capture — populated only on the bar where ta.pivothigh /
// ta.pivotlow fires (which is pivSpan bars after the actual pivot, that's
// how Pine confirms pivots retroactively). When no pivot fires, these stay
// na and the divergence checks below are gated off.
float cHH_p = na
float cHH_w = na
float cLL_p = na
float cLL_w = na

if not na(phRaw)
    cHH_p := high[pivSpan]
    cHH_w := wave[pivSpan]

if not na(plRaw)
    cLL_p := low[pivSpan]
    cLL_w := wave[pivSpan]

// ── Raw divergence detection ─────────────────────────────────────────────────
// Four mutually exclusive flags. Each fires the bar a fresh pivot is
// confirmed and the prev-vs-curr comparison meets the divergence shape.
bool dRegBull = false  // price LL + wave HL → reversal up
bool dRegBear = false  // price HH + wave LH → reversal down
bool dHidBull = false  // price HL + wave LL → uptrend continues
bool dHidBear = false  // price LH + wave HH → downtrend continues

if not na(cHH_p) and not na(pHH_px)
    if cHH_p > pHH_px and cHH_w < pHH_wv
        dRegBear := true
    if cHH_p < pHH_px and cHH_w > pHH_wv
        dHidBear := true

if not na(cLL_p) and not na(pLL_px)
    if cLL_p < pLL_px and cLL_w > pLL_wv
        dRegBull := true
    if cLL_p > pLL_px and cLL_w < pLL_wv
        dHidBull := true

// ── Smart AI Filter ──────────────────────────────────────────────────────────
// Three independent gates evaluated when sdfOn is true. The min-swing gates
// reject noise-level differences; the zone gate encodes the classical
// "divergences are strongest at extremes" rule.
//
//   sdfMinPxAbs — minimum absolute price swing, derived as the user's
//                 percentage of the recent (chanLen × 4) high-low range
//   sdfZoneBull — bull divs require the current LL pivot's wave value to
//                 sit at or below −½ × Reversion Threshold (oversold half)
//   sdfZoneBear — symmetric: HH pivot's wave at +½ × threshold or above
float sdfPxRange  = ta.highest(high, chanLen * 4) - ta.lowest(low, chanLen * 4)
float sdfMinPxAbs = sdfPxRange * (sdfMinPct / 100.0)

float sdfWvSwLL = math.abs(cLL_w - pLL_wv)
float sdfWvSwHH = math.abs(cHH_w - pHH_wv)
float sdfPxSwLL = math.abs(cLL_p - pLL_px)
float sdfPxSwHH = math.abs(cHH_p - pHH_px)

bool sdfZoneBull = not sdfZoneConf or cLL_w <= -revT * 0.5
bool sdfZoneBear = not sdfZoneConf or cHH_w >=  revT * 0.5

bool sdfPassBull = not sdfOn or (sdfWvSwLL >= sdfMinWave and sdfPxSwLL >= sdfMinPxAbs and sdfZoneBull)
bool sdfPassBear = not sdfOn or (sdfWvSwHH >= sdfMinWave and sdfPxSwHH >= sdfMinPxAbs and sdfZoneBear)

// ── Divergence palette + label-size resolver ─────────────────────────────────
// All four flavours pull from the active theme. Regular = thBull / thBear
// at full strength (the classic, most-trusted reversal signal). Hidden =
// the same palette but dashed lines for an obvious visual tier separation.
color colDivRegBull = color.new(thBull, 100 - divRegAlpha)
color colDivRegBear = color.new(thBear, 100 - divRegAlpha)
color colDivHidBull = color.new(thBull, 100 - divHidAlpha)
color colDivHidBear = color.new(thBear, 100 - divHidAlpha)

string divSz = divLabelSize == "Tiny"   ? size.tiny   :
               divLabelSize == "Small"  ? size.small  :
               divLabelSize == "Normal" ? size.normal :
                                          size.large

// ── Divergence rendering + last-event tracking ───────────────────────────────
// Each detected event paints a line between the two pivots and drops a
// tooltip-rich label at the current pivot. The lastDiv* pair persists
// across bars so the dashboard can report the most recent event.
var int    lastDivBar = int(na)
var string lastDivTag = "—"

if divRegOn and dRegBull and sdfPassBull
    line.new (pLL_bx, pLL_wv, bar_index[pivSpan], cLL_w, color = colDivRegBull, width = 1, style = line.style_solid)
    label.new(bar_index[pivSpan], cLL_w, "D▲", style = label.style_label_up,   color = colDivRegBull, textcolor = color.white, size = divSz,
         tooltip = "Regular Bullish Divergence\nPrice: Lower Low\nWave: Higher Low\nSignal: Potential reversal to the upside")
    lastDivBar := bar_index
    lastDivTag := "▲ REG"

if divRegOn and dRegBear and sdfPassBear
    line.new (pHH_bx, pHH_wv, bar_index[pivSpan], cHH_w, color = colDivRegBear, width = 1, style = line.style_solid)
    label.new(bar_index[pivSpan], cHH_w, "D▼", style = label.style_label_down, color = colDivRegBear, textcolor = color.white, size = divSz,
         tooltip = "Regular Bearish Divergence\nPrice: Higher High\nWave: Lower High\nSignal: Potential reversal to the downside")
    lastDivBar := bar_index
    lastDivTag := "▼ REG"

if divHidOn and dHidBull and sdfPassBull
    line.new (pLL_bx, pLL_wv, bar_index[pivSpan], cLL_w, color = colDivHidBull, width = 1, style = line.style_dashed)
    label.new(bar_index[pivSpan], cLL_w, "H▲", style = label.style_label_up,   color = colDivHidBull, textcolor = color.white, size = divSz,
         tooltip = "Hidden Bullish Divergence\nPrice: Higher Low\nWave: Lower Low\nSignal: Uptrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▲ HID"

if divHidOn and dHidBear and sdfPassBear
    line.new (pHH_bx, pHH_wv, bar_index[pivSpan], cHH_w, color = colDivHidBear, width = 1, style = line.style_dashed)
    label.new(bar_index[pivSpan], cHH_w, "H▼", style = label.style_label_down, color = colDivHidBear, textcolor = color.white, size = divSz,
         tooltip = "Hidden Bearish Divergence\nPrice: Lower High\nWave: Higher High\nSignal: Downtrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▼ HID"

// Update previous-pivot anchors — runs AFTER the rendering block above so
// the line.new calls can still resolve the previous pivot's bar/value pair.
if not na(cHH_p)
    pHH_px := cHH_p
    pHH_wv := cHH_w
    pHH_bx := bar_index[pivSpan]

if not na(cLL_p)
    pLL_px := cLL_p
    pLL_wv := cLL_w
    pLL_bx := bar_index[pivSpan]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — PLOTS
// Render every visual layer: histogram area, wave + signal lines, midline,
// reversion-band guides, gradient fills and OB / OS extremity dots. Plot IDs
// declared here are reused by fill() further down, so order matters — the
// midline hline and the hidden band-anchor plots come first so their IDs
// exist for the fill() calls.
// ═══════════════════════════════════════════════════════════════════════════════

// ── Histogram colour resolver ────────────────────────────────────────────────
// Two opacity levels per side distinguish rising momentum (brighter) from
// fading momentum (dimmer). Matches the original Enhanced WaveTrend
// aesthetic while routing every colour through the active theme.
int   histTransRise = 100 - histOpRise
int   histTransFade = 100 - histOpFade

color histCol =
     hist > 0
         ? (hist > hist[1] ? color.new(thBull, histTransRise) : color.new(thBull, histTransFade))
         : (hist > hist[1] ? color.new(thBear, histTransFade) : color.new(thBear, histTransRise))

// ── Midline + reversion-band anchors ─────────────────────────────────────────
// Midline at zero is the only visible guide — drawn as a static hline since
// it never moves. The six band anchors below are rendered as hidden plots
// (not hlines) because hline() only accepts compile-time constants; plots
// carry the input-driven revT through to the fill() calls below. Tier 1 =
// ±revT, Tier 2 = ±revT × 1.25, Tier 3 = ±revT × 1.5 — proportional scaling
// so the bands always wrap the threshold no matter how the user tunes it.
hMid = hline(0, "Midline", color.new(thNeutral, 50), hline.style_solid)


pBandInPos  = plot( revT,        "Band Inner+", color = na, display = display.none, editable = false)
pBandMidPos = plot( revT * 1.25, "Band Mid+",   color = na, display = display.none, editable = false)
pBandMaxPos = plot( revT * 1.5,  "Band Max+",   color = na, display = display.none, editable = false)
pBandInNeg  = plot(-revT,        "Band Inner−", color = na, display = display.none, editable = false)
pBandMidNeg = plot(-revT * 1.25, "Band Mid−",   color = na, display = display.none, editable = false)
pBandMaxNeg = plot(-revT * 1.5,  "Band Max−",   color = na, display = display.none, editable = false)

// ── Histogram area + main wave + signal ──────────────────────────────────────
pHist   = plot(showHist ? hist : na, "Histogram", histCol, 1, plot.style_area)
pWave   = plot(wave, "Wave",   wave > signal ? thBull : thBear, 2, plot.style_line)
pSignal = plot(signal, "Signal", display = display.none)

// ── Wave / signal fill ───────────────────────────────────────────────────────
// Light tinted ribbon between the wave and the signal line — the same
// adaptive colour as the wave, at 50% opacity, so the slope direction is
// obvious without overpowering the histogram.
color ribbonCol = wave > signal ? color.new(thBull, 50) : color.new(thBear, 50)
fill(pWave, pSignal, ribbonCol)

// ── Reversion-band gradient fills ────────────────────────────────────────────
// Two tier intensities per side, both scaled from revT:
//   Tier 1 (outer ring)   — ±revT       to ±revT × 1.25
//   Tier 2 (inner extreme) — ±revT × 1.25 to ±revT × 1.5
// Drawn only when showBands is on; user opacity follows the intuitive
// 0 = invisible / 100 = opaque scale and is inverted here for Pine.
int bandTransOuter = showBands ? math.min(100, 100 - bandOpacity + 7) : 100
int bandTransInner = showBands ? math.max(0,   100 - bandOpacity)     : 100

fill(pBandInPos,  pBandMidPos, color.new(thBull, bandTransOuter), title = "OB Tier 1")
fill(pBandMidPos, pBandMaxPos, color.new(thBull, bandTransInner), title = "OB Tier 2")
fill(pBandInNeg,  pBandMidNeg, color.new(thBear, bandTransOuter), title = "OS Tier 1")
fill(pBandMidNeg, pBandMaxNeg, color.new(thBear, bandTransInner), title = "OS Tier 2")

// ── Extremity Dots ───────────────────────────────────────────────────────────
// Two-track rendering — the VISUAL is drawn through plot.style_circles for
// pixel-perfect small dots (label.style_circle's smallest size renders far
// too large for an oscillator marker), and a parallel INVISIBLE label sits
// on top of each dot to provide the hover tooltip (plot() does not support
// the tooltip argument, only labels do). The fully-transparent label fill
// keeps the visual clean; TradingView still routes hover events through
// the label's bounding box, so the rich tooltip surfaces on mouse-over.
// The y-offset (±40) holds the dot off the wave line so the active
// crossover point stays visually uncluttered.
color dotOSGlow = color.new(thBull, 65)
color dotOSCore = color.new(thBull, 0)
color dotOBGlow = color.new(thBear, 65)
color dotOBCore = color.new(thBear, 0)

float osDotY = showDots and osSignal ? wave - 40 : na
float obDotY = showDots and obSignal ? wave + 40 : na

// Visual layer — dual-circle glow + core, small pixel-accurate plot dots.
plot(osDotY, "OS Glow", dotOSGlow, 6, plot.style_circles)
plot(osDotY, "OS Core", dotOSCore, 2, plot.style_circles)
plot(obDotY, "OB Glow", dotOBGlow, 6, plot.style_circles)
plot(obDotY, "OB Core", dotOBCore, 2, plot.style_circles)

// Hover layer — invisible label.style_circle markers carrying the rich
// tooltip text. Fully-transparent fill so they add zero visual weight;
// their bounding box is what TradingView listens to for the hover gesture.
if showDots and osSignal
    string osTip = "OS Reversion — Oversold Bullish Trigger\nWave: Crossed UP through Signal\nZone: Below −" + str.tostring(revT) + " (deep oversold)\nValue: " + str.tostring(wave, "#.##") + "\nSignal: " + str.tostring(signal, "#.##") + "\nMeaning: Momentum reversing from extreme oversold — mean-reversion long opportunity"
    label.new(bar_index, wave - 40, "", style = label.style_circle, color = color.new(thBull, 100), size = size.small, tooltip = osTip)

if showDots and obSignal
    string obTip = "OB Reversion — Overbought Bearish Trigger\nWave: Crossed DOWN through Signal\nZone: Above +" + str.tostring(revT) + " (deep overbought)\nValue: " + str.tostring(wave, "#.##") + "\nSignal: " + str.tostring(signal, "#.##") + "\nMeaning: Momentum reversing from extreme overbought — mean-reversion short opportunity"
    label.new(bar_index, wave + 40, "", style = label.style_circle, color = color.new(thBear, 100), size = size.small, tooltip = obTip)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — BAR COLORING
// Optional chart-wide colouring of every price bar driven by the wave state.
// Five mutually exclusive modes; "None" emits na so barcolor() is a no-op.
// ═══════════════════════════════════════════════════════════════════════════════

color barCol = switch barMode
    "Midline Cross" => wave > 0    ? thBull : thBear
    "Extremities"   => wave >  revT ? thBull : wave < -revT ? thBear : thNeutral
    "Reversions"    => obSignal     ? thBear : osSignal      ? thBull : thNeutral
    "Slope"         => wave > signal ? thBull : thBear
    "None"          => na
    =>                 na

barcolor(barCol)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — DASHBOARD
// Compact 2-column, 7-row PRO panel drawn on the last bar. Every value is
// already computed above, so the dashboard adds zero overhead until the
// final bar. Layout auto-inverts to a light palette on Midnight / Graphite
// so the text stays readable against their deep-dark plots.
// ═══════════════════════════════════════════════════════════════════════════════

var table awoDash = na

if showDash and barstate.islast
    // Light-canvas guard — Midnight and Graphite themes ship with such dim
    // thBull / thSignal hues that they vanish against a black panel, so for
    // those two palettes the dashboard flips to a light layout with dark
    // theme-bull text. Every other theme keeps the dark chrome.
    bool  dIsLight = themeChoice == "Midnight" or themeChoice == "Graphite"

    color dBgH = dIsLight ? color.new(#F0F0F0, 0)  : color.new(thBull, 90)   // header row — faint theme tint
    color dBgM = dIsLight ? color.new(#FAFAFA, 0)  : color.new(#0f0f0f, 5)   // middle rows — solid dark
    color dBgF = dIsLight ? color.new(#E8E8E8, 0)  : color.new(thBull, 90)   // footer row — faint theme tint
    color dBrd = dIsLight ? color.new(thBull, 40)  : color.new(thBull, 20)   // theme-tinted border, strong presence

    // Strict colour uniformity — both columns share one full-saturation
    // theme tone (thBull, the same hue as the wave line). Direction is
    // conveyed via ▲ ▼ ■ glyphs rather than colour shifts. Same colour
    // for both layouts; the background switch alone provides contrast.
    color dTx = color.new(thBull, 0)

    // Regime classification — wave above zero is bullish, below zero is bearish.
    bool   dRegimeBull  = wave > 0
    bool   dRegimeBear  = wave < 0
    string dRegimeLabel = dRegimeBull ? "▲ BULL" : dRegimeBear ? "▼ BEAR" : "■ NEUTRAL"

    // Wave trend arrow vs. previous bar.
    string dTrendArrow = wave > wave[1] ? "▲" : wave < wave[1] ? "▼" : "■"

    // Zone tag — OB / OS / MID based on the Reversion Threshold.
    string dZoneLabel = wave >= revT ? "OB" : wave <= -revT ? "OS" : "MID"

    // Slope tag — wave above / below the signal line.
    string dSlopeLabel = wave > signal ? "▲ UP" : wave < signal ? "▼ DOWN" : "■ FLAT"

    // Strength gauge — |wave − signal| bucketed into a 10-block monospace bar.
    // Normalised against 50 (typical mid-amplitude swing) so the gauge fills
    // visibly on most assets without one massive outlier saturating it.
    float  dStrPct     = math.min(100, math.abs(hist) / 50.0 * 100.0)
    int    dBarsFilled = math.round(dStrPct / 10.0)
    string dStrBar     = ""
    for _i = 0 to 9
        dStrBar := dStrBar + (_i < dBarsFilled ? "█" : "░")

    // Position resolver — Pine v6 multi-line ternaries inside a local block
    // must be wrapped in parentheses, otherwise the parser treats the newline
    // as a statement terminator and throws CE10156.
    string dTPos = (dashPos == "Top Right"    ? position.top_right    :
                    dashPos == "Top Left"     ? position.top_left     :
                    dashPos == "Middle Right" ? position.middle_right :
                    dashPos == "Middle Left"  ? position.middle_left  :
                    dashPos == "Bottom Right" ? position.bottom_right :
                                                position.bottom_left)

    string dTSize = (dashSize == "Tiny"   ? size.tiny   :
                     dashSize == "Small"  ? size.small  :
                     dashSize == "Normal" ? size.normal :
                                            size.large)

    // Rebuild the table every last-bar tick so input changes take effect live.
    if not na(awoDash)
        table.delete(awoDash)

    awoDash := table.new(dTPos, 2, 7,
         bgcolor      = dBgM,
         border_color = dBrd,
         border_width = 1,
         frame_color  = dBrd,
         frame_width  = 1)

    // Row 0 — Header: brand + live regime tag.
    table.cell(awoDash, 0, 0, "Artemis Wave",
         text_color = dTx, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 0, dRegimeLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 1 — Wave value + trend arrow.
    table.cell(awoDash, 0, 1, "Wave",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 1, str.tostring(wave, "#.##") + " " + dTrendArrow,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2 — Signal value.
    table.cell(awoDash, 0, 2, "Signal",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 2, str.tostring(signal, "#.##"),
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3 — Strength gauge (10-block bar).
    table.cell(awoDash, 0, 3, "Strength",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 3, dStrBar,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4 — Zone tag.
    table.cell(awoDash, 0, 4, "Zone",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 4, dZoneLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 5 — Last divergence detected within ~50 bars (else "—").
    string dDivLabel = (na(lastDivBar) or (bar_index - lastDivBar) > 50) ? "—" : lastDivTag
    table.cell(awoDash, 0, 5, "Div",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 5, dDivLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 6 — Footer: slope tag.
    table.cell(awoDash, 0, 6, "Slope",
         text_color = dTx, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(awoDash, 1, 6, dSlopeLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_right, text_font_family = font.family_monospace)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — ALERTS
// Ten alert conditions covering every core cross + divergence event. Each
// fires through alert() rather than alertcondition() so the message body can
// carry extra context — direction, current wave value and the threshold
// that triggered.
// ═══════════════════════════════════════════════════════════════════════════════

if alrtOSSig    and osSignal
    alert("Artemis Wave — OS Reversion: wave crossed UP past −" + str.tostring(revT) + " (current: " + str.tostring(wave, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtOBSig    and obSignal
    alert("Artemis Wave — OB Reversion: wave crossed DOWN past +" + str.tostring(revT) + " (current: " + str.tostring(wave, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtDivReg   and dRegBull and sdfPassBull
    alert("Artemis Wave — Regular Bullish Divergence (D▲): price made a Lower Low while the wave printed a Higher Low — potential reversal up.",   alert.freq_once_per_bar_close)

if alrtDivReg   and dRegBear and sdfPassBear
    alert("Artemis Wave — Regular Bearish Divergence (D▼): price made a Higher High while the wave printed a Lower High — potential reversal down.", alert.freq_once_per_bar_close)

if alrtDivHid   and dHidBull and sdfPassBull
    alert("Artemis Wave — Hidden Bullish Divergence (H▲): price made a Higher Low while the wave printed a Lower Low — uptrend continuation.",      alert.freq_once_per_bar_close)

if alrtDivHid   and dHidBear and sdfPassBear
    alert("Artemis Wave — Hidden Bearish Divergence (H▼): price made a Lower High while the wave printed a Higher High — downtrend continuation.",  alert.freq_once_per_bar_close)

if alrtBullTrnd and xZeroUp
    alert("Artemis Wave — Bullish Trend: wave crossed above the midline (current: " + str.tostring(wave, "#.##") + ")",                   alert.freq_once_per_bar_close)

if alrtBearTrnd and xZeroDn
    alert("Artemis Wave — Bearish Trend: wave crossed below the midline (current: " + str.tostring(wave, "#.##") + ")",                   alert.freq_once_per_bar_close)

if alrtBullSwng and xWaveUp
    alert("Artemis Wave — Bullish Swing: wave crossed above the signal line (current: " + str.tostring(wave, "#.##") + ")",               alert.freq_once_per_bar_close)

if alrtBearSwng and xWaveDn
    alert("Artemis Wave — Bearish Swing: wave crossed below the signal line (current: " + str.tostring(wave, "#.##") + ")",               alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````

# Artemis Adaptive RSI

- url: https://www.tradingview.com/script/QJzSNz0S-Artemis-Adaptive-RSI/
- type: indicator
- pine_id: PUB;da96897dcafc4f6394742c56eee45d85
- version: 1.0

## Description

[b]🟦 Artemis Adaptive RSI[/b] is a Pine v6 self-tuning RSI workbench. Instead of shipping with a fixed period and fixed thresholds — and forcing the trader to babysit the inputs across regimes (14 / 70 / 30 on stocks, 7 / 80 / 20 on crypto, 21 / 60 / 40 in trends) — a 60-candidate optimisation grid scores Supersmoother-filtered RSI variants against their own forward-return performance on a rolling window, then picks the variant whose threshold trips deliver the cleanest mean-reversion edge on the current market. The active period, smoothing, and OB / OS thresholds update online, and a five-state regime label tells you why the optimiser chose what it chose.

The indicator integrates seven analytical layers — Supersmoother-filtered RSI core, online candidate optimiser, hysteresis-locked regime classifier, Stochastic-Extreme-style multi-band zone visual, pivot-based Regular + Hidden divergence detection with a Smart AI Filter, adaptive trigger markers, theme-adaptive bar painter, and a PRO 8-row dashboard — each operating independently and rendered on a single, clean oscillator panel.


[b]🟦 CREDITS & ATTRIBUTION[/b]

The adaptive optimisation CORE — Supersmoother-filtered RSI fleet, rolling-window incremental scorer, champion selection with hysteresis, and the five-state regime classifier — is derived from the open-source work of **GoodBadBitcoin** and published under the same MPL-2.0 license. Full respect to the original author for the design and the open release; this project would not exist without that groundwork.

- Source script — [Adaptive Modern RSI [GBB]](https://www.tradingview.com/script/jlRKZnLj-Adaptive-Modern-RSI-GBB/)
- Original author — [GoodBadBitcoin](https://www.tradingview.com/u/GoodBadBitcoin/)

Everything else — the Stochastic-Extreme-style multi-band zone UI, the twelve-theme palette system, the pivot-based divergence engine, the Smart AI Filter, the PRO dashboard, the hover-tooltipped regime badge, the theme-aware bar painter, and the curated nine-channel alert pack — is original work added on top.


[b]🟦 HOW THE CORE ENGINE WORKS[/b]

[b]**Supersmoother**[/b]

Each bar, the per-bar close change is split into two streams — positive (gains) and negative (losses) — and each stream is fed through an Ehlers two-pole Butterworth low-pass filter. The Supersmoother removes high-frequency noise without piling on the phase lag that naive EMA / RMA pre-smoothing chains accumulate. The filtered gain / loss streams then feed the classical Wilder RSI ratio:

rsi = 100 − 100 / (1 + smoothedGains / smoothedLosses)

[b]**Candidate Fleet**[/b]

15 RSI variants are precomputed in parallel — every combination of:

| Axis | Values |
|---|---|
| RSI length | 7 / 10 / 14 / 21 / 28 |
| Supersmoother smoothing | 6 / 10 / 16 |

Combined with 4 threshold tiers (15-85 / 20-80 / 25-75 / 30-70), this gives the 60-slot fleet the optimiser grades against.

**Online Optimiser (Rolling-Edge Scorer)**

Every bar, each of the 60 slots is evaluated:

1. **Trigger detection** — for the slot's threshold pair, did the bar produce an OS-entry (RSI crossed down through OS) or an OB-exit (RSI crossed back down through OB)?
2. **Forward-return scoring** — if a trigger fired, score it by `close[t + fwdHorizon] / close[t] − 1` (signed by trigger direction).
3. **Rolling bookkeeping** — each slot maintains its own running mean over a sliding `scoreWindow`-bar window. Returns enter on add, exit on subtract, mean recomputed in O(1) per slot per bar — no rescans, no naive sum-of-products drift.

After every bar's update, the slot with the highest mean return wins — subject to two gates:

- **Min Triggers per Candidate** — under-sampled slots are disqualified
- **Switch Margin (%)** — a new champion must beat the current incumbent by this hysteresis margin before it actually takes over

This protects against bar-by-bar leadership flapping when two candidates trade marginal scores.

**Regime Classifier**

The crowned champion's shape (length-index, smoothing-index, level-index, mean-return) is read each bar and the market is tagged as one of five phases:

| Glyph | Phase | Meaning |
|---|---|---|
| ◐ | Adapting | Cold start — optimiser not yet armed (default RSI in use) |
| ✸ | Noisy | Score collapsed, no exploitable edge — sit out |
| ➜ | Trending | Long period + relaxed thresholds — trend dominates, avoid OB/OS reversals |
| ▣ | Range | Short period + strict thresholds — RSI's sweet spot, triggers reliable |
| ⊠ | Calm | Middling parameters — mild swings, use as light confluence |

The raw tag stream is then locked through a two-stage hysteresis machine: the displayed phase only updates after the underlying classification holds for `Regime Confirmation Bars` in a row. This keeps the floating badge from twitching on every minor optimiser jitter.


[b]🟦 MULTI-BAND ZONE UI[/b]

A Stochastic-Extreme-style six-band visual at 100 / 80 / 70 / 50 / 30 / 20 / 0. The active OB / OS thresholds overlay as steplines that move as the optimiser updates. Zone fills key off the *adaptive* thresholds so the visual escalation tracks the actual signal logic, not a fixed 70 / 30 line.

The fills are tiered — when the RSI line plus the live champion's mean-return both confirm a zone state, the fill intensifies; otherwise the band shows a lighter tint. The 40 / 60 reference dotted lines and the 50 zero line are decorative — they are NOT the triggers.

[b]**RSI line colour**[/b]

| Zone | Colour |
|---|---|
| Above 60 | theme-bull (price-strength bias) |
| Between 40 and 60 | neutral |
| Below 40 | theme-bear (price-weakness bias) |

These 40 / 60 bands are FIXED — they are NOT the adaptive OS / OB. The adaptive thresholds drive the triggers; the 40 / 60 bands just colour the RSI line for at-a-glance bias reading.


[b]🟦 TRIGGER MARKERS[/b]

Triangle markers fire at the bar of OS entry / OB exit on the *adaptive* thresholds — the events the optimiser is actually scoring:

- ▲ **OS Entry Trigger** — RSI just crossed down through the adaptive OS threshold (mean-reversion long opportunity)
- ▼ **OB Exit Trigger** — RSI just crossed back down through the adaptive OB threshold from above (rejection / short opportunity)

Markers use `location.absolute` with fixed Y coordinates (10 / 90) so they stay glued to the same visual spot every bar — no drift between candles, no shift when zone fills update. Each visible triangle is paired with an invisible `label.style_circle` carrying a hover tooltip with live RSI value, active threshold, active period, and active smoothing — `plotshape()` does not support tooltips natively, so the dual-track rendering is required for hover content.


[b]🟦 DIVERGENCE DETECTION[/b]

Pivot-based detection for the four classical divergence flavours:

| Type | Price | RSI | Signal |
|---|---|---|---|
| Regular Bull (D▲) | Lower Low | Higher Low | Potential reversal up |
| Regular Bear (D▼) | Higher High | Lower High | Potential reversal down |
| Hidden Bull (H▲) | Higher Low | Lower Low | Uptrend continuation |
| Hidden Bear (H▼) | Lower High | Higher High | Downtrend continuation |

Pivots are sampled on raw price (high / low) using `Pivot Arm` bars on each side (symmetric). Each pivot bar's RSI value is read **dynamically from the current active RSI series** via bar-index lookup — so when the optimiser switches champions between pivots, the comparison stays internally consistent (both endpoints come from the SAME series). This is a subtle but critical fix vs. naive divergence ports.

Regular Divergence labels (D▲ / D▼) use bracketed glyphs with solid styling — these are the reversal signals.
Hidden Divergence labels (H▲ / H▼) use the same bracket scheme — these are the continuation signals.

Each label hovers a tooltip with the price change, RSI change, and the pivot bar distance.

[b]**Smart AI Filter**[/b]

An optional pre-filter that rejects low-quality divergences before they render. Three independent gates:

1. **Min RSI Swing** — minimum RSI difference between the two pivots (default: 5 points). Drops noise-level differences where RSI barely moved between pivots.
2. **Min Price Swing (%)** — minimum price swing between pivots as a percentage of the recent (80 bars) price range (default: 0.3%). Drops divergences where price barely moved relative to recent volatility.
3. **Zone Confirmation** — RSI at the current pivot must sit in the matching adaptive reversion half:
   - Bullish divergence → RSI ≤ midpoint(liveOs, 50) (moderate-to-deep oversold)
   - Bearish divergence → RSI ≥ midpoint(50, liveOb) (moderate-to-deep overbought)

The zone gate is adaptive — it tightens or loosens as the optimiser updates the live OS / OB thresholds. This encodes the classical "best divergences form at extremes" rule using the live adaptive thresholds, not a fixed 30 / 70.

When the master toggle is OFF (default), all detected divergences render. When ON, only divergences that clear all three gates survive. The filter applies identically to both chart rendering and alert conditions — no mismatch between visual and alert signals.


[b]🟦 REGIME BADGE[/b]

A floating label pinned to the LATEST bar, extending rightward into the chart's right-margin / future area. The `label.style_label_left` style places the arrow tip on the LEFT of the box so it visually "points back" to the active RSI data without overlapping the oscillator line.

The badge shows:

- **Glyph + phase name** (e.g. `▣ Range`)
- **Bars stable** (how long the current phase has held)
- **Action note** (e.g. "RSI's sweet spot — triggers work well")

The background colour pulls from the theme palette — Range = theme-bull tint, Trending = theme-bear tint, Adapting / Noisy = theme-neutral tint, Calm = theme-signal tint — so the badge meaning is reinforced by the palette consistency.

[b]**Hover tooltip**[/b]

Hovering the badge surfaces a comprehensive phase legend explaining all five glyphs, what each means, what action to take in each, and how to read the "bars stable" counter.

[b]**Position**[/b]

User-selectable: Top (y = 80, upper third), Middle (y = 50, centre, default), Bottom (y = 20, lower third). The Y resolver maps the dropdown onto fixed pane-fraction coordinates so the badge stays parked at the same visual spot regardless of RSI value.


[b]🟦 BAR COLORING[/b]

Two mutually exclusive modes apply a state-driven colour to every price bar on the chart:

| Mode | Behavior |
|---|---|
| None | Leave bars untouched (default) |
| RSI Zone | Theme-bear when RSI in OB zone, theme-bull when in OS zone, theme-neutral otherwise |

Uses the *adaptive* OB / OS thresholds, not fixed 30 / 70. The bar painter pulls directly from the active threshold state — when the optimiser switches candidates, the bar colour rule updates accordingly with no lag.


[b]🟦 DASHBOARD[/b]

A compact 2-column, 8-row PRO data panel renders on the last bar when enabled. Every value derives from variables already computed upstream, so the dashboard adds zero overhead until the final bar.

| Row | Left | Right |
|---|---|---|
| Header | Artemis A-RSI | ▲ OB / ▼ OS / ■ Neutral (current bias) |
| Phase | Phase | ◐ ✸ ➜ ▣ ⊠ glyph + name (current regime) |
| Period | Period | Active RSI length (e.g. 14) |
| Smooth | Smooth | Active Supersmoother smoothing (e.g. 10) |
| OS Level | OS | Active adaptive OS threshold (e.g. 20) |
| OB Level | OB | Active adaptive OB threshold (e.g. 80) |
| Score | Score | Champion's mean forward return (in %) |
| Last Div | Last Div | Most recent divergence within last 50 bars (D▲ / D▼ / H▲ / H▼ / —) |

[b]**Theme-Adaptive Chrome**[/b]

The dashboard auto-inverts its layout based on the active theme:

- **Dark themes** (Tropic, Amber, Pastel, Cyber, Helios, Electric, Candy, Bloomberg, Solar, Royal): header and footer use a faint `thBull` tint, middle rows stay solid dark, text uses full-saturation `thBull`. Border uses `thBull` at 20% transparency for strong theme presence.
- **Light themes** (Midnight, Graphite): backgrounds flip to white, text stays `thBull` (which is itself dark on these themes), border uses `thBull` at 40% transparency.

This guarantees text legibility against every palette without per-theme manual tuning.

[b]**Position & Size**[/b]

Six anchor slots (Top / Middle / Bottom × Left / Right) and four text sizes (Tiny / Small / Normal / Large).


[b]🟦 COLOR THEMES[/b]

Twelve cohesive palettes, each resolving to four axis colors. The whole script reads through these four variables — nothing below the theme resolver references a raw hex literal, so a single dropdown selection drives every plot, fill, stepline, divergence line, dashboard cell and badge.

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


[b]🟦 ALERT SYSTEM[/b]

Seven user toggles drive nine alert messages, all using `alert.freq_once_per_bar_close`:

| Toggle | Alert(s) | Condition |
|---|---|---|
| OS Entry Trigger | OS Entry | RSI crossed down through adaptive OS |
| OB Exit Trigger | OB Exit | RSI crossed back down through adaptive OB |
| Regime Change | Phase Flip | Locked regime label updates (post-hysteresis) |
| Regular Divergence | D▲ + D▼ | Reversal divergences detected (respects Smart AI Filter) |
| Hidden Divergence | H▲ + H▼ | Continuation divergences detected (respects Smart AI Filter) |
| RSI Mid Cross Up | Mid ↑ | RSI crossed above 50 |
| RSI Mid Cross Down | Mid ↓ | RSI crossed below 50 |

Each alert fires through `alert()` so the message body carries live context — current RSI value, the active adaptive threshold that triggered, active period and smoothing, and (for Regime Change) the previous phase's hold duration. Divergence alerts respect the Smart AI Filter — if the filter is ON and a divergence is rejected visually, the alert will also not fire.


[b]🟦 SETTINGS REFERENCE[/b]

[b]**Visual**[/b]
- Theme — 12 palette options. Default: Tropic

[b]**Adaptation Core**[/b]
- Optimization Lookback (bars) — 100–1000. Default: 300
- Forward-Return Eval Horizon — 2–20. Default: 5
- Min Triggers per Candidate — ≥ 2. Default: 5
- Switch Margin (%) — 0–50, step 2.5. Default: 10

[b]**Regime Label**[/b]
- Show Regime Label — Toggle. Default: ON
- Regime Label Size — Tiny / Small / Normal / Large / Huge. Default: Normal
- Regime Confirmation Bars — 1–100. Default: 10
- Regime Label Position — Top / Middle / Bottom. Default: Middle

[b]**Zones & Levels**[/b]
- Show Adaptive Levels — Toggle. Default: ON
- Show Zone Fills — Toggle. Default: ON
- Show Trigger Signals — Toggle. Default: ON

[b]**Divergence**[/b]
- Regular Divergence — Toggle. Default: ON
- Regular Opacity — 0–100. Default: 80
- Hidden Divergence — Toggle. Default: ON
- Hidden Opacity — 0–100. Default: 80
- Pivot Arm — 2–50. Default: 5
- Label Size — Tiny / Small / Normal / Large. Default: Tiny
- Smart AI Filter — Master toggle. Default: OFF
- Min RSI Swing — 1.0–50.0. Default: 5.0
- Min Price Swing (%) — 0.1–5.0. Default: 0.3
- Require Zone Confirmation — Toggle. Default: ON

[b]**Bar Coloring**[/b]
- Bar Color Mode — None / RSI Zone. Default: None

[b]**Dashboard**[/b]
- Show Dashboard — Toggle. Default: ON
- Panel Position — 6 anchor slots. Default: Middle Right
- Panel Text Size — Tiny / Small / Normal / Large. Default: Small

[b]**Alerts**[/b]
- OS Entry Trigger — Default: ON
- OB Exit Trigger — Default: ON
- Regime Change — Default: ON
- Regular Divergence — Default: ON
- Hidden Divergence — Default: OFF
- RSI Mid Cross Up — Default: OFF
- RSI Mid Cross Down — Default: OFF


[b]🟦 COMPATIBILITY[/b]

Works on all asset classes and all timeframes in TradingView Pine Script v6.

- Crypto: Spot, futures, perpetual contracts
- Forex: All pairs
- Equities: Stocks, ETFs, indices
- Commodities: Metals, energy, agriculture
- Timeframes: 1m through Monthly

Because the engine self-tunes its RSI period, smoothing, and OB / OS thresholds online, the same default settings work on a 5-second BTC chart and a weekly index chart without retuning. The optimiser sees the asset's actual reversion behaviour and adapts — no per-asset preset library needed.


[b]🟦 TECHNICAL NOTES[/b]

- Pine Script v6
- `max_lines_count = 500`, `max_labels_count = 500`, `max_bars_back = 1000`
- No repainting — all values calculated on bar close. Pivot-based divergence results appear `Pivot Arm` bars late by design (standard Pine pivot confirmation behaviour)
- The adaptive RSI line is internally consistent across optimiser switches — divergence pivots read RSI dynamically via `activeRsi[bar_index − pivotBx]`, so both endpoints come from the SAME (current) RSI series even when the champion changes between pivots
- The Supersmoother filter relies on `var float lpY = 0.0` private state per call-site — Pine v6 issues one independent state slot per call-site, so the 15 fleet entries below produce 30 (15 × 2 streams) independent filter histories with zero cross-talk
- Champion switch is hysteresis-gated by `Switch Margin (%)` and an eligibility floor (`Min Triggers per Candidate`) — protects against bar-by-bar flapping when two candidates trade marginal scores
- Regime tag is doubly hysteresis-gated — first the candidate must hold, then the displayed phase only flips after `Regime Confirmation Bars` of stable tagging
- Trigger markers use `location.absolute` with fixed Y coordinates (10 / 90) for visual stability — no slide on zoom or candle-spacing changes
- Trigger marker tooltips piggy-back on invisible `label.style_circle` parallel renders — `plotshape()` does not natively support the `tooltip` argument


[b]🟦 DISCLAIMER[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Past performance does not guarantee future results. Always conduct your own analysis and apply proper risk management.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// Artemis Adaptive RSI
// Author  : © a_jabbaroff
// Version : 1.0.0
//
// License : Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
// ❤️ Crafted with love for TradingView traders — every line here exists so
//     your next chart reads cleaner and your next trade lands sharper.
// ═══════════════════════════════════════════════════════════════════════════════
//
// DESCRIPTION
//   Artemis Adaptive RSI is a self-tuning RSI workbench: a 60-candidate
//   optimisation grid scores Supersmoother-filtered RSI variants against
//   their own forward-return performance on a rolling scoreWindow window, then
//   picks the variant whose threshold trips deliver the cleanest mean-
//   reversion edge on the current market. The active period, smoothing and
//   OB / OS thresholds update online; a five-state regime label tells you
//   why the optimiser chose what it chose; a Stochastic-Extreme-style
//   multi-band zone UI surfaces the threshold trips visually; pivot-based
//   divergence detection runs against the active RSI line; and a theme-
//   adaptive PRO dashboard summarises the whole stack at a glance.
//
// COMPONENTS
//   Supersmoother    — Ehlers two-pole Butterworth filter applied to gains
//                      / losses before the RSI ratio. Removes high-frequency
//                      noise without lag piling, the way EMA / RMA pre-
//                      smoothing does.
//   Candidate Grid   — 60 variants (5 periods × 3 smoothings × 4 threshold
//                      tiers) — 7 / 10 / 14 / 21 / 28 RSI lengths ×
//                      6 / 10 / 16 SS smoothing × 15-85 / 20-80 / 25-75 /
//                      30-70 OS-OB pairs.
//   Online Optimiser — Rolling-window incremental scoring on each bar:
//                      every candidate's trigger is evaluated against its
//                      forward return `eval_bars` ahead; per-candidate
//                      mean returns rebuild on add / subtract O(1) per
//                      candidate. Winner switches when its mean beats the
//                      incumbent by `switch_margin` %.
//   Regime Classifier— Five-state regime (Adapting / Noisy / Trending /
//                      Range / Calm) inferred from the winning candidate's
//                      shape + score. Hysteresis-gated: the candidate must
//                      hold for `regime_hysteresis` bars before promotion.
//   Multi-Band Zones — Stochastic-Extreme-style 6-band zone visual at
//                      100 / 80 / 70 / 50 / 30 / 20 / 0. The active OB / OS
//                      thresholds overlay as steplines that move as the
//                      optimiser updates. Zone fills key off the *adaptive*
//                      thresholds so the visual escalation tracks the
//                      actual signal logic.
//   Divergence       — Pivot-based Regular + Hidden bull / bear divergence
//                      detection: pivots are sampled on raw price (high /
//                      low) and the active RSI value at each pivot bar is
//                      read dynamically from the *current* RSI series, so
//                      the comparison stays internally consistent even when
//                      the optimiser switches candidates between pivots.
//                      Lines paint between the two pivot bars; an optional
//                      Smart AI Filter (min RSI swing, min price swing %,
//                      adaptive zone confirmation) gates low-conviction
//                      signals.
//   Trigger Markers  — Triangle markers fire at the bar of OS entry / OB
//                      exit on the *adaptive* thresholds. These are the
//                      historically-validated mean-reversion entries the
//                      optimiser is scoring.
//   Bar Painter      — Optional chart-wide bar colouring driven by the
//                      live RSI zone state (OB / OS / neutral).
//   Dashboard        — Compact 8-row PRO panel: Bias / Regime / Period /
//                      Smooth / OS Level / OB Level / Score / Last Div —
//                      theme-adaptive chrome that auto-flips to light
//                      canvas on Midnight / Graphite themes.
//   Theme Palette    — Twelve cohesive palettes (ported from the Artemis
//                      brand family) drive every plot, fill, gauge, line
//                      and dashboard cell.
//
// CORE PHILOSOPHY
//   Most RSI indicators ship with a fixed period and fixed thresholds —
//   then traders babysit the inputs across regimes (14 / 70 / 30 on stocks,
//   7 / 80 / 20 on crypto, 21 / 60 / 40 in trends). Artemis Adaptive RSI
//   collapses that babysitting into a single optimisation loop: every bar
//   the indicator picks the RSI variant that *has been working* on the
//   current asset and regime. The Stochastic-Extreme-style UI keeps the
//   familiar multi-band zone readability; the regime label tells you when
//   to trust the triggers (Range / Calm) vs. step aside (Trending /
//   Noisy); one theme dropdown paints the whole stack consistently — no
//   inline colour pickers, no palette drift, no pane-hopping.
//
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Artemis Adaptive RSI", shorttitle = "Artemis ARSI", overlay = false, precision = 2, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000, explicit_plot_zorder = true)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — INPUT DECLARATIONS
// Every user-configurable setting lives here, organised by component group.
// Group constants are declared first so every input below can share them.
// ═══════════════════════════════════════════════════════════════════════════════

string GRP_THEME = "Visual 🔹"
string GRP_CORE  = "Adaptation Core 🔹"
string GRP_REG   = "Regime Label 🔹"
string GRP_ZONE  = "Zones & Levels 🔹"
string GRP_DIV   = "Divergence 🔹"
string GRP_BAR   = "Bar Coloring 🔹"
string GRP_DASH  = "Dashboard 🔹"
string GRP_ALRT  = "Alerts 🔹"

// ── Color Theme ──────────────────────────────────────────────────────────────
// Twelve cohesive palettes, one control. The theme dropdown is the single
// source of truth for every coloured component — RSI line, zone fills, OS /
// OB steplines, divergence lines and dashboard chrome — all resolve through
// the four switch blocks below.

themeChoice = input.string("Tropic", "Theme",
     options = ["Tropic", "Amber", "Pastel", "Cyber", "Helios", "Electric", "Candy", "Bloomberg", "Solar", "Royal", "Midnight", "Graphite"],
     group   = GRP_THEME,
     tooltip = "Applies a complete color palette across all Artemis Adaptive RSI components.\nOne selection governs the RSI line, zone fills, OS / OB steplines, divergence lines and Dashboard.\n\nTropic — Cyan steel + deep orange (electric contrast — default)\n\nAmber — Warm amber + indigo blue (fire tones)\n\nPastel — Sky blue + soft lavender (cool arctic glow)\n\nCyber — Neon lime + hot crimson (cyber terminal)\n\nHelios — Bright gold + scarlet (solar warmth)\n\nElectric — Electric aqua + magenta (high-voltage neon)\n\nCandy — Neon green + hot pink (dark energy pop)\n\nBloomberg — Terminal orange + cyan (Wall Street finance heritage — PRO)\n\nSolar — Solarized olive + crimson (developer palette, easy on the eyes — PRO)\n\nRoyal — Imperial gold + deep purple (luxury signature — PRO)\n\nMidnight — Deep navy + dark crimson (dark depth)\n\nGraphite — Near-black + silver grey (monochrome minimal)")

// ── Theme color resolver ─────────────────────────────────────────────────────
// Each theme resolves to four axis colours. The whole script reads from
// these resolved variables — nothing below this block references a raw hex
// literal, so a theme change cascades everywhere with one dropdown click.
//   thBull    — bullish / oversold side (RSI in OS zone, bull div, line up)
//   thBear    — bearish / overbought side (RSI in OB zone, bear div, line dn)
//   thNeutral — desaturated mid tone (midline, neutral zone, no-div state)
//   thSignal  — pastel tint of thBull (stepline halo, dashboard chrome)

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

// ── Bar Coloring ─────────────────────────────────────────────────────────────
// Optional chart-wide bar colouring driven by the live RSI zone state.
// Keeps the price pane in sync with the oscillator pane without forcing
// a switch to the bar painter mode.

simple string barMode = input.string("None", "Bar Color Mode",
     options = ["None", "RSI Zone"],
     group   = GRP_BAR,
     tooltip = "Applies a state-driven colour to every price bar on the chart.\n\nNone → leave bars untouched (default)\nRSI Zone → theme-bear when RSI in OB zone, theme-bull when in OS zone, theme-neutral otherwise\n\nUses the *adaptive* OB / OS thresholds, not fixed 30 / 70.")

// ── Adaptation Core ──────────────────────────────────────────────────────────
// Four knobs steer the fleet scorer: the rolling window it grades slots
// over, the forward horizon each trigger is judged against, the hysteresis
// moat that protects an incumbent champion from noise-level challenges, and
// the eligibility floor that disqualifies under-sampled slots. Defaults are
// tuned for general-purpose use across stocks / crypto / FX timeframes.

simple int scoreWindow = input.int(300, "Optimization Lookback (bars)",
     minval = 100, maxval = 1000,
     group   = GRP_CORE,
     tooltip = "Rolling-window size the fleet scorer grades slots over.\n\n100–200 → reactive adaptation, more jitter (intraday / crypto)\n300 → balanced — default (general-purpose baseline)\n500–1000 → very slow adaptation, ultra-stable (daily / weekly setups)\n\nLonger windows reward slots with more historical wins; shorter windows lock onto current-regime behaviour faster but flip more often.")

simple int fwdHorizon = input.int(5, "Forward-Return Eval Horizon",
     minval = 2, maxval = 20,
     group   = GRP_CORE,
     tooltip = "Bars forward to measure each trigger's mean-reversion success. The optimiser scores `close[t + fwdHorizon] / close[t] − 1` for OS entries (positive direction) and the negated version for OB exits (short direction).\n\n2–3 → ultra-fast mean reversion (scalp)\n5 → balanced — default\n10–20 → slower mean reversion (swing / position)\n\nMust be shorter than `scoreWindow` by a wide margin.")

simple float flipMoat = input.float(10.0, "Switch Margin (%)",
     minval = 0.0, maxval = 50.0, step = 2.5,
     group   = GRP_CORE,
     tooltip = "Hysteresis on the optimiser. A new winning candidate must beat the current incumbent's mean return by this percentage before it actually takes over.\n\n0 → no hysteresis, switches on every micro-improvement (noisy)\n10 → balanced — default\n25–50 → very sticky parameters (stable, slower to adapt)\n\nProtects against flip-flopping when two candidates trade leadership bar by bar.")

simple int minSamples = input.int(5, "Min Triggers per Candidate",
     minval = 2,
     group   = GRP_CORE,
     tooltip = "Minimum number of triggers a candidate must fire inside the scoreWindow window to be eligible to win. Candidates with fewer triggers are disqualified — too few samples to score reliably.\n\n2–3 → permissive (more candidates eligible, less reliable scores)\n5 → balanced — default\n10+ → strict (only well-sampled candidates eligible)")

// ── Regime Label ─────────────────────────────────────────────────────────────
// A floating label at the top of the pane summarises the current optimiser
// regime — Adapting / Noisy / Trending / Range / Calm. Hysteresis-gated so
// the label only updates when the underlying classification holds for
// `phaseHold` bars in a row.

simple bool   showPhase = input.bool(true, "Show Regime Label",
     group   = GRP_REG,
     tooltip = "Master toggle for the floating regime label at the top of the pane. The label reports:\n\n• Adapting — optimiser still warming up (< scoreWindow + fwdHorizon bars of history)\n• Noisy — mean-reversion edge weak, score near zero with heavy smoothing — wait\n• Trending — long period + relaxed thresholds — mean reversion less reliable, favour continuation\n• Range — short period + strict thresholds — RSI triggers most reliable here\n• Calm — middling configuration — mild swings, use as light confluence")

simple string phaseSize = input.string("Normal", "Regime Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = GRP_REG,
     tooltip = "Size of the floating regime label. Normal is the default and works on most chart sizes.")

simple int    phaseHold = input.int(10, "Regime Confirmation Bars",
     minval = 1, maxval = 100,
     group   = GRP_REG,
     tooltip = "Bars the underlying classification must hold continuously before the displayed regime label updates.\n\n1–3 → label reacts immediately, more flicker\n10 → balanced — default (label stable, still reactive)\n30+ → very stable label, slow to react to genuine regime shifts\n\nThe optimiser still re-classifies on every bar; this only gates the displayed label, not the underlying RSI selection.")

simple string phasePos  = input.string("Middle", "Regime Label Position",
     options = ["Top", "Middle", "Bottom"],
     group   = GRP_REG,
     tooltip = "Vertical placement of the regime label inside the pane. The label is anchored at the LATEST bar and extends RIGHTWARD into the chart's right-margin / future area (label.style_label_left convention — small triangular pointer on the left points back to the data).\n\nTop → y = 80 (upper third)\nMiddle → y = 50 (centred on midline — default)\nBottom → y = 20 (lower third)\n\nNote: relies on TradingView's right-margin offset being non-zero (the default is ~20 bars). If your chart's right margin is disabled, extend it in Chart settings → Scales.")

// ── Zones & Levels ───────────────────────────────────────────────────────────
// Multi-band Stochastic-Extreme-style zone UI. Fixed bands at
// 100 / 80 / 70 / 50 / 30 / 20 / 0 give a stable visual reference; the
// active adaptive OB / OS levels overlay as theme-coloured steplines that
// move as the optimiser updates. Zone fills key off the *adaptive*
// thresholds so the visual escalation tracks the live signal logic.

simple bool showLevels  = input.bool(true, "Show Adaptive OB / OS Lines",
     group   = GRP_ZONE,
     tooltip = "Renders the active adaptive OB and OS levels as theme-coloured stepline overlays. The lines step up / down as the optimiser updates its threshold tier choice. Turn OFF for a cleaner pane (the adaptive thresholds still drive signals — only their visual is hidden).")

simple bool showZones   = input.bool(true, "Show Zone Fills",
     group   = GRP_ZONE,
     tooltip = "Multi-tier zone fill — the headline Stochastic-Extreme-style visual. Zone intensity escalates as the RSI line pushes deeper into the OB / OS zone:\n\n• Light (entering) — RSI just inside the band, no trigger yet\n• Medium (in zone) — RSI deeper inside the band\n• Solid (rejection) — OB exit / OS entry trigger just fired on the *adaptive* threshold\n\nFills key off the adaptive OB / OS thresholds, not the fixed visual bands, so the colour escalation tracks the actual signal logic.")

simple bool showSignals = input.bool(true, "Show Trigger Markers",
     group   = GRP_ZONE,
     tooltip = "Triangle markers fire on the bar where the adaptive RSI crosses the active OS / OB threshold:\n\n• ▲ Buy — RSI just dropped below the adaptive OS level (mean-reversion long trigger)\n• ▼ Sell — RSI just dropped below the adaptive OB level from above (rejection / short trigger)\n\nThese are the historically-validated mean-reversion entries the optimiser is scoring. Markers respect the adaptive thresholds, not fixed 30 / 70.")

// ── Divergence ───────────────────────────────────────────────────────────────
// Regular and Hidden divergence detection on price-pivot vs. RSI-pivot
// pairs. Regular divergences signal potential reversals (price + RSI move
// in opposite directions); Hidden divergences signal trend continuation
// (price + RSI move in the same direction with mismatched magnitudes).
// The Smart AI Filter is OFF by default — flip on for high-conviction only.

simple bool   divRegOn = input.bool(true, "Regular Divergence",
     group   = GRP_DIV,
     tooltip = "Detects potential trend reversals.\n\nBull (D▲): price Lower Low + RSI Higher Low → reversal up\nBear (D▼): price Higher High + RSI Lower High → reversal down\n\nSolid lines connect the two pivots. Results appear `Pivot Arm` bars late — expected Pine Script pivot behaviour.")

simple int    divRegAlpha = input.int(80, "Regular Opacity",
     minval = 0, maxval = 100,
     group   = GRP_DIV,
     tooltip = "Line and label opacity for Regular Divergences.\n\n0 → fully transparent (invisible)\n80 → bright — default\n100 → fully opaque\n\nIntuitive scale: higher number = more visible.")

simple bool   divHidOn = input.bool(true, "Hidden Divergence",
     group   = GRP_DIV,
     tooltip = "Detects trend-continuation signals.\n\nBull (H▲): price Higher Low + RSI Lower Low → uptrend continues\nBear (H▼): price Lower High + RSI Higher High → downtrend continues\n\nDashed lines connect the two pivots. Use these to add to an existing position in the trend's direction, not as reversal triggers.")

simple int    divHidAlpha = input.int(80, "Hidden Opacity",
     minval = 0, maxval = 100,
     group   = GRP_DIV,
     tooltip = "Line and label opacity for Hidden Divergences.\n\nKept slightly dimmer than Regular Divergence by default so the two flavours read at distinct visual tiers.\n\n0 → fully transparent (invisible)\n60 → readable — default\n100 → fully opaque")

simple int    divPivSpan = input.int(5, "Pivot Arm",
     minval = 2, maxval = 50,
     group   = GRP_DIV,
     tooltip = "Bars to the left AND right required to confirm a pivot (symmetric arm). Higher = more significant pivots, fewer divergences; each divergence carries a `divPivSpan`-bar confirmation delay.\n\n2–3 → reactive, more flicker\n5 → balanced — default\n10+ → strict, only major pivots qualify")

simple string divLabelSize = input.string("Tiny", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DIV,
     tooltip = "Size of the D▲ D▼ H▲ H▼ divergence markers.\n\nTiny → minimal, default\nSmall → slightly larger\nNormal → standard\nLarge → maximum visibility")

simple bool   sdfOn = input.bool(false, "Smart Divergence Filter (AI)",
     group   = GRP_DIV,
     tooltip = "AI-assisted filter that suppresses weak or low-quality divergences.\n\nOFF (default) → all detected divergences pass through\nON → only divergences that clear all three gates below survive\n\nThe three gates:\n1. Min RSI Swing — drops oscillator differences below this size\n2. Min Price Swing (%) — drops divergences where price barely moved\n3. Zone Confirmation — bull divergences must form in the OS half, bear divergences in the OB half (best context)\n\nTurn ON for fewer, higher-conviction signals only.")

simple float  sdfMinRsi = input.float(5.0, "Min RSI Swing",
     minval = 1.0, maxval = 50.0, step = 0.5,
     group   = GRP_DIV,
     tooltip = "Minimum RSI swing between the two pivots (in RSI points, 0-100 scale).\n\nSmall (1–3) → permissive, allows minor divergences through\nMedium (5) → balanced — default\nLarge (10–20) → only structurally significant divergences pass\n\nRequires Smart Filter ON.")

simple float  sdfMinPct = input.float(0.3, "Min Price Swing (%)",
     minval = 0.1, maxval = 5.0, step = 0.1,
     group   = GRP_DIV,
     tooltip = "Minimum price swing between the two pivots as a percentage of the recent (80 bars) price range.\n\nFilters divergences caused by tiny price moves relative to volatility.\n\n0.3% → permissive — default\n1.0% → moderate\n2.0%+ → strict (price swing must be visibly significant)\n\nRequires Smart Filter ON.")

simple bool   sdfZoneConf = input.bool(true, "Require Zone Confirmation",
     group   = GRP_DIV,
     tooltip = "Restricts divergences to the matching reversion half:\n\n• Bullish divergence — RSI at the current pivot must be ≤ midpoint(liveOs, 50) (i.e. in moderate-to-deep oversold territory)\n• Bearish divergence — RSI at the current pivot must be ≥ midpoint(50, liveOb) (i.e. in moderate-to-deep overbought territory)\n\nEncodes the classic 'best divergences form at extremes' rule — the gate adapts as the optimiser updates the active OS / OB thresholds.\n\nRequires Smart Filter ON. Default: ON.")

// ── Dashboard ────────────────────────────────────────────────────────────────
// Compact PRO data table drawn on the last bar. Mirrors the Artemis brand
// family convention so the whole catalogue feels like one product.

simple bool   showDash = input.bool(true, "Show Dashboard",
     group   = GRP_DASH,
     tooltip = "Master toggle for the on-chart data panel.\n\nShows at a glance:\n• Bias — current zone state (OB / OS / Neutral)\n• Regime — Adapting / Noisy / Trending / Range / Calm\n• Period — active RSI period\n• Smooth — active SS smoothing\n• OS Level — current adaptive OS threshold\n• OB Level — current adaptive OB threshold\n• Score — winning candidate's mean forward return\n• Last Div — most recent divergence within the last 50 bars\n\nColours are driven by the active Theme. On Midnight / Graphite themes the panel automatically flips to a light background so the text stays readable against dark plots.")

simple string dashPos  = input.string("Middle Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_DASH,
     tooltip = "Anchor position inside the indicator pane where the dashboard docks. Six slots — three vertical bands × two sides. Pick whichever does not overlap your other indicators or labels.")

simple string dashSize = input.string("Small", "Panel Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DASH,
     tooltip = "Text size inside the dashboard. Small is the default and matches the rest of the Artemis brand family.")

// ── Alerts ───────────────────────────────────────────────────────────────────
// Opt-in toggles for every core event. Each alert is gated by its switch —
// hiding a feature on the chart silences its alerts automatically.

simple bool alrtOsEntry  = input.bool(true,  "OS Entry Trigger",
     group   = GRP_ALRT,
     tooltip = "Fires when the active adaptive RSI drops below the active OS threshold — the optimiser's preferred mean-reversion long trigger.")

simple bool alrtObExit   = input.bool(true,  "OB Exit Trigger",
     group   = GRP_ALRT,
     tooltip = "Fires when the active adaptive RSI drops below the active OB threshold from above — the optimiser's preferred mean-reversion short / rejection trigger.")

simple bool alrtRegime   = input.bool(true,  "Regime Change",
     group   = GRP_ALRT,
     tooltip = "Fires the bar the displayed regime label updates (after the hysteresis gate is cleared). Useful as a heads-up that the optimiser's reading of the market has shifted.")

simple bool alrtDivReg   = input.bool(true,  "Regular Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Regular bullish or bearish divergence detection.\n\nBull (D▲): price Lower Low + RSI Higher Low → reversal up\nBear (D▼): price Higher High + RSI Lower High → reversal down\n\nRespects the Smart Filter when enabled. Subject to the Pivot Arm confirmation delay.")

simple bool alrtDivHid   = input.bool(false, "Hidden Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Hidden bullish or bearish divergence detection.\n\nBull (H▲): price Higher Low + RSI Lower Low → uptrend continues\nBear (H▼): price Lower High + RSI Higher High → downtrend continues\n\nOFF by default — Hidden divergences fire more frequently than Regular. Respects the Smart Filter when enabled.")

simple bool alrtMidUp    = input.bool(false, "RSI Mid Cross Up",
     group   = GRP_ALRT,
     tooltip = "Fires when the active RSI crosses above 50 (bullish regime flip). OFF by default to keep noise low.")

simple bool alrtMidDn    = input.bool(false, "RSI Mid Cross Down",
     group   = GRP_ALRT,
     tooltip = "Fires when the active RSI crosses below 50 (bearish regime flip). OFF by default to keep noise low.")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — GRID DIMENSIONS & PHASE CODES
// Three small integer triples carry the entire combinatorial geometry of
// the optimiser plus the five market-phase tags. Declared as bare ints
// (not `var` and not `simple int`) so the v6 compiler folds them as
// compile-time constants — the search loops below unroll cleanly and the
// phase classifier collapses to a straight chain of integer equalities.
// ═══════════════════════════════════════════════════════════════════════════════

// Grid geometry — three orthogonal axes whose product defines the fleet:
//   N_LEN     — 5 RSI length presets (7 / 10 / 14 / 21 / 28)
//   N_SMOOTH  — 3 Supersmoother smoothing presets (6 / 10 / 16)
//   N_LVL     — 4 OS / OB threshold pairs (15-85 / 20-80 / 25-75 / 30-70)
//   N_FLEET   — flat fleet size: 5 × 3 × 4 = 60 candidate variants.
N_LEN    = 5
N_SMOOTH = 3
N_LVL    = 4
N_FLEET  = N_LEN * N_SMOOTH * N_LVL

// Market-phase tags — fed into the hysteresis state machine in Section 7.
// Integer codes (not strings) so promotion comparisons stay branchless.
//   PH_WARMUP — cold start, optimiser not yet armed
//   PH_FOG    — score collapsed, no exploitable edge — sit out
//   PH_RUSH   — long period + relaxed thresholds, trend-dominant
//   PH_BOUNCE — short period + strict thresholds, RSI's best home
//   PH_DRIFT  — middling parameters, mild swings — light confluence
PH_WARMUP = 0
PH_FOG    = 1
PH_RUSH   = 2
PH_BOUNCE = 3
PH_DRIFT  = 4

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — CORE PRIMITIVES & RSI FLEET
// Two compute primitives — a two-pole Butterworth low-pass and a smoothed
// RSI ratio built on top of it — plus the static 15-variant RSI fleet that
// the optimiser scores against. The `var float lpY = 0.0` inside dualPoleLP
// is load-bearing: Pine v6 issues one private state slot per call-site, so
// the 15 fleet entries below produce 30 independent filter histories with
// zero cross-talk. Removing the `var` keyword or lifting the filter state
// out of the function silently corrupts every downstream reading.
// ═══════════════════════════════════════════════════════════════════════════════

// Two-pole Butterworth low-pass — Ehlers' coefficient construction. Smooths
// the input stream without piling on the phase lag that naive EMA / RMA
// chains accumulate, which matters because we smooth gains / losses ONCE
// before forming the RSI ratio rather than smoothing the RSI itself.
dualPoleLP(float src, simple int period) =>
    decay  = math.exp(-math.sqrt(2) * math.pi / period)
    osc    = 2 * decay * math.cos(math.sqrt(2) * math.pi / period)
    feedA  = osc
    feedB  = -decay * decay
    feedC  = 1 - feedA - feedB
    var float lpY = 0.0
    prevX  = nz(src[1], src)
    prevY1 = nz(lpY[1], src)
    prevY2 = nz(lpY[2], src)
    lpY := feedC * (src + prevX) / 2 + feedA * prevY1 + feedB * prevY2
    lpY

// Harmonic-smoothed RSI — split the per-bar close change into positive /
// negative halves, route each half through the low-pass, then drop the
// ratio into the classical Wilder formula. Returns na on flat markets
// (zero loss stream → ratio collapses to na, propagating cleanly downstream).
harmRsi(simple int rsiLen, simple int smoothLen) =>
    delta    = ta.change(close)
    upStream = math.max(delta,  0)
    dnStream = math.max(-delta, 0)
    upSmooth = dualPoleLP(upStream, smoothLen)
    dnSmooth = dualPoleLP(dnStream, smoothLen)
    relStr   = dnSmooth == 0 ? na : upSmooth / dnSmooth
    100 - 100 / (1 + relStr)

// ── The 15-RSI grid — 5 periods × 3 smoothings ──────────────────────────────
// All 15 variants are precomputed every bar so the optimiser can score them
// in lockstep. Period and smoothing arguments must be `simple int` literals
// here — that's why the grid is expanded statically rather than looped.
harm_7_6   = harmRsi(7, 6)
harm_7_10  = harmRsi(7, 10)
harm_7_16  = harmRsi(7, 16)
harm_10_6  = harmRsi(10, 6)
harm_10_10 = harmRsi(10, 10)
harm_10_16 = harmRsi(10, 16)
harm_14_6  = harmRsi(14, 6)
harm_14_10 = harmRsi(14, 10)
harm_14_16 = harmRsi(14, 16)
harm_21_6  = harmRsi(21, 6)
harm_21_10 = harmRsi(21, 10)
harm_21_16 = harmRsi(21, 16)
harm_28_6  = harmRsi(28, 6)
harm_28_10 = harmRsi(28, 10)
harm_28_16 = harmRsi(28, 16)

// ── Dispatch ladders ────────────────────────────────────────────────────────
// `int` indices map back to the precomputed RSI series. Kept as if-ladders
// (not switch) because every branch is a series access, not a constant —
// switch with series arms would force every series to evaluate every bar
// regardless of the active path.
tapRsi(int pi, int si) =>
    float out = na
    if pi == 0 and si == 0
        out := harm_7_6
    else if pi == 0 and si == 1
        out := harm_7_10
    else if pi == 0 and si == 2
        out := harm_7_16
    else if pi == 1 and si == 0
        out := harm_10_6
    else if pi == 1 and si == 1
        out := harm_10_10
    else if pi == 1 and si == 2
        out := harm_10_16
    else if pi == 2 and si == 0
        out := harm_14_6
    else if pi == 2 and si == 1
        out := harm_14_10
    else if pi == 2 and si == 2
        out := harm_14_16
    else if pi == 3 and si == 0
        out := harm_21_6
    else if pi == 3 and si == 1
        out := harm_21_10
    else if pi == 3 and si == 2
        out := harm_21_16
    else if pi == 4 and si == 0
        out := harm_28_6
    else if pi == 4 and si == 1
        out := harm_28_10
    else if pi == 4 and si == 2
        out := harm_28_16
    out

// Same ladder, but historical lookup. The optimiser's `evalSlot(...)`
// helper needs to evaluate each candidate at bars in the past — `[back]` on
// the precomputed series is the cheapest way.
tapRsiPast(int pi, int si, int back) =>
    float out = na
    if pi == 0 and si == 0
        out := harm_7_6[back]
    else if pi == 0 and si == 1
        out := harm_7_10[back]
    else if pi == 0 and si == 2
        out := harm_7_16[back]
    else if pi == 1 and si == 0
        out := harm_10_6[back]
    else if pi == 1 and si == 1
        out := harm_10_10[back]
    else if pi == 1 and si == 2
        out := harm_10_16[back]
    else if pi == 2 and si == 0
        out := harm_14_6[back]
    else if pi == 2 and si == 1
        out := harm_14_10[back]
    else if pi == 2 and si == 2
        out := harm_14_16[back]
    else if pi == 3 and si == 0
        out := harm_21_6[back]
    else if pi == 3 and si == 1
        out := harm_21_10[back]
    else if pi == 3 and si == 2
        out := harm_21_16[back]
    else if pi == 4 and si == 0
        out := harm_28_6[back]
    else if pi == 4 and si == 1
        out := harm_28_10[back]
    else if pi == 4 and si == 2
        out := harm_28_16[back]
    out

// ── Threshold + parameter dispatchers ───────────────────────────────────────
// Map the threshold-tier index (ti) and period / smooth indices back to
// their actual values. Used by the optimiser scoring + display layers.
osLevel(int ti) =>
    ti == 0 ? 15.0 : ti == 1 ? 20.0 : ti == 2 ? 25.0 : 30.0

obLevel(int ti) =>
    ti == 0 ? 85.0 : ti == 1 ? 80.0 : ti == 2 ? 75.0 : 70.0

mapLen(int pi) =>
    pi == 0 ? 7 : pi == 1 ? 10 : pi == 2 ? 14 : pi == 3 ? 21 : 28

mapSmooth(int si) =>
    si == 0 ? 6 : si == 1 ? 10 : 16

// Pack a (pi, si, ti) triple into a flat index for the scoring arrays.
fleetKey(int pi, int si, int ti) =>
    pi * N_SMOOTH * N_LVL + si * N_LVL + ti

// Pine size-enum resolver. Mirrors the Artemis brand family's
// "string → size constant" pattern.
resolveSize(string s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large  :
                     size.huge

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — ROLLING-EDGE SCORER
// Per-slot trigger detection plus an online rolling-sum bookkeeping pass.
// `evalSlot(...)` inspects a single fleet entry at history offset `b` and
// returns a pair (eventClass, signedReturn) describing whether the slot
// fired a trigger that bar and, if so, how price moved `fwdHorizon` bars
// later. The bookkeeping loop below calls it twice per slot per bar —
// once to ADD the freshest just-ripened trigger (at b = fwdHorizon, the
// youngest bar whose forward return is now resolvable) and once to SUBTRACT
// the oldest trigger that just dropped off the trailing edge of the window
// (at b = scoreWindow). The net effect: each slot's running mean stays in
// lockstep with the trailing scoreWindow bars, refreshed in O(1) per slot
// per bar — no full-history rescan needed.
// ═══════════════════════════════════════════════════════════════════════════════

// Slot evaluator. Returns a 2-tuple:
//   eventClass == 0 → no trigger this bar
//   eventClass == 1 → OS-entry trigger (long-side mean reversion candidate)
//                     signedReturn = close[t+fwdHorizon]/close[t] − 1
//   eventClass == 2 → OB-exit trigger (short-side mean reversion candidate)
//                     signedReturn = −(close[t+fwdHorizon]/close[t] − 1)
// The negation on OB-exit flips the sign so a positive signedReturn ALWAYS
// reads as "mean reversion worked" regardless of trigger direction. This
// lets the optimiser maximise a single scalar across both trigger flavours.
evalSlot(int pi, int si, int ti, int b) =>
    int   eventClass   = 0
    float signedReturn = 0.0
    rsiHere   = tapRsiPast(pi, si, b)
    rsiPrior  = tapRsiPast(pi, si, b + 1)
    osLvl     = osLevel(ti)
    obLvl     = obLevel(ti)
    if not na(rsiHere) and not na(rsiPrior)
        enteredOs = rsiPrior >= osLvl and rsiHere < osLvl
        exitedOb  = rsiPrior >= obLvl and rsiHere < obLvl and rsiPrior > obLvl
        if enteredOs
            pxAtFire = close[b]
            pxLater  = close[b - fwdHorizon]
            if not na(pxAtFire) and not na(pxLater) and pxAtFire > 0
                eventClass   := 1
                signedReturn := pxLater / pxAtFire - 1
        else if exitedOb
            pxAtFire = close[b]
            pxLater  = close[b - fwdHorizon]
            if not na(pxAtFire) and not na(pxLater) and pxAtFire > 0
                eventClass   := 2
                signedReturn := -(pxLater / pxAtFire - 1)
    [eventClass, signedReturn]

// Rolling-window state — one running sum + one running count per candidate.
// Stored as flat arrays of length N_FLEET indexed by `fleetKey(pi, si, ti)`.
var array<float> accReturn  = array.new<float>(N_FLEET, 0.0)
var array<int>   popCount = array.new<int>(N_FLEET, 0)

// Online rolling-edge maintenance. Two operations per slot per bar:
// (1) ADD — fold in the freshest just-ripened trigger at b = fwdHorizon;
//     this is the youngest bar whose forward return horizon has fully
//     elapsed and is therefore safe to score.
// (2) SUB — peel off the trigger that just dropped off the trailing edge
//     at b = scoreWindow, keeping the window length stationary.
// Net result: each slot's accumulator tracks the EXACT trigger set inside
// the last `scoreWindow` bars, refreshed without ever rescanning history.
if bar_index > scoreWindow + fwdHorizon
    for pi = 0 to N_LEN - 1
        for si = 0 to N_SMOOTH - 1
            for ti = 0 to N_LVL - 1
                slotIdx = fleetKey(pi, si, ti)
                [addClass, addRet] = evalSlot(pi, si, ti, fwdHorizon)
                if addClass != 0
                    array.set(accReturn, slotIdx, array.get(accReturn, slotIdx) + addRet)
                    array.set(popCount,  slotIdx, array.get(popCount,  slotIdx) + 1)
                [subClass, subRet] = evalSlot(pi, si, ti, scoreWindow)
                if subClass != 0
                    array.set(accReturn, slotIdx, array.get(accReturn, slotIdx) - subRet)
                    array.set(popCount,  slotIdx, array.get(popCount,  slotIdx) - 1)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — CHAMPION SELECTION
// Crown the fleet slot whose rolling mean return is the highest among the
// candidates that have fired at least `minSamples` triggers in the current
// window. Apply a hysteresis moat (`flipMoat` %) before crowning a new
// champion so two near-tied slots cannot bounce the active configuration
// back and forth bar-by-bar.
// ═══════════════════════════════════════════════════════════════════════════════

// Incumbent state — defaults to a classical 14-period RSI with 10-bar
// Supersmoother and 25 / 75 thresholds (slot index 2,1,2). The optimiser
// is free to crown a new champion once the warm-up window is cleared.
var int   champLen    = 2
var int   champSmooth = 1
var int   champLvl    = 2
var float champScore  = na

if bar_index > scoreWindow + fwdHorizon
    float topScore  = na
    int   topLen    = champLen
    int   topSmooth = champSmooth
    int   topLvl    = champLvl

    // Single-pass scan of the 60-slot fleet. Eligibility gate: minSamples.
    // The first eligible slot seeds topScore (via the na-guard), every
    // subsequent slot competes on > comparison.
    for pi = 0 to N_LEN - 1
        for si = 0 to N_SMOOTH - 1
            for ti = 0 to N_LVL - 1
                slotIdx = fleetKey(pi, si, ti)
                hits    = array.get(popCount, slotIdx)
                if hits >= minSamples
                    meanRet = array.get(accReturn, slotIdx) / hits
                    if na(topScore) or meanRet > topScore
                        topScore  := meanRet
                        topLen    := pi
                        topSmooth := si
                        topLvl    := ti

    if not na(topScore)
        if na(champScore)
            // Cold-start path — the first eligible scan crowns
            // unconditionally; there is no incumbent to defend.
            champLen    := topLen
            champSmooth := topSmooth
            champLvl    := topLvl
            champScore  := topScore
        else
            // Refresh the sitting champion's score against the current
            // window. If still eligible, keep its live reading in sync so
            // the moat below has a fresh baseline. If no longer eligible,
            // leave the stored score untouched — the contender still has to
            // clear the OLD moat, which avoids letting the champion get
            // dethroned by a vacuum.
            incIdx   = fleetKey(champLen, champSmooth, champLvl)
            incHits  = array.get(popCount, incIdx)
            incMean  = incHits >= minSamples ? array.get(accReturn, incIdx) / incHits : na
            if not na(incMean)
                champScore := incMean

            // Hysteresis moat — the contender must clear the champion's
            // score by `flipMoat` % of |champScore| to depose. Stops the
            // active configuration from oscillating on noise.
            moat = math.abs(champScore) * flipMoat / 100.0
            if topScore > champScore + moat
                champLen    := topLen
                champSmooth := topSmooth
                champLvl    := topLvl
                champScore  := topScore

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — LIVE READING & ZONE STATE
// Resolve the crowned fleet slot into a single live RSI series plus its
// matching OS / OB levels and meta-parameters. Every downstream layer —
// plots, dashboard, alerts, divergence — pulls from this single resolved
// snapshot, never from the indices directly.
// ═══════════════════════════════════════════════════════════════════════════════

liveRsi = tapRsi(champLen, champSmooth)
liveOs  = osLevel(champLvl)
liveOb  = obLevel(champLvl)
liveLen   = mapLen(champLen)
liveSmooth   = mapSmooth(champSmooth)

// Zone state — quantised reading used by the dashboard / bar painter.
//   -1 → RSI below adaptive OS (long-trigger zone)
//    0 → between OS and OB (neutral)
//   +1 → RSI above adaptive OB (short-trigger zone)
zoneTag = na(liveRsi) ? na : liveRsi < liveOs ? -1 : liveRsi > liveOb ? 1 : 0

// ── Live trigger events ──────────────────────────────────────────────────────
// Identical to the evalSlot(...) detector's pattern but evaluated on the
// current bar — these drive the on-pane triangle markers and alerts.
osTrip = liveRsi[1] >= liveOs and liveRsi < liveOs
obTrip  = liveRsi[1] >= liveOb and liveRsi < liveOb and liveRsi[1] > liveOb

// Mid-cross transitions — supplementary regime-flip events for alerts.
midUpCross = ta.crossover (liveRsi, 50)
midDnCross = ta.crossunder(liveRsi, 50)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — MARKET-PHASE TAGGER
// Read the crowned champion's shape (length-index / smoothing-index /
// level-index / mean-return) and tag the current market as one of five
// phases. Then run the raw tag through a two-stage hysteresis lock so the
// displayed phase only flips after the underlying classification holds for
// `phaseHold` bars in a row — keeps the floating badge from twitching on
// every minor optimiser jitter.
// ═══════════════════════════════════════════════════════════════════════════════

// Per-bar raw tagger. Reads four heuristic signals off the live champion:
//   • champScore unset (cold start)                       → PH_WARMUP
//   • |champScore| ≈ 0  AND smoothing pinned to heaviest  → PH_FOG
//   • long period AND relaxed levels (permissive setup)   → PH_RUSH (trending)
//   • short period AND strict levels (tight setup)        → PH_BOUNCE (chop, ideal)
//   • anything else (middling config)                     → PH_DRIFT (quiet)
// Codes flow into the hysteresis machine below — they do NOT directly
// drive the displayed badge, the locked phase does.
tagPhase() =>
    int phCode = PH_WARMUP
    if na(champScore)
        phCode := PH_WARMUP
    else if math.abs(champScore) < 0.0005 and champSmooth == 2
        phCode := PH_FOG
    else if champLen >= 3 and champLvl >= 2
        phCode := PH_RUSH
    else if champLen <= 1 and champLvl <= 1
        phCode := PH_BOUNCE
    else
        phCode := PH_DRIFT
    phCode

freshPhase = tagPhase()

// Hysteresis lock — two-state confirmation machine over the raw tag stream.
// The pending phase tracks whatever raw tag the optimiser just emitted; the
// pending hold counts how many bars that raw tag has held in a row. The
// locked phase only advances when the pending hold clears the user-set
// `phaseHold` threshold AND the pending tag differs from the locked one.
// `lockedHold` is a free-running counter that ticks while the locked phase
// is stable, resetting to 1 the bar a new phase locks in. The dashboard
// reads `lockedHold` to show the "held N bars" suffix.
var int lockedPhase  = PH_WARMUP
var int pendingPhase = PH_WARMUP
var int pendingHold  = 0
var int lockedHold   = 0

if freshPhase == pendingPhase
    pendingHold += 1
else
    pendingPhase := freshPhase
    pendingHold  := 1

if pendingHold >= phaseHold and pendingPhase != lockedPhase
    lockedPhase := pendingPhase
    lockedHold  := 1
else
    lockedHold  += 1

// Edge detector for alerts — fires exactly once on the bar the locked
// phase rolls over, never again until the next promotion.
bool phaseFlipped = lockedPhase != lockedPhase[1]

// ── Phase text resolver ──────────────────────────────────────────────────────
// Resolve a phase code into its display triple: short label, action-focused
// note, and the theme-tinted colour to paint the floating badge with. The
// colour pulls from the resolved theme palette (thBull / thBear / thNeutral
// / thSignal) so a theme switch cascades through here automatically.
phaseInfo(int code) =>
    string lbl  = ""
    string desc = ""
    color  col  = thNeutral
    if code == PH_WARMUP
        lbl  := "◐ Adapting"
        desc := "Optimiser warming up — default RSI in use"
        col  := thNeutral
    else if code == PH_FOG
        lbl  := "✸ Noisy"
        desc := "No clean edge — best to stand aside"
        col  := thNeutral
    else if code == PH_RUSH
        lbl  := "➜ Trending"
        desc := "Trend dominant — avoid OB/OS reversals"
        col  := thBear
    else if code == PH_BOUNCE
        lbl  := "▣ Range"
        desc := "RSI's sweet spot — triggers work well"
        col  := thBull
    else
        lbl  := "⊠ Calm"
        desc := "Mild signals — use as confluence"
        col  := thSignal
    [lbl, desc, col]

[phaseTag, phaseNote, phaseTone] = phaseInfo(lockedPhase)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — DIVERGENCE DETECTION
// Pivot-based detection for the four classical divergence flavours:
//   Regular Bull / Bear → reversal signals (price + RSI move opposite ways)
//   Hidden  Bull / Bear → continuation signals (price + RSI same way, mismatched)
//
// Pivots are sampled on raw price (high / low) and the active RSI value at
// the pivot bar is captured in lock-step so the comparison is always taken
// at the same instant. The Smart AI Filter applies three independent gates —
// min RSI swing, min price swing %, zone confirmation. The master toggle is
// OFF by default for permissive detection; flip ON for high-conviction
// signals only.
// ═══════════════════════════════════════════════════════════════════════════════

// Symmetric pivot arm — pivots fire `divPivSpan` bars after the actual pivot
// (that's how Pine confirms pivots retroactively). Pivots are detected on
// PRICE — both highs and lows — and the RSI value at the same bar is
// captured for the divergence comparison.
float phRaw = ta.pivothigh(high, divPivSpan, divPivSpan)
float plRaw = ta.pivotlow (low,  divPivSpan, divPivSpan)

// Previous pivot anchors — bar index + price held in `var` state across
// bars. CRITICAL: the previous pivot's RSI value is NOT stored. Instead it
// is re-read from the *current* `liveRsi` series via a bar-index lookup
// (`pHH_r_now` / `pLL_r_now` below). This guarantees internal consistency
// when the optimiser switches candidates between two pivots — both pivot
// RSI values then come from the same (currently-active) series, never from
// two different series that would produce a meaningless apples-vs-oranges
// comparison.
//   pHH_* — previous price HIGH pivot     |   pLL_* — previous price LOW pivot
//   *_px  — price value at the pivot      |   *_bx  — bar index at the pivot
var float pHH_px = na
var int   pHH_bx = int(na)
var float pLL_px = na
var int   pLL_bx = int(na)

// Current-bar pivot capture — populated only on the bar where ta.pivothigh /
// ta.pivotlow fires. When no pivot fires, these stay na and the divergence
// checks below are gated off.
float cHH_p = na
float cHH_r = na
float cLL_p = na
float cLL_r = na

if not na(phRaw)
    cHH_p := high[divPivSpan]
    cHH_r := liveRsi[divPivSpan]

if not na(plRaw)
    cLL_p := low[divPivSpan]
    cLL_r := liveRsi[divPivSpan]

// Dynamic previous-pivot RSI lookup — read the RSI value at the previous
// pivot bar from the *currently active* series. `bar_index - pXX_bx` is the
// dynamic offset back to that bar; with max_bars_back = 1000, this comfortably
// covers any practical pivot spacing. Both `pHH_r_now` and `cHH_r` therefore
// always come from the same RSI variant, even after an optimiser switch.
float pHH_r_now = na(pHH_bx) ? na : liveRsi[bar_index - pHH_bx]
float pLL_r_now = na(pLL_bx) ? na : liveRsi[bar_index - pLL_bx]

// ── Raw divergence detection ─────────────────────────────────────────────────
// Four mutually exclusive flags. Each fires the bar a fresh pivot is
// confirmed and the prev-vs-curr comparison meets the divergence shape.
bool dRegBull = false  // price LL + RSI HL → reversal up
bool dRegBear = false  // price HH + RSI LH → reversal down
bool dHidBull = false  // price HL + RSI LL → uptrend continues
bool dHidBear = false  // price LH + RSI HH → downtrend continues

if not na(cHH_p) and not na(pHH_px) and not na(pHH_r_now)
    if cHH_p > pHH_px and cHH_r < pHH_r_now
        dRegBear := true
    if cHH_p < pHH_px and cHH_r > pHH_r_now
        dHidBear := true

if not na(cLL_p) and not na(pLL_px) and not na(pLL_r_now)
    if cLL_p < pLL_px and cLL_r > pLL_r_now
        dRegBull := true
    if cLL_p > pLL_px and cLL_r < pLL_r_now
        dHidBull := true

// ── Smart AI Filter ──────────────────────────────────────────────────────────
// Three independent gates evaluated when sdfOn is true. The min-swing gates
// reject noise-level differences; the zone gate encodes the classical
// "divergences are strongest at extremes" rule. The zone gate is adaptive —
// it tracks the optimiser's chosen OS / OB tier:
//   sdfZoneBull — bull pivot RSI must be ≤ midpoint(liveOs, 50) (OS half)
//   sdfZoneBear — bear pivot RSI must be ≥ midpoint(50, liveOb) (OB half)
float sdfPxRange  = ta.highest(high, 80) - ta.lowest(low, 80)
float sdfMinPxAbs = sdfPxRange * (sdfMinPct / 100.0)

float sdfRsSwLL = na(pLL_r_now) ? 0 : math.abs(cLL_r - pLL_r_now)
float sdfRsSwHH = na(pHH_r_now) ? 0 : math.abs(cHH_r - pHH_r_now)
float sdfPxSwLL = math.abs(cLL_p - pLL_px)
float sdfPxSwHH = math.abs(cHH_p - pHH_px)

bool sdfZoneBull = not sdfZoneConf or cLL_r <= math.avg(liveOs, 50.0)
bool sdfZoneBear = not sdfZoneConf or cHH_r >= math.avg(50.0, liveOb)

bool sdfPassBull = not sdfOn or (sdfRsSwLL >= sdfMinRsi and sdfPxSwLL >= sdfMinPxAbs and sdfZoneBull)
bool sdfPassBear = not sdfOn or (sdfRsSwHH >= sdfMinRsi and sdfPxSwHH >= sdfMinPxAbs and sdfZoneBear)

// ── Divergence palette + label-size resolver ─────────────────────────────────
// All four flavours pull from the active theme. Regular = thBull / thBear
// at full strength (the classic, most-trusted reversal signal). Hidden =
// the same palette but dashed lines for an obvious visual tier separation.
color colDivRegBull = color.new(thBull, 100 - divRegAlpha)
color colDivRegBear = color.new(thBear, 100 - divRegAlpha)
color colDivHidBull = color.new(thBull, 100 - divHidAlpha)
color colDivHidBear = color.new(thBear, 100 - divHidAlpha)

string divSz = (divLabelSize == "Tiny"   ? size.tiny   :
                divLabelSize == "Small"  ? size.small  :
                divLabelSize == "Normal" ? size.normal :
                                           size.large)

// ── Divergence rendering + last-event tracking ───────────────────────────────
// Each detected event paints a line between the two pivots and drops a
// tooltip-rich label at the current pivot. The lastDiv* pair persists
// across bars so the dashboard can report the most recent event.
var int    lastDivBar = int(na)
var string lastDivTag = "—"

if divRegOn and dRegBull and sdfPassBull
    line.new (pLL_bx, pLL_r_now, bar_index[divPivSpan], cLL_r, color = colDivRegBull, width = 1, style = line.style_solid)
    label.new(bar_index[divPivSpan], cLL_r, "D▲", style = label.style_label_up,   color = colDivRegBull, textcolor = color.white, size = divSz,
         tooltip = "Regular Bullish Divergence\nPrice: Lower Low\nRSI: Higher Low\nSignal: Potential reversal to the upside")
    lastDivBar := bar_index
    lastDivTag := "▲ REG"

if divRegOn and dRegBear and sdfPassBear
    line.new (pHH_bx, pHH_r_now, bar_index[divPivSpan], cHH_r, color = colDivRegBear, width = 1, style = line.style_solid)
    label.new(bar_index[divPivSpan], cHH_r, "D▼", style = label.style_label_down, color = colDivRegBear, textcolor = color.white, size = divSz,
         tooltip = "Regular Bearish Divergence\nPrice: Higher High\nRSI: Lower High\nSignal: Potential reversal to the downside")
    lastDivBar := bar_index
    lastDivTag := "▼ REG"

if divHidOn and dHidBull and sdfPassBull
    line.new (pLL_bx, pLL_r_now, bar_index[divPivSpan], cLL_r, color = colDivHidBull, width = 1, style = line.style_dashed)
    label.new(bar_index[divPivSpan], cLL_r, "H▲", style = label.style_label_up,   color = colDivHidBull, textcolor = color.white, size = divSz,
         tooltip = "Hidden Bullish Divergence\nPrice: Higher Low\nRSI: Lower Low\nSignal: Uptrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▲ HID"

if divHidOn and dHidBear and sdfPassBear
    line.new (pHH_bx, pHH_r_now, bar_index[divPivSpan], cHH_r, color = colDivHidBear, width = 1, style = line.style_dashed)
    label.new(bar_index[divPivSpan], cHH_r, "H▼", style = label.style_label_down, color = colDivHidBear, textcolor = color.white, size = divSz,
         tooltip = "Hidden Bearish Divergence\nPrice: Lower High\nRSI: Higher High\nSignal: Downtrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▼ HID"

// Update previous-pivot anchors — runs AFTER the rendering block above so
// the line.new calls can still resolve the previous pivot's bar coordinate.
// Only price + bar index are stored; the RSI value is re-read dynamically
// from the current liveRsi series via the bar-index lookup at the top of
// this section (see the pHH_r_now / pLL_r_now block).
if not na(cHH_p)
    pHH_px := cHH_p
    pHH_bx := bar_index[divPivSpan]

if not na(cLL_p)
    pLL_px := cLL_p
    pLL_bx := bar_index[divPivSpan]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — PLOTS
// Multi-band zone visual (Stochastic-Extreme style) + adaptive OB / OS
// overlays + active RSI line + zone fills + trigger markers + divergence.
// Plot IDs declared here feed the fill() calls — order matters.
// ═══════════════════════════════════════════════════════════════════════════════

// ── Fixed reference bands — the stable visual scaffolding ────────────────────
// 100 / 80 / 70 — overbought scaffold
// 50            — midline
// 30 / 20 / 0   — oversold scaffold
hObTop = hline(100, "Top",         color.new(thBear,    0), hline.style_solid)
hObMid = hline(80,  "OB Inner",    color.new(thBear,   25), hline.style_dashed)
hObLow = hline(70,  "OB Outer",    color.new(thBear,   25), hline.style_dotted)
hMid   = hline(50,  "Midline",     color.new(thNeutral, 0), hline.style_dotted)
hOsHi  = hline(30,  "OS Outer",    color.new(thBull,   25), hline.style_dotted)
hOsMid = hline(20,  "OS Inner",    color.new(thBull,   25), hline.style_dashed)
hOsBot = hline(0,   "Bottom",      color.new(thBull,    0), hline.style_solid)

// ── Adaptive OB / OS steplines (move as the optimiser updates) ───────────────
// Theme-coloured stepline overlays so traders can see the optimiser's
// current threshold choice at a glance. Steplines emphasise the
// "snap to new level when the winner switches" semantic.
plot(showLevels ? liveOb : na, "Adaptive OB", color.new(thBear, 0),  1, plot.style_stepline)
plot(showLevels ? liveOs : na, "Adaptive OS", color.new(thBull, 0),  1, plot.style_stepline)

// ── Zone fill colour resolvers ───────────────────────────────────────────────
// The visual escalation tracks RSI position relative to the *adaptive*
// OB / OS thresholds — not the fixed 80 / 20 bands. That keeps the colour
// escalation in lockstep with the actual signal logic (the optimiser's
// triggers fire on the adaptive lines).
//
// Three-tier escalation for each side:
//   Solid (rejection)   — trigger just fired this bar
//   Medium (in zone)    — RSI inside the adaptive band (past the threshold)
//   Light (entering)    — RSI inside the visual band but not yet at the
//                         adaptive threshold (early-warning shade)
//   none (transparent)  — RSI outside the visual band entirely

color obFillCol = (obTrip            ? color.new(thBear,  0) :
                   liveRsi > liveOb ? color.new(thBear, 40) :
                   liveRsi > 70       ? color.new(thBear, 80) :
                                          color.new(thBear, 100))

color osFillCol = (osTrip           ? color.new(thBull,  0) :
                   liveRsi < liveOs ? color.new(thBull, 40) :
                   liveRsi < 30       ? color.new(thBull, 80) :
                                          color.new(thBull, 100))

// Fill the OB extreme band (between hObMid=80 and hObTop=100) and the OS
// extreme band (between hOsBot=0 and hOsMid=20). The 70 / 30 outer bands
// stay as visual reference only — no fill — so the user can see how deep
// the RSI sits without the fill cluttering the pane.
fill(hObMid, hObTop, color = showZones ? obFillCol : na, title = "OB Zone Fill")
fill(hOsBot, hOsMid, color = showZones ? osFillCol : na, title = "OS Zone Fill")

// ── Active RSI line — colour-tiered by position ──────────────────────────────
// Above 60 → theme-bull (price-strength bias)
// Between 40 and 60 → neutral
// Below 40 → theme-bear (price-weakness bias)
// Mirrors the Stochastic-Extreme %D-tier convention.
color rsiLineCol = (liveRsi >= 60 ? color.new(thBull,    0) :
                    liveRsi >= 40 ? color.new(thNeutral, 0) :
                                      color.new(thBear,    0))

pRsi      = plot(liveRsi, "Active RSI", rsiLineCol, 2, plot.style_line)
pMidRef   = plot(50, "Mid Ref", color = na, display = display.none, editable = false)

// Gradient fill above / below the midline. Above 50 fades from theme-bull
// at the top to transparent at the midline; below 50 fades from theme-bear
// at the bottom to transparent at the midline.
fill(pRsi, pMidRef, 100, 50, top_color = color.new(thBull, 0),  bottom_color = color.new(thBull, 100), title = "Above Mid Fill")
fill(pRsi, pMidRef, 50,  0,  top_color = color.new(thBear, 100), bottom_color = color.new(thBear, 0),   title = "Below Mid Fill")

// ── Trigger markers — adaptive-threshold OS-entry / OB-exit ──────────────────
// ▲ Buy at y = 10  (mid-point of the OS extreme band, between 0 and 20)
// ▼ Sell at y = 90 (mid-point of the OB extreme band, between 80 and 100)
//
// Artemis Squeeze convention reproduced exactly: location.absolute with
// FIXED Y coordinates so the markers stay glued to the same visual spot on
// every bar — no auto-scale drift. The chosen Y values centre the markers
// inside their respective extreme bands so they read as part of the zone
// fill rather than crowding the pane edges.
//
// Pure-white fill (#ffffff) so the markers read against every theme; tiny
// size matches the rest of the Artemis brand family's marker convention.
// Signal logic still keys off the *adaptive* thresholds (osTrip / obTrip
// from the live fleet champion) — only the rendering position is pinned
// to the band centres.
//
// plotshape() ignores the `tooltip` parameter, so we pair each visible
// triangle with an invisible label.style_circle anchored at the same
// fixed Y for rich hover context.
plotshape(showSignals and osTrip ? 10 : na, title = "OS Entry Trigger",
     style = shape.triangleup,   location = location.absolute,
     color = color.new(#ffffff, 0), display = display.pane, editable = false)
plotshape(showSignals and obTrip  ? 90 : na, title = "OB Exit Trigger",
     style = shape.triangledown, location = location.absolute,
     color = color.new(#ffffff, 0), display = display.pane, editable = false)

if showSignals and osTrip
    string osTip = "OS Entry Trigger ▲\nRSI: " + str.tostring(liveRsi, "#.##") + "\nActive OS: " + str.tostring(liveOs, "#.##") + "\nPeriod: " + str.tostring(liveLen) + "  Smooth: " + str.tostring(liveSmooth) + "\n\nMeaning: RSI just dropped below the adaptive OS threshold — the optimiser's preferred mean-reversion long trigger on this asset / regime."
    label.new(bar_index, 10, "", style = label.style_circle, color = color.new(color.white, 100), size = size.small, tooltip = osTip)

if showSignals and obTrip
    string obTip = "OB Exit Trigger ▼\nRSI: " + str.tostring(liveRsi, "#.##") + "\nActive OB: " + str.tostring(liveOb, "#.##") + "\nPeriod: " + str.tostring(liveLen) + "  Smooth: " + str.tostring(liveSmooth) + "\n\nMeaning: RSI just dropped below the adaptive OB threshold from above — the optimiser's preferred rejection / short trigger on this asset / regime."
    label.new(bar_index, 90, "", style = label.style_circle, color = color.new(color.white, 100), size = size.small, tooltip = obTip)

// Divergence rendering (lines + labels) happens directly in Section 8 via
// line.new() / label.new() — no plot-based offset trickery here.

// ── Data-window exports (debug / strategy hook-up) ───────────────────────────
plot(zoneTag,        "zone_state",       display = display.data_window)
plot(liveLen,          "active_period",    display = display.data_window)
plot(liveSmooth,          "active_smooth",    display = display.data_window)
plot(liveOs,         "active_os",        display = display.data_window)
plot(liveOb,         "active_ob",        display = display.data_window)
plot(champScore,      "active_score",     display = display.data_window)
plot(lockedPhase,  "regime_code",      display = display.data_window)
plot(lockedHold,         "regime_bars_held", display = display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — BAR COLORING
// Optional chart-wide bar colouring driven by the live RSI zone state.
// One mode — RSI Zone — paints bars theme-bear inside the OB zone, theme-
// bull inside the OS zone, theme-neutral elsewhere. "None" emits na so
// barcolor() is a no-op.
// ═══════════════════════════════════════════════════════════════════════════════

color barCol = switch barMode
    "RSI Zone" => zoneTag ==  1 ? thBear : zoneTag == -1 ? thBull : thNeutral
    "None"     => na
    =>            na

barcolor(barCol)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — PHASE BADGE
// Floating callout pinned at the LATEST bar, extending RIGHTWARD into the
// chart's right-margin / future area. The `label.style_label_left` style
// places the arrow tip on the LEFT of the box so it visually "points back"
// to the active RSI data without overlapping the oscillator line. Rebuilt
// every last bar so input changes take effect live.
//
// Vertical position is user-selectable; the Y resolver below maps the
// three string options onto fixed pane-fraction Y coordinates:
//   Top    → y = 80 (upper third — clear of the OB extreme fill)
//   Middle → y = 50 (centred on the midline, default)
//   Bottom → y = 20 (lower third — clear of the OS extreme fill)
// ═══════════════════════════════════════════════════════════════════════════════

float phaseY = (phasePos == "Top"    ? 80.0 :
                phasePos == "Bottom" ? 20.0 :
                                       50.0)

if showPhase and barstate.islast
    var label phaseLabel = na
    label.delete(phaseLabel)
    string holdStr  = str.tostring(lockedHold) + " bars stable"
    string badgeTxt = phaseTag + "  ·  " + holdStr + "\n" + phaseNote
    string phaseTip =
         "MARKET PHASE BADGE\n"                                                +
         "─────────────────────────────\n"                                     +
         "Live read of what regime the optimiser thinks the market is in, "    +
         "based on the winning RSI candidate's score and shape.\n\n"           +
         "PHASE LEGEND\n"                                                      +
         "◐ Adapting — Optimiser warming up; default RSI in use. "             +
         "Wait for the engine to settle.\n\n"                                  +
         "✸ Noisy — No clean edge across the candidate grid. "                 +
         "Best to stand aside, signals are unreliable.\n\n"                    +
         "➜ Trending — Strong directional flow detected. "                     +
         "Avoid OB / OS reversal trades, ride the trend.\n\n"                  +
         "▣ Range — RSI's sweet spot; mean-reversion edge intact. "            +
         "OB / OS triggers work best here.\n\n"                                +
         "⊠ Calm — Low-volatility drift, mild signals. "                       +
         "Use only as confluence with other tools.\n\n"                        +
         "N BARS STABLE\n"                                                     +
         "How many bars the current phase has been locked in. Higher = more "  +
         "confidence the regime is real and not a one-bar fluke.\n\n"          +
         "TIP — the badge colour, dashboard Phase row, and bar coloring all "  +
         "key off this same classification."
    phaseLabel := label.new(x = bar_index, y = phaseY, text = badgeTxt,
         xloc = xloc.bar_index, yloc = yloc.price,
         style     = label.style_label_left,
         color     = color.new(phaseTone, 70),
         textcolor = color.white,
         size      = resolveSize(phaseSize),
         tooltip   = phaseTip)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — DASHBOARD
// Compact PRO data table drawn on the last bar. Theme-adaptive chrome —
// auto-flips to light canvas on Midnight / Graphite themes where the dark
// thBull hues would vanish against a black background.
// ═══════════════════════════════════════════════════════════════════════════════

var table arsiDash = na

if showDash and barstate.islast
    // Light-canvas guard — Midnight and Graphite themes ship with dim
    // thBull hues that vanish against a black panel, so for those two
    // palettes the dashboard flips to a light layout. Every other theme
    // keeps the dark chrome.
    bool  dIsLight = themeChoice == "Midnight" or themeChoice == "Graphite"

    color dBgH = dIsLight ? color.new(#F0F0F0, 0)  : color.new(thBull, 90)   // header row — faint theme tint
    color dBgM = dIsLight ? color.new(#FAFAFA, 0)  : color.new(#0f0f0f, 5)   // middle rows — solid dark
    color dBgF = dIsLight ? color.new(#E8E8E8, 0)  : color.new(thBull, 90)   // footer row — faint theme tint
    color dBrd = dIsLight ? color.new(thBull, 40)  : color.new(thBull, 20)   // theme-tinted border

    // Strict colour uniformity — every text cell shares one full-saturation
    // theme tone (thBull). Direction is conveyed via ▲ ▼ ■ glyphs.
    color dTx = color.new(thBull, 0)

    // Bias glyph — derived from the live zone state.
    string dBiasLabel = (zoneTag ==  1 ? "▼ OVERBOUGHT" :
                         zoneTag == -1 ? "▲ OVERSOLD" :
                                           "■ NEUTRAL")

    // Phase glyph — same five-glyph convention as the floating badge so the
    // dashboard row reads identically to the on-pane callout.
    string dRegLabel = (lockedPhase == PH_WARMUP ? "◐ Adapting" :
                        lockedPhase == PH_FOG    ? "✸ Noisy"    :
                        lockedPhase == PH_RUSH   ? "➜ Trending" :
                        lockedPhase == PH_BOUNCE ? "▣ Range"    :
                                                   "⊠ Calm")

    // Score label — score scaled to per-trigger %, n/a until cold-start clears.
    string dScoreLabel = na(champScore) ? "—" : str.tostring(champScore * 100.0, "#.##") + "%"

    // Last-divergence label — show "—" if no divergence detected in the last 50 bars.
    string dDivLabel = (na(lastDivBar) or (bar_index - lastDivBar) > 50) ? "—" : lastDivTag

    // Position resolver — Pine v6 multi-line ternaries inside a local block
    // must be wrapped in parentheses, otherwise the parser treats the
    // newline as a statement terminator and throws CE10156.
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
    if not na(arsiDash)
        table.delete(arsiDash)

    arsiDash := table.new(dTPos, 2, 8,
         bgcolor      = dBgM,
         border_color = dBrd,
         border_width = 1,
         frame_color  = dBrd,
         frame_width  = 1)

    // Row 0 — Header: brand + live bias glyph.
    table.cell(arsiDash, 0, 0, "Artemis A-RSI",
         text_color = dTx, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 0, dBiasLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 1 — Regime tag.
    table.cell(arsiDash, 0, 1, "Regime",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 1, dRegLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2 — Active period.
    table.cell(arsiDash, 0, 2, "Period",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 2, str.tostring(liveLen),
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3 — Active smoothing.
    table.cell(arsiDash, 0, 3, "Smooth",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 3, str.tostring(liveSmooth),
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4 — Adaptive OS threshold.
    table.cell(arsiDash, 0, 4, "OS Level",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 4, str.tostring(liveOs, "#.#"),
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 5 — Adaptive OB threshold.
    table.cell(arsiDash, 0, 5, "OB Level",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 5, str.tostring(liveOb, "#.#"),
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 6 — Mean forward-return score (× 100 → %, 4 decimals trimmed to 2).
    table.cell(arsiDash, 0, 6, "Score",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 6, dScoreLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 7 — Footer: most recent divergence within ~50 bars.
    table.cell(arsiDash, 0, 7, "Last Div",
         text_color = dTx, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(arsiDash, 1, 7, dDivLabel,
         text_color = dTx, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_right, text_font_family = font.family_monospace)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 13 — ALERTS
// Seven alert conditions covering every core event. Each fires through
// alert() rather than alertcondition() so the message body can carry extra
// context — current values, the active adaptive thresholds, and the trigger
// condition.
// ═══════════════════════════════════════════════════════════════════════════════

if alrtOsEntry and osTrip
    alert("Artemis A-RSI — OS Entry Trigger: RSI dropped below adaptive OS " + str.tostring(liveOs, "#.#") + " (RSI: " + str.tostring(liveRsi, "#.##") + ", period: " + str.tostring(liveLen) + ", smooth: " + str.tostring(liveSmooth) + "). Mean-reversion long trigger.", alert.freq_once_per_bar_close)

if alrtObExit and obTrip
    alert("Artemis A-RSI — OB Exit Trigger: RSI dropped below adaptive OB " + str.tostring(liveOb, "#.#") + " from above (RSI: " + str.tostring(liveRsi, "#.##") + ", period: " + str.tostring(liveLen) + ", smooth: " + str.tostring(liveSmooth) + "). Mean-reversion short trigger.", alert.freq_once_per_bar_close)

if alrtRegime and phaseFlipped
    alert("Artemis A-RSI — Regime Change: " + phaseTag + " — " + phaseNote, alert.freq_once_per_bar_close)

if alrtDivReg and dRegBull and sdfPassBull
    alert("Artemis A-RSI — Regular Bullish Divergence (D▲): price made a Lower Low while RSI printed a Higher Low — potential reversal up.", alert.freq_once_per_bar_close)

if alrtDivReg and dRegBear and sdfPassBear
    alert("Artemis A-RSI — Regular Bearish Divergence (D▼): price made a Higher High while RSI printed a Lower High — potential reversal down.", alert.freq_once_per_bar_close)

if alrtDivHid and dHidBull and sdfPassBull
    alert("Artemis A-RSI — Hidden Bullish Divergence (H▲): price made a Higher Low while RSI printed a Lower Low — uptrend continuation.", alert.freq_once_per_bar_close)

if alrtDivHid and dHidBear and sdfPassBear
    alert("Artemis A-RSI — Hidden Bearish Divergence (H▼): price made a Lower High while RSI printed a Higher High — downtrend continuation.", alert.freq_once_per_bar_close)

if alrtMidUp and midUpCross
    alert("Artemis A-RSI — Mid Cross Up: RSI crossed above 50 (RSI: " + str.tostring(liveRsi, "#.##") + "). Bullish bias flip.", alert.freq_once_per_bar_close)

if alrtMidDn and midDnCross
    alert("Artemis A-RSI — Mid Cross Down: RSI crossed below 50 (RSI: " + str.tostring(liveRsi, "#.##") + "). Bearish bias flip.", alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````

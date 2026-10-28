# Artemis Squeeze Momentum

- url: https://www.tradingview.com/script/f1frgIl2-Artemis-Squeeze-Momentum/
- type: indicator
- pine_id: PUB;77217d057dcf44b5ba82381475bb45df
- version: 5.0

## Description

[b]🟦 Artemis Squeeze Momentum[/b] collapses an entire momentum-and-volatility workflow into a single oscillator pane. Eight analytical layers — Squeeze Momentum core, Directional Flux, three-tier compression detection with a release tracker, dual confluence gauges, dual anchor Regular + Hidden divergence with a Smart AI Filter, a composite Trend Strength Score (0–100), a four-timeframe MTF Confluence panel with alignment / divergence detection, and a theme-adaptive PRO dashboard — operate as one integrated system, all driven by a single theme dropdown across 12 cohesive palettes.

Most squeeze indicators ship as a strip of black-and-red dots with a lone momentum histogram, then require a separate ADX, a separate divergence tool and a separate confluence gauge to complete the read. Artemis Squeeze Momentum closes that gap: every compression tier, every directional cross, every divergence, every higher-timeframe bias reads from the same pane in the same colour language — no inline colour pickers, no palette drift, no pane-hopping. The result is a complete momentum workbench where compressions, breakouts, regime flips, divergences and multi-TF bias are all readable at a glance.


[b]🟦 HOW THE CORE ENGINE WORKS[/b]

[b]**Squeeze Momentum Engine**[/b]

Each bar, the engine builds three anchors over the Momentum Length window:

1. **Channel midpoint** — `(highest(high, len) + lowest(low, len)) / 2`
2. **Smoothed midline** — `SMA(HL2, len)`
3. **Channel ATR** — channel range plus the gap-to-prior-close component (matches Pine v5 `tr(true)` on the synthetic channel bar)

The raw momentum is then computed as:

mom_raw = (close − avg(channelMid, smaMid)) / channelATR × 100

This produces a channel-aware, ATR-normalized residual scaled to roughly the ±100 range. The result is then passed through `ta.linreg(mom_raw, len, 0)` to produce the visible momentum line — a linear-regression smoothing that gives the curve its characteristic forward-leaning shape. An SMA of length Signal Length builds the trigger line. Crossovers between momentum and signal mark momentum regime changes — the same convention used by classical MACD.

[b]**Directional Flux**[/b]

A custom ADX-style oscillator running in parallel. Each bar, the engine measures positive high-changes vs. negative low-changes, each RMA-smoothed and ATR-normalized:

up = RMA(max(change(high), 0), len) / ATR(len)
dn = RMA(max(−change(low),  0), len) / ATR(len)
ratio = (up − dn) / (up + dn)
flux  = RMA(ratio, len / 2) × 100

The result is a directional bias oscillator bounded to ±100. An overflow branch (values past ±25 — where the directional pressure becomes structurally significant) renders as a separate, brighter fill so traders read both raw direction and acceleration in one glance.

**Heiken Ashi Bias (Optional)**

When `Use Heiken Ashi Bias` is enabled, the Flux engine reads from a Heiken Ashi bar stream instead of raw OHLC. HA bars smooth body / wick noise and emphasise trend continuation — useful on lower timeframes where raw OHLC is noisy.


[b]🟦 SQUEEZE DETECTION[/b]

A three-tier Bollinger-vs-ATR compression detector running on the same Length as the Momentum Core (so compression and momentum stay perfectly aligned):

| Tier | Condition | Visual |
|---|---|---|
| Tight | stdev < ATR × 0.5 | Deepest, most saturated theme tone |
| Mid | stdev < ATR × 0.75 | Middle-intensity theme tone |
| Loose | stdev < ATR × 1.0 | Lightest tier — broadest detection |

Tiers nest — tight implies mid implies loose. The bottom-of-pane squeeze column lights up whenever any tier is active and the colour escalates as compression tightens, using a theme-native ramp drawn from each palette's own colour family (so the column reads as part of the theme rather than an imported generic warning).

The standard deviation is computed via a single-pass Welford algorithm — numerically stable on long histories where naive sum-of-squares accumulators drift.

[b]**♦ Squeeze Release Marker**[/b]

The signature feature of the engine. The bar after the loosest active tier (stdev < ATR × 1.0) finally drops off, a tiny ♦ diamond paints at the midline in the theme's vivid release accent — one step brighter and more saturated than the tight tier so the climax moment reads as the most luminous point in the squeeze cycle.

This is the canonical "spring uncoiled" moment: compression has fully ended, volatility expansion begins, breakout direction is about to reveal itself. Historically the highest-conviction breakout setup the squeeze model produces. Hovering on the marker surfaces:

- Current bar state (compression ended this bar)
- Meaning (volatility expansion incoming)
- Next steps (watch the next 1–5 bars, confirm with Momentum slope, cross-check Flux, prioritise MTF-aligned setups)


[b]🟦 CONFLUENCE GAUGES[/b]

Two horizontal strips render at the top (Bull side, +70 to +75) and bottom (Bear side, −70 to −75) of the pane. Each strip lights up when momentum and flux agree on direction, with brightness reflecting the confluence tier:

| State | Condition | Opacity |
|---|---|---|
| Strong Bull | mom > 0 AND flux > 0 | Full |
| Weak Bull | mom > 0 OR flux > 0 | Half |
| Strong Bear | mom < 0 AND flux < 0 | Full |
| Weak Bear | mom < 0 OR flux < 0 | Half |
| Neutral | Neither side dominates | Transparent |

The display mode (Both / Bull / Bear / None) lets traders mute one half if they only trade one direction.

[b]**Confluence Buy / Sell Triangles**[/b]

A separate signal layer rides outside the gauges. The detector fires only when momentum crosses its signal line WHILE in the opposite zone past the Signal Threshold AND with flux in the opposite direction (classic mean-reversion logic):

- **Buy ▲** (below bear gauge at −90) — `xMomUp AND momVal < −threshold AND fluxVal < 0`
- **Sell ▼** (above bull gauge at +85) — `xMomDn AND momVal > +threshold AND fluxVal > 0`

Each triangle pairs with an invisible label carrying a tooltip that lists current mom, signal, flux, the active threshold, and a one-line interpretation of the trigger. The Signal Threshold (default 40) is independent of the Divergence Sensitivity setting — the two engines need different thresholds (divergence wants permissive at 25 for pivot detection, confluence wants strict at 40 for deep mean-reversion triggers).


[b]🟦 DIVERGENCE DETECTION[/b]

A cross-confirmed, dual-anchor detector that fires on signal-line crossovers (NOT on Pine pivots). Regular divergences signal exhaustion reversals, Hidden divergences signal trend continuation.

[b]**Four divergence types:**[/b]

| Type | Price | Momentum | Signal |
|---|---|---|---|
| Regular Bull (D▲) | Lower Low | Higher Low | Potential reversal up |
| Regular Bear (D▼) | Higher High | Lower High | Potential reversal down |
| Hidden Bull (H▲) | Higher Low | Lower Low | Uptrend continuation |
| Hidden Bear (H▼) | Lower High | Higher High | Downtrend continuation |

Regular divergence uses solid lines; Hidden uses dashed lines — visually quieter to match the continuation signal's lower conviction tier. Labels (D▲ / D▼ / H▲ / H▼) each carry a tooltip-rich hover with price + momentum + meaning context.

[b]**Dual-Anchor Logic**[/b]

The key engineering choice. Regular and Hidden divergences each maintain their own separate anchor pair:

- **Regular anchors** — stored only at extreme-zone crosses (|mom| > Sensitivity). Catches classical exhaustion reversals at deep extremes.
- **Hidden anchors** — stored at ANY signal-line cross, regardless of zone. Shallow pullbacks inside an established trend rarely push momentum past ±Sensitivity, so the Hidden detector must accept every cross to capture the classical "price HL + mom LL" / "price LH + mom HH" continuation pattern.

A detected divergence consumes its anchor (resets to na) so the next setup starts fresh.

[b]**Smart Divergence Filter (AI)**[/b]

Optional pre-filter that rejects low-quality divergences before they render. Three independent gates:

1. **Min Momentum Swing** — minimum |momentum| difference between the two pivot momentum values (default: 10 units). Drops noise-level differences.
2. **Min Price Swing (%)** — minimum price swing between pivots as a percentage of the recent `Momentum Length × 4` high-low range (default: 0.3%). Drops divergences where price barely moved relative to recent volatility.
3. **Require Flux Confirmation** — Flux must agree with the divergence direction at the moment of detection (Bull div needs Flux > 0, Bear div needs Flux < 0). Filters out divergences that fire counter to the broader directional bias.

When the master toggle is OFF (default), all detected divergences render. When ON, only divergences that clear all three gates survive. The filter applies identically to chart rendering and alert conditions — no mismatch between visual and alert signals.


[b]🟦 COMPOSITE TS SCORE (0–100)[/b]

A weighted blend of every analytical layer into a single RSI-style 0–100 reading. 50 is neutral, > 50 leans bull, < 50 leans bear.

| Component | Weight | Mapping |
|---|---|---|
| Momentum | 30% | mom value mapped from −100..+100 → 0..100 |
| Flux | 30% | flux value mapped the same way |
| Mom × Signal | 15% | 70 if mom > sig, else 30 (slope direction confirmation) |
| Confluence | 25% | 90 strong-bull / 65 weak-bull / 50 neutral / 35 weak-bear / 10 strong-bear |

The score is rounded to the nearest integer and labelled into five tiers in the dashboard: STRONG BULL (≥75) / BULL (≥60) / NEUTRAL (40–59) / BEAR (≥25) / STRONG BEAR (<25), each prefixed with a directional glyph (▲ ▼ ■). The tier label gives traders an executive summary at a glance — one row in the dashboard tells you what every other row collectively says.


[b]🟦 MULTI-TIMEFRAME CONFLUENCE[/b]

A separate PRO panel that runs the full Momentum + Flux + Confluence stack on four higher timeframes simultaneously via `request.security()` and surfaces the overall alignment state. All MTF calls use `lookahead = barmerge.lookahead_off` — fully repaint-safe on every closed bar.

[b]**Six Presets**[/b]

Pre-tuned four-timeframe packs matched to common trader profiles:

| Preset | TF 1 | TF 2 | TF 3 | TF 4 | Use case |
|---|---|---|---|---|---|
| Scalp | 1m | 5m | 15m | 1h | Fast scalper |
| Intraday | 5m | 15m | 1h | 4h | Day trader |
| Swing | 15m | 1h | 4h | 1D | Default — swing trader |
| Position | 1h | 4h | 1D | 1W | Position trader |
| Crypto | 5m | 15m | 1h | 4h | 24/7 markets |
| Forex | 15m | 1h | 4h | 1D | Session-based markets |

[b]**Alignment Detection**[/b]

Each TF returns a bias tag (▲ STRONG / ▲ WEAK / ▼ STRONG / ▼ WEAK / ◈ NEUTRAL) and a direction code (+1 / 0 / −1). The header rolls up the four codes into one of three states:

- **▲▲▲▲ ALIGNED** — all four TFs bullish (highest-conviction long setup)
- **▼▼▼▼ ALIGNED** — all four TFs bearish (highest-conviction short setup)
- **◈ MIXED** — TFs disagree (no clean direction)

[b]**Divergence Detection**[/b]

When the current chart's bias contradicts ≥ 3 of the 4 HTF biases (e.g., chart bullish but 3+ HTFs bearish), an MTF Divergence flag fires — a contrarian / counter-trend warning. Treat as a "current move may be a bull / bear trap" signal.

[b]**Panel Style**[/b]

Direction is conveyed purely by the ▲ / ▼ glyphs in each row's tag — never by cell colour. Every cell uses a uniform `thBull` text colour matching the main Dashboard, so the two panels feel like one product across all twelve themes, light and dark alike.


[b]🟦 BAR COLORING[/b]

Five mutually exclusive modes apply an oscillator-driven colour to every price bar on the chart:

| Mode | Behavior |
|---|---|
| None | Leave bars untouched (default) |
| Momentum | Bull when mom > 0, bear when mom < 0 |
| Flux | Bull when flux > 0, bear when flux < 0 |
| Squeeze | Theme-native ramp when compressed, neutral otherwise |
| Confluence | Strong / Weak / Neutral tiers via mom + flux agreement |
| Slope | Bull when mom > signal, bear when mom < signal |

Colours are pulled from the active theme — no per-mode color picker needed.


[b]🟦 DASHBOARD[/b]

A compact 2-column, 8-row data panel renders on the last bar when enabled. Every value derives from variables already computed upstream, so the dashboard adds zero overhead until the final bar.

| Row | Left | Right |
|---|---|---|
| Header | Artemis Squeeze | ▲ STRONG BULL / ▲ WEAK BULL / ■ NEUTRAL / ▼ WEAK BEAR / ▼ STRONG BEAR |
| TS Score | TS Score | 0–100 composite + tier label (STRONG BULL / BULL / NEUTRAL / BEAR / STRONG BEAR) |
| Momentum | Momentum | Current value + trend arrow (▲ ▼ ■) |
| Flux | Flux | Current value + trend arrow (▲ ▼ ■) |
| Squeeze | Squeeze | TIGHT / MID / LOOSE / — |
| Confluence | Confluence | STRONG BULL / WEAK BULL / NONE / WEAK BEAR / STRONG BEAR |
| Div | Div | Most recent divergence within last 50 bars (▲ REG / ▼ REG / ▲ HID / ▼ HID / —) |
| Slope | Slope | ▲ UP / ▼ DOWN / ■ FLAT |

[b]**Theme-Adaptive Chrome**[/b]

The dashboard auto-inverts its layout based on the active theme:

- **Dark themes** (Tropic, Amber, Pastel, Cyber, Helios, Electric, Candy, Bloomberg, Solar, Royal): header and footer use a faint `thBull` tint, middle rows stay solid dark, text uses full-saturation `thBull`. Border uses `thBull` at 20% transparency for strong theme presence.
- **Light themes** (Midnight, Graphite): backgrounds flip to white, text stays `thBull` (which is itself dark on these themes), border uses `thBull` at 40% transparency.

This guarantees text legibility against every palette without per-theme manual tuning. The MTF Confluence panel uses identical chrome rules so the two panels feel like one product.

[b]**Position & Size**[/b]

Six anchor slots (Top / Middle / Bottom × Left / Right) and four text sizes (Tiny / Small / Normal / Large). The Dashboard defaults to Bottom Right and the MTF panel to Top Right — vertically opposite so the two never overlap.


[b]🟦 COLOR THEMES[/b]

Twelve cohesive palettes, each resolving to four axis colours plus a four-step squeeze ramp:

| Theme | Character | Bull | Bear |
|---|---|---|---|
| Tropic | Cyan steel + deep orange | #00bcd4 | #ff6d00 |
| Amber | Warm amber + ember red | #ff9800 | #e53935 |
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

Beyond the four axis colours (bull / bear / neutral / signal), each theme also defines its own four-step squeeze ramp (tight / mid / loose / release) drawn from its own colour family — so the squeeze column and the ♦ release marker harmonise with the active theme rather than imposing a generic warning hue. Nothing below the theme resolver block references a raw hex literal, so a single dropdown selection drives every plot, fill, gauge, divergence line, dashboard cell, MTF panel and bar colour.


[b]🟦 ALERT SYSTEM[/b]

Twenty-two alert conditions, all using `alert.freq_once_per_bar_close`. Each alert is gated by its own toggle in the Alerts group — hiding a feature on the chart silences its alerts automatically.

| Alert | Condition |
|---|---|
| Confluence Buy | Mom crossed UP through signal while below −Threshold AND Flux bearish |
| Confluence Sell | Mom crossed DOWN through signal while above +Threshold AND Flux bullish |
| Momentum Cross Up | Mom crossed above zero |
| Momentum Cross Down | Mom crossed below zero |
| Flux Cross Up | Flux crossed above zero |
| Flux Cross Down | Flux crossed below zero |
| Bullish Swing | Mom × signal upward cross (any zone) |
| Bearish Swing | Mom × signal downward cross (any zone) |
| Strong Bull Confluence | Mom AND flux both turned bullish |
| Strong Bear Confluence | Mom AND flux both turned bearish |
| Weak Bull Confluence | Mom OR flux turned bullish |
| Weak Bear Confluence | Mom OR flux turned bearish |
| Tight Squeeze | stdev < ATR × 0.5 |
| Mid Squeeze | stdev < ATR × 0.75 |
| Loose Squeeze | stdev < ATR × 1.0 |
| Regular Divergence | D▲ or D▼ detected (respects Smart Filter) |
| Hidden Divergence | H▲ or H▼ detected (respects Smart Filter) |
| Squeeze Release ♦ | stdev re-expanded above ATR × 1.0 |
| MTF Aligned | All four MTF timeframes agree on direction |
| MTF Divergence | Current chart bias contradicts ≥ 3 of 4 HTF biases |

Each alert fires through `alert()` so the message body carries live context — direction, current values, the trigger condition, and a one-line interpretation. Divergence alerts respect the Smart Filter — if the filter is ON and a divergence is rejected visually, the alert will also not fire.


[b]🟦 SETTINGS REFERENCE[/b]

[b]**Visual**[/b]
- Theme — 12 cohesive palettes. Default: Tropic

[b]**Bar Coloring**[/b]
- Bar Color Mode — None / Momentum / Flux / Squeeze / Confluence / Slope. Default: None

[b]**Momentum Core**[/b]
- Length — Lookback for both the Momentum engine and the Squeeze window. Range 7–50. Default: 20
- Signal Length — SMA smoothing for the signal line. Range 2–7. Default: 3
- Show Momentum — Toggle. Default: ON

[b]**Directional Flux**[/b]
- Length — Lookback for the Flux engine. Range 7–50. Default: 30
- Use Heiken Ashi Bias — Toggle. Default: OFF
- Show Flux — Toggle. Default: ON

[b]**Squeeze Engine**[/b]
- Show Squeeze — Toggle. Default: ON
- Show Squeeze Release — Toggle for the ♦ marker. Default: ON

[b]**Confluence Gauges**[/b]
- Display Mode — Both / Bull / Bear / None. Default: Both
- Signal Threshold — |momentum| floor for Buy ▲ / Sell ▼ arrows. Range 10–80. Default: 40

[b]**Divergence**[/b]
- Sensitivity — |momentum| floor for Regular div detection. Range 10–50. Default: 25
- Regular Divergence — Toggle. Default: ON
- Hidden Divergence — Toggle. Default: ON
- Show Divergence Lines — Toggle. Default: ON
- Show Divergence Labels — Toggle. Default: ON
- Label Size — Tiny / Small / Normal / Large. Default: Tiny
- Smart Divergence Filter (AI) — Master toggle. Default: OFF
- Min Momentum Swing — Default: 10.0
- Min Price Swing (%) — Default: 0.3%
- Require Flux Confirmation — Default: ON

[b]**Multi-Timeframe**[/b]
- Show MTF Panel — Toggle. Default: ON
- Timeframe Preset — Scalp / Intraday / Swing / Position / Crypto / Forex. Default: Swing
- Panel Position — 6 anchor slots. Default: Top Right
- Panel Text Size — Tiny / Small / Normal / Large. Default: Small

[b]**Dashboard**[/b]
- Show Dashboard — Toggle. Default: ON
- Panel Position — 6 anchor slots. Default: Bottom Right
- Panel Text Size — Tiny / Small / Normal / Large. Default: Small

[b]**Alerts**[/b]
- 20 toggles covering all 22 alert conditions (Regular and Hidden divergence each drive two alerts — bull + bear — from one toggle).
- Defaults ON: Confluence Buy/Sell, Mom Cross Up/Dn, Flux Cross Up/Dn, Strong Bull/Bear Confluence, Tight Squeeze, Regular Divergence, Squeeze Release, MTF Aligned.
- Defaults OFF: Swings, Weak Confluences, Mid/Loose Squeeze, Hidden Divergence, MTF Divergence.


[b]🟦 COMPATIBILITY[/b]

Works on all asset classes and all timeframes in TradingView Pine Script v6.

- Crypto: Spot, futures, perpetual contracts
- Forex: All pairs
- Equities: Stocks, ETFs, indices
- Commodities: Metals, energy, agriculture
- Timeframes: 1m through Monthly

The channel-aware ATR normalization in the Momentum engine, the ATR-normalized Flux ratio, and the stdev / ATR squeeze tests make every layer volatility-agnostic. The same default settings work on a 1m BTC chart and a weekly index chart without retuning. The MTF presets cover the common scalp / intraday / swing / position profiles plus dedicated Crypto and Forex packs.


[b]🟦 DISCLAIMER[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice. Past performance does not guarantee future results. Always conduct your own analysis and apply proper risk management.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// Artemis Squeeze Momentum
// Author  : © a_jabbaroff
// Version : 1.4.0
// License : Mozilla Public License 2.0 — https://mozilla.org/MPL/2.0/
//
// ❤️ Crafted with love for TradingView traders — every line here exists so
//     your next chart reads cleaner and your next trade lands sharper.
// ═══════════════════════════════════════════════════════════════════════════════
//
// DESCRIPTION
//   Artemis Squeeze Momentum fuses nine distinct analytical layers into a
//   single oscillator pane: a linreg-based Squeeze Momentum line, a
//   Directional Flux oscillator, three-tier Bollinger-vs-ATR squeeze
//   detection with a ✦ Release tracker + Direction Predictor (✦▴ / ✦▾ / ✦),
//   dual confluence gauges with optional Volume Confirmation gate, dual-
//   anchor Regular + Hidden divergence with a Smart AI Filter, a composite
//   Trend Strength Score (0–100), an ADX-based Trend Regime detector with
//   regime-shift alerts, a four-timeframe MTF Confluence panel with
//   alignment / divergence detection, and a theme-adaptive PRO dashboard.
//   The result is a complete momentum workbench — compressions, breakouts,
//   regime flips, divergences and multi-TF bias all readable from one pane,
//   all driven by one theme dropdown.
//
// COMPONENTS
//   Momentum Core    — Squeeze Momentum engine: linreg of close vs.
//                      channel midpoint + SMA(HL2), normalised by the
//                      channel's gap-inclusive true range
//   Directional Flux — custom ADX-style up/down change ratio (RMA-smoothed),
//                      with optional Heiken Ashi input for trend bias mode
//   Squeeze Engine   — three-tier compression detection (Loose / Mid / Tight)
//                      from a length-normalised stdev vs. ATR ratio (0.5 /
//                      0.75 / 1.0 × at Length 20) plus a ✦ Squeeze Release
//                      marker with Direction Predictor (✦▴ / ✦▾ / ✦ from
//                      momentum slope at release)
//   Confluence Gauges— top + bottom strips that light up Strong (both
//                      mom + flux aligned) or Weak (momentum leads, flux not
//                      yet aligned) per side — momentum is the tie-breaker so
//                      exactly one state is ever active; with optional Volume
//                      Confirmation gate on Buy/Sell ▲▼
//   Divergence Engine— Regular + Hidden bull / bear divergence detection
//                      with a Smart AI Filter (sensitivity, min mom swing,
//                      min price swing %, flux confirmation)
//   TS Score (0–100) — composite trend strength reading blending mom, flux,
//                      slope and confluence into a single RSI-style number
//   Trend Regime     — ADX-based market state detector (TRENDING UP / DOWN /
//                      RANGING / TRANSITION) with regime-shift alert and
//                      optional adaptive Signal Threshold for context-aware
//                      Confluence arrows
//   MTF Confluence   — four-HTF panel (presets: Scalp / Intraday / Swing /
//                      Position / Crypto / Forex) with overall alignment +
//                      counter-trend divergence detection — anti-repaint
//   Bar Painter      — five chart-wide colouring modes driven by mom, flux,
//                      squeeze, confluence or slope state
//   Dashboard        — compact 8/9-row PRO panel: Bias / TS Score / [Regime] /
//                      Momentum / Flux / Squeeze / Confluence / Div / Slope
//                      (Regime row optional) — theme-adaptive chrome; pairs
//                      with a separate MTF panel
//   Theme Palette    — thirteen cohesive palettes drive every plot, fill,
//                      gauge, divergence line and dashboard cell
//
// CORE PHILOSOPHY
//   Most squeeze indicators ship as a chart of black-and-red dots with a
//   single momentum histogram — and a separate ADX, separate divergence
//   tool, separate gauge. Artemis Squeeze Momentum collapses the full
//   confluence workflow into one pane: mom + flux + squeeze in lock-step,
//   confluence gauges that show the actual agreement state, divergence
//   that respects the same zone logic as the momentum oscillator, and
//   one theme dropdown that paints the entire stack consistently. No
//   inline colour pickers, no palette drift, no pane-hopping.
//
// CREDITS
//   The Squeeze Momentum concept was first introduced to the TradingView
//   community by LazyBear in 2014 ("Squeeze Momentum Indicator [LazyBear]")
//   — itself a Pine adaptation of John Carter's TTM Squeeze methodology.
//   Full credit to LazyBear for the open-source base curve that made every
//   downstream squeeze script possible.
//
//   Catalog-wide acknowledgment also to EliCobra, whose Pine v6 work
//   (Enhanced WaveTrend and beyond) sets the modern community quality bar
//   the entire Artemis catalog aims to meet — typed UDT engines, well-
//   documented internals, palette-coherent visualisation. His work informs
//   the Artemis style across the catalog; the Squeeze Momentum engine
//   below is an independent implementation.
//
//   Original work in Artemis Squeeze Momentum (everything outside the base
//   momentum / squeeze premise): the Pine v6 rewrite with UDT-typed engine,
//   Welford single-pass running stdev, channel true-range normalisation,
//   Directional Flux oscillator, the Squeeze Release ✦ marker with built-in
//   Direction Predictor (✦▴ / ✦▾ / ✦ from slope-at-release), Volume
//   Confirmation gate for Confluence arrows, dual-anchor Regular + Hidden
//   divergence engine, Smart AI Filter, composite Trend Strength Score,
//   ADX-based Trend Regime detector with optional adaptive Signal Threshold,
//   four-timeframe MTF Confluence panel with alignment / divergence
//   detection, theme-adaptive PRO Dashboard, and the thirteen-palette
//   colour system. Code is open-source under MPL-2.0 — fork, study, improve.
//
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Artemis Squeeze Momentum", shorttitle = "Artemis SM", overlay = false, precision = 2, max_lines_count = 500, max_labels_count = 500, explicit_plot_zorder = true)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — USER-DEFINED TYPES
// Four small UDTs keep Section 3's method signatures tidy. Bar bundles the
// four OHLC price streams; MomReading and FluxReading carry the dual-line
// oscillator outputs; SqueezeState packs the three tier booleans.
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

// Momentum reading — two-line oscillator output from computeMom().
//   value  — linreg-smoothed squeeze momentum (the visible line)
//   signal — SMA of value, used for crossover detection
type MomReading
    float value
    float signal

// Flux reading — two-line oscillator output from computeFlux().
//   value     — main directional flux (−100 .. +100, ADX-style)
//   overflow  — clipped overflow beyond ±25 (signals strong directional pressure)
type FluxReading
    float value
    float overflow

// Squeeze state — three nested compression booleans. The × multipliers below
// are the defaults; all three are user-tunable via the Squeeze Engine inputs,
// and each threshold auto-scales by √(len / 20) so a multiplier keeps the same
// selectivity at any Length (see detectSqueeze). The ratios shown are the
// effective thresholds at the default Length 20.
//   tight — stdev < ATR × 0.5  (extreme compression, imminent expansion)
//   mid   — stdev < ATR × 0.75 (moderate compression)
//   loose — stdev < ATR × 1.0  (mild compression, broadest detection)
// Booleans nest — tight implies mid implies loose. The painter picks the
// most-restrictive active tier for the squeeze column colour.
type SqueezeState
    bool tight
    bool mid
    bool loose

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUT DECLARATIONS
// Every user-configurable setting lives here, organised by component group.
// Group constants are declared first so every input below can share them.
// ═══════════════════════════════════════════════════════════════════════════════

string GRP_THEME = "Visual 🔹"
string GRP_MOM   = "Momentum Core 🔹"
string GRP_FLUX  = "Directional Flux 🔹"
string GRP_SQZ   = "Squeeze Engine 🔹"
string GRP_GAUGE = "Confluence Gauges 🔹"
string GRP_DIV    = "Divergence 🔹"
string GRP_REGIME = "Trend Regime 🔹"
string GRP_BAR    = "Bar Coloring 🔹"
string GRP_MTF    = "Multi-Timeframe 🔹"
string GRP_DASH   = "Dashboard 🔹"
string GRP_ALRT   = "Alerts 🔹"

// ── Color Theme ──────────────────────────────────────────────────────────────
// Thirteen cohesive palettes, one control. The theme dropdown is the single
// source of truth for every coloured component — momentum line, flux fill,
// confluence gauges, divergence lines, dashboard chrome — all resolve
// through the palette switch blocks below.

themeChoice = input.string("Tropic", "Theme",
     options = ["Tropic", "Amber", "Pastel", "Cyber", "Helios", "Electric", "Candy", "Bloomberg", "Solar", "Royal", "Emerald", "Midnight", "Graphite"],
     group   = GRP_THEME,
     tooltip = "Applies a complete color palette across all Artemis Squeeze components.\nOne selection governs the Momentum line, Flux fills, Confluence gauges, Divergence lines and Dashboard.\n\nTropic — Cyan steel + deep orange (electric contrast — default)\n\nAmber — Warm amber + ember red (fire tones)\n\nPastel — Sky blue + soft lavender (cool arctic glow)\n\nCyber — Neon lime + hot crimson (cyber terminal)\n\nHelios — Bright gold + scarlet (solar warmth)\n\nElectric — Electric aqua + magenta (high-voltage neon)\n\nCandy — Neon green + hot pink (dark energy pop)\n\nBloomberg — Terminal orange + cyan (Wall Street finance heritage — PRO)\n\nSolar — Solarized olive + crimson (developer palette, easy on the eyes — PRO)\n\nRoyal — Imperial gold + deep purple (luxury signature — PRO)\n\nEmerald — Vibrant emerald + ruby red (jewel-tone finance — PRO)\n\nMidnight — Deep navy + dark crimson (dark depth)\n\nGraphite — Near-black + silver grey (monochrome minimal)")

// Hover-tooltip toggle. The momentum-cross, squeeze-release and confluence
// buy/sell markers each pair their visible glyph with an INVISIBLE label that
// only exists to carry a rich hover tooltip (plotchar / plotshape ignore the
// `tooltip` param). These fire on every crossover and release and share the
// fixed 500-label pool with the divergence markers — so to default this ON
// safely, the hover labels are bounded to a rolling FIFO of the most recent
// HOVER_CAP (see Section 8), permanently reserving the rest of the pool for
// the D▲ / D▼ / H▲ / H▼ divergence labels. They can no longer be crowded out.
showHoverTips = input.bool(true, "Show Hover Tooltips",
     group   = GRP_THEME,
     tooltip = "Adds rich hover tooltips to THREE markers — the Momentum-Cross dots, the Squeeze Release ✦ marker and the Confluence Buy ▲ / Sell ▼ triangles (mom / signal / flux values + meaning). These three have no built-in tooltip (plotchar / plotshape ignore the tooltip param), so an invisible label is paired with each to carry the hover text.\n\nThis toggle does NOT affect the Divergence markers (D▲ D▼ H▲ H▼): those are real labels that carry their OWN tooltip, governed by Show Divergence Labels — their hover text always appears whenever divergence labels are shown, regardless of this setting.\n\nDefault: ON. The hover labels are capped to a small rolling window of the most recent markers (and you only ever hover near recent price action), so they can never crowd the shared 500-label pool or push divergence markers out — even on long, active charts. Turn OFF only if you want a completely tooltip-free pane.")

// ── Theme color resolver ─────────────────────────────────────────────────────
// Each theme resolves to four axis colours plus a four-step squeeze ramp.
// The whole script reads from these resolved variables — nothing below this
// block references a raw hex literal, so a theme change cascades everywhere
// with one dropdown click.
//   thBull        — bullish / positive side  (mom up, flux up, confluence bull)
//   thBear        — bearish / negative side  (mom down, flux down, confluence bear)
//   thNeutral     — desaturated mid tone     (midline, gauge inactive, MID tag)
//   thSignal      — pastel tint of thBull    (signal-line halo, dashboard chrome)
//   sqzColTight   — squeeze tier 3 (deepest tone, theme-native squeeze accent)
//   sqzColMid     — squeeze tier 2 (middle tone of the same family)
//   sqzColLoose   — squeeze tier 1 (lightest / brightest of the family)
//   sqzColRelease — squeeze release accent (vivid pop hue for the ✦ marker)

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
    "Emerald"   => #00bfa5
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
    "Emerald"   => #c62828
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
    "Emerald"   => #546e7a
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
    "Emerald"   => #80CBC4
    "Midnight"  => #90CAF9
    "Graphite"  => #BDBDBD
    =>             #80DEEA

// Theme-native squeeze ramp — each palette defines its own coherent three-step
// gradient drawn from its own colour family, so the squeeze column reads as
// "part of the theme" rather than an imported generic warning. The semantic
// (intensity escalates as compression tightens) is preserved via brightness:
//   tight — deepest, most saturated hue   (imminent expansion, demands focus)
//   mid   — same family, middle intensity (escalating warning)
//   loose — faintest tier, brightest hue  (mild compression, broadest tier)
//
// Each theme picks its squeeze family so it (1) belongs to the theme's overall
// palette, (2) does NOT clash with the bull / bear axis colours, and (3) still
// gives a clear "tight is hotter than loose" visual gradient.

color sqzColTight = switch themeChoice
    "Tropic"    => #ff1100
    "Amber"     => #8b0000
    "Pastel"    => #ab47bc
    "Cyber"     => #f50057
    "Helios"    => #e65100
    "Electric"  => #aa00ff
    "Candy"     => #c51162
    "Bloomberg" => #ff1100
    "Solar"     => #cb4b16
    "Royal"     => #311b92
    "Emerald"   => #ff6f00
    "Midnight"  => #1565c0
    "Graphite"  => #cccccc
    =>             #ff1100

color sqzColMid = switch themeChoice
    "Tropic"    => #ff5e00
    "Amber"     => #d84315
    "Pastel"    => #ce93d8
    "Cyber"     => #ff4081
    "Helios"    => #f57c00
    "Electric"  => #d500f9
    "Candy"     => #e91e63
    "Bloomberg" => #ff5e00
    "Solar"     => #b58900
    "Royal"     => #4527a0
    "Emerald"   => #ffa000
    "Midnight"  => #1e88e5
    "Graphite"  => #888888
    =>             #ff5e00

color sqzColLoose = switch themeChoice
    "Tropic"    => #ffa600
    "Amber"     => #ff6f00
    "Pastel"    => #e1bee7
    "Cyber"     => #ff80ab
    "Helios"    => #ffb300
    "Electric"  => #ea80fc
    "Candy"     => #f06292
    "Bloomberg" => #ffa600
    "Solar"     => #93a1a1
    "Royal"     => #7e57c2
    "Emerald"   => #ffd54f
    "Midnight"  => #64b5f6
    "Graphite"  => #555555
    =>             #ffa600

// Squeeze Release accent — the "vivid pop" hue used for the ✦ release marker.
// One step brighter / more saturated than sqzColTight so the climax moment
// reads as the most luminous point in the squeeze cycle without abandoning
// the theme's colour family. Each entry is hand-picked to be:
//   (1) in-family with the theme's squeeze ramp,
//   (2) maximum saturation — "сочный" / juicy / vivid,
//   (3) high-contrast against the pane's dark background.
color sqzColRelease = switch themeChoice
    "Tropic"    => #ff9500
    "Amber"     => #ff5252
    "Pastel"    => #e040fb
    "Cyber"     => #ff1744
    "Helios"    => #ff9100
    "Electric"  => #d500f9
    "Candy"     => #ff4081
    "Bloomberg" => #ff8400
    "Solar"     => #ff6f00
    "Royal"     => #b388ff
    "Emerald"   => #ffea00
    "Midnight"  => #448aff
    "Graphite"  => #1a1a1a
    =>             #ffea00

// ── Momentum Core ────────────────────────────────────────────────────────────
// Squeeze Momentum engine: linreg of close vs. channel midpoint +
// SMA(HL2), normalised by the channel's gap-inclusive true range. Length
// controls both the momentum lookback and the squeeze detection window
// (so they stay aligned).

simple int momLen = input.int(20, "Length",
     minval = 7, maxval = 50, step = 1,
     group   = GRP_MOM,
     tooltip = "Lookback for the Squeeze Momentum engine and the Squeeze Detection window. Both share this length so compression and momentum stay aligned.\n\n7–14 → scalping / intraday\n20 → balanced — default\n21–30 → swing trading\n30–50 → position / weekly\n\nDefault: 20")

simple int momSigLen = input.int(3, "Signal Length",
     minval = 2, maxval = 7, step = 1,
     group   = GRP_MOM,
     tooltip = "SMA smoothing applied to the momentum line to produce the trigger line. Shorter than the Length so the two cross cleanly.\n\n2 → fast triggers, more crosses\n3 → balanced — default\n5–7 → fewer, more reliable crosses\n\nDefault: 3")

showMom = input.bool(true, "Show Momentum",
     group   = GRP_MOM,
     tooltip = "Toggle for the main momentum oscillator line + signal-line fill ribbon. Turning OFF hides the line but does not disable downstream features (squeeze, divergence, confluence) that depend on momentum state.")

// ── Directional Flux ─────────────────────────────────────────────────────────
// Custom ADX-style oscillator. Measures the ratio of RMA-smoothed positive
// high changes vs. negative low changes, self-normalised by their own sum
// (difference ÷ total → bounded to ±100). The signal branch ("overflow")
// highlights values beyond ±25 where the directional pressure becomes
// structurally significant.

simple int fluxLen = input.int(30, "Length",
     minval = 7, maxval = 50, step = 1,
     group   = GRP_FLUX,
     tooltip = "Lookback for the Directional Flux engine. Larger than the Momentum length by default so flux acts as the slower trend bias against the faster momentum oscillator.\n\n7–14 → reactive, more whipsaws\n30 → balanced — default\n40–50 → very smooth, only macro regimes register\n\nDefault: 30")

fluxHA = input.bool(false, "Use Heiken Ashi Bias",
     group   = GRP_FLUX,
     tooltip = "When ON, the Flux engine reads Heiken Ashi bars instead of raw OHLC. HA bars smooth body / wick noise and emphasise trend continuation. Best on lower timeframes where raw OHLC is noisy.\n\nDefault: OFF")

showFlux = input.bool(true, "Show Flux",
     group   = GRP_FLUX,
     tooltip = "Toggle for the Directional Flux area fills (main + overflow). Flux feeds the Confluence Gauges even when its fills are hidden.")

// ── Squeeze Engine ───────────────────────────────────────────────────────────
// Three-tier Bollinger-vs-ATR compression detection. The Length is shared
// with the Momentum Core so the two engines stay in sync. The visual is a
// 1-bar column at the bottom of the pane, coloured by the tightest active
// tier (theme-native compression ramp — each palette defines its own
// intensity gradient).

showSqz = input.bool(true, "Show Squeeze",
     group   = GRP_SQZ,
     tooltip = "Toggle for the zero-line squeeze column. The column lights up whenever stdev < ATR × the Loose Multiplier (any tier active); the colour escalates as compression tightens:\n\nLightest (Loose) → stdev < ATR × Loose Multiplier (default 1.0)\nMid intensity (Mid) → stdev < ATR × Mid Multiplier (default 0.75)\nDeepest / most saturated (Tight) → stdev < ATR × Tight Multiplier (default 0.5) — imminent expansion\n\nEach threshold auto-scales by √(Length / 20), so a multiplier keeps the same selectivity at any Length (calibrated at the default Length 20 — at 20 nothing changes). Length sets the timescale; the multiplier sets how often the squeeze fires.\n\nEach theme defines its OWN three-step ramp drawn from its palette family, so the squeeze column harmonises with the active theme rather than imposing a generic warning hue. The intensity semantic is preserved across every palette — tight is always the most attention-grabbing tier.")

showSqzRelease = input.bool(true, "Show Squeeze Release",
     group   = GRP_SQZ,
     tooltip = "Renders a ✦ release marker on the bar where the squeeze fully ends — when the loosest active tier (stdev < ATR × the Loose Multiplier, default 1.0 at Length 20; the threshold auto-scales with Length) drops off. This is the canonical \"spring uncoiled\" moment: compression ended, volatility expansion begins. Historically the highest-conviction breakout setup.\n\nMarker colour uses the theme's vivid release accent (sqzColRelease — one step brighter / more saturated than sqzColTight) so the climax moment pops visually while staying inside the theme's colour family. Hover the marker for full context.\n\nDefault: ON.")

sqzPredictOn = input.bool(true, "Show Direction Predictor",
     group   = GRP_SQZ,
     tooltip = "When ON, the ✦ Release marker becomes direction-aware: at the moment of release the engine measures momentum slope across the predictor lookback. If the slope is decisively bullish or bearish, the marker shows ✦▴ or ✦▾ instead of plain ✦.\n\nGives traders immediate breakout-direction guidance the moment compression ends — no waiting for confirmation candles. Slope within the threshold band keeps the marker neutral ✦ (\"direction unclear, wait\").\n\nAssumption: the predictor reads the momentum slope at release as the breakout direction — a CONTINUATION model. It is most reliable when compression breaks in the prevailing direction, and can point the wrong way on reversal-type releases (where price snaps opposite the pre-release slope). Treat ✦▴ / ✦▾ as a lean, not a guarantee, and confirm with Flux + the next 1–5 bars.\n\nDefault: ON.")

sqzPredictLook = input.int(3, "Predictor Lookback",
     minval = 2, maxval = 10, step = 1,
     group   = GRP_SQZ,
     tooltip = "How many bars back to measure momentum slope at the release bar. Shorter = more reactive but noisier; longer = smoother but slower direction reads.\n\n2 → very reactive\n3 → balanced — default\n5–10 → smooth, fewer false direction tags\n\nRequires Show Direction Predictor ON.")

sqzPredictThresh = input.float(5.0, "Predictor Slope Threshold",
     minval = 1.0, maxval = 25.0, step = 0.5,
     group   = GRP_SQZ,
     tooltip = "Minimum |slope| required to label a directional prediction. Below this absolute value the marker stays plain ✦ (neutral — \"direction unclear, wait for confirmation\").\n\n2–4 → permissive, most releases get a direction tag\n5 → balanced — default\n10+ → strict, only high-conviction directional releases earn a tag\n\nRequires Show Direction Predictor ON.")

// Tier multipliers — the stdev / ATR ratio at which each squeeze tier arms.
// Previously hardcoded (0.5 / 0.75 / 1.0); exposed here so the compression
// model can be tuned per market. The three are auto-sorted ascending before
// the detector (see Section 4), so the nesting semantic (tight ⇒ mid ⇒ loose)
// holds even if they are entered out of order — the smallest always drives
// Tight, the largest Loose. Each threshold also auto-scales by √(Length / 20)
// inside detectSqueeze, so a multiplier keeps the SAME selectivity at any
// Length (calibrated at the default 20) rather than drifting with it.
simple float sqzTightMult = input.float(0.5, "Tight Multiplier",
     minval = 0.1, maxval = 2.0, step = 0.05,
     group   = GRP_SQZ,
     tooltip = "Tightest tier: squeeze is TIGHT when stdev < ATR × this. Lower = rarer, more extreme compression.\n\n0.5 → balanced — default\n\nThe three multipliers are auto-sorted ascending, so order can't break — but set this as the smallest for clarity. The threshold auto-scales by √(Length / 20), so this dial keeps the same selectivity at any Length.")

simple float sqzMidMult = input.float(0.75, "Mid Multiplier",
     minval = 0.1, maxval = 2.0, step = 0.05,
     group   = GRP_SQZ,
     tooltip = "Middle tier: squeeze is MID when stdev < ATR × this.\n\n0.75 → balanced — default\n\nThe three multipliers are auto-sorted ascending, so order can't break — but set this between Tight and Loose for clarity. The threshold auto-scales by √(Length / 20), so this dial keeps the same selectivity at any Length.")

simple float sqzLooseMult = input.float(1.0, "Loose Multiplier",
     minval = 0.1, maxval = 2.0, step = 0.05,
     group   = GRP_SQZ,
     tooltip = "Loosest / broadest tier: squeeze is LOOSE (column lights up, release tracked) when stdev < ATR × this.\n\n1.0 → balanced — default\n\nThe three multipliers are auto-sorted ascending, so order can't break — but set this as the largest for clarity. The threshold auto-scales by √(Length / 20), so this dial keeps the same selectivity at any Length.")

// ── Confluence Gauges ────────────────────────────────────────────────────────
// Two horizontal strips rendered at the top (Bull side, +70 to +75) and bottom
// (Bear side, −70 to −75) of the pane. Each strip lights up by confluence tier:
// full opacity when mom + flux agree (Strong), dimmed when momentum leads alone
// (Weak), transparent otherwise.

gaugeMode = input.string("Both", "Display Mode",
     options = ["Both", "Bull", "Bear", "None"],
     group   = GRP_GAUGE,
     tooltip = "Controls which confluence strips render:\n\nBoth → both bull (top) + bear (bottom) gauges — default\nBull → bull strip only\nBear → bear strip only\nNone → disable all gauge strips\n\nConfluence states (momentum is the tie-breaker, so exactly one fires):\n• Strong Bull — mom > 0 AND flux > 0 (both bullish)\n• Weak Bull — mom > 0 while flux is not bullish\n• Strong Bear — mom < 0 AND flux < 0 (both bearish)\n• Weak Bear — mom < 0 while flux is not bearish\n\nThe strip's brightness reflects the confluence tier (full opacity for Strong, dimmed for Weak).")

confThresh = input.int(40, "Signal Threshold",
     minval = 10, maxval = 80, step = 1,
     group   = GRP_GAUGE,
     tooltip = "Minimum |momentum| value required for a Confluence Buy ▲ or Sell ▼ arrow to fire.\n\nThe higher the value, the deeper into the overbought / oversold zone the momentum cross must happen, so fewer but higher-conviction arrows print.\n\nA Confluence arrow needs:\n• Mom × Signal crossover\n• |mom| ≥ this threshold\n• Flux opposite direction (mean-reversion bias)\n• Volume above its MA — only when Require Volume Confirmation is ON (default) and the symbol has volume data\n\n20–30 → permissive, many arrows\n40 → balanced — default\n50–80 → strict, only extreme-zone arrows\n\nNote: this is independent of the Divergence Sensitivity setting in the Divergence group. When Trend Regime → Auto-Adjust Signal Threshold is ON, this value is shifted ±10 based on detected market regime.")

volConfOn = input.bool(true, "Require Volume Confirmation",
     group   = GRP_GAUGE,
     tooltip = "When ON, Confluence Buy ▲ / Sell ▼ arrows fire only when current bar volume exceeds its moving average. Filters out signals firing during low-conviction (low-volume) periods where moves often reverse.\n\nOn symbols without volume data the gate is automatically bypassed — if either current volume or the volume MA is na or zero, the filter is skipped so the indicator remains universal.\n\nDefault: ON.")

volMaLen = input.int(20, "Volume MA Length",
     minval = 5, maxval = 100, step = 1,
     group   = GRP_GAUGE,
     tooltip = "SMA lookback for the volume threshold used by the Volume Confirmation gate.\n\n10–14 → fast (more signals pass)\n20 → balanced — default\n30–50 → slow (only high-conviction volume surges pass)\n\nRequires Require Volume Confirmation ON.")

// ── Divergence ───────────────────────────────────────────────────────────────
// Pivot-aware divergence detection. REGULAR divergences fire only when
// momentum is in an extreme zone (beyond ±Sensitivity) AND crosses the signal
// line. HIDDEN divergences fire on ANY signal-line cross (no zone gate), so
// they can appear during shallow pullbacks within a trend. Cross-confirmed
// style — NOT pivot-confirmed. Regular signal reversal, Hidden continuation.

divSens = input.int(25, "Sensitivity",
     minval = 10, maxval = 50, step = 1,
     group   = GRP_DIV,
     tooltip = "Minimum |momentum| value required for divergence detection to arm. Only momentum crossovers that happen beyond ±Sensitivity become divergence candidates.\n\n10–20 → permissive, many divergences\n25 → balanced — default\n30–50 → strict, only deep-extreme divergences\n\nHigher value = stricter filter, fewer signals, higher conviction.")

divRegOn = input.bool(true, "Regular Divergence",
     group   = GRP_DIV,
     tooltip = "Detects potential trend reversals.\n\nBull (D▲): price Lower Low + momentum Higher Low → reversal up\nBear (D▼): price Higher High + momentum Lower High → reversal down\n\nDetected at the moment of a momentum cross while in an extreme zone (|mom| > Sensitivity). Solid lines connect the divergence pivots.")

divHidOn = input.bool(true, "Hidden Divergence",
     group   = GRP_DIV,
     tooltip = "Detects trend-continuation signals.\n\nBull (H▲): price Higher Low + momentum Lower Low → uptrend continues\nBear (H▼): price Lower High + momentum Higher High → downtrend continues\n\nHidden divergences are tracked through a dedicated any-zone anchor pair (separate from the Sensitivity-gated Regular anchors), so they actually fire during shallow pullbacks within an established trend — exactly the context where the classical Hidden div pattern is supposed to appear. Dashed lines connect the two pivots.")

divShowLines = input.bool(true, "Show Divergence Lines",
     group   = GRP_DIV,
     tooltip = "Toggle for the divergence connection lines (solid for Regular, dashed for Hidden). Turning OFF keeps the labels but removes the connecting lines for a cleaner pane.")

divShowLabels = input.bool(true, "Show Divergence Labels",
     group   = GRP_DIV,
     tooltip = "Toggle for the D▲ D▼ H▲ H▼ markers. Turning OFF keeps the lines but removes the labels — useful on dense charts where labels clutter.")

divLabelSize = input.string("Tiny", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DIV,
     tooltip = "Size of the D▲ D▼ H▲ H▼ divergence markers.\n\nTiny → minimal, default\nSmall → slightly larger\nNormal → standard\nLarge → maximum visibility")

sdfOn = input.bool(false, "Smart Divergence Filter (AI)",
     group   = GRP_DIV,
     tooltip = "AI-assisted filter that suppresses weak or low-quality divergences.\n\nOFF (default) → all detected divergences pass through\nON → only divergences that clear all three gates below survive\n\nThe three gates:\n1. Min Momentum Swing — drops differences below this size between the two pivot momentum values\n2. Min Price Swing (%) — drops divergences where price barely moved relative to recent range\n3. Flux Confirmation — Flux must agree with the divergence direction (Bull div needs Flux > 0, Bear div needs Flux < 0)\n\nTurn ON for fewer, higher-conviction signals only.")

sdfMinMom = input.float(10.0, "Min Momentum Swing",
     minval = 1.0, maxval = 50.0, step = 0.5,
     group   = GRP_DIV,
     tooltip = "Minimum momentum swing between the two divergence pivots.\n\nSmall (1–5) → permissive, allows minor divergences through\nMedium (10) → balanced — default\nLarge (20–50) → only structurally significant divergences pass\n\nRequires Smart Filter ON.")

sdfMinPct = input.float(0.3, "Min Price Swing (%)",
     minval = 0.1, maxval = 5.0, step = 0.1,
     group   = GRP_DIV,
     tooltip = "Minimum price swing between divergence pivots as a percentage of the recent (momLen × 4 bars) high-low range.\n\nFilters divergences caused by tiny price moves relative to volatility.\n\n0.3% → permissive — default\n1.0% → moderate\n2.0%+ → strict\n\nRequires Smart Filter ON.")

sdfFluxConf = input.bool(true, "Require Flux Confirmation",
     group   = GRP_DIV,
     tooltip = "When ON, Flux direction must agree with the divergence direction at the moment of detection:\n\n• Bullish divergence → Flux value must be > 0 (uptrend bias)\n• Bearish divergence → Flux value must be < 0 (downtrend bias)\n\nFilters out divergences that fire counter to the broader directional bias. Most useful when the Flux engine is set to a longer length than Momentum.\n\nRequires Smart Filter ON. Default: ON.")

// ── Trend Regime ─────────────────────────────────────────────────────────────
// ADX-based market state detector. Classifies every bar as TRENDING UP /
// TRENDING DOWN / RANGING / TRANSITION from ADX strength + DI± direction.
// Feeds the Dashboard Regime row and optionally adapts the Confluence
// Signal Threshold (permissive in trends, strict in ranges).

regimeOn = input.bool(true, "Show Regime",
     group   = GRP_REGIME,
     tooltip = "Master toggle for the Trend Regime Detector. When ON, the Dashboard adds a Regime row showing the current market state (⯅ TRENDING UP / ⯆ TRENDING DOWN / ▣ RANGING / ▤ TRANSITION) computed from a built-in ADX + DI± classifier.\n\nWhen OFF, the Regime row hides and the Adaptive Signal Threshold feature is disabled regardless of its own toggle.\n\nDefault: ON.")

regimeLen = input.int(14, "ADX Length",
     minval = 5, maxval = 50, step = 1,
     group   = GRP_REGIME,
     tooltip = "Lookback for the ADX calculation used by the Regime Detector. The standard 14 matches most charting platforms.\n\n7–10 → very reactive (catches early regime shifts)\n14 → balanced — default\n21–28 → smooth (only major, sustained regime changes register)\n\nDefault: 14")

regimeTrendTh = input.float(25.0, "Trend Threshold",
     minval = 15.0, maxval = 50.0, step = 1.0,
     group   = GRP_REGIME,
     tooltip = "ADX value above which the market is classified as TRENDING. Standard convention: ADX > 25 = trend present, ADX < 20 = ranging market.\n\n20 → permissive, many bars classified as trending\n25 → balanced — default\n30+ → strict, only strong trends classified as TRENDING\n\nDefault: 25")

regimeRangeTh = input.float(20.0, "Range Threshold",
     minval = 10.0, maxval = 25.0, step = 1.0,
     group   = GRP_REGIME,
     tooltip = "ADX value below which the market is classified as RANGING. The band between Range and Trend thresholds is TRANSITION (low confidence — neither state strongly active).\n\n15 → strict (only deep range classified as RANGING)\n20 → balanced — default\n22+ → permissive (more bars classified as RANGING)\n\nDefault: 20")

regimeAdaptive = input.bool(false, "Auto-Adjust Signal Threshold",
     group   = GRP_REGIME,
     tooltip = "When ON, the Confluence Signal Threshold auto-adjusts to the detected regime. The Confluence Buy ▲ / Sell ▼ arrows are mean-reversion (counter-trend) triggers, so the threshold shifts toward where mean-reversion actually works:\n\n• TRENDING → threshold + 10 (stricter; a trend runs shallow fades over, so only the deepest counter-trend signals fire)\n• RANGING → threshold − 10 (looser; mean-reversion thrives in ranges, so more fades are allowed)\n• TRANSITION → unchanged (your manual threshold)\n\nUse for context-aware signal generation that respects the market state. Default: OFF (manual threshold respected as-is).")

// ── Bar Coloring ─────────────────────────────────────────────────────────────
// Optional chart-wide colouring mode driven by oscillator state. Five
// mutually exclusive modes; "None" emits na so barcolor() is a no-op.

barMode = input.string("None", "Bar Color Mode",
     options = ["None", "Momentum", "Flux", "Squeeze", "Confluence", "Slope"],
     group   = GRP_BAR,
     tooltip = "Applies a state-driven colour to every price bar on the chart.\n\nNone → leave bars untouched (default)\nMomentum → bull above zero, bear below zero\nFlux → bull when flux > 0, bear when flux < 0\nSqueeze → squeeze colour ramp when compressed, neutral otherwise\nConfluence → strong / weak / none tiers\nSlope → bull when mom > signal, bear when mom < signal\n\nDefault: None")

// ── Multi-Timeframe Confluence ───────────────────────────────────────────────
// PRO MTF panel — calculates Momentum + Flux on four higher timeframes
// simultaneously via request.security() and surfaces alignment / divergence
// against the active chart's bias. Anti-repaint (lookahead_off), works on
// every asset and chart timeframe.

showMTF = input.bool(true, "Show MTF Panel",
     group   = GRP_MTF,
     tooltip = "Master toggle for the Multi-Timeframe Confluence panel. The panel runs the full Momentum + Flux + Confluence stack on four higher timeframes simultaneously and shows each TF's bias as a separate row.\n\nThe header tag shows the overall alignment state:\n• ▲▲▲▲ ALIGNED — all four TFs bullish (highest-conviction long setup)\n• ▼▼▼▼ ALIGNED — all four TFs bearish (highest-conviction short setup)\n• ◈ MIXED — TFs disagree (no clean direction)\n\nAll MTF calls use lookahead_off — fully repaint-safe on every closed bar.")

mtfPreset = input.string("Swing", "Timeframe Preset",
     options = ["Scalp", "Intraday", "Swing", "Position", "Crypto", "Forex"],
     group   = GRP_MTF,
     tooltip = "Pre-tuned four-timeframe sets matched to common trader profiles:\n\nScalp: 1m / 5m / 15m / 1h — fast scalper\nIntraday: 5m / 15m / 1h / 4h — day trader\nSwing: 15m / 1h / 4h / 1D — default, swing trader\nPosition: 1h / 4h / 1D / 1W — position trader\nCrypto: 5m / 15m / 1h / 4h — 24/7 markets\nForex: 15m / 1h / 4h / 1D — session-based markets\n\nDefault: Swing")

mtfPos = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_MTF,
     tooltip = "Anchor position for the MTF Confluence panel inside the indicator pane. Default is Top Right so it docks vertically opposite the main Dashboard (Bottom Right) without overlapping. Six slots — pick whichever clears your other indicators.")

mtfSize = input.string("Small", "Panel Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_MTF,
     tooltip = "Text size inside the MTF Confluence panel. Defaults to Small to mirror the main Dashboard size.")

// ── Dashboard ────────────────────────────────────────────────────────────────
// Compact PRO data table drawn on the last bar. Mirrors the Artemis Wave
// Oscillator convention so the whole catalogue feels like one product family.

showDash = input.bool(true, "Show Dashboard",
     group   = GRP_DASH,
     tooltip = "Master toggle for the on-chart data panel.\n\nShows at a glance:\n• Bias — Strong / Weak Bull / Bear / Neutral from mom + flux agreement\n• TS Score — composite 0–100 trend strength reading (RSI-style)\n• Momentum — current momentum value + trend arrow\n• Flux — current flux value + trend arrow\n• Squeeze — Tight / Mid / Loose / — compression tier\n• Confluence — Strong / Weak / None tag\n• Div — most recent divergence detected within the last 50 bars\n• Slope — ▲ momentum above signal, ▼ below\n\nColours are driven by the active Theme. On Midnight / Graphite themes the panel automatically flips to a light background so the text stays readable against dark plots.")

dashPos = input.string("Bottom Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = GRP_DASH,
     tooltip = "Anchor position inside the indicator pane where the dashboard docks.\n\nSix slots — three vertical bands × two sides. Pick whichever does not overlap your other indicators or labels.\n\nDefault: Bottom Right (pairs with MTF panel at Top Right — vertically separated to avoid overlap).")

dashSize = input.string("Small", "Panel Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = GRP_DASH,
     tooltip = "Text size inside the dashboard.\n\nTiny → smallest, compact layouts\nSmall → default, clean and readable\nNormal → larger, comfortable reading\nLarge → maximum visibility")

dashColorMode = input.string("Uniform", "Cell Color Mode",
     options = ["Uniform", "Directional"],
     group   = GRP_DASH,
     tooltip = "How the value cells of the Dashboard and MTF panel are coloured.\n\nUniform (default) → every value paints in one theme tone; direction is read from the ▲ ▼ ■ glyphs. Cleanest, most cohesive across all 13 themes — both panels read as one product.\n\nDirectional → each value is tinted by its live state, so you read the panel at a glance by colour: bullish = theme bull hue, bearish = theme bear hue, neutral = desaturated. Squeeze tints to its compression accent when active. The row labels stay in the uniform tone for contrast.\n\nPurely cosmetic — no signal logic changes either way.")

// ── Alerts ───────────────────────────────────────────────────────────────────
// Opt-in toggles for every core event. Each alert is gated only by its OWN
// switch here — independent of the on-chart show/display toggles. This is
// deliberate: you can declutter the pane (hide gauges, lines or markers) and
// still receive the alert. So an alert can fire while its visual is hidden.

simple bool alrtBuy       = input.bool(true,  "Confluence Buy",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum crosses ABOVE the signal line while below −Threshold AND Flux is bearish — classical mean-reversion long trigger inside a downtrend. Threshold is the Confluence Gauges → Signal Threshold setting. Respects the Volume Confirmation gate when enabled, so the alert matches the on-chart ▲ arrow whenever the Bear gauge is displayed (the alert is independent of the gauge Display Mode).")

simple bool alrtSell      = input.bool(true,  "Confluence Sell",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum crosses BELOW the signal line while above +Threshold AND Flux is bullish — classical mean-reversion short trigger inside an uptrend. Threshold is the Confluence Gauges → Signal Threshold setting. Respects the Volume Confirmation gate when enabled, so the alert matches the on-chart ▼ arrow whenever the Bull gauge is displayed (the alert is independent of the gauge Display Mode).")

simple bool alrtTsTier    = input.bool(false, "TS Score Tier Change",
     group   = GRP_ALRT,
     tooltip = "Fires when the composite Trend Strength Score crosses into a new tier:\n\nSTRONG BULL (≥ 75) / BULL (60–74) / NEUTRAL (40–59) / BEAR (25–39) / STRONG BEAR (< 25)\n\nA single one-glance read of shifting overall trend strength, mirroring the dashboard TS Score row. OFF by default. Fires once per tier change (not every bar).")

simple bool alrtMomUp     = input.bool(true,  "Momentum Cross Up",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum crosses above zero (bullish regime flip).")

simple bool alrtMomDn     = input.bool(true,  "Momentum Cross Down",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum crosses below zero (bearish regime flip).")

simple bool alrtFluxUp    = input.bool(true,  "Flux Cross Up",
     group   = GRP_ALRT,
     tooltip = "Fires when Flux crosses above zero (bullish directional flip).")

simple bool alrtFluxDn    = input.bool(true,  "Flux Cross Down",
     group   = GRP_ALRT,
     tooltip = "Fires when Flux crosses below zero (bearish directional flip).")

simple bool alrtSwingUp   = input.bool(false, "Bullish Swing",
     group   = GRP_ALRT,
     tooltip = "Fires on every momentum × signal upward cross, regardless of zone. Frequent on short timeframes — best combined with Confluence or Trend alerts for confirmation.")

simple bool alrtSwingDn   = input.bool(false, "Bearish Swing",
     group   = GRP_ALRT,
     tooltip = "Fires on every momentum × signal downward cross, regardless of zone. Frequent on short timeframes — best combined with Confluence or Trend alerts for confirmation.")

simple bool alrtConfBull  = input.bool(true,  "Strong Bull Confluence",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum AND flux both turn bullish (full strong-bull state activates the upper confluence gauge).")

simple bool alrtConfBear  = input.bool(true,  "Strong Bear Confluence",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum AND flux both turn bearish (full strong-bear state activates the lower confluence gauge).")

simple bool alrtWeakBull  = input.bool(false, "Weak Bull Confluence",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum turns bullish while flux is not yet bullish (partial bull state — weaker confluence). OFF by default.")

simple bool alrtWeakBear  = input.bool(false, "Weak Bear Confluence",
     group   = GRP_ALRT,
     tooltip = "Fires when momentum turns bearish while flux is not yet bearish. OFF by default.")

simple bool alrtSqzTight  = input.bool(true,  "Tight Squeeze",
     group   = GRP_ALRT,
     tooltip = "Fires when stdev drops below ATR × the Tight Multiplier (default 0.5 at Length 20; the threshold auto-scales with Length) — extreme compression, expansion imminent.")

simple bool alrtSqzMid    = input.bool(false, "Mid Squeeze",
     group   = GRP_ALRT,
     tooltip = "Fires when stdev drops below ATR × the Mid Multiplier (default 0.75 at Length 20; the threshold auto-scales with Length) — moderate compression. OFF by default to avoid noise.")

simple bool alrtSqzLoose  = input.bool(false, "Loose Squeeze",
     group   = GRP_ALRT,
     tooltip = "Fires when stdev drops below ATR × the Loose Multiplier (default 1.0 at Length 20; the threshold auto-scales with Length) — mild compression. OFF by default.")

simple bool alrtDivReg    = input.bool(true,  "Regular Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Regular bullish or bearish divergence detection. Respects the Smart Filter when enabled.")

simple bool alrtDivHid    = input.bool(false, "Hidden Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires on Hidden bullish or bearish divergence detection. OFF by default — Hidden divergences fire more frequently than Regular. Respects the Smart Filter when enabled.")

simple bool alrtSqzRelease = input.bool(true,  "Squeeze Release",
     group   = GRP_ALRT,
     tooltip = "Fires on the bar where the squeeze fully ends (stdev re-expanded above ATR × the Loose Multiplier, default 1.0 at Length 20; the threshold auto-scales with Length). Imminent volatility expansion — historically the highest-conviction breakout setup.")

simple bool alrtMtfAlign   = input.bool(true,  "MTF Aligned",
     group   = GRP_ALRT,
     tooltip = "Fires the bar all four MTF timeframes first agree on direction (all bull or all bear). The highest-conviction multi-timeframe confluence setup. Fires once per state change to avoid spam.")

simple bool alrtMtfDiv     = input.bool(false, "MTF Divergence",
     group   = GRP_ALRT,
     tooltip = "Fires the bar the current chart's bias first contradicts the majority of HTF biases (3 or more HTFs against current). Useful as a contrarian / counter-trend warning. OFF by default to keep noise low.")

simple bool alrtRegime     = input.bool(false, "Regime Shift",
     group   = GRP_ALRT,
     tooltip = "Fires the bar the market regime transitions (TRENDING ⇄ RANGING ⇄ TRANSITION). Useful as a strategy-switching signal: trending bias when regime is trending, mean-reversion bias when ranging. OFF by default — regime shifts on long histories can fire frequently.")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — METHODS
// Seven small methods drive the entire engine. Declared at top level so they
// participate in Pine v6's UFCS (`b.computeMom(...)`, `x.runStdev(len)`).
// ═══════════════════════════════════════════════════════════════════════════════

// True Range — single-bar primitive. Falls back to high − low on the first
// bar (when close[1] is na), otherwise the classic max(h-l, |h-c[1]|, |l-c[1]|).
// Pine v6 forbids `udt.field[1]` directly — history must be taken on the
// whole object first, then the field accessed. The `na(bPrev)` guard is
// mandatory: on bar 0 the prior object itself is na, and dereferencing a
// field on a na UDT throws a runtime "Cannot access the 'Bar.c' field of
// an undefined object" error.
method runTr(Bar b) =>
    Bar   bPrev = b[1]
    float prevC = na(bPrev) ? na : bPrev.c
    na(prevC) ? b.h - b.l : math.max(math.max(b.h - b.l, math.abs(b.h - prevC)), math.abs(b.l - prevC))

// ATR — RMA-smoothed True Range across `len` bars.
method runAtr(Bar b, simple int len) =>
    ta.rma(b.runTr(), len)

// Welford-style running standard deviation — single-pass O(len) algorithm
// that updates the running mean and squared deviation simultaneously.
// Numerically stable on long histories where naive sum-of-squares drifts.
//
// Denominator note: this returns the SAMPLE standard deviation (÷ len − 1),
// not the population form ta.stdev uses (÷ len). The two differ by a constant
// sqrt(len / (len − 1)) — about +2.6% at len = 20. This is intentional and the
// squeeze multipliers (0.5 / 0.75 / 1.0) are calibrated against this sample
// value; if you ever swap to ta.stdev, re-tune those multipliers ~2.6% down to
// keep the three tiers firing at the same compression.
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

// Heiken Ashi bar — produces a smoothed OHLC bar for the Flux engine when
// the user enables "Use Heiken Ashi Bias". Standard HA formulas:
//   haClose = (open + high + low + close) / 4
//   haOpen  = (prevHaOpen + prevHaClose) / 2
//   haHigh  = max(high, haOpen, haClose)
//   haLow   = min(low,  haOpen, haClose)
method haBar(Bar b) =>
    // No `var` needed: `ha` is reassigned every bar and only its PRIOR value is
    // ever read, via `ha[1]` — and the history operator returns the previous
    // bar's committed value whether or not the variable carries over, so `var`
    // would change nothing here.
    Bar ha = Bar.new(na, na, na, na)
    // Pine v6 disallows `ha.o[1]` — hoist the whole-object history first,
    // then read each field on the previous object reference.
    Bar   haPrev = ha[1]
    float prevO  = na(haPrev) ? na : haPrev.o
    float prevC  = na(haPrev) ? na : haPrev.c
    float haC    = math.avg(b.o, b.h, b.l, b.c)
    float haO    = na(prevO) ? math.avg(b.o, b.c) : math.avg(nz(prevO), nz(prevC))
    float haH    = math.max(b.h, math.max(haO, haC))
    float haL    = math.min(b.l, math.min(haO, haC))
    ha          := Bar.new(haO, haH, haL, haC)
    ha

// Momentum engine — Squeeze Momentum (linreg-based), four ordered steps:
//   1. Compute the channel midpoint: (highest + lowest) / 2 over momLen.
//   2. Compute SMA of HL2 over momLen — the "smoothed midline" reference.
//   3. Build a synthetic channel bar from the channel highs/lows; its
//      gap-inclusive single-bar true range (chanAtr) is the normaliser.
//   4. Linreg((close − avg(channelMid, smaMid)) / chanAtr × 100, momLen).
// The signal is an SMA of the linreg over momSigLen. Both lines drive the
// downstream divergence + confluence logic.
method computeMom(Bar b, simple int len, simple int sigLen) =>
    float chanHi  = ta.highest(b.h, len)
    float chanLo  = ta.lowest (b.l, len)
    float chanMid = math.avg(chanHi, chanLo)
    float smaMid  = ta.sma(math.avg(b.h, b.l), len)
    float chanRng = chanHi - chanLo
    // Channel-aware TR: include gap-to-prior-close component so overnight
    // gaps inflate the denominator (matches Pine v5 `tr(true)` on the
    // synthetic channel bar). Falls back to running TR if both branches
    // collapse to a flat range (preventing divide-by-zero on dead markets).
    // Pine v6 forbids `b.c[1]` directly — history is requested on the whole
    // object first, then the field is read on the prior object. The
    // `na(bPrev)` guard prevents a bar-0 runtime error where dereferencing
    // a field on a na UDT crashes ("Cannot access the 'Bar.c' field...").
    Bar   bPrev   = b[1]
    float prevC   = na(bPrev) ? na : bPrev.c
    float chanTr  = na(prevC) ? chanRng : math.max(chanRng, math.max(math.abs(chanHi - prevC), math.abs(chanLo - prevC)))
    float chanAtr = chanTr < 1e-10 ? b.runTr() : chanTr
    float momRaw  = (b.c - math.avg(chanMid, smaMid)) / chanAtr * 100.0
    float momVal  = ta.linreg(momRaw, len, 0)
    float momSig  = ta.sma(momVal, sigLen)
    MomReading.new(momVal, momSig)

// Directional Flux — ADX-style up/down ratio, self-normalised by (up + dn).
// The "overflow" branch is the part of flux that exceeds ±25 (where
// directional pressure becomes structurally significant); rendered as a
// separate fill so traders can read both raw direction and acceleration.
//
// Note: an earlier version divided both `up` and `dn` by ATR, but that factor
// cancels in (up − dn) / (up + dn) — it never changed the output and only
// burned one RMA pass per bar. The ratio is already scale-free: dividing the
// difference by the sum bounds it to [−1, 1] regardless of price units, so no
// ATR term is needed. Dead-flat markets (up = dn = 0) fall through to 0.
method computeFlux(Bar b, simple int len) =>
    float up = ta.rma(math.max(ta.change(b.h),      0), len)
    float dn = ta.rma(math.max(ta.change(b.l) * -1, 0), len)
    float denom = up + dn
    float ratio = denom < 1e-10 ? 0.0 : (up - dn) / denom
    float fluxVal = ta.rma(ratio, len / 2) * 100.0
    float fluxOf  = fluxVal > +25 ? fluxVal - 25 : fluxVal < -25 ? fluxVal + 25 : na
    FluxReading.new(fluxVal, fluxOf)

// Squeeze detector — three nested tiers based on the stdev / ATR ratio, each
// threshold length-normalised. The tightest active tier wins downstream.
//
// Length normalisation (lenAdj): stdev(close, len) measures the dispersion of
// accumulated price LEVELS, which on a near-random-walk series grows ~√len,
// while ATR is a per-bar quantity that does NOT grow with the window. So the
// raw stdev/ATR ratio scales ~√len, and a fixed multiplier would silently
// change its selectivity as the shared momLen (7–50) moves — e.g. mult 1.0
// fires on ~half of bars at len 20, ~95% at len 10, ~10% at len 50. Scaling
// each threshold by √(len / 20) cancels that √len growth and anchors the
// calibration at the default length 20 (lenAdj = 1.0 there, so existing
// defaults are UNCHANGED). After this, a multiplier is a stable "fires ~X% of
// bars" dial at ANY length — Length controls the timescale, the multiplier
// controls selectivity. The correction is ticker-agnostic: the √len growth is
// a property of windowing a near-random-walk, not of any instrument. It is
// applied identically to all three tiers, so the nesting (tight ⇒ mid ⇒ loose)
// is preserved.
method detectSqueeze(Bar b, simple int len, float mTight, float mMid, float mLoose) =>
    float dev    = b.c.runStdev(len)
    float atr    = b.runAtr(len)
    float lenAdj = math.sqrt(len / 20.0)
    bool  sqzTight = dev < atr * mTight * lenAdj
    bool  sqzMid   = dev < atr * mMid   * lenAdj
    bool  sqzLoose = dev < atr * mLoose * lenAdj
    SqueezeState.new(sqzTight, sqzMid, sqzLoose)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — ENGINE
// Drive the bar bundle through every analytical method and unpack the
// readings into short-named aliases so the plot + alert blocks below stay
// readable.
// ═══════════════════════════════════════════════════════════════════════════════

Bar barRaw = Bar.new(open, high, low, close)
Bar barFlx = fluxHA ? barRaw.haBar() : barRaw

// Sort the three tier multipliers into ascending order before they reach the
// detector, so the nesting semantic (tight ⇒ mid ⇒ loose) can NEVER invert —
// even if a user sets Tight > Loose. This silently reorders the raw inputs by
// value (the intended foolproof behaviour); the median is sum − min − max.
float sqzMultLo  = math.min(sqzTightMult, sqzMidMult, sqzLooseMult)
float sqzMultHi  = math.max(sqzTightMult, sqzMidMult, sqzLooseMult)
float sqzMultMid = sqzTightMult + sqzMidMult + sqzLooseMult - sqzMultLo - sqzMultHi

MomReading    mom = barRaw.computeMom    (momLen, momSigLen)
FluxReading   flx = barFlx.computeFlux   (fluxLen)
SqueezeState  sqz = barRaw.detectSqueeze (momLen, sqzMultLo, sqzMultMid, sqzMultHi)

float momVal  = mom.value
float momSig  = mom.signal
float fluxVal = flx.value
float fluxOf  = flx.overflow

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — SIGNAL DETECTION
// All cross-state booleans + confluence states live here, computed once
// and reused by the plots, the dashboard, the bar painter and the alert
// block. Calculating each event in a single place guarantees the visual
// layer and the alert layer can never disagree.
// ═══════════════════════════════════════════════════════════════════════════════

bool xMomUp   = ta.crossover (momVal, momSig)   // momentum crossed up through signal
bool xMomDn   = ta.crossunder(momVal, momSig)   // momentum crossed down through signal
bool xMomZUp  = ta.crossover (momVal, 0)        // momentum crossed up through zero
bool xMomZDn  = ta.crossunder(momVal, 0)        // momentum crossed down through zero
bool xFluxUp  = ta.crossover (fluxVal, 0)       // flux crossed up through zero
bool xFluxDn  = ta.crossunder(fluxVal, 0)       // flux crossed down through zero

// ── Trend Regime Detector ────────────────────────────────────────────────────
// Built-in ADX + DI± classification — computed once here and reused by the
// dashboard, the adaptive threshold below, and the regime-shift alert.
// ta.dmi returns three series: positive directional movement, negative
// directional movement, and the ADX itself.
//   regimeCode encoding:
//     +2 — TRENDING UP   (ADX > trend th, DI+ > DI−)
//     −2 — TRENDING DOWN (ADX > trend th, DI+ ≤ DI−)
//      0 — TRANSITION    (between range and trend thresholds)
//     +1 — RANGING       (ADX < range th — direction irrelevant)
[regimeDiPlus, regimeDiMinus, regimeAdx] = ta.dmi(regimeLen, regimeLen)
bool   regimeTrending  = regimeOn and regimeAdx > regimeTrendTh
bool   regimeRanging   = regimeOn and regimeAdx < regimeRangeTh
bool   regimeBullTrend = regimeTrending and regimeDiPlus >  regimeDiMinus
bool   regimeBearTrend = regimeTrending and regimeDiPlus <= regimeDiMinus
int    regimeCode      = (regimeBullTrend ?  2 :
                          regimeBearTrend ? -2 :
                          regimeRanging   ?  1 :
                                             0)
string regimeTag       = (regimeBullTrend ? "⯅ TRENDING UP" :
                          regimeBearTrend ? "⯆ TRENDING DOWN" :
                          regimeRanging   ? "▣ RANGING" :
                          regimeOn        ? "▤ TRANSITION" :
                                            "—")
// Regime shift — fires the bar regime changes from one code to another.
// `nz(...)` defaults the prior to the current code on bar 0 so we don't
// fire a false shift on the very first historical bar.
bool   regimeShift     = regimeOn and regimeCode != nz(regimeCode[1], regimeCode)

// ── Adaptive Signal Threshold ────────────────────────────────────────────────
// The Confluence Buy ▲ / Sell ▼ arrows are MEAN-REVERSION (counter-trend)
// triggers — they fade a momentum extreme back toward the mean. Such fades pay
// off in RANGES and get run over in TRENDS, so when regimeAdaptive is ON the
// threshold adapts toward where mean-reversion actually works:
//   • TRENDING → +10 (STRICTER — a trend overruns shallow fades, so only the
//                      deepest counter-trend signals are allowed to fire)
//   • RANGING  → −10 (LOOSER — mean-reversion is in its element here, so let
//                      more fades through)
//   • TRANSITION → unchanged
// (Earlier versions had this backwards — loosening in trends and tightening in
// ranges — which invited the most fades exactly where the trend would run them
// over. The sign is now aligned with the signals' mean-reversion nature.)
// Implemented as an integer offset so the manual `confThresh` stays the
// single source of truth for the user-set baseline.
int  confThreshAdj    = (regimeAdaptive and regimeOn ?
                            (regimeTrending ? 10 : regimeRanging ? -10 : 0) : 0)
int  confThreshActive = math.max(1, confThresh + confThreshAdj)

// ── Volume Confirmation gate ─────────────────────────────────────────────────
// Optional filter applied to the Confluence Buy ▲ / Sell ▼ triangles only.
// Computes the volume MA once here; downstream signal lines consume `volPass`.
// On assets without reliable volume data (Forex, some indices) either `volume`
// or its MA collapses to na/0, so the gate is bypassed entirely — the filter
// is transparent on symbols where volume cannot be trusted.
float volAvg    = ta.sma(volume, volMaLen)
bool  volHasData = not na(volume) and volume > 0 and not na(volAvg) and volAvg > 0
bool  volPass    = not volConfOn or not volHasData or volume > volAvg

// Confluence arrows use the (possibly regime-adjusted) `confThreshActive` —
// independent of the Divergence Sensitivity, since the two engines need
// different thresholds: divergence wants permissive (25) for pivot detection,
// while confluence arrows want strict (40) to mark deep mean-reversion
// triggers. The volume gate adds a final conviction check that low-volume
// fake-outs cannot satisfy on volume-enabled symbols.
bool buySignal  = xMomUp and momVal < -confThreshActive and fluxVal < 0 and volPass   // confluence buy
bool sellSignal = xMomDn and momVal >  confThreshActive and fluxVal > 0 and volPass   // confluence sell

// ── Confluence states ────────────────────────────────────────────────────────
// Four GENUINELY mutually exclusive tiers from the mom + flux agreement matrix.
//   Strong Bull — mom > 0 AND flux > 0   |   Strong Bear — mom < 0 AND flux < 0
//   Weak Bull   — mom > 0, flux not bull |   Weak Bear   — mom < 0, flux not bear
//
// Momentum is the deciding vote (tie-break): when mom and flux disagree the
// state follows momentum's sign. This makes the four tiers sign-exclusive — at
// most one is ever true. The previous OR-based Weak definitions overlapped
// (mom +5 / flux −50 lit BOTH Weak Bull and Weak Bear), and every downstream
// consumer resolved the tie bull-first, so mixed regimes read falsely bullish.
// When mom is exactly 0 no tier fires (neutral), regardless of flux.
// Used by the gauges, dashboard, bar painter, TS Score, curDir and mtfBias.
bool confStrongBull = momVal > 0 and fluxVal > 0
bool confStrongBear = momVal < 0 and fluxVal < 0
bool confWeakBull   = momVal > 0 and fluxVal <= 0
bool confWeakBear   = momVal < 0 and fluxVal >= 0

// Confluence transitions — used for "freshly entered state" alerts.
bool justStrongBull = confStrongBull and not confStrongBull[1]
bool justStrongBear = confStrongBear and not confStrongBear[1]
bool justWeakBull   = confWeakBull   and not confWeakBull[1]
bool justWeakBear   = confWeakBear   and not confWeakBear[1]

// Squeeze transitions — fire on the bar the tier first activates.
// Pine v6 forbids `sqz.tight[1]` (UDT field history); take history on the
// whole object first via `(sqz[1]).tight`. Guard with `na(...)` because the
// SqueezeState reference itself is na on the very first bar.
SqueezeState sqzPrev = sqz[1]
bool wasTight = not na(sqzPrev) and sqzPrev.tight
bool wasMid   = not na(sqzPrev) and sqzPrev.mid
bool wasLoose = not na(sqzPrev) and sqzPrev.loose
bool justSqzTight = sqz.tight and not wasTight
bool justSqzMid   = sqz.mid   and not wasMid
bool justSqzLoose = sqz.loose and not wasLoose

// Squeeze Release — the bar the loosest active tier (stdev < ATR × Loose Mult.)
// drops off, meaning compression has FULLY ended. This is the canonical
// "spring uncoiled" moment: volatility expansion begins, breakout direction
// is about to reveal itself. Historically the highest-conviction setup the
// squeeze model produces.
bool sqzReleased = wasLoose and not sqz.loose

// ── Squeeze Release Direction Predictor ──────────────────────────────────────
// At the release bar, measure momentum slope across the predictor lookback.
// A clearly-positive slope means the spring is uncoiling upward → bullish
// breakout most likely; clearly-negative → bearish; within the threshold band
// → direction unclear, marker stays neutral ✦. Predictor output drives both
// the visible glyph (✦▴ / ✦▾ / ✦) and the release-alert message body.
float sqzReleaseSlope = sqzReleased ? momVal - momVal[sqzPredictLook] : na
bool  sqzPredBull     = sqzPredictOn and sqzReleased and sqzReleaseSlope >  sqzPredictThresh
bool  sqzPredBear     = sqzPredictOn and sqzReleased and sqzReleaseSlope < -sqzPredictThresh

// ── Composite Trend Strength Score (0–100) ───────────────────────────────────
// PRO summary score blending every analytical layer into a single 0–100
// reading (RSI-style scale). 50 is neutral, > 50 leans bull, < 50 leans bear.
//   • Momentum     30% — current mom value mapped from −100..+100 → 0..100
//   • Flux         30% — current flux value mapped the same way
//   • Mom × Signal 15% — slope direction confirmation (70 if mom > sig, else 30)
//   • Confluence   25% — confluence tier (90 strong-bull, 65 weak-bull,
//                        50 neutral, 35 weak-bear, 10 strong-bear)
// The weights add to 1.0 so the output stays cleanly inside the 0–100 band.
float scMom   = math.max(0.0, math.min(100.0, 50.0 + momVal  / 2.0))
float scFlux  = math.max(0.0, math.min(100.0, 50.0 + fluxVal / 2.0))
float scSlope = momVal > momSig ? 70.0 : 30.0
float scConf  = (confStrongBull ? 90.0 :
                 confStrongBear ? 10.0 :
                 confWeakBull   ? 65.0 :
                 confWeakBear   ? 35.0 :
                                  50.0)
float tsScore = math.round(scMom * 0.30 + scFlux * 0.30 + scSlope * 0.15 + scConf * 0.25)

// TS Score tier label — used for the dashboard summary row.
string tsScoreTier  = (tsScore >= 75 ? "STRONG BULL" :
                       tsScore >= 60 ? "BULL" :
                       tsScore >= 40 ? "NEUTRAL" :
                       tsScore >= 25 ? "BEAR" :
                                       "STRONG BEAR")
string tsScoreArrow = tsScore >= 60 ? "▲" : tsScore <= 40 ? "▼" : "■"

// TS Score tier transition — drives the optional TS Score Tier Change alert.
// Guarded against the bar-0 na history so it never fires a false first-bar shift.
bool tsTierShift = bar_index > 0 and tsScoreTier != tsScoreTier[1]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — DIVERGENCE DETECTION
// Cross-confirmed divergence. REGULAR fires only when momentum is in an
// extreme zone (|mom| > divSens) AND crosses its signal line; HIDDEN fires on
// ANY signal-line cross (no zone gate) via its own any-zone anchor pair, so it
// catches continuation during shallow pullbacks. Regular signal reversal,
// Hidden continuation. The Smart AI Filter adds three optional gates (min mom
// swing, min price swing %, flux confirmation) for high-conviction filtering.
// ═══════════════════════════════════════════════════════════════════════════════

// Regular Div anchors — stored at extreme-zone crosses (mom > +divSens for
// the bearish side, mom < −divSens for the bullish side). Regular div catches
// classical exhaustion reversals at deep extremes.
//   *_p — price extreme at the anchor (high for bearish, low for bullish)
//   *_m — momentum value at the anchor
//   *_b — bar index at the anchor (used as the line.new x1 anchor)
var float prevHi_p = na    // previous bearish-setup price high
var float prevHi_m = na    // previous bearish-setup momentum
var int   prevHi_b = int(na)
var float prevLo_p = na    // previous bullish-setup price low
var float prevLo_m = na    // previous bullish-setup momentum
var int   prevLo_b = int(na)

// Hidden Div anchors — stored at ANY signal-line cross (no zone gate). Hidden
// divs fire during shallow pullbacks within an established trend where
// momentum oscillates near zero, so the extreme-zone gate used by Regular
// would block all Hidden detection. Separate anchors let Hidden catch the
// classical continuation pattern (price LH + mom HH for downtrend, or price
// HL + mom LL for uptrend) at any momentum level.
var float hidHi_p = na
var float hidHi_m = na
var int   hidHi_b = int(na)
var float hidLo_p = na
var float hidLo_m = na
var int   hidLo_b = int(na)

// Regular setup — extreme-zone cross. Both anchor storage and detection
// require momentum past the Sensitivity threshold (classical exhaustion).
bool bearSetup = momVal > +divSens and xMomDn and barstate.isconfirmed
bool bullSetup = momVal < -divSens and xMomUp and barstate.isconfirmed

// Hidden setup — any signal-line cross, regardless of zone. This is the
// critical difference from Regular: shallow pullbacks within a strong trend
// rarely push momentum past ±divSens, so Hidden detection must accept every
// cross to capture the continuation patterns.
bool bearHidSetup = xMomDn and barstate.isconfirmed
bool bullHidSetup = xMomUp and barstate.isconfirmed

// Raw divergence flags — populated below when a setup fires and the prev /
// curr comparison meets the divergence shape.
bool dRegBull = false  // price LL + mom HL → reversal up
bool dRegBear = false  // price HH + mom LH → reversal down
bool dHidBull = false  // price HL + mom LL → uptrend continues
bool dHidBear = false  // price LH + mom HH → downtrend continues

// Regular Bear — compare current high + mom against the previous extreme-
// zone bearish anchor.
if bearSetup and not na(prevHi_p) and high > prevHi_p and momSig < prevHi_m
    dRegBear := true

// Regular Bull — symmetric.
if bullSetup and not na(prevLo_p) and low < prevLo_p and momSig > prevLo_m
    dRegBull := true

// Hidden Bear — compare current high + mom against the previous (any-zone)
// hidden bearish anchor. Shape: price LH + mom HH.
if bearHidSetup and not na(hidHi_p) and high < hidHi_p and momSig > hidHi_m
    dHidBear := true

// Hidden Bull — symmetric. Shape: price HL + mom LL.
if bullHidSetup and not na(hidLo_p) and low > hidLo_p and momSig < hidLo_m
    dHidBull := true

// ── Smart AI Filter ──────────────────────────────────────────────────────────
// Three independent gates evaluated when sdfOn is true. The min-swing gates
// reject noise-level differences; the flux gate enforces directional bias
// agreement at the moment of detection. Regular and Hidden divs each evaluate
// against their own anchor pair (Regular uses the extreme-zone anchors,
// Hidden uses the any-zone anchors).
float sdfPxRange = ta.highest(high, momLen * 4) - ta.lowest(low, momLen * 4)
float sdfMinPxAbs = sdfPxRange * (sdfMinPct / 100.0)

float sdfMomSwLo  = na(prevLo_m) ? 0 : math.abs(momSig - prevLo_m)
float sdfMomSwHi  = na(prevHi_m) ? 0 : math.abs(momSig - prevHi_m)
float sdfPxSwLo   = na(prevLo_p) ? 0 : math.abs(low  - prevLo_p)
float sdfPxSwHi   = na(prevHi_p) ? 0 : math.abs(high - prevHi_p)

float sdfMomSwLoH = na(hidLo_m) ? 0 : math.abs(momSig - hidLo_m)
float sdfMomSwHiH = na(hidHi_m) ? 0 : math.abs(momSig - hidHi_m)
float sdfPxSwLoH  = na(hidLo_p) ? 0 : math.abs(low  - hidLo_p)
float sdfPxSwHiH  = na(hidHi_p) ? 0 : math.abs(high - hidHi_p)

bool sdfFluxBull = not sdfFluxConf or fluxVal > 0
bool sdfFluxBear = not sdfFluxConf or fluxVal < 0

bool sdfPassBull    = not sdfOn or (sdfMomSwLo  >= sdfMinMom and sdfPxSwLo  >= sdfMinPxAbs and sdfFluxBull)
bool sdfPassBear    = not sdfOn or (sdfMomSwHi  >= sdfMinMom and sdfPxSwHi  >= sdfMinPxAbs and sdfFluxBear)
bool sdfPassBullHid = not sdfOn or (sdfMomSwLoH >= sdfMinMom and sdfPxSwLoH >= sdfMinPxAbs and sdfFluxBull)
bool sdfPassBearHid = not sdfOn or (sdfMomSwHiH >= sdfMinMom and sdfPxSwHiH >= sdfMinPxAbs and sdfFluxBear)

// ── Divergence palette + label-size resolver ─────────────────────────────────
color colDivBull = color.new(thBull, 0)
color colDivBear = color.new(thBear, 0)

string divSz = (divLabelSize == "Tiny"   ? size.tiny   :
                divLabelSize == "Small"  ? size.small  :
                divLabelSize == "Normal" ? size.normal :
                                           size.large)

// ── Divergence rendering + last-event tracking ───────────────────────────────
// Each detected event paints (optionally) a line between the two pivots and
// drops (optionally) a tooltip-rich label at the current pivot. The
// lastDiv* pair persists across bars so the dashboard reports the most
// recent event up to 50 bars back.
var int    lastDivBar = int(na)
var string lastDivTag = "—"

if divRegOn and dRegBull and sdfPassBull
    if divShowLines
        line.new(prevLo_b, prevLo_m, bar_index, momSig, color = colDivBull, width = 1, style = line.style_solid)
    if divShowLabels
        label.new(bar_index, momSig, "D▲", style = label.style_label_up,   color = colDivBull, textcolor = color.white, size = divSz,
             tooltip = "Regular Bullish Divergence\nPrice: Lower Low\nMomentum: Higher Low\nSignal: Potential reversal to the upside")
    lastDivBar := bar_index
    lastDivTag := "▲ REG"

if divRegOn and dRegBear and sdfPassBear
    if divShowLines
        line.new(prevHi_b, prevHi_m, bar_index, momSig, color = colDivBear, width = 1, style = line.style_solid)
    if divShowLabels
        label.new(bar_index, momSig, "D▼", style = label.style_label_down, color = colDivBear, textcolor = color.white, size = divSz,
             tooltip = "Regular Bearish Divergence\nPrice: Higher High\nMomentum: Lower High\nSignal: Potential reversal to the downside")
    lastDivBar := bar_index
    lastDivTag := "▼ REG"

if divHidOn and dHidBull and sdfPassBullHid
    if divShowLines
        line.new(hidLo_b, hidLo_m, bar_index, momSig, color = colDivBull, width = 1, style = line.style_dashed)
    if divShowLabels
        label.new(bar_index, momSig, "H▲", style = label.style_label_up,   color = colDivBull, textcolor = color.white, size = divSz,
             tooltip = "Hidden Bullish Divergence\nPrice: Higher Low\nMomentum: Lower Low\nSignal: Uptrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▲ HID"

if divHidOn and dHidBear and sdfPassBearHid
    if divShowLines
        line.new(hidHi_b, hidHi_m, bar_index, momSig, color = colDivBear, width = 1, style = line.style_dashed)
    if divShowLabels
        label.new(bar_index, momSig, "H▼", style = label.style_label_down, color = colDivBear, textcolor = color.white, size = divSz,
             tooltip = "Hidden Bearish Divergence\nPrice: Lower High\nMomentum: Higher High\nSignal: Downtrend continuation expected")
    lastDivBar := bar_index
    lastDivTag := "▼ HID"

// Update previous-anchor state — runs AFTER rendering so the line.new
// calls above can still resolve the previous anchor's bar / value pair.
// Anchor-consumption semantics: a divergence that was actually RENDERED
// (passed the Smart AI Filter) CLEARS its anchor to na, so the next anchor
// starts fresh. Otherwise — no divergence, OR one detected but SUPPRESSED by
// the filter — the current swing overwrites the stale anchor and stays
// available for the next comparison. Gating consumption on the same
// `sdfPass*` term as the render/alert layer keeps the three in lock-step:
// a div the user never sees never silently mutates anchor state.
//
// Regular and Hidden each maintain their own anchor pair, so each pair is
// consumed only by its matching divergence type.

if bearSetup
    if not na(prevHi_p) and dRegBear and sdfPassBear
        prevHi_p := na
        prevHi_m := na
        prevHi_b := int(na)
    else
        prevHi_p := high
        prevHi_m := momSig
        prevHi_b := bar_index

if bullSetup
    if not na(prevLo_p) and dRegBull and sdfPassBull
        prevLo_p := na
        prevLo_m := na
        prevLo_b := int(na)
    else
        prevLo_p := low
        prevLo_m := momSig
        prevLo_b := bar_index

if bearHidSetup
    if not na(hidHi_p) and dHidBear and sdfPassBearHid
        hidHi_p := na
        hidHi_m := na
        hidHi_b := int(na)
    else
        hidHi_p := high
        hidHi_m := momSig
        hidHi_b := bar_index

if bullHidSetup
    if not na(hidLo_p) and dHidBull and sdfPassBullHid
        hidLo_p := na
        hidLo_m := na
        hidLo_b := int(na)
    else
        hidLo_p := low
        hidLo_m := momSig
        hidLo_b := bar_index

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — MULTI-TIMEFRAME CONFLUENCE
// Run the full Momentum + Flux stack on four higher timeframes simultaneously
// via request.security(). All MTF calls use lookahead_off — fully repaint
// safe on closed bars. Per-TF bias plus overall alignment / divergence
// detection feed both the on-pane panel (Section 10) and the alert block.
// ═══════════════════════════════════════════════════════════════════════════════

// ── Preset timeframe resolver ────────────────────────────────────────────────
// Six pre-tuned packs map a single preset choice to four ordered HTFs.
// Defaults to "Swing" (15m / 1h / 4h / 1D) — the most common multi-TF
// workflow for stocks and crypto.

string mtfTf1 = switch mtfPreset
    "Scalp"    => "1"
    "Intraday" => "5"
    "Swing"    => "15"
    "Position" => "60"
    "Crypto"   => "5"
    "Forex"    => "15"
    =>             "15"

string mtfTf2 = switch mtfPreset
    "Scalp"    => "5"
    "Intraday" => "15"
    "Swing"    => "60"
    "Position" => "240"
    "Crypto"   => "15"
    "Forex"    => "60"
    =>             "60"

string mtfTf3 = switch mtfPreset
    "Scalp"    => "15"
    "Intraday" => "60"
    "Swing"    => "240"
    "Position" => "D"
    "Crypto"   => "60"
    "Forex"    => "240"
    =>             "240"

string mtfTf4 = switch mtfPreset
    "Scalp"    => "60"
    "Intraday" => "240"
    "Swing"    => "D"
    "Position" => "W"
    "Crypto"   => "240"
    "Forex"    => "D"
    =>             "D"

// ── Friendly TF labels ───────────────────────────────────────────────────────
// Raw Pine timeframe strings ("60", "240", "D") are required by
// request.security(), but readers — especially newer traders — recognise the
// chart-toolbar style ("1h", "4h", "1D") at a glance. This helper converts
// the raw string to its display form; the request.security() calls below
// still consume the raw value, while the MTF panel and alert messages
// display the friendly version.
mtfLabel(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1h"
        "120" => "2h"
        "180" => "3h"
        "240" => "4h"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        =>       tf

string mtfTf1Label = mtfLabel(mtfTf1)
string mtfTf2Label = mtfLabel(mtfTf2)
string mtfTf3Label = mtfLabel(mtfTf3)
string mtfTf4Label = mtfLabel(mtfTf4)

// ── Per-TF computation wrapper ───────────────────────────────────────────────
// Evaluated inside request.security() so the Momentum and Flux engines run
// on the requested HTF's OHLC stream, not the current chart's. Mirrors the
// main-chart engine split exactly: Momentum always reads raw HTF OHLC, while
// Flux honours the "Use Heiken Ashi Bias" toggle so the MTF panel and the
// chart can never disagree for a reason unrelated to the timeframe itself.
// Returns a tuple (mom value, flux value) — destructured below.
mtfData() =>
    Bar bMtf  = Bar.new(open, high, low, close)
    Bar bMtfF = fluxHA ? bMtf.haBar() : bMtf
    MomReading  mMtf = bMtf.computeMom (momLen, momSigLen)
    FluxReading fMtf = bMtfF.computeFlux(fluxLen)
    [mMtf.value, fMtf.value]

[m1, f1] = request.security(syminfo.tickerid, mtfTf1, mtfData(), lookahead = barmerge.lookahead_off)
[m2, f2] = request.security(syminfo.tickerid, mtfTf2, mtfData(), lookahead = barmerge.lookahead_off)
[m3, f3] = request.security(syminfo.tickerid, mtfTf3, mtfData(), lookahead = barmerge.lookahead_off)
[m4, f4] = request.security(syminfo.tickerid, mtfTf4, mtfData(), lookahead = barmerge.lookahead_off)

// ── Bias classification per TF ───────────────────────────────────────────────
// Reuses the same Strong/Weak/Neutral confluence ladder as the main chart,
// returning a printable tag + an integer direction code (−1, 0, +1) for the
// alignment maths below.
// Mirrors the main-chart confluence ladder EXACTLY (mom-priority tie-break),
// so a per-TF row can never read bullish and bearish at once.
mtfBias(float m, float f) =>
    bool sb = m > 0 and f > 0
    bool sB = m < 0 and f < 0
    bool wb = m > 0 and f <= 0
    bool wB = m < 0 and f >= 0
    string tag = sb ? "▲ STRONG" : wb ? "▲ WEAK" : sB ? "▼ STRONG" : wB ? "▼ WEAK" : "◈ NEUTRAL"
    int    dir = (sb or wb) ? 1 : (sB or wB) ? -1 : 0
    [tag, dir]

// ── Sub-timeframe guard ──────────────────────────────────────────────────────
// A preset can request a timeframe BELOW the chart's own (e.g. a Daily chart
// running the Scalp preset asks for 1m / 5m / 15m / 1h). request.security then
// pulls a sub-chart resolution whose bias is meaningless against the chart, so
// any such row is forced neutral (dir 0) and tagged "— n/a" instead of feeding
// the alignment / divergence maths below with noise. Rows at or above the chart
// timeframe pass through untouched.
float chartTfSec = timeframe.in_seconds()
bool  mtfValid1  = timeframe.in_seconds(mtfTf1) >= chartTfSec
bool  mtfValid2  = timeframe.in_seconds(mtfTf2) >= chartTfSec
bool  mtfValid3  = timeframe.in_seconds(mtfTf3) >= chartTfSec
bool  mtfValid4  = timeframe.in_seconds(mtfTf4) >= chartTfSec

[mtfTagRaw1, mtfDirRaw1] = mtfBias(m1, f1)
[mtfTagRaw2, mtfDirRaw2] = mtfBias(m2, f2)
[mtfTagRaw3, mtfDirRaw3] = mtfBias(m3, f3)
[mtfTagRaw4, mtfDirRaw4] = mtfBias(m4, f4)

// Invalid (sub-chart) rows collapse to a neutral "— n/a" / dir 0 so they can
// never count toward alignment or divergence; valid rows pass through as-is.
string mtfTag1 = mtfValid1 ? mtfTagRaw1 : "— n/a"
string mtfTag2 = mtfValid2 ? mtfTagRaw2 : "— n/a"
string mtfTag3 = mtfValid3 ? mtfTagRaw3 : "— n/a"
string mtfTag4 = mtfValid4 ? mtfTagRaw4 : "— n/a"
int    mtfDir1 = mtfValid1 ? mtfDirRaw1 : 0
int    mtfDir2 = mtfValid2 ? mtfDirRaw2 : 0
int    mtfDir3 = mtfValid3 ? mtfDirRaw3 : 0
int    mtfDir4 = mtfValid4 ? mtfDirRaw4 : 0

// ── Alignment + divergence detection ─────────────────────────────────────────
// Aligned — every TF agrees on direction (highest-conviction setup).
// Divergence — current chart bias contradicts ≥ 3 of the 4 HTF biases
// (contrarian / counter-trend warning).
bool mtfAlignedBull = mtfDir1 > 0 and mtfDir2 > 0 and mtfDir3 > 0 and mtfDir4 > 0
bool mtfAlignedBear = mtfDir1 < 0 and mtfDir2 < 0 and mtfDir3 < 0 and mtfDir4 < 0
bool mtfAligned     = mtfAlignedBull or mtfAlignedBear
// All four rows below the chart timeframe → nothing valid to align. Report
// "N/A" rather than "MIXED" (which would wrongly imply the TFs disagree).
bool mtfAllInvalid  = not mtfValid1 and not mtfValid2 and not mtfValid3 and not mtfValid4
string mtfHeader    = (mtfAllInvalid  ? "◈ N/A" :
                       mtfAlignedBull ? "▲▲▲▲ ALIGNED" :
                       mtfAlignedBear ? "▼▼▼▼ ALIGNED" :
                                        "◈ MIXED")

int curDir = ((confStrongBull or confWeakBull) ?  1 :
              (confStrongBear or confWeakBear) ? -1 :
                                                  0)
int htfBullCount = (mtfDir1 > 0 ? 1 : 0) + (mtfDir2 > 0 ? 1 : 0) + (mtfDir3 > 0 ? 1 : 0) + (mtfDir4 > 0 ? 1 : 0)
int htfBearCount = (mtfDir1 < 0 ? 1 : 0) + (mtfDir2 < 0 ? 1 : 0) + (mtfDir3 < 0 ? 1 : 0) + (mtfDir4 < 0 ? 1 : 0)
bool mtfDivBull = curDir > 0 and htfBearCount >= 3
bool mtfDivBear = curDir < 0 and htfBullCount >= 3
bool mtfDiv     = mtfDivBull or mtfDivBear

// Transition flags — alerts fire once per state change instead of every bar.
bool justMtfAligned = mtfAligned and not mtfAligned[1]
bool justMtfDiv     = mtfDiv     and not mtfDiv[1]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — PLOTS
// Render every visual layer: midline, momentum line + signal fill, flux
// fills, squeeze column, squeeze release ✦ marker with ▴ / ▾ direction-
// predictor arrows, confluence gauges, trend-shift dots, and confluence
// buy / sell triangles. Plot IDs declared here feed the fill() calls
// further down — order matters.
// ═══════════════════════════════════════════════════════════════════════════════

// ── Hover-label budget ───────────────────────────────────────────────────────
// The Momentum-cross, ✦ Release and Confluence Buy/Sell markers carry their
// hover tooltips via invisible labels, and those fire often. TradingView caps
// the whole script at 500 labels (shared with the Divergence markers), and
// evicts oldest-first across the WHOLE pool — so left unbounded these hover
// labels would crowd out old D▲ D▼ H▲ H▼ markers on long charts.
//
// To let "Show Hover Tooltips" default ON safely, we keep the hover labels in
// a fixed-size FIFO of the most recent HOVER_CAP and delete our own oldest as
// new ones arrive. That hard-bounds hover labels to HOVER_CAP, permanently
// reserving the remaining (500 − HOVER_CAP) of the pool for divergence markers.
// You only ever hover near recent price action, so a rolling window of the
// latest hover markers loses nothing in practice.
int HOVER_CAP = 50
var array<label> hoverLabels = array.new<label>()

// Pass the FIFO in as a parameter (arrays are by-reference, so this mutates
// the same global store) — keeps the function free of any global-reassignment
// ambiguity.
addHoverLabel(array<label> store, label lb) =>
    array.push(store, lb)
    if array.size(store) > HOVER_CAP
        label.delete(array.shift(store))
    lb

// ── Squeeze column colour resolver — tightest active tier wins ───────────────
color sqzColActive = sqz.tight ? sqzColTight : sqz.mid ? sqzColMid : sqzColLoose

// ── Flux fill colour resolver — full saturation for value, brighter for overflow.
color colFluxFill = fluxVal > 0 ? color.new(thBull, 70) : color.new(thBear, 70)
color colFluxOver = fluxOf  > 0 ? color.new(thBull, 40) : color.new(thBear, 40)

// ── Momentum line colour — adaptive, bull when above signal, bear when below
color colMomLine = momVal > momSig ? thBull : thBear
color colMomFill = momVal > momSig ? color.new(thBull, 50) : color.new(thBear, 50)

// ── Confluence gauge colour resolvers ────────────────────────────────────────
// Top gauge — bull side. Full opacity when both mom + flux bullish, half
// opacity when only one bullish, neutral (transparent) otherwise.
color gaugeUpTint = (confStrongBull ? color.new(thBull, 0) :
                     confWeakBull   ? color.new(thBull, 40) :
                                      color.new(thNeutral, 80))

// Bottom gauge — bear side, symmetric.
color gaugeDnTint = (confStrongBear ? color.new(thBear, 0) :
                     confWeakBear   ? color.new(thBear, 40) :
                                      color.new(thNeutral, 80))

bool gaugeShowBull = gaugeMode == "Both" or gaugeMode == "Bull"
bool gaugeShowBear = gaugeMode == "Both" or gaugeMode == "Bear"

// ── Visible midline + hidden anchors ─────────────────────────────────────────
hline(0, "Midline", color.new(thNeutral, 50), hline.style_dashed)

pMomVal = plot(showMom ? momVal : na, "Momentum",      colMomLine, 2, plot.style_line)
pMomSig = plot(showMom ? momSig : na, "Momentum Sig",  color = na, display = display.none)
plot(showFlux ? fluxVal : na, "Flux",      colFluxFill, 1, plot.style_area)
plot(showFlux ? fluxOf  : na, "Flux Over", colFluxOver, 1, plot.style_areabr)

// Momentum / signal ribbon fill — adaptive colour matching the slope.
fill(pMomVal, pMomSig, colMomFill)

// ── Squeeze column on the zero line ──────────────────────────────────────────
// Rendered only when at least one tier (loose or tighter) is active.
// Drawn as a short column hugging the midline: value 1 with histbase = −1
// spans y −1…+1, the classic squeeze-on-zero-line placement.
plot(showSqz and sqz.loose ? 1 : na, "Squeeze", sqzColActive, 1, plot.style_columns, false, -1, display = display.pane)

// ── Squeeze Release ✦ marker (+ Direction Predictor) ─────────────────────────
// Fires on the bar the squeeze fully ended (sqz.loose just dropped to false).
// The ✦ marker is anchored at the midline (y = 0), centred on its bar, in
// the theme's vivid release accent (sqzColRelease — one step brighter / more
// saturated than sqzColTight so the release reads as the climax moment).
//
// The ✦ marker keeps its exact original position (a single-char plotchar
// centred on the bar) so it never drifts. When the Direction Predictor is ON,
// a directional arrow is added BESIDE the marker as a SECOND plotchar offset
// vertically — ▴ just above for a bullish-slope release, ▾ just below for a
// bearish-slope release. Slope within the threshold band prints no arrow
// (direction unclear → plain ✦). Two single-char plotchars render reliably
// where a combined "✦▴" string would not, and the marker stays put.
plotchar(showSqzRelease and sqzReleased ? 0 : na, "Squeeze Release",
     "✦", location.absolute, color.new(sqzColRelease, 0), size = size.tiny)
plotchar(showSqzRelease and sqzPredBull ?  6 : na, "Squeeze Release ▴",
     "▴", location.absolute, color.new(sqzColRelease, 0), size = size.tiny)
plotchar(showSqzRelease and sqzPredBear ? -6 : na, "Squeeze Release ▾",
     "▾", location.absolute, color.new(sqzColRelease, 0), size = size.tiny)

// plotchar() ignores the `tooltip` parameter, so we pair the visible marker
// with an invisible label.style_circle at the midline for rich hover context
// that describes the predicted direction and the next-bar action plan.
if showHoverTips and showSqzRelease and sqzReleased
    string sqzRelDir  = (sqzPredBull ? " ▴ Bullish Predicted" :
                         sqzPredBear ? " ▾ Bearish Predicted" :
                                       "")
    string sqzRelLine = (sqzPredBull  ? "\n\nDirection prediction: BULLISH — momentum slope at release is " + str.tostring(sqzReleaseSlope, "#.##") + " (≥ +" + str.tostring(sqzPredictThresh, "#.#") + ")" :
                         sqzPredBear  ? "\n\nDirection prediction: BEARISH — momentum slope at release is " + str.tostring(sqzReleaseSlope, "#.##") + " (≤ −" + str.tostring(sqzPredictThresh, "#.#") + ")" :
                         sqzPredictOn ? "\n\nDirection prediction: NEUTRAL — momentum slope at release is " + str.tostring(sqzReleaseSlope, "#.##") + " (within ±" + str.tostring(sqzPredictThresh, "#.#") + " — wait for confirmation)" :
                                        "")
    string sqzRelTip  = "Squeeze Release ✦" + sqzRelDir +
         "\nCompression ended this bar — the loosest active squeeze tier (stdev < ATR × the Loose Multiplier, default 1.0) just broke." +
         "\n\nMeaning: volatility expansion incoming. The spring just uncoiled." +
         sqzRelLine +
         "\n\nNext steps:" +
         "\n• Watch the next 1–5 bars for directional breakout" +
         "\n• Confirm with Momentum slope (▲ bull / ▼ bear)" +
         "\n• Cross-check Flux state for trend bias" +
         "\n• Higher-conviction setups: MTF Aligned + Flux confirming direction"
    addHoverLabel(hoverLabels, label.new(bar_index, 0, "", style = label.style_circle, color = color.new(sqzColRelease, 100), size = size.small, tooltip = sqzRelTip))

// ── Confluence gauges ────────────────────────────────────────────────────────
// Each gauge is rendered as two hidden plots (upper + lower y-bound) and
// a fill() between them. The fill colour reflects the live confluence state.
pGaugeBullUp = plot(gaugeShowBull ? +75 : na, "Bull Gauge Up", color = na, display = display.none, editable = false)
pGaugeBullLo = plot(gaugeShowBull ? +70 : na, "Bull Gauge Lo", color = na, display = display.none, editable = false)
pGaugeBearUp = plot(gaugeShowBear ? -70 : na, "Bear Gauge Up", color = na, display = display.none, editable = false)
pGaugeBearLo = plot(gaugeShowBear ? -75 : na, "Bear Gauge Lo", color = na, display = display.none, editable = false)

fill(pGaugeBullLo, pGaugeBullUp, gaugeUpTint, title = "Bull Gauge Fill")
fill(pGaugeBearUp, pGaugeBearLo, gaugeDnTint, title = "Bear Gauge Fill")

// ── Trend Shift dots — momentum × signal crossovers ──────────────────────────
// Dual-layer plot.style_circles for pixel-perfect markers + an invisible
// label.style_circle carrying the rich hover tooltip (plot() does not
// support tooltips). Bull dot on the cross-up bar, bear dot on cross-down.
// Tied to showMom — when the momentum line is hidden the crossover overlay
// hides with it so the pane stays coherent.
plot(showMom and xMomUp ? momSig : na, "Trend Shift Up Glow",   color.new(thBull, 65), 6, plot.style_circles)
plot(showMom and xMomUp ? momSig : na, "Trend Shift Up Core",   color.new(thBull, 0),  2, plot.style_circles)
plot(showMom and xMomDn ? momSig : na, "Trend Shift Dn Glow",   color.new(thBear, 65), 6, plot.style_circles)
plot(showMom and xMomDn ? momSig : na, "Trend Shift Dn Core",   color.new(thBear, 0),  2, plot.style_circles)

if showHoverTips and showMom and xMomUp
    string upTip = "Momentum Cross Up\nMom: " + str.tostring(momVal, "#.##") + "\nSignal: " + str.tostring(momSig, "#.##") + "\nFlux: " + str.tostring(fluxVal, "#.##") + "\nMeaning: Momentum just turned bullish vs. signal — possible long entry or short cover."
    addHoverLabel(hoverLabels, label.new(bar_index, momSig, "", style = label.style_circle, color = color.new(thBull, 100), size = size.small, tooltip = upTip))

if showHoverTips and showMom and xMomDn
    string dnTip = "Momentum Cross Down\nMom: " + str.tostring(momVal, "#.##") + "\nSignal: " + str.tostring(momSig, "#.##") + "\nFlux: " + str.tostring(fluxVal, "#.##") + "\nMeaning: Momentum just turned bearish vs. signal — possible short entry or long exit."
    addHoverLabel(hoverLabels, label.new(bar_index, momSig, "", style = label.style_circle, color = color.new(thBear, 100), size = size.small, tooltip = dnTip))

// ── Confluence buy / sell triangles (outside the gauge bands) ────────────────
// Sell ▼ sits ABOVE the bull gauge (+85, gauge top = +75 + 10 offset),
// Buy ▲ sits BELOW the bear gauge (−90, gauge bottom = −75 − 15 offset).
// Anchoring outside the bands keeps the arrows readable against the
// oscillator line and makes the overbought / oversold context instantly
// obvious. Visibility is tied to the gauge each arrow sits on (Sell rides
// the bull gauge, Buy rides the bear gauge).
//
// plot.style_triangle* / plotshape() ignore the `tooltip` parameter, so
// we pair each visible triangle with an invisible label.style_circle at
// the same coordinates — empty text + fully transparent fill + tooltip
// string. The label captures the hover zone so users get rich on-bar
// context (mom / signal / flux values + threshold + meaning).
plotshape(gaugeShowBull and sellSignal ?  85 : na, "Confluence Sell", shape.triangledown, location.absolute, color.new(thBear, 0), size = size.tiny)
plotshape(gaugeShowBear and buySignal  ? -90 : na, "Confluence Buy",  shape.triangleup,   location.absolute, color.new(thBull, 0), size = size.tiny)

if showHoverTips and gaugeShowBull and sellSignal
    string sellTip = "Confluence Sell ▼\nMom: " + str.tostring(momVal, "#.##") + "\nSignal: " + str.tostring(momSig, "#.##") + "\nFlux: " + str.tostring(fluxVal, "#.##") + "\nThreshold: +" + str.tostring(confThreshActive) + "\nMeaning: Momentum crossed DOWN through its signal while above +" + str.tostring(confThreshActive) + " and Flux is bullish — mean-reversion short trigger inside an uptrend."
    addHoverLabel(hoverLabels, label.new(bar_index, 85, "", style = label.style_circle, color = color.new(thBear, 100), size = size.small, tooltip = sellTip))

if showHoverTips and gaugeShowBear and buySignal
    string buyTip = "Confluence Buy ▲\nMom: " + str.tostring(momVal, "#.##") + "\nSignal: " + str.tostring(momSig, "#.##") + "\nFlux: " + str.tostring(fluxVal, "#.##") + "\nThreshold: −" + str.tostring(confThreshActive) + "\nMeaning: Momentum crossed UP through its signal while below −" + str.tostring(confThreshActive) + " and Flux is bearish — mean-reversion long trigger inside a downtrend."
    addHoverLabel(hoverLabels, label.new(bar_index, -90, "", style = label.style_circle, color = color.new(thBull, 100), size = size.small, tooltip = buyTip))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — BAR COLORING
// Optional chart-wide colouring of every price bar driven by oscillator
// state. Five mutually exclusive modes; "None" emits na so barcolor() is
// a no-op.
// ═══════════════════════════════════════════════════════════════════════════════

color barCol = switch barMode
    "Momentum"   => momVal > 0 ? thBull : thBear
    "Flux"       => fluxVal > 0 ? thBull : thBear
    "Squeeze"    => sqz.loose ? sqzColActive : thNeutral
    "Confluence" => (confStrongBull ? thBull :
                     confStrongBear ? thBear :
                     confWeakBull   ? color.new(thBull, 40) :
                     confWeakBear   ? color.new(thBear, 40) : thNeutral)
    "Slope"      => momVal > momSig ? thBull : thBear
    "None"       => na
    =>              na

barcolor(barCol)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — DASHBOARDS
// Two on-pane tables drawn on the last bar: the main 8- or 9-row Dashboard
// (Bias / TS Score / [Regime] / Momentum / Flux / Squeeze / Confluence /
// Div / Slope — the Regime row appears when the Trend Regime Detector is
// enabled) and the separate 5-row Multi-Timeframe Confluence panel (header
// + four HTF rows). Both use the same theme-adaptive chrome, so they read
// as one coherent product family. Cell values paint in one uniform theme tone
// by default; the "Cell Color Mode → Directional" input instead tints each
// value by its live state (bull / bear / neutral) for at-a-glance reading.
// ═══════════════════════════════════════════════════════════════════════════════

// Directional cell-colour helper — maps a direction code (+1 bull / −1 bear /
// 0 neutral) to the theme's bull / bear / neutral tone. Used only when
// Cell Color Mode = Directional; Uniform mode keeps the single dTx / mtfCAll
// tone. Reads the theme-resolved palette globals (thBull / thBear).
//
// `dirNeutral` darkens the neutral tone on the two light-flip themes (Midnight
// / Graphite), whose dashboards use a light background — there the desaturated
// thNeutral (Graphite's especially) would read too faint. On every other
// (dark-panel) theme it stays thNeutral so it remains theme-cohesive.
color dirNeutral = (themeChoice == "Midnight" or themeChoice == "Graphite") ? color.new(#555555, 0) : thNeutral
dirColor(int dir) =>
    dir > 0 ? thBull : dir < 0 ? thBear : dirNeutral

var table sqzDash = na

if showDash and barstate.islast
    // Light-canvas guard — Midnight and Graphite themes ship with dim
    // thBull / thSignal hues that vanish against a black panel, so for
    // those two palettes the dashboard flips to a light layout with dark
    // theme-bull text. Every other theme keeps the dark chrome.
    bool  dIsLight = themeChoice == "Midnight" or themeChoice == "Graphite"

    color dBgH = dIsLight ? color.new(#F0F0F0, 0)  : color.new(thBull, 90)   // header row — faint theme tint
    color dBgM = dIsLight ? color.new(#FAFAFA, 0)  : color.new(#0f0f0f, 5)   // middle rows — solid dark
    color dBgF = dIsLight ? color.new(#E8E8E8, 0)  : color.new(thBull, 90)   // footer row — faint theme tint
    color dBrd = dIsLight ? color.new(thBull, 40)  : color.new(thBull, 20)   // theme-tinted border

    // Strict colour uniformity — both columns share one full-saturation
    // theme tone (thBull). Direction is conveyed via ▲ ▼ ■ glyphs.
    color dTx = color.new(thBull, 0)

    // Bias classification — derived from confluence state.
    string dBiasLabel = (confStrongBull ? "▲ STRONG BULL" :
                         confStrongBear ? "▼ STRONG BEAR" :
                         confWeakBull   ? "▲ WEAK BULL" :
                         confWeakBear   ? "▼ WEAK BEAR" :
                                          "■ NEUTRAL")

    // Momentum trend arrow vs. previous bar.
    string dMomArrow = momVal > momVal[1] ? "▲" : momVal < momVal[1] ? "▼" : "■"

    // Flux trend arrow vs. previous bar.
    string dFluxArrow = fluxVal > fluxVal[1] ? "▲" : fluxVal < fluxVal[1] ? "▼" : "■"

    // Squeeze tier tag.
    string dSqzLabel = sqz.tight ? "TIGHT" : sqz.mid ? "MID" : sqz.loose ? "LOOSE" : "—"

    // Confluence tag — same hierarchy as Bias but rendered without arrows
    // to give a compact alternate read.
    string dConfLabel = (confStrongBull ? "STRONG BULL" :
                         confStrongBear ? "STRONG BEAR" :
                         confWeakBull   ? "WEAK BULL" :
                         confWeakBear   ? "WEAK BEAR" :
                                          "NONE")

    // Div tag — most recent divergence detected within the last 50 bars.
    string dDivLabel = (na(lastDivBar) or (bar_index - lastDivBar) > 50) ? "—" : lastDivTag

    // Slope tag — momentum above / below signal line.
    string dSlopeLabel = momVal > momSig ? "▲ UP" : momVal < momSig ? "▼ DOWN" : "■ FLAT"

    // Per-row value-cell colours. Uniform mode → one tone (dTx). Directional
    // mode → bull / bear / neutral by each row's live state, so the panel reads
    // by colour at a glance. Squeeze isn't directional, so it tints to its
    // compression accent when active and neutral otherwise. Div follows the
    // DISPLAYED tag (dDivLabel), so a stale "—" reads neutral. Row labels stay
    // in the uniform tone (dTx) for contrast — only the value column is tinted.
    bool  dDir   = dashColorMode == "Directional"
    int   dirBias = confStrongBull or confWeakBull ? 1 : confStrongBear or confWeakBear ? -1 : 0
    int   dirTs   = tsScore >= 60 ? 1 : tsScore <= 40 ? -1 : 0
    int   dirReg  = regimeBullTrend ? 1 : regimeBearTrend ? -1 : 0
    int   dirMom  = momVal > 0 ? 1 : momVal < 0 ? -1 : 0
    int   dirFlux = fluxVal > 0 ? 1 : fluxVal < 0 ? -1 : 0
    int   dirDiv  = str.startswith(dDivLabel, "▲") ? 1 : str.startswith(dDivLabel, "▼") ? -1 : 0
    int   dirSlp  = momVal > momSig ? 1 : momVal < momSig ? -1 : 0
    color cBias  = dDir ? dirColor(dirBias) : dTx
    color cTs    = dDir ? dirColor(dirTs)   : dTx
    color cReg   = dDir ? dirColor(dirReg)  : dTx
    color cMom   = dDir ? dirColor(dirMom)  : dTx
    color cFlux  = dDir ? dirColor(dirFlux) : dTx
    color cSqz   = dDir ? (sqz.loose ? sqzColActive : dirNeutral) : dTx
    color cConf  = dDir ? dirColor(dirBias) : dTx
    color cDiv   = dDir ? dirColor(dirDiv)  : dTx
    color cSlp   = dDir ? dirColor(dirSlp)  : dTx

    // Position resolver — Pine v6 multi-line ternaries inside a local
    // block must be wrapped in parentheses, otherwise the parser treats
    // the newline as a statement terminator and throws CE10156.
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

    // Row layout — the Regime row appears only when the Trend Regime Detector
    // is enabled. When ON the table has 9 rows and Regime sits at row 2 (right
    // under TS Score, as the "market context" summary). When OFF the table
    // collapses back to the original 8-row layout. `rOff` shifts every row
    // below the Regime slot by 1 when the regime row is present.
    int rOff      = regimeOn ? 1 : 0
    int dashRows  = 8 + rOff

    // Build the table ONCE, then overwrite its cells in place on every last-bar
    // tick (the cell calls below run each tick and refresh all live values).
    // Editing any input triggers a full Pine recalc — `var` state resets and
    // sqzDash returns to na — so a fresh table with the correct row count /
    // position / theme is rebuilt automatically when settings change. This
    // avoids deleting + reallocating the whole table on every realtime tick.
    if na(sqzDash)
        sqzDash := table.new(dTPos, 2, dashRows,
             bgcolor      = dBgM,
             border_color = dBrd,
             border_width = 1,
             frame_color  = dBrd,
             frame_width  = 1)

    // Row 0 — Header: brand + live bias tag.
    table.cell(sqzDash, 0, 0, "Artemis Squeeze",
         text_color = dTx, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 0, dBiasLabel,
         text_color = cBias, text_size = dTSize, bgcolor = dBgH,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 1 — TS Score: composite 0–100 trend strength reading (executive summary).
    table.cell(sqzDash, 0, 1, "TS Score",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 1, str.tostring(tsScore, "#") + " " + tsScoreArrow + " " + tsScoreTier,
         text_color = cTs, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2 — Regime (conditional): TRENDING / RANGING / TRANSITION tag.
    if regimeOn
        table.cell(sqzDash, 0, 2, "Regime",
             text_color = dTx, text_size = dTSize, bgcolor = dBgM,
             text_halign = text.align_left,  text_font_family = font.family_monospace)
        table.cell(sqzDash, 1, 2, regimeTag,
             text_color = cReg, text_size = dTSize, bgcolor = dBgM,
             text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2+rOff — Momentum value + arrow.
    table.cell(sqzDash, 0, 2 + rOff, "Momentum",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 2 + rOff, str.tostring(momVal, "#.##") + " " + dMomArrow,
         text_color = cMom, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3+rOff — Flux value + arrow.
    table.cell(sqzDash, 0, 3 + rOff, "Flux",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 3 + rOff, str.tostring(fluxVal, "#.##") + " " + dFluxArrow,
         text_color = cFlux, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4+rOff — Squeeze tier.
    table.cell(sqzDash, 0, 4 + rOff, "Squeeze",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 4 + rOff, dSqzLabel,
         text_color = cSqz, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 5+rOff — Confluence tag.
    table.cell(sqzDash, 0, 5 + rOff, "Confluence",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 5 + rOff, dConfLabel,
         text_color = cConf, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 6+rOff — Last divergence detected within ~50 bars.
    table.cell(sqzDash, 0, 6 + rOff, "Div",
         text_color = dTx, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 6 + rOff, dDivLabel,
         text_color = cDiv, text_size = dTSize, bgcolor = dBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 7+rOff — Footer: slope tag.
    table.cell(sqzDash, 0, 7 + rOff, "Slope",
         text_color = dTx, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(sqzDash, 1, 7 + rOff, dSlopeLabel,
         text_color = cSlp, text_size = dTSize, bgcolor = dBgF,
         text_halign = text.align_right, text_font_family = font.family_monospace)

// ── MTF Confluence panel ─────────────────────────────────────────────────────
// Separate 5-row panel (header + four HTF rows). Header reports the overall
// alignment state (▲▲▲▲ ALIGNED / ▼▼▼▼ ALIGNED / ◈ MIXED); each TF row prints
// its bias tag inside the cell. Direction is conveyed purely by the ▲ / ▼
// glyphs in the tag string — never by cell colour. Uses the same theme-
// adaptive chrome AND the same uniform thBull text colour as the main
// Dashboard so the two panels feel like one product across all thirteen
// themes, light and dark alike.

// MTF text colour — follows the same Cell Color Mode as the main Dashboard so
// the two panels always read as one product.
//   Uniform (default) → every cell paints in thBull; direction is read from the
//   ▲ / ▼ glyphs in the tag string. This is the cohesive single-tone look.
//   Directional → each row's bias tag tints by its own direction, and the
//   header by the overall alignment, for at-a-glance colour reading. The TF
//   labels (left column) stay in the uniform tone for contrast.
bool  dDirMtf = dashColorMode == "Directional"
color mtfCAll = color.new(thBull, 0)
color mtfCol1 = dDirMtf ? dirColor(mtfDir1) : mtfCAll
color mtfCol2 = dDirMtf ? dirColor(mtfDir2) : mtfCAll
color mtfCol3 = dDirMtf ? dirColor(mtfDir3) : mtfCAll
color mtfCol4 = dDirMtf ? dirColor(mtfDir4) : mtfCAll

// Header colour — uniform thBull, or tinted by overall alignment in
// Directional mode (bull / bear / neutral). The ▲▲▲▲ / ▼▼▼▼ glyph cluster
// keeps the direction readable in either mode.
color mtfHeaderCol = dDirMtf ? (mtfAlignedBull ? thBull : mtfAlignedBear ? thBear : dirNeutral) : color.new(thBull, 0)

var table mtfTbl = na

if showMTF and barstate.islast
    // Light-canvas guard — reuses the same Midnight / Graphite check the
    // main dashboard uses, so both panels share chrome on every theme.
    bool  mIsLight = themeChoice == "Midnight" or themeChoice == "Graphite"

    color mBgH = mIsLight ? color.new(#F0F0F0, 0)  : color.new(thBull, 90)
    color mBgM = mIsLight ? color.new(#FAFAFA, 0)  : color.new(#0f0f0f, 5)
    color mBgF = mIsLight ? color.new(#E8E8E8, 0)  : color.new(thBull, 90)
    color mBrd = mIsLight ? color.new(thBull, 40)  : color.new(thBull, 20)

    string mTPos = (mtfPos == "Top Right"    ? position.top_right    :
                    mtfPos == "Top Left"     ? position.top_left     :
                    mtfPos == "Middle Right" ? position.middle_right :
                    mtfPos == "Middle Left"  ? position.middle_left  :
                    mtfPos == "Bottom Right" ? position.bottom_right :
                                               position.bottom_left)

    string mTSize = (mtfSize == "Tiny"   ? size.tiny   :
                     mtfSize == "Small"  ? size.small  :
                     mtfSize == "Normal" ? size.normal :
                                           size.large)

    // Build once, update cells in place each tick — same lifecycle as the main
    // dashboard. Input edits force a full recalc (var mtfTbl → na), so the panel
    // rebuilds with the right position / theme whenever settings change.
    if na(mtfTbl)
        mtfTbl := table.new(mTPos, 2, 5,
             bgcolor      = mBgM,
             border_color = mBrd,
             border_width = 1,
             frame_color  = mBrd,
             frame_width  = 1)

    // Row 0 — Header: "MTF Confluence" + alignment tag.
    table.cell(mtfTbl, 0, 0, "MTF Confluence",
         text_color = mtfHeaderCol, text_size = mTSize, bgcolor = mBgH,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(mtfTbl, 1, 0, mtfHeader,
         text_color = mtfHeaderCol, text_size = mTSize, bgcolor = mBgH,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 1 — Lowest HTF.
    table.cell(mtfTbl, 0, 1, mtfTf1Label,
         text_color = mtfCAll, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(mtfTbl, 1, 1, mtfTag1,
         text_color = mtfCol1, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2.
    table.cell(mtfTbl, 0, 2, mtfTf2Label,
         text_color = mtfCAll, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(mtfTbl, 1, 2, mtfTag2,
         text_color = mtfCol2, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3.
    table.cell(mtfTbl, 0, 3, mtfTf3Label,
         text_color = mtfCAll, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(mtfTbl, 1, 3, mtfTag3,
         text_color = mtfCol3, text_size = mTSize, bgcolor = mBgM,
         text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4 — Highest HTF (footer styling).
    table.cell(mtfTbl, 0, 4, mtfTf4Label,
         text_color = mtfCAll, text_size = mTSize, bgcolor = mBgF,
         text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(mtfTbl, 1, 4, mtfTag4,
         text_color = mtfCol4, text_size = mTSize, bgcolor = mBgF,
         text_halign = text.align_right, text_font_family = font.family_monospace)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — ALERTS
// Twenty-four alert conditions covering every core event. Each fires through
// alert() rather than alertcondition() so the message body can carry extra
// context — direction, current values, and the trigger condition.
// ═══════════════════════════════════════════════════════════════════════════════

if alrtBuy and buySignal
    alert("Artemis Squeeze — Confluence Buy: mom crossed UP through signal below −" + str.tostring(confThreshActive) + " with flux bearish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtSell and sellSignal
    alert("Artemis Squeeze — Confluence Sell: mom crossed DOWN through signal above +" + str.tostring(confThreshActive) + " with flux bullish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtTsTier and tsTierShift
    alert("Artemis Squeeze — TS Score Tier Change: now " + tsScoreTier + " (" + str.tostring(tsScore, "#") + "/100). Composite trend strength shifted tier.", alert.freq_once_per_bar_close)

if alrtMomUp and xMomZUp
    alert("Artemis Squeeze — Momentum Cross Up: mom crossed above zero (current: " + str.tostring(momVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtMomDn and xMomZDn
    alert("Artemis Squeeze — Momentum Cross Down: mom crossed below zero (current: " + str.tostring(momVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtFluxUp and xFluxUp
    alert("Artemis Squeeze — Flux Cross Up: flux crossed above zero (current: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtFluxDn and xFluxDn
    alert("Artemis Squeeze — Flux Cross Down: flux crossed below zero (current: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtSwingUp and xMomUp
    alert("Artemis Squeeze — Bullish Swing: mom crossed above the signal line (current: " + str.tostring(momVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtSwingDn and xMomDn
    alert("Artemis Squeeze — Bearish Swing: mom crossed below the signal line (current: " + str.tostring(momVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtConfBull and justStrongBull
    alert("Artemis Squeeze — Strong Bull Confluence: mom AND flux both turned bullish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtConfBear and justStrongBear
    alert("Artemis Squeeze — Strong Bear Confluence: mom AND flux both turned bearish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtWeakBull and justWeakBull
    alert("Artemis Squeeze — Weak Bull Confluence: momentum turned bullish while flux is not yet bullish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtWeakBear and justWeakBear
    alert("Artemis Squeeze — Weak Bear Confluence: momentum turned bearish while flux is not yet bearish (mom: " + str.tostring(momVal, "#.##") + ", flux: " + str.tostring(fluxVal, "#.##") + ")", alert.freq_once_per_bar_close)

if alrtSqzTight and justSqzTight
    alert("Artemis Squeeze — Tight Squeeze: stdev dropped below ATR × the Tight Multiplier (default 0.5) — extreme compression, expansion imminent.", alert.freq_once_per_bar_close)

if alrtSqzMid and justSqzMid
    alert("Artemis Squeeze — Mid Squeeze: stdev dropped below ATR × the Mid Multiplier (default 0.75) — moderate compression building.", alert.freq_once_per_bar_close)

if alrtSqzLoose and justSqzLoose
    alert("Artemis Squeeze — Loose Squeeze: stdev dropped below ATR × the Loose Multiplier (default 1.0) — mild compression detected.", alert.freq_once_per_bar_close)

if alrtDivReg and dRegBull and sdfPassBull
    alert("Artemis Squeeze — Regular Bullish Divergence (D▲): price made a Lower Low while momentum printed a Higher Low — potential reversal up.", alert.freq_once_per_bar_close)

if alrtDivReg and dRegBear and sdfPassBear
    alert("Artemis Squeeze — Regular Bearish Divergence (D▼): price made a Higher High while momentum printed a Lower High — potential reversal down.", alert.freq_once_per_bar_close)

if alrtDivHid and dHidBull and sdfPassBullHid
    alert("Artemis Squeeze — Hidden Bullish Divergence (H▲): price made a Higher Low while momentum printed a Lower Low — uptrend continuation.", alert.freq_once_per_bar_close)

if alrtDivHid and dHidBear and sdfPassBearHid
    alert("Artemis Squeeze — Hidden Bearish Divergence (H▼): price made a Lower High while momentum printed a Higher High — downtrend continuation.", alert.freq_once_per_bar_close)

if alrtSqzRelease and sqzReleased
    string sqzRelAlertDir = (sqzPredBull ? "✦▴ (Bullish Predicted)" :
                             sqzPredBear ? "✦▾ (Bearish Predicted)" :
                                           "✦")
    string sqzRelAlertSlope = sqzPredictOn ? " Momentum slope at release: " + str.tostring(sqzReleaseSlope, "#.##") + "." : ""
    alert("Artemis Squeeze — Squeeze Release " + sqzRelAlertDir + ": compression fully ended (stdev re-expanded above ATR × the Loose Multiplier, default 1.0). Volatility expansion incoming." + sqzRelAlertSlope + " Confirm direction with Momentum slope and Flux state on the next 1–5 bars.", alert.freq_once_per_bar_close)

if alrtMtfAlign and justMtfAligned
    alert("Artemis Squeeze — MTF Aligned: all four MTF timeframes (" + mtfTf1Label + " / " + mtfTf2Label + " / " + mtfTf3Label + " / " + mtfTf4Label + ") agree on direction (" + (mtfAlignedBull ? "BULL" : "BEAR") + "). Highest-conviction multi-timeframe confluence setup.", alert.freq_once_per_bar_close)

if alrtMtfDiv and justMtfDiv
    alert("Artemis Squeeze — MTF Divergence: current chart bias contradicts the majority of HTF biases. " + (mtfDivBull ? "Current chart bullish but 3+ HTFs bearish — possible counter-trend rally / bull trap." : "Current chart bearish but 3+ HTFs bullish — possible counter-trend dip / bear trap.") + " Treat as contrarian warning.", alert.freq_once_per_bar_close)

if alrtRegime and regimeShift
    alert("Artemis Squeeze — Regime Shift: market entered " + regimeTag + " (ADX " + str.tostring(regimeAdx, "#.#") + ", DI+ " + str.tostring(regimeDiPlus, "#.#") + ", DI− " + str.tostring(regimeDiMinus, "#.#") + "). Strategy guidance: " + (regimeTrending ? "trend-following / continuation bias." : regimeRanging ? "mean-reversion / range-trade bias." : "low-confidence transitional state — wait for clearer regime."), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════════
````

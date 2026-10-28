# Trend Channel Navigator [MQLSoftware]

- url: https://www.tradingview.com/script/Afoc3VqN-Trend-Channel-Navigator-MQLSoftware/
- type: indicator
- pine_id: PUB;f23f28d0bace4d30a83799b30790d23b
- version: 1.0

## Description

Trend Channel Navigator maps price action as a chain of trend phases, each drawn as its own channel: phase boundaries come from an adaptive swing scanner whose window breathes with the volatility regime, each channel side sits at a quantile of its own deviations instead of a symmetric envelope, a recency-weighted regression tracks the momentum slice inside the active phase, and an original Navigator Entry Score condenses channel position, momentum quality and higher-timeframe agreement into a single 0-100 confluence read - shown live on the panel together with its full component breakdown.

This is a visual analytical tool for chart reading and market-structure context. It does not execute trades and does not provide financial advice.

[b]Key Features[/b]
[list]
[*]Adaptive phase detection: the swing window scales with the volatility regime, so phases are recognized sooner in a heating market and noise swings are ignored in quiet tape
[*]Asymmetric quantile channels: each side's width is a percentile of that side's own deviations, so one spike no longer inflates the whole envelope and the top and bottom bands are independent
[*]Recency-weighted Micro regression: the newest bars dominate the fit, so the momentum read turns earlier than a uniform regression; a weighted R-squared gate hides it when the fit is poor
[*]Navigator Entry Score: a 0-100 confluence read built from four weighted components - macro/micro alignment, channel position, regression fit quality and dual-timeframe agreement
[*]Live Score Breakdown on the panel: every component's points are shown next to its budget, so the number is never a black box
[*]Scored markers: every structural event (BREAK, PULLBACK, CONTINUATION) prints the matching side of the live score and passes a configurable minimum, and the dedicated ENTRY marker fires when the score crosses your threshold
[*]Pullback Zone and Quarter Grid: the favorable quarter of the active channel is shaded and faint quarter lines make Channel Position readable on the chart itself
[*]Self-explanatory chart language: markers and labels are written in plain words, every marker and pivot carries an explanatory tooltip, and a Compact mode switches to short codes
[*]Non-Repaint Mode on by default: markers fire only on confirmed bars and the active structure is built from closed-bar data
[/list]

[b]Core Concept[/b]

Most channel tools on TradingView take one of two approaches. They fit a single regression channel over the latest N bars, or they draw one channel from manually chosen anchors. Both force all recent history into one line fit, so the chart cannot show where one trend phase ended and the next began.

Trend Channel Navigator treats price as a sequence of structural phases. The phase idea started in our earlier open-source script Anchored Trend Channels; Navigator rebuilds the engine around five mechanisms of its own - the detection, the channel geometry, the momentum fit, the score and its on-chart language all differ from that script.

[b]1. Adaptive phase detection.[/b] Swings are found by a strict-extremum scan whose window is re-derived on every bar from the volatility regime - the ratio of short-term ATR to its long baseline. When the market heats up the window contracts and new phases are recognized sooner; in quiet tape it dilates and noise swings never become phases. Builtin pivot functions take a fixed window, which is why the scanner is written by hand. A swing is confirmed a window's worth of bars after it forms, exactly like a classic pivot. When a later swing confirms beyond a phase's endpoint in the same direction - a higher high in an up-phase, a lower low in a down-phase - the phase extends to that new confirmed swing instead of leaving an orphan stretch, so the chain of channels stays continuous.

[b]2. Asymmetric quantile channels.[/b] The channel basis is the straight line between the two anchoring swings, which keeps clean joints between phases. The width is not a symmetric envelope: highs above the basis set the top band and lows below it set the bottom band, each at a configurable percentile of its own deviations with an ATR floor. A single spike no longer inflates the whole channel, and a phase that leans on one side of its basis shows that lean honestly.

[b]3. Recency-weighted Micro regression.[/b] The inner channel is a weighted least-squares fit in which each bar back weighs a fixed fraction of the previous one, so the newest bars dominate and the momentum read turns earlier than a uniform regression of the same length. The fit quality gate and the residual band use the same weights. Setting the decay to 1.00 reproduces the classic unweighted fit.

[b]4. Navigator Entry Score with a live breakdown.[/b] The score is computed independently for the long side and the short side on every bar. Macro and micro direction agreement contributes 35 points, channel position contributes up to 20 and rewards proximity to the favorable edge rather than chasing the far edge, the micro fit quality contributes up to 20, and each of the two higher-timeframe rows contributes 12.5 when it agrees with the side being scored. The panel shows each component's points next to its budget on every bar, so the number is never a black box. An ENTRY marker fires once when the winning side crosses the threshold on a confirmed bar, with its own cooldown; an optional strict mode caps the score below the threshold unless both higher timeframes agree. The other marker families pass through the same score: BREAK, PULLBACK and CONTINUATION print the matching side's value and respect a configurable minimum, so every event on the chart is a scored event.

[b]5. Pullback Zone and Quarter Grid.[/b] The score's channel-position component is made visible: the favorable quarter of the active channel is shaded - near the base in an up phase, near the top in a down phase - and faint quarter lines split the channel into the quarters the Channel Position row reads. The channel does not only show where price has been; it shows where the next trend-side read matters.

[b]Anatomy of the Display[/b]
[b]Macro channels[/b] are the large structures between confirmed swing points. Historical phases are dimmed and frozen; the active phase is bright, carries the shaded Pullback Zone, and extends forward with a dashed projection.

[b]The Micro channel[/b] is the smaller regression channel inside the active phase, labelled "Momentum" with its current direction. It shows whether the current momentum slice agrees with the larger phase or is pulling back against it.

[b]Markers[/b] name their event in plain words and print the matching side of the live score. BREAK marks a confirmed close beyond the active channel boundary, PULLBACK marks a touch of the favorable edge in trend direction, CONTINUATION marks a micro breakout aligned with the macro phase early in the segment, and ENTRY belongs to the score engine and fires on a threshold cross. Every marker carries a tooltip that explains the event.

[b]The status badge[/b] shows the Trend Bias of the recent phases and the live Entry Score with its stronger side.

[b]The panel[/b] is the main readout: Trend Bias, active segment angle, direction and age, the chain of recent phases, Channel Position, anchor pivot, channel width in ATR, the last fired event, micro regression metrics, the two higher-timeframe rows, and the live Entry Score against your threshold - followed by the Score Breakdown, where each of the four components shows its current points against its budget.

[b]Multi-Timeframe Panel[/b]
The two higher-timeframe rows are selected automatically from a standard ladder based on the chart timeframe, for example 240 and 1D on a 1-hour chart. Higher-timeframe values are requested without lookahead and read with a one-bar offset, so only closed higher-timeframe bars are used. Their agreement is not only displayed - it feeds the Entry Score directly.

[b]Notes on Repainting[/b]
[list]
[*][b]Historical channels do not repaint intrabar.[/b] They are anchored to confirmed swings, and one honest exception is stated openly: when a same-direction swing confirms beyond a phase's endpoint, the completed channel extends to that new confirmed swing and its width is recomputed - on closed data only, at confirmation time. It never moves otherwise.
[*][b]Swing detection carries an inherent delay[/b] equal to the current window: a swing becomes visible only after that many bars close past it. With the Adaptive default the window typically resolves to 11-26 bars, tighter in heating markets. This confirmation contract is the same as for all pivot-based tools.
[*][b]Non-Repaint Mode is on by default:[/b] the active channel and the micro regression are computed from closed-bar data, so the visible structure does not wobble intrabar. Turning it off lets the active structure update on the live bar for responsiveness; this affects display only.
[*][b]All markers are gated by confirmed bars.[/b] ENTRY, BREAK, PULLBACK and CONTINUATION can only appear on the close of their bar and cannot appear or vanish intrabar.
[*][b]Higher-timeframe rows[/b] use the standard non-repainting pattern: no lookahead, one-bar offset, closed bars only.
[*][b]The panel and the live score update within the bar.[/b] This is display only; no marker or alert is created from an unconfirmed bar.
[/list]

[b]Typical Analysis Workflow[/b]
A common analytical workflow may include:
[list=1]
[*]Reading Trend Bias and the active phase direction first to understand the current structure
[*]Checking Channel Position to see whether price is near the favorable edge or already stretched toward the far edge
[*]Waiting for price to reach the shaded Pullback Zone in the direction of the active phase
[*]Using the Momentum channel and its fit quality to judge whether the current slice is clean enough to trust
[*]Checking the higher-timeframe rows for agreement
[*]Treating the Entry Score as the final confluence read rather than a standalone trade command, and raising the threshold when you want fewer, higher-confluence marks
[/list]

[b]Configuration[/b]
[b]Pivot Sensitivity[/b] - Adaptive (default) scales the swing window with the volatility regime; the fixed presets from Short to Very Long and Custom Lookback pin it instead.
[b]Min Segment Size (x ATR) / Min Segment Length (bars)[/b] - quality filters that skip noise phases.
[b]Channel Width Multiplier / Min Band Width (x ATR)[/b] - how tightly the channel wraps price and the floor under each side's width.
[b]Channel Quantile (%)[/b] - the percentile each side's width sits at. 100 reproduces a full envelope; lower values ignore single spikes and hug price tighter.
[b]Max Segments Stored[/b] - how many historical phases stay on the chart.
[b]Regression Length / Std Dev Multiplier / Min R2 to Show[/b] - the Micro channel window, its band width and its fit gate.
[b]Recency Weight (decay)[/b] - how strongly the newest bars dominate the Micro fit. 1.00 = classic unweighted regression.
[b]Segment Break / Macro Pullback / Micro Continuation Signals[/b] - enable each marker family independently. [b]Signal Cooldown[/b] - minimum bars between same-family markers.
[b]Min Signal Score[/b] - structural markers only fire when the matching side of the live score is at least this value. 0 = raw structural events.
[b]Entry Score Threshold[/b] - the confluence level an ENTRY marker requires. [b]Require MTF Confluence[/b] - strict mode: both higher timeframes must agree for the score to reach the threshold. [b]Entry Cooldown[/b] - minimum bars between ENTRY markers.
[b]Non-Repaint Mode[/b] - closed-bar data for the active structure (default on).
[b]Line Width / Neon Glow[/b] - core line width and the layered glow tier (Off, Subtle, Balanced, Bright).
[b]Show Channel Fills / Show Basis / Show MTF Mini-Screener[/b] - display toggles.
[b]Marker Style[/b] - Descriptive markers in plain words, or Compact short codes.
[b]Highlight Pullback Zone / Show Quarter Grid[/b] - the shaded favorable quarter of the active channel and the faint quarter lines.
[b]Bull / Bear Colors[/b] - recolor the whole structure. Defaults are a dark-theme identity; pick deeper tones for light charts.

[b]Markets and Timeframes[/b]
The indicator can be applied across multiple markets and timeframes:
[list]
[*]Forex
[*]Stocks and Indices
[*]Commodities
[*]Cryptocurrencies
[/list]
Channel widths and segment filters are scaled in ATR rather than in fixed price units, so behaviour stays consistent across instruments. Defaults are tuned for 1H-4H charts; Pivot Sensitivity is the lever for faster or slower timeframes.

[b]Alerts[/b]
[list]
[*]Segment Direction Changed - the active phase flipped direction
[*]Segment Break - a confirmed close beyond the active channel boundary
[*]Micro Continuation - a micro breakout aligned with the macro phase
[*]Entry Score - the score crossed your threshold on a confirmed bar
[/list]
All alerts evaluate on confirmed bars and respect the same cooldowns and score gates as the chart markers, so an alert fires only when the corresponding marker event fires.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MQLSoftware

// =============================================================================
// TREND CHANNEL NAVIGATOR [MQLSoftware]
// =============================================================================
// A phase-channel system: each stretch of price action between confirmed swing
// points is drawn as its own parallel trend channel. Five authored mechanisms:
//   1. ADAPTIVE PHASE DETECTION — a hand-rolled strict-extremum scanner whose
//      window scales with the volatility regime (ATR14 vs ATR100); builtin
//      pivot functions cannot adapt per bar.
//   2. ASYMMETRIC QUANTILE CHANNEL — each side's width is a percentile of that
//      side's own deviations from the pivot-to-pivot basis, so one spike no
//      longer inflates the whole envelope and the two sides are independent.
//   3. RECENCY-WEIGHTED MICRO REGRESSION — bars weighted by decay^age, so the
//      momentum read turns earlier than a uniform fit; weighted R² gates it.
//   4. NAVIGATOR ENTRY SCORE — a 0-100 confluence read (alignment 35 / channel
//      position 20 / fit quality 20 / dual-TF agreement 25) computed per side;
//      crossing the threshold fires a dedicated ENTRY marker, and ALL
//      structural markers are score-gated and print their score.
//   5. PULLBACK ZONE + QUARTER GRID — the favorable quarter of the active
//      channel is shaded (the exact area the position component rewards) and
//      quarter lines make Channel Position readable on the chart itself.
// Plus a navigator panel with a live Score Breakdown (per-component points),
// Neon Glow tiers, and a self-explanatory marker language (BREAK / PULLBACK /
// CONTINUATION / ENTRY with the live score) — reads without a manual.
//
// Author:  MQLSoftware
// License: Mozilla Public License 2.0
// =============================================================================

// =============================================================================
// REPAINTING TRANSPARENCY (Pine Coders standard disclosure):
//
// 1. HISTORICAL SEGMENTS (frozen, dimmed): DO NOT repaint intrabar.
//    Built from the adaptive strict-extremum scanner: a pivot is only
//    confirmed pivot_lb bars after its formation (same confirmation contract
//    as classic pivots), so historical pivots cannot move retroactively.
//    ONE honest exception: when a same-direction swing confirms beyond the
//    phase's endpoint (higher high in an up-phase / lower low in a down-phase)
//    the completed segment EXTENDS to that new confirmed swing and its metrics
//    are recomputed — on closed data only, at confirmation time. It never
//    moves otherwise. A freshness guard rejects re-detections of old swings
//    when the adaptive window changes.
//
// 2. ACTIVE SEGMENT (bright, glowing, with right-extending dashed projection):
//    - Non-Repaint Mode ON (default): uses close[1] for end-of-segment calc,
//      so the active channel only updates on bar close. Stable visualization.
//    - Non-Repaint Mode OFF: live update on every tick — visually smoother but
//      the active channel "wobbles" intra-bar. Use only if you want max
//      responsiveness and accept the visual jitter.
//
// 3. PIVOT DETECTION DELAY: pivots become visible pivot_lb bars after they
//    actually formed (the Adaptive default typically resolves to 11-26 bars,
//    tighter in heating markets). This is an inherent property of all
//    pivot-based indicators including TradingView's own built-ins.
//
// 4. SIGNALS (PB/BRK/CONT/ENTRY) are gated by barstate.isconfirmed — they fire
//    ONLY once per closed bar and never intra-bar. Safe to use with "Once Per
//    Bar" alert frequency. The Entry Score itself is a continuous read (like
//    an oscillator) and is not repaint-sensitive by nature — only the marker
//    that fires when it crosses the threshold is confirmed-bar gated.
//
// 5. MTF data (240/1D in panel) uses lookahead=barmerge.lookahead_off + [1]
//    offset on every series — strictly non-repainting HTF reads.
// =============================================================================
//@version=6
indicator("Trend Channel Navigator [MQLSoftware]", shorttitle="MQLSoftware - Trend Channel Navigator",
     overlay=true,
     max_lines_count=500,
     max_labels_count=100,
     max_boxes_count=50,
     max_bars_back=5000)

// ============================================================================
// SECTION 0 — DESIGN TOKENS (Neon Grid — exclusive to Navigator)
//   Deliberately NOT the teal/coral "Neo Slate" tokens used elsewhere in the
//   product line — and NOT the house cyan either (cyan bull is the free-line
//   identity: HTF, Auto Trendlines, Anchored Channels, PRL). Navigator owns
//   the one axis no other MQLSoftware product uses: acid lime vs. hot magenta,
//   a synthwave-terminal identity. Bonus: green=bull is the only color
//   semantic a cold viewer reads with zero learning.
// ============================================================================

// NEO_BULL / NEO_BEAR are user-configurable inputs (end of the Visual group) —
// every structural element here is a drawing (line/label/linefill), and the
// TradingView Style tab cannot recolor drawings, so without inputs the palette
// would be locked. Defaults = the Neon Grid identity below.
color NEO_BULL_ACCENT = color.rgb(208, 255, 128)  // pale lime — bull micro accent
color NEO_BEAR_ACCENT = color.rgb(255, 110, 190)  // orchid-pink — bear micro accent
color NEO_SIGNAL      = color.rgb(255, 205,  40)  // electric gold — neutral/score signal
color NEO_ENTRY       = color.rgb(178, 120, 255)  // violet — Entry Score marker (unique to this engine)
color NEO_WHITE       = color.rgb(230, 236, 248)
color NEO_INK         = color.rgb( 10,  14,   6)  // near-black ink for text on bright lime/gold fills
color NEO_LABEL       = color.rgb(168, 178, 205)
color NEO_DIM         = color.rgb(120, 128, 152)
color NEO_SEC         = color.rgb( 84,  92, 118)

color NEO_PANEL_BG    = color.new(color.rgb( 10,   8,  20),  4)  // violet-black, not blue-black
color NEO_PANEL_ROW    = color.new(color.rgb( 18,  14,  32),  6)
color NEO_PANEL_SEP    = color.new(color.rgb( 36,  24,  58), 10)

// ============================================================================
// SECTION 1 — INPUTS
// ============================================================================

string grp_quick   = "Quick Setup"
string grp_macro   = "Phase Engine (Macro)"
string grp_micro   = "Momentum Engine (Micro)"
string grp_signals = "Signals"
string grp_entry   = "Entry Score (Navigator Algorithm)"
string grp_visual  = "Visual"
string grp_alerts  = "Alerts"

bool show_macro_inp    = input.bool(true,  "Show Macro Segments",     group=grp_quick)
bool show_micro_inp    = input.bool(true,  "Show Micro Channel",      group=grp_quick)
bool show_panel_inp    = input.bool(true,  "Show Panel",              group=grp_quick)
bool show_status_inp   = input.bool(true,  "Show Status Badge",       group=grp_quick)
bool show_endlbls_inp  = input.bool(true,  "Show Endpoint Labels",    group=grp_quick)
bool show_pivots_inp   = input.bool(true,  "Show Pivot Markers",      group=grp_quick)
bool show_signals_inp  = input.bool(true,  "Show Signal Markers",     group=grp_quick)
bool show_entry_inp    = input.bool(true,  "Show Entry Score Markers", group=grp_quick)

// === REPAINTING BEHAVIOR ===
bool non_repaint_inp = input.bool(true, "Non-Repaint Mode",
     group=grp_quick,
     tooltip="ON: active channel and signals use closed-bar data only (no intra-bar flicker). OFF: live tick updates (responsive but jittery). Historical channels never repaint.")

string lookback_mode_inp = input.string("Adaptive", "Pivot Sensitivity",
     options=["Adaptive", "Short", "Medium", "Long", "Very Long"], group=grp_macro,
     tooltip="Adaptive (default) scales the pivot window with the volatility regime: detection speeds up when the market heats and slows in quiet tape. Fixed presets: Short = many short phases, Very Long = few clean trends.")
int    fixed_lookback_inp = input.int(20, "Custom Lookback (if enabled)",
     minval=3, maxval=50, group=grp_macro)
bool   use_custom_lb_inp  = input.bool(false, "Use Custom Lookback",
     group=grp_macro)
float  min_seg_atr_inp    = input.float(2.5, "Min Segment Size (× ATR)",
     minval=0.0, maxval=10.0, step=0.1, group=grp_macro,
     tooltip="Skip pivots that don't move price by at least this many ATRs. Higher = cleaner chart with fewer segments.")
int    min_seg_bars_inp   = input.int(8, "Min Segment Length (bars)",
     minval=2, maxval=50, group=grp_macro,
     tooltip="Skip segments shorter than this many bars.")
float  band_dev_mult_inp  = input.float(1.1, "Channel Width Multiplier",
     minval=0.5, maxval=3.0, step=0.05, group=grp_macro,
     tooltip="Multiplier on max bar deviation. 1.0 = price barely fits, 1.2+ = some breathing room.")
float  min_band_atr_inp   = input.float(1.0, "Min Band Width (× ATR)",
     minval=0.0, maxval=3.0, step=0.1, group=grp_macro,
     tooltip="Minimum channel half-width as ATR multiple. Prevents razor-thin channels.")
float  band_q_inp         = input.float(90.0, "Channel Quantile (%)",
     minval=70.0, maxval=100.0, step=1.0, group=grp_macro,
     tooltip="Each side of the channel sits at this percentile of that side's own deviations: highs above the basis set the top band, lows below it set the bottom band. 100 = classic full envelope; lower values ignore single spikes and hug price tighter. The two sides are independent, so the channel is asymmetric.")
int    max_segments_inp   = input.int(15, "Max Segments Stored",
     minval=3, maxval=50, group=grp_macro,
     tooltip="Maximum historical segments to keep (older are removed FIFO)")

int   micro_lr_len_inp  = input.int(20,    "Regression Length",
     minval=10, maxval=100, group=grp_micro)
float micro_dev_mult_inp = input.float(2.0, "Std Dev Multiplier",
     minval=0.5, maxval=5.0, step=0.1, group=grp_micro)
float micro_r2_min_inp   = input.float(0.20, "Min R² to Show",
     minval=0.0, maxval=1.0, step=0.05, group=grp_micro,
     tooltip="Hide Micro channel when fit quality is below this threshold")
float micro_decay_inp    = input.float(0.94, "Recency Weight (decay)",
     minval=0.80, maxval=1.00, step=0.01, group=grp_micro,
     tooltip="Per-bar weight decay of the regression: each bar back weighs decay x the previous one, so the newest bars dominate the fit and turns are caught earlier than a uniform regression of the same length. 1.00 = classic unweighted fit.")

bool sig_segbreak_inp    = input.bool(true, "Segment Break Signals",  group=grp_signals,
     tooltip="Price closes beyond active segment boundary")
bool sig_pullback_inp    = input.bool(true, "Macro Pullback Signals", group=grp_signals,
     tooltip="Price touches Macro band in segment direction")
bool sig_microbreak_inp  = input.bool(true, "Micro Continuation",     group=grp_signals,
     tooltip="Micro breakout aligned with Macro segment direction")
int  signal_cooldown_inp = input.int(15, "Signal Cooldown (bars)",
     minval=0, maxval=50, group=grp_signals,
     tooltip="Minimum bars between consecutive same-type signals.")
int  min_sig_score_inp   = input.int(40, "Min Signal Score",
     minval=0, maxval=90, group=grp_signals,
     tooltip="Structural markers (Break / Pullback / Continuation) fire only when the matching side of the live Entry Score is at least this value, and every marker prints that score. 0 = raw structural events without the confluence filter.")

// === NAVIGATOR ENTRY SCORE — unique confluence algorithm ===
// Fuses 4 independent reads (Macro/Micro alignment, Channel Position pullback
// proximity, Micro R² fit quality, dual-timeframe MTF agreement) into one
// 0-100 score. Not present in any other MQLSoftware channel product.
int   entry_threshold_inp = input.int(75, "Entry Score Threshold",
     minval=40, maxval=95, group=grp_entry,
     tooltip="Fire an ENTRY marker when the confluence score crosses this level (0-100). Higher = fewer, higher-confluence entries.")
bool  entry_require_mtf_inp = input.bool(false, "Require MTF Confluence",
     group=grp_entry,
     tooltip="ON: both MTF timeframes must agree with the Macro direction for the score to reach the top tier. Stricter, fewer signals.")
int   entry_cooldown_inp = input.int(20, "Entry Cooldown (bars)",
     minval=0, maxval=80, group=grp_entry,
     tooltip="Minimum bars between consecutive Entry Score markers (independent of the other signal cooldowns).")

int  line_width_inp      = input.int(2, "Line Width (Core)",  minval=1, maxval=4, group=grp_visual)
string neon_glow_inp     = input.string("Subtle", "Neon Glow",
     options=["Off", "Subtle", "Balanced", "Bright"], group=grp_visual,
     tooltip="Controls layered-line glow width. Off keeps only the core line. Subtle (default) reads as a soft neon edge, not a blur — raise to Balanced/Bright for a louder look.")
bool show_fill_inp       = input.bool(true, "Show Channel Fills", group=grp_visual)
bool show_basis_inp      = input.bool(true, "Show Basis (dashed center)", group=grp_visual)
bool show_mtf_inp        = input.bool(true, "Show MTF Mini-Screener", group=grp_visual)
string marker_style_inp  = input.string("Descriptive", "Marker Style",
     options=["Descriptive", "Compact"], group=grp_visual,
     tooltip="Descriptive: markers spell out the event (BREAK ▲, PULLBACK ▲, ◆ ENTRY 82/100) — the chart reads without a manual. Compact: short codes (BRK↑, PB↑, CONT↑) for minimal footprint.")
bool show_zone_inp       = input.bool(true, "Highlight Pullback Zone", group=grp_visual,
     tooltip="Shade the favorable quarter of the active channel — the exact area the Entry Score's Channel Position component rewards: near the base in an up segment, near the top in a down segment.")
bool show_grid_inp       = input.bool(true, "Show Quarter Grid", group=grp_visual,
     tooltip="Faint dotted lines at 25% and 75% of the active channel. Together with the basis they split the channel into the quarters the Channel Position row reads; the favorable quarter is the shaded Pullback Zone.")
color NEO_BULL           = input.color(color.rgb(158, 255,  40), "Bull / Bear Colors", group=grp_visual, inline="neocol")
color NEO_BEAR           = input.color(color.rgb(255,  42, 128), "", group=grp_visual, inline="neocol",
     tooltip="Channel and structure colors. Defaults are the dark-theme Neon Grid identity (acid lime / hot magenta). On light charts pick deeper tones, e.g. dark green / crimson.")

bool alert_segchange_inp = input.bool(false, "Alert on Segment Change",    group=grp_alerts)
bool alert_segbreak_inp  = input.bool(false, "Alert on Segment Break",     group=grp_alerts)
bool alert_microbreak_inp = input.bool(false, "Alert on Micro Continuation", group=grp_alerts)
bool alert_entry_inp     = input.bool(false, "Alert on Entry Score", group=grp_alerts)

// Glow scale kept deliberately restrained (max +3px) — a thin neon edge, not a
// thick highlighter block. Transparency is layered on top so it reads as a
// soft halo rather than aliased blur at any chart zoom level.
int GLOW_BONUS = neon_glow_inp == "Off" ? 0 : neon_glow_inp == "Subtle" ? 1 : neon_glow_inp == "Bright" ? 3 : 2
int glow_width = line_width_inp + GLOW_BONUS
bool glow_enabled = GLOW_BONUS > 0

// ============================================================================
// SECTION 2 — MARKET DATA
// ============================================================================

float atr14  = ta.atr(14)
float atr100 = ta.atr(100)
float anchor_high_20 = ta.highest(high, 20)

// ============================================================================
// SECTION 3 — ADAPTIVE PHASE DETECTION (Navigator engine)
//   The pivot window scales with the volatility regime: when short-term ATR
//   expands against its long baseline the window contracts, so new phases are
//   recognized sooner in a heating market; in quiet tape it dilates and
//   ignores noise swings. Detection is a hand-rolled strict-extremum scan —
//   that is what allows a bar-by-bar (series) window, which the builtin pivot
//   functions cannot do. A pivot is confirmed `pivot_lb` bars after its bar,
//   exactly like classic pivots, and once confirmed it never moves.
// ============================================================================

int preset_lb = lookback_mode_inp == "Short" ? 5 : lookback_mode_inp == "Medium" ? 10 : lookback_mode_inp == "Long" ? 18 : lookback_mode_inp == "Very Long" ? 30 : 18
// Volatility regime: >1 = heating, <1 = quiet. ATRs are smooth, so the
// adaptive window drifts slowly rather than jumping bar to bar.
float vol_regime  = atr100 > 0 ? atr14 / atr100 : 1.0
int   adaptive_lb = int(math.round(18.0 / math.max(0.70, math.min(1.60, nz(vol_regime, 1.0)))))
int   pivot_lb    = use_custom_lb_inp ? fixed_lookback_inp : lookback_mode_inp == "Adaptive" ? adaptive_lb : preset_lb

// Strict-extremum scan over the [0 .. 2*lb] window; candidate = bar `lb` back.
// Older bars must be strictly beyond the candidate, newer bars at-or-beyond —
// ties resolve to the earliest bar, so one flat swing yields exactly one pivot.
f_scan_pivot(int lb) =>
    float ph = na
    float pl = na
    if bar_index >= 2 * lb and lb > 0
        float ch = high[lb]
        float cl = low[lb]
        bool okH = true
        bool okL = true
        for i = 0 to 2 * lb
            if i != lb
                if i > lb
                    okH := okH and high[i] < ch
                    okL := okL and low[i]  > cl
                else
                    okH := okH and high[i] <= ch
                    okL := okL and low[i]  >= cl
        ph := okH ? ch : na
        pl := okL ? cl : na
    [ph, pl]

[pivot_high_now, pivot_low_now] = f_scan_pivot(pivot_lb)

bool new_ph = not na(pivot_high_now)
bool new_pl = not na(pivot_low_now)

// ============================================================================
// SECTION 4 — SEGMENT MANAGEMENT
//   A segment = bars between two consecutive pivots (HL→PH = up, PH→PL = down)
//   For each segment we store:
//     - start_bar / start_price / end_bar / end_price (pivot anchors)
//     - slope / intercept (regression on bars in segment)
//     - stdev (residual)
//     - direction (1 = up, -1 = down)
//     - drawing handles (lines, fill box, pivot label)
// ============================================================================

// Per-segment data parallel arrays (Pine v6 doesn't allow array<UDT> easily for graphics)
var array<int>   seg_start_bar    = array.new<int>()
var array<float> seg_start_price  = array.new<float>()
var array<int>   seg_end_bar      = array.new<int>()
var array<float> seg_end_price    = array.new<float>()
var array<float> seg_slope        = array.new<float>()
var array<float> seg_intercept    = array.new<float>()
var array<float> seg_updev        = array.new<float>()
var array<float> seg_dndev        = array.new<float>()
var array<int>   seg_direction    = array.new<int>()
var array<float> seg_angle        = array.new<float>()

// Drawing handles per segment — classic parallel channel: upper + lower (each glow + core)
var array<line>  seg_upper_glow   = array.new<line>()
var array<line>  seg_upper_core   = array.new<line>()
var array<line>  seg_lower_glow   = array.new<line>()
var array<line>  seg_lower_core   = array.new<line>()
var array<line>  seg_basis        = array.new<line>()
var array<linefill> seg_fill      = array.new<linefill>()
var array<label> seg_pivot_lbl    = array.new<label>()

// Last confirmed pivot for "open segment" tracking
var int   last_pivot_bar    = na
var float last_pivot_price  = na
var int   last_pivot_type   = 0  // 1 = was PH, -1 = was PL

// ----- Pivot-anchored segment metrics (asymmetric quantile envelope) -----
// Basis = straight line from start_pivot to end_pivot (forces clean joints
// between phases). Each side's width is the chosen percentile of THAT side's
// own deviations: highs above the basis set the top band, lows below it set
// the bottom band. Unlike a symmetric max-envelope, a single spike no longer
// inflates the whole channel, and the two sides are independent.
// Returns [slope, intercept, up_dev, dn_dev, angle_deg]
//   basis(x) = intercept + slope * x   where x = position in segment from start
f_segment_metrics(int start_bar_param, float start_price_param, int end_bar_param, float end_price_param) =>
    int len = end_bar_param - start_bar_param + 1
    float _slope = 0.0
    float _intercept = start_price_param
    float _updev = 0.0
    float _dndev = 0.0
    float _angle = 0.0
    if len >= 2
        // Slope = (end - start) / bars_between
        _slope := (end_price_param - start_price_param) / (end_bar_param - start_bar_param)
        _intercept := start_price_param  // at x=0 (segment start), basis = start_price
        // Collect per-side deviations of sampled bars from the basis line.
        // SAMPLING: limit iterations to MAX_SAMPLES so we don't request beyond historical buffer.
        int MAX_SAMPLES = 500
        int step = math.max(1, math.ceil(len / float(MAX_SAMPLES)))
        array<float> devs_up = array.new<float>()
        array<float> devs_dn = array.new<float>()
        for i = 0 to len - 1 by step
            int bar_i = start_bar_param + i
            int age   = bar_index - bar_i
            // Guard: never request data beyond what Pine guarantees (max_bars_back minus headroom)
            if age >= 0 and age < 4900
                float yh = high[age]
                float yl = low[age]
                if not na(yh) and not na(yl)
                    float x = i
                    float basis_y = _intercept + _slope * x
                    array.push(devs_up, math.max(0.0, yh - basis_y))
                    array.push(devs_dn, math.max(0.0, basis_y - yl))
        if array.size(devs_up) > 0
            _updev := array.percentile_linear_interpolation(devs_up, band_q_inp)
            _dndev := array.percentile_linear_interpolation(devs_dn, band_q_inp)
        // Angle in degrees — slope normalized by ATR
        float slope_atr = atr14 > 0 ? _slope / atr14 : 0.0
        _angle := math.atan(slope_atr) * 180.0 / math.pi
    [_slope, _intercept, _updev, _dndev, _angle]

// ----- Build a new segment between two pivots -----
// Pivot at bar (bar_index - pivot_lb) with given price is the new anchor.
// Connect from `last_pivot_bar` to this new pivot.
// Returns [new_last_bar, new_last_price, new_last_type] for caller to assign.
// (Pine v6 forbids modifying var globals inside functions, so the caller updates state.)
f_close_and_open_segment(int new_pivot_bar, float new_pivot_price, int new_pivot_type, int prev_last_bar, float prev_last_price, int prev_last_type) =>
    // Only build a segment if we have a prior pivot of OPPOSITE type
    bool eligible = not na(prev_last_bar) and prev_last_type != 0 and prev_last_type != new_pivot_type

    // QUALITY FILTERS — skip noise
    bool passes_filters = eligible
    if eligible
        int   bar_dist   = new_pivot_bar - prev_last_bar
        float price_dist = math.abs(new_pivot_price - prev_last_price)
        float atr_at_pivot = atr14
        float min_dist_price = min_seg_atr_inp * atr_at_pivot
        if bar_dist < min_seg_bars_inp
            passes_filters := false
        if price_dist < min_dist_price
            passes_filters := false

    // Return state — if filters fail, DON'T update last_pivot tracker
    // (so next opposite pivot can still try to connect to the original anchor)
    int   ret_bar   = passes_filters ? new_pivot_bar   : prev_last_bar
    float ret_price = passes_filters ? new_pivot_price : prev_last_price
    int   ret_type  = passes_filters ? new_pivot_type  : prev_last_type

    if passes_filters
        int s_bar    = prev_last_bar
        float s_price = prev_last_price
        int e_bar    = new_pivot_bar
        float e_price = new_pivot_price
        int dir = new_pivot_type

        [_slope, _intercept, _updev, _dndev, _angle] = f_segment_metrics(s_bar, s_price, e_bar, e_price)

        array.push(seg_start_bar,   s_bar)
        array.push(seg_start_price, s_price)
        array.push(seg_end_bar,     e_bar)
        array.push(seg_end_price,   e_price)
        array.push(seg_slope,       _slope)
        array.push(seg_intercept,   _intercept)
        array.push(seg_updev,       _updev)
        array.push(seg_dndev,       _dndev)
        array.push(seg_direction,   dir)
        array.push(seg_angle,       _angle)
        array.push(seg_upper_glow,  line(na))
        array.push(seg_upper_core,  line(na))
        array.push(seg_lower_glow,  line(na))
        array.push(seg_lower_core,  line(na))
        array.push(seg_basis,       line(na))
        array.push(seg_fill,        linefill(na))
        array.push(seg_pivot_lbl,   label(na))

    // If filters fail and there was NO previous pivot, still record this one as starting point
    if not passes_filters and na(prev_last_bar)
        ret_bar   := new_pivot_bar
        ret_price := new_pivot_price
        ret_type  := new_pivot_type

    [ret_bar, ret_price, ret_type]

// On new pivot detection, close/open segment.
// Freshness guard: with an adaptive window the same old swing can re-qualify
// later under a different lb — only accept pivots newer than the last anchor.
// Same-type extension MERGES into the completed phase: when the up-phase runs
// to a higher high (or the down-phase to a lower low), the last completed
// segment's endpoint moves to the new confirmed swing and its metrics are
// recomputed — no orphan gap is left between the old and the new extreme.
// This happens only at swing confirmation, on closed data.
if new_ph and (na(last_pivot_bar) or bar_index - pivot_lb > last_pivot_bar)
    int ph_bar = bar_index - pivot_lb
    if last_pivot_type == 1 and not na(last_pivot_price) and pivot_high_now > last_pivot_price
        int ph_last_idx = array.size(seg_end_bar) - 1
        if ph_last_idx >= 0 and array.get(seg_end_bar, ph_last_idx) == last_pivot_bar
            [ph_sl, ph_ic, ph_du, ph_dd, ph_an] = f_segment_metrics(array.get(seg_start_bar, ph_last_idx), array.get(seg_start_price, ph_last_idx), ph_bar, pivot_high_now)
            array.set(seg_end_bar,   ph_last_idx, ph_bar)
            array.set(seg_end_price, ph_last_idx, pivot_high_now)
            array.set(seg_slope,     ph_last_idx, ph_sl)
            array.set(seg_intercept, ph_last_idx, ph_ic)
            array.set(seg_updev,     ph_last_idx, ph_du)
            array.set(seg_dndev,     ph_last_idx, ph_dd)
            array.set(seg_angle,     ph_last_idx, ph_an)
        last_pivot_bar   := ph_bar
        last_pivot_price := pivot_high_now
        last_pivot_type  := 1
    else
        [nb, np, nt] = f_close_and_open_segment(ph_bar, pivot_high_now, 1, last_pivot_bar, last_pivot_price, last_pivot_type)
        last_pivot_bar   := nb
        last_pivot_price := np
        last_pivot_type  := nt

if new_pl and (na(last_pivot_bar) or bar_index - pivot_lb > last_pivot_bar)
    int pl_bar = bar_index - pivot_lb
    if last_pivot_type == -1 and not na(last_pivot_price) and pivot_low_now < last_pivot_price
        int pl_last_idx = array.size(seg_end_bar) - 1
        if pl_last_idx >= 0 and array.get(seg_end_bar, pl_last_idx) == last_pivot_bar
            [pl_sl, pl_ic, pl_du, pl_dd, pl_an] = f_segment_metrics(array.get(seg_start_bar, pl_last_idx), array.get(seg_start_price, pl_last_idx), pl_bar, pivot_low_now)
            array.set(seg_end_bar,   pl_last_idx, pl_bar)
            array.set(seg_end_price, pl_last_idx, pivot_low_now)
            array.set(seg_slope,     pl_last_idx, pl_sl)
            array.set(seg_intercept, pl_last_idx, pl_ic)
            array.set(seg_updev,     pl_last_idx, pl_du)
            array.set(seg_dndev,     pl_last_idx, pl_dd)
            array.set(seg_angle,     pl_last_idx, pl_an)
        last_pivot_bar   := pl_bar
        last_pivot_price := pivot_low_now
        last_pivot_type  := -1
    else
        [nb, np, nt] = f_close_and_open_segment(pl_bar, pivot_low_now, -1, last_pivot_bar, last_pivot_price, last_pivot_type)
        last_pivot_bar   := nb
        last_pivot_price := np
        last_pivot_type  := nt

// FIFO trim — remove oldest segments if over limit
while array.size(seg_start_bar) > max_segments_inp
    array.shift(seg_start_bar)
    array.shift(seg_start_price)
    array.shift(seg_end_bar)
    array.shift(seg_end_price)
    array.shift(seg_slope)
    array.shift(seg_intercept)
    array.shift(seg_updev)
    array.shift(seg_dndev)
    array.shift(seg_direction)
    array.shift(seg_angle)

    line lu_g = array.shift(seg_upper_glow)
    line lu_c = array.shift(seg_upper_core)
    line ll_g = array.shift(seg_lower_glow)
    line ll_c = array.shift(seg_lower_core)
    line lb_  = array.shift(seg_basis)
    linefill lf = array.shift(seg_fill)
    label pl  = array.shift(seg_pivot_lbl)
    if not na(lu_g)
        line.delete(lu_g)
    if not na(lu_c)
        line.delete(lu_c)
    if not na(ll_g)
        line.delete(ll_g)
    if not na(ll_c)
        line.delete(ll_c)
    if not na(lb_)
        line.delete(lb_)
    if not na(lf)
        linefill.delete(lf)
    if not na(pl)
        label.delete(pl)

// ============================================================================
// SECTION 5 — ACTIVE SEGMENT (open, from last pivot to current bar)
//   This is the "live" segment that's still forming — bright with glow
// ============================================================================

// Compute live metrics for the in-progress segment
var float active_slope     = 0.0
var float active_intercept = 0.0
var float active_updev     = 0.0
var float active_dndev     = 0.0
var float active_angle     = 0.0
var int   active_dir       = 0
var int   active_start_bar = na
var float active_start_price = na

if not na(last_pivot_bar) and bar_index > last_pivot_bar
    // Active segment: anchor at last pivot, extend to current bar.
    // In Non-Repaint Mode: use close[1] (closed previous bar) so the segment doesn't
    // flicker tick-by-tick. Otherwise use live close.
    float seg_end_price_input = non_repaint_inp ? nz(close[1], close) : close
    int   seg_end_bar_input   = non_repaint_inp ? bar_index - 1       : bar_index
    [_s, _i, _du, _dd, _a] = f_segment_metrics(last_pivot_bar, last_pivot_price, seg_end_bar_input, seg_end_price_input)
    active_slope     := _s
    active_intercept := _i
    active_updev     := _du
    active_dndev     := _dd
    active_angle     := _a
    active_dir := last_pivot_type == 1 ? -1 : last_pivot_type == -1 ? 1 : 0
    active_start_bar   := last_pivot_bar
    active_start_price := last_pivot_price

bool have_active = not na(active_start_bar) and active_dir != 0

// Active band values at current bar — asymmetric: each side has its own
// quantile width with its own ATR floor
float active_upper_now = na
float active_lower_now = na
float active_basis_now = na
float active_half_width = na
if have_active
    float x_now = bar_index - active_start_bar
    active_basis_now := active_intercept + active_slope * x_now
    float a_hw_up = math.max(active_updev * band_dev_mult_inp, min_band_atr_inp * atr14)
    float a_hw_dn = math.max(active_dndev * band_dev_mult_inp, min_band_atr_inp * atr14)
    active_upper_now := active_basis_now + a_hw_up
    active_lower_now := active_basis_now - a_hw_dn
    active_half_width := (a_hw_up + a_hw_dn) / 2.0

// ============================================================================
// SECTION 6 — MICRO CHANNEL (recency-weighted regression)
//   Not a plain least-squares line: each bar is weighted by decay^age, so the
//   newest bars dominate the fit and the momentum read turns earlier than a
//   uniform regression of the same length. Decay = 1.00 reproduces the
//   classic unweighted fit. R² and the residual band use the same weights.
// ============================================================================

int   n_lr = micro_lr_len_inp
int   micro_src_offset = non_repaint_inp ? 1 : 0
int   micro_end_bar = bar_index - micro_src_offset
float msum_w  = 0.0
float msum_x  = 0.0
float msum_y  = 0.0
float msum_xy = 0.0
float msum_xx = 0.0
float msum_yy = 0.0
for i = 0 to n_lr - 1
    float w = math.pow(micro_decay_inp, i)
    float x = i
    float y = close[i + micro_src_offset]
    msum_w  := msum_w  + w
    msum_x  := msum_x  + w * x
    msum_y  := msum_y  + w * y
    msum_xy := msum_xy + w * x * y
    msum_xx := msum_xx + w * x * x
    msum_yy := msum_yy + w * y * y

// Weighted least squares: slope and intercept at x=0 (the newest bar)
float denom_mx = msum_w * msum_xx - msum_x * msum_x
float slope_xy = denom_mx != 0 ? (msum_w * msum_xy - msum_x * msum_y) / denom_mx : 0.0
float intercept_m = msum_w > 0 ? (msum_y - slope_xy * msum_x) / msum_w : close

float micro_basis = intercept_m
float micro_slope_raw = -slope_xy
float micro_slope_atr = atr14 > 0 ? micro_slope_raw / atr14 : 0.0
float micro_angle = math.atan(micro_slope_atr) * 180.0 / math.pi

int micro_dir = micro_angle >  3.0 ? 1 : micro_angle < -3.0 ? -1 : 0

// Weighted correlation → R²
float num_r   = msum_w * msum_xy - msum_x * msum_y
float den_r_x = msum_w * msum_xx - msum_x * msum_x
float den_r_y = msum_w * msum_yy - msum_y * msum_y
float den_r   = math.sqrt(math.max(0.0, den_r_x) * math.max(0.0, den_r_y))
float micro_r = den_r > 0 ? num_r / den_r : 0.0
float micro_r2 = micro_r * micro_r

// Weighted residual band — second pass with the same weights
float wres = 0.0
for i = 0 to n_lr - 1
    float w = math.pow(micro_decay_inp, i)
    float res = close[i + micro_src_offset] - (intercept_m + slope_xy * i)
    wres := wres + w * res * res
float micro_stdev = msum_w > 0 ? math.sqrt(wres / msum_w) : 0.0

float micro_upper = micro_basis + micro_stdev * micro_dev_mult_inp
float micro_lower = micro_basis - micro_stdev * micro_dev_mult_inp
float micro_width = micro_upper - micro_lower

bool micro_visible = micro_r2 >= micro_r2_min_inp

// ============================================================================
// SECTION 7 — ALIGNMENT & CLASSIFICATION
// ============================================================================

bool macro_up   = active_dir ==  1
bool macro_down = active_dir == -1
bool macro_flat = active_dir ==  0
bool micro_up  = micro_dir ==  1
bool micro_dn  = micro_dir == -1
bool micro_fl  = micro_dir ==  0

f_alignment(bool mu, bool md, bool xu, bool xd, bool xf) =>
    mu and xu ? "Aligned Up" : md and xd ? "Aligned Down" : mu and xd ? "Pullback Down" : md and xu ? "Pullback Up" : "Building"

string alignment = f_alignment(macro_up, macro_down, micro_up, micro_dn, micro_fl)

color align_color = alignment == "Aligned Up" ? NEO_BULL_ACCENT : alignment == "Aligned Down" ? NEO_BEAR_ACCENT : alignment == "Pullback Down" ? NEO_SIGNAL : alignment == "Pullback Up" ? NEO_SIGNAL : NEO_DIM

string align_symbol = alignment == "Aligned Up" ? "↗ ALIGNED UP" : alignment == "Aligned Down" ? "↘ ALIGNED DOWN" : alignment == "Pullback Down" ? "↘ PULLBACK" : alignment == "Pullback Up" ? "↗ PULLBACK" : "● BUILDING"

// Channel Position: where close sits between the active Macro band, 0-100%.
// Hoisted to top level (was previously computed inline inside the panel block
// only) — the Entry Score engine (Section 9B) needs it on every bar, not just
// on the last bar.
float chan_pos_pct = (have_active and active_upper_now != active_lower_now) ? (close - active_lower_now) / (active_upper_now - active_lower_now) * 100.0 : na

// ============================================================================
// SECTION 7B — PANEL HELPER FUNCTIONS (defined before first usage in Section 10)
// ============================================================================

f_dir_arrow(int d) =>
    d == 1 ? "↗ Uptrend" : d == -1 ? "↘ Downtrend" : "⇆ Flat"

f_chain_arrows() =>
    int sz = array.size(seg_direction)
    int show_n = math.min(sz, 6)
    string s = ""
    if show_n > 0
        for k = sz - show_n to sz - 1
            int d = array.get(seg_direction, k)
            s := s + (d == 1 ? "↗" : "↘") + " "
    if have_active
        s := s + (active_dir == 1 ? "↗" : active_dir == -1 ? "↘" : "·") + "*"
    s

// Trend Bias: directional bias weighted by segment length × angle magnitude,
// combined with NET PRICE MOVE over the analysis window.
// Net move dominates choppy zigzag — if price moved $1000 down over 6 segments, bias is bearish
// regardless of how many tiny up-segments existed.
f_trend_bias() =>
    int sz = array.size(seg_direction)
    int look_n = math.min(sz, 6)
    float up_weight = 0.0
    float dn_weight = 0.0
    float oldest_price = na
    float newest_price = na
    if look_n > 0
        for k = sz - look_n to sz - 1
            int   d   = array.get(seg_direction, k)
            int   sb_ = array.get(seg_start_bar, k)
            int   eb_ = array.get(seg_end_bar,   k)
            float ang = array.get(seg_angle,     k)
            float bars = eb_ - sb_
            float w = bars * math.max(math.abs(ang), 1.0)
            if d == 1
                up_weight := up_weight + w
            if d == -1
                dn_weight := dn_weight + w
            if k == sz - look_n
                oldest_price := array.get(seg_start_price, k)
            if k == sz - 1
                newest_price := array.get(seg_end_price, k)
    if have_active
        float a_bars = bar_index - active_start_bar
        float a_w = a_bars * math.max(math.abs(active_angle), 1.0)
        if active_dir == 1
            up_weight := up_weight + a_w
        if active_dir == -1
            dn_weight := dn_weight + a_w
        newest_price := close
        if na(oldest_price)
            oldest_price := active_start_price

    // Net move component (signed, in ATR units)
    float net_move_atr = (not na(oldest_price) and not na(newest_price) and atr14 > 0) ? (newest_price - oldest_price) / atr14 : 0.0

    float total = up_weight + dn_weight
    string lbl = "Neutral"
    color  col = NEO_DIM
    if total > 0
        float up_ratio = up_weight / total
        // Combine: angle-weighted ratio + net move signal
        // Strong net move (>3 ATR) overrides mixed ratio
        if net_move_atr > 3.0 and up_ratio >= 0.40
            lbl := "Strong Bull"
            col := NEO_BULL
        else if net_move_atr < -3.0 and up_ratio <= 0.60
            lbl := "Strong Bear"
            col := NEO_BEAR
        else if up_ratio >= 0.70
            lbl := "Strong Bull"
            col := NEO_BULL
        else if up_ratio >= 0.55 or (net_move_atr > 1.5 and up_ratio >= 0.45)
            lbl := "Bullish"
            col := NEO_BULL
        else if up_ratio <= 0.30
            lbl := "Strong Bear"
            col := NEO_BEAR
        else if up_ratio <= 0.45 or (net_move_atr < -1.5 and up_ratio <= 0.55)
            lbl := "Bearish"
            col := NEO_BEAR
        else
            lbl := "Mixed"
            col := NEO_SIGNAL
    [lbl, col]

// ============================================================================
// SECTION 8 — SIGNALS
// ============================================================================

// Hoist ta.crossover/crossunder to top-level so they execute every bar (CW10002 fix).
// These compute unconditional state — then we gate them downstream with macro direction.
bool _xover_upper  = ta.crossover(close,  active_upper_now)
bool _xunder_lower = ta.crossunder(close, active_lower_now)
bool _xover_mic    = ta.crossover(close,  micro_upper)
bool _xunder_mic   = ta.crossunder(close, micro_lower)

// Segment break: close crosses active upper (if downtrend) or lower (if uptrend)
bool segbreak_up   = have_active and macro_down and _xover_upper
bool segbreak_down = have_active and macro_up   and _xunder_lower
bool segbreak_signal = sig_segbreak_inp and (segbreak_up or segbreak_down)

// Pullback: TRANSITION moment — close touches/penetrates band on THIS bar but didn't on previous
// Long pullback: in uptrend, close drops to within 0.2 ATR of lower band but stays above basis
bool _pb_long_state  = have_active and macro_up   and close <= active_lower_now + atr14 * 0.2 and close >= active_lower_now
bool _pb_short_state = have_active and macro_down and close >= active_upper_now - atr14 * 0.2 and close <= active_upper_now
bool pullback_long   = _pb_long_state  and not _pb_long_state[1]
bool pullback_short  = _pb_short_state and not _pb_short_state[1]
bool pullback_signal = sig_pullback_inp and (pullback_long or pullback_short)

// Micro continuation: micro band breakout aligned with macro
// CRITICAL: only fire in the EARLY part of the macro segment (first 50% of typical segment length).
// Late-segment breakouts are usually exhaustion, not continuation.
int bars_into_seg = have_active ? bar_index - active_start_bar : 0
bool early_in_seg = have_active and bars_into_seg >= 3 and bars_into_seg <= 25
bool micro_break_up   = _xover_mic
bool micro_break_down = _xunder_mic
bool cont_long  = macro_up   and micro_break_up   and micro_visible and early_in_seg
bool cont_short = macro_down and micro_break_down and micro_visible and early_in_seg
bool cont_signal = sig_microbreak_inp and (cont_long or cont_short)

// ============================================================================
// SECTION 9 — MTF
// ============================================================================

int chart_minutes = timeframe.in_seconds() / 60
f_mtf_pair() =>
    string t1 = "240"
    string t2 = "1D"
    if timeframe.isseconds
        t1 := "5"
        t2 := "60"
    else if chart_minutes <= 1
        t1 := "15"
        t2 := "60"
    else if chart_minutes <= 5
        t1 := "60"
        t2 := "240"
    else if chart_minutes <= 15
        t1 := "240"
        t2 := "1D"
    else if chart_minutes <= 60
        t1 := "240"
        t2 := "1D"
    else if chart_minutes <= 240
        t1 := "1D"
        t2 := "1W"
    else if timeframe.isdaily
        t1 := "1W"
        t2 := "1M"
    else
        t1 := "1M"
        t2 := "3M"
    [t1, t2]

[mtf1_tf, mtf2_tf] = f_mtf_pair()

f_get_mtf(string tf) =>
    [_dir, _ang, _r2] = request.security(syminfo.tickerid, tf,
         [active_dir[1], active_angle[1], micro_r2[1]],
         lookahead=barmerge.lookahead_off)
    [_dir, _ang, _r2]

[mtf1_dir, mtf1_ang, mtf1_r2] = f_get_mtf(mtf1_tf)
[mtf2_dir, mtf2_ang, mtf2_r2] = f_get_mtf(mtf2_tf)

// ============================================================================
// SECTION 9B — NAVIGATOR ENTRY SCORE (unique confluence algorithm)
//   0-100 composite score, computed independently for the long side and the
//   short side. Four weighted components, summing to 100 at full confluence:
//
//     1. Macro/Micro Alignment  (35 pts) — active segment direction AND micro
//        regression direction both agree with the side being scored.
//     2. Channel Position       (20 pts) — reward pullback proximity to the
//        favorable band edge (buying dips in an uptrend / selling rallies in
//        a downtrend), not chasing mid-channel or the far edge.
//     3. Micro Fit Quality      (20 pts) — micro_r2 scaled directly; a clean
//        regression fit is a more trustworthy momentum read than a noisy one.
//     4. MTF Confluence         (25 pts) — 12.5 pts per MTF timeframe whose
//        direction agrees with the side being scored (240/1D by default).
//
//   entry_score = max(score_long, score_short); entry_dir = winning side.
//   An ENTRY marker fires once when the winning score crosses the threshold,
//   confirmed-bar gated + cooldown gated, exactly like the other 3 signal
//   families. This scoring model does not exist in any other channel product
//   in the MQLSoftware line — it is the Navigator's differentiator.
// ============================================================================

f_entry_score(bool want_long) =>
    bool aligned  = want_long ? (macro_up and micro_up) : (macro_down and micro_dn)
    float align_c = aligned ? 35.0 : 0.0
    float pos_raw = na(chan_pos_pct) ? 0.0 : want_long ? (100.0 - chan_pos_pct) : chan_pos_pct
    float pos_c   = math.max(0.0, math.min(20.0, pos_raw * 0.20))
    float r2_c    = micro_visible ? math.max(0.0, math.min(1.0, micro_r2)) * 20.0 : 0.0
    float mtf_c   = (want_long ? (mtf1_dir == 1 ? 12.5 : 0.0) + (mtf2_dir == 1 ? 12.5 : 0.0)
                                : (mtf1_dir == -1 ? 12.5 : 0.0) + (mtf2_dir == -1 ? 12.5 : 0.0))
    // Optional stricter mode: cap the score below the top tier unless BOTH
    // MTF timeframes agree — keeps "Require MTF Confluence" meaningful.
    float raw = align_c + pos_c + r2_c + mtf_c
    float capped = entry_require_mtf_inp and mtf_c < 25.0 ? math.min(raw, entry_threshold_inp - 1.0) : raw
    float total = math.max(0.0, math.min(100.0, capped))
    [total, align_c, pos_c, r2_c, mtf_c]

[score_l_raw, al_l, pos_l, fit_l, mtf_l] = f_entry_score(true)
[score_s_raw, al_s, pos_s, fit_s, mtf_s] = f_entry_score(false)
float entry_score_long  = have_active ? score_l_raw : 0.0
float entry_score_short = have_active ? score_s_raw : 0.0
int   entry_dir   = entry_score_long >= entry_score_short ? 1 : -1
float entry_score = math.max(entry_score_long, entry_score_short)
// Winning-side components — feed the live Score Breakdown block in the panel
float sc_align = entry_dir == 1 ? al_l  : al_s
float sc_pos   = entry_dir == 1 ? pos_l : pos_s
float sc_fit   = entry_dir == 1 ? fit_l : fit_s
float sc_mtf   = entry_dir == 1 ? mtf_l : mtf_s

bool entry_cross_up = ta.crossover(entry_score_long,  entry_threshold_inp)
bool entry_cross_dn = ta.crossover(entry_score_short, entry_threshold_inp)
bool entry_long_raw  = macro_up   and entry_cross_up
bool entry_short_raw = macro_down and entry_cross_dn
bool entry_signal = entry_long_raw or entry_short_raw

// ============================================================================
// SECTION 10 — RENDERING: ALL SEGMENTS (rendered on barstate.islast)
//   Pine v6 quirk: lines created on historical bars (inside `if new_ph` blocks)
//   are tied to those bars and may be lost on rebuild. Safe approach:
//   render the entire segment array fresh on the last bar each time.
// ============================================================================

if barstate.islast
    // First — delete any previously rendered segment graphics
    int existing = array.size(seg_upper_glow)
    for k = 0 to existing - 1
        line lu_g = array.get(seg_upper_glow, k)
        line lu_c = array.get(seg_upper_core, k)
        line ll_g = array.get(seg_lower_glow, k)
        line ll_c = array.get(seg_lower_core, k)
        line lb_  = array.get(seg_basis,      k)
        linefill lf_ = array.get(seg_fill,    k)
        label pl_ = array.get(seg_pivot_lbl,  k)
        if not na(lu_g)
            line.delete(lu_g)
        if not na(lu_c)
            line.delete(lu_c)
        if not na(ll_g)
            line.delete(ll_g)
        if not na(ll_c)
            line.delete(ll_c)
        if not na(lb_)
            line.delete(lb_)
        if not na(lf_)
            linefill.delete(lf_)
        if not na(pl_)
            label.delete(pl_)

    // Now render every segment from scratch
    int seg_count = array.size(seg_start_bar)
    for idx = 0 to seg_count - 1
        int   sb = array.get(seg_start_bar,   idx)
        float sp = array.get(seg_start_price, idx)
        int   eb = array.get(seg_end_bar,     idx)
        float ep = array.get(seg_end_price,   idx)
        float sl = array.get(seg_slope,       idx)
        float ic = array.get(seg_intercept,   idx)
        float sdu = array.get(seg_updev,      idx)
        float sdd = array.get(seg_dndev,      idx)
        int   dr = array.get(seg_direction,   idx)

        // x positions within segment local coords: 0 = start, len-1 = end
        int seg_len = eb - sb
        float start_basis = ic                       // basis value at start (x=0) — equals start pivot price
        float end_basis   = ic + sl * seg_len        // basis value at end (x=seg_len)
        // Asymmetric quantile widths — each side has its own multiplier + ATR floor
        float hw_up = math.max(sdu * band_dev_mult_inp, min_band_atr_inp * atr14)
        float hw_dn = math.max(sdd * band_dev_mult_inp, min_band_atr_inp * atr14)

        // Parallel channel with independent side offsets, CONSTANT along the phase
        float start_upper = start_basis + hw_up
        float start_lower = start_basis - hw_dn
        float end_upper   = end_basis   + hw_up
        float end_lower   = end_basis   - hw_dn

        color seg_color = dr == 1 ? NEO_BULL : NEO_BEAR

        // Two parallel lines: upper (glow + core), lower (glow + core).
        // Glow width tracks the same restrained scale as the active segment —
        // a thin neon edge, not a thick highlighter block.
        line lu_glow = show_macro_inp and glow_enabled ? line.new(sb, start_upper, eb, end_upper,
             color=color.new(seg_color, 72), width=glow_width) : na
        line lu_core = show_macro_inp ? line.new(sb, start_upper, eb, end_upper,
             color=color.new(seg_color, 20), width=line_width_inp) : na
        line ll_glow = show_macro_inp and glow_enabled ? line.new(sb, start_lower, eb, end_lower,
             color=color.new(seg_color, 72), width=glow_width) : na
        line ll_core = show_macro_inp ? line.new(sb, start_lower, eb, end_lower,
             color=color.new(seg_color, 20), width=line_width_inp) : na

        // Basis line (dashed center)
        line lb_b = na
        if show_macro_inp and show_basis_inp
            lb_b := line.new(sb, start_basis, eb, end_basis,
                 color=color.new(seg_color, 50), width=1, style=line.style_dashed)

        // Channel fill — between upper and lower core lines
        linefill lf = na
        if show_macro_inp and show_fill_inp and not na(lu_core) and not na(ll_core)
            lf := linefill.new(lu_core, ll_core, color=color.new(seg_color, 92))

        label plb = na
        if show_pivots_inp
            // High pivot: label sits ABOVE pivot, arrow points DOWN to it (▼)
            // Low pivot: label sits BELOW pivot, arrow points UP to it (▲)
            // The label SHAPE acts as the pointer, the TEXT shows which pivot we're at as H/L
            plb := label.new(eb, ep, dr == 1 ? "H" : "L", style=dr == 1 ? label.style_label_down : label.style_label_up, color=color.new(seg_color, 25), textcolor=NEO_WHITE, size=size.tiny, tooltip=dr == 1 ? "Confirmed swing high — segment anchor. Fixed once confirmed, never moves." : "Confirmed swing low — segment anchor. Fixed once confirmed, never moves.")

        array.set(seg_upper_glow, idx, lu_glow)
        array.set(seg_upper_core, idx, lu_core)
        array.set(seg_lower_glow, idx, ll_glow)
        array.set(seg_lower_core, idx, ll_core)
        array.set(seg_basis,      idx, lb_b)
        array.set(seg_fill,       idx, lf)
        array.set(seg_pivot_lbl,  idx, plb)

// ============================================================================
// SECTION 10B — ACTIVE SEGMENT RENDERING (last segment, redraw each bar)
// ============================================================================

var line active_upper_glow = na
var line active_upper_core = na
var line active_upper_glow_b = na
var line active_upper_core_b = na
var line active_lower_glow = na
var line active_lower_core = na
var line active_lower_glow_b = na
var line active_lower_core_b = na
var line active_basis_line = na
var linefill active_fill   = na
var line active_zone_line  = na
var linefill active_zone_fill = na
var line active_q1_line    = na
var line active_q3_line    = na

var line mic_upper_glow = na
var line mic_upper_core = na
var line mic_lower_glow = na
var line mic_lower_core = na
var line mic_basis_line = na
var linefill mic_fill   = na

var label   status_lbl   = na
var label   mac_up_lbl   = na
var label   mac_lo_lbl   = na
var label   mic_up_lbl   = na
var label   mic_lo_lbl   = na

f_del_line(line ln) =>
    if not na(ln)
        line.delete(ln)
    line(na)
f_del_label(label lb) =>
    if not na(lb)
        label.delete(lb)
    label(na)
f_del_fill(linefill lf) =>
    if not na(lf)
        linefill.delete(lf)
    linefill(na)

if barstate.islast
    // Cleanup
    active_fill          := f_del_fill(active_fill)
    active_zone_fill     := f_del_fill(active_zone_fill)
    mic_fill             := f_del_fill(mic_fill)
    active_upper_glow    := f_del_line(active_upper_glow)
    active_upper_core    := f_del_line(active_upper_core)
    active_upper_glow_b  := f_del_line(active_upper_glow_b)
    active_upper_core_b  := f_del_line(active_upper_core_b)
    active_lower_glow    := f_del_line(active_lower_glow)
    active_lower_core    := f_del_line(active_lower_core)
    active_lower_glow_b  := f_del_line(active_lower_glow_b)
    active_lower_core_b  := f_del_line(active_lower_core_b)
    active_basis_line    := f_del_line(active_basis_line)
    active_zone_line     := f_del_line(active_zone_line)
    active_q1_line       := f_del_line(active_q1_line)
    active_q3_line       := f_del_line(active_q3_line)
    mic_upper_glow     := f_del_line(mic_upper_glow)
    mic_upper_core     := f_del_line(mic_upper_core)
    mic_lower_glow     := f_del_line(mic_lower_glow)
    mic_lower_core     := f_del_line(mic_lower_core)
    mic_basis_line     := f_del_line(mic_basis_line)
    mac_up_lbl         := f_del_label(mac_up_lbl)
    mac_lo_lbl         := f_del_label(mac_lo_lbl)
    mic_up_lbl         := f_del_label(mic_up_lbl)
    mic_lo_lbl         := f_del_label(mic_lo_lbl)
    status_lbl         := f_del_label(status_lbl)

    // --- Active Macro segment — parallel channel + dashed projection to the right ---
    // Geometry: classic parallel lines from pivot to current bar, then dashed extension forward.
    // Width is CONSTANT (same as historical segments).
    if show_macro_inp and have_active
        color a_color = active_dir == 1 ? NEO_BULL : NEO_BEAR
        float a_render_hw_up = math.max(active_updev * band_dev_mult_inp, min_band_atr_inp * atr14)
        float a_render_hw_dn = math.max(active_dndev * band_dev_mult_inp, min_band_atr_inp * atr14)

        // Band values at pivot (start) — asymmetric offsets
        float a_start_basis = active_intercept
        float a_start_upper = a_start_basis + a_render_hw_up
        float a_start_lower = a_start_basis - a_render_hw_dn

        // Band values at current bar (already computed: active_upper_now / active_lower_now)
        // Project forward 20 bars
        int   proj_bars  = 20
        int   proj_end_x = bar_index + proj_bars
        float proj_basis = active_intercept + active_slope * (proj_end_x - active_start_bar)
        float proj_upper = proj_basis + a_render_hw_up
        float proj_lower = proj_basis - a_render_hw_dn

        // SOLID portion: pivot → current bar. Core stays crisp (full opacity);
        // the glow layer is thin + fairly transparent so it reads as a soft
        // neon edge rather than a blurred/aliased halo.
        active_upper_glow := glow_enabled ? line.new(active_start_bar, a_start_upper, bar_index, active_upper_now,
             color=color.new(a_color, 62), width=glow_width) : na
        active_upper_core := line.new(active_start_bar, a_start_upper, bar_index, active_upper_now,
             color=color.new(a_color, 0), width=line_width_inp)
        active_lower_glow := glow_enabled ? line.new(active_start_bar, a_start_lower, bar_index, active_lower_now,
             color=color.new(a_color, 62), width=glow_width) : na
        active_lower_core := line.new(active_start_bar, a_start_lower, bar_index, active_lower_now,
             color=color.new(a_color, 0), width=line_width_inp)

        // DASHED projection: current bar → +20 bars right
        active_upper_glow_b := glow_enabled ? line.new(bar_index, active_upper_now, proj_end_x, proj_upper,
             color=color.new(a_color, 78), width=line_width_inp, style=line.style_dashed) : na
        active_upper_core_b := line.new(bar_index, active_upper_now, proj_end_x, proj_upper,
             color=color.new(a_color, 45), width=line_width_inp, style=line.style_dashed)
        active_lower_glow_b := glow_enabled ? line.new(bar_index, active_lower_now, proj_end_x, proj_lower,
             color=color.new(a_color, 78), width=line_width_inp, style=line.style_dashed) : na
        active_lower_core_b := line.new(bar_index, active_lower_now, proj_end_x, proj_lower,
             color=color.new(a_color, 45), width=line_width_inp, style=line.style_dashed)

        // Basis (dashed) — pivot → current
        if show_basis_inp
            active_basis_line := line.new(active_start_bar, a_start_basis, bar_index, active_basis_now,
                 color=color.new(a_color, 25), width=1, style=line.style_dashed)

        // Fill — between solid upper/lower cores
        if show_fill_inp
            active_fill := linefill.new(active_upper_core, active_lower_core,
                 color=color.new(a_color, 90))

        // Pullback Zone — shade the favorable QUARTER of the active channel:
        // the exact area the Entry Score's Channel Position component rewards
        // (dips near the base in an up segment, rallies near the top in a down
        // segment). Turns the channel from "where price has been" into "where
        // the next read matters".
        float a_start_width = a_start_upper - a_start_lower
        float a_now_width   = active_upper_now - active_lower_now
        if show_zone_inp
            float zone_frac    = 0.25
            float z_start_edge = active_dir == 1 ? a_start_lower + a_start_width * zone_frac : a_start_upper - a_start_width * zone_frac
            float z_now_edge   = active_dir == 1 ? active_lower_now + a_now_width * zone_frac : active_upper_now - a_now_width * zone_frac
            active_zone_line := line.new(active_start_bar, z_start_edge, bar_index, z_now_edge, color=color.new(a_color, 88), width=1)
            active_zone_fill := linefill.new(active_zone_line, active_dir == 1 ? active_lower_core : active_upper_core, color=color.new(a_color, 82))

        // Quarter grid — faint dotted 25% / 75% lines. Together with the basis
        // they split the channel into the quarters the Channel Position row
        // reads; the favorable quarter is the shaded Pullback Zone above.
        if show_grid_inp
            float q1_start = a_start_lower + a_start_width * 0.25
            float q1_now   = active_lower_now + a_now_width * 0.25
            float q3_start = a_start_lower + a_start_width * 0.75
            float q3_now   = active_lower_now + a_now_width * 0.75
            active_q1_line := line.new(active_start_bar, q1_start, bar_index, q1_now, color=color.new(a_color, 82), width=1, style=line.style_dotted)
            active_q3_line := line.new(active_start_bar, q3_start, bar_index, q3_now, color=color.new(a_color, 82), width=1, style=line.style_dotted)

        // Endpoint labels — plain English, self-explanatory: the favorable
        // edge is named Pullback Zone so the label says what the line is FOR.
        if show_endlbls_inp
            string mac_top_txt  = active_dir == -1 ? "Pullback Zone ▼" : "Channel Top"
            string mac_base_txt = active_dir ==  1 ? "Pullback Zone ▲" : "Channel Base"
            mac_up_lbl := label.new(bar_index + 3, active_upper_now, mac_top_txt, style=label.style_label_left, color=color.new(a_color, 20), textcolor=NEO_WHITE, size=size.tiny, tooltip=active_dir == -1 ? "Upper edge of the active macro channel — the favorable area for trend-side reads in a down segment" : "Upper edge of the active macro channel")
            mac_lo_lbl := label.new(bar_index + 3, active_lower_now, mac_base_txt, style=label.style_label_left, color=color.new(a_color, 50), textcolor=NEO_WHITE, size=size.tiny, tooltip=active_dir == 1 ? "Lower edge of the active macro channel — the favorable area for trend-side reads in an up segment" : "Lower edge of the active macro channel")

    // --- Micro regression channel ---
    if show_micro_inp and micro_visible
        int   m_start_bar     = micro_end_bar - (n_lr - 1)
        float m_start_basis   = intercept_m + slope_xy * (n_lr - 1)
        float m_start_upper   = m_start_basis + micro_stdev * micro_dev_mult_inp
        float m_start_lower   = m_start_basis - micro_stdev * micro_dev_mult_inp

        color m_color = micro_dir == 1 ? NEO_BULL_ACCENT : micro_dir == -1 ? NEO_BEAR_ACCENT : NEO_DIM

        mic_upper_glow := glow_enabled ? line.new(m_start_bar, m_start_upper, micro_end_bar, micro_upper,
             color=color.new(m_color, 62), width=glow_width) : na
        mic_upper_core := line.new(m_start_bar, m_start_upper, micro_end_bar, micro_upper,
             color=color.new(m_color, 0), width=line_width_inp)
        mic_lower_glow := glow_enabled ? line.new(m_start_bar, m_start_lower, micro_end_bar, micro_lower,
             color=color.new(m_color, 62), width=glow_width) : na
        mic_lower_core := line.new(m_start_bar, m_start_lower, micro_end_bar, micro_lower,
             color=color.new(m_color, 0), width=line_width_inp)
        if show_basis_inp
            mic_basis_line := line.new(m_start_bar, m_start_basis, micro_end_bar, micro_basis,
                 color=color.new(m_color, 25), width=1, style=line.style_dashed)
        if show_fill_inp
            mic_fill := linefill.new(mic_upper_core, mic_lower_core,
                 color=color.new(m_color, 91))

        // One label instead of two — the micro channel is one momentum read,
        // so it gets one name. Fewer right-edge labels = cleaner screenshot.
        if show_endlbls_inp
            string mic_txt = micro_dir == 1 ? "Momentum ▲" : micro_dir == -1 ? "Momentum ▼" : "Momentum —"
            mic_up_lbl := label.new(bar_index + 3, micro_upper, mic_txt, style=label.style_label_left, color=color.new(m_color, 15), textcolor=NEO_WHITE, size=size.tiny, tooltip="Micro regression channel — the current momentum slice inside the macro phase. R² fit: " + str.tostring(micro_r2, "0.00"))

    // --- Status badge — pinned higher to avoid right-edge label collision ---
    // Second line carries the live Entry Score: the panel can be hidden or
    // cropped out of user screenshots, but this chip travels with the price
    // action — every shared screenshot advertises the Navigator's exclusive
    // confluence read.
    if show_status_inp
        [b_lbl, b_col] = f_trend_bias()
        if b_lbl != "Neutral"
            // Position above the high of last 20 bars + good gap so it doesn't overlap the edge labels
            float status_y = anchor_high_20 + atr14 * 3.0
            int   status_x = bar_index + 25
            string status_text = b_lbl == "Strong Bull" ? "↗↗ STRONG BULL" : b_lbl == "Bullish" ? "↗ BULLISH" : b_lbl == "Mixed" ? "⇆ MIXED" : b_lbl == "Bearish" ? "↘ BEARISH" : b_lbl == "Strong Bear" ? "↘↘ STRONG BEAR" : ""
            string score_line  = have_active ? "\n◆ Score " + str.tostring(math.round(entry_score)) + "/100 · " + (entry_dir == 1 ? "LONG" : "SHORT") : ""
            // Dark ink on lime/gold badges, white on magenta — same contrast rule as the panel header
            color  badge_txt = b_lbl == "Bearish" or b_lbl == "Strong Bear" ? NEO_WHITE : NEO_INK
            status_lbl := label.new(status_x, status_y, status_text + score_line,
                 style=label.style_label_left,
                 color=color.new(b_col, 12),
                 textcolor=badge_txt,
                 size=size.normal,
                 textalign=text.align_left,
                 tooltip="Trend Bias across recent segments + the live Navigator Entry Score. When the score crosses the threshold on a confirmed bar, a ◆ ENTRY marker fires.")

// ============================================================================
// SECTION 11 — SIGNAL MARKERS (with cooldown)
// ============================================================================

var array<label> sig_lbls = array.new<label>()
int SIG_LIMIT = 15
bool desc_markers = marker_style_inp == "Descriptive"

var int last_segbreak_bar = -10000
var int last_pb_bar       = -10000
var int last_cont_bar     = -10000
var int last_entry_bar    = -10000

// Last Event tracker (panel row) — most recent fired signal of any type
var string last_event_text = "—"
var int    last_event_bar  = -10000
var color  last_event_col  = NEO_DIM

bool segbreak_ready = signal_cooldown_inp == 0 or (bar_index - last_segbreak_bar) >= signal_cooldown_inp
bool pb_ready       = signal_cooldown_inp == 0 or (bar_index - last_pb_bar)       >= signal_cooldown_inp
bool cont_ready     = signal_cooldown_inp == 0 or (bar_index - last_cont_bar)     >= signal_cooldown_inp
bool entry_ready    = entry_cooldown_inp == 0 or (bar_index - last_entry_bar)     >= entry_cooldown_inp

f_sig_push(label lb) =>
    array.push(sig_lbls, lb)
    if array.size(sig_lbls) > SIG_LIMIT
        label oldest = array.shift(sig_lbls)
        if not na(oldest)
            label.delete(oldest)

// Fired flags — engine truth. Cooldown bookkeeping and alert behavior must be
// IDENTICAL whether markers are displayed or not (display inputs must never
// change signal logic), so state updates below run outside the show_* gates
// and the alertconditions in Section 13 reuse these exact flags.
// Score-aware families: every structural event is checked against the matching
// side of the live Entry Score — Navigator prints SCORED events, not raw ones.
f_side_score(bool is_long_side) =>
    is_long_side ? entry_score_long : entry_score_short
f_score_tag(bool is_long_side) =>
    " " + str.tostring(math.round(f_side_score(is_long_side)))

bool segbreak_fire = segbreak_signal and barstate.isconfirmed and segbreak_ready and f_side_score(segbreak_up) >= min_sig_score_inp
bool pb_fire       = pullback_signal and barstate.isconfirmed and pb_ready       and f_side_score(pullback_long) >= min_sig_score_inp
bool cont_fire     = cont_signal     and barstate.isconfirmed and cont_ready     and f_side_score(cont_long) >= min_sig_score_inp
bool entry_fire    = entry_signal    and barstate.isconfirmed and entry_ready

if segbreak_fire
    bool is_up = segbreak_up
    string brk_txt = desc_markers ? (is_up ? "BREAK ▲" : "BREAK ▼") + f_score_tag(is_up) : (is_up ? "BRK↑" : "BRK↓")
    last_segbreak_bar := bar_index
    last_event_text   := brk_txt
    last_event_bar    := bar_index
    last_event_col    := NEO_SIGNAL
    if show_signals_inp
        float ly = is_up ? high + atr14 * 0.4 : low - atr14 * 0.4
        label lb = label.new(bar_index, ly, brk_txt, style=is_up ? label.style_label_down : label.style_label_up, color=color.new(NEO_SIGNAL, 15), textcolor=NEO_WHITE, size=size.small, tooltip="Confirmed close beyond the active channel boundary — the current trend phase may be ending")
        f_sig_push(lb)

if pb_fire
    bool is_long = pullback_long
    string pb_txt = desc_markers ? (is_long ? "PULLBACK ▲" : "PULLBACK ▼") + f_score_tag(is_long) : (is_long ? "PB↑" : "PB↓")
    last_pb_bar      := bar_index
    last_event_text  := pb_txt
    last_event_bar   := bar_index
    last_event_col   := NEO_SIGNAL
    if show_signals_inp
        float ly = is_long ? low - atr14 * 0.4 : high + atr14 * 0.4
        label lb = label.new(bar_index, ly, pb_txt, style=is_long ? label.style_label_up : label.style_label_down, color=color.new(NEO_SIGNAL, 20), textcolor=NEO_WHITE, size=size.small, tooltip="Price pulled back to the favorable edge of the active channel while the trend structure is intact")
        f_sig_push(lb)

if cont_fire
    bool is_long = cont_long
    color cc = is_long ? NEO_BULL_ACCENT : NEO_BEAR_ACCENT
    string cont_txt = desc_markers ? (is_long ? "CONTINUATION ▲" : "CONTINUATION ▼") + f_score_tag(is_long) : (is_long ? "CONT↑" : "CONT↓")
    last_cont_bar   := bar_index
    last_event_text := cont_txt
    last_event_bar  := bar_index
    last_event_col  := cc
    if show_signals_inp
        float ly = is_long ? low - atr14 * 0.4 : high + atr14 * 0.4
        label lb = label.new(bar_index, ly, cont_txt, style=is_long ? label.style_label_up : label.style_label_down, color=color.new(cc, 20), textcolor=NEO_WHITE, size=size.small, tooltip="Micro momentum breakout in the direction of the macro trend, early in the segment — continuation context, not exhaustion")
        f_sig_push(lb)

// Entry Score marker — the Navigator's unique confluence signal. Rendered
// with the dedicated violet NEO_ENTRY color + diamond marker so it reads as
// a distinct signal family from BRK/PB/CONT at a glance.
if entry_fire
    bool is_long = entry_long_raw
    string score_tag = str.tostring(math.round(entry_score))
    string entry_txt = desc_markers ? (is_long ? "◆ ENTRY ▲ " : "◆ ENTRY ▼ ") + score_tag + "/100" : (is_long ? "◆ ENTRY↑ " : "◆ ENTRY↓ ") + score_tag
    last_entry_bar   := bar_index
    last_event_text  := entry_txt
    last_event_bar   := bar_index
    last_event_col   := NEO_ENTRY
    if show_entry_inp
        float ly = is_long ? low - atr14 * 0.6 : high + atr14 * 0.6
        label lb = label.new(bar_index, ly, entry_txt, style=is_long ? label.style_label_up : label.style_label_down, color=color.new(NEO_ENTRY, 10), textcolor=NEO_WHITE, size=size.small, tooltip="Navigator Entry Score crossed " + str.tostring(entry_threshold_inp) + "/100 on a confirmed bar: trend alignment + pullback position + regression fit + MTF agreement")
        f_sig_push(lb)

// ============================================================================
// SECTION 12 — PANEL
// ============================================================================

var table panel = table.new(position.top_right, 2, 30, bgcolor=na, border_width=0)

if show_panel_inp and barstate.islast
    table.clear(panel, 0, 0, 1, 24)

    [hdr_lbl, hdr_col] = f_trend_bias()
    // Dark ink on the colored header - white text washes out on bright lime;
    // the badge-style header stays readable on lime, magenta and gold alike.
    table.cell(panel, 0, 0, "CHANNEL NAVIGATOR",
         text_color=NEO_INK, bgcolor=color.new(hdr_col, 12),
         text_size=size.normal, text_halign=text.align_left)
    table.cell(panel, 1, 0, syminfo.ticker,
         text_color=NEO_INK, bgcolor=color.new(hdr_col, 12),
         text_size=size.normal, text_halign=text.align_right)

    [bias_lbl, bias_col] = f_trend_bias()
    table.cell(panel, 0, 1, "Trend Bias",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 1, bias_lbl + (alignment == "Building" ? "" : "  ·  " + alignment),
         text_color=bias_col, bgcolor=NEO_PANEL_ROW, text_size=size.normal, text_halign=text.align_right)

    // === Macro ===
    table.cell(panel, 0, 2, "MACRO · Active Segment",
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_SEP, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 2, "", bgcolor=NEO_PANEL_SEP)

    string ang_str = have_active ? str.tostring(active_angle, "+#.#;-#.#") + "°" : "—"
    color  ang_col = active_dir == 1 ? NEO_BULL : active_dir == -1 ? NEO_BEAR : NEO_DIM
    table.cell(panel, 0, 3, "Angle",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 3, ang_str,
         text_color=ang_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 4, "Direction",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 4, f_dir_arrow(active_dir),
         text_color=ang_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    int bars_in_seg = have_active ? bar_index - active_start_bar : 0
    table.cell(panel, 0, 5, "Bars in segment",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 5, str.tostring(bars_in_seg),
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 6, "Segment chain",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 6, f_chain_arrows(),
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    // Channel Position: where close sits between active lower/upper band, 0-100%
    // (chan_pos_pct itself is computed once at top level in Section 7 — the
    // Entry Score engine needs it on every bar, not just barstate.islast)
    string chan_pos_str = na(chan_pos_pct) ? "—" : str.tostring(chan_pos_pct, "#.#") + "%"
    color  chan_pos_col = na(chan_pos_pct) ? NEO_DIM : chan_pos_pct >= 80 ? NEO_BULL : chan_pos_pct <= 20 ? NEO_BEAR : NEO_WHITE
    table.cell(panel, 0, 7, "Channel Position",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 7, chan_pos_str,
         text_color=chan_pos_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    // Anchor: the confirmed pivot (H/L + price) the active segment is built from
    string anchor_type_str = last_pivot_type == 1 ? "H" : last_pivot_type == -1 ? "L" : "—"
    string anchor_str = have_active ? anchor_type_str + " " + str.tostring(active_start_price, format.mintick) : "—"
    color  anchor_col = active_dir == 1 ? NEO_BULL : active_dir == -1 ? NEO_BEAR : NEO_DIM
    table.cell(panel, 0, 8, "Anchor",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 8, anchor_str,
         text_color=anchor_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    // Width: active channel half-width*2, expressed as a multiple of ATR
    float width_atr = (have_active and atr14 > 0 and not na(active_half_width)) ? (active_half_width * 2.0) / atr14 : na
    string width_str = na(width_atr) ? "—" : str.tostring(width_atr, "0.0") + "× ATR"
    table.cell(panel, 0, 9, "Width",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 9, width_str,
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    // Last Event: most recent fired signal (BRK/PB/CONT) of any type, bars since
    string last_event_str = last_event_bar <= -9999 ? "—" : last_event_text + " · " + str.tostring(bar_index - last_event_bar) + "b ago"
    color  last_event_disp_col = last_event_bar <= -9999 ? NEO_DIM : last_event_col
    table.cell(panel, 0, 10, "Last Event",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 10, last_event_str,
         text_color=last_event_disp_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    // === Micro ===
    table.cell(panel, 0, 11, "MICRO · " + str.tostring(micro_lr_len_inp) + "-bar regression",
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_SEP, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 11, "", bgcolor=NEO_PANEL_SEP)

    string m_ang_str = micro_visible ? str.tostring(micro_angle, "+#.#;-#.#") + "°" : "— low fit"
    color  m_ang_col = micro_dir == 1 ? NEO_BULL_ACCENT : micro_dir == -1 ? NEO_BEAR_ACCENT : NEO_DIM
    table.cell(panel, 0, 12, "Angle",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 12, m_ang_str,
         text_color=m_ang_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    table.cell(panel, 0, 13, "Direction",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 13, micro_visible ? f_dir_arrow(micro_dir) : "-",
         text_color=m_ang_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    string r2q = micro_r2 >= 0.80 ? "high" : micro_r2 >= 0.50 ? "med" : micro_r2 >= 0.30 ? "low" : "noise"
    color  r2c = micro_r2 >= 0.80 ? NEO_BULL_ACCENT : micro_r2 >= 0.50 ? NEO_WHITE : micro_r2 >= 0.30 ? NEO_SIGNAL : NEO_DIM
    table.cell(panel, 0, 14, "R² fit",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 14, str.tostring(micro_r2, "0.00") + " " + r2q,
         text_color=r2c, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    // Acceleration: how much steeper/flatter is Micro vs Macro?
    float accel = have_active and micro_visible ? micro_angle - active_angle : na
    string accel_str = na(accel) ? "—" : str.tostring(accel, "+#.#;-#.#") + "° " + (math.abs(accel) < 2.0 ? "flat" : accel > 0 ? "faster" : "slower")
    color accel_col = na(accel) ? NEO_DIM : math.abs(accel) < 2.0 ? NEO_DIM : accel > 0 ? NEO_BULL_ACCENT : NEO_SIGNAL
    table.cell(panel, 0, 15, "Acceleration",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 15, accel_str,
         text_color=accel_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    // === Signals ===
    table.cell(panel, 0, 16, "SIGNALS",
         text_color=NEO_WHITE, bgcolor=NEO_PANEL_SEP, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 16, "", bgcolor=NEO_PANEL_SEP)

    string seg_state = not sig_segbreak_inp ? "off" : segbreak_up ? "▲ UP" : segbreak_down ? "▼ DOWN" : "— wait"
    color  seg_col   = not sig_segbreak_inp ? NEO_DIM : (segbreak_up or segbreak_down) ? NEO_SIGNAL : NEO_DIM
    table.cell(panel, 0, 17, "Segment break",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 17, seg_state,
         text_color=seg_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    string pb_state = not sig_pullback_inp ? "off" : pullback_long ? "▲ LONG" : pullback_short ? "▼ SHORT" : "— wait"
    color  pb_col   = not sig_pullback_inp ? NEO_DIM : (pullback_long or pullback_short) ? NEO_SIGNAL : NEO_DIM
    table.cell(panel, 0, 18, "Pullback",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 18, pb_state,
         text_color=pb_col, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)

    string ct_state = not sig_microbreak_inp ? "off" : cont_long ? "▲ LONG" : cont_short ? "▼ SHORT" : "— wait"
    color  ct_col   = not sig_microbreak_inp ? NEO_DIM : cont_long ? NEO_BULL_ACCENT : cont_short ? NEO_BEAR_ACCENT : NEO_DIM
    table.cell(panel, 0, 19, "Continuation",
         text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 19, ct_state,
         text_color=ct_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    // === MTF ===
    if show_mtf_inp
        table.cell(panel, 0, 20, "MTF",
             text_color=NEO_WHITE, bgcolor=NEO_PANEL_SEP, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 20, "", bgcolor=NEO_PANEL_SEP)

        string mtf1_str = mtf1_dir == 1 ? "↗" : mtf1_dir == -1 ? "↘" : "·"
        mtf1_str := mtf1_str + " " + str.tostring(mtf1_ang, "+#.#;-#.#") + "°"
        color  mtf1_col = mtf1_dir == 1 ? NEO_BULL : mtf1_dir == -1 ? NEO_BEAR : NEO_DIM
        table.cell(panel, 0, 21, mtf1_tf + " / " + mtf2_tf,
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
        string mtf2_str = mtf2_dir == 1 ? "↗" : mtf2_dir == -1 ? "↘" : "·"
        mtf2_str := mtf2_str + " " + str.tostring(mtf2_ang, "+#.#;-#.#") + "°"
        table.cell(panel, 1, 21, mtf1_str + "  |  " + mtf2_str,
             text_color=mtf1_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

    // === Entry Score — Navigator's exclusive confluence algorithm ===
    // Closing row of the panel by design: everything above (Macro/Micro/Signals/
    // MTF) feeds into this one verdict number. Shown even below threshold so the
    // score reads as a live oscillator, not just a post-hoc "it fired" marker.
    if show_entry_inp
        table.cell(panel, 0, 22, "ENTRY SCORE · Navigator",
             text_color=NEO_WHITE, bgcolor=NEO_PANEL_SEP, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 22, "", bgcolor=NEO_PANEL_SEP)

        // Largest-remainder rounding: floor every component, then hand the
        // leftover points to the largest fractional parts — so the four
        // displayed integers ALWAYS sum to the displayed score. Independent
        // per-component rounding could drift ±1 and a careful reader would
        // catch the panel "not adding up".
        int d_align = int(math.floor(sc_align))
        int d_pos   = int(math.floor(sc_pos))
        int d_fit   = int(math.floor(sc_fit))
        int d_mtf   = int(math.floor(sc_mtf))
        float raw_sum = sc_align + sc_pos + sc_fit + sc_mtf
        int leftover = int(math.round(math.min(100.0, raw_sum))) - (d_align + d_pos + d_fit + d_mtf)
        float r_align = sc_align - d_align
        float r_pos   = sc_pos - d_pos
        float r_fit   = sc_fit - d_fit
        float r_mtf   = sc_mtf - d_mtf
        if leftover > 0
            for k = 1 to leftover
                if r_align >= r_pos and r_align >= r_fit and r_align >= r_mtf
                    d_align += 1
                    r_align := -1.0
                else if r_pos >= r_fit and r_pos >= r_mtf
                    d_pos += 1
                    r_pos := -1.0
                else if r_fit >= r_mtf
                    d_fit += 1
                    r_fit := -1.0
                else
                    d_mtf += 1
                    r_mtf := -1.0

        // In strict MTF mode the total is deliberately capped below the sum of
        // the components — say so on the label instead of looking like a bug.
        bool score_capped = entry_require_mtf_inp and sc_mtf < 25.0 and entry_score < math.min(100.0, raw_sum) - 0.5
        string entry_dir_str = entry_dir == 1 ? "↗ LONG" : "↘ SHORT"
        color  entry_score_col = entry_score >= entry_threshold_inp ? NEO_ENTRY : entry_score >= entry_threshold_inp - 15 ? NEO_SIGNAL : NEO_DIM
        string entry_score_str = str.tostring(math.round(entry_score)) + "/100  " + entry_dir_str
        table.cell(panel, 0, 23, "Score (thr " + str.tostring(entry_threshold_inp) + (score_capped ? ", capped)" : ")"),
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 23, entry_score_str,
             text_color=entry_score_col, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

        // Live Score Breakdown — the "why" behind the number, per component of
        // the winning side. A component lights up once it earns more than half
        // of its budget. No other channel tool shows its confluence math live.
        color brk_on  = NEO_WHITE
        color brk_off = NEO_DIM
        table.cell(panel, 0, 24, "· Alignment",
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 24, str.tostring(d_align) + "/35",
             text_color=sc_align > 17.5 ? brk_on : brk_off, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)
        table.cell(panel, 0, 25, "· Channel Position",
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 25, str.tostring(d_pos) + "/20",
             text_color=sc_pos > 10 ? brk_on : brk_off, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)
        table.cell(panel, 0, 26, "· Micro Fit",
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 26, str.tostring(d_fit) + "/20",
             text_color=sc_fit > 10 ? brk_on : brk_off, bgcolor=NEO_PANEL_ROW, text_size=size.small, text_halign=text.align_right)
        table.cell(panel, 0, 27, "· MTF Agreement",
             text_color=NEO_LABEL, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 27, str.tostring(d_mtf) + "/25",
             text_color=sc_mtf > 12.5 ? brk_on : brk_off, bgcolor=NEO_PANEL_BG, text_size=size.small, text_halign=text.align_right)

// ============================================================================
// SECTION 13 — ALERTS
// ============================================================================

bool segment_changed = barstate.isconfirmed and (active_dir != active_dir[1])

alertcondition(segment_changed and alert_segchange_inp,
     title="Segment Direction Changed",
     message="Trend Channel Navigator: segment changed on {{ticker}} ({{interval}})")

// Alerts reuse the exact fired flags from Section 11 (confirmed bar + cooldown),
// so an alert fires if and only if the corresponding marker event fires —
// regardless of whether markers are visible.
alertcondition(segbreak_fire and alert_segbreak_inp,
     title="Segment Break",
     message="Trend Channel Navigator: segment break on {{ticker}} ({{interval}})")

alertcondition(cont_fire and alert_microbreak_inp,
     title="Micro Continuation",
     message="Trend Channel Navigator: micro continuation on {{ticker}} ({{interval}})")

alertcondition(entry_fire and alert_entry_inp,
     title="Entry Score",
     message="Trend Channel Navigator: entry score confluence signal on {{ticker}} ({{interval}})")
````

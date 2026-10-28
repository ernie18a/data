# MTF RSI Synchrony | Rainbow Matrix

- url: https://www.tradingview.com/script/dLBodnwn-MTF-RSI-Synchrony-Rainbow-Matrix/
- type: indicator
- pine_id: PUB;63f93eaf494e4615ad55fe1d5af83415
- version: 4.0

## Description

GENERAL OVERVIEW
The MTF RSI Synchrony is a multi-timeframe RSI fusion oscillator that aggregates five independent RSI readings — one per Fibonacci-spaced timeframe — into a single weighted Master Line. Each per-timeframe RSI is also plotted as a "ghost line" that fades by distance to the Master: when the five timeframes align, the rainbow renders solid; when they diverge, the ghost lines spread visibly across the pane, making synchrony itself a visible density property rather than a number to compute.
The main goal of this indicator is to give traders a single integrated read of RSI across multiple horizons — without flipping between charts, mentally averaging values, or guessing which timeframe's RSI matters at the current decision point. Every line, color, and divergence event on the pane was derived from real RSI calculations on each native timeframe, not approximated from the current chart's resolution.
It computes the Master Line from five timeframes via Fibonacci-proportioned weights (peak weight on the macro middle TFs), classifies the result through an adaptive Fibonacci channel that builds Z-Breathing / Z-Alert / Z-Exhaustion / Black Swan zones around the Master, and runs a classic price↔RSI divergence engine on each of the 5 TFs plus the Master line independently. A 5-column MTF Legend Table surfaces every TF's state at a glance, with an antenna marker (📡) flagging the row whose timeframe matches the chart's native resolution.
This indicator was developed for traders who already understand RSI and divergence concepts and want to see them across multiple timeframes in a single visual, with automatic synchrony detection and an integrated classic divergence layer.


WHAT IS THE THEORY BEHIND THIS INDICATOR?
Most RSI implementations on TradingView operate on a single timeframe. They show you a value between 0 and 100 for the current chart and leave the multi-timeframe assessment to manual work — flipping between charts, sketching trendlines, or stacking multiple instances of the indicator on different intervals. This treats each timeframe as an isolated decision space.
The problem: institutional momentum is not isolated to one timeframe. The participants operating on the daily horizon see different RSI conditions than those operating on the weekly or 4-hour horizon. When the 15-minute RSI flips above 70 but the daily RSI is still neutral, the overbought signal is local — likely a counter-trend bounce. When the 15-minute RSI flips above 70 and the daily RSI also approaches the upper zone, the overbought signal is structurally agreed across horizons — far more likely to mark a multi-horizon exhaustion.
This indicator addresses that by extracting RSI from five user-configured timeframes simultaneously via request.security, fusing them via canonical Fibonacci weights (peak weight on the macro middle TFs), and rendering both the integrated Master signal and each contributing TF's individual reading on the same pane. The math of the per-TF extraction is standard RSI on the native bars — what makes it useful is doing it across five timeframes at once, weighting them by structural significance, and surfacing both the alignment and the per-TF divergences in a single visual.
The classic divergence layer addresses a parallel problem: textbook regular divergence (price↔RSI on the same timeframe) is a well-known reversal cue, but traders typically watch it on one timeframe at a time. By running pivot-based divergence detection independently on each of the 5 TFs and on the Master line, the indicator surfaces local divergences (on fast TFs — often noise) versus structural divergences (on slow TFs — often precede major reversals) in the same table view, with the Master line acting as the integrated read drawn directly on the chart.

MTF RSI SYNCHRONY FEATURES
The indicator includes 7 main features:
◇ Multi-Timeframe RSI Fusion Engine
◇ Adaptive Fibonacci Channel (Master Volatility Envelope)
◇ Hybrid Black Swan Zone (static or dynamic)
◇ Classic Divergence Detection Engine (per-TF + Master)
◇ MTF Legend Table with antenna marker
◇ Per-Timeframe RSI Length Customization
◇ Multilingual interface (5 languages) and full visual customization

MULTI-TIMEFRAME RSI FUSION ENGINE
🔹 What It Does
The core of the indicator. For each of the five configured timeframes, an independent RSI reading is extracted at its native resolution. The five readings are then fused into a single Master Line via canonical Fibonacci-proportioned weights.
🔹 Method
The extraction runs via request.security with lookahead=barmerge.lookahead_off to prevent repainting. Per-timeframe RSI uses Wilder's standard formulation. The Master is computed as a weighted average with the following Fibonacci weights:
◇ TF1 (Trigger, default 5m): 0.15
◇ TF2 (Intraday, default 15m): 0.20
◇ TF3 (Macro 1, default 60m): 0.25 (peak weight)
◇ TF4 (Macro 2, default 240m): 0.25 (peak weight)
◇ TF5 (Base, default Daily): 0.15
The peak weight sits on the macro middle TFs (TF3 + TF4), where institutional decisions consolidate. The Master is clamped to the 0–100 RSI range.
🔹 Ghost Line Rendering
Each per-timeframe RSI is plotted as a ghost line with transparency inversely proportional to its absolute distance from the Master. The fade sensitivity is configurable (default 3.5): at distance 0 the line is solid (transparency 20), at ~20 RSI points away it becomes effectively invisible. Synchrony emerges as a visible density property — when the five lines collapse toward the Master, the rainbow is solid; when they spread, the pane fills with translucent ghosts.

[image]https://www.tradingview.com/x/cIPNsOIg/[/image]

ADAPTIVE FIBONACCI CHANNEL
🔹 What It Does
The Master Line is wrapped in an adaptive volatility channel built from its own highest/lowest over a configurable lookback (default 50), EMA-smoothed (default 10). From the channel envelope, four Fibonacci-proportioned zones are derived above and below the channel midpoint:
◇ Z-Breathing (1.50σ proportion) — yellow (high) / green (low)
◇ Z-Alert (1.85σ anchor) — orange (high) / teal (low)
◇ Z-Exhaustion (2.75σ proportion) — red (high) / blue (low)
◇ Black Swan (3.85σ proportion) — purple (high) / aqua (low)
🔹 Why It Matters
The 30/50/70 lines of classic RSI are static — they don't adapt to the volatility regime of the current instrument or timeframe. The Fibonacci channel does. In a low-volatility regime, the Z-Exhaustion zone tightens and the script flags exhaustion at lower thresholds; in a high-volatility regime, the channel widens and only genuine outliers reach the extreme zones. The Master's position within the channel — color-coded continuously — is a regime-aware read on momentum saturation that the fixed 30/70 lines cannot provide.

HYBRID BLACK SWAN ZONE
🔹 What It Does
The Black Swan threshold operates in hybrid mode:
◇ OFF (default): classic 80/20 RSI extremes — the conventional Wilder oversold/overbought boundaries.
◇ ON: dynamic Fibonacci 3.85σ proportion of the Master channel — adapts to current volatility.
🔹 Method
When dynamic mode is enabled, the Black Swan High becomes osc_up4 = dyn_mid + (dist_up × 3.85/1.85), and the Low becomes dyn_mid − (dist_dn × 3.85/1.85). Both are clamped to [0, 100]. The threshold breathes with the channel — wider in volatile regimes, tighter in calm ones.
🔹 Visual Design
Black Swan zones render as a line + proximity-based glow only — NO fill is drawn underneath, by design. This is a hard rule of the indicator's visual grammar: every other zone (Breathing, Alert, Exhaustion) has a fill; Black Swan is line + glow only, making the extreme zone visually distinct from the gradient zones below it.

CLASSIC DIVERGENCE DETECTION ENGINE
🔹 What It Does
Regular divergence (price↔RSI on the same timeframe) is detected independently on each of the 5 timeframes and on the Master line:
◇ Bear divergence (top): price made higher high + RSI made lower high — momentum failing to confirm the new price peak; exhaustion warning.
◇ Bull divergence (bottom): price made lower low + RSI made higher low — momentum failing to confirm the new price trough; accumulation signal.
🔹 Method
Pivot detection runs via ta.pivothigh and ta.pivotlow with a configurable lookback (default 5 bars before and after). For each timeframe, the previous pivot and current pivot are compared on both price and RSI. A divergence is flagged when price and RSI move in opposite directions across the two pivots, gated by na guards to handle cold-start conditions.
🔹 Two Layers of Output
The detection produces two complementary outputs:
◇ Per-TF divergence flags are rendered in the Legend Table 'Div' column (🔺 bull / 🔻 bear / — none, color-coded). This gives granular per-horizon insight: which exact timeframe is showing divergence right now.
◇ Master divergence — the integrated MTF signal — is additionally drawn on the indicator pane as a line connecting the two pivots, with a "🔺 Bull Div Master" or "🔻 Bear Div Master" label at the second pivot. An alert is available (toggleable, ON by default).
🔹 Why Two Layers
Per-TF divergences answer "where is the divergence forming?" — fast TFs (TF1, TF2) often catch local noise; slow TFs (TF4, TF5) catch structurally significant turns. Master divergence answers "is the integrated MTF view showing exhaustion?" — Master fuses all five TFs into one signal weighted by significance, so its divergence is the consolidated read. The strongest setups occur when both layers agree: Master divergence drawn on the chart + multiple Legend Table 'Div' cells lighting up in the same direction.


MTF LEGEND TABLE
🔹 What It Shows
A compact 5-column table renders inside the indicator pane (force_overlay=false for mobile readability), with 8 rows:
◇ Row 0: title header (multilingual)
◇ Rows 1–5: per-timeframe data — color-coded RSI value, timeframe resolution, trend arrow (▲ rising / ▼ falling / ▬ flat with ±0.5 RSI point deadzone to avoid flicker), and classic divergence cell (🔺/🔻/—)
◇ Row 6: Master row — displays "🌈 Master (~XhYm)" where XhYm is the geometric weighted mean of the 5 active timeframes (e.g. ~1h11m for the default 5/15/60/240/D set), with the Master's RSI value, trend arrow, and divergence state
◇ Row 7: MTF Divergence status row — tracks RSI alignment between TF1 and TF5
🔹 Antenna Marker
An antenna marker (📡) appears at the end of the timeframe label on the row whose timeframe matches the chart's native resolution. Start the read at the antenna row — that's your chart's RSI — then scan up to faster TFs and down to slower TFs to see whether they confirm or contradict the current read.
🔹 MTF Divergence Status Row (TF1 ↔ TF5)
Separate from the classic per-TF divergence: the status row at the bottom tracks RSI alignment between the fastest and slowest configured timeframes:
◇ Aligned (TF1 and TF5 in the same zone): trend continuation, no MTF divergence.
◇ Strong Divergence (TF1 ≥ 70 vs TF5 ≤ 30, or mirrored): fast and slow timeframes telling completely opposite stories. Common at major turning points.
◇ Moderate Divergence (TF1 ≥ 65 vs TF5 ≤ 40, or mirrored): partial misalignment between fast and slow.

PER-TIMEFRAME RSI LENGTH CUSTOMIZATION
🔹 What It Does
RSI period defaults to 14 globally — Wilder's canonical setting. Each of the 5 timeframes has an optional length override: zero means inherit the global default, any positive integer means use that period for that timeframe only.
🔹 Why It Helps
Real-world strategies often want different RSI sensitivities at different horizons. Scalpers use 7-9 on the trigger TF for fast signals while keeping 14 on slower TFs for stability. Swing traders use 14-21 on intraday TFs and 21+ on the daily for smoother reads. Connors-style strategies use 2 on the trigger for mean-reversion. The hybrid pattern keeps the settings panel clean for casual users (one input controls all) while letting power users specialize per TF when needed.

MULTILINGUAL INTERFACE
The indicator supports five languages for the HUD display, Legend Table headers, and alert messages: English (default), Português, Español, Русский, and 中文 (Chinese). Code, comments, and configuration tooltips remain in English regardless of the selected language. Tech abbreviations (RSI, MTF, HTF, TF) stay Latin in all language contexts — they are universally recognized in trading and translation would add noise.
For reference, the multilingual coverage includes:
◇ HUD title and all row labels
◇ Trend arrows (universal: ▲▼▬)
◇ Divergence cells (universal: 🔺🔻—)
◇ MTF Divergence status row (Aligned / Strong / Moderate, with Top/Bottom directional labeling)
◇ All alert messages including the new classic divergence alerts

HOW TO USE
This indicator is not a signal generator. It is a structural map: it tells you where RSI sits across multiple horizons, how aligned (or divergent) those horizons are, and where classic price↔RSI divergence is forming.
🔹 Reading the Rainbow
◇ Solid rainbow + Master near equilibrium (30–70 zone): no clear signal. Trending behavior absent.
◇ Solid rainbow + Master in Z-Alert (orange/teal): trend in motion across all horizons. Look for follow-through confirmation.
◇ Solid rainbow + Master in Z-Exhaustion (red/blue): elevated probability of mean reversion. Multiple horizons agreeing on saturation.
◇ Master touches Black Swan (purple/aqua glow): statistically rare overshoot. High-probability reversal setup, especially when the MTF Divergence row also fires Strong.
◇ Ghost lines visibly spread far from Master: synchrony breakdown. Wait for re-convergence before high-conviction entries.
🔹 Reading the Legend Table
◇ Antenna row (📡): your chart's native TF. Start there.
◇ Scan above the antenna: faster TFs. If they're in extremes opposite to the antenna, the local signal is conflicted.
◇ Scan below the antenna: slower TFs. If they're aligned with the antenna, the structural bias confirms.
◇ Master row: the integrated read. The "~XhYm" label tells you where Master sits in the TF spectrum.
🔹 Reading the Classic Divergence Layer
◇ Single TF lit up (e.g. only TF2 shows 🔻): local divergence. Often noise on fast TFs.
◇ Multiple TFs lit up in the same direction: structurally significant. Confluence of divergence across horizons.
◇ Master divergence drawn on chart + 2 or more TFs in same direction: high-conviction reversal setup. The strongest signal this indicator produces.
◇ Divergence appearing on slow TFs (TF4 / TF5) while fast TFs are quiet: often precedes major reversals — slow-horizon participants are pulling away before fast-horizon ones notice.
🔹 Tactical Reading
◇ Master in Z-Alert + MTF status Aligned: with-trend continuation setup.
◇ Master in Z-Exhaustion + Bear Div drawn on chart + 2 TFs 🔻: short setup with multi-horizon confirmation.
◇ Master at Black Swan Low + Bull Div drawn on chart + Strong MTF Divergence (TF1 ≤ 30 vs TF5 ≥ 70 mirrored): rare confluence of multiple exhaustion signals.

INPUTS EXPLAINED
🔹 System Language
Display language for the HUD and alert messages. Options: English (default), Português, Español, Русский, 中文 (Chinese).
🔹 Multi-Timeframe (TF1 to TF5)
Configure each of the five timeframes to scan. Defaults: 5m / 15m / 60m / 240m / Daily. Plus AI Auto-Sync option that adjusts the 5 TFs based on chart resolution.
🔹 Default RSI Length + 5 Per-TF Overrides
Default 14 applied globally; per-TF override is 0 by default (inherit). Set override > 0 to specialize per TF.
🔹 Dynamic Black Swan Mode
OFF (default): static 80/20 thresholds. ON: dynamic Fibonacci 3.85σ proportion of the Master channel.
🔹 Dynamic Channel Lookback + Smoothing
Lookback for highest/lowest of Master (default 50). EMA smoothing applied to the channel envelope (default 10).
🔹 Divergence Pivot Lookback
Lookback (bars before/after) for the classic divergence pivot detection. Default 5 — matches most community divergence indicators.
🔹 TF Colors + Show/Hide Toggles
Color and visibility for each of the 5 ghost lines. Hiding a TF does NOT remove it from the Master fusion — the calculation continues; visibility is purely visual.
🔹 Ghost Fade Sensitivity
Higher = ghost lines fade more aggressively as they diverge from the Master. Default 3.5 (invisible at ~20 RSI points apart).
🔹 Show Master Line / Fills / Black Swan / Channel / Legend Table / Static Levels / Div Column / Div Chart Line
Independent toggles for each visual layer.
🔹 Legend Table Position + Font Sizes
Position of the table (four corners) and separate font sizes for data rows and label rows.
🔹 Alert Toggles
Master crosses Black Swan High / Low — fires when Master crosses the threshold.
Strong MTF Divergence — fires when TF1 vs TF5 enter opposite extremes.
Master enters Z-Exhaustion — fires when Master enters the red/blue zone (OFF by default to avoid overlap with Black Swan alerts).
Master Classic Divergence — fires when classic bear or bull divergence is detected on the Master line (ON by default).

IMPORTANT NOTES
The MTF RSI Synchrony works on any timeframe. The default radar configuration (5m/15m/60m/240m/D) is calibrated for intraday and swing trading on liquid instruments. For position trading or scalping, the radar timeframes can be reconfigured to scan longer or shorter horizons respectively, or AI Auto-Sync can be enabled to let the engine pick automatically.
The script makes 10 request.security calls in total (5 for the RSI extraction + 5 for the per-TF divergence detection). On low-volatility chart resolutions or weaker hardware, chart load may take a moment longer than for a single-TF RSI; this is expected and normal.
Alerts fire once per confirmed bar (alert.freq_once_per_bar + barstate.isconfirmed gating). Historical bars never repaint after they close. The live bar updates intra-bar as expected for a real-time indicator.
The Fibonacci channel calibration (ratios 1.50 / 1.85 / 2.75 / 3.85) is the canonical Rainbow Matrix ratio set, also used in other portfolio scripts for consistency.
Pine Script v6. Open-source under Mozilla Public License 2.0.

UNIQUENESS
The MTF RSI Synchrony is unique in three ways. First, it performs RSI extraction across five timeframes simultaneously via request.security with Fibonacci-proportioned weights — the integrated Master Line is not a smoothed version of one TF but a true weighted fusion of five independent RSIs, with peak weight on the macro middle TFs where institutional decisions consolidate. Second, the per-timeframe RSIs are rendered as fade-by-distance ghost lines around the Master, transforming synchrony itself into a visible density property — when the timeframes align the rainbow is solid, when they diverge the ghost lines spread visibly across the pane, without requiring the trader to read numbers. Third, the classic divergence detection runs in parallel on each of the 5 timeframes plus the Master line, producing two complementary outputs: a per-TF Legend Table column for granular per-horizon insight and a Master-line chart visual (line connecting pivots + label) for the integrated MTF signal. The combination of weighted multi-timeframe fusion, density-based synchrony visualization, and two-layer divergence detection produces a structural map of RSI behavior that single-timeframe RSI indicators cannot provide — particularly at decision points where multiple horizons converge or where slow-horizon divergences emerge before they reach fast-horizon attention.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rainbowmatrix
//
// ════════════════════════════════════════════════════════════════════════════════
// MTF RSI SYNCHRONY
//
// A multi-timeframe RSI fusion oscillator that aggregates five independent RSI
// readings — one per Fibonacci-spaced timeframe — into a single weighted Master
// Line, with each per-timeframe RSI plotted as a ghost line that fades by
// distance to the Master. When the five timeframes align, the rainbow is solid;
// when they diverge, the ghost lines spread visibly across the pane. A compact
// MTF Legend Table surfaces all five timeframes' RSI values, trend direction,
// classic divergence state, and zone classification simultaneously, with an
// antenna marker flagging the row whose timeframe matches the chart's native
// resolution. A hybrid Black Swan zone (static 80/20 or dynamic Fibonacci-scaled
// channel) flags institutional exhaustion as it forms. A classic divergence
// detection engine surfaces regular price↔RSI divergences both per-timeframe
// (in the Legend Table) and on the Master line itself (drawn directly on the
// chart with optional alert). RSI period can be set globally or overridden
// per-timeframe for traders running asymmetric strategies (e.g. RSI(7) on the
// trigger TF + RSI(14) on slower TFs).
//
// METHOD:
//   1. For each of 5 user-configured timeframes (default 5/15/60/240/D), the
//      script extracts via request.security() an independent RSI(14) reading
//      with lookahead=barmerge.lookahead_off for anti-repaint integrity.
//   2. The five per-timeframe RSI values are aggregated via canonical Fibonacci
//      weights (0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on macro TF3/TF4
//      where institutional decisions consolidate) into the weighted Master Line.
//   3. Each per-timeframe RSI is plotted as a ghost line with transparency
//      inversely proportional to its absolute distance from the Master, using
//      the canonical fade-by-distance pattern. Default sensitivity 3.5 makes
//      lines effectively invisible at ~20 RSI points away from the Master —
//      synchrony itself becomes a visible density property of the rainbow.
//   4. The Master is plotted against an adaptive Fibonacci channel built from
//      its own highest/lowest over a configurable lookback, smoothed by EMA.
//      Channel boundaries: Z-Breathing (1.50σ), Z-Alert (1.85σ anchor),
//      Z-Exhaustion (2.75σ), Black Swan (3.85σ).
//   5. Black Swan zones operate in hybrid mode: static 80/20 by default
//      (classic RSI extremes), or dynamic adapt-to-volatility via the
//      Fibonacci 3.85σ proportion of the Master channel when toggled.
//   6. The MTF Legend Table displays per-timeframe data: a color-coded RSI value
//      using the canonical Rainbow Palette zone classification, a trend arrow
//      (▲ rising, ▼ falling, ▬ flat — ±0.5 RSI point deadzone to avoid flicker),
//      a classic divergence cell (🔺 bull / 🔻 bear / — none), plus a Master row
//      showing the weighted fusion with a dynamic "~XhYm" suffix that reflects
//      the geometric mean of the 5 active timeframes (e.g. "~1h11m" for the
//      default 5/15/60/240/D set). A status row at the bottom tracks RSI alignment
//      between TF1 and TF5: Strong (≥ 70 vs ≤ 30, or mirrored) and Moderate
//      (≥ 65 vs ≤ 40) MTF divergences with directional Top / Bottom labeling.
//      An antenna marker (📡) flags the row whose timeframe equals the chart's
//      native resolution.
//   7. Classic Divergence Detection runs independently on each of the 5
//      timeframes and on the Master line. Regular divergence only (bear top:
//      price made higher high + RSI made lower high; bull bottom: price made
//      lower low + RSI made higher low). Pivot lookback is user-configurable
//      (default 5 bars). Per-TF results render in the Legend Table 'Div'
//      column. Master divergence — the integrated MTF signal — is additionally
//      drawn on the indicator pane as a line connecting the two pivots, with
//      a "🔺 Bull Div Master" or "🔻 Bear Div Master" label, plus an optional
//      alert (ON by default).
//
// ORIGINALITY:
//   Most RSI implementations on TradingView operate on a single timeframe and
//   apply a generic 0-100 reading without expressing how that single value
//   compares to slower or faster timescales. MTF RSI Synchrony fuses five
//   timeframes via Fibonacci-proportioned weights, expresses synchrony as a
//   visible "rainbow density" property (solid when aligned, spread-out when
//   diverging), and surfaces fast-vs-slow MTF divergences as discrete events
//   ranked by intensity. The Fibonacci channel applied to the Master adapts
//   the Black Swan threshold to current volatility — replacing the fixed
//   80/20 thresholds with a self-calibrating extreme zone. Classic price↔RSI
//   divergence detection runs in parallel on each of the 5 timeframes plus
//   the Master line — the per-TF results surface in the Legend Table while
//   the Master divergence is drawn directly on the chart, layering granular
//   per-timeframe insight with an integrated MTF signal. RSI period can be
//   set globally with optional per-timeframe overrides (0 = inherit default),
//   supporting asymmetric strategies where different timescales benefit from
//   different RSI sensitivities (scalping 7-9, swing 14-21, Connors 2).
//
// HOW TO USE:
//   - Master between 30 and 70 with all 5 lines solid: equilibrium, no signal.
//   - Master entering Z-Alert (orange/teal): trend in motion — watch for
//     follow-through confirmation across timeframes.
//   - Master in Z-Exhaustion (red/blue): elevated probability of mean reversion.
//   - Master touches Black Swan (purple/aqua glow): statistically rare overshoot
//     with high-probability reversal setup, especially when HUD confirms
//     aligned extremes across TF1 and TF5.
//   - Legend Table status row lit Strong MTF Divergence (TF1 ≥ 70 vs TF5 ≤ 30 or
//     mirrored): fast and slow timeframes telling opposite stories — common
//     at major turning points.
//   - Ghost lines visibly spread far from Master: synchrony breakdown — wait
//     for re-convergence before high-conviction entries.
//   - Master divergence drawn on the chart (🔻 bear top / 🔺 bull bottom):
//     classic price↔RSI divergence on the integrated MTF view. Strongest
//     signals occur when multiple Legend Table 'Div' cells light up the same
//     direction simultaneously — Master + 2 or more TF agreement is a
//     high-conviction reversal setup.
//   - Legend Table 'Div' column scan: read top-down (TF1 → TF5 → Master) to see
//     where divergence is forming. Divergence appearing on slow TFs (TF4/TF5)
//     while fast TFs are quiet often precedes major reversals; divergence only
//     on fast TFs may be local noise.
//   - Legend Table reading: the antenna marker (📡) shows your chart's native
//     timeframe — start your read there, then scan up/down the table to see
//     whether faster/slower timeframes confirm or contradict the current bias.
//   - Per-TF RSI Length overrides (advanced): leave Default at 14 for standard
//     reads. Set a TF-specific override > 0 to specialize — e.g. RSI(7) on the
//     Trigger TF for fast scalping signals while keeping 14 on slower TFs for
//     stability. Set back to 0 to inherit the default.
//
// MULTILINGUAL UI:
//   HUD labels, alert messages (including the new classic divergence alerts),
//   and Legend Table headers are translated to 5 languages (English, Português,
//   Español, Русский, 中文) via the System Language input. Configuration
//   tooltips, variable names and code comments remain in English by convention.
//   Tech abbreviations (RSI, MTF, HTF, TF) stay Latin in all language contexts.
//
// ════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("MTF RSI Synchrony | Rainbow Matrix",
     overlay         = false,
     max_bars_back   = 1440,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 500)

// ========================================================================================================
// COLOR PALETTE (Rainbow Matrix canonical — do NOT change)
// ========================================================================================================
c_up_4 = color.purple     // Black Swan High (extreme overbought)
c_up_3 = color.red        // Z-Exhaustion High
c_up_2 = color.orange     // Z-Alert High
c_up_1 = color.yellow     // Z-Breathing High
c_dn_1 = color.green      // Z-Breathing Low
c_dn_2 = color.teal       // Z-Alert Low
c_dn_3 = color.blue       // Z-Exhaustion Low
c_dn_4 = color.aqua       // Black Swan Low (extreme oversold)
c_neutral = color.gray
c_black   = color.black

// ========================================================================================================
// GLOBAL SETTINGS
// ========================================================================================================
g_global = "GLOBAL SETTINGS"
language = input.string("English", "System Language",
     options = ["English", "Português", "Español", "Русский", "中文 (Chinese)"],
     group   = g_global,
     tooltip = "Language for HUD labels and alert messages. Affects only the on-chart UI text; code, comments, and configuration tooltips remain in English.")

string _l = language == "Português" ? "PT" : language == "Español" ? "ES" : language == "Русский" ? "RU" : language == "中文 (Chinese)" ? "ZH" : "EN"

font_size_table  = input.string("Small", "Table Font Size",  options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the per-timeframe and Master data rows of the MTF Legend Table (RSI values and trend arrows).")
font_size_labels = input.string("Small", "Labels Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_global, tooltip = "Font size for the header and status rows of the MTF Legend Table.")

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

sz_tbl = f_size(font_size_table)
sz_lbl = f_size(font_size_labels)

// ========================================================================================================
// SYMBOL OVERRIDE (lock the analyzed symbol independently of the chart)
// ========================================================================================================
g_symbol = "SYMBOL"
symbol_override = input.symbol("", "Symbol Override (empty = follow chart)",
     group   = g_symbol,
     tooltip = "Lock the symbol analyzed by the indicator. Leave EMPTY to follow the chart's symbol (default behavior). When set (e.g. BINANCE:BTCUSDT), all 5 MTF RSI fetches, per-TF divergence detection and Master divergence price pivots keep reading that symbol even if you switch the chart to another asset.")
show_symbol_label = input.bool(true, "Show Active Symbol Label",
     group   = g_symbol,
     tooltip = "Display the symbol currently being analyzed on the indicator pane. A lock icon (🔒) with orange text indicates an active Symbol Override. Position is configurable below.")
sym_label_pos = input.string("Top Left", "Symbol Label Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = g_symbol, tooltip = "Corner of the indicator pane where the Active Symbol Label renders. If it collides with the Legend Table or another panel widget, pick a different corner.")

string active_sym = symbol_override != "" ? symbol_override : syminfo.tickerid
bool   sym_locked = symbol_override != ""

// ========================================================================================================
// MULTI-TIMEFRAME
// ========================================================================================================
g_tf = "MULTI-TIMEFRAME"
auto_tf    = input.bool(false, "AI Auto-Sync TFs", group = g_tf, tooltip = "When ON, the engine auto-adjusts the five timeframes based on your current chart resolution to keep the Fibonacci spacing meaningful. When OFF, your manual values below are used.")
m_tf1      = input.string("5",   "TF 1 — Trigger (Minutes, D, W)",    group = g_tf, tooltip = "Fastest timeframe. Default 5m. Weight 0.15 in the Master fusion.")
m_tf2      = input.string("15",  "TF 2 — Intraday (Minutes, D, W)",   group = g_tf, tooltip = "Intraday timeframe. Default 15m. Weight 0.20.")
m_tf3      = input.string("60",  "TF 3 — Macro 1 (Minutes, D, W)",    group = g_tf, tooltip = "First macro reference. Default 60m (1h). Weight 0.25 (peak).")
m_tf4      = input.string("240", "TF 4 — Macro 2 (Minutes, D, W)",    group = g_tf, tooltip = "Second macro reference. Default 240m (4h). Weight 0.25 (peak).")
m_tf5      = input.string("D",   "TF 5 — Base/Daily (Minutes, D, W)", group = g_tf, tooltip = "Slowest anchor. Default Daily. Weight 0.15.")
rsi_length_default = input.int(14, "Default RSI Length", minval = 2, group = g_tf, tooltip = "Default RSI period applied to all 5 timeframes UNLESS a per-TF override below is set to a non-zero value. Most users keep this at 14 (Wilder canonical). Scalpers often use 7-9; swing traders 14-21; Connors strategy uses 2.")
rsi_len_tf1 = input.int(7, "TF1 RSI Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF RSI period override. 0 = inherit from Default RSI Length above. Set to a positive integer to use a different RSI period for this timeframe only. Example: use 7 here for fast scalping read on the Trigger TF while keeping 14 on slower TFs.")
rsi_len_tf2 = input.int(10, "TF2 RSI Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF RSI period override. 0 = inherit from Default RSI Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
rsi_len_tf3 = input.int(14, "TF3 RSI Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF RSI period override. 0 = inherit from Default RSI Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
rsi_len_tf4 = input.int(14, "TF4 RSI Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF RSI period override. 0 = inherit from Default RSI Length above. Set to a positive integer to use a different RSI period for this timeframe only.")
rsi_len_tf5 = input.int(21, "TF5 RSI Length Override (0 = use default)", minval = 0, group = g_tf, tooltip = "Per-TF RSI period override. 0 = inherit from Default RSI Length above. Set to a positive integer to use a different RSI period for this timeframe only. Example: use 21 here on the Base TF for a smoother slow read.")

string tf_1 = ""
string tf_2 = ""
string tf_3 = ""
string tf_4 = ""
string tf_5 = ""

if auto_tf
    if timeframe.isseconds or (timeframe.isintraday and timeframe.multiplier <= 5)
        tf_1 := "5",   tf_2 := "15",  tf_3 := "60",  tf_4 := "240", tf_5 := "D"
    else if timeframe.isintraday and timeframe.multiplier <= 15
        tf_1 := "15",  tf_2 := "60",  tf_3 := "240", tf_4 := "D",   tf_5 := "W"
    else if timeframe.isintraday and timeframe.multiplier <= 60
        tf_1 := "60",  tf_2 := "240", tf_3 := "D",   tf_4 := "W",   tf_5 := "M"
    else
        tf_1 := "240", tf_2 := "D",   tf_3 := "W",   tf_4 := "M",   tf_5 := "M"
else
    tf_1 := m_tf1, tf_2 := m_tf2, tf_3 := m_tf3, tf_4 := m_tf4, tf_5 := m_tf5

// ========================================================================================================
// ENGINE
// ========================================================================================================
g_engine = "ENGINE"
dynamic_extremes = input.bool(true, "Dynamic Black Swan Mode",
     group = g_engine,
     tooltip = "OFF (default): Black Swan zones at fixed 80/20 (classic RSI extremes). ON: Black Swan zones adapt dynamically to the Master Line's volatility using the canonical Fibonacci 3.85σ proportion.")
lookback_dyn = input.int(12, "Dynamic Channel Lookback",  minval = 10, group = g_engine, tooltip = "Lookback window for highest/lowest of the Master Line. Larger = smoother channel envelope.")
smooth_dyn   = input.int(12, "Dynamic Channel Smoothing", minval = 1,  group = g_engine, tooltip = "EMA smoothing applied to the dynamic channel envelope. Larger = slower response.")
div_lookback = input.int(4,  "Divergence Pivot Lookback", minval = 3, maxval = 20, group = g_engine, tooltip = "Pivot lookback (bars before/after) for classic price↔RSI divergence detection. Lower = more sensitive (smaller pivots), higher = more confirmed (larger pivots). Community standard is 5; this script defaults to 4 for slightly faster pivot confirmation.")

// ========================================================================================================
// VISUALIZATION
// ========================================================================================================
g_visual = "VISUALIZATION"
color_tf1 = input.color(c_up_1, "TF 1 Color (Trigger)",  group = g_visual, inline = "tf12", tooltip = "Color of the TF1 (fastest) RSI ghost line.")
color_tf2 = input.color(c_up_2, "TF 2 Color (Intraday)", group = g_visual, inline = "tf12", tooltip = "Color of the TF2 RSI ghost line.")
color_tf3 = input.color(c_up_3, "TF 3 Color (Macro 1)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF3 RSI ghost line.")
color_tf4 = input.color(c_dn_3, "TF 4 Color (Macro 2)",  group = g_visual, inline = "tf34", tooltip = "Color of the TF4 RSI ghost line.")
color_tf5 = input.color(c_dn_2, "TF 5 Color (Base)",     group = g_visual, tooltip = "Color of the TF5 RSI ghost line.")

show_tf1 = input.bool(true, "Show TF1 Ghost Line (Trigger)",  group = g_visual, tooltip = "Hide/show the TF1 RSI ghost line. The TF still contributes to the Master fusion regardless of this toggle — this is purely visual.")
show_tf2 = input.bool(true, "Show TF2 Ghost Line (Intraday)", group = g_visual, tooltip = "Hide/show the TF2 RSI ghost line. TF data still feeds the Master.")
show_tf3 = input.bool(false, "Show TF3 Ghost Line (Macro 1)",  group = g_visual, tooltip = "Hide/show the TF3 RSI ghost line. TF data still feeds the Master.")
show_tf4 = input.bool(true, "Show TF4 Ghost Line (Macro 2)",  group = g_visual, tooltip = "Hide/show the TF4 RSI ghost line. TF data still feeds the Master.")
show_tf5 = input.bool(true, "Show TF5 Ghost Line (Base)",     group = g_visual, tooltip = "Hide/show the TF5 RSI ghost line. TF data still feeds the Master.")
ghost_sensitivity = input.float(3.5, "Ghost Fade Sensitivity", minval = 0.5, maxval = 10.0, step = 0.5, group = g_visual, tooltip = "Higher = ghost lines fade more aggressively as they diverge from the Master. Lower = lines stay solid longer. Default 3.5 (dist=20 RSI points → invisible).")

show_master_line    = input.bool(true, "Show Master Line (Rainbow)",             group = g_visual, tooltip = "Plot the weighted Master RSI line, colored by zone using the canonical Rainbow Palette.")
show_fills          = input.bool(true, "Show Rainbow Fills",                     group = g_visual, tooltip = "Color the 6 Fibonacci bands around the dynamic channel (Breathing / Alert / Exhaustion, both sides).")
show_blackswan      = input.bool(true, "Show Black Swan Lines + Glow",           group = g_visual, tooltip = "Plot the Black Swan High/Low lines with proximity-based glow. No fill underneath (line + glow only).")
show_dyn_channel    = input.bool(true, "Show Dynamic Channel Envelope",          group = g_visual, tooltip = "Plot the dashed dynamic channel (Up / Mid / Down) that adapts to the Master's recent volatility.")
show_legend_table = input.bool(true, "Show MTF Legend Table",         group = g_visual, tooltip = "Show the MTF Legend Table on the indicator pane. Displays all 5 timeframes with RSI value, trend arrow and zone color, plus the weighted Master row and a divergence summary row. An antenna marker (📡) flags the row whose timeframe matches the chart's native resolution.")
show_div_column   = input.bool(true, "Show Divergence Column",        group = g_visual, tooltip = "Show the 'Div' column in the MTF Legend Table. Displays per-timeframe classic divergence detection: 🔺 = bull (price made lower low + RSI made higher low), 🔻 = bear (price made higher high + RSI made lower high), — = no active divergence. When OFF, divergence cells render empty (column space preserved).")
show_state_column = input.bool(true, "Show State Column",             group = g_visual, tooltip = "Show the 'State' column in the MTF Legend Table. Displays per-timeframe named RSI state classification: EXHAUSTED (≥85 — climax top) / OVERBOUGHT (71-85) / BULLISH (62-71) / NEUTRAL (38-62) / BEARISH (29-38) / OVERSOLD (15-29) / CAPITULATION (≤15 — climax bottom). Color-coded by zone via the same thermal matrix as the Value column. When OFF, state cells render empty (column space preserved).")
show_div_chart_line = input.bool(true, "Show Master Divergence Chart Line", group = g_visual, tooltip = "Draw a connecting line between the two pivots that form each Master divergence event, plus a label at the second pivot (🔺 bull / 🔻 bear). Master divergence integrates the weighted view across all 5 timeframes — see the 'Div' column for per-TF breakdown.")
legend_pos        = input.string("Bottom Right", "Legend Table Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = g_visual, tooltip = "Position of the MTF Legend Table on the indicator pane. Four corners available.")
show_div_markers  = input.bool(true, "Show Divergence Event Markers", group = g_visual, tooltip = "Plot directional triangle markers when a Strong or Moderate MTF Divergence is detected. ▼ at the top (Top divergences = potential reversal from highs); ▲ at the bottom (Bottom divergences = potential reversal from lows). Strong = saturated colors (red / green); Moderate = transitional colors (orange / teal). Markers persist while the divergence condition holds. Independent of the Strong Divergence alert toggle in the ALERTS group.")
div_markers_pos   = input.string("Indicator Pane", "Divergence Markers Position", options = ["Indicator Pane", "Chart Overlay"], group = g_visual, tooltip = "Where to render the divergence markers. \"Indicator Pane\" = top/bottom edges of the oscillator pane (next to the Master line); \"Chart Overlay\" = above/below the price bars on the main chart.")
show_static_levels  = input.bool(true, "Show Static Reference Lines", group = g_visual, tooltip = "Plot the classic RSI reference levels (Overbought / 50 midline / Oversold) as subtle dotted guides. Overbought and Oversold are configurable below; the 50 midline is fixed.")
level_high = input.float(70.0, "Overbought Level", minval = 50.0, maxval = 100.0, step = 1.0, group = g_visual, inline = "lvl", tooltip = "Overbought reference level (classic 70). Drawn as the red dotted guide and the extended-right line.")
level_low  = input.float(30.0, "Oversold Level",   minval = 0.0,  maxval = 50.0,  step = 1.0, group = g_visual, inline = "lvl", tooltip = "Oversold reference level (classic 30). Drawn as the green dotted guide and the extended-right line.")
show_level_glow = input.bool(false, "Static Levels Glow", group = g_visual, tooltip = "Optional GLOW on the Overbought/Oversold reference lines using the canonical fade-by-distance pattern: the glow intensifies as the Master RSI approaches the level (same behavior as the Black Swan glow).")

// ========================================================================================================
// ALERTS
// ========================================================================================================
g_alerts = "ALERTS"
alert_blackswan_high = input.bool(true,  "Alert on Master crossing Black Swan High", group = g_alerts, tooltip = "Fires once per bar when the Master RSI crosses ABOVE the Black Swan High (80 or dynamic).")
alert_blackswan_low  = input.bool(true,  "Alert on Master crossing Black Swan Low",  group = g_alerts, tooltip = "Fires once per bar when the Master RSI crosses BELOW the Black Swan Low (20 or dynamic).")
alert_bs_glow_off_high = input.bool(true, "Alert on Black Swan High glow extinguishing", group = g_alerts, tooltip = "Fires when the Black Swan High (purple) glow extinguishes — the Master RSI pulled away from the line after having lit the glow. Companion to the crossing alert: cross = extreme reached; glow-off = extreme episode fading. Hysteresis prevents flicker: the glow counts as LIT at transparency <= 70 and EXTINGUISHED at >= 90.")
alert_bs_glow_off_low  = input.bool(true, "Alert on Black Swan Low glow extinguishing",  group = g_alerts, tooltip = "Fires when the Black Swan Low (aqua) glow extinguishes — the Master RSI pulled away from the line after having lit the glow. Companion to the crossing alert: cross = extreme reached; glow-off = extreme episode fading. Hysteresis prevents flicker: the glow counts as LIT at transparency <= 70 and EXTINGUISHED at >= 90.")
alert_divergence     = input.bool(true,  "Alert on STRONG MTF Divergence",           group = g_alerts, tooltip = "Fires when TF1 and TF5 reach opposite RSI extremes (≥70 vs ≤30).")
alert_master_extreme = input.bool(false, "Alert on Master entering Z-Exhaustion zone", group = g_alerts, tooltip = "Fires when the Master RSI enters the Z-Exhaustion zone (red high / blue low).")
alert_divergence_native = input.bool(true, "Alert on Master Classic Divergence",      group = g_alerts, tooltip = "Fires when classic divergence is detected on the Master line (price↔RSI on the chart timeframe). Master integrates the weighted MTF view, so this alert captures the most synthesized divergence signal. For per-TF breakdown, see the 'Div' column in the Legend Table.")

// ========================================================================================================
// HELPER FUNCTIONS
// ========================================================================================================

// Canonical weighted MTF average (Fibonacci-proportioned weights, peak on macro TF3/TF4)
// Weights: 0.15 / 0.20 / 0.25 / 0.25 / 0.15 — peak weight on macro (TF3 / TF4)
f_avg5_weighted(v1, v2, v3, v4, v5) =>
    w1 = 0.15
    w2 = 0.20
    w3 = 0.25
    w4 = 0.25
    w5 = 0.15
    w_total = (na(v1) ? 0.0 : w1) + (na(v2) ? 0.0 : w2) + (na(v3) ? 0.0 : w3) + (na(v4) ? 0.0 : w4) + (na(v5) ? 0.0 : w5)
    w_total > 0 ? (nz(v1) * w1 + nz(v2) * w2 + nz(v3) * w3 + nz(v4) * w4 + nz(v5) * w5) / w_total : na

// Generic fade-by-distance glow (transparency increases with distance from reference)
// Returns transparency: 20 = solid (current at reference) → 95 = invisible (current ≥ range_unit away)
f_calc_glow(float current_value, float reference_value, float range_unit) =>
    int(95 - (math.max(0.0, math.min(1.0, 1.0 - (math.abs(current_value - reference_value) / math.max(range_unit, 0.000001)))) * 75))

// RSI-scale thermal matrix — maps a 0-100 RSI value to a Rainbow Palette color
// Thresholds use the brand's canonical RSI row classification (62 / 71 / 85 and 38 / 29 / 15, midpoint 50)
f_termal_matrix_rsi(float val) =>
    color c = c_neutral
    if not na(val)
        if val >= 85
            c := c_up_4
        else if val >= 71
            c := c_up_3
        else if val >= 62
            c := c_up_2
        else if val >= 50
            c := c_up_1
        else if val > 38
            c := c_dn_1
        else if val > 29
            c := c_dn_2
        else if val > 15
            c := c_dn_3
        else
            c := c_dn_4
    c

f_position(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// Classic divergence detection (regular only — bear top + bull bottom).
// Returns [bearDiv, bullDiv] booleans. Used inside request.security per-TF
// and directly on the Master series. Uses ta.valuewhen to capture pivot values
// at pivot bars (lookback shift) and compare current vs previous pivots.
f_classic_divergence(simple int length, simple int lookback) =>
    float rsi_local = ta.rsi(close, length)
    bool phFound = not na(ta.pivothigh(rsi_local, lookback, lookback))
    bool plFound = not na(ta.pivotlow(rsi_local, lookback, lookback))

    float rsi_ph_curr   = ta.valuewhen(phFound, rsi_local[lookback], 0)
    float rsi_ph_prev   = ta.valuewhen(phFound, rsi_local[lookback], 1)
    float price_ph_curr = ta.valuewhen(phFound, high[lookback], 0)
    float price_ph_prev = ta.valuewhen(phFound, high[lookback], 1)

    float rsi_pl_curr   = ta.valuewhen(plFound, rsi_local[lookback], 0)
    float rsi_pl_prev   = ta.valuewhen(plFound, rsi_local[lookback], 1)
    float price_pl_curr = ta.valuewhen(plFound, low[lookback], 0)
    float price_pl_prev = ta.valuewhen(plFound, low[lookback], 1)

    bool bearDiv = phFound and not na(rsi_ph_prev) and not na(price_ph_prev) and price_ph_curr > price_ph_prev and rsi_ph_curr < rsi_ph_prev
    bool bullDiv = plFound and not na(rsi_pl_prev) and not na(price_pl_prev) and price_pl_curr < price_pl_prev and rsi_pl_curr > rsi_pl_prev
    [bearDiv, bullDiv]

// Manual TF-string-to-minutes lookup (Pine v6 safe — avoids series/simple type ambiguity of timeframe.in_seconds).
// Returns 0 for unknown TF strings — caller must guard.
f_tf_str_to_minutes(string tf) =>
    int mins = switch tf
        "1"   => 1
        "2"   => 2
        "3"   => 3
        "5"   => 5
        "10"  => 10
        "15"  => 15
        "30"  => 30
        "45"  => 45
        "60"  => 60
        "120" => 120
        "180" => 180
        "240" => 240
        "D"   => 1440
        "1D"  => 1440
        "W"   => 10080
        "1W"  => 10080
        "M"   => 43200
        "1M"  => 43200
        => 0
    mins

// Geometric weighted mean of the 5 TF resolutions, in minutes.
// Same weights as Master fusion (0.15/0.20/0.25/0.25/0.15). Returns na if any TF unknown.
f_master_effective_tf(string t1, string t2, string t3, string t4, string t5) =>
    int m1 = f_tf_str_to_minutes(t1)
    int m2 = f_tf_str_to_minutes(t2)
    int m3 = f_tf_str_to_minutes(t3)
    int m4 = f_tf_str_to_minutes(t4)
    int m5 = f_tf_str_to_minutes(t5)
    float result = na
    if m1 > 0 and m2 > 0 and m3 > 0 and m4 > 0 and m5 > 0
        float log_sum = 0.15 * math.log(m1) + 0.20 * math.log(m2) + 0.25 * math.log(m3) + 0.25 * math.log(m4) + 0.15 * math.log(m5)
        result := math.exp(log_sum)
    result

// Formats minutes (float) → human label. Returns "?" for na input.
//   5  → "5m"   |  60 → "1h"  |  71.5 → "1h11m"  |  1440 → "1d"
f_format_minutes_to_label(float mins) =>
    string result = "?"
    if not na(mins)
        if mins < 1
            result := "<1m"
        else if mins < 60
            result := str.tostring(int(mins)) + "m"
        else if mins < 1440
            int hours = int(mins / 60)
            int rem = int(mins) % 60
            result := rem > 0 ? str.tostring(hours) + "h" + str.tostring(rem) + "m" : str.tostring(hours) + "h"
        else
            float days = mins / 1440.0
            result := str.tostring(math.round(days, 1)) + "d"
    result

// ========================================================================================================
// LOCALIZED STRINGS (Multilingual pattern — EN/PT/ES/RU/ZH coverage)
// ========================================================================================================

// --- HUD: title (merged full-width header) ---
var string s_hud_title        = _l=="PT"?"📊 Sincronia MTF RSI"                  :_l=="ES"?"📊 Sincronía MTF RSI"                  :_l=="RU"?"📊 MTF RSI Синхрония"                :_l=="ZH"?"📊 MTF RSI 同步"                       :"📊 MTF RSI Synchrony"

// --- HUD: status row ---
var string s_aligned          = _l=="PT"?"✅ Alinhado"                            :_l=="ES"?"✅ Alineado"                            :_l=="RU"?"✅ Согласовано"                  :_l=="ZH"?"✅ 一致"                              :"✅ Aligned"
var string s_div_strong_top   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Topo)"            :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Cima)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Верх)"  :_l=="ZH"?"🔀 强背离（顶部）"                       :"🔀 STRONG DIVERGENCE (Top)"
var string s_div_strong_bot   = _l=="PT"?"🔀 DIVERGÊNCIA FORTE (Fundo)"           :_l=="ES"?"🔀 DIVERGENCIA FUERTE (Bajo)"           :_l=="RU"?"🔀 СИЛЬНАЯ ДИВЕРГЕНЦИЯ (Низ)"   :_l=="ZH"?"🔀 强背离（底部）"                       :"🔀 STRONG DIVERGENCE (Bottom)"
var string s_div_mod_top      = _l=="PT"?"⚡ Divergência Moderada (Topo)"         :_l=="ES"?"⚡ Divergencia Moderada (Cima)"          :_l=="RU"?"⚡ Умеренная дивергенция (Верх)" :_l=="ZH"?"⚡ 中度背离（顶部）"                      :"⚡ Moderate Divergence (Top)"
var string s_div_mod_bot      = _l=="PT"?"⚡ Divergência Moderada (Fundo)"        :_l=="ES"?"⚡ Divergencia Moderada (Bajo)"          :_l=="RU"?"⚡ Умеренная дивергенция (Низ)"  :_l=="ZH"?"⚡ 中度背离（底部）"                      :"⚡ Moderate Divergence (Bottom)"

// --- HUD: Legend Table column headers (Row 1 — v2.6 backport) ---
var string s_hdr_indicator    = _l=="PT"?"Indicador"                             :_l=="ES"?"Indicador"                              :_l=="RU"?"Индикатор"                              :_l=="ZH"?"指标"                                 :"Indicator"
var string s_hdr_timeframe    = _l=="PT"?"Timeframe"                             :_l=="ES"?"Marco Temp."                            :_l=="RU"?"Таймфрейм"                              :_l=="ZH"?"时间框架"                             :"Timeframe"
var string s_hdr_value        = _l=="PT"?"Valor"                                 :_l=="ES"?"Valor"                                  :_l=="RU"?"Значение"                               :_l=="ZH"?"数值"                                 :"Value"
var string s_hdr_trend        = _l=="PT"?"Tend."                                 :_l=="ES"?"Tend."                                  :_l=="RU"?"Тренд"                                  :_l=="ZH"?"趋势"                                 :"Trend"
var string s_hdr_div          = _l=="PT"?"Div"                                   :_l=="ES"?"Div"                                    :_l=="RU"?"Див."                                   :_l=="ZH"?"背离"                                 :"Div"

// --- HUD: State column header + 7 state names (v2.7) ---
var string s_hdr_state        = _l=="PT"?"Estado"                                :_l=="ES"?"Estado"                                 :_l=="RU"?"Сост."                                  :_l=="ZH"?"状态"                                 :"State"
var string s_state_exhausted    = _l=="PT"?"EXAURIDO"                            :_l=="ES"?"AGOTADO"                                :_l=="RU"?"ИСТОЩЕН"                                :_l=="ZH"?"力竭"                                  :"EXHAUSTED"
var string s_state_overbought   = _l=="PT"?"SOBRECOMP."                          :_l=="ES"?"SOBRECOMP."                             :_l=="RU"?"ПЕРЕКУПЛ."                              :_l=="ZH"?"超买"                                  :"OVERBOUGHT"
var string s_state_bullish      = _l=="PT"?"ALTA"                                :_l=="ES"?"ALCISTA"                                :_l=="RU"?"БЫЧИЙ"                                  :_l=="ZH"?"看涨"                                  :"BULLISH"
var string s_state_neutral      = _l=="PT"?"NEUTRO"                              :_l=="ES"?"NEUTRO"                                 :_l=="RU"?"НЕЙТРАЛ."                               :_l=="ZH"?"中性"                                  :"NEUTRAL"
var string s_state_bearish      = _l=="PT"?"BAIXA"                               :_l=="ES"?"BAJISTA"                                :_l=="RU"?"МЕДВЕЖИЙ"                               :_l=="ZH"?"看跌"                                  :"BEARISH"
var string s_state_oversold     = _l=="PT"?"SOBREVEND."                          :_l=="ES"?"SOBREVEND."                             :_l=="RU"?"ПЕРЕПРОД."                              :_l=="ZH"?"超卖"                                  :"OVERSOLD"
var string s_state_capitulation = _l=="PT"?"CAPITULAÇÃO"                         :_l=="ES"?"CAPITULACIÓN"                           :_l=="RU"?"КАПИТУЛЯЦ."                             :_l=="ZH"?"投降"                                  :"CAPITULATION"

// ========================================================================================================
// State name resolver — maps a 0-100 RSI value to a multilingual state name string.
// Mirrors the thresholds from f_termal_matrix_rsi (the 7-tier color matrix) but returns
// a multilingual name from the localized dictionary. Used by the State column in the
// MTF Legend Table.
// RSI-native vocabulary (different from Volume sibling's effort/drought semantics):
//   >= 85   -> EXHAUSTED     29-38  -> BEARISH
//   71-85   -> OVERBOUGHT    15-29  -> OVERSOLD
//   62-71   -> BULLISH       <= 15  -> CAPITULATION
//   38-62   -> NEUTRAL       na     -> "—"
// Note: declared AFTER the multilang block because it references s_state_*
// variables that must be declared before this function in Pine v6 top-down parsing.
// ========================================================================================================
f_state_name_rsi(float val) =>
    string result = "—"
    if not na(val)
        if val >= 85
            result := s_state_exhausted
        else if val >= 71
            result := s_state_overbought
        else if val >= 62
            result := s_state_bullish
        else if val > 38
            result := s_state_neutral
        else if val > 29
            result := s_state_bearish
        else if val > 15
            result := s_state_oversold
        else
            result := s_state_capitulation
    result

// Buy/sell emoji from RSI level: buy at oversold (<=29), sell at overbought (>=71), none in neutral band
f_buysell_emoji(float val) =>
    na(val) ? "" : val <= 29 ? "💰 " : val >= 71 ? "💸 " : ""

// RSI-level emoji (symmetric, cumulative): >=71 or <=29 attention; >=85 or <=15 attention + explosion
f_level_emoji_rsi(float val) =>
    na(val) ? "" : (val >= 85 or val <= 15) ? "⚠️💥 " : (val >= 71 or val <= 29) ? "⚠️ " : ""


// --- Alert prefixes (Black Swan crossings) ---
var string s_al_bs_high_pre   = _l=="PT"?"🌈 MTF RSI — Master cruzou ACIMA do Black Swan Alto ("   :_l=="ES"?"🌈 MTF RSI — Master cruzó ARRIBA del Black Swan Alto ("    :_l=="RU"?"🌈 MTF RSI — Master пересёк ВВЕРХ Black Swan High ("     :_l=="ZH"?"🌈 MTF RSI — Master 向上突破 Black Swan 高位 ("              :"🌈 MTF RSI — Master crossed ABOVE Black Swan High ("
var string s_al_bs_low_pre    = _l=="PT"?"🌈 MTF RSI — Master cruzou ABAIXO do Black Swan Baixo (" :_l=="ES"?"🌈 MTF RSI — Master cruzó ABAJO del Black Swan Bajo ("    :_l=="RU"?"🌈 MTF RSI — Master пересёк ВНИЗ Black Swan Low ("       :_l=="ZH"?"🌈 MTF RSI — Master 向下突破 Black Swan 低位 ("              :"🌈 MTF RSI — Master crossed BELOW Black Swan Low ("
var string s_al_bs_mid        = _l=="PT"?"). Master RSI: "                                          :_l=="ES"?"). Master RSI: "                                            :_l=="RU"?"). Master RSI: "                                            :_l=="ZH"?"）。Master RSI："                                            :"). Master RSI: "

// --- Alert prefixes (Black Swan glow extinguished) ---
var string s_al_bs_glow_high_pre = _l=="PT"?"🌑 MTF RSI — Glow do Black Swan Alto APAGADO (Master se afastou da linha roxa). Master RSI: "   :_l=="ES"?"🌑 MTF RSI — Glow del Black Swan Alto APAGADO (Master se alejó de la línea púrpura). Master RSI: "  :_l=="RU"?"🌑 MTF RSI — Свечение Black Swan High ПОГАСЛО (Master отошёл от фиолетовой линии). Master RSI: " :_l=="ZH"?"🌑 MTF RSI — Black Swan 高位光晕已熄灭（Master 远离紫色线）。Master RSI："                       :"🌑 MTF RSI — Black Swan High glow EXTINGUISHED (Master pulled away from the purple line). Master RSI: "
var string s_al_bs_glow_low_pre  = _l=="PT"?"🌑 MTF RSI — Glow do Black Swan Baixo APAGADO (Master se afastou da linha aqua). Master RSI: "   :_l=="ES"?"🌑 MTF RSI — Glow del Black Swan Bajo APAGADO (Master se alejó de la línea aqua). Master RSI: "      :_l=="RU"?"🌑 MTF RSI — Свечение Black Swan Low ПОГАСЛО (Master отошёл от линии аква). Master RSI: "        :_l=="ZH"?"🌑 MTF RSI — Black Swan 低位光晕已熄灭（Master 远离青色线）。Master RSI："                       :"🌑 MTF RSI — Black Swan Low glow EXTINGUISHED (Master pulled away from the aqua line). Master RSI: "

// --- Alert prefixes (Strong MTF Divergence) ---
var string s_al_div_pre       = _l=="PT"?"🔀 MTF RSI — Divergência MTF FORTE ("                    :_l=="ES"?"🔀 MTF RSI — Divergencia MTF FUERTE ("                      :_l=="RU"?"🔀 MTF RSI — СИЛЬНАЯ MTF дивергенция ("                    :_l=="ZH"?"🔀 MTF RSI — 强 MTF 背离（"                                  :"🔀 MTF RSI — STRONG MTF Divergence ("
var string s_al_div_top       = _l=="PT"?"Topo"                                                     :_l=="ES"?"Cima"                                                       :_l=="RU"?"Верх"                                                       :_l=="ZH"?"顶部"                                                       :"Top"
var string s_al_div_bottom    = _l=="PT"?"Fundo"                                                    :_l=="ES"?"Bajo"                                                       :_l=="RU"?"Низ"                                                        :_l=="ZH"?"底部"                                                       :"Bottom"
var string s_al_div_tf1       = _l=="PT"?"). TF1: "                                                 :_l=="ES"?"). TF1: "                                                   :_l=="RU"?"). TF1: "                                                   :_l=="ZH"?"）。TF1："                                                    :"). TF1: "
var string s_al_div_tf5       = _l=="PT"?" | TF5: "                                                 :_l=="ES"?" | TF5: "                                                   :_l=="RU"?" | TF5: "                                                   :_l=="ZH"?" | TF5："                                                     :" | TF5: "

// --- Alert prefixes (Z-Exhaustion zone entries) ---
var string s_al_red_pre       = _l=="PT"?"💸 MTF RSI — Master entrou na zona Z-Exaustão ALTA ("    :_l=="ES"?"💸 MTF RSI — Master entró en la zona Z-Agotamiento ALTA ("  :_l=="RU"?"💸 MTF RSI — Master вошёл в зону Z-Истощение ВЕРХ ("       :_l=="ZH"?"💸 MTF RSI — Master 进入 Z-极限 高位区 ("                       :"💸 MTF RSI — Master entered Z-Exhaustion HIGH zone ("
var string s_al_blue_pre      = _l=="PT"?"💰 MTF RSI — Master entrou na zona Z-Exaustão BAIXA ("   :_l=="ES"?"💰 MTF RSI — Master entró en la zona Z-Agotamiento BAJA ("   :_l=="RU"?"💰 MTF RSI — Master вошёл в зону Z-Истощение НИЗ ("         :_l=="ZH"?"💰 MTF RSI — Master 进入 Z-极限 低位区 ("                       :"💰 MTF RSI — Master entered Z-Exhaustion LOW zone ("
var string s_al_zone_close    = _l=="PT"?")"                                                        :_l=="ES"?")"                                                          :_l=="RU"?")"                                                          :_l=="ZH"?"）"                                                          :")"

// --- Alert prefixes (Master Classic Divergence) ---
var string s_al_div_master_bear_pre = _l=="PT"?"🔻 MTF RSI — Divergência CLÁSSICA Bear no Master (preço↑ + RSI↓). Master RSI: " :_l=="ES"?"🔻 MTF RSI — Divergencia CLÁSICA Bear en Master (precio↑ + RSI↓). Master RSI: " :_l=="RU"?"🔻 MTF RSI — КЛАССИЧЕСКАЯ медвежья дивергенция Master (цена↑ + RSI↓). Master RSI: " :_l=="ZH"?"🔻 MTF RSI — Master 经典看跌背离（价格↑ + RSI↓）。Master RSI："                          :"🔻 MTF RSI — CLASSIC Bear Divergence on Master (price↑ + RSI↓). Master RSI: "
var string s_al_div_master_bull_pre = _l=="PT"?"🔺 MTF RSI — Divergência CLÁSSICA Bull no Master (preço↓ + RSI↑). Master RSI: " :_l=="ES"?"🔺 MTF RSI — Divergencia CLÁSICA Bull en Master (precio↓ + RSI↑). Master RSI: " :_l=="RU"?"🔺 MTF RSI — КЛАССИЧЕСКАЯ бычья дивергенция Master (цена↓ + RSI↑). Master RSI: "  :_l=="ZH"?"🔺 MTF RSI — Master 经典看涨背离（价格↓ + RSI↑）。Master RSI："                          :"🔺 MTF RSI — CLASSIC Bull Divergence on Master (price↓ + RSI↑). Master RSI: "
var string s_div_chart_label_master = _l=="PT"?" Master"                                            :_l=="ES"?" Master"                                            :_l=="RU"?" Master"                                            :_l=="ZH"?" Master"                                            :" Master"

// ========================================================================================================
// MTF RSI FETCH (5 independent timeframes — lookahead_off, anti-repaint)
//   Per-TF length resolution: if rsi_len_tfN is 0, inherit from rsi_length_default;
//   otherwise use the override. Computed once per bar.
// ========================================================================================================
int len_tf1 = rsi_len_tf1 > 0 ? rsi_len_tf1 : rsi_length_default
int len_tf2 = rsi_len_tf2 > 0 ? rsi_len_tf2 : rsi_length_default
int len_tf3 = rsi_len_tf3 > 0 ? rsi_len_tf3 : rsi_length_default
int len_tf4 = rsi_len_tf4 > 0 ? rsi_len_tf4 : rsi_length_default
int len_tf5 = rsi_len_tf5 > 0 ? rsi_len_tf5 : rsi_length_default

float rsi_tf1 = request.security(active_sym, tf_1, ta.rsi(close, len_tf1), lookahead = barmerge.lookahead_off)
float rsi_tf2 = request.security(active_sym, tf_2, ta.rsi(close, len_tf2), lookahead = barmerge.lookahead_off)
float rsi_tf3 = request.security(active_sym, tf_3, ta.rsi(close, len_tf3), lookahead = barmerge.lookahead_off)
float rsi_tf4 = request.security(active_sym, tf_4, ta.rsi(close, len_tf4), lookahead = barmerge.lookahead_off)
float rsi_tf5 = request.security(active_sym, tf_5, ta.rsi(close, len_tf5), lookahead = barmerge.lookahead_off)

// ========================================================================================================
// CLASSIC DIVERGENCE DETECTION (per-TF — price vs RSI on the SAME timeframe)
//   Different from existing MTF Divergence (TF1-vs-TF5 RSI alignment).
//   Each TF runs its own pivot detection via request.security; returned booleans
//   indicate bear (top) or bull (bottom) regular divergence currently active on that TF.
// ========================================================================================================
[bear_div_tf1, bull_div_tf1] = request.security(active_sym, tf_1, f_classic_divergence(len_tf1, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf2, bull_div_tf2] = request.security(active_sym, tf_2, f_classic_divergence(len_tf2, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf3, bull_div_tf3] = request.security(active_sym, tf_3, f_classic_divergence(len_tf3, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf4, bull_div_tf4] = request.security(active_sym, tf_4, f_classic_divergence(len_tf4, div_lookback), lookahead = barmerge.lookahead_off)
[bear_div_tf5, bull_div_tf5] = request.security(active_sym, tf_5, f_classic_divergence(len_tf5, div_lookback), lookahead = barmerge.lookahead_off)

// ========================================================================================================
// MASTER LINE (weighted RSI fusion — clamped to 0–100)
// ========================================================================================================
float rsi_master = math.max(math.min(nz(f_avg5_weighted(rsi_tf1, rsi_tf2, rsi_tf3, rsi_tf4, rsi_tf5), 50.0), 100.0), 0.0)

// Master classic divergence detection — price pivots come from the ACTIVE symbol (chart symbol, or the
//   Symbol Override when set) on the chart resolution, keeping divergence consistent with the RSI source.
//   Detected on the current chart resolution. Used as fallback when chart TF doesn't match any of the 5 user-selected TFs.
[src_high_master, src_low_master] = request.security(active_sym, timeframe.period, [high, low], lookahead = barmerge.lookahead_off)

bool ph_master_found = not na(ta.pivothigh(rsi_master, div_lookback, div_lookback))
bool pl_master_found = not na(ta.pivotlow(rsi_master,  div_lookback, div_lookback))

float rsi_master_ph_curr   = ta.valuewhen(ph_master_found, rsi_master[div_lookback], 0)
float rsi_master_ph_prev   = ta.valuewhen(ph_master_found, rsi_master[div_lookback], 1)
float price_master_ph_curr = ta.valuewhen(ph_master_found, src_high_master[div_lookback], 0)
float price_master_ph_prev = ta.valuewhen(ph_master_found, src_high_master[div_lookback], 1)

float rsi_master_pl_curr   = ta.valuewhen(pl_master_found, rsi_master[div_lookback], 0)
float rsi_master_pl_prev   = ta.valuewhen(pl_master_found, rsi_master[div_lookback], 1)
float price_master_pl_curr = ta.valuewhen(pl_master_found, src_low_master[div_lookback], 0)
float price_master_pl_prev = ta.valuewhen(pl_master_found, src_low_master[div_lookback], 1)

bool bear_div_master = ph_master_found and not na(rsi_master_ph_prev) and not na(price_master_ph_prev) and price_master_ph_curr > price_master_ph_prev and rsi_master_ph_curr < rsi_master_ph_prev
bool bull_div_master = pl_master_found and not na(rsi_master_pl_prev) and not na(price_master_pl_prev) and price_master_pl_curr < price_master_pl_prev and rsi_master_pl_curr > rsi_master_pl_prev

// Bar indices of Master pivots (needed for line.new chart visual — current + previous pivot bars).
int master_bar_ph_curr = ta.valuewhen(ph_master_found, bar_index[div_lookback], 0)
int master_bar_ph_prev = ta.valuewhen(ph_master_found, bar_index[div_lookback], 1)
int master_bar_pl_curr = ta.valuewhen(pl_master_found, bar_index[div_lookback], 0)
int master_bar_pl_prev = ta.valuewhen(pl_master_found, bar_index[div_lookback], 1)

// Master effective TF (geometric weighted mean of the 5 TFs) — shown in the Master row label.
float master_eff_mins  = f_master_effective_tf(tf_1, tf_2, tf_3, tf_4, tf_5)
string master_eff_label = f_format_minutes_to_label(master_eff_mins)

// ========================================================================================================
// CHART VISUAL — Master Divergence (line + label)
//   Drawn on the indicator pane only. Master is the integrated MTF view, so its divergence captures the
//   "average" cross-TF signal. For per-TF breakdown, the Legend Table 'Div' column shows each TF separately.
//   Anti-spam: a divergence triggers ONE line + label on the bar it's confirmed.
//   History: bounded by indicator() max_lines_count / max_labels_count (500 each — ample for ~50 events).
// ========================================================================================================
if show_div_chart_line and bear_div_master and not na(master_bar_ph_prev)
    line.new(x1 = master_bar_ph_prev, y1 = rsi_master_ph_prev, x2 = master_bar_ph_curr, y2 = rsi_master_ph_curr, color = color.new(c_up_3, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_ph_curr, y = rsi_master_ph_curr, text = "🔻 Bear Div" + s_div_chart_label_master, color = color.new(c_up_3, 20), textcolor = color.white, style = label.style_label_down, size = size.small)

if show_div_chart_line and bull_div_master and not na(master_bar_pl_prev)
    line.new(x1 = master_bar_pl_prev, y1 = rsi_master_pl_prev, x2 = master_bar_pl_curr, y2 = rsi_master_pl_curr, color = color.new(c_dn_1, 30), width = 2, style = line.style_solid)
    label.new(x = master_bar_pl_curr, y = rsi_master_pl_curr, text = "🔺 Bull Div" + s_div_chart_label_master, color = color.new(c_dn_1, 20), textcolor = color.white, style = label.style_label_up, size = size.small)

// ========================================================================================================
// DYNAMIC CHANNEL (Master volatility envelope)
// ========================================================================================================
float dyn_up  = ta.ema(ta.highest(rsi_master, lookback_dyn), smooth_dyn)
float dyn_dn  = ta.ema(ta.lowest(rsi_master,  lookback_dyn), smooth_dyn)
float dyn_mid = (dyn_up + dyn_dn) / 2.0
float dist_up = math.max(dyn_up - dyn_mid, 1e-10)
float dist_dn = math.max(dyn_mid - dyn_dn, 1e-10)

// ========================================================================================================
// RAINBOW FIBONACCI ZONES (canonical ratios 1.50/1.85/2.75/3.85 — NEVER change)
// ========================================================================================================
fib_breath    = 1.50 / 1.85   // ≈ 0.811
fib_exhaust   = 2.75 / 1.85   // ≈ 1.486
fib_blackswan = 3.85 / 1.85   // ≈ 2.081

float osc_up1 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_breath)))     // Z-Breathing High (clamped to [0,100] for pane containment)
float osc_up2 = math.min(100.0, math.max(0.0, dyn_up))                                // Z-Alert High (anchor at 1.85σ, clamped to [0,100])
float osc_up3 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_exhaust)))    // Z-Exhaustion High (clamped to [0,100])
float osc_up4 = math.min(100.0, math.max(0.0, dyn_mid + (dist_up * fib_blackswan)))  // Black Swan High dynamic (clamped to [0,100])

float osc_dn1 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_breath)))
float osc_dn2 = math.min(100.0, math.max(0.0, dyn_dn))
float osc_dn3 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_exhaust)))
float osc_dn4 = math.min(100.0, math.max(0.0, dyn_mid - (dist_dn * fib_blackswan)))

// ========================================================================================================
// BLACK SWAN — HYBRID MODE (static 80/20 by default, dynamic Fibonacci when toggled)
// ========================================================================================================
float black_swan_high = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_up4 : 80.0))
float black_swan_low  = math.min(100.0, math.max(0.0, dynamic_extremes ? osc_dn4 : 20.0))

// ========================================================================================================
// DIVERGENCE DETECTION (TF1 vs TF5)
// ========================================================================================================
bool div_strong_top      = barstate.isconfirmed and rsi_tf1 >= 70 and rsi_tf5 <= 30
bool div_strong_bottom   = barstate.isconfirmed and rsi_tf1 <= 30 and rsi_tf5 >= 70
bool div_strong          = div_strong_top or div_strong_bottom
bool div_moderate_top    = barstate.isconfirmed and not div_strong and rsi_tf1 >= 65 and rsi_tf5 <= 40
bool div_moderate_bottom = barstate.isconfirmed and not div_strong and rsi_tf1 <= 35 and rsi_tf5 >= 60
bool div_moderate        = div_moderate_top or div_moderate_bottom

// ========================================================================================================
// VISUAL — INVISIBLE REFERENCE PLOTS (for rainbow fills)
// ========================================================================================================
p_mid = plot(dyn_mid, "Dyn Mid (ref)",        display = display.none, editable = false)
p_up1 = plot(osc_up1, "Z-Breathing High Ref", display = display.none, editable = false)
p_up2 = plot(osc_up2, "Z-Alert High Ref",     display = display.none, editable = false)
p_up3 = plot(osc_up3, "Z-Exhaustion High Ref",display = display.none, editable = false)
p_dn1 = plot(osc_dn1, "Z-Breathing Low Ref",  display = display.none, editable = false)
p_dn2 = plot(osc_dn2, "Z-Alert Low Ref",      display = display.none, editable = false)
p_dn3 = plot(osc_dn3, "Z-Exhaustion Low Ref", display = display.none, editable = false)

// ========================================================================================================
// VISUAL — RAINBOW FIBONACCI FILLS (6 bands — NO fill in Black Swan zone, hard rule #6)
// ========================================================================================================
fill(p_mid, p_up1, color = show_fills ? color.new(c_up_1, 92) : na, title = "Z-Breathing High")
fill(p_up1, p_up2, color = show_fills ? color.new(c_up_2, 90) : na, title = "Z-Alert High")
fill(p_up2, p_up3, color = show_fills ? color.new(c_up_3, 88) : na, title = "Z-Exhaustion High")

fill(p_mid, p_dn1, color = show_fills ? color.new(c_dn_1, 92) : na, title = "Z-Breathing Low")
fill(p_dn1, p_dn2, color = show_fills ? color.new(c_dn_2, 90) : na, title = "Z-Alert Low")
fill(p_dn2, p_dn3, color = show_fills ? color.new(c_dn_3, 88) : na, title = "Z-Exhaustion Low")

// ========================================================================================================
// VISUAL — STATIC REFERENCE LEVELS (30 / 50 / 70 — classic RSI guides, colored + extended)
// Pine v6 note: hline() requires a const color (no series ternary). We use plot() with a
// const color + dynamic `display` toggle so the user input can show/hide cleanly.
// Color semantics — INVERTED vs Volume sibling (RSI = mean-reversion, not effort):
//   70 = red    (c_up_3) — overbought zone (selling pressure / mean reversion candidate)
//   50 = yellow (c_up_1) — neutral midline
//   30 = green  (c_dn_1) — oversold zone (buying pressure / mean reversion candidate)
// ========================================================================================================
// Optional glow on the configurable levels (fade-by-distance to Master — same pattern as Black Swan glow)
int transp_lvl_high = show_level_glow ? f_calc_glow(rsi_master, level_high, math.max(dist_up, 5.0)) : 100
int transp_lvl_low  = show_level_glow ? f_calc_glow(rsi_master, level_low,  math.max(dist_dn, 5.0)) : 100

plot(show_level_glow ? level_high : na, "RSI Overbought Glow", color = color.new(c_up_3, transp_lvl_high), linewidth = 5, display = show_static_levels ? display.pane : display.none, editable = false)
plot(show_level_glow ? level_low  : na, "RSI Oversold Glow",   color = color.new(c_dn_1, transp_lvl_low),  linewidth = 5, display = show_static_levels ? display.pane : display.none, editable = false)

plot(level_high, "RSI Overbought", color = color.new(c_up_3, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)
plot(50,         "RSI 50",         color = color.new(c_up_1, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)
plot(level_low,  "RSI Oversold",   color = color.new(c_dn_1, 50), linewidth = 1, linestyle = plot.linestyle_dotted, display = show_static_levels ? display.pane + display.price_scale : display.none, editable = false)

// Extended-right portion: persistent line objects redrawn at the chart's right edge.
// On the last bar, we set the line's endpoint into the future (bar_index + 500) so it
// projects beyond the price action. Hidden when show_static_levels is OFF.
var line ln_70 = na
var line ln_50 = na
var line ln_30 = na
if barstate.islast
    if not na(ln_70)
        line.delete(ln_70)
    if not na(ln_50)
        line.delete(ln_50)
    if not na(ln_30)
        line.delete(ln_30)
    if show_static_levels
        ln_70 := line.new(bar_index, level_high, bar_index + 500, level_high, color = color.new(c_up_3, 30), width = 1, style = line.style_dotted, extend = extend.right)
        ln_50 := line.new(bar_index, 50, bar_index + 500, 50, color = color.new(c_up_1, 30), width = 1, style = line.style_dotted, extend = extend.right)
        ln_30 := line.new(bar_index, level_low, bar_index + 500, level_low, color = color.new(c_dn_1, 30), width = 1, style = line.style_dotted, extend = extend.right)

// ========================================================================================================
// VISUAL — BLACK SWAN HIGH (line + glow, fade by distance to Master, NO fill)
// ========================================================================================================
float glow_range_high = math.max(dist_up, 5.0)
float glow_range_low  = math.max(dist_dn, 5.0)
int   transp_bs_high  = f_calc_glow(rsi_master, black_swan_high, glow_range_high)
int   transp_bs_low   = f_calc_glow(rsi_master, black_swan_low,  glow_range_low)

plot(show_blackswan ? black_swan_high : na, "Black Swan High Glow", color = color.new(c_up_4, transp_bs_high), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_high : na, "Black Swan High Main", color = color.new(c_up_4, math.max(20, transp_bs_high - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — DYNAMIC CHANNEL (dashed envelope, adapts to Master volatility)
// ========================================================================================================
plot(dyn_up,  "Dyn Channel Up",  color = color.new(c_up_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_mid, "Dyn Channel Mid", color = color.new(c_neutral, 55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)
plot(dyn_dn,  "Dyn Channel Dn",  color = color.new(c_dn_2,    55), linewidth = 1, linestyle = plot.linestyle_dashed, display = show_dyn_channel ? display.pane + display.price_scale : display.none)

// ========================================================================================================
// VISUAL — GHOST LINES (5 individual RSIs, transparency = f(distance to Master))
// Formula:  transp = clamp(20 + dist × ghost_sensitivity, 20, 90)
//   - At dist=0 (perfect alignment): transp=20 (solid).
//   - At dist=(70/ghost_sensitivity) RSI points: transp=90 (invisible).
//   - Default ghost_sensitivity=3.5 ⇒ invisible at ~20 RSI points apart.
// ========================================================================================================
float dist_tf1 = math.abs(rsi_tf1 - rsi_master)
float dist_tf2 = math.abs(rsi_tf2 - rsi_master)
float dist_tf3 = math.abs(rsi_tf3 - rsi_master)
float dist_tf4 = math.abs(rsi_tf4 - rsi_master)
float dist_tf5 = math.abs(rsi_tf5 - rsi_master)

int transp_tf1 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf1 * ghost_sensitivity)))
int transp_tf2 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf2 * ghost_sensitivity)))
int transp_tf3 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf3 * ghost_sensitivity)))
int transp_tf4 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf4 * ghost_sensitivity)))
int transp_tf5 = int(math.min(90.0, math.max(20.0, 20.0 + dist_tf5 * ghost_sensitivity)))

plot(show_tf1 ? rsi_tf1 : na, "RSI TF 1 (Trigger)",  color = color.new(color_tf1, transp_tf1), linewidth = 1)
plot(show_tf2 ? rsi_tf2 : na, "RSI TF 2 (Intraday)", color = color.new(color_tf2, transp_tf2), linewidth = 1)
plot(show_tf3 ? rsi_tf3 : na, "RSI TF 3 (Macro 1)",  color = color.new(color_tf3, transp_tf3), linewidth = 1)
plot(show_tf4 ? rsi_tf4 : na, "RSI TF 4 (Macro 2)",  color = color.new(color_tf4, transp_tf4), linewidth = 1)
plot(show_tf5 ? rsi_tf5 : na, "RSI TF 5 (Base)",     color = color.new(color_tf5, transp_tf5), linewidth = 1)

// ========================================================================================================
// VISUAL — BLACK SWAN LOW (line + glow, before Master so Master always sits on top)
// ========================================================================================================
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Glow", color = color.new(c_dn_4, transp_bs_low), linewidth = 5, display = display.pane)
plot(show_blackswan ? black_swan_low : na, "Black Swan Low Main", color = color.new(c_dn_4, math.max(20, transp_bs_low - 20)), linewidth = 1)

// ========================================================================================================
// VISUAL — MASTER LINE (rainbow color by zone, plotted LAST so it always sits on top)
// ========================================================================================================
color c_master = f_termal_matrix_rsi(rsi_master)
plot(show_master_line ? rsi_master : na, "RSI Master 🌈", color = c_master, linewidth = 3)

// ========================================================================================================
// DIVERGENCE EVENT MARKERS (Strong + Moderate, dual-position via div_markers_pos input)
// 4 events × 2 positions = 8 plotshapes declared; only the 4 matching the chosen position are active.
// Pine v6 requires location and force_overlay as const literals — dual declaration is the canonical pattern.
//
// Color hierarchy mirrors the Legend Table status row palette:
//   - Strong   top    → c_up_3 (red, saturated)     | Strong   bottom → c_dn_1 (green, saturated)
//   - Moderate top    → c_up_2 (orange, transitional)| Moderate bottom → c_dn_2 (teal, transitional)
//
// Triangle direction signals expected reversal: ▼ = Top (reversal from highs); ▲ = Bottom (reversal from lows).
// Markers persist while the divergence condition holds (mutually exclusive: Strong and Moderate never
// co-fire on the same bar — Moderate has "and not div_strong" guard from v1.0 detection logic).
// ========================================================================================================
bool mk_pane    = div_markers_pos == "Indicator Pane"
bool mk_overlay = div_markers_pos == "Chart Overlay"

// --- Indicator pane variant (location.top / location.bottom) ---
plotshape(show_div_markers and mk_pane and div_strong_top,      title = "Strong Top Divergence (pane)",      location = location.top,    style = shape.triangledown, color = color.new(c_up_3, 40), size = size.tiny)
plotshape(show_div_markers and mk_pane and div_strong_bottom,   title = "Strong Bottom Divergence (pane)",   location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_1, 40), size = size.tiny)
plotshape(show_div_markers and mk_pane and div_moderate_top,    title = "Moderate Top Divergence (pane)",    location = location.top,    style = shape.triangledown, color = color.new(c_up_2, 40), size = size.tiny)
plotshape(show_div_markers and mk_pane and div_moderate_bottom, title = "Moderate Bottom Divergence (pane)", location = location.bottom, style = shape.triangleup,   color = color.new(c_dn_2, 40), size = size.tiny)

// --- Chart overlay variant (location.abovebar / location.belowbar, force_overlay=true) ---
plotshape(show_div_markers and mk_overlay and div_strong_top,      title = "Strong Top Divergence (chart)",      location = location.abovebar, style = shape.triangledown, color = color.new(c_up_3, 40), size = size.tiny, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_strong_bottom,   title = "Strong Bottom Divergence (chart)",   location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_1, 40), size = size.tiny, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_top,    title = "Moderate Top Divergence (chart)",    location = location.abovebar, style = shape.triangledown, color = color.new(c_up_2, 40), size = size.tiny, force_overlay = true)
plotshape(show_div_markers and mk_overlay and div_moderate_bottom, title = "Moderate Bottom Divergence (chart)", location = location.belowbar, style = shape.triangleup,   color = color.new(c_dn_2, 40), size = size.tiny, force_overlay = true)

// ========================================================================================================
// MTF LEGEND TABLE (mini-table inside the indicator pane — force_overlay=false for mobile readability)
// Layout (4 cols × 8 rows):
//   Row 0: merged full-width title (multilingual s_hud_title)
//   Row 1-5: per-TF rows — [● TFn + 📡 if chart-native] | TF resolution | RSI value | trend arrow ▲/▼/▬
//   Row 6: Master row (cols 0-1 merged: "🌈 Master") | Master RSI | Master trend arrow
//   Row 7: merged status row (divergence summary, reused from v1.5 logic)
//
// Color scheme:
//   - Col 0 (● TFn label): color_tfN (user-configured, matches ghost line)
//   - Col 1 (TF resolution): c_neutral
//   - Col 2 (RSI value): zone color via f_termal_matrix_rsi(rsi_tfN)
//   - Col 3 (trend arrow): same zone color (visual coupling)
//   - Master row: entire row in Master zone color
//   - Antenna marker (📡): suffix of col 0 only on the row whose TF == timeframe.period
// ========================================================================================================
var table legend = table.new(f_position(legend_pos), 6, 9, border_width = 1, border_color = color.new(c_neutral, 80), frame_width = 2, frame_color = color.new(c_black, 20), force_overlay = false)

if barstate.islast and show_legend_table
    // --- Zone colors (used for RSI value + trend cell text) ---
    color c_tf1_dot    = f_termal_matrix_rsi(rsi_tf1)
    color c_tf2_dot    = f_termal_matrix_rsi(rsi_tf2)
    color c_tf3_dot    = f_termal_matrix_rsi(rsi_tf3)
    color c_tf4_dot    = f_termal_matrix_rsi(rsi_tf4)
    color c_tf5_dot    = f_termal_matrix_rsi(rsi_tf5)
    color c_master_dot = f_termal_matrix_rsi(rsi_master)

    // --- Antenna marker (📡 if this TF == chart's native resolution) ---
    string current_tf = timeframe.period
    string ant1 = tf_1 == current_tf ? " 📡" : ""
    string ant2 = tf_2 == current_tf ? " 📡" : ""
    string ant3 = tf_3 == current_tf ? " 📡" : ""
    string ant4 = tf_4 == current_tf ? " 📡" : ""
    string ant5 = tf_5 == current_tf ? " 📡" : ""

    // --- Trend arrows (±0.5 deadzone vs previous bar — flicker-resistant) ---
    string trend_tf1    = rsi_tf1    > nz(rsi_tf1[1],    rsi_tf1)    + 0.5 ? "▲" : rsi_tf1    < nz(rsi_tf1[1],    rsi_tf1)    - 0.5 ? "▼" : "▬"
    string trend_tf2    = rsi_tf2    > nz(rsi_tf2[1],    rsi_tf2)    + 0.5 ? "▲" : rsi_tf2    < nz(rsi_tf2[1],    rsi_tf2)    - 0.5 ? "▼" : "▬"
    string trend_tf3    = rsi_tf3    > nz(rsi_tf3[1],    rsi_tf3)    + 0.5 ? "▲" : rsi_tf3    < nz(rsi_tf3[1],    rsi_tf3)    - 0.5 ? "▼" : "▬"
    string trend_tf4    = rsi_tf4    > nz(rsi_tf4[1],    rsi_tf4)    + 0.5 ? "▲" : rsi_tf4    < nz(rsi_tf4[1],    rsi_tf4)    - 0.5 ? "▼" : "▬"
    string trend_tf5    = rsi_tf5    > nz(rsi_tf5[1],    rsi_tf5)    + 0.5 ? "▲" : rsi_tf5    < nz(rsi_tf5[1],    rsi_tf5)    - 0.5 ? "▼" : "▬"
    string trend_master = rsi_master > nz(rsi_master[1], rsi_master) + 0.5 ? "▲" : rsi_master < nz(rsi_master[1], rsi_master) - 0.5 ? "▼" : "▬"

    // --- Divergence summary (reused from v1.5 logic) ---
    string status_txt = s_aligned
    color  status_bg  = color.new(c_neutral, 80)
    color  status_fg  = color.white
    if div_strong_top
        status_txt := s_div_strong_top
        status_bg  := color.new(c_up_3, 50)
    else if div_strong_bottom
        status_txt := s_div_strong_bot
        status_bg  := color.new(c_dn_1, 50)
    else if div_moderate_top
        status_txt := s_div_mod_top
        status_bg  := color.new(c_up_2, 60)
    else if div_moderate_bottom
        status_txt := s_div_mod_bot
        status_bg  := color.new(c_dn_2, 60)

    // === Row 0 — Header (merged 5 cols) ===
    table.merge_cells(legend, 0, 0, 5, 0)
    table.cell(legend, 0, 0, s_hud_title,
         text_color = color.new(c_dn_4, 0), text_size = sz_lbl,
         bgcolor = color.new(c_black, 10), text_halign = text.align_center)

    // === Row 1 — Column Headers (v2.6) ===
    table.cell(legend, 0, 1, s_hdr_indicator, text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)
    table.cell(legend, 1, 1, s_hdr_timeframe, text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)
    table.cell(legend, 2, 1, s_hdr_value,     text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)
    table.cell(legend, 3, 1, s_hdr_trend,     text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)
    table.cell(legend, 4, 1, s_hdr_div,       text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)
    table.cell(legend, 5, 1, s_hdr_state,     text_color = color.new(c_neutral, 0), text_size = sz_tbl, bgcolor = color.new(c_black, 30), text_halign = text.align_center)

    // === Row 2 — TF1 ===
    table.cell(legend, 0, 2, "● TF1" + ant1,         text_color = color_tf1,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 2, tf_1,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 2, f_level_emoji_rsi(rsi_tf1) + f_buysell_emoji(rsi_tf1) + str.tostring(rsi_tf1, "#.0"), text_color = c_tf1_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 2, trend_tf1,               text_color = c_tf1_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 2, show_div_column ? (bear_div_tf1 ? "🔻" : bull_div_tf1 ? "🔺" : "—") : "",  text_color = bear_div_tf1 ? c_up_3 : bull_div_tf1 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 2, show_state_column ? f_state_name_rsi(rsi_tf1) : "", text_color = c_tf1_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 3 — TF2 ===
    table.cell(legend, 0, 3, "● TF2" + ant2,         text_color = color_tf2,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 3, tf_2,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 3, f_level_emoji_rsi(rsi_tf2) + f_buysell_emoji(rsi_tf2) + str.tostring(rsi_tf2, "#.0"), text_color = c_tf2_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 3, trend_tf2,               text_color = c_tf2_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 3, show_div_column ? (bear_div_tf2 ? "🔻" : bull_div_tf2 ? "🔺" : "—") : "",  text_color = bear_div_tf2 ? c_up_3 : bull_div_tf2 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 3, show_state_column ? f_state_name_rsi(rsi_tf2) : "", text_color = c_tf2_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 4 — TF3 ===
    table.cell(legend, 0, 4, "● TF3" + ant3,         text_color = color_tf3,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 4, tf_3,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 4, f_level_emoji_rsi(rsi_tf3) + f_buysell_emoji(rsi_tf3) + str.tostring(rsi_tf3, "#.0"), text_color = c_tf3_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 4, trend_tf3,               text_color = c_tf3_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 4, show_div_column ? (bear_div_tf3 ? "🔻" : bull_div_tf3 ? "🔺" : "—") : "",  text_color = bear_div_tf3 ? c_up_3 : bull_div_tf3 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 4, show_state_column ? f_state_name_rsi(rsi_tf3) : "", text_color = c_tf3_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 5 — TF4 ===
    table.cell(legend, 0, 5, "● TF4" + ant4,         text_color = color_tf4,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_left)
    table.cell(legend, 1, 5, tf_4,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 2, 5, f_level_emoji_rsi(rsi_tf4) + f_buysell_emoji(rsi_tf4) + str.tostring(rsi_tf4, "#.0"), text_color = c_tf4_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_right)
    table.cell(legend, 3, 5, trend_tf4,               text_color = c_tf4_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 4, 5, show_div_column ? (bear_div_tf4 ? "🔻" : bull_div_tf4 ? "🔺" : "—") : "",  text_color = bear_div_tf4 ? c_up_3 : bull_div_tf4 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)
    table.cell(legend, 5, 5, show_state_column ? f_state_name_rsi(rsi_tf4) : "", text_color = c_tf4_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 70), text_halign = text.align_center)

    // === Row 6 — TF5 ===
    table.cell(legend, 0, 6, "● TF5" + ant5,         text_color = color_tf5,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_left)
    table.cell(legend, 1, 6, tf_5,                    text_color = color.new(c_neutral, 20), text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 2, 6, f_level_emoji_rsi(rsi_tf5) + f_buysell_emoji(rsi_tf5) + str.tostring(rsi_tf5, "#.0"), text_color = c_tf5_dot,           text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_right)
    table.cell(legend, 3, 6, trend_tf5,               text_color = c_tf5_dot,                text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 4, 6, show_div_column ? (bear_div_tf5 ? "🔻" : bull_div_tf5 ? "🔺" : "—") : "",  text_color = bear_div_tf5 ? c_up_3 : bull_div_tf5 ? c_dn_1 : c_neutral,  text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)
    table.cell(legend, 5, 6, show_state_column ? f_state_name_rsi(rsi_tf5) : "", text_color = c_tf5_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 65), text_halign = text.align_center)

    // === Row 7 — Master (cols 0-1 merged) ===
    table.merge_cells(legend, 0, 7, 1, 7)
    table.cell(legend, 0, 7, "🌈 Master (~" + master_eff_label + ")", text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_left)
    table.cell(legend, 2, 7, f_level_emoji_rsi(rsi_master) + f_buysell_emoji(rsi_master) + str.tostring(rsi_master, "#.0"), text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_right)
    table.cell(legend, 3, 7, trend_master,            text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 4, 7, show_div_column ? (bear_div_master ? "🔻" : bull_div_master ? "🔺" : "—") : "",  text_color = bear_div_master ? c_up_3 : bull_div_master ? c_dn_1 : c_master_dot,  text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)
    table.cell(legend, 5, 7, show_state_column ? f_state_name_rsi(rsi_master) : "", text_color = c_master_dot, text_size = sz_tbl, bgcolor = color.new(c_black, 60), text_halign = text.align_center)

    // === Row 8 — Divergence summary (merged 6 cols) ===
    table.merge_cells(legend, 0, 8, 5, 8)
    table.cell(legend, 0, 8, status_txt,
         text_color = status_fg, text_size = sz_lbl,
         bgcolor = status_bg, text_halign = text.align_center)

// ========================================================================================================
// ACTIVE SYMBOL LABEL (configurable corner of the indicator pane — default Top Left)
//   Shows which symbol the indicator is actually reading. 🔒 prefix + orange text = Symbol Override
//   active (the indicator stays on that symbol even if the chart is switched to another asset).
// ========================================================================================================
var table sym_label_tbl = table.new(f_position(sym_label_pos), 1, 1, border_width = 0, frame_width = 1, frame_color = color.new(c_black, 20), force_overlay = false)

if barstate.islast and show_symbol_label
    string sym_disp = active_sym
    if str.contains(active_sym, ":")
        array<string> sym_parts = str.split(active_sym, ":")
        sym_disp := array.get(sym_parts, array.size(sym_parts) - 1)
    table.cell(sym_label_tbl, 0, 0, (sym_locked ? "🔒 " : "") + sym_disp,
         text_color  = sym_locked ? c_up_2 : color.new(c_neutral, 0),
         text_size   = sz_lbl,
         bgcolor     = color.new(c_black, sym_locked ? 20 : 40),
         text_halign = text.align_center)

// ========================================================================================================
// ALERTS (all gated by barstate.isconfirmed — anti-flicker, see hard rule #7)
// ========================================================================================================
// Black Swan glow state (hysteresis — LIT when transparency <= 70, i.e. Master within ~2/3 of the
// glow range of the line; EXTINGUISHED when transparency >= 90, i.e. Master retreated ~full range away).
// The glow-off event fires once per episode, on the confirmed bar where the state flips to extinguished.
var bool bs_glow_high_lit = false
var bool bs_glow_low_lit  = false
bool bs_glow_high_off = false
bool bs_glow_low_off  = false
if barstate.isconfirmed
    if not bs_glow_high_lit and transp_bs_high <= 70
        bs_glow_high_lit := true
    else if bs_glow_high_lit and transp_bs_high >= 90
        bs_glow_high_lit := false
        bs_glow_high_off := true
    if not bs_glow_low_lit and transp_bs_low <= 70
        bs_glow_low_lit := true
    else if bs_glow_low_lit and transp_bs_low >= 90
        bs_glow_low_lit := false
        bs_glow_low_off := true

bool cross_up_bs    = ta.crossover(rsi_master, black_swan_high) and barstate.isconfirmed
bool cross_dn_bs    = ta.crossunder(rsi_master, black_swan_low) and barstate.isconfirmed
bool entered_red    = ta.crossover(rsi_master, osc_up3)  and barstate.isconfirmed
bool entered_blue   = ta.crossunder(rsi_master, osc_dn3) and barstate.isconfirmed
bool new_div_strong = div_strong and not div_strong[1]

if cross_up_bs and alert_blackswan_high
    alert(s_al_bs_high_pre + str.tostring(black_swan_high, "#.0") + s_al_bs_mid + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

if cross_dn_bs and alert_blackswan_low
    alert(s_al_bs_low_pre + str.tostring(black_swan_low, "#.0") + s_al_bs_mid + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

if bs_glow_high_off and alert_bs_glow_off_high
    alert(s_al_bs_glow_high_pre + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

if bs_glow_low_off and alert_bs_glow_off_low
    alert(s_al_bs_glow_low_pre + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

if new_div_strong and alert_divergence
    string dir_txt = div_strong_top ? s_al_div_top : s_al_div_bottom
    alert(s_al_div_pre + dir_txt + s_al_div_tf1 + str.tostring(rsi_tf1, "#.0") + s_al_div_tf5 + str.tostring(rsi_tf5, "#.0"), alert.freq_once_per_bar)

if entered_red and alert_master_extreme
    alert(s_al_red_pre + str.tostring(rsi_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if entered_blue and alert_master_extreme
    alert(s_al_blue_pre + str.tostring(rsi_master, "#.0") + s_al_zone_close, alert.freq_once_per_bar)

if bear_div_master and alert_divergence_native
    alert(s_al_div_master_bear_pre + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

if bull_div_master and alert_divergence_native
    alert(s_al_div_master_bull_pre + str.tostring(rsi_master, "#.0"), alert.freq_once_per_bar)

// Billboard alertcondition (UX hint — instructs users on alert setup workflow)
alertcondition(false, title = "HOW TO SETUP ALERTS (READ)", message = "Please select 'Any alert() function call' in the condition menu. You can filter which alerts you receive inside the Indicator Settings (Gear Icon).")
````

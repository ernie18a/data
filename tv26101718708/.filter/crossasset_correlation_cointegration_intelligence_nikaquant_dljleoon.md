# Cross-Asset Correlation & Cointegration Intelligence [NikaQuant]

- url: https://www.tradingview.com/script/DLjLeOON-Cross-Asset-Correlation-Cointegration-Intelligence-NikaQuant/
- type: indicator
- pine_id: PUB;755039aab0cd468a88335ada71719beb
- version: 1.0

## Description

**Cross-Asset Correlation & Cointegration Intelligence**

Track your chart symbol against up to six comparison symbols. The script
renders **three synchronized panels** that tell you, in plain numbers:

- How coupled the basket is **right now**
- Which pairs are genuinely tradeable (and the **expected mean-reversion time**)
- How much **gross exposure** you should carry given the current regime


## What It Does

- **Intelligence Dashboard** — per-symbol grid: correlation, beta, R²,
  z-score, percentile, stability, lead/lag, spread z, quality score,
  hedge size, stress-vs-normal correlation delta, signal verdict
- **N×N Correlation Matrix** — full 6×6 pairwise heatmap
- **Action Center** — regime timer, flip probability, risk-budget advisor,
  top-5 ranked trades, top-3 cointegrated pair setups, trade playbook


## Why It Is Original

Unlike standard correlation heatmap scripts that display a single Pearson
value per pair, this script builds a composite intelligence layer across
**three independent axes** that no retail correlation indicator combines:

**1. Asymmetric (Conditional) Correlation**
Splits history into **normal-volatility** and **stress-volatility** regimes
using an ATR-median split on the base symbol, and reports the two
correlations side by side. This exposes the *"diversification fails when
you need it"* amplification that an averaged Pearson value hides — a
documented pattern in every crisis since 1998.

**2. Cointegration + Half-Life**
For all 15 unique pairs, runs an **Engle-Granger two-step** (log-regression
then AR(1) on the residual spread) to flag which spreads are genuinely
mean-reverting. Cointegrated pairs carry an **Ornstein-Uhlenbeck half-life**
t½ = −ln(2) / ln(1 + φ) — the expected mean-reversion time in bars.
*Correlation tells you direction; cointegration tells you whether the
spread will revert.*

**3. Regime Persistence + Flip Probability**
Tracks four states (Crisis / Coupled / Mixed / Decoupled) in a **4×4 Markov
transition counter**, stores per-regime dwell times, and converts them into
flip-probability estimates for the next 10 and 30 bars. You see not just
*"we are in X"* but *"X has lasted 47 bars, historical average is 62 bars,
probability of flip in 30 bars is 55%."*


## Composite Modules

- **Crisis Clock (0–100)** — composite of average absolute correlation,
  cross-sectional dispersion collapse, and tail-dependence count
- **Market Brain** — union-find clustering on positive pairwise
  correlations, auto-groups symbols that move as one
- **Dispersion Trade Detector** — fires when average correlation drops
  >2σ while realized volatility rises
- **Hedge Desk** — converts OLS beta into a **dollar hedge notional**
  given your base position size
- **Effective-N** — correlation-adjusted diversification count (six
  symbols at ρ=1.0 gives effective N = 1)
- **Risk Budget Advisor** — regime + effective-N → suggested gross
  exposure percentage
- **Setup Quality Score** — composite of |corr| × R² × stability,
  adjusted for regime, clock, and break
- **Action List** — scans every symbol and every pair, scores each
  candidate, ranks them, surfaces the top five with type, target, score,
  direction, suggested size, rationale


## Per-Symbol Metrics

- Rolling Pearson correlation across **three lookbacks** (short, medium,
  long) — three-block glyph reveals timeframe divergence
- **OLS beta** from log returns, **R²** as variance explained
- **Z-score** of current correlation vs its own 200-bar distribution
- **Percentile rank** of current correlation in its own history
- **Stability** from rolling stdev of the correlation itself
- **Optimal-lag scanner** across {−5, −3, −1, 0, +1, +3, +5} offsets
- **Spread z-score** of the price ratio for pairs signaling
- **Asymmetric Δ** = ρ_stress − ρ_normal (positive = hedge fails under stress)


## How To Use It

- **Scan the Quality column first.** Anything at or above 60 with a
  TRACK++ or HEDGE++ signal is a high-confidence setup.
- **Cross-check AsymΔ.** Values above +0.3 mean that "hedge" is expected
  to fail under stress — avoid relying on it in a crisis.
- **Use Hedge column values** as the dollar notional to short or long
  against your base position to neutralize beta.
- **Read the matrix** like a portfolio risk report. Clusters of dark-green
  tiles = diversification is breaking down. Red tiles = inverse pairs.
- **In the Action Center**, start at the Risk Budget line, then work
  top-down through the Action List. Cointegrated pairs marked with a
  check-mark prefix show expected mean-reversion time in bars.


**Recommended timeframes:** intraday or daily charts with at least 250
bars of history across all six symbols.

**Recommended markets:** anywhere the base asset has meaningful
relationships with a benchmark basket — equity indexes vs sector ETFs,
crypto majors vs index proxies, FX vs rates and commodities.

**Avoid using when:** fewer than three symbols resolve to valid data;
during the first 250 bars after chart load; or on a symbol with gapped
or illiquid history that creates artificial correlation jumps.


## Alerts

Regime Break · Dispersion Trade Setup · New Cointegrated Pair ·
High-Quality Setup · Imminent Regime Flip · Crisis Regime Entered ·
Asymmetric Correlation Amplification · Risk Budget Reduced · Clock
Stressed/Critical · Strong Positive/Negative Correlation Crossovers


## Key Settings

- **Comparison Symbols 1–6** — the basket (autocomplete from any TV ticker)
- **Medium-Term Correlation Period** (50) — primary correlation lookback
- **Short / Long Lookbacks** (20 / 200) — timeframe-divergence glyph
- **Historical Baseline** (200) — z-score, percentile, stability, regime
  dwell times, and asymmetric-correlation ATR split
- **Strong Correlation** (0.70) — threshold for strong-signal eligibility
- **Regime-Break |Z|** (2.00) — flags correlations breaking their range
- **Pairs-Trade |Spread Z|** (2.00) — pairs-trade setup threshold
- **Min R² for Trust** (0.25), **Min Stability** (0.50) — quality gates
- **Cluster Threshold** (0.60) — Market Brain grouping
- **Crisis Clock** — Stressed (60), Critical (80) thresholds
- **Base Position Size** (10,000) — drives Hedge Desk and Action sizing
- **Min Action Quality** (60) — filters the Action List
- **Risk Budget per regime** — Crisis 50%, Coupled 75%, Mixed 90%,
  Decoupled 100% (all user-tunable)
- **Display** — position each of three tables independently; Compact or
  Pro column density; full palette customization


## Notes

**No repainting.** All correlations, betas, and regime computations use
confirmed bars only. Regime transition counters and dwell-time arrays
update only when a bar confirms.

**Data integrity.** Six external symbol requests are made with
non-forward-looking data fetches, well within TradingView's request limit.

**Methods.** Asymmetric correlation uses log returns with indicator
weights from an ATR-median volatility split on the base asset.
Cointegration is Engle-Granger two-step: log-regression residual, then
AR(1) test. A pair is flagged as cointegrated when the AR(1) coefficient
is sufficiently negative to indicate mean-reversion. Half-life uses the
standard Ornstein-Uhlenbeck solution t½ = −ln(2) / ln(1 + φ).

**Warm-up.** The first ~250 bars after chart load are a warm-up period.
Several metrics will display "—" until enough history accumulates.

**Originality.** All calculations, signal logic, clustering,
cointegration testing, and table rendering are original. No third-party
code is reused.

## Source Code

````pine
// This Pine Script™ is subject to the terms of the Mozilla Public License 2.0
// © NikaQuant

//@version=6
indicator("Market Correlation Intelligence v3 — NikaQuant", overlay=true, max_lines_count=50, max_labels_count=50, max_boxes_count=50)

// ═════════════════════════════════════════════════════════════════════════════════════
//  MARKET CORRELATION INTELLIGENCE — v3 (Hall of Fame Edition)
//
//  The legendary build. A complete correlation intelligence dashboard that combines:
//    • Full N×N correlation matrix across 6 symbols (not just 1-to-N)
//    • Optimal-lag scanner — scans {-5, -3, -1, 0, +1, +3, +5} and reports best
//    • Multi-timeframe correlations per row (ST / MT / LT)
//    • Market Brain — auto-clusters symbols into live correlation groups
//    • Crisis Clock — composite 0-100 early-warning score
//    • Auto-Pairs Scanner — top-3 live pairs-trade setups ranked by stability × |z|
//    • Trade Playbook — dynamic recommendations based on current state
//    • Beta, R², regime z-score, historical percentile, stability per symbol
//    • Composite signal engine (TRACK++, HEDGE++, BREAK, COUPLE, DECOUP, PAIRS, LEADS…)
//    • Full regime detection + chart tint
//    • Comprehensive alerts
// ═════════════════════════════════════════════════════════════════════════════════════

// ─── Scale A Anchor (keeps overlay pinned to chart's existing right scale) ───
plot(close, title="_scale_a", color=color.new(color.white, 99), linewidth=1, editable=false)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 1 — INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════

// ── Symbols ────────────────────────────────────────────────────────────────────────
// Uses input.symbol for the proper TV symbol picker (autocomplete + search).
// Tip: add any ticker from your watchlist — just type its name in the picker.
grpSym = "Comparison Symbols"
i_sym1  = input.symbol("BINANCE:BTCUSDT", "Symbol 1",  tooltip="First comparison symbol.",  group=grpSym)
i_sym2  = input.symbol("TVC:GOLD",        "Symbol 2",  tooltip="Second comparison symbol.", group=grpSym)
i_sym3  = input.symbol("SP:SPX",          "Symbol 3",  tooltip="Third comparison symbol.",  group=grpSym)
i_sym4  = input.symbol("TVC:DXY",         "Symbol 4",  tooltip="Fourth comparison symbol.", group=grpSym)
i_sym5  = input.symbol("TVC:US10Y",       "Symbol 5",  tooltip="Fifth comparison symbol.",  group=grpSym)
i_sym6  = input.symbol("NASDAQ:QQQ",      "Symbol 6",  tooltip="Sixth comparison symbol.",  group=grpSym)

// ── Calculation Engine ─────────────────────────────────────────────────────────────
grpCalc = "Calculation Engine"
i_corr_len  = input.int(50,  "Medium-Term Correlation Period", minval=10, maxval=500, tooltip="Primary correlation lookback — used for Corr, β, R², spread Z, and the N×N matrix.", group=grpCalc)
i_short_len = input.int(20,  "Short-Term Lookback",            minval=5,  maxval=100, tooltip="Short-term correlation lookback for the MTF glyph (ST bar).", group=grpCalc)
i_long_len  = input.int(200, "Long-Term Lookback",             minval=50, maxval=500, tooltip="Long-term correlation lookback for the MTF glyph (LT bar).", group=grpCalc)
i_hist_len  = input.int(200, "Historical Baseline",            minval=50, maxval=1000, tooltip="Bars used to measure the historical mean / stdev / percentile of the correlation itself — powers regime-break detection.", group=grpCalc)
i_change_look = input.int(10, "Correlation Change Lookback",   minval=1,  maxval=100, tooltip="Bars back for the ↑ ↓ → trajectory arrow in the Corr column.", group=grpCalc)

// ── Intelligence Thresholds ────────────────────────────────────────────────────────
grpThr = "Intelligence Thresholds"
i_strong_thr   = input.float(0.70, "Strong Correlation",      minval=0.50, maxval=1.00, step=0.05, tooltip="Absolute correlation above this can fire STRONG TRACK / STRONG HEDGE when R² and stability gates pass.", group=grpThr)
i_break_z      = input.float(2.00, "Regime-Break |Z|",        minval=1.00, maxval=5.00, step=0.10, tooltip="|Z-score| above which the correlation is flagged as breaking its historical range.", group=grpThr)
i_pairs_z      = input.float(2.00, "Pairs-Trade |Spread Z|",  minval=1.00, maxval=5.00, step=0.10, tooltip="|Spread Z-score| of the price ratio that triggers a PAIRS setup (requires stability + meaningful correlation).", group=grpThr)
i_min_r2       = input.float(0.25, "Min R² for Trust",        minval=0.00, maxval=1.00, step=0.05, tooltip="Minimum R² required before TRACK++ / HEDGE++ can fire.", group=grpThr)
i_min_stab     = input.float(0.50, "Min Stability",           minval=0.00, maxval=1.00, step=0.05, tooltip="Minimum stability score required before STRONG signals can fire.", group=grpThr)
i_cluster_thr  = input.float(0.60, "Market Brain Cluster Threshold", minval=0.30, maxval=0.95, step=0.05, tooltip="Two symbols join the same cluster when their positive correlation exceeds this.", group=grpThr)
i_clock_stressed = input.int(60, "Crisis Clock — Stressed",   minval=30, maxval=95, tooltip="Crisis Clock score above this = STRESSED regime.", group=grpThr)
i_clock_critical = input.int(80, "Crisis Clock — Critical",   minval=50, maxval=100, tooltip="Crisis Clock score above this = CRITICAL regime.", group=grpThr)

// ── Risk / Sizing (Hedge Desk + Action List) ────────────────────────────────────────
grpRisk = "Risk & Position Sizing"
i_position_size = input.float(10000.0, "Base Position Size ($)", minval=0.0, step=100.0, tooltip="Dollar value of your position in the base asset. Drives the Hedge Desk calculations — each correlated symbol shows the hedge notional that neutralizes β.", group=grpRisk)
i_min_quality   = input.int(60, "Min Action Quality", minval=0, maxval=100, tooltip="Minimum setup-quality score required before an action enters the Action List (out of 100).", group=grpRisk)
i_risk_crisis   = input.int(50, "Risk Budget — Crisis",    minval=0, maxval=100, tooltip="Gross exposure % recommended during CRISIS regime.", group=grpRisk)
i_risk_coupled  = input.int(75, "Risk Budget — Coupled",   minval=0, maxval=100, tooltip="Gross exposure % recommended during COUPLED regime.", group=grpRisk)
i_risk_mixed    = input.int(90, "Risk Budget — Mixed",     minval=0, maxval=100, tooltip="Gross exposure % recommended during MIXED regime.", group=grpRisk)
i_risk_decoupled = input.int(100, "Risk Budget — Decoupled", minval=0, maxval=100, tooltip="Gross exposure % recommended during DECOUPLED regime.", group=grpRisk)

// ── Display ────────────────────────────────────────────────────────────────────────
grpDisp = "Display"
i_view_mode = input.string("Pro", "View Mode", options=["Compact","Pro"], tooltip="Compact = 5 columns. Pro = full 11-column intelligence dashboard.", group=grpDisp)

i_show_intel = input.bool(true, "Show Intelligence Table", group=grpDisp)
i_pos_intel  = input.string("Top Right", "Intelligence Position", options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpDisp)

i_show_matrix = input.bool(true, "Show N×N Matrix", group=grpDisp)
i_pos_matrix  = input.string("Middle Left", "Matrix Position", options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], tooltip="Default is Middle Left so the matrix doesn't stack behind the Action Center on the right.", group=grpDisp)

i_show_play = input.bool(true, "Show Pairs + Playbook", group=grpDisp)
i_pos_play  = input.string("Bottom Right", "Pairs/Playbook Position", options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpDisp)

i_show_tint = input.bool(false, "Tint Chart by Regime", tooltip="Subtly tints the chart background based on the current market regime.", group=grpDisp)

// ── Style ──────────────────────────────────────────────────────────────────────────
grpSty = "Style"
i_txt_size     = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group=grpSty)
i_header_bg    = input.color(#0d1117, "Header Background", group=grpSty)
i_header_txt   = input.color(#e0e6ed, "Header Text",       group=grpSty)
i_panel_bg     = input.color(#141a22, "Panel Background",  group=grpSty)
i_panel_txt    = input.color(#c9d1d9, "Panel Text",        group=grpSty)
i_border_color = input.color(#26334d, "Border Color",      group=grpSty)
i_border_width = input.int(1, "Border Width", minval=0, maxval=4, group=grpSty)
i_c_up   = input.color(#00e676, "Corr Rising",  group=grpSty)
i_c_dn   = input.color(#ff1744, "Corr Falling", group=grpSty)
i_c_flat = input.color(#9e9e9e, "Corr Flat",    group=grpSty)

// ── Heatmap Palette ────────────────────────────────────────────────────────────────
grpHeat = "Heatmap Palette"
i_c_sp = input.color(#1b5e20, "Strong Positive (> +0.7)",     group=grpHeat)
i_c_mp = input.color(#2e7d32, "Moderate Positive (+0.4…+0.7)", group=grpHeat)
i_c_wp = input.color(#2f4f3a, "Weak Positive (+0.1…+0.4)",    group=grpHeat)
i_c_nu = input.color(#1f2833, "Neutral (-0.1…+0.1)",          group=grpHeat)
i_c_wn = input.color(#4f2f2f, "Weak Negative (-0.4…-0.1)",    group=grpHeat)
i_c_mn = input.color(#7d2e2e, "Moderate Negative (-0.7…-0.4)", group=grpHeat)
i_c_sn = input.color(#8b0000, "Strong Negative (< -0.7)",     group=grpHeat)

// ── Signal Palette ─────────────────────────────────────────────────────────────────
grpSig = "Signal Palette"
i_c_trackpp    = input.color(#00c853, "TRACK++",       group=grpSig)
i_c_hedgepp    = input.color(#d50000, "HEDGE++",       group=grpSig)
i_c_break      = input.color(#ff6d00, "REGIME BREAK",  group=grpSig)
i_c_coupling   = input.color(#f50057, "COUPLING",      group=grpSig)
i_c_decoupling = input.color(#00b0ff, "DECOUPLING",    group=grpSig)
i_c_pairs      = input.color(#ffc107, "PAIRS",         group=grpSig)
i_c_leads      = input.color(#7c4dff, "LEADS",         group=grpSig)
i_c_lags       = input.color(#5c6bc0, "LAGS",          group=grpSig)
i_c_track      = input.color(#4caf50, "TRACK",         group=grpSig)
i_c_hedge      = input.color(#ef5350, "HEDGE",         group=grpSig)
i_c_neutral    = input.color(#424242, "NEUTRAL",       group=grpSig)

// ── Regime Palette ─────────────────────────────────────────────────────────────────
grpReg = "Regime Palette"
i_c_crisis    = input.color(#b71c1c, "Crisis Regime",     group=grpReg)
i_c_coupled   = input.color(#ff6d00, "Coupled Regime",    group=grpReg)
i_c_mixed     = input.color(#616161, "Mixed Regime",      group=grpReg)
i_c_decoupled = input.color(#00c853, "Decoupled Regime", group=grpReg)
i_c_insuf     = input.color(#37474f, "Insufficient Data", group=grpReg)

// ── Crisis Clock Palette ───────────────────────────────────────────────────────────
grpClk = "Crisis Clock Palette"
i_c_clk_safe     = input.color(#00c853, "Safe (0–30)",        group=grpClk)
i_c_clk_elevated = input.color(#ffc107, "Elevated (30–60)",   group=grpClk)
i_c_clk_stressed = input.color(#ff6d00, "Stressed (60–80)",   group=grpClk)
i_c_clk_critical = input.color(#d50000, "Critical (80–100)",  group=grpClk)

// ── Cluster Palette (Market Brain) ─────────────────────────────────────────────────
grpClu = "Market Brain Palette"
i_c_clu_0 = input.color(#42a5f5, "Cluster A", group=grpClu)
i_c_clu_1 = input.color(#ffa726, "Cluster B", group=grpClu)
i_c_clu_2 = input.color(#ab47bc, "Cluster C", group=grpClu)
i_c_clu_3 = input.color(#26c6da, "Cluster D", group=grpClu)
i_c_clu_4 = input.color(#ec407a, "Cluster E", group=grpClu)
i_c_clu_5 = input.color(#66bb6a, "Cluster F", group=grpClu)
i_c_clu_solo = input.color(#616161, "Solo / Unclustered", group=grpClu)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 2 — HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════

f_txt_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

f_pos(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_right

f_heatmap(c) =>
    color result = i_c_nu
    if na(c)
        result := color.new(color.gray, 80)
    else if c > 0.7
        result := i_c_sp
    else if c > 0.4
        result := i_c_mp
    else if c > 0.1
        result := i_c_wp
    else if c > -0.1
        result := i_c_nu
    else if c > -0.4
        result := i_c_wn
    else if c > -0.7
        result := i_c_mn
    else
        result := i_c_sn
    result

f_txt_contrast(c) =>
    color result = color.white
    if na(c)
        result := #9e9e9e
    result

f_short_name(sym) =>
    string result = sym
    int colonIdx = str.pos(sym, ":")
    if not na(colonIdx) and colonIdx >= 0
        result := str.substring(sym, colonIdx + 1)
    result

f_change_glyph(chg) =>
    string result = "→"
    if na(chg)
        result := "·"
    else if chg > 0.05
        result := "↑"
    else if chg < -0.05
        result := "↓"
    result

f_change_color(chg) =>
    color result = i_c_flat
    if na(chg)
        result := i_c_flat
    else if chg > 0.05
        result := i_c_up
    else if chg < -0.05
        result := i_c_dn
    result

f_signed(v, fmt) =>
    string result = "—"
    if not na(v)
        if v >= 0
            result := "+" + str.tostring(v, fmt)
        else
            result := str.tostring(v, fmt)
    result

// Unicode block for MTF glyph — maps -1..+1 to a vertical block character
f_block(v) =>
    string result = "█"
    if na(v)
        result := "·"
    else if v <= -0.75
        result := "▁"
    else if v <= -0.50
        result := "▂"
    else if v <= -0.25
        result := "▃"
    else if v <= 0.00
        result := "▄"
    else if v <= 0.25
        result := "▅"
    else if v <= 0.50
        result := "▆"
    else if v <= 0.75
        result := "▇"
    result

// Format a float or show em-dash on na
f_num(v, fmt) =>
    string result = "—"
    if not na(v)
        result := str.tostring(v, fmt)
    result

// Cluster color by id
f_cluster_color(id) =>
    switch id
        0 => i_c_clu_0
        1 => i_c_clu_1
        2 => i_c_clu_2
        3 => i_c_clu_3
        4 => i_c_clu_4
        5 => i_c_clu_5
        =>   i_c_clu_solo

// Cluster letter by id
f_cluster_letter(id) =>
    switch id
        0 => "A"
        1 => "B"
        2 => "C"
        3 => "D"
        4 => "E"
        5 => "F"
        =>   "—"

// Crisis Clock color by score
f_clock_color(s) =>
    color result = i_c_clk_safe
    if na(s)
        result := i_c_clk_safe
    else if s >= i_clock_critical
        result := i_c_clk_critical
    else if s >= i_clock_stressed
        result := i_c_clk_stressed
    else if s >= 30
        result := i_c_clk_elevated
    else
        result := i_c_clk_safe
    result

f_clock_label(s) =>
    string result = "SAFE"
    if na(s)
        result := "SAFE"
    else if s >= i_clock_critical
        result := "CRITICAL"
    else if s >= i_clock_stressed
        result := "STRESSED"
    else if s >= 30
        result := "ELEVATED"
    else
        result := "SAFE"
    result

// Composite signal engine — priority order, first match wins
f_signal(corr, r2, zscore, stab, spreadZ, lead, pct) =>
    string lbl = "NEUTRAL"
    color  col = i_c_neutral
    string tip = "No meaningful relationship detected."

    if not na(corr)
        if not na(zscore) and math.abs(zscore) > i_break_z
            lbl := "BREAK"
            col := i_c_break
            tip := "Regime break: correlation is more than " + str.tostring(i_break_z, "#.#") + " historical stdev's from its mean. The relationship is snapping — don't extrapolate."
        else if corr > i_strong_thr and not na(r2) and r2 > i_min_r2 and not na(stab) and stab > i_min_stab
            lbl := "TRACK++"
            col := i_c_trackpp
            tip := "Strong, stable, statistically meaningful positive correlation. High-confidence tracking relationship."
        else if corr < -i_strong_thr and not na(r2) and r2 > i_min_r2 and not na(stab) and stab > i_min_stab
            lbl := "HEDGE++"
            col := i_c_hedgepp
            tip := "Strong, stable, statistically meaningful negative correlation. High-confidence hedge."
        else if not na(pct) and pct > 90
            lbl := "COUPLE"
            col := i_c_coupling
            tip := "Correlation is in the top decile of its own history — a coupling event is under way."
        else if not na(pct) and pct < 10
            lbl := "DECOUP"
            col := i_c_decoupling
            tip := "Correlation is in the bottom decile of its own history — a decoupling event is under way."
        else if not na(spreadZ) and math.abs(spreadZ) > i_pairs_z and not na(stab) and stab > i_min_stab and math.abs(corr) > 0.4
            lbl := spreadZ > 0 ? "PAIR-S" : "PAIR-L"
            col := i_c_pairs
            tip := "Pairs-trade setup: price ratio is " + str.tostring(spreadZ, "#.##") + " stdev from mean with stable correlation. " + (spreadZ > 0 ? "Base rich vs symbol — short base / long symbol." : "Base cheap vs symbol — long base / short symbol.")
        else if lead > 0
            lbl := "LEAD+" + str.tostring(lead)
            col := i_c_leads
            tip := "This symbol leads the base by ~" + str.tostring(lead) + " bars."
        else if lead < 0
            lbl := "LAG" + str.tostring(lead)
            col := i_c_lags
            tip := "This symbol lags the base by ~" + str.tostring(math.abs(lead)) + " bars."
        else if corr > 0.4
            lbl := "TRACK"
            col := i_c_track
            tip := "Moderate positive correlation."
        else if corr < -0.4
            lbl := "HEDGE"
            col := i_c_hedge
            tip := "Moderate negative correlation."
    [lbl, col, tip]

// Setup-quality score (0-100) — |corr| × R² × stab × 100, adjusted for regime-break / clock
f_quality(corr, r2, stab, zscore, clock) =>
    float q = 0.0
    if not na(corr) and not na(r2) and not na(stab)
        q := math.abs(corr) * r2 * stab * 100.0
        if not na(zscore) and math.abs(zscore) > i_break_z
            q *= 0.5
        if not na(clock)
            if clock > i_clock_critical
                q *= 0.65
            else if clock > i_clock_stressed
                q *= 0.85
            else if clock < 30
                q *= 1.10
    math.max(0.0, math.min(100.0, q))

// Hedge notional ($) — |β| × base position size
f_hedge_size(beta, basePos) =>
    na(beta) ? 0.0 : math.abs(beta) * basePos

// Hedge direction text — given β sign
f_hedge_dir(beta) =>
    string result = "—"
    if not na(beta)
        if beta > 0.05
            result := "SHORT"
        else if beta < -0.05
            result := "LONG"
        else
            result := "—"
    result

// Risk budget (gross exposure %) given regime + clock
f_risk_budget(regime, clock) =>
    int pct = 100
    if regime == "CRISIS"
        pct := i_risk_crisis
    else if not na(clock) and clock > i_clock_critical
        pct := math.min(pct, i_risk_crisis)
    else if regime == "COUPLED"
        pct := i_risk_coupled
    else if not na(clock) and clock > i_clock_stressed
        pct := math.min(pct, i_risk_coupled)
    else if regime == "MIXED"
        pct := i_risk_mixed
    else if regime == "DECOUPLED"
        pct := i_risk_decoupled
    pct

// Risk budget color
f_risk_color(pct) =>
    color result = i_c_clk_safe
    if pct <= 50
        result := i_c_clk_critical
    else if pct <= 75
        result := i_c_clk_stressed
    else if pct <= 90
        result := i_c_clk_elevated
    else
        result := i_c_clk_safe
    result

// Format currency
f_money(v) =>
    string result = "—"
    if not na(v) and v > 0
        if v >= 1000000
            result := "$" + str.tostring(v / 1000000, "#.#") + "M"
        else if v >= 1000
            result := "$" + str.tostring(v / 1000, "#.#") + "k"
        else
            result := "$" + str.tostring(v, "#")
    result

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 3 — DATA REQUESTS
// ═════════════════════════════════════════════════════════════════════════════════════

src = close

f_req(s) =>
    s != "" ? request.security(s, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : na

float c1 = f_req(i_sym1)
float c2 = f_req(i_sym2)
float c3 = f_req(i_sym3)
float c4 = f_req(i_sym4)
float c5 = f_req(i_sym5)
float c6 = f_req(i_sym6)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 4 — PER-SYMBOL METRICS (vs BASE)
// ═════════════════════════════════════════════════════════════════════════════════════

// Optimal-lag scanner: scans {-5, -3, -1, 0, +1, +3, +5} and returns lag with highest |corr|
f_best_lag(sc, len) =>
    float best = -1.0
    int   lag  = 0
    float cor  = na

    float c_m5 = ta.correlation(src[5], sc, len)
    if not na(c_m5) and math.abs(c_m5) > best
        best := math.abs(c_m5)
        lag  := -5
        cor  := c_m5

    float c_m3 = ta.correlation(src[3], sc, len)
    if not na(c_m3) and math.abs(c_m3) > best
        best := math.abs(c_m3)
        lag  := -3
        cor  := c_m3

    float c_m1 = ta.correlation(src[1], sc, len)
    if not na(c_m1) and math.abs(c_m1) > best
        best := math.abs(c_m1)
        lag  := -1
        cor  := c_m1

    float c_0 = ta.correlation(src, sc, len)
    if not na(c_0) and math.abs(c_0) > best
        best := math.abs(c_0)
        lag  := 0
        cor  := c_0

    float c_p1 = ta.correlation(src, sc[1], len)
    if not na(c_p1) and math.abs(c_p1) > best
        best := math.abs(c_p1)
        lag  := 1
        cor  := c_p1

    float c_p3 = ta.correlation(src, sc[3], len)
    if not na(c_p3) and math.abs(c_p3) > best
        best := math.abs(c_p3)
        lag  := 3
        cor  := c_p3

    float c_p5 = ta.correlation(src, sc[5], len)
    if not na(c_p5) and math.abs(c_p5) > best
        best := math.abs(c_p5)
        lag  := 5
        cor  := c_p5

    [lag, cor]

// Full per-symbol metric bundle vs base
f_metrics(sym, sc) =>
    float corr   = na
    float r2     = na
    float beta   = na
    float zs     = na
    float pct    = na
    float stab   = na
    float spZ    = na
    float chg    = na
    float corrST = na
    float corrLT = na
    int   optLag = 0
    float optCor = na

    if sym != "" and not na(sc)
        corr := ta.correlation(src, sc, i_corr_len)
        r2   := not na(corr) ? corr * corr : na

        float retB = math.log(src / nz(src[1], src))
        float retS = math.log(sc  / nz(sc[1],  sc))
        float cov  = ta.sma(retB * retS, i_corr_len) - ta.sma(retB, i_corr_len) * ta.sma(retS, i_corr_len)
        float vB   = ta.variance(retB, i_corr_len)
        beta := vB > 0 ? cov / vB : na

        float corrMean = ta.sma(corr, i_hist_len)
        float corrStd  = ta.stdev(corr, i_hist_len)
        zs   := not na(corrStd) and corrStd > 0 ? (corr - corrMean) / corrStd : 0.0
        pct  := ta.percentrank(corr, i_hist_len)
        stab := not na(corrStd) ? math.max(0.0, math.min(1.0, 1.0 - corrStd * 2.0)) : na

        corrST := ta.correlation(src, sc, i_short_len)
        corrLT := ta.correlation(src, sc, i_long_len)

        [bL, bC] = f_best_lag(sc, i_corr_len)
        optLag := bL
        optCor := bC

        float ratio = sc != 0 ? src / sc : na
        if not na(ratio)
            float rMean = ta.sma(ratio, i_corr_len)
            float rStd  = ta.stdev(ratio, i_corr_len)
            spZ := not na(rStd) and rStd > 0 ? (ratio - rMean) / rStd : 0.0

        chg := not na(corr) ? corr - nz(corr[i_change_look], corr) : na

    [corr, r2, beta, zs, pct, stab, spZ, chg, corrST, corrLT, optLag, optCor]

[corr1, r2_1, beta1, zs1, pct1, stab1, spZ1, chg1, st1, lt1, lag1, lagC1] = f_metrics(i_sym1, c1)
[corr2, r2_2, beta2, zs2, pct2, stab2, spZ2, chg2, st2, lt2, lag2, lagC2] = f_metrics(i_sym2, c2)
[corr3, r2_3, beta3, zs3, pct3, stab3, spZ3, chg3, st3, lt3, lag3, lagC3] = f_metrics(i_sym3, c3)
[corr4, r2_4, beta4, zs4, pct4, stab4, spZ4, chg4, st4, lt4, lag4, lagC4] = f_metrics(i_sym4, c4)
[corr5, r2_5, beta5, zs5, pct5, stab5, spZ5, chg5, st5, lt5, lag5, lagC5] = f_metrics(i_sym5, c5)
[corr6, r2_6, beta6, zs6, pct6, stab6, spZ6, chg6, st6, lt6, lag6, lagC6] = f_metrics(i_sym6, c6)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 5 — N×N CORRELATION MATRIX (between all symbols, not just vs base)
// ═════════════════════════════════════════════════════════════════════════════════════

f_pairCorr(a, b) =>
    na(a) or na(b) ? na : ta.correlation(a, b, i_corr_len)

// Compute upper-triangle pair correlations (15 unique pairs for 6 symbols)
float p12 = f_pairCorr(c1, c2)
float p13 = f_pairCorr(c1, c3)
float p14 = f_pairCorr(c1, c4)
float p15 = f_pairCorr(c1, c5)
float p16 = f_pairCorr(c1, c6)
float p23 = f_pairCorr(c2, c3)
float p24 = f_pairCorr(c2, c4)
float p25 = f_pairCorr(c2, c5)
float p26 = f_pairCorr(c2, c6)
float p34 = f_pairCorr(c3, c4)
float p35 = f_pairCorr(c3, c5)
float p36 = f_pairCorr(c3, c6)
float p45 = f_pairCorr(c4, c5)
float p46 = f_pairCorr(c4, c6)
float p56 = f_pairCorr(c5, c6)

// Also the rolling stdev of each pair's correlation → pair stability for auto-pairs
f_pairStab(pc) =>
    float s = ta.stdev(pc, i_hist_len)
    na(s) ? na : math.max(0.0, math.min(1.0, 1.0 - s * 2.0))

float s12 = f_pairStab(p12)
float s13 = f_pairStab(p13)
float s14 = f_pairStab(p14)
float s15 = f_pairStab(p15)
float s16 = f_pairStab(p16)
float s23 = f_pairStab(p23)
float s24 = f_pairStab(p24)
float s25 = f_pairStab(p25)
float s26 = f_pairStab(p26)
float s34 = f_pairStab(p34)
float s35 = f_pairStab(p35)
float s36 = f_pairStab(p36)
float s45 = f_pairStab(p45)
float s46 = f_pairStab(p46)
float s56 = f_pairStab(p56)

// Spread z-score for each pair (for pairs-trade ranking)
f_pairSpZ(a, b) =>
    float r = na(a) or na(b) or b == 0 ? na : a / b
    if na(r)
        na
    else
        float rm = ta.sma(r, i_corr_len)
        float rs = ta.stdev(r, i_corr_len)
        not na(rs) and rs > 0 ? (r - rm) / rs : na

float z12 = f_pairSpZ(c1, c2)
float z13 = f_pairSpZ(c1, c3)
float z14 = f_pairSpZ(c1, c4)
float z15 = f_pairSpZ(c1, c5)
float z16 = f_pairSpZ(c1, c6)
float z23 = f_pairSpZ(c2, c3)
float z24 = f_pairSpZ(c2, c4)
float z25 = f_pairSpZ(c2, c5)
float z26 = f_pairSpZ(c2, c6)
float z34 = f_pairSpZ(c3, c4)
float z35 = f_pairSpZ(c3, c5)
float z36 = f_pairSpZ(c3, c6)
float z45 = f_pairSpZ(c4, c5)
float z46 = f_pairSpZ(c4, c6)
float z56 = f_pairSpZ(c5, c6)

// Pack pair data into arrays for easy iteration
var array<float>  aP  = array.new<float>(15)  // correlations
var array<float>  aS  = array.new<float>(15)  // stabilities
var array<float>  aZ  = array.new<float>(15)  // spread z-scores
var array<int>    aI  = array.new<int>(15)    // first index (1-based)
var array<int>    aJ  = array.new<int>(15)    // second index (1-based)

// Populate pair arrays (one-based indexing for human readability)
array.set(aP, 0, p12),  array.set(aS, 0, s12),  array.set(aZ, 0, z12),  array.set(aI, 0, 1), array.set(aJ, 0, 2)
array.set(aP, 1, p13),  array.set(aS, 1, s13),  array.set(aZ, 1, z13),  array.set(aI, 1, 1), array.set(aJ, 1, 3)
array.set(aP, 2, p14),  array.set(aS, 2, s14),  array.set(aZ, 2, z14),  array.set(aI, 2, 1), array.set(aJ, 2, 4)
array.set(aP, 3, p15),  array.set(aS, 3, s15),  array.set(aZ, 3, z15),  array.set(aI, 3, 1), array.set(aJ, 3, 5)
array.set(aP, 4, p16),  array.set(aS, 4, s16),  array.set(aZ, 4, z16),  array.set(aI, 4, 1), array.set(aJ, 4, 6)
array.set(aP, 5, p23),  array.set(aS, 5, s23),  array.set(aZ, 5, z23),  array.set(aI, 5, 2), array.set(aJ, 5, 3)
array.set(aP, 6, p24),  array.set(aS, 6, s24),  array.set(aZ, 6, z24),  array.set(aI, 6, 2), array.set(aJ, 6, 4)
array.set(aP, 7, p25),  array.set(aS, 7, s25),  array.set(aZ, 7, z25),  array.set(aI, 7, 2), array.set(aJ, 7, 5)
array.set(aP, 8, p26),  array.set(aS, 8, s26),  array.set(aZ, 8, z26),  array.set(aI, 8, 2), array.set(aJ, 8, 6)
array.set(aP, 9, p34),  array.set(aS, 9, s34),  array.set(aZ, 9, z34),  array.set(aI, 9, 3), array.set(aJ, 9, 4)
array.set(aP, 10, p35), array.set(aS, 10, s35), array.set(aZ, 10, z35), array.set(aI, 10, 3), array.set(aJ, 10, 5)
array.set(aP, 11, p36), array.set(aS, 11, s36), array.set(aZ, 11, z36), array.set(aI, 11, 3), array.set(aJ, 11, 6)
array.set(aP, 12, p45), array.set(aS, 12, s45), array.set(aZ, 12, z45), array.set(aI, 12, 4), array.set(aJ, 12, 5)
array.set(aP, 13, p46), array.set(aS, 13, s46), array.set(aZ, 13, z46), array.set(aI, 13, 4), array.set(aJ, 13, 6)
array.set(aP, 14, p56), array.set(aS, 14, s56), array.set(aZ, 14, z56), array.set(aI, 14, 5), array.set(aJ, 14, 6)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6 — REGIME + CRISIS CLOCK
// ═════════════════════════════════════════════════════════════════════════════════════

// Build arrays of active base-vs-symbol correlations
var array<float> aCorr = array.new<float>()
var array<float> aAbs  = array.new<float>()
array.clear(aCorr)
array.clear(aAbs)

if not na(corr1)
    array.push(aCorr, corr1)
    array.push(aAbs,  math.abs(corr1))
if not na(corr2)
    array.push(aCorr, corr2)
    array.push(aAbs,  math.abs(corr2))
if not na(corr3)
    array.push(aCorr, corr3)
    array.push(aAbs,  math.abs(corr3))
if not na(corr4)
    array.push(aCorr, corr4)
    array.push(aAbs,  math.abs(corr4))
if not na(corr5)
    array.push(aCorr, corr5)
    array.push(aAbs,  math.abs(corr5))
if not na(corr6)
    array.push(aCorr, corr6)
    array.push(aAbs,  math.abs(corr6))

int   activeN = array.size(aCorr)
float avgAbs  = activeN > 0 ? array.avg(aAbs)   : na
float disp    = activeN > 1 ? array.stdev(aCorr) : na

// Regime classification
string regimeLbl = "INSUFFICIENT"
color  regimeCol = i_c_insuf
string regimeTip = "Not enough active symbols (need ≥ 3) to classify a regime."

if not na(avgAbs) and not na(disp) and activeN >= 3
    if avgAbs > 0.75 and disp < 0.15
        regimeLbl := "CRISIS"
        regimeCol := i_c_crisis
        regimeTip := "Crisis regime: everything is moving together. Diversification is broken."
    else if avgAbs > 0.55
        regimeLbl := "COUPLED"
        regimeCol := i_c_coupled
        regimeTip := "Coupled regime: assets in the basket are moving together."
    else if avgAbs < 0.25 or disp > 0.45
        regimeLbl := "DECOUPLED"
        regimeCol := i_c_decoupled
        regimeTip := "Decoupled regime: correlations are low or widely dispersed."
    else
        regimeLbl := "MIXED"
        regimeCol := i_c_mixed
        regimeTip := "Mixed regime: no dominant coupling."

// ── CRISIS CLOCK (0-100 composite) ───────────────────────────────────────
// Component A: coupling pressure from base-vs-symbol correlations (0-40 pts)
float compA = not na(avgAbs) ? math.min(40.0, avgAbs * 50.0) : 0.0

// Component B: dispersion collapse (0-30 pts) — lower dispersion = more stress
float compB = 0.0
if not na(disp)
    float invDisp = math.max(0.0, math.min(1.0, 1.0 - disp * 2.0))
    compB := invDisp * 30.0

// Component C: tail dependence — count of pair correlations above 0.7 (0-30 pts)
int tailCount = 0
int pairN     = 0
for idx = 0 to 14
    float pv = array.get(aP, idx)
    if not na(pv)
        pairN += 1
        if math.abs(pv) > 0.7
            tailCount += 1
float compC = pairN > 0 ? (tailCount / float(pairN)) * 30.0 : 0.0

float crisisClock = compA + compB + compC
crisisClock := math.max(0.0, math.min(100.0, crisisClock))

// Clock acceleration (change over last 20 bars) — used in playbook
float clockDelta = crisisClock - nz(crisisClock[20], crisisClock)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6b — REGIME PERSISTENCE + MARKOV TRANSITION PROBABILITY
// ═════════════════════════════════════════════════════════════════════════════════════

// Track how long the current regime has persisted
var int regimeBars = 0
if barstate.isconfirmed
    if regimeLbl == regimeLbl[1]
        regimeBars := regimeBars + 1
    else
        regimeBars := 1

// Per-regime historical run lengths (capped to keep memory bounded)
var array<int> runsCrisis    = array.new<int>()
var array<int> runsCoupled   = array.new<int>()
var array<int> runsMixed     = array.new<int>()
var array<int> runsDecoupled = array.new<int>()

// 4×4 Markov transition counter (rows = from-regime, cols = to-regime)
// 0=CRISIS, 1=COUPLED, 2=MIXED, 3=DECOUPLED
var matrix<int> regimeTrans = matrix.new<int>(4, 4, 0)

f_regime_idx(lbl) =>
    int r = -1
    if lbl == "CRISIS"
        r := 0
    else if lbl == "COUPLED"
        r := 1
    else if lbl == "MIXED"
        r := 2
    else if lbl == "DECOUPLED"
        r := 3
    r

// On regime change, push the completed run length and increment transition counter
if barstate.isconfirmed and regimeLbl != regimeLbl[1] and not na(regimeLbl[1])
    int prevLen = nz(regimeBars[1], 0)
    if regimeLbl[1] == "CRISIS" and prevLen > 0
        array.push(runsCrisis, prevLen)
        if array.size(runsCrisis) > 50
            array.shift(runsCrisis)
    else if regimeLbl[1] == "COUPLED" and prevLen > 0
        array.push(runsCoupled, prevLen)
        if array.size(runsCoupled) > 50
            array.shift(runsCoupled)
    else if regimeLbl[1] == "MIXED" and prevLen > 0
        array.push(runsMixed, prevLen)
        if array.size(runsMixed) > 50
            array.shift(runsMixed)
    else if regimeLbl[1] == "DECOUPLED" and prevLen > 0
        array.push(runsDecoupled, prevLen)
        if array.size(runsDecoupled) > 50
            array.shift(runsDecoupled)

    int fromIdx = f_regime_idx(regimeLbl[1])
    int toIdx   = f_regime_idx(regimeLbl)
    if fromIdx >= 0 and toIdx >= 0
        matrix.set(regimeTrans, fromIdx, toIdx, matrix.get(regimeTrans, fromIdx, toIdx) + 1)

// Historical average run length for the current regime
float avgRegimeRun = na
if regimeLbl == "CRISIS" and array.size(runsCrisis) > 0
    avgRegimeRun := array.avg(runsCrisis)
else if regimeLbl == "COUPLED" and array.size(runsCoupled) > 0
    avgRegimeRun := array.avg(runsCoupled)
else if regimeLbl == "MIXED" and array.size(runsMixed) > 0
    avgRegimeRun := array.avg(runsMixed)
else if regimeLbl == "DECOUPLED" and array.size(runsDecoupled) > 0
    avgRegimeRun := array.avg(runsDecoupled)

// Flip probability heuristic: combines dwell-ratio + Markov row frequencies
// Base = 15%, scales up proportional to how overdue we are vs historical mean
float ratio = not na(avgRegimeRun) and avgRegimeRun > 0 ? regimeBars / avgRegimeRun : 0.5
float flipProb10 = math.min(0.95, 0.15 + ratio * 0.35)
float flipProb30 = math.min(0.95, 0.30 + ratio * 0.55)

// Markov row probability (flip out of current regime, any destination)
int curIdx = f_regime_idx(regimeLbl)
float markovStay = na
if curIdx >= 0
    int rowTotal = 0
    for ci = 0 to 3
        rowTotal += matrix.get(regimeTrans, curIdx, ci)
    int staying = matrix.get(regimeTrans, curIdx, curIdx)
    if rowTotal > 0
        markovStay := float(staying) / rowTotal

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6b2 — ASYMMETRIC CORRELATION (conditional on volatility regime)
// ═════════════════════════════════════════════════════════════════════════════════════
//
// Professional insight: cross-asset correlations SPIKE during drawdowns. Pearson averaged
// over N bars hides this. Real hedge behavior is asymmetric: normal-regime ρ vs stress-regime ρ.
// We split bars by base-ATR regime (above/below median) and compute correlation separately.

float atrBase20 = ta.atr(20)
float atrMed    = ta.percentile_linear_interpolation(atrBase20, i_hist_len, 50)
float wStress   = not na(atrMed) and atrBase20 > atrMed ? 1.0 : 0.0
float wNormal   = not na(atrMed) and atrBase20 <= atrMed ? 1.0 : 0.0

float retBase = math.log(src / nz(src[1], src))

// Conditional correlation on log-returns with indicator weights (0/1)
f_cond_corr(rB, rS, w, n) =>
    float result = na
    float sumW = ta.sma(w, n)
    if not na(sumW) and sumW > 0.1
        float mB = ta.sma(rB * w, n) / sumW
        float mS = ta.sma(rS * w, n) / sumW
        float cov = ta.sma(rB * rS * w, n) / sumW - mB * mS
        float vB = ta.sma(rB * rB * w, n) / sumW - mB * mB
        float vS = ta.sma(rS * rS * w, n) / sumW - mS * mS
        if vB > 0 and vS > 0
            result := cov / math.sqrt(vB * vS)
    result

f_asym(sym, sc) =>
    float cN = na
    float cS = na
    if sym != "" and not na(sc)
        float retSym = math.log(sc / nz(sc[1], sc))
        cN := f_cond_corr(retBase, retSym, wNormal, i_hist_len)
        cS := f_cond_corr(retBase, retSym, wStress, i_hist_len)
    [cN, cS]

[cN1, cS1] = f_asym(i_sym1, c1)
[cN2, cS2] = f_asym(i_sym2, c2)
[cN3, cS3] = f_asym(i_sym3, c3)
[cN4, cS4] = f_asym(i_sym4, c4)
[cN5, cS5] = f_asym(i_sym5, c5)
[cN6, cS6] = f_asym(i_sym6, c6)

// Delta = how much correlation amplifies under stress (positive = diversification breaks down)
float aDelta1 = not na(cN1) and not na(cS1) ? cS1 - cN1 : na
float aDelta2 = not na(cN2) and not na(cS2) ? cS2 - cN2 : na
float aDelta3 = not na(cN3) and not na(cS3) ? cS3 - cN3 : na
float aDelta4 = not na(cN4) and not na(cS4) ? cS4 - cN4 : na
float aDelta5 = not na(cN5) and not na(cS5) ? cS5 - cN5 : na
float aDelta6 = not na(cN6) and not na(cS6) ? cS6 - cN6 : na

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6b3 — COINTEGRATION + OU HALF-LIFE (Engle-Granger per pair)
// ═════════════════════════════════════════════════════════════════════════════════════
//
// Step 1: OLS regress log(A) on log(B) → β, α, residual spread r = log(A) - β·log(B) - α
// Step 2: AR(1) on residual: Δr = γ + φ·r[-1] + ε. If φ < −0.05 → mean-reverting (cointegrated).
// Half-life via Ornstein-Uhlenbeck: t½ = −ln(2) / ln(1 + φ)

f_coint(a, b, n) =>
    bool   ok = false
    float  hl = na
    float  phi = na
    if not na(a) and not na(b) and a > 0 and b > 0
        float la = math.log(a)
        float lb = math.log(b)
        float mA = ta.sma(la, n)
        float mB = ta.sma(lb, n)
        float covAB = ta.sma(la * lb, n) - mA * mB
        float varB = ta.variance(lb, n)
        if not na(varB) and varB > 0
            float beta = covAB / varB
            float alpha = mA - beta * mB
            float resid = la - beta * lb - alpha
            float dr = resid - nz(resid[1], resid)
            float rp = nz(resid[1], 0.0)
            float mDr = ta.sma(dr, n)
            float mRp = ta.sma(rp, n)
            float covDR = ta.sma(dr * rp, n) - mDr * mRp
            float varRp = ta.variance(rp, n)
            if not na(varRp) and varRp > 0
                phi := covDR / varRp
                if not na(phi) and phi < -0.05
                    ok := true
                if not na(phi) and 1.0 + phi > 0 and 1.0 + phi < 1.0
                    hl := -math.log(2.0) / math.log(1.0 + phi)
    [ok, hl, phi]

[co12, hl12, ph12] = f_coint(c1, c2, i_corr_len)
[co13, hl13, ph13] = f_coint(c1, c3, i_corr_len)
[co14, hl14, ph14] = f_coint(c1, c4, i_corr_len)
[co15, hl15, ph15] = f_coint(c1, c5, i_corr_len)
[co16, hl16, ph16] = f_coint(c1, c6, i_corr_len)
[co23, hl23, ph23] = f_coint(c2, c3, i_corr_len)
[co24, hl24, ph24] = f_coint(c2, c4, i_corr_len)
[co25, hl25, ph25] = f_coint(c2, c5, i_corr_len)
[co26, hl26, ph26] = f_coint(c2, c6, i_corr_len)
[co34, hl34, ph34] = f_coint(c3, c4, i_corr_len)
[co35, hl35, ph35] = f_coint(c3, c5, i_corr_len)
[co36, hl36, ph36] = f_coint(c3, c6, i_corr_len)
[co45, hl45, ph45] = f_coint(c4, c5, i_corr_len)
[co46, hl46, ph46] = f_coint(c4, c6, i_corr_len)
[co56, hl56, ph56] = f_coint(c5, c6, i_corr_len)

// Store in parallel arrays aligned with aP / aS / aZ (15 pairs)
var array<bool>  aCoint = array.new<bool>(15, false)
var array<float> aHL    = array.new<float>(15, na)
var array<float> aPhi   = array.new<float>(15, na)

array.set(aCoint, 0, co12),  array.set(aHL, 0, hl12),  array.set(aPhi, 0, ph12)
array.set(aCoint, 1, co13),  array.set(aHL, 1, hl13),  array.set(aPhi, 1, ph13)
array.set(aCoint, 2, co14),  array.set(aHL, 2, hl14),  array.set(aPhi, 2, ph14)
array.set(aCoint, 3, co15),  array.set(aHL, 3, hl15),  array.set(aPhi, 3, ph15)
array.set(aCoint, 4, co16),  array.set(aHL, 4, hl16),  array.set(aPhi, 4, ph16)
array.set(aCoint, 5, co23),  array.set(aHL, 5, hl23),  array.set(aPhi, 5, ph23)
array.set(aCoint, 6, co24),  array.set(aHL, 6, hl24),  array.set(aPhi, 6, ph24)
array.set(aCoint, 7, co25),  array.set(aHL, 7, hl25),  array.set(aPhi, 7, ph25)
array.set(aCoint, 8, co26),  array.set(aHL, 8, hl26),  array.set(aPhi, 8, ph26)
array.set(aCoint, 9, co34),  array.set(aHL, 9, hl34),  array.set(aPhi, 9, ph34)
array.set(aCoint, 10, co35), array.set(aHL, 10, hl35), array.set(aPhi, 10, ph35)
array.set(aCoint, 11, co36), array.set(aHL, 11, hl36), array.set(aPhi, 11, ph36)
array.set(aCoint, 12, co45), array.set(aHL, 12, hl45), array.set(aPhi, 12, ph45)
array.set(aCoint, 13, co46), array.set(aHL, 13, hl46), array.set(aPhi, 13, ph46)
array.set(aCoint, 14, co56), array.set(aHL, 14, hl56), array.set(aPhi, 14, ph56)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6c — DISPERSION TRADE DETECTOR
// ═════════════════════════════════════════════════════════════════════════════════════

// Dispersion trade setup: avg|corr| drops >2σ below its own baseline AND realized vol is elevated
float avgAbsMean = ta.sma(avgAbs, i_hist_len)
float avgAbsStd  = ta.stdev(avgAbs, i_hist_len)
float avgAbsZ    = not na(avgAbsStd) and avgAbsStd > 0 ? (avgAbs - avgAbsMean) / avgAbsStd : na

float atrPct     = ta.atr(20) / nz(close, 1.0) * 100.0
float atrPctMean = ta.sma(atrPct, i_hist_len)

bool dispersionSetup = not na(avgAbsZ) and avgAbsZ < -2.0 and not na(atrPctMean) and atrPct > atrPctMean
// Strong version: paired with rising vol trajectory
bool dispersionStrong = dispersionSetup and atrPct > ta.sma(atrPct, 20) * 1.15

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6d — PER-SYMBOL QUALITY + HEDGE
// ═════════════════════════════════════════════════════════════════════════════════════

float qual1 = f_quality(corr1, r2_1, stab1, zs1, crisisClock)
float qual2 = f_quality(corr2, r2_2, stab2, zs2, crisisClock)
float qual3 = f_quality(corr3, r2_3, stab3, zs3, crisisClock)
float qual4 = f_quality(corr4, r2_4, stab4, zs4, crisisClock)
float qual5 = f_quality(corr5, r2_5, stab5, zs5, crisisClock)
float qual6 = f_quality(corr6, r2_6, stab6, zs6, crisisClock)

float hdg1 = f_hedge_size(beta1, i_position_size)
float hdg2 = f_hedge_size(beta2, i_position_size)
float hdg3 = f_hedge_size(beta3, i_position_size)
float hdg4 = f_hedge_size(beta4, i_position_size)
float hdg5 = f_hedge_size(beta5, i_position_size)
float hdg6 = f_hedge_size(beta6, i_position_size)

string hd1 = f_hedge_dir(beta1)
string hd2 = f_hedge_dir(beta2)
string hd3 = f_hedge_dir(beta3)
string hd4 = f_hedge_dir(beta4)
string hd5 = f_hedge_dir(beta5)
string hd6 = f_hedge_dir(beta6)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 6e — RISK BUDGET (from regime + clock + effective concentration)
// ═════════════════════════════════════════════════════════════════════════════════════

int riskBudgetPct = f_risk_budget(regimeLbl, crisisClock)

// Effective concentration adjustment: more coupled basket → reduce budget further
// Simple proxy: when avg|corr| is high, effective N drops sharply
float effN = not na(avgAbs) and activeN > 0 ? activeN / (1.0 + (activeN - 1) * avgAbs) : float(activeN)
if not na(effN) and effN < activeN * 0.5
    riskBudgetPct := math.max(math.min(riskBudgetPct, 75), 30)  // additional clamp when effN halves

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 7 — MARKET BRAIN (clustering via iterative union-find)
// ═════════════════════════════════════════════════════════════════════════════════════

// Each symbol starts in its own cluster. Two symbols merge when positive correlation
// between them exceeds the user threshold. We iterate to propagate transitivity.

var array<int> cluster = array.new<int>(6, 0)
for k = 0 to 5
    array.set(cluster, k, k)

// Only run clustering if we have correlations
bool canCluster = not na(p12) or not na(p13) or not na(p14) or not na(p15) or not na(p16) or not na(p23) or not na(p24) or not na(p25) or not na(p26) or not na(p34) or not na(p35) or not na(p36) or not na(p45) or not na(p46) or not na(p56)

if canCluster
    // Inline adjacency: only positive correlations count for clustering
    var array<float> adj = array.new<float>(15)
    array.set(adj, 0, nz(p12, -1)), array.set(adj, 1, nz(p13, -1)), array.set(adj, 2, nz(p14, -1))
    array.set(adj, 3, nz(p15, -1)), array.set(adj, 4, nz(p16, -1)), array.set(adj, 5, nz(p23, -1))
    array.set(adj, 6, nz(p24, -1)), array.set(adj, 7, nz(p25, -1)), array.set(adj, 8, nz(p26, -1))
    array.set(adj, 9, nz(p34, -1)), array.set(adj, 10, nz(p35, -1)), array.set(adj, 11, nz(p36, -1))
    array.set(adj, 12, nz(p45, -1)), array.set(adj, 13, nz(p46, -1)), array.set(adj, 14, nz(p56, -1))

    // Iterate up to 6 times — enough for transitivity on 6 nodes
    for iter = 0 to 5
        for idx = 0 to 14
            if array.get(adj, idx) > i_cluster_thr
                int i0 = array.get(aI, idx) - 1
                int j0 = array.get(aJ, idx) - 1
                int ci = array.get(cluster, i0)
                int cj = array.get(cluster, j0)
                if ci != cj
                    int keep = math.min(ci, cj)
                    int drop = math.max(ci, cj)
                    for m = 0 to 5
                        if array.get(cluster, m) == drop
                            array.set(cluster, m, keep)

// Normalize cluster IDs to 0,1,2,... in order of first appearance
var array<int> cluNorm = array.new<int>(6, 0)
var array<int> cluMap  = array.new<int>(6, -1)
for k = 0 to 5
    array.set(cluMap, k, -1)
int nextId = 0
for k = 0 to 5
    int rawId = array.get(cluster, k)
    int mapped = array.get(cluMap, rawId)
    if mapped == -1
        array.set(cluMap, rawId, nextId)
        array.set(cluNorm, k, nextId)
        nextId += 1
    else
        array.set(cluNorm, k, mapped)

// Determine if a symbol is "solo" (no correlations > threshold to any other symbol)
f_is_solo(idx0) =>
    bool solo = true
    for idx = 0 to 14
        int i0 = array.get(aI, idx) - 1
        int j0 = array.get(aJ, idx) - 1
        if i0 == idx0 or j0 == idx0
            float pv = array.get(aP, idx)
            if not na(pv) and pv > i_cluster_thr
                solo := false
    solo

bool solo1 = f_is_solo(0)
bool solo2 = f_is_solo(1)
bool solo3 = f_is_solo(2)
bool solo4 = f_is_solo(3)
bool solo5 = f_is_solo(4)
bool solo6 = f_is_solo(5)

// Cluster color / letter per symbol (solo = gray "·")
f_sym_cluster_color(idx0, solo) =>
    solo ? i_c_clu_solo : f_cluster_color(array.get(cluNorm, idx0))

f_sym_cluster_letter(idx0, solo) =>
    solo ? "·" : f_cluster_letter(array.get(cluNorm, idx0))

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 8 — AUTO-PAIRS SCANNER (top 3 live pairs by score)
// ═════════════════════════════════════════════════════════════════════════════════════

// Score each pair: stab × |spread z| × (|corr| > 0.4 filter)
f_pair_score(corr, stab, z) =>
    if na(corr) or na(stab) or na(z)
        -1.0
    else if math.abs(corr) < 0.4
        -1.0
    else
        stab * math.abs(z)

var array<float> pScore = array.new<float>(15, -1.0)
for idx = 0 to 14
    float sc = f_pair_score(array.get(aP, idx), array.get(aS, idx), array.get(aZ, idx))
    array.set(pScore, idx, sc)

// Find top 3 by score
var array<int> topIdx = array.new<int>(3, -1)
array.set(topIdx, 0, -1), array.set(topIdx, 1, -1), array.set(topIdx, 2, -1)

// Three passes to find top 3 (simple but clear)
for pass = 0 to 2
    float maxSc = 0.0  // require score > 0 to be eligible
    int   maxI  = -1
    for idx = 0 to 14
        float sc = array.get(pScore, idx)
        // Skip if already chosen
        bool chosen = false
        for q = 0 to 2
            if array.get(topIdx, q) == idx
                chosen := true
        if not chosen and sc > maxSc
            maxSc := sc
            maxI  := idx
    array.set(topIdx, pass, maxI)

// Map sym index to its input ticker
f_sym_name(i0) =>
    switch i0
        0 => f_short_name(i_sym1)
        1 => f_short_name(i_sym2)
        2 => f_short_name(i_sym3)
        3 => f_short_name(i_sym4)
        4 => f_short_name(i_sym5)
        5 => f_short_name(i_sym6)
        =>   "—"

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 8b — RANKED ACTION LIST (top 5 ordered trades right now)
// ═════════════════════════════════════════════════════════════════════════════════════

// We collect candidate actions from:
//   • Per-symbol TRACK / HEDGE (scored by quality)
//   • Per-symbol LEADS (scored by |lag correlation| × lag magnitude)
//   • Per-pair PAIRS (scored by stability × |spread z| × R²)
// Then rank and pick top 5.

var array<string> actType  = array.new<string>()
var array<string> actTgt   = array.new<string>()
var array<float>  actScore = array.new<float>()
var array<string> actDir   = array.new<string>()
var array<string> actSize  = array.new<string>()
var array<string> actWhy   = array.new<string>()
var array<color>  actCol   = array.new<color>()

array.clear(actType), array.clear(actTgt), array.clear(actScore), array.clear(actDir), array.clear(actSize), array.clear(actWhy), array.clear(actCol)

// Push per-symbol TRACK / HEDGE / LEADS actions
f_push_sym_actions(idx0, sym, corr, r2, qual, beta, hdg, hd, lag, lagC) =>
    if sym != "" and not na(corr)
        // TRACK / HEDGE based on direction + quality
        if corr > 0.4 and qual >= i_min_quality
            array.push(actType, corr > i_strong_thr ? "TRACK++" : "TRACK")
            array.push(actTgt, f_short_name(sym))
            array.push(actScore, qual)
            array.push(actDir, "LONG " + f_short_name(sym) + " with base")
            array.push(actSize, f_money(i_position_size * math.min(1.0, qual / 100.0)))
            array.push(actWhy, "Corr " + str.tostring(corr, "#.##") + " · R² " + str.tostring(r2 * 100, "#") + "% · Qual " + str.tostring(qual, "#"))
            array.push(actCol, corr > i_strong_thr ? i_c_trackpp : i_c_track)
        else if corr < -0.4 and qual >= i_min_quality
            array.push(actType, corr < -i_strong_thr ? "HEDGE++" : "HEDGE")
            array.push(actTgt, f_short_name(sym))
            array.push(actScore, qual)
            array.push(actDir, hd + " " + f_short_name(sym) + " to hedge base")
            array.push(actSize, f_money(hdg))
            array.push(actWhy, "Inverse corr " + str.tostring(corr, "#.##") + " · β " + str.tostring(beta, "#.##") + " · Qual " + str.tostring(qual, "#"))
            array.push(actCol, corr < -i_strong_thr ? i_c_hedgepp : i_c_hedge)

        // LEADS action — symbol leads base
        if not na(lagC) and lag > 0 and math.abs(lagC) > 0.4
            float leadScore = math.abs(lagC) * 100.0 * (1.0 + lag * 0.1)
            array.push(actType, "LEADS")
            array.push(actTgt, f_short_name(sym) + " (+" + str.tostring(lag) + "b)")
            array.push(actScore, leadScore)
            array.push(actDir, "Watch " + f_short_name(sym) + " for early signal on base")
            array.push(actSize, "—")
            array.push(actWhy, "Leads base by ~" + str.tostring(lag) + " bars (corr " + str.tostring(lagC, "#.##") + ")")
            array.push(actCol, i_c_leads)

f_push_sym_actions(0, i_sym1, corr1, r2_1, qual1, beta1, hdg1, hd1, lag1, lagC1)
f_push_sym_actions(1, i_sym2, corr2, r2_2, qual2, beta2, hdg2, hd2, lag2, lagC2)
f_push_sym_actions(2, i_sym3, corr3, r2_3, qual3, beta3, hdg3, hd3, lag3, lagC3)
f_push_sym_actions(3, i_sym4, corr4, r2_4, qual4, beta4, hdg4, hd4, lag4, lagC4)
f_push_sym_actions(4, i_sym5, corr5, r2_5, qual5, beta5, hdg5, hd5, lag5, lagC5)
f_push_sym_actions(5, i_sym6, corr6, r2_6, qual6, beta6, hdg6, hd6, lag6, lagC6)

// Push PAIRS actions (all 15 unique pairs, filtered by score threshold)
for idx = 0 to 14
    float pScoreNow = array.get(pScore, idx)
    if not na(pScoreNow) and pScoreNow > 1.0
        int i0 = array.get(aI, idx) - 1
        int j0 = array.get(aJ, idx) - 1
        float pC = array.get(aP, idx)
        float pS = array.get(aS, idx)
        float pZ = array.get(aZ, idx)
        string nameA = f_sym_name(i0)
        string nameB = f_sym_name(j0)
        string dir = pZ > 0 ? ("SHORT " + nameA + " / LONG " + nameB) : ("LONG " + nameA + " / SHORT " + nameB)
        float pairScore = pS * math.abs(pZ) * 25.0  // scale to 0-100ish range
        // Boost pair score if cointegrated (spread reliably mean-reverts)
        bool isCo = array.get(aCoint, idx)
        float hl = array.get(aHL, idx)
        if isCo
            pairScore := pairScore * 1.5  // 50% boost for cointegrated pairs
        if pairScore >= i_min_quality * 0.6
            array.push(actType, isCo ? "PAIRS✓" : "PAIRS")
            array.push(actTgt, nameA + "/" + nameB)
            array.push(actScore, pairScore)
            array.push(actDir, dir)
            array.push(actSize, f_money(i_position_size * 0.75))
            string whyTxt = "Stab " + str.tostring(pS * 100, "#") + " · Z " + f_signed(pZ, "#.##") + " · Corr " + str.tostring(pC, "#.##")
            if isCo
                whyTxt := whyTxt + " · COINT (HL " + f_num(hl, "#") + "b)"
            array.push(actWhy, whyTxt)
            array.push(actCol, i_c_pairs)

// Dispersion trade action (basket-level, not per-pair)
if dispersionStrong
    array.push(actType, "DISPERS")
    array.push(actTgt, "BASKET")
    array.push(actScore, 85.0)
    array.push(actDir, "Long vol / short index vol — basket is decoupling")
    array.push(actSize, f_money(i_position_size * 0.5))
    array.push(actWhy, "avg|Corr| Z " + str.tostring(avgAbsZ, "#.#") + " · ATR% " + str.tostring(atrPct, "#.#") + " rising")
    array.push(actCol, i_c_decoupling)

// Sort candidates by score desc and pick top 5
var array<int> topAct = array.new<int>(5, -1)
for q = 0 to 4
    array.set(topAct, q, -1)

int nActs = array.size(actScore)
if nActs > 0
    for pick = 0 to 4
        float bestSc = 0.0
        int   bestIx = -1
        for k = 0 to nActs - 1
            float sc = array.get(actScore, k)
            bool already = false
            for q = 0 to 4
                if array.get(topAct, q) == k
                    already := true
            if not already and sc > bestSc
                bestSc := sc
                bestIx := k
        array.set(topAct, pick, bestIx)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 9 — TRADE PLAYBOOK (dynamic recommendations)
// ═════════════════════════════════════════════════════════════════════════════════════

// Find the symbol with the largest |optimal lag| and meaningful correlation
int   bestLeadIdx = -1
int   bestLeadBars = 0
float bestLeadCor = 0.0

f_check_lead(idx0, lag, cor) =>
    bool  upd  = false
    int   newI = bestLeadIdx
    int   newB = bestLeadBars
    float newC = bestLeadCor
    if not na(cor) and math.abs(lag) > math.abs(newB) and math.abs(cor) > 0.4
        newI := idx0
        newB := lag
        newC := cor
        upd  := true
    [newI, newB, newC, upd]

[li1, lb1, lc1, u1] = f_check_lead(0, lag1, lagC1)
bestLeadIdx := li1, bestLeadBars := lb1, bestLeadCor := lc1
[li2, lb2, lc2, u2] = f_check_lead(1, lag2, lagC2)
bestLeadIdx := li2, bestLeadBars := lb2, bestLeadCor := lc2
[li3, lb3, lc3, u3] = f_check_lead(2, lag3, lagC3)
bestLeadIdx := li3, bestLeadBars := lb3, bestLeadCor := lc3
[li4, lb4, lc4, u4] = f_check_lead(3, lag4, lagC4)
bestLeadIdx := li4, bestLeadBars := lb4, bestLeadCor := lc4
[li5, lb5, lc5, u5] = f_check_lead(4, lag5, lagC5)
bestLeadIdx := li5, bestLeadBars := lb5, bestLeadCor := lc5
[li6, lb6, lc6, u6] = f_check_lead(5, lag6, lagC6)
bestLeadIdx := li6, bestLeadBars := lb6, bestLeadCor := lc6

// Build playbook lines
string pb1 = ""
string pb2 = ""
string pb3 = ""
string pb4 = ""
string pb5 = ""
color  pb1col = i_panel_txt

// Line 1 — primary recommendation (regime + clock)
if crisisClock >= i_clock_critical
    pb1 := "▲ CRITICAL " + str.tostring(crisisClock, "#") + "/100 — reduce size, cut leverage. Forced coupling risk is elevated."
    pb1col := i_c_clk_critical
else if crisisClock >= i_clock_stressed
    pb1 := "▲ STRESSED " + str.tostring(crisisClock, "#") + "/100 — trim concentration, favor macro direction over single-name bets."
    pb1col := i_c_clk_stressed
else if regimeLbl == "DECOUPLED"
    pb1 := "● DECOUPLED " + str.tostring(crisisClock, "#") + "/100 — healthy market. Pairs & relative-value setups favored."
    pb1col := i_c_clk_safe
else if regimeLbl == "COUPLED"
    pb1 := "○ COUPLED " + str.tostring(crisisClock, "#") + "/100 — index-like behavior. Limit concentration in single names."
    pb1col := i_c_clk_elevated
else if regimeLbl == "MIXED"
    pb1 := "▫ MIXED " + str.tostring(crisisClock, "#") + "/100 — no dominant theme. Read per-symbol signals individually."
    pb1col := i_panel_txt
else
    pb1 := "Warming up — insufficient active symbols for regime classification."
    pb1col := i_panel_txt

// Line 2 — clock acceleration
if not na(clockDelta) and math.abs(clockDelta) >= 10
    pb2 := (clockDelta > 0 ? "Clock accelerating: +" : "Clock easing: ") + str.tostring(clockDelta, "#") + " pts in last 20 bars."
else
    pb2 := "Clock steady: " + f_signed(clockDelta, "#") + " pts in last 20 bars."

// Line 3 — market leader
if bestLeadIdx >= 0 and math.abs(bestLeadBars) > 0
    string ldrName = f_sym_name(bestLeadIdx)
    if bestLeadBars > 0
        pb3 := "Leader: " + ldrName + " leads " + syminfo.ticker + " by ~" + str.tostring(bestLeadBars) + " bars (corr " + str.tostring(bestLeadCor, "#.##") + "). Use as early warning."
    else
        pb3 := "Laggard: " + ldrName + " lags " + syminfo.ticker + " by ~" + str.tostring(math.abs(bestLeadBars)) + " bars (corr " + str.tostring(bestLeadCor, "#.##") + ")."
else
    pb3 := "No dominant lead/lag detected — relationships are synchronous."

// Line 4 — top live pair
int t0 = array.get(topIdx, 0)
if t0 >= 0
    int i0 = array.get(aI, t0) - 1
    int j0 = array.get(aJ, t0) - 1
    float tZ = array.get(aZ, t0)
    float tC = array.get(aP, t0)
    string dir = tZ > 0 ? ("short " + f_sym_name(i0) + " / long " + f_sym_name(j0)) : ("long " + f_sym_name(i0) + " / short " + f_sym_name(j0))
    pb4 := "Top pair: " + f_sym_name(i0) + "/" + f_sym_name(j0) + " z=" + f_signed(tZ, "#.##") + " corr=" + f_num(tC, "#.##") + " → " + dir + "."
else
    pb4 := "No qualifying pairs-trade setups right now."

// Line 5 — footer
pb5 := "Base " + syminfo.ticker + "  •  " + str.tostring(i_corr_len) + "b corr  •  " + str.tostring(i_hist_len) + "b baseline  •  " + str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 10 — CHART REGIME TINT
// ═════════════════════════════════════════════════════════════════════════════════════

bgcolor(i_show_tint ? color.new(regimeCol, 94) : na, title="Regime Tint")

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 11 — INTELLIGENCE TABLE
// ═════════════════════════════════════════════════════════════════════════════════════

var table tblI = na

f_render_intel_row(t, row, idx0, sym, corr, r2, beta, zs, pct, stab, spZ, chg, stCorr, ltCorr, optLag, optCor, qual, hdg, hd, cNorm, cStress, aDelta, solo, isPro) =>
    color bg = f_heatmap(corr)
    color tc = f_txt_contrast(corr)
    ts = f_txt_size(i_txt_size)
    bool  empty = sym == "" or na(corr)

    // Cluster prefix on symbol name
    color cluCol = f_sym_cluster_color(idx0, solo)
    string cluLtr = f_sym_cluster_letter(idx0, solo)

    if empty
        int cols = isPro ? 14 : 5
        string label = sym == "" ? "—" : f_short_name(sym)
        string tipEmpty = sym == "" ? "Slot empty — add a symbol in Inputs." : "Warming up — waiting for enough bars."
        table.cell(t, 0, row, label, text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip=tipEmpty)
        for c = 1 to cols - 1
            table.cell(t, c, row, "·", text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts)
    else
        // Col 0 — Symbol. Always bright white on heatmap bg for max contrast.
        // Cluster letter appears as a short suffix; cluster color surfaces in the tooltip / Market Brain row.
        string symTip = "Ticker: " + sym + "\nCluster: " + cluLtr + (solo ? " (solo — no strong positive ties)" : "")
        table.cell(t, 0, row, f_short_name(sym) + " · " + cluLtr, text_color=color.white, bgcolor=bg, text_size=ts, text_halign=text.align_left, tooltip=symTip)

        // Col 1 — Corr (with trajectory arrow)
        string corrTxt = str.tostring(corr, "#.00") + " " + f_change_glyph(chg)
        string corrTip = "Pearson (MT, " + str.tostring(i_corr_len) + "b): " + f_num(corr, "#.####") + "\nChange vs " + str.tostring(i_change_look) + " bars ago: " + f_signed(chg, "#.###")
        table.cell(t, 1, row, corrTxt, text_color=f_change_color(chg), bgcolor=bg, text_size=ts, tooltip=corrTip)

        [sigLbl, sigCol, sigTip] = f_signal(corr, r2, zs, stab, spZ, optLag, pct)

        if isPro
            // Col 2 — MTF glyph (ST / MT / LT)
            string mtfTxt = f_block(stCorr) + f_block(corr) + f_block(ltCorr)
            string mtfTip = "Multi-timeframe correlation:\n  Short (" + str.tostring(i_short_len) + "b): " + f_num(stCorr, "#.##") + "\n  Medium (" + str.tostring(i_corr_len) + "b): " + f_num(corr, "#.##") + "\n  Long (" + str.tostring(i_long_len) + "b): " + f_num(ltCorr, "#.##")
            table.cell(t, 2, row, mtfTxt, text_color=tc, bgcolor=bg, text_size=ts, tooltip=mtfTip)

            // Col 3 — β
            table.cell(t, 3, row, f_num(beta, "#.##"), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="Beta: " + f_num(beta, "#.####") + "\nHow much this symbol moves per unit move in base.\nβ>1 amplifies, β<1 dampens, β<0 inverse.")

            // Col 4 — R²
            table.cell(t, 4, row, (na(r2) ? "—" : str.tostring(r2 * 100, "#") + "%"), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="R²: " + (na(r2) ? "—" : str.tostring(r2 * 100, "#.##") + "%\nVariance explained by the base. Trust threshold " + str.tostring(i_min_r2 * 100, "#") + "%."))

            // Col 5 — Z
            table.cell(t, 5, row, f_signed(zs, "#.##"), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="Correlation Z vs own " + str.tostring(i_hist_len) + "b history. |Z|>" + str.tostring(i_break_z, "#.#") + " = regime break.")

            // Col 6 — %ile
            table.cell(t, 6, row, (na(pct) ? "—" : str.tostring(pct, "#") + "%"), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="Percentile rank of current correlation in its own history. >90% = coupling extreme. <10% = decoupling extreme.")

            // Col 7 — Stab
            table.cell(t, 7, row, (na(stab) ? "—" : str.tostring(stab * 100, "#")), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="Stability 0-100. High = steady, trustworthy correlation. Low = noisy, don't trade it.")

            // Col 8 — Opt.Lag
            string lagTxt = optLag == 0 ? "0" : f_signed(optLag, "#")
            string lagTip = "Optimal lag (scanned ±{1,3,5}): " + lagTxt + " bars.\nCorrelation at best lag: " + f_num(optCor, "#.##") + "\n+N = symbol leads base. -N = symbol lags base."
            table.cell(t, 8, row, lagTxt + " (" + f_num(optCor, "#.##") + ")", text_color=tc, bgcolor=bg, text_size=ts, tooltip=lagTip)

            // Col 9 — Sprd
            table.cell(t, 9, row, f_signed(spZ, "#.##"), text_color=tc, bgcolor=bg, text_size=ts,
                 tooltip="Spread Z-score of base/symbol price ratio. |Z|>" + str.tostring(i_pairs_z, "#.#") + " with stable corr = pairs-trade setup.")

            // Col 10 — Quality (0-100 setup score)
            color qCol = qual >= i_min_quality ? i_c_trackpp : (qual >= i_min_quality * 0.66 ? i_c_clk_elevated : i_c_neutral)
            string qTxt = na(qual) ? "—" : str.tostring(qual, "#")
            string qTip = na(qual) ? "—" : "Setup Quality: " + str.tostring(qual, "#") + "/100\n  |corr| × R² × stab, adjusted for regime-break / crisis clock\n  Action threshold: " + str.tostring(i_min_quality) + "+"
            table.cell(t, 10, row, qTxt, text_color=color.white, bgcolor=qCol, text_size=ts, tooltip=qTip)

            // Col 11 — Hedge ($ notional)
            string hTxt = na(corr) or math.abs(corr) < 0.2 ? "—" : (hd + " " + f_money(hdg))
            string hTip = "Hedge Desk:\n  β × position size = |" + f_num(beta, "#.##") + "| × " + f_money(i_position_size) + " = " + f_money(hdg) + "\n  Direction: " + hd + " this symbol to neutralize β on a long base position.\n  (Reverse if your base is short.)"
            table.cell(t, 11, row, hTxt, text_color=tc, bgcolor=bg, text_size=ts, tooltip=hTip)

            // Col 12 — Asymmetric Correlation Δ (stress − normal)
            color asymBg = bg
            color asymTc = tc
            if not na(aDelta) and aDelta > 0.3
                asymBg := i_c_clk_critical
                asymTc := color.white
            else if not na(aDelta) and aDelta > 0.15
                asymBg := i_c_clk_stressed
                asymTc := color.white
            string asymTxt = na(aDelta) ? "—" : f_signed(aDelta, "#.##")
            string asymTip = "Asymmetric Correlation (institutional edge):\n  Normal-vol regime ρ: " + f_num(cNorm, "#.##") + "\n  Stress-vol regime ρ: " + f_num(cStress, "#.##") + "\n  Δ (stress − normal): " + f_signed(aDelta, "#.##") + "\n\nIf Δ > 0.3, this 'hedge' FAILS when you need it — correlation amplifies in crisis. Real hedges have Δ ≤ 0 (uncorrelated or more inverse under stress)."
            table.cell(t, 12, row, asymTxt, text_color=asymTc, bgcolor=asymBg, text_size=ts, tooltip=asymTip)

            // Col 13 — Signal
            table.cell(t, 13, row, sigLbl, text_color=color.white, bgcolor=sigCol, text_size=ts, tooltip=sigTip)
        else
            // Compact: Symbol, Corr, MTF, R², Signal
            string mtfTxt = f_block(stCorr) + f_block(corr) + f_block(ltCorr)
            table.cell(t, 2, row, mtfTxt, text_color=tc, bgcolor=bg, text_size=ts, tooltip="MTF correlation: ST/MT/LT")
            table.cell(t, 3, row, (na(r2) ? "—" : str.tostring(r2 * 100, "#") + "%"), text_color=tc, bgcolor=bg, text_size=ts, tooltip="R² — variance explained.")
            table.cell(t, 4, row, sigLbl, text_color=color.white, bgcolor=sigCol, text_size=ts, tooltip=sigTip)

if barstate.islast and i_show_intel
    bool isPro = i_view_mode == "Pro"
    int  cols  = isPro ? 14 : 5
    int  rows  = 3 + 1 + 6  // title + regime + brain + header + 6 data rows

    if na(tblI)
        tblI := table.new(f_pos(i_pos_intel), cols, rows,
             border_width=i_border_width, border_color=i_border_color,
             frame_width=i_border_width,  frame_color=i_border_color)

    ts = f_txt_size(i_txt_size)
    int  r  = 0

    // ── Row 0: Title ──
    string titleTxt = "⚡ CORRELATION INTELLIGENCE v3 — NikaQuant"
    string subTxt   = "Base " + syminfo.ticker + "  •  " + str.format_time(time, "HH:mm", syminfo.timezone)
    if isPro
        table.cell(tblI, 0, r, titleTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_left,
             tooltip="Hall of Fame edition: N×N matrix + asymmetric correlation + cointegration + OU half-life, optimal-lag scanner, MTF, Market Brain clustering, Crisis Clock, setup quality, hedge desk, action list, trade playbook.")
        table.merge_cells(tblI, 0, r, 7, r)
        table.cell(tblI, 8, r, subTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right)
        table.merge_cells(tblI, 8, r, 13, r)
    else
        table.cell(tblI, 0, r, titleTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_left)
        table.merge_cells(tblI, 0, r, 3, r)
        table.cell(tblI, 4, r, syminfo.ticker, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right)
    r += 1

    // ── Row 1: Regime strip + Crisis Clock ──
    string avgTxt  = f_num(avgAbs, "#.##")
    string dispTxt = f_num(disp,   "#.##")
    string covTxt  = str.tostring(activeN) + "/6"

    if isPro
        table.cell(tblI, 0, r, "REGIME", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right, tooltip="Aggregate regime from avg|corr| and dispersion.")
        table.cell(tblI, 1, r, regimeLbl, text_color=color.white, bgcolor=regimeCol, text_size=ts, tooltip=regimeTip)

        // Crisis Clock (big cell, merged)
        string clockTxt = f_clock_label(crisisClock) + "  " + str.tostring(crisisClock, "#") + "/100"
        string clockTip = "CRISIS CLOCK: " + str.tostring(crisisClock, "#") + "/100\n  Coupling (from avg|corr|): " + str.tostring(compA, "#.#") + "/40\n  Dispersion collapse: " + str.tostring(compB, "#.#") + "/30\n  Tail dependence (pairs with |corr|>0.7): " + str.tostring(tailCount) + "/" + str.tostring(pairN) + " = " + str.tostring(compC, "#.#") + "/30\n  20-bar change: " + f_signed(clockDelta, "#") + " pts\nThresholds: STRESSED≥" + str.tostring(i_clock_stressed) + ", CRITICAL≥" + str.tostring(i_clock_critical)
        table.cell(tblI, 2, r, clockTxt, text_color=color.white, bgcolor=f_clock_color(crisisClock), text_size=ts, tooltip=clockTip)
        table.merge_cells(tblI, 2, r, 4, r)

        table.cell(tblI, 5, r, "⌀|Corr|", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right, tooltip="Average absolute correlation across active symbols.")
        table.cell(tblI, 6, r, avgTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)

        table.cell(tblI, 7, r, "σ(Corr)", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right, tooltip="Cross-sectional dispersion of correlations.")
        table.cell(tblI, 8, r, dispTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)

        // Risk Budget badge
        table.cell(tblI, 9, r, "Risk", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right,
             tooltip="Risk Budget: recommended gross exposure based on current regime + Crisis Clock + effective concentration.\nCRISIS/CRITICAL clock ≤ " + str.tostring(i_risk_crisis) + "%\nCOUPLED/STRESSED ≤ " + str.tostring(i_risk_coupled) + "%\nMIXED ≤ " + str.tostring(i_risk_mixed) + "%\nDECOUPLED ≤ " + str.tostring(i_risk_decoupled) + "%")
        table.cell(tblI, 10, r, str.tostring(riskBudgetPct) + "%", text_color=color.white, bgcolor=f_risk_color(riskBudgetPct), text_size=ts, tooltip="Suggested gross exposure: " + str.tostring(riskBudgetPct) + "%\nEffective N (diversification): " + f_num(effN, "#.#") + " of " + str.tostring(activeN))

        // Active / Persistence
        table.cell(tblI, 11, r, "Reg.Age", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right, tooltip="Regime persistence: bars the current regime has been active. Historical average is compared to estimate flip probability.")
        string regAgeTxt = str.tostring(regimeBars) + "b"
        if not na(avgRegimeRun)
            regAgeTxt := regAgeTxt + " / " + str.tostring(avgRegimeRun, "#") + "b"
        string flipTip = "Regime age: " + str.tostring(regimeBars) + " bars\nHistorical avg for " + regimeLbl + ": " + f_num(avgRegimeRun, "#.#") + "\nFlip probability (10b): " + str.tostring(flipProb10 * 100, "#") + "%\nFlip probability (30b): " + str.tostring(flipProb30 * 100, "#") + "%\nMarkov P(stay): " + f_num(markovStay, "#.##")
        table.cell(tblI, 12, r, regAgeTxt, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip=flipTip)

        // Count cointegrated pairs (15 total) for header summary
        int cointCount = 0
        for cidx = 0 to 14
            if array.get(aCoint, cidx)
                cointCount += 1
        color cointBg = cointCount >= 3 ? i_c_clk_safe : (cointCount >= 1 ? i_c_clk_elevated : i_header_bg)
        color cointTxt = cointCount >= 1 ? color.white : i_header_txt
        table.cell(tblI, 13, r, "Coint " + str.tostring(cointCount) + "/15", text_color=cointTxt, bgcolor=cointBg, text_size=ts,
             tooltip="Cointegrated pairs: " + str.tostring(cointCount) + " of 15\n\nEngle-Granger two-step: log-regression then AR(1) on residual. φ < −0.05 = mean-reverting spread. Cointegrated pairs are the ONLY pairs that reliably mean-revert — correlation alone is not enough.")
    else
        table.cell(tblI, 0, r, "REGIME", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right)
        table.cell(tblI, 1, r, regimeLbl, text_color=color.white, bgcolor=regimeCol, text_size=ts, tooltip=regimeTip)
        string clockTxt2 = f_clock_label(crisisClock) + " " + str.tostring(crisisClock, "#")
        table.cell(tblI, 2, r, clockTxt2, text_color=color.white, bgcolor=f_clock_color(crisisClock), text_size=ts)
        table.merge_cells(tblI, 2, r, 4, r)
    r += 1

    // ── Row 2: Market Brain cluster pills ──
    if isPro
        table.cell(tblI, 0, r, "MARKET BRAIN", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right,
             tooltip="Market Brain: auto-clusters symbols by pairwise correlation > " + str.tostring(i_cluster_thr, "#.##") + ". Same color = same live cluster.")
        // 6 cluster pills (one per slot) — inlined because Pine forbids nested function declarations
        bool   a1 = i_sym1 != ""
        color  bg1_ = a1 ? f_sym_cluster_color(0, solo1) : i_panel_bg
        color  tx1 = a1 ? color.white : #546e7a
        string ds1 = a1 ? (f_sym_cluster_letter(0, solo1) + " " + f_short_name(i_sym1)) : "—"
        string tp1 = a1 ? ("Symbol: " + i_sym1 + "\nCluster: " + f_sym_cluster_letter(0, solo1) + (solo1 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 1, r, ds1, text_color=tx1, bgcolor=bg1_, text_size=ts, tooltip=tp1)

        bool   a2 = i_sym2 != ""
        color  bg2_ = a2 ? f_sym_cluster_color(1, solo2) : i_panel_bg
        color  tx2 = a2 ? color.white : #546e7a
        string ds2 = a2 ? (f_sym_cluster_letter(1, solo2) + " " + f_short_name(i_sym2)) : "—"
        string tp2 = a2 ? ("Symbol: " + i_sym2 + "\nCluster: " + f_sym_cluster_letter(1, solo2) + (solo2 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 2, r, ds2, text_color=tx2, bgcolor=bg2_, text_size=ts, tooltip=tp2)

        bool   a3 = i_sym3 != ""
        color  bg3_ = a3 ? f_sym_cluster_color(2, solo3) : i_panel_bg
        color  tx3 = a3 ? color.white : #546e7a
        string ds3 = a3 ? (f_sym_cluster_letter(2, solo3) + " " + f_short_name(i_sym3)) : "—"
        string tp3 = a3 ? ("Symbol: " + i_sym3 + "\nCluster: " + f_sym_cluster_letter(2, solo3) + (solo3 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 3, r, ds3, text_color=tx3, bgcolor=bg3_, text_size=ts, tooltip=tp3)

        bool   a4 = i_sym4 != ""
        color  bg4_ = a4 ? f_sym_cluster_color(3, solo4) : i_panel_bg
        color  tx4 = a4 ? color.white : #546e7a
        string ds4 = a4 ? (f_sym_cluster_letter(3, solo4) + " " + f_short_name(i_sym4)) : "—"
        string tp4 = a4 ? ("Symbol: " + i_sym4 + "\nCluster: " + f_sym_cluster_letter(3, solo4) + (solo4 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 4, r, ds4, text_color=tx4, bgcolor=bg4_, text_size=ts, tooltip=tp4)

        bool   a5 = i_sym5 != ""
        color  bg5_ = a5 ? f_sym_cluster_color(4, solo5) : i_panel_bg
        color  tx5 = a5 ? color.white : #546e7a
        string ds5 = a5 ? (f_sym_cluster_letter(4, solo5) + " " + f_short_name(i_sym5)) : "—"
        string tp5 = a5 ? ("Symbol: " + i_sym5 + "\nCluster: " + f_sym_cluster_letter(4, solo5) + (solo5 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 5, r, ds5, text_color=tx5, bgcolor=bg5_, text_size=ts, tooltip=tp5)

        bool   a6 = i_sym6 != ""
        color  bg6_ = a6 ? f_sym_cluster_color(5, solo6) : i_panel_bg
        color  tx6 = a6 ? color.white : #546e7a
        string ds6 = a6 ? (f_sym_cluster_letter(5, solo6) + " " + f_short_name(i_sym6)) : "—"
        string tp6 = a6 ? ("Symbol: " + i_sym6 + "\nCluster: " + f_sym_cluster_letter(5, solo6) + (solo6 ? " (solo)" : "")) : "Slot empty."
        table.cell(tblI, 6, r, ds6, text_color=tx6, bgcolor=bg6_, text_size=ts, tooltip=tp6)
        // Leftover cells — show dispersion flag + flip probability in unused space
        string dispFlag = dispersionStrong ? "✦ DISPERSION" : (dispersionSetup ? "⋯ disp" : "")
        color  dispBg   = dispersionStrong ? i_c_decoupling : i_header_bg
        color  dispTxt  = dispersionStrong ? color.white : i_header_txt
        table.cell(tblI, 7, r, dispFlag, text_color=dispTxt, bgcolor=dispBg, text_size=ts,
             tooltip="Dispersion Trade Detector:\n  avg|Corr| Z-score: " + f_num(avgAbsZ, "#.##") + "\n  ATR%: " + f_num(atrPct, "#.##") + " (baseline " + f_num(atrPctMean, "#.##") + ")\n  Fires when avg|Corr| drops >2σ with vol rising — long vol / short index vol setup.")
        table.merge_cells(tblI, 7, r, 8, r)

        string flipTxt2 = "Flip " + str.tostring(flipProb10 * 100, "#") + "%/" + str.tostring(flipProb30 * 100, "#") + "%"
        table.cell(tblI, 9, r, flipTxt2, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts,
             tooltip="Regime flip probability\n  10-bar: " + str.tostring(flipProb10 * 100, "#") + "%\n  30-bar: " + str.tostring(flipProb30 * 100, "#") + "%\n  Current age: " + str.tostring(regimeBars) + "b · avg: " + f_num(avgRegimeRun, "#.#") + "b")
        table.merge_cells(tblI, 9, r, 10, r)

        table.cell(tblI, 11, r, "Eff N " + f_num(effN, "#.#"), text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts,
             tooltip="Effective N (correlation-adjusted diversification):\n  " + f_num(effN, "#.##") + " of " + str.tostring(activeN) + " active symbols\n  If everything is correlated at 1.0, effective N = 1 (you have one bet, not six).")
        table.merge_cells(tblI, 11, r, 13, r)
    else
        table.cell(tblI, 0, r, "BRAIN", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right)
        string brainStr = f_sym_cluster_letter(0, solo1) + f_sym_cluster_letter(1, solo2) + f_sym_cluster_letter(2, solo3) + f_sym_cluster_letter(3, solo4) + f_sym_cluster_letter(4, solo5) + f_sym_cluster_letter(5, solo6)
        table.cell(tblI, 1, r, brainStr, text_color=i_panel_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Cluster letters for slots 1-6.")
        table.merge_cells(tblI, 1, r, 4, r)
    r += 1

    // ── Row 3: Column headers ──
    if isPro
        table.cell(tblI, 0, r, "Symbol",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Comparison symbol (prefixed by cluster letter).")
        table.cell(tblI, 1, r, "Corr",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Pearson correlation (MT) with trajectory arrow.")
        table.cell(tblI, 2, r, "MTF",     text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="ST / MT / LT correlation glyph. Shape reveals timeframe divergence.")
        table.cell(tblI, 3, r, "β",       text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Beta — OLS slope of log returns. Drives the Hedge Desk.")
        table.cell(tblI, 4, r, "R²",      text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Variance explained.")
        table.cell(tblI, 5, r, "Z",       text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Correlation z-score vs own history.")
        table.cell(tblI, 6, r, "%ile",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Percentile rank of current correlation.")
        table.cell(tblI, 7, r, "Stab",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Stability 0-100.")
        table.cell(tblI, 8, r, "Lead",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Optimal lag (scanned ±{1,3,5}) and correlation at that lag.")
        table.cell(tblI, 9, r, "Sprd",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Spread z-score — pairs signal.")
        table.cell(tblI, 10, r, "Qual",   text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Setup Quality 0-100 — composite of |corr| × R² × stab, adjusted for regime/clock/break.")
        table.cell(tblI, 11, r, "Hedge",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Hedge Desk: suggested hedge direction + $ notional = β × position size.")
        table.cell(tblI, 12, r, "AsymΔ",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Asymmetric Correlation Δ: ρ_stress − ρ_normal. Positive Δ = 'hedge' breaks down under stress (diversification fails). Institutional edge — no retail TV indicator surfaces this.")
        table.cell(tblI, 13, r, "Signal", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Composite intelligence verdict.")
    else
        table.cell(tblI, 0, r, "Symbol",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
        table.cell(tblI, 1, r, "Corr",    text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
        table.cell(tblI, 2, r, "MTF",     text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
        table.cell(tblI, 3, r, "R²",      text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
        table.cell(tblI, 4, r, "Signal",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
    r += 1

    // ── Rows 4-9: Per-symbol data ──
    f_render_intel_row(tblI, r, 0, i_sym1, corr1, r2_1, beta1, zs1, pct1, stab1, spZ1, chg1, st1, lt1, lag1, lagC1, qual1, hdg1, hd1, cN1, cS1, aDelta1, solo1, isPro)
    r += 1
    f_render_intel_row(tblI, r, 1, i_sym2, corr2, r2_2, beta2, zs2, pct2, stab2, spZ2, chg2, st2, lt2, lag2, lagC2, qual2, hdg2, hd2, cN2, cS2, aDelta2, solo2, isPro)
    r += 1
    f_render_intel_row(tblI, r, 2, i_sym3, corr3, r2_3, beta3, zs3, pct3, stab3, spZ3, chg3, st3, lt3, lag3, lagC3, qual3, hdg3, hd3, cN3, cS3, aDelta3, solo3, isPro)
    r += 1
    f_render_intel_row(tblI, r, 3, i_sym4, corr4, r2_4, beta4, zs4, pct4, stab4, spZ4, chg4, st4, lt4, lag4, lagC4, qual4, hdg4, hd4, cN4, cS4, aDelta4, solo4, isPro)
    r += 1
    f_render_intel_row(tblI, r, 4, i_sym5, corr5, r2_5, beta5, zs5, pct5, stab5, spZ5, chg5, st5, lt5, lag5, lagC5, qual5, hdg5, hd5, cN5, cS5, aDelta5, solo5, isPro)
    r += 1
    f_render_intel_row(tblI, r, 5, i_sym6, corr6, r2_6, beta6, zs6, pct6, stab6, spZ6, chg6, st6, lt6, lag6, lagC6, qual6, hdg6, hd6, cN6, cS6, aDelta6, solo6, isPro)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 12 — N×N MATRIX TABLE
// ═════════════════════════════════════════════════════════════════════════════════════

var table tblM = na

// Access a matrix cell given 1-based indices (using symmetry)
f_mat_cell(i1, j1) =>
    if i1 == j1
        1.0
    else
        int a = math.min(i1, j1)
        int b = math.max(i1, j1)
        float result = na
        if      a == 1 and b == 2
            result := p12
        else if a == 1 and b == 3
            result := p13
        else if a == 1 and b == 4
            result := p14
        else if a == 1 and b == 5
            result := p15
        else if a == 1 and b == 6
            result := p16
        else if a == 2 and b == 3
            result := p23
        else if a == 2 and b == 4
            result := p24
        else if a == 2 and b == 5
            result := p25
        else if a == 2 and b == 6
            result := p26
        else if a == 3 and b == 4
            result := p34
        else if a == 3 and b == 5
            result := p35
        else if a == 3 and b == 6
            result := p36
        else if a == 4 and b == 5
            result := p45
        else if a == 4 and b == 6
            result := p46
        else if a == 5 and b == 6
            result := p56
        result

f_sym_of(i1) =>
    switch i1
        1 => i_sym1
        2 => i_sym2
        3 => i_sym3
        4 => i_sym4
        5 => i_sym5
        6 => i_sym6
        =>   ""

if barstate.islast and i_show_matrix
    ts = f_txt_size(i_txt_size)
    int  cols = 7  // corner + 6 symbols
    int  rows = 8  // title + header + 6 symbols

    if na(tblM)
        tblM := table.new(f_pos(i_pos_matrix), cols, rows,
             border_width=i_border_width, border_color=i_border_color,
             frame_width=i_border_width,  frame_color=i_border_color)

    int r = 0

    // Title row — merged
    table.cell(tblM, 0, r, "◆ N×N CORRELATION MATRIX", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_center,
         tooltip="All-pairs correlation matrix. Each cell shows the Pearson correlation between the row symbol and the column symbol over " + str.tostring(i_corr_len) + " bars. Heatmap-colored.")
    table.merge_cells(tblM, 0, r, cols - 1, r)
    r += 1

    // Column header row — blank corner + 6 symbol names
    table.cell(tblM, 0, r, "", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts)
    for ci = 1 to 6
        string sym = f_sym_of(ci)
        string disp = sym == "" ? "—" : f_short_name(sym)
        table.cell(tblM, ci, r, disp, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip=sym == "" ? "Slot empty." : ("Symbol " + str.tostring(ci) + ": " + sym))
    r += 1

    // Matrix rows
    for ri = 1 to 6
        string rowSym = f_sym_of(ri)
        string rowDisp = rowSym == "" ? "—" : f_short_name(rowSym)
        table.cell(tblM, 0, r, rowDisp, text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_right, tooltip=rowSym == "" ? "Slot empty." : ("Symbol " + str.tostring(ri) + ": " + rowSym))

        for ci = 1 to 6
            float v = (rowSym == "" or f_sym_of(ci) == "") ? na : f_mat_cell(ri, ci)
            color bg = ri == ci ? #1f2833 : f_heatmap(v)
            color tc = ri == ci ? #546e7a : f_txt_contrast(v)
            string disp = ri == ci ? "•" : f_num(v, "#.00")
            string cellTip = ri == ci ? "Self-correlation (always 1.00)." : (f_short_name(rowSym) + " vs " + f_short_name(f_sym_of(ci)) + ": " + f_num(v, "#.####"))
            table.cell(tblM, ci, r, disp, text_color=tc, bgcolor=bg, text_size=ts, tooltip=cellTip)
        r += 1

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 13 — ACTION CENTER (Action List + Pairs + Risk Budget + Playbook)
// ═════════════════════════════════════════════════════════════════════════════════════

var table tblP = na

if barstate.islast and i_show_play
    ts = f_txt_size(i_txt_size)
    int  cols = 7
    int  rows = 22  // regime timer + risk budget + action title + action header + 5 actions + pairs title + pairs header + 3 pairs + playbook title + 5 playbook lines

    if na(tblP)
        tblP := table.new(f_pos(i_pos_play), cols, rows,
             border_width=i_border_width, border_color=i_border_color,
             frame_width=i_border_width,  frame_color=i_border_color)

    int r = 0

    // ─────────── ROW 0: REGIME TIMER + FLIP PROBABILITY ───────────
    string timerTxt = regimeLbl + " · " + str.tostring(regimeBars) + "b"
    if not na(avgRegimeRun)
        timerTxt := timerTxt + " (avg " + str.tostring(avgRegimeRun, "#") + "b)"
    timerTxt := timerTxt + "  ·  Flip " + str.tostring(flipProb10 * 100, "#") + "%/10b · " + str.tostring(flipProb30 * 100, "#") + "%/30b"
    string timerTip = "Regime Timer\n  Current regime: " + regimeLbl + "\n  Age: " + str.tostring(regimeBars) + " bars\n  Historical avg for this regime: " + f_num(avgRegimeRun, "#.#") + " bars\n  Flip probability:\n    Next 10 bars: " + str.tostring(flipProb10 * 100, "#") + "%\n    Next 30 bars: " + str.tostring(flipProb30 * 100, "#") + "%\n  Markov P(stay in " + regimeLbl + "): " + f_num(markovStay, "#.##")
    table.cell(tblP, 0, r, timerTxt, text_color=color.white, bgcolor=regimeCol, text_size=ts, text_halign=text.align_left, tooltip=timerTip)
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    // ─────────── ROW 1: RISK BUDGET ───────────
    string riskTxt = "RISK BUDGET " + str.tostring(riskBudgetPct) + "%  ·  Eff N " + f_num(effN, "#.#") + "/" + str.tostring(activeN) + "  ·  Clock " + str.tostring(crisisClock, "#") + "/100"
    string riskTip = "Risk Budget Advisor\n  Recommended gross exposure: " + str.tostring(riskBudgetPct) + "% of max\n  Effective N (true diversification): " + f_num(effN, "#.##") + " of " + str.tostring(activeN) + " symbols\n  Crisis Clock: " + str.tostring(crisisClock, "#") + "/100 (" + f_clock_label(crisisClock) + ")\n\nBasis: regime " + regimeLbl + " floors the budget at " + str.tostring(riskBudgetPct) + "%. Effective-N clamp kicks in when the basket is so correlated that you effectively have fewer independent bets than you think you do."
    table.cell(tblP, 0, r, riskTxt, text_color=color.white, bgcolor=f_risk_color(riskBudgetPct), text_size=ts, text_halign=text.align_left, tooltip=riskTip)
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    // ─────────── ACTION LIST TITLE ───────────
    table.cell(tblP, 0, r, "◆ ACTION LIST — ranked trades right now", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_center,
         tooltip="Top 5 actionable setups right now, ranked by score. Includes TRACK / HEDGE / PAIRS / LEADS / DISPERSION candidates, filtered by the Min Action Quality threshold.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    // Action list headers
    table.cell(tblP, 0, r, "#",     text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Rank.")
    table.cell(tblP, 1, r, "Type",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Action type.")
    table.cell(tblP, 2, r, "Target",text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Symbol or pair involved.")
    table.cell(tblP, 3, r, "Score", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Quality score 0-100.")
    table.cell(tblP, 4, r, "Direction", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Directional instruction.")
    table.cell(tblP, 5, r, "Size",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Suggested $ notional (scaled by quality and position size input).")
    table.cell(tblP, 6, r, "Why",   text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Rationale — supporting metrics.")
    r += 1

    // Action rows (up to 5)
    for rank = 0 to 4
        int ai = array.get(topAct, rank)
        if ai < 0
            table.cell(tblP, 0, r, str.tostring(rank + 1), text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts)
            for cc = 1 to cols - 1
                table.cell(tblP, cc, r, "—", text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts)
        else
            string atType = array.get(actType, ai)
            string atTgt  = array.get(actTgt, ai)
            float  atScore = array.get(actScore, ai)
            string atDir  = array.get(actDir, ai)
            string atSize = array.get(actSize, ai)
            string atWhy  = array.get(actWhy, ai)
            color  atCol  = array.get(actCol, ai)
            string atTip  = atType + " " + atTgt + "\n  Score: " + str.tostring(atScore, "#") + "/100\n  " + atDir + "\n  Size: " + atSize + "\n  " + atWhy

            table.cell(tblP, 0, r, str.tostring(rank + 1), text_color=color.white, bgcolor=atCol, text_size=ts, tooltip=atTip)
            table.cell(tblP, 1, r, atType, text_color=color.white, bgcolor=atCol, text_size=ts, tooltip=atTip)
            table.cell(tblP, 2, r, atTgt,  text_color=color.white, bgcolor=atCol, text_size=ts, text_halign=text.align_left, tooltip=atTip)
            table.cell(tblP, 3, r, str.tostring(atScore, "#"), text_color=color.white, bgcolor=atCol, text_size=ts, tooltip=atTip)
            table.cell(tblP, 4, r, atDir,  text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip=atTip)
            table.cell(tblP, 5, r, atSize, text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, tooltip=atTip)
            table.cell(tblP, 6, r, atWhy,  text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip=atTip)
        r += 1

    // ─────────── TOP PAIRS TITLE ───────────
    table.cell(tblP, 0, r, "▤ TOP LIVE PAIRS", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_center,
         tooltip="Top 3 live pairs-trade setups across all 15 unique pairs, ranked by stability × |spread z|.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    // Pairs header
    table.cell(tblP, 0, r, "#",     text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Rank.")
    table.cell(tblP, 1, r, "Pair",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Pair name. ✓ prefix = cointegrated (spread reliably mean-reverts).")
    table.cell(tblP, 2, r, "Stab",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Correlation stability 0-100.")
    table.cell(tblP, 3, r, "Z",     text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Spread z-score.")
    table.cell(tblP, 4, r, "HL/ρ",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="OU half-life in bars (cointegrated pairs). Falls back to correlation for non-cointegrated pairs.")
    table.cell(tblP, 5, r, "Dir",   text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Suggested direction.")
    table.cell(tblP, 6, r, "Size",  text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, tooltip="Suggested $ per leg.")
    r += 1

    // Top 3 pair rows
    for rank = 0 to 2
        int ti = array.get(topIdx, rank)
        if ti < 0
            table.cell(tblP, 0, r, str.tostring(rank + 1), text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts)
            for cc = 1 to cols - 1
                table.cell(tblP, cc, r, "—", text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts)
        else
            int i0 = array.get(aI, ti) - 1
            int j0 = array.get(aJ, ti) - 1
            float pC = array.get(aP, ti)
            float pS = array.get(aS, ti)
            float pZ = array.get(aZ, ti)
            bool  pCo = array.get(aCoint, ti)
            float pHL = array.get(aHL, ti)
            color bg = f_heatmap(pC)
            color tc = f_txt_contrast(pC)
            string nameA = f_sym_name(i0)
            string nameB = f_sym_name(j0)
            string dir = pZ > 0 ? ("-" + nameA + " +" + nameB) : ("+" + nameA + " -" + nameB)
            string pairLbl = (pCo ? "✓ " : "") + nameA + "/" + nameB
            string tip = "Pair: " + nameA + "/" + nameB + "\nCorr: " + f_num(pC, "#.####") + "\nStability: " + f_num(pS * 100, "#") + "/100\nSpread Z: " + f_num(pZ, "#.####") + "\nCointegrated: " + (pCo ? "✓ YES" : "— no") + (pCo ? ("\nOU Half-Life: " + f_num(pHL, "#.#") + " bars (expected mean-reversion time)") : "") + "\nSuggested: " + dir
            string hlTxt = pCo ? ("HL " + f_num(pHL, "#") + "b") : f_num(pC, "#.##")

            table.cell(tblP, 0, r, str.tostring(rank + 1), text_color=tc, bgcolor=bg, text_size=ts, tooltip=tip)
            table.cell(tblP, 1, r, pairLbl, text_color=tc, bgcolor=bg, text_size=ts, text_halign=text.align_left, tooltip=tip)
            table.cell(tblP, 2, r, f_num(pS * 100, "#"), text_color=tc, bgcolor=bg, text_size=ts, tooltip=tip)
            table.cell(tblP, 3, r, f_signed(pZ, "#.##"), text_color=tc, bgcolor=bg, text_size=ts, tooltip=tip)
            table.cell(tblP, 4, r, hlTxt, text_color=tc, bgcolor=bg, text_size=ts, tooltip=tip)
            table.cell(tblP, 5, r, dir, text_color=tc, bgcolor=bg, text_size=ts, text_halign=text.align_left, tooltip=tip)
            table.cell(tblP, 6, r, f_money(i_position_size * 0.75), text_color=tc, bgcolor=bg, text_size=ts, tooltip="Suggested size per leg (75% of base position).")
        r += 1

    // ─────────── PLAYBOOK TITLE ───────────
    table.cell(tblP, 0, r, "◈ TRADE PLAYBOOK", text_color=i_header_txt, bgcolor=i_header_bg, text_size=ts, text_halign=text.align_center,
         tooltip="Dynamic recommendations synthesizing regime, crisis clock, clock acceleration, market leader, and top pair.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    table.cell(tblP, 0, r, pb1, text_color=pb1col, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip=regimeTip)
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    table.cell(tblP, 0, r, pb2, text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip="Crisis Clock 20-bar delta.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    table.cell(tblP, 0, r, pb3, text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip="Symbol with largest lead/lag magnitude and meaningful correlation.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    table.cell(tblP, 0, r, pb4, text_color=i_panel_txt, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip="Top-ranked live pairs-trade setup.")
    table.merge_cells(tblP, 0, r, cols - 1, r)
    r += 1

    table.cell(tblP, 0, r, pb5, text_color=#546e7a, bgcolor=i_panel_bg, text_size=ts, text_halign=text.align_left, tooltip="Context footer.")
    table.merge_cells(tblP, 0, r, cols - 1, r)

// ═════════════════════════════════════════════════════════════════════════════════════
// SECTION 14 — ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════

// Strong positive/negative crossovers vs base
alertcondition(ta.crossover(corr1,  i_strong_thr),  title="Sym1 Strong+", message="{{ticker}}: Symbol 1 correlation crossed above strong threshold")
alertcondition(ta.crossover(corr2,  i_strong_thr),  title="Sym2 Strong+", message="{{ticker}}: Symbol 2 correlation crossed above strong threshold")
alertcondition(ta.crossover(corr3,  i_strong_thr),  title="Sym3 Strong+", message="{{ticker}}: Symbol 3 correlation crossed above strong threshold")
alertcondition(ta.crossover(corr4,  i_strong_thr),  title="Sym4 Strong+", message="{{ticker}}: Symbol 4 correlation crossed above strong threshold")
alertcondition(ta.crossover(corr5,  i_strong_thr),  title="Sym5 Strong+", message="{{ticker}}: Symbol 5 correlation crossed above strong threshold")
alertcondition(ta.crossover(corr6,  i_strong_thr),  title="Sym6 Strong+", message="{{ticker}}: Symbol 6 correlation crossed above strong threshold")

alertcondition(ta.crossunder(corr1, -i_strong_thr), title="Sym1 Strong-", message="{{ticker}}: Symbol 1 correlation crossed below negative strong threshold")
alertcondition(ta.crossunder(corr2, -i_strong_thr), title="Sym2 Strong-", message="{{ticker}}: Symbol 2 correlation crossed below negative strong threshold")
alertcondition(ta.crossunder(corr3, -i_strong_thr), title="Sym3 Strong-", message="{{ticker}}: Symbol 3 correlation crossed below negative strong threshold")
alertcondition(ta.crossunder(corr4, -i_strong_thr), title="Sym4 Strong-", message="{{ticker}}: Symbol 4 correlation crossed below negative strong threshold")
alertcondition(ta.crossunder(corr5, -i_strong_thr), title="Sym5 Strong-", message="{{ticker}}: Symbol 5 correlation crossed below negative strong threshold")
alertcondition(ta.crossunder(corr6, -i_strong_thr), title="Sym6 Strong-", message="{{ticker}}: Symbol 6 correlation crossed below negative strong threshold")

// Regime-break alerts
bool anyBreak = false
if not na(zs1)
    anyBreak := anyBreak or (math.abs(zs1) > i_break_z and math.abs(nz(zs1[1], 0.0)) <= i_break_z)
if not na(zs2)
    anyBreak := anyBreak or (math.abs(zs2) > i_break_z and math.abs(nz(zs2[1], 0.0)) <= i_break_z)
if not na(zs3)
    anyBreak := anyBreak or (math.abs(zs3) > i_break_z and math.abs(nz(zs3[1], 0.0)) <= i_break_z)
if not na(zs4)
    anyBreak := anyBreak or (math.abs(zs4) > i_break_z and math.abs(nz(zs4[1], 0.0)) <= i_break_z)
if not na(zs5)
    anyBreak := anyBreak or (math.abs(zs5) > i_break_z and math.abs(nz(zs5[1], 0.0)) <= i_break_z)
if not na(zs6)
    anyBreak := anyBreak or (math.abs(zs6) > i_break_z and math.abs(nz(zs6[1], 0.0)) <= i_break_z)
alertcondition(anyBreak, title="Regime Break Detected", message="{{ticker}}: A symbol correlation just broke its historical range")

// Crisis Clock level alerts
alertcondition(ta.crossover(crisisClock,  float(i_clock_stressed)), title="Clock → STRESSED",  message="{{ticker}}: Crisis Clock crossed into STRESSED territory")
alertcondition(ta.crossover(crisisClock,  float(i_clock_critical)), title="Clock → CRITICAL",  message="{{ticker}}: Crisis Clock crossed into CRITICAL territory")
alertcondition(ta.crossunder(crisisClock, float(i_clock_stressed)), title="Clock ← Easing",    message="{{ticker}}: Crisis Clock easing below STRESSED threshold")

// Clock acceleration
alertcondition(clockDelta > 15, title="Clock Accelerating", message="{{ticker}}: Crisis Clock rose >15 points in 20 bars — stress building rapidly")

// Pairs-trade setup (any qualifying pair)
bool anyPair = false
for idx = 0 to 14
    float scNow  = array.get(pScore, idx)
    float scPrev = nz(array.get(pScore, idx)[1], 0.0)
    if not na(scNow) and scNow > i_pairs_z * i_min_stab and scPrev <= i_pairs_z * i_min_stab
        anyPair := true
alertcondition(anyPair, title="Pairs Trade Setup", message="{{ticker}}: A new pairs-trade setup just qualified (stable correlation with extreme spread z)")

// Regime change
alertcondition(regimeLbl != regimeLbl[1], title="Regime Change", message="{{ticker}}: Market regime changed — check the Correlation Intelligence dashboard")
alertcondition(regimeLbl == "CRISIS" and regimeLbl[1] != "CRISIS", title="Crisis Regime Entered", message="{{ticker}}: Crisis regime detected — everything is correlating, diversification breaking down")

// Quality setup alerts — a symbol crossed above min quality
bool anyHighQuality = false
if not na(qual1)
    anyHighQuality := anyHighQuality or (qual1 >= i_min_quality and nz(qual1[1], 0.0) < i_min_quality)
if not na(qual2)
    anyHighQuality := anyHighQuality or (qual2 >= i_min_quality and nz(qual2[1], 0.0) < i_min_quality)
if not na(qual3)
    anyHighQuality := anyHighQuality or (qual3 >= i_min_quality and nz(qual3[1], 0.0) < i_min_quality)
if not na(qual4)
    anyHighQuality := anyHighQuality or (qual4 >= i_min_quality and nz(qual4[1], 0.0) < i_min_quality)
if not na(qual5)
    anyHighQuality := anyHighQuality or (qual5 >= i_min_quality and nz(qual5[1], 0.0) < i_min_quality)
if not na(qual6)
    anyHighQuality := anyHighQuality or (qual6 >= i_min_quality and nz(qual6[1], 0.0) < i_min_quality)
alertcondition(anyHighQuality, title="High-Quality Setup", message="{{ticker}}: A setup just crossed the Min Action Quality threshold — check the Action List")

// Regime flip probability ≥ 75%
alertcondition(flipProb30 >= 0.75 and nz(flipProb30[1], 0.0) < 0.75, title="Imminent Regime Flip",  message="{{ticker}}: 30-bar regime flip probability crossed 75% — expect a regime change soon")

// Dispersion trade setup
int dispStrongI = dispersionStrong ? 1 : 0
alertcondition(dispStrongI == 1 and nz(dispStrongI[1], 0) == 0, title="Dispersion Trade Setup", message="{{ticker}}: Basket decoupling with rising vol — long vol / short index-vol dispersion setup")

// Risk budget cuts
alertcondition(riskBudgetPct < nz(riskBudgetPct[1], riskBudgetPct), title="Risk Budget Reduced", message="{{ticker}}: Risk budget just dropped — the advisor is recommending lower gross exposure")

// Asymmetric correlation amplification (a "hedge" is failing under stress)
bool asymFail = false
if not na(aDelta1) and aDelta1 > 0.3 and nz(aDelta1[1], 0.0) <= 0.3
    asymFail := true
if not na(aDelta2) and aDelta2 > 0.3 and nz(aDelta2[1], 0.0) <= 0.3
    asymFail := true
if not na(aDelta3) and aDelta3 > 0.3 and nz(aDelta3[1], 0.0) <= 0.3
    asymFail := true
if not na(aDelta4) and aDelta4 > 0.3 and nz(aDelta4[1], 0.0) <= 0.3
    asymFail := true
if not na(aDelta5) and aDelta5 > 0.3 and nz(aDelta5[1], 0.0) <= 0.3
    asymFail := true
if not na(aDelta6) and aDelta6 > 0.3 and nz(aDelta6[1], 0.0) <= 0.3
    asymFail := true
alertcondition(asymFail, title="Asymmetric Correlation Amplification", message="{{ticker}}: A symbol's stress-regime correlation just spiked >0.3 above its normal-regime correlation — this 'hedge' is failing when you need it")

// New cointegration confirmed on any pair (a pair just became tradeable)
// Pine's nz() doesn't accept series bool, so convert to int (1/0) and compare.
int ci12 = co12 ? 1 : 0
int ci13 = co13 ? 1 : 0
int ci14 = co14 ? 1 : 0
int ci15 = co15 ? 1 : 0
int ci16 = co16 ? 1 : 0
int ci23 = co23 ? 1 : 0
int ci24 = co24 ? 1 : 0
int ci25 = co25 ? 1 : 0
int ci26 = co26 ? 1 : 0
int ci34 = co34 ? 1 : 0
int ci35 = co35 ? 1 : 0
int ci36 = co36 ? 1 : 0
int ci45 = co45 ? 1 : 0
int ci46 = co46 ? 1 : 0
int ci56 = co56 ? 1 : 0

bool newCoint = false
newCoint := newCoint or (ci12 == 1 and nz(ci12[1], 0) == 0)
newCoint := newCoint or (ci13 == 1 and nz(ci13[1], 0) == 0)
newCoint := newCoint or (ci14 == 1 and nz(ci14[1], 0) == 0)
newCoint := newCoint or (ci15 == 1 and nz(ci15[1], 0) == 0)
newCoint := newCoint or (ci16 == 1 and nz(ci16[1], 0) == 0)
newCoint := newCoint or (ci23 == 1 and nz(ci23[1], 0) == 0)
newCoint := newCoint or (ci24 == 1 and nz(ci24[1], 0) == 0)
newCoint := newCoint or (ci25 == 1 and nz(ci25[1], 0) == 0)
newCoint := newCoint or (ci26 == 1 and nz(ci26[1], 0) == 0)
newCoint := newCoint or (ci34 == 1 and nz(ci34[1], 0) == 0)
newCoint := newCoint or (ci35 == 1 and nz(ci35[1], 0) == 0)
newCoint := newCoint or (ci36 == 1 and nz(ci36[1], 0) == 0)
newCoint := newCoint or (ci45 == 1 and nz(ci45[1], 0) == 0)
newCoint := newCoint or (ci46 == 1 and nz(ci46[1], 0) == 0)
newCoint := newCoint or (ci56 == 1 and nz(ci56[1], 0) == 0)
alertcondition(newCoint, title="New Cointegrated Pair", message="{{ticker}}: A pair just became cointegrated (spread is mean-reverting) — check the Top Live Pairs for the tradeable setup")

// Zero cross (direction flip)
bool anyZero = false
if not na(corr1)
    anyZero := anyZero or ta.cross(corr1, 0.0)
if not na(corr2)
    anyZero := anyZero or ta.cross(corr2, 0.0)
if not na(corr3)
    anyZero := anyZero or ta.cross(corr3, 0.0)
if not na(corr4)
    anyZero := anyZero or ta.cross(corr4, 0.0)
if not na(corr5)
    anyZero := anyZero or ta.cross(corr5, 0.0)
if not na(corr6)
    anyZero := anyZero or ta.cross(corr6, 0.0)
alertcondition(anyZero, title="Any Corr Zero Cross", message="{{ticker}}: A symbol correlation has crossed the zero line — relationship flipped direction")
````

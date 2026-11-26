# Explainable Quant Scorecard [TradeDots]

- url: https://www.tradingview.com/script/eMdcgUaq-Explainable-Quant-Scorecard-TradeDots/
- type: indicator
- pine_id: PUB;df80d82728b045589e58e15195969c8c
- version: 1.0

## Description

[b]Explainable Quant Scorecard [TradeDots][/b]

[b]Summary[/b]

This indicator computes a composite 0 to 100 evidence score by combining seven independent normalized sub-scores: Trend, Momentum, Volatility Regime, Participation, Relative Strength, Exhaustion Risk, and Multi-Timeframe Alignment. The composite is regime-dependent: when ADX indicates a trending regime, the trend and momentum weights are boosted; when ADX indicates a range regime, the exhaustion-risk weight is boosted instead. All factor weights are exposed as inputs so the model is fully auditable and tunable. A flagship dashboard panel displays every sub-score, the composite, the active regime, and a one-line interpretation.

The intent is to give traders a transparent multi-factor reading on every bar rather than another single-indicator signal. The composite is an evidence score, not a probability or prediction.

[b]What is original here[/b]

Composite indicators that mash several oscillators together exist in the public library. This script's contributions are:

[list=1]
[*][b]Honest factor separation.[/b] Each sub-score measures a [i]different[/i] dimension (trend, momentum, volatility, participation, relative strength, exhaustion, multi-timeframe). Many composites silently combine correlated readings (such as two momentum oscillators) and present the result as if it were multi-factor confirmation. This script's seven factors are deliberately chosen to be diverse.
[*][b]Regime-dependent weighting.[/b] The composite is not a fixed weighted average. When the market is trending, trend and momentum factors carry more weight; when ranging, exhaustion-risk carries more. This addresses the well-known problem that trend-following inputs and mean-reversion inputs should not be weighted equally in all conditions.
[*][b]Sub-score divergence detection.[/b] The script tracks the maximum deviation of any sub-score from the composite. A large deviation triggers a "sub-score divergence" alert, warning the trader that the factors disagree even when the composite looks clean.
[*][b]Full transparency.[/b] All weights, all thresholds, and the regime trigger levels are user inputs. No black-box.
[/list]

[b]How it works[/b]

Each bar, seven sub-scores are computed.

[b]1. Trend score.[/b] EMA slope over a configurable lookback, normalized to 0 to 100 via min-max over a percentile window.

[b]2. Momentum score.[/b] Rate-of-change of close over a configurable length, min-max normalized.

[b]3. Volatility regime score.[/b] Bollinger Bandwidth percentile mapped to a discrete numeric: compressed BBW (below the lower threshold) maps to 30, expanding BBW (above the upper threshold) maps to 70, normal BBW maps to 50. A label ("Compressed", "Normal", "Expanding") is generated alongside the numeric.

[b]4. Participation score.[/b] Volume percentile multiplied by a close-location alignment factor. For a bullish-direction reading, a close near the bar's high earns full alignment; for a bearish-direction reading, a close near the bar's low. The result is a 0 to 100 score that rewards volume [i]and[/i] direction-consistent closes.

[b]5. Relative strength score.[/b] The asset's return over a configurable horizon, minus the benchmark's return over the same horizon, divided by the asset's own volatility. The result is percentile-ranked over a longer lookback (default 252 bars) to produce a 0 to 100 reading. The benchmark symbol is a user input.

[b]6. Exhaustion risk score.[/b] Distance from the trend EMA in ATR units, mapped inversely to 0 to 100 (high exhaustion gives a [i]low[/i] exhaustion-score, which is consistent with the convention that high scores are "good" for the composite). The dashboard inverts the label so users see "Exhaustion: High" rather than "Exhaustion: 20".

[b]7. Multi-timeframe alignment score.[/b] The trend direction (EMA-fast vs EMA-slow) is fetched at three user-configurable higher timeframes. Each HTF's agreement with the chart-timeframe direction contributes 100, 50, or 0 to the alignment score. The final factor is the average across three timeframes.

The composite is the weighted average. When regime_weighting is enabled and ADX indicates a trending regime (above the user threshold), the trend and momentum weights are multiplied by 1.5 and the exhaustion-risk weight by 0.5. When ADX indicates a range regime (below the lower threshold), the trend and momentum weights are multiplied by 0.5 and the exhaustion-risk weight by 1.5. In a "Mixed" regime, weights are unchanged.

A four-line interpretation is assigned by composite range:

[list]
[*]75 or higher : "Constructive, multi-factor agreement"
[*]60 to 74     : "Mixed but constructive"
[*]40 to 59     : "Mixed — wait for alignment"
[*]below 40     : "Bearish or unclear"
[/list]

[b]Repainting and data integrity[/b]

All sub-scores are computed on confirmed bar values. Alerts are gated by barstate.isconfirmed. The benchmark and the three multi-timeframe trend references are fetched with request.security() using prior-bar sources together with barmerge.lookahead_on — the standard non-repainting idiom that returns the last confirmed value from the requested context. These calls do not access future data.

[b]How to read the chart[/b]

[list]
[*]The composite is plotted as a line in the indicator pane, color-shifted on a red-to-green gradient based on the score.
[*]Horizontal reference lines at 25, 50, and 75 demarcate bearish, midpoint, and bullish zones.
[*]Sub-score plots are available but off by default to keep the pane clean. They can be enabled via input toggle.
[*]The dashboard panel shows the direction in the header, then a row for each of the seven sub-scores (numeric or labelled), then a divider, then the composite score, then the interpretation line and the active regime.
[/list]

[b]Inputs[/b]

Inputs are grouped into seven sections.

[list]
[*][b]Core Settings[/b]: trend EMA lengths and norm lookback, momentum ROC length, generic norm lookback, BB length and multiplier, ATR length, ADX length.
[*][b]Relative Strength[/b]: benchmark symbol, RS return horizon, RS volatility length, RS percentile lookback.
[*][b]Multi-Timeframe[/b]: three HTF inputs (default 60-minute, 240-minute, daily).
[*][b]Factor Weights[/b]: a 0 to N weight for each of the seven sub-scores.
[*][b]Regime Modulation[/b]: regime-weighting enable toggle, trend ADX threshold, range ADX threshold.
[*][b]Visual Settings[/b]: dashboard toggle, panel position, panel size, panel background color, composite-plot toggle, sub-score-plot toggle.
[*][b]Any Alert() function call conditions[/b]: per-alert toggles.
[/list]

[b]Alerts[/b]

Four alert conditions are provided:

[list]
[*]Score ≥ 75 Bullish (composite at or above 75 with trend direction up)
[*]Score ≥ 75 Bearish (composite at or above 75 with trend direction down)
[*]Score Regime Flipped (composite crossed the 50 midpoint in either direction)
[*]Sub-Score Divergence (any sub-score moves more than 30 points from the composite — a warning that factors disagree)
[/list]

Each is declared via alertcondition() and fired programmatically through alert() when the corresponding input toggle is enabled, with alert.freq_once_per_bar_close. Alert messages include {{ticker}}, {{interval}}, and {{close}} placeholders.

[b]How to use this script[/b]

[list=1]
[*]Read this indicator as your master "is the evidence stack constructive" check, not as an entry trigger.
[*]A composite of 75 or higher with trend direction up is the suite's highest-conviction long setup; the inverse for shorts.
[*]Read the regime cell. In a trending regime, weight your decision toward the trend and momentum sub-scores. In a range regime, weight toward exhaustion risk and relative strength.
[*]If the dashboard shows a high composite but the "Sub-Score Divergence" alert is firing, the agreement is shallow — investigate which factor disagrees before sizing up.
[*]Pair with a setup-specific indicator (sweep, breakout, zone) for entry timing. This script does not give entries.
[/list]

[b]Limitations and honest caveats[/b]

[list]
[*]The composite is a weighted heuristic combination of normalized factors, not a calibrated probability. A composite of 80 does not imply an 80% probability of any outcome.
[*]Regime detection uses ADX, which is lagging. The regime label will not reflect a fresh regime change on the first bar.
[*]The Relative Strength benchmark is a single symbol chosen by the user. Choosing an inappropriate benchmark (for example, comparing a small-cap stock to a crypto-currency benchmark) will produce noisy RS readings.
[*]The three MTF references add request.security() calls. On instruments without history at those timeframes, the MTF score may be incomplete on early bars.
[*]Composite values pin to one tail when factor weights are mis-configured. The default weights are reasonable starting values; users are expected to tune for their instrument and timeframe.
[*]The script makes no claim about which direction price will move; it scores the evidence stack currently visible.
[/list]

[b]Disclaimer[/b]

This script is published for informational and educational purposes. It is not investment advice and is not a recommendation to buy or sell any instrument. Composite evidence scores are descriptive, not predictive. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=6
// =============================================================================
// Explainable Quant Scorecard [TradeDots]   (flagship)
// shorttitle: TD-SCR
//
// Concept: One clean scorecard for trend, volatility, liquidity, momentum, and
// risk. A composite of seven normalized 0-100 sub-scores, with regime-dependent
// weighting and an honest interpretation line.
//
// Sub-scores:
//   1. Trend          — EMA slope normalized over a lookback
//   2. Momentum       — ROC min/max normalized
//   3. Vol Regime     — Bollinger Bandwidth percentile (mapped)
//   4. Participation  — Volume percentile gated by close-location alignment
//   5. Relative Strength — Risk-adjusted vs benchmark, percentile-ranked
//   6. Exhaustion Risk— Distance from EMA in ATR units (inverse)
//   7. MTF Alignment  — Average of (LTF trend == HTF trend) across 3 TFs
//
// The composite is regime-dependent: when ADX says we're trending, trend &
// momentum weights are boosted; when ranging, exhaustion weight is boosted.
//
// Honest framing: weights are exposed, the formula is explainable, no black-box
// AI claims. This is an evidence layer, not a prediction.
// =============================================================================

indicator(title         = "Explainable Quant Scorecard [TradeDots]",
          shorttitle    = "TD-SCR",
          overlay       = false,
          max_labels_count = 200,
          format        = format.price,
          precision     = 1)

// ============================ TradeDots palette =============================
color tdBull       = #9cff87
color tdBear       = #f9396a
color tdLight      = #FBFFF4
color tdWhite      = #ffffff
color tdDark       = #1b1b1b
color tdOrange     = #ff6633
color tdCyan       = #90e0ef
color tdMutedPink  = #ea9ab2
color tdForestGrn  = #1b4332
color tdNeutral    = #0077b6
color tdBullText   = #204634

GROUP_CORE     = "Core Settings"
GROUP_RS       = "Relative Strength"
GROUP_MTF      = "Multi-Timeframe"
GROUP_SCORE    = "Factor Weights"
GROUP_REGIME   = "Regime Modulation"
GROUP_VIS      = "Visual Settings"
GROUP_ALERT    = "Any Alert() function call conditions"

// ================================= INPUTS ===================================
trend_ema_fast = input.int(50,  "Trend EMA (fast)",  group = GROUP_CORE)
trend_ema_slow = input.int(200, "Trend EMA (slow)",  group = GROUP_CORE)
trend_norm_len = input.int(100, "Trend Norm Lookback", group = GROUP_CORE)
momo_len       = input.int(14,  "Momentum ROC Length", group = GROUP_CORE)
norm_len       = input.int(100, "Generic Norm Lookback", group = GROUP_CORE,
                           tooltip = "Used for ROC / volume percentile windows.")
bb_len         = input.int(20,  "BB Length", group = GROUP_CORE)
bb_mult        = input.float(2.0,"BB StdDev Multiplier", minval = 0.5, step = 0.1, group = GROUP_CORE)
atr_len        = input.int(14,  "ATR Length", group = GROUP_CORE)
adx_len        = input.int(14,  "ADX Length", group = GROUP_CORE)

rs_benchmark   = input.symbol("SPY", "Benchmark Symbol", group = GROUP_RS)
rs_len         = input.int(20, "RS Return Horizon (bars)", group = GROUP_RS)
rs_vol_len     = input.int(20, "RS Volatility Length",     group = GROUP_RS)
rs_pct_len     = input.int(252, "RS Percentile Lookback",  group = GROUP_RS)

htf1           = input.timeframe("60",  "MTF #1 (e.g. 60m)",  group = GROUP_MTF)
htf2           = input.timeframe("240", "MTF #2 (e.g. 240m)", group = GROUP_MTF)
htf3           = input.timeframe("D",   "MTF #3 (e.g. Daily)",group = GROUP_MTF)

w_trend          = input.float(1.0, "Trend Weight",         minval = 0, step = 0.1, group = GROUP_SCORE)
w_momo           = input.float(1.0, "Momentum Weight",      minval = 0, step = 0.1, group = GROUP_SCORE)
w_vol_regime     = input.float(0.7, "Volatility Regime Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_participation  = input.float(1.0, "Participation Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_rs             = input.float(1.0, "Relative Strength Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_exhaust        = input.float(0.8, "Exhaustion Risk Weight (inverse)", minval = 0, step = 0.1, group = GROUP_SCORE)
w_mtf            = input.float(1.0, "MTF Alignment Weight", minval = 0, step = 0.1, group = GROUP_SCORE)

regime_weighting = input.bool(true, "Regime-Dependent Weighting",
                              group = GROUP_REGIME,
                              tooltip = "Boost trend/momentum weights when ADX says we're trending; boost exhaustion weight when ranging.")
trend_adx_thresh = input.float(25, "Trend ADX Threshold", group = GROUP_REGIME)
range_adx_thresh = input.float(15, "Range ADX Threshold", group = GROUP_REGIME)

show_dashboard  = input.bool(true, "Show Scorecard",  group = GROUP_VIS)
panel_pos       = input.string("Bottom Right", "Panel Position", group = GROUP_VIS,
                               options = ["Hidden", "Top Right", "Bottom Right", "Bottom Left", "Top Left"])
panel_size      = input.string("Normal", "Panel Size", group = GROUP_VIS,
                               options = ["Tiny", "Small", "Normal", "Large"])
panel_color     = input.color(tdDark, "Panel Background", group = GROUP_VIS)
show_composite_plot = input.bool(true, "Plot Composite Line", group = GROUP_VIS)
show_subscore_plots = input.bool(false, "Plot Sub-Score Lines (cluttered)", group = GROUP_VIS)

alert_bull_setup = input.bool(false, "Score ≥ 75 Bullish",     group = GROUP_ALERT, inline = "G1")
alert_bear_setup = input.bool(false, "Score ≥ 75 Bearish",     group = GROUP_ALERT, inline = "G1")
alert_regime_flip= input.bool(false, "Score Regime Flipped",   group = GROUP_ALERT, inline = "G2")
alert_divergence = input.bool(false, "Sub-Score Divergence",   group = GROUP_ALERT, inline = "G2",
                              tooltip = "Fires when any sub-score moves > 30 points away from the composite (warning of internal disagreement).")

// ===================== TradeDots Quant Primitives (inlined) =================
f_pct_rank(src, len) =>
    ta.percentrank(src, len)

f_zscore(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s == 0 ? 0.0 : (src - m) / s

f_minmax_norm(src, len) =>
    hi = ta.highest(src, len)
    lo = ta.lowest(src, len)
    hi == lo ? 50.0 : (src - lo) / (hi - lo) * 100

f_clamp_100(x) =>
    math.max(0, math.min(100, x))

f_eff_ratio(src, len) =>
    change_total = math.abs(src - src[len])
    volatility   = math.sum(math.abs(src - src[1]), len)
    volatility == 0 ? 0.0 : change_total / volatility

f_vol_pct(len_rank) =>
    na(volume) ? na : ta.percentrank(volume, len_rank)

f_clv() =>
    rng = high - low
    rng == 0 ? 50.0 : (close - low) / rng * 100

f_pos(s) =>
    s == "Top Right"    ? position.top_right    :
      s == "Bottom Right" ? position.bottom_right :
      s == "Bottom Left"  ? position.bottom_left  :
      s == "Top Left"     ? position.top_left     : position.bottom_right

f_sz(s) =>
    s == "Tiny"  ? size.tiny  :
      s == "Small" ? size.small :
      s == "Large" ? size.large : size.normal

// ============================ CORE COMPUTATIONS =============================
atrv   = ta.atr(atr_len)
[_diplus, _diminus, adx] = ta.dmi(adx_len, adx_len)
ema_f  = ta.ema(close, trend_ema_fast)
ema_s  = ta.ema(close, trend_ema_slow)

// Regime classification
regime = adx >= trend_adx_thresh ? "Trend" : adx <= range_adx_thresh ? "Range" : "Mixed"

// ============================== SUB-SCORES ==================================
// 1. Trend score — normalized EMA slope, biased to 50 at flat.
ema_slope        = ema_f - ema_f[5]
trend_signed_norm = f_minmax_norm(ema_slope, trend_norm_len)
trend_score       = f_clamp_100(trend_signed_norm)
trend_direction   = ema_f > ema_s ?  1 : ema_f < ema_s ? -1 : 0

// 2. Momentum score — ROC normalized.
roc_raw     = ta.roc(close, momo_len)
momo_score  = f_clamp_100(f_minmax_norm(roc_raw, norm_len))

// 3. Volatility regime score — BBW percentile, mapped:
//    compressed (low) → 30, normal → 50, expanding → 70.
basis     = ta.sma(close, bb_len)
dev       = bb_mult * ta.stdev(close, bb_len)
bbw       = basis == 0 ? 0.0 : ((basis + dev) - (basis - dev)) / basis * 100
bbw_pctr  = ta.percentrank(bbw, norm_len)
vol_regime_score = bbw_pctr < 25 ? 30.0 : bbw_pctr > 75 ? 70.0 : 50.0
vol_regime_label = bbw_pctr < 25 ? "Compressed" : bbw_pctr > 75 ? "Expanding" : "Normal"

// 4. Participation score — volume percentile, gated by direction-aligned CLV.
vol_pctr     = nz(f_vol_pct(norm_len), 50.0)
clv          = f_clv()
participation_align = trend_direction == 1  ? clv / 100.0 :
                      trend_direction == -1 ? (100 - clv) / 100.0 : 0.5
participation_score = f_clamp_100(vol_pctr * participation_align + (1 - participation_align) * vol_pctr * 0.5)

// 5. Relative strength score — risk-adjusted, percentile-ranked.
bench_close   = request.security(rs_benchmark, timeframe.period, close[1],
                                 barmerge.gaps_off, barmerge.lookahead_on)
asset_ret    = (close - close[rs_len]) / close[rs_len]
bench_ret    = na(bench_close) or na(bench_close[rs_len]) or bench_close[rs_len] == 0 ?
               0.0 : (bench_close - bench_close[rs_len]) / bench_close[rs_len]
rel_ret      = asset_ret - bench_ret
asset_vol    = ta.stdev(ta.roc(close, 1), rs_vol_len) / 100.0
rrs          = asset_vol == 0 ? 0.0 : rel_ret / asset_vol
rs_score     = f_clamp_100(ta.percentrank(rrs, rs_pct_len))

// 6. Exhaustion risk score — distance from EMA in ATR units (capped). Inverse:
//    far from EMA = high exhaustion = LOW score on this factor (since a "good"
//    setup is one with low exhaustion). The dashboard inverts the label.
dist_from_ema_atr = atrv == 0 ? 0.0 : math.abs(close - ema_f) / atrv
exhaust_score     = f_clamp_100(100 - dist_from_ema_atr * 25)  // higher score = LESS exhausted

// 7. MTF alignment score — average across 3 HTFs of (LTF trend dir == HTF dir).
htf_dir_src() => ta.ema(close, trend_ema_fast) > ta.ema(close, trend_ema_slow) ? 1 :
                 ta.ema(close, trend_ema_fast) < ta.ema(close, trend_ema_slow) ? -1 : 0
htf_dir_1 = request.security(syminfo.tickerid, htf1, htf_dir_src()[1],
                             barmerge.gaps_on, barmerge.lookahead_on)
htf_dir_2 = request.security(syminfo.tickerid, htf2, htf_dir_src()[1],
                             barmerge.gaps_on, barmerge.lookahead_on)
htf_dir_3 = request.security(syminfo.tickerid, htf3, htf_dir_src()[1],
                             barmerge.gaps_on, barmerge.lookahead_on)
mtf_match_1 = htf_dir_1 == trend_direction ? 100.0 :
              htf_dir_1 == 0               ?  50.0 : 0.0
mtf_match_2 = htf_dir_2 == trend_direction ? 100.0 :
              htf_dir_2 == 0               ?  50.0 : 0.0
mtf_match_3 = htf_dir_3 == trend_direction ? 100.0 :
              htf_dir_3 == 0               ?  50.0 : 0.0
mtf_score = (mtf_match_1 + mtf_match_2 + mtf_match_3) / 3.0

// =============================== COMPOSITE ==================================
// Regime-dependent weight modulation.
w_trend_eff       = w_trend
w_momo_eff        = w_momo
w_vol_eff         = w_vol_regime
w_part_eff        = w_participation
w_rs_eff          = w_rs
w_exhaust_eff     = w_exhaust
w_mtf_eff         = w_mtf
if regime_weighting and regime == "Trend"
    w_trend_eff   := w_trend   * 1.5
    w_momo_eff    := w_momo    * 1.5
    w_exhaust_eff := w_exhaust * 0.5
if regime_weighting and regime == "Range"
    w_trend_eff   := w_trend   * 0.5
    w_momo_eff    := w_momo    * 0.5
    w_exhaust_eff := w_exhaust * 1.5

w_total = w_trend_eff + w_momo_eff + w_vol_eff + w_part_eff +
          w_rs_eff + w_exhaust_eff + w_mtf_eff

raw_composite = (w_trend_eff   * trend_score       +
                 w_momo_eff    * momo_score        +
                 w_vol_eff     * vol_regime_score  +
                 w_part_eff    * participation_score +
                 w_rs_eff      * rs_score          +
                 w_exhaust_eff * exhaust_score     +
                 w_mtf_eff     * mtf_score) / math.max(w_total, 0.01)

composite = f_clamp_100(raw_composite)

// Directional bias for the composite — same direction as the trend module.
composite_signed = trend_direction >= 0 ? composite : 100 - composite

interpretation = composite >= 75 ? "Constructive, multi-factor agreement" : composite >= 60 ? "Mixed but constructive" : composite >= 40 ? "Mixed — wait for alignment" : "Bearish or unclear"

// ============================= DIVERGENCE CHECK =============================
// Sub-score divergence = any sub-score deviates > 30 from the composite.
sub_scores       = array.from(trend_score, momo_score, vol_regime_score,
                              participation_score, rs_score, exhaust_score, mtf_score)
sub_score_names  = array.from("Trend", "Momentum", "Vol Regime", "Participation",
                              "Rel. Strength", "Exhaustion", "MTF")
max_diverge = 0.0
diverge_name = ""
for i = 0 to array.size(sub_scores) - 1
    d = math.abs(array.get(sub_scores, i) - composite)
    if d > max_diverge
        max_diverge := d
        diverge_name := array.get(sub_score_names, i)
divergence_alert = max_diverge > 30

// ============================== VISUALS =====================================
// Composite line (recommended) — color shifts with score.
comp_color = color.from_gradient(composite, 30, 80, tdBear, tdBull)
plot(show_composite_plot ? composite : na, title = "Composite",
     color = comp_color, linewidth = 2)

// Reference lines.
hline(75, "Bullish Threshold", color = color.new(tdBull, 70), linestyle = hline.style_dashed)
hline(50, "Midpoint",          color = color.new(tdLight, 80), linestyle = hline.style_dotted)
hline(25, "Bearish Threshold", color = color.new(tdBear, 70), linestyle = hline.style_dashed)

// Optional individual sub-score plots (off by default — they clutter).
plot(show_subscore_plots ? trend_score        : na, "Trend Sub",         color = color.new(tdCyan, 30),     display = show_subscore_plots ? display.all : display.none)
plot(show_subscore_plots ? momo_score         : na, "Momentum Sub",      color = color.new(tdOrange, 30),    display = show_subscore_plots ? display.all : display.none)
plot(show_subscore_plots ? participation_score: na, "Participation Sub", color = color.new(tdBull, 50),      display = show_subscore_plots ? display.all : display.none)
plot(show_subscore_plots ? rs_score           : na, "RS Sub",            color = color.new(tdMutedPink, 30), display = show_subscore_plots ? display.all : display.none)
plot(show_subscore_plots ? exhaust_score      : na, "Exhaustion Sub",    color = color.new(tdNeutral, 30),   display = show_subscore_plots ? display.all : display.none)
plot(show_subscore_plots ? mtf_score          : na, "MTF Sub",           color = color.new(tdLight, 50),     display = show_subscore_plots ? display.all : display.none)

// Hidden alert-feed plots.
plot(composite,           "Composite (hidden)",   display = display.none)
plot(trend_direction,     "Trend Direction",      display = display.none)
plot(max_diverge,         "Max Divergence",       display = display.none)

// =============================== DASHBOARD ==================================
panel_visible = show_dashboard and panel_pos != "Hidden"
var table panel = table.new(f_pos(panel_pos), columns = 2, rows = 11,
                            bgcolor = color.new(panel_color, 30), border_width = 1)

f_row(row, k, v, score_val) =>
    table.cell(panel, 0, row, k,
               text_color = tdLight, text_size = f_sz(panel_size),
               text_halign = text.align_left)
    fill = na(score_val) ? color.new(panel_color, 60) :
           color.new(color.from_gradient(score_val, 0, 100, tdBear, tdBull), 25)
    table.cell(panel, 1, row, v,
               bgcolor = fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)

if panel_visible and barstate.islast
    // Header
    header_dir_text = trend_direction == 1 ? "▲ BULL" : trend_direction == -1 ? "▼ BEAR" : "↔ FLAT"
    header_dir_color = trend_direction == 1 ? color.new(tdBull, 15) : trend_direction == -1 ? color.new(tdBear, 15) : color.new(panel_color, 50)
    header_txt_color = trend_direction == 1 ? tdBullText : tdWhite
    table.cell(panel, 0, 0, "TD-SCR • Quant Scorecard",
               bgcolor = color.new(panel_color, 0), text_color = tdLight,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 0, header_dir_text,
               bgcolor = header_dir_color, text_color = header_txt_color,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    // Sub-scores
    f_row(1, "Trend",          str.tostring(trend_score, "#") + "/100",         trend_score)
    f_row(2, "Momentum",       str.tostring(momo_score, "#") + "/100",          momo_score)
    f_row(3, "Volatility",     vol_regime_label,                                vol_regime_score)
    f_row(4, "Participation",  str.tostring(participation_score, "#") + "/100", participation_score)
    f_row(5, "Rel. Strength",  str.tostring(rs_score, "#") + "/100",            rs_score)
    f_row(6, "Exhaustion",     dist_from_ema_atr >= 3 ? "High" :
                                dist_from_ema_atr >= 1.5 ? "Medium" : "Low",     exhaust_score)
    f_row(7, "MTF Alignment",  mtf_score >= 75 ? "Aligned" :
                                mtf_score >= 40 ? "Mixed"   : "Conflict",        mtf_score)
    // Composite divider
    table.cell(panel, 0, 8, "─────────",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 8, "─────",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_right)
    // Composite
    comp_fill = color.new(color.from_gradient(composite, 25, 80, tdBear, tdBull), 15)
    table.cell(panel, 0, 9, "Composite",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 9, str.tostring(composite, "#") + " / 100",
               bgcolor = comp_fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    // Interpretation
    interp_fill = composite >= 75 ? color.new(tdBull, 25) :
                  composite >= 40 ? color.new(tdOrange, 30) :
                                     color.new(tdBear, 25)
    table.cell(panel, 0, 10, "Interpretation",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 10, interpretation + " (" + regime + ")",
               bgcolor = interp_fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)

// ============================== ALERTS ======================================
cond_bull_setup   = composite >= 75 and trend_direction ==  1 and barstate.isconfirmed
cond_bear_setup   = composite >= 75 and trend_direction == -1 and barstate.isconfirmed
cond_score_regime_flip = (composite >= 50) != (composite[1] >= 50) and barstate.isconfirmed
cond_divergence   = divergence_alert and not divergence_alert[1] and barstate.isconfirmed

alertcondition(cond_bull_setup,
               title   = "TD-SCR Score ≥ 75 Bullish",
               message = "TD-SCR Score ≥ 75 Bullish on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_bear_setup,
               title   = "TD-SCR Score ≥ 75 Bearish",
               message = "TD-SCR Score ≥ 75 Bearish on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_score_regime_flip,
               title   = "TD-SCR Score Regime Flipped",
               message = "TD-SCR Score Regime flipped on {{ticker}} {{interval}}")
alertcondition(cond_divergence,
               title   = "TD-SCR Sub-Score Divergence",
               message = "TD-SCR Sub-score divergence on {{ticker}} {{interval}}")

if alert_bull_setup and cond_bull_setup
    alert("🟢 TD-SCR Bullish Setup • Score " + str.tostring(composite, "#") + " (" + regime + ")",
          alert.freq_once_per_bar_close)
if alert_bear_setup and cond_bear_setup
    alert("🔴 TD-SCR Bearish Setup • Score " + str.tostring(composite, "#") + " (" + regime + ")",
          alert.freq_once_per_bar_close)
if alert_regime_flip and cond_score_regime_flip
    alert("TD-SCR Score Regime flipped • Composite " + str.tostring(composite, "#"),
          alert.freq_once_per_bar_close)
if alert_divergence and cond_divergence
    alert("TD-SCR Sub-score divergence • " + diverge_name +
          " is " + str.tostring(max_diverge, "#") + " pts from composite",
          alert.freq_once_per_bar_close)
````

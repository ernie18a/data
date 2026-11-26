# Liquidity Sweep Quality Score [TradeDots]

- url: https://www.tradingview.com/script/oOyme5GV-Liquidity-Sweep-Quality-Score-TradeDots/
- type: indicator
- pine_id: PUB;8dfc8fed25304c08bebb719aaeaf3f8e
- version: 1.0

## Description

[b]Liquidity Sweep Quality Score [TradeDots][/b]

[b]Summary[/b]

This indicator detects liquidity-sweep events on the chart timeframe and assigns each event a 0 to 100 composite quality score with an A+, A, B, C, D, or Weak letter grade. A liquidity sweep here is defined precisely: the current bar prints beyond a confirmed swing pivot (below a prior swing low for a bullish sweep, or above a prior swing high for a bearish sweep) and closes back inside the prior range. The composite score is built from six independent factors that quantify how decisively the rejection occurred and how supportive the surrounding context is. The grade label is drawn on the bar immediately after the sweep so that the score includes the first piece of follow-through evidence.

[b]What is original here[/b]

Detecting liquidity sweeps from pivot geometry is straightforward and is already common across public scripts. Where most scripts stop at binary detection ("a sweep happened"), this script adds a multi-factor quality layer on top. The originality is in the scoring methodology: six measurable factors, each normalized to a 0 to 100 scale so that raw units do not dominate, combined as a weighted average with a regime-aware penalty applied at the end. All weights and thresholds are exposed as inputs so that the model is auditable and tunable. The contribution is not the detection but the explicit, transparent scoring layer that lets traders rank sweeps rather than treat them as uniformly meaningful.

[b]How it works[/b]

Pivots are tracked with the standard pivot-high and pivot-low primitives using a user-configurable symmetric left/right lookback. The most recently confirmed swing high and swing low are held in memory.

A bullish sweep registers when the current bar's low prints below the most recent swing low and the current close finishes above it. A bearish sweep is the symmetric case. A wick-to-body ratio gate filters trivial events where the rejection wick is too small relative to the candle body. Signal evaluation is gated by barstate.isconfirmed, so signals only finalize at bar close.

When a sweep is detected, the six factors below are computed.

[b]1. Wick rejection strength.[/b] The size of the rejection wick on the sweep candle relative to the candle body. A larger wick relative to body indicates a more decisive intrabar rejection of the swept level. Scaled by the user's minimum acceptable wick-to-body ratio.

[b]2. Relative volume.[/b] The rolling percentile rank of the sweep bar's volume within a configurable lookback (default 100 bars). Sweeps occurring on volume in the upper percentiles score higher than sweeps on quiet bars.

[b]3. Failed-break decisiveness.[/b] The distance between the swept pivot and the close, expressed in ATR units. A close that recovers a full ATR back inside the prior range scores higher than a marginal recovery.

[b]4. Higher-timeframe level proximity.[/b] The distance between the close and the nearest of the prior higher-timeframe bar's high or low, expressed in ATR units. Sweeps near a major higher-timeframe level score higher than sweeps at intra-range pivots.

[b]5. Follow-through confirmation.[/b] The bar immediately after the sweep is inspected. A directionally consistent follow-through (a green bar after a bullish sweep, a red bar after a bearish sweep) earns full credit. Because this factor requires the next bar, the composite is finalized one bar after the sweep candle and the grade label is drawn on the follow-through bar, not on the sweep bar itself. This is documented behaviour, not a defect.

[b]6. Regime penalty.[/b] Computed from ADX and the EMA-50 / EMA-200 alignment. When a sweep occurs against the direction of a strongly trending market (ADX above the user threshold and the sweep direction conflicts with the EMA alignment), a fixed user-configurable penalty is subtracted from the composite. A bullish sweep in a strong downtrend is structurally the same pattern as a bullish sweep in a balanced range, but the prior probability of follow-through differs. The penalty makes that difference visible in the score.

The composite is the weighted average of factors 1 through 5, with factor 6 applied as a post-weighting deduction. Tier mapping:

[list]
[*]A+ : score 90 or higher
[*]A  : score 80 to 89
[*]B  : score 70 to 79
[*]C  : score 60 to 69
[*]D  : score 50 to 59
[*]Weak : below 50
[/list]

[b]Repainting and data integrity[/b]

All sweep detection, scoring, label placement, and alert triggers are gated by barstate.isconfirmed. Signals do not appear or change intrabar.

The higher-timeframe level is fetched with request.security() using the prior-bar source (high[1] and low[1]) together with the barmerge.lookahead_on flag. This combination is the established non-repainting form for higher-timeframe reads: the [1] index requests the value from the prior higher-timeframe bar, and the lookahead flag ensures that value is returned consistently in both historical and real-time evaluation. This pattern does not access future data. It returns the last confirmed higher-timeframe bar's extremes, which are already history at the moment they are read.

[b]How to read the chart[/b]

[list]
[*]A small triangle is plotted at the sweep bar itself: below the bar for bullish sweeps, above the bar for bearish sweeps. This marks the detection event.
[*]A directional grade label is drawn on the next bar (the follow-through bar), with text showing the letter grade and the numeric composite score. The label color shifts on a red-to-green gradient based on the score.
[*]A configurable dashboard panel shows the most recent sweep's direction, each of the six sub-factor scores with gradient cells, the regime-penalty status, the composite score, and the letter grade.
[*]All sub-scores are also output as hidden plots so that they are accessible from the Data Window and may be referenced in alert messages.
[/list]

[b]Inputs[/b]

Inputs are grouped into five sections.

[list]
[*][b]Core Settings[/b]: swing pivot lookback, minimum wick-to-body ratio, ATR length, volume percentile lookback.
[*][b]Filters[/b]: higher-timeframe reference, ADX length and threshold for the regime check, regime-penalty enable toggle.
[*][b]Score Tuning[/b]: a 0 to 1 weight for each of the five positive factors and the regime-penalty magnitude in points.
[*][b]Visual Settings[/b]: panel position, panel size, label cap, marker and label toggles.
[*][b]Any Alert() function call conditions[/b]: per-signal boolean toggles to enable individual alerts.
[/list]

[b]Alerts[/b]

Six alert conditions are provided: A+ Setup, A Setup, B Setup, Bullish Sweep with quality at or above 70, Bearish Sweep with quality at or above 70, and Any Sweep with score at or above 80. Each alert is declared via alertcondition() for native TradingView alert configuration and is also fired programmatically through alert() when its corresponding input toggle is enabled. All programmatic alerts use alert.freq_once_per_bar_close to prevent intrabar re-triggers. The alertcondition() message templates include {{ticker}}, {{interval}}, and {{close}} placeholders for webhook integrations.

[b]How to use this script[/b]

This script is a quality filter for reversal-style entries. It is not a complete trading system.

[list=1]
[*]Identify a discretionary or systematic reversal context — a higher-timeframe level retest, a range extreme, a divergence, or any structure already in your plan.
[*]Wait for a sweep marker to print.
[*]Read the dashboard at bar close on the follow-through bar. Treat B-grade or better as candidate setups. Treat C and Weak as information only.
[*]If the regime-penalty row indicates the sweep is fighting a strong trend, weight the signal toward "pullback rejection inside a continuing trend" rather than "trend reversal."
[*]Position sizing, stop placement, and target selection remain entirely the user's responsibility.
[/list]

[b]Limitations and honest caveats[/b]

[list]
[*]The composite score is a heuristic evidence weighting. It is not a statistically calibrated probability. An A grade means a sweep has more of the listed evidence factors than a C grade. It does not imply a specific likelihood of follow-through.
[*]Pivot detection has inherent right-bar confirmation lag. A swing pivot is only confirmed after the configured right lookback has elapsed.
[*]The higher-timeframe proximity factor uses only the prior higher-timeframe bar's high and low. Other structurally relevant levels — anchored VWAPs, weekly opens, user-marked supply or demand, prior session highs and lows — are not part of this factor.
[*]The regime penalty uses ADX, which is a lagging measure of trend strength and will not flag fast regime shifts immediately.
[*]The grade label is drawn one bar after the sweep bar by design (see factor 5 above). Traders who require the label on the sweep bar itself should be aware that this would mean publishing a score before the follow-through evidence exists.
[*]The script is an indicator, not a strategy. It does not size positions, manage stops, or backtest entries.
[/list]

[b]Disclaimer[/b]

This script is published for informational and educational purposes. It is not investment advice and is not a recommendation to buy or sell any instrument. Past appearance of any pattern, including high-grade sweep setups, does not guarantee future behaviour. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
//@version=6
// =============================================================================
// Liquidity Sweep Quality Score [TradeDots]
// shorttitle: TD-LSQ
//
// Concept: Not every liquidity sweep matters. This indicator detects bullish
// and bearish sweeps (price prints beyond a recent swing pivot, then closes
// back inside) and scores each one on six independent factors:
//   1. Wick rejection strength (wick / body ratio)
//   2. Relative volume vs rolling percentile
//   3. Failed-breakout structure (close back inside prior range)
//   4. Higher-timeframe level proximity
//   5. Follow-through candle confirmation
//   6. Regime penalty (trend-continuation working against the sweep)
//
// Output: a 0-100 composite score plus a letter grade A+/A/B/C/Weak.
// =============================================================================

indicator(title         = "Liquidity Sweep Quality Score [TradeDots]",
          shorttitle    = "TD-LSQ",
          overlay       = true,
          max_labels_count = 500,
          max_lines_count  = 500,
          max_boxes_count  = 500)

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

// ============================ Input group keys ==============================
GROUP_CORE   = "Core Settings"
GROUP_FILTER = "Filters"
GROUP_SCORE  = "Score Tuning"
GROUP_VIS    = "Visual Settings"
GROUP_ALERT  = "Any Alert() function call conditions"

// ================================= INPUTS ===================================
// Core
swing_len       = input.int(10,  "Swing Pivot Lookback", minval = 2, maxval = 50,
                            group = GROUP_CORE,
                            tooltip = "Bars on each side of a pivot used for swing-high/low detection. Larger = stronger but slower swings.")
wick_min_ratio  = input.float(1.5, "Min Wick / Body Ratio", minval = 0.1, step = 0.1,
                              group = GROUP_CORE,
                              tooltip = "Required rejection wick relative to candle body for a sweep to qualify. Higher = stricter.")
atr_len         = input.int(14, "ATR Length", minval = 1, group = GROUP_CORE)
vol_rank_len    = input.int(100, "Volume Rank Lookback", minval = 10,
                            group = GROUP_CORE,
                            tooltip = "Bars used to compute the rolling percentile rank of volume.")

// Filters
htf             = input.timeframe("240", "HTF Level Reference", group = GROUP_FILTER,
                                  tooltip = "Higher timeframe whose prior bar high/low we use as a 'major' level for proximity scoring.")
regime_adx_len  = input.int(14, "Regime ADX Length", minval = 2, group = GROUP_FILTER)
regime_thresh   = input.float(30, "Trend ADX Threshold", group = GROUP_FILTER,
                              tooltip = "Above this ADX the market is considered strongly trending. A sweep against a strong trend gets a regime penalty.")
trend_penalty_on = input.bool(true, "Apply Regime Penalty", group = GROUP_FILTER)

// Score weights
w_wick     = input.float(1.0, "Wick Rejection Weight",  minval = 0, step = 0.1, group = GROUP_SCORE)
w_volume   = input.float(1.0, "Relative Volume Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_failed   = input.float(1.0, "Failed-Break Weight",    minval = 0, step = 0.1, group = GROUP_SCORE)
w_htf      = input.float(1.0, "HTF Proximity Weight",   minval = 0, step = 0.1, group = GROUP_SCORE)
w_follow   = input.float(1.0, "Follow-Through Weight",  minval = 0, step = 0.1, group = GROUP_SCORE)
regime_pen = input.float(30, "Regime Penalty (points)", minval = 0, maxval = 60, step = 5, group = GROUP_SCORE)

// Visuals
show_sweep_marker = input.bool(true,  "Show Sweep Marker",  group = GROUP_VIS)
show_grade_label  = input.bool(true,  "Show Grade Label",   group = GROUP_VIS)
show_dashboard    = input.bool(true,  "Show Dashboard",     group = GROUP_VIS)
panel_pos         = input.string("Bottom Right", "Panel Position", group = GROUP_VIS,
                                 options = ["Hidden", "Top Right", "Bottom Right", "Bottom Left", "Top Left"])
panel_size        = input.string("Normal", "Panel Size", group = GROUP_VIS,
                                 options = ["Tiny", "Small", "Normal", "Large"])
panel_color       = input.color(tdDark, "Panel Background", group = GROUP_VIS)
max_labels_on_chart = input.int(50, "Max Labels", minval = 10, maxval = 500, group = GROUP_VIS)

// Alerts
alert_aplus = input.bool(false, "A+ Setup", group = GROUP_ALERT, inline = "G1")
alert_a     = input.bool(false, "A Setup",  group = GROUP_ALERT, inline = "G1")
alert_b     = input.bool(false, "B Setup",  group = GROUP_ALERT, inline = "G1")
alert_score80 = input.bool(false, "Score > 80", group = GROUP_ALERT, inline = "G2")
alert_bull_only = input.bool(false, "Bullish Sweeps Only", group = GROUP_ALERT, inline = "G2")
alert_bear_only = input.bool(false, "Bearish Sweeps Only", group = GROUP_ALERT, inline = "G2")

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

f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_vol_pct(len_rank) =>
    na(volume) ? na : ta.percentrank(volume, len_rank)

f_clv() =>
    rng = high - low
    rng == 0 ? 50.0 : (close - low) / rng * 100

f_grade(s) =>
    s >= 90 ? "A+" : s >= 80 ? "A" : s >= 70 ? "B" : s >= 60 ? "C" : s >= 50 ? "D" : "Weak"

f_cap_labels(maxN) =>
    while array.size(label.all) > maxN
        label.delete(array.shift(label.all))

f_pos(s) =>
    s == "Top Right"    ? position.top_right    :
      s == "Bottom Right" ? position.bottom_right :
      s == "Bottom Left"  ? position.bottom_left  :
      s == "Top Left"     ? position.top_left     : position.bottom_right

f_sz(s) =>
    s == "Tiny"  ? size.tiny  :
      s == "Small" ? size.small :
      s == "Large" ? size.large : size.normal

// ============================== CORE STATE ==================================
atrv = ta.atr(atr_len)

// Pivot detection — symmetric left/right lookback (Pine confirms pivots
// `swing_len` bars after they actually print, by design).
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

var float last_swing_high = na
var float last_swing_low  = na
if not na(ph)
    last_swing_high := ph
if not na(pl)
    last_swing_low := pl

// HTF prior-bar level reference — anti-repaint idiom: src[1] + lookahead_on
[htf_prev_high, htf_prev_low] = request.security(syminfo.tickerid, htf,
                                                  [high[1], low[1]],
                                                  barmerge.gaps_on,
                                                  barmerge.lookahead_on)

// ADX for regime penalty
[_diplus, _diminus, adx] = ta.dmi(regime_adx_len, regime_adx_len)
trend_up   = ta.ema(close, 50) > ta.ema(close, 200) and adx >= regime_thresh
trend_down = ta.ema(close, 50) < ta.ema(close, 200) and adx >= regime_thresh

// =========================== SWEEP DETECTION ================================
// A bullish sweep prints below the last swing low intrabar but closes back above it.
// REPAINT: confirmed-only — every signal gated by barstate.isconfirmed.
sweep_bull_raw = not na(last_swing_low)  and low  < last_swing_low  and close > last_swing_low
sweep_bear_raw = not na(last_swing_high) and high > last_swing_high and close < last_swing_high

// Body / wick anatomy
body          = math.abs(close - open)
wick_below    = math.min(open, close) - low
wick_above    = high - math.max(open, close)
wick_used     = sweep_bull_raw ? wick_below : sweep_bear_raw ? wick_above : 0.0
wick_to_body  = body == 0 ? 0.0 : wick_used / body
wick_passes   = wick_to_body >= wick_min_ratio

sweep_bull = sweep_bull_raw and wick_passes and barstate.isconfirmed
sweep_bear = sweep_bear_raw and wick_passes and barstate.isconfirmed
is_sweep   = sweep_bull or sweep_bear

// ============================ FACTOR SCORES =================================
// 1. Wick rejection score — how strong the rejection wick is relative to the
//    minimum threshold. Capped at 100 when the wick is 2x the minimum.
wick_score = is_sweep ? f_clamp_100(wick_to_body / wick_min_ratio * 50) : 0.0

// 2. Relative volume score — rolling percentile rank of current bar's volume.
volume_score = is_sweep ? nz(f_vol_pct(vol_rank_len), 50.0) : 0.0

// 3. Failed-break score — close back inside the prior range = full credit.
//    The structural definition of a sweep IS the failed break, so this scores
//    *how decisively* the failed-break printed (close vs the swept pivot).
failed_score = sweep_bull ? f_clamp_100((close - last_swing_low) / atrv * 50) :
               sweep_bear ? f_clamp_100((last_swing_high - close) / atrv * 50) : 0.0

// 4. HTF proximity score — closer to a prior-HTF high/low = higher score.
htf_dist_bull = math.min(math.abs(close - htf_prev_high), math.abs(close - htf_prev_low)) / atrv
htf_dist_bear = math.min(math.abs(close - htf_prev_high), math.abs(close - htf_prev_low)) / atrv
htf_dist      = sweep_bull ? htf_dist_bull : sweep_bear ? htf_dist_bear : na
htf_score     = is_sweep and not na(htf_dist) ? f_clamp_100(100 - htf_dist * 25) : 0.0

// 5. Follow-through score — assessed on the NEXT bar after the sweep. We
//    record `pending_*` flags here; the follow-through is consumed below.
var int    pending_dir         = 0    // +1 = bullish sweep pending follow, -1 = bearish, 0 = none
var float  pending_score_so_far = na
var float  pending_pivot        = na
var int    pending_bar          = na

// 6. Regime penalty — applied AFTER weighted average. Holds the points to
//    subtract if the sweep direction contradicts a strong trend.
regime_penalty_now = trend_penalty_on and is_sweep and
                     ((sweep_bull and trend_down) or (sweep_bear and trend_up)) ?
                     regime_pen : 0.0

// =========================== COMPOSITE SCORE ================================
// Weighted average of the FIVE factors that are knowable at the sweep bar.
// Follow-through is applied on the next bar (see below).
weights_sum = w_wick + w_volume + w_failed + w_htf
raw_weighted = is_sweep ?
               (w_wick   * wick_score   +
                w_volume * volume_score +
                w_failed * failed_score +
                w_htf    * htf_score) / math.max(weights_sum, 0.01)
               : 0.0

// Stash the partial score on the sweep bar; the next bar's follow-through
// candle will finalize the composite.
if sweep_bull
    pending_dir          := 1
    pending_score_so_far := raw_weighted
    pending_pivot        := last_swing_low
    pending_bar          := bar_index
if sweep_bear
    pending_dir          := -1
    pending_score_so_far := raw_weighted
    pending_pivot        := last_swing_high
    pending_bar          := bar_index

// Apply follow-through one bar later.
follow_resolved = pending_dir != 0 and bar_index == pending_bar + 1 and barstate.isconfirmed
follow_score = 0.0
float final_score  = na
final_dir    = 0
if follow_resolved
    follow_ok = pending_dir == 1 ? close > open : close < open
    follow_score := follow_ok ? 100.0 : 0.0
    weights_total = w_wick + w_volume + w_failed + w_htf + w_follow
    combined = (pending_score_so_far * (w_wick + w_volume + w_failed + w_htf) +
                w_follow * follow_score) / math.max(weights_total, 0.01)
    // Regime penalty was recorded at sweep time but applies here against the
    // *prior* bar's regime direction.
    pen = trend_penalty_on and
          ((pending_dir == 1  and trend_down[1]) or
           (pending_dir == -1 and trend_up[1])) ? regime_pen : 0.0
    final_score := f_clamp_100(combined - pen)
    final_dir   := pending_dir
    // clear pending so a stale pivot doesn't double-fire
    pending_dir := 0

grade = na(final_score) ? "" : f_grade(final_score)

// ============================== VISUALS =====================================
// 1. Sweep markers — small triangles at the swept pivot level on the sweep bar.
plotshape(show_sweep_marker and sweep_bull, title = "Bullish Sweep",
          location = location.belowbar, style = shape.triangleup, size = size.tiny,
          color = tdBull)
plotshape(show_sweep_marker and sweep_bear, title = "Bearish Sweep",
          location = location.abovebar, style = shape.triangledown, size = size.tiny,
          color = tdBear)

// 2. Grade label — placed on the follow-through bar so it carries the full score.
if show_grade_label and follow_resolved and not na(final_score)
    label_color = color.from_gradient(final_score, 50, 100, color.new(tdBear, 30), color.new(tdBull, 0))
    label_style = final_dir == 1 ? label.style_label_up : label.style_label_down
    label_yloc  = final_dir == 1 ? yloc.belowbar : yloc.abovebar
    label_text  = final_dir == 1 ? "▲ " + grade + "  " + str.tostring(final_score, "#") :
                                   "▼ " + grade + "  " + str.tostring(final_score, "#")
    label_txt_color = tdWhite
    label.new(bar_index, final_dir == 1 ? low : high,
              text      = label_text,
              yloc      = label_yloc,
              style     = label_style,
              color     = label_color,
              textcolor = label_txt_color,
              size      = size.small)
    f_cap_labels(max_labels_on_chart)

// 3. Scratch plots — keep the score on the chart history for alerts and inspection.
plot(final_score,        title = "Composite Score",   display = display.none)
plot(wick_score,         title = "Wick Score",        display = display.none)
plot(volume_score,       title = "Volume Score",      display = display.none)
plot(failed_score,       title = "Failed-Break Score",display = display.none)
plot(htf_score,          title = "HTF Proximity",     display = display.none)
plot(follow_score,       title = "Follow-Through",    display = display.none)
plot(final_dir,          title = "Direction",         display = display.none)

// 4. Dashboard panel (right side by default).
panel_visible = show_dashboard and panel_pos != "Hidden"
var table panel = table.new(f_pos(panel_pos), columns = 2, rows = 9,
                            bgcolor = color.new(panel_color, 30), border_width = 1)

f_row(row, label_txt, value_txt, score_val) =>
    table.cell(panel, 0, row, label_txt,
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    fill_color = na(score_val) ? color.new(panel_color, 60) :
                 color.new(color.from_gradient(score_val, 0, 100, tdBear, tdBull), 25)
    txt_color = na(score_val) ? tdLight : tdWhite
    table.cell(panel, 1, row, value_txt,
               bgcolor = fill_color, text_color = txt_color,
               text_size = f_sz(panel_size), text_halign = text.align_right)

// Latest sweep memory — so the panel keeps showing the most recent setup.
var float disp_score      = na
var int   disp_dir         = 0
var float disp_wick        = na
var float disp_volume      = na
var float disp_failed      = na
var float disp_htf         = na
var float disp_follow      = na
var bool  disp_regime_pen  = false
var string disp_grade      = ""
if follow_resolved
    disp_score     := final_score
    disp_dir       := final_dir
    disp_wick      := wick_score[1]
    disp_volume    := volume_score[1]
    disp_failed    := failed_score[1]
    disp_htf       := htf_score[1]
    disp_follow    := follow_score
    disp_regime_pen := (final_dir == 1 and trend_down[1]) or (final_dir == -1 and trend_up[1])
    disp_grade     := grade

if panel_visible and barstate.islast
    table.cell(panel, 0, 0, "TD-LSQ • Sweep Quality",
               bgcolor = color.new(panel_color, 0), text_color = tdLight,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 0, disp_dir == 1 ? "BULL" : disp_dir == -1 ? "BEAR" : "—",
               bgcolor = disp_dir == 1 ? color.new(tdBull, 20) :
                         disp_dir == -1 ? color.new(tdBear, 20) :
                         color.new(panel_color, 50),
               text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    f_row(1, "Wick Rejection",   na(disp_wick)  ? "—" : str.tostring(disp_wick, "#"),   disp_wick)
    f_row(2, "Rel. Volume",      na(disp_volume) ? "—" : str.tostring(disp_volume, "#"), disp_volume)
    f_row(3, "Failed Break",     na(disp_failed) ? "—" : str.tostring(disp_failed, "#"), disp_failed)
    f_row(4, "HTF Proximity",    na(disp_htf)    ? "—" : str.tostring(disp_htf, "#"),    disp_htf)
    f_row(5, "Follow-Through",   na(disp_follow) ? "—" : str.tostring(disp_follow, "#"), disp_follow)
    table.cell(panel, 0, 6, "Regime Penalty",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 6, disp_regime_pen ? "Yes (-" + str.tostring(regime_pen, "#") + ")" : "No",
               bgcolor = disp_regime_pen ? color.new(tdOrange, 25) : color.new(panel_color, 50),
               text_color = tdWhite, text_size = f_sz(panel_size), text_halign = text.align_right)
    // Composite score row
    table.cell(panel, 0, 7, "Composite",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    comp_fill = na(disp_score) ? color.new(panel_color, 60) : color.new(color.from_gradient(disp_score, 0, 100, tdBear, tdBull), 15)
    table.cell(panel, 1, 7, na(disp_score) ? "—" : str.tostring(disp_score, "#"), bgcolor = comp_fill, text_color = tdWhite, text_size = f_sz(panel_size), text_halign = text.align_right)
    // Grade row
    table.cell(panel, 0, 8, "Grade",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    grade_fill = disp_grade == "A+" or disp_grade == "A" ? color.new(tdBull, 10) :
                 disp_grade == "B" ? color.new(tdCyan, 25) :
                 disp_grade == "C" ? color.new(tdOrange, 25) :
                 disp_grade == ""  ? color.new(panel_color, 50) :
                                      color.new(tdBear, 25)
    table.cell(panel, 1, 8, disp_grade == "" ? "—" : disp_grade,
               bgcolor = grade_fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)

// ============================== ALERTS ======================================
// Pure conditions — defined once for both alertcondition() and gated alert().
cond_aplus      = follow_resolved and final_score >= 90
cond_a          = follow_resolved and final_score >= 80 and final_score < 90
cond_b          = follow_resolved and final_score >= 70 and final_score < 80
cond_score80    = follow_resolved and final_score >= 80
cond_bull_setup = follow_resolved and final_dir == 1  and final_score >= 70
cond_bear_setup = follow_resolved and final_dir == -1 and final_score >= 70

// alertcondition() — UI discoverability (users can manually attach alerts).
alertcondition(cond_aplus,
               title   = "TD-LSQ A+ Setup",
               message = "TD-LSQ A+ Sweep Setup on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_a,
               title   = "TD-LSQ A Setup",
               message = "TD-LSQ A Sweep Setup on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_b,
               title   = "TD-LSQ B Setup",
               message = "TD-LSQ B Sweep Setup on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_bull_setup,
               title   = "TD-LSQ Bullish Sweep (Quality ≥ 70)",
               message = "TD-LSQ Bullish Sweep on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_bear_setup,
               title   = "TD-LSQ Bearish Sweep (Quality ≥ 70)",
               message = "TD-LSQ Bearish Sweep on {{ticker}} {{interval}} @ {{close}}")

// alert() — programmatic, gated by per-signal toggles, bar-close only.
if alert_aplus and cond_aplus
    alert("🟢 TD-LSQ A+ Sweep • Score " + str.tostring(final_score, "#") +
          " @ " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_a and cond_a
    alert("🟢 TD-LSQ A Sweep • Score " + str.tostring(final_score, "#") +
          " @ " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_b and cond_b
    alert("TD-LSQ B Sweep • Score " + str.tostring(final_score, "#") +
          " @ " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_score80 and cond_score80
    alert("TD-LSQ Score ≥ 80 (" +
          (final_dir == 1 ? "Bull" : "Bear") + ") @ " +
          str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_bull_only and cond_bull_setup
    alert("▲ TD-LSQ Bullish Sweep • Score " + str.tostring(final_score, "#"),
          alert.freq_once_per_bar_close)
if alert_bear_only and cond_bear_setup
    alert("▼ TD-LSQ Bearish Sweep • Score " + str.tostring(final_score, "#"),
          alert.freq_once_per_bar_close)
````

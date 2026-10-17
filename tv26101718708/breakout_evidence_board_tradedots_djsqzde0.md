# Breakout Evidence Board [TradeDots]

- url: https://www.tradingview.com/script/DJSQzde0-Breakout-Evidence-Board-TradeDots/
- type: indicator
- pine_id: PUB;f950e1ffaa8141a4b81b62fbd8f8dcf0
- version: 1.0

## Description

[b]Breakout Evidence Board [TradeDots][/b]

[b]Summary[/b]

This indicator detects Donchian-style breakouts (a close beyond the highest close or lowest close over a user-configured lookback) and scores each breakout from 0 to 100 across seven independent factors of supporting evidence. The output is a composite "Evidence Score" with a tier label of Strong, Valid, Mixed, or Weak. It is intended as a quality filter for continuation entries — traders use it to separate breakouts that occur in supportive context from breakouts that occur on thin volume, late extension, or counter-trend conditions.

[b]What is original here[/b]

Breakout detection from prior-bar Donchian extremes is standard and is already present in many public scripts. The contribution of this script is the seven-factor evidence panel applied at the moment of the breakout. The factors quantify the breakout's pre-conditions (compression), the breakout's immediate character (volume, ATR expansion, close location), its position relative to mean (VWAP distance), and its alignment with higher-timeframe context. The combination — and the transparency of each factor's contribution to the final score — is what differentiates this script. Each factor weight is exposed as an input so the model can be inspected, tuned, or partially disabled.

[b]How it works[/b]

Breakout detection uses the highest close and lowest close over the prior donchian_len bars, indexed by [1] so the breakout level is the previous bar's extreme rather than the current bar's own extreme. A bullish breakout is registered when the current close exceeds the prior-bar highest close; the bearish case is symmetric. To avoid re-firing on every bar that remains above the prior high, only the first breakout (a transition from "not broken" to "broken") is treated as a signal. Optionally, a "Require Compression Before Breakout" filter rejects breakouts that do not follow a mature Bollinger Bandwidth compression — useful in choppy markets. Signal evaluation is gated by barstate.isconfirmed.

When a breakout is detected, the following seven factors are computed.

[b]1. Compression score.[/b] The Bollinger Bandwidth at the prior bar, expressed as a percentile rank over the configured lookback. The score is inverted: tight pre-break (low BBW percentile) yields a high score, while a breakout from already-expanded volatility yields a low score.

[b]2. ATR expansion score.[/b] The current bar's ATR percentile rank. High ATR percentile means the breakout is moving with thrust, not just drifting across the level.

[b]3. Volume score.[/b] The current bar's volume percentile rank.

[b]4. Close-location score.[/b] Where the close sits within the bar's high-low range. For a bullish breakout the score rewards a close near the bar's high; for a bearish breakout, a close near the bar's low. A weak close (in the middle of the range or against direction) indicates indecision.

[b]5. VWAP distance score.[/b] The absolute distance from an anchored VWAP, expressed in ATR units. A breakout that is already extended from VWAP scores lower than a breakout that occurs near the mean. The anchor is user-selectable: Session, Week, or Month.

[b]6. HTF alignment score.[/b] A higher-timeframe trend reference is fetched and the breakout direction is compared against the HTF trend. Aligned breakouts score full credit; neutral HTF scores half; counter-HTF scores zero.

[b]7. Compression-to-expansion confirmation.[/b] A binary factor that earns full credit only when the prior bar was in a mature compression and the current bar shows clear expansion (ATR percentile above a threshold). This captures the classic "coil release" pattern.

The composite is the weighted average of all seven factors. Tier mapping:

[list]
[*]Strong : score 80 or higher
[*]Valid : score 60 to 79
[*]Mixed : score 30 to 59
[*]Weak : below 30
[/list]

[b]Repainting and data integrity[/b]

Signal generation and labels are gated by barstate.isconfirmed. Donchian extremes are indexed by [1] so they refer to the prior bar's high or low, not the current bar's own value. The higher-timeframe trend reference is fetched with request.security() using a prior-bar source together with barmerge.lookahead_on — the standard non-repainting idiom that returns the last confirmed HTF bar's value. This pattern does not access future data.

[b]How to read the chart[/b]

[list]
[*]The Donchian rails (prior-bar highest and lowest closes) are plotted as thin green and red lines so the breakout level is visible.
[*]A small triangle marks the breakout bar (below for bullish, above for bearish).
[*]A directional tier label is placed on the breakout bar, color-graded from red at low scores to green at high scores. Text shows the tier and numeric composite score.
[*]An "Evidence Board" dashboard panel displays each of the seven factors as a row, with gradient cells reflecting that factor's contribution, plus the composite score and tier.
[*]All sub-scores are also output as hidden plots for use in the Data Window and alert messages.
[/list]

[b]Inputs[/b]

Inputs are grouped into five sections.

[list]
[*][b]Core Settings[/b]: Donchian lookback, Bollinger Band length and standard-deviation multiplier, percentile-rank lookback, ATR length.
[*][b]Filters[/b]: HTF trend reference, VWAP anchor (Session / Week / Month), optional "Require Compression Before Breakout" toggle.
[*][b]Score Tuning[/b]: a 0 to 1 weight for each of the seven factors.
[*][b]Visual Settings[/b]: panel position, panel size, label cap, marker toggles.
[*][b]Any Alert() function call conditions[/b]: per-alert boolean toggles.
[/list]

[b]Alerts[/b]

Four alert conditions are provided: Strong Bull Breakout (bullish breakout with score at or above 80), Strong Bear Breakout, Any Breakout with Score ≥ 70, and Any Breakout with Score ≥ 80. Each alert is declared via alertcondition() for the native TradingView alert UI and is fired programmatically through alert() when the corresponding input toggle is enabled. Programmatic alerts use alert.freq_once_per_bar_close. Alert message templates include {{ticker}}, {{interval}}, and {{close}} placeholders.

[b]How to use this script[/b]

This is a continuation filter, not a complete system.

[list=1]
[*]Look for a chart setup where a breakout would be your trade thesis (range break, base break, retest of a prior high, etc.).
[*]Wait for a breakout marker.
[*]Read the Evidence Board panel. A Strong or Valid score with HTF aligned is the highest-conviction case.
[*]A Weak score on a Donchian breakout usually indicates either thin volume, no prior compression, or counter-trend pressure — useful as a "skip this one" signal.
[*]The script does not place orders or define stops; sizing and exits remain the user's responsibility.
[/list]

[b]Limitations and honest caveats[/b]

[list]
[*]The composite is a heuristic evidence weighting, not a probability. A Strong tier does not imply a specific success rate.
[*]Fast news-driven breakouts may print with little prior compression and may receive lower scores than they deserve. The "Require Compression" filter is therefore off by default; users who want it strict can enable it.
[*]The anchored VWAP uses a fixed anchor choice (Session, Week, or Month). It does not support multiple simultaneous VWAPs or user-defined anchor points.
[*]Donchian breakouts on the current chart timeframe may not align with breakouts a user perceives at higher timeframes; consider the HTF alignment factor as a coarse check, not as multi-timeframe structure analysis.
[*]The script does not include any backtesting, position sizing, or order management logic.
[/list]

[b]Disclaimer[/b]

This script is published for informational and educational purposes. It is not investment advice and is not a recommendation to buy or sell any instrument. Past appearance of any pattern, including high-quality breakouts, does not guarantee future behaviour. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=6
// =============================================================================
// Breakout Evidence Board [TradeDots]
// shorttitle: TD-BEB
//
// Concept: Most breakouts fail. This indicator detects Donchian breakouts and
// scores them on seven independent factors of evidence:
//   1. Pre-break compression (Bollinger Bandwidth percentile, inverted)
//   2. ATR expansion (current ATR percentile)
//   3. Relative volume (volume percentile)
//   4. Close location within the breakout bar (top/bottom of range)
//   5. VWAP distance (extension penalty)
//   6. HTF trend alignment
//   7. Compression-then-expansion confirmation
//
// Output: 0-100 composite Evidence Score and a tier label
// (Strong / Valid / Mixed / Weak).
// =============================================================================

indicator(title         = "Breakout Evidence Board [TradeDots]",
          shorttitle    = "TD-BEB",
          overlay       = true,
          max_labels_count = 500,
          max_lines_count  = 500,
          max_boxes_count  = 500)

// ============================ TradeDots palette =============================
color tdBull       = #9cff87
color tdBear       = #f9396a
color tdDark       = #1b1b1b
color tdOrange     = #ff6633
color tdCyan       = #90e0ef
color tdMutedPink  = #ea9ab2
color tdForestGrn  = #1b4332
color tdNeutral    = #0077b6

// ============================ Input group keys ==============================
GROUP_CORE   = "Core Settings"
GROUP_FILTER = "Filters"
GROUP_SCORE  = "Score Tuning"
GROUP_VIS    = "Visual Settings"
GROUP_ALERT  = "Any Alert() function call conditions"

// ================================= INPUTS ===================================
donchian_len   = input.int(20, "Donchian Lookback", minval = 5,
                           group = GROUP_CORE,
                           tooltip = "Bars used to define the breakout level (highest close / lowest close).")
bb_len         = input.int(20, "BB Length", minval = 5, group = GROUP_CORE)
bb_mult        = input.float(2.0, "BB StdDev Multiplier", minval = 0.5, step = 0.1, group = GROUP_CORE)
pct_rank_len   = input.int(100, "Percentile Rank Lookback", minval = 20,
                           group = GROUP_CORE,
                           tooltip = "Lookback used for all percentile ranks (BBW, ATR, volume).")
atr_len        = input.int(14, "ATR Length", minval = 1, group = GROUP_CORE)

htf            = input.timeframe("D", "HTF Trend Reference", group = GROUP_FILTER)
vwap_anchor    = input.string("Session", "VWAP Anchor", options = ["Session", "Week", "Month"],
                              group = GROUP_FILTER)
require_compression = input.bool(false, "Require Compression Before Breakout",
                                 group = GROUP_FILTER,
                                 tooltip = "If on, only signals breakouts that follow a mature BBW compression.")

w_compress = input.float(1.0, "Compression Weight",   minval = 0, step = 0.1, group = GROUP_SCORE)
w_atrp     = input.float(1.0, "ATR Expansion Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_volp     = input.float(1.0, "Volume Weight",        minval = 0, step = 0.1, group = GROUP_SCORE)
w_clv      = input.float(1.0, "Close Location Weight",minval = 0, step = 0.1, group = GROUP_SCORE)
w_vwap     = input.float(1.0, "VWAP Distance Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_htf      = input.float(1.0, "HTF Alignment Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_confirm  = input.float(1.0, "Compression→Expansion Weight", minval = 0, step = 0.1, group = GROUP_SCORE)

show_break_marker = input.bool(true,  "Show Breakout Marker", group = GROUP_VIS)
show_grade_label  = input.bool(true,  "Show Tier Label",      group = GROUP_VIS)
show_dashboard    = input.bool(true,  "Show Evidence Board",  group = GROUP_VIS)
panel_pos         = input.string("Bottom Right", "Panel Position", group = GROUP_VIS,
                                 options = ["Hidden", "Top Right", "Bottom Right", "Bottom Left", "Top Left"])
panel_size        = input.string("Normal", "Panel Size", group = GROUP_VIS,
                                 options = ["Tiny", "Small", "Normal", "Large"])
panel_color       = input.color(tdDark, "Panel Background", group = GROUP_VIS)
max_labels_on_chart = input.int(50, "Max Labels", minval = 10, maxval = 500, group = GROUP_VIS)

alert_strong_bull = input.bool(false, "Strong Bull Breakout", group = GROUP_ALERT, inline = "G1")
alert_strong_bear = input.bool(false, "Strong Bear Breakout", group = GROUP_ALERT, inline = "G1")
alert_score70     = input.bool(false, "Any Breakout, Score ≥ 70", group = GROUP_ALERT, inline = "G2")
alert_score80     = input.bool(false, "Any Breakout, Score ≥ 80", group = GROUP_ALERT, inline = "G2")

// ===================== TradeDots Quant Primitives (inlined) =================
f_pct_rank(src, len) =>
    ta.percentrank(src, len)

f_clamp_100(x) =>
    math.max(0, math.min(100, x))

f_clv() =>
    rng = high - low
    rng == 0 ? 50.0 : (close - low) / rng * 100

f_vol_pct(len_rank) =>
    na(volume) ? na : ta.percentrank(volume, len_rank)

f_tier(score) =>
    score >= 80 ? "Strong" : score >= 60 ? "Valid" : score >= 30 ? "Mixed" : "Weak"

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

// Evidence board value column: gradient runs bear → bull; split text so blacks sit on greener fills only.
f_table_txt_rb_grad(score_val) =>
    na(score_val) ? color.white :
     score_val >= 52.0 ? color.black : color.white
// ============================ CORE COMPUTATIONS =============================
atrv      = ta.atr(atr_len)
atr_pctr  = ta.percentrank(atrv, pct_rank_len)
vol_pctr  = nz(f_vol_pct(pct_rank_len), 50.0)

// Bollinger Bandwidth percentile
basis     = ta.sma(close, bb_len)
dev       = bb_mult * ta.stdev(close, bb_len)
bb_upper  = basis + dev
bb_lower  = basis - dev
bbw       = basis == 0 ? 0.0 : (bb_upper - bb_lower) / basis * 100
bbw_pctr  = ta.percentrank(bbw, pct_rank_len)

// Anchored VWAP (selectable anchor)
anchor_change = vwap_anchor == "Session" ? ta.change(time("1D")) != 0 : vwap_anchor == "Week"    ? ta.change(time("1W")) != 0 : ta.change(time("1M")) != 0
vwap_value = ta.vwap(hlc3, anchor_change)

// HTF trend reference — anti-repaint idiom (src[1] + lookahead_on)
htf_trend_src() => ta.ema(close, 50) > ta.ema(close, 200) ? 1 :
                   ta.ema(close, 50) < ta.ema(close, 200) ? -1 : 0
htf_trend = request.security(syminfo.tickerid, htf, htf_trend_src()[1],
                             barmerge.gaps_on, barmerge.lookahead_on)

// =========================== BREAKOUT DETECTION =============================
// REPAINT: confirmed-only — Donchian uses [1] offset so we compare against the
// previous bar's extreme, not the current bar's own extreme.
prior_high = ta.highest(close, donchian_len)[1]
prior_low  = ta.lowest(close,  donchian_len)[1]

bull_break_raw = close > prior_high
bear_break_raw = close < prior_low

// First-touch breakout — don't re-fire every bar above the prior high.
first_bull_break = bull_break_raw and not bull_break_raw[1]
first_bear_break = bear_break_raw and not bear_break_raw[1]

// Optional compression precondition.
mature_compression = bbw_pctr < 25 and bbw_pctr[3] < 35
compression_ok     = not require_compression or mature_compression[1]

bull_break = first_bull_break and compression_ok and barstate.isconfirmed
bear_break = first_bear_break and compression_ok and barstate.isconfirmed
is_break   = bull_break or bear_break

// ============================ FACTOR SCORES =================================
// 1. Compression score — tight pre-break = high score. We look at bbw_pctr
//    one bar before the break to capture the "compressed" state.
compress_score = is_break ? f_clamp_100(100 - nz(bbw_pctr[1], 50)) : 0.0

// 2. ATR expansion score — high current ATR percentile = breakout has thrust.
atrp_score = is_break ? nz(atr_pctr, 50.0) : 0.0

// 3. Volume percentile.
volp_score = is_break ? vol_pctr : 0.0

// 4. Close location value — for a bullish breakout we want close near the top
//    of the bar; bearish breakout, close near the bottom.
clv_raw    = f_clv()
clv_score  = bull_break ? clv_raw : bear_break ? 100 - clv_raw : 0.0

// 5. VWAP distance — penalize moves that are already extended from VWAP.
vwap_dist_atr = na(vwap_value) ? 0.0 : math.abs(close - vwap_value) / atrv
vwap_score    = is_break ? f_clamp_100(100 - vwap_dist_atr * 25) : 0.0

// 6. HTF alignment — bull breakout with HTF bull trend = 100, counter = 0.
htf_score = bull_break ? (htf_trend ==  1 ? 100.0 : htf_trend ==  0 ? 50.0 : 0.0) : bear_break ? (htf_trend == -1 ? 100.0 : htf_trend ==  0 ? 50.0 : 0.0) : 0.0

// 7. Compression→expansion confirm — was the prior bar in a mature compression
//    AND the current bar in clear expansion?
confirm_score = is_break and mature_compression[1] and atr_pctr > 60 ? 100.0 : 0.0

// =========================== COMPOSITE SCORE ================================
weights_sum = w_compress + w_atrp + w_volp + w_clv + w_vwap + w_htf + w_confirm
raw_weighted = is_break ?
               (w_compress * compress_score +
                w_atrp     * atrp_score    +
                w_volp     * volp_score    +
                w_clv      * clv_score     +
                w_vwap     * vwap_score    +
                w_htf      * htf_score     +
                w_confirm  * confirm_score) / math.max(weights_sum, 0.01)
               : na
score    = na(raw_weighted) ? na : f_clamp_100(raw_weighted)
tier     = na(score) ? "" : f_tier(score)
direction = bull_break ? 1 : bear_break ? -1 : 0

// ============================== VISUALS =====================================
// Plot the Donchian rails so users can see the breakout context.
plot(prior_high, title = "Donchian High", color = color.new(tdBull, 70), linewidth = 1)
plot(prior_low,  title = "Donchian Low",  color = color.new(tdBear, 70), linewidth = 1)

// Breakout marker — small triangle.
plotshape(show_break_marker and bull_break, title = "Bull Breakout",
          location = location.belowbar, style = shape.triangleup, size = size.tiny,
          color = tdBull)
plotshape(show_break_marker and bear_break, title = "Bear Breakout",
          location = location.abovebar, style = shape.triangledown, size = size.tiny,
          color = tdBear)

// Tier label.
if show_grade_label and is_break and not na(score)
    lbl_color = color.from_gradient(score, 30, 100, color.new(tdBear, 0), color.new(tdBull, 0))
    lbl_style = direction == 1 ? label.style_label_up : label.style_label_down
    lbl_yloc  = direction == 1 ? yloc.belowbar : yloc.abovebar
    arrow     = direction == 1 ? "▲" : "▼"
    label.new(bar_index, direction == 1 ? low : high,
              text      = arrow + " " + tier + "  " + str.tostring(score, "#"),
              yloc      = lbl_yloc, style = lbl_style,
              color     = lbl_color, textcolor = color.white,
              size      = size.small)
    f_cap_labels(max_labels_on_chart)

// Hidden scratch plots for alerts / data window.
plot(score,          title = "Composite Score", display = display.none)
plot(compress_score, title = "Compression",     display = display.none)
plot(atrp_score,     title = "ATR Expansion",   display = display.none)
plot(volp_score,     title = "Volume",          display = display.none)
plot(clv_score,      title = "Close Location",  display = display.none)
plot(vwap_score,     title = "VWAP Distance",   display = display.none)
plot(htf_score,      title = "HTF Alignment",   display = display.none)
plot(confirm_score,  title = "Confirm",         display = display.none)
plot(direction,      title = "Direction",       display = display.none)

// Dashboard panel — opaque cells so chart backdrop does not wash out white text.
var table panel = table.new(f_pos(panel_pos), columns = 2, rows = 10,
                            bgcolor = color.new(panel_color, 0), border_width = 1)

f_row(row, label_txt, value_txt, score_val) =>
    table.cell(panel, 0, row, label_txt,
               bgcolor = color.new(panel_color, 0),
               text_color = color.white, text_size = f_sz(panel_size), text_halign = text.align_left)
    fill_color = na(score_val) ? color.new(panel_color, 0) :
                 color.new(color.from_gradient(score_val, 0, 100, tdBear, tdBull), 0)
    val_txt_col = na(score_val) ? color.white : f_table_txt_rb_grad(score_val)
    table.cell(panel, 1, row, value_txt,
               bgcolor = fill_color, text_color = val_txt_col,
               text_size = f_sz(panel_size), text_halign = text.align_right)

f_qual_text(score_val) =>
    na(score_val)    ? "—" :
      score_val >= 70 ? "Strong" :
      score_val >= 40 ? "Avg"    : "Weak"

// Persist most recent breakout state so the panel always reflects the latest.
var float disp_score    = na
var int   disp_dir      = 0
var float disp_compress = na
var float disp_atrp     = na
var float disp_volp     = na
var float disp_clv      = na
var float disp_vwap     = na
var float disp_htf      = na
var float disp_confirm  = na
var string disp_tier    = ""
if is_break
    disp_score    := score
    disp_dir      := direction
    disp_compress := compress_score
    disp_atrp     := atrp_score
    disp_volp     := volp_score
    disp_clv      := clv_score
    disp_vwap     := vwap_score
    disp_htf      := htf_score
    disp_confirm  := confirm_score
    disp_tier     := tier

panel_visible = show_dashboard and panel_pos != "Hidden"
if panel_visible and barstate.islast
    table.cell(panel, 0, 0, "TD-BEB • Evidence Board",
               bgcolor = color.new(panel_color, 0), text_color = color.white,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 0,
               disp_dir == 1 ? "BULL BREAK" : disp_dir == -1 ? "BEAR BREAK" : "—",
               bgcolor = disp_dir == 1 ? color.new(tdBull, 0) :
                         disp_dir == -1 ? color.new(tdBear, 0) :
                         color.new(panel_color, 0),
               text_color = disp_dir == 1 ? color.black : color.white,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    f_row(1, "Compression",   f_qual_text(disp_compress), disp_compress)
    f_row(2, "ATR Expansion", f_qual_text(disp_atrp),     disp_atrp)
    f_row(3, "Volume",        f_qual_text(disp_volp),     disp_volp)
    f_row(4, "Close Loc.",    f_qual_text(disp_clv),      disp_clv)
    f_row(5, "VWAP Distance", f_qual_text(disp_vwap),     disp_vwap)
    f_row(6, "HTF Aligned",   na(disp_htf) ? "—" :
                              disp_htf >= 100 ? "Yes" :
                              disp_htf >= 50  ? "Neutral" : "Counter",
                              disp_htf)
    f_row(7, "Compress→Exp",  na(disp_confirm) ? "—" : disp_confirm >= 100 ? "Yes" : "No",
          disp_confirm)
    // Composite
    table.cell(panel, 0, 8, "Composite",
               bgcolor = color.new(panel_color, 0), text_color = color.white,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    comp_fill = na(disp_score) ? color.new(panel_color, 0) :
                 color.new(color.from_gradient(disp_score, 0, 100, tdBear, tdBull), 0)
    comp_txt = na(disp_score) ? color.white : f_table_txt_rb_grad(disp_score)
    table.cell(panel, 1, 8, na(disp_score) ? "—" : str.tostring(disp_score, "#") + " / 100",
               bgcolor = comp_fill, text_color = comp_txt,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    // Tier
    table.cell(panel, 0, 9, "Tier",
               bgcolor = color.new(panel_color, 0), text_color = color.white,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    tier_fill = disp_tier == "Strong" ? color.new(tdBull, 0) :
                 disp_tier == "Valid"  ? color.new(tdCyan, 0) :
                 disp_tier == "Mixed"  ? color.new(tdOrange, 0) :
                 disp_tier == ""       ? color.new(panel_color, 0) : color.new(tdBear, 0)
    tier_txt_col = disp_tier == "Strong" or disp_tier == "Valid" ? color.black : color.white
    table.cell(panel, 1, 9, disp_tier == "" ? "—" : disp_tier,
               bgcolor = tier_fill, text_color = tier_txt_col,
               text_size = f_sz(panel_size), text_halign = text.align_right)

// ============================== ALERTS ======================================
cond_strong_bull = bull_break and not na(score) and score >= 80
cond_strong_bear = bear_break and not na(score) and score >= 80
cond_score70_any = is_break  and not na(score) and score >= 70
cond_score80_any = is_break  and not na(score) and score >= 80

alertcondition(cond_strong_bull,
               title   = "TD-BEB Strong Bull Breakout",
               message = "TD-BEB Strong Bull Breakout on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_strong_bear,
               title   = "TD-BEB Strong Bear Breakout",
               message = "TD-BEB Strong Bear Breakout on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_score70_any,
               title   = "TD-BEB Breakout Score ≥ 70",
               message = "TD-BEB Breakout Score ≥ 70 on {{ticker}} {{interval}} @ {{close}}")
alertcondition(cond_score80_any,
               title   = "TD-BEB Breakout Score ≥ 80",
               message = "TD-BEB Breakout Score ≥ 80 on {{ticker}} {{interval}} @ {{close}}")

if alert_strong_bull and cond_strong_bull
    alert("🟢 TD-BEB Strong Bull Breakout • Score " + str.tostring(score, "#") +
          " @ " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_strong_bear and cond_strong_bear
    alert("🔴 TD-BEB Strong Bear Breakout • Score " + str.tostring(score, "#") +
          " @ " + str.tostring(close, format.mintick),
          alert.freq_once_per_bar_close)
if alert_score70 and cond_score70_any
    alert("TD-BEB Breakout (" + (direction == 1 ? "Bull" : "Bear") +
          ") • Score " + str.tostring(score, "#"),
          alert.freq_once_per_bar_close)
if alert_score80 and cond_score80_any
    alert("TD-BEB Strong Breakout (" + (direction == 1 ? "Bull" : "Bear") +
          ") • Score " + str.tostring(score, "#"),
          alert.freq_once_per_bar_close)
````

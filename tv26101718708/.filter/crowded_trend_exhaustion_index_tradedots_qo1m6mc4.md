# Crowded Trend Exhaustion Index [TradeDots]

- url: https://www.tradingview.com/script/Qo1m6MC4-Crowded-Trend-Exhaustion-Index-TradeDots/
- type: indicator
- pine_id: PUB;0581a073a1714a01b826bda67b7f3af0
- version: 1.0

## Description

[b]Crowded Trend Exhaustion Index [TradeDots][/b]

[b]Summary[/b]

This indicator measures how statistically crowded the current trade has become and reports the reading on a 0 to 100 scale with four named tiers: Healthy, Late, Crowded, and Climax Risk. It is not a top or bottom caller. The goal is to give traders an explicit picture of how stretched price has become relative to historical context, so they can avoid late entries, tighten stops, or take profit when the reading enters extreme territory.

Eight independent factors are combined into the composite score. The pane shows a histogram of the score plus reference lines at the tier thresholds; the background of the pane is tinted when the reading enters the Crowded or Climax Risk tier; a dashboard summarizes the contributing factors.

[b]What is original here[/b]

Many public indicators measure one dimension of exhaustion (most commonly distance from a moving average, or RSI level). The contribution of this script is the combination of eight diverse factors that together describe trade crowding from different angles: spatial extension (EMA distance, VWAP distance), persistence (consecutive same-direction candles), momentum exhaustion (RSI percentile), participation extreme (volume climax), volatility expansion (ATR percentile), behavioural rejection (failed continuation wicks with hysteresis), and price/momentum divergence. Each factor weight is exposed as an input so users can audit and tune the composite. The script also deliberately treats divergence and failed-wick signals with a multi-bar hysteresis so single-bar prints do not produce one-bar spikes in the score.

[b]How it works[/b]

The trend direction used by the script is the immediate-bar EMA slope. The trend EMA length is configurable (default 50).

The eight factors are computed each bar.

[b]1. EMA distance.[/b] Absolute distance from the trend EMA in ATR units, scaled to 0-100.

[b]2. VWAP distance.[/b] Absolute distance from an anchored VWAP (Session, Week, or Month — user-selectable) in ATR units, scaled.

[b]3. Candle streak.[/b] Number of consecutive same-direction candles aligned with the trend. The counter resets to zero on the first counter-direction bar and the score scales with the streak length.

[b]4. RSI percentile.[/b] RSI is computed and percentile-ranked over the configurable lookback. The percentile is taken on the trend side (uptrend uses RSI percentile directly; downtrend uses 100 minus the percentile) so that extreme readings always indicate crowding [i]in the direction of the trend[/i].

[b]5. Volume climax.[/b] A discrete score: 100 when volume is in the top decile, 60 in the top quartile, 30 above the median, 0 otherwise.

[b]6. ATR percentile.[/b] Current ATR percentile over the lookback.

[b]7. Failed continuation wick.[/b] When the current bar prints a wick against the trend direction that exceeds the body by a factor of two, a five-bar hysteresis counter is set. The score decays linearly to zero over five bars. This prevents one-bar wick noise from spiking the score and then disappearing.

[b]8. Price-momentum divergence.[/b] Price prints a new N-bar extreme but RSI does not. Bearish divergence in an uptrend, or bullish divergence in a downtrend, sets a five-bar hysteresis just like factor 7.

All factors are weighted (user-configurable), averaged, and clamped to 0-100. Tier mapping:

[list]
[*]Healthy : 0 to 40
[*]Late    : 40 to crowded_threshold (default 70)
[*]Crowded : crowded_threshold to extreme_threshold (default 85)
[*]Climax Risk : extreme_threshold to 100
[/list]

[b]Repainting and data integrity[/b]

All factors are computed on confirmed-bar values; alerts are gated by barstate.isconfirmed. No request.security() calls are made — the script operates entirely on the chart timeframe. The hysteresis counters for divergence and failed-wick reset deterministically and do not look forward.

[b]How to read the chart[/b]

[list]
[*]The composite is plotted as a colored histogram in the indicator pane. The color reflects the current tier (green for Healthy, orange for Late, pink for Crowded, red for Climax Risk).
[*]Reference lines mark the tier thresholds.
[*]The pane background is tinted when the reading enters the Crowded or Climax Risk tier.
[*]The dashboard panel shows the current tier, each contributing factor's reading, and the composite score.
[/list]

[b]Inputs[/b]

Inputs are grouped into four sections.

[list]
[*][b]Core Settings[/b]: trend EMA length, ATR length, RSI length, percentile lookback, divergence lookback, VWAP anchor.
[*][b]Score Tuning[/b]: a 0 to N weight for each of the eight factors, the Climax Risk threshold, the Crowded threshold.
[*][b]Visual Settings[/b]: histogram toggle, dashboard toggle, background-tint toggle, panel position and size, panel background color.
[*][b]Any Alert() function call conditions[/b]: per-alert toggles.
[/list]

[b]Alerts[/b]

Four alert conditions are provided:

[list]
[*]Entered Crowded Zone (score crossed the Crowded threshold from below)
[*]Entered Climax Risk Zone (score crossed the Climax Risk threshold from below)
[*]Divergence Detected (a price-momentum divergence triggered this bar)
[*]Exhaustion Cooling (score fell back below the Crowded threshold from above)
[/list]

Each is declared via alertcondition() and is fired programmatically through alert() when the corresponding input toggle is enabled, using alert.freq_once_per_bar_close. Alert messages include {{ticker}} and {{interval}} placeholders.

[b]How to use this script[/b]

This is a profit-taking and late-entry-avoidance tool, not an entry trigger.

[list=1]
[*]Apply on the timeframe where you make trading decisions.
[*]While the score is Healthy or Late, the trend can continue to extend; this is not a fade signal.
[*]When the score enters Crowded or Climax Risk on the trend side, tighten stops on existing trend trades, scale out, or avoid late entries.
[*]The Divergence alert is a secondary signal — it indicates internal momentum disagreement but is not a reversal call on its own.
[*]The Exhaustion Cooling alert can be used to identify the end of a stretched move, which sometimes precedes a fresh trend or a multi-bar consolidation.
[/list]

[b]Limitations and honest caveats[/b]

[list]
[*]"Crowded" does not mean "imminent reversal". Strong trends can stay crowded for extended periods.
[*]The composite is a heuristic, not a probability.
[*]The divergence factor requires that price prints a new N-bar extreme. Divergences that occur without a fresh extreme will not be detected.
[*]The VWAP factor uses a single anchor at a time (Session, Week, or Month). Multiple simultaneous VWAP comparisons are not supported.
[*]The streak counter resets on a single counter-direction candle, which can cause sharp drops in the streak factor that do not necessarily indicate the trend is over.
[*]The script makes no prediction about when or how a stretched trend will end.
[/list]

[b]Disclaimer[/b]

This script is published for informational and educational purposes. It is not investment advice and is not a recommendation to buy or sell any instrument. A high crowding reading is not a signal to reverse; it is a description of statistical extension. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=6
// =============================================================================
// Crowded Trend Exhaustion Index [TradeDots]
// shorttitle: TD-CTX
//
// Concept: This indicator does NOT call the top. It tells you when a trade
// is getting statistically crowded so you can take profit, avoid late entries,
// and wait for pullbacks. A 0-100 score across seven exhaustion factors.
//
// Factors:
//   1. Distance from EMA(50) in ATR units
//   2. Distance from VWAP in ATR units
//   3. Consecutive same-direction candle count
//   4. RSI percentile rank
//   5. Volume climax (volume in top decile)
//   6. ATR percentile
//   7. Failed-continuation wick (wick against trend > body × 2)
//   8. Price–momentum divergence over a lookback
//
// Tier labels (informational, not signals):
//   Healthy 0-40  ·  Late 40-70  ·  Crowded 70-85  ·  Climax Risk 85-100
//
// Direction labels (taken from the EMA slope at the bar):
//   Bullish ▲  uptrend is exhausted  -> longs crowded, watch for pullback down
//   Bearish ▼  downtrend is exhausted -> shorts crowded, watch for pullback up
//   Neutral —  no defined trend
// =============================================================================

indicator(title         = "Crowded Trend Exhaustion Index [TradeDots]",
          shorttitle    = "TD-CTX",
          overlay       = false,
          max_labels_count = 200,
          format        = format.price, precision = 1)

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
color tdViolet     = #7209b7

GROUP_CORE  = "Core Settings"
GROUP_SCORE = "Score Tuning"
GROUP_VIS   = "Visual Settings"
GROUP_ALERT = "Any Alert() function call conditions"

// ================================= INPUTS ===================================
ema_len        = input.int(50,  "Trend EMA Length", group = GROUP_CORE)
atr_len        = input.int(14,  "ATR Length",       group = GROUP_CORE)
rsi_len        = input.int(14,  "RSI Length",       group = GROUP_CORE)
norm_len       = input.int(100, "Percentile Lookback", group = GROUP_CORE)
divergence_len = input.int(20,  "Divergence Lookback", group = GROUP_CORE)
vwap_anchor    = input.string("Session", "VWAP Anchor", options = ["Session", "Week", "Month"],
                              group = GROUP_CORE)

w_ema_dist  = input.float(1.0, "EMA Distance Weight",          minval = 0, step = 0.1, group = GROUP_SCORE)
w_vwap_dist = input.float(1.0, "VWAP Distance Weight",         minval = 0, step = 0.1, group = GROUP_SCORE)
w_streak    = input.float(0.7, "Candle Streak Weight",         minval = 0, step = 0.1, group = GROUP_SCORE)
w_rsi       = input.float(1.0, "RSI Percentile Weight",        minval = 0, step = 0.1, group = GROUP_SCORE)
w_vol_climax = input.float(1.0, "Volume Climax Weight",        minval = 0, step = 0.1, group = GROUP_SCORE)
w_atrp      = input.float(0.7, "ATR Percentile Weight",        minval = 0, step = 0.1, group = GROUP_SCORE)
w_fail_wick = input.float(1.0, "Failed Continuation Wick Weight", minval = 0, step = 0.1, group = GROUP_SCORE)
w_divergence = input.float(1.0, "Price-Momentum Divergence Weight",minval = 0, step = 0.1, group = GROUP_SCORE)

extreme_threshold = input.float(85, "Climax Risk Threshold",
                                 minval = 50, maxval = 99, group = GROUP_SCORE)
crowded_threshold = input.float(70, "Crowded Threshold",
                                 minval = 40, maxval = 95, group = GROUP_SCORE)

show_histogram   = input.bool(true,  "Show Histogram",       group = GROUP_VIS)
show_background  = input.bool(true,  "Tint Pane Background", group = GROUP_VIS)
show_dashboard   = input.bool(true,  "Show Dashboard",       group = GROUP_VIS)
panel_pos        = input.string("Top Right", "Panel Position", group = GROUP_VIS,
                                options = ["Hidden", "Top Right", "Bottom Right", "Bottom Left", "Top Left"])
panel_size       = input.string("Normal", "Panel Size", group = GROUP_VIS,
                                options = ["Tiny", "Small", "Normal", "Large"])
panel_color      = input.color(tdDark, "Panel Background", group = GROUP_VIS)

alert_crowded     = input.bool(false, "Entered Crowded Zone",  group = GROUP_ALERT, inline = "G1")
alert_climax      = input.bool(false, "Entered Climax Zone",   group = GROUP_ALERT, inline = "G1")
alert_divergence  = input.bool(false, "Divergence Detected",   group = GROUP_ALERT, inline = "G2")
alert_cooldown    = input.bool(false, "Exhaustion Cooling",    group = GROUP_ALERT, inline = "G2")

// ===================== TradeDots Quant Primitives (inlined) =================
f_pct_rank(src, len) =>
    ta.percentrank(src, len)

f_clamp_100(x) =>
    math.max(0, math.min(100, x))

f_vol_pct(len_rank) =>
    na(volume) ? na : ta.percentrank(volume, len_rank)

f_pos(s) =>
    s == "Top Right"    ? position.top_right    :
      s == "Bottom Right" ? position.bottom_right :
      s == "Bottom Left"  ? position.bottom_left  :
      s == "Top Left"     ? position.top_left     : position.top_right

f_sz(s) =>
    s == "Tiny"  ? size.tiny  :
      s == "Small" ? size.small :
      s == "Large" ? size.large : size.normal

// ============================ CORE COMPUTATIONS =============================
atrv = ta.atr(atr_len)
ema_t = ta.ema(close, ema_len)

// VWAP with selectable anchor
anchor_change = vwap_anchor == "Session" ? ta.change(time("1D")) != 0 : vwap_anchor == "Week"    ? ta.change(time("1W")) != 0 : ta.change(time("1M")) != 0
vwap_value = ta.vwap(hlc3, anchor_change)

rsi_val   = ta.rsi(close, rsi_len)
vol_pctr  = nz(f_vol_pct(norm_len), 50.0)
atr_pctr  = ta.percentrank(atrv, norm_len)
rsi_pctr  = ta.percentrank(rsi_val, norm_len)

// Trend direction — used to know which side is "the late side."
trend_dir = ema_t > ema_t[1] ? 1 : ema_t < ema_t[1] ? -1 : 0

// Direction context for visuals & alerts. Crowding is always read on the
// trend-following side, so direction == "which side is overextended."
is_bull_trend = trend_dir == 1
is_bear_trend = trend_dir == -1
trend_label   = is_bull_trend ? "Bullish" : is_bear_trend ? "Bearish" : "Neutral"
trend_arrow   = is_bull_trend ? "▲"       : is_bear_trend ? "▼"       : "—"

// =========================== FACTOR COMPUTATIONS ============================
// 1. EMA distance score (0..100 → 100 is most extended).
ema_dist_atr = atrv == 0 ? 0.0 : math.abs(close - ema_t) / atrv
ema_dist_score = f_clamp_100(ema_dist_atr * 25)

// 2. VWAP distance score.
vwap_dist_atr = atrv == 0 or na(vwap_value) ? 0.0 : math.abs(close - vwap_value) / atrv
vwap_dist_score = f_clamp_100(vwap_dist_atr * 25)

// 3. Consecutive same-direction candle streak.
var int streak = 0
streak_inc = close > close[1] and trend_dir == 1 ? 1 :
             close < close[1] and trend_dir == -1 ? 1 : -10
streak := math.max(0, streak + streak_inc)
streak_score = f_clamp_100(streak * 10)

// 4. RSI percentile score — taken on the trend side.
rsi_score = trend_dir == 1 ? rsi_pctr : trend_dir == -1 ? 100 - rsi_pctr : 50.0

// 5. Volume climax score — full credit when volume in top decile.
vol_climax_score = vol_pctr >= 90 ? 100.0 : vol_pctr >= 75 ? 60.0 : vol_pctr >= 50 ? 30.0 : 0.0

// 6. ATR percentile score.
atrp_score = nz(atr_pctr, 50.0)

// 7. Failed continuation wick — for an uptrend, an upper wick > body × 2.
body          = math.abs(close - open)
upper_wick    = high - math.max(open, close)
lower_wick    = math.min(open, close) - low
fail_wick_raw = trend_dir == 1  and upper_wick > body * 2 ? 100.0 : trend_dir == -1 and lower_wick > body * 2 ? 100.0 : 0.0
// Treat with hysteresis — count failure for a few bars.
var int fail_wick_cooldown = 0
if fail_wick_raw == 100
    fail_wick_cooldown := 5
else if fail_wick_cooldown > 0
    fail_wick_cooldown := fail_wick_cooldown - 1
fail_wick_score = fail_wick_cooldown > 0 ? math.min(100.0, fail_wick_cooldown * 25.0) : 0.0

// 8. Price-momentum divergence — price makes a new high but RSI doesn't.
price_new_high = high == ta.highest(high, divergence_len)
price_new_low  = low  == ta.lowest(low,  divergence_len)
rsi_new_high   = rsi_val == ta.highest(rsi_val, divergence_len)
rsi_new_low    = rsi_val == ta.lowest(rsi_val,  divergence_len)
bear_div = price_new_high and not rsi_new_high
bull_div = price_new_low  and not rsi_new_low
divergence_raw = (trend_dir == 1 and bear_div) or (trend_dir == -1 and bull_div) ? 100.0 : 0.0
var int diverg_cooldown = 0
if divergence_raw == 100
    diverg_cooldown := 5
else if diverg_cooldown > 0
    diverg_cooldown := diverg_cooldown - 1
divergence_score = diverg_cooldown > 0 ? math.min(100.0, diverg_cooldown * 25.0) : 0.0

// =========================== COMPOSITE SCORE ================================
w_total = w_ema_dist + w_vwap_dist + w_streak + w_rsi + w_vol_climax +
          w_atrp + w_fail_wick + w_divergence

crowding = f_clamp_100((w_ema_dist  * ema_dist_score  +
                        w_vwap_dist * vwap_dist_score +
                        w_streak    * streak_score    +
                        w_rsi       * rsi_score       +
                        w_vol_climax* vol_climax_score+
                        w_atrp      * atrp_score      +
                        w_fail_wick * fail_wick_score +
                        w_divergence* divergence_score) / math.max(w_total, 0.01))

tier = crowding >= extreme_threshold ? "Climax Risk" :
       crowding >= crowded_threshold ? "Crowded"     :
       crowding >= 40                ? "Late"        : "Healthy"

// ============================== VISUALS =====================================
// Color the histogram by tier AND direction.
//   Bullish exhaustion -> warm gradient (green → orange → pink → red)
//   Bearish exhaustion -> cool gradient (green → cyan → blue → violet)
hist_color = is_bear_trend ?
             (tier == "Climax Risk" ? tdViolet   :
              tier == "Crowded"     ? tdNeutral  :
              tier == "Late"        ? tdCyan     :
                                       tdBull) :
             (tier == "Climax Risk" ? tdBear     :
              tier == "Crowded"     ? tdMutedPink:
              tier == "Late"        ? tdOrange   :
                                       tdBull)

plot(show_histogram ? crowding : na, title = "Crowding Score",
     style = plot.style_columns, color = color.new(hist_color, 30))
plot(crowding, title = "Crowding Line",
     color = color.new(hist_color, 0), linewidth = 1)

// Reference lines.
hline(extreme_threshold, "Climax Risk threshold",
      color = color.new(tdBear, 50), linestyle = hline.style_dashed)
hline(crowded_threshold, "Crowded threshold",
      color = color.new(tdMutedPink, 50), linestyle = hline.style_dashed)
hline(40,                "Late threshold",
      color = color.new(tdOrange, 70), linestyle = hline.style_dotted)
hline(0,                 "Floor",
      color = color.new(tdLight, 80), linestyle = hline.style_solid)

// Pane tint when in extreme tier — colored by trend direction.
climax_tint  = is_bear_trend ? color.new(tdViolet,  92) : color.new(tdBear,      92)
crowded_tint = is_bear_trend ? color.new(tdNeutral, 95) : color.new(tdMutedPink, 95)
bgcolor(show_background and tier == "Climax Risk" ? climax_tint  :
        show_background and tier == "Crowded"     ? crowded_tint : na,
        title = "Tier tint")

// Hidden alert feed.
plot(crowding,           "Crowding (hidden)",  display = display.none)
plot(trend_dir,          "Trend Direction",    display = display.none)
plot(divergence_score,   "Divergence (hidden)",display = display.none)

// =============================== DASHBOARD ==================================
panel_visible = show_dashboard and panel_pos != "Hidden"
var table panel = table.new(f_pos(panel_pos), columns = 2, rows = 9,
                            bgcolor = color.new(panel_color, 30), border_width = 1)

f_row(row, k, v, score_val) =>
    table.cell(panel, 0, row, k,
               text_color = tdLight, text_size = f_sz(panel_size),
               text_halign = text.align_left)
    fill = na(score_val) ? color.new(panel_color, 60) :
           color.new(color.from_gradient(score_val, 0, 100, tdBull, tdBear), 25)
    table.cell(panel, 1, row, v,
               bgcolor = fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)

if panel_visible and barstate.islast
    tier_fill = tier == "Climax Risk" ? (is_bear_trend ? color.new(tdViolet,  15) : color.new(tdBear,      15)) : tier == "Crowded"     ? (is_bear_trend ? color.new(tdNeutral, 25) : color.new(tdMutedPink, 25)) : tier == "Late"        ? color.new(tdOrange, 30) : color.new(tdBull, 25)
    tier_txt = tier == "Healthy" ? tdBullText : tdWhite
    table.cell(panel, 0, 0, "TD-CTX • Exhaustion",
               bgcolor = color.new(panel_color, 0), text_color = tdLight,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 0, trend_arrow + " " + tier,
               bgcolor = tier_fill, text_color = tier_txt,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    // Direction row — bullish vs bearish exhaustion at a glance.
    trend_cell_fill = is_bull_trend ? color.new(tdBull, 25) :
                      is_bear_trend ? color.new(tdNeutral, 25) :
                                       color.new(panel_color, 50)
    trend_cell_text = is_bull_trend ? tdBullText : tdWhite
    table.cell(panel, 0, 1, "Trend",
               text_color = tdLight, text_size = f_sz(panel_size),
               text_halign = text.align_left)
    table.cell(panel, 1, 1, trend_arrow + " " + trend_label,
               bgcolor = trend_cell_fill, text_color = trend_cell_text,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    f_row(2, "EMA Distance",  str.tostring(ema_dist_atr, "#.#") + " ATR", ema_dist_score)
    f_row(3, "VWAP Distance", str.tostring(vwap_dist_atr, "#.#") + " ATR", vwap_dist_score)
    f_row(4, "Streak (bars)", str.tostring(streak), streak_score)
    f_row(5, "RSI Percentile",str.tostring(rsi_score, "#") + "%", rsi_score)
    f_row(6, "Vol Climax",    vol_climax_score >= 100 ? "Yes" : vol_climax_score >= 60 ? "Elev" : "No",
          vol_climax_score)
    f_row(7, "Fail-Wick",     fail_wick_score >= 60 ? "Yes" : "No", fail_wick_score)
    // Composite — gradient end color follows the trend direction.
    crowd_end_color = is_bear_trend ? tdViolet : tdBear
    crowd_fill = color.new(color.from_gradient(crowding, 30, 85, tdBull, crowd_end_color), 15)
    table.cell(panel, 0, 8, "Crowding",
               text_color = tdLight, text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 8, str.tostring(crowding, "#") + " / 100",
               bgcolor = crowd_fill, text_color = tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)

// ============================== ALERTS ======================================
cond_entered_crowded = crowding >= crowded_threshold and crowding[1] < crowded_threshold and barstate.isconfirmed
cond_entered_climax  = crowding >= extreme_threshold and crowding[1] < extreme_threshold and barstate.isconfirmed
cond_divergence_new  = divergence_raw == 100 and barstate.isconfirmed
cond_cooling         = crowding < crowded_threshold and crowding[1] >= crowded_threshold and barstate.isconfirmed

alertcondition(cond_entered_crowded,
               title   = "TD-CTX Entered Crowded",
               message = "TD-CTX Entered Crowded zone on {{ticker}} {{interval}}")
alertcondition(cond_entered_climax,
               title   = "TD-CTX Entered Climax Risk",
               message = "TD-CTX Entered Climax Risk on {{ticker}} {{interval}}")
alertcondition(cond_divergence_new,
               title   = "TD-CTX Divergence Detected",
               message = "TD-CTX Price-Momentum Divergence on {{ticker}} {{interval}}")
alertcondition(cond_cooling,
               title   = "TD-CTX Exhaustion Cooling",
               message = "TD-CTX Crowding cooled below threshold on {{ticker}} {{interval}}")

if alert_crowded and cond_entered_crowded
    alert("TD-CTX " + trend_arrow + " " + trend_label +
          " Crowded zone entered • Score " + str.tostring(crowding, "#"),
          alert.freq_once_per_bar_close)
if alert_climax and cond_entered_climax
    alert("⚠️ TD-CTX " + trend_arrow + " " + trend_label +
          " Climax Risk • Score " + str.tostring(crowding, "#"),
          alert.freq_once_per_bar_close)
if alert_divergence and cond_divergence_new
    alert("TD-CTX " + trend_arrow + " " + trend_label +
          " Price-Momentum Divergence",
          alert.freq_once_per_bar_close)
if alert_cooldown and cond_cooling
    alert("TD-CTX " + trend_arrow + " " + trend_label +
          " Crowding cooled below threshold",
          alert.freq_once_per_bar_close)
````

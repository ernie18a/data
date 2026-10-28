# Participation-Adjusted Momentum [TradeDots]

- url: https://www.tradingview.com/script/upIMu9z5-Participation-Adjusted-Momentum-TradeDots/
- type: indicator
- pine_id: PUB;ca14b8e77c7b402e827c6478635b689f
- version: 1.0

## Description

[b]Participation-Adjusted Momentum [TradeDots][/b]

[b]Summary[/b]

This indicator computes a momentum oscillator that has been [i]adjusted by participation quality[/i]. Raw momentum (standardized rate-of-change) is multiplied by a quality blend derived from volume percentile, close-location alignment within the bar, and range-per-volume efficiency. The intent is to differentiate strong momentum supported by participation from moves that look impressive on price alone but occur on thin volume or wide ranges with little net travel. The histogram is colored by one of five interpretable states (Strong Bull, Strong Bear, Thin, Quiet Accumulation, Noisy) so users see at a glance whether to trust a momentum reading.

[b]What is original here[/b]

Momentum oscillators (rate-of-change, MACD, RSI) and volume oscillators (volume percentile, MFI) are widely available. This script's contribution is the deliberate [i]combination[/i] into a single adjusted reading, plus the five-state classification that maps raw-momentum / participation combinations to labelled regimes. The "Quiet Accumulation" state (low momentum but rising volume percentile) and the "Thin" state (strong momentum but low participation) are specifically called out because they are the most actionable readings — both indicate that the price reading and the order-flow reading disagree, and that disagreement deserves a label.

[b]How it works[/b]

Each bar, the following quantities are computed.

[b]Raw momentum.[/b] Rate-of-change of close over a configurable length, then z-scored (subtract the mean, divide by the standard deviation) over the normalization lookback. The result is approximately bounded but can exceed plus or minus 3 in extreme moves.

[b]EMA slope.[/b] A 50-period EMA's change over a configurable lookback, min-max normalized to 0-100. Used as a secondary directional bias (computed and exposed as a hidden plot, but not directly added to the displayed oscillator).

[b]Volume percentile.[/b] Volume rank over the normalization lookback (typically 100 bars).

[b]Close-location value.[/b] Where the close sits within the bar's high-low range, expressed as a percentage. For an upward-direction reading, a close near the bar's high indicates buyers won the bar; for a downward-direction reading, a close near the bar's low indicates sellers won.

[b]Participation.[/b] Volume percentile (divided by 100) multiplied by direction-aligned close-location value (also normalized to 0-1). Result is in [0, 1]; higher means "good participation".

[b]Range per volume.[/b] Bar range divided by volume. High range per volume means a wide candle moved on thin flow — typical of news spikes, illiquid prints, or false moves. The percentile rank of range-per-volume is inverted (low range-per-volume gives a high "efficiency score") and used as a quality factor.

[b]Quality blend.[/b] A weighted combination: 0.4 * participation + 0.4 * range_efficiency + 0.2. The +0.2 floor ensures that even with zero participation and zero efficiency, the adjusted momentum retains 20% of the raw signal so the oscillator does not flatline completely.

[b]Adjusted momentum[/b] = raw momentum × quality blend.

State classification (mutually exclusive):

[list]
[*][b]Strong Bull[/b]  : raw momentum at or above +threshold [i]and[/i] participation at or above 0.55
[*][b]Strong Bear[/b]  : raw momentum at or below −threshold [i]and[/i] participation at or above 0.55
[*][b]Thin[/b]         : absolute raw momentum at or above threshold [i]and[/i] participation below 0.35 — momentum without volume, a warning state
[*][b]Quiet Accumulation[/b] : absolute raw momentum below the quiet threshold [i]and[/i] volume percentile above the quiet-volume floor — flat price but rising participation
[*][b]Noisy / Low Quality[/b] : the catch-all when none of the above apply
[/list]

The histogram bar color reflects the current state.

[b]Repainting and data integrity[/b]

All factors are computed on confirmed bar values; alerts are gated by barstate.isconfirmed. No request.security() calls are made — the script operates entirely on the chart timeframe.

[b]How to read the chart[/b]

[list]
[*]The primary plot is the adjusted-momentum histogram, colored by state.
[*]A thin overlay line shows the same value with continuous color for easy zero-line reading.
[*]Reference lines at zero and at ±1 standard deviation provide context for how extreme the current reading is.
[*]Hidden plots expose raw momentum, participation, volume percentile, and direction so they are available in the Data Window.
[*]The dashboard panel shows the current state in the header, then numeric readings for raw momentum (in z-units), adjusted momentum, volume percentile, participation, range efficiency, and the quality blend.
[/list]

[b]Inputs[/b]

Inputs are grouped into three sections.

[list]
[*][b]Core Settings[/b]: ROC length, percentile / z-score lookback, EMA slope length, slope lookback bars, strong-momentum z-threshold, quiet-accumulation maximum z, quiet-accumulation minimum volume percentile.
[*][b]Visual Settings[/b]: zero-line toggle, ±1σ band toggle, dashboard toggle, panel position and size, panel background color.
[*][b]Any Alert() function call conditions[/b]: per-alert toggles.
[/list]

[b]Alerts[/b]

Four alert conditions are provided, each firing on the [i]first bar[/i] the state is entered:

[list]
[*]Strong Bull Momentum
[*]Strong Bear Momentum
[*]Quiet Accumulation Detected
[*]Momentum Without Volume (the "Thin" warning state)
[/list]

Each is declared via alertcondition() and is fired programmatically through alert() when the corresponding input toggle is enabled, with alert.freq_once_per_bar_close. Alert messages include {{ticker}} and {{interval}} placeholders.

[b]How to use this script[/b]

This is a confirmation indicator. It does not generate entries on its own.

[list=1]
[*]When considering an entry on price strength alone, check this indicator. A Strong Bull or Strong Bear state confirms that volume and close location support the move.
[*]The "Thin" state is a warning. A breakout that prints during a Thin reading should be treated more cautiously than the same breakout during Strong Bull.
[*]The Quiet Accumulation state can identify periods of base-building before a move and is useful as a "watchlist" signal.
[*]Use alongside a setup-specific indicator for entry timing.
[/list]

[b]Limitations and honest caveats[/b]

[list]
[*]Volume quality varies dramatically between markets. On crypto exchanges, wash-trading and bot-driven order flow can produce misleading volume percentile readings. Apply with awareness.
[*]Z-score normalization requires the lookback to contain a representative variety of states. On instruments with strong regime changes, early-bar z-scores may be unreliable until the lookback fills.
[*]The close-location alignment factor reads single-bar close behavior. On gappy markets or after market closes, the alignment may not reflect intraday order flow.
[*]The script does not signal direction independently; it adjusts and labels momentum that is already present.
[*]The +0.2 floor in the quality blend is a design choice to avoid flat-lining the oscillator. Users who want a strict "zero adjustment when participation is zero" reading can set the participation weights higher and adjust the floor by modifying the source code.
[/list]

[b]Disclaimer[/b]

This script is published for informational and educational purposes. It is not investment advice and is not a recommendation to buy or sell any instrument. Adjusted momentum is a descriptive measure, not a prediction of future price. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=6
// =============================================================================
// Participation-Adjusted Momentum [TradeDots]
// shorttitle: TD-PAM
//
// Concept: Momentum is more trustworthy when participation confirms it.
// A coin or stock can move sharply on thin volume — that move is fragile.
// This oscillator adjusts raw momentum (standardized ROC) by:
//   - Volume percentile rank
//   - Close-location alignment with direction
//   - Range-per-volume efficiency (thicker fills score higher)
//
// State colors:
//   Green   = strong momentum + strong participation
//   Yellow  = momentum without volume (suspicious)
//   Blue    = quiet accumulation (low momo, rising relative volume)
//   Red     = downside momentum + strong participation
//   Gray    = noisy / low-quality
// =============================================================================

indicator(title         = "Participation-Adjusted Momentum [TradeDots]",
          shorttitle    = "TD-PAM",
          overlay       = false,
          max_labels_count = 200,
          format        = format.price, precision = 2)

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

GROUP_CORE  = "Core Settings"
GROUP_VIS   = "Visual Settings"
GROUP_ALERT = "Any Alert() function call conditions"

// ================================= INPUTS ===================================
momo_len      = input.int(14,  "ROC Length",                 group = GROUP_CORE)
norm_len      = input.int(100, "Percentile / Z-Score Lookback", group = GROUP_CORE)
ema_slope_len = input.int(50,  "EMA Slope Length",           group = GROUP_CORE)
ema_slope_bars= input.int(5,   "Slope Lookback (bars)",      group = GROUP_CORE)
strong_z      = input.float(1.0, "Strong-Momo Z-Threshold",
                            minval = 0.1, step = 0.1, group = GROUP_CORE)
quiet_max_z   = input.float(0.5, "Quiet Accumulation: max |z|",
                            minval = 0.1, step = 0.1, group = GROUP_CORE)
quiet_vol_min = input.float(60, "Quiet Accumulation: min Vol Pctile",
                            minval = 30, group = GROUP_CORE)

show_zero     = input.bool(true, "Show Zero Line",        group = GROUP_VIS)
show_bands    = input.bool(true, "Show ±1σ Bands",        group = GROUP_VIS)
show_dashboard = input.bool(true, "Show Dashboard",       group = GROUP_VIS)
panel_pos     = input.string("Top Right", "Panel Position", group = GROUP_VIS,
                             options = ["Hidden", "Top Right", "Bottom Right", "Bottom Left", "Top Left"])
panel_size    = input.string("Normal", "Panel Size", group = GROUP_VIS,
                             options = ["Tiny", "Small", "Normal", "Large"])
panel_color   = input.color(tdDark, "Panel Background", group = GROUP_VIS)

alert_strong_bull = input.bool(false, "Strong Bull Momentum",  group = GROUP_ALERT, inline = "G1")
alert_strong_bear = input.bool(false, "Strong Bear Momentum",  group = GROUP_ALERT, inline = "G1")
alert_quiet       = input.bool(false, "Quiet Accumulation",    group = GROUP_ALERT, inline = "G2")
alert_thin        = input.bool(false, "Momentum Without Volume",group = GROUP_ALERT, inline = "G2")

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

f_vol_pct(len_rank) =>
    na(volume) ? na : ta.percentrank(volume, len_rank)

f_clv() =>
    rng = high - low
    rng == 0 ? 50.0 : (close - low) / rng * 100

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
// Raw momentum — standardized ROC.
roc_raw  = ta.roc(close, momo_len)
raw_momo = f_zscore(roc_raw, norm_len)

// EMA slope normalized (a small directional bias added to raw momentum).
ema_t       = ta.ema(close, ema_slope_len)
ema_slope   = ema_t - ema_t[ema_slope_bars]
ema_slope_n = f_minmax_norm(ema_slope, norm_len)

// Participation = volume percentile × close-location alignment.
vol_pctr = nz(f_vol_pct(norm_len), 50.0)
clv      = f_clv()
direction_now = raw_momo > 0 ? 1 : raw_momo < 0 ? -1 : 0
participation = direction_now == 1  ? (vol_pctr / 100.0) * (clv / 100.0) : direction_now == -1 ? (vol_pctr / 100.0) * ((100 - clv) / 100.0) : (vol_pctr / 100.0) * 0.5

// Range per volume — high range with low volume = thin fills (low quality).
range_per_vol = (high - low) / math.max(volume, 1)
range_eff_pct = ta.percentrank(range_per_vol, norm_len)
range_eff_score = (100.0 - range_eff_pct) / 100.0   // 0..1, higher = thicker fills

// Adjusted momentum.
quality_blend = 0.4 * participation + 0.4 * range_eff_score + 0.2
adjusted_momo = raw_momo * quality_blend

// =========================== STATE CLASSIFICATION ===========================
strong_bull = raw_momo >=  strong_z and participation >= 0.55
strong_bear = raw_momo <= -strong_z and participation >= 0.55
thin_momo   = math.abs(raw_momo) >= strong_z and participation < 0.35
quiet_accum = math.abs(raw_momo) <= quiet_max_z and vol_pctr >= quiet_vol_min
state_label = strong_bull ? "Strong Bull" : strong_bear ? "Strong Bear" : thin_momo   ? "Thin (low participation)" : quiet_accum ? "Quiet Accumulation" : "Noisy / Low Quality"

state_color = strong_bull ? tdBull : strong_bear ? tdBear : thin_momo   ? tdOrange : quiet_accum ? tdNeutral : color.new(tdLight, 50)

// ============================== VISUALS =====================================
// Histogram of adjusted momentum.
plot(adjusted_momo, title = "Adjusted Momentum",
     style = plot.style_columns, color = color.new(state_color, 25))
plot(adjusted_momo, title = "Adjusted Momentum (line)",
     color = state_color, linewidth = 1)

// Optional raw line for comparison.
plot(raw_momo, title = "Raw Momentum (z)",
     color = color.new(tdLight, 70), linewidth = 1, display = display.none)

// Reference lines.
hline(0,  "Zero",       color = color.new(tdLight, 60),
      linestyle = show_zero ? hline.style_solid : hline.style_dotted)
plus_band_color = show_bands ? color.new(tdBull, 70) : na
minus_band_color = show_bands ? color.new(tdBear, 70) : na
hline( 1, "+1σ", color = plus_band_color,  linestyle = hline.style_dashed)
hline(-1, "-1σ", color = minus_band_color, linestyle = hline.style_dashed)

// Hidden alert feeds.
plot(raw_momo,      "Raw Momo (hidden)",     display = display.none)
plot(participation, "Participation",          display = display.none)
plot(vol_pctr,      "Volume Percentile",      display = display.none)
plot(direction_now, "Direction",              display = display.none)

// =============================== DASHBOARD ==================================
panel_visible = show_dashboard and panel_pos != "Hidden"
var table panel = table.new(f_pos(panel_pos), columns = 2, rows = 7,
                            bgcolor = color.new(panel_color, 30), border_width = 1)

f_row(row, k, v, fill, txt_color) =>
    table.cell(panel, 0, row, k,
               text_color = tdLight, text_size = f_sz(panel_size),
               text_halign = text.align_left)
    table.cell(panel, 1, row, v,
               bgcolor = fill, text_color = txt_color,
               text_size = f_sz(panel_size), text_halign = text.align_right)

if panel_visible and barstate.islast
    state_fill = strong_bull ? color.new(tdBull, 15) : strong_bear ? color.new(tdBear, 15) : thin_momo   ? color.new(tdOrange, 25) : quiet_accum ? color.new(tdNeutral, 30) : color.new(panel_color, 50)
    table.cell(panel, 0, 0, "TD-PAM • Participation",
               bgcolor = color.new(panel_color, 0), text_color = tdLight,
               text_size = f_sz(panel_size), text_halign = text.align_left)
    table.cell(panel, 1, 0, state_label,
               bgcolor = state_fill, text_color = strong_bull ? tdBullText : tdWhite,
               text_size = f_sz(panel_size), text_halign = text.align_right)
    f_row(1, "Raw Momo (z)",   str.tostring(raw_momo, "#.##"),
          color.from_gradient(raw_momo, -2, 2, color.new(tdBear, 15), color.new(tdBull, 15)),
          tdWhite)
    f_row(2, "Adjusted Momo",  str.tostring(adjusted_momo, "#.##"),
          color.from_gradient(adjusted_momo, -2, 2, color.new(tdBear, 15), color.new(tdBull, 15)),
          tdWhite)
    f_row(3, "Volume Pct",     str.tostring(vol_pctr, "#") + "%",
          vol_pctr >= 70 ? color.new(tdBull, 25) : vol_pctr >= 40 ? color.new(tdOrange, 30) : color.new(tdBear, 30),
          tdWhite)
    f_row(4, "Participation",  str.tostring(participation, "#.##"),
          participation >= 0.5 ? color.new(tdBull, 25) : color.new(tdOrange, 30),
          tdWhite)
    f_row(5, "Range Efficiency", str.tostring(range_eff_score, "#.##"),
          range_eff_score >= 0.5 ? color.new(tdBull, 25) : color.new(tdBear, 30),
          tdWhite)
    f_row(6, "Quality Blend",  str.tostring(quality_blend, "#.##"),
          quality_blend >= 0.6 ? color.new(tdBull, 25) : color.new(tdOrange, 30),
          tdWhite)

// ============================== ALERTS ======================================
cond_strong_bull = strong_bull and not strong_bull[1] and barstate.isconfirmed
cond_strong_bear = strong_bear and not strong_bear[1] and barstate.isconfirmed
cond_quiet       = quiet_accum and not quiet_accum[1] and barstate.isconfirmed
cond_thin        = thin_momo   and not thin_momo[1]   and barstate.isconfirmed

alertcondition(cond_strong_bull,
               title   = "TD-PAM Strong Bull Momentum",
               message = "TD-PAM Strong Bull Momentum on {{ticker}} {{interval}}")
alertcondition(cond_strong_bear,
               title   = "TD-PAM Strong Bear Momentum",
               message = "TD-PAM Strong Bear Momentum on {{ticker}} {{interval}}")
alertcondition(cond_quiet,
               title   = "TD-PAM Quiet Accumulation",
               message = "TD-PAM Quiet accumulation detected on {{ticker}} {{interval}}")
alertcondition(cond_thin,
               title   = "TD-PAM Momentum Without Volume",
               message = "TD-PAM Momentum without volume (warning) on {{ticker}} {{interval}}")

if alert_strong_bull and cond_strong_bull
    alert("🟢 TD-PAM Strong Bull Momentum • z=" + str.tostring(raw_momo, "#.##"),
          alert.freq_once_per_bar_close)
if alert_strong_bear and cond_strong_bear
    alert("🔴 TD-PAM Strong Bear Momentum • z=" + str.tostring(raw_momo, "#.##"),
          alert.freq_once_per_bar_close)
if alert_quiet and cond_quiet
    alert("TD-PAM Quiet accumulation — vol pct " + str.tostring(vol_pctr, "#"),
          alert.freq_once_per_bar_close)
if alert_thin and cond_thin
    alert("⚠️ TD-PAM Momentum without volume — participation " + str.tostring(participation, "#.##"),
          alert.freq_once_per_bar_close)
````

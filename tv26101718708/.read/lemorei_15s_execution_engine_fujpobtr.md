# Lemorei 15s Execution Engine

- url: https://www.tradingview.com/script/FUJPOBTr-Lemorei-15s-Execution-Engine/
- type: indicator
- pine_id: PUB;772d067400df495492bc2a9e61875eda
- version: 1.0

## Description

Lemorei 15s Execution Engine — VWAP, EMA Momentum & Volume Delta Timing Tool

Lemorei 15s Execution Engine is a discretionary ultra-short-term trading tool designed for [b]15-second charts[/b]. It is built to help traders evaluate immediate execution quality by combining price position, VWAP structure, EMA momentum, volume delta, cumulative volume delta, and relative volume into one fast visual dashboard.

This script is intended for active intraday traders who already have a higher-timeframe trade idea and need a cleaner way to decide whether the current 15-second price action supports entry, patience, or avoidance.

The core idea is simple: [b]VWAP + EMA momentum + positive delta + rising CVD + strong volume = better execution context.[/b]

Key features include:
[list]
[*] 9 EMA and 21 EMA with a visual EMA cloud for short-term momentum alignment
[*] Session VWAP anchored to the trading day
[*] Optional VWAP standard deviation bands to help visualize extension and mean-reversion zones
[*] Volume delta approximation based on candle structure and volume distribution
[*] Cumulative Volume Delta (CVD) to track whether buying or selling pressure is building
[*] Delta-based candle coloring to make aggressive buying/selling pressure easier to see
[*] 5-point execution score based on VWAP position, EMA alignment, EMA direction, delta, and CVD
[*] GO LONG / WAIT / NO SIGNAL / GO SHORT dashboard for fast readouts
[*] Perfect entry markers when all execution conditions align with stronger relative volume
[*] Bull and bear exhaustion markers when price makes new extremes while delta weakens
[*] VWAP distance display to help avoid chasing when price is too extended
[*] Current price line and label for easier visual tracking during fast movement
[*] Optional background highlighting when long or short conditions are active
[/list]

This indicator is designed to support [b]execution timing[/b], not full trade selection. It works best when combined with a broader trading plan, daily chart context, 1-minute setup confirmation, market strength, news awareness, liquidity, and strict risk management.

Suggested use cases:
[list=1]
[*] Timing entries after a higher-timeframe setup is already identified
[*] Confirming whether buyers are actively supporting a move
[*] Avoiding entries when delta or CVD does not confirm price action
[*] Watching VWAP reclaim or VWAP hold behavior on fast charts
[*] Detecting possible exhaustion when price pushes higher or lower with weakening delta
[*] Improving execution discipline during fast momentum trades
[/list]

[i]Important:[/i] This script is for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security. The volume delta and CVD calculations are approximations based on available TradingView bar data and should not be treated as true exchange-level order flow. Always test thoroughly and use this tool together with your own judgment and risk controls.

## Source Code

````pine
// ================================================================
// 15-SEC EXECUTION ENGINE v1
// Core logic: Volume delta + VWAP + EMA momentum = GO/WAIT/NO
// ================================================================

//@version=6
indicator("Lemorei 15s Execution Engine", overlay=true, max_lines_count=10, max_labels_count=5)

grp_ema  = "-- EMAs --"
show_ema  = input.bool(true,  "Show EMAs",       group=grp_ema)
col_ema9  = input.color(color.new(#FFD700, 0),   "9 EMA",      group=grp_ema)
col_ema21 = input.color(color.new(#FF6B35, 0),   "21 EMA",     group=grp_ema)

grp_vwap = "-- VWAP --"
show_vwap  = input.bool(true,  "Show VWAP",       group=grp_vwap)
show_bands = input.bool(true,  "Show VWAP Bands", group=grp_vwap)
band_mult  = input.float(1.0,  "Band width (SD)", group=grp_vwap, minval=0.5, step=0.25)
col_vwap   = input.color(color.new(#00E5FF, 0),   "VWAP color", group=grp_vwap)
col_band   = input.color(color.new(#00E5FF, 75),  "Band color", group=grp_vwap)

grp_delta = "-- Volume Delta --"
show_delta_color = input.bool(true, "Color candles by delta", group=grp_delta)
delta_smooth     = input.int(3,     "Delta smoothing",        group=grp_delta, minval=1, maxval=10)

grp_sig = "-- Signal --"
show_signal = input.bool(true,  "Show GO/WAIT/NO table",  group=grp_sig)
show_bg     = input.bool(true,  "Highlight GO signal",    group=grp_sig)
show_marker = input.bool(true,  "Mark perfect entries",   group=grp_sig)
table_pos   = input.string("Top Right", "Table position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp_sig)

// -- EMAs --
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

plot(show_ema ? ema9  : na, "9 EMA",  col_ema9,  linewidth=1)
plot(show_ema ? ema21 : na, "21 EMA", col_ema21, linewidth=1)

ema_bull    = ema9 >= ema21
fill_top    = plot(show_ema ? ema9  : na, display=display.none)
fill_bottom = plot(show_ema ? ema21 : na, display=display.none)
fill(fill_top, fill_bottom,
     color=ema_bull ? color.new(#FFD700, 90) : color.new(#FF4444, 90),
     title="EMA Cloud")

// -- VWAP anchored to session open --
is_new_day = dayofweek != dayofweek[1] or (hour == 9 and minute == 30 and second < 16)

var float vwap_sum  = 0.0
var float vwap_vol  = 0.0
var float vwap_sum2 = 0.0

if is_new_day
    vwap_sum  := 0.0
    vwap_vol  := 0.0
    vwap_sum2 := 0.0

typical    = (high + low + close) / 3
vwap_sum  += typical * volume
vwap_vol  += volume
vwap_sum2 += typical * typical * volume

session_vwap = vwap_sum  / vwap_vol
vwap_var     = vwap_sum2 / vwap_vol - session_vwap * session_vwap
vwap_sd      = vwap_var  > 0 ? math.sqrt(vwap_var) : 0.0

upper_band = session_vwap + band_mult * vwap_sd
lower_band = session_vwap - band_mult * vwap_sd

plot(show_vwap  ? session_vwap : na, "VWAP",      col_vwap, linewidth=2)
plot(show_bands ? upper_band   : na, "VWAP +1SD", col_band, linewidth=1)
plot(show_bands ? lower_band   : na, "VWAP -1SD", col_band, linewidth=1)

v_top = plot(show_bands ? upper_band : na, display=display.none)
v_bot = plot(show_bands ? lower_band : na, display=display.none)
fill(v_top, v_bot, color=color.new(#00E5FF, 96), title="VWAP Band Fill")

// -- Volume Delta --
bar_range    = high - low
buy_vol      = bar_range > 0 ? volume * (close - low)  / bar_range : volume * 0.5
sell_vol     = bar_range > 0 ? volume * (high - close) / bar_range : volume * 0.5
bar_delta    = buy_vol - sell_vol
smooth_delta = ta.ema(bar_delta, delta_smooth)

var float cvd = 0.0
if is_new_day
    cvd := 0.0
cvd += bar_delta

cvd_rising  = cvd > cvd[5]
cvd_falling = cvd < cvd[5]

// -- Volume --
vol_avg   = ta.sma(volume, 20)
vol_ratio = vol_avg > 0 ? volume / vol_avg : 1.0

// -- Candle coloring by delta --
delta_pos  = smooth_delta >= 0
vol_strong = vol_ratio >= 1.5
vol_medium = vol_ratio >= 0.8

candle_col = delta_pos and vol_strong      ? color.new(#00E676, 0)  :
             delta_pos and vol_medium       ? color.new(#00E676, 35) :
             delta_pos                      ? color.new(#00E676, 65) :
             not delta_pos and vol_strong   ? color.new(#FF1744, 0)  :
             not delta_pos and vol_medium   ? color.new(#FF1744, 35) :
                                              color.new(#FF1744, 65)

barcolor(show_delta_color ? candle_col : na, title="Delta candle color")

// -- Entry score (0-5) --
score_vwap    = close > session_vwap ? 1 : 0
score_ema_pos = ema9  > ema21        ? 1 : 0
score_ema_dir = ema9  > ema9[3]      ? 1 : 0
score_delta   = smooth_delta > 0     ? 1 : 0
score_cvd     = cvd_rising           ? 1 : 0

entry_score = score_vwap + score_ema_pos + score_ema_dir + score_delta + score_cvd
short_score = (1-score_vwap) + (1-score_ema_pos) + (1-score_ema_dir) + (1-score_delta) + (1-score_cvd)

long_go  = entry_score >= 4
long_ok  = entry_score == 3
short_go = short_score >= 4

// -- Divergence (strict: 12-bar lookback, delta must be 40% weaker than recent peak) --
div_lookback   = 12
delta_peak_abs = ta.highest(math.abs(smooth_delta), div_lookback)
delta_weak     = delta_peak_abs > 0 and math.abs(smooth_delta) < delta_peak_abs * 0.6

bull_div = high >= ta.highest(high, div_lookback) and smooth_delta > 0 and delta_weak and smooth_delta < smooth_delta[3]
bear_div = low  <= ta.lowest(low,  div_lookback)  and smooth_delta < 0 and delta_weak and smooth_delta > smooth_delta[3]

plotshape(bull_div, "Bull exhaustion", shape.xcross, location.abovebar, color.new(#FF9800, 0), size=size.small)
plotshape(bear_div, "Bear exhaustion", shape.xcross, location.belowbar, color.new(#FF9800, 0), size=size.small)

// -- Perfect entry markers --
perfect_long  = entry_score == 5 and vol_ratio >= 1.3
perfect_short = short_score == 5 and vol_ratio >= 1.3

plotshape(show_marker and perfect_long,  "Perfect long",  shape.triangleup,   location.belowbar, color.new(#00E676, 0), size=size.small)
plotshape(show_marker and perfect_short, "Perfect short", shape.triangledown, location.abovebar, color.new(#FF1744, 0), size=size.small)

// -- Background highlight --
bg_col = show_bg and long_go ? color.new(#00E676, 95) : show_bg and short_go ? color.new(#FF1744, 95) : na
bgcolor(bg_col, title="Signal background")

// -- Table --
tpos = switch table_pos
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

var table t = table.new(tpos, 2, 7,
     bgcolor=color.new(#080814, 0), border_color=color.new(#333355, 0),
     border_width=1, frame_color=color.new(#4444AA, 0), frame_width=1)

C_GO      = color.new(#00E676, 0)
C_WAIT    = color.new(#FF9800, 0)
C_NO      = color.new(#FF1744, 0)
C_BG_GO   = color.new(#003318, 0)
C_BG_WAIT = color.new(#331A00, 0)
C_BG_NO   = color.new(#330000, 0)
C_BG_ROW  = color.new(#0A0A18, 0)
C_BG_ALT  = color.new(#10101E, 0)
C_LBL     = color.new(#7777AA, 0)
C_WHT     = color.new(#FFFFFF, 0)
C_GLD     = color.new(#FFD700, 0)

if show_signal and barstate.islast
    sig_txt = long_go  ? "GO LONG"  : short_go ? "GO SHORT" : long_ok ? "WAIT" : "NO SIGNAL"
    sig_col = long_go  ? C_GO  : short_go ? C_NO  : long_ok ? C_WAIT : C_LBL
    sig_bg  = long_go  ? C_BG_GO : short_go ? C_BG_NO : long_ok ? C_BG_WAIT : C_BG_ROW

    table.cell(t, 0, 0, "SIGNAL", text_color=C_LBL,  text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_left)
    table.cell(t, 1, 0, sig_txt,  text_color=sig_col, text_size=size.large,  bgcolor=sig_bg,   text_halign=text.align_center)

    score_col = entry_score >= 4 ? C_GO : entry_score >= 3 ? C_WAIT : C_NO
    table.cell(t, 0, 1, "Score", text_color=C_LBL, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(entry_score) + " / 5", text_color=score_col, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_right)

    vwap_txt = close > session_vwap ? "Above VWAP" : "Below VWAP"
    vwap_col = close > session_vwap ? C_GO : C_NO
    table.cell(t, 0, 2, "VWAP",    text_color=C_LBL,  text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_left)
    table.cell(t, 1, 2, vwap_txt,  text_color=vwap_col, text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_right)

    d_sign = bar_delta >= 0 ? "+" : ""
    d_col  = bar_delta >= 0 ? C_GO : C_NO
    d_val  = str.tostring(math.round(bar_delta / 1000, 1)) + "K"
    table.cell(t, 0, 3, "Delta", text_color=C_LBL, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_left)
    table.cell(t, 1, 3, d_sign + d_val, text_color=d_col, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_right)

    cvd_txt = cvd_rising ? "Rising" : cvd_falling ? "Falling" : "Flat"
    cvd_col = cvd_rising ? C_GO : cvd_falling ? C_NO : C_WAIT
    table.cell(t, 0, 4, "CVD",    text_color=C_LBL,  text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_left)
    table.cell(t, 1, 4, cvd_txt,  text_color=cvd_col, text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_right)

    vol_col = vol_ratio >= 2.0 ? C_GLD : vol_ratio >= 1.3 ? C_GO : vol_ratio <= 0.5 ? C_LBL : C_WHT
    table.cell(t, 0, 5, "Volume", text_color=C_LBL, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_left)
    table.cell(t, 1, 5, str.tostring(math.round(vol_ratio, 2)) + "x vol", text_color=vol_col, text_size=size.normal, bgcolor=C_BG_ALT, text_halign=text.align_right)

    vd_pct  = session_vwap > 0 ? (close - session_vwap) / session_vwap * 100 : 0.0
    vd_sign = vd_pct >= 0 ? "+" : ""
    vd_col  = math.abs(vd_pct) >= 0.5 ? (vd_pct > 0 ? C_GO : C_NO) : math.abs(vd_pct) >= 0.2 ? C_WAIT : C_WHT
    table.cell(t, 0, 6, "Dist VWAP", text_color=C_LBL, text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_left)
    table.cell(t, 1, 6, vd_sign + str.tostring(vd_pct, "#.##") + "%", text_color=vd_col, text_size=size.normal, bgcolor=C_BG_ROW, text_halign=text.align_right)

// -- Current Price Line --
grp_price = "-- Current Price --"
show_price_line  = input.bool(true,  "Show current price line", group=grp_price)
col_price_line   = input.color(color.new(#FF69B4, 0), "Line color",  group=grp_price)
col_price_label  = input.color(color.new(#FF69B4, 0), "Label color", group=grp_price)
price_line_width = input.int(3, "Line width", minval=1, maxval=4, group=grp_price)

var line  price_ln  = na
var label price_lbl = na

if show_price_line and barstate.islast
    // remove previous
    line.delete(price_ln)
    label.delete(price_lbl)

    price_ln := line.new(
         x1    = bar_index - 80,
         y1    = close,
         x2    = bar_index,
         y2    = close,
         color = col_price_line,
         width = price_line_width,
         style = line.style_solid,
         extend = extend.right)

    price_lbl := label.new(
         x         = bar_index,
         y         = close,
         text      = " " + str.format("{0,number,0.00}", close) + " ",
         color     = col_price_line,
         textcolor = color.black,
         style     = label.style_label_left,
         size      = size.normal)
````

# Trinity Signal v3.3

- url: https://www.tradingview.com/script/ccynpA59-Trinity-Signal-v3-3/
- type: indicator
- pine_id: PUB;0d6a144e6a124c5e98c5abc7e14b4a73
- version: 1.0

## Description

Trinity indicator helps with buying and reviewing charts

## Source Code

````pine
// ═══════════════════════════════════════════════════════════
// TRINITY SIGNAL v3.3
// Built for Jermaine Parris | Trinity Prince
// QQQ 0DTE Options Trading
// Works on 1min, 5min, AND 15min charts
// Pine Script v6
// UPDATED: Dashboard larger + moved to bottom right
// ═══════════════════════════════════════════════════════════

//@version=6
indicator("Trinity Signal v3.3", shorttitle="TRINITY v3.3", overlay=true, max_bars_back=1000, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────

grp_ma = "Moving Averages"
sma_fast_len = input.int(10,  "SMA Fast",  group=grp_ma)
sma_slow_len = input.int(50,  "SMA Slow",  group=grp_ma)
ema_fast_len = input.int(9,   "EMA Fast",  group=grp_ma)
ema_slow_len = input.int(21,  "EMA Slow",  group=grp_ma)

grp_sig = "Signal Settings"
min_score       = input.int(3,     "Min Conditions (3-5)",           minval=3, maxval=5, group=grp_sig)
signal_cooldown = input.int(3,     "Bars Between Signals",           minval=1, maxval=20, group=grp_sig)
use_ema_cross   = input.bool(false,"Require EMA Cross (15min only)", group=grp_sig)
use_momentum    = input.bool(true, "Use Momentum Filter",            group=grp_sig)

grp_rsi = "RSI"
rsi_len     = input.int(14,  "RSI Length",   group=grp_rsi)
rsi_bull_lo = input.int(45,  "RSI Bull Min", group=grp_rsi)
rsi_bull_hi = input.int(72,  "RSI Bull Max", group=grp_rsi)
rsi_bear_lo = input.int(28,  "RSI Bear Min", group=grp_rsi)
rsi_bear_hi = input.int(55,  "RSI Bear Max", group=grp_rsi)

grp_vol = "Volume"
vol_len  = input.int(20,    "Volume MA Length",  group=grp_vol)
vol_mult = input.float(1.1, "Volume Multiplier", group=grp_vol)

grp_bb = "Bollinger Bands"
bb_len  = input.int(20,    "BB Length",     group=grp_bb)
bb_mult = input.float(2.0, "BB Multiplier", group=grp_bb)
show_bb = input.bool(false,"Show BB Lines", group=grp_bb)

grp_sr = "Support and Resistance"
show_sr      = input.bool(true,  "Show S/R Zones",         group=grp_sr)
sr_left      = input.int(12,     "Pivot Left Bars",         group=grp_sr)
sr_right     = input.int(12,     "Pivot Right Bars",        group=grp_sr)
sr_zone_pct  = input.float(0.05, "Zone Width Percent",      group=grp_sr)
max_zones    = input.int(3,      "Max Zones Each Side",     minval=1, maxval=5, group=grp_sr)
extend_right = input.int(75,     "Extend Zones Right bars", group=grp_sr)
show_sr_lbl  = input.bool(true,  "Show Zone Labels",        group=grp_sr)

grp_kl = "Key Levels"
show_vwap    = input.bool(true, "Show VWAP",              group=grp_kl)
show_pdh_pdl = input.bool(true, "Show Prev Day High Low", group=grp_kl)
show_rounds  = input.bool(true, "Show Round Numbers",     group=grp_kl)
round_step   = input.int(5,     "Round Number Interval",  group=grp_kl)
show_tdhl    = input.bool(true, "Show Today High Low",    group=grp_kl)

grp_disp = "Display"
show_signals = input.bool(true,  "Show Buy Sell Signals", group=grp_disp)
show_trim    = input.bool(true,  "Show Trim Signals",     group=grp_disp)
show_trail   = input.bool(true,  "Show Trail Dots",       group=grp_disp)
show_near    = input.bool(true,  "Show Near Level Dot",   group=grp_disp)
show_dash    = input.bool(true,  "Show Dashboard",        group=grp_disp)
show_ma      = input.bool(true,  "Show Moving Averages",  group=grp_disp)
color_bars   = input.bool(true,  "Color Candles",         group=grp_disp)
show_bg      = input.bool(false, "Show Background Color", group=grp_disp)

grp_col = "Colors"
bull_col = input.color(color.new(#00ff88, 0),  "Bull",            group=grp_col)
bear_col = input.color(color.new(#ff3366, 0),  "Bear",            group=grp_col)
trim_col = input.color(color.new(#ffaa00, 0),  "Trim",            group=grp_col)
vwap_col = input.color(color.new(#ffff00, 0),  "VWAP",            group=grp_col)
res_col  = input.color(color.new(#ff3366, 78), "Resistance Zone", group=grp_col)
sup_col  = input.color(color.new(#00ff88, 78), "Support Zone",    group=grp_col)

// ─────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────

sma_fast = ta.sma(close, sma_fast_len)
sma_slow = ta.sma(close, sma_slow_len)
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)

vwap_val = ta.vwap(hlc3)

rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = rsi_val >= rsi_bull_lo and rsi_val <= rsi_bull_hi
rsi_bear = rsi_val >= rsi_bear_lo and rsi_val <= rsi_bear_hi
rsi_ob   = rsi_val > 72
rsi_os   = rsi_val < 28

vol_ma   = ta.sma(volume, vol_len)
high_vol = volume >= vol_ma * vol_mult

bb_mid   = ta.sma(close, bb_len)
bb_std   = ta.stdev(close, bb_len)
bb_upper = bb_mid + bb_mult * bb_std
bb_lower = bb_mid - bb_mult * bb_std

mom5     = ta.mom(close, 5)
mom3     = ta.mom(close, 3)
mom_bull = mom5 > 0 and mom3 > 0
mom_bear = mom5 < 0 and mom3 < 0

ema_x_up   = ta.crossover(ema_fast, ema_slow)
ema_x_down = ta.crossunder(ema_fast, ema_slow)
ema_bull   = ema_fast > ema_slow
ema_bear   = ema_fast < ema_slow

sma_bull = close > sma_fast and sma_fast > sma_slow
sma_bear = close < sma_fast and sma_fast < sma_slow

// ─────────────────────────────────────────
// SCORING
// ─────────────────────────────────────────

bc1 = close > vwap_val ? 1 : 0
bc2 = ema_bull         ? 1 : 0
bc3 = rsi_bull         ? 1 : 0
bc4 = high_vol         ? 1 : 0
bc5 = sma_bull         ? 1 : 0
bull_score = bc1 + bc2 + bc3 + bc4 + bc5

rc1 = close < vwap_val ? 1 : 0
rc2 = ema_bear         ? 1 : 0
rc3 = rsi_bear         ? 1 : 0
rc4 = high_vol         ? 1 : 0
rc5 = sma_bear         ? 1 : 0
bear_score = rc1 + rc2 + rc3 + rc4 + rc5

bull_mom_ok = use_momentum ? mom_bull : true
bear_mom_ok = use_momentum ? mom_bear : true

raw_bull = bull_score >= min_score and bull_mom_ok
raw_bear = bear_score >= min_score and bear_mom_ok

trigger_bull = use_ema_cross ? (ema_x_up   and bull_score >= min_score) : raw_bull
trigger_bear = use_ema_cross ? (ema_x_down and bear_score >= min_score) : raw_bear

// ─────────────────────────────────────────
// COOLDOWN
// ─────────────────────────────────────────

var int last_bull_bar = 0
var int last_bear_bar = 0

bull_ready = (bar_index - last_bull_bar) >= signal_cooldown
bear_ready = (bar_index - last_bear_bar) >= signal_cooldown

bull_signal = trigger_bull and bull_ready and not (trigger_bull[1] and bull_ready[1])
bear_signal = trigger_bear and bear_ready and not (trigger_bear[1] and bear_ready[1])

if bull_signal
    last_bull_bar := bar_index
if bear_signal
    last_bear_bar := bar_index

var int last_trim_bar = 0
trim_ready     = (bar_index - last_trim_bar) >= 8
raw_trim_long  = raw_bull and (rsi_ob or close >= bb_upper * 0.999)
raw_trim_short = raw_bear and (rsi_os or close <= bb_lower * 1.001)
trim_long      = show_trim and raw_trim_long  and trim_ready
trim_short     = show_trim and raw_trim_short and trim_ready

if trim_long or trim_short
    last_trim_bar := bar_index

strong_bull = ema_x_up   and bull_score >= 4
strong_bear = ema_x_down and bear_score >= 4

// ─────────────────────────────────────────
// KEY LEVELS
// ─────────────────────────────────────────

var float pdh = na
var float pdl = na
var float pdc = na
var float tdh = na
var float tdl = na

new_day = ta.change(time("D")) != 0
if new_day
    pdh := high[1]
    pdl := low[1]
    pdc := close[1]
    tdh := high
    tdl := low
else
    tdh := math.max(nz(tdh, high), high)
    tdl := math.min(nz(tdl, low),  low)

round_r1 = math.ceil(close  / round_step) * round_step
round_r2 = round_r1 + round_step
round_s1 = math.floor(close / round_step) * round_step
round_s2 = round_s1 - round_step

near_pdh   = not na(pdh) and math.abs(close - pdh) / close < 0.0015
near_pdl   = not na(pdl) and math.abs(close - pdl) / close < 0.0015
near_round = math.abs(close - round_r1) / close < 0.001 or math.abs(close - round_s1) / close < 0.001
near_vwap  = math.abs(close - vwap_val)  / close < 0.001
near_any   = near_pdh or near_pdl or near_round or near_vwap

// ─────────────────────────────────────────
// S/R BOXES
// ─────────────────────────────────────────

pivot_hi = ta.pivothigh(high, sr_left, sr_right)
pivot_lo = ta.pivotlow(low,  sr_left, sr_right)

var float[] res_arr  = array.new_float(0)
var float[] sup_arr  = array.new_float(0)
var int[]   res_bars = array.new_int(0)
var int[]   sup_bars = array.new_int(0)

if not na(pivot_hi)
    array.unshift(res_arr,  pivot_hi)
    array.unshift(res_bars, bar_index - sr_right)
    if array.size(res_arr) > max_zones * 3
        array.pop(res_arr)
        array.pop(res_bars)

if not na(pivot_lo)
    array.unshift(sup_arr,  pivot_lo)
    array.unshift(sup_bars, bar_index - sr_right)
    if array.size(sup_arr) > max_zones * 3
        array.pop(sup_arr)
        array.pop(sup_bars)

if show_sr and barstate.islast
    drawn_res = 0
    if array.size(res_arr) > 0
        for i = 0 to array.size(res_arr) - 1
            if drawn_res >= max_zones
                break
            lvl  = array.get(res_arr,  i)
            bbar = array.get(res_bars, i)
            if lvl > close
                top_z = lvl + lvl * (sr_zone_pct / 100)
                bot_z = lvl - lvl * (sr_zone_pct / 100)
                box.new(bbar, top_z, bar_index + extend_right, bot_z, bgcolor=res_col, border_color=color.new(#ff3366, 25), border_width=1)
                if show_sr_lbl
                    label.new(bar_index + extend_right, lvl, "R" + str.tostring(drawn_res + 1) + "  $" + str.tostring(math.round(lvl, 2)), color=color.new(#ff3366, 40), textcolor=color.white, size=size.small, style=label.style_label_left)
                drawn_res += 1

    drawn_sup = 0
    if array.size(sup_arr) > 0
        for i = 0 to array.size(sup_arr) - 1
            if drawn_sup >= max_zones
                break
            lvl  = array.get(sup_arr,  i)
            bbar = array.get(sup_bars, i)
            if lvl < close
                top_z = lvl + lvl * (sr_zone_pct / 100)
                bot_z = lvl - lvl * (sr_zone_pct / 100)
                box.new(bbar, top_z, bar_index + extend_right, bot_z, bgcolor=sup_col, border_color=color.new(#00ff88, 25), border_width=1)
                if show_sr_lbl
                    label.new(bar_index + extend_right, lvl, "S" + str.tostring(drawn_sup + 1) + "  $" + str.tostring(math.round(lvl, 2)), color=color.new(#00ff88, 40), textcolor=color.white, size=size.small, style=label.style_label_left)
                drawn_sup += 1

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────

plot(show_ma ? sma_fast : na, "SMA Fast", color=color.new(color.blue,   0), linewidth=1)
plot(show_ma ? sma_slow : na, "SMA Slow", color=color.new(color.red,    0), linewidth=1)
plot(show_ma ? ema_fast : na, "EMA Fast", color=color.new(color.lime,   0), linewidth=1)
plot(show_ma ? ema_slow : na, "EMA Slow", color=color.new(color.orange, 0), linewidth=1)
plot(show_vwap ? vwap_val : na, "VWAP",   color=vwap_col, linewidth=2)

plot(show_bb ? bb_upper : na, "BB Upper", color=color.new(color.blue, 60), linewidth=1)
plot(show_bb ? bb_lower : na, "BB Lower", color=color.new(color.blue, 60), linewidth=1)
plot(show_bb ? bb_mid   : na, "BB Mid",   color=color.new(color.blue, 80), linewidth=1)

plot(show_pdh_pdl ? pdh : na, "PDH", color=color.new(#ff6666, 25), linewidth=2, style=plot.style_stepline)
plot(show_pdh_pdl ? pdl : na, "PDL", color=color.new(#66ff99, 25), linewidth=2, style=plot.style_stepline)
plot(show_pdh_pdl ? pdc : na, "PDC", color=color.new(color.gray, 55), linewidth=1, style=plot.style_stepline)
plot(show_tdhl ? tdh : na, "TDH", color=color.new(color.orange, 55), linewidth=1, style=plot.style_stepline)
plot(show_tdhl ? tdl : na, "TDL", color=color.new(color.aqua,   55), linewidth=1, style=plot.style_stepline)

plot(show_rounds ? round_r1 : na, "Round R1", color=color.new(color.white, 65), linewidth=1, style=plot.style_circles)
plot(show_rounds ? round_r2 : na, "Round R2", color=color.new(color.white, 82), linewidth=1, style=plot.style_circles)
plot(show_rounds ? round_s1 : na, "Round S1", color=color.new(color.white, 65), linewidth=1, style=plot.style_circles)
plot(show_rounds ? round_s2 : na, "Round S2", color=color.new(color.white, 82), linewidth=1, style=plot.style_circles)

trail_bull_val = ta.lowest(low, 2)   - close * 0.0008
trail_bear_val = ta.highest(high, 2) + close * 0.0008

plot(show_trail and raw_bull ? trail_bull_val : na, "Bull Trail", color=color.new(bull_col, 35), linewidth=1, style=plot.style_circles)
plot(show_trail and raw_bear ? trail_bear_val : na, "Bear Trail", color=color.new(bear_col, 35), linewidth=1, style=plot.style_circles)

// ─────────────────────────────────────────
// SIGNAL SHAPES
// ─────────────────────────────────────────

plotshape(show_signals and bull_signal and not strong_bull, title="Buy Long",
  style=shape.triangleup, location=location.belowbar,
  color=bull_col, size=size.normal, text="Buy Long", textcolor=bull_col)

plotshape(show_signals and strong_bull, title="Strong Buy Long",
  style=shape.triangleup, location=location.belowbar,
  color=bull_col, size=size.large, text="Buy Long", textcolor=bull_col)

plotshape(show_signals and bear_signal and not strong_bear, title="Sell Short",
  style=shape.triangledown, location=location.abovebar,
  color=bear_col, size=size.normal, text="Sell Short", textcolor=bear_col)

plotshape(show_signals and strong_bear, title="Strong Sell Short",
  style=shape.triangledown, location=location.abovebar,
  color=bear_col, size=size.large, text="Sell Short", textcolor=bear_col)

plotshape(trim_long, title="Trim Long",
  style=shape.triangledown, location=location.abovebar,
  color=color.new(trim_col, 20), size=size.small, text="Trim", textcolor=trim_col)

plotshape(trim_short, title="Trim Short",
  style=shape.triangleup, location=location.belowbar,
  color=color.new(trim_col, 20), size=size.small, text="Trim", textcolor=trim_col)

plotshape(show_near and near_any, title="Near Level",
  style=shape.circle, location=location.abovebar,
  color=color.new(color.yellow, 25), size=size.tiny)

barcolor(color_bars and bull_score >= min_score and bull_mom_ok ? color.new(bull_col, 25) :
         color_bars and bear_score >= min_score and bear_mom_ok ? color.new(bear_col, 25) : na)

bgcolor(show_bg and raw_bull ? color.new(bull_col, 96) : na)
bgcolor(show_bg and raw_bear ? color.new(bear_col, 96) : na)

// ─────────────────────────────────────────
// DASHBOARD — BOTTOM RIGHT — LARGER
// ─────────────────────────────────────────

if show_dash
    var table dash = table.new(
      position.bottom_right, 2, 14,
      bgcolor      = color.new(#05050f, 5),
      border_color = color.new(color.gray, 40),
      border_width = 1,
      frame_color  = color.new(#2222aa, 30),
      frame_width  = 2)

    // Header row
    table.cell(dash, 0, 0, "TRINITY v3.3",
      text_color=color.white, text_size=size.normal,
      bgcolor=color.new(#111133, 0))
    table.cell(dash, 1, 0, "STATUS",
      text_color=color.white, text_size=size.normal,
      bgcolor=color.new(#111133, 0))

    // VWAP
    table.cell(dash, 0, 1, "VWAP", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 1, close > vwap_val ? "ABOVE" : "BELOW",
      text_color=close > vwap_val ? bull_col : bear_col, text_size=size.small)

    // EMA
    table.cell(dash, 0, 2, "EMA 9/21", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 2, ema_bull ? "BULL" : "BEAR",
      text_color=ema_bull ? bull_col : bear_col, text_size=size.small)

    // SMA Stack
    table.cell(dash, 0, 3, "SMA STACK", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 3, sma_bull ? "BULL" : sma_bear ? "BEAR" : "MIXED",
      text_color=sma_bull ? bull_col : sma_bear ? bear_col : color.orange, text_size=size.small)

    // RSI
    table.cell(dash, 0, 4, "RSI  " + str.tostring(math.round(rsi_val, 1)), text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 4,
      rsi_ob   ? "OVERBOUGHT" :
      rsi_os   ? "OVERSOLD"   :
      rsi_bull ? "BULL ZONE"  :
      rsi_bear ? "BEAR ZONE"  : "NEUTRAL",
      text_color=rsi_ob ? bear_col : rsi_os ? bull_col : rsi_bull ? bull_col : rsi_bear ? bear_col : color.orange,
      text_size=size.small)

    // Volume
    table.cell(dash, 0, 5, "VOLUME", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 5, high_vol ? "HIGH" : "LOW",
      text_color=high_vol ? bull_col : color.orange, text_size=size.small)

    // Momentum
    table.cell(dash, 0, 6, "MOMENTUM", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 6, mom_bull ? "UP" : mom_bear ? "DOWN" : "FLAT",
      text_color=mom_bull ? bull_col : mom_bear ? bear_col : color.orange, text_size=size.small)

    // Bull Score
    table.cell(dash, 0, 7, "BULL SCORE", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(bull_score) + " / 5",
      text_color=bull_score >= min_score ? bull_col : bull_score >= 2 ? color.orange : color.gray,
      text_size=size.small)

    // Separator
    table.cell(dash, 0, 8, "KEY LEVELS", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(dash, 1, 8, "──────────", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black, 60))

    // VWAP value
    table.cell(dash, 0, 9,  "VWAP $",    text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 9,  "$" + str.tostring(math.round(vwap_val, 2)), text_color=vwap_col, text_size=size.small)

    // PDH
    table.cell(dash, 0, 10, "PREV HIGH", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 10, not na(pdh) ? "$" + str.tostring(math.round(pdh, 2)) : "N/A",
      text_color=color.new(#ff6666, 0), text_size=size.small)

    // PDL
    table.cell(dash, 0, 11, "PREV LOW",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 11, not na(pdl) ? "$" + str.tostring(math.round(pdl, 2)) : "N/A",
      text_color=color.new(#66ff99, 0), text_size=size.small)

    // Round above
    table.cell(dash, 0, 12, "ROUND UP",  text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, 12, "$" + str.tostring(round_r1), text_color=color.white, text_size=size.small)

    // Signal
    sig_text  = strong_bull ? "STRONG BUY" : strong_bear ? "STRONG SELL" : bull_signal ? "BUY LONG" : bear_signal ? "SELL SHORT" : raw_bull ? "WATCH CALLS" : raw_bear ? "WATCH PUTS" : "WAIT"
    sig_color = strong_bull or bull_signal ? bull_col : strong_bear or bear_signal ? bear_col : raw_bull ? color.yellow : raw_bear ? color.orange : color.gray

    table.cell(dash, 0, 13, "SIGNAL",    text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 13, sig_text,    text_color=sig_color,   text_size=size.small)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────

alertcondition(bull_signal,   title="BUY LONG",          message="TRINITY v3.3 BUY LONG - Consider CALLS. Price: {{close}}")
alertcondition(bear_signal,   title="SELL SHORT",         message="TRINITY v3.3 SELL SHORT - Consider PUTS. Price: {{close}}")
alertcondition(strong_bull,   title="STRONG BUY LONG",   message="TRINITY v3.3 STRONG BUY LONG - High confidence CALL entry. Price: {{close}}")
alertcondition(strong_bear,   title="STRONG SELL SHORT",  message="TRINITY v3.3 STRONG SELL SHORT - High confidence PUT entry. Price: {{close}}")
alertcondition(trim_long,     title="TRIM CALLS",         message="TRINITY v3.3 Consider trimming CALLS - RSI extended. Price: {{close}}")
alertcondition(trim_short,    title="TRIM PUTS",          message="TRINITY v3.3 Consider trimming PUTS - RSI oversold. Price: {{close}}")
alertcondition(ema_x_up,      title="EMA CROSS UP",       message="TRINITY v3.3 EMA 9 crossed above EMA 21. Bullish. Price: {{close}}")
alertcondition(ema_x_down,    title="EMA CROSS DOWN",     message="TRINITY v3.3 EMA 9 crossed below EMA 21. Bearish. Price: {{close}}")
alertcondition(near_pdh,      title="NEAR PREV DAY HIGH", message="TRINITY v3.3 Near Previous Day High - resistance. Price: {{close}}")
alertcondition(near_pdl,      title="NEAR PREV DAY LOW",  message="TRINITY v3.3 Near Previous Day Low - support. Price: {{close}}")
alertcondition(near_vwap,     title="PRICE AT VWAP",      message="TRINITY v3.3 QQQ testing VWAP. Price: {{close}}")
alertcondition(near_round,    title="PRICE AT ROUND NUM",  message="TRINITY v3.3 QQQ at round number level. Price: {{close}}")
````

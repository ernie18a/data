# HERSCALP

- url: https://www.tradingview.com/script/e8rAzV27-HERSCALP/
- type: indicator
- pine_id: PUB;094f2b1620e247c49ee8ca62263d0f99
- version: 1.0

## Description

Good futes scrit. Its pretty good if you trade MES or MNQ give you long and short entrys

## Source Code

````pine
// ============================================================
//  APEX SCALP — MES / MNQ 3-Min Futures Scalping Indicator
//  Pine Script v5  |  Paste into TradingView Pine Editor
// ============================================================
//@version=5
indicator("APEX Scalp — MES/MNQ 3-Min", shorttitle="APEX Scalp", overlay=true, max_labels_count=500, max_lines_count=500)

// ─── INPUTS ───────────────────────────────────────────────────
grp_ema     = "EMA Settings"
ema9_len    = input.int(9,  "EMA Fast",  group=grp_ema)
ema21_len   = input.int(21, "EMA Mid",   group=grp_ema)
ema50_len   = input.int(50, "EMA Slow",  group=grp_ema)

grp_filt    = "Signal Filters"
rsi_len     = input.int(14, "RSI Length", group=grp_filt)
atr_len     = input.int(14, "ATR Length", group=grp_filt)
min_score   = input.int(4,  "Min Confluence Score (1–9)", minval=1, maxval=9, group=grp_filt)
use_vwap    = input.bool(true, "Require VWAP side confirmation", group=grp_filt)

grp_tgt     = "Target Multipliers (× ATR)"
t1_mult     = input.float(1.5, "T1 Multiplier", step=0.1, group=grp_tgt)
t2_mult     = input.float(2.5, "T2 Multiplier", step=0.1, group=grp_tgt)
t3_mult     = input.float(4.0, "T3 Multiplier", step=0.1, group=grp_tgt)
sl_mult     = input.float(1.2, "Stop Loss Multiplier", step=0.1, group=grp_tgt)

grp_disp    = "Display"
show_emas   = input.bool(true,  "Show EMAs",         group=grp_disp)
show_vwap   = input.bool(true,  "Show VWAP",         group=grp_disp)
show_labels = input.bool(true,  "Show Entry Labels", group=grp_disp)
show_lines  = input.bool(true,  "Show Target Lines", group=grp_disp)
show_table  = input.bool(true,  "Show Signal Table", group=grp_disp)
show_bg     = input.bool(true,  "Show Signal BG",    group=grp_disp)

// ─── INDICATORS ───────────────────────────────────────────────
ema9     = ta.ema(close, ema9_len)
ema21    = ta.ema(close, ema21_len)
ema50    = ta.ema(close, ema50_len)
rsi      = ta.rsi(close, rsi_len)
atr      = ta.atr(atr_len)
vwap_val = ta.vwap(hlc3)
[macd_line, signal_line, macd_hist] = ta.macd(close, 12, 26, 9)

// ─── CONDITIONS ───────────────────────────────────────────────
bull_stack     = ema9 > ema21 and ema21 > ema50
bear_stack     = ema9 < ema21 and ema21 < ema50
ema_cross_up   = ta.crossover(ema9, ema21)
ema_cross_down = ta.crossunder(ema9, ema21)
macd_flip_up   = macd_hist > 0 and macd_hist[1] <= 0
macd_flip_down = macd_hist < 0 and macd_hist[1] >= 0
above_vwap     = close > vwap_val
below_vwap     = close < vwap_val
rsi_long       = rsi > 45 and rsi < 72
rsi_short      = rsi < 55 and rsi > 28
pb_tol         = atr * 0.3
pb_long        = bull_stack and low  <= ema21 + pb_tol and low  >= ema21 - pb_tol
pb_short       = bear_stack and high >= ema21 - pb_tol and high <= ema21 + pb_tol

// ─── SCORING ──────────────────────────────────────────────────
long_score  = (bull_stack      ? 2 : 0) +
              (ema_cross_up    ? 2 : 0) +
              (macd_flip_up    ? 2 : 0) +
              ((not use_vwap or above_vwap) ? 1 : 0) +
              (rsi_long        ? 1 : 0) +
              (pb_long         ? 1 : 0)

short_score = (bear_stack      ? 2 : 0) +
              (ema_cross_down  ? 2 : 0) +
              (macd_flip_down  ? 2 : 0) +
              ((not use_vwap or below_vwap) ? 1 : 0) +
              (rsi_short       ? 1 : 0) +
              (pb_short        ? 1 : 0)

long_signal  = long_score  >= min_score and long_score  > short_score
short_signal = short_score >= min_score and short_score > long_score

// Prevent repeat signals on consecutive bars
var int last_dir = 0
new_long  = long_signal  and last_dir != 1
new_short = short_signal and last_dir != -1
if new_long
    last_dir := 1
if new_short
    last_dir := -1
if not long_signal and not short_signal
    last_dir := 0

// ─── TARGETS ──────────────────────────────────────────────────
long_sl  = close - atr * sl_mult
long_t1  = close + atr * t1_mult
long_t2  = close + atr * t2_mult
long_t3  = close + atr * t3_mult
short_sl = close + atr * sl_mult
short_t1 = close - atr * t1_mult
short_t2 = close - atr * t2_mult
short_t3 = close - atr * t3_mult

score_now = new_long ? long_score : new_short ? short_score : 0
strength  = score_now >= 7 ? "STRONG" : score_now >= 5 ? "MOD" : "WEAK"

// ─── EMA + VWAP PLOTS ─────────────────────────────────────────
plot(show_emas ? ema9  : na, "EMA 9",  color=color.new(#00d4ff, 0), linewidth=1)
plot(show_emas ? ema21 : na, "EMA 21", color=color.new(#f0c040, 0), linewidth=1)
plot(show_emas ? ema50 : na, "EMA 50", color=color.new(#a78bfa, 0), linewidth=2)
plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(#40e0a0, 0), linewidth=2, style=plot.style_circles)

// ─── BACKGROUND ───────────────────────────────────────────────
bgcolor(show_bg and new_long  ? color.new(color.green, 88) : na)
bgcolor(show_bg and new_short ? color.new(color.red,   88) : na)

// ─── ARROWS ───────────────────────────────────────────────────
plotshape(new_long,  style=shape.triangleup,   location=location.belowbar, color=#00ff9f, size=size.normal, title="Long",  text="LONG")
plotshape(new_short, style=shape.triangledown, location=location.abovebar, color=#ff4d6d, size=size.normal, title="Short", text="SHORT")

// ─── ENTRY LABELS ─────────────────────────────────────────────
if show_labels and new_long
    label.new(bar_index, low - atr * 0.6,
      "▲ LONG  [" + strength + "  " + str.tostring(long_score) + "/9]\n" +
      "Entry : " + str.tostring(close,   "#.##") + "\n" +
      "Stop  : " + str.tostring(long_sl, "#.##") + "\n" +
      "T1 50%: " + str.tostring(long_t1, "#.##") + "\n" +
      "T2 30%: " + str.tostring(long_t2, "#.##") + "\n" +
      "T3 20%: " + str.tostring(long_t3, "#.##"),
      style=label.style_label_up,
      color=color.new(#003320, 5),
      textcolor=#00ff9f,
      size=size.normal)

if show_labels and new_short
    label.new(bar_index, high + atr * 0.6,
      "▼ SHORT  [" + strength + "  " + str.tostring(short_score) + "/9]\n" +
      "Entry : " + str.tostring(close,    "#.##") + "\n" +
      "Stop  : " + str.tostring(short_sl, "#.##") + "\n" +
      "T1 50%: " + str.tostring(short_t1, "#.##") + "\n" +
      "T2 30%: " + str.tostring(short_t2, "#.##") + "\n" +
      "T3 20%: " + str.tostring(short_t3, "#.##"),
      style=label.style_label_down,
      color=color.new(#330010, 5),
      textcolor=#ff4d6d,
      size=size.normal)

// ─── TARGET LINES ─────────────────────────────────────────────
var line line_sl = na
var line line_t1 = na
var line line_t2 = na
var line line_t3 = na

if show_lines
    line.delete(line_sl)
    line.delete(line_t1)
    line.delete(line_t2)
    line.delete(line_t3)

if show_lines and new_long
    line_sl := line.new(bar_index, long_sl, bar_index+20, long_sl, color=color.new(#ff4d6d,20), style=line.style_dashed)
    line_t1 := line.new(bar_index, long_t1, bar_index+20, long_t1, color=color.new(#f0c040,20), style=line.style_dashed)
    line_t2 := line.new(bar_index, long_t2, bar_index+20, long_t2, color=color.new(#00ccff,20), style=line.style_dashed)
    line_t3 := line.new(bar_index, long_t3, bar_index+20, long_t3, color=color.new(#a78bfa,20), style=line.style_dashed)
    label.new(bar_index+20, long_sl, "SL",     style=label.style_label_left, color=color.new(#ff4d6d,70), textcolor=#ff4d6d, size=size.tiny)
    label.new(bar_index+20, long_t1, "T1 50%", style=label.style_label_left, color=color.new(#f0c040,70), textcolor=#f0c040, size=size.tiny)
    label.new(bar_index+20, long_t2, "T2 30%", style=label.style_label_left, color=color.new(#00ccff,70), textcolor=#00ccff, size=size.tiny)
    label.new(bar_index+20, long_t3, "T3 20%", style=label.style_label_left, color=color.new(#a78bfa,70), textcolor=#a78bfa, size=size.tiny)

if show_lines and new_short
    line_sl := line.new(bar_index, short_sl, bar_index+20, short_sl, color=color.new(#ff4d6d,20), style=line.style_dashed)
    line_t1 := line.new(bar_index, short_t1, bar_index+20, short_t1, color=color.new(#f0c040,20), style=line.style_dashed)
    line_t2 := line.new(bar_index, short_t2, bar_index+20, short_t2, color=color.new(#00ccff,20), style=line.style_dashed)
    line_t3 := line.new(bar_index, short_t3, bar_index+20, short_t3, color=color.new(#a78bfa,20), style=line.style_dashed)
    label.new(bar_index+20, short_sl, "SL",     style=label.style_label_left, color=color.new(#ff4d6d,70), textcolor=#ff4d6d, size=size.tiny)
    label.new(bar_index+20, short_t1, "T1 50%", style=label.style_label_left, color=color.new(#f0c040,70), textcolor=#f0c040, size=size.tiny)
    label.new(bar_index+20, short_t2, "T2 30%", style=label.style_label_left, color=color.new(#00ccff,70), textcolor=#00ccff, size=size.tiny)
    label.new(bar_index+20, short_t3, "T3 20%", style=label.style_label_left, color=color.new(#a78bfa,70), textcolor=#a78bfa, size=size.tiny)

// ─── INFO TABLE ───────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 8, bgcolor=color.new(#030a12,10), border_color=color.new(#0d1e30,0), border_width=1, frame_color=color.new(#0d1e30,0), frame_width=1)

if show_table and barstate.islast
    rsi_c    = rsi > 70 ? color.red : rsi < 30 ? color.green : color.new(#a0b0c0,0)
    vwap_rel = close > vwap_val ? "Above ▲" : "Below ▼"
    vwap_c   = close > vwap_val ? color.green : color.red
    macd_c   = macd_hist > 0 ? color.green : color.red
    stk_txt  = bull_stack ? "BULL ▲" : bear_stack ? "BEAR ▼" : "MIXED"
    stk_c    = bull_stack ? color.green : bear_stack ? color.red : color.gray
    sc_disp  = long_score > short_score ? long_score : short_score
    dir_disp = long_score > short_score ? "LONG" : short_score > long_score ? "SHORT" : "NONE"
    sc_c     = sc_disp >= min_score ? color.green : color.new(#3a5a78,0)
    sig_txt  = long_signal ? "▲ LONG" : short_signal ? "▼ SHORT" : "WAITING"
    sig_c    = long_signal ? color.new(#00ff9f,0) : short_signal ? color.new(#ff4d6d,0) : color.new(#3a5a78,0)

    table.cell(t, 0, 0, "APEX SCALP", text_color=#00d4ff,  text_size=size.small, bgcolor=color.new(#030a12,5))
    table.cell(t, 1, 0, "3-MIN",      text_color=#3a5a78,  text_size=size.small, bgcolor=color.new(#030a12,5))
    table.cell(t, 0, 1, "RSI",        text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 1, str.tostring(rsi,"#.0"), text_color=rsi_c, text_size=size.small)
    table.cell(t, 0, 2, "ATR",        text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 2, str.tostring(atr,"#.00"), text_color=#e0a030, text_size=size.small)
    table.cell(t, 0, 3, "VWAP",       text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 3, vwap_rel,     text_color=vwap_c,   text_size=size.small)
    table.cell(t, 0, 4, "MACD Hist",  text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 4, str.tostring(macd_hist,"#.00"), text_color=macd_c, text_size=size.small)
    table.cell(t, 0, 5, "EMA Stack",  text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 5, stk_txt,      text_color=stk_c,    text_size=size.small)
    table.cell(t, 0, 6, "Score",      text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 6, dir_disp + " " + str.tostring(sc_disp) + "/9", text_color=sc_c, text_size=size.small)
    table.cell(t, 0, 7, "Signal",     text_color=#3a5a78,  text_size=size.small)
    table.cell(t, 1, 7, sig_txt,      text_color=sig_c,    text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────
alertcondition(new_long,              title="APEX Long Signal",  message="APEX Scalp — LONG on {{ticker}} @ {{close}}")
alertcondition(new_short,             title="APEX Short Signal", message="APEX Scalp — SHORT on {{ticker}} @ {{close}}")
alertcondition(new_long or new_short, title="APEX Any Signal",   message="APEX Scalp — New Signal on {{ticker}} @ {{close}}")
````

# Gamma Map

- url: https://www.tradingview.com/script/duyauD9U-Gamma-Map/
- type: indicator
- pine_id: PUB;e4e4f3fc15394c6a997c28a954bbf660
- version: 1.0

## Description

This is an indicator with up to date GEX data to show on the the chart your chop zones, ceilings, long and short triggers, negative gamma nodes. Helpful to have it plotted on a chart with alert abilities.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gr8fultrader72
//@version=6
indicator("Short Gamma Momentum", overlay=true, max_bars_back=500, max_lines_count=20, max_labels_count=50)

// ═══════════════════════════════════════════════════════════
// SHORT GAMMA MOMENTUM INDICATOR
// Three signal stages:
//   1. PRELIMINARY — fires once when price enters chop zone with SG fuel
//   2. RECLAIM     — price reclaims chop zone low from below
//   3. CONTINUATION — price closes above chop zone high with SG fuel confirmed
// Trigger alerts with stop loss buffer
// NO TRADE label in chop zone
// ═══════════════════════════════════════════════════════════

// ── GLOBAL SETTINGS ─────────────────────────────────────────
var string GS = "── Global Settings ──"
show_2m         = input.bool(true,  "Show 2m Signals",            group=GS)
show_5m         = input.bool(true,  "Show 5m Signals",            group=GS)
use_tick        = input.bool(false, "Use TICK Confirmation",       group=GS)
tick_threshold  = input.int(0,      "TICK Minimum for Long",       minval=-500, maxval=500, group=GS)
vol_filter      = input.bool(true,  "Volume Exhaustion (Reclaim)", group=GS)
cont_lookback   = input.int(10,     "SG Visit Lookback (bars)",    minval=3, maxval=30, group=GS)
cont_vol_expand = input.bool(true,  "Require Expanding Volume",    group=GS)
stop_buffer     = input.float(0.25, "Stop Loss Buffer (points below/above trigger)", minval=0.0, maxval=5.0, step=0.05, group=GS)

// ── ZONE DISPLAY SETTINGS ────────────────────────────────────
var string ZS = "── Zone Display ──"
show_chop_fill  = input.bool(true,  "Show Chop Zone Fill",          group=ZS)
show_sg_fill    = input.bool(true,  "Show Short Gamma Fill",         group=ZS)
show_lg_fill    = input.bool(true,  "Show Long Gamma Fill",          group=ZS)
show_cn_fill    = input.bool(true,  "Show Control Node Fill",        group=ZS)
show_bg         = input.bool(true,  "Show Candle Background Color",  group=ZS)
show_no_trade   = input.bool(true,  "Show NO TRADE in Chop Zone",    group=ZS)

// ── TICKER INPUTS ────────────────────────────────────────────
var string T1 = "── Ticker 1 (e.g. QQQ) ──"
t1_on          = input.bool(true,    "Enable",           group=T1)
t1_name        = input.string("QQQ", "Ticker Name",      group=T1)
t1_chop_high   = input.float(0.0,    "Chop High",        group=T1)
t1_chop_low    = input.float(0.0,    "Chop Low",         group=T1)
t1_sg_low      = input.float(0.0,    "Floor",            group=T1)
t1_ceiling     = input.float(0.0,    "Ceiling",          group=T1)
t1_ctrl_node   = input.float(0.0,    "Control Node",     group=T1)
t1_long_trig   = input.float(0.0,    "Long Trigger",     group=T1)
t1_short_trig  = input.float(0.0,    "Short Trigger",    group=T1)
t1_neg_node   = input.float(0.0,    "Nearest Neg Node Below", group=T1)
t1_neg_above  = input.float(0.0,    "Nearest Neg Node Above", group=T1)

var string T2 = "── Ticker 2 (e.g. TSLA) ──"
t2_on          = input.bool(false,   "Enable",           group=T2)
t2_name        = input.string("TSLA","Ticker Name",      group=T2)
t2_chop_high   = input.float(0.0,    "Chop High",        group=T2)
t2_chop_low    = input.float(0.0,    "Chop Low",         group=T2)
t2_sg_low      = input.float(0.0,    "Floor",            group=T2)
t2_ceiling     = input.float(0.0,    "Ceiling",          group=T2)
t2_ctrl_node   = input.float(0.0,    "Control Node",     group=T2)
t2_long_trig   = input.float(0.0,    "Long Trigger",     group=T2)
t2_short_trig  = input.float(0.0,    "Short Trigger",    group=T2)
t2_neg_node   = input.float(0.0,    "Nearest Neg Node Below", group=T2)
t2_neg_above  = input.float(0.0,    "Nearest Neg Node Above", group=T2)

var string T3 = "── Ticker 3 (e.g. NVDA) ──"
t3_on          = input.bool(false,   "Enable",           group=T3)
t3_name        = input.string("NVDA","Ticker Name",      group=T3)
t3_chop_high   = input.float(0.0,    "Chop High",        group=T3)
t3_chop_low    = input.float(0.0,    "Chop Low",         group=T3)
t3_sg_low      = input.float(0.0,    "Floor",            group=T3)
t3_ceiling     = input.float(0.0,    "Ceiling",          group=T3)
t3_ctrl_node   = input.float(0.0,    "Control Node",     group=T3)
t3_long_trig   = input.float(0.0,    "Long Trigger",     group=T3)
t3_short_trig  = input.float(0.0,    "Short Trigger",    group=T3)
t3_neg_node   = input.float(0.0,    "Nearest Neg Node Below", group=T3)
t3_neg_above  = input.float(0.0,    "Nearest Neg Node Above", group=T3)

var string T4 = "── Ticker 4 (e.g. META) ──"
t4_on          = input.bool(false,   "Enable",           group=T4)
t4_name        = input.string("META","Ticker Name",      group=T4)
t4_chop_high   = input.float(0.0,    "Chop High",        group=T4)
t4_chop_low    = input.float(0.0,    "Chop Low",         group=T4)
t4_sg_low      = input.float(0.0,    "Floor",            group=T4)
t4_ceiling     = input.float(0.0,    "Ceiling",          group=T4)
t4_ctrl_node   = input.float(0.0,    "Control Node",     group=T4)
t4_long_trig   = input.float(0.0,    "Long Trigger",     group=T4)
t4_short_trig  = input.float(0.0,    "Short Trigger",    group=T4)
t4_neg_node   = input.float(0.0,    "Nearest Neg Node Below", group=T4)
t4_neg_above  = input.float(0.0,    "Nearest Neg Node Above", group=T4)

var string T5 = "── Ticker 5 (e.g. AMZN) ──"
t5_on          = input.bool(false,   "Enable",           group=T5)
t5_name        = input.string("AMZN","Ticker Name",      group=T5)
t5_chop_high   = input.float(0.0,    "Chop High",        group=T5)
t5_chop_low    = input.float(0.0,    "Chop Low",         group=T5)
t5_sg_low      = input.float(0.0,    "Floor",            group=T5)
t5_ceiling     = input.float(0.0,    "Ceiling",          group=T5)
t5_ctrl_node   = input.float(0.0,    "Control Node",     group=T5)
t5_long_trig   = input.float(0.0,    "Long Trigger",     group=T5)
t5_short_trig  = input.float(0.0,    "Short Trigger",    group=T5)
t5_neg_node   = input.float(0.0,    "Nearest Neg Node Below", group=T5)
t5_neg_above  = input.float(0.0,    "Nearest Neg Node Above", group=T5)

// ── TIMEFRAME DATA ───────────────────────────────────────────
[c2, o2, h2, l2, v2] = request.security(syminfo.tickerid, "2", [close, open, high, low, volume], lookahead=barmerge.lookahead_off)
[c5, o5, h5, l5, v5] = request.security(syminfo.tickerid, "5", [close, open, high, low, volume], lookahead=barmerge.lookahead_off)

// ── TICK DATA ────────────────────────────────────────────────
tick_close = request.security("USI:TICK", timeframe.period, close, lookahead=barmerge.lookahead_off)
tick_ok    = not use_tick or tick_close >= tick_threshold

// ── ACTIVE TICKER RESOLUTION ─────────────────────────────────
current_ticker = syminfo.ticker
is_t1 = t1_on and (current_ticker == t1_name or current_ticker == "QQQ")
is_t2 = t2_on and current_ticker == t2_name and not is_t1
is_t3 = t3_on and current_ticker == t3_name and not is_t1 and not is_t2
is_t4 = t4_on and current_ticker == t4_name and not is_t1 and not is_t2 and not is_t3
is_t5 = t5_on and current_ticker == t5_name and not is_t1 and not is_t2 and not is_t3 and not is_t4

active_enabled  = is_t1 or is_t2 or is_t3 or is_t4 or is_t5

active_chop_h   = 0.0
active_chop_l   = 0.0
active_ceiling  = 0.0
active_sg_low   = 0.0
active_ctrl     = 0.0
active_name     = ""
active_long_t   = 0.0
active_short_t  = 0.0
active_neg_node = 0.0
active_neg_above = 0.0

if is_t1
    active_chop_h  := t1_chop_high
    active_chop_l  := t1_chop_low
    active_ceiling := t1_ceiling
    active_sg_low  := t1_sg_low
    active_ctrl    := t1_ctrl_node
    active_name    := t1_name
    active_long_t  := t1_long_trig
    active_short_t := t1_short_trig
    active_neg_node  := t1_neg_node
    active_neg_above := t1_neg_above
else if is_t2
    active_chop_h  := t2_chop_high
    active_chop_l  := t2_chop_low
    active_ceiling := t2_ceiling
    active_sg_low  := t2_sg_low
    active_ctrl    := t2_ctrl_node
    active_name    := t2_name
    active_long_t  := t2_long_trig
    active_short_t := t2_short_trig
    active_neg_node  := t2_neg_node
    active_neg_above := t2_neg_above
else if is_t3
    active_chop_h  := t3_chop_high
    active_chop_l  := t3_chop_low
    active_ceiling := t3_ceiling
    active_sg_low  := t3_sg_low
    active_ctrl    := t3_ctrl_node
    active_name    := t3_name
    active_long_t  := t3_long_trig
    active_short_t := t3_short_trig
    active_neg_node  := t3_neg_node
    active_neg_above := t3_neg_above
else if is_t4
    active_chop_h  := t4_chop_high
    active_chop_l  := t4_chop_low
    active_ceiling := t4_ceiling
    active_sg_low  := t4_sg_low
    active_ctrl    := t4_ctrl_node
    active_name    := t4_name
    active_long_t  := t4_long_trig
    active_short_t := t4_short_trig
    active_neg_node  := t4_neg_node
    active_neg_above := t4_neg_above
else if is_t5
    active_chop_h  := t5_chop_high
    active_chop_l  := t5_chop_low
    active_ceiling := t5_ceiling
    active_sg_low  := t5_sg_low
    active_ctrl    := t5_ctrl_node
    active_name    := t5_name
    active_long_t  := t5_long_trig
    active_short_t := t5_short_trig
    active_neg_node  := t5_neg_node
    active_neg_above := t5_neg_above

// ── STOP LEVELS ───────────────────────────────────────────────
long_stop  = active_long_t  > 0 ? active_long_t  - stop_buffer : 0.0
short_stop = active_short_t > 0 ? active_short_t + stop_buffer : 0.0

// ── SG VISIT CHECK (bull — visited below chop low) ──────────
visited_sg_2m = false
visited_sg_5m = false
if active_chop_l > 0
    for i = 1 to cont_lookback
        if c2[i] < active_chop_l
            visited_sg_2m := true
        if c5[i] < active_chop_l
            visited_sg_5m := true

// ── NEGATIVE GAMMA VISIT CHECK (bear — visited above chop high) ──
visited_ng_2m = false
visited_ng_5m = false
if active_chop_h > 0
    for i = 1 to cont_lookback
        if c2[i] > active_chop_h
            visited_ng_2m := true
        if c5[i] > active_chop_h
            visited_ng_5m := true

// ── PRE-COMPUTED SMAs ─────────────────────────────────────────
sma_v2_10      = ta.sma(v2, 10)
sma_v5_10      = ta.sma(v5, 10)
sma_v2_10_prev = ta.sma(v2, 10)[1]
sma_v5_10_prev = ta.sma(v5, 10)[1]

// ── TICK FOR SHORTS ──────────────────────────────────────────
tick_ok_short = not use_tick or tick_close <= (tick_threshold * -1)

// ── VOLUME CONDITIONS ─────────────────────────────────────────
vol_climax_2m = v2[1] > sma_v2_10_prev * 1.8 and v2 < v2[1] * 0.6
vol_climax_5m = v5[1] > sma_v5_10_prev * 1.8 and v5 < v5[1] * 0.6
vol_ok_2m     = not vol_filter or vol_climax_2m
vol_ok_5m     = not vol_filter or vol_climax_5m
vol_expand_2m = not cont_vol_expand or v2 > sma_v2_10 * 1.2
vol_expand_5m = not cont_vol_expand or v5 > sma_v5_10 * 1.2

// ── SIGNAL CONDITIONS ─────────────────────────────────────────
levels_ok = active_enabled and active_chop_h > 0 and active_chop_l > 0

// BULL: reclaim from below
reclaim_2m = levels_ok and show_2m and c2[1] < active_chop_l and c2 >= active_chop_l and tick_ok and vol_ok_2m
reclaim_5m = levels_ok and show_5m and c5[1] < active_chop_l and c5 >= active_chop_l and tick_ok and vol_ok_5m

// BULL: continuation through chop high
cont_2m = levels_ok and show_2m and c2[1] < active_chop_h and c2 > active_chop_h and tick_ok and visited_sg_2m and vol_expand_2m
cont_5m = levels_ok and show_5m and c5[1] < active_chop_h and c5 > active_chop_h and tick_ok and visited_sg_5m and vol_expand_5m

// BEAR: reclaim from above (price visited above chop high, now closing below it)
bear_reclaim_2m = levels_ok and show_2m and c2[1] > active_chop_h and c2 <= active_chop_h and tick_ok_short and visited_ng_2m and vol_expand_2m
bear_reclaim_5m = levels_ok and show_5m and c5[1] > active_chop_h and c5 <= active_chop_h and tick_ok_short and visited_ng_5m and vol_expand_5m

// BEAR: continuation through chop low (price visited above chop high, now breaking below chop low)
bear_cont_2m = levels_ok and show_2m and c2[1] > active_chop_l and c2 < active_chop_l and tick_ok_short and visited_ng_2m and vol_expand_2m
bear_cont_5m = levels_ok and show_5m and c5[1] > active_chop_l and c5 < active_chop_l and tick_ok_short and visited_ng_5m and vol_expand_5m

// BEAR: preliminary — price entering chop zone from above with NG fuel confirmed
bear_prelim_raw = levels_ok and tick_ok_short and
             ((show_2m and c2 >= active_chop_l and c2 <= active_chop_h and c2 < c2[1] and visited_ng_2m and vol_expand_2m) or
              (show_5m and c5 >= active_chop_l and c5 <= active_chop_h and c5 < c5[1] and visited_ng_5m and vol_expand_5m))

prelim_raw = levels_ok and tick_ok and
             ((show_2m and c2 >= active_chop_l and c2 <= active_chop_h and c2 > c2[1] and visited_sg_2m and vol_expand_2m) or
              (show_5m and c5 >= active_chop_l and c5 <= active_chop_h and c5 > c5[1] and visited_sg_5m and vol_expand_5m))

// ── TRIGGER CONDITIONS (2m candle close) ─────────────────────
long_triggered  = active_long_t  > 0 and c2[1] < active_long_t  and c2 >= active_long_t
short_triggered = active_short_t > 0 and c2[1] > active_short_t and c2 <= active_short_t

// ── PRELIMINARY ONCE-ONLY GATES ──────────────────────────────
var bool prelim_fired      = false
var bool bear_prelim_fired = false

price_left_chop = active_chop_l > 0 and (close < active_chop_l or close > active_chop_h)
if price_left_chop
    prelim_fired      := false
    bear_prelim_fired := false

is_prelim = prelim_raw and not prelim_fired
if is_prelim
    prelim_fired := true

is_bear_prelim = bear_prelim_raw and not bear_prelim_fired
if is_bear_prelim
    bear_prelim_fired := true

// ── FINAL SIGNAL STRINGS ──────────────────────────────────────
active_sig = reclaim_2m      ? "RECLAIM 2m"      :
             reclaim_5m      ? "RECLAIM 5m"      :
             cont_2m         ? "CONT 2m"         :
             cont_5m         ? "CONT 5m"         :
             bear_reclaim_2m ? "BEAR RECLAIM 2m" :
             bear_reclaim_5m ? "BEAR RECLAIM 5m" :
             bear_cont_2m    ? "BEAR CONT 2m"    :
             bear_cont_5m    ? "BEAR CONT 5m"    : ""

is_reclaim      = str.contains(active_sig, "RECLAIM") and not str.contains(active_sig, "BEAR")
is_cont         = str.contains(active_sig, "CONT")    and not str.contains(active_sig, "BEAR")
is_bear_reclaim = str.contains(active_sig, "BEAR RECLAIM")
is_bear_cont    = str.contains(active_sig, "BEAR CONT")
any_bull_signal = is_reclaim or is_cont
any_bear_signal = is_bear_reclaim or is_bear_cont
any_signal      = any_bull_signal or any_bear_signal

// ── ZONE BOOLEANS ────────────────────────────────────────────
is_short_gamma = active_chop_l > 0 and close < active_chop_l and close > active_sg_low
is_chop_zone   = active_chop_h > 0 and close >= active_chop_l and close <= active_chop_h
is_long_gamma  = active_chop_h > 0 and close > active_chop_h

// ── CANDLE BACKGROUND ────────────────────────────────────────
bgcolor(show_bg and is_short_gamma ? color.new(color.red,    85) : na, title="Short Gamma BG")
bgcolor(show_bg and is_chop_zone   ? color.new(color.yellow, 88) : na, title="Chop Zone BG")
bgcolor(show_bg and is_long_gamma  ? color.new(color.green,  90) : na, title="Long Gamma BG")

// ── HORIZONTAL ZONE BANDS ────────────────────────────────────
p_ceiling = plot(active_ceiling > 0 ? active_ceiling : na, "Ceiling",      color=color.new(color.red,    0), linewidth=2, style=plot.style_line)
p_ctrl    = plot(active_ctrl    > 0 ? active_ctrl    : na, "Control Node", color=color.new(color.purple, 0), linewidth=2, style=plot.style_line)
p_chop_h  = plot(active_chop_h  > 0 ? active_chop_h  : na, "Chop High",   color=color.new(color.yellow, 0), linewidth=2, style=plot.style_line)
p_chop_l  = plot(active_chop_l  > 0 ? active_chop_l  : na, "Chop Low",    color=color.new(color.yellow, 0), linewidth=2, style=plot.style_line)
p_floor   = plot(active_sg_low  > 0 ? active_sg_low  : na, "Floor",       color=color.new(color.green,  0), linewidth=2, style=plot.style_line)

// Nearest negative node below — orange crosses
plot(active_neg_node  > 0 ? active_neg_node  : na, "Neg Node Below", color=color.new(color.orange, 0), linewidth=1, style=plot.style_cross)
// Nearest negative node above — red-orange crosses
plot(active_neg_above > 0 ? active_neg_above : na, "Neg Node Above", color=color.new(color.red,    30), linewidth=1, style=plot.style_cross)

// ── LEVEL LABELS (right edge, always visible) ─────────────────
var label lbl_ceiling  = na
var label lbl_ctrl     = na
var label lbl_chop_h   = na
var label lbl_chop_l   = na
var label lbl_floor    = na
var label lbl_neg_node = na
var label lbl_long_t   = na
var label lbl_short_t  = na
var label lbl_long_sl  = na
var label lbl_short_sl = na

label.delete(lbl_ceiling)
label.delete(lbl_ctrl)
label.delete(lbl_chop_h)
label.delete(lbl_chop_l)
label.delete(lbl_floor)
label.delete(lbl_neg_node)
label.delete(lbl_long_t)
label.delete(lbl_short_t)
label.delete(lbl_long_sl)
label.delete(lbl_short_sl)

if barstate.islast and active_chop_h > 0
    if active_ceiling > 0
        lbl_ceiling  := label.new(bar_index + 1, active_ceiling, "GEX CEILING " + str.tostring(active_ceiling),
          color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    if active_ctrl > 0
        lbl_ctrl     := label.new(bar_index + 1, active_ctrl, "CTRL NODE " + str.tostring(active_ctrl),
          color=color.new(color.purple, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    lbl_chop_h   := label.new(bar_index + 1, active_chop_h, "CHOP HIGH " + str.tostring(active_chop_h),
      color=color.new(color.yellow, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
    lbl_chop_l   := label.new(bar_index + 1, active_chop_l, "CHOP LOW " + str.tostring(active_chop_l),
      color=color.new(color.yellow, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
    if active_sg_low > 0
        lbl_floor    := label.new(bar_index + 1, active_sg_low, "GEX FLOOR " + str.tostring(active_sg_low),
          color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    if active_neg_node > 0
        lbl_neg_node := label.new(bar_index + 1, active_neg_node, "NEG NODE BELOW " + str.tostring(active_neg_node),
          color=color.new(color.orange, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    if active_neg_above > 0
        label.new(bar_index + 1, active_neg_above, "NEG NODE ABOVE " + str.tostring(active_neg_above),
          color=color.new(color.red, 30), textcolor=color.white, style=label.style_label_left, size=size.small)
    if active_long_t > 0
        lbl_long_t   := label.new(bar_index + 1, active_long_t, "LONG TRIG " + str.tostring(active_long_t),
          color=color.new(color.lime, 20), textcolor=color.black, style=label.style_label_left, size=size.small)
        lbl_long_sl  := label.new(bar_index + 1, long_stop, "LONG SL " + str.tostring(long_stop),
          color=color.new(color.lime, 60), textcolor=color.black, style=label.style_label_left, size=size.small)
    if active_short_t > 0
        lbl_short_t  := label.new(bar_index + 1, active_short_t, "SHORT TRIG " + str.tostring(active_short_t),
          color=color.new(color.orange, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
        lbl_short_sl := label.new(bar_index + 1, short_stop, "SHORT SL " + str.tostring(short_stop),
          color=color.new(color.orange, 60), textcolor=color.white, style=label.style_label_left, size=size.small)

// Trigger lines
plot(active_long_t  > 0 ? active_long_t  : na, "Long Trigger",  color=color.new(color.lime,   0), linewidth=1, style=plot.style_stepline)
plot(active_short_t > 0 ? active_short_t : na, "Short Trigger", color=color.new(color.orange, 0), linewidth=1, style=plot.style_stepline)

// Stop loss lines — dotted
plot(long_stop  > 0 ? long_stop  : na, "Long Stop",  color=color.new(color.lime,   30), linewidth=1, style=plot.style_circles)
plot(short_stop > 0 ? short_stop : na, "Short Stop", color=color.new(color.orange, 30), linewidth=1, style=plot.style_circles)

// Zone fills
fill(p_chop_h,  p_chop_l, color=show_chop_fill ? color.new(color.yellow, 80) : na, title="Chop Zone Fill")
fill(p_chop_l,  p_floor,  color=show_sg_fill   ? color.new(color.red,    82) : na, title="Short Gamma Fill")
fill(p_ceiling, p_chop_h, color=show_lg_fill   ? color.new(color.green,  85) : na, title="Long Gamma Fill")
fill(p_ceiling, p_ctrl,   color=show_cn_fill   ? color.new(color.purple, 88) : na, title="Control Node Fill")

// ── NEAREST NEGATIVE NODE LABEL ─────────────────────────────
var label neg_node_label = na
label.delete(neg_node_label)
if active_neg_node > 0 and barstate.islast
    neg_node_label := label.new(
      bar_index + 1, active_neg_node,
      "NEG NODE " + str.tostring(active_neg_node),
      color=color.new(color.orange, 10),
      textcolor=color.white,
      style=label.style_label_left,
      size=size.small)

// ── NO TRADE LABEL IN CHOP ZONE ──────────────────────────────
chop_mid = (active_chop_h + active_chop_l) / 2
var label no_trade_label = na
label.delete(no_trade_label)
if show_no_trade and active_chop_h > 0 and active_chop_l > 0 and barstate.islast
    no_trade_label := label.new(
      bar_index - 10, chop_mid,
      "N  O     T  R  A  D  E",
      color=color.new(color.black, 100),
      textcolor=color.white,
      style=label.style_none,
      size=size.huge,
      textalign=text.align_center)

// ── SIGNAL LABELS ─────────────────────────────────────────────
// Bull preliminary
if is_prelim
    label.new(bar_index, low * 0.9995,
      "SETUP\n" + active_name + " in chop\nSG fuel confirmed\nWatch " + str.tostring(active_chop_h),
      color=color.new(color.orange, 10), textcolor=color.black,
      style=label.style_label_up, size=size.small)

// Bear preliminary
if is_bear_prelim
    label.new(bar_index, high * 1.0005,
      "BEAR SETUP\n" + active_name + " in chop\nNG fuel confirmed\nWatch " + str.tostring(active_chop_l),
      color=color.new(color.red, 10), textcolor=color.white,
      style=label.style_label_down, size=size.small)

// Bull confirmed signals
if any_bull_signal
    label.new(bar_index, low * 0.999,
      (is_reclaim ? "RECLAIM" : "MOMENTUM") + "\n" + active_name + " " + active_sig + "\nTarget: " + str.tostring(active_ceiling),
      color=is_reclaim ? color.new(color.lime, 0) : color.new(color.aqua, 0),
      textcolor=color.black, style=label.style_label_up, size=size.normal)

// Bear confirmed signals
if any_bear_signal
    label.new(bar_index, high * 1.001,
      (is_bear_reclaim ? "BEAR RECLAIM" : "BEAR MOMENTUM") + "\n" + active_name + " " + active_sig + "\nTarget: " + str.tostring(active_sg_low),
      color=is_bear_reclaim ? color.new(color.red, 0) : color.new(color.fuchsia, 0),
      textcolor=color.white, style=label.style_label_down, size=size.normal)

// ── TAKE PROFIT LEVELS ───────────────────────────────────────
// Long TPs: TP1 = control node (above trigger), TP2 = ceiling, TP3 = ceiling + 50% extension
// Only use control node as TP1 if it is ABOVE the long trigger
long_tp1 = active_ctrl > 0 and active_ctrl > active_long_t ? active_ctrl : active_ceiling > 0 and active_long_t > 0 ? active_long_t + (active_ceiling - active_long_t) * 0.33 : 0.0
long_tp2 = active_ceiling > 0 ? active_ceiling : 0.0
long_tp3 = active_ceiling > 0 and active_long_t > 0 ? active_ceiling + (active_ceiling - active_long_t) * 0.5 : 0.0

// Short TPs: must all be BELOW the short trigger
// TP1 = neg node if below trigger, else midpoint between trigger and floor
// TP2 = floor
// TP3 = floor - 50% extension below floor
short_tp1 = active_neg_node > 0 and active_neg_node < active_short_t ? active_neg_node : active_sg_low > 0 and active_short_t > 0 ? active_short_t - (active_short_t - active_sg_low) * 0.5 : 0.0
short_tp2 = active_sg_low   > 0 and active_sg_low < active_short_t ? active_sg_low : 0.0
short_tp3 = active_sg_low   > 0 and active_short_t > 0 and active_sg_low < active_short_t ? active_sg_low - (active_short_t - active_sg_low) * 0.5 : 0.0

// TP plot lines — only show after trigger fires
// Using var to latch on trigger and hold
var float ltp1 = na
var float ltp2 = na
var float ltp3 = na
var float stp1 = na
var float stp2 = na
var float stp3 = na

if long_triggered
    ltp1 := long_tp1
    ltp2 := long_tp2
    ltp3 := long_tp3
    stp1 := na
    stp2 := na
    stp3 := na

if short_triggered
    stp1 := short_tp1
    stp2 := short_tp2
    stp3 := short_tp3
    ltp1 := na
    ltp2 := na
    ltp3 := na

// Trigger labels with TPs
if long_triggered
    label.new(bar_index, low * 0.9992,
      "LONG ENTRY\n" + active_name + "\nSL: " + str.tostring(long_stop) +
      "\nTP1: " + (long_tp1 > 0 ? str.tostring(long_tp1) : "-") +
      "\nTP2: " + (long_tp2 > 0 ? str.tostring(long_tp2) : "-") +
      "\nTP3: " + (long_tp3 > 0 ? str.tostring(long_tp3) : "-"),
      color=color.new(color.lime, 0), textcolor=color.black,
      style=label.style_label_up, size=size.normal)

if short_triggered
    label.new(bar_index, high * 1.0008,
      "SHORT ENTRY\n" + active_name + "\nSL: " + str.tostring(short_stop) +
      "\nTP1: " + (short_tp1 > 0 ? str.tostring(short_tp1) : "-") +
      "\nTP2: " + (short_tp2 > 0 ? str.tostring(short_tp2) : "-") +
      "\nTP3: " + (short_tp3 > 0 ? str.tostring(short_tp3) : "-"),
      color=color.new(color.orange, 0), textcolor=color.black,
      style=label.style_label_down, size=size.normal)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(is_prelim,
  title="SG Preliminary Setup",
  message="PRELIMINARY: {{ticker}} in chop zone with SG fuel. Watch for break above chop high.")

alertcondition(is_reclaim and str.contains(active_sig, "2m"),
  title="SG Reclaim 2m",
  message="RECLAIM (2m): {{ticker}} reclaimed chop low. Target ceiling.")

alertcondition(is_reclaim and str.contains(active_sig, "5m"),
  title="SG Reclaim 5m",
  message="RECLAIM (5m): {{ticker}} reclaimed chop low. Target ceiling.")

alertcondition(is_cont and str.contains(active_sig, "2m"),
  title="SG Continuation 2m",
  message="CONTINUATION (2m): {{ticker}} broke chop high with SG momentum.")

alertcondition(is_cont and str.contains(active_sig, "5m"),
  title="SG Continuation 5m",
  message="CONTINUATION (5m): {{ticker}} broke chop high with SG momentum.")

alertcondition(any_bull_signal,
  title="SG Any Bull Signal",
  message="BULL SIGNAL: {{ticker}} confirmed. Check chart immediately.")

alertcondition(is_bear_prelim,
  title="SG Bear Preliminary Setup",
  message="BEAR PRELIMINARY: {{ticker}} entering chop from above with NG fuel. Watch for break below chop low.")

alertcondition(is_bear_reclaim and str.contains(active_sig, "2m"),
  title="SG Bear Reclaim 2m",
  message="BEAR RECLAIM (2m): {{ticker}} broke below chop high from above. Target floor.")

alertcondition(is_bear_reclaim and str.contains(active_sig, "5m"),
  title="SG Bear Reclaim 5m",
  message="BEAR RECLAIM (5m): {{ticker}} broke below chop high from above. Target floor.")

alertcondition(is_bear_cont and str.contains(active_sig, "2m"),
  title="SG Bear Continuation 2m",
  message="BEAR CONTINUATION (2m): {{ticker}} broke below chop low with NG momentum. Target floor.")

alertcondition(is_bear_cont and str.contains(active_sig, "5m"),
  title="SG Bear Continuation 5m",
  message="BEAR CONTINUATION (5m): {{ticker}} broke below chop low with NG momentum. Target floor.")

alertcondition(any_bear_signal,
  title="SG Any Bear Signal",
  message="BEAR SIGNAL: {{ticker}} confirmed. Check chart immediately.")

alertcondition(any_signal,
  title="SG Any Signal",
  message="SG SIGNAL: {{ticker}} confirmed. Check chart immediately.")

alertcondition(long_triggered,
  title="LONG TRIGGER",
  message="LONG TRIGGER: {{ticker}} 2m close above trigger. Entry confirmed. Stop: below trigger minus buffer.")

alertcondition(short_triggered,
  title="SHORT TRIGGER",
  message="SHORT TRIGGER: {{ticker}} 2m close below trigger. Entry confirmed. Stop: above trigger plus buffer.")

// ── STATUS TABLE ──────────────────────────────────────────────
var table status = table.new(position.top_right, 2, 15,
  bgcolor=color.new(color.black, 20), border_width=1,
  border_color=color.new(color.gray, 50), frame_width=1,
  frame_color=color.new(color.gray, 30))

zone_text  = is_short_gamma ? "SHORT GAMMA" : is_chop_zone ? "NO TRADE" : is_long_gamma ? "LONG GAMMA" : "OUTSIDE"
zone_color = is_short_gamma ? color.red : is_chop_zone ? color.yellow : is_long_gamma ? color.green : color.gray

table.cell(status, 0, 0,  "GEX ZONE",    text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 0,  zone_text,     text_color=zone_color,   text_size=size.small)
table.cell(status, 0, 1,  "SIGNAL",      text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 1,  active_sig == "" ? "-" : active_sig, text_color=active_sig == "" ? color.gray : color.lime, text_size=size.small)
table.cell(status, 0, 2,  "CEILING",     text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 2,  active_ceiling > 0 ? str.tostring(active_ceiling) : "-", text_color=color.red, text_size=size.small)
table.cell(status, 0, 3,  "CTRL NODE",   text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 3,  active_ctrl > 0 ? str.tostring(active_ctrl) : "-", text_color=color.purple, text_size=size.small)
table.cell(status, 0, 4,  "CHOP",        text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 4,  active_chop_h > 0 ? str.tostring(active_chop_l) + "-" + str.tostring(active_chop_h) : "-", text_color=color.yellow, text_size=size.small)
table.cell(status, 0, 5,  "FLOOR",       text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 5,  active_sg_low > 0 ? str.tostring(active_sg_low) : "-", text_color=color.green, text_size=size.small)
table.cell(status, 0, 6,  "LONG TRIG",   text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 6,  active_long_t > 0 ? str.tostring(active_long_t) + " / SL " + str.tostring(long_stop) : "-", text_color=color.lime, text_size=size.small)
table.cell(status, 0, 7,  "SHORT TRIG",  text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 7,  active_short_t > 0 ? str.tostring(active_short_t) + " / SL " + str.tostring(short_stop) : "-", text_color=color.orange, text_size=size.small)
table.cell(status, 0, 8,  "NEG BELOW",   text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 8,  active_neg_node  > 0 ? str.tostring(active_neg_node)  : "-", text_color=color.orange, text_size=size.small)
table.cell(status, 0, 9,  "NEG ABOVE",   text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 9,  active_neg_above > 0 ? str.tostring(active_neg_above) : "-", text_color=color.new(color.red, 30), text_size=size.small)
table.cell(status, 0, 10, "TICK",        text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 10, use_tick ? (tick_ok ? "OK" : "BLOCKED") : "OFF", text_color=use_tick ? (tick_ok ? color.green : color.red) : color.gray, text_size=size.small)
table.cell(status, 0, 11, "SG VISIT",    text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 11, (visited_sg_2m or visited_sg_5m) ? "YES" : "NO", text_color=(visited_sg_2m or visited_sg_5m) ? color.lime : color.gray, text_size=size.small)
table.cell(status, 0, 12, "PRELIM",      text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 12, is_prelim ? "SETUP" : prelim_fired ? "ARMED" : "-", text_color=is_prelim ? color.orange : prelim_fired ? color.yellow : color.gray, text_size=size.small)
table.cell(status, 0, 13, "LONG TPs",    text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 13, long_tp1 > 0 ? str.tostring(long_tp1) + " / " + str.tostring(long_tp2) + " / " + str.tostring(long_tp3) : "-", text_color=color.lime, text_size=size.small)
table.cell(status, 0, 14, "SHORT TPs",   text_color=color.gray,   text_size=size.small)
table.cell(status, 1, 14, short_tp1 > 0 ? str.tostring(short_tp1) + " / " + str.tostring(short_tp2) + " / " + str.tostring(short_tp3) : "-", text_color=color.orange, text_size=size.small)
````

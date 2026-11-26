# GEX Framework Levels Mapper

- url: https://www.tradingview.com/script/FaNfUDo7-GEX-Framework-Levels-Mapper/
- type: indicator
- pine_id: PUB;fbc13fe3fccf40338009b04e30f77617
- version: 1.0

## Description

This indicator is to be used with GEX levels that can be adjusted throughout the day. Using an external GEX reader to identify Ceiling, Chop High, Chop Low, Floor, Control Node, etc., those levels can be inputted into the indicator and the long, chop, and short zones show up on the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("GEX Framework Levels Mapper", overlay=true, max_bars_back=500)

// ── GLOBAL SETTINGS ──────────────────────────────────────────────────────
var string GS = "── Global Style & Filters ──"
entry_session    = input.session("0955-1130", "Signal Entry Window", group=GS)
cooldown_bars    = input.int(10, "Signal Cooldown (Bars)", minval=1, group=GS)
use_htf_filter   = input.bool(true, "Require HTF Confirmation", group=GS)
conf_tf          = input.timeframe("10", "Confirmation TF", group=GS)
timezone         = input.string("America/New_York", "Timezone", group=GS)
bg_opacity       = input.int(85, "Background Opacity %", minval=0, maxval=100, group=GS)
transp           = 100 - bg_opacity

// ── TICKER MAPPING ───────────────────────────────────────────────────────
// Input slots for 12 tickers to allow manual level management.

// SLOT 1: SPY
var string T1 = "── Ticker 1 (SPY) ──"
e1 = input.bool(true, "Enable", group=T1), n1 = input.string("SPY", "Ticker Name", group=T1)
ce1 = input.float(0.0, "Ceiling", group=T1), ch1 = input.float(0.0, "Chop High", group=T1), cl1 = input.float(0.0, "Chop Low", group=T1), fl1 = input.float(0.0, "Floor", group=T1)
lt1 = input.float(0.0, "Long Trigger", group=T1), st1 = input.float(0.0, "Short Trigger", group=T1)
cn1 = input.float(0.0, "Control Node", group=T1), nb1 = input.float(0.0, "Negative Node Below", group=T1), na1 = input.float(0.0, "Negative Node Above", group=T1)

// SLOT 2: QQQ
var string T2 = "── Ticker 2 (QQQ) ──"
e2 = input.bool(true, "Enable", group=T2), n2 = input.string("QQQ", "Ticker Name", group=T2)
ce2 = input.float(0.0, "Ceiling", group=T2), ch2 = input.float(0.0, "Chop High", group=T2), cl2 = input.float(0.0, "Chop Low", group=T2), fl2 = input.float(0.0, "Floor", group=T2)
lt2 = input.float(0.0, "Long Trigger", group=T2), st2 = input.float(0.0, "Short Trigger", group=T2)
cn2 = input.float(0.0, "Control Node", group=T2), nb2 = input.float(0.0, "Negative Node Below", group=T2), na2 = input.float(0.0, "Negative Node Above", group=T2)

// SLOT 3: IWM
var string T3 = "── Ticker 3 (IWM) ──"
e3 = input.bool(true, "Enable", group=T3), n3 = input.string("IWM", "Ticker Name", group=T3)
ce3 = input.float(0.0, "Ceiling", group=T3), ch3 = input.float(0.0, "Chop High", group=T3), cl3 = input.float(0.0, "Chop Low", group=T3), fl3 = input.float(0.0, "Floor", group=T3)
lt3 = input.float(0.0, "Long Trigger", group=T3), st3 = input.float(0.0, "Short Trigger", group=T3)
cn3 = input.float(0.0, "Control Node", group=T3), nb3 = input.float(0.0, "Negative Node Below", group=T3), na3 = input.float(0.0, "Negative Node Above", group=T3)

// SLOT 4: ARKK
var string T4 = "── Ticker 4 (ARKK) ──"
e4 = input.bool(true, "Enable", group=T4), n4 = input.string("ARKK", "Ticker Name", group=T4)
ce4 = input.float(0.0, "Ceiling", group=T4), ch4 = input.float(0.0, "Chop High", group=T4), cl4 = input.float(0.0, "Chop Low", group=T4), fl4 = input.float(0.0, "Floor", group=T4)
lt4 = input.float(0.0, "Long Trigger", group=T4), st4 = input.float(0.0, "Short Trigger", group=T4)
cn4 = input.float(0.0, "Control Node", group=T4), nb4 = input.float(0.0, "Negative Node Below", group=T4), na4 = input.float(0.0, "Negative Node Above", group=T4)

// SLOT 5: MSFT
var string T5 = "── Ticker 5 (MSFT) ──"
e5 = input.bool(true, "Enable", group=T5), n5 = input.string("MSFT", "Ticker Name", group=T5)
ce5 = input.float(0.0, "Ceiling", group=T5), ch5 = input.float(0.0, "Chop High", group=T5), cl5 = input.float(0.0, "Chop Low", group=T5), fl5 = input.float(0.0, "Floor", group=T5)
lt5 = input.float(0.0, "Long Trigger", group=T5), st5 = input.float(0.0, "Short Trigger", group=T5)
cn5 = input.float(0.0, "Control Node", group=T5), nb5 = input.float(0.0, "Negative Node Below", group=T5), na5 = input.float(0.0, "Negative Node Above", group=T5)

// SLOT 6: AAPL
var string T6 = "── Ticker 6 (AAPL) ──"
e6 = input.bool(true, "Enable", group=T6), n6 = input.string("AAPL", "Ticker Name", group=T6)
ce6 = input.float(0.0, "Ceiling", group=T6), ch6 = input.float(0.0, "Chop High", group=T6), cl6 = input.float(0.0, "Chop Low", group=T6), fl6 = input.float(0.0, "Floor", group=T6)
lt6 = input.float(0.0, "Long Trigger", group=T6), st6 = input.float(0.0, "Short Trigger", group=T6)
cn6 = input.float(0.0, "Control Node", group=T6), nb6 = input.float(0.0, "Negative Node Below", group=T6), na6 = input.float(0.0, "Negative Node Above", group=T6)

// SLOT 7: GOOGL
var string T7 = "── Ticker 7 (GOOGL) ──"
e7 = input.bool(true, "Enable", group=T7), n7 = input.string("GOOGL", "Ticker Name", group=T7)
ce7 = input.float(0.0, "Ceiling", group=T7), ch7 = input.float(0.0, "Chop High", group=T7), cl7 = input.float(0.0, "Chop Low", group=T7), fl7 = input.float(0.0, "Floor", group=T7)
lt7 = input.float(0.0, "Long Trigger", group=T7), st7 = input.float(0.0, "Short Trigger", group=T7)
cn7 = input.float(0.0, "Control Node", group=T7), nb7 = input.float(0.0, "Negative Node Below", group=T7), na7 = input.float(0.0, "Negative Node Above", group=T7)

// SLOT 8: AMZN
var string T8 = "── Ticker 8 (AMZN) ──"
e8 = input.bool(true, "Enable", group=T8), n8 = input.string("AMZN", "Ticker Name", group=T8)
ce8 = input.float(0.0, "Ceiling", group=T8), ch8 = input.float(0.0, "Chop High", group=T8), cl8 = input.float(0.0, "Chop Low", group=T8), fl8 = input.float(0.0, "Floor", group=T8)
lt8 = input.float(0.0, "Long Trigger", group=T8), st8 = input.float(0.0, "Short Trigger", group=T8)
cn8 = input.float(0.0, "Control Node", group=T8), nb8 = input.float(0.0, "Negative Node Below", group=T8), na8 = input.float(0.0, "Negative Node Above", group=T8)

// SLOT 9: META
var string T9 = "── Ticker 9 (META) ──"
e9 = input.bool(true, "Enable", group=T9), n9 = input.string("META", "Ticker Name", group=T9)
ce9 = input.float(0.0, "Ceiling", group=T9), ch9 = input.float(0.0, "Chop High", group=T9), cl9 = input.float(0.0, "Chop Low", group=T9), fl9 = input.float(0.0, "Floor", group=T9)
lt9 = input.float(0.0, "Long Trigger", group=T9), st9 = input.float(0.0, "Short Trigger", group=T9)
cn9 = input.float(0.0, "Control Node", group=T9), nb9 = input.float(0.0, "Negative Node Below", group=T9), na9 = input.float(0.0, "Negative Node Above", group=T9)

// SLOT 10: NVDA
var string T10 = "── Ticker 10 (NVDA) ──"
e10 = input.bool(true, "Enable", group=T10), n10 = input.string("NVDA", "Ticker Name", group=T10)
ce10 = input.float(0.0, "Ceiling", group=T10), ch10 = input.float(0.0, "Chop High", group=T10), cl10 = input.float(0.0, "Chop Low", group=T10), fl10 = input.float(0.0, "Floor", group=T10)
lt10 = input.float(0.0, "Long Trigger", group=T10), st10 = input.float(0.0, "Short Trigger", group=T10)
cn10 = input.float(0.0, "Control Node", group=T10), nb10 = input.float(0.0, "Negative Node Below", group=T10), na10 = input.float(0.0, "Negative Node Above", group=T10)

// SLOT 11: TSLA
var string T11 = "── Ticker 11 (TSLA) ──"
e11 = input.bool(true, "Enable", group=T11), n11 = input.string("TSLA", "Ticker Name", group=T11)
ce11 = input.float(0.0, "Ceiling", group=T11), ch11 = input.float(0.0, "Chop High", group=T11), cl11 = input.float(0.0, "Chop Low", group=T11), fl11 = input.float(0.0, "Floor", group=T11)
lt11 = input.float(0.0, "Long Trigger", group=T11), st11 = input.float(0.0, "Short Trigger", group=T11)
cn11 = input.float(0.0, "Control Node", group=T11), nb11 = input.float(0.0, "Negative Node Below", group=T11), na11 = input.float(0.0, "Negative Node Above", group=T11)

// SLOT 12: Extra
var string T12 = "── Ticker 12 (Extra) ──"
e12 = input.bool(true, "Enable", group=T12), n12 = input.string("TICKER", "Ticker Name", group=T12)
ce12 = input.float(0.0, "Ceiling", group=T12), ch12 = input.float(0.0, "Chop High", group=T12), cl12 = input.float(0.0, "Chop Low", group=T12), fl12 = input.float(0.0, "Floor", group=T12)
lt12 = input.float(0.0, "Long Trigger", group=T12), st12 = input.float(0.0, "Short Trigger", group=T12)
cn12 = input.float(0.0, "Control Node", group=T12), nb12 = input.float(0.0, "Negative Node Below", group=T12), na12 = input.float(0.0, "Negative Node Above", group=T12)

// ── LEVEL SELECTION LOGIC ────────────────────────────────────────────────
var float ceiling = na
var float chop_high = na
var float chop_low = na
var float floor_level = na
var float long_trigger = na
var float short_trigger = na
var float ctrl_node = na
var float neg_node_below = na
var float neg_node_above = na

curr_ticker = syminfo.ticker
if e1 and curr_ticker == n1
    ceiling := ce1, chop_high := ch1, chop_low := cl1, floor_level := fl1, long_trigger := lt1, short_trigger := st1, ctrl_node := cn1, neg_node_below := nb1, neg_node_above := na1
else if e2 and curr_ticker == n2
    ceiling := ce2, chop_high := ch2, chop_low := cl2, floor_level := fl2, long_trigger := lt2, short_trigger := st2, ctrl_node := cn2, neg_node_below := nb2, neg_node_above := na2
else if e3 and curr_ticker == n3
    ceiling := ce3, chop_high := ch3, chop_low := cl3, floor_level := fl3, long_trigger := lt3, short_trigger := st3, ctrl_node := cn3, neg_node_below := nb3, neg_node_above := na3
else if e4 and curr_ticker == n4
    ceiling := ce4, chop_high := ch4, chop_low := cl4, floor_level := fl4, long_trigger := lt4, short_trigger := st4, ctrl_node := cn4, neg_node_below := nb4, neg_node_above := na4
else if e5 and curr_ticker == n5
    ceiling := ce5, chop_high := ch5, chop_low := cl5, floor_level := fl5, long_trigger := lt5, short_trigger := st5, ctrl_node := cn5, neg_node_below := nb5, neg_node_above := na5
else if e6 and curr_ticker == n6
    ceiling := ce6, chop_high := ch6, chop_low := cl6, floor_level := fl6, long_trigger := lt6, short_trigger := st6, ctrl_node := cn6, neg_node_below := nb6, neg_node_above := na6
else if e7 and curr_ticker == n7
    ceiling := ce7, chop_high := ch7, chop_low := cl7, floor_level := fl7, long_trigger := lt7, short_trigger := st7, ctrl_node := cn7, neg_node_below := nb7, neg_node_above := na7
else if e8 and curr_ticker == n8
    ceiling := ce8, chop_high := ch8, chop_low := cl8, floor_level := fl8, long_trigger := lt8, short_trigger := st8, ctrl_node := cn8, neg_node_below := nb8, neg_node_above := na8
else if e9 and curr_ticker == n9
    ceiling := ce9, chop_high := ch9, chop_low := cl9, floor_level := fl9, long_trigger := lt9, short_trigger := st9, ctrl_node := cn9, neg_node_below := nb9, neg_node_above := na9
else if e10 and curr_ticker == n10
    ceiling := ce10, chop_high := ch10, chop_low := cl10, floor_level := fl10, long_trigger := lt10, short_trigger := st10, ctrl_node := cn10, neg_node_below := nb10, neg_node_above := na10
else if e11 and curr_ticker == n11
    ceiling := ce11, chop_high := ch11, chop_low := cl11, floor_level := fl11, long_trigger := lt11, short_trigger := st11, ctrl_node := cn11, neg_node_below := nb11, neg_node_above := na11
else if e12 and curr_ticker == n12
    ceiling := ce12, chop_high := ch12, chop_low := cl12, floor_level := fl12, long_trigger := lt12, short_trigger := st12, ctrl_node := cn12, neg_node_below := nb12, neg_node_above := na12

// ── HTF & SIGNAL LOGIC ───────────────────────────────────────────────────
// Direct HTF Synchronization parity with strategy.
htf_last_conf = request.security(syminfo.tickerid, conf_tf, close[1], lookahead = barmerge.lookahead_on)
htf_long_ok   = htf_last_conf >= long_trigger
htf_short_ok  = htf_last_conf <= short_trigger
conf_status   = not use_htf_filter ? "OFF" : (htf_long_ok ? "Long OK" : (htf_short_ok ? "Short OK" : "Chop"))

// Detection Logic (Strict Trigger Breaks)
in_window = not na(time(timeframe.period, entry_session, timezone))
var int last_signal_bar = 0
var int active_dir = 0 

// 1. Fire on physical price break of the trigger line.
price_cross_long  = ta.crossover(close, long_trigger)
price_cross_short = ta.crossunder(close, short_trigger)

// 2. Fire on HTF confirmation if price was already across the trigger (Gaps).
htf_turn_long  = htf_long_ok and not htf_long_ok[1] and close >= long_trigger
htf_turn_short = htf_short_ok and not htf_short_ok[1] and close <= short_trigger

// Combine for final trigger signals
can_trigger_long  = (price_cross_long or htf_turn_long) and htf_long_ok and close > open
can_trigger_short = (price_cross_short or htf_turn_short) and htf_short_ok and close < open

if in_window and can_trigger_long and (bar_index - last_signal_bar >= cooldown_bars)
    label.new(bar_index, low, "Long", color=color.new(color.lime, 0), style=label.style_label_up, textcolor=color.black, size=size.small)
    last_signal_bar := bar_index
    active_dir := 1

if in_window and can_trigger_short and (bar_index - last_signal_bar >= cooldown_bars)
    label.new(bar_index, high, "Short", color=color.new(color.red, 0), style=label.style_label_down, textcolor=color.white, size=size.small)
    last_signal_bar := bar_index
    active_dir := -1

// Reset active tracking for TP lines at start of day
if ta.change(time("D", timezone)) != 0
    active_dir := 0

// TP Levels Calculation
eff_tp1_long  = (ctrl_node > long_trigger + 0.05) ? ctrl_node : (long_trigger + (ceiling - long_trigger) * 0.5)
eff_tp1_short = (neg_node_below < short_trigger - 0.05) ? neg_node_below : (short_trigger - (short_trigger - floor_level) * 0.5)

// ── VISUALS ──────────────────────────────────────────────────────────────
plot(active_dir == 1 ? eff_tp1_long : na, "Active TP1 (Long)", color=color.lime, style=plot.style_linebr, linewidth=2)
plot(active_dir == 1 ? ceiling : na, "Active TP2 (Long)", color=color.green, style=plot.style_linebr, linewidth=3)
plot(active_dir == -1 ? eff_tp1_short : na, "Active TP1 (Short)", color=color.orange, style=plot.style_linebr, linewidth=2)
plot(active_dir == -1 ? floor_level : na, "Active TP2 (Short)", color=color.red, style=plot.style_linebr, linewidth=3)

p_ceil   = plot(ceiling, "GEX Ceiling", color=color.new(#f23645, 50), style=plot.style_linebr)
p_ctrl   = plot(ctrl_node, "GEX Control Node", color=color.new(color.purple, 50), style=plot.style_circles)
p_chop_h = plot(chop_high, "GEX Chop High", color=color.new(#e7da11, 50), style=plot.style_linebr)
p_chop_l = plot(chop_low, "GEX Chop Low", color=color.new(#e7da11, 50), style=plot.style_linebr)
p_neg_b  = plot(neg_node_below, "GEX Negative Node Below", color=color.new(color.orange, 50), style=plot.style_circles)
p_neg_a  = plot(neg_node_above, "GEX Negative Node Above", color=color.new(color.orange, 50), style=plot.style_circles)
p_floor  = plot(floor_level, "GEX Floor", color=color.new(#089981, 50), style=plot.style_linebr)

// Fills
fill(p_ceil, p_chop_h, color.new(#4caf50, transp), title="Long Zone Background")
fill(p_chop_h, p_chop_l, color.new(#f23645, transp), title="Chop Zone Background")
fill(p_chop_l, p_floor, color.new(#e7da11, transp), title="Short Zone Background")

// ── STATUS TABLE ─────────────────────────────────────────────────────────
var table t_stat = table.new(position.bottom_right, 2, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 50))
if barstate.islast
    string actual_date = str.tostring(year(time, timezone)) + "-" + str.tostring(month(time, timezone)) + "-" + str.tostring(dayofmonth(time, timezone))
    table.cell(t_stat, 0, 0, "TICKER",   text_color=color.white,   text_size=size.small), table.cell(t_stat, 1, 0, syminfo.ticker, text_color=color.aqua, text_size=size.small)
    table.cell(t_stat, 0, 1, "DATE",     text_color=color.white,   text_size=size.small), table.cell(t_stat, 1, 1, actual_date, text_color=color.white, text_size=size.small)
    table.cell(t_stat, 0, 2, "HTF CONF", text_color=color.gray,    text_size=size.small), table.cell(t_stat, 1, 2, conf_status, text_color=color.white, text_size=size.small)
    table.cell(t_stat, 0, 3, "CEILING",  text_color=color.gray,    text_size=size.small), table.cell(t_stat, 1, 3, str.tostring(ceiling), text_color=color.red, text_size=size.small)
    table.cell(t_stat, 0, 4, "CHOP H/L", text_color=color.gray,    text_size=size.small), table.cell(t_stat, 1, 4, str.tostring(chop_high)+"/"+str.tostring(chop_low), text_color=color.yellow, text_size=size.small)
    table.cell(t_stat, 0, 5, "FLOOR",    text_color=color.gray,    text_size=size.small), table.cell(t_stat, 1, 5, str.tostring(floor_level), text_color=color.green, text_size=size.small)
    table.cell(t_stat, 0, 6, "CTRL NODE",text_color=color.gray,    text_size=size.small), table.cell(t_stat, 1, 6, str.tostring(ctrl_node), text_color=color.purple, text_size=size.small)
````

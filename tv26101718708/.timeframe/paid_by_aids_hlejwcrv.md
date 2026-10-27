# Paid By Aids

- url: https://www.tradingview.com/script/hLEjWcRV-Paid-By-Aids/
- type: indicator
- pine_id: PUB;e8215a3ff87f4c02b04d958b86eb8516
- version: 3.0

## Description

Uses 3 cross stratetgy KST, RSI, MACD used maximum of 2m time frame

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PaidAids
//@version=6
indicator(title="Thank Aids", shorttitle="Aids Bias", overlay=true)

// ─────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────
grp_ma   = "Trend Filter — 2-Min SMA"
grp_rsi  = "RSI (1-min)"
grp_macd = "MACD (1-min)"
grp_kst  = "KST (1-min)"
grp_vis  = "Visuals"

// 2-min SMAs (trend defined by SMA50 vs SMA200 only)
ma_fast  = input.int(50,  "Fast SMA",   minval=1, group=grp_ma)
ma_mid   = input.int(100, "Mid SMA (visual only)", minval=1, group=grp_ma)
ma_slow  = input.int(200, "Slow SMA",   minval=1, group=grp_ma)

// RSI
rsi_len     = input.int(14, "RSI Length",          minval=1, group=grp_rsi)
rsi_sma_len = input.int(14, "RSI Smoothing (SMA)", minval=1, group=grp_rsi)

// MACD
macd_fast = input.int(12, "Fast EMA",   minval=1, group=grp_macd)
macd_slow = input.int(26, "Slow EMA",   minval=1, group=grp_macd)
macd_sig  = input.int(9,  "Signal EMA", minval=1, group=grp_macd)

// KST
kst_r1 = input.int(10, "ROC 1", minval=1, group=grp_kst)
kst_r2 = input.int(15, "ROC 2", minval=1, group=grp_kst)
kst_r3 = input.int(20, "ROC 3", minval=1, group=grp_kst)
kst_r4 = input.int(30, "ROC 4", minval=1, group=grp_kst)
kst_s1 = input.int(10, "SMA 1", minval=1, group=grp_kst)
kst_s2 = input.int(10, "SMA 2", minval=1, group=grp_kst)
kst_s3 = input.int(10, "SMA 3", minval=1, group=grp_kst)
kst_s4 = input.int(15, "SMA 4", minval=1, group=grp_kst)
kst_sig = input.int(9,  "Signal SMA", minval=1, group=grp_kst)

// Visuals
buy_col    = input.color(color.teal, "Buy label color",  group=grp_vis)
sell_col   = input.color(color.red,  "Sell label color", group=grp_vis)
show_mas   = input.bool(true, "Show 2-min MAs on chart", group=grp_vis)
show_table = input.bool(true, "Show info table",         group=grp_vis)

// ─────────────────────────────────────────────────
// 2-MIN SMA TREND FILTER
// Trend defined by SMA50 vs SMA200 position only
// SMA100 is plotted for visual reference only
// Bull bias: SMA50 > SMA200
// Bear bias: SMA50 < SMA200
// ─────────────────────────────────────────────────
sma50_2m  = request.security(syminfo.tickerid, "2", ta.sma(close, ma_fast), lookahead=barmerge.lookahead_off)
sma100_2m = request.security(syminfo.tickerid, "2", ta.sma(close, ma_mid),  lookahead=barmerge.lookahead_off)
sma200_2m = request.security(syminfo.tickerid, "2", ta.sma(close, ma_slow), lookahead=barmerge.lookahead_off)

trend_bull = sma50_2m > sma200_2m   // SMA50 above SMA200 = bull bias
trend_bear = sma50_2m < sma200_2m   // SMA50 below SMA200 = bear bias

// Plot all 3 MAs (100 is visual reference only, not used in logic)
plot(show_mas ? sma50_2m  : na, "SMA 50 (2m)",       color=color.new(color.yellow, 20), linewidth=1)
plot(show_mas ? sma100_2m : na, "SMA 100 (2m) ref",  color=color.new(color.orange, 40), linewidth=1)
plot(show_mas ? sma200_2m : na, "SMA 200 (2m)",      color=color.new(color.red,    20), linewidth=2)

// ─────────────────────────────────────────────────
// RSI — logarithmic source, SMA(14) smoothing
// Trigger: RSI crosses its SMA in either direction
// No 50-level gate — cross alone is the signal
// ─────────────────────────────────────────────────
log_close = math.log(close)
rsi_val   = ta.rsi(log_close, rsi_len)
rsi_sma   = ta.sma(rsi_val, rsi_sma_len)

rsi_bull_live = rsi_val > rsi_sma   // RSI above its SMA
rsi_bear_live = rsi_val < rsi_sma   // RSI below its SMA

// Cross events (for barssince display in table)
rsi_x_bull = ta.crossover(rsi_val, rsi_sma)
rsi_x_bear = ta.crossunder(rsi_val, rsi_sma)

// ─────────────────────────────────────────────────
// MACD — logarithmic source, EMA 12/26/9
// Trigger: MACD line crosses signal line
// No zero-level gate
// ─────────────────────────────────────────────────
fast_ema      = ta.ema(log_close, macd_fast)
slow_ema      = ta.ema(log_close, macd_slow)
macd_line     = fast_ema - slow_ema
macd_sig_line = ta.ema(macd_line, macd_sig)

macd_bull_live = macd_line > macd_sig_line
macd_bear_live = macd_line < macd_sig_line

macd_x_bull = ta.crossover(macd_line, macd_sig_line)
macd_x_bear = ta.crossunder(macd_line, macd_sig_line)

// ─────────────────────────────────────────────────
// KST — logarithmic source, ROC/SMA settings
// Bull: KST crosses above signal line WHILE below zero
// Bear: KST crosses below signal line WHILE above zero
// ─────────────────────────────────────────────────
roc(src, len) => 100 * (src - src[len]) / src[len]

kst_val      = ta.sma(roc(log_close, kst_r1), kst_s1) * 1 +
               ta.sma(roc(log_close, kst_r2), kst_s2) * 2 +
               ta.sma(roc(log_close, kst_r3), kst_s3) * 3 +
               ta.sma(roc(log_close, kst_r4), kst_s4) * 4
kst_sig_line = ta.sma(kst_val, kst_sig)

kst_bull_live = kst_val > kst_sig_line and kst_val < 0   // above signal, below zero
kst_bear_live = kst_val < kst_sig_line and kst_val > 0   // below signal, above zero

kst_x_bull = ta.crossover(kst_val, kst_sig_line)  and kst_val < 0
kst_x_bear = ta.crossunder(kst_val, kst_sig_line) and kst_val > 0

// ─────────────────────────────────────────────────
// CONFLUENCE — all 3 must be in live state
// ─────────────────────────────────────────────────
all_bull_live = trend_bull and rsi_bull_live and macd_bull_live and kst_bull_live
all_bear_live = trend_bear and rsi_bear_live and macd_bear_live and kst_bear_live

// ─────────────────────────────────────────────────
// ONE-SHOT SIGNAL LOGIC
// Label fires ONCE when all 3 first align
// Does NOT repeat until conditions fully reset
// (all 3 drop) and then realign again
//
// var bool tracks whether a signal is already
// "active" — suppresses repeats until reset
// ─────────────────────────────────────────────────
var bool bull_active = false
var bool bear_active = false

// Reset: conditions no longer hold
if not all_bull_live
    bull_active := false
if not all_bear_live
    bear_active := false

// Fire once on the first bar all 3 align
buy_signal  = all_bull_live  and not bull_active
sell_signal = all_bear_live  and not bear_active

// Mark as active so label doesn't repeat
if buy_signal
    bull_active := true
if sell_signal
    bear_active := true

// ─────────────────────────────────────────────────
// BUY / SELL LABELS — fires once per signal
// ─────────────────────────────────────────────────
plotshape(buy_signal,
     title     = "BUY",
     style     = shape.labelup,
     location  = location.belowbar,
     color     = buy_col,
     textcolor = color.white,
     text      = "BUY",
     size      = size.normal)

plotshape(sell_signal,
     title     = "SELL",
     style     = shape.labeldown,
     location  = location.abovebar,
     color     = sell_col,
     textcolor = color.white,
     text      = "SELL",
     size      = size.normal)

// ─────────────────────────────────────────────────
// BAR COLOR — tints while signal conditions hold
// (so you can see how long the window lasts)
// ─────────────────────────────────────────────────
barcolor(all_bull_live ? color.new(buy_col,  70) : na, title="Bull active tint")
barcolor(all_bear_live ? color.new(sell_col, 70) : na, title="Bear active tint")

// ─────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 8,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray,  50),
     border_width = 1,
     frame_color  = color.new(color.gray,  50),
     frame_width  = 1)

if show_table and barstate.islast

    // Header
    table.cell(tbl, 0, 0, "Component",   text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "Status",      text_color=color.gray,  text_size=size.small, text_halign=text.align_right)

    // 2-min trend (SMA50 vs SMA200)
    ma_str = trend_bull ? "BULL ↑ 50>200" : trend_bear ? "BEAR ↓ 50<200" : "— flat"
    ma_col = trend_bull ? color.teal : color.red
    table.cell(tbl, 0, 1, "2m Trend",    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, ma_str,        text_color=ma_col,       text_size=size.small, text_halign=text.align_right)

    // RSI
    rsi_str = rsi_bull_live ? "↑ above SMA" : "↓ below SMA"
    rsi_col = rsi_bull_live ? color.teal : color.red
    table.cell(tbl, 0, 2, "RSI (log)",   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(math.round(rsi_val,1)) + " / " + rsi_str,
         text_color=rsi_col, text_size=size.small, text_halign=text.align_right)

    // MACD
    macd_str = macd_bull_live ? "↑ above sig" : "↓ below sig"
    macd_col = macd_bull_live ? color.teal : color.red
    table.cell(tbl, 0, 3, "MACD (log)",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(math.round(macd_line,5)) + " / " + macd_str,
         text_color=macd_col, text_size=size.small, text_halign=text.align_right)

    // KST
    kst_str = kst_bull_live ? "↑ X sig (<0)" : kst_bear_live ? "↓ X sig (>0)" : "— not triggered"
    kst_col = kst_bull_live ? color.teal : kst_bear_live ? color.red : color.gray
    table.cell(tbl, 0, 4, "KST (log)",   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(math.round(kst_val,3)) + " / " + kst_str,
         text_color=kst_col, text_size=size.small, text_halign=text.align_right)

    // Confluence progress
    bull_prog = (rsi_bull_live?1:0) + (macd_bull_live?1:0) + (kst_bull_live?1:0)
    bear_prog = (rsi_bear_live?1:0) + (macd_bear_live?1:0) + (kst_bear_live?1:0)
    prog      = math.max(bull_prog, bear_prog)
    prog_col  = prog==3 ? color.teal : prog==2 ? color.orange : color.gray
    table.cell(tbl, 0, 5, "Progress",    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(prog) + " / 3 live",
         text_color=prog_col, text_size=size.small, text_halign=text.align_right)

    // Active state
    act_str = bull_active ? "BULL holding" : bear_active ? "BEAR holding" : "— waiting"
    act_col = bull_active ? color.teal : bear_active ? color.red : color.gray
    table.cell(tbl, 0, 6, "Active",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 6, act_str,       text_color=act_col,      text_size=size.small, text_halign=text.align_right)

    // Signal
    sig_str = buy_signal ? "▲ BUY fired" : sell_signal ? "▼ SELL fired" : "— no new signal"
    sig_col = buy_signal ? color.teal : sell_signal ? color.red : color.gray
    table.cell(tbl, 0, 7, "Signal",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 7, sig_str,       text_color=sig_col,      text_size=size.small, text_halign=text.align_right)

// ─────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────
alertcondition(buy_signal,
     title   = "BUY — Full Confluence",
     message = '{"ticker":"{{ticker}}","signal":"buy","price":"{{close}}","time":"{{time}}","interval":"{{interval}}"}')

alertcondition(sell_signal,
     title   = "SELL — Full Confluence",
     message = '{"ticker":"{{ticker}}","signal":"sell","price":"{{close}}","time":"{{time}}","interval":"{{interval}}"}')

alertcondition(buy_signal or sell_signal,
     title   = "ANY — Full Confluence",
     message = '{"ticker":"{{ticker}}","signal":"{{buy_signal ? buy : sell}}","price":"{{close}}","time":"{{time}}","interval":"{{interval}}"}')

//@version=6
plot(close)
````

# NQ Unified (VIX + HTF TRF)

- url: https://www.tradingview.com/script/hLuK7eRV-NQ-Unified-VIX-HTF-TRF/
- type: indicator
- pine_id: PUB;d4b29aac12634275b2d9a02353ebf7be
- version: 1.0

## Description

This is the NQ system I actually trade off of, on the 1-minute during the cash session. The trigger is a Twin Range Filter cross, but it only counts when the regime agrees: VIX dropping on the 15-minute means I want longs, VIX spiking means shorts, and the higher timeframes (15m and up) have to point the same way. When it all stacks it prints a long on the up-cross or a short on the down-cross, grades the setup $ to $$$ by how much confluence is behind it, and drops a 2.2x ATR stop from entry. Treat the prints as a checklist, not a robot. You still pull the trigger. Honest caveat: it reads VIX and the higher timeframes with lookahead, so the history looks a touch cleaner than real time. Run it on bar replay before you lean on it.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ Unified v4 - VIX-gated momentum system
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  An intraday framework for index futures, tuned on Nasdaq-100 futures
//  (1-minute, U.S. cash session). It fuses three ideas into one signal
//  engine: a Twin Range Filter momentum cross on the trading timeframe, a
//  regime gate from the 15-minute VIX (falling VIX favors longs, a VIX spike
//  favors shorts), and higher-timeframe trend agreement (15m and up). A long
//  is flagged when VIX is falling, the higher timeframe is up, and price
//  crosses up through the Twin Range Filter; a short is the mirror on a VIX
//  spike. Each signal is graded for confluence ($ to $$$) and a 2.2x ATR stop
//  is drawn from entry. Use the flagged bars as a checklist for a
//  discretionary entry, not as auto-trades. Limitation: VIX and higher-
//  timeframe states are read with request.security using lookahead, so
//  historical display can sit earlier than the data was actually available —
//  confirm on bar replay before trading.
// ============================================================================
//
//@version=6
indicator('NQ Unified v4', shorttitle = 'NQ v4', overlay = true, max_labels_count = 500, max_lines_count = 500)

// =============================================================================
// NQ UNIFIED v4 — Simplified Long/Short System
// =============================================================================
// LONGS:  VIX 15m DOWN + NQ 15m UP (min). 1m TRF cross up = entry.
//         $$$ if NY VWAP below entry + more HTF alignment.
// SHORTS: VIX 15m UP (spiking) + 1m TRF cross down = entry.
//         Exit on VIX flip back down.
// STOP:   2.2x ATR from entry (both sides).
// TP:     Fixed R:R from stop distance.
// OE:     Over-extension lines → move stop to breakeven.
// SESSION: 9:30–12:00 ET only.
// =============================================================================

// === INPUTS ===
grp_trf = 'Twin Range Filter'
trf_per1 = input.int(27, 'TRF Fast Period', minval = 1, group = grp_trf)
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval = 0.1, group = grp_trf)
trf_per2 = input.int(55, 'TRF Slow Period', minval = 1, group = grp_trf)
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval = 0.1, group = grp_trf)

grp_vix = 'VIX / HTF'
vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol', group = grp_vix)

grp_risk = 'Risk Management'
sl_atr_len = input.int(14, 'ATR Period', minval = 1, group = grp_risk)
sl_atr_mult = input.float(2.2, 'Stop ATR Multiplier', minval = 0.5, step = 0.1, group = grp_risk)
tp_rr = input.float(2.0, 'TP R:R Ratio', minval = 0.5, step = 0.1, group = grp_risk)

grp_oe = 'Over-Extension'
oe_ext_ratio = input.float(1.3414, 'Extension Ratio', minval = 1.0, step = 0.01, group = grp_oe)

grp_disp = 'Display'
show_vwap = input.bool(true, 'NY Session VWAP', group = grp_disp)
show_trf = input.bool(true, '1m TRF Line', group = grp_disp)
show_oe = input.bool(true, 'Over-Extension Lines', group = grp_disp)
show_sl_tp = input.bool(true, 'SL / TP Levels', group = grp_disp)
show_table = input.bool(true, 'HTF Bias Table', group = grp_disp)
table_pos = input.string('top_right', 'Table Position', options = ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = grp_disp)

TZ = 'America/New_York'

// =============================================================================
// TRF CORE
// =============================================================================

f_smoothrng(x, t, m) =>
    wper = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

f_rngfilt(x, r) =>
    v = x
    v := x > nz(v[1]) ? x - r < nz(v[1]) ? nz(v[1]) : x - r : x + r > nz(v[1]) ? nz(v[1]) : x + r
    v

f_trf(src, p1, m1, p2, m2) =>
    smrng = (f_smoothrng(src, p1, m1) + f_smoothrng(src, p2, m2)) / 2
    filt = f_rngfilt(src, smrng)
    fub = 0.0
    fub := filt + smrng < nz(fub[1]) or close[1] > nz(fub[1]) ? filt + smrng : nz(fub[1])
    flb = 0.0
    flb := filt - smrng > nz(flb[1]) or close[1] < nz(flb[1]) ? filt - smrng : nz(flb[1])
    trf = 0.0
    trf := nz(trf[1]) == fub[1] and close <= fub ? fub : nz(trf[1]) == fub[1] and close >= fub ? flb : nz(trf[1]) == flb[1] and close >= flb ? flb : nz(trf[1]) == flb[1] and close <= flb ? fub : fub
    [trf, ta.crossover(close, trf), ta.crossunder(close, trf)]

f_bull_htf() =>
    [l, _cu, _cd] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close[1] > l[1]

f_bull_now() =>
    [l, _cu2, _cd2] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close > l

// =============================================================================
// 1M TRF (current chart)
// =============================================================================

[trf_1m, trf_cross_up, trf_cross_down] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
trf_bull = close > trf_1m

// =============================================================================
// MULTI-TF STATES
// =============================================================================

nq_15m = request.security(syminfo.tickerid, '15', f_bull_htf(), lookahead = barmerge.lookahead_on)
nq_1h = request.security(syminfo.tickerid, '60', f_bull_htf(), lookahead = barmerge.lookahead_on)
nq_4h = request.security(syminfo.tickerid, '240', f_bull_htf(), lookahead = barmerge.lookahead_on)
nq_d = request.security(syminfo.tickerid, 'D', f_bull_htf(), lookahead = barmerge.lookahead_on)

vix_15m = request.security(vix_symbol, '15', f_bull_now(), lookahead = barmerge.lookahead_on)
vix_1h = request.security(vix_symbol, '60', f_bull_now(), lookahead = barmerge.lookahead_on)
vix_4h = request.security(vix_symbol, '240', f_bull_now(), lookahead = barmerge.lookahead_on)
vix_d = request.security(vix_symbol, 'D', f_bull_now(), lookahead = barmerge.lookahead_on)

vix_15m_down = not vix_15m // VIX below its 15m TRF = favorable for longs
vix_15m_up = vix_15m // VIX above its 15m TRF = spiking = short bias

// =============================================================================
// SESSION FILTER (9:30–12:00 ET)
// =============================================================================

ny_h = hour(time, TZ)
ny_m = minute(time, TZ)

in_session = (ny_h == 9 and ny_m >= 30 or ny_h >= 10 and ny_h < 12) and not(ny_h == 12 and ny_m > 0)

// =============================================================================
// NY SESSION VWAP (resets at 9:30)
// =============================================================================

is_rth_start = ny_h == 9 and ny_m >= 30 and not(ny_h[1] == 9 and ny_m[1] >= 30 or ny_h[1] >= 10)

var float ny_sum_vp = 0.0
var float ny_sum_v = 0.0
var float ny_vwap = na

if is_rth_start
    ny_sum_vp := 0.0
    ny_sum_v := 0.0
    ny_vwap := na
    ny_vwap

in_rth = ny_h == 9 and ny_m >= 30 or ny_h >= 10 and ny_h < 16
if in_rth and volume > 0
    ny_sum_vp := ny_sum_vp + volume * hlc3
    ny_sum_v := ny_sum_v + volume
    ny_vwap := ny_sum_vp / ny_sum_v
    ny_vwap

// =============================================================================
// OVER-EXTENSION LINES
// =============================================================================

prevDayHigh = request.security(syminfo.tickerid, 'D', high[1], lookahead = barmerge.lookahead_on)
prevDayLow = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_on)
prevDayRange = prevDayHigh - prevDayLow

pdUpperExt = prevDayLow + prevDayRange * oe_ext_ratio
pdLowerExt = prevDayLow + prevDayRange * (1 - oe_ext_ratio)

// Opening Range (first 15 min)
or_open_ts = timestamp(TZ, year, month, dayofmonth, 9, 30, 0)
or_close_ts = timestamp(TZ, year, month, dayofmonth, 9, 45, 0)

var float orHigh = na
var float orLow = na
var bool orDone = false

is_new_day = ta.change(time('D')) != 0
if is_new_day
    orHigh := na
    orLow := na
    orDone := false
    orDone

in_or = time >= or_open_ts and time < or_close_ts
if in_or
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)
    orLow

if time >= or_close_ts and not orDone
    orDone := true
    orDone

orRange = orHigh - orLow
orUpperExt = orDone ? orLow + orRange * oe_ext_ratio : na
orLowerExt = orDone ? orLow + orRange * (1 - oe_ext_ratio) : na

// Final OE lines: most extreme of PD and OR extensions
upperOE = orDone ? math.max(pdUpperExt, orUpperExt) : pdUpperExt
lowerOE = orDone ? math.min(pdLowerExt, orLowerExt) : pdLowerExt

// =============================================================================
// ATR & LEVELS
// =============================================================================

raw_atr = ta.atr(sl_atr_len)
stop_pts = raw_atr * sl_atr_mult
tp_pts = stop_pts * tp_rr

// =============================================================================
// CONFLUENCE SCORING ($$$)
// =============================================================================

// For longs: count how many HTF timeframes agree (NQ bull)
nq_bull_count = (nq_15m ? 1 : 0) + (nq_1h ? 1 : 0) + (nq_4h ? 1 : 0) + (nq_d ? 1 : 0)

// VWAP below entry adds a $
vwap_below = not na(ny_vwap) and ny_vwap < close

// Confluence: base $ from NQ 15m required, extras from more TFs + VWAP
long_dollars = (nq_15m ? 1 : 0) + (nq_1h ? 1 : 0) + (nq_4h ? 1 : 0) + (nq_d ? 1 : 0) + (vwap_below ? 1 : 0)

f_dollar_str(count) =>
    count >= 5 ? '$$$$$' : count >= 4 ? '$$$$' : count >= 3 ? '$$$' : count >= 2 ? '$$' : '$'

// =============================================================================
// ENTRY SIGNALS
// =============================================================================

// LONG: VIX 15m down + NQ 15m up + 1m TRF cross up + in session
long_signal = trf_cross_up and barstate.isconfirmed and vix_15m_down and nq_15m and in_session

// SHORT: VIX 15m up (spiking) + 1m TRF cross down + in session
short_signal = trf_cross_down and barstate.isconfirmed and vix_15m_up and in_session

// =============================================================================
// TRADE STATE TRACKING (for SL/TP/BE visualization)
// =============================================================================

var int trade_dir = 0 // 1 = long, -1 = short, 0 = flat
var float trade_entry = na
var float trade_sl = na
var float trade_tp = na
var bool trade_be = false // moved to breakeven?

// Reset at session boundaries
if is_new_day or ny_h >= 12 and trade_dir != 0
    trade_dir := 0
    trade_entry := na
    trade_sl := na
    trade_tp := na
    trade_be := false
    trade_be

// New entries (only if flat)
if trade_dir == 0
    if long_signal
        trade_dir := 1
        trade_entry := close
        trade_sl := close - stop_pts
        trade_tp := close + tp_pts
        trade_be := false
        trade_be
    else if short_signal
        trade_dir := -1
        trade_entry := close
        trade_sl := close + stop_pts
        trade_tp := close - tp_pts
        trade_be := false
        trade_be

// === OVER-EXTENSION → BREAKEVEN ===
if trade_dir == 1 and not trade_be and not na(upperOE)
    if close >= upperOE
        trade_sl := trade_entry
        trade_be := true
        trade_be

if trade_dir == -1 and not trade_be and not na(lowerOE)
    if close <= lowerOE
        trade_sl := trade_entry
        trade_be := true
        trade_be

// === EXIT CONDITIONS ===
// Long: hit SL or TP
if trade_dir == 1
    if low <= trade_sl or high >= trade_tp
        trade_dir := 0
        trade_entry := na
        trade_sl := na
        trade_tp := na
        trade_be := false
        trade_be

// Short: hit SL or TP, OR VIX flips back down (exit)
if trade_dir == -1
    if high >= trade_sl or low <= trade_tp
        trade_dir := 0
        trade_entry := na
        trade_sl := na
        trade_tp := na
        trade_be := false
        trade_be
    else if vix_15m_down // VIX stopped spiking → close short
        trade_dir := 0
        trade_entry := na
        trade_sl := na
        trade_tp := na
        trade_be := false
        trade_be

// =============================================================================
// PLOTS
// =============================================================================

// TRF Line
trf_color = trf_bull ? color.new(#42A5F5, 0) : color.new(#EF5350, 0)
plot(show_trf ? trf_1m : na, '1m TRF', color = trf_color, linewidth = 2)

// NY VWAP
plot(show_vwap and in_rth ? ny_vwap : na, 'NY VWAP', color = color.new(#1565C0, 0), linewidth = 2)

// Over-Extension Lines
plot(show_oe ? upperOE : na, 'Upper OE', color = color.new(#EF5350, 40), linewidth = 2, style = plot.style_stepline)
plot(show_oe ? lowerOE : na, 'Lower OE', color = color.new(#66BB6A, 40), linewidth = 2, style = plot.style_stepline)

// SL / TP while in trade
plot(show_sl_tp and trade_dir != 0 ? trade_sl : na, 'Stop Loss', color = color.new(#EF5350, 0), linewidth = 1, style = plot.style_linebr)
plot(show_sl_tp and trade_dir != 0 ? trade_tp : na, 'Take Profit', color = color.new(#66BB6A, 0), linewidth = 1, style = plot.style_linebr)
plot(show_sl_tp and trade_dir != 0 ? trade_entry : na, 'Entry', color = color.new(#FFFFFF, 60), linewidth = 1, style = plot.style_linebr)

// =============================================================================
// SIGNAL LABELS
// =============================================================================

if long_signal and trade_dir == 1
    lbl_txt = 'LONG ' + f_dollar_str(long_dollars)
    label.new(bar_index, low, lbl_txt, color = color.new(#1565C0, 0), textcolor = color.white, style = label.style_label_up, size = size.small)

if short_signal and trade_dir == -1
    label.new(bar_index, high, 'SHORT', color = color.new(#B71C1C, 0), textcolor = color.white, style = label.style_label_down, size = size.small)

// BE label when OE triggers it
if trade_be and not trade_be[1]
    be_y = trade_dir == 1 ? low : high
    be_style = trade_dir == 1 ? label.style_label_up : label.style_label_down
    label.new(bar_index, be_y, 'BE', color = color.new(#FF6F00, 0), textcolor = color.white, style = be_style, size = size.tiny)

// =============================================================================
// HTF BIAS TABLE
// =============================================================================

pos_lookup(s) =>
    s == 'top_left' ? position.top_left : s == 'top_center' ? position.top_center : s == 'top_right' ? position.top_right : s == 'middle_left' ? position.middle_left : s == 'middle_right' ? position.middle_right : s == 'bottom_left' ? position.bottom_left : s == 'bottom_center' ? position.bottom_center : position.bottom_right

var table tbl = table.new(pos_lookup(table_pos), 3, 9, bgcolor = color.new(#1A1A1A, 0), border_width = 1, frame_color = color.new(#000000, 0))

c_white = color.white
c_hdr = color.new(#2C2C2C, 0)
c_up = color.new(#42A5F5, 0)
c_dn = color.new(#EF5350, 0)
c_gray = color.new(#78909C, 0)

if barstate.islast and show_table
    table.cell(tbl, 0, 0, 'TF', text_color = c_white, bgcolor = c_hdr, text_size = size.tiny)
    table.cell(tbl, 1, 0, 'NQ', text_color = c_white, bgcolor = c_hdr, text_size = size.tiny)
    table.cell(tbl, 2, 0, 'VIX', text_color = c_white, bgcolor = c_hdr, text_size = size.tiny)

    table.cell(tbl, 0, 1, '15m', text_color = c_white, text_size = size.tiny)
    table.cell(tbl, 1, 1, nq_15m ? '▲' : '▼', text_color = nq_15m ? c_up : c_dn, text_size = size.small)
    table.cell(tbl, 2, 1, vix_15m ? '▲' : '▼', text_color = vix_15m ? c_up : c_dn, text_size = size.small)

    table.cell(tbl, 0, 2, '1h', text_color = c_white, text_size = size.tiny)
    table.cell(tbl, 1, 2, nq_1h ? '▲' : '▼', text_color = nq_1h ? c_up : c_dn, text_size = size.small)
    table.cell(tbl, 2, 2, vix_1h ? '▲' : '▼', text_color = vix_1h ? c_up : c_dn, text_size = size.small)

    table.cell(tbl, 0, 3, '4h', text_color = c_white, text_size = size.tiny)
    table.cell(tbl, 1, 3, nq_4h ? '▲' : '▼', text_color = nq_4h ? c_up : c_dn, text_size = size.small)
    table.cell(tbl, 2, 3, vix_4h ? '▲' : '▼', text_color = vix_4h ? c_up : c_dn, text_size = size.small)

    table.cell(tbl, 0, 4, 'D', text_color = c_white, text_size = size.tiny)
    table.cell(tbl, 1, 4, nq_d ? '▲' : '▼', text_color = nq_d ? c_up : c_dn, text_size = size.small)
    table.cell(tbl, 2, 4, vix_d ? '▲' : '▼', text_color = vix_d ? c_up : c_dn, text_size = size.small)

    // Separator
    table.cell(tbl, 0, 5, '', bgcolor = c_hdr)
    table.cell(tbl, 1, 5, '', bgcolor = c_hdr)
    table.cell(tbl, 2, 5, '', bgcolor = c_hdr)

    // Stop distance
    table.cell(tbl, 0, 6, 'SL', text_color = c_white, text_size = size.tiny)
    table.cell(tbl, 1, 6, str.tostring(stop_pts, format.mintick), text_color = c_dn, text_size = size.small)
    table.cell(tbl, 2, 6, 'pts', text_color = c_gray, text_size = size.tiny)

    // Confluence
    table.cell(tbl, 0, 7, 'CONF', text_color = c_white, text_size = size.tiny)
    conf_txt = vix_15m_down and nq_15m ? f_dollar_str(long_dollars) : vix_15m_up ? 'SHORT' : '—'
    conf_clr = vix_15m_down and nq_15m ? color.new(#4CAF50, 0) : vix_15m_up ? c_dn : c_gray
    table.cell(tbl, 1, 7, conf_txt, text_color = conf_clr, text_size = size.small)
    table.cell(tbl, 2, 7, '', text_size = size.tiny)

    // Trade state
    state_txt = trade_dir == 1 ? trade_be ? 'LONG BE' : 'LONG' : trade_dir == -1 ? trade_be ? 'SHORT BE' : 'SHORT' : 'FLAT'
    state_clr = trade_dir == 1 ? c_up : trade_dir == -1 ? c_dn : c_gray
    table.cell(tbl, 0, 8, '', bgcolor = c_hdr)
    table.cell(tbl, 1, 8, state_txt, text_color = state_clr, bgcolor = c_hdr, text_size = size.tiny)
    table.cell(tbl, 2, 8, '', bgcolor = c_hdr)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(long_signal, title = 'Long Signal', message = 'NQ v4: LONG — VIX down, NQ 15m bull, TRF cross up')
alertcondition(short_signal, title = 'Short Signal', message = 'NQ v4: SHORT — VIX spiking, TRF cross down')
alertcondition(trade_be and not trade_be[1], title = 'Moved to BE', message = 'NQ v4: Stop moved to breakeven (OE hit)')
````

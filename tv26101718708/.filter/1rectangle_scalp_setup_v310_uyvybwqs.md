# 1-Rectangle Scalp Setup [v3.10]

- url: https://www.tradingview.com/script/uyVybWqS-1-Rectangle-Scalp-Setup-v3-10/
- type: indicator
- pine_id: PUB;154ce1a9c3404ce7b060319f7ea5145f
- version: 1.0

## Description

1-Rectangle Scalp Setup solid strtegy not very well tested

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © snirk

//@version=6
indicator('1-Rectangle Scalp Setup [v3.10]', overlay = true, max_boxes_count = 50, max_lines_count = 200, max_labels_count = 200)

// ── SETTINGS ─────────────────────────────
G_SETUP = 'Rectangle Setup'
G_RISK = 'Risk & Targets'
G_ACCUM = 'Accumulation'
G_VIEW = 'Which setups to show'
G_REENTRY = 'Re-entry'
G_SESSION = 'Session Filter (UTC+3)'
G_DISPLAY = 'Display'
G_COLORS = 'Colors'

// Rectangle Setup
consol_bars = input.int(8, 'Min bars to form rectangle', minval = 4, maxval = 30, group = G_SETUP)
range_pct = input.float(0.25, 'Max range size (% of price)', minval = 0.05, maxval = 2.0, step = 0.05, group = G_SETUP)
use_ha = input.bool(true, 'Use Heikin Ashi source', group = G_SETUP, tooltip = "Computes Heikin Ashi candles internally so all logic (signals, accumulation, levels, stats) uses HA regardless of the chart's candle type. Turn off to use the chart's own candles.")

// Risk & Targets
sl_buf_mode = input.string('% of price', 'SL buffer basis', options = ['% of price', '% of rectangle'], group = G_RISK, tooltip = '% of price: buffer = price × value%. % of rectangle: buffer = rectangle height × value%.')
sl_buffer_pct = input.float(0.05, 'SL buffer value (%)', minval = 0.01, maxval = 50.0, step = 0.01, group = G_RISK, tooltip = 'Interpreted per the SL buffer basis above. Try ~0.05 for % of price, ~5–10 for % of rectangle.')
rr_ratio = input.float(2.0, 'TP1 Risk:Reward', minval = 0.5, maxval = 5.0, step = 0.5, group = G_RISK)
tp2_ratio = input.float(3.0, 'TP2 Risk:Reward', minval = 0.5, maxval = 10.0, step = 0.5, group = G_RISK)

// Accumulation
accum_src = input.string('Wick', 'Accumulation source', options = ['Wick', 'Body', 'RSI', 'TSI', 'CMF', 'Combined'], group = G_ACCUM, tooltip = 'Wick: lower vs upper wicks. Body: bull body size vs bear body size. RSI: bull bars add RSI, bear bars subtract RSI. TSI: True Strength Index momentum. CMF: Chaikin Money Flow (needs volume). Combined: average of all sources (CMF included only when volume exists).')
rsi_len = input.int(14, 'RSI length (RSI mode)', minval = 2, maxval = 50, group = G_ACCUM)
tsi_long = input.int(25, 'TSI long length (TSI mode)', minval = 2, maxval = 100, group = G_ACCUM)
tsi_short = input.int(13, 'TSI short length (TSI mode)', minval = 2, maxval = 100, group = G_ACCUM)
neutral_thr = input.float(5.0, 'Neutral threshold (%)', minval = 0.0, maxval = 25.0, step = 1.0, group = G_ACCUM, tooltip = 'Below this %, accumulation is treated as neutral (grey).')
extreme_thr = input.float(70.0, 'Extreme threshold (%)', minval = 25.0, maxval = 100.0, step = 5.0, group = G_ACCUM, tooltip = 'At or above this %, accumulation is flagged as EXTREME (★, larger tag). Keep above the neutral threshold.')

// Which setups to show
view_extreme = input.bool(true, 'View: Extreme band', group = G_VIEW)
view_normal = input.bool(true, 'View: Normal band', group = G_VIEW)
view_neutral = input.bool(true, 'View: Neutral band', group = G_VIEW)
view_only_conflict = input.bool(false, 'View: Only conflicts (Accum ≠ Trend)', group = G_VIEW, tooltip = 'When on, only setups where accumulation opposes the trade direction are shown.')

// Re-entry
show_reentry = input.bool(true, 'Show re-entry line', group = G_REENTRY)
reentry_bars = input.int(5, 'Re-entry line length (bars)', minval = 1, maxval = 50, group = G_REENTRY)
reentry_loc = input.float(50.0, 'Re-entry location (% Entry→SL)', minval = 0.0, maxval = 100.0, step = 5.0, group = G_REENTRY, tooltip = '0% = at Entry, 100% = at SL. Places the pullback re-entry between the entry and stop.')

// Session Filter (times interpreted in UTC+3)
use_session = input.bool(false, 'Only allow signals inside session', group = G_SESSION)
sess = input.session('0000-2359', 'Active session', group = G_SESSION, tooltip = 'Signals only fire inside this time window. Times are interpreted in UTC+3.')
sess_days = input.string('All days', 'Days', options = ['All days', 'Mon-Fri'], group = G_SESSION)
shade_session = input.bool(false, 'Shade out-of-session background', group = G_SESSION)

// Display
show_rect = input.bool(true, 'Show rectangle zones', group = G_DISPLAY)
show_label = input.bool(true, 'Show entry labels', group = G_DISPLAY)
show_sl_tp = input.bool(true, 'Show Entry / SL / TP levels', group = G_DISPLAY)
level_bars = input.int(5, 'Level line length (bars)', minval = 1, maxval = 50, group = G_DISPLAY)
show_strength = input.bool(true, 'Show accumulation strength tag', group = G_DISPLAY)
show_conflict = input.bool(true, 'Mark accum ≠ trend conflict', group = G_DISPLAY)
show_table = input.bool(true, 'Show stats table', group = G_DISPLAY)
table_pos = input.string('Top Right', 'Stats table position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = G_DISPLAY)
table_size = input.string('Small', 'Stats table size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = G_DISPLAY)

// Colors
col_buy_zone = input.color(color.teal, 'Buy zone color', group = G_COLORS)
col_sell_zone = input.color(color.red, 'Sell zone color', group = G_COLORS)

// ── COLOURS ──────────────────────────────
C_BUY = color.new(color.lime, 0)
C_SELL = color.new(color.red, 0)
C_ENTRY = color.new(color.gray, 0)
C_SL = color.new(color.orange, 0)
C_TP = color.new(color.aqua, 0)
C_TP2 = color.new(color.green, 0)
C_RE = color.new(color.yellow, 0)
C_WARN = color.new(color.fuchsia, 0)

// Draw a horizontal level: solid line + right-side price label, extended N bars
f_level(_price, _txt, _col, _bars) =>
    line.new(bar_index, _price, bar_index + _bars, _price, color = _col, style = line.style_solid, width = 1)
    label.new(bar_index + _bars, _price, _txt + ' ' + str.tostring(_price, '#.#####'), yloc = yloc.price, style = label.style_label_left, color = _col, textcolor = color.white, size = size.small)

// Percentage of a count relative to a total, as a display string
f_pct(_n, _tot) =>
    _tot > 0 ? str.tostring(math.round(_n / _tot * 100)) + '%' : '–'

// ── SOURCE (Heikin Ashi optional, computed regardless of chart type) ──
ha_tkr = ticker.heikinashi(syminfo.tickerid)
ha_o = request.security(ha_tkr, timeframe.period, open)
ha_h = request.security(ha_tkr, timeframe.period, high)
ha_l = request.security(ha_tkr, timeframe.period, low)
ha_c = request.security(ha_tkr, timeframe.period, close)
s_open = use_ha ? ha_o : open
s_high = use_ha ? ha_h : high
s_low = use_ha ? ha_l : low
s_close = use_ha ? ha_c : close

// ── STEP 1: RECTANGLE ─────────────────────
hi = ta.highest(s_high, consol_bars)
lo = ta.lowest(s_low, consol_bars)
in_range = (hi - lo) / s_close * 100 < range_pct

// ── STEP 1b: ACCUMULATION STRENGTH ────────
// Two sources, selectable via 'Accumulation source':
//
// WICK : Upper wick = rejection of higher prices -> selling pressure (bearish accum)
//        Lower wick = rejection of lower prices  -> buying  pressure (bullish accum)
// RSI  : bull bar (close>open) adds +RSI, bear bar (close<open) adds -RSI,
//        summed over the window, then normalised.
//
// Both produce acc_bias in -1..+1  (+ = bullish accum, - = bearish accum)

// --- Wick source ---
upper_wick = s_high - math.max(s_open, s_close)
lower_wick = math.min(s_open, s_close) - s_low
sum_upper = math.sum(upper_wick, consol_bars)
sum_lower = math.sum(lower_wick, consol_bars)
acc_upper = sum_upper[1]
acc_lower = sum_lower[1]
acc_total = acc_upper + acc_lower
wick_bias = acc_total > 0 ? (acc_lower - acc_upper) / acc_total : 0.0

// --- Body source (bull body size vs bear body size) ---
body = math.abs(s_close - s_open)
bull_body = s_close > s_open ? body : 0.0
bear_body = s_close < s_open ? body : 0.0
sum_bull_body = math.sum(bull_body, consol_bars)[1]
sum_bear_body = math.sum(bear_body, consol_bars)[1]
body_total = sum_bull_body + sum_bear_body
body_bias = body_total > 0 ? (sum_bull_body - sum_bear_body) / body_total : 0.0

// --- RSI source ---
r = ta.rsi(s_close, rsi_len)
bar_dir = s_close > s_open ? 1 : s_close < s_open ? -1 : 0   // bull bar = +, bear bar = -
rsi_signed = bar_dir * r                             // +RSI on bull bars, -RSI on bear bars
rsi_abs = bar_dir != 0 ? r : 0.0
sum_rsi = math.sum(rsi_signed, consol_bars)[1]
sum_rsi_abs = math.sum(rsi_abs, consol_bars)[1]
rsi_bias = nz(sum_rsi_abs) > 0 ? sum_rsi / sum_rsi_abs : 0.0

// --- TSI source (True Strength Index) ---
pc = ta.change(s_close)
ds_pc = ta.ema(ta.ema(pc, tsi_long), tsi_short)            // double-smoothed momentum
ds_apc = ta.ema(ta.ema(math.abs(pc), tsi_long), tsi_short) // double-smoothed |momentum|
tsi_val = nz(ds_apc) != 0 ? 100.0 * ds_pc / ds_apc : 0.0   // -100..+100
tsi_bias = math.max(-1.0, math.min(1.0, tsi_val[1] / 100.0))

// --- CMF source (Chaikin Money Flow) ---
// Money Flow Multiplier weights each bar's volume by where close sits in the range,
// then CMF = sum(MFV) / sum(volume) over the window. Already -1..+1.
mfm = s_high != s_low ? ((s_close - s_low) - (s_high - s_close)) / (s_high - s_low) : 0.0
mfv = mfm * volume
sum_mfv = math.sum(mfv, consol_bars)[1]
sum_vol = math.sum(volume, consol_bars)[1]
cmf_val = nz(sum_vol) != 0 ? sum_mfv / sum_vol : 0.0
cmf_bias = math.max(-1.0, math.min(1.0, cmf_val))

// --- Combined source (average of all; CMF only counts when volume exists) ---
vol_ok = nz(sum_vol) > 0
n_src = 4 + (vol_ok ? 1 : 0)
combined_bias = (wick_bias + body_bias + rsi_bias + tsi_bias + (vol_ok ? cmf_bias : 0.0)) / n_src

// --- Selected bias ---
acc_bias = accum_src == 'Body' ? body_bias : accum_src == 'RSI' ? rsi_bias : accum_src == 'TSI' ? tsi_bias : accum_src == 'CMF' ? cmf_bias : accum_src == 'Combined' ? combined_bias : wick_bias
acc_strength = math.abs(acc_bias)                // 0..1
strength_pct = int(math.round(acc_strength * 100))

is_neutral = strength_pct < neutral_thr
is_extreme = not is_neutral and strength_pct >= extreme_thr
is_normal = not is_neutral and not is_extreme
acc_is_bull = acc_bias > 0

// View filter (band part): only draw setups whose accumulation band is toggled on
band_ok = (is_extreme and view_extreme) or (is_normal and view_normal) or (is_neutral and view_neutral)

// Direction colour for the strength tag (stronger = more solid)
acc_col_base = is_neutral ? color.gray : (acc_is_bull ? color.teal : color.red)

acc_arrow = is_neutral ? '◆' : is_extreme ? '★' : (acc_is_bull ? '▲' : '▼')
acc_word = is_neutral ? 'Neutral' : (acc_is_bull ? 'Bull' : 'Bear') + (is_extreme ? ' EXTREME' : ' accum')
acc_txt = acc_arrow + ' ' + acc_word + ' ' + str.tostring(strength_pct) + '% (' + accum_src + ')'
acc_size = is_extreme ? size.normal : size.small

// ── STEP 2: BREAK OF STRUCTURE ────────────
bull_bos_raw = in_range[1] and s_close > hi[1] and s_close[1] <= hi[1]
bear_bos_raw = in_range[1] and s_close < lo[1] and s_close[1] >= lo[1]

// ── SESSION FILTER (times interpreted in UTC+3) ──
sess_spec = sess + (sess_days == 'Mon-Fri' ? ':23456' : ':1234567')
in_session = not na(time(timeframe.period, sess_spec, 'GMT+3'))
session_ok = not use_session or in_session
bgcolor(use_session and shade_session and not in_session ? color.new(color.gray, 90) : na, title = 'Out-of-session shade')

// ── NO CONSECUTIVE SAME-DIRECTION TRADES ──
// last_dir: 0 = none, 1 = last was BUY, -1 = last was SELL
// A new signal is only allowed if it is in the OPPOSITE direction
var int last_dir = 0
bull_bos = bull_bos_raw and last_dir != 1 and session_ok
bear_bos = bear_bos_raw and last_dir != -1 and session_ok

if bull_bos
    last_dir := 1
    last_dir
if bear_bos
    last_dir := -1
    last_dir

// ── CONFLICT: accumulation direction opposite to breakout/trend ──
// (neutral accumulation is NOT treated as a conflict)
conflict = not is_neutral and ((bull_bos and not acc_is_bull) or (bear_bos and acc_is_bull))

// Final view gate: band toggles + optional only-conflict filter
band_show = band_ok and (not view_only_conflict or conflict)

// ── STEP 3: LEVELS ────────────────────────
// Entry uses the REAL close (actual fill price) even when HA source is on.
// Rectangle edges (hi/lo) remain source-based (HA when enabled).
entry_px = close
buf = sl_buf_mode == '% of rectangle' ? (hi[1] - lo[1]) * sl_buffer_pct / 100 : entry_px * sl_buffer_pct / 100
long_sl = lo[1] - buf
long_risk = entry_px - long_sl
long_tp1 = entry_px + long_risk * rr_ratio
long_tp2 = entry_px + long_risk * tp2_ratio
short_sl = hi[1] + buf
short_risk = short_sl - entry_px
short_tp1 = entry_px - short_risk * rr_ratio
short_tp2 = entry_px - short_risk * tp2_ratio

// Re-entry sits between Entry (0%) and SL (100%)
long_re = entry_px - long_risk * reentry_loc / 100
short_re = entry_px + short_risk * reentry_loc / 100

// ── STEP 4: TRADE OUTCOME TRACKING (for stats table) ──
// Tracks ONE trade at a time. A new signal while a trade is open is skipped
// for stats; the open trade resolves only when TP2 or SL is reached.
var bool in_trade = false
var int t_dir = 0
var float t_sl = na
var float t_tp1 = na
var float t_tp2 = na
var float t_re = na
var bool got_tp1 = false
var bool got_re = false

var int cnt_trades = 0
var int cnt_win = 0
var int cnt_loss = 0
var int cnt_tp2 = 0
var int cnt_re = 0
var int cnt_re_win = 0
var int cnt_re_loss = 0

// 1) Resolve the currently open trade on this bar (bars AFTER its entry bar)
//    WIN  = reaches TP1 before SL.   LOSS = hits SL before TP1.
if in_trade
    if t_dir == 1
        if not got_re and not got_tp1 and s_low <= t_re          // pullback to re-entry first
            got_re := true
            cnt_re += 1
        if s_low <= t_sl                                          // SL ends the trade (assumed first if both)
            in_trade := false
            if not got_tp1
                cnt_loss += 1
                if got_re
                    cnt_re_loss += 1
        else
            if s_high >= t_tp1 and not got_tp1
                got_tp1 := true
                cnt_win += 1
                if got_re
                    cnt_re_win += 1
            if s_high >= t_tp2
                cnt_tp2 += 1
                in_trade := false
    else if t_dir == -1
        if not got_re and not got_tp1 and s_high >= t_re
            got_re := true
            cnt_re += 1
        if s_high >= t_sl
            in_trade := false
            if not got_tp1
                cnt_loss += 1
                if got_re
                    cnt_re_loss += 1
        else
            if s_low <= t_tp1 and not got_tp1
                got_tp1 := true
                cnt_win += 1
                if got_re
                    cnt_re_win += 1
            if s_low <= t_tp2
                cnt_tp2 += 1
                in_trade := false

// 2) Start tracking a new trade — only ACTIVE (view-filtered) signals, none open
if (bull_bos or bear_bos) and band_show and not in_trade
    in_trade := true
    t_dir := bull_bos ? 1 : -1
    t_sl := bull_bos ? long_sl : short_sl
    t_tp1 := bull_bos ? long_tp1 : short_tp1
    t_tp2 := bull_bos ? long_tp2 : short_tp2
    t_re := bull_bos ? long_re : short_re
    got_tp1 := false
    got_re := false
    cnt_trades += 1

// ── RECTANGLE BOX (PRIMARY = trade direction; accumulation = secondary) ──
if show_rect and band_show and (bull_bos or bear_bos)
    trend_base = bull_bos ? col_buy_zone : col_sell_zone     // PRIMARY: BUY = buy color, SELL = sell color
    accum_agrees = (bull_bos and acc_is_bull) or (bear_bos and not acc_is_bull)
    conf = (is_neutral or not accum_agrees) ? 0.0 : acc_strength
    fill_transp = int(math.round(80 - conf * 35))           // stronger same-direction accum = more solid
    mark = conflict and show_conflict
    b_color = mark ? C_WARN : color.new(trend_base, 0)
    b_style = mark ? line.style_dashed : line.style_solid
    b_width = mark ? 2 : 1
    box.new(bar_index - consol_bars, hi[1], bar_index, lo[1], border_color = b_color, bgcolor = color.new(trend_base, fill_transp), border_width = b_width, border_style = b_style)

// ── CONFLICT WARNING TAG ──────────────────
if show_conflict and conflict and band_show
    warn_below = not acc_is_bull                              // opposite side from the strength tag
    warn_y = warn_below ? lo[1] : hi[1]
    warn_style = warn_below ? label.style_label_up : label.style_label_down
    label.new(bar_index, warn_y, '⚠ Accum ≠ Trend', yloc = yloc.price, style = warn_style, color = C_WARN, textcolor = color.white, size = size.small)

// ── STRENGTH TAG ──────────────────────────
if show_strength and band_show and (bull_bos or bear_bos)
    tag_below = acc_is_bull                                   // bull accum -> sit below the rectangle
    tag_y = tag_below ? lo[1] : hi[1]
    tag_style = tag_below ? label.style_label_up : label.style_label_down
    label.new(bar_index - consol_bars, tag_y, acc_txt, yloc = yloc.price, style = tag_style, color = color.new(acc_col_base, 15), textcolor = color.white, size = acc_size)

// ── RE-ENTRY LINE (between Entry and SL, location configurable) ──
if show_reentry and band_show and bull_bos
    line.new(bar_index, long_re, bar_index + reentry_bars, long_re, color = C_RE, style = line.style_dashed, width = 2)
    label.new(bar_index + reentry_bars, long_re, '↩ RE ' + str.tostring(long_re, '#.#####'), yloc = yloc.price, style = label.style_label_left, color = C_RE, textcolor = color.black, size = size.small)
if show_reentry and band_show and bear_bos
    line.new(bar_index, short_re, bar_index + reentry_bars, short_re, color = C_RE, style = line.style_dashed, width = 2)
    label.new(bar_index + reentry_bars, short_re, '↩ RE ' + str.tostring(short_re, '#.#####'), yloc = yloc.price, style = label.style_label_left, color = C_RE, textcolor = color.black, size = size.small)

// ── ENTRY LABEL ───────────────────────────
if bull_bos and show_label and band_show
    label.new(bar_index, low, '▲ BUY\n' + acc_txt, yloc = yloc.belowbar, style = label.style_label_up, color = C_BUY, textcolor = color.black, size = size.small)

if bear_bos and show_label and band_show
    label.new(bar_index, high, '▼ SELL\n' + acc_txt, yloc = yloc.abovebar, style = label.style_label_down, color = C_SELL, textcolor = color.white, size = size.small)

// ── ENTRY / SL / TP1 / TP2 LEVELS (line + label, extended N bars) ──
if bull_bos and show_sl_tp and band_show
    f_level(entry_px, 'Entry', C_ENTRY, level_bars)
    f_level(long_sl, 'SL', C_SL, level_bars)
    f_level(long_tp1, 'TP1', C_TP, level_bars)
    f_level(long_tp2, 'TP2', C_TP2, level_bars)

if bear_bos and show_sl_tp and band_show
    f_level(entry_px, 'Entry', C_ENTRY, level_bars)
    f_level(short_sl, 'SL', C_SL, level_bars)
    f_level(short_tp1, 'TP1', C_TP, level_bars)
    f_level(short_tp2, 'TP2', C_TP2, level_bars)

// ── STATS TABLE (active / view-filtered signals only) ──
tbl_pos = table_pos == 'Top Left' ? position.top_left : table_pos == 'Bottom Right' ? position.bottom_right : table_pos == 'Bottom Left' ? position.bottom_left : position.top_right
var table tbl = table.new(tbl_pos, 3, 10, border_color = color.new(color.gray, 50), border_width = 1)
tsize = table_size == 'Tiny' ? size.tiny : table_size == 'Normal' ? size.normal : table_size == 'Large' ? size.large : size.small

if show_table and barstate.islast
    c_hdr = color.new(color.gray, 0)
    c_bg = color.new(color.black, 20)
    decided = cnt_win + cnt_loss
    table.cell(tbl, 0, 0, 'Active signals', text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 1, 0, '#', text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 2, 0, '%', text_color = color.white, bgcolor = c_hdr, text_size = tsize)

    table.cell(tbl, 0, 1, 'Trades', text_color = color.white, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 1, str.tostring(cnt_trades), text_color = color.white, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 1, cnt_trades > 0 ? '100%' : '–', text_color = color.white, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 2, 'Win (→ TP1)', text_color = C_TP, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 2, str.tostring(cnt_win), text_color = C_TP, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 2, f_pct(cnt_win, cnt_trades), text_color = C_TP, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 3, 'Loss (SL)', text_color = C_SL, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 3, str.tostring(cnt_loss), text_color = C_SL, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 3, f_pct(cnt_loss, cnt_trades), text_color = C_SL, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 4, 'Win rate', text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 1, 4, str.tostring(cnt_win) + '/' + str.tostring(decided), text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 2, 4, f_pct(cnt_win, decided), text_color = color.white, bgcolor = c_hdr, text_size = tsize)

    table.cell(tbl, 0, 5, '→ TP2 reached', text_color = C_TP2, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 5, str.tostring(cnt_tp2), text_color = C_TP2, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 5, f_pct(cnt_tp2, cnt_trades), text_color = C_TP2, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 6, '↩ Re-entry hit', text_color = C_RE, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 6, str.tostring(cnt_re), text_color = C_RE, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 6, f_pct(cnt_re, cnt_trades), text_color = C_RE, bgcolor = c_bg, text_size = tsize)

    re_decided = cnt_re_win + cnt_re_loss
    table.cell(tbl, 0, 7, '  RE → Win', text_color = C_TP, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 7, str.tostring(cnt_re_win), text_color = C_TP, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 7, f_pct(cnt_re_win, cnt_re), text_color = C_TP, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 8, '  RE → Loss', text_color = C_SL, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 1, 8, str.tostring(cnt_re_loss), text_color = C_SL, bgcolor = c_bg, text_size = tsize)
    table.cell(tbl, 2, 8, f_pct(cnt_re_loss, cnt_re), text_color = C_SL, bgcolor = c_bg, text_size = tsize)

    table.cell(tbl, 0, 9, '  RE win rate', text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 1, 9, str.tostring(cnt_re_win) + '/' + str.tostring(re_decided), text_color = color.white, bgcolor = c_hdr, text_size = tsize)
    table.cell(tbl, 2, 9, f_pct(cnt_re_win, re_decided), text_color = color.white, bgcolor = c_hdr, text_size = tsize)

// ── ALERTS ────────────────────────────────
alertcondition(bull_bos, 'BUY – Rectangle Breakout ▲', '1-Rectangle Setup: BUY signal')
alertcondition(bear_bos, 'SELL – Rectangle Breakout ▼', '1-Rectangle Setup: SELL signal')
````

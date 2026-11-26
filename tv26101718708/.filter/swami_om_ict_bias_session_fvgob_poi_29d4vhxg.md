# Swami Om ICT Bias + Session FVG/OB POI

- url: https://www.tradingview.com/script/29D4vhxG-Swami-Om-ICT-Bias-Session-FVG-OB-POI/
- type: indicator
- pine_id: PUB;6043ad7d3c9b41319f4688c6d6b2c676
- version: 1.0

## Description

Swami Om ICT Bias + Session FVG/OB POI
OB Definition (ICT):
//   - A displacement candle = body significantly larger than avg
//   - Creates an FVG (Fair Value Gap) between candle[-2] and candle[0]
//   - The candle BEFORE the displacement = the Order Block
//   - Last Line of Defence (LLOD/LLOF) = 50% of OB candle body
//   - Only the LAST valid OB in bias direction per session is shown

## Source Code

````pine
//@version=6
indicator('Swami Om ICT Bias + Session FVG/OB POI', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// =============SHRI SWAMI SAMARTH===============================================
// ICT TODAY BIAS + SESSION ORDER BLOCK (Displacement + FVG)
//
// OB Definition (ICT):
//   - A displacement candle = body significantly larger than avg
//   - Creates an FVG (Fair Value Gap) between candle[-2] and candle[0]
//   - The candle BEFORE the displacement = the Order Block
//   - Last Line of Defence (LLOD/LLOF) = 50% of OB candle body
//   - Only the LAST valid OB in bias direction per session is shown
//
// Sessions (user sets timezone offset):
//   Asia         20:00 - 00:00
//   London       02:00 - 05:00
//   New York     07:00 - 10:00
//   London Close 10:00 - 12:00
// ============================================================

// ─── INPUTS: DISPLAY ─────────────────────────────────────────
grp0 = '═══ DISPLAY ═══'
show_dashboard = input.bool(true, 'Show Bias Dashboard', group = grp0)
show_levels = input.bool(true, 'Show Key Levels (PDH/PDL/W)', group = grp0)
show_dol = input.bool(true, 'Show DOL Targets', group = grp0)
show_prem_disc = input.bool(true, 'Show Premium/Discount Zone', group = grp0)
show_eq = input.bool(true, 'Show Equilibrium (50%) Line', group = grp0)

// ─── INPUTS: SESSION TIMES ───────────────────────────────────
grp1 = '═══ SESSION TIMES (use your broker/chart timezone) ═══'
tz_offset = input.int(-4, 'Timezone Offset from UTC (e.g. -4 for GMT-4, +5.5 enter 5)', minval = -12, maxval = 14, group = grp1)

asia_start = input.int(20, 'Asia Start Hour', minval = 0, maxval = 23, group = grp1)
asia_end = input.int(0, 'Asia End Hour', minval = 0, maxval = 23, group = grp1)
lon_start = input.int(2, 'London Start Hour', minval = 0, maxval = 23, group = grp1)
lon_end = input.int(5, 'London End Hour', minval = 0, maxval = 23, group = grp1)
ny_start = input.int(7, 'New York Start Hour', minval = 0, maxval = 23, group = grp1)
ny_end = input.int(10, 'New York End Hour', minval = 0, maxval = 23, group = grp1)
lc_start = input.int(10, 'London Close Start Hour', minval = 0, maxval = 23, group = grp1)
lc_end = input.int(12, 'London Close End Hour', minval = 0, maxval = 23, group = grp1)

// ─── INPUTS: SESSION POI ─────────────────────────────────────
grp2 = '═══ SESSION POI / ORDER BLOCK ═══'
show_poi = input.bool(true, 'Show Session POI Boxes', group = grp2)
show_asia_poi = input.bool(true, 'Show Asia POI', group = grp2)
show_lon_poi = input.bool(true, 'Show London POI', group = grp2)
show_ny_poi = input.bool(true, 'Show New York POI', group = grp2)
show_lc_poi = input.bool(true, 'Show London Close POI', group = grp2)
show_llod = input.bool(true, 'Show Last Line of Defence (50% OB)', group = grp2)
disp_mult = input.float(1.5, 'Displacement Strength (x avg body)', minval = 1.0, maxval = 5.0, step = 0.1, group = grp2)
ob_extend = input.int(40, 'Extend OB Box Right (bars)', minval = 5, maxval = 200, group = grp2)

// ─── COLORS ──────────────────────────────────────────────────
C_BULL = color.new(color.green, 0)
C_BEAR = color.new(color.red, 0)
C_NEUT = color.new(color.gray, 0)
C_WEEK = color.new(color.orange, 0)
C_IRL = color.new(color.blue, 0)
C_ERL = color.new(color.purple, 0)
C_PREM = color.new(color.red, 88)
C_DISC = color.new(color.green, 88)
C_EQ = color.new(color.yellow, 0)
C_TT = color.new(color.teal, 0)
C_LLOD = color.new(color.white, 0)

// Session OB colors
C_ASIA_B = color.new(color.aqua, 70)
C_ASIA_S = color.new(color.orange, 70)
C_LON_B = color.new(color.lime, 70)
C_LON_S = color.new(color.red, 70)
C_NY_B = color.new(color.blue, 70)
C_NY_S = color.new(color.fuchsia, 70)
C_LC_B = color.new(color.teal, 70)
C_LC_S = color.new(color.maroon, 70)

// ─── REQUEST.SECURITY ────────────────────────────────────────
w_high = request.security(syminfo.tickerid, 'W', high[0], lookahead = barmerge.lookahead_on)
w_low = request.security(syminfo.tickerid, 'W', low[0], lookahead = barmerge.lookahead_on)
w_close = request.security(syminfo.tickerid, 'W', close[0], lookahead = barmerge.lookahead_on)
w_high2 = request.security(syminfo.tickerid, 'W', high[1], lookahead = barmerge.lookahead_on)
w_low2 = request.security(syminfo.tickerid, 'W', low[1], lookahead = barmerge.lookahead_on)
d_high = request.security(syminfo.tickerid, 'D', high[0], lookahead = barmerge.lookahead_on)
d_low = request.security(syminfo.tickerid, 'D', low[0], lookahead = barmerge.lookahead_on)
d_close = request.security(syminfo.tickerid, 'D', close[0], lookahead = barmerge.lookahead_on)
yd_high = request.security(syminfo.tickerid, 'D', high[1], lookahead = barmerge.lookahead_on)
yd_low = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_on)
yd_close = request.security(syminfo.tickerid, 'D', close[1], lookahead = barmerge.lookahead_on)
d2_high = request.security(syminfo.tickerid, 'D', high[2], lookahead = barmerge.lookahead_on)
d2_low = request.security(syminfo.tickerid, 'D', low[2], lookahead = barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════
// (A) ICT 5-STEP BIAS
// ═══════════════════════════════════════════════════════════════
weekly_bull = w_high > w_high2 and w_low >= w_low2
weekly_bear = w_high <= w_high2 and w_low < w_low2
w_mid = (w_high2 + w_low2) / 2
weekly_bull_fb = not weekly_bull and not weekly_bear and w_close > w_mid
weekly_bear_fb = not weekly_bull and not weekly_bear and w_close <= w_mid
w_bias = weekly_bull or weekly_bull_fb ? 1 : weekly_bear or weekly_bear_fb ? -1 : 0

daily_bull = d_high > yd_high and d_low >= yd_low
daily_bear = d_high <= yd_high and d_low < yd_low
d_mid = (yd_high + yd_low) / 2
daily_bull_fb = not daily_bull and not daily_bear and d_close > d_mid
daily_bear_fb = not daily_bull and not daily_bear and d_close <= d_mid
d_bias_raw = daily_bull or daily_bull_fb ? 1 : daily_bear or daily_bear_fb ? -1 : 0

equilibrium = (d_high + d_low) / 2
price_in_premium = d_close > equilibrium
price_in_discount = d_close <= equilibrium
aligned_bull = w_bias == 1 and d_bias_raw == 1
aligned_bear = w_bias == -1 and d_bias_raw == -1
correction = w_bias != d_bias_raw and w_bias != 0
ict_bias = w_bias == 1 ? 1 : w_bias == -1 ? -1 : d_bias_raw

// ═══════════════════════════════════════════════════════════════
// (B) TTRADES DECISION TREE
// ═══════════════════════════════════════════════════════════════
pdh = d2_high
pdl = d2_low
tt_q1_bull = yd_close > pdh
tt_q2_bear = yd_close < pdl
both_swept = yd_high >= pdh and yd_low <= pdl
high_swept = yd_high >= pdh and yd_low > pdl
low_swept = yd_low <= pdl and yd_high < pdh
last_was_high = both_swept and yd_high - yd_close < yd_close - yd_low
last_was_low = both_swept and yd_close - yd_low < yd_high - yd_close
tt_bias = tt_q1_bull ? 1 : tt_q2_bear ? -1 : both_swept and last_was_high ? -1 : both_swept and last_was_low ? 1 : high_swept ? -1 : low_swept ? 1 : 0
tt_reason = tt_q1_bull ? 'Yday closed > PDH' : tt_q2_bear ? 'Yday closed < PDL' : both_swept and last_was_high ? 'Both swept, last=High' : both_swept and last_was_low ? 'Both swept, last=Low' : high_swept ? 'Single High Sweep' : low_swept ? 'Single Low Sweep' : 'No clear sweep'

// ═══════════════════════════════════════════════════════════════
// COMBINED FINAL BIAS
// ═══════════════════════════════════════════════════════════════
both_bull = ict_bias == 1 and tt_bias == 1
both_bear = ict_bias == -1 and tt_bias == -1
methods_agree = both_bull or both_bear
final_bias = methods_agree ? ict_bias : ict_bias != 0 ? ict_bias : tt_bias
confidence = methods_agree ? 'HIGH - Both methods agree' : ict_bias == 0 or tt_bias == 0 ? 'MEDIUM - One neutral' : 'LOW - Methods conflict'

// ═══════════════════════════════════════════════════════════════
// SESSION DETECTION (convert UTC bar time to user timezone)
// ═══════════════════════════════════════════════════════════════
bar_hour_utc = hour(time, 'UTC')
bar_hour_loc = (bar_hour_utc + tz_offset + 24) % 24

// Handle overnight sessions (e.g. Asia 20:00 - 00:00)
in_asia = asia_start > asia_end ? bar_hour_loc >= asia_start or bar_hour_loc < asia_end : bar_hour_loc >= asia_start and bar_hour_loc < asia_end
in_lon = lon_start > lon_end ? bar_hour_loc >= lon_start or bar_hour_loc < lon_end : bar_hour_loc >= lon_start and bar_hour_loc < lon_end
in_ny = ny_start > ny_end ? bar_hour_loc >= ny_start or bar_hour_loc < ny_end : bar_hour_loc >= ny_start and bar_hour_loc < ny_end
in_lc = lc_start > lc_end ? bar_hour_loc >= lc_start or bar_hour_loc < lc_end : bar_hour_loc >= lc_start and bar_hour_loc < lc_end

is_asia_start = in_asia and not in_asia[1]
is_lon_start = in_lon and not in_lon[1]
is_ny_start = in_ny and not in_ny[1]
is_lc_start = in_lc and not in_lc[1]

// ═══════════════════════════════════════════════════════════════
// ORDER BLOCK + FVG DETECTION (ICT Definition)
//
// Displacement candle (index 0 = current):
//   BULL displacement: close[0] > open[0]  (strong bullish candle)
//                      body[0] > avg_body * disp_mult
//   BULL FVG:          low[0] > high[2]    (gap between c[0] and c[2])
//   BULL OB:           the candle at index [2] (last bearish before displacement)
//                      OB zone = [low[2], high[2]]
//   LLOD (last line of defence) = 50% of OB body = (open[2]+close[2])/2
//
//   BEAR displacement: close[0] < open[0]  (strong bearish candle)
//                      body[0] > avg_body * disp_mult
//   BEAR FVG:          high[0] < low[2]    (gap between c[0] and c[2])
//   BEAR OB:           candle at index [2] (last bullish before displacement)
//                      OB zone = [low[2], high[2]]
//   LLOF (last line of failure) = 50% of OB body = (open[2]+close[2])/2
// ═══════════════════════════════════════════════════════════════

avg_body = ta.sma(math.abs(close - open), 20)

// Displacement check
bull_disp = close > open and math.abs(close - open) > avg_body * disp_mult
bear_disp = close < open and math.abs(close - open) > avg_body * disp_mult

// FVG check (gap between current candle and 2 bars ago)
bull_fvg = low > high[2] // bullish FVG: current low above candle[2] high
bear_fvg = high < low[2] // bearish FVG: current high below candle[2] low

// Valid ICT Order Block = displacement WITH FVG
bull_ob_signal = bull_disp and bull_fvg // OB body is candle[2]
bear_ob_signal = bear_disp and bear_fvg

// OB zone = body of candle[2] (the OB candle itself)
bull_ob_top = bull_ob_signal ? math.max(open[2], close[2]) : na
bull_ob_bot = bull_ob_signal ? math.min(open[2], close[2]) : na
bull_ob_llod = bull_ob_signal ? (open[2] + close[2]) / 2 : na

bear_ob_top = bear_ob_signal ? math.max(open[2], close[2]) : na
bear_ob_bot = bear_ob_signal ? math.min(open[2], close[2]) : na
bear_ob_llof = bear_ob_signal ? (open[2] + close[2]) / 2 : na

// Match to bias
valid_bull_ob = bull_ob_signal and final_bias == 1
valid_bear_ob = bear_ob_signal and final_bias == -1

// ═══════════════════════════════════════════════════════════════
// TRACK LAST VALID OB PER SESSION
// ═══════════════════════════════════════════════════════════════
type ObData
	int bar
	float top
	float bot
	float llod
	bool is_bull

var ObData asia_ob = ObData.new(na, na, na, na, bool(na))
var ObData lon_ob = ObData.new(na, na, na, na, bool(na))
var ObData ny_ob = ObData.new(na, na, na, na, bool(na))
var ObData lc_ob = ObData.new(na, na, na, na, bool(na))

// Reset on session start
if is_asia_start
    asia_ob := ObData.new(na, na, na, na, bool(na))
    asia_ob
if is_lon_start
    lon_ob := ObData.new(na, na, na, na, bool(na))
    lon_ob
if is_ny_start
    ny_ob := ObData.new(na, na, na, na, bool(na))
    ny_ob
if is_lc_start
    lc_ob := ObData.new(na, na, na, na, bool(na))
    lc_ob

// Store last valid OB in each session (keeps overwriting = always last one)
if valid_bull_ob and in_asia
    asia_ob := ObData.new(bar_index[2], bull_ob_top, bull_ob_bot, bull_ob_llod, true)
    asia_ob
if valid_bear_ob and in_asia
    asia_ob := ObData.new(bar_index[2], bear_ob_top, bear_ob_bot, bear_ob_llof, false)
    asia_ob

if valid_bull_ob and in_lon
    lon_ob := ObData.new(bar_index[2], bull_ob_top, bull_ob_bot, bull_ob_llod, true)
    lon_ob
if valid_bear_ob and in_lon
    lon_ob := ObData.new(bar_index[2], bear_ob_top, bear_ob_bot, bear_ob_llof, false)
    lon_ob

if valid_bull_ob and in_ny
    ny_ob := ObData.new(bar_index[2], bull_ob_top, bull_ob_bot, bull_ob_llod, true)
    ny_ob
if valid_bear_ob and in_ny
    ny_ob := ObData.new(bar_index[2], bear_ob_top, bear_ob_bot, bear_ob_llof, false)
    ny_ob

if valid_bull_ob and in_lc
    lc_ob := ObData.new(bar_index[2], bull_ob_top, bull_ob_bot, bull_ob_llod, true)
    lc_ob
if valid_bear_ob and in_lc
    lc_ob := ObData.new(bar_index[2], bear_ob_top, bear_ob_bot, bear_ob_llof, false)
    lc_ob

// ─── Helper: draw one OB box + LLOD line + label ─────────────
f_draw_ob(ObData ob, string sess_name, color c_bull, color c_bear, bool do_draw) =>
    var box b = na
    var line l = na
    var label lb = na
    box.delete(b)
    line.delete(l)
    label.delete(lb)
    if do_draw and not na(ob.bar) and not na(ob.top)
        ob_c = ob.is_bull ? c_bull : c_bear
        b := box.new(ob.bar, ob.top, bar_index + ob_extend, ob.bot, border_color = ob_c, bgcolor = ob_c, border_width = 1)
        if show_llod
            l := line.new(ob.bar, ob.llod, bar_index + ob_extend, ob.llod, color = C_LLOD, width = 1, style = line.style_dashed)
            l
        tag = sess_name + ' OB ' + (ob.is_bull ? '[BUY]' : '[SELL]') + ' LLOD:' + str.tostring(ob.llod, format.mintick)
        lb := label.new(bar_index + ob_extend + 1, ob.llod, text = tag, style = label.style_label_left, color = color.new(ob_c, 60), textcolor = color.white, size = size.small)
        lb
    [b, l, lb]

// Draw all session OBs on last bar
var box a_box = na
var line a_ln = na
var label a_lb = na
var box lo_box = na
var line lo_ln = na
var label lo_lb = na
var box n_box = na
var line n_ln = na
var label n_lb = na
var box lc_box = na
var line lc_ln = na
var label lc_lb = na

if barstate.islast and show_poi
    [ab, al, alb] = f_draw_ob(asia_ob, 'ASIA', C_ASIA_B, C_ASIA_S, show_asia_poi)
    a_box := ab
    a_ln := al
    a_lb := alb
    [lb2, ll2, lb2b] = f_draw_ob(lon_ob, 'LONDON', C_LON_B, C_LON_S, show_lon_poi)
    lo_box := lb2
    lo_ln := ll2
    lo_lb := lb2b
    [nb, nl, nlb] = f_draw_ob(ny_ob, 'NY', C_NY_B, C_NY_S, show_ny_poi)
    n_box := nb
    n_ln := nl
    n_lb := nlb
    [lcb, lcl, lclb] = f_draw_ob(lc_ob, 'LC', C_LC_B, C_LC_S, show_lc_poi)
    lc_box := lcb
    lc_ln := lcl
    lc_lb := lclb
    lc_lb

// ─── SESSION BACKGROUND ───────────────────────────────────────
bgcolor(in_asia ? color.new(color.aqua, 96) : na, title = 'Asia Session BG')
bgcolor(in_lon ? color.new(color.yellow, 96) : na, title = 'London Session BG')
bgcolor(in_ny ? color.new(color.blue, 96) : na, title = 'NY Session BG')
bgcolor(in_lc ? color.new(color.fuchsia, 96) : na, title = 'London Close BG')

// ─── KEY LEVELS ───────────────────────────────────────────────
irl_bull = d_high
irl_bear = d_low
erl_bull = w_high
erl_bear = w_low
irl_val = final_bias == 1 ? irl_bull : irl_bear
erl_val = final_bias == 1 ? erl_bull : erl_bear
irl_txt = final_bias == 1 ? 'IRL: PDH' : 'IRL: PDL'
erl_txt = final_bias == 1 ? 'ERL: W-High' : 'ERL: W-Low'
irl_disp = str.tostring(irl_val, format.mintick)
erl_disp = str.tostring(erl_val, format.mintick)

var box prem_box = na
var box disc_box = na
var line eq_line = na
var label eq_lbl = na
var line pdh_line = na
var line pdl_line = na
var line ydh_line = na
var line ydl_line = na
var line wh_line = na
var line wl_line = na
var label pdh_lbl = na
var label pdl_lbl = na
var label ydh_lbl = na
var label ydl_lbl = na
var label wh_lbl = na
var label wl_lbl = na
var line irl_line = na
var line erl_line = na
var label irl_lbl = na
var label erl_lbl = na

if barstate.islast
    box.delete(prem_box)
    box.delete(disc_box)
    line.delete(eq_line)
    label.delete(eq_lbl)
    line.delete(pdh_line)
    line.delete(pdl_line)
    line.delete(ydh_line)
    line.delete(ydl_line)
    line.delete(wh_line)
    line.delete(wl_line)
    label.delete(pdh_lbl)
    label.delete(pdl_lbl)
    label.delete(ydh_lbl)
    label.delete(ydl_lbl)
    label.delete(wh_lbl)
    label.delete(wl_lbl)
    line.delete(irl_line)
    line.delete(erl_line)
    label.delete(irl_lbl)
    label.delete(erl_lbl)

    R = bar_index + ob_extend

    if show_prem_disc
        prem_box := box.new(bar_index - 10, d_high, R, equilibrium, border_color = color.new(C_BEAR, 60), bgcolor = C_PREM, border_width = 1)
        disc_box := box.new(bar_index - 10, equilibrium, R, d_low, border_color = color.new(C_BULL, 60), bgcolor = C_DISC, border_width = 1)
        disc_box

    if show_eq
        eq_line := line.new(bar_index - 10, equilibrium, R, equilibrium, color = C_EQ, width = 1, style = line.style_dotted)
        eq_lbl := label.new(R + 1, equilibrium, text = 'EQ 50%', style = label.style_label_left, color = color.new(C_EQ, 80), textcolor = C_EQ, size = size.tiny)
        eq_lbl

    if show_levels
        pdh_line := line.new(bar_index - 10, d_high, R, d_high, color = C_BULL, width = 2)
        pdl_line := line.new(bar_index - 10, d_low, R, d_low, color = C_BEAR, width = 2)
        ydh_line := line.new(bar_index - 10, yd_high, R, yd_high, color = color.new(C_BULL, 55), width = 1, style = line.style_dashed)
        ydl_line := line.new(bar_index - 10, yd_low, R, yd_low, color = color.new(C_BEAR, 55), width = 1, style = line.style_dashed)
        wh_line := line.new(bar_index - 10, w_high, R, w_high, color = C_WEEK, width = 1, style = line.style_dashed)
        wl_line := line.new(bar_index - 10, w_low, R, w_low, color = C_WEEK, width = 1, style = line.style_dashed)
        pdh_lbl := label.new(R + 1, d_high, text = 'Today H', style = label.style_label_left, color = color.new(C_BULL, 80), textcolor = C_BULL, size = size.small)
        pdl_lbl := label.new(R + 1, d_low, text = 'Today L', style = label.style_label_left, color = color.new(C_BEAR, 80), textcolor = C_BEAR, size = size.small)
        ydh_lbl := label.new(R + 1, yd_high, text = 'PDH', style = label.style_label_left, color = color.new(C_BULL, 90), textcolor = color.new(C_BULL, 30), size = size.tiny)
        ydl_lbl := label.new(R + 1, yd_low, text = 'PDL', style = label.style_label_left, color = color.new(C_BEAR, 90), textcolor = color.new(C_BEAR, 30), size = size.tiny)
        wh_lbl := label.new(R + 1, w_high, text = 'W-High', style = label.style_label_left, color = color.new(C_WEEK, 80), textcolor = C_WEEK, size = size.small)
        wl_lbl := label.new(R + 1, w_low, text = 'W-Low', style = label.style_label_left, color = color.new(C_WEEK, 80), textcolor = C_WEEK, size = size.small)
        wl_lbl

    if show_dol
        irl_line := line.new(bar_index - 5, irl_val, R, irl_val, color = C_IRL, width = 2, style = line.style_dotted)
        erl_line := line.new(bar_index - 5, erl_val, R, erl_val, color = C_ERL, width = 2, style = line.style_dotted)
        irl_lbl := label.new(R + 1, irl_val, text = irl_txt, style = label.style_label_left, color = color.new(C_IRL, 80), textcolor = C_IRL, size = size.small)
        erl_lbl := label.new(R + 1, erl_val, text = erl_txt, style = label.style_label_left, color = color.new(C_ERL, 80), textcolor = C_ERL, size = size.small)
        erl_lbl

// ─── DASHBOARD STRINGS ────────────────────────────────────────
bias_str = final_bias == 1 ? 'BULLISH' : final_bias == -1 ? 'BEARISH' : 'NEUTRAL'
bias_col = final_bias == 1 ? C_BULL : final_bias == -1 ? C_BEAR : C_NEUT
ict_str = ict_bias == 1 ? 'Bullish' : ict_bias == -1 ? 'Bearish' : 'Neutral'
ict_col = ict_bias == 1 ? C_BULL : ict_bias == -1 ? C_BEAR : C_NEUT
tt_str = tt_bias == 1 ? 'BUY ONLY' : tt_bias == -1 ? 'SELL ONLY' : 'Neutral'
tt_col = tt_bias == 1 ? C_BULL : tt_bias == -1 ? C_BEAR : C_NEUT
w_col = w_bias == 1 ? C_BULL : w_bias == -1 ? C_BEAR : C_NEUT
w_str = w_bias == 1 ? 'Bullish' : w_bias == -1 ? 'Bearish' : 'Neutral'
d_col = d_bias_raw == 1 ? C_BULL : d_bias_raw == -1 ? C_BEAR : C_NEUT
d_str = d_bias_raw == 1 ? 'Bullish' : d_bias_raw == -1 ? 'Bearish' : 'Neutral'
zone_col = price_in_premium ? C_BEAR : C_BULL
zone_str = price_in_premium ? 'PREMIUM - Optimal Shorts' : 'DISCOUNT - Optimal Longs'
align_str = aligned_bull or aligned_bear ? 'W+D Aligned' : correction ? 'Correction' : 'Neutral'
conf_col = methods_agree ? C_BULL : ict_bias == 0 or tt_bias == 0 ? C_WEEK : C_BEAR
scene_str = final_bias == 1 and price_in_discount ? 'Scenario B: SSL sweep > Bull FVG' : final_bias == -1 and price_in_premium ? 'Scenario A: BSL sweep > Bear FVG' : final_bias == 1 and price_in_premium ? 'Caution: Bullish but in Premium' : final_bias == -1 and price_in_discount ? 'Caution: Bearish but in Discount' : 'No clear bias - stand aside'
cur_sess = in_asia ? 'ASIA' : in_lon ? 'LONDON' : in_ny ? 'NEW YORK' : in_lc ? 'LONDON CLOSE' : 'Off-Session'

f_poi_str(ObData ob) =>
    not na(ob.top) ? str.tostring(ob.llod, format.mintick) + (ob.is_bull ? ' BUY' : ' SELL') + ' | OB:' + str.tostring(ob.top, format.mintick) + '-' + str.tostring(ob.bot, format.mintick) : 'No FVG/OB yet'
f_poi_col(ObData ob) =>
    not na(ob.top) ? ob.is_bull ? C_BULL : C_BEAR : C_NEUT

// ─── DASHBOARD TABLE ─────────────────────────────────────────
var table dash = na
if barstate.islast and show_dashboard
    table.delete(dash)
    dash := table.new(position.top_right, 2, 18, bgcolor = color.new(color.black, 15), border_color = color.new(color.gray, 50), border_width = 1)

    table.cell(dash, 0, 0, 'ICT TODAY BIAS', text_color = bias_col, text_size = size.normal, bgcolor = color.new(bias_col, 75))
    table.cell(dash, 1, 0, bias_str, text_color = bias_col, text_size = size.normal, bgcolor = color.new(bias_col, 75))
    table.cell(dash, 0, 1, 'Confidence', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 1, confidence, text_color = conf_col, text_size = size.tiny, bgcolor = color.new(conf_col, 85))
    table.cell(dash, 0, 2, 'Active Session', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 2, cur_sess, text_color = C_EQ, text_size = size.small, bgcolor = color.new(color.black, 55))

    table.cell(dash, 0, 3, '── ICT 5-STEP ──', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 1, 3, ict_str, text_color = ict_col, text_size = size.small, bgcolor = color.new(ict_col, 82))
    table.cell(dash, 0, 4, '[1] Weekly', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 4, w_str, text_color = w_col, text_size = size.small, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 5, '[2] Daily', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 5, d_str + ' | ' + align_str, text_color = d_col, text_size = size.tiny, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 6, '[4] Zone', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 6, zone_str, text_color = zone_col, text_size = size.small, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 7, '[5] Scenario', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 7, scene_str, text_color = color.white, text_size = size.tiny, bgcolor = color.new(ict_col, 82))

    table.cell(dash, 0, 8, '── TTRADES ──', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 1, 8, tt_str, text_color = tt_col, text_size = size.small, bgcolor = color.new(tt_col, 82))
    table.cell(dash, 0, 9, 'Reason', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 9, tt_reason, text_color = C_TT, text_size = size.tiny, bgcolor = color.new(color.black, 55))

    table.cell(dash, 0, 10, '── SESSION POI (LLOD) ──', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 1, 10, 'Displace+FVG OB', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 0, 11, 'Asia OB', text_color = color.new(color.aqua, 0), text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 11, f_poi_str(asia_ob), text_color = f_poi_col(asia_ob), text_size = size.tiny, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 12, 'London OB', text_color = color.new(color.lime, 0), text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 12, f_poi_str(lon_ob), text_color = f_poi_col(lon_ob), text_size = size.tiny, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 13, 'NY OB', text_color = color.new(color.blue, 0), text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 13, f_poi_str(ny_ob), text_color = f_poi_col(ny_ob), text_size = size.tiny, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 14, 'London Close OB', text_color = color.new(color.teal, 0), text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 14, f_poi_str(lc_ob), text_color = f_poi_col(lc_ob), text_size = size.tiny, bgcolor = color.new(color.black, 55))

    table.cell(dash, 0, 15, '── TARGETS ──', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 1, 15, '──────────', text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 65))
    table.cell(dash, 0, 16, 'IRL (1st target)', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 16, irl_disp, text_color = C_IRL, text_size = size.small, bgcolor = color.new(color.black, 55))
    table.cell(dash, 0, 17, 'ERL (destination)', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 40))
    table.cell(dash, 1, 17, erl_disp, text_color = C_ERL, text_size = size.small, bgcolor = color.new(color.black, 55))

// ─── BAR COLOR ───────────────────────────────────────────────
barcolor(final_bias == 1 ? color.new(C_BULL, 75) : final_bias == -1 ? color.new(C_BEAR, 75) : na)
````

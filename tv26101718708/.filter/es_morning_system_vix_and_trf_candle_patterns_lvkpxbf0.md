# ES Morning System (VIX and TRF + Candle Patterns)

- url: https://www.tradingview.com/script/LvkPXBF0-ES-Morning-System-VIX-and-TRF-Candle-Patterns/
- type: indicator
- pine_id: PUB;e78543e7a03d4d09b696fbea2e04f5a6
- version: 1.0

## Description

Same idea as my NQ work, tuned for ES on the 1-minute in the morning. It marks swing pivots off candle-color flips (green-to-red is a high, red-to-green is a low) and waits for a higher-high, higher-low structure that then takes out the prior high. The piece that makes it different: nothing arms until price actually touches VWAP. Once it's armed you need price above both the session and overnight VWAP with the 15-minute pointing your way, and it grades //
/$/$$$ by how many higher timeframes agree. After a trigger it goes quiet until the next VWAP touch, so you're not getting spammed. Wait for the touch, then take the break. It leans on multi-timeframe VWAP with lookahead, so check live against history before you trust the timing.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  ES Morning System v2 - VWAP-touch entries
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  Same idea as my NQ work, tuned for ES on the 1-minute in the morning. It
//  marks swing pivots off candle-color flips (green-to-red is a high, red-to-
//  green is a low) and waits for a higher-high, higher-low structure that
//  then takes out the prior high. The piece that makes it different: nothing
//  arms until price actually touches VWAP. Once it's armed you need price
//  above both the session and overnight VWAP with the 15-minute pointing your
//  way, and it grades $/$$/$$$ by how many higher timeframes agree. After a
//  trigger it goes quiet until the next VWAP touch, so you're not getting
//  spammed. Wait for the touch, then take the break. It leans on multi-
//  timeframe VWAP with lookahead, so check live against history before you
//  trust the timing.
// ============================================================================
//
// =============================================================================
// ES MORNING SYSTEM v2 — VWAP-Touch Gated Entries
// =============================================================================
// Apply on a 1-minute chart of ES futures (9:30 AM – 12:00 PM ET).
//
// LONG (E2): Swing-pivot HH → HL → break HH (buy stop at HH)
//   - Swings defined by candle color transitions (green→red = high, red→green = low)
//   - Must be above both VWAPs + 15m HTF green at entry
//   - Quality: $ (15m only), $$ (15m+1 HTF), $$$ (15m+2+ HTF)
//   - VWAP touch arms entry. Dormant after entry until next touch.
//   - Pattern invalidated if price drops below HL
//
// SHORT (E1): Swing-pivot LL → LH → break LL (sell stop at LL)
//   - Swings defined by candle color transitions (mirrored from long)
//   - Below ON VWAP + VIX 15m green at entry
//   - Continuous — can fire multiple times. No VWAP-touch gating.
//
// =============================================================================

//@version=6
indicator(title = 'ES Morning System v2', shorttitle = 'ES v2', overlay = true, max_labels_count = 500, max_lines_count = 300)

// =============================================================================
// INPUTS
// =============================================================================

trf_per1 = input.int(27, 'TRF Fast Period', minval = 1, group = 'Twin Range Filter')
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval = 0.1, group = 'Twin Range Filter')
trf_per2 = input.int(55, 'TRF Slow Period', minval = 1, group = 'Twin Range Filter')
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval = 0.1, group = 'Twin Range Filter')

vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol', group = 'Settings')
sl_atr_len = input.int(14, 'ATR Period', minval = 1, group = 'Risk')
stop_buffer = input.float(0.25, 'Stop Buffer (pts)', minval = 0.0, step = 0.25, group = 'Risk')

show_trf = input.bool(true, '1m TRF Line', group = 'Display')
show_vwaps = input.bool(true, 'VWAPs', group = 'Display')
show_pa = input.bool(true, 'PA Swing Markers', group = 'Display')
show_levels = input.bool(true, 'Entry Level Lines', group = 'Display')
show_signals = input.bool(true, 'Entry Signal Labels', group = 'Display')

session_tz = 'America/New_York'

// =============================================================================
// TRF ENGINE
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

f_bull() =>
    [line, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close > line

f_bull_simple() =>
    [line, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close > line

// =============================================================================
// SESSION / TIME
// =============================================================================

ny_hour = hour(time, session_tz)
ny_min = minute(time, session_tz)
ny_hour_prev = hour(time[1], session_tz)
ny_min_prev = minute(time[1], session_tz)

new_overnight_anchor = ny_hour == 18 and ny_min == 0 and not(ny_hour_prev == 18 and ny_min_prev == 0)
new_ny_anchor = ny_hour == 9 and ny_min == 30 and not(ny_hour_prev == 9 and ny_min_prev == 30)

in_rth_session = ny_hour == 9 and ny_min >= 30 or ny_hour > 9 and ny_hour < 12 or ny_hour == 12 and ny_min == 0
signals_ok = in_rth_session and (ny_hour > 9 or ny_hour == 9 and ny_min >= 45)

// =============================================================================
// OVERNIGHT VWAP (anchored 6:00 PM ET)
// =============================================================================

var float on_pv = na
var float on_v = na
if new_overnight_anchor
    on_pv := 0.0
    on_v := 0.0
    on_v
if not na(on_v)
    on_pv := on_pv + hlc3 * volume
    on_v := on_v + volume
    on_v
overnight_vwap = on_v > 0 ? on_pv / on_v : na

// =============================================================================
// NY SESSION VWAP (anchored 9:30 AM ET)
// =============================================================================

var float ny_pv = na
var float ny_v = na
if new_ny_anchor
    ny_pv := 0.0
    ny_v := 0.0
    ny_v
if not na(ny_v)
    ny_pv := ny_pv + hlc3 * volume
    ny_v := ny_v + volume
    ny_v
ny_vwap = ny_v > 0 ? ny_pv / ny_v : na

isNewDay = ta.change(time('D')) != 0

// =============================================================================
// 1M TRF (chart timeframe)
// =============================================================================

[trf_1m, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
// =============================================================================
// MULTI-TF STATES — ES HTF TRF + VIX TRF
// =============================================================================

nq_15m_bull = request.security(syminfo.tickerid, '15', f_bull(), lookahead = barmerge.lookahead_off)
nq_1h_bull = request.security(syminfo.tickerid, '60', f_bull(), lookahead = barmerge.lookahead_off)
nq_4h_bull = request.security(syminfo.tickerid, '240', f_bull(), lookahead = barmerge.lookahead_off)
nq_d_bull = request.security(syminfo.tickerid, 'D', f_bull(), lookahead = barmerge.lookahead_off)

vix_15m_bull = request.security(vix_symbol, '15', f_bull_simple(), lookahead = barmerge.lookahead_off)
vix_1h_bull = request.security(vix_symbol, '60', f_bull_simple(), lookahead = barmerge.lookahead_off)
vix_4h_bull = request.security(vix_symbol, '240', f_bull_simple(), lookahead = barmerge.lookahead_off)
vix_d_bull = request.security(vix_symbol, 'D', f_bull_simple(), lookahead = barmerge.lookahead_off)

htf_extra_count = (nq_1h_bull ? 1 : 0) + (nq_4h_bull ? 1 : 0) + (nq_d_bull ? 1 : 0)

// =============================================================================
// ATR
// =============================================================================

raw_atr = ta.atr(sl_atr_len)

// =============================================================================
// FRACTAL SWING LABELS (visual reference only — NOT used for entries)
// =============================================================================

is_swing_high_1m = high[2] < high[1] and high[0] < high[1] and barstate.isconfirmed
is_swing_low_1m = low[2] > low[1] and low[0] > low[1] and barstate.isconfirmed

var float sh_1m = na
var float sh_1m_prev = na
var float sl_1m = na
var float sl_1m_prev = na

if is_swing_high_1m
    sh_1m_prev := sh_1m
    sh_1m := high[1]
    sh_1m
if is_swing_low_1m
    sl_1m_prev := sl_1m
    sl_1m := low[1]
    sl_1m

is_hh_1m = is_swing_high_1m and not na(sh_1m) and not na(sh_1m_prev) and sh_1m > sh_1m_prev
is_lh_1m = is_swing_high_1m and not na(sh_1m) and not na(sh_1m_prev) and sh_1m < sh_1m_prev
is_hl_1m = is_swing_low_1m and not na(sl_1m) and not na(sl_1m_prev) and sl_1m > sl_1m_prev
is_ll_1m = is_swing_low_1m and not na(sl_1m) and not na(sl_1m_prev) and sl_1m < sl_1m_prev

// =============================================================================
// LONG ENTRY — VWAP-touch gated HH → HL → Break
// =============================================================================
// Swing pivots detected by candle-color transitions:
//   HIGH = max high from green run through red run (red candle highs included)
//   LOW  = min low of consecutive red candles, confirmed at red→green transition
//
// Pattern:
//   1) Swing high > prev swing high = HH (higher high)
//   2) Next swing low > prev swing low = HL (higher low — no lower low)
//   3) Price breaks above pullback candle's high = entry (buy stop at PB high)
//
// VWAP gating: touch arms. Entry fires → dormant until next touch.
// =============================================================================

// --- Swing detection state ---
var bool sw_was_green = true // previous bar's color (green = close >= open)
var float sw_run_high = na // max high of current green run
var float sw_run_low = na // min low of current red run
var float sw_pend_high = na // pending swing high (tracks max through red run)
var float sw_hi1 = na // most recent confirmed swing high
var float sw_hi2 = na // previous confirmed swing high
var float sw_lo1 = na // most recent confirmed swing low
var float sw_lo2 = na // previous confirmed swing low
var float sw_pb_high = na // max high of pullback (red) candles — used as break level

// --- Long entry state ---
var int long_st = 0 // 0=scan  1=break-wait  3=dormant
var float long_hh = na // HH break level
var float long_hl = na // HL reference level
var bool long_armed = false // VWAP touch has armed entry
var bool long_was_clear = true // edge detection for VWAP touch

if isNewDay
    sw_was_green := true
    sw_run_high := na
    sw_run_low := na
    sw_pend_high := na
    sw_hi1 := na
    sw_hi2 := na
    sw_lo1 := na
    sw_lo2 := na
    sw_pb_high := na
    long_st := 0
    long_hh := na
    long_hl := na
    long_armed := false
    long_was_clear := true
    long_was_clear

// --- VWAP touch detection ---
vwap_contact_bar = not na(overnight_vwap) and low <= overnight_vwap and high >= overnight_vwap or not na(ny_vwap) and low <= ny_vwap and high >= ny_vwap
long_touch_now = in_rth_session and barstate.isconfirmed and long_was_clear and vwap_contact_bar

// --- Above-VWAP check (entry gate only) ---
above_both = not na(overnight_vwap) and close > overnight_vwap and (na(ny_vwap) or close > ny_vwap)

// --- Signal flags ---
e2_fire = false
e2_quality = ''

// --- VWAP touch: arm the scanner ---
if long_touch_now
    long_armed := true
    if long_st == 3
        long_st := 0
        long_st

// --- Swing detection, pattern matching, and break detection ---
if in_rth_session and barstate.isconfirmed
    cur_green = close == open ? sw_was_green : close > open

    if sw_was_green and not cur_green
        // GREEN → RED: swing high candidate forming
        sw_pend_high := math.max(nz(sw_run_high, high), high)
        sw_run_low := low
        sw_pb_high := high // first red candle starts pullback tracking
        sw_pb_high
    else if not sw_was_green and cur_green
        // RED → GREEN: confirm swing high + swing low
        sw_hi2 := sw_hi1
        sw_hi1 := nz(sw_pend_high, high)
        sw_lo2 := sw_lo1
        sw_lo1 := nz(sw_run_low, low)

        // Check for HH → HL pattern
        if not na(sw_hi2) and not na(sw_lo2) and sw_hi1 > sw_hi2 and sw_lo1 > sw_lo2
            long_hh := nz(sw_pb_high, high) // break level = pullback candle's high, not swing HH
            long_hl := sw_lo1
            if long_st != 3
                long_st := 1
                long_st

        // Start new green run
        sw_run_high := high
        sw_run_high
    else if cur_green
        // Continuing green run
        sw_run_high := math.max(nz(sw_run_high, high), high)
        sw_run_high
    else // Continuing red run
        sw_run_low := math.min(nz(sw_run_low, low), low)
        sw_pend_high := math.max(nz(sw_pend_high, high), high)
        sw_pb_high := math.max(nz(sw_pb_high, high), high) // track pullback highs
        sw_pb_high

    sw_was_green := cur_green

    // --- Break detection (state 1: waiting for price to hit break level) ---
    if long_st == 1
        if high >= nz(long_hh, high + 1)
            // Break! Check entry gates.
            if long_armed and above_both and nq_15m_bull and signals_ok
                e2_fire := true
                e2_quality := htf_extra_count >= 2 ? '$$$' : htf_extra_count == 1 ? '$$' : '$'
                long_st := 3
                long_armed := false
                long_armed
        // Gates not met — stay in break-wait, try again next bar
        // Invalidation: price drops below HL
        else if low < nz(long_hl, 0)
            long_st := 0
            long_hh := na
            long_hl := na
            long_hl

// --- Edge detection update ---
if vwap_contact_bar
    long_was_clear := false
    long_was_clear
else
    long_was_clear := true
    long_was_clear

// =============================================================================
// SHORT ENTRY — Swing-pivot LL → LH → Break (continuous, no VWAP gating)
// =============================================================================
// Swing pivots via candle-color transitions (mirrored from long):
//   LOW  = min low from red run through green run (green candle lows included)
//   HIGH = max high of consecutive green candles, confirmed at green→red transition
//
// Pattern:
//   1) Swing low < prev swing low = LL (lower low)
//   2) Next swing high < prev swing high = LH (lower high — no higher high)
//   3) Price breaks below bounce candle's low = entry (sell stop at bounce low)
//
// No VWAP-touch gating. Continuous during RTH.
// Entry requires: below ON VWAP + VIX 15m green + signals_ok.
// Can fire multiple times per session.
// =============================================================================

// --- Short swing detection state ---
var bool ss_was_green = true // previous bar's color
var float ss_run_high = na // max high of current green run
var float ss_run_low = na // min low of current red run
var float ss_pend_low = na // pending swing low (tracks min through green run)
var float ss_hi1 = na // most recent confirmed swing high
var float ss_hi2 = na // previous confirmed swing high
var float ss_lo1 = na // most recent confirmed swing low
var float ss_lo2 = na // previous confirmed swing low
var float ss_pb_low = na // min low of bounce (green) candles — used as break level

// --- Short entry state ---
var int short_st = 0 // 0=scan  1=break-wait
var float short_ll = na // LL break level (sell stop)
var float short_lh = na // LH reference level

if isNewDay
    ss_was_green := true
    ss_run_high := na
    ss_run_low := na
    ss_pend_low := na
    ss_hi1 := na
    ss_hi2 := na
    ss_lo1 := na
    ss_lo2 := na
    ss_pb_low := na
    short_st := 0
    short_ll := na
    short_lh := na
    short_lh

e1_fire = false

// --- Short swing detection, pattern matching, and break detection ---
if in_rth_session and barstate.isconfirmed
    ss_cur_green = close == open ? ss_was_green : close > open

    if not ss_was_green and ss_cur_green
        // RED → GREEN: swing low candidate forming
        ss_pend_low := math.min(nz(ss_run_low, low), low)
        ss_run_high := high
        ss_pb_low := low // first green candle starts bounce tracking
        ss_pb_low
    else if ss_was_green and not ss_cur_green
        // GREEN → RED: confirm swing high + swing low
        ss_lo2 := ss_lo1
        ss_lo1 := nz(ss_pend_low, low)
        ss_hi2 := ss_hi1
        ss_hi1 := math.max(nz(ss_run_high, high), high)

        // Check for LL → LH pattern
        if not na(ss_lo2) and not na(ss_hi2) and ss_lo1 < ss_lo2 and ss_hi1 < ss_hi2
            short_ll := nz(ss_pb_low, low) // break level = bounce candle's low, not swing LL
            short_lh := ss_hi1
            short_st := 1
            short_st

        // Start new red run
        ss_run_low := low
        ss_run_low
    else if not ss_cur_green
        // Continuing red run
        ss_run_low := math.min(nz(ss_run_low, low), low)
        ss_run_low
    else // Continuing green run
        ss_run_high := math.max(nz(ss_run_high, high), high)
        ss_pend_low := math.min(nz(ss_pend_low, low), low)
        ss_pb_low := math.min(nz(ss_pb_low, low), low) // track bounce lows
        ss_pb_low

    ss_was_green := ss_cur_green

    // --- Short break detection (state 1: waiting for price to hit break level) ---
    if short_st == 1
        if low <= nz(short_ll, low - 1)
            // Break! Check entry gates.
            mc1_valid = not na(overnight_vwap) and close < overnight_vwap and vix_15m_bull and signals_ok
            if mc1_valid
                e1_fire := true
                short_st := 0
                short_ll := na
                short_lh := na
                short_lh
        // Gates not met — stay in break-wait, try again next bar
        // Invalidation: price breaks above LH
        else if high > nz(short_lh, high + 1)
            short_st := 0
            short_ll := na
            short_lh := na
            short_lh

// =============================================================================
// MARKET CONDITIONS (for display)
// =============================================================================

mc1_display = not na(overnight_vwap) and close < overnight_vwap and vix_15m_bull and signals_ok
mc2_display = above_both and nq_15m_bull and signals_ok

// =============================================================================
// COLORS
// =============================================================================

col_blue = color.new(#1565C0, 0)
col_blue_lt = color.new(#42A5F5, 0)
col_dark = color.new(#212121, 0)
col_dark_bg = color.new(#1A1A1A, 0)
col_hdr = color.new(#2C2C2C, 0)
col_white = color.white
col_red = color.new(#B71C1C, 0)
col_red_lt = color.new(#EF5350, 0)
col_gray = color.new(#78909C, 0)
col_purple = color.new(#AB47BC, 0)
col_amber = color.new(#FFA726, 0)
col_green = color.new(#66BB6A, 0)
col_gold = color.new(#FFD600, 0)

// =============================================================================
// PLOTS
// =============================================================================

plot(show_vwaps ? overnight_vwap : na, 'ON VWAP', color = col_purple, linewidth = 2)
plot(show_vwaps ? ny_vwap : na, 'NY VWAP', color = col_blue, linewidth = 2)

trf_bull = close > trf_1m
trf_color = trf_bull ? col_blue_lt : col_red_lt
plot(show_trf ? trf_1m : na, 'TRF', color = trf_color, linewidth = 2)

// =============================================================================
// SWING MARKERS (visual reference — fractal pivots, not tied to entries)
// =============================================================================

if show_pa and is_hh_1m
    label.new(bar_index - 1, high[1], 'HH', color = color.new(color.black, 100), textcolor = col_blue_lt, style = label.style_label_down, size = size.tiny)
if show_pa and is_lh_1m
    label.new(bar_index - 1, high[1], 'LH', color = color.new(color.black, 100), textcolor = col_red_lt, style = label.style_label_down, size = size.tiny)
if show_pa and is_hl_1m
    label.new(bar_index - 1, low[1], 'HL', color = color.new(color.black, 100), textcolor = col_blue_lt, style = label.style_label_up, size = size.tiny)
if show_pa and is_ll_1m
    label.new(bar_index - 1, low[1], 'LL', color = color.new(color.black, 100), textcolor = col_red_lt, style = label.style_label_up, size = size.tiny)

// =============================================================================
// ENTRY LEVEL LINES
// =============================================================================

// Long break level (active in break-wait — HH that needs to be broken)
var line long_stop_line = na
if show_levels and long_st == 1 and not na(long_hh)
    if na(long_stop_line)
        long_stop_line := line.new(bar_index, long_hh, bar_index + 1, long_hh, color = col_blue_lt, style = line.style_dashed, width = 1)
        long_stop_line
    else
        line.set_x2(long_stop_line, bar_index + 1)
        line.set_y1(long_stop_line, long_hh)
        line.set_y2(long_stop_line, long_hh)
else
    if not na(long_stop_line)
        long_stop_line := na
        long_stop_line

// Long HL level (active in break-wait — shows higher low)
var line long_hl_line = na
if show_levels and long_st == 1 and not na(long_hl)
    if na(long_hl_line)
        long_hl_line := line.new(bar_index, long_hl, bar_index + 1, long_hl, color = col_green, style = line.style_dotted, width = 1)
        long_hl_line
    else
        line.set_x2(long_hl_line, bar_index + 1)
else
    if not na(long_hl_line)
        long_hl_line := na
        long_hl_line

// Short break level (active in break-wait — LL that needs to be broken)
var line short_stop_line = na
if show_levels and short_st == 1 and not na(short_ll)
    if na(short_stop_line)
        short_stop_line := line.new(bar_index, short_ll, bar_index + 1, short_ll, color = col_red_lt, style = line.style_dashed, width = 1)
        short_stop_line
    else
        line.set_x2(short_stop_line, bar_index + 1)
        line.set_y1(short_stop_line, short_ll)
        line.set_y2(short_stop_line, short_ll)
else
    if not na(short_stop_line)
        short_stop_line := na
        short_stop_line

// Short LH level (active in break-wait — shows lower high)
var line short_lh_line = na
if show_levels and short_st == 1 and not na(short_lh)
    if na(short_lh_line)
        short_lh_line := line.new(bar_index, short_lh, bar_index + 1, short_lh, color = col_red, style = line.style_dotted, width = 1)
        short_lh_line
    else
        line.set_x2(short_lh_line, bar_index + 1)
else
    if not na(short_lh_line)
        short_lh_line := na
        short_lh_line

// =============================================================================
// SIGNAL LABELS
// =============================================================================

// E1 — Short
if show_signals and e1_fire
    label.new(bar_index, high, 'E1 $$$\nSHORT', color = col_red, textcolor = col_white, style = label.style_label_down, size = size.small)

// E2 — Long (quality-rated)
if show_signals and e2_fire
    label.new(bar_index, low, 'E2 ' + e2_quality + '\nLONG', color = col_blue, textcolor = col_white, style = label.style_label_up, size = size.small)

// DEBUG: show state + touch on every bar during RTH (toggle off when done testing)
show_debug = input.bool(false, 'Show State Debug', group = 'Display')
if show_debug and in_rth_session and barstate.isconfirmed
    d_st = long_st == 0 ? 'S' : long_st == 1 ? 'B' : 'D'
    d_arm = long_armed ? 'A' : ''
    d_ab = above_both ? '' : '!AV'
    d_15 = nq_15m_bull ? '' : '!15'
    d_txt = d_st + d_arm + d_ab + d_15
    label.new(bar_index, low * 0.9999, d_txt, color = color.new(color.gray, 80), textcolor = color.white, style = label.style_label_up, size = size.tiny)


// =============================================================================
// COMBINED TABLE (top right — trend + conditions)
// =============================================================================

var table tbl = table.new(position.top_right, 3, 13, bgcolor = col_dark_bg, border_width = 1, frame_color = color.new(#000000, 0))

if barstate.islast
    chk_off = color.new(#424242, 0)

    // --- Trend section ---
    table.cell(tbl, 0, 0, 'TF', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 1, 0, 'ES', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 2, 0, 'VIX', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)

    table.cell(tbl, 0, 1, '15m', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 1, nq_15m_bull ? '^' : 'v', text_color = nq_15m_bull ? col_blue_lt : col_red_lt, text_size = size.small)
    table.cell(tbl, 2, 1, vix_15m_bull ? '^' : 'v', text_color = vix_15m_bull ? col_blue_lt : col_red_lt, text_size = size.small)

    table.cell(tbl, 0, 2, '1h', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 2, nq_1h_bull ? '^' : 'v', text_color = nq_1h_bull ? col_blue_lt : col_red_lt, text_size = size.small)
    table.cell(tbl, 2, 2, vix_1h_bull ? '^' : 'v', text_color = vix_1h_bull ? col_blue_lt : col_red_lt, text_size = size.small)

    table.cell(tbl, 0, 3, '4h', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 3, nq_4h_bull ? '^' : 'v', text_color = nq_4h_bull ? col_blue_lt : col_red_lt, text_size = size.small)
    table.cell(tbl, 2, 3, vix_4h_bull ? '^' : 'v', text_color = vix_4h_bull ? col_blue_lt : col_red_lt, text_size = size.small)

    table.cell(tbl, 0, 4, 'D', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 4, nq_d_bull ? '^' : 'v', text_color = nq_d_bull ? col_blue_lt : col_red_lt, text_size = size.small)
    table.cell(tbl, 2, 4, vix_d_bull ? '^' : 'v', text_color = vix_d_bull ? col_blue_lt : col_red_lt, text_size = size.small)

    table.cell(tbl, 0, 5, 'ATR', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 1, 5, str.tostring(raw_atr, format.mintick), text_color = col_gray, bgcolor = col_hdr, text_size = size.small)
    table.cell(tbl, 2, 5, '', bgcolor = col_hdr)

    // --- Conditions section ---
    table.cell(tbl, 0, 6, 'MC1', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 1, 6, 'MC2', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 2, 6, '', bgcolor = col_hdr)

    table.cell(tbl, 0, 7, mc1_display ? '$$$' : '-', text_color = mc1_display ? col_red_lt : chk_off, text_size = size.small)
    e2_tbl = mc2_display ? htf_extra_count >= 2 ? '$$$' : htf_extra_count == 1 ? '$$' : '$' : '-'
    table.cell(tbl, 1, 7, e2_tbl, text_color = mc2_display ? col_blue_lt : chk_off, text_size = size.small)
    table.cell(tbl, 2, 7, '', text_size = size.small)

    // --- State machine section ---
    long_txt = long_st == 0 ? 'SCAN' : long_st == 1 ? 'BREAK' : 'DORM'
    long_col = long_st == 1 ? col_green : col_gray
    table.cell(tbl, 0, 8, 'LONG', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 8, long_txt, text_color = long_col, text_size = size.small)
    table.cell(tbl, 2, 8, '', text_size = size.tiny)

    short_txt = short_st == 0 ? 'SCAN' : 'BREAK'
    short_col = short_st == 1 ? col_green : col_gray
    table.cell(tbl, 0, 9, 'SHORT', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 9, short_txt, text_color = short_col, text_size = size.small)
    table.cell(tbl, 2, 9, '', text_size = size.tiny)

    // Long HH/HL levels
    hh_txt = long_st == 1 and not na(long_hh) ? str.tostring(long_hh, format.mintick) : '-'
    hl_txt = long_st == 1 and not na(long_hl) ? str.tostring(long_hl, format.mintick) : '-'
    table.cell(tbl, 0, 10, 'HH/HL', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 10, hh_txt, text_color = col_blue_lt, text_size = size.tiny)
    table.cell(tbl, 2, 10, hl_txt, text_color = col_blue_lt, text_size = size.tiny)

    // Short LL/LH levels
    ll_txt = short_st == 1 and not na(short_ll) ? str.tostring(short_ll, format.mintick) : '-'
    lh_txt = short_st == 1 and not na(short_lh) ? str.tostring(short_lh, format.mintick) : '-'
    table.cell(tbl, 0, 11, 'LL/LH', text_color = col_white, text_size = size.tiny)
    table.cell(tbl, 1, 11, ll_txt, text_color = col_red_lt, text_size = size.tiny)
    table.cell(tbl, 2, 11, lh_txt, text_color = col_red_lt, text_size = size.tiny)

    // Gates
    gate_ab = above_both ? 'V' : 'x'
    gate_15 = nq_15m_bull ? 'V' : 'x'
    gate_arm = long_armed ? 'V' : 'x'
    table.cell(tbl, 0, 12, 'Gates', text_color = col_white, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 1, 12, 'AV:' + gate_ab + ' 15:' + gate_15, text_color = col_gray, bgcolor = col_hdr, text_size = size.tiny)
    table.cell(tbl, 2, 12, 'ARM:' + gate_arm, text_color = col_gray, bgcolor = col_hdr, text_size = size.tiny)

// =============================================================================
// (ON VWAP touch labels removed — only entry signals are labeled)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(e1_fire, title = 'E1 Short', message = 'ES Morning: E1 SHORT signal')
alertcondition(e2_fire, title = 'E2 Long', message = 'ES Morning: E2 LONG signal')
any_signal = e1_fire or e2_fire
alertcondition(any_signal, title = 'Any Entry Signal', message = 'ES Morning: Entry signal triggered')

// =============================================================================
// CHART TIMEFRAME WARNING
// =============================================================================

if barstate.isfirst and timeframe.period != '1'
    label.new(bar_index, high, '⚠ Apply on 1-minute chart', color = col_amber, textcolor = col_dark, style = label.style_label_down, size = size.large)
````

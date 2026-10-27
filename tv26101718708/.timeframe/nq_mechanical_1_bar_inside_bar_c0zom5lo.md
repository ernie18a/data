# NQ Mechanical 1 Bar (inside bar)

- url: https://www.tradingview.com/script/C0ZoM5lo-NQ-Mechanical-1-Bar-inside-bar/
- type: indicator
- pine_id: PUB;d8c9de71f2024b38b5f0e07cf3fad9fc
- version: 1.0

## Description

If you don't trust yourself to stay mechanical, this takes the decision away. It finds an inside bar on the 5- or 15-minute and signals when the next bar breaks its high or low. Direction gets filtered three ways before it'll fire: which side of VWAP you're on, the 15-minute VIX regime, and timeframe continuity. Below VWAP it shorts into a rising-VIX read and only goes long when VIX is falling and continuity isn't against you. Let the inside bar set, take the break in the allowed direction. It pulls VIX and higher-timeframe data with lookahead, so confirm on replay, since the live read can lag the historical one.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ Mechanical IB - inside-bar breakouts
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  If you don't trust yourself to stay mechanical, this takes the decision
//  away. It finds an inside bar on the 5- or 15-minute and signals when the
//  next bar breaks its high or low. Direction gets filtered three ways before
//  it'll fire: which side of VWAP you're on, the 15-minute VIX regime, and
//  timeframe continuity. Below VWAP it shorts into a rising-VIX read and only
//  goes long when VIX is falling and continuity isn't against you. Let the
//  inside bar set, take the break in the allowed direction. It pulls VIX and
//  higher-timeframe data with lookahead, so confirm on replay, since the live
//  read can lag the historical one.
// ============================================================================
//
// =============================================================================
// NQ MECHANICAL INSIDE BAR STRATEGY
// =============================================================================
// Fully mechanical system for NQ futures.
//
// ENTRY LOGIC:
//   Inside bar (1) forms on 5m or 15m → next bar breaks high or low = signal.
//   Direction filtered by VWAP position, VIX 15m regime, and TFC state.
//
//   BELOW VWAP:
//     SHORT → VIX 15m UP + IB break down
//     LONG  → VIX 15m DOWN + TFC not red (green or middle) + IB break up
//
//   ABOVE VWAP:
//     LONG  → TFC GREEN + IB break up
//     SHORT → price crossed a key level + TFC middle or red + IB break down
//
//   Time window: 9:45 AM – 12:00 PM ET (entries only; trades can run)
//
// CHART ELEMENTS:
//   - VWAP + ±1σ / ±2σ standard deviation bands
//   - VIX 15m ON/OFF labels (marks regime flips on the chart)
//   - Key levels: PDH/PDL, Asia H/L, London H/L, 6PM Open
//   - Volume candle coloring (brighter = higher relative volume)
//   - Inside bar "1" labels on 5m and 15m only
//   - Entry signal labels (LONG / SHORT with context)
//   - Dashboard: VIX multi-TF, VWAP zone, TFC state, volume, window
//
// DESIGNED FOR: 5-minute chart, NQ futures (CME_MINI:NQ1!)
// =============================================================================

//@version=6
indicator(title='NQ Mechanical IB', shorttitle='NQ MIB', overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// =============================================================================
// INPUTS
// =============================================================================

// --- Display ---
grp_disp = 'Display'
show_vwap_bands    = input.bool(true,  'VWAP + σ Bands',                   group=grp_disp)
show_key_levels    = input.bool(true,  'Key Levels (PDH/PDL/Asia/London)', group=grp_disp)
show_table         = input.bool(true,  'Dashboard Table',                  group=grp_disp)
show_vol_color     = input.bool(true,  'Volume Candle Coloring',           group=grp_disp)
show_vix_marks     = input.bool(true,  'VIX ON/OFF Labels',               group=grp_disp)
show_ib_labels     = input.bool(true,  'Inside Bar (1) Labels',           group=grp_disp)
show_signals       = input.bool(true,  'Entry Signal Labels',             group=grp_disp)

// --- Symbols ---
grp_sym = 'Symbols'
vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol', group=grp_sym)

// --- VIX Twin Range Filter ---
grp_trf = 'VIX Twin Range Filter'
trf_per1  = input.int(27,    'TRF Fast Period',     minval=1,   group=grp_trf)
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval=0.1, group=grp_trf)
trf_per2  = input.int(55,    'TRF Slow Period',     minval=1,   group=grp_trf)
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval=0.1, group=grp_trf)

// --- TFC (Timeframe Continuity) ---
grp_tfc = 'Timeframe Continuity'
tfc_tf1 = input.timeframe('5',   'TF 1', group=grp_tfc)
tfc_tf2 = input.timeframe('15',  'TF 2', group=grp_tfc)
tfc_tf3 = input.timeframe('30',  'TF 3', group=grp_tfc)
tfc_tf4 = input.timeframe('60',  'TF 4', group=grp_tfc)
tfc_tf5 = input.timeframe('1D',  'TF 5', group=grp_tfc)
tfc_tf6 = input.timeframe('1W',  'TF 6', group=grp_tfc)

// --- Volume ---
grp_vol = 'Volume'
vol_ma_len = input.int(20, 'Volume MA Length', minval=1, group=grp_vol)
vol_spike  = input.float(1.5, 'Volume Spike Multiplier', minval=1.0, step=0.1, group=grp_vol)

// --- Session Times (ET) ---
grp_sess = 'Session Windows'
asia_start_h   = input.int(20, 'Asia Start Hour (ET)', minval=0, maxval=23, group=grp_sess)
asia_end_h     = input.int(1,  'Asia End Hour (ET)',   minval=0, maxval=23, group=grp_sess)
london_start_h = input.int(3,  'London Start Hour (ET)', minval=0, maxval=23, group=grp_sess)
london_end_h   = input.int(5,  'London End Hour (ET)',   minval=0, maxval=23, group=grp_sess)

// --- Inside Bar Detection ---
grp_ib = 'Inside Bar Detection'
ib_tf2 = input.timeframe('15', 'Higher TF for IB (15m default)', group=grp_ib)

TZ = 'America/New_York'

// =============================================================================
// TIME / SESSION HELPERS
// =============================================================================

ny_h = hour(time, TZ)
ny_m = minute(time, TZ)

hhmm = ny_h * 100 + ny_m

is_new_day = ta.change(time('D')) != 0

// 6 PM ET = futures session open
six_pm_ts      = timestamp(TZ, year, month, dayofmonth, 18, 0, 0)
is_new_session = time >= six_pm_ts and time[1] < six_pm_ts

// Entry window: 9:45 AM – 12:00 PM ET
in_entry_window = hhmm >= 945 and hhmm <= 1200

// RTH detection
is_rth = hhmm >= 930 and hhmm < 1600
was_rth = (hour(time[1], TZ) * 100 + minute(time[1], TZ)) >= 930 and (hour(time[1], TZ) * 100 + minute(time[1], TZ)) < 1600
rth_open = is_rth and not was_rth

// Detect first bar of RTH (9:30 ET)
is_rth_open = (ny_h == 9 and ny_m == 30) and not (hour(time[1], TZ) == 9 and minute(time[1], TZ) >= 30)

// =============================================================================
// VWAP + STANDARD DEVIATION BANDS (Session-anchored)
// =============================================================================

anchor = session.isfirstbar
[vwapLine, upper1, lower1] = ta.vwap(hlc3, anchor, 1.0)
[_,        upper2, lower2] = ta.vwap(hlc3, anchor, 2.0)

aboveVWAP = close > vwapLine
belowVWAP = close < vwapLine

// =============================================================================
// TRF CORE (for VIX regime detection)
// =============================================================================

f_smoothrng(x, t, m) =>
    wper  = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

f_rngfilt(x, r) =>
    v = x
    v := x > nz(v[1]) ? (x - r < nz(v[1]) ? nz(v[1]) : x - r) :
         (x + r > nz(v[1]) ? nz(v[1]) : x + r)
    v

f_trf_bull() =>
    src = close
    smrng = (f_smoothrng(src, trf_per1, trf_mult1) + f_smoothrng(src, trf_per2, trf_mult2)) / 2
    filt  = f_rngfilt(src, smrng)
    fub   = 0.0
    fub  := (filt + smrng) < nz(fub[1]) or close[1] > nz(fub[1]) ? filt + smrng : nz(fub[1])
    flb   = 0.0
    flb  := (filt - smrng) > nz(flb[1]) or close[1] < nz(flb[1]) ? filt - smrng : nz(flb[1])
    trf   = 0.0
    trf  := nz(trf[1]) == fub[1] and close <= fub ? fub :
         nz(trf[1]) == fub[1] and close >= fub ? flb :
         nz(trf[1]) == flb[1] and close >= flb ? flb :
         nz(trf[1]) == flb[1] and close <= flb ? fub : fub
    close > trf

// =============================================================================
// VIX REGIME (multi-TF)
// =============================================================================

vix_5m  = request.security(vix_symbol, '5',   f_trf_bull(), lookahead=barmerge.lookahead_on)
vix_15m = request.security(vix_symbol, '15',  f_trf_bull(), lookahead=barmerge.lookahead_on)
vix_1h  = request.security(vix_symbol, '60',  f_trf_bull(), lookahead=barmerge.lookahead_on)
vix_4h  = request.security(vix_symbol, '240', f_trf_bull(), lookahead=barmerge.lookahead_on)
vix_d   = request.security(vix_symbol, 'D',   f_trf_bull(), lookahead=barmerge.lookahead_on)

// VIX 15m is the primary gate: true = VIX rising (risk-off), false = VIX dropping (risk-on)
vix_15m_up   = vix_15m
vix_15m_down = not vix_15m

// VIX 15m flip detection (confirmed bars only)
vix_15m_flip_on  = barstate.isconfirmed and vix_15m and not vix_15m[1]
vix_15m_flip_off = barstate.isconfirmed and not vix_15m and vix_15m[1]

// If VIX is already on when RTH starts, mark it
vix_on_at_open = barstate.isconfirmed and is_rth_open and vix_15m
vix_15m_on  = vix_15m_flip_on or vix_on_at_open
vix_15m_off = vix_15m_flip_off

// =============================================================================
// TFC — TIMEFRAME CONTINUITY (exact logic from NQ TFC Companion)
// =============================================================================

// TF validity check
var bool can_tfc1 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf1)
var bool can_tfc2 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf2)
var bool can_tfc3 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf3)
var bool can_tfc4 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf4)
var bool can_tfc5 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf5)
var bool can_tfc6 = timeframe.in_seconds() <= timeframe.in_seconds(tfc_tf6)

var int tfc_num_tfs = (can_tfc1 ? 1 : 0) + (can_tfc2 ? 1 : 0) + (can_tfc3 ? 1 : 0) +
     (can_tfc4 ? 1 : 0) + (can_tfc5 ? 1 : 0) + (can_tfc6 ? 1 : 0)

// Track opens per TF
var float tfc_o1 = open
var float tfc_o2 = open
var float tfc_o3 = open
var float tfc_o4 = open
var float tfc_o5 = open
var float tfc_o6 = open

if can_tfc1 and timeframe.change(tfc_tf1)
    tfc_o1 := open
if can_tfc2 and timeframe.change(tfc_tf2)
    tfc_o2 := open
if can_tfc3 and timeframe.change(tfc_tf3)
    tfc_o3 := open
if can_tfc4 and timeframe.change(tfc_tf4)
    tfc_o4 := open
if can_tfc5 and timeframe.change(tfc_tf5)
    tfc_o5 := open
if can_tfc6 and timeframe.change(tfc_tf6)
    tfc_o6 := open

// Count bullish / bearish TFs
tfc_up = (can_tfc1 and close > tfc_o1 ? 1 : 0) + (can_tfc2 and close > tfc_o2 ? 1 : 0) +
     (can_tfc3 and close > tfc_o3 ? 1 : 0) + (can_tfc4 and close > tfc_o4 ? 1 : 0) +
     (can_tfc5 and close > tfc_o5 ? 1 : 0) + (can_tfc6 and close > tfc_o6 ? 1 : 0)

tfc_dn = (can_tfc1 and close < tfc_o1 ? 1 : 0) + (can_tfc2 and close < tfc_o2 ? 1 : 0) +
     (can_tfc3 and close < tfc_o3 ? 1 : 0) + (can_tfc4 and close < tfc_o4 ? 1 : 0) +
     (can_tfc5 and close < tfc_o5 ? 1 : 0) + (can_tfc6 and close < tfc_o6 ? 1 : 0)

// Net score: positive = bullish majority, negative = bearish majority
tfc_net = tfc_up - tfc_dn

// TFC STATE for entry logic:
//   GREEN  = tfc_net > 0 (bullish majority)
//   MIDDLE = tfc_net == 0 (neutral)
//   RED    = tfc_net < 0 (bearish majority)
tfc_green  = tfc_net > 0
tfc_middle = tfc_net == 0
tfc_red    = tfc_net < 0

// "Not red" = green or middle
tfc_not_red = tfc_green or tfc_middle

// FTFC states (full alignment)
ftfc_full_bull = tfc_up == tfc_num_tfs and tfc_num_tfs > 0
ftfc_full_bear = tfc_dn == tfc_num_tfs and tfc_num_tfs > 0

// =============================================================================
// VOLUME ANALYSIS
// =============================================================================

vol_ma      = ta.sma(volume, vol_ma_len)
vol_is_high = volume >= vol_ma * vol_spike
vol_ratio   = vol_ma > 0 ? volume / vol_ma : 1.0

// =============================================================================
// KEY LEVELS — PDH/PDL, Asia H/L, London H/L, 6PM Open
// =============================================================================

// --- Previous Day High / Low ---
prevDayHigh = request.security(syminfo.tickerid, 'D', high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, 'D', low[1],  lookahead=barmerge.lookahead_on)

// --- 6 PM Open ---
var float six_pm_open = na
if is_new_session
    six_pm_open := open

// --- Asia Session H/L ---
var float asia_high = na
var float asia_low  = na
var bool  asia_done = false

in_asia = (asia_start_h > asia_end_h) ?
     (ny_h >= asia_start_h or ny_h <= asia_end_h) :
     (ny_h >= asia_start_h and ny_h <= asia_end_h)

if is_new_session
    asia_high := na
    asia_low  := na
    asia_done := false

if in_asia and not asia_done
    asia_high := na(asia_high) ? high : math.max(asia_high, high)
    asia_low  := na(asia_low)  ? low  : math.min(asia_low, low)

if not in_asia and not na(asia_high) and not asia_done
    asia_done := true

// --- London Session H/L ---
var float london_high = na
var float london_low  = na
var bool  london_done = false

in_london = (ny_h >= london_start_h and ny_h < london_end_h)

if is_new_session
    london_high := na
    london_low  := na
    london_done := false

if in_london and not london_done
    london_high := na(london_high) ? high : math.max(london_high, high)
    london_low  := na(london_low)  ? low  : math.min(london_low, low)

if not in_london and not na(london_high) and not london_done
    london_done := true

// --- Key Level Sweep Detection (price crosses the level) ---
// Used for "above VWAP short" condition: price must have crossed a key level

f_crossed(level) =>
    not na(level) and (ta.cross(close, level) or ta.cross(high, level) or ta.cross(low, level))

key_level_crossed = f_crossed(prevDayHigh) or f_crossed(prevDayLow) or
     (asia_done and (f_crossed(asia_high) or f_crossed(asia_low))) or
     (london_done and (f_crossed(london_high) or f_crossed(london_low))) or
     f_crossed(six_pm_open)

// Track bars since last key level cross (lookback window for sweep condition)
var int bars_since_kl_cross = 999
bars_since_kl_cross := key_level_crossed ? 0 : bars_since_kl_cross + 1

// Recent key level cross = within last 5 bars on the chart TF
recent_kl_sweep = bars_since_kl_cross <= 5

// =============================================================================
// INSIDE BAR (1) DETECTION — 5m and 15m (The Strat Classification)
// =============================================================================
// A "1" bar (inside bar) = candle that does NOT break the previous candle's
// high or low. Strat definition: high <= prior high AND low >= prior low.
//
// Once a 1 forms and closes, the NEXT bar on that same timeframe that breaks
// the 1's high or low is the entry trigger.
//
// 5m: Detected directly on the chart (designed to run on a 5m chart).
// 15m: Detected via request.security so we see 15m candle structure.
// =============================================================================

// ── Strat classifier (same logic as your other indicators) ──
f_is_inside(_h, _l, _ph, _pl) =>
    _h <= _ph and _l >= _pl

// ─────────────────────────────────────────────────────────────
// 5m INSIDE BARS (chart timeframe — direct detection)
// ─────────────────────────────────────────────────────────────
// On a 5m chart, every bar IS a 5m candle, so we just compare
// the current closed bar to the prior bar.

// Was the PREVIOUS bar a 1? (we check [1] because we act on the current bar)
tf1_was_inside = f_is_inside(high[1], low[1], high[2], low[2])

// Track the 1 bar's range for break detection
var float tf1_ib_high   = na
var float tf1_ib_low    = na
var bool  tf1_ib_active = false

if barstate.isconfirmed
    if tf1_was_inside and not tf1_ib_active
        // A new 1 bar just closed on the prior bar — mark it
        tf1_ib_high   := high[1]
        tf1_ib_low    := low[1]
        tf1_ib_active := true

// Break detection: current bar (the one after the 1) breaks the range
tf1_break_up_now   = tf1_ib_active and barstate.isconfirmed and close > tf1_ib_high
tf1_break_down_now = tf1_ib_active and barstate.isconfirmed and close < tf1_ib_low

// Once broken (or if current bar is NOT inside the 1's range), reset
if tf1_break_up_now or tf1_break_down_now
    tf1_ib_active := false
// If price neither breaks up nor down and a NEW non-inside bar formed,
// the setup is stale — the next bar didn't trigger, reset
if tf1_ib_active and barstate.isconfirmed and not f_is_inside(high, low, tf1_ib_high, tf1_ib_low) and not tf1_break_up_now and not tf1_break_down_now
    tf1_ib_active := false

// ─────────────────────────────────────────────────────────────
// 15m INSIDE BARS (higher timeframe via request.security)
// ─────────────────────────────────────────────────────────────
// Get 15m bar data. With lookahead_off, values update only when
// the 15m bar closes, so high/low = last completed 15m candle.

[tf2_h, tf2_l, tf2_ph, tf2_pl] = request.security(syminfo.tickerid, ib_tf2,
     [high, low, high[1], low[1]], lookahead=barmerge.lookahead_off)

tf2_is_inside = f_is_inside(tf2_h, tf2_l, tf2_ph, tf2_pl)

var float tf2_ib_high   = na
var float tf2_ib_low    = na
var bool  tf2_ib_active = false

// When a new 15m bar starts, check if the PREVIOUS 15m bar was a 1
if timeframe.change(ib_tf2)
    if tf2_is_inside
        tf2_ib_high   := tf2_h
        tf2_ib_low    := tf2_l
        tf2_ib_active := true
    else
        tf2_ib_active := false

// Break: current chart bar's close breaks the 15m inside bar range
// Only fires once per IB
var bool tf2_broke = false

tf2_break_up_now   = tf2_ib_active and not tf2_broke and barstate.isconfirmed and close > tf2_ib_high
tf2_break_down_now = tf2_ib_active and not tf2_broke and barstate.isconfirmed and close < tf2_ib_low

if tf2_break_up_now or tf2_break_down_now
    tf2_broke := true
if timeframe.change(ib_tf2)
    tf2_broke := false
if not tf2_ib_active
    tf2_broke := false

// ─────────────────────────────────────────────────────────────
// AGGREGATE: any IB break from either timeframe
// ─────────────────────────────────────────────────────────────
any_ib_break_up   = tf1_break_up_now or tf2_break_up_now
any_ib_break_down = tf1_break_down_now or tf2_break_down_now

// Which TF triggered (for label info)
ib_break_tf = tf1_break_up_now ? '5m' : tf1_break_down_now ? '5m' :
     tf2_break_up_now ? '15m' : tf2_break_down_now ? '15m' : ''

// =============================================================================
// MECHANICAL ENTRY SIGNALS
// =============================================================================
//
// BELOW VWAP:
//   SHORT → VIX 15m UP + IB break down
//   LONG  → VIX 15m DOWN + TFC not red + IB break up
//
// ABOVE VWAP:
//   LONG  → TFC GREEN + IB break up
//   SHORT → recent key level cross + TFC middle or red + IB break down
//
// All signals require: in_entry_window AND barstate.isconfirmed

// --- LONG signals ---
long_below_vwap = belowVWAP and vix_15m_down and tfc_not_red and any_ib_break_up
long_above_vwap = aboveVWAP and tfc_green and any_ib_break_up

long_signal = (long_below_vwap or long_above_vwap) and in_entry_window and barstate.isconfirmed

// --- SHORT signals ---
short_below_vwap = belowVWAP and vix_15m_up and any_ib_break_down
short_above_vwap = aboveVWAP and recent_kl_sweep and (tfc_middle or tfc_red) and any_ib_break_down

short_signal = (short_below_vwap or short_above_vwap) and in_entry_window and barstate.isconfirmed

// Signal context (for labels)
long_context  = long_below_vwap  ? 'Below VWAP | VIX↓ | TFC OK' : 'Above VWAP | TFC Green'
short_context = short_below_vwap ? 'Below VWAP | VIX↑' : 'Above VWAP | KL Sweep | TFC ≤Mid'

// =============================================================================
// VOLUME CANDLE COLORING
// =============================================================================

vol_alpha = vol_ratio >= 2.0 ? 0 : vol_ratio >= 1.5 ? 10 : vol_ratio >= 1.0 ? 30 : 60

bull_candle = close >= open
bear_candle = close < open

vol_bull_color = color.new(#26A69A, vol_alpha)
vol_bear_color = color.new(#EF5350, vol_alpha)
vol_doji_color = color.new(#78909C, vol_alpha)

candle_color = bull_candle ? vol_bull_color : bear_candle ? vol_bear_color : vol_doji_color
barcolor(show_vol_color ? candle_color : na, title='Volume Candle Color')

// =============================================================================
// PLOTS — VWAP + BANDS
// =============================================================================

plot(show_vwap_bands ? vwapLine : na, title='VWAP', color=color.new(#FFB300, 0), linewidth=2)
plot(show_vwap_bands ? upper1   : na, title='+1σ',  color=color.new(#4FC3F7, 40), linewidth=1)
plot(show_vwap_bands ? lower1   : na, title='-1σ',  color=color.new(#4FC3F7, 40), linewidth=1)
plot(show_vwap_bands ? upper2   : na, title='+2σ',  color=color.new(#CE93D8, 40), linewidth=1)
plot(show_vwap_bands ? lower2   : na, title='-2σ',  color=color.new(#CE93D8, 40), linewidth=1)

// Fill between bands
p_u1 = plot(show_vwap_bands ? upper1 : na, display=display.none)
p_l1 = plot(show_vwap_bands ? lower1 : na, display=display.none)
p_u2 = plot(show_vwap_bands ? upper2 : na, display=display.none)
p_l2 = plot(show_vwap_bands ? lower2 : na, display=display.none)

fill(p_u1, p_l1, color=color.new(#4FC3F7, 92), title='±1σ Zone')
fill(p_u2, p_u1, color=color.new(#CE93D8, 94), title='+1σ to +2σ Zone')
fill(p_l1, p_l2, color=color.new(#CE93D8, 94), title='-1σ to -2σ Zone')

// =============================================================================
// PLOTS — KEY LEVELS
// =============================================================================

plot(show_key_levels ? prevDayHigh : na, title='PDH', color=color.new(#AB47BC, 30), linewidth=2, style=plot.style_stepline)
plot(show_key_levels ? prevDayLow  : na, title='PDL', color=color.new(#AB47BC, 30), linewidth=2, style=plot.style_stepline)

plot(show_key_levels and asia_done ? asia_high : na, title='Asia High', color=color.new(#FF7043, 40), linewidth=1, style=plot.style_stepline)
plot(show_key_levels and asia_done ? asia_low  : na, title='Asia Low',  color=color.new(#FF7043, 40), linewidth=1, style=plot.style_stepline)

plot(show_key_levels and london_done ? london_high : na, title='London High', color=color.new(#42A5F5, 40), linewidth=1, style=plot.style_stepline)
plot(show_key_levels and london_done ? london_low  : na, title='London Low',  color=color.new(#42A5F5, 40), linewidth=1, style=plot.style_stepline)

plot(show_key_levels and not na(six_pm_open) ? six_pm_open : na, title='6PM Open', color=color.new(#78909C, 30), linewidth=1, style=plot.style_stepline)

// =============================================================================
// VIX ON/OFF LABELS
// =============================================================================

c_red_label = color.new(#B71C1C, 0)
c_grn_label = color.new(#2E7D32, 0)

if show_vix_marks and vix_15m_on
    label.new(bar_index, low, 'VIX ON',
         color=c_red_label, textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

if show_vix_marks and vix_15m_off
    label.new(bar_index, high, 'VIX OFF',
         color=c_grn_label, textcolor=color.white,
         style=label.style_label_down, size=size.tiny)

// =============================================================================
// INSIDE BAR "1" LABELS — 5m and 15m only
// =============================================================================

if show_ib_labels and barstate.isconfirmed
    // Label 5m inside bars: the CURRENT bar just closed as a 1
    // (we label it on the bar itself, not on the break bar)
    if f_is_inside(high, low, high[1], low[1])
        label.new(bar_index, high, '1\n5m',
             color=color.new(color.black, 100), textcolor=color.new(#78909C, 0),
             style=label.style_label_down, size=size.tiny)

    // Label 15m inside bars: detected when a new 15m bar starts
    if timeframe.change(ib_tf2) and tf2_is_inside
        label.new(bar_index, high, '1\n15m',
             color=color.new(color.black, 100), textcolor=color.new(#FFB300, 0),
             style=label.style_label_down, size=size.tiny)

// =============================================================================
// ENTRY SIGNAL LABELS
// =============================================================================

if show_signals and long_signal
    lbl_text = 'LONG\n' + ib_break_tf + ' IB Break\n' + long_context
    label.new(bar_index, low, lbl_text,
         color=color.new(#00C853, 10), textcolor=color.white,
         style=label.style_label_up, size=size.small)

if show_signals and short_signal
    lbl_text = 'SHORT\n' + ib_break_tf + ' IB Break\n' + short_context
    label.new(bar_index, high, lbl_text,
         color=color.new(#FF1744, 10), textcolor=color.white,
         style=label.style_label_down, size=size.small)

// =============================================================================
// KEY LEVEL LABELS (once per day / session)
// =============================================================================

if show_key_levels and is_new_day and barstate.isconfirmed
    if not na(prevDayHigh)
        label.new(bar_index, prevDayHigh, 'PDH', color=color.new(color.black, 100),
             textcolor=color.new(#AB47BC, 0), style=label.style_label_left, size=size.tiny)
        label.new(bar_index, prevDayLow, 'PDL', color=color.new(color.black, 100),
             textcolor=color.new(#AB47BC, 0), style=label.style_label_left, size=size.tiny)

if show_key_levels and asia_done and not asia_done[1]
    label.new(bar_index, asia_high, 'Asia H', color=color.new(color.black, 100),
         textcolor=color.new(#FF7043, 0), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, asia_low, 'Asia L', color=color.new(color.black, 100),
         textcolor=color.new(#FF7043, 0), style=label.style_label_left, size=size.tiny)

if show_key_levels and london_done and not london_done[1]
    label.new(bar_index, london_high, 'London H', color=color.new(color.black, 100),
         textcolor=color.new(#42A5F5, 0), style=label.style_label_left, size=size.tiny)
    label.new(bar_index, london_low, 'London L', color=color.new(color.black, 100),
         textcolor=color.new(#42A5F5, 0), style=label.style_label_left, size=size.tiny)

if show_key_levels and is_new_session
    label.new(bar_index, six_pm_open, '6PM', color=color.new(color.black, 100),
         textcolor=color.new(#78909C, 0), style=label.style_label_left, size=size.tiny)

// =============================================================================
// DASHBOARD TABLE
// =============================================================================

var table tbl = table.new(position.top_right, 2, 12,
     bgcolor=color.new(#1A1A1A, 0), border_width=1,
     frame_color=color.new(#000000, 0))

c_white = color.white
c_hdr   = color.new(#2C2C2C, 0)
c_dn    = color.new(#EF5350, 0)
c_gray  = color.new(#78909C, 0)
c_green = color.new(#66BB6A, 0)
c_amber = color.new(#FFB300, 0)

if barstate.islast and show_table
    // Header
    table.cell(tbl, 0, 0, 'NQ MIB', text_color=c_white, bgcolor=c_hdr, text_size=size.small)
    table.cell(tbl, 1, 0, 'v1.0',   text_color=c_gray,  bgcolor=c_hdr, text_size=size.small)

    // VIX 5m
    table.cell(tbl, 0, 1, 'VIX 5m',  text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 1, vix_5m ? '▲' : '▼', text_color=vix_5m ? c_dn : c_green, text_size=size.small)

    // VIX 15m (PRIMARY)
    table.cell(tbl, 0, 2, 'VIX 15m', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 2, vix_15m ? '▲ ON' : '▼ OFF', text_color=vix_15m ? c_dn : c_green, text_size=size.small)

    // VIX 1h
    table.cell(tbl, 0, 3, 'VIX 1h',  text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 3, vix_1h ? '▲' : '▼', text_color=vix_1h ? c_dn : c_green, text_size=size.small)

    // VIX 4h
    table.cell(tbl, 0, 4, 'VIX 4h',  text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 4, vix_4h ? '▲' : '▼', text_color=vix_4h ? c_dn : c_green, text_size=size.small)

    // VIX D
    table.cell(tbl, 0, 5, 'VIX D',   text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 5, vix_d ? '▲' : '▼', text_color=vix_d ? c_dn : c_green, text_size=size.small)

    // Separator
    table.cell(tbl, 0, 6, '', bgcolor=c_hdr)
    table.cell(tbl, 1, 6, '', bgcolor=c_hdr)

    // VWAP Zone
    zone_txt = close > upper2 ? '> +2σ' : close > upper1 ? '> +1σ' :
         close < lower2 ? '< -2σ' : close < lower1 ? '< -1σ' :
         aboveVWAP ? 'Above' : belowVWAP ? 'Below' : 'At VWAP'
    zone_clr = aboveVWAP ? c_green : belowVWAP ? c_dn : c_gray
    table.cell(tbl, 0, 7, 'VWAP', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 7, zone_txt, text_color=zone_clr, text_size=size.small)

    // TFC State
    tfc_txt = ftfc_full_bull ? 'FTFC ▲' : ftfc_full_bear ? 'FTFC ▼' :
         tfc_green ? str.tostring(tfc_up) + '/' + str.tostring(tfc_num_tfs) + ' ▲' :
         tfc_red   ? str.tostring(tfc_dn) + '/' + str.tostring(tfc_num_tfs) + ' ▼' :
         str.tostring(tfc_up) + '/' + str.tostring(tfc_num_tfs) + ' —'
    tfc_clr = tfc_green ? c_green : tfc_red ? c_dn : c_gray
    table.cell(tbl, 0, 8, 'TFC', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 8, tfc_txt, text_color=tfc_clr, text_size=size.small)

    // Volume
    vol_txt = vol_is_high ? 'SPIKE' : str.tostring(vol_ratio, '#.#') + 'x'
    vol_clr = vol_is_high ? c_amber : c_gray
    table.cell(tbl, 0, 9, 'VOL', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 9, vol_txt, text_color=vol_clr, text_size=size.small)

    // IB Status
    ib_txt = tf1_ib_active and tf2_ib_active ? '5m + 15m' :
         tf1_ib_active ? '5m' : tf2_ib_active ? '15m' : 'None'
    ib_clr = (tf1_ib_active or tf2_ib_active) ? c_amber : c_gray
    table.cell(tbl, 0, 10, 'IB', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 10, ib_txt, text_color=ib_clr, text_size=size.small)

    // Window Status
    table.cell(tbl, 0, 11, 'WINDOW', text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 11, in_entry_window ? '● LIVE' : '○ CLOSED',
         text_color=in_entry_window ? c_green : c_gray, text_size=size.small)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(long_signal,  title='MIB Long Signal',  message='NQ MIB: LONG — Inside bar break up — {{close}}')
alertcondition(short_signal, title='MIB Short Signal', message='NQ MIB: SHORT — Inside bar break down — {{close}}')
alertcondition(long_signal or short_signal, title='MIB Any Signal', message='NQ MIB: Signal fired — {{close}}')
alertcondition(vix_15m_on,  title='VIX 15m ON',  message='NQ MIB: VIX 15m turned ON — risk-off')
alertcondition(vix_15m_off, title='VIX 15m OFF', message='NQ MIB: VIX 15m turned OFF — risk-on')

// =============================================================================
// INSIDE BAR RANGE VISUALIZATION
// =============================================================================
// Draw a subtle box showing the IB range when active (helps see the break zone)

var box tf1_ib_box = na
var box tf2_ib_box = na

// 5m IB box: show range while waiting for break
if tf1_ib_active
    if not na(tf1_ib_box)
        box.set_right(tf1_ib_box, bar_index)
    else
        tf1_ib_box := box.new(bar_index - 1, tf1_ib_high, bar_index, tf1_ib_low,
             border_color=color.new(#78909C, 60), bgcolor=color.new(#78909C, 92),
             border_width=1, border_style=line.style_dotted)
else
    tf1_ib_box := na

// 15m IB box: show range while waiting for break
if tf2_ib_active and not tf2_broke
    if not na(tf2_ib_box)
        box.set_right(tf2_ib_box, bar_index)
    else
        tf2_ib_box := box.new(bar_index - 1, tf2_ib_high, bar_index, tf2_ib_low,
             border_color=color.new(#FFB300, 60), bgcolor=color.new(#FFB300, 94),
             border_width=1, border_style=line.style_dotted)
else
    tf2_ib_box := na
````

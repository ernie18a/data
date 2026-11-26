# Combined System (momentum or mean reversion)

- url: https://www.tradingview.com/script/OjSUEYZB-Combined-System-momentum-or-mean-reversion/
- type: indicator
- pine_id: PUB;9d4d8e6a93df4e7b865a8cb681806092
- version: 1.0

## Description

This runs my momentum and mean-reversion logic at the same time, under one VIX filter, on the 1-minute NQ. Momentum side: a 1m Twin Range Filter cross going with the 15-minute, where longs also want the 1h or 4h on board, VIX falling, and price not already stretched, while shorts want VIX rising. Mean-reversion side: a Strat reversal inside a VWAP stretch zone, long when VIX is falling, short when it's rising or price is overextended. Everything gets a 2.2x ATR(14) stop. Running both means momentum catches the trend days and the reversion side catches the fades momentum would miss, while VIX keeps either one from fighting the tape. The prints are a checklist, not a robot. It pulls VIX and higher-timeframe data with lookahead, so confirm on replay.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ Combined System - momentum and mean reversion
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  This runs my momentum and mean-reversion logic at the same time, under one
//  VIX filter, on the 1-minute NQ. Momentum side: a 1m Twin Range Filter
//  cross going with the 15-minute, where longs also want the 1h or 4h on
//  board, VIX falling, and price not already stretched, while shorts want VIX
//  rising. Mean-reversion side: a Strat reversal inside a VWAP stretch zone,
//  long when VIX is falling, short when it's rising or price is overextended.
//  Everything gets a 2.2x ATR(14) stop. Running both means momentum catches
//  the trend days and the reversion side catches the fades momentum would
//  miss, while VIX keeps either one from fighting the tape. The prints are a
//  checklist, not a robot. It pulls VIX and higher-timeframe data with
//  lookahead, so confirm on replay.
// ============================================================================
//
// =============================================================================
// NQ COMBINED SYSTEM — Momentum + Mean Reversion + Regime
// =============================================================================
// Apply on a 1-minute chart of NQ futures.
//
// Signal types:
//   Momo Long  : 1m TRF cross + NQ 15m bull + (1h or 4h bull) + VIX 15m down + not overextended
//   Momo Short : 1m TRF cross + NQ 15m bear + VIX 15m up
//   MR Long    : Strat bull pattern in zone + VIX 15m down
//   MR Short   : Strat bear pattern in zone + (VIX 15m up or overextended)
//   Stops      : 2.2 × ATR(14) on all signals
// =============================================================================

//@version=6
indicator(title='NQ Combined System', shorttitle='NQ Sys', overlay=true, max_labels_count=500, max_lines_count=200)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// TRF
trf_per1  = input.int(27,    'TRF Fast Period',     minval=1,   group='Twin Range Filter')
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval=0.1, group='Twin Range Filter')
trf_per2  = input.int(55,    'TRF Slow Period',     minval=1,   group='Twin Range Filter')
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval=0.1, group='Twin Range Filter')

// Regime Score
vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol',        group='Regime Score')
w_15m      = input.float(50.0, '15m Weight (%)',   minval=0, maxval=100, group='Regime Score')
w_1h       = input.float(20.0, '1h Weight (%)',    minval=0, maxval=100, group='Regime Score')
w_4h       = input.float(20.0, '4h Weight (%)',    minval=0, maxval=100, group='Regime Score')
w_d        = input.float(10.0, 'Daily Weight (%)', minval=0, maxval=100, group='Regime Score')
state_high = input.int(60, 'HIGH Threshold (>)', minval=51, maxval=99, group='Regime Score')
state_low  = input.int(40, 'LOW Threshold (<)',  minval=1,  maxval=49, group='Regime Score')

// Overextension
ext_atr_len = input.int(7,      'Daily ATR Period',            minval=1,              group='Overextension')
ext_thresh  = input.float(0.75, 'Range Threshold (fraction)',  minval=0.1, step=0.05, group='Overextension')

// Stop Loss
sl_atr_len  = input.int(14,    'Stop ATR Period',     minval=1,            group='Stop Loss')
sl_atr_mult = input.float(2.2, 'Stop ATR Multiplier', minval=0.1, step=0.1, group='Stop Loss')

// Display
show_vwaps        = input.bool(true,  'VWAPs',                group='Display')
show_bands        = input.bool(true,  '±1σ / ±2σ Bands',      group='Display')
show_or           = input.bool(true,  'Opening Range',         group='Display')
show_trf          = input.bool(true,  '1m TRF Line',           group='Display')
show_exp_range    = input.bool(true,  'Expected Daily Range',  group='Display')
show_momo_signals = input.bool(true,  'Momentum Signals',      group='Display')
show_mr_signals   = input.bool(true,  'Mean-Rev Signals',      group='Display')
show_stops        = input.bool(true,  'Stop Lines',            group='Display')
show_regime       = input.bool(true,  'Regime Table',          group='Display')
show_conditions   = input.bool(true,  'Conditions Panel',      group='Display')
show_candle_type  = input.bool(false, 'Debug: Candle Type',    group='Display')
show_pattern_type = input.bool(false, 'Debug: Pattern Type',   group='Display')
table_pos = input.string('top_right', 'Regime Table Position',
     options=['top_left','top_center','top_right','middle_left','middle_right',
              'bottom_left','bottom_center','bottom_right'], group='Display')

session_tz = 'America/New_York'

// ═══════════════════════════════════════════════════════════════════════════════
// TRF FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

f_smoothrng(x, t, m) =>
    wper  = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

f_rngfilt(x, r) =>
    v = x
    v := x > nz(v[1]) ? (x - r < nz(v[1]) ? nz(v[1]) : x - r) : (x + r > nz(v[1]) ? nz(v[1]) : x + r)
    v

f_trf(src, p1, m1, p2, m2) =>
    smrng = (f_smoothrng(src, p1, m1) + f_smoothrng(src, p2, m2)) / 2
    filt  = f_rngfilt(src, smrng)
    fub   = 0.0
    fub  := (filt + smrng) < nz(fub[1]) or close[1] > nz(fub[1]) ? filt + smrng : nz(fub[1])
    flb   = 0.0
    flb  := (filt - smrng) > nz(flb[1]) or close[1] < nz(flb[1]) ? filt - smrng : nz(flb[1])
    trf   = 0.0
    trf  := nz(trf[1]) == fub[1] and close <= fub ? fub : nz(trf[1]) == fub[1] and close >= fub ? flb : nz(trf[1]) == flb[1] and close >= flb ? flb : nz(trf[1]) == flb[1] and close <= flb ? fub : fub
    [trf, ta.crossover(close, trf), ta.crossunder(close, trf)]

// NQ confirmed-close state (previous bar's close vs line — stable, non-repainting)
f_bull() =>
    [line, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close[1] > line[1]

// VIX responsive state (current close vs line — more reactive to VIX changes)
f_bull_simple() =>
    [line, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close > line

// ═══════════════════════════════════════════════════════════════════════════════
// SESSION / TIME
// ═══════════════════════════════════════════════════════════════════════════════

ny_hour      = hour(time, session_tz)
ny_min       = minute(time, session_tz)
ny_hour_prev = hour(time[1], session_tz)
ny_min_prev  = minute(time[1], session_tz)

new_overnight_anchor = (ny_hour == 18 and ny_min == 0) and not (ny_hour_prev == 18 and ny_min_prev == 0)
new_ny_anchor        = (ny_hour == 9  and ny_min == 30) and not (ny_hour_prev == 9  and ny_min_prev == 30)

in_rth_session = (ny_hour == 9 and ny_min >= 30) or (ny_hour > 9 and ny_hour < 12) or (ny_hour == 12 and ny_min == 0)
in_or_window   = ny_hour == 9 and ny_min >= 30 and ny_min < 45

// Signals only allowed after the 9:44 candle closes (first signal on 9:45 bar)
signals_ok = in_rth_session and (ny_hour > 9 or (ny_hour == 9 and ny_min >= 45))

// ═══════════════════════════════════════════════════════════════════════════════
// MULTI-TF TRF + VIX STATES
// ═══════════════════════════════════════════════════════════════════════════════

// 1-minute TRF (entry trigger for momentum)
[trf_1m, long_1m_raw, short_1m_raw] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
long_1m  = long_1m_raw  and barstate.isconfirmed
short_1m = short_1m_raw and barstate.isconfirmed

// NQ TRF states across timeframes (confirmed close-based)
nq_15m_bull = request.security(syminfo.tickerid, '15',  f_bull(), lookahead=barmerge.lookahead_on)
nq_1h_bull  = request.security(syminfo.tickerid, '60',  f_bull(), lookahead=barmerge.lookahead_on)
nq_4h_bull  = request.security(syminfo.tickerid, '240', f_bull(), lookahead=barmerge.lookahead_on)
nq_d_bull   = request.security(syminfo.tickerid, 'D',   f_bull(), lookahead=barmerge.lookahead_on)

// VIX TRF states across timeframes (responsive — current close vs line)
vix_15m_bull = request.security(vix_symbol, '15',  f_bull_simple(), lookahead=barmerge.lookahead_on)
vix_1h_bull  = request.security(vix_symbol, '60',  f_bull_simple(), lookahead=barmerge.lookahead_on)
vix_4h_bull  = request.security(vix_symbol, '240', f_bull_simple(), lookahead=barmerge.lookahead_on)
vix_d_bull   = request.security(vix_symbol, 'D',   f_bull_simple(), lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════════════════════
// REGIME SCORE + STATE (informational — shown in table, not used as signal filter)
// ═══════════════════════════════════════════════════════════════════════════════

nq_score  = (nq_15m_bull  ? w_15m : 0.0) + (nq_1h_bull  ? w_1h : 0.0) + (nq_4h_bull  ? w_4h : 0.0) + (nq_d_bull  ? w_d : 0.0)
vix_score = (vix_15m_bull ? w_15m : 0.0) + (vix_1h_bull ? w_1h : 0.0) + (vix_4h_bull ? w_4h : 0.0) + (vix_d_bull ? w_d : 0.0)

nq_h = nq_score > state_high
nq_l = nq_score < state_low
vix_h = vix_score > state_high
vix_l = vix_score < state_low

state_label = nq_h and vix_h ? 'BREAKOUT LONG' : nq_l and vix_h ? 'BREAKOUT SHORT' : nq_h and vix_l ? 'FADE LONG' : nq_l and vix_l ? 'FADE SHORT' : 'MIXED'

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP ARCHITECTURE
// ═══════════════════════════════════════════════════════════════════════════════

// Overnight VWAP (6pm ET anchor — visual reference for directional context)
var float on_pv = na
var float on_v  = na
if new_overnight_anchor
    on_pv := 0.0
    on_v  := 0.0
if not na(on_v)
    on_pv := on_pv + hlc3 * volume
    on_v  := on_v  + volume
overnight_vwap = on_v > 0 ? on_pv / on_v : na

// Overnight open (6pm ET — anchor for expected daily range)
var float overnight_open = na
if new_overnight_anchor
    overnight_open := close

// Session VWAP + ±1σ / ±2σ bands (9:30am anchor — used for MR zones + overextension)
[session_vwap, upper1, lower1] = ta.vwap(hlc3, session.isfirstbar_regular, 1.0)
[_,            upper2, lower2] = ta.vwap(hlc3, session.isfirstbar_regular, 2.0)

// ═══════════════════════════════════════════════════════════════════════════════
// OPENING RANGE (visual reference)
// ═══════════════════════════════════════════════════════════════════════════════

var float or_high = na
var float or_low  = na
if new_ny_anchor
    or_high := high
    or_low  := low
if in_or_window and not na(or_high)
    or_high := math.max(or_high, high)
    or_low  := math.min(or_low,  low)

// ═══════════════════════════════════════════════════════════════════════════════
// ATR + OVEREXTENSION
// ═══════════════════════════════════════════════════════════════════════════════

// Stop-loss ATR (1-minute, for signal stops)
sl_atr = ta.atr(sl_atr_len) * sl_atr_mult

// Daily ATR (previous completed day — expected daily range)
daily_atr = request.security(syminfo.tickerid, 'D', ta.atr(ext_atr_len)[1], lookahead=barmerge.lookahead_on)

// Range consumed from overnight open as fraction of expected daily range (signed: + = up, - = down)
range_pct = daily_atr > 0 and not na(overnight_open) ? (close - overnight_open) / daily_atr : 0.0

// Overextended upside: beyond +2σ band OR consumed ≥ threshold of expected range
overext_up = (not na(upper2) and close >= upper2) or range_pct >= ext_thresh

// Overextended downside: beyond -2σ band OR consumed ≥ threshold downward
overext_down = (not na(lower2) and close <= lower2) or range_pct <= -ext_thresh

// Expected range boundaries (for visual)
exp_range_high = not na(overnight_open) and not na(daily_atr) ? overnight_open + daily_atr : na
exp_range_low  = not na(overnight_open) and not na(daily_atr) ? overnight_open - daily_atr : na

// ═══════════════════════════════════════════════════════════════════════════════
// CANDLE CLASSIFICATION + STRAT PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

// 1 = inside | 2 = 2U (breaks prev high) | -2 = 2D (breaks prev low) | 3 = outside
f_classify(_h, _l, _ph, _pl) =>
    isOutside = _h > _ph and _l < _pl
    isInside  = _h <= _ph and _l >= _pl
    isOutside ? 3 : isInside ? 1 : _h > _ph ? 2 : -2

candleType = f_classify(high, low, high[1], low[1])

// Pattern detection (indexed: [2] = two bars ago, [1] = prev, [0] = current)
bull_322 = candleType[2] == 3  and candleType[1] == -2 and candleType[0] == 2
bear_322 = candleType[2] == 3  and candleType[1] == 2  and candleType[0] == -2
bull_312 = candleType[2] == 3  and candleType[1] == 1  and candleType[0] == 2
bear_312 = candleType[2] == 3  and candleType[1] == 1  and candleType[0] == -2
bull_22  = candleType[1] == -2 and candleType[0] == 2
bear_22  = candleType[1] == 2  and candleType[0] == -2

// ═══════════════════════════════════════════════════════════════════════════════
// MR ZONE LOGIC
// ═══════════════════════════════════════════════════════════════════════════════
// ANY candle in the pattern — open OR close — validates the zone.
// Long zone = at or below -1σ | Short zone = at or above +1σ
// Band values are checked at each candle's own bar (contemporaneous).

// 3-bar patterns: check [2], [1], [0]
zone_long_3bar = open[2] <= lower1[2] or close[2] <= lower1[2] or open[1] <= lower1[1] or close[1] <= lower1[1] or open[0] <= lower1[0] or close[0] <= lower1[0]

zone_short_3bar = open[2] >= upper1[2] or close[2] >= upper1[2] or open[1] >= upper1[1] or close[1] >= upper1[1] or open[0] >= upper1[0] or close[0] >= upper1[0]

// 2-bar patterns: must be OUTSIDE ±2σ (more extreme zone)
zone_long_2bar = open[1] < lower2[1] or close[1] < lower2[1] or open[0] < lower2[0] or close[0] < lower2[0]

zone_short_2bar = open[1] > upper2[1] or close[1] > upper2[1] or open[0] > upper2[0] or close[0] > upper2[0]

// Pattern name (for MR signal labels)
long_pattern  = bull_322 ? '3-2-2' : bull_312 ? '3-1-2' : bull_22 ? '2-2' : ''
short_pattern = bear_322 ? '3-2-2' : bear_312 ? '3-1-2' : bear_22 ? '2-2' : ''

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL GENERATION
// ═══════════════════════════════════════════════════════════════════════════════

// --- Momentum Long ---
// 1m TRF cross + VIX 15m down + NQ 15m bull + (1h or 4h bull) + not overextended
sig_momo_long = long_1m and not vix_15m_bull and nq_15m_bull and (nq_1h_bull or nq_4h_bull) and not overext_up and signals_ok

// --- Momentum Short ---
// 1m TRF cross + NQ 15m bear + VIX 15m up
sig_momo_short = short_1m and not nq_15m_bull and vix_15m_bull and signals_ok

// --- MR Long ---
// 3-bar: pattern + zone (≤ -1σ) + VIX 15m down
// 2-2:   pattern + zone (< -2σ) + overextended downside + VIX 15m down
mr_long_raw  = ((bull_322 or bull_312) and zone_long_3bar) or (bull_22 and zone_long_2bar and overext_down)
sig_mr_long  = mr_long_raw and not vix_15m_bull and signals_ok and barstate.isconfirmed

// --- MR Short ---
// 3-bar: pattern + zone (≥ +1σ) + (VIX 15m up OR overextended)
// 2-2:   pattern + zone (> +2σ) + overextended upside (always required for 2-2)
mr_short_raw = ((bear_322 or bear_312) and zone_short_3bar) or (bear_22 and zone_short_2bar and overext_up)
sig_mr_short = mr_short_raw and (vix_15m_bull or overext_up) and signals_ok and barstate.isconfirmed

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

col_green = color.new(#1B5E20, 0)
col_red   = color.new(#B71C1C, 0)

// VWAPs
plot(show_vwaps ? overnight_vwap : na, title='Overnight VWAP', color=color.new(#4A148C, 0), linewidth=2)
plot(show_vwaps ? session_vwap   : na, title='Session VWAP',   color=color.new(#0D47A1, 0), linewidth=1)

// ±σ bands
plot(show_bands ? upper1 : na, title='+1σ', color=color.new(color.aqua,    30), linewidth=1)
plot(show_bands ? lower1 : na, title='-1σ', color=color.new(color.aqua,    30), linewidth=1)
plot(show_bands ? upper2 : na, title='+2σ', color=color.new(color.fuchsia, 30), linewidth=1)
plot(show_bands ? lower2 : na, title='-2σ', color=color.new(color.fuchsia, 30), linewidth=1)

// Opening range
plot(show_or and not na(or_high) ? or_high : na, title='OR High', color=color.new(#212121, 0), linewidth=1, style=plot.style_circles)
plot(show_or and not na(or_low)  ? or_low  : na, title='OR Low',  color=color.new(#212121, 0), linewidth=1, style=plot.style_circles)

// 1m TRF
plot(show_trf ? trf_1m : na, title='1m TRF', color=color.new(#37474F, 30), linewidth=1)

// Expected daily range boundaries (from overnight open ± daily ATR)
plot(show_exp_range ? exp_range_high : na, title='Exp Range High', color=color.new(color.orange, 40), linewidth=1, style=plot.style_circles)
plot(show_exp_range ? exp_range_low  : na, title='Exp Range Low',  color=color.new(color.orange, 40), linewidth=1, style=plot.style_circles)

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL LABELS + STOP LINES
// ═══════════════════════════════════════════════════════════════════════════════

// Momentum labels
if show_momo_signals and sig_momo_long
    label.new(bar_index, low,  'BUY',  color=col_green, textcolor=color.white, style=label.style_label_up,   size=size.small)
if show_momo_signals and sig_momo_short
    label.new(bar_index, high, 'SELL', color=col_red,   textcolor=color.white, style=label.style_label_down, size=size.small)

// MR labels (include pattern name)
if show_mr_signals and sig_mr_long
    label.new(bar_index, low,  'MR▲\n' + long_pattern,  color=col_green, textcolor=color.white, style=label.style_label_up,   size=size.small)
if show_mr_signals and sig_mr_short
    label.new(bar_index, high, 'MR▼\n' + short_pattern, color=col_red,   textcolor=color.white, style=label.style_label_down, size=size.small)

// Stop lines (dashed, 5 bars wide)
if show_stops and (sig_momo_long or sig_mr_long)
    line.new(bar_index, low - sl_atr, bar_index + 5, low - sl_atr, color=col_red, width=1, style=line.style_dashed)
if show_stops and (sig_momo_short or sig_mr_short)
    line.new(bar_index, high + sl_atr, bar_index + 5, high + sl_atr, color=col_green, width=1, style=line.style_dashed)

// ═══════════════════════════════════════════════════════════════════════════════
// DEBUG LABELS
// ═══════════════════════════════════════════════════════════════════════════════

if show_candle_type and barstate.isconfirmed
    txt = candleType == 3 ? '3' : candleType == 1 ? '1' : candleType == 2 ? '2U' : candleType == -2 ? '2D' : '·'
    label.new(bar_index, high, txt, color=color.new(color.gray, 70), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if show_pattern_type and barstate.isconfirmed
    pat = bull_322 or bear_322 ? '3-2-2' : bull_312 or bear_312 ? '3-1-2' : bull_22 or bear_22 ? '2-2' : ''
    dir = bull_322 or bull_312 or bull_22 ? 'B' : bear_322 or bear_312 or bear_22 ? 'S' : ''
    if pat != ''
        label.new(bar_index, low, pat + ' ' + dir, color=color.new(color.teal, 50), textcolor=color.white, style=label.style_label_up, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// REGIME TABLE (configurable position — NQ + VIX per timeframe)
// ═══════════════════════════════════════════════════════════════════════════════

pos_lookup(s) =>
    s == 'top_left' ? position.top_left : s == 'top_center' ? position.top_center : s == 'top_right' ? position.top_right : s == 'middle_left' ? position.middle_left : s == 'middle_right' ? position.middle_right : s == 'bottom_left' ? position.bottom_left : s == 'bottom_center' ? position.bottom_center : position.bottom_right

var table regime_tbl = table.new(pos_lookup(table_pos), 3, 9, bgcolor=color.new(#1E1E1E, 0), border_width=1, frame_color=color.new(#000000, 0))

if show_regime and barstate.islast
    txt_c   = color.white
    hdr_bg  = color.new(#424242, 0)
    arrow_g = color.new(#66BB6A, 0)
    arrow_r = color.new(#EF5350, 0)

    table.cell(regime_tbl, 0, 0, 'REGIME', text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(regime_tbl, 1, 0, '',       bgcolor=hdr_bg)
    table.cell(regime_tbl, 2, 0, '',       bgcolor=hdr_bg)

    table.cell(regime_tbl, 0, 1, 'NQ',  text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 1, str.tostring(nq_score,  '#') + '%', text_color=txt_c, text_size=size.small)
    table.cell(regime_tbl, 2, 1, '')

    table.cell(regime_tbl, 0, 2, 'VIX', text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 2, str.tostring(vix_score, '#') + '%', text_color=txt_c, text_size=size.small)
    table.cell(regime_tbl, 2, 2, '')

    state_clr = nq_h ? arrow_g : nq_l ? arrow_r : color.new(#BDBDBD, 0)
    table.cell(regime_tbl, 0, 3, 'STATE', text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 3, state_label, text_color=state_clr, text_size=size.normal)
    table.cell(regime_tbl, 2, 3, '')

    table.cell(regime_tbl, 0, 4, 'TF',  text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(regime_tbl, 1, 4, 'NQ',  text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(regime_tbl, 2, 4, 'VIX', text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)

    table.cell(regime_tbl, 0, 5, '15m', text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 5, nq_15m_bull  ? '▲' : '▼', text_color=nq_15m_bull  ? arrow_g : arrow_r, text_size=size.small)
    table.cell(regime_tbl, 2, 5, vix_15m_bull ? '▲' : '▼', text_color=vix_15m_bull ? arrow_g : arrow_r, text_size=size.small)

    table.cell(regime_tbl, 0, 6, '1h',  text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 6, nq_1h_bull  ? '▲' : '▼', text_color=nq_1h_bull  ? arrow_g : arrow_r, text_size=size.small)
    table.cell(regime_tbl, 2, 6, vix_1h_bull ? '▲' : '▼', text_color=vix_1h_bull ? arrow_g : arrow_r, text_size=size.small)

    table.cell(regime_tbl, 0, 7, '4h',  text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 7, nq_4h_bull  ? '▲' : '▼', text_color=nq_4h_bull  ? arrow_g : arrow_r, text_size=size.small)
    table.cell(regime_tbl, 2, 7, vix_4h_bull ? '▲' : '▼', text_color=vix_4h_bull ? arrow_g : arrow_r, text_size=size.small)

    table.cell(regime_tbl, 0, 8, 'D',   text_color=txt_c, text_size=size.tiny)
    table.cell(regime_tbl, 1, 8, nq_d_bull  ? '▲' : '▼', text_color=nq_d_bull  ? arrow_g : arrow_r, text_size=size.small)
    table.cell(regime_tbl, 2, 8, vix_d_bull ? '▲' : '▼', text_color=vix_d_bull ? arrow_g : arrow_r, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// CONDITIONS PANEL (bottom-left — shows what to look for + range + SL)
// ═══════════════════════════════════════════════════════════════════════════════

var table cond_tbl = table.new(position.bottom_left, 2, 7, bgcolor=color.new(#1E1E1E, 0), border_width=1, frame_color=color.new(#000000, 0))

if show_conditions and barstate.islast
    txt_c   = color.white
    hdr_bg  = color.new(#424242, 0)
    chk_on  = color.new(#66BB6A, 0)
    chk_off = color.new(#757575, 0)
    warn_c  = color.new(#EF5350, 0)

    // Header
    table.cell(cond_tbl, 0, 0, 'LOOK FOR', text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(cond_tbl, 1, 0, '',          bgcolor=hdr_bg)

    // Momo Long: VIX 15m down + NQ 15m bull + (1h or 4h bull) + not overextended + RTH
    cond_ml = not vix_15m_bull and nq_15m_bull and (nq_1h_bull or nq_4h_bull) and not overext_up and signals_ok
    table.cell(cond_tbl, 0, 1, 'Momo Long',  text_color=txt_c, text_size=size.tiny)
    table.cell(cond_tbl, 1, 1, cond_ml ? '✓' : '✗', text_color=cond_ml ? chk_on : chk_off, text_size=size.small)

    // Momo Short: NQ 15m bear + VIX 15m up + RTH
    cond_ms = not nq_15m_bull and vix_15m_bull and signals_ok
    table.cell(cond_tbl, 0, 2, 'Momo Short', text_color=txt_c, text_size=size.tiny)
    table.cell(cond_tbl, 1, 2, cond_ms ? '✓' : '✗', text_color=cond_ms ? chk_on : chk_off, text_size=size.small)

    // MR Long: VIX 15m down + price at or below -1σ + RTH
    cond_mrl = not vix_15m_bull and not na(lower1) and close <= lower1 and signals_ok
    table.cell(cond_tbl, 0, 3, 'MR Long',    text_color=txt_c, text_size=size.tiny)
    table.cell(cond_tbl, 1, 3, cond_mrl ? '✓' : '✗', text_color=cond_mrl ? chk_on : chk_off, text_size=size.small)

    // MR Short: (VIX 15m up or overextended) + price at or above +1σ + RTH
    cond_mrs = (vix_15m_bull or overext_up) and not na(upper1) and close >= upper1 and in_rth_session
    table.cell(cond_tbl, 0, 4, 'MR Short',   text_color=txt_c, text_size=size.tiny)
    table.cell(cond_tbl, 1, 4, cond_mrs ? '✓' : '✗', text_color=cond_mrs ? chk_on : chk_off, text_size=size.small)

    // Range % filled (signed direction)
    range_dir = range_pct >= 0 ? '↑' : '↓'
    range_abs = math.round(math.abs(range_pct) * 100)
    range_txt = str.tostring(range_abs) + '% ' + range_dir
    range_clr = overext_up ? warn_c : txt_c
    table.cell(cond_tbl, 0, 5, 'Range', text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(cond_tbl, 1, 5, range_txt, text_color=range_clr, bgcolor=hdr_bg, text_size=size.small)

    // SL distance (in points)
    table.cell(cond_tbl, 0, 6, 'SL Dist', text_color=txt_c, bgcolor=hdr_bg, text_size=size.tiny)
    table.cell(cond_tbl, 1, 6, str.tostring(sl_atr, format.mintick), text_color=txt_c, bgcolor=hdr_bg, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// DATA WINDOW + ALERTS + WARNING
// ═══════════════════════════════════════════════════════════════════════════════

plot(nq_score,  title='NQ Score',  display=display.data_window)
plot(vix_score, title='VIX Score', display=display.data_window)
plot(range_pct, title='Range %',   display=display.data_window)

alertcondition(sig_momo_long,  title='Momo Long',  message='NQ Sys: Momentum BUY')
alertcondition(sig_momo_short, title='Momo Short', message='NQ Sys: Momentum SELL')
alertcondition(sig_mr_long,    title='MR Long',    message='NQ Sys: Mean-Rev BUY')
alertcondition(sig_mr_short,   title='MR Short',   message='NQ Sys: Mean-Rev SELL')

if barstate.isfirst and timeframe.period != '1'
    label.new(bar_index, high, 'Apply on 1-min chart', color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.large)
````

# Correlated Assets Table

- url: https://www.tradingview.com/script/aaqV80md-Correlated-Assets-Table/
- type: indicator
- pine_id: PUB;982f69fdd4f743959f73cb16ffb996d9
- version: 1.0

## Description

A quick cross-check on whether the rest of the complex agrees with you. It tracks NQ, ES, YM, and the VIX and shows, for each, where price sits against an EMA envelope. A move with all three indices pulling the same way and VIX cooperating is worth more than NQ running by itself. Only take your chart's signal when the table backs it, and treat a split as a yellow light. Each symbol comes in through request.security, so the values settle as bars close. It's confirmation, not a precise entry clock.A quick cross-check on whether the rest of the complex agrees with you. It tracks NQ, ES, YM, and the VIX and shows, for each, where price sits against an EMA envelope. A move with all three indices pulling the same way and VIX cooperating is worth more than NQ running by itself. Only take your chart's signal when the table backs it, and treat a split as a yellow light. Each symbol comes in through request.security, so the values settle as bars close. It's confirmation, not a precise entry clock.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  Correlated Assets Table - NQ / ES / YM / VIX
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  A quick cross-check on whether the rest of the complex agrees with you. It
//  tracks NQ, ES, YM, and the VIX and shows, for each, where price sits
//  against an EMA envelope. A move with all three indices pulling the same
//  way and VIX cooperating is worth more than NQ running by itself. Only take
//  your chart's signal when the table backs it, and treat a split as a yellow
//  light. Each symbol comes in through request.security, so the values settle
//  as bars close. It's confirmation, not a precise entry clock.
// ============================================================================
//
//@version=6
indicator('Correlated Assets Table', overlay = true)

// ═══════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════
nq_sym = input.symbol('CME_MINI:NQ1!', 'NQ Symbol', group = 'Symbols')
es_sym = input.symbol('CME_MINI:ES1!', 'ES Symbol', group = 'Symbols')
ym_sym = input.symbol('CBOT_MINI:YM1!', 'YM Symbol', group = 'Symbols')
vix_sym = input.symbol('TVC:VIX', 'VIX Symbol', group = 'Symbols')

ema_len = input.int(20, 'EMA Envelope Length', minval = 1, group = 'EMA System')
ema200_len = input.int(200, '200 EMA Length', minval = 1, group = 'EMA System')

sec_tf = input.string('1', 'Data Timeframe', options = ['1', '3', '5', '15'], group = 'Settings', tooltip = 'Timeframe for external symbol data. Switch to 5 if 1 shows ? in replay.')
show_debug = input.bool(false, 'Show Debug Values', group = 'Display')
table_pos = input.string('top_right', 'Table Position', options = ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = 'Display')

// ═══════════════════════════════════════════════════════
//  SESSION-MATCHED TICKERS
// ═══════════════════════════════════════════════════════
nq_ticker = ticker.modify(nq_sym, syminfo.session)
es_ticker = ticker.modify(es_sym, syminfo.session)
ym_ticker = ticker.modify(ym_sym, syminfo.session)
vix_ticker = ticker.modify(vix_sym, syminfo.session)

// ═══════════════════════════════════════════════════════
//  EMA ENVELOPE — returns float state
//   2 = strong bull (price fully above cloud)
//   1 = bull (price above both EMAs)
//   0 = neutral (inside cloud)
//  -1 = bear (price below both EMAs)
//  -2 = strong bear (price fully below cloud)
// ═══════════════════════════════════════════════════════
f_ema_state() =>
    ema_hi = ta.ema(high, ema_len)
    ema_lo = ta.ema(low, ema_len)
    bull_f = high > ema_hi and low > ema_lo
    bear_f = high < ema_hi and low < ema_lo
    bull_strong = bull_f and low > ema_hi
    bear_strong = bear_f and high < ema_lo
    bull_strong ? 2.0 : bull_f ? 1.0 : bear_strong ? -2.0 : bear_f ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════
//  200 EMA — above = 1, below = -1
// ═══════════════════════════════════════════════════════
f_ema200_state() =>
    ema200 = ta.ema(close, ema200_len)
    close > ema200 ? 1.0 : -1.0

// ═══════════════════════════════════════════════════════
//  VWAP — above = 1, below = -1
// ═══════════════════════════════════════════════════════
f_vwap_state() =>
    close > ta.vwap ? 1.0 : -1.0

// ═══════════════════════════════════════════════════════
//  DEBUG helpers
// ═══════════════════════════════════════════════════════
f_ema_hi_val() =>
    ta.ema(high, ema_len)
f_ema_lo_val() =>
    ta.ema(low, ema_len)
f_ema200_val() =>
    ta.ema(close, ema200_len)
f_close_val() =>
    close

// ═══════════════════════════════════════════════════════
//  SECURITY CALLS
//  Uses sec_tf (default '5') — 5m data loads reliably
//  for external symbols even in replay mode, unlike '1'
//  which returns NaN for cross-symbol requests.
//  All values wrapped in nz() to prevent NaN propagation.
// ═══════════════════════════════════════════════════════

// --- EMA Envelope State ---
nq_ema = nz(request.security(nq_ticker, sec_tf, f_ema_state(), lookahead = barmerge.lookahead_on), 0.0)
es_ema = nz(request.security(es_ticker, sec_tf, f_ema_state(), lookahead = barmerge.lookahead_on), 0.0)
ym_ema = nz(request.security(ym_ticker, sec_tf, f_ema_state(), lookahead = barmerge.lookahead_on), 0.0)
vix_ema = nz(request.security(vix_ticker, sec_tf, f_ema_state(), lookahead = barmerge.lookahead_on), 0.0)

// --- 200 EMA State ---
nq_200 = nz(request.security(nq_ticker, sec_tf, f_ema200_state(), lookahead = barmerge.lookahead_on), 0.0)
es_200 = nz(request.security(es_ticker, sec_tf, f_ema200_state(), lookahead = barmerge.lookahead_on), 0.0)
ym_200 = nz(request.security(ym_ticker, sec_tf, f_ema200_state(), lookahead = barmerge.lookahead_on), 0.0)
vix_200 = nz(request.security(vix_ticker, sec_tf, f_ema200_state(), lookahead = barmerge.lookahead_on), 0.0)

// --- VWAP State (no VIX — no volume) ---
nq_vwap = nz(request.security(nq_ticker, sec_tf, f_vwap_state(), lookahead = barmerge.lookahead_on), 0.0)
es_vwap = nz(request.security(es_ticker, sec_tf, f_vwap_state(), lookahead = barmerge.lookahead_on), 0.0)
ym_vwap = nz(request.security(ym_ticker, sec_tf, f_vwap_state(), lookahead = barmerge.lookahead_on), 0.0)

// --- DEBUG values ---
nq_ema_hi_dbg = nz(request.security(nq_ticker, sec_tf, f_ema_hi_val(), lookahead = barmerge.lookahead_on))
nq_ema_lo_dbg = nz(request.security(nq_ticker, sec_tf, f_ema_lo_val(), lookahead = barmerge.lookahead_on))
es_ema_hi_dbg = nz(request.security(es_ticker, sec_tf, f_ema_hi_val(), lookahead = barmerge.lookahead_on))
es_ema_lo_dbg = nz(request.security(es_ticker, sec_tf, f_ema_lo_val(), lookahead = barmerge.lookahead_on))

nq_200_dbg = nz(request.security(nq_ticker, sec_tf, f_ema200_val(), lookahead = barmerge.lookahead_on))
es_200_dbg = nz(request.security(es_ticker, sec_tf, f_ema200_val(), lookahead = barmerge.lookahead_on))

nq_close_dbg = nz(request.security(nq_ticker, sec_tf, f_close_val(), lookahead = barmerge.lookahead_on))
es_close_dbg = nz(request.security(es_ticker, sec_tf, f_close_val(), lookahead = barmerge.lookahead_on))
ym_close_dbg = nz(request.security(ym_ticker, sec_tf, f_close_val(), lookahead = barmerge.lookahead_on))
vix_close_dbg = nz(request.security(vix_ticker, sec_tf, f_close_val(), lookahead = barmerge.lookahead_on))

// ═══════════════════════════════════════════════════════
//  BIAS SCORE — EMA Envelope weighted heaviest
//
//  EMA Envelope: ±5 strong, ±3 normal, 0 neutral (per asset)
//  200 EMA:      ±2 per asset
//  VWAP:         ±1 per asset (3 assets, no VIX)
//  VIX INVERTED throughout
//
//  Max: +39 | Min: -39 | Normalized 0–100 (50 = neutral)
// ═══════════════════════════════════════════════════════

f_ema_score(state) =>
    state >= 2.0 ? 5.0 : state >= 1.0 ? 3.0 : state <= -2.0 ? -5.0 : state <= -1.0 ? -3.0 : 0.0

score = 0.0

// EMA Envelope — heaviest weight
score := score + f_ema_score(nq_ema)
score := score + f_ema_score(es_ema)
score := score + f_ema_score(ym_ema)
score := score + f_ema_score(vix_ema) * -1.0

// 200 EMA — medium weight
score := score + nq_200 * 2.0
score := score + es_200 * 2.0
score := score + ym_200 * 2.0
score := score + vix_200 * -2.0

// VWAP — lightest weight (no VIX)
score := score + nq_vwap
score := score + es_vwap
score := score + ym_vwap

// Normalize to 0–100
bias_pct = math.max(0.0, math.min(100.0, (score + 39.0) / 78.0 * 100.0))

bias_label = bias_pct >= 75 ? 'STRONG LONG' : bias_pct >= 60 ? 'LONG BIAS' : bias_pct >= 40 ? 'NEUTRAL' : bias_pct >= 25 ? 'SHORT BIAS' : 'STRONG SHORT'
bias_color = bias_pct >= 75 ? color.new(#66BB6A, 0) : bias_pct >= 60 ? color.new(#A5D6A7, 0) : bias_pct >= 40 ? color.new(#FFD54F, 0) : bias_pct >= 25 ? color.new(#EF9A9A, 0) : color.new(#EF5350, 0)

// ═══════════════════════════════════════════════════════
//  TABLE DISPLAY HELPERS
// ═══════════════════════════════════════════════════════

f_ema_arrow(state) =>
    state >= 2.0 ? '▲▲' : state >= 1.0 ? '▲' : state <= -2.0 ? '▼▼' : state <= -1.0 ? '▼' : '—'

f_ema_color(state, grn, red, dim) =>
    state >= 1.0 ? grn : state <= -1.0 ? red : dim

f_simple_arrow(state) =>
    state > 0 ? '▲' : state < 0 ? '▼' : '?'

f_simple_color(state, grn, red, dim) =>
    state > 0 ? grn : state < 0 ? red : dim

// ═══════════════════════════════════════════════════════
//  TABLE
// ═══════════════════════════════════════════════════════
pos_lookup(s) =>
    s == 'top_left' ? position.top_left : s == 'top_center' ? position.top_center : s == 'top_right' ? position.top_right : s == 'middle_left' ? position.middle_left : s == 'middle_right' ? position.middle_right : s == 'bottom_left' ? position.bottom_left : s == 'bottom_center' ? position.bottom_center : position.bottom_right

num_rows = show_debug ? 11 : 6
var table tbl = table.new(pos_lookup(table_pos), 5, num_rows, bgcolor = color.new(#1E1E1E, 0), border_width = 1, frame_color = color.new(#000000, 0))

if barstate.islast
    txt_c = color.white
    hdr_bg = color.new(#424242, 0)
    grn = color.new(#66BB6A, 0)
    red = color.new(#EF5350, 0)
    dim = color.new(#888888, 0)

    // ── Header ──
    table.cell(tbl, 0, 0, '', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 1, 0, 'NQ', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 2, 0, 'ES', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 3, 0, 'YM', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 4, 0, 'VIX', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)

    // ── EMA Envelope ──
    table.cell(tbl, 0, 1, 'EMA', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 1, f_ema_arrow(nq_ema), text_color = f_ema_color(nq_ema, grn, red, dim), text_size = size.small)
    table.cell(tbl, 2, 1, f_ema_arrow(es_ema), text_color = f_ema_color(es_ema, grn, red, dim), text_size = size.small)
    table.cell(tbl, 3, 1, f_ema_arrow(ym_ema), text_color = f_ema_color(ym_ema, grn, red, dim), text_size = size.small)
    table.cell(tbl, 4, 1, f_ema_arrow(vix_ema), text_color = f_ema_color(vix_ema, grn, red, dim), text_size = size.small)

    // ── 200 EMA ──
    table.cell(tbl, 0, 2, '200', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 2, f_simple_arrow(nq_200), text_color = f_simple_color(nq_200, grn, red, dim), text_size = size.small)
    table.cell(tbl, 2, 2, f_simple_arrow(es_200), text_color = f_simple_color(es_200, grn, red, dim), text_size = size.small)
    table.cell(tbl, 3, 2, f_simple_arrow(ym_200), text_color = f_simple_color(ym_200, grn, red, dim), text_size = size.small)
    table.cell(tbl, 4, 2, f_simple_arrow(vix_200), text_color = f_simple_color(vix_200, grn, red, dim), text_size = size.small)

    // ── VWAP ──
    table.cell(tbl, 0, 3, 'VWAP', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 3, f_simple_arrow(nq_vwap), text_color = f_simple_color(nq_vwap, grn, red, dim), text_size = size.small)
    table.cell(tbl, 2, 3, f_simple_arrow(es_vwap), text_color = f_simple_color(es_vwap, grn, red, dim), text_size = size.small)
    table.cell(tbl, 3, 3, f_simple_arrow(ym_vwap), text_color = f_simple_color(ym_vwap, grn, red, dim), text_size = size.small)
    table.cell(tbl, 4, 3, '—', text_color = dim, text_size = size.small)

    // ── Divider ──
    table.cell(tbl, 0, 4, '', bgcolor = hdr_bg)
    table.cell(tbl, 1, 4, '', bgcolor = hdr_bg)
    table.cell(tbl, 2, 4, '', bgcolor = hdr_bg)
    table.cell(tbl, 3, 4, '', bgcolor = hdr_bg)
    table.cell(tbl, 4, 4, '', bgcolor = hdr_bg)

    // ── BIAS SCORE ──
    table.cell(tbl, 0, 5, 'BIAS', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 5, str.tostring(bias_pct, '#') + '%', text_color = bias_color, text_size = size.small)
    table.cell(tbl, 2, 5, bias_label, text_color = bias_color, text_size = size.tiny, text_halign = text.align_left)
    table.cell(tbl, 3, 5, '', text_size = size.tiny)
    table.cell(tbl, 4, 5, '', text_size = size.tiny)

    // ── DEBUG ──
    if show_debug
        table.cell(tbl, 0, 6, 'EMA Hi', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 1, 6, str.tostring(nq_ema_hi_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 2, 6, str.tostring(es_ema_hi_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 3, 6, '', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 4, 6, '', text_color = dim, text_size = size.tiny)

        table.cell(tbl, 0, 7, 'EMA Lo', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 1, 7, str.tostring(nq_ema_lo_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 2, 7, str.tostring(es_ema_lo_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 3, 7, '', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 4, 7, '', text_color = dim, text_size = size.tiny)

        table.cell(tbl, 0, 8, '200 Val', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 1, 8, str.tostring(nq_200_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 2, 8, str.tostring(es_200_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 3, 8, '', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 4, 8, '', text_color = dim, text_size = size.tiny)

        table.cell(tbl, 0, 9, 'Close', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 1, 9, str.tostring(nq_close_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 2, 9, str.tostring(es_close_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 3, 9, str.tostring(ym_close_dbg, '#.##'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 4, 9, str.tostring(vix_close_dbg, '#.##'), text_color = dim, text_size = size.tiny)

        table.cell(tbl, 0, 10, 'State', text_color = dim, text_size = size.tiny)
        table.cell(tbl, 1, 10, str.tostring(nq_ema, '#') + '/' + str.tostring(nq_200, '#') + '/' + str.tostring(nq_vwap, '#'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 2, 10, str.tostring(es_ema, '#') + '/' + str.tostring(es_200, '#') + '/' + str.tostring(es_vwap, '#'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 3, 10, str.tostring(ym_ema, '#') + '/' + str.tostring(ym_200, '#') + '/' + str.tostring(ym_vwap, '#'), text_color = dim, text_size = size.tiny)
        table.cell(tbl, 4, 10, str.tostring(vix_ema, '#') + '/' + str.tostring(vix_200, '#'), text_color = dim, text_size = size.tiny)
````

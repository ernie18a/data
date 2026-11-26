# Vol & Trend Table

- url: https://www.tradingview.com/script/l2jkvame-Vol-Trend-Table/
- type: indicator
- pine_id: PUB;c1decd5272834167aa6836b7ceae3c7f
- version: 1.0

## Description

A heads-up table so you're not eyeballing the VIX every two minutes. It reads VIX through a Twin Range Filter across a few timeframes to show the risk regime, and works out an ATR-based stop distance (2.2x by default) so you can size without doing math mid-trade. Glance at it for risk-on versus risk-off and the stop number before you take a setup from your main system. It doesn't fire entries itself. The VIX and multi-timeframe reads use lookahead, so on history the table can show a state earlier than you'd have seen it live. Use it as context, not a trigger.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ Vol and Trend Table
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  A heads-up table so you're not eyeballing the VIX every two minutes. It
//  reads VIX through a Twin Range Filter across a few timeframes to show the
//  risk regime, and works out an ATR-based stop distance (2.2x by default) so
//  you can size without doing math mid-trade. Glance at it for risk-on versus
//  risk-off and the stop number before you take a setup from your main
//  system. It doesn't fire entries itself. The VIX and multi-timeframe reads
//  use lookahead, so on history the table can show a state earlier than you'd
//  have seen it live. Use it as context, not a trigger.
// ============================================================================
//
//@version=6
indicator('NQ Vol & Trend Table', overlay = true)

// === INPUTS ===
vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol', group = 'Settings')
trf_per1 = input.int(27, 'TRF Fast Period', minval = 1, group = 'TRF')
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval = 0.1, group = 'TRF')
trf_per2 = input.int(55, 'TRF Slow Period', minval = 1, group = 'TRF')
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval = 0.1, group = 'TRF')
sl_atr_len = input.int(14, 'Stop ATR Period', minval = 1, group = 'Stop Loss')
sl_atr_mult = input.float(2.2, 'Stop ATR Multiplier', minval = 0.1, step = 0.1, group = 'Stop Loss')
table_pos = input.string('top_right', 'Table Position', options = ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = 'Settings')

// === TRF FUNCTIONS ===
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
    close[1] > line[1]

f_bull_simple() =>
    [line, _, _] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
    close > line

// === STOP LOSS ATR ===
sl_atr = ta.atr(sl_atr_len) * sl_atr_mult

// === MULTI-TF STATES ===
nq_15m_bull = request.security(syminfo.tickerid, '15', f_bull(), lookahead = barmerge.lookahead_on)
nq_1h_bull = request.security(syminfo.tickerid, '60', f_bull(), lookahead = barmerge.lookahead_on)
nq_4h_bull = request.security(syminfo.tickerid, '240', f_bull(), lookahead = barmerge.lookahead_on)
nq_d_bull = request.security(syminfo.tickerid, 'D', f_bull(), lookahead = barmerge.lookahead_on)

vix_15m_bull = request.security(vix_symbol, '15', f_bull_simple(), lookahead = barmerge.lookahead_on)
vix_1h_bull = request.security(vix_symbol, '60', f_bull_simple(), lookahead = barmerge.lookahead_on)
vix_4h_bull = request.security(vix_symbol, '240', f_bull_simple(), lookahead = barmerge.lookahead_on)
vix_d_bull = request.security(vix_symbol, 'D', f_bull_simple(), lookahead = barmerge.lookahead_on)

// === TABLE ===
pos_lookup(s) =>
    s == 'top_left' ? position.top_left : s == 'top_center' ? position.top_center : s == 'top_right' ? position.top_right : s == 'middle_left' ? position.middle_left : s == 'middle_right' ? position.middle_right : s == 'bottom_left' ? position.bottom_left : s == 'bottom_center' ? position.bottom_center : position.bottom_right

var table tbl = table.new(pos_lookup(table_pos), 3, 7, bgcolor = color.new(#1E1E1E, 0), border_width = 1, frame_color = color.new(#000000, 0))

if barstate.islast
    txt_c = color.white
    hdr_bg = color.new(#424242, 0)
    arrow_g = color.new(#66BB6A, 0)
    arrow_r = color.new(#EF5350, 0)

    table.cell(tbl, 0, 0, 'TF', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 1, 0, 'NQ', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(tbl, 2, 0, 'VIX', text_color = txt_c, bgcolor = hdr_bg, text_size = size.tiny)

    table.cell(tbl, 0, 1, '15m', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 1, nq_15m_bull ? '▲' : '▼', text_color = nq_15m_bull ? arrow_g : arrow_r, text_size = size.small)
    table.cell(tbl, 2, 1, vix_15m_bull ? '▲' : '▼', text_color = vix_15m_bull ? arrow_g : arrow_r, text_size = size.small)

    table.cell(tbl, 0, 2, '1h', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 2, nq_1h_bull ? '▲' : '▼', text_color = nq_1h_bull ? arrow_g : arrow_r, text_size = size.small)
    table.cell(tbl, 2, 2, vix_1h_bull ? '▲' : '▼', text_color = vix_1h_bull ? arrow_g : arrow_r, text_size = size.small)

    table.cell(tbl, 0, 3, '4h', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 3, nq_4h_bull ? '▲' : '▼', text_color = nq_4h_bull ? arrow_g : arrow_r, text_size = size.small)
    table.cell(tbl, 2, 3, vix_4h_bull ? '▲' : '▼', text_color = vix_4h_bull ? arrow_g : arrow_r, text_size = size.small)

    table.cell(tbl, 0, 4, 'D', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 4, nq_d_bull ? '▲' : '▼', text_color = nq_d_bull ? arrow_g : arrow_r, text_size = size.small)
    table.cell(tbl, 2, 4, vix_d_bull ? '▲' : '▼', text_color = vix_d_bull ? arrow_g : arrow_r, text_size = size.small)

    table.cell(tbl, 0, 5, '', bgcolor = hdr_bg)
    table.cell(tbl, 1, 5, '', bgcolor = hdr_bg)
    table.cell(tbl, 2, 5, '', bgcolor = hdr_bg)

    table.cell(tbl, 0, 6, 'SL Dist', text_color = txt_c, text_size = size.tiny)
    table.cell(tbl, 1, 6, str.tostring(sl_atr, format.mintick), text_color = txt_c, text_size = size.small)
    table.cell(tbl, 2, 6, '', text_size = size.tiny)
````

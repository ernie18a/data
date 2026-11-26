# VIX Charting + Table

- url: https://www.tradingview.com/script/VC33ZUl7-VIX-Charting-Table/
- type: indicator
- pine_id: PUB;699cd91667e94d59bdbd97eb51d0f4fe
- version: 1.0

## Description

Built this one specifically because most VIX scripts cheat. My most important and most useful indicator by far. They request the 15-minute VIX with lookahead on, which leaks the end of the period back to its start on historical bars, so the backtest looks sharper than anything you'd get live. This version only uses confirmed data, so the history and the live read match. Use it as a directional gate for index futures: VIX falling favors longs, VIX rising favors shorts, and what you see on the chart is honest. If you've got older VIX variants lying around, trust this one instead. It's about accuracy, not extra signals.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ VIX No Bias - non-repainting VIX regime
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  Built this one specifically because most VIX scripts cheat. They request
//  the 15-minute VIX with lookahead on, which leaks the end of the period
//  back to its start on historical bars, so the backtest looks sharper than
//  anything you'd get live. This version only uses confirmed data, so the
//  history and the live read match. Use it as a directional gate for index
//  futures: VIX falling favors longs, VIX rising favors shorts, and what you
//  see on the chart is honest. If you've got older VIX variants lying around,
//  trust this one instead. It's about accuracy, not extra signals.
// ============================================================================
//
// =============================================================================
// NQ VIX INDICATOR — NO LOOKBACK BIAS
// =============================================================================
// Bias-free VIX 15m Twin Range Filter regime detection.
//
// THE PROBLEM WITH OTHER VARIANTS:
//   All prior versions use:
//     request.security(vix, '15', close > trf, lookahead=on)
//   On historical bars this leaks the END-of-15m-bar result to the START
//   of that 15m period.  Live bars only see confirmed state.
//   Result: backtest signals fire earlier than real-time → false edge.
//
// THE FIX:
//   1. Request the 15m TRF LINE VALUE using [1] + lookahead_on
//      (standard no-repaint pattern — always the last CONFIRMED 15m bar)
//   2. Request VIX price on the CHART timeframe (updates every bar)
//   3. Compare them HERE on the 1m chart: vix_price vs confirmed_trf_line
//
//   This means:
//   - The TRF line only updates when a 15m bar closes (no future leak)
//   - VIX price updates every chart bar (real-time responsive)
//   - "Currently above" not "closed above" — checked every bar
//   - Historical and live behavior are IDENTICAL
//
// FEATURES:
//   • VIX ON/OFF labels when state flips (marks on chart)
//   • Background highlight during VIX-up regime
//   • Dashboard table: VIX price, 15m TRF state, TRF line value
//   • Optional: plot the 15m TRF line (in VIX price space, separate pane)
//   • Works on any chart timeframe ≤ 15m (1m, 5m recommended)
//
// Designed for: 1-minute or 5-minute NQ futures chart
// =============================================================================

//@version=6
indicator(title='NQ VIX — No Bias', shorttitle='VIX NB', overlay=true,
     max_labels_count=500)

// =============================================================================
// INPUTS
// =============================================================================

grp_vix = 'VIX Settings'
vix_symbol = input.symbol('TVC:VIX', 'VIX Symbol', group=grp_vix)
trf_per1   = input.int(27,    'TRF Fast Period',     minval=1,   group=grp_vix)
trf_mult1  = input.float(1.6, 'TRF Fast Multiplier', minval=0.1, group=grp_vix)
trf_per2   = input.int(55,    'TRF Slow Period',     minval=1,   group=grp_vix)
trf_mult2  = input.float(2.0, 'TRF Slow Multiplier', minval=0.1, group=grp_vix)

grp_disp = 'Display'
show_labels   = input.bool(true,  'VIX ON/OFF Labels',      group=grp_disp)
show_bg       = input.bool(true,  'Background Highlight',    group=grp_disp,
     tooltip='Red tint when VIX is above 15m TRF (risk-off)')
show_table    = input.bool(true,  'VIX Dashboard Table',     group=grp_disp)
table_pos     = input.string('top_right', 'Table Position',
     options=['top_left','top_center','top_right','middle_left','middle_right',
              'bottom_left','bottom_center','bottom_right'], group=grp_disp)

TZ = 'America/New_York'

// =============================================================================
// TRF CORE FUNCTIONS
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

// Returns the TRF line value only (no boolean, no cross detection)
f_trf_line() =>
    src   = close
    smrng = (f_smoothrng(src, trf_per1, trf_mult1) + f_smoothrng(src, trf_per2, trf_mult2)) / 2
    filt  = f_rngfilt(src, smrng)
    fub   = 0.0
    fub  := (filt + smrng) < nz(fub[1]) or close[1] > nz(fub[1]) ?
         filt + smrng : nz(fub[1])
    flb   = 0.0
    flb  := (filt - smrng) > nz(flb[1]) or close[1] < nz(flb[1]) ?
         filt - smrng : nz(flb[1])
    trf   = 0.0
    trf  := nz(trf[1]) == fub[1] and close <= fub ? fub :
         nz(trf[1]) == fub[1] and close >= fub ? flb :
         nz(trf[1]) == flb[1] and close >= flb ? flb :
         nz(trf[1]) == flb[1] and close <= flb ? fub : fub
    trf

// =============================================================================
// BIAS-FREE VIX 15m TRF
// =============================================================================
// Step 1: Get the CONFIRMED 15m TRF line value.
//         [1] + lookahead_on = previous completed 15m bar's TRF line.
//         This is the standard no-repaint pattern.
//         The value updates once per 15m bar close — no intra-bar future leak.

vix_15m_trf_line = request.security(vix_symbol, '15',
     f_trf_line()[1], lookahead=barmerge.lookahead_on)

// Step 2: Get the CURRENT VIX price.
//         Primary: chart timeframe (1m on a 1m chart — max responsiveness).
//         Fallback: confirmed 15m close (for older data where 1m VIX is NaN).
//         TradingView only stores ~2-3 months of 1m VIX data, but 15m goes
//         back 1+ years. The fallback ensures the indicator works on old data.
//         Both sources are bias-free — neither uses future information.

vix_price_chart = request.security(vix_symbol, timeframe.period, close)
vix_price_15m   = request.security(vix_symbol, '15',
     close[1], lookahead=barmerge.lookahead_on)

// Use chart-TF price when available (finer resolution), fall back to 15m close
vix_price = nz(vix_price_chart, vix_price_15m)

// Step 3: Compare HERE on the chart.
//         "Currently above" = VIX's latest price > confirmed 15m TRF line.
//         On recent data: fires the 1m bar VIX crosses the line.
//         On older data: updates every 15m bar (limited by VIX data availability).
//         Both modes are bias-free. Historical = live in both cases.

vix_above_trf = not na(vix_15m_trf_line) and not na(vix_price) and
     vix_price > vix_15m_trf_line

vix_15m_up   = vix_above_trf       // VIX above 15m TRF = risk-off / short bias
vix_15m_down = not na(vix_15m_trf_line) and not na(vix_price) and
     not vix_above_trf              // VIX below 15m TRF = risk-on / long bias

// Track which data source is active (shown in table)
using_chart_tf = not na(vix_price_chart)

// =============================================================================
// ALSO DO 5m TRF (same bias-free method) FOR FAST EXIT DETECTION
// =============================================================================
// 5m TRF line also uses [1]+lookahead_on for confirmed previous bar.
// VIX price reuses the same vix_price (chart-TF or 15m fallback).

vix_5m_trf_line = request.security(vix_symbol, '5',
     f_trf_line()[1], lookahead=barmerge.lookahead_on)

vix_5m_above = not na(vix_5m_trf_line) and not na(vix_price) and
     vix_price > vix_5m_trf_line

// =============================================================================
// FLIP DETECTION — ON-CHART MARKERS
// =============================================================================
// Detect the exact bar where VIX crosses above/below the 15m TRF line.
// Because we compare vix_price (chart TF) vs confirmed TRF line,
// this fires on the 1m bar where the cross actually happens.
// barstate.isconfirmed ensures labels only appear on closed bars
// (prevents label flicker on the forming bar).

vix_flip_on  = vix_15m_up and not vix_15m_up[1] and barstate.isconfirmed
vix_flip_off = vix_15m_down and not vix_15m_down[1] and barstate.isconfirmed

// Also detect if VIX is already ON at RTH open
ny_h = hour(time, TZ)
ny_m = minute(time, TZ)
is_rth_open = (ny_h == 9 and ny_m == 30) and
     not (hour(time[1], TZ) == 9 and minute(time[1], TZ) >= 30)
vix_on_at_open = barstate.isconfirmed and is_rth_open and vix_15m_up

// Combined: mark when VIX turns ON or is ON at open
vix_mark_on  = vix_flip_on or vix_on_at_open
vix_mark_off = vix_flip_off

// =============================================================================
// LABELS
// =============================================================================

c_red_label = color.new(#B71C1C, 0)
c_grn_label = color.new(#2E7D32, 0)

if show_labels and vix_mark_on
    label.new(bar_index, low, 'VIX ON',
         color=c_red_label, textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

if show_labels and vix_mark_off
    label.new(bar_index, high, 'VIX OFF',
         color=c_grn_label, textcolor=color.white,
         style=label.style_label_down, size=size.tiny)

// =============================================================================
// BACKGROUND HIGHLIGHT
// =============================================================================
// Light red tint when VIX is above 15m TRF (risk-off regime)

bgcolor(show_bg and vix_15m_up ? color.new(#EF5350, 90) : na,
     title='VIX Up Background')

// =============================================================================
// DASHBOARD TABLE
// =============================================================================

pos_lookup(s) =>
    s == 'top_left' ? position.top_left : s == 'top_center' ? position.top_center :
     s == 'top_right' ? position.top_right : s == 'middle_left' ? position.middle_left :
     s == 'middle_right' ? position.middle_right : s == 'bottom_left' ? position.bottom_left :
     s == 'bottom_center' ? position.bottom_center : position.bottom_right

var table tbl = table.new(pos_lookup(table_pos), 2, 8,
     bgcolor=color.new(#1A1A1A, 0), border_width=1,
     frame_color=color.new(#000000, 0))

c_white = color.white
c_hdr   = color.new(#2C2C2C, 0)
c_dn    = color.new(#EF5350, 0)
c_gray  = color.new(#78909C, 0)
c_green = color.new(#66BB6A, 0)
c_amber = color.new(#FFB300, 0)

if barstate.islast and show_table
    // Header: VIX price
    table.cell(tbl, 0, 0, 'VIX', text_color=c_white, bgcolor=c_hdr, text_size=size.small)
    table.cell(tbl, 1, 0, not na(vix_price) ? str.tostring(vix_price, '#.##') : '—',
         text_color=c_amber, bgcolor=c_hdr, text_size=size.small)

    // 5m state
    table.cell(tbl, 0, 1, '5m', text_color=c_gray, text_size=size.tiny)
    vix_5m_txt = na(vix_5m_trf_line) ? '—' : (vix_5m_above ? '▲ ABOVE' : '▼ BELOW')
    vix_5m_clr = na(vix_5m_trf_line) ? c_gray : (vix_5m_above ? c_dn : c_green)
    table.cell(tbl, 1, 1, vix_5m_txt, text_color=vix_5m_clr, text_size=size.small)

    // 15m state (PRIMARY)
    table.cell(tbl, 0, 2, '15m', text_color=c_white, text_size=size.tiny)
    table.cell(tbl, 1, 2, vix_15m_up ? '▲ ABOVE' : '▼ BELOW',
         text_color=vix_15m_up ? c_dn : c_green, text_size=size.small)

    // Separator
    table.cell(tbl, 0, 3, '', bgcolor=c_hdr)
    table.cell(tbl, 1, 3, '', bgcolor=c_hdr)

    // TRF line value
    table.cell(tbl, 0, 4, '15m TRF', text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 4, not na(vix_15m_trf_line) ? str.tostring(vix_15m_trf_line, '#.##') : '—',
         text_color=c_white, text_size=size.small)

    // Distance from line
    has_dist = not na(vix_price) and not na(vix_15m_trf_line)
    dist     = has_dist ? vix_price - vix_15m_trf_line : 0.0
    dist_pct = has_dist and vix_15m_trf_line > 0 ? (dist / vix_15m_trf_line) * 100 : 0.0
    table.cell(tbl, 0, 5, 'DIST', text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 5,
         has_dist ?
         (dist > 0 ? '+' : '') + str.tostring(dist, '#.##') +
         ' (' + (dist_pct > 0 ? '+' : '') + str.tostring(dist_pct, '#.#') + '%)' : '—',
         text_color=has_dist ? (dist > 0 ? c_dn : c_green) : c_gray,
         text_size=size.small)

    // Data source indicator
    table.cell(tbl, 0, 6, 'SRC', text_color=c_gray, text_size=size.tiny)
    table.cell(tbl, 1, 6, using_chart_tf ? '1m' : '15m',
         text_color=using_chart_tf ? c_green : c_amber, text_size=size.small)

    // Regime label
    regime_txt = vix_15m_up ? 'RISK OFF' : 'RISK ON'
    regime_clr = vix_15m_up ? c_dn : c_green
    table.cell(tbl, 0, 7, '', bgcolor=c_hdr)
    table.cell(tbl, 1, 7, regime_txt, text_color=regime_clr,
         bgcolor=c_hdr, text_size=size.small)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(vix_mark_on,
     title='VIX 15m ON (No Bias)',
     message='VIX crossed ABOVE 15m TRF — risk-off regime')
alertcondition(vix_mark_off,
     title='VIX 15m OFF (No Bias)',
     message='VIX crossed BELOW 15m TRF — risk-on regime')
alertcondition(vix_5m_above and not vix_5m_above[1],
     title='VIX 5m ON (No Bias)',
     message='VIX crossed ABOVE 5m TRF')

// =============================================================================
// NOTES FOR INTEGRATION WITH OTHER INDICATORS
// =============================================================================
// To use this VIX state in your entry indicators (NQ_Unified_v4, etc.),
// replace their VIX request.security calls with this same pattern:
//
//   // OLD (biased):
//   // vix_15m = request.security(vix_symbol, '15', f_bull_now(), lookahead=barmerge.lookahead_on)
//
//   // NEW (bias-free, with historical data fallback):
//   vix_15m_trf_line = request.security(vix_symbol, '15', f_trf_line()[1], lookahead=barmerge.lookahead_on)
//   vix_price_chart  = request.security(vix_symbol, timeframe.period, close)
//   vix_price_15m    = request.security(vix_symbol, '15', close[1], lookahead=barmerge.lookahead_on)
//   vix_price        = nz(vix_price_chart, vix_price_15m)
//   vix_15m_up       = vix_price > vix_15m_trf_line
//   vix_15m_down     = not vix_15m_up
//
// Uses 3 request.security calls per VIX timeframe (vs 1 before).
// Chart-TF gives 1m resolution on recent data; 15m fallback covers older data.
// Both sources are bias-free — no future information used.
// =============================================================================
````

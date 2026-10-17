# High time frame TRF Momentum

- url: https://www.tradingview.com/script/2GElshTU-High-time-frame-TRF-Momentum/
- type: indicator
- pine_id: PUB;d95f00a615a040ed99dbd7a8f6fc5ea9
- version: 1.0

## Description

Just the Twin Range Filter on its own, for when I want one clean momentum read without the rest of the system cluttering the chart. It wraps price in a fast and a slow range band and flips long when price crosses up through the combined filter, short on the cross down. It doubles as a trailing line to keep you in a move. Take the crosses with your higher-timeframe bias and ignore the ones fighting it. Confirms on the bar close. It's built on the open-source Twin Range Filter, credit to the original author: colinmck.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ TRF Momentum - Twin Range Filter
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  Just the Twin Range Filter on its own, for when I want one clean momentum
//  read without the rest of the system cluttering the chart. It wraps price
//  in a fast and a slow range band and flips long when price crosses up
//  through the combined filter, short on the cross down. It doubles as a
//  trailing line to keep you in a move. Take the crosses with your higher-
//  timeframe bias and ignore the ones fighting it. Confirms on the bar close.
//  It's built on the open-source Twin Range Filter, credit to the original
//  author.
// ============================================================================
//
//@version=6
indicator('NQ TRF Momentum', overlay = true, max_labels_count = 500)

// === INPUTS ===
trf_per1 = input.int(27, 'TRF Fast Period', minval = 1, group = 'Twin Range Filter')
trf_mult1 = input.float(1.6, 'TRF Fast Multiplier', minval = 0.1, group = 'Twin Range Filter')
trf_per2 = input.int(55, 'TRF Slow Period', minval = 1, group = 'Twin Range Filter')
trf_mult2 = input.float(2.0, 'TRF Slow Multiplier', minval = 0.1, group = 'Twin Range Filter')

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

// === 1M TRF ===
[trf_1m, cross_up, cross_down] = f_trf(close, trf_per1, trf_mult1, trf_per2, trf_mult2)
long_cross = cross_up and barstate.isconfirmed
short_cross = cross_down and barstate.isconfirmed

// === 15M FILTER ===
nq_15m_bull = request.security(syminfo.tickerid, '15', f_bull(), lookahead = barmerge.lookahead_on)

// === SESSION FILTER (signals only after OR: 9:45+) ===
session_tz = 'America/New_York'
ny_hour = hour(time, session_tz)
ny_min = minute(time, session_tz)
in_rth = ny_hour == 9 and ny_min >= 30 or ny_hour > 9 and ny_hour < 12 or ny_hour == 12 and ny_min == 0
signals_ok = in_rth and (ny_hour > 9 or ny_hour == 9 and ny_min >= 45)

// === SIGNALS ===
sig_long = long_cross and nq_15m_bull and signals_ok
sig_short = short_cross and not nq_15m_bull and signals_ok

// === PLOT TRF LINE (color changes with direction) ===
trf_bull = close > trf_1m
trf_color = trf_bull ? color.new(#2196F3, 0) : color.new(#EF5350, 0)
plot(trf_1m, 'TRF', color = trf_color, linewidth = 2)

// === SIGNAL LABELS ===
col_blue = color.new(#1565C0, 0)
col_red = color.new(#B71C1C, 0)

if sig_long
    label.new(bar_index, low, 'BUY', color = col_blue, textcolor = color.white, style = label.style_label_up, size = size.small)
if sig_short
    label.new(bar_index, high, 'SELL', color = col_red, textcolor = color.white, style = label.style_label_down, size = size.small)

// === ALERTS ===
alertcondition(sig_long, title = 'Momo Long', message = 'TRF Momentum BUY')
alertcondition(sig_short, title = 'Momo Short', message = 'TRF Momentum SELL')
````

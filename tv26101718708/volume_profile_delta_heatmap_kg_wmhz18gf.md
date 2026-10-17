# Volume Profile & Delta Heatmap [KG]

- url: https://www.tradingview.com/script/WmHz18gf-Volume-Profile-Delta-Heatmap-KG/
- type: indicator
- pine_id: PUB;b72a7e4a2d0b44cf93c31c422b2a3f1d
- version: 1.0

## Description

Overview#
Volume Profile & Delta Heatmap [KG] is a multi-feature, all-in-one volume analysis  that combines a traditional horizontal Volume Profile, a session-by-session Delta heatmap, a rotated (vertical) Volume Profile, RSI-confirmed auto signals, and a live info panel — all drawn on the price chart.

It is designed for traders who want to read where volume is concentrated, who is in control (buyers vs. sellers), and where price is likely to react — without cluttering the chart with multiple separate tools.

Key Features#
1. Horizontal Volume Profile (VP)
Built from the last N bars (default 150) across a user-defined number of price rows.
Volume from each candle's body and wicks is distributed proportionally across price levels.

Calculates and plots:
POC (Point of Control) — the price with the highest traded volume
VAH / VAL (Value Area High / Low) — the range containing a configurable % of total volume (default 70%).Bars inside the Value Area are drawn brighter; outside bars are faded.

2. Delta Heatmap:
Splits recent sessions (Daily / Weekly / Monthly) into price rows and colors each cell by net delta (buy volume − sell volume).
Green shades = net buying; red shades = net selling; darker shades = stronger imbalance.
Each session's total net delta is printed above the heatmap.
Delta is optionally dampened when RSI is neutral, reducing noise during indecision.

3. Rotated Volume Profile (RV):
A second, independently computed Volume Profile drawn vertically in the middle-right of the chart.Includes its own POC, VAH, and VAL with arrows, brackets, and a volume axis.
Fully customizable: horizontal offset, vertical offset, column width, gap, histogram height, label frequency, and axis ticks.Confining frame, POC arrow, and VA brackets can be toggled on/off.

4. Auto Buy/Sell Signals:
Three signal engines, selectable:

VA Breakout — price closes above VAH (buy) or below VAL (sell)
POC Bounce — price crosses POC with RSI agreement
Both — combines the two
Each signal can be filtered by:
RSI confirmation (bullish > threshold, bearish < threshold)
Delta confirmation (net positive for buys, net negative for sells)
Minimum bars between signals and a total-signal cap to prevent clutter.

5. RSI Filter & Info Panel:
RSI is used both as a signal filter and as a delta weighting factor.
Info panel shows live RSI value + state, plus current POC / VAH / VAL prices.

Full Customization:
The script ships with 12 grouped input sections:

Volume Profile · 2. Delta Heatmap · 3. RSI Filter · 4. Signals · 5. Rotated VP · 6. RV Layout · 7. RV Colors · 8. RV Show · 9. Display · 10. Label Sizes · 11. Colors · 12. Opacity
Nearly every visual element — colors, transparency, label sizes, offsets, and tick counts — is user-adjustable.

How to Use#

Adjust VP: Bars to match your trading timeframe (shorter for intraday, longer for swing).
Tune Value Area % (70% is standard; 80% for tighter zones).
Enable Delta Heatmap to see session-by-session buyer/seller imbalance.
Turn on Auto Signals with RSI + Delta confirmation for higher-quality entries.
Position the Rotated VP using the layout inputs so it sits where it doesn't obscure price action.

Typical reading:

Price rejecting VAH with negative delta → potential short.
Price bouncing off VAL with positive delta → potential long.
POC often acts as a magnet / support-resistance pivot.

Notes & Limitations#
All drawing objects reset and redraw on the last bar, so historical bars do not carry profile boxes — this is intentional to keep the chart clean and within Pine's object limits.
Delta is approximated from candle direction and volume (close vs. open).The heatmap uses the last ~500 bars only.

⚠️ Disclaimer#
This indicator is provided for educational and informational purposes only. It is not financial advice and does not constitute a recommendation to buy or sell any financial instrument. Volume Profile, Delta, and RSI readings are interpretive tools, not predictive certainties. Past performance and historical volume patterns do not guarantee future results. Always perform your own due diligence, use proper risk management, and consult a licensed financial advisor before making trading decisions.Happy trading

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kingshukghosh71  — Rotated VP + VP & Delta Heatmap
//@version=6
indicator('Volume Profile & Delta Heatmap [KG]', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 501)

// ═══════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════
// ── 1. Horizontal Volume Profile  ───────────────────────────
vp_bars = input.int(150, 'VP: Bars', minval = 20, maxval = 500, group = '1. Volume Profile')
vp_rows = input.int(24, 'VP: Rows', minval = 5, maxval = 50, group = '1. Volume Profile')
va_pct = input.float(70., 'VP: Value Area %', minval = 0, maxval = 100, group = '1. Volume Profile')
vp_size = input.float(70., 'VP: Size (% of range)', minval = 20, maxval = 100, step = 5, group = '1. Volume Profile')
// ── 2. Delta Heatmap ──────────────────────────────────────────────────
show_delta = input.bool(true, 'Show Delta Heatmap', group = '2. Delta Heatmap')
d_sessions = input.int(10, 'Delta: Sessions', minval = 3, maxval = 20, group = '2. Delta Heatmap')
d_rows = input.int(15, 'Delta: Price Rows', minval = 5, maxval = 25, group = '2. Delta Heatmap')
d_tf = input.timeframe('D', 'Delta: Timeframe', options = ['D', 'W', 'M'], group = '2. Delta Heatmap')
// ── 3. RSI Filter ─────────────────────────────────────────────────────
use_rsi = input.bool(true, 'Enable RSI Filter', group = '3. RSI Filter')
rsi_len = input.int(14, 'RSI Length', minval = 2, maxval = 50, group = '3. RSI Filter')
rsi_bull = input.float(55., 'Bullish Threshold', minval = 50, maxval = 80, group = '3. RSI Filter')
rsi_bear = input.float(45., 'Bearish Threshold', minval = 20, maxval = 50, group = '3. RSI Filter')
// ── 4. Auto Signals ───────────────────────────────────────────────────
show_sigs = input.bool(true, 'Show Auto Buy/Sell Signals', group = '4. Signals')
sig_mode = input.string('Both', 'Signal Source', options = ['VA Breakout', 'POC Bounce', 'Both'], group = '4. Signals')
need_rsi = input.bool(true, 'Require RSI Confirm', group = '4. Signals')
need_delta = input.bool(true, 'Require Delta Confirm', group = '4. Signals')
sig_gap = input.int(5, 'Min Bars Between Signals', minval = 1, maxval = 50, group = '4. Signals')
max_sigs = input.int(20, 'Max Signals Total', minval = 1, maxval = 50, group = '4. Signals')
// ── 5. Rotated Volume Profile ──────────────────────────────
show_rvp = input.bool(true, 'Show Rotated VP (middle-right)', group = '5. Rotated VP')
rvp_bars = input.int(150, 'RV: Number of Bars', minval = 1, maxval = 500, group = '5. Rotated VP')
rvp_rows = input.int(24, 'RV: Rows', minval = 5, maxval = 100, group = '5. Rotated VP')
rvp_pct = input.float(70., 'RV: Value Area %', minval = 0, maxval = 100, group = '5. Rotated VP')

rvp_offset = input.int(10, 'RV: Horizontal offset from last bar (bars)', minval = 0, maxval = 200, group = '6. RV Layout')
rvp_voffset = input.float(0., 'RV: Vertical offset (% of range)', minval = -200, maxval = 200, step = 5, group = '6. RV Layout')
rvp_colw = input.int(2, 'RV: Column width', minval = 1, maxval = 10, group = '6. RV Layout')
rvp_gap = input.int(1, 'RV: Gap between columns', minval = 0, maxval = 5, group = '6. RV Layout')
rvp_hpct = input.float(60., 'RV: Histogram height (% of range)', minval = 10, maxval = 200, group = '6. RV Layout')
rvp_lblstep = input.int(5, 'RV: Price label every N columns', minval = 1, maxval = 20, group = '6. RV Layout')
rvp_axis_ticks = input.int(3, 'RV: Volume axis ticks', minval = 2, maxval = 10, group = '6. RV Layout')

rvp_bar_col = input.color(#1e78ff, 'RV: Volume Bar', group = '7. RV Colors')
rvp_out_col = input.color(color.new(#1e78ff, 45), 'RV: Bar outside VA', group = '7. RV Colors')
rvp_poc_col = input.color(#ef3e4f, 'RV: POC', group = '7. RV Colors')
rvp_va_col = input.color(#2ee86a, 'RV: VAH / VAL', group = '7. RV Colors')
rvp_txt_col = input.color(#c9d6f2, 'RV: Text / Axis', group = '7. RV Colors')
rvp_frame_col = input.color(#3a4a66, 'RV: Frame Border', group = '7. RV Colors')

rvp_show_axis = input.bool(true, 'RV: Show Axes & Labels', group = '8. RV Show')
rvp_show_va = input.bool(true, 'RV: Show VAH / VAL Brackets', group = '8. RV Show')
rvp_show_frame = input.bool(true, 'RV: Show Confining Frame', group = '8. RV Show')

// ── 9. Display ────────────────────────────────────────────────────────
show_vp_labels = input.bool(true, 'Show POC/VAH/VAL Labels', group = '9. Display')
show_axis = input.bool(true, 'Show Price Axis', group = '9. Display')
show_panel = input.bool(true, 'Show Info Panel', group = '9. Display')
// ── 10. Label Sizes ───────────────────────────────────────────────────
sz_axis_in = input.string('Tiny', 'Price Axis', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = '10. Label Sizes')
sz_vp_in = input.string('Small', 'VP Levels (POC/VAH/VAL)', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = '10. Label Sizes')
sz_sig_in = input.string('Normal', 'Signal Arrows', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = '10. Label Sizes')
sz_delta_in = input.string('Tiny', 'Session Delta', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = '10. Label Sizes')
sz_panel_in = input.string('Small', 'Info Panel', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = '10. Label Sizes')
// ── 11. Colors ────────────────────────────────────────────────────────
h_col = input.color(#1e78ff, 'VP Bars', group = '11. Colors')
poc_col = input.color(#ef3e4f, 'POC', group = '11. Colors')
va_col = input.color(#2ee86a, 'VAH / VAL', group = '11. Colors')
buy_col = input.color(#2ee86a, 'Buy Signal', group = '11. Colors')
sell_col = input.color(#ef3e4f, 'Sell Signal', group = '11. Colors')
txt_col = input.color(#c9d6f2, 'Text', group = '11. Colors')
// ── 12. Opacity ───────────────────────────────────────────────────────
va_transp = input.int(80, 'VP: VA Transparency', minval = 0, maxval = 100, group = '12. Opacity')
out_transp = input.int(90, 'VP: Outside Transparency', minval = 0, maxval = 100, group = '12. Opacity')

// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════
f_size(s) =>
    switch s
        'Tiny' => size.tiny
        'Small' => size.small
        'Large' => size.large
        'Huge' => size.huge
        => size.normal

sz_axis = f_size(sz_axis_in)
sz_vp = f_size(sz_vp_in)
sz_sig = f_size(sz_sig_in)
sz_delta = f_size(sz_delta_in)
sz_panel = f_size(sz_panel_in)

transp = color.new(color.black, 100)

get_vol(y11, y12, y21, y22, height, vol) =>
    nz(math.max(math.min(math.max(y11, y12), math.max(y21, y22)) - math.max(math.min(y11, y12), math.min(y21, y22)), 0) * vol / height)

// helper for rotated VP column x‑centre
r_xc(x1) =>
    int(math.round(x1 + rvp_colw / 2.0))

// ═══════════════════════════════════════════════════════════════════════
//  RANGES
// ═══════════════════════════════════════════════════════════════════════
// horizontal VP range 
top = ta.highest(vp_bars)
bot = ta.lowest(vp_bars)
vp_step = (top - bot) / vp_rows

// rotated VP range 
r_top = ta.highest(rvp_bars)
r_bot = ta.lowest(rvp_bars)
r_step = (r_top - r_bot) / rvp_rows

// ═══════════════════════════════════════════════════════════════════════
//  SESSION TRACKING + RSI
// ═══════════════════════════════════════════════════════════════════════
new_sess = timeframe.change(d_tf)
var int sess_id = 0
if new_sess
    sess_id := sess_id + 1
    sess_id

rsi_v = ta.rsi(close, rsi_len)
rsi_bull_ok = rsi_v > rsi_bull
rsi_bear_ok = rsi_v < rsi_bear

// ═══════════════════════════════════════════════════════════════════════
//  ROLLING BUFFERS
// ═══════════════════════════════════════════════════════════════════════
var array<int> b_sess = array.new_int()
var array<float> b_h = array.new_float()
var array<float> b_l = array.new_float()
var array<float> b_c = array.new_float()
var array<float> b_delta = array.new_float()
var array<float> b_rsi = array.new_float()

raw_delta = close > open ? volume : close < open ? -volume : 0.
delta_v = raw_delta * (not use_rsi ? 1.0 : rsi_bull_ok or rsi_bear_ok ? 1.0 : 0.35)

array.push(b_sess, sess_id)
array.push(b_h, high)
array.push(b_l, low)
array.push(b_c, close)
array.push(b_delta, delta_v)
array.push(b_rsi, rsi_v)

cap = 500
if array.size(b_sess) > cap
    array.shift(b_sess)
    array.shift(b_h)
    array.shift(b_l)
    array.shift(b_c)
    array.shift(b_delta)
    array.shift(b_rsi)

// ═══════════════════════════════════════════════════════════════════════
//  STORAGE
// ═══════════════════════════════════════════════════════════════════════
var array<box> boxes = array.new_box()
var array<label> lbls = array.new_label()
var array<line> lns = array.new_line()

clear_all() =>
    while array.size(boxes) > 0
        box.delete(array.pop(boxes))
    while array.size(lbls) > 0
        label.delete(array.pop(lbls))
    while array.size(lns) > 0
        line.delete(array.pop(lns))

// ═══════════════════════════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════════════════════════
if barstate.islast
    clear_all()

    // ── (A) Compute horizontal Volume Profile ─────────────────────────
    levels = array.new_float(vp_rows + 1)
    for x = 0 to vp_rows by 1
        array.set(levels, x, bot + vp_step * x)

    totalvols = array.new_float(vp_rows, 0.)
    for b = 0 to vp_bars - 1 by 1
        body_top = math.max(close[b], open[b])
        body_bot = math.min(close[b], open[b])
        topwick = high[b] - body_top
        bottomwick = body_bot - low[b]
        body = body_top - body_bot
        denom = 2 * topwick + 2 * bottomwick + body
        bodyvol = body * volume[b] / denom
        topvol = 2 * topwick * volume[b] / denom
        botvol = 2 * bottomwick * volume[b] / denom
        for x = 0 to vp_rows - 1 by 1
            l1 = array.get(levels, x)
            l2 = array.get(levels, x + 1)
            v = get_vol(l1, l2, body_bot, body_top, body, bodyvol) + get_vol(l1, l2, body_top, high[b], topwick, topvol) / 2 + get_vol(l1, l2, body_bot, low[b], bottomwick, botvol) / 2
            array.set(totalvols, x, array.get(totalvols, x) + v)

    maxvol = array.max(totalvols)
    int poc = array.indexof(totalvols, maxvol)

    totalmax = array.sum(totalvols) * va_pct / 100.
    va_total = array.get(totalvols, poc)
    int up = poc
    int down = poc
    for x = 0 to vp_rows - 1 by 1
        if va_total >= totalmax
            break
        uppervol = up < vp_rows - 1 ? array.get(totalvols, up + 1) : 0.
        lowervol = down > 0 ? array.get(totalvols, down - 1) : 0.
        if uppervol == 0 and lowervol == 0
            break
        if uppervol >= lowervol
            va_total := va_total + uppervol
            up := up + 1
            up
        else
            va_total := va_total + lowervol
            down := down - 1
            down

    poc_price = (array.get(levels, poc) + array.get(levels, poc + 1)) / 2
    vah_price = array.get(levels, up + 1)
    val_price = array.get(levels, down)

    // ── (B) Draw horizontal VP ────────────────────────────────────────
    xh0 = bar_index - vp_bars + 1
    hw = vp_bars * vp_size / 100.
    rng = top - bot
    dist = rng / 500


    xh_r = xh0 - 3

    for i = 0 to vp_rows - 1 by 1
        w = maxvol > 0 ? array.get(totalvols, i) / maxvol * hw : 0.
        c = i >= down and i <= up ? color.new(h_col, va_transp) : color.new(h_col, out_transp)
        if i == poc
            c := color.new(poc_col, 65)
            c
        array.push(boxes, box.new(xh0, array.get(levels, i + 1) - dist, xh0 + int(math.round(w)), array.get(levels, i) + dist, border_width = 0, bgcolor = c))

    array.push(lns, line.new(xh0, poc_price, bar_index + 1, poc_price, color = poc_col, width = 2))
    array.push(lns, line.new(xh0, vah_price, bar_index + 1, vah_price, color = va_col, width = 1, style = line.style_dashed))
    array.push(lns, line.new(xh0, val_price, bar_index + 1, val_price, color = va_col, width = 1, style = line.style_dashed))

    if show_vp_labels

        array.push(lbls, label.new(xh_r, poc_price, 'POC', style = label.style_label_right, color = transp, textcolor = poc_col, size = sz_vp))
        array.push(lbls, label.new(xh_r, vah_price, 'VAH', style = label.style_label_right, color = transp, textcolor = va_col, size = sz_vp))
        array.push(lbls, label.new(xh_r, val_price, 'VAL', style = label.style_label_right, color = transp, textcolor = va_col, size = sz_vp))

    // ── (C) Delta Heatmap ─────────────────────────────────────────────
    n = array.size(b_sess)
    first_sess = sess_id - d_sessions + 1

    if show_delta
        sess_x1 = array.new_int(d_sessions, -1)
        sess_x2 = array.new_int(d_sessions, -1)
        sess_dsum = array.new_float(d_sessions, 0.)
        d_grid = array.new_float(d_sessions * d_rows, 0.)
        d_step = rng / d_rows

        for i = 0 to n - 1 by 1
            s = array.get(b_sess, i)
            if s >= first_sess
                si = s - first_sess
                h = array.get(b_h, i)
                l = array.get(b_l, i)
                d = array.get(b_delta, i)
                bb = n - 1 - i
                xi = bar_index - bb
                if array.get(sess_x1, si) == -1
                    array.set(sess_x1, si, xi)
                array.set(sess_x2, si, xi)
                array.set(sess_dsum, si, array.get(sess_dsum, si) + d)

                bar_rng = math.max(h - l, syminfo.mintick)
                r_lo = math.max(0, int(math.floor((l - bot) / d_step)))
                r_hi = math.min(d_rows - 1, int(math.floor((h - bot) / d_step)))
                for r = r_lo to r_hi by 1
                    rl = bot + d_step * r
                    rh = bot + d_step * (r + 1)
                    ovl = math.max(0, math.min(h, rh) - math.max(l, rl))
                    if ovl > 0
                        idx = si * d_rows + r
                        array.set(d_grid, idx, array.get(d_grid, idx) + d * ovl / bar_rng)

        abs_max = 0.
        for i = 0 to array.size(d_grid) - 1 by 1
            v = math.abs(array.get(d_grid, i))
            if v > abs_max
                abs_max := v
                abs_max

        for si = 0 to d_sessions - 1 by 1
            x1 = array.get(sess_x1, si)
            x2 = array.get(sess_x2, si)
            if x1 != -1 and x2 >= x1
                for r = 0 to d_rows - 1 by 1
                    v = array.get(d_grid, si * d_rows + r)
                    t = abs_max > 0 ? math.abs(v) / abs_max : 0
                    c = v > 0 ? color.from_gradient(t, 0, 1, color.new(buy_col, 92), color.new(buy_col, 50)) : v < 0 ? color.from_gradient(t, 0, 1, color.new(sell_col, 92), color.new(sell_col, 50)) : color.new(color.gray, 95)
                    y1 = bot + d_step * (r + 1)
                    y2 = bot + d_step * r
                    array.push(boxes, box.new(x1, y1, x2, y2, bgcolor = c, border_width = 0))

        for si = 0 to d_sessions - 1 by 1
            x1 = array.get(sess_x1, si)
            x2 = array.get(sess_x2, si)
            if x1 != -1 and x2 >= x1
                sd = array.get(sess_dsum, si)
                xm = int(math.round((x1 + x2) / 2))
                col = sd > 0 ? buy_col : sell_col
                array.push(lbls, label.new(xm, top + vp_step * 2, str.tostring(sd, format.volume), style = label.style_label_down, color = transp, textcolor = col, size = sz_delta))

    // ── (D) Auto Signals ──────────────────────────────────────────────
    if show_sigs
        sig_count = 0
        last_buy_bar = -10000
        last_sell_bar = -10000

        for i = n - 1 to 1 by 1
            if sig_count >= max_sigs
                break

            cl = array.get(b_c, i)
            cl_prev = array.get(b_c, i - 1)
            d = array.get(b_delta, i)
            rv = array.get(b_rsi, i)
            bb = n - 1 - i
            xi = bar_index - bb

            rsi_buy_ok = not need_rsi or rv > rsi_bull
            rsi_sell_ok = not need_rsi or rv < rsi_bear
            delta_buy_ok = not need_delta or d > 0
            delta_sell_ok = not need_delta or d < 0

            vah_bk_up = cl > vah_price and cl_prev <= vah_price
            val_bk_dn = cl < val_price and cl_prev >= val_price
            poc_up = cl > poc_price and cl_prev <= poc_price and rv > 50
            poc_dn = cl < poc_price and cl_prev >= poc_price and rv < 50

            buy_sig = false
            sell_sig = false

            if sig_mode == 'VA Breakout' or sig_mode == 'Both'
                if vah_bk_up and rsi_buy_ok and delta_buy_ok
                    buy_sig := true
                    buy_sig
                if val_bk_dn and rsi_sell_ok and delta_sell_ok
                    sell_sig := true
                    sell_sig

            if sig_mode == 'POC Bounce' or sig_mode == 'Both'
                if poc_up and rsi_buy_ok and delta_buy_ok
                    buy_sig := true
                    buy_sig
                if poc_dn and rsi_sell_ok and delta_sell_ok
                    sell_sig := true
                    sell_sig

            if buy_sig and xi - last_buy_bar >= sig_gap
                array.push(lbls, label.new(xi, array.get(b_l, i) - vp_step * 1.5, '▲ BUY', style = label.style_label_up, color = color.new(buy_col, 15), textcolor = color.white, size = sz_sig))
                last_buy_bar := xi
                sig_count := sig_count + 1
                sig_count
            else if sell_sig and xi - last_sell_bar >= sig_gap
                array.push(lbls, label.new(xi, array.get(b_h, i) + vp_step * 1.5, '▼ SELL', style = label.style_label_down, color = color.new(sell_col, 15), textcolor = color.white, size = sz_sig))
                last_sell_bar := xi
                sig_count := sig_count + 1
                sig_count

    // ── (E) Price Axis ────────────────────────────────────────────────
    if show_axis
        axis_step = math.max(1, int(math.round(vp_rows / 8)))
        for r = 0 to vp_rows by 1
            if r % axis_step == 0 or r == vp_rows
                y = bot + vp_step * r
                // *** CHANGED: Placed at xh0 - 3 (left side) with label_left style ***
                array.push(lbls, label.new(xh0 - 3, y, str.tostring(math.round_to_mintick(y)), style = label.style_label_left, color = transp, textcolor = txt_col, size = sz_axis))

    // ── (F) Info Panel ────────────────────────────────────────────────
    if show_panel
        rsi_state = rsi_bull_ok ? 'BULL ✓' : rsi_bear_ok ? 'BEAR ✓' : 'NEUTRAL'
        rsi_col = rsi_bull_ok ? buy_col : rsi_bear_ok ? sell_col : color.gray
        panel_txt = 'RSI: ' + str.tostring(rsi_v, '#.##') + ' | ' + rsi_state + '\nPOC: ' + str.tostring(math.round_to_mintick(poc_price)) + '\nVAH: ' + str.tostring(math.round_to_mintick(vah_price)) + '\nVAL: ' + str.tostring(math.round_to_mintick(val_price))
        array.push(lbls, label.new(bar_index - int(vp_bars / 2), top + vp_step * 5, panel_txt, style = label.style_label_down, color = color.new(color.black, 20), textcolor = rsi_col, size = sz_panel))

    // ── (G) ROTATED VP — fixed middle‑right, offset inputs ────────────
    if show_rvp
        // Compute its own profile independently
        r_levels = array.new_float(rvp_rows + 1)
        for x = 0 to rvp_rows by 1
            array.set(r_levels, x, r_bot + r_step * x)

        r_totalvols = array.new_float(rvp_rows, 0.)
        for b = 0 to rvp_bars - 1 by 1
            r_body_top = math.max(close[b], open[b])
            r_body_bot = math.min(close[b], open[b])
            r_topwick = high[b] - r_body_top
            r_botwick = r_body_bot - low[b]
            r_body = r_body_top - r_body_bot
            r_denom = 2 * r_topwick + 2 * r_botwick + r_body
            r_bodyvol = r_body * volume[b] / r_denom
            r_topvol = 2 * r_topwick * volume[b] / r_denom
            r_botvol = 2 * r_botwick * volume[b] / r_denom
            for x = 0 to rvp_rows - 1 by 1
                l1 = array.get(r_levels, x)
                l2 = array.get(r_levels, x + 1)
                v = get_vol(l1, l2, r_body_bot, r_body_top, r_body, r_bodyvol) + get_vol(l1, l2, r_body_top, high[b], r_topwick, r_topvol) / 2 + get_vol(l1, l2, r_body_bot, low[b], r_botwick, r_botvol) / 2
                array.set(r_totalvols, x, array.get(r_totalvols, x) + v)

        r_maxvol = array.max(r_totalvols)
        int r_poc = array.indexof(r_totalvols, r_maxvol)

        r_totalmax = array.sum(r_totalvols) * rvp_pct / 100.
        r_va_total = array.get(r_totalvols, r_poc)
        int r_up = r_poc
        int r_down = r_poc
        for x = 0 to rvp_rows - 1 by 1
            if r_va_total >= r_totalmax
                break
            rupper = r_up < rvp_rows - 1 ? array.get(r_totalvols, r_up + 1) : 0.
            rlower = r_down > 0 ? array.get(r_totalvols, r_down - 1) : 0.
            if rupper == 0 and rlower == 0
                break
            if rupper >= rlower
                r_va_total := r_va_total + rupper
                r_up := r_up + 1
                r_up
            else
                r_va_total := r_va_total + rlower
                r_down := r_down - 1
                r_down

        r_poc_price = (array.get(r_levels, r_poc) + array.get(r_levels, r_poc + 1)) / 2
        r_vah_price = array.get(r_levels, r_up + 1)
        r_val_price = array.get(r_levels, r_down)

        // ── Geometry: middle‑right, offset inputs control horizontal & vertical gaps ─
        r_x0 = bar_index + rvp_offset
        r_hgt = (r_top - r_bot) * rvp_hpct / 100.
        r_rng = r_top - r_bot
        r_mid = (r_top + r_bot) / 2 + r_rng * rvp_voffset / 100. // vertical offset applied here
        r_base = r_mid - r_hgt / 2 // vertical centre aligned to (mid‑price + offset)
        r_colstep = rvp_colw + rvp_gap
        r_xend = r_x0 + rvp_rows * r_colstep

        // Confining frame 
        if rvp_show_frame
            frame_left = r_x0 - r_colstep * 2
            frame_right = r_xend + r_colstep
            frame_bottom = r_base - (r_top - r_bot) * 0.10
            frame_top = r_base + r_hgt * 1.32
            array.push(boxes, box.new(frame_left, frame_top, frame_right, frame_bottom, border_color = rvp_frame_col, border_width = 2, bgcolor = color.new(#0b2a4a, 85)))

        // Bars
        for i = 0 to rvp_rows - 1 by 1
            x1 = r_x0 + i * r_colstep
            x2 = x1 + rvp_colw
            v = array.get(r_totalvols, i)
            h = r_maxvol > 0 ? v / r_maxvol * r_hgt : 0.
            c = i == r_poc ? rvp_poc_col : i >= r_down and i <= r_up ? rvp_bar_col : rvp_out_col
            array.push(boxes, box.new(x1, r_base + h, x2, r_base, border_width = 0, bgcolor = c))

        // Axes + labels
        if rvp_show_axis
            array.push(lns, line.new(r_x0 - 1, r_base, r_xend, r_base, color = rvp_txt_col, width = 1))
            array.push(lns, line.new(r_xend - 1, r_base, r_xend + 1, r_base, color = rvp_txt_col, width = 1))
            array.push(lns, line.new(r_x0 - 1, r_base, r_x0 - 1, r_base + r_hgt * 1.05, color = rvp_txt_col, width = 1))
            for t = 0 to rvp_axis_ticks by 1
                yv = r_base + r_hgt * t / rvp_axis_ticks
                array.push(lns, line.new(r_x0 - 2, yv, r_x0 - 1, yv, color = rvp_txt_col, width = 1))
                array.push(lbls, label.new(r_x0 - 2, yv, str.tostring(r_maxvol * t / rvp_axis_ticks, format.volume), style = label.style_label_right, color = transp, textcolor = rvp_txt_col, size = size.small))
            for i = 0 to rvp_rows - 1 by 1
                if i % rvp_lblstep == 0 and i != r_poc
                    pr = (array.get(r_levels, i) + array.get(r_levels, i + 1)) / 2
                    array.push(lbls, label.new(r_xc(r_x0 + i * r_colstep), r_base, str.tostring(math.round_to_mintick(pr)), style = label.style_label_up, color = transp, textcolor = rvp_txt_col, size = size.small))

        r_hb = r_base + r_hgt * 1.02

        // POC arrow + label (top row)
        r_pocx = r_xc(r_x0 + r_poc * r_colstep)
        r_poctop = r_base + array.get(r_totalvols, r_poc) / r_maxvol * r_hgt
        array.push(lns, line.new(r_pocx, r_hb, r_pocx, r_poctop, color = rvp_poc_col, width = 2))
        array.push(lbls, label.new(r_pocx, r_hb + r_hgt * 0.15, 'POC', style = label.style_label_down, color = transp, textcolor = rvp_poc_col, size = size.small))

        // VAH / VAL brackets
        if rvp_show_va
            r_valx = r_xc(r_x0 + r_down * r_colstep)
            r_vahx = r_xc(r_x0 + r_up * r_colstep)
            r_valtop = r_base + array.get(r_totalvols, r_down) / r_maxvol * r_hgt
            r_vahtop = r_base + array.get(r_totalvols, r_up) / r_maxvol * r_hgt
            // VAL (left, bottom row)
            array.push(lns, line.new(r_valx, r_valtop, r_valx, r_hb, color = rvp_va_col, width = 1))
            array.push(lns, line.new(r_valx, r_hb, r_pocx, r_hb, color = rvp_va_col, width = 1, style = line.style_dashed))
            array.push(lbls, label.new(r_valx, r_hb - r_hgt * 0.01, 'VAL', style = label.style_label_down, color = transp, textcolor = rvp_va_col, size = size.small))
            // VAH (right, middle row)
            array.push(lns, line.new(r_vahx, r_vahtop, r_vahx, r_hb, color = rvp_va_col, width = 1))
            array.push(lns, line.new(r_pocx, r_hb, r_vahx, r_hb, color = rvp_va_col, width = 1, style = line.style_dashed))
            array.push(lbls, label.new(r_vahx, r_hb + r_hgt * 0.07, 'VAH', style = label.style_label_down, color = transp, textcolor = rvp_va_col, size = size.small))
````

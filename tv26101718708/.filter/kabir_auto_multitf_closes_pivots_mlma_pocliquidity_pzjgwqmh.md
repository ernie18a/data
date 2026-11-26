# kabir Auto Multi-TF Closes & Pivots + MLMA + POC/Liquidity

- url: https://www.tradingview.com/script/pZjgwqmH-kabir-Auto-Multi-TF-Closes-Pivots-MLMA-POC-Liquidity/
- type: indicator
- pine_id: PUB;9341b64cbdd54a9ea8b69714bf6e3640
- version: 1.0

## Description

Title: Irfan Kabir Growth Formula
Author: Irfan Kabir

Overview:
The "Irfan Kabir Growth Formula" is an all-in-one intraday and swing trading system engineered to identify high-probability breakout setups using multi-timeframe structural levels and institutional liquidity dynamics.

By integrating key closing levels from the 4-Hour, Daily, Weekly, and Monthly timeframes alongside a Machine Learning Moving Average (MLMA), automated Point of Control (POC), and swing-based Order Blocks (OB), this formula delivers clear, rule-based market execution.

Key Components & Features:
1. Multi-TF Closes & Full Extension Levels (4H, Daily, Weekly, Monthly):
   - Full-length, thick structural lines representing critical institutional closes across multiple timeframes.
   - Provides immediate visual clarity on higher-timeframe support and resistance zones.

2. LuxAlgo Machine Learning Moving Average (MLMA):
   - Adaptive trend filtering designed to reduce false breakout signals and align trades with the dominant trend.

3. Auto Intraday POC & Liquidity / Order Blocks (OB):
   - Automatically detects the intraday Point of Control (POC) and swing 17 liquidity zones (Upper Supply and Lower Demand).

4. Built-in Momentum Confirmation (Custom AO):
   - On-chart momentum tracking based on fast/slow moving average differentials to confirm breakout strength.

Risk Management & Execution Rules:
- Risk per Trade: 5% strict capital allocation per setup.
- Target / Profit Reward: Aiming for 10% to 50% reward on every trade, offering a Risk-to-Reward Ratio (RRR) ranging from 1:2 to 1:10 depending on timeframe confluence.
- Entry Confirmation: Execute entries only after a decisive candle close breaks beyond the key TF Close, POC, or Order Block levels.

Disclaimer:
This script is published for technical analysis and educational purposes only. Trading financial assets involves significant capital risk; always exercise strict risk and money management.

## Source Code

````pine
//@version=6
indicator('Auto Multi-TF Closes & Pivots + MLMA + POC/Liquidity', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// =============================================================================
// 1. STANDARD DEVIATION PIVOTS (4H, DAY, WEEK, MONTH CLOSE - THICK FULL LINES)
// =============================================================================
grp_piv = 'SD Pivots & Closes'
show_lbls = input.bool(true, 'Show Labels?', group = grp_piv)
hide_hist = input.bool(true, 'Hide Historical Lines?', group = grp_piv)
show_3_5 = input.bool(true, 'Show SD Level 3-5?', group = grp_piv)
show_6_10 = input.bool(true, 'Show SD Level 6-10?', group = grp_piv)

// टाइमफ्रेम डेटा फेच (Previous Close और Range)
f_get_tf(tf) =>
    request.security(syminfo.tickerid, tf, [close[1], high[1], low[1]], lookahead = barmerge.lookahead_on)

[c_4h, h_4h, l_4h] = f_get_tf('240')
[c_1d, h_1d, l_1d] = f_get_tf('D')
[c_1w, h_1w, l_1w] = f_get_tf('W')
[c_1m, h_1m, l_1m] = f_get_tf('M')

// लाइन ड्रॉ फंक्शन (सिंगल लाइन स्ट्रक्चर ताकि कभी भी सिंटेक्स एरर न आए)
f_draw_tf(name, base_c, h_val, l_val, col, main_w, sub_w) =>
    var array<line> l_arr = array.new_line()
    var array<label> lb_arr = array.new_label()
    if hide_hist
        if array.size(l_arr) > 0
            for i = 0 to array.size(l_arr) - 1 by 1
                line.delete(array.get(l_arr, i))
            array.clear(l_arr)
        if array.size(lb_arr) > 0
            for i = 0 to array.size(lb_arr) - 1 by 1
                label.delete(array.get(lb_arr, i))
            array.clear(lb_arr)
    sd = (h_val - l_val) / 2.0
    x1 = bar_index
    x2 = bar_index + 20
    // मुख्य क्लोज लाइन (फुल मोटी लाइन)
    l_main = line.new(x1, base_c, x2, base_c, extend = extend.right, color = col, width = main_w, style = line.style_solid)
    array.push(l_arr, l_main)
    if show_lbls
        lb_main = label.new(x1, base_c, '■ ' + name + ' CLOSE', color = col, textcolor = color.white, style = label.style_label_left, size = size.normal)
        array.push(lb_arr, lb_main)
    // डेविएशन लेवल्स
    for m = 1 to 10 by 1
        is_on = m <= 2 or m >= 3 and m <= 5 and show_3_5 or m >= 6 and m <= 10 and show_6_10
        if is_on
            u_p = base_c + sd * m
            d_p = base_c - sd * m
            l_u = line.new(x1, u_p, x2, u_p, extend = extend.right, color = col, width = sub_w, style = line.style_dashed)
            l_d = line.new(x1, d_p, x2, d_p, extend = extend.right, color = col, width = sub_w, style = line.style_dashed)
            array.push(l_arr, l_u)
            array.push(l_arr, l_d)
            if show_lbls
                lb_u = label.new(x1, u_p, name + ' +' + str.tostring(m) + 'σ', color = color.new(col, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
                lb_d = label.new(x1, d_p, name + ' -' + str.tostring(m) + 'σ', color = color.new(col, 20), textcolor = color.white, style = label.style_label_left, size = size.small)
                array.push(lb_arr, lb_u)
                array.push(lb_arr, lb_d)

// चार्ट के अंत में ऑटोमेटिक रेंडर
if barstate.islast
    f_draw_tf('4H', c_4h, h_4h, l_4h, color.orange, 3, 1)
    f_draw_tf('DAY', c_1d, h_1d, l_1d, color.blue, 3, 1)
    f_draw_tf('WEEKLY', c_1w, h_1w, l_1w, #311b92, 4, 2)
    f_draw_tf('MONTHLY', c_1m, h_1m, l_1m, #880e4f, 4, 2)

// =============================================================================
// 2. LUXALGO - MACHINE LEARNING MOVING AVERAGE (मोटी लाइन linewidth=4)
// =============================================================================
grp_mlma = 'LuxAlgo - ML Moving Average'
ml_win = input.int(100, 'Window', group = grp_mlma)
ml_sig = input.float(0.02, 'Sigma', group = grp_mlma)
ml_fac = input.float(3.0, 'Factor', group = grp_mlma)
ml_src = input.source(close, 'Source', group = grp_mlma)

var float sum_w = 0.0
var float sum_v = 0.0
sum_w := 0.0
sum_v := 0.0
for i = 0 to ml_win - 1 by 1
    w = math.exp(-math.pow(i, 2) / (2 * math.pow(ml_sig * ml_fac * ml_win, 2)))
    sum_w := sum_w + w
    sum_v := sum_v + ml_src[i] * w
    sum_v

mlma = sum_v / sum_w
mlma_col = mlma >= mlma[1] ? color.blue : color.red
plot(mlma, 'ML Moving Average', color = mlma_col, linewidth = 4)

// =============================================================================
// 3. AUTO INTRADAY POC & LIQUIDITY LINES (17 Swing Length)
// =============================================================================
grp_liq = 'Auto Intraday POC & Liquidity'
sw_len = input.int(17, 'Liquidity Swing Length', group = grp_liq)

hi_swing = ta.pivothigh(high, sw_len, sw_len)
lo_swing = ta.pivotlow(low, sw_len, sw_len)

var line liq_hi = na
var line liq_lo = na
if not na(hi_swing)
    line.delete(liq_hi)
    liq_hi := line.new(bar_index[sw_len], hi_swing, bar_index, hi_swing, color = color.maroon, width = 3, extend = extend.right, style = line.style_dashed)
    liq_hi
if not na(lo_swing)
    line.delete(liq_lo)
    liq_lo := line.new(bar_index[sw_len], lo_swing, bar_index, lo_swing, color = color.teal, width = 3, extend = extend.right, style = line.style_dashed)
    liq_lo

// ऑटो इंट्राडे POC (Highest Volume Weighted Price)
var float cur_poc = na
var float max_session_vol = 0.0
is_new_day = ta.change(time('D')) != 0
if is_new_day
    max_session_vol := volume
    cur_poc := hlc3
    cur_poc
else
    if volume > max_session_vol
        max_session_vol := volume
        cur_poc := hlc3
        cur_poc

var line poc_line = na
if barstate.islast and not na(cur_poc)
    line.delete(poc_line)
    poc_line := line.new(bar_index - 30, cur_poc, bar_index + 15, cur_poc, color = color.yellow, width = 3, extend = extend.right, style = line.style_solid)
    poc_line
````

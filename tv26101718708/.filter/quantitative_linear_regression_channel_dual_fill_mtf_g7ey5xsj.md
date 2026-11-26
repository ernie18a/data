# Quantitative Linear Regression Channel [Dual Fill + MTF]

- url: https://www.tradingview.com/script/G7EY5xsj-Quantitative-Linear-Regression-Channel-Dual-Fill-MTF/
- type: indicator
- pine_id: PUB;2d649746632c40e686debe0137339ceb
- version: 3.0

## Description

Abstract / Description:
This is a significantly upgraded v6 version of the classic Linear Regression Channel originally created by LonesomeTheBlue.
Key Improvements over the original:

Updated to Pine Script v6 with modern syntax and better performance.
Persistent object pool for lines and labels – eliminates object leakage and improves rendering speed.
Optional dual-zone fill (Upper and Lower) with fully customizable colors for clearer visual separation.
Broken channel visualization that freezes the previous channel in blue dotted style instead of deleting it immediately.
Dynamic MTF Trend Table (5m to 1D) showing slope direction with arrows and color coding. Table position is user-configurable (top_left, top_right, etc.).
Support for calculating the channel on a higher timeframe (MTF mode) while displaying it cleanly on the current chart.
Cleaner code structure, grouped inputs, improved alerts, and overall more stable behavior across all timeframes.

The core regression calculation and broken channel logic remain faithful to the original concept, while adding modern institutional-grade features for better usability and performance.
Credits:
Base concept and original code by © LonesomeTheBlue (2020).
v6 architecture, persistent pool, dual fill, MTF table and optimizations by datapro (2026).
Recommended use: Works on any timeframe. Best results when used with the MTF table for confluence.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue (Original Concept)
// © datapro (v6 Architecture & MTF Hardening)

//@version=6

// ─────────────────────────────────────────────────────────────────────────────
// 1. DISCLAIMER & LICENSE
// ─────────────────────────────────────────────────────────────────────────────
// Licensed under MPL 2.0. Attribution required.
// NO FINANCIAL ADVICE. Use at your own risk. Provided "AS IS".
// ─────────────────────────────────────────────────────────────────────────────

indicator(title = "Quantitative Linear Regression Channel [Dual Fill + MTF]", shorttitle = "Q-LRC MTF", overlay = true, max_bars_back = 1000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// 2. INPUTS
// ─────────────────────────────────────────────────────────────────────────────
src = input.source(close, "Source", group = "Channel Settings")
len = input.int(100, "Length", minval = 10, group = "Channel Settings")
devlen = input.float(2.0, "Deviation", minval = 0.1, step = 0.1, group = "Channel Settings")
calc_tf = input.timeframe("", "Channel Calculation TF (Empty = Chart TF)", group = "Channel Settings")
extendit = input.bool(true, "Extend Lines", group = "Channel Settings")
showfibo = input.bool(false, "Show Fibonacci Levels", group = "Channel Settings")
showfill = input.bool(true, "Fill Channel", group = "Visuals")
fill_up = input.color(color.new(color.teal, 85), "Fill Upper Zone", inline = "fills", group = "Visuals")
fill_dn = input.color(color.new(color.maroon, 85), "Fill Lower Zone", inline = "fills", group = "Visuals")
showbroken = input.bool(true, "Show Broken Channel", inline = "brk", group = "Visuals")
brokencol = input.color(color.blue, "", inline = "brk", group = "Visuals")
upcol = input.color(color.lime, "Up Trend Color", inline = "trcols", group = "Visuals")
dncol = input.color(color.red, "Down Trend Color", inline = "trcols", group = "Visuals")
widt = input.int(2, "Line Width", group = "Visuals")
show_table = input.bool(true, "Show MTF Trend Table", group = "MTF Table")
table_pos = input.string("top_right", "Table Position", options = ["top_left", "top_right", "bottom_left", "bottom_right"], group = "MTF Table")

// ─────────────────────────────────────────────────────────────────────────────
// 3. UTILITY FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
// 3.1: Sign Helper
get_sign(val) => val > 0 ? 1 : val < 0 ? -1 : 0

// 3.2: Trend Arrow Helper
get_trend_arrow(slope_curr, slope_prev) =>
     slope_curr > 0 ? (slope_curr > slope_prev ? "⇑" : "⇗") :
     slope_curr < 0 ? (slope_curr < slope_prev ? "⇓" : "⇘") :
     "⇒"

// 3.3: Table Position Helper
get_table_position(pos_string) =>
     pos_string == "top_left" ? position.top_left :
     pos_string == "top_right" ? position.top_right :
     pos_string == "bottom_left" ? position.bottom_left :
     position.bottom_right

// 3.4: Irregular Timeframe Check
is_irregular_tf(tf) =>
    tf == "M" or tf == "3M" or tf == "6M" or tf == "12M" or tf == "Y"

// 3.5: Persistent Line Management Helper
set_line(arr, idx, x1, y1, x2, y2, col, sty, w, ext) =>
    ln = array.size(arr) > idx ? array.get(arr, idx) : na
    if na(ln)
        ln := line.new(x1, y1, x2, y2, color = col, style = sty, width = w, extend = ext)
        if array.size(arr) > idx
            array.set(arr, idx, ln)
        else
            while array.size(arr) <= idx
                array.push(arr, na)
            array.set(arr, idx, ln)
    else
        line.set_xy1(ln, x1, y1)
        line.set_xy2(ln, x2, y2)
        line.set_color(ln, col)
        line.set_style(ln, sty)
        line.set_width(ln, w)
        line.set_extend(ln, ext)
    ln

// ─────────────────────────────────────────────────────────────────────────────
// 4. DATA STRUCTURES
// ─────────────────────────────────────────────────────────────────────────────
var float[] fibo_ratios = array.from(0.236, 0.382, 0.618, 0.786)
var color[] colors = array.new_color(2)
if barstate.isfirst
    array.set(colors, 0, dncol)
    array.set(colors, 1, upcol)

// ─────────────────────────────────────────────────────────────────────────────
// 5. CORE CHANNEL MTF ENGINE
// ─────────────────────────────────────────────────────────────────────────────
// 5.1: Pure Channel Calculation
f_calc_channel(src_val, length) =>
    float slope_  = ta.linreg(src_val, length, 0) - ta.linreg(src_val, length, 1)
    float endP_   = ta.linreg(src_val, length, 0)
    float sum_sq  = 0.0
    for i = 0 to length - 1
        float fitted = endP_ - slope_ * i
        sum_sq += math.pow(src_val[i] - fitted, 2)
    float stdDev_ = math.sqrt(sum_sq / math.max(length - 1, 1))
    [slope_, endP_, stdDev_]

// 5.2: MTF Transport Layer
tf_to_use = calc_tf == "" ? timeframe.period : calc_tf

[slope_val_raw, end_price_val_raw, stdev_val_raw] = request.security(
     syminfo.tickerid,
     tf_to_use,
     f_calc_channel(src, len),
     lookahead = barmerge.lookahead_off,
     gaps = barmerge.gaps_off
)

float slope_val     = nz(slope_val_raw, 0.0)
float end_price_val = nz(end_price_val_raw, close)
float stdev_safe    = nz(stdev_val_raw, 0.0)

// 5.3: Dynamic Visual Length
float tf_sec_src   = timeframe.in_seconds(tf_to_use)
float tf_sec_chart = timeframe.in_seconds(timeframe.period)
int   visual_len_dynamic = len
if tf_sec_src > 0 and tf_sec_chart > 0 and not is_irregular_tf(tf_to_use)
    float ratio = tf_sec_src / tf_sec_chart
    visual_len_dynamic := math.round(len * ratio)
visual_len_dynamic := math.max(visual_len_dynamic, 1)

// 5.4: Time Geometry (Safe lookback)
var int start_x = na
if barstate.islast
    int tf_sec = timeframe.in_seconds(tf_to_use)
    float lookback_ms = (len - 1) * (na(tf_sec) ? 2592000.0 : tf_sec) * 1000.0
    float target_time = time - lookback_ms
    int found_x = na
    int max_i   = math.min(bar_index, len * 5)
    for i = 0 to max_i
        if time[i] <= target_time
            found_x := bar_index - i
            break
    start_x := na(found_x) ? math.max(bar_index - (len - 1), 0) : found_x

if na(start_x) or start_x > bar_index
    start_x := math.max(bar_index - (len - 1), 0)

int start_x_final = barstate.islast ? start_x : (bar_index - visual_len_dynamic)
start_x_final := math.max(math.min(start_x_final, bar_index), 0)
int visual_len = bar_index - start_x_final

// ─────────────────────────────────────────────────────────────────────────────
// 5.5: PRICE GEOMETRY & BREAKOUT DETECTION (HFT Sanitized)
// ─────────────────────────────────────────────────────────────────────────────
float start_price     = end_price_val - slope_val * visual_len
float upperStartPrice = start_price + stdev_safe * devlen
float upperEndPrice   = end_price_val + stdev_safe * devlen
float lowerStartPrice = start_price - stdev_safe * devlen
float lowerEndPrice   = end_price_val - stdev_safe * devlen

// Institutional Fix: Breakout logic must evaluate the exact 'src' series 
// used to construct the channel bounds. Evaluating 'close' against an 'hl2' 
// channel causes systematic false triggers in LTF/HFT execution.
int outofchannel = (src > upperEndPrice) ? 2 : (src < lowerEndPrice) ? 0 : -1

// ─────────────────────────────────────────────────────────────────────────────
// 6. MTF SLOPE TRANSPORT (TABLE DATA)
// ─────────────────────────────────────────────────────────────────────────────
// 6.1: Unified slope calculation (Uses dynamic 'src' instead of hardcoded 'close')
calc_slope(src_val, int tf_len) =>
    ta.linreg(src_val, tf_len, 0) - ta.linreg(src_val, tf_len, 1)

// 6.2: MTF Tuple Wrapper
get_all_mtfs_slopes() =>
    s5  = request.security(syminfo.tickerid, "5",   calc_slope(src, len), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    s15 = request.security(syminfo.tickerid, "15",  calc_slope(src, len), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    s60 = request.security(syminfo.tickerid, "60",  calc_slope(src, len), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    s240= request.security(syminfo.tickerid, "240", calc_slope(src, len), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    sD  = request.security(syminfo.tickerid, "D",   calc_slope(src, len), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    [s5, s5[1], s15, s15[1], s60, s60[1], s240, s240[1], sD, sD[1]]

// 6.3: Tuple Destructuring (Indentation strictly non-multiple of 4)
[s5m, s5m_prev, s15m, s15m_prev, s1h, s1h_prev, s4h, s4h_prev, s1d, s1d_prev] = 
     get_all_mtfs_slopes()

// ─────────────────────────────────────────────────────────────────────────────
// 7. RENDER ENGINE
// ─────────────────────────────────────────────────────────────────────────────
// 7.1: Persistent Object Pool
var line baseLine = na
var line upperLine = na
var line lowerLine = na
var linefill upFill = na
var linefill dnFill = na
var line[] fibolines = array.new_line(4)
var line[] broken_lines = array.new_line(5)
var label sideLab = label.new(bar_index, na, "", style = label.style_label_right, size = size.large, textcolor = color.white)

// 7.2: Broken Channel Logic
bool is_breaking = outofchannel != -1 and nz(outofchannel[1], -1) == -1

if is_breaking and showbroken
    float y_b1 = outofchannel == 0 ? lowerStartPrice : upperStartPrice
    float y_b2 = outofchannel == 0 ? lowerEndPrice   : upperEndPrice
    if not na(start_x_final) and not na(y_b1) and not na(y_b2)
        line new_brk = line.new(start_x_final, y_b1, bar_index, y_b2, color = brokencol, style = line.style_dotted, width = widt, extend = extend.none)
        if array.size(broken_lines) >= 5
            line oldest = array.shift(broken_lines)
            if not na(oldest)
                line.delete(oldest)
        array.push(broken_lines, new_brk)

// 7.3: Main Channel Draw
if barstate.islast
    if na(start_x_final) or start_x_final > bar_index
        start_x_final := math.max(bar_index - (len - 1), 0)
    raw_idx = math.round(math.max(get_sign(slope_val), 0))
    col_idx = math.min(raw_idx, array.size(colors) - 1)
    base_col = array.get(colors, col_idx)
    ext_style = extendit ? extend.right : extend.none
    
    if na(baseLine)
        baseLine := line.new(start_x_final, start_price, bar_index, end_price_val, color = base_col, width = widt, extend = ext_style)
        upperLine := line.new(start_x_final, upperStartPrice, bar_index, upperEndPrice, color = base_col, style = line.style_dashed, width = widt, extend = ext_style)
        lowerLine := line.new(start_x_final, lowerStartPrice, bar_index, lowerEndPrice, color = base_col, style = line.style_dashed, width = widt, extend = ext_style)
        if showfill
            upFill := linefill.new(upperLine, baseLine, color = fill_up)
            dnFill := linefill.new(baseLine, lowerLine, color = fill_dn)
    else
        line.set_xy1(baseLine, start_x_final, start_price)
        line.set_xy2(baseLine, bar_index, end_price_val)
        line.set_color(baseLine, base_col)
        line.set_extend(baseLine, ext_style)
        line.set_xy1(upperLine, start_x_final, upperStartPrice)
        line.set_xy2(upperLine, bar_index, upperEndPrice)
        line.set_color(upperLine, base_col)
        line.set_extend(upperLine, ext_style)
        line.set_xy1(lowerLine, start_x_final, lowerStartPrice)
        line.set_xy2(lowerLine, bar_index, lowerEndPrice)
        line.set_color(lowerLine, base_col)
        line.set_extend(lowerLine, ext_style)
        
    if showfibo
        for x = 0 to 3
            ratio = array.get(fibo_ratios, x)
            y_fibo_start = lowerStartPrice + (upperStartPrice - lowerStartPrice) * ratio
            y_fibo_end = lowerEndPrice + (upperEndPrice - lowerEndPrice) * ratio
            set_line(fibolines, x, start_x_final, y_fibo_start, bar_index, y_fibo_end, base_col, line.style_dotted, widt, ext_style)
            
    txt = get_trend_arrow(slope_val, nz(slope_val[1]))
    stl = slope_val > 0 ? (slope_val > nz(slope_val[1]) ? label.style_label_up : label.style_label_upper_right) : slope_val < 0 ? (slope_val < nz(slope_val[1]) ? label.style_label_down : label.style_label_lower_right) : label.style_label_right
    label.set_text(sideLab, txt)
    label.set_style(sideLab, stl)
    label.set_x(sideLab, start_x_final)
    label.set_y(sideLab, slope_val > 0 ? lowerStartPrice : slope_val < 0 ? upperStartPrice : start_price)
    label.set_color(sideLab, base_col)

// ─────────────────────────────────────────────────────────────────────────────
// 8. ALERTS (Global Scope)
// ─────────────────────────────────────────────────────────────────────────────
// Note: Alert conditions now strictly reflect 'src' dynamics, not raw 'close'.
alertcondition(outofchannel != -1, title = "Channel Broken", message = "Q-LRC: Channel Broken on {{ticker}} {{interval}}")
trendisup = get_sign(slope_val) != get_sign(nz(slope_val[1])) and slope_val > 0
trendisdown = get_sign(slope_val) != get_sign(nz(slope_val[1])) and slope_val < 0
alertcondition(trendisup, title = "Up trend", message = "Q-LRC: Bullish trend change detected")
alertcondition(trendisdown, title = "Down trend", message = "Q-LRC: Bearish trend change detected")

// ─────────────────────────────────────────────────────────────────────────────
// 9. MTF TABLE RENDER
// ─────────────────────────────────────────────────────────────────────────────
var table mtf_table = na
if show_table
    pos = get_table_position(table_pos)
    if na(mtf_table)
        mtf_table := table.new(pos, 2, 6, bgcolor = color.new(color.black, 80), frame_width = 1, border_width = 1)
    else
        table.set_position(mtf_table, pos)
    if barstate.isfirst
        table.cell(mtf_table, 0, 0, "TF", text_color = color.white, bgcolor = color.gray)
        table.cell(mtf_table, 1, 0, "Direction", text_color = color.white, bgcolor = color.gray)
    if barstate.islast
        table.cell(mtf_table, 0, 1, "5m", text_color = color.white)
        table.cell(mtf_table, 1, 1, get_trend_arrow(s5m, nz(s5m_prev)), text_color = color.white, bgcolor = s5m > 0 ? color.new(upcol, 70) : s5m < 0 ? color.new(dncol, 70) : color.new(color.blue, 70))
        table.cell(mtf_table, 0, 2, "15m", text_color = color.white)
        table.cell(mtf_table, 1, 2, get_trend_arrow(s15m, nz(s15m_prev)), text_color = color.white, bgcolor = s15m > 0 ? color.new(upcol, 70) : s15m < 0 ? color.new(dncol, 70) : color.new(color.blue, 70))
        table.cell(mtf_table, 0, 3, "1h", text_color = color.white)
        table.cell(mtf_table, 1, 3, get_trend_arrow(s1h, nz(s1h_prev)), text_color = color.white, bgcolor = s1h > 0 ? color.new(upcol, 70) : s1h < 0 ? color.new(dncol, 70) : color.new(color.blue, 70))
        table.cell(mtf_table, 0, 4, "4h", text_color = color.white)
        table.cell(mtf_table, 1, 4, get_trend_arrow(s4h, nz(s4h_prev)), text_color = color.white, bgcolor = s4h > 0 ? color.new(upcol, 70) : s4h < 0 ? color.new(dncol, 70) : color.new(color.blue, 70))
        table.cell(mtf_table, 0, 5, "1D", text_color = color.white)
        table.cell(mtf_table, 1, 5, get_trend_arrow(s1d, nz(s1d_prev)), text_color = color.white, bgcolor = s1d > 0 ? color.new(upcol, 70) : s1d < 0 ? color.new(dncol, 70) : color.new(color.blue, 70))
````

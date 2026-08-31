<!-- tradingview-pine-id: PUB;218f3b0465cf414c801ab7677a9cf561 -->
<!-- tradingviewscripts-format: 1 -->
# StO Price Action - Orderblock

Source: https://www.tradingview.com/script/1sRdxjHp-StO-Price-Action-Orderblock/

## Description

This Generates Order Blocks For You. Hint Use The Order Block As Your Entry And Stop Loss. And Only Take A Trade On The Retest / But Make Sure That Before It Retest the Price Went 2.5X Away From the Entry Compared To The Stop Loss.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sto_svc (Stephan Opitz)
// @version=6
indicator(title="StO Price Action - Orderblock", shorttitle="StO OB", max_lines_count=500, max_boxes_count=500, overlay=true)

// type
type OB
    box box_id
    line ce_line_id     
    bool is_bullish
    float mitigation_limit
    int touch_time = 0

// functions
in_session(sess) =>
    not na(time(timeframe.period, sess, "America/New_York"))

is_time_in_session(int t_check, string sess_val) =>
    bool result = false
    if sess_val != ""
        parts = str.split(sess_val, "-")
        if array.size(parts) >= 2
            start_str = array.get(parts, 0)
            // session might have days attached
            end_parts = str.split(array.get(parts, 1), ":")
            end_str   = array.get(end_parts, 0)
            
            s_val = str.tonumber(start_str)
            e_val = str.tonumber(end_str)
            
            if not na(s_val) and not na(e_val)
                // convert to total minutes
                s_mins = math.floor(s_val / 100) * 60 + (s_val % 100)
                e_mins = math.floor(e_val / 100) * 60 + (e_val % 100)
                
                // get check time in ny minutes
                t_h = hour(t_check, "America/New_York")
                t_m = minute(t_check, "America/New_York")
                t_mins = t_h * 60 + t_m
                
                if s_mins < e_mins // intraday session
                    result := t_mins >= s_mins and t_mins < e_mins
                else // overnight session
                    result := t_mins >= s_mins or t_mins < e_mins
    result

check_killzones(t_check, asia_use, asia_def, lm_use, lm_def, nym_use, nym_def) =>
    in_asia = asia_use and is_time_in_session(t_check, asia_def)
    in_lm   = lm_use and is_time_in_session(t_check, lm_def)
    in_nym  = nym_use and is_time_in_session(t_check, nym_def)
    in_asia or in_lm or in_nym

build_candles(tf, tf_times, tf_values, n_candles) =>
    is_new = bool(ta.change(time(tf)))

    // initialize
    if array.size(tf_values) == 0
        for _ = 0 to n_candles - 1
            array.push(tf_values, open)
            array.push(tf_values, high)
            array.push(tf_values, low)
            array.push(tf_values, close)

    if array.size(tf_times) == 0
        for _ = 0 to n_candles - 1
            array.push(tf_times, time)

    // new candle
    if is_new
        if n_candles > 1
            // shift candles backwards
            for c = n_candles - 2 to 0 by 1
                src = c * 4
                dst = (c + 1) * 4

                for o = 0 to 3
                    array.set(tf_values, dst + o, array.get(tf_values, src + o))

                array.set(tf_times, c + 1, array.get(tf_times, c))

        // new current candle
        array.set(tf_values, 0, open)
        array.set(tf_values, 1, high)
        array.set(tf_values, 2, low)
        array.set(tf_values, 3, close)
        array.set(tf_times, 0, time)
    else // update running candle
        array.set(tf_values, 1, math.max(array.get(tf_values, 1), high))
        array.set(tf_values, 2, math.min(array.get(tf_values, 2), low))
        array.set(tf_values, 3, close)

    is_new

check_pivot(val_array, p_length, search_high) =>
    mid_idx = p_length + 1 
    mid_val = array.get(val_array, mid_idx * 4 + (search_high ? 1 : 2))
    is_piv  = true
    for i = 1 to (p_length * 2) + 1
        if i == mid_idx
            continue
        curr_val = array.get(val_array, i * 4 + (search_high ? 1 : 2))
        if (search_high and curr_val > mid_val) or (not search_high and curr_val < mid_val)
            is_piv := false
            break
    is_piv

readable_tf(tf_in) =>
    tf = (tf_in == "" or na(tf_in)) ? timeframe.period : tf_in
    
    m = str.tonumber(tf)
    result = tf // default (S, T, D, W, M)
    
    if not na(m)
        if m >= 60 // hours
            result := str.tostring(m / 60, "#.##") + "H"
        else // minutes
            result := str.tostring(m, "#") + "Min"
    
    result

update_box(OB ob, bool fill, color bg_col, color border_col, string box_style, color ce_col, bool show_ce) =>
    box.set_border_color(ob.box_id, border_col)
    box.set_border_style(ob.box_id, box_style)
    box.set_right(ob.box_id, ob.touch_time)
    line.set_x2(ob.ce_line_id, ob.touch_time)

    if fill
        box.set_bgcolor(ob.box_id, bg_col)
    
    if show_ce
        line.set_color(ob.ce_line_id, ce_col)
    else
        line.delete(ob.ce_line_id)

// inputs
tf = input.timeframe("", "TF", group="ORDERBLOCK", inline="PARAMS1", display=display.none)
color_bullish = input.color(color.new(color.green, 90), title="", group="ORDERBLOCK", inline="PARAMS1", display=display.none)
color_bearish = input.color(color.new(color.red, 90), title="", group="ORDERBLOCK", inline="PARAMS1", display=display.none)
ob_fill = input.bool(true, "Fill", group="ORDERBLOCK", inline="PARAMS1", display=display.none)
show_history = input.bool(true, "Mitigated OBs", group="ORDERBLOCK", inline="PARAMS2", display=display.none)
color_history_bullish = input.color(color.new(color.gray, 90), title="", group="ORDERBLOCK", inline="PARAMS2", display=display.none)
color_history_bearish  = input.color(color.new(color.gray, 90), title="", group="ORDERBLOCK", inline="PARAMS2", display=display.none)
box_border_width = input.int(1, "", group="ORDERBLOCK", inline="PARAMS2", display=display.none)
use_hit_highlight = input.bool(true, "Highlight on Touch", group="ORDERBLOCK", inline="PARAMS3", display=display.none)
color_highlight = input.color(color.new(color.orange, 90), "", group="ORDERBLOCK", inline="PARAMS3", display=display.none)
highlight_duration = input.int(3, "", minval=1, group="ORDERBLOCK", inline="PARAMS3", display=display.none)
ce_line = input.bool(true, "Consequent Encroachment", group="ORDERBLOCK", inline="PARAMS4", display=display.none)
color_ce_active = input.color(color.new(color.white, 20), "", group="ORDERBLOCK", inline="PARAMS4", display=display.none)

alert_on_touch = input.bool(true, "Alert On Touch", group="ALERT", inline="PARAMS1", display=display.none)
color_bv_alert = input.color(color.new(color.gray, 90), "", group="ALERT", inline="PARAMS1", display=display.none)
alert_time_active = input.bool(false, title="Active", group="ALERT", inline="PARAMS2", display=display.none)
alert_time_window = input.session(title="", defval="0201-1205", group="ALERT", inline="PARAMS2", display=display.none)
alert_bar_view = input.bool(false, "", group="ALERT", inline="PARAMS2", display=display.none)

killzone_use = input.bool(false, title="OB Starts In Killzone", group="KILLZONE", inline="PARAMS1", display=display.none)
color_bv_killzone = input.color(color.new(color.gray, 90), "", group="KILLZONE", inline="PARAMS1", display=display.none)
asia_use = input.bool(true, title="Asia", group="KILLZONE", inline="PARAMS2", display=display.none)
asia_def = input.session(title="", defval="1900-0001", group="KILLZONE", inline="PARAMS2", display=display.none)
asia_bar_view = input.bool(false, title="", group="KILLZONE", inline="PARAMS2", display=display.none)
lm_use = input.bool(true, title="London", group="KILLZONE", inline="PARAMS3", display=display.none)
lm_def = input.session(title="", defval="0300-0431", inline="PARAMS3", group="KILLZONE", display=display.none)
lm_bar_view = input.bool(false, title="", group="KILLZONE", inline="PARAMS3", display=display.none)
nym_use = input.bool(true, title="NY", group="KILLZONE", inline="PARAMS4", display=display.none)
nym_def = input.session(title="", defval="0830-1001", group="KILLZONE", inline="PARAMS4", display=display.none)
nym_bar_view = input.bool(false, title="", group="KILLZONE", inline="PARAMS4", display=display.none)

pivot_length = input.int(10, "Pivot LB", group="FILTER", inline="PARAMS1", display=display.none)
use_max_pips = input.bool(false, "Max Pips", group="FILTER", inline="PARAMS2", display=display.none)
max_width_val = input.float(13.0, "", minval=0.1, group="FILTER", inline="PARAMS2", display=display.none)
use_body_percentage = input.bool(false, "Min Body %", group="FILTER", inline="PARAMS3", display=display.none)
min_body_val = input.float(25.0, "", minval=0, maxval=100, group="FILTER", inline="PARAMS3", display=display.none)
use_displacement = input.bool(false, "Filter by ATR", group="FILTER", inline="PARAMS4", display=display.none)
displacement_factor = input.float(1.2, "", step=0.1, group="FILTER", inline="PARAMS4", display=display.none)
use_trend = input.bool(false, "Trend EMA", group="FILTER", inline="PARAMS5", display=display.none)
ema_length = input.int(200, "", group="FILTER", inline="PARAMS5", display=display.none)

// detection logic
var tf_times  = array.new_int(0)
var tf_values = array.new_float(0)
var active_ob_list = array.new<OB>()
var highlight_ob_list = array.new<OB>() 
int required_candles = (pivot_length * 2) + 2
int duration_ms = highlight_duration * timeframe.in_seconds(tf) * 1000

current_tf_min = timeframe.in_seconds() / 60
selected_tf_min = timeframe.in_seconds(tf) / 60
tf_valid = selected_tf_min >= current_tf_min

[ema_val, atr_val] = request.security(syminfo.tickerid, tf, [ta.ema(close, ema_length), ta.atr(14)])
new_tf_bar = build_candles(tf, tf_times, tf_values, required_candles)

if new_tf_bar
    is_pivot_low  = check_pivot(tf_values, pivot_length, false)
    is_pivot_high = check_pivot(tf_values, pivot_length, true)

    if is_pivot_low or is_pivot_high
        p_idx   = (pivot_length + 1) * 4
        p_open  = array.get(tf_values, p_idx + 0)
        p_high  = array.get(tf_values, p_idx + 1)
        p_low   = array.get(tf_values, p_idx + 2)
        p_close = array.get(tf_values, p_idx + 3)
        tf_close = array.get(tf_values, 1 * 4 + 3)
        start_t = array.get(tf_times, pivot_length + 1)

        killzone_valid = not killzone_use or check_killzones(start_t, asia_use, asia_def, lm_use, lm_def, nym_use, nym_def)
        ob_height_pips = (p_high - p_low) / (syminfo.mintick * 10)
        width_valid = not use_max_pips or (ob_height_pips <= max_width_val)
        body_valid = not use_body_percentage or (math.abs(p_open - p_close) / math.max(p_high - p_low, syminfo.mintick) * 100 >= min_body_val)
        move_dist = is_pivot_low ? (tf_close - p_high) : (p_low - tf_close)
        displace_valid = not use_displacement or (move_dist >= atr_val * displacement_factor)
        trend_valid = not use_trend or (is_pivot_low ? tf_close > ema_val : tf_close < ema_val)

        if tf_valid and killzone_valid and width_valid and body_valid and displace_valid and trend_valid
            theme_col = is_pivot_low ? color_bullish : color_bearish
            m_limit = is_pivot_low ? p_high : p_low
            ce_level = (p_high + p_low) / 2

            new_ob_box = box.new(start_t, p_high, time, p_low, xloc=xloc.bar_time, border_color=theme_col, bgcolor=ob_fill ? theme_col : na, border_width = box_border_width)
            new_ce_ln = line.new(start_t, ce_level, time, ce_level, xloc=xloc.bar_time, color=color.new(color.white, 50), style=line.style_dotted)

            array.push(active_ob_list, OB.new(new_ob_box, new_ce_ln, is_pivot_low, m_limit))

// mitigation
if array.size(active_ob_list) > 0
    for i = array.size(active_ob_list) - 1 to 0
        OB ob = array.get(active_ob_list, i)
        touched = ob.is_bullish ? low <= ob.mitigation_limit : high >= ob.mitigation_limit
        
        if touched
            if use_hit_highlight
                ob.touch_time := time
                update_box(ob, ob_fill, color_highlight, color_highlight, line.style_solid, color_ce_active, ce_line)
                array.push(highlight_ob_list, ob)
            else if show_history
                ob.touch_time := time
                update_box(ob, ob_fill, ob.is_bullish ? color_history_bullish : color_history_bearish, ob.is_bullish ? color_history_bullish : color_history_bearish, line.style_dotted, color_ce_active, ce_line)
            else
                box.delete(ob.box_id), line.delete(ob.ce_line_id)
            array.remove(active_ob_list, i)

            time_ok = not alert_time_active or in_session(alert_time_window)

            if alert_on_touch and time_ok
                alert(syminfo.prefix + ":" + syminfo.ticker + " " + readable_tf(tf) + (ob.is_bullish ? " Bullish OB" : " Bearish OB") + " touched")
        else
            box.set_right(ob.box_id, time)
            line.set_x2(ob.ce_line_id, time)

// highlight
if array.size(highlight_ob_list) > 0
    for i = array.size(highlight_ob_list) - 1 to 0
        OB ob = array.get(highlight_ob_list, i)
        
        if time - ob.touch_time >= duration_ms // diff reached
            if show_history
                update_box(ob, ob_fill, ob.is_bullish ? color_history_bullish : color_history_bearish, ob.is_bullish ? color_history_bullish : color_history_bearish, line.style_dotted, color_ce_active, ce_line)
            else
                box.delete(ob.box_id), line.delete(ob.ce_line_id)

            array.remove(highlight_ob_list, i)

// bar view
show_alert_bg = alert_bar_view and in_session(alert_time_window)
bgcolor(show_alert_bg ? color_bv_alert : na, title="Alert Bar View")

show_asia_bg = asia_bar_view and in_session(asia_def)
bgcolor(show_asia_bg ? color_bv_killzone : na, title="Asia Bar View")

show_lm_bg = lm_bar_view and in_session(lm_def)
bgcolor(show_lm_bg ? color_bv_killzone : na, title="London Bar View")

show_nym_bg = nym_bar_view and in_session(nym_def)
bgcolor(show_nym_bg ? color_bv_killzone : na, title="NY Bar View")
````

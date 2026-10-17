# 5S_E_W_H_MA

- url: https://www.tradingview.com/script/f7L7didw/
- type: indicator
- pine_id: PUB;bbeed8feec4d499c9909e63ca060824d
- version: 1.0

## Description

5 S_E_W_H_MA

Brief Description of How It Works
5S_E_W_H_MA is a TradingView indicator that displays 5 Dynamic Adaptive Moving Averages (SMA, EMA, WMA, HMA) that automatically adapt to the chart's timeframe.

How it works:

The base periods you set (e.g. 9, 21, 50, 100, 200) are automatically rescaled based on the current timeframe relative to a reference timeframe (default: 60 minutes)

On higher timeframes the periods lengthen, on lower timeframes they shorten

Each MA is independently configurable (type, period, colors, transparency)

Lines change color based on slope (trend coloring: green/bullish, red/bearish)

Period labels are automatically positioned without overlapping, showing base period → adapted period and the reference trend (e.g. "50 → 200 (SMA) ▲")

Main features:

Automatic timeframe adaptation

5 fully configurable MAs

Trend-based coloring

Smart auto-positioned labels

Max period safety cap

Works on all timeframes (intraday, daily, weekly)

DISCLAIMER:

This indicator is provided for informational and educational purposes only. It does not constitute financial advice or investment recommendations. Past performance does not guarantee future results. Always conduct your own research and consult with qualified financial professionals before making any trading or investment decisions. The author assumes no responsibility for any financial losses incurred through the use of this indicator.

LICENSE: Free to use, modify, and share. Attribution appreciated but not required.

## Source Code

````pine
//@version=6
// Description: 5 Dynamic Adaptive Moving Averages with automatic period scaling based on timeframe
// FIX: FULLY AUTOMATIC non-overlapping labels - NO manual gap adjustment needed!

// DISCLAIMER:
// This indicator is for informational and educational purposes only.
// It does not constitute financial advice or investment recommendations.
// Past performance does not guarantee future results.
// Always conduct your own research and consult with qualified financial professionals
// before making any trading or investment decisions.
// The author assumes no responsibility for any financial losses incurred through the use of this indicator.
//
// LICENSE: Free to use, modify, and share. Attribution appreciated but not required.



indicator("5S_E_W_H_MA", shorttitle="5S_E_W_H_MA", overlay=true, max_bars_back=5000)

// ─── GLOBAL SETTINGS ───────────────────────────────────────────────────────────
var grp_gen = "Global Settings"
ref_tf          = input.int(60,   "Reference Timeframe (Min)", minval=1, group=grp_gen)
max_per         = input.int(3000, "Max Period Safety Cap", minval=1, group=grp_gen)
use_trend_color = input.bool(true, "Enable Trend Coloring (Slope)", group=grp_gen)

// ─── LABEL SETTINGS ────────────────────────────────────────────────────────────
var grp_lbl = "Label Settings"
show_labels          = input.bool(true, "Show Period Labels", group=grp_lbl)
label_offset         = input.int(20, "Bars Offset from Price", minval=5, maxval=100, group=grp_lbl)
label_bg_transp      = input.int(70, "Label BG Transparency", minval=0, maxval=100, group=grp_lbl)
label_txt_color      = input.color(color.white, "Label Text Color", group=grp_lbl)
label_size           = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grp_lbl)
show_base_period     = input.bool(true, "Show Base Period in Label", group=grp_lbl)

// ─── MA 1 INPUTS ───────────────────────────────────────────────────────────────
var grp_ma1 = "═══ MA 1 Settings ═══"
s1 = input.bool(true, "Enable MA 1", group=grp_ma1)
t1 = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","HMA"], group=grp_ma1)
p1 = input.int(9, "Base Period", group=grp_ma1)
grp_ma1_col = "MA 1 Colors"
c1_up   = input.color(#2196F3, "Uptrend Color", group=grp_ma1_col)
c1_down = input.color(#F44336, "Downtrend Color", group=grp_ma1_col)
c1_transp = input.int(0, "Line Transparency", minval=0, maxval=100, group=grp_ma1_col)

// ─── MA 2 INPUTS ───────────────────────────────────────────────────────────────
var grp_ma2 = "═══ MA 2 Settings ═══"
s2 = input.bool(true, "Enable MA 2", group=grp_ma2)
t2 = input.string("EMA", "MA Type", options=["SMA","EMA","WMA","HMA"], group=grp_ma2)
p2 = input.int(21, "Base Period", group=grp_ma2)
grp_ma2_col = "MA 2 Colors"
c2_up   = input.color(#E91E63, "Uptrend Color", group=grp_ma2_col)
c2_down = input.color(#9C27B0, "Downtrend Color", group=grp_ma2_col)
c2_transp = input.int(0, "Line Transparency", minval=0, maxval=100, group=grp_ma2_col)

// ─── MA 3 INPUTS ───────────────────────────────────────────────────────────────
var grp_ma3 = "═══ MA 3 Settings ═══"
s3 = input.bool(true, "Enable MA 3", group=grp_ma3)
t3 = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","HMA"], group=grp_ma3)
p3 = input.int(50, "Base Period", group=grp_ma3)
grp_ma3_col = "MA 3 Colors"
c3_up   = input.color(#FF9800, "Uptrend Color", group=grp_ma3_col)
c3_down = input.color(#FF5722, "Downtrend Color", group=grp_ma3_col)
c3_transp = input.int(0, "Line Transparency", minval=0, maxval=100, group=grp_ma3_col)

// ─── MA 4 INPUTS ───────────────────────────────────────────────────────────────
var grp_ma4 = "═══ MA 4 Settings ═══"
s4 = input.bool(true, "Enable MA 4", group=grp_ma4)
t4 = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","HMA"], group=grp_ma4)
p4 = input.int(100, "Base Period", group=grp_ma4)
grp_ma4_col = "MA 4 Colors"
c4_up   = input.color(#4CAF50, "Uptrend Color", group=grp_ma4_col)
c4_down = input.color(#8BC34A, "Downtrend Color", group=grp_ma4_col)
c4_transp = input.int(0, "Line Transparency", minval=0, maxval=100, group=grp_ma4_col)

// ─── MA 5 INPUTS ───────────────────────────────────────────────────────────────
var grp_ma5 = "═══ MA 5 Settings ═══"
s5 = input.bool(true, "Enable MA 5", group=grp_ma5)
t5 = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","HMA"], group=grp_ma5)
p5 = input.int(200, "Base Period", group=grp_ma5)
grp_ma5_col = "MA 5 Colors"
c5_up   = input.color(#9C27B0, "Uptrend Color", group=grp_ma5_col)
c5_down = input.color(#673AB7, "Downtrend Color", group=grp_ma5_col)
c5_transp = input.int(0, "Line Transparency", minval=0, maxval=100, group=grp_ma5_col)

// ─── FUNCTIONS ─────────────────────────────────────────────────────────────────
f_adaptive_period(base_len) =>
    curr_min = timeframe.isintraday ? timeframe.multiplier :
               timeframe.isdaily    ? 1440  :
               timeframe.isweekly   ? 10080 : 1440
    int(math.max(math.min(math.round(float(base_len) * float(ref_tf) / float(curr_min)), max_per), 1))

f_ma(type, src, len) =>
    switch type
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        =>       ta.sma(src, len)

f_line_color(val, up_color, down_color, transp) =>
    if use_trend_color
        val > val[1] ? color.new(up_color, transp) : color.new(down_color, transp)
    else
        color.new(up_color, transp)

f_label_color(val, up_color, down_color, transp) =>
    if use_trend_color and not na(val)
        val > val[1] ? color.new(up_color, transp) : color.new(down_color, transp)
    else
        color.new(up_color, transp)

f_label_size(size_str) =>
    switch size_str
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>        size.small

f_label_text(base_period, adapted_period, ma_type, show_base, ref_trend) =>
    string trend_symbol = ref_trend ? " ▲" : " ▼"
    string period_text = show_base ? str.tostring(base_period) + " → " + str.tostring(adapted_period) + " (" + ma_type + ")" : str.tostring(adapted_period) + " (" + ma_type + ")"
    period_text + trend_symbol

// ─── REFERENCE TIMEFRAME TREND ─────────────────────────────────────────────────
f_ref_tf_trend_simple() =>
    curr_min = timeframe.isintraday ? timeframe.multiplier :
               timeframe.isdaily    ? 1440  :
               timeframe.isweekly   ? 10080 : 1440
    float ratio = float(ref_tf) / float(curr_min)
    int fast_period = math.min(math.max(math.round(20 * ratio), 10), 200)
    int slow_period = math.min(math.max(math.round(50 * ratio), 20), 500)
    float fast_ema = ta.ema(close, fast_period)
    float slow_ema = ta.ema(close, slow_period)
    fast_ema > slow_ema

ref_trend_up = f_ref_tf_trend_simple()

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
len1_adapted = f_adaptive_period(p1)
len2_adapted = f_adaptive_period(p2)
len3_adapted = f_adaptive_period(p3)
len4_adapted = f_adaptive_period(p4)
len5_adapted = f_adaptive_period(p5)

v1 = f_ma(t1, close, len1_adapted)
v2 = f_ma(t2, close, len2_adapted)
v3 = f_ma(t3, close, len3_adapted)
v4 = f_ma(t4, close, len4_adapted)
v5 = f_ma(t5, close, len5_adapted)

// ─── PLOTS ─────────────────────────────────────────────────────────────────────
plot(s1 ? v1 : na, "MA 1", color=f_line_color(v1, c1_up, c1_down, c1_transp), linewidth=2)
plot(s2 ? v2 : na, "MA 2", color=f_line_color(v2, c2_up, c2_down, c2_transp), linewidth=2)
plot(s3 ? v3 : na, "MA 3", color=f_line_color(v3, c3_up, c3_down, c3_transp), linewidth=2)
plot(s4 ? v4 : na, "MA 4", color=f_line_color(v4, c4_up, c4_down, c4_transp), linewidth=2)
plot(s5 ? v5 : na, "MA 5", color=f_line_color(v5, c5_up, c5_down, c5_transp), linewidth=2)

// ─── FULLY AUTOMATIC NON-OVERLAPPING LABELS ────────────────────────────────────
// Automatic gap calculation based on font size and text
f_calculate_auto_gap(ma_count, price_range, font_size) =>
    // Base factors for font size
    float base_factor = 0.001  // Minimum base value
    
    switch font_size
        "Tiny"   => base_factor := 0.0005
        "Small"  => base_factor := 0.001
        "Normal" => base_factor := 0.002
        "Large"  => base_factor := 0.003
        "Huge"   => base_factor := 0.005
    
    // More MAs active means larger gap needed
    float count_factor = 1 + (ma_count / 20)
    
    // Final gap = price range * base factor * count factor
    price_range * base_factor * count_factor

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na

var float current_v1 = na
var float current_v2 = na
var float current_v3 = na
var float current_v4 = na
var float current_v5 = na
var int last_bar_index = -1

// Update current values
current_v1 := v1
current_v2 := v2
current_v3 := v3
current_v4 := v4
current_v5 := v5

// Recalculate labels when the last bar changes
if (barstate.islast or barstate.isrealtime) and (last_bar_index != bar_index)
    last_bar_index := bar_index
    
    if show_labels
        label_size_const = f_label_size(label_size)
        
        // Create arrays with (value, index) pairs
        values = array.new_float()
        indices = array.new_int()
        
        if s1 and not na(current_v1)
            array.push(values, current_v1)
            array.push(indices, 1)
        if s2 and not na(current_v2)
            array.push(values, current_v2)
            array.push(indices, 2)
        if s3 and not na(current_v3)
            array.push(values, current_v3)
            array.push(indices, 3)
        if s4 and not na(current_v4)
            array.push(values, current_v4)
            array.push(indices, 4)
        if s5 and not na(current_v5)
            array.push(values, current_v5)
            array.push(indices, 5)
        
        // Sort by value (from lowest to highest)
        int n = array.size(values)
        for i = 0 to n - 2
            for j = 0 to n - i - 2
                if array.get(values, j) > array.get(values, j + 1)
                    float temp_val = array.get(values, j)
                    array.set(values, j, array.get(values, j + 1))
                    array.set(values, j + 1, temp_val)
                    
                    int temp_idx = array.get(indices, j)
                    array.set(indices, j, array.get(indices, j + 1))
                    array.set(indices, j + 1, temp_idx)
        
        // Calculate average distance between MA values
        float total_distance = 0.0
        if n > 1
            for i = 1 to n - 1
                total_distance := total_distance + (array.get(values, i) - array.get(values, i - 1))
            float avg_distance = total_distance / (n - 1)
            
            // Calculate AUTO gap based on average distance between MAs
            float auto_gap = avg_distance
            
            // If MAs are too close (distance < 0.1% of price), use minimum gap
            float price_range = high - low
            if price_range <= 0
                price_range := 1
            float min_acceptable_gap = price_range * 0.0005  // 0.05% as absolute minimum
            
            if auto_gap < min_acceptable_gap
                auto_gap := min_acceptable_gap
            
            // Calculate Y positions with auto-calculated gap
            y_positions = array.new_float()
            array.push(y_positions, array.get(values, 0))
            
            for i = 1 to n - 1
                float prev_y = array.get(y_positions, i - 1)
                float curr_val = array.get(values, i)
                float min_allowed_y = prev_y + auto_gap
                
                if curr_val < min_allowed_y
                    array.push(y_positions, min_allowed_y)
                else
                    array.push(y_positions, curr_val)
            
            // Update labels
            for i = 0 to n - 1
                int idx = array.get(indices, i)
                float y_pos = array.get(y_positions, i)
                
                if idx == 1
                    label.delete(lbl1)
                    string txt = f_label_text(p1, len1_adapted, t1, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v1, c1_up, c1_down, label_bg_transp)
                    lbl1 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
                
                if idx == 2
                    label.delete(lbl2)
                    string txt = f_label_text(p2, len2_adapted, t2, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v2, c2_up, c2_down, label_bg_transp)
                    lbl2 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
                
                if idx == 3
                    label.delete(lbl3)
                    string txt = f_label_text(p3, len3_adapted, t3, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v3, c3_up, c3_down, label_bg_transp)
                    lbl3 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
                
                if idx == 4
                    label.delete(lbl4)
                    string txt = f_label_text(p4, len4_adapted, t4, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v4, c4_up, c4_down, label_bg_transp)
                    lbl4 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
                
                if idx == 5
                    label.delete(lbl5)
                    string txt = f_label_text(p5, len5_adapted, t5, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v5, c5_up, c5_down, label_bg_transp)
                    lbl5 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
        else
            // Case with only one MA or none
            if n == 1
                int idx = array.get(indices, 0)
                float y_pos = array.get(values, 0)
                if idx == 1
                    label.delete(lbl1)
                    string txt = f_label_text(p1, len1_adapted, t1, show_base_period, ref_trend_up)
                    color col = f_label_color(current_v1, c1_up, c1_down, label_bg_transp)
                    lbl1 := label.new(bar_index + label_offset, y_pos, text=txt, color=col, textcolor=label_txt_color, style=label.style_label_left, size=label_size_const)
    else
        // If show_labels is false, delete all labels
        label.delete(lbl1)
        label.delete(lbl2)
        label.delete(lbl3)
        label.delete(lbl4)
        label.delete(lbl5)
````

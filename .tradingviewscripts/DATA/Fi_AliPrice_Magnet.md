<!-- tradingview-pine-id: PUB;08042152e5494556a71f0f249b3dbae6 -->
<!-- tradingviewscripts-format: 1 -->
# Fi Ali_Price Magnet

Source: https://www.tradingview.com/script/w1g3z824-Fi-Ali-Price-Magnet/

## Description

Price Magnet Gap Driven

Fi Ali Smart Liquidity Gap is a clean and lightweight TradingView indicator designed to identify and visualize price gaps between the previous candle's Close and the current candle's Open across multiple higher timeframes.

The indicator helps traders quickly identify potential support and resistance zones created by market gaps without cluttering the chart with unnecessary signals.

Features
Detects gaps on:
H1
H4
Daily (D1)
Draws gap zones automatically using colored boxes.
Each timeframe uses a unique color for easy identification:
H1 – Cream
H4 – Blue
Daily – Gray
Historical gap zones remain visible for market structure analysis.
Optional box extension to the latest bar.
Lightweight and optimized for smooth performance.
Gap Logic

A gap is detected whenever the Open of the current higher timeframe candle differs from the Close of the previous higher timeframe candle.

The gap zone is drawn from the previous Close to the current Open, making it easy to identify areas where price may revisit or react.

Purpose

This indicator is built for traders who believe that higher timeframe opening gaps often act as important liquidity zones, support/resistance areas, or potential reaction levels.

It is especially useful when combined with price action, market structure, Wyckoff methodology, or order flow analysis.

Version: V1.0

---

## Source Code

````pine
//@version=6
indicator("Fi Ali_Price Magnet", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ========================================================================== //
// --- INPUTS ---
// ========================================================================== //
grp_tf = "Visibility & Timeframes"
show_h1 = input.bool(true, "Show H1 Gaps", group = grp_tf)
show_h4 = input.bool(true, "Show H4 Gaps", group = grp_tf)
show_d  = input.bool(true, "Show Daily Gaps", group = grp_tf)

grp_st = "Settings & Colors"
max_gaps      = input.int(50, "Max Gaps & Lines to Keep", minval = 1, maxval = 150, group = grp_st)
min_gap_ticks = input.int(0, "Minimum Gap Size (Ticks)", minval = 0, group = grp_st) 
extend_boxes  = input.bool(true, "Extend boxes to the right", group = grp_st)

show_border   = input.bool(true, "Show Box Border", group = grp_st)
show_midline  = input.bool(true, "Show Mid-Line (50%)", group = grp_st)
line_width    = input.int(2, "Gap Border Width", minval = 1, maxval = 5, group = grp_st)

color_h1 = input.color(color.new(#F5DEB3, 60), "H1 Color (Cream)", group = grp_st)
color_h4 = input.color(color.new(color.blue, 60), "H4 Color (Blue)", group = grp_st)
color_d  = input.color(color.new(color.gray, 60), "Daily Color (Gray)", group = grp_st)

grp_do = "Daily Open Line (FCPO)"
show_do     = input.bool(true, "Show Session Open Price", group = grp_do)
start_hr    = input.int(10, "Start Hour", minval = 0, maxval = 23, group = grp_do, inline = "start")
start_min   = input.int(30, "Minute", minval = 0, maxval = 59, group = grp_do, inline = "start")
end_hr      = input.int(23, "End Hour (Isnin-Khamis)", minval = 0, maxval = 23, group = grp_do, inline = "end")
end_min     = input.int(00, "Minute", minval = 0, maxval = 59, group = grp_do, inline = "end")
fri_end_hr  = input.int(18, "End Hour (Jumaat)", minval = 0, maxval = 23, group = grp_do, inline = "fri")
fri_end_min = input.int(00, "Minute", minval = 0, maxval = 59, group = grp_do, inline = "fri")
do_tz       = input.string("Asia/Kuala_Lumpur", "Timezone", group = grp_do)
color_do    = input.color(color.new(color.yellow, 0), "Line Color", group = grp_do)
style_do_in = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = grp_do)
do_width    = input.int(3, "Line Thickness (px)", minval = 1, maxval = 10, group = grp_do)

grp_bias = "Today's Bias Panel"
show_bias = input.bool(true, "Show Bias Panel", group = grp_bias)

f_get_line_style(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

// ========================================================================== //
// --- ARRAYS & VARIABLES ---
// ========================================================================== //
var box[] h1_boxes = array.new<box>()
var box[] h4_boxes = array.new<box>()
var box[] d_boxes  = array.new<box>()

var line[] h1_lines = array.new<line>()
var line[] h4_lines = array.new<line>()
var line[] d_lines  = array.new<line>()

var line[] do_lines = array.new<line>() 
var line cur_do_line = na 

// Pembolehubah khas untuk memori "Today's Bias"
var float prev_day_open = na
var float today_open = na

// ========================================================================== //
// --- FUNCTIONS (GAPS) ---
// ========================================================================== //
f_process_gaps(bool is_new, float o1, float c1, int t1, float o2, float c2, bool show, color box_color, array<box> box_array, array<line> line_array, int min_ticks, int limit_gaps, int l_width) =>
    if show and is_new
        float gap_size = math.abs(o1 - c2)
        if gap_size >= (min_ticks * syminfo.mintick)
            bool c1_bull = c2 > o2 
            bool c1_bear = c2 < o2 
            bool invalid_gap = false
            
            if c1_bull and (c1 < c2)
                invalid_gap := true
            if c1_bear and (c1 > c2)
                invalid_gap := true
                
            if not invalid_gap
                float top = math.max(o1, c2)
                float bot = math.min(o1, c2)
                float mid = (top + bot) / 2
                
                string ext = extend_boxes ? extend.right : extend.none
                color border_col = show_border ? color.new(box_color, 0) : na
                
                box b = box.new(left = t1, top = top, right = time, bottom = bot, xloc = xloc.bar_time, border_color = border_col, border_width = l_width, bgcolor = box_color, extend = ext)
                array.push(box_array, b)
                if array.size(box_array) > limit_gaps
                    box.delete(array.shift(box_array))
                
                if show_midline
                    line l = line.new(x1 = t1, y1 = mid, x2 = time, y2 = mid, xloc = xloc.bar_time, color = border_col, style = line.style_dashed, width = l_width, extend = ext)
                    array.push(line_array, l)
                    if array.size(line_array) > limit_gaps
                        line.delete(array.shift(line_array))

// ========================================================================== //
// --- DATA FETCHING (GAPS) ---
// ========================================================================== //
[h1_o1, h1_c1, h1_t1, h1_o2, h1_c2] = request.security(syminfo.tickerid, "60",  [open[1], close[1], time[1], open[2], close[2]], barmerge.gaps_off, barmerge.lookahead_on)
[h4_o1, h4_c1, h4_t1, h4_o2, h4_c2] = request.security(syminfo.tickerid, "240", [open[1], close[1], time[1], open[2], close[2]], barmerge.gaps_off, barmerge.lookahead_on)
[d_o1,  d_c1,  d_t1,  d_o2,  d_c2]  = request.security(syminfo.tickerid, "D",   [open[1], close[1], time[1], open[2], close[2]], barmerge.gaps_off, barmerge.lookahead_on)

bool new_h1 = ta.change(time("60")) != 0
bool new_h4 = ta.change(time("240")) != 0
bool new_d  = ta.change(time("D")) != 0

f_process_gaps(new_h1, h1_o1, h1_c1, h1_t1, h1_o2, h1_c2, show_h1, color_h1, h1_boxes, h1_lines, min_gap_ticks, max_gaps, line_width)
f_process_gaps(new_h4, h4_o1, h4_c1, h4_t1, h4_o2, h4_c2, show_h4, color_h4, h4_boxes, h4_lines, min_gap_ticks, max_gaps, line_width)
f_process_gaps(new_d,  d_o1,  d_c1,  d_t1,  d_o2,  d_c2,  show_d,  color_d,  d_boxes,  d_lines,  min_gap_ticks, max_gaps, line_width)

// ========================================================================== //
// --- LOGIK FCPO DAILY OPEN & TRACKER ---
// ========================================================================== //
int cur_mins   = hour(time, do_tz) * 60 + minute(time, do_tz)
int start_mins = start_hr * 60 + start_min

int current_dow = dayofweek(time, do_tz)
bool is_friday  = (current_dow == dayofweek.friday)

int active_end_hr  = is_friday ? fri_end_hr : end_hr
int active_end_min = is_friday ? fri_end_min : end_min
int end_mins       = active_end_hr * 60 + active_end_min

bool is_in_session = (cur_mins >= start_mins) and (cur_mins <= end_mins)

int current_cal_day = dayofmonth(time, do_tz)
bool is_new_cal_day = na(current_cal_day[1]) or (current_cal_day != current_cal_day[1])

// Trigger tepat pada candle pertama 10:30 pagi
bool is_session_start = is_in_session and (is_new_cal_day or not is_in_session[1])

if is_session_start
    // Memori Bias: Kunci harga semalam sebelum timpa harga harini
    prev_day_open := today_open
    today_open := open

    if show_do
        cur_do_line := line.new(
          x1 = time, 
          y1 = open, 
          x2 = time, 
          y2 = open, 
          xloc = xloc.bar_time, 
          color = color_do, 
          style = f_get_line_style(style_do_in), 
          width = do_width
          )
        array.push(do_lines, cur_do_line)
        
        if array.size(do_lines) > max_gaps
            line.delete(array.shift(do_lines))
            
else if is_in_session and show_do
    if not na(cur_do_line)
        line.set_x2(cur_do_line, time)

// ========================================================================== //
// --- UI: TODAY'S BIAS PANEL ---
// ========================================================================== //
var table bias_tbl = table.new(position.top_right, 1, 2, bgcolor = color.new(color.black, 70), border_color = color.new(color.gray, 50), border_width = 1)

if show_bias and barstate.islast
    string txt_bias = "WAITING..."
    color col_bias  = color.gray
    
    // Bandingkan open harini dengan open kelmarin (10:30 pagi)
    if not na(today_open) and not na(prev_day_open)
        if today_open > prev_day_open
            txt_bias := "BULLISH ⬆"
            col_bias := color.new(#26a69a, 20) // Hijau sejuk
        else if today_open < prev_day_open
            txt_bias := "BEARISH ⬇"
            col_bias := color.new(#ef5350, 20) // Merah pudar
        else
            txt_bias := "NEUTRAL ➖"
            col_bias := color.new(color.gray, 20)
            
    // Header
    table.cell(bias_tbl, 0, 0, "TODAY'S BIAS", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 40))
    // Data Bias
    table.cell(bias_tbl, 0, 1, txt_bias, text_color = color.white, text_size = size.normal, bgcolor = col_bias)
````

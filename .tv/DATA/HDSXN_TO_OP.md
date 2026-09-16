<!-- tradingview-pine-id: PUB;e4328694be9e441a9ad130eb2a8a5539 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HDSXN | TO · OP

Source: https://www.tradingview.com/script/9lGPRB9u/

## Description

This script is a comprehensive indicator designed for **ICT (Inner Circle Trader)** and **Smart Money Concepts (SMC)** traders. Its primary focus is on automatically identifying, drawing, and tracking **Opening Prices (OP)** and algorithmic **True Opens (TO)** across various timeframes and specific macro windows.

Here is a detailed breakdown of what this indicator does and its main features:

**1. Custom Opening Prices (Time Slots)**
The first module allows you to highlight specific intraday opening times.

* **Customizable Time Slots:** It features 4 independent slots where you can define a start and end time (e.g., 08:30 AM for the critical economic news open, or 09:30 AM for the NY Equities open).
* **Line Projection:** It grabs the exact opening price at that minute and projects a horizontal line across your chart until the designated end time, acting as a crucial intraday level (support/resistance or accumulation/manipulation reference).

**2. True Open (TO) Module**
Standard charts often plot the "Daily" or "Weekly" open at midnight based on the broker's timezone. This module recalculates the **"True Open"** based on real market mechanics (like the Sunday 6:00 PM EST futures open) and ICT algorithmic cycles:

* **Macro Timeframes:** Plots the True Year, True Quarter, True Month, True Week, and True Day opens using specific algorithmic rules (e.g., calculating the monthly open based on the 2nd Sunday of the month at 6:00 PM EST).
* **Session Opens (Killzones):** Automatically plots the opening prices for key trading sessions: Asia (19:30), London (01:30), NY AM (07:30), and NY PM (13:30).
* **90-Minute Cycles:** It tracks and plots the highly specific ICT 90-minute algorithmic cycles, triggering at precise macro minutes (e.g., xx:23 and xx:53).

**3. Advanced Chart Management (Visibility & History)**
To prevent the chart from becoming cluttered with dozens of lines, the script includes smart visibility rules:

* **Timeframe Boundaries:** You can set rules so that Yearly and Monthly opens only show on higher timeframes (like the 4H or Daily), while Session and 90-minute opens only appear on the 1m to 15m charts.
* **History Control:** You can choose exactly how many past "True Opens" to keep on the screen (e.g., keeping only the current active day's open, or saving the last 3 days for backtesting).
* **Auto-Styling:** Lines can automatically change from a dotted style (when the period is active) to a solid style (when the period has ended and becomes historical data).

**4. Real-Time Price Tracking Dashboard (Table)**
It features a built-in HUD (Heads-Up Display) table that sits in the corner of your screen.

* This table dynamically tracks the current price in relation to the True Opens.
* It tells you instantly if the current price is **"Above"** (highlighted in blue) or **"Below"** (highlighted in red) the Daily, Weekly, Monthly, Session, or 90-minute open. This is extremely useful for quickly determining if you are in a Premium (above the open) or Discount (below the open) condition for the day or week.

**In summary:** It is an all-in-one institutional time and price tracker. Instead of manually drawing horizontal lines at 8:30 AM or midnight EST every single day, this script automates the process and provides a dashboard to tell you exactly where the current price sits relative to these key algorithmic opening prices.

---

## Source Code

````pine
// © HDSXN
//@version=6
indicator("HDSXN | TO · OP", shorttitle="HDSXN [TO·OP]", overlay=true,
          max_boxes_count=500, max_labels_count=500, max_lines_count=500,
          max_bars_back=5000, dynamic_requests=true)

// =============================================================================
// OPENING PRICES
// =============================================================================

qt_grp_global = "Opening Prices Styling 🎨"
qt_grp_slots  = "Opening Prices Slots ⏰"

qt_i_max_keep  = input.int(1,     "Max History", minval=1, maxval=50, group=qt_grp_global, inline="g1", tooltip="How many past lines to keep per slot.")
qt_i_unlimited = input.bool(false, "∞ Keep All", group=qt_grp_global, inline="g1")

qt_i_l_style   = input.string("Dotted", "Style", options=["Solid", "Dotted", "Dashed"], group=qt_grp_global, inline="g2")
int qt_i_l_width = 1
qt_i_t_size    = input.string("Small", "Text", options=["Tiny", "Small", "Normal", "Large"], group=qt_grp_global, inline="g2")
qt_i_offset    = input.int(0, "Offset", group=qt_grp_global, inline="g2")

qt_i_mono      = input.bool(false, "Monospace", group=qt_grp_global)

var qt_slot_line_style = qt_i_l_style == "Dotted" ? line.style_dotted : qt_i_l_style == "Dashed" ? line.style_dashed : line.style_solid
var qt_text_size       = qt_i_t_size  == "Tiny"   ? size.tiny  : qt_i_t_size == "Small" ? size.small : qt_i_t_size == "Large" ? size.large : size.normal
qt_font_fam = qt_i_mono ? font.family_monospace : font.family_default

// Slot 1
qt_s1_on    = input.bool(false,   "", inline="s1", group=qt_grp_slots)
qt_s1_name  = input.string("8:30", "", inline="s1", group=qt_grp_slots, tooltip="Label Name")
qt_s1_start = input.string("08:30", "to", inline="s1", group=qt_grp_slots, tooltip="Start Time (EST)")
qt_s1_end   = input.string("10:00", "", inline="s1", group=qt_grp_slots, tooltip="End Time (EST)")
qt_s1_col   = input.color(color.new(color.gray, 0), "", inline="s1", group=qt_grp_slots)

// Slot 2
qt_s2_on    = input.bool(true,    "", inline="s2", group=qt_grp_slots)
qt_s2_name  = input.string("9:30", "", inline="s2", group=qt_grp_slots)
qt_s2_start = input.string("09:30", "to", inline="s2", group=qt_grp_slots)
qt_s2_end   = input.string("11:59", "", inline="s2", group=qt_grp_slots)
qt_s2_col   = input.color(color.new(color.gray, 0), "", inline="s2", group=qt_grp_slots)

// Slot 3
qt_s3_on    = input.bool(false,       "", inline="s3", group=qt_grp_slots)
qt_s3_name  = input.string("Slot3",   "", inline="s3", group=qt_grp_slots)
qt_s3_start = input.string("07:30", "to", inline="s3", group=qt_grp_slots)
qt_s3_end   = input.string("11:59",   "", inline="s3", group=qt_grp_slots)
qt_s3_col   = input.color(color.new(color.gray, 0), "", inline="s3", group=qt_grp_slots)

// Slot 4
qt_s4_on    = input.bool(false,       "", inline="s4", group=qt_grp_slots)
qt_s4_name  = input.string("Slot4",   "", inline="s4", group=qt_grp_slots)
qt_s4_start = input.string("10:00", "to", inline="s4", group=qt_grp_slots)
qt_s4_end   = input.string("11:00",   "", inline="s4", group=qt_grp_slots)
qt_s4_col   = input.color(color.new(color.gray, 0), "", inline="s4", group=qt_grp_slots)

var qt_a_lines_1 = array.new<line>(), var qt_a_lbls_1 = array.new<label>()
var qt_a_lines_2 = array.new<line>(), var qt_a_lbls_2 = array.new<label>()
var qt_a_lines_3 = array.new<line>(), var qt_a_lbls_3 = array.new<label>()
var qt_a_lines_4 = array.new<line>(), var qt_a_lbls_4 = array.new<label>()

qt_clean_time(t) =>
    s = str.replace_all(t, ":", "")
    str.length(s) == 3 ? "0" + s : s

qt_is_timeframe_valid(start_time_str) =>
    int current_seconds = timeframe.in_seconds(timeframe.period)
    bool valid_tf = current_seconds <= 3600
    string mins = str.substring(qt_clean_time(start_time_str), 2, 4)
    if current_seconds == 3600 and mins != "00"
        valid_tf := false
    valid_tf

qt_process_slot(bool enable, string name, string t_start, string t_end, color col, array<line> line_arr, array<label> lbl_arr) =>
    if enable and qt_is_timeframe_valid(t_start)
        string sess_str = qt_clean_time(t_start) + "-" + qt_clean_time(t_end)
        bool in_session = not na(time(timeframe.period, sess_str + ":1234567", "America/New_York"))
        bool is_start   = in_session and not in_session[1]

        if is_start
            line new_line = line.new(bar_index, open, bar_index, open, color=col, width=qt_i_l_width, style=qt_slot_line_style)
            array.push(line_arr, new_line)
            label new_lbl = label.new(bar_index, open, text=name, color=color.new(color.white, 100), style=label.style_label_left, textcolor=col, size=qt_text_size, text_font_family=qt_font_fam)
            array.push(lbl_arr, new_lbl)
            if not qt_i_unlimited and array.size(line_arr) > qt_i_max_keep
                line.delete(array.shift(line_arr))
                label.delete(array.shift(lbl_arr))

        if in_session and array.size(line_arr) > 0
            line  curr_line = array.get(line_arr, array.size(line_arr) - 1)
            label curr_lbl  = array.get(lbl_arr,  array.size(lbl_arr)  - 1)
            line.set_x2(curr_line, bar_index)
            label.set_x(curr_lbl, bar_index + qt_i_offset)

qt_process_slot(qt_s1_on, qt_s1_name, qt_s1_start, qt_s1_end, qt_s1_col, qt_a_lines_1, qt_a_lbls_1)
qt_process_slot(qt_s2_on, qt_s2_name, qt_s2_start, qt_s2_end, qt_s2_col, qt_a_lines_2, qt_a_lbls_2)
qt_process_slot(qt_s3_on, qt_s3_name, qt_s3_start, qt_s3_end, qt_s3_col, qt_a_lines_3, qt_a_lbls_3)
qt_process_slot(qt_s4_on, qt_s4_name, qt_s4_start, qt_s4_end, qt_s4_col, qt_a_lines_4, qt_a_lbls_4)

// =============================================================================
// TRUE OPEN MODULE
// =============================================================================

int to_triggerHour = 18

to_grp_main = "TRUE OPENS SETTINGS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
to_offset_val         = input.int(10,       "Label Offset (Bars)", minval=0, maxval=100, group=to_grp_main)
to_textSize           = input.string(size.small, "Text Size", options=[size.tiny, size.small, size.normal, size.large], group=to_grp_main)
to_use_mono           = input.bool(false,   "Use Monospace Text", group=to_grp_main)
to_style_mode         = input.string("Auto","Line Style Mode", options=["Auto", "Custom"], group=to_grp_main, inline="style", tooltip="Auto: Active=Dotted, History=Solid.")
to_custom_style       = input.string("Solid","Style", options=["Solid", "Dashed", "Dotted"], group=to_grp_main, inline="style")

to_grp_hist = "True Open History Filters"
to_hist_count_global = input.int(1, "Global History Count", minval=1, group=to_grp_hist)
to_hist_yr   = input.bool(false, "Year",    group=to_grp_hist, inline="h1")
to_hist_qt   = input.bool(false, "Quarter", group=to_grp_hist, inline="h1")
to_hist_mn   = input.bool(false, "Month",   group=to_grp_hist, inline="h1")
to_hist_wk   = input.bool(false, "Week",    group=to_grp_hist, inline="h2")
to_hist_dy   = input.bool(false, "Day",     group=to_grp_hist, inline="h2")
to_hist_sess = input.bool(false, "Session", group=to_grp_hist, inline="h3")
to_hist_90m  = input.bool(false, "90m",     group=to_grp_hist, inline="h3")

to_font_fam = to_use_mono ? font.family_monospace : font.family_default

int to_t_asia_h = 19, int to_t_asia_m = 30
int to_t_lon_h  = 1,  int to_t_lon_m  = 30
int to_t_nyam_h = 7,  int to_t_nyam_m = 30
int to_t_nypm_h = 13, int to_t_nypm_m = 30

to_grp_vis = "True Open Visibility"
to_show_yr_open   = input.bool(true, "Show True Year Opens",    group=to_grp_vis)
to_show_qt_open   = input.bool(true, "Show True Quarter Opens", group=to_grp_vis)
to_show_mn_open   = input.bool(true, "Show True Month Opens",   group=to_grp_vis)
to_show_wk_open   = input.bool(true, "Show True Week Opens",    group=to_grp_vis)
to_show_dy_open   = input.bool(true, "Show True Day Opens",     group=to_grp_vis)
to_show_sess_open = input.bool(true, "Show True Session Opens", group=to_grp_vis)
to_show_90m_open  = input.bool(true, "Show True 90-Min Opens",  group=to_grp_vis)

to_grp_rng = "True Open Custom TF Ranges"
to_nm_min   = input.timeframe("1",   "90-Min Boundaries",    group=to_grp_rng, inline="rng_nm")
to_nm_max   = input.timeframe("3",   "To",                   group=to_grp_rng, inline="rng_nm")
to_sess_min = input.timeframe("1",   "Session Boundaries",   group=to_grp_rng, inline="rng_sess")
to_sess_max = input.timeframe("45",  "To",                   group=to_grp_rng, inline="rng_sess")
to_dy_min   = input.timeframe("1",   "Daily Boundaries",     group=to_grp_rng, inline="rng_dy")
to_dy_max   = input.timeframe("60",  "To",                   group=to_grp_rng, inline="rng_dy")
to_wk_min   = input.timeframe("15",  "Weekly Boundaries",    group=to_grp_rng, inline="rng_wk")
to_wk_max   = input.timeframe("60",  "To",                   group=to_grp_rng, inline="rng_wk")
to_mn_min   = input.timeframe("60",  "Monthly Boundaries",   group=to_grp_rng, inline="rng_mn")
to_mn_max   = input.timeframe("240", "To",                   group=to_grp_rng, inline="rng_mn")
to_qt_min   = input.timeframe("240", "Quarterly Boundaries", group=to_grp_rng, inline="rng_qt")
to_qt_max   = input.timeframe("W",   "To",                   group=to_grp_rng, inline="rng_qt")
to_yr_min   = input.timeframe("240", "Yearly Boundaries",    group=to_grp_rng, inline="rng_yr")
to_yr_max   = input.timeframe("M",   "To",                   group=to_grp_rng, inline="rng_yr")

to_grp_style = "True Open Styling & Labels"
to_c_yr  = input.color(color.new(#ff5252, 35), "Year TO",     group=to_grp_style, inline="sty_yr")
to_n_yr  = input.string("TYO", "",                             group=to_grp_style, inline="sty_yr")
to_c_qt  = input.color(color.new(#ff0066, 36), "Quarter TO",  group=to_grp_style, inline="sty_qt")
to_n_qt  = input.string("TQO", "",                             group=to_grp_style, inline="sty_qt")
to_c_mn  = input.color(color.new(#545754,  0), "Month TO",    group=to_grp_style, inline="sty_mn")
to_n_mn  = input.string("TMO", "",                             group=to_grp_style, inline="sty_mn")
to_c_wk  = input.color(color.new(#2195f3, 41), "Week TO",     group=to_grp_style, inline="sty_wk")
to_n_wk  = input.string("TWO", "",                             group=to_grp_style, inline="sty_wk")
to_c_dy  = input.color(color.new(#403f37, 34), "Daily TO",    group=to_grp_style, inline="sty_dy")
to_n_dy  = input.string("TDO", "",                             group=to_grp_style, inline="sty_dy")
to_c_90m = input.color(color.new(#00bbd4, 34), "90-Min TO",   group=to_grp_style, inline="sty_90")
to_c_sess        = input.color(color.new(#9b27b0, 36), "Session TO Color", group=to_grp_style)
to_sess_lbl_mode = input.string("Time", "Session Label Mode", options=["Name", "Time"], group=to_grp_style)

to_grp_tbl = "True Open Price Tracking Table"
to_show_table     = input.bool(true, "Show Price Tracking Table", group=to_grp_tbl)
to_table_pos      = input.string(position.bottom_right, "Table Position", options=[position.top_right, position.middle_right, position.bottom_right, position.top_left, position.middle_left, position.bottom_left], group=to_grp_tbl)
to_table_txt_size = input.string(size.small, "Table Text Size", options=[size.tiny, size.small, size.normal, size.large], group=to_grp_tbl)
to_tbl_show_90m   = input.bool(true,  "Show 90-Min",    group=to_grp_tbl, inline="tbl_rows")
to_tbl_show_sess  = input.bool(true,  "Show Session",   group=to_grp_tbl, inline="tbl_rows")
to_tbl_show_dy    = input.bool(true,  "Show Daily",     group=to_grp_tbl, inline="tbl_rows")
to_tbl_show_wk    = input.bool(true,  "Show Weekly",    group=to_grp_tbl, inline="tbl_rows")
to_tbl_show_mn    = input.bool(true,  "Show Monthly",   group=to_grp_tbl, inline="tbl_rows")
to_tbl_show_qt    = input.bool(false, "Show Quarterly", group=to_grp_tbl, inline="tbl_rows2")
to_tbl_show_yr    = input.bool(false, "Show Yearly",    group=to_grp_tbl, inline="tbl_rows2")
to_c_tbl_above    = input.color(color.new(#1090f9, 36), "Above",    group=to_grp_tbl, inline="tbl_cols")
to_c_tbl_below    = input.color(color.new(#c8452b, 33), "Below",    group=to_grp_tbl, inline="tbl_cols")
to_c_tbl_none     = input.color(color.new(color.gray, 0), "Not Open", group=to_grp_tbl, inline="tbl_cols")

// --- Type & Helper Functions ---
type TO_Level
    line   l
    label  lbl
    float  price
    bool   active
    string name
    color  c
    int    start_t
    int    end_t

to_tf_to_min(string tf) =>
    timeframe.in_seconds(tf) / 60.0

to_is_visible(string min_s, string max_s) =>
    float current_min = timeframe.multiplier
    if timeframe.isseconds
        current_min := current_min / 60.0
    if timeframe.isdaily
        current_min := 1440.0
    if timeframe.isweekly
        current_min := 10080.0
    if timeframe.ismonthly
        current_min := 43200.0
    float min_val = to_tf_to_min(min_s)
    float max_val = to_tf_to_min(max_s)
    current_min >= min_val and current_min <= max_val

to_get_style_const(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

to_get_active_style() =>
    if to_style_mode == "Auto"
        line.style_dotted
    else
        to_get_style_const(to_custom_style)

to_get_sess_end(int start_time) =>
    string tz = "America/New_York"
    int h = hour(start_time, tz)
    int y = year(start_time, tz)
    int m = month(start_time, tz)
    int d = dayofmonth(start_time, tz)
    int end_h = 0
    if h >= 18
        end_h := 0
    else if h >= 12
        end_h := 18
    else if h >= 6
        end_h := 12
    else
        end_h := 6
    int target = 0
    if h >= 18
        int today_zero = timestamp(tz, y, m, d, 0, 0)
        target := today_zero + 86400000
    else
        target := timestamp(tz, y, m, d, end_h, 0)
    target

to_enforce_limit(array<TO_Level> arr, bool allow_hist) =>
    bool has_active = array.size(arr) > 0 and array.get(arr, array.size(arr)-1).active
    int hist_limit  = allow_hist ? to_hist_count_global : 0
    int total_limit = hist_limit + (has_active ? 1 : 0)
    while array.size(arr) > total_limit
        oldObj = array.shift(arr)
        line.delete(oldObj.l)
        label.delete(oldObj.lbl)

to_force_close_period(array<TO_Level> arr, bool allow_hist) =>
    if array.size(arr) > 0
        lastObj = array.get(arr, array.size(arr) - 1)
        if lastObj.active
            lastObj.active := false
            line.set_x2(lastObj.l, time)
            label.set_x(lastObj.lbl, time)
            if to_style_mode == "Auto"
                line.set_style(lastObj.l, line.style_solid)
            label.delete(lastObj.lbl)
            to_enforce_limit(arr, allow_hist)

to_manage_history(array<TO_Level> arr, float p, int start_time, string txt, color col, bool allow_hist, bool use_hard_end, int custom_end) =>
    if array.size(arr) > 0
        prevObj = array.get(arr, array.size(arr) - 1)
        if prevObj.active
            prevObj.active := false
            int cut_time = start_time
            if prevObj.end_t != 0 and prevObj.end_t < start_time
                cut_time := prevObj.end_t
            line.set_x2(prevObj.l, cut_time)
            label.set_x(prevObj.lbl, cut_time)
            if to_style_mode == "Auto"
                line.set_style(prevObj.l, line.style_solid)
            label.delete(prevObj.lbl)

    l_new  = line.new(x1=start_time, y1=p, x2=start_time, y2=p, xloc=xloc.bar_time, width=1, style=to_get_active_style(), color=col)
    lb_new = label.new(x=start_time, y=p, xloc=xloc.bar_time, text="", style=label.style_label_left, color=color(na), textcolor=col, text_font_family=to_font_fam, size=to_textSize)

    int final_end = 0
    if custom_end > 0
        final_end := custom_end
    else if use_hard_end
        final_end := to_get_sess_end(start_time)

    newObj = TO_Level.new(l_new, lb_new, p, true, txt, col, start_time, final_end)
    array.push(arr, newObj)
    to_enforce_limit(arr, allow_hist)

to_maintain_lines(array<TO_Level> arr, bool is_vis, bool is_time_label_mode, bool allow_hist) =>
    if array.size(arr) > 0
        int tf_ms   = int(timeframe.in_seconds(timeframe.period) * 1000)
        int future_t = time + (to_offset_val * tf_ms)
        for i = 0 to array.size(arr) - 1
            obj = array.get(arr, i)
            if obj.active
                int target_x = future_t
                if obj.end_t != 0 and future_t > obj.end_t
                    target_x := obj.end_t
                line.set_x2(obj.l, target_x)
                label.set_x(obj.lbl, target_x)
            bool show_line = is_vis
            if not allow_hist and not obj.active
                show_line := false
            color final_c = show_line ? obj.c : color.new(color.white, 100)
            line.set_color(obj.l, final_c)
            label.set_textcolor(obj.lbl, show_line ? obj.c : color.new(color.white, 100))
            string final_txt = obj.name
            if is_time_label_mode
                if to_sess_lbl_mode == "Time" or obj.name == "90m"
                    final_txt := str.format_time(obj.start_t, "HH:mm", "America/New_York")
            label.set_text(obj.lbl, final_txt)

// --- Calculation Functions ---
to_calc_yr_func() =>
    int m = month(time)
    var float p = na
    var int trig_t = 0
    bool new_yr = false
    if m == 4 and m[1] != 4
        p := open
        new_yr := true
        trig_t := time
    [p, new_yr, trig_t]

to_get_4th_sunday_timestamp(int y, int m) =>
    int d = 1
    int first_sunday_day = 0
    for i = 0 to 6
        int ts_check = timestamp(y, m, d + i, 0, 0)
        if dayofweek(ts_check) == dayofweek.sunday
            first_sunday_day := d + i
            break
    int fourth_sunday_day = first_sunday_day + 21
    timestamp(y, m, fourth_sunday_day, 0, 0)

to_calc_qt_func() =>
    int m = month(time)
    int y = year(time)
    int q_start_m = m <= 3 ? 1 : m <= 6 ? 4 : m <= 9 ? 7 : 10
    int target_time = to_get_4th_sunday_timestamp(y, q_start_m)
    var float p = na
    var int last_t = 0
    var int trig_t = 0
    bool new_qt = false
    if time >= target_time and last_t != target_time
        p := open
        last_t := target_time
        new_qt := true
        trig_t := time
    [p, new_qt, trig_t]

to_calc_mn_func(int t_hour) =>
    string tz = "America/New_York"
    int d   = dayofmonth(time, tz)
    int dow = dayofweek(time, tz)
    int h   = hour(time, tz)
    bool is_sec_wk  = d >= 7 and d <= 13
    bool is_sun     = dow == dayofweek.sunday
    bool time_trig  = h == t_hour or (h > t_hour and h[1] < t_hour)
    var float p = na
    var int trig_t = 0
    bool new_mn = false
    var int last_m = -1
    int cur_m = month(time, tz)
    if is_sec_wk and is_sun and time_trig and cur_m != last_m
        p := open
        new_mn := true
        last_m := cur_m
        trig_t := time
    [p, new_mn, trig_t]

to_calc_wk_func(int t_hour) =>
    string tz  = "America/New_York"
    int dow    = dayofweek(time, tz)
    int h      = hour(time, tz)
    int min    = minute(time, tz)
    bool is_mon    = dow == dayofweek.monday
    bool time_trig = h == t_hour and min == 0
    var float p = na
    var int trig_t = 0
    bool new_wk = false
    var int last_time = 0
    if is_mon and time_trig and time != last_time
        p := open
        new_wk := true
        last_time := time
        trig_t := time
    [p, new_wk, trig_t]

to_calc_dy_func() =>
    string tz = "America/New_York"
    int h   = hour(time, tz)
    int d   = dayofmonth(time, tz)
    int min = minute(time, tz)
    var float p = na
    var int trig_t = 0
    bool new_dy = false
    var int last_d = -1
    if d != last_d and h == 0 and min == 0
        p := open
        new_dy := true
        last_d := d
        trig_t := time
    [p, new_dy, trig_t]

to_calc_session_func(int t_h, int t_m) =>
    string tz = "America/New_York"
    int h   = hour(time, tz)
    int min = minute(time, tz)
    bool time_trig = (h == t_h and min == t_m)
    var float p = na
    var int trig_t = 0
    bool new_sess = false
    var int last_trigger_time = 0
    if time_trig and time != last_trigger_time
        p := open
        new_sess := true
        trig_t := time
        last_trigger_time := time
    [p, new_sess, trig_t]

to_calc_90m_func() =>
    string tz  = "America/New_York"
    int h      = hour(time, tz)
    int min    = minute(time, tz)
    int y      = year(time, tz)
    int m      = month(time, tz)
    int d      = dayofmonth(time, tz)
    bool is_cycle_a = (h % 3 == 0) and (min == 23)
    bool is_cycle_b = (h % 3 == 1) and (min == 53)
    bool time_trig  = is_cycle_a or is_cycle_b
    var float p = na
    var int trig_t = 0
    var int strict_end_t = 0
    bool new_90 = false
    var int last_trigger_time = 0
    if time_trig and time != last_trigger_time
        p := open
        new_90 := true
        trig_t := time
        last_trigger_time := time
        if is_cycle_a
            strict_end_t := timestamp(tz, y, m, d, h+1, 30, 0)
        if is_cycle_b
            strict_end_t := timestamp(tz, y, m, d, h+2, 0, 0)
    [p, new_90, trig_t, strict_end_t]

// --- Data Fetching ---
[to_yr_p,   to_yr_new,   to_yr_t]   = request.security(syminfo.tickerid, "W",   to_calc_yr_func(),                lookahead=barmerge.lookahead_on)
[to_qt_p,   to_qt_new,   to_qt_t]   = request.security(syminfo.tickerid, "D",   to_calc_qt_func(),                lookahead=barmerge.lookahead_on)
[to_mn_p,   to_mn_new,   to_mn_t]   = request.security(syminfo.tickerid, "240", to_calc_mn_func(to_triggerHour),  lookahead=barmerge.lookahead_on)
[to_wk_p,   to_wk_new,   to_wk_t]   = request.security(syminfo.tickerid, "60",  to_calc_wk_func(to_triggerHour),  lookahead=barmerge.lookahead_on)
[to_dy_p,   to_dy_new,   to_dy_t]   = request.security(syminfo.tickerid, "1",   to_calc_dy_func(),                lookahead=barmerge.lookahead_on)
[to_asia_p, to_asia_new, to_asia_t] = request.security(syminfo.tickerid, "1",   to_calc_session_func(to_t_asia_h, to_t_asia_m), lookahead=barmerge.lookahead_on)
[to_lon_p,  to_lon_new,  to_lon_t]  = request.security(syminfo.tickerid, "1",   to_calc_session_func(to_t_lon_h,  to_t_lon_m),  lookahead=barmerge.lookahead_on)
[to_nyam_p, to_nyam_new, to_nyam_t] = request.security(syminfo.tickerid, "1",   to_calc_session_func(to_t_nyam_h, to_t_nyam_m), lookahead=barmerge.lookahead_on)
[to_nypm_p, to_nypm_new, to_nypm_t] = request.security(syminfo.tickerid, "1",   to_calc_session_func(to_t_nypm_h, to_t_nypm_m), lookahead=barmerge.lookahead_on)
[to_nm_p,   to_nm_new,   to_nm_t, to_nm_end_t] = request.security(syminfo.tickerid, "1", to_calc_90m_func(),     lookahead=barmerge.lookahead_on)

// --- Drawing & Execution ---
var array<TO_Level> to_arr_yr   = array.new<TO_Level>()
var array<TO_Level> to_arr_qt   = array.new<TO_Level>()
var array<TO_Level> to_arr_mn   = array.new<TO_Level>()
var array<TO_Level> to_arr_wk   = array.new<TO_Level>()
var array<TO_Level> to_arr_dy   = array.new<TO_Level>()
var array<TO_Level> to_arr_sess = array.new<TO_Level>()
var array<TO_Level> to_arr_90m  = array.new<TO_Level>()

var int to_last_yr_t   = 0
var int to_last_qt_t   = 0
var int to_last_mn_t   = 0
var int to_last_wk_t   = 0
var int to_last_dy_t   = 0
var int to_last_asia_t = 0
var int to_last_lon_t  = 0
var int to_last_nyam_t = 0
var int to_last_nypm_t = 0
var int to_last_nm_t   = 0

bool to_chg_yr = timeframe.change("12M")
bool to_chg_qt = timeframe.change("3M")
bool to_chg_mn = timeframe.change("1M")
bool to_chg_wk = timeframe.change("1W")

if to_chg_yr
    to_force_close_period(to_arr_yr, to_hist_yr)
if to_chg_qt
    to_force_close_period(to_arr_qt, to_hist_qt)
if to_chg_mn
    to_force_close_period(to_arr_mn, to_hist_mn)
if to_chg_wk
    to_force_close_period(to_arr_wk, to_hist_wk)

if to_show_yr_open and not na(to_yr_p) and to_yr_t != to_last_yr_t
    to_manage_history(to_arr_yr, to_yr_p, to_yr_t, to_n_yr, to_c_yr, to_hist_yr, false, 0)
    to_last_yr_t := to_yr_t

if to_show_qt_open and not na(to_qt_p) and to_qt_t != to_last_qt_t
    to_manage_history(to_arr_qt, to_qt_p, to_qt_t, to_n_qt, to_c_qt, to_hist_qt, false, 0)
    to_last_qt_t := to_qt_t

if to_show_mn_open and not na(to_mn_p) and to_mn_t != to_last_mn_t
    to_manage_history(to_arr_mn, to_mn_p, to_mn_t, to_n_mn, to_c_mn, to_hist_mn, false, 0)
    to_last_mn_t := to_mn_t

if to_show_wk_open and not na(to_wk_p) and to_wk_t != to_last_wk_t
    to_manage_history(to_arr_wk, to_wk_p, to_wk_t, to_n_wk, to_c_wk, to_hist_wk, false, 0)
    to_last_wk_t := to_wk_t

if to_show_dy_open and not na(to_dy_p) and to_dy_t != to_last_dy_t
    to_manage_history(to_arr_dy, to_dy_p, to_dy_t, to_n_dy, to_c_dy, to_hist_dy, false, 0)
    to_last_dy_t := to_dy_t

if to_show_sess_open
    if not na(to_asia_p) and to_asia_t != to_last_asia_t
        to_manage_history(to_arr_sess, to_asia_p, to_asia_t, "AO", to_c_sess, to_hist_sess, true, 0)
        to_last_asia_t := to_asia_t
    if not na(to_lon_p) and to_lon_t != to_last_lon_t
        to_manage_history(to_arr_sess, to_lon_p, to_lon_t, "LO", to_c_sess, to_hist_sess, true, 0)
        to_last_lon_t := to_lon_t
    if not na(to_nyam_p) and to_nyam_t != to_last_nyam_t
        to_manage_history(to_arr_sess, to_nyam_p, to_nyam_t, "NYO[AM]", to_c_sess, to_hist_sess, true, 0)
        to_last_nyam_t := to_nyam_t
    if not na(to_nypm_p) and to_nypm_t != to_last_nypm_t
        to_manage_history(to_arr_sess, to_nypm_p, to_nypm_t, "NYO[PM]", to_c_sess, to_hist_sess, true, 0)
        to_last_nypm_t := to_nypm_t

if to_show_90m_open
    if not na(to_nm_p) and to_nm_t != to_last_nm_t
        to_manage_history(to_arr_90m, to_nm_p, to_nm_t, "90m", to_c_90m, to_hist_90m, true, to_nm_end_t)
        to_last_nm_t := to_nm_t

// Maintenance
to_vis_yr   = to_is_visible(to_yr_min,   to_yr_max)
to_vis_qt   = to_is_visible(to_qt_min,   to_qt_max)
to_vis_mn   = to_is_visible(to_mn_min,   to_mn_max)
to_vis_wk   = to_is_visible(to_wk_min,   to_wk_max)
to_vis_dy   = to_is_visible(to_dy_min,   to_dy_max)
to_vis_sess = to_is_visible(to_sess_min, to_sess_max)
to_vis_90m  = to_is_visible(to_nm_min,   to_nm_max)

to_maintain_lines(to_arr_yr,   to_vis_yr,   false, to_hist_yr)
to_maintain_lines(to_arr_qt,   to_vis_qt,   false, to_hist_qt)
to_maintain_lines(to_arr_mn,   to_vis_mn,   false, to_hist_mn)
to_maintain_lines(to_arr_wk,   to_vis_wk,   false, to_hist_wk)
to_maintain_lines(to_arr_dy,   to_vis_dy,   false, to_hist_dy)
to_maintain_lines(to_arr_sess, to_vis_sess, true,  to_hist_sess)
to_maintain_lines(to_arr_90m,  to_vis_90m,  true,  to_hist_90m)

// =============================================================================
// PRICE TRACKING TABLE
// =============================================================================

var table to_tbl = table.new(to_table_pos, 2, 8, border_width=0)

to_is_current_period(int trigger_time, string type) =>
    bool current = false
    if trigger_time == 0 or na(trigger_time)
        current := false
    else
        string tz = "America/New_York"
        int t_y = year(trigger_time, tz)
        int t_m = month(trigger_time, tz)
        int t_d = dayofmonth(trigger_time, tz)
        int c_y = year(time, tz)
        int c_m = month(time, tz)
        int c_d = dayofmonth(time, tz)
        if type == "D"
            current := (t_d == c_d and t_m == c_m and t_y == c_y)
        else if type == "W"
            int t_w = weekofyear(trigger_time, tz)
            int c_w = weekofyear(time, tz)
            bool is_sunday = dayofweek(time, tz) == dayofweek.sunday
            current := (t_w == c_w and t_y == c_y and not is_sunday)
        else if type == "M"
            current := (t_m == c_m and t_y == c_y)
        else if type == "Q"
            int t_q = math.floor((t_m - 1) / 3)
            int c_q = math.floor((c_m - 1) / 3)
            current := (t_q == c_q and t_y == c_y)
        else if type == "Y"
            current := (t_y == c_y)
        else if type == "SESS" or type == "90M"
            current := (t_d == c_d and t_m == c_m and t_y == c_y)
    current

to_get_status(float lvl_price, int trig_t, string period_type) =>
    string txt = "Not Open"
    color col = to_c_tbl_none
    if not na(lvl_price) and to_is_current_period(trig_t, period_type)
        if close > lvl_price
            txt := "Above"
            col := to_c_tbl_above
        else
            txt := "Below"
            col := to_c_tbl_below
    [txt, col]

to_get_array_status(array<TO_Level> arr, string label_name) =>
    string label_txt  = label_name
    string status_txt = "Not Open"
    color col = to_c_tbl_none
    if array.size(arr) > 0
        lastObj = array.get(arr, array.size(arr)-1)
        bool is_time_valid = lastObj.end_t == 0 or time < lastObj.end_t
        if lastObj.active and is_time_valid
            if close > lastObj.price
                status_txt := "Above"
                col := to_c_tbl_above
            else
                status_txt := "Below"
                col := to_c_tbl_below
    [label_txt, status_txt, col]

if to_show_table and barstate.islast
    int row_idx = 0
    if to_tbl_show_90m
        [lbl_90, txt_90, col_90] = to_get_array_status(to_arr_90m, "90-Min")
        table.cell(to_tbl, 0, row_idx, lbl_90, text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, txt_90, text_color=col_90,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_sess
        [lbl_s, txt_s, col_s] = to_get_array_status(to_arr_sess, "Session")
        table.cell(to_tbl, 0, row_idx, lbl_s,   text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, txt_s,   text_color=col_s,          text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_dy
        [st_txt, st_col] = to_get_status(to_dy_p, to_dy_t, "D")
        table.cell(to_tbl, 0, row_idx, "Daily",  text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, st_txt,   text_color=st_col,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_wk
        [st_txt, st_col] = to_get_status(to_wk_p, to_wk_t, "W")
        table.cell(to_tbl, 0, row_idx, "Weekly", text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, st_txt,   text_color=st_col,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_mn
        [st_txt, st_col] = to_get_status(to_mn_p, to_mn_t, "M")
        table.cell(to_tbl, 0, row_idx, "Monthly",text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, st_txt,   text_color=st_col,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_qt
        [st_txt, st_col] = to_get_status(to_qt_p, to_qt_t, "Q")
        table.cell(to_tbl, 0, row_idx, "Quarterly", text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, st_txt,      text_color=st_col,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
    if to_tbl_show_yr
        [st_txt, st_col] = to_get_status(to_yr_p, to_yr_t, "Y")
        table.cell(to_tbl, 0, row_idx, "Yearly", text_color=chart.fg_color, text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        table.cell(to_tbl, 1, row_idx, st_txt,   text_color=st_col,         text_size=to_table_txt_size, bgcolor=color(na), text_font_family=to_font_fam)
        row_idx += 1
````

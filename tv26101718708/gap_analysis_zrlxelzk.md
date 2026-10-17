# Gap Analysis

- url: https://www.tradingview.com/script/ZrLxeLZK-Gap-Analysis/
- type: indicator
- pine_id: PUB;0568730a64564aa0bab38dad083edd95
- version: 5.0

## Description

Description:

This indicator automates the tracking of session gaps, providing real-time data on gap fills, historical context, and exhaustion risk. It is built specifically for day traders and swing traders who use gap-fill strategies during Regular Trading Hours (RTH).

Core Functionality:
The script captures the closing price (settle) of the previous RTH session and measures it against the open of the current RTH session. If a gap exceeds your minimum point threshold, it maps the gap zone on your chart and tracks price action against the settle line until the gap is filled.

Key Features:

    Dynamic Fill Tracking: Monitors unfilled gaps bar-by-bar. It calculates the exact percentage of the gap filled and displays how many bars it took to reach completion.

    Exhaustion Risk Detection: Tracks consecutive gaps in the same direction. If the market gaps in the same direction three or more times consecutively, the script flags an "Elevated Exhaustion" risk on the display panel.

    Clean Chart Management: Automatically shades the gap zone and draws the target settle line. You can toggle a setting to instantly hide gaps once they are 100% filled, preventing chart clutter.

    Heads-Up Display Table: An on-chart dashboard provides immediate access to the current session's gap direction, fill status, specific target price, and elapsed time.

    Historical Gap Review: Displays up to 20 historical session gaps, allowing you to backtest how often and how quickly an asset fills its gaps.

    Integrated Alerts: Supports automated alerts for two conditions: when a new qualifying gap is formed at the session open, and the moment a gap is entirely filled.

Configuration & Setup:

    RTH Session: Define your specific trading hours (default is 0830-1500 America/Chicago). The indicator requires this to accurately lock in the previous day's settle.

    Minimum Gap Size: Filter out market noise by setting a minimum point threshold. Gaps smaller than this value will be ignored.

    Visual Customization: Full control over bull/bear zone colors, line styles, text sizes, and table positioning.

Usage Notes:
This script relies on timeframe data to establish session boundaries. It is optimal for intraday timeframes (e.g., 1m, 5m, 15m, 1H).

## Source Code

````pine
// © TatankaTrading
//@version=6
indicator("Gap Analysis", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// Process the full chart dataset; drawing limits are separate from stored history.
const int MAX_STORED_GAPS = 100000  // Pine's per-array limit.
const int MAX_DRAWINGS = 500

// ============================================================================
// INPUTS
// ============================================================================

string u_tz = "America/Chicago"

g_gap = "═══ Gap Settings ═══"
gap_enable       = input.bool(true, "Enable Gap Analysis", group=g_gap)
gap_rth_session  = input.session("0830-1500", "RTH Session", group=g_gap)
gap_min_pts      = input.float(0.0, "Min Gap Size (Points)", group=g_gap, tooltip="Minimum gap size in points to display. Set to 0 to show all gaps.")
gap_hist_count   = input.int(500, "Maximum Gaps to Show", minval=1, maxval=500, group=g_gap, tooltip="Show the newest eligible gaps from all available chart history, including the latest gap. Hidden filled gaps do not consume display slots. TradingView allows 500 boxes: up to 500 one-box gaps, or 250 when every gap needs both an unfilled box and touched-area box. Tracking continues for older gaps even when they cannot be drawn.")
i_gap_extend_right = input.bool(true, "Extend Unfilled Gaps Right", group=g_gap, tooltip="Extend displayed unfilled zones and settle lines to the right until filled. Maximum Gaps to Show limits drawings only. When disabled, historical zones end at the next detected gap and the newest ends at the current bar.")

g_vis = "═══ Visual Settings ═══"
gap_bull_color   = input.color(color.new(#22c55e, 80), "Bull Gap Color (Up)", group=g_vis)
gap_bear_color   = input.color(color.new(#ef4444, 80), "Bear Gap Color (Down)", group=g_vis)
gap_fill_color   = input.color(color.new(#64748b, 90), "Filled Gap Color", group=g_vis)
gap_settle_style = input.string("Dashed", "Settle Line Style", options=["Solid", "Dashed", "Dotted"], group=g_vis)
gap_settle_width = input.int(1, "Settle Line Width", minval=1, maxval=4, group=g_vis)
gap_lbl_size_in  = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=g_vis)
gap_show_zone    = input.bool(true, "Show Gap Zone (Shading)", group=g_vis)
i_gap_partial_fill = input.bool(true, "Shrink Zone as Price Fills Gap", group=g_vis, tooltip="Shrink the colored zone to the unfilled portion using candle wicks. Up gaps shrink downward; down gaps shrink upward. The deepest fill is retained when price moves away. Tracking includes every chart bar, including overnight bars when available.")
i_gap_show_filled_part = input.bool(true, "Show Partially Filled Area", group=g_vis, tooltip="With shrinking enabled, shade the touched portion using Filled Gap Color. Turn off to show only the remaining colored zone. Fully filled gaps still follow Hide Filled Gaps.")
gap_show_settle  = input.bool(true, "Show Settle Line", group=g_vis)
gap_show_labels  = input.bool(true, "Show Gap Labels", group=g_vis)
gap_hide_filled  = input.bool(true, "Hide Filled Gaps", group=g_vis, tooltip="Remove gaps from the chart once they have been filled.")

g_tbl = "═══ Table Settings ═══"
gap_show_table   = input.bool(true, "Show Gap Table", group=g_tbl)
gap_tbl_pos      = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group=g_tbl)
gap_tbl_size     = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group=g_tbl)

g_alert = "═══ Alerts ═══"
gap_alert_fill   = input.bool(true, "Alert on Gap Fill", group=g_alert)
gap_alert_new    = input.bool(true, "Alert on New Gap", group=g_alert)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

get_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large

get_line_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted

get_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left

f_fmt_price(float p) =>
    str.tostring(p, format.mintick)

// ============================================================================
// SESSION DETECTION
// ============================================================================

bool is_rth = not na(time(timeframe.period, gap_rth_session, u_tz))
bool rth_open = is_rth and not is_rth[1]
bool rth_close = not is_rth and is_rth[1]

// Include the whole fill bar, even when the gap fills on its opening bar.
// A minimal fallback keeps drawings valid if the chart has no known bar close time.
int gap_bar_end_time = na(time_close) ? time + 1 : math.max(time + 1, time_close)

// ============================================================================
// SETTLE PRICE CAPTURE
// ============================================================================

// Track the close of the last RTH bar as settle
var float prev_settle = na
var float current_settle = na
var float tracking_settle = na

// During RTH, continuously track close as potential settle
if is_rth
    tracking_settle := close

// When RTH ends, lock in the settle
if rth_close and not na(tracking_settle)
    prev_settle := current_settle
    current_settle := tracking_settle

// ============================================================================
// ATR FOR CONTEXT
// ============================================================================

atr_14 = ta.atr(14)

// ============================================================================
// GAP DETECTION & TRACKING
// ============================================================================

// Append oldest-to-newest so active gap indices stay stable as history grows.
var float[]   gap_open_prices  = array.new_float()
var float[]   gap_settle_prices = array.new_float()
var float[]   gap_sizes        = array.new_float()
var int[]     gap_directions   = array.new_int()      // 1 = bull, -1 = bear
var bool[]    gap_filled       = array.new_bool()
var int[]     gap_fill_bars    = array.new_int()       // 0 also allows an opening-bar fill; use gap_filled for status
var int[]     gap_start_bars   = array.new_int()
var float[]   gap_fill_pcts    = array.new_float()     // % of gap filled so far
var int[]     gap_start_times  = array.new_int()
var int[]     gap_fill_times   = array.new_int()       // close time of the first fully filled bar
var int[]     gap_active_indices = array.new_int()     // only unfilled gaps need work on each bar

// Current session gap state
var float cur_gap_size     = na
var int   cur_gap_dir      = 0
var bool  cur_gap_filled   = false
var int   cur_gap_bar_start = 0
var float cur_gap_open     = na
var float cur_gap_settle   = na
var float cur_gap_max_fill = 0.0
var int   cur_gap_fill_bar = 0

// Consecutive gap tracking
var int consec_bull = 0
var int consec_bear = 0

// Drawing arrays
var box[]   gap_boxes   = array.new_box()
var line[]  gap_lines   = array.new_line()
var label[] gap_labels  = array.new_label()

// ─── New Gap Detection ─────────────────────────────────────────

if rth_open and gap_enable
    float rth_open_price = open
    float settle_ref = current_settle  // settle from the session that just ended

    if not na(settle_ref)
        float gap_size_pts = rth_open_price - settle_ref
        float abs_gap = math.abs(gap_size_pts)
        
        if abs_gap >= gap_min_pts
            int dir = gap_size_pts > 0 ? 1 : gap_size_pts < 0 ? -1 : 0
            
            if dir != 0
                // Update consecutive counters
                if dir == 1
                    consec_bull += 1
                    consec_bear := 0
                else
                    consec_bear += 1
                    consec_bull := 0
                
                // Only trim if Pine's hard array capacity is reached.
                if array.size(gap_open_prices) >= MAX_STORED_GAPS
                    array.shift(gap_open_prices)
                    array.shift(gap_settle_prices)
                    array.shift(gap_sizes)
                    array.shift(gap_directions)
                    array.shift(gap_filled)
                    array.shift(gap_fill_bars)
                    array.shift(gap_start_bars)
                    array.shift(gap_fill_pcts)
                    array.shift(gap_start_times)
                    array.shift(gap_fill_times)
                    if array.size(gap_active_indices) > 0
                        for active_pos = array.size(gap_active_indices) - 1 to 0
                            int stored_index = array.get(gap_active_indices, active_pos)
                            if stored_index == 0
                                array.remove(gap_active_indices, active_pos)
                            else
                                array.set(gap_active_indices, active_pos, stored_index - 1)

                // Keep the entire available history independently of drawing capacity.
                array.push(gap_open_prices, rth_open_price)
                array.push(gap_settle_prices, settle_ref)
                array.push(gap_sizes, abs_gap)
                array.push(gap_directions, dir)
                array.push(gap_filled, false)
                array.push(gap_fill_bars, 0)
                array.push(gap_start_bars, bar_index)
                array.push(gap_fill_pcts, 0.0)
                array.push(gap_start_times, time)
                array.push(gap_fill_times, int(na))
                
                array.push(gap_active_indices, array.size(gap_open_prices) - 1)

                // Set current session state
                cur_gap_size := abs_gap
                cur_gap_dir := dir
                cur_gap_filled := false
                cur_gap_bar_start := bar_index
                cur_gap_open := rth_open_price
                cur_gap_settle := settle_ref
                cur_gap_max_fill := 0.0
                cur_gap_fill_bar := 0
                
                // Alert
                if gap_alert_new
                    string dir_str = dir == 1 ? "UP" : "DOWN"
                    alert("GAP " + dir_str + " " + f_fmt_price(abs_gap) + " pts | Open: " + f_fmt_price(rth_open_price) + " | Settle: " + f_fmt_price(settle_ref), alert.freq_once_per_bar)

// ─── Fill Tracking: Check ALL Unfilled Gaps Every Bar ─────────────────

if gap_enable and array.size(gap_active_indices) > 0
    // Reverse iteration safely removes completed gaps without skipping a neighbor.
    int active_count = array.size(gap_active_indices)
    for active_pos = active_count - 1 to 0
        int i = array.get(gap_active_indices, active_pos)
        int   g_dir_i    = array.get(gap_directions, i)
        float g_settle_i = array.get(gap_settle_prices, i)
        float g_open_i   = array.get(gap_open_prices, i)
        float g_size_i   = array.get(gap_sizes, i)
        int   g_start_i  = array.get(gap_start_bars, i)
        
        // Check if price reached settle level
        bool just_filled = false
        if g_dir_i == 1 and low <= g_settle_i
            just_filled := true
        else if g_dir_i == -1 and high >= g_settle_i
            just_filled := true
        
        // Update fill percentage
        float fill_dist = 0.0
        if g_dir_i == 1
            fill_dist := g_open_i - math.min(low, g_open_i)
        else
            fill_dist := math.max(high, g_open_i) - g_open_i
        
        if g_size_i > 0
            float new_pct = math.min(fill_dist / g_size_i * 100, 100.0)
            float old_pct = array.get(gap_fill_pcts, i)
            if new_pct > old_pct
                array.set(gap_fill_pcts, i, new_pct)
        
        if just_filled
            array.set(gap_filled, i, true)
            array.set(gap_fill_bars, i, bar_index - g_start_i)
            array.set(gap_fill_pcts, i, 100.0)
            array.set(gap_fill_times, i, gap_bar_end_time)
            array.remove(gap_active_indices, active_pos)
            
            // Alert on fill
            if gap_alert_fill
                string dir_str_i = g_dir_i == 1 ? "UP" : "DOWN"
                int bars_to_fill = bar_index - g_start_i
                alert("GAP " + dir_str_i + " FILLED | " + f_fmt_price(g_size_i) + " pts in " + str.tostring(bars_to_fill) + " bars", alert.freq_once_per_bar)

// The latest gap can be filled even when the active list is empty.
if gap_enable and array.size(gap_filled) > 0
    int latest_gap_index = array.size(gap_filled) - 1
    cur_gap_filled := array.get(gap_filled, latest_gap_index)
    cur_gap_fill_bar := array.get(gap_fill_bars, latest_gap_index)
    cur_gap_max_fill := array.get(gap_fill_pcts, latest_gap_index)

// ============================================================================
// GAP CLASSIFICATION
// ============================================================================

f_classify_gap(int dir, bool filled, int consec, float fill_pct) =>
    string classification = ""
    string dir_str = dir == 1 ? "UP" : "DN"
    
    if filled
        classification := "GAP " + dir_str + " (FILLED)"
    else
        classification := "GAP " + dir_str + " (" + str.tostring(math.round(fill_pct)) + "% filled)"
    
    bool is_exhaustion_risk = consec >= 3
    
    [classification, is_exhaustion_risk]

int cur_consec = cur_gap_dir == 1 ? consec_bull : consec_bear
[cur_classification, cur_exhaustion_risk] = f_classify_gap(cur_gap_dir, cur_gap_filled, cur_consec, cur_gap_max_fill)

// ============================================================================
// VISUALIZATION: GAP ZONES, SETTLE LINES, LABELS
// ============================================================================

int gap_drawn_count = 0

if barstate.islast and gap_enable
    // Clean previous drawings
    if array.size(gap_boxes) > 0
        for i = 0 to array.size(gap_boxes) - 1
            box.delete(array.get(gap_boxes, i))
    array.clear(gap_boxes)
    
    if array.size(gap_lines) > 0
        for i = 0 to array.size(gap_lines) - 1
            line.delete(array.get(gap_lines, i))
    array.clear(gap_lines)
    
    if array.size(gap_labels) > 0
        for i = 0 to array.size(gap_labels) - 1
            label.delete(array.get(gap_labels, i))
    array.clear(gap_labels)

    // Scan all stored history, newest first. Hidden gaps do not consume slots.
    int stored_count = array.size(gap_open_prices)
    
    if stored_count > 0 and (gap_show_zone or gap_show_settle or gap_show_labels)
        for i = stored_count - 1 to 0
            if gap_drawn_count >= gap_hist_count
                break

            bool g_fill = array.get(gap_filled, i)
            if g_fill and gap_hide_filled
                continue

            float g_open   = array.get(gap_open_prices, i)
            float g_settle = array.get(gap_settle_prices, i)
            int   g_dir    = array.get(gap_directions, i)
            int   g_start_time = array.get(gap_start_times, i)
            float g_size   = array.get(gap_sizes, i)
            float g_pct    = array.get(gap_fill_pcts, i)
            int   g_fill_time = array.get(gap_fill_times, i)
            
            float top_price = math.max(g_open, g_settle)
            float bot_price = math.min(g_open, g_settle)
            
            // Timestamp coordinates keep older gaps drawable without bar-index limits.
            int zone_end = gap_bar_end_time
            if not i_gap_extend_right and i < stored_count - 1
                zone_end := array.get(gap_start_times, i + 1)
            if g_fill and not na(g_fill_time)
                zone_end := math.min(zone_end, g_fill_time)
            zone_end := math.max(g_start_time + 1, zone_end)
            string zone_extend = i_gap_extend_right and not g_fill ? extend.right : extend.none

            // Fill percentage is cumulative: the unfilled region never grows back.
            float fill_edge = g_fill ? g_settle : g_open - g_dir * g_size * g_pct / 100.0
            fill_edge := math.max(bot_price, math.min(top_price, fill_edge))
            float remaining_top = g_dir == 1 ? fill_edge : top_price
            float remaining_bot = g_dir == 1 ? bot_price : fill_edge
            float touched_top = g_dir == 1 ? top_price : fill_edge
            float touched_bot = g_dir == 1 ? fill_edge : bot_price

            // Budget complete gaps before creating objects, so garbage collection
            // cannot silently remove a newer gap to make room for an older one.
            bool draw_full_zone = gap_show_zone and (g_fill or not i_gap_partial_fill)
            bool draw_touched_zone = gap_show_zone and not draw_full_zone and i_gap_show_filled_part and g_pct > 0 and touched_top > touched_bot
            bool draw_remaining_zone = gap_show_zone and not draw_full_zone and remaining_top > remaining_bot
            int boxes_needed = (draw_full_zone ? 1 : 0) + (draw_touched_zone ? 1 : 0) + (draw_remaining_zone ? 1 : 0)
            if array.size(gap_boxes) + boxes_needed > MAX_DRAWINGS
                break
            gap_drawn_count += 1

            // Colors — strong for unfilled, muted for filled
            color dir_col = g_dir == 1 ? color.new(#22c55e, 0) : color.new(#ef4444, 0)
            color zone_col = g_dir == 1 ? gap_bull_color : gap_bear_color
            color touched_col = gap_fill_color
            color line_col = g_dir == 1 ? color.new(#22c55e, 30) : color.new(#ef4444, 30)
            color lbl_col  = dir_col
            
            if g_fill
                zone_col := gap_fill_color
                line_col := color.new(#64748b, 70)
                lbl_col  := color.new(#64748b, 30)
            
            // Dim older historical gaps
            int gap_age = stored_count - 1 - i
            if gap_age > 0
                int dim = math.min(gap_age * 10, 40)
                zone_col := color.new(zone_col, math.min(math.max(95, color.t(zone_col)), color.t(zone_col) + dim))
                touched_col := color.new(touched_col, math.min(math.max(98, color.t(touched_col)), color.t(touched_col) + dim * 0.25))
                line_col := color.new(line_col, math.min(85, 40 + dim))
                lbl_col  := color.new(lbl_col, math.min(80, 20 + dim))
            
            // Only the remaining portion extends right; the touched area stays finite.
            if draw_full_zone
                box full_box = box.new(left=g_start_time, top=top_price, right=zone_end, bottom=bot_price, xloc=xloc.bar_time, extend=zone_extend, border_color=color.new(line_col, 40), border_width=1, bgcolor=zone_col, border_style=line.style_dotted)
                array.push(gap_boxes, full_box)
            if draw_touched_zone
                box touched_box = box.new(left=g_start_time, top=touched_top, right=zone_end, bottom=touched_bot, xloc=xloc.bar_time, extend=extend.none, border_color=na, border_width=0, bgcolor=touched_col)
                array.push(gap_boxes, touched_box)
            if draw_remaining_zone
                box remaining_box = box.new(left=g_start_time, top=remaining_top, right=zone_end, bottom=remaining_bot, xloc=xloc.bar_time, extend=zone_extend, border_color=color.new(line_col, 40), border_width=1, bgcolor=zone_col, border_style=line.style_dotted)
                array.push(gap_boxes, remaining_box)
            
            // Settle line (fill target)
            if gap_show_settle
                l = line.new(g_start_time, g_settle, zone_end, g_settle, xloc=xloc.bar_time, extend=zone_extend, color=line_col, style=get_line_style(gap_settle_style), width=gap_settle_width)
                array.push(gap_lines, l)
            
            // Label
            if gap_show_labels
                string dir_str = g_dir == 1 ? "GAP UP ▲" : "GAP DOWN ▼"
                string size_str = f_fmt_price(g_size) + " pts"
                string status_str = g_fill ? "FILLED" : g_pct > 0 ? str.tostring(g_pct, "#.##") + "% FILLED" : "UNFILLED"
                string gap_txt = dir_str + "\n" + size_str + "\n" + status_str
                
                float lbl_price = g_dir == 1 ? top_price : bot_price
                
                lb = label.new(g_start_time, lbl_price, gap_txt, xloc=xloc.bar_time, color=color.new(color.black, 70), textcolor=lbl_col, style=g_dir == 1 ? label.style_label_lower_right : label.style_label_upper_right, size=get_size(gap_lbl_size_in))
                array.push(gap_labels, lb)

// ============================================================================
// INFO TABLE
// ============================================================================

var table gap_table = table.new(get_pos(gap_tbl_pos), 2, 7, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast and gap_show_table and gap_enable and cur_gap_dir != 0
    string sz = get_size(gap_tbl_size)
    
    // Row 0: Direction
    table.cell(gap_table, 0, 0, "GAP", text_color=color.white, text_size=sz, text_halign=text.align_left)
    string dir_display = cur_gap_dir == 1 ? "▲ UP" : "▼ DOWN"
    color dir_col = cur_gap_dir == 1 ? color.new(#22c55e, 0) : color.new(#ef4444, 0)
    table.cell(gap_table, 1, 0, dir_display, text_color=dir_col, text_size=sz, text_halign=text.align_right)

    // Stored history and visible drawings have separate limits.
    table.cell(gap_table, 0, 1, "HISTORY", text_color=color.white, text_size=sz, text_halign=text.align_left)
    string history_str = str.tostring(array.size(gap_open_prices)) + " stored / " + str.tostring(gap_drawn_count) + " shown"
    table.cell(gap_table, 1, 1, history_str, text_color=color.gray, text_size=sz, text_halign=text.align_right)
    
    // Row 2: Fill status with color progression
    table.cell(gap_table, 0, 2, "STATUS", text_color=color.white, text_size=sz, text_halign=text.align_left)
    string fill_str = cur_gap_filled ? "FILLED" : str.tostring(math.round(cur_gap_max_fill)) + "% FILLED"
    color fill_col = cur_gap_filled ? color.new(#22c55e, 0) : (cur_gap_max_fill > 50 ? color.yellow : color.gray)
    table.cell(gap_table, 1, 2, fill_str, text_color=fill_col, text_size=sz, text_halign=text.align_right)
    
    // Row 3: Fill target price
    table.cell(gap_table, 0, 3, "FILL TARGET", text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(gap_table, 1, 3, f_fmt_price(cur_gap_settle), text_color=color.gray, text_size=sz, text_halign=text.align_right)
    
    // Row 4: Bar count
    table.cell(gap_table, 0, 4, "BARS", text_color=color.white, text_size=sz, text_halign=text.align_left)
    int bars_elapsed = bar_index - cur_gap_bar_start
    string bars_str = cur_gap_filled ? str.tostring(cur_gap_fill_bar) + " to fill" : str.tostring(bars_elapsed) + " elapsed"
    table.cell(gap_table, 1, 4, bars_str, text_color=color.gray, text_size=sz, text_halign=text.align_right)
    
    // Row 5: Consecutive same-direction gaps
    table.cell(gap_table, 0, 5, "CONSECUTIVE", text_color=color.white, text_size=sz, text_halign=text.align_left)
    string consec_str = str.tostring(cur_consec) + (cur_gap_dir == 1 ? " bull" : " bear")
    color consec_col = cur_consec >= 3 ? color.new(#f59e0b, 0) : color.gray
    table.cell(gap_table, 1, 5, consec_str, text_color=consec_col, text_size=sz, text_halign=text.align_right)
    
    // Row 6: Exhaustion risk flag
    table.cell(gap_table, 0, 6, "EXHAUSTION", text_color=color.white, text_size=sz, text_halign=text.align_left)
    string exh_str = cur_exhaustion_risk ? "⚠ ELEVATED" : "---"
    color exh_col = cur_exhaustion_risk ? color.new(#f59e0b, 0) : color.gray
    table.cell(gap_table, 1, 6, exh_str, text_color=exh_col, text_size=sz, text_halign=text.align_right)
````

# ICT Algorithmic Macro Tracker @SafarTrades

- url: https://www.tradingview.com/script/wKvuXp5t-ICT-Algorithmic-Macro-Tracker-SafarTrades/
- type: indicator
- pine_id: PUB;baa7ac1663ff4469bc8750cfda13d79e
- version: 1.0

## Description

[b]ICT Algorithmic Macro Tracker[/b]

ICT Algorithmic Macro Tracker automatically highlights the predefined ICT macro time windows throughout the trading day, allowing traders to quickly identify high-probability algorithmic execution periods without manually tracking the clock.

Designed for ICT and Smart Money traders, the indicator centralizes all major macro windows into a single configurable tool while providing extensive customization for different trading workflows.
[image]https://www.tradingview.com/x/4ogUf1DQ/[/image]
[b]Features[/b]
[image]https://www.tradingview.com/x/sQ32wNXX/[/image]
Display all major ICT macro windows, including:

AM Killzone
[list]
[*]07:50 – 08:10
[*]08:50 – 09:10
[*]09:50 – 10:10
[*]10:50 – 11:10
[/list]
PM Killzone
[list]
[*]11:50 – 12:10
[*]12:50 – 13:10
[*]13:50 – 14:10
[*]14:50 – 15:10
[*]15:15 – 15:45
[*]15:50 – 16:10
[/list]
Overnight & London
[list]
[*]23:50 – 00:10
[*]00:50 – 01:10
[*]01:50 – 02:10
[*]02:50 – 03:10
[/list]
Each macro window can be enabled or disabled independently.

[b]Bracket & Label Customization[/b]
[image]https://www.tradingview.com/x/OpooIjFW/[/image]
Customize every macro bracket with configurable:
[list]
[*]Bracket color
[*]Label color
[*]Line style
[*]Line width
[*]Bracket placement
[*]Label size
[*]Optional time display
[*]Macro projections
[/list]
[b]Intended Use[/b]

ICT Algorithmic Macro Tracker is designed for traders who incorporate ICT macro timing into their execution. By automatically marking algorithmic time windows, the indicator helps maintain awareness of important market periods while reducing chart clutter and manual time tracking.

## Source Code

````pine
//@version=6
indicator("ICT Algorithmic Macro Tracker", overlay=true, max_lines_count=500, max_labels_count=500)

// © 2026 SafarTrades
// All Rights Reserved
//
// This indicator is proprietary software.
// Unauthorized copying, redistribution,
// resale, modification, or republication
// is prohibited without written permission.

// =========================================================================
// 1. Global Settings & Visual Styling
// =========================================================================
var string G_GLOBAL = "GLOBAL CONFIGURATION"

timezoneInput = input.string("America/New_York", title="Timezone Selection", group=G_GLOBAL, 
     options=["America/New_York", "UTC-4", "UTC-5", "UTC-6", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+8"],
     tooltip="Select timezone for sessions. 'America/New_York' is highly recommended for ICT to handle Daylight Saving Time (DST) automatically.")

history_limit_days = input.int(7, title="Draw History Limit (Days)", minval=1, maxval=60, group=G_GLOBAL,
     tooltip="Limits calculation and drawing to the specified number of days in the past. Default is 7 days (1 week).")

hideAboveInput = input.int(5, title="Hide Indicator Above Specified Minutes", group=G_GLOBAL,
     tooltip="Hide the indicator features when chart timeframe is higher than this value (in minutes). Default is 5 minutes.")

var string G_STYLE = "BRACKET & LABEL STYLING"

macro_color      = input.color(#000000, "Bracket Color", group=G_STYLE, inline="col")
lbl_color        = input.color(#000000, "Label Color", group=G_STYLE, inline="col")
macro_width      = input.int(1, "Line Width", minval=1, maxval=4, group=G_STYLE)
macro_style      = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_STYLE)
bracket_mode     = input.string("Above", "Bracket Placement", options=["Above", "Below", "Both"], group=G_STYLE,
     tooltip="Choose whether to display brackets Above the highs, Below the lows, or Both.")
show_labels      = input.bool(true, "Macro Label?", group=G_STYLE, inline="labels")
show_time        = input.bool(true, "Show Time?", group=G_STYLE, inline="labels")
lbl_size_input   = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=G_STYLE)
show_projections = input.bool(true, "Macro Projections?", group=G_STYLE, tooltip="Draws vertical dotted lines extending from bracket corners to candle wicks.")

// =========================================================================
// 2. Pre-configured Macro Time Windows (Checklist Only)
// =========================================================================

// Group: AM Macros (Morning NY)
var string G_AM = "AM KILLZONE MACROS"
show_m1 = input.bool(true, "07:50 - 08:10", group=G_AM)
show_m2 = input.bool(true, "08:50 - 09:10", group=G_AM)
show_m3 = input.bool(true, "09:50 - 10:10", group=G_AM)
show_m4 = input.bool(true, "10:50 - 11:10", group=G_AM)

// Group: PM Macros (Afternoon NY)
var string G_PM = "PM KILLZONE MACROS"
show_p1 = input.bool(true, "11:50 - 12:10", group=G_PM)
show_p2 = input.bool(true, "12:50 - 13:10", group=G_PM)
show_p3 = input.bool(true, "13:50 - 14:10", group=G_PM)
show_p4 = input.bool(true, "14:50 - 15:10", group=G_PM)
show_p5 = input.bool(true, "15:15 - 15:45", group=G_PM)
show_p6 = input.bool(true, "15:50 - 16:10", group=G_PM)

// Group: Overnight & London Macros
var string G_ON = "OVERNIGHT & LONDON MACROS"
show_o1 = input.bool(true, "23:50 - 00:10", group=G_ON)
show_o2 = input.bool(true, "00:50 - 01:10", group=G_ON)
show_o3 = input.bool(true, "01:50 - 02:10", group=G_ON)
show_o4 = input.bool(true, "02:50 - 03:10", group=G_ON)
show_o5 = input.bool(true, "03:50 - 04:10", group=G_ON)
show_o6 = input.bool(true, "04:50 - 05:10", group=G_ON)
show_o7 = input.bool(true, "05:50 - 06:10", group=G_ON)
show_o8 = input.bool(true, "06:50 - 07:10", group=G_ON)

// Group: Evening Macros
var string G_EV = "EVENING MACROS"
show_e1 = input.bool(true, "16:50 - 17:10", group=G_EV)
show_e2 = input.bool(true, "17:50 - 18:10", group=G_EV)
show_e3 = input.bool(true, "18:50 - 19:10", group=G_EV)
show_e4 = input.bool(true, "19:50 - 20:10", group=G_EV)
show_e5 = input.bool(true, "20:50 - 21:10", group=G_EV)
show_e6 = input.bool(true, "21:50 - 22:10", group=G_EV)
show_e7 = input.bool(true, "22:50 - 23:10", group=G_EV)


// =========================================================================
// 3. Types & Data Structures
// =========================================================================

// Custom User-Defined Type (UDT) to represent a macro session drawing block
type MacroSession
    line high_line_top
    line high_line_left
    line high_line_right
    line high_proj_left
    line high_proj_right
    label high_lbl
    
    line low_line_btm
    line low_line_left
    line low_line_right
    line low_proj_left
    line low_proj_right
    label low_lbl
    
    int start_time
    int end_time
    float high_baseline
    float low_baseline
    float start_high
    float start_low
    float end_high
    float end_low
    bool is_completed

// Custom User-Defined Type (UDT) to track the state and timing of each macro session configuration
type MacroTrackerState
    string sess_time
    bool active_input
    string label_name
    int last_start_time
    MacroSession active_sess

// Method to delete all lines/labels in a MacroSession
method clean(MacroSession sess) =>
    if not na(sess.high_line_top)
        line.delete(sess.high_line_top)
    if not na(sess.high_line_left)
        line.delete(sess.high_line_left)
    if not na(sess.high_line_right)
        line.delete(sess.high_line_right)
    if not na(sess.high_proj_left)
        line.delete(sess.high_proj_left)
    if not na(sess.high_proj_right)
        line.delete(sess.high_proj_right)
    if not na(sess.high_lbl)
        label.delete(sess.high_lbl)
        
    if not na(sess.low_line_btm)
        line.delete(sess.low_line_btm)
    if not na(sess.low_line_left)
        line.delete(sess.low_line_left)
    if not na(sess.low_line_right)
        line.delete(sess.low_line_right)
    if not na(sess.low_proj_left)
        line.delete(sess.low_proj_left)
    if not na(sess.low_proj_right)
        line.delete(sess.low_proj_right)
    if not na(sess.low_lbl)
        label.delete(sess.low_lbl)

// Method to draw or update high and low brackets dynamically
method draw_or_update(MacroSession sess, bool active, color col, int width, string style_str, bool show_lbl, bool show_tm, string name, string bracket_m, bool draw_proj, color lbl_col, string lbl_sz) =>
    int endT = active ? time : sess.end_time
    float leg_height = syminfo.mintick * 5
    
    string lineStyle = line.style_solid
    if style_str == "Dashed"
        lineStyle := line.style_dashed
    else if style_str == "Dotted"
        lineStyle := line.style_dotted
        
    // Map text size string to TradingView label size constants
    string lblSize = size.small
    if lbl_sz == "Tiny"
        lblSize := size.tiny
    else if lbl_sz == "Normal"
        lblSize := size.normal
        
    // 1. High Bracket Update (Above or Both)
    bool draw_high = (bracket_m == "Above" or bracket_m == "Both")
    if draw_high
        float high_level = sess.high_baseline + leg_height
        float high_leg_bottom = sess.high_baseline
        if na(sess.high_line_top)
            sess.high_line_top := line.new(sess.start_time, high_level, endT, high_level, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
            sess.high_line_left := line.new(sess.start_time, high_level, sess.start_time, high_leg_bottom, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
        else
            line.set_xy1(sess.high_line_top, sess.start_time, high_level)
            line.set_xy2(sess.high_line_top, endT, high_level)
            line.set_color(sess.high_line_top, col)
            line.set_width(sess.high_line_top, width)
            line.set_style(sess.high_line_top, lineStyle)
            
            line.set_xy1(sess.high_line_left, sess.start_time, high_level)
            line.set_xy2(sess.high_line_left, sess.start_time, high_leg_bottom)
            line.set_color(sess.high_line_left, col)
            line.set_width(sess.high_line_left, width)
            line.set_style(sess.high_line_left, lineStyle)
            
        // Right vertical tip (only drawn when session is completed)
        if not active
            if na(sess.high_line_right)
                sess.high_line_right := line.new(endT, high_level, endT, high_leg_bottom, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
            else
                line.set_xy1(sess.high_line_right, endT, high_level)
                line.set_xy2(sess.high_line_right, endT, high_leg_bottom)
                line.set_color(sess.high_line_right, col)
                line.set_width(sess.high_line_right, width)
                line.set_style(sess.high_line_right, lineStyle)
        else
            if not na(sess.high_line_right)
                line.delete(sess.high_line_right)
                sess.high_line_right := na
            
        // Dotted Projections (High Bracket)
        if draw_proj
            if na(sess.high_proj_left)
                sess.high_proj_left := line.new(sess.start_time, high_leg_bottom, sess.start_time, sess.start_high, xloc=xloc.bar_time, color=col, width=width, style=line.style_dotted)
            else
                line.set_xy1(sess.high_proj_left, sess.start_time, high_leg_bottom)
                line.set_xy2(sess.high_proj_left, sess.start_time, sess.start_high)
                line.set_color(sess.high_proj_left, col)
                line.set_width(sess.high_proj_left, width)
                
            // Right projection (only drawn when session is completed)
            if not active
                if na(sess.high_proj_right)
                    sess.high_proj_right := line.new(endT, high_leg_bottom, endT, sess.end_high, xloc=xloc.bar_time, color=col, width=width, style=line.style_dotted)
                else
                    line.set_xy1(sess.high_proj_right, endT, high_leg_bottom)
                    line.set_xy2(sess.high_proj_right, endT, sess.end_high)
                    line.set_color(sess.high_proj_right, col)
                    line.set_width(sess.high_proj_right, width)
            else
                if not na(sess.high_proj_right)
                    line.delete(sess.high_proj_right)
                    sess.high_proj_right := na
        else
            if not na(sess.high_proj_left)
                line.delete(sess.high_proj_left)
                sess.high_proj_left := na
            if not na(sess.high_proj_right)
                line.delete(sess.high_proj_right)
                sess.high_proj_right := na

        // Centered stacked labels (High)
        if show_lbl
            string display_text = show_tm ? "MACRO\n" + name : "MACRO"
            if na(sess.high_lbl)
                sess.high_lbl := label.new(math.round((sess.start_time + endT) / 2), high_level, display_text, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lbl_col, style=label.style_label_down, size=lblSize)
            
            label.set_xy(sess.high_lbl, math.round((sess.start_time + endT) / 2), high_level)
            label.set_text(sess.high_lbl, display_text)
            label.set_textcolor(sess.high_lbl, lbl_col)
            label.set_size(sess.high_lbl, lblSize)
            label.delete(na)
        else
            if not na(sess.high_lbl)
                label.delete(sess.high_lbl)
                sess.high_lbl := na
            label.delete(na)
    else
        // Clean up high drawings if disabled
        if not na(sess.high_line_top)
            line.delete(sess.high_line_top)
            sess.high_line_top := na
        if not na(sess.high_line_left)
            line.delete(sess.high_line_left)
            sess.high_line_left := na
        if not na(sess.high_line_right)
            line.delete(sess.high_line_right)
            sess.high_line_right := na
        if not na(sess.high_proj_left)
            line.delete(sess.high_proj_left)
            sess.high_proj_left := na
        if not na(sess.high_proj_right)
            line.delete(sess.high_proj_right)
            sess.high_proj_right := na
        if not na(sess.high_lbl)
            label.delete(sess.high_lbl)
            sess.high_lbl := na
        label.delete(na)
            
    // 2. Low Bracket Update (Below or Both)
    bool draw_low = (bracket_m == "Below" or bracket_m == "Both")
    if draw_low
        float low_level = sess.low_baseline - leg_height
        float low_leg_top = sess.low_baseline
        if na(sess.low_line_btm)
            sess.low_line_btm := line.new(sess.start_time, low_level, endT, low_level, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
            sess.low_line_left := line.new(sess.start_time, low_level, sess.start_time, low_leg_top, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
        else
            line.set_xy1(sess.low_line_btm, sess.start_time, low_level)
            line.set_xy2(sess.low_line_btm, endT, low_level)
            line.set_color(sess.low_line_btm, col)
            line.set_width(sess.low_line_btm, width)
            line.set_style(sess.low_line_btm, lineStyle)
            
            line.set_xy1(sess.low_line_left, sess.start_time, low_level)
            line.set_xy2(sess.low_line_left, sess.start_time, low_leg_top)
            line.set_color(sess.low_line_left, col)
            line.set_width(sess.low_line_left, width)
            line.set_style(sess.low_line_left, lineStyle)
            
        // Right vertical tip (only drawn when session is completed)
        if not active
            if na(sess.low_line_right)
                sess.low_line_right := line.new(endT, low_level, endT, low_leg_top, xloc=xloc.bar_time, color=col, width=width, style=lineStyle)
            else
                line.set_xy1(sess.low_line_right, endT, low_level)
                line.set_xy2(sess.low_line_right, endT, low_leg_top)
                line.set_color(sess.low_line_right, col)
                line.set_width(sess.low_line_right, width)
                line.set_style(sess.low_line_right, lineStyle)
        else
            if not na(sess.low_line_right)
                line.delete(sess.low_line_right)
                sess.low_line_right := na
            
        // Dotted Projections (Low Bracket)
        if draw_proj
            if na(sess.low_proj_left)
                sess.low_proj_left := line.new(sess.start_time, low_leg_top, sess.start_time, sess.start_low, xloc=xloc.bar_time, color=col, width=width, style=line.style_dotted)
            else
                line.set_xy1(sess.low_proj_left, sess.start_time, low_leg_top)
                line.set_xy2(sess.low_proj_left, sess.start_time, sess.start_low)
                line.set_color(sess.low_proj_left, col)
                line.set_width(sess.low_proj_left, width)
                
            // Right projection (only drawn when session is completed)
            if not active
                if na(sess.low_proj_right)
                    sess.low_proj_right := line.new(endT, low_leg_top, endT, sess.end_low, xloc=xloc.bar_time, color=col, width=width, style=line.style_dotted)
                else
                    line.set_xy1(sess.low_proj_right, endT, low_leg_top)
                    line.set_xy2(sess.low_proj_right, endT, sess.end_low)
                    line.set_color(sess.low_proj_right, col)
                    line.set_width(sess.low_proj_right, width)
            else
                if not na(sess.low_proj_right)
                    line.delete(sess.low_proj_right)
                    sess.low_proj_right := na
        else
            if not na(sess.low_proj_left)
                line.delete(sess.low_proj_left)
                sess.low_proj_left := na
            if not na(sess.low_proj_right)
                line.delete(sess.low_proj_right)
                sess.low_proj_right := na

        // Centered stacked labels (Low)
        if show_lbl
            string display_text = show_tm ? "MACRO\n" + name : "MACRO"
            if na(sess.low_lbl)
                sess.low_lbl := label.new(math.round((sess.start_time + endT) / 2), low_level, display_text, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=lbl_col, style=label.style_label_up, size=lblSize)
            
            label.set_xy(sess.low_lbl, math.round((sess.start_time + endT) / 2), low_level)
            label.set_text(sess.low_lbl, display_text)
            label.set_textcolor(sess.low_lbl, lbl_col)
            label.set_size(sess.low_lbl, lblSize)
            label.delete(na)
        else
            if not na(sess.low_lbl)
                label.delete(sess.low_lbl)
                sess.low_lbl := na
            label.delete(na)
    else
        // Clean up low drawings if disabled
        if not na(sess.low_line_btm)
            line.delete(sess.low_line_btm)
            sess.low_line_btm := na
        if not na(sess.low_line_left)
            line.delete(sess.low_line_left)
            sess.low_line_left := na
        if not na(sess.low_line_right)
            line.delete(sess.low_line_right)
            sess.low_line_right := na
        if not na(sess.low_proj_left)
            line.delete(sess.low_proj_left)
            sess.low_proj_left := na
        if not na(sess.low_proj_right)
            line.delete(sess.low_proj_right)
            sess.low_proj_right := na
        if not na(sess.low_lbl)
            label.delete(sess.low_lbl)
            sess.low_lbl := na
        label.delete(na)

// =========================================================================
// 4. Utility & Time Processing Functions
// =========================================================================

// Convert UTC offsets to GMT for compatibility with Pine Script's native time functions
cleanTimezone(string tz) =>
    string cleanTz = str.replace_all(tz, "UTC", "GMT")
    cleanTz := str.replace_all(cleanTz, " ", "")
    cleanTz

// Fetch the start and end timestamp of a session for the current bar
getSessionTimes(string sessionTime, string tz) =>
    int startHr  = int(str.tonumber(str.substring(sessionTime, 0, 2)))
    int startMin = int(str.tonumber(str.substring(sessionTime, 2, 4)))
    int endHr    = int(str.tonumber(str.substring(sessionTime, 5, 7)))
    int endMin   = int(str.tonumber(str.substring(sessionTime, 7, 9)))
    
    // Check if session crosses midnight
    bool crosses_midnight = (endHr < startHr) or (endHr == startHr and endMin < startMin)
    
    // Determine the base time to extract the calendar date
    int base_time = time
    if crosses_midnight
        int currHr = hour(time, tz)
        int currMin = minute(time, tz)
        bool is_post_midnight = (currHr < endHr) or (currHr == endHr and currMin < endMin)
        if is_post_midnight
            base_time := time - 86400000 // Shift back by 24 hours to use yesterday's date
            
    int y = year(base_time, tz)
    int m = month(base_time, tz)
    int d = dayofmonth(base_time, tz)
    
    int startTimeMs = timestamp(tz, y, m, d, startHr, startMin, 0)
    int endTimeMs   = timestamp(tz, y, m, d, endHr, endMin, 0)
    
    if endTimeMs <= startTimeMs
        endTimeMs := endTimeMs + 86400000 // Add 24 hours in milliseconds
        
    [startTimeMs, endTimeMs]

// Calculate timeframe in minutes
tfInMinutes() =>
    int tfMultiplier = timeframe.multiplier
    int timeframeInMinutes = 
      timeframe.isseconds ? 0 :
      timeframe.isminutes ? tfMultiplier :
      timeframe.isdaily   ? tfMultiplier * 1440 :
      timeframe.isweekly  ? tfMultiplier * 10080 :
      timeframe.ismonthly ? tfMultiplier * 43200 : 999999
    timeframeInMinutes

// =========================================================================
// 5. Macro Core Engine & Drawing Execution
// =========================================================================

tz = cleanTimezone(timezoneInput)

// Auto-hide indicator if chart timeframe is above the specified limit
showIndicator = tfInMinutes() <= hideAboveInput

// Date range filters
var int msInDay = 86400000
y_now = year(last_bar_time, tz)
m_now = month(last_bar_time, tz)
d_now = dayofmonth(last_bar_time, tz)
today_start = timestamp(tz, y_now, m_now, d_now, 0, 0, 0)

withinTimeFilter = time >= (today_start - history_limit_days * msInDay)

// Maintain active arrays of session drawings
var MacroTrackerState[] trackers = array.new<MacroTrackerState>()
var MacroSession[] all_sessions = array.new<MacroSession>()

// Calculate 15-minute lookback length in terms of chart bars
lookback_len = math.max(1, math.round(900 / timeframe.in_seconds()))
rolling_highest = ta.highest(high, lookback_len)
rolling_lowest  = ta.lowest(low, lookback_len)

// Initialize trackers on the first bar
if barstate.isfirst
    // AM Macros
    array.push(trackers, MacroTrackerState.new("0750-0810", show_m1, "7:50 - 8:10", na, na))
    array.push(trackers, MacroTrackerState.new("0850-0910", show_m2, "8:50 - 9:10", na, na))
    array.push(trackers, MacroTrackerState.new("0950-1010", show_m3, "9:50 - 10:10", na, na))
    array.push(trackers, MacroTrackerState.new("1050-1110", show_m4, "10:50 - 11:10", na, na))
    
    // PM Macros
    array.push(trackers, MacroTrackerState.new("1150-1210", show_p1, "11:50 - 12:10", na, na))
    array.push(trackers, MacroTrackerState.new("1250-1310", show_p2, "12:50 - 13:10", na, na))
    array.push(trackers, MacroTrackerState.new("1350-1410", show_p3, "13:50 - 14:10", na, na))
    array.push(trackers, MacroTrackerState.new("1450-1510", show_p4, "14:50 - 15:10", na, na))
    array.push(trackers, MacroTrackerState.new("1515-1545", show_p5, "15:15 - 15:45", na, na))
    array.push(trackers, MacroTrackerState.new("1550-1610", show_p6, "15:50 - 16:10", na, na))
    
    // Overnight / London Macros
    array.push(trackers, MacroTrackerState.new("2350-0010", show_o1, "23:50 - 0:10", na, na))
    array.push(trackers, MacroTrackerState.new("0050-0110", show_o2, "0:50 - 1:10", na, na))
    array.push(trackers, MacroTrackerState.new("0150-0210", show_o3, "1:50 - 2:10", na, na))
    array.push(trackers, MacroTrackerState.new("0250-0310", show_o4, "2:50 - 3:10", na, na))
    array.push(trackers, MacroTrackerState.new("0350-0410", show_o5, "3:50 - 4:10", na, na))
    array.push(trackers, MacroTrackerState.new("0450-0510", show_o6, "4:50 - 5:10", na, na))
    array.push(trackers, MacroTrackerState.new("0550-0610", show_o7, "5:50 - 6:10", na, na))
    array.push(trackers, MacroTrackerState.new("0650-0710", show_o8, "6:50 - 7:10", na, na))
    
    // Evening Macros
    array.push(trackers, MacroTrackerState.new("1650-1710", show_e1, "16:50 - 17:10", na, na))
    array.push(trackers, MacroTrackerState.new("1750-1810", show_e2, "17:50 - 18:10", na, na))
    array.push(trackers, MacroTrackerState.new("1850-1910", show_e3, "18:50 - 19:10", na, na))
    array.push(trackers, MacroTrackerState.new("1950-2010", show_e4, "19:50 - 20:10", na, na))
    array.push(trackers, MacroTrackerState.new("2050-2110", show_e5, "20:50 - 21:10", na, na))
    array.push(trackers, MacroTrackerState.new("2150-2210", show_e6, "21:50 - 22:10", na, na))
    array.push(trackers, MacroTrackerState.new("2250-2310", show_e7, "22:50 - 23:10", na, na))

// Process all trackers on every bar
if showIndicator and withinTimeFilter
    for i = 0 to array.size(trackers) - 1
        MacroTrackerState t = array.get(trackers, i)
        if t.active_input
            // Check if current bar is inside this macro time window
            bool in_sess = not na(time(timeframe.period, t.sess_time, tz))
            
            if in_sess
                [startTimeMs, endTimeMs] = getSessionTimes(t.sess_time, tz)
                
                // If a new session starts
                if na(t.last_start_time) or startTimeMs != t.last_start_time
                    t.last_start_time := startTimeMs
                    
                    // Dynamic 15-minute lookback baseline initialization
                    float start_one_high = rolling_highest + syminfo.mintick * 10
                    float start_one_low = rolling_lowest - syminfo.mintick * 10
                    
                    t.active_sess := MacroSession.new(
                         high_line_top=na, high_line_left=na, high_line_right=na,
                         high_proj_left=na, high_proj_right=na, high_lbl=na,
                         low_line_btm=na, low_line_left=na, low_line_right=na,
                         low_proj_left=na, low_proj_right=na, low_lbl=na,
                         start_time=startTimeMs, end_time=endTimeMs,
                         high_baseline=start_one_high, low_baseline=start_one_low,
                         start_high=high, start_low=low,
                         end_high=high, end_low=low,
                         is_completed=false
                      )
                    array.push(all_sessions, t.active_sess)
                    
                    // Memory optimization: Prune old drawings at hardcoded max threshold of 500
                    if array.size(all_sessions) > 500
                        MacroSession oldest = array.shift(all_sessions)
                        oldest.clean()
                        
                // Update currently active session values
                if not na(t.active_sess)
                    t.active_sess.high_baseline := math.max(t.active_sess.high_baseline, high + syminfo.mintick * 10)
                    t.active_sess.low_baseline := math.min(t.active_sess.low_baseline, low - syminfo.mintick * 10)
                    t.active_sess.end_high := high
                    t.active_sess.end_low := low
                    t.active_sess.draw_or_update(true, macro_color, macro_width, macro_style, show_labels, show_time, t.label_name, bracket_mode, show_projections, lbl_color, lbl_size_input)
            
            // Check if active session just completed
            if not na(t.active_sess) and not t.active_sess.is_completed and time >= t.active_sess.end_time
                t.active_sess.is_completed := true
                t.active_sess.draw_or_update(false, macro_color, macro_width, macro_style, show_labels, show_time, t.label_name, bracket_mode, show_projections, lbl_color, lbl_size_input)
                t.active_sess := na
````

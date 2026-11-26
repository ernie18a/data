# Multi PPO

- url: https://www.tradingview.com/script/kGZ9SVPh-Multi-PPO/
- type: indicator
- pine_id: PUB;25c5c7a9dd974a5bb95857917948dc30
- version: 1.0

## Description

v3.8 — Extended label background

  • New input: "Extended Label Background" — color picker for the label
    bg. Default matches TradingView dark theme (#131722, fully opaque).
    Set transparency to 100 if you prefer the line to show through.
  • Pivot labels are unchanged (they already sit cleanly past the
    period end, no overlap to mask).

  If you're on a light theme, change the Extended Label Background
  input to white (or any color matching your chart background).

## Source Code

````pine
//@version=6
indicator("Multi PPO", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ═══ TIMEFRAME SELECTION ═══
show_daily_pivots = input.bool(true, "Show Daily Pivots", group="Timeframe Selection")
show_weekly_pivots = input.bool(true, "Show Weekly Pivots", group="Timeframe Selection")
show_monthly_pivots = input.bool(true, "Show Monthly Pivots", group="Timeframe Selection")
show_quarterly_pivots = input.bool(false, "Show Quarterly Pivots", group="Timeframe Selection")
show_sixmonth_pivots = input.bool(false, "Show Six-Month Pivots", group="Timeframe Selection")
show_yearly_pivots = input.bool(true, "Show Yearly Pivots", group="Timeframe Selection")

show_prev_day = input.bool(true, "Show Previous Day Levels", group="Timeframe Selection")
show_prev_week = input.bool(true, "Show Previous Week Levels", group="Timeframe Selection")
show_prev_month = input.bool(true, "Show Previous Month Levels", group="Timeframe Selection")

show_daily_open = input.bool(false, "Show Daily Open", group="Timeframe Selection")
show_weekly_open = input.bool(true, "Show Weekly Open", group="Timeframe Selection")
show_monthly_open = input.bool(true, "Show Monthly Open", group="Timeframe Selection")
show_quarterly_open = input.bool(false, "Show Quarterly Open", group="Timeframe Selection")
show_sixmonth_open = input.bool(false, "Show Six-Month Open", group="Timeframe Selection")
show_yearly_open = input.bool(true, "Show Yearly Open", group="Timeframe Selection")

// ═══ PIVOT SETTINGS ═══
pivot_levels = input.int(0, "Number of S/R Levels", minval=0, maxval=5, group="Pivot Settings")
pivot_periods_back = input.int(1, "Number of Periods Back", minval=1, maxval=3, group="Pivot Settings", tooltip="Show pivots from multiple previous periods (1=most recent only)")
daily_pivot_color = input.color(color.new(color.orange, 30), "Daily Pivot Color", group="Pivot Settings")
weekly_pivot_color = input.color(color.new(color.purple, 30), "Weekly Pivot Color", group="Pivot Settings")
monthly_pivot_color = input.color(color.new(color.green, 30), "Monthly Pivot Color", group="Pivot Settings")
quarterly_pivot_color = input.color(color.new(#FF4500, 30), "Quarterly Pivot Color", group="Pivot Settings")
sixmonth_pivot_color = input.color(color.new(color.blue, 30), "Six-Month Pivot Color", group="Pivot Settings")
yearly_pivot_color = input.color(color.new(color.aqua, 30), "Yearly Pivot Color", group="Pivot Settings")
pivot_line_width = input.int(2, "Pivot Line Width", minval=1, maxval=4, group="Pivot Settings")
pivot_line_style = input.string("Solid", "Pivot Line Style", options=["Solid", "Dashed", "Dotted"], group="Pivot Settings")

// ═══ PREVIOUS PERIOD SETTINGS ═══
prev_day_color = input.color(color.new(color.gray, 40), "Previous Day Color", group="Previous Period Settings")
prev_week_color = input.color(color.new(color.gray, 40), "Previous Week Color", group="Previous Period Settings")
prev_month_color = input.color(color.new(color.gray, 40), "Previous Month Color", group="Previous Period Settings")
prev_line_width = input.int(2, "Previous Level Line Width", minval=1, maxval=4, group="Previous Period Settings")
show_prev_backgrounds = input.bool(true, "Show Background Zones", group="Previous Period Settings", tooltip="Background opacity set to 5%")

// ═══ PERIOD OPEN SETTINGS ═══
daily_open_color = input.color(color.new(color.orange, 20), "Daily Open Color", group="Period Open Settings")
weekly_open_color = input.color(color.new(color.purple, 20), "Weekly Open Color", group="Period Open Settings")
monthly_open_color = input.color(color.new(color.green, 20), "Monthly Open Color", group="Period Open Settings")
quarterly_open_color = input.color(color.new(#FF4500, 20), "Quarterly Open Color", group="Period Open Settings")
sixmonth_open_color = input.color(color.new(color.blue, 20), "Six-Month Open Color", group="Period Open Settings")
yearly_open_color = input.color(color.new(color.aqua, 20), "Yearly Open Color", group="Period Open Settings")
open_line_width = input.int(1, "Open Line Width", minval=1, maxval=4, group="Period Open Settings")
open_line_style = input.string("Dashed", "Open Line Style", options=["Solid", "Dashed", "Dotted"], group="Period Open Settings")

// ═══ SIGNAL DISPLAY ═══
show_inside_bar_marker = input.bool(true, "Show Inside Bar Marker", group="Signal Display", tooltip="Shows a circle marker next to previous period labels when that period was an inside bar (range stayed within the period before it) - indicates consolidation")
show_untested_pivot_marker = input.bool(true, "Show Untested Pivot Marker", group="Signal Display", tooltip="Shows a circle marker next to current pivot labels when both the previous period's pivot and current pivot haven't been touched - indicates untested level")
consecutive_marker_count = input.int(3, "Max Consecutive Dots", minval=1, maxval=5, group="Signal Display", tooltip="Maximum number of dots to show for consecutive untapped pivots / inside bars (e.g., 3 = up to ●●● for 3 in a row)")

// ═══ STATISTICS ═══
show_tap_percentages = input.bool(true, "Show Tap Percentages", group="Statistics", tooltip="Append (XX%) to pivot labels showing the % of recent pivots that were tapped, and to previous period EQ labels showing the % that were NOT inside bars (breakout rate)")
stats_lookback_periods = input.int(10, "Stats Lookback Periods", minval=1, maxval=20, group="Statistics", tooltip="Number of recent completed periods to use when computing tap/breakout percentages")
pct_show_only_with_marker = input.bool(false, "Show % Only With Marker", group="Statistics", tooltip="If enabled, percentages appear only when the dot marker is present. If disabled, percentages always show.")

// ═══ VISUAL SETTINGS ═══
show_level_labels = input.bool(true, "Show Level Labels", group="Visual Settings")
label_size = input.string("normal", "Label Size", options=["tiny", "small", "normal", "large"], group="Visual Settings")
label_offset = input.int(40, "Label Offset (bars)", minval=0, maxval=500, group="Visual Settings", tooltip="Number of bars to offset labels to the right of current bar (applies to opens and previous period levels only)")
extended_label_bg_color = input.color(color.new(#131722, 0), "Extended Label Background", group="Visual Settings", tooltip="Background color for extended-level labels (opens, prev periods). An opaque background hides the line behind the label so the text reads cleanly. Default matches TradingView's dark theme bg. Set transparency to 100 for no background (line will strike through text again).")
pivot_end_tick_pct = input.float(0.15, "Pivot End Marker Size (%)", minval=0.0, maxval=2.0, step=0.05, group="Visual Settings", tooltip="When a pivot is merged with extended levels (opens, prev periods), a vertical tick mark is drawn at the pivot's period end using the pivot's color. Height = this % of price (total, split above and below the line). Set to 0 to disable.")

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Convert line style string to Pine constant (for future use with line objects)
// Note: plot() only supports solid lines, so this is reserved for potential line.new() implementations
getLineStyle(style) =>
    style == "Dashed" ? line.style_dashed : style == "Dotted" ? line.style_dotted : line.style_solid

// Get label size constant
getLabelSize(size) =>
    size == "tiny" ? size.tiny : size == "small" ? size.small : size == "normal" ? size.normal : size.large

// Adjust color transparency
adjustTransparency(base_color, new_transp) =>
    color.new(color.rgb(color.r(base_color), color.g(base_color), color.b(base_color)), new_transp)

// Build a string of N dot characters followed by a trailing space (for label prefixes)
// Returns "" when count <= 0
makeDots(int count) =>
    result = ""
    if count > 0
        for i = 1 to count
            result := result + "●"
        result := result + " "
    result

// Count consecutive matching entries in an int history array starting from the most
// recent (end of array) going backward. Stops at first non-match or after max_count.
// History arrays store 0/1 ints (1 = condition true, 0 = condition false).
countConsecutiveFromEnd(array<int> hist, int target, int max_count) =>
    int count = 0
    int sz = array.size(hist)
    if sz > 0 and max_count > 0
        int i = sz - 1
        while i >= 0 and count < max_count
            if array.get(hist, i) == target
                count := count + 1
                i := i - 1
            else
                break
    count

// Compute percentage of entries equal to target_value in the last `lookback` items.
// Returns na when array is empty. Result is rounded to nearest integer 0-100.
computePct(array<int> hist, int target, int lookback) =>
    int sz = array.size(hist)
    int window = math.min(sz, lookback)
    float result = na
    if window > 0
        int matches = 0
        int start_i = sz - window
        for i = start_i to sz - 1
            if array.get(hist, i) == target
                matches := matches + 1
        result := math.round(matches * 100.0 / window)
    result

// Calculate time offset in milliseconds based on current timeframe and bar count
// Used to position labels to the right of the current bar
getTimeOffset(bars) =>
    if bars == 0
        0
    else
        // Get the current timeframe in milliseconds
        // timeframe.in_seconds() returns the timeframe duration in seconds
        timeframe.in_seconds() * 1000 * bars

// Calculate Standard Pivots
calcPivot(hi, lo, cl) =>
    (hi + lo + cl) / 3

calcR1(pivot, hi, lo) =>
    2 * pivot - lo

calcS1(pivot, hi, lo) =>
    2 * pivot - hi

calcR2(pivot, hi, lo) =>
    pivot + (hi - lo)

calcS2(pivot, hi, lo) =>
    pivot - (hi - lo)

calcR3(pivot, hi, lo) =>
    hi + 2 * (pivot - lo)

calcS3(pivot, hi, lo) =>
    lo - 2 * (hi - pivot)

calcR4(pivot, hi, lo) =>
    pivot + (hi - lo) * 1.5

calcS4(pivot, hi, lo) =>
    pivot - (hi - lo) * 1.5

calcR5(pivot, hi, lo) =>
    pivot + (hi - lo) * 2

calcS5(pivot, hi, lo) =>
    pivot - (hi - lo) * 2

// ═══════════════════════════════════════════════════════════════════════════════
// PIVOT HIT TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

// Track whether current period's pivot point has been hit
var bool daily_pivot_hit = false
var bool weekly_pivot_hit = false
var bool monthly_pivot_hit = false
var bool quarterly_pivot_hit = false
var bool sixmonth_pivot_hit = false
var bool yearly_pivot_hit = false

// Track whether previous period's pivot was hit (for marking current pivot)
var bool prev_daily_pivot_was_hit = false
var bool prev_weekly_pivot_was_hit = false
var bool prev_monthly_pivot_was_hit = false
var bool prev_quarterly_pivot_was_hit = false
var bool prev_sixmonth_pivot_was_hit = false
var bool prev_yearly_pivot_was_hit = false

// ═══════════════════════════════════════════════════════════════════════════════
// HISTORY ARRAYS FOR STATS (capped at MAX_HISTORY = 20)
// ═══════════════════════════════════════════════════════════════════════════════
// Each entry is 1 (condition true) or 0 (condition false) for the period that just ended.
// Most recent entries are at the end of the array.

// Pivot tap history: 1 = the just-ended period's pivot was tapped, 0 = untapped
var int[] daily_pivot_hit_history = array.new<int>()
var int[] weekly_pivot_hit_history = array.new<int>()
var int[] monthly_pivot_hit_history = array.new<int>()
var int[] quarterly_pivot_hit_history = array.new<int>()
var int[] sixmonth_pivot_hit_history = array.new<int>()
var int[] yearly_pivot_hit_history = array.new<int>()

// Inside-bar history: 1 = the just-ended period was an inside bar (within prior period), 0 = not
var int[] inside_bar_history_day = array.new<int>()
var int[] inside_bar_history_week = array.new<int>()
var int[] inside_bar_history_month = array.new<int>()

// Helper: push an entry and cap array at 20 elements (drop oldest from front)
pushHistory(array<int> hist, int value) =>
    array.push(hist, value)
    if array.size(hist) > 20
        array.shift(hist)

// Flags to skip the very first period transition for each timeframe (partial-period noise)
var bool daily_history_started = false
var bool weekly_history_started = false
var bool monthly_history_started = false
var bool quarterly_history_started = false
var bool sixmonth_history_started = false
var bool yearly_history_started = false

var bool inside_history_day_started = false
var bool inside_history_week_started = false
var bool inside_history_month_started = false

// ═══════════════════════════════════════════════════════════════════════════════
// GET HTF DATA
// ═══════════════════════════════════════════════════════════════════════════════

// Track period changes to know when to start drawing lines
var int prev_day_start_bar = na
var int prev_week_start_bar = na
var int prev_month_start_bar = na

// Track additional periods back for pivot history
var int prev_day_start_bar_2 = na
var int prev_day_start_bar_3 = na
var int prev_week_start_bar_2 = na
var int prev_week_start_bar_3 = na
var int prev_month_start_bar_2 = na
var int prev_month_start_bar_3 = na
var int prev_quarter_start_bar = na
var int prev_quarter_start_bar_2 = na
var int prev_quarter_start_bar_3 = na
var int prev_sixmonth_start_bar = na
var int prev_sixmonth_start_bar_2 = na
var int prev_sixmonth_start_bar_3 = na
var int prev_year_start_bar = na
var int prev_year_start_bar_2 = na
var int prev_year_start_bar_3 = na

var int day_start_bar = na
var int week_start_bar = na
var int month_start_bar = na
var int quarter_start_bar = na
var int sixmonth_start_bar = na
var int year_start_bar = na

var int day_end_bar = na
var int week_end_bar = na
var int month_end_bar = na
var int quarter_end_bar = na
var int sixmonth_end_bar = na
var int year_end_bar = na

// Time tracking variables for time-based drawing (bypasses bar index buffer limits)
var int day_start_time = na
var int week_start_time = na
var int month_start_time = na
var int quarter_start_time = na
var int sixmonth_start_time = na
var int year_start_time = na

// Previous period start times (for previous period levels)
var int prev_day_start_time = na
var int prev_week_start_time = na
var int prev_month_start_time = na

// Historical period start times (for multi-period pivot history)
var int prev_day_start_time_2 = na
var int prev_day_start_time_3 = na
var int prev_week_start_time_2 = na
var int prev_week_start_time_3 = na
var int prev_month_start_time_2 = na
var int prev_month_start_time_3 = na
var int prev_quarter_start_time = na
var int prev_quarter_start_time_2 = na
var int prev_quarter_start_time_3 = na
var int prev_sixmonth_start_time = na
var int prev_sixmonth_start_time_2 = na
var int prev_sixmonth_start_time_3 = na
var int prev_year_start_time = na
var int prev_year_start_time_2 = na
var int prev_year_start_time_3 = na

// Initialize start bars on first bar
if barstate.isfirst
    day_start_bar := bar_index
    week_start_bar := bar_index
    month_start_bar := bar_index
    quarter_start_bar := bar_index
    sixmonth_start_bar := bar_index
    year_start_bar := bar_index
    // Initialize time tracking
    day_start_time := time
    week_start_time := time
    month_start_time := time
    quarter_start_time := time
    sixmonth_start_time := time
    year_start_time := time

// Detect period changes and track both current and previous period starts
if ta.change(time("D")) != 0
    day_end_bar := bar_index - 1        // Previous bar is end of old period
    // Shift history back
    prev_day_start_bar_3 := prev_day_start_bar_2
    prev_day_start_bar_2 := prev_day_start_bar
    prev_day_start_bar := day_start_bar  // Save previous period start
    day_start_bar := bar_index           // Update to current period start
    // Update time tracking
    prev_day_start_time_3 := prev_day_start_time_2
    prev_day_start_time_2 := prev_day_start_time
    prev_day_start_time := day_start_time
    day_start_time := time
    // Save pivot hit status and reset
    // Push to history BEFORE reset (skip first transition - partial period)
    if daily_history_started
        pushHistory(daily_pivot_hit_history, daily_pivot_hit ? 1 : 0)
    daily_history_started := true
    prev_daily_pivot_was_hit := daily_pivot_hit
    daily_pivot_hit := false
if ta.change(time("W")) != 0
    week_end_bar := bar_index - 1
    // Shift history back
    prev_week_start_bar_3 := prev_week_start_bar_2
    prev_week_start_bar_2 := prev_week_start_bar
    prev_week_start_bar := week_start_bar
    week_start_bar := bar_index
    // Update time tracking
    prev_week_start_time_3 := prev_week_start_time_2
    prev_week_start_time_2 := prev_week_start_time
    prev_week_start_time := week_start_time
    week_start_time := time
    // Save pivot hit status and reset
    if weekly_history_started
        pushHistory(weekly_pivot_hit_history, weekly_pivot_hit ? 1 : 0)
    weekly_history_started := true
    prev_weekly_pivot_was_hit := weekly_pivot_hit
    weekly_pivot_hit := false
if ta.change(time("M")) != 0
    month_end_bar := bar_index - 1
    // Shift history back
    prev_month_start_bar_3 := prev_month_start_bar_2
    prev_month_start_bar_2 := prev_month_start_bar
    prev_month_start_bar := month_start_bar
    month_start_bar := bar_index
    // Update time tracking for time-based drawing
    prev_month_start_time_3 := prev_month_start_time_2
    prev_month_start_time_2 := prev_month_start_time
    prev_month_start_time := month_start_time
    month_start_time := time
    // Save pivot hit status and reset
    if monthly_history_started
        pushHistory(monthly_pivot_hit_history, monthly_pivot_hit ? 1 : 0)
    monthly_history_started := true
    prev_monthly_pivot_was_hit := monthly_pivot_hit
    monthly_pivot_hit := false
if ta.change(time("3M")) != 0
    quarter_end_bar := bar_index - 1
    // Shift history back
    prev_quarter_start_bar_3 := prev_quarter_start_bar_2
    prev_quarter_start_bar_2 := prev_quarter_start_bar
    prev_quarter_start_bar := quarter_start_bar
    quarter_start_bar := bar_index
    // Update time tracking
    prev_quarter_start_time_3 := prev_quarter_start_time_2
    prev_quarter_start_time_2 := prev_quarter_start_time
    prev_quarter_start_time := quarter_start_time
    quarter_start_time := time
    // Save pivot hit status and reset
    if quarterly_history_started
        pushHistory(quarterly_pivot_hit_history, quarterly_pivot_hit ? 1 : 0)
    quarterly_history_started := true
    prev_quarterly_pivot_was_hit := quarterly_pivot_hit
    quarterly_pivot_hit := false
if ta.change(time("6M")) != 0
    sixmonth_end_bar := bar_index - 1
    // Shift history back
    prev_sixmonth_start_bar_3 := prev_sixmonth_start_bar_2
    prev_sixmonth_start_bar_2 := prev_sixmonth_start_bar
    prev_sixmonth_start_bar := sixmonth_start_bar
    sixmonth_start_bar := bar_index
    // Update time tracking
    prev_sixmonth_start_time_3 := prev_sixmonth_start_time_2
    prev_sixmonth_start_time_2 := prev_sixmonth_start_time
    prev_sixmonth_start_time := sixmonth_start_time
    sixmonth_start_time := time
    // Save pivot hit status and reset
    if sixmonth_history_started
        pushHistory(sixmonth_pivot_hit_history, sixmonth_pivot_hit ? 1 : 0)
    sixmonth_history_started := true
    prev_sixmonth_pivot_was_hit := sixmonth_pivot_hit
    sixmonth_pivot_hit := false
if ta.change(time("12M")) != 0
    year_end_bar := bar_index - 1
    // Shift history back
    prev_year_start_bar_3 := prev_year_start_bar_2
    prev_year_start_bar_2 := prev_year_start_bar
    prev_year_start_bar := year_start_bar
    year_start_bar := bar_index
    // Update time tracking
    prev_year_start_time_3 := prev_year_start_time_2
    prev_year_start_time_2 := prev_year_start_time
    prev_year_start_time := year_start_time
    year_start_time := time
    // Save pivot hit status and reset
    if yearly_history_started
        pushHistory(yearly_pivot_hit_history, yearly_pivot_hit ? 1 : 0)
    yearly_history_started := true
    prev_yearly_pivot_was_hit := yearly_pivot_hit
    yearly_pivot_hit := false

// Previous Period Data
[prev_day_high, prev_day_low, prev_day_close] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[prev_week_high, prev_week_low, prev_week_close] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[prev_month_high, prev_month_low, prev_month_close] = request.security(syminfo.tickerid, "M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// Calculate EQ levels
prev_day_eq = (prev_day_high + prev_day_low) / 2
prev_week_eq = (prev_week_high + prev_week_low) / 2
prev_month_eq = (prev_month_high + prev_month_low) / 2

// Current Period Opens
daily_open = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
weekly_open = request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
monthly_open = request.security(syminfo.tickerid, "M", open, lookahead=barmerge.lookahead_on)
quarterly_open = request.security(syminfo.tickerid, "3M", open, lookahead=barmerge.lookahead_on)
sixmonth_open = request.security(syminfo.tickerid, "6M", open, lookahead=barmerge.lookahead_on)
yearly_open = request.security(syminfo.tickerid, "12M", open, lookahead=barmerge.lookahead_on)

// Pivot Calculations - Period 1 (most recent previous period)
[daily_h, daily_l, daily_c] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[weekly_h, weekly_l, weekly_c] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[monthly_h, monthly_l, monthly_c] = request.security(syminfo.tickerid, "M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[quarterly_h, quarterly_l, quarterly_c] = request.security(syminfo.tickerid, "3M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[sixmonth_h, sixmonth_l, sixmonth_c] = request.security(syminfo.tickerid, "6M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[yearly_h, yearly_l, yearly_c] = request.security(syminfo.tickerid, "12M", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// Pivot Calculations - Period 2 (2 periods back)
[daily_h2, daily_l2, daily_c2] = request.security(syminfo.tickerid, "D", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)
[weekly_h2, weekly_l2, weekly_c2] = request.security(syminfo.tickerid, "W", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)
[monthly_h2, monthly_l2, monthly_c2] = request.security(syminfo.tickerid, "M", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)
[quarterly_h2, quarterly_l2, quarterly_c2] = request.security(syminfo.tickerid, "3M", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)
[sixmonth_h2, sixmonth_l2, sixmonth_c2] = request.security(syminfo.tickerid, "6M", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)
[yearly_h2, yearly_l2, yearly_c2] = request.security(syminfo.tickerid, "12M", [high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)

// Pivot Calculations - Period 3 (3 periods back)
[daily_h3, daily_l3, daily_c3] = request.security(syminfo.tickerid, "D", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)
[weekly_h3, weekly_l3, weekly_c3] = request.security(syminfo.tickerid, "W", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)
[monthly_h3, monthly_l3, monthly_c3] = request.security(syminfo.tickerid, "M", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)
[quarterly_h3, quarterly_l3, quarterly_c3] = request.security(syminfo.tickerid, "3M", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)
[sixmonth_h3, sixmonth_l3, sixmonth_c3] = request.security(syminfo.tickerid, "6M", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)
[yearly_h3, yearly_l3, yearly_c3] = request.security(syminfo.tickerid, "12M", [high[3], low[3], close[3]], lookahead=barmerge.lookahead_on)

// Daily Pivots
daily_pivot = calcPivot(daily_h, daily_l, daily_c)
daily_r1 = calcR1(daily_pivot, daily_h, daily_l)
daily_s1 = calcS1(daily_pivot, daily_h, daily_l)
daily_r2 = calcR2(daily_pivot, daily_h, daily_l)
daily_s2 = calcS2(daily_pivot, daily_h, daily_l)
daily_r3 = calcR3(daily_pivot, daily_h, daily_l)
daily_s3 = calcS3(daily_pivot, daily_h, daily_l)
daily_r4 = calcR4(daily_pivot, daily_h, daily_l)
daily_s4 = calcS4(daily_pivot, daily_h, daily_l)
daily_r5 = calcR5(daily_pivot, daily_h, daily_l)
daily_s5 = calcS5(daily_pivot, daily_h, daily_l)

// Weekly Pivots
weekly_pivot = calcPivot(weekly_h, weekly_l, weekly_c)
weekly_r1 = calcR1(weekly_pivot, weekly_h, weekly_l)
weekly_s1 = calcS1(weekly_pivot, weekly_h, weekly_l)
weekly_r2 = calcR2(weekly_pivot, weekly_h, weekly_l)
weekly_s2 = calcS2(weekly_pivot, weekly_h, weekly_l)
weekly_r3 = calcR3(weekly_pivot, weekly_h, weekly_l)
weekly_s3 = calcS3(weekly_pivot, weekly_h, weekly_l)
weekly_r4 = calcR4(weekly_pivot, weekly_h, weekly_l)
weekly_s4 = calcS4(weekly_pivot, weekly_h, weekly_l)
weekly_r5 = calcR5(weekly_pivot, weekly_h, weekly_l)
weekly_s5 = calcS5(weekly_pivot, weekly_h, weekly_l)

// Monthly Pivots
monthly_pivot = calcPivot(monthly_h, monthly_l, monthly_c)
monthly_r1 = calcR1(monthly_pivot, monthly_h, monthly_l)
monthly_s1 = calcS1(monthly_pivot, monthly_h, monthly_l)
monthly_r2 = calcR2(monthly_pivot, monthly_h, monthly_l)
monthly_s2 = calcS2(monthly_pivot, monthly_h, monthly_l)
monthly_r3 = calcR3(monthly_pivot, monthly_h, monthly_l)
monthly_s3 = calcS3(monthly_pivot, monthly_h, monthly_l)
monthly_r4 = calcR4(monthly_pivot, monthly_h, monthly_l)
monthly_s4 = calcS4(monthly_pivot, monthly_h, monthly_l)
monthly_r5 = calcR5(monthly_pivot, monthly_h, monthly_l)
monthly_s5 = calcS5(monthly_pivot, monthly_h, monthly_l)

// Quarterly Pivots
quarterly_pivot = calcPivot(quarterly_h, quarterly_l, quarterly_c)
quarterly_r1 = calcR1(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_s1 = calcS1(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_r2 = calcR2(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_s2 = calcS2(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_r3 = calcR3(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_s3 = calcS3(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_r4 = calcR4(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_s4 = calcS4(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_r5 = calcR5(quarterly_pivot, quarterly_h, quarterly_l)
quarterly_s5 = calcS5(quarterly_pivot, quarterly_h, quarterly_l)

// Six-Month Pivots
sixmonth_pivot = calcPivot(sixmonth_h, sixmonth_l, sixmonth_c)
sixmonth_r1 = calcR1(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_s1 = calcS1(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_r2 = calcR2(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_s2 = calcS2(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_r3 = calcR3(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_s3 = calcS3(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_r4 = calcR4(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_s4 = calcS4(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_r5 = calcR5(sixmonth_pivot, sixmonth_h, sixmonth_l)
sixmonth_s5 = calcS5(sixmonth_pivot, sixmonth_h, sixmonth_l)

// Yearly Pivots
yearly_pivot = calcPivot(yearly_h, yearly_l, yearly_c)
yearly_r1 = calcR1(yearly_pivot, yearly_h, yearly_l)
yearly_s1 = calcS1(yearly_pivot, yearly_h, yearly_l)
yearly_r2 = calcR2(yearly_pivot, yearly_h, yearly_l)
yearly_s2 = calcS2(yearly_pivot, yearly_h, yearly_l)
yearly_r3 = calcR3(yearly_pivot, yearly_h, yearly_l)
yearly_s3 = calcS3(yearly_pivot, yearly_h, yearly_l)
yearly_r4 = calcR4(yearly_pivot, yearly_h, yearly_l)
yearly_s4 = calcS4(yearly_pivot, yearly_h, yearly_l)
yearly_r5 = calcR5(yearly_pivot, yearly_h, yearly_l)
yearly_s5 = calcS5(yearly_pivot, yearly_h, yearly_l)

// ═══════════════════════════════════════════════════════════════════════════════
// DETECT PIVOT HITS
// ═══════════════════════════════════════════════════════════════════════════════

// Check if current bar touches each pivot point
if high >= daily_pivot and low <= daily_pivot
    daily_pivot_hit := true
if high >= weekly_pivot and low <= weekly_pivot
    weekly_pivot_hit := true
if high >= monthly_pivot and low <= monthly_pivot
    monthly_pivot_hit := true
if high >= quarterly_pivot and low <= quarterly_pivot
    quarterly_pivot_hit := true
if high >= sixmonth_pivot and low <= sixmonth_pivot
    sixmonth_pivot_hit := true
if high >= yearly_pivot and low <= yearly_pivot
    yearly_pivot_hit := true

// ═══════════════════════════════════════════════════════════════════════════════
// LEVEL GROUPING SYSTEM (for combining overlapping levels)
// ═══════════════════════════════════════════════════════════════════════════════

// User Defined Type to store level data
type LevelData
    string name          // e.g., "dPP", "pdLow"
    float price          // Level price
    color line_color     // Line color
    color label_color    // Label text color
    int line_width       // Line width
    string line_style    // "Solid", "Dashed", "Dotted"
    int start_bar        // Starting bar index
    int end_bar          // Ending bar index (or na for extended)
    bool is_extended     // true = extends right, false = period-bound
    int label_x_offset   // Label X position offset from end_bar or bar_index

// User Defined Type for time-based level data (used in grouped drawing)
type TimeBasedLevel
    string name          // e.g., "dPP", "pdLow", "wOpen"
    float price          // Level price
    int start_time       // Starting timestamp
    int end_time         // Ending timestamp (or far future for extended)
    color line_color     // Line color
    color label_color    // Label text color
    int line_width       // Line width
    int priority         // For color selection when grouping (higher = preferred)
    string suffix = ""   // Trailing text appended after price (e.g., "(72%)" for tap rate)

// Check if two prices are within 0.1% of each other
pricesMatch(price1, price2) =>
    tolerance = math.abs(price1) * 0.001  // 0.1%
    math.abs(price1 - price2) <= tolerance

// Group levels by price and draw combined levels
drawGroupedLevels(array<LevelData> levels) =>
    if array.size(levels) == 0
        bool(na)  // Return early if no levels
    else
        // Track which levels have been grouped
        var grouped = array.new_bool()
        array.clear(grouped)
        // Initialize grouped array with false for each level
        for i = 0 to array.size(levels) - 1
            array.push(grouped, false)

        // Process each level
        for i = 0 to array.size(levels) - 1
            if not array.get(grouped, i)
                level = array.get(levels, i)
                combined_name = level.name + " " + str.tostring(level.price, format.mintick)

                // Find all other levels at the same price
                if i + 1 < array.size(levels)
                    for j = i + 1 to array.size(levels) - 1
                        if not array.get(grouped, j)
                            other_level = array.get(levels, j)
                            if pricesMatch(level.price, other_level.price)
                                combined_name := combined_name + " + " + other_level.name + " " + str.tostring(other_level.price, format.mintick)
                                array.set(grouped, j, true)

                // Draw the line (only one line for all grouped levels)
                if level.is_extended
                    line.new(level.start_bar, level.price, bar_index, level.price,
                             color=level.line_color, width=level.line_width,
                             style=getLineStyle(level.line_style), extend=extend.right)
                else
                    line.new(level.start_bar, level.price, level.end_bar, level.price,
                             color=level.line_color, width=level.line_width,
                             style=getLineStyle(level.line_style), extend=extend.none)

                // Draw the combined label
                if show_level_labels
                    label_x = level.is_extended ? bar_index + level.label_x_offset : level.end_bar + level.label_x_offset
                    label.new(label_x, level.price, combined_name,
                              color=na, textcolor=level.label_color,
                              textalign=text.align_left, style=label.style_label_left,
                              size=getLabelSize(label_size))
        true

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW PIVOTS USING LINE OBJECTS
// ═══════════════════════════════════════════════════════════════════════════════

// Helper function to draw a horizontal ray (extends to the right indefinitely)
// Used for: Opens and Previous Period levels
drawExtendedLevel(y_value, level_color, width, style, start_bar) =>
    line.new(start_bar, y_value, bar_index, y_value,
             color=level_color, width=width, style=style,
             extend=extend.right)

// Helper function to draw a period-bound line (from start to end of period)
// Used for: Pivots
drawPeriodLevel(y_value, level_color, width, style, start_bar, end_bar) =>
    line.new(start_bar, y_value, end_bar, y_value,
             color=level_color, width=width, style=style,
             extend=extend.none)

// Helper function to draw a line using time coordinates (bypasses bar index buffer limits)
// Used for: All levels - pivots, opens, and previous periods
// NOTE: Pine Script has a type conflict with series-qualified style parameters
// Temporarily using solid style for all lines as a workaround
drawTimeBasedLevel(start_time, end_time, y_value, level_color, width, linestyle) =>
    line result = na
    if not na(start_time) and not na(end_time)
        // WORKAROUND: Using solid style for all lines due to Pine Script type limitations
        // TODO: Investigate why style parameter causes "series int vs series string" errors
        result := line.new(start_time, y_value, end_time, y_value, xloc=xloc.bar_time, color=level_color, width=width, style=line.style_solid)
    result

// Helper functions to calculate period end times
// These calculate the start time of the NEXT period, which is the end of the current period
getPeriodEndTime(period_start_time, period_type) =>
    int result = na
    if not na(period_start_time)
        yr = year(period_start_time)
        mo = month(period_start_time)
        dy = dayofmonth(period_start_time)

        if period_type == "D"  // Daily: add 1 day
            result := timestamp(yr, mo, dy + 1)
        else if period_type == "W"  // Weekly: add 7 days
            result := timestamp(yr, mo, dy + 7)
        else if period_type == "M"  // Monthly: add 1 month
            result := timestamp(yr, mo + 1, 1)
        else if period_type == "3M"  // Quarterly: add 3 months
            result := timestamp(yr, mo + 3, 1)
        else if period_type == "6M"  // Six-month: add 6 months
            result := timestamp(yr, mo + 6, 1)
        else if period_type == "12M"  // Yearly: add 1 year
            result := timestamp(yr + 1, 1, 1)
    result

// Arrays to track drawing objects (prevents accumulation and blurriness)
// Declared globally so they can be accessed by drawGroupedTimeLevels
var line[] all_lines = array.new<line>()
var label[] all_labels = array.new<label>()

// Classify a level as a pivot (period-bound, end_time within 1 year) vs an extended level
// (open/prev-period, end_time at far-future 10-year stamp).
isPivotLevel(TimeBasedLevel level) =>
    level.end_time <= timestamp(year(time) + 1, 1, 1)

// Strip the consecutive-dot prefix (e.g., "●● ") from a level name. Returns the bare
// identifier (e.g., "pdEQ") so per-level stat lines in merged labels don't duplicate
// dots that already appear in combined_name.
getBaseName(string name) =>
    parts = str.split(name, " ")
    array.get(parts, array.size(parts) - 1)

// Group time-based levels by price and draw combined levels
// Used by the time-based drawing system to combine overlapping levels
drawGroupedTimeLevels(array<TimeBasedLevel> levels) =>
    if array.size(levels) == 0
        bool(na)  // Return early if no levels
    else
        // Track which levels have been grouped
        var grouped = array.new_bool()
        array.clear(grouped)
        // Initialize grouped array with false for each level
        for i = 0 to array.size(levels) - 1
            array.push(grouped, false)

        // Process each level
        for i = 0 to array.size(levels) - 1
            if not array.get(grouped, i)
                level = array.get(levels, i)
                combined_name = level.name
                selected_level = level  // Start with current level

                // Track pivot levels in this group so we can mark their period-end on the merged line
                pivot_marks = array.new<TimeBasedLevel>()
                if isPivotLevel(level)
                    array.push(pivot_marks, level)

                // Track group size + per-level stats so merged labels can list each level's %
                int grouped_count = 1
                stats_parts = array.new<string>()
                if level.suffix != ""
                    array.push(stats_parts, getBaseName(level.name) + " " + level.suffix)

                // Find all other levels at the same price
                if i + 1 < array.size(levels)
                    for j = i + 1 to array.size(levels) - 1
                        if not array.get(grouped, j)
                            other_level = array.get(levels, j)
                            if pricesMatch(level.price, other_level.price)
                                combined_name := combined_name + " + " + other_level.name
                                array.set(grouped, j, true)
                                grouped_count := grouped_count + 1
                                // Use the level with highest priority for color/style
                                if other_level.priority > selected_level.priority
                                    selected_level := other_level
                                if isPivotLevel(other_level)
                                    array.push(pivot_marks, other_level)
                                if other_level.suffix != ""
                                    array.push(stats_parts, getBaseName(other_level.name) + " " + other_level.suffix)

                // Draw the line using the selected level's color (solid style)
                new_line = drawTimeBasedLevel(selected_level.start_time, selected_level.end_time,
                                              selected_level.price, selected_level.line_color,
                                              selected_level.line_width, line.style_solid)
                if not na(new_line)
                    array.push(all_lines, new_line)

                // If the merged group contains a pivot but the drawn line is an extended level
                // (so its end is hidden), draw a colored vertical tick at each pivot's period end.
                // The tick uses the pivot's own color, making the boundary visible on the merged line.
                if not isPivotLevel(selected_level) and array.size(pivot_marks) > 0 and pivot_end_tick_pct > 0
                    tick_half = selected_level.price * pivot_end_tick_pct / 100.0 / 2.0
                    for k = 0 to array.size(pivot_marks) - 1
                        pmark = array.get(pivot_marks, k)
                        tick_line = line.new(pmark.end_time, selected_level.price - tick_half,
                                             pmark.end_time, selected_level.price + tick_half,
                                             xloc=xloc.bar_time, color=pmark.line_color, width=2,
                                             style=line.style_solid)
                        array.push(all_lines, tick_line)

                // Draw the combined label with price + per-level stats
                if show_level_labels
                    string suffix_text = ""
                    if grouped_count == 1
                        // Single level: suffix is just the % value (e.g., "80%") → wrap with parens
                        if selected_level.suffix != ""
                            suffix_text := " (" + selected_level.suffix + ")"
                    else
                        // Merged: list each contributing level's stat labeled with its base name
                        // e.g., " (pdEQ 100%, dPP 60%)". Levels without a % are omitted from the list.
                        if array.size(stats_parts) > 0
                            joined = ""
                            for sp = 0 to array.size(stats_parts) - 1
                                if sp > 0
                                    joined := joined + ", "
                                joined := joined + array.get(stats_parts, sp)
                            suffix_text := " (" + joined + ")"
                    label_text = combined_name + " " + str.tostring(selected_level.price, format.mintick) + suffix_text
                    // Position pivots at their period end, extended levels with offset from current bar
                    // Pivots have end_time within 1 year, extended levels have far-future end_time
                    is_pivot = isPivotLevel(selected_level)
                    label_x_time = is_pivot ? selected_level.end_time : time + getTimeOffset(label_offset)
                    // Both pivots and extended levels use style_label_left (text centered on line).
                    // Pivots: transparent bg — line ends before the label so no strike-through.
                    // Extended levels: opaque bg covers the line behind the label text, simulating
                    // a "label in front of line" effect (Pine has no real z-index, but an opaque
                    // background achieves the same visual outcome).
                    label_bg = is_pivot ? color(na) : extended_label_bg_color
                    new_label = label.new(label_x_time, selected_level.price, label_text,
                                         xloc=xloc.bar_time, color=label_bg, textcolor=selected_level.label_color,
                                         textalign=text.align_left, style=label.style_label_left,
                                         size=getLabelSize(label_size))
                    array.push(all_labels, new_label)
        true

// Get line style
pivot_style = getLineStyle(pivot_line_style)

// Daily Pivots
if false and show_daily_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to current bar (extends through the period)
    start_bar = not na(day_start_bar) ? day_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(daily_pivot, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, daily_pivot, (show_untested_pivot_marker and not prev_daily_pivot_was_hit ? "● " : "") + "dPP " + str.tostring(daily_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_daily_pivot_was_hit ? color.orange : daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(daily_r1, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(daily_s1, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, daily_r1, "dR1 " + str.tostring(daily_r1, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, daily_s1, "dS1 " + str.tostring(daily_s1, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(daily_r2, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(daily_s2, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, daily_r2, "dR2 " + str.tostring(daily_r2, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, daily_s2, "dS2 " + str.tostring(daily_s2, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(daily_r3, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(daily_s3, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, daily_r3, "dR3 " + str.tostring(daily_r3, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, daily_s3, "dS3 " + str.tostring(daily_s3, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(daily_r4, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(daily_s4, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, daily_r4, "dR4 " + str.tostring(daily_r4, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, daily_s4, "dS4 " + str.tostring(daily_s4, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(daily_r5, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(daily_s5, daily_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, daily_r5, "dR5 " + str.tostring(daily_r5, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
            label.new(end_bar + 3, daily_s5, "dS5 " + str.tostring(daily_s5, format.mintick), color=na, textcolor=daily_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    // Additional periods (2 and 3 periods back) - with increased transparency
    if pivot_periods_back >= 2 and not na(prev_day_start_bar)
        // Calculate pivots for period 2 (yesterday's pivot)
        daily_pivot2 = calcPivot(daily_h2, daily_l2, daily_c2)
        // Draw in yesterday's timeframe: from prev_day_start_bar to day_start_bar-1
        start_bar2 = prev_day_start_bar
        end_bar2 = day_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar2 := math.max(end_bar2, start_bar2 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar2 > 0 and bar_index - start_bar2 < 350
            drawPeriodLevel(daily_pivot2, adjustTransparency(daily_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
            if show_level_labels
                label.new(end_bar2 + 3, daily_pivot2, "dPP " + str.tostring(daily_pivot2, format.mintick), color=na, textcolor=adjustTransparency(daily_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    if pivot_periods_back >= 3 and not na(prev_day_start_bar_2)
        // Calculate pivots for period 3 (2 days ago pivot)
        daily_pivot3 = calcPivot(daily_h3, daily_l3, daily_c3)
        // Draw in 2 days ago timeframe: from prev_day_start_bar_2 to prev_day_start_bar-1
        start_bar3 = prev_day_start_bar_2
        end_bar3 = prev_day_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar3 := math.max(end_bar3, start_bar3 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar3 > 0 and bar_index - start_bar3 < 350
            drawPeriodLevel(daily_pivot3, adjustTransparency(daily_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
            if show_level_labels
                label.new(end_bar3 + 3, daily_pivot3, "dPP " + str.tostring(daily_pivot3, format.mintick), color=na, textcolor=adjustTransparency(daily_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Weekly Pivots
if false and show_weekly_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to period end (or current bar if still in period)
    start_bar = not na(week_start_bar) ? week_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(weekly_pivot, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, weekly_pivot, (show_untested_pivot_marker and not prev_weekly_pivot_was_hit ? "● " : "") + "wPP " + str.tostring(weekly_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_weekly_pivot_was_hit ? color.orange : weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(weekly_r1, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(weekly_s1, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, weekly_r1, "wR1 " + str.tostring(weekly_r1, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, weekly_s1, "wS1 " + str.tostring(weekly_s1, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(weekly_r2, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(weekly_s2, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, weekly_r2, "wR2 " + str.tostring(weekly_r2, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, weekly_s2, "wS2 " + str.tostring(weekly_s2, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(weekly_r3, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(weekly_s3, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, weekly_r3, "wR3 " + str.tostring(weekly_r3, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, weekly_s3, "wS3 " + str.tostring(weekly_s3, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(weekly_r4, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(weekly_s4, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, weekly_r4, "wR4 " + str.tostring(weekly_r4, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, weekly_s4, "wS4 " + str.tostring(weekly_s4, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(weekly_r5, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(weekly_s5, weekly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, weekly_r5, "wR5 " + str.tostring(weekly_r5, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
            label.new(end_bar + 3, weekly_s5, "wS5 " + str.tostring(weekly_s5, format.mintick), color=na, textcolor=weekly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    // Additional periods (2 and 3 periods back) - with increased transparency
    if pivot_periods_back >= 2 and not na(prev_week_start_bar)
        // Calculate pivots for period 2 (last week's pivot)
        weekly_pivot2 = calcPivot(weekly_h2, weekly_l2, weekly_c2)
        // Draw in last week's timeframe: from prev_week_start_bar to week_start_bar-1
        start_bar2 = prev_week_start_bar
        end_bar2 = week_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar2 := math.max(end_bar2, start_bar2 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar2 > 0 and bar_index - start_bar2 < 350
            drawPeriodLevel(weekly_pivot2, adjustTransparency(weekly_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
            if show_level_labels
                label.new(end_bar2 + 3, weekly_pivot2, "wPP " + str.tostring(weekly_pivot2, format.mintick), color=na, textcolor=adjustTransparency(weekly_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    if pivot_periods_back >= 3 and not na(prev_week_start_bar_2)
        // Calculate pivots for period 3 (2 weeks ago pivot)
        weekly_pivot3 = calcPivot(weekly_h3, weekly_l3, weekly_c3)
        // Draw in 2 weeks ago timeframe: from prev_week_start_bar_2 to prev_week_start_bar-1
        start_bar3 = prev_week_start_bar_2
        end_bar3 = prev_week_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar3 := math.max(end_bar3, start_bar3 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar3 > 0 and bar_index - start_bar3 < 350
            drawPeriodLevel(weekly_pivot3, adjustTransparency(weekly_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
            if show_level_labels
                label.new(end_bar3 + 3, weekly_pivot3, "wPP " + str.tostring(weekly_pivot3, format.mintick), color=na, textcolor=adjustTransparency(weekly_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Monthly Pivots
if false and show_monthly_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to period end (or current bar if still in period)
    start_bar = not na(month_start_bar) ? month_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(monthly_pivot, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, monthly_pivot, (show_untested_pivot_marker and not prev_monthly_pivot_was_hit ? "● " : "") + "mPP " + str.tostring(monthly_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_monthly_pivot_was_hit ? color.orange : monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(monthly_r1, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(monthly_s1, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, monthly_r1, "mR1 " + str.tostring(monthly_r1, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, monthly_s1, "mS1 " + str.tostring(monthly_s1, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(monthly_r2, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(monthly_s2, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, monthly_r2, "mR2 " + str.tostring(monthly_r2, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, monthly_s2, "mS2 " + str.tostring(monthly_s2, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(monthly_r3, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(monthly_s3, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, monthly_r3, "mR3 " + str.tostring(monthly_r3, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, monthly_s3, "mS3 " + str.tostring(monthly_s3, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(monthly_r4, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(monthly_s4, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, monthly_r4, "mR4 " + str.tostring(monthly_r4, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, monthly_s4, "mS4 " + str.tostring(monthly_s4, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(monthly_r5, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(monthly_s5, monthly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, monthly_r5, "mR5 " + str.tostring(monthly_r5, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, monthly_s5, "mS5 " + str.tostring(monthly_s5, format.mintick), color=na, textcolor=monthly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    // Additional periods (2 and 3 periods back) - with increased transparency
    if pivot_periods_back >= 2 and not na(prev_month_start_bar)
        // Calculate pivots for period 2 (last month's pivot)
        monthly_pivot2 = calcPivot(monthly_h2, monthly_l2, monthly_c2)
        // Draw in last month's timeframe: from prev_month_start_bar to month_start_bar-1
        start_bar2 = prev_month_start_bar
        end_bar2 = month_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar2 := math.max(end_bar2, start_bar2 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar2 > 0 and bar_index - start_bar2 < 350
            drawPeriodLevel(monthly_pivot2, adjustTransparency(monthly_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
            if show_level_labels
                label.new(end_bar2 + 3, monthly_pivot2, "mPP " + str.tostring(monthly_pivot2, format.mintick), color=na, textcolor=adjustTransparency(monthly_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

    if pivot_periods_back >= 3 and not na(prev_month_start_bar_2)
        // Calculate pivots for period 3 (2 months ago pivot)
        monthly_pivot3 = calcPivot(monthly_h3, monthly_l3, monthly_c3)
        // Draw in 2 months ago timeframe: from prev_month_start_bar_2 to prev_month_start_bar-1
        start_bar3 = prev_month_start_bar_2
        end_bar3 = prev_month_start_bar - 1
        // Ensure minimum line length of 1 bar for visibility
        end_bar3 := math.max(end_bar3, start_bar3 + 1)
        // Only draw if bar index is valid and within reasonable range
        if start_bar3 > 0 and bar_index - start_bar3 < 350
            drawPeriodLevel(monthly_pivot3, adjustTransparency(monthly_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
            if show_level_labels
                label.new(end_bar3 + 3, monthly_pivot3, "mPP " + str.tostring(monthly_pivot3, format.mintick), color=na, textcolor=adjustTransparency(monthly_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Quarterly Pivots
if false and show_quarterly_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to period end (or current bar if still in period)
    start_bar = not na(quarter_start_bar) ? quarter_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(quarterly_pivot, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, quarterly_pivot, (show_untested_pivot_marker and not prev_quarterly_pivot_was_hit ? "● " : "") + "qPP " + str.tostring(quarterly_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_quarterly_pivot_was_hit ? color.orange : quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(quarterly_r1, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(quarterly_s1, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, quarterly_r1, "qR1 " + str.tostring(quarterly_r1, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, quarterly_s1, "qS1 " + str.tostring(quarterly_s1, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(quarterly_r2, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(quarterly_s2, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, quarterly_r2, "qR2 " + str.tostring(quarterly_r2, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, quarterly_s2, "qS2 " + str.tostring(quarterly_s2, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(quarterly_r3, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(quarterly_s3, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, quarterly_r3, "qR3 " + str.tostring(quarterly_r3, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, quarterly_s3, "qS3 " + str.tostring(quarterly_s3, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(quarterly_r4, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(quarterly_s4, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, quarterly_r4, "qR4 " + str.tostring(quarterly_r4, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, quarterly_s4, "qS4 " + str.tostring(quarterly_s4, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(quarterly_r5, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(quarterly_s5, quarterly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, quarterly_r5, "qR5 " + str.tostring(quarterly_r5, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, quarterly_s5, "qS5 " + str.tostring(quarterly_s5, format.mintick), color=na, textcolor=quarterly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        // Additional periods (2 and 3 periods back) - with increased transparency
        if pivot_periods_back >= 2 and not na(prev_quarter_start_bar)
            // Calculate pivots for period 2 (last quarter's pivot)
            quarterly_pivot2 = calcPivot(quarterly_h2, quarterly_l2, quarterly_c2)
            // Draw in last quarter's timeframe: from prev_quarter_start_bar to quarter_start_bar-1
            start_bar2 = prev_quarter_start_bar
            end_bar2 = quarter_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar2 := math.max(end_bar2, start_bar2 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar2 > 0 and bar_index - start_bar2 < 350
                drawPeriodLevel(quarterly_pivot2, adjustTransparency(quarterly_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
                if show_level_labels
                    label.new(end_bar2 + 3, quarterly_pivot2, "qPP " + str.tostring(quarterly_pivot2, format.mintick), color=na, textcolor=adjustTransparency(quarterly_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        if pivot_periods_back >= 3 and not na(prev_quarter_start_bar_2)
            // Calculate pivots for period 3 (2 quarters ago pivot)
            quarterly_pivot3 = calcPivot(quarterly_h3, quarterly_l3, quarterly_c3)
            // Draw in 2 quarters ago timeframe: from prev_quarter_start_bar_2 to prev_quarter_start_bar-1
            start_bar3 = prev_quarter_start_bar_2
            end_bar3 = prev_quarter_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar3 := math.max(end_bar3, start_bar3 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar3 > 0 and bar_index - start_bar3 < 350
                drawPeriodLevel(quarterly_pivot3, adjustTransparency(quarterly_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
                if show_level_labels
                    label.new(end_bar3 + 3, quarterly_pivot3, "qPP " + str.tostring(quarterly_pivot3, format.mintick), color=na, textcolor=adjustTransparency(quarterly_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Six-Month Pivots
if false and show_sixmonth_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to period end (or current bar if still in period)
    start_bar = not na(sixmonth_start_bar) ? sixmonth_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(sixmonth_pivot, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, sixmonth_pivot, (show_untested_pivot_marker and not prev_sixmonth_pivot_was_hit ? "● " : "") + "6mPP " + str.tostring(sixmonth_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_sixmonth_pivot_was_hit ? color.orange : sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(sixmonth_r1, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(sixmonth_s1, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, sixmonth_r1, "6mR1 " + str.tostring(sixmonth_r1, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, sixmonth_s1, "6mS1 " + str.tostring(sixmonth_s1, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(sixmonth_r2, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(sixmonth_s2, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, sixmonth_r2, "6mR2 " + str.tostring(sixmonth_r2, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, sixmonth_s2, "6mS2 " + str.tostring(sixmonth_s2, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(sixmonth_r3, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(sixmonth_s3, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, sixmonth_r3, "6mR3 " + str.tostring(sixmonth_r3, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, sixmonth_s3, "6mS3 " + str.tostring(sixmonth_s3, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(sixmonth_r4, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(sixmonth_s4, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, sixmonth_r4, "6mR4 " + str.tostring(sixmonth_r4, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, sixmonth_s4, "6mS4 " + str.tostring(sixmonth_s4, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(sixmonth_r5, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(sixmonth_s5, sixmonth_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, sixmonth_r5, "6mR5 " + str.tostring(sixmonth_r5, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, sixmonth_s5, "6mS5 " + str.tostring(sixmonth_s5, format.mintick), color=na, textcolor=sixmonth_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        // Additional periods (2 and 3 periods back) - with increased transparency
        if pivot_periods_back >= 2 and not na(prev_sixmonth_start_bar)
            // Calculate pivots for period 2 (last six-month's pivot)
            sixmonth_pivot2 = calcPivot(sixmonth_h2, sixmonth_l2, sixmonth_c2)
            // Draw in last six-month's timeframe: from prev_sixmonth_start_bar to sixmonth_start_bar-1
            start_bar2 = prev_sixmonth_start_bar
            end_bar2 = sixmonth_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar2 := math.max(end_bar2, start_bar2 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar2 > 0 and bar_index - start_bar2 < 350
                drawPeriodLevel(sixmonth_pivot2, adjustTransparency(sixmonth_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
                if show_level_labels
                    label.new(end_bar2 + 3, sixmonth_pivot2, "6mPP " + str.tostring(sixmonth_pivot2, format.mintick), color=na, textcolor=adjustTransparency(sixmonth_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        if pivot_periods_back >= 3 and not na(prev_sixmonth_start_bar_2)
            // Calculate pivots for period 3 (2 six-months ago pivot)
            sixmonth_pivot3 = calcPivot(sixmonth_h3, sixmonth_l3, sixmonth_c3)
            // Draw in 2 six-months ago timeframe: from prev_sixmonth_start_bar_2 to prev_sixmonth_start_bar-1
            start_bar3 = prev_sixmonth_start_bar_2
            end_bar3 = prev_sixmonth_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar3 := math.max(end_bar3, start_bar3 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar3 > 0 and bar_index - start_bar3 < 350
                drawPeriodLevel(sixmonth_pivot3, adjustTransparency(sixmonth_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
                if show_level_labels
                    label.new(end_bar3 + 3, sixmonth_pivot3, "6mPP " + str.tostring(sixmonth_pivot3, format.mintick), color=na, textcolor=adjustTransparency(sixmonth_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Yearly Pivots
if false and show_yearly_pivots and barstate.islast  // DISABLED - now drawn by grouped system
    // Line spans from period start to period end (or current bar if still in period)
    start_bar = not na(year_start_bar) ? year_start_bar : math.max(0, bar_index - 500)
    end_bar = bar_index  // Always use current bar as end for current period
    // Ensure minimum line length of 1 bar for visibility
    end_bar := math.max(end_bar, start_bar + 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawPeriodLevel(yearly_pivot, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
        if show_level_labels
            label.new(end_bar + 3, yearly_pivot, (show_untested_pivot_marker and not prev_yearly_pivot_was_hit ? "● " : "") + "yPP " + str.tostring(yearly_pivot, format.mintick), color=na, textcolor=show_untested_pivot_marker and not prev_yearly_pivot_was_hit ? color.orange : yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 1
            drawPeriodLevel(yearly_r1, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(yearly_s1, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, yearly_r1, "yR1 " + str.tostring(yearly_r1, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, yearly_s1, "yS1 " + str.tostring(yearly_s1, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 2
            drawPeriodLevel(yearly_r2, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(yearly_s2, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, yearly_r2, "yR2 " + str.tostring(yearly_r2, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, yearly_s2, "yS2 " + str.tostring(yearly_s2, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 3
            drawPeriodLevel(yearly_r3, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(yearly_s3, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, yearly_r3, "yR3 " + str.tostring(yearly_r3, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, yearly_s3, "yS3 " + str.tostring(yearly_s3, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 4
            drawPeriodLevel(yearly_r4, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(yearly_s4, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, yearly_r4, "yR4 " + str.tostring(yearly_r4, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, yearly_s4, "yS4 " + str.tostring(yearly_s4, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
        if pivot_levels >= 5
            drawPeriodLevel(yearly_r5, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            drawPeriodLevel(yearly_s5, yearly_pivot_color, pivot_line_width, pivot_style, start_bar, end_bar)
            if show_level_labels
                label.new(end_bar + 3, yearly_r5, "yR5 " + str.tostring(yearly_r5, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
                label.new(end_bar + 3, yearly_s5, "yS5 " + str.tostring(yearly_s5, format.mintick), color=na, textcolor=yearly_pivot_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        // Additional periods (2 and 3 periods back) - with increased transparency
        if pivot_periods_back >= 2 and not na(prev_year_start_bar)
            // Calculate pivots for period 2 (last year's pivot)
            yearly_pivot2 = calcPivot(yearly_h2, yearly_l2, yearly_c2)
            // Draw in last year's timeframe: from prev_year_start_bar to year_start_bar-1
            start_bar2 = prev_year_start_bar
            end_bar2 = year_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar2 := math.max(end_bar2, start_bar2 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar2 > 0 and bar_index - start_bar2 < 350
                drawPeriodLevel(yearly_pivot2, adjustTransparency(yearly_pivot_color, 60), pivot_line_width, pivot_style, start_bar2, end_bar2)
                if show_level_labels
                    label.new(end_bar2 + 3, yearly_pivot2, "yPP " + str.tostring(yearly_pivot2, format.mintick), color=na, textcolor=adjustTransparency(yearly_pivot_color, 60), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

        if pivot_periods_back >= 3 and not na(prev_year_start_bar_2)
            // Calculate pivots for period 3 (2 years ago pivot)
            yearly_pivot3 = calcPivot(yearly_h3, yearly_l3, yearly_c3)
            // Draw in 2 years ago timeframe: from prev_year_start_bar_2 to prev_year_start_bar-1
            start_bar3 = prev_year_start_bar_2
            end_bar3 = prev_year_start_bar - 1
            // Ensure minimum line length of 1 bar for visibility
            end_bar3 := math.max(end_bar3, start_bar3 + 1)
            // Only draw if bar index is valid and within reasonable range (avoid "too far" errors)
            if start_bar3 > 0 and bar_index - start_bar3 < 350
                drawPeriodLevel(yearly_pivot3, adjustTransparency(yearly_pivot_color, 80), pivot_line_width, pivot_style, start_bar3, end_bar3)
                if show_level_labels
                    label.new(end_bar3 + 3, yearly_pivot3, "yPP " + str.tostring(yearly_pivot3, format.mintick), color=na, textcolor=adjustTransparency(yearly_pivot_color, 80), textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW PREVIOUS PERIOD LEVELS USING LINE AND BOX OBJECTS
// ═══════════════════════════════════════════════════════════════════════════════

// Store box references to update them instead of creating new ones
var box prev_day_box = na
var box prev_week_box = na
var box prev_month_box = na

// Track if ranges have been broken (persist once broken)
var bool prev_day_range_broken = false
var bool prev_week_range_broken = false
var bool prev_month_range_broken = false

// Reset broken flags when new period starts
if ta.change(time("D")) != 0
    prev_day_range_broken := false
if ta.change(time("W")) != 0
    prev_week_range_broken := false
if ta.change(time("M")) != 0
    prev_month_range_broken := false

// ═══════════════════════════════════════════════════════════════════════════════
// INSIDE BAR DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

// Inside Bar Detection
// Detects when the PREVIOUS period was an inside bar relative to the period before it
// This indicates consolidation/range compression in the previous period
is_inside_prev_day = show_prev_day and prev_day_high < daily_h2 and prev_day_low > daily_l2
is_inside_prev_week = show_prev_week and prev_week_high < weekly_h2 and prev_week_low > weekly_l2
is_inside_prev_month = show_prev_month and prev_month_high < monthly_h2 and prev_month_low > monthly_l2

// Inside-bar history tracking (push at period boundary, after request.security values rolled forward)
// Independent of show_prev_* toggles so history stays consistent if user toggles display off/on
if ta.change(time("D")) != 0
    inside_data_valid_d = not na(prev_day_high) and not na(prev_day_low) and not na(daily_h2) and not na(daily_l2)
    if inside_history_day_started and inside_data_valid_d
        inside_d_value = prev_day_high < daily_h2 and prev_day_low > daily_l2
        pushHistory(inside_bar_history_day, inside_d_value ? 1 : 0)
    inside_history_day_started := true

if ta.change(time("W")) != 0
    inside_data_valid_w = not na(prev_week_high) and not na(prev_week_low) and not na(weekly_h2) and not na(weekly_l2)
    if inside_history_week_started and inside_data_valid_w
        inside_w_value = prev_week_high < weekly_h2 and prev_week_low > weekly_l2
        pushHistory(inside_bar_history_week, inside_w_value ? 1 : 0)
    inside_history_week_started := true

if ta.change(time("M")) != 0
    inside_data_valid_m = not na(prev_month_high) and not na(prev_month_low) and not na(monthly_h2) and not na(monthly_l2)
    if inside_history_month_started and inside_data_valid_m
        inside_m_value = prev_month_high < monthly_h2 and prev_month_low > monthly_l2
        pushHistory(inside_bar_history_month, inside_m_value ? 1 : 0)
    inside_history_month_started := true

// Previous Day
if show_prev_day and not na(prev_day_start_bar)
    // Check if high or low has been taken (once broken, stays broken)
    // Use bar high/low instead of close to catch wicks
    if high > prev_day_high or low < prev_day_low
        prev_day_range_broken := true

    // Draw background zone
    if show_prev_backgrounds and not prev_day_range_broken
        if barstate.islast
            // Create or update box (hardcoded to 95% transparency = 5% opacity)
            if na(prev_day_box)
                prev_day_box := box.new(prev_day_start_bar, prev_day_high, bar_index, prev_day_low, bgcolor=adjustTransparency(prev_day_color, 95), border_color=color.new(color.gray, 100), border_width=0, extend=extend.right)
            else
                box.set_right(prev_day_box, bar_index)
                box.set_bgcolor(prev_day_box, adjustTransparency(prev_day_color, 95))
    else
        // Delete box if backgrounds are disabled or range is broken
        if not na(prev_day_box)
            box.delete(prev_day_box)
            prev_day_box := na

    // Note: Lines and labels now drawn using grouped system below

// Previous Week
if show_prev_week and not na(prev_week_start_bar)
    // Check if high or low has been taken (once broken, stays broken)
    // Use bar high/low instead of close to catch wicks
    if high > prev_week_high or low < prev_week_low
        prev_week_range_broken := true

    // Draw background zone
    if show_prev_backgrounds and not prev_week_range_broken
        if barstate.islast
            // Create or update box (hardcoded to 95% transparency = 5% opacity)
            if na(prev_week_box)
                prev_week_box := box.new(prev_week_start_bar, prev_week_high, bar_index, prev_week_low, bgcolor=adjustTransparency(prev_week_color, 95), border_color=color.new(color.gray, 100), border_width=0, extend=extend.right)
            else
                box.set_right(prev_week_box, bar_index)
                box.set_bgcolor(prev_week_box, adjustTransparency(prev_week_color, 95))
    else
        // Delete box if backgrounds are disabled or range is broken
        if not na(prev_week_box)
            box.delete(prev_week_box)
            prev_week_box := na

    // Note: Lines and labels now drawn using grouped system below

// Previous Month
if show_prev_month and not na(prev_month_start_bar)
    // Check if high or low has been taken (once broken, stays broken)
    // Use bar high/low instead of close to catch wicks
    if high > prev_month_high or low < prev_month_low
        prev_month_range_broken := true

    // Draw background zone
    if show_prev_backgrounds and not prev_month_range_broken
        if barstate.islast
            // Create or update box (hardcoded to 95% transparency = 5% opacity)
            if na(prev_month_box)
                prev_month_box := box.new(prev_month_start_bar, prev_month_high, bar_index, prev_month_low, bgcolor=adjustTransparency(prev_month_color, 95), border_color=color.new(color.gray, 100), border_width=0, extend=extend.right)
            else
                box.set_right(prev_month_box, bar_index)
                box.set_bgcolor(prev_month_box, adjustTransparency(prev_month_color, 95))
    else
        // Delete box if backgrounds are disabled or range is broken
        if not na(prev_month_box)
            box.delete(prev_month_box)
            prev_month_box := na

    // Note: Lines and labels now drawn using grouped system below

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW PERIOD OPENS USING LINE OBJECTS
// ═══════════════════════════════════════════════════════════════════════════════

// Get period open line style
open_style = getLineStyle(open_line_style)

// Detect current chart timeframe to only show opens from HIGHER timeframes
// This prevents vertical lines when viewing on same or higher timeframe
is_on_intraday = timeframe.isintraday
is_on_daily = timeframe.isdaily
is_on_weekly = timeframe.isweekly
is_on_monthly = timeframe.ismonthly

// Only draw opens for timeframes HIGHER than current chart timeframe
// Daily open only shows on intraday charts
if false and show_daily_open and barstate.islast  // DISABLED - now drawn by grouped system and is_on_intraday
    // Start at period start and extend to the right
    start_bar = not na(day_start_bar) ? day_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(daily_open, daily_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, daily_open, "dOpen " + str.tostring(daily_open, format.mintick), color=na, textcolor=daily_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Weekly open shows on intraday and daily charts (not on weekly or higher)
if false and show_weekly_open and barstate.islast  // DISABLED - now drawn by grouped system and (is_on_intraday or is_on_daily)
    // Start at period start and extend to the right
    start_bar = not na(week_start_bar) ? week_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(weekly_open, weekly_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, weekly_open, "wOpen " + str.tostring(weekly_open, format.mintick), color=na, textcolor=weekly_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Monthly open shows on intraday, daily, and weekly charts (not on monthly or higher)
if false and show_monthly_open and barstate.islast  // DISABLED - now drawn by grouped system and (is_on_intraday or is_on_daily or is_on_weekly)
    // Start at period start and extend to the right
    start_bar = not na(month_start_bar) ? month_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(monthly_open, monthly_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, monthly_open, "mOpen " + str.tostring(monthly_open, format.mintick), color=na, textcolor=monthly_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Quarterly open shows on all timeframes except quarterly and higher
if false and show_quarterly_open and barstate.islast  // DISABLED - now drawn by grouped system and (is_on_intraday or is_on_daily or is_on_weekly or is_on_monthly)
    // Start at period start and extend to the right
    start_bar = not na(quarter_start_bar) ? quarter_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(quarterly_open, quarterly_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, quarterly_open, "qOpen " + str.tostring(quarterly_open, format.mintick), color=na, textcolor=quarterly_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Six-month open shows on all standard timeframes
if false and show_sixmonth_open and barstate.islast  // DISABLED - now drawn by grouped system and (is_on_intraday or is_on_daily or is_on_weekly or is_on_monthly)
    // Start at period start and extend to the right
    start_bar = not na(sixmonth_start_bar) ? sixmonth_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(sixmonth_open, sixmonth_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, sixmonth_open, "6mOpen " + str.tostring(sixmonth_open, format.mintick), color=na, textcolor=sixmonth_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// Yearly open shows on all standard timeframes
if false and show_yearly_open and barstate.islast  // DISABLED - now drawn by grouped system and (is_on_intraday or is_on_daily or is_on_weekly or is_on_monthly)
    // Start at period start and extend to the right
    start_bar = not na(year_start_bar) ? year_start_bar : math.max(0, bar_index - 500)
    // Ensure start is at least 1 bar before current for visibility
    start_bar := math.min(start_bar, bar_index - 1)
    // Only draw if bar index is valid and within reasonable range
    if start_bar > 0 and bar_index - start_bar < 350
        drawExtendedLevel(yearly_open, yearly_open_color, open_line_width, open_style, start_bar)
        if show_level_labels
            label.new(bar_index + 20, yearly_open, "yOpen " + str.tostring(yearly_open, format.mintick), color=na, textcolor=yearly_open_color, textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW GROUPED LEVELS (combines overlapping levels into single labels)
// ═══════════════════════════════════════════════════════════════════════════════
// TIME-BASED DRAWING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
// Uses time coordinates instead of bar indices to bypass buffer limitations
// Pivots extend from period start to period end
// Opens and Previous Period levels extend to the right indefinitely

// Helper function to clean up old objects before redrawing
// (all_lines and all_labels arrays are declared globally above)
cleanupObjects() =>
    // Delete all existing lines
    if array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
    array.clear(all_lines)

    // Delete all existing labels
    if array.size(all_labels) > 0
        for i = 0 to array.size(all_labels) - 1
            label.delete(array.get(all_labels, i))
    array.clear(all_labels)

// Wrapper for drawTimeBasedLevel that tracks the line object
drawAndTrackLevel(start_time, end_time, y_value, level_color, width, linestyle) =>
    new_line = drawTimeBasedLevel(start_time, end_time, y_value, level_color, width, linestyle)
    if not na(new_line)
        array.push(all_lines, new_line)
    new_line

// Wrapper for label.new that tracks the label object (not currently used - kept for reference)
createAndTrackLabel(x, y, label_text, textcolor) =>
    new_label = label.new(x, y, label_text, xloc=xloc.bar_time, color=na, textcolor=textcolor,
                         textalign=text.align_left, style=label.style_label_left, size=getLabelSize(label_size))
    array.push(all_labels, new_label)
    new_label

if barstate.islast
    // Clean up old objects before redrawing
    cleanupObjects()

    // ═══════════════════════════════════════════════════════════
    // COLLECT CURRENT PERIOD LEVELS FOR GROUPED DRAWING
    // ═══════════════════════════════════════════════════════════
    // Priority system for color selection when grouping:
    // - Current pivots: 100-50 (Daily=100, Weekly=90, Monthly=80, etc.)
    // - Previous period: 45-23 (Day High=45, Day EQ=44, Day Low=43, etc.)
    // - Opens: 20-15 (Daily=20, Weekly=19, Monthly=18, etc.)

    var current_levels = array.new<TimeBasedLevel>()
    array.clear(current_levels)

    future_time = timestamp(year(time) + 10, 1, 1)

    // ═══ PREVIOUS PERIOD LEVELS ═══
    // Previous Day Levels
    if show_prev_day and not na(prev_day_start_time)
        // Consecutive inside-bar count (gated by marker toggle and current-period range integrity)
        pd_inside_consec = (show_inside_bar_marker and not prev_day_range_broken) ? countConsecutiveFromEnd(inside_bar_history_day, 1, consecutive_marker_count) : 0
        pd_prefix = makeDots(pd_inside_consec)
        pd_label_color = pd_inside_consec > 0 ? color.orange : adjustTransparency(prev_day_color, 0)
        // Breakout % (non-inside / total) — shown on EQ label only
        pd_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or pd_inside_consec > 0)
        pd_breakout_pct = pd_pct_visible ? computePct(inside_bar_history_day, 0, stats_lookback_periods) : float(na)
        pd_eq_suffix = not na(pd_breakout_pct) ? str.tostring(pd_breakout_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(pd_prefix + "pdHigh", prev_day_high, prev_day_start_time, future_time,
                   adjustTransparency(prev_day_color, 60), pd_label_color, prev_line_width, 70))
        array.push(current_levels, TimeBasedLevel.new(pd_prefix + "pdEQ", prev_day_eq, prev_day_start_time, future_time,
                   adjustTransparency(prev_day_color, 20), pd_label_color, prev_line_width, 69, pd_eq_suffix))
        array.push(current_levels, TimeBasedLevel.new(pd_prefix + "pdLow", prev_day_low, prev_day_start_time, future_time,
                   adjustTransparency(prev_day_color, 60), pd_label_color, prev_line_width, 68))

    // Previous Week Levels
    if show_prev_week and not na(prev_week_start_time)
        pw_inside_consec = (show_inside_bar_marker and not prev_week_range_broken) ? countConsecutiveFromEnd(inside_bar_history_week, 1, consecutive_marker_count) : 0
        pw_prefix = makeDots(pw_inside_consec)
        pw_label_color = pw_inside_consec > 0 ? color.orange : adjustTransparency(prev_week_color, 0)
        pw_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or pw_inside_consec > 0)
        pw_breakout_pct = pw_pct_visible ? computePct(inside_bar_history_week, 0, stats_lookback_periods) : float(na)
        pw_eq_suffix = not na(pw_breakout_pct) ? str.tostring(pw_breakout_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(pw_prefix + "pwHigh", prev_week_high, prev_week_start_time, future_time,
                   adjustTransparency(prev_week_color, 60), pw_label_color, prev_line_width, 65))
        array.push(current_levels, TimeBasedLevel.new(pw_prefix + "pwEQ", prev_week_eq, prev_week_start_time, future_time,
                   adjustTransparency(prev_week_color, 20), pw_label_color, prev_line_width, 64, pw_eq_suffix))
        array.push(current_levels, TimeBasedLevel.new(pw_prefix + "pwLow", prev_week_low, prev_week_start_time, future_time,
                   adjustTransparency(prev_week_color, 60), pw_label_color, prev_line_width, 63))

    // Previous Month Levels
    if show_prev_month and not na(prev_month_start_time)
        pm_inside_consec = (show_inside_bar_marker and not prev_month_range_broken) ? countConsecutiveFromEnd(inside_bar_history_month, 1, consecutive_marker_count) : 0
        pm_prefix = makeDots(pm_inside_consec)
        pm_label_color = pm_inside_consec > 0 ? color.orange : adjustTransparency(prev_month_color, 0)
        pm_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or pm_inside_consec > 0)
        pm_breakout_pct = pm_pct_visible ? computePct(inside_bar_history_month, 0, stats_lookback_periods) : float(na)
        pm_eq_suffix = not na(pm_breakout_pct) ? str.tostring(pm_breakout_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(pm_prefix + "pmHigh", prev_month_high, prev_month_start_time, future_time,
                   adjustTransparency(prev_month_color, 60), pm_label_color, prev_line_width, 60))
        array.push(current_levels, TimeBasedLevel.new(pm_prefix + "pmEQ", prev_month_eq, prev_month_start_time, future_time,
                   adjustTransparency(prev_month_color, 20), pm_label_color, prev_line_width, 59, pm_eq_suffix))
        array.push(current_levels, TimeBasedLevel.new(pm_prefix + "pmLow", prev_month_low, prev_month_start_time, future_time,
                   adjustTransparency(prev_month_color, 60), pm_label_color, prev_line_width, 58))

    // ═══ PERIOD OPENS ═══
    if show_daily_open and not na(day_start_time)
        array.push(current_levels, TimeBasedLevel.new("dOpen", daily_open, day_start_time, future_time,
                   daily_open_color, daily_open_color, open_line_width, 100))

    if show_weekly_open and not na(week_start_time)
        array.push(current_levels, TimeBasedLevel.new("wOpen", weekly_open, week_start_time, future_time,
                   weekly_open_color, weekly_open_color, open_line_width, 95))

    if show_monthly_open and not na(month_start_time)
        array.push(current_levels, TimeBasedLevel.new("mOpen", monthly_open, month_start_time, future_time,
                   monthly_open_color, monthly_open_color, open_line_width, 90))

    if show_quarterly_open and not na(quarter_start_time)
        array.push(current_levels, TimeBasedLevel.new("qOpen", quarterly_open, quarter_start_time, future_time,
                   quarterly_open_color, quarterly_open_color, open_line_width, 85))

    if show_sixmonth_open and not na(sixmonth_start_time)
        array.push(current_levels, TimeBasedLevel.new("6mOpen", sixmonth_open, sixmonth_start_time, future_time,
                   sixmonth_open_color, sixmonth_open_color, open_line_width, 80))

    if show_yearly_open and not na(year_start_time)
        array.push(current_levels, TimeBasedLevel.new("yOpen", yearly_open, year_start_time, future_time,
                   yearly_open_color, yearly_open_color, open_line_width, 75))

    // ═══ CURRENT PERIOD PIVOTS ═══
    // Daily Pivots (current period only)
    if show_daily_pivots and not na(day_start_time)
        day_end_time = getPeriodEndTime(day_start_time, "D")
        d_label_color = daily_pivot_color
        // Consecutive untapped count: current (if untapped) + history of consecutive 0s
        d_current_untapped = show_untested_pivot_marker and not daily_pivot_hit
        d_hist_untapped = countConsecutiveFromEnd(daily_pivot_hit_history, 0, consecutive_marker_count)
        d_total_consec = d_current_untapped ? 1 + d_hist_untapped : 0
        // Marker fires when current + at least 1 prior period are untapped (preserves original threshold)
        d_marker_visible = d_total_consec >= 2
        d_dot_count = d_marker_visible ? math.min(d_total_consec, consecutive_marker_count) : 0
        d_prefix = makeDots(d_dot_count)
        // Tap rate %
        d_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or d_marker_visible)
        d_tap_pct = d_pct_visible ? computePct(daily_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        d_pp_suffix = not na(d_tap_pct) ? str.tostring(d_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(d_prefix + "dPP", daily_pivot, day_start_time, day_end_time,
                   daily_pivot_color, d_label_color, pivot_line_width, 45, d_pp_suffix))

        // Daily S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("dR1", daily_r1, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 44))
            array.push(current_levels, TimeBasedLevel.new("dS1", daily_s1, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 43))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("dR2", daily_r2, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 42))
            array.push(current_levels, TimeBasedLevel.new("dS2", daily_s2, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 41))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("dR3", daily_r3, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 40))
            array.push(current_levels, TimeBasedLevel.new("dS3", daily_s3, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 39))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("dR4", daily_r4, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 38))
            array.push(current_levels, TimeBasedLevel.new("dS4", daily_s4, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 37))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("dR5", daily_r5, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 36))
            array.push(current_levels, TimeBasedLevel.new("dS5", daily_s5, day_start_time, day_end_time,
                       daily_pivot_color, daily_pivot_color, pivot_line_width, 35))

        // Historical Daily Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_day_start_time) and not na(day_start_time)
            daily_pivot2 = calcPivot(daily_h2, daily_l2, daily_c2)
            prev_day_end_time = day_start_time  // Previous period ends when current period starts
            drawAndTrackLevel(prev_day_start_time, prev_day_end_time, daily_pivot2, adjustTransparency(daily_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_day_end_time, daily_pivot2, "dPP " + str.tostring(daily_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(daily_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Daily Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_day_start_time_2) and not na(prev_day_start_time)
            daily_pivot3 = calcPivot(daily_h3, daily_l3, daily_c3)
            prev_day_end_time_2 = prev_day_start_time  // Period 2 ends when period 1 starts
            drawAndTrackLevel(prev_day_start_time_2, prev_day_end_time_2, daily_pivot3, adjustTransparency(daily_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_day_end_time_2, daily_pivot3, "dPP " + str.tostring(daily_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(daily_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // Weekly Pivots (current period only)
    if show_weekly_pivots and not na(week_start_time)
        week_end_time = getPeriodEndTime(week_start_time, "W")
        w_label_color = weekly_pivot_color
        w_current_untapped = show_untested_pivot_marker and not weekly_pivot_hit
        w_hist_untapped = countConsecutiveFromEnd(weekly_pivot_hit_history, 0, consecutive_marker_count)
        w_total_consec = w_current_untapped ? 1 + w_hist_untapped : 0
        w_marker_visible = w_total_consec >= 2
        w_dot_count = w_marker_visible ? math.min(w_total_consec, consecutive_marker_count) : 0
        w_prefix = makeDots(w_dot_count)
        w_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or w_marker_visible)
        w_tap_pct = w_pct_visible ? computePct(weekly_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        w_pp_suffix = not na(w_tap_pct) ? str.tostring(w_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(w_prefix + "wPP", weekly_pivot, week_start_time, week_end_time,
                   weekly_pivot_color, w_label_color, pivot_line_width, 40, w_pp_suffix))

        // Weekly S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("wR1", weekly_r1, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 39))
            array.push(current_levels, TimeBasedLevel.new("wS1", weekly_s1, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 38))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("wR2", weekly_r2, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 37))
            array.push(current_levels, TimeBasedLevel.new("wS2", weekly_s2, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 36))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("wR3", weekly_r3, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 35))
            array.push(current_levels, TimeBasedLevel.new("wS3", weekly_s3, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 34))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("wR4", weekly_r4, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 33))
            array.push(current_levels, TimeBasedLevel.new("wS4", weekly_s4, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 32))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("wR5", weekly_r5, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 31))
            array.push(current_levels, TimeBasedLevel.new("wS5", weekly_s5, week_start_time, week_end_time,
                       weekly_pivot_color, weekly_pivot_color, pivot_line_width, 30))

        // Historical Weekly Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_week_start_time) and not na(week_start_time)
            weekly_pivot2 = calcPivot(weekly_h2, weekly_l2, weekly_c2)
            prev_week_end_time = week_start_time
            drawAndTrackLevel(prev_week_start_time, prev_week_end_time, weekly_pivot2, adjustTransparency(weekly_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_week_end_time, weekly_pivot2, "wPP " + str.tostring(weekly_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(weekly_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Weekly Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_week_start_time_2) and not na(prev_week_start_time)
            weekly_pivot3 = calcPivot(weekly_h3, weekly_l3, weekly_c3)
            prev_week_end_time_2 = prev_week_start_time
            drawAndTrackLevel(prev_week_start_time_2, prev_week_end_time_2, weekly_pivot3, adjustTransparency(weekly_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_week_end_time_2, weekly_pivot3, "wPP " + str.tostring(weekly_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(weekly_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // Monthly Pivots (current period only)
    if show_monthly_pivots and not na(month_start_time)
        month_end_time = getPeriodEndTime(month_start_time, "M")
        m_label_color = monthly_pivot_color
        m_current_untapped = show_untested_pivot_marker and not monthly_pivot_hit
        m_hist_untapped = countConsecutiveFromEnd(monthly_pivot_hit_history, 0, consecutive_marker_count)
        m_total_consec = m_current_untapped ? 1 + m_hist_untapped : 0
        m_marker_visible = m_total_consec >= 2
        m_dot_count = m_marker_visible ? math.min(m_total_consec, consecutive_marker_count) : 0
        m_prefix = makeDots(m_dot_count)
        m_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or m_marker_visible)
        m_tap_pct = m_pct_visible ? computePct(monthly_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        m_pp_suffix = not na(m_tap_pct) ? str.tostring(m_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(m_prefix + "mPP", monthly_pivot, month_start_time, month_end_time,
                   monthly_pivot_color, m_label_color, pivot_line_width, 35, m_pp_suffix))

        // Monthly S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("mR1", monthly_r1, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 34))
            array.push(current_levels, TimeBasedLevel.new("mS1", monthly_s1, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 33))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("mR2", monthly_r2, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 32))
            array.push(current_levels, TimeBasedLevel.new("mS2", monthly_s2, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 31))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("mR3", monthly_r3, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 30))
            array.push(current_levels, TimeBasedLevel.new("mS3", monthly_s3, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 29))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("mR4", monthly_r4, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 28))
            array.push(current_levels, TimeBasedLevel.new("mS4", monthly_s4, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 27))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("mR5", monthly_r5, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 26))
            array.push(current_levels, TimeBasedLevel.new("mS5", monthly_s5, month_start_time, month_end_time,
                       monthly_pivot_color, monthly_pivot_color, pivot_line_width, 25))

        // Historical Monthly Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_month_start_time) and not na(month_start_time)
            monthly_pivot2 = calcPivot(monthly_h2, monthly_l2, monthly_c2)
            prev_month_end_time = month_start_time
            drawAndTrackLevel(prev_month_start_time, prev_month_end_time, monthly_pivot2, adjustTransparency(monthly_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_month_end_time, monthly_pivot2, "mPP " + str.tostring(monthly_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(monthly_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Monthly Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_month_start_time_2) and not na(prev_month_start_time)
            monthly_pivot3 = calcPivot(monthly_h3, monthly_l3, monthly_c3)
            prev_month_end_time_2 = prev_month_start_time
            drawAndTrackLevel(prev_month_start_time_2, prev_month_end_time_2, monthly_pivot3, adjustTransparency(monthly_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_month_end_time_2, monthly_pivot3, "mPP " + str.tostring(monthly_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(monthly_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // Quarterly Pivots (current period only)
    if show_quarterly_pivots and not na(quarter_start_time)
        quarter_end_time = getPeriodEndTime(quarter_start_time, "3M")
        q_label_color = quarterly_pivot_color
        q_current_untapped = show_untested_pivot_marker and not quarterly_pivot_hit
        q_hist_untapped = countConsecutiveFromEnd(quarterly_pivot_hit_history, 0, consecutive_marker_count)
        q_total_consec = q_current_untapped ? 1 + q_hist_untapped : 0
        q_marker_visible = q_total_consec >= 2
        q_dot_count = q_marker_visible ? math.min(q_total_consec, consecutive_marker_count) : 0
        q_prefix = makeDots(q_dot_count)
        q_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or q_marker_visible)
        q_tap_pct = q_pct_visible ? computePct(quarterly_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        q_pp_suffix = not na(q_tap_pct) ? str.tostring(q_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(q_prefix + "qPP", quarterly_pivot, quarter_start_time, quarter_end_time,
                   quarterly_pivot_color, q_label_color, pivot_line_width, 30, q_pp_suffix))

        // Quarterly S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("qR1", quarterly_r1, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 29))
            array.push(current_levels, TimeBasedLevel.new("qS1", quarterly_s1, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 28))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("qR2", quarterly_r2, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 27))
            array.push(current_levels, TimeBasedLevel.new("qS2", quarterly_s2, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 26))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("qR3", quarterly_r3, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 25))
            array.push(current_levels, TimeBasedLevel.new("qS3", quarterly_s3, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 24))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("qR4", quarterly_r4, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 23))
            array.push(current_levels, TimeBasedLevel.new("qS4", quarterly_s4, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 22))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("qR5", quarterly_r5, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 21))
            array.push(current_levels, TimeBasedLevel.new("qS5", quarterly_s5, quarter_start_time, quarter_end_time,
                       quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, 20))

        // Historical Quarterly Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_quarter_start_time) and not na(quarter_start_time)
            quarterly_pivot2 = calcPivot(quarterly_h2, quarterly_l2, quarterly_c2)
            prev_quarter_end_time = quarter_start_time
            drawAndTrackLevel(prev_quarter_start_time, prev_quarter_end_time, quarterly_pivot2, adjustTransparency(quarterly_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_quarter_end_time, quarterly_pivot2, "qPP " + str.tostring(quarterly_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(quarterly_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Quarterly Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_quarter_start_time_2) and not na(prev_quarter_start_time)
            quarterly_pivot3 = calcPivot(quarterly_h3, quarterly_l3, quarterly_c3)
            prev_quarter_end_time_2 = prev_quarter_start_time
            drawAndTrackLevel(prev_quarter_start_time_2, prev_quarter_end_time_2, quarterly_pivot3, adjustTransparency(quarterly_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_quarter_end_time_2, quarterly_pivot3, "qPP " + str.tostring(quarterly_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(quarterly_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // Six-Month Pivots (current period only)
    if show_sixmonth_pivots and not na(sixmonth_start_time)
        sixmonth_end_time = getPeriodEndTime(sixmonth_start_time, "6M")
        sm_label_color = sixmonth_pivot_color
        sm_current_untapped = show_untested_pivot_marker and not sixmonth_pivot_hit
        sm_hist_untapped = countConsecutiveFromEnd(sixmonth_pivot_hit_history, 0, consecutive_marker_count)
        sm_total_consec = sm_current_untapped ? 1 + sm_hist_untapped : 0
        sm_marker_visible = sm_total_consec >= 2
        sm_dot_count = sm_marker_visible ? math.min(sm_total_consec, consecutive_marker_count) : 0
        sm_prefix = makeDots(sm_dot_count)
        sm_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or sm_marker_visible)
        sm_tap_pct = sm_pct_visible ? computePct(sixmonth_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        sm_pp_suffix = not na(sm_tap_pct) ? str.tostring(sm_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(sm_prefix + "6mPP", sixmonth_pivot, sixmonth_start_time, sixmonth_end_time,
                   sixmonth_pivot_color, sm_label_color, pivot_line_width, 25, sm_pp_suffix))

        // Six-Month S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("6mR1", sixmonth_r1, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 24))
            array.push(current_levels, TimeBasedLevel.new("6mS1", sixmonth_s1, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 23))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("6mR2", sixmonth_r2, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 22))
            array.push(current_levels, TimeBasedLevel.new("6mS2", sixmonth_s2, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 21))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("6mR3", sixmonth_r3, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 20))
            array.push(current_levels, TimeBasedLevel.new("6mS3", sixmonth_s3, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 19))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("6mR4", sixmonth_r4, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 18))
            array.push(current_levels, TimeBasedLevel.new("6mS4", sixmonth_s4, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 17))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("6mR5", sixmonth_r5, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 16))
            array.push(current_levels, TimeBasedLevel.new("6mS5", sixmonth_s5, sixmonth_start_time, sixmonth_end_time,
                       sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, 15))

        // Historical Six-Month Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_sixmonth_start_time) and not na(sixmonth_start_time)
            sixmonth_pivot2 = calcPivot(sixmonth_h2, sixmonth_l2, sixmonth_c2)
            prev_sixmonth_end_time = sixmonth_start_time
            drawAndTrackLevel(prev_sixmonth_start_time, prev_sixmonth_end_time, sixmonth_pivot2, adjustTransparency(sixmonth_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_sixmonth_end_time, sixmonth_pivot2, "6mPP " + str.tostring(sixmonth_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(sixmonth_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Six-Month Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_sixmonth_start_time_2) and not na(prev_sixmonth_start_time)
            sixmonth_pivot3 = calcPivot(sixmonth_h3, sixmonth_l3, sixmonth_c3)
            prev_sixmonth_end_time_2 = prev_sixmonth_start_time
            drawAndTrackLevel(prev_sixmonth_start_time_2, prev_sixmonth_end_time_2, sixmonth_pivot3, adjustTransparency(sixmonth_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_sixmonth_end_time_2, sixmonth_pivot3, "6mPP " + str.tostring(sixmonth_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(sixmonth_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // Yearly Pivots (current period only)
    if show_yearly_pivots and not na(year_start_time)
        year_end_time = getPeriodEndTime(year_start_time, "12M")
        y_label_color = yearly_pivot_color
        y_current_untapped = show_untested_pivot_marker and not yearly_pivot_hit
        y_hist_untapped = countConsecutiveFromEnd(yearly_pivot_hit_history, 0, consecutive_marker_count)
        y_total_consec = y_current_untapped ? 1 + y_hist_untapped : 0
        y_marker_visible = y_total_consec >= 2
        y_dot_count = y_marker_visible ? math.min(y_total_consec, consecutive_marker_count) : 0
        y_prefix = makeDots(y_dot_count)
        y_pct_visible = show_tap_percentages and (not pct_show_only_with_marker or y_marker_visible)
        y_tap_pct = y_pct_visible ? computePct(yearly_pivot_hit_history, 1, stats_lookback_periods) : float(na)
        y_pp_suffix = not na(y_tap_pct) ? str.tostring(y_tap_pct, "#") + "%" : ""
        array.push(current_levels, TimeBasedLevel.new(y_prefix + "yPP", yearly_pivot, year_start_time, year_end_time,
                   yearly_pivot_color, y_label_color, pivot_line_width, 20, y_pp_suffix))

        // Yearly S/R Levels
        if pivot_levels >= 1
            array.push(current_levels, TimeBasedLevel.new("yR1", yearly_r1, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 19))
            array.push(current_levels, TimeBasedLevel.new("yS1", yearly_s1, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 18))
        if pivot_levels >= 2
            array.push(current_levels, TimeBasedLevel.new("yR2", yearly_r2, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 17))
            array.push(current_levels, TimeBasedLevel.new("yS2", yearly_s2, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 16))
        if pivot_levels >= 3
            array.push(current_levels, TimeBasedLevel.new("yR3", yearly_r3, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 15))
            array.push(current_levels, TimeBasedLevel.new("yS3", yearly_s3, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 14))
        if pivot_levels >= 4
            array.push(current_levels, TimeBasedLevel.new("yR4", yearly_r4, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 13))
            array.push(current_levels, TimeBasedLevel.new("yS4", yearly_s4, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 12))
        if pivot_levels >= 5
            array.push(current_levels, TimeBasedLevel.new("yR5", yearly_r5, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 11))
            array.push(current_levels, TimeBasedLevel.new("yS5", yearly_s5, year_start_time, year_end_time,
                       yearly_pivot_color, yearly_pivot_color, pivot_line_width, 10))

        // Historical Yearly Pivots (period 2)
        if pivot_periods_back >= 2 and not na(prev_year_start_time) and not na(year_start_time)
            yearly_pivot2 = calcPivot(yearly_h2, yearly_l2, yearly_c2)
            prev_year_end_time = year_start_time
            drawAndTrackLevel(prev_year_start_time, prev_year_end_time, yearly_pivot2, adjustTransparency(yearly_pivot_color, 60), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_year_end_time, yearly_pivot2, "yPP " + str.tostring(yearly_pivot2, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(yearly_pivot_color, 60), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

        // Historical Yearly Pivots (period 3)
        if pivot_periods_back >= 3 and not na(prev_year_start_time_2) and not na(prev_year_start_time)
            yearly_pivot3 = calcPivot(yearly_h3, yearly_l3, yearly_c3)
            prev_year_end_time_2 = prev_year_start_time
            drawAndTrackLevel(prev_year_start_time_2, prev_year_end_time_2, yearly_pivot3, adjustTransparency(yearly_pivot_color, 80), pivot_line_width, pivot_style)
            if show_level_labels
                array.push(all_labels, label.new(prev_year_end_time_2, yearly_pivot3, "yPP " + str.tostring(yearly_pivot3, format.mintick),
                         xloc=xloc.bar_time, color=na, textcolor=adjustTransparency(yearly_pivot_color, 80), textalign=text.align_left,
                         style=label.style_label_left, size=getLabelSize(label_size)))

    // ═══════════════════════════════════════════════════════════
    // DRAW ALL GROUPED CURRENT PERIOD LEVELS
    // ═══════════════════════════════════════════════════════════
    drawGroupedTimeLevels(current_levels)

// ═══════════════════════════════════════════════════════════════════════════════
// OLD BAR-INDEX GROUPED LEVEL SYSTEM (DISABLED - replaced by time-based drawing)
// ═══════════════════════════════════════════════════════════════════════════════

if false and barstate.islast
    // Collect ALL levels (pivots, opens, previous periods) for grouping
    var all_levels = array.new<LevelData>()
    array.clear(all_levels)

    // Add Previous Day levels
    if show_prev_day and not na(prev_day_start_bar) and prev_day_start_bar > 0
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        pd_start_bar = math.max(prev_day_start_bar, bar_index - 350)
        pd_label_color = show_inside_bar_marker and is_inside_prev_day and not prev_day_range_broken ? color.orange : adjustTransparency(prev_day_color, 0)
        pd_prefix = show_inside_bar_marker and is_inside_prev_day and not prev_day_range_broken ? "● " : ""
        array.push(all_levels, LevelData.new(pd_prefix + "pdHigh", prev_day_high, adjustTransparency(prev_day_color, 60), pd_label_color, prev_line_width, "Solid", pd_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pd_prefix + "pdEQ", prev_day_eq, adjustTransparency(prev_day_color, 20), pd_label_color, prev_line_width, "Solid", pd_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pd_prefix + "pdLow", prev_day_low, adjustTransparency(prev_day_color, 60), pd_label_color, prev_line_width, "Solid", pd_start_bar, na, true, 20))

    // Add Previous Week levels
    if show_prev_week and not na(prev_week_start_bar) and prev_week_start_bar > 0
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        pw_start_bar = math.max(prev_week_start_bar, bar_index - 350)
        pw_label_color = show_inside_bar_marker and is_inside_prev_week and not prev_week_range_broken ? color.orange : adjustTransparency(prev_week_color, 0)
        pw_prefix = show_inside_bar_marker and is_inside_prev_week and not prev_week_range_broken ? "● " : ""
        array.push(all_levels, LevelData.new(pw_prefix + "pwHigh", prev_week_high, adjustTransparency(prev_week_color, 60), pw_label_color, prev_line_width, "Solid", pw_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pw_prefix + "pwEQ", prev_week_eq, adjustTransparency(prev_week_color, 20), pw_label_color, prev_line_width, "Solid", pw_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pw_prefix + "pwLow", prev_week_low, adjustTransparency(prev_week_color, 60), pw_label_color, prev_line_width, "Solid", pw_start_bar, na, true, 20))

    // Add Previous Month levels
    if show_prev_month and not na(prev_month_start_bar) and prev_month_start_bar > 0
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        pm_start_bar = math.max(prev_month_start_bar, bar_index - 350)
        pm_label_color = show_inside_bar_marker and is_inside_prev_month and not prev_month_range_broken ? color.orange : adjustTransparency(prev_month_color, 0)
        pm_prefix = show_inside_bar_marker and is_inside_prev_month and not prev_month_range_broken ? "● " : ""
        array.push(all_levels, LevelData.new(pm_prefix + "pmHigh", prev_month_high, adjustTransparency(prev_month_color, 60), pm_label_color, prev_line_width, "Solid", pm_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pm_prefix + "pmEQ", prev_month_eq, adjustTransparency(prev_month_color, 20), pm_label_color, prev_line_width, "Solid", pm_start_bar, na, true, 20))
        array.push(all_levels, LevelData.new(pm_prefix + "pmLow", prev_month_low, adjustTransparency(prev_month_color, 60), pm_label_color, prev_line_width, "Solid", pm_start_bar, na, true, 20))

    // Add Daily Pivots
    if show_daily_pivots
        start_bar = not na(day_start_bar) ? day_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            d_label_color = show_untested_pivot_marker and not prev_daily_pivot_was_hit ? color.orange : daily_pivot_color
            d_prefix = show_untested_pivot_marker and not prev_daily_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(d_prefix + "dPP", daily_pivot, daily_pivot_color, d_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("dR1", daily_r1, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("dS1", daily_s1, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("dR2", daily_r2, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("dS2", daily_s2, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("dR3", daily_r3, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("dS3", daily_s3, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("dR4", daily_r4, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("dS4", daily_s4, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("dR5", daily_r5, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("dS5", daily_s5, daily_pivot_color, daily_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // Add Weekly Pivots
    if show_weekly_pivots
        start_bar = not na(week_start_bar) ? week_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            w_label_color = show_untested_pivot_marker and not prev_weekly_pivot_was_hit ? color.orange : weekly_pivot_color
            w_prefix = show_untested_pivot_marker and not prev_weekly_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(w_prefix + "wPP", weekly_pivot, weekly_pivot_color, w_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("wR1", weekly_r1, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("wS1", weekly_s1, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("wR2", weekly_r2, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("wS2", weekly_s2, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("wR3", weekly_r3, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("wS3", weekly_s3, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("wR4", weekly_r4, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("wS4", weekly_s4, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("wR5", weekly_r5, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("wS5", weekly_s5, weekly_pivot_color, weekly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // Add Monthly Pivots
    if show_monthly_pivots
        start_bar = not na(month_start_bar) ? month_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            m_label_color = show_untested_pivot_marker and not prev_monthly_pivot_was_hit ? color.orange : monthly_pivot_color
            m_prefix = show_untested_pivot_marker and not prev_monthly_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(m_prefix + "mPP", monthly_pivot, monthly_pivot_color, m_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("mR1", monthly_r1, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("mS1", monthly_s1, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("mR2", monthly_r2, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("mS2", monthly_s2, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("mR3", monthly_r3, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("mS3", monthly_s3, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("mR4", monthly_r4, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("mS4", monthly_s4, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("mR5", monthly_r5, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("mS5", monthly_s5, monthly_pivot_color, monthly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // EXPERIMENTAL: Test time-based drawing for monthly pivot (bypasses bar index buffer limits)
    // This draws a BLUE line using time coordinates to compare with the regular monthly pivot
    if show_monthly_pivots and barstate.islast and not na(month_start_time)
        drawAndTrackLevel(month_start_time, time, monthly_pivot, color.new(color.blue, 0), 3, pivot_style)
        if show_level_labels
            array.push(all_labels, label.new(time, monthly_pivot, "mPP (TIME) " + str.tostring(monthly_pivot, format.mintick),
                     xloc=xloc.bar_time, color=na, textcolor=color.blue, textalign=text.align_left,
                     style=label.style_label_left, size=getLabelSize(label_size)))

    // Add Quarterly Pivots
    if show_quarterly_pivots
        start_bar = not na(quarter_start_bar) ? quarter_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            q_label_color = show_untested_pivot_marker and not prev_quarterly_pivot_was_hit ? color.orange : quarterly_pivot_color
            q_prefix = show_untested_pivot_marker and not prev_quarterly_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(q_prefix + "qPP", quarterly_pivot, quarterly_pivot_color, q_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("qR1", quarterly_r1, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("qS1", quarterly_s1, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("qR2", quarterly_r2, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("qS2", quarterly_s2, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("qR3", quarterly_r3, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("qS3", quarterly_s3, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("qR4", quarterly_r4, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("qS4", quarterly_s4, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("qR5", quarterly_r5, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("qS5", quarterly_s5, quarterly_pivot_color, quarterly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // Add Six-Month Pivots
    if show_sixmonth_pivots
        start_bar = not na(sixmonth_start_bar) ? sixmonth_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            sm_label_color = show_untested_pivot_marker and not prev_sixmonth_pivot_was_hit ? color.orange : sixmonth_pivot_color
            sm_prefix = show_untested_pivot_marker and not prev_sixmonth_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(sm_prefix + "6mPP", sixmonth_pivot, sixmonth_pivot_color, sm_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("6mR1", sixmonth_r1, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("6mS1", sixmonth_s1, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("6mR2", sixmonth_r2, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("6mS2", sixmonth_s2, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("6mR3", sixmonth_r3, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("6mS3", sixmonth_s3, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("6mR4", sixmonth_r4, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("6mS4", sixmonth_s4, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("6mR5", sixmonth_r5, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("6mS5", sixmonth_s5, sixmonth_pivot_color, sixmonth_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // Add Yearly Pivots
    if show_yearly_pivots
        start_bar = not na(year_start_bar) ? year_start_bar : math.max(0, bar_index - 500)
        end_bar = bar_index
        end_bar := math.max(end_bar, start_bar + 1)
        if start_bar > 0 and bar_index - start_bar < 350
            y_label_color = show_untested_pivot_marker and not prev_yearly_pivot_was_hit ? color.orange : yearly_pivot_color
            y_prefix = show_untested_pivot_marker and not prev_yearly_pivot_was_hit ? "● " : ""
            array.push(all_levels, LevelData.new(y_prefix + "yPP", yearly_pivot, yearly_pivot_color, y_label_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 1
                array.push(all_levels, LevelData.new("yR1", yearly_r1, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("yS1", yearly_s1, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 2
                array.push(all_levels, LevelData.new("yR2", yearly_r2, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("yS2", yearly_s2, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 3
                array.push(all_levels, LevelData.new("yR3", yearly_r3, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("yS3", yearly_s3, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 4
                array.push(all_levels, LevelData.new("yR4", yearly_r4, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("yS4", yearly_s4, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
            if pivot_levels >= 5
                array.push(all_levels, LevelData.new("yR5", yearly_r5, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))
                array.push(all_levels, LevelData.new("yS5", yearly_s5, yearly_pivot_color, yearly_pivot_color, pivot_line_width, pivot_line_style, start_bar, end_bar, false, 3))

    // Add Period Opens
    if show_daily_open
        start_bar = not na(day_start_bar) ? day_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("dOpen", daily_open, daily_open_color, daily_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    if show_weekly_open
        start_bar = not na(week_start_bar) ? week_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("wOpen", weekly_open, weekly_open_color, weekly_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    if show_monthly_open
        start_bar = not na(month_start_bar) ? month_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("mOpen", monthly_open, monthly_open_color, monthly_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    if show_quarterly_open
        start_bar = not na(quarter_start_bar) ? quarter_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("qOpen", quarterly_open, quarterly_open_color, quarterly_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    if show_sixmonth_open
        start_bar = not na(sixmonth_start_bar) ? sixmonth_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("6mOpen", sixmonth_open, sixmonth_open_color, sixmonth_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    if show_yearly_open
        start_bar = not na(year_start_bar) ? year_start_bar : math.max(0, bar_index - 500)
        // Adjust start_bar to stay within buffer limits while maintaining correct price level
        start_bar := math.max(start_bar, bar_index - 350)
        array.push(all_levels, LevelData.new("yOpen", yearly_open, yearly_open_color, yearly_open_color, open_line_width, open_line_style, start_bar, na, true, 20))

    // Draw all grouped levels (pivots + opens + previous periods)
    drawGroupedLevels(all_levels)
````

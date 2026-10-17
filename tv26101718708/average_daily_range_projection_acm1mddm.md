# Average Daily Range Projection

- url: https://www.tradingview.com/script/AcM1mDdM-Average-Daily-Range-Projection/
- type: indicator
- pine_id: PUB;b2f46356f4274713958587b01a0d38e4
- version: 2.0

## Description

WHAT IT DOES

The Average Daily Range (ADR) Projection converts a historical average range into live price levels based on the range already realized during the current session.

Rather than anchoring fixed ADR bands to the session open or another single reference price, the indicator conditions each projection on the session's developing high and low. It answers a specific question: given the range already traded, where would price need to reach for this session to equal its recent average range?

Two independent sets let you compare separate baselines, such as the regular trading session versus the full futures session or a short lookback versus a longer one. This shows when price has satisfied one definition of its typical range while remaining below another.

CALCULATION

For each set, the indicator averages high minus low over up to the most recent N completed session windows. The ADR is fixed at the start of a new session; only the projected prices change as the current high and low develop. A partial session encountered when the script first loads is excluded.

Let ADR be the historical average, H the current session high, and L the current session low:

[pine]    remaining        = max(ADR - (H - L), 0)
    upper projection = H + remaining
    lower projection = L - remaining[/pine]

Before the session has completed its ADR, these reduce to:

[pine]    upper projection = L + ADR
    lower projection = H - ADR[/pine]

These are conditional range-completion thresholds. A new high raises the lower projection, while a new low lowers the upper projection. As realized range expands, the additional movement required to equal ADR decreases. A reached threshold freezes and is labeled FILLED.

HOW TO READ IT

An open projection marks the price that would complete the configured average range in that direction, assuming the opposite session extreme does not change first. Its distance from price represents remaining range relative to the benchmark, not a prediction that price will reach it.

A FILLED label means the session range has reached or exceeded that set's trailing mean. If one set is filled while the other remains open, the session has satisfied one baseline but not the other.

Previous-session lines may be retained to review completed thresholds on the selected instrument and timeframe.

INPUTS

ADR Period sets the maximum number of completed sessions in each average. During initial data collection, the indicator starts after one complete session and uses the available sample until the selected period is populated.

Session Start, Session End, and Timezone define each measurement window; overnight windows are supported. Set 1 and Set 2 may use different windows, ADR periods, and styling. Show Previous Sessions retains completed levels, while Max Previous Sessions limits their number. Other controls manage labels, first-fill emphasis, and the optional information table.

The default Pacific-time windows are:

[list]
[*]Set 1: 06:30 to 13:55, 14-session ADR
[*]Set 2: 15:00 to 13:55, 14-session ADR
[/list]

ALERTS

Four alert conditions cover upper and lower fills for both sets.

LIMITATIONS AND CALCULATION BEHAVIOR

ADR is a trailing sample mean, not a percentile, confidence interval, forecast, or estimate of reversal probability. Reaching it does not establish that a move is rare, exhausted, or likely to reverse. Outliers and volatility-regime changes can materially affect the average.

The script does not use future data or lookahead and does not repaint completed levels from future information. Active projections intentionally update as the session high or low changes, including during an open realtime bar. Completed-session lines show final or filled levels, not every level occupied intraday. Label Offset moves labels to the right for readability only; it does not reference future prices.

Calculations use extended-hours data so a full-session window remains intact on a regular-hours chart. Results depend on the data supplied by the symbol's feed, and an off-chart fill may already be marked when the next visible bar opens.

Designed for intraday charts with standard candles. Synthetic chart types can produce ranges and alerts based on synthetic prices rather than actual traded OHLC values.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Macrodoser

//@version=6

indicator(title="ADR Projection", shorttitle="ADR Proj", overlay=true, max_lines_count=500, max_labels_count=500)

// === SESSION SETTINGS ===

group_session = "SESSION SETTINGS"

sess_timezone = input.string("America/Los_Angeles", title="Timezone", options=["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney"], group=group_session, tooltip="Timezone for both ADR session windows. Session data is always pulled from the extended-hours feed, so ranges stay correct whether the chart is set to regular or electronic trading hours.")

// === ADR SET 1 SETTINGS ===

group_set1 = "ADR SET 1"

show_set1 = input.bool(true, title="Show Set 1", group=group_set1)

adr_period_1 = input.int(14, title="ADR Period", minval=1, group=group_set1, tooltip="Number of sessions to average for ADR Set 1.")

sess1_start_hour = input.int(6, title="Session Start Hour", minval=0, maxval=23, group=group_set1, tooltip="Session window for Set 1. Daily ranges are measured inside this window, the session high/low is tracked inside it, and the projection lines are only drawn inside it. Default is the regular trading session (6:30 - 13:55 Pacific).")

sess1_start_minute = input.int(30, title="Session Start Minute", minval=0, maxval=59, group=group_set1)

sess1_end_hour = input.int(13, title="Session End Hour", minval=0, maxval=23, group=group_set1)

sess1_end_minute = input.int(55, title="Session End Minute", minval=0, maxval=59, group=group_set1)

upper_color_1 = input.color(#03FF00, title="Upper Target Color", group=group_set1)

lower_color_1 = input.color(#FF1001, title="Lower Target Color", group=group_set1)

line_width_1 = input.int(2, title="Line Width", minval=1, maxval=5, group=group_set1)

line_style_1 = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=group_set1)

bold_first_1 = input.bool(true, title="Bold First Filled Line Label", group=group_set1, tooltip="Bolds the label of whichever target line was touched first in the session.")

fade_opposite_1 = input.bool(true, title="Fade Opposite Extreme on Fill", group=group_set1, tooltip="Once one target line fills first, the opposite line is drawn at 33% opacity so it's clear which side was hit first.")

show_labels_1 = input.bool(true, title="Show Labels", group=group_set1)

show_previous_1 = input.bool(true, title="Show Previous Sessions", group=group_set1)

show_prev_labels_1 = input.bool(true, title="Show Previous Session Labels", group=group_set1, tooltip="Turn off to keep previous sessions' lines but hide their labels, which can overlap price action on regular-hours charts.")

max_previous_1 = input.int(30, title="Max Previous Sessions", minval=1, maxval=100, group=group_set1)

// === ADR SET 2 SETTINGS ===

group_set2 = "ADR SET 2"

show_set2 = input.bool(true, title="Show Set 2", group=group_set2)

adr_period_2 = input.int(14, title="ADR Period", minval=1, group=group_set2, tooltip="Number of sessions to average for ADR Set 2.")

sess2_start_hour = input.int(15, title="Session Start Hour", minval=0, maxval=23, group=group_set2, tooltip="Session window for Set 2. Daily ranges are measured inside this window, the session high/low is tracked inside it, and the projection lines are only drawn inside it. Default is the full futures day (15:00 - 13:55 Pacific). Overnight data comes from the extended-hours feed, so this stays a true full-day range even on an RTH chart.")

sess2_start_minute = input.int(0, title="Session Start Minute", minval=0, maxval=59, group=group_set2)

sess2_end_hour = input.int(13, title="Session End Hour", minval=0, maxval=23, group=group_set2)

sess2_end_minute = input.int(55, title="Session End Minute", minval=0, maxval=59, group=group_set2)

upper_color_2 = input.color(#00E2FF, title="Upper Target Color", group=group_set2)

lower_color_2 = input.color(#FF00FF, title="Lower Target Color", group=group_set2)

line_width_2 = input.int(2, title="Line Width", minval=1, maxval=5, group=group_set2)

line_style_2 = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group=group_set2)

bold_first_2 = input.bool(true, title="Bold First Filled Line Label", group=group_set2, tooltip="Bolds the label of whichever target line was touched first in the session.")

fade_opposite_2 = input.bool(true, title="Fade Opposite Extreme on Fill", group=group_set2, tooltip="Once one target line fills first, the opposite line is drawn at 33% opacity so it's clear which side was hit first.")

show_labels_2 = input.bool(true, title="Show Labels", group=group_set2)

show_previous_2 = input.bool(true, title="Show Previous Sessions", group=group_set2)

show_prev_labels_2 = input.bool(true, title="Show Previous Session Labels", group=group_set2, tooltip="Turn off to keep previous sessions' lines but hide their labels, which can overlap price action on regular-hours charts.")

max_previous_2 = input.int(30, title="Max Previous Sessions", minval=1, maxval=100, group=group_set2)

// === DISPLAY SETTINGS ===

group_display = "DISPLAY SETTINGS"

label_size_input = input.string("Small", title="Label Size", options=["Tiny", "Small", "Normal", "Large"], group=group_display)

label_offset = input.int(5, title="Label Offset (Bars)", minval=0, maxval=100, group=group_display, tooltip="How many bars to the right of the line's edge the labels sit.")

show_table = input.bool(false, title="Show Info Table", group=group_display)

// === HELPER FUNCTIONS ===

get_line_style(style_str) =>
    switch style_str
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

get_label_size(size_str) =>
    switch size_str
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

// === SESSION DETECTION FUNCTIONS ===

// Helper function to check if we're in a time window (handles overnight sessions)
is_in_time_window(int current_mins, int start_mins, int end_mins) =>
    if start_mins < end_mins
        // Same-day session (e.g., 9:30 to 16:00)
        current_mins >= start_mins and current_mins < end_mins
    else
        // Overnight session (e.g., 15:00 to 14:00 next day)
        current_mins >= start_mins or current_mins < end_mins

// Session-day detection: shift each bar's time so the session start maps to midnight,
// then fire on the first bar whose shifted calendar date differs from the previous bar's.
is_new_session_day(int start_mins, string tz) =>
    shifted = time - start_mins * 60000
    d = year(shifted, tz) * 10000 + month(shifted, tz) * 100 + dayofmonth(shifted, tz)
    not na(d[1]) and d != d[1]

// Session range tracker. This runs inside request.security() on the EXTENDED-HOURS
// version of the symbol, so it sees every bar of the session window (including
// overnight bars) no matter which session type the chart itself is displaying.
// The ADR average and the breach/first-touch detection also live in here, so they are
// computed bar-by-bar on the extended-hours feed and stay correct even when the fill
// happens on bars the chart doesn't display (e.g., overnight on an RTH chart).
// Returns:
//   day_id         - increments each time a new session starts (sampled changes = new session on the chart)
//   s_high/low     - running high/low of the current session window
//   active         - true while inside the session window
//   sess_adr       - ADR average for the current session (na until enough history)
//   up/dn_breached - whether each target has been hit this session
//   frozen_up/dn   - the target level at the moment it was hit
//   first_side     - 1 = upper hit first, 2 = lower hit first, 0 = none/ambiguous
//   fill_count     - number of completed ranges currently in the average
f_track_session(int start_mins, int end_mins, string tz, int adr_period) =>
    var float s_high = na
    var float s_low = na
    var bool active = false
    var bool partial = false
    var int day_id = 0
    var array<float> ranges = array.new_float()
    var float sess_adr = na
    var bool up_breached = false
    var bool dn_breached = false
    var float frozen_up = na
    var float frozen_dn = na
    var int first_side = 0
    cur = hour(time, tz) * 60 + minute(time, tz)
    prv = hour(time[1], tz) * 60 + minute(time[1], tz)
    in_win = is_in_time_window(cur, start_mins, end_mins)
    was_in = is_in_time_window(prv, start_mins, end_mins)
    new_day = is_new_session_day(start_mins, tz)
    s_start = in_win and (new_day or not active)
    s_end = was_in and not in_win
    // Finalize the previous session's range: when price leaves the window, or at the
    // next session start if the end time never printed (data gaps/holidays)
    if active and (s_end or (s_start and new_day))
        r = s_high - s_low
        if not partial and not na(r) and r > 0
            array.push(ranges, r)
            while array.size(ranges) > adr_period
                array.shift(ranges)
        active := false
    if s_start
        sess_adr := array.size(ranges) > 0 ? array.avg(ranges) : na
        up_breached := false
        dn_breached := false
        frozen_up := na
        frozen_dn := na
        first_side := 0
        s_high := high
        s_low := low
        active := true
        // A session started mid-window (chart start) is incomplete - don't store its range
        partial := not new_day
        day_id += 1
    else if active and in_win
        s_high := math.max(s_high, high)
        s_low := math.min(s_low, low)
    // Breach check against targets derived from the previous bar's session state
    // (so the target freezes at its pre-breach level)
    if active and not s_start and not na(sess_adr) and not na(s_high[1]) and not na(s_low[1])
        pre_rem = math.max(0, sess_adr - (s_high[1] - s_low[1]))
        pre_up_t = s_high[1] + pre_rem
        pre_dn_t = s_low[1] - pre_rem
        hit_up = not up_breached and s_high >= pre_up_t
        hit_dn = not dn_breached and s_low <= pre_dn_t
        // Record which side filled first (both on the same bar = ambiguous, neither)
        if hit_up and not hit_dn and not dn_breached and first_side == 0
            first_side := 1
        if hit_dn and not hit_up and not up_breached and first_side == 0
            first_side := 2
        if hit_up
            frozen_up := pre_up_t
            up_breached := true
        if hit_dn
            frozen_dn := pre_dn_t
            dn_breached := true
    [day_id, s_high, s_low, active, sess_adr, up_breached, dn_breached, frozen_up, frozen_dn, first_side, array.size(ranges)]

  

// === SESSION TRACKING (extended-hours data feed) ===

eth_ticker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)



sess1_start_mins = sess1_start_hour * 60 + sess1_start_minute

sess1_end_mins = sess1_end_hour * 60 + sess1_end_minute

sess2_start_mins = sess2_start_hour * 60 + sess2_start_minute

sess2_end_mins = sess2_end_hour * 60 + sess2_end_minute



[sday_1, sess_high_1, sess_low_1, sess_active_1, session_adr_1, upper_breached_1, lower_breached_1, frozen_upper_target_1, frozen_lower_target_1, first_side_1, ranges_count_1] = request.security(eth_ticker, timeframe.period, f_track_session(sess1_start_mins, sess1_end_mins, sess_timezone, adr_period_1))

[sday_2, sess_high_2, sess_low_2, sess_active_2, session_adr_2, upper_breached_2, lower_breached_2, frozen_upper_target_2, frozen_lower_target_2, first_side_2, ranges_count_2] = request.security(eth_ticker, timeframe.period, f_track_session(sess2_start_mins, sess2_end_mins, sess_timezone, adr_period_2))

  

// === ADR SET 1 TRACKING ===

var line upper_line_1 = na

var line lower_line_1 = na

var label upper_label_1 = na

var label lower_label_1 = na

var array<line> prev_upper_lines_1 = array.new_line()

var array<line> prev_lower_lines_1 = array.new_line()

var array<label> prev_upper_labels_1 = array.new_label()

var array<label> prev_lower_labels_1 = array.new_label()

  

// === ADR SET 2 TRACKING ===

var line upper_line_2 = na

var line lower_line_2 = na

var label upper_label_2 = na

var label lower_label_2 = na

var array<line> prev_upper_lines_2 = array.new_line()

var array<line> prev_lower_lines_2 = array.new_line()

var array<label> prev_upper_labels_2 = array.new_label()

var array<label> prev_lower_labels_2 = array.new_label()

  

// === LINE ARRAY MANAGEMENT ===

manage_line_array(array<line> arr, int max_size) =>
    while array.size(arr) > max_size
        old_line = array.shift(arr)
        line.delete(old_line)

manage_label_array(array<label> arr, int max_size) =>
    while array.size(arr) > max_size
        old_label = array.shift(arr)
        label.delete(old_label)

  

// === SESSION START DETECTION (chart display) ===

// A new session shows on the chart when the sampled session-day id changes, or when
// the session becomes active again after inactive bars (e.g., the RTH open on an ETH chart).
// (v6: bools are never na, so sess_active[1] is simply false on the first bar.)

sess1_session_start = sess_active_1 and (not sess_active_1[1] or (not na(sday_1[1]) and sday_1 != sday_1[1]))

sess2_session_start = sess_active_2 and (not sess_active_2[1] or (not na(sday_2[1]) and sday_2 != sday_2[1]))

  

// === PROCESS ADR SET 1 SESSION ===

// Session start: archive or clear the old drawings and create fresh ones (the ADR
// value and breach state arrive pre-computed from the extended-hours tracker)

if sess1_session_start
    if show_set1
        if show_previous_1
            if not na(upper_line_1)
                array.push(prev_upper_lines_1, upper_line_1)
                manage_line_array(prev_upper_lines_1, max_previous_1)
            if not na(lower_line_1)
                array.push(prev_lower_lines_1, lower_line_1)
                manage_line_array(prev_lower_lines_1, max_previous_1)
            if show_prev_labels_1
                if not na(upper_label_1)
                    array.push(prev_upper_labels_1, upper_label_1)
                    manage_label_array(prev_upper_labels_1, max_previous_1)
                if not na(lower_label_1)
                    array.push(prev_lower_labels_1, lower_label_1)
                    manage_label_array(prev_lower_labels_1, max_previous_1)
            else
                label.delete(upper_label_1)
                label.delete(lower_label_1)
        else
            line.delete(upper_line_1)
            line.delete(lower_line_1)
            label.delete(upper_label_1)
            label.delete(lower_label_1)
        if not na(session_adr_1) and not na(sess_high_1) and not na(sess_low_1)
            initial_remaining_1 = math.max(0, session_adr_1 - (sess_high_1 - sess_low_1))
            // If a side already filled on bars the chart doesn't display, start from its frozen level
            up_y_1 = upper_breached_1 and not na(frozen_upper_target_1) ? frozen_upper_target_1 : sess_high_1 + initial_remaining_1
            dn_y_1 = lower_breached_1 and not na(frozen_lower_target_1) ? frozen_lower_target_1 : sess_low_1 - initial_remaining_1
            // Fade the line opposite the first-filled side (a fill can already exist here if it happened on hidden overnight bars)
            up_col_1 = fade_opposite_1 and first_side_1 == 2 ? color.new(upper_color_1, 67) : upper_color_1
            dn_col_1 = fade_opposite_1 and first_side_1 == 1 ? color.new(lower_color_1, 67) : lower_color_1
            upper_line_1 := line.new(bar_index, up_y_1, bar_index, up_y_1, color=up_col_1, width=line_width_1, style=get_line_style(line_style_1))
            lower_line_1 := line.new(bar_index, dn_y_1, bar_index, dn_y_1, color=dn_col_1, width=line_width_1, style=get_line_style(line_style_1))
            if show_labels_1
                up_txt_1 = (upper_breached_1 ? "ADR1 FILLED: " : "ADR1 Upper: ") + str.tostring(up_y_1, format.mintick)
                dn_txt_1 = (lower_breached_1 ? "ADR1 FILLED: " : "ADR1 Lower: ") + str.tostring(dn_y_1, format.mintick)
                upper_label_1 := label.new(bar_index + label_offset, up_y_1, text=up_txt_1, style=label.style_label_left, color=color.new(upper_color_1, 80), textcolor=upper_color_1, size=get_label_size(label_size_input), text_formatting=bold_first_1 and first_side_1 == 1 ? text.format_bold : text.format_none)
                lower_label_1 := label.new(bar_index + label_offset, dn_y_1, text=dn_txt_1, style=label.style_label_left, color=color.new(lower_color_1, 80), textcolor=lower_color_1, size=get_label_size(label_size_input), text_formatting=bold_first_1 and first_side_1 == 2 ? text.format_bold : text.format_none)
        else
            upper_line_1 := na
            lower_line_1 := na
            upper_label_1 := na
            lower_label_1 := na



// Update lines during the session - handle upper and lower lines independently

if show_set1 and sess_active_1 and not sess1_session_start and not na(upper_line_1) and not na(lower_line_1) and not na(session_adr_1)
    new_remaining_1 = math.max(0, session_adr_1 - (sess_high_1 - sess_low_1))
    // Fade whichever line is opposite the first-filled side (first_side updates mid-session)
    line.set_color(upper_line_1, fade_opposite_1 and first_side_1 == 2 ? color.new(upper_color_1, 67) : upper_color_1)
    line.set_color(lower_line_1, fade_opposite_1 and first_side_1 == 1 ? color.new(lower_color_1, 67) : lower_color_1)
    // Upper line: use frozen value if breached, otherwise calculate dynamically
    if upper_breached_1
        line.set_x2(upper_line_1, bar_index)
        line.set_y1(upper_line_1, frozen_upper_target_1)
        line.set_y2(upper_line_1, frozen_upper_target_1)
        if show_labels_1 and not na(upper_label_1)
            label.set_x(upper_label_1, bar_index + label_offset)
            label.set_y(upper_label_1, frozen_upper_target_1)
            label.set_text(upper_label_1, "ADR1 FILLED: " + str.tostring(frozen_upper_target_1, format.mintick))
            label.set_text_formatting(upper_label_1, bold_first_1 and first_side_1 == 1 ? text.format_bold : text.format_none)
    else
        new_upper_target_1 = sess_high_1 + new_remaining_1
        line.set_x2(upper_line_1, bar_index)
        line.set_y1(upper_line_1, new_upper_target_1)
        line.set_y2(upper_line_1, new_upper_target_1)
        if show_labels_1 and not na(upper_label_1)
            label.set_x(upper_label_1, bar_index + label_offset)
            label.set_y(upper_label_1, new_upper_target_1)
            label.set_text(upper_label_1, "ADR1 Upper: " + str.tostring(new_upper_target_1, format.mintick))
    // Lower line: use frozen value if breached, otherwise calculate dynamically
    if lower_breached_1
        line.set_x2(lower_line_1, bar_index)
        line.set_y1(lower_line_1, frozen_lower_target_1)
        line.set_y2(lower_line_1, frozen_lower_target_1)
        if show_labels_1 and not na(lower_label_1)
            label.set_x(lower_label_1, bar_index + label_offset)
            label.set_y(lower_label_1, frozen_lower_target_1)
            label.set_text(lower_label_1, "ADR1 FILLED: " + str.tostring(frozen_lower_target_1, format.mintick))
            label.set_text_formatting(lower_label_1, bold_first_1 and first_side_1 == 2 ? text.format_bold : text.format_none)
    else
        new_lower_target_1 = sess_low_1 - new_remaining_1
        line.set_x2(lower_line_1, bar_index)
        line.set_y1(lower_line_1, new_lower_target_1)
        line.set_y2(lower_line_1, new_lower_target_1)
        if show_labels_1 and not na(lower_label_1)
            label.set_x(lower_label_1, bar_index + label_offset)
            label.set_y(lower_label_1, new_lower_target_1)
            label.set_text(lower_label_1, "ADR1 Lower: " + str.tostring(new_lower_target_1, format.mintick))



// === PROCESS ADR SET 2 SESSION ===

// Session start: archive or clear the old drawings and create fresh ones (the ADR
// value and breach state arrive pre-computed from the extended-hours tracker)

if sess2_session_start
    if show_set2
        if show_previous_2
            if not na(upper_line_2)
                array.push(prev_upper_lines_2, upper_line_2)
                manage_line_array(prev_upper_lines_2, max_previous_2)
            if not na(lower_line_2)
                array.push(prev_lower_lines_2, lower_line_2)
                manage_line_array(prev_lower_lines_2, max_previous_2)
            if show_prev_labels_2
                if not na(upper_label_2)
                    array.push(prev_upper_labels_2, upper_label_2)
                    manage_label_array(prev_upper_labels_2, max_previous_2)
                if not na(lower_label_2)
                    array.push(prev_lower_labels_2, lower_label_2)
                    manage_label_array(prev_lower_labels_2, max_previous_2)
            else
                label.delete(upper_label_2)
                label.delete(lower_label_2)
        else
            line.delete(upper_line_2)
            line.delete(lower_line_2)
            label.delete(upper_label_2)
            label.delete(lower_label_2)
        if not na(session_adr_2) and not na(sess_high_2) and not na(sess_low_2)
            initial_remaining_2 = math.max(0, session_adr_2 - (sess_high_2 - sess_low_2))
            // If a side already filled on bars the chart doesn't display, start from its frozen level
            up_y_2 = upper_breached_2 and not na(frozen_upper_target_2) ? frozen_upper_target_2 : sess_high_2 + initial_remaining_2
            dn_y_2 = lower_breached_2 and not na(frozen_lower_target_2) ? frozen_lower_target_2 : sess_low_2 - initial_remaining_2
            // Fade the line opposite the first-filled side (a fill can already exist here if it happened on hidden overnight bars)
            up_col_2 = fade_opposite_2 and first_side_2 == 2 ? color.new(upper_color_2, 67) : upper_color_2
            dn_col_2 = fade_opposite_2 and first_side_2 == 1 ? color.new(lower_color_2, 67) : lower_color_2
            upper_line_2 := line.new(bar_index, up_y_2, bar_index, up_y_2, color=up_col_2, width=line_width_2, style=get_line_style(line_style_2))
            lower_line_2 := line.new(bar_index, dn_y_2, bar_index, dn_y_2, color=dn_col_2, width=line_width_2, style=get_line_style(line_style_2))
            if show_labels_2
                up_txt_2 = (upper_breached_2 ? "ADR2 FILLED: " : "ADR2 Upper: ") + str.tostring(up_y_2, format.mintick)
                dn_txt_2 = (lower_breached_2 ? "ADR2 FILLED: " : "ADR2 Lower: ") + str.tostring(dn_y_2, format.mintick)
                upper_label_2 := label.new(bar_index + label_offset, up_y_2, text=up_txt_2, style=label.style_label_left, color=color.new(upper_color_2, 80), textcolor=upper_color_2, size=get_label_size(label_size_input), text_formatting=bold_first_2 and first_side_2 == 1 ? text.format_bold : text.format_none)
                lower_label_2 := label.new(bar_index + label_offset, dn_y_2, text=dn_txt_2, style=label.style_label_left, color=color.new(lower_color_2, 80), textcolor=lower_color_2, size=get_label_size(label_size_input), text_formatting=bold_first_2 and first_side_2 == 2 ? text.format_bold : text.format_none)
        else
            upper_line_2 := na
            lower_line_2 := na
            upper_label_2 := na
            lower_label_2 := na



// Update lines during the session - handle upper and lower lines independently

if show_set2 and sess_active_2 and not sess2_session_start and not na(upper_line_2) and not na(lower_line_2) and not na(session_adr_2)
    new_remaining_2 = math.max(0, session_adr_2 - (sess_high_2 - sess_low_2))
    // Fade whichever line is opposite the first-filled side (first_side updates mid-session)
    line.set_color(upper_line_2, fade_opposite_2 and first_side_2 == 2 ? color.new(upper_color_2, 67) : upper_color_2)
    line.set_color(lower_line_2, fade_opposite_2 and first_side_2 == 1 ? color.new(lower_color_2, 67) : lower_color_2)
    // Upper line: use frozen value if breached, otherwise calculate dynamically
    if upper_breached_2
        line.set_x2(upper_line_2, bar_index)
        line.set_y1(upper_line_2, frozen_upper_target_2)
        line.set_y2(upper_line_2, frozen_upper_target_2)
        if show_labels_2 and not na(upper_label_2)
            label.set_x(upper_label_2, bar_index + label_offset)
            label.set_y(upper_label_2, frozen_upper_target_2)
            label.set_text(upper_label_2, "ADR2 FILLED: " + str.tostring(frozen_upper_target_2, format.mintick))
            label.set_text_formatting(upper_label_2, bold_first_2 and first_side_2 == 1 ? text.format_bold : text.format_none)
    else
        new_upper_target_2 = sess_high_2 + new_remaining_2
        line.set_x2(upper_line_2, bar_index)
        line.set_y1(upper_line_2, new_upper_target_2)
        line.set_y2(upper_line_2, new_upper_target_2)
        if show_labels_2 and not na(upper_label_2)
            label.set_x(upper_label_2, bar_index + label_offset)
            label.set_y(upper_label_2, new_upper_target_2)
            label.set_text(upper_label_2, "ADR2 Upper: " + str.tostring(new_upper_target_2, format.mintick))
    // Lower line: use frozen value if breached, otherwise calculate dynamically
    if lower_breached_2
        line.set_x2(lower_line_2, bar_index)
        line.set_y1(lower_line_2, frozen_lower_target_2)
        line.set_y2(lower_line_2, frozen_lower_target_2)
        if show_labels_2 and not na(lower_label_2)
            label.set_x(lower_label_2, bar_index + label_offset)
            label.set_y(lower_label_2, frozen_lower_target_2)
            label.set_text(lower_label_2, "ADR2 FILLED: " + str.tostring(frozen_lower_target_2, format.mintick))
            label.set_text_formatting(lower_label_2, bold_first_2 and first_side_2 == 2 ? text.format_bold : text.format_none)
    else
        new_lower_target_2 = sess_low_2 - new_remaining_2
        line.set_x2(lower_line_2, bar_index)
        line.set_y1(lower_line_2, new_lower_target_2)
        line.set_y2(lower_line_2, new_lower_target_2)
        if show_labels_2 and not na(lower_label_2)
            label.set_x(lower_label_2, bar_index + label_offset)
            label.set_y(lower_label_2, new_lower_target_2)
            label.set_text(lower_label_2, "ADR2 Lower: " + str.tostring(new_lower_target_2, format.mintick))

  

// === SESSION RANGES (for info table) ===

current_range_1 = (sess_active_1 and not na(sess_high_1) and not na(sess_low_1)) ? sess_high_1 - sess_low_1 : na

current_range_2 = (sess_active_2 and not na(sess_high_2) and not na(sess_low_2)) ? sess_high_2 - sess_low_2 : na

  

// === ALERT DETECTION ===

// A breach flag turning on means that side just filled. The session-day check also
// catches a fresh fill whose flag was already on at the previous chart bar
// (back-to-back fills across an overnight gap on an RTH chart).

// Set 1 alerts

adr_filled_via_upper_1 = upper_breached_1 and (not upper_breached_1[1] or sday_1 != sday_1[1])

adr_filled_via_lower_1 = lower_breached_1 and (not lower_breached_1[1] or sday_1 != sday_1[1])

// Set 2 alerts

adr_filled_via_upper_2 = upper_breached_2 and (not upper_breached_2[1] or sday_2 != sday_2[1])

adr_filled_via_lower_2 = lower_breached_2 and (not lower_breached_2[1] or sday_2 != sday_2[1])

  

// === CLEANUP PREVIOUS SESSIONS ===

if not show_previous_1
    while array.size(prev_upper_lines_1) > 0
        line.delete(array.pop(prev_upper_lines_1))
    while array.size(prev_lower_lines_1) > 0
        line.delete(array.pop(prev_lower_lines_1))
    while array.size(prev_upper_labels_1) > 0
        label.delete(array.pop(prev_upper_labels_1))
    while array.size(prev_lower_labels_1) > 0
        label.delete(array.pop(prev_lower_labels_1))

if not show_previous_2
    while array.size(prev_upper_lines_2) > 0
        line.delete(array.pop(prev_upper_lines_2))
    while array.size(prev_lower_lines_2) > 0
        line.delete(array.pop(prev_lower_lines_2))
    while array.size(prev_upper_labels_2) > 0
        label.delete(array.pop(prev_upper_labels_2))
    while array.size(prev_lower_labels_2) > 0
        label.delete(array.pop(prev_lower_labels_2))

if not show_prev_labels_1
    while array.size(prev_upper_labels_1) > 0
        label.delete(array.pop(prev_upper_labels_1))
    while array.size(prev_lower_labels_1) > 0
        label.delete(array.pop(prev_lower_labels_1))

if not show_prev_labels_2
    while array.size(prev_upper_labels_2) > 0
        label.delete(array.pop(prev_upper_labels_2))
    while array.size(prev_lower_labels_2) > 0
        label.delete(array.pop(prev_lower_labels_2))

  

// === INFO TABLE ===

var table info_table = table.new(position.top_right, 2, 9, bgcolor=color.rgb(0, 0, 0, 80), border_width=1, border_color=color.gray)

  

if barstate.islast and show_table
    table.cell(info_table, 0, 0, "Set 1 Sessions", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 0, str.tostring(ranges_count_1) + "/" + str.tostring(adr_period_1), text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 1, "ADR 1", text_color=color.white, text_size=size.small)
    adr_display_1 = na(session_adr_1) ? "Waiting..." : str.tostring(session_adr_1, format.mintick)
    table.cell(info_table, 1, 1, adr_display_1, text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 2, "Range 1", text_color=color.white, text_size=size.small)
    range_display_1 = na(current_range_1) ? "N/A" : str.tostring(current_range_1, format.mintick)
    table.cell(info_table, 1, 2, range_display_1, text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 3, "Remaining 1", text_color=color.white, text_size=size.small)
    remaining_val_1 = na(session_adr_1) or na(current_range_1) ? na : session_adr_1 - current_range_1
    remaining_display_1 = na(remaining_val_1) ? "N/A" : str.tostring(remaining_val_1, format.mintick)
    remaining_color_1 = na(remaining_val_1) ? color.gray : (remaining_val_1 > 0 ? color.green : color.red)
    table.cell(info_table, 1, 3, remaining_display_1, text_color=remaining_color_1, text_size=size.small)
    table.cell(info_table, 0, 4, "Set 2 Sessions", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 4, str.tostring(ranges_count_2) + "/" + str.tostring(adr_period_2), text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 5, "ADR 2", text_color=color.white, text_size=size.small)
    adr_display_2 = na(session_adr_2) ? "Waiting..." : str.tostring(session_adr_2, format.mintick)
    table.cell(info_table, 1, 5, adr_display_2, text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 6, "Range 2", text_color=color.white, text_size=size.small)
    range_display_2 = na(current_range_2) ? "N/A" : str.tostring(current_range_2, format.mintick)
    table.cell(info_table, 1, 6, range_display_2, text_color=color.yellow, text_size=size.small)
    table.cell(info_table, 0, 7, "Remaining 2", text_color=color.white, text_size=size.small)
    remaining_val_2 = na(session_adr_2) or na(current_range_2) ? na : session_adr_2 - current_range_2
    remaining_display_2 = na(remaining_val_2) ? "N/A" : str.tostring(remaining_val_2, format.mintick)
    remaining_color_2 = na(remaining_val_2) ? color.gray : (remaining_val_2 > 0 ? color.green : color.red)
    table.cell(info_table, 1, 7, remaining_display_2, text_color=remaining_color_2, text_size=size.small)
    table.cell(info_table, 0, 8, "Status", text_color=color.white, text_size=size.small)
    status_text = ""
    if upper_breached_1 or lower_breached_1
        status_text := "Set1: FILLED "
    if upper_breached_2 or lower_breached_2
        status_text := status_text + "Set2: FILLED"
    if status_text == ""
        status_text := "Active"
    table.cell(info_table, 1, 8, status_text, text_color=color.yellow, text_size=size.small)

  

// === ALERTS ===

alertcondition(adr_filled_via_upper_1, title="ADR Set 1 - Upper Extreme", message="ADR Set 1 filled via upper extreme on {{ticker}}")

alertcondition(adr_filled_via_lower_1, title="ADR Set 1 - Lower Extreme", message="ADR Set 1 filled via lower extreme on {{ticker}}")

alertcondition(adr_filled_via_upper_2, title="ADR Set 2 - Upper Extreme", message="ADR Set 2 filled via upper extreme on {{ticker}}")

alertcondition(adr_filled_via_lower_2, title="ADR Set 2 - Lower Extreme", message="ADR Set 2 filled via lower extreme on {{ticker}}")
````

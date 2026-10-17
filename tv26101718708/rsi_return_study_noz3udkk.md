# RSI Return Study

- url: https://www.tradingview.com/script/NOZ3UdKK-RSI-Return-Study/
- type: indicator
- pine_id: PUB;356e00356e0d4f7493358e92c1714a69
- version: 2.0

## Description

Ever wonder what happens after the RSI hits an extreme level on your favorite ticker? This indicator answers that question historically.

[b]What it does:[/b]

[list]
[*]Finds every instance where the RSI crossed a user-defined trigger level
[*]Measures the forward price return N trading days later
[*]Displays each signal date and return in a clean table
[*]Plots labels on the chart at each signal location
[*]Shows the average return across all historical signals
[/list]

[b]How to use:[/b]

[list]
[*]Set "When RSI Touches..." to your oversold level (e.g. 25) or overbought level (e.g. 75)
[*]Set "Calculate Return Days Later" to how many trading days forward you want to measure
[*]Works on any timeframe — bar count is automatically calculated for you
[*]Adjust "Max Results/Labels to Display" to control how much shows on the chart
[/list]

[b]Notes:[/b]

[list]
[*]All signals are included in the average regardless of the display limit
[*]Set "Min Bars Between Signals" to 0 to count every RSI cross, or increase it to reduce clustering during volatile periods
[/list]

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────────────────
// RSI Return Study - Multi Period
// Author: DarkStarOptions
//
// DESCRIPTION:
// This indicator finds every historical instance where the RSI crossed a
// user-defined trigger level, then measures the forward price return across
// multiple user-defined periods. Results are displayed in a table showing
// each signal date and returns per period, along with averages and win rates.
//
// SETTINGS:
// - RSI Length: Period for RSI calculation (default 14)
// - Source: Price source for RSI (default close)
// - When RSI Touches: The trigger level (e.g. 25 for oversold, 75 for overbought)
// - Forward Periods: Comma separated list of up to 5 periods e.g. "3D,1W,1M,3M,1Y"
//   Valid units: D=days, W=weeks, M=months, Y=years. Max 5 periods.
//   * = forward period not yet complete
// - Min Days Between Signals: Prevents signal clustering (0 = every cross counts)
// - Max Results to Display: Controls table rows shown
//
// NOTE: All signals are included in the average regardless of display limit.
// Entry price is the open of the bar immediately following the signal bar,
// reflecting realistic alert-based entry.
// ─────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("RSI Return Study", overlay=true)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
rsi_length    = input.int(14,             title="RSI Length", minval=1)
src           = input.source(close,       title="Source")
rsi_trigger   = input.float(25,           title="When RSI Touches...",          group="Study Settings",
     tooltip="Set the RSI level that triggers a signal. Values below 50 are oversold, values above 50 are overbought.",
     minval=1, maxval=100)
fwd_input     = input.string("5D,1M", title="...Calculate Forward Returns", group="Study Settings",
     tooltip="Comma separated list of up to 5 periods. Valid units: D=days, W=weeks, M=months, Y=years. Example: 3D,1W,1M,3M,1Y. * in results means the period is not yet complete.")
cooldown_days = input.int(1,              title="Min Days Between Signals",     group="Study Settings",
     tooltip="Minimum number of days required between two signals. Set to 0 to count every RSI cross. Increase to avoid clustering during volatile periods.",
     minval=0)
show_count    = input.int(15,             title="Max Results to Display",       group="Display Settings",
     tooltip="Controls how many rows appear in the table. All signals are still included in the average calculation regardless of this setting.",
     minval=1)
show_labels   = input.bool(true,          title="Show Labels on Chart",         group="Display Settings")

// ─── TIMEFRAME ───────────────────────────────────────────────────────────────
tf_minutes   = timeframe.in_seconds() / 60
bars_per_day = tf_minutes <= 0 ? 1 : math.round(390 / tf_minutes)

cooldown_bars = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
     ? cooldown_days
     : math.max(0, math.round(cooldown_days * bars_per_day))

tf_label = timeframe.isseconds ? str.tostring(timeframe.in_seconds()) + "s"
         : timeframe.isminutes and timeframe.multiplier < 60  ? str.tostring(timeframe.multiplier) + "m"
         : timeframe.isminutes and timeframe.multiplier >= 60 ? str.tostring(timeframe.multiplier / 60) + "h"
         : timeframe.isdaily   ? str.tostring(timeframe.multiplier) + "D"
         : timeframe.isweekly  ? str.tostring(timeframe.multiplier) + "W"
         : timeframe.ismonthly ? str.tostring(timeframe.multiplier) + "M"
         : timeframe.period

// ─── PERIOD PARSING ──────────────────────────────────────────────────────────
periodToBars(p) =>
    p_upper = str.upper(str.replace(p, " ", ""))
    n       = str.length(p_upper)
    result  = -1
    if n >= 2
        unit    = str.substring(p_upper, n - 1, n)
        num_str = str.substring(p_upper, 0, n - 1)
        num     = str.tonumber(num_str)
        if not na(num)
            days = unit == "D" ? num
                 : unit == "W" ? num * 5
                 : unit == "M" ? num * 21
                 : unit == "Y" ? num * 252
                 : float(na)
            if not na(days)
                result := timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
                     ? int(days)
                     : math.max(1, math.round(bars_per_day * days))
    result

var string[] period_labels     = array.new_string(0)
var int[]    period_bar_counts = array.new_int(0)
var bool     input_valid       = true
var string   input_error       = ""

if barstate.isfirst
    raw_periods = str.split(fwd_input, ",")
    n_raw       = array.size(raw_periods)
    if n_raw > 5
        input_valid := false
        input_error := "Too many periods — maximum is 5. Please reduce your list."
    else
        for i = 0 to n_raw - 1
            p    = array.get(raw_periods, i)
            bars = periodToBars(p)
            if bars == -1
                input_valid := false
                input_error := "Invalid period: '" + p + "'. Use format like 3D, 1W, 2M, 1Y."
                break
            array.push(period_labels,     str.upper(str.replace(p, " ", "")))
            array.push(period_bar_counts, bars)

n_periods = array.size(period_labels)

// ─── SIGNAL TYPE ─────────────────────────────────────────────────────────────
type Signal
    int   bar
    float entry_price
    float window_low
    float window_high
    int   signal_start_time
    float r0
    float r1
    float r2
    float r3
    float r4
    bool  p0
    bool  p1
    bool  p2
    bool  p3
    bool  p4

// ─── VARIABLES ───────────────────────────────────────────────────────────────
var int      last_trigger_bar = -999
var Signal[] signals          = array.new<Signal>(0)

// ─── GET/SET HELPERS ─────────────────────────────────────────────────────────
getReturn(Signal s, int p) =>
    switch p
        0 => s.r0
        1 => s.r1
        2 => s.r2
        3 => s.r3
        4 => s.r4
        => float(na)

setReturn(Signal s, int p, float val) =>
    switch p
        0 => s.r0 := val
        1 => s.r1 := val
        2 => s.r2 := val
        3 => s.r3 := val
        4 => s.r4 := val

getPartial(Signal s, int p) =>
    switch p
        0 => s.p0
        1 => s.p1
        2 => s.p2
        3 => s.p3
        4 => s.p4
        => false

setPartial(Signal s, int p, bool val) =>
    switch p
        0 => s.p0 := val
        1 => s.p1 := val
        2 => s.p2 := val
        3 => s.p3 := val
        4 => s.p4 := val

// ─── RSI & SIGNAL ────────────────────────────────────────────────────────────
rsi_val     = ta.rsi(src, rsi_length)
did_trigger = rsi_val <= rsi_trigger and rsi_val[1] > rsi_trigger and (bar_index - last_trigger_bar) > cooldown_bars

if did_trigger and input_valid and n_periods > 0
    last_trigger_bar := bar_index
    array.push(signals, Signal.new(bar_index, float(na), float(na), float(na), time,
         float(na), float(na), float(na), float(na), float(na),
         false, false, false, false, false))

// ─── SET ENTRY PRICE ON NEXT BAR OPEN ────────────────────────────────────────
if array.size(signals) > 0
    for i = 0 to array.size(signals) - 1
        s = array.get(signals, i)
        if na(s.entry_price) and bar_index == s.bar + 1
            s.entry_price := open

// ─── FORWARD RETURN CALCULATION ──────────────────────────────────────────────
if array.size(signals) > 0 and n_periods > 0
    for i = 0 to array.size(signals) - 1
        s = array.get(signals, i)
        if na(s.entry_price)
            continue
        elapsed = bar_index - s.bar
        for p = 0 to n_periods - 1
            bars_needed = array.get(period_bar_counts, p)
            r           = getReturn(s, p)
            if elapsed >= bars_needed
                if na(r) or getPartial(s, p)
                    setReturn(s, p, (src - s.entry_price) / s.entry_price * 100)
                    setPartial(s, p, false)
            else if elapsed > 0 and na(r)
                setReturn(s, p, (src - s.entry_price) / s.entry_price * 100)
                setPartial(s, p, true)
        any_pending = false
        for p = 0 to n_periods - 1
            if getPartial(s, p)
                any_pending := true
        if any_pending
            s.window_low  := na(s.window_low)  ? low  : math.min(s.window_low,  low)
            s.window_high := na(s.window_high) ? high : math.max(s.window_high, high)

// ─── HELPER FUNCTIONS ────────────────────────────────────────────────────────
calcAvg(arr) =>
    n = array.size(arr)
    if n == 0
        float(na)
    else
        total = 0.0
        for i = 0 to n - 1
            total += array.get(arr, i)
        total / n

calcWinRate(arr) =>
    n = array.size(arr)
    if n == 0
        float(na)
    else
        wins = 0
        for i = 0 to n - 1
            if array.get(arr, i) > 0
                wins += 1
        wins / n * 100

// ─── TABLE ───────────────────────────────────────────────────────────────────
var table t = table.new(
    position.middle_right, 6, 200,
    bgcolor      = color.new(color.black, 15),
    border_color = color.new(color.gray, 40),
    border_width = 1,
    frame_color  = color.new(color.gray, 20),
    frame_width  = 1)

if barstate.islast
    header_bg  = color.new(color.navy, 20)
    header_fg  = color.white
    cell_bg    = color.new(color.black, 30)
    pos_fg     = color.new(color.lime, 0)
    neg_fg     = color.new(color.red, 0)
    neu_fg     = color.new(color.gray, 0)
    subhead_bg = color.new(color.navy, 50)
    partial_fg = color.new(color.yellow, 0)
    n_cols     = n_periods + 1
    total_sigs = array.size(signals)

    if not input_valid
        table.cell(t, 0, 0, "⚠ " + input_error,
             text_color=color.red, bgcolor=header_bg, text_halign=text.align_left)
        table.merge_cells(t, 0, 0, 5, 0)

    else if n_periods == 0
        table.cell(t, 0, 0, "⚠ No periods defined.",
             text_color=color.red, bgcolor=header_bg, text_halign=text.align_left)
        table.merge_cells(t, 0, 0, 5, 0)

    else
        // ─── BUILD COMPLETED ARRAYS PER PERIOD ───────────────────────────────
        completed_0 = array.new_float(0)
        completed_1 = array.new_float(0)
        completed_2 = array.new_float(0)
        completed_3 = array.new_float(0)
        completed_4 = array.new_float(0)

        completed_count = 0
        longest_bars    = array.get(period_bar_counts, n_periods - 1)

        if total_sigs > 0
            for i = 0 to total_sigs - 1
                s = array.get(signals, i)
                if (bar_index - s.bar) >= longest_bars
                    completed_count += 1
                for p = 0 to n_periods - 1
                    r = getReturn(s, p)
                    if not na(r) and not getPartial(s, p)
                        switch p
                            0 => array.push(completed_0, r)
                            1 => array.push(completed_1, r)
                            2 => array.push(completed_2, r)
                            3 => array.push(completed_3, r)
                            4 => array.push(completed_4, r)

        // ─── DYNAMIC HEADER ───────────────────────────────────────────────────
        table.cell(t, 0, 0, "RSI Returns for " + syminfo.ticker,
             text_color=header_fg, bgcolor=header_bg, text_halign=text.align_center)
        table.merge_cells(t, 0, 0, n_cols - 1, 0)

        row = 0

        if n_periods == 1
            table.cell(t, 0, 1,
                 "RSI (" + str.tostring(rsi_length) + ")  |  TF: " + tf_label + "  |  " +
                 str.tostring(completed_count) + "x RSI touched " + str.tostring(rsi_trigger),
                 text_color=header_fg, bgcolor=header_bg, text_halign=text.align_center)
            table.merge_cells(t, 0, 1, n_cols - 1, 1)
            table.cell(t, 0, 2, "Date",
                 text_color=header_fg, bgcolor=subhead_bg, text_halign=text.align_center)
            table.cell(t, 1, 2, array.get(period_labels, 0),
                 text_color=header_fg, bgcolor=subhead_bg, text_halign=text.align_center)
            row := 3
        else
            table.cell(t, 0, 1, "RSI (" + str.tostring(rsi_length) + ")",
                 text_color=header_fg, bgcolor=header_bg, text_halign=text.align_center)
            table.cell(t, 1, 1, "TF: " + tf_label,
                 text_color=header_fg, bgcolor=header_bg, text_halign=text.align_center)
            if n_cols > 2
                table.merge_cells(t, 1, 1, n_cols - 1, 1)
            table.cell(t, 0, 2, " " + str.tostring(completed_count) + " time(s) RSI touched " + str.tostring(rsi_trigger),
                 text_color=header_fg, bgcolor=header_bg, text_halign=text.align_left)
            table.merge_cells(t, 0, 2, n_cols - 1, 2)
            table.cell(t, 0, 3, "Date",
                 text_color=header_fg, bgcolor=subhead_bg, text_halign=text.align_center)
            for p = 0 to n_periods - 1
                table.cell(t, p + 1, 3, array.get(period_labels, p),
                     text_color=header_fg, bgcolor=subhead_bg, text_halign=text.align_center)
            row := 4

        // ─── DATA ROWS ────────────────────────────────────────────────────────
        shown     = 0
        start_idx = total_sigs - 1

        if total_sigs > 0
            for i = start_idx to 0
                if shown >= show_count
                    break
                s        = array.get(signals, i)
                date_str = str.format_time(s.signal_start_time, "M/d/yyyy")
                table.cell(t, 0, row, date_str,
                     text_color=neu_fg, bgcolor=cell_bg, text_halign=text.align_center)
                for p = 0 to n_periods - 1
                    r          = getReturn(s, p)
                    is_partial = getPartial(s, p)
                    if na(r)
                        table.cell(t, p + 1, row, "?",
                             text_color=neu_fg, bgcolor=cell_bg, text_halign=text.align_center)
                    else
                        ret_str = str.tostring(math.round(r, 2)) + "%" + (is_partial ? "*" : "")
                        ret_fg  = is_partial ? partial_fg : r >= 0 ? pos_fg : neg_fg
                        table.cell(t, p + 1, row, ret_str,
                             text_color=ret_fg, bgcolor=cell_bg, text_halign=text.align_center)
                row   += 1
                shown += 1

        // ─── MORE RESULTS ROW ─────────────────────────────────────────────────
        remaining = completed_count - show_count
        if remaining > 0
            table.cell(t, 0, row, "(...there are " + str.tostring(remaining) + " more results)",
                 text_color=neu_fg, bgcolor=cell_bg, text_halign=text.align_center)
            table.merge_cells(t, 0, row, n_cols - 1, row)
            row += 1

        // ─── AVERAGE ROW ──────────────────────────────────────────────────────
        table.cell(t, 0, row, "Average",
             text_color=color.white, bgcolor=header_bg, text_halign=text.align_center)
        for p = 0 to n_periods - 1
            arr = switch p
                0 => completed_0
                1 => completed_1
                2 => completed_2
                3 => completed_3
                4 => completed_4
                => completed_0
            avg     = calcAvg(arr)
            cnt     = array.size(arr)
            avg_str = na(avg) ? "n/a" : str.tostring(math.round(avg, 2)) + "% (" + str.tostring(cnt) + ")"
            avg_fg  = na(avg) ? neu_fg : avg >= 0 ? pos_fg : neg_fg
            table.cell(t, p + 1, row, avg_str,
                 text_color=avg_fg, bgcolor=header_bg, text_halign=text.align_center)
        row += 1

        // ─── WIN RATE ROW ─────────────────────────────────────────────────────
        table.cell(t, 0, row, "Win Rate",
             text_color=color.white, bgcolor=header_bg, text_halign=text.align_center)
        for p = 0 to n_periods - 1
            arr = switch p
                0 => completed_0
                1 => completed_1
                2 => completed_2
                3 => completed_3
                4 => completed_4
                => completed_0
            wr     = calcWinRate(arr)
            wr_str = na(wr) ? "n/a" : str.tostring(math.round(wr, 1)) + "%"
            wr_fg  = na(wr) ? neu_fg : wr >= 50 ? pos_fg : neg_fg
            table.cell(t, p + 1, row, wr_str,
                 text_color=wr_fg, bgcolor=header_bg, text_halign=text.align_center)
        row += 1

        // ─── LABELS ──────────────────────────────────────────────────────────
        if show_labels
            shown_chart = 0
            for i = start_idx to 0
                if shown_chart >= show_count
                    break
                s = array.get(signals, i)

                // Build multi-line label text
                label_text = ""
                for p = 0 to n_periods - 1
                    lbl        = array.get(period_labels, p)
                    r          = getReturn(s, p)
                    is_partial = getPartial(s, p)
                    line_str   = na(r) ? lbl + " = ?" : lbl + " = " + str.tostring(math.round(r, 2)) + "%" + (is_partial ? "*" : "")
                    label_text := label_text + (p == 0 ? "" : "\n") + line_str

                // Color based on first period return
                r0         = getReturn(s, 0)
                text_color = na(r0) ? color.white : r0 >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

                isOverbought = rsi_trigger >= 50
                label.new(
                    x         = s.signal_start_time,
                    y         = isOverbought ? s.entry_price * 1.01 : s.entry_price * 0.99,
                    text      = label_text,
                    xloc      = xloc.bar_time,
                    yloc      = yloc.price,
                    style     = isOverbought ? label.style_label_down : label.style_label_up,
                    color     = color.black,
                    textcolor = text_color,
                    size      = size.large)

                shown_chart += 1
````

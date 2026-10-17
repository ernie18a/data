# Market Opening & Closing Times (Latest Only)

- url: https://www.tradingview.com/script/G3ql0fME-Market-Opening-Closing-Times-Latest-Only/
- type: indicator
- pine_id: PUB;98efe5a0dac547149db842c546e5419a
- version: 1.0

## Description

Fork of "Market Opening & Closing Times" indicator. Removes historic open and close labels.

## Source Code

````pine
//@version=6
indicator("Market Opening & Closing Times (Latest Only)", overlay=true)

// Toggles
show_nyse_open   = input.bool(true, "Show NYSE Open")
show_nyse_close  = input.bool(true, "Show NYSE Close")
show_lse_open    = input.bool(true, "Show LSE Open")
show_lse_close   = input.bool(true, "Show LSE Close")
show_tokyo_open  = input.bool(true, "Show Tokyo Open")
show_tokyo_close = input.bool(true, "Show Tokyo Close")

show_lines  = input.bool(true, "Show Lines")
show_labels = input.bool(true, "Show Labels")

// Colors
col_nyse  = input.color(color.red,   "NYSE Color")
col_lse   = input.color(color.blue,  "LSE Color")
col_tokyo = input.color(color.green, "Tokyo Color")

// Timezones
tz_nyse  = "America/New_York"
tz_lse   = "Europe/London"
tz_tokyo = "Asia/Tokyo"

// Helper
f_eventInBar(_tz, _h, _m) =>
    if not timeframe.isintraday
        false
    else
        yy   = year(time, _tz)
        mo   = month(time, _tz)
        dd   = dayofmonth(time, _tz)
        evTs = timestamp(_tz, yy, mo, dd, _h, _m)
        dur  = str.tonumber(timeframe.period) * 60000
        time >= evTs and time < evTs + dur

// Events
open_nyse  = show_nyse_open  and f_eventInBar(tz_nyse,  9, 30)
close_nyse = show_nyse_close and f_eventInBar(tz_nyse, 16, 0)

open_lse   = show_lse_open   and f_eventInBar(tz_lse,   8, 0)
close_lse  = show_lse_close  and f_eventInBar(tz_lse,   16, 30)

open_tokyo  = show_tokyo_open  and f_eventInBar(tz_tokyo, 9, 0)
close_tokyo = show_tokyo_close and f_eventInBar(tz_tokyo, 15, 0)

// =============================
// STORAGE
// =============================

// NYSE
var line nyse_open_line = na
var label nyse_open_label = na
var line nyse_close_line = na
var label nyse_close_label = na

// LSE
var line lse_open_line = na
var label lse_open_label = na
var line lse_close_line = na
var label lse_close_label = na

// Tokyo
var line tokyo_open_line = na
var label tokyo_open_label = na
var line tokyo_close_line = na
var label tokyo_close_label = na

// =============================
// DRAW LOGIC (NO FUNCTIONS)
// =============================

// ===== NYSE OPEN =====
if open_nyse
    if not na(nyse_open_line)
        line.delete(nyse_open_line)
    if not na(nyse_open_label)
        label.delete(nyse_open_label)

    nyse_open_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_nyse, width=1) : na
    nyse_open_label := show_labels ? label.new(bar_index, high, "NYSE Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_nyse) : na

// ===== NYSE CLOSE =====
if close_nyse
    if not na(nyse_close_line)
        line.delete(nyse_close_line)
    if not na(nyse_close_label)
        label.delete(nyse_close_label)

    nyse_close_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_nyse, width=1) : na
    nyse_close_label := show_labels ? label.new(bar_index, low, "NYSE Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_nyse) : na

// ===== LSE OPEN =====
if open_lse
    if not na(lse_open_line)
        line.delete(lse_open_line)
    if not na(lse_open_label)
        label.delete(lse_open_label)

    lse_open_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_lse, width=1) : na
    lse_open_label := show_labels ? label.new(bar_index, high, "LSE Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_lse) : na

// ===== LSE CLOSE =====
if close_lse
    if not na(lse_close_line)
        line.delete(lse_close_line)
    if not na(lse_close_label)
        label.delete(lse_close_label)

    lse_close_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_lse, width=1) : na
    lse_close_label := show_labels ? label.new(bar_index, low, "LSE Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_lse) : na

// ===== TOKYO OPEN =====
if open_tokyo
    if not na(tokyo_open_line)
        line.delete(tokyo_open_line)
    if not na(tokyo_open_label)
        label.delete(tokyo_open_label)

    tokyo_open_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_tokyo, width=1) : na
    tokyo_open_label := show_labels ? label.new(bar_index, high, "Tokyo Open", yloc=yloc.abovebar, style=label.style_label_down, color=col_tokyo) : na

// ===== TOKYO CLOSE =====
if close_tokyo
    if not na(tokyo_close_line)
        line.delete(tokyo_close_line)
    if not na(tokyo_close_label)
        label.delete(tokyo_close_label)

    tokyo_close_line := show_lines ? line.new(bar_index, high, bar_index, low, extend=extend.both, color=col_tokyo, width=1) : na
    tokyo_close_label := show_labels ? label.new(bar_index, low, "Tokyo Close", yloc=yloc.belowbar, style=label.style_label_up, color=col_tokyo) : na
````

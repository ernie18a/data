# Forum Initium + LTA Session Breaks 

- url: https://www.tradingview.com/script/pnBf9sXm-Forum-Initium-LTA-Session-Breaks/
- type: indicator
- pine_id: PUB;abf1a416ee9743edbff1fcf5b3941d0d
- version: 1.0

## Description

LTA Forum Initium + Session Breaks is a confluence indicator built to map key weekly and session-based reference levels on intraday charts.
It combines:
	•	Forum Initium, defined here as the opening price of the new weekly candle
	•	Previous Week High and Previous Week Low
	•	Daily session break markers
	•	New York 18:00 timing marker
	•	A live weekly bias table based on price relative to Forum Initium
	•	A configurable approach zone around Forum Initium for reaction monitoring
How it works:
	•	At the start of each new trading week, the script stores the new weekly open as Forum Initium.
	•	Previous week high/low are requested from the weekly timeframe using non-repainting higher-timeframe logic.
	•	Daily session changes are marked with vertical dotted separators.
	•	A separate vertical marker is drawn when the chart bar time aligns with 18:00 in the New York timezone.
	•	A bias table displays whether price is trading above or below Forum Initium.
	•	A background highlight appears when price moves within a configurable distance of Forum Initium.
This script is designed for traders who use weekly reference levels and session timing as context rather than as standalone signals. It is most useful on lower intraday timeframes such as 1-minute and 5-minute charts across Gold, Forex, indices, and crypto.
Notes:
	•	This is a confluence tool, not an entry model.
	•	The script is designed to avoid repainting by using confirmed weekly state changes and  request.security()  with  lookahead_off .
	•	Session markers and weekly levels are intended to provide structure for discretionary execution.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InkJunkieuv

//@version=6
indicator("Forum Initium + LTA Session Breaks (Merged)", overlay=true, max_lines_count=300, max_labels_count=100)

// ============================================================
// MERGED FEATURES
// 1. Forum Initium / Sunday Open fixed line
// 2. Previous Week High / Low
// 3. Session Break vertical markers
// 4. NY 18:00 timestamp markers
// 5. Weekly bias table
// 6. Approach zone highlight + alerts
// Non-repainting: confirmed-bar logic + lookahead_off
// ============================================================

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grp_fi = "Forum Initium"
fi_color = input.color(color.new(#F5C842, 0), "Sunday Open / FI Colour", group=grp_fi)
fi_width = input.int(2, "FI Width", minval=1, maxval=4, group=grp_fi)
show_fi_label = input.bool(true, "Show FI Label", group=grp_fi)
show_bias = input.bool(true, "Show Weekly Bias Table", group=grp_fi)
show_approach = input.bool(true, "Show FI Approach Zone", group=grp_fi)
approach_pts = input.float(5.0, "Approach Zone (pts)", minval=0.1, step=0.1, group=grp_fi)

grp_pw = "Previous Week"
show_pw = input.bool(true, "Show Previous Week High / Low", group=grp_pw)
pw_hi_col = input.color(color.new(#26A69A, 35), "PW High Colour", group=grp_pw)
pw_lo_col = input.color(color.new(#EF5350, 35), "PW Low Colour", group=grp_pw)
show_pw_labels = input.bool(true, "Show PWH / PWL Labels", group=grp_pw)

grp_sb = "Session Breaks"
show_daily_breaks = input.bool(true, "Show Daily Session Breaks", group=grp_sb)
daily_break_color = input.color(color.new(color.gray, 65), "Daily Break Colour", group=grp_sb)
daily_break_width = input.int(1, "Daily Break Width", minval=1, maxval=3, group=grp_sb)
show_ny_1800 = input.bool(true, "Show 18:00 New York Markers", group=grp_sb)
ny_line_color = input.color(color.new(#4A9EFF, 55), "NY 18:00 Colour", group=grp_sb)
ny_line_width = input.int(1, "NY 18:00 Width", minval=1, maxval=3, group=grp_sb)
ny_tz = input.string("America/New_York", "Timezone for 18:00 Marker", group=grp_sb)
show_break_labels = input.bool(false, "Show Break Labels", group=grp_sb)

// ─────────────────────────────────────────
// WEEK DETECTION / FORUM INITIUM
// ─────────────────────────────────────────
is_new_week = ta.change(time("W")) != 0

var float forum_initium = na
if barstate.isconfirmed and is_new_week
    forum_initium := open

plot(forum_initium, "Forum Initium", color=fi_color, linewidth=fi_width)

// Persistent FI label
var label fi_lbl = na
if show_fi_label and barstate.islast and not na(forum_initium)
    if na(fi_lbl)
        fi_lbl := label.new(bar_index + 2, forum_initium, "", style=label.style_label_left, color=color.new(fi_color, 5), textcolor=color.black, size=size.small)
    label.set_x(fi_lbl, bar_index + 2)
    label.set_y(fi_lbl, forum_initium)
    label.set_text(fi_lbl, "FI " + str.tostring(forum_initium, format.mintick))
    label.set_color(fi_lbl, color.new(fi_color, 5))
    label.set_textcolor(fi_lbl, color.black)
else
    if not na(fi_lbl)
        label.delete(fi_lbl)
        fi_lbl := na

// ─────────────────────────────────────────
// PREVIOUS WEEK LEVELS (NON-REPAINTING)
// ─────────────────────────────────────────
pw_high = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pw_low  = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_off)

plot(show_pw ? pw_high : na, "Previous Week High", color=pw_hi_col, linewidth=1, style=plot.style_linebr)
plot(show_pw ? pw_low : na, "Previous Week Low", color=pw_lo_col, linewidth=1, style=plot.style_linebr)

// Persistent PWH/PWL labels
var label pwh_lbl = na
var label pwl_lbl = na

if show_pw and show_pw_labels and barstate.islast
    if na(pwh_lbl)
        pwh_lbl := label.new(bar_index + 2, pw_high, "", style=label.style_label_left, color=color.new(#26A69A, 15), textcolor=color.white, size=size.tiny)
    if na(pwl_lbl)
        pwl_lbl := label.new(bar_index + 2, pw_low, "", style=label.style_label_left, color=color.new(#EF5350, 15), textcolor=color.white, size=size.tiny)

    label.set_x(pwh_lbl, bar_index + 2)
    label.set_y(pwh_lbl, pw_high)
    label.set_text(pwh_lbl, "PWH")
    label.set_x(pwl_lbl, bar_index + 2)
    label.set_y(pwl_lbl, pw_low)
    label.set_text(pwl_lbl, "PWL")
else
    if not na(pwh_lbl)
        label.delete(pwh_lbl)
        pwh_lbl := na
    if not na(pwl_lbl)
        label.delete(pwl_lbl)
        pwl_lbl := na

// ─────────────────────────────────────────
// WEEKLY BIAS TABLE
// ─────────────────────────────────────────
bullish_bias = not na(forum_initium) ? close > forum_initium : false
bias_text = bullish_bias ? "ABOVE FI - Bullish Bias" : "BELOW FI - Bearish Bias"
bias_col = bullish_bias ? color.new(#26A69A, 0) : color.new(#EF5350, 0)

var table bias_tbl = table.new(position.top_right, 1, 2, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.clear(bias_tbl, 0, 0, 0, 1)
    if show_bias and not na(forum_initium)
        table.cell(bias_tbl, 0, 0, "Forum Initium: " + str.tostring(forum_initium, format.mintick), text_color=color.new(fi_color, 0), text_size=size.small)
        table.cell(bias_tbl, 0, 1, bias_text, text_color=bias_col, text_size=size.small)

// ─────────────────────────────────────────
// APPROACH ZONE
// ─────────────────────────────────────────
in_fi_zone = show_approach and not na(forum_initium) and math.abs(close - forum_initium) <= approach_pts
touching_fi = not na(forum_initium) and close == forum_initium
bgcolor(in_fi_zone ? color.new(fi_color, 88) : na, title="FI Approach Zone")

// ─────────────────────────────────────────
// SESSION BREAKS (DAILY)
// ─────────────────────────────────────────
new_day = ta.change(time("D")) != 0
if show_daily_breaks and new_day and barstate.isconfirmed
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=daily_break_color, width=daily_break_width, style=line.style_dotted)
    if show_break_labels
        label.new(bar_index, high, "Day", style=label.style_label_down, color=color.new(daily_break_color, 10), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────
// NEW YORK 18:00 MARKERS
// ─────────────────────────────────────────
ny_hour = hour(time, ny_tz)
ny_min = minute(time, ny_tz)
ny_1800 = ny_hour == 18 and ny_min == 0

if show_ny_1800 and ny_1800 and barstate.isconfirmed
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=ny_line_color, width=ny_line_width, style=line.style_dashed)
    if show_break_labels
        label.new(bar_index, high, "NY 18:00", style=label.style_label_down, color=color.new(#4A9EFF, 10), textcolor=color.white, size=size.tiny)

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(not na(forum_initium) and ta.crossover(close, forum_initium),
 title="Crossed Above Forum Initium",
 message="{{ticker}} crossed ABOVE Forum Initium at {{close}}. Weekly bias now BULLISH.")

alertcondition(not na(forum_initium) and ta.crossunder(close, forum_initium),
 title="Crossed Below Forum Initium",
 message="{{ticker}} crossed BELOW Forum Initium at {{close}}. Weekly bias now BEARISH.")

alertcondition(in_fi_zone and not in_fi_zone[1],
 title="Approaching Forum Initium",
 message="{{ticker}} is approaching the Forum Initium level at {{close}}.")

alertcondition(touching_fi,
 title="Touching Forum Initium",
 message="{{ticker}} is touching the Forum Initium level at {{close}}.")

alertcondition(is_new_week,
 title="New Week - Forum Initium Set",
 message="New weekly candle opened. Forum Initium set at {{open}} on {{ticker}}.")

alertcondition(show_ny_1800 and ny_1800,
 title="NY 18:00 Marker",
 message="{{ticker}} printed the 18:00 New York timestamp marker.")
````

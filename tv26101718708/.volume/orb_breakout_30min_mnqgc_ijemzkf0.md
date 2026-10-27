# ORB Breakout - 30min (MNQ/GC)

- url: https://www.tradingview.com/script/iJeMZkf0-ORB-Breakout-30min-MNQ-GC/
- type: indicator
- pine_id: PUB;9769a88a697a434880c30063fc4efe97
- version: 1.0

## Description

**ORB Breakout — 30min (MNQ/GC)**

Identifies high-probability breakout setups during the first 2 hours of the regular NYSE session, optimized for futures traders (MNQ, GC).

**Triggers when ALL 4 conditions are met simultaneously:**
- ✅ Price closes above the 30-minute Opening Range High (9:30–10:00 AM EST)
- ✅ Current bar volume is ≥ 1.5× the average volume of the opening range bars
- ✅ Price is above VWAP
- ✅ Time is before 11:30 AM EST (within the first 2 hours of session)

**Visuals:**
- Dashed orange horizontal line marking the ORB High
- Green triangle marker on the breakout bar
- Light green background highlight while all conditions are active
- VWAP plotted for reference
- Live debug table (top-right) showing the status of each condition in real time

**Alerts:**
- Built-in alert condition fires once on the first bar where all conditions are met — set to *Once Per Bar Close* for confirmation entries.

**Settings are fully adjustable:** ORB window times, session end time, volume multiplier, and all visual colors can be customized via the indicator settings panel.

## Source Code

````pine
//@version=5
indicator(title="ORB Breakout - 30min (MNQ/GC)", shorttitle="ORB Break", overlay=true)

// ============================================================
//  OPENING RANGE BREAKOUT INDICATOR
//  Designed for: MNQ (Micro E-mini Nasdaq) & GC (Gold Futures)
//  Session:      NYSE Regular Session — 9:30 AM to 10:00 AM EST
//
//  Triggers when ALL conditions are met:
//    1. Close breaks above the 30-min Opening Range High
//    2. Current bar volume >= 1.5x the avg volume of the ORB
//    3. Price is above VWAP
//    4. Time is before 11:30 AM EST (first 2 hours of session)
// ============================================================


// ─────────────────────────────────────────────
//  USER INPUTS
// ─────────────────────────────────────────────

var g_orb     = "Opening Range Settings"
orb_start_h   = input.int(9,  "ORB Start Hour (EST)",   minval=0, maxval=23, group=g_orb)
orb_start_m   = input.int(30, "ORB Start Minute (EST)", minval=0, maxval=59, group=g_orb)
orb_end_h     = input.int(10, "ORB End Hour (EST)",     minval=0, maxval=23, group=g_orb)
orb_end_m     = input.int(0,  "ORB End Minute (EST)",   minval=0, maxval=59, group=g_orb)
session_end_h = input.int(11, "Session Window End Hour (EST)",   minval=0, maxval=23, group=g_orb, tooltip="Breakout alerts only fire before this hour")
session_end_m = input.int(30, "Session Window End Minute (EST)", minval=0, maxval=59, group=g_orb)

var g_vol     = "Volume Settings"
vol_mult      = input.float(1.5, "Volume Multiplier vs ORB Avg", minval=1.0, step=0.1, group=g_vol)

var g_vis     = "Visual Settings"
show_orb_line = input.bool(true,  "Show ORB High Line",       group=g_vis)
show_triangle = input.bool(true,  "Show Breakout Triangle",   group=g_vis)
show_bg       = input.bool(true,  "Show Background Highlight", group=g_vis)
orb_line_col  = input.color(color.new(color.orange, 0),   "ORB High Line Color", group=g_vis)
bg_col        = input.color(color.new(color.green,  88),  "Breakout BG Color",   group=g_vis)
tri_col       = input.color(color.new(color.lime,   0),   "Breakout Triangle Color", group=g_vis)


// ─────────────────────────────────────────────
//  SESSION TIME HELPERS
//  Pine Script uses the chart's timezone.
//  We target EST (UTC-5 / UTC-4 DST).
//  Use "America/New_York" to keep EST/EDT correct year-round.
// ─────────────────────────────────────────────

// Current bar's hour and minute in New York time
ny_hour   = hour(time,   "America/New_York")
ny_minute = minute(time, "America/New_York")

// Convert hour:minute to total minutes for easy comparison
ny_time_mins       = ny_hour * 60 + ny_minute
orb_start_mins     = orb_start_h * 60 + orb_start_m   // 9:30  = 570
orb_end_mins       = orb_end_h   * 60 + orb_end_m     // 10:00 = 600
session_end_mins   = session_end_h * 60 + session_end_m // 11:30 = 690

// Boolean flags for where we are in the session
is_in_orb_window      = ny_time_mins >= orb_start_mins and ny_time_mins < orb_end_mins
is_in_session_window  = ny_time_mins >= orb_end_mins   and ny_time_mins < session_end_mins

// Detect the very first bar of a new trading day
is_new_day = dayofweek(time, "America/New_York") != dayofweek(time[1], "America/New_York")


// ─────────────────────────────────────────────
//  OPENING RANGE CALCULATION
//  Track the HIGH and cumulative volume across
//  all bars within the 9:30–10:00 window.
// ─────────────────────────────────────────────

var float orb_high       = na   // Highest high during the ORB window
var float orb_vol_total  = 0.0  // Total volume accumulated in the ORB
var int   orb_bar_count  = 0    // Number of bars in the ORB (for avg calculation)
var bool  orb_complete   = false // True once the ORB window has closed for the day
var line  orb_line       = na   // Reference to the drawn ORB high line

// Reset state at the start of each new trading day
if is_new_day
    orb_high      := na
    orb_vol_total := 0.0
    orb_bar_count := 0
    orb_complete  := false

// Accumulate the ORB high and volume while inside the opening range window
if is_in_orb_window
    orb_high      := na(orb_high) ? high : math.max(orb_high, high)
    orb_vol_total += volume
    orb_bar_count += 1

// Freeze the ORB once the window closes (first bar after 10:00 AM)
if not orb_complete and ny_time_mins >= orb_end_mins and not na(orb_high)
    orb_complete := true

// Average volume per bar during the ORB window
orb_avg_vol = orb_bar_count > 0 ? orb_vol_total / orb_bar_count : na


// ─────────────────────────────────────────────
//  VWAP
//  Built-in ta.vwap resets each session automatically.
// ─────────────────────────────────────────────

vwap_value = ta.vwap(hlc3)


// ─────────────────────────────────────────────
//  BREAKOUT CONDITIONS
// ─────────────────────────────────────────────

// Condition 1 — Close breaks above the ORB High (only after ORB is locked in)
cond_orb_break = orb_complete and not na(orb_high) and close > orb_high

// Condition 2 — Current bar volume is at least 1.5x the ORB average volume
cond_volume    = not na(orb_avg_vol) and volume >= (orb_avg_vol * vol_mult)

// Condition 3 — Price is above VWAP
cond_vwap      = not na(vwap_value) and close > vwap_value

// Condition 4 — We are within the first 2 hours of the session (before 11:30 AM)
cond_time      = is_in_session_window

// ALL conditions must be met simultaneously
all_conditions = cond_orb_break and cond_volume and cond_vwap and cond_time

// Fire only ONCE per breakout event (rising edge — first bar all conditions are true)
breakout_signal = all_conditions and not all_conditions[1]


// ─────────────────────────────────────────────
//  VISUALS
// ─────────────────────────────────────────────

// — Draw / extend the ORB High horizontal line —
if show_orb_line and orb_complete and not na(orb_high)
    // Create a new line at the start of each day's ORB completion
    if orb_bar_count > 0 and volume[0] == volume[0]  // always true; just triggers per-bar
        // Extend the line on every bar after ORB is complete
        if not na(orb_line)
            line.set_x2(orb_line, bar_index)
        // Draw a fresh line when ORB first completes
        if barstate.islast or (orb_complete and not orb_complete[1])
            orb_line := line.new(
                 x1    = bar_index - orb_bar_count,
                 y1    = orb_high,
                 x2    = bar_index,
                 y2    = orb_high,
                 color = orb_line_col,
                 width = 2,
                 style = line.style_dashed)

// — Green triangle below the breakout bar —
plotshape(
     show_triangle ? breakout_signal : na,
     title    = "Breakout Signal",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = tri_col,
     size     = size.normal,
     text     = "ORB▲",
     textcolor = tri_col)

// — Light green background when all conditions are active —
bgcolor(
     show_bg and all_conditions ? bg_col : na,
     title = "Breakout Background")

// — Plot VWAP for reference —
plot(vwap_value, title="VWAP", color=color.new(color.blue, 40), linewidth=1)

// — Plot the ORB High as a persistent horizontal level —
plot(orb_complete ? orb_high : na, title="ORB High", color=orb_line_col, linewidth=2, style=plot.style_linebr)


// ─────────────────────────────────────────────
//  ALERT
//  Fires once per bar (alert.freq_once_per_bar)
//  when all four conditions align on the close.
// ─────────────────────────────────────────────

// NOTE: alertcondition() message must be a const string — runtime series values
// like orb_high and vwap_value cannot be concatenated here. Use TradingView's
// built-in {{placeholders}} for dynamic price/time data in the alert message.
alertcondition(
     breakout_signal,
     title   = "ORB Breakout — All Conditions Met",
     message = "🚨 ORB BREAKOUT | Symbol: {{ticker}} | Price: {{close}} | Time: {{time}} | Bar High: {{high}} | Check chart for ORB High / VWAP levels.")

// ─────────────────────────────────────────────
//  DEBUG TABLE (top-right, visible on last bar)
//  Helpful for confirming condition states live.
// ─────────────────────────────────────────────

// Helper function — must be defined at top-level scope in Pine Script v5
bool_to_str(b) => b ? "✅" : "❌"

var table debug_tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.cell(debug_tbl, 0, 0, "Condition",       text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 1, 0, "Status",           text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 0, 1, "ORB Break",        text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 1, 1, bool_to_str(cond_orb_break), text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 0, 2, "Volume 1.5x",      text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 1, 2, bool_to_str(cond_volume),    text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 0, 3, "Above VWAP",       text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 1, 3, bool_to_str(cond_vwap),      text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 0, 4, "< 11:30 AM",       text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 1, 4, bool_to_str(cond_time),      text_color=color.white, text_size=size.small)
    table.cell(debug_tbl, 0, 5, "🔥 ALL MET",       text_color=color.yellow, text_size=size.small)
    table.cell(debug_tbl, 1, 5, bool_to_str(all_conditions), text_color=color.yellow, text_size=size.small)
````

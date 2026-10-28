# Multi-Session VWAP + ORB

- url: https://www.tradingview.com/script/ZUY5EtnX-Multi-Session-VWAP-ORB/
- type: indicator
- pine_id: PUB;0e245178b3db4f7eace13de65986102a
- version: 1.0

## Description

shows multi-session VWAP and ORB (customizable) 

includes:

NY VWAP
London VWAP
Daily VWAP
Weekly VWAP (resetting Sunday)

200EMA
9EMA

ORB (time customizable)

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Multi-Session VWAP + Opening Range Breakout

//@version=5
indicator("Multi-Session VWAP + ORB", overlay = true, max_bars_back = 1000)

// ─────────────────────────────────────────────
// SOURCE
// ─────────────────────────────────────────────

var g_src = "Source"
src = input.source(ohlc4, "VWAP Source", group = g_src)

// ─────────────────────────────────────────────
// NY SESSION VWAP
// ─────────────────────────────────────────────

var g_ny   = "NY Session VWAP"
show_ny    = input.bool(true,                        "Show",         group = g_ny, inline = "ny_show")
col_ny     = input.color(color.new(color.yellow, 0), "",             group = g_ny, inline = "ny_show")
width_ny   = input.int(2,                            "Width",        group = g_ny, minval = 1, maxval = 5)
ny_start_t = input.string("0930", "Start (HHMM)", group = g_ny, inline = "ny_time", tooltip = "Enter time in HHMM format, e.g. 0930 = 9:30am")
ny_end_t   = input.string("1600", "End (HHMM)",   group = g_ny, inline = "ny_time")
ny_tz      = input.string("America/New_York", "Timezone", group = g_ny, options = ["America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Sao_Paulo","Europe/London","Europe/Berlin","Europe/Moscow","Asia/Dubai","Asia/Kolkata","Asia/Singapore","Asia/Tokyo","Australia/Sydney","UTC"])

// ─────────────────────────────────────────────
// LONDON SESSION VWAP
// ─────────────────────────────────────────────

var g_lo   = "London Session VWAP"
show_lo    = input.bool(true,                        "Show",         group = g_lo, inline = "lo_show")
col_lo     = input.color(color.new(color.blue, 0),   "",             group = g_lo, inline = "lo_show")
width_lo   = input.int(2,                            "Width",        group = g_lo, minval = 1, maxval = 5)
lo_start_t = input.string("0300",                    "Start (HHMM)", group = g_lo, inline = "lo_time")
lo_end_t   = input.string("1100",                    "End (HHMM)",   group = g_lo, inline = "lo_time")
lo_tz      = input.string("America/New_York", "Timezone", group = g_lo, options = ["America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Sao_Paulo","Europe/London","Europe/Berlin","Europe/Moscow","Asia/Dubai","Asia/Kolkata","Asia/Singapore","Asia/Tokyo","Australia/Sydney","UTC"])

// ─────────────────────────────────────────────
// DAILY VWAP
// ─────────────────────────────────────────────

var g_d    = "Daily VWAP"
show_d     = input.bool(true,                        "Show",  group = g_d, inline = "d_show")
col_d      = input.color(color.new(color.white, 0),  "",      group = g_d, inline = "d_show")
width_d    = input.int(2,                            "Width", group = g_d, minval = 1, maxval = 5)

// ─────────────────────────────────────────────
// WEEKLY VWAP
// ─────────────────────────────────────────────

var g_w    = "Weekly VWAP  (resets each Sunday)"
show_w     = input.bool(true,                          "Show",  group = g_w, inline = "w_show")
col_w      = input.color(color.new(color.fuchsia, 0),  "",      group = g_w, inline = "w_show")
width_w    = input.int(2,                              "Width", group = g_w, minval = 1, maxval = 5)
w_tz       = input.string("America/New_York", "Timezone", group = g_w, tooltip = "Controls which timezone defines the Sunday week-reset boundary.", options = ["America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Sao_Paulo","Europe/London","Europe/Berlin","Europe/Moscow","Asia/Dubai","Asia/Kolkata","Asia/Singapore","Asia/Tokyo","Australia/Sydney","UTC"])

// ─────────────────────────────────────────────
// EMAs
// ─────────────────────────────────────────────

var g_ema9   = "9 EMA"
show_ema9    = input.bool(true,                      "Show 9 EMA", group = g_ema9,   inline = "e9")
col_ema9     = input.color(color.new(color.lime, 0), "",           group = g_ema9,   inline = "e9")
width_ema9   = input.int(1,                          "Width",      group = g_ema9,   minval = 1, maxval = 5)

var g_ema200 = "200 EMA"
show_ema200  = input.bool(true,                        "Show 200 EMA", group = g_ema200, inline = "e200")
col_ema200   = input.color(color.new(color.orange, 0), "",             group = g_ema200, inline = "e200")
width_ema200 = input.int(2,                            "Width",        group = g_ema200, minval = 1, maxval = 5)

// ─────────────────────────────────────────────
// OPENING RANGE BREAKOUT (ORB)
// ─────────────────────────────────────────────

var g_orb      = "Opening Range Breakout (ORB)"
show_orb       = input.bool(true,                          "Show ORB",          group = g_orb)
orb_range_start = input.string("0930", "Range Start (HHMM)", group = g_orb, inline = "orb_range", tooltip = "Start of the opening range. Default 0930 = 9:30am")
orb_range_end   = input.string("0945", "Range End (HHMM)",   group = g_orb, inline = "orb_range", tooltip = "End of range. HIGH and LOW of all candles in this window are used.")
orb_extend_to   = input.string("1600", "Extend Lines Until (HHMM)", group = g_orb, tooltip = "ORB high/low lines extend until this time each day. Default 1600 = 4:00pm")
orb_tz          = input.string("America/New_York", "Timezone", group = g_orb, options = ["America/New_York","America/Chicago","America/Denver","America/Los_Angeles","America/Sao_Paulo","Europe/London","Europe/Berlin","Europe/Moscow","Asia/Dubai","Asia/Kolkata","Asia/Singapore","Asia/Tokyo","Australia/Sydney","UTC"])
col_orb_high    = input.color(color.new(color.green, 20), "High Line Color",  group = g_orb, inline = "orb_cols")
col_orb_low     = input.color(color.new(color.red,   20), "Low Line Color",   group = g_orb, inline = "orb_cols")
col_orb_mid     = input.color(color.new(color.gray,  40), "Mid Line Color",   group = g_orb, inline = "orb_cols")
width_orb       = input.int(2, "Width", group = g_orb, minval = 1, maxval = 5)

// ─────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────

ny_sess_str = ny_start_t + "-" + ny_end_t
lo_sess_str = lo_start_t + "-" + lo_end_t

ny_session  = time(timeframe.period, ny_sess_str, ny_tz)
ny_open     = not na(ny_session) and na(ny_session[1])
in_ny       = not na(ny_session)

lo_session  = time(timeframe.period, lo_sess_str, lo_tz)
lo_open     = not na(lo_session) and na(lo_session[1])
in_lo       = not na(lo_session)

new_day     = ta.change(time("D")) != 0
new_week    = ta.change(time("W", w_tz)) != 0

// ORB sessions
orb_range_str   = orb_range_start + "-" + orb_range_end
orb_extend_str  = orb_range_start + "-" + orb_extend_to

orb_range_sess  = time(timeframe.period, orb_range_str,  orb_tz)
orb_extend_sess = time(timeframe.period, orb_extend_str, orb_tz)

in_orb_range    = not na(orb_range_sess)
orb_range_open  = not na(orb_range_sess) and na(orb_range_sess[1])   // first candle of range
orb_range_close = na(orb_range_sess) and not na(orb_range_sess[1])   // range just closed
in_orb_extend   = not na(orb_extend_sess)                             // within the full extension window

// ─────────────────────────────────────────────
// VWAP CALCULATIONS
// ─────────────────────────────────────────────

// ── NY ───────────────────────────────────────
var float ny_pv  = 0.0
var float ny_vol = 0.0
if ny_open
    ny_pv  := 0.0
    ny_vol := 0.0
if in_ny
    ny_pv  += src * volume
    ny_vol += volume
ny_vwap = in_ny and ny_vol > 0 ? ny_pv / ny_vol : na

// ── LONDON ───────────────────────────────────
var float lo_pv  = 0.0
var float lo_vol = 0.0
if lo_open
    lo_pv  := 0.0
    lo_vol := 0.0
if in_lo
    lo_pv  += src * volume
    lo_vol += volume
lo_vwap = in_lo and lo_vol > 0 ? lo_pv / lo_vol : na

// ── DAILY ────────────────────────────────────
var float d_pv  = 0.0
var float d_vol = 0.0
if new_day
    d_pv  := 0.0
    d_vol := 0.0
d_pv  += src * volume
d_vol += volume
d_vwap = d_vol > 0 ? d_pv / d_vol : na

// ── WEEKLY ───────────────────────────────────
var float w_pv  = 0.0
var float w_vol = 0.0
if new_week
    w_pv  := 0.0
    w_vol := 0.0
w_pv  += src * volume
w_vol += volume
w_vwap = w_vol > 0 ? w_pv / w_vol : na

// ─────────────────────────────────────────────
// EMAs
// ─────────────────────────────────────────────

ema9   = ta.ema(close, 9)
ema200 = ta.ema(close, 200)

// ─────────────────────────────────────────────
// ORB LOGIC
// Track the high and low across all candles in the opening range window,
// then draw horizontal lines that extend to orb_extend_to each day.
// Lines are deleted and redrawn on each new day so they don't carry over.
// ─────────────────────────────────────────────

var float orb_high   = na
var float orb_low    = na
var int   orb_x1     = na
var line  orb_h_line = na
var line  orb_l_line = na
var line  orb_m_line = na
var bool  orb_locked = false

// Reset on first candle of the opening range each day
if orb_range_open
    orb_high   := high
    orb_low    := low
    orb_x1     := bar_index
    orb_locked := false
    line.delete(orb_h_line)
    line.delete(orb_l_line)
    line.delete(orb_m_line)
    orb_h_line := na
    orb_l_line := na
    orb_m_line := na

// Expand high/low while inside the range window (live, every bar)
if in_orb_range and not orb_locked
    orb_high := math.max(orb_high, high)
    orb_low  := math.min(orb_low,  low)

// Draw / update lines live during the range AND during the extension window
if show_orb and (in_orb_range or (in_orb_extend and orb_locked)) and not na(orb_high)
    orb_mid = (orb_high + orb_low) / 2

    // Create lines on the very first bar they're needed
    if na(orb_h_line)
        orb_h_line := line.new(orb_x1, orb_high, bar_index, orb_high, color = col_orb_high, width = width_orb, style = line.style_solid, extend = extend.none)
        orb_l_line := line.new(orb_x1, orb_low,  bar_index, orb_low,  color = col_orb_low,  width = width_orb, style = line.style_solid, extend = extend.none)
        orb_m_line := line.new(orb_x1, orb_mid,  bar_index, orb_mid,  color = col_orb_mid, width = 1, style = line.style_dashed, extend = extend.none)
    else
        // Update prices (in case high/low expanded) and push right edge forward
        line.set_y1(orb_h_line, orb_high)
        line.set_y2(orb_h_line, orb_high)
        line.set_x2(orb_h_line, bar_index)

        line.set_y1(orb_l_line, orb_low)
        line.set_y2(orb_l_line, orb_low)
        line.set_x2(orb_l_line, bar_index)

        line.set_y1(orb_m_line, orb_mid)
        line.set_y2(orb_m_line, orb_mid)
        line.set_x2(orb_m_line, bar_index)

// Lock levels once the range window closes
if orb_range_close
    orb_locked := true

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

plot(show_w      ? w_vwap  : na, title = "Weekly VWAP", color = col_w,      linewidth = width_w,    style = plot.style_linebr)
plot(show_d      ? d_vwap  : na, title = "Daily VWAP",  color = col_d,      linewidth = width_d,    style = plot.style_linebr)
plot(show_lo     ? lo_vwap : na, title = "London VWAP", color = col_lo,     linewidth = width_lo,   style = plot.style_linebr)
plot(show_ny     ? ny_vwap : na, title = "NY VWAP",     color = col_ny,     linewidth = width_ny,   style = plot.style_linebr)
plot(show_ema9   ? ema9    : na, title = "9 EMA",       color = col_ema9,   linewidth = width_ema9,   style = plot.style_line)
plot(show_ema200 ? ema200  : na, title = "200 EMA",     color = col_ema200, linewidth = width_ema200, style = plot.style_line)
````

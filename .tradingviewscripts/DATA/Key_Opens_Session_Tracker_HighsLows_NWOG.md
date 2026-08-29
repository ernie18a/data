<!-- tradingview-pine-id: PUB;098c8d26b8cb4e36ad4a0ddfc6b58267 -->
<!-- tradingviewscripts-format: 1 -->
# Key Opens & Session Tracker + Highs/Lows & NWOG

Source: https://www.tradingview.com/script/pyIRD0rH-Key-Opens-Session-Tracker-Highs-Lows-NWOG/

## Description

Key Opens & Session Tracker + Highs/Lows & NWOG
OVERVIEW
An all-in-one intraday context tool that marks the reference levels most session traders
watch: the Midnight and 10:00 AM opens, live Asian and London session ranges, the New Week
Opening Gap, and a status panel showing which of the four global sessions are currently
open. Everything is drawn on the price chart with rays that extend to the right, so the
levels stay visible as price develops through the day.
WHAT IT PLOTS
1. Key Open Rays
   • Midnight Open — captured from the open of the first bar of each new day in the chosen
     timezone (default America/New_York). Drawn as a horizontal ray extending right.
   • 10 AM Open — captured from the open of the 10:00 bar in the same timezone, also drawn
     as an extending ray.
   Both are labeled directly on the chart. Only the current day's opens are kept; the
   previous day's rays are removed when a new one is set, keeping the chart clean.
2. Asian and London Session Highs & Lows
   • Asian range is tracked over the Tokyo window (19:00–04:00 NY).
   • London range is tracked over the London window (03:00–12:00 NY).
   When a session begins, the high and low are seeded from that first bar and then updated
   in real time as the session extends. Each level is drawn as a labeled ray that continues
   to the right after the session closes, so the completed session range remains as
   reference during the following session.
3. New Week Opening Gap (NWOG)
   At the start of each new trading week, the script measures the distance between the
   prior week's close and the new week's open and draws the zone between them as two lines
   with a shaded fill. Useful as a weekly reference area that price often revisits.
4. Session Dashboard
   A table in the bottom-right corner shows live Active / Closed status for Sydney, Tokyo,
   London, and New York, so you always know which participants are in the market:
     Sydney  17:00–02:00 NY
     Tokyo   19:00–04:00 NY
     London  03:00–12:00 NY
     New York 08:00–17:00 NY
HOW TO USE IT
Open levels act as a daily equilibrium reference — price trading above the Midnight Open
frames a bullish session bias, below it a bearish one, and the 10 AM Open gives a second
reference once the New York morning is underway. The Asian and London highs and lows mark
the liquidity resting above and below completed ranges; sweeps of those levels followed by
a reversal back inside are a common setup, while a clean break and hold beyond them argues
for continuation. The NWOG zone acts as a weekly reference area that can behave as support
or resistance on retest. The dashboard adds context for expected volatility — the
London/New York overlap is typically the most active window of the day.
SETTINGS
• Timezone for Key Opens — controls the timezone used for the Midnight and 10 AM opens
  (default America/New_York). Session windows are fixed to New York time.
• Key Open Ray Color — color for the Midnight and 10 AM open rays and labels.
• Session High/Low Color — color for the Asian and London range lines and labels.
• NWOG Color — color for the New Week Opening Gap lines, fill, and label.
NOTES
• Designed for intraday timeframes. Use a timeframe that divides evenly into the session
  windows (1m to 1h works well); on higher timeframes the open bars and session boundaries
  will not resolve accurately.
• Only the most recent instance of each level is displayed — historical opens, session
  ranges, and gaps are removed as new ones form. This is intentional, to keep the chart
  readable rather than accumulating clutter.
• This is a contextual reference tool, not a signal generator. It does not produce entries,
  exits, or alerts, and nothing here is financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Key Opens & Session Tracker + Highs/Lows & NWOG", overlay = true)

// --- Inputs ---
tz = input.string("America/New_York", title = "Timezone for Key Opens")
color_ray = input.color(#f23645, title = "Key Open Ray Color")
color_hl = input.color(color.yellow, title = "Session High/Low Color")
color_nwog = input.color(color.blue, title = "NWOG Color")

// --- Key Open Rays ---
// Variables to hold the line and label objects
var line midnight_ray = na
var label midnight_lbl = na

var line am10_ray = na
var label am10_lbl = na

var float midnight_open = na
var float am10_open = na

// Extract time components
current_day = dayofmonth(time, tz)
current_hour = hour(time, tz)
current_minute = minute(time, tz)

is_new_day = current_day != current_day[1]

// 1. Midnight detection (Hour 0)
is_midnight = (current_hour == 0 and current_minute == 0)
var int last_midnight_day = na
if is_midnight or is_new_day
    if na(last_midnight_day) or last_midnight_day != current_day
        last_midnight_day := current_day
        midnight_open := open
        
        if not na(midnight_ray)
            line.delete(midnight_ray)
        if not na(midnight_lbl)
            label.delete(midnight_lbl)
            
        midnight_ray := line.new(bar_index, open, bar_index + 1, open, extend = extend.right, color = color_ray, width = 2)
        midnight_lbl := label.new(bar_index, open, "Midnight Open", color = color(na), textcolor = color_ray, style = label.style_label_down, size = size.small)

// 2. 10 AM detection
is_10am = (current_hour == 10 and current_minute == 0)
var int last_10am_day = na
if is_10am
    if na(last_10am_day) or last_10am_day != current_day
        last_10am_day := current_day
        am10_open := open
        
        if not na(am10_ray)
            line.delete(am10_ray)
        if not na(am10_lbl)
            label.delete(am10_lbl)
            
        am10_ray := line.new(bar_index, open, bar_index + 1, open, extend = extend.right, color = color_ray, width = 2)
        am10_lbl := label.new(bar_index, open, "10 AM Open", color = color(na), textcolor = color_ray, style = label.style_label_up, size = size.small)


// --- Session Tracker & Highs/Lows ---
is_sydney = not na(time(timeframe.period, "1700-0200", "America/New_York"))
is_tokyo  = not na(time(timeframe.period, "1900-0400", "America/New_York"))
is_london = not na(time(timeframe.period, "0300-1200", "America/New_York"))
is_ny     = not na(time(timeframe.period, "0800-1700", "America/New_York"))

// Asian (Tokyo) Highs & Lows
var float asia_h = na
var float asia_l = na
var line asia_h_line = na
var line asia_l_line = na
var label asia_h_lbl = na
var label asia_l_lbl = na

asia_start = is_tokyo and not is_tokyo[1]

if asia_start
    asia_h := high
    asia_l := low
    if not na(asia_h_line)
        line.delete(asia_h_line)
    if not na(asia_l_line)
        line.delete(asia_l_line)
    if not na(asia_h_lbl)
        label.delete(asia_h_lbl)
    if not na(asia_l_lbl)
        label.delete(asia_l_lbl)
        
    asia_h_line := line.new(bar_index, asia_h, bar_index + 1, asia_h, extend = extend.right, color = color_hl, style = line.style_solid, width = 2)
    asia_l_line := line.new(bar_index, asia_l, bar_index + 1, asia_l, extend = extend.right, color = color_hl, style = line.style_solid, width = 2)
    
    asia_h_lbl := label.new(bar_index, asia_h, "Asian High", color = color(na), textcolor = color_hl, style = label.style_label_down, size = size.small)
    asia_l_lbl := label.new(bar_index, asia_l, "Asian Low", color = color(na), textcolor = color_hl, style = label.style_label_up, size = size.small)
    
else if is_tokyo
    if high > asia_h
        asia_h := high
        line.set_xy1(asia_h_line, bar_index, asia_h)
        line.set_xy2(asia_h_line, bar_index + 1, asia_h)
        label.set_xy(asia_h_lbl, bar_index, asia_h)
        
    if low < asia_l
        asia_l := low
        line.set_xy1(asia_l_line, bar_index, asia_l)
        line.set_xy2(asia_l_line, bar_index + 1, asia_l)
        label.set_xy(asia_l_lbl, bar_index, asia_l)

// London Highs & Lows
var float lon_h = na
var float lon_l = na
var line lon_h_line = na
var line lon_l_line = na
var label lon_h_lbl = na
var label lon_l_lbl = na

lon_start = is_london and not is_london[1]

if lon_start
    lon_h := high
    lon_l := low
    if not na(lon_h_line)
        line.delete(lon_h_line)
    if not na(lon_l_line)
        line.delete(lon_l_line)
    if not na(lon_h_lbl)
        label.delete(lon_h_lbl)
    if not na(lon_l_lbl)
        label.delete(lon_l_lbl)
        
    lon_h_line := line.new(bar_index, lon_h, bar_index + 1, lon_h, extend = extend.right, color = color_hl, style = line.style_solid, width = 1)
    lon_l_line := line.new(bar_index, lon_l, bar_index + 1, lon_l, extend = extend.right, color = color_hl, style = line.style_solid, width = 1)
    
    lon_h_lbl := label.new(bar_index, lon_h, "London High", color = color(na), textcolor = color_hl, style = label.style_label_down, size = size.small)
    lon_l_lbl := label.new(bar_index, lon_l, "London Low", color = color(na), textcolor = color_hl, style = label.style_label_up, size = size.small)
    
else if is_london
    if high > lon_h
        lon_h := high
        line.set_xy1(lon_h_line, bar_index, lon_h)
        line.set_xy2(lon_h_line, bar_index + 1, lon_h)
        label.set_xy(lon_h_lbl, bar_index, lon_h)
        
    if low < lon_l
        lon_l := low
        line.set_xy1(lon_l_line, bar_index, lon_l)
        line.set_xy2(lon_l_line, bar_index + 1, lon_l)
        label.set_xy(lon_l_lbl, bar_index, lon_l)


// --- New Week Opening Gap (NWOG) ---
var line nwog_top_line = na
var line nwog_bot_line = na
var label nwog_lbl = na
var linefill nwog_fill = na

is_new_week = ta.change(time("W")) != 0

if is_new_week
    // Previous week close and current week open
    float prev_close = close[1]
    float curr_open = open
    
    float gap_high = math.max(prev_close, curr_open)
    float gap_low  = math.min(prev_close, curr_open)
    
    if not na(nwog_top_line)
        line.delete(nwog_top_line)
    if not na(nwog_bot_line)
        line.delete(nwog_bot_line)
    if not na(nwog_lbl)
        label.delete(nwog_lbl)
        
    nwog_top_line := line.new(bar_index, gap_high, bar_index + 1, gap_high, extend = extend.right, color = color_nwog, style = line.style_solid, width = 1)
    nwog_bot_line := line.new(bar_index, gap_low, bar_index + 1, gap_low, extend = extend.right, color = color_nwog, style = line.style_solid, width = 1)
    
    nwog_fill := linefill.new(nwog_top_line, nwog_bot_line, color = color.new(color_nwog, 85))
    nwog_lbl := label.new(bar_index, gap_high, "NWOG", color = color(na), textcolor = color_nwog, style = label.style_label_down, size = size.small)

// --- Dashboard ---
var table session_dash = table.new(position.bottom_right, 2, 5, bgcolor = color.new(color.black, 80), border_color = color.gray, border_width = 1)

if barstate.islast
    // Table Header
    table.cell(session_dash, 0, 0, "Market Session", text_color = color.white, bgcolor = color.new(color.gray, 50))
    table.cell(session_dash, 1, 0, "Status", text_color = color.white, bgcolor = color.new(color.gray, 50))
    
    // Sydney
    table.cell(session_dash, 0, 1, "Sydney", text_color = color.white)
    table.cell(session_dash, 1, 1, is_sydney ? "Active" : "Closed", text_color = is_sydney ? #089981 : color.gray)
    
    // Tokyo (Asian)
    table.cell(session_dash, 0, 2, "Tokyo", text_color = color.white)
    table.cell(session_dash, 1, 2, is_tokyo ? "Active" : "Closed", text_color = is_tokyo ? #089981 : color.gray)
    
    // London
    table.cell(session_dash, 0, 3, "London", text_color = color.white)
    table.cell(session_dash, 1, 3, is_london ? "Active" : "Closed", text_color = is_london ? #089981 : color.gray)
    
    // New York
    table.cell(session_dash, 0, 4, "New York", text_color = color.white)
    table.cell(session_dash, 1, 4, is_ny ? "Active" : "Closed", text_color = is_ny ? #089981 : color.gray)
````

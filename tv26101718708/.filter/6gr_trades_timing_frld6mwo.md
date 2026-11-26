# 6GR Trades - Timing

- url: https://www.tradingview.com/script/frLD6MwO-6GR-Trades-Timing/
- type: indicator
- pine_id: PUB;dc18998e2226421193c5ab726dbb6a82
- version: 1.0

## Description

6GR Trades – Session Timing Indicator

Overview

A professional TradingView indicator built for session-based price action traders. It maps the four major trading sessions directly onto your chart in real time, shading the full background of each session window so you always have instant visual context for where price is trading within the trading day — all configurable without touching a line of code.

Sessions Covered

Asian (Gray) — the overnight session, the range most commonly targeted for liquidity sweeps during the European open
Frankfurt (Yellow) — the earliest European liquidity window, often where the first directional move of the day is initiated
London (Green) — the highest volume session where the majority of institutional order flow enters the market
New York (Red) — the second major liquidity window, known for reversals and continuations off the London range


What It Plots

Full background shading across the entire chart for each active session
Live session boxes capturing the high and low of each session in real time
High, mid, and low lines for all four sessions
Yesterday's high, low, and close for daily reference
Weekly high and low for broader context


Customisation

Rename, recolour, and toggle each session independently
Show or hide the session label inside each box
Manually adjust start and end times for every session in London time
Auto-hides boxes on higher timeframes to keep your chart clean
Full watermark control with live symbol, timeframe, and date


Built for traders who use session opens, liquidity sweeps, and range formations as the core of their decision making.

## Source Code

````pine
// 6GR Trades
//@version=6
indicator('6GR Trades - Timing', overlay=true, max_labels_count=500, max_boxes_count=500)

// ---------- INPUTS --------------
HideTFAbove      = input.int(59, 'Hide Boxes on TF above (Minutes)', minval=15, maxval=120)
HideTFAbove_asia = 60

// ---------- SESSION TOGGLES, NAMES & LABELS --------------
show_asia       = input(true,  'Show Session',     group="Session 1 - Asian")
asia_name       = input.string("Asian",            "Session Name",      group="Session 1 - Asian")
asia_label      = input(true,  'Show Label',       group="Session 1 - Asian")
asia_show_lines = input(true,  'Show H/L/M Lines', group="Session 1 - Asian")

show_fra        = input(true,  'Show Session',     group="Session 2 - Frankfurt")
fra_name        = input.string("Frankfurt",        "Session Name",      group="Session 2 - Frankfurt")
fra_label       = input(true,  'Show Label',       group="Session 2 - Frankfurt")
fra_show_lines  = input(true,  'Show H/L/M Lines', group="Session 2 - Frankfurt")

show_lon        = input(true,  'Show Session',     group="Session 3 - London")
lon_name        = input.string("London",           "Session Name",      group="Session 3 - London")
lon_label       = input(true,  'Show Label',       group="Session 3 - London")
lon_show_lines  = input(true,  'Show H/L/M Lines', group="Session 3 - London")

show_nyt        = input(true,  'Show Session',     group="Session 4 - New York")
nyt_name        = input.string("New York",         "Session Name",      group="Session 4 - New York")
nyt_label       = input(true,  'Show Label',       group="Session 4 - New York")
nyt_show_lines  = input(true,  'Show H/L/M Lines', group="Session 4 - New York")

// ---------- SESSION COLORS --------------
asia_color      = input(color.new(color.gray,   85), 'Fill Color', group="Session 1 - Asian")
asia_line_color = input(color.new(color.gray,   40), 'Line Color', group="Session 1 - Asian")
fra_color       = input(color.new(color.yellow, 85), 'Fill Color', group="Session 2 - Frankfurt")
fra_line_color  = input(color.new(color.yellow, 40), 'Line Color', group="Session 2 - Frankfurt")
lon_color       = input(color.new(color.green,  85), 'Fill Color', group="Session 3 - London")
lon_line_color  = input(color.new(color.green,  40), 'Line Color', group="Session 3 - London")
nyt_color       = input(color.new(color.red,    85), 'Fill Color', group="Session 4 - New York")
nyt_line_color  = input(color.new(color.red,    40), 'Line Color', group="Session 4 - New York")

// ---------- SESSION TIME INPUTS (London Time) --------------
asia_start_hour = input.int(0,  'Start Hour',   minval=0, maxval=23, group="Session 1 - Asian",     tooltip="London Time")
asia_start_min  = input.int(0,  'Start Minute', minval=0, maxval=59, group="Session 1 - Asian")
asia_end_hour   = input.int(9,  'End Hour',     minval=0, maxval=23, group="Session 1 - Asian",     tooltip="London Time")
asia_end_min    = input.int(0,  'End Minute',   minval=0, maxval=59, group="Session 1 - Asian")

fra_start_hour  = input.int(7,  'Start Hour',   minval=0, maxval=23, group="Session 2 - Frankfurt", tooltip="London Time")
fra_start_min   = input.int(0,  'Start Minute', minval=0, maxval=59, group="Session 2 - Frankfurt")
fra_end_hour    = input.int(8,  'End Hour',     minval=0, maxval=23, group="Session 2 - Frankfurt", tooltip="London Time")
fra_end_min     = input.int(0,  'End Minute',   minval=0, maxval=59, group="Session 2 - Frankfurt")

lon_start_hour  = input.int(8,  'Start Hour',   minval=0, maxval=23, group="Session 3 - London",    tooltip="London Time")
lon_start_min   = input.int(0,  'Start Minute', minval=0, maxval=59, group="Session 3 - London")
lon_end_hour    = input.int(12, 'End Hour',     minval=0, maxval=23, group="Session 3 - London",    tooltip="London Time")
lon_end_min     = input.int(0,  'End Minute',   minval=0, maxval=59, group="Session 3 - London")

nyt_start_hour  = input.int(13, 'Start Hour',   minval=0, maxval=23, group="Session 4 - New York",  tooltip="London Time")
nyt_start_min   = input.int(0,  'Start Minute', minval=0, maxval=59, group="Session 4 - New York")
nyt_end_hour    = input.int(17, 'End Hour',     minval=0, maxval=23, group="Session 4 - New York",  tooltip="London Time")
nyt_end_min     = input.int(0,  'End Minute',   minval=0, maxval=59, group="Session 4 - New York")

var string londonTZ = 'Europe/London'

//------------ WATERMARKS --------------------
titelCheck    = input.bool(true,  title="Show Text",        group="text")
title         = input.string("6GR Trades",                  "Title",    group="text")
subtitle      = input.string("Never  |  Predict  |  React", "Subtitle", group="text")

symInfoCheck  = input.bool(true, title="Show Symbol Info", group="watermark position")
symInfo       = syminfo.ticker + " | " + timeframe.period + (timeframe.isminutes ? "M" : na)
date          = str.tostring(dayofmonth(time_close)) + "/" + str.tostring(month(time_close)) + "/" + str.tostring(year(time_close))

textVPosition = input.string("top",    "Vertical Position",   options=["top", "middle", "bottom"], group="watermark position")
textHPosition = input.string("center", "Horizontal Position", options=["left", "center", "right"], group="watermark position")
symVPosition  = input.string("bottom", "Vertical Position",   options=["top", "middle", "bottom"], group="symbol position")
symHPosition  = input.string("center", "Horizontal Position", options=["left", "center", "right"], group="symbol position")

width   = input.int(0, "Width",  minval=0, maxval=100, group="cell size")
height  = input.int(0, "Height", minval=0, maxval=100, group="cell size")

c_title    = input.color(color.new(color.black, 0),  "Title Color",     group="title settings")
s_title    = input.string("large",  "Title Size",    options=["tiny", "small", "normal", "large", "huge", "auto"], group="title settings")
a_title    = input.string("center", "Title Alignment", options=["center", "left", "right"], group="title settings")

c_subtitle = input.color(color.new(color.black, 30), "Subtitle Color",   group="subtitle settings")
s_subtitle = input.string("normal", "Subtitle Size", options=["tiny", "small", "normal", "large", "huge", "auto"], group="subtitle settings")
a_subtitle = input.string("center", "Subtitle Alignment", options=["center", "left", "right"], group="subtitle settings")

c_symInfo  = input.color(color.new(color.black, 30), "Symbol Color",     group="symbol settings")
s_symInfo  = input.string("normal", "Symbol Size",   options=["tiny", "small", "normal", "large", "huge", "auto"], group="symbol settings")
a_symInfo  = input.string("center", "Symbol Alignment", options=["center", "left", "right"], group="symbol settings")
c_bg       = input.color(color.new(color.blue, 100), "Background",       group="background")

// ---------- HELPER FUNCTIONS --------------
PadTwo(n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

BuildSession(sh, sm, eh, em) =>
    PadTwo(sh) + PadTwo(sm) + "-" + PadTwo(eh) + PadTwo(em)

GetTFMinutes() =>
    (time - time[1]) / 60000

TFIsCorrect      = GetTFMinutes() <= HideTFAbove
TFIsCorrect_asia = GetTFMinutes() <= HideTFAbove_asia

// ---------- SESSION HIGH/LOW TRACKING ----------
GetSessionHighLow(session_active, start) =>
    var float hh = high
    var float ll = low
    if session_active == 1
        if high > hh or start
            hh := high
        if low < ll or start
            ll := low
    [hh, ll]

// ---------- BUILD SESSION STRINGS ----------
asia_session_str = BuildSession(asia_start_hour, asia_start_min, asia_end_hour, asia_end_min) + ":1234567"
fra_session_str  = BuildSession(fra_start_hour,  fra_start_min,  fra_end_hour,  fra_end_min)  + ":23456"
lon_session_str  = BuildSession(lon_start_hour,  lon_start_min,  lon_end_hour,  lon_end_min)  + ":23456"
nyt_session_str  = BuildSession(nyt_start_hour,  nyt_start_min,  nyt_end_hour,  nyt_end_min)  + ":23456"

t_asia = time(timeframe.period, asia_session_str, londonTZ)
t_fra  = time(timeframe.period, fra_session_str,  londonTZ)
t_lon  = time(timeframe.period, lon_session_str,  londonTZ)
t_nyt  = time(timeframe.period, nyt_session_str,  londonTZ)

// ---------- ACTIVE SESSION CONDITIONS ----------
asia_session_active = TFIsCorrect_asia and show_asia ? not na(t_asia) ? 1 : 0 : 0
fra_session_active  = TFIsCorrect      and show_fra  ? not na(t_fra)  ? 1 : 0 : 0
lon_session_active  = TFIsCorrect      and show_lon  ? not na(t_lon)  ? 1 : 0 : 0
nyt_session_active  = TFIsCorrect      and show_nyt  ? not na(t_nyt)  ? 1 : 0 : 0

// ---------- SESSION START FLAGS ----------
bool asia_start_bar = asia_session_active[1] == 0 and asia_session_active == 1
bool fra_start_bar  = fra_session_active[1]  == 0 and fra_session_active  == 1
bool lon_start_bar  = lon_session_active[1]  == 0 and lon_session_active  == 1
bool nyt_start_bar  = nyt_session_active[1]  == 0 and nyt_session_active  == 1

// ---------- SESSION HIGHS & LOWS ----------
[asia_h, asia_l] = GetSessionHighLow(asia_session_active, asia_start_bar)
[fra_h,  fra_l]  = GetSessionHighLow(fra_session_active,  fra_start_bar)
[lon_h,  lon_l]  = GetSessionHighLow(lon_session_active,  lon_start_bar)
[nyt_h,  nyt_l]  = GetSessionHighLow(nyt_session_active,  nyt_start_bar)

// ---------- SESSION START TIME ----------
var int asia_time_start = na
var int fra_time_start  = na
var int lon_time_start  = na
var int nyt_time_start  = na
asia_time_start := asia_start_bar ? time : asia_time_start[1]
fra_time_start  := fra_start_bar  ? time : fra_time_start[1]
lon_time_start  := lon_start_bar  ? time : lon_time_start[1]
nyt_time_start  := nyt_start_bar  ? time : nyt_time_start[1]

// ---------- SESSION DURATIONS (minutes) ----------
// Used only for the box right edge — matches session length
asia_dur = (asia_end_hour * 60 + asia_end_min - (asia_start_hour * 60 + asia_start_min))
fra_dur  = (fra_end_hour  * 60 + fra_end_min  - (fra_start_hour  * 60 + fra_start_min))
lon_dur  = (lon_end_hour  * 60 + lon_end_min  - (lon_start_hour  * 60 + lon_start_min))
nyt_dur  = (nyt_end_hour  * 60 + nyt_end_min  - (nyt_start_hour  * 60 + nyt_start_min))

// Convert to milliseconds
asia_ms = asia_dur * 60 * 1000
fra_ms  = fra_dur  * 60 * 1000
lon_ms  = lon_dur  * 60 * 1000
nyt_ms  = nyt_dur  * 60 * 1000

// ---------- DRAW BOXES — using the proven working pattern ----------
// Box is drawn on session start and deleted/redrawn each bar to update H/L

if asia_session_active == 1
    string asia_txt = asia_label ? asia_name : ""
    box.new(left=asia_time_start, bottom=asia_l, top=asia_h,
         right        = asia_time_start + asia_ms,
         xloc         = xloc.bar_time,
         bgcolor      = asia_color,
         border_color = asia_line_color,
         border_width = 1,
         text         = asia_txt,
         text_color   = asia_line_color,
         text_size    = size.small,
         text_valign  = text.align_top,
         text_halign  = text.align_center)
    if asia_session_active[1] == 1
        box.delete(box.all.get(box.all.size() - 2))
    if asia_show_lines
        float asia_m = (asia_h + asia_l) / 2
        line.new(x1=asia_time_start, y1=asia_h, x2=asia_time_start + asia_ms, y2=asia_h, xloc=xloc.bar_time, color=asia_line_color, width=1)
        line.new(x1=asia_time_start, y1=asia_m, x2=asia_time_start + asia_ms, y2=asia_m, xloc=xloc.bar_time, color=asia_line_color, width=1, style=line.style_dashed)
        line.new(x1=asia_time_start, y1=asia_l, x2=asia_time_start + asia_ms, y2=asia_l, xloc=xloc.bar_time, color=asia_line_color, width=1)
        if asia_session_active[1] == 1
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))

if fra_session_active == 1
    string fra_txt = fra_label ? fra_name : ""
    box.new(left=fra_time_start, bottom=fra_l, top=fra_h,
         right        = fra_time_start + fra_ms,
         xloc         = xloc.bar_time,
         bgcolor      = fra_color,
         border_color = fra_line_color,
         border_width = 1,
         text         = fra_txt,
         text_color   = fra_line_color,
         text_size    = size.small,
         text_valign  = text.align_top,
         text_halign  = text.align_center)
    if fra_session_active[1] == 1
        box.delete(box.all.get(box.all.size() - 2))
    if fra_show_lines
        float fra_m = (fra_h + fra_l) / 2
        line.new(x1=fra_time_start, y1=fra_h, x2=fra_time_start + fra_ms, y2=fra_h, xloc=xloc.bar_time, color=fra_line_color, width=1)
        line.new(x1=fra_time_start, y1=fra_m, x2=fra_time_start + fra_ms, y2=fra_m, xloc=xloc.bar_time, color=fra_line_color, width=1, style=line.style_dashed)
        line.new(x1=fra_time_start, y1=fra_l, x2=fra_time_start + fra_ms, y2=fra_l, xloc=xloc.bar_time, color=fra_line_color, width=1)
        if fra_session_active[1] == 1
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))

if lon_session_active == 1
    string lon_txt = lon_label ? lon_name : ""
    box.new(left=lon_time_start, bottom=lon_l, top=lon_h,
         right        = lon_time_start + lon_ms,
         xloc         = xloc.bar_time,
         bgcolor      = lon_color,
         border_color = lon_line_color,
         border_width = 1,
         text         = lon_txt,
         text_color   = lon_line_color,
         text_size    = size.small,
         text_valign  = text.align_top,
         text_halign  = text.align_center)
    if lon_session_active[1] == 1
        box.delete(box.all.get(box.all.size() - 2))
    if lon_show_lines
        float lon_m = (lon_h + lon_l) / 2
        line.new(x1=lon_time_start, y1=lon_h, x2=lon_time_start + lon_ms, y2=lon_h, xloc=xloc.bar_time, color=lon_line_color, width=1)
        line.new(x1=lon_time_start, y1=lon_m, x2=lon_time_start + lon_ms, y2=lon_m, xloc=xloc.bar_time, color=lon_line_color, width=1, style=line.style_dashed)
        line.new(x1=lon_time_start, y1=lon_l, x2=lon_time_start + lon_ms, y2=lon_l, xloc=xloc.bar_time, color=lon_line_color, width=1)
        if lon_session_active[1] == 1
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))

if nyt_session_active == 1
    string nyt_txt = nyt_label ? nyt_name : ""
    box.new(left=nyt_time_start, bottom=nyt_l, top=nyt_h,
         right        = nyt_time_start + nyt_ms,
         xloc         = xloc.bar_time,
         bgcolor      = nyt_color,
         border_color = nyt_line_color,
         border_width = 1,
         text         = nyt_txt,
         text_color   = nyt_line_color,
         text_size    = size.small,
         text_valign  = text.align_top,
         text_halign  = text.align_center)
    if nyt_session_active[1] == 1
        box.delete(box.all.get(box.all.size() - 2))
    if nyt_show_lines
        float nyt_m = (nyt_h + nyt_l) / 2
        line.new(x1=nyt_time_start, y1=nyt_h, x2=nyt_time_start + nyt_ms, y2=nyt_h, xloc=xloc.bar_time, color=nyt_line_color, width=1)
        line.new(x1=nyt_time_start, y1=nyt_m, x2=nyt_time_start + nyt_ms, y2=nyt_m, xloc=xloc.bar_time, color=nyt_line_color, width=1, style=line.style_dashed)
        line.new(x1=nyt_time_start, y1=nyt_l, x2=nyt_time_start + nyt_ms, y2=nyt_l, xloc=xloc.bar_time, color=nyt_line_color, width=1)
        if nyt_session_active[1] == 1
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))
            line.delete(line.all.get(line.all.size() - 4))

// ----------- Yesterday / Weekly Levels ------------
i_displayLast  = input(false, 'Display on current only')

yesterdayHigh  = request.security(syminfo.tickerid, 'D', high[1],  lookahead=barmerge.lookahead_on)
yesterdayLow   = request.security(syminfo.tickerid, 'D', low[1],   lookahead=barmerge.lookahead_on)
yesterdayClose = request.security(syminfo.tickerid, 'D', close[1], lookahead=barmerge.lookahead_on)
weeklyHigh     = request.security(syminfo.tickerid, 'W', high[1],  lookahead=barmerge.lookahead_on)
weeklyLow      = request.security(syminfo.tickerid, 'W', low[1],   lookahead=barmerge.lookahead_on)
isLastBar      = request.security(syminfo.tickerid, '', barstate.islast, lookahead=barmerge.lookahead_on)

plotCondition(_price) =>
    i_displayLast ? isLastBar ? _price : na : _price

plot(plotCondition(weeklyHigh),     'Weekly high',       color.new(color.green, 0), style=plot.style_circles, display=display.none)
plot(plotCondition(weeklyLow),      'Weekly low',        color.new(color.red, 0),   style=plot.style_circles, display=display.none)
plot(plotCondition(yesterdayHigh),  'Yesterday\'s high', color.rgb(48, 193, 236),   style=plot.style_circles, display=display.none)
plot(plotCondition(yesterdayLow),   'Yesterday\'s low',  color.rgb(48, 193, 236),   style=plot.style_circles, display=display.none)
plot(plotCondition(yesterdayClose), 'Day Open',          color.new(color.gray, 0),  style=plot.style_cross)

// ----------- Watermarks ------------
textWatermark = table.new(textVPosition + "_" + textHPosition, 1, 3)
if titelCheck == true
    table.cell(textWatermark, 0, 0, title,    width, height, c_title,    a_title,    text_size=s_title,    bgcolor=c_bg)
    table.cell(textWatermark, 0, 1, subtitle, width, height, c_subtitle, a_subtitle, text_size=s_subtitle, bgcolor=c_bg)

symWatermark = table.new(symVPosition + "_" + symHPosition, 5, 5)
if symInfoCheck == true
    table.cell(symWatermark, 0, 1, symInfo, width, height, c_symInfo, a_symInfo, text_size=s_symInfo, bgcolor=c_bg)
    table.cell(symWatermark, 0, 0, date,    width, height, c_symInfo, a_symInfo, text_size=s_symInfo, bgcolor=c_bg)
````

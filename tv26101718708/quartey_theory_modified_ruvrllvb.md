# Quartey theory (Modified)

- url: https://www.tradingview.com/script/rUvrLlVB-Quartey-theory-Modified/
- type: indicator
- pine_id: PUB;2e98ffffa713414ba399ab33323ec128
- version: 1.0

## Description

helps with trading and shi will make you rich ahh fu downlod this now and you will be billionair

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cashmeine

//@version=6
indicator("Quartey theory (Modified)", overlay=true)
// --- General Script Settings ---
// Check if the current bar is part of the current calendar day
bool isToday = year(time) == year(timenow) and month(time) == month(timenow) and dayofmonth(time) == dayofmonth(timenow)
// Restrict to 1m, 5m, 15m charts only
show_tf = timeframe.isminutes and (timeframe.multiplier == 1 or timeframe.multiplier == 5 or timeframe.multiplier == 15)
// --- Timezone and Session Setup ---
ny_session = "America/New_York"
ny_hour = hour(time, ny_session)
ny_minute = minute(time, ny_session)
ny_minutes = ny_hour * 60 + ny_minute
// Define target times in minutes since midnight (NY time) for vertical lines
is_target = (ny_minutes == 360   // 6:00 AM NY
          or ny_minutes == 450   // 7:30 AM NY
          or ny_minutes == 540   // 9:00 AM NY
          or ny_minutes == 630   // 10:30 AM NY
          or ny_minutes == 0)    // 12:00 AM NY midnight
    // Draw full-height dashed vertical line at target times (NY time)
if show_tf and is_target
    line.new(bar_index, close, bar_index, close + 1, color=color.white, style=line.style_dashed, width=1, extend=extend.both)
    // --- London Session logic (12:00 AM to 6:00 AM New York time) ---
london_session_start_min = 0 * 60 // 12:00 AM NY
london_session_end_min = 6 * 60 // 6:00 AM NY
in_london_session = ny_minutes >= london_session_start_min and ny_minutes < london_session_end_min
// Persistent variables for London session
var float londonHigh = na
var float londonLow = na
var int londonHighBarIndex = na
var int londonLowBarIndex = na
var line londonHighLine = na
var line londonLowLine = na
var int londonDay = na
// --- London Day ID and Reset Logic ---
ny_year  = year(time, ny_session)
ny_month = month(time, ny_session)
ny_day   = dayofmonth(time, ny_session)
ny_day_id = ny_year * 10000 + ny_month * 100 + ny_day
if ny_minutes == london_session_start_min and (na(londonDay) or londonDay != ny_day_id)
    londonHigh := high
    londonHighBarIndex := bar_index
    londonLow := low
    londonLowBarIndex := bar_index
    londonDay := ny_day_id
    if line.all.size() > 0
        for i = 0 to line.all.size() - 1
            line.delete(array.get(line.all, i))
            // Update high/low and their bar indices during the London session
if in_london_session
    if high > londonHigh or na(londonHigh)
        londonHigh := high
        londonHighBarIndex := bar_index
    if low < londonLow or na(londonLow)
        londonLow := low
        londonLowBarIndex := bar_index
        // Draw horizontal rays at London session end (6:00 AM NY)
if ny_minutes == london_session_end_min
    if not na(londonHigh) and not na(londonLow)
        londonHighLine := line.new(londonHighBarIndex, londonHigh, bar_index, londonHigh, extend=extend.right, color=color.green, width=1)
        londonLowLine := line.new(londonLowBarIndex, londonLow, bar_index, londonLow, extend=extend.right, color=color.red, width=1)
// --- 6:00 AM - 7:30 AM NY Session Logic ---
session_start_min = 360  // 6:00 AM NY
session_end_min = 450    // 7:30 AM NY
in_target_session = ny_minutes >= session_start_min and ny_minutes < session_end_min
var float targetHigh = na
var float targetLow = na
var int targetHighBarIndex = na
var int targetLowBarIndex = na
var line targetHighLine = na
var line targetLowLine = na
var int targetSessionDay = na
var bool highBreached = false
var bool lowBreached = false
if ny_minutes == session_start_min and (na(targetSessionDay) or targetSessionDay != ny_day_id)
    targetHigh := high
    targetHighBarIndex := bar_index
    targetLow := low
    targetLowBarIndex := bar_index
    targetSessionDay := ny_day_id
    highBreached := false
    lowBreached := false
    if not na(targetHighLine)
        line.delete(targetHighLine)
    if not na(targetLowLine)
        line.delete(targetLowLine)
    targetHighLine := na
    targetLowLine := na
if in_target_session
    if high > targetHigh or na(targetHigh)
        targetHigh := high
        targetHighBarIndex := bar_index
    if low < targetLow or na(targetLow)
        targetLow := low
        targetLowBarIndex := bar_index
if ny_minutes >= session_end_min and na(targetHighLine) and not na(targetHigh)
    targetHighLine := line.new(targetHighBarIndex, targetHigh, bar_index, targetHigh, color=color.black, width=1, extend=extend.none)
    targetLowLine := line.new(targetLowBarIndex, targetLow, bar_index, targetLow, color=color.black, width=1, extend=extend.none)
// --- Logic to extend black rays to the candle that takes out the high or low ---
// This ensures the line continues to extend as long as there is no breakout
if not na(targetHighLine) and ny_minutes >= session_end_min and not highBreached
    if high > targetHigh
        line.set_x2(targetHighLine, bar_index)
        highBreached := true
    else
        line.set_x2(targetHighLine, bar_index)
if not na(targetLowLine) and ny_minutes >= session_end_min and not lowBreached
    if low < targetLow
        line.set_x2(targetLowLine, bar_index)
        lowBreached := true
    else
        line.set_x2(targetLowLine, bar_index)
        // --- 7:30 AM - 9:00 AM NY Session Logic ---
session2_start_min = 450   // 7:30 AM NY
session2_end_min   = 540   // 9:00 AM NY
in_session2        = ny_minutes >= session2_start_min and ny_minutes < session2_end_min
// Persistent variables
var float session2High = na
var float session2Low  = na
var int   session2HighBarIndex = na
var int   session2LowBarIndex  = na
var line  session2HighLine = na
var line  session2LowLine  = na
var int   session2Day = na
var bool  session2HighBreached = false
var bool  session2LowBreached  = false
// Reset at session start
if ny_minutes == session2_start_min and (na(session2Day) or session2Day != ny_day_id)
    session2High := high
    session2Low  := low
    session2HighBarIndex := bar_index
    session2LowBarIndex  := bar_index
    session2Day := ny_day_id
    session2HighBreached := false
    session2LowBreached  := false
    if not na(session2HighLine)
        line.delete(session2HighLine)
    if not na(session2LowLine)
        line.delete(session2LowLine)
    session2HighLine := na
    session2LowLine  := na
// Track highs/lows during session
if in_session2
    if na(session2High) or high > session2High
        session2High := high
        session2HighBarIndex := bar_index
    if na(session2Low) or low < session2Low
        session2Low := low
        session2LowBarIndex := bar_index
// At session end (9:00 AM), draw horizontal rays from exact candle
if ny_minutes >= session2_end_min and na(session2HighLine) and not na(session2High)
    session2HighLine := line.new(session2HighBarIndex, session2High, bar_index, session2High,color=color.orange, width=1, extend=extend.none)
    session2LowLine := line.new(session2LowBarIndex, session2Low, bar_index, session2Low,color=color.orange, width=1, extend=extend.none)
// --- Extend rays until breakout after 9:00 AM ---
if not na(session2HighLine) and ny_minutes >= session2_end_min and not session2HighBreached
    if high > session2High
        line.set_x2(session2HighLine, bar_index)
        session2HighBreached := true
    else
        line.set_x2(session2HighLine, bar_index)

if not na(session2LowLine) and ny_minutes >= session2_end_min and not session2LowBreached
    if low < session2Low
        line.set_x2(session2LowLine, bar_index)
        session2LowBreached := true
    else
        line.set_x2(session2LowLine, bar_index)
````

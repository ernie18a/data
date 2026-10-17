# Vertical Lines (Alerts)

- url: https://www.tradingview.com/script/i2wPr7az-Vertical-Lines-Alerts/
- type: indicator
- pine_id: PUB;d6f22adb3def46d7a07474998dd7181a
- version: 1.0

## Description

NY Session Vertical Lines plots 4 customizable vertical lines with alerts on your chart using New York time. Set your preferred start and end times in the settings, then easily customize each line’s color, width, and style.

Perfect for marking key market sessions such as pre-market, New York open, cash session ranges, news windows, or any important time-based levels. Built specifically for traders who want clean visual session markers without clutter.

Features:
• Uses fixed New York time (handles DST automatically)  
• Separate start and end line colors  
• Adjustable line width and style  
• Clean and lightweight design  
• Works on all timeframes

Ideal for futures, indices, forex, and stocks traders who track New York session activity.

## Source Code

````pine
//@version=5
indicator("Vertical Lines ", overlay=true, max_lines_count=500)

// ===== Inputs =====
timeFormat = input.string("24H", "Time Format", options=["24H", "12H"])

time1 = input.string("07:30", "Line 1 Time")
time2 = input.string("09:30", "Line 2 Time")
time3 = input.string("12:00", "Line 3 Time")
time4 = input.string("15:30", "Line 4 Time")

show1 = input.bool(true, "Show Line 1")
show2 = input.bool(true, "Show Line 2")
show3 = input.bool(true, "Show Line 3")
show4 = input.bool(true, "Show Line 4")

color1 = input.color(color.green, "Line 1 Color")
color2 = input.color(color.red, "Line 2 Color")
color3 = input.color(color.blue, "Line 3 Color")
color4 = input.color(color.orange, "Line 4 Color")

lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
lineStyle = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])

tz = "America/New_York"

// ===== Line Style =====
style = line.style_solid
if lineStyle == "Dashed"
    style := line.style_dashed
if lineStyle == "Dotted"
    style := line.style_dotted

// ===== Functions =====
getMinute(txt) =>
    int(str.tonumber(str.substring(txt, 3, 5)))

getHour(txt) =>
    h = int(str.tonumber(str.substring(txt, 0, 2)))
    timeFormat == "24H" ? h : h % 12

// ===== Current NY Time =====
h = hour(time, tz)
m = minute(time, tz)

// ===== Conditions =====
// For 12H mode:
// 01:00 to 11:59 = AM
// 12:00 to 12:59 = Noon
// 13:00 to 23:59 enter as 01:00 to 11:59 PM equivalent automatically
adjH = timeFormat == "24H" ? h : h % 12

hit1 = show1 and adjH == getHour(time1) and m == getMinute(time1)
hit2 = show2 and adjH == getHour(time2) and m == getMinute(time2)
hit3 = show3 and adjH == getHour(time3) and m == getMinute(time3)
hit4 = show4 and adjH == getHour(time4) and m == getMinute(time4)

// ===== Draw Lines =====
if hit1
    line.new(bar_index, 0, bar_index, 999999, extend=extend.both, color=color1, width=lineWidth, style=style)

if hit2
    line.new(bar_index, 0, bar_index, 999999, extend=extend.both, color=color2, width=lineWidth, style=style)

if hit3
    line.new(bar_index, 0, bar_index, 999999, extend=extend.both, color=color3, width=lineWidth, style=style)

if hit4
    line.new(bar_index, 0, bar_index, 999999, extend=extend.both, color=color4, width=lineWidth, style=style)

// ===== Alerts =====
alertcondition(hit1, "Line 1 Alert", "Line 1 Triggered")
alertcondition(hit2, "Line 2 Alert", "Line 2 Triggered")
alertcondition(hit3, "Line 3 Alert", "Line 3 Triggered")
alertcondition(hit4, "Line 4 Alert", "Line 4 Triggered")
````

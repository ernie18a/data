# Session Vertical Lines by XAUUSDGODD

- url: https://www.tradingview.com/script/zOLN6WYO-Session-Vertical-Lines-by-XAUUSDGODD/
- type: indicator
- pine_id: PUB;1eae8e7a6a2842909cc989ec2b920937
- version: 2.0

## Description

This script marks the start of each major trading session on the chart by drawing vertical lines for the Asia, London, and New York sessions.

It allows the user to set the session start times based on their local time zone, then automatically converts those times to UTC internally so the lines appear at the correct moments on the chart.

Each session line can be customized with its own color, and the user can also adjust the line style and thickness. This makes it easier to visually identify when each market session begins and analyze price behavior around those session opens.

[image]https://www.tradingview.com/x/Z2zPY8aI/[/image]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © missiego_andres

//@version=6
// max_lines_count=500 -> evita que Pine borre las líneas antiguas (por defecto solo guarda ~50).
indicator("Session Vertical Lines", overlay = true, max_lines_count = 500)

// --- INTERNAL TIME ZONE SETTINGS ---
var string g_timezone = "Time Zone Settings"
utc_input = input.int(2, title = "Your Time Zone (Example: 2 for UTC+2, -5 for UTC-5)", minval = -12, maxval = 14, group = g_timezone)

// --- SESSION START TIMES SETTINGS ---
var string g_times = "Session Start Times"
asia_h   = input.int(2,  title = "Asia - Hour",     minval = 0, maxval = 23, group = g_times)
asia_m   = input.int(0,  title = "Asia - Minute",   minval = 0, maxval = 59, group = g_times)
london_h = input.int(9,  title = "London - Hour",   minval = 0, maxval = 23, group = g_times)
london_m = input.int(0,  title = "London - Minute", minval = 0, maxval = 59, group = g_times)
ny_h     = input.int(14, title = "New York - Hour", minval = 0, maxval = 23, group = g_times)
ny_m     = input.int(0,  title = "New York - Minute", minval = 0, maxval = 59, group = g_times)

// --- VISUAL STYLE SETTINGS ---
var string g_style = "Visual Style"
color_asia   = input.color(color.new(#000000, 0), title = "Asia Color",     group = g_style)
color_london = input.color(color.new(#000000, 0), title = "London Color",   group = g_style)
color_ny     = input.color(color.new(#000000, 0), title = "New York Color", group = g_style)
line_style   = input.string("Dashed", title = "Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_style)
line_width   = input.int(1, title = "Line Width", minval = 1, maxval = 5, group = g_style)

// --- LOCAL SESSION TIME -> UTC ---
convert_to_utc(local_hour, local_minute, utc_offset) =>
    int h = local_hour - utc_offset
    if h < 0
        h := h + 24
    if h >= 24
        h := h - 24
    [h, local_minute]

[asia_utc_h,   asia_utc_m]   = convert_to_utc(asia_h,   asia_m,   utc_input)
[london_utc_h, london_utc_m] = convert_to_utc(london_h, london_m, utc_input)
[ny_utc_h,     ny_utc_m]     = convert_to_utc(ny_h,     ny_m,     utc_input)

// --- LINE STYLE ---
get_line_style(style_name) =>
    switch style_name
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_dashed
current_style = get_line_style(line_style)

// --- HELPERS ---
// Minutos desde medianoche UTC de la vela / identificador único de día UTC.
minute_of_day(int t) => hour(t, "UTC") * 60 + minute(t, "UTC")
day_id(int t)        => year(t, "UTC") * 10000 + month(t, "UTC") * 100 + dayofmonth(t, "UTC")

// --- DETECCIÓN: primera vela del día que alcanza la hora de sesión ---
// Agnóstico al TF, sin el bug de medianoche y aguanta gaps (dibuja en la 1ª vela tras el hueco).
var int last_asia   = na
var int last_london = na
var int last_ny     = na

is_asia_time   = false
is_london_time = false
is_ny_time     = false

if minute_of_day(time) >= asia_utc_h * 60 + asia_utc_m and (na(last_asia) or last_asia != day_id(time))
    is_asia_time := true
    last_asia    := day_id(time)

if minute_of_day(time) >= london_utc_h * 60 + london_utc_m and (na(last_london) or last_london != day_id(time))
    is_london_time := true
    last_london    := day_id(time)

if minute_of_day(time) >= ny_utc_h * 60 + ny_utc_m and (na(last_ny) or last_ny != day_id(time))
    is_ny_time := true
    last_ny    := day_id(time)

// --- DIBUJO ---
// Sin barstate.isnew: en tiempo real el rollback recrea la misma línea en cada tick,
// así no desaparece en modo replay.
draw_vertical_line(condition, line_color) =>
    if condition
        line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, xloc = xloc.bar_index, extend = extend.both, color = line_color, style = current_style, width = line_width)

draw_vertical_line(is_asia_time,   color_asia)
draw_vertical_line(is_london_time, color_london)
draw_vertical_line(is_ny_time,     color_ny)
````

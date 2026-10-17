# Custom Session Boundaries with Timezone Support

- url: https://www.tradingview.com/script/6lf1QbR4-Custom-Session-Boundaries-with-Timezone-Support/
- type: indicator
- pine_id: PUB;0651f1fac7c14e4aa94c21717cd1213c
- version: 3.0

## Description

This indicator draws two clean vertical lines on your chart — one marking the start of your selected trading session and one marking the end. No clutter, no extra lines between them. Just the two boundaries you care about.
It is designed for traders who want a clear visual reference of their session window directly on the chart, regardless of the timezone their broker or exchange uses.
Features:

Select your Start Hour and End Hour independently (0–23 format)
Full timezone support: UTC, New York, Chicago, London, Berlin, Bucharest, Tokyo, Singapore, Sydney
Separate color control for the start and end line
Choose between Solid, Dashed, or Dotted line style
Adjustable line width (1–4)
Works on all timeframes and all instruments

How to use:
Set your desired session start and end hour in the timezone that matches your setup. The indicator will place one vertical line at the opening of the start hour and one at the opening of the end hour, across your entire chart history.
Works well for marking sessions such as London Open, New York Open, Asian Session, or any custom time window relevant to your strategy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © TheFocusedEdge

//@version=6
indicator("Session Separators", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
timezone_input = input.string(title="Timezone",
     defval="UTC",
     options=["UTC", "America/New_York", "America/Chicago", "Europe/London",
              "Europe/Berlin", "Europe/Bucharest", "Asia/Tokyo", "Asia/Singapore",
              "Australia/Sydney"])

start_hour   = input.int(title="Start Hour (0–23)",      defval=7,  minval=0, maxval=23)
start_minute = input.int(title="Start Minute (0 or 30)", defval=0,  minval=0, maxval=30, step=30)
end_hour     = input.int(title="End Hour (0–23)",        defval=12, minval=0, maxval=23)
end_minute   = input.int(title="End Minute (0 or 30)",   defval=0,  minval=0, maxval=30, step=30)

start_color = input.color(title="Start Line Color", defval=color.new(color.green, 50))
end_color   = input.color(title="End Line Color",   defval=color.new(color.red,   50))
line_width  = input.int(title="Line Width", defval=1, minval=1, maxval=4)
line_style_input = input.string(title="Line Style",
     defval="Dashed",
     options=["Solid", "Dashed", "Dotted"])

// ─── RESOLVE STYLE ────────────────────────────────────────────────────────────
resolved_style = line_style_input == "Dotted" ? line.style_dotted :
                 line_style_input == "Dashed"  ? line.style_dashed  :
                 line.style_solid

// ─── LOGIC ────────────────────────────────────────────────────────────────────
// Current and previous bar time in total minutes since midnight
cur_mins  = hour(time,    timezone_input) * 60 + minute(time,    timezone_input)
prev_mins = hour(time[1], timezone_input) * 60 + minute(time[1], timezone_input)

target_start = start_hour * 60 + start_minute
target_end   = end_hour   * 60 + end_minute

// Draw on the bar whose open is the first one >= target (prev bar was still before target)
cross_start = prev_mins < target_start and cur_mins >= target_start
cross_end   = prev_mins < target_end   and cur_mins >= target_end

// ─── DRAW ─────────────────────────────────────────────────────────────────────
if cross_start
    line.new(x1=bar_index, y1=low, x2=bar_index, y2=high,
         xloc=xloc.bar_index, extend=extend.both,
         color=start_color, style=resolved_style, width=line_width)

if cross_end
    line.new(x1=bar_index, y1=low, x2=bar_index, y2=high,
         xloc=xloc.bar_index, extend=extend.both,
         color=end_color, style=resolved_style, width=line_width)
````

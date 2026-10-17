# Availability Hours

- url: https://www.tradingview.com/script/h19cCqYm-Availability-Hours/
- type: indicator
- pine_id: PUB;38ff467683ac43a995b1f3ea453d8dc0
- version: 1.0

## Description

Draws two vertical lines on the chart to mark a custom daily trading session window.
A green line marks the session open and a red line marks the session close. Both times are fully customizable through the indicator settings using 24-hour format, allowing any trader to define their own available trading hours.
Automatically adjusts between Pacific Daylight Time (UTC-7) from March to November and Pacific Standard Time (UTC-8) from November to March, ensuring the lines always land at the correct local time year-round without any manual input.
Designed for traders who backtest within specific daily time windows and want a clear visual boundary to identify which candles fall inside or outside their chosen trading hours. Helpful for maintaining consistency when journaling trades and reviewing whether entries respected a defined session schedule.

## Source Code

````pine
//@version=6
indicator("Availability Hours", overlay=true)

// ─────────────────────────────────────────
// AUTO-DETECT PDT (UTC-7) vs PST (UTC-8)
// ─────────────────────────────────────────
isDST(t) =>
    m  = month(t, "UTC+0")
    d  = dayofmonth(t, "UTC+0")
    dw = dayofweek(t, "UTC+0")
    if m > 3 and m < 11
        true
    else if m == 3
        d > 14 ? true : d >= 8 and dw == 1 and d <= 14 ? true : false
    else if m == 11
        d > 7 ? false : dw == 1 and d <= 7 ? false : true
    else
        false

utcOffset = isDST(time) ? -7 : -8
barTime   = time + utcOffset * 3600000

h        = hour(barTime, "UTC+0")
m        = minute(barTime, "UTC+0")
totalMin = h * 60 + m

ph      = hour(time[1] + utcOffset * 3600000, "UTC+0")
pm      = minute(time[1] + utcOffset * 3600000, "UTC+0")
prevMin = ph * 60 + pm

// ─────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────
open_hour  = input.int(6,  "Session Open Hour (24h)",  minval=0, maxval=23)
close_hour = input.int(23, "Session Close Hour (24h)", minval=0, maxval=23)
show_lines = input.bool(true, "Show Availability Lines")
col_open   = input.color(color.new(color.green, 20), "Open Line Color")
col_close  = input.color(color.new(color.red,   20), "Close Line Color")
lw         = input.int(1, "Line Width", minval=1, maxval=4)

// ─────────────────────────────────────────
// DETECT CROSSINGS
// ─────────────────────────────────────────
is_open  = show_lines and totalMin == open_hour  * 60 and prevMin != open_hour  * 60
is_close = show_lines and totalMin == close_hour * 60 and prevMin != close_hour * 60

// ─────────────────────────────────────────
// DRAW
// ─────────────────────────────────────────
if is_open
    line.new(bar_index, high, bar_index, low, extend=extend.both,
             color=col_open, width=lw, style=line.style_solid)

if is_close
    line.new(bar_index, high, bar_index, low, extend=extend.both,
             color=col_close, width=lw, style=line.style_solid)
````

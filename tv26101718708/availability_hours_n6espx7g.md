# Availability Hours

- url: https://www.tradingview.com/script/N6espx7g-Availability-Hours/
- type: indicator
- pine_id: PUB;4b64ad9e95b3489f9c1c787a1d9bbf5d
- version: 1.0

## Description

Draws two vertical lines daily to mark personal trading availability hours based on Vancouver time (Pacific Time).

A green line appears at 6:00 AM and a red line appears at 11:00 PM, indicating the start and end of available trading hours for the day.
Automatically adjusts for Pacific Daylight Time (UTC-7) from March to November and Pacific Standard Time (UTC-8) from November to March, so the lines always land at the correct local time year-round.

Useful for backtesting and trade journaling — any trade entry between the green and red lines falls within availability hours and is valid for review. Any trade outside these lines should be disregarded.

## Source Code

````pine
//@version=6
indicator("Availability Hours", overlay=true)

isDST(t) =>
    m = month(t, "UTC+0")
    d = dayofmonth(t, "UTC+0")
    dw = dayofweek(t, "UTC+0")
    if m > 3 and m < 11
        true
    else if m == 3
        d >= 8 and dw == 1 and d <= 14 ? true : d > 14 ? true : false
    else if m == 11
        d < 7 and dw != 1 ? true : d == 1 and dw == 1 ? false : d > 7 ? false : dw == 1 and d <= 7 ? false : true
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

show_lines = input.bool(true, "Show Availability Lines")
col_open   = input.color(color.new(color.green, 20), "6AM Line Color")
col_close  = input.color(color.new(color.red,   20), "11PM Line Color")
lw         = input.int(1, "Line Width", minval=1, maxval=4)

is_open  = show_lines and totalMin == 6  * 60 and prevMin != 6  * 60
is_close = show_lines and totalMin == 23 * 60 and prevMin != 23 * 60

if is_open
    line.new(bar_index, high, bar_index, low, extend=extend.both,
             color=col_open, width=lw, style=line.style_solid)

if is_close
    line.new(bar_index, high, bar_index, low, extend=extend.both,
             color=col_close, width=lw, style=line.style_solid)
````

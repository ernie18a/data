# Clock

- url: https://www.tradingview.com/script/suBe4kGp-Clock/
- type: indicator
- pine_id: PUB;dc0a09c842a142bd8bca84b60ab99987
- version: 1.0

## Description

A lightweight overlay indicator that displays a live clock on your chart, stamped to Eastern Time (America/New_York), automatically accounting for EST/EDT daylight saving transitions.

Display Options

Time Format — Shows the current time in 12-hour format with AM/PM. Optionally enable milliseconds for sub-second precision
Date Display — Toggle on a date line above the time


Appearance

Text Color — Fully customizable via color picker.
Background Color — Fully customizable via color picker.
Clock Size — Four size options: Tiny, Small, Normal, Large, Huge.


Positioning
Freely position the clock anywhere on the chart using independent Vertical (Top / Middle / Bottom) and Horizontal (Left / Center / Right) controls, giving you nine possible anchor points.

Update Behavior
The clock refreshes under three conditions — on the last bar, on any real-time tick, and on each new bar close. This means the clock remains active and updates continuously during live market hours, and still advances bar-by-bar during off-hours and weekends when no real-time feed is present.

## Source Code

````pine
//@version=6
// Created by © MattSmiggs
indicator("Clock ⌖", overlay=true)

pos_v      = input.string("bottom", "Vertical Position",   options=["top", "middle", "bottom"])
pos_h      = input.string("right",  "Horizontal Position", options=["left", "center", "right"])
t_size     = input.string("small",  "Clock Size",          options=["tiny", "small", "normal", "large", "huge"])
show_ms    = input.bool(false, "Show Milliseconds")
show_date  = input.bool(false, "Show Date")
txt_color  = input.color(color.white, "Text Color")
bg_color   = input.color(color.black, "Background Color")

var table clockTable = na

if barstate.islast or barstate.isrealtime or barstate.isnew
    if not na(clockTable)
        table.delete(clockTable)
    clockTable := table.new(pos_v + "_" + pos_h, 1, 1)
    string timeFormat = show_ms ? "hh:mm:ss.SSS a" : "hh:mm:ss a"
    string timeStr    = str.format_time(timenow, timeFormat, "America/New_York")
    string dateStr    = str.format_time(timenow, "MM-dd-yyyy", "America/New_York")
    string finalText  = show_date ? (dateStr + "\n" + timeStr) : timeStr
    table.cell(clockTable, 0, 0, finalText,
         text_color=txt_color,
         bgcolor=bg_color,
         text_size=t_size)
````

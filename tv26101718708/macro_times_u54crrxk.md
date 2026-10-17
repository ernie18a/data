# Macro Times

- url: https://www.tradingview.com/script/U54CRRXK-Macro-Times/
- type: indicator
- pine_id: PUB;7cfb4bbe8b7446a78d34ec78ee156d50
- version: 1.0

## Description

The only Macro time indicator for ICT concepts you need!!!

## Source Code

````pine
//@version=6
indicator("Macro Times", overlay = false, max_lines_count = 500, max_labels_count = 500)

col_line   = input.color(color.black, "Line Color",   group = "Style")
line_width = input.int(2, "Line Width", minval = 1, maxval = 4, group = "Style")
days_back  = input.int(3, "Days to show", minval = 1, maxval = 10, group = "Style")

TZ = "America/New_York"

macro_names = array.from(
    "0:50-1:10", "1:50-2:10", "2:50-3:10", "3:50-4:10",
    "4:50-5:10", "5:50-6:10", "6:50-7:10", "7:50-8:10",
    "8:50-9:10", "9:50-10:10", "10:50-11:10", "11:50-12:10",
    "12:50-13:10", "13:50-14:10", "14:50-15:10", "15:50-16:10",
    "16:50-17:10", "17:50-18:10", "18:50-19:10", "19:50-20:10",
    "20:50-21:10", "21:50-22:10", "22:50-23:10", "23:50-0:10")

plot(100, color = color.new(color.white, 100), display = display.none)
plot(0,   color = color.new(color.white, 100), display = display.none)

float LINE_Y = 8

var line[]  all_lines  = array.new<line>()
var label[] all_labels = array.new<label>()

if barstate.islast
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    array.clear(all_lines)
    array.clear(all_labels)

    for d = 0 to days_back - 1
        ref_time = time - d * 86400000
        dow      = dayofweek(ref_time, TZ)

        if dow >= 2 and dow <= 6
            for i = 0 to 23
                start_min = i * 60 + 50
                end_min   = start_min + 20
                t_start = timestamp(TZ,
                                    year(ref_time, TZ),
                                    month(ref_time, TZ),
                                    dayofmonth(ref_time, TZ),
                                    start_min / 60, start_min % 60, 0)
                t_end   = timestamp(TZ,
                                    year(ref_time, TZ),
                                    month(ref_time, TZ),
                                    dayofmonth(ref_time, TZ),
                                    end_min / 60, end_min % 60, 0)

                if t_start <= time
                    ln = line.new(t_start, LINE_Y, t_end, LINE_Y,
                                  xloc  = xloc.bar_time,
                                  color = col_line,
                                  width = line_width,
                                  style = line.style_solid)
                    array.push(all_lines, ln)

                    t_mid = int(t_start + (t_end - t_start) / 2)
                    lb = label.new(t_mid, LINE_Y + 2,
                                   array.get(macro_names, i),
                                   xloc      = xloc.bar_time,
                                   yloc      = yloc.price,
                                   color     = color.new(color.white, 100),
                                   textcolor = col_line,
                                   style     = label.style_none,
                                   size      = size.tiny)
                    array.push(all_labels, lb)
````

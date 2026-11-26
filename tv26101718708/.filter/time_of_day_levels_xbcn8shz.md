# Time of Day Levels

- url: https://www.tradingview.com/script/Xbcn8SHZ-Time-of-Day-Levels/
- type: indicator
- pine_id: PUB;6f39528d919f4d55808910b1e00a1bc0
- version: 1.0

## Description

This is an indicator to plot a level that corresponds to a particular time of day (hour and minute) and draw that level as a horizontal line, with text tag, as far through the rest of the day as desired.  It is common to plot midnight open and cash market open as levels, but this will give you the ability to plot for other times as well, useful for some trading strategies.

The historically difficult thing to do has been plotting for times that fall in the middle of a time bar, like if you wanted to plot the level for 9:53 on a 5 minute chart.  When the level does not correspond to beginning or end of a chart's bar, the code will look back up to 15 minutes into the middle of the bar to find the level.  So, it will work will for time bars up to 15 minutes, but may not show the level for larger time bars.

[i]Note:  This has not been tested for charts that don't use fixed time bars[/i]

For up to 10 time levels, you can specify the following:
[list]
[*][b]Hour:[/b]  An integer specifying the desired hour in 24 hour format
[*][b]Minute:[/b]  An integer specifying the desired minute in that hour
[*][b]Use Close:[/b]  If checked will spot the closing value of the specified 1 minute time, otherwise will show the opening value
[*][b]Tag Text:[/b]  Text to show to the right of the horizontal line plots for the time level
[*][b]Extend Minutes:[/b]  How long, in minutes, to extend the line from the specified time.  If set to 0 or 1440, the line will just always be updated to the current day
[*][b]Color - Style - Width: [/b] Specifies the style for the plotted horizontal line
[/list]
For the text tags, you can specify the following:
[list]
[*][b]Color:[/b]  The color for all text tags, unless choosing to use the individual line colors
[*][b]Size:[/b]  Size of text tags
[*][b]Offset:[/b]  The number of bars to the right of the plotted horizontal line before showing the text tag.  A value of 0 will place it right next to the horizontal line
[*][b]Use Line Color:[/b]  Instead of using the Text Tag Color, text tags will be drawn in the same color as the horizontal line
[*][b]Show Level:[/b]  When checked, the price level will be printed to the right of the text tag in parentheses
[/list]
In Other Settings, you can also force the times to be interpreted as Eastern Standard Time, accounting for daylight savings.  Otherwise, local chart time will be used

## Source Code

````pine
//@version=6
indicator("Time of Day Levels", shorttitle="TimeLevels", overlay=true, max_lines_count=500, max_labels_count=500)

group1 = "Level 1"
time1_enabled = input.bool(true, "Enable", group=group1)
time1_hour = input.int(9, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group1, inline="1")
time1_min = input.int(30, "", minval=0, maxval=59, group=group1, inline="1")
time1_use_close = input.bool(false, "", group=group1, inline="1")
time1_label = input.string("9:30 Open", "Tag Text - Extend Minutes", group=group1, inline="2")
time1_extend = input.int(450, "", minval=0, group=group1, inline="2")
time1_color = input.color(color.lime, "Color - Style - Width", group=group1, inline="3")
time1_style = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], group=group1, inline="3")
time1_width = input.int(2, "", minval=1, maxval=4, group=group1, inline="3")

group2 = "Level 2"
time2_enabled = input.bool(true, "Enable", group=group2)
time2_hour = input.int(9, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group2, inline="1")
time2_min = input.int(53, "", minval=0, maxval=59, group=group2, inline="1")
time2_use_close = input.bool(false, "", group=group2, inline="1")
time2_label = input.string("9:53", "Tag Text - Extend Minutes", group=group2, inline="2")
time2_extend = input.int(428, "", minval=0, group=group2, inline="2")
time2_color = input.color(color.yellow, "Color - Style - Width", group=group2, inline="3")
time2_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group2, inline="3")
time2_width = input.int(2, "", minval=1, maxval=4, group=group2, inline="3")

group3 = "Level 3"
time3_enabled = input.bool(true, "Enable", group=group3)
time3_hour = input.int(00, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group3, inline="1")
time3_min = input.int(00, "", minval=0, maxval=59, group=group3, inline="1")
time3_use_close = input.bool(false, "", group=group3, inline="1")
time3_label = input.string("TDO", "Tag Text - Extend Minutes", group=group3, inline="2")
time3_extend = input.int(1410, "", minval=0, group=group3, inline="2")
time3_color = input.color(color.green, "Color - Style - Width", group=group3, inline="3")
time3_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group3, inline="3")
time3_width = input.int(2, "", minval=1, maxval=4, group=group3, inline="3")

group4 = "Level 4"
time4_enabled = input.bool(true, "Enable", group=group4)
time4_hour = input.int(7, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group4, inline="1")
time4_min = input.int(30, "", minval=0, maxval=59, group=group4, inline="1")
time4_use_close = input.bool(false, "", group=group4, inline="1")
time4_label = input.string("NYO", "Tag Text - Extend Minutes", group=group4, inline="2")
time4_extend = input.int(570, "", minval=0, group=group4, inline="2")
time4_color = input.color(color.white, "Color - Style - Width", group=group4, inline="3")
time4_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group4, inline="3")
time4_width = input.int(2, "", minval=1, maxval=4, group=group4, inline="3")

group5 = "Level 5"
time5_enabled = input.bool(true, "Enable", group=group5)
time5_hour = input.int(13, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group5, inline="1")
time5_min = input.int(30, "", minval=0, maxval=59, group=group5, inline="1")
time5_use_close = input.bool(false, "", group=group5, inline="1")
time5_label = input.string("PMO", "Tag Text - Extend Minutes", group=group5, inline="2")
time5_extend = input.int(210, "", minval=0, group=group5, inline="2")
time5_color = input.color(color.red, "Color - Style - Width", group=group5, inline="3")
time5_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group5, inline="3")
time5_width = input.int(2, "", minval=1, maxval=4, group=group5, inline="3")

group6 = "Level 6"
time6_enabled = input.bool(false, "Enable", group=group6)
time6_hour = input.int(0, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group6, inline="1")
time6_min = input.int(0, "", minval=0, maxval=59, group=group6, inline="1")
time6_use_close = input.bool(false, "", group=group6, inline="1")
time6_label = input.string("TBD", "Tag Text - Extend Minutes", group=group6, inline="2")
time6_extend = input.int(1410, "", minval=0, group=group6, inline="2")
time6_color = input.color(color.white, "Color - Style - Width", group=group6, inline="3")
time6_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group6, inline="3")
time6_width = input.int(2, "", minval=1, maxval=4, group=group6, inline="3")

group7 = "Level 7"
time7_enabled = input.bool(false, "Enable", group=group7)
time7_hour = input.int(0, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group7, inline="1")
time7_min = input.int(0, "", minval=0, maxval=59, group=group7, inline="1")
time7_use_close = input.bool(false, "", group=group7, inline="1")
time7_label = input.string("TBD", "Tag Text - Extend Minutes", group=group7, inline="2")
time7_extend = input.int(1410, "", minval=0, group=group7, inline="2")
time7_color = input.color(color.white, "Color - Style - Width", group=group7, inline="3")
time7_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group7, inline="3")
time7_width = input.int(2, "", minval=1, maxval=4, group=group7, inline="3")

group8 = "Level 8"
time8_enabled = input.bool(false, "Enable", group=group8)
time8_hour = input.int(0, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group8, inline="1")
time8_min = input.int(0, "", minval=0, maxval=59, group=group8, inline="1")
time8_use_close = input.bool(false, "", group=group8, inline="1")
time8_label = input.string("TBD", "Tag Text - Extend Minutes", group=group8, inline="2")
time8_extend = input.int(1410, "", minval=0, group=group8, inline="2")
time8_color = input.color(color.white, "Color - Style - Width", group=group8, inline="3")
time8_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group8, inline="3")
time8_width = input.int(2, "", minval=1, maxval=4, group=group8, inline="3")

group9 = "Level 9"
time9_enabled = input.bool(false, "Enable", group=group9)
time9_hour = input.int(0, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group9, inline="1")
time9_min = input.int(0, "", minval=0, maxval=59, group=group9, inline="1")
time9_use_close = input.bool(false, "", group=group9, inline="1")
time9_label = input.string("TBD", "Tag Text - Extend Minutes", group=group9, inline="2")
time9_extend = input.int(1410, "", minval=0, group=group9, inline="2")
time9_color = input.color(color.white, "Color - Style - Width", group=group9, inline="3")
time9_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group9, inline="3")
time9_width = input.int(2, "", minval=1, maxval=4, group=group9, inline="3")

group10 = "Level 10"
time10_enabled = input.bool(false, "Enable", group=group10)
time10_hour = input.int(0, "Hour (24h) - Minute - Use Close", minval=0, maxval=23, group=group10, inline="1")
time10_min = input.int(0, "", minval=0, maxval=59, group=group10, inline="1")
time10_use_close = input.bool(false, "", group=group10, inline="1")
time10_label = input.string("TBD", "Tag Text - Extend Minutes", group=group10, inline="2")
time10_extend = input.int(1410, "", minval=0, group=group10, inline="2")
time10_color = input.color(color.white, "Color - Style - Width", group=group10, inline="3")
time10_style = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=group10, inline="3")
time10_width = input.int(2, "", minval=1, maxval=4, group=group10, inline="3")

groupTags = "Tags"
tagColor = input.color(color.white, group = groupTags, inline = "tagstyle", title = "Color - Size - Offset")
tagSize = input.string('Normal', group = groupTags, inline = "tagstyle", title = "", options = ['Normal','Large', 'Small', 'Tiny', 'Auto' ])
tagOffset = input.int(1, group = groupTags, inline = "tagstyle", title = "")
tagLineColor = input.bool(true, group = groupTags, title = "Use LIne Color")
tagLevel = input.bool(true, group = groupTags, title = "Show Level")

groupOther = "Other Settings"
use_est = input.bool(true, "Use Eastern Standard Time", group=groupOther, tooltip="When enabled, all time-of-day comparisons use EST/EDT regardless of chart timezone")

var string tz = use_est ? "America/New_York" : syminfo.timezone
var line time1_line = na
var line time2_line = na
var line time3_line = na
var line time4_line = na
var line time5_line = na
var line time6_line = na
var line time7_line = na
var line time8_line = na
var line time9_line = na
var line time10_line = na
var label time1_tag = na
var label time2_tag = na
var label time3_tag = na
var label time4_tag = na
var label time5_tag = na
var label time6_tag = na
var label time7_tag = na
var label time8_tag = na
var label time9_tag = na
var label time10_tag = na
var int time1_end = na
var int time2_end = na
var int time3_end = na
var int time4_end = na
var int time5_end = na
var int time6_end = na
var int time7_end = na
var int time8_end = na
var int time9_end = na
var int time10_end = na

lineStyle(x) =>
    switch x
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted

textSize(x) =>
    switch x
        'Normal'  => size.normal
        'Small'   => size.small
        'Tiny'    => size.tiny
        'Auto'    => size.auto
        'Large'   => size.large

check_time(int t_hour, int t_min, bool use_close) =>
    int t_open = time
    int t_close = time_close
    int t_check = timestamp(tz, year(t_open, tz), month(t_open, tz), dayofmonth(t_open, tz), t_hour, t_min, 0)

    if use_close
        t_check := t_check + 60000

    if t_check < t_open
        t_check := t_check + 86400000

    if t_check >= t_close
        t_check := na
    
    t_check

get_time_level(int t_check, bool use_close) =>
    float t_level = na

    if not na(t_check)
        if t_check == time and not use_close
            t_level := open
        else if t_check == time and use_close
            t_level := close[1]
        else
            int t_curr = request.security(syminfo.tickerid, "1", time)

            if t_curr >= t_check
                int bar = (t_curr - t_check) / 60000
                [open0, open1, open2, open3, open4, open5, open6, open7, open8, open9, open10, open11, open12, open13, open14, close1, close2, close3, close4, close5, close6, close7, close8, close9, close10, close11, close12, close13, close14, close15] = request.security(syminfo.tickerid, "1", [open[0], open[1], open[2], open[3], open[4], open[5], open[6], open[7], open[8], open[9], open[10], open[11], open[12], open[13], open[14], close[1], close[2], close[3], close[4], close[5], close[6], close[7], close[8], close[9], close[10], close[11], close[12], close[13], close[14], close[15]])
                
                if bar == 0
                    t_level := use_close ? close1 : open0
                else if bar == 1
                    t_level := use_close ? close2 : open1
                else if bar == 2
                    t_level := use_close ? close3 : open2
                else if bar == 3
                    t_level := use_close ? close4 : open3
                else if bar == 4
                    t_level := use_close ? close5 : open4
                else if bar == 5
                    t_level := use_close ? close6 : open5
                else if bar == 6
                    t_level := use_close ? close7 : open6
                else if bar == 7
                    t_level := use_close ? close8 : open7
                else if bar == 8
                    t_level := use_close ? close9 : open8
                else if bar == 9
                    t_level := use_close ? close10 : open9
                else if bar == 10
                    t_level := use_close ? close11 : open10
                else if bar == 11
                    t_level := use_close ? close12 : open11
                else if bar == 12
                    t_level := use_close ? close13 : open12
                else if bar == 13
                    t_level := use_close ? close14 : open13
                else if bar == 14
                    t_level := use_close ? close15 : open14

    t_level

check_time_level(int t_hour, int t_min, bool use_close, string tag, color clr, string sty, int wid, int extend, line t_line, label t_tag, int t_end) =>
    int t_check = check_time(t_hour, t_min, use_close)
    float t_level = get_time_level(t_check, use_close)
    line o_line = t_line
    label o_tag = t_tag
    int o_end = t_end

    if not na(t_level)

        if na(o_line)
            o_line := line.new(bar_index, t_level, bar_index + 1, t_level, color = clr, width = wid, style = lineStyle(sty))
        else
            line.set_xy1(o_line, bar_index, t_level)
            line.set_xy2(o_line, bar_index + 1, t_level)

        if na(o_tag)
            o_tag := label.new(bar_index + tagOffset, t_level, text = tagLevel ? tag + " (" + str.tostring(t_level) + ")" : tag, style = label.style_label_left, color = color.new(color.black, 100), textcolor = tagLineColor ? color.new(clr, 0) : tagColor, size = textSize(tagSize))
        else
            label.set_x(o_tag, bar_index + tagOffset)
            label.set_y(o_tag, t_level)
            label.set_text(o_tag, tagLevel ? tag + " (" + str.tostring(t_level) + ")" : tag)

        if extend > 0
            o_end := t_check + extend * 60000

    if barstate.isconfirmed
        if time >= o_end
            o_line := na
            o_tag := na
            
        if not na(o_line)
            line.set_x2(o_line, bar_index + 2)

        if not na(o_tag)
            label.set_x(o_tag, bar_index + 1 + tagOffset)

    [o_line, o_tag, o_end]

if time1_enabled
    [t_line, t_tag, t_end] = check_time_level(time1_hour, time1_min, time1_use_close, time1_label, time1_color, time1_style, time1_width, time1_extend, time1_line, time1_tag, time1_end)
    time1_line := t_line
    time1_tag := t_tag
    time1_end := t_end

if time2_enabled
    [t_line, t_tag, t_end] = check_time_level(time2_hour, time2_min, time2_use_close, time2_label, time2_color, time2_style, time2_width, time2_extend, time2_line, time2_tag, time2_end)
    time2_line := t_line
    time2_tag := t_tag
    time2_end := t_end

if time3_enabled
    [t_line, t_tag, t_end] = check_time_level(time3_hour, time3_min, time3_use_close, time3_label, time3_color, time3_style, time3_width, time3_extend, time3_line, time3_tag, time3_end)
    time3_line := t_line
    time3_tag := t_tag
    time3_end := t_end

if time4_enabled
    [t_line, t_tag, t_end] = check_time_level(time4_hour, time4_min, time4_use_close, time4_label, time4_color, time4_style, time4_width, time4_extend, time4_line, time4_tag, time4_end)
    time4_line := t_line
    time4_tag := t_tag
    time4_end := t_end

if time5_enabled
    [t_line, t_tag, t_end] = check_time_level(time5_hour, time5_min, time5_use_close, time5_label, time5_color, time5_style, time5_width, time5_extend, time5_line, time5_tag, time5_end)
    time5_line := t_line
    time5_tag := t_tag
    time5_end := t_end

if time6_enabled
    [t_line, t_tag, t_end] = check_time_level(time6_hour, time6_min, time6_use_close, time6_label, time6_color, time6_style, time6_width, time6_extend, time6_line, time6_tag, time6_end)
    time6_line := t_line
    time6_tag := t_tag
    time6_end := t_end

if time7_enabled
    [t_line, t_tag, t_end] = check_time_level(time7_hour, time7_min, time7_use_close, time7_label, time7_color, time7_style, time7_width, time7_extend, time7_line, time7_tag, time7_end)
    time7_line := t_line
    time7_tag := t_tag
    time7_end := t_end

if time8_enabled
    [t_line, t_tag, t_end] = check_time_level(time8_hour, time8_min, time8_use_close, time8_label, time8_color, time8_style, time8_width, time8_extend, time8_line, time8_tag, time8_end)
    time8_line := t_line
    time8_tag := t_tag
    time8_end := t_end

if time9_enabled
    [t_line, t_tag, t_end] = check_time_level(time9_hour, time9_min, time9_use_close, time9_label, time9_color, time9_style, time9_width, time9_extend, time9_line, time9_tag, time9_end)
    time9_line := t_line
    time9_tag := t_tag
    time9_end := t_end

if time10_enabled
    [t_line, t_tag, t_end] = check_time_level(time10_hour, time10_min, time10_use_close, time10_label, time10_color, time10_style, time10_width, time10_extend, time10_line, time10_tag, time10_end)
    time10_line := t_line
    time10_tag := t_tag
    time10_end := t_end
````

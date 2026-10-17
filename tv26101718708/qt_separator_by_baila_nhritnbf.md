# QT Separator by Baila

- url: https://www.tradingview.com/script/NHrItnbf-QT-Separator-by-Baila/
- type: indicator
- pine_id: PUB;f4a9226af59d4d3282486a20d0db7056
- version: 1.0

## Description

Reup of Simple and Clean QT indicator.

Helps to spot SSMT

Based on: Daye Quarterly Theory by toodegrees

These Quarters represent:
 A - Accumulation (required for a cycle to occur)
 M - Manipulation
 D - Distribution
 X - Reversal/Continuation

## Source Code

````pine
//@version=6
indicator("QT Separator by Baila", overlay=true)

// Input parameters
shift_input = input.int(0, "Shift in candles", minval=-20, maxval=20)

timezone_input = input.string("America/Chicago", "Timezone", 
     options=["UTC", "America/Chicago", "UTC-12", "UTC-11"])

line_color = input.color(color.rgb(120, 123, 134, 30), "Line Color")
line_style = input.string(line.style_dotted, "Line Style", options=[line.style_solid, line.style_dotted, line.style_dashed])
line_width = input.int(1, "Line Width", minval=1, maxval=4)
wirdo_tingo = input.bool(false, "Wirdo Tingo", "You use it at your own risk")

is_target_time = hour(time, timezone_input) == 0

if timeframe.period == "1"
    // Your specific times: 00:23, 00:45, 01:08, 01:30, 01:53, 02:15, 02:38, 03:00
    specific_times = array.from (8, 30, 53, 75, 98, 120, 143, 165, 188, 210, 233, 255, 278, 300, 323, 345, 368, 390, 413, 435, 458, 480, 503, 525, 548, 570, 593, 615, 638, 660, 683, 705, 728, 750, 773, 795, 818, 840, 863, 885, 908, 930, 953, 975, 998, 1020, 1043, 1065, 1088, 1110, 1133, 1155, 1178, 1200, 1223, 1245, 1268, 1290, 1313, 1335, 1358, 1380, 1403, 1425)
    
    current_minutes = hour(time, timezone_input) * 60 + minute(time, timezone_input)
    is_target_time := array.includes(specific_times, current_minutes)
    
else if timeframe.period == "2"
    // Your specific times: 00:23, 00:45, 01:08, 01:30, 01:53, 02:15, 02:38, 03:00
    specific_times = array.from(8, 30, 54, 76, 98, 120, 144, 166, 188, 210, 234, 256, 278, 300, 324, 346, 368, 390, 414, 436, 458, 480, 504, 526, 548, 570, 594, 616, 638, 660, 684, 706, 728, 750, 774, 796, 818, 840, 864, 886, 908, 930, 954, 976, 998, 1020, 1044, 1066, 1088, 1110, 1134, 1156, 1178, 1200, 1224, 1246, 1268, 1290, 1314, 1336, 1358, 1380, 1404, 1426)
    
    current_minutes = hour(time, timezone_input) * 60 + minute(time, timezone_input)
    is_target_time := array.includes(specific_times, current_minutes)
    
else if timeframe.period == "3"
    // Your specific times: 00:23, 00:45, 01:08, 01:30, 01:53, 02:15, 02:38, 03:00
    specific_times = array.from(9, 30, 54, 75, 99, 120, 144, 165, 189, 210, 234, 255, 279, 300, 324, 345, 369, 390, 414, 435, 459, 480, 504, 525, 549, 570, 594, 615, 639, 660, 684, 705, 729, 750, 774, 795, 819, 840, 864, 885, 909, 930, 954, 975, 999, 1020, 1044, 1065, 1089, 1110, 1134, 1155, 1179, 1200, 1224, 1245, 1269, 1290, 1314, 1335, 1359, 1380, 1404, 1425)
    
    current_minutes = hour(time, timezone_input) * 60 + minute(time, timezone_input)
    is_target_time := array.includes(specific_times, current_minutes)

else if timeframe.period == "5"
    // Your specific times: 00:00, 01:30, 03:00, 04:30
    specific_times = array.from(30, 120, 210, 300, 390, 480, 570, 660, 750, 840, 930, 1020, 1110, 1200, 1290, 1380)
    
    current_minutes = hour(time, timezone_input) * 60 + minute(time, timezone_input)
    is_target_time := array.includes(specific_times, current_minutes)

else if timeframe.period == "15"
    is_target_time := (hour(time, timezone_input) == 23 or hour(time, timezone_input) == 5 or hour(time, timezone_input) == 11 or hour(time, timezone_input) == 17) and minute(time, timezone_input) == 0

else if timeframe.period == "30"
    is_target_time := (hour(time, timezone_input) == 23 or hour(time, timezone_input) == 5 or hour(time, timezone_input) == 11 or hour(time, timezone_input) == 17) and minute(time, timezone_input) == 0

else if timeframe.period == "60" and wirdo_tingo == true
    is_target_time := (dayofweek(time, timezone_input) == 1 and hour(time, timezone_input) == 17) or (dayofweek(time, timezone_input) == 2 and hour(time, timezone_input) == 23) or (dayofweek(time, timezone_input) == 4 and hour(time, timezone_input) == 5) or (dayofweek(time, timezone_input) == 5 and hour(time, timezone_input) == 11)

else if timeframe.period == "60"
    is_target_time := hour(time, timezone_input) == 17

else if timeframe.period == "90" and wirdo_tingo == true
    is_target_time := (dayofweek(time, timezone_input) == 1 and hour(time, timezone_input) == 17) or (dayofweek(time, timezone_input) == 2 and hour(time, timezone_input) == 23) or (dayofweek(time, timezone_input) == 4 and hour(time, timezone_input) == 5) or (dayofweek(time, timezone_input) == 5 and hour(time, timezone_input) == 11)

else if timeframe.period == "90"
    is_target_time := hour(time, timezone_input) == 17

else if timeframe.period == "240"
    is_target_time := (dayofweek(time, timezone_input) == 1 and hour(time, timezone_input) == 17)

else if timeframe.period == "360"
    is_target_time := (dayofweek(time, timezone_input) == 1 and hour(time, timezone_input) == 17)
else
    line_width := 0

// Draw vertical line when conditions are met
vline(BarIndex, Color, LineStyle, LineWidth) =>
    line.new(BarIndex, low - ta.tr, BarIndex, high + ta.tr, xloc.bar_index, extend.both, Color, LineStyle, LineWidth)

// Draw vertical line when conditions are met
if is_target_time and line_width != 0
    vline(bar_index + shift_input, line_color, line_style, line_width)
````

# Smart MTF Vertical Timezones & Future Forecast [212]

- url: https://www.tradingview.com/script/cFWZewzN/
- type: indicator
- pine_id: PUB;d61e666512704d6aa9d130d48dd4a634
- version: 1.0

## Description

Author: 212 (KOREA)

This indicator is designed for scalpers and day traders who monitor micro-timeframes (e.g., 15-second or 1-minute charts) but need to keep track of higher timeframe (HTF) market rhythms without cluttering their screens.

[Key Features]
1. Smart Overlap Filter (Hierarchy System)
When multiple timeframes close at the exact same time (e.g., at 12:00, the 15m, 30m, 1H, 4H, and 12H intervals all overlap), the script automatically hides the lower timeframe lines and only displays the most significant HTF line. This prevents color bleeding and keeps your chart incredibly clean.

2. Multi-Timeframe Tracking
Visualizes 5 essential intervals (15m, 30m, 1H, 4H, and 12H) with distinct colors, line widths, and labels for immediate visual recognition.

3. Future Time Projection
Dynamically plots the next two upcoming 15-minute intervals (Future +15m, Future +30m) into the right-side empty space (future axis) of the chart. This helps you anticipate upcoming volatility and crucial candle closes.

4. Extreme Optimization (Anti-Lag)
Limits the historical lines to a maximum of 100 to prevent browser lag and memory overload when used on ultra-fast timeframes like the 15s chart.

[How to Use]
Apply this script to any lower timeframe chart (15s, 30s, 1m, 3m, 5m). Use the vertical lines as major structural transition points where volatility or trend reversals are likely to occur.

## Source Code

````pine
//@version=6
indicator("Smart MTF Vertical Timezones & Future Forecast", overlay=true, max_lines_count=100)

// ---------------------------------------------------------
// 1. Past & Present Vertical Lines (Hierarchy System)
// ---------------------------------------------------------
is_12h = (time("720") != time("720")[1])
is_4h  = (time("240") != time("240")[1])
is_1h  = (time("60")  != time("60")[1])
is_30m = (time("30")  != time("30")[1])
is_15m = (time("15")  != time("15")[1])

draw_marker(line_color, line_width, line_style, text_tag) =>
    line.new(x1=bar_index, y1=low, x2=bar_index, y2=high, extend=extend.both, color=line_color, style=line_style, width=line_width)
    label.new(x=bar_index, y=high, text=text_tag, color=color.new(color.white, 100), textcolor=line_color, style=label.style_none, yloc=yloc.abovebar)

if is_12h
    draw_marker(color.rgb(255, 0, 255), 3, line.style_solid, "12H")
else if is_4h
    draw_marker(color.rgb(255, 82, 82), 2, line.style_solid, "4H")
else if is_1h
    draw_marker(color.rgb(255, 167, 38), 1, line.style_solid, "1H")
else if is_30m
    draw_marker(color.rgb(0, 188, 212), 1, line.style_dashed, "30M")
else if is_15m
    draw_marker(color.new(color.white, 50), 1, line.style_dotted, "15M")

// ---------------------------------------------------------
// 2. Future Projection (Upcoming 15m intervals)
// ---------------------------------------------------------
var line f_line1 = na
var line f_line2 = na
var label f_label1 = na
var label f_label2 = na

if barstate.islast
    line.delete(f_line1)
    line.delete(f_line2)
    label.delete(f_label1)
    label.delete(f_label2)
    
    future_time_1 = time_close("15") 
    future_time_2 = future_time_1 + (15 * 60 * 1000) 
    
    f_line1 := line.new(x1=future_time_1, y1=low, x2=future_time_1, y2=high, extend=extend.both, color=color.new(color.yellow, 40), style=line.style_dashed, width=1, xloc=xloc.bar_time)
    f_label1 := label.new(x=future_time_1, y=high, text="Future (+15m)", color=color.new(color.white, 100), textcolor=color.yellow, style=label.style_none, yloc=yloc.abovebar, xloc=xloc.bar_time)
    
    f_line2 := line.new(x1=future_time_2, y1=low, x2=future_time_2, y2=high, extend=extend.both, color=color.new(color.yellow, 60), style=line.style_dotted, width=1, xloc=xloc.bar_time)
    f_label2 := label.new(x=future_time_2, y=high, text="Future (+30m)", color=color.new(color.white, 100), textcolor=color.yellow, style=label.style_none, yloc=yloc.abovebar, xloc=xloc.bar_time)
````

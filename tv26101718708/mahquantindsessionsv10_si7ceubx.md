# MAHQuant_IND_Sessions_v1.0

- url: https://www.tradingview.com/script/sI7cEubx-MAHQuant-IND-Sessions-v1-0/
- type: indicator
- pine_id: PUB;a697b2f9604945128802bbc6c4ae4ee7
- version: 5.0

## Description

MAHQuant_IND_Sessions_v1.0

A comprehensive dual-purpose session tracking tool designed for professional traders. This indicator combines global market session visualization with precise Kill Zone mapping for London and New York sessions.

✨ Key Features:

1️⃣ Global Session Highlighter & Live Market Clock:
• Visual cubes and labels marking the exact start and end of New York, London, Tokyo, and Sydney sessions
• Live Market Clock dashboard showing real-time open/closed status of each major market
• Toggle between session visualization and clock display

2️⃣ London & New York Kill Zones (Vertical Lines):
• Custom vertical lines marking high-probability "Kill Zones"
• **Default Configuration: -1 hour offset**
  - Start: 1 hour BEFORE London/NY session open
  - End: 2 hours AFTER London/NY session open
• This captures the most volatile and high-probability trading windows
• Fully customizable line styles, widths, colors, and label positions

⚙️ Additional Features:
• Built-in alerts for all major market openings (NY, London, Tokyo, Sydney)
• Timezone offset support for any broker/server time
• Toggle each component independently based on your trading style
• Clean, professional visual design

📖 How to Use:
1. Add indicator to your chart
2. Set "Time Zone Offset" to match your broker time (e.g., +3 for UTC+3)
3. **Kill Zone Offset**: Default is -1 (shows 1hr before to 2hr after session start)
4. Enable/disable sessions or kill zones via input menu
5. Set alerts for "Session Open" to catch market moves

 Credits & Acknowledgment:
• Session highlighting and market clock logic inspired by traderharikrishna's open-source "Time Zone / Market Sessions" indicator
• Kill Zone vertical lines and offset logic developed by MAHQuant Trading System
• Thank you to the TradingView community for open-source collaboration

⚠️ Disclaimer:
This script is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Past performance is not indicative of future results. Always manage your risk and trade responsibly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MAHQuant

// Session highlighting and market clock logic inspired by:
// traderharikrishna's open-source "Time Zone / Market Sessions" indicator
// Kill Zone vertical lines and offset logic developed by: MAHQuant Trading System


//@version=6
indicator('MAHQuant_IND_Sessions_v1.1', overlay = true)

/////////////////////////////////////////
// TIME SESSION DISPLAY (UNCHANGED)
/////////////////////////////////////////
showtime = input(true, 'Show Time Sessions', group = 'TIME/SESSION')
var show_newyork_session = true and showtime
var newyork_color = input(title = 'New York Session Color', defval = color.rgb(10, 141, 242, 20), group = 'TIME/SESSION')
var newyork_text_color = input(title = 'New York Session Label Color', defval = color.rgb(10, 141, 242, 0), group = 'TIME/SESSION')
var newyork_position = input.string(title = 'New York Session Position', options = ['Top', 'Bottom'], defval = 'Top', group = 'TIME/SESSION')

var show_london_session = true and showtime
var london_color = input(title = 'London Session Color', defval = color.rgb(80, 204, 27, 20), group = 'TIME/SESSION')
var london_text_color = input(title = 'London Session Label Color', defval = color.rgb(80, 204, 27, 0), group = 'TIME/SESSION')
var london_position = input.string(title = 'London Session Position', options = ['Top', 'Bottom'], defval = 'Bottom', group = 'TIME/SESSION')

var show_tokyo_session = true and showtime
var tokyo_color = input(title = 'Tokyo Session Color', defval = color.rgb(252, 223, 3, 20), group = 'TIME/SESSION')
var tokyo_text_color = input(title = 'Tokyo Session Label Color', defval = color.rgb(252, 223, 3, 0), group = 'TIME/SESSION')
var tokyo_position = input.string(title = 'Tokyo Session Position', options = ['Top', 'Bottom'], defval = 'Top', group = 'TIME/SESSION')

var show_sydney_session = true and showtime
var sydney_color = input(title = 'Sydney Session Color', defval = color.rgb(247, 72, 238, 20), group = 'TIME/SESSION')
var sydney_text_color = input(title = 'Sydney Session Label Color', defval = color.rgb(253, 75, 215), group = 'TIME/SESSION')
var sydney_position = input.string(title = 'Sydney Session Position', options = ['Top', 'Bottom'], defval = 'Bottom', group = 'TIME/SESSION')

newyork_session = time(timeframe.period, '0800-1600:1234567', 'America/New_York')
newyork_session_start = time(timeframe.period, '0800-0801:1234567', 'America/New_York')
plotshape(show_newyork_session ? newyork_session : na, style = shape.square, color = newyork_color, location = newyork_position == 'Top' ? location.top : location.bottom, size = size.auto)
plotshape(show_newyork_session ? newyork_session_start : na, style = shape.square, color = color.rgb(255, 255, 255, 255), textcolor = newyork_text_color, location = newyork_position == 'Top' ? location.top : location.bottom, size = size.auto, text = 'Newyork')

london_session = time(timeframe.period, '0300-1100:1234567', 'America/New_York')
london_session_start = time(timeframe.period, '0300-0301:1234567', 'America/New_York')
plotshape(show_london_session ? london_session : na, style = shape.square, color = london_color, location = london_position == 'Top' ? location.top : location.bottom, size = size.auto)
plotshape(show_london_session ? london_session_start : na, style = shape.square, color = color.rgb(0, 0, 0, 255), textcolor = london_text_color, location = london_position == 'Top' ? location.top : location.bottom, size = size.auto, text = 'London')

tokyo_session = time(timeframe.period, '1900-0300:1234567', 'America/New_York')
tokyo_session_start = time(timeframe.period, '1900-1901:1234567', 'America/New_York')
plotshape(show_tokyo_session ? tokyo_session : na, style = shape.square, color = tokyo_color, location = tokyo_position == 'Top' ? location.top : location.bottom, size = size.auto)
plotshape(show_tokyo_session ? tokyo_session_start : na, style = shape.square, color = color.rgb(0, 0, 0, 255), textcolor = tokyo_text_color, location = tokyo_position == 'Top' ? location.top : location.bottom, size = size.auto, text = 'Tokyo')

sydney_session = time(timeframe.period, '1700-0100:1234567', 'America/New_York')
sydney_session_start = time(timeframe.period, '1700-1701:1234567', 'America/New_York')
plotshape(show_sydney_session ? sydney_session : na, style = shape.square, color = sydney_color, location = sydney_position == 'Top' ? location.top : location.bottom, size = size.auto)
plotshape(show_sydney_session ? sydney_session_start : na, style = shape.square, color = color.rgb(0, 0, 0, 255), textcolor = sydney_text_color, location = sydney_position == 'Top' ? location.top : location.bottom, size = size.auto, text = 'Sydney')

alertcondition(bool(newyork_session_start), title = 'New York Session Open', message = 'New York Session Open')
alertcondition(bool(london_session_start), title = 'London Session Open', message = 'London Session Open')
alertcondition(bool(tokyo_session_start), title = 'Tokyo Session Open', message = 'Tokyo Session Open')
alertcondition(bool(sydney_session_start), title = 'Sydney Session Open', message = 'Sydney Session Open')

markets = table.new(position.top_right, 4, 9, border_width = 1)
if not showtime
    table.cell(markets, 0, 0, text = 'OPEN', bgcolor = color.rgb(39, 133, 42), text_color = color.new(#ffffff, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(markets, 0, 1, text = 'NewYork ' + str.tostring(hour(timenow, 'America/New_York'), '00:') + str.tostring(minute(timenow, 'America/New_York'), '00:') + str.tostring(second(timenow, 'America/New_York'), '00') + '', bgcolor = bool(newyork_session) ? newyork_color : color.gray, text_color = color.new(#ffffff, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(markets, 0, 2, text = 'London  ' + str.tostring(hour(timenow, 'Europe/London'), '00:') + str.tostring(minute(timenow, 'Europe/London'), '00:') + str.tostring(second(timenow, 'Europe/London'), '00') + '', bgcolor = bool(london_session) ? london_color : color.gray, text_color = color.new(#ffffff, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(markets, 0, 3, text = 'Tokyo     ' + str.tostring(hour(timenow, 'Asia/Tokyo'), '00:') + str.tostring(minute(timenow, 'Asia/Tokyo'), '00:') + str.tostring(second(timenow, 'Asia/Tokyo'), '00') + '', bgcolor = bool(tokyo_session) ? tokyo_color : color.gray, text_color = color.new(#ffffff, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(markets, 0, 4, text = 'Sydney   ' + str.tostring(hour(timenow, 'Australia/Sydney'), '00:') + str.tostring(minute(timenow, 'Australia/Sydney'), '00:') + str.tostring(second(timenow, 'Australia/Sydney'), '00') + '', bgcolor = bool(sydney_session) ? sydney_color : color.gray, text_color = color.new(#ffffff, 0), text_size = size.small, text_halign = text.align_left)


//==========================================
// KILL ZONE (KZ) SETTINGS
//==========================================
timezone_offset = input.float(-1, "Time Zone Offset (Hours)", minval=-12.0, maxval=12.0, step=0.5)
days_back = input.int(10, "Days to show in past", minval=1, maxval=30)

show_before_london = input.bool(true, "London KZ Start")
show_after_london = input.bool(true, "London KZ End")
show_before_ny    = input.bool(true, "NY KZ Start")
show_after_ny     = input.bool(true, "NY KZ End")
show_kz_labels    = input.bool(true, "Show KZ Labels")
show_kz_lines     = input.bool(true, "Show KZ Vertical Lines")

color_before_london = input.color(color.new(#FF9800, 80), "London KZ Start Color")
color_after_london  = input.color(color.new(#FF5722, 80), "London KZ End Color")
color_before_ny     = input.color(color.new(#9C27B0, 80), "NY KZ Start Color")
color_after_ny      = input.color(color.new(#E91E63, 80), "NY KZ End Color")

line_style_opt = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"])
line_width_val = input.int(3, "Line Width", minval=1, maxval=5)
kz_label_text_color = input.color(color.black, "KZ Label Text Color")

getLineStyle(styleName) =>
    switch styleName
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

isAtTime(ts) =>
    not na(ts) and time >= ts and time < ts + 60000

offset_ms = int(timezone_offset * 60 * 60 * 1000)
y_cur = year(timenow)
m_cur = month(timenow)
d_cur = dayofmonth(timenow)

before_london = timestamp("UTC", y_cur, m_cur, d_cur, 7, 0, 0) + offset_ms
after_london  = timestamp("UTC", y_cur, m_cur, d_cur, 10, 0, 0) + offset_ms
before_ny     = timestamp("UTC", y_cur, m_cur, d_cur, 12, 0, 0) + offset_ms
after_ny      = timestamp("UTC", y_cur, m_cur, d_cur, 15, 0, 0) + offset_ms

//==========================================
// KZ VERTICAL LINES
//==========================================
if barstate.islast and show_kz_lines
    float chartMin = low
    float chartMax = high
    for i = 0 to 100
        chartMin := math.min(chartMin, low[i])
        chartMax := math.max(chartMax, high[i])
    
    ext = chartMax + (chartMax - chartMin) * 50
    
    // Today
    if show_before_london
        line.new(before_london, chartMin - ext, before_london, chartMax + ext, xloc=xloc.bar_time, color=color_before_london, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
    if show_after_london
        line.new(after_london, chartMin - ext, after_london, chartMax + ext, xloc=xloc.bar_time, color=color_after_london, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
    if show_before_ny
        line.new(before_ny, chartMin - ext, before_ny, chartMax + ext, xloc=xloc.bar_time, color=color_before_ny, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
    if show_after_ny
        line.new(after_ny, chartMin - ext, after_ny, chartMax + ext, xloc=xloc.bar_time, color=color_after_ny, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
    
    // Past days
    for dayOffset = -days_back to -1
        futureDate = timenow + dayOffset * 86400000
        y_future = year(futureDate)
        m_future = month(futureDate)
        d_future = dayofmonth(futureDate)
        
        before_london_future = timestamp("UTC", y_future, m_future, d_future, 7, 0, 0) + offset_ms
        after_london_future  = timestamp("UTC", y_future, m_future, d_future, 10, 0, 0) + offset_ms
        before_ny_future     = timestamp("UTC", y_future, m_future, d_future, 12, 0, 0) + offset_ms
        after_ny_future      = timestamp("UTC", y_future, m_future, d_future, 15, 0, 0) + offset_ms
        
        if show_before_london
            line.new(before_london_future, chartMin - ext, before_london_future, chartMax + ext, xloc=xloc.bar_time, color=color_before_london, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
        if show_after_london
            line.new(after_london_future, chartMin - ext, after_london_future, chartMax + ext, xloc=xloc.bar_time, color=color_after_london, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
        if show_before_ny
            line.new(before_ny_future, chartMin - ext, before_ny_future, chartMax + ext, xloc=xloc.bar_time, color=color_before_ny, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)
        if show_after_ny
            line.new(after_ny_future, chartMin - ext, after_ny_future, chartMax + ext, xloc=xloc.bar_time, color=color_after_ny, style=getLineStyle(line_style_opt), width=line_width_val, extend=extend.both)

//==========================================
// MARKERS & LABELS (FIXED - UNCHANGED)
//==========================================
plotshape(show_before_london and isAtTime(before_london), title="London KZ Start Marker", style=shape.circle, location=location.top, color=color_before_london, size=size.tiny)
plotshape(show_after_london and isAtTime(after_london), title="London KZ End Marker", style=shape.circle, location=location.top, color=color_after_london, size=size.tiny)
plotshape(show_before_ny and isAtTime(before_ny), title="NY KZ Start Marker", style=shape.circle, location=location.top, color=color_before_ny, size=size.tiny)
plotshape(show_after_ny and isAtTime(after_ny), title="NY KZ End Marker", style=shape.circle, location=location.top, color=color_after_ny, size=size.tiny)

plotshape(show_before_london and show_kz_labels and isAtTime(before_london), title="London KZ Start Label", style=shape.labeldown, location=location.top, color=color.new(color.white, 80), textcolor=kz_label_text_color, text="London KZ Start", size=size.normal)
plotshape(show_after_london and show_kz_labels and isAtTime(after_london), title="London KZ End Label", style=shape.labeldown, location=location.top, color=color.new(color.white, 80), textcolor=kz_label_text_color, text="London KZ End", size=size.normal)
plotshape(show_before_ny and show_kz_labels and isAtTime(before_ny), title="NY KZ Start Label", style=shape.labeldown, location=location.top, color=color.new(color.white, 80), textcolor=kz_label_text_color, text="NY KZ Start", size=size.normal)
plotshape(show_after_ny and show_kz_labels and isAtTime(after_ny), title="NY KZ End Label", style=shape.labeldown, location=location.top, color=color.new(color.white, 80), textcolor=kz_label_text_color, text="NY KZ End", size=size.normal)
````

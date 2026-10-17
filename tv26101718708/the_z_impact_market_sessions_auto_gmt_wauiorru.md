# The Z impact Market Sessions (Auto GMT)

- url: https://www.tradingview.com/script/WauIORrU-The-Z-impact-Market-Sessions-Auto-GMT/
- type: indicator
- pine_id: PUB;3a95ab885d4e4603b6a12e00d1fe1539
- version: 1.0

## Description

[b]The Z Impact Market Sessions (Auto GMT)

OVERVIEW
This indicator highlights the four major Forex trading sessions — 
London, New York, Tokyo and Sydney — directly on the chart as colored 
boxes. Each box tracks the high and low reached during that session, so 
you can see each session's range as it forms and where price sits 
relative to it.

WHAT MAKES IT PRACTICAL
The main focus is a single GMT offset input. Instead of editing four 
separate session time ranges by hand every time your broker's server 
time or daylight saving changes, you adjust one value and all four 
sessions shift together. Session times are defined internally on a fixed 
base and recalculated from that one offset, including correct handling of 
sessions that cross midnight (such as Tokyo and Sydney).

HOW IT WORKS
- Each session has a fixed base open/close time. A single offset input 
  shifts all of them, with hours wrapping correctly across the 0-24 
  boundary.
- A box is opened when a session starts and is extended bar by bar until 
  the session ends, continuously updating its high and low.
- A label marks each session by name, centered over its box.
- Sessions that span midnight are detected with an OR-based time check so 
  the box stays continuous.

INPUTS
- GMT offset: one value to align all sessions to your chart/broker time.
- Show toggles for London, New York, Tokyo and Sydney.
- A color per session and a background transparency control.

HOW TO USE
- If the sessions do not line up with your chart, adjust the GMT offset 
  until London (or any session you can verify) sits where you expect.
- Use the session boxes to see range highs and lows, session overlaps, 
  and where the current price is within the active session.
- Sydney is off by default; enable it if you trade that session.

NOTES
- Times are based on standard session hours; during daylight saving 
  transitions you may need to adjust the offset by half or one hour.
- This is a visual session tool. It does not generate buy or sell 
  signals.[/b]

## Source Code

````pine
//@version=6
indicator('The Z impact Market Sessions (Auto GMT)', shorttitle = 'The Z impact market Sessions', overlay = true, max_lines_count = 200, max_boxes_count = 200)

// ---- GMT SETTINGS ---- //
i_gmt = input.float(1, 'increase or decrease time (Dont change if there is no problem)', step = 0.5, minval = -12, maxval = 14)

// ---- BASE SESSION TIMES (in GMT-4) ---- //
london_base_start = 4 // London opens 08:00 GMT -> 04:00 GMT-4
london_base_end = 13 // London closes 17:00 GMT -> 13:00 GMT-4

ny_base_start = 9 // NY opens 13:00 GMT -> 09:00 GMT-4
ny_base_end = 18 // NY closes 22:00 GMT -> 18:00 GMT-4

tokyo_base_start = 20 // Tokyo opens 00:00 GMT -> 20:00 GMT-4 (previous day)
tokyo_base_end = 5 // Tokyo closes 09:00 GMT -> 05:00 GMT-4

sydney_base_start = 16 // Sydney opens 20:00 GMT -> 16:00 GMT-4
sydney_base_end = 1 // Sydney closes 05:00 GMT -> 01:00 GMT-4

// ---- ADJUST HOURS FOR GMT ---- //
adjustHour(hour, gmt) =>
    h = hour - gmt // 
    h := h >= 24 ? h - 24 : h
    h := h < 0 ? h + 24 : h
    h

// Calculate session times based on GMT offset
london_start = adjustHour(london_base_start, i_gmt)
london_end = adjustHour(london_base_end, i_gmt)

ny_start = adjustHour(ny_base_start, i_gmt)
ny_end = adjustHour(ny_base_end, i_gmt)

tokyo_start = adjustHour(tokyo_base_start, i_gmt)
tokyo_end = adjustHour(tokyo_base_end, i_gmt)

sydney_start = adjustHour(sydney_base_start, i_gmt)
sydney_end = adjustHour(sydney_base_end, i_gmt)

// ---- DISPLAY SETTINGS ---- //
i_show_london = input(true, 'Show London')
i_show_ny = input(true, 'Show New York')
i_show_tokyo = input(true, 'Show Tokyo')
i_show_sydney = input(true, 'Show Sydney')

london_color = input(color.blue, 'London Color')
ny_color = input(color.orange, 'NY Color')
tokyo_color = input(color.purple, 'Tokyo Color')
sydney_color = input(color.red, 'Sydney Color')

bg_transp = input.int(90, 'Background Transparency', minval = 0, maxval = 100)

// ---- SESSION FUNCTIONS ---- //
inSession(start_hour, end_hour) =>
    hour = hour(time)
    minute = minute(time)
    curr_time = hour + minute / 60

    result = false
    if start_hour < end_hour
        result := curr_time >= start_hour and curr_time < end_hour
        result
    else
        result := curr_time >= start_hour or curr_time < end_hour
        result
    result

drawSession(show, start_hour, end_hour, _color, session_name) =>
    var box current_box = na
    var label current_label = na
    var int start_bar = na
    var float sess_high = na
    var float sess_low = na

    in_session = inSession(start_hour, end_hour)
    sess_start = in_session and not inSession(start_hour, end_hour)[1]
    sess_end = not in_session and inSession(start_hour, end_hour)[1]

    if sess_start
        start_bar := bar_index
        sess_high := high
        sess_low := low
        // Create new box at session start
        if show
            current_box := box.new(start_bar, sess_high, bar_index, sess_low, border_color = _color, bgcolor = color.new(_color, bg_transp))
            current_label := label.new(
                start_bar,
                sess_high,
                session_name,
                style = label.style_none,
                textcolor = _color,
                size = size.small)
            current_box

    if in_session
        sess_high := math.max(sess_high, high)
        sess_low := math.min(sess_low, low)
        // Update current box while session is active
        if show and not na(current_box)
            box.set_right(current_box, bar_index)
            box.set_top(current_box, sess_high)
            box.set_bottom(current_box, sess_low)
            if not na(current_label)
                label.set_x(current_label, math.floor((start_bar + bar_index) / 2))
                label.set_y(current_label, sess_high + (sess_high - sess_low) * 0.03)

    if sess_end
        current_box := na
        current_label := na
        current_box

// ---- DRAW SESSIONS ---- //
drawSession(i_show_london, london_start, london_end, london_color, "London")
drawSession(i_show_ny, ny_start, ny_end, ny_color, "New York")
drawSession(i_show_tokyo, tokyo_start, tokyo_end, tokyo_color, "Tokyo")
drawSession(i_show_sydney, sydney_start, sydney_end, sydney_color, "Sydney")
````

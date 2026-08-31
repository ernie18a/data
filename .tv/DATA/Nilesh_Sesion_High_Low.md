<!-- tradingview-pine-id: PUB;9a3a0cfb7aef49ec8033524e02bf6611 -->
<!-- tradingviewscripts-format: 1 -->
# Nilesh Sesion High Low

Source: https://www.tradingview.com/script/rSFgPuww-Nilesh-Sesion-High-Low/

## Description

This indicator is best used on intraday charts to mark important session highs and lows that often act as reaction points, liquidity levels, or breakout references during the same trading day.

---

## Source Code

````pine
//@version=6
indicator("Nilesh Sesion High Low", "Nilesh Sesion High Low", true, max_labels_count = 300, max_lines_count = 300)

// ---------- Helpers ----------
get_line_type(_style) =>
    switch _style
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed

// ---------- Inputs ----------
var g_sessions = "Sessions"

asia_on      = input.bool(true, "Show Asia", inline = "ASIA", group = g_sessions)
asia_color   = input.color(color.blue, "", inline = "ASIA", group = g_sessions)
asia_name    = input.string("Asia", "", inline = "ASIA", group = g_sessions)
asia_session = input.session("2000-0000", "", inline = "ASIA", group = g_sessions)

london_on      = input.bool(true, "Show London", inline = "LONDON", group = g_sessions)
london_color   = input.color(color.yellow, "", inline = "LONDON", group = g_sessions)
london_name    = input.string("London", "", inline = "LONDON", group = g_sessions)
london_session = input.session("0200-0500", "", inline = "LONDON", group = g_sessions)

ny_on      = input.bool(true, "Show NY", inline = "NY", group = g_sessions)
ny_color   = input.color(color.purple, "", inline = "NY", group = g_sessions)
ny_name    = input.string("NY", "", inline = "NY", group = g_sessions)
ny_session = input.session("0930-1100", "", inline = "NY", group = g_sessions)

var g_style = "Style"
line_style  = get_line_type(input.string("Solid", "Line Style", options = ["Solid", "Dotted", "Dashed"], group = g_style))
line_width  = input.int(1, "Line Width", minval = 1, maxval = 5, group = g_style)
show_labels = input.bool(true, "Show Labels", group = g_style)

var g_global = "Global"
max_days = input.int(3, "Session Limit", minval = 1, group = g_global)
gmt_tz   = input.string("America/New_York", "Timezone", options = ["America/New_York","GMT-12","GMT-11","GMT-10","GMT-9","GMT-8","GMT-7","GMT-6","GMT-5","GMT-4","GMT-3","GMT-2","GMT-1","GMT+0","GMT+1","GMT+2","GMT+3","GMT+4","GMT+5","GMT+6","GMT+7","GMT+8","GMT+9","GMT+10","GMT+11","GMT+12","GMT+13","GMT+14"], group = g_global)

// ---------- Types ----------
type SessionState
    string title
    color session_color
    int[] start_time
    line[] hi_line
    line[] lo_line
    label[] hi_label
    label[] lo_label
    float hi
    float lo

new_session(_title, _color) =>
    SessionState.new(_title, _color, array.new_int(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), na, na)

// ---------- State ----------
var SessionState asia   = new_session(asia_name, asia_color)
var SessionState london = new_session(london_name, london_color)
var SessionState ny     = new_session(ny_name, ny_color)
var transparent = #ffffff00

// ---------- Utilities ----------
trim_session(SessionState s) =>
    if s.hi_line.size() > max_days
        s.hi_line.pop().delete()
    if s.lo_line.size() > max_days
        s.lo_line.pop().delete()
    if s.hi_label.size() > max_days
        s.hi_label.pop().delete()
    if s.lo_label.size() > max_days
        s.lo_label.pop().delete()
    if s.start_time.size() > max_days
        s.start_time.pop()

manage_session(SessionState s, bool enabled, string sess) =>
    bool t  = not na(time("", sess, gmt_tz))
    bool t1 = not na(time("", sess, gmt_tz)[1])

    if enabled
        if t and not t1
            s.hi := high
            s.lo := low
            s.start_time.unshift(time)

            s.hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = line_style, color = s.session_color, width = line_width))
            s.lo_line.unshift(line.new(time, low, time, low, xloc = xloc.bar_time, style = line_style, color = s.session_color, width = line_width))

            if show_labels
                s.hi_label.unshift(label.new(time, high, s.title + " High", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = s.session_color, size = size.normal))
                s.lo_label.unshift(label.new(time, low, s.title + " Low", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = s.session_color, size = size.normal))

            trim_session(s)

        if s.hi_line.size() > 0
            if t
                s.hi := math.max(s.hi, high)
                s.lo := math.min(s.lo, low)

                s.hi_line.get(0).set_y1(s.hi)
                s.hi_line.get(0).set_y2(s.hi)

                s.lo_line.get(0).set_y1(s.lo)
                s.lo_line.get(0).set_y2(s.lo)

                if show_labels and s.hi_label.size() > 0
                    s.hi_label.get(0).set_y(s.hi)
                    s.lo_label.get(0).set_y(s.lo)

            s.hi_line.get(0).set_x2(time)
            s.lo_line.get(0).set_x2(time)

            if show_labels and s.hi_label.size() > 0
                s.hi_label.get(0).set_x(time)
                s.lo_label.get(0).set_x(time)

// keep titles/colors synced with settings
asia.title := asia_name
asia.session_color := asia_color

london.title := london_name
london.session_color := london_color

ny.title := ny_name
ny.session_color := ny_color

manage_session(asia, asia_on, asia_session)
manage_session(london, london_on, london_session)
manage_session(ny, ny_on, ny_session)
````

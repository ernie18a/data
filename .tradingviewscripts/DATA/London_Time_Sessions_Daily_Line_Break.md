<!-- tradingview-pine-id: PUB;5c4a8fbde96648d2a9fa25f6c658f108 -->
<!-- tradingviewscripts-format: 1 -->
# London Time Sessions & Daily Line Break

Source: https://www.tradingview.com/script/ZCUkBdX7-Daily-sessions/

## Description

I just wanted to have chart breakdown by days and sessions. So I built this indicator for that. There's few things you can edit. But anyway, enjoy. Happy trading.

---

## Source Code

````pine
//@version=6
indicator("London Time Sessions & Daily Line Break", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ==========================================
// Timezone & Master Controls
// ==========================================
tz                = input.string("Europe/London", title="Time Zone", group="Time Settings")
show_all_sessions = input.bool(true, "ENABLE ALL SESSIONS (Master Switch)", group="Session Master Control")

// ==========================================
// Individual Session Toggles & Inputs
// ==========================================
// Asia
show_asia    = input.bool(true, "Show Asia", group="Asia Session", inline="asia")
asia_sess    = input.session("0000-0600", "", group="Asia Session", inline="asia")
asia_color   = input.color(#ff9800, "Color", group="Asia Session", inline="asia")

// Frankfurt
show_frank   = input.bool(true, "Show Frankfurt", group="Frankfurt Session", inline="frank")
frank_sess   = input.session("0700-0800", "", group="Frankfurt Session", inline="frank")
frank_color  = input.color(#9c27b0, "Color", group="Frankfurt Session", inline="frank")

// London
show_london  = input.bool(true, "Show London", group="London Session", inline="london")
london_sess  = input.session("0800-1430", "", group="London Session", inline="london")
london_color = input.color(#4caf50, "Color", group="London Session", inline="london")

// Red Zone
show_red     = input.bool(true, "Show Red Zone", group="Red Zone", inline="red")
red_sess     = input.session("0930-1030", "", group="Red Zone", inline="red")
red_color    = input.color(color.new(#f44336, 85), "Color", group="Red Zone", inline="red")

// New York
show_ny      = input.bool(true, "Show New York", group="New York Session", inline="ny")
ny_sess      = input.session("1430-2000", "", group="New York Session", inline="ny")
ny_color     = input.color(#2196f3, "Color", group="New York Session", inline="ny")

// Box Style Inputs
box_transp    = input.int(85, "Box Fill Transparency (0-100)", minval=0, maxval=100, group="Box Settings")
border_transp = input.int(30, "Box Border Transparency (0-100)", minval=0, maxval=100, group="Box Settings")
extend_bars   = input.int(1, "Right Edge Extension (Bars)", minval=0, maxval=5, group="Box Settings")

// Daily Line Break & Label Inputs
show_divider      = input.bool(true, "Show Daily Line Break", group="Daily Separator")
divider_color     = input.color(color.new(color.gray, 40), "Line Color", group="Daily Separator")
divider_style_str = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Daily Separator")
divider_width     = input.int(1, "Line Width", minval=1, maxval=10, group="Daily Separator")

show_labels       = input.bool(true, "Show Day Labels", group="Daily Separator")
label_text_col    = input.color(color.black, "Label Text Color", group="Daily Separator")
label_offset_ticks= input.int(15, "Label Offset Below Day Low (Ticks)", minval=0, group="Daily Separator")

// Helper function for line style
f_get_line_style(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

divider_style = f_get_line_style(divider_style_str)

// ==========================================
// Session Calculations & Master Filtering
// ==========================================
in_asia   = show_all_sessions and show_asia   and not na(time(timeframe.period, asia_sess, tz))
in_frank  = show_all_sessions and show_frank  and not na(time(timeframe.period, frank_sess, tz))
in_london = show_all_sessions and show_london and not na(time(timeframe.period, london_sess, tz))
in_ny     = show_all_sessions and show_ny     and not na(time(timeframe.period, ny_sess, tz))
in_red    = show_all_sessions and show_red    and not na(time(timeframe.period, red_sess, tz))

// Full Layout Background Highlight for Red Zone (Top to Bottom)
bgcolor(in_red ? red_color : na, title="Red Zone (09:30 - 10:30)")

// ==========================================
// Function to Draw High-to-Low Session Boxes
// ==========================================
f_draw_session_box(bool in_sess, color sess_color, int ext_bars) =>
    var box b = na
    var float h_val = na
    var float l_val = na

    if in_sess
        if not in_sess[1]
            h_val := high
            l_val := low
            b := box.new(
                 left = bar_index,
                 top = h_val,
                 right = bar_index + ext_bars,
                 bottom = l_val,
                 border_color = color.new(sess_color, border_transp),
                 bgcolor = color.new(sess_color, box_transp),
                 border_style = line.style_solid,
                 border_width = 1
                 )
        else if not na(b)
            h_val := math.max(h_val, high)
            l_val := math.min(l_val, low)
            box.set_top(b, h_val)
            box.set_bottom(b, l_val)
            box.set_right(b, bar_index + ext_bars)
    else
        b := na
    b

// Draw boxes for Asia, Frankfurt, London, NY
f_draw_session_box(in_asia, asia_color, extend_bars)
f_draw_session_box(in_frank, frank_color, extend_bars)
f_draw_session_box(in_london, london_color, extend_bars)
f_draw_session_box(in_ny, ny_color, extend_bars)

// ==========================================
// Daily Line Break & Day Labels Below Day Low
// ==========================================
day_num = dayofmonth(time, tz)
is_new_day = ta.change(day_num) != 0 and timeframe.isintraday
dow = dayofweek(time, tz)

var int sunday_start_bar = na
var int day_start_bar    = na
var label current_day_label = na
var float current_day_low   = na

if is_new_day
    current_day_low := low
    if dow == dayofweek.sunday
        sunday_start_bar  := bar_index
        current_day_label := na
        if show_divider
            line.new(
                 x1 = bar_index, y1 = low,
                 x2 = bar_index, y2 = high,
                 extend = extend.both,
                 color = divider_color,
                 style = divider_style,
                 width = divider_width
                 )
    else
        if dow == dayofweek.monday and not na(sunday_start_bar)
            day_start_bar    := sunday_start_bar
            sunday_start_bar := na
        else
            day_start_bar := bar_index
            if show_divider
                line.new(
                     x1 = bar_index, y1 = low,
                     x2 = bar_index, y2 = high,
                     extend = extend.both,
                     color = divider_color,
                     style = divider_style,
                     width = divider_width
                     )

        day_str = switch dow
            dayofweek.monday    => "Monday"
            dayofweek.tuesday   => "Tuesday"
            dayofweek.wednesday => "Wednesday"
            dayofweek.thursday  => "Thursday"
            dayofweek.friday    => "Friday"
            dayofweek.saturday  => "Saturday"
            => ""

        if show_labels and day_str != ""
            current_day_label := label.new(
                 x = bar_index,
                 y = current_day_low - (label_offset_ticks * syminfo.mintick),
                 text = day_str,
                 yloc = yloc.price,
                 color = color.new(color.white, 100),
                 textcolor = label_text_col,
                 style = label.style_none,
                 size = size.normal
                 )
else
    current_day_low := math.min(current_day_low, low)

// Continuously update position during intraday trading
if timeframe.isintraday and not na(current_day_label) and not na(day_start_bar)
    // 1. Keep label centered between day start bar and current bar
    int mid_bar = math.round((day_start_bar + bar_index) / 2)
    label.set_x(current_day_label, mid_bar)
    
    // 2. Anchor label just below the lowest price/session box of that specific day
    label.set_y(current_day_label, current_day_low - (label_offset_ticks * syminfo.mintick))
````

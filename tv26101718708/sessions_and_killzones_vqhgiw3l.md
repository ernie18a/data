# Sessions AND killzones 

- url: https://www.tradingview.com/script/VQHGiw3l/
- type: indicator
- pine_id: PUB;e17b1329cd344993aae815965ba2eb9f
- version: 1.0

## Description

What this indicator does
This is a Pine Script (TradingView) indicator called "Sessions AND Killzones" that visually marks the main market sessions on the chart. Here's what each part does:

🌍 Highlighted Sessions
The indicator marks 4 configurable sessions on the chart, with default presets:
SessionDefault TimeColorNew York AM07:00–11:00ConfigurableNew York PM13:00–16:00ConfigurableAsian (Tokyo)20:00–00:00ConfigurableLondon02:00–05:00Configurable
There's also an opening block that highlights Tokyo, London, and New York via bgcolor, using orange, blue, and green.

📦 What gets drawn per session
For each of the 4 sessions, the indicator can draw:

Box — a rectangle showing the session's price range (high and low)
Labels — session name, day of the week, price change, or pips
Fibonacci Levels — lines at 38.2%, 50%, and 62.8% of the session's range
Opening Range — a highlighted box covering the first X minutes of the session (default: 15 min), with breakout alerts
Session Candle — a large "candle" representing the entire session (body + wicks)
Bar Coloring — can recolor chart candles with the active session's color


🔔 Alert System
The indicator fires alerts for:

Start and end of each session
Price crossing the high or low of a closed session (breakout)
Opening Range breakouts (upward or downward)


⚙️ In short
This is a complete tool for traders who operate based on market sessions (ICT/SMC methodology), allowing them to visualize where price moved during each session, identify breakouts, and set automatic alerts — all highly customizable.

## Source Code

````pine
//@version=5
indicator("Sessions AND killzones ", overlay=true)

// ─── SESSIONS ─────────────────────────────────────────────────────────────────
show_tokyo   = input.bool(true, "Tokyo    (18:00-03:00 EST)", group="Sessions")
show_london  = input.bool(true, "London   (03:00-12:00 EST)", group="Sessions")
show_ny      = input.bool(true, "New York (08:00-17:00 EST)", group="Sessions")
show_sess_bg = input.bool(true, "Highlight Active Session",   group="Sessions")

// ─── COLORS ───────────────────────────────────────────────────────────────────
col_tokyo  = input.color(color.new(#FF9800, 88), "Tokyo Color",    group="Colors")
col_london = input.color(color.new(#2196F3, 88), "London Color",   group="Colors")
col_ny     = input.color(color.new(#4CAF50, 88), "New York Color", group="Colors")

// ─── SESSION DETECTION ────────────────────────────────────────────────────────
is_tokyo  = not na(time("1", "1800-0300", "America/New_York"))
is_london = not na(time("1", "0300-1200", "America/New_York"))
is_ny     = not na(time("1", "0800-1700", "America/New_York"))

bgcolor(show_sess_bg and show_tokyo  and is_tokyo  ? col_tokyo  : na, title="Tokyo BG")
bgcolor(show_sess_bg and show_london and is_london ? col_london : na, title="London BG")
bgcolor(show_sess_bg and show_ny     and is_ny     ? col_ny     : na, title="New York BG")

import boitoki/AwesomeColor/4 as ac
import boitoki/Utilities/3 as util

///////////////
// Groups
///////////////
g0                      = 'GENERAL'
g1_01                   = '♯1 SESSION'
g1_02                   = '♯2 SESSION'
g1_03                   = '♯3 SESSION'
g1_04                   = '♯4 SESSION'
g4                      = 'BOX'
g6                      = 'LABELS'
g5                      = 'OPENING RANGE'
g7                      = 'FIBONACCI LEVELS'
g8                      = 'OPTIONS'
g11                     = 'CANDLE'
g10                     = 'Alerts visualized'

///////////////
// Defined
///////////////
max_bars                = 500

option_yes              = 'Yes'
option_no               = '× No'
option_extend1          = 'Yes'
option_hide             = '× Hide'
option_border_style1    = '────'
option_border_style2    = '- - - - - -'
option_border_style3    = '•••••••••'
option_chart_x          = '× No'
option_chart_1          = 'Bar color'
option_chart_2          = 'Candles'

fmt_price               = '{0,number,#.#####}'
fmt_pips                = '{0,number,#.#}'

icon_separator          = ' • '

color_none              = color.new(color.black, 100)
color_text              = color.new(color.white, 0)

///////////////
// Functions
///////////////
f_get_time_by_bar(bar_count) => timeframe.multiplier * bar_count * 60 * 1000

f_border_style (_style) =>
    switch _style
        option_border_style1 => line.style_solid
        option_border_style2 => line.style_dashed
        option_border_style3 => line.style_dotted
        => _style

f_get_period (_session, _start, _lookback) =>
    result = math.max(_start, 1)
    for i = result to _lookback
        if na(_session[i+1]) and _session[i]
            result := i+1
            break
    result

f_get_label_position (_y, _side) =>
    switch _y
        'top'    => _side == 'outside' ? label.style_label_lower_left : label.style_label_upper_left
        'bottom' => _side == 'outside' ? label.style_label_upper_left : label.style_label_lower_left

f_get_started (_session) => na(_session[1]) and _session

f_get_ended (_session) => na(_session) and _session[1]

f_message_limit_bars (_v) => '⚠️ This box\'s right position exceeds 500 bars(' + str.tostring(_v) + '). This box is not displayed correctly.'

f_set_line_x1 (_line, _x) =>
    if (line.get_x1(_line) != _x)
        line.set_x1(_line, _x)

f_set_line_x2 (_line, _x) =>
    if (line.get_x2(_line) != _x)
        line.set_x2(_line, _x)

f_set_box_right (_box, _x) =>
    if box.get_right(_box) != _x
        box.set_right(_box, _x)

///////////////
// Inputs
///////////////
// Timezone
i_tz                    = input.string('GMT-4', title='Timezone', options=['GMT-11', 'GMT-10', 'GMT-9', 'GMT-8', 'GMT-7', 'GMT-6', 'GMT-5', 'GMT-4', 'GMT-3', 'GMT-2', 'GMT-1', 'GMT+0', 'GMT+1', 'GMT+2', 'GMT+3', 'GMT+330', 'GMT+4', 'GMT+430', 'GMT+5', 'GMT+530', 'GMT+6', 'GMT+7', 'GMT+8', 'GMT+9', 'GMT+10', 'GMT+11', 'GMT+12'], tooltip='e.g. \'America/New_York\', \'Asia/Tokyo\', \'GMT-4\', \'GMT+9\'...', group=g0)
i_history_period        = input.int(10, 'History', minval=0, group=g0)
i_show                  = i_history_period > 0
i_lookback              = 12 * 60

// Sessions
i_show_sess1            = input.bool(true, 'Session 1  ', group=g1_01, inline='session1_1') and i_show
i_sess1_label           = input.string('New York AM', '', group=g1_01, inline='session1_1')
i_sess1_color           = input.color(#0a0a0a, '', group=g1_01, inline='session1_1')
i_sess1_barcolor1       = input.color(#0a0a0a, '•', group=g1_01, inline='session1_1')
i_sess1_barcolor2       = input.color(#0a0a0a, '', group=g1_01, inline='session1_1')
i_sess1                 = input.session('0700-1100', 'Time', group=g1_01)
i_sess1_extend          = input.string(option_no, 'Extend', options=[option_no, option_extend1], group=g1_01)
i_sess1_fib             = input.string(option_no, 'Fibonacci levels', group=g1_01, options=[option_yes, option_no]) != option_no
i_sess1_op              = input.string(option_no, 'Opening range', group=g1_01, options=[option_yes, option_no]) != option_no and i_show
i_sess1_chart           = input.string(option_chart_x, 'Bar', options=[option_chart_1, option_chart_2, option_chart_x], group=g1_01)
i_sess1_barcolor        = i_sess1_chart == option_chart_1
i_sess1_plotcandle      = i_sess1_chart == option_chart_2

i_show_sess2            = input.bool(true, 'Session 2  ', group=g1_02, inline='session2_1') and i_show
i_sess2_label           = input.string('New York PM', '', group=g1_02, inline='session2_1')
i_sess2_color           = input.color(#0a0a0a, '', group=g1_02, inline='session2_1')
i_sess2_barcolor1       = input.color(#0a0a0a, '•', group=g1_02, inline='session2_1')
i_sess2_barcolor2       = input.color(#0a0a0a, '', group=g1_02, inline='session2_1')
i_sess2                 = input.session('1300-1600', 'Time', group=g1_02)
i_sess2_extend          = input.string(option_no, 'Extend', options=[option_no, option_extend1], group=g1_02)
i_sess2_fib             = input.string(option_no, 'Fibonacci levels', group=g1_02, options=[option_yes, option_no]) != option_no
i_sess2_op              = input.string(option_no, 'Opening range', group=g1_02, options=[option_yes, option_no]) != option_no and i_show
i_sess2_chart           = input.string(option_chart_x, 'Bar', options=[option_chart_1, option_chart_2, option_chart_x], group=g1_02)
i_sess2_barcolor        = i_sess2_chart == option_chart_1
i_sess2_plotcandle      = i_sess2_chart == option_chart_2

i_show_sess3            = input.bool(true, 'Session 3  ', group=g1_03, inline='session3_1') and i_show
i_sess3_label           = input.string('Asian Sesh', '', group=g1_03, inline='session3_1')
i_sess3_color           = input.color(#0a0a0a, '', group=g1_03, inline='session3_1')
i_sess3_barcolor1       = input.color(#0a0a0a, '•', group=g1_03, inline='session3_1')
i_sess3_barcolor2       = input.color(#0a0a0a, '', group=g1_03, inline='session3_1')
i_sess3                 = input.session('2000-0000', 'Time', group=g1_03)
i_sess3_extend          = input.string(option_no, 'Extend', options=[option_no, option_extend1], group=g1_03)
i_sess3_fib             = input.string(option_no, 'Fibonacci levels', group=g1_03, options=[option_yes, option_no]) != option_no
i_sess3_op              = input.string(option_no, 'Opening range', group=g1_03, options=[option_yes, option_no]) != option_no and i_show
i_sess3_chart           = input.string(option_chart_x, 'Bar', options=[option_chart_1, option_chart_2, option_chart_x], group=g1_03)
i_sess3_barcolor        = i_sess3_chart == option_chart_1
i_sess3_plotcandle      = i_sess3_chart == option_chart_2

i_show_sess4            = input.bool(true, 'Session 4  ', group=g1_04, inline='session4_1') and i_show
i_sess4_label           = input.string('London', '', group=g1_04, inline='session4_1')
i_sess4_color           = input.color(#0a0a0a, '', group=g1_04, inline='session4_1')
i_sess4_barcolor1       = input.color(#0a0a0a, '•', group=g1_04, inline='session4_1')
i_sess4_barcolor2       = input.color(#0a0a0a, '', group=g1_04, inline='session4_1')
i_sess4                 = input.session('0200-0500', 'Time', group=g1_04)
i_sess4_extend          = input.string(option_no, 'Extend', options=[option_no, option_extend1], group=g1_04)
i_sess4_fib             = input.string(option_no, 'Fibonacci levels', group=g1_04, options=[option_yes, option_no]) != option_no
i_sess4_op              = input.string(option_no, 'Opening range', group=g1_04, options=[option_yes, option_no]) != option_no and i_show
i_sess4_chart           = input.string(option_chart_x, 'Bar', options=[option_chart_1, option_chart_2, option_chart_x], group=g1_04)
i_sess4_barcolor        = i_sess4_chart == option_chart_1
i_sess4_plotcandle      = i_sess4_chart == option_chart_2

// Show & Styles
i_sess_box_style        = input.string('Box', 'Style', options=['Box', 'Dot'], group=g4)
i_sess_border_style     = f_border_style(input.string(option_border_style2, 'Line style', options=[option_border_style1, option_border_style2, option_border_style3], group=g4))
i_sess_border_width     = input.int(1, 'Thickness', minval=0, group=g4)
i_sess_bgopacity        = input.int(94, 'Transp', minval=0, maxval=100, step=1, group=g4, tooltip='Setting the 100 is no background color')

// Candle
option_candle_body      = 'OC'
option_candle_wick      = 'OHLC'
i_candle                = input.string(option_hide, 'Display', options=[option_candle_wick, option_candle_body, option_hide], group=g11)
i_candle_border_width   = input.int(2, 'Thickness', minval=0, group=g11)
i_show_candle           = (i_candle != option_hide) and (i_candle_border_width > 0)
i_show_candle_wick      = i_candle == option_candle_wick
option_candle_color1    = 'Session\'s'
option_candle_color2    = 'Red • Green'
i_candle_color          = input.string(option_candle_color2, 'Color ', options=[option_candle_color1, option_candle_color2], group=g11, inline='candle_color')
i_candle_color_g        = input.color(#A6E22E, '', group=g11, inline='candle_color')
i_candle_color_r        = input.color(#F92672, '', group=g11, inline='candle_color')

// Labels
i_label_show            = input.bool(true, 'Labels', inline='label_show', group=g6) and i_show
i_label_size            = str.lower(input.string('Small', '', options=['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline='label_show', group=g6))
i_label_position_y      = str.lower(input.string('Top', '', options=['Top', 'Bottom'], inline='label_show', group=g6))
i_label_position_s      = str.lower(input.string('Outside', '', options=['Inside', 'Outside'], inline='label_show', group=g6))
i_label_position        = f_get_label_position(i_label_position_y, i_label_position_s)
i_label_format_name     = input.bool(true, 'Name', inline='label_format', group=g6)
i_label_format_day      = input.bool(false, 'Day', inline='label_format', group=g6)
i_label_format_price    = input.bool(false, 'Price', inline='label_format', group=g6)
i_label_format_pips     = input.bool(false, 'Pips', inline='label_format', group=g6)

// Fibonacci levels
i_f_linestyle           = f_border_style(input.string(option_border_style1, title="Style", options=[option_border_style1, option_border_style2, option_border_style3], group=g7))
i_f_linewidth           = input.int(1, title="Thickness", minval=1, group=g7)

// Opening range
i_o_minutes             = input.int(15, title='Periods (minutes)', minval=1, step=1, group=g5)
i_o_minutes            := math.max(i_o_minutes, timeframe.multiplier + 1)
i_o_transp              = input.int(88, title='Transp', minval=0, maxval=100, step=1, group=g5)

// Alerts
i_alert1_show           = input.bool(false, 'Alerts - Sessions stard/end', group=g10)
i_alert2_show           = input.bool(false, 'Alerts - Opening range breakouts', group=g10)
i_alert3_show           = input.bool(false, 'Alerts - Price crossed session\'s High/Low after session closed', group=g10)

// ------------------------
// Drawing labels
// ------------------------
f_render_label (_show, _session, _is_started, _color, _top, _bottom, _text, _labels) =>
    var label my_label = na
    var int start_time = na

    v_position_y = (i_label_position_y == 'top') ? _top : _bottom
    v_label = array.new_string()
    v_chg = _top - _bottom
    
    if _is_started
        start_time := time
    
    if i_label_format_name and not na(_text)
        array.push(v_label, _text)

    if i_label_format_day
        array.push(v_label, util.get_day(dayofweek(start_time, i_tz)))

    if i_label_format_price
        array.push(v_label, str.format(fmt_price, v_chg))
    
    if i_label_format_pips
        array.push(v_label, str.format(fmt_pips, util.toPips(v_chg)) + ' pips')

    if _show
        if _is_started
            my_label := label.new(bar_index, v_position_y, array.join(v_label, icon_separator), textcolor=_color, color=color_none, size=i_label_size, style=i_label_position)
            
            array.push(_labels, my_label)

            util.clear_labels(_labels, i_history_period)

        else if _session
            label.set_y(my_label, v_position_y)
            label.set_text(my_label, array.join(v_label, icon_separator))

// ------------------------
// Drawing Fibonacci levels
// ------------------------
f_render_fibonacci (_show, _session, _is_started, _x1, _x2, _color, _top, _bottom, _level, _width, _style, _is_extend, _lines) =>
    var line my_line = na

    if _show
        y = (_top - _bottom) * _level + _bottom

        if _is_started
            my_line := line.new(_x1, y, _x2, y, width=_width, color=color.new(_color, 30), style=_style)
            array.push(_lines, my_line)

            if _is_extend
                line.set_extend(my_line, extend.right)

        else if _session
            line.set_y1(my_line, y)
            line.set_y2(my_line, y)

            f_set_line_x2(my_line, _x2)

// ------------------------
// Drawing Opening range
// ------------------------
f_render_oprange (_show, _session, _is_started, _x1, _x2, _color, _max, _is_extend, _boxes) =>
    var int start_time  = na
    var box my_box      = na

    top                 = ta.highest(high, _max)
    bottom              = ta.lowest(low, _max)
    is_crossover        = ta.crossover(close, box.get_top(my_box))
    is_crossunder       = ta.crossunder(close, box.get_bottom(my_box))
    
    if _show
        if _is_started
            util.clear_boxes(_boxes, math.max(0, i_history_period - 1))

            start_time  := time
            my_box      := na

        else if _session
            time_op = start_time + (i_o_minutes * 60 * 1000)
            time_op_delay = time_op - f_get_time_by_bar(1)
            
            if time <= time_op and time > time_op_delay
                my_box := box.new(_x1, top, _x2, bottom, border_width=0, bgcolor=color.new(_color, i_o_transp))
                array.push(_boxes, my_box)

                if _is_extend
                    box.set_extend(my_box, extend.right)
                    my_box

            else
                f_set_box_right(my_box, _x2)

                if is_crossover
                    alert('Price crossed over the opening range', alert.freq_once_per_bar)

                    if i_alert2_show
                        label.new(bar_index, box.get_top(my_box), "×", color=color.blue, textcolor=ac.tradingview('blue'), style=label.style_none, size=size.large)

                if is_crossunder
                    alert('Price crossed under the opening range', alert.freq_once_per_bar)

                    if i_alert2_show
                        label.new(bar_index, box.get_bottom(my_box), "×", color=color.red, textcolor=ac.tradingview('red'), style=label.style_none, size=size.large)

                my_box


// ------------------------
// Drawing candle
// ------------------------
f_render_candle (_show, _session, _is_started, _is_ended, _color, _top, _bottom, _open, _x1, _x2, _boxes, _lines) =>
    var box body = na
    var line wick1 = na
    var line wick2 = na

    border_width = i_candle_border_width
    cx = math.round(math.avg(_x2, _x1)) - math.round(border_width / 2)
    
    body_color = i_candle_color == option_candle_color2 ? close > _open ? i_candle_color_g : i_candle_color_r : _color
    
    if _show
        if _is_started
            body    := box.new(_x1, _top, _x2, _bottom, body_color, border_width, line.style_solid, bgcolor=color.new(color.black, 100))
            wick1   := i_show_candle_wick ? line.new(cx, _top, cx, _top, color=_color, width=border_width, style=line.style_solid) : na
            wick2   := i_show_candle_wick ? line.new(cx, _bottom, cx, _bottom, color=_color, width=border_width, style=line.style_solid) : na

            array.push(_boxes, body)
            array.push(_lines, wick1)
            array.push(_lines, wick2)

            util.clear_boxes(_boxes, i_history_period)
            util.clear_lines(_lines, i_history_period * 2)

        else if _session
            top    = math.max(_open, close)
            bottom = math.min(_open, close)

            box.set_top(body, top)
            box.set_bottom(body, bottom)
            box.set_right(body, _x2)
            box.set_border_color(body, body_color)
            
            line.set_y1(wick1, _top)
            line.set_y2(wick1, top)
            f_set_line_x1(wick1, cx)
            f_set_line_x2(wick1, cx)
            line.set_color(wick1, body_color)

            line.set_y1(wick2, _bottom)
            line.set_y2(wick2, bottom)
            f_set_line_x1(wick2, cx)
            f_set_line_x2(wick2, cx)
            line.set_color(wick2, body_color)

        else if _is_ended
            box.set_right(body, bar_index)
        

// ------------------------
// Rendering limit message
// ------------------------
f_render_limitmessage (_show, _session, _is_started, _is_ended, _x, _y, _rightbars) =>
    var label my_note = na

    if _show
        if _is_started
            if _rightbars > max_bars
                my_note := label.new(_x, _y, f_message_limit_bars(_rightbars), style=label.style_label_upper_left, color=color.yellow, textalign=text.align_left, yloc=yloc.price)

        else if _session
            if _rightbars > max_bars
                label.set_y(my_note, _y)
                label.set_text(my_note, f_message_limit_bars(_rightbars))
            else
                label.delete(my_note)

        else if _is_ended
            label.delete(my_note)
    true

// Rendering session
// 
f_render_sessionrange (_show, _session, _is_started, _is_ended, _color, _top, _bottom, _x1, _x2, _is_extend, _lines) =>
    var line above_line = na
    var line below_line = na

    if _show
        if _is_started
            above_line := line.new(_x1, _top, _x2, _top, width=i_sess_border_width, style=i_sess_border_style, color=_color)
            below_line := line.new(_x1, _bottom, _x2, _bottom, width=i_sess_border_width, style=i_sess_border_style, color=_color)
            linefill.new(above_line, below_line, color.new(_color, i_sess_bgopacity))

            array.push(_lines, above_line)
            array.push(_lines, below_line)

            util.clear_lines(_lines, i_history_period * 2)

            if _is_extend
                line.set_extend(above_line, extend.right)
                line.set_extend(below_line, extend.right)

        else if _session
            line.set_y1(above_line, _top)
            line.set_y2(above_line, _top)
            line.set_x2(above_line, _x2)

            line.set_y1(below_line, _bottom)
            line.set_y2(below_line, _bottom)
            line.set_x2(below_line, _x2)
            true
        else if _is_ended

            true
    true

// ------------------------
// Rendering session box
// ------------------------
f_render_session (_show, _session, _is_started, _is_ended, _color, _top, _bottom, _x1, _x2, _is_extend, _boxes) =>
    var box my_box = na

    if _show
        if _is_started
            my_box := box.new(_x1, _top, _x2, _bottom, _color, i_sess_border_width, i_sess_border_style, bgcolor=color.new(_color, i_sess_bgopacity))
            array.push(_boxes, my_box)

            util.clear_boxes(_boxes, i_history_period)

            if _is_extend
                box.set_extend(my_box, extend.right)

        else if _session
            box.set_top(my_box, _top)
            box.set_bottom(my_box, _bottom)
            f_set_box_right(my_box, _x2)

        else if _is_ended
            box.set_right(my_box, bar_index)

    my_box


// ------------------------
// Drawing market
// ------------------------
f_render_main (_show, _session, _is_started, _is_ended, _color, _top, _bottom) =>
    var box my_box = na
    var label my_note = na
    var x1 = 0
    var x2 = 0
    var session_open  = 0.0
    var session_high  = 0.0
    var session_low   = 0.0

    x0_1 = ta.valuewhen(na(_session[1]) and _session, bar_index, 1)
    x0_2 = ta.valuewhen(na(_session) and _session[1], bar_index, 0)
    x0_d = math.abs(x0_2 - x0_1)
    limit_bars = max_bars
    rightbars = x0_d

    if _show
        if _is_started
            x1 := bar_index
            x2 := bar_index + (math.min(x0_d, limit_bars))

            session_open := open
            session_high := _top
            session_low  := _bottom

        else if _session
            true_x2         = x1 + x0_d
            rightbars      := true_x2 - bar_index
            limit_bars     := bar_index + max_bars

            x2 := math.min(true_x2, limit_bars)

            session_high := _top
            session_low  := _bottom
        
        else if _is_ended
            session_open := na

    [x1, x2, session_open, session_high, session_low, rightbars]

// ------------------------
// Drawing
// ------------------------
draw (_show, _session, _color, _label, _extend, _show_fib, _show_op, _lookback, _boxes_session, _lines_session, _boxes_candle_body, _lines_candle_wick, _boxes_op, _lines_fib, _labels) =>
    max = f_get_period(_session, 1, _lookback)
    top = ta.highest(high, max)
    bottom = ta.lowest(low, max)
    
    is_started = f_get_started(_session)
    is_ended = f_get_ended(_session)
    is_extend = _extend != option_no

    [x1, x2, _open, _high, _low, _rightbars] = f_render_main(_show, _session, is_started, is_ended, _color, top, bottom)

    if i_sess_box_style == 'Box'
        f_render_session(_show, _session, is_started, is_ended, _color, top, bottom, x1, x2, is_extend, _boxes_session)

    if i_sess_box_style == 'Sandwich'
        f_render_sessionrange(_show, _session, is_started, is_ended, _color, top, bottom, x1, x2, is_extend, _lines_session)

    if i_show_candle
        f_render_candle(_show, _session, is_started, is_ended, _color, top, bottom, _open, x1, x2, _boxes_candle_body, _lines_candle_wick)

    if i_label_show
        f_render_label(_show, _session, is_started, _color, top, bottom, _label, _labels)

    if _show_op
        f_render_oprange(_show, _session, is_started, x1, x2, _color, max, is_extend, _boxes_op)

    if _show_fib
        f_render_fibonacci(_show, _session, is_started, x1, x2, _color, top, bottom, 0.500, 2, line.style_solid, is_extend, _lines_fib)
        f_render_fibonacci(_show, _session, is_started, x1, x2, _color, top, bottom, 0.628, i_f_linewidth, i_f_linestyle, is_extend, _lines_fib)
        f_render_fibonacci(_show, _session, is_started, x1, x2, _color, top, bottom, 0.382, i_f_linewidth, i_f_linestyle, is_extend, _lines_fib)
        util.clear_lines(_lines_fib, i_history_period * 3)
    
    f_render_limitmessage(_show, _session, is_started, is_ended, x1, bottom, _rightbars)

    [_session, _open, _high, _low]

///////////////////
// Calculating
///////////////////
string tz = (i_tz == option_no or i_tz == '') ? na : i_tz
int sess1 = time(timeframe.period, i_sess1, tz)
int sess2 = time(timeframe.period, i_sess2, tz)
int sess3 = time(timeframe.period, i_sess3, tz)
int sess4 = time(timeframe.period, i_sess4, tz)

///////////////////
// Plotting
///////////////////
var sess1_box           = array.new<box>()
var sess2_box           = array.new<box>()
var sess3_box           = array.new<box>()
var sess4_box           = array.new<box>()
var sess1_line          = array.new<line>()
var sess2_line          = array.new<line>()
var sess3_line          = array.new<line>()
var sess4_line          = array.new<line>()
var sess1_op            = array.new<box>()
var sess2_op            = array.new<box>()
var sess3_op            = array.new<box>()
var sess4_op            = array.new<box>()
var sess1_fib           = array.new<line>()
var sess2_fib           = array.new<line>()
var sess3_fib           = array.new<line>()
var sess4_fib           = array.new<line>()
var sess1_candle_body   = array.new<box>()
var sess2_candle_body   = array.new<box>()
var sess3_candle_body   = array.new<box>()
var sess4_candle_body   = array.new<box>()
var sess1_candle_wick   = array.new<line>()
var sess2_candle_wick   = array.new<line>()
var sess3_candle_wick   = array.new<line>()
var sess4_candle_wick   = array.new<line>()
var sess1_labels        = array.new<label>()
var sess2_labels        = array.new<label>()
var sess3_labels        = array.new<label>()
var sess4_labels        = array.new<label>()

[is_sess1, sess1_open, sess1_high, sess1_low] = draw(i_show_sess1, sess1, i_sess1_color, i_sess1_label, i_sess1_extend, i_sess1_fib, i_sess1_op, i_lookback, sess1_box, sess1_line, sess1_candle_body, sess1_candle_wick, sess1_op, sess1_fib, sess1_labels)
[is_sess2, sess2_open, sess2_high, sess2_low] = draw(i_show_sess2, sess2, i_sess2_color, i_sess2_label, i_sess2_extend, i_sess2_fib, i_sess2_op, i_lookback, sess2_box, sess2_line, sess2_candle_body, sess2_candle_wick, sess2_op, sess2_fib, sess2_labels)
[is_sess3, sess3_open, sess3_high, sess3_low] = draw(i_show_sess3, sess3, i_sess3_color, i_sess3_label, i_sess3_extend, i_sess3_fib, i_sess3_op, i_lookback, sess3_box, sess3_line, sess3_candle_body, sess3_candle_wick, sess3_op, sess3_fib, sess3_labels)
[is_sess4, sess4_open, sess4_high, sess4_low] = draw(i_show_sess4, sess4, i_sess4_color, i_sess4_label, i_sess4_extend, i_sess4_fib, i_sess4_op, i_lookback, sess4_box, sess4_line, sess4_candle_body, sess4_candle_wick, sess4_op, sess4_fib, sess4_labels)

is_positive_bar         = close > open

color c_barcolor        = na
color c_plotcandle      = na

c_sess1_barcolor        = (is_sess1) ? (is_positive_bar ? i_sess1_barcolor1 : i_sess1_barcolor2) : na
c_sess2_barcolor        = (is_sess2) ? (is_positive_bar ? i_sess2_barcolor1 : i_sess2_barcolor2) : na
c_sess3_barcolor        = (is_sess3) ? (is_positive_bar ? i_sess3_barcolor1 : i_sess3_barcolor2) : na
c_sess4_barcolor        = (is_sess4) ? (is_positive_bar ? i_sess4_barcolor1 : i_sess4_barcolor2) : na

if (i_sess1_chart != option_chart_x) and is_sess1
    c_barcolor         := i_sess1_barcolor ? c_sess1_barcolor : na
    c_plotcandle       := i_sess1_plotcandle ? c_sess1_barcolor : na

if (i_sess2_chart != option_chart_x) and is_sess2
    c_barcolor         := i_sess2_barcolor ? c_sess2_barcolor : na
    c_plotcandle       := i_sess2_plotcandle ? c_sess2_barcolor : na

if (i_sess3_chart != option_chart_x) and is_sess3
    c_barcolor         := i_sess3_barcolor ? c_sess3_barcolor : na
    c_plotcandle       := i_sess3_plotcandle ? c_sess3_barcolor : na

if (i_sess4_chart != option_chart_x) and is_sess4
    c_barcolor         := i_sess4_barcolor ? c_sess4_barcolor : na
    c_plotcandle       := i_sess4_plotcandle ? c_sess4_barcolor : na

barcolor(c_barcolor)
plotcandle(open, high, low, close, color=is_positive_bar ? color_none : c_plotcandle, bordercolor=c_plotcandle, wickcolor=c_plotcandle)


////////////////////
// Alerts
////////////////////
// Session alerts
sess1_started = is_sess1 and not is_sess1[1], sess1_ended = not is_sess1 and is_sess1[1]
sess2_started = is_sess2 and not is_sess2[1], sess2_ended = not is_sess2 and is_sess2[1]
sess3_started = is_sess3 and not is_sess3[1], sess3_ended = not is_sess3 and is_sess3[1]
sess4_started = is_sess4 and not is_sess4[1], sess4_ended = not is_sess4 and is_sess4[1]

alertcondition(sess1_started,   'Session #1 started')
alertcondition(sess1_ended,     'Session #1 ended')
alertcondition(sess2_started,   'Session #2 started')
alertcondition(sess2_ended,     'Session #2 ended')
alertcondition(sess3_started,   'Session #3 started')
alertcondition(sess3_ended,     'Session #3 ended')
alertcondition(sess4_started,   'Session #4 started')
alertcondition(sess4_ended,     'Session #4 ended')

alertcondition((not is_sess1) and ta.crossover(close, sess1_high), 'Session #1 High crossed (after session closed)')
alertcondition((not is_sess1) and ta.crossunder(close, sess1_low), 'Session #1 Low crossed (after session closed)')
alertcondition((not is_sess2) and ta.crossover(close, sess2_high), 'Session #2 High crossed (after session closed)')
alertcondition((not is_sess2) and ta.crossunder(close, sess2_low), 'Session #2 Low crossed (after session closed)')
alertcondition((not is_sess3) and ta.crossover(close, sess3_high), 'Session #3 High crossed (after session closed)')
alertcondition((not is_sess3) and ta.crossunder(close, sess3_low), 'Session #3 Low crossed (after session closed)')
alertcondition((not is_sess4) and ta.crossover(close, sess4_high), 'Session #4 High crossed (after session closed)')
alertcondition((not is_sess4) and ta.crossunder(close, sess4_low), 'Session #4 Low crossed (after session closed)')

// Alerts visualized
if i_alert1_show
    if i_show_sess1
        if sess1_started
            label.new(bar_index, close, 'Start', yloc=yloc.abovebar, color=i_sess1_color, textcolor=color_text, size=size.small, style=label.style_label_down)
        if sess1_ended
            label.new(bar_index, close, 'End'  , yloc=yloc.abovebar, color=i_sess1_color, textcolor=color_text, size=size.small, style=label.style_label_down)
    if i_show_sess2
        if sess2_started
            label.new(bar_index, close, 'Start', yloc=yloc.abovebar, color=i_sess2_color, textcolor=color_text, size=size.small, style=label.style_label_down)
        if sess2_ended
            label.new(bar_index, close, 'End'  , yloc=yloc.abovebar, color=i_sess2_color, textcolor=color_text, size=size.small, style=label.style_label_down)
    if i_show_sess3
        if sess3_started
            label.new(bar_index, close, 'Start', yloc=yloc.abovebar, color=i_sess3_color, textcolor=color_text, size=size.small, style=label.style_label_down)
        if sess3_ended
            label.new(bar_index, close, 'End'  , yloc=yloc.abovebar, color=i_sess3_color, textcolor=color_text, size=size.small, style=label.style_label_down)
    if i_show_sess4
        if sess4_started
            label.new(bar_index, close, 'Start', yloc=yloc.abovebar, color=i_sess4_color, textcolor=color_text, size=size.small, style=label.style_label_down)
        if sess4_ended
            label.new(bar_index, close, 'End'  , yloc=yloc.abovebar, color=i_sess4_color, textcolor=color_text, size=size.small, style=label.style_label_down)

plot(i_alert3_show ? sess1_high : na, 'sess1_high', style=plot.style_linebr, color=i_sess1_color)
plot(i_alert3_show ? sess1_low  : na, 'sess1_low' , style=plot.style_linebr, color=i_sess1_color, linewidth=2)
plot(i_alert3_show ? sess2_high : na, 'sess2_high', style=plot.style_linebr, color=i_sess2_color)
plot(i_alert3_show ? sess2_low  : na, 'sess2_low' , style=plot.style_linebr, color=i_sess2_color, linewidth=2)
plot(i_alert3_show ? sess3_high : na, 'sess3_high', style=plot.style_linebr, color=i_sess3_color)
plot(i_alert3_show ? sess3_low  : na, 'sess3_low' , style=plot.style_linebr, color=i_sess3_color, linewidth=2)
plot(i_alert3_show ? sess4_high : na, 'sess4_high', style=plot.style_linebr, color=i_sess4_color)
plot(i_alert3_show ? sess4_low  : na, 'sess4_low' , style=plot.style_linebr, color=i_sess4_color, linewidth=2)

plotshape(i_alert3_show and (not is_sess1) and ta.crossover(close, sess1_high) ? sess1_high : na, 'cross sess1_high', color=i_sess1_color, style=shape.triangleup, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess1) and ta.crossunder(close, sess1_low) ? sess1_low  : na, 'cross sess1_low', color=i_sess1_color, style=shape.triangledown, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess2) and ta.crossover(close, sess2_high) ? sess2_high : na, 'cross sess2_high', color=i_sess2_color, style=shape.triangleup, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess2) and ta.crossunder(close, sess2_low) ? sess2_low  : na, 'cross sess2_low', color=i_sess2_color, style=shape.triangledown, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess3) and ta.crossover(close, sess3_high) ? sess3_high : na, 'cross sess3_high', color=i_sess3_color, style=shape.triangleup, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess3) and ta.crossunder(close, sess3_low) ? sess3_low  : na, 'cross sess3_low', color=i_sess3_color, style=shape.triangledown, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess4) and ta.crossover(close, sess4_high) ? sess4_high : na, 'cross sess4_high', color=i_sess4_color, style=shape.triangleup, location=location.absolute, size=size.tiny)
plotshape(i_alert3_show and (not is_sess4) and ta.crossunder(close, sess4_low) ? sess4_low  : na, 'cross sess4_low', color=i_sess4_color, style=shape.triangledown, location=location.absolute, size=size.tiny)
````

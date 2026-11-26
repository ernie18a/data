# MTF FVG MODULE(NITIN)

- url: https://www.tradingview.com/script/7jSqvLWe-MTF-FVG-MODULE-NITIN/
- type: indicator
- pine_id: PUB;907cab22950945c98c203346a17de237
- version: 2.0

## Description

The MTF FVG MODULE(NITIN) is a highly optimized TradingView indicator designed to automatically detect, visualize, and manage Fair Value Gaps (FVGs) across multiple timeframes.

Key Features at a Glance:

Multi-Timeframe (MTF) Overlay: Project higher-timeframe FVGs (like 1H or Daily) directly onto your current, lower-timeframe chart.

Smart Mitigation: The indicator actively monitors price action—automatically shrinking, recoloring, or deleting FVG boxes as price taps into or fully fills the gap.

Deep Customization: Full control over box extensions, background colors, custom border colors/thickness, and detailed text labels (displaying the origin timeframe and exact gap size in points).

Lag-Free Performance: Uses dynamic request logic to only calculate the specific timeframes you have enabled, keeping your charts clean and fast.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

// ==== SPEED FIX: dynamic_requests=true allows the engine to skip disabled timeframes entirely ====
indicator("FVG Module (Standalone)", overlay=true, max_boxes_count=500, max_lines_count=500, dynamic_requests=true)

// ============================================================================
// 🎛️ MASTER SWITCHES & VISIBILITY RANGES
// ============================================================================
enable_fvg  = input.bool(true, "Enable FVG Module", group="Master Switches")
fvg_min_tf  = input.string("1", "FVG Min Timeframe", options=["1", "3", "5", "15", "30", "45", "60", "240", "D", "W", "M"], inline="fvg_tf", group="Master Switches")
fvg_max_tf  = input.string("W", "to Max:", options=["1", "3", "5", "15", "30", "45", "60", "240", "D", "W", "M"], inline="fvg_tf", group="Master Switches")

current_tf_sec = timeframe.in_seconds(timeframe.period)
is_fvg_tf   = current_tf_sec >= timeframe.in_seconds(fvg_min_tf) and current_tf_sec <= timeframe.in_seconds(fvg_max_tf)

// ============================================================================
// ============================== FVG SETTINGS ================================
// ============================================================================
show_mtf        = input.bool(false, "Show MTF (Multi-Timeframe) FVGs", group='FVG - General', tooltip="If unchecked, ignores the timeframes below and ONLY draws FVGs for your current chart timeframe.")
changelvl       = input.bool(false, "Move box levels with price touch", group='FVG - General')
changecolor     = input.bool(false, "Change box color with price touch", group='FVG - General')
extend_r        = input.bool(true, "Extend boxes to the right", group='FVG - General')
delete_old      = input.bool(false, "Delete fully mitigated FVGs", group='FVG - General')

fvg_width_mult  = input.int(2, "Unextended FVG Width (1x-10x)", minval=1, maxval=10, group='FVG - General', tooltip="Only applies if 'Extend boxes to the right' is turned OFF.")

plotLabel       = input.bool(defval=false, title='Plot OB Label', inline='FVG label', group='FVG - Style')
show_size       = input.bool(defval=true, title='Plot FVG Size (Points)', inline='FVG label', group='FVG - Style')
LabelColor      = input.color(defval=color.gray, title='Color', inline='FVG label', group='FVG - Style')
LabelSize       = input.string(defval=size.tiny, title="Size", options=[size.huge, size.large, size.small, size.tiny, size.auto, size.normal], inline='FVG label', group='FVG - Style')

// --- INTERNAL FALLBACK COLORS ---
BullColor       = color.new(color.green, 90)
BearColor       = color.new(color.red, 90)
BullColorTested = color.new(color.gray, 90)
BearColorTested = color.new(color.gray, 90)

// --- BORDER SETTINGS ---
BullBorderColor = input.color(defval=color.new(color.green, 50), title='Bullish Border Color', inline='Border Color', group='FVG - Style')
BearBorderColor = input.color(defval=color.new(color.red, 50), title='Bearish Border Color', inline='Border Color', group='FVG - Style')
BorderWidth     = input.int(defval=1, title="Border Thickness", minval=0, maxval=10, group='FVG - Style')

// --- NEW MIDLINE SETTINGS ---
show_midline    = input.bool(defval=true, title='Show FVG Midline', inline='Midline', group='FVG - Style')
MidlineColor    = input.color(defval=color.new(color.white, 50), title='Color', inline='Midline', group='FVG - Style')
MidlineStyleStr = input.string(defval="Dotted", title="Style", options=["Solid", "Dotted", "Dashed"], inline='Midline', group='FVG - Style')

MidlineStyle = MidlineStyleStr == "Solid" ? line.style_solid : MidlineStyleStr == "Dotted" ? line.style_dashed : line.style_dotted

// ============================================================================
// ========================== FVG SPECIFIC MTF COLORS =========================
// ============================================================================
use_custom_mtf_cols = input.bool(true, "Enable Custom MTF Colors", group='FVG - MTF Colors')

custom_tf_1 = input.string("5", "TF 1", options=["1", "3", "5", "15", "30", "45", "60", "240", "D", "W", "M"], inline='tf1', group='FVG - MTF Colors')
BullColor1  = input.color(defval=color.new(color.blue, 80), title='Bull', inline='tf1', group='FVG - MTF Colors')
BearColor1  = input.color(defval=color.new(color.orange, 80), title='Bear', inline='tf1', group='FVG - MTF Colors')

custom_tf_2 = input.string("15", "TF 2", options=["1", "3", "5", "15", "30", "45", "60", "240", "D", "W", "M"], inline='tf2', group='FVG - MTF Colors')
BullColor2  = input.color(defval=color.new(color.purple, 80), title='Bull', inline='tf2', group='FVG - MTF Colors')
BearColor2  = input.color(defval=color.new(color.fuchsia, 80), title='Bear', inline='tf2', group='FVG - MTF Colors')

custom_tf_3 = input.string("60", "TF 3", options=["1", "3", "5", "15", "30", "45", "60", "240", "D", "W", "M"], inline='tf3', group='FVG - MTF Colors')
BullColor3  = input.color(defval=color.new(color.yellow, 80), title='Bull', inline='tf3', group='FVG - MTF Colors')
BearColor3  = input.color(defval=color.new(color.navy, 80), title='Bear', inline='tf3', group='FVG - MTF Colors')

// ============================================================================
// ============================== FVG TIMEFRAMES ==============================
// ============================================================================
tf1_in  = input.bool(false, "1", group='FVG - Timeframes')
tf2_in  = input.bool(true, "3", group='FVG - Timeframes')
tf3_in  = input.bool(false, "5", group='FVG - Timeframes')
tf4_in  = input.bool(true, "15", group='FVG - Timeframes')
tf5_in  = input.bool(false, "30", group='FVG - Timeframes')
tf6_in  = input.bool(false, "45", group='FVG - Timeframes')
tf7_in  = input.bool(true, "60", group='FVG - Timeframes')
tf10_in = input.bool(false, "240", group='FVG - Timeframes')
tf11_in = input.bool(false, "D", group='FVG - Timeframes')
tf12_in = input.bool(false, "W", group='FVG - Timeframes')

hide_lower_mtf = input.bool(true, "Hide MTF FVGs Lower Than Chart TF", group='FVG - Timeframes', tooltip="If ON, viewing a 5m chart will automatically hide 1m and 3m FVGs. Viewing a 15m chart will hide 1m, 3m, and 5m FVGs.")

// ============================================================================
// ============================== FVG ENGINE ==================================
// ============================================================================
var box[] bull_box  = array.new_box()
var box[] bear_box  = array.new_box()
var line[] bull_line = array.new_line()
var line[] bear_line = array.new_line()

// --- ANTI-DUPLICATE TRACKERS ---
var int last_tf1_time = na
var int last_tf2_time = na
var int last_tf3_time = na
var int last_tf4_time = na
var int last_tf5_time = na
var int last_tf6_time = na
var int last_tf7_time = na
var int last_tf10_time = na
var int last_tf11_time = na
var int last_tf12_time = na

tf1  = show_mtf and tf1_in  and (not hide_lower_mtf or timeframe.in_seconds("1") >= current_tf_sec)
tf2  = show_mtf and tf2_in  and (not hide_lower_mtf or timeframe.in_seconds("3") >= current_tf_sec)
tf3  = show_mtf and tf3_in  and (not hide_lower_mtf or timeframe.in_seconds("5") >= current_tf_sec)
tf4  = show_mtf and tf4_in  and (not hide_lower_mtf or timeframe.in_seconds("15") >= current_tf_sec)
tf5  = show_mtf and tf5_in  and (not hide_lower_mtf or timeframe.in_seconds("30") >= current_tf_sec)
tf6  = show_mtf and tf6_in  and (not hide_lower_mtf or timeframe.in_seconds("45") >= current_tf_sec)
tf7  = show_mtf and tf7_in  and (not hide_lower_mtf or timeframe.in_seconds("60") >= current_tf_sec)
tf10 = show_mtf and tf10_in and (not hide_lower_mtf or timeframe.in_seconds("240") >= current_tf_sec)
tf11 = show_mtf and tf11_in and (not hide_lower_mtf or timeframe.in_seconds("D") >= current_tf_sec)
tf12 = show_mtf and tf12_in and (not hide_lower_mtf or timeframe.in_seconds("W") >= current_tf_sec)

find_box() =>
    int x = 0
    float _top = na
    float _bottom = na
    int _time = na
    if barstate.isconfirmed
        x := low[2] >= high ? -1 : low >= high[2] ? 1 : 0
        _top := x > 0 ? low : x < 0 ? low[2] : 0
        _bottom := x > 0 ? high[2] : x < 0 ? high : 0
        _time := time[1]
    [_time, _top, _bottom, x]

create_box(_time, _top, _bottom, x, TF) =>
    color active_bull = BullColor
    color active_bear = BearColor
    
    if use_custom_mtf_cols
        if TF == custom_tf_1
            active_bull := BullColor1
            active_bear := BearColor1
        else if TF == custom_tf_2
            active_bull := BullColor2
            active_bear := BearColor2
        else if TF == custom_tf_3
            active_bull := BullColor3
            active_bear := BearColor3
            
    _col = x > 0 ? active_bull : active_bear
    _border_col = x > 0 ? BullBorderColor : BearBorderColor 
    _extend = extend.none
    
    string _text = na
    if plotLabel or show_size
        string lbl = plotLabel ? TF : ""
        float ticks = (_top - _bottom) / syminfo.mintick
        float points = ticks / 100
        string sz  = show_size ? "(" + str.tostring(points, "#.##") + ")" : ""
        if plotLabel and show_size
            _text := lbl + "\n" + sz
        else if plotLabel
            _text := lbl
        else if show_size
            _text := sz

    box boxOB = na
    line lineOB = na

    if x != 0 and not na(_time)
        _right_time = extend_r ? time : time + ((time - _time) * (fvg_width_mult - 1))
        boxOB := box.new(left=_time, top=_top, right=_right_time, extend=_extend , bottom=_bottom, bgcolor=_col, border_color=_border_col, border_width=BorderWidth, text=_text, text_halign=text.align_right, text_size=LabelSize, text_color=LabelColor, xloc = xloc.bar_time)
        
        if show_midline
            float _mid = (_top + _bottom) / 2
            lineOB := line.new(x1=_time, y1=_mid, x2=_right_time, y2=_mid, color=MidlineColor, style=MidlineStyle, extend=_extend, xloc=xloc.bar_time)

    if x > 0 and not na(boxOB)
        array.push(bull_box, boxOB)
        array.push(bull_line, lineOB)
    if x < 0 and not na(boxOB)
        array.push(bear_box, boxOB)
        array.push(bear_line, lineOB)

control_box(_boxes, _lines, bearbull) =>
    if array.size(_boxes) > 0
        for i = array.size(_boxes) - 1 to 0 by 1
            _box = array.get(_boxes, i)
            _line = array.get(_lines, i)
            _boxLow = box.get_bottom(_box)
            _boxHigh = box.get_top(_box)
            
            if (bearbull > 0 and low < _boxLow) or (bearbull < 0 and high > _boxHigh)
                if delete_old
                    box.delete(_box)
                    if not na(_line)
                        line.delete(_line)
                else
                    box.set_extend(_box, extend.none)
                    if not na(_line)
                        line.set_extend(_line, extend.none)
                        
                    if extend_r or time < box.get_right(_box)
                        box.set_right(_box, time)
                        if not na(_line)
                            line.set_x2(_line, time)
                
                array.set(_boxes, i, na)
                array.set(_lines, i, na)
                
            else
                if bearbull > 0 and low < _boxHigh
                    if changelvl
                        box.set_top(_box, low)
                        if not na(_line)
                            _newMid = (low + box.get_bottom(_box)) / 2
                            line.set_y1(_line, _newMid)
                            line.set_y2(_line, _newMid)
                    if changecolor
                        box.set_bgcolor(_box, BullColorTested)    
                if bearbull < 0 and high > _boxLow
                    if changelvl
                        box.set_bottom(_box, high)
                        if not na(_line)
                            _newMid = (box.get_top(_box) + high) / 2
                            line.set_y1(_line, _newMid)
                            line.set_y2(_line, _newMid)
                    if changecolor
                        box.set_bgcolor(_box, BearColorTested)
                
                if extend_r
                    box.set_right(_box, time)
                    if not na(_line)
                        line.set_x2(_line, time)
                    
    if array.size(_boxes) > 0
        for i = array.size(_boxes) - 1 to 0 by 1
            if na(array.get(_boxes, i))
                array.remove(_boxes, i)
                array.remove(_lines, i)

if enable_fvg and is_fvg_tf
    [_time_curr, _top_curr, _bottom_curr, x_curr] = find_box()
    if not show_mtf and x_curr != 0
        create_box(_time_curr, _top_curr, _bottom_curr, x_curr, timeframe.period)

    if show_mtf
        if tf1
            [_t1, _tp1, _b1, _x1] = request.security(syminfo.tickerid, "1", find_box())
            if _x1 != 0 and (na(last_tf1_time) or _t1 != last_tf1_time)
                create_box(_t1, _tp1, _b1, _x1, "1")
                last_tf1_time := _t1
        if tf2
            [_t2, _tp2, _b2, _x2] = request.security(syminfo.tickerid, "3", find_box())
            if _x2 != 0 and (na(last_tf2_time) or _t2 != last_tf2_time)
                create_box(_t2, _tp2, _b2, _x2, "3")
                last_tf2_time := _t2
        if tf3
            [_t3, _tp3, _b3, _x3] = request.security(syminfo.tickerid, "5", find_box())
            if _x3 != 0 and (na(last_tf3_time) or _t3 != last_tf3_time)
                create_box(_t3, _tp3, _b3, _x3, "5")
                last_tf3_time := _t3
        if tf4
            [_t4, _tp4, _b4, _x4] = request.security(syminfo.tickerid, "15", find_box())
            if _x4 != 0 and (na(last_tf4_time) or _t4 != last_tf4_time)
                create_box(_t4, _tp4, _b4, _x4, "15")
                last_tf4_time := _t4
        if tf5
            [_t5, _tp5, _b5, _x5] = request.security(syminfo.tickerid, "30", find_box())
            if _x5 != 0 and (na(last_tf5_time) or _t5 != last_tf5_time)
                create_box(_t5, _tp5, _b5, _x5, "30")
                last_tf5_time := _t5
        if tf6
            [_t6, _tp6, _b6, _x6] = request.security(syminfo.tickerid, "45", find_box())
            if _x6 != 0 and (na(last_tf6_time) or _t6 != last_tf6_time)
                create_box(_t6, _tp6, _b6, _x6, "45")
                last_tf6_time := _t6
        if tf7
            [_t7, _tp7, _b7, _x7] = request.security(syminfo.tickerid, "60", find_box())
            if _x7 != 0 and (na(last_tf7_time) or _t7 != last_tf7_time)
                create_box(_t7, _tp7, _b7, _x7, "60")
                last_tf7_time := _t7
        if tf10
            [_t10, _tp10, _b10, _x10] = request.security(syminfo.tickerid, "240", find_box())
            if _x10 != 0 and (na(last_tf10_time) or _t10 != last_tf10_time)
                create_box(_t10, _tp10, _b10, _x10, "240")
                last_tf10_time := _t10
        if tf11
            [_t11, _tp11, _b11, _x11] = request.security(syminfo.tickerid, "D", find_box())
            if _x11 != 0 and (na(last_tf11_time) or _t11 != last_tf11_time)
                create_box(_t11, _tp11, _b11, _x11, "D")
                last_tf11_time := _t11
        if tf12
            [_t12, _tp12, _b12, _x12] = request.security(syminfo.tickerid, "W", find_box())
            if _x12 != 0 and (na(last_tf12_time) or _t12 != last_tf12_time)
                create_box(_t12, _tp12, _b12, _x12, "W")
                last_tf12_time := _t12

    control_box(bull_box, bull_line,  1)
    control_box(bear_box, bear_line, -1)
````

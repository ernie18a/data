# MELLO

- url: https://www.tradingview.com/script/aWhvlCxN-MELLO/
- type: indicator
- pine_id: PUB;7cb132e3d0654ab3ad31c9e250e5a7af
- version: 7.0

## Description

The Settings in the MELLO script is to show the Previous Day Session High and Low, as well as the Overnight Sessions and Midnight Point. The ASIA Session High and Low, and the London Session High and Low. These Levels are to give an educational area of interest about where the market made its Highest and Lowest Point in those sessions. These levels do not determine the market conditions. They are for educational purposes only and just marks the levels of Highs and Lows created during that session. The original indicator was created by @tradeforopp and customized to use the simple version for @mellotradez settings. Please use these levels at your own discretion as trading involves risks, and these levels will not provide any financial benefits.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradeforopp (Customized Defaults for @mellotradeX)

//@version=6
indicator("MELLO XT", "MELLO XT", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500) 

// ---------------------------------------- Constant Functions --------------------------------------------------
get_line_type(_style) =>
    switch _style
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed

get_size(x) =>
    switch x
        "Auto" => size.auto
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge

get_table_pos(pos) =>
    switch pos
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Top Right" => position.top_right
// ---------------------------------------- Constant Functions --------------------------------------------------


// ---------------------------------------- Inputs --------------------------------------------------
var g_SETTINGS      = "Settings"
max_days            = input.int(1, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, open lines, etc.)", group = g_SETTINGS)
tf_limit            = input.timeframe("240", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)
gmt_tz              = input.string('America/New_York', "Timezone", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip = "Note GMT is not adjusted to reflect Daylight Saving Time changes", group = g_SETTINGS)
lbl_size            = get_size(input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color           = input.color(color.white, "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff              = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzones"
use_asia            = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt              = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia                = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)
as_color            = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london          = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt              = input.string("London", "", inline = "LONDON", group = g_KZ)
london              = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)
lo_color            = input.color(color.red, "", inline = "LONDON", group = g_KZ)

use_ny              = input.bool(true, "", inline = "NY", group = g_KZ)
ny_txt              = input.string("6-7 AM", "", inline = "NY", group = g_KZ)
ny                  = input.session("0900-1000", "", inline = "NY", group = g_KZ)
ny_color            = input.color(#9C27B0, "", inline = "NY", group = g_KZ)

use_nypm            = input.bool(true, "", inline = "NYPM", group = g_KZ)
nypm_txt            = input.string("7-8 AM", "", inline = "NYPM", group = g_KZ)
nypm                = input.session("1000-1100", "", inline = "NYPM", group = g_KZ)
nypm_color          = input.color(#BA68C8, "", inline = "NYPM", group = g_KZ)


var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)
use_alerts          = input.bool(true, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS) 
show_labels         = input.bool(true, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level.", group = g_LABELS)
label_price         = input.bool(false, "Display Price", inline = "LB", group = g_LABELS)
ext_pivots          = input.string("Past Mitigation", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)
ext_which           = input.string("Most Recent", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS)

ash_str             = input.string("AS.H", "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str             = input.string("AS.L", "", inline = "L_AS", group = g_LABELS)

loh_str             = input.string("LO.H", "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str             = input.string("LO.L", "", inline = "L_LO", group = g_LABELS)

nyh_str             = input.string("6-7.H", "Killzone 3 Labels", inline = "L_NY", group = g_LABELS)
nyl_str             = input.string("6-7.L", "", inline = "L_NY", group = g_LABELS)

npmh_str            = input.string("7-8.H", "Killzone 4 Labels", inline = "L_PM", group = g_LABELS)
npml_str            = input.string("7-8.L", "", inline = "L_PM", group = g_LABELS)

kzp_style           = get_line_type(input.string('Solid', "Pivot Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS))
kzp_width           = input.int(2, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string('Dotted', "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)


var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip = "Show the most recent ranges of each selected killzone, from high to low", group = g_RNG)
show_range_avg      = input.bool(true, "Show Average", tooltip = "Show the average range of each selected killzone", group = g_RNG)
range_avg           = input.int(5, "Average Length", 0, tooltip = "This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group = g_RNG)
range_pos           = get_table_pos(input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG))
range_size          = get_size(input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG))


var g_DWM           = "Day - Week - Month"
show_d_open         = input.bool(false, "D Open", inline = "DO", group = g_DWM)
dhl                 = input.bool(true, "High/Low", inline = "DO", tooltip = "", group = g_DWM)
ds                  = input.bool(false, "Separators", inline = "DO", tooltip = "Mark where a new day begins", group = g_DWM)
d_color             = input.color(#00bcd4, "", inline = "DO", group = g_DWM)

show_w_open         = input.bool(false, "W Open", inline = "WO", group = g_DWM)
whl                 = input.bool(false, "High/Low", inline = "WO", tooltip = "", group = g_DWM)
ws                  = input.bool(false, "Separators", inline = "WO", tooltip = "Mark where a new week begins", group = g_DWM)
w_color             = input.color(#089981, "", inline = "WO", group = g_DWM)

show_m_open         = input.bool(false, "M Open", inline = "MO", group = g_DWM)
mhl                 = input.bool(false, "High/Low", inline = "MO", tooltip = "", group = g_DWM)
ms                  = input.bool(false, "Separators", inline = "MO", tooltip = "Mark where a new month begins", group = g_DWM)
m_color             = input.color(color.red, "", inline = "MO", group = g_DWM)

htf_style           = get_line_type(input.string('Solid', "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "D0", group = g_DWM))
htf_width           = input.int(2, "", inline = "D0", group = g_DWM)


var g_OPEN          = "Opening Prices"
use_h1              = input.bool(true, "", inline = "H1", group = g_OPEN)
h1_text             = input.string("MIDNIGHT", "", inline = "H1", group = g_OPEN)
h1                  = input.session("0000-0001", "", inline = "H1", group = g_OPEN)
h1_color            = input.color(color.purple, "", inline = "H1", group = g_OPEN)

use_h2              = input.bool(true, "", inline = "H2", group = g_OPEN)
h2_text             = input.string("NY OPEN", "", inline = "H2", group = g_OPEN)
h2                  = input.session("0930-0931", "", inline = "H2", group = g_OPEN)
h2_color            = input.color(color.green, "", inline = "H2", group = g_OPEN)

use_h3              = input.bool(false, "", inline = "H3", group = g_OPEN)
h3_text             = input.string("10:00", "", inline = "H3", group = g_OPEN)
h3                  = input.session("1000-1001", "", inline = "H3", group = g_OPEN)
h3_color            = input.color(color.black, "", inline = "H3", group = g_OPEN)

hz_style            = get_line_type(input.string('Solid', "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "H0", group = g_OPEN))
hz_width            = input.int(3, "", inline = "H0", group = g_OPEN)
// ---------------------------------------- Inputs --------------------------------------------------


type kz
    string _title
    array<box> _box
    array<line> _hi_line
    array<line> _md_line
    array<line> _lo_line
    array<label> _hi_label
    array<label> _lo_label
    array<bool> _hi_valid
    array<bool> _md_valid
    array<bool> _lo_valid
    array<float> _range_store
    float _range_current

type hz
    array<line> LN
    array<label> LB
    array<bool> CO

type dwm_hl
    array<line> hi_line
    array<line> lo_line
    array<label> hi_label
    array<label> lo_label
    bool hit_high = false
    bool hit_low = false

type dwm_info
    string tf
    float o = na
    float h = na
    float l = na
    float ph = na
    float pl = na

type lines_helper
    hz _hz
    string h
    string h_text
    color h_color

initLines() => 
    array<lines_helper> res = array.new<lines_helper>()
    if use_h1
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h1, h1_text, h1_color))
    if use_h2
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h2, h2_text, h2_color))
    if use_h3
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h3, h3_text, h3_color))
    res

var array<lines_helper> lines = initLines()

type kz_helper
    kz _kz
    string session
    color c
    string box_txt
    string hi_txt
    string lo_txt

initKZ() => 
    array<kz_helper> res = array.new<kz_helper>()
    if use_asia
        res.push(kz_helper.new(
             kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             asia, as_color, as_txt, ash_str, asl_str
         ))
    if use_london
        res.push(kz_helper.new(
             kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             london, lo_color, lo_txt, loh_str, lol_str
         ))
    if use_ny
        res.push(kz_helper.new(
             kz.new(ny_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             ny, ny_color, ny_txt, nyh_str, nyl_str
         ))
    if use_nypm
        res.push(kz_helper.new(
             kz.new(nypm_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nypm, nypm_color, nypm_txt, npmh_str, npml_str
         ))
    res

var array<kz_helper> _kz = initKZ()


var d_hl = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var w_hl = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var m_hl = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())

var d_info = dwm_info.new("D")
var w_info = dwm_info.new("W")
var m_info = dwm_info.new("M")

t_co = not na(time("", cutoff, gmt_tz))

var d_sep_line = array.new_line()
var w_sep_line = array.new_line()
var m_sep_line = array.new_line()

var d_line = array.new_line()
var w_line = array.new_line()
var m_line = array.new_line()

var d_label = array.new_label()
var w_label = array.new_label()
var m_label = array.new_label()

var transparent = #ffffff00
var ext_current = ext_which == 'Most Recent'
var ext_past = ext_pivots == 'Past Mitigation'

update_dwm_info(dwm_info n) =>
    if timeframe.change(n.tf)
        n.ph := n.h
        n.pl := n.l
        n.o := open
        n.h := high
        n.l := low
    else
        n.h := math.max(high, n.h)
        n.l := math.min(low, n.l)

if dhl or show_d_open
    update_dwm_info(d_info)
if whl or show_w_open
    update_dwm_info(w_info)
if mhl or show_m_open
    update_dwm_info(m_info)

get_box_color(color c) =>
    color.new(c, 70)

get_text_color(color c) =>
    color.new(c, 50)

dwm_sep(string tf, bool use, array<line> arr, color col) =>
    if use
        if timeframe.change(tf)
            arr.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style = htf_style, width = htf_width, extend = extend.both, color = col))
            if arr.size() > max_days
                arr.pop().delete()

dwm_open(string tf, bool use, array<line> lns, array<label> lbls, dwm_info n, color col) =>
    if use
        if lns.size() > 0
            lns.get(0).set_x2(time)
            lbls.get(0).set_x(time)
        if timeframe.change(tf)
            lns.unshift(line.new(time, n.o, time, n.o, xloc = xloc.bar_time, style = htf_style, width = htf_width, color = col))
            lbls.unshift(label.new(time, n.o, tf + " OPEN", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
            if lns.size() > max_days
                lns.pop().delete()
                lbls.pop().delete()

dwm_hl(string tf, bool use, dwm_hl hl, dwm_info n, color col) =>
    if use
        if hl.hi_line.size() > 0
            hl.hi_line.get(0).set_x2(time)
            hl.lo_line.get(0).set_x2(time)
            hl.hi_label.get(0).set_x(time)
            hl.lo_label.get(0).set_x(time)
        if timeframe.change(tf)
            hl.hi_line.unshift(line.new(time, n.ph, time, n.ph, xloc = xloc.bar_time, style = htf_style, width = htf_width, color = col))
            hl.lo_line.unshift(line.new(time, n.pl, time, n.pl, xloc = xloc.bar_time, style = htf_style, width = htf_width, color = col))
            hl.hi_label.unshift(label.new(time, n.ph, "P" + tf + "H", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
            hl.lo_label.unshift(label.new(time, n.pl, "P" + tf + "L", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
            hl.hit_high := false
            hl.hit_low := false
            if hl.hi_line.size() > max_days
                hl.hi_line.pop().delete()
                hl.lo_line.pop().delete()
                hl.hi_label.pop().delete()
                hl.lo_label.pop().delete()

dwm() =>
    if tf_limit_is_equal_or_more_chart_tf
        dwm_sep("D", ds, d_sep_line, d_color)
        dwm_sep("W", ws, w_sep_line, w_color)
        dwm_sep("M", ms, m_sep_line, m_color)
        dwm_open("D", show_d_open, d_line, d_label, d_info, d_color)
        dwm_open("W", show_w_open, w_line, w_label, w_info, w_color)
        dwm_open("M", show_m_open, m_line, m_label, m_info, m_color)
        dwm_hl("D", dhl, d_hl, d_info, d_color)
        dwm_hl("W", whl, w_hl, w_info, w_color)
        dwm_hl("M", mhl, m_hl, m_info, m_color)

method hz_line(lines_helper this) =>
    bool t = not na(time("", this.h, gmt_tz))
    bool t_prev = not na(time("", this.h, gmt_tz, bars_back = 1))
    hz hz = this._hz
    string txt = this.h_text
    color col = this.h_color
    if t and not t_prev
        hz.LN.unshift(line.new(bar_index, open, bar_index, open, style = hz_style, width = hz_width, color = col))
        hz.LB.unshift(label.new(bar_index, open, txt, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
        array.unshift(hz.CO, false)
        if hz.LN.size() > max_days
            hz.LN.pop().delete()
            hz.LB.pop().delete()
            hz.CO.pop()
    if not t and hz.CO.size() > 0
        if not hz.CO.get(0)
            hz.LN.get(0).set_x2(bar_index)
            hz.LB.get(0).set_x(bar_index)
            if (use_cutoff ? t_co : false)
                hz.CO.set(0, true)

hz_lines() =>
    if tf_limit_is_equal_or_more_chart_tf
        for [_, value] in lines
            hz_line(value)

del_kz(kz k) =>
    if k._box.size() > max_days
        k._box.pop().delete()
    if k._hi_line.size() > max_days
        k._hi_line.pop().delete()
        k._lo_line.pop().delete()
        k._hi_valid.pop()
        k._lo_valid.pop()
        if show_midpoints
            k._md_line.pop().delete()
            k._md_valid.pop()
    if k._hi_label.size() > max_days
        k._hi_label.pop().delete()
        k._lo_label.pop().delete()

update_price_string(label L, float P) =>
    S = L.get_text()
    pre = str.substring(S, 0, str.pos(S, " ")) 
    L.set_text(str.format("{0} ({1})", pre, P))

adjust_in_kz(kz kz, bool t) =>
    if t
        kzBox0 = kz._box.get(0)
        kzBox0.set_right(time)
        newTop = math.max(kzBox0.get_top(), high)
        kzBox0.set_top(newTop)
        newBottom = math.min(kzBox0.get_bottom(), low)
        kzBox0.set_bottom(newBottom)
        kz._range_current := newTop - newBottom
        if show_pivots and kz._hi_line.size() > 0
            kzHiLine0 = kz._hi_line.get(0)
            kzHiLine0.set_x2(time)
            if high > kzHiLine0.get_y1()
                kzHiLine0.set_xy1(time, high)
                kzHiLine0.set_xy2(time, high)
            kzLoLine0 = kz._lo_line.get(0)
            kzLoLine0.set_x2(time)
            if low < kzLoLine0.get_y1()
                kzLoLine0.set_xy1(time, low)
                kzLoLine0.set_xy2(time, low)
            if show_midpoints
                kzMidLine0 = kz._md_line.get(0)
                kzMidLine0.set_x2(time)
                kzMidLine0.set_xy1(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))
                kzMidLine0.set_xy2(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))
        if show_labels and kz._hi_label.size() > 0
            kz._hi_label.get(0).set_x(time)
            kz._lo_label.get(0).set_x(time)
            if high > kz._hi_label.get(0).get_y()
                kz._hi_label.get(0).set_xy(time, high)
                if label_price
                    update_price_string(kz._hi_label.get(0), high)
            if low < kz._lo_label.get(0).get_y()
                kz._lo_label.get(0).set_xy(time, low)
                if label_price
                    update_price_string(kz._lo_label.get(0), low)

adjust_out_kz(kz kz, bool t, bool t_prev) =>
    boxCount = kz._box.size()
    if not t and boxCount > 0
        if t_prev
            array.unshift(kz._range_store, kz._range_current)
            if kz._range_store.size() > range_avg
                kz._range_store.pop()
    if show_pivots and boxCount > 0
        for i = 0 to boxCount - 1 by 1
            if not ext_current or i == 0
                kzHiValid = kz._hi_valid.get(i)
                if ext_past or kzHiValid
                    kz._hi_line.get(i).set_x2(time)
                    kz._hi_label.get(i).set_x(time)
                if kzHiValid and high > kz._hi_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert('Broke ' + kz._title + ' High', alert.freq_once_per_bar)
                    kz._hi_valid.set(i, false)
                else if use_cutoff ? t_co : false
                    kz._hi_valid.set(i, false)
                kzLoValid = kz._lo_valid.get(i)
                if ext_past or kzLoValid
                    kz._lo_line.get(i).set_x2(time)
                    kz._lo_label.get(i).set_x(time)
                if kzLoValid and low < kz._lo_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert("Broke " + kz._title + " Low", alert.freq_once_per_bar)
                    kz._lo_valid.set(i, false)
                else if use_cutoff ? t_co : false
                    kz._lo_valid.set(i, false)
                if show_midpoints and not t
                    if stop_midpoints ? kz._md_valid.get(i) : true
                        kz._md_line.get(i).set_x2(time)
                        if kz._md_valid.get(i) and low <= kz._md_line.get(i).get_y1() and high >= kz._md_line.get(i).get_y1()
                            kz._md_valid.set(i, false)
            else
                break

method manage_kz(kz_helper this) =>
    kz kz = this._kz    
    c = this.c
    string box_txt = this.box_txt
    string hi_txt = this.hi_txt
    string lo_txt = this.lo_txt
    if tf_limit_is_equal_or_more_chart_tf
        t = not na(time("", this.session, gmt_tz))
        t_prev = not na(time("", this.session, gmt_tz, bars_back = 1))
        if t and not t_prev
            kz._box.unshift(box.new(time, high, time, low, xloc = xloc.bar_time, border_color = na, bgcolor = na))
            if show_pivots
                kz._hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                kz._lo_line.unshift(line.new(time, low, time, low, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                if show_midpoints
                    kz._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc = xloc.bar_time, style = kzm_style, color = c, width = kzm_width))
                    array.unshift(kz._md_valid, true)
                array.unshift(kz._hi_valid, true)
                array.unshift(kz._lo_valid, true)
                if show_labels
                    _hi_txt = label_price ? str.format('{0} ({1})', hi_txt, high) : hi_txt
                    _lo_txt = label_price ? str.format('{0} ({1})', lo_txt, low) : lo_txt
                    kz._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                    kz._lo_label.unshift(label.new(time, low, _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
            del_kz(kz)
        adjust_in_kz(kz, t)
        adjust_out_kz(kz, t, t_prev)

for [_, value] in _kz
    manage_kz(value)

dwm()
hz_lines()

get_min_days_stored() =>
    store = array.new_int()
    for [_, value] in _kz
        int tmpStoreSize = value._kz._range_store.size()
        if tmpStoreSize > 0
            store.push(tmpStoreSize) 
    store.min()

method set_table(table tbl, kz kz, int row, string txt, bool t, color col) =>
    table.cell(tbl, 0, row, txt, text_size = range_size, bgcolor = get_box_color(col), text_color = txt_color)
    table.cell(tbl, 1, row, str.tostring(kz._range_current), text_size = range_size, bgcolor = t ? get_box_color(col) : na, text_color = txt_color)
    if show_range_avg
        table.cell(tbl, 2, row, str.tostring(kz._range_store.avg()), text_size = range_size, text_color = txt_color)

if show_range and barstate.islast
    var tbl = table.new(range_pos, 10, 10, chart.bg_color, chart.fg_color, 2, chart.fg_color, 1)
    table.cell(tbl, 0, 0, "Killzone", text_size = range_size, text_color = txt_color)
    table.cell(tbl, 1, 0, "Range", text_size = range_size, text_color = txt_color)
    if show_range_avg
        table.cell(tbl, 2, 0, "Avg (" + str.tostring(get_min_days_stored()) + ")", text_size = range_size, text_color = txt_color)
    for [index, value] in _kz
        set_table(tbl, value._kz, index + 1, value.box_txt, not na(time("", value.session, gmt_tz)), value.c)
````

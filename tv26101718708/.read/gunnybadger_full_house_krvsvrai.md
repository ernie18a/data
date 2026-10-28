# GunnyBadger Full House

- url: https://www.tradingview.com/script/kRVsVRai-GunnyBadger-Full-House/
- type: indicator
- pine_id: PUB;567781d5b0df4cbbb97faff4c45e6f7b
- version: 1.0

## Description

This Indicator Uses ICT concepts to analyze market. It prints FVGs IFVGs Liquidity and HTF candles making it easy for analysis.

## Source Code

````pine
//@version=5
indicator("ICT Engine: Master Pro", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=100)

// --- INPUTS ---
bsl_color = input.color(color.red, "BSL Color")
ssl_color = input.color(color.green, "SSL Color")
mitigated_col = input.color(color.gray, "Mitigated Color")

// --- STORAGE ---
var line[] bsl_lines = array.new_line(0)
var line[] ssl_lines = array.new_line(0)
var bool[] bsl_mitigated = array.new_bool(0)
var bool[] ssl_mitigated = array.new_bool(0)

swing_len = 5
p_high = ta.pivothigh(high, swing_len, swing_len)
p_low  = ta.pivotlow(low, swing_len, swing_len)

// Add Lines
if not na(p_high)
    array.push(bsl_lines, line.new(bar_index-swing_len, p_high, bar_index, p_high, color=bsl_color, style=line.style_dashed))
    array.push(bsl_mitigated, false)

if not na(p_low)
    array.push(ssl_lines, line.new(bar_index-swing_len, p_low, bar_index, p_low, color=ssl_color, style=line.style_dashed))
    array.push(ssl_mitigated, false)

// Update & Freeze Lines
if array.size(bsl_lines) > 0
    for i = 0 to array.size(bsl_lines) - 1
        l = array.get(bsl_lines, i)
        if not array.get(bsl_mitigated, i)
            line.set_x2(l, bar_index)
            if high > line.get_y1(l)
                line.set_color(l, mitigated_col)
                array.set(bsl_mitigated, i, true)

if array.size(ssl_lines) > 0
    for i = 0 to array.size(ssl_lines) - 1
        l = array.get(ssl_lines, i)
        if not array.get(ssl_mitigated, i)
            line.set_x2(l, bar_index)
            if low < line.get_y1(l)
                line.set_color(l, mitigated_col)
                array.set(ssl_mitigated, i, true)

// --- FVG & IFVG ENGINE WITH LABELS ---
var box current_fvg = na
var label current_label = na
var int fvg_type = 0 

if low > high[2] and fvg_type != 1
    current_fvg := box.new(bar_index-2, low, bar_index, high[2], border_color=color.rgb(21, 252, 0), bgcolor=color.new(#02fc0a, 65))
    current_label := label.new(bar_index-1, (low + high[2])/2, "FVG", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none)
    fvg_type := 1
else if high < low[2] and fvg_type != -1
    current_fvg := box.new(bar_index-2, low[2], bar_index, high, border_color=color.rgb(250, 2, 2), bgcolor=color.new(#ff0202, 80))
    current_label := label.new(bar_index-1, (low[2] + high)/2, "FVG", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none)
    fvg_type := -1

if not na(current_fvg)
    box.set_right(current_fvg, bar_index)
    if fvg_type == 1 and close < box.get_bottom(current_fvg)
        box.set_border_color(current_fvg, color.rgb(133, 0, 71))
        box.set_bgcolor(current_fvg, color.new(#970051, 51))
        label.set_text(current_label, "IFVG")
        fvg_type := -2
    else if fvg_type == -1 and close > box.get_top(current_fvg)
        box.set_border_color(current_fvg, color.rgb(0, 248, 128))
        box.set_bgcolor(current_fvg, color.new(#00e677, 57))
        label.set_text(current_label, "IFVG")
        fvg_type := 2
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
max_days            = input.int(3, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, open lines, etc.)", group = g_SETTINGS)
tf_limit            = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)
gmt_tz              = input.string('America/New_York', "Timezone", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip = "Note GMT is not adjusted to reflect Daylight Saving Time changes", group = g_SETTINGS)
lbl_size            = get_size(input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color           = input.color(color.black, "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff              = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzones"
show_kz             = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ)
show_kz_text        = input.bool(true, "Display Text", inline = "KZ", group = g_KZ)

use_asia            = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt              = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia                = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)
as_color            = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london          = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt              = input.string("London", "", inline = "LONDON", group = g_KZ)
london              = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)
lo_color            = input.color(color.red, "", inline = "LONDON", group = g_KZ)

use_nyam            = input.bool(true, "", inline = "NYAM", group = g_KZ)
na_txt              = input.string("NY AM", "", inline = "NYAM", group = g_KZ)
nyam                = input.session("0930-1100", "", inline = "NYAM", group = g_KZ)
na_color            = input.color(#089981, "", inline = "NYAM", group = g_KZ)

use_nylu            = input.bool(true, "", inline = "NYLU", group = g_KZ)
nl_txt              = input.string("NY Lunch", "", inline = "NYLU", group = g_KZ)
nylu                = input.session("1200-1300", "", inline = "NYLU", group = g_KZ)
nl_color            = input.color(color.yellow, "", inline = "NYLU", group = g_KZ)

use_nypm            = input.bool(true, "", inline = "NYPM", group = g_KZ)
np_txt              = input.string("NY PM", "", inline = "NYPM", group = g_KZ)
nypm                = input.session("1330-1600", "", inline = "NYPM", group = g_KZ)
np_color            = input.color(color.purple, "", inline = "NYPM", group = g_KZ)

box_transparency    = input.int(70, "Box Transparency", 0, 100, group = g_KZ)
text_transparency   = input.int(50, "Text Transparency", 0, 100, group = g_KZ)


var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)
use_alerts          = input.bool(true, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS) 
show_labels         = input.bool(true, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group = g_LABELS)
label_price         = input.bool(false, "Display Price", inline = "LB", group = g_LABELS)
label_right         = input.bool(false, "Right Side", inline = "LB", group = g_LABELS)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)
ext_which           = input.string("Most Recent", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS)

ash_str             = input.string("AS.H", "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str             = input.string("AS.L", "", inline = "L_AS", group = g_LABELS)

loh_str             = input.string("LO.H", "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str             = input.string("LO.L", "", inline = "L_LO", group = g_LABELS)

nah_str             = input.string("NYAM.H", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)
nal_str             = input.string("NYAM.L", "", inline = "L_NA", group = g_LABELS)

nlh_str             = input.string("NYL.H", "Killzone 4 Labels", inline = "L_NL", group = g_LABELS)
nll_str             = input.string("NYL.L", "", inline = "L_NL", group = g_LABELS)

nph_str             = input.string("NYPM.H", "Killzone 5 Labels", inline = "L_NP", group = g_LABELS)
npl_str             = input.string("NYPM.L", "", inline = "L_NP", group = g_LABELS)

kzp_style           = get_line_type(input.string(defval = 'Solid', title = "Pivot Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS))
kzp_width           = input.int(1, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string(defval = 'Dotted', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)


var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip = "Show the most recent ranges of each selected killzone, from high to low", group = g_RNG)
show_range_avg      = input.bool(true, "Show Average", tooltip = "Show the average range of each selected killzone", group = g_RNG)
range_avg           = input.int(5, "Average Length", 0, tooltip = "This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group = g_RNG)
range_pos           = get_table_pos(input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG))
range_size          = get_size(input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG))


var g_DWM           = "Day - Week - Month"
sep_unlimited       = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_DWM)
alert_HL            = input.bool(false, "Alert High/Low Break", tooltip = "Alert when any selected highs and lows are traded through. The desired timeframe's high/low option must be enabled at the time that an alert is created", group = g_DWM)

show_d_open         = input.bool(false, "D Open", inline = "DO", group = g_DWM)
dhl                 = input.bool(false, "High/Low", inline = "DO", tooltip = "", group = g_DWM)
ds                  = input.bool(false, "Separators", inline = "DO", tooltip = "Mark where a new day begins", group = g_DWM)
d_color             = input.color(color.blue, "", inline = "DO", group = g_DWM)

show_w_open         = input.bool(false, "W Open", inline = "WO", group = g_DWM)
whl                 = input.bool(false, "High/Low", inline = "WO", tooltip = "", group = g_DWM)
ws                  = input.bool(false, "Separators", inline = "WO", tooltip = "Mark where a new week begins", group = g_DWM)
w_color             = input.color(#089981, "", inline = "WO", group = g_DWM)

show_m_open         = input.bool(false, "M Open", inline = "MO", group = g_DWM)
mhl                 = input.bool(false, "High/Low", inline = "MO", tooltip = "", group = g_DWM)
ms                  = input.bool(false, "Separators", inline = "MO", tooltip = "Mark where a new month begins", group = g_DWM)
m_color             = input.color(color.red, "", inline = "MO", group = g_DWM)

htf_style           = get_line_type(input.string(defval = 'Solid', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "D0", group = g_DWM))
htf_width           = input.int(1, "", inline = "D0", group = g_DWM)

dow_labels          = input.bool(true, "Day of Week Labels", inline = "DOW", group = g_DWM)
dow_yloc            = input.string('Bottom', "", options = ['Top', 'Bottom'], inline = "DOW", group = g_DWM)
dow_xloc            = input.string('Midnight', "", options = ['Midnight', 'Midday'], inline = "DOW", group = g_DWM)
dow_hide_wknd       = input.bool(true, "Hide Weekend Labels", group = g_DWM)


var g_OPEN          = "Opening Prices"
open_unlimited      = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPEN)

use_h1              = input.bool(false, "", inline = "H1", group = g_OPEN)
h1_text             = input.string("True Day Open", "", inline = "H1", group = g_OPEN)
h1                  = input.session("0000-0001", "", inline = "H1", group = g_OPEN)
h1_color            = input.color(color.black, "", inline = "H1", group = g_OPEN)

use_h2              = input.bool(false, "", inline = "H2", group = g_OPEN)
h2_text             = input.string("06:00", "", inline = "H2", group = g_OPEN)
h2                  = input.session("0600-0601", "", inline = "H2", group = g_OPEN)
h2_color            = input.color(color.black, "", inline = "H2", group = g_OPEN)

use_h3              = input.bool(false, "", inline = "H3", group = g_OPEN)
h3_text             = input.string("10:00", "", inline = "H3", group = g_OPEN)
h3                  = input.session("1000-1001", "", inline = "H3", group = g_OPEN)
h3_color            = input.color(color.black, "", inline = "H3", group = g_OPEN)

use_h4              = input.bool(false, "", inline = "H4", group = g_OPEN)
h4_text             = input.string("14:00", "", inline = "H4", group = g_OPEN)
h4                  = input.session("1400-1401", "", inline = "H4", group = g_OPEN)
h4_color            = input.color(color.black, "", inline = "H4", group = g_OPEN)

use_h5              = input.bool(false, "", inline = "H5", group = g_OPEN)
h5_text             = input.string("00:00", "", inline = "H5", group = g_OPEN)
h5                  = input.session("0000-0001", "", inline = "H5", group = g_OPEN)
h5_color            = input.color(color.black, "", inline = "H5", group = g_OPEN)

use_h6              = input.bool(false, "", inline = "H6", group = g_OPEN)
h6_text             = input.string("00:00", "", inline = "H6", group = g_OPEN)
h6                  = input.session("0000-0001", "", inline = "H6", group = g_OPEN)
h6_color            = input.color(color.black, "", inline = "H6", group = g_OPEN)

use_h7              = input.bool(false, "", inline = "H7", group = g_OPEN)
h7_text             = input.string("00:00", "", inline = "H7", group = g_OPEN)
h7                  = input.session("0000-0001", "", inline = "H7", group = g_OPEN)
h7_color            = input.color(color.black, "", inline = "H7", group = g_OPEN)

use_h8              = input.bool(false, "", inline = "H8", group = g_OPEN)
h8_text             = input.string("00:00", "", inline = "H8", group = g_OPEN)
h8                  = input.session("0000-0001", "", inline = "H8", group = g_OPEN)
h8_color            = input.color(color.black, "", inline = "H8", group = g_OPEN)

hz_style            = get_line_type(input.string(defval = 'Dotted', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "H0", group = g_OPEN))
hz_width            = input.int(1, "", inline = "H0", group = g_OPEN)


var g_VERTICAL      = "Timestamps"
v_unlimited         = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_VERTICAL)

use_v1              = input.bool(false, "", inline = "V1", group = g_VERTICAL)
v1                  = input.session("0000-0001", "", inline = "V1", group = g_VERTICAL)
v1_color            = input.color(color.black, "", inline = "V1", group = g_VERTICAL)

use_v2              = input.bool(false, "", inline = "V2", group = g_VERTICAL)
v2                  = input.session("0800-0801", "", inline = "V2", group = g_VERTICAL)
v2_color            = input.color(color.black, "", inline = "V2", group = g_VERTICAL)

use_v3              = input.bool(false, "", inline = "V3", group = g_VERTICAL)
v3                  = input.session("1000-1001", "", inline = "V3", group = g_VERTICAL)
v3_color            = input.color(color.black, "", inline = "V3", group = g_VERTICAL)

use_v4              = input.bool(false, "", inline = "V4", group = g_VERTICAL)
v4                  = input.session("1200-1201", "", inline = "V4", group = g_VERTICAL)
v4_color            = input.color(color.black, "", inline = "V4", group = g_VERTICAL)

vl_style            = get_line_type(input.string(defval = 'Dotted', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "V0", group = g_VERTICAL))
vl_width            = input.int(1, "", inline = "V0", group = g_VERTICAL)
// ---------------------------------------- Inputs --------------------------------------------------


// ---------------------------------------- Variables & Constants --------------------------------------------------
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
    if use_h4
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h4, h4_text, h4_color))
    if use_h5
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h5, h5_text, h5_color))
    if use_h6
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h6, h6_text, h6_color))
    if use_h7
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h7, h7_text, h7_color))
    if use_h8
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), h8, h8_text, h8_color))
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
    if use_nyam
        res.push(kz_helper.new(
             kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nyam, na_color, na_txt, nah_str, nal_str
         ))
    if use_nylu
        res.push(kz_helper.new(
             kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nylu, nl_color, nl_txt, nlh_str, nll_str
         ))
    if use_nypm
        res.push(kz_helper.new(
             kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nypm, np_color, np_txt, nph_str, npl_str
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

type ts_helper
    string session
    array<line> lines
    color c

initTS() =>
    array<ts_helper> res = array.new<ts_helper>()
    if use_v1
        res.push(ts_helper.new(v1, array.new_line(), v1_color))
    if use_v2
        res.push(ts_helper.new(v2, array.new_line(), v2_color))
    if use_v3
        res.push(ts_helper.new(v3, array.new_line(), v3_color))
    if use_v4
        res.push(ts_helper.new(v4, array.new_line(), v4_color))
    res

var array<ts_helper> ts_data = initTS()

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
// ---------------------------------------- Variables & Constants --------------------------------------------------


// ---------------------------------------- Functions --------------------------------------------------
get_box_color(color c) =>
    color.new(c, box_transparency)

get_text_color(color c) =>
    color.new(c, text_transparency)
// ---------------------------------------- Functions --------------------------------------------------


// ---------------------------------------- Core Logic --------------------------------------------------
dwm_sep(string tf, bool use, array<line> arr, color col) =>
    if use
        if timeframe.change(tf)
            arr.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style = htf_style, width = htf_width, extend = extend.both, color = col))
            if not sep_unlimited and arr.size() > max_days
                arr.pop().delete()


dwm_open(string tf, bool use, array<line> lns, array<label> lbls, dwm_info n, color col) =>
    if use
        if lns.size() > 0
            lns.get(0).set_x2(time)
            lbls.get(0).set_x(time)
        if timeframe.change(tf)
            lns.unshift(line.new(time, n.o, time, n.o, xloc = xloc.bar_time, style = htf_style, width = htf_width, color = col))
            lbls.unshift(label.new(time, n.o, tf + " OPEN", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
            if not sep_unlimited and lns.size() > max_days
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
            if not sep_unlimited and hl.hi_line.size() > max_days
                hl.hi_line.pop().delete()
                hl.lo_line.pop().delete()
                hl.hi_label.pop().delete()
                hl.lo_label.pop().delete()
        if hl.hi_line.size() > 0 and alert_HL
            if not hl.hit_high and high > hl.hi_line.get(0).get_y1()
                hl.hit_high := true
                alert(str.format("Hit P{0}H", tf))
            if not hl.hit_low and low < hl.lo_line.get(0).get_y1()
                hl.hit_low := true
                alert(str.format("Hit P{0}L", tf))


dwm() =>
    if tf_limit_is_equal_or_more_chart_tf
        // DWM - Separators
        dwm_sep("D", ds, d_sep_line, d_color)
        dwm_sep("W", ws, w_sep_line, w_color)
        dwm_sep("M", ms, m_sep_line, m_color)

        // DWM - Open Lines
        dwm_open("D", show_d_open, d_line, d_label, d_info, d_color)
        dwm_open("W", show_w_open, w_line, w_label, w_info, w_color)
        dwm_open("M", show_m_open, m_line, m_label, m_info, m_color)

        // DWM - Highs and Lows
        dwm_hl("D", dhl, d_hl, d_info, d_color)
        dwm_hl("W", whl, w_hl, w_info, w_color)
        dwm_hl("M", mhl, m_hl, m_info, m_color)


method vline(ts_helper this) =>
    bool t = not na(time("", this.session, gmt_tz))
    bool t_prev = not na(time("", this.session, gmt_tz, bars_back = 1))
    array<line> arr = this.lines
    color col = this.c
    if t and not t_prev
        arr.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style = vl_style, width = vl_width, extend = extend.both, color = col))
    if not v_unlimited
        if arr.size() > max_days
            arr.pop().delete()


vlines() =>
    if tf_limit_is_equal_or_more_chart_tf
        for [_, value] in ts_data
            vline(value)

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
        if not open_unlimited and hz.LN.size() > max_days
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
    str.trim(pre)
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
            if label_right
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
                    if show_labels and label_right
                        kz._hi_label.get(i).set_x(time)
                if kzHiValid and high > kz._hi_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert('Broke ' + kz._title + ' High', alert.freq_once_per_bar)
                    kz._hi_valid.set(i, false)
                    if show_labels and label_right
                        kz._hi_label.get(i).set_style(label.style_label_down)
                else if use_cutoff ? t_co : false
                    kz._hi_valid.set(i, false)

                kzLoValid = kz._lo_valid.get(i)
                if ext_past or kzLoValid
                    kz._lo_line.get(i).set_x2(time)
                    if show_labels and label_right
                        kz._lo_label.get(i).set_x(time)
                if kzLoValid and low < kz._lo_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert("Broke " + kz._title + " Low", alert.freq_once_per_bar)
                    kz._lo_valid.set(i, false)
                    if show_labels and label_right
                        kz._lo_label.get(i).set_style(label.style_label_up)
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
            _c = get_box_color(c)
            _t = get_text_color(c)
            kz._box.unshift(box.new(time, high, time, low, xloc = xloc.bar_time, border_color = show_kz ? _c : na, bgcolor = show_kz ? _c : na, text = show_kz and show_kz_text ? box_txt : na, text_color = _t))

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
                    if label_right
                        kz._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                        kz._lo_label.unshift(label.new(time, low, _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                    else
                        kz._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_down, size = lbl_size))
                        kz._lo_label.unshift(label.new(time, low, _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_up, size = lbl_size))

            del_kz(kz)
        adjust_in_kz(kz, t)
        adjust_out_kz(kz, t, t_prev)

for [_, value] in _kz
    manage_kz(value)

dwm()
vlines()
hz_lines()

new_dow_time = dow_xloc == 'Midday' ? time - timeframe.in_seconds("D") / 2 * 1000 : time
new_day = dayofweek(new_dow_time, gmt_tz) != dayofweek(new_dow_time, gmt_tz)[1]

var dow_top = dow_yloc == 'Top'

var saturday = "SATURDAY"
var sunday = "SUNDAY"
var monday = "MONDAY"
var tuesday = "TUESDAY"
var wednesday = "WEDNESDAY"
var thursday = "THURSDAY"
var friday = "FRIDAY"

plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 1 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = sunday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 2 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = monday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 3 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = tuesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 4 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = wednesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 5 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = thursday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 6 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = friday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 7 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = saturday)

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
// ---------------------------------------- Core Logic --------------------------------------------------
type Candle
	float o
	float c
	float h
	float l
    int o_time
	int o_idx
	int c_idx
	int h_idx
	int l_idx
    string dow
	box body
	line wick_up
	line wick_down
    label dow_label

type Trace
	line o
	line c
	line h
	line l
	label o_l
	label c_l
	label h_l
	label l_l

type Imbalance
	box b
	int idx

type CandleSettings
	bool show
	string htf
	int max_display

type Settings
	int max_sets
	color bull_body
	color bull_border
	color bull_wick
	color bear_body
	color bear_border
	color bear_wick
	int offset
	int buffer
	int htf_buffer
	int width
	bool use_custom_daily
    string custom_daily
    bool daily_name
	bool trace_show
	color trace_o_color
	string trace_o_style
	int trace_o_size
	color trace_c_color
	string trace_c_style
	int trace_c_size
	color trace_h_color
	string trace_h_style
	int trace_h_size
	color trace_l_color
	string trace_l_style
	int trace_l_size
	string trace_anchor
	bool label_show
	color label_color
	string label_size
    string label_position
    string label_alignment
	bool fvg_show
	color fvg_color
	bool vi_show
	color vi_color
	bool htf_label_show
	color htf_label_color
	string htf_label_size
	bool htf_timer_show
	color htf_timer_color
	string htf_timer_size
    color dow_color
    string dow_size

type CandleSet
	array<Candle> candles
	array<Imbalance> imbalances
	CandleSettings settings
	label tfNameTop
    label tfNameBottom
	label tfTimerTop
    label tfTimerBottom

type Helper
	string name = 'Helper'

Settings settings = Settings.new()

var CandleSettings SettingsHTF1 = CandleSettings.new()
var CandleSettings SettingsHTF2 = CandleSettings.new()
var CandleSettings SettingsHTF3 = CandleSettings.new()
var CandleSettings SettingsHTF4 = CandleSettings.new()
var CandleSettings SettingsHTF5 = CandleSettings.new()
var CandleSettings SettingsHTF6 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)
var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)
var array<Candle> candles_5 = array.new<Candle>(0)
var array<Candle> candles_6 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()
var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()
var array<Imbalance> imbalances_5 = array.new<Imbalance>()
var array<Imbalance> imbalances_6 = array.new<Imbalance>()

var CandleSet htf1 = CandleSet.new()
htf1.settings := SettingsHTF1
htf1.candles := candles_1
htf1.imbalances := imbalances_1

var CandleSet htf2 = CandleSet.new()
htf2.settings := SettingsHTF2
htf2.candles := candles_2
htf2.imbalances := imbalances_2

var CandleSet htf3 = CandleSet.new()
htf3.settings := SettingsHTF3
htf3.candles := candles_3
htf3.imbalances := imbalances_3

var CandleSet htf4 = CandleSet.new()
htf4.settings := SettingsHTF4
htf4.candles := candles_4
htf4.imbalances := imbalances_4

var CandleSet htf5 = CandleSet.new()
htf5.settings := SettingsHTF5
htf5.candles := candles_5
htf5.imbalances := imbalances_5

var CandleSet htf6 = CandleSet.new()
htf6.settings := SettingsHTF6
htf6.candles := candles_6
htf6.imbalances := imbalances_6

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_trace              = "Trace  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

htf1.settings.show              := input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('5', '', inline = 'htf1')
htf1.settings.htf := htf_1
htf1.settings.max_display       := input.int(10, '', inline = 'htf1')

htf2.settings.show              := input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('15', '', inline = 'htf2')
htf2.settings.htf := htf_2
htf2.settings.max_display       := input.int(10, '', inline = 'htf2')

htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('60', '', inline = 'htf3')
htf3.settings.htf := htf_3
htf3.settings.max_display       := input.int(10, '', inline = 'htf3')

htf4.settings.show              := input.bool(true, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('240', '', inline = 'htf4')
htf4.settings.htf               := htf_4
htf4.settings.max_display       := input.int(10, '', inline = 'htf4')

htf5.settings.show              := input.bool(true, 'HTF 5      ', inline = 'htf5')
htf_5                           = input.timeframe('1D', '', inline = 'htf5')
htf5.settings.htf := htf_5
htf5.settings.max_display       := input.int(10, '', inline = 'htf5')

htf6.settings.show              := input.bool(true, 'HTF 6      ', inline = 'htf6')
htf_6                           = input.timeframe('1W', '', inline = 'htf6')
htf6.settings.htf               := htf_6
htf6.settings.max_display       := input.int(10, '', inline = 'htf6')

settings.max_sets               := input.int(6, 'Limit to next HTFs only', minval = 1, maxval = 6)
settings.use_custom_daily       := input.bool(false, 'Custom daily candle open     ', inline='customdaily')
settings.custom_daily           := input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily')
settings.bull_body              := input.color(color.new(color.green, 10), 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.new(color.red, 10), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.new(color.black, 10), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.new(color.black, 10), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.new(color.black, 10), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.new(color.black, 10), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(10, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(10, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.new(color.black, 10), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.large, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')

settings.label_position         := input.string("Both", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Align", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.new(color.black, 10), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.daily_name             := input.bool(false, 'Interval Value        ', group=group_label, inline = 'dow')
settings.dow_color              := input.color(color.black , '', group=group_label, inline = 'dow')
settings.dow_size               := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(color.gray, 80), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(true, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 50), '', inline = 'vi', group = group_imbalance)

settings.trace_show             := input.bool(false, 'Trace lines', group = group_trace)
settings.trace_o_color          := input.color(color.new(color.gray, 50), 'Open    ', inline = '1', group = group_trace)
settings.trace_o_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '1', group = group_trace)
settings.trace_o_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '1', group = group_trace)
settings.trace_c_color          := input.color(color.new(color.gray, 50), 'Close    ', inline = '2', group = group_trace)
settings.trace_c_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '2', group = group_trace)
settings.trace_c_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '2', group = group_trace)
settings.trace_h_color          := input.color(color.new(color.gray, 50), 'High     ', inline = '3', group = group_trace)
settings.trace_h_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '3', group = group_trace)
settings.trace_h_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '3', group = group_trace)
settings.trace_l_color          := input.color(color.new(color.gray, 50), 'Low     ', inline = '4', group = group_trace)
settings.trace_l_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '4', group = group_trace)
settings.trace_l_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '4', group = group_trace)
settings.trace_anchor           := input.string('First Timeframe', 'Anchor to', options = ['First Timeframe', 'Last Timeframe'], group = group_trace)

settings.label_show             := input.bool(false, 'Price Label           ', inline = 'label')
settings.label_color            := input.color(color.new(color.black, 10), '', inline = 'label')
settings.label_size             := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'label')

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
var Trace trace = Trace.new()
color color_transparent = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method LineStyle(Helper helper, string style) =>
    helper.name := style
    out = switch style
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid
    out

method DayofWeek(Helper helper, int index) =>
    helper.name := 'DOW'
    switch
        index == 1 => 'M'
        index == 2 => 'T'
        index == 3 => 'W'
        index == 4 => 'T'
        index == 5 => 'F'
        index == 6 => 'S'
        index == 7 => 'S'
        na(index) => ''

method ValidTimeframe(Helper helper, string HTF) =>
    helper.name := HTF
    if timeframe.in_seconds(HTF) >= timeframe.in_seconds('D') and timeframe.in_seconds(HTF) > timeframe.in_seconds()
        true
    else
        n1 = timeframe.in_seconds()
        n2 = timeframe.in_seconds(HTF)
        n3 = n1 % n2
        n1 < n2 and math.round(n2 / n1) == n2 / n1


method RemainingTime(Helper helper, string HTF) =>
    helper.name := HTF
    if barstate.isrealtime
        timeRemaining = (time_close(HTF) - timenow) / 1000
        days = math.floor(timeRemaining / 86400)
        hours = math.floor((timeRemaining - days * 86400) / 3600)
        minutes = math.floor((timeRemaining - days * 86400 - hours * 3600) / 60)
        seconds = math.floor(timeRemaining - days * 86400 - hours * 3600 - minutes * 60)

        r = str.tostring(seconds, '00')
        if minutes > 0 or hours > 0 or days > 0
            r := str.tostring(minutes, '00') + ':' + r
            r
        if hours > 0 or days > 0
            r := str.tostring(hours, '00') + ':' + r
            r
        if days > 0
            r := str.tostring(days) + 'D ' + r
            r
        r
    else
        'n/a'

method HTFName(Helper helper, string HTF) =>
    helper.name := 'HTFName'
    formatted = HTF

    seconds = timeframe.in_seconds(HTF)
    if seconds < 60
        formatted := str.tostring(seconds) + 's'
        formatted
    else if seconds / 60 < 60
        formatted := str.tostring(seconds / 60) + 'm'
        formatted
    else if seconds / 60 / 60 < 24
        formatted := str.tostring(seconds / 60 / 60) + 'H'
        formatted
    formatted

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (htf1.settings.show ? 1 : 0)
    enabled := enabled + (htf2.settings.show ? 1 : 0)
    enabled := enabled + (htf3.settings.show ? 1 : 0)
    enabled := enabled + (htf4.settings.show ? 1 : 0)
    enabled := enabled + (htf5.settings.show ? 1 : 0)
    enabled := enabled + (htf6.settings.show ? 1 : 0)
    int last = math.min(enabled, settings.max_sets)

    last

method CandleSetHigh(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesSetHigh'
    float _h = h
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > _h
                _h := c.h
                _h
    _h

method CandleSetLow(Helper helper, array<Candle> candles, float l) =>
    helper.name := 'CandlesSetLow'
    float _l = l
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < _l
                _l := c.l
                _l
    _l

method CandlesHigh(Helper helper, array<Candle> candles) =>
    helper.name := 'CandlesHigh'
    h = 0.0
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        h := helper.CandleSetHigh(htf1.candles, h)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf2.candles, h)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf3.candles, h)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf4.candles, h)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf5.candles, h)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf6.candles, h)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > h
                h := c.h
    h

method CandlesLow(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesLow'
    l = h
    int cnt = 0
    int last = helper.HTFEnabled()

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        l := helper.CandleSetLow(htf1.candles, l)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf2.candles, l)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf3.candles, l)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf4.candles, l)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf5.candles, l)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf6.candles, l)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < l
                l := c.l
    l

method UpdateTime(CandleSet candleSet, int offset) =>
    if settings.htf_timer_show and (barstate.isrealtime or barstate.islast)
        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'

        if not na(candleSet.tfTimerTop)
            candleSet.tfTimerTop.set_text(tmr)

        if not na(candleSet.tfTimerBottom)
            candleSet.tfTimerBottom.set_text(tmr)
    candleSet

method Reorder(CandleSet candleSet, int offset) =>
    size = candleSet.candles.size()

    if size > 0
        for i = size - 1 to 0 by 1
            Candle candle = candleSet.candles.get(i)
            t_buffer = offset + (settings.width + settings.buffer) * (size - i - 1)
            box.set_left(candle.body, bar_index + t_buffer)
            box.set_right(candle.body, bar_index + settings.width + t_buffer)
            line.set_x1(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x1(candle.wick_down, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_down, bar_index + settings.width / 2 + t_buffer)

            if settings.daily_name //and candleSet.settings.htf == '1D'
                if not na(candle.dow_label)
                    candle.dow_label.set_y(candle.h)
                    candle.dow_label.set_x(bar_index + settings.width / 2 + t_buffer)
                    candle.dow_label.set_text(candle.dow)
                else
                    candle.dow_label := label.new(bar_index + settings.width / 2 + t_buffer, candle.h, candle.dow, color = color_transparent, textcolor = settings.dow_color, style = label.style_label_down, size = settings.dow_size)

    top = 0.0
    bottom = 0.0

    if settings.label_alignment == 'Align'
        top := helper.CandlesHigh(candleSet.candles)
        bottom := helper.CandlesLow(candleSet.candles, top)
    if settings.label_alignment == 'Follow Candles'
        top := helper.CandleSetHigh(candleSet.candles, 0)
        bottom := helper.CandleSetLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    if settings.htf_label_show
        string lblt = helper.HTFName(candleSet.settings.htf)
        string lbll = lblt
        if settings.htf_timer_show
            lblt := lblt + '\n'
            lbll := '\n' + lbll
        if settings.daily_name
            lblt := lblt + '\n'

        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')' + (settings.daily_name ? '\n' : '')
        if settings.label_position == 'Both' or settings.label_position == 'Top'
            
            if not na(candleSet.tfNameTop)
                candleSet.tfNameTop.set_xy(left, top)
            else
                candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size)
            if settings.htf_timer_show
                if not na(candleSet.tfTimerTop)
                    candleSet.tfTimerTop.set_xy(left, top)
                else
                    candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size)

        if settings.label_position == 'Both' or settings.label_position == 'Bottom'
            if not na(candleSet.tfNameBottom)
                candleSet.tfNameBottom.set_xy(left, bottom)
            else
                candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size)
            if settings.htf_timer_show
                if settings.htf_timer_show
                    if not na(candleSet.tfTimerBottom)
                        candleSet.tfTimerBottom.set_xy(left, bottom)
                    else
                        candleSet.tfTimerBottom := label.new(left, bottom, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_up, size = settings.htf_timer_size)

    candleSet

method FindImbalance(CandleSet candleSet) =>
    if barstate.isrealtime or barstate.islast
        if candleSet.imbalances.size() > 0
            for i = candleSet.imbalances.size() - 1 to 0 by 1
                Imbalance del = candleSet.imbalances.get(i)
                box.delete(del.b)
                candleSet.imbalances.pop()

        if candleSet.candles.size() > 3 and settings.fvg_show
            for i = 0 to candleSet.candles.size() - 3 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 2)
                candle3 = candleSet.candles.get(i + 1)

                if candle1.l > candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), candle2.h, box.get_right(candle1.body), candle1.l, bgcolor = settings.fvg_color, border_color = color_transparent, xloc = xloc.bar_index)
                    candleSet.imbalances.push(imb)
                if candle1.h < candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), candle1.h, box.get_left(candle2.body), candle2.l, bgcolor = settings.fvg_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                box temp = box.copy(candle3.body)
                box.delete(candle3.body)
                candle3.body := temp
                candle3.body

        if candleSet.candles.size() > 2 and settings.vi_show
            for i = 0 to candleSet.candles.size() - 2 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 1)
                if candle1.l < candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), math.min(candle1.o, candle1.c), box.get_right(candle1.body), math.max(candle2.o, candle2.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                if candle1.h > candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), math.min(candle2.o, candle2.c), box.get_left(candle2.body), math.max(candle1.o, candle1.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
    candleSet

method Monitor(CandleSet candleSet) =>
    HTFBarTime = time(candleSet.settings.htf, 'america/New_York')
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if settings.use_custom_daily
        int _830 = 0
        if isNewHTFCandle
            _830 := timestamp("America/New_York", year(time), month(time), dayofmonth(time), 0, 0) + 30600000
        if candleSet.settings.htf == '1D'
            if settings.custom_daily == 'Midnight'
                isNewHTFCandle := dayofweek(time, 'America/New_York') != dayofweek(time - (time - time[1]), 'America/New_York')
            if settings.custom_daily == '8:30'    
                // Get 8:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0830-0831:123456", 'America/New_York')) and na(time(timeframe.period, "0830-0831:123456", 'America/New_York')[1])
            if settings.custom_daily == '9:30'    
                // Get 9:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0930-0931:123456", 'America/New_York')) and na(time(timeframe.period, "0930-0931:123456", 'America/New_York')[1])
    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_time := time
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        candle.dow := switch
            candleSet.settings.htf == '1D' =>
                helper.DayofWeek(dayofweek(time_tradingday, "America/New_York"))
            str.tonumber(candleSet.settings.htf) < 60 =>
                str.format_time(candle.o_time, 'm', 'America/New_York')
            str.tonumber(candleSet.settings.htf) >= 60 =>
                str.format_time(candle.o_time, 'H', 'America/New_York')
            candleSet.settings.htf == '1M' =>
                str.format_time(candle.o_time, 'M', 'America/New_York')
            =>
                ''
        log.info('dow: {1} |{0}|', candle.dow, candleSet.settings.htf)
        bull = candle.c > candle.o

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), bull ? settings.bull_border : settings.bear_border, 1, bgcolor = bull ? settings.bull_body : settings.bear_body)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = bull ? settings.bull_wick : settings.bear_wick)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = bull ? settings.bull_wick : settings.bear_wick)

        candleSet.candles.unshift(candle)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)
            delCandle.dow_label.delete()

    candleSet

method Update(CandleSet candleSet, int offset, bool showTrace) =>
    if candleSet.candles.size() > 0
        Candle candle = candleSet.candles.first()
        candle.h_idx := high > candle.h ? bar_index : candle.h_idx
        candle.h := high > candle.h ? high : candle.h
        candle.l_idx := low < candle.l ? bar_index : candle.l_idx
        candle.l := low < candle.l ? low : candle.l
        candle.c := close
        candle.c_idx := bar_index

        bull = candle.c > candle.o

        box.set_top(candle.body, candle.o)
        box.set_bottom(candle.body, candle.c)
        box.set_bgcolor(candle.body, bull ? settings.bull_body : settings.bear_body)
        box.set_border_color(candle.body, bull ? settings.bull_border : settings.bear_border)
        line.set_color(candle.wick_up, bull ? settings.bull_wick : settings.bear_wick)
        line.set_color(candle.wick_down, bull ? settings.bull_wick : settings.bear_wick)
        line.set_y1(candle.wick_up, candle.h)
        line.set_y2(candle.wick_up, math.max(candle.o, candle.c))
        line.set_y1(candle.wick_down, candle.l)
        line.set_y2(candle.wick_down, math.min(candle.o, candle.c))

        if barstate.isrealtime or barstate.islast
            candleSet.Reorder(offset)
            if settings.trace_show and showTrace
                if bar_index - candle.o_idx < 5000
                    if na(trace.o)
                        trace.o := line.new(candle.o_idx, candle.o, box.get_left(candle.body), candle.o, xloc = xloc.bar_index, color = settings.trace_o_color, style = helper.LineStyle(settings.trace_o_style), width = settings.trace_o_size)
                        trace.o
                    else
                        line.set_xy1(trace.o, candle.o_idx, candle.o)
                        line.set_xy2(trace.o, box.get_left(candle.body), candle.o)

                    if settings.label_show
                        if na(trace.o_l)
                            trace.o_l := label.new(box.get_right(candle.body), candle.o, str.tostring(candle.o), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.o_l
                        else
                            label.set_xy(trace.o_l, box.get_right(candle.body), candle.o)
                            label.set_text(trace.o_l, str.tostring(candle.o))

                if bar_index - candle.c_idx < 5000
                    if na(trace.c)
                        trace.c := line.new(candle.c_idx, candle.c, box.get_left(candle.body), candle.c, xloc = xloc.bar_index, color = settings.trace_c_color, style = helper.LineStyle(settings.trace_c_style), width = settings.trace_c_size)
                        trace.c
                    else
                        line.set_xy1(trace.c, candle.c_idx, candle.c)
                        line.set_xy2(trace.c, box.get_left(candle.body), candle.c)

                    if settings.label_show
                        if na(trace.c_l)
                            trace.c_l := label.new(box.get_right(candle.body), candle.c, str.tostring(candle.c), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.c_l
                        else
                            label.set_xy(trace.c_l, box.get_right(candle.body), candle.c)
                            label.set_text(trace.c_l, str.tostring(candle.c))

                if bar_index - candle.h_idx < 5000
                    if na(trace.h)
                        trace.h := line.new(candle.h_idx, candle.h, line.get_x1(candle.wick_up), candle.h, xloc = xloc.bar_index, color = settings.trace_h_color, style = helper.LineStyle(settings.trace_h_style), width = settings.trace_h_size)
                        trace.h
                    else
                        line.set_xy1(trace.h, candle.h_idx, candle.h)
                        line.set_xy2(trace.h, line.get_x1(candle.wick_up), candle.h)

                    if settings.label_show
                        if na(trace.h_l)
                            trace.h_l := label.new(box.get_right(candle.body), candle.h, str.tostring(candle.h), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.h_l
                        else
                            label.set_xy(trace.h_l, box.get_right(candle.body), candle.h)
                            label.set_text(trace.h_l, str.tostring(candle.h))

                if bar_index - candle.l_idx < 5000
                    if na(trace.l)
                        trace.l := line.new(candle.l_idx, candle.l, line.get_x1(candle.wick_down), candle.l, xloc = xloc.bar_index, color = settings.trace_l_color, style = helper.LineStyle(settings.trace_l_style), width = settings.trace_l_size)
                        trace.l
                    else
                        line.set_xy1(trace.l, candle.l_idx, candle.l)
                        line.set_xy2(trace.l, line.get_x1(candle.wick_down), candle.l)

                    if settings.label_show
                        if na(trace.l_l)
                            trace.l_l := label.new(box.get_right(candle.body), candle.l, str.tostring(candle.l), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.l_l
                        else
                            label.set_xy(trace.l_l, box.get_right(candle.body), candle.l)
                            label.set_text(trace.l_l, str.tostring(candle.l))
    candleSet

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe'
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and settings.max_sets == 1
        showTrace := true
        showTrace
    htf1.UpdateTime(offset)
    htf1.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf2.UpdateTime(offset)
    htf2.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf2.candles.size() * settings.width + (htf2.candles.size() > 0 ? (htf2.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf3.UpdateTime(offset)
    htf3.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf4.UpdateTime(offset)
    htf4.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf5.UpdateTime(offset)
    htf5.Monitor().Update(offset, showTrace).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf5.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe'
        showTrace := true
        showTrace
    htf6.UpdateTime(offset)
    htf6.Monitor().Update(offset, showTrace).FindImbalance()
````

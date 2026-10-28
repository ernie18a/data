# Forex Killzones [LeHanz]

- url: https://www.tradingview.com/script/T9FgAvqg-Forex-Killzones-LeHanz/
- type: indicator
- pine_id: PUB;a681e2f4f03b4e8fa73a53fc6bd5423c
- version: 2.0

## Description

ICT Killzones & Pivots by TFO - Improved by LeHanz and duplicated into both Forex Killzones [LeHanz] and Index Killzones [LeHanz]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradeforopp

//@version=6
indicator("Forex Killzones [LeHanz]", "Forex Killzones [LeHanz]", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

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
max_days            = input.int(10, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, open lines, etc.)", group = g_SETTINGS)
tf_limit            = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)
gmt_tz              = input.string('America/New_York', "Timezone", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip = "Note GMT is not adjusted to reflect Daylight Saving Time changes", group = g_SETTINGS)
lbl_size            = get_size(input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color           = input.color(color.black, "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff              = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzones"
show_kz             = input.bool(false, "Show Killzone Boxes", inline = "KZ", group = g_KZ)
show_kz_text        = input.bool(false, "Display Text", inline = "KZ", group = g_KZ)

use_asia            = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt              = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia                = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)
as_color            = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london          = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt              = input.string("London", "", inline = "LONDON", group = g_KZ)
london              = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)
lo_color            = input.color(color.orange, "", inline = "LONDON", group = g_KZ)

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

use_PreMarket            = input.bool(true, "", inline = "PreMarket", group = g_KZ)
PreMarket_txt            = input.string("KZ 6", "", inline = "PreMarket", group = g_KZ)
PreMarket                = input.session("0700-0929", "", inline = "PreMarket", group = g_KZ)
PreMarket_color          = input.color(color.red, "", inline = "PreMarket", group = g_KZ)

box_transparency    = input.int(96, "Box Transparency", 0, 100, group = g_KZ)
text_transparency   = input.int(100, "Text Transparency", 0, 100, group = g_KZ)


var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)
use_alerts          = input.bool(false, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints      = input.bool(false, "Stop Once Mitigated", inline = "mp", group = g_LABELS) 
show_labels         = input.bool(false, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group = g_LABELS)
label_price         = input.bool(false, "Display Price", inline = "LB", group = g_LABELS)
label_right         = input.bool(false, "Right Side", inline = "LB", group = g_LABELS)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)
ext_which           = input.string("All", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS)

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
kzp_width           = input.int(2, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string(defval = 'Solid', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)


var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip = "Show the most recent ranges of each selected killzone, from high to low", group = g_RNG)
show_range_avg      = input.bool(true, "Show Average", tooltip = "Show the average range of each selected killzone", group = g_RNG)
range_avg           = input.int(5, "Average Length", 0, tooltip = "This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group = g_RNG)
range_pos           = get_table_pos(input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG))
range_size          = get_size(input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG))


var g_DWM           = "Day - Week - Month"
show_pdh_pdl     = input.bool(true, "Previous Day High/Low", group = g_DWM)
show_cdh_cdl     = input.bool(true, "Current Day High/Low", group = g_DWM)
show_midnight    = input.bool(true, "Midnight Open", group = g_DWM)
show_week_open   = input.bool(true, "Weekly Open", group = g_DWM)
show_month_open  = input.bool(true, "Monthly Open", group = g_DWM)

liquidity_style  = get_line_type(input.string(defval = 'Dotted', title = "Liquidity Style", options = ['Solid', 'Dotted', 'Dashed'], group = g_DWM))
liquidity_width  = input.int(1, "Liquidity Width", group = g_DWM)

pdh_color        = input.color(color.black, "PDH Color", group = g_DWM)
pdl_color        = input.color(color.black, "PDL Color", group = g_DWM)
cdh_color        = input.color(color.black, "CDH Color", group = g_DWM)
cdl_color        = input.color(color.black, "CDL Color", group = g_DWM)
midnight_color   = input.color(color.black, "Midnight Open", group = g_DWM)
week_open_color  = input.color(color.black, "Weekly Open", group = g_DWM)
month_open_color = input.color(color.black, "Monthly Open", group = g_DWM)

sep_unlimited       = input.bool(true, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_DWM)
alert_HL            = input.bool(false, "Alert High/Low Break", tooltip = "Alert when any selected highs and lows are traded through. The desired timeframe's high/low option must be enabled at the time that an alert is created", group = g_DWM)

show_d_open         = input.bool(true, "D Open", inline = "DO", group = g_DWM)
dhl                 = input.bool(true, "High/Low", inline = "DO", tooltip = "", group = g_DWM)
ds                  = input.bool(true, "Separators", inline = "DO", tooltip = "Mark where a new day begins", group = g_DWM)
d_color             = input.color(color.black, "", inline = "DO", group = g_DWM)

show_w_open         = input.bool(true, "W Open", inline = "WO", group = g_DWM)
whl                 = input.bool(true, "High/Low", inline = "WO", tooltip = "", group = g_DWM)
ws                  = input.bool(true, "Separators", inline = "WO", tooltip = "Mark where a new week begins", group = g_DWM)
w_color             = input.color(color.black, "", inline = "WO", group = g_DWM)

show_m_open         = input.bool(true, "M Open", inline = "MO", group = g_DWM)
mhl                 = input.bool(true, "High/Low", inline = "MO", tooltip = "", group = g_DWM)
ms                  = input.bool(true, "Separators", inline = "MO", tooltip = "Mark where a new month begins", group = g_DWM)
m_color             = input.color(color.black, "", inline = "MO", group = g_DWM)

htf_style           = get_line_type(input.string(defval = 'Dotted', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "D0", group = g_DWM))
htf_width           = input.int(1, "", inline = "D0", group = g_DWM)

dow_labels          = input.bool(true, "Day of Week Labels", inline = "DOW", group = g_DWM)
dow_yloc            = input.string('Bottom', "", options = ['Top', 'Bottom'], inline = "DOW", group = g_DWM)
dow_xloc            = input.string('Midnight', "", options = ['Midnight', 'Midday'], inline = "DOW", group = g_DWM)
dow_hide_wknd       = input.bool(true, "Hide Weekend Labels", group = g_DWM)
label_stagger_minutes = input.int(0, "Label Stagger (Minutes)", minval = 0, group = g_DWM)

var g_OPEN          = "Opening Prices"
open_unlimited      = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPEN)

use_h1              = input.bool(true, "", inline = "H1", group = g_OPEN)
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
    if use_PreMarket
        res.push(kz_helper.new(
            kz.new(PreMarket_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
            PreMarket, PreMarket_color, PreMarket_txt, "PreMarket.H", "PreMarket.L"
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

var float current_day_high = na
var float current_day_low = na
var float prev_day_high = na
var float prev_day_low = na

var bool cdh_valid = true
var bool cdl_valid = true
var bool pdh_valid = true
var bool pdl_valid = true

var line cdh_line = na
var line cdl_line = na
var line pdh_line = na
var line pdl_line = na

var label cdh_label = na
var label cdl_label = na
var label pdh_label = na
var label pdl_label = na

var line midnight_open_line = na
var line week_open_line = na
var line month_open_line = na

var label midnight_label = na
var label week_label = na
var label month_label = na

var line daily_separator = na

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

// =====================================
// DAILY / WEEKLY / MONTHLY LIQUIDITY
// =====================================

new_day_ny   = timeframe.change("D")
new_week_ny  = timeframe.change("W")
new_month_ny = timeframe.change("M")

// ---------- ARRAYS ----------
var array<line> pdh_lines = array.new_line()
var array<line> pdl_lines = array.new_line()

var array<label> pdh_labels = array.new_label()
var array<label> pdl_labels = array.new_label()

var array<bool> pdh_valids = array.new_bool()
var array<bool> pdl_valids = array.new_bool()

// ---------- NEW DAY ----------
if new_day_ny

    // Store previous day's final values
    prev_day_high := current_day_high
    prev_day_low  := current_day_low

    // Reset current day
    current_day_high := high
    current_day_low  := low

    cdh_valid := true
    cdl_valid := true

    // =====================================
    // PREVIOUS DAY HIGH / LOW
    // =====================================

    if show_pdh_pdl and not na(prev_day_high)

        pdh_new = line.new(
             time,
             prev_day_high,
             time,
             prev_day_high,
             xloc = xloc.bar_time,
             color = pdh_color,
             style = liquidity_style,
             width = liquidity_width)

        pdl_new = line.new(
             time,
             prev_day_low,
             time,
             prev_day_low,
             xloc = xloc.bar_time,
             color = pdl_color,
             style = liquidity_style,
             width = liquidity_width)

        // Detect overlap with ANY weekly liquidity lines

        bool is_pwh_overlap = false
        bool is_pwl_overlap = false

        // Check overlap with weekly highs
        if array.size(w_hl.hi_line) > 0

            for j = 0 to array.size(w_hl.hi_line) - 1

                weekly_high_price = line.get_y1(array.get(w_hl.hi_line, j))

                if math.abs(prev_day_high - weekly_high_price) <= syminfo.mintick * 2
                    is_pwh_overlap := true


        // Check overlap with weekly lows
        if array.size(w_hl.lo_line) > 0

            for j = 0 to array.size(w_hl.lo_line) - 1

                weekly_low_price = line.get_y1(array.get(w_hl.lo_line, j))

                if math.abs(prev_day_low - weekly_low_price) <= syminfo.mintick * 2
                    is_pwl_overlap := true


        pdh_lab = label.new(
            time,
            prev_day_high,
            is_pwh_overlap ? "" : "PDH",
            xloc = xloc.bar_time,
            style = label.style_label_left,
            color = transparent,
            textcolor = txt_color,
            size = lbl_size)

        pdl_lab = label.new(
            time,
            prev_day_low,
            is_pwl_overlap ? "" : "PDL",
            xloc = xloc.bar_time,
            style = label.style_label_left,
            color = transparent,
            textcolor = txt_color,
            size = lbl_size)

        array.unshift(pdh_lines, pdh_new)
        array.unshift(pdl_lines, pdl_new)

        array.unshift(pdh_labels, pdh_lab)
        array.unshift(pdl_labels, pdl_lab)

        array.unshift(pdh_valids, true)
        array.unshift(pdl_valids, true)

        // Keep 5 trading days
        if array.size(pdh_lines) > 5
            line.delete(array.pop(pdh_lines))
            line.delete(array.pop(pdl_lines))

            label.delete(array.pop(pdh_labels))
            label.delete(array.pop(pdl_labels))

            array.pop(pdh_valids)
            array.pop(pdl_valids)

    // =====================================
    // CURRENT DAY HIGH / LOW
    // =====================================

    if show_cdh_cdl

        cdh_line := line.new(
             time,
             high,
             time,
             high,
             xloc = xloc.bar_time,
             color = cdh_color,
             style = liquidity_style,
             width = liquidity_width)

        cdl_line := line.new(
             time,
             low,
             time,
             low,
             xloc = xloc.bar_time,
             color = cdl_color,
             style = liquidity_style,
             width = liquidity_width)

        cdh_label := label.new(
             time,
             high,
             "CDH",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent,
             textcolor = txt_color,
             size = lbl_size)

        cdl_label := label.new(
             time,
             low,
             "CDL",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent,
             textcolor = txt_color,
             size = lbl_size)

    // =====================================
    // MIDNIGHT OPEN
    // =====================================

    if show_midnight

        midnight_open_line := line.new(
             time,
             open,
             time,
             open,
             xloc = xloc.bar_time,
             color = midnight_color,
             style = liquidity_style,
             width = liquidity_width)

        midnight_label := label.new(
             time,
             open,
             "MID",
             xloc = xloc.bar_time,
             style = label.style_label_left,
             color = transparent,
             textcolor = txt_color,
             size = lbl_size)

    // =====================================
    // DAILY SEPARATOR
    // =====================================

    daily_separator := line.new(
         bar_index,
         high * 1.02,
         bar_index,
         low * 0.98,
         extend = extend.both,
         color = color.new(color.gray, 75),
         style = line.style_dotted,
         width = 1)

// =====================================
// UPDATE CURRENT DAY HIGH / LOW
// =====================================

current_day_high := na(current_day_high) ? high : math.max(current_day_high, high)
current_day_low  := na(current_day_low)  ? low  : math.min(current_day_low, low)

// =====================================
// UPDATE CDH
// =====================================

if show_cdh_cdl and not na(cdh_line)

    new_cdh = current_day_high

    line.set_y1(cdh_line, new_cdh)
    line.set_y2(cdh_line, new_cdh)

    line.set_x2(cdh_line, time)

    label.set_y(cdh_label, new_cdh)
    label.set_x(cdh_label, time)


// =====================================
// UPDATE CDL
// =====================================

if show_cdh_cdl and not na(cdl_line)

    new_cdl = current_day_low

    line.set_y1(cdl_line, new_cdl)
    line.set_y2(cdl_line, new_cdl)

    line.set_x2(cdl_line, time)

    label.set_y(cdl_label, new_cdl)
    label.set_x(cdl_label, time)
// =====================================
// EXTEND MIDNIGHT OPEN
// =====================================

if show_midnight and not na(midnight_open_line)

    line.set_x2(midnight_open_line, time)
    label.set_x(midnight_label, time)

// =====================================
// WEEKLY OPEN
// =====================================

if new_week_ny and show_week_open

    week_open_line := line.new(
         time,
         open,
         time,
         open,
         xloc = xloc.bar_time,
         color = week_open_color,
         style = liquidity_style,
         width = liquidity_width)

    week_label := label.new(
         time,
         open,
         "WO",
         xloc = xloc.bar_time,
         style = label.style_label_left,
         color = transparent,
         textcolor = txt_color,
         size = lbl_size)

if show_week_open and not na(week_open_line)

    line.set_x2(week_open_line, time)
    label.set_x(week_label, time)

// =====================================
// MONTHLY OPEN
// =====================================

if new_month_ny and show_month_open

    month_open_line := line.new(
         time,
         open,
         time,
         open,
         xloc = xloc.bar_time,
         color = month_open_color,
         style = liquidity_style,
         width = liquidity_width)

    month_label := label.new(
         time,
         open,
         "MO",
         xloc = xloc.bar_time,
         style = label.style_label_left,
         color = transparent,
         textcolor = txt_color,
         size = lbl_size)

if show_month_open and not na(month_open_line)

    line.set_x2(month_open_line, time)
    label.set_x(month_label, time)

// =====================================
// EXTEND PDH / PDL
// =====================================

// =====================================
// EXTEND PDH / PDL
// =====================================

if array.size(pdh_lines) > 0

    for i = 0 to array.size(pdh_lines) - 1

        pdh_ln = array.get(pdh_lines, i)
        pdl_ln = array.get(pdl_lines, i)

        pdh_lb = array.get(pdh_labels, i)
        pdl_lb = array.get(pdl_labels, i)

        pdh_valid = array.get(pdh_valids, i)
        pdl_valid = array.get(pdl_valids, i)

        // PDH
        if pdh_valid

            line.set_x2(pdh_ln, time)

            offset_ms_pdh = i * label_stagger_minutes * 60 * 1000

            label.set_x(
                 pdh_lb,
                 time + offset_ms_pdh)

            label.set_y(
                pdh_lb,
                line.get_y1(pdh_ln) + (i * syminfo.mintick * 200))

            if high > line.get_y1(pdh_ln)
                array.set(pdh_valids, i, false)

        // PDL
        if pdl_valid

            line.set_x2(pdl_ln, time)

            offset_ms_pdl = (i + 1) * label_stagger_minutes * 60 * 1000

            label.set_x(
                 pdl_lb,
                 time + offset_ms_pdl)

            label.set_y(
                pdl_lb,
                line.get_y1(pdl_ln) - (i * syminfo.mintick * 200))

            if low < line.get_y1(pdl_ln)
                array.set(pdl_valids, i, false)
                
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
````

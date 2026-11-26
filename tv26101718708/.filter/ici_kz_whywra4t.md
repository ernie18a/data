# ICI + KZ

- url: https://www.tradingview.com/script/whYwra4T-ICI-KZ/
- type: indicator
- pine_id: PUB;f1d180c28b3f4ba4ba070e8bc339bb9e
- version: 3.0

## Description

ICI + Killzones + ATR

ICI moving averages 10/20/50 + Killzones and pivots + Average True Range + Custom notebook

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FXsmu

//@version=6
indicator("ICI + KZ", "ICI", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)


// ════════════════════════════════════════════════════════════════════════
// ▶ ICI BLOCK — ATR + EMA Stack (toggle on/off)
// ════════════════════════════════════════════════════════════════════════
var g_ICI = "▶ ICI — ATR & EMA Stack"
ici_on = input.bool (true, "Enable ICI Block", group = g_ICI)
ici_length = input.int (14, "ATR Period", group = g_ICI, minval = 1)
ici_smoothing = input.string("RMA", "Smoothing", group = g_ICI, options = ["RMA", "SMA", "EMA", "WMA"])
ici_atrMult = input.float (0.5, "ATR Multiplier", group = g_ICI, minval = 0.01, maxval = 100, step = 0.05)

// === EMA Colors ===
ici_ema10_color = input.color(color.rgb(4, 186, 241),   "EMA 10 Color", group = g_ICI)
ici_ema20_color = input.color(#ccd0d1,                  "EMA 20 Color", group = g_ICI)
ici_ema50_color = input.color(#ce0be7,                  "EMA 50 Color", group = g_ICI)

ici_tblPos = input.string("Top Right", "Table Position", group = g_ICI, options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"])
ici_borderColor = input.color (#636363, "Border Color", group = g_ICI)
ici_bgColor = input.color (#ffffff, "Background Color", group = g_ICI)
ici_textColor = input.color (#000000, "Text Color", group = g_ICI)

ici_tblposition =
     ici_tblPos == "Top Left" ? position.top_left :
     ici_tblPos == "Top Right" ? position.top_right :
     ici_tblPos == "Bottom Left" ? position.bottom_left :
     ici_tblPos == "Bottom Right" ? position.bottom_right :
     ici_tblPos == "Middle Left" ? position.middle_left : position.middle_right

ici_ma_function(src, len) =>
    if ici_smoothing == "RMA"
        ta.rma(src, len)
    else if ici_smoothing == "SMA"
        ta.sma(src, len)
    else if ici_smoothing == "EMA"
        ta.ema(src, len)
    else
        ta.wma(src, len)

ici_catr = ici_ma_function(ta.tr(true), ici_length)
ici_atrVal = ici_catr * ici_atrMult

var ici_table = table.new(
     position = ici_tblposition,
     columns = 1,
     rows = 1,
     bgcolor = #ffffff,
     border_width = 1,
     frame_color = ici_borderColor,
     frame_width = 4)

table.clear(ici_table, 0, 0)
if ici_on
    table.cell(ici_table,
         column = 0,
         row = 0,
         text = "ATR Value: " + str.tostring(ici_atrVal, format.mintick),
         text_color = ici_textColor,
         text_halign = text.align_right,
         text_valign = text.align_center,
         bgcolor = ici_bgColor)

ici_mic  = ta.ema(close, 10)
ici_mic2 = ta.ema(close, 20)
ici_mediu = ta.ema(close, 50)

plot(ici_mic,  "EMA 10", color = ici_on ? ici_ema10_color : na)
plot(ici_mic2, "EMA 20", color = ici_on ? ici_ema20_color : na)
plot(ici_mediu,"EMA 50", color = ici_on ? ici_ema50_color : na)
// ════════════════════════════════════════════════════════════════════════
// END ICI BLOCK
// ════════════════════════════════════════════════════════════════════════

// ---------------------------------------- Constant Functions --------------------------------------------------
get_line_type(_style) =>
    switch _style
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed

get_size(x) =>
    switch x
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
// ---------------------------------------- Constant Functions --------------------------------------------------


// ---------------------------------------- Inputs --------------------------------------------------
var g_SETTINGS    = "Settings"
max_days          = input.int(3, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, open lines, etc.)", group = g_SETTINGS)
tf_limit          = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS)
gmt_tz            = input.string('America/New_York', "Timezone", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip = "Note GMT is not adjusted to reflect Daylight Saving Time changes", group = g_SETTINGS)
lbl_size          = get_size(input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color         = input.color(color.black, "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff        = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff            = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ          = "Killzones"
show_kz           = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ)
show_kz_text      = input.bool(true, "Display Text",        inline = "KZ", group = g_KZ)

use_asia          = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt            = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia              = input.session("2000-0000", "", inline = "ASIA", group = g_KZ)
as_color          = input.color(color.blue, "", inline = "ASIA", group = g_KZ)

use_london        = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt            = input.string("London", "", inline = "LONDON", group = g_KZ)
london            = input.session("0200-0500", "", inline = "LONDON", group = g_KZ)
lo_color          = input.color(color.red, "", inline = "LONDON", group = g_KZ)

use_nyam          = input.bool(true, "", inline = "NYAM", group = g_KZ)
na_txt            = input.string("NY AM", "", inline = "NYAM", group = g_KZ)
nyam              = input.session("0930-1100", "", inline = "NYAM", group = g_KZ)
na_color          = input.color(#089981, "", inline = "NYAM", group = g_KZ)

use_nylu          = input.bool(true, "", inline = "NYLU", group = g_KZ)
nl_txt            = input.string("NY Lunch", "", inline = "NYLU", group = g_KZ)
nylu              = input.session("1200-1300", "", inline = "NYLU", group = g_KZ)
nl_color          = input.color(color.yellow, "", inline = "NYLU", group = g_KZ)

use_nypm          = input.bool(true, "", inline = "NYPM", group = g_KZ)
np_txt            = input.string("NY PM", "", inline = "NYPM", group = g_KZ)
nypm              = input.session("1330-1600", "", inline = "NYPM", group = g_KZ)
np_color          = input.color(color.purple, "", inline = "NYPM", group = g_KZ)

box_transparency  = input.int(70, "Box Transparency", 0, 100, group = g_KZ)
text_transparency = input.int(50, "Text Transparency", 0, 100, group = g_KZ)


var g_LABELS      = "Killzone Pivots"
show_pivots       = input.bool(true,  "Show Pivots",         inline = "PV", group = g_LABELS)
use_alerts        = input.bool(true,  "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS)
show_midpoints    = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints    = input.bool(true,  "Stop Once Mitigated",  inline = "mp", group = g_LABELS)
show_labels       = input.bool(true,  "Show Pivot Labels",   inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group = g_LABELS)
label_price       = input.bool(false, "Display Price",        inline = "LB", group = g_LABELS)
label_right       = input.bool(false, "Right Side",           inline = "LB", group = g_LABELS)
ext_pivots        = input.string("Until Mitigated", "Extend Pivots...",       options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)
ext_which         = input.string("Most Recent",     "...From Which Sessions", options = ['Most Recent', 'All'],                 group = g_LABELS)

ash_str           = input.string("AS.H",   "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str           = input.string("AS.L",   "",                  inline = "L_AS", group = g_LABELS)
as_ext_pivot      = input.bool  (true,     "Extend Pivots",     inline = "L_AS", group = g_LABELS)

loh_str           = input.string("LO.H",   "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str           = input.string("LO.L",   "",                  inline = "L_LO", group = g_LABELS)
lo_ext_pivot      = input.bool  (true,     "Extend Pivots",     inline = "L_LO", group = g_LABELS)

nah_str           = input.string("NYAM.H", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)
nal_str           = input.string("NYAM.L", "",                  inline = "L_NA", group = g_LABELS)
na_ext_pivot      = input.bool  (true,     "Extend Pivots",     inline = "L_NA", group = g_LABELS)

nlh_str           = input.string("NYL.H",  "Killzone 4 Labels", inline = "L_NL", group = g_LABELS)
nll_str           = input.string("NYL.L",  "",                  inline = "L_NL", group = g_LABELS)
nl_ext_pivot      = input.bool  (true,     "Extend Pivots",     inline = "L_NL", group = g_LABELS)

nph_str           = input.string("NYPM.H", "Killzone 5 Labels", inline = "L_NP", group = g_LABELS)
npl_str           = input.string("NYPM.L", "",                  inline = "L_NP", group = g_LABELS)
np_ext_pivot      = input.bool  (true,     "Extend Pivots",     inline = "L_NP", group = g_LABELS)

kzp_style         = get_line_type(input.string(defval = 'Solid',  title = "Pivot Style",    options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS))
kzp_width         = input.int(1, "", inline = "KZP", group = g_LABELS)
kzm_style         = get_line_type(input.string(defval = 'Dotted', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width         = input.int(1, "", inline = "KZM", group = g_LABELS)


var g_DWM         = "Day - Week - Month"
sep_unlimited     = input.bool(false, "Unlimited",          tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_DWM)
alert_HL          = input.bool(false, "Alert High/Low Break", tooltip = "Alert when any selected highs and lows are traded through. The desired timeframe's high/low option must be enabled at the time that an alert is created", group = g_DWM)

show_d_open       = input.bool(false, "D Open",     inline = "DO", group = g_DWM)
dhl               = input.bool(false, "High/Low",   inline = "DO", group = g_DWM)
ds                = input.bool(false, "Separators", inline = "DO", tooltip = "Mark where a new day begins",   group = g_DWM)
d_color           = input.color(color.blue, "", inline = "DO", group = g_DWM)

show_w_open       = input.bool(false, "W Open",     inline = "WO", group = g_DWM)
whl               = input.bool(false, "High/Low",   inline = "WO", group = g_DWM)
ws                = input.bool(false, "Separators", inline = "WO", tooltip = "Mark where a new week begins",  group = g_DWM)
w_color           = input.color(#089981, "", inline = "WO", group = g_DWM)

show_m_open       = input.bool(false, "M Open",     inline = "MO", group = g_DWM)
mhl               = input.bool(false, "High/Low",   inline = "MO", group = g_DWM)
ms                = input.bool(false, "Separators", inline = "MO", tooltip = "Mark where a new month begins", group = g_DWM)
m_color           = input.color(color.red, "", inline = "MO", group = g_DWM)

htf_style         = get_line_type(input.string(defval = 'Solid', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "D0", group = g_DWM))
htf_width         = input.int(1, "", inline = "D0", group = g_DWM)

dow_labels        = input.bool(true, "Day of Week Labels", inline = "DOW", group = g_DWM)
dow_yloc          = input.string('Bottom', "",  options = ['Top', 'Bottom'],          inline = "DOW", group = g_DWM)
dow_xloc          = input.string('Midnight', "", options = ['Midnight', 'Midday'],    inline = "DOW", group = g_DWM)
dow_hide_wknd     = input.bool(true, "Hide Weekend Labels", group = g_DWM)


var g_OPEN        = "Opening Prices"
open_unlimited    = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPEN)

use_h1            = input.bool(false, "", inline = "H1", group = g_OPEN)
h1_text           = input.string("True Day Open", "", inline = "H1", group = g_OPEN)
h1                = input.session("0000-0001", "", inline = "H1", group = g_OPEN)
h1_color          = input.color(color.black, "", inline = "H1", group = g_OPEN)

use_h2            = input.bool(false, "", inline = "H2", group = g_OPEN)
h2_text           = input.string("06:00", "", inline = "H2", group = g_OPEN)
h2                = input.session("0600-0601", "", inline = "H2", group = g_OPEN)
h2_color          = input.color(color.black, "", inline = "H2", group = g_OPEN)

use_h3            = input.bool(false, "", inline = "H3", group = g_OPEN)
h3_text           = input.string("10:00", "", inline = "H3", group = g_OPEN)
h3                = input.session("1000-1001", "", inline = "H3", group = g_OPEN)
h3_color          = input.color(color.black, "", inline = "H3", group = g_OPEN)

use_h4            = input.bool(false, "", inline = "H4", group = g_OPEN)
h4_text           = input.string("14:00", "", inline = "H4", group = g_OPEN)
h4                = input.session("1400-1401", "", inline = "H4", group = g_OPEN)
h4_color          = input.color(color.black, "", inline = "H4", group = g_OPEN)

use_h5            = input.bool(false, "", inline = "H5", group = g_OPEN)
h5_text           = input.string("00:00", "", inline = "H5", group = g_OPEN)
h5                = input.session("0000-0001", "", inline = "H5", group = g_OPEN)
h5_color          = input.color(color.black, "", inline = "H5", group = g_OPEN)

use_h6            = input.bool(false, "", inline = "H6", group = g_OPEN)
h6_text           = input.string("00:00", "", inline = "H6", group = g_OPEN)
h6                = input.session("0000-0001", "", inline = "H6", group = g_OPEN)
h6_color          = input.color(color.black, "", inline = "H6", group = g_OPEN)

use_h7            = input.bool(false, "", inline = "H7", group = g_OPEN)
h7_text           = input.string("00:00", "", inline = "H7", group = g_OPEN)
h7                = input.session("0000-0001", "", inline = "H7", group = g_OPEN)
h7_color          = input.color(color.black, "", inline = "H7", group = g_OPEN)

use_h8            = input.bool(false, "", inline = "H8", group = g_OPEN)
h8_text           = input.string("00:00", "", inline = "H8", group = g_OPEN)
h8                = input.session("0000-0001", "", inline = "H8", group = g_OPEN)
h8_color          = input.color(color.black, "", inline = "H8", group = g_OPEN)

hz_style          = get_line_type(input.string(defval = 'Dotted', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "H0", group = g_OPEN))
hz_width          = input.int(1, "", inline = "H0", group = g_OPEN)


var g_VERTICAL    = "Timestamps"
v_unlimited       = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_VERTICAL)

use_v1            = input.bool(false, "", inline = "V1", group = g_VERTICAL)
v1                = input.session("0000-0001", "", inline = "V1", group = g_VERTICAL)
v1_color          = input.color(color.black, "", inline = "V1", group = g_VERTICAL)

use_v2            = input.bool(false, "", inline = "V2", group = g_VERTICAL)
v2                = input.session("0800-0801", "", inline = "V2", group = g_VERTICAL)
v2_color          = input.color(color.black, "", inline = "V2", group = g_VERTICAL)

use_v3            = input.bool(false, "", inline = "V3", group = g_VERTICAL)
v3                = input.session("1000-1001", "", inline = "V3", group = g_VERTICAL)
v3_color          = input.color(color.black, "", inline = "V3", group = g_VERTICAL)

use_v4            = input.bool(false, "", inline = "V4", group = g_VERTICAL)
v4                = input.session("1200-1201", "", inline = "V4", group = g_VERTICAL)
v4_color          = input.color(color.black, "", inline = "V4", group = g_VERTICAL)

vl_style          = get_line_type(input.string(defval = 'Dotted', title = "Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "V0", group = g_VERTICAL))
vl_width          = input.int(1, "", inline = "V0", group = g_VERTICAL)
// ---------------------------------------- Inputs --------------------------------------------------


// ---------------------------------------- Variables & Constants --------------------------------------------------
type kz
    string _title
    array<box>   _box
    array<line>  _hi_line
    array<line>  _md_line
    array<line>  _lo_line
    array<label> _hi_label
    array<label> _lo_label
    array<bool>  _hi_valid
    array<bool>  _md_valid
    array<bool>  _lo_valid

type hz
    array<line>  LN
    array<label> LB
    array<bool>  CO

type dwm_hl
    array<line>  hi_line
    array<line>  lo_line
    array<label> hi_label
    array<label> lo_label
    bool hit_high = false
    bool hit_low  = false

type dwm_info
    string tf
    float o  = na
    float h  = na
    float l  = na
    float ph = na
    float pl = na

type lines_helper
    hz     _hz
    string h
    string h_text
    color  h_color

type kz_helper
    kz     _kz
    string session
    color  c
    string box_txt
    string hi_txt
    string lo_txt
    bool   extend_pivot

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

initKZ() =>
    array<kz_helper> res = array.new<kz_helper>()
    if use_asia
        res.push(kz_helper.new(
             kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool()),
             asia, as_color, as_txt, ash_str, asl_str, as_ext_pivot))
    if use_london
        res.push(kz_helper.new(
             kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool()),
             london, lo_color, lo_txt, loh_str, lol_str, lo_ext_pivot))
    if use_nyam
        res.push(kz_helper.new(
             kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool()),
             nyam, na_color, na_txt, nah_str, nal_str, na_ext_pivot))
    if use_nylu
        res.push(kz_helper.new(
             kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool()),
             nylu, nl_color, nl_txt, nlh_str, nll_str, nl_ext_pivot))
    if use_nypm
        res.push(kz_helper.new(
             kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool()),
             nypm, np_color, np_txt, nph_str, npl_str, np_ext_pivot))
    res

var array<kz_helper> _kz = initKZ()


var d_hl   = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var w_hl   = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var m_hl   = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())

var d_info = dwm_info.new("D")
var w_info = dwm_info.new("W")
var m_info = dwm_info.new("M")

t_co = not na(time("", cutoff, gmt_tz))

type ts_helper
    string      session
    array<line> lines
    color       c

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

var d_line  = array.new_line()
var w_line  = array.new_line()
var m_line  = array.new_line()

var d_label = array.new_label()
var w_label = array.new_label()
var m_label = array.new_label()

var transparent = #ffffff00
var ext_current = ext_which == 'Most Recent'
var ext_past    = ext_pivots == 'Past Mitigation'

update_dwm_info(dwm_info n) =>
    if timeframe.change(n.tf)
        n.ph := n.h
        n.pl := n.l
        n.o  := open
        n.h  := high
        n.l  := low
    else
        n.h  := math.max(high, n.h)
        n.l  := math.min(low,  n.l)

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
            hl.hit_low  := false
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
        dwm_sep("D", ds, d_sep_line, d_color)
        dwm_sep("W", ws, w_sep_line, w_color)
        dwm_sep("M", ms, m_sep_line, m_color)
        dwm_open("D", show_d_open, d_line, d_label, d_info, d_color)
        dwm_open("W", show_w_open, w_line, w_label, w_info, w_color)
        dwm_open("M", show_m_open, m_line, m_label, m_info, m_color)
        dwm_hl("D", dhl, d_hl, d_info, d_color)
        dwm_hl("W", whl, w_hl, w_info, w_color)
        dwm_hl("M", mhl, m_hl, m_info, m_color)


method vline(ts_helper this) =>
    bool t      = not na(time("", this.session, gmt_tz))
    bool t_prev = not na(time("", this.session, gmt_tz, bars_back = 1))
    array<line> arr = this.lines
    color col   = this.c
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
    bool t      = not na(time("", this.h, gmt_tz))
    bool t_prev = not na(time("", this.h, gmt_tz, bars_back = 1))
    hz hz       = this._hz
    string txt  = this.h_text
    color col   = this.h_color
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
    S   = L.get_text()
    pre = str.substring(S, 0, str.pos(S, " "))
    str.trim(pre)
    L.set_text(str.format("{0} ({1})", pre, P))

adjust_in_kz(kz kz, bool t) =>
    if t
        kzBox0    = kz._box.get(0)
        kzBox0.set_right(time)
        newTop    = math.max(kzBox0.get_top(), high)
        kzBox0.set_top(newTop)
        newBottom = math.min(kzBox0.get_bottom(), low)
        kzBox0.set_bottom(newBottom)

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


// t_prev removed from signature — no longer needed after range block removal
adjust_out_kz(kz kz, bool t) =>
    boxCount = kz._box.size()
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
    kz kz          = this._kz
    c              = this.c
    string box_txt = this.box_txt
    string hi_txt  = this.hi_txt
    string lo_txt  = this.lo_txt

    if tf_limit_is_equal_or_more_chart_tf
        t      = not na(time("", this.session, gmt_tz))
        t_prev = not na(time("", this.session, gmt_tz, bars_back = 1))
        if t and not t_prev
            _c = get_box_color(c)
            _t = get_text_color(c)
            kz._box.unshift(box.new(time, high, time, low, xloc = xloc.bar_time, border_color = show_kz ? _c : na, bgcolor = show_kz ? _c : na, text = show_kz and show_kz_text ? box_txt : na, text_color = _t))

            if show_pivots
                kz._hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                kz._lo_line.unshift(line.new(time, low,  time, low,  xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                if show_midpoints
                    kz._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc = xloc.bar_time, style = kzm_style, color = c, width = kzm_width))
                    array.unshift(kz._md_valid, true)
                array.unshift(kz._hi_valid, true)
                array.unshift(kz._lo_valid, true)

                if show_labels
                    _hi_txt = label_price ? str.format('{0} ({1})', hi_txt, high) : hi_txt
                    _lo_txt = label_price ? str.format('{0} ({1})', lo_txt, low)  : lo_txt
                    if label_right
                        kz._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                        kz._lo_label.unshift(label.new(time, low,  _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_left, size = lbl_size))
                    else
                        kz._hi_label.unshift(label.new(time, high, _hi_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_down, size = lbl_size))
                        kz._lo_label.unshift(label.new(time, low,  _lo_txt, xloc = xloc.bar_time, color = transparent, textcolor = txt_color, style = label.style_label_up,   size = lbl_size))

            del_kz(kz)
        adjust_in_kz(kz, t)
        if this.extend_pivot
            adjust_out_kz(kz, t)

for [_, value] in _kz
    manage_kz(value)

dwm()
vlines()
hz_lines()

new_dow_time = dow_xloc == 'Midday' ? time - timeframe.in_seconds("D") / 2 * 1000 : time
new_day      = dayofweek(new_dow_time, gmt_tz) != dayofweek(new_dow_time, gmt_tz)[1]

var dow_top   = dow_yloc == 'Top'

var saturday  = "SATURDAY"
var sunday    = "SUNDAY"
var monday    = "MONDAY"
var tuesday   = "TUESDAY"
var wednesday = "WEDNESDAY"
var thursday  = "THURSDAY"
var friday    = "FRIDAY"

plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 1 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = sunday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 2 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = monday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 3 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = tuesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 4 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = wednesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 5 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = thursday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 6 and new_day, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = friday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 7 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = saturday)
// ---------------------------------------- Core Logic --------------------------------------------------

// ════════════════════════════════════════════════════════════════════════
// ▶ NOTES BLOCK — Custom Notes on Chart
// ════════════════════════════════════════════════════════════════════════
var g_NOTES = "▶ Notes Block"
notes_on = input.bool(true, "Enable Notes Block", group = g_NOTES)
notes_text = input.text_area("", "Notes Text", group = g_NOTES)
notes_pos = input.string("Top Center", "Table Position", group = g_NOTES, 
     options = ["Top Left", "Top Right", "Top Center", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right", "Center"])

notes_borderColor = input.color(#636363, "Border Color", group = g_NOTES)
notes_bgColor = input.color(#f8f9fa, "Background Color", group = g_NOTES)
notes_textColor = input.color(#000000, "Text Color", group = g_NOTES)
notes_size = input.string("Normal", "Text Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_NOTES)

notes_tblposition =
     notes_pos == "Top Left" ? position.top_left :
     notes_pos == "Top Right" ? position.top_right :
     notes_pos == "Top Center" ? position.top_center :
     notes_pos == "Bottom Left" ? position.bottom_left :
     notes_pos == "Bottom Right" ? position.bottom_right :
     notes_pos == "Middle Left" ? position.middle_left :
     notes_pos == "Middle Right" ? position.middle_right : position.middle_center

var notes_table = table.new(
     position = notes_tblposition,
     columns = 1,
     rows = 1,
     bgcolor = notes_bgColor,
     border_width = 1,
     frame_color = notes_borderColor,
     frame_width = 2)

if notes_on
    table.cell(notes_table, 0, 0,
         text = notes_text,
         text_color = notes_textColor,
         text_size = get_size(notes_size),
         text_halign = text.align_left,
         text_valign = text.align_top,
         bgcolor = notes_bgColor)
else
    table.clear(notes_table, 0, 0)
// ════════════════════════════════════════════════════════════════════════
// END NOTES BLOCK
// ════════════════════════════════════════════════════════════════════════
````

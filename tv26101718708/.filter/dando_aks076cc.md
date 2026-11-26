# Dando

- url: https://www.tradingview.com/script/Aks076CC-Dando/
- type: indicator
- pine_id: PUB;e19c03d466994bfc99a4d97d1d116e4d
- version: 7.0

## Description

Welcome to Dando, the ultimate all-in-one suite for traders utilizing Smart Money Concepts (SMC) and Inner Circle Trader (ICT) methodologies.

Instead of cluttering your chart with a dozen different indicators, Dando combines the most powerful price action concepts into a single, highly customizable, and visually clean overlay. From precision Fair Value Gap (FVG) tracking and multi-timeframe trend analysis to automated Liquidity Sweeps and Killzone detection, Dando is designed to provide actionable, high-probability trade setups based on algorithmic logic.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradeforopp — modified by Dando

//@version=6
indicator("Dando v7", "Dando v7", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)


// ══════════════════════════════════════════════════════════════════════════════
// CONSTANT FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

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

get_table_pos(pos) =>
    switch pos
        "Bottom Center" => position.bottom_center
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Middle Center" => position.middle_center
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        "Top Center"    => position.top_center
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right


// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

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

ash_str             = input.string("AS.H",   "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str             = input.string("AS.L",   "",                  inline = "L_AS", group = g_LABELS)
loh_str             = input.string("LO.H",   "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str             = input.string("LO.L",   "",                  inline = "L_LO", group = g_LABELS)
nah_str             = input.string("NYAM.H", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)
nal_str             = input.string("NYAM.L", "",                  inline = "L_NA", group = g_LABELS)
nlh_str             = input.string("NYL.H",  "Killzone 4 Labels", inline = "L_NL", group = g_LABELS)
nll_str             = input.string("NYL.L",  "",                  inline = "L_NL", group = g_LABELS)
nph_str             = input.string("NYPM.H", "Killzone 5 Labels", inline = "L_NP", group = g_LABELS)
npl_str             = input.string("NYPM.L", "",                  inline = "L_NP", group = g_LABELS)

kzp_style           = get_line_type(input.string(defval = 'Solid',  title = "Pivot Style",    options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS))
kzp_width           = input.int(1, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string(defval = 'Dotted', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)

var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip = "Show the most recent ranges of each selected killzone, from high to low", group = g_RNG)
show_range_avg      = input.bool(true,  "Show Average",        tooltip = "Show the average range of each selected killzone", group = g_RNG)
range_avg           = input.int(5, "Average Length", 0, tooltip = "This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group = g_RNG)
range_pos           = get_table_pos(input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG))
range_size          = get_size(input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG))

G_DODGY             = "FVG Settings"
fvg_min             = input.float(0.05, "FVG Min Size (%)",            step = 0.01, group = G_DODGY) / 100
show_fvg            = input.bool(true,  "Show FVG Boxes",              group = G_DODGY)
fvg_buf             = input.float(0.03, "FVG Invalidation Buffer (%)", step = 0.01, group = G_DODGY) / 100
hist_days           = input.int(14,     "Show Last N Days",            group = G_DODGY, minval = 1, maxval = 365)

G_MTF               = "MTF FVGs"
show_5m_fvg         = input.bool(true, "Show 5m FVGs",  group = G_MTF)
show_15m_fvg        = input.bool(true, "Show 15m FVGs", group = G_MTF)
show_1h_fvg         = input.bool(true, "Show 1h FVGs",  group = G_MTF)
show_4h_fvg         = input.bool(true, "Show 4h FVGs",  group = G_MTF)

G_4H                = "4H Key Levels"
show_4h_levels      = input.bool(true, "Show Prev 4H High/Low Lines", group = G_4H)

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

G_EXODUS            = "Exodus Labels"
exo_len             = input.int(14,    "Lookback Length",      group = G_EXODUS)
exo_thresh          = input.float(0.6, "Imbalance Threshold",  group = G_EXODUS, step = 0.1)


// ══════════════════════════════════════════════════════════════════════════════
// TYPES
// ══════════════════════════════════════════════════════════════════════════════

type kz
    string       _title
    array<box>   _box
    array<line>  _hi_line
    array<line>  _md_line
    array<line>  _lo_line
    array<label> _hi_label
    array<label> _lo_label
    array<bool>  _hi_valid
    array<bool>  _md_valid
    array<bool>  _lo_valid
    array<float> _range_store
    float        _range_current

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

type ts_helper
    string      session
    array<line> lines
    color       c


// ══════════════════════════════════════════════════════════════════════════════
// INIT
// ══════════════════════════════════════════════════════════════════════════════

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
             kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             asia, as_color, as_txt, ash_str, asl_str))
    if use_london
        res.push(kz_helper.new(
             kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             london, lo_color, lo_txt, loh_str, lol_str))
    if use_nyam
        res.push(kz_helper.new(
             kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nyam, na_color, na_txt, nah_str, nal_str))
    if use_nylu
        res.push(kz_helper.new(
             kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nylu, nl_color, nl_txt, nlh_str, nll_str))
    if use_nypm
        res.push(kz_helper.new(
             kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()),
             nypm, np_color, np_txt, nph_str, npl_str))
    res

var array<kz_helper> _kz = initKZ()

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


// ══════════════════════════════════════════════════════════════════════════════
// VARIABLES
// ══════════════════════════════════════════════════════════════════════════════

var d_hl       = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var w_hl       = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var m_hl       = dwm_hl.new(array.new_line(), array.new_line(), array.new_label(), array.new_label())
var d_info     = dwm_info.new("D")
var w_info     = dwm_info.new("W")
var m_info     = dwm_info.new("M")

var d_sep_line = array.new_line()
var w_sep_line = array.new_line()
var m_sep_line = array.new_line()
var d_line     = array.new_line()
var w_line     = array.new_line()
var m_line     = array.new_line()
var d_label    = array.new_label()
var w_label    = array.new_label()
var m_label    = array.new_label()

var transparent = #ffffff00
var ext_current = ext_which == 'Most Recent'
var ext_past    = ext_pivots == 'Past Mitigation'

t_co = not na(time("", cutoff, gmt_tz))

// 4H key levels state
var line  h4_hi_line    = na
var line  h4_lo_line    = na
var float h4_tracked_hi = na
var float h4_tracked_lo = na
var bool  h4_hi_broken  = false
var bool  h4_lo_broken  = false

// FVG state
var float bfvg_hi  = na
var float bfvg_lo  = na
var float sfvg_hi  = na
var float sfvg_lo  = na
var box   bfvg_box = na
var box   sfvg_box = na

var float f5_b_top  = na
var float f5_b_bot  = na
var box   f5_b_box  = na
var float f5_s_top  = na
var float f5_s_bot  = na
var box   f5_s_box  = na

var float f15_b_top = na
var float f15_b_bot = na
var box   f15_b_box = na
var float f15_s_top = na
var float f15_s_bot = na
var box   f15_s_box = na

var float f1h_b_top = na
var float f1h_b_bot = na
var box   f1h_b_box = na
var float f1h_s_top = na
var float f1h_s_bot = na
var box   f1h_s_box = na

var float f4h_b_top = na
var float f4h_b_bot = na
var box   f4h_b_box = na
var float f4h_s_top = na
var float f4h_s_bot = na
var box   f4h_s_box = na


// ══════════════════════════════════════════════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

get_box_color(color c) => color.new(c, box_transparency)
get_text_color(color c) => color.new(c, text_transparency)

// FVG helpers — defined before request.security() calls
f_fvg() =>
    bull   = high[2] < low  and high[2] > 0 and (low  - high[2]) / high[2] >= fvg_min
    bear   = low[2]  > high and low[2]  > 0 and (low[2] - high)  / low[2]  >= fvg_min
    b_top  = bull ? low     : na
    b_bot  = bull ? high[2] : na
    s_top  = bear ? low[2]  : na
    s_bot  = bear ? high    : na
    b_time = bull ? time[2] : na
    s_time = bear ? time[2] : na
    [bull, b_top, b_bot, b_time, bear, s_top, s_bot, s_time]

_mtf_box(int left_t, float top, float bot, color col, string lbl) =>
    t = math.max(top, bot)
    b = math.min(top, bot)
    box.new(left_t, t, time, b,
         xloc         = xloc.bar_time,
         border_color = color.new(col, 20),
         bgcolor      = color.new(col, 88),
         border_style = line.style_solid,
         border_width = 1,
         text         = lbl,
         text_size    = size.tiny,
         text_color   = color.new(col, 0),
         text_halign  = text.align_right,
         text_valign  = text.align_top)

// DWM
update_dwm_info(dwm_info n) =>
    if timeframe.change(n.tf)
        n.ph := n.h
        n.pl := n.l
        n.o  := open
        n.h  := high
        n.l  := low
    else
        n.h := math.max(high, n.h)
        n.l := math.min(low,  n.l)

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
    if t and not t_prev
        this.lines.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style = vl_style, width = vl_width, extend = extend.both, color = this.c))
    if not v_unlimited and this.lines.size() > max_days
        this.lines.pop().delete()

vlines() =>
    if tf_limit_is_equal_or_more_chart_tf
        for [_, value] in ts_data
            vline(value)

method hz_line(lines_helper this) =>
    bool t      = not na(time("", this.h, gmt_tz))
    bool t_prev = not na(time("", this.h, gmt_tz, bars_back = 1))
    hz hz       = this._hz
    if t and not t_prev
        hz.LN.unshift(line.new(bar_index, open, bar_index, open, style = hz_style, width = hz_width, color = this.h_color))
        hz.LB.unshift(label.new(bar_index, open, this.h_text, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
        array.unshift(hz.CO, false)
        if not open_unlimited and hz.LN.size() > max_days
            hz.LN.pop().delete()
            hz.LB.pop().delete()
            hz.CO.pop()
    if not t and hz.CO.size() > 0
        if not hz.CO.get(0)
            hz.LN.get(0).set_x2(bar_index)
            hz.LB.get(0).set_x(bar_index)
            if use_cutoff ? t_co : false
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

// Delete+recreate active session box every bar → always newest z-order → on top of FVGs
adjust_in_kz(kz kz, bool t, color c, string box_txt) =>
    if t and kz._box.size() > 0
        kzBox0    = kz._box.get(0)
        left_t    = kzBox0.get_left()
        newTop    = math.max(kzBox0.get_top(), high)
        newBottom = math.min(kzBox0.get_bottom(), low)
        kz._range_current := newTop - newBottom
        _c = get_box_color(c)
        _t = get_text_color(c)
        kzBox0.delete()
        kz._box.set(0, box.new(left_t, newTop, time, newBottom,
             xloc         = xloc.bar_time,
             border_color = show_kz ? _c : na,
             bgcolor      = show_kz ? _c : na,
             text         = show_kz and show_kz_text ? box_txt : na,
             text_color   = _t))

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

// Delete+recreate ALL closed session boxes every bar → always newest z-order → on top of FVGs
adjust_out_kz(kz kz, bool t, bool t_prev, color c, string box_txt) =>
    boxCount = kz._box.size()
    if not t and boxCount > 0
        if t_prev
            array.unshift(kz._range_store, kz._range_current)
            if kz._range_store.size() > range_avg
                kz._range_store.pop()
        _c = get_box_color(c)
        _t = get_text_color(c)
        for i = 0 to boxCount - 1
            b      = kz._box.get(i)
            left_t = b.get_left()
            top    = b.get_top()
            bot    = b.get_bottom()
            right  = b.get_right()
            b.delete()
            kz._box.set(i, box.new(left_t, top, right, bot,
                 xloc         = xloc.bar_time,
                 border_color = show_kz ? _c : na,
                 bgcolor      = show_kz ? _c : na,
                 text         = show_kz and show_kz_text ? box_txt : na,
                 text_color   = _t))

    if show_pivots and boxCount > 0
        for i = 0 to boxCount - 1
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
            kz._box.unshift(box.new(time, high, time, low,
                 xloc         = xloc.bar_time,
                 border_color = show_kz ? _c : na,
                 bgcolor      = show_kz ? _c : na,
                 text         = show_kz and show_kz_text ? box_txt : na,
                 text_color   = _t))

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

        adjust_in_kz(kz, t, c, box_txt)
        adjust_out_kz(kz, t, t_prev, c, box_txt)


// ══════════════════════════════════════════════════════════════════════════════
// EXECUTION
// ══════════════════════════════════════════════════════════════════════════════

if dhl or show_d_open
    update_dwm_info(d_info)
if whl or show_w_open
    update_dwm_info(w_info)
if mhl or show_m_open
    update_dwm_info(m_info)

// Exodus series
_ema_fast    = ta.ema(close, 8)
_ema_slow    = ta.ema(close, 21)
_momentum    = ta.mom(close, exo_len)
pumping      = _ema_fast > _ema_slow and _momentum > 0
dumping      = _ema_fast < _ema_slow and _momentum < 0
instinct_str = pumping ? "Pumping" : dumping ? "Dumping" : "-"
instinct_col = pumping ? color.lime : dumping ? color.red : color.gray

_body        = math.abs(close - open)
_fullRange   = high - low
_imbalance   = _fullRange > 0 ? _body / _fullRange : 0
imbalStr     = _imbalance >= exo_thresh ? "Imbalance" : "-"
imbalCol     = _imbalance >= exo_thresh ? color.white : color.gray

_atr         = ta.atr(exo_len)
_atr_avg     = ta.sma(_atr, exo_len)
chop         = _atr < _atr_avg * 0.85
vacuumStr    = chop ? "Chop" : "-"
vacuumCol    = chop ? color.white : color.gray

in_hist_window = time >= (timenow - hist_days * 86400000)

// ── 4H Key Levels ─────────────────────────────────────────────────────────────
// Pull previous complete 4H bar's high/low directly — same value on every timeframe
prev_4h_hi   = request.security(syminfo.tickerid, "240", high[1], lookahead = barmerge.lookahead_off)
prev_4h_lo   = request.security(syminfo.tickerid, "240", low[1],  lookahead = barmerge.lookahead_off)
prev_4h_time = request.security(syminfo.tickerid, "240", time[1], lookahead = barmerge.lookahead_off)
cur_4h_time  = request.security(syminfo.tickerid, "240", time,    lookahead = barmerge.lookahead_off)
new_4h_bar   = ta.change(cur_4h_time) != 0

if new_4h_bar and show_4h_levels and not na(prev_4h_hi) and not na(prev_4h_lo)
    if not na(h4_hi_line)
        line.delete(h4_hi_line)
    if not na(h4_lo_line)
        line.delete(h4_lo_line)
    h4_tracked_hi := prev_4h_hi
    h4_tracked_lo := prev_4h_lo
    h4_hi_broken  := false
    h4_lo_broken  := false
    h4_hi_line := line.new(prev_4h_time, prev_4h_hi, time, prev_4h_hi,
         xloc = xloc.bar_time, color = color.white, style = line.style_solid, width = 2)
    h4_lo_line := line.new(prev_4h_time, prev_4h_lo, time, prev_4h_lo,
         xloc = xloc.bar_time, color = color.white, style = line.style_solid, width = 2)

if show_4h_levels
    if not h4_hi_broken and not na(h4_hi_line)
        line.set_x2(h4_hi_line, time)
    if not h4_lo_broken and not na(h4_lo_line)
        line.set_x2(h4_lo_line, time)
    if not h4_hi_broken and not na(h4_tracked_hi) and high > h4_tracked_hi
        h4_hi_broken := true
        if not na(h4_hi_line)
            line.set_color(h4_hi_line, color.new(color.white, 60))
            line.set_style(h4_hi_line, line.style_dashed)
            line.set_x2(h4_hi_line, time)
    if not h4_lo_broken and not na(h4_tracked_lo) and low < h4_tracked_lo
        h4_lo_broken := true
        if not na(h4_lo_line)
            line.set_color(h4_lo_line, color.new(color.white, 60))
            line.set_style(h4_lo_line, line.style_dashed)
            line.set_x2(h4_lo_line, time)

// ── Current-TF FVG ────────────────────────────────────────────────────────────
bull_fvg_formed = high[2] < low  and high[2] > 0 and (low  - high[2]) / high[2] >= fvg_min
bear_fvg_formed = low[2]  > high and low[2]  > 0 and (low[2] - high)  / low[2]  >= fvg_min

if bull_fvg_formed
    bfvg_hi := low
    bfvg_lo := high[2]
if bear_fvg_formed
    sfvg_hi := low[2]
    sfvg_lo := high

bull_fvg_invalid = not na(bfvg_lo) and close < bfvg_lo * (1 - fvg_buf)
bear_fvg_invalid = not na(sfvg_hi) and close > sfvg_hi * (1 + fvg_buf)

if bull_fvg_invalid
    bfvg_hi := na
    bfvg_lo := na
if bear_fvg_invalid
    sfvg_hi := na
    sfvg_lo := na

if show_fvg and in_hist_window
    if bull_fvg_formed
        if not na(bfvg_box)
            box.delete(bfvg_box)
        bfvg_box := box.new(time[2], low, time, high[2],
             xloc         = xloc.bar_time,
             border_color = color.new(color.white, 20),
             bgcolor      = color.new(color.white, 82),
             border_style = line.style_solid, border_width = 1,
             text         = "FVG", text_size = size.tiny,
             text_color   = color.new(color.white, 40),
             text_halign  = text.align_right, text_valign = text.align_top)
    if bear_fvg_formed
        if not na(sfvg_box)
            box.delete(sfvg_box)
        sfvg_box := box.new(time[2], low[2], time, high,
             xloc         = xloc.bar_time,
             border_color = color.new(color.white, 20),
             bgcolor      = color.new(color.white, 82),
             border_style = line.style_solid, border_width = 1,
             text         = "FVG", text_size = size.tiny,
             text_color   = color.new(color.white, 40),
             text_halign  = text.align_right, text_valign = text.align_top)
    if bull_fvg_invalid and not na(bfvg_box)
        box.set_right(bfvg_box, time)
        box.set_bgcolor(bfvg_box, color.new(color.white, 96))
        box.set_border_color(bfvg_box, color.new(color.white, 80))
        bfvg_box := na
    if bear_fvg_invalid and not na(sfvg_box)
        box.set_right(sfvg_box, time)
        box.set_bgcolor(sfvg_box, color.new(color.white, 96))
        box.set_border_color(sfvg_box, color.new(color.white, 80))
        sfvg_box := na

if not na(bfvg_box)
    box.set_right(bfvg_box, time)
if not na(sfvg_box)
    box.set_right(sfvg_box, time)

// ── MTF FVGs ──────────────────────────────────────────────────────────────────
chart_secs = timeframe.in_seconds()

[f5_bull,  f5_btop,  f5_bbot,  f5_btime,  f5_bear,  f5_stop,  f5_sbot,  f5_stime]  = request.security(syminfo.tickerid, "5",   f_fvg(), lookahead = barmerge.lookahead_off)
[f15_bull, f15_btop, f15_bbot, f15_btime, f15_bear, f15_stop, f15_sbot, f15_stime] = request.security(syminfo.tickerid, "15",  f_fvg(), lookahead = barmerge.lookahead_off)
[f1h_bull, f1h_btop, f1h_bbot, f1h_btime, f1h_bear, f1h_stop, f1h_sbot, f1h_stime] = request.security(syminfo.tickerid, "60",  f_fvg(), lookahead = barmerge.lookahead_off)
[f4h_bull, f4h_btop, f4h_bbot, f4h_btime, f4h_bear, f4h_stop, f4h_sbot, f4h_stime] = request.security(syminfo.tickerid, "240", f_fvg(), lookahead = barmerge.lookahead_off)

f5_bull_new  = f5_bull  and not f5_bull[1]  and chart_secs < 300
f5_bear_new  = f5_bear  and not f5_bear[1]  and chart_secs < 300
f15_bull_new = f15_bull and not f15_bull[1] and chart_secs < 900
f15_bear_new = f15_bear and not f15_bear[1] and chart_secs < 900
f1h_bull_new = f1h_bull and not f1h_bull[1] and chart_secs < 3600
f1h_bear_new = f1h_bear and not f1h_bear[1] and chart_secs < 3600
f4h_bull_new = f4h_bull and not f4h_bull[1] and chart_secs < 14400
f4h_bear_new = f4h_bear and not f4h_bear[1] and chart_secs < 14400

// 5m
if f5_bull_new and not na(f5_btop) and not na(f5_bbot) and f5_btop > f5_bbot and not na(f5_btime)
    f5_b_top := f5_btop
    f5_b_bot := f5_bbot
    if show_5m_fvg and in_hist_window
        if not na(f5_b_box)
            box.delete(f5_b_box)
        f5_b_box := _mtf_box(f5_btime, f5_b_top, f5_b_bot, color.white, "5m")
if f5_bear_new and not na(f5_stop) and not na(f5_sbot) and f5_stop > f5_sbot and not na(f5_stime)
    f5_s_top := f5_stop
    f5_s_bot := f5_sbot
    if show_5m_fvg and in_hist_window
        if not na(f5_s_box)
            box.delete(f5_s_box)
        f5_s_box := _mtf_box(f5_stime, f5_s_top, f5_s_bot, color.white, "5m")
if not na(f5_b_bot) and close < f5_b_bot * (1 - fvg_buf)
    f5_b_top := na
    f5_b_bot := na
    if show_5m_fvg and not na(f5_b_box)
        box.set_right(f5_b_box, time)
        box.set_bgcolor(f5_b_box, color.new(color.white, 97))
        box.set_border_color(f5_b_box, color.new(color.white, 75))
        f5_b_box := na
if not na(f5_s_top) and close > f5_s_top * (1 + fvg_buf)
    f5_s_top := na
    f5_s_bot := na
    if show_5m_fvg and not na(f5_s_box)
        box.set_right(f5_s_box, time)
        box.set_bgcolor(f5_s_box, color.new(color.white, 97))
        box.set_border_color(f5_s_box, color.new(color.white, 75))
        f5_s_box := na

// 15m
if f15_bull_new and not na(f15_btop) and not na(f15_bbot) and f15_btop > f15_bbot and not na(f15_btime)
    f15_b_top := f15_btop
    f15_b_bot := f15_bbot
    if show_15m_fvg and in_hist_window
        if not na(f15_b_box)
            box.delete(f15_b_box)
        f15_b_box := _mtf_box(f15_btime, f15_b_top, f15_b_bot, color.white, "15m")
if f15_bear_new and not na(f15_stop) and not na(f15_sbot) and f15_stop > f15_sbot and not na(f15_stime)
    f15_s_top := f15_stop
    f15_s_bot := f15_sbot
    if show_15m_fvg and in_hist_window
        if not na(f15_s_box)
            box.delete(f15_s_box)
        f15_s_box := _mtf_box(f15_stime, f15_s_top, f15_s_bot, color.white, "15m")
if not na(f15_b_bot) and close < f15_b_bot * (1 - fvg_buf)
    f15_b_top := na
    f15_b_bot := na
    if show_15m_fvg and not na(f15_b_box)
        box.set_right(f15_b_box, time)
        box.set_bgcolor(f15_b_box, color.new(color.white, 97))
        box.set_border_color(f15_b_box, color.new(color.white, 75))
        f15_b_box := na
if not na(f15_s_top) and close > f15_s_top * (1 + fvg_buf)
    f15_s_top := na
    f15_s_bot := na
    if show_15m_fvg and not na(f15_s_box)
        box.set_right(f15_s_box, time)
        box.set_bgcolor(f15_s_box, color.new(color.white, 97))
        box.set_border_color(f15_s_box, color.new(color.white, 75))
        f15_s_box := na

// 1h
if f1h_bull_new and not na(f1h_btop) and not na(f1h_bbot) and f1h_btop > f1h_bbot and not na(f1h_btime)
    f1h_b_top := f1h_btop
    f1h_b_bot := f1h_bbot
    if show_1h_fvg and in_hist_window
        if not na(f1h_b_box)
            box.delete(f1h_b_box)
        f1h_b_box := _mtf_box(f1h_btime, f1h_b_top, f1h_b_bot, color.white, "1h")
if f1h_bear_new and not na(f1h_stop) and not na(f1h_sbot) and f1h_stop > f1h_sbot and not na(f1h_stime)
    f1h_s_top := f1h_stop
    f1h_s_bot := f1h_sbot
    if show_1h_fvg and in_hist_window
        if not na(f1h_s_box)
            box.delete(f1h_s_box)
        f1h_s_box := _mtf_box(f1h_stime, f1h_s_top, f1h_s_bot, color.white, "1h")
if not na(f1h_b_bot) and close < f1h_b_bot * (1 - fvg_buf)
    f1h_b_top := na
    f1h_b_bot := na
    if show_1h_fvg and not na(f1h_b_box)
        box.set_right(f1h_b_box, time)
        box.set_bgcolor(f1h_b_box, color.new(color.white, 97))
        box.set_border_color(f1h_b_box, color.new(color.white, 75))
        f1h_b_box := na
if not na(f1h_s_top) and close > f1h_s_top * (1 + fvg_buf)
    f1h_s_top := na
    f1h_s_bot := na
    if show_1h_fvg and not na(f1h_s_box)
        box.set_right(f1h_s_box, time)
        box.set_bgcolor(f1h_s_box, color.new(color.white, 97))
        box.set_border_color(f1h_s_box, color.new(color.white, 75))
        f1h_s_box := na

// 4h
if f4h_bull_new and not na(f4h_btop) and not na(f4h_bbot) and f4h_btop > f4h_bbot and not na(f4h_btime)
    f4h_b_top := f4h_btop
    f4h_b_bot := f4h_bbot
    if show_4h_fvg and in_hist_window
        if not na(f4h_b_box)
            box.delete(f4h_b_box)
        f4h_b_box := _mtf_box(f4h_btime, f4h_b_top, f4h_b_bot, color.white, "4h")
if f4h_bear_new and not na(f4h_stop) and not na(f4h_sbot) and f4h_stop > f4h_sbot and not na(f4h_stime)
    f4h_s_top := f4h_stop
    f4h_s_bot := f4h_sbot
    if show_4h_fvg and in_hist_window
        if not na(f4h_s_box)
            box.delete(f4h_s_box)
        f4h_s_box := _mtf_box(f4h_stime, f4h_s_top, f4h_s_bot, color.white, "4h")
if not na(f4h_b_bot) and close < f4h_b_bot * (1 - fvg_buf)
    f4h_b_top := na
    f4h_b_bot := na
    if show_4h_fvg and not na(f4h_b_box)
        box.set_right(f4h_b_box, time)
        box.set_bgcolor(f4h_b_box, color.new(color.white, 97))
        box.set_border_color(f4h_b_box, color.new(color.white, 75))
        f4h_b_box := na
if not na(f4h_s_top) and close > f4h_s_top * (1 + fvg_buf)
    f4h_s_top := na
    f4h_s_bot := na
    if show_4h_fvg and not na(f4h_s_box)
        box.set_right(f4h_s_box, time)
        box.set_bgcolor(f4h_s_box, color.new(color.white, 97))
        box.set_border_color(f4h_s_box, color.new(color.white, 75))
        f4h_s_box := na

// Extend all live MTF boxes to current bar
if not na(f5_b_box)
    box.set_right(f5_b_box, time)
if not na(f5_s_box)
    box.set_right(f5_s_box, time)
if not na(f15_b_box)
    box.set_right(f15_b_box, time)
if not na(f15_s_box)
    box.set_right(f15_s_box, time)
if not na(f1h_b_box)
    box.set_right(f1h_b_box, time)
if not na(f1h_s_box)
    box.set_right(f1h_s_box, time)
if not na(f4h_b_box)
    box.set_right(f4h_b_box, time)
if not na(f4h_s_box)
    box.set_right(f4h_s_box, time)

// ── KZ loop — runs AFTER all FVG drawing so session boxes are the newest objects ──
for [_, value] in _kz
    manage_kz(value)

dwm()
vlines()
hz_lines()

new_dow_time = dow_xloc == 'Midday' ? time - timeframe.in_seconds("D") / 2 * 1000 : time
new_day      = dayofweek(new_dow_time, gmt_tz) != dayofweek(new_dow_time, gmt_tz)[1]
var dow_top  = dow_yloc == 'Top'

plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 1 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "SUNDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 2 and new_day,                        location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "MONDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 3 and new_day,                        location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "TUESDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 4 and new_day,                        location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "WEDNESDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 5 and new_day,                        location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "THURSDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 6 and new_day,                        location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "FRIDAY")
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 7 and new_day and not dow_hide_wknd, location = dow_top ? location.top : location.bottom, char = '', textcolor = txt_color, text = "SATURDAY")

// ── KZ Range Table ────────────────────────────────────────────────────────────
get_min_days_stored() =>
    store = array.new_int()
    for [_, value] in _kz
        int tmpStoreSize = value._kz._range_store.size()
        if tmpStoreSize > 0
            store.push(tmpStoreSize)
    store.min()

method set_table(table tbl, kz kz, int row, string txt, bool t, color col) =>
    table.cell(tbl, 0, row, txt,                              text_size = range_size, bgcolor = get_box_color(col),          text_color = txt_color)
    table.cell(tbl, 1, row, str.tostring(kz._range_current),  text_size = range_size, bgcolor = t ? get_box_color(col) : na, text_color = txt_color)
    if show_range_avg
        table.cell(tbl, 2, row, str.tostring(kz._range_store.avg()), text_size = range_size, text_color = txt_color)

if show_range and barstate.islast
    var tbl = table.new(range_pos, 10, 10, chart.bg_color, chart.fg_color, 2, chart.fg_color, 1)
    table.cell(tbl, 0, 0, "Killzone", text_size = range_size, text_color = txt_color)
    table.cell(tbl, 1, 0, "Range",    text_size = range_size, text_color = txt_color)
    if show_range_avg
        table.cell(tbl, 2, 0, "Avg (" + str.tostring(get_min_days_stored()) + ")", text_size = range_size, text_color = txt_color)
    for [index, value] in _kz
        set_table(tbl, value._kz, index + 1, value.box_txt, not na(time("", value.session, gmt_tz)), value.c)

// ── Dando / Exodus Table ──────────────────────────────────────────────────────
var table exo_tbl = table.new(position.bottom_right, 2, 4,
     bgcolor      = color.new(color.black, 30),
     border_color = color.gray,
     border_width = 1)

if barstate.islast
    table.cell(exo_tbl, 0, 0, "Dando",      text_color = color.white,  text_size = size.normal)
    table.cell(exo_tbl, 1, 0, "",            text_color = color.white)
    table.cell(exo_tbl, 0, 1, "Instinct",   text_color = color.silver, text_size = size.small)
    table.cell(exo_tbl, 1, 1, instinct_str, text_color = instinct_col, text_size = size.small)
    table.cell(exo_tbl, 0, 2, "Imbalance",  text_color = color.silver, text_size = size.small)
    table.cell(exo_tbl, 1, 2, imbalStr,     text_color = imbalCol,     text_size = size.small)
    table.cell(exo_tbl, 0, 3, "Vacuum",     text_color = color.silver, text_size = size.small)
    table.cell(exo_tbl, 1, 3, vacuumStr,    text_color = vacuumCol,    text_size = size.small)
````

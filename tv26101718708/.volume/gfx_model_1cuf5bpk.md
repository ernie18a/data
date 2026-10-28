# GFX Model

- url: https://www.tradingview.com/script/1cuf5bpK-GFX-Model/
- type: indicator
- pine_id: PUB;3045489eff504d9d82879e1c6477b3e1
- version: 1.0

## Description

🎯 Why Use This Indicator?

This tool is designed to give you:

-Clear market structure (CISD)
-Session-based context (Killzones)
-Trend + bias (EMAs + VWAP)
-Timing precision (timestamps & opens)

Instead of stacking multiple indicators, everything is combined into one clean system.


Made by Gerald Hildebrand

## Source Code

````pine
//@version=6
indicator("GFX Model", shorttitle="GFX Suite", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================================================================
// EMA SETTINGS
// ============================================================================
groupEMA = "EMA Settings"

ema1Enabled = input.bool(true, "Show EMA 1", group=groupEMA)
ema1Length  = input.int(20, "EMA 1 Length", minval=1, group=groupEMA)
ema1Color   = input.color(color.blue, "EMA 1 Color", group=groupEMA)
ema1Width   = input.int(2, "EMA 1 Thickness", minval=1, maxval=5, group=groupEMA)

ema2Enabled = input.bool(true, "Show EMA 2", group=groupEMA)
ema2Length  = input.int(50, "EMA 2 Length", minval=1, group=groupEMA)
ema2Color   = input.color(color.orange, "EMA 2 Color", group=groupEMA)
ema2Width   = input.int(2, "EMA 2 Thickness", minval=1, maxval=5, group=groupEMA)

ema3Enabled = input.bool(true, "Show EMA 3", group=groupEMA)
ema3Length  = input.int(200, "EMA 3 Length", minval=1, group=groupEMA)
ema3Color   = input.color(color.red, "EMA 3 Color", group=groupEMA)
ema3Width   = input.int(2, "EMA 3 Thickness", minval=1, maxval=5, group=groupEMA)

// ============================================================================
// VWAP SETTINGS
// ============================================================================
groupVWAP = "VWAP Settings"

showVWAP  = input.bool(true, "Show VWAP", group=groupVWAP)
vwapColor = input.color(color.purple, "VWAP Color", group=groupVWAP)
vwapWidth = input.int(2, "VWAP Thickness", minval=1, maxval=5, group=groupVWAP)

// ============================================================================
// CISD SETTINGS
// ============================================================================
groupCISD = "CISD Settings"

bullishBreakColor = input.color(color.black, "Bull CISD Color", inline="bup", group=groupCISD)
bearishBreakColor = input.color(color.black, "Bear CISD Color", inline="bep", group=groupCISD)

bullStr = input.string("+CISD", "Bull Label", inline="bup", group=groupCISD)
bearStr = input.string("-CISD", "Bear Label", inline="bep", group=groupCISD)

bullishAlerts = input.bool(false, "Bullish Alert?", inline="bup", group=groupCISD)
bearishAlerts = input.bool(false, "Bearish Alert?", inline="bep", group=groupCISD)

cisdLineWidth     = input.int(1, "CISD Line Width", minval=1, maxval=5, group=groupCISD)
lookAheadBars     = input.int(5, "CISD Line Extension Bars", minval=1, maxval=50, group=groupCISD)
cisdStyleOption   = input.string("Solid (─)", "CISD Line Style", options=["Solid (─)", "Dotted (┈)", "Dashed (╌)"], group=groupCISD)
keepLevels        = input.bool(false, "Keep Old CISD Levels", group=groupCISD)

groupCISDTable = "CISD Table"
showCisdTable = input.bool(false, "Enable CISD Stat Table", group=groupCISDTable)
cisdTablePosition = input.string("Top Right", "CISD Table Position", options=["Top Right", "Bottom Right", "Middle Right", "Bottom Center", "Middle Left"], group=groupCISDTable)

// ============================================================================
// CONSTANT FUNCTIONS
// ============================================================================
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

get_cisd_table_pos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Bottom Right"  => position.bottom_right
        "Middle Right"  => position.middle_right
        "Bottom Center" => position.bottom_center
        "Middle Left"   => position.middle_left

// ============================================================================
// EMA + VWAP CALCS
// ============================================================================
ema1 = ta.ema(close, ema1Length)
ema2 = ta.ema(close, ema2Length)
ema3 = ta.ema(close, ema3Length)
vwapValue = ta.vwap(hlc3)

plot(ema1Enabled ? ema1 : na, title="EMA 1", color=ema1Color, linewidth=ema1Width)
plot(ema2Enabled ? ema2 : na, title="EMA 2", color=ema2Color, linewidth=ema2Width)
plot(ema3Enabled ? ema3 : na, title="EMA 3", color=ema3Color, linewidth=ema3Width)
plot(showVWAP ? vwapValue : na, title="VWAP", color=vwapColor, linewidth=vwapWidth)

// ============================================================================
// KILLZONES INPUTS
// ============================================================================
var g_SETTINGS      = "Killzones Settings"
max_days            = input.int(3, "Session Drawing Limit", 1, tooltip="Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, open lines, etc.)", group=g_SETTINGS)
tf_limit            = input.timeframe("30", "Timeframe Limit", tooltip="Drawings will not appear on timeframes greater than or equal to this", group=g_SETTINGS)
gmt_tz              = input.string("America/New_York", "Timezone", options=['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip="Note GMT is not adjusted to reflect Daylight Saving Time changes", group=g_SETTINGS)
lbl_size            = get_size(input.string("Normal", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], tooltip="The size of all labels", group=g_SETTINGS))
txt_color           = input.color(color.black, "Text Color", tooltip="The color of all label and table text", group=g_SETTINGS)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline="CO", tooltip="When enabled, all pivots and open price lines will stop extending at this time", group=g_SETTINGS)
cutoff              = input.session("1800-1801", "", inline="CO", group=g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds("") <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzone Boxes"
show_kz             = input.bool(true, "Show Killzone Boxes", inline="KZ", group=g_KZ)
show_kz_text        = input.bool(true, "Display Text", inline="KZ", group=g_KZ)

use_asia            = input.bool(true, "", inline="ASIA", group=g_KZ)
as_txt              = input.string("Asia", "", inline="ASIA", group=g_KZ)
asia                = input.session("2000-0000", "", inline="ASIA", group=g_KZ)
as_color            = input.color(color.blue, "", inline="ASIA", group=g_KZ)

use_london          = input.bool(true, "", inline="LONDON", group=g_KZ)
lo_txt              = input.string("London", "", inline="LONDON", group=g_KZ)
london              = input.session("0200-0500", "", inline="LONDON", group=g_KZ)
lo_color            = input.color(color.red, "", inline="LONDON", group=g_KZ)

use_nyam            = input.bool(true, "", inline="NYAM", group=g_KZ)
na_txt              = input.string("NY AM", "", inline="NYAM", group=g_KZ)
nyam                = input.session("0930-1100", "", inline="NYAM", group=g_KZ)
na_color            = input.color(#089981, "", inline="NYAM", group=g_KZ)

use_nylu            = input.bool(true, "", inline="NYLU", group=g_KZ)
nl_txt              = input.string("NY Lunch", "", inline="NYLU", group=g_KZ)
nylu                = input.session("1200-1300", "", inline="NYLU", group=g_KZ)
nl_color            = input.color(color.yellow, "", inline="NYLU", group=g_KZ)

use_nypm            = input.bool(true, "", inline="NYPM", group=g_KZ)
np_txt              = input.string("NY PM", "", inline="NYPM", group=g_KZ)
nypm                = input.session("1330-1600", "", inline="NYPM", group=g_KZ)
np_color            = input.color(color.purple, "", inline="NYPM", group=g_KZ)

box_transparency    = input.int(70, "Box Transparency", 0, 100, group=g_KZ)
text_transparency   = input.int(50, "Text Transparency", 0, 100, group=g_KZ)

var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline="PV", group=g_LABELS)
use_alerts          = input.bool(true, "Alert Broken Pivots", inline="PV", tooltip="The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group=g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline="mp", group=g_LABELS)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline="mp", group=g_LABELS)
show_labels         = input.bool(true, "Show Pivot Labels", inline="LB", tooltip="Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group=g_LABELS)
label_price         = input.bool(false, "Display Price", inline="LB", group=g_LABELS)
label_right         = input.bool(false, "Right Side", inline="LB", group=g_LABELS)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots...", options=["Until Mitigated", "Past Mitigation"], group=g_LABELS)
ext_which           = input.string("Most Recent", "...From Which Sessions", options=["Most Recent", "All"], group=g_LABELS)

ash_str             = input.string("AS.H", "Killzone 1 Labels", inline="L_AS", group=g_LABELS)
asl_str             = input.string("AS.L", "", inline="L_AS", group=g_LABELS)

loh_str             = input.string("LO.H", "Killzone 2 Labels", inline="L_LO", group=g_LABELS)
lol_str             = input.string("LO.L", "", inline="L_LO", group=g_LABELS)

nah_str             = input.string("NYAM.H", "Killzone 3 Labels", inline="L_NA", group=g_LABELS)
nal_str             = input.string("NYAM.L", "", inline="L_NA", group=g_LABELS)

nlh_str             = input.string("NYL.H", "Killzone 4 Labels", inline="L_NL", group=g_LABELS)
nll_str             = input.string("NYL.L", "", inline="L_NL", group=g_LABELS)

nph_str             = input.string("NYPM.H", "Killzone 5 Labels", inline="L_NP", group=g_LABELS)
npl_str             = input.string("NYPM.L", "", inline="L_NP", group=g_LABELS)

kzp_style           = get_line_type(input.string(defval="Solid", title="Pivot Style", options=["Solid", "Dotted", "Dashed"], inline="KZP", group=g_LABELS))
kzp_width           = input.int(1, "", inline="KZP", group=g_LABELS)
kzm_style           = get_line_type(input.string(defval="Dotted", title="Midpoint Style", options=["Solid", "Dotted", "Dashed"], inline="KZM", group=g_LABELS))
kzm_width           = input.int(1, "", inline="KZM", group=g_LABELS)

var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip="Show the most recent ranges of each selected killzone, from high to low", group=g_RNG)
show_range_avg      = input.bool(true, "Show Average", tooltip="Show the average range of each selected killzone", group=g_RNG)
range_avg           = input.int(5, "Average Length", 0, tooltip="This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group=g_RNG)
range_pos           = get_table_pos(input.string("Top Right", "Table Position", options=["Bottom Center", "Bottom Left", "Bottom Right", "Middle Center", "Middle Left", "Middle Right", "Top Center", "Top Left", "Top Right"], group=g_RNG))
range_size          = get_size(input.string("Normal", "Table Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=g_RNG))

var g_DWM           = "Day - Week - Month"
sep_unlimited       = input.bool(false, "Unlimited", tooltip="Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group=g_DWM)
alert_HL            = input.bool(false, "Alert High/Low Break", tooltip="Alert when any selected highs and lows are traded through. The desired timeframe's high/low option must be enabled at the time that an alert is created", group=g_DWM)

show_d_open         = input.bool(false, "D Open", inline="DO", group=g_DWM)
dhl                 = input.bool(false, "High/Low", inline="DO", group=g_DWM)
ds                  = input.bool(false, "Separators", inline="DO", group=g_DWM)
d_color             = input.color(color.blue, "", inline="DO", group=g_DWM)

show_w_open         = input.bool(false, "W Open", inline="WO", group=g_DWM)
whl                 = input.bool(false, "High/Low", inline="WO", group=g_DWM)
ws                  = input.bool(false, "Separators", inline="WO", group=g_DWM)
w_color             = input.color(#089981, "", inline="WO", group=g_DWM)

show_m_open         = input.bool(false, "M Open", inline="MO", group=g_DWM)
mhl                 = input.bool(false, "High/Low", inline="MO", group=g_DWM)
ms                  = input.bool(false, "Separators", inline="MO", group=g_DWM)
m_color             = input.color(color.red, "", inline="MO", group=g_DWM)

htf_style           = get_line_type(input.string(defval="Solid", title="Style", options=["Solid", "Dotted", "Dashed"], inline="D0", group=g_DWM))
htf_width           = input.int(1, "", inline="D0", group=g_DWM)

dow_labels          = input.bool(true, "Day of Week Labels", inline="DOW", group=g_DWM)
dow_yloc            = input.string("Bottom", "", options=["Top", "Bottom"], inline="DOW", group=g_DWM)
dow_xloc            = input.string("Midnight", "", options=["Midnight", "Midday"], inline="DOW", group=g_DWM)
dow_hide_wknd       = input.bool(true, "Hide Weekend Labels", group=g_DWM)

var g_OPEN          = "Opening Prices"
open_unlimited      = input.bool(false, "Unlimited", tooltip="Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group=g_OPEN)

use_h1              = input.bool(false, "", inline="H1", group=g_OPEN)
h1_text             = input.string("True Day Open", "", inline="H1", group=g_OPEN)
h1                  = input.session("0000-0001", "", inline="H1", group=g_OPEN)
h1_color            = input.color(color.black, "", inline="H1", group=g_OPEN)

use_h2              = input.bool(false, "", inline="H2", group=g_OPEN)
h2_text             = input.string("06:00", "", inline="H2", group=g_OPEN)
h2                  = input.session("0600-0601", "", inline="H2", group=g_OPEN)
h2_color            = input.color(color.black, "", inline="H2", group=g_OPEN)

use_h3              = input.bool(false, "", inline="H3", group=g_OPEN)
h3_text             = input.string("10:00", "", inline="H3", group=g_OPEN)
h3                  = input.session("1000-1001", "", inline="H3", group=g_OPEN)
h3_color            = input.color(color.black, "", inline="H3", group=g_OPEN)

use_h4              = input.bool(false, "", inline="H4", group=g_OPEN)
h4_text             = input.string("14:00", "", inline="H4", group=g_OPEN)
h4                  = input.session("1400-1401", "", inline="H4", group=g_OPEN)
h4_color            = input.color(color.black, "", inline="H4", group=g_OPEN)

use_h5              = input.bool(false, "", inline="H5", group=g_OPEN)
h5_text             = input.string("00:00", "", inline="H5", group=g_OPEN)
h5                  = input.session("0000-0001", "", inline="H5", group=g_OPEN)
h5_color            = input.color(color.black, "", inline="H5", group=g_OPEN)

use_h6              = input.bool(false, "", inline="H6", group=g_OPEN)
h6_text             = input.string("00:00", "", inline="H6", group=g_OPEN)
h6                  = input.session("0000-0001", "", inline="H6", group=g_OPEN)
h6_color            = input.color(color.black, "", inline="H6", group=g_OPEN)

use_h7              = input.bool(false, "", inline="H7", group=g_OPEN)
h7_text             = input.string("00:00", "", inline="H7", group=g_OPEN)
h7                  = input.session("0000-0001", "", inline="H7", group=g_OPEN)
h7_color            = input.color(color.black, "", inline="H7", group=g_OPEN)

use_h8              = input.bool(false, "", inline="H8", group=g_OPEN)
h8_text             = input.string("00:00", "", inline="H8", group=g_OPEN)
h8                  = input.session("0000-0001", "", inline="H8", group=g_OPEN)
h8_color            = input.color(color.black, "", inline="H8", group=g_OPEN)

hz_style            = get_line_type(input.string(defval="Dotted", title="Style", options=["Solid", "Dotted", "Dashed"], inline="H0", group=g_OPEN))
hz_width            = input.int(1, "", inline="H0", group=g_OPEN)

var g_VERTICAL      = "Timestamps"
v_unlimited         = input.bool(false, "Unlimited", tooltip="Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group=g_VERTICAL)

use_v1              = input.bool(false, "", inline="V1", group=g_VERTICAL)
v1                  = input.session("0000-0001", "", inline="V1", group=g_VERTICAL)
v1_color            = input.color(color.black, "", inline="V1", group=g_VERTICAL)

use_v2              = input.bool(false, "", inline="V2", group=g_VERTICAL)
v2                  = input.session("0800-0801", "", inline="V2", group=g_VERTICAL)
v2_color            = input.color(color.black, "", inline="V2", group=g_VERTICAL)

use_v3              = input.bool(false, "", inline="V3", group=g_VERTICAL)
v3                  = input.session("1000-1001", "", inline="V3", group=g_VERTICAL)
v3_color            = input.color(color.black, "", inline="V3", group=g_VERTICAL)

use_v4              = input.bool(false, "", inline="V4", group=g_VERTICAL)
v4                  = input.session("1200-1201", "", inline="V4", group=g_VERTICAL)
v4_color            = input.color(color.black, "", inline="V4", group=g_VERTICAL)

vl_style            = get_line_type(input.string(defval="Dotted", title="Style", options=["Solid", "Dotted", "Dashed"], inline="V0", group=g_VERTICAL))
vl_width            = input.int(1, "", inline="V0", group=g_VERTICAL)

// ============================================================================
// KILLZONE TYPES / VARIABLES
// ============================================================================
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
        res.push(kz_helper.new(kz.new(as_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()), asia, as_color, as_txt, ash_str, asl_str))
    if use_london
        res.push(kz_helper.new(kz.new(lo_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()), london, lo_color, lo_txt, loh_str, lol_str))
    if use_nyam
        res.push(kz_helper.new(kz.new(na_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()), nyam, na_color, na_txt, nah_str, nal_str))
    if use_nylu
        res.push(kz_helper.new(kz.new(nl_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()), nylu, nl_color, nl_txt, nlh_str, nll_str))
    if use_nypm
        res.push(kz_helper.new(kz.new(np_txt, array.new_box(), array.new_line(), array.new_line(), array.new_line(), array.new_label(), array.new_label(), array.new_bool(), array.new_bool(), array.new_bool(), array.new_float()), nypm, np_color, np_txt, nph_str, npl_str))
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
var ext_current = ext_which == "Most Recent"
var ext_past = ext_pivots == "Past Mitigation"

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

// ============================================================================
// KILLZONE FUNCTIONS
// ============================================================================
get_box_color(color c) =>
    color.new(c, box_transparency)

get_text_color(color c) =>
    color.new(c, text_transparency)

dwm_sep(string tf, bool use, array<line> arr, color col) =>
    if use
        if timeframe.change(tf)
            arr.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style=htf_style, width=htf_width, extend=extend.both, color=col))
            if not sep_unlimited and arr.size() > max_days
                arr.pop().delete()

dwm_open(string tf, bool use, array<line> lns, array<label> lbls, dwm_info n, color col) =>
    if use
        if lns.size() > 0
            lns.get(0).set_x2(time)
            lbls.get(0).set_x(time)
        if timeframe.change(tf)
            lns.unshift(line.new(time, n.o, time, n.o, xloc=xloc.bar_time, style=htf_style, width=htf_width, color=col))
            lbls.unshift(label.new(time, n.o, tf + " OPEN", xloc=xloc.bar_time, style=label.style_label_left, color=transparent, textcolor=txt_color, size=lbl_size))
            if not sep_unlimited and lns.size() > max_days
                lns.pop().delete()
                lbls.pop().delete()

dwm_hl_func(string tf, bool use, dwm_hl hl, dwm_info n, color col) =>
    if use
        if hl.hi_line.size() > 0
            hl.hi_line.get(0).set_x2(time)
            hl.lo_line.get(0).set_x2(time)
            hl.hi_label.get(0).set_x(time)
            hl.lo_label.get(0).set_x(time)
        if timeframe.change(tf)
            hl.hi_line.unshift(line.new(time, n.ph, time, n.ph, xloc=xloc.bar_time, style=htf_style, width=htf_width, color=col))
            hl.lo_line.unshift(line.new(time, n.pl, time, n.pl, xloc=xloc.bar_time, style=htf_style, width=htf_width, color=col))
            hl.hi_label.unshift(label.new(time, n.ph, "P" + tf + "H", xloc=xloc.bar_time, style=label.style_label_left, color=transparent, textcolor=txt_color, size=lbl_size))
            hl.lo_label.unshift(label.new(time, n.pl, "P" + tf + "L", xloc=xloc.bar_time, style=label.style_label_left, color=transparent, textcolor=txt_color, size=lbl_size))
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
        dwm_sep("D", ds, d_sep_line, d_color)
        dwm_sep("W", ws, w_sep_line, w_color)
        dwm_sep("M", ms, m_sep_line, m_color)

        dwm_open("D", show_d_open, d_line, d_label, d_info, d_color)
        dwm_open("W", show_w_open, w_line, w_label, w_info, w_color)
        dwm_open("M", show_m_open, m_line, m_label, m_info, m_color)

        dwm_hl_func("D", dhl, d_hl, d_info, d_color)
        dwm_hl_func("W", whl, w_hl, w_info, w_color)
        dwm_hl_func("M", mhl, m_hl, m_info, m_color)

method vline(ts_helper this) =>
    bool t = not na(time("", this.session, gmt_tz))
    bool t_prev = not na(time("", this.session, gmt_tz, bars_back=1))
    array<line> arr = this.lines
    color col = this.c
    if t and not t_prev
        arr.unshift(line.new(bar_index, high * 1.0001, bar_index, low, style=vl_style, width=vl_width, extend=extend.both, color=col))
    if not v_unlimited
        if arr.size() > max_days
            arr.pop().delete()

vlines() =>
    if tf_limit_is_equal_or_more_chart_tf
        for [_, value] in ts_data
            vline(value)

method hz_line(lines_helper this) =>
    bool t = not na(time("", this.h, gmt_tz))
    bool t_prev = not na(time("", this.h, gmt_tz, bars_back=1))
    hz hzObj = this._hz
    string txt = this.h_text
    color col = this.h_color

    if t and not t_prev
        hzObj.LN.unshift(line.new(bar_index, open, bar_index, open, style=hz_style, width=hz_width, color=col))
        hzObj.LB.unshift(label.new(bar_index, open, txt, style=label.style_label_left, color=transparent, textcolor=txt_color, size=lbl_size))
        array.unshift(hzObj.CO, false)
        if not open_unlimited and hzObj.LN.size() > max_days
            hzObj.LN.pop().delete()
            hzObj.LB.pop().delete()
            hzObj.CO.pop()
    if not t and hzObj.CO.size() > 0
        if not hzObj.CO.get(0)
            hzObj.LN.get(0).set_x2(bar_index)
            hzObj.LB.get(0).set_x(bar_index)
            if (use_cutoff ? t_co : false)
                hzObj.CO.set(0, true)

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
    pos = str.pos(S, " ")
    pre = not na(pos) ? str.substring(S, 0, pos) : S
    L.set_text(str.format("{0} ({1})", str.trim(pre), P))

adjust_in_kz(kz kzObj, bool t) =>
    if t and kzObj._box.size() > 0
        kzBox0 = kzObj._box.get(0)
        kzBox0.set_right(time)
        newTop = math.max(kzBox0.get_top(), high)
        kzBox0.set_top(newTop)
        newBottom = math.min(kzBox0.get_bottom(), low)
        kzBox0.set_bottom(newBottom)

        kzObj._range_current := newTop - newBottom

        if show_pivots and kzObj._hi_line.size() > 0
            kzHiLine0 = kzObj._hi_line.get(0)
            kzHiLine0.set_x2(time)
            if high > kzHiLine0.get_y1()
                kzHiLine0.set_xy1(time, high)
                kzHiLine0.set_xy2(time, high)

            kzLoLine0 = kzObj._lo_line.get(0)
            kzLoLine0.set_x2(time)
            if low < kzLoLine0.get_y1()
                kzLoLine0.set_xy1(time, low)
                kzLoLine0.set_xy2(time, low)

            if show_midpoints and kzObj._md_line.size() > 0
                kzMidLine0 = kzObj._md_line.get(0)
                kzMidLine0.set_x2(time)
                kzMidLine0.set_xy1(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))
                kzMidLine0.set_xy2(time, math.avg(kzHiLine0.get_y2(), kzLoLine0.get_y2()))

        if show_labels and kzObj._hi_label.size() > 0
            if label_right
                kzObj._hi_label.get(0).set_x(time)
                kzObj._lo_label.get(0).set_x(time)
            if high > kzObj._hi_label.get(0).get_y()
                kzObj._hi_label.get(0).set_xy(time, high)
                if label_price
                    update_price_string(kzObj._hi_label.get(0), high)
            if low < kzObj._lo_label.get(0).get_y()
                kzObj._lo_label.get(0).set_xy(time, low)
                if label_price
                    update_price_string(kzObj._lo_label.get(0), low)

adjust_out_kz(kz kzObj, bool t, bool t_prev) =>
    boxCount = kzObj._box.size()
    if not t and boxCount > 0
        if t_prev
            array.unshift(kzObj._range_store, kzObj._range_current)
            if kzObj._range_store.size() > range_avg
                kzObj._range_store.pop()

    if show_pivots and boxCount > 0
        for i = 0 to boxCount - 1 by 1
            if not ext_current or i == 0
                kzHiValid = kzObj._hi_valid.get(i)
                if ext_past or kzHiValid
                    kzObj._hi_line.get(i).set_x2(time)
                    if show_labels and label_right
                        kzObj._hi_label.get(i).set_x(time)
                if kzHiValid and high > kzObj._hi_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert("Broke " + kzObj._title + " High", alert.freq_once_per_bar)
                    kzObj._hi_valid.set(i, false)
                    if show_labels and label_right
                        kzObj._hi_label.get(i).set_style(label.style_label_down)
                else if use_cutoff ? t_co : false
                    kzObj._hi_valid.set(i, false)

                kzLoValid = kzObj._lo_valid.get(i)
                if ext_past or kzLoValid
                    kzObj._lo_line.get(i).set_x2(time)
                    if show_labels and label_right
                        kzObj._lo_label.get(i).set_x(time)
                if kzLoValid and low < kzObj._lo_line.get(i).get_y1()
                    if use_alerts and i == 0
                        alert("Broke " + kzObj._title + " Low", alert.freq_once_per_bar)
                    kzObj._lo_valid.set(i, false)
                    if show_labels and label_right
                        kzObj._lo_label.get(i).set_style(label.style_label_up)
                else if use_cutoff ? t_co : false
                    kzObj._lo_valid.set(i, false)

                if show_midpoints and not t and kzObj._md_line.size() > i
                    if stop_midpoints ? kzObj._md_valid.get(i) : true
                        kzObj._md_line.get(i).set_x2(time)
                        if kzObj._md_valid.get(i) and low <= kzObj._md_line.get(i).get_y1() and high >= kzObj._md_line.get(i).get_y1()
                            kzObj._md_valid.set(i, false)
            else
                break

method manage_kz(kz_helper this) =>
    kz kzObj = this._kz
    c = this.c
    string box_txt = this.box_txt
    string hi_txt = this.hi_txt
    string lo_txt = this.lo_txt

    if tf_limit_is_equal_or_more_chart_tf
        t = not na(time("", this.session, gmt_tz))
        t_prev = not na(time("", this.session, gmt_tz, bars_back=1))
        if t and not t_prev
            _c = get_box_color(c)
            _t = get_text_color(c)
            kzObj._box.unshift(box.new(time, high, time, low, xloc=xloc.bar_time, border_color=show_kz ? _c : na, bgcolor=show_kz ? _c : na, text=show_kz and show_kz_text ? box_txt : na, text_color=_t))

            if show_pivots
                kzObj._hi_line.unshift(line.new(time, high, time, high, xloc=xloc.bar_time, style=kzp_style, color=c, width=kzp_width))
                kzObj._lo_line.unshift(line.new(time, low, time, low, xloc=xloc.bar_time, style=kzp_style, color=c, width=kzp_width))
                if show_midpoints
                    kzObj._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc=xloc.bar_time, style=kzm_style, color=c, width=kzm_width))
                    array.unshift(kzObj._md_valid, true)

                array.unshift(kzObj._hi_valid, true)
                array.unshift(kzObj._lo_valid, true)

                if show_labels
                    _hi_txt = label_price ? str.format("{0} ({1})", hi_txt, high) : hi_txt
                    _lo_txt = label_price ? str.format("{0} ({1})", lo_txt, low) : lo_txt
                    if label_right
                        kzObj._hi_label.unshift(label.new(time, high, _hi_txt, xloc=xloc.bar_time, color=transparent, textcolor=txt_color, style=label.style_label_left, size=lbl_size))
                        kzObj._lo_label.unshift(label.new(time, low, _lo_txt, xloc=xloc.bar_time, color=transparent, textcolor=txt_color, style=label.style_label_left, size=lbl_size))
                    else
                        kzObj._hi_label.unshift(label.new(time, high, _hi_txt, xloc=xloc.bar_time, color=transparent, textcolor=txt_color, style=label.style_label_down, size=lbl_size))
                        kzObj._lo_label.unshift(label.new(time, low, _lo_txt, xloc=xloc.bar_time, color=transparent, textcolor=txt_color, style=label.style_label_up, size=lbl_size))

            del_kz(kzObj)
        adjust_in_kz(kzObj, t)
        adjust_out_kz(kzObj, t, t_prev)

// ============================================================================
// CISD TYPES / LOGIC
// ============================================================================
type MarketStructure
    float topPrice
    float bottomPrice
    bool isBullish

type cisd
    line level
    label txt
    bool completed

cisdLineStyle = cisdStyleOption == "Dotted (┈)" ? line.style_dotted : cisdStyleOption == "Dashed (╌)" ? line.style_dashed : line.style_solid

var MarketStructure currentStructure = MarketStructure.new(0.0, 0.0, false)
var cisdLevelsBu = array.new<cisd>()
var cisdLevelsBe = array.new<cisd>()

var bool isBullishPullback = false
var bool isBearishPullback = false

var float potentialTopPrice = na
var float potentialBottomPrice = na

var int bullishBreakIndex = na
var int bearishBreakIndex = na

var bool currentState = false

bearishPullbackDetected = close[1] > open[1]
bullishPullbackDetected = close[1] < open[1]

if bearishPullbackDetected and not isBearishPullback
    isBearishPullback := true
    potentialTopPrice := open[1]
    bullishBreakIndex := bar_index[1]

if bullishPullbackDetected and not isBullishPullback
    isBullishPullback := true
    potentialBottomPrice := open[1]
    bearishBreakIndex := bar_index[1]

if isBullishPullback
    if open < potentialBottomPrice
        potentialBottomPrice := open
        bearishBreakIndex := bar_index
    if (close < open) and (open > potentialBottomPrice)
        potentialBottomPrice := open
        bearishBreakIndex := bar_index

if isBearishPullback
    if open > potentialTopPrice
        potentialTopPrice := open
        bullishBreakIndex := bar_index
    if (close > open) and (open < potentialTopPrice)
        potentialTopPrice := open
        bullishBreakIndex := bar_index

if low < currentStructure.bottomPrice
    currentStructure.bottomPrice := low
    currentStructure.isBullish := false

    if isBearishPullback and not na(bullishBreakIndex) and (bar_index - bullishBreakIndex != 0)
        idx = math.min(bar_index - bullishBreakIndex + 1, bar_index)
        currentStructure.topPrice := math.max(high[idx], high[math.max(idx - 1, 0)])
        isBearishPullback := false

        bearishLine = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color=bullishBreakColor, width=cisdLineWidth, style=cisdLineStyle)
        bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, bullStr, color=color.new(color.white, 100), textcolor=bullishBreakColor, style=label.style_label_left, text_font_family=font.family_default, size=size.small, text_formatting=text.format_italic)

        b = cisd.new(bearishLine, bearishLabel, false)
        array.push(cisdLevelsBe, b)

    else if close[1] > open[1] and close < open and not na(bullishBreakIndex)
        currentStructure.topPrice := high[1]
        isBearishPullback := false

        bearishLine = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color=bullishBreakColor, width=cisdLineWidth, style=cisdLineStyle)
        bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, bullStr, color=color.new(color.white, 100), textcolor=bullishBreakColor, style=label.style_label_left, text_font_family=font.family_default, size=size.small, text_formatting=text.format_italic)

        b = cisd.new(bearishLine, bearishLabel, false)
        array.push(cisdLevelsBe, b)

if high > currentStructure.topPrice
    currentStructure.isBullish := true
    currentStructure.topPrice := high

    if isBullishPullback and not na(bearishBreakIndex) and (bar_index - bearishBreakIndex != 0)
        idx = math.min(bar_index - bearishBreakIndex + 1, bar_index)
        currentStructure.bottomPrice := math.min(low[idx], low[math.max(idx - 1, 0)])
        isBullishPullback := false

        bullishLine = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color=bearishBreakColor, width=cisdLineWidth, style=cisdLineStyle)
        bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, bearStr, color=color.new(color.white, 100), textcolor=bearishBreakColor, style=label.style_label_left, text_font_family=font.family_default, size=size.small, text_formatting=text.format_italic)

        bu = cisd.new(bullishLine, bullishLabel, false)
        array.push(cisdLevelsBu, bu)

    else if close[1] < open[1] and close > open and not na(bearishBreakIndex)
        currentStructure.bottomPrice := low[1]
        isBullishPullback := false

        bullishLine = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color=bearishBreakColor, width=cisdLineWidth, style=cisdLineStyle)
        bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, bearStr, color=color.new(color.white, 100), textcolor=bearishBreakColor, style=label.style_label_left, text_font_family=font.family_default, size=size.small, text_formatting=text.format_italic)

        bu = cisd.new(bullishLine, bullishLabel, false)
        array.push(cisdLevelsBu, bu)

if array.size(cisdLevelsBu) > 1 and not keepLevels
    oldBu = array.shift(cisdLevelsBu)
    line.delete(oldBu.level)
    label.delete(oldBu.txt)

if array.size(cisdLevelsBe) > 1 and not keepLevels
    oldBe = array.shift(cisdLevelsBe)
    line.delete(oldBe.level)
    label.delete(oldBe.txt)

if array.size(cisdLevelsBu) >= 1
    latestBu = array.get(cisdLevelsBu, 0)
    if not (close < line.get_y2(latestBu.level)) and not latestBu.completed
        line.set_x2(latestBu.level, bar_index + lookAheadBars)
        label.set_x(latestBu.txt, bar_index + lookAheadBars)

    if close < line.get_y2(latestBu.level) and not latestBu.completed
        latestBu.completed := true
        currentState := false
        if bearishAlerts
            alert("Bearish CISD Formed", alert.freq_once_per_bar_close)

if array.size(cisdLevelsBe) >= 1
    latestBe = array.get(cisdLevelsBe, 0)
    if not (close > line.get_y2(latestBe.level)) and not latestBe.completed
        line.set_x2(latestBe.level, bar_index + lookAheadBars)
        label.set_x(latestBe.txt, bar_index + lookAheadBars)

    if close > line.get_y2(latestBe.level) and not latestBe.completed
        latestBe.completed := true
        currentState := true
        if bullishAlerts
            alert("Bullish CISD Formed", alert.freq_once_per_bar_close)

bullishCisdTriggered = array.size(cisdLevelsBe) >= 1 ? (close > line.get_y2(array.get(cisdLevelsBe, 0).level) and not array.get(cisdLevelsBe, 0).completed) : false
bearishCisdTriggered = array.size(cisdLevelsBu) >= 1 ? (close < line.get_y2(array.get(cisdLevelsBu, 0).level) and not array.get(cisdLevelsBu, 0).completed) : false

alertcondition(bullishCisdTriggered and bullishAlerts, title="Bullish CISD", message="Bullish CISD Formed")
alertcondition(bearishCisdTriggered and bearishAlerts, title="Bearish CISD", message="Bearish CISD Formed")

// ============================================================================
// RUN KILLZONES
// ============================================================================
for [_, value] in _kz
    manage_kz(value)

dwm()
vlines()
hz_lines()

new_dow_time = dow_xloc == "Midday" ? time - timeframe.in_seconds("D") / 2 * 1000 : time
new_day = dayofweek(new_dow_time, gmt_tz) != dayofweek(new_dow_time, gmt_tz)[1]

var dow_top = dow_yloc == "Top"

var saturday = "SATURDAY"
var sunday = "SUNDAY"
var monday = "MONDAY"
var tuesday = "TUESDAY"
var wednesday = "WEDNESDAY"
var thursday = "THURSDAY"
var friday = "FRIDAY"

plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 1 and new_day and not dow_hide_wknd, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=sunday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 2 and new_day, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=monday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 3 and new_day, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=tuesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 4 and new_day, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=wednesday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 5 and new_day, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=thursday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 6 and new_day, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=friday)
plotchar(dow_labels and timeframe.isintraday and dayofweek(new_dow_time, gmt_tz) == 7 and new_day and not dow_hide_wknd, location=dow_top ? location.top : location.bottom, char="", textcolor=txt_color, text=saturday)

get_min_days_stored() =>
    store = array.new_int()
    for [_, value] in _kz
        int tmpStoreSize = value._kz._range_store.size()
        if tmpStoreSize > 0
            store.push(tmpStoreSize)
    array.size(store) > 0 ? store.min() : 0

method set_table(table tbl, kz kzObj, int row, string txt, bool t, color col) =>
    table.cell(tbl, 0, row, txt, text_size=range_size, bgcolor=get_box_color(col), text_color=txt_color)
    table.cell(tbl, 1, row, str.tostring(kzObj._range_current), text_size=range_size, bgcolor=t ? get_box_color(col) : na, text_color=txt_color)
    if show_range_avg
        table.cell(tbl, 2, row, str.tostring(kzObj._range_store.avg()), text_size=range_size, text_color=txt_color)

if show_range and barstate.islast
    var tbl = table.new(range_pos, 10, 10, chart.bg_color, chart.fg_color, 2, chart.fg_color, 1)
    table.cell(tbl, 0, 0, "Killzone", text_size=range_size, text_color=txt_color)
    table.cell(tbl, 1, 0, "Range", text_size=range_size, text_color=txt_color)
    if show_range_avg
        table.cell(tbl, 2, 0, "Avg (" + str.tostring(get_min_days_stored()) + ")", text_size=range_size, text_color=txt_color)

    for [index, value] in _kz
        set_table(tbl, value._kz, index + 1, value.box_txt, not na(time("", value.session, gmt_tz)), value.c)

// ============================================================================
// CISD TABLE
// ============================================================================
if showCisdTable and barstate.islast
    var cisdTbl = table.new(get_cisd_table_pos(cisdTablePosition), 2, 3, bgcolor=chart.bg_color, border_color=chart.fg_color, frame_color=chart.fg_color, frame_width=1, border_width=1)
    table.cell(cisdTbl, 0, 0, syminfo.ticker + ", " + timeframe.period, text_size=size.tiny, text_color=chart.fg_color, text_font_family=font.family_monospace)
    table.cell(cisdTbl, 0, 1, "Current State", text_color=chart.bg_color, text_size=size.small, text_font_family=font.family_monospace, text_formatting=text.format_bold, bgcolor=chart.fg_color)
    table.cell(cisdTbl, 1, 1, currentState ? "Bullish" : "Bearish", text_color=chart.fg_color, text_size=size.small, text_font_family=font.family_monospace, text_formatting=text.format_bold)
````

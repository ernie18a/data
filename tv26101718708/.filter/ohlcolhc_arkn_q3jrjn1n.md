# OHLC-OLHC [ARKN] 

- url: https://www.tradingview.com/script/q3JrJN1N-OHLC-OLHC-ARKN/
- type: indicator
- pine_id: PUB;8ddc5231620548c69be23cb93fd92e46
- version: 1.0

## Description

ARKN combines three time-based analysis tools into a single overlay so that session context, higher-timeframe structure, and cross-asset divergence can be read together on one chart, without stacking three separate indicators.

[b]What it does[/b]
[i]Killzones[/i] — Draws up to four configurable session boxes (defaults: Asia, London, NY AM, NY PM) with optional session high/low pivot lines, midpoints, day-of-week labels, opening-price lines, and an "opening candle" marker. Pivots can extend until mitigated or past mitigation, with optional alerts when a session high or low is broken.
[i]HTF Candles[/i] — Renders up to four higher-timeframe candle sets to the right of the live price, each with its own timeframe and display count. Optional Fair Value Gap and Volume Imbalance boxes, a remaining-time countdown, and interval labels are drawn directly on the projected candles.
[i]Sequential SMT (SSMT)[/i] — Detects SMT-style divergence between correlated instruments across nested cycles (Micro, 90-minute, Daily, Weekly, Monthly). Triads can be set automatically for common groups (metals, indices, FX, crypto, futures) or defined manually, with an inverse option for negatively-correlated pairs. Both standard (wick-based) and hidden (body/close-based) divergences are supported.

[b]Why these three together[/b]
The three modules answer three sequential questions a session-based trader asks in order: when (Killzones frame the active session), what structure (HTF Candles show the higher-timeframe bias forming in real time), and confirmation (SSMT flags when a correlated instrument fails to confirm the move). Combining them removes the need to switch layouts or sync timeframes manually, since all three share the same timezone and session logic.

[b]How to use[/b]
Set your timezone under Settings; all sessions and cycles reference it.
Each module has a master ON/OFF toggle at the top of its settings group.
For SSMT, either leave Triad Selection on Auto (it picks correlated assets for the current symbol) or set Manual to define your own triad. Lower timeframes show Micro/90m cycles; higher timeframes show Daily/Weekly/Monthly.
HTF Candle timeframes must be higher than the chart timeframe to display.

[b]Settings overview[/b]
Global: drawing limit, timeframe limit, timezone, label size, text color, cutoff time. Per module: session times and colors (Killzones), timeframe and candle count (HTF Candles), cycle visibility, line styles, and correlation triads (SSMT).

Note on originality
This script combines well-established, publicly-discussed ICT community concepts — session Killzones, projected higher-timeframe candles, and SMT/Sequential SMT divergence. These concepts are not original to this script; the contribution here is integrating all three into one configurable overlay with shared session and timezone handling. The script is published open-source so the implementation can be reviewed and reused.

## Source Code

````pine
//@version=6
indicator("OHLC-OLHC [ARKN] ", "[ARKN] OHLC-OLHC", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500) 



// --- KILLZONE ON/OFF FEATURE ---
showKillzone = input.bool(true, "Killzone (ON/OFF)", group="Killzone Settings")

// --- HTF CANDLE ON/OFF FEATURE ---
showHTFCandle = input.bool(true, " HTF Candle (ON/OFF)", group="HTF Candle Settings")

// --- SSMT ON/OFF FEATURE ---
showSSMT = input.bool(true, "SSMT (ON/OFF)", group="SSMT Settings")

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
lbl_size            = get_size(input.string('Small', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS))
txt_color           = input.color(color.rgb(54,58,69), "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS)
use_cutoff          = input.bool(true, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS)
cutoff              = input.session("1700-1701", "", inline = "CO", group = g_SETTINGS)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzones"
show_kz             = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ)

use_asia            = input.bool(true, "", inline = "ASIA", group = g_KZ)
as_txt              = input.string("Asia", "", inline = "ASIA", group = g_KZ)
asia                = input.session("2000-0001", "", inline = "ASIA", group = g_KZ)
as_color            = input.color(color.rgb(39,37,37), "", inline = "ASIA", group = g_KZ)

use_london          = input.bool(true, "", inline = "LONDON", group = g_KZ)
lo_txt              = input.string("London", "", inline = "LONDON", group = g_KZ)
london              = input.session("0200-0501", "", inline = "LONDON", group = g_KZ)
lo_color            = input.color(color.rgb(41,98,255), "", inline = "LONDON", group = g_KZ)

use_nyam            = input.bool(true, "", inline = "NYAM", group = g_KZ)
na_txt              = input.string("NY AM", "", inline = "NYAM", group = g_KZ)
nyam                = input.session("0700-1001", "", inline = "NYAM", group = g_KZ)
na_color            = input.color(color.rgb(39,37,37), "", inline = "NYAM", group = g_KZ)

use_nypm            = input.bool(true, "", inline = "NYPM", group = g_KZ)
np_txt              = input.string("NY PM", "", inline = "NYPM", group = g_KZ)
nypm                = input.session("1300-1601", "", inline = "NYPM", group = g_KZ)
np_color            = input.color(color.rgb(41,98,255), "", inline = "NYPM", group = g_KZ)

box_transparency    = input.int(94, "Box Transparency", 0, 100, group = g_KZ)


var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS)
show_pivot_lines    = input.bool(true, "Show Pivot Lines", inline = "PV", group = g_LABELS, tooltip="Show pivot lines (turn off for labels only)")
use_alerts          = input.bool(false, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS)
show_labels         = input.bool(true, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group = g_LABELS)
label_right         = input.bool(false, "Right Side", inline = "LB", group = g_LABELS)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS)
ext_which           = input.string("Most Recent", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS)

// All killzone labels set to bullet "•"
ash_str             = input.string("•", "Killzone 1 Labels", inline = "L_AS", group = g_LABELS)
asl_str             = input.string("•", "", inline = "L_AS", group = g_LABELS)
loh_str             = input.string("•", "Killzone 2 Labels", inline = "L_LO", group = g_LABELS)
lol_str             = input.string("•", "", inline = "L_LO", group = g_LABELS)
nah_str             = input.string("•", "Killzone 3 Labels", inline = "L_NA", group = g_LABELS)
nal_str             = input.string("•", "", inline = "L_NA", group = g_LABELS)
nph_str             = input.string("•", "Killzone 4 Labels", inline = "L_NP", group = g_LABELS)
npl_str             = input.string("•", "", inline = "L_NP", group = g_LABELS)

// Pivot style Dotted
kzp_style           = get_line_type(input.string(defval = 'Dotted', title = "Pivot Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS))
kzp_width           = input.int(1, "", inline = "KZP", group = g_LABELS)
kzm_style           = get_line_type(input.string(defval = 'Dotted', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS)


// --- Day of Week Labels ---
dow_labels          = input.bool(true, "Day of Week Labels", inline = "DOW", group = "Day of Week")
dow_yloc            = input.string('Bottom', "", options = ['Top', 'Bottom'], inline = "DOW", group = "Day of Week")
dow_xloc            = input.string('Midnight', "", options = ['Midnight', 'Midday'], inline = "DOW", group = "Day of Week")
dow_hide_wknd       = input.bool(true, "Hide Weekend Labels", group = "Day of Week")


var g_OPEN          = "Opening Prices"
open_unlimited      = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPEN)
open_label_offset   = input.int(1, "Label Offset (candles)", minval=0, maxval=50, tooltip="Distance of the label to the right from the first candle", group=g_OPEN)

// All Opening Prices set to default false and session 00:00
use_h1              = input.bool(false, "", inline = "H1", group = g_OPEN)
h1_text             = input.string("00.00", "", inline = "H1", group = g_OPEN)
h1                  = input.session("0000-0001", "", inline = "H1", group = g_OPEN)
h1_color            = input.color(color.rgb(39,37,37), "", inline = "H1", group = g_OPEN)

use_h2              = input.bool(false, "", inline = "H2", group = g_OPEN)
h2_text             = input.string("00.00", "", inline = "H2", group = g_OPEN)
h2                  = input.session("0000-0001", "", inline = "H2", group = g_OPEN)
h2_color            = input.color(color.rgb(120,123,134), "", inline = "H2", group = g_OPEN)

use_h3              = input.bool(false, "", inline = "H3", group = g_OPEN)
h3_text             = input.string("00.00", "", inline = "H3", group = g_OPEN)
h3                  = input.session("0000-0001", "", inline = "H3", group = g_OPEN)
h3_color            = input.color(color.rgb(120,123,134), "", inline = "H3", group = g_OPEN)

use_h4              = input.bool(false, "", inline = "H4", group = g_OPEN)
h4_text             = input.string("00.00", "", inline = "H4", group = g_OPEN)
h4                  = input.session("0000-0001", "", inline = "H4", group = g_OPEN)
h4_color            = input.color(color.rgb(120,123,134), "", inline = "H4", group = g_OPEN)

use_h5              = input.bool(false, "", inline = "H5", group = g_OPEN)
h5_text             = input.string("00.00", "", inline = "H5", group = g_OPEN)
h5                  = input.session("0000-0001", "", inline = "H5", group = g_OPEN)
h5_color            = input.color(color.rgb(120,123,134), "", inline = "H5", group = g_OPEN)

use_h6              = input.bool(false, "", inline = "H6", group = g_OPEN)
h6_text             = input.string("00.00", "", inline = "H6", group = g_OPEN)
h6                  = input.session("0000-0001", "", inline = "H6", group = g_OPEN)
h6_color            = input.color(color.rgb(120,123,134), "", inline = "H6", group = g_OPEN)

use_h7              = input.bool(false, "", inline = "H7", group = g_OPEN)
h7_text             = input.string("00.00", "", inline = "H7", group = g_OPEN)
h7                  = input.session("0000-0001", "", inline = "H7", group = g_OPEN)
h7_color            = input.color(color.rgb(120,123,134), "", inline = "H7", group = g_OPEN)


// ==================== OPENING CANDLE GROUP ====================
var g_OPENING_CANDLE  = "Opening Candle"
oc_unlimited      = input.bool(false, "Unlimited", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPENING_CANDLE)
oc_label_offset   = input.int(2, "Label Offset (candles)", minval=0, maxval=50, tooltip="Distance of the label to the right from the first candle", group=g_OPENING_CANDLE)

use_oc1           = input.bool(true, "", inline = "OC1", group = g_OPENING_CANDLE)
oc1_text          = input.string("Open", "", inline = "OC1", group = g_OPENING_CANDLE)
oc1_session       = input.session("1700-1701", "", inline = "OC1", group = g_OPENING_CANDLE)
oc1_color         = input.color(color.rgb(39,37,37), "", inline = "OC1", group = g_OPENING_CANDLE)

use_oc2           = input.bool(false, "", inline = "OC2", group = g_OPENING_CANDLE)
oc2_text          = input.string("21.00", "", inline = "OC2", group = g_OPENING_CANDLE)
oc2_session       = input.session("2100-2101", "", inline = "OC2", group = g_OPENING_CANDLE)
oc2_color         = input.color(color.rgb(91,156,246), "", inline = "OC2", group = g_OPENING_CANDLE)

use_oc3           = input.bool(false, "", inline = "OC3", group = g_OPENING_CANDLE)
oc3_text          = input.string("01.00", "", inline = "OC3", group = g_OPENING_CANDLE)
oc3_session       = input.session("0100-0101", "", inline = "OC3", group = g_OPENING_CANDLE)
oc3_color         = input.color(color.rgb(91,156,246), "", inline = "OC3", group = g_OPENING_CANDLE)

use_oc4           = input.bool(false, "", inline = "OC4", group = g_OPENING_CANDLE)
oc4_text          = input.string("05.00", "", inline = "OC4", group = g_OPENING_CANDLE)
oc4_session       = input.session("0500-0501", "", inline = "OC4", group = g_OPENING_CANDLE)
oc4_color         = input.color(color.rgb(91,156,246), "", inline = "OC4", group = g_OPENING_CANDLE)

use_oc5           = input.bool(false, "", inline = "OC5", group = g_OPENING_CANDLE)
oc5_text          = input.string("09.00", "", inline = "OC5", group = g_OPENING_CANDLE)
oc5_session       = input.session("0900-0901", "", inline = "OC5", group = g_OPENING_CANDLE)
oc5_color         = input.color(color.rgb(91,156,246), "", inline = "OC5", group = g_OPENING_CANDLE)

use_oc6           = input.bool(false, "", inline = "OC6", group = g_OPENING_CANDLE)
oc6_text          = input.string("13.00", "", inline = "OC6", group = g_OPENING_CANDLE)
oc6_session       = input.session("1300-1301", "", inline = "OC6", group = g_OPENING_CANDLE)
oc6_color         = input.color(color.rgb(91,156,246), "", inline = "OC6", group = g_OPENING_CANDLE)

use_oc7           = input.bool(false, "", inline = "OC7", group = g_OPENING_CANDLE)
oc7_text          = input.string("", "", inline = "OC7", group = g_OPENING_CANDLE)
oc7_session       = input.session("1330-1331", "", inline = "OC7", group = g_OPENING_CANDLE)
oc7_color         = input.color(color.rgb(91,156,246), "", inline = "OC7", group = g_OPENING_CANDLE)

// ==================== END OPENING CANDLE ====================

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

type hz
    array<line> LN
    array<label> LB
    array<bool> CO


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
    // ===== ADDED FOR OPENING CANDLE =====
    if use_oc1
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc1_session, oc1_text, oc1_color))
    if use_oc2
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc2_session, oc2_text, oc2_color))
    if use_oc3
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc3_session, oc3_text, oc3_color))
    if use_oc4
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc4_session, oc4_text, oc4_color))
    if use_oc5
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc5_session, oc5_text, oc5_color))
    if use_oc6
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc6_session, oc6_text, oc6_color))
    if use_oc7
        res.push(lines_helper.new(hz.new(array.new_line(), array.new_label(), array.new_bool()), oc7_session, oc7_text, oc7_color))
    // ===== END OF ADDITION =====
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
             kz.new(as_txt, 
                    array.new_box(), 
                    array.new_line(), array.new_line(), array.new_line(), 
                    array.new_label(), array.new_label(), 
                    array.new_bool(), array.new_bool(), array.new_bool()),
             asia, as_color, as_txt, ash_str, asl_str
         ))
    if use_london
        res.push(kz_helper.new(
             kz.new(lo_txt, 
                    array.new_box(), 
                    array.new_line(), array.new_line(), array.new_line(), 
                    array.new_label(), array.new_label(), 
                    array.new_bool(), array.new_bool(), array.new_bool()),
             london, lo_color, lo_txt, loh_str, lol_str
         ))
    if use_nyam
        res.push(kz_helper.new(
             kz.new(na_txt, 
                    array.new_box(), 
                    array.new_line(), array.new_line(), array.new_line(), 
                    array.new_label(), array.new_label(), 
                    array.new_bool(), array.new_bool(), array.new_bool()),
             nyam, na_color, na_txt, nah_str, nal_str
         ))
    if use_nypm
        res.push(kz_helper.new(
             kz.new(np_txt, 
                    array.new_box(), 
                    array.new_line(), array.new_line(), array.new_line(), 
                    array.new_label(), array.new_label(), 
                    array.new_bool(), array.new_bool(), array.new_bool()),
             nypm, np_color, np_txt, nph_str, npl_str
         ))
    res

var array<kz_helper> _kz = initKZ()

t_co = not na(time("", cutoff, gmt_tz))

var transparent = #ffffff00
var ext_current = ext_which == 'Most Recent'
var ext_past = ext_pivots == 'Past Mitigation'

// ---------------------------------------- Variables & Constants --------------------------------------------------


// ---------------------------------------- Functions --------------------------------------------------
get_box_color(color c) =>
    color.new(c, box_transparency)

// ---------------------------------------- Functions --------------------------------------------------


// ---------------------------------------- Core Logic --------------------------------------------------

// ========== FIXED HZ LINE FUNCTION (LINE STAYS ON CANDLE, LABEL AT OFFSET) ==========
method hz_line(lines_helper this) =>
    bool t = not na(time("", this.h, gmt_tz))
    bool t_prev = not na(time("", this.h, gmt_tz, bars_back = 1))
    hz hz = this._hz
    string txt = this.h_text
    color col = this.h_color
    
    // Variables for style, width, and offset - now constants
    string line_style = line.style_solid
    int line_width = 1
    bool unlimited = false
    int label_offset = 0
    
    // Check whether this comes from the Opening Price group (h1-h7) or the Opening Candle group (oc1-oc7)
    if this.h == h1 or this.h == h2 or this.h == h3 or this.h == h4 or this.h == h5 or this.h == h6 or this.h == h7
        line_style := line.style_dotted   // for Opening Price
        line_width := 1
        unlimited := open_unlimited
        label_offset := open_label_offset
    else if this.h == oc1_session or this.h == oc2_session or this.h == oc3_session or this.h == oc4_session or this.h == oc5_session or this.h == oc6_session or this.h == oc7_session
        line_style := line.style_solid   // for Opening Candle
        line_width := 1
        unlimited := oc_unlimited
        label_offset := oc_label_offset

    if t and not t_prev
        // LINE: stays at bar_index (candle position)
        hz.LN.unshift(line.new(bar_index, open, bar_index, open, style = line_style, width = line_width, color = col))
        // LABEL: shifted to the right by label_offset
        hz.LB.unshift(label.new(bar_index + label_offset, open, txt, style = label.style_label_left, color = transparent, textcolor = txt_color, size = lbl_size))
        array.unshift(hz.CO, false)
        if not unlimited and hz.LN.size() > max_days
            hz.LN.pop().delete()
            hz.LB.pop().delete()
            hz.CO.pop()
    if not t and hz.CO.size() > 0
        if not hz.CO.get(0)
            // Extend the line up to the latest bar_index
            hz.LN.get(0).set_x2(bar_index)
            // Label follows to the latest bar_index + offset
            hz.LB.get(0).set_x(bar_index + label_offset)
            if (use_cutoff ? t_co : false)
                hz.CO.set(0, true)


hz_lines() =>
    if tf_limit_is_equal_or_more_chart_tf and showKillzone
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


adjust_in_kz(kz kz, bool t) =>
    if t
        kzBox0 = kz._box.get(0)
        kzBox0.set_right(time)
        newTop = math.max(kzBox0.get_top(), high)
        kzBox0.set_top(newTop)
        newBottom = math.min(kzBox0.get_bottom(), low)
        kzBox0.set_bottom(newBottom)

        if show_pivots and kz._hi_line.size() > 0
            kzHiLine0 = kz._hi_line.get(0)
            kzLoLine0 = kz._lo_line.get(0)
            
            if show_pivot_lines
                kzHiLine0.set_x2(time)
                if high > kzHiLine0.get_y1()
                    kzHiLine0.set_xy1(time, high)
                    kzHiLine0.set_xy2(time, high)

                kzLoLine0.set_x2(time)
                if low < kzLoLine0.get_y1()
                    kzLoLine0.set_xy1(time, low)
                    kzLoLine0.set_xy2(time, low)
            else
                kzHiLine0.set_x2(time)
                kzLoLine0.set_x2(time)

            if show_midpoints and show_pivot_lines
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
            if low < kz._lo_label.get(0).get_y()
                kz._lo_label.get(0).set_xy(time, low)


adjust_out_kz(kz kz, bool t, bool t_prev) =>
    boxCount = kz._box.size()

    if show_pivots and boxCount > 0
        for i = 0 to boxCount - 1 by 1
            if not ext_current or i == 0
                kzHiValid = kz._hi_valid.get(i)
                if ext_past or kzHiValid
                    if show_pivot_lines
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
                    if show_pivot_lines
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

                if show_midpoints and not t and show_pivot_lines
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

    if tf_limit_is_equal_or_more_chart_tf and showKillzone
        t = not na(time("", this.session, gmt_tz))
        t_prev = not na(time("", this.session, gmt_tz, bars_back = 1))
        if t and not t_prev
            _c = get_box_color(c)
            kz._box.unshift(box.new(time, high, time, low, xloc = xloc.bar_time, border_color = show_kz ? _c : na, bgcolor = show_kz ? _c : na, text = na, text_color = na))

            if show_pivots
                if show_pivot_lines
                    kz._hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                    kz._lo_line.unshift(line.new(time, low, time, low, xloc = xloc.bar_time, style = kzp_style, color = c, width = kzp_width))
                else
                    kz._hi_line.unshift(line.new(time, high, time, high, xloc = xloc.bar_time, style = kzp_style, color = color.new(c, 100), width = kzp_width))
                    kz._lo_line.unshift(line.new(time, low, time, low, xloc = xloc.bar_time, style = kzp_style, color = color.new(c, 100), width = kzp_width))
                
                if show_midpoints
                    if show_pivot_lines
                        kz._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc = xloc.bar_time, style = kzm_style, color = c, width = kzm_width))
                    else
                        kz._md_line.unshift(line.new(time, math.avg(high, low), time, math.avg(high, low), xloc = xloc.bar_time, style = kzm_style, color = color.new(c, 100), width = kzm_width))
                    array.unshift(kz._md_valid, true)

                array.unshift(kz._hi_valid, true)
                array.unshift(kz._lo_valid, true)

                if show_labels
                    _hi_txt = hi_txt
                    _lo_txt = lo_txt
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

// ========== HTF CANDLE - NOW 4 ==========
var CandleSettings SettingsHTF1 = CandleSettings.new()
var CandleSettings SettingsHTF2 = CandleSettings.new()
var CandleSettings SettingsHTF3 = CandleSettings.new()
var CandleSettings SettingsHTF4 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)
var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()
var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()

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


//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

// HTF 1
htf1.settings.show              := input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('15', '', inline = 'htf1')
htf1.settings.htf := htf_1
htf1.settings.max_display       := input.int(10, '', inline = 'htf1')

// HTF 2
htf2.settings.show              := input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('60', '', inline = 'htf2')
htf2.settings.htf := htf_2
htf2.settings.max_display       := input.int(7, '', inline = 'htf2')

// HTF 3
htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('90', '', inline = 'htf3')
htf3.settings.htf := htf_3
htf3.settings.max_display       := input.int(7, '', inline = 'htf3')

// HTF 4
htf4.settings.show              := input.bool(true, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('240', '', inline = 'htf4')
htf4.settings.htf := htf_4
htf4.settings.max_display       := input.int(10, '', inline = 'htf4')

settings.max_sets               := input.int(1, 'Limit to next HTFs only', minval = 1, maxval = 4)
settings.use_custom_daily       := input.bool(false, 'Custom daily candle open     ', inline='customdaily')
settings.custom_daily           := input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily')
settings.bull_body              := input.color(color.white, 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.rgb(208,210,212), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.rgb(54,58,69), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.rgb(54,58,69), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.rgb(59,52,53), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.rgb(59,52,53), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(18, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(10, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.rgb(54,58,69), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')

settings.label_position         := input.string("Both", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Align", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.rgb(54,58,69), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.daily_name             := input.bool(true, 'Interval Value        ', group=group_label, inline = 'dow')
settings.dow_color              := input.color(color.rgb(54,58,69), '', group=group_label, inline = 'dow')
settings.dow_size               := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(color.rgb(120,123,134), 80), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(false, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 80), '', inline = 'vi', group = group_imbalance)


//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
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

            if settings.daily_name
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
    // UTC for Drawing (Crypto Standard)
    HTFBarTime = time(candleSet.settings.htf, 'UTC')
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if settings.use_custom_daily
        int _830 = 0
        if isNewHTFCandle
            // UTC
            _830 := timestamp("UTC", year(time), month(time), dayofmonth(time), 0, 0) + 30600000
        if candleSet.settings.htf == '1D'
            if settings.custom_daily == 'Midnight'
                // UTC
                isNewHTFCandle := dayofweek(time, 'UTC') != dayofweek(time - (time - time[1]), 'UTC')
            if settings.custom_daily == '8:30'    
                // UTC
                isNewHTFCandle := not na(time(timeframe.period, "0830-0831:123456", 'UTC')) and na(time(timeframe.period, "0830-0831:123456", 'UTC')[1])
            if settings.custom_daily == '9:30'    
                // UTC
                isNewHTFCandle := not na(time(timeframe.period, "0930-0931:123456", 'UTC')) and na(time(timeframe.period, "0930-0931:123456", 'UTC')[1])
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
                // New York Time for Labels
                helper.DayofWeek(dayofweek(time, "America/New_York"))
            str.tonumber(candleSet.settings.htf) < 60 =>
                // New York Time for Labels
                str.format_time(candle.o_time, 'm', 'America/New_York')
            str.tonumber(candleSet.settings.htf) >= 60 =>
                // New York Time for Labels
                str.format_time(candle.o_time, 'H', 'America/New_York')
            candleSet.settings.htf == '1M' =>
                // New York Time for Labels
                str.format_time(candle.o_time, 'M', 'America/New_York')
            =>
                ''
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

method Update(CandleSet candleSet, int offset) =>
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
    candleSet

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf) and showHTFCandle
    htf1.UpdateTime(offset)
    htf1.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last and showHTFCandle
    htf2.UpdateTime(offset)
    htf2.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf2.candles.size() * settings.width + (htf2.candles.size() > 0 ? (htf2.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last and showHTFCandle
    htf3.UpdateTime(offset)
    htf3.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last and showHTFCandle
    htf4.UpdateTime(offset)
    htf4.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset


// ==================== PART 2: SSMT ====================

// --- Triad Assets (required for correlation) ---
ssmt_tr1B = true
ssmt_st4 = "OANDA:XAUUSD"
ssmt_st5 = "OANDA:XAGUSD"
ssmt_st6 = "OANDA:XPTUSD"
ssmt_tr1C = true
ssmt_st7 = "BINANCE:BTCUSDT.P"
ssmt_st8 = "BINANCE:ETHUSDT.P"
ssmt_st9 = "BINANCE:XRPUSDT.P"
ssmt_tr1D = true
ssmt_st10 = "CME_MINI:MNQ1!"
ssmt_st11 = "CME_MINI:MES1!"
ssmt_st12 = "CBOT_MINI:MYM1!"
ssmt_tr1E = true
ssmt_st13 = "FOREXCOM:EURUSD"
ssmt_st14 = "FOREXCOM:GBPUSD"
ssmt_st15 = "TICKMILL:DXY"
ssmt_tr1F = true
ssmt_st16 = "CAPITALCOM:NAS100"
ssmt_st17 = "CAPITALCOM:US500"
ssmt_st18 = "CAPITALCOM:US30"
ssmt_tr1G = true
ssmt_st19 = "COMEX:GC1!"
ssmt_st20 = "COMEX:SI1!"
ssmt_st21 = "NYMEX:PL1!"

// Hidden pairs for auto mode
ssmt_s1 = "CAPITALCOM:US100"
ssmt_s2 = "CAPITALCOM:US500"
ssmt_s3 = "OANDA:XAUUSD"
ssmt_s4 = "OANDA:XAGUSD"
ssmt_s5 = "FOREXCOM:EURUSD"
ssmt_s6 = "FOREXCOM:GBPUSD"
ssmt_s7 = "BINANCE:BTCUSDT.P"
ssmt_s8 = "BINANCE:ETHUSDT.P"
ssmt_s9 = "CME_MINI:MNQ1!"
ssmt_s10 = "CME_MINI:MES1!"
ssmt_s11 = "COMEX:GC1!"
ssmt_s12 = "COMEX:SI1!"

// --- SSMT Input Groups ---
ssmt_g0      = "SSMT Visibility"
ssmt_g_sbar  = "SSMT Status Bar" // this group will be removed
ssmt_g6      = "SSMTs on chart"
ssmt_g11     = "Triad Correlation"

// --- Visibility Settings ---
ssmt_mdl1 = "Auto"
ssmt_mdl2 = "Custom"
ssmt_modeltype   = input.string(ssmt_mdl1, "Calculation Mode", options=[ssmt_mdl1, ssmt_mdl2], group=ssmt_g0, inline="v1")
ssmt_alerttype   = input.string("All", "Display Type", options=["All", "Normal", "Hidden"], group=ssmt_g0, inline="v2")
ssmt_lblfrmt     = input.string("Symbol Name", "Label Format", options=["Symbol Name"], group=ssmt_g0, inline="v3")
ssmt_i_font      = input.string("tiny", "Text Size", options=["tiny", "small", "normal", "large", "huge"], group=ssmt_g0, inline="font")
ssmt_target_font = font.family_default

// Timeframe limits for SSMT (hardcoded)
ssmt_botm = "1"
ssmt_topm = "2"
ssmt_botN = "3"
ssmt_topN = "10"
ssmt_botD = "15"
ssmt_topD = "30"
ssmt_botW = "60"
ssmt_topW = "720"
ssmt_botMo = "240"
ssmt_topMo = "10080"

// --- SSMT Visual Settings ---
ssmt_hidelines  = input.bool(false, "Hide lines", inline="00", group=ssmt_g6)
ssmt_ssmt_history_limit = input.int(5, "SSMT History Limit", minval=1, maxval=100, group=ssmt_g6)
ssmt_hidelabels = input.bool(false, "Hide labels", inline="00", group=ssmt_g6)

// Normal SSMT - all colors with 50% opacity (using color.new)
ssmt_show_smtMo = input.bool(true, "Normal Monthly", inline="m0", group=ssmt_g6)
ssmt_show_smtW  = input.bool(true, "Normal Weekly", inline="0", group=ssmt_g6)
ssmt_show_smtD  = input.bool(true, "Normal Daily", inline="1", group=ssmt_g6)
ssmt_show_smtN  = input.bool(true, "Normal 90m", inline="2", group=ssmt_g6)
ssmt_show_smtm  = input.bool(true, "Normal Micro", inline="3", group=ssmt_g6)

ssmt_smtMo_clr  = input.color(color.new(color.rgb(41,98,255), 50), "N", inline="m0", group=ssmt_g6)
ssmt_smtW_clr   = input.color(color.new(color.rgb(41,98,255), 50), "N", inline="0", group=ssmt_g6)
ssmt_smtD_clr   = input.color(color.new(color.rgb(39,37,37), 50), "N", inline="1", group=ssmt_g6)
ssmt_smtN_clr   = input.color(color.new(color.rgb(39,37,37), 50), "N", inline="2", group=ssmt_g6)
ssmt_smtm_clr   = input.color(color.new(color.rgb(39,37,37), 50), "N", inline="3", group=ssmt_g6)

// Hidden SSMT - all colors with 50% opacity
ssmt_show_hsmtMo = input.bool(true, "Hidden Monthly", inline="m0", group=ssmt_g6)
ssmt_show_hsmtW  = input.bool(true, "Hidden Weekly", inline="0", group=ssmt_g6)
ssmt_show_hsmtD  = input.bool(true, "Hidden Daily", inline="1", group=ssmt_g6)
ssmt_show_hsmtN  = input.bool(true, "Hidden 90m", inline="2", group=ssmt_g6)
ssmt_show_hsmtm  = input.bool(true, "Hidden Micro", inline="3", group=ssmt_g6)

ssmt_hsmtMo_clr = input.color(color.new(color.rgb(41,98,255), 50), "H", inline="m0", group=ssmt_g6)
ssmt_hsmtW_clr  = input.color(color.new(color.rgb(41,98,255), 50), "H", inline="0", group=ssmt_g6)
ssmt_hsmtD_clr  = input.color(color.new(color.rgb(39,37,37), 50), "H", inline="1", group=ssmt_g6)
ssmt_hsmtN_clr  = input.color(color.new(color.rgb(39,37,37), 50), "H", inline="2", group=ssmt_g6)
ssmt_hsmtm_clr  = input.color(color.new(color.rgb(39,37,37), 50), "H", inline="3", group=ssmt_g6)

ssmt_smt_txt_all = input.color(color.rgb(62,64,71), "SSMT Text Color", group=ssmt_g6)
ssmt_normstyle  = input.string(line.style_solid, "Normal SSMT line style", options=[line.style_solid, line.style_dotted, line.style_dashed], group=ssmt_g6)
ssmt_hiddstyle  = input.string(line.style_dashed, "Hidden SSMT line style", options=[line.style_solid, line.style_dotted, line.style_dashed], group=ssmt_g6)

// --- Triad Correlation Settings (default Manual, Triad 1 active with GBPUSD, EURUSD, DXY and Inverse) ---
ssmt_triad_selection_mode = input.string("Manual", "Triad Selection", options=["Auto", "Manual", "Off"], group=ssmt_g11)
ssmt_tr1A = ssmt_triad_selection_mode == "Manual"

ssmt_enable_m1 = input.bool(true, "Triad 1", group=ssmt_g11, inline="m1")
ssmt_st1_m1 = input.symbol("FOREXCOM:GBPUSD", "", group=ssmt_g11, inline="m1")
ssmt_st2_m1 = input.symbol("FOREXCOM:EURUSD", "&", group=ssmt_g11, inline="m1")
ssmt_st3_m1 = input.symbol("CAPITALCOM:DXY", "&", group=ssmt_g11, inline="m1")
ssmt_inv_m1 = input.bool(true, "Inverse", group=ssmt_g11, inline="m1")

ssmt_enable_m2 = input.bool(false, "Triad 2", group=ssmt_g11, inline="m2")
ssmt_st1_m2 = input.symbol("", "", group=ssmt_g11, inline="m2")
ssmt_st2_m2 = input.symbol("", "&", group=ssmt_g11, inline="m2")
ssmt_st3_m2 = input.symbol("", "&", group=ssmt_g11, inline="m2")
ssmt_inv_m2 = input.bool(false, "Inverse", group=ssmt_g11, inline="m2")

ssmt_showsmt1 = input.bool(true, "Show SMT 1", group=ssmt_g11, inline="s5")
ssmt_showsmt2 = input.bool(true, "Show SMT 2", group=ssmt_g11, inline="s5")

// --- Timezone & Adjustment (for futures) ---
ssmt_tz_incr = input.int(-5, 'UTC (+/-)', group='Timezone', inline="s6")
ssmt_badj = input.bool(true, "B-ADJ (for futures)", group='Timezone', inline="s6")
var ssmt_tz = str.format('UTC{0}{1}', ssmt_tz_incr >= 0 ? '+' : '-', math.abs(ssmt_tz_incr))

// --- SSMT global variables ---
ssmt_n = bar_index
ssmt_tf = timeframe.period
ssmt_sym = syminfo.tickerid
ssmt_arr_inv = array.from(false, false)
ssmt_day_week = dayofweek(time, 'America/New_York')
ssmt_num_candles = 5

// --- Array helper functions ---
ssmt_add_to_array(arr, value) =>
    array.unshift(arr, value)
    if array.size(arr) > ssmt_num_candles - 1
        array.pop(arr)

ssmt_add_to_line_array(arr, value) =>
    array.unshift(arr, value)
    if array.size(arr) > ssmt_ssmt_history_limit
        line.delete(array.pop(arr))

ssmt_add_to_label_array(arr, value) =>
    array.unshift(arr, value)
    if array.size(arr) > ssmt_ssmt_history_limit
        label.delete(array.pop(arr))

// --- Live sym function (to obtain candle data from a higher timeframe) ---
ssmt_f_live_sym(_xc0, _xo0, _xh0, _xl0, _xt0, _tf) =>
    var _c1 = 0.0
    var _o1 = 0.0
    var _h1 = 0.0
    var _l1 = 0.0
    var _t1 = 0
    var _c2 = 0.0
    var _o2 = 0.0
    var _h2 = 0.0
    var _l2 = 0.0
    var _t2 = 0
    var up0 = false
    var up1 = false
    var dw0 = false
    var dw1 = false
    var _l0t = time
    var _h0t = time
    var _h1t = time
    var _l1t = time
    var _o0 = open
    var _h0 = high
    var _l0 = low
    var _t0 = time
    var _c0 = close
    if timeframe.change(_tf)
        _t0 := _xt0
        _o0 := _xo0
        _h0 := _xh0
        _l0 := _xl0
    if _xh0 >= _h0
        _h0 := _xh0
        _h0t := time
    if _xl0 <= _l0
        _l0 := _xl0
        _l0t := time
    _c0 := _xc0
    up0 := _c0 > _o0
    dw0 := _c0 < _o0
    if timeframe.change(_tf)
        _c1 := _c0[1]
        _o1 := _o0[1]
        _h1 := _h0[1]
        _l1 := _l0[1]
        _t1 := _t0[1]
        _c2 := _c1[1]
        _o2 := _o1[1]
        _h2 := _h1[1]
        _l2 := _l1[1]
        _t2 := _t1[1]
        up1 := up0[1]
        dw1 := dw0[1]
        _l1t := _l0t[1]
        _h1t := _h0t[1]
    [_h2, _l2, _c2, _o2, _t2, _h1, _l1, _c1, _o1, _t1, _h0, _l0, _c0, _o0, _t0, up1, dw1, _l1t, _h1t]

ssmt_f_text(string _tf) =>
    _text = str.tonumber(_tf) < 59 ? _tf + 'm' : str.tonumber(_tf) > 59 ? 'h' + str.tostring(math.floor(str.tonumber(_tf) / 60)) : _tf
    _text := _tf == "1D" ? "D" : _tf == "1W" ? "W" : _tf == "1M" ? "M" : _text

// --- Timeframe detection for SSMT ---
ssmt_tf_ok_mic = timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds("5")
ssmt_tf_ok = timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds("30")
ssmt_tf_okD = timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds("180")
ssmt_tf_okW = timeframe.in_seconds(ssmt_tf) < timeframe.in_seconds("240")
ssmt_tf_okMo = timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds("10080")

ssmt_tf_ok_mic_V = ssmt_modeltype == ssmt_mdl1 ? (timeframe.in_seconds(ssmt_tf) >= timeframe.in_seconds(ssmt_botm) and timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds(ssmt_topm)) : (timeframe.in_seconds(ssmt_tf) <= 120)
ssmt_tf_ok_V = ssmt_modeltype == ssmt_mdl1 ? (timeframe.in_seconds(ssmt_tf) >= timeframe.in_seconds(ssmt_botN) and timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds(ssmt_topN)) : (timeframe.in_seconds(ssmt_tf) <= 900)
ssmt_tf_okD_V = ssmt_modeltype == ssmt_mdl1 ? (timeframe.in_seconds(ssmt_tf) >= timeframe.in_seconds(ssmt_botD) and timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds(ssmt_topD)) : (timeframe.in_seconds(ssmt_tf) <= 3600)
ssmt_tf_okW_V = ssmt_modeltype == ssmt_mdl1 ? (timeframe.in_seconds(ssmt_tf) >= timeframe.in_seconds(ssmt_botW) and timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds(ssmt_topW)) : (timeframe.in_seconds(ssmt_tf) <= 14400)
ssmt_tf_okMo_V = ssmt_modeltype == ssmt_mdl1 ? (timeframe.in_seconds(ssmt_tf) >= timeframe.in_seconds(ssmt_botMo) and timeframe.in_seconds(ssmt_tf) <= timeframe.in_seconds(ssmt_topMo)) : true

// --- Session definitions (required for SSMT cycles) ---
// Micro cycles (22.5 minutes)
ssmt_sesa1_txt = 'Asian Aa'
ssmt_txta1 = "A"
ssmt_is_sesa1 = not na(time(ssmt_tf, '1800-1823', ssmt_tz))
ssmt_sesa2_txt = 'Asian Am'
ssmt_txta2 = "M"
ssmt_is_sesa2 = not na(time(ssmt_tf, '1823-1845', ssmt_tz))
ssmt_sesa3_txt = 'Asian Ad'
ssmt_txta3 = "D"
ssmt_is_sesa3 = not na(time(ssmt_tf, '1845-1908', ssmt_tz))
ssmt_sesa4_txt = 'Asian Ar'
ssmt_txta4 = "X"
ssmt_is_sesa4 = not na(time(ssmt_tf, '1908-1930', ssmt_tz))
ssmt_sesb1_txt = 'Asian Ma'
ssmt_txtb1 = "A"
ssmt_is_sesb1 = not na(time(ssmt_tf, '1930-1953', ssmt_tz))
ssmt_sesb2_txt = 'Asian Mm'
ssmt_txtb2 = "M"
ssmt_is_sesb2 = not na(time(ssmt_tf, '1953-2015', ssmt_tz))
ssmt_sesb3_txt = 'Asian Md'
ssmt_txtb3 = "D"
ssmt_is_sesb3 = not na(time(ssmt_tf, '2015-2038', ssmt_tz))
ssmt_sesb4_txt = 'Asian Mr'
ssmt_txtb4 = "X"
ssmt_is_sesb4 = not na(time(ssmt_tf, '2038-2100', ssmt_tz))
ssmt_sesc1_txt = 'Asian Da'
ssmt_txtc1 = "A"
ssmt_is_sesc1 = not na(time(ssmt_tf, '2100-2123', ssmt_tz))
ssmt_sesc2_txt = 'Asian Dm'
ssmt_txtc2 = "M"
ssmt_is_sesc2 = not na(time(ssmt_tf, '2123-2145', ssmt_tz))
ssmt_sesc3_txt = 'Asian Dd'
ssmt_txtc3 = "D"
ssmt_is_sesc3 = not na(time(ssmt_tf, '2145-2208', ssmt_tz))
ssmt_sesc4_txt = 'Asian Dr'
ssmt_txtc4 = "X"
ssmt_is_sesc4 = not na(time(ssmt_tf, '2208-2230', ssmt_tz))
ssmt_sesd1_txt = 'Asian Ra'
ssmt_txtd1 = "A"
ssmt_is_sesd1 = not na(time(ssmt_tf, '2230-2253', ssmt_tz))
ssmt_sesd2_txt = 'Asian Rm'
ssmt_txtd2 = "M"
ssmt_is_sesd2 = not na(time(ssmt_tf, '2253-2315', ssmt_tz))
ssmt_sesd3_txt = 'Asian Rd'
ssmt_txtd3 = "D"
ssmt_is_sesd3 = not na(time(ssmt_tf, '2315-2338', ssmt_tz))
ssmt_sesd4_txt = 'Asian Rr'
ssmt_txtd4 = "X"
ssmt_is_sesd4 = not na(time(ssmt_tf, '2338-0000', ssmt_tz))
ssmt_sese1_txt = 'London Aa'
ssmt_txte1 = "A"
ssmt_is_sese1 = not na(time(ssmt_tf, '0000-0023', ssmt_tz))
ssmt_sese2_txt = 'London Am'
ssmt_txte2 = "M"
ssmt_is_sese2 = not na(time(ssmt_tf, '0023-0045', ssmt_tz))
ssmt_sese3_txt = 'London Ad'
ssmt_txte3 = "D"
ssmt_is_sese3 = not na(time(ssmt_tf, '0045-0108', ssmt_tz))
ssmt_sese4_txt = 'London Rr'
ssmt_txte4 = "X"
ssmt_is_sese4 = not na(time(ssmt_tf, '0108-0130', ssmt_tz))
ssmt_sesf1_txt = 'London Ma'
ssmt_txtf1 = "A"
ssmt_is_sesf1 = not na(time(ssmt_tf, '0130-0153', ssmt_tz))
ssmt_sesf2_txt = 'London Mm'
ssmt_txtf2 = "M"
ssmt_is_sesf2 = not na(time(ssmt_tf, '0153-0215', ssmt_tz))
ssmt_sesf3_txt = 'London Md'
ssmt_txtf3 = "D"
ssmt_is_sesf3 = not na(time(ssmt_tf, '0215-0238', ssmt_tz))
ssmt_sesf4_txt = 'London Mr'
ssmt_txtf4 = "X"
ssmt_is_sesf4 = not na(time(ssmt_tf, '0238-0300', ssmt_tz))
ssmt_sesg1_txt = 'London Da'
ssmt_txtg1 = "A"
ssmt_is_sesg1 = not na(time(ssmt_tf, '0300-0323', ssmt_tz))
ssmt_sesg2_txt = 'London Dm'
ssmt_txtg2 = "M"
ssmt_is_sesg2 = not na(time(ssmt_tf, '0323-0345', ssmt_tz))
ssmt_sesg3_txt = 'London Dd'
ssmt_txtg3 = "D"
ssmt_is_sesg3 = not na(time(ssmt_tf, '0345-0408', ssmt_tz))
ssmt_sesg4_txt = 'London Dr'
ssmt_txtg4 = "X"
ssmt_is_sesg4 = not na(time(ssmt_tf, '0408-0430', ssmt_tz))
ssmt_sesh1_txt = 'London Ra'
ssmt_txth1 = "A"
ssmt_is_sesh1 = not na(time(ssmt_tf, '0430-0453', ssmt_tz))
ssmt_sesh2_txt = 'London Rm'
ssmt_txth2 = "M"
ssmt_is_sesh2 = not na(time(ssmt_tf, '0453-0515', ssmt_tz))
ssmt_sesh3_txt = 'London Rd'
ssmt_txth3 = "D"
ssmt_is_sesh3 = not na(time(ssmt_tf, '0515-0538', ssmt_tz))
ssmt_sesh4_txt = 'London Rr'
ssmt_txth4 = "X"
ssmt_is_sesh4 = not na(time(ssmt_tf, '0538-0600', ssmt_tz))
ssmt_sesi1_txt = 'NY Aa'
ssmt_txti1 = "A"
ssmt_is_sesi1 = not na(time(ssmt_tf, '0600-0623', ssmt_tz))
ssmt_sesi2_txt = 'NY Am'
ssmt_txti2 = "M"
ssmt_is_sesi2 = not na(time(ssmt_tf, '0623-0645', ssmt_tz))
ssmt_sesi3_txt = 'NY Ad'
ssmt_txti3 = "D"
ssmt_is_sesi3 = not na(time(ssmt_tf, '0645-0708', ssmt_tz))
ssmt_sesi4_txt = 'NY Ar'
ssmt_txti4 = "X"
ssmt_is_sesi4 = not na(time(ssmt_tf, '0708-0730', ssmt_tz))
ssmt_sesj1_txt = 'NY Ma'
ssmt_txtj1 = "A"
ssmt_is_sesj1 = not na(time(ssmt_tf, '0730-0753', ssmt_tz))
ssmt_sesj2_txt = 'NY Mm'
ssmt_txtj2 = "M"
ssmt_is_sesj2 = not na(time(ssmt_tf, '0753-0815', ssmt_tz))
ssmt_sesj3_txt = 'NY Md'
ssmt_txtj3 = "D"
ssmt_is_sesj3 = not na(time(ssmt_tf, '0815-0838', ssmt_tz))
ssmt_sesj4_txt = 'NY Mr'
ssmt_txtj4 = "X"
ssmt_is_sesj4 = not na(time(ssmt_tf, '0838-0900', ssmt_tz))
ssmt_sesk1_txt = 'NY Da'
ssmt_txtk1 = "A"
ssmt_is_sesk1 = not na(time(ssmt_tf, '0900-0923', ssmt_tz))
ssmt_sesk2_txt = 'NY Dm'
ssmt_txtk2 = "M"
ssmt_is_sesk2 = not na(time(ssmt_tf, '0923-0945', ssmt_tz))
ssmt_sesk3_txt = 'NY Dd'
ssmt_txtk3 = "D"
ssmt_is_sesk3 = not na(time(ssmt_tf, '0945-1008', ssmt_tz))
ssmt_sesk4_txt = 'NY Dr'
ssmt_txtk4 = "X"
ssmt_is_sesk4 = not na(time(ssmt_tf, '1008-1030', ssmt_tz))
ssmt_sesl1_txt = 'NY Ra'
ssmt_txtl1 = "A"
ssmt_is_sesl1 = not na(time(ssmt_tf, '1030-1053', ssmt_tz))
ssmt_sesl2_txt = 'NY Rm'
ssmt_txtl2 = "M"
ssmt_is_sesl2 = not na(time(ssmt_tf, '1053-1115', ssmt_tz))
ssmt_sesl3_txt = 'NY Rd'
ssmt_txtl3 = "D"
ssmt_is_sesl3 = not na(time(ssmt_tf, '1115-1138', ssmt_tz))
ssmt_sesl4_txt = 'NY Rr'
ssmt_txtl4 = "X"
ssmt_is_sesl4 = not na(time(ssmt_tf, '1138-1200', ssmt_tz))
ssmt_sesm1_txt = 'PM Aa'
ssmt_txtm1 = "A"
ssmt_is_sesm1 = not na(time(ssmt_tf, '1200-1223', ssmt_tz))
ssmt_sesm2_txt = 'PM Am'
ssmt_txtm2 = "M"
ssmt_is_sesm2 = not na(time(ssmt_tf, '1223-1245', ssmt_tz))
ssmt_sesm3_txt = 'PM Ad'
ssmt_txtm3 = "D"
ssmt_is_sesm3 = not na(time(ssmt_tf, '1245-1308', ssmt_tz))
ssmt_sesm4_txt = 'PM Ar'
ssmt_txtm4 = "X"
ssmt_is_sesm4 = not na(time(ssmt_tf, '1308-1330', ssmt_tz))
ssmt_sesn1_txt = 'PM Ma'
ssmt_txtn1 = "A"
ssmt_is_sesn1 = not na(time(ssmt_tf, '1330-1353', ssmt_tz))
ssmt_sesn2_txt = 'PM Mm'
ssmt_txtn2 = "M"
ssmt_is_sesn2 = not na(time(ssmt_tf, '1353-1415', ssmt_tz))
ssmt_sesn3_txt = 'PM Md'
ssmt_txtn3 = "D"
ssmt_is_sesn3 = not na(time(ssmt_tf, '1415-1438', ssmt_tz))
ssmt_sesn4_txt = 'PM Mr'
ssmt_txtn4 = "X"
ssmt_is_sesn4 = not na(time(ssmt_tf, '1438-1500', ssmt_tz))
ssmt_seso1_txt = 'PM Da'
ssmt_txto1 = "A"
ssmt_is_seso1 = not na(time(ssmt_tf, '1500-1523', ssmt_tz))
ssmt_seso2_txt = 'PM Dm'
ssmt_txto2 = "M"
ssmt_is_seso2 = not na(time(ssmt_tf, '1523-1545', ssmt_tz))
ssmt_seso3_txt = 'PM Dd'
ssmt_txto3 = "D"
ssmt_is_seso3 = not na(time(ssmt_tf, '1545-1608', ssmt_tz))
ssmt_seso4_txt = 'PM Dr'
ssmt_txto4 = "X"
ssmt_is_seso4 = not na(time(ssmt_tf, '1608-1630', ssmt_tz))
ssmt_sesp1_txt = 'PM Ra'
ssmt_txtp1 = "A"
ssmt_is_sesp1 = not na(time(ssmt_tf, '1630-1653', ssmt_tz))
ssmt_sesp2_txt = 'PM Rm'
ssmt_txtp2 = "M"
ssmt_is_sesp2 = not na(time(ssmt_tf, '1653-1715', ssmt_tz))
ssmt_sesp3_txt = 'PM Rd'
ssmt_txtp3 = "D"
ssmt_is_sesp3 = not na(time(ssmt_tf, '1715-1738', ssmt_tz))
ssmt_sesp4_txt = 'PM Rr'
ssmt_txtp4 = "X"
ssmt_is_sesp4 = not na(time(ssmt_tf, '1738-1800', ssmt_tz))

// 90m cycles
ssmt_sesa_txt = 'Asian A'
ssmt_txta = "A"
ssmt_is_sesa = not na(time(ssmt_tf, '1800-1930', ssmt_tz))
ssmt_sesb_txt = 'Asian M'
ssmt_txtb = "M"
ssmt_is_sesb = not na(time(ssmt_tf, '1930-2100', ssmt_tz))
ssmt_sesc_txt = 'Asian D'
ssmt_txtc = "D"
ssmt_is_sesc = not na(time(ssmt_tf, '2100-2230', ssmt_tz))
ssmt_sesd_txt = 'Asian R'
ssmt_txtd = "X"
ssmt_is_sesd = not na(time(ssmt_tf, '2230-0000', ssmt_tz))
ssmt_sese_txt = 'London A'
ssmt_txte = "A"
ssmt_is_sese = not na(time(ssmt_tf, '0000-0130', ssmt_tz))
ssmt_sesf_txt = 'London M'
ssmt_txtf = "M"
ssmt_is_sesf = not na(time(ssmt_tf, '0130-0300', ssmt_tz))
ssmt_sesg_txt = 'London D'
ssmt_txtg = "D"
ssmt_is_sesg = not na(time(ssmt_tf, '0300-0430', ssmt_tz))
ssmt_sesh_txt = 'London R'
ssmt_txth = "X"
ssmt_is_sesh = not na(time(ssmt_tf, '0430-0600', ssmt_tz))
ssmt_sesi_txt = 'NY A'
ssmt_txti = "A"
ssmt_is_sesi = not na(time(ssmt_tf, '0600-0730', ssmt_tz))
ssmt_sesj_txt = 'NY M'
ssmt_txtj = "M"
ssmt_is_sesj = not na(time(ssmt_tf, '0730-0900', ssmt_tz))
ssmt_sesk_txt = 'NY D'
ssmt_txtk = "D"
ssmt_is_sesk = not na(time(ssmt_tf, '0900-1030', ssmt_tz))
ssmt_sesl_txt = 'NY R'
ssmt_txtl = "X"
ssmt_is_sesl = not na(time(ssmt_tf, '1030-1200', ssmt_tz))
ssmt_sesm_txt = 'PM A'
ssmt_txtm = "A"
ssmt_is_sesm = not na(time(ssmt_tf, '1200-1330', ssmt_tz))
ssmt_sesn_txt = 'PM M'
ssmt_txtn = "M"
ssmt_is_sesn = not na(time(ssmt_tf, '1330-1500', ssmt_tz))
ssmt_seso_txt = 'PM D'
ssmt_txto = "D"
ssmt_is_seso = not na(time(ssmt_tf, '1500-1630', ssmt_tz))
ssmt_sesp_txt = 'PM R'
ssmt_txtp = "X"
ssmt_is_sesp = not na(time(ssmt_tf, '1630-1800', ssmt_tz))

// Daily cycles
ssmt_sesq_txt = 'Daily A'
ssmt_txtq = "A"
ssmt_is_sesq = not na(time(ssmt_tf, '1800-0000', ssmt_tz))
ssmt_sesr_txt = 'Daily M'
ssmt_txtr = "M"
ssmt_is_sesr = not na(time(ssmt_tf, '0000-0600', ssmt_tz))
ssmt_sess_txt = 'Daily D'
ssmt_txts = "D"
ssmt_is_sess = not na(time(ssmt_tf, '0600-1200', ssmt_tz))
ssmt_sest_txt = 'Daily R'
ssmt_txtt = "X"
ssmt_is_sest = not na(time(ssmt_tf, '1200-1800', ssmt_tz))

// Weekly cycle (based on day)
var ssmt_trueday = 2
var ssmt_newday = false
if ssmt_is_sesq[1] == false and ssmt_is_sesq == true and ssmt_newday == false
    ssmt_trueday := ssmt_day_week == 1 ? 2 : ssmt_day_week == 2 ? 3 : ssmt_day_week == 3 ? 4 : ssmt_day_week == 4 ? 5 : ssmt_day_week == 5 ? 6 : ssmt_day_week == 6 ? 7 : 1
    ssmt_newday := true
if (ssmt_is_sesq[1] == true and ssmt_is_sesq == true)
    ssmt_newday := false
ssmt_is_week1 = ssmt_trueday == 2
ssmt_is_week2 = ssmt_trueday == 3
ssmt_is_week3 = ssmt_trueday == 4
ssmt_is_week4 = ssmt_trueday == 5
ssmt_is_week5 = ssmt_trueday == 6
ssmt_is_week6 = ssmt_trueday == 7
ssmt_is_week7 = ssmt_trueday == 1

// Monthly cycle (based on date)
ssmt_dom = dayofmonth(time, ssmt_tz)
ssmt_is_month1 = ssmt_dom <= 7
ssmt_is_month2 = ssmt_dom > 7 and ssmt_dom <= 14
ssmt_is_month3 = ssmt_dom > 14 and ssmt_dom <= 21
ssmt_is_month4 = ssmt_dom > 21

// Array to store session status
ssmt_arr_sesm   = array.from(ssmt_is_sesa1, ssmt_is_sesa2, ssmt_is_sesa3, ssmt_is_sesa4, ssmt_is_sesb1, ssmt_is_sesb2, ssmt_is_sesb3, ssmt_is_sesb4, ssmt_is_sesc1, ssmt_is_sesc2, ssmt_is_sesc3, ssmt_is_sesc4, ssmt_is_sesd1, ssmt_is_sesd2, ssmt_is_sesd3, ssmt_is_sesd4, ssmt_is_sese1, ssmt_is_sese2, ssmt_is_sese3, ssmt_is_sese4, ssmt_is_sesf1, ssmt_is_sesf2, ssmt_is_sesf3, ssmt_is_sesf4, ssmt_is_sesg1, ssmt_is_sesg2, ssmt_is_sesg3, ssmt_is_sesg4, ssmt_is_sesh1, ssmt_is_sesh2, ssmt_is_sesh3, ssmt_is_sesh4, ssmt_is_sesi1, ssmt_is_sesi2, ssmt_is_sesi3, ssmt_is_sesi4, ssmt_is_sesj1, ssmt_is_sesj2, ssmt_is_sesj3, ssmt_is_sesj4, ssmt_is_sesk1, ssmt_is_sesk2, ssmt_is_sesk3, ssmt_is_sesk4, ssmt_is_sesl1, ssmt_is_sesl2, ssmt_is_sesl3, ssmt_is_sesl4, ssmt_is_sesm1, ssmt_is_sesm2, ssmt_is_sesm3, ssmt_is_sesm4, ssmt_is_sesn1, ssmt_is_sesn2, ssmt_is_sesn3, ssmt_is_sesn4, ssmt_is_seso1, ssmt_is_seso2, ssmt_is_seso3, ssmt_is_seso4, ssmt_is_sesp1, ssmt_is_sesp2, ssmt_is_sesp3, ssmt_is_sesp4)
ssmt_arr_sesmy  = array.from(ssmt_txta1, ssmt_txta2, ssmt_txta3, ssmt_txta4, ssmt_txtb1, ssmt_txtb2, ssmt_txtb3, ssmt_txtb4, ssmt_txtc1, ssmt_txtc2, ssmt_txtc3, ssmt_txtc4, ssmt_txtd1, ssmt_txtd2, ssmt_txtd3, ssmt_txtd4, ssmt_txte1, ssmt_txte2, ssmt_txte3, ssmt_txte4, ssmt_txtf1, ssmt_txtf2, ssmt_txtf3, ssmt_txtf4, ssmt_txtg1, ssmt_txtg2, ssmt_txtg3, ssmt_txtg4, ssmt_txth1, ssmt_txth2, ssmt_txth3, ssmt_txth4, ssmt_txti1, ssmt_txti2, ssmt_txti3, ssmt_txti4, ssmt_txtj1, ssmt_txtj2, ssmt_txtj3, ssmt_txtj4, ssmt_txtk1, ssmt_txtk2, ssmt_txtk3, ssmt_txtk4, ssmt_txtl1, ssmt_txtl2, ssmt_txtl3, ssmt_txtl4, ssmt_txtm1, ssmt_txtm2, ssmt_txtm3, ssmt_txtm4, ssmt_txtn1, ssmt_txtn2, ssmt_txtn3, ssmt_txtn4, ssmt_txto1, ssmt_txto2, ssmt_txto3, ssmt_txto4, ssmt_txtp1, ssmt_txtp2, ssmt_txtp3, ssmt_txtp4)
ssmt_arr_sesmz  = array.from(ssmt_sesa1_txt, ssmt_sesa2_txt, ssmt_sesa3_txt, ssmt_sesa4_txt, ssmt_sesb1_txt, ssmt_sesb2_txt, ssmt_sesb3_txt, ssmt_sesb4_txt, ssmt_sesc1_txt, ssmt_sesc2_txt, ssmt_sesc3_txt, ssmt_sesc4_txt, ssmt_sesd1_txt, ssmt_sesd2_txt, ssmt_sesd3_txt, ssmt_sesd4_txt, ssmt_sese1_txt, ssmt_sese2_txt, ssmt_sese3_txt, ssmt_sese4_txt, ssmt_sesf1_txt, ssmt_sesf2_txt, ssmt_sesf3_txt, ssmt_sesf4_txt, ssmt_sesg1_txt, ssmt_sesg2_txt, ssmt_sesg3_txt, ssmt_sesg4_txt, ssmt_sesh1_txt, ssmt_sesh2_txt, ssmt_sesh3_txt, ssmt_sesh4_txt, ssmt_sesi1_txt, ssmt_sesi2_txt, ssmt_sesi3_txt, ssmt_sesi4_txt, ssmt_sesj1_txt, ssmt_sesj2_txt, ssmt_sesj3_txt, ssmt_sesj4_txt, ssmt_sesk1_txt, ssmt_sesk2_txt, ssmt_sesk3_txt, ssmt_sesk4_txt, ssmt_sesl1_txt, ssmt_sesl2_txt, ssmt_sesl3_txt, ssmt_sesl4_txt, ssmt_sesm1_txt, ssmt_sesm2_txt, ssmt_sesm3_txt, ssmt_sesm4_txt, ssmt_sesn1_txt, ssmt_sesn2_txt, ssmt_sesn3_txt, ssmt_sesn4_txt, ssmt_seso1_txt, ssmt_seso2_txt, ssmt_seso3_txt, ssmt_seso4_txt, ssmt_sesp1_txt, ssmt_sesp2_txt, ssmt_sesp3_txt, ssmt_sesp4_txt)
ssmt_val_sesm   = array.indexof(ssmt_arr_sesm, true)

ssmt_arr_ses    = array.from(ssmt_is_sesa, ssmt_is_sesb, ssmt_is_sesc, ssmt_is_sesd, ssmt_is_sese, ssmt_is_sesf, ssmt_is_sesg, ssmt_is_sesh, ssmt_is_sesi, ssmt_is_sesj, ssmt_is_sesk, ssmt_is_sesl, ssmt_is_sesm, ssmt_is_sesn, ssmt_is_seso, ssmt_is_sesp)
ssmt_arr_sesy   = array.from(ssmt_txta, ssmt_txtb, ssmt_txtc, ssmt_txtd, ssmt_txte, ssmt_txtf, ssmt_txtg, ssmt_txth, ssmt_txti, ssmt_txtj, ssmt_txtk, ssmt_txtl, ssmt_txtm, ssmt_txtn, ssmt_txto, ssmt_txtp)
ssmt_arr_sesz   = array.from(ssmt_sesa_txt, ssmt_sesb_txt, ssmt_sesc_txt, ssmt_sesd_txt, ssmt_sese_txt, ssmt_sesf_txt, ssmt_sesg_txt, ssmt_sesh_txt, ssmt_sesi_txt, ssmt_sesj_txt, ssmt_sesk_txt, ssmt_sesl_txt, ssmt_sesm_txt, ssmt_sesn_txt, ssmt_seso_txt, ssmt_sesp_txt)
ssmt_val_ses    = array.indexof(ssmt_arr_ses, true)

ssmt_arr_sesD   = array.from(ssmt_is_sesq, ssmt_is_sesr, ssmt_is_sess, ssmt_is_sest)
ssmt_arr_sesDy  = array.from(ssmt_txtq, ssmt_txtr, ssmt_txts, ssmt_txtt)
ssmt_arr_sesDz  = array.from(ssmt_sesq_txt, ssmt_sesr_txt, ssmt_sess_txt, ssmt_sest_txt)
ssmt_val_sesD   = array.indexof(ssmt_arr_sesD, true)

ssmt_arr_sesW   = array.from(ssmt_is_week1, ssmt_is_week2, ssmt_is_week3, ssmt_is_week4, ssmt_is_week5, ssmt_is_week6, ssmt_is_week7)
ssmt_arr_sesWy  = array.from("A", "M", "D", "X", "Fr", "Sat", "Sun")
ssmt_arr_sesWz  = array.from("Weekly A", "Weekly B", "Weekly C", "Weekly D", "Weekly x", "Weekly x", "Weekly x")
ssmt_val_sesW   = array.indexof(ssmt_arr_sesW, true)

ssmt_arr_sesMo  = array.from(ssmt_is_month1, ssmt_is_month2, ssmt_is_month3, ssmt_is_month4)
ssmt_arr_sesMoy = array.from("W1", "W2", "W3", "W4")
ssmt_arr_sesMoz = array.from("Monthly W1", "Monthly W2", "Monthly W3", "Monthly W4")
ssmt_val_sesMo  = array.indexof(ssmt_arr_sesMo, true)

ssmt_newMo = ssmt_val_sesMo != ssmt_val_sesMo[1]
ssmt_newW = ssmt_val_sesW != ssmt_val_sesW[1]
ssmt_newD = ssmt_val_sesD != ssmt_val_sesD[1]
ssmt_newN = ssmt_val_ses != ssmt_val_ses[1]
ssmt_newm = ssmt_val_sesm != ssmt_val_sesm[1]

ssmt_arrstart = array.from(0, 0, 0, 0, 0)
ssmt_dx = 10

// --- Correlation (Triad) ---
ssmt_csym = ssmt_sym
ssmt_tsym2 = ssmt_sym
ssmt_tsym3 = ssmt_sym
var string ssmt_current_ticker = syminfo.ticker

ssmt_f_check_match(input_sym) =>
    if str.length(input_sym) == 0 or not str.contains(input_sym, ":")
        false
    else
        t_sym = array.get(str.split(input_sym, ":"), 1)
        (ssmt_current_ticker == t_sym) or str.contains(ssmt_sym, t_sym) or str.contains(input_sym, ssmt_current_ticker)

ssmt_match_m1_1 = ssmt_f_check_match(ssmt_st1_m1)
ssmt_match_m1_2 = ssmt_f_check_match(ssmt_st2_m1)
ssmt_match_m1_3 = ssmt_f_check_match(ssmt_st3_m1)
ssmt_match_m2_1 = ssmt_f_check_match(ssmt_st1_m2)
ssmt_match_m2_2 = ssmt_f_check_match(ssmt_st2_m2)
ssmt_match_m2_3 = ssmt_f_check_match(ssmt_st3_m2)

ssmt_is_in_manual_m1 = ssmt_tr1A and ssmt_enable_m1 and (ssmt_match_m1_1 or ssmt_match_m1_2 or ssmt_match_m1_3)
ssmt_is_in_manual_m2 = ssmt_tr1A and ssmt_enable_m2 and (ssmt_match_m2_1 or ssmt_match_m2_2 or ssmt_match_m2_3)
ssmt_is_in_manual = ssmt_is_in_manual_m1 or ssmt_is_in_manual_m2

var ssmt_st1 = ""
var ssmt_st2 = ""
var ssmt_st3 = ""

if ssmt_is_in_manual_m1 and ssmt_enable_m1
    ssmt_st1 := ssmt_st1_m1
    ssmt_st2 := ssmt_st2_m1
    ssmt_st3 := ssmt_st3_m1
else if ssmt_is_in_manual_m2 and ssmt_enable_m2
    ssmt_st1 := ssmt_st1_m2
    ssmt_st2 := ssmt_st2_m2
    ssmt_st3 := ssmt_st3_m2

// Auto groups
ssmt_is_nq_asset = str.contains(ssmt_sym, "NQ") or str.contains(ssmt_sym, "MNQ")
ssmt_is_es_asset = str.contains(ssmt_sym, "ES") or str.contains(ssmt_sym, "MES")
ssmt_is_ym_asset = str.contains(ssmt_sym, "YM") or str.contains(ssmt_sym, "MYM")
ssmt_is_gc_asset = str.contains(ssmt_sym, "GC") or str.contains(ssmt_sym, "MGC")
ssmt_is_si_asset = str.contains(ssmt_sym, "SI") or str.contains(ssmt_sym, "MSI")
ssmt_is_sl_asset = str.contains(ssmt_sym, "PL") or str.contains(ssmt_sym, "MSL")

ssmt_is_in_g2 = ssmt_tr1B and (str.contains(ssmt_sym, "XAU") or str.contains(ssmt_sym, "XAG") or str.contains(ssmt_sym, "XPT"))
ssmt_is_in_g3 = ssmt_tr1C and (str.contains(ssmt_sym, "BTC") or str.contains(ssmt_sym, "ETH") or str.contains(ssmt_sym, "XRP"))
ssmt_is_in_g4 = ssmt_tr1D and (ssmt_is_nq_asset or ssmt_is_es_asset or ssmt_is_ym_asset)
ssmt_is_in_g5 = ssmt_tr1E and (str.contains(ssmt_sym, "EURUSD") or str.contains(ssmt_sym, "GBPUSD") or str.contains(ssmt_sym, "DXY"))
ssmt_is_in_g6 = ssmt_tr1F and (str.contains(ssmt_sym, "US100") or str.contains(ssmt_sym, "USTEC") or str.contains(ssmt_sym, "NAS100") or str.contains(ssmt_sym, "US500") or str.contains(ssmt_sym, "SPX500") or str.contains(ssmt_sym, "SP500") or str.contains(ssmt_sym, "US30"))
ssmt_is_in_g7 = ssmt_tr1G and (ssmt_is_gc_asset or ssmt_is_si_asset or ssmt_is_sl_asset)

ssmt_triad_ok = ssmt_triad_selection_mode == "Off" ? false : ssmt_triad_selection_mode == "Auto" ? (ssmt_is_in_g2 or ssmt_is_in_g3 or ssmt_is_in_g4 or ssmt_is_in_g5 or ssmt_is_in_g6 or ssmt_is_in_g7) : ssmt_is_in_manual

ssmt_match_1 = ssmt_f_check_match(ssmt_st1)
ssmt_match_2 = ssmt_f_check_match(ssmt_st2)
ssmt_match_3 = ssmt_f_check_match(ssmt_st3)

array.set(ssmt_arr_inv, 0, false)
array.set(ssmt_arr_inv, 1, false)

if ssmt_triad_ok
    if ssmt_is_in_manual
        if ssmt_match_1
            ssmt_tsym2 := ssmt_st2
            ssmt_tsym3 := ssmt_st3
            if (ssmt_is_in_manual_m1 and ssmt_inv_m1) or (ssmt_is_in_manual_m2 and ssmt_inv_m2)
                array.set(ssmt_arr_inv, 1, true)
        else if ssmt_match_2
            ssmt_tsym2 := ssmt_st1
            ssmt_tsym3 := ssmt_st3
            if (ssmt_is_in_manual_m1 and ssmt_inv_m1) or (ssmt_is_in_manual_m2 and ssmt_inv_m2)
                array.set(ssmt_arr_inv, 1, true)
        else if ssmt_match_3
            ssmt_tsym2 := ssmt_st1
            ssmt_tsym3 := ssmt_st2
            if (ssmt_is_in_manual_m1 and ssmt_inv_m1) or (ssmt_is_in_manual_m2 and ssmt_inv_m2)
                array.set(ssmt_arr_inv, 0, true)
                array.set(ssmt_arr_inv, 1, true)
    else if ssmt_is_in_g2
        ssmt_tsym2 := str.contains(ssmt_sym, "XAU") ? ssmt_st5 : ssmt_st4
        ssmt_tsym3 := str.contains(ssmt_sym, "XPT") ? ssmt_st5 : ssmt_st6
    else if ssmt_is_in_g3
        ssmt_tsym2 := str.contains(ssmt_sym, "BTC") ? ssmt_st8 : (str.contains(ssmt_sym, "ETH") ? ssmt_st7 : ssmt_st7)
        ssmt_tsym3 := str.contains(ssmt_sym, "BTC") ? ssmt_st9 : (str.contains(ssmt_sym, "ETH") ? ssmt_st9 : ssmt_st8)
    else if ssmt_is_in_g4
        if ssmt_is_nq_asset
            ssmt_tsym2 := ssmt_st11
            ssmt_tsym3 := ssmt_st12
        else if ssmt_is_es_asset
            ssmt_tsym2 := ssmt_st10
            ssmt_tsym3 := ssmt_st12
        else if ssmt_is_ym_asset
            ssmt_tsym2 := ssmt_st10
            ssmt_tsym3 := ssmt_st11
    else if ssmt_is_in_g5
        ssmt_tsym2 := str.contains(ssmt_sym, "EURUSD") ? ssmt_st14 : (str.contains(ssmt_sym, "GBPUSD") ? ssmt_st13 : ssmt_st13)
        ssmt_tsym3 := str.contains(ssmt_sym, "EURUSD") ? ssmt_st15 : (str.contains(ssmt_sym, "GBPUSD") ? ssmt_st15 : ssmt_st14)
    else if ssmt_is_in_g6
        ssmt_tsym2 := str.contains(ssmt_sym, "US100") ? ssmt_st17 : (str.contains(ssmt_sym, "US500") ? ssmt_st16 : ssmt_st16)
        ssmt_tsym3 := str.contains(ssmt_sym, "US100") ? ssmt_st18 : (str.contains(ssmt_sym, "US500") ? ssmt_st18 : ssmt_st17)
    else if ssmt_is_in_g7
        if ssmt_is_gc_asset
            ssmt_tsym2 := ssmt_st20
            ssmt_tsym3 := ssmt_st21
        else if ssmt_is_si_asset
            ssmt_tsym2 := ssmt_st19
            ssmt_tsym3 := ssmt_st21
        else if ssmt_is_sl_asset
            ssmt_tsym2 := ssmt_st19
            ssmt_tsym3 := ssmt_st20

if ssmt_triad_ok
    ssmt_csym := syminfo.type == "futures" ? ticker.modify(ssmt_tsym2, session=syminfo.session, backadjustment=ssmt_badj ? backadjustment.off : backadjustment.on) : ssmt_tsym2
    ssmt_tsym3 := syminfo.type == "futures" ? ticker.modify(ssmt_tsym3, session=syminfo.session, backadjustment=ssmt_badj ? backadjustment.off : backadjustment.on) : ssmt_tsym3

// Data from correlation pair
[ssmt_xc0, ssmt_xo0, ssmt_xh0, ssmt_xl0, ssmt_xt0] = request.security(ssmt_csym, ssmt_tf, [close, open, high, low, time], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
ssmt_ssmt_pair = str.tostring(syminfo.ticker(ssmt_csym))

[ssmt_yc0, ssmt_yo0, ssmt_yh0, ssmt_yl0, ssmt_yt0] = request.security(ssmt_tsym3, ssmt_tf, [close, open, high, low, time], lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
ssmt_ssmt_pair2 = str.tostring(syminfo.ticker(ssmt_tsym3))

// --- Main function to process each cycle ---
ssmt_f_main_process(_tf_ok, _tf_ok_V, _val_ses, op, cls, hi, lo, ti, show_cand, cyc_txt, arr_sesy, arr_sesz, arrst) =>
    var o0 = op
    var o1 = op
    var o2 = op
    var c1 = cls
    var c2 = cls
    var hmax = hi
    var hmax1 = hi
    var hmax2 = hi
    var lmin = lo
    var lmin1 = lo
    var lmin2 = lo
    var t0 = ti
    var t1 = ti
    var txt0 = ""
    var hmaxt = ti
    var lmint = ti
    var hmaxt1 = ti
    var lmint1 = ti
    var clsmax = math.max(cls, op)
    var clsmaxt = ti
    var clsmin = math.min(cls, op)
    var clsmint = ti
    var clsmax1 = math.max(cls, op)
    var clsmaxt1 = ti
    var clsmin1 = math.min(cls, op)
    var clsmint1 = ti
    var arr_h = array.new_float()
    var arr_l = array.new_float()
    var arr_o = array.new_float()
    var arr_c = array.new_float()
    var arr_t = array.new_string()

    if _tf_ok
        if _val_ses != _val_ses[1]
            o0 := op
            hmax := hi
            lmin := lo
            t0 := ti
            hmaxt := ti
            lmint := ti
            clsmax := math.max(cls, op)
            clsmaxt := ti
            clsmin := math.min(cls, op)
            clsmint := ti

    if _val_ses == _val_ses[1]
        if hi >= hmax
            hmax := hi
            hmaxt := ti
        if lo <= lmin
            lmin := lo
            lmint := ti
        if math.max(cls, op) >= clsmax
            clsmax := math.max(cls, op)
            clsmaxt := ti
        if math.min(cls, op) <= clsmin
            clsmin := math.min(cls, op)
            clsmint := ti

    c0 = cls
    txt0 := array.get(arr_sesy, _val_ses)
    if _val_ses != _val_ses[1]
        ssmt_add_to_array(arr_h, hmax[1])
        ssmt_add_to_array(arr_l, lmin[1])
        ssmt_add_to_array(arr_o, o0[1])
        ssmt_add_to_array(arr_c, cls[1])
        ssmt_add_to_array(arr_t, txt0[1])
        hmax1 := hmax[1]
        lmin1 := lmin[1]
        hmax2 := hmax1[1]
        lmin2 := lmin1[1]
        hmaxt1 := hmaxt[1]
        lmint1 := lmint[1]
        t1 := t0[1]
        clsmax1 := clsmax[1]
        clsmaxt1 := clsmaxt[1]
        clsmin1 := clsmin[1]
        clsmint1 := clsmint[1]
        o1 := o0[1]
        o2 := o1[1]
        c1 := c0[1]
        c2 := c1[1]

    var bias = 0
    if _val_ses != _val_ses[1]
        bias := 0
        if c1 > hmax2
            bias := 1
        if c1 < lmin2
            bias := -1
        if c1 < hmax2 and c1 > lmin2 and hmax1 > hmax2 and lmin1 > lmin2
            bias := -1
        if c1 > lmin2 and c1 < hmax2 and hmax1 < hmax2 and lmin1 < lmin2
            bias := 1
        if hmax1 <= hmax2 and lmin1 >= lmin2
            if c2 > o2
                bias := 1
            else
                bias := -1
    biastxt = bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "No Bias"

    [hmaxt, lmint, hmax2, lmin2, hmax1, lmin1, hmax, lmin, hmaxt1, lmint1, clsmax, clsmax1, clsmaxt1, clsmin, clsmin1, clsmint1, clsmaxt, clsmint, o0, txt0, biastxt]

// --- Normal SSMT function ---
ssmt_f_ssmt(ah2, ah1, ah0, al2, al1, al0, bh2, bh1, bh0, bl2, bl1, bl0, start, show, _hmaxt, _lmint, _hmaxt1, _lmint1, _tfok, _val_ses, showon, _smt_clr, _smt_txt_clr, tri, xx, zh0, zl0, _tf_ok_V, lbl, name, pair, _inv) =>
    _bear1 = ((ah2 >= ah1 and bh2 <= bh1) or (ah2 <= ah1 and bh2 >= bh1)) and not(ah2 == ah1 and bh2 == bh1) and not _inv
    _bear0 = ((ah1 >= ah0 and bh1 <= bh0) or (ah1 <= ah0 and bh1 >= bh0)) and not(ah1 == ah0 and bh1 == bh0) and not _inv
    _bull1 = ((al2 <= al1 and bl2 >= bl1) or (al2 >= al1 and bl2 <= bl1)) and not(al2 == al1 and bl2 == bl1) and not _inv
    _bull0 = ((al1 <= al0 and bl1 >= bl0) or (al1 >= al0 and bl1 <= bl0)) and not(al1 == al0 and bl1 == bl0) and not _inv
    if _inv
        _bear1 := ((ah2 >= ah1 and bl2 >= bl1) or (ah2 <= ah1 and bl2 <= bl1)) and not(ah2 == ah1 and bl2 == bl1)
        _bear0 := ((ah1 >= ah0 and bl1 >= bl0) or (ah1 <= ah0 and bl1 <= bl0)) and not(ah1 == ah0 and bl1 == bl0)
        _bull1 := ((al2 <= al1 and bh2 <= bh1) or (al2 >= al1 and bh2 >= bh1)) and not(al2 == al1 and bh2 == bh1)
        _bull0 := ((al1 <= al0 and bh1 <= bh0) or (al1 >= al0 and bh1 >= bh0)) and not(al1 == al0 and bh1 == bh0)

    tooltiplbl = pair == 2 ? name + " " + ssmt_ssmt_pair : name + " " + ssmt_ssmt_pair2
    lblstyleh = label.style_label_down
    lblstylel = label.style_label_up
    var smth1 = line.new(na, na, na, na)
    var smth0 = line.new(na, na, na, na)
    var smtl1 = line.new(na, na, na, na)
    var smtl0 = line.new(na, na, na, na)
    line.delete(smth1)
    line.delete(smth0)
    line.delete(smtl1)
    line.delete(smtl0)

    if _bear1 and show and _tf_ok_V
        smth1 := line.new(bar_index + start + ssmt_dx + 10, ah2, bar_index + start + ssmt_dx + 13, ah1, color=_smt_clr, width=2)
    if _bear0 and show and _tf_ok_V
        smth0 := line.new(bar_index + start + ssmt_dx + 13, ah1, bar_index + start + ssmt_dx + 16, ah0, color=_smt_clr, width=2)
    if _bull1 and show and _tf_ok_V
        smtl1 := line.new(bar_index + start + ssmt_dx + 10, al2, bar_index + start + ssmt_dx + 13, al1, color=_smt_clr, width=2)
    if _bull0 and show and _tf_ok_V
        smtl0 := line.new(bar_index + start + ssmt_dx + 13, al1, bar_index + start + ssmt_dx + 16, al0, color=_smt_clr, width=2)

    var smtbeh = line.new(na, na, na, na)
    var smtbul = line.new(na, na, na, na)
    var smtbe = label.new(na, na)
    var smtbu = label.new(na, na)
    label ret_smtbe = na
    label ret_smtbu = na
    var arr_beh = array.new_line()
    var arr_lbh = array.new_label()
    var arr_bul = array.new_line()
    var arr_lbl = array.new_label()

    if (_bull0 or _bear0) and showon and _tfok and _tf_ok_V
        if (_val_ses[1] != _val_ses or not _bear0[1] or _hmaxt != _hmaxt[1]) and _bear0
            smtbeh := line.new(x1=_hmaxt1, y1=ah1, x2=_hmaxt, y2=ah0, xloc=xloc.bar_time, color=ssmt_hidelines ? color.new(_smt_clr, 100) : _smt_clr, width=1, style=ssmt_normstyle)
            if not ssmt_hidelabels
                smtbe := label.new(x=math.round((_hmaxt + _hmaxt1) / 2), y=(ah1 + ah0) / 2, text=lbl, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), style=lblstyleh, textcolor=_smt_txt_clr, size=ssmt_i_font, tooltip=tooltiplbl, text_font_family=ssmt_target_font)
                ret_smtbe := smtbe
                ssmt_add_to_label_array(arr_lbh, smtbe)
            ssmt_add_to_line_array(arr_beh, smtbeh)

        if (_val_ses[1] != _val_ses or not _bull0[1] or _lmint != _lmint[1]) and _bull0
            smtbul := line.new(x1=_lmint1, y1=al1, x2=_lmint, y2=al0, xloc=xloc.bar_time, color=ssmt_hidelines ? color.new(_smt_clr, 100) : _smt_clr, width=1, style=ssmt_normstyle)
            if not ssmt_hidelabels
                smtbu := label.new(x=math.round((_lmint + _lmint1) / 2), y=(al1 + al0) / 2, text=lbl, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), style=lblstylel, textcolor=_smt_txt_clr, size=ssmt_i_font, tooltip=tooltiplbl, text_font_family=ssmt_target_font)
                ret_smtbu := smtbu
                ssmt_add_to_label_array(arr_lbl, smtbu)
            ssmt_add_to_line_array(arr_bul, smtbul)

    if array.size(arr_beh) > 0 and showon and _tfok and _tf_ok_V
        if _val_ses == _val_ses[1] and _bear0[1] and not _bear0
            line.delete(smtbeh)
            array.remove(arr_beh, 0)
            if not ssmt_hidelabels and array.size(arr_lbh) > 0
                label.delete(smtbe)
                array.remove(arr_lbh, 0)

    if array.size(arr_beh) > 0 and showon
        for i = array.size(arr_beh) - 1 to 0
            dline = array.get(arr_beh, i)
            top = line.get_y2(dline)
            tme = line.get_x2(dline)
            if time > tme and high >= top
                line.delete(dline)
                array.remove(arr_beh, i)
                if not ssmt_hidelabels and array.size(arr_lbh) > 0
                    dlbl = array.get(arr_lbh, i)
                    label.delete(dlbl)
                    array.remove(arr_lbh, i)

    if array.size(arr_bul) > 0 and showon and _tfok and _tf_ok_V
        if _val_ses == _val_ses[1] and _bull0[1] and not _bull0
            line.delete(smtbul)
            array.remove(arr_bul, 0)
            if not ssmt_hidelabels and array.size(arr_lbl) > 0
                label.delete(smtbu)
                array.remove(arr_lbl, 0)

    if array.size(arr_bul) > 0 and showon and _tfok and _tf_ok_V
        for i = array.size(arr_bul) - 1 to 0
            dline = array.get(arr_bul, i)
            bot = line.get_y2(dline)
            tme = line.get_x2(dline)
            if time > tme and low <= bot
                line.delete(dline)
                array.remove(arr_bul, i)
                if not ssmt_hidelabels and array.size(arr_lbl) > 0
                    dlbl = array.get(arr_lbl, i)
                    label.delete(dlbl)
                    array.remove(arr_lbl, i)

    [_bear1, _bear0, _bull1, _bull0, ret_smtbe, ret_smtbu]

// --- Hidden SSMT function ---
ssmt_f_hidden_ssmt(_clsmax, _clsmax1, _clsmin, _clsmin1, _clsmaxt, _clsmaxt1, _clsmint, _clsmint1, _cclsmax, _cclsmax1, _cclsmin, _cclsmin1, _tfok, showon, _smt_clr, _smt_txt_clr, tri, xx, _val_ses, ah1, ah0, al1, al0, bh1, bh0, bl1, bl0, zh0, zl0, _tf_ok_V, lbl, name, pair, _inv) =>
    bool _hbear0 = false
    bool _lbull0 = false
    if not _inv
        _hbear0 := ((_clsmax >= _clsmax1 and _cclsmax <= _cclsmax1) or (_clsmax <= _clsmax1 and _cclsmax >= _cclsmax1)) and not (_clsmax == _clsmax1 and _cclsmax == _cclsmax1)
        _lbull0 := ((_clsmin >= _clsmin1 and _cclsmin <= _clsmin1) or (_clsmin <= _clsmin1 and _cclsmin >= _clsmin1)) and not (_clsmin == _clsmin1 and _cclsmin == _cclsmin1)
    else
        _hbear0 := ((_clsmax >= _clsmax1 and _cclsmin >= _cclsmin1) or (_clsmax <= _clsmax1 and _cclsmin <= _cclsmin1)) and not (_clsmax == _clsmax1 and _cclsmin == _cclsmin1)
        _lbull0 := ((_clsmin >= _clsmin1 and _cclsmax >= _cclsmax1) or (_clsmin <= _clsmin1 and _cclsmax <= _cclsmax1)) and not (_clsmin == _clsmin1 and _cclsmax == _cclsmax1)

    tooltiplbl = pair == 2 ? name + " hd " + ssmt_ssmt_pair : name + " hd " + ssmt_ssmt_pair2
    lblstyleh = label.style_label_down
    lblstylel = label.style_label_up
    var hsmtbeh = line.new(na, na, na, na)
    var hsmtbul = line.new(na, na, na, na)
    var hsmtbe = label.new(na, na)
    var hsmtbu = label.new(na, na)
    label ret_hsmtbe = na
    label ret_hsmtbu = na
    var harr_beh = array.new_line()
    var harr_lbh = array.new_label()
    var harr_bul = array.new_line()
    var harr_lbl = array.new_label()

    if showon and _tfok and _tf_ok_V
        if (_val_ses[1] != _val_ses or not _hbear0[1] or _clsmaxt != _clsmaxt[1]) and _hbear0
            hsmtbeh := line.new(x1=_clsmaxt1, y1=_clsmax1, x2=_clsmaxt, y2=_clsmax, xloc=xloc.bar_time, color=ssmt_hidelines ? color.new(_smt_clr, 100) : _smt_clr, width=1, style=ssmt_hiddstyle)
            ssmt_add_to_line_array(harr_beh, hsmtbeh)
            if not ssmt_hidelabels
                hsmtbe := label.new(x=math.round((_clsmaxt + _clsmaxt1) / 2), y=(_clsmax1 + _clsmax) / 2, text=lbl, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), style=lblstyleh, textcolor=_smt_txt_clr, size=ssmt_i_font, tooltip=tooltiplbl, text_font_family=ssmt_target_font)
                ret_hsmtbe := hsmtbe
                ssmt_add_to_label_array(harr_lbh, hsmtbe)

        if (_val_ses[1] != _val_ses or not _lbull0[1] or _clsmint != _clsmint[1]) and _lbull0
            hsmtbul := line.new(x1=_clsmint1, y1=_clsmin1, x2=_clsmint, y2=_clsmin, xloc=xloc.bar_time, color=ssmt_hidelines ? color.new(_smt_clr, 100) : _smt_clr, width=1, style=ssmt_hiddstyle)
            ssmt_add_to_line_array(harr_bul, hsmtbul)
            if not ssmt_hidelabels
                hsmtbu := label.new(x=math.round((_clsmint + _clsmint1) / 2), y=(_clsmin1 + _clsmin) / 2, text=lbl, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.white, 100), style=lblstylel, textcolor=_smt_txt_clr, size=ssmt_i_font, tooltip=tooltiplbl, text_font_family=ssmt_target_font)
                ret_hsmtbu := hsmtbu
                ssmt_add_to_label_array(harr_lbl, hsmtbu)

    if array.size(harr_beh) > 0 and showon and _tfok and _tf_ok_V
        if _val_ses == _val_ses[1] and _hbear0[1] and not _hbear0
            line.delete(hsmtbeh)
            array.remove(harr_beh, 0)
            if not ssmt_hidelabels and array.size(harr_lbh) > 0
                label.delete(hsmtbe)
                array.remove(harr_lbh, 0)

    if array.size(harr_beh) > 0 and showon and _tfok and _tf_ok_V
        for i = array.size(harr_beh) - 1 to 0
            dline = array.get(harr_beh, i)
            top = line.get_y2(dline)
            tme = line.get_x2(dline)
            if time > tme and math.max(open, close) >= top
                line.delete(dline)
                array.remove(harr_beh, i)
                if not ssmt_hidelabels and array.size(harr_lbh) > 0
                    dlbl = array.get(harr_lbh, i)
                    label.delete(dlbl)
                    array.remove(harr_lbh, i)

    if array.size(harr_bul) > 0 and showon and _tfok and _tf_ok_V
        if _val_ses == _val_ses[1] and _lbull0[1] and not _lbull0
            line.delete(hsmtbul)
            array.remove(harr_bul, 0)
            if not ssmt_hidelabels and array.size(harr_lbl) > 0
                label.delete(hsmtbu)
                array.remove(harr_lbl, 0)

    if array.size(harr_bul) > 0 and showon and _tfok and _tf_ok_V
        for i = array.size(harr_bul) - 1 to 0
            dline = array.get(harr_bul, i)
            bot = line.get_y2(dline)
            tme = line.get_x2(dline)
            if time > tme and math.min(open, close) <= bot
                line.delete(dline)
                array.remove(harr_bul, i)
                if not ssmt_hidelabels and array.size(harr_lbl) > 0
                    dlbl = array.get(harr_lbl, i)
                    label.delete(dlbl)
                    array.remove(harr_lbl, i)

    [_hbear0, _lbull0, ret_hsmtbe, ret_hsmtbu]

// --- Arrays to store SSMT status ---
ssmt_M_SSMT = array.from(false, false, false, false, false, false, false, false, false, false)
ssmt_W_SSMT = array.from(false, false, false, false, false, false, false, false, false, false)
ssmt_D_SSMT = array.from(false, false, false, false, false, false, false, false, false, false)
ssmt_N_SSMT = array.from(false, false, false, false, false, false, false, false, false, false)
ssmt_m_SSMT = array.from(false, false, false, false, false, false, false, false, false, false)

ssmt_N_label = array.from("")
ssmt_D_label = array.from("")
ssmt_W_label = array.from("")
ssmt_M_label = array.from("")
ssmt_m_label = array.from("")

ssmt_N_ext   = array.from(0.0, 0.0, 0.0, 0.0)
ssmt_D_ext   = array.from(0.0, 0.0, 0.0, 0.0)
ssmt_W_ext   = array.from(0.0, 0.0, 0.0, 0.0)
ssmt_M_ext   = array.from(0.0, 0.0, 0.0, 0.0)
ssmt_m_ext   = array.from(0.0, 0.0, 0.0, 0.0)

ssmt_N_bias = array.from("", "", "")
ssmt_D_bias = array.from("", "", "")
ssmt_W_bias = array.from("", "", "")
ssmt_M_bias = array.from("", "", "")
ssmt_m_bias = array.from("", "", "")

// --- allrun function to run all cycles ---
ssmt_f_allrun(_tf_ok, _tf_ok_V, _val_ses, name, _arr_sesy, _arr_sesz, _show_smt, _smt_clr, _hsmt_clr, _smt_txt_clr, _show_hsmt, X_SSMT, X_label, X_ext, X_bias, arrst, shortname) =>
    [hmaxt, lmint, hmax2, lmin2, hmax1, lmin1, hmax, lmin, hmaxt1, lmint1, clsmax, clsmax1, clsmaxt1, clsmin, clsmin1, clsmint1, clsmaxt, clsmint, o0, txt0, mbias] = ssmt_f_main_process(_tf_ok, _tf_ok_V, _val_ses, open, close, high, low, time, false, name, _arr_sesy, _arr_sesz, arrst)
    [chmaxt, clmint, chmax2, clmin2, chmax1, clmin1, chmax, clmin, chmaxt1, clmint1, cclsmax, cclsmax1, cclsmaxt1, cclsmin, cclsmin1, cclsmint1, cclsmaxt, cclsmint, co0, ctxt0, xbias] = ssmt_f_main_process(_tf_ok, _tf_ok_V, _val_ses, ssmt_xo0, ssmt_xc0, ssmt_xh0, ssmt_xl0, ssmt_xt0, false, "", _arr_sesy, _arr_sesz, arrst)
    _ssmt_label = ""
    nm1 = ssmt_ssmt_pair
    nm2 = ssmt_ssmt_pair2
    label l_be1 = na
    label l_bu1 = na
    label l_hbe1 = na
    label l_hbu1 = na

    if ssmt_alerttype != "Hidden" and showSSMT
        [bear1, bear0, bull1, bull0, l_be1_t, l_bu1_t] = ssmt_f_ssmt(hmax2, hmax1, hmax, lmin2, lmin1, lmin, chmax2, chmax1, chmax, clmin2, clmin1, clmin, array.get(ssmt_arrstart, arrst), false, hmaxt, lmint, hmaxt1, lmint1, _tf_ok, _val_ses, _show_smt, _smt_clr, _smt_txt_clr, false, 2, ssmt_xh0, ssmt_xl0, _tf_ok_V, shortname + " " + nm1, name, 2, array.get(ssmt_arr_inv, 0))
        l_be1 := l_be1_t
        l_bu1 := l_bu1_t
        array.set(X_SSMT, 0, bear1)
        array.set(X_SSMT, 1, bear0)
        array.set(X_SSMT, 2, bull1)
        array.set(X_SSMT, 3, bull0)

    if ssmt_alerttype != "Normal" and showSSMT
        [hidbear2, hidbull2, l_hbe1_t, l_hbu1_t] = ssmt_f_hidden_ssmt(clsmax, clsmax1, clsmin, clsmin1, clsmaxt, clsmaxt1, clsmint, clsmint1, cclsmax, cclsmax1, cclsmin, cclsmin1, _tf_ok, _show_hsmt, _hsmt_clr, _smt_txt_clr, false, 2, _val_ses, hmax1, hmax, lmin1, lmin, chmax1, chmax, clmin1, clmin, ssmt_xh0, ssmt_xl0, _tf_ok_V, shortname + " (hd) " + nm1, name, 2, array.get(ssmt_arr_inv, 0))
        l_hbe1 := l_hbe1_t
        l_hbu1 := l_hbu1_t
        array.set(X_SSMT, 4, hidbear2)
        array.set(X_SSMT, 5, hidbull2)

    if ssmt_triad_ok and ssmt_showsmt2 and showSSMT
        [dhmaxt, dlmint, dhmax2, dlmin2, dhmax1, dlmin1, dhmax, dlmin, dhmaxt1, dlmint1, dclsmax, dclsmax1, dclsmaxt1, dclsmin, dclsmin1, dclsmint1, dclsmaxt, dclsmint, do0, dtxt0, ybias] = ssmt_f_main_process(_tf_ok, _tf_ok_V, _val_ses, ssmt_yo0, ssmt_yc0, ssmt_yh0, ssmt_yl0, ssmt_yt0, false, "", _arr_sesy, _arr_sesz, 1)
        label l_be2 = na
        label l_bu2 = na
        label l_hbe2 = na
        label l_hbu2 = na

        if ssmt_alerttype != "Hidden" and showSSMT
            [bear13, bear03, bull13, bull03, l_be2_t, l_bu2_t] = ssmt_f_ssmt(hmax2, hmax1, hmax, lmin2, lmin1, lmin, dhmax2, dhmax1, dhmax, dlmin2, dlmin1, dlmin, array.get(ssmt_arrstart, arrst), false, hmaxt, lmint, hmaxt1, lmint1, _tf_ok, _val_ses, _show_smt, _smt_clr, _smt_txt_clr, true, 2, ssmt_yh0, ssmt_yl0, _tf_ok_V, shortname + " " + nm2, name, 3, array.get(ssmt_arr_inv, 1))
            l_be2 := l_be2_t
            l_bu2 := l_bu2_t
            if bear03
                array.set(X_SSMT, 6, bear03)
            if bull03
                array.set(X_SSMT, 7, bull03)

        if ssmt_alerttype != "Normal" and showSSMT
            [hidbear3, hidbull3, l_hbe2_t, l_hbu2_t] = ssmt_f_hidden_ssmt(clsmax, clsmax1, clsmin, clsmin1, clsmaxt, clsmaxt1, clsmint, clsmint1, dclsmax, dclsmax1, dclsmin, dclsmin1, _tf_ok, _show_hsmt, _hsmt_clr, _smt_txt_clr, true, 2, _val_ses, hmax1, hmax, lmin1, lmin, dhmax1, dhmax, dlmin1, dlmin, ssmt_yh0, ssmt_yl0, _tf_ok_V, shortname + " (hd) " + nm2, name, 3, array.get(ssmt_arr_inv, 1))
            l_hbe2 := l_hbe2_t
            l_hbu2 := l_hbu2_t
            if hidbear3
                array.set(X_SSMT, 8, true)
            if hidbull3
                array.set(X_SSMT, 9, true)

        if not na(l_be1) and not na(l_be2)
            label.set_text(l_be1, shortname + " " + nm1 + " + " + nm2)
            label.delete(l_be2)
        if not na(l_bu1) and not na(l_bu2)
            label.set_text(l_bu1, shortname + " " + nm1 + " + " + nm2)
            label.delete(l_bu2)
        if not na(l_hbe1) and not na(l_hbe2)
            label.set_text(l_hbe1, shortname + " (hd) " + nm1 + " + " + nm2)
            label.delete(l_hbe2)
        if not na(l_hbu1) and not na(l_hbu2)
            label.set_text(l_hbu1, shortname + " (hd) " + nm1 + " + " + nm2)
            label.delete(l_hbu2)

        array.set(X_bias, 2, ybias)

    // Combine pair1 and pair2 signals
    _bear_pair1 = array.get(X_SSMT, 1) or array.get(X_SSMT, 4)
    _bull_pair1 = array.get(X_SSMT, 3) or array.get(X_SSMT, 5)
    _bear_pair2 = array.get(X_SSMT, 6) or array.get(X_SSMT, 8)
    _bull_pair2 = array.get(X_SSMT, 7) or array.get(X_SSMT, 9)
    _combined_label = _ssmt_label
    if _tf_ok
        if (_bear_pair1 and _bear_pair2)
            _combined_label := name + " Combined Bearish SSMT (" + ssmt_ssmt_pair + " + " + ssmt_ssmt_pair2 + ")" + '\n'
        if (_bull_pair1 and _bull_pair2)
            _combined_label := name + " Combined Bullish SSMT (" + ssmt_ssmt_pair + " + " + ssmt_ssmt_pair2 + ")" + '\n'
    array.set(X_label, 0, _combined_label)

    array.set(X_ext, 0, hmax)
    array.set(X_ext, 1, lmin)
    array.set(X_ext, 2, clsmax)
    array.set(X_ext, 3, clsmin)
    array.set(X_bias, 0, mbias)
    array.set(X_bias, 1, xbias)

// Execute for each cycle (only when showSSMT is active)
if showSSMT
    ssmt_f_allrun(ssmt_tf_ok    , ssmt_tf_ok_V    , ssmt_val_ses   , "90m"    , ssmt_arr_sesy , ssmt_arr_sesz , ssmt_show_smtN , ssmt_smtN_clr , ssmt_hsmtN_clr , ssmt_smt_txt_all , ssmt_show_hsmtN , ssmt_N_SSMT , ssmt_N_label , ssmt_N_ext , ssmt_N_bias , 1 , "90m")
    ssmt_f_allrun(ssmt_tf_ok_mic, ssmt_tf_ok_mic_V, ssmt_val_sesm  , "Micro"  , ssmt_arr_sesmy, ssmt_arr_sesmz, ssmt_show_smtm , ssmt_smtm_clr , ssmt_hsmtm_clr , ssmt_smt_txt_all , ssmt_show_hsmtm , ssmt_m_SSMT , ssmt_m_label , ssmt_m_ext , ssmt_m_bias , 0 , "Mic.")
    ssmt_f_allrun(ssmt_tf_okD   , ssmt_tf_okD_V   , ssmt_val_sesD  , "Daily"  , ssmt_arr_sesDy, ssmt_arr_sesDz, ssmt_show_smtD , ssmt_smtD_clr , ssmt_hsmtD_clr , ssmt_smt_txt_all , ssmt_show_hsmtD , ssmt_D_SSMT , ssmt_D_label , ssmt_D_ext , ssmt_D_bias , 2 , "D")
    ssmt_f_allrun(ssmt_tf_okW   , ssmt_tf_okW_V   , ssmt_val_sesW  , "Weekly" , ssmt_arr_sesWy, ssmt_arr_sesWz, ssmt_show_smtW , ssmt_smtW_clr , ssmt_hsmtW_clr , ssmt_smt_txt_all , ssmt_show_hsmtW , ssmt_W_SSMT , ssmt_W_label , ssmt_W_ext , ssmt_W_bias , 3 , "W")
    ssmt_f_allrun(ssmt_tf_okMo  , ssmt_tf_okMo_V  , ssmt_val_sesMo , "Monthly", ssmt_arr_sesMoy, ssmt_arr_sesMoz, ssmt_show_smtMo, ssmt_smtMo_clr, ssmt_hsmtMo_clr, ssmt_smt_txt_all , ssmt_show_hsmtMo, ssmt_M_SSMT , ssmt_M_label , ssmt_M_ext , ssmt_M_bias , 4 , "M")

// ==================== END OF SSMT PART ====================
````

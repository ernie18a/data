# ICT Killzones & Key Levels -DST- By Spartan

- url: https://www.tradingview.com/script/f5Qf4MIO-ICT-Killzones-Key-Levels-DST-By-Spartan/
- type: indicator
- pine_id: PUB;f977cb3b0ac542128724c910bbb3f9b3
- version: 1.0

## Description

ICT Killzones & Key Levels -DST- By Spartan

This tool brings together the reference levels that ICT-style session traders build their bias around, so you are not stacking four or five separate indicators on one chart to get them. Killzone session ranges, their pivot highs and lows, Fibonacci retracements of each session's range, and the higher-timeframe opens, highs, lows, and time markers that traders use to judge context all come from the same underlying session and time data. Keeping them in one script means they stay in sync with each other and with the timeframe/timezone settings you choose, instead of drifting apart the way separately-configured indicators can.

This indicator's strongest feature is the automatic daylight saving time adjustment for each session as it uses real time zones of each session and adjusts automatically rather than having to change them each time the clock is changed anywhere

WHAT IT DOES

Killzone sessions
Draws boxes around the Asia, London, and New York killzone sessions. Each session's time range is entered in that session's own local time (UTC for Asia, Europe/London for London, America/New York for New York) and automatically adjusts for daylight saving, so you never have to manually shift the input twice a year.

Pivots
Marks each session's high and low as extending lines, with optional labels showing price. Pivots can extend until price mitigates them or continue past mitigation, and can alert you when a session high or low is broken.

Fibonacci levels (new in this version)
Each session can independently plot 0, 0.25, 0.5, 0.75, and 1 retracement levels of its own range. These update live while the session is still forming and lock in place once the session closes, so you can watch how a session's midpoint and quartiles evolve in real time rather than only seeing them after the fact. Colors automatically match each session's own color so the chart stays readable.

Midpoints
Optional midpoint line for each session's pivot range, with the choice to stop tracking once price mitigates it or keep tracking through the session.

Killzone range table
An optional table showing each session's most recent range and its rolling average over a configurable number of past sessions, so you can gauge whether the current session is expanding or contracting relative to its recent history.

Day / Week / Month tools
Optional open lines, high/low lines, and separators for the daily, weekly, and monthly timeframes, each with independent alerting on high/low breaks.

Custom opening prices and timestamps
Up to eight custom time-of-day open markers (for marking things like true day open or other reference times you track) and four vertical timestamp lines, both independently configurable.

Day-of-week labels
Optional labels marking the start of each weekday on intraday charts, with the option to hide weekend labels.

HOW TO USE IT

Turn on the sessions you trade, set the killzone range and pivot options to match how you use highs/lows and mitigation, and enable Fibonacci levels on whichever sessions you want retracement context for. The killzone range table is useful for a quick read on whether the current session is unusually wide or narrow. The Day/Week/Month and custom time tools are there if you also reference higher-timeframe opens or specific times of day, but are fully optional and off by default so the chart stays clean if you only want killzones.

CREDIT AND ORIGINALITY

The killzone box, pivot, and DST-safe session-detection logic in this script is built on tradeforopp's open-source "ICT Killzones & Pivots" indicator. This version adds session-independent live-updating Fibonacci retracement levels (not present in the original), a reorganized and more clearly labeled settings panel, and several fixes to line/label handling in the underlying session logic. Published open-source in keeping with the license of the code it builds on.

This is a level-marking and context tool, not a signal generator or a strategy. It does not predict future price movement or guarantee any outcome; it plots historical and forming session data so you can build your own read of the market around it.

## Source Code

````pine
//@version=6
indicator("ICT Killzones & Key Levels -DST- By Spartan", "ICT KZ & KL - Spartan", true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

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
max_days            = input.int(3, "Session Drawing Limit", 1, tooltip = "Only this many drawings will be kept on the chart, for each selected drawing type (killzone boxes, pivot lines, fib levels, open lines, etc.)", group = g_SETTINGS, display = display.none)
tf_limit            = input.timeframe("30", "Timeframe Limit", tooltip = "Drawings will not appear on timeframes greater than or equal to this", group = g_SETTINGS, display = display.none)
gmt_tz              = input.string('America/New_York', "Timezone (Opening Prices / Timestamps / DWM only)", options = ['America/New_York','GMT-12','GMT-11','GMT-10','GMT-9','GMT-8','GMT-7','GMT-6','GMT-5','GMT-4','GMT-3','GMT-2','GMT-1','GMT+0','GMT+1','GMT+2','GMT+3','GMT+4','GMT+5','GMT+6','GMT+7','GMT+8','GMT+9','GMT+10','GMT+11','GMT+12','GMT+13','GMT+14'], tooltip = "Changes the time zone that the Opening Price lines, Timestamp lines, and Day/Week/Month sections are calculated in. Does NOT affect the Asia, London, or New York killzone sessions below — those always use their own fixed time zone (UTC, Europe/London, America/New_York) so their DST handling stays correct no matter what you pick here.", group = g_SETTINGS, display = display.none)
lbl_size            = get_size(input.string('Normal', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], tooltip = "The size of all labels", group = g_SETTINGS, display = display.none))
txt_color           = input.color(color.black, "Text Color", tooltip = "The color of all label and table text", group = g_SETTINGS, display = display.none)
use_cutoff          = input.bool(false, "Drawing Cutoff Time", inline = "CO", tooltip = "When enabled, all pivots and open price lines will stop extending at this time", group = g_SETTINGS, display = display.none)
cutoff              = input.session("1800-1801", "", inline = "CO", group = g_SETTINGS, display = display.none)
show_watermark      = input.bool(true, "Show Watermark", inline = "WM", tooltip = "Toggle the watermark display in the bottom-right corner", group = g_SETTINGS, display = display.none)
watermark_text       = input.string("Spartan", "", inline = "WM", group = g_SETTINGS, display = display.none)

var tf_limit_is_equal_or_more_chart_tf = timeframe.in_seconds('') <= timeframe.in_seconds(tf_limit)

var g_KZ            = "Killzone Display"
show_kz             = input.bool(true, "Show Killzone Boxes", inline = "KZ", group = g_KZ, display = display.none)
show_kz_text        = input.bool(false, "Display Text On Box", inline = "KZ", group = g_KZ, display = display.none)
box_transparency    = input.int(85, "Box Transparency", 0, 100, group = g_KZ, display = display.none)
text_transparency   = input.int(68, "Box Text Transparency", 0, 100, group = g_KZ, display = display.none)

var g_ASIA          = "Asia Session"
use_asia            = input.bool(true, "Enable", inline = "AS1", group = g_ASIA, display = display.none)
as_txt              = input.string("Asia", "Name", inline = "AS1", group = g_ASIA, display = display.none)
asia                = input.session("0000-0700", "Session (UTC time, auto DST)", inline = "AS2", tooltip = "Enter the session as HHMM-HHMM in UTC. This always adjusts correctly for daylight saving — you don't need to change it manually throughout the year.", group = g_ASIA, display = display.none)
as_color            = input.color(color.rgb(74, 74, 74), "Color", inline = "AS2", group = g_ASIA, display = display.none)
ash_str             = input.string("AS.H", "Pivot Labels (High / Low)", inline = "AS3", group = g_ASIA, display = display.none)
asl_str             = input.string("AS.L", "", inline = "AS3", group = g_ASIA, display = display.none)
use_fib_asia        = input.bool(true, "Show Fibonacci Levels", inline = "AS4", tooltip = "Draws 0, 0.25, 0.5, 0.75 and 1 Fibonacci retracement levels on this session's high and low. Levels update live while the session is forming and freeze once it closes. Color automatically matches the session color above.", group = g_ASIA, display = display.none)

var g_LONDON        = "London Session"
use_london          = input.bool(true, "Enable", inline = "LO1", group = g_LONDON, display = display.none)
lo_txt              = input.string("London", "Name", inline = "LO1", group = g_LONDON, display = display.none)
london              = input.session("0700-1430", "Session (London local time, auto DST)", inline = "LO2", tooltip = "Enter the session as HHMM-HHMM in Europe/London local time. This always adjusts correctly for daylight saving — you don't need to change it manually throughout the year.", group = g_LONDON, display = display.none)
lo_color            = input.color(color.rgb(103, 58, 183), "Color", inline = "LO2", group = g_LONDON, display = display.none)
loh_str             = input.string("LO.H", "Pivot Labels (High / Low)", inline = "LO3", group = g_LONDON, display = display.none)
lol_str             = input.string("LO.L", "", inline = "LO3", group = g_LONDON, display = display.none)
use_fib_london      = input.bool(true, "Show Fibonacci Levels", inline = "LO4", tooltip = "Draws 0, 0.25, 0.5, 0.75 and 1 Fibonacci retracement levels on this session's high and low. Levels update live while the session is forming and freeze once it closes. Color automatically matches the session color above.", group = g_LONDON, display = display.none)

var g_NEWYORK       = "New York Session"
use_nyam            = input.bool(true, "Enable", inline = "NY1", group = g_NEWYORK, display = display.none)
na_txt              = input.string("New York", "Name", inline = "NY1", group = g_NEWYORK, display = display.none)
nyam                = input.session("0930-1730", "Session (New York local time, auto DST)", inline = "NY2", tooltip = "Enter the session as HHMM-HHMM in America/New_York local time. This always adjusts correctly for daylight saving — you don't need to change it manually throughout the year.", group = g_NEWYORK, display = display.none)
na_color            = input.color(color.rgb(41, 98, 255), "Color", inline = "NY2", group = g_NEWYORK, display = display.none)
nah_str             = input.string("NY.H", "Pivot Labels (High / Low)", inline = "NY3", group = g_NEWYORK, display = display.none)
nal_str             = input.string("NY.L", "", inline = "NY3", group = g_NEWYORK, display = display.none)
use_fib_nyam        = input.bool(true, "Show Fibonacci Levels", inline = "NY4", tooltip = "Draws 0, 0.25, 0.5, 0.75 and 1 Fibonacci retracement levels on this session's high and low. Levels update live while the session is forming and freeze once it closes. Color automatically matches the session color above.", group = g_NEWYORK, display = display.none)


var g_LABELS        = "Killzone Pivots"
show_pivots         = input.bool(true, "Show Pivots", inline = "PV", group = g_LABELS, display = display.none)
use_alerts          = input.bool(true, "Alert Broken Pivots", inline = "PV", tooltip = "The desired killzones must be enabled at the time that an alert is created, along with the show pivots option, in order for alerts to work", group = g_LABELS, display = display.none)
show_midpoints      = input.bool(false, "Show Pivot Midpoints", inline = "mp", group = g_LABELS, display = display.none)
stop_midpoints      = input.bool(true, "Stop Once Mitigated", inline = "mp", group = g_LABELS, display = display.none)
show_labels         = input.bool(true, "Show Pivot Labels", inline = "LB", tooltip = "Show labels denoting each killzone's high and low. Optionally choose to show the price of each level. Right side will show labels on the right-hand side of the chart until they are reached", group = g_LABELS, display = display.none)
label_price         = input.bool(false, "Display Price", inline = "LB", group = g_LABELS, display = display.none)
label_right         = input.bool(false, "Right Side", inline = "LB", group = g_LABELS, display = display.none)
ext_pivots          = input.string("Until Mitigated", "Extend Pivots...", options = ['Until Mitigated', 'Past Mitigation'], group = g_LABELS, display = display.none)
ext_which           = input.string("Most Recent", "...From Which Sessions", options = ['Most Recent', 'All'], group = g_LABELS, display = display.none)

kzp_style           = get_line_type(input.string(defval = 'Solid', title = "Pivot Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZP", group = g_LABELS, display = display.none))
kzp_width           = input.int(1, "", inline = "KZP", group = g_LABELS, display = display.none)
kzm_style           = get_line_type(input.string(defval = 'Dotted', title = "Midpoint Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "KZM", group = g_LABELS, display = display.none))
kzm_width           = input.int(1, "", inline = "KZM", group = g_LABELS, display = display.none)


var g_FIB           = "Fibonacci Levels"
show_fib_labels     = input.bool(false, "Show Level Labels", tooltip = "Show the 0, 0.25, 0.5, 0.75 and 1 text labels on fib lines. Turning this off hides the text but keeps the lines. Enable/disable fib levels per session in each session's own group above.", group = g_FIB, display = display.none)
fib_style           = get_line_type(input.string(defval = 'Dashed', title = "Line Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "FIB", group = g_FIB, display = display.none))
fib_width           = input.int(1, "", inline = "FIB", group = g_FIB, display = display.none)


var g_RNG           = "Killzone Range"
show_range          = input.bool(false, "Show Killzone Range", tooltip = "Show the most recent ranges of each selected killzone, from high to low", group = g_RNG, display = display.none)
show_range_avg      = input.bool(true, "Show Average", tooltip = "Show the average range of each selected killzone", group = g_RNG, display = display.none)
range_avg           = input.int(5, "Average Length", 0, tooltip = "This many previous sessions will be used to calculate the average. If there isn't enough data on the current chart, it will use as many sessions as possible", group = g_RNG, display = display.none)
range_pos           = get_table_pos(input.string('Top Right', "Table Position", options = ['Bottom Center', 'Bottom Left', 'Bottom Right', 'Middle Center', 'Middle Left', 'Middle Right', 'Top Center', 'Top Left', 'Top Right'], group = g_RNG, display = display.none))
range_size          = get_size(input.string('Normal', "Table Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_RNG, display = display.none))


var g_DWM_GEN       = "Day / Week / Month - General"
sep_unlimited       = input.bool(false, "Unlimited Drawings", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_DWM_GEN, display = display.none)
alert_HL            = input.bool(false, "Alert High/Low Break", tooltip = "Alert when any selected highs and lows are traded through. The desired timeframe's high/low option must be enabled at the time that an alert is created", group = g_DWM_GEN, display = display.none)
htf_style           = get_line_type(input.string(defval = 'Solid', title = "Line Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "D0", tooltip = "Applies to all Day/Week/Month separators and open lines", group = g_DWM_GEN, display = display.none))
htf_width           = input.int(1, "", inline = "D0", group = g_DWM_GEN, display = display.none)
dow_labels          = input.bool(true, "Day of Week Labels", inline = "DOW", group = g_DWM_GEN, display = display.none)
dow_yloc            = input.string('Bottom', "", options = ['Top', 'Bottom'], inline = "DOW", group = g_DWM_GEN, display = display.none)
dow_xloc            = input.string('Midnight', "", options = ['Midnight', 'Midday'], inline = "DOW", group = g_DWM_GEN, display = display.none)
dow_hide_wknd       = input.bool(true, "Hide Weekend Labels", group = g_DWM_GEN, display = display.none)

var g_DAY           = "Day"
show_d_open         = input.bool(false, "Open", inline = "D1", group = g_DAY, display = display.none)
dhl                 = input.bool(false, "High/Low", inline = "D1", group = g_DAY, display = display.none)
ds                  = input.bool(false, "Separator", inline = "D1", tooltip = "Mark where a new day begins", group = g_DAY, display = display.none)
d_color             = input.color(color.blue, "", inline = "D1", group = g_DAY, display = display.none)

var g_WEEK          = "Week"
show_w_open         = input.bool(false, "Open", inline = "W1", group = g_WEEK, display = display.none)
whl                 = input.bool(false, "High/Low", inline = "W1", group = g_WEEK, display = display.none)
ws                  = input.bool(false, "Separator", inline = "W1", tooltip = "Mark where a new week begins", group = g_WEEK, display = display.none)
w_color             = input.color(#089981, "", inline = "W1", group = g_WEEK, display = display.none)

var g_MONTH         = "Month"
show_m_open         = input.bool(false, "Open", inline = "M1", group = g_MONTH, display = display.none)
mhl                 = input.bool(false, "High/Low", inline = "M1", group = g_MONTH, display = display.none)
ms                  = input.bool(false, "Separator", inline = "M1", tooltip = "Mark where a new month begins", group = g_MONTH, display = display.none)
m_color             = input.color(color.red, "", inline = "M1", group = g_MONTH, display = display.none)


var g_OPEN          = "Opening Prices"
open_unlimited      = input.bool(false, "Unlimited Drawings", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_OPEN, display = display.none)
hz_style            = get_line_type(input.string(defval = 'Dotted', title = "Line Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "H0", tooltip = "Applies to all opening price lines below", group = g_OPEN, display = display.none))
hz_width            = input.int(1, "", inline = "H0", group = g_OPEN, display = display.none)

use_h1              = input.bool(false, "Enable", inline = "H1", group = g_OPEN, display = display.none)
h1_text             = input.string("True Day Open", "Label", inline = "H1", group = g_OPEN, display = display.none)
h1                  = input.session("0000-0001", "Time", inline = "H1", group = g_OPEN, display = display.none)
h1_color            = input.color(color.black, "", inline = "H1", group = g_OPEN, display = display.none)

use_h2              = input.bool(false, "Enable", inline = "H2", group = g_OPEN, display = display.none)
h2_text             = input.string("06:00", "Label", inline = "H2", group = g_OPEN, display = display.none)
h2                  = input.session("0600-0601", "Time", inline = "H2", group = g_OPEN, display = display.none)
h2_color            = input.color(color.black, "", inline = "H2", group = g_OPEN, display = display.none)

use_h3              = input.bool(false, "Enable", inline = "H3", group = g_OPEN, display = display.none)
h3_text             = input.string("10:00", "Label", inline = "H3", group = g_OPEN, display = display.none)
h3                  = input.session("1000-1001", "Time", inline = "H3", group = g_OPEN, display = display.none)
h3_color            = input.color(color.black, "", inline = "H3", group = g_OPEN, display = display.none)

use_h4              = input.bool(false, "Enable", inline = "H4", group = g_OPEN, display = display.none)
h4_text             = input.string("14:00", "Label", inline = "H4", group = g_OPEN, display = display.none)
h4                  = input.session("1400-1401", "Time", inline = "H4", group = g_OPEN, display = display.none)
h4_color            = input.color(color.black, "", inline = "H4", group = g_OPEN, display = display.none)

use_h5              = input.bool(false, "Enable", inline = "H5", group = g_OPEN, display = display.none)
h5_text             = input.string("00:00", "Label", inline = "H5", group = g_OPEN, display = display.none)
h5                  = input.session("0000-0001", "Time", inline = "H5", group = g_OPEN, display = display.none)
h5_color            = input.color(color.black, "", inline = "H5", group = g_OPEN, display = display.none)

use_h6              = input.bool(false, "Enable", inline = "H6", group = g_OPEN, display = display.none)
h6_text             = input.string("00:00", "Label", inline = "H6", group = g_OPEN, display = display.none)
h6                  = input.session("0000-0001", "Time", inline = "H6", group = g_OPEN, display = display.none)
h6_color            = input.color(color.black, "", inline = "H6", group = g_OPEN, display = display.none)

use_h7              = input.bool(false, "Enable", inline = "H7", group = g_OPEN, display = display.none)
h7_text             = input.string("00:00", "Label", inline = "H7", group = g_OPEN, display = display.none)
h7                  = input.session("0000-0001", "Time", inline = "H7", group = g_OPEN, display = display.none)
h7_color            = input.color(color.black, "", inline = "H7", group = g_OPEN, display = display.none)

use_h8              = input.bool(false, "Enable", inline = "H8", group = g_OPEN, display = display.none)
h8_text             = input.string("00:00", "Label", inline = "H8", group = g_OPEN, display = display.none)
h8                  = input.session("0000-0001", "Time", inline = "H8", group = g_OPEN, display = display.none)
h8_color            = input.color(color.black, "", inline = "H8", group = g_OPEN, display = display.none)


var g_VERTICAL      = "Timestamps"
v_unlimited         = input.bool(false, "Unlimited Drawings", tooltip = "Unlimited will show as many of the selected lines as possible. Otherwise, the session drawing limit will be used", group = g_VERTICAL, display = display.none)
vl_style            = get_line_type(input.string(defval = 'Dotted', title = "Line Style", options = ['Solid', 'Dotted', 'Dashed'], inline = "V0", tooltip = "Applies to all timestamp lines below", group = g_VERTICAL, display = display.none))
vl_width            = input.int(1, "", inline = "V0", group = g_VERTICAL, display = display.none)

use_v1              = input.bool(false, "Enable", inline = "V1", group = g_VERTICAL, display = display.none)
v1                  = input.session("0000-0001", "Time", inline = "V1", group = g_VERTICAL, display = display.none)
v1_color            = input.color(color.black, "", inline = "V1", group = g_VERTICAL, display = display.none)

use_v2              = input.bool(false, "Enable", inline = "V2", group = g_VERTICAL, display = display.none)
v2                  = input.session("0800-0801", "Time", inline = "V2", group = g_VERTICAL, display = display.none)
v2_color            = input.color(color.black, "", inline = "V2", group = g_VERTICAL, display = display.none)

use_v3              = input.bool(false, "Enable", inline = "V3", group = g_VERTICAL, display = display.none)
v3                  = input.session("1000-1001", "Time", inline = "V3", group = g_VERTICAL, display = display.none)
v3_color            = input.color(color.black, "", inline = "V3", group = g_VERTICAL, display = display.none)

use_v4              = input.bool(false, "Enable", inline = "V4", group = g_VERTICAL, display = display.none)
v4                  = input.session("1200-1201", "Time", inline = "V4", group = g_VERTICAL, display = display.none)
v4_color            = input.color(color.black, "", inline = "V4", group = g_VERTICAL, display = display.none)
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

	// Fibonacci levels: one array per level (0, 0.25, 0.5, 0.75, 1). Index 0 in each
	// array always refers to the current/most recent session, matching the pattern
	// already used by _hi_line / _lo_line above.
	array<line> _fib_l0
	array<line> _fib_l1
	array<line> _fib_l2
	array<line> _fib_l3
	array<line> _fib_l4

	array<label> _fib_lb0
	array<label> _fib_lb1
	array<label> _fib_lb2
	array<label> _fib_lb3
	array<label> _fib_lb4

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
    string tz
    color c
    string box_txt
    string hi_txt
    string lo_txt
    bool use_fib

new_kz_state(string title) =>
    kz.new(
     _title = title,
     _box = array.new_box(), _hi_line = array.new_line(), _md_line = array.new_line(), _lo_line = array.new_line(),
     _hi_label = array.new_label(), _lo_label = array.new_label(),
     _hi_valid = array.new_bool(), _md_valid = array.new_bool(), _lo_valid = array.new_bool(),
     _range_store = array.new_float(),
     _fib_l0 = array.new_line(), _fib_l1 = array.new_line(), _fib_l2 = array.new_line(), _fib_l3 = array.new_line(), _fib_l4 = array.new_line(),
     _fib_lb0 = array.new_label(), _fib_lb1 = array.new_label(), _fib_lb2 = array.new_label(), _fib_lb3 = array.new_label(), _fib_lb4 = array.new_label())

initKZ() =>
    array<kz_helper> res = array.new<kz_helper>()
    if use_asia
        res.push(kz_helper.new(_kz = new_kz_state(as_txt), session = asia, tz = "UTC", c = as_color, box_txt = as_txt, hi_txt = ash_str, lo_txt = asl_str, use_fib = use_fib_asia))
    if use_london
        res.push(kz_helper.new(_kz = new_kz_state(lo_txt), session = london, tz = "Europe/London", c = lo_color, box_txt = lo_txt, hi_txt = loh_str, lo_txt = lol_str, use_fib = use_fib_london))
    if use_nyam
        res.push(kz_helper.new(_kz = new_kz_state(na_txt), session = nyam, tz = "America/New_York", c = na_color, box_txt = na_txt, hi_txt = nah_str, lo_txt = nal_str, use_fib = use_fib_nyam))
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

// Fibonacci ratio/label constants, shared by all three sessions.
var float[] FIB_LEVELS = array.from(0.0, 0.25, 0.5, 0.75, 1.0)
var string[] FIB_LABELS = array.from("0", "0.25", "0.5", "0.75", "1")

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


// ---------------------------------------- Fibonacci Functions --------------------------------------------------
fib_create_session(kz kz, color c, int t_open, float h, float l) =>
    float r0 = l + FIB_LEVELS.get(0) * (h - l)
    float r1 = l + FIB_LEVELS.get(1) * (h - l)
    float r2 = l + FIB_LEVELS.get(2) * (h - l)
    float r3 = l + FIB_LEVELS.get(3) * (h - l)
    float r4 = l + FIB_LEVELS.get(4) * (h - l)

    kz._fib_l0.unshift(line.new(t_open, r0, t_open, r0, xloc = xloc.bar_time, style = fib_style, width = fib_width, color = c))
    kz._fib_l1.unshift(line.new(t_open, r1, t_open, r1, xloc = xloc.bar_time, style = fib_style, width = fib_width, color = c))
    kz._fib_l2.unshift(line.new(t_open, r2, t_open, r2, xloc = xloc.bar_time, style = fib_style, width = fib_width, color = c))
    kz._fib_l3.unshift(line.new(t_open, r3, t_open, r3, xloc = xloc.bar_time, style = fib_style, width = fib_width, color = c))
    kz._fib_l4.unshift(line.new(t_open, r4, t_open, r4, xloc = xloc.bar_time, style = fib_style, width = fib_width, color = c))

    kz._fib_lb0.unshift(label.new(t_open, r0, show_fib_labels ? FIB_LABELS.get(0) : "", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = c, size = lbl_size))
    kz._fib_lb1.unshift(label.new(t_open, r1, show_fib_labels ? FIB_LABELS.get(1) : "", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = c, size = lbl_size))
    kz._fib_lb2.unshift(label.new(t_open, r2, show_fib_labels ? FIB_LABELS.get(2) : "", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = c, size = lbl_size))
    kz._fib_lb3.unshift(label.new(t_open, r3, show_fib_labels ? FIB_LABELS.get(3) : "", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = c, size = lbl_size))
    kz._fib_lb4.unshift(label.new(t_open, r4, show_fib_labels ? FIB_LABELS.get(4) : "", xloc = xloc.bar_time, style = label.style_label_left, color = transparent, textcolor = c, size = lbl_size))

fib_update_current(kz kz, float h, float l, int t_right) =>
    if kz._fib_l0.size() > 0
        float r0 = l + FIB_LEVELS.get(0) * (h - l)
        float r1 = l + FIB_LEVELS.get(1) * (h - l)
        float r2 = l + FIB_LEVELS.get(2) * (h - l)
        float r3 = l + FIB_LEVELS.get(3) * (h - l)
        float r4 = l + FIB_LEVELS.get(4) * (h - l)

        kz._fib_l0.get(0).set_y1(r0)
        kz._fib_l0.get(0).set_y2(r0)
        kz._fib_l0.get(0).set_x2(t_right)
        kz._fib_l1.get(0).set_y1(r1)
        kz._fib_l1.get(0).set_y2(r1)
        kz._fib_l1.get(0).set_x2(t_right)
        kz._fib_l2.get(0).set_y1(r2)
        kz._fib_l2.get(0).set_y2(r2)
        kz._fib_l2.get(0).set_x2(t_right)
        kz._fib_l3.get(0).set_y1(r3)
        kz._fib_l3.get(0).set_y2(r3)
        kz._fib_l3.get(0).set_x2(t_right)
        kz._fib_l4.get(0).set_y1(r4)
        kz._fib_l4.get(0).set_y2(r4)
        kz._fib_l4.get(0).set_x2(t_right)

        kz._fib_lb0.get(0).set_xy(t_right, r0)
        kz._fib_lb1.get(0).set_xy(t_right, r1)
        kz._fib_lb2.get(0).set_xy(t_right, r2)
        kz._fib_lb3.get(0).set_xy(t_right, r3)
        kz._fib_lb4.get(0).set_xy(t_right, r4)

fib_lock_current(kz kz, int t_end) =>
    if kz._fib_l0.size() > 0
        kz._fib_l0.get(0).set_x2(t_end)
        kz._fib_l1.get(0).set_x2(t_end)
        kz._fib_l2.get(0).set_x2(t_end)
        kz._fib_l3.get(0).set_x2(t_end)
        kz._fib_l4.get(0).set_x2(t_end)

        kz._fib_lb0.get(0).set_x(t_end)
        kz._fib_lb1.get(0).set_x(t_end)
        kz._fib_lb2.get(0).set_x(t_end)
        kz._fib_lb3.get(0).set_x(t_end)
        kz._fib_lb4.get(0).set_x(t_end)

fib_delete_oldest(kz kz) =>
    if kz._fib_l0.size() > max_days
        kz._fib_l0.pop().delete()
        kz._fib_l1.pop().delete()
        kz._fib_l2.pop().delete()
        kz._fib_l3.pop().delete()
        kz._fib_l4.pop().delete()

        kz._fib_lb0.pop().delete()
        kz._fib_lb1.pop().delete()
        kz._fib_lb2.pop().delete()
        kz._fib_lb3.pop().delete()
        kz._fib_lb4.pop().delete()
// ---------------------------------------- Fibonacci Functions --------------------------------------------------


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


del_kz(kz k, bool use_fib) =>
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
    if use_fib
        fib_delete_oldest(k)

update_price_string(label L, float P) =>
    S = L.get_text()
    pre = str.substring(S, 0, str.pos(S, " "))
    str.trim(pre)
    L.set_text(str.format("{0} ({1})", pre, P))

adjust_in_kz(kz kz, bool t, bool use_fib) =>
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

        if use_fib
            fib_update_current(kz, newTop, newBottom, time)


adjust_out_kz(kz kz, bool t, bool t_prev, bool use_fib) =>
    boxCount = kz._box.size()
    if not t and boxCount > 0
        if t_prev
            array.unshift(kz._range_store, kz._range_current)
            if kz._range_store.size() > range_avg
                kz._range_store.pop()
            if use_fib
                fib_lock_current(kz, time)

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
    bool use_fib = this.use_fib
    string box_txt = this.box_txt
    string hi_txt = this.hi_txt
    string lo_txt = this.lo_txt

    if tf_limit_is_equal_or_more_chart_tf
        t = not na(time("", this.session, this.tz))
        t_prev = not na(time("", this.session, this.tz, bars_back = 1))
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

            if use_fib
                fib_create_session(kz, c, time, high, low)

            del_kz(kz, use_fib)
        adjust_in_kz(kz, t, use_fib)
        adjust_out_kz(kz, t, t_prev, use_fib)

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
        set_table(tbl, value._kz, index + 1, value.box_txt, not na(time("", value.session, value.tz)), value.c)
// ---------------------------------------- Core Logic --------------------------------------------------


// ═══════════════════════════════════════════════════════════════════════════════
// ──  WATERMARK
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast and show_watermark and watermark_text != ""
    var wm = table.new(
         position.bottom_right, 1, 1,
         bgcolor      = color.new(color.black, 90),
         border_width = 0,
         frame_width  = 0)
    table.cell(
         wm, 0, 0,
         watermark_text,
         text_color = color.new(color.white, 40),
         text_size  = size.small,
         bgcolor    = color.new(color.black, 90))
````

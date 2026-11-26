# Nik's SMC Indicator

- url: https://www.tradingview.com/script/9LRrqj7Z-nik-s-smc-indicator/
- type: indicator
- pine_id: PUB;c2913a6764074da798a7134f451ff9c3
- version: 1.0

## Description

Here is a suggested description for your indicator: This indicator features six distinct sessions to help you track market movements throughout the day. It includes the Previous Day's High and Low, as well as the Previous Week's High and Low. Additionally, it highlights the Daily Open levels and features a bright middle point for better visual clarity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nikan0r

//@version=6
indicator("Nik's SMC Indicator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════
// ⚙️ GLOBAL SETTINGS
// ══════════════════════════════════════════════════════════════
utcOffset  = input.int(3, "UTC Offset", minval=-12, maxval=14, group="⚙️ Settings")
labelPos   = input.string("Top", "Session Label Position", options=["Top", "Bottom"], group="⚙️ Settings")
fontSize   = input.string("Small", "Font Size (All Labels)", options=["Tiny","Small","Normal","Large","Huge"], group="⚙️ Settings")

_fsize() =>
    switch fontSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

// ══════════════════════════════════════════════════════════════
// 📦 SESSIONS
// ══════════════════════════════════════════════════════════════
s1_en   = input.bool(true,          "Enable", group="📦 Session 1", inline="s1")
s1_name = input.string("London",    "Name",   group="📦 Session 1", inline="s1")
s1_col  = input.color(color.new(color.blue,   75), "Color", group="📦 Session 1", inline="s1")
s1_time = input.session("0800-1700","Time",   group="📦 Session 1")

s2_en   = input.bool(true,          "Enable", group="📦 Session 2", inline="s2")
s2_name = input.string("New York",  "Name",   group="📦 Session 2", inline="s2")
s2_col  = input.color(color.new(color.orange, 75), "Color", group="📦 Session 2", inline="s2")
s2_time = input.session("1300-2200","Time",   group="📦 Session 2")

s3_en   = input.bool(true,          "Enable", group="📦 Session 3", inline="s3")
s3_name = input.string("Asian",     "Name",   group="📦 Session 3", inline="s3")
s3_col  = input.color(color.new(color.purple, 75), "Color", group="📦 Session 3", inline="s3")
s3_time = input.session("0000-0900","Time",   group="📦 Session 3")

s4_en   = input.bool(false,         "Enable", group="📦 Session 4", inline="s4")
s4_name = input.string("Session 4", "Name",   group="📦 Session 4", inline="s4")
s4_col  = input.color(color.new(color.green,  75), "Color", group="📦 Session 4", inline="s4")
s4_time = input.session("1500-1600","Time",   group="📦 Session 4")

s5_en   = input.bool(false,         "Enable", group="📦 Session 5", inline="s5")
s5_name = input.string("Session 5", "Name",   group="📦 Session 5", inline="s5")
s5_col  = input.color(color.new(color.red,    75), "Color", group="📦 Session 5", inline="s5")
s5_time = input.session("1900-2000","Time",   group="📦 Session 5")

s6_en   = input.bool(false,         "Enable", group="📦 Session 6", inline="s6")
s6_name = input.string("Session 6", "Name",   group="📦 Session 6", inline="s6")
s6_col  = input.color(color.new(color.yellow, 75), "Color", group="📦 Session 6", inline="s6")
s6_time = input.session("2100-2200","Time",   group="📦 Session 6")

// ══════════════════════════════════════════════════════════════
// 📊 PDH / PDL
// ══════════════════════════════════════════════════════════════
pdhl_en = input.bool(true,  "Show PDH / PDL", group="📊 PDH / PDL")
pdh_col = input.color(color.new(color.teal,    0), "PDH Color", group="📊 PDH / PDL")
pdl_col = input.color(color.new(color.red,     0), "PDL Color", group="📊 PDH / PDL")

// ══════════════════════════════════════════════════════════════
// 📊 PWH / PWL
// ══════════════════════════════════════════════════════════════
pwhl_en = input.bool(true,  "Show PWH / PWL", group="📊 PWH / PWL")
pwh_col = input.color(color.new(color.aqua,    0), "PWH Color", group="📊 PWH / PWL")
pwl_col = input.color(color.new(color.fuchsia, 0), "PWL Color", group="📊 PWH / PWL")

// ══════════════════════════════════════════════════════════════
// 📍 DAILY OPEN
// ══════════════════════════════════════════════════════════════
do_en  = input.bool(true,  "Show Daily Open (DO)", group="📍 Daily Open")
do_col = input.color(color.new(color.white, 0),    "DO Color",  group="📍 Daily Open")

// ══════════════════════════════════════════════════════════════
// 🌙 NY MIDNIGHT
// ══════════════════════════════════════════════════════════════
ny_en   = input.bool(true,   "Show NY Midnight", group="🌙 NY Midnight")
ny_col  = input.color(color.new(color.yellow, 0), "NY Color", group="🌙 NY Midnight")
ny_time = input.string("00:00", "NY Midnight Time (HH:MM in selected UTC)", group="🌙 NY Midnight")

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════
_tz(off) =>
    switch off
        -12 => "Etc/GMT+12"
        -11 => "Etc/GMT+11"
        -10 => "Etc/GMT+10"
        -9  => "Etc/GMT+9"
        -8  => "Etc/GMT+8"
        -7  => "Etc/GMT+7"
        -6  => "Etc/GMT+6"
        -5  => "Etc/GMT+5"
        -4  => "Etc/GMT+4"
        -3  => "Etc/GMT+3"
        -2  => "Etc/GMT+2"
        -1  => "Etc/GMT+1"
        0   => "UTC"
        1   => "Etc/GMT-1"
        2   => "Etc/GMT-2"
        3   => "Etc/GMT-3"
        4   => "Etc/GMT-4"
        5   => "Etc/GMT-5"
        6   => "Etc/GMT-6"
        7   => "Etc/GMT-7"
        8   => "Etc/GMT-8"
        9   => "Etc/GMT-9"
        10  => "Etc/GMT-10"
        11  => "Etc/GMT-11"
        =>    "Etc/GMT-12"

tz = _tz(utcOffset)

// Bars per day estimate for line length
barsPerDay() =>
    switch timeframe.period
        "1"   => 1440
        "3"   => 480
        "5"   => 288
        "15"  => 96
        "30"  => 48
        "60"  => 24
        "120" => 12
        "240" => 6
        "D"   => 1
        =>       96

barsPerWeek() => barsPerDay() * 5

// ══════════════════════════════════════════════════════════════
// SESSION BOX LOGIC — dynamic high/low tracking
// ══════════════════════════════════════════════════════════════
_sessionActive(sess_str) =>
    not na(time(timeframe.period, sess_str, tz))

_lblStyle() =>
    labelPos == "Top" ? label.style_label_lower_left : label.style_label_upper_left

_processSession(bool enabled, string sess_str, color col, string sname) =>
    var bool  active   = false
    var int   bLeft    = 0
    var float bHigh    = na
    var float bLow     = na
    var box   b        = na
    var label lbl      = na

    if enabled
        inSess = _sessionActive(sess_str)

        if inSess and not active
            // Session start
            active := true
            bLeft  := bar_index
            bHigh  := high
            bLow   := low
            b      := box.new(bar_index, high, bar_index + 1, low,
                         border_color=col, border_width=1, bgcolor=col)
            lbl    := label.new(bar_index, labelPos == "Top" ? high : low, sname,
                         color=color.new(color.black, 100),
                         textcolor=col,
                         style=_lblStyle(),
                         size=_fsize())

        if inSess and active
            if high > bHigh
                bHigh := high
            if low < bLow
                bLow := low
            box.set_top(b, bHigh)
            box.set_bottom(b, bLow)
            box.set_right(b, bar_index + 1)
            label.set_x(lbl, bLeft)
            label.set_y(lbl, labelPos == "Top" ? bHigh : bLow)

        if not inSess and active
            active := false

_processSession(s1_en, s1_time, s1_col, s1_name)
_processSession(s2_en, s2_time, s2_col, s2_name)
_processSession(s3_en, s3_time, s3_col, s3_name)
_processSession(s4_en, s4_time, s4_col, s4_name)
_processSession(s5_en, s5_time, s5_col, s5_name)
_processSession(s6_en, s6_time, s6_col, s6_name)

// ══════════════════════════════════════════════════════════════
// PDH / PDL — от начала текущего дня до конца текущего дня
// ══════════════════════════════════════════════════════════════
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

var line pdh_line = na
var line pdl_line = na
var label pdh_lbl = na
var label pdl_lbl = na
var int   pdh_x1  = 0
var bool  pdh_crossed = false
var bool  pdl_crossed = false

isNewDay = ta.change(time("D")) != 0

if pdhl_en
    if isNewDay or barstate.isfirst
        if not na(pdh_line)
            line.delete(pdh_line)
            line.delete(pdl_line)
            label.delete(pdh_lbl)
            label.delete(pdl_lbl)

        pdh_crossed := false
        pdl_crossed := false
        pdh_x1      := bar_index

        // Line spans current day: x1 = now, x2 = now + barsPerDay()
        int x2 = bar_index + barsPerDay()

        pdh_line := line.new(bar_index, prevDayHigh, x2, prevDayHigh,
                     color=pdh_col, width=1, style=line.style_solid)
        pdl_line := line.new(bar_index, prevDayLow,  x2, prevDayLow,
                     color=pdl_col, width=1, style=line.style_solid)
        pdh_lbl  := label.new(bar_index, prevDayHigh, "PDH",
                     color=color.new(color.black,100), textcolor=pdh_col,
                     style=label.style_label_right, size=_fsize())
        pdl_lbl  := label.new(bar_index, prevDayLow,  "PDL",
                     color=color.new(color.black,100), textcolor=pdl_col,
                     style=label.style_label_right, size=_fsize())

    if not na(pdh_line)
        if high > prevDayHigh and not pdh_crossed
            pdh_crossed := true
            line.set_style(pdh_line, line.style_dashed)
        if low < prevDayLow and not pdl_crossed
            pdl_crossed := true
            line.set_style(pdl_line, line.style_dashed)

// ══════════════════════════════════════════════════════════════
// PWH / PWL — от начала текущей недели до конца текущей недели
// ══════════════════════════════════════════════════════════════
prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
prevWeekLow  = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

var line  pwh_line = na
var line  pwl_line = na
var label pwh_lbl  = na
var label pwl_lbl  = na
var bool  pwh_crossed = false
var bool  pwl_crossed = false

isNewWeek = ta.change(time("W")) != 0

if pwhl_en
    if isNewWeek or barstate.isfirst
        if not na(pwh_line)
            line.delete(pwh_line)
            line.delete(pwl_line)
            label.delete(pwh_lbl)
            label.delete(pwl_lbl)

        pwh_crossed := false
        pwl_crossed := false

        int x2w = bar_index + barsPerWeek()

        pwh_line := line.new(bar_index, prevWeekHigh, x2w, prevWeekHigh,
                     color=pwh_col, width=1, style=line.style_solid)
        pwl_line := line.new(bar_index, prevWeekLow,  x2w, prevWeekLow,
                     color=pwl_col, width=1, style=line.style_solid)
        pwh_lbl  := label.new(bar_index, prevWeekHigh, "PWH",
                     color=color.new(color.black,100), textcolor=pwh_col,
                     style=label.style_label_right, size=_fsize())
        pwl_lbl  := label.new(bar_index, prevWeekLow,  "PWL",
                     color=color.new(color.black,100), textcolor=pwl_col,
                     style=label.style_label_right, size=_fsize())

    if not na(pwh_line)
        if high > prevWeekHigh and not pwh_crossed
            pwh_crossed := true
            line.set_style(pwh_line, line.style_dashed)
        if low < prevWeekLow and not pwl_crossed
            pwl_crossed := true
            line.set_style(pwl_line, line.style_dashed)

// ══════════════════════════════════════════════════════════════
// DAILY OPEN (DO) — только текущий день, линия до конца дня
// ══════════════════════════════════════════════════════════════
dailyOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)

var line  do_line = na
var label do_lbl  = na

if do_en
    if isNewDay or barstate.isfirst
        if not na(do_line)
            line.delete(do_line)
            label.delete(do_lbl)

        int x2do = bar_index + barsPerDay()
        do_line := line.new(bar_index, dailyOpen, x2do, dailyOpen,
                     color=do_col, width=1, style=line.style_solid)
        do_lbl  := label.new(bar_index, dailyOpen, "DO",
                     color=color.new(color.black,100), textcolor=do_col,
                     style=label.style_label_right, size=_fsize())

// ══════════════════════════════════════════════════════════════
// NY MIDNIGHT — только текущий день, линия до конца дня
// ══════════════════════════════════════════════════════════════
_parseHour(s) => int(str.tonumber(str.substring(s, 0, 2)))
_parseMin(s)  => int(str.tonumber(str.substring(s, 3, 5)))

nyHour = _parseHour(ny_time)
nyMin  = _parseMin(ny_time)

var line  ny_line  = na
var label ny_lbl   = na
var bool  ny_drawn = false

if ny_en
    if isNewDay or barstate.isfirst
        // Удаляем предыдущий день
        if not na(ny_line)
            line.delete(ny_line)
            label.delete(ny_lbl)
        ny_line  := na
        ny_lbl   := na
        ny_drawn := false

    barH = hour(time, tz)
    barM = minute(time, tz)

    if not ny_drawn and barH == nyHour and barM == nyMin
        ny_drawn := true
        int x2ny = bar_index + barsPerDay()
        ny_line  := line.new(bar_index, close, x2ny, close,
                      color=ny_col, width=1, style=line.style_solid)
        ny_lbl   := label.new(bar_index, close, "NY MM",
                      color=color.new(color.black,100), textcolor=ny_col,
                      style=label.style_label_right, size=_fsize())
````

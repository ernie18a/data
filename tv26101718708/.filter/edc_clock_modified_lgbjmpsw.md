# EDC Clock Modified

- url: https://www.tradingview.com/script/LGBJMPSw-EDC-Clock-Modified/
- type: indicator
- pine_id: PUB;87ac66edca9545218290511006406902
- version: 7.0

## Description

Clock ⌖ – Custom Timezone Clock
A clean and highly customizable clock indicator that displays the current time directly on your chart in your local timezone.
Features:

User-selectable timezone – No more New York time! Choose from 15+ major timezones worldwide (including all US zones)
Real-time updating clock (updates every second)
Optional date display (MM-dd-yyyy)
Optional milliseconds display
Fully customizable:
Position (Top/Middle/Bottom + Left/Center/Right)
Text size (Tiny to Huge)
Text color
Background color


Perfect for:

Traders in different timezones
Session timing (London, NY, Asia)
Keeping track of market close/open times in your local time
Recording trade timestamps accurately

How to use:
Simply add the indicator to your chart and select your timezone in the settings. Everything else is fully adjustable.
Created by © MattSmiggs – Modified for flexible user timezones.

## Source Code

````pine
//@version=6
// Based on "Clock ⌖" by © MattSmiggs, rebuilt in the EDC layout with world sessions
indicator("EDC's Clock & Sessions", overlay=true)

// ─── Table ────────────────────────────────────────────────────────────────────
// Master switch first so "labels only" is one click.
show_table    = input.bool(true, title="Show Table", tooltip="Off hides the whole table. Chart levels stay on if Chart Levels is on.", group="Table")
show_clock    = input.bool(true, title="Show Clock Row", tooltip="Time row at the top of the table. Needs Show Table on.", group="Table")
show_sessions = input.bool(true, title="Show Session Rows", tooltip="World sessions list in the table. Needs Show Table on.", group="Table")
show_cd       = input.bool(true, title="Show Countdown", tooltip="Time left until the session's next change: open, close, lunch, or the end of extended hours.", group="Table")
days_cd       = input.bool(true, title="Show Days in Long Countdowns", tooltip="Countdowns of a day or more read as 1d 17h instead of 41h 00m.", group="Table")
show_hl       = input.bool(true, title="Show High / Low Columns", tooltip="High and low of the chart's ticker during each session's regular hours, held after the close until that session opens again. Needs an intraday chart.", group="Table")
pos_in        = input.string("Bottom Right", title="Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table")
size_in       = input.string("Small", title="Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Table")

// ─── Clock ────────────────────────────────────────────────────────────────────
// Pine cannot read the user's device or TradingView account timezone. Custom is how
// you show your local time: pick your city below.
tz_mode   = input.string("Custom", title="Clock Timezone", options=["Custom", "Chart Exchange"], tooltip="Custom: use the city you pick below (set this to your local time).\n\nChart Exchange: use the chart symbol's exchange timezone.", group="Clock")
user_tz   = input.string("America/New_York", title="Custom Timezone", options=["UTC", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Toronto", "America/Mexico_City", "Europe/London", "Europe/Paris", "Europe/Berlin", "Europe/Moscow", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney", "Pacific/Auckland"], tooltip="Used when Clock Timezone is Custom. Pick your city for local time.", group="Clock")
clock_tz  = tz_mode == "Chart Exchange" ? syminfo.timezone : user_tz
use_24h   = input.bool(false, title="24-Hour Time",      tooltip="Off shows 12-hour time with AM/PM.", group="Clock")
show_sec  = input.bool(true,  title="Show Seconds",      group="Clock")
show_ms   = input.bool(false, title="Show Milliseconds", tooltip="Only shown when seconds are on.", group="Clock")
show_date = input.bool(false, title="Show Date",         group="Clock")

// ─── Sessions ─────────────────────────────────────────────────────────────────
// Regular cash hours in each exchange's own timezone, so daylight saving is handled automatically.
// Exchange holidays are not accounted for. These toggles drive both the table rows and the chart levels.
show_prepost  = input.bool(true, title="New York Pre-Market & After-Hours", tooltip="Pre-Market 04:00–09:30 ET and After-Hours 16:00–20:00 ET show as their own status instead of Closed.", group="Sessions")
show_lunch    = input.bool(true, title="Lunch Breaks", tooltip="Tokyo 11:30–12:30, Hong Kong 12:00–13:00, and Shanghai 11:30–13:00 show as Lunch instead of Open.", group="Sessions")
soon_on       = input.bool(true, title="Highlight Changes Coming Soon", inline="soon", tooltip="Turns the session amber when its next change is within this many minutes.", group="Sessions")
soon_min      = input.int(15, title="", minval=1, inline="soon", group="Sessions")
s_globex = input.bool(true,  title="CME Globex (17:00–16:00 CT, Sun–Fri)", group="Sessions")
s_ny     = input.bool(true,  title="New York (09:30–16:00 ET)",            group="Sessions")
s_lon    = input.bool(true,  title="London (08:00–16:30)",                 group="Sessions")
s_fra    = input.bool(true,  title="Frankfurt (09:00–17:30)",              group="Sessions")
s_dxb    = input.bool(false, title="Dubai (10:00–15:00)",                  group="Sessions")
s_mum    = input.bool(false, title="Mumbai (09:15–15:30)",                 group="Sessions")
s_sgp    = input.bool(false, title="Singapore (09:00–17:00)",              group="Sessions")
s_hk     = input.bool(true,  title="Hong Kong (09:30–16:00)",              group="Sessions")
s_sha    = input.bool(false, title="Shanghai (09:30–15:00)",               group="Sessions")
s_tyo    = input.bool(true,  title="Tokyo (09:00–15:30)",                  group="Sessions")
s_syd    = input.bool(true,  title="Sydney (10:00–16:00)",                 group="Sessions")

// ─── Chart Levels ─────────────────────────────────────────────────────────────
show_chart  = input.bool(true, title="Show on Chart", tooltip="Draws open/high/low for every session turned on under Sessions. Needs an intraday chart.", group="Chart Levels")
show_sopen  = input.bool(true, title="Show Opens", tooltip="Also draws the price each session opened at.", group="Chart Levels")
merge_ticks = input.int(8, title="Combine Within (ticks)", minval=0, tooltip="Levels this close together share one label so they don't overlap. Raise it if labels still crowd when zoomed out.", group="Chart Levels")
lbl_off     = input.int(25, title="Label Offset (bars)", minval=0, tooltip="How far right of the last bar the labels sit.", group="Chart Levels")
lbl_size_in = input.string("Small", title="Label Size", options=["Tiny", "Small", "Normal"], group="Chart Levels")

// ─── Colors ───────────────────────────────────────────────────────────────────
col_time   = input.color(color.white,            title="Clock Text",     group="Colors")
col_sub    = input.color(color.new(#B2B5BE, 0),  title="Secondary Text", group="Colors")
col_open   = input.color(#86E6A2,                title="Open",           group="Colors")
col_closed = input.color(#F77C80,                title="Closed",         group="Colors")
col_ext    = input.color(#7EC8E3,                title="Pre-Market / After-Hours", group="Colors")
col_lunch  = input.color(#B39DDB,                title="Lunch",          group="Colors")
col_soon   = input.color(#FFB74D,                title="Change Coming Soon", group="Colors")
col_high   = input.color(#86E6A2,                title="Session High",   group="Colors")
col_low    = input.color(#F77C80,                title="Session Low",    group="Colors")
col_sopen  = input.color(#21c9f3,                title="Session Open",   group="Colors")
col_head   = input.color(color.new(#2A2E39, 0),  title="Header",         group="Colors")
col_bg     = input.color(color.new(#131722, 10), title="Background",     group="Colors")
col_line   = input.color(color.new(#434651, 0),  title="Border",         group="Colors")

// ─── Settings → Values ────────────────────────────────────────────────────────
clk_pos = switch pos_in
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

clk_size = switch size_in
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small

f_tz_tag(tz) =>
    string tag = switch tz
        "America/New_York"    => "ET"
        "America/Chicago"     => "CT"
        "America/Denver"      => "MT"
        "America/Los_Angeles" => "PT"
        "America/Toronto"     => "ET"
        "America/Mexico_City" => "CT"
        "Europe/London"       => "UK"
        "Europe/Paris"        => "CET"
        "Europe/Berlin"       => "CET"
        "Europe/Moscow"       => "MSK"
        "Asia/Tokyo"          => "JST"
        "Asia/Hong_Kong"      => "HKT"
        "Asia/Singapore"      => "SGT"
        "Asia/Dubai"          => "GST"
        "Asia/Kolkata"        => "IST"
        "Australia/Sydney"    => "AET"
        "Pacific/Auckland"    => "NZT"
        "UTC"                 => "UTC"
        => ""
    if tag == ""
        parts = str.split(tz, "/")
        tag := array.size(parts) > 0 ? array.get(parts, array.size(parts) - 1) : tz
    tag

// Main clock format, built from the toggles
f_fmt() =>
    string base = use_24h ? "HH:mm" : "hh:mm"
    if show_sec
        base += ":ss"
        if show_ms
            base += ".SSS"
    use_24h ? base : base + " a"

SESS_FMT = use_24h ? "HH:mm" : "hh:mm a"

// ─── Session Math ─────────────────────────────────────────────────────────────
// Minutes since midnight in a given timezone
f_min(t, tz) => hour(t, tz) * 60 + minute(t, tz)
f_now(tz) => f_min(timenow, tz)

f_dur(m) =>
    string out = ""
    if days_cd and m >= 1440
        out := str.tostring(int(math.floor(m / 1440))) + "d " + str.tostring(int(math.floor((m % 1440) / 60))) + "h"
    else
        h = int(math.floor(m / 60))
        mm = m % 60
        out := (h > 0 ? str.tostring(h) + "h " : "") + str.tostring(mm, "00") + "m"
    out

// Weekday cash session. Lunch (ls–le) and pre/after-hours (pre, post) are skipped when passed -1.
// Returns [status, countdown prefix, minutes until the next change]
f_cash(tz, o, c, ls, le, pre, post) =>
    now = f_now(tz)
    dow = dayofweek(timenow, tz)
    wk  = dow >= dayofweek.monday and dow <= dayofweek.friday
    has_lunch = show_lunch and ls >= 0
    has_pre   = show_prepost and pre >= 0
    has_post  = show_prepost and post >= 0
    first     = has_pre ? pre : o
    string st  = "Closed"
    string pfx = "opens"
    int mins   = 0
    if wk and has_pre and now >= pre and now < o
        st   := "Pre-Market"
        pfx  := "opens"
        mins := o - now
    else if wk and now >= o and now < c
        if has_lunch and now >= ls and now < le
            st   := "Lunch"
            pfx  := "reopens"
            mins := le - now
        else if has_lunch and now < ls
            st   := "Open"
            pfx  := "lunch in"
            mins := ls - now
        else
            st   := "Open"
            pfx  := "closes"
            mins := c - now
    else if wk and has_post and now >= c and now < post
        st   := "After-Hours"
        pfx  := "ends"
        mins := post - now
    else
        int days = 0
        if not (wk and now < first)
            days := dow == dayofweek.friday ? 3 : dow == dayofweek.saturday ? 2 : 1
        pfx  := has_pre ? "pre in" : "opens"
        mins := days * 1440 + first - now
    [st, pfx, mins]

// CME Globex: Sun 17:00 to Fri 16:00 CT, with a daily 16:00–17:00 break
f_gx_open(dow, m) =>
    mon_thu = dow >= dayofweek.monday and dow <= dayofweek.thursday
    (dow == dayofweek.sunday and m >= 1020) or (mon_thu and (m < 960 or m >= 1020)) or (dow == dayofweek.friday and m < 960)

f_globex() =>
    tz  = "America/Chicago"
    now = f_now(tz)
    dow = dayofweek(timenow, tz)
    is_open = f_gx_open(dow, now)
    int mins = 0
    if is_open
        mins := now >= 1020 ? 1440 - now + 960 : 960 - now
    else
        mins := dow == dayofweek.friday ? 2 * 1440 + 1020 - now : dow == dayofweek.saturday ? 1440 + 1020 - now : 1020 - now
    [is_open ? "Open" : "Closed", is_open ? "closes" : "opens", mins]

// ─── Session High / Low ───────────────────────────────────────────────────────
// Tracked on 1-minute bars of the chart's ticker (or the chart's own bars on 1-minute
// and lower charts), so opens, highs, and lows land on the exact session times on any
// intraday timeframe. Where 1-minute history runs out, the chart's own bars are used.
f_day(t, tz) => year(t, tz) * 10000 + month(t, tz) * 100 + dayofmonth(t, tz)

INTRA_TF = timeframe.isintraday and timeframe.in_seconds() > 60 ? "1" : timeframe.period
[i_t, i_o, i_h, i_l] = request.security_lower_tf(syminfo.tickerid, INTRA_TF, [time, open, high, low], ignore_invalid_timeframe = true)
use_intra = not na(i_t) and i_t.size() > 0
bars_t = use_intra ? i_t : array.from(time)
bars_o = use_intra ? i_o : array.from(open)
bars_h = use_intra ? i_h : array.from(high)
bars_l = use_intra ? i_l : array.from(low)

type SessRange
    float hi
    float lo
    float op
    int   sb    // Bar the session started on, where its chart lines begin
    int   dt    // Time whose date, in the session's timezone, is the session's trading day
    bool  live  // Session is trading on the current bar

// Fed one bar at a time (t, o, h, l). Resets on the first bar of a new session
// (key changes) and holds after the close.
f_hl(in_s, key, shift, t, o, h, l) =>
    var float hi = na
    var float lo = na
    var float op = na
    var int k  = na
    var int sb = na
    var int dt = na
    if in_s
        if na(k) or key != k
            hi := h
            lo := l
            op := o
            k  := key
            sb := bar_index
            dt := t + shift
        else
            hi := math.max(hi, h)
            lo := math.min(lo, l)
    SessRange.new(hi, lo, op, sb, dt, in_s)

// Lunch breaks fall inside open–close and are included in the range
f_cash_hl(tz, s_open, s_close, t, o, h, l) =>
    m   = f_min(t, tz)
    dow = dayofweek(t, tz)
    f_hl(dow >= dayofweek.monday and dow <= dayofweek.friday and m >= s_open and m < s_close, f_day(t, tz), 0, t, o, h, l)

// Globex trading day runs 17:00–16:00 CT, so shifting 7 hours puts it on one calendar date
f_globex_hl(t, o, h, l) =>
    tz    = "America/Chicago"
    shift = 7 * 3600000
    f_hl(f_gx_open(dayofweek(t, tz), f_min(t, tz)), f_day(t + shift, tz), shift, t, o, h, l)

SessRange gx  = na
SessRange ny  = na
SessRange lon = na
SessRange fra = na
SessRange dxb = na
SessRange mum = na
SessRange sgp = na
SessRange hk  = na
SessRange sha = na
SessRange tyo = na
SessRange syd = na
for i = 0 to bars_t.size() - 1
    t = bars_t.get(i)
    o = bars_o.get(i)
    h = bars_h.get(i)
    l = bars_l.get(i)
    gx  := f_globex_hl(t, o, h, l)
    ny  := f_cash_hl("America/New_York", 570, 960,  t, o, h, l)
    lon := f_cash_hl("Europe/London",    480, 990,  t, o, h, l)
    fra := f_cash_hl("Europe/Berlin",    540, 1050, t, o, h, l)
    dxb := f_cash_hl("Asia/Dubai",       600, 900,  t, o, h, l)
    mum := f_cash_hl("Asia/Kolkata",     555, 930,  t, o, h, l)
    sgp := f_cash_hl("Asia/Singapore",   540, 1020, t, o, h, l)
    hk  := f_cash_hl("Asia/Hong_Kong",   570, 960,  t, o, h, l)
    sha := f_cash_hl("Asia/Shanghai",    570, 900,  t, o, h, l)
    tyo := f_cash_hl("Asia/Tokyo",       540, 930,  t, o, h, l)
    syd := f_cash_hl("Australia/Sydney", 600, 960,  t, o, h, l)

f_px(v) => na(v) or not timeframe.isintraday ? "—" : str.tostring(v, format.mintick)

// ─── Table ────────────────────────────────────────────────────────────────────
// Created once and only redrawn on the last bar, so it never rebuilds on history.
TBL_ROWS = 16
TBL_COLS = 6
HI_COL   = show_cd ? 4 : 3
LAST_COL = show_hl ? HI_COL + 1 : 3
var table clk_tbl = table.new(clk_pos, TBL_COLS, TBL_ROWS, border_color=col_line, border_width=1, frame_color=col_line, frame_width=1)

f_cell(c, r, txt, tcol, bg, sz, align) =>
    table.cell(clk_tbl, c, r, txt, text_color=tcol, bgcolor=bg, text_size=sz, text_halign=align)

f_state_col(st) =>
    switch st
        "Open"        => col_open
        "Lunch"       => col_lunch
        "Pre-Market"  => col_ext
        "After-Hours" => col_ext
        => col_closed

f_sess_row(r, name, tz, st, pfx, mins, hi, lo) =>
    soon   = soon_on and mins <= soon_min
    st_col = soon ? col_soon : f_state_col(st)
    f_cell(0, r, name, st_col, col_bg, clk_size, text.align_left)
    f_cell(1, r, str.format_time(timenow, SESS_FMT, tz), col_sub, col_bg, clk_size, text.align_right)
    f_cell(2, r, st, st_col, col_bg, clk_size, text.align_center)
    if show_cd
        f_cell(3, r, pfx + " " + f_dur(mins), soon ? col_soon : col_sub, col_bg, clk_size, text.align_right)
    if show_hl
        f_cell(HI_COL,     r, f_px(hi), col_high, col_bg, clk_size, text.align_right)
        f_cell(HI_COL + 1, r, f_px(lo), col_low,  col_bg, clk_size, text.align_right)
    r + 1

f_cash_row(r, show_it, name, tz, o, c, ls, le, pre, post, hi, lo) =>
    int out = r
    if show_it
        [st, pfx, mins] = f_cash(tz, o, c, ls, le, pre, post)
        out := f_sess_row(r, name, tz, st, pfx, mins, hi, lo)
    out

if barstate.islast
    table.clear(clk_tbl, 0, 0, TBL_COLS - 1, TBL_ROWS - 1)
    int r = 0
    if show_table
        if show_clock
            table.cell(clk_tbl, 0, r, str.format_time(timenow, f_fmt(), clock_tz) + "  " + f_tz_tag(clock_tz), text_color=col_time, bgcolor=col_bg, text_size=clk_size)
            table.merge_cells(clk_tbl, 0, r, LAST_COL, r)
            r += 1
            if show_date
                table.cell(clk_tbl, 0, r, str.format_time(timenow, "EEE MM-dd-yyyy", clock_tz), text_color=col_sub, bgcolor=col_bg, text_size=size.tiny)
                table.merge_cells(clk_tbl, 0, r, LAST_COL, r)
                r += 1
        if show_sessions
            if show_hl
                f_cell(0, r, "", color.white, col_head, clk_size, text.align_left)
                table.merge_cells(clk_tbl, 0, r, HI_COL - 1, r)
                f_cell(HI_COL, r, syminfo.ticker, color.white, col_head, clk_size, text.align_center)
                table.merge_cells(clk_tbl, HI_COL, r, HI_COL + 1, r)
                r += 1
            f_cell(0, r, "Session",    color.white, col_head, clk_size, text.align_left)
            f_cell(1, r, "Local Time", color.white, col_head, clk_size, text.align_center)
            f_cell(2, r, "Status",     color.white, col_head, clk_size, text.align_center)
            if show_cd
                f_cell(3, r, "Countdown", color.white, col_head, clk_size, text.align_center)
            if show_hl
                f_cell(HI_COL,     r, "High", color.white, col_head, clk_size, text.align_center)
                f_cell(HI_COL + 1, r, "Low",  color.white, col_head, clk_size, text.align_center)
            r += 1
            if s_globex
                [g_st, g_pfx, g_mins] = f_globex()
                r := f_sess_row(r, "CME Globex", "America/Chicago", g_st, g_pfx, g_mins, gx.hi, gx.lo)
            //                                                         open close lunch     pre/post   high    low
            r := f_cash_row(r, s_ny,  "New York",  "America/New_York", 570, 960,  -1,  -1,  240, 1200, ny.hi,  ny.lo)
            r := f_cash_row(r, s_lon, "London",    "Europe/London",    480, 990,  -1,  -1,  -1,  -1,   lon.hi, lon.lo)
            r := f_cash_row(r, s_fra, "Frankfurt", "Europe/Berlin",    540, 1050, -1,  -1,  -1,  -1,   fra.hi, fra.lo)
            r := f_cash_row(r, s_dxb, "Dubai",     "Asia/Dubai",       600, 900,  -1,  -1,  -1,  -1,   dxb.hi, dxb.lo)
            r := f_cash_row(r, s_mum, "Mumbai",    "Asia/Kolkata",     555, 930,  -1,  -1,  -1,  -1,   mum.hi, mum.lo)
            r := f_cash_row(r, s_sgp, "Singapore", "Asia/Singapore",   540, 1020, -1,  -1,  -1,  -1,   sgp.hi, sgp.lo)
            r := f_cash_row(r, s_hk,  "Hong Kong", "Asia/Hong_Kong",   570, 960,  720, 780, -1,  -1,   hk.hi,  hk.lo)
            r := f_cash_row(r, s_sha, "Shanghai",  "Asia/Shanghai",    570, 900,  690, 780, -1,  -1,   sha.hi, sha.lo)
            r := f_cash_row(r, s_tyo, "Tokyo",     "Asia/Tokyo",       540, 930,  690, 750, -1,  -1,   tyo.hi, tyo.lo)
            r := f_cash_row(r, s_syd, "Sydney",    "Australia/Sydney", 600, 960,  -1,  -1,  -1,  -1,   syd.hi, syd.lo)

// ─── Chart Levels ─────────────────────────────────────────────────────────────
// Levels are sorted by price and grouped from the lowest up. Anything within the
// combine distance of a group's first level joins that group and shares its label.
lbl_size = switch lbl_size_in
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var array<line>  ch_lines  = array.new<line>()
var array<label> ch_labels = array.new<label>()

// Level kinds. A label shared by different kinds uses the secondary text color.
LV_HIGH = 1
LV_LOW  = 2
LV_OPEN = 3

f_lv_col(t) => t == LV_HIGH ? col_high : t == LV_LOW ? col_low : t == LV_OPEN ? col_sopen : col_sub

f_push(prices, parts, types, starts, lives, p, txt, t, s) =>
    prices.push(p)
    parts.push(txt)
    types.push(t)
    starts.push(s.sb)
    lives.push(s.live)

// Closed sessions are tagged with their trading day in the exchange's timezone and drawn fainter
f_add(prices, parts, types, starts, lives, show_it, name, tz, s) =>
    if show_it and not na(s.hi)
        tag = s.live ? "" : " · " + str.format_time(s.dt, "EEE", tz)
        f_push(prices, parts, types, starts, lives, s.hi, name + " High" + tag, LV_HIGH, s)
        f_push(prices, parts, types, starts, lives, s.lo, name + " Low" + tag,  LV_LOW,  s)
        if show_sopen
            f_push(prices, parts, types, starts, lives, s.op, name + " Open" + tag, LV_OPEN, s)

f_range_txt(lo, hi) => hi > lo ? str.tostring(lo, format.mintick) + "–" + str.tostring(hi, format.mintick) : str.tostring(lo, format.mintick)

f_group_lbl(lo, hi, txt, typ, live) =>
    label.new(bar_index + lbl_off, (lo + hi) / 2, txt + "  " + f_range_txt(lo, hi), style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(f_lv_col(typ), live ? 0 : 45), size=lbl_size)

if barstate.islast
    while ch_lines.size() > 0
        ch_lines.pop().delete()
    while ch_labels.size() > 0
        ch_labels.pop().delete()
    if show_chart and timeframe.isintraday
        prices = array.new<float>()
        parts  = array.new<string>()
        types  = array.new<int>()
        starts = array.new<int>()
        lives  = array.new<bool>()
        f_add(prices, parts, types, starts, lives, s_globex, "Globex",    "America/Chicago",  gx)
        f_add(prices, parts, types, starts, lives, s_ny,     "NY",        "America/New_York", ny)
        f_add(prices, parts, types, starts, lives, s_lon,    "London",    "Europe/London",    lon)
        f_add(prices, parts, types, starts, lives, s_fra,    "Frankfurt", "Europe/Berlin",    fra)
        f_add(prices, parts, types, starts, lives, s_dxb,    "Dubai",     "Asia/Dubai",       dxb)
        f_add(prices, parts, types, starts, lives, s_mum,    "Mumbai",    "Asia/Kolkata",     mum)
        f_add(prices, parts, types, starts, lives, s_sgp,    "Singapore", "Asia/Singapore",   sgp)
        f_add(prices, parts, types, starts, lives, s_hk,     "HK",        "Asia/Hong_Kong",   hk)
        f_add(prices, parts, types, starts, lives, s_sha,    "Shanghai",  "Asia/Shanghai",    sha)
        f_add(prices, parts, types, starts, lives, s_tyo,    "Tokyo",     "Asia/Tokyo",       tyo)
        f_add(prices, parts, types, starts, lives, s_syd,    "Sydney",    "Australia/Sydney", syd)
        if prices.size() > 0
            gap = merge_ticks * syminfo.mintick
            float  g_lo   = na
            float  g_hi   = na
            string g_txt  = ""
            int    g_typ  = 0
            bool   g_live = false
            by_price = prices.sort_indices(order.ascending)
            for j in by_price
                p    = prices.get(j)
                t    = types.get(j)
                live = lives.get(j)
                ch_lines.push(line.new(starts.get(j), p, bar_index + lbl_off, p, color=color.new(f_lv_col(t), live ? 40 : 75), style=line.style_dotted, width=1))
                if na(g_lo) or p - g_lo > gap
                    if not na(g_lo)
                        ch_labels.push(f_group_lbl(g_lo, g_hi, g_txt, g_typ, g_live))
                    g_lo   := p
                    g_hi   := p
                    g_txt  := parts.get(j)
                    g_typ  := t
                    g_live := live
                else
                    g_hi   := p
                    g_txt  := g_txt + " · " + parts.get(j)
                    g_typ  := g_typ == t ? t : 0
                    g_live := g_live or live
            ch_labels.push(f_group_lbl(g_lo, g_hi, g_txt, g_typ, g_live))
````

# Session Killzones ICT Concept

- url: https://www.tradingview.com/script/b2jn5B1U-Session-Killzones-ICT-Concept/
- type: indicator
- pine_id: PUB;ed27915147d54cc7a9e6834d54b0304f
- version: 1.0

## Description

[b]Session Killzones - ICT Concept[/b]
Session Killzones plots the four standard ICT killzone sessions
(Asia, London, NY AM, NY PM) in New York time. It tracks unswept
session highs and lows in real time, fires alerts on sweeps, and
displays a compact session info panel with countdown.
 
Built for ICT traders who need to know which session levels are
still active and which have already been taken.
 
[b]SESSIONS[/b]
Draws session boxes and boundary lines for each killzone in New
York time with automatic DST handling (EDT/EST). Each session is
fully customizable: name, time range, and color.
 
[b]Default sessions (New York time):[/b]
[list]
[*]Asia: 20:00 - 00:00
[*]London: 02:00 - 05:00
[*]NY AM: 08:30 - 11:00
[*]NY PM: 13:30 - 16:00
[/list][i]Each session can be toggled on/off independently. Time ranges can
be modified to match your broker's session definition.[/i]
 
[b]UNSWEPT LEVELS[/b]
When a session closes, its high and low are extended forward as
dashed lines. These are unswept levels session liquidity that
price has not yet taken.
 
When price reaches an unswept level, the line is automatically
removed from the chart. No manual cleanup needed. This gives a
live, self-cleaning view of which session levels still matter.
 
Sweep events fire an alert. Alerts are available for high sweeps
and low sweeps independently.

[b]SESSION PANEL[/b]
A compact info panel shows session context at a glance. Three
detail levels:
[list][*]Simple - shows the active session name and time remaining (or next session and time until open).[/list][list][*]Standard - adds today's percentage range for each session that has occurred, with direction indicator relative to session open.
[/list][list][*]Advanced - includes unswept level prices from all closed sessions directly in the panel, alongside the session breakdown.
[/list][b]SESSION COUNTDOWN[/b]
Inside a session:     "NY AM - 1h 23m left"
Between sessions:     "London in 4h 10m"
 
[b]Color indicators[/b]:
[list]
[*]Green: session is active
[*]Yellow: less than 15 minutes remaining (closing warning)
[*]Gray: currently between sessions
[/list][i]The countdown adapts to custom session times. If you change the
London session to 01:00-04:00, the countdown reflects that.[/i]
 
[b]HOW TO USE[/b]
[list=1]
[*] Session boxes show the developing high and low of each killzone as the session progresses.
[*] Dashed lines extending beyond the box are unswept levels. These represent liquidity that price has not yet reached.
[*]When a dashed line disappears, that level has been swept. It is no longer an active reference.
[*]Use the percentage range in Standard mode to gauge which sessions were high-range versus low-range days.
[*]Use the countdown to plan your analysis around session opens and closes. Most high-probability ICT setups occur within the first 30 to 90 minutes of a killzone.
[*]Enable alerts on sweep events to get notified the moment a session high or low is taken, even if you are not at the screen.
[/list] [b]SETTINGS[/b]

Display
- Chart Theme: Dark / Light
- Timezone: Auto DST / Manual UTC-4 (EDT) / Manual UTC-5 (EST)
 
Sessions (per session: toggle, name, time range, color)
- Asia, London, NY AM, NY PM

Appearance
- Show Session Box, High/Low Lines, Midpoint Line, Opening Price
- Lines Only mode: removes box fill, shows boundary lines only
- Line Thickness: 1 to 4
- Boundary Line Style: Solid / Dashed / Dotted
- Color Intensity: global transparency adjustment (-50 to +50)
 
Levels
- Show Unswept Levels: toggle
- Level Line Style: Solid / Dashed / Dotted
- Anticipation Zone: how far unswept lines extend right (candles)
- Show Level Price Labels: toggle
 
Info Panel
- Detail Level: Simple / Standard / Advanced
- Position: Top Left / Top Right / Bottom Left / Bottom Right /
  Middle Left / Middle Right
- Size: Tiny / Small / Normal
 
Display Limits
- Show on Timeframe: 1M / 3M / 5M / 15M / 30M / 45M / 60M
- Show Last N Days: 1 to 30
 
[b]NOTES[/b]
Session Killzones is open source under CC BY-NC-SA 4.0 and is intended for educational purposes only. Nothing in this script constitutes financial advice or a recommendation to buy or sell any instrument.

The DST resolver calculates timezone offset from bar time rather than the system clock, which means the indicator behaves correctly in TradingView replay mode. If you replay to November 2023, the resolver returns EST, not the current wall-clock timezone.

The indicator is designed for intraday timeframes from 1M to 60M and works on any instrument available on TradingView, though it is primarily optimized for forex majors and gold (XAUUSD).
Internally, all session state is tracked using explicit boolean arrays. No state is inferred from drawing object positions or line coordinates, which avoids a common source of bugs in session-based indicators.

## Source Code

````pine
// =======================================================================
//
//   Session Killzones v3.0 - Asia . London . NY AM . NY PM
//
// =======================================================================
//
//   Version    : 3.0.0
//   License    : CC BY-NC-SA 4.0
//
// =======================================================================
//  ABOUT
// =======================================================================
//
//  Session Killzones is a session-based analysis tool for traders
//  following ICT (Inner Circle Trader) methodology. It plots four
//  standard killzones (Asia, London, NY AM, NY PM) in New York time
//  with intelligent features:
//
//    . Session boxes with top/bottom/mid boundary lines
//    . Unswept level extension - lines auto-delete when swept
//    . Sweep detection with alerts
//    . Auto-DST timezone handling (EDT/EST)
//    . Info panel with session countdown
//
// =======================================================================
//  PHILOSOPHY
// =======================================================================
//  Tools amplify skill. Tools don't create skill.
//  Edge stays with discipline + risk management + psychology.
// =======================================================================

//@version=6
indicator("Session Killzones ICT Concept", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=500)

// =======================================================================
// INPUTS - DISPLAY
// =======================================================================
g_disp      = "  Display"
chart_theme = input.string("Dark", "Chart Theme", options=["Dark","Light"], group=g_disp)
tz_mode     = input.string("Auto (DST)", "Timezone",
     options=["Auto (DST)","Manual UTC-4 (EDT)","Manual UTC-5 (EST)"],
     group=g_disp,
     tooltip="Auto: handles EDT (summer) and EST (winter) automatically.\nUse manual only if Auto is inaccurate on your broker.\n\nKillzone reference (NY time):\nAsia 20-00 | London 02-05 | NY AM 08:30-11 | NY PM 13:30-16")

is_dark = chart_theme == "Dark"

// =======================================================================
// INPUTS - SESSIONS
// =======================================================================
g_ses = " Sessions"

sh_asia = input.bool(true,  "",            inline="r1", group=g_ses)
nm_asia = input.string("Asia",       "",   inline="r1", group=g_ses)
ss_asia = input.session("2000-0000", "",   inline="r1", group=g_ses)
cl_asia = input.color(#e91e63,       "",   inline="r1", group=g_ses)

sh_ldn  = input.bool(true,  "",            inline="r2", group=g_ses)
nm_ldn  = input.string("London",     "",   inline="r2", group=g_ses)
ss_ldn  = input.session("0200-0500", "",   inline="r2", group=g_ses)
cl_ldn  = input.color(#00bcd4,       "",   inline="r2", group=g_ses)

sh_nyam = input.bool(true,  "",            inline="r3", group=g_ses)
nm_nyam = input.string("NY AM",      "",   inline="r3", group=g_ses)
ss_nyam = input.session("0830-1100", "",   inline="r3", group=g_ses)
cl_nyam = input.color(#ff5d00,       "",   inline="r3", group=g_ses)

sh_nypm = input.bool(true,  "",            inline="r4", group=g_ses)
nm_nypm = input.string("NY PM",      "",   inline="r4", group=g_ses)
ss_nypm = input.session("1330-1600", "",   inline="r4", group=g_ses)
cl_nypm = input.color(#2157f3,       "",   inline="r4", group=g_ses)

// =======================================================================
// INPUTS - APPEARANCE
// =======================================================================
g_app = " Appearance"
draw_box       = input.bool(true,  "Show Session Box",         group=g_app)
draw_hl        = input.bool(true,  "Show High / Low Lines",    group=g_app)
draw_mid       = input.bool(false, "Show Midpoint Line (50%)", group=g_app)
draw_open      = input.bool(false, "Show Opening Price Line",  group=g_app)
lines_only     = input.bool(false, "Lines Only (Hide Box Fill)", group=g_app, tooltip="ON: shows lines only without box fill. Cleaner chart.")
line_thick     = input.int(1,      "Line Thickness",           group=g_app, minval=1, maxval=4)
boundary_style = input.string("Solid", "Boundary Line Style",  group=g_app, options=["Solid","Dashed","Dotted"])
intensity_adj  = input.int(0,      "Color Intensity",          group=g_app, minval=-50, maxval=50, step=5, tooltip="Slide right (+) for more saturated colors.\nSlide left (-) for more transparent.\n0 = default.")

// =======================================================================
// INPUTS - LEVELS
// =======================================================================
g_lvl            = " Levels"
draw_session_lbl = input.bool(true,   "Show Session Name Label", group=g_lvl)
draw_unswept     = input.bool(true,   "Show Unswept Levels",     group=g_lvl, tooltip="Extend session H/L lines after session close. Auto-deletes when price touches the level.")
anticipate_bars  = input.int(50,      "Anticipation Zone (candles)", group=g_lvl, minval=5, maxval=200, step=5, tooltip="How far the unswept line extends to the right of the latest candle.")
unswept_style    = input.string("Dashed", "Level Line Style",    group=g_lvl, options=["Solid","Dashed","Dotted"])
draw_price_lbl   = input.bool(true,   "Show Level Price Labels", group=g_lvl)

// =======================================================================
// INPUTS - INFO PANEL
// =======================================================================
g_panel      = " Info Panel"
show_panel   = input.bool(true, "Show Panel", group=g_panel)
panel_detail = input.string("Standard", "Detail", options=["Simple","Standard","Advanced"], group=g_panel, tooltip="Simple: active session only.\nStandard: + range of all sessions.\nAdvanced: + unswept levels in panel.")
panel_pos    = input.string("Top Right", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"],
     group=g_panel)
panel_size   = input.string("Tiny", "Size", options=["Tiny","Small","Normal"], group=g_panel)

// =======================================================================
// INPUTS - DISPLAY LIMITS
// =======================================================================
g_tf         = " Display Limits"
max_tf_min   = input.int(60, "Show on Timeframe  (min)", options=[1,3,5,15,30,45,60], group=g_tf)
lookback_day = input.int(3,  "Show Last N Days",          group=g_tf, minval=1, maxval=30)

// Apply lines-only override
eff_draw_box  = lines_only ? false : draw_box
eff_draw_mid  = lines_only ? false : draw_mid
eff_draw_open = lines_only ? false : draw_open

// =======================================================================
// AUTO-DST RESOLVER
// US DST rules: starts 2nd Sunday of March, ends 1st Sunday of November
// Uses bar `time` (not `timenow`) -> works correctly in replay mode
// =======================================================================
f_resolve_tz() =>
    int _mo = month(time, "UTC")
    int _dy = dayofmonth(time, "UTC")
    int _dw = dayofweek(time, "UTC")
    bool _is_edt = false
    if _mo > 3 and _mo < 11
        _is_edt := true
    else if _mo == 3
        if _dy >= 8 and _dy <= 14 and _dw == dayofweek.sunday
            _is_edt := true
        else if _dy > 14
            _is_edt := true
    else if _mo == 11
        if _dy < 7 and _dw != dayofweek.sunday
            _is_edt := true
        else if _dy == 7 and _dw != dayofweek.sunday
            _is_edt := true
    _is_edt ? "UTC-4" : "UTC-5"

ny_tz = switch tz_mode
    "Manual UTC-4 (EDT)" => "UTC-4"
    "Manual UTC-5 (EST)" => "UTC-5"
    =>                      f_resolve_tz()

// =======================================================================
// STYLE CONSTANTS
// =======================================================================
PB   = color.new(#141414, 5)
PH   = color.new(#1f1f1f, 0)
PS   = color.new(#2d2d2d, 0)
PT   = color.rgb(210, 210, 210)
PD   = color.rgb(130, 130, 130)
PBDR = color.new(#2a2a2a, 0)
PA   = color.rgb(180, 180, 180)

PTXT = panel_size == "Small" ? size.small : panel_size == "Normal" ? size.normal : size.tiny

C_GREEN = color.rgb(100, 200, 140)
C_RED   = color.rgb(230, 120, 120)

f_opacity(base) => math.max(0, math.min(100, base - intensity_adj))

int OP_BOX      = f_opacity(is_dark ? 90 : 78)
int OP_UNSWEPT  = f_opacity(is_dark ? 75 : 55)
int OP_BOUNDARY = f_opacity(is_dark ? 40 : 15)
int OP_OPENING  = f_opacity(is_dark ? 50 : 30)
int OP_MIDLINE  = f_opacity(is_dark ? 70 : 50)

// =======================================================================
// SESSION COUNTDOWN HELPERS
// =======================================================================
f_parse_time(string hhmm) =>
    int result = 0
    if str.length(hhmm) >= 4
        float fh = str.tonumber(str.substring(hhmm, 0, 2))
        float fm = str.tonumber(str.substring(hhmm, 2, 4))
        if not na(fh) and not na(fm)
            result := int(fh) * 60 + int(fm)
    result

f_parse_session(string sess) =>
    int dash_pos = str.pos(sess, "-")
    int _start = 0
    int _end   = 0
    if not na(dash_pos) and dash_pos > 0
        string s_start = str.substring(sess, 0, dash_pos)
        string s_end   = str.substring(sess, dash_pos + 1, str.length(sess))
        _start := f_parse_time(s_start)
        _end   := f_parse_time(s_end)
        if _end == 0
            _end := 1440
    [_start, _end]

f_ny_now_mins() =>
    int _h = hour(time, ny_tz)
    int _m = minute(time, ny_tz)
    _h * 60 + _m

f_fmt_dur(int n) =>
    int safe = math.max(n, 0)
    int h = int(safe / 60)
    int m = safe - h * 60
    h > 0 ? str.tostring(h) + "h " + str.tostring(m) + "m" : str.tostring(m) + "m"

f_session_countdown() =>
    int cur_mins = f_ny_now_mins()
    string result = ""

    string[] names = array.from(nm_asia, nm_ldn, nm_nyam, nm_nypm)
    string[] sess_str = array.from(ss_asia, ss_ldn, ss_nyam, ss_nypm)
    bool[]   visible  = array.from(sh_asia, sh_ldn, sh_nyam, sh_nypm)

    bool found_active = false
    for i = 0 to 3
        if array.get(visible, i) and not found_active
            [sess_start, sess_end] = f_parse_session(array.get(sess_str, i))
            if cur_mins >= sess_start and cur_mins < sess_end
                int left = sess_end - cur_mins
                result := array.get(names, i) + " | " + f_fmt_dur(left) + " left"
                found_active := true

    if not found_active
        int best_diff = 99999
        string best_name = ""
        for i = 0 to 3
            if array.get(visible, i)
                [next_start, next_end] = f_parse_session(array.get(sess_str, i))
                int diff = next_start - cur_mins
                if diff < 0
                    diff := diff + 1440
                if diff < best_diff and diff > 0
                    best_diff := diff
                    best_name := array.get(names, i)
        result := best_name == "" ? "No session" : best_name + " in " + f_fmt_dur(best_diff)

    result

// =======================================================================
// HELPER FUNCTIONS
// =======================================================================
f_line_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_table_pos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        =>                position.middle_right

f_price(p) =>
    na(p) ? "-" : math.abs(p) >= 1000.0 ? str.tostring(math.round(p)) : str.tostring(p, format.mintick)

f_range_pct(hi, lo, opn, cls) =>
    if na(hi) or na(lo) or lo == 0.0 or hi <= lo
        "-"
    else
        float  mag  = (hi - lo) / lo * 100.0
        string sgn  = na(opn) or na(cls) ? "" : cls > opn ? "+" : cls < opn ? "-" : ""
        string num  = mag < 1.0 ? str.tostring(mag, "#.##") : str.tostring(mag, "#.#")
        sgn + num + "%"

f_direction_sign(opn, cls) =>
    na(opn) or na(cls) ? 0 : cls > opn ? 1 : cls < opn ? -1 : 0

f_short_name(n) =>
    n == "Asia" ? "A" : n == "London" ? "L" : n == "NY AM" ? "NA" : n == "NY PM" ? "NP" : str.substring(n, 0, 1)

f_row(_tbl, _r, _lbl, _val, _lcol, _vcol, _bg) =>
    table.cell(_tbl, 0, _r, _lbl, text_color=_lcol, text_size=PTXT, bgcolor=_bg, text_halign=text.align_left)
    table.cell(_tbl, 1, _r, _val, text_color=_vcol, text_size=PTXT, bgcolor=_bg, text_halign=text.align_right)
    _r + 1

// =======================================================================
// SESSION STATE - PARALLEL ARRAYS
// =======================================================================
cur_in_asia = not na(time(timeframe.period, ss_asia, ny_tz))
cur_in_ldn  = not na(time(timeframe.period, ss_ldn,  ny_tz))
cur_in_nyam = not na(time(timeframe.period, ss_nyam, ny_tz))
cur_in_nypm = not na(time(timeframe.period, ss_nypm, ny_tz))

tf_mult   = timeframe.multiplier
within_tf = timeframe.isintraday and tf_mult <= max_tf_min

active_asia = cur_in_asia and sh_asia and within_tf
active_ldn  = cur_in_ldn  and sh_ldn  and within_tf
active_nyam = cur_in_nyam and sh_nyam and within_tf
active_nypm = cur_in_nypm and sh_nypm and within_tf

any_active = active_asia or active_ldn or active_nyam or active_nypm

within_lookback = (last_bar_index - bar_index) <= lookback_day * 1440 / tf_mult

new_day = timeframe.change("D")
var bool today_asia = false
var bool today_ldn  = false
var bool today_nyam = false
var bool today_nypm = false

if new_day
    today_asia := false
    today_ldn  := false
    today_nyam := false
    today_nypm := false

var float[] ses_hi   = array.from(0.0, 0.0, 0.0, 0.0)
var float[] ses_lo   = array.from(0.0, 0.0, 0.0, 0.0)
var float[] ses_mid  = array.from(0.0, 0.0, 0.0, 0.0)
var float[] ses_opn  = array.from(0.0, 0.0, 0.0, 0.0)
var float[] ses_cls  = array.from(0.0, 0.0, 0.0, 0.0)
var int[]   ses_st   = array.from(0, 0, 0, 0)
var bool[]  ses_live = array.from(false, false, false, false)

var box[]   ref_box    = array.from(box(na),   box(na),   box(na),   box(na))
var line[]  ref_hi     = array.from(line(na),  line(na),  line(na),  line(na))
var line[]  ref_lo     = array.from(line(na),  line(na),  line(na),  line(na))
var line[]  ref_mid    = array.from(line(na),  line(na),  line(na),  line(na))
var line[]  ref_open   = array.from(line(na),  line(na),  line(na),  line(na))
var label[] ref_sesLbl = array.from(label(na), label(na), label(na), label(na))

var line[]  unswept_lines  = array.new<line>()
var label[] unswept_labels = array.new<label>()
var bool[]  unswept_is_hi  = array.new<bool>()
var bool[]  unswept_swept  = array.new<bool>()

ses_names  = array.from(nm_asia,  nm_ldn,  nm_nyam, nm_nypm)
ses_colors = array.from(cl_asia,  cl_ldn,  cl_nyam, cl_nypm)
ses_show   = array.from(sh_asia,  sh_ldn,  sh_nyam, sh_nypm)
ses_active = array.from(active_asia, active_ldn, active_nyam, active_nypm)
ses_today  = array.from(today_asia,  today_ldn,  today_nyam,  today_nypm)

// =======================================================================
// SESSION PROCESSING
// =======================================================================
f_process_session(int idx, bool cur_active, bool prev_active, float _h, float _l, float _o, float _c, int _t, color _col, string _name) =>
    bool is_new   = cur_active and not prev_active and within_lookback
    bool is_alive = cur_active and within_lookback
    bool is_end   = not cur_active and prev_active and within_lookback

    color c_box      = color.new(_col, OP_BOX)
    color c_boundary = color.new(_col, OP_BOUNDARY)
    color c_unswept  = color.new(_col, OP_UNSWEPT)
    color c_opening  = color.new(_col, OP_OPENING)
    color c_midline  = color.new(_col, OP_MIDLINE)
    color c_lbl_txt  = is_dark ? color.new(#e0e0e0, 10) : color.new(#333333, 10)

    if is_new
        array.set(ses_hi,   idx, _h)
        array.set(ses_lo,   idx, _l)
        array.set(ses_mid,  idx, (_h + _l) / 2.0)
        array.set(ses_opn,  idx, _o)
        array.set(ses_cls,  idx, _c)
        array.set(ses_st,   idx, _t)
        array.set(ses_live, idx, true)

        if eff_draw_box
            array.set(ref_box, idx, box.new(bar_index, _h, bar_index, _l, na, bgcolor=c_box))
        if draw_hl
            array.set(ref_hi, idx, line.new(_t, _h, _t, _h, xloc.bar_time, color=c_boundary, width=line_thick, style=f_line_style(boundary_style)))
            array.set(ref_lo, idx, line.new(_t, _l, _t, _l, xloc.bar_time, color=c_boundary, width=line_thick, style=f_line_style(boundary_style)))
        if eff_draw_mid
            array.set(ref_mid, idx, line.new(_t, (_h + _l) / 2.0, _t, (_h + _l) / 2.0, xloc.bar_time, color=c_midline, style=line.style_dotted, width=line_thick))
        if eff_draw_open
            array.set(ref_open, idx, line.new(_t, _o, _t, _o, xloc.bar_time, color=c_opening, width=1, style=line.style_dotted))
        if draw_session_lbl
            array.set(ref_sesLbl, idx, label.new(_t, _h, _name, xloc.bar_time, color=color.new(color.gray, 100), style=label.style_label_down, textcolor=c_lbl_txt, size=size.tiny))

    if is_alive
        float prev_hi = array.get(ses_hi, idx)
        float prev_lo = array.get(ses_lo, idx)
        float new_hi  = math.max(_h, prev_hi)
        float new_lo  = math.min(_l, prev_lo)

        array.set(ses_hi,  idx, new_hi)
        array.set(ses_lo,  idx, new_lo)
        array.set(ses_mid, idx, (new_hi + new_lo) / 2.0)
        array.set(ses_cls, idx, _c)

        box   b  = array.get(ref_box,    idx)
        line  lh = array.get(ref_hi,     idx)
        line  ll = array.get(ref_lo,     idx)
        line  lm = array.get(ref_mid,    idx)
        line  ln_op = array.get(ref_open, idx)
        label lb = array.get(ref_sesLbl, idx)

        if eff_draw_box and not na(b)
            box.set_top(b, new_hi)
            box.set_rightbottom(b, bar_index, new_lo)
        if draw_hl and not na(lh)
            line.set_y1(lh, new_hi)
            line.set_xy2(lh, _t, new_hi)
            line.set_y1(ll, new_lo)
            line.set_xy2(ll, _t, new_lo)
        if eff_draw_mid and not na(lm)
            line.set_y1(lm, (new_hi + new_lo) / 2.0)
            line.set_xy2(lm, _t, (new_hi + new_lo) / 2.0)
        if eff_draw_open and not na(ln_op)
            line.set_xy2(ln_op, _t, _o)
        if draw_session_lbl and not na(lb)
            label.set_x(lb, int(math.avg(array.get(ses_st, idx), _t)))
            label.set_y(lb, new_hi)

    if is_end
        array.set(ses_live, idx, false)
        if draw_unswept and draw_hl
            float final_hi = array.get(ses_hi, idx)
            float final_lo = array.get(ses_lo, idx)
            if final_hi > 0.0 and final_lo > 0.0
                line  unsw_hi_ln = line.new(_t, final_hi, _t, final_hi, xloc.bar_time, color=c_unswept, width=line_thick, style=f_line_style(unswept_style))
                array.push(unswept_lines,  unsw_hi_ln)
                array.push(unswept_is_hi,  true)
                array.push(unswept_swept,  false)
                if draw_price_lbl
                    label lb_hi = label.new(_t, final_hi, f_short_name(_name) + ".H " + f_price(final_hi), xloc.bar_time, color=color.new(color.gray, 100), style=label.style_label_left, textcolor=_col, size=size.tiny)
                    array.push(unswept_labels, lb_hi)
                else
                    array.push(unswept_labels, label(na))

                line  unsw_lo_ln = line.new(_t, final_lo, _t, final_lo, xloc.bar_time, color=c_unswept, width=line_thick, style=f_line_style(unswept_style))
                array.push(unswept_lines,  unsw_lo_ln)
                array.push(unswept_is_hi,  false)
                array.push(unswept_swept,  false)
                if draw_price_lbl
                    label lb_lo = label.new(_t, final_lo, f_short_name(_name) + ".L " + f_price(final_lo), xloc.bar_time, color=color.new(color.gray, 100), style=label.style_label_left, textcolor=_col, size=size.tiny)
                    array.push(unswept_labels, lb_lo)
                else
                    array.push(unswept_labels, label(na))

if active_asia and not active_asia[1]
    today_asia := true
if active_ldn and not active_ldn[1]
    today_ldn := true
if active_nyam and not active_nyam[1]
    today_nyam := true
if active_nypm and not active_nypm[1]
    today_nypm := true

f_process_session(0, active_asia, active_asia[1], high, low, open, close, time, cl_asia, nm_asia)
f_process_session(1, active_ldn,  active_ldn[1],  high, low, open, close, time, cl_ldn,  nm_ldn)
f_process_session(2, active_nyam, active_nyam[1], high, low, open, close, time, cl_nyam, nm_nyam)
f_process_session(3, active_nypm, active_nypm[1], high, low, open, close, time, cl_nypm, nm_nypm)

// =======================================================================
// UNSWEPT LEVEL SWEEP DETECTION
// =======================================================================
int bar_duration_ms = tf_mult * 60000
int anticipate_time = time + anticipate_bars * bar_duration_ms

var bool sweep_hi_event = false
var bool sweep_lo_event = false
sweep_hi_event := false
sweep_lo_event := false

if array.size(unswept_lines) > 0
    int i = 0
    while i < array.size(unswept_lines)
        bool already_swept = array.get(unswept_swept, i)
        if not already_swept
            line  ln    = array.get(unswept_lines,  i)
            label lb    = array.get(unswept_labels, i)
            bool  is_hi = array.get(unswept_is_hi,  i)
            float level = line.get_y1(ln)

            bool touched = is_hi ? (high >= level) : (low <= level)
            if touched
                line.set_x2(ln, time)
                if not na(lb)
                    label.delete(lb)
                    array.set(unswept_labels, i, label(na))
                array.set(unswept_swept, i, true)
                if is_hi
                    sweep_hi_event := true
                else
                    sweep_lo_event := true
            else
                int new_x2 = barstate.islast ? anticipate_time : time
                line.set_x2(ln, new_x2)
                if not na(lb)
                    label.set_x(lb, new_x2)
        i += 1

alertcondition(sweep_hi_event, title="KZ High Swept", message="! Killzone HIGH has been swept!")
alertcondition(sweep_lo_event, title="KZ Low Swept",  message="! Killzone LOW has been swept!")

// =======================================================================
// INFO PANEL
// =======================================================================
f_active_session_index() =>
    int _idx = -1
    if active_asia
        _idx := 0
    else if active_ldn
        _idx := 1
    else if active_nyam
        _idx := 2
    else if active_nypm
        _idx := 3
    _idx

var table info_tbl = na

if show_panel and barstate.islast and within_tf
    table.delete(info_tbl)

    int act_idx = f_active_session_index()
    bool has_active = act_idx >= 0

    bool panel_has_sessions = panel_detail == "Standard" or panel_detail == "Advanced"
    bool panel_has_unswept  = panel_detail == "Advanced"

    int vis_count = (sh_asia ? 1 : 0) + (sh_ldn ? 1 : 0) + (sh_nyam ? 1 : 0) + (sh_nypm ? 1 : 0)

    int unsw_count = 0
    if panel_has_unswept
        for i = 0 to 3
            if array.get(ses_show, i) and not array.get(ses_active, i) and array.get(ses_today, i)
                if array.get(ses_hi, i) > 0.0
                    unsw_count += 1
                if array.get(ses_lo, i) > 0.0
                    unsw_count += 1

    int rows = 4
    if panel_has_sessions
        rows += 1 + vis_count
    if panel_has_unswept and unsw_count > 0
        rows += 1 + unsw_count

    info_tbl := table.new(f_table_pos(panel_pos), 2, rows, bgcolor=PB, border_color=PBDR, border_width=1, frame_color=PBDR, frame_width=1)
    int r = 0

    r := f_row(info_tbl, r, "Session Killzones", syminfo.ticker + " / " + timeframe.period, PA, PD, PH)

    string tz_label = tz_mode == "Auto (DST)" ? ny_tz + " (Auto)" : ny_tz
    r := f_row(info_tbl, r, "CURRENT SESSION", tz_label, PD, PD, PS)

    string ctdn_str = f_session_countdown()
    int cur_mins_panel = f_ny_now_mins()
    string[] ctdn_sess_arr = array.from(ss_asia, ss_ldn, ss_nyam, ss_nypm)
    bool in_warning = false
    for i = 0 to 3
        if array.get(ses_show, i) and array.get(ses_active, i)
            [warn_start, warn_end] = f_parse_session(array.get(ctdn_sess_arr, i))
            int time_left = warn_end - cur_mins_panel
            if time_left <= 15 and time_left > 0
                in_warning := true
    color ctdn_col = has_active ? (in_warning ? color.rgb(255, 200, 80) : C_GREEN) : PD
    r := f_row(info_tbl, r, "  Session", ctdn_str, PD, ctdn_col, PB)

    if has_active
        string a_name = array.get(ses_names,  act_idx)
        color  a_col  = array.get(ses_colors, act_idx)
        float  a_opn  = array.get(ses_opn,    act_idx)
        float  a_hi   = array.get(ses_hi,     act_idx)
        float  a_lo   = array.get(ses_lo,     act_idx)
        string dir    = close > a_opn ? " Up" : close < a_opn ? " Dn" : ""
        color  col    = close > a_opn ? C_GREEN : close < a_opn ? C_RED : a_col
        string pct    = f_range_pct(a_hi, a_lo, a_opn, close)
        r := f_row(info_tbl, r, "  " + a_name + dir, pct, col, col, PB)
    else
        r := f_row(info_tbl, r, "  -", "", PD, PD, PB)

    if panel_has_sessions
        r := f_row(info_tbl, r, "SESSIONS", "%", PD, PD, PS)
        for i = 0 to 3
            if array.get(ses_show, i)
                float hi       = array.get(ses_hi,     i)
                float lo       = array.get(ses_lo,     i)
                float opn      = array.get(ses_opn,    i)
                float cls      = array.get(ses_cls,    i)
                bool  act      = array.get(ses_active, i)
                bool  occurred = array.get(ses_today,  i)
                color sc       = array.get(ses_colors, i)
                string nm      = array.get(ses_names,  i)
                float eff_cls  = act ? close : cls
                bool  has_data = occurred and hi > 0.0 and lo > 0.0
                int   sgn      = f_direction_sign(opn, eff_cls)
                color name_col = has_data ? sc : color.new(sc, 70)
                color pct_col  = not has_data ? PD : sgn > 0 ? C_GREEN : sgn < 0 ? C_RED : PT
                string pct_str = has_data ? f_range_pct(hi, lo, opn, eff_cls) : "-"
                r := f_row(info_tbl, r, "  " + nm, pct_str, name_col, pct_col, PB)

    if panel_has_unswept and unsw_count > 0
        r := f_row(info_tbl, r, "UNSWEPT LEVELS", "Price", PD, PD, PS)
        for i = 0 to 3
            if array.get(ses_show, i) and not array.get(ses_active, i) and array.get(ses_today, i)
                string ab = f_short_name(array.get(ses_names,  i))
                color  sc = array.get(ses_colors, i)
                float  hi = array.get(ses_hi, i)
                float  lo = array.get(ses_lo, i)
                if hi > 0.0
                    r := f_row(info_tbl, r, "  " + ab + ".H", f_price(hi), sc, PT, PB)
                if lo > 0.0
                    r := f_row(info_tbl, r, "  " + ab + ".L", f_price(lo), sc, PT, PB)
````

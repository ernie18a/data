# Trading Sessions [EDGE]

- url: https://www.tradingview.com/script/20uWl6bR-Trading-Sessions-EDGE/
- type: indicator
- pine_id: PUB;bd6d150c69244de3b46580645d783ed9
- version: 1.0

## Description

Trading Sessions [EDGE].

A continental trading-session engine that marks the four global sessions - Pacific, Asia, Europe, USA - in both Forex and Stocks mode, and shows at a glance which session is live, how long until each one opens or closes, and where price sits relative to each session open. Built for intraday traders who structure the day around session opens and want a single, timezone-correct view of the session clock.

How it works:
Every session is defined in the local business hours of its region and detected with an IANA timezone name (Australia/Sydney, Asia/Tokyo, Europe/London, America/New_York), so daylight-saving transitions are resolved automatically - the windows shift with each region's own clock and never need a manual seasonal adjustment. Detection is restricted to Monday through Friday. Two market modes share the same four continental sessions with hours native to each market type: in Forex mode they map to the Sydney, Tokyo, London and New York dealing desks; in Stocks mode they map to the region's anchor cash market - ASX Sydney (Pacific), a combined Tokyo/Hong Kong window (Asia), LSE London (Europe) and NYSE/Nasdaq (USA).

For each active session the script tracks a live high and low, drawing a range box that updates every bar and a horizontal line at the session open. The dashboard reads live clock time in each session's own timezone, so its open and close countdowns stay correct through every daylight-saving change, and it reports each session open price together with the current price's signed percent distance from it. All context is anchored to price - session boxes and open lines - plus the dashboard; there is no background shading.

What it calculates:
- Session state - which continental sessions are open right now, marked with a dot and a session-colored row in the dashboard
- Countdown - time until each session opens (when closed) or closes (when running), in the session's own timezone
- Session range box - the live high-to-low band of each session, kept on the chart as a prior-session reference
- Session open price - the price at which each session opened, shown in the dashboard
- Open Δ% - the current price change from the session open as a signed percent, green above the open and red below
- Session open line - a horizontal level at each session open, a widely watched institutional reference for retests
- Europe/USA overlap flag (Forex) - a dashboard note during the four-hour overlap, the deepest liquidity window of the day

Key features:
- Two market modes - Forex and Stocks - selectable from a single input, each with its own native session hours
- Four continental sessions - Pacific, Asia, Europe, USA - with per-session visibility toggles and editable hours
- Automatic daylight-saving handling through IANA timezones; no manual seasonal switching
- Combined Asia stock session spanning Tokyo and Hong Kong as one continuous window
- Live dashboard with active-session highlighting, per-session open/close countdowns, session open price and the signed percent change from it, with configurable position and text size
- Session range boxes and session open price lines, both fully colorable, with a configurable history depth to limit chart clutter
- Alerts for every session open and close, plus the Europe/USA overlap start
- Intraday-only operation with a clear on-panel notice on daily and higher timeframes

Who it's for:
Intraday and short-horizon traders who structure the day around session opens - Asia-range and London-breakout players, New York-open traders, and index or futures traders who track the Pacific-to-USA handover. The tool answers the questions that matter at the open: which session is driving price now, how long until the next one turns over, and how far price has travelled from each session open - a clean, timezone-correct session clock without the visual noise of overlapping session tools.

## Source Code

````pine
// =============================================================================
// TRADING SESSIONS [EDGE]
// Continental trading-session engine with automatic DST handling via IANA
// timezones. Four continental sessions in both modes - Pacific, Asia, Europe,
// USA - with a live open/close countdown dashboard, session range boxes,
// session open price lines and session open/close alerts. No background
// shading - all context lives in price-anchored drawings and the dashboard.
// =============================================================================

//@version=6
indicator(title            = "Trading Sessions [EDGE]",
          shorttitle       = "Trading Sessions [EDGE]",
          overlay          = true,
          max_boxes_count  = 100,
          max_lines_count  = 100)

// =============================================================================
// GROUP 1 — MODE
// =============================================================================

g_mode = "Mode"

market_mode = input.string("Forex", "Market mode", options = ["Forex", "Stocks"], group = g_mode,
     tooltip = "Both modes use the same four continental sessions - Pacific, Asia, Europe, USA - with hours native to each market type. Forex: dealing hours of Sydney, Tokyo, London and New York desks. Stocks: cash hours of the region's anchor exchange - ASX Sydney (Pacific), TSE Tokyo (Asia), LSE London (Europe), NYSE/Nasdaq (USA). All windows are defined in local exchange time with IANA timezones, so daylight-saving shifts are applied automatically - no manual seasonal adjustment is ever needed.")

// =============================================================================
// GROUP 2 — FOREX SESSIONS (continental, local business hours, DST-safe)
// =============================================================================

g_fx = "Forex Sessions"

fx_show_pac  = input.bool(true, "Pacific", group = g_fx, inline = "fx1")
fx_show_asia = input.bool(true, "Asia",    group = g_fx, inline = "fx1")
fx_show_eur  = input.bool(true, "Europe",  group = g_fx, inline = "fx2")
fx_show_usa  = input.bool(true, "USA",     group = g_fx, inline = "fx2")

fx_sess_pac  = input.session("0800-1700", "Pacific hours", group = g_fx, tooltip = "Local Sydney dealing window. Change only if your desk uses different hours.")
fx_sess_asia = input.session("0900-1800", "Asia hours",    group = g_fx, tooltip = "Local Tokyo dealing window.")
fx_sess_eur  = input.session("0800-1700", "Europe hours",  group = g_fx, tooltip = "Local London dealing window.")
fx_sess_usa  = input.session("0800-1700", "USA hours",     group = g_fx, tooltip = "Local New York dealing window.")

// =============================================================================
// GROUP 3 — STOCK SESSIONS (continental anchor exchanges, DST-safe)
// =============================================================================

g_st = "Stock Sessions"

st_show_pac  = input.bool(true, "Pacific", group = g_st, inline = "st1")
st_show_asia = input.bool(true, "Asia",    group = g_st, inline = "st1")
st_show_eur  = input.bool(true, "Europe",  group = g_st, inline = "st2")
st_show_usa  = input.bool(true, "USA",     group = g_st, inline = "st2")

st_sess_pac  = input.session("1000-1600",           "Pacific hours", group = g_st, tooltip = "Local Sydney cash-session window (ASX).")
st_sess_asia = input.session("0900-1700",           "Asia hours",    group = g_st, tooltip = "Combined Asia cash session in Asia/Tokyo time, spanning both Tokyo and Hong Kong: TSE 09:00-15:30 JST plus HKEX 09:30-16:00 HKT (10:30-17:00 JST). Tracked as one continuous 09:00-17:00 window so the range box, average and countdowns cover the whole Asian cash day; internal lunch breaks are ignored.")
st_sess_eur  = input.session("0800-1630",           "Europe hours",  group = g_st, tooltip = "Local London cash-session window (LSE). For Frankfurt use 0900-1730 - Xetra runs on Europe/Berlin time, one hour ahead of London.")
st_sess_usa  = input.session("0930-1600",           "USA hours",     group = g_st, tooltip = "Local New York cash-session window (NYSE/Nasdaq).")

// =============================================================================
// GROUP 4 — VISUALS (price-anchored only, no background shading)
// =============================================================================

g_vis = "Visuals"

show_boxes = input.bool(true, "Session range boxes", group = g_vis, tooltip = "Live-updating high/low box per session. Completed boxes stay on the chart as prior-session liquidity references.")
show_opens = input.bool(true, "Session open price lines", group = g_vis, tooltip = "Bright horizontal ray from each session open. Open-price retests (notably Europe and USA opens) are widely traded institutional reference levels.")
keep_days  = input.int(20, "Draw history (days)", minval = 1, maxval = 60, group = g_vis, tooltip = "How many recent days keep session range boxes and open lines. Limits chart clutter and drawing count.")

col_pac  = input.color(#00695c, "Pacific", group = g_vis, inline = "c1")
col_asia = input.color(#b71c1c, "Asia",    group = g_vis, inline = "c1")
col_eur  = input.color(#0d47a1, "Europe",  group = g_vis, inline = "c2")
col_usa  = input.color(#6a1b9a, "USA",     group = g_vis, inline = "c2")

// =============================================================================
// GROUP 5 — DASHBOARD
// =============================================================================

g_tbl = "Dashboard"

show_tbl = input.bool(true, "Show dashboard", group = g_tbl, tooltip = "Live panel: active sessions are marked with a dot and a session-colored row plus time to close; inactive sessions show time to open.")
tbl_pos  = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_tbl, tooltip = "Corner anchor of the dashboard.")
tbl_size = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = g_tbl, tooltip = "Dashboard text size.")

// =============================================================================
// TIMEZONES AND SESSION DETECTION
// All windows are LOCAL exchange hours with IANA zone names, so TradingView
// resolves daylight-saving transitions automatically (US: Mar-Nov, UK/EU:
// Mar-Oct, Australia: Oct-Apr, Japan and Hong Kong: none). ":23456" restricts
// detection to Monday-Friday.
// =============================================================================

TZ_SYD = "Australia/Sydney"
TZ_TOK = "Asia/Tokyo"
TZ_LDN = "Europe/London"
TZ_NYC = "America/New_York"

is_fx = market_mode == "Forex"
is_st = not is_fx

fx_in_pac  = not na(time(timeframe.period, fx_sess_pac  + ":23456", TZ_SYD))
fx_in_asia = not na(time(timeframe.period, fx_sess_asia + ":23456", TZ_TOK))
fx_in_eur  = not na(time(timeframe.period, fx_sess_eur  + ":23456", TZ_LDN))
fx_in_usa  = not na(time(timeframe.period, fx_sess_usa  + ":23456", TZ_NYC))

st_in_pac  = not na(time(timeframe.period, st_sess_pac  + ":23456", TZ_SYD))
st_in_asia = not na(time(timeframe.period, st_sess_asia + ":23456", TZ_TOK))
st_in_eur  = not na(time(timeframe.period, st_sess_eur  + ":23456", TZ_LDN))
st_in_usa  = not na(time(timeframe.period, st_sess_usa  + ":23456", TZ_NYC))

// Sessions are meaningful on intraday charts only.
intraday_ok = not timeframe.isdwm
recent_ok   = time > timenow - keep_days * 86400 * 1000

// Europe/USA overlap - the deepest FX liquidity window (dashboard + alert).
fx_overlap = fx_in_eur and fx_in_usa

// =============================================================================
// SESSION TRACKER
// One call per session. Tracks the live high/low to draw the range box and the
// open price line, and returns the session-open and session-close edge events.
// =============================================================================

f_track(bool enabled, bool in_sess, color base_col) =>
    var float s_hi  = na
    var float s_lo  = na
    var float s_op  = na
    var box   s_box = na
    var line  s_ln  = na
    started = enabled and in_sess and not in_sess[1]
    ended   = enabled and not in_sess and in_sess[1]
    if started
        s_hi := high
        s_lo := low
        s_op := open
        if show_boxes and recent_ok and intraday_ok
            s_box := box.new(bar_index, high, bar_index, low, border_color = color.new(base_col, 10), border_width = 1, bgcolor = color.new(base_col, 82))
        if show_opens and recent_ok and intraday_ok
            s_ln := line.new(bar_index, open, bar_index + 1, open, color = color.new(base_col, 0), style = line.style_solid, width = 1)
    if enabled and in_sess and not started
        s_hi := math.max(s_hi, high)
        s_lo := math.min(s_lo, low)
        if not na(s_box)
            box.set_right(s_box, bar_index)
            box.set_top(s_box, s_hi)
            box.set_bottom(s_box, s_lo)
        if not na(s_ln)
            line.set_x2(s_ln, bar_index)
    if ended
        s_box := na
        s_ln  := na
    [started, ended, s_op]

[fxp_start, fxp_end, fxp_op] = f_track(is_fx and fx_show_pac,  fx_in_pac,  col_pac)
[fxa_start, fxa_end, fxa_op] = f_track(is_fx and fx_show_asia, fx_in_asia, col_asia)
[fxe_start, fxe_end, fxe_op] = f_track(is_fx and fx_show_eur,  fx_in_eur,  col_eur)
[fxu_start, fxu_end, fxu_op] = f_track(is_fx and fx_show_usa,  fx_in_usa,  col_usa)

[stp_start, stp_end, stp_op] = f_track(is_st and st_show_pac,  st_in_pac,  col_pac)
[sta_start, sta_end, sta_op] = f_track(is_st and st_show_asia, st_in_asia, col_asia)
[ste_start, ste_end, ste_op] = f_track(is_st and st_show_eur,  st_in_eur,  col_eur)
[stu_start, stu_end, stu_op] = f_track(is_st and st_show_usa,  st_in_usa,  col_usa)

// =============================================================================
// DASHBOARD: LIVE MARKERS AND OPEN/CLOSE COUNTDOWNS
// Countdowns are computed from live clock time in each session's own timezone,
// so they stay correct through every DST transition.
// =============================================================================

f_min_of(string hhmm) =>
    str.tonumber(str.substring(hhmm, 0, 2)) * 60 + str.tonumber(str.substring(hhmm, 2, 4))

f_open_min(string sess) =>
    f_min_of(str.substring(sess, 0, 4))

f_close_min(string sess) =>
    int len = str.length(sess)
    f_min_of(str.substring(sess, len - 4, len))

f_pad(int n) =>
    (n < 10 ? "0" : "") + str.tostring(n)

f_dur(int mins) =>
    str.tostring(math.floor(mins / 60)) + "h " + f_pad(mins % 60) + "m"

f_status(bool in_sess, string sess, string tz) =>
    int now_m = hour(timenow, tz) * 60 + minute(timenow, tz)
    int dow   = dayofweek(timenow, tz)
    int o_m   = int(f_open_min(sess))
    int c_m   = int(f_close_min(sess))
    string s  = ""
    if dow == dayofweek.saturday or dow == dayofweek.sunday
        s := "weekend"
    else if in_sess
        int wait_c = c_m - now_m
        wait_c := wait_c < 0 ? 0 : wait_c
        s := "closes in " + f_dur(wait_c)
    else
        int wait_o = (o_m - now_m) % 1440
        wait_o := wait_o < 0 ? wait_o + 1440 : wait_o
        s := "opens in " + f_dur(wait_o)
    s

// Percent distance of the current price from a session open, signed.
f_pct(float op) =>
    not na(op) and op != 0 ? (close - op) / op * 100.0 : na

f_pct_txt(float pct) =>
    na(pct) ? "" : (pct >= 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"

f_pct_col(float pct) =>
    na(pct) ? color.new(#e6e6e6, 0) : pct > 0 ? color.new(#26a69a, 0) : pct < 0 ? color.new(#ef5350, 0) : color.new(#e6e6e6, 0)

f_price_txt(float p) =>
    na(p) ? "" : str.tostring(p, format.mintick)

pos_lookup = tbl_pos == "Top Right" ? position.top_right : tbl_pos == "Bottom Right" ? position.bottom_right : tbl_pos == "Top Left" ? position.top_left : position.bottom_left
sz_lookup  = tbl_size == "Tiny" ? size.tiny : tbl_size == "Small" ? size.small : size.normal

C_HDR = color.new(#1e222d, 0)
C_TXT = color.new(#e6e6e6, 0)
C_R1  = color.new(#262b36, 30)
C_R2  = color.new(#1a1d24, 30)

var table tbl = table.new(pos_lookup, 4, 8, border_width = 1, border_color = color.new(#000000, 70))

f_row(int r, string name_, bool live_, string status_, float op_, color mark) =>
    color rbg = live_ ? color.new(mark, 78) : r % 2 == 0 ? C_R1 : C_R2
    string nm = (live_ ? "● " : "") + name_
    float pct = f_pct(op_)
    table.cell(tbl, 0, r, nm,      text_color = live_ ? color.white : mark, text_size = sz_lookup, bgcolor = rbg, text_halign = text.align_left)
    table.cell(tbl, 1, r, status_, text_color = live_ ? color.white : C_TXT, text_size = sz_lookup, bgcolor = rbg)
    table.cell(tbl, 2, r, f_price_txt(op_), text_color = live_ ? color.white : C_TXT, text_size = sz_lookup, bgcolor = rbg)
    table.cell(tbl, 3, r, f_pct_txt(pct),   text_color = f_pct_col(pct), text_size = sz_lookup, bgcolor = rbg)

if show_tbl and barstate.islast
    table.clear(tbl, 0, 0, 3, 7)
    table.cell(tbl, 0, 0, "Session", text_color = C_TXT, text_size = sz_lookup, bgcolor = C_HDR, text_halign = text.align_left, tooltip = "Continental session. A dot and a colored row mark sessions running right now.")
    table.cell(tbl, 1, 0, "Status", text_color = C_TXT, text_size = sz_lookup, bgcolor = C_HDR, tooltip = "Time until the session opens (when closed) or closes (when running), in the session's own timezone.")
    table.cell(tbl, 2, 0, "Open", text_color = C_TXT, text_size = sz_lookup, bgcolor = C_HDR, tooltip = "Price at which the session opened. For a closed session this keeps the most recent session open.")
    table.cell(tbl, 3, 0, "Open Δ%", text_color = C_TXT, text_size = sz_lookup, bgcolor = C_HDR, tooltip = "Current price change from the session open, signed percent. Green above the open, red below.")
    if not intraday_ok
        table.cell(tbl, 0, 1, "Intraday timeframes only", text_color = color.new(#ffa726, 0), text_size = sz_lookup, bgcolor = C_R1)
        table.merge_cells(tbl, 0, 1, 3, 1)
    else if is_fx
        int r = 1
        if fx_show_pac
            f_row(r, "Pacific", fx_in_pac, f_status(fx_in_pac, fx_sess_pac, TZ_SYD), fxp_op, col_pac)
            r += 1
        if fx_show_asia
            f_row(r, "Asia", fx_in_asia, f_status(fx_in_asia, fx_sess_asia, TZ_TOK), fxa_op, col_asia)
            r += 1
        if fx_show_eur
            f_row(r, "Europe", fx_in_eur, f_status(fx_in_eur, fx_sess_eur, TZ_LDN), fxe_op, col_eur)
            r += 1
        if fx_show_usa
            f_row(r, "USA", fx_in_usa, f_status(fx_in_usa, fx_sess_usa, TZ_NYC), fxu_op, col_usa)
            r += 1
        if fx_show_eur and fx_show_usa and fx_overlap
            table.cell(tbl, 0, r, "Europe+USA overlap - peak liquidity", text_color = color.new(#ffa726, 0), text_size = sz_lookup, bgcolor = C_R1)
            table.merge_cells(tbl, 0, r, 3, r)
    else
        int r = 1
        if st_show_pac
            f_row(r, "Pacific", st_in_pac, f_status(st_in_pac, st_sess_pac, TZ_SYD), stp_op, col_pac)
            r += 1
        if st_show_asia
            f_row(r, "Asia", st_in_asia, f_status(st_in_asia, st_sess_asia, TZ_TOK), sta_op, col_asia)
            r += 1
        if st_show_eur
            f_row(r, "Europe", st_in_eur, f_status(st_in_eur, st_sess_eur, TZ_LDN), ste_op, col_eur)
            r += 1
        if st_show_usa
            f_row(r, "USA", st_in_usa, f_status(st_in_usa, st_sess_usa, TZ_NYC), stu_op, col_usa)
            r += 1

// =============================================================================
// ALERTS
// Session-edge events are computed in global scope and referenced here.
// =============================================================================

overlap_on = is_fx and fx_overlap and not fx_overlap[1]

alertcondition(fxp_start,  title = "FX Pacific open",          message = "Trading Sessions [EDGE]: FX Pacific session opened")
alertcondition(fxa_start,  title = "FX Asia open",             message = "Trading Sessions [EDGE]: FX Asia session opened")
alertcondition(fxe_start,  title = "FX Europe open",           message = "Trading Sessions [EDGE]: FX Europe session opened")
alertcondition(fxu_start,  title = "FX USA open",              message = "Trading Sessions [EDGE]: FX USA session opened")
alertcondition(fxe_end,    title = "FX Europe close",          message = "Trading Sessions [EDGE]: FX Europe session closed")
alertcondition(fxu_end,    title = "FX USA close",             message = "Trading Sessions [EDGE]: FX USA session closed")
alertcondition(overlap_on, title = "Europe+USA overlap start", message = "Trading Sessions [EDGE]: Europe/USA overlap started - peak liquidity window")
alertcondition(stp_start,  title = "Stocks Pacific open",      message = "Trading Sessions [EDGE]: Pacific cash session opened")
alertcondition(sta_start,  title = "Stocks Asia open",         message = "Trading Sessions [EDGE]: Asia cash session opened")
alertcondition(ste_start,  title = "Stocks Europe open",       message = "Trading Sessions [EDGE]: Europe cash session opened")
alertcondition(stu_start,  title = "Stocks USA open",          message = "Trading Sessions [EDGE]: USA cash session opened")
alertcondition(stu_end,    title = "Stocks USA close",         message = "Trading Sessions [EDGE]: USA cash session closed")
````

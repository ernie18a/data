# Custom Sessions [AtomicPips]

- url: https://www.tradingview.com/script/bbCYTfmk-Custom-Sessions-AtomicPips/
- type: indicator
- pine_id: PUB;c137e0ba326d41909f6ee27f94745484
- version: 1.0

## Description

[b]Overview[/b]
Custom Sessions is a flexible session-range visualization tool that lets you map up to eight fully independent trading sessions directly onto your chart. Each session draws its own range, body, and reference lines so you can study how price behaves during specific market windows such as London, New York, Tokyo, and Sydney — or any custom time block you define.

[b]Key Features[/b]
- 8 independent sessions — each with its own name, session time, and color. Sessions A–D are enabled by default (New York, London, Tokyo, Sydney); E–H are free slots for custom windows.
- Range box — plots the full high-to-low range of each session as a shaded zone with an optional dotted outline.
- Session body — an inner box spanning the open-to-close range, helping you distinguish the directional core of the session from its extremes (wicks).
- Open & Close lines — optional horizontal markers for each session's opening and closing price.
- Adaptive background — when enabled, each session is colored bullish or bearish based on whether price closed above or below the session open, instead of using the fixed session color.
- Timezone control — choose a manual UTC offset or follow the chart's exchange timezone, so sessions stay accurate across instruments.
- Historical sessions — display previous days' sessions (configurable days back) or keep the chart focused on the current day only.
- Status dashboard — an on-chart table showing which sessions are currently active or inactive.
- Session & daily dividers — optional vertical markers for session boundaries and day-of-week separators.

[b]How It Works[/b]
For every enabled session, the script tracks the session window using TradingView's session-time logic in your selected timezone. When a session opens, it records the opening price and begins tracking the running high and low. As each bar develops, the range box and body box are updated in real time to reflect the evolving high, low, and close. When the session ends, the range is finalized and (optionally) a close line is drawn at the session's last price.
Each session's drawings are stored and managed individually, and older sessions are automatically cleaned up based on your history setting to keep the chart efficient and uncluttered.

[b]Settings[/b]
- Session A–H — toggle, name, session time, color, and per-session Range / Open Line / Close Line options.
- Timezone — manual UTC offset or exchange timezone.
- History — show historical sessions and number of days back.
- Ranges Settings — wick/body transparency, body toggle, outline toggle, label toggle, and adaptive background colors.
- Dashboard — show/hide, location, and text size.
- Dividers — session dividers and daily dividers.

[b]How to Use[/b]
Add the indicator to any intraday timeframe. Configure each session's time to match the market windows you trade, and set your timezone so the boxes align correctly. Use the range box to identify session highs and lows that often act as intraday support/resistance, and use the body and open/close lines to gauge directional bias within each window. The adaptive background option provides a quick visual read of whether a session closed bullish or bearish.

[b]Notes[/b]
This indicator is a visualization and study tool. It does not generate buy or sell signals and makes no claim about future performance. Always combine it with your own analysis and risk management.

Original Indicator by : LuxAlgo (Big Thanks)

## Source Code

````pine
//@version=6
indicator('Custom Sessions [AtomicPips]', 'AtomicPips - Sessions', overlay = true, max_bars_back = 500, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

//─────────────────────────────────────────────────────────────────────────────
// USER-DEFINED TYPE
//─────────────────────────────────────────────────────────────────────────────
type SessionData
	int start_time = 0
	box bx = na
	box body_bx = na
	line ol = na
	line cl = na
	label lb = na

//─────────────────────────────────────────────────────────────────────────────
// SETTINGS
//─────────────────────────────────────────────────────────────────────────────
// Session A
show_sesa = input(true, '', inline = 'sesa', group = 'Session A')
sesa_txt = input('New York', '', inline = 'sesa', group = 'Session A')
sesa_ses = input.session('1300-2200', '', inline = 'sesa', group = 'Session A')
sesa_css = input.color(#ff5d00, '', inline = 'sesa', group = 'Session A')
sesa_range = input(true, 'Range', inline = 'sesa_o', group = 'Session A')
sesa_open_line = input(false, 'Open Line', inline = 'sesa_o', group = 'Session A')
sesa_close_line = input(false, 'Close Line', inline = 'sesa_o', group = 'Session A')

// Session B
show_sesb = input(true, '', inline = 'sesb', group = 'Session B')
sesb_txt = input('London', '', inline = 'sesb', group = 'Session B')
sesb_ses = input.session('0700-1600', '', inline = 'sesb', group = 'Session B')
sesb_css = input.color(#2157f3, '', inline = 'sesb', group = 'Session B')
sesb_range = input(true, 'Range', inline = 'sesb_o', group = 'Session B')
sesb_open_line = input(false, 'Open Line', inline = 'sesb_o', group = 'Session B')
sesb_close_line = input(false, 'Close Line', inline = 'sesb_o', group = 'Session B')

// Session C
show_sesc = input(true, '', inline = 'sesc', group = 'Session C')
sesc_txt = input('Tokyo', '', inline = 'sesc', group = 'Session C')
sesc_ses = input.session('0000-0900', '', inline = 'sesc', group = 'Session C')
sesc_css = input.color(#e91e63, '', inline = 'sesc', group = 'Session C')
sesc_range = input(true, 'Range', inline = 'sesc_o', group = 'Session C')
sesc_open_line = input(false, 'Open Line', inline = 'sesc_o', group = 'Session C')
sesc_close_line = input(false, 'Close Line', inline = 'sesc_o', group = 'Session C')

// Session D
show_sesd = input(true, '', inline = 'sesd', group = 'Session D')
sesd_txt = input('Sydney', '', inline = 'sesd', group = 'Session D')
sesd_ses = input.session('2100-0600', '', inline = 'sesd', group = 'Session D')
sesd_css = input.color(#ffeb3b, '', inline = 'sesd', group = 'Session D')
sesd_range = input(true, 'Range', inline = 'sesd_o', group = 'Session D')
sesd_open_line = input(false, 'Open Line', inline = 'sesd_o', group = 'Session D')
sesd_close_line = input(false, 'Close Line', inline = 'sesd_o', group = 'Session D')

// Session E
show_sese = input(false, '', inline = 'sese', group = 'Session E')
sese_txt = input('Session E', '', inline = 'sese', group = 'Session E')
sese_ses = input.session('0800-1700', '', inline = 'sese', group = 'Session E')
sese_css = input.color(#00bcd4, '', inline = 'sese', group = 'Session E')
sese_range = input(true, 'Range', inline = 'sese_o', group = 'Session E')
sese_open_line = input(false, 'Open Line', inline = 'sese_o', group = 'Session E')
sese_close_line = input(false, 'Close Line', inline = 'sese_o', group = 'Session E')

// Session F
show_sesf = input(false, '', inline = 'sesf', group = 'Session F')
sesf_txt = input('Session F', '', inline = 'sesf', group = 'Session F')
sesf_ses = input.session('1000-1900', '', inline = 'sesf', group = 'Session F')
sesf_css = input.color(#9c27b0, '', inline = 'sesf', group = 'Session F')
sesf_range = input(true, 'Range', inline = 'sesf_o', group = 'Session F')
sesf_open_line = input(false, 'Open Line', inline = 'sesf_o', group = 'Session F')
sesf_close_line = input(false, 'Close Line', inline = 'sesf_o', group = 'Session F')

// Session G
show_sesg = input(false, '', inline = 'sesg', group = 'Session G')
sesg_txt = input('Session G', '', inline = 'sesg', group = 'Session G')
sesg_ses = input.session('1200-2100', '', inline = 'sesg', group = 'Session G')
sesg_css = input.color(#4caf50, '', inline = 'sesg', group = 'Session G')
sesg_range = input(true, 'Range', inline = 'sesg_o', group = 'Session G')
sesg_open_line = input(false, 'Open Line', inline = 'sesg_o', group = 'Session G')
sesg_close_line = input(false, 'Close Line', inline = 'sesg_o', group = 'Session G')

// Session H
show_sesh = input(false, '', inline = 'sesh', group = 'Session H')
sesh_txt = input('Session H', '', inline = 'sesh', group = 'Session H')
sesh_ses = input.session('1500-0000', '', inline = 'sesh', group = 'Session H')
sesh_css = input.color(#ff9800, '', inline = 'sesh', group = 'Session H')
sesh_range = input(true, 'Range', inline = 'sesh_o', group = 'Session H')
sesh_open_line = input(false, 'Open Line', inline = 'sesh_o', group = 'Session H')
sesh_close_line = input(false, 'Close Line', inline = 'sesh_o', group = 'Session H')

// Timezone
tz_incr = input.int(0, 'UTC (+/-)', group = 'Timezone')
use_exchange = input(false, 'Use Exchange Timezone', group = 'Timezone')

// History
show_hist = input(false, 'Historical Sessions', group = 'History')
hist_days = input.int(3, 'Days Back', minval = 1, maxval = 30, group = 'History')

// Ranges
bg_transp = input.float(90, 'Wick Transparency', group = 'Ranges Settings')
show_body = input(true, 'Session Body (Open↔Close)', group = 'Ranges Settings')
body_transp = input.float(65, 'Body Transparency', group = 'Ranges Settings')
show_outline = input(true, 'Range Outline', group = 'Ranges Settings')
show_txt = input(true, 'Range Label', group = 'Ranges Settings')
// Adaptive background
adaptive_bg = input(false, 'Adaptive Background', inline = 'adaptive', group = 'Ranges Settings')
bull_css = input.color(#089981, '', inline = 'adaptive', group = 'Ranges Settings')
bear_css = input.color(#f23645, '', inline = 'adaptive', group = 'Ranges Settings')

// Dashboard
show_dash = input(false, 'Show Dashboard', group = 'Dashboard')
dash_loc = input.string('Top Right', 'Dashboard Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Dashboard')
text_size = input.string('Small', 'Dashboard Size', options = ['Tiny', 'Small', 'Normal'], group = 'Dashboard')

// Dividers
show_ses_div = input(false, 'Show Sessions Divider', group = 'Dividers')
show_day_div = input(true, 'Show Daily Divider', group = 'Dividers')

//─────────────────────────────────────────────────────────────────────────────
// SESSION DATA ARRAYS
//─────────────────────────────────────────────────────────────────────────────
var array<SessionData> a_data = array.new<SessionData>()
var array<SessionData> b_data = array.new<SessionData>()
var array<SessionData> c_data = array.new<SessionData>()
var array<SessionData> d_data = array.new<SessionData>()
var array<SessionData> e_data = array.new<SessionData>()
var array<SessionData> f_data = array.new<SessionData>()
var array<SessionData> g_data = array.new<SessionData>()
var array<SessionData> h_data = array.new<SessionData>()

//─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS
//─────────────────────────────────────────────────────────────────────────────
n = bar_index

get_range(session, name, css, show_range, do_open, do_close, data) =>
    var int sess_t = 0
    var int sess_bar = 0
    var float s_max = na
    var float s_min = na
    var float s_open = na
    var box curr_bx = na
    var box curr_bbx = na
    var line curr_ol = na
    var label curr_lb = na

    if session and not session[1]
        sess_t := time
        sess_bar := n
        s_max := high
        s_min := low
        s_open := open
        curr_bx := na
        curr_bbx := na
        curr_ol := na
        curr_lb := na

        eff = adaptive_bg ? close >= s_open ? bull_css : bear_css : css

        sd = SessionData.new(start_time = sess_t)

        if show_range
            curr_bx := box.new(n, s_max, n, s_min, bgcolor = color.new(eff, bg_transp), border_color = show_outline ? eff : na, border_style = line.style_dotted)
            sd.bx := curr_bx

            if show_body
                curr_bbx := box.new(n, math.max(s_open, close), n, math.min(s_open, close), bgcolor = color.new(eff, body_transp), border_color = na)
                sd.body_bx := curr_bbx
                sd.body_bx

            if show_txt
                curr_lb := label.new(sess_t, s_max, name, xloc = xloc.bar_time, textcolor = eff, style = label.style_label_down, color = color.new(color.white, 100), size = size.tiny)
                sd.lb := curr_lb
                sd.lb

        if do_open
            curr_ol := line.new(n, s_open, n, s_open, color = eff, width = 1, style = line.style_dashed)
            sd.ol := curr_ol
            sd.ol

        array.push(data, sd)
        int(na)

    else if session and session == session[1]
        s_max := math.max(high, s_max)
        s_min := math.min(low, s_min)

        eff = adaptive_bg ? close >= s_open ? bull_css : bear_css : css

        if not na(curr_bx)
            box.set_top(curr_bx, s_max)
            box.set_rightbottom(curr_bx, n, s_min)
            box.set_bgcolor(curr_bx, color.new(eff, bg_transp))
            if show_outline
                box.set_border_color(curr_bx, eff)

        if not na(curr_bbx)
            box.set_top(curr_bbx, math.max(s_open, close))
            box.set_rightbottom(curr_bbx, n, math.min(s_open, close))
            box.set_bgcolor(curr_bbx, color.new(eff, body_transp))

        if not na(curr_ol)
            line.set_x2(curr_ol, n)
            line.set_color(curr_ol, eff)

        if show_txt and not na(curr_lb)
            label.set_xy(curr_lb, int(math.avg(sess_t, time)), s_max)
            label.set_textcolor(curr_lb, eff)

        int(na)

    else if not session and session[1] and do_close and array.size(data) > 0
        eff = adaptive_bg ? close[1] >= s_open ? bull_css : bear_css : css
        sd = array.last(data)
        cl = line.new(sess_bar, close[1], n - 1, close[1], color = eff, width = 1, style = line.style_solid)
        sd.cl := cl
        int(na)

cleanup_session(data, thr) =>
    i = 0
    while i < array.size(data) - 1
        sd = array.get(data, i)
        if sd.start_time < thr
            if not na(sd.bx)
                box.delete(sd.bx)
            if not na(sd.body_bx)
                box.delete(sd.body_bx)
            if not na(sd.ol)
                line.delete(sd.ol)
            if not na(sd.cl)
                line.delete(sd.cl)
            if not na(sd.lb)
                label.delete(sd.lb)
            array.remove(data, i)
            i
        else
            i := i + 1
            i

//─────────────────────────────────────────────────────────────────────────────
// SESSION DETECTION
//─────────────────────────────────────────────────────────────────────────────
tf = timeframe.period

var tz = use_exchange ? syminfo.timezone : str.format('UTC{0}{1}', tz_incr >= 0 ? '+' : '-', math.abs(tz_incr))

is_sesa = not na(time(tf, sesa_ses, tz))
is_sesb = not na(time(tf, sesb_ses, tz))
is_sesc = not na(time(tf, sesc_ses, tz))
is_sesd = not na(time(tf, sesd_ses, tz))
is_sese = not na(time(tf, sese_ses, tz))
is_sesf = not na(time(tf, sesf_ses, tz))
is_sesg = not na(time(tf, sesg_ses, tz))
is_sesh = not na(time(tf, sesh_ses, tz))

//─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//─────────────────────────────────────────────────────────────────────────────
var table_position = dash_loc == 'Bottom Left' ? position.bottom_left : dash_loc == 'Top Right' ? position.top_right : position.bottom_right

var table_size = text_size == 'Tiny' ? size.tiny : text_size == 'Small' ? size.small : size.normal

var tb = table.new(table_position, 2, 9, bgcolor = #1e222d, border_color = #373a46, border_width = 1, frame_color = #373a46, frame_width = 1)

if barstate.isfirst and show_dash
    table.cell(tb, 0, 0, 'Sessions', text_color = color.white, text_size = table_size)
    table.merge_cells(tb, 0, 0, 1, 0)
    table.cell(tb, 0, 1, sesa_txt, text_color = sesa_css, text_size = table_size)
    table.cell(tb, 0, 2, sesb_txt, text_color = sesb_css, text_size = table_size)
    table.cell(tb, 0, 3, sesc_txt, text_color = sesc_css, text_size = table_size)
    table.cell(tb, 0, 4, sesd_txt, text_color = sesd_css, text_size = table_size)
    table.cell(tb, 0, 5, sese_txt, text_color = sese_css, text_size = table_size)
    table.cell(tb, 0, 6, sesf_txt, text_color = sesf_css, text_size = table_size)
    table.cell(tb, 0, 7, sesg_txt, text_color = sesg_css, text_size = table_size)
    table.cell(tb, 0, 8, sesh_txt, text_color = sesh_css, text_size = table_size)

if barstate.islast and show_dash
    table.cell(tb, 1, 1, is_sesa ? 'Active' : 'Inactive', bgcolor = is_sesa ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 2, is_sesb ? 'Active' : 'Inactive', bgcolor = is_sesb ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 3, is_sesc ? 'Active' : 'Inactive', bgcolor = is_sesc ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 4, is_sesd ? 'Active' : 'Inactive', bgcolor = is_sesd ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 5, is_sese ? 'Active' : 'Inactive', bgcolor = is_sese ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 6, is_sesf ? 'Active' : 'Inactive', bgcolor = is_sesf ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 7, is_sesg ? 'Active' : 'Inactive', bgcolor = is_sesg ? #089981 : #f23645, text_color = color.white, text_size = table_size)
    table.cell(tb, 1, 8, is_sesh ? 'Active' : 'Inactive', bgcolor = is_sesh ? #089981 : #f23645, text_color = color.white, text_size = table_size)

//─────────────────────────────────────────────────────────────────────────────
// DRAW SESSIONS
//─────────────────────────────────────────────────────────────────────────────
if show_sesa
    get_range(is_sesa, sesa_txt, sesa_css, sesa_range, sesa_open_line, sesa_close_line, a_data)
if show_sesb
    get_range(is_sesb, sesb_txt, sesb_css, sesb_range, sesb_open_line, sesb_close_line, b_data)
if show_sesc
    get_range(is_sesc, sesc_txt, sesc_css, sesc_range, sesc_open_line, sesc_close_line, c_data)
if show_sesd
    get_range(is_sesd, sesd_txt, sesd_css, sesd_range, sesd_open_line, sesd_close_line, d_data)
if show_sese
    get_range(is_sese, sese_txt, sese_css, sese_range, sese_open_line, sese_close_line, e_data)
if show_sesf
    get_range(is_sesf, sesf_txt, sesf_css, sesf_range, sesf_open_line, sesf_close_line, f_data)
if show_sesg
    get_range(is_sesg, sesg_txt, sesg_css, sesg_range, sesg_open_line, sesg_close_line, g_data)
if show_sesh
    get_range(is_sesh, sesh_txt, sesh_css, sesh_range, sesh_open_line, sesh_close_line, h_data)

//─────────────────────────────────────────────────────────────────────────────
// CLEANUP
//─────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    days_limit = show_hist ? hist_days : 1
    thr = time - days_limit * 86400000
    cleanup_session(a_data, thr)
    cleanup_session(b_data, thr)
    cleanup_session(c_data, thr)
    cleanup_session(d_data, thr)
    cleanup_session(e_data, thr)
    cleanup_session(f_data, thr)
    cleanup_session(g_data, thr)
    cleanup_session(h_data, thr)

//─────────────────────────────────────────────────────────────────────────────
// SESSION DIVIDERS
//─────────────────────────────────────────────────────────────────────────────
plotshape(is_sesa and show_ses_div and show_sesa, '·', shape.square, location.bottom, na, text = '.', textcolor = sesa_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesa != is_sesa[1] and show_ses_div and show_sesa, 'NYE', shape.labelup, location.bottom, na, text = '❚', textcolor = sesa_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesb and show_ses_div and show_sesb, '·', shape.labelup, location.bottom, na, text = '.', textcolor = sesb_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesb != is_sesb[1] and show_ses_div and show_sesb, 'LDN', shape.labelup, location.bottom, na, text = '❚', textcolor = sesb_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesc and show_ses_div and show_sesc, '·', shape.square, location.bottom, na, text = '.', textcolor = sesc_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesc != is_sesc[1] and show_ses_div and show_sesc, 'TYO', shape.labelup, location.bottom, na, text = '❚', textcolor = sesc_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesd and show_ses_div and show_sesd, '·', shape.labelup, location.bottom, na, text = '.', textcolor = sesd_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesd != is_sesd[1] and show_ses_div and show_sesd, 'SYD', shape.labelup, location.bottom, na, text = '❚', textcolor = sesd_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sese and show_ses_div and show_sese, '·', shape.square, location.bottom, na, text = '.', textcolor = sese_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sese != is_sese[1] and show_ses_div and show_sese, 'SE', shape.labelup, location.bottom, na, text = '❚', textcolor = sese_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesf and show_ses_div and show_sesf, '·', shape.square, location.bottom, na, text = '.', textcolor = sesf_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesf != is_sesf[1] and show_ses_div and show_sesf, 'SF', shape.labelup, location.bottom, na, text = '❚', textcolor = sesf_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesg and show_ses_div and show_sesg, '·', shape.square, location.bottom, na, text = '.', textcolor = sesg_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesg != is_sesg[1] and show_ses_div and show_sesg, 'SG', shape.labelup, location.bottom, na, text = '❚', textcolor = sesg_css, size = size.tiny, display = display.all - display.status_line, editable = false)

plotshape(is_sesh and show_ses_div and show_sesh, '·', shape.square, location.bottom, na, text = '.', textcolor = sesh_css, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(is_sesh != is_sesh[1] and show_ses_div and show_sesh, 'SH', shape.labelup, location.bottom, na, text = '❚', textcolor = sesh_css, size = size.tiny, display = display.all - display.status_line, editable = false)

//─────────────────────────────────────────────────────────────────────────────
// DAILY DIVIDERS
//─────────────────────────────────────────────────────────────────────────────
day = dayofweek

if day != day[1] and show_day_div
    line.new(n, close + syminfo.mintick, n, close - syminfo.mintick, color = color.gray, extend = extend.both, style = line.style_dashed)

plotshape(day != day[1] and day == 1 and show_day_div, 'Sunday', shape.labeldown, location.top, na, text = 'Sunday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 2 and show_day_div, 'Monday', shape.labeldown, location.top, na, text = 'Monday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 3 and show_day_div, 'Tuesday', shape.labeldown, location.top, na, text = 'Tuesday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 4 and show_day_div, 'Wednesday', shape.labeldown, location.top, na, text = 'Wednesday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 5 and show_day_div, 'Thursday', shape.labeldown, location.top, na, text = 'Thursday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 6 and show_day_div, 'Friday', shape.labeldown, location.top, na, text = 'Friday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
plotshape(day != day[1] and day == 7 and show_day_div, 'Saturday', shape.labeldown, location.top, na, text = 'Saturday', textcolor = color.gray, size = size.tiny, display = display.all - display.status_line, editable = false)
````

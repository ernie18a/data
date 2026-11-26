# Sphinx Sessions, Cycles & Liquidity

- url: https://www.tradingview.com/script/L1JrjI1g-Sphinx-Sessions-Cycles-Liquidity/
- type: indicator
- pine_id: PUB;5f981f52485e4fe7af2bcf99f366b39a
- version: 2.0

## Description

Sphinx Sessions, Cycles & Liquidity is a session and time-cycle framework for intraday index-futures analysis (ES, NQ, YM and their micros). It combines four things usually spread across separate indicators - a fractal cycle grid, session and higher-timeframe liquidity levels, macro-window markers, and an ATR-graded open-bias table - into one overlay built around the CME futures day. It is a context tool and does not issue buy or sell signals.

WHAT MAKES IT DIFFERENT
Most session tools shade Asia / London / New York as flat blocks. This script instead decomposes the day into a continuous 90-minute cycle grid anchored to 20:00 New York, then subdivides each 90-minute block into 30-minute and 10-minute sub-cycles drawn as nested boxes with graduated opacity. The result is a fractal view of intraday time: the current 90m cycle, which third of it you are in, and which 10m segment is active, all at once. Each cycle box closes one minute early, so cycles read as discrete units rather than one continuous wall of shading.
Everything is anchored to an 18:00 New York day reset (the CME futures open) rather than calendar midnight, so sessions, levels, and bias all reference the futures trading day.

The bias model is quantified rather than binary. Instead of only marking price above or below the 08:30 open, the table grades displacement from that open in multiples of the instrument's own daily ATR into equilibrium, caution, and extended zones, and raises a compression flag when the 08:30-09:30 range is unusually tight relative to ATR. This adapts across ES, NQ, and YM without manual point thresholds.

COMPONENTS
Cycle grid: Asia / London / NY / PM structure as nested 90m / 30m / 10m boxes. Renders on chart timeframes below 15 minutes.
Open lines: Midnight open and 08:30 NY open, independently styled and labeled.
Higher-timeframe levels: prior day, week, and month highs and lows (PDH/PDL, PWH/PWL, PMH/PML), persistent and updated on period roll.
Session liquidity: Asia and London highs and lows that grow live through their session and optionally mitigate (delete) on a close-through, leaving only unmitigated liquidity visible.

Macro windows: 09:40, 10:40, and 13:40 NY windows as bracketed zones.
1H fair value gaps: nearest unmitigated bullish and bearish 1H gaps relative to price.
08:30 bias table: direction, ATR-graded strength, zone, and compression flag.

HOW TO USE IT
Apply it to a sub-15-minute chart of an index-futures symbol. Use the cycle grid to locate yourself in the day's time structure, the session and higher-timeframe levels as liquidity targets, the macro windows for timing, and the 08:30 table for directional context relative to the session open. Every module toggles independently, so you can run the full framework or only the pieces you want.

HOW IT WORKS
Session and cycle boundaries are computed from New York clock time, with the 90-minute grid indexed from the 20:00 open and subdivided by integer division into 30m and 10m segments. Session and macro windows use native session detection so they stay correct from 1-minute up to 15-minute charts. Higher-timeframe levels and 1H fair value gaps are pulled from higher-timeframe data; completed values are fixed and current values develop with the forming bar. Key values (session open, session and cycle highs/lows, gate states, ATR distance) are exposed in the Data Window for use in alerts or other tools.

For education and market analysis only. This is not financial advice, and past behavior of any level or signal does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © your_tradingview_username
//
// Sphinx Sessions, Cycles & Liquidity   |   v2.6
//
// A session and cycle mapping tool for intraday index-futures analysis. It
// frames the trading day into an Asia / London / NY / PM structure drawn as a
// nested 90m / 30m / 10m cycle grid, tracks intraday liquidity (session and
// higher-timeframe highs and lows, 1H fair value gaps, macro windows), and
// grades price location relative to the 08:30 NY open using a daily-ATR
// distance table.
//
// Behaviour notes:
//   - The trading day resets at 18:00 NY (CME futures open).
//   - Cycle boxes render only on chart timeframes below 15 minutes.
//   - Session H/L lines grow live and mitigate on a close-through (optional).
//   - HTF levels (PDH/PDL/PWH/PWL/PMH/PML) and 1H fair value gaps are derived
//     from higher-timeframe data and update as the current HTF bar develops.
//   - Cycle boxes close one minute early by design, leaving a visual gap.
//
// For education and analysis only. This is not financial advice.
//@version=6
indicator('Sphinx Sessions, Cycles & Liquidity', shorttitle = 'Sphinx Sessions, Cycles & Liquidity', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================
// === INPUT GROUPS ===
// ============================================================
g_gen = 'General'
g_tog = 'Quick Toggle'
g_ol = 'Open Lines'
g_htf = 'HTF Levels'
g_sl = 'Session Levels'
g_mac = 'Macros'
g_cyc = 'Cycles'
g_tbl = '0830 Bias'
g_fvg = '1H Fair Value Gaps'

// ============================================================
// === QUICK TOGGLE ===
// ============================================================
tog_anc_today = input.bool(true, 'Open Lines - today only', group = g_tog, tooltip = 'When ON, only today\'s open lines are drawn.')
tog_mac_today = input.bool(true, 'Macro Windows - today only', group = g_tog, tooltip = 'When ON, only today\'s macro boxes are drawn.')
tog_fvg = input.bool(true, '1H FVGs - show', group = g_tog, tooltip = 'Show/hide the most recent 1H Fair Value Gap boxes.')

// ============================================================
// === GENERAL ===
// ============================================================
i_lookback = input.int(5, 'History (days)', group = g_gen, minval = 1, maxval = 60)
i_tz = input.string('America/New_York', 'Timezone', group = g_gen, options = ['America/New_York', 'America/Chicago', 'Europe/London', 'Europe/Berlin', 'Asia/Tokyo'])

// ============================================================
// === OPEN LINES ===
// ============================================================
show_midnight = input.bool(true, 'Midnight', group = g_ol, inline = 'mn')
col_midnight = input.color(#2748ac, '', group = g_ol, inline = 'mn')
lbl_midnight = input.string(defval = 'MN Open', title = '', group = g_ol, inline = 'mn')

show_session = input.bool(true, '0830', group = g_ol, inline = 'ses')
col_session = input.color(#089981, '', group = g_ol, inline = 'ses')
lbl_session = input.string(defval = '08:30', title = '', group = g_ol, inline = 'ses')

sess_midnight = input.session('0000-1700', '         Midnight    ', group = g_ol, inline = 'mn_s')
sess_session = input.session('0830-1700', '            0830        ', group = g_ol, inline = 'ses_s')

width_anc = input.int(1, 'Width', group = g_ol, inline = 'ext', minval = 1, maxval = 4)
sty_anc = input.string('Solid', 'Style', group = g_ol, inline = 'ext', options = ['Solid', 'Dashed', 'Dotted'])
extend_anc = input.string('EOD', 'Extend', group = g_ol, inline = 'ext', options = ['Extend', 'EOD'])
lbl_anc_pos = input.string('Right', 'Label placement', group = g_ol, options = ['Left', 'Middle', 'Right', 'None'])
lbl_anc_size = input.string('Small', 'Label size', group = g_ol, options = ['Tiny', 'Small', 'Normal'])
ext_anc = input.int(20, 'Right extension (bars)', group = g_ol, minval = 0, maxval = 500, tooltip = 'Extends open lines this many bars to the right of current price.')

// ============================================================
// === HTF LEVELS ===
// ============================================================
show_pd = input.bool(true, 'Daily  ', group = g_htf, inline = 'pd')
col_pd = input.color(#ff9800, '', group = g_htf, inline = 'pd')
lbl_pdh = input.string(defval = 'PDH', title = '', group = g_htf, inline = 'pd')
lbl_pdl = input.string(defval = 'PDL', title = '', group = g_htf, inline = 'pd')
sty_pd = input.string('Solid', '', group = g_htf, inline = 'pd', options = ['Solid', 'Dashed', 'Dotted'])

show_pw = input.bool(true, 'Weekly ', group = g_htf, inline = 'pw')
col_pw = input.color(#9c27b0, '', group = g_htf, inline = 'pw')
lbl_pwh = input.string(defval = 'PWH', title = '', group = g_htf, inline = 'pw')
lbl_pwl = input.string(defval = 'PWL', title = '', group = g_htf, inline = 'pw')
sty_pw = input.string('Solid', '', group = g_htf, inline = 'pw', options = ['Solid', 'Dashed', 'Dotted'])

show_pm = input.bool(true, 'Monthly', group = g_htf, inline = 'pm')
col_pm = input.color(#f44336, '', group = g_htf, inline = 'pm')
lbl_pmh = input.string(defval = 'PMH', title = '', group = g_htf, inline = 'pm')
lbl_pml = input.string(defval = 'PML', title = '', group = g_htf, inline = 'pm')
sty_pm = input.string('Solid', '', group = g_htf, inline = 'pm', options = ['Solid', 'Dashed', 'Dotted'])

width_htf = input.int(1, 'Width', group = g_htf, inline = 'hext', minval = 1, maxval = 4)
extend_htf = input.string('EOD', 'Extend', group = g_htf, inline = 'hext', options = ['Extend', 'EOD'])
lbl_htf_pos = input.string('Right', 'Label placement', group = g_htf, options = ['Left', 'Middle', 'Right', 'None'])
lbl_htf_size = input.string('Small', 'Label size', group = g_htf, options = ['Tiny', 'Small', 'Normal'])
ext_htf = input.int(20, 'Right extension (bars)', group = g_htf, minval = 0, maxval = 500, tooltip = 'Extends HTF level lines this many bars to the right of current price.')

// ============================================================
// === SESSION LEVELS ===
// ============================================================
show_asia_hl = input.bool(true, 'Asia H/L   ', group = g_sl, inline = 'sl_asia')
col_asia_sl = input.color(#607d8b, '', group = g_sl, inline = 'sl_asia')
lbl_asia_h = input.string(defval = 'Asia H', title = '', group = g_sl, inline = 'sl_asia')
lbl_asia_l = input.string(defval = 'Asia L', title = '', group = g_sl, inline = 'sl_asia')
mit_asia_hl = input.bool(true, 'Mitigate', group = g_sl, inline = 'sl_asia', tooltip = 'When ON, Asia H/L lines delete when price closes through them. When OFF, lines persist all day.')

show_lon_hl = input.bool(true, 'London H/L', group = g_sl, inline = 'sl_lon')
col_lon_sl = input.color(#3f51b5, '', group = g_sl, inline = 'sl_lon')
lbl_lon_h = input.string(defval = 'Lon H', title = '', group = g_sl, inline = 'sl_lon')
lbl_lon_l = input.string(defval = 'Lon L', title = '', group = g_sl, inline = 'sl_lon')
mit_lon_hl = input.bool(true, 'Mitigate', group = g_sl, inline = 'sl_lon', tooltip = 'When ON, London H/L lines delete when price closes through them. When OFF, lines persist all day.')

width_sl = input.int(1, 'Width  ', group = g_sl, inline = 'sl_ext', minval = 1, maxval = 4)
sty_sl = input.string('Dashed', 'Style', group = g_sl, inline = 'sl_ext', options = ['Solid', 'Dashed', 'Dotted'])
lbl_sl_pos = input.string('Right', 'Label placement', group = g_sl, options = ['Left', 'Center', 'Right', 'None'])
lbl_sl_size = input.string('Small', 'Label size', group = g_sl, options = ['Tiny', 'Small', 'Normal'])
ext_sl = input.int(20, 'Right extension (bars)', group = g_sl, minval = 0, maxval = 500, tooltip = 'Extends Asia/London H/L lines this many bars to the right of current price.')

// ============================================================
// === MACROS ===
// ============================================================
show_mac = input.bool(true, 'Show', group = g_mac, inline = 'mc')
show_mac_lbl = input.bool(true, 'Labels', group = g_mac, inline = 'mc')
col_mac = input.color(#089981, '', group = g_mac, inline = 'mc')

// ============================================================
// === CYCLES ===
// ============================================================
show_cycles = input.bool(true, 'Shading', group = g_cyc, inline = 'cy')
show_cyc_lbl = input.bool(true, 'Labels', group = g_cyc, inline = 'cy')
cyc_lbl_pos = input.string('Center', 'Position', group = g_cyc, inline = 'cy_lbl', options = ['Left', 'Center', 'Right'])
cyc_lbl_side = input.string('Outside', '', group = g_cyc, inline = 'cy_lbl', options = ['Inside', 'Outside'])
cyc_txt_size = input.string('Tiny', 'Size', group = g_cyc, inline = 'cy_lbl', options = ['Tiny', 'Small', 'Normal'])

col_asia_fill = input.color(color.new(#607d8b, 93), 'Asia', group = g_cyc, inline = 'cy_asia')
col_asia_border = input.color(color.new(#607d8b, 0), '', group = g_cyc, inline = 'cy_asia')
sty_asia_border = input.string('None', '', group = g_cyc, inline = 'cy_asia', options = ['None', 'Solid', 'Dashed', 'Dotted'])

col_lon_fill = input.color(color.new(#3f51b5, 93), 'London', group = g_cyc, inline = 'cy_lon')
col_lon_border = input.color(color.new(#3f51b5, 0), '', group = g_cyc, inline = 'cy_lon')
sty_lon_border = input.string('None', '', group = g_cyc, inline = 'cy_lon', options = ['None', 'Solid', 'Dashed', 'Dotted'])

col_ny_fill = input.color(color.new(#4caf50, 93), 'NY', group = g_cyc, inline = 'cy_ny')
col_ny_border = input.color(color.new(#4caf50, 0), '', group = g_cyc, inline = 'cy_ny')
sty_ny_border = input.string('None', '', group = g_cyc, inline = 'cy_ny', options = ['None', 'Solid', 'Dashed', 'Dotted'])

col_pm_fill = input.color(color.new(#ff9800, 93), 'PM', group = g_cyc, inline = 'cy_pm')
col_pm_border = input.color(color.new(#ff9800, 0), '', group = g_cyc, inline = 'cy_pm')
sty_pm_border = input.string('None', '', group = g_cyc, inline = 'cy_pm', options = ['None', 'Solid', 'Dashed', 'Dotted'])

g_sub = 'Sub-Cycles (30m / 10m)'
show_subcyc = input.bool(true, 'Show', group = g_sub, inline = 'sc_show')
sub_opacity = input.int(60, '30m Opacity', group = g_sub, inline = 'sc_show', minval = 0, maxval = 100)
sub15_opacity = input.int(80, '10m Opacity', group = g_sub, inline = 'sc_show', minval = 0, maxval = 100, tooltip = 'Opacity for 10m sub-cycle boxes. Higher = more transparent.')
sub_border_sty = input.string('None', '30m Border', group = g_sub, inline = 'sc_30b', options = ['None', 'Solid', 'Dashed', 'Dotted'])
sub_border_col = input.color(color.new(#ffffff, 50), '', group = g_sub, inline = 'sc_30b', tooltip = '30m border colour. Only applies when style is not None.')
sub15_border_sty = input.string('None', '10m Border', group = g_sub, inline = 'sc_15b', options = ['None', 'Solid', 'Dashed', 'Dotted'])
sub15_border_col = input.color(color.new(#ffffff, 70), '', group = g_sub, inline = 'sc_15b', tooltip = '10m border colour. Only applies when style is not None.')

// ============================================================
// === 1H FAIR VALUE GAPS ===
// ============================================================
col_fvg_bull = input.color(color.new(#089981, 90), 'Bullish', group = g_fvg, inline = 'fvg_c')
col_fvg_bear = input.color(color.new(#f44336, 90), 'Bearish', group = g_fvg, inline = 'fvg_c')
fvg_border_sty = input.string('None', 'Border Style', group = g_fvg, inline = 'fvg_b', options = ['None', 'Solid', 'Dashed', 'Dotted'])
fvg_border_w = input.int(1, '', group = g_fvg, inline = 'fvg_b', minval = 1, maxval = 4)

// ============================================================
// === 0830 BIAS ===
// ============================================================
// ATR zone thresholds - distance from 08:30 open graded by daily ATR(14).
// All three thresholds are adjustable to suit the instrument.
equil_atr_mult = input.float(0.10, 'Equilibrium  (~10pts ES)', group = g_tbl, tooltip = 'Within this ATR multiple of 08:30 = equilibrium. ~10pts on ES.', minval = 0.05, maxval = 0.5, step = 0.05)
tier1_atr_mult = input.float(0.40, 'Caution      (~40pts ES)', group = g_tbl, tooltip = 'Caution zone upper boundary. ~40pts on ES.', minval = 0.1, maxval = 1.0, step = 0.05)
tier2_atr_mult = input.float(0.70, 'Extended     (~70pts ES)', group = g_tbl, tooltip = 'Above this = extended/exhaustion watch. ~70pts on ES.', minval = 0.2, maxval = 3.0, step = 0.05)
show_htf_tbl = input.bool(true, 'Show', group = g_tbl, inline = 't1')
tbl_pos = input.string('Top Center', '', group = g_tbl, inline = 't1', options = ['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'])
tbl_width = input.float(5.0, 'Width %', group = g_tbl, inline = 't1', minval = 0.5, maxval = 50.0, step = 0.5)
tbl_height = input.float(2.0, 'Height %', group = g_tbl, inline = 't1', minval = 0.5, maxval = 25.0, step = 0.5)
col_tbl_hdr = input.color(color.new(#2e2e2e, 0), 'Header BG', group = g_tbl, inline = 't2')
col_tbl_bg = input.color(color.new(#d1d4dc, 92), 'Cell BG', group = g_tbl, inline = 't2')
col_tbl_hdr_txt = input.color(#dbdbdb, 'Hdr Text', group = g_tbl, inline = 't3')
col_tbl_txt = input.color(#2e2e2e, 'Body Text', group = g_tbl, inline = 't3')

// ============================================================
// === TIME UTILS ===
// ============================================================
nyHour(t) =>
    hour(t, i_tz)
nyMin(t) =>
    minute(t, i_tz)
oneBarMS = time_close - time
noColor = color.new(#ffffff, 100)
lbl_off = syminfo.mintick * 1
lbl_offset = lbl_off // alias used by HTF line function

_bsty(s) =>
    s == 'Solid' ? line.style_solid : s == 'Dashed' ? line.style_dashed : s == 'Dotted' ? line.style_dotted : line.style_solid

_lsize(s) =>
    s == 'Tiny' ? size.tiny : s == 'Normal' ? size.normal : size.small

// in_window: evaluates against time_close so bars are correctly
// classified on all timeframes up to 15m. A bar belongs to a session
// window if its last minute falls inside that window.
in_window(h1, m1, h2, m2) =>
    tc = time_close - 60000
    cur = hour(tc, i_tz) * 60 + minute(tc, i_tz)
    start = h1 * 60 + m1
    end_t = h2 * 60 + m2 < start ? h2 * 60 + m2 + 1440 : h2 * 60 + m2
    cur_adj = cur < start and end_t >= 1440 ? cur + 1440 : cur
    cur_adj >= start and cur_adj < end_t

// ============================================================
// === DAY RESET - 18:00 NY (futures open) ===
// ============================================================
// Native time() session match is timeframe-safe - works on 1m to 15m.
in_new_day_open = not na(time(timeframe.period, '1800-1802', i_tz))
is_day_reset = in_new_day_open and not in_new_day_open[1]

// ============================================================
// === 08:30 BIAS GATE ===
// ============================================================
var float open_830 = na
var float open_mn = na

if is_day_reset
    open_830 := na
    open_mn := na
    open_mn

in_mn_sess = not na(time(timeframe.period, sess_midnight, i_tz))
is_mn_start = in_mn_sess and not in_mn_sess[1]
if is_mn_start and na(open_mn)
    open_mn := open
    open_mn

in_ny_sess = not na(time(timeframe.period, sess_session, i_tz))
is_ny_start = in_ny_sess and not in_ny_sess[1]
if is_ny_start
    open_830 := open
    open_830

in_discount = not na(open_830) and close < open_830
in_premium = not na(open_830) and close > open_830
at_equil = not na(open_830) and close == open_830

// ============================================================
// === SESSION WINDOWS ===
// ============================================================
// Native time() session strings - correct on 1m through 15m.
// Asia   : 20:00-03:30 NY (split across midnight into two strings)
// London : 03:30-08:00 NY
in_asia_a = not na(time(timeframe.period, '2000-0000', i_tz))
in_asia_b = not na(time(timeframe.period, '0000-0330', i_tz))
in_asia = in_asia_a or in_asia_b
in_london = not na(time(timeframe.period, '0330-0800', i_tz))

is_asia_open = in_asia and not in_asia[1]
is_london_open = in_london and not in_london[1]

// ============================================================
// === ASIA H/L LIVE TRACKING ===
// ============================================================
var float asia_high = na
var float asia_low = na
var int asia_high_bar = 0
var int asia_low_bar = 0
var bool asia_ready = false

if is_day_reset
    asia_high := na
    asia_low := na
    asia_high_bar := 0
    asia_low_bar := 0
    asia_ready := false
    asia_ready

if in_asia
    asia_ready := true
    if na(asia_high) or high > asia_high
        asia_high := high
        asia_high_bar := bar_index
        asia_high_bar
    if na(asia_low) or low < asia_low
        asia_low := low
        asia_low_bar := bar_index
        asia_low_bar

// ============================================================
// === LONDON H/L LIVE TRACKING ===
// ============================================================
var float lon_high = na
var float lon_low = na
var int lon_high_bar = 0
var int lon_low_bar = 0
var bool lon_ready = false

if is_day_reset
    lon_high := na
    lon_low := na
    lon_high_bar := 0
    lon_low_bar := 0
    lon_ready := false
    lon_ready

if in_london
    lon_ready := true
    if na(lon_high) or high > lon_high
        lon_high := high
        lon_high_bar := bar_index
        lon_high_bar
    if na(lon_low) or low < lon_low
        lon_low := low
        lon_low_bar := bar_index
        lon_low_bar

// ============================================================
// === SESSION H/L LINE DRAWING - LIVE + MITIGATION ===
// ============================================================
// Asia lines   : appear from first Asia bar (20:00), grow live as new
//                extremes are made, persist through London and NY.
// London lines : appear from first London bar (03:30), grow live,
//                persist through NY.
// Mitigation   : close > high line -> high deleted (buyside taken)
//                close < low  line -> low  deleted (sellside taken)
// No redraw after mitigation within same trading day.
// HTF lines never mitigate - only update on period roll.

var line ln_asia_h = na
var label lb_asia_h = na
var line ln_asia_l = na
var label lb_asia_l = na
var line ln_lon_h = na
var label lb_lon_h = na
var line ln_lon_l = na
var label lb_lon_l = na

var bool asia_h_mit = false
var bool asia_l_mit = false
var bool lon_h_mit = false
var bool lon_l_mit = false

// Full day reset - clear all lines and flags
if is_day_reset
    asia_h_mit := false
    asia_l_mit := false
    lon_h_mit := false
    lon_l_mit := false
    if not na(ln_asia_h)
        ln_asia_h.delete()
        ln_asia_h := na
        ln_asia_h
    if not na(lb_asia_h)
        lb_asia_h.delete()
        lb_asia_h := na
        lb_asia_h
    if not na(ln_asia_l)
        ln_asia_l.delete()
        ln_asia_l := na
        ln_asia_l
    if not na(lb_asia_l)
        lb_asia_l.delete()
        lb_asia_l := na
        lb_asia_l
    if not na(ln_lon_h)
        ln_lon_h.delete()
        ln_lon_h := na
        ln_lon_h
    if not na(lb_lon_h)
        lb_lon_h.delete()
        lb_lon_h := na
        lb_lon_h
    if not na(ln_lon_l)
        ln_lon_l.delete()
        ln_lon_l := na
        ln_lon_l
    if not na(lb_lon_l)
        lb_lon_l.delete()
        lb_lon_l := na
        lb_lon_l

// Session level label helpers.
// Label style per placement:
//   Left   = label.style_label_right  (tag opens rightward from anchor bar)
//   Center = label.style_label_left   (tag opens rightward from midpoint)
//   Right  = label.style_label_left   (tag opens rightward from right edge)
//   None   = no label
// All labels sit exactly at price level - no vertical offset needed.
_sl_lx(anchor) =>
    lbl_sl_pos == 'Left' ? anchor : lbl_sl_pos == 'Center' ? math.round((anchor + bar_index + ext_sl) / 2) : bar_index + ext_sl

_sl_lsty() =>
    lbl_sl_pos == 'Left' ? label.style_label_right : label.style_label_left

_sl_new(price, anchor, c, txt) =>
    ln = line.new(anchor, price, bar_index + ext_sl, price, color = c, width = width_sl, style = _bsty(sty_sl))
    lb = lbl_sl_pos == 'None' ? label(na) : label.new(_sl_lx(anchor), price, txt, style = _sl_lsty(), textcolor = c, color = color.new(c, 100), size = _lsize(lbl_sl_size))
    [ln, lb]

// Extend an existing line to current bar; re-anchor if extreme bar moved
_sl_extend(ln, lb, price, anchor) =>
    if not na(ln)
        if ln.get_x1() != anchor
            ln.set_x1(anchor)
            ln.set_y1(price)
            ln.set_y2(price)
        ln.set_x2(bar_index + ext_sl)
    if not na(lb)
        lb.set_x(_sl_lx(ln.get_x1()))
        lb.set_y(price)

// -- ASIA LINES ----------------------------------------------
if show_asia_hl and asia_ready and not is_day_reset
    // Mitigation
    if mit_asia_hl and not asia_h_mit and not na(asia_high) and close > asia_high
        asia_h_mit := true
        if not na(ln_asia_h)
            ln_asia_h.delete()
            ln_asia_h := na
            ln_asia_h
        if not na(lb_asia_h)
            lb_asia_h.delete()
            lb_asia_h := na
            lb_asia_h
    if mit_asia_hl and not asia_l_mit and not na(asia_low) and close < asia_low
        asia_l_mit := true
        if not na(ln_asia_l)
            ln_asia_l.delete()
            ln_asia_l := na
            ln_asia_l
        if not na(lb_asia_l)
            lb_asia_l.delete()
            lb_asia_l := na
            lb_asia_l
    // Draw / extend high
    if not asia_h_mit and not na(asia_high)
        if na(ln_asia_h)
            [a, b] = _sl_new(asia_high, asia_high_bar, col_asia_sl, lbl_asia_h)
            ln_asia_h := a
            lb_asia_h := b
            lb_asia_h
        else
            _sl_extend(ln_asia_h, lb_asia_h, asia_high, asia_high_bar)
    // Draw / extend low
    if not asia_l_mit and not na(asia_low)
        if na(ln_asia_l)
            [a, b] = _sl_new(asia_low, asia_low_bar, col_asia_sl, lbl_asia_l)
            ln_asia_l := a
            lb_asia_l := b
            lb_asia_l
        else
            _sl_extend(ln_asia_l, lb_asia_l, asia_low, asia_low_bar)

// -- LONDON LINES ---------------------------------------------
if show_lon_hl and lon_ready and not is_day_reset
    // Mitigation
    if mit_lon_hl and not lon_h_mit and not na(lon_high) and close > lon_high
        lon_h_mit := true
        if not na(ln_lon_h)
            ln_lon_h.delete()
            ln_lon_h := na
            ln_lon_h
        if not na(lb_lon_h)
            lb_lon_h.delete()
            lb_lon_h := na
            lb_lon_h
    if mit_lon_hl and not lon_l_mit and not na(lon_low) and close < lon_low
        lon_l_mit := true
        if not na(ln_lon_l)
            ln_lon_l.delete()
            ln_lon_l := na
            ln_lon_l
        if not na(lb_lon_l)
            lb_lon_l.delete()
            lb_lon_l := na
            lb_lon_l
    // Draw / extend high
    if not lon_h_mit and not na(lon_high)
        if na(ln_lon_h)
            [a, b] = _sl_new(lon_high, lon_high_bar, col_lon_sl, lbl_lon_h)
            ln_lon_h := a
            lb_lon_h := b
            lb_lon_h
        else
            _sl_extend(ln_lon_h, lb_lon_h, lon_high, lon_high_bar)
    // Draw / extend low
    if not lon_l_mit and not na(lon_low)
        if na(ln_lon_l)
            [a, b] = _sl_new(lon_low, lon_low_bar, col_lon_sl, lbl_lon_l)
            ln_lon_l := a
            lb_lon_l := b
            lb_lon_l
        else
            _sl_extend(ln_lon_l, lb_lon_l, lon_low, lon_low_bar)

// ============================================================
// === SWEEP DETECTION ===
// ============================================================
var float cyc_high_t2 = na
var float cyc_low_t2 = na

swept_asia_low = not na(asia_low) and low < asia_low and close > asia_low
swept_lon_low = not na(lon_low) and low < lon_low and close > lon_low
swept_cyc_low = not na(cyc_low_t2) and low < cyc_low_t2 and close > cyc_low_t2

swept_asia_high = not na(asia_high) and high > asia_high and close < asia_high
swept_lon_high = not na(lon_high) and high > lon_high and close < lon_high
swept_cyc_high = not na(cyc_high_t2) and high > cyc_high_t2 and close < cyc_high_t2

var bool sellside_taken = false
var bool buyside_taken = false

if is_day_reset
    sellside_taken := false
    buyside_taken := false
    buyside_taken

if swept_asia_low or swept_lon_low or swept_cyc_low
    sellside_taken := true
    sellside_taken
if swept_asia_high or swept_lon_high or swept_cyc_high
    buyside_taken := true
    buyside_taken

// ============================================================
// === LONG / SHORT VALIDITY GATES ===
// ============================================================
long_gate = in_discount and sellside_taken
short_gate = in_premium and buyside_taken

// ============================================================
// === EQUILIBRIUM / CHOP FILTER ===
// ============================================================
var float am_high = na
var float am_low = na
var bool am_bull_swept = false
var bool am_bear_swept = false

in_am_range = in_window(8, 30, 9, 30)
is_am_start = in_am_range and not in_am_range[1]

if is_day_reset
    am_high := na
    am_low := na
    am_bull_swept := false
    am_bear_swept := false
    am_bear_swept

if is_am_start
    am_high := high
    am_low := low
    am_low
else if in_am_range
    am_high := na(am_high) ? high : math.max(am_high, high)
    am_low := na(am_low) ? low : math.min(am_low, low)
    am_low

if not in_am_range and not na(am_high) and not na(am_low) and not na(open_830)
    if high > am_high and close < am_high
        am_bull_swept := true
        am_bull_swept
    if low < am_low and close > am_low
        am_bear_swept := true
        am_bear_swept

// Daily ATR(14) - reference range for bias grading
atr_daily = request.security(syminfo.tickerid, 'D', ta.atr(14), lookahead = barmerge.lookahead_off)
am_range = not na(am_high) and not na(am_low) ? am_high - am_low : float(na)

// Equilibrium: AM range too compressed vs daily ATR
equilibrium_mode = not na(am_range) and not na(atr_daily) and am_range < atr_daily * equil_atr_mult
no_trade_env = equilibrium_mode

// ATR distance from 08:30 open - drives bias tier grading
atr_dist = not na(open_830) and not na(atr_daily) and atr_daily > 0 ? math.abs(close - open_830) / atr_daily : float(na)

// Bias tier (0=equil, 1=weak, 2=moderate, 3=extended)
bias_tier = not na(atr_dist) ? atr_dist < equil_atr_mult ? 0 : atr_dist < tier1_atr_mult ? 1 : atr_dist < tier2_atr_mult ? 2 : 3 : 0

// ============================================================
// === MACRO WINDOWS ===
// ============================================================
in_macro_940 = in_window(9, 40, 10, 15) // Macro 1: 09:40 - 10:15
in_macro_1040 = in_window(10, 40, 11, 15) // Macro 2: 10:40 - 11:15
in_macro_1340 = in_window(13, 40, 14, 15) // Macro 3: 13:40 - 14:15
in_any_macro = in_macro_940 or in_macro_1040 or in_macro_1340

var array<line> MAC_LINES = array.new_line()
var array<label> MAC_LBLS = array.new_label()
_yRef = ta.highest(high, math.max(1, math.round(timeframe.in_seconds('15') / timeframe.in_seconds(timeframe.period)))) + syminfo.mintick * 15
_yTop = _yRef + syminfo.mintick * 8

_macHandler(txt, in_mac) =>
    is_start = in_mac and not in_mac[1]
    is_end = not in_mac and in_mac[1]
    if is_start
        MAC_LINES.push(line.new(time, _yRef, time, _yTop, xloc = xloc.bar_time, color = col_mac, width = 1))
        MAC_LINES.push(line.new(time, _yTop, time + oneBarMS, _yTop, xloc = xloc.bar_time, color = col_mac, width = 1))
        if show_mac_lbl
            MAC_LBLS.push(label.new(time, _yTop + lbl_off, txt, xloc = xloc.bar_time, style = label.style_none, textcolor = col_mac, size = size.small))
    if in_mac and MAC_LINES.size() >= 2
        h = MAC_LINES.last()
        h.set_x2(time + oneBarMS)
        if MAC_LBLS.size() > 0
            MAC_LBLS.last().set_x(math.round(math.avg(MAC_LINES.get(MAC_LINES.size() - 2).get_x1(), time)))
        if _yTop > h.get_y2()
            h.set_y1(_yTop)
            h.set_y2(_yTop)
            MAC_LINES.get(MAC_LINES.size() - 2).set_y2(_yTop)
            if MAC_LBLS.size() > 0
                MAC_LBLS.last().set_y(_yTop + lbl_off)
    if is_end and MAC_LINES.size() >= 2
        MAC_LINES.push(line.new(time, _yRef, time, MAC_LINES.get(MAC_LINES.size() - 2).get_y2(), xloc = xloc.bar_time, color = col_mac, width = 1))

if show_mac
    _macHandler('MACRO 09:40', in_macro_940)
    _macHandler('MACRO 10:40', in_macro_1040)
    _macHandler('MACRO 13:40', in_macro_1340)

max_mac_boxes = tog_mac_today ? 3 : i_lookback * 3
max_mac_lines = max_mac_boxes * 3
while MAC_LINES.size() > max_mac_lines
    line.delete(array.shift(MAC_LINES))
while MAC_LBLS.size() > max_mac_boxes
    label.delete(array.shift(MAC_LBLS))

// ============================================================
// === ANCHOR LEVELS (Midnight / NY Open) ===
// ============================================================
// Open line label helpers
_anc_lsz() =>
    lbl_anc_size == 'Tiny' ? size.tiny : lbl_anc_size == 'Normal' ? size.normal : size.small
_anc_lshow(txt) =>
    lbl_anc_pos == 'None' ? '' : txt
_anc_lx(bi, bi_end) =>
    lbl_anc_pos == 'Left' ? bi : lbl_anc_pos == 'Middle' ? math.round((bi + bi_end) / 2) : bi_end

plot_open_line(show, sess, txt, c, ln_arr, lb_arr) =>
    in_sess = not na(time(timeframe.period, sess, i_tz))
    is_start = in_sess and not in_sess[1]
    is_end = not in_sess and in_sess[1]
    if show
        if is_start
            if array.size(ln_arr) > 0 and extend_anc == 'Extend'
                line.set_x2(array.last(ln_arr), bar_index)
            _ext = extend_anc == 'Extend' ? extend.right : extend.none
            _lsty = _bsty(sty_anc)
            array.push(ln_arr, line.new(bar_index, open, bar_index + ext_anc, open, color = c, width = width_anc, style = _lsty, extend = _ext))
            _anc_start = bar_index
            array.push(lb_arr, label.new(_anc_lx(_anc_start, bar_index + ext_anc), open + lbl_off, _anc_lshow(txt), style = label.style_none, textcolor = c, size = _anc_lsz()))
            max_lines = tog_anc_today ? 1 : i_lookback
            while array.size(ln_arr) > max_lines
                line.delete(array.shift(ln_arr))
                label.delete(array.shift(lb_arr))
        else if in_sess and extend_anc == 'EOD' and array.size(ln_arr) > 0
            line.set_x2(array.last(ln_arr), bar_index + ext_anc)
            _anc_s = array.last(ln_arr).get_x1()
            label.set_x(array.last(lb_arr), _anc_lx(_anc_s, bar_index + ext_anc))
        // After session ends - keep extending to current bar so EOD line stays visible
        else if not in_sess and extend_anc == 'EOD' and array.size(ln_arr) > 0 and not is_start
            line.set_x2(array.last(ln_arr), bar_index + ext_anc)
            _anc_s = array.last(ln_arr).get_x1()
            label.set_x(array.last(lb_arr), _anc_lx(_anc_s, bar_index + ext_anc))

var mn_lines = array.new_line()
var mn_lbls = array.new_label()
var se_lines = array.new_line()
var se_lbls = array.new_label()
plot_open_line(show_midnight, sess_midnight, lbl_midnight, col_midnight, mn_lines, mn_lbls)
plot_open_line(show_session, sess_session, lbl_session, col_session, se_lines, se_lbls)

// ============================================================
// === CYCLES & SUB-CYCLES (90M GRID) ===
// ============================================================
// Asia = single session box (20:00-03:30). No 90m sub-divisions.
// London / NY / PM = 90m blocks with 30m and 10m sub-cycles.
//
// CYCLE GAP: each box closes 1 minute early to create a visual gap.
//   90m block : right edge stops at minute 89  (gap at minute 89)
//   30m sub   : right edge stops at minute 29  (gap at minute 29)
//   10m subsub: right edge stops at minute 9   (gap at minute 9)
//
// block_idx/sub_idx/subsub_idx still increment at clean boundaries -
// the gap just suppresses RIGHT-EDGE extension during the final minute.
//
// v2.4 FIX: top/bottom edges still update during the gap minute so wicks
// made on the cycle's final bar are captured in the box height. Only the
// right-edge extension is gated by the *_active flags.
//
// v2.6 CHANGE: innermost sub-cycle is now 10m. subsub_idx counts
// 0..2 within each 30m sub; gap minute is now minute 9.

int h_ny = nyHour(time)
int m_ny = nyMin(time)
int mins_from_2000 = h_ny >= 20 ? (h_ny - 20) * 60 + m_ny : h_ny < 17 ? (h_ny + 4) * 60 + m_ny : na

int block_idx = not na(mins_from_2000) ? math.floor(mins_from_2000 / 90) : na
int mins_into_block = not na(mins_from_2000) ? mins_from_2000 % 90 : na
int sub_idx = not na(mins_into_block) ? math.floor(mins_into_block / 30) : na
int mins_into_sub = not na(mins_into_block) ? mins_into_block % 30 : na
int subsub_idx = not na(mins_into_sub) ? math.floor(mins_into_sub / 10) : na
int mins_into_subsub = not na(mins_into_sub) ? mins_into_sub % 10 : na

// Gap flags - true during the active drawing window (not in the gap minute)
bool block_active = not na(mins_into_block) and mins_into_block < 89
bool sub_active = not na(mins_into_sub) and mins_into_sub < 29
bool subsub_active = not na(mins_into_subsub) and mins_into_subsub < 9

bool in_asia_cyc = not na(block_idx) and block_idx <= 4

get_cyc_props(idx) =>
    string name = ''
    color c = na
    color bc = na
    string bs = ''
    if idx <= 4
        name := 'Asia'
        c := col_asia_fill
        bc := col_asia_border
        bs := sty_asia_border
        bs
    else if idx <= 7
        name := idx == 5 ? 'Lon-A' : idx == 6 ? 'Lon-B' : 'Lon-C'
        c := col_lon_fill
        bc := col_lon_border
        bs := sty_lon_border
        bs
    else if idx <= 10
        name := idx == 8 ? 'NY-A' : idx == 9 ? 'NY-B' : 'NY-C'
        c := col_ny_fill
        bc := col_ny_border
        bs := sty_ny_border
        bs
    else if idx <= 13
        name := idx == 11 ? 'PM-A' : idx == 12 ? 'PM-B' : 'PM-C'
        c := col_pm_fill
        bc := col_pm_border
        bs := sty_pm_border
        bs
    [name, c, bc, bs]

var int active_block = -1
var int active_sub = -1
var int active_subsub = -1
var float cyc_high_90 = na
var float cyc_low_90 = na
var float sub_high = na
var float sub_low = na
var float subsub_high = na
var float subsub_low = na
var box main_box = na
var label cyc_label = na
var array<box> sub_boxes = array.new_box()
var array<box> subsub_boxes = array.new_box()
var array<box> TRASH_B = array.new_box()
var array<label> TRASH_L = array.new_label()

var box asia_sess_box = na
var label asia_sess_label = na
var float asia_box_high = na
var float asia_box_low = na

_th = cyc_lbl_pos == 'Center' ? text.align_center : cyc_lbl_pos == 'Right' ? text.align_right : text.align_left
_ts = cyc_txt_size == 'Small' ? size.small : cyc_txt_size == 'Normal' ? size.normal : size.tiny
_ls = cyc_lbl_pos == 'Right' ? label.style_label_lower_right : label.style_label_lower_left
_tf_ok = timeframe.in_seconds() < 900

if (show_cycles or show_subcyc) and _tf_ok
    is_new_block = block_idx != active_block and not na(block_idx)
    is_new_sub = sub_idx != active_sub and not na(sub_idx)
    is_new_subsub = subsub_idx != active_subsub and not na(subsub_idx)

    // -- ASIA: single session box ------------------------------
    if in_asia_cyc
        if is_asia_open
            asia_box_high := high
            asia_box_low := low
            if not na(asia_sess_box)
                asia_sess_box.delete()
            if not na(asia_sess_label)
                asia_sess_label.delete()
            [c_name, c_col, c_bcol, c_bsty] = get_cyc_props(0)
            _bc = c_bsty == 'None' ? color.new(c_bcol, 100) : c_bcol
            _txt = show_cyc_lbl and cyc_lbl_side == 'Inside' ? c_name : ''
            if show_cycles
                asia_sess_box := box.new(bar_index, asia_box_high, bar_index + 1, asia_box_low, bgcolor = c_col, border_color = _bc, border_style = _bsty(c_bsty), text = _txt, text_size = _ts, text_color = color.new(c_col, 10), text_halign = _th, text_valign = text.align_top)
                TRASH_B.push(asia_sess_box)
                if show_cyc_lbl and cyc_lbl_side == 'Outside'
                    asia_sess_label := label.new(bar_index, high, c_name, style = _ls, textcolor = color.new(c_col, 10), color = noColor, size = _ts)
                    TRASH_L.push(asia_sess_label)
        else if not na(asia_sess_box)
            asia_box_high := math.max(asia_box_high, high)
            asia_box_low := math.min(asia_box_low, low)
            asia_sess_box.set_top(asia_box_high)
            asia_sess_box.set_bottom(asia_box_low)
            asia_sess_box.set_right(bar_index + 1)
            if not na(asia_sess_label)
                _lx = cyc_lbl_pos == 'Right' ? bar_index : cyc_lbl_pos == 'Center' ? math.round((asia_sess_box.get_left() + bar_index) / 2) - 1 : asia_sess_box.get_left()
                asia_sess_label.set_x(_lx)
                asia_sess_label.set_y(asia_box_high)
        active_block := block_idx
        active_sub := sub_idx
        active_subsub := subsub_idx
        active_subsub

    // -- LONDON / NY / PM: 90m + sub-cycles with gap -----------
    else
        if is_new_block
            active_block := block_idx
            active_sub := sub_idx
            active_subsub := subsub_idx
            cyc_high_90 := high
            cyc_low_90 := low
            sub_high := high
            sub_low := low
            subsub_high := high
            subsub_low := low
            cyc_high_t2 := high
            cyc_low_t2 := low
            sub_boxes.clear()
            while subsub_boxes.size() > 0
                box.delete(subsub_boxes.shift())
            subsub_boxes.clear()
            [c_name, c_col, c_bcol, c_bsty] = get_cyc_props(block_idx)
            _bc = c_bsty == 'None' ? color.new(c_bcol, 100) : c_bcol
            _txt = show_cyc_lbl and cyc_lbl_side == 'Inside' ? c_name : ''
            // Only open the main box if we are not in the gap minute
            if show_cycles and block_active
                main_box := box.new(bar_index, cyc_high_90, bar_index + 1, cyc_low_90, bgcolor = c_col, border_color = _bc, border_style = _bsty(c_bsty), text = _txt, text_size = _ts, text_color = color.new(c_col, 10), text_halign = _th, text_valign = text.align_top)
                TRASH_B.push(main_box)
                if show_cyc_lbl and cyc_lbl_side == 'Outside'
                    cyc_label := label.new(bar_index, high, c_name, style = _ls, textcolor = color.new(c_col, 10), color = noColor, size = _ts)
                    TRASH_L.push(cyc_label)
                else
                    cyc_label := na
                    cyc_label
            if show_subcyc and block_active and sub_active
                _sbc = sub_border_sty == 'None' ? color.new(c_col, 100) : sub_border_col
                _sbc15 = sub15_border_sty == 'None' ? color.new(c_col, 100) : sub15_border_col
                s_box = box.new(bar_index, cyc_high_90, bar_index + 1, cyc_low_90, bgcolor = color.new(c_col, sub_opacity), border_color = _sbc, border_style = _bsty(sub_border_sty))
                sub_boxes.push(s_box)
                TRASH_B.push(s_box)
                _s15_transp = sub15_opacity
                if subsub_active
                    s15_box = box.new(bar_index, cyc_high_90, bar_index + 1, cyc_low_90, bgcolor = color.new(c_col, _s15_transp), border_color = _sbc15, border_style = _bsty(sub15_border_sty))
                    subsub_boxes.push(s15_box)

        else if not na(block_idx)
            cyc_high_90 := math.max(cyc_high_90, high)
            cyc_low_90 := math.min(cyc_low_90, low)
            sub_high := math.max(sub_high, high)
            sub_low := math.min(sub_low, low)
            subsub_high := math.max(subsub_high, high)
            subsub_low := math.min(subsub_low, low)
            cyc_high_t2 := math.max(cyc_high_t2, high)
            cyc_low_t2 := math.min(cyc_low_t2, low)
            [c_name, c_col, c_bcol, c_bsty] = get_cyc_props(block_idx)

            if show_subcyc and is_new_sub
                active_sub := sub_idx
                active_subsub := subsub_idx
                sub_high := high
                sub_low := low
                subsub_high := high
                subsub_low := low
                if sub_active
                    _transp = sub_opacity
                    _sbc = sub_border_sty == 'None' ? color.new(c_col, 100) : sub_border_col
                    _sbc15 = sub15_border_sty == 'None' ? color.new(c_col, 100) : sub15_border_col
                    s_box = box.new(bar_index, high, bar_index + 1, low, bgcolor = color.new(c_col, _transp), border_color = _sbc, border_style = _bsty(sub_border_sty))
                    sub_boxes.push(s_box)
                    TRASH_B.push(s_box)
                    if subsub_active
                        _s15_transp = sub15_opacity
                        s15_box = box.new(bar_index, high, bar_index + 1, low, bgcolor = color.new(c_col, _s15_transp), border_color = _sbc15, border_style = _bsty(sub15_border_sty))
                        subsub_boxes.push(s15_box)

            else if show_subcyc and is_new_subsub
                active_subsub := subsub_idx
                subsub_high := high
                subsub_low := low
                if subsub_active
                    _sbc15 = sub15_border_sty == 'None' ? color.new(c_col, 100) : sub15_border_col
                    _s15_transp = sub15_opacity
                    s15_box = box.new(bar_index, high, bar_index + 1, low, bgcolor = color.new(c_col, _s15_transp), border_color = _sbc15, border_style = _bsty(sub15_border_sty))
                    subsub_boxes.push(s15_box)

            // FIX v2.4: Top/bottom edges update every bar to capture wicks
            // made during the gap minute. Only the right-edge extension is
            // gated by *_active flags - that's what creates the visual gap.
            // Previously top/bottom were also gated, causing the box to
            // miss the final bar's wick if that wick set a new high/low.
            if show_cycles and not na(main_box)
                main_box.set_top(cyc_high_90)
                main_box.set_bottom(cyc_low_90)
                if block_active
                    main_box.set_right(bar_index + 1)
                if not na(cyc_label)
                    _lx = cyc_lbl_pos == 'Right' ? bar_index : cyc_lbl_pos == 'Center' ? math.round((main_box.get_left() + bar_index) / 2) - 1 : main_box.get_left()
                    cyc_label.set_x(_lx)
                    cyc_label.set_y(cyc_high_90)
            if show_subcyc and sub_boxes.size() > 0
                sub_boxes.last().set_top(sub_high)
                sub_boxes.last().set_bottom(sub_low)
                if sub_active
                    sub_boxes.last().set_right(bar_index + 1)
            if show_subcyc and subsub_boxes.size() > 0
                subsub_boxes.last().set_top(subsub_high)
                subsub_boxes.last().set_bottom(subsub_low)
                if subsub_active
                    subsub_boxes.last().set_right(bar_index + 1)

else if na(block_idx)
    active_block := -1
    active_sub := -1
    active_subsub := -1
    active_subsub

max_cyc_boxes = math.min(i_lookback * 60, 500)
max_cyc_lbls = math.min(i_lookback * 15, 500)
while TRASH_B.size() > max_cyc_boxes
    box.delete(array.shift(TRASH_B))
while TRASH_L.size() > max_cyc_lbls
    label.delete(array.shift(TRASH_L))

// ============================================================
// === HTF LEVELS ===
// ============================================================
[pdh, pdl] = request.security(syminfo.tickerid, 'D', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, 'M', [high[1], low[1]], lookahead = barmerge.lookahead_on)

var line ln_pdh = na
var line ln_pdl = na
var line ln_pwh = na
var line ln_pwl = na
var line ln_pmh = na
var line ln_pml = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na
var label lb_pmh = na
var label lb_pml = na

// HTF label size/position helpers
_htf_lsz() =>
    lbl_htf_size == 'Tiny' ? size.tiny : lbl_htf_size == 'Normal' ? size.normal : size.small
_htf_lx(bi, bi_start) =>
    lbl_htf_pos == 'Left' ? bi_start : lbl_htf_pos == 'Middle' ? math.round((bi_start + bar_index + ext_htf) / 2) : bar_index + ext_htf
_htf_lshow(txt) =>
    lbl_htf_pos == 'None' ? '' : txt

_htfLine(ln, lb, price, c, txt, sty) =>
    lo = ln
    lo2 = lb
    if na(ln) or ln.get_y1() != price
        if not na(ln)
            ln.delete()
        if not na(lb)
            lb.delete()
        _ext = extend_htf == 'Extend' ? extend.right : extend.none
        _lsty = _bsty(sty)
        lo := line.new(bar_index, price, bar_index + ext_htf, price, color = c, width = width_htf, style = _lsty, extend = _ext)
        lo2 := label.new(_htf_lx(bar_index + 1, bar_index), price + lbl_offset, _htf_lshow(txt), style = label.style_none, textcolor = c, size = _htf_lsz())
        lo2
    lo.set_x2(bar_index + ext_htf)
    lo2.set_x(_htf_lx(bar_index + ext_htf, lo.get_x1()))
    [lo, lo2]

if show_pd
    [a, b] = _htfLine(ln_pdh, lb_pdh, pdh, col_pd, lbl_pdh, sty_pd)
    ln_pdh := a
    lb_pdh := b
    [c, d] = _htfLine(ln_pdl, lb_pdl, pdl, col_pd, lbl_pdl, sty_pd)
    ln_pdl := c
    lb_pdl := d
    lb_pdl
if show_pw
    [a, b] = _htfLine(ln_pwh, lb_pwh, pwh, col_pw, lbl_pwh, sty_pw)
    ln_pwh := a
    lb_pwh := b
    [c, d] = _htfLine(ln_pwl, lb_pwl, pwl, col_pw, lbl_pwl, sty_pw)
    ln_pwl := c
    lb_pwl := d
    lb_pwl
if show_pm
    [a, b] = _htfLine(ln_pmh, lb_pmh, pmh, col_pm, lbl_pmh, sty_pm)
    ln_pmh := a
    lb_pmh := b
    [c, d] = _htfLine(ln_pml, lb_pml, pml, col_pm, lbl_pml, sty_pm)
    ln_pml := c
    lb_pml := d
    lb_pml

// ============================================================
// === 1H FAIR VALUE GAPS ===
// ============================================================
_h1_fvg() =>
    var array<float> b_tops = array.new_float()
    var array<float> b_bots = array.new_float()
    var array<int> b_ts = array.new_int()
    var array<float> r_tops = array.new_float()
    var array<float> r_bots = array.new_float()
    var array<int> r_ts = array.new_int()
    is_new_day_fvg = dayofmonth(time) != dayofmonth(time[1])
    if is_new_day_fvg ? high[1] < low[0] : high[2] < low[0]
        b_tops.push(low[0])
        b_bots.push(is_new_day_fvg ? high[1] : high[2])
        b_ts.push(is_new_day_fvg ? time[1] : time[2])
        if b_tops.size() > 20
            b_tops.shift()
            b_bots.shift()
            b_ts.shift()
    if is_new_day_fvg ? low[1] > high[0] : low[2] > high[0]
        r_tops.push(is_new_day_fvg ? low[1] : low[2])
        r_bots.push(high[0])
        r_ts.push(is_new_day_fvg ? time[1] : time[2])
        if r_tops.size() > 20
            r_tops.shift()
            r_bots.shift()
            r_ts.shift()
    float sel_b_top = float(na)
    float sel_b_bot = float(na)
    int sel_b_t = int(na)
    if b_tops.size() > 0
        for i = b_tops.size() - 1 to 0 by 1
            if b_tops.get(i) < close
                sel_b_top := b_tops.get(i)
                sel_b_bot := b_bots.get(i)
                sel_b_t := b_ts.get(i)
                break
    float sel_r_top = float(na)
    float sel_r_bot = float(na)
    int sel_r_t = int(na)
    if r_tops.size() > 0
        for i = r_tops.size() - 1 to 0 by 1
            if r_bots.get(i) > close
                sel_r_top := r_tops.get(i)
                sel_r_bot := r_bots.get(i)
                sel_r_t := r_ts.get(i)
                break
    [sel_b_top, sel_b_bot, sel_b_t, sel_r_top, sel_r_bot, sel_r_t]

[_h1_bt, _h1_bb, _h1_bt2, _h1_art, _h1_arb, _h1_art2] = request.security(syminfo.tickerid, '60', _h1_fvg(), lookahead = barmerge.lookahead_off)

var float fvg_b_top = na
var float fvg_b_bot = na
var int fvg_b_t = na
var float fvg_r_top = na
var float fvg_r_bot = na
var int fvg_r_t = na

if not na(_h1_bt)
    fvg_b_top := _h1_bt
    fvg_b_bot := _h1_bb
    fvg_b_t := _h1_bt2
    fvg_b_t
else
    fvg_b_top := na
    fvg_b_bot := na
    fvg_b_t := na
    fvg_b_t

if not na(_h1_art) and _h1_arb > close
    fvg_r_top := _h1_art
    fvg_r_bot := _h1_arb
    fvg_r_t := _h1_art2
    fvg_r_t
else
    fvg_r_top := na
    fvg_r_bot := na
    fvg_r_t := na
    fvg_r_t

var box fvg_bull_box = na
var box fvg_bear_box = na
var float _fvg_lb_top = na
var float _fvg_lr_top = na

if tog_fvg
    _fvg_bs = _bsty(fvg_border_sty)
    _fvg_bull_bc = fvg_border_sty == 'None' ? color.new(col_fvg_bull, 100) : color.new(col_fvg_bull, 0)
    _fvg_bear_bc = fvg_border_sty == 'None' ? color.new(col_fvg_bear, 100) : color.new(col_fvg_bear, 0)
    _fr = time + 86400000 * 30
    if not na(fvg_b_t) and (na(fvg_bull_box) or fvg_b_top != _fvg_lb_top)
        if not na(fvg_bull_box)
            fvg_bull_box.delete()
        fvg_bull_box := box.new(fvg_b_t, fvg_b_top, _fr, fvg_b_bot, xloc = xloc.bar_time, bgcolor = col_fvg_bull, border_color = _fvg_bull_bc, border_style = _fvg_bs, border_width = fvg_border_w)
        _fvg_lb_top := fvg_b_top
        _fvg_lb_top
    if not na(fvg_r_t) and (na(fvg_bear_box) or fvg_r_top != _fvg_lr_top)
        if not na(fvg_bear_box)
            fvg_bear_box.delete()
        fvg_bear_box := box.new(fvg_r_t, fvg_r_top, _fr, fvg_r_bot, xloc = xloc.bar_time, bgcolor = col_fvg_bear, border_color = _fvg_bear_bc, border_style = _fvg_bs, border_width = fvg_border_w)
        _fvg_lr_top := fvg_r_top
        _fvg_lr_top
    if na(fvg_b_t) and not na(fvg_bull_box)
        fvg_bull_box.delete()
        fvg_bull_box := na
        fvg_bull_box
    if na(fvg_r_t) and not na(fvg_bear_box)
        fvg_bear_box.delete()
        fvg_bear_box := na
        fvg_bear_box
else
    if not na(fvg_bull_box)
        fvg_bull_box.delete()
        fvg_bull_box := na
        fvg_bull_box
    if not na(fvg_bear_box)
        fvg_bear_box.delete()
        fvg_bear_box := na
        fvg_bear_box

// Bias zone shading and neutralization label removed.
// Bias is now represented entirely in the SMT table with ATR grading.

// ============================================================
// === PLOTS (exported for Trinity reference) ===
// ============================================================
plot(open_830, '08:30 Open', color = na, display = display.data_window)
plot(asia_high, 'Asia High', color = na, display = display.data_window)
plot(asia_low, 'Asia Low', color = na, display = display.data_window)
plot(lon_high, 'London High', color = na, display = display.data_window)
plot(lon_low, 'London Low', color = na, display = display.data_window)
plot(cyc_high_t2, 'Cycle High T2', color = na, display = display.data_window)
plot(cyc_low_t2, 'Cycle Low T2', color = na, display = display.data_window)
plot(long_gate ? 1 : 0, 'Long Gate', color = na, display = display.data_window)
plot(short_gate ? 1 : 0, 'Short Gate', color = na, display = display.data_window)
plot(no_trade_env ? 1 : 0, 'No Trade', color = na, display = display.data_window)

// ============================================================
// === HTF SMT TABLE ===
// ============================================================
_tpos = switch tbl_pos
    'Top Left' => position.top_left
    'Top Center' => position.top_center
    'Middle Left' => position.middle_left
    'Middle Center' => position.middle_center
    'Middle Right' => position.middle_right
    'Bottom Left' => position.bottom_left
    'Bottom Center' => position.bottom_center
    'Bottom Right' => position.bottom_right
    => position.top_right

// -- Bias strength bar (5 unicode blocks, filled by tier) --
// Tier 0 = equil = no fill | Tier 1 = 1-2 | Tier 2 = 3-4 | Tier 3 = 5
_bias_filled(tier) =>
    tier == 0 ? '[-----]' : tier == 1 ? '[##---]' : tier == 2 ? '[####-]' : '[#####]'

// Bias direction and colour grading by tier
bias_dir = in_discount ? 'LONG' : in_premium ? 'SHORT' : 'EQUIL'
bias_base_c = in_discount ? #089981 : in_premium ? #f44336 : #888888
// Tier colours - intensity increases with tier
// Bias cell colour - driven by tier only, independent of AM chop flag
// Tier 0 = grey (within 10pts of open), 1 = faint, 2 = medium, 3 = bright
bias_cell_bg = bias_tier == 0 ? color.new(#888888, 80) : bias_tier == 1 ? color.new(bias_base_c, 65) : bias_tier == 2 ? color.new(bias_base_c, 35) : color.new(bias_base_c, 5)
bias_txt_c = bias_tier == 0 ? color.new(#888888, 0) : color.new(bias_base_c, 0)

// ATR distance string
atr_dist_str = not na(atr_dist) ? str.tostring(math.round(atr_dist, 2)) + 'x ATR' : '-'
tier_str = bias_tier == 0 ? 'EQUIL' : bias_tier == 1 ? 'CAUTION' : bias_tier == 2 ? in_discount ? 'LONG' : 'SHORT' : in_discount ? 'LONG +' : 'SHORT +'
bar_str = _bias_filled(bias_tier)
// AM chop flag shown separately - does not override bias colour
chop_str = no_trade_env ? 'CHOP' : '-'
chop_col = no_trade_env ? #f44336 : col_tbl_txt

// -- Bias-only table -----------------------------------------
// Cols: 2 (label | value)
// Rows: 5
//   0: header row
//   1: Direction  | LONG / SHORT / EQUIL  (colour graded)
//   2: Strength   | fill bar              (colour graded)
//   3: Zone       | EQUIL / CAUTION / LONG / LONG+
//   4: ATR Dist   | 0.56x ATR
//   5: 08:30 Ref  | 7210.00  | CHOP if AM compressed

var table htf_tbl = na
if show_htf_tbl and barstate.islast
    // Recreate table every last bar so position and size changes take effect
    if not na(htf_tbl)
        htf_tbl.delete()
    htf_tbl := table.new(_tpos, 2, 4, bgcolor = col_tbl_bg, border_width = 0, border_color = noColor, frame_width = 0, frame_color = noColor)
    // Row 0: header - 08:30 reference price
    table.cell(htf_tbl, 0, 0, '0830 BIAS', text_color = col_tbl_hdr_txt, text_size = size.small, bgcolor = col_tbl_hdr, width = tbl_width, height = tbl_height)
    table.cell(htf_tbl, 1, 0, not na(open_830) ? str.tostring(open_830, format.mintick) : '-', text_color = col_tbl_hdr_txt, text_size = size.small, bgcolor = col_tbl_hdr, width = tbl_width, height = tbl_height)
    // Row 1: Direction
    table.cell(htf_tbl, 0, 1, 'Direction', text_color = col_tbl_txt, text_size = size.small, bgcolor = col_tbl_bg, width = tbl_width, height = tbl_height)
    table.cell(htf_tbl, 1, 1, bias_dir, text_color = bias_txt_c, text_size = size.small, bgcolor = bias_cell_bg, width = tbl_width, height = tbl_height)
    // Row 2: Strength bar
    table.cell(htf_tbl, 0, 2, 'Strength', text_color = col_tbl_txt, text_size = size.small, bgcolor = col_tbl_bg, width = tbl_width, height = tbl_height)
    table.cell(htf_tbl, 1, 2, bar_str, text_color = bias_txt_c, text_size = size.small, bgcolor = bias_cell_bg, width = tbl_width, height = tbl_height)
    // Row 3: Zone
    table.cell(htf_tbl, 0, 3, 'Zone', text_color = col_tbl_txt, text_size = size.small, bgcolor = col_tbl_bg, width = tbl_width, height = tbl_height)
    table.cell(htf_tbl, 1, 3, tier_str, text_color = bias_txt_c, text_size = size.small, bgcolor = bias_cell_bg, width = tbl_width, height = tbl_height)

// Additional bias exports for Trinity reference
plot(not na(atr_dist) ? atr_dist : 0, 'ATR Distance', color = na, display = display.data_window)
plot(bias_tier, 'Bias Tier', color = na, display = display.data_window)
````

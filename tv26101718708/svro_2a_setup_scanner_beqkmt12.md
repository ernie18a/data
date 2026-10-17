# SVRO + 2A Setup Scanner

- url: https://www.tradingview.com/script/bEqkmt12-SVRO-2A-Setup-Scanner/
- type: indicator
- pine_id: PUB;846a4c32d4d24ba8a9d71cff42d1a29b
- version: 8.0

## Description

Step 1 — Your Daily Workflow
Glance at the info table (top right) first — it tells you instantly where each stock stands
You're looking for stocks where a phase is ACTIVE
You can change mods between SVRO(VCP) or Reversal/Pullbacks or Both.

Step 2 — Reading the Background Colors
🔵 Blue tint on chart = SVRO contraction building

The stock had a big prior run, a Purple Dot institutional move, and is now quietly coiling
This is your "put on watchlist and watch daily" signal
Don't enter yet — wait for the green triangle

🟠 Orange tint = 2A pullback in progress

Uptrend is intact, stock is pulling back toward 21 EMA, volume drying up
Same thing — watchlist mode, not entry mode yet


Step 3 — The Green Triangle = Entry Signal
This is the "act now" signal. But check which label it carries:

SVRO ENTRY = Strong Start breakout out of contraction. Enter within first 30 mins of market open
2A-SS = Strong Start bounce off 21 EMA. Same — early morning entry
2A-SV = Stop Volume absorption bar. Enter on next day's open if structure holds
2A-CV = Climax Volume exhaustion. More aggressive — enter same day if market confirms


Step 4 — Stop Loss
The red dashed line on the chart is your stop. It auto-calculates as:

SVRO = 1% below entry
2A = low of the pullback candle

If price closes below it — exit, no argument.

Step 5 — Setting Up Alerts
This is the most powerful part for daily scanning:

Go to Alerts (clock icon) → Create Alert
Under Condition → select "Manas Arora Setups"
You'll see all 12 alert conditions listed
Set "ANY Setup Entry Signal" first — this fires whenever either setup triggers
Then separately set "SVRO Contraction Building" and "2A Pullback Phase Started" — so you get early warning before entry

Set these on every stock in your watchlist. TV Essential allows multiple alerts.

Step 6 — What to Ignore

Green triangle on a stock with no prior uptrend (table shows uptrend % red) → skip
Green triangle but volume not confirming → be cautious
2A-CV signal on a stock that's been falling for weeks → this is the Falling Knife setup, harder to trade, skip it for now


Practical tip to start — load the script on 5-10 stocks you already know well rather than random scanning. The signals will make more intuitive sense on familiar charts first.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// SVRO + Reversal Scanner — Final Created by Azhar - NiftyBreakouts
//@version=6
indicator('SVRO + Reversal Scanner', shorttitle = 'SVRO+Reversal', overlay = true, max_bars_back = 500)

// ═══════════════════════════════════════════════════════════
// COLOR VARIABLES (defined once, reused everywhere)
// ═══════════════════════════════════════════════════════════

color COL_GOLD       = color.new(#FFD700, 0)
color COL_GREEN      = color.new(#00FF88, 0)
color COL_BLUE       = color.new(#0066ff, 0)
color COL_ORANGE     = color.new(#FF8C00, 0)
color COL_RED        = color.new(#0940d5, 0)
color COL_CYAN       = color.new(#00CCFF, 0)
color COL_WHITE    = color.new(#fbfbfb, 0)
color COL_FIRE       = color.new(#ff0000, 0)

color COL_GRAY       = color.new(#555555, 0)
color COL_MUTED      = color.new(#AAAAAA, 0)
color COL_TBL_BG     = color.new(#111111, 10)
color COL_TBL_HDR    = color.new(#222222, 0)
color COL_TBL_BORDER = color.new(#444444, 0)
color COL_TBL_FRAME  = color.new(#666666, 0)
color COL_BG_BLUE    = color.new(#00BFFF, 88)
color COL_BG_ORANGE  = color.new(#FF8C00, 88)

// ═══════════════════════════════════════════════════════════
// INPUT GROUPS
// ═══════════════════════════════════════════════════════════

grp_mode   = '═══ SETUP SELECTOR ═══'
grp_svro   = '═══ SVRO SETTINGS ═══'
grp_rev    = '═══ REVERSAL SETTINGS ═══'
grp_shared = '═══ SHARED SETTINGS ═══'

// ── Setup Mode ──
setup_mode  = input.string('Both', 'Active Setup', options = ['SVRO Only', 'Reversal Only', 'Both'], group = grp_mode)
show_ema10  = input.bool(true, 'Show 10 EMA',        group = grp_mode)
show_ema21  = input.bool(true, 'Show 21 EMA',        group = grp_mode)
show_ema50  = input.bool(true, 'Show 50 EMA',        group = grp_mode)
show_ema200 = input.bool(true, 'Show 200 EMA',       group = grp_mode)
show_vol_ma = input.bool(true, 'Show Volume MA (10)', group = grp_mode)

// ── SVRO Settings ──
svro_prior_uptrend_pct = input.float(50.0,    'Prior Uptrend Min %',           minval = 20.0,   step = 5.0,      group = grp_svro, tooltip = 'Minimum % gain in prior uptrend before base formation')
svro_uptrend_weeks     = input.int(10,         'Prior Uptrend Lookback (weeks)', minval = 4,     maxval = 20,     group = grp_svro)
svro_purple_dot_pct    = input.float(5.0,     'Purple Dot Min Move %',          minval = 3.0,   step = 0.5,      group = grp_svro, tooltip = 'Min single-day % move to qualify as institutional strength')
svro_purple_dot_vol    = input.int(1000000,   'Purple Dot Min Volume',          minval = 100000, step = 100000,  group = grp_svro)
svro_contraction_pct   = input.float(3.0,     'Contraction Max Daily Range %',  minval = 1.0,   maxval = 6.0,    step = 0.5, group = grp_svro, tooltip = 'Max high-low range % to qualify as volatility contraction')
svro_vol_dry_factor    = input.float(0.7,     'Volume Dry-Up Factor (vs 10MA)', minval = 0.3,   maxval = 1.0,    step = 0.05, group = grp_svro)
svro_ema_pierce_pct    = input.float(1.5,     'Max EMA Pierce % (close below)', minval = 0.0,   maxval = 3.0,    step = 0.5, group = grp_svro)

// ── Reversal Settings ──
rev_pullback_min   = input.float(10.0, 'Min Pullback from High %',       minval = 5.0,  maxval = 25.0, step = 1.0,  group = grp_rev)
rev_bearish_bars   = input.int(5,      'Bearish Bars (out of 7)',         minval = 3,    maxval = 7,                 group = grp_rev)
rev_ema_proximity  = input.float(3.0,  'Max Distance from 21 EMA %',     minval = 1.0,  maxval = 8.0,  step = 0.5,  group = grp_rev)
rev_vol_dry_factor = input.float(0.85, 'Volume Dry-Up Factor (vs 10MA)', minval = 0.3,  maxval = 1.0,  step = 0.05, group = grp_rev)
rev_sv_range_pct   = input.float(2.0,  'Stop Volume Max Range %',        minval = 0.5,  maxval = 5.0,  step = 0.5,  group = grp_rev, tooltip = 'High volume bar with small range = absorption')
rev_sv_vol_factor  = input.float(1.5,  'Stop Volume Min Vol Factor',     minval = 1.0,  maxval = 3.0,  step = 0.1,  group = grp_rev)
rev_cv_move_pct    = input.float(3.0,  'Climax Volume Min Drop %',       minval = 2.0,  maxval = 8.0,  step = 0.5,  group = grp_rev, tooltip = 'Big red candle = exhaustion')
rev_cv_vol_factor  = input.float(2.0,  'Climax Volume Min Vol Factor',   minval = 1.5,  maxval = 4.0,  step = 0.1,  group = grp_rev)

// ── Shared Settings ──
ema_len    = input.int(21, 'Primary EMA Length', minval = 5, maxval = 50, group = grp_shared)
vol_ma_len = input.int(10, 'Volume MA Length',   minval = 5, maxval = 20, group = grp_shared)

// ═══════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════

// ── EMA Lines ──
ema10  = ta.ema(close, 10)
ema21  = ta.ema(close, ema_len)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// ── Volume MA ──
vol_ma10 = ta.sma(volume, vol_ma_len)

// ── Strong Start locked to 1D — consistent on any timeframe ──
[d_open, d_prev_close, d_low] =
     request.security(syminfo.tickerid, "1D",
     [open, close[1], low],
     lookahead = barmerge.lookahead_off)

bool is_strong_start = d_open > d_prev_close and d_low >= d_prev_close * 0.995

// ── Inside Bar ──
bool is_inside_bar = high < high[1] and low > low[1]

// ── Daily Range % ──
float daily_range = (high - low) / low * 100

// ── TREND FILTER — all EMAs must be in order ──
bool trend_ok = ema21 > ema50 and ema50 > ema200

// ── Prior Uptrend (SVRO) ──
int   lookback_bars    = svro_uptrend_weeks * 5
float prior_low        = ta.lowest(low, lookback_bars)
float uptrend_pct      = (close - prior_low) / prior_low * 100
bool  in_prior_uptrend = uptrend_pct >= svro_prior_uptrend_pct

// ── Purple Dot (uses ta.barssince — no loop) ──
float pd_move             = (close - open) / open * 100
bool  is_purple_dot_today = pd_move >= svro_purple_dot_pct and volume >= svro_purple_dot_vol
float bars_since_pd       = ta.barssince(is_purple_dot_today)
bool  purple_dot_recent   = not na(bars_since_pd) and bars_since_pd <= 30

// ── Volatility Contraction ──
bool is_contraction  = daily_range <= svro_contraction_pct
bool vol_drying_svro = volume < vol_ma10 * svro_vol_dry_factor

// ── Price vs 21 EMA ──
bool above_ema        = close >= ema21
bool barely_below_ema = close < ema21 and close >= ema21 * (1 - svro_ema_pierce_pct / 100)
bool ema_ok_svro      = above_ema or barely_below_ema

// ═══════════════════════════════════════════════════════════
// SVRO CONDITIONS
// ═══════════════════════════════════════════════════════════

bool svro_contraction_phase = trend_ok and in_prior_uptrend and purple_dot_recent and is_contraction and vol_drying_svro and ema_ok_svro

bool svro_breakout        = svro_contraction_phase[1] and is_strong_start and volume > vol_ma10
bool svro_inside_breakout = svro_contraction_phase[1] and is_inside_bar[1] and is_strong_start
bool svro_entry           = svro_breakout or svro_inside_breakout

// ═══════════════════════════════════════════════════════════
// REVERSAL CONDITIONS
// ═══════════════════════════════════════════════════════════

bool  ema_rising      = ema21 > ema21[3]
float recent_high     = ta.highest(high, 20)
float pullback_pct    = (recent_high - close) / recent_high * 100
bool  enough_pullback = pullback_pct >= rev_pullback_min

int bearish_count = 0
for i = 0 to 6 by 1
    if close[i] < open[i]
        bearish_count += 1
bool enough_bearish = bearish_count >= rev_bearish_bars

float ema_proximity_pct = math.abs(close - ema21) / ema21 * 100
bool  near_ema          = ema_proximity_pct <= rev_ema_proximity

bool rev_trend_ok = ema50 > ema200
bool rev_base     = rev_trend_ok and ema_rising and enough_pullback and enough_bearish and near_ema

// ── Strong Start Reversal Trigger ──
bool rev_ss_trigger = rev_base and is_strong_start

// ── Stop Volume (close must finish in upper 30% of candle) ──
float sv_close_threshold = high - (high - low) * 0.3
bool  is_stop_volume     = volume >= vol_ma10 * rev_sv_vol_factor and daily_range <= rev_sv_range_pct and close >= sv_close_threshold
bool  rev_sv_trigger     = rev_base and is_stop_volume

// ── Climax Volume ──
bool is_climax_vol  = close < open and (open - close) / open * 100 >= rev_cv_move_pct and volume >= vol_ma10 * rev_cv_vol_factor
bool rev_cv_trigger = rev_base and is_climax_vol

bool rev_entry          = rev_ss_trigger or rev_sv_trigger or rev_cv_trigger
bool rev_pullback_phase = rev_trend_ok and ema_rising and enough_pullback and enough_bearish

// ═══════════════════════════════════════════════════════════
// STOP LOSS LEVELS
// ═══════════════════════════════════════════════════════════

float svro_sl = low - close * 0.01
float rev_sl  = low[1]

// ═══════════════════════════════════════════════════════════
// INSIDE BAR — BAR COLOR
// ═══════════════════════════════════════════════════════════

barcolor(is_inside_bar ? color.yellow : na, title = 'Inside Bar')

// ═══════════════════════════════════════════════════════════
// PLOT — EMA LINES
// ═══════════════════════════════════════════════════════════

plot(show_ema10  ? ema10  : na, '10 EMA',  color = COL_GREEN,   linewidth = 1)
plot(show_ema21  ? ema21  : na, '21 EMA',  color = COL_GOLD,   linewidth = 2)
plot(show_ema50  ? ema50  : na, '50 EMA',  color = COL_FIRE,   linewidth = 2)
plot(show_ema200 ? ema200 : na, '200 EMA', color = COL_RED,    linewidth = 2)
plot(show_vol_ma ? vol_ma10 : na, 'Vol MA10', display = display.none)

// ═══════════════════════════════════════════════════════════
// VISIBILITY FLAGS
// ═══════════════════════════════════════════════════════════

bool run_svro = setup_mode == 'SVRO Only' or setup_mode == 'Both'
bool run_rev  = setup_mode == 'Reversal Only' or setup_mode == 'Both'

// ═══════════════════════════════════════════════════════════
// PLOT — SVRO SIGNALS
// ═══════════════════════════════════════════════════════════

bgcolor(run_svro and svro_contraction_phase ? COL_BG_BLUE : na, title = 'SVRO Contraction Zone')

plotshape(run_svro and is_purple_dot_today,
     title = 'Purple Dot', style = shape.circle, location = location.abovebar,
     color = COL_WHITE, size = size.small, text = 'PD')

bool svro_contraction_start = svro_contraction_phase and not svro_contraction_phase[1]
plotshape(run_svro and svro_contraction_start,
     title = 'SVRO Contraction Start', style = shape.labeldown, location = location.abovebar,
     color = COL_BLUE, textcolor = COL_WHITE, size = size.normal, text = 'VCP\nBuilding')

plotshape(run_svro and svro_entry,
     title = 'SVRO Entry Signal', style = shape.triangleup, location = location.belowbar,
     color = COL_GREEN, size = size.large, text = 'SVRO\nENTRY')

plot(run_svro and svro_entry ? svro_sl : na, 'SVRO Stop Loss',
     color = color.new(#FF4444, 80), style = plot.style_linebr, linewidth = 1)

// ═══════════════════════════════════════════════════════════
// PLOT — REVERSAL SIGNALS
// ═══════════════════════════════════════════════════════════

bgcolor(run_rev and rev_pullback_phase ? COL_BG_ORANGE : na, title = 'Reversal Pullback Zone')

bool rev_phase_start = rev_pullback_phase and not rev_pullback_phase[1]
plotshape(run_rev and rev_phase_start,
     title = 'Reversal Pullback Phase', style = shape.labeldown, location = location.abovebar,
     color = COL_ORANGE, textcolor = COL_WHITE, size = size.normal, text = 'HL\nPullback')

plotshape(run_rev and rev_ss_trigger,
     title = 'Reversal Strong Start', style = shape.triangleup, location = location.belowbar,
     color = COL_GREEN, size = size.large, text = 'REV\nSS')

plotshape(run_rev and rev_sv_trigger,
     title = 'Reversal Stop Volume', style = shape.triangleup, location = location.belowbar,
     color = COL_CYAN, size = size.large, text = 'REV\nSV')

plotshape(run_rev and rev_cv_trigger,
     title = 'Reversal Climax Volume', style = shape.triangleup, location = location.belowbar,
     color = COL_FIRE, size = size.large, text = 'REV\nCV')

plot(run_rev and rev_entry ? rev_sl : na, 'Reversal Stop Loss',
     color = color.new(#FF4444, 80), style = plot.style_linebr, linewidth = 1)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════

alertcondition(is_purple_dot_today,     title = '🟣 Purple Dot Detected',         message = 'SVRO: Purple Dot detected on {{ticker}}. Watch for base formation.')
alertcondition(svro_contraction_start,  title = '🔵 SVRO Contraction Building',    message = 'SVRO: Volatility contraction started on {{ticker}}. Monitor for breakout.')
alertcondition(svro_entry,              title = '🟢 SVRO Entry Signal',            message = 'SVRO: Entry signal on {{ticker}} at {{close}}.')
alertcondition(svro_breakout,           title = '🟢 SVRO Breakout (Strong Start)', message = 'SVRO: Strong Start breakout on {{ticker}} at {{close}}.')
alertcondition(svro_inside_breakout,    title = '🟢 SVRO Inside Bar Breakout',     message = 'SVRO: Inside bar + Strong Start on {{ticker}} at {{close}}.')
alertcondition(rev_phase_start,         title = '🟠 Reversal Pullback Started',    message = 'Reversal: Higher Low pullback started on {{ticker}}. Watch EMA.')
alertcondition(rev_ss_trigger,          title = '🟢 Reversal Strong Start Entry',  message = 'Reversal: Strong Start entry on {{ticker}} at {{close}}.')
alertcondition(rev_sv_trigger,          title = '🔵 Reversal Stop Volume Entry',   message = 'Reversal: Stop Volume (absorption) on {{ticker}} at {{close}}.')
alertcondition(rev_cv_trigger,          title = '🔴 Reversal Climax Volume Entry', message = 'Reversal: Climax Volume exhaustion on {{ticker}} at {{close}}.')
alertcondition(rev_entry,               title = '🟢 Reversal Any Entry Signal',    message = 'Reversal: Entry condition met on {{ticker}} at {{close}}.')
alertcondition(svro_entry or rev_entry, title = '⚡ ANY Setup Entry Signal',       message = 'Entry signal on {{ticker}} at {{close}}. Check chart for setup type.')

// ═══════════════════════════════════════════════════════════
// INFO TABLE (top right) — 9 rows
// ═══════════════════════════════════════════════════════════

var table info_table = table.new(position.top_right, 2, 9,
     bgcolor      = COL_TBL_BG,
     border_color = COL_TBL_BORDER, border_width = 1,
     frame_color  = COL_TBL_FRAME,  frame_width  = 1)

if barstate.islast

    // ── Header ──
    table.cell(info_table, 0, 0, 'INDICATOR', text_color = COL_MUTED, text_size = size.small, bgcolor = COL_TBL_HDR)
    table.cell(info_table, 1, 0, 'STATUS',    text_color = COL_MUTED, text_size = size.small, bgcolor = COL_TBL_HDR)
    
    // ── Trend Filter ──
    color  trend_color  = trend_ok ? COL_GREEN : COL_RED
    string trend_status = trend_ok ? '21>50>200 ✓' : 'WEAK ✗'
    table.cell(info_table, 0, 1, 'Trend Filter', text_color = COL_WHITE,   text_size = size.small)
    table.cell(info_table, 1, 1, trend_status,    text_color = trend_color,  text_size = size.small)

    // ── Price vs 21 EMA ──
    color  ema_color  = close >= ema21 ? COL_GREEN : COL_RED
    string ema_status = close >= ema21 ? 'ABOVE ✓' : 'BELOW ✗'
    table.cell(info_table, 0, 2, 'Price vs 21 EMA', text_color = COL_WHITE, text_size = size.small)
    table.cell(info_table, 1, 2, ema_status,          text_color = ema_color,  text_size = size.small)

    // ── Volume vs MA ──
    color  vol_color  = volume < vol_ma10 ? COL_GREEN : COL_ORANGE
    string vol_status = volume < vol_ma10 ? 'DRYING ✓' : 'ELEVATED'
    table.cell(info_table, 0, 3, 'Volume vs MA', text_color = COL_WHITE, text_size = size.small)
    table.cell(info_table, 1, 3, vol_status,      text_color = vol_color,  text_size = size.small)

    // ── Strong Start ──
    color  ss_color  = is_strong_start ? COL_GREEN : COL_RED
    string ss_status = is_strong_start ? '✓' : '✗'
    table.cell(info_table, 0, 4, 'Strong Start (1D)', text_color = COL_WHITE, text_size = size.small)
    table.cell(info_table, 1, 4, ss_status,            text_color = ss_color,  text_size = size.small)

    // ── Prior Uptrend ──
    color  ut_color  = in_prior_uptrend ? COL_GREEN : COL_RED
    string ut_status = str.tostring(math.round(uptrend_pct, 1)) + (in_prior_uptrend ? '% ✓' : '% ✗')
    table.cell(info_table, 0, 5, 'Prior Uptrend', text_color = COL_WHITE, text_size = size.small)
    table.cell(info_table, 1, 5, ut_status,        text_color = ut_color,  text_size = size.small)

    // ── Pullback % ──
    color pb_color = enough_pullback ? COL_GREEN : COL_MUTED
    table.cell(info_table, 0, 6, 'Pullback %',                                     text_color = COL_WHITE, text_size = size.small)
    table.cell(info_table, 1, 6, str.tostring(math.round(pullback_pct, 1)) + '%',  text_color = pb_color,  text_size = size.small)

    // ── SVRO Phase ──
    color  svro_ph_color = svro_contraction_phase ? COL_BLUE : COL_GRAY
    string svro_ph_text  = svro_contraction_phase  ? 'ACTIVE ●' : 'WAITING'
    table.cell(info_table, 0, 7, 'SVRO Phase', text_color = COL_WHITE,     text_size = size.small)
    table.cell(info_table, 1, 7, svro_ph_text,  text_color = svro_ph_color, text_size = size.small)

    // ── Reversal Phase ──
    color  rev_ph_color = rev_pullback_phase ? COL_ORANGE : COL_GRAY
    string rev_ph_text  = rev_pullback_phase  ? 'ACTIVE ●' : 'WAITING'
    table.cell(info_table, 0, 8, 'Reversal Phase', text_color = COL_WHITE,    text_size = size.small)
    table.cell(info_table, 1, 8, rev_ph_text,       text_color = rev_ph_color, text_size = size.small)
````

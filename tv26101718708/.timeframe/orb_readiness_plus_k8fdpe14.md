# ORB Readiness Plus

- url: https://www.tradingview.com/script/k8fdPe14-ORB-Readiness-Plus/
- type: indicator
- pine_id: PUB;1338f57bd65b4c8395d714b7201ca9aa
- version: 1.0

## Description

ORB Readiness Plus is an Opening Range Breakout decision-support indicator that tracks ORB breaks, retests, reclaims, midline reactions, and trade-quality context.

Unlike a basic ORB tool that only plots the high and low of the opening range, this script also evaluates whether the price is continuing a breakout, failing a breakout, reclaiming the ORB, or reacting from the ORB midline.

Features include ORB high/low/midline plotting, bullish and bearish close-break detection, edge retest tracking, reclaim warning and confirmation logic, midline reaction logic, VWAP alignment, HTF EMA bias, EMA slope, volume confirmation, ORB/ATR range quality, measured-move target guide, dashboard scoring, alerts, and clean triangle markers.

The goal is to help traders quickly answer:

• Has the ORB been set?
• Did price break the range with a close?
• Is the move continuing or reclaiming?
• Did price retest the ORB edge or react from the midline?
• Is the setup aligned with VWAP, trend, volume, and range quality?

Signal guide:

▲Green triangle = Long entry condition  
▼ Red triangle = Short entry condition  
▲ Orange triangle = Best setup condition  
▲ / ▼ Small yellow triangle = Optional reclaim warning/context signal  
▲ / ▼ Small gray triangle = Optional ORB midline reaction signal  

This script is best used on intraday charts such as 1-minute, 3-minute, or 5-minute timeframes. It is intended for discretionary ORB traders who want a cleaner structure and context, not automatic buy or sell calls.

This indicator is for education and decision support only. It does not guarantee results. Always use proper risk management and test before using in live trading.

## Source Code

````pine
//@version=6
indicator("ORB Readiness Plus - Armed Reclaim Tight", overlay=true, max_labels_count=500, max_lines_count=500)

//====================
// Inputs
//====================
session_open = input.session("0930-1000", "ORB Session", group="Session")
timezone = input.string("America/New_York", "Timezone", group="Session")

htf_tf = input.timeframe("60", "HTF Timeframe for Trend", group="HTF Trend")
ema_len = input.int(50, "HTF EMA Length", group="HTF Trend", minval=1)

orb_retest_zone = input.float(0.10, "Retest Proximity $", group="ORB Settings", minval=0.01, maxval=20.0, step=0.01)
allow_midline_as_retest = input.bool(true, "Allow Midline Reaction as Retest", group="ORB Settings")
count_first_retest_only = input.bool(true, "Count First Retest Only Per Setup", group="ORB Settings")
max_retests = input.int(3, "Flag if retests exceed", group="ORB Settings", minval=1)

show_orb_lines = input.bool(true, "Show ORB High/Low Lines", group="Visuals")
show_midline = input.bool(true, "Show ORB Midline", group="Visuals")
show_target_lines = input.bool(true, "Show Measured Move Target", group="Visuals")
show_entry_labels = input.bool(true, "Show Entry Labels", group="Visuals")
show_reclaim_warning_labels = input.bool(false, "Show Reclaim Warning Labels", group="Visuals")
show_midline_labels = input.bool(false, "Show Separate Midline Labels", group="Visuals")

max_entry_labels_per_day = input.int(6, "Max Entry Labels Per Day", group="Visuals", minval=1, maxval=20)
label_cooldown_bars = input.int(10, "Label Cooldown Bars", group="Visuals", minval=1, maxval=200)

use_quality_score = input.bool(true, "Use Quality Score", group="Quality Filters")
min_quality_for_best = input.int(3, "Min Quality Score for BEST SETUP", group="Quality Filters", minval=1, maxval=5)

vwap_enabled = input.bool(true, "VWAP Align", group="Quality Filters")
volume_enabled = input.bool(true, "Volume Confirm", group="Quality Filters")
vol_len = input.int(20, "Volume SMA Length", group="Quality Filters", minval=1)
vol_mult = input.float(1.0, "Volume Multiplier", group="Quality Filters", minval=0.1, maxval=5.0, step=0.1)

ema_slope_enabled = input.bool(true, "EMA Slope Align", group="Quality Filters")
slope_ema_len = input.int(20, "Slope EMA Length", group="Quality Filters", minval=1)

atr_enabled = input.bool(true, "ORB Range / ATR Quality", group="Quality Filters")
atr_len = input.int(14, "ATR Length", group="Quality Filters", minval=1)
min_orb_atr = input.float(3.0, "Min ORB Range x ATR", group="Quality Filters", minval=0.1, maxval=50.0, step=0.1)
max_orb_atr = input.float(20.0, "Max ORB Range x ATR", group="Quality Filters", minval=0.1, maxval=100.0, step=0.1)

dash_x = input.string("right", "Dashboard X Position", options=["left", "center", "right"], group="Dashboard")
dash_y = input.string("top", "Dashboard Y Position", options=["top", "middle", "bottom"], group="Dashboard")

//====================
// Helpers
//====================
in_session(sess) =>
    not na(time(timeframe.period, sess, timezone))

//====================
// Time / Day
//====================
is_orb_bar = in_session(session_open)
new_day = dayofmonth(time, timezone) != dayofmonth(time[1], timezone)

//====================
// ORB Build
//====================
var float orb_high = na
var float orb_low = na
var bool orb_set = false

if new_day
    orb_high := na
    orb_low := na
    orb_set := false

if is_orb_bar
    orb_high := na(orb_high) ? high : math.max(orb_high, high)
    orb_low := na(orb_low) ? low : math.min(orb_low, low)

if not is_orb_bar and not na(orb_high) and not na(orb_low)
    orb_set := true

orb_mid = orb_set ? (orb_high + orb_low) / 2.0 : na
orb_range = orb_set ? orb_high - orb_low : na

//====================
// Lines
//====================
var line orb_high_line = na
var line orb_low_line = na
var line orb_mid_line = na
var line target_line = na

if orb_set and barstate.islast
    start_bar = math.max(bar_index - 200, 0)

    if show_orb_lines
        line.delete(orb_high_line)
        line.delete(orb_low_line)
        orb_high_line := line.new(start_bar, orb_high, bar_index, orb_high, color=color.new(color.green, 20), width=2, style=line.style_dashed, extend=extend.right)
        orb_low_line := line.new(start_bar, orb_low, bar_index, orb_low, color=color.new(color.red, 20), width=2, style=line.style_dashed, extend=extend.right)

    if show_midline
        line.delete(orb_mid_line)
        orb_mid_line := line.new(start_bar, orb_mid, bar_index, orb_mid, color=color.new(color.gray, 15), width=2, style=line.style_dotted, extend=extend.right)

//====================
// State Variables
// active_dir:
//  1 = active long idea
// -1 = active short idea
//  0 = no setup yet
//
// setup_mode:
//  1 = breakout long
// -1 = breakout short
//  2 = confirmed ORB low reclaim long
// -2 = confirmed ORB high reclaim short
//  0 = none
//====================
var int active_dir = 0
var int setup_mode = 0
var int trigger_bar = na

var int retest_high_count = 0
var int retest_low_count = 0
var int midline_reaction_count = 0

var int bull_break_count = 0
var int bear_break_count = 0
var int bull_reclaim_warning_count = 0
var int bear_reclaim_warning_count = 0
var int confirmed_reclaim_count = 0
var int reclaim_continuation_count = 0

var bool was_valid_bull_edge = false
var bool was_valid_bear_edge = false
var bool was_valid_midline = false

var bool armed_bull_reclaim = false
var bool armed_bear_reclaim = false
var bool pending_bull_reclaim = false
var bool pending_bear_reclaim = false
var int pending_reclaim_bar = na
var int reclaim_warning_dir = 0

var int entry_labels_today = 0
var int warning_labels_today = 0
var int last_entry_label_bar = na
var int last_warning_label_bar = na

if new_day
    active_dir := 0
    setup_mode := 0
    trigger_bar := na

    retest_high_count := 0
    retest_low_count := 0
    midline_reaction_count := 0

    bull_break_count := 0
    bear_break_count := 0
    bull_reclaim_warning_count := 0
    bear_reclaim_warning_count := 0
    confirmed_reclaim_count := 0
    reclaim_continuation_count := 0

    was_valid_bull_edge := false
    was_valid_bear_edge := false
    was_valid_midline := false

    armed_bull_reclaim := false
    armed_bear_reclaim := false
    pending_bull_reclaim := false
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

    entry_labels_today := 0
    warning_labels_today := 0
    last_entry_label_bar := na
    last_warning_label_bar := na

//====================
// Break Detection
//====================
bull_break = orb_set and not is_orb_bar and close > orb_high
bear_break = orb_set and not is_orb_bar and close < orb_low

bull_break_event = bull_break and not bull_break[1]
bear_break_event = bear_break and not bear_break[1]

new_setup = false
confirmed_reclaim_event_raw = false
reclaim_warning_event = false

if bull_break_event
    bull_break_count += 1
    armed_bear_reclaim := true
    armed_bull_reclaim := false
    pending_bull_reclaim := false
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

if bear_break_event
    bear_break_count += 1
    armed_bull_reclaim := true
    armed_bear_reclaim := false
    pending_bull_reclaim := false
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

if bull_break and active_dir != 1
    active_dir := 1
    setup_mode := 1
    trigger_bar := bar_index
    new_setup := true

if bear_break and active_dir != -1
    active_dir := -1
    setup_mode := -1
    trigger_bar := bar_index
    new_setup := true

//====================
// Armed Reclaim Warning Logic
// A warning only happens after a fresh outside break armed it.
// It triggers on a close crossing back inside the ORB.
// It does NOT flip direction.
//====================
bull_low_reclaim_warning = orb_set and armed_bull_reclaim and not pending_bull_reclaim and close[1] <= orb_low and close > orb_low and close < orb_high
bear_high_reclaim_warning = orb_set and armed_bear_reclaim and not pending_bear_reclaim and close[1] >= orb_high and close < orb_high and close > orb_low

if bull_low_reclaim_warning
    pending_bull_reclaim := true
    pending_bear_reclaim := false
    pending_reclaim_bar := bar_index
    reclaim_warning_dir := 1
    bull_reclaim_warning_count += 1
    reclaim_warning_event := true

if bear_high_reclaim_warning
    pending_bear_reclaim := true
    pending_bull_reclaim := false
    pending_reclaim_bar := bar_index
    reclaim_warning_dir := -1
    bear_reclaim_warning_count += 1
    reclaim_warning_event := true

// Cancel pending warning if price rejects back outside.
if pending_bull_reclaim and close < orb_low
    pending_bull_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

if pending_bear_reclaim and close > orb_high
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

//====================
// Confirmed Reclaim Logic
// Confirmation requires at least one candle after the warning.
// Tightened hold confirmation:
// Long reclaim hold requires close > ORB low AND close > previous high.
// Short reclaim hold requires close < ORB high AND close < previous low.
//====================
vwap_value = ta.vwap(hlc3)

can_confirm_reclaim = not na(pending_reclaim_bar) and bar_index > pending_reclaim_bar

bull_reclaim_mid_confirm = pending_bull_reclaim and can_confirm_reclaim and close > orb_mid
bull_reclaim_vwap_confirm = pending_bull_reclaim and can_confirm_reclaim and close > vwap_value
bull_reclaim_hold_confirm = pending_bull_reclaim and can_confirm_reclaim and close > orb_low and close > high[1]

bear_reclaim_mid_confirm = pending_bear_reclaim and can_confirm_reclaim and close < orb_mid
bear_reclaim_vwap_confirm = pending_bear_reclaim and can_confirm_reclaim and close < vwap_value
bear_reclaim_hold_confirm = pending_bear_reclaim and can_confirm_reclaim and close < orb_high and close < low[1]

bull_reclaim_confirmed_now = bull_reclaim_mid_confirm or bull_reclaim_vwap_confirm or bull_reclaim_hold_confirm
bear_reclaim_confirmed_now = bear_reclaim_mid_confirm or bear_reclaim_vwap_confirm or bear_reclaim_hold_confirm

if bull_reclaim_confirmed_now
    active_dir := 1
    setup_mode := 2
    trigger_bar := bar_index
    confirmed_reclaim_count += 1
    new_setup := true
    confirmed_reclaim_event_raw := true

    armed_bull_reclaim := false
    armed_bear_reclaim := false
    pending_bull_reclaim := false
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

if bear_reclaim_confirmed_now
    active_dir := -1
    setup_mode := -2
    trigger_bar := bar_index
    confirmed_reclaim_count += 1
    new_setup := true
    confirmed_reclaim_event_raw := true

    armed_bull_reclaim := false
    armed_bear_reclaim := false
    pending_bull_reclaim := false
    pending_bear_reclaim := false
    pending_reclaim_bar := na
    reclaim_warning_dir := 0

if new_setup
    retest_high_count := 0
    retest_low_count := 0
    midline_reaction_count := 0

    was_valid_bull_edge := false
    was_valid_bear_edge := false
    was_valid_midline := false

setup_text =
     setup_mode == 1 ? "Breakout Long" :
     setup_mode == -1 ? "Breakout Short" :
     setup_mode == 2 ? "Confirmed Low Reclaim Long" :
     setup_mode == -2 ? "Confirmed High Reclaim Short" :
     "No setup yet"

reclaim_warning_text =
     pending_bull_reclaim ? "Low reclaim warning" :
     pending_bear_reclaim ? "High reclaim warning" :
     armed_bull_reclaim ? "Low reclaim armed" :
     armed_bear_reclaim ? "High reclaim armed" :
     "None"

//====================
// Retest / Reaction Logic
//====================
can_count_retest = orb_set and not is_orb_bar and active_dir != 0 and not na(trigger_bar) and bar_index > trigger_bar

bull_edge_level = setup_mode == 2 ? orb_low : orb_high
bear_edge_level = setup_mode == -2 ? orb_high : orb_low

bullish_edge_retest = can_count_retest and active_dir == 1 and low <= bull_edge_level + orb_retest_zone and close > bull_edge_level
bearish_edge_retest = can_count_retest and active_dir == -1 and high >= bear_edge_level - orb_retest_zone and close < bear_edge_level

bullish_midline_reaction = can_count_retest and active_dir == 1 and low <= orb_mid + orb_retest_zone and close > orb_mid
bearish_midline_reaction = can_count_retest and active_dir == -1 and high >= orb_mid - orb_retest_zone and close < orb_mid

if can_count_retest
    if active_dir == 1
        if bullish_edge_retest and not was_valid_bull_edge
            if not count_first_retest_only or retest_high_count == 0
                retest_high_count += 1

        if bullish_midline_reaction and not was_valid_midline
            if not count_first_retest_only or midline_reaction_count == 0
                midline_reaction_count += 1

        was_valid_bull_edge := bullish_edge_retest
        was_valid_bear_edge := false
        was_valid_midline := bullish_midline_reaction

    if active_dir == -1
        if bearish_edge_retest and not was_valid_bear_edge
            if not count_first_retest_only or retest_low_count == 0
                retest_low_count += 1

        if bearish_midline_reaction and not was_valid_midline
            if not count_first_retest_only or midline_reaction_count == 0
                midline_reaction_count += 1

        was_valid_bear_edge := bearish_edge_retest
        was_valid_bull_edge := false
        was_valid_midline := bearish_midline_reaction

edge_retest_count = retest_high_count + retest_low_count
total_retests = edge_retest_count + midline_reaction_count

edge_retest_confirmed = active_dir == 1 ? retest_high_count >= 1 : active_dir == -1 ? retest_low_count >= 1 : false
midline_reaction_confirmed = midline_reaction_count >= 1
confirmed_reclaim_active = setup_mode == 2 or setup_mode == -2

valid_reaction_confirmed = edge_retest_confirmed or confirmed_reclaim_active or (allow_midline_as_retest and midline_reaction_confirmed)

reaction_type =
     edge_retest_confirmed ? "ORB edge" :
     confirmed_reclaim_active ? "Confirmed reclaim" :
     midline_reaction_confirmed ? "Midline" :
     "None"

//====================
// Reclaim Continuation Event
// Long: confirmed low reclaim active, then price crosses back above ORB low.
// Short: confirmed high reclaim active, then price crosses back below ORB high.
//====================
long_reclaim_continuation = setup_mode == 2 and bar_index > trigger_bar and close > orb_low and close[1] <= orb_low
short_reclaim_continuation = setup_mode == -2 and bar_index > trigger_bar and close < orb_high and close[1] >= orb_high

reclaim_continuation_event = barstate.isconfirmed and (long_reclaim_continuation or short_reclaim_continuation)

if reclaim_continuation_event
    reclaim_continuation_count += 1

//====================
// Fresh Events
//====================
edge_retest_event = edge_retest_confirmed and not edge_retest_confirmed[1]
midline_event = midline_reaction_confirmed and not midline_reaction_confirmed[1]
confirmed_reclaim_event = confirmed_reclaim_event_raw

//====================
// HTF Trend
//====================
htf_close = request.security(syminfo.tickerid, htf_tf, close)
htf_ema = request.security(syminfo.tickerid, htf_tf, ta.ema(close, ema_len))

htf_bullish = htf_close > htf_ema
htf_trend = htf_bullish ? "BULLISH" : "BEARISH"

bias_aligned = active_dir != 0 and ((htf_bullish and active_dir == 1) or (not htf_bullish and active_dir == -1))

//====================
// Quality Filters
//====================
vwap_align = active_dir == 1 ? close > vwap_value : active_dir == -1 ? close < vwap_value : false

vol_sma = ta.sma(volume, vol_len)
volume_confirm = volume > vol_sma * vol_mult

slope_ema = ta.ema(close, slope_ema_len)
ema_slope_align = active_dir == 1 ? slope_ema > slope_ema[1] : active_dir == -1 ? slope_ema < slope_ema[1] : false

midline_side_align = active_dir == 1 ? close > orb_mid : active_dir == -1 ? close < orb_mid : false

atr_value = ta.atr(atr_len)
orb_atr_ratio = orb_set and atr_value > 0 ? orb_range / atr_value : na
range_quality_ok = orb_set and not na(orb_atr_ratio) and orb_atr_ratio >= min_orb_atr and orb_atr_ratio <= max_orb_atr

quality_score =
     (midline_side_align ? 1 : 0) +
     ((not vwap_enabled or vwap_align) ? 1 : 0) +
     ((not volume_enabled or volume_confirm) ? 1 : 0) +
     ((not ema_slope_enabled or ema_slope_align) ? 1 : 0) +
     ((not atr_enabled or range_quality_ok) ? 1 : 0)

//====================
// Target Guide
//====================
target_price = active_dir == 1 and orb_set ? orb_high + orb_range : active_dir == -1 and orb_set ? orb_low - orb_range : na

if orb_set and show_target_lines and active_dir != 0 and barstate.islast
    line.delete(target_line)
    start_bar_target = math.max(bar_index - 100, 0)
    target_line := line.new(start_bar_target, target_price, bar_index, target_price, color=color.new(color.orange, 25), width=1, style=line.style_dashed, extend=extend.right)

//====================
// Core Score
//====================
check_orb_set = orb_set
check_setup = active_dir != 0
check_reaction = valid_reaction_confirmed
check_retests_ok = total_retests <= max_retests
check_bias = bias_aligned

core_score =
     (check_orb_set ? 1 : 0) +
     (check_setup ? 1 : 0) +
     (check_reaction ? 1 : 0) +
     (check_retests_ok ? 1 : 0) +
     (check_bias ? 1 : 0)

best_setup = use_quality_score and core_score >= 5 and quality_score >= min_quality_for_best
look_for_entry = core_score >= 5 and check_reaction and check_bias

verdict = best_setup ? "BEST SETUP" : look_for_entry ? "LOOK FOR ENTRY" : core_score >= 3 ? "PARTIAL - WAIT" : "STAND ASIDE"

//====================
// Label Safety
//====================
cooldown_ok = na(last_entry_label_bar) or bar_index - last_entry_label_bar >= label_cooldown_bars
daily_label_ok = entry_labels_today < max_entry_labels_per_day

entry_event = barstate.isconfirmed and look_for_entry and (edge_retest_event or midline_event or confirmed_reclaim_event or reclaim_continuation_event) and cooldown_ok and daily_label_ok

warning_cooldown_ok = na(last_warning_label_bar) or bar_index - last_warning_label_bar >= label_cooldown_bars
warning_event = barstate.isconfirmed and reclaim_warning_event and warning_cooldown_ok

//====================
// Colors
//====================
col_bg = color.rgb(13, 13, 13)
col_header = color.rgb(26, 26, 46)
col_pass = color.rgb(0, 193, 124)
col_fail = color.rgb(224, 82, 96)
col_neutral = color.rgb(240, 192, 64)
col_orange = color.rgb(255, 165, 0)
col_text = color.rgb(255, 255, 255)
col_sub = color.rgb(160, 160, 176)

verdict_col = best_setup ? col_orange : look_for_entry ? col_pass : core_score >= 3 ? col_neutral : col_fail

PASS = "[Y]"
FAIL = "[N]"
WARN = "[!]"

status(cond) =>
    [cond ? PASS : FAIL, cond ? col_pass : col_fail]

//====================
// Dashboard Position
//====================
t_pos = switch dash_y + dash_x
    "topleft" => position.top_left
    "topcenter" => position.top_center
    "topright" => position.top_right
    "middleleft" => position.middle_left
    "middlecenter" => position.middle_center
    "middleright" => position.middle_right
    "bottomleft" => position.bottom_left
    "bottomcenter" => position.bottom_center
    "bottomright" => position.bottom_right
    => position.top_right

//====================
// Dashboard
//====================
var table dash = na

if barstate.islast
    table.delete(dash)

    dash := table.new(t_pos, 3, 25, bgcolor=col_bg, border_color=color.rgb(128, 128, 128), border_width=1, frame_color=color.rgb(100, 100, 100), frame_width=1)

    table.cell(dash, 0, 0, "ORB READINESS PLUS", text_color=col_text, bgcolor=col_header, text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 0, "", text_color=col_text, bgcolor=col_header)
    table.cell(dash, 2, 0, "", text_color=col_text, bgcolor=col_header)

    table.cell(dash, 0, 1, "CORE CONDITION", text_color=col_sub, bgcolor=col_header, text_size=size.small)
    table.cell(dash, 1, 1, "STATUS", text_color=col_sub, bgcolor=col_header, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 1, "DETAIL", text_color=col_sub, bgcolor=col_header, text_size=size.small)

    [s1_icon, s1_col] = status(check_orb_set)
    table.cell(dash, 0, 2, "ORB Set", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 2, s1_icon, text_color=s1_col, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 2, check_orb_set ? str.tostring(orb_high, "#.####") + " / " + str.tostring(orb_low, "#.####") : "Waiting", text_color=col_sub, text_size=size.tiny)

    [s2_icon, s2_col] = status(check_setup)
    table.cell(dash, 0, 3, "Setup Trigger", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 3, check_orb_set ? s2_icon : "-", text_color=check_orb_set ? s2_col : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 3, check_orb_set ? setup_text : "ORB pending", text_color=col_sub, text_size=size.tiny)

    [s3_icon, s3_col] = status(edge_retest_confirmed)
    table.cell(dash, 0, 4, "ORB Edge Retest", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 4, check_setup ? s3_icon : "-", text_color=check_setup ? s3_col : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 4, check_setup ? "H:" + str.tostring(retest_high_count) + " L:" + str.tostring(retest_low_count) : "Need setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 5, "Reclaim State", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 5, reclaim_warning_dir != 0 ? WARN : "-", text_color=reclaim_warning_dir != 0 ? col_neutral : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 5, reclaim_warning_text, text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 6, "Confirmed Reclaim", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 6, confirmed_reclaim_active ? PASS : WARN, text_color=confirmed_reclaim_active ? col_pass : col_neutral, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 6, "C:" + str.tostring(confirmed_reclaim_count), text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 7, "Reclaim Continuation", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 7, reclaim_continuation_count > 0 ? PASS : "-", text_color=reclaim_continuation_count > 0 ? col_pass : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 7, "RC:" + str.tostring(reclaim_continuation_count), text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 8, "Midline Reaction", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 8, check_setup ? (midline_reaction_confirmed ? PASS : WARN) : "-", text_color=check_setup ? (midline_reaction_confirmed ? col_pass : col_neutral) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 8, check_setup ? "M:" + str.tostring(midline_reaction_count) + (allow_midline_as_retest ? " allowed" : " info only") : "Need setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 9, "Valid Reaction", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 9, check_setup ? (check_reaction ? PASS : FAIL) : "-", text_color=check_setup ? (check_reaction ? col_pass : col_fail) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 9, check_setup ? reaction_type : "Need setup", text_color=col_sub, text_size=size.tiny)

    retest_warn = total_retests > max_retests
    [s4_icon, s4_col] = status(check_retests_ok)
    table.cell(dash, 0, 10, "Retest Count OK", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 10, check_setup ? (retest_warn ? WARN : s4_icon) : "-", text_color=check_setup ? (retest_warn ? col_neutral : s4_col) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 10, check_setup ? str.tostring(total_retests) + " of max " + str.tostring(max_retests) : "Need setup", text_color=retest_warn ? col_neutral : col_sub, text_size=size.tiny)

    table.cell(dash, 0, 11, "HTF Trend", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 11, htf_bullish ? "[UP]" : "[DN]", text_color=htf_bullish ? col_pass : col_fail, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 11, htf_trend + " " + htf_tf + " EMA" + str.tostring(ema_len), text_color=htf_bullish ? col_pass : col_fail, text_size=size.tiny)

    table.cell(dash, 0, 12, "Bias Align", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 12, check_setup ? (bias_aligned ? PASS : WARN) : "-", text_color=check_setup ? (bias_aligned ? col_pass : col_neutral) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 12, check_setup ? (bias_aligned ? "Direction matches HTF" : "Direction vs HTF conflict") : "No setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 13, "Direction", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 13, active_dir == 1 ? "LONG" : active_dir == -1 ? "SHORT" : "-", text_color=active_dir == 1 ? col_pass : active_dir == -1 ? col_fail : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 13, active_dir == 1 ? "Long idea active" : active_dir == -1 ? "Short idea active" : "Wait for setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 14, "COUNTS", text_color=col_sub, bgcolor=col_header, text_size=size.small)
    table.cell(dash, 1, 14, "DAY", text_color=col_sub, bgcolor=col_header, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 14, "DETAIL", text_color=col_sub, bgcolor=col_header, text_size=size.small)

    table.cell(dash, 0, 15, "Breaks", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 15, str.tostring(bull_break_count + bear_break_count), text_color=col_text, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 15, "H:" + str.tostring(bull_break_count) + " L:" + str.tostring(bear_break_count), text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 16, "Reclaim Warnings", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 16, str.tostring(bull_reclaim_warning_count + bear_reclaim_warning_count), text_color=col_text, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 16, "Bull:" + str.tostring(bull_reclaim_warning_count) + " Bear:" + str.tostring(bear_reclaim_warning_count), text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 17, "QUALITY FILTER", text_color=col_sub, bgcolor=col_header, text_size=size.small)
    table.cell(dash, 1, 17, "STATUS", text_color=col_sub, bgcolor=col_header, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 17, "DETAIL", text_color=col_sub, bgcolor=col_header, text_size=size.small)

    table.cell(dash, 0, 18, "Midline Side", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 18, check_setup ? (midline_side_align ? PASS : WARN) : "-", text_color=check_setup ? (midline_side_align ? col_pass : col_neutral) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 18, check_setup ? (active_dir == 1 ? "Above ORB mid" : "Below ORB mid") : "No setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 19, "VWAP Align", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 19, check_setup ? (vwap_align ? PASS : WARN) : "-", text_color=check_setup ? (vwap_align ? col_pass : col_neutral) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 19, close > vwap_value ? "Price above VWAP" : "Price below VWAP", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 20, "Volume Confirm", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 20, volume_confirm ? PASS : WARN, text_color=volume_confirm ? col_pass : col_neutral, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 20, "Vol vs SMA" + str.tostring(vol_len), text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 21, "EMA Slope", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 21, check_setup ? (ema_slope_align ? PASS : WARN) : "-", text_color=check_setup ? (ema_slope_align ? col_pass : col_neutral) : col_sub, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 21, active_dir == 1 ? "EMA rising" : active_dir == -1 ? "EMA falling" : "No setup", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 22, "Range Quality", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 22, range_quality_ok ? PASS : WARN, text_color=range_quality_ok ? col_pass : col_neutral, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 22, orb_set ? "ORB/ATR " + str.tostring(orb_atr_ratio, "#.##") : "ORB pending", text_color=col_sub, text_size=size.tiny)

    table.cell(dash, 0, 23, "Scores", text_color=col_text, text_size=size.small)
    table.cell(dash, 1, 23, str.tostring(core_score) + "/5", text_color=core_score >= 5 ? col_pass : core_score >= 3 ? col_neutral : col_fail, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 23, "Quality " + str.tostring(quality_score) + "/5", text_color=quality_score >= min_quality_for_best ? col_pass : col_neutral, text_size=size.tiny)

    table.cell(dash, 0, 24, verdict, text_color=verdict_col, bgcolor=color.new(verdict_col, 85), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 24, "", text_color=verdict_col, bgcolor=color.new(verdict_col, 85), text_size=size.small)
    table.cell(dash, 2, 24, "", text_color=verdict_col, bgcolor=color.new(verdict_col, 85), text_size=size.small)

//====================
// Triangle Signals
// Replaces text labels with solid colored triangles
//====================

// Main entry triangles
long_entry_triangle = show_entry_labels and entry_event and active_dir == 1
short_entry_triangle = show_entry_labels and entry_event and active_dir == -1

plotshape(
     long_entry_triangle,
     title="Long Entry Triangle",
     style=shape.triangleup,
     location=location.belowbar,
     color=best_setup ? col_orange : col_pass,
     size=size.small
)

plotshape(
     short_entry_triangle,
     title="Short Entry Triangle",
     style=shape.triangledown,
     location=location.abovebar,
     color=best_setup ? col_orange : col_fail,
     size=size.small
)

// Reclaim warning triangles, optional
bull_warning_triangle = show_reclaim_warning_labels and warning_event and reclaim_warning_dir == 1
bear_warning_triangle = show_reclaim_warning_labels and warning_event and reclaim_warning_dir == -1

plotshape(
     bull_warning_triangle,
     title="Bullish Reclaim Warning Triangle",
     style=shape.triangleup,
     location=location.belowbar,
     color=col_neutral,
     size=size.tiny
)

plotshape(
     bear_warning_triangle,
     title="Bearish Reclaim Warning Triangle",
     style=shape.triangledown,
     location=location.abovebar,
     color=col_neutral,
     size=size.tiny
)

// Midline triangles, optional
bull_midline_triangle = show_midline_labels and midline_event and active_dir == 1
bear_midline_triangle = show_midline_labels and midline_event and active_dir == -1

plotshape(
     bull_midline_triangle,
     title="Bullish Midline Triangle",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.gray,
     size=size.tiny
)

plotshape(
     bear_midline_triangle,
     title="Bearish Midline Triangle",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.gray,
     size=size.tiny
)

// Keep counters working without text labels
if show_reclaim_warning_labels and warning_event
    warning_labels_today += 1
    last_warning_label_bar := bar_index

if show_entry_labels and entry_event
    entry_labels_today += 1
    last_entry_label_bar := bar_index

//====================
// Visuals
//====================
bgcolor(is_orb_bar ? color.new(color.yellow, 88) : na, title="ORB Formation Highlight")

plot(orb_high, "ORB High", display=display.data_window, color=color.new(color.green, 60))
plot(orb_low, "ORB Low", display=display.data_window, color=color.new(color.red, 60))
plot(orb_mid, "ORB Midline", display=display.data_window, color=color.new(color.gray, 60))
plot(vwap_value, "VWAP", color=color.new(color.blue, 30))

plot(core_score, "Core Score", display=display.data_window)
plot(quality_score, "Quality Score", display=display.data_window)
plot(bull_break_count, "Bull Break Count", display=display.data_window)
plot(bear_break_count, "Bear Break Count", display=display.data_window)
plot(edge_retest_count, "ORB Edge Retests", display=display.data_window)
plot(midline_reaction_count, "Midline Reactions", display=display.data_window)
plot(bull_reclaim_warning_count + bear_reclaim_warning_count, "Reclaim Warnings", display=display.data_window)
plot(confirmed_reclaim_count, "Confirmed Reclaims", display=display.data_window)
plot(reclaim_continuation_count, "Reclaim Continuations", display=display.data_window)
plot(total_retests, "Total Retests", display=display.data_window)
plot(orb_atr_ratio, "ORB / ATR Ratio", display=display.data_window)

//====================
// Alerts
//====================
alertcondition(bull_break_event, "Bullish ORB Break", "Price closed above ORB high.")
alertcondition(bear_break_event, "Bearish ORB Break", "Price closed below ORB low.")
alertcondition(reclaim_warning_event, "ORB Reclaim Warning", "Price reclaimed a broken ORB edge. Wait for confirmation.")
alertcondition(confirmed_reclaim_event, "Confirmed ORB Reclaim", "ORB reclaim confirmed.")
alertcondition(reclaim_continuation_event, "ORB Reclaim Continuation", "Confirmed reclaim continuation trigger.")
alertcondition(edge_retest_event, "ORB Edge Retest Confirmed", "Price retested the ORB edge in the active direction.")
alertcondition(midline_event, "ORB Midline Reaction Confirmed", "Price reacted from the ORB midline in the active direction.")
alertcondition(entry_event, "ORB Entry Event", "Fresh ORB entry event confirmed.")
alertcondition(total_retests > max_retests and total_retests[1] <= max_retests, "Excessive ORB Retests", "ORB has been retested more than your max setting.")
````

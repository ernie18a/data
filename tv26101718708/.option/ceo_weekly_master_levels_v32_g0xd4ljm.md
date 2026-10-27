# CEO - Weekly Master Levels (v32)

- url: https://www.tradingview.com/script/G0xD4LJM-CEO-Weekly-Master-Levels-v32/
- type: indicator
- pine_id: PUB;8605c30f7db549e19d111204781f2c59
- version: 1.0

## Description

Core Levels Plotted                                                                                                                                    
  - MH / ML — Current week's high and low (first trading day develops live; locked Tue–Fri)
  - PMH / PML — Previous week's high and low                                               
  - Monthly Open (MO) — Up to 24 months of monthly opens                                                                                                   
  - Monthly H/L — Current and historical monthly high/low ranges                                                                                           
  - Mid — Midpoint of the weekly range (used as a momentum void filter)                                                                                    
                                                                                                                                                                                            
                                                                                                                                                         
  Risk Management                                                                                                                                          
  - 5 stop modes: ATR-from-structure, fixed buffer, signal-bar invalidation, hybrid, legacy                                                              
  - Projected take-profit via: current week MH/ML, fixed-R, prior-week structural targets, or EMA trail                                                    
   
  Key Filters                                                                                                                                              
  - RTH-only (pre-market wicks excluded)                                                                                                                 
  - Touch hysteresis (entry + release bands) to prevent level-hover chop                                                                                   
  - Mid-range momentum void (MMR) for continuation trades                                                                                                
  - Consolidation guard (time-based cooldown between same-direction signals)                                                                               
  - First-weekly-day family gates (reactions and flips can be independently allowed/blocked)                                                               
                                                                                                                                                           
  Alerts: Entry signals, weekly level breaks/reclaims, EMA crosses, MTF SMA50 state changes.

## Source Code

````pine
//@version=6
indicator("Weekly Master Levels (v32)", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// 1. INPUTS
// ============================================================================
// Stage 7 governance contracts:
// - Only the Signal Logic (Policy + Tactical) group should be considered part
//   of the executable strategy surface.
// - Visual, telemetry, and monitor groups are intentionally non-strategy and
//   should be excluded from parameter optimization.
// - Treat family toggles, first-weekly-day permissions, stop mode, and chart
//   timeframe as policy decisions; treat stop/touch/time windows as tactical
//   calibration; test high-risk knobs in coarse ranges only.

grp_sma       = "Trend Filters (Visual)"
show_sma50    = input.bool(true, "Show SMA 50", group=grp_sma)
col_sma50     = input.color(color.blue, "SMA 50 Color", group=grp_sma)
show_sma100   = input.bool(false, "Show SMA 100", group=grp_sma)
col_sma100    = input.color(color.orange, "SMA 100 Color", group=grp_sma)
show_sma200   = input.bool(false, "Show SMA 200", group=grp_sma)
col_sma200    = input.color(color.black, "SMA 200 Color", group=grp_sma)

grp_ema        = "EMA Ribbon (Visual / Alert-Only)"
show_ema       = input.bool(true,  "Show EMA Ribbon", group=grp_ema)
ema_fast_len   = input.int(12, "Fast EMA Length", minval=1, group=grp_ema)
ema_slow_len   = input.int(25, "Slow EMA Length", minval=1, group=grp_ema)
col_ema_bull   = input.color(color.green, "Bull Color (Fast > Slow)", group=grp_ema)
col_ema_bear   = input.color(color.red,   "Bear Color (Fast < Slow)", group=grp_ema)
show_ema_cross = input.bool(true, "Show Cross Signal", group=grp_ema)
use_ema_alert  = input.bool(true, "Alert on EMA Cross", group=grp_ema)

grp_mon       = "Weekly Levels (Visual)"
show_cur_mon  = input.bool(true, "Show Current Week Levels", group=grp_mon)
col_mh        = input.color(color.green, "Weekly High (MH)", group=grp_mon)
col_ml        = input.color(color.red, "Weekly Low (ML)", group=grp_mon)
show_mid      = input.bool(true, "Show Mid-Range", group=grp_mon)
col_mid       = input.color(color.gray, "Mid-Range Color", group=grp_mon)
show_prev_mon = input.bool(true, "Show Previous Week Levels", group=grp_mon)
col_pmh       = input.color(color.new(color.green, 50), "Previous MH", group=grp_mon)
col_pml       = input.color(color.new(color.red, 50), "Previous ML", group=grp_mon)

grp_monthly   = "Monthly Levels (Visual)"
show_mo       = input.bool(true, "Show Monthly Open", group=grp_monthly)
col_mo        = input.color(color.purple, "Monthly Open Color", group=grp_monthly)
mo_count      = input.int(3, "Months to Show", minval=1, maxval=24, group=grp_monthly,
     tooltip="Number of monthly open levels to draw. 1 = current month only. Max 24.")
show_month_hl      = input.bool(true, "Show Monthly High/Low", group=grp_monthly)
col_month_h        = input.color(color.new(color.teal, 0), "Monthly High Color", group=grp_monthly)
col_month_l        = input.color(color.new(color.maroon, 0), "Monthly Low Color", group=grp_monthly)
show_month_mid     = input.bool(false, "Show Monthly Mid-Range", group=grp_monthly)
col_month_mid      = input.color(color.new(color.gray, 30), "Monthly Mid Color", group=grp_monthly)
show_month_labels  = input.bool(true, "Show Monthly H/L Labels", group=grp_monthly)

// Governance note: the input groups below are intentionally separated by role.
// - Signal Logic (Combo) contains the core policy selectors plus tactical
//   calibration knobs that can change accepted trades and computed stops.
grp_sig       = "Signal Logic (Policy + Tactical)"
show_signals  = input.bool(true, "Show Long/Short Signals", group=grp_sig, tooltip="Visual only. Shows accepted signal markers/labels without changing acceptance logic.")
show_stop_l   = input.bool(true, "Show Stop Loss (Long)", group=grp_sig, tooltip="Visual only. Controls long stop plotting/labels after acceptance. Does not change stop computation.")
show_stop_s   = input.bool(false, "Show Stop Loss (Short)", group=grp_sig, tooltip="Visual only. Controls short stop plotting/labels after acceptance. Does not change stop computation.")
atr_len       = input.int(14, "ATR Length", minval=1, group=grp_sig, tooltip="Tactical stop calibration input. Active in ATR from Structure (Structural), Hybrid (Wider), and Legacy ATR from Close, Structure-Clamped (Legacy). Test coarsely; avoid dense optimization.")
atr_mult      = input.float(0.8, "ATR Multiplier", minval=0.1, step=0.1, group=grp_sig,
     tooltip="Tactical stop calibration multiplier. Active in ATR from Structure (Structural), Hybrid (Wider), and Legacy ATR from Close, Structure-Clamped (Legacy). This is a high overfit-risk knob; test in coarse steps.")
stop_mode     = input.string("Hybrid (Wider)", "Stop Mode",
     options=["ATR from Structure (Structural)", "Structure + Fixed Buffer (Fixed)", "Signal Bar Invalidation (Trigger)", "Hybrid (Wider)", "Legacy ATR from Close, Structure-Clamped (Legacy)"],
     tooltip="Professional stop-policy selector. Structural modes anchor to ML/MH by signal family. Hybrid (Wider) uses the wider stop between ATR-from-structure and signal-bar invalidation. Legacy ATR from Close, Structure-Clamped (Legacy) preserves the prior close-anchored ATR behavior.",
     group=grp_sig)
fixed_buffer_ticks   = input.int(2, "Fixed Buffer (Ticks)", minval=0, group=grp_sig,
     tooltip="Tactical stop calibration in ticks. Active in Structure + Fixed Buffer (Fixed), Signal Bar Invalidation (Trigger), and the signal-bar leg of Hybrid (Wider). Test in coarse steps.")
min_stop_floor_ticks = input.int(1, "Minimum Stop Floor (Ticks)", minval=0, group=grp_sig,
     tooltip="Minimum absolute stop floor applied to Structural, Fixed, Trigger, and Hybrid calculations to avoid unrealistically tight stops. Legacy preserves the prior raw ATR-from-close behavior before structure clamp.")
touch_tolerance = input.float(0.5, "Touch Tolerance (%)", minval=0.0, maxval=2.0, step=0.1,
     tooltip="High overfit-risk touch geometry knob. Proximity buffer for level touches. 0 = exact touch required. 0.5 = within 0.5% of level counts as touch. Prefer coarse reviews instead of dense sweeps.",
     group=grp_sig)
release_mult = input.float(2.0, "Touch Release Multiplier", minval=1.0, step=0.1,
     tooltip="High overfit-risk hysteresis knob. Touch entry uses Touch Tolerance (%). Re-arm requires price to leave a wider release band equal to tolerance × multiplier. 2.0 = release band is twice as wide as the entry band.",
     group=grp_sig)
valid_minutes = input.int(300, "Max Minutes Validity (Recency)", minval=1,
     tooltip="High overfit-risk freshness window. Touch must be within this many minutes to be valid. 300 = 5 hours. Review as a policy range, not a fine-tuned precision setting.",
     group=grp_sig)
consol_minutes = input.int(45, "Consolidation Guard (Minutes)", minval=1,
     tooltip="High overfit-risk cadence guard. Suppresses duplicate signals within this time window. Review together with Max Minutes Validity (Recency), not as an isolated optimizer target.",
     group=grp_sig)
enable_reactions = input.bool(true, "Enable Reactions",
     tooltip="Core policy switch. Enables reaction-family trades: ML Bounce, MH Rejection, and SMA50 Reversal. Treat as a scenario choice, not a fine-tuning knob.",
     group=grp_sig)
enable_flips     = input.bool(false, "Enable Flips",
     tooltip="Core policy switch. Enables flip-family trades: MH/ML Flip Pullback and Momentum paths. Treat as a scenario choice, not a fine-tuning knob.",
     group=grp_sig)
allow_reactions_first_day = input.bool(true, "Allow Reactions on First Weekly Day",
     tooltip="Core policy switch. When OFF, reaction-family trades are discarded on the first weekly trading day based on the script's weekly reset logic. This is a regime choice, not a tactical optimizer input.",
     group=grp_sig)
allow_flips_first_day     = input.bool(false, "Allow Flips on First Weekly Day",
     tooltip="Core policy switch. When OFF, flip-family trades are discarded on the first weekly trading day based on the script's weekly reset logic. This is a regime choice, not a tactical optimizer input.",
     group=grp_sig)

// Governance note: Visual Styling and Scanner groups below are operator-facing
// only. They do not change signal acceptance logic.
grp_style     = "Visual Styling (Non-Strategy)"
compact_mode  = input.bool(true, "Compact Mode (Reduce Clutter)",
     tooltip="Hides text labels on EMA cross signals. GO signals always retain their label.",
     group=grp_style)
sl_txt        = input.string("SL", "Stop Loss Label Text", group=grp_style)
sl_size       = input.string(size.small, "Stop Loss Label Size", options=[size.tiny, size.small, size.normal, size.large], group=grp_style)
sl_col_txt    = input.color(color.white, "Stop Loss Text Color", group=grp_style)
max_sl_labels = input.int(20, "Max Stop Loss Labels (per direction)", minval=1, maxval=100, group=grp_style)

grp_scan           = "Scanner / Telemetry (Non-Strategy)"
use_scan_alert     = input.bool(true, "Alert on Signals", group=grp_scan, tooltip="Telemetry only. Controls dynamic production alert() messages for accepted signals without changing trade logic.")
alert_long_signals = input.bool(true, "Alert Long Signals", group=grp_scan, tooltip="Controls dynamic LONG signal alert() messages only. Does not change signal logic.")
alert_short_signals= input.bool(false, "Alert Short Signals", group=grp_scan, tooltip="Controls dynamic SHORT signal alert() messages only. Does not change signal logic.")

grp_exit            = "Trade Management Projection (Non-Execution)"
show_tp_l           = input.bool(true, "Show Take Profit (Long)", group=grp_exit, tooltip="Visual/export only. Shows projected long take-profit markers/series without changing entry logic.")
show_tp_s           = input.bool(false, "Show Take Profit (Short)", group=grp_exit, tooltip="Visual/export only. Shows projected short take-profit markers/series without changing entry logic.")
monday_exit_mode    = input.string("Fixed R", "Monday Exit Projection Mode",
     options=["Developing MH/ML", "Fixed R", "Prior-Week Structural", "EMA Trail (No Static TP)"],
     tooltip="Projection only. Monday uses a separate exit regime because the current week's range is still forming. This pass computes projected TP levels/metadata without changing entry acceptance logic.",
     group=grp_exit)
weekly_exit_mode    = input.string("Current Week MH/ML", "Tue-Fri Exit Projection Mode",
     options=["Current Week MH/ML", "Fixed R", "Prior-Week Structural", "EMA Trail (No Static TP)"],
     tooltip="Projection only. Tuesday-Friday assumes current-week ML/MH are fixed for exit projection purposes. This pass computes projected TP levels/metadata without changing entry acceptance logic.",
     group=grp_exit)
tp_r_multiple       = input.float(2.0, "Fixed R Multiple", minval=0.25, step=0.25,
     tooltip="Projection only. Used when the selected exit projection mode is Fixed R. 2.0 = target at two times initial risk.",
     group=grp_exit)
struct_align_pct    = input.float(2.0, "Prior-Week Alignment Window (% of prior range)", minval=0.0, maxval=100.0, step=1.0,
     tooltip="Projection only. When current ML/MH is within this percentage of the prior week's corresponding level, the model treats the structure as aligned.",
     group=grp_exit)
struct_ext_mult     = input.float(1.0, "Prior-Week Extension Multiple", minval=0.25, step=0.25,
     tooltip="Projection only. When current structure is already beyond the prior week's range, extension targets use prior-range size multiplied by this value.",
     group=grp_exit)
ema_exit_closes_req = input.int(2, "EMA Trail Consecutive Closes", minval=1,
     tooltip="Projection only. Used by EMA Trail mode as the required consecutive closes beyond EMA12 and EMA25 before a dynamic exit would trigger. This mode has no static TP price.",
     group=grp_exit)

// Stage 7 governance: no-trade-zone inputs intentionally removed for this
// release. This avoids exposing a mixed display/execution control surface in
// TradingView. Reintroduce later only as an explicit policy control.
// grp_zone      = "Discipline Zone"
// show_zone     = input.bool(false, "Show No-Trade Zone", group=grp_zone)
// time_zone     = input.session("1200-1330", "No-Trade Time", group=grp_zone)
// col_zone      = input.color(color.new(color.gray, 90), "Zone Color", group=grp_zone)

grp_sma_alert     = "SMA50 Monitor Alert (Non-Strategy)"
use_sma_alert     = input.bool(false, "Enable SMA50 Monitor Alert", group=grp_sma_alert,
     tooltip="Alert timeframe must be >= chart timeframe. If not, alert is automatically disabled.")
tf_sma_alert      = input.timeframe("5", "SMA50 Alert Timeframe", group=grp_sma_alert, tooltip="Monitoring-only timeframe. Keep separate from strategy tests because this alert family does not change signal acceptance logic.")
alert_sma_reclaim = input.bool(true,  "Alert on SMA50 Reclaim", group=grp_sma_alert)
alert_sma_loss    = input.bool(true,  "Alert on SMA50 Loss",    group=grp_sma_alert)

// ============================================================================
// 2. HELPER FUNCTIONS
// ============================================================================

f_month_name(int t) =>
    m = month(t)
    switch m
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        => "Dec"

f_right_edge_time(int bars_forward) =>
    bar_ms = int(nz(time - time[1], timeframe.in_seconds() * 1000))
    time + bar_ms * bars_forward

f_fixed_r_target_long(float entry_price, float stop_price, float r_mult) =>
    risk = entry_price - stop_price
    risk > 0 ? entry_price + (risk * r_mult) : na

f_fixed_r_target_short(float entry_price, float stop_price, float r_mult) =>
    risk = stop_price - entry_price
    risk > 0 ? entry_price - (risk * r_mult) : na

f_struct_target_long(float cur_ml, float cur_mh, float prev_pml, float prev_pmh, float align_pct, float ext_mult) =>
    prev_range = prev_pmh - prev_pml
    align_band = prev_range * (align_pct / 100.0)
    float tgt = na
    if na(cur_ml) or na(cur_mh) or na(prev_pml) or na(prev_pmh) or prev_range <= 0
        tgt := cur_mh
    else if math.abs(cur_ml - prev_pml) <= align_band
        tgt := cur_mh
    else if cur_ml < (prev_pml - align_band)
        tgt := prev_pml
    else if cur_ml > (prev_pmh + align_band)
        tgt := cur_ml + (prev_range * ext_mult)
    else
        tgt := prev_pmh
    tgt

f_struct_target_short(float cur_mh, float cur_ml, float prev_pmh, float prev_pml, float align_pct, float ext_mult) =>
    prev_range = prev_pmh - prev_pml
    align_band = prev_range * (align_pct / 100.0)
    float tgt = na
    if na(cur_mh) or na(cur_ml) or na(prev_pmh) or na(prev_pml) or prev_range <= 0
        tgt := cur_ml
    else if math.abs(cur_mh - prev_pmh) <= align_band
        tgt := cur_ml
    else if cur_mh > (prev_pmh + align_band)
        tgt := prev_pmh
    else if cur_mh < (prev_pml - align_band)
        tgt := cur_mh - (prev_range * ext_mult)
    else
        tgt := prev_pml
    tgt

// ============================================================================
// 3. DATA CALCULATIONS
// ============================================================================

// Force Regular Trading Hours (RTH) to prevent pre-market wicks skewing levels.
// Spread/custom symbols cannot be rebuilt with ticker.new(...), so fall back to
// the chart's native tickerid for level sourcing in those cases.
first_colon_pos     = str.pos(syminfo.tickerid, ":")
rest_after_exchange = first_colon_pos != -1 ? str.substring(syminfo.tickerid, first_colon_pos + 1) : syminfo.tickerid
has_second_prefix   = str.pos(rest_after_exchange, ":") != -1

string t_rth = na
if has_second_prefix
    t_rth := syminfo.tickerid
else
    t_rth := ticker.new(syminfo.prefix, syminfo.ticker, session.regular)

// Canonical tradable-session flag, aligned to the same RTH source used for
// weekly/monthly structural levels. With gaps_on, non-session bars remain na.
rth_bar_time = request.security(t_rth, timeframe.period, time, gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
in_tradable_session = not na(rth_bar_time)

// A. Chart Data
chart_sma50  = ta.sma(close, 50)
chart_sma100 = ta.sma(close, 100)
chart_sma200 = ta.sma(close, 200)
chart_atr    = ta.atr(atr_len)

// B. EMA Ribbon
chart_ema_fast = ta.ema(close, ema_fast_len)
chart_ema_slow = ta.ema(close, ema_slow_len)
ema_bull_cond  = chart_ema_fast > chart_ema_slow
ema_col        = ema_bull_cond ? col_ema_bull : col_ema_bear
ema_bull_cross = ta.crossover(chart_ema_fast,  chart_ema_slow)
ema_bear_cross = ta.crossunder(chart_ema_fast, chart_ema_slow)

// SMA50 Monitor — MTF data (lookahead_off to prevent repainting)
sma_alert_close = request.security(syminfo.tickerid, tf_sma_alert, close,             lookahead=barmerge.lookahead_off)
sma_alert_sma50 = request.security(syminfo.tickerid, tf_sma_alert, ta.sma(close, 50), lookahead=barmerge.lookahead_off)

// Auto-disable if selected TF is smaller than chart TF (alert would be late/useless)
tf_mismatch      = timeframe.in_seconds(tf_sma_alert) < timeframe.in_seconds()
sma_alert_active = use_sma_alert and not tf_mismatch

// C. Weekly Levels
// Time-honest weekly model:
// - On the first tradable RTH day of each week, MH/ML DEVELOP intraday from
//   the actual RTH bars seen so far.
// - After that first day completes, the finalized first-day range is pulled
//   from a completed daily RTH series (lookahead_off) and held frozen for the
//   remainder of the week.
// - Previous-week PMH/PML are sourced only from completed daily data.
f_weekly_levels() =>
    var float cur_h  = na, var float cur_l  = na
    var float prev_h = na, var float prev_l = na
    is_new_week = ta.change(time("W")) != 0
    if is_new_week
        prev_h := cur_h
        prev_l := cur_l
        cur_h  := high
        cur_l  := low
    [cur_h, cur_l, prev_h, prev_l]

// Completed daily RTH values only: safe for locked Tue-Fri weekly levels and
// previous-week references. On the first trading day itself these remain
// unavailable until the day is complete, which is exactly what we want.
[d_locked_mh, d_locked_ml, d_pmh, d_pml] = request.security(t_rth, "D", f_weekly_levels(), lookahead=barmerge.lookahead_off)

// First weekly trading day flag is day-identity only, not a forward-looking
// price series. Holidays remain safe because the first available RTH day of the
// new week is marked as the first weekly day.
is_first_weekly_day = request.security(t_rth, "D", ta.change(time("W")) != 0 ? 1 : 0,
     lookahead=barmerge.lookahead_on) == 1

var float d_mh = na
var float d_ml = na
var float d_mid = na
var float dev_week_mh = na
var float dev_week_ml = na

if ta.change(time("W")) != 0
    dev_week_mh := na
    dev_week_ml := na

if is_first_weekly_day and in_tradable_session
    if ta.change(time("W")) != 0 or not is_first_weekly_day[1]
        dev_week_mh := high
        dev_week_ml := low
    else
        dev_week_mh := na(dev_week_mh) ? high : math.max(dev_week_mh, high)
        dev_week_ml := na(dev_week_ml) ? low : math.min(dev_week_ml, low)

if is_first_weekly_day
    d_mh := dev_week_mh
    d_ml := dev_week_ml
else
    d_mh := d_locked_mh
    d_ml := d_locked_ml

if not is_first_weekly_day and is_first_weekly_day[1]
    dev_week_mh := na
    dev_week_ml := na

d_mid := (d_mh + d_ml) / 2

// D. Monthly Open
// Uses RTH ticker and monthly open — stable value regardless of chart timeframe.
// A new level is captured on the first bar of each calendar month.
// Stores up to mo_count months; oldest is dropped automatically.
mo_open_rth = request.security(t_rth, "M", open, lookahead=barmerge.lookahead_on)

var float[] mo_prices    = array.new_float()
var int[]   mo_bar_start = array.new_int()   // Stores month start times
var int[]   mo_bar_end   = array.new_int()   // Stores month end times

is_new_month = ta.change(time("M")) != 0

if barstate.isfirst or is_new_month
    if is_new_month and array.size(mo_bar_end) > 0
        array.set(mo_bar_end, 0, time[1])
    array.unshift(mo_prices,    mo_open_rth)
    array.unshift(mo_bar_start, time)
    array.unshift(mo_bar_end,   na)
    while array.size(mo_prices) > mo_count
        array.pop(mo_prices)
        array.pop(mo_bar_start)
        array.pop(mo_bar_end)

// E. Monthly High/Low
// Tracks the HIGHEST HIGH and LOWEST LOW across the entire month.
var float cur_month_high = na
var float cur_month_low  = na
var int   cur_month_start_time = 0
var int   cur_month_time = 0

var float prev_month_high = na
var float prev_month_low  = na
var int   prev_month_start_time = 0
var int   prev_month_end_time   = 0
var int   prev_month_time = 0

if barstate.isfirst
    cur_month_high       := high
    cur_month_low        := low
    cur_month_start_time := time
    cur_month_time       := time
else if is_new_month
    prev_month_high       := cur_month_high
    prev_month_low        := cur_month_low
    prev_month_start_time := cur_month_start_time
    prev_month_end_time   := time[1]
    prev_month_time       := cur_month_time
    cur_month_high        := high
    cur_month_low         := low
    cur_month_start_time  := time
    cur_month_time        := time
else
    if high > cur_month_high or na(cur_month_high)
        cur_month_high := high
    if low < cur_month_low or na(cur_month_low)
        cur_month_low := low

cur_month_mid  = (cur_month_high + cur_month_low) / 2
cur_month_name = f_month_name(cur_month_time)

// ============================================================================
// 4. SIGNAL STATE MACHINE (v33)
// ============================================================================

// ── Core State Variables ─────────────────────────────────────────────────────

var int  last_touch_ml_time        = 0
var int  last_touch_mh_time        = 0
var bool long_setup_voided_by_mmr  = false
var bool short_setup_voided_by_mmr = false

// Hard same-touch blocks (reset on new touch, set on signal fire)
var bool long_touch_triggered      = false
var bool short_touch_triggered     = false

// Explicit interaction lifecycle state for event-based re-arming.
// A touch only refreshes on a new zone entry after the prior interaction has
// fully exited the tolerance zone.
var bool ml_reaction_touch_active  = false
var bool mh_reaction_touch_active  = false

// ── MH Flip to Support ───────────────────────────────────────────────────────
var bool mh_flipped             = false
var int  last_mh_flip_time      = 0   // Set when price pulls back TO flipped MH
var int  mh_flip_confirmed_time = 0   // Set when flip is first confirmed
var bool mh_flip_triggered      = false
var bool mh_mom_triggered       = false
var int  consec_closes_above_mh = 0

// ── ML Flip to Resistance ─────────────────────────────────────────────────────
var bool ml_flipped             = false
var int  last_ml_flip_time      = 0   // Set when price rallies back TO flipped ML
var int  ml_flip_confirmed_time = 0   // Set when flip is first confirmed
var bool ml_flip_triggered      = false
var bool ml_mom_triggered       = false
var int  consec_closes_below_ml = 0
var bool mh_flip_touch_active   = false
var bool ml_flip_touch_active   = false
var bool pending_sig_weekly_reset = false

// ── Timeframe-Aware Confirmation Threshold ───────────────────────────────────
// ≤5 min: 2 consecutive closes required (noise filter for lower timeframes)
// >5 min: 1 close is sufficient
// Audit note: changing chart timeframe changes this confirmation policy, so
// timeframe comparisons are not pure resampling tests.
closes_required = timeframe.in_seconds() <= 300 ? 2 : 1

ms_per_minute   = 60 * 1000
sig_in_rth      = in_tradable_session

// First weekly trading day flag is defined in the weekly-level source block
// above and is reused here for family gating / policy control.

// Effective family gates
// Stage 5 contract vocabulary used below:
// - Deferred  = blocked now, may still qualify later only if the underlying
//                candidate remains valid and fresh; no pending signal is stored.
// - Discarded = blocked and state flushed; no carry-forward into later bars.
// - Consumed  = accepted signal used the setup and set its hard block.
// - Voided    = temporarily invalid under policy while the touch lifecycle is
//               still open.
reactions_active_now = enable_reactions and (not is_first_weekly_day or allow_reactions_first_day)
flips_active_now     = enable_flips and (not is_first_weekly_day or allow_flips_first_day)

// ── Weekly Reset (applied on first RTH bar of new week) ─────────────────────
if ta.change(time("W")) != 0
    pending_sig_weekly_reset := true

if pending_sig_weekly_reset and sig_in_rth
    mh_flipped               := false
    mh_flip_triggered        := false
    mh_flip_confirmed_time   := 0
    consec_closes_above_mh   := 0
    mh_mom_triggered         := false
    ml_flipped               := false
    ml_flip_triggered        := false
    ml_flip_confirmed_time   := 0
    consec_closes_below_ml   := 0
    ml_mom_triggered         := false
    last_touch_ml_time       := 0
    last_touch_mh_time       := 0
    last_mh_flip_time        := 0
    last_ml_flip_time        := 0
    long_setup_voided_by_mmr := false
    short_setup_voided_by_mmr := false
    long_touch_triggered     := false
    short_touch_triggered    := false
    ml_reaction_touch_active := false
    mh_reaction_touch_active := false
    mh_flip_touch_active     := false
    ml_flip_touch_active     := false
    pending_sig_weekly_reset := false

// Reactions family OFF contract: discarded, not deferred.
// When reactions are inactive (including first-weekly-day policy OFF), all
// reaction-family lifecycle state is intentionally flushed so no hidden state
// accumulates and no blocked-day context carries into later sessions.
if not reactions_active_now
    last_touch_ml_time        := 0
    last_touch_mh_time        := 0
    long_setup_voided_by_mmr  := false
    short_setup_voided_by_mmr := false
    long_touch_triggered      := false
    short_touch_triggered     := false
    ml_reaction_touch_active  := false
    mh_reaction_touch_active  := false

// Flips family OFF contract: discarded, not deferred.
// When flips are inactive (including first-weekly-day policy OFF), all
// flip-family lifecycle state is intentionally flushed so later eligibility
// requires a fresh post-gate lifecycle rather than inherited state.
if not flips_active_now
    mh_flipped              := false
    mh_flip_triggered       := false
    mh_flip_confirmed_time  := 0
    consec_closes_above_mh  := 0
    mh_mom_triggered        := false
    ml_flipped              := false
    ml_flip_triggered       := false
    ml_flip_confirmed_time  := 0
    consec_closes_below_ml  := 0
    ml_mom_triggered        := false
    last_mh_flip_time       := 0
    last_ml_flip_time       := 0
    mh_flip_touch_active    := false
    ml_flip_touch_active    := false

// ── Touch Tolerance Buffers ───────────────────────────────────────────────────
// Stage 4b dual-band hysteresis:
// - Entry band uses Touch Tolerance (%)
// - Release/re-arm requires price to leave a wider band defined by
//   Touch Tolerance (%) × Touch Release Multiplier
ml_tolerance = d_ml * (touch_tolerance / 100)
mh_tolerance = d_mh * (touch_tolerance / 100)

ml_release_tolerance = ml_tolerance * release_mult
mh_release_tolerance = mh_tolerance * release_mult

ml_touch_low     = d_ml - ml_tolerance
ml_touch_high    = d_ml + ml_tolerance
mh_touch_low     = d_mh - mh_tolerance
mh_touch_high    = d_mh + mh_tolerance
ml_release_low   = d_ml - ml_release_tolerance
ml_release_high  = d_ml + ml_release_tolerance
mh_release_low   = d_mh - mh_release_tolerance
mh_release_high  = d_mh + mh_release_tolerance

ml_touched_raw         = not na(d_ml) and high >= ml_touch_low and low <= ml_touch_high
mh_touched_raw         = not na(d_mh) and high >= mh_touch_low and low <= mh_touch_high
ml_touch_release_raw   = not na(d_ml) and high >= ml_release_low and low <= ml_release_high
mh_touch_release_raw   = not na(d_mh) and high >= mh_release_low and low <= mh_release_high

// Event-based touch lifecycle for reaction paths with dual-band hysteresis.
// A new touch only occurs on re-entry into the narrower entry band after the
// prior interaction has fully exited the wider release band, preventing
// hover/chop around the level from repeatedly refreshing setup timestamps and
// hard blocks.
if reactions_active_now and sig_in_rth
    if ml_touched_raw and not ml_reaction_touch_active
        ml_reaction_touch_active := true
    else if not ml_touch_release_raw
        ml_reaction_touch_active := false

    if mh_touched_raw and not mh_reaction_touch_active
        mh_reaction_touch_active := true
    else if not mh_touch_release_raw
        mh_reaction_touch_active := false
else
    ml_reaction_touch_active := false
    mh_reaction_touch_active := false

ml_touched_this_bar = reactions_active_now and sig_in_rth and ml_touched_raw and ml_reaction_touch_active[1] != true
mh_touched_this_bar = reactions_active_now and sig_in_rth and mh_touched_raw and mh_reaction_touch_active[1] != true

// ── MH Flip Confirmation ──────────────────────────────────────────────────────
// Closing back below MH fully invalidates the flip state
if flips_active_now and sig_in_rth and not na(d_mh)
    if close <= d_mh
        consec_closes_above_mh := 0
        mh_flipped             := false
        mh_flip_confirmed_time := 0
        last_mh_flip_time      := 0
        mh_flip_triggered      := false
        mh_mom_triggered       := false
        mh_flip_touch_active   := false
    else
        consec_closes_above_mh := consec_closes_above_mh + 1
        if consec_closes_above_mh >= closes_required and not mh_flipped
            mh_flip_confirmed_time := time
        if consec_closes_above_mh >= closes_required
            mh_flipped := true

// Pullback touch: wick comes back down to flipped MH (now acting as support)
mh_flip_touch_raw = flips_active_now and sig_in_rth and mh_flipped[1] and not na(d_mh) and high >= mh_touch_low and low <= mh_touch_high and close > d_mh
mh_flip_touch_release_raw = flips_active_now and sig_in_rth and mh_flipped and not na(d_mh) and high >= mh_release_low and low <= mh_release_high and close > d_mh

if flips_active_now and sig_in_rth and mh_flipped
    if mh_flip_touch_raw and not mh_flip_touch_active
        mh_flip_touch_active := true
    else if not mh_flip_touch_release_raw
        mh_flip_touch_active := false
else
    mh_flip_touch_active := false

mh_flip_touched = mh_flip_touch_raw and mh_flip_touch_active[1] != true

if mh_flip_touched
    last_mh_flip_time := time
    mh_flip_triggered := false

// ── ML Flip Confirmation ──────────────────────────────────────────────────────
// Closing back above ML fully invalidates the flip state
if flips_active_now and sig_in_rth and not na(d_ml)
    if close >= d_ml
        consec_closes_below_ml := 0
        ml_flipped             := false
        ml_flip_confirmed_time := 0
        last_ml_flip_time      := 0
        ml_flip_triggered      := false
        ml_mom_triggered       := false
        ml_flip_touch_active   := false
    else
        consec_closes_below_ml := consec_closes_below_ml + 1
        if consec_closes_below_ml >= closes_required and not ml_flipped
            ml_flip_confirmed_time := time
        if consec_closes_below_ml >= closes_required
            ml_flipped := true

// Rally touch: wick comes back up to flipped ML (now acting as resistance)
ml_flip_touch_raw = flips_active_now and sig_in_rth and ml_flipped[1] and not na(d_ml) and high >= ml_touch_low and low <= ml_touch_high and close < d_ml
ml_flip_touch_release_raw = flips_active_now and sig_in_rth and ml_flipped and not na(d_ml) and high >= ml_release_low and low <= ml_release_high and close < d_ml

if flips_active_now and sig_in_rth and ml_flipped
    if ml_flip_touch_raw and not ml_flip_touch_active
        ml_flip_touch_active := true
    else if not ml_flip_touch_release_raw
        ml_flip_touch_active := false
else
    ml_flip_touch_active := false

ml_flip_touched = ml_flip_touch_raw and ml_flip_touch_active[1] != true

if ml_flip_touched
    last_ml_flip_time := time
    ml_flip_triggered := false

// ── ML / MH Core Touch State Updates ─────────────────────────────────────────
if ml_touched_this_bar
    last_touch_ml_time       := time
    long_setup_voided_by_mmr := false
    long_touch_triggered     := false

if mh_touched_this_bar
    last_touch_mh_time        := time
    short_setup_voided_by_mmr := false
    short_touch_triggered     := false

// ── Freshness ─────────────────────────────────────────────────────────────────
validity_ms = valid_minutes * ms_per_minute

is_fresh_long  = last_touch_ml_time > 0 and (time - last_touch_ml_time) <= validity_ms
is_fresh_short = last_touch_mh_time > 0 and (time - last_touch_mh_time) <= validity_ms

// Flip pullback freshness (measured from touch back to the level)
is_fresh_mh_flip = last_mh_flip_time > 0 and (time - last_mh_flip_time) <= validity_ms
is_fresh_ml_flip = last_ml_flip_time > 0 and (time - last_ml_flip_time) <= validity_ms

// Flip momentum freshness (measured from when flip was first confirmed)
is_fresh_mh_momentum = mh_flip_confirmed_time > 0 and (time - mh_flip_confirmed_time) <= validity_ms
is_fresh_ml_momentum = ml_flip_confirmed_time > 0 and (time - ml_flip_confirmed_time) <= validity_ms

// ── MMR Void ──────────────────────────────────────────────────────────────────
// Stage 5 contract: MMR is a recoverable temporary void for reaction-
// continuation paths only. It does not consume the setup, does not queue a
// pending signal, and may re-enable the continuation path if price closes back
// to the valid side of mid before freshness expires. A new touch resets the
// touch lifecycle and MMR state.
//
// Bar-ordering rule: capture prior bar state before updating so the current
// signal bar is evaluated against the pre-update MMR state and is not
// self-voided by its own close.
mmr_voided_long  = long_setup_voided_by_mmr
mmr_voided_short = short_setup_voided_by_mmr

// Void on candle close beyond mid (not wick).
// Recover if price closes back to the valid side of mid while the current
// touch lifecycle is still fresh. This is recoverable void logic, not a
// one-shot or queued second-chance mechanism.
if sig_in_rth and is_fresh_long and not ml_touched_this_bar and not na(d_mid)
    if close >= d_mid
        long_setup_voided_by_mmr := true
    else if long_setup_voided_by_mmr and close < d_mid
        long_setup_voided_by_mmr := false

if sig_in_rth and is_fresh_short and not mh_touched_this_bar and not na(d_mid)
    if close <= d_mid
        short_setup_voided_by_mmr := true
    else if short_setup_voided_by_mmr and close > d_mid
        short_setup_voided_by_mmr := false

// ── No-Trade Zone (Temporarily Removed for Release) ──────────────────────────
// Stage 7 governance: the no-trade-zone feature is intentionally disabled and
// its TradingView inputs are removed for this release. Preserve the acceptance
// gate plumbing by hard-forcing the policy OFF.
in_no_trade_zone = false

// ── Bar Duration in Milliseconds ─────────────────────────────────────────────
bar_ms = timeframe.in_seconds() * 1000

// =============================================================================
// LONG TRIGGERS
// =============================================================================

// A. Reversal: SMA50 crossover — MMR void does NOT apply to this path
// This path is exempt from the MMR continuation policy by design.
trigger_rev_long = ta.crossover(close, chart_sma50) and close > d_ml

// B. Continuation: bounce / defense off ML — MMR void applies
// If blocked by MMR, this continuation path is temporarily voided rather than
// consumed, and it may re-qualify only while freshness still holds.
trend_ok_long     = close > chart_sma50
reclaim_long      = ta.crossover(close, d_ml)
defense_long      = ml_touched_this_bar and close > d_ml and close > open
bounce_long       = not ml_touched_this_bar and is_fresh_long and close > d_ml and close > open
trigger_cont_long = trend_ok_long and (reclaim_long or defense_long or bounce_long)

// C. MH Flip Pullback: price pulls back to flipped MH and defends it
defense_mh_flip  = mh_flip_touched and close > d_mh and close > open
bounce_mh_flip   = not mh_flip_touched and is_fresh_mh_flip and close > d_mh and close > open
trigger_mh_flip  = mh_flipped and trend_ok_long and (defense_mh_flip or bounce_mh_flip)

// D. MH Flip Momentum: fires once flip is confirmed, bullish follow-through above MH
mh_follow_through   = mh_flipped
     and close > open
     and close > close[1]
     and close > d_mh

trigger_mh_momentum = trend_ok_long and mh_follow_through

// ── Long Candidate Paths ──────────────────────────────────────────────────────

// ML-based entries (reversal bypasses MMR void; continuation respects it).
// Reaction-family candidates remain subject to acceptance-time policy filters
// later in the chain (session gate, no-trade zone, consolidation).
valid_long_ml = reactions_active_now and is_fresh_long
     and not long_touch_triggered
     and (trigger_rev_long or (not mmr_voided_long and trigger_cont_long))

// MH Flip pullback entries
valid_long_flip = flips_active_now and mh_flipped
     and is_fresh_mh_flip
     and not mh_flip_triggered
     and trigger_mh_flip

// MH Flip momentum entries
valid_long_momentum = flips_active_now and mh_flipped
     and is_fresh_mh_momentum
     and not mh_mom_triggered
     and trigger_mh_momentum

// =============================================================================
// SHORT TRIGGERS
// =============================================================================

// A. Reversal: SMA50 crossunder — MMR void does NOT apply to this path
// This path is exempt from the MMR continuation policy by design.
trigger_rev_short = ta.crossunder(close, chart_sma50) and close < d_mh

// B. Continuation: rejection / defense at MH — MMR void applies
// If blocked by MMR, this continuation path is temporarily voided rather than
// consumed, and it may re-qualify only while freshness still holds.
trend_ok_short     = close < chart_sma50
reclaim_short      = ta.crossunder(close, d_mh)
defense_short      = mh_touched_this_bar and close < d_mh and close < open
bounce_short       = not mh_touched_this_bar and is_fresh_short and close < d_mh and close < open
trigger_cont_short = trend_ok_short and (reclaim_short or defense_short or bounce_short)

// C. ML Flip Pullback: price rallies back to flipped ML and rejects it
defense_ml_flip  = ml_flip_touched and close < d_ml and close < open
bounce_ml_flip   = not ml_flip_touched and is_fresh_ml_flip and close < d_ml and close < open
trigger_ml_flip  = ml_flipped and trend_ok_short and (defense_ml_flip or bounce_ml_flip)

// D. ML Flip Momentum: fires once flip is confirmed, red bar still below ML
ml_follow_through   = ml_flipped
     and close < open
     and close < close[1]
     and close < d_ml

trigger_ml_momentum = trend_ok_short and ml_follow_through

// ── Short Candidate Paths ─────────────────────────────────────────────────────

// MH-based entries (reversal bypasses MMR void; continuation respects it).
// Reaction-family candidates remain subject to acceptance-time policy filters
// later in the chain (session gate, no-trade zone, consolidation).
valid_short_mh = reactions_active_now and is_fresh_short
     and not short_touch_triggered
     and (trigger_rev_short or (not mmr_voided_short and trigger_cont_short))

// ML Flip pullback entries
valid_short_flip = flips_active_now and ml_flipped
     and is_fresh_ml_flip
     and not ml_flip_triggered
     and trigger_ml_flip

// ML Flip momentum entries
valid_short_momentum = flips_active_now and ml_flipped
     and is_fresh_ml_momentum
     and not ml_mom_triggered
     and trigger_ml_momentum

// ── DIAGNOSTIC LABELS — commented out for release ─────────────────────────────
// if valid_long_ml
//     label.new(bar_index, low, "ML", style=label.style_label_up,
//          color=color.blue, textcolor=color.white, size=size.tiny)
// if valid_long_flip
//     label.new(bar_index, low, "FLIP", style=label.style_label_up,
//          color=color.purple, textcolor=color.white, size=size.tiny)
// if valid_long_momentum
//     label.new(bar_index, low, "MOM", style=label.style_label_up,
//          color=color.orange, textcolor=color.white, size=size.tiny)

// =============================================================================
// ACCEPTED SIGNALS + CONSOLIDATION FILTER (TIME-BASED)
// =============================================================================
// Stage 5 policy contract at acceptance:
// - No-trade zone and consolidation are acceptance-time blocks only.
// - A blocked setup is deferred, not consumed, and no pending signal is stored.
// - Deferral only matters while the underlying candidate remains valid/fresh;
//   event-style triggers (for example crossover/crossunder/touch-event bars)
//   can naturally disappear on later bars.
// - Same-direction candidates are resolved by fixed acceptance order:
//   Momentum > Flip Pullback > Reaction-family. Lower-priority valid
//   candidates are not accepted on that bar once a higher-priority candidate
//   wins.
// - Consolidation is direction-wide, not family-specific. One accepted long can
//   suppress a later long from a different family inside the cooldown window,
//   and likewise for shorts.

var int last_sig_long_time  = 0
var int last_sig_short_time = 0
consol_ms = consol_minutes * ms_per_minute

long_candidate = valid_long_momentum or valid_long_flip or valid_long_ml
short_candidate = valid_short_momentum or valid_short_flip or valid_short_mh

long_consol_blocked = long_candidate and (time - last_sig_long_time < consol_ms)
short_consol_blocked = short_candidate and (time - last_sig_short_time < consol_ms)

accepted_long_momentum = sig_in_rth and not in_no_trade_zone and not long_consol_blocked and valid_long_momentum
accepted_long_flip     = sig_in_rth and not in_no_trade_zone and not long_consol_blocked and not accepted_long_momentum and valid_long_flip
accepted_long_ml       = sig_in_rth and not in_no_trade_zone and not long_consol_blocked and not accepted_long_momentum and not accepted_long_flip and valid_long_ml
accepted_long          = accepted_long_momentum or accepted_long_flip or accepted_long_ml

accepted_short_momentum = sig_in_rth and not in_no_trade_zone and not short_consol_blocked and valid_short_momentum
accepted_short_flip     = sig_in_rth and not in_no_trade_zone and not short_consol_blocked and not accepted_short_momentum and valid_short_flip
accepted_short_mh       = sig_in_rth and not in_no_trade_zone and not short_consol_blocked and not accepted_short_momentum and not accepted_short_flip and valid_short_mh
accepted_short          = accepted_short_momentum or accepted_short_flip or accepted_short_mh

if accepted_long
    last_sig_long_time := time
if accepted_short
    last_sig_short_time := time

// Set hard blocks only after accepted signal fires
if accepted_long_ml
    long_touch_triggered := true
if accepted_long_flip
    mh_flip_triggered    := true
if accepted_long_momentum
    mh_mom_triggered     := true

if accepted_short_mh
    short_touch_triggered := true
if accepted_short_flip
    ml_flip_triggered     := true
if accepted_short_momentum
    ml_mom_triggered      := true

// ============================================================================
// 5. STOP LOSS + PROJECTED TAKE PROFIT CALCULATION
// ============================================================================
// Professional stop-policy selector.
// All stop levels are frozen on the accepted signal bar and do not drift later.
// Structural anchors are mapped by signal family:
//   Long ML Bounce / SMA50 Reversal  -> ML
//   Long MH Flip Pullback / Momentum -> MH
//   Short MH Rejection / SMA50 Rev   -> MH
//   Short ML Flip Pullback / Momentum-> ML
//
// Stage 8 audit add-on:
// - TP logic below is a NON-EXECUTION projection framework intended for
//   chart-data export, audit comparison, and future strategy wrapping.
// - It does not change entry acceptance logic in this indicator.
// - Monday and Tue-Fri can use different projection modes to reflect the
//   developing-vs-locked weekly-range design discussion.

var float stop_level_long   = na
var float stop_level_short  = na
var float tp_level_long     = na
var float tp_level_short    = na
var float entry_price_long  = na
var float entry_price_short = na
var float tp_mode_code_long = na
var float tp_mode_code_short= na
var float tp1_level_long    = na
var float tp2_level_long    = na

stop_level_long   := na
stop_level_short  := na
tp_level_long     := na
tp_level_short    := na
entry_price_long  := na
entry_price_short := na
tp_mode_code_long := na
tp_mode_code_short:= na
tp1_level_long    := na
tp2_level_long    := na

float stop_floor_buffer = min_stop_floor_ticks * syminfo.mintick
float fixed_stop_buffer = math.max(fixed_buffer_ticks * syminfo.mintick, stop_floor_buffer)
float atr_stop_buffer   = math.max(chart_atr * atr_mult, stop_floor_buffer)

float long_structure_anchor  = accepted_long_ml ? d_ml : (accepted_long_flip or accepted_long_momentum ? d_mh : na)
float short_structure_anchor = accepted_short_mh ? d_mh : (accepted_short_flip or accepted_short_momentum ? d_ml : na)

string stop_mode_alert = stop_mode == "ATR from Structure (Structural)" ? "ATR-STRUCT" :
     stop_mode == "Structure + Fixed Buffer (Fixed)" ? "STRUCT+TICKS" :
     stop_mode == "Signal Bar Invalidation (Trigger)" ? "SIGBAR" :
     stop_mode == "Hybrid (Wider)" ? "HYBRID-C" : "LEGACY"

// ── Long Stops ────────────────────────────────────────────────────────────────
if accepted_long and not na(long_structure_anchor)
    float long_stop_structure_atr   = long_structure_anchor - atr_stop_buffer
    float long_stop_structure_fixed = long_structure_anchor - fixed_stop_buffer
    float long_stop_signal_bar      = low - fixed_stop_buffer
    float long_stop_legacy_raw      = close - (chart_atr * atr_mult)
    float long_stop_legacy          = math.min(long_stop_legacy_raw, long_structure_anchor)

    stop_level_long := switch stop_mode
        "ATR from Structure (Structural)" => long_stop_structure_atr
        "Structure + Fixed Buffer (Fixed)" => long_stop_structure_fixed
        "Signal Bar Invalidation (Trigger)" => long_stop_signal_bar
        "Hybrid (Wider)" => math.min(long_stop_structure_atr, long_stop_signal_bar)
        => long_stop_legacy

// ── Short Stops ───────────────────────────────────────────────────────────────
if accepted_short and not na(short_structure_anchor)
    float short_stop_structure_atr   = short_structure_anchor + atr_stop_buffer
    float short_stop_structure_fixed = short_structure_anchor + fixed_stop_buffer
    float short_stop_signal_bar      = high + fixed_stop_buffer
    float short_stop_legacy_raw      = close + (chart_atr * atr_mult)
    float short_stop_legacy          = math.max(short_stop_legacy_raw, short_structure_anchor)

    stop_level_short := switch stop_mode
        "ATR from Structure (Structural)" => short_stop_structure_atr
        "Structure + Fixed Buffer (Fixed)" => short_stop_structure_fixed
        "Signal Bar Invalidation (Trigger)" => short_stop_signal_bar
        "Hybrid (Wider)" => math.max(short_stop_structure_atr, short_stop_signal_bar)
        => short_stop_legacy

// ── Projected TP / Exit Framework (non-execution) ───────────────────────────
active_exit_mode = is_first_weekly_day ? monday_exit_mode : weekly_exit_mode

if accepted_long and not na(stop_level_long)
    entry_price_long := close
    tp1_level_long := f_fixed_r_target_long(entry_price_long, stop_level_long, 1.0)
    tp2_level_long := f_fixed_r_target_long(entry_price_long, stop_level_long, 2.0)
    tp_mode_code_long := active_exit_mode == "Developing MH/ML" or active_exit_mode == "Current Week MH/ML" ? 1 :
         active_exit_mode == "Fixed R" ? 2 :
         active_exit_mode == "Prior-Week Structural" ? 3 : 4

    if active_exit_mode == "Developing MH/ML" or active_exit_mode == "Current Week MH/ML"
        tp_level_long := d_mh
    else if active_exit_mode == "Fixed R"
        tp_level_long := f_fixed_r_target_long(entry_price_long, stop_level_long, tp_r_multiple)
    else if active_exit_mode == "Prior-Week Structural"
        tp_level_long := f_struct_target_long(d_ml, d_mh, d_pml, d_pmh, struct_align_pct, struct_ext_mult)
    else
        tp_level_long := na

if accepted_short and not na(stop_level_short)
    entry_price_short := close
    tp_mode_code_short := active_exit_mode == "Developing MH/ML" or active_exit_mode == "Current Week MH/ML" ? 1 :
         active_exit_mode == "Fixed R" ? 2 :
         active_exit_mode == "Prior-Week Structural" ? 3 : 4

    if active_exit_mode == "Developing MH/ML" or active_exit_mode == "Current Week MH/ML"
        tp_level_short := d_ml
    else if active_exit_mode == "Fixed R"
        tp_level_short := f_fixed_r_target_short(entry_price_short, stop_level_short, tp_r_multiple)
    else if active_exit_mode == "Prior-Week Structural"
        tp_level_short := f_struct_target_short(d_mh, d_ml, d_pmh, d_pml, struct_align_pct, struct_ext_mult)
    else
        tp_level_short := na

// ============================================================================
// 6. PLOTTING
// ============================================================================

plot(show_sma50  ? chart_sma50  : na, "SMA 50",  color=col_sma50,  linewidth=2)
plot(show_sma100 ? chart_sma100 : na, "SMA 100", color=col_sma100, linewidth=1)
plot(show_sma200 ? chart_sma200 : na, "SMA 200", color=col_sma200, linewidth=2)

// ── EMA Ribbon ───────────────────────────────────────────────────────────────
// Both lines share the same dynamic color: green when Fast > Slow, red otherwise.
// Cross signal shape style is customizable via TradingView's Style tab.
plot(show_ema ? chart_ema_fast : na, "Fast EMA", color=ema_col, linewidth=1)
plot(show_ema ? chart_ema_slow : na, "Slow EMA", color=ema_col, linewidth=1)

// Bull Cross: with text in normal mode, shape-only in compact mode
plotshape(show_ema and show_ema_cross and ema_bull_cross and not compact_mode,
     "Bull Cross", style=shape.triangleup, location=location.belowbar,
     color=col_ema_bull, size=size.tiny, text="Bull")
plotshape(show_ema and show_ema_cross and ema_bull_cross and compact_mode,
     "Bull Cross (Compact)", style=shape.triangleup, location=location.belowbar,
     color=col_ema_bull, size=size.tiny, text="")

// Bear Cross: with text in normal mode, shape-only in compact mode
plotshape(show_ema and show_ema_cross and ema_bear_cross and not compact_mode,
     "Bear Cross", style=shape.triangledown, location=location.abovebar,
     color=col_ema_bear, size=size.tiny, text="Bear")
plotshape(show_ema and show_ema_cross and ema_bear_cross and compact_mode,
     "Bear Cross (Compact)", style=shape.triangledown, location=location.abovebar,
     color=col_ema_bear, size=size.tiny, text="")

// Stage 7 governance: no-trade-zone shading removed with the feature.
// bgcolor(show_zone and in_zone ? col_zone : na)

int right_edge_time = f_right_edge_time(5)

// ── Weekly Line Anchors ───────────────────────────────────────────────────────

var int  idx_cur_week       = bar_index
var int  idx_prev_week      = na
var bool pending_rth_update = false

is_in_rth = in_tradable_session

if ta.change(time("W")) != 0
    pending_rth_update := true

if pending_rth_update and is_in_rth
    idx_prev_week      := idx_cur_week
    idx_cur_week       := bar_index
    pending_rth_update := false

if bar_index == 0
    idx_cur_week := bar_index

var line  l_mh   = na, var line  l_ml  = na, var line  l_mid = na
var line  l_pmh  = na, var line  l_pml = na
var label lb_mh  = na, var label lb_ml = na
var label lb_pmh = na, var label lb_pml = na

line.delete(l_mh),   line.delete(l_ml),  line.delete(l_mid)
line.delete(l_pmh),  line.delete(l_pml)
label.delete(lb_mh), label.delete(lb_ml)
label.delete(lb_pmh),label.delete(lb_pml)

if show_cur_mon and not na(d_mh)
    l_mh  := line.new(idx_cur_week, d_mh, bar_index + 5, d_mh, color=col_mh, width=2)
    lb_mh := label.new(bar_index + 5, d_mh, "MH", color=color.new(color.white, 100), textcolor=col_mh, style=label.style_none, size=size.small)
if show_cur_mon and not na(d_ml)
    l_ml  := line.new(idx_cur_week, d_ml, bar_index + 5, d_ml, color=col_ml, width=2)
    lb_ml := label.new(bar_index + 5, d_ml, "ML", color=color.new(color.white, 100), textcolor=col_ml, style=label.style_none, size=size.small)
if show_mid and not na(d_mid)
    l_mid := line.new(idx_cur_week, d_mid, bar_index + 5, d_mid, color=col_mid, style=line.style_dotted, width=1)

if show_prev_mon and not na(d_pmh) and not na(idx_prev_week)
    l_pmh  := line.new(idx_prev_week, d_pmh, bar_index + 5, d_pmh, color=col_pmh, style=line.style_dotted, width=2)
    lb_pmh := label.new(bar_index + 5, d_pmh, "PMH", color=color.new(color.white, 100), textcolor=col_pmh, style=label.style_none, size=size.small)
if show_prev_mon and not na(d_pml) and not na(idx_prev_week)
    l_pml  := line.new(idx_prev_week, d_pml, bar_index + 5, d_pml, color=col_pml, style=line.style_dotted, width=2)
    lb_pml := label.new(bar_index + 5, d_pml, "PML", color=color.new(color.white, 100), textcolor=col_pml, style=label.style_none, size=size.small)

// ── Monthly Open Lines ────────────────────────────────────────────────────────
// Delete all existing monthly lines/labels then redraw from stored history.
// Lines run from the first bar of each month to the current bar edge.
var line[]  mo_lines_arr  = array.new_line()
var label[] mo_labels_arr = array.new_label()

int mo_n = array.size(mo_lines_arr)
if mo_n > 0
    for i = 0 to mo_n - 1
        line.delete(array.get(mo_lines_arr, i))
        label.delete(array.get(mo_labels_arr, i))
array.clear(mo_lines_arr)
array.clear(mo_labels_arr)

if show_mo
    int total = array.size(mo_prices)
    if total > 0
        for i = 0 to total - 1
            float p   = array.get(mo_prices, i)
            int   s   = array.get(mo_bar_start, i)
            int   e   = array.get(mo_bar_end, i)
            int   end_time = na(e) ? right_edge_time : e
            if not na(p)
                ln = line.new(s, p, end_time, p, xloc=xloc.bar_time, color=col_mo, width=1, style=line.style_dashed)
                lb = label.new(end_time, p, "MO", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_mo, style=label.style_none, size=size.small)
                array.push(mo_lines_arr, ln)
                array.push(mo_labels_arr, lb)

var line[]  hist_month_lines  = array.new_line()
var label[] hist_month_labels = array.new_label()
hist_month_keep = math.max(mo_count - 1, 0)

// ── Monthly High/Low Lines (Historical) ─────────────────────────────────────
if is_new_month and not na(prev_month_high)
    prev_name = f_month_name(prev_month_time)
    prev_mid = (prev_month_high + prev_month_low) / 2

    if show_month_hl and hist_month_keep > 0
        hist_h = line.new(prev_month_start_time, prev_month_high, prev_month_end_time, prev_month_high, xloc=xloc.bar_time, color=col_month_h, width=2)
        hist_l = line.new(prev_month_start_time, prev_month_low, prev_month_end_time, prev_month_low, xloc=xloc.bar_time, color=col_month_l, width=2)
        array.push(hist_month_lines, hist_h)
        array.push(hist_month_lines, hist_l)

        if show_month_labels
            hist_h_label = label.new(prev_month_start_time, prev_month_high, prev_name + " H", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_h, style=label.style_none, size=size.tiny)
            hist_l_label = label.new(prev_month_start_time, prev_month_low, prev_name + " L", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_l, style=label.style_none, size=size.tiny)
            array.push(hist_month_labels, hist_h_label)
            array.push(hist_month_labels, hist_l_label)

        if show_month_mid
            hist_mid = line.new(prev_month_start_time, prev_mid, prev_month_end_time, prev_mid, xloc=xloc.bar_time, color=col_month_mid, style=line.style_dotted, width=1)
            array.push(hist_month_lines, hist_mid)
            if show_month_labels
                hist_mid_label = label.new(prev_month_start_time, prev_mid, prev_name + " Mid", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_mid, style=label.style_none, size=size.tiny)
                array.push(hist_month_labels, hist_mid_label)

    while array.size(hist_month_lines) > hist_month_keep * (show_month_mid ? 3 : 2)
        line.delete(array.shift(hist_month_lines))
    while array.size(hist_month_labels) > hist_month_keep * (show_month_labels ? (show_month_mid ? 3 : 2) : 0)
        label.delete(array.shift(hist_month_labels))

if not show_month_hl
    while array.size(hist_month_lines) > 0
        line.delete(array.shift(hist_month_lines))
    while array.size(hist_month_labels) > 0
        label.delete(array.shift(hist_month_labels))

// ── Monthly High/Low Lines (Current Month) ──────────────────────────────────
var line  l_month_h   = na
var line  l_month_l   = na
var line  l_month_mid = na
var label lb_month_h  = na
var label lb_month_l  = na
var label lb_month_mid = na

line.delete(l_month_h)
line.delete(l_month_l)
line.delete(l_month_mid)
label.delete(lb_month_h)
label.delete(lb_month_l)
label.delete(lb_month_mid)

if show_month_hl and not na(cur_month_high)
    l_month_h := line.new(cur_month_start_time, cur_month_high, right_edge_time, cur_month_high, xloc=xloc.bar_time, color=col_month_h, width=2)
    l_month_l := line.new(cur_month_start_time, cur_month_low, right_edge_time, cur_month_low, xloc=xloc.bar_time, color=col_month_l, width=2)
    if show_month_labels
        lb_month_h := label.new(right_edge_time, cur_month_high, cur_month_name + " H", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_h, style=label.style_none, size=size.small)
        lb_month_l := label.new(right_edge_time, cur_month_low, cur_month_name + " L", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_l, style=label.style_none, size=size.small)

if show_month_hl and show_month_mid and not na(cur_month_mid)
    l_month_mid := line.new(cur_month_start_time, cur_month_mid, right_edge_time, cur_month_mid, xloc=xloc.bar_time, color=col_month_mid, style=line.style_dotted, width=1)
    if show_month_labels
        lb_month_mid := label.new(right_edge_time, cur_month_mid, cur_month_name + " Mid", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=col_month_mid, style=label.style_none, size=size.small)

// ── Signal Shapes ─────────────────────────────────────────────────────────────
// GO label always shown regardless of compact mode
plotshape(show_signals and accepted_long,  "Long Signal",  shape.triangleup,   location.belowbar, color.green, size=size.tiny, text="GO")
plotshape(show_signals and accepted_short, "Short Signal", shape.triangledown, location.abovebar, color.red,   size=size.tiny, text="GO")

// Export/audit series for TradingView chart-data extraction.
// These plots are sparse by design: they print only on accepted signal bars so
// external review pipelines can line up entry, stop, and projected TP.
plot(accepted_long  ? entry_price_long  : na, "Long Entry Price",  color=color.new(color.green, 0), linewidth=1, style=plot.style_cross, editable=false)
plot(accepted_short ? entry_price_short : na, "Short Entry Price", color=color.new(color.red,   0), linewidth=1, style=plot.style_cross, editable=false)
plot(show_signals and show_stop_l and accepted_long  ? stop_level_long  : na, "Long SL", color=color.new(color.green, 0), linewidth=1, style=plot.style_cross, editable=false)
plot(show_signals and show_stop_s and accepted_short ? stop_level_short : na, "Short SL", color=color.new(color.red,   0), linewidth=1, style=plot.style_cross, editable=false)
plot(show_signals and show_tp_l and accepted_long    ? tp_level_long    : na, "Long TP", color=color.new(color.aqua,  0), linewidth=1, style=plot.style_cross, editable=false)
plot(show_signals and show_tp_s and accepted_short   ? tp_level_short   : na, "Short TP", color=color.new(color.orange,0), linewidth=1, style=plot.style_cross, editable=false)
plot(accepted_long  ? tp_mode_code_long  : na, "Long TP Mode Code",  color=color.new(color.aqua, 100), editable=false, display=display.data_window)
plot(accepted_short ? tp_mode_code_short : na, "Short TP Mode Code", color=color.new(color.orange,100), editable=false, display=display.data_window)

// ── Stop Loss Labels (Rolling Queue) ─────────────────────────────────────────
var label[] long_sl_queue  = array.new_label()
var label[] short_sl_queue = array.new_label()

if show_signals and show_stop_l and accepted_long and not na(stop_level_long)
    lbl = label.new(x=bar_index, y=stop_level_long, text=sl_txt + "\n" + str.tostring(stop_level_long, format.mintick), color=color.green, style=label.style_label_up, textcolor=sl_col_txt, size=sl_size)
    array.push(long_sl_queue, lbl)
    if array.size(long_sl_queue) > max_sl_labels
        label.delete(array.shift(long_sl_queue))

if show_signals and show_stop_s and accepted_short and not na(stop_level_short)
    lbl = label.new(x=bar_index, y=stop_level_short, text=sl_txt + "\n" + str.tostring(stop_level_short, format.mintick), color=color.red, style=label.style_label_down, textcolor=sl_col_txt, size=sl_size)
    array.push(short_sl_queue, lbl)
    if array.size(short_sl_queue) > max_sl_labels
        label.delete(array.shift(short_sl_queue))

// ============================================================================
// 6b. ALERTS
// ============================================================================

// Stage 6 alert taxonomy:
// - CLASS=TRADE   : accepted strategy entry alerts intended as the primary alert()
//                   payloads for automation / webhook use.
// - CLASS=INFO    : weekly level state alerts (informational, not trade entries).
// - CLASS=MONITOR : broader EMA / SMA context alerts (monitoring, not trade entries).
//
// TradingView alertcondition() hooks remain minimal raw acceptance hooks for manual
// TradingView alert setup. They are intentionally less informative than alert()
// payloads and are not the primary production telemetry surface.

// ── Signal family labels and machine-stable family codes ──────────────────────
sig_type_long  = accepted_long_momentum                 ? "MH FLIP MOM"      :
                 accepted_long_flip                     ? "MH FLIP PULLBACK" :
                 accepted_long_ml and trigger_rev_long  ? "SMA50 REVERSAL"   : "ML BOUNCE"

sig_type_short = accepted_short_momentum                ? "ML FLIP MOM"      :
                 accepted_short_flip                    ? "ML FLIP PULLBACK" :
                 accepted_short_mh and trigger_rev_short ? "SMA50 REVERSAL"  : "MH REJECTION"

sig_code_long  = accepted_long_momentum                 ? "LONG_MH_FLIP_MOM"      :
                 accepted_long_flip                     ? "LONG_MH_FLIP_PULLBACK" :
                 accepted_long_ml and trigger_rev_long  ? "LONG_SMA50_REVERSAL"   : "LONG_ML_BOUNCE"

sig_code_short = accepted_short_momentum                ? "SHORT_ML_FLIP_MOM"      :
                 accepted_short_flip                    ? "SHORT_ML_FLIP_PULLBACK" :
                 accepted_short_mh and trigger_rev_short ? "SHORT_SMA50_REVERSAL"  : "SHORT_MH_REJECTION"

// ── Signal anchor context depends on which path fired ─────────────────────────
// Long: flip/momentum paths anchor to MH (now support), all others anchor to ML.
sig_anchor_long       = (accepted_long_flip  or accepted_long_momentum)  ? "MH" : "ML"
sig_anchor_long_value = (accepted_long_flip  or accepted_long_momentum)  ? d_mh  : d_ml

// Short: flip/momentum paths anchor to ML (now resistance), all others anchor to MH.
sig_anchor_short       = (accepted_short_flip or accepted_short_momentum) ? "ML" : "MH"
sig_anchor_short_value = (accepted_short_flip or accepted_short_momentum) ? d_ml  : d_mh

// ── Stop loss guard (prevents NaN in payload if stop not yet set) ─────────────
sl_long_str   = not na(stop_level_long)  ? str.tostring(stop_level_long,  format.mintick) : "N/A"
sl_short_str  = not na(stop_level_short) ? str.tostring(stop_level_short, format.mintick) : "N/A"
tp_long_str   = not na(tp_level_long)    ? str.tostring(tp_level_long,    format.mintick) : "TRAIL"
tp_short_str  = not na(tp_level_short)   ? str.tostring(tp_level_short,   format.mintick) : "TRAIL"
tp1_long_str  = not na(tp1_level_long)   ? str.tostring(tp1_level_long,   format.mintick) : "N/A"
tp2_long_str  = not na(tp2_level_long)   ? str.tostring(tp2_level_long,   format.mintick) : "N/A"
exit_mode_str = active_exit_mode

// ── Directional signal alert controls (dynamic alert() only; no signal impact) ──
long_signal_alert_fire  = use_scan_alert and alert_long_signals  and accepted_long
short_signal_alert_fire = use_scan_alert and alert_short_signals and accepted_short

// ── TradingView alertcondition hooks (minimal raw acceptance hooks) ───────────
alertcondition(accepted_long,  title="LONG Signal Accepted",  message="LONG signal accepted")
alertcondition(accepted_short, title="SHORT Signal Accepted", message="SHORT signal accepted")

// ── Compact live alert payloads (operator-facing; still include stop mode) ─────
// Stage 6 refinement: keep alert() messages shorter for live readability while
// preserving the key execution context fields that matter most operationally.
trade_alert_long  = syminfo.ticker + " | LONG | " + sig_type_long  + " | PRICE=" + str.tostring(close, format.mintick) + " | " + sig_anchor_long  + "=" + str.tostring(sig_anchor_long_value,  format.mintick) + " | " + stop_mode_alert + " SL=" + sl_long_str + " | TP1=" + tp1_long_str + " | TP2=" + tp2_long_str + " | EXIT=" + exit_mode_str + " TP=" + tp_long_str
trade_alert_short = syminfo.ticker + " | SHORT | " + sig_type_short + " | PRICE=" + str.tostring(close, format.mintick) + " | " + sig_anchor_short + "=" + str.tostring(sig_anchor_short_value, format.mintick) + " | " + stop_mode_alert + " SL=" + sl_short_str + " | EXIT=" + exit_mode_str + " TP=" + tp_short_str

// ── Previous full-context trade payload templates (kept for rollback/reference) ─
// trade_alert_long_full  = syminfo.ticker + " | CLASS=TRADE | DIR=LONG | FAMILY=" + sig_type_long  + " | FAMILY_CODE=" + sig_code_long  + " | PRICE=" + str.tostring(close, format.mintick) + " | ANCHOR=" + sig_anchor_long  + " | ANCHOR_PRICE=" + str.tostring(sig_anchor_long_value,  format.mintick) + " | STOP_MODE=" + stop_mode_alert + " | STOP=" + sl_long_str
// trade_alert_short_full = syminfo.ticker + " | CLASS=TRADE | DIR=SHORT | FAMILY=" + sig_type_short + " | FAMILY_CODE=" + sig_code_short + " | PRICE=" + str.tostring(close, format.mintick) + " | ANCHOR=" + sig_anchor_short + " | ANCHOR_PRICE=" + str.tostring(sig_anchor_short_value, format.mintick) + " | STOP_MODE=" + stop_mode_alert + " | STOP=" + sl_short_str

// ── Entry Signal Alerts ───────────────────────────────────────────────────────
if long_signal_alert_fire
    alert(trade_alert_long, alert.freq_once_per_bar_close)

if short_signal_alert_fire
    alert(trade_alert_short, alert.freq_once_per_bar_close)

// ── Weekly level state alerts (compact informational format) ─────────────────
// Previous full-context versions retained below for rollback/reference:
// ES1! | CLASS=INFO | TYPE=LEVEL_STATE | EVENT=ML_LOST | PRICE=... | LEVEL=ML | LEVEL_PRICE=...
// ES1! | CLASS=INFO | TYPE=LEVEL_STATE | EVENT=ML_RECLAIMED | PRICE=... | LEVEL=ML | LEVEL_PRICE=...
// ES1! | CLASS=INFO | TYPE=LEVEL_STATE | EVENT=MH_BROKEN | PRICE=... | LEVEL=MH | LEVEL_PRICE=...
// ES1! | CLASS=INFO | TYPE=LEVEL_STATE | EVENT=MH_LOST | PRICE=... | LEVEL=MH | LEVEL_PRICE=...
if use_scan_alert and sig_in_rth and not na(d_ml) and ta.crossunder(close, d_ml)
    alert(syminfo.ticker + " | ML LOST | PRICE=" + str.tostring(close, format.mintick) + " | ML=" + str.tostring(d_ml, format.mintick), alert.freq_once_per_bar_close)

if use_scan_alert and sig_in_rth and not na(d_ml) and ta.crossover(close, d_ml)
    alert(syminfo.ticker + " | ML RECLAIMED | PRICE=" + str.tostring(close, format.mintick) + " | ML=" + str.tostring(d_ml, format.mintick), alert.freq_once_per_bar_close)

if use_scan_alert and sig_in_rth and not na(d_mh) and ta.crossover(close, d_mh)
    alert(syminfo.ticker + " | MH BROKEN | PRICE=" + str.tostring(close, format.mintick) + " | MH=" + str.tostring(d_mh, format.mintick), alert.freq_once_per_bar_close)

if use_scan_alert and sig_in_rth and not na(d_mh) and ta.crossunder(close, d_mh)
    alert(syminfo.ticker + " | MH LOST | PRICE=" + str.tostring(close, format.mintick) + " | MH=" + str.tostring(d_mh, format.mintick), alert.freq_once_per_bar_close)

// ── EMA Cross Alerts (compact monitor/context format) ───────────────────────
// Previous full-context versions retained below for rollback/reference:
// ES1! | CLASS=MONITOR | TYPE=EMA_CROSS | EVENT=BULL | FAST_LEN=... | FAST=... | SLOW_LEN=... | SLOW=...
// ES1! | CLASS=MONITOR | TYPE=EMA_CROSS | EVENT=BEAR | FAST_LEN=... | FAST=... | SLOW_LEN=... | SLOW=...
if use_ema_alert and ema_bull_cross
    alert(syminfo.ticker + " | EMA BULL CROSS | EMA" + str.tostring(ema_fast_len) + "=" + str.tostring(chart_ema_fast, format.mintick) + " | EMA" + str.tostring(ema_slow_len) + "=" + str.tostring(chart_ema_slow, format.mintick), alert.freq_once_per_bar_close)

if use_ema_alert and ema_bear_cross
    alert(syminfo.ticker + " | EMA BEAR CROSS | EMA" + str.tostring(ema_fast_len) + "=" + str.tostring(chart_ema_fast, format.mintick) + " | EMA" + str.tostring(ema_slow_len) + "=" + str.tostring(chart_ema_slow, format.mintick), alert.freq_once_per_bar_close)

// ── SMA50 Monitor (compact MTF context format) ──────────────────────────────
// Previous full-context versions retained below for rollback/reference:
// ES1! | CLASS=MONITOR | TYPE=SMA50_STATE | EVENT=RECLAIM | TF=... | PRICE=... | SMA50=...
// ES1! | CLASS=MONITOR | TYPE=SMA50_STATE | EVENT=LOSS | TF=... | PRICE=... | SMA50=...
if sma_alert_active and alert_sma_reclaim and ta.crossover(sma_alert_close, sma_alert_sma50)
    alert(syminfo.ticker + " | SMA50 RECLAIM (" + tf_sma_alert + ") | PRICE=" + str.tostring(sma_alert_close, format.mintick) + " | SMA50=" + str.tostring(sma_alert_sma50, format.mintick), alert.freq_once_per_bar_close)

if sma_alert_active and alert_sma_loss and ta.crossunder(sma_alert_close, sma_alert_sma50)
    alert(syminfo.ticker + " | SMA50 LOSS (" + tf_sma_alert + ") | PRICE=" + str.tostring(sma_alert_close, format.mintick) + " | SMA50=" + str.tostring(sma_alert_sma50, format.mintick), alert.freq_once_per_bar_close)

// ============================================================================
// 7. PRICE SCALE LABELS
// ============================================================================

plot(show_cur_mon  ? d_mh  : na, "MH Axis",  color=col_mh,  editable=false, display=display.price_scale)
plot(show_cur_mon  ? d_ml  : na, "ML Axis",  color=col_ml,  editable=false, display=display.price_scale)
plot(show_mid      ? d_mid : na, "Mid Axis", color=col_mid, editable=false, display=display.price_scale)
plot(show_prev_mon ? d_pmh : na, "PMH Axis", color=col_pmh, editable=false, display=display.price_scale)
plot(show_prev_mon ? d_pml : na, "PML Axis", color=col_pml, editable=false, display=display.price_scale)
plot(show_mo       ? mo_open_rth : na, "MO Axis", color=col_mo, editable=false, display=display.price_scale)
plot(show_month_hl ? cur_month_high : na, "Month H Axis", color=col_month_h, editable=false, display=display.price_scale)
plot(show_month_hl ? cur_month_low  : na, "Month L Axis", color=col_month_l, editable=false, display=display.price_scale)
plot(show_month_hl and show_month_mid ? cur_month_mid : na, "Month Mid Axis", color=col_month_mid, editable=false, display=display.price_scale)
````

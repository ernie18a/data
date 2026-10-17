# Daily Deviation Range and Gap Stats - NikaQuant

- url: https://www.tradingview.com/script/xv3h3KJE-Daily-Deviation-Range-and-Gap-Stats-NikaQuant/
- type: indicator
- pine_id: PUB;097850bf122242099fbc928b4aafa74f
- version: 2.0

## Description

## What It Does

This indicator projects six pairs of deviation levels above and below a defined session range, draws a daily gap line at a configurable time, and shows a live stats panel with historical hit rates, mean-revert rates, gap fill statistics, and trade-decision suggestions.

The range itself is captured as the high and low of 5-minute closes during a configurable New York time window (default 19:30 to 20:30 NY). Once the window closes, the range is locked and six fibonacci-style deviation levels at multiples 1, 2.5, 5, 8, 13, and 19 of the range size are projected forward both upward and downward across the next trading day until a configurable cutoff (default 16:00 NY next day).

A separate gap line is captured at a configurable time (default 15:55 NY) using the close of that 5-minute bar. The gap line extends visually across the overnight session and is monitored for fill during the next session's open-to-close window (default 09:30 to 16:00 NY). When price crosses the gap level inside that window, the line is locked at the fill bar.

A live statistics table aggregates historical performance per day for the lookback period, showing per-level touch frequencies, mean-revert frequencies, close-inside-level frequencies, and gap fill statistics, then turns these into actionable trade-setup suggestions.

## Why It Is Original

Unlike a standard pivots or fibonacci-retracement indicator, this script is not a static price-level projection. It is a session-range deviation framework combined with an integrated gap tracker and a per-level historical statistics engine.

This script combines three distinct functional modules because each one addresses a different question about session structure:

(1) The range-multiple deviation levels answer "how far has price moved from session balance, in units of session range?" — analogous to standard-deviation channels but anchored to a user-defined range window rather than a rolling average.

(2) The daily gap line answers "is there an unfilled overnight reference price and what is the historical edge of trading toward it?" — different from standard gap detectors that only flag open-to-close gaps because it captures a specific price (the close at gap-time) and tracks fill behaviour inside a defined session window.

(3) The historical statistics engine answers "given today's structure, what has actually happened on past days when price reached the same levels or when a gap was open at this distance?" — turning the visual levels into probability-weighted decision inputs rather than just lines on a chart.

Together, the three modules produce something none of them would alone: a session-relative deviation map with quantified historical edge per level, plus a context-aware trade decision suggestion that combines current position, time remaining in the session, and historical revert behaviour.

The script also enforces a strict 5-minute internal data resolution regardless of chart timeframe (1-minute through 1-hour), so the levels and gap stay consistent whether the user is on a 5m chart or a 1H chart. This is accomplished via a dual-path data fetch that adapts to the chart's timeframe — pulling individual 5-minute samples on lower-timeframe charts and aggregating 5-minute closes per chart bar on higher-timeframe charts.

## How It Works

On each chart bar the script collects the 5-minute bars that have closed since the last update. For each 5-minute bar it checks whether the bar falls inside the range window, the extension window, the gap trigger time, or the gap fill window, and updates the relevant state.

When a 5-minute bar marks the end of the range window, the script locks in the highest and lowest 5-minute closes of the window, computes the range size and midline, and draws the deviation levels at multiples of the range above the high and below the low, projected forward to the configured extension-end time. A range-outline box is drawn over the range window for visual reference.

When a 5-minute bar matches the gap-trigger time, the script captures that bar's close as the gap price and starts drawing a horizontal line. On every subsequent 5-minute bar inside the next session's gap-fill window, the script checks whether the bar's high-low straddles the gap price. If so, the line is locked and the gap is recorded as filled.

Every time a deviation level is touched intraday — the 5-minute high reaches an upper level or the 5-minute low reaches a lower level — the script records that touch for the day. If price subsequently revisits the midline before the extension window ends, all touched levels for that day are also recorded as having reverted. When the extension window ends, the day's data is appended to a rolling history.

Each day's gap statistics (occurred, filled, minutes from fill-window open to fill) are appended at the next gap trigger, which ensures the gap is paired with its complete fill outcome before the next gap overwrites the live tracking state.

The stats table reads the history and renders per-level touch frequency, per-level revert frequency, close-inside-level frequency, gap fill rate, gap fill-time distribution (average, median, percent filled within 1 hour, percent filled within 4 hours), daily directional bias, range expansion vs contraction regime, day-type classification, time-elapsed in the active extension, and a context-aware trade-setup suggestion with stop and target prices for active fade setups.

The setup engine includes a time-remaining guard: when fewer minutes remain in the extension than the configured threshold, time-sensitive setups (fades and gap targets) are suppressed and the panel shows a "late session" status instead.

## How To Use It

- A range outline box appears over the range window once the window closes — this is the visual reference for the session range.
- Six pairs of lines extend forward from range-end to extension-end at multiples 1, 2.5, 5, 8, 13, and 19 of the range above and below the range high and low.
- Numerical labels at each level show the multiple — labels can be placed at the left or right end of the line via the "Level Label Side" setting.
- The gap line appears horizontally at the gap price after the configured gap time and extends until either price crosses through it during the fill window or the next day's gap is set.
- The live stats panel shows current price location vs midline (in range-multiples), today's range vs historical average, the current zone between two adjacent levels, the furthest level tagged today, per-level historical touch and revert rates, gap fill statistics, and a live setup suggestion.

Recommended timeframes: 1-minute through 1-hour. The script always uses 5-minute data internally, so behavior is consistent across chart timeframes.

Recommended markets: 24-hour markets such as index futures (ES, NQ), major FX pairs, and crypto majors, where overnight session structure matters and the configured NY-time windows align with meaningful session boundaries.

Avoid using when: less than 30 sessions of chart history are loaded (statistics will be unreliable) or on instruments that close before the configured range window (the range simply will not populate).

## Settings

- Max Deviation Days (default 11): how many past days to keep deviation levels visible. Older days are removed automatically.
- Show Deviation Levels: toggle the level lines.
- Normalize Range Size: when on, the range box and level distances use the average range over N past days instead of today's actual range.
- Normalize over N Days (default 500): number of past days to average for the normalization.
- Range Start and End Hour and Minute (default 19:30 to 20:30 NY): the window during which the range is captured.
- Extension Start and End Hour and Minute (default 20:30 to 16:00 NY next day): the window during which the deviation levels are drawn forward.
- Show Gap Level: toggle the gap line.
- Max Gap Days (default 11): number of past gap lines to keep visible.
- Gap Time Hour and Minute (default 15:55 NY): the 5-minute bar whose close becomes the gap price.
- Gap Close Start and End Hour and Minute (default 09:30 to 16:00 NY next day): the window during which gap fill is detected.
- Show Range Outline (default on): toggle the range outline box.
- Range Outline Color, Width, Style, Fill Transparency: visual settings for the box.
- Gap Width, Style, Color: visual settings for the gap line.
- Levels Width, Style: visual settings for the deviation lines.
- Level 1 through Level 6 (defaults 1, 2.5, 5, 8, 13, 19): numeric multiples of the range used for each level pair.
- Level 1 to 6 Color: per-level color.
- Level Label Side (default Left): place the level number labels at the left or right end of each line.
- Font Size (default 9): label font size.
- Show Stats Table (default on): toggle the live statistics panel.
- Stats Lookback in Days (default 5000): number of past completed days to include in historical statistics. Higher means more reliable percentages but requires more chart history loaded.
- Min Revert Percent for Fade Setup (default 55): a FADE setup is suggested only if the historical mean-revert rate at the touched level is at or above this threshold and the level was tagged at least 3 times in the lookback.
- Min Remaining Minutes for Setup (default 60): suppresses time-sensitive setups when fewer than this many minutes remain in the extension. Set to 0 to disable.
- Table Position (default Top Right): where the stats table is anchored.
- Table Size (default Normal): text size inside the stats table.
- Bull / Setup Color, Bear / Warning Color, Table Background, Table Text, Table Border: color settings for the panel.

## Alerts

Five alert conditions are exposed and can be selected from TradingView's "Add Alert" dialog:

- Range Locked: fires when the range window closes and the levels are projected.
- Level Tagged: fires the first time price reaches any deviation level on either side.
- Gap Set: fires when the daily gap level is captured.
- Gap Filled: fires when price crosses through an open gap during the fill window.
- Session End: fires when the extension window ends and stats are finalized.

## Notes

The script does not repaint after a 5-minute bar closes. The range, deviation levels, and gap line are drawn from confirmed data only. The live distance-from-midline and live setup suggestions update intrabar based on current price.

Future bar-index positions for projected lines and labels are estimated based on the chart timeframe's bar duration. On charts with weekend gaps the projected end positions may visually diverge from the configured extension-end time by a small amount, but the underlying logical end time is correct.

## Source Code

````pine
// © nikaquant.com
// V1.10
//@version=6
indicator("Daily Deviation — NikaQuant", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════
//  Daily Deviation + Historical Stats + Trade Decisions
//  Works on any chart TF from 1m to 1H. Always uses 5-minute data internally.
// ════════════════════════════════════════════════════════════════════════

TZ = "America/New_York"

// ─────────── Deviation ───────────
INP_days      = input.int(11, "Max Deviation Days", minval=1, maxval=30, group="Deviation",
     tooltip="Number of past days to draw deviation levels for. Older days are removed automatically (FIFO).")
INP_allow_dev = input.bool(true, "Show Deviation Levels?", group="Deviation",
     tooltip="Toggle the projected fibonacci-style deviation level lines on/off.")
INP_normalize_box  = input.bool(false, "Normalize Range Size?", group="Deviation",
     tooltip="When ON, the range outline box AND the deviation level distances use the AVERAGE range over N past days, instead of today's actual range. Today's midline is unchanged. Useful for keeping level magnitudes consistent across expansion / contraction days. Stats panel still shows today's ACTUAL range for the 'vs Avg' comparison.")
INP_normalize_days = input.int(500, "Normalize over N Days", minval=5, maxval=5000, group="Deviation",
     tooltip="How many past completed days to average the range over when normalization is ON. Higher = smoother, more consistent levels (recommended: 250-1000).")

// ─────────── Range Times (NY) ───────────
rs_h = input.int(19, "Range Start Hour", minval=0, maxval=23, group="Range Times",
     tooltip="Hour (NY time) when the range window begins. The range is built from the high/low of 5m closes inside this window.")
rs_m = input.int(30, "Range Start Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Range Times",
     tooltip="Minute (NY time) when the range window begins.")
re_h = input.int(20, "Range End Hour", minval=0, maxval=23, group="Range Times",
     tooltip="Hour (NY time) when the range window ends. After this moment the range is locked and levels are projected forward.")
re_m = input.int(30, "Range End Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Range Times",
     tooltip="Minute (NY time) when the range window ends.")

// ─────────── Extension Times (NY) ───────────
xs_h = input.int(20, "Extension Start Hour", minval=0, maxval=23, group="Extension Times",
     tooltip="Hour (NY time) when deviation level lines start drawing. Usually equals the range end hour.")
xs_m = input.int(30, "Extension Start Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Extension Times",
     tooltip="Minute (NY time) when deviation level lines start drawing.")
xe_h = input.int(16, "Extension End Hour", minval=0, maxval=23, group="Extension Times",
     tooltip="Hour (NY time) when deviation level lines stop. If earlier than start hour, it rolls to the next day (e.g. 16:00 next-day RTH close).")
xe_m = input.int(0, "Extension End Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Extension Times",
     tooltip="Minute (NY time) when deviation level lines stop.")

// ─────────── Gap ───────────
INP_allow_gap = input.bool(true, "Show Gap Level?", group="Gap",
     tooltip="Toggle the daily gap line that anchors at a specific NY time and remains until price trades through it next day.")
INP_gap_days  = input.int(11, "Max Gap Days", minval=1, maxval=30, group="Gap",
     tooltip="Number of past days to keep gap lines visible.")
g_h   = input.int(15, "Gap Time Hour", minval=0, maxval=23, group="Gap",
     tooltip="Hour (NY time) of the gap reference. The gap price = close of the 5m bar at this exact time.")
g_m   = input.int(55, "Gap Time Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Gap",
     tooltip="Minute (NY time) of the gap reference.")
gcs_h = input.int(9,  "Gap Close Start Hour", minval=0, maxval=23, group="Gap",
     tooltip="Hour (NY time) when the gap-fill detection window opens (typically the next session open).")
gcs_m = input.int(30, "Gap Close Start Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Gap",
     tooltip="Minute (NY time) when the gap-fill detection window opens.")
gce_h = input.int(16, "Gap Close End Hour", minval=0, maxval=23, group="Gap",
     tooltip="Hour (NY time) when the gap-fill detection window closes. Beyond this, the gap line stops checking for fills.")
gce_m = input.int(0,  "Gap Close End Minute", options=[0,5,10,15,20,25,30,35,40,45,50,55], group="Gap",
     tooltip="Minute (NY time) when the gap-fill detection window closes.")

// ─────────── Visuals ───────────
INP_draw_outline   = input.bool(true, "Show Range Outline?", group="Visuals")
INP_outline_clr    = input.color(#2962ff, "Range Outline Color", group="Visuals")
INP_outline_w      = input.int(1, "Range Outline Width", minval=1, group="Visuals")
INP_outline_sty    = input.string("Dashed", "Range Outline Style", options=["Solid","Dashed","Dotted"], group="Visuals")
INP_outline_fill_t = input.int(78, "Range Fill Transparency", minval=0, maxval=100, group="Visuals")

INP_gap_w   = input.int(2, "Gap Width", minval=1, group="Visuals")
INP_gap_sty = input.string("Solid", "Gap Style", options=["Solid","Dashed","Dotted"], group="Visuals")
INP_gap_clr = input.color(#78909c, "Gap Color", group="Visuals")

INP_fibo_w   = input.int(1, "Levels Width", minval=1, group="Visuals",
     tooltip="Line thickness for deviation level lines.")
INP_fibo_sty = input.string("Solid", "Levels Style", options=["Solid","Dashed","Dotted"], group="Visuals",
     tooltip="Line style for deviation level lines.")
INP_label_side = input.string("Left", "Level Label Side", options=["Left","Right"], group="Visuals",
     tooltip="Place the level number labels (1, 2.5, 5, etc.) on the LEFT (start of extension) or RIGHT (end of extension).")

INP_lv1 = input.float(1,   "Level 1", group="Levels")
INP_lv1_c = input.color(#26a69a, "Level 1 Color", group="Levels")
INP_lv2 = input.float(2.5, "Level 2", group="Levels")
INP_lv2_c = input.color(#26a69a, "Level 2 Color", group="Levels")
INP_lv3 = input.float(5,   "Level 3", group="Levels")
INP_lv3_c = input.color(#ffb74d, "Level 3 Color", group="Levels")
INP_lv4 = input.float(8,   "Level 4", group="Levels")
INP_lv4_c = input.color(#ffb74d, "Level 4 Color", group="Levels")
INP_lv5 = input.float(13,  "Level 5", group="Levels")
INP_lv5_c = input.color(#ef5350, "Level 5 Color", group="Levels")
INP_lv6 = input.float(19,  "Level 6", group="Levels")
INP_lv6_c = input.color(#ef5350, "Level 6 Color", group="Levels")

INP_font_size = input.int(9, "Font Size", minval=6, maxval=24, group="Visuals")

// ─────────── Stats / Decisions ───────────
INP_show_stats  = input.bool(true, "Show Stats Table", group="Stats",
     tooltip="Toggle the live stats / trade decision panel.")
INP_stats_days  = input.int(5000, "Stats Lookback (days)", minval=5, maxval=5000, group="Stats",
     tooltip="How many past completed days to use when computing hit rates, revert rates, and gap fill stats. Effectively 'all available history' at 5000.")
INP_revert_edge = input.int(55, "Min Revert % for Fade Setup", minval=30, maxval=95, group="Stats",
     tooltip="A FADE setup is suggested only if historical mean-revert rate at the touched level is at or above this threshold (and the level was tagged at least 3 times in lookback).")
INP_min_setup_mins = input.int(60, "Min Remaining Minutes for Setup", minval=0, maxval=600, group="Stats",
     tooltip="Suppress FADE / TARGET GAP setups when less than this many minutes remain in today's extension window. Prevents suggesting trades that have no time to work. Set to 0 to disable this check.")
INP_stats_pos   = input.string("top_right", "Table Position", options=["top_left","top_right","bottom_left","bottom_right","middle_right","middle_left"], group="Stats",
     tooltip="Where the stats table is anchored on the chart.")
INP_stats_size  = input.string("normal", "Table Size", options=["tiny","small","normal","large"], group="Stats",
     tooltip="Text size inside the stats table.")
INP_bull_txt    = input.color(#26a69a, "Bull / Setup Color", group="Stats",
     tooltip="Color used for bullish bias, long setups, and gap-filled state.")
INP_bear_txt    = input.color(#ef5350, "Bear / Warning Color", group="Stats",
     tooltip="Color used for bearish bias, short setups, and open gap state.")
INP_tbl_bg      = input.color(#0d1117, "Table Background", group="Stats")
INP_tbl_fg      = input.color(#e6edf3, "Table Text", group="Stats")
INP_tbl_border  = input.color(#1b2028, "Table Border", group="Stats")

// ─────────── Derived styles ───────────
style_of(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
fibo_style    = style_of(INP_fibo_sty)
outline_style = style_of(INP_outline_sty)
gap_style     = style_of(INP_gap_sty)
label_size    = INP_font_size <= 7 ? size.tiny : INP_font_size <= 9 ? size.small : INP_font_size <= 12 ? size.normal : size.large

tbl_pos = INP_stats_pos == "top_left" ? position.top_left : INP_stats_pos == "top_right" ? position.top_right : INP_stats_pos == "bottom_left" ? position.bottom_left : INP_stats_pos == "bottom_right" ? position.bottom_right : INP_stats_pos == "middle_right" ? position.middle_right : position.middle_left
tbl_size = INP_stats_size == "tiny" ? size.tiny : INP_stats_size == "small" ? size.small : INP_stats_size == "normal" ? size.normal : size.large

// Level arrays
levels  = array.from(INP_lv1, INP_lv2, INP_lv3, INP_lv4, INP_lv5, INP_lv6)
lv_clrs = array.from(INP_lv1_c, INP_lv2_c, INP_lv3_c, INP_lv4_c, INP_lv5_c, INP_lv6_c)

// Powers of 2 (for bitmask emulation — Pine has no bit-shift/bitwise operators)
pow2 = array.from(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048)

// Window boundaries (minute-of-day)
range_start_mod  = rs_h * 60 + rs_m
range_end_mod    = re_h * 60 + re_m
extend_start_mod = xs_h * 60 + xs_m
extend_end_mod   = xe_h * 60 + xe_m
gap_mod          = g_h  * 60 + g_m
gap_cs_mod       = gcs_h * 60 + gcs_m
gap_ce_mod       = gce_h * 60 + gce_m

// ─── helper: in-window check (handles midnight wrap) ───
in_window(sm, em, cm) => sm == em ? false : sm > em ? (cm >= sm or cm < em) : (cm >= sm and cm < em)

// ─── helper: approximate future bar offset ───
bars_to_future(target_ms) =>
    tf_s = timeframe.in_seconds(timeframe.period)
    diff = target_ms - time
    diff <= 0 ? 0 : math.max(1, math.min(2000, int(diff / (tf_s * 1000))))

// ─── helper: bit operations via integer arithmetic ───
bit_is_set(mask, j) =>
    p = array.get(pow2, j)
    int(mask / p) % 2 == 1

bit_set(mask, j) =>
    p = array.get(pow2, j)
    int(mask / p) % 2 == 1 ? mask : mask + p

// ─── helper: average of last N entries of a float array (used by normalization and stats) ───
avg_tail(arr, n) =>
    sz = array.size(arr)
    take = math.min(n, sz)
    tot = 0.0
    if take > 0
        for i = sz - take to sz - 1
            tot := tot + array.get(arr, i)
    take == 0 ? na : tot / take

// ════════════════════════════════════════════════════════════════════════
//  5m DATA FETCH — chart-TF agnostic
// ════════════════════════════════════════════════════════════════════════

// Path A (chart TF <= 5m): single 5m value per chart bar (non-repainting)
[sA_c, sA_h, sA_l, sA_t] = request.security(syminfo.tickerid, "5", [close[1], high[1], low[1], time[1]], lookahead=barmerge.lookahead_on)

// Path B (chart TF > 5m): array of all 5m bars within each chart bar
arrB_c = request.security_lower_tf(syminfo.tickerid, "5", close, ignore_invalid_timeframe=true)
arrB_h = request.security_lower_tf(syminfo.tickerid, "5", high,  ignore_invalid_timeframe=true)
arrB_l = request.security_lower_tf(syminfo.tickerid, "5", low,   ignore_invalid_timeframe=true)
arrB_t = request.security_lower_tf(syminfo.tickerid, "5", time,  ignore_invalid_timeframe=true)

// Build unified event list for THIS chart bar
var array<float> evt_c = array.new<float>()
var array<float> evt_h = array.new<float>()
var array<float> evt_l = array.new<float>()
var array<int>   evt_t = array.new<int>()

array.clear(evt_c)
array.clear(evt_h)
array.clear(evt_l)
array.clear(evt_t)

use_array_path = array.size(arrB_t) > 0

if use_array_path
    nB = array.size(arrB_t)
    for i = 0 to nB - 1
        ti = array.get(arrB_t, i)
        if not na(ti)
            array.push(evt_c, array.get(arrB_c, i))
            array.push(evt_h, array.get(arrB_h, i))
            array.push(evt_l, array.get(arrB_l, i))
            array.push(evt_t, ti)
else
    if not na(sA_t) and ta.change(sA_t) != 0
        array.push(evt_c, sA_c)
        array.push(evt_h, sA_h)
        array.push(evt_l, sA_l)
        array.push(evt_t, sA_t)

// ════════════════════════════════════════════════════════════════════════
//  STATE
// ════════════════════════════════════════════════════════════════════════
var float acc_high = na
var float acc_low  = na
var int   range_start_bar = na

// Today's locked range (today_hi/lo/rng = effective values used for drawing & touch detection;
//                       today_rng_actual = the unmodified actual range, used for stats display & history push)
var float today_hi         = na
var float today_lo         = na
var float today_mid        = na
var float today_rng        = na
var float today_rng_actual = na

// Today's touches (bitmask: bits 0-5 upper, bits 6-11 lower)
var int   today_touched_mask = 0
var bool  today_any_touch    = false
var bool  today_mid_revisit  = false
var float today_last_close   = na

// Active extension
var bool ext_active     = false
var int  ext_start_ms   = 0
var int  ext_end_ms     = 0
var int  ext_line_count = 0

// Active gap
var bool  gap_active     = false
var line  gap_line       = na
var label gap_lbl        = na
var float gap_price_live = na
var bool  today_gap_occurred = false
var bool  today_gap_filled   = false
var int   today_gap_time_ms  = 0
var int   today_gap_fill_ms  = 0
// Minutes from when the fill window OPENED (09:30 NY default) until the fill fired.
// Fills only happen during the fill window, so meaningful range is 0..(gap_ce_mod - gap_cs_mod).
var int   today_gap_fill_mins = 0

// Object pools (FIFO)
var array<line>  dev_lines    = array.new<line>()
var array<box>   dev_boxes    = array.new<box>()
var array<label> dev_labels   = array.new<label>()
var array<int>   batch_lines  = array.new<int>()
var array<int>   batch_boxes  = array.new<int>()
var array<int>   batch_labels = array.new<int>()

var array<line>  gap_line_pool  = array.new<line>()
var array<label> gap_label_pool = array.new<label>()

// Historical stats
var array<float> hist_rng       = array.new<float>()
var array<int>   hist_touch     = array.new<int>()    // bit j set if level j was tagged that day
var array<int>   hist_revert    = array.new<int>()    // bit j set if a touch at level j later mid-reverted
var array<int>   hist_close_out = array.new<int>()    // bit j set if FINAL close (at ext_end) was outside ±level_j
var array<bool>  hist_above     = array.new<bool>()
var array<bool>  hist_gap_o     = array.new<bool>()
var array<bool>  hist_gap_f     = array.new<bool>()
var array<int>   hist_gap_mins  = array.new<int>()

// ════════════════════════════════════════════════════════════════════════
//  EVENT LOOP
// ════════════════════════════════════════════════════════════════════════
// Alert flags — reset each chart bar, set TRUE inside the event loop when the relevant event fires.
// Must be declared OUTSIDE the event loop so alertcondition() can reference them at global scope.
bool alert_range_locked = false
bool alert_level_tagged = false
bool alert_gap_created  = false
bool alert_gap_filled   = false
bool alert_ext_ended    = false

n_events = array.size(evt_t)
if n_events > 0
    for ii = 0 to n_events - 1
        c5 = array.get(evt_c, ii)
        h5 = array.get(evt_h, ii)
        l5 = array.get(evt_l, ii)
        t5 = array.get(evt_t, ii)

        ny_hh_e = hour(t5, TZ)
        ny_mm_e = minute(t5, TZ)
        ny_d_e  = dayofmonth(t5, TZ)
        ny_mo_e = month(t5, TZ)
        ny_yr_e = year(t5, TZ)
        mod_e   = ny_hh_e * 60 + ny_mm_e

        in_rng_e = in_window(range_start_mod, range_end_mod, mod_e)
        in_ext_e = in_window(extend_start_mod, extend_end_mod, mod_e)
        in_gc_e  = in_window(gap_cs_mod, gap_ce_mod, mod_e)

        // ─── Range accumulation ───
        if in_rng_e
            if na(acc_high)
                acc_high := c5
                acc_low  := c5
                range_start_bar := bar_index
            else
                acc_high := math.max(acc_high, c5)
                acc_low  := math.min(acc_low,  c5)
        else
            if not na(acc_high) and not na(acc_low) and not ext_active
                // Finalize today's levels.
                // ACTUAL range = high - low of 5m closes during the range window (used for stats).
                acc_mid_e = (acc_high + acc_low) / 2.0
                acc_rng_e = acc_high - acc_low
                today_rng_actual := acc_rng_e
                today_mid := acc_mid_e
                // EFFECTIVE range = either today's actual or the N-day average (when normalization is ON).
                eff_rng_e = acc_rng_e
                if INP_normalize_box and array.size(hist_rng) > 0
                    avg_r_e = avg_tail(hist_rng, INP_normalize_days)
                    if not na(avg_r_e) and avg_r_e > 0
                        eff_rng_e := avg_r_e
                today_rng := eff_rng_e
                today_hi  := acc_mid_e + eff_rng_e / 2.0
                today_lo  := acc_mid_e - eff_rng_e / 2.0
                today_touched_mask := 0
                today_any_touch    := false
                today_mid_revisit  := false
                today_last_close   := c5
                // NOTE: today_gap_* state is intentionally NOT reset here.
                // The gap for THIS cycle was created at 15:55 BEFORE range_end at 20:30,
                // so its state must persist through the overnight fill window (09:30-16:00 next day).
                // The gap gets pushed to history and reset at the NEXT day's gap trigger (15:55).

                // FIFO cleanup
                while array.size(batch_lines) >= INP_days
                    n_ln = array.shift(batch_lines)
                    n_bx = array.shift(batch_boxes)
                    n_lb = array.shift(batch_labels)
                    if n_ln > 0
                        for kk = 1 to n_ln
                            line.delete(array.shift(dev_lines))
                    if n_bx > 0
                        for kk = 1 to n_bx
                            box.delete(array.shift(dev_boxes))
                    if n_lb > 0
                        for kk = 1 to n_lb
                            label.delete(array.shift(dev_labels))

                // Extension timestamps
                ext_start_ms_calc = timestamp(TZ, ny_yr_e, ny_mo_e, ny_d_e, int(extend_start_mod / 60), extend_start_mod % 60)
                if extend_start_mod < range_end_mod
                    ext_start_ms_calc := ext_start_ms_calc + 24 * 60 * 60 * 1000

                ext_end_ms_calc = timestamp(TZ, ny_yr_e, ny_mo_e, ny_d_e, int(extend_end_mod / 60), extend_end_mod % 60)
                if extend_end_mod <= extend_start_mod
                    ext_end_ms_calc := ext_end_ms_calc + 24 * 60 * 60 * 1000

                xs_bar = extend_start_mod == range_end_mod ? bar_index : bar_index + bars_to_future(ext_start_ms_calc)
                xe_bar = bar_index + bars_to_future(ext_end_ms_calc)
                lbl_x_pos = INP_label_side == "Left" ? xs_bar : xe_bar
                lbl_style_pos = INP_label_side == "Left" ? label.style_label_right : label.style_label_left

                // Range outline box
                n_box_drawn = 0
                if INP_draw_outline
                    left_bar = nz(range_start_bar, bar_index - 1)
                    fill_col = color.new(INP_outline_clr, INP_outline_fill_t)
                    b = box.new(left_bar, today_hi, bar_index - 1, today_lo, border_color=INP_outline_clr, bgcolor=fill_col, border_width=INP_outline_w, border_style=outline_style)
                    array.push(dev_boxes, b)
                    n_box_drawn := 1

                // Deviation levels
                n_lines_drawn  = 0
                n_labels_drawn = 0
                if INP_allow_dev
                    mid_ln = line.new(xs_bar, today_mid, xe_bar, today_mid, color=INP_lv1_c, width=INP_fibo_w, style=fibo_style)
                    array.push(dev_lines, mid_ln)
                    n_lines_drawn := n_lines_drawn + 1
                    mid_lb_obj = label.new(lbl_x_pos, today_mid, "0", xloc=xloc.bar_index, style=lbl_style_pos, color=color.new(color.black, 100), textcolor=INP_lv1_c, size=label_size)
                    array.push(dev_labels, mid_lb_obj)
                    n_labels_drawn := n_labels_drawn + 1

                    for j = 0 to 5
                        lv = array.get(levels, j)
                        cl = array.get(lv_clrs, j)
                        up_price = today_hi + today_rng * lv
                        up_ln = line.new(xs_bar, up_price, xe_bar, up_price, color=cl, width=INP_fibo_w, style=fibo_style)
                        array.push(dev_lines, up_ln)
                        n_lines_drawn := n_lines_drawn + 1
                        up_lb_obj = label.new(lbl_x_pos, up_price, str.tostring(lv, "#.#"), xloc=xloc.bar_index, style=lbl_style_pos, color=color.new(color.black, 100), textcolor=cl, size=label_size)
                        array.push(dev_labels, up_lb_obj)
                        n_labels_drawn := n_labels_drawn + 1

                        dn_price = today_lo - today_rng * lv
                        dn_ln = line.new(xs_bar, dn_price, xe_bar, dn_price, color=cl, width=INP_fibo_w, style=fibo_style)
                        array.push(dev_lines, dn_ln)
                        n_lines_drawn := n_lines_drawn + 1
                        dn_lb_obj = label.new(lbl_x_pos, dn_price, str.tostring(-lv, "#.#"), xloc=xloc.bar_index, style=lbl_style_pos, color=color.new(color.black, 100), textcolor=cl, size=label_size)
                        array.push(dev_labels, dn_lb_obj)
                        n_labels_drawn := n_labels_drawn + 1

                    ext_active     := true
                    ext_start_ms   := ext_start_ms_calc
                    ext_end_ms     := ext_end_ms_calc
                    ext_line_count := n_lines_drawn

                array.push(batch_lines,  n_lines_drawn)
                array.push(batch_boxes,  n_box_drawn)
                array.push(batch_labels, n_labels_drawn)

                acc_high := na
                acc_low  := na
                range_start_bar := na
                alert_range_locked := true

        // ─── Level touches + mean-revert during extension ───
        if ext_active and in_ext_e and not na(today_rng) and today_rng > 0
            today_last_close := c5
            for j = 0 to 5
                lv = array.get(levels, j)
                up_p = today_hi + today_rng * lv
                dn_p = today_lo - today_rng * lv
                if h5 >= up_p and not bit_is_set(today_touched_mask, j)
                    today_touched_mask := bit_set(today_touched_mask, j)
                    today_any_touch := true
                    alert_level_tagged := true
                if l5 <= dn_p and not bit_is_set(today_touched_mask, j + 6)
                    today_touched_mask := bit_set(today_touched_mask, j + 6)
                    today_any_touch := true
                    alert_level_tagged := true
            if today_any_touch and h5 >= today_mid and l5 <= today_mid
                today_mid_revisit := true

        // ─── Gap trigger (fires on every gap_mod 5m bar) ───
        if INP_allow_gap and mod_e == gap_mod
            // STEP 1 — PUSH PRIOR CYCLE'S GAP STATS before overwriting today_gap_*.
            // This pairs the gap (created yesterday at 15:55) with its complete fill outcome
            // (determined during 09:30-15:55 today's close window).
            if today_gap_occurred
                array.push(hist_gap_o, true)
                array.push(hist_gap_f, today_gap_filled)
                // Push minutes-from-fill-window-open (meaningful 0..390 range, not 1000+ from gap-creation).
                fill_mins_push = today_gap_filled ? today_gap_fill_mins : 0
                array.push(hist_gap_mins, fill_mins_push)
                // FIFO cleanup for gap history (sized separately from range history)
                max_gap_hist = INP_stats_days * 3
                while array.size(hist_gap_o) > max_gap_hist
                    array.shift(hist_gap_o)
                    array.shift(hist_gap_f)
                    array.shift(hist_gap_mins)

            // STEP 2 — lock any still-extending prior gap line so today's fresh line takes over
            if gap_active
                gap_active := false

            // STEP 3 — FIFO cleanup of drawn gap lines
            while array.size(gap_line_pool) >= INP_gap_days
                line.delete(array.shift(gap_line_pool))
                if array.size(gap_label_pool) > 0
                    label.delete(array.shift(gap_label_pool))

            // STEP 4 — create today's new gap line & reset tracking state
            gap_price_live := c5
            gap_line := line.new(bar_index, c5, bar_index, c5, color=INP_gap_clr, width=INP_gap_w, style=gap_style)
            array.push(gap_line_pool, gap_line)
            gap_lbl := label.new(bar_index, c5, "Gap", xloc=xloc.bar_index, style=label.style_label_right, color=color.new(color.black, 100), textcolor=INP_gap_clr, size=label_size)
            array.push(gap_label_pool, gap_lbl)

            gap_active          := true
            today_gap_occurred  := true
            today_gap_filled    := false
            today_gap_time_ms   := t5
            today_gap_fill_ms   := 0
            today_gap_fill_mins := 0
            alert_gap_created   := true

        // ─── Gap fill detection (skip same-bar trigger; require subsequent 5m bar) ───
        if gap_active and not na(gap_line) and t5 > today_gap_time_ms
            line.set_x2(gap_line, bar_index)
            if in_gc_e and h5 >= gap_price_live and gap_price_live >= l5
                gap_active := false
                today_gap_filled  := true
                today_gap_fill_ms := t5
                // Minutes from fill-window open (09:30 NY default) to fill moment.
                // Handles optional wrap-around if the fill window spans midnight.
                fill_mins_e = gap_cs_mod <= gap_ce_mod ? (mod_e - gap_cs_mod) : (mod_e >= gap_cs_mod ? mod_e - gap_cs_mod : (1440 - gap_cs_mod) + mod_e)
                today_gap_fill_mins := fill_mins_e
                alert_gap_filled := true

        // ─── End of extension: roll into history ───
        if ext_active and t5 > ext_end_ms
            ext_active := false
            alert_ext_ended := true
            above_mid = not na(today_last_close) and not na(today_mid) and today_last_close > today_mid
            rev_mask = today_mid_revisit ? today_touched_mask : 0
            // Compute close-outside bitmask for each of the 6 levels using ACTUAL range.
            close_out_mask_e = 0
            if not na(today_last_close) and not na(today_mid) and not na(today_rng_actual) and today_rng_actual > 0
                close_dev_abs = math.abs((today_last_close - today_mid) / today_rng_actual)
                for jcl = 0 to 5
                    if close_dev_abs > array.get(levels, jcl)
                        close_out_mask_e := bit_set(close_out_mask_e, jcl)
            // Push NON-GAP stats here at ext_end. Gap stats are pushed separately
            // at the next day's gap trigger (so the gap is paired with its correct fill outcome).
            array.push(hist_rng,       nz(today_rng_actual, 0))
            array.push(hist_touch,     today_touched_mask)
            array.push(hist_revert,    rev_mask)
            array.push(hist_close_out, close_out_mask_e)
            array.push(hist_above,     above_mid)
            max_hist = INP_stats_days * 3
            while array.size(hist_rng) > max_hist
                array.shift(hist_rng)
                array.shift(hist_touch)
                array.shift(hist_revert)
                array.shift(hist_close_out)
                array.shift(hist_above)

// ════════════════════════════════════════════════════════════════════════
//  LIVE LINE RE-PROJECTION — keep the right edge anchored at ext_end_ms
//  (not at current bar — that was the V1.09 bug that made lines grow
//   slowly from range_end instead of extending immediately to 16:00 NY).
//  Each bar, recompute the projected end bar based on remaining time.
// ════════════════════════════════════════════════════════════════════════
if ext_active and ext_line_count > 0 and time <= ext_end_ms
    target_x2 = bar_index + bars_to_future(ext_end_ms)
    total = array.size(dev_lines)
    start_i = total - ext_line_count
    if start_i >= 0
        for k = start_i to total - 1
            line.set_x2(array.get(dev_lines, k), target_x2)

// ════════════════════════════════════════════════════════════════════════
//  STATS HELPERS
// ════════════════════════════════════════════════════════════════════════
count_bit_tail(arr, j, n) =>
    sz = array.size(arr)
    take = math.min(n, sz)
    cnt = 0
    p = array.get(pow2, j)
    if take > 0
        for i = sz - take to sz - 1
            if int(array.get(arr, i) / p) % 2 == 1
                cnt := cnt + 1
    [cnt, take]

// Count days where EITHER bit j_up OR bit j_dn was set (for "either side" hit-rate)
count_either_bit_tail(arr, j_up, j_dn, n) =>
    sz = array.size(arr)
    take = math.min(n, sz)
    cnt = 0
    p_up = array.get(pow2, j_up)
    p_dn = array.get(pow2, j_dn)
    if take > 0
        for i = sz - take to sz - 1
            v = array.get(arr, i)
            up_set = int(v / p_up) % 2 == 1
            dn_set = int(v / p_dn) % 2 == 1
            if up_set or dn_set
                cnt := cnt + 1
    [cnt, take]

count_bool_tail(arr, n) =>
    sz = array.size(arr)
    take = math.min(n, sz)
    cnt = 0
    if take > 0
        for i = sz - take to sz - 1
            if array.get(arr, i)
                cnt := cnt + 1
    [cnt, take]

avg_tail_cond(arr, cond_arr, n) =>
    sz = array.size(arr)
    take = math.min(n, sz)
    tot = 0.0
    c = 0
    if take > 0
        for i = sz - take to sz - 1
            if array.get(cond_arr, i) and array.get(arr, i) > 0
                tot := tot + array.get(arr, i)
                c := c + 1
    c == 0 ? na : tot / c

// Median of last N filled-gap times (only counting days where gap actually filled)
median_fill_tail(arr_mins, arr_filled, n) =>
    sz = array.size(arr_mins)
    take = math.min(n, sz)
    vals = array.new<int>()
    if take > 0
        for i = sz - take to sz - 1
            if array.get(arr_filled, i) and array.get(arr_mins, i) > 0
                array.push(vals, array.get(arr_mins, i))
    cnt = array.size(vals)
    result = float(na)
    if cnt > 0
        sorted = array.copy(vals)
        array.sort(sorted, order.ascending)
        if cnt % 2 == 1
            result := float(array.get(sorted, cnt / 2))
        else
            result := (float(array.get(sorted, cnt / 2 - 1)) + float(array.get(sorted, cnt / 2))) / 2.0
    result

// Of last N filled gaps, count how many filled within `threshold_minutes`. Returns [within, total_filled]
pct_fill_within(arr_mins, arr_filled, n, threshold_minutes) =>
    sz = array.size(arr_mins)
    take = math.min(n, sz)
    filled = 0
    within = 0
    if take > 0
        for i = sz - take to sz - 1
            if array.get(arr_filled, i) and array.get(arr_mins, i) > 0
                filled := filled + 1
                if array.get(arr_mins, i) <= threshold_minutes
                    within := within + 1
    [within, filled]

// ════════════════════════════════════════════════════════════════════════
//  STATS TABLE
// ════════════════════════════════════════════════════════════════════════
var table stats_tbl = na
if INP_show_stats and barstate.islast
    if na(stats_tbl)
        stats_tbl := table.new(tbl_pos, 2, 32, bgcolor=INP_tbl_bg, border_color=INP_tbl_border, border_width=1, frame_color=INP_tbl_border, frame_width=1)
    table.clear(stats_tbl, 0, 0, 1, 31)

    // ─── Live metrics ───
    live_dev = not na(today_mid) and not na(today_rng) and today_rng > 0 ? (close - today_mid) / today_rng : na

    zone_str = "—"
    if not na(live_dev)
        ad = math.abs(live_dev)
        sign_str = live_dev >= 0 ? "+" : "-"
        lb_z = 0.0
        ub_z = 99.0
        found = false
        for j = 0 to 5
            lv = array.get(levels, j)
            if not found and ad < lv
                ub_z := lv
                found := true
            if not found
                lb_z := lv
        zone_str := sign_str + str.tostring(lb_z, "#.#") + " / " + sign_str + (ub_z == 99.0 ? ">max" : str.tostring(ub_z, "#.#"))

    // Furthest level today — track both sides independently (scan from largest level down)
    furthest_up_lv = 0.0
    furthest_dn_lv = 0.0
    for jj = 0 to 5
        idx = 5 - jj
        if furthest_up_lv == 0.0 and bit_is_set(today_touched_mask, idx)
            furthest_up_lv := array.get(levels, idx)
        if furthest_dn_lv == 0.0 and bit_is_set(today_touched_mask, idx + 6)
            furthest_dn_lv := array.get(levels, idx)
    furthest_str = furthest_up_lv == 0.0 and furthest_dn_lv == 0.0 ? "—" :
                   furthest_up_lv > 0.0 and furthest_dn_lv > 0.0 ? "+" + str.tostring(furthest_up_lv, "#.#") + " / -" + str.tostring(furthest_dn_lv, "#.#") :
                   furthest_up_lv > 0.0 ? "+" + str.tostring(furthest_up_lv, "#.#") :
                   "-" + str.tostring(furthest_dn_lv, "#.#")
    // Side indicator for coloring: 1 = only upper, -1 = only lower, 2 = both sides, 0 = none
    furthest_side = furthest_up_lv > 0.0 and furthest_dn_lv > 0.0 ? 2 : furthest_up_lv > 0.0 ? 1 : furthest_dn_lv > 0.0 ? -1 : 0

    avg_rng_val = avg_tail(hist_rng, INP_stats_days)
    rng_pct_str = not na(today_rng_actual) and not na(avg_rng_val) and avg_rng_val > 0 ? str.tostring(math.round(100 * today_rng_actual / avg_rng_val)) + "%" : "—"

    // Gap state
    gap_dist_str = "—"
    gap_state_str = "no gap"
    if today_gap_occurred
        if gap_active and not na(gap_price_live)
            diff = close - gap_price_live
            gap_dist_str := (diff >= 0 ? "+" : "") + str.tostring(diff, format.mintick)
            gap_state_str := "open"
        else if today_gap_filled
            gap_state_str := "filled"

    [gf_cnt, gf_take] = count_bool_tail(hist_gap_f, INP_stats_days)
    [go_cnt, go_take] = count_bool_tail(hist_gap_o, INP_stats_days)
    gap_fill_rate_str = go_cnt > 0 ? str.tostring(math.round(100 * gf_cnt / go_cnt)) + "% (" + str.tostring(gf_cnt) + "/" + str.tostring(go_cnt) + ")" : "—"
    avg_fill_mins = avg_tail_cond(hist_gap_mins, hist_gap_f, INP_stats_days)
    avg_fill_str = na(avg_fill_mins) ? "—" : avg_fill_mins < 60 ? str.tostring(math.round(avg_fill_mins)) + "m" : str.tostring(avg_fill_mins / 60, "#.#") + "h"

    // Side bias
    [ab_cnt, ab_take] = count_bool_tail(hist_above, INP_stats_days)
    bias_pct = ab_take > 0 ? math.round(100 * ab_cnt / ab_take) : 50
    bias_str = bias_pct >= 60 ? "UP " + str.tostring(bias_pct) + "%" : bias_pct <= 40 ? "DOWN " + str.tostring(100 - bias_pct) + "%" : "Neutral " + str.tostring(bias_pct) + "/" + str.tostring(100 - bias_pct)

    // Trade Decision
    setup_text = "— no setup —"
    setup_clr  = color.new(INP_tbl_fg, 30)

    // Time-remaining guard — suppress time-sensitive setups late in the extension window.
    remaining_mins_setup = ext_active and ext_end_ms > 0 ? (ext_end_ms - time) / 60000.0 : 0.0
    time_blocked = INP_min_setup_mins > 0 and ext_active and remaining_mins_setup < INP_min_setup_mins and remaining_mins_setup > 0

    if not na(live_dev) and not time_blocked
        same_side = live_dev > 0 ? 1 : -1
        touched_ix = -1
        for jj2 = 0 to 5
            idx2 = 5 - jj2
            bit_off = same_side > 0 ? idx2 : idx2 + 6
            if touched_ix == -1 and bit_is_set(today_touched_mask, bit_off)
                touched_ix := idx2
        if touched_ix >= 0 and math.abs(live_dev) >= array.get(levels, touched_ix) * 0.95
            bit_off2 = same_side > 0 ? touched_ix : touched_ix + 6
            [t_cnt, t_take] = count_bit_tail(hist_touch, bit_off2, INP_stats_days)
            [r_cnt, r_take] = count_bit_tail(hist_revert, bit_off2, INP_stats_days)
            revert_rate = t_cnt > 0 ? math.round(100 * r_cnt / t_cnt) : 0
            lv_fade = array.get(levels, touched_ix)
            if t_cnt >= 3 and revert_rate >= INP_revert_edge
                setup_text := "FADE " + (same_side > 0 ? "+" : "-") + str.tostring(lv_fade, "#.#") + " → Mid (" + str.tostring(revert_rate) + "% rev, " + str.tostring(t_cnt) + "/" + str.tostring(t_take) + ")"
                setup_clr := same_side > 0 ? INP_bear_txt : INP_bull_txt

    if gap_active and not na(gap_price_live) and not na(today_mid) and not time_blocked
        between = (close > today_mid and close < gap_price_live) or (close < today_mid and close > gap_price_live)
        if between and go_cnt >= 3 and gf_cnt * 100 >= INP_revert_edge * go_cnt
            gfr = math.round(100 * gf_cnt / go_cnt)
            dir_up = gap_price_live > close
            setup_text := "TARGET GAP " + (dir_up ? "LONG ↑" : "SHORT ↓") + " (" + str.tostring(gfr) + "% fill)"
            setup_clr := dir_up ? INP_bull_txt : INP_bear_txt

    if not na(live_dev) and math.abs(live_dev) > 1.0 and today_any_touch and not today_mid_revisit and setup_text == "— no setup —"
        setup_text := "TREND DAY — no revert"
        setup_clr := color.new(INP_tbl_fg, 20)

    // Late-session override — if time_blocked killed a potential setup, say so clearly.
    if time_blocked and setup_text == "— no setup —"
        setup_text := "LATE SESSION — " + str.tostring(math.round(remaining_mins_setup)) + "min left"
        setup_clr := color.new(INP_tbl_fg, 20)

    // ─── Populate table (with hover tooltips) ───
    r = 0
    table.cell(stats_tbl, 0, r, "DAILY DEVIATION", text_color=INP_tbl_fg, bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="Daily Deviation indicator stats panel. All percentages are computed over the last N completed days set in 'Stats Lookback'.")
    table.cell(stats_tbl, 1, r, "Hist: " + str.tostring(array.size(hist_rng)) + "d", text_color=INP_tbl_fg, bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="Number of completed days currently stored in history. Load more chart history to grow this number.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Price vs Mid", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Current price's distance from today's midline, expressed in range-multiples. +1.0 means price is one full range above midline; -2.5 means 2.5 ranges below.")
    dev_clr = na(live_dev) ? INP_tbl_fg : live_dev > 0 ? INP_bull_txt : INP_bear_txt
    dev_str = na(live_dev) ? "—" : (live_dev >= 0 ? "+" : "") + str.tostring(live_dev, "#.##")
    table.cell(stats_tbl, 1, r, dev_str, text_color=dev_clr, text_size=tbl_size,
         tooltip="Live deviation in range-multiples. Compare to the level numbers (1, 2.5, 5, 8, 13, 19) to see which zone you are in.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Zone", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Which deviation zone the price is currently in (between two adjacent levels).")
    table.cell(stats_tbl, 1, r, zone_str, text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Lower bound / upper bound (in range-multiples) of the zone enclosing live price.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Today Range", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Today's ACTUAL range = highest 5m close minus lowest 5m close inside the range window. (Even when 'Normalize Range' is ON, this cell shows today's real measured range.)")
    table.cell(stats_tbl, 1, r, na(today_rng_actual) ? "—" : str.tostring(today_rng_actual, format.mintick) + (INP_normalize_box ? "  (norm: " + str.tostring(today_rng, format.mintick) + ")" : ""), text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Range value in price units. When normalization is ON, the value in parentheses is the normalized range used for drawing levels.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "vs Avg", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Today's range as a percentage of the average range over the lookback window. >120% = expansion day; <80% = contraction.")
    table.cell(stats_tbl, 1, r, rng_pct_str, text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Range expansion/contraction signal vs. lookback average.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Furthest Today", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="The furthest deviation level price has tagged today (max magnitude on either side).")
    f_clr = furthest_side == 2 ? color.new(INP_tbl_fg, 20) : furthest_side == 1 ? INP_bull_txt : furthest_side == -1 ? INP_bear_txt : INP_tbl_fg
    table.cell(stats_tbl, 1, r, furthest_str, text_color=f_clr, text_size=tbl_size,
         tooltip="Sign indicates upper (+) or lower (-) side. Magnitude is the level multiple.")
    r := r + 1

    // ── "Within ±X" stats — both TOUCH (intraday max range) and CLOSE (final close at ext_end) ──
    // Within ±8 (level index 3 by default = 8)
    [w8_touch_cnt, w8_take] = count_either_bit_tail(hist_touch, 3, 9, INP_stats_days)
    [w8_close_cnt, w8c_take] = count_bit_tail(hist_close_out, 3, INP_stats_days)
    w8_touch_pct = w8_take > 0 ? math.round(100 * (w8_take - w8_touch_cnt) / w8_take) : 0
    w8_close_pct = w8c_take > 0 ? math.round(100 * (w8c_take - w8_close_cnt) / w8c_take) : 0
    lv_8 = array.get(levels, 3)
    w8_tip = "Of " + str.tostring(w8_take) + " days:  " + str.tostring(w8_take - w8_touch_cnt) + " (" + str.tostring(w8_touch_pct) + "%) never tagged either side of ±" + str.tostring(lv_8, "#.#") + " intraday.   " + str.tostring(w8c_take - w8_close_cnt) + " (" + str.tostring(w8_close_pct) + "%) had the FINAL close (at extension end / 16:00 NY) inside ±" + str.tostring(lv_8, "#.#") + "."
    table.cell(stats_tbl, 0, r, "Within ±" + str.tostring(lv_8, "#.#"), text_color=INP_tbl_fg, text_size=tbl_size, tooltip=w8_tip)
    table.cell(stats_tbl, 1, r, "T " + str.tostring(w8_touch_pct) + "%  /  C " + str.tostring(w8_close_pct) + "%",
         text_color=w8_touch_pct >= 70 ? INP_bull_txt : w8_touch_pct >= 50 ? INP_tbl_fg : INP_bear_txt, text_size=tbl_size, tooltip=w8_tip)
    r := r + 1

    // Within ±MAX (largest level — index 5 = 19 by default)
    [w19_touch_cnt, w19_take] = count_either_bit_tail(hist_touch, 5, 11, INP_stats_days)
    [w19_close_cnt, w19c_take] = count_bit_tail(hist_close_out, 5, INP_stats_days)
    w19_touch_pct = w19_take > 0 ? math.round(100 * (w19_take - w19_touch_cnt) / w19_take) : 0
    w19_close_pct = w19c_take > 0 ? math.round(100 * (w19c_take - w19_close_cnt) / w19c_take) : 0
    max_lv = array.get(levels, 5)
    w19_tip = "Of " + str.tostring(w19_take) + " days:  " + str.tostring(w19_take - w19_touch_cnt) + " (" + str.tostring(w19_touch_pct) + "%) never tagged either side of ±" + str.tostring(max_lv, "#.#") + " intraday.   " + str.tostring(w19c_take - w19_close_cnt) + " (" + str.tostring(w19_close_pct) + "%) had the FINAL close inside ±" + str.tostring(max_lv, "#.#") + ".  T = touched neither side intraday.  C = final close inside the level."
    table.cell(stats_tbl, 0, r, "Within ±" + str.tostring(max_lv, "#.#"), text_color=INP_tbl_fg, text_size=tbl_size, tooltip=w19_tip)
    table.cell(stats_tbl, 1, r, "T " + str.tostring(w19_touch_pct) + "%  /  C " + str.tostring(w19_close_pct) + "%",
         text_color=w19_touch_pct >= 80 ? INP_bull_txt : w19_touch_pct >= 60 ? INP_tbl_fg : INP_bear_txt, text_size=tbl_size, tooltip=w19_tip)
    r := r + 1

    table.cell(stats_tbl, 0, r, "── HIT / REVERT ──", text_color=color.new(INP_tbl_fg, 40), bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="Per-level historical statistics over the lookback window.")
    table.cell(stats_tbl, 1, r, "U% / D% / T% / Rev%", text_color=color.new(INP_tbl_fg, 40), bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="U% = % of days only the UPPER side of this level was tagged.  D% = % for lower side.  T% = TOTAL — % of days EITHER side was tagged (treats ±X as the same level — answers 'how often does price reach this magnitude?').  Rev% = of all touches at this level, what % returned to midline before the extension ended.")
    r := r + 1

    for jr = 0 to 5
        lv = array.get(levels, jr)
        cl = array.get(lv_clrs, jr)
        [u_cnt, u_take] = count_bit_tail(hist_touch, jr, INP_stats_days)
        [d_cnt, d_take] = count_bit_tail(hist_touch, jr + 6, INP_stats_days)
        [t_cnt, t_take] = count_either_bit_tail(hist_touch, jr, jr + 6, INP_stats_days)
        [ur_cnt, ur_take] = count_bit_tail(hist_revert, jr, INP_stats_days)
        [dr_cnt, dr_take] = count_bit_tail(hist_revert, jr + 6, INP_stats_days)
        u_pct = u_take > 0 ? math.round(100 * u_cnt / u_take) : 0
        d_pct = u_take > 0 ? math.round(100 * d_cnt / u_take) : 0
        t_pct = t_take > 0 ? math.round(100 * t_cnt / t_take) : 0
        tot_t = u_cnt + d_cnt
        tot_r = ur_cnt + dr_cnt
        r_pct = tot_t > 0 ? math.round(100 * tot_r / tot_t) : 0
        lv_tip = "Level ±" + str.tostring(lv, "#.#") + " over " + str.tostring(t_take) + " days:  Up tagged " + str.tostring(u_cnt) + " (" + str.tostring(u_pct) + "%).  Down tagged " + str.tostring(d_cnt) + " (" + str.tostring(d_pct) + "%).  EITHER side tagged " + str.tostring(t_cnt) + " (" + str.tostring(t_pct) + "%).  Of " + str.tostring(tot_t) + " touches, " + str.tostring(tot_r) + " (" + str.tostring(r_pct) + "%) reverted to midline."
        table.cell(stats_tbl, 0, r, "±" + str.tostring(lv, "#.#"), text_color=cl, text_size=tbl_size, tooltip=lv_tip)
        table.cell(stats_tbl, 1, r, str.tostring(u_pct) + " / " + str.tostring(d_pct) + " / " + str.tostring(t_pct) + " / " + str.tostring(r_pct), text_color=INP_tbl_fg, text_size=tbl_size, tooltip=lv_tip)
        r := r + 1

    table.cell(stats_tbl, 0, r, "── GAP ──", text_color=color.new(INP_tbl_fg, 40), bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="Daily gap line statistics. The gap = the close of the 5m bar at gap-time NY (default 15:55). It is 'filled' when price crosses through it during the close window (default 09:30–16:00 next day).")
    table.cell(stats_tbl, 1, r, "", bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size)
    r := r + 1

    table.cell(stats_tbl, 0, r, "Gap State", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Today's gap state: 'open' = not yet filled.  'filled' = price already crossed the gap level.  'no gap' = today's gap-time hasn't fired yet.")
    gs_clr = gap_state_str == "open" ? INP_bear_txt : gap_state_str == "filled" ? INP_bull_txt : INP_tbl_fg
    gs_text = gap_state_str + (gap_dist_str == "—" ? "" : "  " + gap_dist_str)
    table.cell(stats_tbl, 1, r, gs_text, text_color=gs_clr, text_size=tbl_size,
         tooltip="If 'open', the value shown is the LIVE signed distance from current price to the gap level. Positive = gap above price, negative = gap below price.")
    r := r + 1

    // Gap target direction (live trading-relevant): tells you which way price needs to move to fill
    gap_dir_str = "—"
    gap_dir_clr = INP_tbl_fg
    if gap_active and not na(gap_price_live)
        if gap_price_live > close
            gap_dir_str := "↑ LONG to fill"
            gap_dir_clr := INP_bull_txt
        else if gap_price_live < close
            gap_dir_str := "↓ SHORT to fill"
            gap_dir_clr := INP_bear_txt
        else
            gap_dir_str := "AT GAP"
    table.cell(stats_tbl, 0, r, "Gap Target", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="The direction price needs to move to fill the open gap. Combined with the historical fill rate, this is the actionable gap-trade signal.")
    table.cell(stats_tbl, 1, r, gap_dir_str, text_color=gap_dir_clr, text_size=tbl_size,
         tooltip="Long = buy here aiming for the gap above.  Short = sell here aiming for the gap below.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Fill Rate", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Of all past days that had a gap set, what % were filled inside the close window.")
    fr_clr = go_cnt > 0 and (gf_cnt * 100 / go_cnt) >= 60 ? INP_bull_txt : go_cnt > 0 and (gf_cnt * 100 / go_cnt) <= 30 ? INP_bear_txt : INP_tbl_fg
    table.cell(stats_tbl, 1, r, gap_fill_rate_str, text_color=fr_clr, text_size=tbl_size,
         tooltip="Format: pct% (filled / occurred). Above 60% suggests gap-fill plays have a positive edge; below 30% means gaps usually hold and you should consider trading WITH the direction of the gap instead.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Avg Fill Time", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="AVERAGE minutes from when the fill window OPENED (default 09:30 NY) until the gap filled. Only days that actually filled are counted. Max possible = fill window length (default 6.5h).")
    table.cell(stats_tbl, 1, r, avg_fill_str, text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Shown in minutes (m) under 60, otherwise hours (h). Small values = gap usually fills early in the session.")
    r := r + 1

    // Median fill time
    median_mins = median_fill_tail(hist_gap_mins, hist_gap_f, INP_stats_days)
    median_str = na(median_mins) ? "—" : median_mins < 60 ? str.tostring(math.round(median_mins)) + "m" : str.tostring(median_mins / 60, "#.#") + "h"
    table.cell(stats_tbl, 0, r, "Median Fill", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="MEDIAN minutes from fill-window open to fill. More robust than average when a few outlier days take very long. Half of all filled gaps fill faster than this.")
    table.cell(stats_tbl, 1, r, median_str, text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="If median << avg, most gaps fill quickly with a few slow outliers skewing the average up.")
    r := r + 1

    // Fill within 60 minutes from window open
    [fw60_w, fw60_t] = pct_fill_within(hist_gap_mins, hist_gap_f, INP_stats_days, 60)
    fw60_pct = fw60_t > 0 ? math.round(100 * fw60_w / fw60_t) : 0
    table.cell(stats_tbl, 0, r, "Fill <1h", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Of FILLED gaps, what % filled within the first 60 minutes AFTER the fill window opened (default 09:30-10:30 NY).")
    table.cell(stats_tbl, 1, r, str.tostring(fw60_pct) + "% (" + str.tostring(fw60_w) + "/" + str.tostring(fw60_t) + ")", text_color=fw60_pct >= 60 ? INP_bull_txt : INP_tbl_fg, text_size=tbl_size,
         tooltip="High % means most gaps fill in the first hour of the session — early-session gap fades have a strong edge.")
    r := r + 1

    // Fill within 4 hours from window open
    [fw240_w, fw240_t] = pct_fill_within(hist_gap_mins, hist_gap_f, INP_stats_days, 240)
    fw240_pct = fw240_t > 0 ? math.round(100 * fw240_w / fw240_t) : 0
    table.cell(stats_tbl, 0, r, "Fill <4h", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Of FILLED gaps, what % filled within the first 4 hours of the fill window (default 09:30-13:30 NY).")
    table.cell(stats_tbl, 1, r, str.tostring(fw240_pct) + "% (" + str.tostring(fw240_w) + "/" + str.tostring(fw240_t) + ")", text_color=fw240_pct >= 80 ? INP_bull_txt : INP_tbl_fg, text_size=tbl_size,
         tooltip="Combined with Fill <1h, gives you a sense of the fill-time distribution shape.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "── DECISION ──", text_color=color.new(INP_tbl_fg, 40), bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size,
         tooltip="Live trade-setup decision panel based on current position vs historical edge.")
    table.cell(stats_tbl, 1, r, "", bgcolor=color.new(INP_tbl_border, 0), text_size=tbl_size)
    r := r + 1

    table.cell(stats_tbl, 0, r, "Daily Bias", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Historical directional bias = % of past days that closed (at extension end) above the midline.  ≥60% = UP-biased.  ≤40% = DOWN-biased.  In between = neutral.")
    bias_clr = bias_pct >= 60 ? INP_bull_txt : bias_pct <= 40 ? INP_bear_txt : INP_tbl_fg
    table.cell(stats_tbl, 1, r, bias_str, text_color=bias_clr, text_size=tbl_size,
         tooltip="Strong bias means trades aligned with the bias have higher base-rate odds of finishing in the money at the extension end.")
    r := r + 1

    // Range Regime
    rng_regime = "—"
    rng_regime_clr = INP_tbl_fg
    if not na(today_rng_actual) and not na(avg_rng_val) and avg_rng_val > 0
        rng_pct_n = 100 * today_rng_actual / avg_rng_val
        if rng_pct_n > 130
            rng_regime := "Expansion " + str.tostring(math.round(rng_pct_n)) + "%"
            rng_regime_clr := INP_bear_txt
        else if rng_pct_n < 75
            rng_regime := "Contraction " + str.tostring(math.round(rng_pct_n)) + "%"
            rng_regime_clr := INP_bull_txt
        else
            rng_regime := "Normal " + str.tostring(math.round(rng_pct_n)) + "%"
    table.cell(stats_tbl, 0, r, "Range Regime", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Today's range vs lookback average.  EXPANSION (>130%) = wider-than-usual range; mean-revert plays often fail.  NORMAL (75-130%) = standard.  CONTRACTION (<75%) = compressed; expect breakout volatility.")
    table.cell(stats_tbl, 1, r, rng_regime, text_color=rng_regime_clr, text_size=tbl_size,
         tooltip="Range expansion days favor trend-continuation. Range contraction days favor breakout / volatility plays.")
    r := r + 1

    // Day Type — categorize what's happening today
    day_type = "Pending"
    day_type_clr = color.new(INP_tbl_fg, 40)
    if not na(today_rng) and today_rng > 0
        if not today_any_touch
            day_type := "Quiet (no touch)"
            day_type_clr := INP_tbl_fg
        else if today_mid_revisit
            day_type := "Mean-Revert ✓"
            day_type_clr := INP_bull_txt
        else
            day_type := "Trend (no revert)"
            day_type_clr := INP_bear_txt
    table.cell(stats_tbl, 0, r, "Day Type", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Live classification of today's behavior.  PENDING = range not yet built.  QUIET = no levels tagged yet.  MEAN-REVERT = touched a level AND returned to midline (revert worked).  TREND = touched a level but no return — fade plays will likely fail today.")
    table.cell(stats_tbl, 1, r, day_type, text_color=day_type_clr, text_size=tbl_size,
         tooltip="On TREND days, switch from mean-revert to trend-continuation. On MEAN-REVERT days, fade subsequent level touches with confidence.")
    r := r + 1

    // Time elapsed in extension (uses actual ext_start_ms — accurate for any configured window)
    time_elapsed_str = "—"
    remaining_mins_live = 0.0
    if ext_active and ext_start_ms > 0 and ext_end_ms > 0
        elapsed_h = (time - ext_start_ms) / (60.0 * 60 * 1000)
        remaining_h = (ext_end_ms - time) / (60.0 * 60 * 1000)
        remaining_mins_live := remaining_h * 60
        if remaining_h > 0
            time_elapsed_str := str.tostring(math.max(0, elapsed_h), "#.#") + "h done / " + str.tostring(remaining_h, "#.#") + "h left"
        else
            time_elapsed_str := "extension over"
    else if not ext_active
        time_elapsed_str := "no active ext"
    table.cell(stats_tbl, 0, r, "Time", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Approximate progress through today's extension window. Mean-revert plays late in the session have less time to work.")
    table.cell(stats_tbl, 1, r, time_elapsed_str, text_color=color.new(INP_tbl_fg, 30), text_size=tbl_size,
         tooltip="Hours elapsed since extension start / hours remaining until extension end.")
    r := r + 1

    table.cell(stats_tbl, 0, r, "Setup", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Live trade-setup suggestion combining current position with historical edge.  FADE = mean-revert play to midline.  TARGET GAP = directional play toward open gap.  TREND DAY = warning that mean-revert is failing.")
    table.cell(stats_tbl, 1, r, setup_text, text_color=setup_clr, text_size=tbl_size,
         tooltip="Suggestions only — always confirm with your own analysis. (% rev) = historical revert rate at this level. (% fill) = historical gap fill rate.")
    r := r + 1

    // Stop / Target prices when a FADE setup is active
    st_text = "—"
    st_clr = color.new(INP_tbl_fg, 40)
    if not na(live_dev) and not na(today_mid) and not na(today_rng) and today_rng > 0
        same_side_st = live_dev > 0 ? 1 : -1
        touched_ix_st = -1
        for jjs = 0 to 5
            idxs = 5 - jjs
            bit_off_s = same_side_st > 0 ? idxs : idxs + 6
            if touched_ix_st == -1 and bit_is_set(today_touched_mask, bit_off_s)
                touched_ix_st := idxs
        if touched_ix_st >= 0
            target_p = today_mid
            // Stop = next level above (or 1 range buffer if at max)
            stop_lv = touched_ix_st < 5 ? array.get(levels, touched_ix_st + 1) : array.get(levels, 5) + 5
            stop_p = same_side_st > 0 ? today_hi + stop_lv * today_rng : today_lo - stop_lv * today_rng
            risk_amt = math.abs(close - stop_p)
            reward_amt = math.abs(close - target_p)
            rr = risk_amt > 0 ? reward_amt / risk_amt : 0
            st_text := "T " + str.tostring(target_p, format.mintick) + "  S " + str.tostring(stop_p, format.mintick) + "  R:R 1:" + str.tostring(rr, "#.#")
            st_clr := same_side_st > 0 ? INP_bear_txt : INP_bull_txt
    table.cell(stats_tbl, 0, r, "Stop / Target", text_color=INP_tbl_fg, text_size=tbl_size,
         tooltip="Suggested stop and target for the FADE setup.  Target = today's midline.  Stop = next deviation level beyond the touched level (a buffer above the level, or +5 range-multiples if already at max).  R:R = risk-to-reward ratio.")
    table.cell(stats_tbl, 1, r, st_text, text_color=st_clr, text_size=tbl_size,
         tooltip="T = take-profit price (midline).  S = stop-loss price (next level beyond). 1:X means you risk 1 unit to make X. Aim for at least 1:2 for a tradeable setup.")

// ════════════════════════════════════════════════════════════════════════
//  ALERTS — fire at natural event boundaries. Users configure these via
//  TradingView's "Add Alert" dialog and pick the desired condition.
// ════════════════════════════════════════════════════════════════════════
alertcondition(alert_range_locked, title="Nika DD — Range Locked",
     message="Nika DD: Range window closed. Deviation levels are now projected for the session.")
alertcondition(alert_level_tagged, title="Nika DD — Level Tagged",
     message="Nika DD: Price has tagged a deviation level. Check the stats panel for the level magnitude and revert odds.")
alertcondition(alert_gap_created, title="Nika DD — Gap Set",
     message="Nika DD: Daily gap level has been set. Fill window opens at the configured gap-close time next day.")
alertcondition(alert_gap_filled, title="Nika DD — Gap Filled",
     message="Nika DD: Price has crossed through the gap level. Gap is now filled.")
alertcondition(alert_ext_ended, title="Nika DD — Session End",
     message="Nika DD: Extension window has ended. Today's stats are now finalized.")
````

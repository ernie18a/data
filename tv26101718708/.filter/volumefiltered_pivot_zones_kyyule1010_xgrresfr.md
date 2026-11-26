# Volume-Filtered Pivot Zones [ky_yule1010]

- url: https://www.tradingview.com/script/xgRrEsFr-Volume-Filtered-Pivot-Zones-ky-yule1010/
- type: indicator
- pine_id: PUB;2c42b2fce6d5491a84f97cb8889b9259
- version: 1.0

## Description

[b]Volume-Filtered Pivot Zones[/b]
Detects swing pivots only when they occur on meaningful volume, then clusters them into weighted support/resistance zones using ATR-based proximity. The result is a clean, adaptive S/R map that evolves with the market rather than cluttering the chart with every minor swing.

[b]Core Concept[/b]
Not all pivots are equal. A swing high printed on 2× relative volume carries far more institutional weight than one on dead tape. This indicator filters pivots through a configurable RVOL threshold (rolling SMA or time-of-day normalized), retains only the validated ones in a managed pool, and merges nearby pivots into zones using RVOL-weighted centroids. Zones closer to price activate; distant ones sit dormant until price revisits.
Why It Works

High-RVOL pivots act as gravity — price tends to revisit levels where significant volume transacted, making these zones natural magnets for mean-reversion and re-tests.
Pivot-anchored VWAP resets on each validated pivot, giving you a more responsive fair-value reference than session or fixed-anchor VWAP. It adapts to the market's actual turning points rather than arbitrary time boundaries.

[b]Key Features[/b]

LTF Volume-Weighted mode — pivots are detected on wicks but the S/R line is drawn at the micro-VWAP from lower-timeframe bars, pinpointing where volume actually concentrated at the turning point.
Zone weight scoring — each zone carries a weight (touch count × average RVOL) so you can immediately see which levels have the deepest structural backing.
Volume gradient heatmap — visualizes volume density above and below active zones, highlighting friction (price slows) vs. voids (price rips).
Fair Value Gap detection — flags statistically large FVGs (P75+) as potential re-fill targets.
Comprehensive Gradient Score (CGS) — blends density asymmetry, ATR-normalized slope, acceleration, and rejection quality into a single directional bias reading.
Structure bias tracking — HH/HL vs. LH/LL sequence detection with staleness decay and price-position overrides.
Full data export — nearest S/R levels, distances, zone weights, RVOL, slope, acceleration, rejection quality, and CGS all plotted to the status line and data window.

[b]Suggested Use[/b]
Use zone weight and the volume gradient to gauge conviction at each level — heavy zones with dense volume below support (or above resistance) tend to hold. Thin zones sitting in a volume void are breakout candidates. The CGS and density bias readings provide at-a-glance directional context without needing a separate oscillator.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
// © ky_yule1010

//@version=5
indicator("Volume-Filtered Pivot Zones [ky_yule1010]", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── INPUTS ──────────────────────────────────────────────────────────────

// Pivot Detection
pivotLen      = input.int(5, "Pivot Lookback Length", minval=2, maxval=50, group="Pivot Detection")
pivotConfirm  = input.int(3, "Pivot Confirmation Bars", minval=1, maxval=10, group="Pivot Detection", tooltip="Bars after pivot to confirm it")
pivotSource   = input.string("LTF Volume-Weighted", "Pivot Source", options=["High / Low", "Close", "LTF Volume-Weighted"], group="Pivot Detection", tooltip="High/Low uses wick extremes for S/R levels. Close uses the settled price. LTF Volume-Weighted detects pivots on wicks but draws the S/R line at the micro-VWAP from lower-timeframe bars — the price where volume actually concentrated at the turning point.")

// Lower Timeframe Settings (used only when Pivot Source = "LTF Volume-Weighted")
ltf_timeframe  = input.timeframe("5", "Lower Timeframe", group="LTF Settings", tooltip="The sub-bar timeframe to analyze. Must be LOWER than your chart timeframe (e.g., 5min for a 30min chart, 1min for a 5min chart). Only used when Pivot Source = 'LTF Volume-Weighted'.")
ltf_rej_zone   = input.float(0.20, "Rejection Zone (%)", minval=0.05, maxval=0.50, step=0.05, group="LTF Settings", tooltip="Fraction of the bar's range near the extreme to count as 'at the high/low' for rejection sharpness. 0.20 = top/bottom 20% of the bar.")
show_rej_score = input.bool(true, "Show Rejection Sharpness", group="LTF Settings", tooltip="Display rejection sharpness (0–1) in pivot labels and data export. 1.0 = instant spike & reject, 0.0 = price sat at the extreme.")

// Relative Volume Filter
rvol_method    = input.string("Time of Day", "RVOL Method", options=["Rolling SMA", "Time of Day"], group="Relative Volume Filter")
rvol_sma_len   = input.int(20, "Rolling SMA Length", minval=5, maxval=200, group="Relative Volume Filter", tooltip="Lookback for rolling average volume")
rvol_threshold = input.float(1.2, "RVOL Threshold", minval=0.5, maxval=5.0, step=0.1, group="Relative Volume Filter", tooltip="Minimum relative volume to validate a pivot")
tod_lookback   = input.int(10, "Time-of-Day Lookback Days", minval=3, maxval=60, group="Relative Volume Filter", tooltip="Days to average for time-of-day comparison")

// ─── ZONE MANAGEMENT INPUTS ─────────────────────────────────────────────

pool_max        = input.int(40, "Max Pivot Pool Size", minval=10, maxval=60, group="Zone Management", tooltip="Total number of raw volume-validated pivots to retain. Larger = deeper structural memory. Old/far pivots are evicted by staleness rules.")
cluster_mult    = input.float(0.40, "Cluster Radius (ATR ×)", minval=0.10, maxval=1.50, step=0.05, group="Zone Management", tooltip="Pivots within this ATR multiple of each other merge into one zone. The zone's representative price becomes the RVOL-weighted centroid of all constituent pivots. 0.40 works well for 30min SPY.")
activation_mult = input.float(2.0, "Activation Radius (ATR ×)", minval=0.5, maxval=5.0, step=0.25, group="Zone Management", tooltip="Only zones within this ATR multiple of the current close are considered 'active' — plotted and fed into the gradient engine. Everything else sits dormant in the pool until price revisits.")
stale_bars_evict = input.int(500, "Staleness Eviction (Bars)", minval=50, maxval=2000, group="Zone Management", tooltip="Pivots older than this many bars AND farther than the staleness distance are removed from the pool entirely.")
stale_dist_evict = input.float(3.0, "Staleness Distance (ATR ×)", minval=1.0, maxval=10.0, step=0.5, group="Zone Management", tooltip="Distance threshold for staleness eviction. A pivot must be BOTH old (bars) AND far (ATR) to be evicted. This prevents removing old pivots that price is still near.")
show_zone_wt    = input.bool(true, "Show Zone Weight Labels", group="Zone Management", tooltip="Display a small label at each active zone showing its weight (touch count × avg RVOL).")
atr_length      = input.int(14, "ATR Length", minval=5, maxval=100, group="Zone Management", tooltip="Lookback for Average True Range, used for clustering, activation, gradient radius, and reaction strength scaling.")

// S/R Display
show_sr        = input.bool(true, "Show S/R Lines", group="Support / Resistance")
sr_max_lines   = input.int(10, "Max Active Zone Lines", minval=2, maxval=20, group="Support / Resistance", tooltip="Maximum number of zone lines to display. When more zones are active, only the highest-weight ones are shown.")
sr_extend      = input.bool(true, "Extend Lines Right", group="Support / Resistance")
sr_line_width  = input.int(3, "Max Line Width", minval=1, maxval=4, group="Support / Resistance", tooltip="Line width for the highest-weight zones. Lower-weight zones get thinner lines.")
res_color      = input.color(color.new(#ef5350, 20), "Resistance Color", group="Support / Resistance")
sup_color      = input.color(color.new(#26a69a, 20), "Support Color", group="Support / Resistance")
sr_style_input = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Support / Resistance")
enable_sr_flip = input.bool(true, "Flip S/R on Price Cross", group="Support / Resistance", tooltip="When price closes beyond a zone centroid, flip its role: resistance becomes support and vice versa.")

// VWAP
show_vwap     = input.bool(true, "Show Pivot-Anchored VWAP", group="VWAP")
vwap_width    = input.int(2, "VWAP Line Width", minval=1, maxval=4, group="VWAP")
vwap_bull_col = input.color(color.new(#26a69a, 0), "VWAP Bullish Color", group="VWAP")
vwap_bear_col = input.color(color.new(#ef5350, 0), "VWAP Bearish Color", group="VWAP")
vwap_neut_col = input.color(color.new(#787b86, 0), "VWAP Neutral Color", group="VWAP")

// Labels
show_labels   = input.bool(true, "Show All Pivot Labels", group="Labels")
show_low_labels   = input.bool(false, "Show Low RVOL Pivot Labels", group="Labels")
label_size_in = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal"], group="Labels")

// ─── FVG ZONES ──────────────────────────────────────────────────────────

show_fvg_zones    = input.bool(true, "Draw FVG Zones", group="FVG Zones", tooltip="Shade large fair value gaps on the chart")
fvg_size_lookback = input.int(100, "FVG Size Percentile Lookback", minval=20, maxval=500, group="FVG Zones", tooltip="Bars to calculate FVG size percentile (P75 = large)")
fvg_bull_zone     = input.color(color.new(#22c55e, 85), "Bull FVG Zone", group="FVG Zones")
fvg_bear_zone     = input.color(color.new(#ef4444, 85), "Bear FVG Zone", group="FVG Zones")

// ─── VOLUME GRADIENT INPUTS ─────────────────────────────────────────────

show_vol_gradient = input.bool(true, "Show Volume Gradient", group="Volume Gradient", tooltip="Draws a volume heatmap above and below active zones near price. Dense bins = friction (price slows), thin bins = void (price rips).")
vg_lookback       = input.int(50, "Profile Lookback Bars", minval=10, maxval=300, group="Volume Gradient", tooltip="How many bars of volume history to bucket into the profile.")
vg_bins           = input.int(8, "Number of Bins", minval=4, maxval=16, group="Volume Gradient", tooltip="Price subdivisions per side of the S/R level.")
vg_radius_mult    = input.float(1.5, "Zone Radius (ATR ×)", minval=0.5, maxval=5.0, step=0.25, group="Volume Gradient", tooltip="Half-height of the gradient zone around each level, expressed as a multiple of ATR.")
vg_display_bars   = input.int(30, "Display Width (Bars)", minval=5, maxval=100, group="Volume Gradient")
vg_right_ext      = input.int(5, "Right Extension (Bars)", minval=0, maxval=30, group="Volume Gradient")
vg_max_transp     = input.int(96, "Max Transparency (void)", minval=80, maxval=99, group="Volume Gradient")
vg_min_transp     = input.int(30, "Min Transparency (dense)", minval=5, maxval=70, group="Volume Gradient")
vg_res_color      = input.color(#b33735, "Resistance Gradient Color", group="Volume Gradient")
vg_sup_color      = input.color(color.rgb(27, 114, 64), "Support Gradient Color", group="Volume Gradient")
vg_decay_factor   = input.float(0.97, "Recency Decay Factor", minval=0.90, maxval=1.00, step=0.005, group="Volume Gradient", tooltip="Exponential decay applied to older bars in the volume profile. 1.00 = equal weight. 0.97 = bar 50 carries ~22% the weight of bar 0.")

// Bar Coloring by Gradient Bias
show_bias_bars  = input.bool(false, "Color Bars by Gradient Bias", group="Volume Gradient")
gb_smooth_len   = input.int(1, "Gradient Bias SMA Length", minval=1, maxval=50, group="Volume Gradient")
gb_neut_thresh  = input.float(0.10, "Bias Neutral Threshold", minval=0.01, maxval=0.50, step=0.01, group="Volume Gradient")
gb_bull_bar_col = input.color(color.new(#26a69a, 0), "Bias Bull Bar Color", group="Volume Gradient")
gb_bear_bar_col = input.color(color.new(#ef5350, 0), "Bias Bear Bar Color", group="Volume Gradient")
gb_neut_bar_col = input.color(color.new(#787b86, 50), "Bias Neutral Bar Color", group="Volume Gradient")

// Comprehensive Gradient Score
cgs_w_density   = input.float(0.40, "CGS: Density Weight",      minval=0.0, maxval=1.0, step=0.05, group="Volume Gradient", tooltip="Weight of volume-density asymmetry (existing gradient bias) in the comprehensive score.")
cgs_w_slope     = input.float(0.30, "CGS: Slope Weight",        minval=0.0, maxval=1.0, step=0.05, group="Volume Gradient", tooltip="Weight of ATR-normalised slope from the nearest centroid.")
cgs_w_accel     = input.float(0.20, "CGS: Acceleration Weight", minval=0.0, maxval=1.0, step=0.05, group="Volume Gradient", tooltip="Weight of slope acceleration (2nd derivative).")
cgs_w_rej       = input.float(0.10, "CGS: Rejection Weight",    minval=0.0, maxval=1.0, step=0.05, group="Volume Gradient", tooltip="Weight of candle rejection quality when price is near an active centroid.")
cgs_accel_scale = input.float(10.0, "CGS: Accel Scaler",        minval=1.0, maxval=50.0, step=1.0, group="Volume Gradient", tooltip="Multiplier to bring raw acceleration to comparable magnitude before clamping to ±1.")

// Structure Bias
struct_stale_bars    = input.int(30, "Structure Staleness (Bars)", minval=5, maxval=100, group="Structure Bias", tooltip="After this many bars without a new pivot (of either type), fade structure bias toward neutral.")
struct_price_override = input.bool(true, "Price Position Override", group="Structure Bias", tooltip="When price closes above the last pivot high, a bearish bias is forced neutral (and vice versa).")

// ─── REACTION STRENGTH INPUTS ───────────────────────────────────────────

show_reaction     = input.bool(true, "Enable Reaction Metrics", group="Reaction Strength", tooltip="Compute ATR-normalized slope from nearest active centroid, acceleration (2nd derivative), and proximity-gated rejection quality.")
rs_slope_method   = input.string("LinReg", "Slope Method", options=["Raw", "LinReg"], group="Reaction Strength", tooltip="Raw = (close − level) / ATR — responds instantly but noisy. LinReg = ATR-normalized regression slope — institutional-quality smoothing.")
rs_linreg_len     = input.int(10, "LinReg Length", minval=3, maxval=50, group="Reaction Strength", tooltip="Bars of price history used for the linear regression slope.")
rs_accel_smooth   = input.int(3, "Acceleration EMA", minval=1, maxval=20, group="Reaction Strength", tooltip="EMA smoothing applied to the raw acceleration (slope − slope[1]). 1 = no smoothing.")
rs_show_rejection = input.bool(true, "Compute Rejection Quality", group="Reaction Strength", tooltip="Candle close position (0–1) computed only when price is near an active centroid.")
rs_rej_prox_mult  = input.float(0.50, "Rejection Proximity (Act. Radius ×)", minval=0.10, maxval=1.00, step=0.05, group="Reaction Strength", tooltip="Fraction of the activation radius within which rejection quality is computed.")

// Data Export
show_status = input.bool(false, "Plot Levels to Status Line", group="Data Export", tooltip="Plots nearest S/R levels, VWAP, RVOL, and zone weights to the status line and data window for CSV export")

// ─── HELPERS ─────────────────────────────────────────────────────────────

sr_line_style = switch sr_style_input
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

label_size = switch label_size_in
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

use_ltf = pivotSource == "LTF Volume-Weighted"

// ─── ATR ────────────────────────────────────────────────────────────────
atr_val = ta.atr(atr_length)

// ─── LOWER TIMEFRAME DATA ───────────────────────────────────────────────

[ltf_h, ltf_l, ltf_c, ltf_v] = request.security_lower_tf(syminfo.tickerid, ltf_timeframe, [high, low, close, volume])

// ─── PER-BAR LTF METRICS ───────────────────────────────────────────────

var float ltf_micro_vwap    = na
var float ltf_rej_at_high   = na
var float ltf_rej_at_low    = na
var float ltf_vol_ratio_top = na
var float ltf_vol_ratio_bot = na

ltf_count = array.size(ltf_h)

if ltf_count > 0
    float sum_pv = 0.0
    float sum_v  = 0.0
    float parent_range      = high - low
    float near_hi_threshold = parent_range > 0 ? high - parent_range * ltf_rej_zone : high
    float near_lo_threshold = parent_range > 0 ? low  + parent_range * ltf_rej_zone : low
    float vol_zone          = parent_range > 0 ? parent_range * 0.30 : 0.0
    float top_zone_floor    = high - vol_zone
    float bot_zone_ceil     = low  + vol_zone

    int bars_near_high = 0
    int bars_near_low  = 0
    float vol_in_top = 0.0
    float vol_in_bot = 0.0
    float vol_total  = 0.0

    for i = 0 to ltf_count - 1
        float h = array.get(ltf_h, i)
        float l = array.get(ltf_l, i)
        float c = array.get(ltf_c, i)
        float v = array.get(ltf_v, i)
        float hlc = (h + l + c) / 3.0

        sum_pv   += hlc * v
        sum_v    += v
        vol_total += v

        if h >= near_hi_threshold
            bars_near_high += 1
        if l <= near_lo_threshold
            bars_near_low += 1

        float mid = (h + l) / 2.0
        if parent_range > 0
            if mid >= top_zone_floor
                vol_in_top += v
            if mid <= bot_zone_ceil
                vol_in_bot += v

    ltf_micro_vwap := sum_v > 0 ? sum_pv / sum_v : hlc3

    if ltf_count > 1
        ltf_rej_at_high := 1.0 - (bars_near_high * 1.0) / (ltf_count * 1.0)
        ltf_rej_at_low  := 1.0 - (bars_near_low  * 1.0) / (ltf_count * 1.0)
    else
        ltf_rej_at_high := 0.5
        ltf_rej_at_low  := 0.5

    ltf_vol_ratio_top := vol_total > 0 ? vol_in_top / vol_total : 0.0
    ltf_vol_ratio_bot := vol_total > 0 ? vol_in_bot / vol_total : 0.0
else
    ltf_micro_vwap    := hlc3
    ltf_rej_at_high   := na
    ltf_rej_at_low    := na
    ltf_vol_ratio_top := na
    ltf_vol_ratio_bot := na

// ─── RELATIVE VOLUME CALCULATION ────────────────────────────────────────

vol_sma      = ta.sma(volume, rvol_sma_len)
rvol_rolling = vol_sma > 0 ? volume / vol_sma : 0.0

var float[] tod_vol_history = array.new_float(0)
var int[]   tod_bar_indices = array.new_int(0)

is_new_session = ta.change(time("D")) != 0
var int bars_into_session = 0
bars_into_session := is_new_session ? 0 : bars_into_session + 1

var float tod_avg_vol = na
var int session_count = 0

var int[] session_start_bars = array.new_int(0)
if is_new_session
    array.push(session_start_bars, bar_index)
    session_count += 1
    if array.size(session_start_bars) > tod_lookback + 1
        array.shift(session_start_bars)

f_tod_avg_volume() =>
    float sum_vol = 0.0
    int count     = 0
    int n_sessions = array.size(session_start_bars)
    if n_sessions > 1
        int current_offset = bars_into_session
        for i = 0 to n_sessions - 2
            int sess_start = array.get(session_start_bars, i)
            int target_bar = sess_start + current_offset
            if target_bar < bar_index and target_bar >= sess_start
                float hist_vol = volume[bar_index - target_bar]
                if not na(hist_vol) and hist_vol > 0
                    sum_vol += hist_vol
                    count   += 1
    count > 0 ? sum_vol / count : na

tod_avg_vol_calc = f_tod_avg_volume()
rvol_tod = not na(tod_avg_vol_calc) and tod_avg_vol_calc > 0 ? volume / tod_avg_vol_calc : 0.0

rvol = rvol_method == "Rolling SMA" ? rvol_rolling : rvol_tod

// ─── PIVOT DETECTION ────────────────────────────────────────────────────

ph_source = pivotSource == "Close" ? close : high
pl_source = pivotSource == "Close" ? close : low

ph = ta.pivothigh(ph_source, pivotLen, pivotConfirm)
pl = ta.pivotlow(pl_source,  pivotLen, pivotConfirm)

var float  last_ph = na
var float  last_pl = na
var int    last_ph_bar = na
var int    last_pl_bar = na

var string pivot_type    = na
var bool   pivot_is_high = false
var float  pivot_price   = na
var float  pivot_rvol    = na
var int    pivot_bar     = na
var float  pivot_rej_score = na

// ─── ALL-PIVOT STRUCTURE TRACKING ───────────────────────────────────────

var float  struct_prev_ph = na
var float  struct_last_ph = na
var float  struct_prev_pl = na
var float  struct_last_pl = na
var int    struct_last_bar = na

var string structure_bias = "neutral"

f_calc_structure_bias(_prev_ph, _last_ph, _prev_pl, _last_pl) =>
    if na(_prev_ph) or na(_prev_pl)
        "neutral"
    else
        bool highs_rising  = _last_ph > _prev_ph
        bool highs_falling = _last_ph < _prev_ph
        bool lows_rising   = _last_pl > _prev_pl
        bool lows_falling  = _last_pl < _prev_pl

        if highs_rising and lows_rising
            "bullish"
        else if highs_falling and lows_falling
            "bearish"
        else
            "neutral"

if not na(ph)
    raw_ph = ph

    if use_ltf
        pivot_price := nz(ltf_micro_vwap[pivotConfirm], raw_ph)
    else
        pivot_price := raw_ph

    pivot_is_high := true
    pivot_bar     := bar_index - pivotConfirm
    pivot_rvol    := rvol[pivotConfirm]
    pivot_rej_score := use_ltf ? nz(ltf_rej_at_high[pivotConfirm], na) : na

    if na(last_ph)
        pivot_type := "HH"
    else
        pivot_type := raw_ph > last_ph ? "HH" : "LH"

    last_ph     := raw_ph
    last_ph_bar := bar_index - pivotConfirm

    struct_prev_ph := struct_last_ph
    struct_last_ph := raw_ph
    struct_last_bar := bar_index - pivotConfirm
    structure_bias := f_calc_structure_bias(struct_prev_ph, struct_last_ph, struct_prev_pl, struct_last_pl)

if not na(pl)
    raw_pl = pl

    if use_ltf
        pivot_price := nz(ltf_micro_vwap[pivotConfirm], raw_pl)
    else
        pivot_price := raw_pl

    pivot_is_high := false
    pivot_bar     := bar_index - pivotConfirm
    pivot_rvol    := rvol[pivotConfirm]
    pivot_rej_score := use_ltf ? nz(ltf_rej_at_low[pivotConfirm], na) : na

    if na(last_pl)
        pivot_type := "LL"
    else
        pivot_type := raw_pl > last_pl ? "HL" : "LL"

    last_pl     := raw_pl
    last_pl_bar := bar_index - pivotConfirm

    struct_prev_pl := struct_last_pl
    struct_last_pl := raw_pl
    struct_last_bar := bar_index - pivotConfirm
    structure_bias := f_calc_structure_bias(struct_prev_ph, struct_last_ph, struct_prev_pl, struct_last_pl)

// ─── STRUCTURE BIAS OVERRIDES ───────────────────────────────────────────

int bars_since_pivot = not na(struct_last_bar) ? (bar_index - struct_last_bar) : 9999

if bars_since_pivot > struct_stale_bars and structure_bias != "neutral"
    structure_bias := "neutral"

if struct_price_override
    if structure_bias == "bearish" and not na(struct_last_ph) and close > struct_last_ph
        structure_bias := "neutral"
    if structure_bias == "bullish" and not na(struct_last_pl) and close < struct_last_pl
        structure_bias := "neutral"

// ═════════════════════════════════════════════════════════════════════════
// ─── RAW PIVOT POOL ─────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

var float[]  pool_price     = array.new_float(0)
var float[]  pool_rvol      = array.new_float(0)
var int[]    pool_bar       = array.new_int(0)
var bool[]   pool_is_high   = array.new_bool(0)
var string[] pool_type      = array.new_string(0)
var float[]  pool_rej_score = array.new_float(0)

var bool pool_changed = false

// ─── VOLUME VALIDATION & POOL INSERTION ─────────────────────────────────

bool is_validated = false

if not na(ph) or not na(pl)
    is_validated := pivot_rvol >= rvol_threshold

    if is_validated
        array.push(pool_price,     pivot_price)
        array.push(pool_rvol,      pivot_rvol)
        array.push(pool_bar,       pivot_bar)
        array.push(pool_is_high,   pivot_is_high)
        array.push(pool_type,      pivot_type)
        array.push(pool_rej_score, nz(pivot_rej_score, na))
        pool_changed := true

        while array.size(pool_price) > pool_max
            array.shift(pool_price)
            array.shift(pool_rvol)
            array.shift(pool_bar)
            array.shift(pool_is_high)
            array.shift(pool_type)
            array.shift(pool_rej_score)

// ─── STALENESS EVICTION ─────────────────────────────────────────────────

if array.size(pool_price) > 0 and not na(atr_val) and atr_val > 0
    float evict_dist = atr_val * stale_dist_evict
    int pool_n = array.size(pool_price)
    for i = pool_n - 1 to 0
        int   p_bar   = array.get(pool_bar, i)
        float p_price = array.get(pool_price, i)
        int   age     = bar_index - p_bar
        float dist    = math.abs(close - p_price)

        if age > stale_bars_evict and dist > evict_dist
            array.remove(pool_price,     i)
            array.remove(pool_rvol,      i)
            array.remove(pool_bar,       i)
            array.remove(pool_is_high,   i)
            array.remove(pool_type,      i)
            array.remove(pool_rej_score, i)
            pool_changed := true

// ═════════════════════════════════════════════════════════════════════════
// ─── ZONE CLUSTERING ENGINE ─────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

var float[] zone_centroid   = array.new_float(0)
var int[]   zone_count      = array.new_int(0)
var float[] zone_sum_rvol   = array.new_float(0)
var float[] zone_weight     = array.new_float(0)
var bool[]  zone_is_resist  = array.new_bool(0)
var int[]   zone_high_count = array.new_int(0)
var int[]   zone_newest_bar = array.new_int(0)
var int[]   zone_oldest_bar = array.new_int(0)

if pool_changed and not na(atr_val) and atr_val > 0
    array.clear(zone_centroid)
    array.clear(zone_count)
    array.clear(zone_sum_rvol)
    array.clear(zone_weight)
    array.clear(zone_is_resist)
    array.clear(zone_high_count)
    array.clear(zone_newest_bar)
    array.clear(zone_oldest_bar)

    float c_thresh = atr_val * cluster_mult
    int pool_n     = array.size(pool_price)

    if pool_n > 0
        for i = 0 to pool_n - 1
            float p  = array.get(pool_price, i)
            float rv = array.get(pool_rvol, i)
            bool  ih = array.get(pool_is_high, i)
            int   pb = array.get(pool_bar, i)

            int   nearest_idx  = -1
            float nearest_dist = c_thresh
            int   nz_count     = array.size(zone_centroid)

            if nz_count > 0
                for j = 0 to nz_count - 1
                    float d = math.abs(p - array.get(zone_centroid, j))
                    if d < nearest_dist
                        nearest_dist := d
                        nearest_idx  := j

            if nearest_idx >= 0
                float old_sum  = array.get(zone_sum_rvol, nearest_idx)
                float new_sum  = old_sum + rv
                float old_cent = array.get(zone_centroid, nearest_idx)
                float new_cent = (old_cent * old_sum + p * rv) / new_sum
                int   new_cnt  = array.get(zone_count, nearest_idx) + 1
                float new_avg  = new_sum / new_cnt

                array.set(zone_centroid,  nearest_idx, new_cent)
                array.set(zone_count,     nearest_idx, new_cnt)
                array.set(zone_sum_rvol,  nearest_idx, new_sum)
                array.set(zone_weight,    nearest_idx, new_cnt * new_avg)

                int hc = array.get(zone_high_count, nearest_idx) + (ih ? 1 : 0)
                array.set(zone_high_count, nearest_idx, hc)
                array.set(zone_is_resist, nearest_idx, hc * 2 > new_cnt)

                if pb > array.get(zone_newest_bar, nearest_idx)
                    array.set(zone_newest_bar, nearest_idx, pb)
                if pb < array.get(zone_oldest_bar, nearest_idx)
                    array.set(zone_oldest_bar, nearest_idx, pb)
            else
                array.push(zone_centroid,   p)
                array.push(zone_count,      1)
                array.push(zone_sum_rvol,   rv)
                array.push(zone_weight,     rv)
                array.push(zone_is_resist,  ih)
                array.push(zone_high_count, ih ? 1 : 0)
                array.push(zone_newest_bar, pb)
                array.push(zone_oldest_bar, pb)

    pool_changed := false

// ═════════════════════════════════════════════════════════════════════════
// ─── ACTIVATION FILTER ──────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

var float[] az_centroid   = array.new_float(0)
var float[] az_weight     = array.new_float(0)
var bool[]  az_is_resist  = array.new_bool(0)
var int[]   az_newest_bar = array.new_int(0)
var int[]   az_count      = array.new_int(0)
var bool[]  az_flipped    = array.new_bool(0)

array.clear(az_centroid)
array.clear(az_weight)
array.clear(az_is_resist)
array.clear(az_newest_bar)
array.clear(az_count)
array.clear(az_flipped)

int nz_total = array.size(zone_centroid)
if nz_total > 0 and not na(atr_val) and atr_val > 0
    float act_thresh = atr_val * activation_mult

    for i = 0 to nz_total - 1
        float zc = array.get(zone_centroid, i)
        if math.abs(close - zc) <= act_thresh
            bool base_resist  = array.get(zone_is_resist, i)
            bool final_resist = base_resist
            bool flipped      = false

            if enable_sr_flip
                if zc > close and not base_resist
                    final_resist := true
                    flipped      := true
                else if zc < close and base_resist
                    final_resist := false
                    flipped      := true

            array.push(az_centroid,   zc)
            array.push(az_weight,     array.get(zone_weight, i))
            array.push(az_is_resist,  final_resist)
            array.push(az_newest_bar, array.get(zone_newest_bar, i))
            array.push(az_count,      array.get(zone_count, i))
            array.push(az_flipped,    flipped)

// ─── SORT ACTIVE ZONES BY WEIGHT (descending) & CAP ─────────────────────

int az_n = array.size(az_centroid)
if az_n > 1
    for i = 0 to az_n - 2
        int   max_idx = i
        float max_w   = array.get(az_weight, i)
        for j = i + 1 to az_n - 1
            float w = array.get(az_weight, j)
            if w > max_w
                max_w   := w
                max_idx := j
        if max_idx != i
            float tmp_f = 0.0
            int   tmp_i = 0
            bool  tmp_b = false

            tmp_f := array.get(az_centroid, i)
            array.set(az_centroid, i, array.get(az_centroid, max_idx))
            array.set(az_centroid, max_idx, tmp_f)

            tmp_f := array.get(az_weight, i)
            array.set(az_weight, i, array.get(az_weight, max_idx))
            array.set(az_weight, max_idx, tmp_f)

            tmp_b := array.get(az_is_resist, i)
            array.set(az_is_resist, i, array.get(az_is_resist, max_idx))
            array.set(az_is_resist, max_idx, tmp_b)

            tmp_i := array.get(az_newest_bar, i)
            array.set(az_newest_bar, i, array.get(az_newest_bar, max_idx))
            array.set(az_newest_bar, max_idx, tmp_i)

            tmp_i := array.get(az_count, i)
            array.set(az_count, i, array.get(az_count, max_idx))
            array.set(az_count, max_idx, tmp_i)

            tmp_b := array.get(az_flipped, i)
            array.set(az_flipped, i, array.get(az_flipped, max_idx))
            array.set(az_flipped, max_idx, tmp_b)

while array.size(az_centroid) > sr_max_lines
    array.pop(az_centroid)
    array.pop(az_weight)
    array.pop(az_is_resist)
    array.pop(az_newest_bar)
    array.pop(az_count)
    array.pop(az_flipped)

az_n := array.size(az_centroid)

// ─── FIND NEAREST ACTIVE R1/S1 & THEIR WEIGHTS ─────────────────────────

var float status_r1     = na
var float status_r2     = na
var float status_s1     = na
var float status_s2     = na
var float status_r1_wt  = na
var float status_s1_wt  = na
var int   status_r1_cnt = na
var int   status_s1_cnt = na

status_r1     := na
status_r2     := na
status_s1     := na
status_s2     := na
status_r1_wt  := na
status_s1_wt  := na
status_r1_cnt := na
status_s1_cnt := na

if az_n > 0
    float nr1 = na, float nr2 = na, float ns1 = na, float ns2 = na
    float nr1_w = na, float ns1_w = na
    int   nr1_c = na, int   ns1_c = na

    for i = 0 to az_n - 1
        float lvl = array.get(az_centroid, i)
        float wt  = array.get(az_weight, i)
        int   cnt = array.get(az_count, i)

        if lvl > close
            if na(nr1) or lvl < nr1
                nr2   := nr1
                nr1   := lvl
                nr1_w := wt
                nr1_c := cnt
            else if (na(nr2) or lvl < nr2) and lvl != nr1
                nr2 := lvl

        if lvl < close
            if na(ns1) or lvl > ns1
                ns2   := ns1
                ns1   := lvl
                ns1_w := wt
                ns1_c := cnt
            else if (na(ns2) or lvl > ns2) and lvl != ns1
                ns2 := lvl

    status_r1     := nr1
    status_r2     := nr2
    status_s1     := ns1
    status_s2     := ns2
    status_r1_wt  := nr1_w
    status_s1_wt  := ns1_w
    status_r1_cnt := nr1_c
    status_s1_cnt := ns1_c

status_r1_dist = not na(status_r1) ? status_r1 - close : na
status_s1_dist = not na(status_s1) ? close - status_s1 : na

// ═════════════════════════════════════════════════════════════════════════
// ─── REACTION STRENGTH ENGINE ───────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

float rs_nearest_level     = na
bool  rs_nearest_is_resist = na
float rs_nearest_dist      = na

if not na(status_s1_dist) and not na(status_r1_dist)
    if status_s1_dist <= status_r1_dist
        rs_nearest_level     := status_s1
        rs_nearest_is_resist := false
        rs_nearest_dist      := status_s1_dist
    else
        rs_nearest_level     := status_r1
        rs_nearest_is_resist := true
        rs_nearest_dist      := status_r1_dist
else if not na(status_s1)
    rs_nearest_level     := status_s1
    rs_nearest_is_resist := false
    rs_nearest_dist      := status_s1_dist
else if not na(status_r1)
    rs_nearest_level     := status_r1
    rs_nearest_is_resist := true
    rs_nearest_dist      := status_r1_dist

// ── Slope computation ───────────────────────────────────────────────────

float rs_raw_slope = not na(rs_nearest_level) and not na(atr_val) and atr_val > 0 ? (close - rs_nearest_level) / atr_val : na

float rs_linreg_val_0 = ta.linreg(close, rs_linreg_len, 0)
float rs_linreg_val_1 = ta.linreg(close, rs_linreg_len, 1)
float rs_linreg_raw   = rs_linreg_val_0 - rs_linreg_val_1
float rs_linreg_slope = not na(atr_val) and atr_val > 0 ? rs_linreg_raw / atr_val : na

float rs_slope = show_reaction ? (rs_slope_method == "LinReg" ? rs_linreg_slope : rs_raw_slope) : na

// ── Acceleration ────────────────────────────────────────────────────────
float rs_accel_raw = not na(rs_slope) ? rs_slope - nz(rs_slope[1]) : na
float rs_accel     = show_reaction ? (rs_accel_smooth > 1 ? ta.ema(rs_accel_raw, rs_accel_smooth) : rs_accel_raw) : na

// ── Rejection Quality (proximity-gated) ─────────────────────────────────
float rs_rejection_raw = (high - low) > 0 ? (close - low) / (high - low) : 0.5
float rs_rej_thresh    = not na(atr_val) ? atr_val * activation_mult * rs_rej_prox_mult : na
bool  rs_near_level    = not na(rs_nearest_dist) and not na(rs_rej_thresh) and rs_nearest_dist <= rs_rej_thresh
float rs_rejection     = show_reaction and rs_show_rejection and rs_near_level ? rs_rejection_raw : na

// ── Reaction Strength (slope × RVOL) ────────────────────────────────────
float rs_strength      = show_reaction and not na(rs_slope) ? rs_slope * math.max(rvol, 0.1) : na
float rs_strength_ema  = ta.ema(nz(rs_strength), rs_accel_smooth > 1 ? rs_accel_smooth : 3)
float rs_strength_plot = show_reaction ? rs_strength_ema : na

// ─── DRAW PIVOT LABELS ─────────────────────────────────────────────────

if show_labels and (not na(ph) or not na(pl))
    if is_validated or show_low_labels
        lbl_color = is_validated ? (pivot_is_high ? res_color : sup_color) : color.new(color.gray, 50)
        lbl_style = pivot_is_high ? label.style_label_down : label.style_label_up
        lbl_yloc  = pivot_is_high ? pivot_price : pivot_price
        rvol_str  = str.tostring(pivot_rvol, "#.##")
        vol_icon  = is_validated ? "✓ " : "✗ "
        lbl_text  = vol_icon + pivot_type + "\nRV:" + rvol_str

        if use_ltf and show_rej_score and not na(pivot_rej_score)
            rej_str  = str.tostring(pivot_rej_score, "#.##")
            lbl_text := lbl_text + "\nREJ:" + rej_str

        if use_ltf and not na(ph)
            raw_wick   = ph
            offset_pts = pivot_price - raw_wick
            if math.abs(offset_pts) > 0
                lbl_text := lbl_text + "\n" + (offset_pts > 0 ? "+" : "") + str.tostring(offset_pts, "#.##")
        if use_ltf and not na(pl)
            raw_wick   = pl
            offset_pts = pivot_price - raw_wick
            if math.abs(offset_pts) > 0
                lbl_text := lbl_text + "\n" + (offset_pts > 0 ? "+" : "") + str.tostring(offset_pts, "#.##")

        label.new(
             pivot_bar, lbl_yloc, lbl_text,
             style     = lbl_style,
             color     = lbl_color,
             textcolor = color.white,
             size      = label_size)

// ═════════════════════════════════════════════════════════════════════════
// ─── DRAW ACTIVE ZONE LINES ─────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

var line[]  az_lines  = array.new_line(0)
var label[] az_labels = array.new_label(0)

if array.size(az_lines) > 0
    for i = 0 to array.size(az_lines) - 1
        line.delete(array.get(az_lines, i))
    array.clear(az_lines)
if array.size(az_labels) > 0
    for i = 0 to array.size(az_labels) - 1
        label.delete(array.get(az_labels, i))
    array.clear(az_labels)

if show_sr and az_n > 0
    float max_az_wt = 0.0
    for i = 0 to az_n - 1
        float w = array.get(az_weight, i)
        if w > max_az_wt
            max_az_wt := w

    for i = 0 to az_n - 1
        float lvl  = array.get(az_centroid, i)
        bool  is_res = array.get(az_is_resist, i)
        int   nb   = array.get(az_newest_bar, i)
        float wt   = array.get(az_weight, i)
        int   cnt  = array.get(az_count, i)
        bool  flip = array.get(az_flipped, i)

        float wt_ratio = max_az_wt > 0 ? wt / max_az_wt : 1.0
        int   lw       = math.max(1, math.round(wt_ratio * sr_line_width))

        line_col = is_res ? res_color : sup_color
        ext      = sr_extend ? extend.right : extend.none
        l_style  = flip ? line.style_dashed : sr_line_style

        new_line = line.new(
             nb, lvl, bar_index, lvl,
             color = line_col,
             width = lw,
             style = l_style,
             extend = ext)
        array.push(az_lines, new_line)

        if show_zone_wt
            string wt_txt = str.tostring(cnt) + "× W:" + str.tostring(wt, "#.#")
            color  wt_col = is_res ? res_color : sup_color
            label  wl     = label.new(bar_index + 2, lvl, wt_txt,
                 style     = is_res ? label.style_label_down : label.style_label_up,
                 color     = color.new(wt_col, 50),
                 textcolor = color.white,
                 size      = size.tiny)
            array.push(az_labels, wl)

// ─── PIVOT-ANCHORED VWAP ────────────────────────────────────────────────

var float cum_vol_price   = 0.0
var float cum_vol         = 0.0
var int   vwap_anchor_bar = na

if is_validated
    cum_vol_price   := 0.0
    cum_vol         := 0.0
    vwap_anchor_bar := pivot_bar

hlc3_val       = hlc3
cum_vol_price += hlc3_val * volume
cum_vol       += volume
vwap_val       = cum_vol > 0 ? cum_vol_price / cum_vol : hlc3_val

vwap_rising  = vwap_val > nz(vwap_val[1])
vwap_falling = vwap_val < nz(vwap_val[1])
vwap_color   = vwap_rising ? vwap_bull_col : vwap_falling ? vwap_bear_col : vwap_neut_col

plot(show_vwap ? vwap_val : na, "Pivot-Anchored VWAP", color=vwap_color, linewidth=vwap_width)

// ─── STATUS LINE / DATA EXPORT ──────────────────────────────────────────

status_bias = structure_bias == "bullish" ? 1.0 : structure_bias == "bearish" ? -1.0 : 0.0

disp = display.status_line + display.data_window

plot(show_status ? status_r1      : na, "L1 Above (Nearest)", display=disp, color=res_color)
plot(show_status ? status_r2      : na, "L2 Above (2nd)",     display=disp, color=res_color)
plot(show_status ? status_s1      : na, "L1 Below (Nearest)", display=disp, color=sup_color)
plot(show_status ? status_s2      : na, "L2 Below (2nd)",     display=disp, color=sup_color)
plot(show_status ? status_r1_dist : na, "L1 Above Distance",  display=disp, color=color.gray)
plot(show_status ? status_s1_dist : na, "L1 Below Distance",  display=disp, color=color.gray)
plot(show_status ? vwap_val       : na, "VWAP (Export)",       display=disp, color=color.gray)
plot(show_status ? rvol           : na, "RVOL (Export)",       display=disp, color=color.gray)
plot(show_status ? status_bias    : na, "Bias (+1/0/-1)",      display=disp, color=color.gray)

plot(show_status ? nz(status_r1_wt, 0)        : na, "R1 Zone Weight",  display=disp, color=color.gray)
plot(show_status ? nz(status_s1_wt, 0)        : na, "S1 Zone Weight",  display=disp, color=color.gray)
plot(show_status ? nz(status_r1_cnt, 0) * 1.0 : na, "R1 Touch Count",  display=disp, color=color.gray)
plot(show_status ? nz(status_s1_cnt, 0) * 1.0 : na, "S1 Touch Count",  display=disp, color=color.gray)
plot(show_status ? array.size(pool_price) * 1.0 : na, "Pool Size",     display=disp, color=color.gray)
plot(show_status ? nz_total * 1.0               : na, "Total Zones",   display=disp, color=color.gray)
plot(show_status ? az_n * 1.0                   : na, "Active Zones",  display=disp, color=color.gray)

plot(show_status and use_ltf ? ltf_micro_vwap    : na, "LTF Micro-VWAP",       display=disp, color=color.gray)
plot(show_status and use_ltf ? ltf_rej_at_high   : na, "LTF Rej. Sharpness H", display=disp, color=color.gray)
plot(show_status and use_ltf ? ltf_rej_at_low    : na, "LTF Rej. Sharpness L", display=disp, color=color.gray)
plot(show_status and use_ltf ? ltf_vol_ratio_top : na, "LTF Vol% Top 30%",     display=disp, color=color.gray)
plot(show_status and use_ltf ? ltf_vol_ratio_bot : na, "LTF Vol% Bot 30%",     display=disp, color=color.gray)
plot(show_status ? atr_val                       : na, "ATR Value",             display=disp, color=color.gray)
plot(show_status ? bars_since_pivot * 1.0        : na, "Bars Since Pivot",      display=disp, color=color.gray)

plot(show_status and show_reaction ? rs_slope          : na, "RS Slope",             display=disp, color=color.gray)
plot(show_status and show_reaction ? rs_accel          : na, "RS Acceleration",      display=disp, color=color.gray)
plot(show_status and show_reaction ? rs_rejection      : na, "RS Rejection Quality", display=disp, color=color.gray)
plot(show_status and show_reaction ? rs_strength_plot  : na, "RS Strength (EMA)",    display=disp, color=color.gray)
plot(show_status and show_reaction ? rs_nearest_level  : na, "RS Governing Level",   display=disp, color=color.gray)

// ═════════════════════════════════════════════════════════════════════════
// ─── PER-BAR VOLUME DENSITY ─────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

f_density_pair(_level, _lookback, _num_bins, _radius, _decay) =>
    float d_above = na
    float d_below = na
    if not na(_level) and _radius > 0
        float zone_bot = _level - _radius
        float bin_size = (_radius * 2.0) / _num_bins
        if bin_size > 0
            float max_v = 0.0
            float[] bins = array.new_float(_num_bins, 0.0)
            for lb = 0 to _lookback - 1
                float h_ = high[lb]
                float l_ = low[lb]
                float v_ = volume[lb]
                if not na(h_) and not na(l_) and not na(v_) and v_ > 0
                    float w   = math.pow(_decay, lb)
                    float wv  = v_ * w
                    int   lo_b = math.max(0, math.floor((l_ - zone_bot) / bin_size))
                    int   hi_b = math.min(_num_bins - 1, math.floor((h_ - zone_bot) / bin_size))
                    if lo_b < _num_bins and hi_b >= 0 and lo_b <= hi_b
                        int   span = hi_b - lo_b + 1
                        float vpb  = wv / span
                        for b = lo_b to hi_b
                            array.set(bins, b, array.get(bins, b) + vpb)
            max_v := array.max(bins)
            if max_v > 0
                int   mid_b = math.floor((_level - zone_bot) / bin_size)
                float s_a   = 0.0, float s_b_ = 0.0
                int   c_a   = 0,   int   c_b_ = 0
                for i = 0 to _num_bins - 1
                    float norm = array.get(bins, i) / max_v
                    if i > mid_b
                        s_a  += norm, c_a  += 1
                    else if i < mid_b
                        s_b_ += norm, c_b_ += 1
                d_above := c_a  > 0 ? s_a  / c_a  : na
                d_below := c_b_ > 0 ? s_b_ / c_b_ : na
    [d_above, d_below]

float vg_radius_bar = atr_val * vg_radius_mult

[bar_r1_da, bar_r1_db] = f_density_pair(status_r1, vg_lookback, vg_bins, vg_radius_bar, vg_decay_factor)
[bar_s1_da, bar_s1_db] = f_density_pair(status_s1, vg_lookback, vg_bins, vg_radius_bar, vg_decay_factor)

// ═════════════════════════════════════════════════════════════════════════
// ─── FVG DETECTION & ZONE DRAWING ───────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

bull_fvg_gap = low - high[2]
has_bull_fvg = bull_fvg_gap > 0

bear_fvg_gap = low[2] - high
has_bear_fvg = bear_fvg_gap > 0

fvg_size = has_bull_fvg ? bull_fvg_gap : has_bear_fvg ? bear_fvg_gap : na

var float[] fvg_sizes = array.new_float(0)
var float   fvg_p75   = 0.0

if not na(fvg_size)
    array.push(fvg_sizes, fvg_size)
    if array.size(fvg_sizes) > fvg_size_lookback
        array.shift(fvg_sizes)
    if array.size(fvg_sizes) >= 10
        sorted = array.copy(fvg_sizes)
        array.sort(sorted, order.ascending)
        int p75_idx = math.floor(array.size(sorted) * 0.75)
        fvg_p75    := array.get(sorted, math.min(p75_idx, array.size(sorted) - 1))

is_large_bull_fvg = has_bull_fvg and bull_fvg_gap >= fvg_p75 and fvg_p75 > 0
is_large_bear_fvg = has_bear_fvg and bear_fvg_gap >= fvg_p75 and fvg_p75 > 0

if show_fvg_zones
    if is_large_bull_fvg
        box.new(bar_index - 2, low, bar_index, high[2],
             bgcolor      = fvg_bull_zone,
             border_color = color.new(#22c55e, 0),
             border_width = 1)

    if is_large_bear_fvg
        box.new(bar_index - 2, low[2], bar_index, high,
             bgcolor      = fvg_bear_zone,
             border_color = color.new(#ef4444, 0),
             border_width = 1)

// ═════════════════════════════════════════════════════════════════════════
// ─── COMPREHENSIVE GRADIENT SCORE (per-bar) ─────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

// ── Component 1: Density asymmetry ──────────────────────────────────────
float bar_gradient_bias = na

if not na(bar_r1_da) and not na(bar_r1_db) and not na(bar_s1_da) and not na(bar_s1_db)
    bar_gradient_bias := bar_s1_db - bar_r1_da
else if not na(bar_s1_da) and not na(bar_s1_db)
    bar_gradient_bias := bar_s1_db - bar_s1_da
else if not na(bar_r1_da) and not na(bar_r1_db)
    bar_gradient_bias := bar_r1_db - bar_r1_da

float cgs_c_density = math.max(-1.0, math.min(1.0, nz(bar_gradient_bias)))

// ── Component 2: Slope ──────────────────────────────────────────────────
float cgs_c_slope = math.max(-1.0, math.min(1.0, nz(rs_slope)))

// ── Component 3: Acceleration ───────────────────────────────────────────
float cgs_c_accel = math.max(-1.0, math.min(1.0, nz(rs_accel) * cgs_accel_scale))

// ── Component 4: Rejection quality ──────────────────────────────────────
float cgs_c_rej = not na(rs_rejection) ? (rs_rejection - 0.5) * 2.0 : 0.0

// ── Weighted blend ──────────────────────────────────────────────────────
float cgs_sum_w = cgs_w_density + cgs_w_slope + cgs_w_accel + cgs_w_rej
float cgs_raw   = cgs_sum_w > 0 ? (cgs_w_density * cgs_c_density + cgs_w_slope * cgs_c_slope + cgs_w_accel * cgs_c_accel + cgs_w_rej * cgs_c_rej) / cgs_sum_w : 0.0

float cgs_smoothed = gb_smooth_len > 1 ? ta.sma(cgs_raw, gb_smooth_len) : cgs_raw

float gb_smoothed = gb_smooth_len > 1 ? ta.sma(bar_gradient_bias, gb_smooth_len) : bar_gradient_bias

// ═════════════════════════════════════════════════════════════════════════
// ─── VOLUME GRADIENT ENGINE (visual boxes — last bar only) ──────────────
// ═════════════════════════════════════════════════════════════════════════

var box[]   vg_boxes  = array.new_box(0)
var label[] vg_labels = array.new_label(0)

var float vg_r1_density_above = na
var float vg_r1_density_below = na
var float vg_s1_density_above = na
var float vg_s1_density_below = na

if barstate.islast and show_vol_gradient
    if array.size(vg_boxes) > 0
        for i = 0 to array.size(vg_boxes) - 1
            box.delete(array.get(vg_boxes, i))
        array.clear(vg_boxes)

    if array.size(vg_labels) > 0
        for i = 0 to array.size(vg_labels) - 1
            label.delete(array.get(vg_labels, i))
        array.clear(vg_labels)

    float vg_radius = atr_val * vg_radius_mult
    int   x_left   = bar_index - vg_display_bars
    int   x_right  = bar_index + vg_right_ext

    // L1 ABOVE (nearest resistance zone)
    if not na(status_r1) and vg_radius > 0
        float r_zone_bot = status_r1 - vg_radius
        float r_bin_size = (vg_radius * 2.0) / vg_bins

        if r_bin_size > 0
            float[] r_bins = array.new_float(vg_bins, 0.0)
            for lb = 0 to vg_lookback - 1
                float h = high[lb]
                float l = low[lb]
                float v = volume[lb]
                if not na(h) and not na(l) and not na(v) and v > 0
                    float w      = math.pow(vg_decay_factor, lb)
                    float wv     = v * w
                    int   lo_bin = math.max(0, math.floor((l - r_zone_bot) / r_bin_size))
                    int   hi_bin = math.min(vg_bins - 1, math.floor((h - r_zone_bot) / r_bin_size))
                    if lo_bin < vg_bins and hi_bin >= 0 and lo_bin <= hi_bin
                        int   span = hi_bin - lo_bin + 1
                        float vpb  = wv / span
                        for b = lo_bin to hi_bin
                            array.set(r_bins, b, array.get(r_bins, b) + vpb)

            float r_max_vol = array.max(r_bins)
            if r_max_vol > 0
                int   r_mid_bin  = math.floor((status_r1 - r_zone_bot) / r_bin_size)
                float sum_above  = 0.0
                float sum_below  = 0.0
                int   cnt_above  = 0
                int   cnt_below  = 0

                for i = 0 to vg_bins - 1
                    float norm = array.get(r_bins, i) / r_max_vol
                    int   t    = math.round(vg_max_transp - norm * (vg_max_transp - vg_min_transp))
                    float bbot = r_zone_bot + i * r_bin_size
                    float btop = bbot + r_bin_size

                    box b = box.new(x_left, btop, x_right, bbot,
                         bgcolor      = color.new(vg_res_color, t),
                         border_color = color.new(color.gray, 96),
                         border_width = 0)
                    array.push(vg_boxes, b)

                    if i > r_mid_bin
                        sum_above += norm
                        cnt_above += 1
                    else if i < r_mid_bin
                        sum_below += norm
                        cnt_below += 1

                vg_r1_density_above := cnt_above > 0 ? sum_above / cnt_above : na
                vg_r1_density_below := cnt_below > 0 ? sum_below / cnt_below : na

                string r_lbl = "▲" + str.tostring(nz(vg_r1_density_above, 0), "#.##") + " ▼" + str.tostring(nz(vg_r1_density_below, 0), "#.##")
                label rl = label.new(x_right + 1, status_r1, r_lbl,
                     style     = label.style_label_left,
                     color     = color.new(vg_res_color, 60),
                     textcolor = color.white,
                     size      = size.tiny)
                array.push(vg_labels, rl)

    // L1 BELOW (nearest support zone)
    if not na(status_s1) and vg_radius > 0
        float s_zone_bot = status_s1 - vg_radius
        float s_bin_size = (vg_radius * 2.0) / vg_bins

        if s_bin_size > 0
            float[] s_bins = array.new_float(vg_bins, 0.0)
            for lb = 0 to vg_lookback - 1
                float h = high[lb]
                float l = low[lb]
                float v = volume[lb]
                if not na(h) and not na(l) and not na(v) and v > 0
                    float w      = math.pow(vg_decay_factor, lb)
                    float wv     = v * w
                    int   lo_bin = math.max(0, math.floor((l - s_zone_bot) / s_bin_size))
                    int   hi_bin = math.min(vg_bins - 1, math.floor((h - s_zone_bot) / s_bin_size))
                    if lo_bin < vg_bins and hi_bin >= 0 and lo_bin <= hi_bin
                        int   span = hi_bin - lo_bin + 1
                        float vpb  = wv / span
                        for b = lo_bin to hi_bin
                            array.set(s_bins, b, array.get(s_bins, b) + vpb)

            float s_max_vol = array.max(s_bins)
            if s_max_vol > 0
                int   s_mid_bin  = math.floor((status_s1 - s_zone_bot) / s_bin_size)
                float sum_above  = 0.0
                float sum_below  = 0.0
                int   cnt_above  = 0
                int   cnt_below  = 0

                for i = 0 to vg_bins - 1
                    float norm = array.get(s_bins, i) / s_max_vol
                    int   t    = math.round(vg_max_transp - norm * (vg_max_transp - vg_min_transp))
                    float bbot = s_zone_bot + i * s_bin_size
                    float btop = bbot + s_bin_size

                    box b = box.new(x_left, btop, x_right, bbot,
                         bgcolor      = color.new(vg_sup_color, t),
                         border_color = color.new(color.gray, 96),
                         border_width = 0)
                    array.push(vg_boxes, b)

                    if i > s_mid_bin
                        sum_above += norm
                        cnt_above += 1
                    else if i < s_mid_bin
                        sum_below += norm
                        cnt_below += 1

                vg_s1_density_above := cnt_above > 0 ? sum_above / cnt_above : na
                vg_s1_density_below := cnt_below > 0 ? sum_below / cnt_below : na

                string s_lbl = "▲" + str.tostring(nz(vg_s1_density_above, 0), "#.##") + " ▼" + str.tostring(nz(vg_s1_density_below, 0), "#.##")
                label sl = label.new(x_right + 1, status_s1, s_lbl,
                     style     = label.style_label_left,
                     color     = color.new(vg_sup_color, 60),
                     textcolor = color.white,
                     size      = size.tiny)
                array.push(vg_labels, sl)

// ─── GRADIENT BIAS ──────────────────────────────────────────────────────
var float gradient_bias = na
bool has_r1_grad = not na(vg_r1_density_above) and not na(vg_r1_density_below)
bool has_s1_grad = not na(vg_s1_density_above) and not na(vg_s1_density_below)

if has_r1_grad and has_s1_grad
    gradient_bias := vg_s1_density_below - vg_r1_density_above
else if has_s1_grad
    gradient_bias := vg_s1_density_below - vg_s1_density_above
else if has_r1_grad
    gradient_bias := vg_r1_density_below - vg_r1_density_above
else
    gradient_bias := na

// ─── GRADIENT & CGS DATA EXPORT ─────────────────────────────────────────

plot(show_status and show_vol_gradient ? vg_r1_density_above : na, "VG R1 Density Above", display=disp, color=color.gray)
plot(show_status and show_vol_gradient ? vg_r1_density_below : na, "VG R1 Density Below", display=disp, color=color.gray)
plot(show_status and show_vol_gradient ? vg_s1_density_above : na, "VG S1 Density Above", display=disp, color=color.gray)
plot(show_status and show_vol_gradient ? vg_s1_density_below : na, "VG S1 Density Below", display=disp, color=color.gray)
plot(show_status and show_vol_gradient ? gradient_bias        : na, "Density Bias (Raw)",  display=disp, color=color.gray)
plot(show_status and show_vol_gradient ? cgs_smoothed         : na, "CGS (Comprehensive)", display=disp, color=color.gray)

// ─── BAR COLORING (driven by Comprehensive Gradient Score) ──────────────

gb_bar_color = not na(cgs_smoothed) and show_bias_bars ?
     (cgs_smoothed >  gb_neut_thresh ? gb_bull_bar_col :
      cgs_smoothed < -gb_neut_thresh ? gb_bear_bar_col :
      gb_neut_bar_col) : na

barcolor(show_vol_gradient ? gb_bar_color : na)

// ═════════════════════════════════════════════════════════════════════════
// ─── INFO TABLE ─────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════

var table info_tbl = table.new(position.top_right, 2, 6, bgcolor=color.new(#1e1e1e, 10), border_color=color.new(color.gray, 60), border_width=1)

if barstate.islast
    // Row 0: Current RVOL
    table.cell(info_tbl, 0, 0, "Current RVOL", text_color=color.gray, text_size=size.tiny)
    rvol_color = rvol >= rvol_threshold ? color.lime : color.orange
    table.cell(info_tbl, 1, 0, str.tostring(rvol, "#.##"), text_color=rvol_color, text_size=size.tiny)

    // Row 1: R1 Zone
    table.cell(info_tbl, 0, 1, "R1 Zone", text_color=color.gray, text_size=size.tiny)
    if not na(status_r1)
        string r1_info = str.tostring(status_r1, "#.##") + " (" + str.tostring(nz(status_r1_cnt, 0)) + "× W:" + str.tostring(nz(status_r1_wt, 0), "#.#") + ")"
        table.cell(info_tbl, 1, 1, r1_info, text_color=res_color, text_size=size.tiny)
    else
        table.cell(info_tbl, 1, 1, "—", text_color=color.gray, text_size=size.tiny)

    // Row 2: S1 Zone
    table.cell(info_tbl, 0, 2, "S1 Zone", text_color=color.gray, text_size=size.tiny)
    if not na(status_s1)
        string s1_info = str.tostring(status_s1, "#.##") + " (" + str.tostring(nz(status_s1_cnt, 0)) + "× W:" + str.tostring(nz(status_s1_wt, 0), "#.#") + ")"
        table.cell(info_tbl, 1, 2, s1_info, text_color=sup_color, text_size=size.tiny)
    else
        table.cell(info_tbl, 1, 2, "—", text_color=color.gray, text_size=size.tiny)

    // Row 3: Structure Bias
    table.cell(info_tbl, 0, 3, "Structure", text_color=color.gray, text_size=size.tiny)
    bias_col = switch structure_bias
        "bullish" => color.lime
        "bearish" => color.red
        => color.gray
    struct_suffix = ""
    if bars_since_pivot > struct_stale_bars
        struct_suffix := " (stale)"
    else if struct_price_override and structure_bias == "neutral"
        string raw_bias = f_calc_structure_bias(struct_prev_ph, struct_last_ph, struct_prev_pl, struct_last_pl)
        if raw_bias != "neutral"
            struct_suffix := " (override)"
    table.cell(info_tbl, 1, 3, str.upper(structure_bias) + struct_suffix, text_color=bias_col, text_size=size.tiny)

    // Row 4: Density Bias
    table.cell(info_tbl, 0, 4, "Density Bias", text_color=color.gray, text_size=size.tiny)
    if not na(gradient_bias)
        string gb_label = math.abs(gradient_bias) < 0.10 ? "NEUTRAL" : gradient_bias > 0 ? "BULLISH" : "BEARISH"
        string gb_score = (gradient_bias > 0 ? "+" : "") + str.tostring(gradient_bias, "#.##")
        color  gb_col   = math.abs(gradient_bias) < 0.10 ? color.gray : gradient_bias > 0 ? color.lime : color.red
        table.cell(info_tbl, 1, 4, gb_label + " (" + gb_score + ")", text_color=gb_col, text_size=size.tiny)
    else
        table.cell(info_tbl, 1, 4, "—", text_color=color.gray, text_size=size.tiny)

    // Row 5: CGS Score
    table.cell(info_tbl, 0, 5, "CGS Score", text_color=color.gray, text_size=size.tiny)
    if not na(cgs_smoothed)
        string cgs_label = math.abs(cgs_smoothed) < gb_neut_thresh ? "NEUTRAL" : cgs_smoothed > 0 ? "BULLISH" : "BEARISH"
        string cgs_str   = (cgs_smoothed > 0 ? "+" : "") + str.tostring(cgs_smoothed, "#.###")
        color  cgs_col   = math.abs(cgs_smoothed) < gb_neut_thresh ? color.gray : cgs_smoothed > 0 ? color.lime : color.red
        table.cell(info_tbl, 1, 5, cgs_label + " (" + cgs_str + ")", text_color=cgs_col, text_size=size.tiny)
    else
        table.cell(info_tbl, 1, 5, "—", text_color=color.gray, text_size=size.tiny)

// ─── ALERTS ─────────────────────────────────────────────────────────────

alertcondition(is_validated and pivot_is_high and pivot_type == "HH", "Volume-Validated HH", "HH pivot confirmed with RVOL ≥ threshold")
alertcondition(is_validated and not pivot_is_high and pivot_type == "HL", "Volume-Validated HL", "HL pivot confirmed with RVOL ≥ threshold")
alertcondition(is_validated and pivot_is_high and pivot_type == "LH", "Volume-Validated LH", "LH pivot confirmed with RVOL ≥ threshold")
alertcondition(is_validated and not pivot_is_high and pivot_type == "LL", "Volume-Validated LL", "LL pivot confirmed with RVOL ≥ threshold")
alertcondition(is_validated, "Any Volume-Validated Pivot", "Pivot confirmed with RVOL ≥ threshold")
````

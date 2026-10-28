# XAUUSD Zone Sniper v1

- url: https://www.tradingview.com/script/70dnQZ1K/
- type: indicator
- pine_id: PUB;fc2a13e8bfc246ef86a9649888e5c190
- version: 1.0

## Description

XAUUSD Zone Sniper is an intraday liquidity-based indicator built for gold traders who want a more structured way to read sweep-and-reversal conditions on lower timeframes. The script is designed for XAUUSD and overlays the chart with key liquidity levels, displacement events, and actionable reaction zones derived from post-sweep price behavior.

The indicator uses a multi-factor workflow instead of a single trigger. First, it builds a directional bias using a combination of EMA alignment, EMA slope, and recent swing structure. It then tracks key reference levels such as Asia session high/low, previous day high/low, recent swing liquidity, and nearby round numbers. When price wicks through one of those levels and closes back inside, the event is treated as a potential liquidity sweep.

After a sweep, the script looks for displacement. In this context, displacement is defined as a strong impulsive candle with a minimum body-to-range ratio and a minimum expansion versus ATR. If displacement occurs within a short window after the sweep, the script can mark a potential reaction area using either a Fair Value Gap, an Order Block, or both, depending on the selected settings.

Each zone is then scored using several contextual factors. The score can include liquidity quality, displacement, inefficiency, session timing, higher-timeframe bias alignment, and retest confirmation, while poor context such as dead-session conditions can reduce quality. This allows the indicator to separate weaker candidates from stronger A and A+ setups instead of plotting every possible zone equally.

The script also includes a zone state model. A newly created zone starts as a candidate, can later become armed after a valid retest, and is eventually marked as mitigated or no longer relevant if price trades too deeply into it, closes beyond it, or enough bars pass without confirmation. This helps reduce chart clutter and keeps the focus on fresh areas.

What you see on the chart:
- EMA fast, EMA slow, and HTF EMA for bias context
- Asia high/low, previous day high/low, and nearby round numbers
- Sweep markers when liquidity is taken above or below key levels
- Displacement arrows after valid sweep reactions
- Bullish and bearish zones drawn as boxes
- Optional score labels showing setup quality and class

Suggested use:
- Best suited to XAUUSD intraday charts
- Typically most relevant on lower timeframes such as M1 to M15
- Can be used to frame reaction trades after a liquidity event rather than to predict price in advance
- Stronger signals generally occur when a sweep, displacement, session timing, and directional bias align together

Important notes:
- This script is a decision-support tool, not a fully autonomous trading system
- Zones are context-dependent and should be evaluated together with execution, risk management, and nearby targets/liquidity
- Session filters and scoring thresholds can materially change how selective the script becomes
- The default settings are optimized for a liquidity/reaction style workflow on gold, but users may still need to tune them to their broker feed and timeframe

Main inputs:
- HTF Bias: EMA fast/slow/HTF, structure lookback, slope length
- Key Levels: Asia range, previous day high/low, round number logic, swing lookback
- Sweep Detection: tolerance and wick quality filters
- Displacement: body/range threshold, ATR expansion, ATR length
- Zone Logic: FVG / OB / Both
- Scoring: minimum score to draw, alert thresholds, class thresholds, factor weights
- Zone Management: max active zones, expiry bars, mitigation depth, minimum R:R filter
- Alerts: armed bull/bear zones, sweeps, and displacement events

This indicator is for educational and analytical purposes only. It does not guarantee future performance, and all trading decisions remain the responsibility of the user.

## Source Code

````pine
//@version=5
indicator("XAUUSD Zone Sniper v1", shorttitle="XAU-SNIPER", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ============================================================
// INPUTS
// ============================================================

var string G_BIAS    = "HTF Bias"
var string G_LEVELS  = "Key Levels"
var string G_SWEEP   = "Sweep Detection"
var string G_DISP    = "Displacement"
var string G_ZONE    = "Zone (FVG / OB)"
var string G_SCORE   = "Scoring"
var string G_MGMT    = "Zone Management"
var string G_ALERT   = "Alerts"
var string G_VIS     = "Visual"

// --- Bias
i_ema_fast    = input.int(21,    "EMA Fast",               group=G_BIAS)
i_ema_slow    = input.int(50,    "EMA Slow",               group=G_BIAS)
i_ema_htf     = input.int(200,   "EMA HTF",                group=G_BIAS)
i_struct_lb   = input.int(8,     "Structure Lookback",     group=G_BIAS, minval=3, maxval=30)
i_slope_len   = input.int(5,     "EMA Slope Length",       group=G_BIAS, minval=2, maxval=20)

// --- Levels
i_asia_start  = input.int(0,     "Asia Start UTC",         group=G_LEVELS, minval=0, maxval=23)
i_asia_end    = input.int(7,     "Asia End UTC",           group=G_LEVELS, minval=0, maxval=23)
i_show_asia   = input.bool(true, "Show Asia H/L",          group=G_LEVELS)
i_show_pdhl   = input.bool(true, "Show PDH / PDL",         group=G_LEVELS)
i_show_round  = input.bool(true, "Show Round Numbers",     group=G_LEVELS)
i_round_step  = input.float(50.0,"Round Number Step",      group=G_LEVELS, minval=10.0, maxval=100.0, step=10.0)
i_swing_lb    = input.int(5,     "Swing Lookback",         group=G_LEVELS, minval=2, maxval=15)

// --- Sweep
i_sweep_tol   = input.float(0.15,"Sweep Tolerance %",     group=G_SWEEP, minval=0.01, maxval=1.0, step=0.01)
i_sweep_wick  = input.float(0.6, "Min Wick Ratio",         group=G_SWEEP, minval=0.3, maxval=0.9, step=0.05)

// --- Displacement
i_disp_body   = input.float(0.65,"Min Body/Range Ratio",  group=G_DISP, minval=0.4, maxval=0.9, step=0.05)
i_disp_atr    = input.float(1.2, "Min Range vs ATR",       group=G_DISP, minval=0.5, maxval=3.0, step=0.1)
i_atr_len     = input.int(14,    "ATR Length",             group=G_DISP)

// --- Zone
i_fvg_min     = input.float(0.08,"FVG Min Size % price",  group=G_ZONE, minval=0.01, maxval=0.5, step=0.01)
i_ob_lookback = input.int(3,     "OB Lookback Bars",       group=G_ZONE, minval=1, maxval=10)
i_zone_type   = input.string("Both", "Zone Type", options=["FVG", "OB", "Both"], group=G_ZONE)

// --- Scoring
i_score_min   = input.int(4,     "Min Score to Draw",      group=G_SCORE, minval=1, maxval=8)
i_score_alert = input.int(6,     "Min Score for Alert (A)",group=G_SCORE, minval=3, maxval=10)
i_score_top   = input.int(7,     "Score for A+ Class",     group=G_SCORE, minval=4, maxval=12)
i_w_liq       = input.int(2,     "Weight: Liquidity (L)",  group=G_SCORE, minval=0, maxval=3)
i_w_disp      = input.int(2,     "Weight: Displacement (D)",group=G_SCORE, minval=0, maxval=3)
i_w_ineff     = input.int(1,     "Weight: Inefficiency (I)",group=G_SCORE, minval=0, maxval=3)
i_w_sess      = input.int(1,     "Weight: Session (S)",    group=G_SCORE, minval=0, maxval=3)
i_w_bias      = input.int(1,     "Weight: HTF Bias (B)",   group=G_SCORE, minval=0, maxval=3)
i_w_conf      = input.int(2,     "Weight: Retest Conf (C)",group=G_SCORE, minval=0, maxval=3)
i_p_mitig     = input.int(2,     "Penalty: Mitigation (M)",group=G_SCORE, minval=0, maxval=3)
i_p_noise     = input.int(1,     "Penalty: Noise/Mid (N)", group=G_SCORE, minval=0, maxval=3)
i_p_risk      = input.int(1,     "Penalty: Poor R:R (R)",  group=G_SCORE, minval=0, maxval=3)

// --- Management
i_max_zones   = input.int(8,     "Max Active Zones",       group=G_MGMT, minval=2, maxval=20)
i_expiry      = input.int(80,    "Zone Expiry Bars",       group=G_MGMT, minval=20, maxval=300)
i_mitig_pct   = input.float(50.0,"Mitigation % into zone",group=G_MGMT, minval=20.0, maxval=100.0, step=5.0)
i_min_rr      = input.float(1.8, "Min R:R to Next Level",  group=G_MGMT, minval=1.0, maxval=5.0, step=0.1)

// --- Alert
i_alert_armed = input.bool(true, "Alert on Armed A/A+",    group=G_ALERT)

// --- Visual
i_col_bull_c  = input.color(color.new(#00BCD4, 75), "Bull Candidate",  group=G_VIS)
i_col_bull_a  = input.color(color.new(#00E676, 55), "Bull Armed",      group=G_VIS)
i_col_bear_c  = input.color(color.new(#E040FB, 75), "Bear Candidate",  group=G_VIS)
i_col_bear_a  = input.color(color.new(#FF1744, 55), "Bear Armed",      group=G_VIS)
i_col_mitig   = input.color(color.new(#607D8B, 90), "Mitigated",       group=G_VIS)
i_show_scores = input.bool(true, "Show Score Labels",      group=G_VIS)
i_show_levels = input.bool(true, "Show Key Levels",        group=G_VIS)

// ============================================================
// CORE CALCULATIONS
// ============================================================

atr = ta.atr(i_atr_len)

// --- EMAs
ema_fast = ta.ema(close, i_ema_fast)
ema_slow = ta.ema(close, i_ema_slow)
ema_htf  = ta.ema(close, i_ema_htf)

// --- EMA Slope (normalized)
slope_fast = (ema_fast - ema_fast[i_slope_len]) / (atr * i_slope_len) * 100
slope_slow = (ema_slow - ema_slow[i_slope_len]) / (atr * i_slope_len) * 100

// --- Structure: HH/HL vs LH/LL
ph = ta.pivothigh(high, i_struct_lb, i_struct_lb)
pl = ta.pivotlow(low, i_struct_lb, i_struct_lb)

var float last_ph1 = na
var float last_ph2 = na
var float last_pl1 = na
var float last_pl2 = na

if not na(ph)
    last_ph2 := last_ph1
    last_ph1 := ph

if not na(pl)
    last_pl2 := last_pl1
    last_pl1 := pl

hh_hl = not na(last_ph1) and not na(last_ph2) and not na(last_pl1) and not na(last_pl2) and last_ph1 > last_ph2 and last_pl1 > last_pl2
lh_ll = not na(last_ph1) and not na(last_ph2) and not na(last_pl1) and not na(last_pl2) and last_ph1 < last_ph2 and last_pl1 < last_pl2

// --- HTF Bias Composite
bias_bull = (ema_fast > ema_slow and ema_slow > ema_htf and slope_fast > 0) or (hh_hl and close > ema_htf)
bias_bear = (ema_fast < ema_slow and ema_slow < ema_htf and slope_fast < 0) or (lh_ll and close < ema_htf)

plot(ema_fast, "EMA Fast", color=color.new(#29B6F6, 40), linewidth=1)
plot(ema_slow, "EMA Slow", color=color.new(#FFA726, 40), linewidth=1)
plot(ema_htf,  "EMA HTF",  color=color.new(#EF5350, 40), linewidth=2)

// ============================================================
// KEY LEVELS: ASIA H/L, PDH/PDL, SWINGS, ROUND NUMBERS
// ============================================================

utc_h = hour(time, "UTC")

// --- Asia High/Low
var float asia_hi = na
var float asia_lo = na
var float asia_hi_confirmed = na
var float asia_lo_confirmed = na
var bool  in_asia = false

new_asia = utc_h >= i_asia_start and utc_h < i_asia_end
was_asia = utc_h[1] >= i_asia_start and utc_h[1] < i_asia_end

if new_asia and not was_asia
    asia_hi := high
    asia_lo := low
    in_asia := true

if new_asia
    asia_hi := math.max(asia_hi, high)
    asia_lo := math.min(asia_lo, low)

if not new_asia and was_asia
    asia_hi_confirmed := asia_hi
    asia_lo_confirmed := asia_lo
    in_asia := false

// --- Previous Day High/Low
var float pdh = na
var float pdl = na
var float today_hi = na
var float today_lo = na
var int   prev_day = -1

curr_day = dayofweek(time, "UTC")
if curr_day != prev_day
    pdh := today_hi
    pdl := today_lo
    today_hi := high
    today_lo := low
    prev_day := curr_day
else
    today_hi := math.max(nz(today_hi, high), high)
    today_lo := math.min(nz(today_lo, low), low)

// --- Swing Levels (recent pivots for external liquidity)
swing_hi = ta.pivothigh(high, i_swing_lb, i_swing_lb)
swing_lo = ta.pivotlow(low, i_swing_lb, i_swing_lb)

var float sw_hi_1 = na
var float sw_lo_1 = na

if not na(swing_hi)
    sw_hi_1 := swing_hi
if not na(swing_lo)
    sw_lo_1 := swing_lo

// --- Round Numbers
round_above = math.ceil(close / i_round_step) * i_round_step
round_below = math.floor(close / i_round_step) * i_round_step

// --- Draw levels on last bar
var line ln_asia_hi = na
var line ln_asia_lo = na
var line ln_pdh = na
var line ln_pdl = na
var line ln_round_a = na
var line ln_round_b = na

if i_show_levels and barstate.islast
    line.delete(ln_asia_hi)
    line.delete(ln_asia_lo)
    line.delete(ln_pdh)
    line.delete(ln_pdl)
    line.delete(ln_round_a)
    line.delete(ln_round_b)

    if i_show_asia and not na(asia_hi_confirmed)
        ln_asia_hi := line.new(bar_index - 30, asia_hi_confirmed, bar_index + 10, asia_hi_confirmed, color=color.new(#1E88E5, 30), width=1, style=line.style_dotted)
        ln_asia_lo := line.new(bar_index - 30, asia_lo_confirmed, bar_index + 10, asia_lo_confirmed, color=color.new(#1E88E5, 30), width=1, style=line.style_dotted)

    if i_show_pdhl and not na(pdh)
        ln_pdh := line.new(bar_index - 30, pdh, bar_index + 10, pdh, color=color.new(#FF6F00, 30), width=1, style=line.style_dashed)
        ln_pdl := line.new(bar_index - 30, pdl, bar_index + 10, pdl, color=color.new(#FF6F00, 30), width=1, style=line.style_dashed)

    if i_show_round
        ln_round_a := line.new(bar_index - 30, round_above, bar_index + 10, round_above, color=color.new(#9E9E9E, 50), width=1, style=line.style_dotted)
        ln_round_b := line.new(bar_index - 30, round_below, bar_index + 10, round_below, color=color.new(#9E9E9E, 50), width=1, style=line.style_dotted)

// ============================================================
// SWEEP DETECTION
// Wick pierces a key level, close stays inside = liquidity grab
// ============================================================

f_near(price, level, tol_pct) =>
    not na(level) and math.abs(price - level) / level * 100 < tol_pct

f_swept_above(lvl) =>
    not na(lvl) and high > lvl and close < lvl and (high - math.max(open, close)) > (high - low) * i_sweep_wick * 0.5

f_swept_below(lvl) =>
    not na(lvl) and low < lvl and close > lvl and (math.min(open, close) - low) > (high - low) * i_sweep_wick * 0.5

// Check all key levels for sweeps
sweep_asia_hi = f_swept_above(asia_hi_confirmed)
sweep_asia_lo = f_swept_below(asia_lo_confirmed)
sweep_pdh     = f_swept_above(pdh)
sweep_pdl     = f_swept_below(pdl)
sweep_sw_hi   = f_swept_above(sw_hi_1)
sweep_sw_lo   = f_swept_below(sw_lo_1)
sweep_round_a = f_swept_above(round_above)
sweep_round_b = f_swept_below(round_below)

any_sweep_bull = sweep_asia_lo or sweep_pdl or sweep_sw_lo or sweep_round_b
any_sweep_bear = sweep_asia_hi or sweep_pdh or sweep_sw_hi or sweep_round_a

// Sweep quality: Asia/PDH/PDL worth more than generic swing
sweep_quality_bull = (sweep_asia_lo or sweep_pdl ? 2 : 1)
sweep_quality_bear = (sweep_asia_hi or sweep_pdh ? 2 : 1)

// ============================================================
// DISPLACEMENT DETECTION
// Strong impulsive candle following a sweep
// ============================================================

bar_body  = math.abs(close - open)
bar_range = high - low
body_ratio = bar_range > 0 ? bar_body / bar_range : 0.0
is_big     = bar_range > atr * i_disp_atr

disp_bull = close > open and body_ratio > i_disp_body and is_big
disp_bear = close < open and body_ratio > i_disp_body and is_big

// Displacement within 3 bars after sweep
var int last_sweep_bull_bar = -99
var int last_sweep_bear_bar = -99

if any_sweep_bull
    last_sweep_bull_bar := bar_index
if any_sweep_bear
    last_sweep_bear_bar := bar_index

disp_after_sweep_bull = disp_bull and (bar_index - last_sweep_bull_bar <= 3) and (bar_index - last_sweep_bull_bar >= 0)
disp_after_sweep_bear = disp_bear and (bar_index - last_sweep_bear_bar <= 3) and (bar_index - last_sweep_bear_bar >= 0)

// ============================================================
// FVG DETECTION (Fair Value Gap)
// Bullish FVG: low[0] > high[2]  (gap up)
// Bearish FVG: high[0] < low[2]  (gap down)
// ============================================================

fvg_bull_exists = low > high[2] and (low - high[2]) / close * 100 > i_fvg_min
fvg_bear_exists = high < low[2] and (low[2] - high) / close * 100 > i_fvg_min

fvg_bull_top = fvg_bull_exists ? low : na
fvg_bull_bot = fvg_bull_exists ? high[2] : na
fvg_bear_top = fvg_bear_exists ? low[2] : na
fvg_bear_bot = fvg_bear_exists ? high : na

// ============================================================
// ORDER BLOCK DETECTION
// Last opposing candle before displacement
// ============================================================

ob_bull_exists = disp_after_sweep_bull and close[1] < open[1]
ob_bear_exists = disp_after_sweep_bear and close[1] > open[1]

ob_bull_top = ob_bull_exists ? high[1] : na
ob_bull_bot = ob_bull_exists ? low[1] : na
ob_bear_top = ob_bear_exists ? high[1] : na
ob_bear_bot = ob_bear_exists ? low[1] : na

// ============================================================
// SESSION CONTEXT
// London open (07-09 UTC) and NY open (12-14 UTC) = best windows
// ============================================================

is_london_open = utc_h >= 7 and utc_h < 10
is_ny_open     = utc_h >= 12 and utc_h < 15
is_overlap     = utc_h >= 12 and utc_h < 15
is_killzone    = is_london_open or is_ny_open
is_dead_zone   = utc_h >= 20 or utc_h < 2

// ============================================================
// ZONE STATE MACHINE
// Uses arrays to manage multiple zones simultaneously
// States: 0=candidate, 1=armed, 2=mitigated, 3=invalidated
// ============================================================

// Zone arrays
var float[] z_top      = array.new_float(0)
var float[] z_bot      = array.new_float(0)
var int[]   z_dir      = array.new_int(0)
var int[]   z_state    = array.new_int(0)
var int[]   z_bar      = array.new_int(0)
var int[]   z_score    = array.new_int(0)
var int[]   z_class    = array.new_int(0)
var box[]   z_box      = array.new_box(0)
var label[] z_lbl      = array.new_label(0)

// --- Score Calculation Function
f_calc_score(has_liq, liq_qual, has_disp, has_ineff, in_killzone_now, aligned_bias, is_dead) =>
    int s = 0
    if has_liq
        s += i_w_liq * liq_qual
    if has_disp
        s += i_w_disp
    if has_ineff
        s += i_w_ineff
    if in_killzone_now
        s += i_w_sess
    if aligned_bias
        s += i_w_bias
    if is_dead
        s -= i_p_noise
    s

// --- Create Zones
bull_zone_trigger = disp_after_sweep_bull and not is_dead_zone
bear_zone_trigger = disp_after_sweep_bear and not is_dead_zone

var int last_zone_bar = -10

if bull_zone_trigger and (bar_index - last_zone_bar >= 3)
    float zt = na
    float zb = na
    bool has_ineff = false

    if (i_zone_type == "FVG" or i_zone_type == "Both") and fvg_bull_exists
        zt := fvg_bull_top
        zb := fvg_bull_bot
        has_ineff := true
    else if (i_zone_type == "OB" or i_zone_type == "Both") and ob_bull_exists
        zt := ob_bull_top
        zb := ob_bull_bot
        has_ineff := true

    if not na(zt) and not na(zb)
        int liq_q = sweep_quality_bull
        int sc = f_calc_score(true, liq_q, true, has_ineff, is_killzone, bias_bull, is_dead_zone)

        if sc >= i_score_min
            int cls = sc >= i_score_top ? 2 : (sc >= i_score_alert ? 1 : 0)

            array.unshift(z_top, zt)
            array.unshift(z_bot, zb)
            array.unshift(z_dir, 1)
            array.unshift(z_state, 0)
            array.unshift(z_bar, bar_index)
            array.unshift(z_score, sc)
            array.unshift(z_class, cls)

            box new_box = box.new(bar_index, zt, bar_index + i_expiry, zb, border_color=i_col_bull_c, bgcolor=i_col_bull_c, border_width=1)
            array.unshift(z_box, new_box)

            string class_txt = cls == 2 ? "A+" : (cls == 1 ? "A" : "B")
            string lbl_txt = "BULL " + class_txt + " [" + str.tostring(sc) + "]"
            label new_lbl = na
            if i_show_scores
                new_lbl := label.new(bar_index, zb, lbl_txt, style=label.style_label_up, color=i_col_bull_c, textcolor=color.white, size=size.tiny, yloc=yloc.price)
            array.unshift(z_lbl, new_lbl)

            last_zone_bar := bar_index

if bear_zone_trigger and (bar_index - last_zone_bar >= 3)
    float zt = na
    float zb = na
    bool has_ineff = false

    if (i_zone_type == "FVG" or i_zone_type == "Both") and fvg_bear_exists
        zt := fvg_bear_top
        zb := fvg_bear_bot
        has_ineff := true
    else if (i_zone_type == "OB" or i_zone_type == "Both") and ob_bear_exists
        zt := ob_bear_top
        zb := ob_bear_bot
        has_ineff := true

    if not na(zt) and not na(zb)
        int liq_q = sweep_quality_bear
        int sc = f_calc_score(true, liq_q, true, has_ineff, is_killzone, bias_bear, is_dead_zone)

        if sc >= i_score_min
            int cls = sc >= i_score_top ? 2 : (sc >= i_score_alert ? 1 : 0)

            array.unshift(z_top, zt)
            array.unshift(z_bot, zb)
            array.unshift(z_dir, -1)
            array.unshift(z_state, 0)
            array.unshift(z_bar, bar_index)
            array.unshift(z_score, sc)
            array.unshift(z_class, cls)

            box new_box = box.new(bar_index, zt, bar_index + i_expiry, zb, border_color=i_col_bear_c, bgcolor=i_col_bear_c, border_width=1)
            array.unshift(z_box, new_box)

            string class_txt = cls == 2 ? "A+" : (cls == 1 ? "A" : "B")
            string lbl_txt = "BEAR " + class_txt + " [" + str.tostring(sc) + "]"
            label new_lbl = na
            if i_show_scores
                new_lbl := label.new(bar_index, zt, lbl_txt, style=label.style_label_down, color=i_col_bear_c, textcolor=color.white, size=size.tiny, yloc=yloc.price)
            array.unshift(z_lbl, new_lbl)

            last_zone_bar := bar_index

// ============================================================
// ZONE MANAGEMENT: Retest -> Armed, Mitigation, Expiry
// ============================================================

var bool armed_alert_bull = false
var bool armed_alert_bear = false
armed_alert_bull := false
armed_alert_bear := false

if array.size(z_top) > 0
    int sz = array.size(z_top)
    for idx = sz - 1 to 0
        if idx >= array.size(z_top)
            continue

        float zt   = array.get(z_top, idx)
        float zb   = array.get(z_bot, idx)
        int   dir  = array.get(z_dir, idx)
        int   st   = array.get(z_state, idx)
        int   zbar = array.get(z_bar, idx)
        int   sc   = array.get(z_score, idx)
        int   cls  = array.get(z_class, idx)

        // --- Expiry check
        if bar_index - zbar > i_expiry
            array.set(z_state, idx, 2)
            if idx < array.size(z_box)
                box.set_bgcolor(array.get(z_box, idx), i_col_mitig)
                box.set_border_color(array.get(z_box, idx), i_col_mitig)
            continue

        // --- Mitigation check
        float zone_height = zt - zb
        float mitig_depth = zone_height * i_mitig_pct / 100.0
        bool mitigated = false

        if dir == 1
            if low < zt - mitig_depth
                mitigated := true
        else
            if high > zb + mitig_depth
                mitigated := true

        if mitigated and st != 2
            array.set(z_state, idx, 2)
            if idx < array.size(z_box)
                box.set_bgcolor(array.get(z_box, idx), i_col_mitig)
                box.set_border_color(array.get(z_box, idx), i_col_mitig)
            continue

        // --- Invalidation: close beyond zone
        bool invalidated = false
        if dir == 1 and close < zb and bar_index - zbar > 2
            invalidated := true
        if dir == -1 and close > zt and bar_index - zbar > 2
            invalidated := true

        if invalidated and st != 2
            array.set(z_state, idx, 2)
            if idx < array.size(z_box)
                box.set_bgcolor(array.get(z_box, idx), i_col_mitig)
                box.set_border_color(array.get(z_box, idx), i_col_mitig)
            continue

        // --- Retest -> Promote to Armed
        if st == 0
            bool retested = false
            if dir == 1
                retested := low <= zt and low >= zb and close > zt
            else
                retested := high >= zb and high <= zt and close < zb

            if retested
                int new_sc = sc + i_w_conf
                array.set(z_score, idx, new_sc)
                int new_cls = new_sc >= i_score_top ? 2 : (new_sc >= i_score_alert ? 1 : 0)
                array.set(z_class, idx, new_cls)
                array.set(z_state, idx, 1)

                if idx < array.size(z_box)
                    if dir == 1
                        box.set_bgcolor(array.get(z_box, idx), i_col_bull_a)
                        box.set_border_color(array.get(z_box, idx), i_col_bull_a)
                    else
                        box.set_bgcolor(array.get(z_box, idx), i_col_bear_a)
                        box.set_border_color(array.get(z_box, idx), i_col_bear_a)

                if i_show_scores and idx < array.size(z_lbl)
                    label old_lbl = array.get(z_lbl, idx)
                    if not na(old_lbl)
                        label.delete(old_lbl)
                    string dir_txt = dir == 1 ? "BULL" : "BEAR"
                    string c_txt = new_cls == 2 ? "A+" : (new_cls == 1 ? "A" : "B")
                    string armed_txt = dir_txt + " ARMED " + c_txt + " [" + str.tostring(new_sc) + "]"
                    if dir == 1
                        label new_armed_lbl = label.new(bar_index, zb, armed_txt, style=label.style_label_up, color=i_col_bull_a, textcolor=color.white, size=size.small, yloc=yloc.price)
                        array.set(z_lbl, idx, new_armed_lbl)
                    else
                        label new_armed_lbl = label.new(bar_index, zt, armed_txt, style=label.style_label_down, color=i_col_bear_a, textcolor=color.white, size=size.small, yloc=yloc.price)
                        array.set(z_lbl, idx, new_armed_lbl)

                if new_cls >= 1
                    if dir == 1
                        armed_alert_bull := true
                    else
                        armed_alert_bear := true

    // --- Trim excess zones
    while array.size(z_top) > i_max_zones
        int last_idx = array.size(z_top) - 1
        array.pop(z_top)
        array.pop(z_bot)
        array.pop(z_dir)
        array.pop(z_state)
        array.pop(z_bar)
        array.pop(z_score)
        array.pop(z_class)
        if array.size(z_box) > last_idx
            box.delete(array.pop(z_box))
        if array.size(z_lbl) > last_idx
            label old_l = array.pop(z_lbl)
            if not na(old_l)
                label.delete(old_l)

// ============================================================
// VISUAL: SWEEP MARKERS
// ============================================================

plotshape(any_sweep_bull and not is_dead_zone,
     title="Sweep Low",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(#1E88E5, 20),
     size=size.tiny,
     text="SW")

plotshape(any_sweep_bear and not is_dead_zone,
     title="Sweep High",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(#1E88E5, 20),
     size=size.tiny,
     text="SW")

plotshape(disp_after_sweep_bull,
     title="Displacement Bull",
     style=shape.arrowup,
     location=location.belowbar,
     color=color.new(#00E676, 0),
     size=size.small)

plotshape(disp_after_sweep_bear,
     title="Displacement Bear",
     style=shape.arrowdown,
     location=location.abovebar,
     color=color.new(#FF1744, 0),
     size=size.small)

// ============================================================
// CANDLE COLOR
// ============================================================

var color bc = na
if disp_after_sweep_bull
    bc := color.new(#00E676, 20)
else if disp_after_sweep_bear
    bc := color.new(#FF1744, 20)
else if any_sweep_bull or any_sweep_bear
    bc := color.new(#FFD600, 40)
else
    bc := na

barcolor(bc, title="Event Candle Color")

// ============================================================
// SESSION BACKGROUND
// ============================================================

bgcolor(is_killzone ? color.new(#1B5E20, 96) : na, title="Killzone BG")
bgcolor(is_dead_zone ? color.new(#37474F, 97) : na, title="Dead Zone BG")

// ============================================================
// ALERTS
// ============================================================

alertcondition(armed_alert_bull, "Armed Bull Zone A/A+", "XAU SNIPER: Bull zone ARMED - Class A or A+")
alertcondition(armed_alert_bear, "Armed Bear Zone A/A+", "XAU SNIPER: Bear zone ARMED - Class A or A+")
alertcondition(any_sweep_bull, "Sweep Below Key Level", "XAU SNIPER: Liquidity swept below key level")
alertcondition(any_sweep_bear, "Sweep Above Key Level", "XAU SNIPER: Liquidity swept above key level")
alertcondition(disp_after_sweep_bull, "Displacement Bull", "XAU SNIPER: Bullish displacement after sweep")
alertcondition(disp_after_sweep_bear, "Displacement Bear", "XAU SNIPER: Bearish displacement after sweep")
````

# MTF Dashboard with WVAP Volume option

- url: https://www.tradingview.com/script/AIgTfgPY-MTF-Dashboard-with-WVAP-Volume-option/
- type: indicator
- pine_id: PUB;ea9c5084690d4cdfaa30bc5ac165b9a3
- version: 1.0

## Description

This is a WIP for now...Multi level RSI, vwap with VOLUME weighted std deviation also offer std price deviation option.

## Source Code

````pine
//@version=6
// MTF Dashboard Overlay — fixed VWAP session anchor
indicator(title="Multi-TF Dashboard Overlay", shorttitle="MTF Dashboard", overlay=true, max_lines_count=10, max_labels_count=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────

// VWAP
var g_vwap = "── VWAP ──"
vwap_show       = input.bool(true,  "Show VWAP",               group=g_vwap)
vwap_bands_show = input.bool(true,  "Show VWAP SD Bands",      group=g_vwap)
vwap_mult1      = input.float(1.0,  "Band 1 Multiplier (σ)",   group=g_vwap, minval=0.25, maxval=5.0, step=0.25,
     tooltip="e.g. 1.0 = ±1σ, 2.0 = ±2σ. Use 0.5 early-session for tighter bands.")
vwap_mult2      = input.float(2.0,  "Band 2 Multiplier (σ)",   group=g_vwap, minval=0.25, maxval=5.0, step=0.25,
     tooltip="Second set of bands. Set equal to Band 1 to hide it.")
vwap_band2_show  = input.bool(false, "Show Band 2",                    group=g_vwap)
vwap_simple_show = input.bool(false, "Show Simple Price StDev Bands",  group=g_vwap,
     tooltip="Overlays unweighted price StDev bands for comparison. Each bar contributes equally regardless of volume.")

// RSI – Timeframe 1 (Fast)
var g_rsi1 = "── RSI – TF 1 (Fast) ──"
rsi1_tf  = input.timeframe("5",  "Timeframe 1", group=g_rsi1)
rsi1_len = input.int(14,         "RSI Length",  group=g_rsi1, minval=2)
rsi1_src = input.source(close,   "Source",      group=g_rsi1)

// RSI – Timeframe 2 (Mid)
var g_rsi2 = "── RSI – TF 2 (Mid) ──"
rsi2_tf  = input.timeframe("15", "Timeframe 2", group=g_rsi2)
rsi2_len = input.int(14,         "RSI Length",  group=g_rsi2, minval=2)
rsi2_src = input.source(close,   "Source",      group=g_rsi2)

// RSI – Timeframe 3 (Slow)
var g_rsi3 = "── RSI – TF 3 (Slow) ──"
rsi3_tf  = input.timeframe("60", "Timeframe 3", group=g_rsi3)
rsi3_len = input.int(14,         "RSI Length",  group=g_rsi3, minval=2)
rsi3_src = input.source(close,   "Source",      group=g_rsi3)

// Volume
var g_vol = "── Volume ──"
vol_lookback = input.int(30, "Avg Volume Lookback (days)", group=g_vol, minval=5, maxval=252)

// Dashboard Display
var g_dash = "── Dashboard ──"
dash_pos  = input.string("Top Right", "Position",  group=g_dash, options=["Top Right","Top Left","Bottom Right","Bottom Left"])
dash_size = input.string("Normal",    "Text Size",  group=g_dash, options=["Tiny","Small","Normal","Large"])

// Trend Strength EMAs
var g_trend = "── Trend Strength ──"
ema_fast  = input.int(9,  "Fast EMA",  group=g_trend, minval=1)
ema_slow  = input.int(21, "Slow EMA",  group=g_trend, minval=1)
ema_trend = input.int(50, "Trend EMA", group=g_trend, minval=1)

// ─────────────────────────────────────────────
//  VWAP CALCULATION (session-anchored, variable SD)
// ─────────────────────────────────────────────
// Detect the start of each new session (resets VWAP daily)
is_new_session = timeframe.change("1D")

// On the very first bar, also treat it as a new period
var bool first_bar = true
if first_bar
    is_new_session := true
    first_bar := false

float vwap_val    = na
float vwap_upper1 = na
float vwap_lower1 = na
float vwap_upper2 = na
float vwap_lower2 = na

if not timeframe.isdwm
    // Band 1 — user-defined multiplier
    [_vwap1, _up1, _lo1] = ta.vwap(hlc3, is_new_session, vwap_mult1)
    vwap_val    := _vwap1
    vwap_upper1 := _up1
    vwap_lower1 := _lo1
    // Band 2 — separate multiplier, isolate stdev then rescale
    [_v2, _up2, _lo2]    = ta.vwap(hlc3, is_new_session, vwap_mult2)
    vwap_upper2 := _up2
    vwap_lower2 := _lo2

// ─────────────────────────────────────────────
//  SIMPLE PRICE STDEV BANDS (equal-weight, for comparison)
// ─────────────────────────────────────────────
// Number of bars since session open (reuses is_new_session)
var int session_bar_index = 0
if is_new_session
    session_bar_index := 1
else
    session_bar_index := session_bar_index + 1

// Running mean of squared deviations from VWAP
// sigma = sqrt( mean( (price - VWAP)^2 ) ) over all bars this session
float price_src      = hlc3
float sq_dev         = math.pow(price_src - vwap_val, 2)
float running_sq_dev = na
var float cum_sq_dev  = 0.0
if is_new_session
    cum_sq_dev := sq_dev
else
    cum_sq_dev := cum_sq_dev + sq_dev
running_sq_dev := cum_sq_dev / session_bar_index
float simple_sigma   = not na(vwap_val) ? math.sqrt(running_sq_dev) : na

// Apply the same Band 1 multiplier for a like-for-like comparison
float simple_upper = not na(simple_sigma) ? vwap_val + simple_sigma * vwap_mult1 : na
float simple_lower = not na(simple_sigma) ? vwap_val - simple_sigma * vwap_mult1 : na

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────
plot(vwap_show ? vwap_val : na,                              title="VWAP",           color=color.new(color.yellow, 0),  linewidth=2)
plot(vwap_bands_show ? vwap_upper1 : na,                     title="VWAP Band1+",    color=color.new(color.aqua,   45), linewidth=1)
plot(vwap_bands_show ? vwap_lower1 : na,                     title="VWAP Band1-",    color=color.new(color.aqua,   45), linewidth=1)
plot(vwap_bands_show and vwap_band2_show ? vwap_upper2 : na, title="VWAP Band2+",    color=color.new(color.blue,   35), linewidth=1)
plot(vwap_bands_show and vwap_band2_show ? vwap_lower2 : na, title="VWAP Band2-",    color=color.new(color.blue,   35), linewidth=1)
// Simple StDev bands — dashed style via step to visually distinguish from VW bands
plot(vwap_simple_show ? simple_upper : na, title="VWAP SimpleSD+", color=color.new(color.orange, 30), linewidth=1)
plot(vwap_simple_show ? simple_lower : na, title="VWAP SimpleSD-", color=color.new(color.orange, 30), linewidth=1)

// ─────────────────────────────────────────────
//  MULTI-TIMEFRAME RSI
// ─────────────────────────────────────────────
rsi1_val = request.security(syminfo.tickerid, rsi1_tf, ta.rsi(rsi1_src, rsi1_len), lookahead=barmerge.lookahead_off)
rsi2_val = request.security(syminfo.tickerid, rsi2_tf, ta.rsi(rsi2_src, rsi2_len), lookahead=barmerge.lookahead_off)
rsi3_val = request.security(syminfo.tickerid, rsi3_tf, ta.rsi(rsi3_src, rsi3_len), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  VOLUME % vs N-DAY AVERAGE — pace-projected
// ─────────────────────────────────────────────
// Pull current cumulative volume and 30-day avg from daily TF
daily_vol = request.security(syminfo.tickerid, "1D", volume,                       lookahead=barmerge.lookahead_off)
avg_vol   = request.security(syminfo.tickerid, "1D", ta.sma(volume, vol_lookback),  lookahead=barmerge.lookahead_off)

// Session length input (default 390 min = 9:30–4:00 ET for equities/SPX)
var g_vol2 = "── Volume Session ──"
session_minutes = input.int(390, "Session Length (minutes)", group=g_vol2, minval=60, maxval=1440,
     tooltip="390 = NYSE regular session (9:30–4:00 ET). Use 1440 for 24h futures.")

// Count intraday bars elapsed since session open using timeframe.in_seconds()
bars_per_day     = session_minutes * 60 / timeframe.in_seconds()
var int bar_count = 0
if is_new_session
    bar_count := 1
else
    bar_count := bar_count + 1

// Fraction of session elapsed (cap at 1.0 so post-close doesn't inflate)
float elapsed_frac = math.min(bar_count / bars_per_day, 1.0)

// Project today's partial volume to full-session equivalent
float projected_vol = elapsed_frac > 0 ? daily_vol / elapsed_frac : daily_vol

// Compare projected volume to 30-day average
float vol_pct = avg_vol != 0 ? (projected_vol / avg_vol) * 100 : 0.0

// ─────────────────────────────────────────────
//  TREND STRENGTH SCORE (0–5)
// ─────────────────────────────────────────────
ema_f = ta.ema(close, ema_fast)
ema_s = ta.ema(close, ema_slow)
ema_t = ta.ema(close, ema_trend)

score = 0
score := score + (close   > ema_t ? 1 : 0)   // price above trend EMA
score := score + (ema_f   > ema_s ? 1 : 0)   // fast above slow EMA
score := score + (ema_s   > ema_t ? 1 : 0)   // slow above trend EMA
score := score + (rsi2_val > 50   ? 1 : 0)   // mid-TF RSI bullish
score := score + (rsi3_val > 50   ? 1 : 0)   // slow-TF RSI bullish

var string trend_label = ""
var color  trend_color = color.gray
if score >= 5
    trend_label := "▲ STRONG BULL"
    trend_color := color.new(color.lime,   0)
else if score == 4
    trend_label := "▲ Bull"
    trend_color := color.new(color.green, 20)
else if score == 3
    trend_label := "◆ Neutral"
    trend_color := color.new(color.gray,  10)
else if score == 2
    trend_label := "▼ Bear"
    trend_color := color.new(color.orange,10)
else
    trend_label := "▼ STRONG BEAR"
    trend_color := color.new(color.red,    0)

// ─────────────────────────────────────────────
//  COLOR HELPERS  (v6: if/else, no na returns)
// ─────────────────────────────────────────────
rsi_color(float v) =>
    color result = color.new(color.gray, 10)
    if v >= 70
        result := color.new(color.red,    10)
    else if v >= 60
        result := color.new(color.orange, 10)
    else if v >= 50
        result := color.new(color.lime,   10)
    else if v >= 40
        result := color.new(color.yellow, 10)
    else
        result := color.new(color.red,    30)
    result

vol_color(float v) =>
    color result = color.new(color.gray, 20)
    if v >= 150
        result := color.new(color.lime,   0)
    else if v >= 100
        result := color.new(color.green, 20)
    else if v >= 70
        result := color.new(color.yellow,10)
    else
        result := color.new(color.gray,  20)
    result

// ─────────────────────────────────────────────
//  DASHBOARD SIZE & POSITION  (v6: if/else)
// ─────────────────────────────────────────────
var string txt_size_str = size.normal
if dash_size == "Tiny"
    txt_size_str := size.tiny
else if dash_size == "Small"
    txt_size_str := size.small
else if dash_size == "Large"
    txt_size_str := size.large
else
    txt_size_str := size.normal

var string tbl_pos_str = position.top_right
if dash_pos == "Top Left"
    tbl_pos_str := position.top_left
else if dash_pos == "Bottom Right"
    tbl_pos_str := position.bottom_right
else if dash_pos == "Bottom Left"
    tbl_pos_str := position.bottom_left
else
    tbl_pos_str := position.top_right

// ─────────────────────────────────────────────
//  TABLE
// ─────────────────────────────────────────────
var table dash = table.new(tbl_pos_str, 2, 7,
     bgcolor      = color.new(color.black, 20),
     border_width = 1,
     border_color = color.new(color.gray,  50),
     frame_width  = 1,
     frame_color  = color.new(color.gray,  30))

update_row(int row, string lbl, string val_str, color val_col) =>
    table.cell(dash, 0, row, lbl,     text_color=color.new(color.white, 20), text_size=txt_size_str, bgcolor=color.new(color.black, 30))
    table.cell(dash, 1, row, val_str, text_color=val_col,                    text_size=txt_size_str, bgcolor=color.new(color.black, 20))

if barstate.islast
    // Header row
    table.cell(dash, 0, 0, "INDICATOR", text_color=color.white, text_size=txt_size_str, bgcolor=color.new(color.navy, 10))
    table.cell(dash, 1, 0, "VALUE",     text_color=color.white, text_size=txt_size_str, bgcolor=color.new(color.navy, 10))

    // VWAP row
    vwap_diff_pct = close != 0 ? ((close - vwap_val) / vwap_val) * 100 : 0.0
    vwap_sign     = vwap_diff_pct >= 0 ? "▲" : "▼"
    vwap_col      = vwap_diff_pct >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    update_row(1, "VWAP", str.format("{0,number,#.##}  {1}{2,number,#.##}%", vwap_val, vwap_sign, math.abs(vwap_diff_pct)), vwap_col)

    // RSI rows
    update_row(2, "RSI " + rsi1_tf + "m", str.format("{0,number,#.#}", rsi1_val), rsi_color(rsi1_val))
    update_row(3, "RSI " + rsi2_tf + "m", str.format("{0,number,#.#}", rsi2_val), rsi_color(rsi2_val))
    update_row(4, "RSI " + rsi3_tf + "m", str.format("{0,number,#.#}", rsi3_val), rsi_color(rsi3_val))

    // Volume row — label shows projected pace
    update_row(5, "Vol Pace/" + str.tostring(vol_lookback) + "dAvg", str.format("{0,number,#.#}%", vol_pct), vol_color(vol_pct))

    // Trend row
    update_row(6, "Trend", trend_label + "  [" + str.tostring(score) + "/5]", trend_color)
````

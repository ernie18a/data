# WSD - Seasonality Pro

- url: https://www.tradingview.com/script/EVCPx2s3-WSD-Seasonality-Pro/
- type: indicator
- pine_id: PUB;595c4ff229f94820b69923c3998b58e4
- version: 1.0

## Description

📈 WSD - Seasonality Pro

Overview

WSD - Seasonality Pro is an advanced asset-class agnostic data-mining tool designed to extract, isolate, and project multi-year seasonal tendencies directly onto your chart. By processing historical daily logs, the engine calculates baseline performance across specific phases of the calendar year, producing an institutional-grade seasonal roadmap. It visualizes both a comprehensive historical benchmark and a forward-looking Forecast Window to help traders align with cyclical market flows.

Key Features
Dual Calculation Engines

Trading Days Mode: Filters out weekends and non-trading periods. Optimized for structured execution environments like Forex, Global Indices (NASDAQ, DAX), and Commodities (Gold, USOIL).

Calendar Days Mode: Tracks a continuous, uninterrupted 365-day loop. Engineered specifically for Crypto markets.

US Presidential Electoral Cycle Filtering
Allows macro-driven traders to isolate historical performance based on the 4-year US political cycle. You can filter the data engine to strictly analyze:

Election Years

Post-Election Years

Midterm Years

Pre-Election Years

Mathematical Detrending & Volatility Scaling
To prevent historical multi-year trends from distorting cyclical data, the script mathematically removes baseline price drift (slope detrending). It then dynamically recalibrates the visual range using the asset's current Average True Range (ATR), ensuring the seasonal curves match today's exact volatility regime.

Optimized Vector Visuals
Utilizes native Pine Script v6 polyline rendering to draw a clean, cohesive, and lag-free interface. The grey curve displays the relative historical pathway up to the current bar, while the blue extension projects the high-probability seasonal outlook for your specified forecast window.

🛠 How to Use It in Your Trading Strategy
⚠️ Important Note: This indicator is a directional roadmap, not an execution trigger. It does not provide immediate entry signals; instead, it establishes structural context.

Macro Bias Alignment: Look at the blue forecast line to see the structural tendency for the next 30 to 60 days. If the seasonal pattern points sharply upward, your structural bias for the asset should be Bullish.

Confluence Trading: Once a seasonal window (bullish or bearish) is identified, drop down to your execution timeframes. Look for technical setups—such as structural breaks, institutional order blocks, or liquidity sweeps—that align with the macro seasonal direction.

Portfolio Rebalancing: Use the Electoral Cycle filters when trading major indices to see if current geopolitical phases are historically prone to specific Q3/Q4 rallies or distribution phases.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version=6
indicator("WSD - Seasonality Pro", shorttitle="WSD - Seasonality Pro", overlay=false, max_polylines_count=100, max_lines_count=500)

// =============================================================================
// 1. INPUTS
// =============================================================================
grp_eng = "Calculation Engine"
_calc_mode = input.string("Trading Days", "Count Mode", options=["Trading Days", "Calendar Days"], group=grp_eng, tooltip="Trading Days: Ignores weekends (ideal for Stocks/Forex).\nCalendar Days: Counts every day (ideal for Crypto).")

grp_cyc = "Cycle Filters"
_cycle_filt = input.string("Midterm Year", "Cycle Phase", options=["All Years (Regular)", "Election Year", "Post-Election", "Midterm Year", "Pre-Election"], group=grp_cyc)
_lookback   = input.int(24, "History (Years)", minval=4, maxval=100, group=grp_cyc, tooltip="How many years to analyse? For electoral cycles, use multiples of 4.")

grp_proj = "Projection & Stats"
_proj_bars  = input.int(60, "Forecast Window (Days)", minval=10, maxval=252, group=grp_proj)
_stats_win  = input.int(30, "Stats Window", minval=5, maxval=90, group=grp_proj, tooltip="Analyses profit probability for the next X days.")

grp_vis = "Visual"
_color_hist = input.color(#808080, "Historical Curve Color", group=grp_vis) // Αλλάχτηκε σε Γκρι
_color_fore = input.color(#007FFF, "Forecast Color", group=grp_vis)         // Αλλάχτηκε σε Μπλε
_width      = input.int(2, "Line Width", minval=1, group=grp_vis)

// =============================================================================
// 2. GLOBAL CALCULATIONS
// =============================================================================
float global_atr = ta.atr(14)
float global_tr  = ta.tr(true)

// =============================================================================
// 3. TIME ENGINE
// =============================================================================
int ms_day   = 86400000
int start_yr = timestamp(year(time), 1, 1, 0, 0)
int diff_ts  = time - start_yr
int cal_idx  = math.floor(diff_ts / ms_day)
if cal_idx < 0
    cal_idx := 0
if cal_idx > 365
    cal_idx := 365

var int trade_idx = 0
if ta.change(year(time)) != 0
    trade_idx := 0
else
    trade_idx := trade_idx + 1
if trade_idx > 365
    trade_idx := 365

int current_doy = _calc_mode == "Calendar Days" ? int(cal_idx) : trade_idx
int MAX_DAYS    = 367

// =============================================================================
// 4. ELECTORAL CYCLE LOGIC
// =============================================================================
int REF_YEAR = 2024

get_phase(int y) =>
    int diff = y - REF_YEAR
    int p    = diff % 4
    if p < 0
        p := p + 4
    p

int target_p = -1
if _cycle_filt == "Election Year"
    target_p := 0
if _cycle_filt == "Post-Election"
    target_p := 1
if _cycle_filt == "Midterm Year"
    target_p := 2
if _cycle_filt == "Pre-Election"
    target_p := 3

// =============================================================================
// 5. DATA MINING
// =============================================================================
var array<float> sum_pct  = array.new<float>(MAX_DAYS, 0.0)
var array<int>   cnt_yr   = array.new<int>(MAX_DAYS, 0)
var array<int>   pos_days = array.new<int>(MAX_DAYS, 0)

int   start_ts   = timenow - (_lookback * 31557600000)
bool valid_time = time > start_ts

bool valid_cycle = true
if target_p != -1
    if get_phase(year(time)) != target_p
        valid_cycle := false

if valid_time and valid_cycle
    float ret = 0.0
    if close[1] != 0
        ret := math.log(close / close[1])

    float s = array.get(sum_pct, current_doy)
    array.set(sum_pct, current_doy, s + ret)

    int c = array.get(cnt_yr, current_doy)
    array.set(cnt_yr, current_doy, c + 1)

    if ret > 0
        int p = array.get(pos_days, current_doy)
        array.set(pos_days, current_doy, p + 1)

// =============================================================================
// 6. PROCESSING & PROJECTION (Last Bar)
// =============================================================================
if barstate.islast
    array<float> curve = array.new<float>(MAX_DAYS, 0.0)
    float acc           = 0.0
    int   max_valid_idx = 0

    for i = 0 to MAX_DAYS - 1
        int n = array.get(cnt_yr, i)
        if n > 0
            float avg = array.get(sum_pct, i) / n
            acc += avg
            max_valid_idx := i
        array.set(curve, i, acc)

    float start_v = array.get(curve, 0)
    float end_v   = array.get(curve, max_valid_idx)
    float slope   = (end_v - start_v) / math.max(1, max_valid_idx)

    for i = 0 to max_valid_idx
        float raw = array.get(curve, i)
        array.set(curve, i, raw - (slope * i))

    float safe_atr = global_atr
    if na(safe_atr)
        safe_atr := close * 0.01

    float c_max   = array.max(curve)
    float c_min   = array.min(curve)
    float c_range = c_max - c_min

    float scale = 0.0
    if c_range != 0
        scale := (safe_atr * 15) / c_range

    int safe_idx = current_doy
    if safe_idx > max_valid_idx
        safe_idx := 0

    float val_now  = array.get(curve, safe_idx)
    float offset_y = close - (val_now * scale)

    int start_bar_loop = bar_index
    for k = 0 to 3000
        if time[k] < chart.left_visible_bar_time
            start_bar_loop := bar_index - k
            break

    // Historical curve
    array<chart.point> pts_hist = array.new<chart.point>()
    for bi = start_bar_loop to bar_index
        int dist     = bi - bar_index
        int tdoy     = current_doy + dist
        int y_len    = max_valid_idx + 1
        int norm_doy = tdoy % y_len
        if norm_doy < 0
            node_doy = norm_doy + y_len
            norm_doy += y_len
        float price = offset_y + (array.get(curve, norm_doy) * scale)
        array.push(pts_hist, chart.point.from_index(bi, price))

    if array.size(pts_hist) > 0
        polyline.new(pts_hist, curved=true, line_color=_color_hist, line_width=_width)

    // Forecast curve
    array<chart.point> pts_fore = array.new<chart.point>()
    for bi = bar_index to bar_index + _proj_bars
        int dist     = bi - bar_index
        int tdoy     = current_doy + dist
        int y_len    = max_valid_idx + 1
        int norm_doy = tdoy % y_len
        if norm_doy < 0
            norm_doy += y_len
        float price = offset_y + (array.get(curve, norm_doy) * scale)
        array.push(pts_fore, chart.point.from_index(bi, price))

    if array.size(pts_fore) > 0
        polyline.new(pts_fore, curved=true, line_color=_color_fore, line_width=_width)
````

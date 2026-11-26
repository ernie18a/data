# Pan Sniper Hybrid V16.0 [Cluster VP]

- url: https://www.tradingview.com/script/5cq8EMmp-Pan-Sniper-Hybrid-V16-0-Cluster-VP/
- type: indicator
- pine_id: PUB;e84265559ccf4d04a9f3ad9d748e0162
- version: 2.0

## Description

📊 Pan Sniper Hybrid V16.0 [Cluster VP]
Advanced Multi-Indicator Trading System with Cluster Volume Profile
📝 Overview
Pan Sniper Hybrid is a comprehensive trading system that combines multiple advanced indicators including Cluster Volume Profile (K-Means Algorithm), Demand/Supply Zones, Fair Value Gaps, and Nadaraya-Watson Envelope. Designed for scalping and day trading with precise entry/exit signals.
✨ Key Features
1. Cluster Volume Profile (K-Means Clustering)
Uses machine learning algorithm to identify key price levels
Automatically detects Point of Control (POC) for each cluster
Visual volume distribution across different price zones
Color-coded clusters for easy identification
2. Demand/Supply Zones (PRO Scalper Style)
Two-tier zone detection (Pair A & Pair B)
ATR-based zone depth for dynamic adjustment
Touch counter to track zone strength
Trend-filtered zones (optional)
3. Fair Value Gaps (FVG) / Order Blocks
LuxAlgo-style imbalance detection
Customizable filter by percentage
Auto-extension and break detection
Visual signals when price enters FVG zones
4. Nadaraya-Watson Envelope
Non-parametric regression for trend detection
Upper/Lower bands for dynamic support/resistance
Smooth and responsive to market changes
5. Multi-Timeframe Dashboard
Real-time trend analysis (4H/1H/15m/1m)
Overall bias indicator (STRONG BULL/BEAR)
Entry/SL/TP calculation with R:R ratio
Position customization (Top Left/Right, Bottom Left/Right)
6. Density Zones
Detects high-volume/delta concentration areas
Auto-merge nearby zones
Break detection with volume confirmation
7. Session Boxes & Opening Range
4 customizable trading sessions (Asia/London/NY)
Multi-timeframe Opening Range (OR)
Dashed border style for clarity
🎯 How to Use
For LONG Entry:
Dashboard shows "STRONG BULL" or "BULL" bias
Wait for 🐂 (Bull) or 🦈 (Shark Bull) signal
Check Bull Score ≥ 3/5 (in Strict Mode)
Entry at signal candle close
SL below nearest Demand Zone or last Pivot Low
TP at nearest Supply Zone or TP1/TP2 levels
For SHORT Entry:
Dashboard shows "STRONG BEAR" or "BEAR" bias
Wait for 🐻 (Bear) or 🦈 (Shark Bear) signal
Check Bear Score ≥ 3/5 (in Strict Mode)
Entry at signal candle close
SL above nearest Supply Zone or last Pivot High
TP at nearest Demand Zone or TP1/TP2 levels
⚙️ Settings Guide
🔒 Strict Mode:
Enable Strict Mode: Filter signals by confluence
Min Confirmations: Minimum score required (2-5)
Min Volume Ratio: Minimum volume compared to MA
Max Distance %: Max distance from Gaussian filter
Avoid Choppy Market: Filter low volatility periods
🔷 Cluster Volume Profile:
Lookback Period: Number of bars to analyze (200 recommended)
Number of Clusters: How many groups to detect (5-7 optimal)
K-Means Iterations: Algorithm precision (30 recommended)
Rows per Cluster: Volume profile resolution (20 rows)
Max VP Width: Maximum histogram width in bars
Show POC Lines: Display Point of Control lines
🎯 Demand/Supply Zones:
Zone Depth × ATR: Zone thickness (0.6 = 60% of ATR)
Pivot A/B Left/Right: Pivot detection sensitivity
Show Only In-Trend: Hide counter-trend zones
Extend Zones: How far to extend zones (bars)
📦 FVG Order Blocks:
Filter Gaps by %: Minimum gap size percentage
Max Blocks Display: Limit visible blocks (prevent clutter)
Show Entry Signals: Show arrows when price enters FVG
🔹 Density Zones:
Metric: AbsDelta or Volume
Quantile %: Threshold for high density (92% = top 8%)
Depth × ATR: Zone thickness
Merge if |Δprice| < ×ATR: Merge nearby zones
📊 Dashboard Interpretation
Timeframe
Meaning
4H (Macro)
Major trend direction
1H (Bias)
Intermediate trend
15m (Setup)
Setup confirmation
1m (Entry)
Execution signal
OVERALL
Combined bias (STRONG BULL/BEAR = All TF aligned)
DECISION
LONG / SHORT / WAIT
⚠️ Risk Management
Recommended Timeframe: 5m, 15m, 1H
Leverage: Use appropriate leverage (25x-75x max)
Position Size: Risk max 1-2% per trade
Stop Loss: Always use SL (calculated automatically)
Take Profit: TP1 at 1:2 RR, TP2 at 1:4 RR
💡 Tips
Best Performance: Use on liquid pairs (BTC, ETH, major alts)
Avoid: Sideways markets when Overall Bias = "SIDEWAY"
Combine: Wait for signals in confluence with Cluster POC
Backtest: Test settings on your preferred timeframe first
Alerts: Set up alerts for "MTF LONG" and "MTF SHORT"
📌 Disclaimer
This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading cryptocurrencies involves substantial risk of loss. Past performance does not guarantee future results. Always do your own research and trade at your own risk.
🔧 Credits & Inspiration
Cluster Volume Profile: Inspired by LuxAlgo (CC BY-NC-SA 4.0)
Demand/Supply Zones: Inspired by PRO Scalper methodology
FVG Order Blocks: Based on BigBeluga's implementation
Nadaraya-Watson: Classic non-parametric regression
📞 Support
For questions, suggestions, or bug reports, please leave a comment or contact the author.
Happy Trading! 🚀

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pan Sniper Hybrid V16.0 [Cluster Volume Integrated]
// K-Means Clustering logic inspired by LuxAlgo (CC BY-NC-SA 4.0)

//@version=6
indicator("Pan Sniper Hybrid V16.0 [Cluster VP]", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ============================================================================
// INPUTS
// ============================================================================
group_macd = "MACD Settings"
fast_len = input.int(12, "Fast Length", group=group_macd)
slow_len = input.int(26, "Slow Length", group=group_macd)
sig_len = input.int(9, "Signal Length", group=group_macd)

group_sig = "Signal Thresholds"
bull_thresh = input.float(0.75, "Bull Threshold", minval=0.5, maxval=1.0, step=0.01, group=group_sig)
bear_thresh = input.float(0.25, "Bear Threshold", minval=0.0, maxval=0.5, step=0.01, group=group_sig)
shark_bull = input.float(0.85, "Shark Bull", minval=0.5, maxval=1.0, step=0.01, group=group_sig)
shark_bear = input.float(0.15, "Shark Bear", minval=0.0, maxval=0.5, step=0.01, group=group_sig)

group_strict = "🔒 Strict Mode"
strict_mode = input.bool(true, "Enable Strict Mode", group=group_strict)
min_confluence = input.int(3, "Min Confirmations", minval=2, maxval=5, group=group_strict)
vol_filter_val = input.float(1.2, "Min Volume Ratio", minval=1.0, step=0.1, group=group_strict)
dist_filter_pct = input.float(0.3, "Max Distance %", minval=0.1, step=0.1, group=group_strict)
avoid_chop = input.bool(true, "Avoid Choppy Market", group=group_strict)

group_trend = "Trend Filter"
g_len = input.int(200, "Gaussian Length", group=group_trend)
trend_mode = input.string("Off", "D/S Trend Filter", options=["Off","EMA","EMA+ADX"], group=group_trend)
use_htf = input.bool(true, "Use HTF for D/S Filter", group=group_trend)
tf_htf = input.timeframe("60", "HTF Timeframe", group=group_trend)
ema_fast_len = input.int(34, "EMA Fast (D/S)", minval=1, group=group_trend)
ema_slow_len = input.int(89, "EMA Slow (D/S)", minval=2, group=group_trend)
adx_len = input.int(14, "ADX Len (D/S)", minval=1, group=group_trend)
adx_thr = input.float(18, "ADX ≥ (D/S)", step=0.5, group=group_trend)
show_gaussian = input.bool(true, "Show Gaussian Line", group=group_trend)
gaussian_color = input.color(color.purple, "Gaussian Color", group=group_trend)
enable_gauss_alert = input.bool(false, "🔔 Alert Gaussian Cross", group=group_trend)

group_nw = "Nadaraya-Watson"
nw_h = input.float(8.0, "NW Lookback", minval=3.0, group=group_nw)
nw_r = input.float(8.0, "NW Weighting", step=0.25, group=group_nw)
nw_lag = input.int(2, "NW Lag", group=group_nw)
lenjeje = input.int(32, "NW ATR Period", group=group_nw)
coef = input.float(2.7, "NW Multiplier", group=group_nw)
c_bullish = input.color(#3AFF17, "NW Bull Color", group=group_nw)
c_bearish = input.color(#FD1707, "NW Bear Color", group=group_nw)

group_sess = "Sessions"
s1_t = input.session("0630-1200", "Session 1", group=group_sess)
s2_t = input.session("1400-1800", "Session 2", group=group_sess)
s3_t = input.session("2030-0000", "Session 3", group=group_sess)
s4_t = input.session("0030-0300", "Session 4", group=group_sess)
show_boxes = input.bool(true, "Show Session Boxes", group=group_sess)

group_or = "Opening Range"
or_tf = input.timeframe("15", "OR Timeframe", options=["1", "3", "5", "15", "30", "60", "120", "240"], group=group_or)
or_len = input.int(3, "OR Candle Count", minval=1, maxval=10, group=group_or)

group_fvg = "📦 FVG Order Blocks"
fvg_enable = input.bool(true, "Enable FVG Blocks", group=group_fvg)
fvg_loockback = input.int(2000, "Lookback Period", minval=100, maxval=5000, group=group_fvg)
fvg_filter = input.float(0.5, "Filter Gaps by %", minval=0, maxval=100, step=0.1, group=group_fvg)
fvg_show_imb = input.bool(true, "Show Imbalance Preview", group=group_fvg)
fvg_box_amount = input.int(6, "Max Blocks Display", minval=1, maxval=20, group=group_fvg)
fvg_show_broken = input.bool(false, "Show Broken Blocks", group=group_fvg)
fvg_show_signal = input.bool(true, "Show Entry Signals", group=group_fvg)
fvg_col_bull = input.color(#14be94, "Bull Block Color", group=group_fvg)
fvg_col_bear = input.color(color.rgb(194, 25, 25), "Bear Block Color", group=group_fvg)

// ============================================================================
// 🕯️ CANDLE COLOR ON NW TOUCH
// ============================================================================
group_candle = "🕯️ Candle Color Settings"
enable_candle_color = input.bool(true, "Enable Candle Color", group=group_candle)
candle_upper_color = input.color(color.red, "Color at NW Upper", group=group_candle)
candle_lower_color = input.color(color.green, "Color at NW Lower", group=group_candle)

// ============================================================================
// 🎱 BOUNCE LINE SETTINGS
// ============================================================================
group_bounce = "🎱 Bounce Line"
enable_bounce = input.bool(true, "Enable Bounce Line", group=group_bounce)
bounce_len = input.int(55, "Bounce Length", minval=1, group=group_bounce, tooltip="ความยาวเส้น (แนะนำ 55 สำหรับ Swing)")
bounce_color = input.color(#00FFFF, "Bounce Color", group=group_bounce)

// ============================================================================
// DEMAND/SUPPLY ZONES [PRO Scalper Style]
// ============================================================================
group_ds = "🎯 Demand/Supply Zones"
ds_enable = input.bool(true, "Enable D/S Zones", group=group_ds)
ds_atr_len = input.int(14, "ATR Length", minval=1, group=group_ds)
ds_depth = input.float(0.6, "Zone Depth × ATR", step=0.05, group=group_ds)
ds_extend = input.int(120, "Extend Zones (bars)", minval=10, group=group_ds)
ds_a_left = input.int(10, "Pivot A Left", minval=2, group=group_ds)
ds_a_right = input.int(10, "Pivot A Right", minval=2, group=group_ds)
ds_b_left = input.int(5, "Pivot B Left", minval=2, group=group_ds)
ds_b_right = input.int(5, "Pivot B Right", minval=2, group=group_ds)
ds_show_mid = input.bool(true, "Show Zone Midline", group=group_ds)
ds_only_trend = input.bool(false, "Show Only In-Trend Zones", group=group_ds)
ds_lab_size = input.string("Tiny", "Label Size", options=["Tiny","Small","Normal"], group=group_ds)

// ============================================================================
// CLUSTER VOLUME PROFILE [LuxAlgo Style]
// ============================================================================
group_cluster = "🔷 Cluster Volume Profile"
cluster_enable = input.bool(true, "Enable Cluster VP", group=group_cluster)
cluster_lookback = input.int(200, "Lookback Period", minval=10, maxval=500, group=group_cluster)
cluster_k = input.int(5, "Number of Clusters", minval=2, maxval=10, group=group_cluster)
cluster_iters = input.int(30, "K-Means Iterations", minval=5, maxval=50, group=group_cluster)
cluster_rows = input.int(20, "Rows per Cluster", minval=2, maxval=50, group=group_cluster)
cluster_width = input.int(40, "Max VP Width (Bars)", minval=5, maxval=100, group=group_cluster)
cluster_offset = input.int(10, "VP Offset", group=group_cluster)
cluster_show_poc = input.bool(true, "Show POC Lines", group=group_cluster)
cluster_poc_col = input.color(color.yellow, "POC Line Color", group=group_cluster)

// ============================================================================
// DENSITY ZONES (Subtle)
// ============================================================================
group_den = "🔹 Density Zones"
den_enable = input.bool(true, "Enable Density Zones", group=group_den)
den_metric = input.string("AbsDelta", "Metric", options=["AbsDelta","Volume"], group=group_den)
den_q_len = input.int(200, "Quantile Lookback", minval=50, group=group_den)
den_q_pct = input.float(92, "Quantile %", step=0.5, minval=60, maxval=99.9, group=group_den)
den_depth = input.float(0.45, "Depth × ATR", step=0.05, group=group_den)
den_extend = input.int(150, "Extend (bars)", minval=10, group=group_den)
den_merge_x = input.float(0.30, "Merge if |Δprice| < ×ATR", step=0.05, group=group_den)
den_vol_len = input.int(20, "Volume MA", group=group_den)
den_break_mult = input.float(1.2, "Delete if break vol > MA×", step=0.1, group=group_den)
den_show_mid = input.bool(true, "Show Midline", group=group_den)

// ============================================================================
// CORE CALCULATIONS
// ============================================================================

// MACD
[macd_line, signal_line, macd_hist] = ta.macd(close, fast_len, slow_len, sig_len)

// Gaussian Filter
g_ma = ta.ema(close, g_len)

// Volume Force
calc_volume_force() =>
    bull_vol = close > open ? volume : 0.0
    total_vol = volume
    total_vol > 0 ? bull_vol / total_vol : 0.5
bullPct = calc_volume_force()

// Market Structure
var float last_ph = na
var float last_pl = na
var string current_struct_state = "CHOCH/HOLD"
ph = ta.pivothigh(high, 5, 5)
pl = ta.pivotlow(low, 5, 5)
if not na(ph)
    last_ph := ph
    if ph < last_ph[1]
        current_struct_state := "BOS BEAR"
if not na(pl)
    last_pl := pl
    if pl > last_pl[1]
        current_struct_state := "BOS BULL"

// ATR for zones
ds_atr = ta.atr(ds_atr_len)

// Trend Filter for D/S (EMA + ADX)
tf_minutes() =>
    float m = na
    if timeframe.isseconds
        m := math.max(1.0, timeframe.multiplier) / 60.0
    else if timeframe.isminutes
        m := timeframe.multiplier
    else if timeframe.isdaily
        m := 1440.0 * timeframe.multiplier
    else if timeframe.isweekly
        m := 10080.0 * timeframe.multiplier
    else
        m := 43200.0 * timeframe.multiplier
    m
float tf_min = tf_minutes()

adx_calc(_len) =>
    up_move = high - high[1]
    down_move = low[1] - low
    plus_dm = (up_move > down_move and up_move > 0) ? up_move : 0.0
    minus_dm = (down_move > up_move and down_move > 0) ? down_move : 0.0
    tr = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
    sm_tr = ta.rma(tr, _len)
    sm_p = ta.rma(plus_dm, _len)
    sm_m = ta.rma(minus_dm, _len)
    plus_di = sm_tr != 0 ? 100.0 * sm_p / sm_tr : 0.0
    minus_di = sm_tr != 0 ? 100.0 * sm_m / sm_tr : 0.0
    dx = (plus_di + minus_di != 0) ? 100.0 * math.abs(plus_di - minus_di) / (plus_di + minus_di) : 0.0
    ta.rma(dx, _len)

src_close = use_htf ? request.security(syminfo.tickerid, tf_htf, close) : close
ema_f = ta.ema(src_close, ema_fast_len)
ema_s = ta.ema(src_close, ema_slow_len)
trend_up = ema_f > ema_s
adx_tf = use_htf ? request.security(syminfo.tickerid, tf_htf, adx_calc(adx_len)) : adx_calc(adx_len)

long_ok = trend_mode=="Off" ? true : trend_mode=="EMA" ? trend_up : (trend_up and adx_tf >= adx_thr)
short_ok = trend_mode=="Off" ? true : trend_mode=="EMA" ? not trend_up : ((not trend_up) and adx_tf >= adx_thr)

// Delta proxy for Density zones
rng = math.max(high - low, syminfo.mintick)
d_rw = rng > 0 ? volume * (close - open) / rng : 0
d_cp = close >= close[1] ? volume : -volume
d_co = close >= open ? volume : -volume
delta = den_metric=="RangeWeighted" ? d_rw : den_metric=="CloseVsOpen" ? d_co : d_cp
abs_del = math.abs(delta)

// ============================================================================
// CLUSTER VOLUME PROFILE [K-Means]
// ============================================================================

// Color palette for clusters
var color[] cluster_palette = array.from(#2196f3, #f44336, #4caf50, #ff9800, #9c27b0, #00bcd4, #ffeb3b, #e91e63, #795548, #607d8b)

// K-Means Clustering Function
f_kmeans(int n, int k, int iterations) =>
    float[] prices = array.new_float(0)
    float[] volumes = array.new_float(0)
    float min_p = 1e10, max_p = -1e10
    
    for i = 0 to n - 1
        float p = hl2[i], v = volume[i]
        prices.push(p), volumes.push(v)
        min_p := math.min(min_p, p), max_p := math.max(max_p, p)
            
    float[] centroids = array.new_float(k)
    float step = (max_p - min_p) / (k + 1)
    for i = 0 to k - 1
        centroids.set(i, min_p + (i + 1) * step)
        
    int[] assignments = array.new_int(n)
    for iter = 1 to iterations
        for i = 0 to n - 1
            float p = prices.get(i)
            int best_k = 0
            float min_dist = 1e10
            for j = 0 to k - 1
                float dist = math.abs(p - centroids.get(j))
                if dist < min_dist
                    min_dist := dist, best_k := j
            assignments.set(i, best_k)
            
        float[] sum_pv = array.new_float(k, 0.0), sum_v = array.new_float(k, 0.0)
        for i = 0 to n - 1
            int cluster = assignments.get(i)
            sum_pv.set(cluster, sum_pv.get(cluster) + prices.get(i) * volumes.get(i))
            sum_v.set(cluster, sum_v.get(cluster) + volumes.get(i))
        for j = 0 to k - 1
            if sum_v.get(j) > 0
                centroids.set(j, sum_pv.get(j) / sum_v.get(j))
    
    [assignments, centroids]

// Cluster POC storage
var float[] cluster_pocs = array.new_float()
var box[] cluster_boxes = array.new_box()
var line[] cluster_lines = array.new_line()

// Execute clustering on last bar
if barstate.islast and cluster_enable
    // Clear old elements
    if array.size(cluster_boxes) > 0
        for b in cluster_boxes
            box.delete(b)
        cluster_boxes.clear()
    if array.size(cluster_lines) > 0
        for ln in cluster_lines
            line.delete(ln)
        cluster_lines.clear()
    array.clear(cluster_pocs)
    
    [assignments, centroids] = f_kmeans(cluster_lookback, cluster_k, cluster_iters)
    
    int calc_start = bar_index - cluster_lookback + 1
    int vp_start_x = bar_index + cluster_offset

    for c_id = 0 to cluster_k - 1
        color cluster_color = array.get(cluster_palette, c_id % array.size(cluster_palette))
        
        float[] c_prices = array.new_float(0)
        float[] c_vols = array.new_float(0)
        float[] c_highs = array.new_float(0)
        float[] c_lows = array.new_float(0)
        
        float c_min = 1e10, c_max = -1e10
        float c_total_vol = 0.0
        
        for i = 0 to cluster_lookback - 1
            if array.get(assignments, i) == c_id
                float p = hl2[i], v = volume[i], h = high[i], l = low[i]
                c_prices.push(p), c_vols.push(v), c_highs.push(h), c_lows.push(l)
                c_min := math.min(c_min, l), c_max := math.max(c_max, h)
                c_total_vol += v

        if array.size(c_prices) > 0
            float[] bin_vols = array.new_float(cluster_rows, 0.0)
            float bin_size = (c_max - c_min) / cluster_rows
            if bin_size == 0
                bin_size := syminfo.mintick
                
            for i = 0 to array.size(c_prices) - 1
                float b_h = array.get(c_highs, i), b_l = array.get(c_lows, i), b_v = array.get(c_vols, i)
                float wick_range = math.max(b_h - b_l, syminfo.mintick)
                for b_idx = 0 to cluster_rows - 1
                    float bin_b = c_min + b_idx * bin_size
                    float bin_t = bin_b + bin_size
                    float intersect_l = math.max(b_l, bin_b)
                    float intersect_h = math.min(b_h, bin_t)
                    if intersect_h > intersect_l
                        bin_vols.set(b_idx, array.get(bin_vols, b_idx) + b_v * (intersect_h - intersect_l) / wick_range)
                
            float max_bin_vol = array.max(bin_vols)
            int poc_bin_idx = array.indexof(bin_vols, max_bin_vol)
            
            if poc_bin_idx >= 0
                float poc_y = c_min + (poc_bin_idx + 0.5) * bin_size
                array.push(cluster_pocs, poc_y)
                
                if cluster_show_poc
                    cluster_lines.push(line.new(calc_start, poc_y, vp_start_x, poc_y, color = cluster_poc_col, width = 1, style = line.style_dashed))
            
            // Create volume profile boxes
            for b_idx = 0 to cluster_rows - 1
                if array.size(cluster_boxes) >= 500
                    break
                float vol = array.get(bin_vols, b_idx)
                if vol == 0
                    continue
                float b_bottom = c_min + b_idx * bin_size
                float b_top = b_bottom + bin_size
                int b_width = int((vol / max_bin_vol) * cluster_width)
                int end_x = vp_start_x + b_width
                bool is_poc = b_idx == poc_bin_idx
                color b_color = is_poc ? cluster_color : color.new(cluster_color, 75)
                
                cluster_boxes.push(box.new(vp_start_x, b_top, end_x, b_bottom, bgcolor = b_color, border_color = is_poc ? cluster_color : #00000000))

// ============================================================================
// DEMAND/SUPPLY ZONES LOGIC
// ============================================================================

type ZoneState
    box z_box
    float z_top
    float z_bot
    line z_mid
    int z_touches
    bool z_in_prev
    label z_label

mk_zone(_left, _top, _bot, is_supply, _right, in_trend) =>
    color fill = is_supply ? (in_trend ? color.new(#E57373, 76) : color.new(#E57373, 96)) : (in_trend ? color.new(#81C784, 76) : color.new(#81C784, 96))
    color brd = is_supply ? (in_trend ? color.new(#E57373, 25) : color.new(#E57373, 90)) : (in_trend ? color.new(#81C784, 25) : color.new(#81C784, 90))
    box.new(_left, _top, _right, _bot, xloc=xloc.bar_index, bgcolor=fill, border_color=brd)

make_midline(x0, mid) =>
    line.new(x0, mid, x0 + ds_extend, mid, xloc=xloc.bar_index, extend=extend.none, style=line.style_dashed, color=color.new(color.gray, 50), width=1)

update_zone(pivot_val, is_supply, left, right, ZoneState zs, string tag) =>
    ZoneState ret = zs
    if ds_enable and not na(pivot_val)
        float top = is_supply ? pivot_val : pivot_val + ds_depth * ds_atr
        float bot = is_supply ? pivot_val - ds_depth * ds_atr : pivot_val
        int x0 = bar_index - right
        if not na(zs.z_box)
            box.delete(zs.z_box)
        if not na(zs.z_mid)
            line.delete(zs.z_mid)
        bool in_trend = is_supply ? short_ok : long_ok
        ret.z_box := mk_zone(x0, top, bot, is_supply, bar_index + ds_extend, in_trend)
        if ds_show_mid
            ret.z_mid := make_midline(x0, (top + bot) * 0.5)
        ret.z_touches := 0
        ret.z_in_prev := false
        if not na(zs.z_label)
            label.delete(zs.z_label)
        string txt = is_supply ? "SUP " + tag : "DEM " + tag
        ret.z_label := label.new(x0, is_supply ? top : bot, txt + " (0)", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, size=ds_lab_size=="Tiny"?size.tiny:ds_lab_size=="Small"?size.small:size.normal, color=color.new(color.black, 100), textcolor=color.white)
        ret.z_top := top
        ret.z_bot := bot
    
    if not na(ret.z_box) and ds_enable
        bool in_trend = is_supply ? short_ok : long_ok
        if ds_only_trend and not in_trend
            box.set_bgcolor(ret.z_box, color.new(color.white, 100))
            box.set_border_color(ret.z_box, color.new(color.white, 100))
            if not na(ret.z_label)
                label.delete(ret.z_label)
                ret.z_label := na
            if not na(ret.z_mid)
                line.delete(ret.z_mid)
                ret.z_mid := na
        else
            color fill = is_supply ? (in_trend ? color.new(#E57373, 76) : color.new(#E57373, 96)) : (in_trend ? color.new(#81C784, 76) : color.new(#81C784, 96))
            color brd = is_supply ? (in_trend ? color.new(#E57373, 25) : color.new(#E57373, 90)) : (in_trend ? color.new(#81C784, 25) : color.new(#81C784, 90))
            box.set_bgcolor(ret.z_box, fill)
            box.set_border_color(ret.z_box, brd)
            if ds_show_mid and na(ret.z_mid)
                ret.z_mid := make_midline(box.get_left(ret.z_box), (ret.z_top + ret.z_bot) * 0.5)
            if na(ret.z_label)
                string txt = is_supply ? "SUP " + tag : "DEM " + tag
                ret.z_label := label.new(box.get_left(ret.z_box), is_supply ? ret.z_top : ret.z_bot, txt + " (" + str.tostring(ret.z_touches) + ")", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, size=ds_lab_size=="Tiny"?size.tiny:ds_lab_size=="Small"?size.small:size.normal, color=color.new(color.black, 100), textcolor=color.white)
    
    if not na(ret.z_top) and not na(ret.z_bot) and ds_enable
        bool in_zone = high >= ret.z_bot and low <= ret.z_top
        if in_zone and not ret.z_in_prev
            ret.z_touches := ret.z_touches + 1
        ret.z_in_prev := in_zone
    
    if not na(ret.z_label) and ds_enable
        string txt = is_supply ? "SUP " + tag : "DEM " + tag
        label.set_text(ret.z_label, txt + " (" + str.tostring(ret.z_touches) + ")")
    
    ret

var ZoneState sup_a = ZoneState.new(na, na, na, na, 0, false, na)
var ZoneState dem_a = ZoneState.new(na, na, na, na, 0, false, na)
var ZoneState sup_b = ZoneState.new(na, na, na, na, 0, false, na)
var ZoneState dem_b = ZoneState.new(na, na, na, na, 0, false, na)

ph_a = ta.pivothigh(high, ds_a_left, ds_a_right)
pl_a = ta.pivotlow(low, ds_a_left, ds_a_right)
sup_a := update_zone(ph_a, true, ds_a_left, ds_a_right, sup_a, "A")
dem_a := update_zone(pl_a, false, ds_a_left, ds_a_right, dem_a, "A")

ph_b = ta.pivothigh(high, ds_b_left, ds_b_right)
pl_b = ta.pivotlow(low, ds_b_left, ds_b_right)
sup_b := update_zone(ph_b, true, ds_b_left, ds_b_right, sup_b, "B")
dem_b := update_zone(pl_b, false, ds_b_left, ds_b_right, dem_b, "B")

extend_box(_b) =>
    if not na(_b) and ds_enable
        box.set_right(_b, bar_index + ds_extend)

extend_line(_l, y) =>
    if not na(_l) and ds_enable
        line.set_x2(_l, bar_index + ds_extend)
        line.set_y1(_l, y)
        line.set_y2(_l, y)

if ds_enable
    extend_box(sup_a.z_box), extend_box(dem_a.z_box), extend_box(sup_b.z_box), extend_box(dem_b.z_box)
    extend_line(sup_a.z_mid, na(sup_a.z_top) or na(sup_a.z_bot) ? na : (sup_a.z_top + sup_a.z_bot)*0.5)
    extend_line(dem_a.z_mid, na(dem_a.z_top) or na(dem_a.z_bot) ? na : (dem_a.z_top + dem_a.z_bot)*0.5)
    extend_line(sup_b.z_mid, na(sup_b.z_top) or na(sup_b.z_bot) ? na : (sup_b.z_top + sup_b.z_bot)*0.5)
    extend_line(dem_b.z_mid, na(dem_b.z_top) or na(dem_b.z_bot) ? na : (dem_b.z_top + dem_b.z_bot)*0.5)

// ============================================================================
// DENSITY ZONES LOGIC
// ============================================================================

den_thr = den_enable ? ta.percentile_linear_interpolation(den_metric=="AbsDelta"?abs_del:volume, den_q_len, den_q_pct) : na
vol_ma = ta.sma(volume, den_vol_len)

var array<box> den_boxes = array.new<box>()
var array<line> den_lines = array.new<line>()
var array<float> den_tops = array.new<float>()
var array<float> den_bots = array.new<float>()
var array<float> den_mids = array.new<float>()
var array<int> den_ends = array.new<int>()
var array<int> den_dirs = array.new<int>()

new_density(mid, is_demand) =>
    float half = ds_atr * den_depth
    float top = mid + half
    float bot = mid - half
    color fill_col = is_demand ? color.new(#4CAF50, 90) : color.new(#F44336, 90)
    color brd_col = is_demand ? color.new(#4CAF50, 60) : color.new(#F44336, 60)
    box b = box.new(bar_index, top, bar_index, bot, xloc=xloc.bar_index, bgcolor=fill_col, border_color=brd_col)
    line ln = na
    if den_show_mid and den_enable
        ln := line.new(bar_index, mid, bar_index, mid, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.gray, 50), style=line.style_dashed, width=1)
    array.push(den_boxes, b)
    array.push(den_lines, ln)
    array.push(den_tops, top)
    array.push(den_bots, bot)
    array.push(den_mids, mid)
    array.push(den_ends, bar_index + den_extend)
    array.push(den_dirs, is_demand ? 1 : -1)

if den_enable and not na(den_thr) and (den_metric=="AbsDelta"?abs_del:volume) >= den_thr
    mid = close
    bool merged = false
    sz = array.size(den_boxes)
    if sz > 0
        for i = 0 to sz - 1
            if not merged and math.abs(mid - array.get(den_mids, i)) <= ds_atr * den_merge_x
                array.set(den_ends, i, bar_index + den_extend)
                merged := true
    if not merged
        new_density(mid, delta >= 0)

if den_enable and array.size(den_boxes) > 0
    sz2 = array.size(den_boxes)
    for i = sz2 - 1 to 0
        b = array.get(den_boxes, i)
        ln = array.get(den_lines, i)
        top = array.get(den_tops, i)
        bot = array.get(den_bots, i)
        mid = array.get(den_mids, i)
        right = math.min(bar_index + 1, array.get(den_ends, i))
        box.set_right(b, right)
        if not na(ln)
            line.set_x2(ln, right)
            line.set_y1(ln, mid)
            line.set_y2(ln, mid)
        dir = array.get(den_dirs, i)
        bool break_up = close > top and volume > vol_ma * den_break_mult
        bool break_down = close < bot and volume > vol_ma * den_break_mult
        bool eaten = (dir == 1 and break_down) or (dir == -1 and break_up)
        if eaten or bar_index >= array.get(den_ends, i)
            box.delete(b)
            if not na(ln)
                line.delete(ln)
            array.remove(den_boxes, i)
            array.remove(den_lines, i)
            array.remove(den_tops, i)
            array.remove(den_bots, i)
            array.remove(den_mids, i)
            array.remove(den_ends, i)
            array.remove(den_dirs, i)

// ============================================================================
// FVG ORDER BLOCKS [BigBeluga] - INTEGRATED
// ============================================================================

var array<box> fvg_boxes_bull = array.new<box>()
var array<box> fvg_boxes_bear = array.new<box>()
var box fvg_box1 = na
var box fvg_box2 = na
var bool fvg_isBull_gap = false
var bool fvg_isBear_gap = false

fvg_atr = ta.atr(200)
fvg_filt_up = (low - high[2]) / low * 100
fvg_filt_dn = (low[2] - high) / low[2] * 100
fvg_max_up = ta.highest(fvg_filt_up, 200)
fvg_max_dn = ta.highest(fvg_filt_dn, 200)

if barstate.isconfirmed and last_bar_index - bar_index < fvg_loockback
    fvg_isBull_gap := high[2] < low and high[2] < high[1] and low[2] < low and fvg_filt_up > fvg_filter
    fvg_isBear_gap := low[2] > high and low[2] > low[1] and high[2] > high and fvg_filt_dn > fvg_filter

if fvg_enable and fvg_isBull_gap
    if fvg_show_imb
        box.new(bar_index-1, low, bar_index + 5, high[2], na, 0, 
             bgcolor = color.from_gradient(fvg_filt_up, 0, fvg_max_up, color.new(chart.fg_color, 90), color.new(chart.fg_color, 70)),
             text = str.tostring(fvg_filt_up, format.percent),
             text_color = chart.fg_color)
    fvg_box1 := box.new(bar_index-1, high[2], last_bar_index, high[2] - fvg_atr, fvg_col_bull, 1, 
                 bgcolor = color.from_gradient(fvg_filt_up, 0, fvg_max_up, na, color.new(fvg_col_bull, 70)), 
                 text = str.tostring(fvg_filt_up, format.percent), 
                 text_size = size.small,
                 text_color = chart.fg_color, 
                 text_halign = text.align_right)
    array.push(fvg_boxes_bull, fvg_box1)

if fvg_enable and fvg_isBear_gap
    if fvg_show_imb
        box.new(bar_index-1, low[2], bar_index + 5, high, na, 0,
             bgcolor = color.from_gradient(fvg_filt_dn, 0, fvg_max_dn, color.new(chart.fg_color, 90), color.new(chart.fg_color, 70)),
             text = "-"+str.tostring(fvg_filt_dn, format.percent),
             text_color = chart.fg_color)
    fvg_box2 := box.new(bar_index-1, low[2] + fvg_atr, last_bar_index, low[2], fvg_col_bear, 1,
                 bgcolor = color.from_gradient(fvg_filt_dn, 0, fvg_max_dn, na, color.new(fvg_col_bear, 70)),
                 text = str.tostring(fvg_filt_dn, format.percent),
                 text_size = size.small,
                 text_color = chart.fg_color, 
                 text_halign = text.align_right)
    array.push(fvg_boxes_bear, fvg_box2)

if barstate.islast and fvg_enable
    for fvg_bid in fvg_boxes_bull
        box.set_right(fvg_bid, bar_index + 15)
    for fvg_bid in fvg_boxes_bear
        box.set_right(fvg_bid, bar_index + 15)

if fvg_enable
    for fvg_bid in fvg_boxes_bull
        if high < box.get_bottom(fvg_bid)
            box.set_border_width(fvg_bid, 0)
            box.set_bgcolor(fvg_bid, color.new(chart.fg_color, 85))
            if not fvg_show_broken
                box.delete(fvg_bid)
                if array.includes(fvg_boxes_bull, fvg_bid)
                    array.remove(fvg_boxes_bull, array.indexof(fvg_boxes_bull, fvg_bid))
        if low > box.get_top(fvg_bid) and low[1] <= box.get_top(fvg_bid) and not fvg_isBull_gap and fvg_show_signal
            label.new(bar_index-1, low[1], "︽", color = color(na), textcolor = fvg_col_bull, style = label.style_label_up, size=size.tiny)
        for fvg_bid1 in fvg_boxes_bull
            if box.get_top(fvg_bid1) < box.get_top(fvg_bid) and box.get_top(fvg_bid1) > box.get_bottom(fvg_bid)
                box.delete(fvg_bid)
                if array.includes(fvg_boxes_bull, fvg_bid)
                    array.remove(fvg_boxes_bull, array.indexof(fvg_boxes_bull, fvg_bid))
                break
    for fvg_bid in fvg_boxes_bear
        if low > box.get_top(fvg_bid)
            box.set_border_width(fvg_bid, 0)
            box.set_bgcolor(fvg_bid, color.new(chart.fg_color, 85))
            if not fvg_show_broken
                box.delete(fvg_bid)
                if array.includes(fvg_boxes_bear, fvg_bid)
                    array.remove(fvg_boxes_bear, array.indexof(fvg_boxes_bear, fvg_bid))
        if high < box.get_bottom(fvg_bid) and high[1] >= box.get_bottom(fvg_bid) and not fvg_isBear_gap and fvg_show_signal
            label.new(bar_index-1, high[1], "﹀", color = color(na), textcolor = fvg_col_bear, style = label.style_label_down, size=size.tiny)
        for fvg_bid1 in fvg_boxes_bear
            if box.get_top(fvg_bid1) < box.get_top(fvg_bid) and box.get_top(fvg_bid1) > box.get_bottom(fvg_bid)
                box.delete(fvg_bid)
                if array.includes(fvg_boxes_bear, fvg_bid)
                    array.remove(fvg_boxes_bear, array.indexof(fvg_boxes_bear, fvg_bid))
                break

if array.size(fvg_boxes_bull) >= fvg_box_amount
    if array.size(fvg_boxes_bull) > 0
        box.delete(array.shift(fvg_boxes_bull))
if array.size(fvg_boxes_bear) >= fvg_box_amount
    if array.size(fvg_boxes_bear) > 0
        box.delete(array.shift(fvg_boxes_bear))

// ============================================================================
// NADARAYA-WATSON (Safe Array Logic)
// ============================================================================

var float[] nw_history = array.new<float>(0)
if barstate.isconfirmed
    array.push(nw_history, close)
    if array.size(nw_history) > 500
        array.shift(nw_history)

kernel_reg(_h) =>
    float curr_w = 0.0
    float cum_w = 0.0
    int size = array.size(nw_history)
    float result = close
    if size > 0
        int limit = math.min(size, 100)
        for i = 0 to limit - 1
            int idx = size - 1 - i
            if idx >= 0 and idx < size
                float y = array.get(nw_history, idx)
                float w = math.pow(1 + (math.pow(i, 2) / (math.pow(_h, 2) * 2 * nw_r)), -nw_r)
                curr_w += y * w
                cum_w += w
        result := cum_w > 0 ? curr_w / cum_w : close
    result

yhat1 = kernel_reg(nw_h)
yhat2 = kernel_reg(math.max(0.5, nw_h - nw_lag))
isBullish = yhat1 > yhat1[1]
upper_nw = yhat1 + coef * ta.atr(lenjeje)
lower_nw = yhat1 - coef * ta.atr(lenjeje)

plot(yhat1, "NW Middle", color=isBullish ? c_bullish : c_bearish, linewidth=2)
plot(upper_nw, "NW Upper", color=color.green, linewidth=1)
plot(lower_nw, "NW Lower", color=color.red, linewidth=1)
// Gaussian Filter Plot
plot(show_gaussian ? g_ma : na, "Gaussian Filter", color=gaussian_color, linewidth=2)

// ============================================================================
// 🎱 BOUNCE LINE CALCULATION (Hull Moving Average)
// ============================================================================

// ฟังก์ชันคำนวณ HMA
f_hma(src, len) =>
    _wma1 = ta.wma(src, math.round(len / 2))
    _wma2 = ta.wma(src, len)
    _raw_hma = 2 * _wma1 - _wma2
    _hma = ta.wma(_raw_hma, math.round(math.sqrt(len)))

bounce_line = f_hma(close, bounce_len)

// พล็อตเส้นลงบนกราฟ
plot(enable_bounce ? bounce_line : na, "Bounce Line", color=bounce_color, linewidth=2, style=plot.style_line)

// ============================================================================
// SESSIONS & OPENING RANGE (Dashed & Multi-TF)
// ============================================================================

f_sess(t) => not na(time(timeframe.period, t, "Asia/Bangkok"))
in1 = f_sess(s1_t)
in2 = f_sess(s2_t)
in3 = f_sess(s3_t)
in4 = f_sess(s4_t)

var box b1 = na
if show_boxes and in1
    if not in1[1]
        b1 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.yellow, 95), border_color=color.yellow, border_style=line.style_dashed)
    else
        box.set_right(b1, bar_index)
        box.set_top(b1, math.max(box.get_top(b1), high))
        box.set_bottom(b1, math.min(box.get_bottom(b1), low))

var box b2 = na
if show_boxes and in2
    if not in2[1]
        b2 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.blue, 95), border_color=color.blue, border_style=line.style_dashed)
    else
        box.set_right(b2, bar_index)
        box.set_top(b2, math.max(box.get_top(b2), high))
        box.set_bottom(b2, math.min(box.get_bottom(b2), low))

var box b3 = na
if show_boxes and in3
    if not in3[1]
        b3 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.red, 95), border_color=color.red, border_style=line.style_dashed)
    else
        box.set_right(b3, bar_index)
        box.set_top(b3, math.max(box.get_top(b3), high))
        box.set_bottom(b3, math.min(box.get_bottom(b3), low))

var box b4 = na
if show_boxes and in4
    if not in4[1]
        b4 := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.purple, 95), border_color=color.purple, border_style=line.style_dashed)
    else
        box.set_right(b4, bar_index)
        box.set_top(b4, math.max(box.get_top(b4), high))
        box.set_bottom(b4, math.min(box.get_bottom(b4), low))

f_or_calc(in_sess, length) =>
    var float h = na
    var float l = na
    var int count = 0
    if in_sess and not in_sess[1]
        h := high
        l := low
        count := 1
    else if in_sess and count < length
        h := math.max(h, high)
        l := math.min(l, low)
        count := count + 1
    [h, l]

[h1, l1] = request.security(syminfo.tickerid, or_tf, f_or_calc(in1, or_len))
[h2, l2] = request.security(syminfo.tickerid, or_tf, f_or_calc(in2, or_len))
[h3, l3] = request.security(syminfo.tickerid, or_tf, f_or_calc(in3, or_len))
[h4, l4] = request.security(syminfo.tickerid, or_tf, f_or_calc(in4, or_len))

plot(in1 ? h1 : na, "S1 OR High", color=color.yellow, style=plot.style_linebr, linewidth=2)
plot(in1 ? l1 : na, "S1 OR Low", color=color.yellow, style=plot.style_linebr, linewidth=2)
plot(in2 ? h2 : na, "S2 OR High", color=color.blue, style=plot.style_linebr, linewidth=2)
plot(in2 ? l2 : na, "S2 OR Low", color=color.blue, style=plot.style_linebr, linewidth=2)
plot(in3 ? h3 : na, "S3 OR High", color=color.red, style=plot.style_linebr, linewidth=2)
plot(in3 ? l3 : na, "S3 OR Low", color=color.red, style=plot.style_linebr, linewidth=2)
plot(in4 ? h4 : na, "S4 OR High", color=color.purple, style=plot.style_linebr, linewidth=2)
plot(in4 ? l4 : na, "S4 OR Low", color=color.purple, style=plot.style_linebr, linewidth=2)

// ============================================================================
// STRICT MODE FILTERS & SIGNALS
// ============================================================================

// Check if price is near cluster POC
check_cluster_confluence() =>
    bool in_cluster = false
    if cluster_enable and array.size(cluster_pocs) > 0
        for poc in cluster_pocs
            if math.abs(close - poc) <= ds_atr * 0.5
                in_cluster := true
                break
    in_cluster

check_confluence(is_bull) =>
    int score = 0
    if is_bull
        score += close > g_ma ? 1 : 0
        score += macd_line > signal_line ? 1 : 0
        score += bullPct > bull_thresh ? 1 : 0
        if not na(dem_a.z_bot) and close >= dem_a.z_bot and close <= dem_a.z_top
            score += 1
        else if not na(dem_b.z_bot) and close >= dem_b.z_bot and close <= dem_b.z_top
            score += 1
        // Cluster bonus
        if check_cluster_confluence()
            score += 1
    else
        score += close < g_ma ? 1 : 0
        score += macd_line < signal_line ? 1 : 0
        score += bullPct < bear_thresh ? 1 : 0
        if not na(sup_a.z_top) and close >= sup_a.z_bot and close <= sup_a.z_top
            score += 1
        else if not na(sup_b.z_top) and close >= sup_b.z_bot and close <= sup_b.z_top
            score += 1
        // Cluster bonus
        if check_cluster_confluence()
            score += 1
    score

vol_ratio = ta.sma(volume, 20) > 0 ? volume / ta.sma(volume, 20) : 1.0
vol_ok = vol_ratio >= vol_filter_val
dist_pct = math.abs(close - g_ma) / g_ma * 100
dist_ok = dist_pct <= dist_filter_pct
atr_curr = ta.atr(14)
atr_avg = ta.sma(atr_curr, 50)
chop_ok = avoid_chop ? (atr_curr >= atr_avg * 0.7) : true

raw_bull_sig = ta.crossover(macd_line, signal_line) and close > g_ma and bullPct > bull_thresh
raw_bear_sig = ta.crossunder(macd_line, signal_line) and close < g_ma and bullPct < bear_thresh

bull_score = check_confluence(true)
bear_score = check_confluence(false)

bull_sig = strict_mode ? (raw_bull_sig and bull_score >= min_confluence and vol_ok and dist_ok and chop_ok) : raw_bull_sig
bear_sig = strict_mode ? (raw_bear_sig and bear_score >= min_confluence and vol_ok and dist_ok and chop_ok) : raw_bear_sig

sfp_bull = low < last_pl and close > last_pl and bullPct > shark_bull
sfp_bear = high > last_ph and close < last_ph and bullPct < shark_bear

plotshape(bull_sig, "Bull", shape.labelup, location.belowbar, color.green, text="🐂", size=size.tiny)
plotshape(bear_sig, "Bear", shape.labeldown, location.abovebar, color.red, text="🐻", size=size.tiny)
plotshape(sfp_bull, "Shark Bull", shape.labelup, location.belowbar, color.orange, text="🦈", size=size.tiny)
plotshape(sfp_bear, "Shark Bear", shape.labeldown, location.abovebar, color.orange, text="🦈", size=size.tiny)

// ============================================================================
// DASHBOARD
// ============================================================================

var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 20), border_color=color.gray)

if barstate.islast
    table.cell(dash, 0, 0, "PAN SNIPER V16.0", text_color=color.white, bgcolor=color.blue)
    table.cell(dash, 1, 0, "CLUSTER VP", text_color=color.lime, bgcolor=color.new(color.green, 70))
    table.cell(dash, 0, 1, "MACD", text_color=color.white)
    table.cell(dash, 1, 1, macd_line > signal_line ? "BULL" : "BEAR", text_color=macd_line > signal_line ? color.green : color.red)
    table.cell(dash, 0, 2, "Gaussian", text_color=color.white)
    table.cell(dash, 1, 2, close > g_ma ? "ABOVE" : "BELOW", text_color=close > g_ma ? color.green : color.red)
    table.cell(dash, 0, 3, "Volume", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(bullPct * 100, "#.##") + "%", text_color=bullPct > 0.5 ? color.green : color.red)
    table.cell(dash, 0, 4, "Structure", text_color=color.white)
    table.cell(dash, 1, 4, current_struct_state, text_color=color.orange)
    table.cell(dash, 0, 5, "Trend Filter", text_color=color.white)
    table.cell(dash, 1, 5, trend_mode=="Off" ? "OFF" : trend_up ? "BULL" : "BEAR", text_color=trend_mode=="Off"?color.gray:trend_up?color.green:color.red)
    if strict_mode
        table.cell(dash, 0, 6, "Bull Score", text_color=color.white)
        table.cell(dash, 1, 6, str.tostring(bull_score) + "/5", text_color=color.lime)
        table.cell(dash, 0, 7, "Bear Score", text_color=color.white)
        table.cell(dash, 1, 7, str.tostring(bear_score) + "/5", text_color=color.red)
    table.cell(dash, 0, 8, "In Zone?", text_color=color.white)
    in_zone_txt = (not na(dem_a.z_bot) and close >= dem_a.z_bot and close <= dem_a.z_top) ? "DEM-A" : 
                  (not na(sup_a.z_top) and close >= sup_a.z_bot and close <= sup_a.z_top) ? "SUP-A" :
                  (not na(dem_b.z_bot) and close >= dem_b.z_bot and close <= dem_b.z_top) ? "DEM-B" :
                  (not na(sup_b.z_top) and close >= sup_b.z_bot and close <= sup_b.z_top) ? "SUP-B" : "NONE"
    table.cell(dash, 1, 8, in_zone_txt, text_color=in_zone_txt=="NONE"?color.gray:in_zone_txt[0]=="D"?color.green:color.red)
    table.cell(dash, 0, 9, "Near POC?", text_color=color.white)
    near_poc = check_cluster_confluence()
    table.cell(dash, 1, 9, near_poc ? "YES" : "NO", text_color=near_poc?color.yellow:color.gray)

// ============================================================================
// ALERTS (Essential Only)
// ============================================================================
alertcondition(bull_sig, "Strict Bull", "Bull Signal Confirmed")
alertcondition(bear_sig, "Strict Bear", "Bear Signal Confirmed")
alertcondition(sfp_bull, "Shark Bull", "Shark Sweep Bull")
alertcondition(sfp_bear, "Shark Bear", "Shark Sweep Bear")
alertcondition(ta.cross(close, yhat1), "NW Middle Cross", "Price crossed NW Middle")
alertcondition(ta.cross(close, upper_nw), "NW Upper Cross", "Price crossed NW Upper")
alertcondition(ta.cross(close, lower_nw), "NW Lower Cross", "Price crossed NW Lower")
alertcondition(ta.cross(high, last_ph), "Pivot High Break", "Price broke Last Pivot High")
alertcondition(ta.cross(low, last_pl), "Pivot Low Break", "Price broke Last Pivot Low")
alertcondition(not na(sup_a.z_box) and ta.cross(low, sup_a.z_bot), "SUP-A Break", "Supply Zone A Broken")
alertcondition(not na(dem_a.z_box) and ta.cross(high, dem_a.z_top), "DEM-A Break", "Demand Zone A Broken")
alertcondition(not na(sup_b.z_box) and ta.cross(low, sup_b.z_bot), "SUP-B Break", "Supply Zone B Broken")
alertcondition(not na(dem_b.z_box) and ta.cross(high, dem_b.z_top), "DEM-B Break", "Demand Zone B Broken")
// 🔔 Gaussian Cross Alerts
gauss_bull_cross = ta.crossover(close, g_ma)
gauss_bear_cross = ta.crossunder(close, g_ma)

if enable_gauss_alert and gauss_bull_cross
    alert("🟢 GAUSSIAN CROSS UP\nPrice: " + str.tostring(close, "#.####") + "\nTF: " + timeframe.period, alert.freq_once_per_bar_close)

if enable_gauss_alert and gauss_bear_cross
    alert("🔴 GAUSSIAN CROSS DOWN\nPrice: " + str.tostring(close, "#.####") + "\nTF: " + timeframe.period, alert.freq_once_per_bar_close)

// ============================================================================
// 🕯️ CANDLE COLOR LOGIC
// ============================================================================
// คำนวณ NW Bands จากตัวแปรเดิมของ Pan Sniper
nw_upper = yhat1 + coef * ta.atr(lenjeje)
nw_lower = yhat1 - coef * ta.atr(lenjeje)

// ตรวจสอบการแตะเส้น
touch_upper = high >= nw_upper
touch_lower = low <= nw_lower

// กำหนดสีแท่งเทียน
candle_col = enable_candle_color ? (touch_upper ? candle_upper_color : touch_lower ? candle_lower_color : na) : na

// ระบายสี
barcolor(candle_col, title="NW Touch Color")
````

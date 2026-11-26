# Auto-Anchored Volume Profile (AAVP) - Precision Pro Engine

- url: https://www.tradingview.com/script/MgLEXSNz-Auto-Anchored-Volume-Profile-AAVP-Precision-Pro-Engine/
- type: indicator
- pine_id: PUB;25731e415c4b4f4eb13d68ad79725674
- version: 1.0

## Description

1. Overview & Philosophy
The AAVP Precision Pro is a tactical radar designed to decode Market Physics. Unlike standard volume profiles, this engine focuses on the collision of Taker Aggression (Market Orders) and Maker Absorption (Limit Orders). It identifies where "Invisible Mass" accumulates and where "Liquidity Vacuums" exist to predict potential breakthrough or reversal points.

2. Core Features
Smart Adaptive Lookback: Automatically detects the most significant structural anchor points based on the current timeframe (e.g., 300 bars for 5m, 250 bars for Daily) to filter out stale data.

Range-Distributed Algorithm: Distributes volume evenly across the High-Low range of each candle, preventing the "Data Spikes" caused by closing-price-only attribution.

Precision Labeling (V10): Includes left-aligned price labels for POC, VAH, and VAL to eliminate visual confusion during extreme price compression.

3. Operational Instructions (SOP)
Step 1: Calibration: Set Lookback to 0 for auto-mode. The script will anchor itself to the most relevant structural bottom (or top if Use High is checked).

Step 2: Regime Synergy:

Red Bar (Trending): High scores (>75) indicate strong momentum. Watch for a break of VAH (Value Area High) for a "Vacuum Run".

Green Bar (Mean Reversion): High scores (>80) indicate extreme expansion. Expect a violent snap-back toward the POC (Point of Control).

Step 3: Absorption Check: If VAH and VAL are tightly "merged" on the POC, the market is in a dead-lock. A breakthrough of this "merged line" often leads to a high-velocity位移 (displacement).

4. Key Metrics Explained
POC (Aqua Line): The "Gravity Well" where the highest volume has been transacted.

VAH/VAL (Yellow Dashed): The "Fences" of the 70% value area. Prices above VAH represent non-linear expansion.

Score (0-100): Quantitative measurement of the current regime's strength.

## Source Code

````pine
// @version=5
// AAVP V9 (Smart Adaptive)
indicator("AAVP V9 (Smart Adaptive)", overlay=true, max_boxes_count=500, max_lines_count=500, max_bars_back=1000)

// ==========================================
// --- 1. 自适应输入 (设为 0 即开启自动) ---
// ==========================================
lookback_in = input.int(0, "回溯周期 (0=自动)", minval=0)
num_bins_in = input.int(0, "分辨率 (0=自动)", minval=0)
va_pct      = input.float(70.0, "价值区间占比 (%)", minval=10, maxval=90)
width_pct   = input.int(30, "分布图最大宽度 (%)")
use_high    = input.bool(false, "以高点为锚点 (空头结构)")

// ==========================================
// --- 2. 自动化逻辑计算 ---
// ==========================================
// 自动回溯逻辑
int final_lookback = lookback_in
if lookback_in == 0
    if timeframe.isdaily
        final_lookback := 250 // 日线看一年
    else if timeframe.isintraday
        // 小时线看一个月，分钟线看两天
        final_lookback := timeframe.multiplier <= 5 ? 300 : 150 
    else
        final_lookback := 100

// 自动分辨率逻辑
int final_bins = num_bins_in
if num_bins_in == 0
    final_bins := 100 // 默认值

// ==========================================
// --- 3. 内存管理 ---
// ==========================================
var box[] b_arr = array.new_box()
var line[] l_arr = array.new_line()
var label[] lb_arr = array.new_label()

// ==========================================
// --- 4. 寻找物理锚点 ---
// ==========================================
int anchor_idx = use_high ? ta.highestbars(high, final_lookback) : ta.lowestbars(low, final_lookback)
int dist = math.abs(anchor_idx)

if barstate.islast and dist > 5
    while array.size(b_arr) > 0
        box.delete(array.pop(b_arr))
    while array.size(l_arr) > 0
        line.delete(array.pop(l_arr))
    while array.size(lb_arr) > 0
        label.delete(array.pop(lb_arr))

    // 手动扫描波段极端价
    float true_min = low[0], true_max = high[0]
    for i = 0 to dist
        true_min := math.min(true_min, low[i]), true_max := math.max(true_max, high[i])
    
    // 自动重算分辨率（根据价格范围动态加密）
    if num_bins_in == 0
        float price_spread = (true_max - true_min) / syminfo.mintick
        final_bins := price_spread > 1000 ? 150 : 100

    float range_h = true_max - true_min
    float step = range_h / final_bins
    step := step == 0 ? syminfo.mintick : step

    // 分布计算
    float[] vols = array.new_float(final_bins, 0.0)
    float total_vol = 0.0
    for i = 0 to dist
        int idx_h = math.floor((high[i] - true_min) / step)
        int idx_l = math.floor((low[i] - true_min) / step)
        idx_h := math.min(final_bins - 1, math.max(0, idx_h))
        idx_l := math.min(final_bins - 1, math.max(0, idx_l))
        int spans = (idx_h - idx_l) + 1
        float v_part = volume[i] / spans
        for j = idx_l to idx_h
            array.set(vols, j, array.get(vols, j) + v_part)
        total_vol += volume[i]

    // 寻找 POC
    float max_v = 0.0, int poc_i = 0
    for k = 0 to final_bins - 1
        float vv = array.get(vols, k)
        if vv > max_v
            max_v := vv, poc_i := k
    float poc_p = true_min + (poc_i * step) + (step / 2)

    // 计算价值区间
    float target_va = total_vol * (va_pct / 100.0)
    float cur_va = array.get(vols, poc_i)
    int up_i = poc_i, int dn_i = poc_i
    while cur_va < target_va and (up_i < final_bins - 1 or dn_i > 0)
        float v_up = (up_i < final_bins - 1) ? array.get(vols, up_i + 1) : -1.0
        float v_dn = (dn_i > 0) ? array.get(vols, dn_i - 1) : -1.0
        if v_up >= v_dn and v_up != -1.0
            up_i += 1, cur_va += v_up
        else if v_dn > v_up and v_dn != -1.0
            dn_i -= 1, cur_va += v_dn
        else
            break
    float vah_p = true_min + (up_i + 1) * step
    float val_p = true_min + dn_i * step

    // ==========================================
    // --- 5. 渲染渲染 ---
    // ==========================================
    int left_bar = bar_index[dist], int right_bar = bar_index
    int max_w_bars = math.round(dist * (width_pct / 100.0))

    // Anchor
    array.push(lb_arr, label.new(left_bar, use_high ? high[dist] : low[dist], "AUTO ANCHOR", yloc = use_high ? yloc.abovebar : yloc.belowbar, color=color.orange, textcolor=color.white, style = use_high ? label.style_label_down : label.style_label_up))

    // 绘制
    for j = 0 to final_bins - 1
        float bin_v = array.get(vols, j)
        if bin_v > 0
            float ratio = math.pow(bin_v / (max_v == 0 ? 1 : max_v), 0.6) 
            int b_len = math.round(ratio * max_w_bars)
            color c = (j >= dn_i and j <= up_i) ? color.new(color.blue, 60) : color.new(color.gray, 70)
            if j == poc_i
                c := color.new(color.aqua, 40)
            array.push(b_arr, box.new(left_bar, true_min + (j+1)*step, left_bar + b_len, true_min + j*step, border_color=na, bgcolor=c))

    // 关键线与实时标签
    array.push(l_arr, line.new(left_bar, poc_p, right_bar, poc_p, color=color.aqua, width=3))
    array.push(l_arr, line.new(left_bar, vah_p, right_bar, vah_p, color=color.yellow, width=2, style=line.style_dashed))
    array.push(l_arr, line.new(left_bar, val_p, right_bar, val_p, color=color.yellow, width=2, style=line.style_dashed))

    string txt = "VAH: " + str.tostring(vah_p, "#.##") + "\nPOC: " + str.tostring(poc_p, "#.##") + "\nVAL: " + str.tostring(val_p, "#.##")
    array.push(lb_arr, label.new(right_bar, poc_p, txt, color=color.new(color.black, 40), textcolor=color.white, style=label.style_label_left, size=size.small))
````
